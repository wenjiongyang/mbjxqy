Kin.Def = {

nMaxCountPerSrv			 = 150;	--每个服务器限制家族数量
nLevelLimite             = 11; -- 入家族等级限制
nCreationCost            = 1200; -- 家族创建开销，单位元宝
nChangeNameCost			 = 1000; --修改家族名开销，单位元宝
nCreationContribution    = 6000; -- 创建家族的贡献
nEliteContributionLine   = 1; --精英成员的贡献值分界线
nChatForbidTime          = 2 * 3600; --禁言时间
nContribDelayDeleteTime  = 7 * 24 * 3600; -- 离开家族后贡献延迟删除时间
nChangeLeaderTime		 = 3600*24*3;

nMaxCareerMailPerDay     = 3; -- 每日任命邮件最大发送次数
nMaxMailCount            = 3; --家族邮件每天最大次数..
nMailCountRefreshTime    = 4 * 3600; -- 4点刷新..
nSendMailFeeRate         = 10; -- 发送邮件的费率, 费率*家族人数
nMaxMailLength           = 200; -- 最大邮件发送字数

nMaxApplyList			= 200;	--家族申请列表最大人数

nMaxKinNameLength        = 6;
nMinKinNameLength        = 2;

nMaxKinTitleLen          = 4;
szFullTitleFormat        = "［幫派］%s·%s";

nMaxDeclareLength        = 160; -- 最大公告长度
nMaxAddDeclareLength     = 96; -- 最大宣言长度

nKinMapTemplateId = 1004; -- 家族地图模板Id.
nKinNestMapTemplateId = 700;

nPrestigeFalloffRate = 0.2;
nContributionFalloffRate = 0.2;
bForbidCamp = true; --是否禁止阵营

---------建设相关---------------
nDonate2ContribPerTime = 200;   --捐献后获得贡献
nMaxBuildingLevel      = 10; -- 建筑最大等级
nBuildingLevelUpdateTime = 4 * 60 * 60; -- 4点刷新等级
nDonateNoticeMin = 50;	-- 捐献公告的最小次数

-----------家族礼盒相关---------------
nGiftBagRefreshTime = 4 * 3600; -- 4点刷新..
nGiftBoxCost        = 100;
nMaxGiftBoxPerDay   = 4;
nGiftBoxCdTime      = 1 * 60 * 60; -- 每次领取礼包两小时cd时间

----------------职位-----------------
Career_Master     = 1; -- 族长
Career_ViceMaster = 2; -- 副族长
Career_Elder      = 3; -- 长老
Career_Elite      = 4; -- 精英
Career_Normal     = 5; -- 正式成员
Career_New        = 6; -- 见习成员
Career_Retire     = 7; -- 退隐成员
Career_Mascot     = 8; -- 家族宝贝
Career_Leader	  = 9; -- 领袖

-------------- 权限定义-------------------
Authority_Recruit           = 1;  -- 招人, 发送QQ群消息
Authority_KickOut           = 2;  -- 踢人
Authority_EditRecuitInfo    = 3;  -- 修改招聘信息
Authority_Invite            = 4;  -- 邀请
Authority_Promotion         = 5;  -- 实习成员转正
Authority_Retire            = 6;  -- 退隐

Authority_Disband           = 7; -- 解散家族
Authority_Building          = 8; -- 家族建筑, 升降级
Authority_Combine           = 9; -- 家族合并

Authority_GrantMaster       = 10; -- 传位
Authority_GrantOlder        = 11; -- 任免长老
Authority_GrantViceMaster   = 12; -- 任免副族长
Authority_GrantLeader		= 13; -- 任命领袖
Authority_GrantMascot		= 20; -- 任命家族宝贝

Authority_ChatForbid        = 14; -- 禁言
Authority_Mail              = 15; -- 发送家族邮件
Authority_EditKinTitle      = 16; -- 修改职位称谓
Authority_EditPubilcDeclare = 17; -- 修改公告
Authority_ChangeCamp        = 18; -- 修改阵营
Authority_BindGroup         = 19; -- 绑定Q群/微信群

MEMBER_GIFT_KEY_GROUP         = 85;
MEMBER_GIFT_KEY_CUR_DAY       = 1;
MEMBER_GIFT_KEY_NEXT_BUY_TIME = 2;
MEMBER_GIFT_KEY_LEFT_COUNT    = 3;
};

if version_vn then
	Kin.Def.nMaxKinNameLength		= 14
	Kin.Def.nMinKinNameLength		= 4

	Kin.Def.nMaxKinTitleLen 		= 14;
	Kin.Def.nMaxMailLength  		= 400;
elseif version_hk or version_tw or version_xm then
	Kin.Def.nMaxKinNameLength		= 22
	Kin.Def.nMaxKinTitleLen			= 12
elseif version_th then
	Kin.Def.nMaxKinNameLength		= 14
	Kin.Def.nMaxKinTitleLen			= 8
end

Kin.Def.tbManagerCareers = {
	[Kin.Def.Career_Master] = true,
	[Kin.Def.Career_ViceMaster] = true,
	[Kin.Def.Career_Elder] = true,
	[Kin.Def.Career_Mascot] = true,
}

Kin.Def.CareerAuthorityName = {
	[Kin.Def.Authority_Recruit]           = "招收成員",
	[Kin.Def.Authority_KickOut]           = "開除成員",
	[Kin.Def.Authority_EditRecuitInfo]    = "修改幫派宣言",
	[Kin.Def.Authority_Promotion]         = "小弟轉正",
	[Kin.Def.Authority_Retire]            = "強制退隱",
	[Kin.Def.Authority_Building]          = "建築升級",
	[Kin.Def.Authority_ChatForbid]        = "幫派禁言",
	[Kin.Def.Authority_Mail]              = "發送幫派信件",
	[Kin.Def.Authority_EditKinTitle]      = "修改職位稱謂",
	[Kin.Def.Authority_EditPubilcDeclare] = "修改幫派公告",
	[Kin.Def.Authority_ChangeCamp]        = "修改幫派陣營";
};


Kin.Def.ChangeCampFound =
{
	[1] = 20000;
	[2] = 40000;
	[3] = 60000;
}

local function Array2Map( ... )
	local params = {...};
	local map = {};
	for _, key in pairs(params) do
		map[key] = true;
	end
	return map;
end

Kin.Def.Career_Authority = {
	[Kin.Def.Career_Master]     = Array2Map(1, 2, 3, 4, 5, 7, 8, 9, 10, 11, 12, 14, 15, 16, 17, 19, 20);
	[Kin.Def.Career_ViceMaster] = Array2Map(1, 3, 4, 5, 14, 15, 17);
	[Kin.Def.Career_Elder]      = Array2Map(1, 5, 17, 15, 14);
	[Kin.Def.Career_Normal]     = Array2Map();
	[Kin.Def.Career_New]        = Array2Map();
	[Kin.Def.Career_Elite]      = Array2Map();
	[Kin.Def.Career_Retire]     = Array2Map();
	[Kin.Def.Career_Leader]     = Array2Map(1);
	[Kin.Def.Career_Mascot]     = Array2Map();
};

Kin.Def.Career_Name = {
	[Kin.Def.Career_Master]     = "堂主";
	[Kin.Def.Career_ViceMaster] = "副堂主";
	[Kin.Def.Career_Elder]      = "會長";
	[Kin.Def.Career_Normal]     = "成員";
	[Kin.Def.Career_New]        = "小弟";
	[Kin.Def.Career_Elite]      = "組長";
	[Kin.Def.Career_Retire]     = "退隱";
	[Kin.Def.Career_Mascot]     = "吉祥物";
	[Kin.Def.Career_Leader]		= "總堂主";
};

-- 各职位对应的奖励加成倍率
Kin.Def.CareerRewardAdditionRate = {
	[Kin.Def.Career_Master]     = 0;
	[Kin.Def.Career_ViceMaster] = 0;
	[Kin.Def.Career_Elder]      = 0;
	[Kin.Def.Career_Normal]     = 0;
	[Kin.Def.Career_New]        = 0;
	[Kin.Def.Career_Elite]      = 0;
	[Kin.Def.Career_Retire]     = 0;
	[Kin.Def.Career_Mascot]     = 0;
	[Kin.Def.Career_Leader]		= 0;
};

Kin.Def.Career2Authority = {
	[Kin.Def.Career_Master]     = Kin.Def.Authority_GrantMaster,
	[Kin.Def.Career_ViceMaster] = Kin.Def.Authority_GrantViceMaster,
	[Kin.Def.Career_Elder]      = Kin.Def.Authority_GrantOlder,
	[Kin.Def.Career_Normal]     = Kin.Def.Authority_Recruit,
	[Kin.Def.Career_Elite]      = Kin.Def.Authority_Recruit,
	[Kin.Def.Career_Mascot]     = Kin.Def.Authority_Recruit,
};

-------------------------家族建设-------------------------------

Kin.Def.Building_Main         = 1;
Kin.Def.Building_Totem        = 2;
Kin.Def.Building_Auction      = 3;
Kin.Def.Building_Treasure     = 4;
Kin.Def.Building_DrugStore    = 5;
Kin.Def.Building_FangJuHouse  = 6;	--防具坊
Kin.Def.Building_WeaponStore  = 7;	--兵甲坊
Kin.Def.Building_ShouShiHouse = 8;	--首饰坊
Kin.Def.Building_War          = 9;

Kin.Def.BuildingName = {
	[Kin.Def.Building_Main]         = "主殿",
	[Kin.Def.Building_Totem]        = "圖騰",
	[Kin.Def.Building_Auction]      = "拍賣行",
	[Kin.Def.Building_Treasure]     = "金庫",
	[Kin.Def.Building_DrugStore]    = "珍寶坊",
	[Kin.Def.Building_WeaponStore]  = "兵甲坊",
	[Kin.Def.Building_War]          = "戰爭坊",
	[Kin.Def.Building_FangJuHouse]	= "防具坊",
	[Kin.Def.Building_ShouShiHouse]	= "首飾坊",
};

Kin.Def.BuildingCanUpdate = {
	[Kin.Def.Building_Main]         = true;
	[Kin.Def.Building_War]          = true;
	[Kin.Def.Building_DrugStore]    = true;
	[Kin.Def.Building_WeaponStore]  = true;
	[Kin.Def.Building_Treasure]     = true;
	[Kin.Def.Building_FangJuHouse]	= true;
	[Kin.Def.Building_ShouShiHouse]	= true;
}

--时间轴开放建筑折扣
Kin.Def.BuildingDiscountRate = {
	[1] = 1;  --相差等级，升级费率
	[2] = 0.8;
	[3] = 0.7;
	[4] = 0.6;
	[5] = 0.5;
	[6] = 0.4;
	[7] = 0.3;
	[8] = 0.3;
	[9] = 0.3;
	[10] = 0.3;
};

-- 家族礼包等级对应的随机礼包ItemId
Kin.Def.GiftBoxItemIdByLevel = {
	[1] = 1226;
	[2] = 1227;
	[3] = 4687;
	[4] = 4687;
	[5] = 4687;
	[6] = 4687;
	[7] = 4687;
	[8] = 4687;
	[9] = 4687;
	[10] = 4687;
};

-- 捐献记录保存数
Kin.Def.nDonationMaxRecordCount = 13;

Kin.Def.nRedBagMaxCount = 100	-- 红包数量上限
Kin.Def.nRedBagListMaxCount = 80	--红包列表上限
Kin.Def.nRedBagReceiverShowCount = 50	--红包领取列表显示上限
Kin.Def.nRedBagActiveDelta = 60*5
Kin.Def.nRedbagExpireTime = 24*3600
Kin.Def.tbRedBagNextCheckTimes = {}

-- 建筑开启限制
Kin.Def.BuildingOpenLimit = {
	[Kin.Def.Building_Main]         = 1,
	[Kin.Def.Building_Totem]        = 1,
	[Kin.Def.Building_War]          = 4,
	[Kin.Def.Building_DrugStore]    = 1,
	[Kin.Def.Building_WeaponStore]  = 2,
	[Kin.Def.Building_Auction]      = 1,
	[Kin.Def.Building_Treasure]     = 1,
	[Kin.Def.Building_FangJuHouse]	= 2,
	[Kin.Def.Building_ShouShiHouse]	= 2,
};

Kin.RobDef = {
	FailLostFound = {2000, 4000}; -- 失败失去的建筑资金范围
	RewardItemId = 1005; -- 击杀robber获得的道具.
	FirstKillContrib = 100; --首次击杀盗贼的贡献度
	MaxRewardPerDay = 4; -- 每日最多获得奖励次数
	KillRobberContribution = 50; -- 击杀盗贼获得的贡献度
	KillAllRobberPrestige = {20, 10, 10, 10}; --击杀盗贼威望
	ActivityTime = 30 * 60; -- 持续时间
};

Kin.NestDef = {
	tbClueRewards = {	--家族盗贼线索奖励
		[0] = {	--线索数
			{"Item", 1363, 1},
		},
		[1] = {
			{"Item", 1363, 1},
		},
		[2] = {
			{"Item", 1363, 2},
		},
		[3] = {
			{"Item", 1363, 3},
		},
	};
};

Kin.MonsterNianDef = {
	nFireworkPickId = 2173,	--烟花ID（采集）
	nFireworkPickTime = 2,	--烟花采集时间(秒)
	nFireworkRefreshInterval = 15,	--烟花刷新时间（秒）
	
	szFireworkUseAtlas = "UI/Atlas/Home/HomeScreenAtlas.prefab ",	--烟花快速使用图片atlas
	szFireworkUseSprite = "Fireworks",	--烟花快速使用图片sprite

	nFireworkId = 3688,	--烟花ID（道具）
	nFireworkSkillIds = {3507, 3509, 3511},	--使用烟花释放的技能ID
	nMaxFireworkSkillDist = 400, --使用烟花最大距离
	nFireworkCD = 5,	--使用烟花CD（秒）
	nFireworksCountMult = 2.0,	--每次刷新个数 = 属地内人数*nFireworksCountMult
	nFireworkMaxInBag = 3,	--背包中存放烟花的最大个数
	tbFireworksPos = {	--烟花坐标
			{3072,7598},
			{3057,6701},
			{2157,6766},
			{3280,6861},
			{2377,6493},
			{2089,7259},
			{2006,7022},
			{2454,6935},
			{2920,7022},
			{2897,6526},
			{2879,7319},
			{2478,7310},
			{2262,7365},
			{2581,7583},
			{2215,7069},
			{2847,7560},
			{3128,7374},
			{2815,6726},
			{2445,6699},
			{3155,7102},
			{2898,7731},
			{2667,6971},
			{2643,6708},
			{2661,6475},
			{2256,6617},
			{2726,7681},
			{2250,6892},
			{2782,6874},
			{2499,7119},
			{2670,7374},
			{3037,6880},
			{3001,7223},
			{2714,7167},
	},

	nMonsterId = 2172,	--年兽ID
	tbMonsterPos = {2597, 7243},	--年兽坐标
	szMapMonsterIndex = "MonsterNianPos",	--小地图上显示的年兽text pos Index

	nMaxHpRewardsPerDay = 10,	--每人每天最多采集宝箱个数
	nMonsterHpPercentRewardId = 2185,	--年兽血量百分比刷宝箱ID
	tbMonsterHpPercentRewards = {	--年兽多少血量百分比刷宝箱
		70, 40, 0,
	},

	tbGatherBoxPos = {	--宝箱坐标
			{2376,7467},
			{2941,6743},
			{3061,7470},
			{2267,6741},
			{2297,7260},
			{2914,7475},
			{2880,6879},
			{3111,7265},
			{2414,6626},
			{2565,6589},
			{2358,6855},
			{2185,6985},
			{2299,7121},
			{2528,6810},
			{2555,7366},
			{2504,7571},
			{2424,7193},
			{2568,7020},
			{2688,6804},
			{2794,6621},
			{3026,7020},
			{3170,6940},
			{2810,7041},
			{2784,7257},
			{2786,7436},
			{2757,7563},
			{2986,7364},
			{3127,6834},
			{3250,7084},
			{3210,7300},
	},

	nValuePerMember = 100000,	--奖励价值=家族参加人数*100000

	tbAuctionSettings = {
		[3709] = {1/2, 1350000},	-- 物品id, 占比, 价值
		[3714] = {1/2, 500000},
	},

	nMinJoinLevel = 20,	--最小参加等级
	nClearGatherBoxDelay = 60,	--活动结束后，等待清理宝箱的时间（秒）
}

Kin.GatherDef = {
	PrepareTime = 3 * 60;
	ActivityTime = 10 * 60;

	MaxExtraExpBuff = 200;  --篝火经验的最大奖励倍数
	MaxExtraMemberExpBuff = 150; -- 篝火人数最大奖励倍数
	DrinkCost = 60; -- 喝酒价格，单位Gold
	DrinkReward = {{"Contrib", 300}};  --喝酒后的奖励
	DrinkExpBuff = 5;  --喝酒后经验加成
	FireNpcPosX = 5066;
	FireNpcPosY = 4252;
	FireNpcTemplateId = 516;  --篝火ID

	DiceTimeOut = 50;
	DicePriceTime = 60;
	DiceOpenAnswerCount = 2; --2题对有机会摇骰子
	DicePricePercent = 1 / 5; -- 参与答题的获奖比例.
	WeekendDicePriceExtraPercent = 0.2; -- 活动时参与答题的额外获奖比例.

	DicePriceMail = {
		To = nil; -- 手动填
		Title = "幫派骰子獎勵";
		Text = "恭喜少俠在幫派烤火活動中獲得骰子排名獎勵，請查收附件獎勵。";
		From = "幫派系統";
		tbAttach = {
			{"item", 1307, 1},
		};
	};

	FirstQuestionTime = 2 * 60;
	QuestionAnwserTime = 74;  --答题时间
	NextQuestionTime = 1;
	QuizCount = 4; -- 每轮题目数..

	AutoSendRedBagTime	= 5;	--家族烤火开始后多久自动发放红包
	AutoSendRedBagInterval = 30;	--自动发放过期红包的时间间隔

	AnswerWrongRewardContrib = 60; --答错奖励
	AnswerRightRewardContrib = 90; --答对奖励
	AnswerRightRewardItem = {"item", 3103, 1}; -- 答对时获得的item
	WeekendExtraAnswerRate = 1; -- 活动时的额外奖励倍率

	GatherJoinContribution = 10; -- 聚集参与获得个人贡献值
	KinPrestigeReward = {15, 20, 25, 25, 30, 30, 35, 35, 40, 40, 50, 50, 60}; -- 每五个一组
	KinMaxPrestigeReward = 60; -- 每次家族聚集家族获得的最大威望

	CurQuestionIdx = "nCurQuestionIdx";
	MemberNum      = "nMemberNum";
	Quotiety       = "nQuotiety";
	LastTime       = "nLastTime";
	QuestionData   = "tbQuestionData";
	QuestionOver   = "bQuestionOver";
	DrinkFlag      = "bDrink";
};

-- 家族任务增加威望
Kin.Task2Prestige = {
	[1] = 15,
	[51] = 5,
	[101] = 5,
	[151] = 5,
	[201] = 5,
	[251] = 5,
	[301] = 10,
	[351] = 10,
};

Kin.Def.nRedBagMaxGrabPerDay = 50 --个人抢红包每日次数上限
Kin.Def.nRedBagPlayerGrabGrp = 97
Kin.Def.nRedBagPlayerGrabCount = 1
Kin.Def.nRedBagPlayerLastGrabTime = 2

Kin.tbRedBagEvents = {
	charge_count = 1,	-- 充值次数-
	vip_level = 2,	-- vip等级-
	wsd_rank = 3,	-- 武神殿排名-
	all_strength = 4,	-- 全身强化-
	all_insert = 5,	-- 全身镶嵌-
	title = 6,	-- 头衔-
	newbie_king = 7,	-- 门派新人王-
	big_brother = 8,	-- 门派大师兄
	white_tiger_boss = 9,	-- 白虎堂x层首领-
	battle_rank = 10,	-- 战场排名-
	battle_rank_cross = 34,	--跨服战场排名
	battle_hundred = 37,	--百人战场排名
	battle_monthly = 45,	--月度战场排名
	leader_rank = 11,	-- 盟主排名-
	tower_floor = 12,	-- 通天塔层数-
	tower_floor_monthly = 60,	--月度通天塔层数
	first_master = 13,	--第一家族族长
	top10_master = 14,	--十大家族族长
	good_master = 15,	--卓越家族族长
	first_leader = 16,	--第一家族领袖
	top10_leader = 17,	--十大家族领袖
	good_leader = 18,	--卓越家族领袖
	buy_weekly_gift = 30,	--购买7日礼包
	buy_weekly_suit = 61,	--购买每日礼包7日套包
	buy_monthly_gift = 31,	--购买30日礼包
	buy_invest_1 = 32,	--购买一本万利(20级)
	buy_invest_2 = 33,	--购买一本万利(65级)
	buy_invest_3 = 35,	--购买一本万利(90级)
	buy_invest_4 = 38,	--购买一本万利（新年）
	buy_invest_5 = 43,	--购买一本万利（100级）
	buy_invest_6 = 44,	--购买一本万利（五阶）
	in_differ_battle = 36,	--心魔幻境红包
	new_year_gift_1 = 42,	--新年礼包(30)
	new_year_gift_2 = 41,	--新年礼包(98)
	new_year_gift_3 = 40,	--新年礼包(298)
	new_year_gift_4 = 39,	--新年礼包(648)
	qyh_win = 46,	--群英会连胜
	oneyear1 = 48,	--周年庆缘起礼包（648）
	oneyear2 = 49,	--周年庆情韵礼包（298）
	oneyear3 = 50,	--周年庆侠踪礼包（98）
	oneyear4 = 51,	--周年庆剑影礼包（30）
	beauty_hx_1 = 52,		--美女评选海选赛第一
	beauty_g_hx_1 = 56,		--美女评选海选赛第一（全服红包）
	beauty_hx_10 = 53,		--美女评选海选赛前十
	beauty_hx_vote = 54,	--美女评选海选赛获投199
	beauty_final_1 = 55,	--美女评选决赛第一
	beauty_g_final_1 = 58,	--美女评选决赛第一（全服红包）
	beauty_final_10 = 59,	--美女评选决赛前十
	beauty_g_final_10 = 57,	--美女评选决赛前十（全服红包）
	beauty_final_vote = 62,	--美女评选决赛获投8000
	beauty_g_final_vote = 63,--美女评选决赛获投8000（全服红包）
	wldh_top1 = 65, 	--武林大会冠军
	wldh_top4 = 66, 	--武林大会四强
	wldh_top16 = 67,	--武林大会十六强
	wldh_elite = 68,	--武林大会精英
	wldh_g_top1 = 69,	--武林大会冠军（全服红包）
	wldh_g_top4 = 70,	--武林大会四强（全服红包）
	summer_gift_1 = 71,	--盛夏礼包（648）
	summer_gift_2 = 72,	--盛夏礼包（298）
	summer_gift_3 = 73,	--盛夏礼包（98）
	summer_gift_4 = 74,	--盛夏礼包（30）
	travel_seller_1 = 75,--行脚商拍卖竞价超1000元宝
	travel_seller_2 = 76,--行脚商拍卖竞价超2000元宝
	travel_seller_3 = 77,--行脚商拍卖竞价超5000元宝
	travel_seller_4 = 78,--行脚商拍卖竞价超10000元宝
	travel_seller_5 = 79,--行脚商拍卖竞价超20000元宝
	travel_seller_6 = 80,--行脚商拍卖竞价超50000元宝
	travel_seller_7 = 81,--行脚商拍卖竞价超100000元宝
	travel_seller_8 = 82,--行脚商拍卖竞价超120000元宝
	travel_seller_9 = 83,--行脚商拍卖竞价超150000元宝
	travel_seller_10 = 84,--行脚商拍卖竞价超180000元宝
	travel_seller_11 = 85,--行脚商拍卖竞价超200000元宝
	wedding_1 = 90,	--举办庄园·晚樱连理婚礼
	wedding_2 = 91,	--举办海岛·红鸾揽月婚礼
	wedding_3 = 92,	--举办舫舟·乘龙配凤婚礼
}

Kin.tbRedBagBattleTypes = {
	BattleKill = Kin.tbRedBagEvents.battle_rank,
	BattleDota = Kin.tbRedBagEvents.battle_rank,
	BattleCross = Kin.tbRedBagEvents.battle_rank_cross,
	BattleHundred = Kin.tbRedBagEvents.battle_hundred,
	BattleMonth = Kin.tbRedBagEvents.battle_monthly,
}

-- 职位对应的工资加成
Kin.tbActivityCareerSalary = {
	[Kin.Def.Career_Master] = 6,
	[Kin.Def.Career_ViceMaster] = 3,
	[Kin.Def.Career_Elder] = 2,
	[Kin.Def.Career_Mascot] = 2,
}

-- 见习成员等级限制时间轴
Kin.tbCareerNewTimeFrames = {
	["OpenLevel49"] ={35, 40},
	["OpenLevel59"] ={45, 50},
	["OpenLevel69"] ={55, 60},
	["OpenLevel79"] ={65, 70},
	["OpenLevel89"] ={75, 80},
	["OpenLevel99"] ={85, 90},
	["OpenLevel109"] ={95, 100},
	["OpenLevel119"] ={105, 110},
	["OpenLevel129"] ={115, 120},
}

--职位对应的分红比例
Kin.Def.tbCareerProfitRate = {
	[Kin.Def.Career_Master] = 0.4,
	[Kin.Def.Career_ViceMaster] = 0.2,
	[Kin.Def.Career_Elder] = 0.1,
	[Kin.Def.Career_Mascot] = 0.05,
}

-- 充值总额（元宝）对应分红比例
Kin.Def.tbProfitRate = {
	{300010, 0.01},
	{200010, 0.02},	--min, rate
	{100010, 0.04},
	{0, 0.06},
}

--家族创建满x小时才发放工资
Kin.Def.nSalaryCreateMinHours = 24

--任职满x小时才有工资
Kin.Def.nSalaryCareerMinHours = 24

--家族职位工资对应红包配置
Kin.Def.tbSalaryRedBagCfgs = {
	[Kin.Def.Career_Master] = {
		{10000, 46},	--最小元宝数, 红包EventId
		{5000, 47},
		{2500, 48},
		{1000, 49},
	},
	[Kin.Def.Career_ViceMaster] = {
		{5000, 50},
		{2500, 51},
		{1250, 52},
		{500, 53},
	},
	[Kin.Def.Career_Elder] = {
		{2500, 54},
		{1250, 55},
		{625, 56},
	},
}

--不需要加到家族累计贡献中的logReason
Kin.Def.tbExcludeAddContribLogReasons = {
	[Env.LogWay_ShopSell] = true,
}

--vip对应红包倍数上限,默认为1倍
Kin.Def.tbVipRedBagMaxMulti = {
	{2, 2},	-- vip, 最大倍数
	{4, 3},
	{7, 6},
}

--禁止使用的职位称谓
Kin.Def.tbForbiddenTitleNames = {

}

--称号对应的红包事件
Kin.Def.tbTitle2RedBagEvent = {
	[4000] = Kin.tbRedBagEvents.first_master,
    [4005] = Kin.tbRedBagEvents.top10_master,
    [4010] = Kin.tbRedBagEvents.good_master,
    [4015] = Kin.tbRedBagEvents.first_leader,
    [4016] = Kin.tbRedBagEvents.top10_leader,
    [4017] = Kin.tbRedBagEvents.good_leader,
}

--家族改名道具ID
Kin.Def.nChangeNameItem = 2640

--家族宝贝功能开关
Kin.Def.bMascotClosed = false

--充值对应活跃度比例,1元宝=x活跃 (家族工资)
Kin.Def.nCharge2Activity = 0.7

--充值转换活跃的对多元宝数
Kin.Def.nMaxChargeActiveGolds = 10000

--家族职位排序顺序
Kin.Def.tbCareersOrder = {
	[Kin.Def.Career_Leader] = 1,
	[Kin.Def.Career_Master] = 2,
	[Kin.Def.Career_ViceMaster] = 3,
	[Kin.Def.Career_Elder] = 4,
	[Kin.Def.Career_Mascot] = 5,
	[Kin.Def.Career_Elite] = 6,
	[Kin.Def.Career_Normal] = 7,
	[Kin.Def.Career_New] = 8,
	[Kin.Def.Career_Retire] = 9,
}

--给家族管理层推送邮件的最小时间间隔（2周一次）
Kin.Def.nPushMailCD = 13*24*3600+23*3600

--加入家族冷却时间
Kin.Def.tbJoinCD = {
	nDefault = 1*3600,		--默认
	nKickedOut = 1*3600,	--被踢出
}