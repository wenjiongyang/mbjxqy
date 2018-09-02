
-- 客户端往 server 调用接口，只在这个文件内定义，其它地方不允许

function c2s:OnClientCall(szFunc, ...)
	if szFunc == "OnClientCall" then
		return;
	end
	if MODULE_ZONESERVER then
		if not c2z[szFunc] then
			Log("[c2z] OnClientCall ERR ?? function can't find ", szFunc);
			return;
		end

		c2z[szFunc](c2z, ...);
	else
		if not c2s[szFunc] then
			Log("[c2s] OnClientCall ERR ?? function can't find ", szFunc);
			return;
		end

		c2s[szFunc](c2s, ...);
	end
end

function c2s:OnFinishTaskDialog(nTaskId, nState, nNpcId)
	if nState ~= Task.STATE_CAN_FINISH and nState ~= Task.STATE_CAN_ACCEPT then
		return;
	end

	local tbTask = Task:GetTask(nTaskId);
	if not tbTask then
		return;
	end

	if nState == Task.STATE_CAN_ACCEPT then
		if not Task:CheckCanClientAccetp(nTaskId) and (not me.nCurAcceptTaskId or me.nCurAcceptTaskId ~= nTaskId) then
			me.CenterMsg(string.format("任務%s無法通過用戶端接取", nTaskId));
			return;
		end

		me.nCurAcceptTaskId = nil;
		Task:TryAcceptTask(me, nTaskId, nNpcId);
		return;
	end

	if nState == Task.STATE_CAN_FINISH then
		Task:TryFinishTask(me, nTaskId, nNpcId);
		return;
	end
end

function c2s:DoTaskNextStep(nTaskId, nNpcId)
	if not nTaskId or nTaskId <= 0 or not nNpcId or nNpcId <= 0 then
		return;
	end

	local tbTask = Task:GetTask(nTaskId);
	local nState = Task:GetTaskState(me, nTaskId, nNpcId);
	if nState == Task.STATE_CAN_ACCEPT and not Task:CheckCanClientAccetp(nTaskId) then
		me.CenterMsg(string.format("任務%s無法通過用戶端接取", nTaskId));
		return;
	end

	Task:DoTaskNextStep(me, nNpcId, nTaskId);
end

function c2s:OnDialogSelect(nIndex)
	local tbDialogInfo = Dialog:GetPlayerDialogInfo(me);
	local pNpc = KNpc.GetById(tbDialogInfo.NpcId or 0);

	Dialog:SetPlayerDialog(me, {});		-- 清理数据
	if tbDialogInfo.NpcId and tbDialogInfo.NpcId > 0 then
		if not pNpc then
			return;
		end

		local nDistance = me.GetNpc().GetDistance(pNpc.nId);
		if nDistance > Npc.DIALOG_DISTANCE then
			print("OnSimpleTapNpc >> dis = " .. nDistance);
			return;
		end
	end


	if not tbDialogInfo or not tbDialogInfo.OptList then
		Log("Dialog err select !!");
		return;
	end

	local tbOpt = tbDialogInfo.OptList[nIndex];
	if not tbOpt or not tbOpt.Type then
		Log("Dialog err opt type " .. ((tbOpt or {}).Type or "nil"));
		return;
	end

	if tbOpt.Type == "Script" then
		if not tbOpt.Callback then
			Log("Dialog err Script Callback is nil !!");
			return;
		end
		GameSetting:SetGlobalObj(me, pNpc, it);
		tbOpt.Callback(unpack(tbOpt.Param or {}));
		GameSetting:RestoreGlobalObj();
		return;
	elseif tbOpt.Type == "Task" then
		tbOpt.Param = tbOpt.Param or {};
		if not tbOpt.Param.nNpcId or tbOpt.Param.nNpcId <= 0 then
			Log("Dialog err select task " .. (tbOpt.Param.nNpcId or "nil"));
			return;
		end
		GameSetting:SetGlobalObj(me, pNpc, it);
		Task:DoTaskNextStep(me, tbOpt.Param.nNpcId, tbOpt.Param.nTaskId);
		GameSetting:RestoreGlobalObj();
		return;
	end
end

function c2s:OnSimpleTapNpc(nNpcId)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		Log("OnSimpleTapNpc err pNpc is nil !!");
		return;
	end

	if pNpc.nKind <= Npc.KIND.none or pNpc.nKind >= Npc.KIND.num then
		Log("OnSimpleTapNpc err pNpc.nKind ?? " .. pNpc.nKind);
		return;
	end

	local nDistance = me.GetNpc().GetDistance(pNpc.nId);
	if nDistance > Npc.DIALOG_DISTANCE then
		print("OnSimpleTapNpc >> dis = " .. nDistance);
		return;
	end

	if pNpc.nKind == Npc.KIND.dialoger then
		GameSetting:SetGlobalObj(me, pNpc, it);
		Npc:OnDialog(him.szClass, him.szScriptParam);
		GameSetting:RestoreGlobalObj();
	else
		print("OnSimpleTapNpc >> pNpc.nKind = " .. pNpc.nKind);
		return;
	end
end

function c2s:OnMsgBoxSelect(nIndex)
	if not me.tbMsgBoxCallback or not me.tbMsgBoxCallback[nIndex] then
		return;
	end

	Dialog:OnMsgBoxSelect(nIndex, true);
end

function c2s:NotifyItem(nId,tbMsg)
	Item:NotifyItem(me,nId,tbMsg)
end

function c2s:UseItem(nId)
	Item:UseItem(nId)
end

function c2s:UseAllItem(nId)
	Item:UseAllItem(nId)
end

function c2s:UseEquip(nId, nEquipPos)
	if not nEquipPos then
		nEquipPos = -1;
	end

	if type(nEquipPos) ~= "number" then
		return;
	end

	Item:UseEquip(nId, nil, nEquipPos)
end

function c2s:UnuseEquip(nPos)
	Item:UnuseEquip(nPos)
end

function c2s:OnTeamRequest( ...)
	if not me.CanTeamOpt() then
		me.CenterMsg("目前地圖無法進行此操作");
		return
	end
	TeamMgr:ClientRequest( ...);
end

function c2s:OnTeamUpRequest( ... )
	if not me.CanTeamOpt() then
		me.CenterMsg("目前地圖無法進行此操作");
		return
	end
	TeamMgr:QuickTeamUpRequest( ... );
end

function c2s:OnSyncNearbyTeamsReq(tbIds)
	TeamMgr:OnSyncNearbyTeamsReq(tbIds)
end

function c2s:DoWatchRequest(szType, ...)
	local fnCallBack = CommonWatch.tbC2SRequest[szType];
	if not fnCallBack then
		return;
	end

	fnCallBack(me, ...);
end

--- 单人副本相关
function c2s:TryResetFubenTimes(nFubenIndex, nFubenLevel)
	Log("[PersonalFuben] ERR TryResetFubenTimes is nil !!!");
end

function c2s:TryCreatePersonalFuben(nSectionIdx, nSubSectionIdx, nFubenLevel, tbHelperInfo)
	PersonalFuben:TryCreatePersonalFuben(me, nSectionIdx, nSubSectionIdx, nFubenLevel, tbHelperInfo);
end

function c2s:EnterKinNest()
	Kin.KinNest:EnterKinNest(me.dwID);
end

function c2s:ActivityCalendarInterface()
	Kin.KinNest:ActivityCalendarInterface(me.dwID);
end

function c2s:SendPersonalFubenResult(tbClientData)
	local tbCurData = PersonalFuben:GetCurrentFubenData(me);

	if tbCurData.nStartTime and tbClientData.nServerStartTime and tbCurData.nStartTime == tbClientData.nServerStartTime then
		PersonalFuben:OnSendResult(me, tbClientData);
	else
		Lib:LogData(tbCurData or {}, tbClientData or {});
		Log("[Fuben] PersonalFuben c2s:SendPersonalFubenResult ERR ?? ");
	end
end

function c2s:TryToReviveInPersonalFuben(nDeathCount)
	Log("[PersonalFuben] ERR TryToReviveInPersonalFuben is nil !!!");
end

function c2s:TryGetPersonalFubenData()
	PersonalFuben:DoSyncPlayerData(me);
end

function c2s:TryGetStarAward(nSectionIdx, nFubenLevel, nIndex)
	Log("[PersonalFuben] ERR TryGetStarAward is nil !!!");
end

function c2s:LeaveFuben(bIsPersonalFuben, bShowStronger, bIsWin)
	if bIsPersonalFuben then
		if me.nState ~= Player.emPLAYER_STATE_ALONE then
			return;
		end

		if not bIsWin then
			local nX, nY, nFightMode = Map:GetDefaultPos(me.nMapTemplateId);
			me.SetPosition(nX, nY);
			me.nFightMode = nFightMode;
		end

		me.LeaveClientMap();
		me.CallClientScript("PersonalFuben:OnLeaveSucess");
		PersonalFuben:ClearCurrentFubenData(me);
	else
		if me.nLastMapExploreMapId then --从探索进去的话要返回探索
			Fuben.DungeonFubenMgr:CheckReturnMapExplore(me)
		elseif me.nMapTemplateId == Fuben.WhiteTigerFuben.OUTSIDE_MAPID then --从白虎堂第一层出来要回到准备场
			Fuben.WhiteTigerFuben:TryBackToPrepareMap(me)
		elseif me.nMapTemplateId == Activity:GetClass("HouseDefend").nFubenMapTemplateId then
			local bRet = Map:SwitchKinMap(me);
			if not bRet then
				me.GotoEntryPoint();
			end
		else
			me.GotoEntryPoint();
		end
	end

	if bShowStronger then
		me.CallClientScript("Ui:OpenWindow", "StrongerPanel");
	end
end

function c2s:TrySweep(nSectionIdx, nSubSectionIdx, nFubenLevel)
	Log("[PersonalFuben] ERR TrySweep is nil !!!");
	--local tbResult = PersonalFuben:TrySweep(me, nSectionIdx, nSubSectionIdx, nFubenLevel);
	--if tbResult then
	--	me.CallClientScript("PersonalFuben:OnSweepOver", {tbResult})
	--end
end

function c2s:TryMultiSweep(nSectionIdx, nSubSectionIdx, nFubenLevel)
	Log("[PersonalFuben] ERR TryMultiSweep is nil !!!");

	--local tbAllAward = PersonalFuben:TryMultiSweep(me, nSectionIdx, nSubSectionIdx, nFubenLevel);
	--if tbAllAward then
	--	me.CallClientScript("PersonalFuben:OnSweepOver", tbAllAward)
	--end
end

function c2s:ApplyChangeMode(nMode)
	if nMode == Player.MODE_CAMP and Kin.Def.bForbidCamp then
		me.CenterMsg("禁止操作");
		return;
	end

	Player:ChangePKMode(me, nMode);
end

function c2s:OnKinRequest(...)
	Kin:ClientRequest(...);
end

function c2s:OnActionRequest( ... )
	Kin:AuctionRequest(...);
end

function c2s:OnKinGatherRequest( ... )
	Kin:GatherClientRequest(...);
end

function c2s:OnCardPickerRequest(...)
	CardPicker:ClientRequest(...);
end

function c2s:OnBossRequest(...)
	Boss:ClientRequest(...);
end

function c2s:OnMapRequest(...)
	Map:ClientRequest(...);
end

function c2s:OnShopRequest(...)
	Shop:ClientRequest(me, ...);
end

function c2s:ActiveTitle(nTitleID)
	if me.bTitileLock  then
		me.CenterMsg("現在禁止修改稱號")
		return
	end
	nTitleID = tonumber(nTitleID);
	if not nTitleID then
		return;
	end

    me.ActiveTitle(nTitleID, true);
end

function c2s:OnRefinement(nTarId, nSrcId, nTarPos, nSrcPos)
	local bRet, szMsg = Item.tbRefinement:Refinement(me, nTarId, nSrcId, nTarPos, nSrcPos);
	me.CallClientScript("Item.tbRefinement:OnRefinementResult", bRet, szMsg);
end

function c2s:ResetSkillPoint()
    FightSkill:DoResetSkillPoint(me);
end

function c2s:OnSkillLevelUp(nSkillId)
	if type(nSkillId) ~= "number" then
		Log("Error OnSkillLevelUp", me.dwID);
		return;
	end

	FightSkill:SkillLevelUp(me, nSkillId);
end

function c2s:ChangeActionMode(nActionMode)
	if nActionMode ~= Npc.NpcActionModeType.act_mode_none and
	   nActionMode ~= Npc.NpcActionModeType.act_mode_ride then
	   Log("Error c2s:ChangeActionMode", me.dwID, nActionMode);
	   return;
	end

	ActionMode:DoChangeActionMode(me, nActionMode);
end

function c2s:CreateTeamFuben(nSectionIdx, nSubSectionIdx)
	TeamFuben:CreateFuben(me.dwID, nSectionIdx, nSubSectionIdx);
end

function c2s:DoFubenClickMakeFriend(nOtherPlayerId)
	local tbFubenInstance = Fuben:GetFubenInstance(me);
	if not tbFubenInstance or not tbFubenInstance.DoFubenClickMakeFriend then
		return;
	end

	tbFubenInstance:DoFubenClickMakeFriend(me, nOtherPlayerId);
end

function c2s:ConfirmFubenMission()
	local tbFubenInstance = Fuben:GetFubenInstance(me);
	if not tbFubenInstance or not tbFubenInstance.ConfirmFubenMission then
		return;
	end

	tbFubenInstance:ConfirmFubenMission(me);
end

local tbMissionAwardApi = {
	AddAwardIdx = 1,
	GetAwardInfo = 1,
	GetAward = 1,
	GetAwardListList = 1,
	ShowMissionAward = 1,
};
function c2s:CallMissionAwardFunc(szFunc, ...)
	if tbMissionAwardApi[szFunc] then
		MissionAward[szFunc](MissionAward, me, ...);
	else
		Log("[MissionAward] CallMissionAwardFunc ERR ?? unknown function >> ", szFunc, me.szName, me.dwID);
	end
end


--TODO 所有手动申请的地方可以加入申请间隔，或者是点了申请后直接客户端用一个loading 防止双击重复申请
function c2s:RequestAddFriend(dwAlliedPlayerID)
	-- todo 失败一般是数据过期了因为已经客户端检查一遍了
	local bRet, szMsg = FriendShip:RequestAddFriend(me.dwID, dwAlliedPlayerID)
	me.CallClientScript("FriendShip:OnRequestAddFriendRes", bRet, szMsg)

end
RegisterZoneC2S("RequestAddFriend", 1);

function c2s:AcceptFriendRequest(dwAlliedPlayerID)
	local bRet, szMsg = FriendShip:AcceptFriend(me.dwID, dwAlliedPlayerID)
	if not bRet then
		me.CenterMsg(szMsg or "添加好友失敗")
	else
		--删除A 通缉B 或者B 通缉A 的数据
		FriendShip:DelFriendWanted(me.dwID, dwAlliedPlayerID);

		local tbRoleStayInfo = KPlayer.GetRoleStayInfo(dwAlliedPlayerID)

		me.CenterMsg(string.format("你成功將「%s」添加為好友！", tbRoleStayInfo.szName))
		me.OnEvent("AddFriend", dwAlliedPlayerID);

		local pAlliedPlayer = KPlayer.GetPlayerObjById(dwAlliedPlayerID)
		if pAlliedPlayer then
			pAlliedPlayer.Msg(string.format("你成功將「%s」添加為好友！", me.szName))
			pAlliedPlayer.OnEvent("AddFriend", me.dwID);
		end
	end
end

function c2s:RequesDelFriend(dwAlliedPlayerID)
	local bRet, szMsg = FriendShip:DelFriend(me.dwID, dwAlliedPlayerID)
	if not bRet then
		me.CenterMsg(szMsg or "刪除好友失敗")
	else
		me.CenterMsg("刪除好友成功")
		Achievement:AddCount(me, "DeleteFriend_1", 1)
	end
end

--客户端去判断是好友还是没关系，决定调
function c2s:RequestBlackHim(dwAlliedPlayerID)
	local bRet, szMsg = FriendShip:BlackHim(me.dwID, dwAlliedPlayerID)
	if not bRet then
		me.CenterMsg(szMsg or "加入黑名單失敗")
	else
		me.CenterMsg("您已將其拉入黑名單")
	end
end


function c2s:SearchRole(NameOrId, bAddAFriend)
	--todo 设置间隔吧 ,放客户端ui哪里 ，客户端检查字符格式
	if NameOrId == me.szName or NameOrId == me.dwID then
		me.CenterMsg("不允許搜尋自己")
		return
	end

	local tbRoleStayInfo = KPlayer.GetRoleStayInfo(NameOrId)
	if tbRoleStayInfo then
		if bAddAFriend then
			self:RequestAddFriend(tbRoleStayInfo.dwID)
		end

	else
		me.CenterMsg("您搜尋的玩家不存在");
	end

end

function c2s:RefuseAllRequet()
	local bRet, szMsg = FriendShip:RefuseAllRequet(me.dwID)
	if not bRet then
		me.CenterMsg(szMsg or "一鍵清空失敗")
	else
		me.CallClientScript("FriendShip:OnClearAllRequet")
	end
end

function c2s:RefuseAddFriend(dwRoleId)
	FriendShip:RefuseAddFriend(me.dwID, dwRoleId)
end

function c2s:RequestSynAllFriendData(nClientFriendNum)
	FriendShip:RequestSynAllFriendData(me, nClientFriendNum)
end

function c2s:FocusSelfAllPet()
 	Player:FocusSelfAllPet(me);
end

function c2s:RequesDelEnemy(dwAlliedPlayerID)
	local bRet, szMsg = FriendShip:DelEnemy(me.dwID, dwAlliedPlayerID)
	if not bRet then
		me.CenterMsg(szMsg or "刪除仇人失敗")
	else
		me.CenterMsg("成功刪除仇人")
	end
end

function c2s:RequesDoRevenge(dwAlliedPlayerID)
	local bRet, szMsg = FriendShip:DoRevenge(me, dwAlliedPlayerID)
	if szMsg then
		me.CenterMsg(szMsg)
	end
end

function c2s:DoSkillBook(szType, ...)
	local tbBook = Item:GetClass("SkillBook");
    local FunCall = tbBook.tbC2SCallFun[szType];
    if not FunCall then
    	return;
    end

    FunCall(me, ...);
end

function c2s:DoRequesHSLJ(szType, ...)
	local FunCall = HuaShanLunJian.tbC2SRequest[szType];
    if not FunCall then
    	return;
    end

    FunCall(me, ...);
end

function c2s:DoRequesWLDH(szType, ... )
    local FunCall = WuLinDaHui.tbC2SRequest[szType];
    if not FunCall then
        return;
    end

    FunCall(me, ...);
end

function c2s:SendChatBQ(nChatID)
	if type(nChatID) ~= "number" then
		return;
	end

	ChatMgr:PlayerChatActionBQ(me, nChatID);
end

function c2s:DoChangeFaction(nFaction)
	if type(nFaction) ~= "number" then
		return;
	end

	if not Faction.tbFactionInfo[nFaction] then
		me.CenterMsg("沒有當前的門派!!", true);
        return;
    end

	ChangeFaction:PlayerChangeFaction(me, nFaction);
end

function c2s:RequestClearRevengeTime()
	local nCdTime = FriendShip:GetRevengeCDTiem()
	local nRevengeGold = FriendShip:GetRevengeCDMoney(nCdTime)
	if nRevengeGold == 0 then
		return
	end

	me.CostGold(nRevengeGold, Env.LogWay_ClearRevengeCD, nil, function (nPlayerId, bSuccess)
		if not bSuccess then
			return false;
		end

		local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
		if not pPlayer then
			return false;
		end

		FriendShip:SetNextRevengeTime(0, pPlayer)
		pPlayer.CallClientScript("FriendShip:OnClearRevengeTime")
		return true
	end)


end

function c2s:RequestWantedData()
	FriendShip:GetWantedData(me)
end

--发通缉
function c2s:RequestWanted(dwWantedId, nWantedTime)
	if nWantedTime ~= FriendShip.nWantedTimeLong and nWantedTime ~= FriendShip.nWantedTimeShort then
		me.CenterMsg("非法的通緝操作")
		return
	end

	--发布通缉 里做了好友，家族检查
	FriendShip:AddWanted(me, dwWantedId, nWantedTime)
end

--抓捕指定者
function c2s:RequestCatchHim(dwWantedId, dwSenderId)
	local bRet, szMsg = FriendShip:CatchWanted(me, dwWantedId, dwSenderId)
	if not bRet then
		me.CenterMsg(szMsg or "非法抓捕操作")
		return
	end
end

--购买次数
function c2s:BuyCount(szDegreeName, nDegree)
	DegreeCtrl:BuyCount(me, szDegreeName, nDegree)
end

local tbPartnerApi = {
	SetPartnerPos = 1,
	ChangePartnerFightID = 1,
	DecomposePartner = 1,
	DoUseExpItem = 1,
	UseSkillBook = 1,
	UseProtentialItem = 1,
	BatchUseProtentialItem = 1,
	--SkillLevelup = 1,
	ReInitPartner = 1,
	ReInitPartnerConfirm = 1,
	CheckReinitResult = 1,
	GradeLevelup = 1,
	CallPartner = 1,
	DoAwareness = 1,
	UseWeapon = 1,
};
function c2s:CallPartnerFunc(szCmd, ...)
	if not tbPartnerApi[szCmd] then
		Log("[Partner] c2s:CallPartnerFunc ERR ?? not tbPartnerApi[szCmd] !!", me.szName, szCmd, ...);
		return;
	end

	local pNpc = me.GetNpc();
    if pNpc.nShapeShiftNpcTID > 0 then
    	me.CenterMsg("變身狀態時不能操作", true);
        return;
    end

	Partner[szCmd](Partner, me, ...);
	FightPower:ChangeFightPower("Partner", me);
end

function c2s:OnStrengthen(...)
	Strengthen:OnStrengthen(me, ...);
end

function c2s:OnInset(...)
	StoneMgr:OnInset(me, ...);
end

function c2s:RemoveInset( ... )
	if 1 then
		return
	end
	local bRet, szMsg = StoneMgr:RemoveInset(me, ...);
	if szMsg then
		pPlayer.CenterMsg(szMsg)
	end

end

function c2s:OnCombine(...)
	StoneMgr:OnCombine(me, ...);
end

function c2s:DoQuickCombineStone(nStoneTemplateId)
	StoneMgr:DoQuickCombineStone(me, nStoneTemplateId);
end

function c2s:OnQuicklyInset(...)
	StoneMgr:OnQuicklyInset(me, ...);
end

function c2s:OnQuicklyCombine(...)
	local bRet, szMsg = StoneMgr:OnQuicklyCombine(me, ...);
	if szMsg then
		me.CenterMsg(szMsg)
	end
end

function c2s:DoEquipEvolution( ... )
	Item.GoldEquip:Evolution(me, ...)
end

function c2s:DoUpgradeEquipTrainLevel( ... )
	Item.GoldEquip:UpgradeEquipTrainLevel(me, ...)
end

function c2s:RequestEquipUpgrade(...)
	Item.GoldEquip:ServerDoEquipUpgrade(me, ...)
end

function c2s:RankEnemyRequest(nVersion)
	RankBattle:CheckLastBattle(me);
	RankBattle:SyncRankEnemy(me, nVersion)
end

function c2s:RefreshEnemy()
	RankBattle:RefreshEnemy(me)
end

function c2s:StartRankBattle(nFightType, nRankNo, nId)
	RankBattle:StartBattle(me, nFightType, nRankNo, nId)
end

function c2s:FetchRankBattleAward()
	RankBattle:FetchRankBattleAward(me);
end

function c2s:EndAsyncBattle()
	AsyncBattle:RequireEndBattle(me)
end

function c2s:BattleArrayRequest()
	AsyncBattle:OnSyncBattleArray(me)
end

function c2s:ChangeArrayRequest(tbBattleArray)
	local pAsync = KPlayer.GetAsyncData(me.dwID)
	AsyncBattle:OnChangeBattleArray(pAsync, tbBattleArray)
end

function c2s:AsyncBattleResult(nBattleKey, nResult, tbParams)
	AsyncBattle:OnAsyncResult(me, nResult, tbParams)
end

function c2s:LeaveAsyncBattle()
	AsyncBattle:RequireLeaveBattle(me)
end

function c2s:AsyncBattleReady(nMapId)
	AsyncBattle:AsyncBattleReady(me, nMapId)
end

function c2s:DebrisGetRobList(nItemId, nIndex)
	Debris:GetRobList(me, nItemId, nIndex)
end

function c2s:DebrisRobHim(dwRobId, nItemId, nIndex, nCount)
	Debris:RobHim(me, dwRobId, nItemId, nIndex, nCount)
end

function c2s:DebrisFlipCard()
	Debris:GetCardAward(me)
end

function c2s:BuyDebrisAvoidRobTime(nIndex)
	Debris:BuyDebrisAvoidRobTime(me, nIndex)
end

function c2s:BattleSignUp()
	Battle:SignUp(me)
end

function c2s:LeaveAloneBattle()
	Battle:LeaveAloneBattle(me)
end

function c2s:ReEnterZoneBattle()
	Battle:ReEnterZoneBattle(me)
end

function c2s:BattleClientRequest( szType, ... )
	local FunCall = Battle.tbC2SRequest[szType]
	if not FunCall then
		return
	end
	FunCall(me, ...)
end


function c2s:OnCommerceTaskRequset(...)
	CommerceTask:OnResquest(me, ...);
end

function c2s:ConfirmPartnerPos()
    local pNpc = me.GetNpc();
    if pNpc.nShapeShiftNpcTID > 0 then
        return;
    end

	me.ConfirmPartnerPos();
end

function c2s:GetStranger(nNeedCount)
	local tbStranger = KPlayer.GetStranger(me.dwID, nNeedCount);
	me.CallClientScript("Helper:OnGetStrangerList", tbStranger);
end

function c2s:GetHelperSyncData(nPlayerId)
	local bRet = me.SyncOtherPlayerAsyncData(nPlayerId, 11);
	if not bRet then
		me.CenterMsg("同步資料失敗！");
		Log("[Helper] ERR ?? GetHelperSyncData bRet is false !", me.szName, me.dwID, nPlayerId);
		return;
	end

	me.CallClientScript("Helper:OnGetSyncData", nPlayerId);
end

function c2s:DungeonFubenInvite(dwRoleId, bNotNotify)
	Fuben.DungeonFubenMgr:InvitePlayer(me, dwRoleId)
end

function c2s:DungeonFubenInviteApply(dwRoleId)
	Fuben.DungeonFubenMgr:InviteApply(me, dwRoleId)
end

function c2s:DungeonFubeRandomInvite()
	Fuben.DungeonFubenMgr:RandomInvite(me)
end

function c2s:TryGainAchievementAward(szKind, nGainLevel)
	Achievement:TryGainAward(me, szKind, nGainLevel);
end

function c2s:RequestMapExplore(nMapTemplateId)
	local bRet, szMsg = MapExplore:RequestExplore(me, nMapTemplateId)
	if szMsg then
		me.CenterMsg(szMsg)
	end
end

function c2s:ReEnterExplore()
	MapExplore:ReEnterExplore(me)
end

function c2s:MapExploreMove(nMapTemplateId, nStep)
	MapExplore:MoveStep(me, nMapTemplateId, nStep)
end

function c2s:MapExploreWalkEnd(nMapTemplateId)
	MapExplore:WalkEnd(me, nMapTemplateId)
end

function c2s:MapExploreWalkLeave()
	MapExplore:Leave(me)
end

function c2s:MapExploreAttackEnemy()
	MapExplore:AttackEnemy(me)
end

function c2s:BossLeaderEnterFuben(szType, nMapTID)
    BossLeader:ApplyEnterFuben(me, szType, nMapTID);
end

function c2s:ApplyDaXueZhang()
	local tbDaXueZhang = Activity.tbDaXueZhang;
    tbDaXueZhang:PlayerEnterDaXueZhang(me);
end

function c2s:RequestUpdateMapExplore()
	MapExplore:RequestUpdateMapExplore(me)
end

function c2s:MapExploreReset(nMapTemplateId)
	MapExplore:RequestReset(me, nMapTemplateId)
end

local tbViewPlayerWndKey = {
	["ViewRolePanel"] = 26; --
	["ViewFight"] = 10; --装备,门派
	["ChuangGongPanel"] = 10;
}

function c2s:ViewPlayerInfo(dwRoleId, szWnd)
	local nKey = tbViewPlayerWndKey[szWnd]
	if not nKey then
		Log("Error!! ViewPlayerInfo", dwRoleId, szWnd)
		return
	end
	local bRet = me.SyncOtherPlayerAsyncData(dwRoleId, nKey);
	if not bRet then
		me.CenterMsg("同步資料失敗！");
		Log("[Helper] ERR ?? ViewPlayerInfo bRet is false !", me.szName, me.dwID, dwRoleId);
		return;
	end
	local tbRole = Player:GetRoleStayInfo(dwRoleId, true)
	me.CallClientScript("ViewRole:OnGetSyncData", tbRole);
end

function c2s:MoneyTreeShake(bMultiShake, nShakeIdx, bLaunchExtra)
	MoneyTree:TryShaking(me, bMultiShake, nShakeIdx, bLaunchExtra)
end

function c2s:QuickBuy(szBuyType, tbParams)
	QuickBuy:DoQuickBuy(me, szBuyType, tbParams);
end

function c2s:NotifyQuickBuy(szBuyType, tbParams)
	QuickBuy:NotifyQuickBuy(me, szBuyType, tbParams);
end

RegisterZoneC2S("RequestMailData", 1);
RegisterZoneC2S("RecordReadMails", 1);
RegisterZoneC2S("TakeMailAttach", 1);

function c2s:RequestMailData(nSelfLoadIndex, nGlobleLoadIndex)
	Mail:RequestMailData(me, nSelfLoadIndex, nGlobleLoadIndex);
end

function c2s:RecordReadMails(nMaildId, bAutoDelete)
	Mail:RecordReadMails(me, nMaildId, bAutoDelete);
end

function c2s:TakeMailAttach(nMailId)
	Mail:TakeMailAttach(me, nMailId);
end

function c2s:TryGetDayTargetAward(nOrder)
	EverydayTarget:TryGainAward(me, nOrder);
end

function c2s:FinishGuide(nGuideId)
	-- LogD(Env.LOGD_Guide, me.szAccount, me.dwID, "SkipGuide");
	me.TLog("GuideFlow", me.nLevel, nGuideId, 0);
	Guide:OnFinishGuide(me, nGuideId)
end

function c2s:GuideStep(nGuideId, nStep)
	-- LogD(Env.LOGD_Guide, me.szAccount, me.dwID, nGuideId.."_"..nStep);
	me.TLog("GuideFlow", me.nLevel, nGuideId, nStep);
end

function c2s:FinishNotifyGuide(szGuide)
	Guide:FinishNotifyGuide(me, szGuide)
end

function c2s:__FinishAllGuide()
	Guide:FinishAllGuide(me)
end

function c2s:GetLoginAwards(nDayIndex)
	LoginAwards:OnGetAwards(nDayIndex);
end

function c2s:OnPrayRequest(...)
	Pray:ClientRequest(me, ...);
end

function c2s:RequestRecharge(szProductId)
	if not Recharge.IS_OPEN then
		me.CenterMsg("本次測試期間，不開放儲值")
		return
	end
	Recharge:RequestRecharge(me, szProductId)
end

function c2s:BuyVipAward(nLevel)
	Recharge:BuyVipAward(me, nLevel)
end

function c2s:TakeMonthCardAward()
	Recharge:TakeMonthCardAward(me)
end

function c2s:TakeWeekMonthCardAward()
	Recharge:TakeWeekMonthCardAward(me)
end

function c2s:TakeGrowInvestAward(nIndex, nGroupIndex)
	Recharge:TakeGrowInvestAward(me, nIndex, nGroupIndex)
end

function c2s:RechargeRequestlock(szTradeNo)
	Recharge:RechargeRequestlock(me.dwID, szTradeNo)
end

function c2s:TakeOneDayCardPlusAward()
	Recharge:TakeOneDayCardPlusAward(me)
end

function c2s:PlayerSignUpQunYingHui()
    QunYingHui:PlayerSignUpGame(me);
end

function c2s:RequestDataBossLeader(szType)
	local bRet = BossLeader:HaveCrossBossServer(me);
	if not bRet or not BossLeader.tbCrossBossDataInfo.bOpenCross then
		local tbSyncData = BossLeader:ClientRequestData(szType);
		if tbSyncData then
			me.CallClientScript("BossLeader:OnSyncMapData", szType, tbSyncData);
		end
	elseif szType == "Boss" then
		local tbCrossInfo = BossLeader.tbCrossBossDataInfo;
		if tbCrossInfo.tbEndSyncData and tbCrossInfo.nTime and Lib:GetLocalDay() == Lib:GetLocalDay(tbCrossInfo.nTime) then
			BossLeader:PlayerCrossClientRequestData(me.dwID, szType, tbCrossInfo.tbEndSyncData);
		else
			CallZoneServerScript("BossLeader:CrossClientRequestData", szType, me.dwID);
		end
	end
end

function c2s:RequestHaveCrossServer()
	me.CallClientScript("Player:ServerSyncData", "BossCrossServer", BossLeader:HaveCrossBossServer(me));
end

function c2s:PlayerLeaveMap(szMsg)
	local nMapId = me.nMapId;
	local szMsg = szMsg or "確定要離開活動？"
	if me.szCanLeaveMapMsg then
		szMsg = me.szCanLeaveMapMsg;
	end

	me.MsgBox(szMsg, {{"確定", function (nMapId)
		if me.nMapId ~= nMapId then
			return;
		end

		if (me.nCanLeaveMapId and me.nCanLeaveMapId == me.nMapId) or Map:CheckCanLeave(me.nMapTemplateId) then
			if MODULE_ZONESERVER then
				me.ZoneLogout();
			else
				me.GotoEntryPoint()
			end
		end
	end, nMapId}, {"取消"}})
end

function c2s:FinishHonorLevel()
    local tbHonorLevel = Player.tbHonorLevel;
    tbHonorLevel:FinishHonorLevel(me);
end

function c2s:DoHeroChallenge()
    HeroChallenge:DoChallengeMaster(me);
end

function c2s:DoHeroChallengeAward(nFloor)
	if type(nFloor) ~= "number" then
		return;
	end

    HeroChallenge:DoChallengeAward(me, nFloor);
end

function c2s:RequestHeroChallengeInfo()
    HeroChallenge:UpdatePlayerData(me);
end

function c2s:OpenXiuLianTime()
    XiuLian:OpenXiuLianTime(me);
end

function c2s:RequestResetHeroChallenge()
    HeroChallenge:NeedResetHeroChallenge(me);
end

function c2s:FinishHonorRepairItem()
    --local tbHonorLevel = Player.tbHonorLevel;
    --tbHonorLevel:RepairItem(me);
end

function c2s:RequestBossLeaderBossDmgRank()
	BossLeader:ClientRequestKinDmgRank(me, "Boss");
end

function c2s:StartMapAutoRunSpeed(nDstX, nDstY, nPathLen)
	if type(nDstX) ~= "number" or type(nDstY) ~= "number" or type(nPathLen) ~= "number" then
		return;
	end

	AutoRunSpeed:MapStartRunSpeed(me, nDstX, nDstY, nPathLen)
end

function c2s:StopMapAutoRunSpeed()
	AutoRunSpeed:StopRunSpeed(me);
end

function c2s:GetSignInAwards(nDayIdx, nLaunchPlatform)
	SignInAwards:OnGetAwards(nDayIdx, nLaunchPlatform);
end

function c2s:RequestGetChuangGong(dwRoleId)
	local bOk = TeacherStudent:ReqChuanGong(dwRoleId)
	if not bOk then
		ChuangGong:RequestGetChuangGong(me, dwRoleId)
	end
end

function c2s:RequestSendChuangGong(dwRoleId)
	local bOk = TeacherStudent:ReqChuanGong(dwRoleId)
	if not bOk then
		ChuangGong:RequestSendChuangGong(me, dwRoleId)
	end
end

function c2s:ChangePortrait(nPortrait)
	PlayerPortrait:ChangePortrait(me, nPortrait);
end

function c2s:RequestChangeName(szNewName)
	ChangeName:RequestChangeName(me, szNewName)
end

function c2s:UpdateEveryTarget(nVersion)
	EverydayTarget:RequestUpdate(me, nVersion);
end

function c2s:OpenRankBoard(szKey, nPage, bRequestMy)
	RankBoard:OpenRankBoard(me, szKey, nPage, bRequestMy)
end

function c2s:AnswerQuestion(szType, nQuestionId, nAnswerId, ...)
	DaTi:TryAnswer(me, szType, nQuestionId, nAnswerId, ...)
end

function c2s:TryAcceptActQuesTask()
	ActivityQuestion:TryAcceptTask()
end

function c2s:TryAnswerTaskQuestion(nQuestionId, nAnswerId)
	ActivityQuestion.tbTaskQuestion:TryAnswer(nQuestionId, nAnswerId)
end

function c2s:TryComposeItem(nItemID)
	Compose:TryComposeItem(nItemID);
end

function c2s:UpdateAchievementKindData(szSubKind, nCount)
	Achievement:OnUpdateCount(me, szSubKind, nCount);
end

function c2s:RequestCheckAchievementFinish(tbCheckAchi)
	Achievement:OnRequestCheckAchievementFinish(me, tbCheckAchi)
end

function c2s:TakeCodeAward(szCode)
	CodeAward:TakeCodeAward(me, szCode)
end

function c2s:TryUpdateDailyTargetData()
	EverydayTarget:OnTryUpdateData(me)
end

function c2s:GetMyJuBaoPenMoney()
	local nMoney = JuBaoPen:GetJuBaoPengVal(me.dwID)
	if nMoney > 0 then
		me.CallClientScript("JuBaoPen:UpdateMoney", nMoney)
	end
end

function c2s:TakeJuBaoPenMoney()
	JuBaoPen:TakeMoney(me)
end

c2s.tbPlayerCallCache = {};
function c2s:CallServerSafe(nCallId, szFunc, ...)
	c2s.tbPlayerCallCache[me.dwID] = c2s.tbPlayerCallCache[me.dwID] or {}
	local tbCalledId = c2s.tbPlayerCallCache[me.dwID];
	local nCount = #tbCalledId
	for i = nCount, 1, -1 do
		if tbCalledId[i] == nCallId then
			Log("CallServerSafe", "Recall function", me.szName, nCallId, szFunc)
			me.CallClientScript("Player:OnSafeCallRespond", nCallId)
			return;
		end
	end
	if nCount > 10 then		-- 只留最近执行的10条
		table.remove(tbCalledId, 1);
	end
	table.insert(tbCalledId, nCallId);
	if c2s[szFunc] then
		Lib:CallBack({c2s[szFunc], c2s, ...})
	else
		Log("CallServerSafe", "do not exist function", szFunc);
	end

	me.CallClientScript("Player:OnSafeCallRespond", nCallId)
end

function c2s:ResetCallSafe()
	c2s.tbPlayerCallCache[me.dwID] = {};
end


c2s.tbKinBattleApi = {
	["TryJoinPreMap"] = true;
	["GetCurrentData"] = true;
	["SetLevelLimite"] = true;
};

function c2s:KinBattleCall(szFunc, ...)
	if not self.tbKinBattleApi[szFunc] then
		return;
	end
	KinBattle[szFunc](KinBattle, me, ...);
end

function c2s:TryCheckImityAchievement(nImityCheckAcheLevel, tbCheckRoleIDs )
	FriendShip:TryCheckImityAchievement(me, nImityCheckAcheLevel, tbCheckRoleIDs)
end

function c2s:TeamBattleTryJoinPreMap(bIsSignle)
	TeamBattle:TryJoinPreMap(me, bIsSignle);
end

function c2s:UseTaskItem(nTaskId)
	Task:UseTaskItem(me, nTaskId);
end

function c2s:CallWhiteTigerFunc(szFunc, ...)
	Fuben.WhiteTigerFuben:OnClientCall(szFunc, me, ...)
end

function c2s:FactionBattleTryJoin()
	FactionBattle:TrapIn(me)
end

function c2s:RequestSyncNpc(nNpcTemplateId)
	if not nNpcTemplateId or nNpcTemplateId <= 0 then
		return;
	end

	local tbNpc = KNpc.GetAroundNpcList(me.GetNpc(), Npc.DIALOG_DISTANCE);
	for _, pNpc in pairs(tbNpc) do
		if pNpc.nTemplateId == nNpcTemplateId then
			me.SyncNpc(pNpc.nId);
		end
	end
end

function c2s:RequestChatRoleBaseInfo(tbRoleIDs)
	local tbResust = {}
	for i, dwRoleId in ipairs(tbRoleIDs) do
		local tbRole = KPlayer.GetRoleStayInfo(dwRoleId)
		if 	tbRole then
			table.insert(tbResust, tbRole)
		end
	end

	if next(tbResust) then
		me.CallClientScript("ChatMgr:OnSynChatRoleBaseInfo", tbResust)
	end
end

c2s.tbMarketStallFunc = {
	["NewSellItem"] = true;
	["UpdateMyItemPrice"] = true;
	["CancelSellItem"] = true;
	["GetMySellItemInfo"] = true;
	["GetCacheMoney"] = true;
	["GetAllItems"] = true;
	["UpdateAllStall"] = true;
	["BuyItem"] = true;
	["GetAvaragePrice"] = true;
};
function c2s:CallMarketStallFunc(szFunc, ...)
	if not self.tbMarketStallFunc[szFunc] then
		return;
	end

	if not MarketStall:CheckOpen() then
		me.CenterMsg("擺攤正在維護中！");
		return;
	end

	local bRet, szMsg = MarketStall:IsMarketOpen(me)
	if not bRet then
		me.CenterMsg(szMsg or "未知錯誤")
		return;
	end

	MarketStall[szFunc](MarketStall, me, ...);
end

function c2s:TryJoinKinTrain()
	Fuben.KinTrainMgr:TryEnterMap(me)
end

function c2s:KinTrainTryDepart()
    local tbFubenInst = Fuben:GetFubenInstance(me)
    if tbFubenInst and tbFubenInst.TryDepart then
        tbFubenInst:TryDepart(me)
    end
end

--家族试炼，取消物资情况实时更新
function c2s:CancelMatUpdate()
	local tbFubenInst = Fuben:GetFubenInstance(me)
    if tbFubenInst and tbFubenInst.OnCancelMatUpdate then
        tbFubenInst:OnCancelMatUpdate(me)
    end
end

function c2s:ComposeEntityItem(nTemplateId)
    Compose.EntityCompose:ComposeEntityItem(me,nTemplateId)
end

function c2s:ComposeValueItem(nSeqId)
	Compose.ValueCompose:TryComposeValue(me,nSeqId)
end

function c2s:DoReconnect()
	me.CallClientScript("Ui:CloseWindow", "LoadingTips");
end

function c2s:SurveyFinish(bUrl, nGroupId, tbAnswer)
	Survey:Finish(me, bUrl, nGroupId, tbAnswer)
end

function c2s:UpdateBalanceInfo()
	AssistClient:UpdateBalanceInfo(me);
end

function c2s:UpdateMsdkInfo(...)
	AssistClient:UpdateMsdkInfo(me, ...);
end

function c2s:PkExcerciseRequest(nPlayerId)
	Player:RequestExcercise(me, nPlayerId)
end

function c2s:PkExcerciseRespond(nRequestId, bResult)
	Player:OnExcerciseRespond(me, nRequestId, bResult)
end

function c2s:GetOnHookExp(nGetType)
	if not OnHook:CheckType(nGetType) then
		return;
	end
	OnHook:GetOnHookExp(me,nGetType);
end

local tbValidKinRedBagReq = {
	RedBagUpdateReq = true,
	RedBagSendReq = true,
	RedBagGrabReq = true,
}
function c2s:DoKinRedBagReq(szFunc, ...)
	if not tbValidKinRedBagReq[szFunc] then
		return
	end
	Kin[szFunc](Kin, me, ...)
end

function c2s:SendGift(nGiftType,nAcceptId,nCount,nItemId)
	if not nGiftType or not Gift.AllGift[nGiftType] or not nAcceptId or not nCount or nCount < 1 then
		Log("[c2s] SendGift illegal data",nGiftType,nAcceptId,nCount,nItemId)
		return ;
	end
	local fnSend = Gift.fnSend[nGiftType]
	if fnSend then
		fnSend(me,nAcceptId,nCount,nItemId);
	else
		me.CenterMsg("你要送什麼??");
		Log("[c2s] SendGift illegal type",nGiftType,nAcceptId,nCount,nItemId)
	end
end

function c2s:SynGiftData()
	Gift.GiftManager:SynGiftData(me)
end

function c2s:UseChooseItem(nId, tbChoose)
	Item:UseChooseItem(nId, tbChoose)
end

function c2s:SdkRequest(...)
	Sdk:ClientRequest(...);
end

function c2s:TryEntrySeriesFuben()
	SeriesFuben:TryEntry()
end

function c2s:TryGetSupplementAward(szKey, nNum, bCoin)
	SupplementAward:TryGetAward(szKey, nNum, bCoin)
end

function c2s:TryUpdateNewInformation(szKey, nSession)
	NewInformation:OnTryUpdateData(szKey, nSession)
end

function c2s:OnNewInfomationButton(szType)
	NewInformation:OnButtonEvent(szType);
end

function c2s:TLogClickWeiGuanWang()
	me.TLog("ClickWeiGuanWang", me.nLevel)
end

function c2s:TLogClickPraise()
	me.TLog("ClickPraise", me.nLevel)
end

function c2s:SynFactionMonkeyData()
	if not FactionBattle.FactionMonkey:IsMonkeyStarting() then
		return
	end
	FactionBattle.FactionMonkey:CheckResetVote(me)
	FactionBattle.FactionMonkey:OnSynData(me)
end

function c2s:VoteMonkey(dwMonkeyID)
	if not dwMonkeyID then
		return
	end
	FactionBattle.FactionMonkey:VoteMonkey(me,dwMonkeyID)
end

function c2s:DomainBattleUseSupplys(nTemplateId, nVersion)
	DomainBattle:UseSupplys(me, nTemplateId, nVersion)
end

function c2s:DomainBattleSynFightData(nBattleReportVersion)
	DomainBattle:GetBattleReportInfo(me, nBattleReportVersion)
end

function c2s:DomainBattleRequestBaseInfo(nVersion)
	DomainBattle:RequestBaseInfo(me, nVersion)
end

function c2s:DomainBattleDeclareWar(nMapTemplateId)
	DomainBattle:KinSignUp(me, nMapTemplateId)
end

function c2s:DomainBattleRequestMapInfo()
	DomainBattle:RequestMapInfo(me)
end

function c2s:DomainBattlePlayerSignUp()
	DomainBattle:PlayerSignUp(me)
end

function c2s:DomainBattleLeave()
	DomainBattle:RequestLeave(me)
end

function c2s:DomainBattleRequestMainMapInfo()
	DomainBattle:RequestMainMapInfo(me)
end

function c2s:DomainBattleSelectCamp(nIndex)
	DomainBattle:SelectCamp(me, nIndex)
end

function c2s:RequestMapStatueInfo(nMapId)
	Map:RequestMiniStatueData(me, nMapId)
end

function c2s:RequestRemoveSkillState(nSkillId)
	me.RemoveSkillState(nSkillId);
end

function c2s:SynLevelRankData()
	RankActivity.LevelRankActivity:SynData(me)
end

function c2s:EquipExchange(nItemId)
	Item.tbEquipExchange:DoExchange(me, nItemId)
end

function c2s:DoChangeEquipColor(nItemId, nTargetId)
	Item.tbChangeColor:DoChangeColor(me, nItemId, nTargetId)
end

function c2s:ChangeOnLineOnHook()
	if OnHook:IsOnLineOnHook(me) then
		OnHook:EndOnLineOnHook(me,OnHook.tbCalcLogType.LogType_Online_Hand)
	else
		OnHook:StartOnLineOnHook(me)
	end
end

function c2s:ConfirmExchange(tbItems)
	Exchange:ConfirmExchange(me, tbItems)
end

function c2s:TryGainNewPackageGift(nVersion)
	NewPackageGift:TryGainGift(nVersion)
end

function c2s:ReqTeacherStudent(szFunc, ...)
	TeacherStudent:OnRequest(szFunc, ...)
end

function c2s:ReqSwornFriends(szFunc, ...)
	SwornFriends:OnRequest(szFunc, ...)
end

function c2s:SynArenaData()
	ArenaBattle:SynArenaManData(me)
end

function c2s:ApplyChallenge(nArenaId)
	if not nArenaId then
		return
	end
	ArenaBattle:ApplyChallenge(me,nArenaId)
end

function c2s:SynChallengerData()
	ArenaBattle:SynChallengerData(me)
end

function c2s:ArenaChallenge(tbData)
	if not tbData then
		return
	end
	ArenaBattle:PickChallenger(me,tbData)
end

function c2s:LeaveArenaBattle()
	ArenaBattle:Leave(me)
end

function c2s:RefreshArenaState()
	ArenaBattle:RefreshArenaState(me)
end
function c2s:SynMyApplyData()
	ArenaBattle:SynMyApplyData(me)
end

function c2s:ImperialTombEnter()
	ImperialTomb:EnterTomb()
end

function c2s:ImperialTombFemaleEmperorEnter(nIndex)
	ImperialTomb:EnterFemaleEmperorTomb(nIndex)
end

function c2s:ImperialTombSecretEnter(nType)
	ImperialTomb:SecretEnterRequest(me, nType)
end

function c2s:ImperialTombEmperorDmgReq()
	ImperialTomb:SynEmperorDmgInfo(me)
end

function c2s:ImperialTombBossDmgReq()
	ImperialTomb:SynBossDmgInfo(me, me.nMapId)
end

function c2s:ImperialTombLeave()
	if me.nFightMode == 1 then
		GeneralProcess:StartProcess(me, 5 * Env.GAME_FPS, "傳送中...", ImperialTomb.LeaveRequest, ImperialTomb, me)
	else
		ImperialTomb:LeaveRequest(me)
	end
end

function c2s:ImperialTombCheckStayTime()
	if ImperialTomb:IsNormalMapByTemplate(me.nMapTemplateId) then
		ImperialTomb:CheckStayTime(me)
	end
end

function c2s:ImperialTombCheckSecretRoomTime()
	if ImperialTomb:IsSecretMapByTemplate(me.nMapTemplateId) then
		ImperialTomb:CheckSecretTime(me)
	end
end

function c2s:ImperialTombBossStatusRequest()
	ImperialTomb:SyncBossStatus(me)
end

function c2s:TrySendQixiGift(nPlayerId, nItemTemplateId)
	Activity:OnPlayerEvent(me, "Act_QixiOnClientCall", "TrySendGift", nPlayerId, nItemTemplateId)
end

function c2s:TryUpdateQixiData()
	Activity:OnPlayerEvent(me, "Act_QixiOnClientCall", "RefreshPlayerData")
end

function c2s:NpcBiWuZhaoQinAct(szCmd, ...)
	Activity:OnPlayerEvent(me, "Act_NpcBiWuZhaoQinClientCall", szCmd, ...);
end

function c2s:OnCallPregressionPrivilege(...)
	RegressionPrivilege:OnClientCall(me, ...)
end

function c2s:RequestSendBless(dwRoleId, bUseGold, szWord)
	SendBless:SendBless(me, dwRoleId, bUseGold, szWord)
end

function c2s:RequestSendBlessData()
	SendBless:SynSendData(me)
end

function c2s:RequetTakeSendBlessAward()
	SendBless:TakeAward(me)
end

function c2s:UseJuanZhouItem(nItemId, tbSelect)
	local pItem = me.GetItemInBag(nItemId);
	if not pItem then
		return;
	end

	Item:GetClass("JuanZhou"):UseItem(pItem, tbSelect);
end

function c2s:InDifferBattleSignUp()
	InDifferBattle:SignUp(me)
end

function c2s:SynWeekendQuestionData()
	Activity:OnPlayerEvent(me, "Act_SysData")
end

function c2s:TryApplyDecorate(tbData)
	ChatMgr.ChatDecorate:ApplyDecorate(me,tbData)
end

function c2s:CheckChatDecorate()
	ChatMgr.ChatDecorate:TryCheckValid(me)
end

function c2s:TrySelfChuanGong()
	ChuangGong:SelfChuanGong(me.dwID)
end

function c2s:ReportTextVoiceSetting(bOnlyVoiceText)
	Log("ChatVoice", "OnlyVoiceText",  tostring(bOnlyVoiceText), tostring(me.dwID))
end

function c2s:RequestRecordStoneInset(nTemplateId, nInsetPos)
	RecordStone:SetCurRecordStone(me, nTemplateId, nInsetPos)
end

function c2s:TryCallDirectLevelUpFunc(szFunc, ...)
	DirectLevelUp:OnClientCall(me, szFunc, ...)
end

function c2s:DoChatRequest( ... )
	ChatMgr:DoChatRequest( ... );
end

function c2s:BiWuZhaoQinAct(szType, ...)
	Activity:OnPlayerEvent(me, "BiWuZhaoQin", szType, ...)
end

function c2s:TryCallWishActFunc(szFunc, ...)
	Activity:OnPlayerEvent(me, "Act_Wish_OnClientCall", szFunc, ...)
end

function c2s:BiWuZhaoQinUseItem(nItemId, szTitle1, szTitle2)
	local pItem = me.GetItemInBag(nItemId);
	if not pItem then
		return;
	end

	Item:GetClass("LoveToken"):OnUseLoveTokenItem(me, pItem, szTitle1, szTitle2);
end

function c2s:OnCallFriendRecall(...)
	FriendRecall:OnClientCall(me, ...);
end

function c2s:TryCallNewYearLoginActFunc( ... )
	Activity:OnPlayerEvent(me, "Act_TryCallNewYearLoginActFunc", ...)
end

function c2s:TryOpenSelectItemUi(nUiX, nUiY, nTID, nID)
	Item:GetClass("NeedChooseItem"):OpenWindow(nUiX, nUiY, nTID, nID)
end

function c2s:UseChangeTitleItem(nItemId, szTitle)
	Item:GetClass("ChangeTitleItem"):ChangeTitle(me.dwID, nItemId, szTitle);
end

function c2s:QingRenJieRespon(szEvent, ...)
	Activity:OnPlayerEvent(me, szEvent, ...)
end

function c2s:TryLeaveQingRenJieMap()
	if not Env:CheckSystemSwitch(me, Env.SW_SwitchMap) then
		me.CenterMsg("目前狀態不允許切換地圖")
		return
	end

	me.GotoEntryPoint()
end

function c2s:TryUseTitleItem(...)
	if Activity:__IsActInProcessByType("QingRenJie") then
		Activity:OnPlayerEvent(me, "Act_QingRenJie_ChooseTitle", ...)
		return
	end
	local tbItem = Item:GetClass("QingRenJieTitleItem")
	tbItem:OnRequestUse(me, ...)
end

function c2s:TrySendLabel(tbParam)
	if Activity:__IsActInProcessByType("WomanAct") then
		Activity:OnPlayerEvent(me, "Act_TrySendLabel", tbParam)
	else
		me.CenterMsg("活動已結束", true)
	end
end

function c2s:TrySynLabelData(dwID)
	if Activity:__IsActInProcessByType("WomanAct") then
		Activity:OnPlayerEvent(me, "Act_SynData", dwID)
	end
end

function c2s:TrySynLabelPlayer(nTargetId)
	if Activity:__IsActInProcessByType("WomanAct") then
		Activity:OnPlayerEvent(me, "Act_SynLabelPlayer", nTargetId)
	end
end

function c2s:PutFurniture(nX, nY, nRotation, nTemplateId, nSX, nSY)
	Furniture:PutFurnitureByTB(me, {nTemplateId = nTemplateId, nX = nX, nY = nY, nRotation = nRotation, nSX = nSX, nSY = nSY});
end

function c2s:ChangeFurniturePos(nId, nX, nY, nRotation, nSX, nSY)
	Furniture:ChangeFurniturePos(me, nId, nX, nY, nRotation, nSX, nSY);
end

function c2s:PackupFurniture(nId)
	if not House:IsInOwnHouse(me) then
		me.CenterMsg("只能裝扮自己的家園！");
		return;
	end
	Furniture:PackupFurniture(me, nId);
end

function c2s:EnterHome(dwOwnerId)
	if not Env:CheckSystemSwitch(me, Env.SW_SwitchMap) then
		me.CenterMsg("目前狀態不允許切換地圖")
		return
	end

	House:EnterHouse(me, dwOwnerId);
end

function c2s:GoMyHome()
	if not Env:CheckSystemSwitch(me, Env.SW_SwitchMap) then
		me.CenterMsg("目前狀態不允許切換地圖")
		return
	end

	House:GoMyHome(me);
end

function c2s:GoBackFromHome()
	if not Env:CheckSystemSwitch(me, Env.SW_SwitchMap) then
		me.CenterMsg("目前狀態不允許切換地圖")
		return
	end

	if Map:IsHouseMap(me.nMapTemplateId) then
		me.GotoEntryPoint();
	end
end

function c2s:ChangeHouseAccess(nType, bAccess)
	House:SetAccess(me, nType, bAccess);
end

function c2s:ChangeHouseDecorationAccess(nRoomerId, bAccess)
	House:SetDecorationAccess(me.dwID, nRoomerId, bAccess);
end

function c2s:MakeFurniture(nFurnitureItemId)
	Furniture:MakeFurniture(me, nFurnitureItemId);
end

function c2s:TryUseArborTitleItem(...)
	Item:GetClass("ArborDayCureTitleItem"):OnRequestUse(me, ...)
end

function c2s:PeekPlayer(dwRoleId)
	Player:PeekPlayer(me, dwRoleId)
end

function c2s:StopPeek()
	me.StopPeek();
end

function c2s:HouseStartLevelUp()
	House:StartLevelUp(me);
end

function c2s:DecorationChangeActType(nId, nType)
	Decoration:DecorationChangeActType(me, nId, nType);
end

function c2s:DecorationEnterActState(nId, nParam, nType)
	Decoration:EnterPlayerActState(me, nId, nParam, nType);
end

function c2s:DecorationExitActState()
	Decoration:ExitPlayerActState(me.dwID);
end

function c2s:OnStartDecorationState()
	House:OnStartDecorationState(me);
end

function c2s:OnClientCmd(nId, ...)
	Decoration:OnClientCmd(me, nId, ...);
end

function c2s:InviteCheckIn(dwPlayerId)
	House:InviteCheckIn(me, dwPlayerId);
end

function c2s:CheckIn(dwOwnerId)
	House:CheckIn(me, dwOwnerId);
end

function c2s:MakeCheckOut(dwRoomerId)
	House:MakeCheckOut(me, dwRoomerId);
end

function c2s:CheckOut()
	House:RoomerCheckOut(me);
end

function c2s:TryMuse()
	House:TryMuse(me);
end

function c2s:MakeZhenYuan(nLevel)
	Item.tbZhenYuan:MakeEquip(me, nLevel)
end

function c2s:ZhenYuanSkillLevelUp(tbItemIds)
	local bRet, szMsg = Item.tbZhenYuan:ZhenYuanSkillLevelUp(me, tbItemIds)
	if szMsg then
		me.CenterMsg(szMsg)
	end
end

function c2s:ZhenYuanRefineSkill(nItemIdSrc)
	Item.tbZhenYuan:OnRequestRefineSkill(me, nItemIdSrc)
end

function c2s:TryComposeWorshipMap()
	if not Activity:__IsActInProcessByType("QingMingAct") then
		me.CenterMsg("活動已經結束", true)
		return
	end

	Activity:OnPlayerEvent(me, "Act_ComposeWorshipMap");
end

function c2s:TryGetFriendCanCure()
	HousePlant:TryGetFriendCanCure(me);
end

function c2s:Plant()
	HousePlant:Plant(me);
end

function c2s:Crop()
	HousePlant:Crop(me);
end

function c2s:CurePlant(dwOwnerId, nState, bCost)
	HousePlant:Cure(me, dwOwnerId, nState, bCost);
end

function c2s:RequestBuyDressMoney()
	Recharge:RequestBuyDressMoney(me)
end

function c2s:GotoLand(dwOwnerId)
	if not Env:CheckSystemSwitch(me, Env.SW_SwitchMap) then
		me.CenterMsg("目前狀態不允許切換地圖")
		return
	end

	House:GotoLand(me, dwOwnerId);
end

function c2s:SellFurniture(nTemplateId, nCount)
	Furniture:SellFurniture(me, nTemplateId, nCount);
end

function c2s:TryGetHouseFriendList()
	House:TryGetHouseFriendList(me);
end

function c2s:CheckPlayerCanCure()
	HousePlant:CheckPlayerCanCure(me);
end

function c2s:TryComposeLoverRecallMap()
	if not Activity:__IsActInProcessByType("LoverRecallAct") then
		me.CenterMsg("活動已經結束", true)
		return
	end
	Activity:OnPlayerEvent(me, "Act_ComposeLoverRecallMap");
end

function c2s:ArborDayTryCure(nIdx)
	Activity:OnPlayerEvent(me, "Act_OnTryCure", nIdx);
end

function c2s:ArborDayTryGoHouse()
	if not Activity:__IsActInProcessByType("ArborDayCure") then
		me.CenterMsg("活動已經結束", true)
		return
	end
	Activity:OnPlayerEvent(me, "Act_OnTryGoHouse");
end

function c2s:SendBeautyPageantChannelMsg(nType, nParam)
	if not Activity:__IsActInProcessByType("BeautyPageant") then
		me.CenterMsg("活動已經結束", true)
		return
	end
	Activity:OnPlayerEvent(me, "Act_SendChannelMsg", nType, nParam);
end

function c2s:BeautyPageantSignUpFriendReq()
	if not Activity:__IsActInProcessByType("BeautyPageant") then
		me.CenterMsg("活動已經結束", true)
		return
	end
	Activity:OnPlayerEvent(me, "Act_RequestSignUpFriend");
end

function c2s:BeautyPageantVotedAwardReq(nIndex)
	if not Activity:__IsActInProcessByType("BeautyPageant") then
		me.CenterMsg("活動已經結束", true)
		return
	end
	Activity:OnPlayerEvent(me, "Act_VotedAwardReq", nIndex);
end

function c2s:Act_DaiYanRenAct(szFunc, ...)
	Activity:OnPlayerEvent(me, szFunc, ...)
end
function c2s:TryGetExtComfortLevel()
	House:SyncExtComfortLevel(me);
end

function c2s:WeddingCheckNpc(nNpcId)
	 Wedding:WeddingCheckNpc(me, nNpcId)
end

function c2s:OnWeddingRequest(...)
	Wedding:ClientRequest(me, ...);
end

function c2s:XueWeiLevelup(nXueWeiId, XueWeiLevelup)
	JingMai:XueWeiLevelup(me, nXueWeiId, XueWeiLevelup);
end

function c2s:XueWeiReset(nXueWeiId)
	JingMai:ResetXueWei(me, nXueWeiId);
end

function c2s:ResetJingMai(nJingMaiId)
	JingMai:ResetJingMai(me, nJingMaiId);
end

function c2s:SyncLotteryState()
	Lottery:SyncLotteryState(me);
end
