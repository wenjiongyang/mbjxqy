local tbFuben = Fuben:CreateFubenClass(IdiomFuben.szFubenClass);

function tbFuben:OnCreate()
	self.nKillCount = 0;
	self.nKillNpcIndex = 0;
	self.nCurIndex = MathRandom(1, #IdiomFuben.tbNpcNameSet);
	self.tbNpc = {};
	self.tbReviveTimer = {};
	self.nStartTime = GetTime();
	self:Start();
	Log(string.format("[IdiomsFubenBase] OnCreate start from npc index %d",self.nCurIndex));
end

function tbFuben:OnLogin(bReConnect)
	self:OnMapState(me)
	if self.bClose == 1 then
		me.CallClientScript("Fuben:ShowLeave");
	end
end

function tbFuben:OnMapState(pPlayer)
	pPlayer.CallClientScript("Ui:SetAllUiVisable", true);
	pPlayer.CallClientScript("Fuben:ClearClientData");
	pPlayer.CallClientScript("Ui:OpenWindow", "HomeScreenFuben", "TeamFuben");
	pPlayer.CallClientScript("Fuben:SetScoro", self.nKillCount);
	if self.nShowEndTime and self.nShowEndTime > 0 then
		pPlayer.CallClientScript("Fuben:SetEndTime", self.bClose == 1 and 0 or self.nShowEndTime);
	end
end

function tbFuben:OnJoin(pPlayer)
	self:OnMapState(pPlayer)
end

function tbFuben:OnFirstJoin(pPlayer)
	local bCost = DegreeCtrl:ReduceDegree(pPlayer, "Idioms", 1);
	self.tbPlayer[pPlayer.dwID].nJoinTime = GetTime()
	Log("[IdiomsFubenBase] OnJoin",pPlayer.szAccount, pPlayer.dwID, pPlayer.nLevel,pPlayer.GetFightPower(),bCost and "Yes" or "No",DegreeCtrl:GetDegree(pPlayer, "Idioms"))
end

function tbFuben:OnCallIdiomNpc()
	self.nCurIndex = (self.nCurIndex + 1) % IdiomFuben.NameRow;
	self.nCurIndex = self.nCurIndex == 0 and IdiomFuben.NameRow or self.nCurIndex;

	self:ClearNpc();
	local szLog = ""
	local tbNpcID = IdiomFuben.tbNpcIdSet;
	local fnSelect =  Lib:GetRandomSelect(#IdiomFuben.tbNpcPos)
	for i=1,IdiomFuben.NameCol do
		local nNpcCount = #tbNpcID
		local nNpcId = tbNpcID[i] or tbNpcID[MathRandom(1, nNpcCount)]
		local tbPos = IdiomFuben.tbNpcPos[fnSelect()]

		local nAvgLevel = self:GetAverageLevel();
		if not nAvgLevel then
			Log("[IdiomsFubenBase] there is no player in the map");
			return;
		end
		local pNpc = KNpc.Add(nNpcId, nAvgLevel, -1, self.nMapId, tbPos.nPosX, tbPos.nPosY);
		if pNpc then
			
			local tbNpcNameSet = IdiomFuben.tbNpcNameSet[self.nCurIndex]
			if not tbNpcNameSet then
				Log(string.format("[IdiomsFubenBase] Can't find the name of index:%d", self.nCurIndex));
				return;
			end
			local szNpcName = tbNpcNameSet["name" .. i] or "????"
			pNpc.SetName(szNpcName);
			pNpc.nIndex  = (i - 1) * IdiomFuben.NameRow + self.nCurIndex;
			table.insert(self.tbNpc, pNpc.nId);

			szLog = szLog ..string.format("%s(%d,%d)",szNpcName,tbPos.nPosX or 0,tbPos.nPosY or 0)
		else
			Log("[IdiomsFubenBase] Call Npc failed in qixi_idiom fuben"); 
		end
	end
	Log("[IdiomsFubenBase] OnCallIdiomNpc  ",self.nCurIndex,self.nKillNpcIndex,self.nKillNpcIndex,szLog)
end

function tbFuben:OnKillNpc(pNpc, pKiller)
	local pKillPlayer = pKiller and pKiller.GetPlayer() or {}
	Log("[IdiomsFubenBase] OnKillNpc -- ",pNpc.szName,pNpc.nIndex,self.nCurIndex,self.nKillNpcIndex,pKillPlayer.szName,pKillPlayer.dwID)
	local nNpcIndex = pNpc.nIndex
	if self.nKillNpcIndex > 0 then
		local nRightIndex = self.nKillNpcIndex + 1
		if (self.nKillNpcIndex == 100 and nNpcIndex ~=  1) or (self.nKillNpcIndex ~= 100 and nNpcIndex ~= (nRightIndex)) then
			-- 任务失败
			Log("[IdiomsFubenBase] OnKillNpc Lost",pNpc.szName,nRightIndex,nNpcIndex,self.nKillNpcIndex)
			self:GameLost()
			return;
		end
	end

	self.nKillCount = self.nKillCount + 1;
	self.nKillNpcIndex =nNpcIndex;
	
	self:OnCallIdiomNpc();

	self:AllPlayerExcute(function (pPlayer) pPlayer.CallClientScript("Fuben:SetScoro", self.nKillCount); end)
	self:Msg("接龍成功，獲得1點積分")
end

function tbFuben:OnPlayerDeath()
	me.CallClientScript("Ui:OpenWindow", "CommonDeathPopup", "AutoRevive", "您將在 %d 秒後復活", IdiomFuben.REVIVE_TIME);
	self.tbReviveTimer[me.dwID] = Timer:Register(IdiomFuben.REVIVE_TIME * Env.GAME_FPS, self.DoRevive, self, me.dwID);
end

function tbFuben:DoRevive(nPlayerId,bIsOut)
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

function tbFuben:ClearNpc()
	local szLog = ""
	for _, nNpcId in ipairs(self.tbNpc) do
		local pNpc = KNpc.GetById(nNpcId);
		if pNpc then
			pNpc.Delete();
			szLog = szLog ..pNpc.szName .."1"
		end
	end
	self.tbNpc = {};
	Log("[IdiomsFubenBase] ClearNpc ",szLog); 
end

function tbFuben:GameWin()
	self:ClearNpc();
	self:Close();
	Log("[IdiomsFubenBase] GameWin ",GetTime() - self.nStartTime,self.nKillCount,self.nKillNpcIndex,self.nCurIndex)
end

function tbFuben:GameLost()
	self:ClearNpc();
	self:SetEndTime()
	self:BlackMsg("太遺憾了，沒能首尾相連，挑戰結束！")
	self:Msg("太遺憾了，沒能首尾相連，挑戰結束！")
	self:Close();
	Log("[IdiomsFubenBase] GameLost ",GetTime() - self.nStartTime,self.nKillCount,self.nKillNpcIndex,self.nCurIndex)
end

function tbFuben:SetEndTime(nTime)
	nTime = nTime or GetTime()
	local tbAllPlayer = KPlayer.GetMapPlayer(self.nMapId);
	for _, pPlayer in pairs(tbAllPlayer) do
		pPlayer.CallClientScript("Fuben:SetEndTime", nTime);
	end
end

function tbFuben:OnOut(pPlayer)
	self:DoRevive(pPlayer.dwID, true);
	-- 发奖励
	self:SendReward(pPlayer)
	pPlayer.TLogRoundFlow(Env.LogWay_Idioms, pPlayer.nMapTemplateId, self.nKillCount, GetTime() - (self.nStartTime or 0), Env.LogRound_SUCCESS, 0, 0);
end

function tbFuben:SendReward(pPlayer)
	local tbReward = IdiomFuben:GetReward(self.nKillCount)
	local szTitle = "有緣一線牽"
	local szText = string.format("少俠，你這次在有緣一線牽活動中，獲得了%d點積分，給予你如下的獎勵，請笑納！",self.nKillCount)
	local tbMail = {
		To = pPlayer.dwID;
		Title = szTitle;
		From = "南宮飛雲";
		Text = szText;
		tbAttach = tbReward;
		nLogReazon = Env.LogWay_Idioms;
	};

	Mail:SendSystemMail(tbMail);
	Log("[IdiomsFubenBase] SendReward ",pPlayer.szName,pPlayer.dwID,self.nKillCount,self.nKillNpcIndex,self.nCurIndex)
end

function tbFuben:OnLeaveMap(pPlayer)
	self.nKillCount = 0
	self:DoRevive(pPlayer.dwID, true);
	pPlayer.CallClientScript("IdiomFuben:OnLeaveMap")
end

function tbFuben:OnClose()
	local tbAllPlayer = KPlayer.GetMapPlayer(self.nMapId);
	for _, pPlayer in pairs(tbAllPlayer) do
		pPlayer.CallClientScript("Fuben:ShowLeave");
	end

	self:OnKickOutAllPlayer(IdiomFuben.KICK_TIME);
end

function tbFuben:OnKickOutAllPlayer(nTime)
	Timer:Register(Env.GAME_FPS * nTime, function ()
		self:KickOutAllPlayer();
	end);
end

function tbFuben:KickOutAllPlayer()
	local tbAllPlayer = KPlayer.GetMapPlayer(self.nMapId);
	for _, pPlayer in pairs(tbAllPlayer) do
		pPlayer.GotoEntryPoint();
	end
end
