TeamBattle.SAVE_GROUP = 45;
TeamBattle.SAVE_DATE = 1;
TeamBattle.SAVE_USE_COUNT = 2;
TeamBattle.SAVE_HONOR = 3;

TeamBattle.SAVE_LAST_WEEK_DATE = 4;
TeamBattle.SAVE_LAST_WEEK_USE_COUNT = 5;

TeamBattle.SAVE_MONTHLY_INFO = 6;
TeamBattle.SAVE_MONTHLY_INFO_OLD = 7;
TeamBattle.SAVE_QUARTERLY_INFO = 8;
TeamBattle.SAVE_QUARTERLY_INFO_OLD = 9;
TeamBattle.SAVE_YEAR_INFO = 10;
TeamBattle.SAVE_YEAR_INFO_OLD = 11;
TeamBattle.SAVE_MONTHLY_TIP = 12;
TeamBattle.SAVE_QUARTERLY_TIP = 13;
TeamBattle.SAVE_YEAR_TIP = 14;

TeamBattle.TYPE_NORMAL = 1;
TeamBattle.TYPE_MONTHLY = 2;
TeamBattle.TYPE_QUARTERLY = 3;
TeamBattle.TYPE_YEAR = 4;

TeamBattle.szLeagueOpenTimeFrame = "OpenLevel109";

-- 月度赛开启时间，此处用于各种判断，不用做真正开启时间
TeamBattle.nMonthlyOpenWeek = 1;		--当月第几周
TeamBattle.nMonthlyOpenWeekDay = 3;		--周几
TeamBattle.nMonthlyOpenHour = 21;		--当日小时
TeamBattle.nMonthlyOpenMin = 0;			--当日分钟

-- 季度赛开启时间，此处用于各种判断，不用做真正开启时间
TeamBattle.nQuarterlyOpenMonth = 3;		--本季度第几个月
TeamBattle.nQuarterlyOpenWeek = -1;		--本月第几周
TeamBattle.nQuarterlyOpenWeekDay = 3;	--本周几
TeamBattle.nQuarterlyOpenHour = 21;		--当日小时
TeamBattle.nQuarterlyOpenMin = 0;		--当日分钟

-- 年度赛开启时间，此处用于各种判断，不用做真正开启时间
TeamBattle.nYearOpenMonth = 4;			--几月份
TeamBattle.nYearOpenWeek = -1;			--第几周
TeamBattle.nYearOpenWeekDay = 3;		--周几
TeamBattle.nYearOpenHour = 21;			--几点
TeamBattle.nYearOpenMin = 0;			--几分

TeamBattle.nMonthlyAddTitle = 7700;
TeamBattle.nQuarterlyAddTitle = 7701;

TeamBattle.nFloor2Num = 32;			--2层队伍数量

TeamBattle.PRE_MAP_ID = 1040;		--准备场地图ID
TeamBattle.TOP_MAP_ID = 1047;		--七层地图ID
TeamBattle.TOP_MAP_ID_CROSS = 1057;		--八层地图ID

TeamBattle.tbTopPoint =
{
	{1794, 4044},
	{1804, 2505},
}

TeamBattle.nAddImitity = 20;		--结束后好友增加亲密度
TeamBattle.nTopMapTime = 20 * 60;	--顶层停留最大时间
TeamBattle.nPreMapTime = 5 * 60;	--准备场等待时间
TeamBattle.nMinLevel = 30;			--最小参与等级
TeamBattle.nMinTeamCount = 16;		--最小开启队伍数量
TeamBattle.nFightTime = 220;		--每轮耗时
TeamBattle.nTeamMemeber = 3;		--每个队伍玩家数量
TeamBattle.nMaxFightTimes = 5;		--战斗场次数
TeamBattle.nMaxFloor = 7;			--最大层数
TeamBattle.nMaxFloor_Cross = 8;			--跨服通天塔最大层数
TeamBattle.nTryStartCount = 3;		--最大尝试开启次数，不足16个队伍则再次等待一段时间后尝试开启，最大次数尝试后还是失败，则直接失败
TeamBattle.nDeathSkillState = 1520;	--死亡后状态

TeamBattle.nMaxTimes = 3;
TeamBattle.tbRefreshDay = {3, 6, 7};

TeamBattle.szCrossOpenTimeFrame = "OpenLevel89";

TeamBattle.szStartNotifyInfo = "通天塔的入口已打開，眾俠士可前往挑戰";
TeamBattle.szTopWorldNotify = "「%s」成功登頂通天塔第七層！";
TeamBattle.szTopWorldNotify_Cross = "「%s」成功登頂跨服通天塔第八層！";
TeamBattle.szTopKinNotify = "恭喜本幫派成員「%s」成功登頂通天塔第七層！";
TeamBattle.szTopKinNotify_Cross = "恭喜本幫派成員「%s」成功登頂跨服通天塔第八層！";
TeamBattle.szCloseNotify = "通天塔活動結束了！";

TeamBattle.tbLeagueTopWorldNotify =
{
	[TeamBattle.TYPE_MONTHLY] = "「%s」成功登頂月度通天塔第八層！";
	[TeamBattle.TYPE_QUARTERLY] = "「%s」成功登頂季度通天塔第八層！";
	[TeamBattle.TYPE_YEAR] = "「%s」成功登頂年度通天塔第八層！";
}

TeamBattle.tbLeagueTopKinNotify =
{
	[TeamBattle.TYPE_MONTHLY] = "恭喜本幫派成員「%s」成功登頂月度通天塔第八層！";
	[TeamBattle.TYPE_QUARTERLY] = "恭喜本幫派成員「%s」成功登頂季度通天塔第八層！";
	[TeamBattle.TYPE_YEAR] = "恭喜本幫派成員「%s」成功登頂年度通天塔第八層！";
}

TeamBattle.tbLeagueCloseNotify = {
	[TeamBattle.TYPE_MONTHLY] = "月度通天塔結束了！";
	[TeamBattle.TYPE_QUARTERLY] = "季度通天塔結束了！";
	[TeamBattle.TYPE_YEAR] = "年度通天塔結束了！";
}

TeamBattle.szTopNotifyCrossWin = "「%s」帶領小隊，在跨服通天塔中擊敗了來自 %s 服的「%s」小隊，榮登第八層";
TeamBattle.szTopNotifyCrossLost = "「%s」帶領的小隊，被 %s 服的「%s」小隊擊敗，未能登頂八層";

-- 亲密度
TeamBattle.tbAddImityInfo = {
	[0] = 40,
	[1] = 60,
	[2] = 80,
	[3] = 100,
	[4] = 120,
	[5] = 150,
};

TeamBattle.TeamBattlePanelDescribe =
{
	["Describe"] = [[·3人組隊，3 對 3的小隊競技
·從通天塔的底層開始，每輪會隨機匹配同處於本層的另一個隊伍來進行挑戰
·每輪挑戰分上、下兩個半場，最終累計擊敗對方人數最多的隊伍為勝
·勝者隊可以進入更高一層，再與同層的其他隊伍匹配對戰
·負者隊繼續留在本層，再與同層的其他隊伍匹配對戰
·整個通天塔共5輪，全勝隊伍有望進入到塔頂第七層！獲得通天塔最高榮譽！
]],
}

-- 准备场出生点，可以配多个，随机取用
TeamBattle.tbPreMapBeginPos =
{
	{6374, 6891};
	{6403, 4430};
	{6403, 4430};
}

-- 战斗场地图配置,随机取用
TeamBattle.tbFightMapBeginPoint =
{
	[1] = {--一层
		--地图ID 	1队：   休息点			出生点 		2队：  休息点		出生点
		{1041, 			{{7960, 6783}, {2698, 5581}}, 		{{7905, 2076}, {2698, 3408}}},
	};
	[2] = {--二层
		--地图ID 	1队：   休息点			出生点 		2队：  休息点		出生点
		{1042, 			{{8283, 6090}, {3155, 3250}}, 		{{8277, 2106}, {3081,5504}}},
	};
	[3] = {--三层
		--地图ID 	1队：   休息点			出生点 		2队：  休息点		出生点
		{1043, 			{{6432, 5391}, {1340, 4845}}, 		{{6439, 1985}, {1402, 2526}}},
	};
	[4] = {--四层
		--地图ID 	1队：   休息点			出生点 		2队：  休息点		出生点
		{1044, 			{{7540, 6009}, {2274, 5082}}, 		{{7393, 1689}, {2311, 2921}}},
	};
	[5] = {--五层
		--地图ID 	1队：   休息点			出生点 		2队：  休息点		出生点
		{1045, 			{{7864, 6297}, {2691, 5381}}, 		{{7711, 2269}, {2720, 3155}}},
	};
	[6] = {--六层
		--地图ID 	1队：   休息点			出生点 		2队：  休息点		出生点
		{1046, 			{{8365, 6431}, {3260, 5244}}, 		{{8323, 1810}, {3304, 3066}}},
	};
	[7] = {--七层
		--地图ID 	1队：   休息点			出生点 		2队：  休息点		出生点
		{1056, 			{{8365, 6431}, {3260, 5244}}, 		{{8323, 1810}, {3304, 3066}}},
	};
}

TeamBattle.nAwardItemId = 2418;
TeamBattle.nAwardItemNeedHonor = 800;

-- 各层奖励
TeamBattle.tbAwardInfo =
{
	[1] = {
		{"BasicExp", 100};
		nTeamBattleHonor = 1000,
	};
	[2] = {
		{"BasicExp", 120};
		nTeamBattleHonor = 1100,
	};
	[3] = {
		{"BasicExp", 140};
		nTeamBattleHonor = 1200,
	};
	[4] = {
		{"BasicExp", 150};
		nTeamBattleHonor = 1500,
	};
	[5] = {
		{"BasicExp", 160};
		nTeamBattleHonor = 1800,
	};
	[6] = {
		{"BasicExp", 180};
		nTeamBattleHonor = 2100,
	};
	[7] = {
		{"BasicExp", 200};
		nTeamBattleHonor = 2400,
	};
	[8] = {
		{"BasicExp", 220};
		nTeamBattleHonor = 3000,
	};
}

-- 月度赛增加亲密度
TeamBattle.nLeagueAddImity = 100;

-- 联赛奖励内容
TeamBattle.tbLeagueAward = {
	[TeamBattle.TYPE_MONTHLY] = {
		[1] = {{"BasicExp", 100}, {"Energy", 1500}},
		[2] = {{"BasicExp", 120}, {"Energy", 1800}},
		[3] = {{"BasicExp", 140}, {"Energy", 2000}},
		[4] = {{"BasicExp", 150}, {"Energy", 2500}},
		[5] = {{"BasicExp", 160}, {"Energy", 3000}},
		[6] = {{"BasicExp", 180}, {"Energy", 4000}},
		[7] = {{"BasicExp", 200}, {"Energy", 5000}},
		[8] = {{"BasicExp", 220}, {"Energy", 7000}},
	};
	[TeamBattle.TYPE_QUARTERLY] = {
		[1] = {{"BasicExp", 100}, {"Energy", 1000}},
		[2] = {{"BasicExp", 100}, {"Energy", 1000}},
		[3] = {{"BasicExp", 100}, {"Energy", 1000}},
		[4] = {{"BasicExp", 100}, {"Energy", 1000}},
		[5] = {{"BasicExp", 100}, {"Energy", 1000}},
		[6] = {{"BasicExp", 100}, {"Energy", 1000}},
		[7] = {{"BasicExp", 100}, {"Energy", 1000}},
		[8] = {{"BasicExp", 100}, {"Energy", 1000}},
	};
	[TeamBattle.TYPE_YEAR] = {
		[1] = {{"BasicExp", 100}, {"Energy", 1000}},
		[2] = {{"BasicExp", 100}, {"Energy", 1000}},
		[3] = {{"BasicExp", 100}, {"Energy", 1000}},
		[4] = {{"BasicExp", 100}, {"Energy", 1000}},
		[5] = {{"BasicExp", 100}, {"Energy", 1000}},
		[6] = {{"BasicExp", 100}, {"Energy", 1000}},
		[7] = {{"BasicExp", 100}, {"Energy", 1000}},
		[8] = {{"BasicExp", 100}, {"Energy", 1000}},
	};
};

TeamBattle.tbStartFailMailInfo = {
	[TeamBattle.TYPE_MONTHLY] = {"月度通天塔開啟失敗", "      很遺憾，由於本場月度通天塔競技比賽晉級玩家不足，導致不能正常舉行比賽。現已為您準備了月度通天塔的最高獎勵作為補償，請查收。\n      望少俠再度征戰通天塔，下一次能遇到旗鼓相當的對手，勇奪殊榮！"},
	[TeamBattle.TYPE_QUARTERLY] = {"季度通天塔開啟失敗", "      很遺憾，由於本場季度通天塔競技比賽晉級玩家不足，導致不能正常舉行比賽。現已為您準備了季度通天塔的最高獎勵作為補償，請查收。\n      望少俠再度征戰通天塔，下一次能遇到旗鼓相當的對手，勇奪殊榮！"},
	[TeamBattle.TYPE_YEAR] = {"年度通天塔開啟失敗", "      很遺憾，由於本場年度通天塔競技比賽晉級玩家不足，導致不能正常舉行比賽。現已為您準備了年度通天塔的最高獎勵作為補償，請查收。\n      望少俠再度征戰通天塔，下一次能遇到旗鼓相當的對手，勇奪殊榮！"},
};

TeamBattle.tbSpaceTipsMailInfo = {
	[TeamBattle.TYPE_MONTHLY] = {"月度通天塔參與失敗", "      很遺憾，由於您在月度通天塔競技比賽中，未能組滿隊伍，導致不能正常參與比賽。現已為您準備了月度通天塔的基礎獎勵，請查收。\n      望少俠下次準備充分，攜手隊友，再度征戰通天塔！"},
	[TeamBattle.TYPE_QUARTERLY] = {"季度通天塔參與失敗", "      很遺憾，由於您在季度通天塔競技比賽中，未能組滿隊伍，導致不能正常參與比賽。現已為您準備了季度通天塔的基礎獎勵，請查收。\n      望少俠下次準備充分，攜手隊友，再度征戰通天塔！"},
	[TeamBattle.TYPE_YEAR] = {"年度通天塔參與失敗", "      很遺憾，由於您在年度通天塔競技比賽中，未能組滿隊伍，導致不能正常參與比賽。現已為您準備了年度通天塔的基礎獎勵，請查收。\n      望少俠下次準備充分，攜手隊友，再度征戰通天塔！"},
}

TeamBattle.tbAwardMailInfo =
{
	[TeamBattle.TYPE_MONTHLY] = {"月度通天塔挑戰獎勵", "      恭喜你在本次月度通天塔中登上%s層，獲得如下獎勵。"},
	[TeamBattle.TYPE_QUARTERLY] = {"季度通天塔挑戰獎勵", "      恭喜你在本次季度通天塔中登上%s層，獲得如下獎勵。"},
	[TeamBattle.TYPE_YEAR] = {"年度通天塔挑戰獎勵", "      恭喜你在本次年度通天塔中登上%s層，獲得如下獎勵。"},
}

TeamBattle.nPreTipTime = 2 * 24 * 3600;			-- 开赛前提示，提前时间

-- 开赛前提示邮件
TeamBattle.tbLeagueTipMailInfo =
{
	[TeamBattle.TYPE_MONTHLY] = {"月度通天塔參賽通知", "      您已獲得本次月度通天塔競技的參賽資格，比賽時間為[EACC00]%s[-]，請您務必準時參加。屆時會有更豐厚的獎勵以及更高的榮譽等著您！"},
	[TeamBattle.TYPE_QUARTERLY] = {"季度通天塔參賽通知", "      您已獲得本次季度通天塔競技的參賽資格，比賽時間為[EACC00]%s[-]，請您務必準時參加。屆時會有更豐厚的獎勵以及更高的榮譽等著您！"},
	[TeamBattle.TYPE_YEAR] = {"年度通天塔參賽通知", "      您已獲得本次年度通天塔競技的參賽資格，比賽時間為[EACC00]%s[-]，請您務必準時參加。屆時會有更豐厚的獎勵以及更高的榮譽等著您！"},
}

-- 非程序勿动
TeamBattle.tbTipSaveValue =
{
	[TeamBattle.TYPE_MONTHLY] = TeamBattle.SAVE_MONTHLY_TIP,
	[TeamBattle.TYPE_QUARTERLY] = TeamBattle.SAVE_QUARTERLY_TIP,
	[TeamBattle.TYPE_YEAR] = TeamBattle.SAVE_YEAR_TIP,
}

TeamBattle.szStartMsg = "根據你隊實力，本次從第%s層開始";
TeamBattle.szJoinMsg = "現在是%s層，開打了！";
TeamBattle.szWinMsg = "挑戰成功，登上第%s層！";
TeamBattle.szFailMsg = "遺憾落敗，繼續留在第%s層！";
TeamBattle.szTopMsg = "恭喜你們本次通天塔登上了第%s層！";

TeamBattle.STATE_TRANS =  --战场流程控制
{
	{nSeconds = 5,   	szFunc = "WaitePlayer",		szDesc = "等待開始"},
	{nSeconds = 5,   	szFunc = "ShowTeamInfo",	szDesc = "等待開始"},
	{nSeconds = 4,   	szFunc = "PreStart",		szDesc = "等待開始"},
	{nSeconds = 86,   	szFunc = "StartFight",		szDesc = "上半場"},
	{nSeconds = 20,   	szFunc = "MidRest",			szDesc = "中場休息"},
	{nSeconds = 4,   	szFunc = "PreStart",		szDesc = "等待開始"},
	{nSeconds = 86,   	szFunc = "StartFight",		szDesc = "下半場"},
	{nSeconds = 20,   	szFunc = "ClcResult",		szDesc = "等待配對"},
}

TeamBattle.STATE_TRANS_CROSS =  --战场流程控制
{
	{nSeconds = 10,   	szFunc = "WaitePlayer",		szDesc = "等待開始"},
	{nSeconds = 5,   	szFunc = "ShowTeamInfo",	szDesc = "等待開始"},
	{nSeconds = 4,   	szFunc = "PreStart",		szDesc = "等待開始"},
	{nSeconds = 86,   	szFunc = "StartFight",		szDesc = "上半場"},
	{nSeconds = 20,   	szFunc = "MidRest",			szDesc = "中場休息"},
	{nSeconds = 4,   	szFunc = "PreStart",		szDesc = "等待開始"},
	{nSeconds = 86,   	szFunc = "StartFight",		szDesc = "下半場"},
	{nSeconds = 20,   	szFunc = "ClcResult",		szDesc = "等待配對"},
}

TeamBattle.emMsgNotTeamCaptain		= 1;
TeamBattle.emMsgNotNeedTeam			= 2;
TeamBattle.emMsgNeedTeam			= 3;
TeamBattle.emMsgTeamMemeberErr		= 4;
TeamBattle.emMsgMemberOffline		= 5;
TeamBattle.emMsgMemberMinLevel		= 6;
TeamBattle.emMsgMemberSafeMap		= 7;
TeamBattle.emMsgMemberAloneState	= 8;
TeamBattle.emMsgMinLevel			= 9;
TeamBattle.emMsgSafeMap				= 10;
TeamBattle.emMsgAloneState			= 11;
TeamBattle.emMsgHasNoBattle			= 12;
TeamBattle.emMsgTimesErr			= 13;
TeamBattle.emMsgMemberTimesErr		= 14;
TeamBattle.emMsgHasFight			= 15;
TeamBattle.emMsgMemberNotSafePoint	= 16;
TeamBattle.emMsgNotSafePoint		= 17;
TeamBattle.emMsgSystemSwitch		= 18;
TeamBattle.emMsgMemberSystemSwitch	= 19;
TeamBattle.emMsgLeagueTicket		= 20;
TeamBattle.emMsgMemberLeagueTicket	= 21;
TeamBattle.emMsgMemberHasLeagueTicket	= 22;

TeamBattle.tbMsg =
{
	[TeamBattle.emMsgNotTeamCaptain]		= "不是隊長，無法操作！";
	[TeamBattle.emMsgNotNeedTeam]			= "組隊狀態，無法單人報名！";
	[TeamBattle.emMsgNeedTeam]				= "沒有隊伍，無法組隊報名！";
	[TeamBattle.emMsgTeamMemeberErr]		= "組隊模式只允許%s人報名！";
	[TeamBattle.emMsgMemberOffline]			= "有隊員不線上，無法報名！";
	[TeamBattle.emMsgMemberMinLevel]		= "「%s」等級不足%s，無法報名！";
	[TeamBattle.emMsgMemberSafeMap]			= "「%s」所在地圖無法報名！";
	[TeamBattle.emMsgMemberAloneState]		= "「%s」正在參與其它活動，無法報名！";
	[TeamBattle.emMsgMinLevel]				= "等級不足%s，無法參加！";
	[TeamBattle.emMsgSafeMap]				= "目前地圖無法報名！";
	[TeamBattle.emMsgAloneState]			= "你正在參與其它活動，等結束後再來報名！";
	[TeamBattle.emMsgHasNoBattle]			= "活動未開啟！";
	[TeamBattle.emMsgTimesErr]				= "你可參與次數不足！";
	[TeamBattle.emMsgLeagueTicket]			= "你沒有參賽資格！";
	[TeamBattle.emMsgMemberTimesErr]		= "「%s」可參與次數不足！";
	[TeamBattle.emMsgMemberLeagueTicket]	= "「%s」尚未獲取系列賽資格，無法參加。";
	[TeamBattle.emMsgMemberHasLeagueTicket]	= "「%s」擁有系列賽資格，無法參加跨服通天塔。";
	[TeamBattle.emMsgHasFight]				= "本次通天塔已開啟，請等下次再來";
	[TeamBattle.emMsgMemberNotSafePoint]	= "「%s」不在安全區，無法報名！";
	[TeamBattle.emMsgNotSafePoint]			= "你不在安全區，無法報名";
	[TeamBattle.emMsgSystemSwitch]			= "你目前狀態不允許報名";
	[TeamBattle.emMsgMemberSystemSwitch]	= "「%s」目前狀態不允許報名";
}

-- 通天塔奖励配置
TeamBattle.tbReward =
{

	{"Item", 1346, 1},
	{"Item", 1736, 1},
	{"Contrib", 0},

}

function TeamBattle:RefreshTimes(pPlayer)
	local nUsedTimes = pPlayer.GetUserValue(self.SAVE_GROUP, self.SAVE_USE_COUNT);
	local nLastWeekUseCount = pPlayer.GetUserValue(self.SAVE_GROUP, self.SAVE_LAST_WEEK_USE_COUNT);
	local nSaveDate = pPlayer.GetUserValue(self.SAVE_GROUP, self.SAVE_DATE);
	local nWeek = Lib:GetLocalWeek();

	if pPlayer.GetUserValue(self.SAVE_GROUP, self.SAVE_LAST_WEEK_DATE) ~= nWeek - 1 then
		nLastWeekUseCount = self.nMaxTimes;

		if nSaveDate == nWeek - 1 then
			nLastWeekUseCount = nUsedTimes;
		elseif nSaveDate > 0 and nSaveDate < nWeek - 1 then
			nLastWeekUseCount = 0;
		end
		if MODULE_GAMESERVER then
			pPlayer.SetUserValue(self.SAVE_GROUP, self.SAVE_LAST_WEEK_USE_COUNT, nLastWeekUseCount);
			pPlayer.SetUserValue(self.SAVE_GROUP, self.SAVE_LAST_WEEK_DATE, nWeek - 1);
		end
	end

	if nSaveDate ~= nWeek then
		if MODULE_GAMESERVER then
			pPlayer.SetUserValue(self.SAVE_GROUP, self.SAVE_DATE, nWeek);
			pPlayer.SetUserValue(self.SAVE_GROUP, self.SAVE_USE_COUNT, 0);
		end
		nUsedTimes = 0;
	end

	return nUsedTimes, nLastWeekUseCount;
end

function TeamBattle:GetLastTimes(pPlayer)
	local nCostTimes, nLastWeekUseCount = self:RefreshTimes(pPlayer);
	local nMaxTimes = 0;
	local nWeekDay = Lib:GetLocalWeekDay();
	for _, nWDay in pairs(self.tbRefreshDay) do
		if nWDay <= nWeekDay then
			nMaxTimes = nMaxTimes + 1;
		end
	end

	local nLastWeekMaxTimes = math.min(self.nMaxTimes, #self.tbRefreshDay);

	-- 开了攻城战后会周六少开一场
	if GetTimeFrameState("OpenDomainBattle") == 1 then
		nMaxTimes = nMaxTimes - 1;
		nLastWeekMaxTimes = nLastWeekMaxTimes - 1;

		-- 恰好是周日开启攻城战的时间轴，本周六已过，此时攻城战不开，那么本周六还是正常开，所以还有3场
		if nWeekDay == 7 then
			local nOpenTime = CalcTimeFrameOpenTime("OpenDomainBattle");
			local nOpenDay = Lib:GetLocalDay(nOpenTime);
			if nOpenDay == Lib:GetLocalDay() then
				nMaxTimes = nMaxTimes + 1;
			end
		elseif nWeekDay < 6 then
			nMaxTimes = nMaxTimes + 1;
		end
	end

	nMaxTimes = math.min(nMaxTimes, self.nMaxTimes);

	local nLastTimes = nMaxTimes - nCostTimes;
	nLastTimes = math.max(nLastTimes, 0);


	return nLastTimes, nMaxTimes, math.max(nLastWeekMaxTimes - nLastWeekUseCount, 0);
end

function TeamBattle:CostTimes(pPlayer)
	self:RefreshTimes(pPlayer);
	local nCurUseCount = pPlayer.GetUserValue(self.SAVE_GROUP, self.SAVE_USE_COUNT);
	pPlayer.SetUserValue(self.SAVE_GROUP, self.SAVE_USE_COUNT, math.max(nCurUseCount + 1, 1));
	self:OnPlayedTeamBattle(pPlayer)	
end

function TeamBattle:OnPlayedTeamBattle(pPlayer)
	Achievement:AddCount(pPlayer, "TeamBattle_1", 1);
	TeacherStudent:CustomTargetAddCount(pPlayer, "Tower", 1)
end

function TeamBattle:SendMsgCode(player, nCode, ...)
	local pPlayer = player;
	if type(player) == "number" then
		pPlayer = KPlayer.GetPlayerObjById(player);
	end
	if not pPlayer then
		return;
	end

	if type(nCode) == "string" then
		pPlayer.CenterMsg(nCode)
		return
	end

	pPlayer.CallClientScript("TeamBattle:MsgCode", nCode, ...);
end

function TeamBattle:CheckTicket(pPlayer, nType, nTime)
	nTime = nTime or GetTime();
	local nNextOpenTime = self:GetNextOpenTime(nType, nTime);
	if nType == self.TYPE_MONTHLY then
		local nCheckMonth = Lib:GetLocalMonth(nNextOpenTime);
		nCheckMonth = nCheckMonth - 1;
		if pPlayer.GetUserValue(self.SAVE_GROUP, self.SAVE_MONTHLY_INFO) == nCheckMonth or
			pPlayer.GetUserValue(self.SAVE_GROUP, self.SAVE_MONTHLY_INFO_OLD) == nCheckMonth then

			return true;
		end
	elseif nType == self.TYPE_QUARTERLY then
		local nLocalSeason = Lib:GetLocalSeason(nNextOpenTime);
		if pPlayer.GetUserValue(self.SAVE_GROUP, self.SAVE_QUARTERLY_INFO) == nLocalSeason or
			pPlayer.GetUserValue(self.SAVE_GROUP, self.SAVE_QUARTERLY_INFO_OLD) == nLocalSeason then

			return true;
		end
	elseif nType == self.TYPE_YEAR then
		local nLocalYear = Lib:GetLocalYear(nNextOpenTime);
		nLocalYear = nLocalYear - 1;
		if pPlayer.GetUserValue(self.SAVE_GROUP, self.SAVE_YEAR_INFO) == nLocalYear or
			pPlayer.GetUserValue(self.SAVE_GROUP, self.SAVE_YEAR_INFO_OLD) == nLocalYear then

			return true;
		end
	end

	return false;
end

function TeamBattle:GetNextOpenTime(nType, nTime)
	if not MODULE_ZONESERVER and GetTimeFrameState(TeamBattle.szLeagueOpenTimeFrame) ~= 1 then
		return nil;
	end

	local nNow = nTime or GetTime();
	if nType == self.TYPE_MONTHLY then
		local nOpenTime = Lib:GetTimeByWeekInMonth(nNow, TeamBattle.nMonthlyOpenWeek, TeamBattle.nMonthlyOpenWeekDay, TeamBattle.nMonthlyOpenHour, TeamBattle.nMonthlyOpenMin, 0);
		if nOpenTime < nNow then
			local tbTime = os.date("*t", nOpenTime);
			tbTime.month = tbTime.month + 1;
			if tbTime.month > 12 then
				tbTime.month = 1;
				tbTime.year = tbTime.year + 1;
			end

			nOpenTime = os.time(tbTime);
			nOpenTime = Lib:GetTimeByWeekInMonth(nOpenTime, TeamBattle.nMonthlyOpenWeek, TeamBattle.nMonthlyOpenWeekDay, TeamBattle.nMonthlyOpenHour, TeamBattle.nMonthlyOpenMin, 0);
		end

		return nOpenTime;
	elseif nType == self.TYPE_QUARTERLY then
		local tbTime = os.date("*t", nNow);
		local nOpenMonth = math.ceil(tbTime.month / 3) * 3;
		if nOpenMonth ~= tbTime.month then
			tbTime.month = nOpenMonth;
			tbTime.day = 1;
			tbTime.hour = 0;
			tbTime.min = 0;
		end

		local nTime = os.time(tbTime);
		local nOpenTime = Lib:GetTimeByWeekInMonth(nTime, TeamBattle.nQuarterlyOpenWeek, TeamBattle.nQuarterlyOpenWeekDay, TeamBattle.nQuarterlyOpenHour, TeamBattle.nQuarterlyOpenMin, 0);
		if nOpenTime < nNow then
			tbTime.month = nOpenMonth + 3;
			if tbTime.month > 12 then
				tbTime.year = tbTime.year + 1;
				tbTime.month = 3;
			end
		end

		nTime = os.time(tbTime);
		nOpenTime = Lib:GetTimeByWeekInMonth(nTime, TeamBattle.nQuarterlyOpenWeek, TeamBattle.nQuarterlyOpenWeekDay, TeamBattle.nQuarterlyOpenHour, TeamBattle.nQuarterlyOpenMin, 0);
		assert(nOpenTime > nNow);

		return nOpenTime;
	elseif nType == self.TYPE_YEAR then
		local tbTime = os.date("*t", nNow);
		tbTime.month = TeamBattle.nYearOpenMonth;
		tbTime.day = 1;
		tbTime.hour = 0;
		tbTime.min = 0;

		local nTime = os.time(tbTime);
		local nOpenTime = Lib:GetTimeByWeekInMonth(nTime, TeamBattle.nYearOpenWeek, TeamBattle.nYearOpenWeekDay, TeamBattle.nYearOpenHour, TeamBattle.nYearOpenMin, 0);
		if nOpenTime < nNow then
			tbTime.year = tbTime.year + 1;
		end

		nTime = os.time(tbTime);
		nOpenTime = Lib:GetTimeByWeekInMonth(nTime, TeamBattle.nYearOpenWeek, TeamBattle.nYearOpenWeekDay, TeamBattle.nYearOpenHour, TeamBattle.nYearOpenMin, 0);
		assert(nOpenTime > nNow);

		return nOpenTime;
	end
end