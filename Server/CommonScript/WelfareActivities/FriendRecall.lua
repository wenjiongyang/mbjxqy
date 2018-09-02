--常驻活动不挂在Activity下了

FriendRecall.Def = {
	MAIN_ICON_SHOW_TIME = {Lib:ParseDateTime("2017-03-01 00:00:00"), Lib:ParseDateTime("2017-03-28 23:59:59")},
	BEGIN_DATE = 1, --(暂时没用)每月回归开始日期，这个时间段内符合离线标准的玩家回归了才有效
	END_DATE = 31, --每月回归结束日期
	LAST_ONLINE_TIME_LIMIT = 15 * 24 * 60 * 60, --离线多久算老玩家
	AWARD_TIME = 30 * 24 * 60 * 60,		 --福利持续多久
	MAX_RENOWN_WEEKLY = 10000, 	--每周获取名望上限
	MAX_RENOWN_COUNT_WEEKLY = 3,	--每个活动每周最多可以获得几次回归玩家的额外名望奖励
	RENOWN_FRESH_TIME = 4 * 3600; 	--4点刷新累计上限
	MAX_AWARD_PLAYER_COUNT = 100, 	--老玩家召回福利列表上限
	MAX_SHOW_CAN_RECALL_COUNT = 10, --最多显示多少名可召回玩家(按亲密度排序)
	IMITY_LEVEL_LIMIT = 10, 			--好友亲密度等级限制
	RESH_LIST_INTERVAL = 10, 		--列表刷新请求间隔
	IMITY_BONUS = 2,				--亲密度加成100%
	MAX_RECALLED_COUNT  = 5,		--召回次数
	TEAM_BUFF_TIME = 3*24*3600,		--组队buff时间
	TEAM_BUFF_ID = 2317,			--组队buff ID
	RENOWN_VALUE = 				--名望奖励
	{
		["TeamFuben"] = 100,	--组队秘境
		["RandomFuben"] = 100,	--凌绝峰
		["AdventureFuben"] = 100,	--山贼秘窟
		["PunishTask"] = 40,		--惩恶
		["TeamBattle"] = 500,		--通天塔
		["InDifferBattle"] = 500,	--心魔幻境
	},
--------------------------以上为策划配置项--------------------------
	SAVE_GROUP = 61,
	ACTIVITY_VERSION = 101, --版本信息
	RECALL = 102, --是否是召回的老玩家
	AWARD_END_TIME = 103, --福利结束时间
	GET_RENOWN = 104, --累计获取的名望
	RESET_RENOWN_WEEK = 105,--重置名望累计周
	HAVE_RECALL_PLAYER = 106,--有过可召回玩家标记
	TEAM_BATTLE_RENOWN = 107,--每周获取通天塔名望奖励次数
	PUNISH_TASK_RENOWN = 108,--每周获取惩恶名望奖励次数
	TEAM_FUBEN_RENOWN = 109,--每周获取组队秘境名望奖励次数
	RANDOM_FUBEN_RENOWN = 110,--每周获取凌绝峰名望奖励次数
	ADVENTURE_FUBEN_RENOWN = 111,--每周获取山贼秘窟名望奖励次数
	INDIFFER_BATTLE_RENOWN = 112,--每周获取心魔幻境名望奖励次数
}

FriendRecall.Def.RENOWN_SAVE_MAP = 
{
	["TeamFuben"] = FriendRecall.Def.TEAM_FUBEN_RENOWN,
	["RandomFuben"] = FriendRecall.Def.RANDOM_FUBEN_RENOWN,
	["AdventureFuben"] = FriendRecall.Def.ADVENTURE_FUBEN_RENOWN,
	["PunishTask"] = FriendRecall.Def.PUNISH_TASK_RENOWN,
	["TeamBattle"] = FriendRecall.Def.TEAM_BATTLE_RENOWN,
	["InDifferBattle"] = FriendRecall.Def.INDIFFER_BATTLE_RENOWN,
}

FriendRecall.RecallType = 
{
	TEACHER = 1,
	STUDENT = 2,
	FIREND = 3,
	KIN = 4,	
}

FriendRecall.AwardInfo = 
{
	szTitle = [[許久不見，如今安好？
   往日征戰江湖的夥伴，是否漸行漸遠，如今功成名就，是否想與他們同享喜悅？若有此心，不若行動，通過Facebook和LINE找到他們，一同再戰江湖！]],

   	szDesc = [[
規則&獎勵說明
  1、與被召回俠士組隊完成[FFFE0D]組隊秘境、淩絕峰、山賊秘窟、懲惡任務、心魔幻境、通天塔[-]時將額外獲得名望
  2、與召回玩家組隊時將獲得屬性加成的增益狀態（跨服無效）
  3、與召回玩家提升親密度時將獲得100%加成
  4、与召回玩家提升亲密度时将获得100%加成]],

     	tbAward = {{3640, 1}, {3641, 1}, {3642, 1}},
}

FriendRecall.RecalledAwardInfo = 
{
	szTitle = [[俠士重回江湖，實在可喜可賀！如今江湖風雲變動，武林福利不減，少俠還需多提升等級，早日重新融入江湖。]],

   	szDesc = [[
規則&獎勵說明
     1、俠士只需從好友列表中尋找符合條件的人一起組隊，均可享受「重聚江湖」狀態
     2、55級以上的俠士可以通過主介面的回歸福利按鈕領取老玩家回歸的獎勵
     3、與召回玩家組隊時將獲得屬性加成的增益狀態（跨服無效）
     4、與召回玩家提升親密度時將獲得100%加成]],

     	tbAward = {{3640, 1}, {3641, 1}, {3643, 1}},
}

FriendRecall.RecallDesc = 
{
	[FriendRecall.RecallType.TEACHER] = 
	{
		szTitle = "師徒再聚，情緣再續",
		szDesc = "徒兒，許久未見，為師甚是掛念，可要一同再闖江湖？",
	},
	[FriendRecall.RecallType.STUDENT] = 
	{
		szTitle = "一日為師，一世為師",
		szDesc = "師父，十大門派有趣得緊，你何時再帶徒兒闖蕩江湖？",
	},
	[FriendRecall.RecallType.FIREND] = 
	{
		szTitle = "酒仍暖，人未遠",
		szDesc = "好兄弟！話不在多，回來我們再一塊大口喝酒，大塊吃肉！",
	},
	[FriendRecall.RecallType.KIN] = 
	{
		szTitle = "有你之處，才是江湖",
		szDesc = "如今江湖風雲變幻，群豪爭霸，正是你回來大展身手之時！",
	},
}

--主界面是否显示图标入口
function FriendRecall:IsInShowMainIcon()
	local nNow = GetTime()
	local nBegin = self.Def.MAIN_ICON_SHOW_TIME[1];
	local nEnd = self.Def.MAIN_ICON_SHOW_TIME[2];

	if not nBegin or not nEnd then
		return false
	end

	return nBegin <= nNow and nNow <= nEnd;
end

function FriendRecall:IsInProcess()
	local nDate = Lib:GetMonthDay()
	return self.Def.BEGIN_DATE <= nDate and nDate <= self.Def.END_DATE;
end

function FriendRecall:IsRecallPlayer(pPlayer)
	return pPlayer.GetUserValue(self.Def.SAVE_GROUP, self.Def.RECALL) == 1;
end

function FriendRecall:IsHaveRecallAward(pPlayer)
	local nEndTime = pPlayer.GetUserValue(self.Def.SAVE_GROUP, self.Def.AWARD_END_TIME);
	return nEndTime > 0 and nEndTime > GetTime();
end
