Require("CommonScript/KinBattle/KinBattleCommon.lua");

KinBattle.PreMapClass = KinBattle.PreMapClass or {};
local tbPreMap = KinBattle.PreMapClass;
tbPreMap.nUpdateTime = 3;
function tbPreMap:OnCreate(nMapId)
	KinBattle:OnPreMapCreate(nMapId);
	self.tbPlayerCount = {};
	for nType = 1, KinBattle.nKinBattleTypeCount do
		self.tbPlayerCount[nType] = 0;
	end
end

function tbPreMap:UpdatePlayerInfo()
	local nTime = math.max(KinBattle.nStartPreTime + KinBattle.nWaitTime - GetTime(), 0);
	local tbNumInfo = {};
	for nType = 1, KinBattle.nKinBattleTypeCount do
		tbNumInfo[nType] = string.format("%s / %s", self.tbPlayerCount[nType] or 0, KinBattle.MAX_PLAYER_COUNT);
	end

	local tbPlayer = KPlayer.GetMapPlayer(self.nMapId);
	for _, pPlayer in ipairs(tbPlayer) do
		pPlayer.CallClientScript("Ui:DoLeftInfoUpdate", {tbNumInfo[1], tbNumInfo[2], nTime});
	end

	if #tbPlayer <= 0 or nTime <= 0 then
		self.nTimerId = nil;
		return;
	end

	return true;
end

function tbPreMap:OnEnter()
	Log("[KinBattle] enter pre map ", me.dwID, me.szName, me.nKinBattleType, me.dwKinId);

	local nKinBattleType = me.nKinBattleType;
	if nKinBattleType <= 0 or nKinBattleType > KinBattle.nKinBattleTypeCount then
		return;
	end

	self.tbPlayerCount[nKinBattleType] = self.tbPlayerCount[nKinBattleType] + 1;
	self.nPlayerCount = self.nPlayerCount + 1;

	local nTime = math.max(KinBattle.nStartPreTime + KinBattle.nWaitTime - GetTime(), 0);
	local szInfo1 = string.format("%d / %d", self.tbPlayerCount[1], KinBattle.MAX_PLAYER_COUNT);
	local szInfo2 = string.format("%d / %d", self.tbPlayerCount[2], KinBattle.MAX_PLAYER_COUNT);

	me.CallClientScript("Ui:CloseWindow", "KinBattle");
	me.CallClientScript("Battle:EnterReadyMap", "KinBattle", {szInfo1, szInfo2, nTime});

	if not self.nTimerId and nTime > 0 then
		self.nTimerId = Timer:Register(Env.GAME_FPS * self.nUpdateTime, function () return self:UpdatePlayerInfo(); end);
	end

	Kin:JoinChatRoom(me)
end

function tbPreMap:OnLeave()

	local nKinBattleType = me.nKinBattleType;
	if self.tbPlayerCount[nKinBattleType] <= 0 then
		return;
	end

	self.tbPlayerCount[nKinBattleType] = self.tbPlayerCount[nKinBattleType] - 1;
	self.nPlayerCount = self.nPlayerCount - 1;

	ChatMgr:LeaveKinChatRoom(me);
end

function tbPreMap:DoClearPlayer()
	local tbMapPlayer = KPlayer.GetMapPlayer(self.nMapId);
	for _, pPlayer in pairs(tbMapPlayer) do
		pPlayer.GotoEntryPoint();
	end

	if self.nTimerId then
		Timer:Close(self.nTimerId);
		self.nTimerId = nil;
	end
end

function tbPreMap:MemberJoinKinChatRoom()
	local tbPlayer = KPlayer.GetMapPlayer(self.nMapId)
	for _, pPlayer in ipairs(tbPlayer) do
		Kin:JoinChatRoom(pPlayer)
	end
end

--------------------------------------------------------------------------------------
local tbMap = Map:GetClass(KinBattle.PRE_MAP_ID);
function tbMap:OnCreate(nMapId)
	local tbInst = KinBattle.tbPreMapInstByMapId[nMapId];
	if not tbInst then
		Log("[KinBattle] ERR ?? unknow pre map !! ", nMapId);
		Lib:LogTB(KinBattle.tbPreMapInstByMapId);
		return;
	end

	tbInst:OnCreate(nMapId);
end

function tbMap:OnEnter(nMapId)
	local tbInst = KinBattle.tbPreMapInstByMapId[nMapId];
	if not tbInst then
		Log("[KinBattle] ERR ?? unknow pre map !! ", nMapId);
		return;
	end

	tbInst:OnEnter();
end

function tbMap:OnLeave(nMapId)
	local tbInst = KinBattle.tbPreMapInstByMapId[nMapId];
	if not tbInst then
		return;
	end

	tbInst:OnLeave();
end
