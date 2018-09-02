local tbCampSetting = Battle.tbCampSetting

local tbBase = Battle:CreateClass("BattleMoba")

local tbBattleSettingCamp = Battle.tbAllBattleSetting.BattleMoba
local tbFile = LoadTabFile(tbBattleSettingCamp.fileMovePath, "ddd", nil, 
	{"Index", "nX", "nY"});	
tbCampSetting.tbMovePath = {};
for _, v in ipairs(tbFile) do
	tbCampSetting.tbMovePath[v.Index] = tbCampSetting.tbMovePath[v.Index] or {}
	table.insert(tbCampSetting.tbMovePath[v.Index], {v.nX, v.nY})
end	

function tbBase:Init(nMapId, tbBattleSetting, tbPlayerInfos, tbTeamA, tbTeamB, nReadyMapIndex, tbTeamFightPowers)
	self.nMapId = nMapId;
	self.bZone = MODULE_ZONESERVER and true or false; --拿来区分是否低价跨服了
	self.tbBattleSetting = tbBattleSetting;
	self.tbPlayerInfos = tbPlayerInfos;
	self.nReadyMapIndex = nReadyMapIndex
	self.tbTeamInfo = { {
		nDestroyBuildNum = 0; --是摧毁对方的建筑数
	}, {
		nDestroyBuildNum = 0;
	}}; --两个阵营各自的信息

	self.tbTeamIdToSide = {}; --[nTeamId] = nSide

	local nTotalFightPower = 0;
	for i,v in ipairs(tbTeamFightPowers) do
		nTotalFightPower = nTotalFightPower + v;
	end
	local nTotalLevel = 0;
    for dwRoleId, v in pairs(tbPlayerInfos) do
    	self:InitPlayerBattleInfo(v, dwRoleId)
    	nTotalLevel = nTotalLevel + v.nLevel
    end

	local nAverageFightPower = math.floor(nTotalFightPower / (#tbTeamA + #tbTeamB)) 
	local nAverageLevel = math.floor(nTotalLevel / (#tbTeamA + #tbTeamB)) 
	self.nNpcLevel = nAverageLevel
	self.nNpcIndex = self:GetNpcLevelByFightPower(nAverageLevel, nAverageFightPower)
	-- self.tbTeams = {tbTeamA, tbTeamB}  --todo 看下有用没

    self.nClinetDataVersion = 0; --客户端主动请求
    self.bServerForceSync = false; --服务端主动下发

    self.tbAllMoveCampNpc = { {}, {} }; --小兵
    self.tbAllBuildNpc = { {}, {} }; --建筑npc  [NpcId] = nLevel 形式

    self.tbAllBuildHpPercent = { {},{}};

    self.nBossBornTime = tbCampSetting.nBossBornTime; --boss出现的帧数， 从Active 0开始算的

    self.tbMapShowInfo = {}; -- szIndex = szName 小地图文字
    for i,v in ipairs(tbCampSetting.tbInitFuncs) do
    	self[v[1]](self, unpack( v, 2 ))
    end

    --根据现在的时间轴初始化奖励设置
end

function tbBase:GetNpcLevelByFightPower(nAverageLevel, nAverageFightPower)
	local tbInfo;
	for i,v in ipairs(tbCampSetting.tbFightPowerNpcLevel) do
		if nAverageLevel >= v.nPlyerLevel then
			tbInfo = v;
		else
			break;
		end
	end
	local nNpcIndex = 1;
	for i,v in ipairs(tbInfo.tbFigPowerLevel) do
		if nAverageFightPower >= v then
			nNpcIndex = i;
		else
			break;
		end
	end
	return nNpcIndex;
end


function tbBase:OnLogin()
	local tbInfo = self.tbPlayerInfos[me.dwID]
	if not tbInfo then
		Log(debug.traceback(), me.dwID)
		return
	end
	me.CallClientScript("Battle:EnterFightMap", self.tbBattleSetting.nIndex, self.nSchedulePos, math.floor(Timer:GetRestTime(self.nMainTimer) / Env.GAME_FPS), self.tbTeamInfo, tbInfo.nTeamIndex)

	if self.nBossHelpEndTime and self.nBossHelpSide then
		me.CallClientScript("Player:ServerSyncData", "BattleCampBossInfo",  "Help", self.nBossHelpEndTime, self.nBossHelpSide)
	elseif self.nBossBornTime then
		me.CallClientScript("Player:ServerSyncData", "BattleCampBossInfo",  "Reborn", self.nBossBornTime)
	end
	ChatMgr:JoinChatRoom(me, 1)
end

function tbBase:Start()
	self.STATE_TRANS = Battle.STATE_TRANS[self.tbBattleSetting.nUseSchedule]
	self.nSchedulePos = 0;
	self:StartSchedule();
end

function tbBase:StartSchedule()
	local tbLastSchedule = self.STATE_TRANS[self.nSchedulePos]
	if tbLastSchedule then
		Lib:CallBack({ self[tbLastSchedule.szFunc], self, tbLastSchedule.tbParam })
	end

	self.nMainTimer = nil; --nMainTimer 这样不为空时说明还有定时器未执行，

	self.nSchedulePos = self.nSchedulePos + 1;

	local tbNextSchedule = self.STATE_TRANS[self.nSchedulePos];
	if not tbNextSchedule then --后面没有timer 就断了
		return
	end

	self.nMainTimer = Timer:Register(Env.GAME_FPS * tbNextSchedule.nSeconds, self.StartSchedule, self )
end

--直接多少miao后进入指定步骤
function tbBase:DirGotoSchedule(nPos)
	if self.nMainTimer then
		Timer:Close(self.nMainTimer)
		self.nMainTimer = nil;
	end

	local tbLastSchedule = self.STATE_TRANS[self.nSchedulePos]
	if tbLastSchedule then
		Lib:CallBack({ self[tbLastSchedule.szFunc], self, tbLastSchedule.tbParam })
	end

	self.nSchedulePos = nPos;

	local tbNextSchedule = self.STATE_TRANS[nPos];
	if not tbNextSchedule then --后面没有timer 就断了
		return
	end

	self.nMainTimer = Timer:Register(Env.GAME_FPS * tbNextSchedule.nSeconds, self.StartSchedule, self )
end

--schd
function tbBase:StartFight()
	self.nFirstBloodPlayerId = nil;

	local nTimeNow = GetTime()
	local fnNofiy = function (pPlayer)
		pPlayer.CenterMsg("戰鬥開始！請各位前往前線")
		local tbInfo = self.tbPlayerInfos[pPlayer.dwID]
		tbInfo.nInBackCampTime = nTimeNow;

		pPlayer.CallClientScript("Player:ServerSyncData", "BattleScheTime", self.nSchedulePos + 1)
	end
	self:ForEachInMap(fnNofiy)

	self.nBattleOpen = 1
	self.nStartTime = nTimeNow

	KPlayer.MapBoardcastScript(self.nMapId, "Player:ServerSyncData", "BattleCampBossInfo",  "Reborn", self.nBossBornTime) 

	self.nActieTime = 0;
	self.nActiveTimer = Timer:Register(Env.GAME_FPS, function ()
		self:Active()
		self.nActieTime = self.nActieTime + 1;
		return true
	end)
end

--schd
function tbBase:StopFight()
	local nWinTeam = self:SetWinTeam();

	local nMatchTime = GetTime() - self.nStartTime
	local tbAwardSet = self.tbBattleSetting.tbAward
	local tbAwardMsg = self.tbBattleSetting.tbAwardMsg
	local tbTeamNames = self.tbBattleSetting.tbTeamNames
	for dwRoleId,tbInfo in pairs(self.tbPlayerInfos) do
		if not tbInfo.bNotJoin then
			local pPlayer = KPlayer.GetPlayerObjById(dwRoleId)
			local tbBattleInfo;
			local nResult = (nWinTeam == tbInfo.nTeamIndex and Env.LogRound_SUCCESS or Env.LogRound_FAIL);
			if pPlayer and self.nMapId == pPlayer.nMapId then
				self:GotoBackBattle(pPlayer)

				pPlayer.SetPkMode(0)
				tbBattleInfo = 
				{
					nMapTemplateId = self.tbBattleSetting.nMapTemplateId;
					szLogicClass = self.tbBattleSetting.szLogicClass;
					nScore = 0;
					nMatchTime = nMatchTime;
					nResult = nResult;
					nRank = 0;
					nKillCount = tbInfo.nKillCount;
					nMaxCombo = tbInfo.nMaxCombo;
					nDeathCount = tbInfo.nDeathCount;
					bZone = self.bZone;
				}
			end
			
			Battle:OnGetAwardEvent(dwRoleId, {},  tbAwardSet[nResult] , tbBattleInfo, string.format(tbAwardMsg[nResult], tbTeamNames[tbInfo.nTeamIndex], tbTeamNames[tbInfo.nTeamIndex]) )
		end
	end

	KPlayer.MapBoardcastScript(self.nMapId, "Player:ServerSyncData", "BattleScheTime", self.nSchedulePos + 1) 
	
	KPlayer.MapBoardcastScript(self.nMapId, "Battle:OnSynWinTeam", nWinTeam) 

	-- Battle:OnGetBattleFirstEnven(self.tbBattleRank[1].dwID, self.tbBattleSetting.szLogicClass, self.nReadyMapIndex)
end

--sche 整个比赛结束清场了
function tbBase:CloseBattle()
	if self.nMapId then
		self:ForEachInMap(self.PlayerLeave)
	end
	if self.nActiveTimer then
		Timer:Close(self.nActiveTimer)
		self.nActiveTimer = nil
	end
	self.nMapId = nil; --防止定时添加的npc,最后清
end

function tbBase:OnMapDestroy()
	self:CloseBattle();
	if self.nMainTimer then
		Timer:Close(self.nMainTimer)
		self.nMainTimer = nil
	end
end

function tbBase:Active()
	local nTimeNow = GetTime();
	self:CheckStayInCamp(nTimeNow)

	local tbTimeFunc = tbCampSetting.tbCampActives[self.nActieTime]
	if tbTimeFunc then
		for _,v in ipairs(tbTimeFunc) do
			Lib:CallBack({ self[v[1]], self, unpack( v, 2 )})	
		end
	end

	local nInterval = 3
	if self.nActieTime % nInterval == 0 then
		for nTeamIndex, tbNpcs in ipairs(self.tbAllMoveCampNpc) do
			local tbNewMoveNpcs = {}
			for i,nNpcId in ipairs(tbNpcs) do
				local pNpc = KNpc.GetById(nNpcId)
				if pNpc then
					pNpc.SetActiveForever(1)
					table.insert(tbNewMoveNpcs, nNpcId)
				end	
			end
			self.tbAllMoveCampNpc[nTeamIndex] = tbNewMoveNpcs
		end
		if self.nBossNpcId then
			self:CheckBossHpChange(nInterval);
		end
		for nTeam,v1 in ipairs(self.tbAllBuildNpc) do
			for nNpcId, nBuildLevel in pairs(v1) do
				local pNpc = KNpc.GetById(nNpcId)
				if pNpc then
					local nHpPercert = pNpc.nCurLife / pNpc.nMaxLife
					if nHpPercert < self.tbAllBuildHpPercent[nTeam][nBuildLevel] then
						self.tbAllBuildHpPercent[nTeam][nBuildLevel] = nHpPercert
						self.nClinetDataVersion = self.nClinetDataVersion + 1;
					end
				else
					v1[nNpcId] = nil;
				end
			end
		end
	end

	--只要取当前可以打的塔Npc就可以了
	for nTeam=1,2 do
		local nNpcId = self["nCurCanAttackBuildNpcId" .. nTeam]
		if nNpcId then
			local pNpc = KNpc.GetById(nNpcId)
			if pNpc then
				local tbPlayers, nPlayerCount = KNpc.GetAroundPlayerList(nNpcId, tbCampSetting.nBuildDamagePFlagRanage)
				if nPlayerCount > 0 then
					local tbNpcs, nNpcCount = KNpc.GetAroundNpcList(pNpc, tbCampSetting.nBuildDamagePFlagRanage) --会包含自己的
					local bHasNoEnmey = nNpcCount == 2; --因为塔身也是一个npc
					if not bHasNoEnmey then
						local bFindEnmey = false
						for i2,v2 in ipairs(tbNpcs) do
							local _,nAttakSide = v2.GetPkMode()
							if nAttakSide ~= 0 and nAttakSide ~= nTeam then
								bFindEnmey = true
								break;
							end
						end
						if not bFindEnmey then
							bHasNoEnmey =  true
						end
					end

					if bHasNoEnmey then 
						for i2,v2 in ipairs(tbPlayers) do
							local _,nAttakSide = v2.GetNpc().GetPkMode()
							if nAttakSide ~= nTeam then
								v2.AddSkillState(tbCampSetting.nPlayerDamagePFlagBuffId, 1, 0, 15)	
								v2.CallClientScript("Battle:OnGetLowAttackBuff", nNpcId)
							end
						end
					end
				end
			end
		end
	end


	--必须放到 tbCampActives 下面
	if self.bCheckAddCampNpcTarget then
		self.bCheckAddCampNpcTarget = nil
		for nTeam=1,2 do
			local nOtherTeamId = nTeam == 1 and 2 or 1;
			local tbMyCampNpc = self.tbAllMoveCampNpc[nTeam]
			local tbOtherCampNpc = self.tbAllMoveCampNpc[nOtherTeamId]
			local tbOtherBuildNpc = self.tbAllBuildNpc[nOtherTeamId]

			for i,v in ipairs(tbMyCampNpc) do
				local pNpc = KNpc.GetById(v)
				if pNpc then
					pNpc.ClearAiLockTarget();
					for k2,v2 in pairs(tbOtherBuildNpc) do
						pNpc.AddAiLockTarget(k2)
					end
					for i2,v2 in ipairs(tbOtherCampNpc) do
						pNpc.AddAiLockTarget(v2)
					end
				end
			end
		end
	end

	if self.bServerForceSync then
		self.bServerForceSync = nil;
		KPlayer.MapBoardcastScript(self.nMapId, "Player:ServerSyncData", "BattleCampTeamScore", self.tbTeamInfo, math.floor(Timer:GetRestTime(self.nMainTimer) / Env.GAME_FPS)) 
	end

end

function tbBase:CheckBossHpChange(nInterval)
	local pNpc = KNpc.GetById(self.nBossNpcId)
	if not pNpc then
		self.nBossNpcId = nil;
		return
	end
	local tbDmgInfo = pNpc.GetDamageInfo()
	local tbChangedSide = {};--1,2 
	local nMaxLife = pNpc.nMaxLife / ( 1 - tbCampSetting.nBossLastDmgPercent)
	for _, v in ipairs(tbDmgInfo) do
		local nSide = self.tbTeamIdToSide[v.nTeamId]
		if nSide then
			local nLastDmg = self.tbBossCampDamgHp[nSide]
			if nLastDmg == v.nTotalDamage then
				self.tbBossHpNotChangeTime[nSide] = (self.tbBossHpNotChangeTime[nSide] + nInterval);
				if self.tbBossHpNotChangeTime[nSide] > tbCampSetting.nBossDmgNotChangeInterval and v.nTotalDamage > 0 then
					local nChangeDamg = math.min(math.floor(nMaxLife * 0.01 * nInterval) , v.nTotalDamage)  
					local tbMember = TeamMgr:GetMembers(v.nTeamId);
					local _, nPlayerId = next(tbMember)
					local pPlayer = KPlayer.GetPlayerObjById(nPlayerId)
					if pPlayer then
						pNpc.ModifyRecordDamage(pPlayer.GetNpc().nId, - nChangeDamg) 
						table.insert(tbChangedSide, nSide)
						self.tbBossCampDamgHp[nSide] = v.nTotalDamage - nChangeDamg
					end
				end
			else
				self.tbBossHpNotChangeTime[nSide] = 0;
				self.tbBossCampDamgHp[nSide] = v.nTotalDamage
				table.insert(tbChangedSide, nSide)
			end
		else
			Log(debug.traceback(), v.nTeamId)
		end
	end
	if #tbChangedSide > 0 then
		KPlayer.MapBoardcastScript(self.nMapId, "Player:ServerSyncData", "BattleCampBossInfo", "Dmg", self.tbBossCampDamgHp, tbChangedSide, nMaxLife) 
	end
end

function tbBase:InitPlayerBattleInfo(tbInfo, dwRoleId)
			-- nTeamIndex = nTeamIndex,  init时已经设上
	  --   	szName = pPlayer.szName,
	  --   	nFaction = pPlayer.nFaction,
	  --   	nLevel = pPlayer.nLevel,
	tbInfo.nDeathCount 		= 0 ; --死亡次数 -- tlog记录需要
	tbInfo.nComboCount  	= 0;                -- 当前连斩数
    tbInfo.nMaxCombo    	= 0;                -- 最高连斩数
    tbInfo.nComboLevel 		= 1;				--连斩数对应超神那些等级，用于变化时的战场公告
    tbInfo.nKillCount		= 0;				--杀敌数，只包括玩家
    tbInfo.nInBackCampTime  = 0; 	    -- 上次呆在后营的时间，0则是不再后营
    local pRole = KPlayer.GetRoleStayInfo(dwRoleId)
    tbInfo.nPortrait = pRole.nPortrait
    tbInfo.nHonorLevel = pRole.nHonorLevel
end

function tbBase.PlayerLeave(pPlayer)
	pPlayer.GotoEntryPoint()	
end
if MODULE_ZONESERVER then
	function tbBase.PlayerLeave(pPlayer)
		pPlayer.ZoneLogout()
	end
end

function tbBase:OnEnter()
	local tbInfo = self.tbPlayerInfos[me.dwID]
	if not tbInfo then
		Log(debug.traceback(), me.dwID)
		self.PlayerLeave(me)
		return
	end
	local nTeamIndex = tbInfo.nTeamIndex
	if not self.tbTeamInfo[nTeamIndex].nTeamId then
		TeamMgr:CreateOnePersonTeam();
		local dwTeamID = me.dwTeamID
		if dwTeamID == 0 then
			Log(debug.traceback(), me.dwID)
			self.PlayerLeave(me)
			return
		end
		self.tbTeamInfo[nTeamIndex].nTeamId = dwTeamID;
		self.tbTeamIdToSide[dwTeamID] = nTeamIndex;
		if not ChatMgr:IsTeamHaveChatRoom(dwTeamID) then
			ChatMgr:CreateTeamChatRoom(dwTeamID)
		end

	else
		local nTeamId = self.tbTeamInfo[nTeamIndex].nTeamId
		me.GetNpc().SetTeamId(nTeamId)
	end

	me.SetPosition(unpack(Battle:GetRandInitPos(nTeamIndex, self.tbBattleSetting))) 

	me.GetNpc().SetAiNotify(true, false)

	me.nInBattleState = 1; --战场模式

	me.bForbidChangePk = 1;
	
	me.SetPkMode(3, nTeamIndex)
	--设置虚拟队伍id

	me.GetNpc().SetDir(self.tbBattleSetting.tbInitDir[nTeamIndex])


    tbInfo.nOnDeathRegID = PlayerEvent:Register(me, "OnDeath", self.OnPlayerDeath, self);
    tbInfo.nOnReviveRegID = PlayerEvent:Register(me, "OnRevive", self.OnPlayerRevive, self);


    tbInfo.nOlgCamp = me.GetNpc().nCamp
    me.GetNpc().SetCamp(self.tbBattleSetting.tbCamVal[nTeamIndex]);
   -- self.tbTeamInfo[tbInfo.szTeam].nPlayerCount = self.tbTeamInfo[tbInfo.szTeam].nPlayerCount + 1;

	me.CallClientScript("Battle:EnterFightMap", self.tbBattleSetting.nIndex, self.nSchedulePos, math.floor(Timer:GetRestTime(self.nMainTimer) / Env.GAME_FPS), self.tbTeamInfo, nTeamIndex);
end

function tbBase:OnLeave()
	if ChatMgr:IsTeamHaveChatRoom(me.GetNpc().dwTeamID) then
		ChatMgr:LeaveKinChatRoom(me);	
	end
	me.nInBattleState = 0; --战场模式
	me.bForbidChangePk = 0;
	me.RemoveSkillState(TeamBattle.nDeathSkillState);

	me.SetPkMode(0)
	me.ClearTempRevivePos()
	me.GetNpc().SetAiNotify(false, false)

	local tbInfo = self.tbPlayerInfos[me.dwID]
	if not tbInfo then
		Log(debug.traceback())
		return
	end

	if me.dwTeamID ~= 0 then
		TeamMgr:QuiteTeam(me.dwTeamID, me.dwID)
	else
		me.GetNpc().SetTeamId(0);
	end

	me.GetNpc().SetCamp(tbInfo.nOlgCamp);

	if tbInfo.nOnDeathRegID then
		PlayerEvent:UnRegister(me, "OnDeath", tbInfo.nOnDeathRegID);
		tbInfo.nOnDeathRegID = nil;
    end
    if tbInfo.nOnReviveRegID then
		PlayerEvent:UnRegister(me, "OnRevive", tbInfo.nOnReviveRegID);
		tbInfo.nOnReviveRegID = nil;
    end

    --todo 如果buff不久也是可以不处理把
    -- for k,v in pairs(tbCampSetting.tbBuffToTitleSetting) do
    -- 	me.RemoveSkillState(k);
    -- end

  --因为是先logout 的，所以还是 在这里做区分吧
  	-- self:OnLeaveZoneBattleMap(me)
end

function tbBase:OnPlayerTrap(szTrapName)
	if self.nBattleOpen ~= 1 then
		me.CenterMsg("戰鬥還沒有打響哦，請稍等片刻")
		return
	end
	if szTrapName == "GotoFrontBattle" then
		self:GotoFrontBattle(me);
    end
end

function tbBase:RevivePlayer(nPlayerId)
	if not self.nMapId then
		return
	end
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId)
	if not pPlayer then
		return
	end
	if pPlayer.nMapId ~= self.nMapId then
		return
	end
	pPlayer.nFightMode = 1;
	local tbMyInfo = self.tbPlayerInfos[pPlayer.dwID]	
	pPlayer.SetPosition(unpack(Battle:GetRandInitPos(tbMyInfo.nTeamIndex, self.tbBattleSetting))); 
end

function tbBase:OnPlayerDeath(pKillerLuna)
	local tbMyInfo = self.tbPlayerInfos[me.dwID]	
	me.Revive(1)
	me.nFightMode = 2;

	me.AddSkillState(TeamBattle.nDeathSkillState, 1, 0, Env.GAME_FPS * tbCampSetting.nRevieTime );	 
	Timer:Register(Env.GAME_FPS * tbCampSetting.nRevieTime , self.RevivePlayer, self, me.dwID)
	me.GetNpc().ClearAllSkillCD();
	me.GetNpc().SetDir(self.tbBattleSetting.tbInitDir[tbMyInfo.nTeamIndex])

	tbMyInfo.nDeathCount = tbMyInfo.nDeathCount + 1
	tbMyInfo.nComboCount = 0;
	local nDeadComboLevel = tbMyInfo.nComboLevel
	tbMyInfo.nComboLevel = 1;
	me.CallClientScript("Battle:OnPlayerDeath",GetTime() + tbCampSetting.nRevieTime)
	
	tbMyInfo.nInBackCampTime = GetTime();

	if not pKillerLuna then
		return
	end
	local pKiller = pKillerLuna.GetPlayer()
	if not pKiller then
		return
	end

	self:OnKillPlayer(pKiller, me, nDeadComboLevel);
end

function tbBase:ComboKill(pPlayer, tbInfo)
	tbInfo = tbInfo or self.tbPlayerInfos[pPlayer.dwID]
	tbInfo.nComboCount = tbInfo.nComboCount + 1

	if tbInfo.nComboCount > tbInfo.nMaxCombo then
		tbInfo.nMaxCombo = tbInfo.nComboCount
	end

	pPlayer.CallClientScript("Ui:ShowComboKillCount", tbInfo.nComboCount, true)

	local nNewComboLevel = tbInfo.nComboLevel
	for i = nNewComboLevel + 1, #Battle.tbComboLevelSet do
		local v = Battle.tbComboLevelSet[i]
		if tbInfo.nComboCount < v.nComboCount then
			break;
		else
			nNewComboLevel = i
		end
	end
	if tbInfo.nComboLevel ~= nNewComboLevel then
		local tbComboInfo = Battle.tbComboLevelSet[nNewComboLevel]
		tbInfo.nComboLevel = nNewComboLevel
	    self:BattleFieldTips(string.format(tbComboInfo.szNotify, tbInfo.szName));	
	end

    -- self.bRankUpdate = true
end

function tbBase:ForEachInMap(fnFunction)
	local tbPlayer = KPlayer.GetMapPlayer(self.nMapId);
	for _, pPlayer in ipairs(tbPlayer) do
		fnFunction(pPlayer);
	end
end

function tbBase:BlackMsg(szMsg)
	local fnExcute = function (pPlayer)
		Dialog:SendBlackBoardMsg(pPlayer, szMsg);
	end
	self:ForEachInMap(fnExcute);
end

function tbBase:BattleFieldTips(szMsg)
    KPlayer.MapBoardcastScript(self.nMapId, "Ui:OpenWindow", "BattleFieldTips", szMsg) 
end

--pPlayer 或假玩家 杀死玩家时 ,
function tbBase:OnKillPlayer(pPlayerNpc, pDeader, nComboLevel)
	if not self.nFirstBloodPlayerId then
	self.nFirstBloodPlayerId = true
		self:BattleFieldTips(string.format("%s擊敗了%s，拿到第一滴血", pPlayerNpc.szName, pDeader.szName))
	end

	local tbDeadTitileInfo = Battle.tbComboLevelSet[nComboLevel]

	if tbDeadTitileInfo.szKilledNotify then
		self:BattleFieldTips(string.format(tbDeadTitileInfo.szKilledNotify, pPlayerNpc.szName, pDeader.szName))
	end

	local dwRoleId = pPlayerNpc.dwID
	local tbKillerInfo = self.tbPlayerInfos[dwRoleId]

	tbKillerInfo.nKillCount = tbKillerInfo.nKillCount + 1

	self:ComboKill(pPlayerNpc, tbKillerInfo);
end

--对于在后营待太久的移到到前线
function tbBase:CheckStayInCamp(nTimeNow)
	local fnCheck = function (pPlayer)
		local tbInfo = self.tbPlayerInfos[pPlayer.dwID]
		if tbInfo.nInBackCampTime ~= 0 and  nTimeNow - tbInfo.nInBackCampTime > self.tbBattleSetting.BACK_IN_CAMP_TIME then
			self:GotoFrontBattle(pPlayer)
		end
	end
	self:ForEachInMap(fnCheck);
end

-- 传送到大营
function tbBase:GotoFrontBattle(pPlayer)
    local tbInfo = self.tbPlayerInfos[pPlayer.dwID];
    if self.tbBattleSetting.tbPosBattle then
    	local tbPos = self.tbBattleSetting.tbPosBattle[tbInfo.nTeamIndex]
    	pPlayer.SetPosition(unpack( tbPos[MathRandom(#tbPos)] ))
    	--给一个复活的buff
    	local nSkillId, nSkillLevel, nSkillTime = unpack(Battle.tbRevieBuff)
		pPlayer.AddSkillState(nSkillId, nSkillLevel,  0 , nSkillTime * Env.GAME_FPS)
    end

    pPlayer.GetNpc().SetPkMode(3, tbInfo.nTeamIndex)
    tbInfo.nInBackCampTime = 0;
end


function tbBase:SetWinTeam()
	self.nBattleOpen = 0;
	
	if self.nActiveTimer then
		Timer:Close(self.nActiveTimer)
		self.nActiveTimer = nil
	end

	local nDestroyBuildNum1, nDestroyBuildNum2 = self.tbTeamInfo[1].nDestroyBuildNum, self.tbTeamInfo[2].nDestroyBuildNum
	if nDestroyBuildNum1 ~= nDestroyBuildNum2 then
		Log("CampBattle:SetWinTeam BuildNum", self.nMapId, nDestroyBuildNum1, nDestroyBuildNum2)
		return nDestroyBuildNum1 > nDestroyBuildNum2 and 1 or 2;
	else
		for nBuildLevel = 1, #self.tbAllBuildHpPercent[1] do
			local nHp1 = self.tbAllBuildHpPercent[1][nBuildLevel]
			local nHp2 = self.tbAllBuildHpPercent[2][nBuildLevel]
			if nHp1 ~= nHp2 then
				Log("CampBattle:SetWinTeam BuildHp", self.nMapId, nHp1 , nHp2, nBuildLevel)
				return nHp1 > nHp2 and 1 or 2;
			end
		end
		local tbSideKillTotal = {0,0}
		for k,v in pairs(self.tbPlayerInfos) do
			tbSideKillTotal[v.nTeamIndex] = tbSideKillTotal[v.nTeamIndex] + v.nKillCount
		end
		if tbSideKillTotal[1] ~= tbSideKillTotal[2] then
			Log("CampBattle:SetWinTeam KillNum", self.nMapId, tbSideKillTotal[1], tbSideKillTotal[2])
			return tbSideKillTotal[1] > tbSideKillTotal[2] and 1 or 2;
		end

		Log("CampBattle:SetWinTeam Random", self.nMapId)
		return MathRandom(2)
	end
end

-- 只是比赛结算时回后营
function tbBase:GotoBackBattle(pPlayer)
    local tbInfo = self.tbPlayerInfos[pPlayer.dwID];
    pPlayer.SetPosition(unpack( Battle:GetRandInitPos(tbInfo.nTeamIndex, self.tbBattleSetting)))
    pPlayer.GetNpc().SetPkMode(0)
    tbInfo.nInBackCampTime = GetTime();
end


function tbBase:OnNpcDeath(him, pKiller)
	if him.nWildSettingIndex then
		self:OnWildNpcDeath(him, pKiller, him.nWildSettingIndex)
		return
	end

	local nMode, nCustom = him.GetPkMode()
	if self.tbAllBuildNpc[nCustom] and self.tbAllBuildNpc[nCustom][him.nId] then
		self:OnBuildNpcDeath(him, pKiller)
		return
	end

	if self.nBossNpcId == him.nId then
		self:OnBossNpcDeath(him, pKiller);
		return
	end

	if self.nHelpBossId == him.nId then
		self:OnHelpBossNpcDeath()
		return
	end

end

function tbBase:OnEarlyDeath( him, pKiller )
	if him.nCreateWithNpc then
		local pNpc2 = KNpc.GetById(him.nCreateWithNpc)
		if pNpc2 then
			pNpc2.DoDeath()
		end
	end
end

function tbBase:OnHelpBossNpcDeath()
	self.nHelpBossId = nil;
	self.nBossHelpEndTime = nil;
	self.nBossHelpSide = nil;
	if self.nBossBornTime then
		KPlayer.MapBoardcastScript(self.nMapId, "Player:ServerSyncData", "BattleCampBossInfo",  "Reborn", self.nBossBornTime) 
	end
end

function tbBase:OnBossNpcDeath(him, pKiller)
	--重生
	self.nBossNpcId = nil;
	Timer:Register(Env.GAME_FPS * tbCampSetting.nBossReBorntTime, self.AddBossNpc, self, him.nOrgX, him.nOrgY, him.nDir);
	self.nBossBornTime = self.nActieTime + tbCampSetting.nBossReBorntTime;
	
	--援助
	local tbDmgInfo = him.GetDamageInfo()
	if not tbDmgInfo or #tbDmgInfo <= 0 then
		KPlayer.MapBoardcastScript(self.nMapId, "Player:ServerSyncData", "BattleCampBossInfo",  "Reborn", self.nBossBornTime) 
		return
	end

	local nLastDmgPlayerID = him.GetLastDmgMePlayerID();
	local nLastAttackTeam;
	local pLastKiller;
	if nLastDmgPlayerID > 0 then
		pLastKiller = KPlayer.GetPlayerObjById(nLastDmgPlayerID)
		if pLastKiller then
			nLastAttackTeam = pLastKiller.GetNpc().dwTeamID
		end
	end

	local nMaxLife = him.nMaxLife / (1 - tbCampSetting.nBossLastDmgPercent)
	for _,v in ipairs(tbDmgInfo) do
		local nSide = self.tbTeamIdToSide[v.nTeamId]
		if nSide then
			if v.nTeamId == nLastAttackTeam then
				self.tbBossCampDamgHp[nSide] = v.nTotalDamage + nMaxLife * tbCampSetting.nBossLastDmgPercent
			else
				self.tbBossCampDamgHp[nSide] = v.nTotalDamage
			end
		end
	end
	local nKillSide = self.tbBossCampDamgHp[1] > self.tbBossCampDamgHp[2] and 1 or 2;
	if self.tbBossCampDamgHp[nKillSide] == 0 then
		KPlayer.MapBoardcastScript(self.nMapId, "Player:ServerSyncData", "BattleCampBossInfo",  "Reborn", self.nBossBornTime) 
		return
	end
	local nX, nY, nDir, nMovePath = unpack(tbCampSetting.tbBossHelpMovePath[nKillSide])
	self.nHelpBossId = self:AddCampNpcMovePath(tbCampSetting.tbBossNpcTeamplate, nKillSide, nX, nY, nDir, nMovePath)
	local pHelpNpc = KNpc.GetById(self.nHelpBossId) 
	if pHelpNpc then
		pHelpNpc.SetAi(tbCampSetting.szBossHelpAiFile)
	end

	self.nBossHelpEndTime = self.nActieTime + tbCampSetting.nBossHelpTime
	self.nBossHelpSide = nKillSide
	Timer:Register(Env.GAME_FPS * tbCampSetting.nBossHelpTime, self.DelHelpBoss, self)

	KPlayer.MapBoardcastScript(self.nMapId, "Player:ServerSyncData", "BattleCampBossInfo", "Dmg", self.tbBossCampDamgHp, {nKillSide}, nMaxLife) 
	Timer:Register(Env.GAME_FPS * 5, function ()
		if self.nMapId and self.nBossHelpEndTime then
			KPlayer.MapBoardcastScript(self.nMapId, "Player:ServerSyncData", "BattleCampBossInfo",  "Help", self.nBossHelpEndTime, self.nBossHelpSide) 	
		end
	end)
	

	self:BattleFieldTips(string.format("%s成功捕獲%s，即將加入戰場", self.tbBattleSetting.tbTeamNames[nKillSide], him.szName))
end

function tbBase:OnBuildNpcDeath(him, pKiller)
	local nMode, nTeam = him.GetPkMode()
	local nTarTeam = nTeam == 1 and 2 or 1;
	self.tbTeamInfo[nTarTeam].nDestroyBuildNum = self.tbTeamInfo[nTarTeam].nDestroyBuildNum + 1;
	local nBuildLevel = self.tbAllBuildNpc[nTeam][him.nId]
	self.tbAllBuildNpc[nTeam][him.nId] = nil;
	self.tbAllBuildHpPercent[nTeam][nBuildLevel] = 0;
	self.bServerForceSync = true;
	self.nClinetDataVersion = self.nClinetDataVersion + 1;
	if him.szMapIndex then
		self.tbMapShowInfo[him.szMapIndex] = "";
	end

	if him.szDynamicObstacle then
		OpenDynamicObstacle(self.nMapId, him.szDynamicObstacle);	
	end

	self["nCurCanAttackBuildNpcId" .. nTeam] = nil

	if not next(self.tbAllBuildNpc[nTeam]) then
		self:BattleFieldTips(string.format("%s的大營被摧毀", self.tbBattleSetting.tbTeamNames[nTeam]) );	
		local fnSetPeace = function (pPlayer)
			pPlayer.SetPkMode(Player.MODE_PEACE) --TODO 确认下这时也不能打建筑物
		end
		self:ForEachInMap(fnSetPeace)

		Timer:Register(Env.GAME_FPS * 3, function ()
			if self.nSchedulePos >= #self.STATE_TRANS then
				return
			end
			
			self:DirGotoSchedule( #self.STATE_TRANS)
		end)
		return
	end
	
	self:BattleFieldTips(string.format("%s的一座防禦塔被摧毀", self.tbBattleSetting.tbTeamNames[nTeam]) );	

	local nOpenNextLevel = nBuildLevel + 1;
	local nOpenNpcId;
	for k,v in pairs(self.tbAllBuildNpc[nTeam]) do
		if v == nOpenNextLevel then
			nOpenNpcId = k;
			break;
		end
	end
	if not nOpenNpcId then
		Log(debug.traceback())
		return
	end

	local pNpc = KNpc.GetById(nOpenNpcId)
	if not pNpc then
		Log(debug.traceback())
		return
	end
	pNpc.RemoveSkillState(tbCampSetting.tbBuffBuilding[1]);	
	if nOpenNextLevel < 3 then
		self["nCurCanAttackBuildNpcId" .. nTeam] = nOpenNpcId
	end
end

function tbBase:OnWildNpcDeath(him, pKiller, nWildSettingIndex)
	local nReviveTime = him.nRebornTime
	if nReviveTime and nReviveTime > 0  then
		Timer:Register(Env.GAME_FPS * nReviveTime, self.AddRandWildNpc, self, nReviveTime, him.nOrgX, him.nOrgY, him.nDir);
	end

	local pPlayer = pKiller and pKiller.GetPlayer()
	if not pPlayer then
		return
	end

	local _, _, nBuffId, nBuffLevel, nBuffTime = unpack(tbCampSetting.RandWildNpcSetting[nWildSettingIndex])
	pPlayer.AddSkillState(nBuffId, nBuffLevel, 0, nBuffTime)
end

function tbBase:AddCampNpcMovePath(tbNpcTemplate, nTeam, nX, nY, nDir, nMovePath)
	local pNpc = KNpc.Add(tbNpcTemplate[self.nNpcIndex], self.nNpcLevel, 0, self.nMapId, nX, nY, 0, nDir)
	if not pNpc then
		return
	end
	pNpc.SetPkMode(3, nTeam)
	pNpc.SetActiveForever(1)
	pNpc.AI_ClearMovePathPoint();
	for _,Pos in ipairs(tbCampSetting.tbMovePath[nMovePath]) do
		pNpc.AI_AddMovePos(unpack(Pos));
	end
	pNpc.AI_StartPath();	
	pNpc.SetCamp(self.tbBattleSetting.tbCamVal[nTeam]);

	table.insert(self.tbAllMoveCampNpc[nTeam], pNpc.nId)
	self.bCheckAddCampNpcTarget = true
	return pNpc.nId
	
end

function tbBase.fnOnAiNotify(pNpc, nEvent, nHurdNpcId, nAttackNpcId)
	if Npc.AI_EVENT_ATTACK_BY_PLAYER ~= nEvent then
		return
	end
	local pAttackNpc = KNpc.GetById(nAttackNpcId)
	if not pAttackNpc then
		return
	end
	local pAttackPlayer = pAttackNpc.GetPlayer()
	if not pAttackPlayer then
		return
	end
	
	local nCurTargeId = pNpc.AI_GetTarget()
	if nCurTargeId == nAttackNpcId then
		return
	end

	local _, nMySide = pNpc.GetPkMode()
	local _,nAttakSide = pAttackNpc.GetPkMode()
	if nAttakSide == nMySide then
		return
	end

	if nCurTargeId ~= 0 then
		local pCurTargetNpc = KNpc.GetById(nCurTargeId)
		if pCurTargetNpc then
			local pCurTargetPlayer = pCurTargetNpc.GetPlayer()
			if pCurTargetPlayer then
				return
			end
		end
	end

	pNpc.AI_SetTarget(nAttackNpcId)
end

function tbBase:AddBuildNpc(tbNpcTemplate, nTeam, nBuildLevel, nX, nY, nDir, szMapIndex, szName, szDynamicObstacle)
	local nNpcTemplate = tbNpcTemplate[self.nNpcIndex]
	local pNpc = KNpc.Add(nNpcTemplate, self.nNpcLevel, 0, self.nMapId, nX, nY, 0, nDir)
	if not pNpc then
		return
	end
	pNpc.SetPkMode(3, nTeam)
	pNpc.SetActiveForever(1)
	pNpc.SetCamp(self.tbBattleSetting.tbCamVal[nTeam]);
	--单独设置其Ai
	pNpc.SetAi(tbCampSetting.szBuildNpcAiFile)
	pNpc.SetAiNotify(false, true)
	pNpc.fnOnAiNotify = self.fnOnAiNotify

	self.tbAllBuildNpc[nTeam][pNpc.nId] = nBuildLevel

	if nBuildLevel > 1 then
		local nBuffId,nBuffLevel,nBuffTime = unpack(tbCampSetting.tbBuffBuilding)
		pNpc.AddSkillState(nBuffId,nBuffLevel,0, nBuffTime)	
	else
		self["nCurCanAttackBuildNpcId" .. nTeam] = pNpc.nId
	end

	pNpc.AddSkillState(tbCampSetting.nBuildDamagePFlagBuffId, 1, 0, (1800) * Env.GAME_FPS)

	pNpc.szMapIndex = szMapIndex
	self.tbMapShowInfo[szMapIndex] = szName;

	self.tbAllBuildHpPercent[nTeam][nBuildLevel] = 1;
	pNpc.szDynamicObstacle = szDynamicObstacle
	local nCreateWithNpc = tbCampSetting.tbNpcCreateWith[nNpcTemplate]
	if nCreateWithNpc then
		local pNpc2 = KNpc.Add(nCreateWithNpc, self.nNpcLevel, 0, self.nMapId, nX, nY, 0, nDir)
		if pNpc2 then
			pNpc.nCreateWithNpc = pNpc2.nId;
		end
	end
end

function tbBase:AddRandWildNpc(nRebornTime, nX, nY, nDir)
	if not self.nMapId then
		return
	end

	local RandWildNpcSetting = tbCampSetting.RandWildNpcSetting
	local nRand = MathRandom(#RandWildNpcSetting)
	local tbSet = RandWildNpcSetting[nRand]
	local tbNpcTemplate,nTitleId  = unpack(tbSet)

	local pNpc = KNpc.Add(tbNpcTemplate[self.nNpcIndex], self.nNpcLevel, 0, self.nMapId, nX, nY, 0, nDir)
	if not pNpc then
		return
	end
	pNpc.SetPkMode(3, 3)
	pNpc.nOrgX = nX;
	pNpc.nOrgY = nY;

	pNpc.nWildSettingIndex = nRand
	pNpc.SetTitleID(nTitleId);

	if nRebornTime ~= 0 then
		pNpc.nRebornTime = nRebornTime;
	end
end

function tbBase:DelHelpBoss()
	if self.nHelpBossId then --先删掉协助的
		local pNpc = KNpc.GetById(self.nHelpBossId)
		if pNpc then
			pNpc.Delete()
		end

		self.nHelpBossId = nil;
		KPlayer.MapBoardcastScript(self.nMapId, "Player:ServerSyncData", "BattleCampBossInfo",  "Reborn", self.nBossBornTime) 
	end	
end

function tbBase:AddBossNpc(nX, nY, nDir)
	if not self.nMapId then
		return
	end
	local pNpc = KNpc.Add(tbCampSetting.tbBossNpcTeamplate[ self.nNpcIndex ], self.nNpcLevel, 0, self.nMapId, nX, nY, 0, nDir)
	if not pNpc then
		return
	end
	pNpc.SetPkMode(3, 3)
	pNpc.nOrgX = nX;
	pNpc.nOrgY = nY;
	
	-- self.tbBossNpcHp[pNpc.nId] = pNpc.nCurLife	

	self.tbBossCampDamgHp = { 0,0 }; --两边输出的伤害
	self.tbBossHpNotChangeTime = { 0,0 }; --两边各个没有对boss输出的秒数
	self.nBossNpcId = pNpc.nId
	self.nBossBornTime = 0;


	-- self.nClinetDataVersion = self.nClinetDataVersion + 1;

	self:BlackMsg(string.format("%s現身戰場，擊殺的一方可獲得協助", pNpc.szName))
end

function tbBase:AddRandBuff(nX, nY, szParam)
	Item.Obj:DropBufferInPosWhithType(Item.Obj.TYPE_CHECK_FIGHT_MODE, self.nMapId, nX, nY, szParam);
end

function tbBase:RequestCampMapInfo(pPlayer)
	if not self.nActieTime or not self.nBossBornTime then
		return
	end
	--因为需要npc的位置，所以限制客户端的请求就好了	
	local nX,nY;
	local nNpcId = self.nBossNpcId or self.nHelpBossId
	if nNpcId then
		local pNpc = KNpc.GetById(nNpcId)
		if pNpc then
			local _, X,Y = pNpc.GetWorldPos()
			 nX,nY = X,Y
		end
	end

	pPlayer.CallClientScript("Player:ServerSyncData", "BattleCampMapInfo",  { tbMapShowInfo =  self.tbMapShowInfo, nNpcId = nNpcId, nLeftTime = self.nBossBornTime - self.nActieTime, nX = nX, nY = nY})
end

function tbBase:RequestTeamInfo(pPlayer)
	pPlayer.CallClientScript("Player:ServerSyncData", "BattleCampTeamInfo", self.tbPlayerInfos, self.tbAllBuildHpPercent)
end