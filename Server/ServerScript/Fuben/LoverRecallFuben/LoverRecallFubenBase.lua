local tbAct = Activity:GetClass("LoverRecallAct")
local tbFuben = Fuben:CreateFubenClass(tbAct.szFubenClass);

function tbFuben:OnCreate(nUsePlayerId, nAssistPlayerId)
	self.tbReviveTimer = {};
	self.nUsePlayerId = nUsePlayerId
	self.nAssistPlayerId = nAssistPlayerId
	self.nStartTime = GetTime();
	self:Start();
end

function tbFuben:OnJoin(pPlayer)
	self:OnMapState(pPlayer)
	pPlayer.CallClientScript("Ui:CloseWindow", "ItemBox");
end

function tbFuben:OnMapState(pPlayer)
	pPlayer.nCanLeaveMapId = self.nMapId;
	pPlayer.CallClientScript("Ui:ChangeUiState", Ui.STATE_MINI_MAP);
	pPlayer.CallClientScript("Ui:OpenWindow", "HomeScreenFuben", "TeamFuben");
	if self.bClose == 1 then
		me.CallClientScript("Fuben:ShowLeave");
	end
	if self.nShowEndTime and self.nShowEndTime > 0 then
		pPlayer.CallClientScript("Fuben:SetEndTime", self.bClose == 1 and 0 or self.nShowEndTime);
	end
end

function tbFuben:OnLogin(bReConnect)
	self:OnMapState(me)
end

function tbFuben:OnFirstJoin(pPlayer)
	if self.nAssistPlayerId == pPlayer.dwID then
		Activity:OnPlayerEvent(pPlayer, "Act_AssistOk", self.nUsePlayerId);
	end
	Log("[LoverRecallFubenBase] fnOnJoin", pPlayer.szAccount, pPlayer.dwID, pPlayer.nLevel, pPlayer.GetFightPower(), self.nAssistPlayerId, self.nUsePlayerId)
end

function tbFuben:OnOut(pPlayer)
	self:DoRevive(pPlayer.dwID, true);
	pPlayer.CallClientScript("Fuben:ShowLeave");
	pPlayer.TLogRoundFlow(Env.LogWay_LoverRecallAct, pPlayer.nMapTemplateId, 0, GetTime() - (self.nStartTime or 0), Env.LogRound_SUCCESS, 0, 0);
end

function tbFuben:OnLeaveMap(pPlayer)
	if self.nUsePlayerId == pPlayer.dwID then
		Activity:OnPlayerEvent(pPlayer, "Act_SendUseMapAward");
	elseif self.nAssistPlayerId == pPlayer.dwID then
		Activity:OnPlayerEvent(pPlayer, "Act_SendAssistAward");
	end
	self:DoRevive(pPlayer.dwID, true);
	pPlayer.CallClientScript("Activity.LoverRecallAct:OnLeaveLoverRecallMap");
end

function tbFuben:OnPlayerDeath()
	local nDelay = 5
	me.CallClientScript("Ui:OpenWindow", "CommonDeathPopup", "AutoRevive", "您將在 %d 秒後復活", nDelay);
	self.tbReviveTimer[me.dwID] = Timer:Register(nDelay * Env.GAME_FPS, self.DoRevive, self, me.dwID);
end

function tbFuben:DoRevive(nPlayerId, bIsOut)
	if bIsOut and self.tbReviveTimer[nPlayerId] then
		Timer:Close(self.tbReviveTimer[nPlayerId]);
	end
	self.tbReviveTimer[nPlayerId] = nil;

	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return;
	end
	pPlayer.Revive(bIsOut and 1 or 0);
end
