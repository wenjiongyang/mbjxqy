
function ScheduleTask:OnExecute(szFunc, szTimeFrame, szCloseTimeFrame, Param1, Param2, Param3, Param4, Param5)
	if szTimeFrame and szTimeFrame ~= "" then
		if TimeFrame:GetTimeFrameState(szTimeFrame) ~= 1 then
			return false;
		end
	end

	if szCloseTimeFrame and szCloseTimeFrame ~= "" then
		if TimeFrame:GetTimeFrameState(szCloseTimeFrame) == 1 then
			return false;
		end
	end

	local fnFunc = self[szFunc];
	if (not fnFunc) then
		Log(string.format("[SCHEDUALTASK]Callback Func Missing: %s", szFunc));
		return true;
	end

	local tbParams = {Param1, Param2, Param3, Param4, Param5}
	for i, v in ipairs(tbParams) do
		if Lib:IsEmptyStr(v) then
			tbParams[i] = nil;
		elseif tonumber(v) then
			tbParams[i] = tonumber(v);
		end
	end
	Log(string.format("[SCHEDUALTASK]Execute: %s()", szFunc), tbParams[1], tbParams[2],tbParams[3],tbParams[4],tbParams[5]);
	local fnExc = function ()
		fnFunc(self, tbParams[1],tbParams[2],tbParams[3],tbParams[4],tbParams[5])
	end
	xpcall(fnExc, Lib.ShowStack);
	return true;
end

function ScheduleTask:DoNothing()
end

function ScheduleTask:KinRunPerDay()
	Kin:RunPerDay();

	if version_vn then
		local nServerId = GetServerIdentity()
		TLog("ServerCreateTime", nServerId, ScriptData:GetValue("dwServerCreateTime"))
	end
end

function ScheduleTask:KinRobber(nRound)
	if not Kin.bRobberOpened then
		return
	end
	Kin:OpenKinRobber(tonumber(nRound));
end

function ScheduleTask:KinRobberStop()
	-- 活动显示用...故加的空的..
end

function ScheduleTask:BossFight(nRound)
	Boss:StartBossFight(nRound);
end

function ScheduleTask:StopBossFight()
	Boss:NotifyFinishBoss();
end

function ScheduleTask:AuctionRunPerday()
	--Kin:AuctionRunPerday();
end

function ScheduleTask:CheckMaxLevel()
	local nMaxLevel = TimeFrame:GetMaxLevel();
	if nMaxLevel then
		SetMaxLevel(nMaxLevel)
	end
end

function ScheduleTask:UpdateLevelAddExpP()
    Lib:CallBack({Npc.UpdateLevelAddExpP, Npc})
end

function ScheduleTask:KinGatherPrepare()
	Kin:PrepareKinGatherActivity();
end

function ScheduleTask:KinGatherStart()
	Kin:StartKinGatherActivity();
end

function ScheduleTask:KinGatherStop()
	Kin:StopKinGatherActivity()
end

function ScheduleTask:RankBattleAward()
	RankBattle:Award()
end

function ScheduleTask:HeroChallengeUpdate()
    HeroChallenge:UpdatePlayerRankData();
end

function ScheduleTask:PreStartBoss()
	BossLeader:PreStartActivity("Boss");
	Log("ChangeMapPKMode PreStartBoss");
end

function ScheduleTask:EndEnterBossFuben()
	BossLeader:EndActivityEnter("Boss");
	Log("ChangeMapPKMode EndEnterBoss");
end

function ScheduleTask:StartBoss(nJiFen)
	if not nJiFen then
		nJiFen = 0;
	end
	nJiFen = tonumber(nJiFen);
	local bJiFen = false;
	if nJiFen == 1 then
		bJiFen = true;
	end
	BossLeader:StartActivity("Boss", 0, bJiFen);
end

function ScheduleTask:EndBoss()
	BossLeader:CloseActivity("Boss");
end

function ScheduleTask:CrossBossMail(nWorld)
	if not nWorld then
		nWorld = 0;
	end
	nWorld = tonumber(nWorld);
	local bWorld = false;
	if nWorld == 1 then
		bWorld = true;
	end
    BossLeader:SendCrossKinMail(bWorld);
end

function ScheduleTask:StartLeader(nExtCount)
	if not nExtCount then
		nExtCount = 0;
	end

	nExtCount = tonumber(nExtCount);
	BossLeader:StartActivity("Leader", nExtCount);
end

function ScheduleTask:EndLeader()
	BossLeader:CloseActivity("Leader");
end

function ScheduleTask:HSLJOpenHSLJMail()
   HuaShanLunJian:OpenHSLJMail()
end

function ScheduleTask:HSLJPreStartPreGame()
   HuaShanLunJian:PreStartPrepareGame()
end

function ScheduleTask:HSLJStartPreGame()
   HuaShanLunJian:StartPrepareGame();
end

function ScheduleTask:HSLJClosePreGame()
   HuaShanLunJian:CloseEnterPreGame();
end

function ScheduleTask:HSLJPreStartFinalsGame()
	HuaShanLunJian:PreStartFinalsPlayGame();
end

function ScheduleTask:HSLJStartFinalsGame()
   HuaShanLunJian:StartFinalsPlayGame();
end

function ScheduleTask:HSLJCloseFinalsGame()
   HuaShanLunJian:CloseFinalsPlayGame();
end

function ScheduleTask:HSLJFinalsList()
    HuaShanLunJian:InformFinalsFightTeamList();
end

function ScheduleTask:StartUpdatePunishTask()
	PunishTask:StartCreateMapNpc()
	Log("ScheduleTask StartUpdatePunishTask");
end

function ScheduleTask:QYHFirstStartGame()
    QunYingHui:FirstStartGame();
end

function ScheduleTask:QYHStartGame()
    QunYingHui:StartGame();
end

function ScheduleTask:QYHEndGame()
    --QunYingHui:EndGame();
end

function ScheduleTask:QYHSeasonEndGame()
	QunYingHui:SeasonEndGame();
end

function ScheduleTask:StartBattle(nType)
	Battle:OpenBattleSignUp(nType)
	Log("StartBattle sign up", nType)
end

function ScheduleTask:StopBattle()
	Battle:StopBattleSignUp()
end

function ScheduleTask:UpdateStrangerMap()
	KPlayer.UpdateStrangerMap();
end

--新的一天开始了
function ScheduleTask:OnNewDayBegin()
	SupplementAward:OnPerDayUpdate()
	ActivityQuestion:OnNewDayBegin()
	LoginAwards:OnNewDayBegin()
	SignInAwards:OnNewDayBegin()
	MoneyTree:OnNewDayBegin()
	SummerGift:OnPerDayUpdate()
end

function ScheduleTask:CheckRankBoard()
	RankBoard:UpdateAllRank()
end

function ScheduleTask:LogDailyKinData()
	-- 日期，家族ID，家族中文名，家族等级，威望值，家族排名，族长角色ID
	local pRank = KRank.GetRankBoard("kin")
	if not pRank then
		return
	end

	for i = 1, 500 do
		local tbInfo = pRank.GetRankInfoByPos(i - 1);
		if not tbInfo then
			break;
		end
		local tbKin = Kin:GetKinById(tbInfo.dwUnitID)
		if tbKin then
			LogD(Env.LOGD_DailyKin, nil, nil, tbInfo.dwUnitID, tbKin.szName, tbKin:GetLevel(), tbKin.nPrestige, i, tbKin.nMasterId)
		end
	end
end

function ScheduleTask:LogDailyRole()
	LogRoleLogined(os.date("%Y-%m-%d %H:%M:%S", (GetTime() - 3600 * 26)))
end

function ScheduleTask:PreStartKinBattle(nWaiteTime)
	KinBattle:PreStartKinBattle(nWaiteTime * 60);
end

function ScheduleTask:EndKinBattle()
	KinBattle:EndKinBattle();
end

function ScheduleTask:StartWhiteTiger()
	Fuben.WhiteTigerFuben:Start()
end

function ScheduleTask:CheckCrossBossTimeFrame()
    if not MODULE_ZONESERVER then
		return
	end

	BossLeader:CheckServerCrossBossInfoZ();
end

function ScheduleTask:PreStartCrossBoss()
    if not MODULE_ZONESERVER then
		return
	end

	BossLeader:PreStartCrossBossZ();
end

function ScheduleTask:StartCrossBoss()
    if not MODULE_ZONESERVER then
		return
	end

	BossLeader:StartCrossBossZ()
end

function ScheduleTask:EndCrossBoss()
    if not MODULE_ZONESERVER then
		return
	end

	BossLeader:EndCrossBossZ();
end

function ScheduleTask:StartCrossWhiteTiger()
	if not MODULE_ZONESERVER then
		return
	end

	Fuben.WhiteTigerFuben:BeginCrossFight()
end

function ScheduleTask:CloseWhiteTiger()
    if MODULE_ZONESERVER then
        Fuben.WhiteTigerFuben:StopCrossFight()
        return
    end
	Fuben.WhiteTigerFuben:CloseFuben()
end

function ScheduleTask:CheckStartTeamBattle()
	TeamBattle:CheckStart();
end

function ScheduleTask:CheckStartLeagueTeamBattle()
	TeamBattle:CheckStartLeague();
end

function ScheduleTask:SendLeagueTeamBattleTip()
	local bNeedCheck = TeamBattle:CheckTips();
	if not bNeedCheck then
		return;
	end

	local tbAllPlayer = KPlayer.GetAllPlayer();
	for _, pPlayer in pairs(tbAllPlayer) do
		TeamBattle:SendLeagueTip(pPlayer);
	end
end

function ScheduleTask:StartFactionBattle()
	FactionBattle:Start()
end

function ScheduleTask:CloseFactionBattle()
	FactionBattle:Close()
end

--开启家族运镖活动
function ScheduleTask:StartKinEscort()
	KinEscort:Open()
end

--关闭家族运镖活动
function ScheduleTask:CloseKinEscort()
	KinEscort:Close()
end

function ScheduleTask:StartKinTrain()
	Fuben.KinTrainMgr:Start()
end

function ScheduleTask:StopKinTrain()
	Fuben.KinTrainMgr:Stop()
end

function ScheduleTask:UpdateKinLeader()
	Kin:CheckLeaderOn()
	Kin:CheckLeaderOff()
end

function ScheduleTask:StartFactionMonkey()
	FactionBattle.FactionMonkey:StartFactionMonkey()
end

function ScheduleTask:EndFactionMonkey()
	FactionBattle.FactionMonkey:EndFactionMonkey()
end

function ScheduleTask:KinActivityDaily()
	Kin:DoActivityDaily()
	Kin:RedBagGlobalRemoveExpire()
end

function ScheduleTask:KinTransferCareerNew()
	Kin:TransferCareerNew()
end

function ScheduleTask:NewDayBegin_Zero()
	Spokesman:OnNewDayBegin()
end

function ScheduleTask:NotifyDomainBattle()
	DomainBattle:NotifyEndDomainWar()
end

function ScheduleTask:NotifyKinDomainBattle()
	DomainBattle:NotifyKinDomainWar()
end

function ScheduleTask:StartDomainBattle()
	DomainBattle:StartActivity()
end

function ScheduleTask:DeclareWarDomainBattle()
	DomainBattle:StartDeclareWar();
end

function ScheduleTask:CloseDomainBattle()

end

function ScheduleTask:ActivityDynamicCallback(szParam)
	Activity:ScheduleCallBack(szParam);
end

function ScheduleTask:CheckAndStartActivity()
	Activity:CheckActivityStartToday();
end

function ScheduleTask:CheckNewMonth()
	CollectionSystem:CheckNewMonth()
end

function ScheduleTask:CheckFirstCollection()
	CollectionSystem:CheckBeginFirstActivity()
end

function ScheduleTask:UpdateCollectionRankBoard()
	CollectionSystem:UpdateRank()
end

function ScheduleTask:MarketStallCheckAllLimit()
	MarketStall:CheckAllLimit();
end

function ScheduleTask:MarketStallOutputLimitData()
	MarketStall:OutputLimitDataInfo();
end

function ScheduleTask:TeacherStudentDaily()
	TeacherStudent:DoDaily()
end

function ScheduleTask:AcutionAwardDomainBattle()
	DomainBattle:AddOnwenrAcutionAward()
end

function ScheduleTask:StartImperialTomb()
	ImperialTomb:Open()
end

function ScheduleTask:CloseImperialTomb()
	ImperialTomb:Close()
end

function ScheduleTask:StartEmperor()
	ImperialTomb:OpenEmperor()
end

function ScheduleTask:StartFemaleEmperor()
	ImperialTomb:OpenEmperor(true)
end

function ScheduleTask:CallBoss()
	ImperialTomb:CallBoss()
end

function ScheduleTask:CallEmperor()
	ImperialTomb:CallEmperor()
end

function ScheduleTask:ClearEmperorData()
	ImperialTomb:ClearEmperorData()
	ImperialTomb:ClearBossData()
end

function ScheduleTask:CloseEmperor()
	ImperialTomb:CloseEmperor()
end

function ScheduleTask:SaveAllPlayerQueryData()
	if not version_vn then
		return
	end
	Log("ScheduleTask:SaveAllPlayerQueryData Begin")
	KPlayer.SaveAllPlayerQueryData()
	Log("ScheduleTask:SaveAllPlayerQueryData End")
end

function ScheduleTask:StopBattleCalender()
	Battle:StopBattleCalender()
end

function ScheduleTask:ChanageZone(szType, szActName, szCloseActName)
	Server:ChangeZoneGroup(szType, szActName, szCloseActName)
end

function ScheduleTask:OpenIndiffer()
	if MODULE_ZONESERVER then
		InDifferBattle:OpenSignUp();
	end
end

function ScheduleTask:CloseInfiffer()
	--只是一次匹配不走这里
end

function ScheduleTask:OpenIndifferNotify(nMinute)
	KPlayer.SendWorldNotify(InDifferBattle.tbDefine.nMinLevel, 150, string.format("心魔幻境將在%d分鐘後開始報名，屆時報名時間將持續%d分鐘，請各位俠士提前做好入場準備！", nMinute, math.floor(InDifferBattle.tbDefine.MATCH_SIGNUP_TIME / 60)), 1, 1)
end

function ScheduleTask:CheckCardPickCutAct()
	CardPicker:CheckPickCutAct();
end

function ScheduleTask:UpdateCardPickSchedule()
	CardPicker:UpdateSpecialCardSchedule();
end

function ScheduleTask:CheckCalendarHonor()
	Calendar:CheckMonth()
end

function ScheduleTask:CheckTaskValidTime()
	local tbPlayer = KPlayer.GetAllPlayer()
	for _, pPlayer in ipairs(tbPlayer) do
	    Task:CheckTaskValidTime(pPlayer)
	end
end

function ScheduleTask:StartAuctionDealer()
	Kin:StartAuctionDealer();
end

function ScheduleTask:WeddingDaily()
	Wedding:DoDaily()
end

function ScheduleTask:LotteryDraw()
	Lottery:Draw();	
end

function ScheduleTask:LotteryNotify()
	Lottery:Notify();	
end

function ScheduleTask:LotteryWorldMsg(nMinute)
	Lottery:SendWorldMsg(nMinute);
end
