Require("CommonScript/SdkDef.lua")
Recharge.IS_OPEN = true
Recharge.IS_OPEN_INVEST = false
Recharge.IS_OPEN_BUY_ENHANCE = true
Recharge.IS_OPEN_BUY_DRESS = true
Recharge.SAVE_GROUP = 20
Recharge.KEY_TOTAL_ONLY_GOLD = 1
Recharge.KEY_TOTAL_ONLY_GOLD2 = 57
Recharge.TOTAL_RECHARGE_LARGE = 2147483648
Recharge.KEY_VIP_AWARD = 3
Recharge.KEY_BUYED_FLAG = 4
Recharge.tbKeyGrowBuyed = {
  5,
  23,
  31,
  38,
  50,
  59,
  65
}
Recharge.tbKeyGrowTaked = {
  6,
  24,
  32,
  39,
  51,
  60,
  66
}
Recharge.KEY_INVEST_ACT_TAKEDAY = 48
Recharge.KEY_INVEST_BACK_TAKEDAY = 72
Recharge.KEY_TAKE_MON = 8
Recharge.KEY_TAKE_WEEK = 9
Recharge.KEY_TOTAL_CARD = 10
Recharge.KEY_GET_FIRST_RECHARGE = 12
Recharge.KEY_VIP_AWARD_EX = 18
Recharge.KEY_BUYED_FLAG_TIME = 19
Recharge.KEY_ACT_SUM_R = 25
Recharge.KEY_ACT_SUM_SET_TIME_R = 26
Recharge.KEY_ACT_SUM_TAKE_R = 27
Recharge.KEY_ACT_SUM_C = 28
Recharge.KEY_ACT_SUM_SET_TIME_C = 29
Recharge.KEY_ACT_SUM_TAKE_C = 30
Recharge.KEY_ACT_CONTINUAL_DATA_DAY = 33
Recharge.KEY_ACT_CONTINUAL_DAYS = 34
Recharge.KEY_ACT_CONTINUAL_FLAG = 35
Recharge.KEY_ACT_CONTINUAL_RECHARGE = 36
Recharge.KEY_ACT_CONTINUAL_SESSION_TIME = 37
Recharge.KEY_ONE_DAY_CARD_PLUS_COUNT = 62
Recharge.KEY_ONE_DAY_CARD_PLUS_DAY = 63
Recharge.KEY_ACT_NEWYEARGIFT_RESET = 58
Recharge.KEY_ACT_INVEST_RESET = 64
Recharge.RATE = 0.1
Recharge.tbMoneyRMBRate = {
  RMB = 1,
  VND = 3,
  HKD = 0.76,
  TWD = 0.2,
  USD = 6.8,
  THB = 0.25
}
Recharge.tbMoneyName = {
  RMB = {
    "元",
    "¥",
    "%d",
    0.01
  },
  VND = {
    "越南币",
    "VND",
    "%d",
    100
  },
  HKD = {
    "港币",
    "HKD",
    "%d",
    0.01
  },
  TWD = {
    "新台币",
    "TWD",
    "%d",
    0.01
  },
  USD = {
    "美元",
    "$",
    "%.2f",
    0.01
  },
  THB = {
    "泰铢",
    "THB",
    "%d",
    0.01
  }
}
Recharge.tbMoneyThirdRate = {
  RMB = 0.1,
  TWD = 0.022,
  HKD = 0.0836,
  USD = 0.748,
  VND = 0.4,
  THB = 0.025
}
Recharge.tbMoneyThirdRatePlatform = {
  PlatformPay = 1,
  PlatformPay_B2 = 1,
  PlatformPay_D1 = 1,
  PlatformPay_E1 = 1,
  PlatformPay_I1 = 1,
  PlatformPay_I2 = 1,
  PlatformPay_L3 = 1,
  PlatformPay_N1 = 1,
  PlatformPay_N2 = 1,
  PlatformPay_P1 = 1,
  PlatformPay_S1 = 1,
  PlatformPay_T1 = 1,
  PlatformPay_T2 = 1,
  PlatformPay_U1 = 1,
  PlatformPay_W = 1
}
if version_xm then
  Recharge.tbMoneyThirdRate.USD = 0.77
end
Recharge.THIRD_GET_GOLD_RATE = 1.1
Recharge.tbDaysCardBuyLimitDay = {3, 5}
Recharge.nFirstAwardItem = 1240
Recharge.MAX_COMPENSATION = 6
Recharge.tbCompensationAward = {
  {
    "Item",
    1458,
    1
  },
  {
    "Item",
    1459,
    1
  },
  {
    "Item",
    1460,
    1
  },
  {
    "Item",
    1461,
    1
  },
  {
    "Item",
    1462,
    1
  },
  {
    "Item",
    2275,
    1
  }
}
Recharge.fActivityCardAwardParam = 100
Recharge.SaveGroupActiviy = 14
Recharge.SaveKeyActiviyMon = 7
Recharge.SaveKeyActiviyWeek = 8
Recharge.tbMonAward = {
  {
    {
      {"Gold", 150}
    },
    "OpenLevel39"
  },
  {
    {
      {"Gold", 160}
    },
    "OpenLevel79"
  },
  {
    {
      {"Gold", 170}
    },
    "OpenLevel89"
  },
  {
    {
      {"Gold", 180}
    },
    "OpenLevel99"
  },
  {
    {
      {"Gold", 190}
    },
    "OpenLevel109"
  },
  {
    {
      {"Gold", 200}
    },
    "OpenLevel119"
  }
}
Recharge.tbWeekAward = {
  {
    {
      {"Gold", 180}
    },
    "OpenLevel39"
  },
  {
    {
      {"Gold", 200}
    },
    "OpenLevel79"
  },
  {
    {
      {"Gold", 220}
    },
    "OpenLevel89"
  },
  {
    {
      {"Gold", 240}
    },
    "OpenLevel99"
  },
  {
    {
      {"Gold", 260}
    },
    "OpenLevel109"
  },
  {
    {
      {"Gold", 280}
    },
    "OpenLevel119"
  }
}
if version_hk or version_tw then
  Recharge.tbWeekAward = {
    {
      {
        {"Gold", 200}
      },
      "OpenLevel39"
    }
  }
elseif version_vn then
  Recharge.tbMonAward = {
    {
      {
        {"Gold", 180}
      },
      "OpenLevel39"
    }
  }
end
Recharge.tbGrowInvestActSetting = {
  szNameInPanel = "金秋专属",
  szTextureInPanel = "UI/Textures/GrowInvest_Summer.png",
  szBuyTimeLimit = "时限：2017年9月30日~10月7日"
}
if version_xm then
  Recharge.tbGrowInvestActSetting.szNameInPanel = "周年庆专属"
  Recharge.tbGrowInvestActSetting.szBuyTimeLimit = "时限：2017年10月18日-10月31日"
end
Recharge.tbNewYearBuyGiftActSetting = {
  szNameInPanel = "感恩节礼包",
  szPanelLine1 = "感恩节倾情回馈",
  szPanelLine2 = "超值礼包喜相迎",
  szTextureInPanel = "UI/Textures/NewYearBag.png"
}
Recharge.tbNewYearBuySetting = {
  {
    nBuyCount = 5,
    nCanBuyDay = 0,
    nSaveCountKey = 49
  },
  {nBuyCount = 1, nCanBuyDay = 0},
  {nBuyCount = 1, nCanBuyDay = 0},
  {nBuyCount = 1, nCanBuyDay = 0}
}
Recharge.tbVipAwardTakeTimeKey = {
  [14] = 20,
  [15] = 21,
  [16] = 22
}
Recharge.tbDirectEnhanceSetting = {
  {
    OpenTimeFrame = "OpenLevel59",
    nPlayerLevel = 20,
    nEnhanceLevel = 20
  },
  {
    OpenTimeFrame = "OpenLevel69",
    nPlayerLevel = 30,
    nEnhanceLevel = 30
  },
  {
    OpenTimeFrame = "OpenLevel79",
    nPlayerLevel = 40,
    nEnhanceLevel = 40
  }
}
Recharge.tbProptGrowInvestLevel = {
  {
    60,
    50,
    40
  },
  {85, 75},
  {96, 90},
  {999, 999},
  {106, 100},
  {116, 110}
}
Recharge.tbVipSetting = {
  0,
  0,
  0,
  0,
  204000,
  408000,
  612000,
  1020000,
  2040000,
  4080000,
  6120000,
  10200000,
  20400000,
  40800000,
  61200000,
  81600000,
  108800000,
  136000000
}
Recharge.tbVipTimeFrameSetting = {
  [15] = "OpenLevel69",
  [16] = "OpenLevel69",
  [17] = "OpenLevel89",
  [18] = "OpenLevel89"
}
Recharge.nMaxVip = #Recharge.tbVipSetting
Recharge.VIP_SHOW_LEVEL = {
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
  [18] = "V_Golden_"
}
assert(#Recharge.VIP_SHOW_LEVEL == #Recharge.tbVipSetting)
Recharge.tbVipAward = {
  {
    nShowPrice = 200,
    nRealPrice = 8,
    nGiveItemId = 1317
  },
  {
    nShowPrice = 400,
    nRealPrice = 18,
    nGiveItemId = 1318
  },
  {
    nShowPrice = 480,
    nRealPrice = 28,
    nGiveItemId = 1319
  },
  {
    nShowPrice = 650,
    nRealPrice = 48,
    nGiveItemId = 1320
  },
  {
    nShowPrice = 1600,
    nRealPrice = 98,
    nGiveItemId = 1321
  },
  {
    nShowPrice = 1550,
    nRealPrice = 118,
    nGiveItemId = 1322
  },
  {
    nShowPrice = 1675,
    nRealPrice = 148,
    nGiveItemId = 1323
  },
  {
    nShowPrice = 2650,
    nRealPrice = 278,
    nGiveItemId = 1324
  },
  {
    nShowPrice = 6000,
    nRealPrice = 648,
    nGiveItemId = 1325
  },
  {
    nShowPrice = 7600,
    nRealPrice = 848,
    nGiveItemId = 1326
  },
  {
    nShowPrice = 7850,
    nRealPrice = 948,
    nGiveItemId = 1327
  },
  {
    nShowPrice = 7650,
    nRealPrice = 1048,
    nGiveItemId = 1328
  },
  {
    nShowPrice = 8450,
    nRealPrice = 1148,
    nGiveItemId = 1329
  },
  {
    nShowPrice = 9400,
    nRealPrice = 1288,
    nGiveItemId = 1330
  },
  {
    nShowPrice = 14400,
    nRealPrice = 2388,
    nGiveItemId = 1331
  },
  {
    nShowPrice = 16400,
    nRealPrice = 2988,
    nGiveItemId = 1332
  },
  {
    nShowPrice = 18500,
    nRealPrice = 3688,
    nGiveItemId = 1333
  },
  {
    nShowPrice = 24000,
    nRealPrice = 4688,
    nGiveItemId = 3076
  },
  {
    nShowPrice = 29800,
    nRealPrice = 5888,
    nGiveItemId = 3077
  }
}
Recharge.tbVipExtSetting = {
  ExFriendNum = {
    {4, 50},
    {18, 50}
  },
  public_chat = {6, 15},
  ChuangGongLevelMinus = {
    {0, 3},
    {9, 2},
    {15, 1}
  },
  KinDonateContributeInc = {
    {14, 0.2}
  },
  AddImity = {11, 1.2},
  TeacherStudentConnectLvDiff = {
    {0, 5},
    {6, 4},
    {9, 3},
    {12, 2}
  },
  KinGiftBoxInc = {
    {7, 1}
  }
}
Recharge.tbVipDescFix = {
  "",
  "\n",
  "\n",
  "\n",
  "\n",
  "\n",
  "\n",
  "\n",
  "\n",
  "\n",
  "\n",
  "\n",
  "\n",
  "\n",
  "\n",
  "\n",
  "\n",
  "\n",
  "\n"
}
Recharge.tbVipDesc = {
  "●  每天家族捐献次数：　　[fefb1a]  10[-]次\n●  每天世界频道发言次数：[fefb1a]  10[-]次\n●  每天宝藏探索次数：　　[fefb1a]  10[-]次\n",
  "●  每天[fefb1a]0.99[-]美元礼包购买资格\n●  每天传功次数：             [fefb1a]    1→2[-]次\n●  每天家族捐献次数：　　[fefb1a]  10→20[-]次\n●  每天世界频道发言次数：[fefb1a]  10→20[-]次\n●  每天宝藏探索次数：　　     [fefb1a]    10[-]次\n",
  "●  每天武神殿购买次数：[fefb1a]  0→5[-]次\n●  每天商会协助次数： [fefb1a]10→20[-]次\n●  每天[fefb1a]0.99[-]美元礼包购买资格\n●  每天传功次数:                [fefb1a] 2[-]次\n●  每天家族捐献次数：　　[fefb1a]  20[-]次\n●  每天世界频道发言次数：[fefb1a]  20[-]次\n●  每天宝藏探索次数：　　[fefb1a]  10[-]次\n",
  "●  每天家族捐献次数：[fefb1a] 20→25[-]次\n●  每天武神殿购买次数：　[fefb1a]    5[-]次\n●  每天商会协助次数：  　[fefb1a]   20[-]次\n●  每天[fefb1a]0.99/1.99[-]美元礼包购买资格\n●  每天传功次数:               [fefb1a]   2[-]次\n●  每天世界频道发言次数：[fefb1a]  20[-]次\n●  每天宝藏探索次数：　　[fefb1a]  10[-]次\n",
  "●  好友数量上限额外增加：[fefb1a]  50[-]人\n●  每天武神殿购买次数：　[fefb1a]    5[-]次\n●  每天商会协助次数：  　[fefb1a]   20[-]次\n●  每天[fefb1a]0.99/1.99[-]美元礼包购买资格\n●  每天传功次数:                [fefb1a]  2[-]次\n●  每天家族捐献次数：　　[fefb1a]  25[-]次\n●  每天世界频道发言次数：[fefb1a]  20[-]次\n●  每天宝藏探索次数：　　[fefb1a]  10[-]次\n",
  "●  获得举办[fefb1a]庄园[-]婚礼的特权\n●  每天商会任务求助次数：[fefb1a]3→4[-]次\n●  好友数量上限额外增加：  [fefb1a] 50[-]人\n●  每天武神殿购买次数：　[fefb1a]    5[-]次\n●  每天商会协助次数：  　[fefb1a]   20[-]次\n●  每天[fefb1a]0.99/1.99/2.99[-]美元礼包购买资格\n●  每天传功次数:                [fefb1a]  2[-]次\n●  每天家族捐献次数：　　[fefb1a]  25[-]次\n●  每天世界频道发言次数：[fefb1a]  20[-]次\n●  每天宝藏探索次数：　　[fefb1a]  10[-]次\n",
  "●  可使用特效白驹丸获得[fefb1a]2.5[-]倍离线经验\n●  可拜师/收徒的最低等级差：[fefb1a] 5→4[-]级\n●  世界频道发言间隔：    [fefb1a]   30→15[-]秒\n●  每天武神殿购买次数：　[fefb1a]   5→10[-]次\n●  每天家族捐献次数：　　[fefb1a] 25→50[-]次\n●  拥有举办[fefb1a]庄园[-]婚礼的特权\n●  每天商会任务求助次数：[fefb1a]           4[-]次\n●  好友数量上限额外增加：[fefb1a]         50[-]人\n●  每天商会协助次数：  　[fefb1a]          20[-]次\n●  每天[fefb1a]0.99/1.99/2.99[-]美元礼包购买资格\n●  每天传功次数:                       [fefb1a]  2[-]次\n●  每天世界频道发言次数：[fefb1a]        20[-]次\n●  每天宝藏探索次数：　　[fefb1a]        10[-]次\n",
  "●  家族礼盒每日兑换次数：[fefb1a]   4→5[-]次\n●  每天宝藏探索次数：[fefb1a]     10→15[-]次\n●  拥有举办[fefb1a]庄园[-]婚礼的特权\n●  可拜师/收徒的最低等级差：[fefb1a]    4[-]级\n●  可使用特效白驹丸获得[fefb1a]2.5[-]倍离线经验\n●  世界频道发言间隔：    [fefb1a]        15[-]秒\n●  每天商会任务求助次数：[fefb1a]        4[-]次\n●  好友数量上限额外增加：[fefb1a]      50[-]人\n●  每天武神殿购买次数：　[fefb1a]      10[-]次\n●  每天商会协助次数：  　[fefb1a]       20[-]次\n●  每天[fefb1a]0.99/1.99/2.99[-]美元礼包购买资格\n●  每天传功次数:                [fefb1a]      2[-]次\n●  每天家族捐献次数：　　[fefb1a]      50[-]次\n●  每天世界频道发言次数：[fefb1a]      20[-]次\n",
  "●  每天传功/被传功次数:       [fefb1a] 2→3[-]次\n●  离线托管获得经验：[fefb1a]100%→110%[-]\n●  拥有举办[fefb1a]庄园[-]婚礼的特权\n●  家族礼盒每日兑换次数：[fefb1a]         5[-]次\n●  可拜师/收徒的最低等级差：[fefb1a]     4[-]级\n●  可使用特效白驹丸获得[fefb1a]2.5[-]倍离线经验\n●  世界频道发言间隔：    [fefb1a]        15[-]秒\n●  每天商会任务求助次数：[fefb1a]        4[-]次\n●  好友数量上限额外增加：[fefb1a]       50[-]人\n●  每天武神殿购买次数：　[fefb1a]      10[-]次\n●  每天商会协助次数：  　[fefb1a]       20[-]次\n●  每天[fefb1a]0.99/1.99/2.99[-]美元礼包购买资格\n●  每天家族捐献次数：　　[fefb1a]      50[-]次\n●  每天世界频道发言次数：[fefb1a]      20[-]次\n●  每天宝藏探索次数：　　[fefb1a]      15[-]次\n",
  "●  获得举办[fefb1a]海岛[-]婚礼的特权\n●  可传功/被传功最低等级差：[fefb1a] 3→2[-]级\n●  可拜师/收徒的最低等级差：[fefb1a] 4→3[-]级\n●  每天家族捐献次数：[fefb1a]     50→200[-]次\n●  拥有举办[fefb1a]庄园[-]婚礼的特权\n●  每天传功/被传功次数:        [fefb1a]      3[-]次\n●  离线托管获得经验：      [fefb1a]      110%[-]\n●  家族礼盒每日兑换次数：[fefb1a]          5[-]次\n●  可使用特效白驹丸获得[fefb1a]2.5[-]倍离线经验\n●  世界频道发言间隔：    [fefb1a]          15[-]秒\n●  每天商会任务求助次数：[fefb1a]          4[-]次\n●  好友数量上限额外增加：[fefb1a]        50[-]人\n●  每天武神殿购买次数：　[fefb1a]        10[-]次\n●  每天商会协助次数：  　[fefb1a]         20[-]次\n●  每天[fefb1a]0.99/1.99/2.99[-]美元礼包购买资格\n●  每天世界频道发言次数：[fefb1a]        20[-]次\n●  每天宝藏探索次数：　　[fefb1a]        15[-]次\n",
  "●  每天武神殿购买次数：  [fefb1a]10→15[-]次\n●  摆摊显示商品数量增加[fefb1a]50%[-]\n●  摇钱树获得银两增加[fefb1a]20%[-]\n●  拥有举办[fefb1a]庄园、海岛[-]婚礼的特权\n●  可传功/被传功最低等级差：    [fefb1a]2[-]级\n●  每天传功/被传功次数:            [fefb1a]3[-]次\n●  离线托管获得经验：          [fefb1a]110%[-]\n●  家族礼盒每日兑换次数：     [fefb1a]   5[-]次\n●  可拜师/收徒的最低等级差：    [fefb1a]3[-]级\n●  可使用特效白驹丸获得[fefb1a]2.5[-]倍离线经验\n●  世界频道发言间隔：            [fefb1a]15[-]秒\n●  每天商会任务求助次数：      [fefb1a]  4[-]次\n●  好友数量上限额外增加：      [fefb1a]50[-]人\n●  每天商会协助次数：       　[fefb1a]  20[-]次\n●  每天[fefb1a]0.99/1.99/2.99[-]美元礼包购买资格\n●  每天家族捐献次数：          [fefb1a]200[-]次\n●  每天世界频道发言次数：    [fefb1a]  20[-]次\n●  每天宝藏探索次数：　　    [fefb1a]  15[-]次\n",
  "●  好友亲密度提升速度增加[fefb1a]20%[-]\n●  摆摊显示商品数量增加[fefb1a]50%[-]\n●  摇钱树获得银两增加[fefb1a]20%[-]\n●  拥有举办[fefb1a]庄园、海岛[-]婚礼的特权\n●  可传功/被传功最低等级差：   [fefb1a]2[-]级\n●  每天传功/被传功次数:           [fefb1a]3[-]次\n●  离线托管获得经验：         [fefb1a]110%[-]\n●  家族礼盒每日兑换次数：    [fefb1a]   5[-]次\n●  可拜师/收徒的最低等级差：   [fefb1a]3[-]级\n●  可使用特效白驹丸获得[fefb1a]2.5[-]倍离线经验\n●  世界频道发言间隔：           [fefb1a]15[-]秒\n●  每天商会任务求助次数：     [fefb1a]  4[-]次\n●  好友数量上限额外增加:       [fefb1a]50[-]人\n●  每天武神殿购买次数：　   [fefb1a]  15[-]次\n●  每天商会协助次数：      　[fefb1a]  20[-]次\n●  每天[fefb1a]0.99/1.99/2.99[-]美元礼包购买资格\n●  每天家族捐献次数：      [fefb1a]   200[-]次\n●  每天世界频道发言次数：   [fefb1a]  20[-]次\n●  每天宝藏探索次数：　   　[fefb1a]  15[-]次\n",
  "●  获得举办[fefb1a]舫舟[-]婚礼的特权\n●  离线托管获得经验：[fefb1a]110%→120%[-]\n●  每天家族捐献次数：[fefb1a]  200→500[-]次\n●  可拜师/收徒的最低等级差：[fefb1a]3→2[-]级\n●  拥有举办[fefb1a]庄园、海岛[-]婚礼的特权\n●  好友亲密度提升速度增加[fefb1a]20%[-]\n●  摆摊显示商品数量增加[fefb1a]50%[-]\n●  摇钱树获得银两增加[fefb1a]20%[-]\n●  可传功/被传功最低等级差：     [fefb1a]2[-]级\n●  每天传功/被传功次数:             [fefb1a]3[-]次\n●  家族礼盒每日兑换次数：      [fefb1a]   5[-]次\n●  可使用特效白驹丸获得[fefb1a]2.5[-]倍离线经验\n●  世界频道发言间隔：             [fefb1a]15[-]秒\n●  每天商会任务求助次数：       [fefb1a]  4[-]次\n●  好友数量上限额外增加:         [fefb1a]50[-]人\n●  每天武神殿购买次数：     　[fefb1a]  15[-]次\n●  每天商会协助次数：        　[fefb1a]  20[-]次\n●  每天[fefb1a]0.99/1.99/2.99[-]美元礼包购买资格\n●  每天世界频道发言次数：     [fefb1a]  20[-]次\n●  每天宝藏探索次数：　     　[fefb1a]  15[-]次\n",
  "●  每天武神殿购买次数：[fefb1a]15→20[-]次\n●  拥有举办[fefb1a]庄园、海岛、舫舟[-]婚礼的特权\n●  同伴经验药水经验增加[fefb1a]20%[-]\n●  好友亲密度提升速度增加[fefb1a]20%[-]\n●  摆摊显示商品数量增加[fefb1a]50%[-]\n●  摇钱树获得银两增加[fefb1a]20%[-]\n●  可传功/被传功最低等级差：  [fefb1a]2[-]级\n●  每天传功/被传功次数:          [fefb1a]3[-]次\n●  离线托管获得经验：        [fefb1a]120%[-]\n●  可拜师/收徒的最低等级差：  [fefb1a]2[-]级\n●  家族礼盒每日兑换次数：   [fefb1a]   5[-]次\n●  可使用特效白驹丸获得[fefb1a]2.5[-]倍离线经验\n●  世界频道发言间隔：          [fefb1a]15[-]秒\n●  每天商会任务求助次数：    [fefb1a]  4[-]次\n●  好友数量上限额外增加:      [fefb1a]50[-]人\n●  每天商会协助次数：    　 [fefb1a]  20[-]次\n●  每天[fefb1a]0.99/1.99/2.99[-]美元礼包购买资格\n●  每天家族捐献次数：       [fefb1a] 500[-]次\n●  每天世界频道发言次数：  [fefb1a]  20[-]次\n●  每天宝藏探索次数：　　  [fefb1a]  15[-]次\n",
  "●  每天修炼丹使用次数：  [fefb1a]1→2[-]次\n●  拥有举办[fefb1a]庄园、海岛、舫舟[-]婚礼的特权\n●  同伴经验药水经验增加[fefb1a]20%[-]\n●  好友亲密度提升速度增加[fefb1a]20%[-]\n●  摆摊显示商品数量增加[fefb1a]50%[-]\n●  可传功/被传功最低等级差：[fefb1a]2[-]级\n●  每天传功/被传功次数:        [fefb1a]3[-]次\n●  离线托管获得经验：      [fefb1a]120%[-]\n●  可拜师/收徒的最低等级差：[fefb1a]2[-]级\n●  摇钱树获得银两增加[fefb1a]20%[-]\n●  家族礼盒每日兑换次数：[fefb1a]    5[-]次\n●  可使用特效白驹丸获得[fefb1a]2.5[-]倍离线经验\n●  世界频道发言间隔：        [fefb1a]15[-]秒\n●  每天商会任务求助次数：[fefb1a]    4[-]次\n●  好友数量上限额外增加:    [fefb1a]50[-]人\n●  每天武神殿购买次数：　[fefb1a]  20[-]次\n●  每天商会协助次数：   　[fefb1a]  20[-]次\n●  每天[fefb1a]0.99/1.99/2.99[-]美元礼包购买资格\n●  每天家族捐献次数：     [fefb1a] 500[-]次\n●  每天世界频道发言次数：[fefb1a]  20[-]次\n●  每天宝藏探索次数：　　[fefb1a]  15[-]次\n",
  "●  可传功/被传功最低等级差：[fefb1a]2→1[-]级\n●  拥有举办[fefb1a]庄园、海岛、舫舟[-]婚礼的特权\n●  每天修炼丹使用次数：            [fefb1a]2[-]次\n●  同伴经验药水经验增加[fefb1a]20%[-]\n●  好友亲密度提升速度增加[fefb1a]20%[-]\n●  摆摊显示商品数量增加[fefb1a]50%[-]\n●  每天传功/被传功次数:             [fefb1a]3[-]次\n●  离线托管获得经验：           [fefb1a]120%[-]\n●  可拜师/收徒的最低等级差：     [fefb1a]2[-]级\n●  摇钱树获得银两增加[fefb1a]20%[-]\n●  家族礼盒每日兑换次数：[fefb1a]         5[-]次\n●  可使用特效白驹丸获得[fefb1a]2.5[-]倍离线经验\n●  世界频道发言间隔：             [fefb1a]15[-]秒\n●  每天商会任务求助次数：       [fefb1a]  4[-]次\n●  好友数量上限额外增加:         [fefb1a]50[-]人\n●  每天武神殿购买次数：     　[fefb1a]  20[-]次\n●  每天商会协助次数：        　[fefb1a]  20[-]次\n●  每天[fefb1a]0.99/1.99/2.99[-]美元礼包购买资格\n●  每天家族捐献次数：          [fefb1a] 500[-]次\n●  每天世界频道发言次数：     [fefb1a]  20[-]次\n●  每天宝藏探索次数：　    　 [fefb1a]  15[-]次\n",
  "●  每天传功/被传功次数:        [fefb1a]3→4[-]次\n●  离线托管获得经验：[fefb1a]120%→130%[-]\n●  每天家族捐献次数：[fefb1a]500→3000[-]次\n●  拥有举办[fefb1a]庄园、海岛、舫舟[-]婚礼的特权\n●  可传功/被传功最低等级差：     [fefb1a]1[-]级\n●  每天修炼丹使用次数：            [fefb1a]2[-]次\n●  同伴经验药水经验增加[fefb1a]20%[-]\n●  好友亲密度提升速度增加[fefb1a]20%[-]\n●  摆摊显示商品数量增加[fefb1a]50%[-]\n●  可拜师/收徒的最低等级差：     [fefb1a]2[-]级\n●  摇钱树获得银两增加[fefb1a]20%[-]\n●  家族礼盒每日兑换次数：      [fefb1a]   5[-]次\n●  可使用特效白驹丸获得[fefb1a]2.5[-]倍离线经验\n●  世界频道发言间隔：             [fefb1a]15[-]秒\n●  每天商会任务求助次数：       [fefb1a]  4[-]次\n●  好友数量上限额外增加:         [fefb1a]50[-]人\n●  每天武神殿购买次数：     　[fefb1a]  20[-]次\n●  每天商会协助次数：        　[fefb1a]  20[-]次\n●  每天[fefb1a]0.99/1.99/2.99[-]美元礼包购买资格\n●  每天世界频道发言次数：     [fefb1a]  20[-]次\n●  每天宝藏探索次数：　     　[fefb1a]  15[-]次\n",
  "●  摆摊显示商品数量增加[fefb1a]50%→100%[-]\n●  拥有举办[fefb1a]庄园、海岛、舫舟[-]婚礼的特权\n●  每天传功/被传功次数:           [fefb1a]4[-]次\n●  离线托管获得经验：          [fefb1a]130%[-]\n●  可传功/被传功最低等级差：   [fefb1a]1[-]级\n●  每天修炼丹使用次数：          [fefb1a]2[-]次\n●  同伴经验药水经验增加[fefb1a]20%[-]\n●  好友亲密度提升速度增加[fefb1a]20%[-]\n●  可拜师/收徒的最低等级差：   [fefb1a]2[-]级\n●  摇钱树获得银两增加[fefb1a]20%[-]\n●  家族礼盒每日兑换次数：[fefb1a]       5[-]次\n●  可使用特效白驹丸获得[fefb1a]2.5[-]倍离线经验\n●  世界频道发言间隔：           [fefb1a]15[-]秒\n●  每天商会任务求助次数：     [fefb1a]  4[-]次\n●  好友数量上限额外增加:       [fefb1a]50[-]人\n●  每天武神殿购买次数：   　[fefb1a]  20[-]次\n●  每天商会协助次数：      　[fefb1a]  20[-]次\n●  每天[fefb1a]0.99/1.99/2.99[-]美元礼包购买资格\n●  每天家族捐献次数：[fefb1a]       3000[-]次\n●  每天世界频道发言次数：[fefb1a]     20[-]次\n●  每天宝藏探索次数：　　[fefb1a]     15[-]次\n",
  "●  摆摊显示商品数量增加[fefb1a]100%[-]\n●  好友数量上限额外增加:  [fefb1a]50→100[-]人\n●  拥有举办[fefb1a]庄园、海岛、舫舟[-]婚礼的特权\n●  每天传功/被传功次数:              [fefb1a]4[-]次\n●  离线托管获得经验：             [fefb1a]130%[-]\n●  可传功/被传功最低等级差：      [fefb1a]1[-]级\n●  每天修炼丹使用次数：             [fefb1a]2[-]次\n●  同伴经验药水经验增加[fefb1a]20%[-]\n●  好友亲密度提升速度增加[fefb1a]20%[-]\n●  可拜师/收徒的最低等级差：      [fefb1a]2[-]级\n●  摇钱树获得银两增加[fefb1a]20%[-]\n●  家族礼盒每日兑换次数：[fefb1a]          5[-]次\n●  可使用特效白驹丸获得[fefb1a]2.5[-]倍离线经验\n●  世界频道发言间隔：    [fefb1a]          15[-]秒\n●  每天商会任务求助次数：[fefb1a]          4[-]次\n●  每天武神殿购买次数：　[fefb1a]        20[-]次\n●  每天商会协助次数：  　[fefb1a]         20[-]次\n●  每天[fefb1a]0.99/1.99/2.99[-]美元礼包购买资格\n●  每天家族捐献次数：[fefb1a]          3000[-]次\n●  每天世界频道发言次数：[fefb1a]        20[-]次\n●  每天宝藏探索次数：　　[fefb1a]        15[-]次\n"
}
if version_vn then
  Recharge.tbVipDesc[2] = "●  蓝V标识\n●  传功次数每日额外增加[fefb1a]1[-]次\n●  每天世界频道发言次数：[fefb1a]  20[-]次\n●  每天宝藏探索次数：　　[fefb1a]  10[-]次\n●  每天家族捐献次数：　　[fefb1a]  20[-]次\n"
  Recharge.tbVipDesc[4] = "●  可发放2倍红包\n●  每天世界频道发言次数：[fefb1a]  20[-]次\n●  每天宝藏探索次数：　　[fefb1a]  10[-]次\n●  每天家族捐献次数：　　[fefb1a]  25[-]次\n●  每天武神殿购买次数：　[fefb1a]    5[-]次\n"
  Recharge.tbVipDesc[6] = "●  可发放3倍红包\n●  每天世界频道发言次数：[fefb1a]  20[-]次\n●  每天宝藏探索次数：　　[fefb1a]  10[-]次\n●  每天家族捐献次数：　　[fefb1a]  25[-]次\n●  每天武神殿购买次数：　[fefb1a]    5[-]次\n"
end
Recharge.DAILY_GIFT_TYPE = {
  YUAN_1 = 1,
  YUAN_3 = 2,
  YUAN_6 = 3,
  YUAN_10 = 4
}
Recharge.DAYS_CARD_TYPE = {DAYS_7 = 1, DAYS_30 = 2}
Recharge.tbVipPrivilegeDesc = {
  KinDonate = {
    [0] = "升级尊1每天最多可捐献20次",
    [1] = "升级尊3每天最多可捐献25次",
    [2] = "升级尊3每天最多可捐献25次",
    [3] = "升级尊7每天最多可捐献50次",
    [4] = "升级尊7每天最多可捐献50次",
    [5] = "升级尊7每天最多可捐献50次",
    [6] = "升级尊7每天最多可捐献50次",
    [7] = "升级尊9每天最多可捐献200次",
    [8] = "升级尊9每天最多可捐献200次",
    [9] = "升级尊12每天最多可捐献500次",
    [10] = "升级尊12每天最多可捐献500次",
    [11] = "升级尊12每天最多可捐献500次",
    [12] = "升级尊14捐献获得贡献增加20%",
    [13] = "升级尊14捐献获得贡献增加20%",
    [14] = "升级尊16每天最多可捐献3000次",
    [15] = "升级尊16每天最多可捐献3000次"
  },
  MoneyTree = {
    [8] = "升级尊10摇钱树获得银两增加20%",
    [9] = "升级尊10摇钱树获得银两增加20%"
  },
  WaiYi = {
    [7] = "升级尊10可赠予好友外装",
    [8] = "升级尊10可赠予好友外装",
    [9] = "升级尊10可赠予好友外装"
  },
  OnHook = {
    [3] = "升级尊6可使用特效白驹丸托管（离线经验2.5倍）",
    [4] = "升级尊6可使用特效白驹丸托管（离线经验2.5倍）",
    [5] = "升级尊6可使用特效白驹丸托管（离线经验2.5倍）",
    [6] = "升级尊8离线托管经验增加10%",
    [7] = "升级尊8离线托管经验增加10%",
    [9] = "升级尊12离线托管经验增加20%",
    [10] = "升级尊12离线托管经验增加20%",
    [11] = "升级尊12离线托管经验增加20%",
    [13] = "升级尊16离线托管经验增加30%",
    [14] = "升级尊16离线托管经验增加30%",
    [15] = "升级尊16离线托管经验增加30%"
  },
  FriendImity = {
    [8] = "升级尊11好友亲密度提升速度增加20%",
    [9] = "升级尊11好友亲密度提升速度增加20%",
    [10] = " 升级尊11好友亲密度提升速度增加20%"
  },
  KinGift = {
    [4] = "升级尊7每天家族礼盒兑换次数增加1次",
    [5] = "升级尊7每天家族礼盒兑换次数增加1次",
    [6] = "升级尊7每天家族礼盒兑换次数增加1次"
  }
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
  if tbInfo.version_tx == 1 and version_tx or tbInfo.version_vn == 1 and version_vn or tbInfo.version_hk == 1 and version_hk or tbInfo.version_xm == 1 and version_xm or tbInfo.version_en == 1 and version_en or tbInfo.version_kor == 1 and version_kor or tbInfo.version_th == 1 and version_th then
    return true
  end
  return false
end
function Recharge:Init()
  local tbSettingGroup = {}
  local tbProductionSettingAll = {}
  local tbFile = LoadTabFile("Setting/Recharge/Recharge.tab", "sssddsdssssssdsddssss", nil, {
    "ProductId",
    "szDesc",
    "szServiceCode",
    "nLastingDay",
    "nMoney",
    "szMoneyType",
    "nNeedVipLevel",
    "szAward",
    "szFirstAward",
    "szThirdAward",
    "szFourthAward",
    "szFifthAward",
    "szGroup",
    "nGroupIndex",
    "szVersion",
    "nEndTimeKey",
    "nBuyDayKey",
    "szSprite",
    "szFirstDesc",
    "szNoromalDesc",
    "Plat"
  })
  local fnCheck
  if MODULE_GAMESERVER and (version_hk or version_tw) then
    function fnCheck(v)
      return v.szVersion == "version_hk" or v.szVersion == "version_tw"
    end
  else
    function fnCheck(v)
      if not _G[v.szVersion] then
        return
      end
      if MODULE_GAMECLIENT and not Lib:IsEmptyStr(v.Plat) and not _G[v.Plat] then
        return
      end
      return true
    end
  end
  for i, v in ipairs(tbFile) do
    if fnCheck(v) then
      if v.szAward ~= "" then
        v.tbAward = Lib:GetAwardFromString(v.szAward)
      end
      if v.szFirstAward ~= "" then
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
        tbSettingGroup[v.szGroup] = tbSettingGroup[v.szGroup] or {}
        tbSettingGroup[v.szGroup][v.nGroupIndex] = v
      end
    end
  end
  local tbGrowInvestGroup = {}
  local tbFile = LoadTabFile("Setting/Recharge/GrowInvest.tab", "dddddddddddd", nil, {
    "nGroup",
    "nIndex",
    "nLevel",
    "nAwardGold",
    "nDay",
    "version_tx",
    "version_vn",
    "version_hk",
    "version_xm",
    "version_en",
    "version_kor",
    "version_th"
  })
  for i, v in ipairs(tbFile) do
    if self:CheckVersion(v) then
      tbGrowInvestGroup[v.nGroup] = tbGrowInvestGroup[v.nGroup] or {}
      local tbData = {
        nLevel = v.nLevel,
        nAwardGold = v.nAwardGold
      }
      if v.nDay ~= 0 then
        tbData.nDay = v.nDay
      end
      tbGrowInvestGroup[v.nGroup][v.nIndex] = tbData
    end
  end
  Recharge.tbGrowInvestGroup = tbGrowInvestGroup
  self.tbProductionSettingAll = tbProductionSettingAll
  self.tbSettingGroup = tbSettingGroup
  self.szDefMoneyType = self.tbSettingGroup.BuyGold[1].szMoneyType
  if version_kor then
    if MODULE_GAMESERVER then
      assert(self.szDefMoneyType == "KRW")
    end
    self.szDefMoneyType = "KRW"
  end
  if not version_tx then
    local nRate = self.tbMoneyRMBRate[self.szDefMoneyType]
    for i, v in ipairs(Recharge.tbVipSetting) do
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
    return 0
  end
  local tbBuyInfo = self.tbSettingGroup.DaysCard[nIndex]
  return Lib:GetLocalDay(pPlayer.GetUserValue(self.SAVE_GROUP, tbBuyInfo.nEndTimeKey) - 14400) - Lib:GetLocalDay(GetTime() - 14400)
end
function Recharge:GetDaysCardLeftTime(pPlayer, nIndex)
  if not self.tbSettingGroup.DaysCard then
    return 0
  end
  local tbBuyInfo = self.tbSettingGroup.DaysCard[nIndex]
  return pPlayer.GetUserValue(self.SAVE_GROUP, tbBuyInfo.nEndTimeKey) - GetTime()
end
function Recharge:GetDaysCardEndTime(pPlayer, nIndex)
  if not self.tbSettingGroup.DaysCard then
    return 0
  end
  local tbBuyInfo = self.tbSettingGroup.DaysCard[nIndex]
  return pPlayer.GetUserValue(self.SAVE_GROUP, tbBuyInfo.nEndTimeKey)
end
function Recharge:GetTotoalRecharge(pPlayer)
  return self:GetTotoalRechargeGold(pPlayer) + pPlayer.GetUserValue(self.SAVE_GROUP, self.KEY_TOTAL_CARD)
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
  if self.tbCardActData then
    return self.tbCardActData
  end
  local nWeekDay = Lib:GetLocalWeekDay(GetTime() - 14400)
  if nWeekDay == 6 or nWeekDay == 7 then
    return {
      self.fActivityCardAwardParam,
      self.fActivityCardAwardParam
    }
  end
  return false
end
function Recharge:GetRefreshDay()
  return Lib:GetLocalDay(GetTime() - 14400)
end
function Recharge:CheckBuyGoldGetNum(pPlayer, szProductId)
  local tbBuyInfo = self.tbProductionSettingAll[szProductId]
  if not tbBuyInfo then
    return 0
  end
  local nMoney = tbBuyInfo.nMoney
  local szGroup = tbBuyInfo.szGroup
  if szGroup == "BuyGold" then
    local nSellIdx = tbBuyInfo.nGroupIndex
    local nBuyedFlag = Recharge:GetBuyedFlag(pPlayer)
    local nBuydeBit = KLib.GetBit(nBuyedFlag, nSellIdx)
    if nBuydeBit == 1 then
      return self:GetGoldNumFromAward(tbBuyInfo.tbAward)
    else
      return self:GetGoldNumFromAward(tbBuyInfo.tbFirstAward)
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
  for _, v2 in ipairs(tbAward) do
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
  local bRet, szMsg = true, nil
  if szGroup == "DaysCard" then
    if not self:CanBuyDaysCard(pPlayer, tbBuyInfo.nGroupIndex) then
      return
    end
  elseif szGroup == "GrowInvest" then
    if not self:CanBuyGrowInvest(pPlayer, tbBuyInfo.nGroupIndex) then
      return
    end
  elseif szGroup == "DayGift" then
    bRet, szMsg = self:CanBuyOneDayCard(pPlayer, szProductId)
  elseif szGroup == "DayGiftSet" then
    bRet, szMsg = self:CanBuyOneDayCardSet(pPlayer)
  elseif szGroup == "YearGift" then
    bRet, szMsg = self:CanBuyYearGift(pPlayer, szProductId)
  elseif szGroup == "DirectEnhance" then
    bRet, szMsg = self:CanBuyDirectEnhance(pPlayer, szProductId)
  elseif szGroup == "DayGiftPlus" then
    bRet, szMsg = self:CanBuyOneDayCardPlus(pPlayer, szProductId)
  elseif szGroup == "DressMoney" then
    bRet, szMsg = self:CanBuyDressMoney()
  end
  if szMsg then
    pPlayer.CenterMsg(szMsg, true)
  end
  return bRet
end
function Recharge:CanBuyYearGift(pPlayer, szProductId)
  local tbBuyInfo = Recharge.tbProductionSettingAll[szProductId]
  if not tbBuyInfo then
    return
  end
  if not Activity:__IsActInProcessByType("RechargeNewYearBuyGift") then
    return false, "不在活动时间内不可购买"
  end
  if pPlayer.GetVipLevel() < tbBuyInfo.nNeedVipLevel then
    return false, string.format("达到剑侠尊享%d后可购买", tbBuyInfo.nNeedVipLevel)
  end
  local tbLimitInfo = self.tbNewYearBuySetting[tbBuyInfo.nGroupIndex]
  if tbLimitInfo.nSaveCountKey and tbLimitInfo.nBuyCount > 1 then
    if pPlayer.GetUserValue(Recharge.SAVE_GROUP, tbLimitInfo.nSaveCountKey) >= tbLimitInfo.nBuyCount then
      return false, string.format("最多购买%d次", tbLimitInfo.nBuyCount)
    elseif pPlayer.GetUserValue(Recharge.SAVE_GROUP, tbBuyInfo.nBuyDayKey) == Recharge:GetRefreshDay() then
      return false, "今天已经买过了"
    end
  elseif pPlayer.GetUserValue(Recharge.SAVE_GROUP, tbBuyInfo.nBuyDayKey) > 0 then
    return false, "最多购买一次"
  end
  local szAwardKey
  if MODULE_GAMESERVER then
    szAwardKey = self.szYearGiftAwardKey
  else
    local tbUiData, tbActData = Activity:GetActUiSetting("RechargeNewYearBuyGift")
    szAwardKey = tbUiData and tbUiData.szAwardKey
  end
  if not szAwardKey then
    return false, "活动已结束"
  end
  local tbInfo = tbBuyInfo[szAwardKey]
  if not tbInfo then
    return false, "未开放对应奖励"
  end
  return true
end
function Recharge:CanBuyDirectEnhance(pPlayer, szProductId)
  if not self.IS_OPEN_BUY_ENHANCE then
    return false, "当前暂时关闭购买"
  end
  local tbBuyInfo = Recharge.tbProductionSettingAll[szProductId]
  if not tbBuyInfo then
    return
  end
  if pPlayer.GetUserValue(self.SAVE_GROUP, tbBuyInfo.nEndTimeKey) ~= 0 then
    return false, "当前已经购买"
  end
  local tbLimitSetting = self.tbDirectEnhanceSetting[tbBuyInfo.nGroupIndex]
  if not tbLimitSetting then
    return
  end
  if GetTimeFrameState(tbLimitSetting.OpenTimeFrame) ~= 1 then
    return
  end
  if pPlayer.nLevel < tbLimitSetting.nPlayerLevel then
    return false, "等级不够"
  end
  local nMoreCount = 0
  local tbStrengthen = pPlayer.GetStrengthen()
  for nEquipPos = 1, 10 do
    local nStrenLevel = tbStrengthen[nEquipPos]
    if nStrenLevel >= tbLimitSetting.nEnhanceLevel then
      nMoreCount = nMoreCount + 1
    end
  end
  if nMoreCount >= 10 then
    return false, string.format("身上没有强化低于%d级的位置", tbLimitSetting.nEnhanceLevel)
  end
  return true
end
function Recharge:CanBuyOneDayCard(pPlayer, szProductId)
  local tbBuyInfo = Recharge.tbProductionSettingAll[szProductId]
  if not tbBuyInfo then
    return
  end
  if pPlayer.GetVipLevel() < tbBuyInfo.nNeedVipLevel then
    return false, string.format("达到剑侠尊享%d后可购买", tbBuyInfo.nNeedVipLevel)
  end
  local nToday = Recharge:GetRefreshDay()
  if nToday <= pPlayer.GetUserValue(self.SAVE_GROUP, tbBuyInfo.nBuyDayKey) then
    return false, "今天已经买过了"
  end
  if self.tbSettingGroup.DayGiftSet then
    local tbBuyInfoSet = self.tbSettingGroup.DayGiftSet[1]
    local nBuySetDay = pPlayer.GetUserValue(self.SAVE_GROUP, tbBuyInfoSet.nBuyDayKey)
    if nToday <= nBuySetDay then
      return false, "已购买组合礼包"
    end
  end
  local bRet, szMsg = self:IsNotTakeOrBuyedOneDayCardPlus(pPlayer)
  if not bRet then
    return bRet, szMsg
  end
  return true
end
function Recharge:IsNotTakeOrBuyedOneDayCardPlus(pPlayer)
  if pPlayer.GetUserValue(self.SAVE_GROUP, self.KEY_ONE_DAY_CARD_PLUS_COUNT) > 0 then
    return false, "已购买一三六累积礼包"
  end
  if pPlayer.GetUserValue(self.SAVE_GROUP, self.KEY_ONE_DAY_CARD_PLUS_DAY) >= self:GetRefreshDay() then
    return false, "已领取一三六累积礼包"
  end
  return true
end
function Recharge:CanBuyOneDayCardSet(pPlayer)
  local tbGroup = self.tbSettingGroup.DayGiftSet
  if not tbGroup then
    return false, "无配置", false
  end
  local tbBuyInfo = tbGroup[1]
  if not tbBuyInfo then
    return false, "无配置", false
  end
  if Sdk:IsPCVersion() then
    return false, "PC版不可购买", false
  end
  if pPlayer.GetVipLevel() < tbBuyInfo.nNeedVipLevel then
    return false, string.format("达到剑侠尊享%d后可购买", tbBuyInfo.nNeedVipLevel), true
  end
  local nToday = Recharge:GetRefreshDay()
  if nToday <= pPlayer.GetUserValue(self.SAVE_GROUP, tbBuyInfo.nBuyDayKey) then
    return false, "今天已经买过了", false
  end
  for i, v in ipairs(self.tbSettingGroup.DayGift) do
    if nToday <= pPlayer.GetUserValue(self.SAVE_GROUP, v.nBuyDayKey) then
      return false, "已购买分拆包", false
    end
  end
  local bRet, szMsg = self:IsNotTakeOrBuyedOneDayCardPlus(pPlayer)
  if not bRet then
    return bRet, szMsg, false
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
    pPlayer.CenterMsg(string.format("只有%s剩余时间小于%d天时才能购买新的", tbBuyInfo.szDesc, self.tbDaysCardBuyLimitDay[nIndex]))
    return
  end
  return true
end
function Recharge:CanBuyGrowInvest(pPlayer, nGroupIndex)
  if nGroupIndex == 4 and not Activity:__IsActInProcessByType("RechargeNewyearGrowInvest") then
    return
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
  if version_tx then
    if MODULE_GAMECLIENT and Sdk:IsLoginByGuest() then
      return
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
function Recharge:GetActRechareRMBToGold(nRechareRMB)
  return math.ceil(Recharge.tbMoneyRMBRate[self.szDefMoneyType] * nRechareRMB / 10)
end
function Recharge:GetDayInvestTaskedDayKey(nGroupIndex)
  if nGroupIndex == 4 then
    return self.KEY_INVEST_ACT_TAKEDAY
  end
  if nGroupIndex == 7 then
    return self.KEY_INVEST_BACK_TAKEDAY
  end
end
function Recharge:GetActGrowInvestTakeDay(pPlayer, nGroupIndex)
  local nSaveKey = self:GetDayInvestTaskedDayKey(nGroupIndex)
  if not nSaveKey then
    return 0
  end
  local nTakedDay = pPlayer.GetUserValue(self.SAVE_GROUP, nSaveKey)
  local nRefreshDay = Recharge:GetRefreshDay()
  local nNowMinus = nRefreshDay - nTakedDay
  if nNowMinus > 0 then
    local nTaked = pPlayer.GetUserValue(Recharge.SAVE_GROUP, Recharge.tbKeyGrowTaked[nGroupIndex])
    local tbSetting = self.tbGrowInvestGroup[nGroupIndex]
    for i, v in ipairs(tbSetting) do
      if KLib.GetBit(nTaked, i) == 0 then
        if i == 1 then
          do return i end
          break
        end
        do
          local nDayMinus = v.nDay - tbSetting[i - 1].nDay
          if nNowMinus >= nDayMinus then
            return i
          end
        end
        break
      end
    end
  end
  return 0
end
function Recharge:CanTakeOneDayCardPlusAward(pPlayer)
  local nOldCount = pPlayer.GetUserValue(self.SAVE_GROUP, self.KEY_ONE_DAY_CARD_PLUS_COUNT)
  if nOldCount <= 0 then
    return false, "没有可领取次数"
  end
  local nTakedDay = pPlayer.GetUserValue(self.SAVE_GROUP, self.KEY_ONE_DAY_CARD_PLUS_DAY)
  if self:GetRefreshDay() == nTakedDay then
    return false, "今天已经领取过了，请[FFFE0D]凌晨4点[-]过后再来领取", nOldCount
  end
  return true, nil, nOldCount
end
function Recharge:CanBuyOneDayCardPlus(pPlayer)
  if not self.tbSettingGroup.DayGiftPlus then
    return false, "无对应购买项", false
  end
  local tbBuyInfo = self.tbSettingGroup.DayGiftPlus[1]
  local nOldCount = pPlayer.GetUserValue(self.SAVE_GROUP, self.KEY_ONE_DAY_CARD_PLUS_COUNT)
  if nOldCount > 0 then
    return false, "还有可领取次数", true
  end
  if GetTimeFrameState("OpenLevel49") ~= 1 then
    return false, "暂未开启一键购买，请侠士在开放49级上限后再尝试", false
  end
  if pPlayer.GetVipLevel() < tbBuyInfo.nNeedVipLevel then
    return false, string.format("达到剑侠尊享%d后可购买", tbBuyInfo.nNeedVipLevel), true
  end
  local nToday = self:GetRefreshDay()
  if self.tbSettingGroup.DayGiftSet then
    local tbBuyInfoSet = self.tbSettingGroup.DayGiftSet[1]
    local nBuySetDay = pPlayer.GetUserValue(self.SAVE_GROUP, tbBuyInfoSet.nBuyDayKey)
    if nToday <= nBuySetDay then
      return false, "已购买组合礼包", true
    end
  end
  for i, v in ipairs(self.tbSettingGroup.DayGift) do
    if nToday <= pPlayer.GetUserValue(self.SAVE_GROUP, v.nBuyDayKey) then
      return false, "已购买过礼包，无法进行一键购买，请[FFFE0D]凌晨4点[-]后再尝试", true
    end
  end
  return true, nil, true
end
function Recharge:GetMonthCardAward()
  local tbAward = {}
  for i, v in ipairs(Recharge.tbMonAward) do
    if GetTimeFrameState(v[2]) == 1 then
      tbAward = v[1]
    end
  end
  return tbAward
end
function Recharge:GetWeekCardAward()
  local tbAward = {}
  for i, v in ipairs(Recharge.tbWeekAward) do
    if GetTimeFrameState(v[2]) == 1 then
      tbAward = v[1]
    end
  end
  return tbAward
end
