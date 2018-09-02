BiWuZhaoQin.BWZQBattle = BiWuZhaoQin.BWZQBattle or {}
local BWZQBattle = BiWuZhaoQin.BWZQBattle

function BWZQBattle:OnCreate()
	self:OnInit()
end

function BWZQBattle:OnInit()
	self.tbPlayer = {}
	self.tbDmgInfo = {{nTotalDmg = 0, nKillCount = 0}, {nTotalDmg = 0, nKillCount = 0}} 		-- 阵营的输出和杀敌数
	self.tbPlayerKill = self.tbPlayerKill or {} 				-- 玩家的连斩数
	self.nStartTime = GetTime();
	self.nSchedulePos = 0
	self.nUpdateDmgTime = nil
end

function BWZQBattle:GetLog()
	return self.nTargetId, self.nPreMapId, self.nConnectIdx, self.nType, self.nFightType, self.nMapId, self.nSchedulePos
end

function BWZQBattle:OnClose()
	self.bStart = nil
	self.nPos = nil
end

function BWZQBattle:OnLeave(pPlayer)
	pPlayer.nInBattleState = 0
	self:ClearState(pPlayer)
	self:UnRegisterEvent(pPlayer)
	pPlayer.CallClientScript("BiWuZhaoQin:OnLeaveArena")
	self:CloseAllTimer()
	Log("BWZQBattle fnOnLeave ",self:GetLog())
end

function BWZQBattle:EndFightForce(pLoser)
	local nLostCame = self.tbPlayer[pLoser.dwID]
	local nWinCamp = nLostCame == 1 and 2 or 1;
    self.tbDmgInfo[nWinCamp].nKillCount = self.tbDmgInfo[nWinCamp].nKillCount + 1;
    self:ClcResult()
end

function BWZQBattle:OnEnter(pPlayer)
	Log("BWZQBattle fnOnEnter ",pPlayer.dwID,pPlayer.szName,self:GetLog())
	if not self.tbPlayer[pPlayer.dwID] then
		self:RegisterEvent(pPlayer)
	end
	pPlayer.nBWZQFightMapId = self.nMapId
	self.tbPlayer[pPlayer.dwID] = Lib:CountTB(self.tbPlayer) + 1
	self:UpdatePlayerUi(pPlayer)
	ActionMode:DoForceNoneActMode(pPlayer)
	pPlayer.nInBattleState = 1
	pPlayer.SetPkMode(0);
	pPlayer.nFightMode = 0;
	if Lib:CountTB(self.tbPlayer) == 2 then
		self.bStart = true
		self:ExecuteSchedule()
	end
	if self.nFightType then
		if self.nFightType == BiWuZhaoQin.FIGHT_TYPE_MAP then
			self.nPos = (self.nPos or 0) + 1
			local tbPos = BiWuZhaoQin.tbTaoTaiEnterPos[self.nPos]
			if tbPos then
				pPlayer.SetPosition(unpack(tbPos))
			end
		elseif self.nFightType == BiWuZhaoQin.FIGHT_TYPE_ARENA then
			local tbPreMapLogic = BiWuZhaoQin:GetPreMapLogic(self.nPreMapId)
			if tbPreMapLogic then
				tbPreMapLogic:RemoveFromWaitList(pPlayer.dwID)
			end
		end
	end
	pPlayer.CallClientScript("BiWuZhaoQin:OnEnterFightMap")
end

function BWZQBattle:ExecuteSchedule()
	self.nMainTimer = nil;
	self.nSchedulePos = (self.nSchedulePos or 0) + 1
	local tbCurSchedule = BiWuZhaoQin.STATE_TRANS[self.nSchedulePos]
	if not tbCurSchedule then
		return
	end
	Log("[BWZQBattle] fnExecuteSchedule", self.nSchedulePos, tbCurSchedule.nSeconds or 0, tbCurSchedule.szDesc or "nil",self:GetLog());
	self.szStateInfo = tbCurSchedule.szDesc;
	self[tbCurSchedule.szFunc](self)
	if tbCurSchedule.nSeconds < 0 then
		return
	end
	if not BiWuZhaoQin.STATE_TRANS[self.nSchedulePos + 1] then --后面没有timer 就断了
		return;
	end
	local function fnSyncFightState(self, pPlayer)
	    self:SyncPlayerLeftInfo(pPlayer);
	    pPlayer.CallClientScript("BiWuZhaoQin:SyncFightState", tbCurSchedule.nSeconds);
	end
	self:ForeachPlayer(fnSyncFightState)
	self.nMainTimer = Timer:Register(Env.GAME_FPS * tbCurSchedule.nSeconds, self.ExecuteSchedule, self)
end

function BWZQBattle:CloseAllTimer()
	self:CloseMainSchedule()
	self:CloseDmgSchedule()
end

function BWZQBattle:CloseMainSchedule()
	if self.nMainTimer then
		Timer:Close(self.nMainTimer)
		self.nMainTimer = nil
	end
end

function BWZQBattle:CloseDmgSchedule()
	if self.nUpdateDmgTime then
		Timer:Close(self.nUpdateDmgTime)
		self.nUpdateDmgTime = nil
	end
end

function BWZQBattle:PlayerReady()

end

function BWZQBattle:ShowTeamInfo(nWinCamp)
	self.tbCurCampInfo = {};
	
	local function fnGetPlayerInfo(self, pPlayer)
		local nCamp = self.tbPlayer[pPlayer.dwID];
		if not nCamp then
			return 
		end
		self.tbCurCampInfo[nCamp] = self.tbCurCampInfo[nCamp] or {};

		local nDamage,nKillCount = 0,0
		if nWinCamp then
			if self.tbDmgInfo[nCamp] then
				if self.tbDmgInfo[nCamp].tbPlayerDmg[pPlayer.dwID] then
					nDamage = self.tbDmgInfo[nCamp].tbPlayerDmg[pPlayer.dwID].nDamage;
				end
				if self.tbDmgInfo[nCamp].tbPlayerKillCount then
					nKillCount = self.tbDmgInfo[nCamp].tbPlayerKillCount[pPlayer.dwID] or 0;
				end
			end
		end


		table.insert(self.tbCurCampInfo[nCamp], {
			szName		= pPlayer.szName,
			nPortrait	= pPlayer.nPortrait,
			nLevel		= pPlayer.nLevel,
			nHonorLevel	= pPlayer.nHonorLevel,
			nFaction	= pPlayer.nFaction,
			nFightPower	= pPlayer.GetFightPower(),
			nDamage = nDamage,
			nKillCount = nKillCount,
		});
	end
	self:ForeachPlayer(fnGetPlayerInfo)

	local function fnShowInfo(self,pPlayer)
		local nCamp = self.tbPlayer[pPlayer.dwID];
		if not nCamp then
			return 
		end
		pPlayer.CallClientScript("BiWuZhaoQin:OnShowTeamInfo", nCamp, self.tbCurCampInfo,nWinCamp);
	end
	self:ForeachPlayer(fnShowInfo)
end

function BWZQBattle:SetPlayerDmgCounter(pPlayer, bStart)
	local pPlayerNpc = pPlayer.GetNpc();
	if bStart then
		pPlayerNpc.StartDamageCounter();
	else
		pPlayerNpc.StopDamageCounter();
	end
end

function BWZQBattle:PlayerAvatar()
	local function fnAvatar(self,pPlayer)
	    local tbAvatarInfo = BiWuZhaoQin.tbAvatar[self.szTimeFrame] or BiWuZhaoQin.tbDefaultAvatar
	    if not Player:ChangePlayer2Avatar(pPlayer, pPlayer.nFaction, tbAvatarInfo.nLevel, tbAvatarInfo.szEquipKey, tbAvatarInfo.szInsetKey, tbAvatarInfo.nStrengthLevel) then
	        Log("BiWuZhaoQin Error!!!!! In ChangePlayer2Avatar" .. pPlayer.dwID .. self.szTimeFrame)
	        pPlayer.CenterMsg("轉換無差別角色失敗",true)
	        pPlayer.ZoneLogout();
	    end
	end

    self:ForeachPlayer(fnAvatar)
end

function BWZQBattle:StartFight()
	local function fnStartFight(self,pPlayer)
		self:SetPlayerDmgCounter(pPlayer,true)
		local nCamp = self.tbPlayer[pPlayer.dwID]
		if nCamp then
			pPlayer.nFightMode = 1;
			pPlayer.SetPkMode(3, nCamp);
		else
			Log("[BWZQBattle] fnStartFight player no camp",pPlayer.dwID,pPlayer.szName,pPlayer.nMapTemplateId,self:GetLog())
		end
	end
	if not self.nUpdateDmgTime then
		self.nUpdateDmgTime = Timer:Register(Env.GAME_FPS * 2, self.UpdateAllPlayerDmg, self);
	end

	self:ForeachPlayer(fnStartFight)
end

function BWZQBattle:UpdatePlayerDmg(pPlayer)
	local nCamp = self.tbPlayer[pPlayer.dwID];
	if not nCamp then
		return;
	end

	self.tbDmgInfo[nCamp].tbPlayerDmg = self.tbDmgInfo[nCamp].tbPlayerDmg or {};
	self.tbDmgInfo[nCamp].tbPlayerDmg[pPlayer.dwID] = self.tbDmgInfo[nCamp].tbPlayerDmg[pPlayer.dwID] or {nDamage = 0};

	local tbLastCounter = self.tbDmgInfo[nCamp].tbPlayerDmg[pPlayer.dwID];
	local tbCounter = pPlayer.GetNpc().GetDamageCounter();
	self.tbDmgInfo[nCamp].tbPlayerDmg[pPlayer.dwID] = tbCounter;
	self.tbDmgInfo[nCamp].nTotalDmg = self.tbDmgInfo[nCamp].nTotalDmg - tbLastCounter.nDamage + tbCounter.nDamage;
end

function BWZQBattle:SyncPlayerLeftInfo(pPlayer)
	local tbDmgInfo = {
		szStateInfo = self.szStateInfo or "--",
		[1] = {nTotalDmg = self.tbDmgInfo[1].nTotalDmg, nKillCount = self.tbDmgInfo[1].nKillCount},
		[2] = {nTotalDmg = self.tbDmgInfo[2].nTotalDmg, nKillCount = self.tbDmgInfo[2].nKillCount},
	};
	pPlayer.CallClientScript("BiWuZhaoQin:SyncPlayerLeftInfo", self.tbPlayer[pPlayer.dwID], tbDmgInfo);
end

function BWZQBattle:UpdateAllPlayerDmg()
	self:ForeachPlayer(self.UpdatePlayerDmg);
	self:ForeachPlayer(self.SyncPlayerLeftInfo);

	return self.bStart;
end

function BWZQBattle:StartCountDown()
	local function fnStartCountDown(self, pPlayer)
		pPlayer.CallClientScript("Ui:OpenWindow", "ReadyGo");
	end
	self:ForeachPlayer(fnStartCountDown)
end

function BWZQBattle:ClearState(pPlayer)
	pPlayer.Revive(1);
	pPlayer.SetPkMode(0);
	pPlayer.RestoreAll();
	pPlayer.nFightMode = 0;
	pPlayer.RemoveSkillState(BiWuZhaoQin.nDeathSkillState);
	self:SetPlayerDmgCounter(pPlayer, false)
end

function BWZQBattle:RegisterEvent(pPlayer)
	self.tbRegisterInfo = self.tbRegisterInfo or {};
	self.tbRegisterInfo[pPlayer.dwID] = {};
	self.tbRegisterInfo[pPlayer.dwID].nOnDeathRegID = PlayerEvent:Register(pPlayer, "OnDeath", function(pKiller) self:OnPlayerDeath(pKiller); end);
end

function BWZQBattle:UnRegisterEvent(pPlayer)
	self.tbRegisterInfo = self.tbRegisterInfo or {};
	if self.tbRegisterInfo[pPlayer.dwID] and self.tbRegisterInfo[pPlayer.dwID].nOnDeathRegID then
		PlayerEvent:UnRegister(pPlayer, "OnDeath", self.tbRegisterInfo[pPlayer.dwID].nOnDeathRegID);
	end
	self.tbRegisterInfo[pPlayer.dwID] = nil;
end

function BWZQBattle:ClcResult()
	self:CloseAllTimer()

	local nCostTime = GetTime() - self.nStartTime;

	self.szStateInfo = "比賽結束";
	self.bStart = false
	self:UpdateAllPlayerDmg();

	local nWinCamp = 1;
	if self.tbDmgInfo[2].nKillCount > self.tbDmgInfo[1].nKillCount or
		(self.tbDmgInfo[2].nKillCount == self.tbDmgInfo[1].nKillCount and self.tbDmgInfo[2].nTotalDmg >= self.tbDmgInfo[1].nTotalDmg) then

		nWinCamp = 2;
	end

	self:ShowTeamInfo(nWinCamp)

	local nWinPlayerId,nLostPlayerId
	for dwID,nCamp in pairs(self.tbPlayer) do
		if nCamp == nWinCamp then
			nWinPlayerId = dwID
		else
			nLostPlayerId = dwID
		end
	end

	if not nWinPlayerId or not nLostPlayerId then
		Log("[BWZQBattle] fnClcResult not player id",nCostTime,nWinCamp,nWinPlayerId or -1,nLostPlayerId or -1)
		return
	end

	local function fnResult(self,pPlayer)
		pPlayer.nBWZQFightMapId = nil
		self:OnLeave(pPlayer)
		local nResult = self.tbPlayer[pPlayer.dwID] == nWinCamp and Env.LogRound_SUCCESS or Env.LogRound_FAIL;
		pPlayer.TLogRoundFlow(Env.LogWay_BiWuZhaoQin, pPlayer.nMapTemplateId, 0, nCostTime, nResult, 0, 0);
		if pPlayer.dwID == nWinPlayerId then
			local szMsg = "恭喜您贏得了比賽，晉級下階段！"
			pPlayer.Msg(szMsg)
			Dialog:SendBlackBoardMsg(pPlayer, szMsg)
		elseif pPlayer.dwID == nLostPlayerId then
			local szMsg = "您輸了，再接再厲！"
			pPlayer.Msg(szMsg)
			Dialog:SendBlackBoardMsg(pPlayer, szMsg)
		end
	end
	
	self:ForeachPlayer(fnResult)
	
	Log("[BWZQBattle] fnClcResult", nCostTime, nWinCamp, nWinPlayerId, nLostPlayerId, self.nTargetId, self.nPreMapId, self.nType)

	BiWuZhaoQin:OnFightClose(self.nPreMapId,self.nMapId)

	BiWuZhaoQin:Report(self.nPreMapId,nWinPlayerId,nLostPlayerId)

	local function fnLeaveArena(self,tbId)
		local tbPreMapLogic = BiWuZhaoQin:GetPreMapLogic(self.nPreMapId)
        for nPos,dwID in ipairs(tbId) do
            local pPlayer = KPlayer.GetPlayerObjById(dwID)
            if pPlayer then
                if self.nFightType == BiWuZhaoQin.FIGHT_TYPE_ARENA then
                	local tbPosInfo = BiWuZhaoQin.tbPos[self.nMapId]
                	if tbPosInfo and tbPosInfo.tbLeavePos and tbPosInfo.tbLeavePos[nPos] then
                		pPlayer.SetPosition(unpack(tbPosInfo.tbLeavePos[nPos]))
                	end
					if tbPreMapLogic then
						tbPreMapLogic:UpdatePlayerUi(pPlayer)
					end
                else
                	pPlayer.SwitchMap(self.nPreMapId,0,0)
                end
            end
        end
        self:OnClose()
    end

    Timer:Register(Env.GAME_FPS * BiWuZhaoQin.nDealyLeaveTime, fnLeaveArena,self, {nWinPlayerId,nLostPlayerId})
end

function BWZQBattle:OnPlayerDeath(pKiller)
	if not self.bStart then
		Log("[BWZQBattle] fnOnPlayerDeath no start",me.dwID,me.szName,me.nMapTemplateId,self:GetLog())
		return
	end
	local nCamp = self.tbPlayer[me.dwID]
	if not nCamp then
		Log("[BWZQBattle] fnOnPlayerDeath no camp",me.dwID,me.szName,me.nMapTemplateId,self:GetLog())
		return
	end
	local nKillCamp = nCamp == 1 and 2 or 1;
	local nKillID,nKillName

	if pKiller then
		local pKillPlayer = pKiller.GetPlayer();
		if pKillPlayer then
			self.tbDmgInfo[nKillCamp].tbPlayerKillCount = self.tbDmgInfo[nKillCamp].tbPlayerKillCount or {};
			self.tbDmgInfo[nKillCamp].tbPlayerKillCount[pKillPlayer.dwID] = (self.tbDmgInfo[nKillCamp].tbPlayerKillCount[pKillPlayer.dwID] or 0) + 1;
			
			self.tbPlayerKill[pKillPlayer.dwID] = (self.tbPlayerKill[pKillPlayer.dwID] or 0) + 1
			
			nKillID = pKillPlayer.dwID
			nKillName = pKillPlayer.szName
		end
	end

	self.tbPlayerKill[me.dwID] = 0
	self.tbDmgInfo[nKillCamp].nKillCount = self.tbDmgInfo[nKillCamp].nKillCount + 1;
	me.Revive(1);
	me.SetPkMode(0);
	me.RestoreAll();
	me.nFightMode = 2;
	me.AddSkillState(BiWuZhaoQin.nDeathSkillState, 1, 0, 10000);
	Log("[BWZQBattle] OnPlayerDeath ",me.dwID,me.szName,nKillID or -1,nKillName or "nil",nCamp,nKillCamp,self:GetLog())
	self:ClcResult();
end

function BWZQBattle:OnPlayerLogin()
	Timer:Register(Env.GAME_FPS * 3, function (self, nPlayerId)
		local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
		if not pPlayer then
			return;
		end
		self:UpdatePlayerUi(pPlayer);
	end, self, me.dwID);
end

function BWZQBattle:ForeachPlayer(fnFunc,...)
	for dwID,_ in pairs(self.tbPlayer) do
		local pPlayer = KPlayer.GetPlayerObjById(dwID)
		if pPlayer then
			Lib:CallBack({fnFunc, self, pPlayer, ...});
		end
	end
end

function BWZQBattle:UpdatePlayerUi(pPlayer)
	local nCamp = self.tbPlayer[pPlayer.dwID]
	if not nCamp then
		Log("[BWZQBattle] UpdatePlayerUi can not find camp",pPlayer.dwID,pPlayer.dwTeamID,pPlayer.szName,pPlayer.nMapTemplateId,self.nArenaId)
		return
	end	
	if self.bStart then 		-- 战斗中
		local nRestTime = 0;
		if self.nMainTimer then
			nRestTime = math.floor(Timer:GetRestTime(self.nMainTimer) / Env.GAME_FPS);
		end
		pPlayer.CallClientScript("BiWuZhaoQin:OnFightingState",nRestTime)
		self:SyncPlayerLeftInfo(pPlayer);
	end
end