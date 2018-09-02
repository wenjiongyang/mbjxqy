local tbAct = Activity:GetClass("WomanAct")

tbAct.tbTimerTrigger = { }
tbAct.tbTrigger = { Init = { }, Start = { }, End = { }, }

--[[
	{
		-- 所有已赠送免费标签的玩家
		tbFreeSender = 
		{
			[dwID] = GetTime(),
		};
		-- 所有免费标签
		tbFreeLabel = 
		{
			[szLabel] = nCount,
		};
		-- 所有付费标签
		tbPayLabel = 
		{
			[szLabel] = nCount,
		};
		-- 保存n个付费的赠送来源
		tbPayLabelPlayer = {
			[szLabel] = 
			{
				[dwID] = nCount
			}
		}
		-- 标签第一次评论的时间
		tbLabelTime = 
		{
			[szLabel] = nTime,
		}
		-- 获得礼盒的个数
		nBoxCount = nCount,
		-- 获得礼盒的时间
		nBoxGetTime = nTime,
		-- 是否领过女神礼盒
		bSendGirlAward = false,

	}
]]

local tbItem = Item:GetClass("ImpressionBook");

function tbAct:OnTrigger(szTrigger)
	if szTrigger == "Init" then
		--self:OnInit()
    elseif szTrigger == "Start" then
        --Activity:RegisterPlayerEvent(self, "Act_EverydayTargetGainAward", "OnEverydayTargetGainAward")
        --Activity:RegisterPlayerEvent(self, "Act_SendMailGift", "OnSendMailGift")
        --Activity:RegisterPlayerEvent(self, "Act_OnPlayerLevelUp", "OnLevelUp")
        Activity:RegisterPlayerEvent(self, "Act_TrySendLabel", "OnTrySendLabel")
        Activity:RegisterPlayerEvent(self, "Act_OnPlayerLogin", "OnPlayerLogin")
        Activity:RegisterPlayerEvent(self, "Act_SynData", "SynData")
        Activity:RegisterPlayerEvent(self, "Act_SynLabelPlayer", "SynLabelPlayer")
        local _, nEndTime = self:GetOpenTimeInfo()
        -- 注册申请存库数据块,活动结束自动清掉
        self:RegisterDataInPlayer(nEndTime)
        Log("[WomanAct] start ok:", nEndTime)
    end
    Log("[WomanAct] OnTrigger:", szTrigger)
end

function tbAct:OnTrySendLabel(pPlayer, tbParam)
	local nAcceptId = tonumber(tbParam[1])
	local nType = tonumber(tbParam[2])
	local szLabel = tbParam[3]
	if not nAcceptId or not nType or not szLabel or szLabel == "" then
		return
	end
	local pAcceptPlayer = KPlayer.GetPlayerObjById(nAcceptId)
	if not pAcceptPlayer then
		pPlayer.CenterMsg("需要[FFFE0D]雙方均線上[-]才能夠添加祝福哦", true)
		return
	end

	local bRet, szMsg = self:CheckCommon(pPlayer, nAcceptId, nType, szLabel)
	if not bRet then
		pPlayer.CenterMsg(szMsg, true)
		return
	end

	bRet, szMsg = self:CheckData(pPlayer, pAcceptPlayer, nType, szLabel)
	if not bRet then
		pPlayer.CenterMsg(szMsg, true)
		return
	end

	if nType == self.FreeLabel then
		self:TrySendLabel(pPlayer.dwID, true, nil, nAcceptId, nType, szLabel)
	elseif nType == self.PayLabel then
		local function fnCostCallback(nPlayerId, bSuccess, szBillNo, nAcceptId, nType, szLabel)
			return self:TrySendLabel(nPlayerId, bSuccess, szBillNo, nAcceptId, nType, szLabel)
		end
		-- CostGold谨慎调用, 调用前请搜索 _LuaPlayer.CostGold 查看使用说明, 它处调用时请保留本注释
		local bRet = pPlayer.CostGold(self.nPayLabelCost, Env.LogWay_WomanAct, nil, fnCostCallback, nAcceptId, nType, szLabel);
		if not bRet then
			pPlayer.CenterMsg("支付失敗請稍後再試！");
			Log("[WomanAct] fnCostCallback fail", pPlayer.dwID, pPlayer.szName, pAcceptPlayer.dwID, pAcceptPlayer.szName, nType, szLabel)
		end
	end
end

function tbAct:CheckData(pPlayer, pAcceptPlayer, nType, szLabel)
	local tbAcceptInfo = self:GetDataFromPlayer(pAcceptPlayer.dwID) or {}
	tbAcceptInfo.tbFreeSender = tbAcceptInfo.tbFreeSender or {}
	tbAcceptInfo.tbFreeLabel = tbAcceptInfo.tbFreeLabel or {}
	tbAcceptInfo.tbPayLabel = tbAcceptInfo.tbPayLabel or {}
	tbAcceptInfo.tbPayLabelPlayer = tbAcceptInfo.tbPayLabelPlayer or {}
	tbAcceptInfo.tbLabelTime = tbAcceptInfo.tbLabelTime or {}

	local tbFreeSender = tbAcceptInfo.tbFreeSender
	local tbFreeLabel = tbAcceptInfo.tbFreeLabel
	local tbPayLabel = tbAcceptInfo.tbPayLabel
	local tbPayLabelPlayer = tbAcceptInfo.tbPayLabelPlayer
	local tbLabelTime = tbAcceptInfo.tbLabelTime

	local nFreeCount = Lib:CountTB(tbFreeLabel)
	local nPayCount = Lib:CountTB(tbPayLabel)
	local nLabelCount = nFreeCount + nPayCount

	local nCountInFree = tbFreeLabel[szLabel]
	local nCountInPay = tbPayLabel[szLabel]
	local bExistLabel = nCountInFree or nCountInPay

	local nNowTime = GetTime()

	--local nHimSex = Gift:CheckSex(pAcceptPlayer.nFaction)

	if nType == self.FreeLabel then
		if tbFreeSender[pPlayer.dwID] then
			return false, "您已經對目標俠士添加過該祝福，請選擇其他祝福"
		end

		-- if nHimSex ~= Gift.Sex.Girl then
		-- 	return false, "批量祝福签只能为师父添加祝福"
		-- end

		if not bExistLabel and nLabelCount >= self.nMaxLabel then
			return false, "對方的祝福已滿，請另外挑選一個俠士吧"
		end
	elseif nType == self.PayLabel then
		if not bExistLabel and nPayCount >= self.nMaxLabel then
			return false, "對方的祝福已滿，請另外挑選一個俠士吧"
		end
		if tbPayLabelPlayer[szLabel] and tbPayLabelPlayer[szLabel][pPlayer.dwID] then
			return false, "不能多次添加同一祝福"
		end
	end

	return true
end

function tbAct:TrySendLabel(nPlayerId, bSuccess, szBillNo, nAcceptId, nType, szLabel)
	if not bSuccess then
		return false, "支付失敗請稍後再試！";
	end

	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return false, "扣除手續費中途, 您掉線了！";
	end

	local pAcceptPlayer =  KPlayer.GetPlayerObjById(nAcceptId);
	if not pAcceptPlayer then
		return false, "扣除手續費中途, 對方掉線了！";
	end

	local bRet, szMsg = self:CheckCommon(pPlayer, nAcceptId, nType, szLabel, true)
	if not bRet then
		pPlayer.CenterMsg(szMsg, true)
		return false, szMsg
	end

	local nMySex = Gift:CheckSex(pPlayer.nFaction)
	local nHimSex = Gift:CheckSex(pAcceptPlayer.nFaction)
	if not nMySex or not nHimSex then
		pPlayer.CenterMsg("未知性別", true)
		return false, "未知性別"
	end

	bRet, szMsg = self:CheckData(pPlayer, pAcceptPlayer, nType, szLabel)
	if not bRet then
		pPlayer.CenterMsg(szMsg, true)
		return false, szMsg
	end

	if nType == self.FreeLabel then
		local nConsume = pPlayer.ConsumeItemInAllPos(self.nImpressionLabelItemID, self.nNeedConsumeImpressionLabel, Env.LogWay_WomanAct);
		if nConsume < self.nNeedConsumeImpressionLabel then
			szMsg = string.format("扣除道具%s失敗！",KItem.GetItemShowInfo(self.nImpressionLabelItemID, pPlayer.nFaction) or "-")
			pPlayer.CenterMsg(szMsg, true)
			return false, szMsg
		end
	end

	local tbAcceptInfo = self:GetDataFromPlayer(nAcceptId) or {}
	tbAcceptInfo.tbFreeSender = tbAcceptInfo.tbFreeSender or {}
	tbAcceptInfo.tbFreeLabel = tbAcceptInfo.tbFreeLabel or {}
	tbAcceptInfo.tbPayLabel = tbAcceptInfo.tbPayLabel or {}
	tbAcceptInfo.tbPayLabelPlayer = tbAcceptInfo.tbPayLabelPlayer or {}
	tbAcceptInfo.tbLabelTime = tbAcceptInfo.tbLabelTime or {}

	local tbFreeSender = tbAcceptInfo.tbFreeSender
	local tbFreeLabel = tbAcceptInfo.tbFreeLabel
	local tbPayLabel = tbAcceptInfo.tbPayLabel
	local tbPayLabelPlayer = tbAcceptInfo.tbPayLabelPlayer
	local tbLabelTime = tbAcceptInfo.tbLabelTime

	local nFreeCount = Lib:CountTB(tbFreeLabel)
	local nPayCount = Lib:CountTB(tbPayLabel)
	local nLabelCount = nFreeCount + nPayCount
	local bSendGirlAward = tbAcceptInfo.bSendGirlAward

	local nCountInFree = tbFreeLabel[szLabel]
	local nCountInPay = tbPayLabel[szLabel]
	local bExistLabel = nCountInFree or nCountInPay

	local nNowTime = GetTime()

	-- 更新数据

	if nType == self.FreeLabel then
		tbFreeLabel[szLabel] = (nCountInFree or 0) + 1
		--if not nCountInFree then
			tbLabelTime[self.FreeLabel] = tbLabelTime[self.FreeLabel] or {}
			tbLabelTime[self.FreeLabel][szLabel] = nNowTime
		--end
	elseif nType == self.PayLabel then
		tbPayLabel[szLabel] = (nCountInPay or 0) + 1
		if nLabelCount >= self.nMaxLabel then
			self:RemoveFreeLabel(tbFreeLabel)
		end
		--if not nCountInPay then
			tbLabelTime[self.PayLabel] = tbLabelTime[self.PayLabel] or {}
			tbLabelTime[self.PayLabel][szLabel] = nNowTime
		--end
	end

	if nType == self.FreeLabel then
		tbFreeSender[nPlayerId] = nNowTime
	elseif nType == self.PayLabel then
		-- 记录标签是哪些玩家送的
		tbPayLabelPlayer[szLabel] = tbPayLabelPlayer[szLabel] or {}
		local nSavePlayerCount = Lib:CountTB(tbPayLabelPlayer[szLabel])
		if nSavePlayerCount < self.nSavePayCount then
			tbPayLabelPlayer[szLabel][nPlayerId] = nNowTime
		end
	end

	FriendShip:AddImitity(nPlayerId, nAcceptId, self.nAddImitity, Env.LogWay_WomanAct);

	local tbSendInfo = self:GetDataFromPlayer(nPlayerId) or {}
	-- 赠送方获得奖励
	local nBoxSendGetTime = tbSendInfo.nBoxGetTime or 0
	if Lib:IsDiffDay(self.nBoxRefreshTime, nBoxSendGetTime, nNowTime) then
		tbSendInfo.nBoxCount = 0
		tbSendInfo.nBoxGetTime = nNowTime
	end
	local nBoxSendCount = tbSendInfo.nBoxCount or 0
	local tbSendAward = self.tbSendAward[nType]
	if tbSendAward and nBoxSendCount < self.nBoxLimit then
		pPlayer.SendAward(tbSendAward, true, nil, Env.LogWay_WomanAct);
		tbSendInfo.nBoxCount = nBoxSendCount + 1
		Log("[WomanAct] tbSendAward ok ", nPlayerId, pPlayer.nFaction, nAcceptId, pAcceptPlayer.nFaction, nBoxSendCount, nType)
	end

	-- 接收方获得奖励
	local nBoxAcceptGetTime = tbAcceptInfo.nBoxGetTime or 0
	if Lib:IsDiffDay(self.nBoxRefreshTime, nBoxAcceptGetTime, nNowTime) then
		tbAcceptInfo.nBoxCount = 0
		tbAcceptInfo.nBoxGetTime = nNowTime
	end
	local nBoxAcceptCount = tbAcceptInfo.nBoxCount or 0
	local tbAcceptAward = self.tbAcceptAward[nType]
	if tbAcceptAward and nBoxAcceptCount < self.nBoxLimit then
		pAcceptPlayer.SendAward(tbAcceptAward, true, nil, Env.LogWay_WomanAct);
		tbAcceptInfo.nBoxCount = nBoxAcceptCount + 1
		Log("[WomanAct] tbAcceptAward ok ", nPlayerId, pPlayer.nFaction, nAcceptId, pAcceptPlayer.nFaction, nBoxAcceptCount, nType)
	end

	-- 免费的一种算一种
	local nAfterFreeCount = Lib:CountTB(tbFreeLabel)
	-- 付费的一个算一种
	local nAfterPayCount = self:CountPayLabel(tbPayLabel)
	local nAfterLabelCount = nAfterFreeCount + nAfterPayCount	

	if nHimSex == Gift.Sex.Girl and nAfterLabelCount >= self.nGirlAwardLabelCount and not bSendGirlAward then
		pAcceptPlayer.SendAward(self.nGirlAward, true, nil, Env.LogWay_WomanAct);
		tbAcceptInfo.bSendGirlAward = nNowTime
		Log("[WomanAct] SendGirlAward ok ", nPlayerId, pPlayer.nFaction, nAcceptId, pAcceptPlayer.nFaction)
	end

	self:SaveDataToPlayer(pAcceptPlayer, tbAcceptInfo)
	self:SaveDataToPlayer(pPlayer, tbSendInfo)

	local szMsg = string.format("「%s」對「%s」添加了新的祝福「%s」", pPlayer.szName or "-", pAcceptPlayer.szName or "-", szLabel)
	if nType == self.PayLabel then
		KPlayer.SendWorldNotify(0, 999, szMsg, 1, 1);

		if pAcceptPlayer.dwKinId > 0 then
			ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.Kin, szMsg, pAcceptPlayer.dwKinId);
		end

		ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.Friend, szMsg, nAcceptId);

		local tbMail = {
			To = nAcceptId;
			Title = self.szAcceptMailTitle;
			From = self.szAcceptMailFrom;
			Text = string.format(self.szAcceptMailText, pPlayer.szName, szLabel);
			nLogReazon = Env.LogWay_WomanAct;
		};
		Mail:SendSystemMail(tbMail);
	end

	pPlayer.CenterMsg(string.format("已成功對「%s」添加祝福", pAcceptPlayer.szName or "-"), true)
	pAcceptPlayer.CenterMsg(string.format("「%s」對你添加了新的祝福「%s」", pPlayer.szName or "-", szLabel), true)

	self:SynData(pPlayer, nAcceptId)

	pPlayer.CallClientScript("Activity.WomanAct.OnSendLabelSuccess")
	pAcceptPlayer.CallClientScript("Activity.WomanAct.OnAcceptLabelSuccess")

	local szLog = nPlayerId .."_" ..pPlayer.nFaction .."_" ..pPlayer.nLevel .."_" 
	..nAcceptId .."_" ..pAcceptPlayer.nFaction .."_" ..pAcceptPlayer.nLevel .."_" 
	..nType .."_" ..szLabel .."_"
	..nFreeCount .."_" ..nPayCount .."_" .. (nCountInFree or -1) .."_" ..(nCountInPay or -1) .."_"
	.. nBoxSendCount .."_" ..nAfterFreeCount .."_" ..nAfterPayCount .."_" ..nBoxAcceptCount

	Log("[WomanAct] TrySendLabel ok ", szLog)
	return true
end

function tbAct:CountPayLabel(tbPayLabel)
	local nCount = 0
	for _,nNum in pairs(tbPayLabel or {}) do
		nCount = nCount + nNum
	end
	return nCount
end

function tbAct:RemoveFreeLabel(tbFreeLabel)
	if not tbFreeLabel or not next(tbFreeLabel) then
		Log("[WomanAct] RemoveFreeLabel fail ")
		return
	end
	local tbLabel = {}
	for szLabel,nCount in pairs(tbFreeLabel) do
		table.insert(tbLabel, {szLabel = szLabel, nCount = nCount})
	end
	local fnSort = function (a, b)
		return a.nCount < b.nCount
	end
	table.sort(tbLabel, fnSort)
	local nRemoveKey = tbLabel[1] and tbLabel[1].szLabel
	local nRemoveCount = tbLabel[1] and tbLabel[1].nCount
	tbFreeLabel[nRemoveKey] = nil
	Log("[WomanAct] RemoveFreeLabel ok ", nRemoveKey, nRemoveCount)
end

function tbAct:OnEverydayTargetGainAward(pPlayer, nAwardIdx)
	if not self:IsEndSendLabel() then
		local nSex = Gift:CheckSex(pPlayer.nFaction)
	    if not self.tbActiveIndex[nSex] then
	    	Log("[WomanAct] OnEverydayTargetGainAward sex nil ", nSex or 0, pPlayer.dwID, pPlayer.szName, pPlayer.nFaction, pPlayer.nLevel)
	    	return 
	    end
	    local tbAward = self.tbActiveIndex[nSex][nAwardIdx]
	    if not tbAward then
			return 
	    end
	    if nSex == Gift.Sex.Boy then
	    	tbAward[1][4] = self.nSendLabelEndTime
	    end
	    pPlayer.SendAward(tbAward, true, nil, Env.LogWay_WomanAct);
	    Log("[WomanAct] OnEverydayTargetGainAward ok ", nSex or 0, pPlayer.dwID, pPlayer.szName, pPlayer.nFaction, pPlayer.nLevel)
	end
end

function tbAct:OnPlayerLogin()
	self:SynActivityData(me)
end

function tbAct:SynActivityData(pPlayer, tbData)
	local nStartTime, nEndTime = self:GetOpenTimeInfo()
	pPlayer.CallClientScript("Activity.WomanAct:OnSynData", tbData, nStartTime, nEndTime)
end

function tbAct:SynLabelPlayer(pPlayer, nTargetId)
	local pTargetPlayer = KPlayer.GetPlayerObjById(nTargetId) 
	local pTargetPlayerStay = pTargetPlayer or KPlayer.GetRoleStayInfo(nTargetId)
	if not pTargetPlayerStay then
		return 
	end
	self:SynData(pPlayer, nTargetId)
	local tbData = {}
	local tbPlayerInfo = {}
	tbPlayerInfo.nState = pTargetPlayer and Player.emPLAYER_STATE_NORMAL or Player.emPLAYER_STATE_OFFLINE
	tbPlayerInfo.nImity = FriendShip:GetImity(pPlayer.dwID, nTargetId) or 0
	tbPlayerInfo.szName = pTargetPlayerStay.szName
	tbPlayerInfo.dwID = nTargetId
	tbPlayerInfo.nFaction = pTargetPlayerStay.nFaction
	tbPlayerInfo.nPortrait = pTargetPlayerStay.nPortrait
	tbPlayerInfo.nLevel = pTargetPlayerStay.nLevel
	table.insert(tbData, tbPlayerInfo)
	pPlayer.CallClientScript("Activity.WomanAct:OnSynLabelPlayer", tbData)
end

-- 同步玩家的好友祝福数据
function tbAct:SynData(pPlayer, nTargetId)
	local tbData = {}
	local nSynCountPerTime = 100
	if nTargetId then
		local tbLabelInfo = self:GetDataFromPlayer(nTargetId) or {}
		if next(tbLabelInfo) then
			tbData[nTargetId] = {}
			tbData[nTargetId].tbFreeLabel = tbLabelInfo.tbFreeLabel or {}
			tbData[nTargetId].tbPayLabel = tbLabelInfo.tbPayLabel or {}
			tbData[nTargetId].nHadLabelCount = Lib:CountTB(tbData[nTargetId].tbFreeLabel) + Lib:CountTB(tbData[nTargetId].tbPayLabel)
			tbData[nTargetId].tbLabelTime = tbLabelInfo.tbLabelTime or {}
			tbData[nTargetId].tbPayLabelPlayer = {}
			local tbPayLabelPlayerTemp = tbLabelInfo.tbPayLabelPlayer or {}
			for szLabel, tbInfo in pairs(tbPayLabelPlayerTemp) do
				tbData[nTargetId].tbPayLabelPlayer[szLabel] = {}
				tbData[nTargetId].tbPayLabelPlayer[szLabel].tbPlayerInfo = {}
				for nPlayerId, nTime in pairs(tbInfo) do
					local pPlayerStay = KPlayer.GetRoleStayInfo(nPlayerId) or {};
					local tbTemp = {}
					tbTemp.nPlayerId = nPlayerId
					tbTemp.szName = pPlayerStay.szName or "未知"
					tbTemp.nTime = nTime
					table.insert(tbData[nTargetId].tbPayLabelPlayer[szLabel].tbPlayerInfo, tbTemp)
				end
			end
		end
	else
		local tbAllFriend = KFriendShip.GetFriendList(pPlayer.dwID) or {}
		tbAllFriend[pPlayer.dwID] = true
		local nDataCount = 0
		for dwID,_ in pairs(tbAllFriend) do
			local tbLabelInfo = self:GetDataFromPlayer(dwID) or {}
			if next(tbLabelInfo) then
				nDataCount = nDataCount + 1
				tbData[dwID] = {}
				local tbFreeLabel = tbLabelInfo.tbFreeLabel or {}
				local tbPayLabel = tbLabelInfo.tbPayLabel or {}

				tbData[dwID].nHadLabelCount = Lib:CountTB(tbFreeLabel) + Lib:CountTB(tbPayLabel)
				if dwID == pPlayer.dwID then
					tbData[dwID].tbFreeLabel = tbFreeLabel
					tbData[dwID].tbPayLabel = tbPayLabel
					tbData[dwID].tbLabelTime = tbLabelInfo.tbLabelTime or {}
					tbData[dwID].tbPayLabelPlayer = {}
					local tbPayLabelPlayerTemp = tbLabelInfo.tbPayLabelPlayer or {}
					for szLabel, tbInfo in pairs(tbPayLabelPlayerTemp) do
						tbData[dwID].tbPayLabelPlayer[szLabel] = {}
						tbData[dwID].tbPayLabelPlayer[szLabel].tbPlayerInfo = {}
						for nPlayerId, nTime in pairs(tbInfo) do
							local pPlayerStay = KPlayer.GetRoleStayInfo(nPlayerId) or {};
							local tbTemp = {}
							tbTemp.nPlayerId = nPlayerId
							tbTemp.szName = pPlayerStay.szName or "未知"
							tbTemp.nTime = nTime
							table.insert(tbData[dwID].tbPayLabelPlayer[szLabel].tbPlayerInfo, tbTemp)
						end
					end

				end
				if nDataCount >= nSynCountPerTime then
					self:SynActivityData(pPlayer, tbData)
					tbData = {}
					nDataCount = 0
				end
			end
		end
	end

	self:SynActivityData(pPlayer, tbData)
end


function tbAct:OnSendMailGift(pPlayer, pAcceptPlayer, szKey)
	
end

function tbAct:OnLevelUp(pPlayer)
	if pPlayer.nLevel == self.nLevelLimit and not self:IsEndSendLabel() then
		local nStartTime, nEndTime = self:GetOpenTimeInfo()
		local tbMail = {
			To = pPlayer.dwID;
			Title = self.szMailTitle;
			From = self.szMailFrom;
			Text = self.szMailText;
			tbAttach = {{"item", tbItem.nImpressionBookItemID, 1, nEndTime}};
			nLogReazon = Env.LogWay_WomanAct;
		};
		Mail:SendSystemMail(tbMail);
		Log("[WomanAct] OnLevelUp ok ", pPlayer.dwID, pPlayer.szName, pPlayer.nFaction, pPlayer.nLevel, nStartTime, nEndTime)
	end
end

function tbAct:OnInit()
	local nStartTime, nEndTime = self:GetOpenTimeInfo()
	Mail:SendGlobalSystemMail({
		Title = self.szMailTitle;
		From = self.szMailFrom;
		Text = self.szMailText;
		tbAttach = {{"item", tbItem.nImpressionBookItemID, 1, nEndTime}};
		LevelLimit = self.nLevelLimit;
		nLogReazon = Env.LogWay_WomanAct;
	})
	Log("[WomanAct] OnInit ok ", nStartTime, nEndTime)
end
