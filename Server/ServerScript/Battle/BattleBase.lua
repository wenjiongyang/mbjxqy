local tbBase = Battle:CreateClass("BattleServerBase", "BattleComBase")

function tbBase:Init(nMapId, tbBattleSetting, tbPlayerInfos, tbTeamA, tbTeamB, nReadyMapIndex)
	self.nMapId = nMapId;
	self.bZone = MODULE_ZONESERVER and true or false; --拿来区分是否低价跨服了
	self.tbBattleSetting = tbBattleSetting;
	self.tbPlayerInfos = tbPlayerInfos;
	self.nReadyMapIndex = nReadyMapIndex
	self.tbTeams = {tbTeamA, tbTeamB}  --todo 看下有用没

	--初始化排行榜 客户端显示的战报信息
	self.tbBattleRank = {}
    for dwRoleId, v in pairs(tbPlayerInfos) do
    	self:InitPlayerBattleInfo(v)
        table.insert(self.tbBattleRank, {dwID = dwRoleId, nFaction = v.nFaction, szName = v.szName, nTeamIndex = v.nTeamIndex, nScore = 0, nKillCount = 0, nMaxCombo = 0, nComboCount = 0});
    end

    --根据现在的时间轴初始化奖励设置
    local szAwardDesc = #self.tbBattleRank > tbBattleSetting.nPlayerMinNum and tbBattleSetting.tbAwardSetBig or tbBattleSetting.tbAwardSetSmall
    local tbAwardTime = Battle.tbTimeFrameAward[szAwardDesc]
    if tbAwardTime then
    	local nIndex = 0
    	for i, szTimeFrame in ipairs(tbAwardTime) do
    		if GetTimeFrameState(szTimeFrame) == 1 then
    			nIndex = i;
    		else
    			break;
    		end
    	end
    	assert(nIndex > 0)
    	self.tbAwardSet = Battle.tbAllAwardSet[szAwardDesc.."_"..nIndex]
    else
    	self.tbAwardSet = Battle.tbAllAwardSet[szAwardDesc]
    end
    assert(self.tbAwardSet)
end


function tbBase:OnLogin()
	me.CallClientScript("Battle:EnterFightMap", self.tbBattleSetting.nIndex, self.nSchedulePos, math.floor(Timer:GetRestTime(self.nMainTimer) / Env.GAME_FPS)  )
end

--schd
function tbBase:StopFight()
	local nWinTeam = self:SetWinTeam();
	local szWinNotify  = "本方勢如破竹，大獲全勝"
	local szLostNotify = "本方力戰不敵，鳴金收兵"
	local nTotalRankNum = #self.tbBattleRank

	local nMatchTime = GetTime() - self.nStartTime

	local tbExChangeBoxInfo = Battle.tbAllAwardSet.tbExChangeBoxInfo
	local bHonor = self.tbBattleSetting.tbAwardSetBig ~= "BattleAwardMonth";
	local szMsgFormt = bHonor and "本次戰場你勇奪第%d名，獲得%d點戰場榮譽" or "本次戰場你勇奪第%d名，獲得%d點元氣";

	for nRank, tbRankInfo in ipairs(self.tbBattleRank) do
		local dwRoleId = tbRankInfo.dwID
		local tbInfo = self.tbPlayerInfos[dwRoleId]
		if not tbInfo.bNotJoin then
			local tbAchievenments = {};
			local pPlayer = KPlayer.GetPlayerObjById(dwRoleId)
			local tbAward = Battle:GetAward(nRank, tbInfo.nScore, self.tbAwardSet, self.tbBattleSetting.nMin_AWARD_SCORE);
			local tbBattleInfo;

			local nGetHonor = 0;
			for i,v in ipairs(tbAward) do
				if v[1] ~= "BasicExp" then
					nGetHonor = nGetHonor + v[2]
				end
			end

			tbRankInfo.nGetHonor = nGetHonor
			local szMsg = string.format(szMsgFormt, nRank, nGetHonor);

			if pPlayer and self.nMapId == pPlayer.nMapId then
				if nWinTeam == tbInfo.nTeamIndex then
					pPlayer.CenterMsg(szWinNotify, true)	
					table.insert(tbAchievenments, "Battle_3")
				else
					pPlayer.CenterMsg(szLostNotify, true)	
				end

				self:GotoBackBattle(pPlayer)
				pPlayer.SetPkMode(0)
				
				Dialog:SendBlackBoardMsg(pPlayer, szMsg);

				if nRank <= nTotalRankNum / 2  then
					table.insert(tbAchievenments, "Rank_1")
					if nRank <= 3 then
						table.insert(tbAchievenments, "Rank_2")
						if nRank == 1 then
							table.insert(tbAchievenments, "Rank_3")
						end	
					end	
				end
				tbBattleInfo = 
				{
					nMapTemplateId = self.tbBattleSetting.nMapTemplateId;
					szLogicClass = self.tbBattleSetting.szLogicClass;
					nScore = tbInfo.nScore;
					nMatchTime = nMatchTime;
					nResult = (nWinTeam == tbInfo.nTeamIndex and Env.LogRound_SUCCESS or Env.LogRound_FAIL);
					nRank = nRank;
					nKillCount = tbInfo.nKillCount;
					nMaxCombo = tbInfo.nMaxCombo;
					nDeathCount = tbInfo.nDeathCount;
					bZone = self.bZone;
				}
			end
			if bHonor then
				szMsg = szMsg .. string.format("（%s）", Battle.szBoxExchangeTip)
			end
			Battle:OnGetAwardEvent(dwRoleId, tbAchievenments, tbAward, tbBattleInfo, szMsg)
		end
	end

	self:SynWinTeam(nWinTeam)

	Battle:OnGetBattleFirstEnven(self.tbBattleRank[1].dwID, self.tbBattleSetting.szLogicClass, self.nReadyMapIndex)
end

function tbBase:SynWinTeam(nWinTeam)
	self.bRankUpdate = true
	self:SyncAllInfo(GetTime())

	KPlayer.MapBoardcastScript(self.nMapId, "Battle:OnSynWinTeam", nWinTeam)
end

--sche 整个比赛结束清场了
function tbBase:CloseBattle()
	local fnKick = function (pPlayer)
		pPlayer.GotoEntryPoint()
	end
	self:ForEachInMap(fnKick)

	if self.nActiveTimer then
		Timer:Close(self.nActiveTimer)
		self.nActiveTimer = nil
	end
end

--地图被系统销毁时
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
	self:SyncAllInfo(nTimeNow)
end


function tbBase:OnEnter()
	local tbInfo = self.tbPlayerInfos[me.dwID]
	if not tbInfo then
		Log(debug.traceback(), me.dwID)
		if MODULE_ZONESERVER then
			me.ZoneLogout()
		else
			me.GotoEntryPoint()	
		end
		return
	end

	me.SetPosition(unpack(Battle:GetRandInitPos(tbInfo.nTeamIndex, self.tbBattleSetting))) 

	me.nInBattleState = 1; --战场模式

	me.bForbidChangePk = 1;
	
	me.SetPkMode(3, tbInfo.nTeamIndex)
	me.GetNpc().SetDir(self.tbBattleSetting.tbInitDir[tbInfo.nTeamIndex])


	-- pPlayer.SetNoDeathPunish(1); todo 死亡惩罚

	--todo
	-- 根据积分设置称号

    --因为不会有 重进战场，就不用反注册已有的 OnDeath OnRevive 等事件

    tbInfo.nOnDeathRegID = PlayerEvent:Register(me, "OnDeath", self.OnPlayerDeath, self);
    tbInfo.nOnReviveRegID = PlayerEvent:Register(me, "OnRevive", self.OnPlayerRevive, self);
    -- tbInfo.nOnKillNpcRegID = PlayerEvent:Register(me, "OnKillNpc", self.OnKillNpc, self);

    tbInfo.nOrgTitleId = me.LockTitle(true); --现在进场是先
    self:UpdatePlayerTitle(me, tbInfo.nTitleLevel)

    tbInfo.nOlgCamp = me.GetNpc().nCamp
    me.GetNpc().SetCamp(self.tbBattleSetting.tbCamVal[tbInfo.nTeamIndex]);
   -- self.tbTeamInfo[tbInfo.szTeam].nPlayerCount = self.tbTeamInfo[tbInfo.szTeam].nPlayerCount + 1;

	me.CallClientScript("Battle:EnterFightMap", self.tbBattleSetting.nIndex, self.nSchedulePos, math.floor(Timer:GetRestTime(self.nMainTimer) / Env.GAME_FPS));
end

--重载下
function tbBase:UpdatePlayerTitle(pPlayer, nTitleLevel, nDelTitleLevel)
--同类型的会自动替换掉时不用删除
	local tbInfo = self.tbPlayerInfos[pPlayer.dwID]
	if nDelTitleLevel then
		local nOldTitle = Battle.tbTitleLevelSet[nDelTitleLevel].tbTitleID[tbInfo.nTeamIndex]
		pPlayer.DeleteTitle(nOldTitle, true)
	end
	if nTitleLevel then
		pPlayer.AddTitle(Battle.tbTitleLevelSet[nTitleLevel].tbTitleID[tbInfo.nTeamIndex], 720, true, false, true)
	end
end

--重载
function tbBase:ForEachInMap(fnFunction)
	local tbPlayer = KPlayer.GetMapPlayer(self.nMapId);
	for _, pPlayer in ipairs(tbPlayer) do
		fnFunction(pPlayer);
	end
end

--在战场的每秒循环里，同步战场信息，目前是只同步改变的
--位置信息同步是在地图配置里的  SynAllPos
function tbBase:SyncAllInfo(nTimeNow)
	if self.bRankUpdate then
		self:UpdatePlayerRank()
		KPlayer.MapBoardcastScript(self.nMapId, "Battle:UpdateRankData", self.tbBattleRank, self.tbTeamScore, math.floor(Timer:GetRestTime(self.nMainTimer) / Env.GAME_FPS))
		self.bRankUpdate = false
	end
end

function tbBase:OnLeave()
	me.nInBattleState = 0; --战场模式
	me.bForbidChangePk = 0;

	me.SetPkMode(0)
	me.ClearTempRevivePos()

	local tbInfo = self.tbPlayerInfos[me.dwID]
	if not tbInfo then
		Log("Error!!! Battle map miss tbPlayerInfos")
		return
	end

	--删掉玩家获取的称号
	me.LockTitle(nil);
	self:UpdatePlayerTitle(me, nil, tbInfo.nTitleLevel)
	if tbInfo.nOrgTitleId ~= 0 then
		me.ActiveTitle(tbInfo.nOrgTitleId, false);
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
  --   if tbInfo.nOnKillNpcRegID then
		-- PlayerEvent:UnRegister(me, "OnKillNpc", tbInfo.nOnKillNpcRegID);
		-- tbInfo.nOnKillNpcRegID = nil;
  --   end
  --因为是先logout 的，所以还是 在这里做区分吧
  	self:OnLeaveZoneBattleMap(me)
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

function tbBase:OnPlayerDeath(pKillerLuna)
	local tbMyInfo = self.tbPlayerInfos[me.dwID]	
	me.SetTempRevivePos(self.nMapId, unpack(Battle:GetRandInitPos(tbMyInfo.nTeamIndex, self.tbBattleSetting)));  --设置临时复活点
	me.Revive(0)
	me.SetPkMode(0) --是自动回到了后营了，从后营出来才改战斗状态
	me.GetNpc().ClearAllSkillCD();
	me.GetNpc().SetDir(self.tbBattleSetting.tbInitDir[tbMyInfo.nTeamIndex])

	tbMyInfo.nDeathCount = tbMyInfo.nDeathCount + 1
	tbMyInfo.nComboCount = 0;
	local nDeadComboLevel = tbMyInfo.nComboLevel
	tbMyInfo.nComboLevel = 1;
	me.CallClientScript("Ui:ShowComboKillCount", 0, true)
	
	tbMyInfo.nInBackCampTime = GetTime();

	if not pKillerLuna then
		return
	end
	local pKiller = pKillerLuna.GetPlayer()
	if not pKiller then
		return
	end

	self:OnKillPlayer(pKiller, me, nDeadComboLevel, tbMyInfo.nTitleLevel);
end

function tbBase:OnPlayerRevive()
end

--BattleNpc 类型 npc 死亡时，无论怎么死的，在OnKillNpc 之前调
function tbBase:OnNpcDeath(him, pKiller)
end

--me 杀死非玩家npc时
-- function tbBase:OnKillNpc()
-- end

function tbBase:OnLeaveZoneBattleMap(pPlayer)
	-- body
end