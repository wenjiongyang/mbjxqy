local nEndDay = 11			-- 结束时间（第x天凌晨0:00)
local nRewardMinJoinDay = 2	-- 加入家族超过x天才有奖励
local nMaxRewardPerKin = 160	-- 每个家族最多x人领奖

local nCheckDelta = 5*60	-- 检测频率（秒）

--领袖称号itemId
local tbLeaderTitleItemIds = {
	[1] = 4015,	--第一家族领袖
	[2] = 4016,	--2~10
	[3] = 4017,	--11~20
}

function Kin:InitEndDay()
	local nCreateTimestamp = GetServerCreateTime()
	local nCreateTime = Lib:GetTimeNum(nCreateTimestamp)
	if nCreateTime<20160617 then
		nEndDay = 15
	end
	Log("Kin:InitEndDay", nCreateTimestamp, nCreateTime, nEndDay)
end

function Kin:OpenSrvInit()
	self.tbOpenSrvStatus = ScriptData:GetValue("KinOpenSrvStatus") or {
		bEnd = false,
		bSendDontQuit = false,
	}

	local tbSettings = LoadTabFile("Setting/Kin/KinOpenSrvActivity.tab", "ddddddddddddddddddd", nil,
		{"nRankTo", "nMasterTitle", "nViceMasterTitle", "nElderTitle", "nMascotTitle", "nEliteTitle", "nNormalTitle", "nMasterRewardId",
		 "nMasterRewardCount", "nViceMasterRewardId", "nViceMasterRewardCount", "nElderRewardId", "nElderRewardCount", "nMascotRewardId",
		 "nMascotRewardCount", "nEliteRewardId", "nEliteRewardCount", "nNormalRewardId", "nNormalRewardCount"})
	table.sort(tbSettings, function(tbA, tbB)
		return tbA.nRankTo<tbB.nRankTo
	end)
	self.tbOpenSrvSettings = tbSettings
	self.nMaxRewardRank = tbSettings[#tbSettings].nRankTo

	self:InitEndDay()
end

local nLastSendRewardInfoDay = 0
local nNextCheckTime = 0
function Kin:OpenSrvActive()
	local nNow = GetTime()
	if nNow<nNextCheckTime then
		return
	end
	nNextCheckTime = nNow+nCheckDelta

	if self.tbOpenSrvStatus.bEnd then
		return
	end

	local nToday = Lib:GetLocalDay()
	if nToday~=nLastSendRewardInfoDay then
		self:_OpenSrvPushRewardInfo()
		nLastSendRewardInfoDay = nToday
	end

	local nOpenDay = Lib:GetServerOpenDay()
	if not self.tbOpenSrvStatus.bSendDontQuit and nOpenDay==nEndDay-nRewardMinJoinDay-1 then
		self:_OpenSrvDontQuitMail()
	end

	if nOpenDay>=nEndDay then
		self:_OpenSrvDoEnd()
	end
end

function Kin:_OpenSrvSetStatus(szKey, bValue)
	self.tbOpenSrvStatus[szKey] = bValue
	ScriptData:SaveAtOnce("KinOpenSrvStatus", self.tbOpenSrvStatus)
end

function Kin:_OpenSrvDoEnd()
	self:_OpenSrvSetStatus("bEnd", true)

	local szKey = "kin"
	RankBoard:Rank(szKey)
	local tbTopList = RankBoard:GetRankBoardWithLength(szKey, self.nMaxRewardRank, 1)
	self:_OpenSrvSendReward(tbTopList)
	self:_OpenSrvPushResultInfo(tbTopList)
end

function Kin:_OpenSrvGetSetting(nRank)
	for nIdx,tb in ipairs(self.tbOpenSrvSettings) do
		if nRank<=tb.nRankTo then
			return tb, nIdx
		end
	end
end

local tbCareerToKey = {
	[Kin.Def.Career_Master] = "Master", -- 族长
	[Kin.Def.Career_ViceMaster] = "ViceMaster", -- 副族长
	[Kin.Def.Career_Elder] = "Elder", -- 长老
	[Kin.Def.Career_Mascot] = "Mascot", -- 家族宝贝
	[Kin.Def.Career_Elite] = "Elite", -- 精英
	[Kin.Def.Career_Normal] = "Normal", -- 正式成员
	[Kin.Def.Career_New] = "Normal",
}

function Kin:_OpenSrvGetRankDesc(nRank)
	if nRank==1 then
		return "[ffb400]【第一幫派】[-]"
	elseif nRank<=10 then
		return "[ff68a1]【十大幫派】[-]"
	elseif nRank<=20 then
		return "[9f5fff]【卓越幫派】[-]"
	end
end

function Kin:_OpenSrvSendReward(tbTopList)
	local nNow = GetTime()
	for i,tb in ipairs(tbTopList) do
		local tbSetting,nSettingIdx = self:_OpenSrvGetSetting(i)

		local tbKin = self:GetKinById(tb.dwKinId)
		if tbKin and tbSetting then
			local nSendCount = 0
			local nLeaderId = tbKin:GetLeaderId()
			local nLeaderTitleItemId = tbLeaderTitleItemIds[nSettingIdx] or 0
			for nCareer,szKey in pairs(tbCareerToKey) do
				local tbIds = tbKin:GetCareerMemberIds(nCareer)
				for _,nId in ipairs(tbIds) do
					local tbInfo = Kin:GetMemberData(nId)
					if tbInfo then

						local nJoinTime = tbInfo:GetJoinTime()
						if nNow-nJoinTime>=24*3600*nRewardMinJoinDay then
							local tbAttach = {}
							local nTitle = tbSetting[string.format("n%sTitle", szKey)]
							if nTitle and nTitle>0 then
								table.insert(tbAttach, {"AddTimeTitle", nTitle, nNow+30*24*3600})
							end

							local nRewardId = tbSetting[string.format("n%sRewardId", szKey)]
							local nRewardCount = tbSetting[string.format("n%sRewardCount", szKey)] or 1
							if nRewardId and nRewardId>0 then
								table.insert(tbAttach, {"item", nRewardId, nRewardCount})
							end

							--领袖称号奖励
							if nLeaderId==nId and nLeaderTitleItemId>0 then
								table.insert(tbAttach, {"AddTimeTitle", nLeaderTitleItemId, nNow+30*24*3600})
							end

							local szText = string.format("    恭喜你所在的幫派在百大幫派活動中排名[FFFE0D]第%d名[-]", i)
							local szRankDesc = self:_OpenSrvGetRankDesc(i)
							if szRankDesc then
								szText = string.format("%s，被評選為%s。", szText, szRankDesc)
							end
							Mail:SendSystemMail({
								To = nId,
							    Title = "百大幫派評選",
							    Text = szText,
							    From = "系統",
							    tbAttach = tbAttach,
							})
							Log("Kin:_OpenSrvSendReward sent", nSendCount, tb.dwKinId, nId, nJoinTime, i, nCareer, #tbAttach)

							nSendCount = nSendCount+1
							if nSendCount>=nMaxRewardPerKin then
								Log("Kin:_OpenSrvSendReward break", nSendCount, nMaxRewardPerKin)
								break
							end
						else
							Log("Kin:_OpenSrvSendReward not send", tb.dwKinId, nId, nJoinTime, nNow, nCareer)
						end
						
					end
				end
				if nSendCount>=nMaxRewardPerKin then
					Log("Kin:_OpenSrvSendReward break", nSendCount, nMaxRewardPerKin)
					break
				end
			end
		end
	end
end

function Kin:_OpenSrvGetLeftDays()
	local nOpenDay = Lib:GetServerOpenDay()	
	return nEndDay-nOpenDay-1
end

function Kin:_OpenSrvGetEndDate()
	local nCreateTime = GetServerCreateTime()
	local nEndTime = nCreateTime+24*3600*(nEndDay-1)
	return Lib:GetTimeStr(nEndTime)
end

function Kin:_OpenSrvDontQuitMail()
	self:_OpenSrvSetStatus("bSendDontQuit", true)

	local nDaysLeft = self:_OpenSrvGetLeftDays()
	local szEndDate = self:_OpenSrvGetEndDate()
	for nKinId in pairs(self.KinData) do
		Mail:SendKinMail({
			KinId = nKinId,
			Text = string.format("    諸位俠士，百大幫派評選將於[FFFE0D]%s（%d天后）[-]截止！\n    [FFFE0D]注意：此時脫離幫派將會錯失豐厚的活動獎勵[-]", szEndDate, nDaysLeft),
			From = "幫派總管",
		})
	end
end

function Kin:_OpenSrvPushRewardInfo()
	local nCreateTime = GetServerCreateTime()
	local tbCreateTime = os.date("*t", nCreateTime)
	tbCreateTime.hour = 0
	tbCreateTime.min = 0
	tbCreateTime.sec = 0
	local nDayBegin = os.time(tbCreateTime)
	local nDeadline = nDayBegin+3600*24*(nEndDay-1)
	local tbActData = {
		bResult = false,
		nDeadline = nDeadline,
	}
	for _,tbSetting in ipairs(self.tbOpenSrvSettings) do
		table.insert(tbActData, {
			{tbSetting.nMasterRewardId, tbSetting.nMasterRewardCount},
			{tbSetting.nViceMasterRewardId, tbSetting.nViceMasterRewardCount},
			{tbSetting.nNormalRewardId, tbSetting.nNormalRewardCount},
		})
	end
	NewInformation:AddInfomation("OpenSrvActivity", GetTime()+24*3600, tbActData)
end

function Kin:_OpenSrvPushResultInfo(tbTopList)
	local nValidTime = GetTime()+3600*24*2
	local tbActData = {
		bResult = true,
	}

	for i=1,10 do
		local tb = tbTopList[i]
		if not tb then break end

		local tbKin = self:GetKinById(tb.dwKinId)
		if tbKin then
			local bMaster = false
			local nPeopleId = tbKin:GetLeaderId()
			if not nPeopleId or nPeopleId<=0 then
				nPeopleId = tbKin:GetMasterId()
				bMaster = true
			end
			local pPeople = KPlayer.GetRoleStayInfo(nPeopleId)
			table.insert(tbActData, {
				szKinName = tbKin.szName,
				bMaster = bMaster,
				szName = pPeople and pPeople.szName or "",
			})
		end
	end
	NewInformation:AddInfomation("OpenSrvActivity", nValidTime, tbActData)
end

function Kin:OpenSrvMyKinRankReq()
	local nKinId = me.dwKinId
	if not nKinId or nKinId<=0 then return end

	local tbTopList = RankBoard:GetRankBoardWithLength("kin", self.nMaxRewardRank, 1)
	local nRank = 0
	for i, tb in ipairs(tbTopList) do
		if nKinId==tb.dwKinId then
			nRank = i
			break
		end
	end
	me.CallClientScript("Kin:MyKinRankRsp", nRank)
end