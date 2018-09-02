FactionBattle.tbFreedomPK = FactionBattle.tbFreedomPK or {}
local tbFreedomPK = FactionBattle.tbFreedomPK;

function tbFreedomPK:Init(nArea, nMapId, nSorePerKill, tbPoint, tbGame, nOpenCount)
	self.nSorePerKill = nSorePerKill;
	self.tbPoint = tbPoint;
	self.tbGame = tbGame;
	self.nMapId = nMapId;
	self.nArea = nArea;
	self.nOpenCount = nOpenCount;
	self.tbPlayer = {}
	self.nProtectTimerId = nil;
	self.nReviveTimerId = nil;
	self.nStartTime = GetTime()
end

function tbFreedomPK:ForEach(fnFunction)
	for nPlayerId, _ in pairs(self.tbPlayer) do
		local pPlayer = KPlayer.GetPlayerObjById(nPlayerId)
		if pPlayer then
			fnFunction(pPlayer)
		end
	end
end

function tbFreedomPK:Start()
	--这时玩家还在准备场地图
	local tbResult = {}
	local fnSort = function (tbA, tbB)
		return tbA.nScore > tbB.nScore
	end
	for nPlayerId, tbInfo in pairs(self.tbPlayer) do
		local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
		if pPlayer and FactionBattle:IsInValidMap(pPlayer) then
			table.insert(tbResult, {pPlayer = pPlayer, nFightPow = pPlayer.GetFightPower(), nScore = self.tbGame:GetPlayerScore(nPlayerId)})
		end
	end
	
	if self.nOpenCount > 1 then
		table.sort(tbResult, fnSort);
	else
		Lib:SmashTable(tbResult)
	end
	
	local nHalfCount = math.ceil(#tbResult / 2);
	local tbPointNum = { #self.tbPoint[1], #self.tbPoint[2] }
	for nIndex, tbInfo in pairs(tbResult) do
		local pPlayer = tbInfo.pPlayer;
		local nCamp = (nIndex % 2) + 1;

		self.tbPlayer[pPlayer.dwID].nCamp = nCamp
		self.tbGame:OnPlayerJoinArea(pPlayer.dwID, self.nArea)

		local nPointIdx = MathRandom(tbPointNum[nCamp])
		if pPlayer.nMapId == self.nMapId then
			self:SetGameState(pPlayer, true);
		end

		self.tbGame:OnAttend(pPlayer)

		pPlayer.SwitchMap(self.nMapId, unpack(self.tbPoint[nCamp][nPointIdx]));
	end
	
	self.nProtectTimerId = Timer:Register(FactionBattle.FREEDOM_PK_PROTECT_TIME * Env.GAME_FPS, self.ChangeAllFight, self);
	self.nReviveTimerId = Timer:Register(FactionBattle.FREEDOM_PK_REVIVE_TIME * Env.GAME_FPS, self.ReviveAllPlayer, self);
end

function tbFreedomPK:ReviveAllPlayer()
	local function fnRevive(pPlayer)
		local pNpc = pPlayer.GetNpc()
		if pNpc and pNpc.IsDeath() then
			pPlayer.Revive(1);
		end
		pPlayer.RemoveSkillState(1520);
		pPlayer.RestoreAll();
		pPlayer.nFightMode = 1;
	end

	self:ForEach(fnRevive);

	return true;
end

function tbFreedomPK:ChangeAllFight()
	self.nProtectTimerId = nil;

	local fnChangeFight = function (pPlayer)
		self:_ChangeFight(pPlayer)
	end

	self:ForEach(fnChangeFight)
end

function tbFreedomPK:_ChangeFight(pPlayer)
	if pPlayer.nMapId ~= self.nMapId then
		return;
	end
	pPlayer.nFightMode = 1;
	self:SyncLeftInfo(pPlayer);
end

function tbFreedomPK:SetGameState(pPlayer)
	local nPlayerId = pPlayer.dwID;
	local playerInfo = self.tbPlayer[nPlayerId]
	-- 非战斗状态, 保护时间过后进入战斗状态
	if self.nProtectTimerId then
		pPlayer.nFightMode = 0;
	else
		pPlayer.nFightMode = 1;
	end
	pPlayer.nInBattleState = 1;--  战场标志（同家族可相互攻击）
	pPlayer.bForbidChangePk = 1;
	pPlayer.SetPkMode(3, playerInfo.nCamp)

	-- 强制退队
	if pPlayer.dwTeamID ~= 0 then
		TeamMgr:QuiteTeam(pPlayer.dwTeamID, pPlayer.dwID);
	end
	
	-- 死亡回调
	if self.tbPlayer[nPlayerId].nOnDeathRegId ~= 0 then
		PlayerEvent:UnRegister(pPlayer, "OnDeath", self.tbPlayer[nPlayerId].nOnDeathRegId);
		self.tbPlayer[nPlayerId].nOnDeathRegId = 0;
	end
	self.tbPlayer[nPlayerId].nOnDeathRegId = PlayerEvent:Register(pPlayer, "OnDeath", self.OnPlayerDeath, self);
	-- 更新信息面板
	self:SyncLeftInfo(pPlayer);

	pPlayer.bTempForbitMount = true;
	pPlayer.DoChangeActionMode(Npc.NpcActionModeType.act_mode_none);
end

function tbFreedomPK:RecoverState(pPlayer,bNotRecoverFightMode)
	local nPlayerId = pPlayer.dwID;

	local pNpc = pPlayer.GetNpc()
	if pNpc and pNpc.IsDeath() then
		pPlayer.Revive(1);
	end

	pPlayer.RemoveSkillState(1520);
	pPlayer.RestoreAll();
	
	-- 非战斗状态
	if not bNotRecoverFightMode then
		pPlayer.nFightMode = 0;
		pPlayer.nInBattleState = 0;
		pPlayer.bForbidChangePk = 0;
	end
	pPlayer.SetPkMode(0);

	-- 反注销死亡脚本
	if self.tbPlayer[nPlayerId] and self.tbPlayer[nPlayerId].nOnDeathRegId and self.tbPlayer[nPlayerId].nOnDeathRegId ~= 0 then
		PlayerEvent:UnRegister(pPlayer, "OnDeath", self.tbPlayer[nPlayerId].nOnDeathRegId);
		self.tbPlayer[nPlayerId].nOnDeathRegId = 0;
	end

	pPlayer.bTempForbitMount = false;
end

function tbFreedomPK:OnPlayerDeath(pKiller)
	if pKiller then
		local pKillerPlayer = pKiller.GetPlayer();
		if pKillerPlayer then
			self.tbGame:AddPlayerScore(pKillerPlayer.dwID, self.nSorePerKill)
			self.tbGame:AddFreePKCombo(pKillerPlayer.dwID)
		end
	end
	local nPlayerId = me.dwID
	
	if self.tbPlayer[nPlayerId] then
		local nDeathCount = (self.tbPlayer[nPlayerId].nDeathCount or 0) + 1;
		self.tbPlayer[nPlayerId].nDeathCount = nDeathCount;
	end

	--先原地复活，设置隐身不能战斗
	me.Revive(1);
	me.nFightMode = 2;
	me.AddSkillState(1520,1,0,100000);
end

function tbFreedomPK:Join(pPlayer)
	local nPlayerId = pPlayer.dwID
	if not self.tbPlayer[nPlayerId] then
		self.tbPlayer[nPlayerId] = {}
		self.tbGame:RecordPlayerPoint(pPlayer);
	end
end

function tbFreedomPK:KickOut(pPlayer, bNotRecoverFightMode)
	local nPlayerId = pPlayer.dwID
	local tbPlayerInfo = self.tbPlayer[nPlayerId]
	local nNow = GetTime()

	self:RecoverState(pPlayer,bNotRecoverFightMode)
	
	if tbPlayerInfo then
		self.tbGame:OnPlayerLeaveArea(nPlayerId)

		pPlayer.TLogRoundFlow(Env.LogWay_FactionBattle,
				 pPlayer.nMapTemplateId,
				 self.tbGame:GetPlayerScore(pPlayer.dwID),
				 nNow - self.nStartTime,
				 Env.LogRound_SUCCESS ,
				 self.tbGame:GetPlayerSort(pPlayer.dwID),
				 0);

		self.tbPlayer[nPlayerId] = nil;
	end
end

function tbFreedomPK:Close(bKickOut)
	if self.nProtectTimerId then
		Timer:Close(self.nProtectTimerId)
		self.nProtectTimerId = nil
	end

	if self.nReviveTimerId then
		Timer:Close(self.nReviveTimerId)
		self.nReviveTimerId = nil
	end
	
	-- 踢掉所有人
	local fnKickOutAll = function (pPlayer)
		self:KickOut(pPlayer, not bKickOut)
		if bKickOut then
			self.tbGame:Return2EnterPoint(pPlayer);
		end
	end
	self:ForEach(fnKickOutAll);
end

function tbFreedomPK:SyncLeftInfo(pPlayer, bStarted)
	local nOpenCount = self.nOpenCount or 0
	local nStateTime = (bStarted and self.tbGame:GetNextStateTime()) or (self.tbGame:GetCurStateTime()/Env.GAME_FPS)
	local nReviveTime = Timer:GetRestTime(self.nReviveTimerId)/Env.GAME_FPS
	local fnFunction = function (pPlayer)
		pPlayer.CallClientScript("FactionBattle:OnSyncLeftInfo", "FactionBattleFreePK", 
			{
				self.tbGame:GetPlayerScore(pPlayer.dwID),
				self.tbGame:GetPlayerSort(pPlayer.dwID),
				nStateTime,
				nReviveTime,
				nOpenCount,
			});
	end
	
	if not pPlayer then
		self:ForEach(fnFunction);
	else
		fnFunction(pPlayer)
	end
end

function tbFreedomPK:OnEnterMap()
	self.tbGame:NotifyClientEnter(me);
	self:SetGameState(me);
	--KChat.AddPlayerToDynamicChannel(self.tbGame.nChatChannelId,me.dwID);
end

function tbFreedomPK:OnLoginMap()
	me.CallClientScript("FactionBattle:OnEnter");
	self.tbGame:NotifyClientEnter(me);
	self:SetGameState(me);
end

function tbFreedomPK:OnLeaveMap()
	self:KickOut(me);
	--KChat.DelPlayerFromDynamicChannel(self.tbGame.nChatChannelId,me.dwID);
end

function tbFreedomPK:BoardMsgToPlayer(szMsg)
	local fnFunction = function (pPlayer)
		Dialog:SendBlackBoardMsg(pPlayer, szMsg);
	end
	self:ForEach(fnFunction);
end
