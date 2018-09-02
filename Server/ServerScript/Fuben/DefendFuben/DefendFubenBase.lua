local tbFuben = Fuben:CreateFubenClass(DefendFuben.szFubenClass);

function tbFuben:OnCreate()
	self.nRound = 0 					-- 第几波
	self.tbReviveTimer = {};
	self.tbActive = {} 					-- 某轮已经激活的NPC
	self.tbOpenRoad = {}				-- 已经开放的路
	self.tbRoadInfo = {} 				-- 所有的路
	self.tbDialogNpc = {}				-- 对话NPC
	self.tbRecord = {} 				    -- 发奖记录	
	self:OnCreateDialogNpc()
	self:Start();
	self.nStartTime = GetTime();
	self.tbMonsterGroup = {}
end

function tbFuben:OnNpcCreateFubenBase(pNpc)
	self.tbNpcHpNotice = self.tbNpcHpNotice or {}
	self.nMingXiaHitTime = 0
	self.tbNpcHpNotice[pNpc.nId] = Npc:RegisterNpcHpChange(pNpc, function(nOldHp, nNewHp, nMaxHp)
		if GetTime() > self.nMingXiaHitTime + DefendFuben.nMingXiaHitMsgInteval then
			self:Msg("張如夢正與死士交手，快保護他！")
		end
		self.nMingXiaHitTime = GetTime()
	end)
end

function tbFuben:OnKillNpc(pNpc, pKiller)
	if pNpc.szClass == "DefendMainNpc" and self.tbNpcHpNotice and self.tbNpcHpNotice[pNpc.nId] then
		Npc:UnRegisterNpcHpEvent(pNpc.nId, self.tbNpcHpNotice[pNpc.nId]);
		self.tbNpcHpNotice[pNpc.nId] = nil
	end
end

function tbFuben:UnRegAllNpcHpChange()
	if self.tbNpcHpNotice then
		for nNpcId,nRegId in pairs(self.tbNpcHpNotice) do
			Npc:UnRegisterNpcHpEvent(nNpcId, nRegId);
			self.tbNpcHpNotice[nNpcId] = nil
		end
	end
end

-- 创建对话NPC
function tbFuben:OnCreateDialogNpc()
	local tbSetting = self.tbSetting
	local fnRandomSeries = Lib:GetRandomSelect(#tbSetting.NpcSeries)
	for nRoad = 1,tbSetting.nMaxRoad do
		local nSeries = self.tbRoadInfo[nRoad] and self.tbRoadInfo[nRoad].nSeries or fnRandomSeries()
		local nNpcId = tbSetting.tbSeriesDialogNpc[nSeries]
		local szPointName = tbSetting.tbRoadSetting[nRoad][2]
		local nNpcX, nNpcY = self:GetPoint(szPointName);
		local pNpc = KNpc.Add(nNpcId, self:GetAverageLevel(), nSeries, self.nMapId, nNpcX, nNpcY);
		if pNpc then
			-- 重置对话NPC激活助战Npc
			self.tbDialogNpc[pNpc.nId] = {
				nSeries = nSeries,
				nNpcTId = nNpcId,
				nNpcId = pNpc.nId,
				nDialogNpcPointName = szPointName,
				nRoad = nRoad
			}
			-- 同步记录对话NPC状态
			self.tbRoadInfo[nRoad] = {
				nSeries = nSeries,
				nNpcTId = nNpcId,
				nNpcId = pNpc.nId,
				nRoad = nRoad,
				nNpcX = nNpcX,
				nNpcY = nNpcY,
			}
			pNpc.SetTitle(tbSetting.NpcSeries[nSeries],1,1)
			Log("[DefendFubenBase] OnCreateDialogNpc ok",nRoad,nSeries,szPointName,nNpcX, nNpcY)
		else
			Log("[DefendFubenBase] OnCreateDialogNpc fail",nRoad,nSeries,szPointName,nNpcX, nNpcY)
		end
	end
end

function tbFuben:GetDialogSeries()
	local tbData = {
		["Dialog"] = self.tbRoadInfo,
		["Monster"] = self.tbOpenRoad,
	}
	return tbData
end

function tbFuben:SynSeriesData(tbData)
	local function fnSynSeries(pPlayer)
		pPlayer.CallClientScript("DefendFuben:OnSynSeriesData",tbData or self:GetDialogSeries());
	end

	self:AllPlayerExcute(fnSynSeries);
end

-- 每一轮开始的时候调
-- 随机开放路并随机怪物五行
function tbFuben:OnRoundStep()
	local tbSetting = self.tbSetting
	if self.nRound >= tbSetting.nMaxRound then
		Log("[DefendFubenBase] OnRoundStep fail ",self.nRound,tbSetting.nMaxRound,self.nMapId)
		return 
	end
	self.tbOpenRoad = {}
	local fnRandomRoad = Lib:GetRandomSelect(tbSetting.nMaxRoad)
	local fnRandomSeries = Lib:GetRandomSelect(#tbSetting.NpcSeries)
	for i=1,tbSetting.nOpenRoadNum do
		local nRoad = fnRandomRoad()
		local nSeries = fnRandomSeries()
		local nIndex = tbSetting.tbSeriesMonster[nSeries]
		local szMonsterPoint = tbSetting.tbRoadSetting[nRoad][1]
		local nNpcX, nNpcY = self:GetPoint(szMonsterPoint);
		self.tbOpenRoad[nRoad] = {
			nSeries = nSeries,
			nNpcIndex = nIndex,
			nNpcX = nNpcX,
			nNpcY = nNpcY,
		}
		Log("[DefendFubenBase] OnRoundStep ok",nRoad,nSeries,nIndex,szMonsterPoint,nNpcX,nNpcY,self.nRound)
	end
	self.nRound = self.nRound + 1
	self.bStart = true
	self:SynSeriesData()
end

-- 为开放的路创建怪物
function tbFuben:OnCreateMonster(nLockId)
	assert(next(self.tbOpenRoad),string.format("[DefendFubenBase] CreateMonster fail Round %d",self.nRound))
	self.nMonsterId = self.nMonsterId and (self.nMonsterId + 1) or 0
	local szMonsterGroup = "Monster" ..self.nMonsterId
	for nRoad,tbInfo in pairs(self.tbOpenRoad) do
		local nNpcIndex = tbInfo.nNpcIndex
		local szMonsterPoint = self.tbSetting.tbRoadSetting[nRoad][1]
		self:_AddNpc(nNpcIndex, 1, nLockId, szMonsterGroup, szMonsterPoint, 0, 0, 0, 0, 0);
	end
	self:ChangeNpcAi(szMonsterGroup,"Move",self.tbSetting.szMingXiaPath,0,0,0,0,0)
	self:ChangeNpcAi(szMonsterGroup,"AddAiLockTarget","MingXiaNpc")
	self:SetActiveForever(szMonsterGroup, 1)
	self:SynSeriesData()
	self.tbMonsterGroup[szMonsterGroup] = true
end

function tbFuben:OnClearAllMonster()
	for szMonsterGroup,_ in pairs(self.tbMonsterGroup) do
		self:DelNpc(szMonsterGroup)
	end
end

-- 每一轮结束的时候调
function tbFuben:OnRoundStepOver()
	self:OnResetDialogNpc()
	self.bStart = false
end

-- 激活助战NPC
function tbFuben:ActiveNpc(nNpcID,dwID)
	local pPlayer = KPlayer.GetPlayerObjById(dwID)
	
	if not pPlayer then
		return 
	end

	if self.bClose == 1 then
		pPlayer.CenterMsg("活動已經結束",true)
		return
	end

	if not self.bStart then
		pPlayer.CenterMsg("敵人尚未出現，請稍後片刻",true)
		return
	end

	local pDialogNpc = KNpc.GetById(nNpcID);
	if not pDialogNpc then
		pPlayer.CenterMsg("NPC不存在",true)
		return
	end

	if self.tbActive[self.nRound] then
		pPlayer.CenterMsg("你已選擇了一名助戰者，請下輪再重新選取",true)
		return
	end

	if not self.tbDialogNpc[nNpcID] then
		pPlayer.CenterMsg("你要啟動哪個NPC??",true)
		return
	end
	local tbSetting = self.tbSetting
	local _,nNpcX,nNpcY = pDialogNpc.GetWorldPos()
	local nSeries = self.tbDialogNpc[nNpcID].nSeries
	local nNpcTId = tbSetting.tbSeriesActiveNpc[nSeries]

	local pAssistNpc = KNpc.Add(nNpcTId, self:GetAverageLevel(), nSeries, self.nMapId, nNpcX, nNpcY);
	if not pAssistNpc then
		Log("[DefendFubenBase] ActiveNpc failed ",nNpcTId,nNpcID,pPlayer.dwID,pPlayer.szName,self.nRound,self.nMapId); 
		return
	end

	pDialogNpc.Delete();
	
	self.tbActive[self.nRound] = pAssistNpc.nId

	Log("[DefendFubenBase] ActiveNpc ok",pPlayer.dwID,pPlayer.szName,self.nRound,nSeries,self.nMapId,nNpcX,nNpcY,nNpcID,nNpcTId)
end

-- 清理助战NPC
function tbFuben:ClearActiveNpc()
	for nRound,nNpcID in pairs(self.tbActive) do
		local pNpc = KNpc.GetById(nNpcID);
		if pNpc then
			pNpc.Delete();
			Log("[DefendFubenBase] ClearActiveNpc ",nRound,nNpcID)
		end
	end
end

function tbFuben:ClearDialogNpc()
	for nNpcId,v in pairs(self.tbDialogNpc) do
		local pNpc = KNpc.GetById(nNpcId);
		if pNpc then
			pNpc.Delete();
			Log("[DefendFubenBase] ClearDialogNpc ",nNpcId,v.nSeries,v.nRoad)
		end
	end
end

-- 重置对话npc
function tbFuben:OnResetDialogNpc()
	self:ClearActiveNpc()
	self:ClearDialogNpc()
	self:OnCreateDialogNpc()
end

function tbFuben:OnFirstJoin(pPlayer)
	local bCost = DegreeCtrl:ReduceDegree(pPlayer, "DefendFuben", 1);
	pPlayer.CallClientScript("Fuben:ShowLeave");
	Log("[DefendFubenBase] OnJoin",pPlayer.szAccount, pPlayer.dwID, pPlayer.nLevel,pPlayer.GetFightPower(),bCost and "Yes" or "No",DegreeCtrl:GetDegree(pPlayer, "DefendFuben"))
end

function tbFuben:OnJoin(pPlayer)
	self:OnMapState(pPlayer)
end

function tbFuben:OnMapState(pPlayer)
	pPlayer.CallClientScript("Ui:SetAllUiVisable", true);
	pPlayer.CallClientScript("Fuben:ClearClientData");
	pPlayer.CallClientScript("Ui:OpenWindow", "HomeScreenFuben", "TeamFuben");
	pPlayer.CallClientScript("DefendFuben:OnSynSeriesData",self:GetDialogSeries())
	if self.nShowEndTime and self.nShowEndTime > 0 then
		pPlayer.CallClientScript("Fuben:SetEndTime", self.bClose == 1 and 0 or self.nShowEndTime);
	end
end

function tbFuben:OnLogin(bReConnect)
	self:OnMapState(me)
	if self.bClose == 1 then
		me.CallClientScript("Fuben:ShowLeave");
	end
end

function tbFuben:GameWin()
	self:Close();
	Log("[DefendFubenBase] GameWin ",GetTime() - self.nStartTime,self.nRound)
end

function tbFuben:GameLost()
	self.nRound = (self.nRound - 1) >= 0 and (self.nRound - 1) or 0
	self:Close();
	Log("[DefendFubenBase] GameLost ",GetTime() - self.nStartTime,self.nRound)
end

function tbFuben:SendReward(pPlayer)
	local tbReward = DefendFuben:GetReward(self.nRound)
	if not tbReward then
		Log("[DefendFubenBase] SendReward fail",pPlayer.dwID,pPlayer.szName,pPlayer.nLevel,self.nRound)
		return
	end
	if self.tbRecord[pPlayer.dwID] then
		Log("[DefendFuben] SendReward repeat",pPlayer.dwID,pPlayer.szName,pPlayer.nLevel,self.nRound)
		return
	end
	local szTitle = "五一江湖展身手"
	local szText = string.format("少俠，在五一江湖展身手活動中，你與同伴共成功抵禦了[c8ff00] %d輪 [-]敵人的進攻，這是在下的小小心意，還望勿要拒絕！",self.nRound)
	local tbMail = {
		To = pPlayer.dwID;
		Title = szTitle;
		From = "獨孤劍";
		Text = szText;
		tbAttach = tbReward;
		nLogReazon = Env.LogWay_ActDefend;
	};

	Mail:SendSystemMail(tbMail);
	self.tbRecord[pPlayer.dwID] = GetTime()
	Log("[DefendFubenBase] SendReward ",pPlayer.szName,pPlayer.dwID,pPlayer.nLevel,self.nRound)
end

function tbFuben:OnOut(pPlayer)
	self:DoRevive(pPlayer.dwID, true);
	-- 发奖励
	self:SendReward(pPlayer)
	pPlayer.CallClientScript("DefendFuben:OnSynSeriesData")
	pPlayer.CallClientScript("Fuben:ShowLeave");
	pPlayer.TLogRoundFlow(Env.LogWay_ActDefend, pPlayer.nMapTemplateId, self.nRound, GetTime() - (self.nStartTime or 0), Env.LogRound_SUCCESS, 0, 0);
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

function tbFuben:OnPlayerDeath()
	me.CallClientScript("Ui:OpenWindow", "CommonDeathPopup", "AutoRevive", "您將在 %d 秒後復活", DefendFuben.REVIVE_TIME);
	self.tbReviveTimer[me.dwID] = Timer:Register(DefendFuben.REVIVE_TIME * Env.GAME_FPS, self.DoRevive, self, me.dwID);
end

function tbFuben:OnLeaveMap(pPlayer)
	self.nRound = 0
	self:DoRevive(pPlayer.dwID, true);
	pPlayer.CallClientScript("DefendFuben:OnLeaveMap")
end


function tbFuben:OnClose()
	self:UnRegAllNpcHpChange()
	self:OnKickOutAllPlayer(DefendFuben.KICK_TIME);
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

