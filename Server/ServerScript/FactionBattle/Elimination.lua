FactionBattle.tbElimination = FactionBattle.tbElimination or {}
local tbElimination = FactionBattle.tbElimination;

function tbElimination:Init(nArea, tbPoint, tbGame)
	self.nArea = nArea
	self.tbPoint = tbPoint;
	self.tbGame = tbGame;
	self.nWinner = 0;
	self.nLoser = 0
	self.tbPlayer = {}
	self.tbPlayer2Idx = {}
	self.tbDeathRegId = {}
	self.nStartTime = GetTime()
end

function tbElimination:ForEach(fnFunction)
	for _, tbInfo in pairs(self.tbPlayer) do
		local pPlayer = KPlayer.GetPlayerObjById(tbInfo.nPlayerId)
		if pPlayer then
			fnFunction(pPlayer)
		end
	end
end

function tbElimination:Start()
	for i, tbPointInfo in pairs(self.tbPoint) do
		local pPlayer = KPlayer.GetPlayerObjById(self.tbPlayer[i].nPlayerId);
		self.tbGame:RecordPlayerPoint(pPlayer);
		pPlayer.SetPosition(unpack(tbPointInfo));
		self:SetGameState(pPlayer);
		pPlayer.RestoreAll();

		local pNpc = pPlayer.GetNpc()
		if pNpc then
			pNpc.StartDamageCounter();
		end

		pPlayer.CallClientScript("FactionBattle:OnEliminationStart", self.tbGame:GetNextStateTime())
	end
	self.nStartTimer = Timer:Register(FactionBattle.ELIMI_PROTECT_TIME * Env.GAME_FPS, self.ChangeFight, self);

	self:SyncLeftInfo()
end

function tbElimination:ChangeFight()
	self.nStartTimer = nil;
	if not self.tbPlayer[1] or not self.tbPlayer[2] then
		return 0;
	end
	local pPlayer1 = KPlayer.GetPlayerObjById(self.tbPlayer[1].nPlayerId);
	local pPlayer2 = KPlayer.GetPlayerObjById(self.tbPlayer[2].nPlayerId);
	if pPlayer1 and pPlayer2 then
		pPlayer1.nFightMode = 1
		pPlayer1.SetPkMode(3, 1)

		pPlayer2.nFightMode = 1
		pPlayer2.SetPkMode(3, 2)
	end
	if not self.nDamageTimer then
		self.nDamageTimer = Timer:Register(Env.GAME_FPS * 5, self.SyncLeftInfo, self);
	end
	return 0;
end

function tbElimination:SetGameState(pPlayer)
	local nPlayerId = pPlayer.dwID;
	-- 非战斗状态, 保护时间过后进入战斗状态
	pPlayer.nFightMode = 0
	--  战场标志（同家族可相互攻击）
	pPlayer.nInBattleState = 1;
	-- 强制退队
	if pPlayer.dwTeamID ~= 0 then
		TeamMgr:QuiteTeam(pPlayer.dwTeamID, pPlayer.dwID);
	end
	
	--广播伤害飘血
	local pNpc = pPlayer.GetNpc();
	if pNpc then
		pNpc.bFlyCharBroad = 1;
	end

	-- 临时重生点
	pPlayer.SetTempRevivePos(pPlayer.nMapId, FactionBattle.tbRevPos[1], FactionBattle.tbRevPos[2])
	
	-- 死亡回调	
	if self.tbDeathRegId[nPlayerId] and self.tbDeathRegId[nPlayerId] ~= 0 then
		PlayerEvent:UnRegister(pPlayer, "OnDeath", self.tbDeathRegId[nPlayerId]);
		self.tbDeathRegId[nPlayerId] = nil
	end
	self.tbDeathRegId[nPlayerId] = PlayerEvent:Register(pPlayer, "OnDeath", self.OnPlayerDeath, self);

	pPlayer.bTempForbitMount = true;
	pPlayer.DoChangeActionMode(Npc.NpcActionModeType.act_mode_none);
end

function tbElimination:RecoverState(pPlayer)
	local nPlayerId = pPlayer.dwID;
	local pNpc = pPlayer.GetNpc()
	if pNpc and pNpc.IsDeath() then
		pPlayer.Revive(1);
	end

	-- 非战斗状态
	pPlayer.nFightMode = 0
	--  战场标志（同家族可相互攻击）
	pPlayer.nInBattleState = 0;

	pPlayer.SetPkMode(0)

	if pNpc then
		pNpc.StopDamageCounter();
		pNpc.bFlyCharBroad = 0;
	end
	
	-- 取消临时重生
	pPlayer.ClearTempRevivePos()
	
	-- 反注销死亡脚本
	if self.tbDeathRegId[nPlayerId] and self.tbDeathRegId[nPlayerId] ~= 0 then
		PlayerEvent:UnRegister(pPlayer, "OnDeath", self.tbDeathRegId[nPlayerId]);
		self.tbDeathRegId[nPlayerId] = nil
	end

	pPlayer.bTempForbitMount = false;
end

function tbElimination:OnPlayerDeath(pKiller)
	self:CheckWin(nil, me.dwID);
	if not self.nCloseTimer then
		self.nCloseTimer = Timer:Register(FactionBattle.END_DELAY * Env.GAME_FPS, self.Close,	self, 1);
	end
end

function tbElimination:Join(pPlayer)
	local nPlayerId = pPlayer.dwID
	if #self.tbPlayer >= 2 then	-- 淘汰赛不允许大于2人
		return;
	end
	table.insert(self.tbPlayer, {nPlayerId = nPlayerId})
	self.tbPlayer2Idx[nPlayerId] = #self.tbPlayer;
	self.tbGame:OnPlayerJoinArea(nPlayerId, self.nArea)
end

function tbElimination:KickOut(pPlayer)
	self:_KickOut(pPlayer)
	if not self.nCloseTimer then
		self.nCloseTimer = Timer:Register(FactionBattle.END_DELAY * Env.GAME_FPS, self.Close, self, 1);
	end
end

function tbElimination:_KickOut(pPlayer)
	if self.tbPlayer2Idx[pPlayer.dwID] then
		local nPlayerId = pPlayer.dwID
		self.tbGame:StopWatchElimination(nPlayerId)
		self.tbGame:OnPlayerLeaveArea(nPlayerId)
		self:CheckWin(nil, nPlayerId);		-- 离场可能导致胜负
		self.tbPlayer[self.tbPlayer2Idx[pPlayer.dwID]] = nil;
		self.tbPlayer2Idx[pPlayer.dwID] = nil
		
		self:RecoverState(pPlayer);
	end
end

function tbElimination:Close(bEarlier)
	-- 踢掉所有人
	self:CheckWin();
	self.tbGame:SetEliminationWinner(self.nArea, self.nWinner, self.nLoser, GetTime() - self.nStartTime)

	local fnKickOutAll = function (pPlayer)
		
		pPlayer.CallClientScript("Ui:CloseWindow", "QYHbattleInfo");
		self.tbGame:SyncLeftInfo(pPlayer);

		self.tbGame:Return2EnterPoint(pPlayer);
		self:_KickOut(pPlayer)

		local pNpc = pPlayer.GetNpc()
		if pNpc and pNpc.IsDeath() then
			pPlayer.Revive(1);
		end
	end
	self:ForEach(fnKickOutAll);
	if self.nStartTimer then
		Timer:Close(self.nStartTimer);
		self.nStartTimer = nil
	end
	if self.nDamageTimer then
		Timer:Close(self.nDamageTimer);
		self.nDamageTimer = nil
	end
	if self.nCloseTimer then
		Timer:Close(self.nCloseTimer);
		self.nCloseTimer = nil
	end

	if bEarlier == 1 then
		self.tbGame:OnElimanationEarlyClose(self.nArea)
	end
	
	return 0
end

function tbElimination:CheckWin(nWinner, nLoser)
	if self.nWinner ~= 0 then
		return;
	end
	if not nWinner and not nLoser then
		local pPlayer1 = KPlayer.GetPlayerObjById(self.tbPlayer[1].nPlayerId);
		local pPlayer2 = KPlayer.GetPlayerObjById(self.tbPlayer[2].nPlayerId);
		if pPlayer1 and pPlayer2 then
			local pNpc1 = pPlayer1.GetNpc()
			local pNpc2 = pPlayer2.GetNpc()
			local tbDamage1 = {nDamage = 0}
			local tbDamage2 = {nDamage = 0}
			if pNpc1 then
				tbDamage1 = pNpc1.GetDamageCounter();
			end
			if pNpc2 then
				tbDamage2 = pNpc2.GetDamageCounter();
			end
			if tbDamage1.nDamage < tbDamage2.nDamage then
				self.nWinner = self.tbPlayer[2].nPlayerId;
			elseif tbDamage1.nDamage > tbDamage2.nDamage then
				self.nWinner = self.tbPlayer[1].nPlayerId
			else	-- 随机胜负
				self.nWinner = self.tbPlayer[MathRandom(1,2)].nPlayerId;
			end
		end
	elseif nWinner then
		self.nWinner = nWinner;
	elseif nLoser then
		if self.tbPlayer[1].nPlayerId == nLoser then
			self.nWinner = self.tbPlayer[2].nPlayerId
		elseif self.tbPlayer[2].nPlayerId == nLoser then
			self.nWinner = self.tbPlayer[1].nPlayerId
		end
	end
	if self.nWinner == self.tbPlayer[1].nPlayerId then
		self.nLoser = self.tbPlayer[2].nPlayerId
	elseif self.nWinner == self.tbPlayer[2].nPlayerId then
		self.nLoser = self.tbPlayer[1].nPlayerId
	end
end

function tbElimination:SyncLeftInfo(pPlayer)

	local tbDamage1 = {}
	local tbDamage2 = {}
	local pPlayer1 = KPlayer.GetPlayerObjById((self.tbPlayer[1] and self.tbPlayer[1].nPlayerId) or 0);
	local pPlayer2 = KPlayer.GetPlayerObjById((self.tbPlayer[2] and self.tbPlayer[2].nPlayerId) or 0);
	if pPlayer1 then
		local pNpc = pPlayer1.GetNpc()
		if pNpc then
			tbDamage1 = pNpc.GetDamageCounter();
		end
	end

	if pPlayer2 then
		local pNpc = pPlayer2.GetNpc()
		if pNpc then
			tbDamage2 = pNpc.GetDamageCounter();
		end
	end

	local fnFunction = function (pPlayer)

		pPlayer.CallClientScript("Player:SetActiveRunTimeData", "QYHbattleInfo", 
					{
						[(pPlayer1 and pPlayer1.dwID) or 0] = tbDamage1.nDamage or 0,
						[(pPlayer2 and pPlayer2.dwID) or 0] = tbDamage2.nDamage or 0,
					});
	end

	if not pPlayer then
		self:ForEach(fnFunction);
	else
		fnFunction(pPlayer)
	end

	return true
end

function tbElimination:SyncWatchInfo(pPlayer)
	if not self.tbPlayer[1] or not self.tbPlayer[2] then
		return
	end

	if pPlayer.dwID == self.tbPlayer[1].nPlayerId or pPlayer.dwID == self.tbPlayer[2].nPlayerId then
		return
	end

	local pPlayer1 = KPlayer.GetPlayerObjById(self.tbPlayer[1].nPlayerId);
	local pPlayer2 = KPlayer.GetPlayerObjById(self.tbPlayer[2].nPlayerId);

	if not pPlayer1 or not pPlayer2 then
		return
	end

	local pNpc1 = pPlayer1.GetNpc();
	local pNpc2 = pPlayer2.GetNpc();

	if not pNpc1 or not pNpc2 then
		return
	end

	pNpc1.AddToForceSyncSet(pPlayer.dwID);
	pNpc2.AddToForceSyncSet(pPlayer.dwID);
	pPlayer.SyncNpc(pNpc1.nId)
	pPlayer.SyncNpc(pNpc2.nId)

	pPlayer.CallClientScript("FactionBattle:OnSyncWatchInfo", {pPlayer1.szName, pNpc1.nId}, {pPlayer2.szName, pNpc2.nId})
end

function tbElimination:StopSyncWatch(pPlayer)
	local pPlayer1 = KPlayer.GetPlayerObjById((self.tbPlayer[1] and self.tbPlayer[1].nPlayerId) or 0);
	local pPlayer2 = KPlayer.GetPlayerObjById((self.tbPlayer[2] and self.tbPlayer[2].nPlayerId) or 0);

	if pPlayer1 then
		local pNpc = pPlayer1.GetNpc();
		if pNpc then
			pNpc.RemoveFromForceSyncSet(pPlayer.dwID);
		end
	end

	if pPlayer2 then
		local pNpc = pPlayer2.GetNpc();
		if pNpc then
			pNpc.RemoveFromForceSyncSet(pPlayer.dwID);
		end
	end
end

function tbElimination:ReLogin(pPlayer)
	pPlayer.CallClientScript("Ui:CloseWindow", "QYHLeftInfo");
	pPlayer.CallClientScript("Ui:OpenWindow", "QYHbattleInfo", self.tbGame:GetNextStateTime());

	if not self.nStartTimer then

		pPlayer.nFightMode = 1;

		if (self.tbPlayer[1] and self.tbPlayer[1].nPlayerId) == pPlayer.dwID then
			pPlayer.SetPkMode(3, 1)
		elseif (self.tbPlayer[2] and self.tbPlayer[2].nPlayerId) == pPlayer.dwID then
			pPlayer.SetPkMode(3, 2)
		end
	end
end