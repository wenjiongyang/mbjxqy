 Require("CommonScript/SdkDef.lua");

Recharge.IS_OPEN = true;
Recharge.IS_OPEN_INVEST = true;--是否开启一本万利
Recharge.IS_OPEN_BUY_ENHANCE = true;--是否开启强化直够
Recharge.IS_OPEN_BUY_DRESS = true;--是否开启购买外装货币


Recharge.SAVE_GROUP 	= 20;
Recharge.KEY_TOTAL_ONLY_GOLD = 1; -- 买金币的累积充值金额，实际总额要加上KEY_TOTAL_CARD --有异步数据进行同步
Recharge.KEY_TOTAL_ONLY_GOLD2 = 57; --超过21亿部分的 买金币的累积充值金额
Recharge.TOTAL_RECHARGE_LARGE = 2^31;

Recharge.KEY_VIP_AWARD  = 3; --玩家已购买哪个档次的礼包，用标识位，从0开始
Recharge.KEY_BUYED_FLAG = 4; -- 玩家已买过的哪个档次的充值，首冲奖励用

Recharge.tbKeyGrowBuyed = {5, 23, 31, 38, 50,59, 65} --一本万利是否购买了
Recharge.tbKeyGrowTaked = {6, 24, 32, 39, 51,60, 66} -- 拿了几档的一本万利奖励 用bit位存
Recharge.KEY_INVEST_ACT_TAKEDAY = 48;
Recharge.KEY_INVEST_BACK_TAKEDAY = 72;


Recharge.KEY_TAKE_MON	= 8; --领取月卡福利的天数
Recharge.KEY_TAKE_WEEK	= 9; --领取周卡福利的天数

Recharge.KEY_TOTAL_CARD = 10; --卡类的充值总额

Recharge.KEY_GET_FIRST_RECHARGE = 12; --是否获得了首冲礼包

Recharge.KEY_VIP_AWARD_EX  = 18; --后面对vip的内容又改了所以换了标识 --在一个月后就不检查这个的不同了
Recharge.KEY_BUYED_FLAG_TIME = 19;--上次购买哪个档次的充值的时间，用于活动重置每挡的首冲用

--累计充值
Recharge.KEY_ACT_SUM_R = 25
Recharge.KEY_ACT_SUM_SET_TIME_R = 26
Recharge.KEY_ACT_SUM_TAKE_R = 27
--累计消耗
Recharge.KEY_ACT_SUM_C = 28
Recharge.KEY_ACT_SUM_SET_TIME_C = 29
Recharge.KEY_ACT_SUM_TAKE_C = 30

Recharge.KEY_ACT_CONTINUAL_DATA_DAY = 33 --连续充值相关存储
Recharge.KEY_ACT_CONTINUAL_DAYS = 34
Recharge.KEY_ACT_CONTINUAL_FLAG = 35
Recharge.KEY_ACT_CONTINUAL_RECHARGE = 36
Recharge.KEY_ACT_CONTINUAL_SESSION_TIME = 37

Recharge.KEY_ONE_DAY_CARD_PLUS_COUNT = 62 --剩余的可领取一键礼包次数
Recharge.KEY_ONE_DAY_CARD_PLUS_DAY = 63 --领取一键礼包的天数，每天只能领取一次

Recharge.KEY_ACT_NEWYEARGIFT_RESET = 58 --新年大礼包的活动开启时间，区分版本清除玩家是否已经购买
Recharge.KEY_ACT_INVEST_RESET = 64 --新年一本万利的活动开启时间，区分版本清除玩家是否已经购买

Recharge.RATE 			= 0.1; --1分 与元宝的兑换比例是10：1

Recharge.tbMoneyRMBRate = { --不同币种 分 * rate = 对应RMB 分，决定vip经验，运营后不能改变
	["RMB"] = 1,
	["VND"] = 3, --越南币元 对应 0.01分
	["HKD"] = 0.76, --港币分 对应 1分
	["TWD"] = 0.2, --台币
	["USD"] = 6.8, --美元
	["THB"] = 0.25, --泰铢
}
--第三个参数是 界面上显示的字符格式
Recharge.tbMoneyName = {
	["RMB"] = {"元", "¥", "%d", 0.01}, --第四个值是存盘值 与显示值（界面） 的转换比率
	["VND"] = {"越南幣", "VND", "%d", 100},
	["HKD"] = {"港幣","HKD", "%d", 0.01},
	["TWD"] = {"新臺幣", "TWD", "%d", 0.01},
	["USD"] = {"美元", "$", "%.2f", 0.01},
	["THB"] = {"泰銖", "THB", "%d", 0.01},
}

--第三方支付的货币分 与元宝的兑换比例
Recharge.tbMoneyThirdRate = {
	["RMB"] = 0.1,
	["TWD"] = 0.022,
	["HKD"] = 0.022 * 3.8,
	["USD"] = 0.022 * 34,
	["VND"] = 0.4, --这里是100越南盾对应的元宝数
	["THB"] = 0.025,
}

--泰国不同第三方充值渠道对应不同的元宝兑换比率
Recharge.tbMoneyThirdRatePlatform = {
	["PlatformPay"] = 1;
	["PlatformPay_B2"] = 1;
	["PlatformPay_D1"] = 1;
	["PlatformPay_E1"] = 1;
	["PlatformPay_I1"] = 1;
	["PlatformPay_I2"] = 1;
	["PlatformPay_L3"] = 1;
	["PlatformPay_N1"] = 1;
	["PlatformPay_N2"] = 1;
	["PlatformPay_P1"] = 1;
	["PlatformPay_S1"] = 1;
	["PlatformPay_T1"] = 1;
	["PlatformPay_T2"] = 1;
	["PlatformPay_U1"] = 1;
	["PlatformPay_W"] = 1;
};

if version_xm then
	Recharge.tbMoneyThirdRate["USD"] = 0.77 --只是已购买项重复买时 1：70 再乘额外的1.1
end


Recharge.THIRD_GET_GOLD_RATE = 1.1; --新马版的根据传过来的元宝数对应实际赠送元宝数倍率


Recharge.tbDaysCardBuyLimitDay = {
	3, 5,  --周卡剩余天数《=3才可重新购买，  --月卡剩余天数《=5才可重新购买
}

Recharge.nFirstAwardItem = 1240--首冲奖励

Recharge.MAX_COMPENSATION = 6 -- 晚进服补偿
Recharge.tbCompensationAward = {
	{"Item", 1458, 1},
	{"Item", 1459, 1},
	{"Item", 1460, 1},
	{"Item", 1461, 1},
	{"Item", 1462, 1},
	{"Item", 2275, 1},
}

Recharge.fActivityCardAwardParam = 100; --周月卡的奖励百分比

Recharge.SaveGroupActiviy   = 14;
Recharge.SaveKeyActiviyMon  = 7;
Recharge.SaveKeyActiviyWeek = 8;

--月卡，每天领取奖励
Recharge.tbMonAward = {
	{ {{"Gold", 150   }}, "OpenLevel39"}; --时间轴从低到高
	{ {{"Gold", 160   }}, "OpenLevel79"};
	{ {{"Gold", 170   }}, "OpenLevel89"};
	{ {{"Gold", 180   }}, "OpenLevel99"};
	{ {{"Gold", 190   }}, "OpenLevel109"};
	{ {{"Gold", 200   }}, "OpenLevel119"};
}

--周卡，每天领取奖励
Recharge.tbWeekAward = {
    { {{"Gold", 180   }}, "OpenLevel39"};
    { {{"Gold", 200   }}, "OpenLevel79"};
	{ {{"Gold", 220   }}, "OpenLevel89"};
	{ {{"Gold", 240   }}, "OpenLevel99"};
	{ {{"Gold", 260   }}, "OpenLevel109"};
	{ {{"Gold", 280   }}, "OpenLevel119"};
}

if version_hk or version_tw then
	--周卡，每天领取奖励
	Recharge.tbWeekAward = {
		{ {{"Gold", 200   }}, "OpenLevel39"};
	}
elseif version_vn then
	Recharge.tbMonAward = {
		{ {{"Gold", 180   }}, "OpenLevel39"};
	}
end

--活动一本万利配置
Recharge.tbGrowInvestActSetting = {
	szNameInPanel = "金秋專屬";
	szTextureInPanel = "UI/Textures/GrowInvest_Summer.png";
	szBuyTimeLimit = "時限：2017年9月30日~10月7日"
};
if version_xm then
	Recharge.tbGrowInvestActSetting.szNameInPanel = "周年慶專屬";
	Recharge.tbGrowInvestActSetting.szBuyTimeLimit = "時限：2017年10月18日-10月31日"
end

-- 活动充值礼包配置
Recharge.tbNewYearBuyGiftActSetting = {
	szNameInPanel = "聖誕大禮包";
	szPanelLine1  = "聖誕祝福從天降";
	szPanelLine2  = "情緣相伴送豪禮";
	szTextureInPanel = "UI/Textures/NewYearBag.png";
};

---活动充值礼包的配置项
Recharge.tbNewYearBuySetting =
{
	{ nBuyCount = 5, nCanBuyDay = 0,  nSaveCountKey = 49 }; 
	{ nBuyCount = 1, nCanBuyDay = 0, }; --活动开启后一天才可购买
	{ nBuyCount = 1, nCanBuyDay = 0, };
	{ nBuyCount = 1, nCanBuyDay = 0, }; 
}

--领取这些vip礼包的时间key，方便后期奖励调整时进行补偿
Recharge.tbVipAwardTakeTimeKey = {
	[14] = 20, --V14 --saveKey
	[15] = 21,
	[16] = 22,
}

Recharge.tbDirectEnhanceSetting = { --强化直升道具购买的配置
	{OpenTimeFrame = "OpenLevel59", nPlayerLevel = 20; nEnhanceLevel = 20; };
	{OpenTimeFrame = "OpenLevel69", nPlayerLevel = 30; nEnhanceLevel = 30; };
	{OpenTimeFrame = "OpenLevel79", nPlayerLevel = 40; nEnhanceLevel = 40; };
};




--一本万利的推送等级
Recharge.tbProptGrowInvestLevel = {
 	{ 60, 50, 40 },
 	{ 85, 75 },
 	{ 96, 90},
 	{ 999, 999}, --新年的是不推送的
 	{ 106, 100},
 	{ 116, 110},
}



--- VIP的设置 ,以分为单位
Recharge.tbVipSetting = {
	--累积充值人民币数
	600,				--V1
	3000,				--V2
	6000,				--V3
	15000,				--V4
	30000,				--V5
	60000,				--V6
	90000,				--V7
	150000,				--V8
	300000,				--V9
	600000,				--V10
	900000,				--V11
	1500000,			--V12
	3000000,			--V13
	6000000,			--V14
	9000000,			--V15
	12000000,			--V16
	16000000,			--V17
	20000000,			--V18
}

Recharge.tbVipTimeFrameSetting =
{
	[15] = "OpenLevel69"; --OpenLevel69才开放VIP15
	[16] = "OpenLevel69"; --OpenLevel69才开放VIP16
	[17] = "OpenLevel89";
	[18] = "OpenLevel89";
}

Recharge.nMaxVip = #Recharge.tbVipSetting

Recharge.VIP_SHOW_LEVEL = { --vip特效标识显示
	[1] = "V_Blue_",
	[2] = "V_Blue_",
	[3] = "V_Blue_",
	[4] = "V_Blue_",
	[5] = "V_Blue_",

	[6] = "V_Purple_",
	[7] = "V_Purple_",
	[8] = "V_Purple_",

	[9] = "V_Pink_",
	[10] = "V_Pink_",
	[11] = "V_Pink_",

	[12] = "V_Orange_",
	[13] = "V_Orange_",
	[14] = "V_Orange_",
	[15] = "V_Orange_",
	[16] = "V_Golden_",
	[17] = "V_Golden_",
	[18] = "V_Golden_",
}

assert( #Recharge.VIP_SHOW_LEVEL == #Recharge.tbVipSetting)

--vip特权礼包 ,不能超过32档
Recharge.tbVipAward = {
	--从vip 0 开始
	{
		nShowPrice  = 200,
		nRealPrice  = 8,
		nGiveItemId = 1317, --实际给的道具id
	},

	--VIP1
	{
		nShowPrice  = 400,
		nRealPrice  = 18,
		nGiveItemId = 1318,
	},

	--VIP2
	{
		nShowPrice  = 480,
		nRealPrice  = 28,
		nGiveItemId = 1319,
	},

	--VIP3
	{
		nShowPrice  = 650,
		nRealPrice  = 48,
		nGiveItemId = 1320,
	},

	--VIP4
	{
		nShowPrice  = 1600,
		nRealPrice  = 98,
		nGiveItemId = 1321,
	},

	--VIP5
	{
		nShowPrice  = 1550,
		nRealPrice  = 118,
		nGiveItemId = 1322,
	},

	--VIP6
	{
		nShowPrice  = 1675,
		nRealPrice  = 148,
		nGiveItemId = 1323,
	},

	--VIP7
	{
		nShowPrice  = 2650,
		nRealPrice  = 278,
		nGiveItemId = 1324,
	},

	--VIP8
	{
		nShowPrice  = 6000,
		nRealPrice  = 648,
		nGiveItemId = 1325,
	},

	--VIP9
	{
		nShowPrice  = 7600,
		nRealPrice  = 848,
		nGiveItemId = 1326,
	},

	--VIP10
	{
		nShowPrice  = 7850,
		nRealPrice  = 948,
		nGiveItemId = 1327,
	},

	--VIP11
	{
		nShowPrice  = 7650,
		nRealPrice  = 1048,
		nGiveItemId = 1328,
	},

	--VIP12
	{
		nShowPrice  = 8450,
		nRealPrice  = 1148,
		nGiveItemId = 1329,
	},

	--VIP13
	{
		nShowPrice  = 9400,
		nRealPrice  = 1288,
		nGiveItemId = 1330,
	},

	--VIP14
	{
		nShowPrice  = 14400,
		nRealPrice  = 2388,
		nGiveItemId = 1331,
	},

	--VIP15
	{
		nShowPrice  = 16400,
		nRealPrice  = 2988,
		nGiveItemId = 1332,
	},

	--VIP16
	{
		nShowPrice  = 18500,
		nRealPrice  = 3688,
		nGiveItemId = 1333,
	},

	--VIP17
	{
		nShowPrice  = 24000,
		nRealPrice  = 4688,
		nGiveItemId = 3076,
	},

	--VIP18
	{
		nShowPrice  = 29800,
		nRealPrice  = 5888,
		nGiveItemId = 3077,
	},
}

--VIP的特权设置参数, 具体调用自定义吧
Recharge.tbVipExtSetting = {
	["ExFriendNum"] = {{4, 50}, {18, 50} }, --额外的好友上限, 是累计的

	["public_chat"] = { 6, 15 }, --VIP6 以后公聊间隔变15s

	["ChuangGongLevelMinus"] = { --传功等级差要求
		--vip 等级， 等级差要求
		{0, 	3},
		{9, 	2},
		{15, 	1},
	},

	--vip等级对应家族捐献获得贡献加成
	KinDonateContributeInc = {
		{14, 0.2},	-- vip >= 14,加成20%
	},

	--亲密度提升速度+20%
	AddImity = { 11, 1.2 };

	TeacherStudentConnectLvDiff = {	--师徒拜师收徒最小等级差
		{0, 5},	-- vip>=0, LvDiff=5
		{6, 4},
		{9, 3},
		{12, 2},
	},

	KinGiftBoxInc = {	--vip等级增加家族礼盒数量
		{7, 1},	-- vip>=7, 增加1个（绝对值）
	},
}

--上面的固定描述
Recharge.tbVipDescFix = {
	--VIP0
[[
]],

--VIP1
[[

]],

--VIP2
[[

]],

--VIP3
[[

]],

--VIP4
[[

]],

--VIP5
[[

]],

--VIP6
[[

]],

--VIP7
[[

]],

--VIP8
[[

]],

--VIP9
[[

]],

--VIP10
[[

]],

--VIP11
[[

]],

--VIP12
[[

]],

--VIP13
[[

]],

--VIP14
[[

]],

--VIP15
[[

]],

--VIP16
[[

]],

--VIP17
[[

]],

--VIP18
[[

]],
}

--特权说明, 从0 级开始
Recharge.tbVipDesc = {
--VIP0
[[
●  每天幫派捐獻次數：　　[fefb1a]  10[-]次
●  每天世界頻道發言次數：[fefb1a]  10[-]次
●  每天寶藏探索次數：　　[fefb1a]  10[-]次
]],

--VIP1
[[
●  每天[fefb1a]1[-]元超值禮包購買資格
●  每天傳功次數：             [fefb1a]    1→2[-]次
●  每天幫派捐獻次數：　　[fefb1a]  10→20[-]次
●  每天世界頻道發言次數：[fefb1a]  10→20[-]次
●  每天寶藏探索次數：　　     [fefb1a]    10[-]次
]],

--VIP2
[[
●  每天武神殿購買次數：[fefb1a]  0→5[-]次
●  每天商會協助次數： [fefb1a]10→20[-]次
●  每天[fefb1a]1[-]元超值禮包購買資格
●  每天傳功次數:                [fefb1a] 2[-]次
●  每天幫派捐獻次數：　　[fefb1a]  20[-]次
●  每天世界頻道發言次數：[fefb1a]  20[-]次
●  每天寶藏探索次數：　　[fefb1a]  10[-]次
]],

--VIP3
[[
●  每天幫派捐獻次數：[fefb1a] 20→25[-]次
●  每天武神殿購買次數：　[fefb1a]    5[-]次
●  每天商會協助次數：  　[fefb1a]   20[-]次
●  每天[fefb1a]1/3[-]元超值禮包購買資格
●  每天傳功次數:               [fefb1a]   2[-]次
●  每天世界頻道發言次數：[fefb1a]  20[-]次
●  每天寶藏探索次數：　　[fefb1a]  10[-]次
]],

--VIP4
[[
●  好友數量上限額外增加：[fefb1a]  50[-]人
●  每天武神殿購買次數：　[fefb1a]    5[-]次
●  每天商會協助次數：  　[fefb1a]   20[-]次
●  每天[fefb1a]1/3[-]元超值禮包購買資格
●  每天傳功次數:                [fefb1a]  2[-]次
●  每天幫派捐獻次數：　　[fefb1a]  25[-]次
●  每天世界頻道發言次數：[fefb1a]  20[-]次
●  每天寶藏探索次數：　　[fefb1a]  10[-]次
]],

--VIP5
[[
●  獲得舉辦[fefb1a]莊園[-]婚禮的特權
●  每天商會任務求助次數：[fefb1a]3→4[-]次
●  好友數量上限額外增加：  [fefb1a] 50[-]人
●  每天武神殿購買次數：　[fefb1a]    5[-]次
●  每天商會協助次數：  　[fefb1a]   20[-]次
●  每天[fefb1a]1/3/6[-]元超值禮包購買資格
●  每天傳功次數:                [fefb1a]  2[-]次
●  每天幫派捐獻次數：　　[fefb1a]  25[-]次
●  每天世界頻道發言次數：[fefb1a]  20[-]次
●  每天寶藏探索次數：　　[fefb1a]  10[-]次
]],

--VIP6
[[
●  可使用特效白駒丸獲得[fefb1a]2.5[-]倍離線經驗
●  可拜師/收徒的最低等級差：[fefb1a] 5→4[-]級
●  世界頻道發言間隔：    [fefb1a]   30→15[-]秒
●  每天武神殿購買次數：　[fefb1a]   5→10[-]次
●  每天幫派捐獻次數：　　[fefb1a] 25→50[-]次
●  擁有舉辦[fefb1a]莊園[-]婚禮的特權
●  每天商會任務求助次數：[fefb1a]           4[-]次
●  好友數量上限額外增加：[fefb1a]         50[-]人
●  每天商會協助次數：  　[fefb1a]          20[-]次
●  每天[fefb1a]1/3/6[-]元超值禮包購買資格
●  每天傳功次數:                       [fefb1a]  2[-]次
●  每天世界頻道發言次數：[fefb1a]        20[-]次
●  每天寶藏探索次數：　　[fefb1a]        10[-]次
]],

--VIP7
[[
●  幫派禮盒每日兌換次數：[fefb1a]   4→5[-]次
●  每天寶藏探索次數：[fefb1a]     10→15[-]次
●  擁有舉辦[fefb1a]莊園[-]婚禮的特權
●  可拜師/收徒的最低等級差：[fefb1a]    4[-]級
●  可使用特效白駒丸獲得[fefb1a]2.5[-]倍離線經驗
●  世界頻道發言間隔：    [fefb1a]        15[-]秒
●  每天商會任務求助次數：[fefb1a]        4[-]次
●  好友數量上限額外增加：[fefb1a]      50[-]人
●  每天武神殿購買次數：　[fefb1a]      10[-]次
●  每天商會協助次數：  　[fefb1a]       20[-]次
●  每天[fefb1a]1/3/6[-]元超值禮包購買資格
●  每天傳功次數:                [fefb1a]      2[-]次
●  每天幫派捐獻次數：　　[fefb1a]      50[-]次
●  每天世界頻道發言次數：[fefb1a]      20[-]次
]],

--VIP8
[[
●  每天傳功/被傳功次數:       [fefb1a] 2→3[-]次
●  離線託管獲得經驗：[fefb1a]100%→110%[-]
●  擁有舉辦[fefb1a]莊園[-]婚禮的特權
●  幫派禮盒每日兌換次數：[fefb1a]         5[-]次
●  可拜師/收徒的最低等級差：[fefb1a]     4[-]級
●  可使用特效白駒丸獲得[fefb1a]2.5[-]倍離線經驗
●  世界頻道發言間隔：    [fefb1a]        15[-]秒
●  每天商會任務求助次數：[fefb1a]        4[-]次
●  好友數量上限額外增加：[fefb1a]       50[-]人
●  每天武神殿購買次數：　[fefb1a]      10[-]次
●  每天商會協助次數：  　[fefb1a]       20[-]次
●  每天[fefb1a]1/3/6[-]元超值禮包購買資格
●  每天幫派捐獻次數：　　[fefb1a]      50[-]次
●  每天世界頻道發言次數：[fefb1a]      20[-]次
●  每天寶藏探索次數：　　[fefb1a]      15[-]次
]],

--VIP9
[[
●  獲得舉辦[fefb1a]海島[-]婚禮的特權
●  可傳功/被傳功最低等級差：[fefb1a] 3→2[-]級
●  可拜師/收徒的最低等級差：[fefb1a] 4→3[-]級
●  每天幫派捐獻次數：[fefb1a]     50→200[-]次
●  擁有舉辦[fefb1a]莊園[-]婚禮的特權
●  每天傳功/被傳功次數:        [fefb1a]      3[-]次
●  離線託管獲得經驗：      [fefb1a]      110%[-]
●  幫派禮盒每日兌換次數：[fefb1a]          5[-]次
●  可使用特效白駒丸獲得[fefb1a]2.5[-]倍離線經驗
●  世界頻道發言間隔：    [fefb1a]          15[-]秒
●  每天商會任務求助次數：[fefb1a]          4[-]次
●  好友數量上限額外增加：[fefb1a]        50[-]人
●  每天武神殿購買次數：　[fefb1a]        10[-]次
●  每天商會協助次數：  　[fefb1a]         20[-]次
●  每天[fefb1a]1/3/6[-]元超值禮包購買資格
●  每天世界頻道發言次數：[fefb1a]        20[-]次
●  每天寶藏探索次數：　　[fefb1a]        15[-]次
]],
--VIP10
[[
●  每天武神殿購買次數：  [fefb1a]10→15[-]次
●  擺攤顯示商品數量增加[fefb1a]50%[-]
●  搖錢樹獲得銀兩增加[fefb1a]20%[-]
●  擁有舉辦[fefb1a]莊園、海島[-]婚禮的特權
●  可傳功/被傳功最低等級差：    [fefb1a]2[-]級
●  每天傳功/被傳功次數:            [fefb1a]3[-]次
●  離線託管獲得經驗：          [fefb1a]110%[-]
●  幫派禮盒每日兌換次數：     [fefb1a]   5[-]次
●  可拜師/收徒的最低等級差：    [fefb1a]3[-]級
●  可使用特效白駒丸獲得[fefb1a]2.5[-]倍離線經驗
●  世界頻道發言間隔：            [fefb1a]15[-]秒
●  每天商會任務求助次數：      [fefb1a]  4[-]次
●  好友數量上限額外增加：      [fefb1a]50[-]人
●  每天商會協助次數：       　[fefb1a]  20[-]次
●  每天[fefb1a]1/3/6[-]元超值禮包購買資格
●  每天幫派捐獻次數：          [fefb1a]200[-]次
●  每天世界頻道發言次數：    [fefb1a]  20[-]次
●  每天寶藏探索次數：　　    [fefb1a]  15[-]次
]],

--VIP11
[[
●  好友親密度提升速度增加[fefb1a]20%[-]
●  擺攤顯示商品數量增加[fefb1a]50%[-]
●  搖錢樹獲得銀兩增加[fefb1a]20%[-]
●  擁有舉辦[fefb1a]莊園、海島[-]婚禮的特權
●  可傳功/被傳功最低等級差：   [fefb1a]2[-]級
●  每天傳功/被傳功次數:           [fefb1a]3[-]次
●  離線託管獲得經驗：         [fefb1a]110%[-]
●  幫派禮盒每日兌換次數：    [fefb1a]   5[-]次
●  可拜師/收徒的最低等級差：   [fefb1a]3[-]級
●  可使用特效白駒丸獲得[fefb1a]2.5[-]倍離線經驗
●  世界頻道發言間隔：           [fefb1a]15[-]秒
●  每天商會任務求助次數：     [fefb1a]  4[-]次
●  好友數量上限額外增加:       [fefb1a]50[-]人
●  每天武神殿購買次數：　   [fefb1a]  15[-]次
●  每天商會協助次數：      　[fefb1a]  20[-]次
●  每天[fefb1a]1/3/6[-]元超值禮包購買資格
●  每天幫派捐獻次數：      [fefb1a]   200[-]次
●  每天世界頻道發言次數：   [fefb1a]  20[-]次
●  每天寶藏探索次數：　   　[fefb1a]  15[-]次
]],

--VIP12
[[
●  獲得舉辦[fefb1a]舫舟[-]婚禮的特權
●  離線託管獲得經驗：[fefb1a]110%→120%[-]
●  每天幫派捐獻次數：[fefb1a]  200→500[-]次
●  可拜師/收徒的最低等級差：[fefb1a]3→2[-]級
●  擁有舉辦[fefb1a]莊園、海島[-]婚禮的特權
●  好友親密度提升速度增加[fefb1a]20%[-]
●  擺攤顯示商品數量增加[fefb1a]50%[-]
●  搖錢樹獲得銀兩增加[fefb1a]20%[-]
●  可傳功/被傳功最低等級差：     [fefb1a]2[-]級
●  每天傳功/被傳功次數:             [fefb1a]3[-]次
●  幫派禮盒每日兌換次數：      [fefb1a]   5[-]次
●  可使用特效白駒丸獲得[fefb1a]2.5[-]倍離線經驗
●  世界頻道發言間隔：             [fefb1a]15[-]秒
●  每天商會任務求助次數：       [fefb1a]  4[-]次
●  好友數量上限額外增加:         [fefb1a]50[-]人
●  每天武神殿購買次數：     　[fefb1a]  15[-]次
●  每天商會協助次數：        　[fefb1a]  20[-]次
●  每天[fefb1a]1/3/6[-]元超值禮包購買資格
●  每天世界頻道發言次數：     [fefb1a]  20[-]次
●  每天寶藏探索次數：　     　[fefb1a]  15[-]次
]],

--VIP13
[[
●  每天武神殿購買次數：[fefb1a]15→20[-]次
●  擁有舉辦[fefb1a]莊園、海島、舫舟[-]婚禮的特權
●  同伴經驗藥水經驗增加[fefb1a]20%[-]
●  好友親密度提升速度增加[fefb1a]20%[-]
●  擺攤顯示商品數量增加[fefb1a]50%[-]
●  搖錢樹獲得銀兩增加[fefb1a]20%[-]
●  可傳功/被傳功最低等級差：  [fefb1a]2[-]級
●  每天傳功/被傳功次數:          [fefb1a]3[-]次
●  離線託管獲得經驗：        [fefb1a]120%[-]
●  可拜師/收徒的最低等級差：  [fefb1a]2[-]級
●  幫派禮盒每日兌換次數：   [fefb1a]   5[-]次
●  可使用特效白駒丸獲得[fefb1a]2.5[-]倍離線經驗
●  世界頻道發言間隔：          [fefb1a]15[-]秒
●  每天商會任務求助次數：    [fefb1a]  4[-]次
●  好友數量上限額外增加:      [fefb1a]50[-]人
●  每天商會協助次數：    　 [fefb1a]  20[-]次
●  每天[fefb1a]1/3/6[-]元超值禮包購買資格
●  每天幫派捐獻次數：       [fefb1a] 500[-]次
●  每天世界頻道發言次數：  [fefb1a]  20[-]次
●  每天寶藏探索次數：　　  [fefb1a]  15[-]次
]],

--VIP14
[[
●  每天修煉丹使用次數：  [fefb1a]1→2[-]次
●  擁有舉辦[fefb1a]莊園、海島、舫舟[-]婚禮的特權
●  同伴經驗藥水經驗增加[fefb1a]20%[-]
●  好友親密度提升速度增加[fefb1a]20%[-]
●  擺攤顯示商品數量增加[fefb1a]50%[-]
●  可傳功/被傳功最低等級差：[fefb1a]2[-]級
●  每天傳功/被傳功次數:        [fefb1a]3[-]次
●  離線託管獲得經驗：      [fefb1a]120%[-]
●  可拜師/收徒的最低等級差：[fefb1a]2[-]級
●  搖錢樹獲得銀兩增加[fefb1a]20%[-]
●  幫派禮盒每日兌換次數：[fefb1a]    5[-]次
●  可使用特效白駒丸獲得[fefb1a]2.5[-]倍離線經驗
●  世界頻道發言間隔：        [fefb1a]15[-]秒
●  每天商會任務求助次數：[fefb1a]    4[-]次
●  好友數量上限額外增加:    [fefb1a]50[-]人
●  每天武神殿購買次數：　[fefb1a]  20[-]次
●  每天商會協助次數：   　[fefb1a]  20[-]次
●  每天[fefb1a]1/3/6[-]元超值禮包購買資格
●  每天幫派捐獻次數：     [fefb1a] 500[-]次
●  每天世界頻道發言次數：[fefb1a]  20[-]次
●  每天寶藏探索次數：　　[fefb1a]  15[-]次
]],

--VIP15
[[
●  可傳功/被傳功最低等級差：[fefb1a]2→1[-]級
●  擁有舉辦[fefb1a]莊園、海島、舫舟[-]婚禮的特權
●  每天修煉丹使用次數：            [fefb1a]2[-]次
●  同伴經驗藥水經驗增加[fefb1a]20%[-]
●  好友親密度提升速度增加[fefb1a]20%[-]
●  擺攤顯示商品數量增加[fefb1a]50%[-]
●  每天傳功/被傳功次數:             [fefb1a]3[-]次
●  離線託管獲得經驗：           [fefb1a]120%[-]
●  可拜師/收徒的最低等級差：     [fefb1a]2[-]級
●  搖錢樹獲得銀兩增加[fefb1a]20%[-]
●  幫派禮盒每日兌換次數：[fefb1a]         5[-]次
●  可使用特效白駒丸獲得[fefb1a]2.5[-]倍離線經驗
●  世界頻道發言間隔：             [fefb1a]15[-]秒
●  每天商會任務求助次數：       [fefb1a]  4[-]次
●  好友數量上限額外增加:         [fefb1a]50[-]人
●  每天武神殿購買次數：     　[fefb1a]  20[-]次
●  每天商會協助次數：        　[fefb1a]  20[-]次
●  每天[fefb1a]1/3/6[-]元超值禮包購買資格
●  每天幫派捐獻次數：          [fefb1a] 500[-]次
●  每天世界頻道發言次數：     [fefb1a]  20[-]次
●  每天寶藏探索次數：　    　 [fefb1a]  15[-]次
]],

--VIP16
[[
●  每天傳功/被傳功次數:        [fefb1a]3→4[-]次
●  離線託管獲得經驗：[fefb1a]120%→130%[-]
●  每天幫派捐獻次數：[fefb1a]500→3000[-]次
●  擁有舉辦[fefb1a]莊園、海島、舫舟[-]婚禮的特權
●  可傳功/被傳功最低等級差：     [fefb1a]1[-]級
●  每天修煉丹使用次數：            [fefb1a]2[-]次
●  同伴經驗藥水經驗增加[fefb1a]20%[-]
●  好友親密度提升速度增加[fefb1a]20%[-]
●  擺攤顯示商品數量增加[fefb1a]50%[-]
●  可拜師/收徒的最低等級差：     [fefb1a]2[-]級
●  搖錢樹獲得銀兩增加[fefb1a]20%[-]
●  幫派禮盒每日兌換次數：      [fefb1a]   5[-]次
●  可使用特效白駒丸獲得[fefb1a]2.5[-]倍離線經驗
●  世界頻道發言間隔：             [fefb1a]15[-]秒
●  每天商會任務求助次數：       [fefb1a]  4[-]次
●  好友數量上限額外增加:         [fefb1a]50[-]人
●  每天武神殿購買次數：     　[fefb1a]  20[-]次
●  每天商會協助次數：        　[fefb1a]  20[-]次
●  每天[fefb1a]1/3/6[-]元超值禮包購買資格
●  每天世界頻道發言次數：     [fefb1a]  20[-]次
●  每天寶藏探索次數：　     　[fefb1a]  15[-]次
]],

--VIP17
[[
●  擺攤顯示商品數量增加[fefb1a]50%→100%[-]
●  擁有舉辦[fefb1a]莊園、海島、舫舟[-]婚禮的特權
●  每天傳功/被傳功次數:           [fefb1a]4[-]次
●  離線託管獲得經驗：          [fefb1a]130%[-]
●  可傳功/被傳功最低等級差：   [fefb1a]1[-]級
●  每天修煉丹使用次數：          [fefb1a]2[-]次
●  同伴經驗藥水經驗增加[fefb1a]20%[-]
●  好友親密度提升速度增加[fefb1a]20%[-]
●  可拜師/收徒的最低等級差：   [fefb1a]2[-]級
●  搖錢樹獲得銀兩增加[fefb1a]20%[-]
●  幫派禮盒每日兌換次數：[fefb1a]       5[-]次
●  可使用特效白駒丸獲得[fefb1a]2.5[-]倍離線經驗
●  世界頻道發言間隔：           [fefb1a]15[-]秒
●  每天商會任務求助次數：     [fefb1a]  4[-]次
●  好友數量上限額外增加:       [fefb1a]50[-]人
●  每天武神殿購買次數：   　[fefb1a]  20[-]次
●  每天商會協助次數：      　[fefb1a]  20[-]次
●  每天[fefb1a]1/3/6[-]元超值禮包購買資格
●  每天幫派捐獻次數：[fefb1a]       3000[-]次
●  每天世界頻道發言次數：[fefb1a]     20[-]次
●  每天寶藏探索次數：　　[fefb1a]     15[-]次
]],

--VIP18
[[
●  擺攤顯示商品數量增加[fefb1a]100%[-]
●  好友數量上限額外增加:  [fefb1a]50→100[-]人
●  擁有舉辦[fefb1a]莊園、海島、舫舟[-]婚禮的特權
●  每天傳功/被傳功次數:              [fefb1a]4[-]次
●  離線託管獲得經驗：             [fefb1a]130%[-]
●  可傳功/被傳功最低等級差：      [fefb1a]1[-]級
●  每天修煉丹使用次數：             [fefb1a]2[-]次
●  同伴經驗藥水經驗增加[fefb1a]20%[-]
●  好友親密度提升速度增加[fefb1a]20%[-]
●  可拜師/收徒的最低等級差：      [fefb1a]2[-]級
●  搖錢樹獲得銀兩增加[fefb1a]20%[-]
●  幫派禮盒每日兌換次數：[fefb1a]          5[-]次
●  可使用特效白駒丸獲得[fefb1a]2.5[-]倍離線經驗
●  世界頻道發言間隔：    [fefb1a]          15[-]秒
●  每天商會任務求助次數：[fefb1a]          4[-]次
●  每天武神殿購買次數：　[fefb1a]        20[-]次
●  每天商會協助次數：  　[fefb1a]         20[-]次
●  每天[fefb1a]1/3/6[-]元超值禮包購買資格
●  每天幫派捐獻次數：[fefb1a]          3000[-]次
●  每天世界頻道發言次數：[fefb1a]        20[-]次
●  每天寶藏探索次數：　　[fefb1a]        15[-]次
]],
}

if version_vn then --越南版vip特权里没有对应的每日礼包
Recharge.tbVipDesc[2] =
--VIP1
[[
●  藍V標識
●  傳功次數每日額外增加[fefb1a]1[-]次
●  每天世界頻道發言次數：[fefb1a]  20[-]次
●  每天寶藏探索次數：　　[fefb1a]  10[-]次
●  每天幫派捐獻次數：　　[fefb1a]  20[-]次
]];

Recharge.tbVipDesc[4] =
--VIP3
[[
●  可發放2倍紅包
●  每天世界頻道發言次數：[fefb1a]  20[-]次
●  每天寶藏探索次數：　　[fefb1a]  10[-]次
●  每天幫派捐獻次數：　　[fefb1a]  25[-]次
●  每天武神殿購買次數：　[fefb1a]    5[-]次
]];

Recharge.tbVipDesc[6] =
--VIP5
[[
●  可發放3倍紅包
●  每天世界頻道發言次數：[fefb1a]  20[-]次
●  每天寶藏探索次數：　　[fefb1a]  10[-]次
●  每天幫派捐獻次數：　　[fefb1a]  25[-]次
●  每天武神殿購買次數：　[fefb1a]    5[-]次
]];
end

Recharge.DAILY_GIFT_TYPE = 
{
	["YUAN_1"] = 1,
	["YUAN_3"] = 2,
	["YUAN_6"] = 3,
	["YUAN_10"] = 4,
}

Recharge.DAYS_CARD_TYPE = 
{
	["DAYS_7"] = 1,
	["DAYS_30"] = 2,
}

Recharge.tbVipPrivilegeDesc = {
	KinDonate = {
		[0]  = "升級尊1每天最多可捐獻20次",
		[1]  = "升級尊3每天最多可捐獻25次",
		[2]  = "升級尊3每天最多可捐獻25次",
		[3]  = "升級尊7每天最多可捐獻50次",
		[4]  = "升級尊7每天最多可捐獻50次",
		[5]  = "升級尊7每天最多可捐獻50次",
		[6]  = "升級尊7每天最多可捐獻50次",
		[7]  = "升級尊9每天最多可捐獻200次",
		[8]  = "升級尊9每天最多可捐獻200次",
		[9]  = "升級尊12每天最多可捐獻500次",
		[10] = "升級尊12每天最多可捐獻500次",
		[11] = "升級尊12每天最多可捐獻500次",
		[12] = "升級尊14捐獻獲得貢獻增加20%",
		[13] = "升級尊14捐獻獲得貢獻增加20%",
		[14] = "升級尊16每天最多可捐獻3000次",
		[15] = "升級尊16每天最多可捐獻3000次",
	},
	MoneyTree = {
		[8] = "升級尊10搖錢樹獲得銀兩增加20%",
		[9] = "升級尊10搖錢樹獲得銀兩增加20%",
	},
	WaiYi = {
		[7] = "升級尊10可贈予好友外裝",
		[8] = "升級尊10可贈予好友外裝",
		[9] = "升級尊10可贈予好友外裝",
	},
	OnHook = {
		[3]  = "升級尊6可使用特效白駒丸託管（離線經驗2.5倍）",
		[4]  = "升級尊6可使用特效白駒丸託管（離線經驗2.5倍）",
		[5]  = "升級尊6可使用特效白駒丸託管（離線經驗2.5倍）",
		[6]  = "升級尊8離線託管經驗增加10%",
		[7]  = "升級尊8離線託管經驗增加10%",
		[9]  = "升級尊12離線託管經驗增加20%",
		[10] = "升級尊12離線託管經驗增加20%",
		[11] = "升級尊12離線託管經驗增加20%",
		[13] = "升級尊16離線託管經驗增加30%",
		[14] = "升級尊16離線託管經驗增加30%",
		[15] = "升級尊16離線託管經驗增加30%",
	},
	FriendImity = {
		[8]  = "升級尊11好友親密度提升速度增加20%",
		[9]  = "升級尊11好友親密度提升速度增加20%",
		[10] = " 升級尊11好友親密度提升速度增加20%",
	},
	KinGift = {
		[4] = "升級尊7每天幫派禮盒兌換次數增加1次",
		[5] = "升級尊7每天幫派禮盒兌換次數增加1次",
		[6] = "升級尊7每天幫派禮盒兌換次數增加1次",
	},
}

function Recharge:OnSumActStart(nStartTime)
	self.nSumActStartTime = nStartTime
end
function Recharge:OnSumActEnd()
	self.nSumActStartTime = nil
end
function Recharge:GetActRechageSumVal(pPlayer)
	if not self.nSumActStartTime then
		return 0
	end
	local nLastRestTime = Recharge:GetActRechageSumTime(pPlayer)
	if nLastRestTime < self.nSumActStartTime then
		return 0
	end
	return pPlayer.GetUserValue(self.SAVE_GROUP, self.KEY_ACT_SUM_R)
end
function Recharge:SetActRechageSumVal(pPlayer, nVal)
	 pPlayer.SetUserValue(self.SAVE_GROUP, self.KEY_ACT_SUM_R, nVal)
end
function Recharge:GetActRechageSumTime(pPlayer)
	return pPlayer.GetUserValue(self.SAVE_GROUP, self.KEY_ACT_SUM_SET_TIME_R)
end
function Recharge:SetActRechageSumTime(pPlayer, nVal)
	 pPlayer.SetUserValue(self.SAVE_GROUP, self.KEY_ACT_SUM_SET_TIME_R, nVal)
end
function Recharge:GetActRechageSumTake(pPlayer)
	return pPlayer.GetUserValue(self.SAVE_GROUP, self.KEY_ACT_SUM_TAKE_R)
end
function Recharge:SetActRechageSumTake(pPlayer, nVal)
	 pPlayer.SetUserValue(self.SAVE_GROUP, self.KEY_ACT_SUM_TAKE_R, nVal)
end

function Recharge:OnConsumeSumActStart(nStartTime)
	self.nConsumeSumStartTime = nStartTime
end
function Recharge:OnConsumeSumActEnd()
	self.nConsumeSumStartTime = nil
end
function Recharge:GetActConsumeSumVal(pPlayer)
	if self.nConsumeSumStartTime <= 0 then
		return 0
	end
	local nLastRestTime = Recharge:GetActConsumeSumTime(pPlayer)
	if nLastRestTime < self.nConsumeSumStartTime then
		return 0
	end
	return pPlayer.GetUserValue(self.SAVE_GROUP, self.KEY_ACT_SUM_C)
end
function Recharge:SetActConsumeSumVal(pPlayer, nVal)
	 pPlayer.SetUserValue(self.SAVE_GROUP, self.KEY_ACT_SUM_C, nVal)
end
function Recharge:GetActConsumeSumTime(pPlayer)
	return pPlayer.GetUserValue(self.SAVE_GROUP, self.KEY_ACT_SUM_SET_TIME_C)
end
function Recharge:SetActConsumeSumTime(pPlayer, nVal)
	 pPlayer.SetUserValue(self.SAVE_GROUP, self.KEY_ACT_SUM_SET_TIME_C, nVal)
end
function Recharge:GetActConsumeSumTake(pPlayer)
	return pPlayer.GetUserValue(self.SAVE_GROUP, self.KEY_ACT_SUM_TAKE_C)
end
function Recharge:SetActConsumeSumTake(pPlayer, nVal)
	 pPlayer.SetUserValue(self.SAVE_GROUP, self.KEY_ACT_SUM_TAKE_C, nVal)
end

--连续充值活动
function Recharge:SetActContinualData(pPlayer, nKey, nValue)
	if nKey < self.KEY_ACT_CONTINUAL_DATA_DAY or nKey > self.KEY_ACT_CONTINUAL_SESSION_TIME then
		return
	end
	pPlayer.SetUserValue(self.SAVE_GROUP, nKey, nValue)
end
function Recharge:GetActContinualData(pPlayer, nKey)
	return pPlayer.GetUserValue(self.SAVE_GROUP, nKey)
end

function Recharge:CheckVersion(tbInfo)
	if (tbInfo.version_tx == 1 and version_tx) or
		(tbInfo.version_vn == 1 and version_vn) or
		(tbInfo.version_hk == 1 and version_hk) or
		(tbInfo.version_hk == 1 and version_tw) or
		(tbInfo.version_xm == 1 and version_xm) or
		(tbInfo.version_en == 1 and version_en) or
		(tbInfo.version_kor == 1 and version_kor) or
		(tbInfo.version_th == 1 and version_th) then
		return true;
	end

	return false;
end

--这里面是分为单位， val是充值sdk里显示的名字
function Recharge:Init()
	local tbSettingGroup = {};
	local tbProductionSettingAll = {}
	local tbFile = LoadTabFile("Setting/Recharge/Recharge.tab", "sssddsdssssssdsddssss", nil,
			{"ProductId", "szDesc", "szServiceCode", "nLastingDay", "nMoney", "szMoneyType", "nNeedVipLevel","szAward", "szFirstAward","szThirdAward", "szFourthAward",	"szFifthAward", "szGroup","nGroupIndex", "szVersion","nEndTimeKey","nBuyDayKey", "szSprite", "szFirstDesc","szNoromalDesc","Plat"});
	local fnCheck;
	if MODULE_GAMESERVER and (version_hk or version_tw) then
		fnCheck = function (v)
			return(v.szVersion == "version_hk" or v.szVersion == "version_tw")
		end
	else
		fnCheck = function (v)
			if not _G[v.szVersion] then
				return
			end
			if MODULE_GAMECLIENT  and not Lib:IsEmptyStr(v.Plat) then
				if not _G[v.Plat] then
					return
				end
			end
			return true;
		end
	end

	for i,v in ipairs(tbFile) do
		if fnCheck(v) then
			if v.szAward ~= "" then
				v.tbAward = Lib:GetAwardFromString(v.szAward)
			end
			if v.szFirstAward  ~= "" then
				v.tbFirstAward = Lib:GetAwardFromString(v.szFirstAward)
			end
			if v.szThirdAward ~= "" then
				v.tbThirdAward = Lib:GetAwardFromString(v.szThirdAward)
			end
			if v.szFourthAward ~= "" then
				v.szFourthAward = Lib:GetAwardFromString(v.szFourthAward)
			end
			if v.szFifthAward ~= "" then
				v.tbFifthAward = Lib:GetAwardFromString(v.szFifthAward)
			end
			tbProductionSettingAll[v.ProductId] = v
			if v.szGroup ~= "" then
				tbSettingGroup[v.szGroup] = tbSettingGroup[v.szGroup] or {};
				tbSettingGroup[v.szGroup][v.nGroupIndex] = v;
			end
		end
	end

	local tbGrowInvestGroup = {}
	local tbFile = LoadTabFile("Setting/Recharge/GrowInvest.tab", "dddddddddddd", nil,
			{"nGroup", "nIndex",	"nLevel",	"nAwardGold",	"nDay",	"version_tx",	"version_vn",	"version_hk",	"version_xm",	"version_en",	"version_kor",	"version_th"});
	for i,v in ipairs(tbFile) do
		if self:CheckVersion(v) then
			tbGrowInvestGroup[v.nGroup] = tbGrowInvestGroup[v.nGroup] or {};
			local tbData = { nLevel = v.nLevel, nAwardGold = v.nAwardGold }
			if v.nDay ~= 0 then
				tbData.nDay = v.nDay
			end
			tbGrowInvestGroup[v.nGroup][v.nIndex] =  tbData
		end
	end

	Recharge.tbGrowInvestGroup = tbGrowInvestGroup

	self.tbProductionSettingAll = tbProductionSettingAll
	self.tbSettingGroup = tbSettingGroup

	--todo 一个版本的vip经验以对应的货币标准为准
	self.szDefMoneyType = self.tbSettingGroup.BuyGold[1].szMoneyType;
	if version_kor then
		if MODULE_GAMESERVER then
			assert(self.szDefMoneyType == "KRW"); --韩国的ios和安卓客户端使用了不同的货币， 但是服务端统一用krw,存盘值也是KRW
		end
		self.szDefMoneyType = "KRW";
	end
	if not version_tx  then
		local nRate = self.tbMoneyRMBRate[self.szDefMoneyType]
		for i,v in ipairs(Recharge.tbVipSetting) do
			if version_kor then
				Recharge.tbVipSetting[i] = v / nRate
			else
				Recharge.tbVipSetting[i] = math.ceil(v / nRate)
			end
			
		end
	end

end
Recharge:Init()



function Recharge:GetDaysCardLeftDay(pPlayer, nIndex)
	if not self.tbSettingGroup.DaysCard then
		return 0;
	end
	local tbBuyInfo = self.tbSettingGroup.DaysCard[nIndex]
	return Lib:GetLocalDay(pPlayer.GetUserValue(self.SAVE_GROUP, tbBuyInfo.nEndTimeKey) - 3600 * 4) - Lib:GetLocalDay(GetTime() - 3600 * 4)
end

function Recharge:GetDaysCardLeftTime(pPlayer, nIndex)
	if not self.tbSettingGroup.DaysCard then
		return 0;
	end
	local tbBuyInfo = self.tbSettingGroup.DaysCard[nIndex]
	return pPlayer.GetUserValue(self.SAVE_GROUP, tbBuyInfo.nEndTimeKey) - GetTime()
end

function Recharge:GetDaysCardEndTime(pPlayer, nIndex)
	if not self.tbSettingGroup.DaysCard then
		return 0;
	end
	local tbBuyInfo = self.tbSettingGroup.DaysCard[nIndex]
	return pPlayer.GetUserValue(self.SAVE_GROUP, tbBuyInfo.nEndTimeKey);
end

function Recharge:GetTotoalRecharge(pPlayer)
	return self:GetTotoalRechargeGold(pPlayer) + pPlayer.GetUserValue(self.SAVE_GROUP, self.KEY_TOTAL_CARD) ;
end

function Recharge:GetTotoalRechargeGold(pPlayer)
	return self.TOTAL_RECHARGE_LARGE * pPlayer.GetUserValue(self.SAVE_GROUP, self.KEY_TOTAL_ONLY_GOLD2) + pPlayer.GetUserValue(self.SAVE_GROUP, self.KEY_TOTAL_ONLY_GOLD)
end

function Recharge:SetTotoalRechargeGold(pPlayer, nTotal)
	local nHigh = math.floor(nTotal / self.TOTAL_RECHARGE_LARGE) 
	local nLow = nTotal % self.TOTAL_RECHARGE_LARGE
	pPlayer.SetUserValue(self.SAVE_GROUP, self.KEY_TOTAL_ONLY_GOLD2, nHigh)
	pPlayer.SetUserValue(self.SAVE_GROUP, self.KEY_TOTAL_ONLY_GOLD, nLow)
end

function Recharge:OnCardActStart(tbData)
	self.tbCardActData = tbData
end
function Recharge:OnCardActEnd()
	self.tbCardActData = nil
end
function Recharge:IsOnActvityDay()
	-- if Sdk:IsEfunHKTW() then
		if self.tbCardActData then
			return self.tbCardActData; --todo client no tbCardActData
		end
	-- 	return false
	-- else
		local nWeekDay = Lib:GetLocalWeekDay(GetTime() - 3600 * 4)
		if nWeekDay == 6 or nWeekDay == 7 then
			return {self.fActivityCardAwardParam, self.fActivityCardAwardParam}
		end
		return false
	-- end
end

function Recharge:GetRefreshDay()
	return Lib:GetLocalDay(GetTime() - 3600 *4)
end

function Recharge:CheckBuyGoldGetNum(pPlayer, szProductId)
	local tbBuyInfo = self.tbProductionSettingAll[szProductId]
	if not tbBuyInfo then
		return 0
	end
	local nMoney = tbBuyInfo.nMoney
	local szGroup = tbBuyInfo.szGroup
	if szGroup ==  "BuyGold" then
		local nSellIdx = tbBuyInfo.nGroupIndex
		local nBuyedFlag = Recharge:GetBuyedFlag(pPlayer);
		local nBuydeBit = KLib.GetBit(nBuyedFlag, nSellIdx)
		if nBuydeBit == 1 then
			return self:GetGoldNumFromAward(tbBuyInfo.tbAward)
		else
			return self:GetGoldNumFromAward(tbBuyInfo.tbFirstAward) --每一项首冲双倍
		end
	elseif szGroup == "DaysCard" then
		return self:GetGoldNumFromAward(tbBuyInfo.tbAward)
	elseif szGroup == "GrowInvest" then
		local tbInfo = self.tbGrowInvestGroup[tbBuyInfo.nGroupIndex][1]
		return tbInfo.nAwardGold
	elseif szGroup == "DayGift" then
		return self:GetGoldNumFromAward(tbBuyInfo.tbAward)
	end
	return 0
end

function Recharge:GetGoldNumFromAward(tbAward)
	if not tbAward then
		return 0
	end
	local nGetGold = 0
	if type(tbAward[1]) ~= "table" then
		if tbAward[1] == "Gold" then
			nGetGold = tbAward[2]
		end 
		return nGetGold
	end
	
	for _,v2 in ipairs(tbAward) do
		if v2[1] == "Gold" then
			nGetGold = nGetGold + v2[2]
		end
	end
	return nGetGold
end



function Recharge:CanBuyProduct(pPlayer, szProductId)
	local tbBuyInfo = Recharge.tbProductionSettingAll[szProductId]
	if not tbBuyInfo then
		return
	end
	local szGroup = tbBuyInfo.szGroup
	local bRet,szMsg = true;
	if szGroup == "DaysCard" then
		if not self:CanBuyDaysCard(pPlayer, tbBuyInfo.nGroupIndex) then
			return
		end
	elseif szGroup == "GrowInvest" then
		if not self:CanBuyGrowInvest(pPlayer,tbBuyInfo.nGroupIndex) then
			return
		end
	elseif szGroup == "DayGift" then
		bRet,szMsg = self:CanBuyOneDayCard(pPlayer, szProductId)
	elseif szGroup == "DayGiftSet" then
		bRet,szMsg = self:CanBuyOneDayCardSet(pPlayer)
	elseif szGroup == "YearGift" then
		bRet,szMsg = self:CanBuyYearGift(pPlayer, szProductId)
	elseif szGroup == "DirectEnhance" then
		bRet,szMsg = self:CanBuyDirectEnhance(pPlayer, szProductId)
	elseif szGroup == "DayGiftPlus" then
		bRet,szMsg = self:CanBuyOneDayCardPlus(pPlayer, szProductId)
	elseif szGroup == "DressMoney" then
		bRet, szMsg = self:CanBuyDressMoney()
	end
	if szMsg then
		pPlayer.CenterMsg(szMsg,true)
	end
	return bRet
end

function Recharge:CanBuyYearGift(pPlayer, szProductId)
	local tbBuyInfo = Recharge.tbProductionSettingAll[szProductId]
	if not tbBuyInfo then
		return
	end

	if not Activity:__IsActInProcessByType("RechargeNewYearBuyGift") then
		return false, "不在活動時間內不可購買"
	end
	if pPlayer.GetVipLevel() < tbBuyInfo.nNeedVipLevel then
        return false, string.format("達到劍俠尊享%d後可購買", tbBuyInfo.nNeedVipLevel)
    end

	local tbLimitInfo = self.tbNewYearBuySetting[tbBuyInfo.nGroupIndex]
	if tbLimitInfo.nSaveCountKey and  tbLimitInfo.nBuyCount > 1 then
		if pPlayer.GetUserValue(Recharge.SAVE_GROUP, tbLimitInfo.nSaveCountKey) >= tbLimitInfo.nBuyCount then
			return false, string.format("最多購買%d次", tbLimitInfo.nBuyCount)
		else
			if pPlayer.GetUserValue(Recharge.SAVE_GROUP, tbBuyInfo.nBuyDayKey) == Recharge:GetRefreshDay() then
				return false, "今天已經買過了"
			end
		end
	else
		if pPlayer.GetUserValue(Recharge.SAVE_GROUP, tbBuyInfo.nBuyDayKey) > 0 then
			return false, "最多購買一次"
		end
	end

	local szAwardKey;
	--有的购买项对应时间轴没有的
	if MODULE_GAMESERVER then
		szAwardKey = self.szYearGiftAwardKey
	else
		local tbUiData, tbActData = Activity:GetActUiSetting("RechargeNewYearBuyGift")
		szAwardKey = tbUiData and tbUiData.szAwardKey
	end

	if not szAwardKey then
		return false, "活動已結束"
	end
	local tbInfo = tbBuyInfo[szAwardKey]
	if not tbInfo then
		return false, "未開放對應獎勵"
	end

	return true
end

function Recharge:CanBuyDirectEnhance(pPlayer, szProductId)
	if not self.IS_OPEN_BUY_ENHANCE then
		return false, "當前暫時關閉購買"
	end
	local tbBuyInfo = Recharge.tbProductionSettingAll[szProductId]
	if not tbBuyInfo then
		return 
	end
	if pPlayer.GetUserValue(self.SAVE_GROUP, tbBuyInfo.nEndTimeKey) ~= 0 then
		return false, "當前已經購買"
	end
	local tbLimitSetting = self.tbDirectEnhanceSetting[tbBuyInfo.nGroupIndex]
	if not tbLimitSetting then
		return 
	end
	if GetTimeFrameState(tbLimitSetting.OpenTimeFrame) ~= 1 then
		return 
	end
	if pPlayer.nLevel < tbLimitSetting.nPlayerLevel then
		return false, "等級不夠"
	end
	local nMoreCount = 0;
	local tbStrengthen 	= pPlayer.GetStrengthen();
	for nEquipPos = 1,10 do
		local nStrenLevel 	= tbStrengthen[nEquipPos]
		if nStrenLevel >= tbLimitSetting.nEnhanceLevel then
			nMoreCount = nMoreCount + 1;
		end
	end
	if nMoreCount >= 10 then
		return false, string.format("身上沒有強化低於%d級的位置", tbLimitSetting.nEnhanceLevel)
	end
	return true;
end

function Recharge:CanBuyOneDayCard(pPlayer, szProductId)
	local tbBuyInfo = Recharge.tbProductionSettingAll[szProductId]
	if not tbBuyInfo then
		return
	end

	if pPlayer.GetVipLevel() < tbBuyInfo.nNeedVipLevel then
        return false, string.format("達到劍俠尊享%d後可購買", tbBuyInfo.nNeedVipLevel)
    end
    local nToday = Recharge:GetRefreshDay()
	if pPlayer.GetUserValue(self.SAVE_GROUP, tbBuyInfo.nBuyDayKey) >= nToday then
		return false, "今天已經買過了"
	end
	if self.tbSettingGroup.DayGiftSet then
		local tbBuyInfoSet = self.tbSettingGroup.DayGiftSet[1];
		local nBuySetDay = pPlayer.GetUserValue(self.SAVE_GROUP, tbBuyInfoSet.nBuyDayKey)
		if nBuySetDay >= nToday then
			return false, "已購買組合禮包"
		end
	end
	local bRet,szMsg = self:IsNotTakeOrBuyedOneDayCardPlus(pPlayer)
	if not bRet then
		return bRet,szMsg
	end

	return true
end

function Recharge:IsNotTakeOrBuyedOneDayCardPlus(pPlayer)
	if pPlayer.GetUserValue(self.SAVE_GROUP ,self.KEY_ONE_DAY_CARD_PLUS_COUNT) > 0 then
		return false, "已購買一三六累積禮包"
	end
	if pPlayer.GetUserValue(self.SAVE_GROUP, self.KEY_ONE_DAY_CARD_PLUS_DAY) >= self:GetRefreshDay() then
		return false, "已領取一三六累積禮包"
	end 
	return true
end

function Recharge:CanBuyOneDayCardSet(pPlayer)
	local tbGroup = self.tbSettingGroup.DayGiftSet
	if not tbGroup then
		return false, "無配置", false
	end
	local tbBuyInfo = tbGroup[1]
	if not tbBuyInfo then
		return false, "無配置", false
	end

	if Sdk:IsPCVersion() then
		return false, "PC版不可購買", false
	end

	if pPlayer.GetVipLevel() < tbBuyInfo.nNeedVipLevel then
        return false, string.format("達到劍俠尊享%d後可購買", tbBuyInfo.nNeedVipLevel), true
    end
    local nToday = Recharge:GetRefreshDay()
	if pPlayer.GetUserValue(self.SAVE_GROUP, tbBuyInfo.nBuyDayKey) >= nToday then
		return false, "今天已經買過了", false
	end
	for i,v in ipairs(self.tbSettingGroup.DayGift) do
		if pPlayer.GetUserValue(self.SAVE_GROUP, v.nBuyDayKey) >= nToday then
			return false, "已購買分拆包", false
		end
	end
	local bRet,szMsg = self:IsNotTakeOrBuyedOneDayCardPlus(pPlayer)
	if not bRet then
		return bRet,szMsg, false
	end
	return true, nil, true
end

function Recharge:CanBuyDaysCard(pPlayer, nIndex)
	local tbBuyInfo = self.tbSettingGroup.DaysCard[nIndex]
	if not tbBuyInfo then
		return
	end
	local nLeftDay = self:GetDaysCardLeftDay(pPlayer, nIndex)
	if nLeftDay and nLeftDay - 1 >= self.tbDaysCardBuyLimitDay[nIndex] then
		pPlayer.CenterMsg(string.format("只有%s剩餘時間小於%d天時才能購買新的", tbBuyInfo.szDesc, self.tbDaysCardBuyLimitDay[nIndex]))
		return
	end
	return true;
end

function Recharge:CanBuyGrowInvest(pPlayer, nGroupIndex)
	if nGroupIndex == 4 then
		if not Activity:__IsActInProcessByType("RechargeNewyearGrowInvest") then
			return
		end
	end
	if pPlayer.nLevel < Recharge.tbGrowInvestGroup[nGroupIndex][1].nLevel then
		return
	end
	if pPlayer.GetUserValue(Recharge.SAVE_GROUP, Recharge.tbKeyGrowBuyed[nGroupIndex]) ~= 0 then
		return
	end
	return true
end

function Recharge:CanBuyDressMoney()
	if not Recharge.IS_OPEN_BUY_DRESS then
		return
	end
	if  version_tx then
		if MODULE_GAMECLIENT  then
			if Sdk:IsLoginByGuest() then
				return
			end
		end

	else
		local tbGroup = self.tbSettingGroup.DressMoney
		if not tbGroup then
			return
		end
		if not tbGroup[1] then
			return
		end
	end
	return true
end

function Recharge:GetBuyedFlag(pPlayer)
	return pPlayer.GetUserValue(self.SAVE_GROUP, self.KEY_BUYED_FLAG)
end

function Recharge:ClearBuyedFlag(pPlayer)
	pPlayer.SetUserValue(self.SAVE_GROUP, self.KEY_BUYED_FLAG, 0)
end

function Recharge:GetRechareRMBToGold(nRechareRMB) 
	return math.floor(Recharge.tbMoneyThirdRate[self.szDefMoneyType] * nRechareRMB) 
end

function Recharge:GetActRechareRMBToGold(nRechareRMB) --活动用的充值对应元宝数,不计算额外赠送的
	return math.ceil(Recharge.tbMoneyRMBRate[self.szDefMoneyType] *  nRechareRMB / 10)  --tbMoneyRMBRate对应的是vip经验所以除以10
end

--获取领取天数保存的Key
function Recharge:GetDayInvestTaskedDayKey(nGroupIndex)
	if nGroupIndex == 4 then
		return self.KEY_INVEST_ACT_TAKEDAY
	end
	if nGroupIndex == 7 then
		return self.KEY_INVEST_BACK_TAKEDAY
	end
end

--获取活动一本万利，回归一本万利当前可以领的天数
function Recharge:GetActGrowInvestTakeDay(pPlayer, nGroupIndex)
	local nSaveKey = self:GetDayInvestTaskedDayKey(nGroupIndex)
	if not nSaveKey then
		return 0
	end

	local nTakedDay = pPlayer.GetUserValue(self.SAVE_GROUP, nSaveKey)
	local nRefreshDay = Recharge:GetRefreshDay()
	local nNowMinus = nRefreshDay  - nTakedDay
	if nNowMinus > 0  then --放回第一个可领的
		local nTaked = pPlayer.GetUserValue(Recharge.SAVE_GROUP, Recharge.tbKeyGrowTaked[nGroupIndex])
		local tbSetting = self.tbGrowInvestGroup[nGroupIndex]
		for i, v in ipairs(tbSetting) do
			if KLib.GetBit(nTaked, i) == 0 then
				if i == 1 then
					return i ;
				else
					local nDayMinus = v.nDay - tbSetting[i - 1].nDay
					if nNowMinus >= nDayMinus then
						return i;		
					end
				end
				break;
			end
		end
	end
	return 0;
end


--这是是否可一键领取，还有是否可一键购买
function Recharge:CanTakeOneDayCardPlusAward(pPlayer)
	local nOldCount = pPlayer.GetUserValue(self.SAVE_GROUP, self.KEY_ONE_DAY_CARD_PLUS_COUNT)
	if nOldCount <= 0 then
		return false, "沒有可領取次數"
	end
	local nTakedDay = pPlayer.GetUserValue(self.SAVE_GROUP, self.KEY_ONE_DAY_CARD_PLUS_DAY)
	if self:GetRefreshDay() == nTakedDay then
		return false, "今天已經領取過了，請[FFFE0D]淩晨4點[-]過後再來領取", nOldCount
	end
	return true, nil, nOldCount 
end

function Recharge:CanBuyOneDayCardPlus(pPlayer)
	if not self.tbSettingGroup.DayGiftPlus then
		return false, "無對應購買項", false
	end

	local tbBuyInfo = self.tbSettingGroup.DayGiftPlus[1]
	
	local nOldCount = pPlayer.GetUserValue(self.SAVE_GROUP, self.KEY_ONE_DAY_CARD_PLUS_COUNT)
	if nOldCount > 0 then
		return false, "還有可領取次數", true
	end
	if GetTimeFrameState("OpenLevel49") ~= 1 then --时间轴限制是后面加的，如果还有可领的就不做这个限制了
		return false, "暫未開啟一鍵購買，請俠士在開放49級上限後再嘗試", false
	end
	if pPlayer.GetVipLevel() < tbBuyInfo.nNeedVipLevel then
        return false, string.format("達到劍俠尊享%d後可購買", tbBuyInfo.nNeedVipLevel), true
    end

	--如果当前已经有买每日礼包 或者一键每日礼包的 都不鞥买了
	local nToday = self:GetRefreshDay()
	if self.tbSettingGroup.DayGiftSet then
		local tbBuyInfoSet = self.tbSettingGroup.DayGiftSet[1];
		local nBuySetDay = pPlayer.GetUserValue(self.SAVE_GROUP, tbBuyInfoSet.nBuyDayKey)
		if nBuySetDay >= nToday then
			return false, "已購買組合禮包", true
		end
	end

	for i,v in ipairs(self.tbSettingGroup.DayGift) do
		if pPlayer.GetUserValue(self.SAVE_GROUP, v.nBuyDayKey) >= nToday then
			return false, "已購買過禮包，無法進行一鍵購買，請[FFFE0D]淩晨4點[-]後再嘗試", true
		end
	end

    return true, nil, true;
end

function Recharge:GetMonthCardAward()
	local tbAward = {}
	for i,v in ipairs(Recharge.tbMonAward) do
		if GetTimeFrameState(v[2]) == 1 then
			tbAward = v[1];
		end 
	end
	return tbAward;
end

function Recharge:GetWeekCardAward()
	local tbAward = {}
	for i,v in ipairs(Recharge.tbWeekAward) do
		if GetTimeFrameState(v[2]) == 1 then
			tbAward = v[1];
		end 
	end
	return tbAward;
end