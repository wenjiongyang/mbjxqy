--[[
-- 挑战武林盟主
Boss._tbPlayerData = {
	[nPlayerId] = {
		nScore =
	}
}

-- 数据对于到_PalyerData时的值, 作用在于用于排序
Boss._tbPlayerRankData = {
	[1] = ...;
	[2] = ...;
	}

Boss._tbKinData = {

}
]]

Boss.tbStateInfo = Boss.tbStateInfo or {};

function Boss:StateStart(szStateType, nStart)
	if not Boss.tbStateInfo[szStateType] then
		Boss.tbStateInfo[szStateType] = {
			nCount = 0;
			nTotal = 0;
			nPeak  = 0;
			nStart = 0;
		};
	end

	Boss.tbStateInfo[szStateType].nStart = nStart or GetRDTSC();
end

function Boss:StateEnd(szStateType, nEnd)
	local tbInfo = Boss.tbStateInfo[szStateType];
	local nCost = (nEnd or GetRDTSC()) - tbInfo.nStart;
	if nCost < 0 then
		return;
	end

	tbInfo.nCount = tbInfo.nCount + 1;
	tbInfo.nTotal = tbInfo.nTotal + nCost;
	if nCost > tbInfo.nPeak then
		tbInfo.nPeak = nCost;
	end
end

function Boss:LogState()
	Log("=========Boss:LogState============");
	Lib:Tree(Boss.tbStateInfo);
	Log("==================================");
	Boss.tbStateInfo = {};
end

function Boss:InitData()
	self._tbPlayerData = {};
	self._tbPlayerRankData = {};
	self._tbRobMap = {};
	self._tbKinData = {};
	self._tbKinRankData = {};
	self.bStart = false;
	self._tbBossData = nil;
	self.bPrepareFinish = nil;
	self.bSortKinRank = nil;
	self.bSortPlayerRank = nil;
end

function Boss:ClearRankShow()
	local tbRankData = Boss:GetBossRankData();
	tbRankData.tbPlayerRank = {};
	tbRankData.nPlayerRankVersion = 0;
	tbRankData.tbKinRank = {};
	tbRankData.nKinRankVersion = 0;
end

function Boss:GetBossHpAdjustRate()
	local tbScriptData = ScriptData:GetValue("Boss");
	return tbScriptData.nBossHpAdjustRate or 1;
end

function Boss:SetBossAdjustRate(nRate)
	local tbScriptData = ScriptData:GetValue("Boss");
	tbScriptData.nBossHpAdjustRate = nRate;

	ScriptData:SaveAtOnce("Boss", tbScriptData);
end

function Boss:GetBossRankData()
	local tbScriptData = ScriptData:GetValue("Boss");
	if not tbScriptData.tbRankData then
		tbScriptData.tbRankData = {};
	end
	return tbScriptData.tbRankData;
end

function Boss:MarkRobTable(nRober, nRobed)
	assert(self._tbRobMap);
	self._tbRobMap[nRobed] = self._tbRobMap[nRobed] or {};
	self._tbRobMap[nRobed][nRober] = true;
end

function Boss:GetRobers(nPlayerId)
	assert(self._tbRobMap);
	return self._tbRobMap[nPlayerId];
end

function Boss:GetBossData()
	return self._tbBossData;
end

-- 获取列表中列的值
local function GetItemValueFromSetting(nIth, tbItems)
	for i, v in ipairs(tbItems) do
		if nIth <= (v.Rank or v.Day) then
			return v;
		end
	end
end

function Boss:GetCurBossData()
	local tbCurBossData = Boss.Def.tbBossSetting[1];
	for _, tbItem in ipairs(Boss.Def.tbBossSetting) do
		if GetTimeFrameState(tbItem.TimeFrame) ~= 1 then
			break;
		end
		tbCurBossData = tbItem;
	end

	local tbBossInfo = {};
	tbBossInfo.Hp = tbCurBossData.Data.Hp;

	local tbNpcIds = tbCurBossData.Data.NpcIds;
	tbBossInfo.NpcId = tbNpcIds[MathRandom(1, #tbNpcIds)];

	return tbBossInfo;
end

function Boss:StartBossFight(nRound)
	Log("Boss:StartBossFight");

	self:InitData();
	self:ClearRankShow();

	local tbCurBossData = self:GetCurBossData();
	assert(tbCurBossData, "武林盟主 找不到設置");
	Log("Boss CurBossNpcInfo", tbCurBossData.NpcId, tbCurBossData.Hp);

	local nHpRate = Boss:GetBossHpAdjustRate();
	self._tbBossData = {
		nMaxHp = tbCurBossData.Hp;		--math.min(tbCurBossData.Hp * nHpRate, Boss.Def.nBossHpMaxValue);
		nCurHp = tbCurBossData.Hp;
		nNpcId = tbCurBossData.NpcId;
		nEndTime = GetTime() + Boss.Def.nTimeDuration;
		nStartTime = GetTime();
	}

	KPlayer.SendWorldNotify(Boss.Def.nPlayerEnterLevel - 1, 1000,
		"各位少俠！挑戰武林盟主已經準時開啟！通過「活動」前去挑戰獲得榮耀吧！",
		ChatMgr.ChannelType.Public, 1);

	local tbMsgData = {
		szType = "Boss";
		nTimeOut = GetTime() + Boss.Def.nTimeDuration;
	};

	local tbPlayer = KPlayer.GetAllPlayer();
	for _, pPlayer in pairs(tbPlayer) do
		if pPlayer.nLevel >= Boss.Def.nPlayerEnterLevel then
			pPlayer.CallClientScript("Ui:SynNotifyMsg", tbMsgData);
		end
	end

	self.nRound = nRound; -- 标识中午场1 还是 晚上场2
	self.bStart = true;

	self.nSortRankTimer = Timer:Register(Env.GAME_FPS * Boss.Def.nSortRankWaitingTime, self.SortRankActive, self);

	-- 5秒 check 一次活动end，直接起一个定时器在结束会受追帧影响
	self.nCheckTimer = Timer:Register(Env.GAME_FPS * Boss.Def.nCheckEndTime, self.CheckState, self);
	Calendar:OnActivityBegin("Boss");
end

function Boss:CheckState()
	local tbBossData = self:GetBossData()
	local nCurTime = GetTime();
	if not tbBossData or not self.nCheckTimer then
		return false;
	end
	tbBossData.nCurHp = math.max(tbBossData.nMaxHp * (tbBossData.nEndTime - nCurTime) / (tbBossData.nEndTime - tbBossData.nStartTime), 0);
	if nCurTime > tbBossData.nEndTime then
		if not self.bPrepareFinish then
			Boss:NotifyFinishBoss();
			self.nCheckTimer = nil;
		end
		return false;
	end
	return true;
end

function Boss:SortRankActive()
	if not Boss:IsOpen() then
		self.nSortRankTimer = nil;
		return false;
	end

	if self.bSortPlayerRank then
		self.bSortPlayerRank = nil;
		Boss:StateStart("SortPlayerRank");
		Boss:SortPlayerRank();
		Boss:StateEnd("SortPlayerRank");
	end

	if self.bSortKinRank then
		self.bSortKinRank = nil;
		Boss:StateStart("SortKinRank");
		Boss:SortKinRank();
		Boss:StateEnd("SortKinRank");
	end
	return true;
end

function Boss:IsOpen()
	return self.bStart and not self.bPrepareFinish;
end

function Boss:NotifyFinishBoss()
	if not self.bStart or self.bPrepareFinish then
		return;
	end
	self.bPrepareFinish = true;
	Log("Boss:NotifyFinishBoss");

	for nPlayerId, _ in pairs(self._tbPlayerData) do
		local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
		if pPlayer then
			pPlayer.CallClientScript("Boss:NotifyFinish");
		end
	end

	AsyncBattle:AllBattleExecute("BossFightBattle", "CloseBossBattle");
	AsyncBattle:AllBattleExecute("BossRobBattle", "CloseBossBattle");

	Timer:Register(Env.GAME_FPS * Boss.Def.nFinishWaitTime, self.FinishBoss, self);
end

function Boss:FinishBoss(pPlayer)
	if not self.bStart then
		return;
	end

	Log("Boss:FinishBoss");

	Calendar:OnActivityEnd("Boss");
	self.bStart = false;
	self.bPrepareFinish = nil;

	--考虑到参加活动时家族可能变更, 重新清算参与人数
	for nRank, tbKinData in ipairs(self._tbKinRankData) do
		tbKinData.nJoinMember = 0;
	end

	for nRank, tbPlayerData in ipairs(self._tbPlayerRankData) do
		local pRole = KPlayer.GetPlayerObjById(tbPlayerData.nPlayerId) or KPlayer.GetRoleStayInfo(tbPlayerData.nPlayerId);
		if pRole and pRole.dwKinId == tbPlayerData.nKinId and tbPlayerData.nKinId ~= 0 then
			local kinMemberData = Kin:GetMemberData(tbPlayerData.nPlayerId);
			if kinMemberData and not kinMemberData:IsRetire() then
				local tbKinData = Boss:GetKinData(pRole.dwKinId);
				if tbKinData then
					tbKinData.nJoinMember = tbKinData.nJoinMember + 1;
					tbKinData.tbFighter[tbPlayerData.nPlayerId] = true;
				end
			end
		end
	end

	-- 家族发奖
	Boss:SortKinRank();
	local tbKinTop1 = self._tbKinRankData[1];
	if tbKinTop1 then
		local szMsgFormat = "本輪挑戰武林盟主, [FFFF0E]「%s」[-]幫派以%d分獲得幫派總積分第一！";
		local szMsg = string.format(szMsgFormat, tbKinTop1.szName, tbKinTop1.nScore);
		ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.System, szMsg);
	end

	for nRank, tbKinData in ipairs(self._tbKinRankData) do
		Boss:SendKinReward(tbKinData, nRank);
	end

	-- 个人发奖
	Boss:SortPlayerRank();
	local tbPlayerTop1 = self._tbPlayerRankData[1];
	if tbPlayerTop1 then
		local szMsgFormat = "[FFFF0E]「%s」[-]武功卓絕，非但與武林盟主交手不落下風，更力克群雄，奪得%d分，爭得榜首!";
		local szMsg = string.format(szMsgFormat, tbPlayerTop1.szName, tbPlayerTop1.nScore);
		ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.System, szMsg);
	end

	-- 前十名玩家 家族名
	for nPlayerRank = 1, 10 do
		local tbPlayerData = self._tbPlayerRankData[nPlayerRank];
		if not tbPlayerData then
			break;
		end

		local kinData = Kin:GetKinById(tbPlayerData.nKinId);
		tbPlayerData.szKinName = kinData and kinData.szName;
	end

	for nRank, tbPlayerData in ipairs(self._tbPlayerRankData) do
		Boss:SendPlayerReward(tbPlayerData.nPlayerId, tbPlayerData.nScore, nRank);
	end

	-- 计算下回boss的血
	--local tbBossData = Boss:GetBossData();
	--local nCostTime = GetTime() - tbBossData.nStartTime;
	--local nOrgBossHpRate = Boss:GetBossHpAdjustRate();
	--if nCostTime < 60 * 10 then -- 10分钟内结束, 则下场血量增加10%
	--	Boss:SetBossAdjustRate(nOrgBossHpRate * 1.1);
	--elseif nCostTime > 60 * 20 then -- 超过20分钟结束, 则下场血量减少10%
	--	Boss:SetBossAdjustRate(nOrgBossHpRate * 0.9);
	--end

	Boss:LogState();
	self:InitData();
end

function Boss:SendPlayerReward(nPlayerId, nScore, nRank)
	-- 成就
	local player = KPlayer.GetPlayerObjById(nPlayerId);

	local nKinHonorBoss = 0;
	local kinMemberData = Kin:GetMemberData(nPlayerId);
	local bossKinData = Boss:GetKinData(kinMemberData and kinMemberData.nKinId or 0);
	if bossKinData then
		nKinHonorBoss = GetItemValueFromSetting(bossKinData.nRank, Boss.Def.tbKinBoxRankScore).Honor;
		if bossKinData.nJoinMember >= Boss.Def.nBossKinMemberN then
			nKinHonorBoss = math.max(nKinHonorBoss, Boss.Def.nBossKinMemberNMinScore);
		end

		if player and bossKinData.nRank == 1 then
			Achievement:AddCount(player, "BossNumberOne_1");
		end
	end

	local nPlayerHonorBoss = GetItemValueFromSetting(nRank, Boss.Def.tbPlayerBoxRankScore).Honor;
	if nScore >= Boss.Def.nBossPlayerScoreN then
		nPlayerHonorBoss = math.max(nPlayerHonorBoss, Boss.Def.nBossPlayerScoreNMinScore);
	end

	local nKinRewardAdditionRate = kinMemberData and kinMemberData:GetRewardAdditionRate() or 0;
	local nFinalHonorBoss = (nKinHonorBoss + nPlayerHonorBoss) * (1 + nKinRewardAdditionRate);

	if player then
		local tbMyKin = bossKinData;
		local tbMyRank = {nScore = nScore, nRank = nRank};
		local tbTop10Player = Boss:GetTop10Player();
		local tbTop10Kin = Boss:GetTop10Kin();

		player.CallClientScript("Boss:SyncFinalResult", tbMyRank, tbMyKin, tbTop10Player, tbTop10Kin);
	end

	local szMsgFormat = "尊敬的玩家：\n\n    本次挑戰武林盟主，您獲得了[FFFE0D]第%d名[-]，您%s本次挑戰共獲得[FFFE0D]%d[-]貢獻%s，請注意查收哦。\n\n小提示：幫派參與人數越多獎勵越豐厚哦！";
	local szKinInfo = "";
	if bossKinData and bossKinData.nRank then
		szKinInfo = string.format("所在的幫派排名第[FFFE0D]%d[-]名，", bossKinData.nRank);
	end

	local tbMailRewards = {{ Boss.Def.szAwardMoneyType, nFinalHonorBoss}};
	if not bossKinData then
		local tbNoKinReward = Boss:GetNoKinReward(nPlayerId);
		for _, tbReward in ipairs(tbNoKinReward) do
			table.insert(tbMailRewards, tbReward);
		end
	end
	local _, szMsg, tbFinalAward = RegressionPrivilege:GetDoubleAward(player, "Boss", tbMailRewards)
	local tbGiftBoxMail = {
		To = nPlayerId;
		Title = "挑戰武林盟主獎勵";
		Text = string.format(szMsgFormat, nRank, szKinInfo, nFinalHonorBoss, szMsg and string.format(szMsg, nFinalHonorBoss) or "");
		From = "「武林盟主」獨孤劍";
		tbAttach = tbFinalAward;
		nLogReazon = Env.LogWay_Boss;
		tbParams = {
			nRank = nRank,
		};
	};

	Mail:SendSystemMail(tbGiftBoxMail);
end

function Boss:GetNoKinReward(nPlayerId)
	local tbRewards = {};
	local tbBossData = Boss:GetBossData();
	local tbAuctionRewards = Boss:GetAuctionRewards();
	for _, tbItemsData in ipairs(tbAuctionRewards) do
		if not tbItemsData.nBossId or tbBossData.nNpcId == tbItemsData.nBossId then
			local nValue = Boss.Def.nNoKinRewardScore * tbItemsData.nRate / #tbItemsData.Items;
			for _, nItemId in ipairs(tbItemsData.Items) do
				if nItemId ~= Boss.Def.nNoKinIgnoreItemId then
					local nItemValue = KItem.GetItemBaseProp(nItemId).nValue;
					local nItemCount = math.floor(nValue / nItemValue + MathRandom());
					if nItemCount > 0 then
						table.insert(tbRewards, {"item", nItemId, nItemCount});
						Log("NoKinRewardItem:", nPlayerId, nItemId, nItemCount);
					end
				end
			end
		end
	end
	return tbRewards;
end

function Boss:SendKinReward(tbKinData, nRank)
	local nRewardScore = GetItemValueFromSetting(nRank, Boss.Def.KinRwardRankScore).Score;

	local tbAuctionItems = {};
	local tbBossData = Boss:GetBossData();
	local tbAuctionRewards = Boss:GetAuctionRewards();
	local nAuctionScale = Boss:GetAuctionRewardScale();
	local nTotalKinValue = nRewardScore * tbKinData.nJoinMember * nAuctionScale;
	for _, tbItemsData in ipairs(tbAuctionRewards) do
		if not tbItemsData.nBossId or tbBossData.nNpcId == tbItemsData.nBossId then
			local nValue = nTotalKinValue * tbItemsData.nRate / #tbItemsData.Items;
			for _, nItemId in ipairs(tbItemsData.Items) do
				local nItemValue = KItem.GetItemBaseProp(nItemId).nValue;
				local nItemCount = math.floor(nValue / nItemValue + MathRandom());
				if nItemCount > 0 then
					table.insert(tbAuctionItems, {nItemId, nItemCount});
				end
			end
		end
	end

	Log(tbKinData.nKinId, tbKinData.nJoinMember, nRank, "BOSS活動進入拍賣的物品:")
	Lib:LogTB(tbAuctionItems);

	Kin:AddAuction(tbKinData.nKinId, "Boss", tbKinData.tbFighter, tbAuctionItems);

	-- 家族威望奖励
	local nPrestige = GetItemValueFromSetting(nRank, Boss.Def.KinPrestigeRward).Prestige;
	local kinData = Kin:GetKinById(tbKinData.nKinId);
	nPrestige = nPrestige + tbKinData.nJoinMember; -- 所有家族获得参与人数*1的基准威望值
	kinData:AddPrestige(nPrestige, Env.LogWay_Boss);

	-- 记录家族排名信息
	kinData:SetCacheFlag("BossRank" .. (self.nRound or ""), nRank);

	local szMsg = string.format("你的幫派在本輪挑戰武林盟主當中, 獲得第[FFFF0E]%d[-]名, 獲得威望[FFFF0E]%d[-]", nRank, nPrestige);
	ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.Kin, szMsg, tbKinData.nKinId);
end

function Boss:MarkSortPlayer()
	self.bSortPlayerRank = true;
end

function Boss:SortPlayerRank()
	table.sort(self._tbPlayerRankData, function (a, b)
		if a.nScore == b.nScore then
			return a.nTime < b.nTime;
		else
			return a.nScore > b.nScore;
		end
	end);

	for nRank, tbPlayerData in ipairs(self._tbPlayerRankData) do
		tbPlayerData.nRank = nRank;
	end
	Boss:Refresh10Player(self._tbPlayerRankData);
end

function Boss:PlayerJoin(pPlayer)
	if not self._tbPlayerData[pPlayer.dwID] then
		local tbPlayerData = {
			nKinId              = pPlayer.dwKinId;
			nPlayerId           = pPlayer.dwID;
			szName              = pPlayer.szName;
			nPortrait           = pPlayer.nPortrait;
			nScore              = 0;
			nTime               = GetTime();
			nNextFightTime      = 0;
			nNextRobTime        = 0;
			nProtectRobTime     = 0;
			nProtectRobFullTime = 0; -- 抢夺全保护时间，被抢期间有效
			nLevel              = pPlayer.nLevel;
			nHonorLevel         = pPlayer.nHonorLevel;
			nFaction            = pPlayer.nFaction;
			nRank               = 9999;
			tbPartner           = {};
		}

		self._tbPlayerData[pPlayer.dwID] = tbPlayerData;
		table.insert(self._tbPlayerRankData, tbPlayerData);

		if pPlayer.dwKinId ~= 0 then
			local tbKinRankData = Boss:GetKinData(pPlayer.dwKinId);
			if tbKinRankData then
				tbPlayerData.szKinName = tbKinRankData.szName;
				tbKinRankData.nJoinMember = tbKinRankData.nJoinMember + 1;
			end
		end

		EverydayTarget:AddCount(pPlayer, "Boss");

		AssistClient:ReportQQScore(pPlayer, Env.QQReport_IsJoinBossFight, 1, 0, 1)
		return tbPlayerData;
	end
end

function Boss:GetPlayerData(nPlayerId)
	return self._tbPlayerData[nPlayerId]
end

function Boss:KinJoin(nKinId)
	if not self._tbKinData[nKinId] and nKinId ~= 0 then
		local kinData = Kin:GetKinById(nKinId);
		if not kinData then
			return;
		end

		local nLeaderId = kinData:GetLeaderId();
		local leader = Kin:GetMemberData(nLeaderId);
		if not leader then
			leader = Kin:GetMemberData(kinData.nMasterId);
		end
		local tbKinData = {
			nKinId       = nKinId;
			szName       = kinData.szName;
			szMasterName = leader and leader:GetName() or "暫無";
			nScore       = 0;
			bCanJoin     = kinData:Available2Join();
			nJoinMember  = 0;
			nRank        = 999;
			tbFighter    = {};
		};

		self._tbKinData[nKinId] = tbKinData;
		table.insert(self._tbKinRankData, tbKinData);

		return tbKinData;
	end
end

function Boss:GetKinData(nKinId)
	if not self._tbKinData[nKinId] then
		Boss:KinJoin(nKinId);
	end
	return self._tbKinData[nKinId];
end

function Boss:DealKinScore(nKinId, nScore)
	assert(nKinId and nScore);
	if nScore == 0 or nKinId == 0 then
		return;
	end

	local tbKinData = Boss:GetKinData(nKinId);
	if tbKinData then
		tbKinData.nScore = tbKinData.nScore + nScore;
		Boss:MarkSortKin();
	end
end

function Boss:MarkSortKin()
	self.bSortKinRank = true;
end

function Boss:SortKinRank()
	table.sort(self._tbKinRankData, function (a, b)
		return a.nScore > b.nScore;
	end)

	for nRank, tbKinData in ipairs(self._tbKinRankData) do
		tbKinData.nRank = nRank;
	end

	Boss:RefreshTop10Kin(self._tbKinRankData);
end

function Boss:GetPartnerInfo(nPlayerId, nCount)
	nCount = nCount or 2; -- 抢夺列表默认取两个
	local pAsyncData = KPlayer.GetAsyncData(nPlayerId);
	local tbPartners = {};
	for i = 1, Partner.MAX_PARTNER_POS_COUNT do
		local nPartnerId, nLevel = pAsyncData.GetPartnerInfo(i);
		if nPartnerId and nPartnerId ~= 0 then
			table.insert(tbPartners, {nPartnerId, nLevel});
			if #tbPartners >= nCount then
				break;
			end
		end
	end
	return tbPartners;
end

function Boss:CheckJoinLevel(player)
	return player.nLevel >= Boss.Def.nPlayerEnterLevel;
end

function Boss:FightBoss()
	if not Boss:CheckJoinLevel(me) then
		return false, string.format("%d級才可參加該活動", Boss.Def.nPlayerEnterLevel);
	end

	if not Boss:IsOpen() then
		return false, "本輪挑戰已結束";
	end

    if not Env:CheckSystemSwitch(me, Env.SW_SwitchMap) then
        return false, "目前狀態不允許切換地圖";
    end

	if not Boss:CanJoinBoss(me) then
		return false, "目前狀態無法挑戰武林盟主，請先前往[FFFE0D]野外安全區[-]再嘗試";
	end

	local pPlayerNpc = me.GetNpc();
	local nResult = pPlayerNpc.CanChangeDoing(Npc.Doing.skill);
	if nResult == 0 then
		return false, "目前狀態不能參加";
	end

	local tbPlayerData = Boss:GetPlayerData(me.dwID);
	if not tbPlayerData then
		Boss:PlayerJoin(me);
		tbPlayerData = Boss:GetPlayerData(me.dwID);
	end

	local nCurTime = GetTime();
	if nCurTime < tbPlayerData.nNextFightTime then
		return false, "挑戰冷卻時間未到."
	end

	tbPlayerData.tbPartner = Boss:GetPartnerInfo(me.dwID);
	tbPlayerData.nNextFightTime = nCurTime + Boss.Def.nBossFightCd;
	tbPlayerData.nKinId = me.dwKinId;

	local nBattleKey = nCurTime;
	local tbBossData = Boss:GetBossData();
	local tbFightParam = {
		nMaxHp = tbBossData.nMaxHp,
		nCurHp = tbBossData.nCurHp,
		nNpcId = tbBossData.nNpcId,
	};

	if Boss.bServerFight or tbPlayerData.bServerFight then
		if not AsyncBattle:CreateAsyncBattle(me, Boss.Def.nBossFightMap, {2202, 1978}, "BossFightBattle", tbFightParam, nBattleKey, {nCurTime}, true) then
			Log("Error!! Enter BossFightBattle Map Failed!")
			return;
		end
	else
		AsyncBattle:CreateClientAsyncBattle(me, Boss.Def.nBossFightMap, {2202, 1978}, "BossFight_Client", tbFightParam, nBattleKey, {nCurTime})
	end


	LogD(Env.LOGD_ActivityPlay, me.szAccount, me.dwID, me.nLevel, 0, Env.LOGD_VAL_TAKE_TASK, Env.LOGD_MIS_BOSS, me.GetFightPower());

	Achievement:AddCount(me, "BossChallenge_1");
end

function Boss:CalculateBossFightScore(nDamage)
	local nScore = nDamage / 100;
	local tbBossData = Boss:GetBossData();
	local nLeftHpRate = tbBossData.nCurHp / tbBossData.nMaxHp;
	local nScoreRate = Boss:GetBossHpStageInfo(nLeftHpRate);
	return math.max(1, math.floor(nScore * nScoreRate)), nScore; -- 至少抢一分
end

function Boss:OnBossFightBattleResult(pPlayer, nResult, tbBattleObj, nFightBeginTime)
	if not self.bStart or not tbBattleObj.nDamage then
		pPlayer.CenterMsg("BOSS已被他人強行殺死, 本次得分無效");
		return;
	end

	local bClientFight = (tbBattleObj.szClassType ~= "BossFightBattle");
	if Boss.bServerFight and bClientFight then
		Log("Error!!!Boss:OnBossFightBattleResult while ServerFight Bug szClassType ~= BossFightBattle");
		return;
	end

	local tbPlayerData = Boss:GetPlayerData(pPlayer.dwID);
	if not tbPlayerData then
		return;
	end

	Boss:StateStart("OnBossFightBattleResult");

	local nCurTime = GetTime();
	local nFightScore, nOrgScore = Boss:CalculateBossFightScore(tbBattleObj.nDamage);
	local nLimitScore = Boss:GetLimitBossFightScore(pPlayer);

	if nOrgScore > nLimitScore and bClientFight then
		tbPlayerData.nNextFightTime = nCurTime - 30;
		tbPlayerData.bServerFight = true;
		pPlayer.CallClientScript("Boss:OnSyncMyData", tbPlayerData);
		pPlayer.MsgBox("由於系統檢測到分數異常, 故判定此次挑戰無效. 還請再次對盟主進行挑戰");
		Log("BossFightResult OverScore", pPlayer.dwID, pPlayer.szName, nLimitScore, nOrgScore);
		return;
	end

	tbPlayerData.bServerFight = nil;
	if not bClientFight then
		Boss:UpdateServerBossFightScore(pPlayer, nOrgScore);
	end

	if Forbid:IsBanning(pPlayer,Forbid.BanType.WuLinMengZhu) then                                       -- 功能冻结
		nFightScore = 0
		local nEndTime = Forbid:BanEndTime(pPlayer,Forbid.BanType.WuLinMengZhu)
		local szTime = Lib:GetTimeStr3(nEndTime)
		pPlayer.MsgBox(string.format("您由於%s被禁止上榜，解禁時間%s",Forbid:BanTips(pPlayer,Forbid.BanType.WuLinMengZhu), szTime or ""), {{"確定"}, {"取消"}})
	end

	tbPlayerData.nScore = tbPlayerData.nScore + nFightScore;
	local tbBossData = Boss:GetBossData();

	local nKinScore = Kin:GetReducedValue(pPlayer.dwID, nFightScore)
	Boss:DealKinScore(pPlayer.dwKinId, nKinScore);
	Boss:MarkSortPlayer();

	pPlayer.CallClientScript("Boss:OnSyncMyData", tbPlayerData);
	pPlayer.CallClientScript("Boss:OnMyMsg", string.format("本次挑戰盟主獲得[FFFF0E]%d[-]點積分", math.floor(nFightScore)));

	if pPlayer.dwKinId ~= 0 then
		local szBroadcastMsg = string.format("「%s」挑戰盟主獲得[FFFF0E]%d[-]點積分", pPlayer.szName, math.floor(nFightScore));
		ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.Boss, szBroadcastMsg, pPlayer.dwKinId);
	end

	local bBossDie = (nResult == 1);
	local tbFightResult = {
		bBossDie = bBossDie and not self.bPrepareFinish;
		nScore = nFightScore;
	};
	pPlayer.CallClientScript("Boss:OnFightBossResult", tbFightResult);

	pPlayer.TLogRoundFlow(Env.LogWay_Boss, Env.LogWay_BossFight, nFightScore or 0, GetTime() - nFightBeginTime,
		nResult == 1 and Env.LogRound_SUCCESS or Env.LogRound_FAIL, tbPlayerData.nRank or 0, 0);
	--LogD(Env.LOGD_ActivityPlay, pPlayer.szAccount, pPlayer.dwID, pPlayer.nLevel, 0, Env.LOGD_VAL_FINISH_TASK, Env.LOGD_MIS_BOSS, pPlayer.GetFightPower());

	Boss:StateEnd("OnBossFightBattleResult");
	return true;
end

AsyncBattle:ResgiterBattleType("BossFightBattle", Boss, Boss.OnBossFightBattleResult, nil, Boss.Def.nBossFightMap);
AsyncBattle:ResgiterBattleType("BossFight_Client", Boss, Boss.OnBossFightBattleResult, nil, Boss.Def.nBossFightMap)

function Boss:RobPlayer(nTargetPlayerId)
	if not Boss:CheckJoinLevel(me) then
		return false, string.format("%d級才可參加該活動", Boss.Def.nPlayerEnterLevel);
	end

	if not Boss:IsOpen() then
		return false, "本輪武林盟主挑戰已結束";
	end

	if not Env:CheckSystemSwitch(me, Env.SW_SwitchMap) then
	    return false, "目前狀態不允許切換地圖";
	end

	if not Boss:CanJoinBoss(me) then
		return false, "目前狀態無法搶奪，請先前往[FFFE0D]野外安全區[-]再嘗試";
	end

	if FriendShip:IsFriend(me.dwID, nTargetPlayerId) then
		return false, "這位俠客是您的好友，請不要背後捅刀子哦！";
	end

	local targetPlayer = KPlayer.GetPlayerObjById(nTargetPlayerId) or KPlayer.GetRoleStayInfo(nTargetPlayerId);
	local tbTargetPlayerData = Boss:GetPlayerData(nTargetPlayerId);
	-- 更新..
	if targetPlayer.dwKinId ~= tbTargetPlayerData.nKinId then
		tbTargetPlayerData.nKinId = targetPlayer.dwKinId;
	end
	if targetPlayer.nHonorLevel ~= tbTargetPlayerData.nHonorLevel then
		tbTargetPlayerData.nHonorLevel = targetPlayer.nHonorLevel;
	end

	if me.dwKinId == tbTargetPlayerData.nKinId and me.dwKinId ~= 0 then
		return false, "這位俠客是您的幫派成員，請不要破壞幫派關係哦！";
	end

	-- 头衔高于自身2级的玩家不可抢分
	if tbTargetPlayerData.nHonorLevel > me.nHonorLevel + 2 then
		return false, "此人頭銜太高，隱隱傳來一股威壓，請提升頭銜後再嘗試！";
	end

	local nCurTime = GetTime();
	if nCurTime < tbTargetPlayerData.nProtectRobTime then
		return false, "該俠士正與其他俠士交手，請稍後再嘗試挑戰";
	end

	if nCurTime < tbTargetPlayerData.nProtectRobFullTime then
		local nProtectBack = Boss.Def.nProtectRobCd + Boss.Def.nExtraProtectRobCd - Boss.Def.nRobBattleTime;
		tbTargetPlayerData.nProtectRobTime = tbTargetPlayerData.nProtectRobFullTime - nProtectBack;
		return false, "該俠士正與其他俠士交手，請稍後再嘗試挑戰";
	end

	if not me.SyncOtherPlayerAsyncData(nTargetPlayerId) then
		return false, "同步戰鬥資料出錯";
	end

	local pPlayerNpc = me.GetNpc();
	local nResult = pPlayerNpc.CanChangeDoing(Npc.Doing.skill);
	if nResult == 0 then
		return false, "目前狀態不能參加";
	end

	local nBattleKey = nCurTime;
	if not AsyncBattle:CreateAsyncBattle(me, Boss.Def.nRobFightMap, {2190, 1939}, "BossRobBattle", nTargetPlayerId, nBattleKey, {nTargetPlayerId, nCurTime}, true) then
		Log("Error!! Enter BossRobBattle Map Failed!")
		return;
	end

	tbTargetPlayerData.nProtectRobTime = nCurTime + Boss.Def.nProtectRobCd;
	tbTargetPlayerData.nProtectRobFullTime = nCurTime + Boss.Def.nProtectRobCd + Boss.Def.nExtraProtectRobCd;
	Achievement:AddCount(me, "BossRob_1");

	local tbPlayerData = Boss:GetPlayerData(me.dwID);
	if not tbPlayerData then
		Boss:PlayerJoin(me);
		tbPlayerData = Boss:GetPlayerData(me.dwID);
		tbPlayerData.tbPartner = Boss:GetPartnerInfo(me.dwID);
	end
	tbPlayerData.nNextRobTime = nCurTime + Boss.Def.nRobCd;
	tbPlayerData.nKinId = me.dwKinId;

	LogD(Env.LOGD_ActivityPlay, me.szAccount, me.dwID, me.nLevel, 0, Env.LOGD_VAL_TAKE_TASK, Env.LOGD_MIS_BOSS_ROB, me.GetFightPower());
	return true;
end

function Boss:OnRobBattleResult(pPlayer, nResult, tbBattleObj, nTargetPlayerId, nFightBeginTime)
	Boss:StateStart("OnRobBattleResult");

	if not Boss:IsOpen() then
		pPlayer.CenterMsg("此輪武林盟主挑戰已結束, 本次搶奪得分無效");
		return;
	end

	--LogD(Env.LOGD_ActivityPlay, pPlayer.szAccount, pPlayer.dwID, pPlayer.nLevel, 0, Env.LOGD_VAL_FINISH_TASK, Env.LOGD_MIS_BOSS_ROB, pPlayer.GetFightPower());

	local tbTargetPlayerData = Boss:GetPlayerData(nTargetPlayerId);
	assert(tbTargetPlayerData);

	local nRobScore = Boss:CalculateRobScore(tbTargetPlayerData.nScore, tbBattleObj.nEnemyBeated, tbBattleObj.bEnemyMainBeated);
	local tbPlayerData = Boss:GetPlayerData(pPlayer.dwID);
	if not tbPlayerData then
		Boss:PlayerJoin(pPlayer);
		tbPlayerData = Boss:GetPlayerData(pPlayer.dwID);
	end

	if Forbid:IsBanning(pPlayer,Forbid.BanType.WuLinMengZhu) then                                       -- 功能冻结,自己抢不到分，对方也不扣分
		nRobScore = 0

		local nEndTime = Forbid:BanEndTime(pPlayer,Forbid.BanType.WuLinMengZhu)
        local szTime = Lib:GetTimeStr3(nEndTime)
        pPlayer.MsgBox(string.format("您由於%s被禁止上榜，解禁時間%s",Forbid:BanTips(pPlayer,Forbid.BanType.WuLinMengZhu), szTime or ""), {{"確定"}, {"取消"}})
	end

	if nResult == 1 then
		tbTargetPlayerData.nProtectRobTime = tbTargetPlayerData.nProtectRobFullTime;
	end
	tbTargetPlayerData.nProtectRobFullTime = 0;

	tbPlayerData.nScore = tbPlayerData.nScore + nRobScore;
	tbTargetPlayerData.nScore = tbTargetPlayerData.nScore - nRobScore;

	local pTargetPlayer = KPlayer.GetRoleStayInfo(nTargetPlayerId);
	if nRobScore > 0 then
		FriendShip:AddHate(pTargetPlayer, pPlayer, Boss.Def.nRobHate);
		FriendShip:AddHate(pPlayer, pTargetPlayer, -0.8 * Boss.Def.nRobHate);
		RecordStone:AddRecordCount(pPlayer, "Master", 1);
	end

	Boss:MarkSortPlayer();

	pPlayer.CallClientScript("Boss:OnSyncMyData", tbPlayerData);
	local szMyMsg = string.format("成功搶奪到[FFFF0E]%d[-]點積分", nRobScore);
	if nRobScore == 0 then
		szMyMsg = "你嘗試搶奪積分, 可惜並無所獲..";
	end
	pPlayer.CallClientScript("Boss:OnMyMsg", szMyMsg);

	pTargetPlayer = KPlayer.GetPlayerObjById(nTargetPlayerId);
	if pTargetPlayer then
		tbTargetPlayerData.nKinId = pTargetPlayer.dwKinId;
		pTargetPlayer.CallClientScript("Boss:OnSyncMyData", tbTargetPlayerData);
		if nRobScore == 0 then
			pTargetPlayer.CallClientScript("Boss:OnMyMsg", string.format("[FFFF0E]「%s」[-]嘗試搶奪您的積分, 可惜他技不如人，搶奪失敗了", pPlayer.szName));
		else
			pTargetPlayer.CallClientScript("Boss:OnMyMsg", string.format("被[FFFF0E]「%s」[-]奪走了%d點積分", pPlayer.szName, nRobScore));
		end
	end


	local szBroadcastMsg = string.format("[FFFF0E]「%s」[-]成功奪走[FFFF0E]「%s」[-]%d點積分", pPlayer.szName, tbTargetPlayerData.szName, nRobScore);
	if nRobScore == 0 then
		szBroadcastMsg = string.format("[FFFF0E]「%s」[-]嘗試對[FFFF0E]「%s」[-]進行搶奪, 可惜技不如人", pPlayer.szName, tbTargetPlayerData.szName);
	end
	if pPlayer.dwKinId ~= 0 then
		ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.Boss, szBroadcastMsg, pPlayer.dwKinId);
	end
	if tbTargetPlayerData.nKinId and tbTargetPlayerData.nKinId ~= 0 then
		ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.Boss, szBroadcastMsg, tbTargetPlayerData.nKinId);
	end

	Boss:MarkRobTable(pPlayer.dwID, nTargetPlayerId);
	Boss:DealKinScore(pPlayer.dwKinId, nRobScore);
	Boss:DealKinScore(tbTargetPlayerData.nKinId, -nRobScore);

	local tbEnemyPartners = Boss:GetPartnerInfo(nTargetPlayerId, Partner.MAX_PARTNER_POS_COUNT);

	-- 结算界面
	local tbResult = {
		bSuccess = (nResult == 1);
		nRobScore = nRobScore;
		tbEnemyPartners = tbEnemyPartners;
		tbEnemyData = tbTargetPlayerData;
		tbBeated = tbBattleObj.tbBeatedNpc;
		bMainBeated = tbBattleObj.bEnemyMainBeated;
	};

	pPlayer.CallClientScript("Boss:OnRobResult", tbResult);

	pPlayer.TLogRoundFlow(Env.LogWay_Boss, Env.LogWay_BossRob, nRobScore or 0, GetTime() - nFightBeginTime,
		nResult == 1 and Env.LogRound_SUCCESS or Env.LogRound_FAIL, tbPlayerData.nRank or 0, 0);

	Boss:StateEnd("OnRobBattleResult");
end

function Boss:CalculateRobScore(nEnemyScore, nBeated, bMainBeated)
	local nResultScore = 0;
	local nMinBaseRate = Boss.Def.nRobScoreBaseRateMin;
	local nMaxBaseRate = Boss.Def.nRobScoreBaseRateMax;
	local nBaseScore = MathRandom(nMinBaseRate, nMaxBaseRate) * nEnemyScore / 100;
	local nMainCount = 0;
	if bMainBeated then
		nMainCount = 1;
		nResultScore = nBaseScore * 0.6;
	end

	nResultScore = nResultScore + (nBeated - nMainCount) * 0.1 * nBaseScore;

	return math.floor(nResultScore);
end

AsyncBattle:ResgiterBattleType("BossRobBattle", Boss, Boss.OnRobBattleResult, nil, Boss.Def.nRobFightMap);

function Boss:Refresh10Player(tbPlayers)
	local tbRankData = Boss:GetBossRankData();
	if not tbRankData.tbPlayerRank then
		tbRankData.tbPlayerRank = {};
		tbRankData.nPlayerRankVersion = 0;
	end

	tbRankData.nPlayerRankVersion = tbRankData.nPlayerRankVersion + 1;
	for nRank, tbPlayerData in ipairs(tbPlayers) do
		if nRank > 20 then
			break;
		end
		tbRankData.tbPlayerRank[nRank] = tbPlayerData;
	end
end

function Boss:GetTop10Player(nVersion)
	local tbRankData = Boss:GetBossRankData();

	if nVersion ~= tbRankData.nPlayerRankVersion then
		return tbRankData.tbPlayerRank, tbRankData.nPlayerRankVersion;
	end
end

function Boss:RefreshTop10Kin(tbKins)
	local tbRankData = Boss:GetBossRankData();
	if not tbRankData.tbKinRank then
		tbRankData.tbKinRank = {};
		tbRankData.nKinRankVersion = 0;
	end

	tbRankData.nPlayerRankVersion = tbRankData.nPlayerRankVersion + 1;
	for nRank, tbKinData in ipairs(tbKins) do
		if nRank > 10 then
			break;
		end
		tbRankData.tbKinRank[nRank] = tbKinData;
	end
end

function Boss:GetTop10Kin(nVersion)
	local tbRankData = Boss:GetBossRankData();
	if nVersion ~= tbRankData.nKinRankVersion then
		return tbRankData.tbKinRank, tbRankData.nKinRankVersion;
	end
end

function Boss:SyncBossInfo(nEndTime, nMyRank)
	local tbBossData = Boss:GetBossData() or {};
	if not nEndTime and Boss:IsOpen() then
		me.CallClientScript("Boss:OnSyncBossData", tbBossData);
	end

	local tbPlayerData = Boss:IsOpen() and Boss:GetPlayerData(me.dwID);
	if tbPlayerData and tbPlayerData.nRank ~= nMyRank then
		me.CallClientScript("Boss:OnSyncMyData", tbPlayerData);
	end

	if tbBossData.nEndTime == nEndTime then
		return true;
	end

	me.CallClientScript("Boss:OnSyncBossTime", tbBossData.nStartTime or 0, tbBossData.nEndTime or 0);
	return true;
end

function Boss:SyncRobList()
	if not Boss:IsOpen() then
		return false, "挑戰未開啟";
	end

	Boss:StateStart("SyncRobListCount", 0);

	local tbRobList = {};
	local nTopSelectCount = 20;

	for nRank, tbPlayerData in ipairs(self._tbPlayerRankData) do
		if nRank > nTopSelectCount then
			break;
		end

		table.insert(tbRobList, tbPlayerData);
	end

	local tbRobers = Boss:GetRobers(me.dwID) or {};
	for nPlayerId, _ in pairs(tbRobers) do
		local tbPlayerData = Boss:GetPlayerData(nPlayerId);
		if tbPlayerData.nRank > nTopSelectCount then
			table.insert(tbRobList, tbPlayerData);
		end
	end

	local myData = Boss:GetPlayerData(me.dwID) or {};
	local nMyRank = myData.nRank;
	if nMyRank then
		local nUpSelectCount = 5;
		local nBeforeCount = 0;
		local nCurRank = nMyRank;
		while nBeforeCount <= nUpSelectCount and nCurRank > nTopSelectCount do
			local tbPlayerData = self._tbPlayerRankData[nCurRank];
			if tbPlayerData and
				not FriendShip:IsFriend(me.dwID, tbPlayerData.nPlayerId)
				and (tbPlayerData.nKinId ~= me.dwKinId or me.dwKinId == 0 or me.dwID == tbPlayerData.nPlayerId)
				and not tbRobers[tbPlayerData.nPlayerId]
				then
				nBeforeCount = nBeforeCount + 1;
				table.insert(tbRobList, tbPlayerData);
			end

			nCurRank = nCurRank - 1;
		end
	end

	me.CallClientScript("Boss:OnSyncRobList", tbRobList);
	Boss:StateEnd("SyncRobListCount", #tbRobList);
	return true;
end

function Boss:SyncKinRank(nVersion)
	local tbRank, nVersion = Boss:GetTop10Kin(nVersion);
	if tbRank then
		local tbMyKin = Boss:IsOpen() and Boss:GetPlayerData(me.dwID) and Boss:GetKinData(me.dwKinId);
		me.CallClientScript("Boss:OnSyncKinRank", tbRank, nVersion, tbMyKin);
	end
	return true;
end

function Boss:SyncPlayerRank(nVersion)
	local tbRank, nVersion = Boss:GetTop10Player(nVersion);
	if tbRank then
		me.CallClientScript("Boss:OnSyncPlayerRank", tbRank, nVersion);
	end
	return true;
end

local tbBossInterface = {
	FightBoss = true;
	RobPlayer = true;
	SyncPlayerRank = true;
	SyncKinRank = true;
	SyncRobList = true;
	SyncBossInfo = true;
}

function Boss:ClientRequest(szRequestType, ...)
	if tbBossInterface[szRequestType] then
		Boss:StateStart(szRequestType);
		local bSuccess, szInfo = Boss[szRequestType](Boss, ...);
		Boss:StateEnd(szRequestType);
		if not bSuccess then
			me.CenterMsg(szInfo);
		end
	else
		Log("WRONG Boss Request:", szRequestType, ...);
	end
end

function Boss:ResetPlayerData(nPlayerId)
	if Boss.bStart then
		local tbPlayerData = Boss:GetPlayerData(nPlayerId);
		if not tbPlayerData then
			return
		end
		tbPlayerData.nScore = 0												-- 将武林盟主个人积分重置为0
		--Boss:MarkSortPlayer();											-- 更新玩家排名
		local pPlayer = KPlayer.GetPlayerObjById(nPlayerId)
		if pPlayer then
			pPlayer.CallClientScript("Boss:OnSyncMyData", tbPlayerData);	-- 同步玩家自身信息
			local tbRank, nVersion = Boss:GetTop10Player();
			if tbRank then
				pPlayer.CallClientScript("Boss:OnSyncPlayerRank", tbRank, nVersion);		-- 同步玩家排名
			end
		end
	end
end

-- ===================================================IDIP用到=================================================================
function Boss:PlayerDmgInfo(dwID)
    local nMyRank = 0
    local nMyScore = 0
    local nKinRank = 0
    local nKinScore = 0
    local tbPlayerData = Boss:GetPlayerData(dwID);
    if not tbPlayerData then
        return nMyScore,nMyRank,nKinScore,nKinRank
    else
        nMyRank = tbPlayerData.nRank
        nMyScore = tbPlayerData.nScore
        local pPlayer = KPlayer.GetPlayerObjById(dwID) or KPlayer.GetRoleStayInfo(dwID);
        local nMyKinId = pPlayer.dwKinId
        if nMyKinId > 0 then
            local tbKinData = Boss:GetKinData(nMyKinId)
            if tbKinData then
                nKinRank = tbKinData.nRank
                nKinScore = tbKinData.nScore
            end
        end
    end
    return nMyScore,nMyRank,nKinScore,nKinRank
end
