local tbAct = Activity:GetClass("QingMingAct")
local tbFuben = Fuben:CreateFubenClass(tbAct.szFubenClass);

function tbFuben:OnCreate(nUsePlayerId, nAssistPlayerId, nMapTID)
	self.nUsePlayerId = nUsePlayerId
	self.nAssistPlayerId = nAssistPlayerId
	self.tbJoinPlayer = {nUsePlayerId, nAssistPlayerId}
	self.nMapTID = nMapTID
	self.nAddExpTimes = tbAct.nWorshipTimes
	self.bStart = false
	self.nStartTime = GetTime();
	self:Start();
end

function tbFuben:OnJoin(pPlayer)
	pPlayer.nCanLeaveMapId = self.nMapId;
	self:OnMapState(pPlayer)
end

function tbFuben:OnMapState(pPlayer)
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
	me.nCanLeaveMapId = self.nMapId;
	self:OnMapState(me)
end

function tbFuben:OnFirstJoin(pPlayer)
	local bAssist 
	if self.nAssistPlayerId == pPlayer.dwID then
		bAssist = true
		Activity:OnPlayerEvent(pPlayer, "Act_AssistOk", self.nUsePlayerId, self.nMapTID);
	end
	Log("[QingMingFubenBase] fnOnJoin", pPlayer.szAccount, pPlayer.dwID, pPlayer.nLevel,pPlayer.GetFightPower(), bAssist and "Yes" or "No")
end

function tbFuben:StartWorship(nExeId)
	local szLog = ""
	self.bStart = true
	if self.tbSetting.nStartWorshipUnlockId then
		self:UnLock(self.tbSetting.nStartWorshipUnlockId);
	end
	local nIndex = 0
	local function fnWorship(pPlayer)
		ActionMode:DoForceNoneActMode(pPlayer)
		nIndex = nIndex + 1
        local tbWorshipInfo = self.tbSetting.tbWorshipInfo
        if tbWorshipInfo then
       		local tbPlayerWorshipInfo = tbWorshipInfo[nIndex]
       		if tbPlayerWorshipInfo then
       			local tbPos = tbPlayerWorshipInfo.tbPos
       			if tbPos then
       				pPlayer.SetPosition(unpack(tbPos))
       			end
       			local nDir = tbPlayerWorshipInfo.nDir
       			if nDir then
       				local pNpc = pPlayer.GetNpc()
       				if pNpc then
       					local _, nX, nY = pPlayer.GetWorldPos()
       					pNpc.CastSkill(tbAct.nSitSkill, 1, nX, nY);
       					pNpc.SetDir(nDir)
       				end
       			end
       		end
       	end
       	pPlayer.AddSkillState(tbAct.nEffectId, 1, 0, Env.GAME_FPS * tbAct.nWorshipDelayTime * tbAct.nWorshipTimes);
       	pPlayer.CallClientScript("ChuangGong:BeginChuangGong", pPlayer.dwID, nil, nil, nil, self.nMapTID, nil, "QingMingAct")
       	szLog = szLog .. pPlayer.dwID .. "_" .. pPlayer.szName .. "_"
    end

    self:fnAllPlayer(fnWorship);

    Timer:Register(Env.GAME_FPS * tbAct.nWorshipDelayTime, self.AddPlayerExp, self);

    szLog = szLog .. nExeId
    Log("[QingMingFubenBase] fnStartWorship ", szLog)
end

function tbFuben:AddPlayerExp()
	self.nAddExpTimes = self.nAddExpTimes - 1
	local fnAddExp = function (pPlayer)
		pPlayer.AddExperience(tbAct.nWorshipAddExpRate * pPlayer.GetBaseAwardExp(), Env.LogWay_QingMingAct)
		pPlayer.CallClientScript("ChuangGong:SendOne", self.nAddExpTimes)
	end
	self:fnAllPlayer(fnAddExp);

	if self.nAddExpTimes <= 0 then
		local fnDone = function (pPlayer)
			pPlayer.CallClientScript("Ui:CloseWindow", "ChuangGongPanel")
			local pNpc = pPlayer.GetNpc()
			if pNpc then
				pNpc.RestoreAction();
			end
			pPlayer.RemoveSkillState(tbAct.nEffectId);
		end
		self:fnAllPlayer(fnDone);
		self:FinishWorship()
		return false
	else
		return true
	end
end

function tbFuben:FinishWorship()
	if self.tbSetting.nFinishWorshipUnlockId then
		self:UnLock(self.tbSetting.nFinishWorshipUnlockId);
	end
end

function tbFuben:fnAllPlayer(fnSc, ...)
    for _, nPlayerId in pairs(self.tbJoinPlayer or {}) do
        local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
        if pPlayer and pPlayer.nMapTemplateId == self.nMapTID then
            fnSc(pPlayer, ...);
        end
    end
end

function tbFuben:OnOut(pPlayer)
	if self.nUsePlayerId == pPlayer.dwID then
		Activity:OnPlayerEvent(pPlayer, "Act_SendWorshipAward");
	end
	if self.nAssistPlayerId == pPlayer.dwID then
		Activity:OnPlayerEvent(pPlayer, "Act_SendAssistAward");
	end
	
	pPlayer.CallClientScript("Fuben:ShowLeave");

	local pNpc = pPlayer.GetNpc()
	if pNpc then
		pNpc.RestoreAction();
	end
	pPlayer.RemoveSkillState(tbAct.nEffectId);
	pPlayer.TLogRoundFlow(Env.LogWay_QingMingAct, pPlayer.nMapTemplateId, 0, GetTime() - (self.nStartTime or 0), Env.LogRound_SUCCESS, 0, 0);
end

function tbFuben:OnLeaveMap(pPlayer)
	pPlayer.CallClientScript("Activity.QingMingAct:OnLeaveWorshipMap");
end
