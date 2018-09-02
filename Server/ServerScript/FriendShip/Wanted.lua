

-- 目前声明的是客户和服务端都有的


-- struct WantedInfo
-- {
-- 	RoleStayInfo* pCatcher; //抓捕者 ，设置抓捕者时 同时设置失效时间为往后的2个小时
-- 	time_t nEndTime;	//失效时间
-- 	time_t nCatchEndTime; //成功抓捕后的失效时间，不等于0且和nEndTime不同时说明应该是 对同一个玩家通缉抓捕成功，后来又有一条待发布或抓捕中记录
-- 	BOOL bSended; //是否发布
-- };


local WANTED_OPER_TIME = 7200
local WANTED_SHORT_TIME	 = FriendShip.nWantedTimeShort;

FriendShip.tbWantedData = FriendShip.tbWantedData or {}
local tbWantedData = FriendShip.tbWantedData

 --现在没做active清除操作，因为只是探索时被杀的不在线记录用
local tbNewAllWantAdd = tbNewAllWantAdd or {} --所有离线的时候被杀的玩家（探索遇敌），上线时提醒可通缉



--通缉时长，空就是添加一条可补发通缉
--pSender 可以是 Luaplayer 或者 RoleStay table ,因为探索遇敌也可能会杀
function FriendShip:AddWanted(pSender, dwWantedId, nWantedTime)
	local dwSenderId = pSender.dwID;
	if dwSenderId == dwWantedId then
		return
	end

	local pWanted = KPlayer.GetRoleStayInfo(dwWantedId)
	if not pWanted then
		return
	end

	if pSender.dwKinId ~= 0 and pSender.dwKinId == pWanted.dwKinId then
		return
	end

	local bIsPlayer = type(pSender) == "userdata";

	if self:IsFriend(dwSenderId, dwWantedId) and bIsPlayer then
		FriendShip:GetWantedData(pSender)
		return
	end

	tbWantedData[dwSenderId] = tbWantedData[dwSenderId] or {};
	local tbSenderList = tbWantedData[dwSenderId]

	local tbWantedInfo = tbSenderList[dwWantedId]
	local nTimeNow = GetTime();
	if not tbWantedInfo then --//新增的通缉 通缉时间肯定是0
		if nWantedTime and nWantedTime ~= 0 then
			Log("Error! FriendShip:AddWanted add new wanted the time must be zero");
			return
		end
		local szKinName = ""
		if pWanted.dwKinId ~= 0 then
			local tbKin = Kin:GetKinById(pWanted.dwKinId)
			if tbKin then
				szKinName = tbKin.szName;
			end
		end
		tbSenderList[dwWantedId] = {
			szWantedName = pWanted.szName,
			szSenderName = pSender.szName,
			nCatchEndTime = 0,
			nEndTime = nTimeNow + WANTED_OPER_TIME,
			--要同步到客户端显示
			nHonorLevel = pWanted.nHonorLevel,
			nState = pWanted.nState,
			nFaction = pWanted.nFaction,
			szKinName = szKinName,
			nLevel = pWanted.nLevel,
			nVipLevel = pWanted.nVipLevel,
			nPortrait = pWanted.nPortrait,

		};
		tbWantedInfo = tbSenderList[dwWantedId];
		if bIsPlayer then
			pSender.CallClientScript("Ui:OpenWindow", "WantedTips", dwWantedId, tbWantedInfo.szWantedName);
		else
			local pPlayer = KPlayer.GetPlayerObjById(dwSenderId)
			if pPlayer then
				pPlayer.CallClientScript("FriendShip:OnNewWantedMsg")
			else
				tbNewAllWantAdd[dwSenderId] = tbWantedInfo.nEndTime
			end
		end
	else
		--上条记录还在的情况下，又被杀了， 最多只保留上一次的抓捕时间
		if not nWantedTime then
			if tbWantedInfo.szCactherName then --又变成可发布状态
				if tbWantedInfo.nEndTime == tbWantedInfo.nCatchEndTime then --上条抓捕成功还没新发布时
					tbWantedInfo.bSended = false;
					tbWantedInfo.nEndTime = nTimeNow + WANTED_OPER_TIME;
					pSender.CallClientScript("Ui:OpenWindow", "WantedTips", dwWantedId, tbWantedInfo.szWantedName);
				else
					tbWantedInfo.nEndTime = nTimeNow + WANTED_SHORT_TIME;
				end

			else --上条抓捕还没被抓时又被杀延长时效
				if tbWantedInfo.bSended then
					--已发布又被杀的话通缉是延长到至少短通缉时长
					if tbWantedInfo.nEndTime - nTimeNow < WANTED_SHORT_TIME then
						tbWantedInfo.nEndTime = nTimeNow + WANTED_SHORT_TIME;
					end
				else
					tbWantedInfo.nEndTime = nTimeNow + WANTED_OPER_TIME; --不发布也会保留记录到2个小时后
				end
			end
		else
			if tbWantedInfo.bSended  then
				return
			end
			if nWantedTime == self.nWantedTimeLong then
				pSender.CostGold(FriendShip.nWantedLongCost, Env.LogWay_WantedLongCost, nil, self.AddWantedCostGoldCallbck, dwWantedId, nWantedTime)
			else
				self.AddWantedCostGoldCallbck(dwSenderId, true, nil, dwWantedId, nWantedTime)
			end
			return;
		end
	end

	-- 同步数据到发布者
	if bIsPlayer then
		local tbSycnData = Lib:CopyTB1(tbWantedInfo)
		tbSycnData.dwSenderID = dwSenderId;
		tbSycnData.dwWantedID = dwWantedId;
		pSender.CallClientScript("FriendShip:SyncOneWantedData", tbSycnData);
		pSender.CenterMsg("通緝成功")
	end
end

function FriendShip.AddWantedCostGoldCallbck(dwSenderId, bSucceed, szBillNo, dwWantedId, nWantedTime)
	if not bSucceed then
		return false
	end
	local pSender = KPlayer.GetPlayerObjById(dwSenderId)
	if not pSender then
		return false
	end

	local tbWantedInfo = tbWantedData[dwSenderId][dwWantedId]
	if not tbWantedInfo then
		return false, "通緝數據超時"
	end
	tbWantedInfo.nEndTime = GetTime() + nWantedTime;
	tbWantedInfo.bSended = true;
	Achievement:AddCount(pSender, "Prison_1", 1)

	local tbAllFriend = KFriendShip.GetFriendList(dwSenderId)
	if pSender.dwKinId ~= 0 then
		local pWanted = KPlayer.GetRoleStayInfo(dwWantedId)
		ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.Kin,  string.format("「%s」發布了對「%s」的通緝，各位大俠可以通過\"通緝\"界面前去抓捕。", pSender.szName, pWanted.szName), pSender.dwKinId);
		local tbAllMemners =  Kin:GetKinMembers(pSender.dwKinId) or {}
		for dwRoleId, v in pairs(tbAllMemners) do
			tbAllFriend[dwRoleId] = 1
		end
	end

	for dwRoleId, v in pairs(tbAllFriend) do
		local pPlayer = KPlayer.GetPlayerObjById(dwRoleId)
		if pPlayer then
			pPlayer.CallClientScript("FriendShip:OnNewWantedMsg", dwWantedId)
		end
	end


	local tbSycnData = Lib:CopyTB1(tbWantedInfo)
	tbSycnData.dwSenderID = dwSenderId;
	tbSycnData.dwWantedID = dwWantedId;

	pSender.CallClientScript("FriendShip:SyncOneWantedData", tbSycnData);
	pSender.CenterMsg("通緝成功")
	return true
end


function FriendShip:OnLogin(pPlayer)
	local dwID = pPlayer.dwID
	local nWantedEndTime = tbNewAllWantAdd[dwID]
	if nWantedEndTime then
		if nWantedEndTime > GetTime() then
			pPlayer.CallClientScript("FriendShip:OnNewWantedMsg")
		end
		tbNewAllWantAdd[dwID] = nil;
	end
end

function FriendShip:CatchWanted(pCatcher, dwWantedId, dwSenderId)
	if not AsyncBattle:CanStartAsyncBattle(pCatcher) then
		return false, "請在安全區域下參與"
	end
	if DegreeCtrl:GetDegree(pCatcher, "Catch") < 1 then
		pCatcher.CenterMsg("抓捕次數已用完")
		return
	end

	local dwCatcherId = pCatcher.dwID
	if dwCatcherId == dwWantedId then
		return
	end

	local pWanted = KPlayer.GetRoleStayInfo(dwWantedId)
	if not pWanted then
		return
	end

	local pSender = KPlayer.GetRoleStayInfo(dwSenderId)
	if not pSender then
		return
	end

	if pCatcher.dwKinId ~= 0 and pCatcher.dwKinId == pWanted.dwKinId then
		self:GetWantedData(pCatcher)
		return false, "對方已和你同一幫派"
	end

	if self:IsFriend(dwCatcherId, dwWantedId) then
		self:GetWantedData(pCatcher)
		return false, "對方已經是你的好友"
	end

	local tbSenderList = tbWantedData[dwSenderId]
	if not tbSenderList then
		self:GetWantedData(pCatcher)
		return
	end
	local tbWantedInfo = tbSenderList[dwWantedId]
	if not tbWantedInfo then
		self:GetWantedData(pCatcher)
		return
	end

	local nTimeNow = GetTime()
		--扣次数
	if tbWantedInfo.nLock and nTimeNow - tbWantedInfo.nLock <= 300 then
		return false, "對方在被其他人攻擊，請稍等"
	end
	DegreeCtrl:ReduceDegree(pCatcher, "Catch", 1)


 	tbWantedInfo.nLock = nTimeNow
 	return self:DoAsyncWanted(pCatcher, pAnsyPlayer2, dwWantedId, dwSenderId)

end

-- 获取该玩家的通缉数据
function FriendShip:GetWantedData(pPlayer)
	--遍历该玩家的好友和 家族成员
	--dataIt->second.nCatchEndTime != 0 && dataIt->second.nCatchEndTime != dataIt->second.nEndTime 这种拆成2个的客户端自己拆把
	if not pPlayer.nRequestWantedTime or GetTime() - pPlayer.nRequestWantedTime > FriendShip.nRequsetWantedCdTime then
		pPlayer.nRequestWantedTime = GetTime()
	else
		return
	end

	local tbSycnAllData = {}


	local dwKinId = pPlayer.dwKinId
	local tbAllFriend = KFriendShip.GetFriendList(pPlayer.dwID)
	local tbAllMemners = dwKinId ~= 0 and Kin:GetKinMembers(dwKinId) or {}

	--自己的全部同步
	local tbSenderList = tbWantedData[pPlayer.dwID]
	if tbSenderList then
		tbSycnAllData[pPlayer.dwID] = {};
		for dwWanted, tbWantedInfo in pairs(tbSenderList) do
			if not tbAllMemners[dwWanted] and not tbAllFriend[dwWanted] then
				tbSycnAllData[pPlayer.dwID][dwWanted] = tbWantedInfo
			end
		end
	end

	if dwKinId ~= 0 then
		local tbAllMemners = Kin:GetKinMembers(dwKinId)
		for dwRoleId, v in pairs(tbAllMemners) do
			if dwRoleId ~= pPlayer.dwID then
				local tbSenderList = tbWantedData[dwRoleId]
				if tbSenderList then
					tbSycnAllData[dwRoleId] = {}
					for dwWanted, tbWantedInfo in pairs(tbSenderList) do
						if not tbAllMemners[dwWanted] and not tbAllFriend[dwWanted] and tbWantedInfo.bSended then
							tbSycnAllData[dwRoleId][dwWanted] = tbWantedInfo
						end
					end
				end
			end
		end
	end

	--遍历好友 , 好友通缉目标可能是同家族的
	for dwRoleId, _ in pairs(tbAllFriend) do
		if not tbSycnAllData[dwRoleId] then --过滤家族发布过的
			local tbSenderList = tbWantedData[dwRoleId]
			if tbSenderList then
				tbSycnAllData[dwRoleId] = {};
				for dwWanted, tbWantedInfo in pairs(tbSenderList) do
					if not tbAllMemners[dwWanted] and not tbAllFriend[dwWanted] and tbWantedInfo.bSended then
						tbSycnAllData[dwRoleId][dwWanted] = tbWantedInfo
					end
				end
			end
		end
	end

	pPlayer.CallClientScript("FriendShip:SyncWantedData", tbSycnAllData);
end

function FriendShip:DelFriendWanted(dwRoleId1, dwRoleId2)
	 if tbWantedData[dwRoleId1] then
	 	tbWantedData[dwRoleId1][dwRoleId2] = nil;
	 end

	if tbWantedData[dwRoleId2] then
	 	tbWantedData[dwRoleId2][dwRoleId1] = nil;
	 end
end


function FriendShip:OnDeath(pKillerLuna)
	--仅限野外，战场不算
	if me.nInBattleState ~= 0 then
		return
	end
	if not pKillerLuna then
		return
	end
	local pKiller = pKillerLuna.GetPlayer()
	if not pKiller then
		return
	end

	if pKiller.nPkMode == Player.MODE_KILLER then
		self:AddHate(me, pKiller, 30000)
		self:AddWanted(me, pKiller.dwID)
	end
end

function FriendShip:DoAsyncWanted(pPlayer, pAnsyPlayer2, dwRoleId2, dwSenderId)
	if not AsyncBattle:CanStartAsyncBattle(pPlayer) then
		pPlayer.CenterMsg("目前地圖無法通緝，請先返回[FFFE0D]「襄陽城」[-]再嘗試")
		return;
	end

	local pPlayerNpc = pPlayer.GetNpc();
	local nResult = pPlayerNpc.CanChangeDoing(Npc.Doing.skill);
	if nResult == 0 then
		pPlayer.CenterMsg("目前狀態不能參加");
		return
	end

--	AsyncBattle:PrepareBattleArray(pAnsyPlayer2);
--	local pMyAsync = KPlayer.GetAsyncData(pPlayer.dwID);
--	AsyncBattle:PrepareBattleArray(pMyAsync);
	
	local nBattleKey = GetTime()
	
	if not AsyncBattle:CreateAsyncBattle(pPlayer, self.FIGHT_MAP, self.ENTER_POINT, "AsyncWanted", dwRoleId2, nBattleKey, {dwRoleId2, dwSenderId, nBattleKey}) then
		Log("Error!! Enter AsyncWanted Map Failed!")
		return;
	end
	
	pPlayer.CallClientScript("Ui:CloseWindow", "SocialPanel");
	
	return true
end



function FriendShip:OnWantedResult(pPlayer, nResult, tbBattleObj, dwRoleId2, dwSenderId, nStartTime)
	local tbSenderList = tbWantedData[dwSenderId]
	if not tbSenderList then
		Log("Error!! FriendShip:OnWantedResult1", dwSenderId)
		return
	end

	local tbWantedInfo = tbSenderList[dwRoleId2]
	if not tbWantedInfo then
		Log("Error!! FriendShip:OnWantedResult2", dwSenderId, dwRoleId2)
		return
	end
	local nTimeNow = GetTime()
	local pWanted = KPlayer.GetRoleStayInfo(dwRoleId2)

	tbWantedInfo.nLock = nil;
	local bAddHate, nRobJuBaoPen, nRobCoin, nMinusHate;

	if nResult == 1 then --成功
		tbWantedInfo.szCactherName = pPlayer.szName;
		tbWantedInfo.nCatchEndTime = nTimeNow + WANTED_OPER_TIME;
		tbWantedInfo.nEndTime = tbWantedInfo.nCatchEndTime;

		local pSender = KPlayer.GetRoleStayInfo(dwSenderId)

 		bAddHate, nRobJuBaoPen, nRobCoin, nMinusHate = self:RobCoinAddHate(pPlayer, self.nCatchAddHate, dwRoleId2)
 		if bAddHate then
			Player:SendNotifyMsg(dwRoleId2, {
				szType = "WantedKill",
				nTimeOut = nTimeNow + 86400 * 15,
				dwID = pPlayer.dwID,
				nRobCoin = nRobCoin,
				nRobJuBaoPen = nRobJuBaoPen,
				szSenderName = pSender.szName,
				})
 		end

 		local tbSycnData = Lib:CopyTB(tbWantedInfo)
 		tbSycnData.dwSenderID = dwSenderId;
 		tbSycnData.dwWantedID = dwRoleId2;

		FriendShip:AddHate(pSender, pWanted, -nMinusHate)
		FriendShip:AddImitityByKind(dwSenderId, pPlayer.dwID, Env.LogWay_Wanted)

		pPlayer.CallClientScript("FriendShip:SyncOneWantedData", tbSycnData);

		local pPlayerSend = KPlayer.GetPlayerObjById(dwSenderId)
		if pPlayerSend then
			pPlayerSend.CallClientScript("FriendShip:SyncOneWantedData", tbSycnData);
		end

		Mail:SendSystemMail(
		{
			To = dwSenderId,
			Text =  string.format("你通緝的仇人「%s」被「%s」擊殺了", pWanted.szName, pPlayer.szName)
		})
 	end

 	pPlayer.CallClientScript("FriendShip:OnClientWantedResult", nResult, pWanted, nMinusHate, nRobCoin)

 	pPlayer.TLogRoundFlow(Env.LogWay_Wanted, dwRoleId2, 0, nTimeNow - nStartTime, nResult == 1 and Env.LogRound_SUCCESS or Env.LogRound_FAIL, 0, nRobCoin)
end


PlayerEvent:RegisterGlobal("OnDeath",   FriendShip.OnDeath, FriendShip);

AsyncBattle:ResgiterBattleType("AsyncWanted", FriendShip, FriendShip.OnWantedResult, nil, FriendShip.FIGHT_MAP)