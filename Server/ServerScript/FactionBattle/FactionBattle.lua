
--门派竞技

Require("CommonScript/FactionBattle/FactionBattleDef.lua")

-------------------------------------------------------------------
function FactionBattle:Start()
	if Lib:CountTB(self.tbGame) > 0 then
		Log("[Error]", "FactionBattle", "Already Started");
		return
	end

	if not FactionBattle:IsCanStart() then
		--如果华山论剑活动开启，关闭周四的场次
		Log("[Info]", "FactionBattle", "Close On HuaShanLunJian, Tuesday");
		return
	end

	if Lib:CountTB(self.tbBattleData.tbWinnerInfo) >= self.MAX_SAVE_DATA_COUNT then
		for i=self.tbBattleData.nCurSession-self.MAX_SAVE_DATA_COUNT, 1, -1 do
			self.tbBattleData.tbWinnerInfo[i] = nil
		end
	end

	self.tbBattleData.nCurSession = self.tbBattleData.nCurSession + 1;
	self.tbPrepareMap = {}
	self.tbFreePKMap = {}
	self.tbBoxAwardRecord = {};	--箱子拾取记录

	self.tbWinnerInfo[self.tbBattleData.nCurSession] = {}

	for nFaction=1,Faction.MAX_FACTION_COUNT do
		local nPrepareMapId = CreateMap(self.PREPARE_MAP_TAMPLATE_ID);
		self.tbPrepareMap[nPrepareMapId] = {nFaction = nFaction}
	end


	KPlayer.SendWorldNotify(FactionBattle.MIN_LEVEL, 1000,
				"門派競技已經開啟，各位少俠，通過「活動」前去參加！",
				ChatMgr.ChannelType.Public, 1);

	--开始时给右下角叹号通知
	local tbMsgData =
	{
		szType = "FactionBattleStart",
		nTimeOut = GetTime() + FactionBattle.START_NOTIFY_TIME,
	};

	local tbPlayer = KPlayer.GetAllPlayer();
	for _, pPlayer in pairs(tbPlayer) do
		if pPlayer.nLevel >= FactionBattle.MIN_LEVEL then
			pPlayer.CallClientScript("Ui:SynNotifyMsg", tbMsgData);
		end
	end

	if HuaShanLunJian:IsPlayGamePeriod() then
		--华山论剑开启后给不同奖励
		SupplementAward:OnActivityOpen("FactionBattle2")
	else
		SupplementAward:OnActivityOpen("FactionBattle")
	end

	Calendar:OnActivityBegin("FactionBattle")
end

function FactionBattle:IsCanStart()
	--如果华山论剑活动开启或群英会开启，关闭周四的场次
	return not ((HuaShanLunJian:IsPlayGamePeriod() or GetTimeFrameState("OpenLevel99") == 1)and Lib:GetLocalWeekDay() == 4)
end

function FactionBattle:Init()
	self.tbBattleData = ScriptData:GetValue("FactionBattle");
	self.tbBattleData.nCurSession = self.tbBattleData.nCurSession or 0;
	self.tbBattleData.tbWinnerInfo = self.tbBattleData.tbWinnerInfo or {}
	self.tbWinnerInfo = self.tbBattleData.tbWinnerInfo

	self.tbBattleData.tbMonkeyData = self.tbBattleData.tbMonkeyData or {}
	self.tbBattleData.tbMonkeyData.nStartTime = self.tbBattleData.tbMonkeyData.nStartTime or 0
	self.tbBattleData.tbMonkeyData.tbMonkeyInfo = self.tbBattleData.tbMonkeyData.tbMonkeyInfo or {}
	self.tbBattleData.tbMonkeyData.nChosedSession = self.tbBattleData.tbMonkeyData.nChosedSession or 0
	self.tbBattleData.tbMonkeyData.nBackUpSession = self.tbBattleData.tbMonkeyData.nBackUpSession or -1
	self.tbBattleData.tbMonkeyData.nMonkeySession = self.tbBattleData.tbMonkeyData.nMonkeySession or 0

	self.tbGame = self.tbGame or {}

	local fnMapCreateCallback = function (tbMap, nMapId)
		local mapInfo = self.tbPrepareMap[nMapId]

		self:InitGame(mapInfo.nFaction, nMapId);
		--创建了准备场再创建晋级赛地图
		local nFreePKMapId = CreateMap(self.FREEPK_MAP_TAMPLATE_ID);
		self.tbFreePKMap[nFreePKMapId] = {nFaction = mapInfo.nFaction}
	end
	local fnMapOnDestroyCallback = function (tbMap, nMapId)
		local mapInfo = self.tbPrepareMap[nMapId]
		local tbGame = self:GetFactionData((mapInfo and mapInfo.nFaction) or 0)
		if tbGame then
			tbGame:Close()
		end
	end
	local fnMapEnterCallback = function (tbMap, nMapId)
		local mapInfo = self.tbPrepareMap[nMapId]
		local tbGame = self:GetFactionData((mapInfo and mapInfo.nFaction) or 0)
		if tbGame then
			tbGame:OnMapEnter(nMapId);
		end
	end
	local fnMapLoginCallback = function (tbMap, nMapId)
		local mapInfo = self.tbPrepareMap[nMapId]
		local tbGame = self:GetFactionData((mapInfo and mapInfo.nFaction) or 0)
		if tbGame then
			tbGame:OnMapLogin(nMapId);
		end
	end
	local fnMapLeaveCallback = function (tbMap,nMapId)
		local mapInfo = self.tbPrepareMap[nMapId]
		local tbGame = self:GetFactionData((mapInfo and mapInfo.nFaction) or 0)
		if tbGame then
			tbGame:OnMapLeave(nMapId);
		end
	end
	local fnOnPlayerTrap = function (tbMap, nMapId, szClassName)
		local mapInfo = self.tbPrepareMap[nMapId]
		local tbGame = self:GetFactionData((mapInfo and mapInfo.nFaction) or 0)
		if tbGame then
			tbGame:OnPlayerTrap(szClassName);
		else
			self:DefaultPlayerTrap(szClassName)
		end
	end

	local fnFreePKMapCreateCallback = function (tbMap, nMapId)
		local mapInfo = self.tbFreePKMap[nMapId]
		local tbGame = self:GetFactionData((mapInfo and mapInfo.nFaction) or 0)
		if tbGame then
			tbGame:OnFreePKMapCreate(nMapId)
		else
			Log("[Error]", "FactionBattle", "Create FreePK map but not found Game Obj", nFaction)
		end
	end
	local fnFreePKMapOnDestroyCallback = function (tbMap, nMapId)
		local mapInfo = self.tbFreePKMap[nMapId]
		local tbGame = self:GetFactionData((mapInfo and mapInfo.nFaction) or 0)
		if tbGame then
			tbGame:OnFreePKMapDestroy(nMapId)
		else
			Log("[Error]", "FactionBattle", "Destroy FreePK map but not found Game Obj", nFaction)
		end
	end
	local fnFreePKMapEnterCallback = function (tbMap, nMapId)
		local mapInfo = self.tbFreePKMap[nMapId]
		local tbGame = self:GetFactionData((mapInfo and mapInfo.nFaction) or 0)
		if tbGame then
			tbGame:OnEnterFreePKMap(nMapId)
		else
			Log("[Error]", "FactionBattle", "Enter FreePK map but not found Game Obj", nFaction)
		end
	end
	local fnFreePKMapLoginCallback = function (tbMap, nMapId)
		local mapInfo = self.tbFreePKMap[nMapId]
		local tbGame = self:GetFactionData((mapInfo and mapInfo.nFaction) or 0)
		if tbGame then
			tbGame:OnLoginFreePKMap(nMapId)
		else
			Log("[Error]", "FactionBattle", "Enter FreePK map but not found Game Obj", nFaction)
		end
	end

	local fnFreePKMapLeaveCallback = function (tbMap,nMapId)
		local mapInfo = self.tbFreePKMap[nMapId]
		local tbGame = self:GetFactionData((mapInfo and mapInfo.nFaction) or 0)
		if tbGame then
			tbGame:OnLeaveFreePKMap(nMapId)
		else
			Log("[Error]", "FactionBattle", "Leave FreePK map but not found Game Obj", nFaction)
		end
	end

	local tbPrepareMap = Map:GetClass(self.PREPARE_MAP_TAMPLATE_ID)
	tbPrepareMap.OnCreate = fnMapCreateCallback;
	tbPrepareMap.OnDestroy = fnMapOnDestroyCallback;
	tbPrepareMap.OnEnter = fnMapEnterCallback;
	tbPrepareMap.OnLogin = fnMapLoginCallback;
	tbPrepareMap.OnLeave = fnMapLeaveCallback;
	tbPrepareMap.OnPlayerTrap = fnOnPlayerTrap;

	local tbFreePKMap = Map:GetClass(self.FREEPK_MAP_TAMPLATE_ID)
	tbFreePKMap.OnCreate = fnFreePKMapCreateCallback;
	tbFreePKMap.OnEnter = fnFreePKMapEnterCallback;
	tbFreePKMap.OnLogin = fnFreePKMapLoginCallback;
	tbFreePKMap.OnLeave = fnFreePKMapLeaveCallback;

	self.tbFreedomPkPoint = {}
	assert(self:LoadFreedomPkPoint(self.FREEDOMPK_POINT, self.tbFreedomPkPoint) == 1);	-- 读取自由PK配置

	self.tbEliminationPoint = {}
	assert(self:LoadGamePoint(self.ELIMINATION_POINT, self.tbEliminationPoint) == 1);	-- 读取淘汰定点配置

	assert(self:LoadBoxPoint() == 1);		-- 读取箱子的刷点
end

function FactionBattle:DefaultPlayerTrap(szClassName)
	if szClassName == "trap_enter" then
		me.SetPosition(unpack(self.FALG_TICK_BACK))
	end
end

-- 开启门派战
function FactionBattle:InitGame(nFaction, nMapId)
	self.tbGame[nFaction] = Lib:NewClass(self.tbBaseFaction);	-- 创建活动数据对象
	self.tbGame[nFaction]:Init(nMapId, nFaction)
	self.tbGame[nFaction]:Start();

	return self.tbGame[nFaction]
end

function FactionBattle:GetFactionData(nFaction)
	if self.tbGame then
		return self.tbGame[nFaction];
	end
end

-- 比赛场地点载入
function FactionBattle:LoadFreedomPkPoint(szFile, tbTable)
	local tbNumColName = {ARENA_ID = 1, X1 = 1, Y1 = 1, X2 = 1, Y2 = 1};
	local tbFileData = Lib:LoadTabFile(szFile, tbNumColName);
	if not tbFileData then
		return 0;
	end
	for nIndex, tbRow in pairs(tbFileData) do
		tbTable[tbRow.ARENA_ID] = tbTable[tbRow.ARENA_ID] or {}
		tbTable[tbRow.ARENA_ID][1] = tbTable[tbRow.ARENA_ID][1] or {}
		table.insert(tbTable[tbRow.ARENA_ID][1], {tbRow.X1, tbRow.Y1});
		tbTable[tbRow.ARENA_ID][2] = tbTable[tbRow.ARENA_ID][2] or {}
		table.insert(tbTable[tbRow.ARENA_ID][2], {tbRow.X2, tbRow.Y2});
	end
	return 1;
end

-- 比赛场地点载入
function FactionBattle:LoadGamePoint(szFile, tbTable)
	local tbNumColName = {ARENA_ID = 1, X1 = 1, Y1 = 1, X2 = 1, Y2 = 1};
	local tbFileData = Lib:LoadTabFile(szFile, tbNumColName);
	if not tbFileData then
		return 0;
	end
	for nIndex, tbRow in pairs(tbFileData) do
		tbTable[tbRow.ARENA_ID] = {}	-- 有重复定点则会覆盖
		tbTable[tbRow.ARENA_ID][1] = {tbRow.X1, tbRow.Y1};
		tbTable[tbRow.ARENA_ID][2] = {tbRow.X2, tbRow.Y2};
	end
	return 1;
end

-- 加载奖励箱子的刷点
function FactionBattle:LoadBoxPoint()
	self.tbBoxPoint = {}
	local tbNumColName = {GROUP = 1, X = 1, Y = 1};
	local tbFileData = Lib:LoadTabFile(self.BOX_POINT, tbNumColName);
	if not tbFileData then
		return 0;
	end
	for nIndex, tbRow in pairs(tbFileData) do
		if not self.tbBoxPoint[tbRow.GROUP] then
			self.tbBoxPoint[tbRow.GROUP] = {}
		end
		local tbPoint = {math.floor(tbRow.X), math.floor(tbRow.Y)};
		table.insert(self.tbBoxPoint[tbRow.GROUP], tbPoint);
	end
	return 1;
end

-- 获取某个混战区的一个随机点
function FactionBattle:GetFreedomPkPoint(nArenaId, i)
	if not self.tbFreedomPkPoint or not self.tbFreedomPkPoint[nArenaId] then
		return;
	end
	local nArenaRangeNum = #self.tbFreedomPkPoint[nArenaId];
	local tbRandomRange = self.tbFreedomPkPoint[nArenaId][MathRandom(nArenaRangeNum)];
	if not tbRandomRange then
		return;
	end

	local nRand = MathRandom(#tbRandomRange)		-- 随机距离
	local nX = tbRandomRange[nRand].nX;
	local nY = tbRandomRange[nRand].nY;
	return nX, nY;
end

-- 获取某个淘汰赛区域的两个定点
function FactionBattle:GetElimFixPoint(nArenaId)
	if self.tbEliminationPoint and self.tbEliminationPoint[nArenaId] then
		return self.tbEliminationPoint[nArenaId];
	end
end

function FactionBattle:AddBoxNpcInPoint(nPointGroup, nMapId, nCount, nNpc)
	if not self.tbBoxPoint[nPointGroup] then
		return;
	end
	local tbPoint = self.tbBoxPoint[nPointGroup]
	local nPointCount = #tbPoint
	for i = 0, nCount - 1 do
		local nIdx = i % nPointCount
		local nPos = MathRandom(1, nPointCount - nIdx);
		local nX, nY = unpack(tbPoint[nPos]);
		FactionBattle:AddBox(nNpc or self.BOX_NPC_ID, nMapId, nX, nY);
		tbPoint[nPos], tbPoint[ nPointCount- nIdx] = tbPoint[nPointCount - nIdx], tbPoint[nPos]
	end
end

function FactionBattle:Close()
	for _,tbGame in pairs(self.tbGame) do
		tbGame:Close()
	end
	Calendar:OnActivityEnd("FactionBattle")
end

function FactionBattle:ShutDown(nMapId, nFaction)
	self.tbGame[nFaction] = nil;

	if Lib:CountTB(self.tbGame) <= 0 then
		--结束时给右下角叹号通知
		local tbMsgData =
		{
			szType = "FactionBattleWinner",
			nTimeOut = GetTime() + FactionBattle.WINNER_NOTIFY_TIME,
			nCurSession = self.tbBattleData.nCurSession,
		};

		local tbPlayer = KPlayer.GetAllPlayer();
		for _, pPlayer in pairs(tbPlayer) do
			if pPlayer.nLevel >= FactionBattle.MIN_LEVEL then
				pPlayer.CallClientScript("Ui:SynNotifyMsg", tbMsgData);
			end
		end

		NewInformation:AddInfomation("FactionBattle", GetTime() + 24*60*60, { self.tbBattleData.nCurSession, self.tbWinnerInfo[self.tbBattleData.nCurSession] })
	end
end

--传入活动地图
function FactionBattle:TrapIn(pPlayer)
    if not Env:CheckSystemSwitch(pPlayer, Env.SW_SwitchMap) then
    	pPlayer.CenterMsg("目前狀態不允許切換地圖")
        return
    end

	local tbGame = self.tbGame[pPlayer.nFaction]
	if not tbGame then
		Dialog:SendBlackBoardMsg(pPlayer, string.format(XT("本門派競技參與人數少於%d人，無法開啟"), FactionBattle.MIN_ATTEND_PLAYER));
		return
	end

	if pPlayer.nMapTemplateId == FactionBattle.PREPARE_MAP_TAMPLATE_ID or
		pPlayer.nMapTemplateId == FactionBattle.FREEPK_MAP_TAMPLATE_ID then

		Dialog:SendBlackBoardMsg(pPlayer, XT("你已經進入活動場地"));
		return
	end

	pPlayer.SetEntryPoint();

	pPlayer.SwitchMap(tbGame.nMapId, unpack(FactionBattle:GetRandomEnterPos()))

	pPlayer.CallClientScript("FactionBattle:OnTrapIn")
end

function FactionBattle:IsInValidMap(pPlayer)
	if  not pPlayer then
		return false
	end
	return pPlayer.nMapTemplateId == FactionBattle.PREPARE_MAP_TAMPLATE_ID or pPlayer.nMapTemplateId == FactionBattle.FREEPK_MAP_TAMPLATE_ID
end

function FactionBattle:GetRandomEnterPos()
	return FactionBattle.ENTER_POS[MathRandom(#FactionBattle.ENTER_POS)]
end

function FactionBattle:AddBox(nNpcID, nMapId, nX, nY)
	local pNpc = KNpc.Add(nNpcID , 1, 0, nMapId, nX, nY);
	if not pNpc then
		return;
	end
	return pNpc;
end

function FactionBattle:OnWinner(nFaction, nPlayerId)
	local pPlayerStay = KPlayer.GetRoleStayInfo(nPlayerId) or {};
	local pKinData = Kin:GetKinById(pPlayerStay.dwKinId or 0) or {};

	self.tbWinnerInfo[self.tbBattleData.nCurSession][nFaction] =
	{
		nPlayerId = nPlayerId,
		nLevel = pPlayerStay.nLevel or 0,
		nFaction = nFaction,
		nPortrait = pPlayerStay.nPortrait or 0,
		nHonorLevel = pPlayerStay.nHonorLevel or 0,
		nFightPower = FightPower:GetFightPower(nPlayerId),
		szName = pPlayerStay.szName or XT("無"),
		szKinName = pKinData.szName or "",
	}
end

function FactionBattle:GetBoxAwardId()
	local nMaxLevel = GetMaxLevel();
	for i=#self.BOX_AWARD_RANDOM_ID,1,-1 do
		if nMaxLevel >= self.BOX_AWARD_RANDOM_ID[i].nLevelLimit then
			return self.BOX_AWARD_RANDOM_ID[i].nAwardId;
		end
	end
end

function FactionBattle:AddBoxAwardRecord(nPlayerId)
	self.tbBoxAwardRecord[nPlayerId] = (self.tbBoxAwardRecord[nPlayerId] or 0) + 1
end

function FactionBattle:GetBoxAwardCount(nPlayerId)
	return self.tbBoxAwardRecord[nPlayerId] or 0;
end

function FactionBattle:OnServerStart()
	FactionBattle:Init()
end

function FactionBattle:Honor2Box(dwRoleId, nGetHonor, tbAwardList)
	local nCurHonor = 0;
	local nBoxCount = 0;
	local nLeftHonor = 0;

	if not tbAwardList then
		return nCurHonor, nBoxCount, nLeftHonor;
	end

	local pAsync = KPlayer.GetAsyncData(dwRoleId);
	if  not pAsync then
		return nCurHonor, nBoxCount, nLeftHonor;
	end

	nCurHonor = pAsync.GetFactionHonor();

	nBoxCount = math.floor((nCurHonor+nGetHonor)/FactionBattle.HONOR_2_BOX_RATE);
	nLeftHonor = math.mod((nCurHonor+nGetHonor), FactionBattle.HONOR_2_BOX_RATE);

	if nBoxCount > 0 then
		table.insert(tbAwardList, {"Item", FactionBattle.HONOR_BOX_ITEM_ID, nBoxCount})
	end

	return nCurHonor, nBoxCount, nLeftHonor;
end
