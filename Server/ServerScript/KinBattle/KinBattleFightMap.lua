Require("CommonScript/KinBattle/KinBattleCommon.lua");
Require("CommonScript/Battle/BattleComBase.lua");
Require("CommonScript/Battle/BattleComDota.lua");


KinBattle.FightMapClass = Battle:GetClass("KinBattle") or Battle:CreateClass("KinBattle", "BattleComBase");
local tbFightMap = KinBattle.FightMapClass;
local tbBaseClass = Battle:GetClass("BattleComBase");
local tbDotaCom = Battle.tbDotaCom;

function tbFightMap:Init(nMapId, tbKinInfo, nType)
	self.tbBattleSetting = Lib:CopyTB(Battle.tbAllBattleSetting["KinBattle"]);
	self.nMapId = nMapId;
	self.nKinBattleType = nType;
	self.tbKinInfo = tbKinInfo;

	self.tbTeamIndex = {};
	self.tbTeamNames = {};
	self.tbPlayerInfos = {};
	self.tbBattleRank = {};
	self.nKinBattleStartTime = GetTime();
	self.szKinBattleName = "";
	for nTeamIndex, nKinId in pairs(self.tbKinInfo) do
		local tbKinData = Kin:GetKinById(nKinId);
		self.tbTeamNames[nTeamIndex] = tbKinData.szName;
		self.tbTeamIndex[nKinId] = nTeamIndex;
		self.szKinBattleName = self.szKinBattleName .. tbKinData.szName .. "\t";
	end

	self.tbBattleSetting.tbTeamNames = self.tbTeamNames;
	tbDotaCom.Init(self);
end

function tbFightMap:StartFight()
	Log("[KinBattle] StartFight", self.nMapId, self.szKinBattleName);

	tbBaseClass.StartFight(self);
	tbDotaCom.StartFight(self);
end

function tbFightMap:StopFight()
	Log("[KinBattle] StopFight", self.nMapId, self.szKinBattleName);

	local nCostTime = GetTime() - self.nKinBattleStartTime;
	local nWinTeam = self:SetWinTeam();
	local szNotify = string.format("比賽結束，恭喜%s獲得了勝利", self.tbTeamNames[nWinTeam]);
	for nPlayerId, tbInfo in pairs(self.tbPlayerInfos) do
		local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
		if pPlayer then
			pPlayer.SetPkMode(0);
			pPlayer.CenterMsg(szNotify, true);
			self:GotoBackBattle(pPlayer);

			local nResult = tbInfo.nTeamIndex == nWinTeam and Env.LogRound_SUCCESS or Env.LogRound_FAIL;
			pPlayer.TLogRoundFlow(Env.LogWay_KinBattle, pPlayer.nMapTemplateId, self.tbTeamScore[tbInfo.nTeamIndex] or 0, nCostTime, nResult, 0, 0);
			pPlayer.TLog("KinMemberFlow", pPlayer.dwKinId, Env.LogWay_KinBattle, self.tbTeamScore[tbInfo.nTeamIndex] or 0, nResult)
		end
	end

	for nTeamIndex, nKinId in pairs(self.tbKinInfo) do
		KinBattle:SetKinBattleResult(nKinId, self.nKinBattleType, nTeamIndex == nWinTeam and 1 or 0);
	end

	self.nIsClose = 1;
	KinBattle:CheckKinBattleEnd();
end

function tbFightMap:CloseBattle()
	Log("[KinBattle] CloseBattle", self.nMapId, self.szKinBattleName);

	local fnKick = function (pPlayer)
		pPlayer.GotoEntryPoint()
	end
	self:ForEachInMap(fnKick)

	if self.nActiveTimer then
		Timer:Close(self.nActiveTimer)
		self.nActiveTimer = nil
	end
end

--刷兵
function tbFightMap:Active()
	local nTimeNow = GetTime();
	self:CheckStayInCamp(nTimeNow)
	self:SyncAllInfo(nTimeNow)

	tbDotaCom.Active(self, nTimeNow)
end

function tbFightMap:ForEachInMap(fnFunction)
	local tbPlayer = KPlayer.GetMapPlayer(self.nMapId);
	for _, pPlayer in ipairs(tbPlayer) do
		fnFunction(pPlayer);
	end
end

function tbFightMap:SyncAllInfo(nTimeNow)
	if self.bRankUpdate then
		self:UpdatePlayerRank()
		KPlayer.MapBoardcastScript(self.nMapId, "Battle:UpdateRankData", self.tbBattleRank, self.tbTeamScore, math.floor(Timer:GetRestTime(self.nMainTimer) / Env.GAME_FPS))
		self.bRankUpdate = false
	end
end

function tbFightMap:OnNpcDeath(him, pKiller)
	tbDotaCom.OnNpcDeath(self, him, pKiller)
end

--玩家杀死非玩家npc时
function tbFightMap:OnKillNpc()
	tbDotaCom.OnKillNpc(self, me);
end

function tbFightMap:OnPlayerDeath(pKillerLuna)
	Log("[KinBattle] OnPlayerDeath", me.dwID, me.szName, self.nMapId, self.szKinBattleName);

	me.Revive(0)
	me.SetPkMode(0) --是自动回到了后营了，从后营出来才改战斗状态
	me.GetNpc().ClearAllSkillCD();

	--给一个复活的buff
	local nSkillId, nSkillLevel, nSkillTime = unpack(Battle.tbRevieBuff)
	me.AddSkillState(nSkillId, nSkillLevel,  0 , nSkillTime * Env.GAME_FPS)

	local tbMyInfo = self.tbPlayerInfos[me.dwID]
	tbMyInfo.nDeathCount = tbMyInfo.nDeathCount + 1
	tbMyInfo.nComboCount = 0;
	local nDeadComboLevel = tbMyInfo.nComboLevel
	tbMyInfo.nComboLevel = 1;
	me.CallClientScript("Ui:ShowComboKillCount", 0, true)
	tbMyInfo.nInBackCampTime = GetTime();

	if not pKillerLuna then
		return;
	end
	local pKiller = pKillerLuna.GetPlayer()
	if not pKiller then
		return;
	end

	self:OnKillPlayer(pKiller, me, nDeadComboLevel, tbMyInfo.nTitleLevel);
end

function tbFightMap:OnPlayerTrap(szTrapName)
	if self.nBattleOpen ~= 1 then
		me.CenterMsg("戰鬥還沒有打響哦，請稍等片刻")
		return
	end
	if szClassName == "CanghaiToErengu" then --todo 只是试下
		self:GotoFrontBattle(me);
	end
end

function tbFightMap:UpdatePlayerTitle(pPlayer, nTitleLevel, nDelTitleLevel)
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

function tbFightMap:OnEnter()
	if not self.tbPlayerInfos[me.dwID] then
		self.tbPlayerInfos[me.dwID] = {
			dwID = me.dwID,
			nFaction = me.nFaction,
			szName = me.szName,
			nTeamIndex = self.tbTeamIndex[me.dwKinId],
			nScore = 0,
			nKillCount = 0,
			nMaxCombo = 0,
			nComboCount = 0
		};
		table.insert(self.tbBattleRank, self.tbPlayerInfos[me.dwID]);
	end

	local tbInfo = self.tbPlayerInfos[me.dwID];
	if not tbInfo or not tbInfo.nTeamIndex then
		me.GotoEntryPoint();
		return;
	end

	me.nInBattleState = 1; --战场模式
	me.bForbidChangePk = 1;
	me.SetPkMode(3, tbInfo.nTeamIndex);
	me.SetTempRevivePos(self.nMapId, unpack(KinBattle.tbFightMapBeginPoint[tbInfo.nTeamIndex]));  --设置临时复活点
	me.SetPosition(unpack(KinBattle.tbFightMapBeginPoint[tbInfo.nTeamIndex]));

	tbInfo.nOnDeathRegID = PlayerEvent:Register(me, "OnDeath", self.OnPlayerDeath, self);
	tbInfo.nOnReviveRegID = PlayerEvent:Register(me, "OnRevive", function () end);
	tbInfo.nOnKillNpcRegID = PlayerEvent:Register(me, "OnKillNpc", self.OnKillNpc, self);

	self:InitPlayerBattleInfo(tbInfo)

	tbInfo.nOrgTitleId = me.LockTitle(true); --现在进场是先
	me.ActiveTitle(0, false);
	me.CallClientScript("Battle:EnterFightMap", self.tbBattleSetting);

	Kin:JoinChatRoom(me)
end

function tbFightMap:OnLeave()
	me.nInBattleState = 0; --战场模式
	me.bForbidChangePk = 0;

	me.SetPkMode(0)
	me.ClearTempRevivePos()

	local tbInfo = self.tbPlayerInfos[me.dwID]
	if not tbInfo then
		Log("Error!!! Battle map miss tbPlayerInfos")
		return;
	end

	--删掉玩家获取的称号
	me.LockTitle(nil);
	self:UpdatePlayerTitle(me, nil, tbInfo.nTitleLevel)
	if tbInfo.nOrgTitleId ~= 0 then
		me.ActiveTitle(tbInfo.nOrgTitleId, false);
	end

	if tbInfo.nOnDeathRegID then
		PlayerEvent:UnRegister(me, "OnDeath", tbInfo.nOnDeathRegID);
		tbInfo.nOnDeathRegID = nil;
	end
	if tbInfo.nOnReviveRegID then
		PlayerEvent:UnRegister(me, "OnRevive", tbInfo.nOnReviveRegID);
		tbInfo.nOnReviveRegID = nil;
	end
	if tbInfo.nOnKillNpcRegID then
		PlayerEvent:UnRegister(me, "OnKillNpc", tbInfo.nOnKillNpcRegID);
		tbInfo.nOnKillNpcRegID = nil;
	end

	ChatMgr:LeaveKinChatRoom(me);
end

function tbFightMap:MemberJoinKinChatRoom(dwKinId)
	local tbPlayer = KPlayer.GetMapPlayer(self.nMapId)
	for _, pPlayer in ipairs(tbPlayer) do
		if dwKinId == pPlayer.dwKinId then
			Kin:JoinChatRoom(pPlayer)
		end
	end
end

--------------------------------------------------------------------------------------
local tbMap = Map:GetClass(KinBattle.FIGHT_MAP_ID);
function tbMap:OnCreate(nMapId)
	KinBattle:OnFightMapCreate(nMapId);
end

function tbMap:OnEnter(nMapId)
	local tbInst = KinBattle.tbFightInstanceByMapId[nMapId];
	if not tbInst then
		Log("[KinBattle] ERR ?? unknow fight map !! ", nMapId);
		Lib:LogTB(tbInst);
		return;
	end

	tbInst:OnEnter();
end

function tbMap:OnLeave(nMapId)
	local tbInst = KinBattle.tbFightInstanceByMapId[nMapId];
	if not tbInst then
		Log("[KinBattle] ERR ?? unknow fight map !! ", nMapId);
		Lib:LogTB(tbInst);
		return;
	end

	tbInst:OnLeave();
end
