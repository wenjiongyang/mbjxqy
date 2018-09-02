DomainBattle.tbBase = DomainBattle.tbBase or {};
local tbBase = DomainBattle.tbBase
local define = DomainBattle.define

function tbBase:Init(nMapTemplateId, nMapId, nOwnerKin, tbAttckKins)
	self.bOpenBattle = false;
	self.nMapTemplateId = nMapTemplateId
	self.nMapId = nMapId
	nOwnerKin = nOwnerKin or - 1; --没有占领的就是 -1
	self.nOwnerKin = nOwnerKin
	self.tbMapPosSetting = DomainBattle.tbMapPosSetting[nMapTemplateId]
	local tbMapPosSetting = self.tbMapPosSetting
	
	self.tbMapShowInfo = {} --要同步给客户端更新小地图显示的
	if tbMapPosSetting.Doors then
		for i,v in ipairs(tbMapPosSetting.Doors) do
			self.tbMapShowInfo[v[5]] = "";
		end
	end
	
	for i,v in ipairs(self.tbMapPosSetting.tbFlogNpcPos) do
		self.tbMapShowInfo[v[6]] = "";
	end

	self.tbCampNpcs = {} -- 具有阵营的npc，如龙柱和城门

	local tbKinAttackCampIndex = {} --每个家族的出生camp
	local tbKinPkIndex = {} --, 每个家族的pkmode，因为有npc所以自定义
	local nAttackCamps = #(tbMapPosSetting.tbAtackPos)
	local tbOwnerMap = DomainBattle:GetDomainOwnerMap()
	for i, dwKinId in ipairs(tbAttckKins) do
		local nHisMap = tbOwnerMap[dwKinId]
		local nCampIndex = i % nAttackCamps + 1;-- - math.floor(i / nAttackCamps)
		if nHisMap  then
			local tbMapLevel = DomainBattle.tbMapLevel[nHisMap]
			local nLevel, index1, index2 = unpack(tbMapLevel)
			if index2 then
				nCampIndex = index2
			elseif index1 then
				nCampIndex = index1
			end
		end
		tbKinAttackCampIndex[dwKinId] = nCampIndex
		tbKinPkIndex[dwKinId] = i;
	end
	tbKinPkIndex[nOwnerKin] = #tbAttckKins + 1
	tbKinPkIndex[-1] = #tbAttckKins + 2

	self.tbKinPkIndex = tbKinPkIndex
	self.tbKinAttackCampIndex = tbKinAttackCampIndex

	self.tbFlogNpcHpState = {}; --龙柱的hp状态，用于提醒用，每秒检查一次 --这个只记录一些临界状态，超过以临界状态记录
	self.tbFlagState = {} --龙柱的归属家族  [nIndex] = dwKinid （3是最高级的）
	local tbFlogNpcPos = tbMapPosSetting.tbFlogNpcPos
	for i, v in ipairs(tbFlogNpcPos) do
		self:CreateCampNpc(i, nOwnerKin)
	end

	local tbDoors = tbMapPosSetting.Doors
	if tbDoors then
		local nMapLevel = DomainBattle:GetMapLevel(nMapTemplateId)
		local nNpcId_Door = define.tbNpcId_Door[nMapLevel]
		local nSkillId, nSkillLevel = unpack(define.tbDoorBuff)
		for i, v in ipairs(tbDoors) do
			local nX, nY, nDir = unpack(v)
			local pNpc = KNpc.Add(nNpcId_Door, DomainBattle.nTimeFrameNpcLevel, 0, self.nMapId, nX, nY, 0, nDir)
			pNpc.SetPkMode(3,  self.tbKinPkIndex[nOwnerKin]);
			pNpc.nDoorIndex = i;
			pNpc.AddSkillState(nSkillId, DomainBattle.nTimeFrameLevel,  0 , 3600 * Env.GAME_FPS)
			self.tbCampNpcs[pNpc.nId] = 1;
		end
	end

	local tbTrpGotoLowMap = {} --回低级地图
	local tbAttackCampTrapsOut = {};
	local tbAttackCampTrapsIn = {};
	

	for i, v in ipairs(tbMapPosSetting.tbAtackPos) do
		local _,_,szTrapToLow, _,szTrapAttCampOut, tbOutPosSet, szTrapAttCampIn, tbInPosSet = unpack(v);
		if DomainBattle:GetChildLinkMap(nMapTemplateId) and not Lib:IsEmptyStr(szTrapToLow)  then
			tbTrpGotoLowMap[szTrapToLow] = i;
		end
		if not Lib:IsEmptyStr(szTrapAttCampOut) then
			tbAttackCampTrapsOut[szTrapAttCampOut] = tbOutPosSet;
		end
		if not Lib:IsEmptyStr(szTrapAttCampIn) then
			tbAttackCampTrapsIn[szTrapAttCampIn] = i;
		end
	end	
	self.tbTrpGotoLowMap = tbTrpGotoLowMap;
	self.tbAttackCampTrapsOut = tbAttackCampTrapsOut
	self.tbAttackCampTrapsIn = tbAttackCampTrapsIn


	--一开始的动态障碍
	local nDynamicObstacleNpcId = define.nDynamicObstacleNpcId
	self.tbCampDynamicObstacleNpcs = {}
	for i, v in ipairs(tbMapPosSetting.tbCampDynamicObstacle) do
		local nX, nY, nDir = unpack(v)
		local pNpc = KNpc.Add(nDynamicObstacleNpcId, 1, 0, self.nMapId, nX, nY, 0, nDir)
		table.insert(self.tbCampDynamicObstacleNpcs, pNpc.nId)
	end

	self.tbInvalidTraps = {} -- 现在只是城门攻破以后失效的trap名
	
	
	self.tbRoleInfo = {}
end

function tbBase:Start()
	self.STATE_TRANS = DomainBattle.STATE_TRANS;
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

function tbBase:CheckFlagHPNotify(nNpcId)
	local nOldHp = self.tbFlogNpcHpState[nNpcId]
	if not nOldHp then
		return
	end
	local pNpc = KNpc.GetById(nNpcId)
	if not pNpc then
		return
	end
	
	local nNewHp = pNpc.nCurLife
	if nNewHp >= nOldHp then
		return
	end

	local nMaxLife = pNpc.nMaxLife
	local fOldFlag = nOldHp / nMaxLife
	local tbFlagHpStateNotify = DomainBattle.define.tbFlagHpStateNotify
	if fOldFlag <= tbFlagHpStateNotify[1][1] then
		return
	end

	local nFlagIndex = pNpc.nFlagIndex
	if not nFlagIndex then
		return
	end

	local fChangeFlag = nNewHp / nMaxLife
	for _, v in ipairs(tbFlagHpStateNotify) do
		local fP, szDmgInfo = unpack(v)
		if fChangeFlag <= fP then
			if fP * nMaxLife < nOldHp then
				self.tbFlogNpcHpState[nNpcId] = fP * nMaxLife
				local tbFlagState = self.tbFlagState[nFlagIndex]
				local dwOldKinId = tbFlagState[1]
				if dwOldKinId and dwOldKinId ~= -1 then
					ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.Kin, string.format("本幫派的%s——%s%s！", Map:GetMapName(self.nMapTemplateId), pNpc.szName, szDmgInfo), dwOldKinId);	
				end	
			end
			break;
		end
	end
end

function tbBase:Active()
	--检查通知龙柱状态
	for nNpcId, _ in pairs(self.tbCampNpcs) do
		self:CheckFlagHPNotify(nNpcId)
	end
	local szfnFuc = DomainBattle.tbActiveCountFunc[self.nActiveCount]
	if szfnFuc then
		Lib:CallBack({ self[szfnFuc], self})
	end
end

function tbBase:SynGameTime()
	KPlayer.MapBoardcastScript(self.nMapId, "DomainBattle:OnSynDomainGameTime", math.floor(Timer:GetRestTime(self.nMainTimer) / Env.GAME_FPS))
end


function tbBase:OnEnter()
	local dwKinId = me.dwKinId
	local nCampIndex = self.tbKinPkIndex[dwKinId]
	if not nCampIndex  then
		me.GotoEntryPoint()
		Log(debug.traceback(),me.dwID)
		return
	end
	local nPosX, nPosY;
	if dwKinId == self.nOwnerKin then
		nPosX, nPosY = unpack( self.tbMapPosSetting.tbDefendPos )
	else
		nPosX, nPosY = unpack( self.tbMapPosSetting.tbAtackPos[self.tbKinAttackCampIndex[dwKinId] ] )
	end
	me.SetPosition(nPosX, nPosY)
	me.SetTempRevivePos(self.nMapId, nPosX, nPosY);

	if self.bOpenBattle then
		me.SetPkMode(Player.MODE_CUSTOM, nCampIndex);
	else
		me.SetPkMode(Player.MODE_PEACE);
	end
	
	me.bForbidChangePk = 1;
	me.nInBattleState = 1; --战场模式

	self.tbRoleInfo[me.dwID] = {
		nOnDeathRegID = PlayerEvent:Register(me, "OnDeath", self.OnPlayerDeath, self);
		tbSkillState = {}; --出去的时候要清掉
		-- nOnKillNpcRegID = PlayerEvent:Register(me, "OnKillNpc", self.OnKillNpc, self);
		nOnLeaveKinRegID = PlayerEvent:Register(me, "OnLeaveKin", self.OnPlayerLeaveKin, self);
	};

	DomainBattle:AddBattleScore(me, 0, 0)

	Kin:JoinChatRoom(me);

	me.CallClientScript("DomainBattle:EnterFightMap", self.nSchedulePos, math.floor(Timer:GetRestTime(self.nMainTimer) / Env.GAME_FPS), self.tbCampNpcs); 
end

function tbBase:OnLeave()
	me.bForbidChangePk = 0;
	me.nInBattleState = 0; --战场模式
	me.SetPkMode(Player.MODE_PEACE);
	me.ClearTempRevivePos();

	ChatMgr:LeaveKinChatRoom(me);

	local tbInfo = self.tbRoleInfo[me.dwID]
	if tbInfo then
		if tbInfo.nOnDeathRegID then
			PlayerEvent:UnRegister(me, "OnDeath", tbInfo.nOnDeathRegID);
			tbInfo.nOnDeathRegID = nil;
	    end

	    if tbInfo.nOnLeaveKinRegID then
	    	PlayerEvent:UnRegister(me, "OnLeaveKin", tbInfo.nOnLeaveKinRegID);
			tbInfo.nOnLeaveKinRegID = nil;
	    end

	    for nSkillId, _ in pairs(tbInfo.tbSkillState) do
	    	me.RemoveSkillState(nSkillId);	
	    end
	    tbInfo.tbSkillState = {};
	  --   if tbInfo.nOnKillNpcRegID then
			-- PlayerEvent:UnRegister(me, "OnKillNpc", tbInfo.nOnKillNpcRegID);
			-- tbInfo.nOnKillNpcRegID = nil;
	  --   end
	end
end

function tbBase:OnPlayerLeaveKin()
	me.GotoEntryPoint();
end

function tbBase:OnPlayerTrap(szTrapName)
	if self.tbInvalidTraps[szTrapName] then
		return
	end
	local tbPos = self.tbMapPosSetting[szTrapName]
	if tbPos then
		me.SetPosition(unpack(tbPos[MathRandom(#tbPos)]))
	elseif szTrapName == define.szTrapGotoAttack then
		DomainBattle:GotoAttackMap(me)
	elseif not self:OnMoveTrap(me, szTrapName) then

	else
		local nIndex = self.tbTrpGotoLowMap[szTrapName]
		if nIndex then
			DomainBattle:GotoDefendMap(me, nIndex)
		end
	end
end

--todo 其实是没用了 因为召唤的战斗npc是在非安全区招的
function tbBase:OnNpcTrap(szTrapName)
	self:OnMoveTrap(him, szTrapName)	
end

function tbBase:OnMoveTrap(pPlayerNpc, szTrapName)
	if not self.bOpenBattle then
		return
	end
	
	if szTrapName == "TrapPeace" then
		if pPlayerNpc.nFightMode ~= 0 then
			pPlayerNpc.nFightMode = 0;
		end
	elseif szTrapName == "TrapFight" then
		if pPlayerNpc.nFightMode ~= 1 then
			pPlayerNpc.nFightMode = 1;
			pPlayerNpc.AddSkillState(1517, 1,  0 , 5 * Env.GAME_FPS)
		end
	elseif self.tbAttackCampTrapsOut[szTrapName] then
		if pPlayerNpc.nFightMode ~= 1 then
			pPlayerNpc.nFightMode = 1;
			pPlayerNpc.AddSkillState(1517, 1,  0 , 5 * Env.GAME_FPS)
		end
		local tbPosSet = self.tbAttackCampTrapsOut[szTrapName]
		pPlayerNpc.SetPosition(unpack(tbPosSet[MathRandom(#tbPosSet)]))
	elseif self.tbAttackCampTrapsIn[szTrapName] then
		local nMyIndex = self.tbKinAttackCampIndex[pPlayerNpc.dwKinId]
		if nMyIndex == self.tbAttackCampTrapsIn[szTrapName] then
			if pPlayerNpc.nFightMode ~= 0 then
				pPlayerNpc.nFightMode = 0;
			end
			local tbPosSet = self.tbMapPosSetting.tbAtackPos[nMyIndex][8]
			if tbPosSet then
				pPlayerNpc.SetPosition(unpack(tbPosSet[MathRandom(#tbPosSet)]))
			end
		end
	elseif szTrapName == "BackCampOut" then
		if pPlayerNpc.dwKinId == self.nOwnerKin then
			local tbPosBackCampOut = self.tbMapPosSetting.tbPosBackCampOut
			pPlayerNpc.SetPosition(unpack(tbPosBackCampOut[MathRandom(#tbPosBackCampOut)]))
			pPlayerNpc.nFightMode = 1;
			pPlayerNpc.AddSkillState(1517, 1,  0 , 5 * Env.GAME_FPS)
		end
	elseif szTrapName == "BackCampIn" then
		if pPlayerNpc.dwKinId == self.nOwnerKin then
			local tbPosBackCampIn = self.tbMapPosSetting.tbPosBackCampIn
			pPlayerNpc.SetPosition(unpack(tbPosBackCampIn[MathRandom(#tbPosBackCampIn)]))
			pPlayerNpc.nFightMode = 0;
		end
	else
		return true
	end
end

function tbBase:OnLogin()
	me.CallClientScript("DomainBattle:EnterFightMap", self.nSchedulePos, math.floor(Timer:GetRestTime(self.nMainTimer) / Env.GAME_FPS) ); 
end

function tbBase:OnMapDestroy()
	self:CloseBattle();
	if self.nMainTimer then
		Timer:Close(self.nMainTimer)
		self.nMainTimer = nil
	end

	if self.nActiveTimer then
		Timer:Close(self.nActiveTimer)
		self.nActiveTimer = nil;
	end
end

function tbBase:StartFight()
	self.bOpenBattle = true;

	if DomainBattle:GetMapLevel(self.nMapTemplateId) == 3 then --野外的动态障碍是打开的
		for i, nNpcId in ipairs(self.tbCampDynamicObstacleNpcs) do
			local pNpc = KNpc.GetById(nNpcId)
			if pNpc then
				pNpc.Delete();
			end
		end
		OpenDynamicObstacle(self.nMapId, define.szDynamicObstacleCamp);	
	end
	

	local tbStartPutNpcs = self.tbMapPosSetting.tbStartPutNpcs
	if tbStartPutNpcs then
		for i, v in ipairs(tbStartPutNpcs) do
			local nNpcTemplate, nX, nY, nDir = unpack(v)
			KNpc.Add(nNpcTemplate, 1, 0, self.nMapId, nX, nY, 0, nDir)
		end
	end

	local fnNofiy = function (pPlayer)
		pPlayer.CenterMsg("戰鬥開始了！", true)
		pPlayer.SetPkMode(Player.MODE_CUSTOM, self.tbKinPkIndex[pPlayer.dwKinId]);
	end
	self:ForEachInMap(fnNofiy)
	KPlayer.MapBoardcastScript(self.nMapId, "Ui:OpenWindow", "DomainBattleHomeInfo", self.nSchedulePos + 1)

	self.nActiveCount = 0
	self.nActiveTimer = Timer:Register(Env.GAME_FPS, function ()
		self.nActiveCount = self.nActiveCount + 1
		self:Active()
		return true
	end)
end

function tbBase:StopFight()
	self.bStopBattle = true;
	--判断下龙柱的归属及获胜方
	local tbWinKin = DomainBattle:GetWinKin(self.tbFlagState, self.nMapTemplateId)
	local dwWinId, szWinName;
	if tbWinKin then
		dwWinId, szWinName = unpack(tbWinKin)
		DomainBattle:SetMapOwner(self.nMapTemplateId, dwWinId)
	end
		
	Lib:LogTB(self.tbFlagState)
	Log("DomainBattle Result wind Kin ", dwWinId, szWinName, self.nMapTemplateId, self.nMapId)

	local szMsg = dwWinId and string.format("恭喜%s幫派佔據了%s", szWinName, Map:GetMapName(self.nMapTemplateId)) or "本場無戰果" 
	local fnNofiy = function (pPlayer)
		pPlayer.CenterMsg(szMsg, true)
		pPlayer.SetPkMode(Player.MODE_PEACE);
	end
	self:ForEachInMap(fnNofiy)	
	

	for nNpcId,v in pairs(self.tbCampNpcs) do
		local pNpc = KNpc.GetById(nNpcId)
		if pNpc then
			pNpc.SetCamp(0)
		end
	end

	DomainBattle:StopActivity(self.nMapTemplateId)

	if self.nActiveTimer then
		Timer:Close(self.nActiveTimer)
		self.nActiveTimer = nil;
	end
	--因为StopActivity 同步战报里已经同步了时间， 这里是执行打开操作就不放同步时间前了
	KPlayer.MapBoardcastScript(self.nMapId, "Ui:OpenWindow", "DomainBattleHomeInfo", self.nSchedulePos + 1)
end

function tbBase:CloseBattle()
	local fnKick = function (pPlayer)
		local kinData = Kin:GetKinById(pPlayer.dwKinId);
		if kinData then
			kinData:GoMap(pPlayer.dwID);
		end
	end
	self:ForEachInMap(fnKick)
end


function tbBase:ForEachInMap(fnFunction)
	local tbPlayer = KPlayer.GetMapPlayer(self.nMapId);
	for _, pPlayer in ipairs(tbPlayer) do
		fnFunction(pPlayer);
	end
end

function tbBase:OnPlayerDeath(pKillerLuna)
	if me.dwKinId ~= self.nOwnerKin then 	--因为征战是可换的
		local nPosX, nPosY = unpack( self.tbMapPosSetting.tbAtackPos[self.tbKinAttackCampIndex[me.dwKinId] ] )
		me.SetTempRevivePos(self.nMapId, nPosX, nPosY);
	end

	me.Revive(0)
	me.GetNpc().ClearAllSkillCD();
	me.nFightMode = 0

	me.nDomainBattleCombo = 0;
	me.CallClientScript("DomainBattle:ShowComboKillCount", 0) --TODO

	if not pKillerLuna then
		return
	end
	local pKiller = pKillerLuna.GetPlayer()
	if not pKiller then
		return
	end

	self:OnKillPlayer(pKiller, pDeader)
end

function tbBase:OnKillPlayer(pKiller, pDeader)
	if self.bStopBattle then
		return
	end
	local nDomainBattleCombo = (pKiller.nDomainBattleCombo or 0) + 1
	pKiller.nDomainBattleCombo = nDomainBattleCombo
	if nDomainBattleCombo % 10 == 0 then
		ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.Kin, string.format("「%s」在攻城戰中，連斬%s人！", pKiller.szName, nDomainBattleCombo), pKiller.dwKinId);	
	end
	pKiller.CallClientScript("DomainBattle:ShowComboKillCount", nDomainBattleCombo)
	DomainBattle:AddBattleScore(pKiller, define.nKillPlayerAddScore, 1)
	Achievement:AddCount(pKiller, "DomainBattle_1", 1)
	RecordStone:AddRecordCount(pKiller, "Domain", 1)
end

--创建龙柱npc
function tbBase:CreateCampNpc(nFlagIndex, dwKinId, nDelay)
	if dwKinId ~= - 1 and not self.tbKinPkIndex[dwKinId] then
		Log("Error DomainBattle add CampNpc ", self.nMapId, dwKinId);
		Lib:LogTB(self.tbKinPkIndex)
		dwKinId = - 1;
	end
	local tbKin = Kin:GetKinById(dwKinId)
	if not tbKin then
		tbKin = {szName = "無人"}; 
	end

	self.tbFlagState[nFlagIndex] = {dwKinId, tbKin.szName};	

	for k,v in pairs(self.tbKinPkIndex) do
		DomainBattle:SetKinBattleReporteVersion(k)	
	end

	local szTitle = string.format("「%s」佔據", tbKin.szName)
	local tbFlogNpcPos = self.tbMapPosSetting.tbFlogNpcPos[nFlagIndex]
	local nNpcTemplate, _, nX, nY, nDir, szNpcIndex = unpack(tbFlogNpcPos)
	self.tbMapShowInfo[szNpcIndex] = string.format("「%s」佔據", tbKin.szName) 

	local fnAddNpc = function ()
		local pNpc = KNpc.Add(nNpcTemplate, DomainBattle.nTimeFrameNpcLevel, 0, self.nMapId, nX, nY, 0, nDir)
		if not pNpc then
			Log(nNpcTemplate, self.nMapId, nX, nY,nDir, debug.traceback())
			return
		end
		local nSkillId, nSkillLevel = unpack(define.tbDoorBuff)
		pNpc.AddSkillState(nSkillId, DomainBattle.nTimeFrameLevel,  0 , 3600 * Env.GAME_FPS)
		local nSkillId, nSkillLevel = unpack(define.tbFlagBuff)
		pNpc.AddFightSkill(nSkillId, nSkillLevel)


		pNpc.SetPkMode(3, self.tbKinPkIndex[dwKinId]);
		pNpc.SetTitle(szTitle)
		pNpc.nFlagIndex = nFlagIndex
		self.tbCampNpcs[pNpc.nId] = 1;
		self.tbFlogNpcHpState[pNpc.nId] = pNpc.nCurLife
		if self.bStopBattle then
			pNpc.SetCamp(0)
		end
		if nDelay then
			KPlayer.MapBoardcastScript(self.nMapId, "Ui:OpenWindow", "BloodPanel", self.tbCampNpcs)	
		end
	end

	if not nDelay  then
		fnAddNpc()
	else
		Timer:Register(nDelay, fnAddNpc)	
	end
end

--龙柱的击杀
function tbBase:OnFlagDeath(him, pKiller, nFlagIndex)
	local tbSortDamage = him.GetDamageInfo();
	local dwKillKinId;
	if not tbSortDamage or #tbSortDamage <= 0 then
		if pKiller then
			local nMode, nCustom = pKiller.GetPkMode()
			if nMode == 3 then
				for dwKinId, v in pairs(self.tbKinPkIndex) do
					if v == nCustom then
						dwKillKinId = dwKinId
						break
					end
				end
			end
			Log("tbBase:OnFlagDeath ", self.nMapId, self.nMapTemplateId, dwKillKinId, nMode, nCustom, pKiller.szName)
		end
    else
    	local function fnDamageCmp(a, b)
	        return a.nTotalDamage > b.nTotalDamage;
	    end
	    table.sort(tbSortDamage, fnDamageCmp);
	    local tbKinSort = {};
	    for nRank, tbDmgInfo in ipairs(tbSortDamage) do
	        local nCaptainId = -1;
	        local tbTeam = nil;
	        if tbDmgInfo.nTeamId > 0 then
	            tbTeam = TeamMgr:GetTeamById(tbDmgInfo.nTeamId);
	        end    
	        if tbTeam then
	        	--取队伍里第一个在本地图的人，防止队长不是本家族也不在本地图
	            local tbMembers = tbTeam:GetMembers()
	            for _, nPlayerID in pairs(tbMembers) do
	            	local pMember = KPlayer.GetPlayerObjById(nPlayerID);
	            	if pMember and pMember.nMapId == self.nMapId then
	            		nCaptainId = pMember.dwID
	            		break;
	            	end
	            end
	        elseif tbDmgInfo.nAttackRoleId > 0 then
	            nCaptainId = tbDmgInfo.nAttackRoleId;
	        end

	        if nCaptainId > 0 then
	            local nKinId = self:GetPlayerKinID(nCaptainId)
	            if nKinId > 0 then
	                tbKinSort[nKinId] = (tbKinSort[nKinId] or 0) + tbDmgInfo.nTotalDamage;
	            end
	        end    
	    end

	    local tbSortDmg = {};
	    for nKinId, nDmg in pairs(tbKinSort) do
	        table.insert(tbSortDmg, {nKinId, nDmg});
	    end

	    local function fnKinDamage(a, b)
	        return a[2] > b[2];
	    end
	    table.sort(tbSortDmg, fnKinDamage);	
	    dwKillKinId = tbSortDmg[1][1]
    end

    if not dwKillKinId then
    	Log(self.nMapId, self.nMapTemplateId, debug.traceback())
    	return
    end
    
	DomainBattle:AddMapKinScore(self.nMapId, dwKillKinId, define.nKillFlagAddScore, string.format("摧毀%s獲得了%d積分！", him.szName, define.nKillFlagAddScore))

	local tbFlagState = self.tbFlagState[nFlagIndex]
	local dwOldKinId = tbFlagState[1]
	if dwOldKinId and dwOldKinId ~= -1 then
		ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.Kin, string.format("本幫派的%s——%s已被摧毀！", Map:GetMapName(self.nMapTemplateId), him.szName ), dwOldKinId);	
	end

	self:CreateCampNpc(nFlagIndex, dwKillKinId, Env.GAME_FPS * 5)
	ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.Kin, string.format("本幫派成功佔據了%s——%s！", Map:GetMapName(self.nMapTemplateId), him.szName ), dwKillKinId);
end

--城门的击杀
function tbBase:OnDoorDeath(him, pKiller, nDoorIndex)
	local tbDoorInfo = self.tbMapPosSetting.Doors[nDoorIndex]
	local _,_,_, szObstacle, szDoorNpc, szTrapName, szGateName = unpack(tbDoorInfo)
	self.tbMapShowInfo[szDoorNpc] = "已擊破"
	OpenDynamicObstacle(self.nMapId, szObstacle);
	self.tbInvalidTraps[szTrapName] = 1;
	self:BlackMsg(szGateName .. "已被摧毀！")
end

function tbBase:OnNpcDeath(him, pKiller)
	if self.bStopBattle then
		return
	end
	if self.tbCampNpcs[him.nId] then
		self.tbCampNpcs[him.nId] = nil;
		KPlayer.MapBoardcastScript(self.nMapId, "Ui:OpenWindow", "BloodPanel", self.tbCampNpcs)
	end
	
	self.tbFlogNpcHpState[him.nId] = nil;

	local nKillNpcAddScore = him.nKillNpcAddScore
	if nKillNpcAddScore then
		if pKiller then
			local pPlayer = pKiller.GetPlayer()
			if pPlayer then
				DomainBattle:AddBattleScore(pPlayer, nKillNpcAddScore, 0)
				pPlayer.CenterMsg(string.format("摧毀%s獲得了%d積分！", him.szName, nKillNpcAddScore))
			end
		end
	end

	local nFlagIndex = him.nFlagIndex
	if nFlagIndex then
		self:OnFlagDeath(him, pKiller, nFlagIndex)
		return 
	end

	local nDoorIndex = him.nDoorIndex
	if nDoorIndex then
		self:OnDoorDeath(him, pKiller, nDoorIndex)
		return 
	end
end

function tbBase:BlackMsg(szMsg)
	local fnExcute = function (pPlayer)
		Dialog:SendBlackBoardMsg(pPlayer, szMsg);
	end
	self:ForEachInMap(fnExcute);
end


function tbBase:GetPlayerKinID(nPlayerID)
    local pPlayer = KPlayer.GetPlayerObjById(nPlayerID);
    local nKinId = 0;
    if pPlayer then
        nKinId = pPlayer.dwKinId;
    else
        local tbStayInfo = KPlayer.GetRoleStayInfo(nPlayerID);
        if tbStayInfo then
            nKinId = tbStayInfo.dwKinId;
        end    
    end

    return nKinId;
end

function tbBase:UseSupplys(pPlayer, nItemId)
	local tbKin = Kin:GetKinById(pPlayer.dwKinId)
	if not tbKin then
		return
	end

	local tbMember = Kin:GetMemberData(pPlayer.dwID)
	if not tbMember then
		return
	end

	local tbBattleSupply = tbKin:GetBattleApplys();
	if not nItemId then
		return
	end

	local nCareer = tbMember:GetCareer()
	if not define.tbCanUseItemCareer[nCareer] then
		pPlayer.CenterMsg("您的許可權不足")
		return
	end

	if not tbBattleSupply[nItemId] or tbBattleSupply[nItemId] <= 0 then
		pPlayer.CenterMsg("該道具已經沒有庫存")
		pPlayer.CallClientScript("DomainBattle:OnSynBattleSupply", tbBattleSupply)
		return
	end

	local tbItemUseInfo = define.tbBattleApplyIds[nItemId]
	if not tbItemUseInfo then
		return
	end

	local bRet, szMsg =  self[tbItemUseInfo[1]](self, pPlayer, unpack(tbItemUseInfo, 2))
	if szMsg then
		pPlayer.CenterMsg(szMsg, true)
	end
	if bRet then
		local bRet, tbBattleSupplyNew = tbKin:UseBattleApplys(nItemId)	
		tbBattleSupply = tbBattleSupplyNew
		if not bRet then
			Log(pPlayer.dwKinId, pPlayer.dwID, nItemId, debug.traceback())
		end
		return tbBattleSupply
	end
end

--使用的战争道具 --TODO 使用区域检查
function tbBase:UseItemCallDialogNpc(pPlayer, nNpcId, nDir, bIsVehicles, szItemName)
	local tbNpcList = KNpc.GetAroundNpcList(me.GetNpc(), define.nCallNpcMinDistance);
	local nDomainDialogCount = 0;
	for i, pNpc in ipairs(tbNpcList) do
		if pNpc.szClass == "DomainBattleChange" then
			return false, "附近已有同類型"
		end
	end
	if bIsVehicles then --如果是攻城车
		if DomainBattle:GetMapLevel(self.nMapTemplateId) == 3 then
			return false, "攻城車不能在野外領地使用"
		end
		if pPlayer.dwKinId == self.nOwnerKin then
			return false, "守方不能用攻城車"
		end
	end

	if pPlayer.nFightMode ~= 0 then
		return false, "請在營地使用"
	end

	local nMapId, nX, nY = pPlayer.GetWorldPos()
	local pNpc = KNpc.Add(nNpcId, 1, 0, nMapId, nX, nY, 0, nDir)
	if pNpc then
		pNpc.dwKinId = pPlayer.dwKinId
		local tbKin = Kin:GetKinById(pPlayer.dwKinId)
		pNpc.SetTitle(tbKin.szName)
		return true,  string.format("使用成功，身邊出現了一個「%s」，請點擊選擇變身。", szItemName) 
	end
end

--使用的战争道具 --TODO 使用区域检查
function tbBase:UseItemCallAttackNpc(pPlayer, nNpcId, nDir, szNpcName, nKillNpcAddScore)
	local dwKinId = pPlayer.dwKinId

	if pPlayer.nFightMode ~= 1 then
		return false, "請在戰鬥區域使用"
	end

	-- TODO 召唤npc的强度根据时间轴
	local nMapId, nX, nY = pPlayer.GetWorldPos()
	local pNpc = KNpc.Add(nNpcId, DomainBattle.nTimeFrameNpcLevel, 0, nMapId, nX, nY, 0, nDir)
	if pNpc then
		pNpc.dwKinId = dwKinId
		local tbKin = Kin:GetKinById(dwKinId)
		pNpc.SetTitle(tbKin.szName)
		local nCampIndex = self.tbKinPkIndex[dwKinId]
		pNpc.SetPkMode(3, nCampIndex)
		pNpc.nKillNpcAddScore = nKillNpcAddScore
		return true, string.format("使用成功，身邊出現了一個「%s」！", szNpcName)
	end
end

function tbBase:OnSelectNpcDialog(pPlayer, nNpcId, nChangeSkillId, szText, nDuraSeconds)
	if pPlayer.GetNpc().nShapeShiftNpcTID ~= 0 then
		pPlayer.CenterMsg("您目前已經變身")
		return
	end

	local pNpc = KNpc.GetById(nNpcId)
	if not pNpc then
		return
	end
	local tbInfo = self.tbRoleInfo[pPlayer.dwID]
	if not tbInfo then
		return
	end

	if pPlayer.nFightMode ~= 0 then
		pPlayer.CenterMsg("請在營地使用")
		return
	end

	if nChangeSkillId then
	    for nSkillId, _ in pairs(tbInfo.tbSkillState) do
	    	pPlayer.RemoveSkillState(nSkillId);	
	    end
		
		pPlayer.AddSkillState(nChangeSkillId, DomainBattle.nTimeFrameLevel,  0 , nDuraSeconds * Env.GAME_FPS) 
		pPlayer.CenterMsg(string.format("成功變身為「%s」", szText))
		tbInfo.tbSkillState[nChangeSkillId] = 1;
	end

	pNpc.Delete();
end

function tbBase:RequestMapInfo(pPlayer)
	pPlayer.CallClientScript("DomainBattle:OnSynMiniMapInfo", self.tbMapShowInfo)
end
