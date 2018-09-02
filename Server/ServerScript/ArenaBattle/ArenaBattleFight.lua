ArenaBattle.ArenaBattleFight = ArenaBattle.ArenaBattleFight or {}
local ArenaBattleFight = ArenaBattle.ArenaBattleFight

function ArenaBattleFight:TryStart(nChallengerId)
	self:CloseAllTimer()
	self:Init(nChallengerId)
	self:ForeachPlayer(ArenaBattle.tbForeachType.CHALLENGER, self.Go2Arena, ArenaBattle.tbForeachType.CHALLENGER);
	self:StartSchedule()
end

function ArenaBattleFight:Init(nChallengerId)
	local tbArenaInfo = ArenaBattle:GetArenaInfo(self.nArenaId)
	assert(tbArenaInfo,"arena fight Init cant not find arena info!")

	self.nChallengerId = nChallengerId

	tbArenaInfo.tbCurChallenger = {nChallengerId = self.nChallengerId}

	self.tbDmgInfo = {{nTotalDmg = 0, nKillCount = 0}, {nTotalDmg = 0, nKillCount = 0}} 		-- 阵营的输出和杀敌数

	self.tbPlayerKill = self.tbPlayerKill or {} 				-- 玩家的连斩数

	self.nArenaBattleStartTime = GetTime();

	self.nSchedulePos = nil
end

function ArenaBattleFight:ClearArenaFightData()
	self.tbCampInfo = {}
	self.tbDmgInfo = {}
	self.nArenaBattleStartTime = nil
	self.nArenaManId = nil
	self.nSchedulePos = nil
	self.nChallengerId = nil
end

function ArenaBattleFight:UpdatePlayerDmg(pPlayer)
	local nCamp = self.tbCampInfo[pPlayer.dwID];
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

function ArenaBattleFight:StartSchedule()
	self.bStart = true
	self:ForeachAllPlayer(self.UpdatePlayerUi)
	self:ExecuteSchedule()
	self:ForeachMapPlayer(self.SynArenaState,self.bStart)
	self:StartAllWatch()									
end

function ArenaBattleFight:ExecuteSchedule()
	self:CloseMainSchedule()
	self:CloseSystemPickTimer()
	self:CloseCheckApplyTimer()

	self.nSchedulePos = (self.nSchedulePos or 0) + 1

	local tbCurSchedule = ArenaBattle.STATE_TRANS[self.nSchedulePos]
	if not tbCurSchedule then
		return
	end

	Log("[ArenaBattleFight] ExecuteSchedule", self.nSchedulePos, tbCurSchedule.nSeconds or 0, tbCurSchedule.szDesc or "nil");

	self.szStateInfo = tbCurSchedule.szDesc;
	self[tbCurSchedule.szFunc](self)

	if tbCurSchedule.nSeconds < 0 then
		return
	end

	if not ArenaBattle.STATE_TRANS[self.nSchedulePos + 1] then --后面没有timer 就断了
		return;
	end

	local function fnSyncFightState(self, pPlayer)
	    self:SyncPlayerLeftInfo(pPlayer);
	    pPlayer.CallClientScript("ArenaBattle:SyncFightState", tbCurSchedule.nSeconds);
	end
	self:ForeachAllPlayer(fnSyncFightState)
	
	self.nMainTimer = Timer:Register(Env.GAME_FPS * tbCurSchedule.nSeconds, self.ExecuteSchedule, self)
end

function ArenaBattleFight:CloseSystemPickTimer()
	if self.nSystemPickTimer then
		Timer:Close(self.nSystemPickTimer)
		self.nSystemPickTimer = nil
	end
end

function ArenaBattleFight:CloseAllTimer()
	self:CloseSystemPickTimer()
	self:CloseMainSchedule()
	self:CloseCheckApplyTimer()
	self:CloseDmgTimer()
end

function ArenaBattleFight:CloseMainSchedule()
	if self.nMainTimer then
		Timer:Close(self.nMainTimer)
		self.nMainTimer = nil
	end
end

function ArenaBattleFight:CloseDmgTimer()
	if self.nUpdateDmgTime then
		Timer:Close(self.nUpdateDmgTime);
		self.nUpdateDmgTime = nil;
	end
end

function ArenaBattleFight:CheckApply()
	if ArenaBattle:GetApplyData(self.nArenaId,1)[1] then
		if not self.nSystemPickTimer then
			self:WaitChooseChalleger()
		end
	else
		if self.nSystemPickTimer then
			self:CloseSystemPickTimer()
			local function fnAutoChooseStop(self,pPlayer)
				pPlayer.CallClientScript("ArenaBattle:OnAutoChooseStop")
			end
			self:ForeachPlayer(ArenaBattle.tbForeachType.ARENA_MAN,fnAutoChooseStop)
		end
	end
	return true
end

function ArenaBattleFight:CloseCheckApplyTimer()
	if self.CheckApplyTimer then
		Timer:Close(self.CheckApplyTimer)
		self.CheckApplyTimer = nil
	end
end

-- 每两秒检查是否有挑战者申请
function ArenaBattleFight:WaiteChallenger()
	self:CloseAllTimer()
	if not self.CheckApplyTimer then
		self.CheckApplyTimer = Timer:Register(Env.GAME_FPS * ArenaBattle.nCheckApplyTime, self.CheckApply, self)
	end
	self.szStateInfo = "等待挑戰者..."

	local function fnWaitState(self,pPlayer)
		pPlayer.nFightMode = 0;
		self:UpdatePlayerUi(pPlayer)
	end
	self:ForeachPlayer(ArenaBattle.tbForeachType.ARENA_MAN,fnWaitState)
end

function ArenaBattleFight:WaitChooseChalleger()
	self:CloseSystemPickTimer()
	if not self.nSystemPickTimer then
		self.nSystemPickTimer = Timer:Register(Env.GAME_FPS * ArenaBattle.nWaitChooseChallegerTime, self.AutoChoose, self)
	end
	self.szStateInfo = "請選擇挑戰者："
	local function fnShowWaitUi(self,pPlayer)
		self:UpdatePlayerUi(pPlayer);
	end
	self:ForeachPlayer(ArenaBattle.tbForeachType.ARENA_MAN,fnShowWaitUi)
end

function ArenaBattleFight:AutoChoose()
	self:CloseCheckApplyTimer()
	self.nSystemPickTimer = nil
	local bRet = ArenaBattle:AutoPickChallenger(self.nArenaId)
	if not bRet then
		self:WaiteChallenger()
		Log("[ArenaBattleFight] AutoChoose fail",self.nArenaId or -1)
	end
end

function ArenaBattleFight:KickOutNotice(nCamp,szMsg,nTeamId)
	if not nCamp or not szMsg or szMsg == "" then
		return
	end

	ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.Team, szMsg, nTeamId);

	local function fnKickOutNotice(self,pPlayer,szMsg)
		pPlayer.CenterMsg(szMsg)
	end
	self:ForeachPlayer(nCamp,fnKickOutNotice,szMsg)
end

function ArenaBattleFight:OnArenaManChange(nPlayerID,bUnderArena)
	self.nArenaManId = nPlayerID
	if bUnderArena then
		local function fnTurnArenaManDirect(self,pPlayer,nCamp)
			self:Go2Arena(pPlayer,nCamp)
			if self.tbCampInfo[pPlayer.dwID] then
				pPlayer.CallClientScript("ArenaBattle:TurnArenaManDirect")
			end
		end
		self:ForeachPlayer(ArenaBattle.tbForeachType.ARENA_MAN, fnTurnArenaManDirect, ArenaBattle.tbForeachType.ARENA_MAN);
	end
	self:WaiteChallenger()
end

function ArenaBattleFight:Go2Arena(pPlayer,nCamp)
	if not nCamp or (nCamp ~= ArenaBattle.tbForeachType.ARENA_MAN and nCamp ~= ArenaBattle.tbForeachType.CHALLENGER) then
		pPlayer.CenterMsg("找不到陣營");
		Log("[ArenaBattleFight] Go2Arena fail",pPlayer.dwID,pPlayer.szName,pPlayer.nMapTemplateId,nCamp or -1,self.nArenaManId or -1,self.nChallengerId or -1)
		return
	end
	local tbCampEnterPos = self.tbAllPos.tbEnterPos and self.tbAllPos.tbEnterPos[nCamp]
	local nPos = tbCampEnterPos and MathRandom(#tbCampEnterPos) or 0
	local tbPos = tbCampEnterPos[nPos]

	if tbPos then
		if not ArenaBattle:CheckValidMap(pPlayer) then
			if pPlayer.dwTeamID > 0 then
				self:KickOutNotice(nCamp,string.format("「%s」不在比武場，自動退出隊伍",pPlayer.szName),pPlayer.dwTeamID)
				TeamMgr:QuiteTeam(pPlayer.dwTeamID, pPlayer.dwID)
			end
			return
		end
		self.tbCampInfo = self.tbCampInfo or {}
		self.tbCampInfo[pPlayer.dwID] = nCamp
		self:OnEnter(pPlayer,tbPos)
		pPlayer.CallClientScript("ArenaBattle:Go2Arena")
		Log("[ArenaBattleFight] Go2Arena ",self.nArenaId or -1,pPlayer.dwID,pPlayer.szName,pPlayer.dwTeamID,nCamp,tbPos[1] or 0,tbPos[2] or 0)
	else
		pPlayer.CenterMsg("資料異常，請聯繫客服！");
		Log("[ArenaBattleFight] Go2Arena fail",pPlayer.szName,pPlayer.dwID,pPlayer.nMapTemplateId,nCamp,self.nArenaId or -1,self.nArenaManId or -1,self.nChallengerId or -1)
	end
end

function ArenaBattleFight:OnEnter(pPlayer,tbPos)
	pPlayer.bForbidTeamOp = true
	Env:SetSystemSwitchOff(pPlayer, Env.SW_All)
	pPlayer.nFightMode = 0;
	pPlayer.SetPkMode(0);
	pPlayer.SetPosition(unpack(tbPos));
	ActionMode:DoForceNoneActMode(pPlayer)
	self:RegisterEvent(pPlayer)
	ArenaBattle:ClearOtherWaitWatch(0,pPlayer.dwID) 							-- 强制移除观战列表
	ArenaBattle:RemoveAllApply(pPlayer) 										-- 移除所有申请列表
end

function ArenaBattleFight:RegisterEvent(pPlayer)
	self.tbRegisterInfo = self.tbRegisterInfo or {};
	self.tbRegisterInfo[pPlayer.dwID] = {};
	self.tbRegisterInfo[pPlayer.dwID].nOnDeathRegID = PlayerEvent:Register(pPlayer, "OnDeath", function(pKiller) self:OnPlayerDeath(pKiller); end);
	self.tbRegisterInfo[pPlayer.dwID].nOnLogoutRegID = PlayerEvent:Register(pPlayer, "OnLogout", function() self:OnPlayerLogout(); end);
	self.tbRegisterInfo[pPlayer.dwID].nOnLoginRegID = PlayerEvent:Register(pPlayer, "OnLogin", function() self:OnPlayerLogin(); end);
	self.tbRegisterInfo[pPlayer.dwID].nOnReConnectRegID = PlayerEvent:Register(pPlayer, "OnReConnect", function() self:OnPlayerLogin(); end);
	self.tbRegisterInfo[pPlayer.dwID].nOnTeamCaptainChangedRegID = PlayerEvent:Register(pPlayer, "OnTeamCaptainChanged", function(nOldCaptainID,nNewCaptainID) self:UpdateArenaCaptainData(nOldCaptainID,nNewCaptainID); end);
end

-- 玩家在台上掉线自动转让队长的时候更新
function ArenaBattleFight:UpdateArenaCaptainData(nOldCaptainID,nNewCaptainID)

	local tbArenaInfo = ArenaBattle:GetArenaInfo(self.nArenaId)

	if tbArenaInfo and self.nArenaManId and self.nArenaManId == nOldCaptainID then
		tbArenaInfo.tbArenaMan.nArenaManId = nNewCaptainID
		self.nArenaManId = nNewCaptainID
	elseif tbArenaInfo and self.nChallengerId and self.nChallengerId == nOldCaptainID then
		tbArenaInfo.tbCurChallenger.nChallengerId = nNewCaptainID
		self.nChallengerId = nNewCaptainID
	else
		Log("[ArenaBattleFight] UpdateArenaCaptainData error !",nOldCaptainID,nNewCaptainID,self.nArenaId,self.nArenaManId,self.nChallengerId)
	end
end

function ArenaBattleFight:UnRegisterEvent(pPlayer)
	if not self.tbRegisterInfo then
		Log("[ArenaBattleFight] UnRegisterEvent fail no tbRegisterInfo",self.nArenaId or -1,pPlayer.dwID,pPlayer.szName,pPlayer.nMapTemplateId,pPlayer.dwTeamID)
		return 
	end
	if self.tbRegisterInfo[pPlayer.dwID] and self.tbRegisterInfo[pPlayer.dwID].nOnDeathRegID then
		PlayerEvent:UnRegister(pPlayer, "OnDeath", self.tbRegisterInfo[pPlayer.dwID].nOnDeathRegID);
	end
	if self.tbRegisterInfo[pPlayer.dwID] and self.tbRegisterInfo[pPlayer.dwID].nOnLogoutRegID then
		PlayerEvent:UnRegister(pPlayer, "OnLogout", self.tbRegisterInfo[pPlayer.dwID].nOnLogoutRegID);
	end
	if self.tbRegisterInfo[pPlayer.dwID] and self.tbRegisterInfo[pPlayer.dwID].nOnLoginRegID then
		PlayerEvent:UnRegister(pPlayer, "OnLogin", self.tbRegisterInfo[pPlayer.dwID].nOnLoginRegID);
	end
	if self.tbRegisterInfo[pPlayer.dwID] and self.tbRegisterInfo[pPlayer.dwID].nOnReConnectRegID then
		PlayerEvent:UnRegister(pPlayer, "OnReConnect", self.tbRegisterInfo[pPlayer.dwID].nOnReConnectRegID);
	end
	if self.tbRegisterInfo[pPlayer.dwID] and self.tbRegisterInfo[pPlayer.dwID].nOnTeamCaptainChangedRegID then
		PlayerEvent:UnRegister(pPlayer, "OnTeamCaptainChanged", self.tbRegisterInfo[pPlayer.dwID].nOnTeamCaptainChangedRegID);
	end
	self.tbRegisterInfo[pPlayer.dwID] = nil;
end

function ArenaBattleFight:OnLeave(pPlayer,bKick)
	local nCamp = self.tbCampInfo and self.tbCampInfo[pPlayer.dwID]

	pPlayer.bForbidTeamOp = nil
	Env:SetSystemSwitchOn(pPlayer, Env.SW_All);
	if self.tbPlayerKill then
		self.tbPlayerKill[pPlayer.dwID] = nil
	end
	self:ClearState(pPlayer)
	self:OnOut(pPlayer)
	self:UnRegisterEvent(pPlayer)

	local pNpc = pPlayer.GetNpc();
	if pNpc then
		pNpc.ClearForceSyncSet()
	end

	pPlayer.CallClientScript("ArenaBattle:OnPlayerLeave")
	Log("[ArenaBattleFight] OnLeave ",self.nArenaId or -1,pPlayer.dwID,pPlayer.szName,pPlayer.dwTeamID,bKick and 1 or 0,self.bStart and 1 or 0,nCamp or -1)

	if not bKick then
		self:CheckResult()
	end
end

function ArenaBattleFight:OnOut(pPlayer)
	local tbLeavePos = self.tbAllPos.tbLeavePos
	local nCamp = self.tbCampInfo and self.tbCampInfo[pPlayer.dwID]
	local tbPos = ArenaBattle.defaultLeavePos

	if nCamp and tbLeavePos and tbLeavePos[nCamp] then
		local nPos = MathRandom(#tbLeavePos[nCamp])
		tbPos = tbLeavePos[nCamp][nPos]
	end
	pPlayer.SetPosition(unpack(tbPos));
	self.tbCampInfo[pPlayer.dwID] = nil
end

function ArenaBattleFight:ClearState(pPlayer)
	pPlayer.Revive(1);
	pPlayer.SetPkMode(0);
	pPlayer.RestoreAll();
	pPlayer.nFightMode = 0;
	pPlayer.RemoveSkillState(ArenaBattle.nDeathSkillState);
	self:SetPlayerDmgCounter(pPlayer, false)
end

function ArenaBattleFight:ShowTeamInfo(nWinCamp)

	self.tbCurCampInfo = {};
	
	local function fnGetPlayerInfo(self, pPlayer)
		local nCamp = self.tbCampInfo[pPlayer.dwID];
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
	self:ForeachAllPlayer(fnGetPlayerInfo)

	local function fnShowInfo(self,pPlayer)
		local nCamp = self.tbCampInfo[pPlayer.dwID];
		if not nCamp then
			return 
		end
		pPlayer.CallClientScript("ArenaBattle:OnShowTeamInfo", nCamp, self.tbCurCampInfo,nWinCamp);
	end
	self:ForeachAllPlayer(fnShowInfo)
end

function ArenaBattleFight:StartCountDown()
	local function fnStartCountDown(self, pPlayer)
		pPlayer.CallClientScript("Ui:OpenWindow", "ReadyGo");
	end
	self:ForeachAllPlayer(fnStartCountDown)
end

function ArenaBattleFight:StartFight()
	
	local function fnStartFight(self,pPlayer)
		self:SetPlayerDmgCounter(pPlayer,true)
		local nCamp = self.tbCampInfo[pPlayer.dwID]
		if nCamp then
			pPlayer.nFightMode = 1;
			pPlayer.SetPkMode(3, nCamp);
		else
			Log("[ArenaBattleFight] StartFight player no camp",pPlayer.dwID,pPlayer.szName,pPlayer.nMapTemplateId,self.nArenaId)
		end
	end
	if not self.nUpdateDmgTime then
		self.nUpdateDmgTime = Timer:Register(Env.GAME_FPS * 2, self.UpdateAllPlayerDmg, self);
	end

	self:ForeachAllPlayer(fnStartFight)
end

function ArenaBattleFight:ClearCamp(nCamp)
	if self.tbCampInfo then
		for nPlayerId,nC in pairs(self.tbCampInfo) do
			if nC == nCamp then
				self.tbCampInfo[nPlayerId] = nil
			end
		end
	end
end

function ArenaBattleFight:ClcResult()
	local bGameStart = self.bStart 					-- 比赛开始后对方离开才会给自动获胜提示

	local nCostTime = self.nArenaBattleStartTime and (GetTime() - self.nArenaBattleStartTime) or 0 ;

	self.szStateInfo = "比賽結束";				

	self.bStart = false

	self:ForeachMapPlayer(self.SynArenaState,self.bStart)

	local tbArenaFight = ArenaBattle:GetArenaFight(self.nArenaId)

	local function fnSetCamp(self,pPlayer,nCamp)
		self.tbCampInfo = self.tbCampInfo or {}
		self.tbCampInfo[pPlayer.dwID] = nCamp
	end

	local function fnSuccessTip(self,pPlayer)
		Dialog:SendBlackBoardMsg(pPlayer, "恭喜成為擂主");
	end	

	local bAutoWin
	local nArenaManCampNum = self:GetCampMemberNum(ArenaBattle.tbForeachType.ARENA_MAN)
	local nChallengeCampNum = self:GetCampMemberNum(ArenaBattle.tbForeachType.CHALLENGER)
	if nArenaManCampNum == 0 and nChallengeCampNum == 0 then
		self:CloseAllTimer()
		Lib:CallBack({ArenaBattle.ArenaManChangeNotice,ArenaBattle,self.nArenaId});
		self:ClearArenaFightData()
		ArenaBattle:ResetArenaInfo(self.nArenaId)
		Log("[ArenaBattleFight] ClcResult Reset Arena",self.nArenaId or -1)
		return
	elseif nArenaManCampNum == 0 then
		if tbArenaFight and bGameStart then 			-- 比赛开始后才算自动赢
			Lib:CallBack({tbArenaFight.SendAutoWinTip,tbArenaFight,ArenaBattle.tbForeachType.CHALLENGER});
			Lib:CallBack({tbArenaFight.SendResultTip,tbArenaFight,ArenaBattle.tbForeachType.CHALLENGER});
			self:ForeachPlayer(ArenaBattle.tbForeachType.CHALLENGER,fnSuccessTip)
		end
		self:ClearCamp(ArenaBattle.tbForeachType.ARENA_MAN)
		self:ForeachPlayer(ArenaBattle.tbForeachType.CHALLENGER,fnSetCamp,ArenaBattle.tbForeachType.ARENA_MAN) 	-- 重置擂主阵营		
		ArenaBattle:OnArenaManChange(self.nArenaId,self.nChallengerId) 											-- 重置擂主
		bAutoWin = true
	elseif nChallengeCampNum == 0 then
		if tbArenaFight and bGameStart then 
			Lib:CallBack({tbArenaFight.SendAutoWinTip,tbArenaFight,ArenaBattle.tbForeachType.ARENA_MAN});
			Lib:CallBack({tbArenaFight.SendResultTip,tbArenaFight,ArenaBattle.tbForeachType.ARENA_MAN});
			self:ForeachPlayer(ArenaBattle.tbForeachType.ARENA_MAN,fnSuccessTip)
		end
		bAutoWin = true
	end	

	if bAutoWin then
		if bGameStart then
			self:CloseAllTimer()
			self:ClearChallenger()
			self:WaiteChallenger()
			self:StopAllWatch()
			self:ForeachPlayer(ArenaBattle.tbForeachType.ARENA_MAN,self.ClearState)
			Log("[ArenaBattleFight] ClcResult auto",nCostTime,self.nArenaId,nArenaManCampNum,nChallengeCampNum,self.nArenaManId or -1,self.nChallengerId or -1)
		end
		return
	end
	self:CloseAllTimer()
	self:UpdateAllPlayerDmg();

	local nWinCamp = ArenaBattle.tbForeachType.ARENA_MAN
	if self.tbDmgInfo[ArenaBattle.tbForeachType.CHALLENGER].nKillCount > self.tbDmgInfo[ArenaBattle.tbForeachType.ARENA_MAN].nKillCount or
		(self.tbDmgInfo[ArenaBattle.tbForeachType.CHALLENGER].nKillCount == self.tbDmgInfo[ArenaBattle.tbForeachType.ARENA_MAN].nKillCount and self.tbDmgInfo[ArenaBattle.tbForeachType.CHALLENGER].nTotalDmg > self.tbDmgInfo[ArenaBattle.tbForeachType.ARENA_MAN].nTotalDmg) then

		nWinCamp = ArenaBattle.tbForeachType.CHALLENGER;
	end

	self:ShowTeamInfo(nWinCamp)

	
	if tbArenaFight then
		Lib:CallBack({tbArenaFight.SendResultTip,tbArenaFight,nWinCamp});
	end
	
	if nWinCamp == ArenaBattle.tbForeachType.ARENA_MAN then
		self:ForeachPlayer(ArenaBattle.tbForeachType.CHALLENGER,self.OnLeave,true)		
		self:WaiteChallenger()
	else
		self:ForeachPlayer(ArenaBattle.tbForeachType.ARENA_MAN,self.OnLeave,true)
		self:ForeachPlayer(ArenaBattle.tbForeachType.CHALLENGER,fnSetCamp,ArenaBattle.tbForeachType.ARENA_MAN) 	-- 重置擂主阵营	
		ArenaBattle:OnArenaManChange(self.nArenaId,self.nChallengerId)
	end

	self:ClearCamp(ArenaBattle.tbForeachType.CHALLENGER) 					 -- 以防万一最后再清理一遍
	self:ClearChallenger()
	self:StopAllWatch()
	self:ForeachPlayer(ArenaBattle.tbForeachType.ARENA_MAN,self.ClearState)
	self:ForeachPlayer(ArenaBattle.tbForeachType.ARENA_MAN,fnSuccessTip)
	Log("[ArenaBattleFight] ClcResult",nCostTime,self.nArenaId,nArenaManCampNum,nChallengeCampNum,self.nArenaManId or -1,self.nChallengerId or -1,nWinCamp)
end

function ArenaBattleFight:SendAutoWinTip(nCamp)
	if not nCamp then
		return
	end
	local function fnAutoWinTip(self,pPlayer)
		pPlayer.CenterMsg("對手離開擂臺，自動獲勝。",true)
	end
	self:ForeachPlayer(nCamp,fnAutoWinTip)
end

function ArenaBattleFight:SendResultTip(nWinCamp)
	if not nWinCamp then
		return
	end

	local szTip = string.format("%d號擂臺",tonumber(self.nArenaId))
	local nWinnerId

	if nWinCamp == ArenaBattle.tbForeachType.ARENA_MAN then
		nWinnerId = self.nArenaManId
	else
		nWinnerId = self.nChallengerId
	end

	local pPlayer = KPlayer.GetPlayerObjById(nWinnerId or 0)
	if pPlayer then
		if pPlayer.dwTeamID > 0 then
			szTip = szTip ..string.format("「%s」所帶領的隊伍獲勝！",pPlayer.szName)
		else
			szTip = szTip ..string.format("「%s」獲勝！",pPlayer.szName)
		end
	end

	KPlayer.MapBoardcastScript(ArenaBattle.nArenaMapId, "ArenaBattle:SendResultTip",szTip)
end

function ArenaBattleFight:ClearChallenger()
	self.nChallengerId = nil
	ArenaBattle:ClearChallenger(self.nArenaId)
end

function ArenaBattleFight:ForeachAllPlayer(fnFunc,...)
	self:ForeachPlayer(ArenaBattle.tbForeachType.ARENA_MAN,fnFunc,...)
	self:ForeachPlayer(ArenaBattle.tbForeachType.CHALLENGER,fnFunc,...)
end

function ArenaBattleFight:SyncPlayerLeftInfo(pPlayer)
	local tbDmgInfo = {
		szStateInfo = self.szStateInfo or "--",
		[ArenaBattle.tbForeachType.ARENA_MAN] = {nTotalDmg = self.tbDmgInfo[ArenaBattle.tbForeachType.ARENA_MAN].nTotalDmg, nKillCount = self.tbDmgInfo[ArenaBattle.tbForeachType.ARENA_MAN].nKillCount},
		[ArenaBattle.tbForeachType.CHALLENGER] = {nTotalDmg = self.tbDmgInfo[ArenaBattle.tbForeachType.CHALLENGER].nTotalDmg, nKillCount = self.tbDmgInfo[ArenaBattle.tbForeachType.CHALLENGER].nKillCount},
	};
	pPlayer.CallClientScript("ArenaBattle:SyncPlayerLeftInfo", self.tbCampInfo[pPlayer.dwID], tbDmgInfo);
end

function ArenaBattleFight:UpdatePlayerUi(pPlayer)
	local nCamp = self.tbCampInfo[pPlayer.dwID]
	if not nCamp then
		Log("[ArenaBattleFight] UpdatePlayerUi can not find camp",pPlayer.dwID,pPlayer.dwTeamID,pPlayer.szName,pPlayer.nMapTemplateId,self.nArenaId)
		return
	end	
	if not ArenaBattle:CheckValidMap(pPlayer) then
		Log("[ArenaBattleFight] UpdatePlayerUi can invalid map",pPlayer.dwID,pPlayer.dwTeamID,pPlayer.szName,pPlayer.nMapTemplateId,self.nArenaId)
		return
	end
	if self.bStart then 		-- 战斗中
		local nRestTime = 0;
		if self.nMainTimer then
			nRestTime = math.floor(Timer:GetRestTime(self.nMainTimer) / Env.GAME_FPS);
		end
		pPlayer.CallClientScript("ArenaBattle:OnFightingState",nRestTime)
		self:SyncPlayerLeftInfo(pPlayer);
	elseif not self.bStart and nCamp == ArenaBattle.tbForeachType.ARENA_MAN then
		if self.nSystemPickTimer then 													-- 等待挑选挑战者
			local nPickRestTime = math.floor(Timer:GetRestTime(self.nSystemPickTimer) / Env.GAME_FPS);
			pPlayer.CallClientScript("ArenaBattle:WaitingChooseState",nPickRestTime)
		else
			pPlayer.CallClientScript("ArenaBattle:OnWaitingState")
		end
	end
end

function ArenaBattleFight:UpdateAllPlayerDmg()
	self:ForeachAllPlayer(self.UpdatePlayerDmg);
	self:ForeachAllPlayer(self.SyncPlayerLeftInfo);

	return self.bStart;
end

function ArenaBattleFight:SetPlayerDmgCounter(pPlayer, bStart)
	local pPlayerNpc = pPlayer.GetNpc();
	if bStart then
		pPlayerNpc.StartDamageCounter();
	else
		pPlayerNpc.StopDamageCounter();
	end
end

function ArenaBattleFight:CheckCampMemberNum()
	if self:GetCampMemberNum(ArenaBattle.tbForeachType.ARENA_MAN) <= 0 then
		return ArenaBattle.tbForeachType.ARENA_MAN
	elseif self:GetCampMemberNum(ArenaBattle.tbForeachType.CHALLENGER) <= 0 then
		return ArenaBattle.tbForeachType.CHALLENGER
	end
end

function ArenaBattleFight:GetCampMemberNum(nCamp)
	local nNumber = 0
	if self.tbCampInfo then
		for _,nC in pairs(self.tbCampInfo) do
			if nC == nCamp then
				nNumber = nNumber + 1
			end
		end
	end
	return nNumber
end

function ArenaBattleFight:CheckResult()
	local bIsFinish = true;

	if not self:CheckCampMemberNum() then
		local function fnCheckDeath(self, pPlayer)
		local pNpc = pPlayer.GetNpc();
			if not bIsFinish or pNpc.GetSkillState(TeamBattle.nDeathSkillState) then
				return;
			end
			bIsFinish = false;
		end
		self:ForeachPlayer(ArenaBattle.tbForeachType.ARENA_MAN,fnCheckDeath)
		if not bIsFinish then
			bIsFinish = true;
			self:ForeachPlayer(ArenaBattle.tbForeachType.CHALLENGER,fnCheckDeath)
		end
	end
	if not bIsFinish then
		return;
	end
	self:ClcResult()
end

function ArenaBattleFight:ForeachPlayer(nForeachType,fnFunc,...)
	local tbArenaInfo = ArenaBattle:GetArenaInfo(self.nArenaId)
	local nPlayerID
	if nForeachType == ArenaBattle.tbForeachType.ARENA_MAN then
		nPlayerID = tbArenaInfo.tbArenaMan and tbArenaInfo.tbArenaMan.nArenaManId
	elseif nForeachType == ArenaBattle.tbForeachType.CHALLENGER then
		nPlayerID = tbArenaInfo.tbCurChallenger and tbArenaInfo.tbCurChallenger.nChallengerId
	end
	
	local pMan = KPlayer.GetPlayerObjById(nPlayerID or 0)
	if pMan then
		if pMan.dwTeamID > 0 then
			local tbMember = TeamMgr:GetMembers(pMan.dwTeamID);
			for _,dwID in pairs(tbMember) do
				local pPlayer = KPlayer.GetPlayerObjById(dwID)
				if pPlayer then
					Lib:CallBack({fnFunc, self, pPlayer, ...});
				end
			end
		else
			Lib:CallBack({fnFunc, self, pMan, ...});
		end
	end
end

function ArenaBattleFight:OnPlayerDeath(pKiller)

	if not self.bStart or not ArenaBattle:CheckValidMap(me) then
		Log("[ArenaBattleFight] OnPlayerDeath valid map",me.dwID,me.szName,me.nMapTemplateId,self.nArenaId)
		return 
	end

	if not ArenaBattle:CheckIsFighting(me) then
		Log("[ArenaBattleFight] OnPlayerDeath not fight player",me.dwID,me.szName,me.nMapTemplateId,self.nArenaId)
		return
	end

	local nCamp = self.tbCampInfo and self.tbCampInfo[me.dwID]
	if not nCamp then
		Log("[ArenaBattleFight] OnPlayerDeath camp not find",me.dwID,me.szName,me.nMapTemplateId,self.nArenaId)
		return
	end
	local nKillCamp = nCamp == ArenaBattle.tbForeachType.ARENA_MAN and ArenaBattle.tbForeachType.CHALLENGER or ArenaBattle.tbForeachType.ARENA_MAN
	local nKillID,nKillName,nKillTeamID
	
	if pKiller then
		local pKillPlayer = pKiller.GetPlayer();
		if pKillPlayer then
			self.tbDmgInfo[nKillCamp].tbPlayerKillCount = self.tbDmgInfo[nKillCamp].tbPlayerKillCount or {};
			self.tbDmgInfo[nKillCamp].tbPlayerKillCount[pKillPlayer.dwID] = (self.tbDmgInfo[nKillCamp].tbPlayerKillCount[pKillPlayer.dwID] or 0) + 1;
			
			self.tbPlayerKill[pKillPlayer.dwID] = (self.tbPlayerKill[pKillPlayer.dwID] or 0) + 1

			pKillPlayer.CallClientScript("ArenaBattle:ShowComboKillCount", self.tbPlayerKill[pKillPlayer.dwID],true);
			
			nKillID = pKillPlayer.dwID
			nKillName = pKillPlayer.szName
			nKillTeamID = pKillPlayer.dwTeamID
		end
	end

	self.tbPlayerKill[me.dwID] = 0
	self.tbDmgInfo[nKillCamp].nKillCount = self.tbDmgInfo[nKillCamp].nKillCount + 1;
	me.Revive(1);
	me.SetPkMode(0);
	me.RestoreAll();
	me.nFightMode = 2;
	me.AddSkillState(ArenaBattle.nDeathSkillState, 1, 0, 10000);
	me.CallClientScript("ArenaBattle:OnPlayerDeath")
	self:StopAllWatching(me)
	Log("[ArenaBattleFight] OnPlayerDeath ",self.nArenaId or -1,me.dwID,me.szName,me.dwTeamID,nKillID or -1,nKillName or "nil",nKillTeamID or -1,nCamp,nKillCamp)
	self:CheckResult();	
end

-- 玩家死亡后或掉线后为所有观战的玩家结束观战并同步观战状态
function ArenaBattleFight:StopAllWatching(pPlayer)
	if self.bStart then
		local pNpc = pPlayer.GetNpc()
		local nNpcId = pNpc and pNpc.nId or -1
		self:SynAllWatchingState(nNpcId)
	end
end

function ArenaBattleFight:SynAllWatchingState(nNpcId)
	local tbWatchList = self.tbWatchList or {}
	for dwID,_ in pairs(tbWatchList) do
		local pPlayer = KPlayer.GetPlayerObjById(dwID)
		if pPlayer then
			if not ArenaBattle:CheckIsFighting(pPlayer) and ArenaBattle:CheckValidMap(pPlayer) then
				ArenaBattle:SyncWatchInfo(pPlayer,self.nArenaId)
				pPlayer.CallClientScript("ArenaBattle:SynAllWatchingState",nNpcId)
			end
		end
	end
end


function ArenaBattleFight:OnPlayerLogout()
	if not ArenaBattle:CheckValidMap(me) then
		Log("[ArenaBattleFight] OnPlayerLogout valid map",me.dwID,me.szName,me.nMapTemplateId,self.nArenaId or -1)
		return
	end
	self:OnLeave(me)
	ArenaBattle:ClearOtherWaitWatch(0,me.dwID)
	self:StopAllWatching(me)
end

function ArenaBattleFight:OnPlayerLogin()
	if not ArenaBattle:CheckValidMap(me) then
		Log("[ArenaBattleFight] OnPlayerLogin valid map",me.dwID,me.szName,me.nMapTemplateId,self.nArenaId or -1)
		return
	end
	Timer:Register(Env.GAME_FPS * 3, function (self, nPlayerId)
		local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
		if not pPlayer or not ArenaBattle:CheckValidMap(pPlayer) then
			return;
		end
		self:UpdatePlayerUi(pPlayer);
	end, self, me.dwID);
end

function ArenaBattleFight:SynArenaState(pPlayer,bStart)
	if not pPlayer then
		return 
	end
	pPlayer.CallClientScript("ArenaBattle:OnSynArenaState",self.nArenaId,bStart)
end

function ArenaBattleFight:ForeachMapPlayer(fnFunc,...)
	local tbPlayer = KPlayer.GetMapPlayer(ArenaBattle.nArenaMapId)
	for _, pPlayer in ipairs(tbPlayer or {}) do
		Lib:CallBack({fnFunc, self, pPlayer, ...});
	end
end

function ArenaBattleFight:OnTryIn(pPlayer)
	self:Add2WatchList(pPlayer.dwID)
	if self.bStart then
		ArenaBattle:SyncWatchInfo(pPlayer,self.nArenaId) 
	end
end

function ArenaBattleFight:OnTrapOut(pPlayer)
	self:RemoveFromWatchList(pPlayer.dwID)
	self:ForeachAllPlayer(self.StopSyncWatch,pPlayer)
	pPlayer.CallClientScript("ArenaBattle:OnWatchTrapOut")
end

function ArenaBattleFight:StopSyncWatch(pFightPlayer,pWatchPlayer)
	if not pFightPlayer or not pWatchPlayer then
		return
	end
	local pNpc = pFightPlayer.GetNpc();
	if pNpc then
		pNpc.RemoveFromForceSyncSet(pWatchPlayer.dwID);
	end
end

function ArenaBattleFight:Add2WatchList(nPlayerID)
	self.tbWatchList = self.tbWatchList or {}
	self.tbWatchList[nPlayerID] = true
	ArenaBattle:ClearOtherWaitWatch(self.nArenaId,nPlayerID) 			-- 把玩家从其他擂台的等待观战列表删除
end

function ArenaBattleFight:RemoveFromWatchList(nPlayerID)
	if self.tbWatchList and self.tbWatchList[nPlayerID] then
		self.tbWatchList[nPlayerID] = nil
	end
end

-- 强制停止观战
function ArenaBattleFight:StopAllWatch()
	local tbWatchList = self.tbWatchList or {}
	for dwID,_ in pairs(tbWatchList) do
		local pPlayer = KPlayer.GetPlayerObjById(dwID)
		if pPlayer then
			pPlayer.CallClientScript("ArenaBattle:ForceStopWatch")
		end
	end
end

-- 战斗开始后为所有准备观战的玩家同步观战状态
function ArenaBattleFight:StartAllWatch()
	local tbWatchList = self.tbWatchList or {}
	for dwID,_ in pairs(tbWatchList) do
		local pPlayer = KPlayer.GetPlayerObjById(dwID)
		if pPlayer then
			if not ArenaBattle:CheckIsFighting(pPlayer) and ArenaBattle:CheckValidMap(pPlayer) then
				ArenaBattle:SyncWatchInfo(pPlayer,self.nArenaId)
			end
		end
	end
end
