function Forbid:OnLogin(pPlayer)
	local  tbForbidData = pPlayer.GetScriptTable("Forbid");
	tbForbidData.tbAward = tbForbidData.tbAward or {};
	tbForbidData.BanData = tbForbidData.BanData or {};
	pPlayer.tbForbidData = tbForbidData;
	self:CheckOverdue(pPlayer)
	if Forbid:IsForbidAward(pPlayer) then
		local tbForbidState = pPlayer.tbForbidData.tbAward;
		self:SyncForbidAwardState(pPlayer, tbForbidState.nEndTime, tbForbidState.szMsg);
	end
	self:BanNotice(pPlayer) 					-- 会覆盖零收益的提示,可接受
end

function Forbid:IsForbidAward(pPlayer)
	if not pPlayer.tbForbidData then
		return false
	end
	
	local nEndTime = pPlayer.tbForbidData.tbAward.nEndTime or 0;

	return nEndTime < 0 or (nEndTime > 0 and GetTime() < nEndTime);
end

function Forbid:GetForbidAwardMsg(pPlayer)
	return pPlayer.tbForbidData.tbAward.szMsg or "";
end

function Forbid:SetForbidAward(pPlayer, nEndTime, szMsg,bHideBox)
	local tbForbidState = pPlayer.tbForbidData.tbAward;
	tbForbidState.nEndTime = nEndTime;
	tbForbidState.szMsg = szMsg;

	self:SyncForbidAwardState(pPlayer, nEndTime, szMsg,bHideBox);
end

function Forbid:SendForbidAwardNotice(pPlayer)
	pPlayer.CallClientScript("Forbid:OnForbidAwardNotice")
end

function Forbid:SyncForbidAwardState(pPlayer, nEndTime, szMsg,bHideBox)
	pPlayer.CallClientScript("Forbid:OnSyncForbidAwardState", nEndTime, szMsg,bHideBox)
end

function Forbid:Ban(pPlayer,nType,nEndTime,szTips,dwKinId)
	if (not pPlayer and not dwKinId) or not nType or not self:CheckBanType(nType) then
		local nPlayerId = pPlayer and pPlayer.dwID or 0
		Log("[Ban] can not fine ban type or player or dwKinId！！！ ",nPlayerId,nType,dwKinId);
		return 
	end
	if nEndTime > GetTime() then
		if nType == Forbid.BanType.KinRank then						-- 家族是可以及时生效的，需dwKinId
			if dwKinId and dwKinId > 0 then
				local kinData = Kin:GetKinById(dwKinId)
				if not kinData then
					Log("[Ban] can not fine kinData ！！！  dwKinId is ",dwKinId);
					return
				end
				kinData:SetBanRankTime(nEndTime,szTips)
				Log(string.format("[Ban] Ban [%d],[%d],[%s],[%s],[%s],[%d]",(pPlayer and pPlayer.dwID or 0),nType,os.date("%c",GetTime()),os.date("%c",nEndTime),szTips or "",dwKinId or 0))
			end
		else
			local tbBanData = pPlayer.tbForbidData.BanData;			-- 玩家在线及时生效，玩家不在线上线生效,需pPlayer
			if not tbBanData then
				Log("[Ban] can not fine BanData ！！！  player dwID is ",pPlayer.dwID);
				return
			end

			if not tbBanData[nType] then
				tbBanData[nType] = {}
				tbBanData[nType].nBanTime = 0
				tbBanData[nType].szBanTips = ""
			end
			tbBanData[nType].nBanTime = nEndTime
			tbBanData[nType].szBanTips = szTips
			Log(string.format("[Ban] Ban [%d],[%d],[%s],[%s],[%s],[%d]",(pPlayer and pPlayer.dwID or 0),nType,os.date("%c",GetTime()),os.date("%c",nEndTime),szTips or "",dwKinId or 0))
		end
	end
end

-- 冻结排行版时清掉玩家的数据
function Forbid:ClearRankData(nPlayerId,nType,dwKinId)
	if (not nPlayerId and not dwKinId) or not nType then
		Log("[ClearRankData] can not fine ban type or nPlayerId or dwKinId！！！ ",nPlayerId,nType,dwKinId);
		return 
	end
	if Forbid.RankType[nType] then
		local szRankType
		if nType == Forbid.BanType.FightPower_Faction then
			local pPlayer = KPlayer.GetPlayerObjById(nPlayerId) or KPlayer.GetRoleStayInfo(nPlayerId); 
			local nFaction = pPlayer and pPlayer.nFaction or 0
			szRankType = "FightPower_" ..nFaction
		else
			szRankType = Forbid.RankType[nType]
		end
		 
		local pRank = KRank.GetRankBoard(szRankType)
		if not pRank then	
			Log("[Forbid] ClearRankData can not find pRank",nPlayerId or 0,nType,dwKinId or 0,szRankType)
			return
		end

		if nType == Forbid.BanType.KinRank then
			if dwKinId <= 0 then
				return
			end
			if not Kin:GetKinById(dwKinId) then
				return
			end
			pRank.RemoveByID(dwKinId)										
		else
			local pPlayerInfo = KPlayer.GetRoleStayInfo(nPlayerId);
			if not pPlayerInfo then
				return
			end
			pRank.RemoveByID(nPlayerId)
		end

		pRank.Rank();
		Log(string.format("[ClearRankData] ClearRankData [%d], [%d], [%d]",nPlayerId or 0,nType,dwKinId or 0))
	elseif Forbid.ActRankType[nType] then

		if nType == Forbid.BanType.WuShenRank then
			RankBattle:ClearPlayerRank(nPlayerId)
			Log(string.format("[ClearRankData] ClearRankData [%d], %d, [%d]",nPlayerId or 0,nType,dwKinId or 0))
		elseif nType == Forbid.BanType.WuLinMengZhu then
			Boss:ResetPlayerData(nPlayerId)
			Log(string.format("[ClearRankData] ClearRankData [%d], [%d], [%d]",nPlayerId or 0,nType,dwKinId or 0))
		end
	end
end

function Forbid:RelieveBan(pPlayer,nType,dwKinId)
	if (not pPlayer and not dwKinId) or not nType or not self:CheckBanType(nType) then
		local nPlayerId = pPlayer and pPlayer.dwID or 0
		Log("[RelieveBan] can not fine ban type or player！！！ ",nPlayerId,nType,dwKinId);
		return 
	end
	if nType == Forbid.BanType.KinRank then
		if dwKinId == 0 then
			return 
		end
		local kinData = Kin:GetKinById(dwKinId)
		if not kinData then
			Log("[RelieveBan] can not fine kinData ！！！  dwKinId is ",dwKinId);
			return
		end
		kinData:SetBanRankTime(0,"")
		RankBoard:UpdateRankVal("kin", kinData)
		Log(string.format("[RelieveBan] [%d], [%d], [%d]", (pPlayer and pPlayer.dwID or 0), nType, dwKinId or 0))
	else
		local tbBanData = pPlayer.tbForbidData.BanData;
		if not tbBanData then
			Log("[RelieveBan] can not fine BanData ！！！  player dwID is ",pPlayer.dwID);
			return
		end
		if not tbBanData[nType] then
			return 
		end
		tbBanData[nType].nBanTime = 0;
		tbBanData[nType].szBanTips = "";

		local fnParam = Forbid.RankUpdateVal[nType]
		if fnParam then
			GameSetting:SetGlobalObj(pPlayer); 						-- 凌绝峰收集榜接口需要强制用到me
	   		local tbParam = {Lib:CallBack({fnParam, pPlayer})};
	   		GameSetting:RestoreGlobalObj();
	   		if tbParam then
				table.remove(tbParam,1) 							-- 去掉返回结果
				RankBoard:UpdateRankVal(unpack(tbParam))			-- 手动更新玩家数据
			else
				Log("[RelieveBan] UpdateRankVal no param ??",nType,pPlayer.szName,pPlayer.dwID)
			end
		end
		Log(string.format("[RelieveBan]  [%d], [%d], [%d]", (pPlayer and pPlayer.dwID or 0), nType, dwKinId or 0))
	end
end

function Forbid:IsBanning(pPlayer,nType,dwKinId)
	local nBanTime = 0

	if nType == Forbid.BanType.KinRank then
		if not dwKinId or dwKinId == 0 then
			return false
		end
		local kinData = Kin:GetKinById(dwKinId)
		if not kinData then
			return false
		end
		nBanTime = kinData:GetBanRankTime();
	else
		local tbForbidData = pPlayer.tbForbidData
		-- OnEnterMap 是在 OnLogin 之前调的,如果在 OnEnterMap 的时候调这里,那么 pPlayer.tbForbidData 是 nil
		if not tbForbidData then 						
			tbForbidData = pPlayer.GetScriptTable("Forbid");
		end
		local tbBanData = tbForbidData.BanData;
		if not tbBanData or not tbBanData[nType] then
			return false
		end
		nBanTime = tbBanData[nType].nBanTime or 0;
	end

	return nBanTime == 0 and false or GetTime() < nBanTime;
end

function Forbid:BanEndTime(pPlayer,nType,dwKinId)
	local nBanTime = 0

	if not nType then
		return nBanTime
	end

	if nType == Forbid.BanType.KinRank then
		if not dwKinId or dwKinId == 0 then
			return 0
		end
		local kinData = Kin:GetKinById(dwKinId)
		if not kinData then
			return 0
		end
		nBanTime = kinData:GetBanRankTime();
	else
		local tbBanData = pPlayer.tbForbidData.BanData;
		if not tbBanData[nType] then
			return 0
		end
		nBanTime = tbBanData[nType].nBanTime or 0;
	end

	return nBanTime
end

--[[
	家族排行榜应该什么时候检查过期信息？？
	目前不处理的话只有家族的数值变化才会重新排名
]]
function Forbid:CheckOverdue(pPlayer)
	local tbBanData = pPlayer.tbForbidData.BanData;								-- 家族排行榜冻结信息没有存在BanData里
	for nType,tbInfo in pairs(tbBanData) do
		if Forbid.RankType[nType] and (tbInfo.nBanTime and tbInfo.nBanTime ~= 0) and not self:IsBanning(pPlayer,nType) then	-- 等级和战力排行榜在玩家冻结过期是手动排行
			tbInfo.nBanTime = 0;
			tbInfo.szBanTips = "";
			local fnParam = Forbid.RankUpdateVal[nType]
			local tbParam = fnParam and {fnParam(pPlayer)}
			if tbParam then
				RankBoard:UpdateRankVal(unpack(tbParam))	-- 时间过期之后手动更新玩家排名
			else
				Log("[Forbid] CheckOverdue no param ??",nType,pPlayer.szName,pPlayer.dwID)
			end
			Log(string.format("[Forbid] CheckOverdue ,[%d],[%d]",pPlayer.dwID,nType))
		end
	end
end

function Forbid:CheckBanType(nType)
	if Forbid.szBanName[nType] then
		return true
	end
end

function Forbid:BanTips(pPlayer,nType)
	local szTips = ""
	if not nType then
		return szTips
	end
	if self:IsBanning(pPlayer,nType) then
		if nType == Forbid.BanType.KinRank then
			local kinData = Kin:GetKinById(pPlayer.dwKinId)
			szTips = kinData:GetBanRankTips();
		else
			local tbBanData = pPlayer.tbForbidData.BanData;
			szTips = tbBanData[nType].szBanTips
		end
	end
	return szTips
end

function Forbid:BanNotice(pPlayer)
	local szMsg = ""

	for szBanType,nBanType in pairs(Forbid.BanType) do
		local nEndTime,szTime
		if Forbid.RankType[nBanType] or Forbid.ActRankType[nBanType] then
			if nBanType == Forbid.BanType.KinRank then
				local kinMemberData = Kin:GetMemberData(pPlayer.dwID) or {};
				local nKinId = kinMemberData.nKinId or 0
				if Forbid:IsBanning(_,Forbid.BanType.KinRank,nKinId) then
					nEndTime = Forbid:BanEndTime(_,Forbid.BanType.KinRank,nKinId)
					szTime = Lib:GetTimeStr3(nEndTime) or ""
				end
			else
				if Forbid:IsBanning(pPlayer,nBanType) then
					nEndTime = Forbid:BanEndTime(pPlayer,nBanType)
					szTime = Lib:GetTimeStr3(nEndTime) or ""
				end
			end
			if szTime and szTime ~= "" then
				szMsg = szMsg ..string.format("%s被禁止,解禁時間%s\n",Forbid.szBanName[nBanType] or "",szTime)
			end
		end
	end

	if szMsg and szMsg ~= "" then
		pPlayer.CallClientScript("Forbid:OnBanNotice", szMsg)
	end
end

