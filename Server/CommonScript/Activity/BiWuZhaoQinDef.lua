BiWuZhaoQin.SAVE_GROUP = 125;
BiWuZhaoQin.INDEX_LAST_DATE = 1;
BiWuZhaoQin.INDEX_ID = 2;

BiWuZhaoQin.nOpenZhaoQinCD = 3;		--两次招亲的时间间隔（单位：天）

BiWuZhaoQin.nCostGold_TypeGlobal = 5000;		-- 开启全服招亲消耗元宝
BiWuZhaoQin.nCostGold_TypeKin = 3000;			-- 开启家族招亲消耗元宝

BiWuZhaoQin.nMinPlayerLevel = 50;	-- 招亲活动最低等级限制

BiWuZhaoQin.nTitleId = 6200;			-- 情缘称号ID
BiWuZhaoQin.nTitleNameMin = 3;		-- 最小称号长度
BiWuZhaoQin.nTitleNameMax = 6;		-- 最大称号长度
BiWuZhaoQin.nVNTitleNameMin = 4;	-- 越南版最小称号长度
BiWuZhaoQin.nVNTitleNameMax = 20;	-- 越南版最大称号长度

BiWuZhaoQin.nTHTitleNameMin = 3;	-- 泰国版最小称号长度
BiWuZhaoQin.nTHTitleNameMax = 16;	-- 泰国版最大称号长度

-- 开启招亲的UI内容
BiWuZhaoQin.szUiDesc = [[
·[FFFE0D]活動時間[-]：2017年12月19日10點~2018年1月14日21:30。
·開啟的“比武招親”比賽，系統會自動排期，每[FFFE0D]周日20：30[-]開啟比賽。[FFFE0D]活動期間開啟場次有限，排期滿後不再接受預定。[-]
·比賽開始報名時，玩家可以去找燕若雪參加比賽，最多允許[FFFE0D]128人[-]參賽。
·不參賽的玩家可以從燕若雪處以“[FFFE0D]觀戰[-]”的形式進入比賽地圖。
·比賽冠軍能獲得“[FFFE0D]定情信物[-]”，可使用該道具與開啟比武招親的玩家結成情緣關係。
·比賽為[FFFE0D]無差別、無五行相剋[-]形式，角色能力由系統設定。
]]

-- 最新消息标题
BiWuZhaoQin.szNewInfomationTitle = "比武招親";
-- 最新消息内容
BiWuZhaoQin.szNewInfomation = [[[FFFE0D]比武招親活動開始了！[-]

[FFFE0D]活動時間：[-]2017年12月19日10點~2018年1月14日21:30
[FFFE0D]參與等級：[-]50級
      比武招親是一場[FFFE0D]無差別、無五行相克[-]的競技比賽，優勝者可以與發佈招親的人結成情緣關係！

[FFFE0D]1、開啟招親[-]
      活動期間，[FFFE0D]50級[-]以上玩家可去襄陽找[FFFE0D][url=npc:燕若雪, 631, 10][-]開啟“比武招親”，系統會自動排期，每[FFFE0D]周日20：30[-]開啟比賽。
      開啟招親時可以設定招親範圍（全服或本幫派），還可以限制參賽者的最低等級和最低頭銜。
      全服和每個幫派每週可以開啟一場比武招親，[FFFE0D]活動期間開啟場次有限，排期滿後不再接受預定。[-]

[FFFE0D]2、參與招親比賽[-]
      比賽開始報名時，50級以上的玩家可以去找[FFFE0D][url=npc:燕若雪, 631, 10][-]參加比武招親比賽，滿足條件可以參加比賽，每場最多允許[FFFE0D]128人[-]參賽。
      比賽為無差別形式，角色[FFFE0D]能力由系統設定[-]，開打後玩家會成為自己門派對應的無差別角色，[FFFE0D]五行相克[-]效果也被取消了。
      參賽者兩兩隨機配對戰鬥，贏者晉級，當剩餘參賽人數不大於[FFFE0D]8人[-]後進入決賽階段。
      決賽階段比賽在[FFFE0D]場內擂臺[-]上進行，玩家可以進行[FFFE0D]觀戰[-]。

[FFFE0D]3、情緣關係[-]
      比賽冠軍能獲得道具“[FFFE0D]定情信物[-]”，與招親玩家單獨組隊使用可以結成情緣關係。
      關係結成時，可以設定[FFFE0D]情緣稱號[-]。
]];

-- 比武招亲最低限制
BiWuZhaoQin.tbLimitByTimeFrame =
{

	-- 时间轴			显示最高头衔    最高能设置的限制等级
	{"OpenLevel39", 		7, 				69};
	{"OpenLevel79", 		8, 				79};
	{"OpenLevel89", 		9, 				89};
	{"OpenLevel99", 		11,				99};
	{"OpenLevel109", 		11,				109};
}

BiWuZhaoQin.szOpenTime = "20:30";			-- 开启时间

BiWuZhaoQin.tbOpenWeekDay = 			-- 周几开启 (1-7)
{
	[7] = 1;
};

----------------------------------------------战斗相关

BiWuZhaoQin.TYPE_GLOBAL = 1;
BiWuZhaoQin.TYPE_KIN = 2;

-- 阶段
BiWuZhaoQin.Process_Pre = 1 											-- 准备阶段，任意进出地图报名
BiWuZhaoQin.Process_Fight = 2 											-- 战斗阶段，不允许报名，允许观战，匹配开打时不在线或不在准备场则失去资格
BiWuZhaoQin.Process_Final = 3 											-- 八强阶段，匹配开打时不在线或不在准备场则失去资格

BiWuZhaoQin.nDealyLeaveTime = 3 										-- 延迟几秒离开对战地图，为了显示结果

BiWuZhaoQin.FIGHT_TYPE_MAP = 1
BiWuZhaoQin.FIGHT_TYPE_ARENA = 2


BiWuZhaoQin.STATE_TRANS = 												--擂台流程控制
{

	{nSeconds = 2,   	szFunc = "PlayerReady",			szDesc = "玩家準備"},
	{nSeconds = 3,   	szFunc = "PlayerAvatar",		szDesc = "玩家準備"},
	{nSeconds = 3,   	szFunc = "StartCountDown",		szDesc = "對戰準備"},
	{nSeconds = 150,    szFunc = "StartFight",			szDesc = "對戰開始"},
	{nSeconds = 3,   	szFunc = "ClcResult",			szDesc = "對戰結算"},
}

BiWuZhaoQin.tbFightState =
{
	NoJoin = 0,
	StandBy = 1,
	Next = 2,
	Out = 3,
}

BiWuZhaoQin.tbFightStateDes =
{
	[BiWuZhaoQin.tbFightState.NoJoin] 	 = "未參賽",
	[BiWuZhaoQin.tbFightState.StandBy]	 = "待定",
	[BiWuZhaoQin.tbFightState.Next]		 = "晉級",
	[BiWuZhaoQin.tbFightState.Out]		 = "淘汰",
}


-- 下面策划配
BiWuZhaoQin.nPreMapTID = 1301; 											-- 准备场位置
BiWuZhaoQin.tbPreEnterPos = {{6451,6274},{8350,6296},{4420,6273},{6506,8117},{6459,4490}}-- 进入准备场位置（随机）
BiWuZhaoQin.nTaoTaiMapTID = 1300 										-- 淘汰赛地图
BiWuZhaoQin.nFinalNum = 8 			 									-- 剩下几个人开始8强赛阶段
BiWuZhaoQin.nDeathSkillState = 1520 									-- 死亡状态
BiWuZhaoQin.nFirstFightWaitTime = 5*60 									-- 第一次开打等待时间
BiWuZhaoQin.nMatchWaitTime = 30 										-- 匹配赛等待时间
BiWuZhaoQin.nAutoMatchTime = 190										-- 自动匹配的时间（需要计算一下从上次匹配到下一次匹配的时间，再加一些时间）
																		-- 一般不用自动匹配，所有玩家报告完之后就会匹配，这是为了保险（战斗流程时间 + nDealyLeaveTime + more）
BiWuZhaoQin.nDelayKictoutTime = 5*60 									-- 比赛结束后延迟踢走玩家时间
BiWuZhaoQin.nActNpc = 631
BiWuZhaoQin.nMaxJoin = 128 												-- 可参加人数
BiWuZhaoQin.nJoinLevel = 50 											-- 参加等级

BiWuZhaoQin.nBaseExpCount = 15 											-- 每次多少基准经验

BiWuZhaoQin.nFirstMatch = 1
BiWuZhaoQin.nFightMatch = 2
BiWuZhaoQin.nFinalMatch = 3
BiWuZhaoQin.nAutoMatch = 4
BiWuZhaoQin.nAutoMatchFinal = 5

BiWuZhaoQin.tbMatchSetting =
{
	[BiWuZhaoQin.nFirstMatch] = {szUiKey = "BiWuZhaoQinFirst"},
	[BiWuZhaoQin.nFightMatch] = {szUiKey = "BiWuZhaoQinFight"},
	[BiWuZhaoQin.nFinalMatch] = {szUiKey = "BiWuZhaoQinFinal"},
	[BiWuZhaoQin.nAutoMatch]  = {szUiKey = "BiWuZhaoQinAuto"},
	[BiWuZhaoQin.nAutoMatchFinal]  = {szUiKey = "BiWuZhaoQinAutoFinal"},
}

BiWuZhaoQin.tbProcessDes =
{
	[BiWuZhaoQin.Process_Pre] = "報名階段",
	[BiWuZhaoQin.Process_Fight] = "淘汰賽階段",
	[BiWuZhaoQin.Process_Final] = "決賽階段",
}

BiWuZhaoQin.szProcessEndDes = "比武招親比賽已結束！"

-- 无差别配置(需要至少配一个默认的最小时间轴的配置)
BiWuZhaoQin.tbAvatar =
{
	["OpenLevel39"] =
	{
		nLevel = 50,
		szEquipKey = "InDiffer",
		szInsetKey = "InDiffer",
		nStrengthLevel = 50,
	},
	["OpenLevel59"] =
	{
		nLevel = 50,
		szEquipKey = "ZhaoQin59",
		szInsetKey = "ZhaoQin59",
		nStrengthLevel = 50,
	},
	["OpenLevel69"] =
	{
		nLevel = 60,
		szEquipKey = "ZhaoQin69",
		szInsetKey = "ZhaoQin69",
		nStrengthLevel = 60,
	},
	["OpenLevel79"] =
	{
		nLevel = 70,
		szEquipKey = "ZhaoQin79",
		szInsetKey = "ZhaoQin79",
		nStrengthLevel = 70,
	},
	["OpenLevel89"] =
	{
		nLevel = 80,
		szEquipKey = "ZhaoQin89",
		szInsetKey = "ZhaoQin89",
		nStrengthLevel = 80,
	},
	["OpenLevel99"] =
	{
		nLevel = 90,
		szEquipKey = "ZhaoQin99",
		szInsetKey = "ZhaoQin99",
		nStrengthLevel = 90,
	},
}

BiWuZhaoQin.tbDefaultAvatar =
{
	nLevel = 50,
	szEquipKey = "InDiffer",
	szInsetKey = "InDiffer",
	nStrengthLevel = 50,
}

-- 淘汰赛地图进入点
BiWuZhaoQin.tbTaoTaiEnterPos = {{5276,7432},{3822,8912}}

BiWuZhaoQin.nItemTID = 3592												-- 冠军道具

BiWuZhaoQin.nArenaNum = 4 												-- 准备场擂台个数

BiWuZhaoQin.tbPos =  													-- 准备场上擂台和离开擂台时双方的位置
{
	{
		tbEnterPos = {
			{7711,5167},
			{9130,3701},
		},
		tbLeavePos =
		{
			{6449,5694},
			{6449,5694},
		},
	},
	{
		tbEnterPos = {
			{5268,5176},
			{3870,3697},
		},
		tbLeavePos =
		{
			{5690,6318},
			{5690,6318},
		},
	},
	{
		tbEnterPos = {
			{7688,7406},
			{9075,8893},
		},
		tbLeavePos =
		{
			{7159,6320},
			{7159,6320},
		},
	},
	{
		tbEnterPos = {
			{5276,7432},
			{3822,8912},
		},
		tbLeavePos =
		{
			{6464,6907},
			{6464,6907},
		},
	},
}


function BiWuZhaoQin:OnSyncLoverInfo(nLoverId)
	self.nLoverId = nLoverId;
end
