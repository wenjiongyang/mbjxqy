Require("CommonScript/Player/PlayerEventRegister.lua");

PlayerEvent.tbTimeFrameForceOpen = {
	-- ["OpenDomainBattle"] = 3600*24*6+3600*4 ; --开服第七天（天数要减一的） 4点
}

local function UpdateAsyncData(pPlayer)
	local pAsyncData = KPlayer.GetAsyncData(pPlayer.dwID)
	if not pAsyncData then
		return
	end
	local nAddCoin = pAsyncData.GetCoinAdd()
	if nAddCoin ~= 0 then
		pAsyncData.SetCoinAdd(0)

		if nAddCoin > 0 then
			pPlayer.AddMoney("Coin", nAddCoin, Env.LogWay_Offline)
		else
			if not pPlayer.CostMoney("Coin", -nAddCoin, Env.LogWay_Offline)  then
				local nHasMoney = pPlayer.GetMoney("Coin")
				local bRet =  pPlayer.CostMoney("Coin", nHasMoney, Env.LogWay_Offline)
				Log("Warning!!! UpdateAsyncData_CostCoin", pPlayer.dwID, nHasMoney, nAddCoin, bRet)
			end
		end
	end


	--更新装备碎片，目前只有抢夺或在线增减，不要在登陆事件前送碎片
	-- Debris:UpdateOnlineData(pPlayer, pAsyncData);
	CommerceTask:SyncCommerceData(pPlayer);

	RankBattle:UpdateLoginAward(pPlayer, pAsyncData);
end

function PlayerEvent:OnBeforLogin()
	local tbTimeFrameInfo = ScriptData:GetValue("TimeFrame");
	me.CallClientScript("TimeFrame:OnSyncTimeFrameInfo", tbTimeFrameInfo);
end

function PlayerEvent:OnReConnect()
	Lib:CallBack({Fuben.OnLogin, Fuben, true});
	Lib:CallBack({Kin.OnLogin, Kin});
	Lib:CallBack({TeamMgr.OnLogin, TeamMgr});
	Lib:CallBack({PlayerTitle.OnLogin, PlayerTitle, me});
	Lib:CallBack({UpdateAsyncData, me});
	Lib:CallBack({Mail.SyncMailCount, Mail, me});
	Lib:CallBack({Strengthen.OnLogin, Strengthen, me});
	Lib:CallBack({FriendShip.OnLogin, FriendShip, me});
	Lib:CallBack({Player.NotifyMsgOnLogin, Player, me});
	Lib:CallBack({Map.OnLogin, Map});
	Lib:CallBack({Transmit.ReportLogin, Transmit, me});
	Lib:CallBack({ActivityQuestion.OnLogin, ActivityQuestion});
	Lib:CallBack({ActionMode.ServerSendActMode, ActionMode, me});
	Lib:CallBack({Task.OnLogin, Task});
	Lib:CallBack({LoginAwards.OnLogin, LoginAwards});
	Lib:CallBack({MoneyTree.OnLogin, MoneyTree});
	Lib:CallBack({Player.OnLogin, Player, me});
	Lib:CallBack({Faction.OnLogin, Faction, me});
	Lib:CallBack({Activity.OnLogin, Activity, me});
	Lib:CallBack({SeriesFuben.OnLogin, SeriesFuben, me})
	Lib:CallBack({FightPower.OnLogin, FightPower, me});
	Lib:CallBack({CollectionSystem.OnLogin, CollectionSystem})
	Lib:CallBack({SummerGift.OnLogin, SummerGift, me})
	Lib:CallBack({NewPackageGift.OnLogin, NewPackageGift, me});
	Lib:CallBack({Calendar.OnPlayerLogin, Calendar, me});
	Lib:CallBack({ImperialTomb.OnPlayerLogin, ImperialTomb, me});
	me.CallClientScript("PlayerEvent:OnSyncOrgServerId", me.nOrgServerId);
	Lib:CallBack({ChatMgr.ChatDecorate.OnLogin, ChatMgr.ChatDecorate, me})
	Lib:CallBack({ChatMgr.OnReConnect, ChatMgr, me});
	Lib:CallBack({Decoration.OnLogin, Decoration, me});
	Lib:CallBack({House.OnReConnect, House, me});
	Lib:CallBack({Furniture.OnReConnect, Furniture});
	Lib:CallBack({HousePlant.OnReConnect, HousePlant});
	Lib:CallBack({Wedding.OnLogin, Wedding, me});
end

function PlayerEvent:OnLogin(bHosted)
	-- 非托管下登入, 如果在野外地图则设置到进入点
	if not bHosted and Map:IsFieldFightMap(me.nMapTemplateId) then
		local nPosX, nPosY = Map:GetDefaultPos(me.nMapTemplateId);
		me.SetPosition(nPosX, nPosY);
	end

	Lib:CallBack({SupplementAward.OnLogin, SupplementAward, me});
	Lib:CallBack({Task.OnLogin, Task});
	Lib:CallBack({PersonalFuben.OnLogin, PersonalFuben});
	Lib:CallBack({ChatMgr.OnLogin, ChatMgr});
	Lib:CallBack({Kin.OnLogin, Kin});
	Lib:CallBack({TeamMgr.OnLogin, TeamMgr});
	Lib:CallBack({UpdateAsyncData, me});
	Lib:CallBack({House.OnLogin, House});

	Lib:CallBack({LoginAwards.OnLogin, LoginAwards});
	Lib:CallBack({SignInAwards.OnLogin, SignInAwards});
	Lib:CallBack({ActivityQuestion.OnLogin, ActivityQuestion});
	Lib:CallBack({Item.GoldEquip.OnLogin, Item.GoldEquip, me})

	me.SyncFightPower();
	Lib:CallBack({PlayerTitle.OnLogin, PlayerTitle, me});
	Lib:CallBack({EverydayTarget.OnLogin, EverydayTarget, me});
	Lib:CallBack({Pray.OnLogin, Pray, me});
	Lib:CallBack({Helper.OnLogin, Helper, me});
	Lib:CallBack({Mail.SyncMailCount, Mail, me});
	Lib:CallBack({Strengthen.OnLogin, Strengthen, me});
	Lib:CallBack({Transmit.ReportLogin, Transmit, me});
	Lib:CallBack({Fuben.OnLogin, Fuben});
	Lib:CallBack({FriendShip.OnLogin, FriendShip, me});
	Lib:CallBack({Player.NotifyMsgOnLogin, Player, me});
	Lib:CallBack({MoneyTree.OnLogin, MoneyTree});
	Lib:CallBack({Map.OnLogin, Map});
	Lib:CallBack({OnHook.OnLogin, OnHook, me});
	Lib:CallBack({NewInformation.OnPlayerLogin, NewInformation, me})
	Lib:CallBack({FactionBattle.FactionMonkey.OnLogin, FactionBattle.FactionMonkey, me})
	Lib:CallBack({Activity.OnLogin, Activity, me});
	Lib:CallBack({SeriesFuben.OnLogin, SeriesFuben, me})
	Lib:CallBack({CollectionSystem.OnLogin, CollectionSystem})
	Lib:CallBack({Gift.GiftManager.OnLogin, Gift.GiftManager})

	local nOrgGamp = Npc.CampTypeDef.camp_type_player;
	if me.dwKinId > 0 then
		local tbKinData = Kin:GetKinById(me.dwKinId);
		if tbKinData then
			nOrgGamp = tbKinData:GetCamp();
		end
	end

	me.SetOrgCamp(nOrgGamp);
	Lib:CallBack({OpenLight.OnLogin, OpenLight, me});
	Lib:CallBack({ActionMode.ServerSendActMode, ActionMode, me});
	Lib:CallBack({MarketStall.OnLogin, MarketStall, me});
	Lib:CallBack({Survey.SendLatest, Survey, me});
	Lib:CallBack({AssistClient.OnLogin, AssistClient, me});
	Lib:CallBack({Faction.OnLogin, Faction, me});
	Lib:CallBack({Calendar.OnPlayerLogin, Calendar, me})
	Lib:CallBack({Player.OnLogin, Player, me});
	Lib:CallBack({CardPicker.OnLogin, CardPicker, me});
	Lib:CallBack({PlayerEvent.CheckForceOpenTimeFrame, PlayerEvent, me});
	Lib:CallBack({FightPower.OnLogin, FightPower, me});
	Lib:CallBack({Partner.OnLogin, Partner, me});
	Lib:CallBack({SummerGift.OnLogin, SummerGift, me});
	Lib:CallBack({NewPackageGift.OnLogin, NewPackageGift, me});
	Lib:CallBack({TeacherStudent.OnLogin, TeacherStudent, me})
	Lib:CallBack({Player.CheckAllMoneyDebt, Player, me})
	Lib:CallBack({ImperialTomb.OnPlayerLogin, ImperialTomb, me});

	me.CallClientScript("PlayerEvent:OnSyncOrgServerId", me.nOrgServerId);
	Lib:CallBack({Player.SendServerIdentity, Player, me})
	Lib:CallBack({Player.SyncRechargeBackNewsInfo, Player, me})
	Lib:CallBack({ChatMgr.ChatDecorate.OnLogin, ChatMgr.ChatDecorate, me})
	Lib:CallBack({SwornFriends.OnLogin, SwornFriends, me})
	Lib:CallBack({Kin.MonsterNian.OnLogin, Kin.MonsterNian, me})

	-- 因为要取到玩家身上战力等数据才放到最后
	Lib:CallBack({Forbid.OnLogin, Forbid, me});
	Lib:CallBack({BiWuZhaoQin.OnLogin, BiWuZhaoQin, me});
	Lib:CallBack({RegressionPrivilege.OnLogin, RegressionPrivilege, me})
	Lib:CallBack({DirectLevelUp.OnLogin, DirectLevelUp, me})
	Lib:CallBack({Player.CheckMoneyDebtBuff, Player, me})
	Lib:CallBack({Player.CheckMoneyDebtStartTime, Player, me})
	Lib:CallBack({Decoration.OnLogin, Decoration, me});
	Lib:CallBack({Furniture.OnLogin, Furniture});
	Lib:CallBack({HousePlant.OnLogin, HousePlant});
	Lib:CallBack({Sdk.OnLogin, Sdk, me});
	Lib:CallBack({Wedding.OnLogin, Wedding, me});
	Lib:CallBack({TeamBattle.OnPlayerLogin_League, TeamBattle});
	Lib:CallBack({InDifferBattle.OnPlayerLogin_League, InDifferBattle, me});
	Lib:CallBack({JingMai.OnLogin, JingMai, me});
	Lib:CallBack({Lottery.OnLogin, Lottery, me});

	me.SetUserValue(Player.SAVE_GROUP_LOGIN, Player.SAVE_KEY_LoginTime, GetTime()) --需要登录事件最后设置,之前可用于做上次登录时间
	Log("[Login]", me.szAccount, me.dwID, me.szName, me.GetMoney("Gold"), me.GetMoney("Coin"));
end

function PlayerEvent:OnZoneLogin(nReconnected)
	Lib:CallBack({TeamMgr.OnLogin, TeamMgr}); --队伍的在地图的前面

	if nReconnected == 1 then
		Lib:CallBack({Map.OnLogin, Map});
		Lib:CallBack({PlayerTitle.OnLogin, PlayerTitle, me});
	end

	Lib:CallBack({Fuben.OnLogin, Fuben});
	Lib:CallBack({Partner.OnZoneLogin, Partner, me});
end

--本服的前往跨区服时
function PlayerEvent:OnTransferZone()
	OnHook:EndOnLineOnHook(me,OnHook.tbCalcLogType.LogType_Online_Force)
	Lib:CallBack({ChatMgr.OnTransferZone, ChatMgr, me});
end

function PlayerEvent:OnLogout()
	Lib:CallBack({PlayerTitle.OnLogout, PlayerTitle, me});
	Lib:CallBack({SignInAwards.OnLogout, SignInAwards});
	Lib:CallBack({TeamMgr.OnLogout, TeamMgr, me});
	Lib:CallBack({OnHook.OnLogout, OnHook, me});
	Lib:CallBack({SeriesFuben.OnLogout, SeriesFuben, me});
	Lib:CallBack({self.OnLogoutLogRoleInfo, self, me});
	Log("[Logout]", me.szAccount, me.dwID, me.szName, string.format("%.2fKB", me.nScriptDataSize / 1024));
	Lib:CallBack({Sdk.OnLogout, Sdk, me});
	Lib:CallBack({Kin.OnLogout, Kin, me});
	if not MODULE_ZONESERVER then
		Lib:CallBack({Faction.OnLogout, Faction, me});
		Lib:CallBack({RankBoard.UpdateRankVal, RankBoard, "Level", me});
		Lib:CallBack({FriendShip.OnLogout, FriendShip, me})
	end
	Lib:CallBack({TeacherStudent.OnLogout, TeacherStudent, me})
	Lib:CallBack({ChatMgr.OnLogout, ChatMgr, me})
	Lib:CallBack({Activity.OnPlayerEvent, Activity, me, "Act_OnPlayerLogout"})
	Lib:CallBack({Wedding.OnLogout, Wedding, me})
	AssistClient:ReportQQScore(me, Env.QQReport_VipLevel, me.GetVipLevel(), 0, 1)

	me.TLog("LogoutGameFlow", me.nLevel);
end

function PlayerEvent:OnFinishPersonalFuben(nFubenIndex, nFubenLevel, nStarLevel)
	Task:OnFinishPersonalFuben(nFubenIndex, nFubenLevel, nStarLevel);
end

function PlayerEvent:OnAchievementCompleted(szMainKind, szSubKind, nCompletedLevel)
	Task:OnAchievementCompleted(szMainKind, szSubKind, nCompletedLevel);
end

PlayerEvent.tbRevivePos =
{
	{10, 14134, 13275},
	{10, 15080,	11484},
	{10, 15810,	13278},
	{10, 10565,	15336},
	{10, 12708,	15336},
	{10, 8693,	15395},
	{10, 14928,	15367},
	{10, 11547,	13662},
	{10, 11556,	12001},
};

-- 下面的每一行代表一个矩形，第二个和第三个代表了矩形的对角的点
-- 会根据100的间隔在矩形内自动生成可用的点
PlayerEvent.tbReviveRange = {
	{10, {11274, 9322}, {11951, 8797}, },
	{10, {7775, 13003}, {8449, 12560}, },
	{10, {7560, 11291}, {8029, 10673}, },
	{10, {6793, 15590}, {8177, 15042}, },
	{10, {7615, 19207}, {8561, 18195}, },
	{10, {10961, 22084}, {11795, 20982}, },
	{10, {11404, 19773}, {11873, 18653}, },
	{10, {12897, 19055}, {13235, 18507}, },
	{10, {15524, 15575}, {16481, 15214}, },
	{10, {10698, 16278}, {11078, 15929}, },
	{10, {12078, 14846}, {12564, 14373}, },
	{10, {15593, 11927}, {16053, 11374}, },
	{10, {13944, 13501}, {14514, 13209}, },
}
function PlayerEvent:LoadRevivePos()
	for nIdx, tbInfo in pairs(self.tbReviveRange) do
		local nMapId = tbInfo[1];
		local tbFirstPos = tbInfo[2];
		local tbSecondPos = tbInfo[3];
		local nSpX = tbFirstPos[1] > tbSecondPos[1] and -100 or 100;
		local nSpY = tbFirstPos[2] > tbSecondPos[2] and -100 or 100;
		for nX = tbFirstPos[1], tbSecondPos[1], nSpX do
			for nY = tbFirstPos[2], tbSecondPos[2], nSpY do
				table.insert(self.tbRevivePos, {nMapId, nX, nY});
			end
		end
	end

	Lib:SmashTable(self.tbRevivePos);
end
PlayerEvent:LoadRevivePos();

PlayerEvent.nCurRevivePos = 1;
function PlayerEvent:GetRevivePos(nMapId)
	self.nCurRevivePos = self.nCurRevivePos + 1;
	if not self.tbRevivePos[self.nCurRevivePos] then
		self.nCurRevivePos = 1;
	end

	if nMapId and self.tbRevivePos[self.nCurRevivePos][1] ~= nMapId then
		return;
	end

	return unpack(self.tbRevivePos[self.nCurRevivePos]);
end

function PlayerEvent:OnRevive(nType)
	if nType == 1 then
		return;
	end

	local nRevMapId, nX, nY, nRevFightMode = me.GetTempRevivePos();
	if nRevMapId and nX and nY then
		local nMapTID = GetMapInfoById(nRevMapId);
		if nMapTID then

			if me.nMapId == nRevMapId then
				me.SetPosition(nX, nY);
				if nRevFightMode then
					me.nFightMode = nRevFightMode
				end
			else
				me.SwitchMap(nRevMapId, nX, nY);
			end

			return;
		end
	end

	local nMapId, nX, nY = self:GetRevivePos();
	me.SwitchMap(nMapId, nX, nY);
end

PlayerEvent.tbPKMap = {
	[400] = 1,
	[401] = 1,
	[402] = 1,
	[403] = 1,
	[404] = 1,
	[405] = 1,
	[406] = 1,
	[407] = 1,
	[408] = 1,
	[410] = 1,
	[411] = 1,
	[412] = 1,
	[413] = 1,
	[414] = 1,
	[415] = 1,
	[416] = 1,
	[417] = 1,
	[418] = 1,
};
-- 通用死亡事件
function PlayerEvent:OnDeath(pKiller)
	if me._bDefaultDeathDisable then
		return;
	end
	local pPlayer = pKiller and pKiller.GetPlayer() or nil;
	if pPlayer then
		pPlayer.CenterMsg(string.format("你擊傷了「%s」！", (me.szNickName or me.szName) ), true);
		Player:AddFieldComboKill(pPlayer);
	end

	Player:ClearFieldComboKill(me);
	if Fuben.tbFubenSetting[me.nMapTemplateId] then  -- 副本的不处理
		return;
	end

	local szKillerName;
	if pPlayer then
		szKillerName = pPlayer.szNickName or pPlayer.szName
	else
		szKillerName = pKiller and pKiller.szName or "天外來客"
	end
	me.Msg(string.format("您被「%s」擊為重傷！",  szKillerName));
	if me.nInBattleState == 1 or ImperialTomb:IsEmperorMirrorMapByTemplate(me.nMapTemplateId) or ImperialTomb:IsFemaleEmperorMirrorMapByTemplate(me.nMapTemplateId) then
		if me.nInBattleState == 1 and (Map:IsCityMap(me.nMapTemplateId) or Map:IsFieldFightMap(me.nMapTemplateId)) then
			Log("[PlayerEvent] OnDeath ERRR ???? ", me.dwID, me.nMapTemplateId);
		end
		return
	end

	if me.bSelfAutoRevive then
		return;
	end

	local function fnRevive(nPlayerId)
		local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
		if not pPlayer then
			return;
		end

		pPlayer.Revive(0);
		pPlayer.GetNpc().SetCurLife(1);
	end

	if pPlayer then
		if self.tbPKMap[me.nMapTemplateId] then
			local nExp = PKValue:GetExpCount(me);
			if nExp > 0 then
				me.ReduceExp(nExp, Env.LogWay_Exp_Death);
				me.Msg(string.format("您的經驗減少了%s點", nExp));
			end
			PKValue:ReduceValue(me);
		end
		if Map:GetClassDesc(me.nMapTemplateId) == "fight" and
			(pPlayer.nPkMode == Player.MODE_KILLER or pPlayer.nPkMode == Player.MODE_PK) then
			me.TLog("PKDeathFlow", me.nLevel, me.GetVipLevel(), me.GetFightPower(), pPlayer.szAccount, pPlayer.dwID, pPlayer.nLevel, pPlayer.GetVipLevel(), pPlayer.GetFightPower(), me.nMapTemplateId)
		end

	end

	local nMeID = me.dwID;
	me.MsgBox(string.format("您被「[FFC300FF]%s[-]」擊為重傷\n", szKillerName) .. "將在%s秒後回城療傷", {{"回城療傷", fnRevive, me.dwID}}, nil, 10, function () fnRevive(nMeID) end);
	me.CallClientScript("PlayerEvent:OnEvent", "OnDeath");
end

function PlayerEvent:OnEarlyDeath(pKiller)
	local pPlayer = pKiller and pKiller.GetPlayer() or nil;
	if pPlayer and self.tbPKMap[me.nMapTemplateId] then
		if pPlayer.nPkMode == Player.MODE_KILLER and me.nPkMode == Player.MODE_PEACE then
			PKValue:AddValue(pPlayer);
		end
	end
end

function PlayerEvent:OnLeaveMap(nMapTemplateId, nMapId)
	Lib:CallBack({Decoration.OnLeaveMap, Decoration, nMapTemplateId, nMapId});
	Player:ClearFieldComboKill(me);
	me.nForbidPkMode = nil;
end

function PlayerEvent:OnEnterMap(nMapTemplateId, nMapId)
    ActionMode:OnEnterMap(me, nMapTemplateId);
    Lib:CallBack({Decoration.PlayerOnEnterMap, Decoration, nMapId});
    Lib:CallBack({Furniture.OnEnterMap, Furniture, nMapId});
    Lib:CallBack({HousePlant.OnEnterMap, HousePlant});
    Lib:CallBack({OnHook.OnEnterMap, OnHook, nMapTemplateId, nMapId});
end

function PlayerEvent:LeaveClientMap()
    ActionMode:ServerSendActMode(me);
    local forcePkMode = Map:GetForcePkMode(me.nMapTemplateId)
	if forcePkMode and forcePkMode>0 then
		me.SetPkMode(forcePkMode)
		me.bForbidChangePk = 1
	end
end

function PlayerEvent:UnuseEquip(nEquipPos)
    if nEquipPos == Item.EQUIPPOS_HORSE then
    	ActionMode:DoForceNoneActMode(me);
    end
end

function PlayerEvent:OnGotoEntryPointFail()
	local nMapId, nX, nY = KPlayer.GetBirthPosition();
	me.SwitchMap(nMapId, nX, nY);
end

function PlayerEvent:OnFirstLogin()
	-- 第一个任务Id配置位置改变到 CommonScript/Task/TaskCommon.lua 中
	Task:ForceAcceptTask(me, Task.nFirstTaskId);
	-- 设置初始朝向
	me.CallClientScript("Client:SetPlayerDir", 20, 999);
	--me.AddMoney("SkillPoint", FightSkill.nInitSkillPoint, Env.LogWay_FirstLogin);
	OnHook:OnFirstLogin(me);
	Log("[FirstLogin]", me.szAccount, me.dwID, me.szName)
	AssistClient:ReportQQScore(me, Env.QQReport_RegisterTime, GetTime(), 0, 1);
	AssistClient:ReportQQScore(me, Env.QQReport_ChangeRoleName, me.szName, 0, 2);
end

function PlayerEvent:OnPartnerFightPowerChange()
	if  me.tbForbidData then --需要登录事件后触发 排行榜操作
		FightPower:ChangeFightPower("Partner", me);
	end
end

function PlayerEvent:OnShapeShift(nNpcTemplateID, nType)
    ActionMode:DoForceNoneActMode(me);
end

function PlayerEvent:OnGetMaxLevel(pPlayer)
	local nCurOpenServerDay = Lib:GetLocalDay(GetServerCreateTime())
	local nToday = Lib:GetLocalDay()
	local nTimeNow = GetTime();
	for i,v in ipairs(TimeFrame.tbOpenNewMaxLevelTimeFrame) do
		local nOpenDay = Lib:GetLocalDay(v.nTimeFrameOpenTime);
		if v.nTimeFrameOpenTime > nTimeNow then
			local tbTime = os.date("*t", GetTime() + 24* 3600 * (nOpenDay - nToday));
			Mail:SendSystemMail({
				To        = pPlayer.dwID,
				Title = "等級上限說明",
				Text      = string.format("    恭喜俠士已經達到當前等級上限，距離開放%d級上限還有%d天（%d月%d日 4:00）\n[FFFE0D]    注：達到等級上限且經驗100%%後，繼續獲得的經驗減半[-]", v.nMaxLevel, nOpenDay - nToday, tbTime.month, tbTime.day),
				});

			return
		end
	end
end

function PlayerEvent:OnLevelUp(nNewLevel)
	JuBaoPen:CheckOpenJuBaoPen(me, nNewLevel);

	Kin:UpdateKinMemberInfo(me.dwKinId);
	if nNewLevel == 10 then
		Mail:SendSystemMail({
			To = me.dwID,
			Title = "真兒的饋贈",
			Text = "    你從島上離開已有一段時日了，雖然內傷應該已好的差不多了，可是闖蕩江湖，處處都得小心，尤其要珍重身體。哼，再有一次，我可不救你了哦！我讓郵差捎去一些盤纏，若有時間，便多回島上看看，珍重。",
			From = "真兒",
			tbAttach = {
				{"Gold", 100},
			},
		})
	end
	if nNewLevel == GetMaxLevel() then
	 	self:OnGetMaxLevel(me)
	end

	Task:OnLevelUp();
	XiuLian:OnPlayerLevelUp(me, nNewLevel);
	RankBoard:UpdateRankVal("Level", me)
	--me.AddMoney("SkillPoint", FightSkill.nAddLeveUpSkillPoint, Env.LogWay_RoleLevelUp);
	Survey:SendLatest(me)
	AssistClient:ReportQQScore(me, Env.QQReport_LevelUp, nNewLevel, 0, 1)
	ActivityQuestion:OnPlayerLevelUp(nNewLevel)
	Lib:CallBack({Faction.OnLevelUp, Faction, me});
	TeamMgr:PlayerInfoChange(me)
	NewPackageGift:OnLevelUp(nNewLevel)
	TeacherStudent:OnLevelUp(me)
	House:OnLevelUp();
	Activity:OnPlayerEvent(me, "Act_OnPlayerLevelUp")

	LogD(Env.LOGD_RoleLevelUp, me.szAccount, me.dwID, nNewLevel);
end

function PlayerEvent:OnFinishTask(nTaskId)
	Battle:OnFinishTask(nTaskId);
	House:OnFinishTask(nTaskId);
	JingMai:OnFinishTask(nTaskId);
end

function PlayerEvent:OnDisConnect()
end

function PlayerEvent:OnLogoutLogRoleInfo(pPlayer)
	local tbAllPartner = pPlayer.GetAllPartner();
	local tbPartnerPosInfo = pPlayer.GetPartnerPosInfo()
	local tbPartnerInPos = {}
	for i,v in ipairs(tbPartnerPosInfo) do
		if v ~= 0 then
			tbPartnerInPos[v] = 1;
		end
	end
	for dwPartnerId, v in pairs(tbAllPartner) do
		local pPartner = pPlayer.GetPartnerObj(dwPartnerId);
		local tbSkillInfo = pPartner.GetNormalSkillInfo();
		LogD(Env.LOGD_ParterInfo, pPlayer.szAccount, pPlayer.dwID, dwPartnerId, v.nTemplateId, v.nNpcTemplateId, v.nLevel, v.nFightPower, (tbPartnerInPos[dwPartnerId] or 0),
			tbSkillInfo[1].nSkillId, tbSkillInfo[2].nSkillId, tbSkillInfo[3].nSkillId, tbSkillInfo[4].nSkillId, tbSkillInfo[5].nSkillId)
	end
	--装备信息日志
	local tbEquipInfo = pPlayer.GetEquips()
	local tbStrength = pPlayer.GetStrengthen()

	for nEquipPos, nItemId in pairs(tbEquipInfo) do
		local pItem = pPlayer.GetItemInBag(nItemId)
		if pItem then
			local tbInsetInfo = pPlayer.GetInsetInfo(nEquipPos)
			LogD(Env.LOGD_EquipInfo, pPlayer.szAccount, pPlayer.dwID, nItemId, pItem.dwTemplateId, pItem.nLevel, pItem.nFightPower, tbStrength[nEquipPos], tbInsetInfo[1], tbInsetInfo[2], tbInsetInfo[3], tbInsetInfo[4])
		end
	end
end

function PlayerEvent:OnPlayer5MinuteActive()
	local nGameTime = me.dwGameTime;
	local nToday = Lib:GetLocalDay();
	local nYesterday = me.GetUserValue(Player.ONLINE_TIME_GROUP, Player.ONLINE_YESTERDAY_DAY);
	if nYesterday ~= (nToday - 1) then
		nYesterday = nToday - 1;
		me.SetUserValue(Player.ONLINE_TIME_GROUP, Player.ONLINE_YESTERDAY_DAY, nYesterday);
		me.SetUserValue(Player.ONLINE_TIME_GROUP, Player.ONLINE_YESTERDAY_ONLINETIME, nGameTime);
		return;
	end

	local nLastDayGameTime = me.GetUserValue(Player.ONLINE_TIME_GROUP, Player.ONLINE_YESTERDAY_ONLINETIME);
	local nTodayOnlineTime = nGameTime - nLastDayGameTime;

	AssistClient:ReportQQScore(me, Env.QQReport_DayOnlineTime, nTodayOnlineTime, 0, 1);
end

--该函数只作用1个月时长，已指令形式执行 补发移漏的 vip10，12礼包
function PlayerEvent:OnPlayerLoginVipAward()
	local nBuyedVal = me.GetUserValue(Recharge.SAVE_GROUP, Recharge.KEY_VIP_AWARD)
	local nBuyedValEx = me.GetUserValue(Recharge.SAVE_GROUP, Recharge.KEY_VIP_AWARD_EX)
	if nBuyedVal == nBuyedValEx then
		return
	end

	for i = 11, 13, 2 do
		local nBuydeBit = KLib.GetBit(nBuyedVal, i)
		local nBuydeBitEx = KLib.GetBit(nBuyedValEx, i)
		local nNewValEx = 0;
		if nBuydeBit == 1 and nBuydeBitEx == 0 then
			Mail:SendSystemMail({
				To = me.dwID,
				Title = "特權禮包補償",
				Text = string.format("    俠士好！由於劍俠V%d特權禮包增加了【名將令】獎勵，附件為您的【名將令】補償。", i-1) ,
				From = "系統",
				tbAttach = {
					{"item", 1394, 1},
				},
			});
			nBuyedValEx = KLib.SetBit(nBuyedValEx, i, 1)
			me.SetUserValue(Recharge.SAVE_GROUP, Recharge.KEY_VIP_AWARD_EX, nBuyedValEx)
		end
	end
end

function PlayerEvent:CheckForceOpenTimeFrame()
	if not next(self.tbTimeFrameForceOpen) then
		return
	end
	me.CallClientScript("Player:SynForceOpenTimeFrame", self.tbTimeFrameForceOpen)
end

function PlayerEvent:OnReConnectZoneClient()
	Lib:CallBack({Kin.OnLogin, Kin});
	Lib:CallBack({PlayerTitle.OnLogin, PlayerTitle, me});
	Lib:CallBack({TeamMgr.OnLogin, TeamMgr});
	Lib:CallBack({Player.CheckMoneyDebtStartTime, Player, me})

	me.CallClientScript("PlayerEvent:OnReConnectZoneClient")
end

function PlayerEvent:OnTakeMailAttach(nLogReazon1, nLogReazon2, tbParams)
	if nLogReazon1 == Env.LogWay_AuctionGold then
		Achievement:AddCount(me, "PayOff_1", tbParams and tbParams.nGoldEach);
		TeacherStudent:TargetAddCount(me, "KinSalary", 1);
	elseif nLogReazon1 == Env.LogWay_AuctionOnDeal then
		Achievement:AddCount(me, "FirstAuctionDeal_2");
	elseif nLogReazon1==Env.LogWay_MarketStallGetMoney then
		TeacherStudent:TargetAddCount(me, "SellMarketStall", 1)
	elseif nLogReazon1==Env.LogWay_Boss then
		if not tbParams or not tbParams.nRank then
			return
		end

		local nRank = tbParams.nRank
		if nRank <= 100 then
			Achievement:AddCount(me, "Boss_1");
		end
		if nRank <= 30 then
			Achievement:AddCount(me, "Boss_2");
		end
		if nRank <= 10 then
			Achievement:AddCount(me, "Boss_3");
		end
		if nRank <= 1 then
			Achievement:AddCount(me, "Boss_4");
		end

		Kin:RedBagOnEvent(me, Kin.tbRedBagEvents.leader_rank, nRank)

		if nRank == 1 then
			me.CallClientScript("GameSetting.Comment:OnEvent", GameSetting.Comment.Type_WuLinMengZhu_First);
		end

		if nRank<=500 then
			TeacherStudent:TargetAddCount(me, "MengZhu500", 1)
		end
		if nRank<=1500 then
			TeacherStudent:TargetAddCount(me, "MengZhu1500", 1)
		end
		TeacherStudent:CustomTargetAddCount(me, "MengZhu", 1)
	elseif nLogReazon1 == Env.LogWay_FactionMonkey then
		Sdk:SendTXLuckyBagMail(me, "FactionMonkey");
	elseif nLogReazon1 == Env.LogWay_KinEscort then
		TeacherStudent:CustomTargetAddCount(me, "KinEscort", 1)
	elseif nLogReazon1 == Env.LogWay_DomainBattle then
		TeacherStudent:CustomTargetAddCount(me, "CityWar", 1)
	elseif nLogReazon1 == Env.LogWay_InDifferBattleAward then
		TeacherStudent:CustomTargetAddCount(me, "SoulGhost", 1)
	elseif nLogReazon1 == Env.LogWay_InDifferBattleUpgrade then
		me.CallClientScript("Ui:OpenWindow", "BattleRankEffectPanel", nLogReazon2)
	elseif nLogReazon1 == Env.LogWay_GetBattleQualify then
		me.CallClientScript("Ui:OpenWindow", "BattleRankEffectPanel", nLogReazon2)
	end
end

function PlayerEvent:OnTeamChanged()
	Lib:CallBack({ArenaBattle.OnTeamChanged, ArenaBattle, me});
end

local tbTXLuckyBagMap = {
	["VIP6"] = "VIP6";
	["VIP9"] = "VIP9";
	["VIP12"] = "VIP12";
	["VIP15"] = "VIP15";
	["Honor6"] = "Honor6";
	["Honor7"] = "Honor7";
	["Honor8"] = "Honor8";
	["Honor9"] = "Honor9";
	["Honor10"] = "Honor10";
	["Honor11"] = "Honor11";
	["Honor12"] = "Honor12";
	["Honor13"] = "Honor13";
}

function PlayerEvent:OnVipChanged(nNewVipLevel, nOldVipLevel)
	-- 腾讯红包
	local szRedBagKey = "VIP" .. nNewVipLevel;
	if tbTXLuckyBagMap[szRedBagKey] then
		Sdk:SendTXLuckyBagMail(me, szRedBagKey);
	end

	Kin:OnVipChanged(me, nNewVipLevel, nOldVipLevel)
end

function PlayerEvent:OnHonorLevelUp(nNewHonorLevel)
	-- 腾讯红包
	local szRedBagKey = "Honor" .. nNewHonorLevel;
	if tbTXLuckyBagMap[szRedBagKey] then
		Sdk:SendTXLuckyBagMail(me, szRedBagKey);
	end
end

function PlayerEvent:OnMarry(pLover)
	Lib:CallBack({ House.OnMarry, House, me, pLover });
end

PlayerEvent:RegisterGlobal("OnPartnerFightPowerChange",     PlayerEvent.OnPartnerFightPowerChange, PlayerEvent);
PlayerEvent:RegisterGlobal("OnBeforLogin",                  PlayerEvent.OnBeforLogin, PlayerEvent);
PlayerEvent:RegisterGlobal("OnLogin",                       PlayerEvent.OnLogin, PlayerEvent);
PlayerEvent:RegisterGlobal("OnLogout",                      PlayerEvent.OnLogout, PlayerEvent);
PlayerEvent:RegisterGlobal("OnFinishPersonalFuben",         PlayerEvent.OnFinishPersonalFuben, PlayerEvent);
PlayerEvent:RegisterGlobal("OnRevive",                      PlayerEvent.OnRevive, PlayerEvent);
PlayerEvent:RegisterGlobal("OnDeath",                       PlayerEvent.OnDeath, PlayerEvent);
PlayerEvent:RegisterGlobal("OnEarlyDeath",                  PlayerEvent.OnEarlyDeath, PlayerEvent);
PlayerEvent:RegisterGlobal("OnGotoEntryPointFail",          PlayerEvent.OnGotoEntryPointFail, PlayerEvent);
PlayerEvent:RegisterGlobal("OnFirstLogin",                  PlayerEvent.OnFirstLogin, PlayerEvent);
PlayerEvent:RegisterGlobal("OnReConnect",                   PlayerEvent.OnReConnect, PlayerEvent);
PlayerEvent:RegisterGlobal("OnDisConnect",                  PlayerEvent.OnDisConnect, PlayerEvent);
PlayerEvent:RegisterGlobal("OnLeaveMap",                    PlayerEvent.OnLeaveMap, PlayerEvent);
PlayerEvent:RegisterGlobal("OnEnterMap",                    PlayerEvent.OnEnterMap, PlayerEvent);
PlayerEvent:RegisterGlobal("LeaveClientMap",                PlayerEvent.LeaveClientMap, PlayerEvent);
PlayerEvent:RegisterGlobal("UnuseEquip",                    PlayerEvent.UnuseEquip, PlayerEvent);
PlayerEvent:RegisterGlobal("OnAchievementCompleted",        PlayerEvent.OnAchievementCompleted, PlayerEvent);
PlayerEvent:RegisterGlobal("FinishTask",                    PlayerEvent.OnFinishTask, PlayerEvent);
PlayerEvent:RegisterGlobal("ShapeShift",                    PlayerEvent.OnShapeShift, PlayerEvent);
PlayerEvent:RegisterGlobal("OnReConnectZoneClient",         PlayerEvent.OnReConnectZoneClient, PlayerEvent);
PlayerEvent:RegisterGlobal("OnTakeMailAttach", 				PlayerEvent.OnTakeMailAttach, PlayerEvent);
PlayerEvent:RegisterGlobal("OnTeamChanged",					PlayerEvent.OnTeamChanged, PlayerEvent);
PlayerEvent:RegisterGlobal("OnVipChanged",					PlayerEvent.OnVipChanged, PlayerEvent);
PlayerEvent:RegisterGlobal("OnHonorLevelUp",				PlayerEvent.OnHonorLevelUp, PlayerEvent);
PlayerEvent:RegisterGlobal("OnZoneLogin",					PlayerEvent.OnZoneLogin, PlayerEvent);
PlayerEvent:RegisterGlobal("OnTransferZone",				PlayerEvent.OnTransferZone, PlayerEvent);
PlayerEvent:RegisterGlobal("OnMarry",						PlayerEvent.OnMarry, PlayerEvent);

if Sdk:IsMsdk() and not MODULE_ZONESERVER then
	PlayerEvent:RegisterGlobal("OnPlayer5Minute",               PlayerEvent.OnPlayer5MinuteActive, PlayerEvent);
	PlayerEvent:RegisterGlobal("OnLogin",                       PlayerEvent.OnPlayer5MinuteActive, PlayerEvent);
end

if not MODULE_ZONESERVER then
	PlayerEvent:RegisterGlobal("OnLevelUp",                     PlayerEvent.OnLevelUp, PlayerEvent);
end