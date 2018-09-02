
local tbFuben = Fuben:CreateFubenClass("TestServerFuben");

function tbFuben:OnCreate()
	self.tbReviveTimer = {};

	self:Start();
end

function tbFuben:OnJoin(pPlayer)
	
end

function tbFuben:OnOut(pPlayer)
	self:DoRevive(pPlayer.dwID, true);
end

function tbFuben:OnPlayerDeath()
	self.tbReviveTimer[me.dwID] = Timer:Register(TeamFuben.REVIVE_TIME * Env.GAME_FPS, self.DoRevive, self, me.dwID);
end

function tbFuben:DoRevive(nPlayerId, bCloseTimer)
	if bCloseTimer and self.tbReviveTimer[nPlayerId] then
		Timer:Close(self.tbReviveTimer[nPlayerId]);
	end
	self.tbReviveTimer[nPlayerId] = nil;

	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return;
	end

	pPlayer.Revive(0);
end

function tbFuben:OnLog(...)
	Log(...);
end

function tbFuben:GameWin()
	self:BlackMsg("贏了！！！");
	self:Close();
end

function tbFuben:GameLost()
	self:BlackMsg("輸了！！！");
	self:Close();
end
