Kin.Def = {
  nMaxCountPerSrv = 150,
  nLevelLimite = 11,
  nCreationCost = 1200,
  nChangeNameCost = 1000,
  nCreationContribution = 6000,
  nEliteContributionLine = 1,
  nChatForbidTime = 7200,
  nContribDelayDeleteTime = 604800,
  nChangeLeaderTime = 259200,
  nMaxCareerMailPerDay = 3,
  nMaxMailCount = 3,
  nMailCountRefreshTime = 14400,
  nSendMailFeeRate = 10,
  nMaxMailLength = 200,
  nMaxApplyList = 200,
  nMaxKinNameLength = 6,
  nMinKinNameLength = 2,
  nMaxKinTitleLen = 4,
  szFullTitleFormat = "［家族］%s·%s",
  nMaxDeclareLength = 160,
  nMaxAddDeclareLength = 96,
  nKinMapTemplateId = 1004,
  nKinNestMapTemplateId = 700,
  nPrestigeFalloffRate = 0.2,
  nContributionFalloffRate = 0.2,
  bForbidCamp = true,
  nDonate2ContribPerTime = 200,
  nMaxBuildingLevel = 10,
  nBuildingLevelUpdateTime = 14400,
  nDonateNoticeMin = 50,
  nGiftBagRefreshTime = 14400,
  nGiftBoxCost = 100,
  nMaxGiftBoxPerDay = 4,
  nGiftBoxCdTime = 3600,
  Career_Master = 1,
  Career_ViceMaster = 2,
  Career_Elder = 3,
  Career_Elite = 4,
  Career_Normal = 5,
  Career_New = 6,
  Career_Retire = 7,
  Career_Mascot = 8,
  Career_Leader = 9,
  Authority_Recruit = 1,
  Authority_KickOut = 2,
  Authority_EditRecuitInfo = 3,
  Authority_Invite = 4,
  Authority_Promotion = 5,
  Authority_Retire = 6,
  Authority_Disband = 7,
  Authority_Building = 8,
  Authority_Combine = 9,
  Authority_GrantMaster = 10,
  Authority_GrantOlder = 11,
  Authority_GrantViceMaster = 12,
  Authority_GrantLeader = 13,
  Authority_GrantMascot = 20,
  Authority_ChatForbid = 14,
  Authority_Mail = 15,
  Authority_EditKinTitle = 16,
  Authority_EditPubilcDeclare = 17,
  Authority_ChangeCamp = 18,
  Authority_BindGroup = 19,
  MEMBER_GIFT_KEY_GROUP = 85,
  MEMBER_GIFT_KEY_CUR_DAY = 1,
  MEMBER_GIFT_KEY_NEXT_BUY_TIME = 2,
  MEMBER_GIFT_KEY_LEFT_COUNT = 3
}
if version_vn then
  Kin.Def.nMaxKinNameLength = 14
  Kin.Def.nMinKinNameLength = 4
  Kin.Def.nMaxKinTitleLen = 14
  Kin.Def.nMaxMailLength = 400
elseif version_hk or version_tw or version_xm then
  Kin.Def.nMaxKinNameLength = 22
  Kin.Def.nMaxKinTitleLen = 12
elseif version_th then
  Kin.Def.nMaxKinNameLength = 14
  Kin.Def.nMaxKinTitleLen = 8
end
Kin.Def.tbManagerCareers = {
  [Kin.Def.Career_Master] = true,
  [Kin.Def.Career_ViceMaster] = true,
  [Kin.Def.Career_Elder] = true,
  [Kin.Def.Career_Mascot] = true
}
Kin.Def.CareerAuthorityName = {
  [Kin.Def.Authority_Recruit] = "招收成员",
  [Kin.Def.Authority_KickOut] = "开除成员",
  [Kin.Def.Authority_EditRecuitInfo] = "修改家族宣言",
  [Kin.Def.Authority_Promotion] = "见习转正",
  [Kin.Def.Authority_Retire] = "强制退隐",
  [Kin.Def.Authority_Building] = "建筑升级",
  [Kin.Def.Authority_ChatForbid] = "家族禁言",
  [Kin.Def.Authority_Mail] = "发送家族邮件",
  [Kin.Def.Authority_EditKinTitle] = "修改职位称谓",
  [Kin.Def.Authority_EditPubilcDeclare] = "修改家族公告",
  [Kin.Def.Authority_ChangeCamp] = "修改家族阵营"
}
Kin.Def.ChangeCampFound = {
  [1] = 20000,
  [2] = 40000,
  [3] = 60000
}
local Array2Map = function(...)
  local params = {
    ...
  }
  local map = {}
  for _, key in pairs(params) do
    map[key] = true
  end
  return map
end
Kin.Def.Career_Authority = {
  [Kin.Def.Career_Master] = Array2Map(1, 2, 3, 4, 5, 7, 8, 9, 10, 11, 12, 14, 15, 16, 17, 19, 20),
  [Kin.Def.Career_ViceMaster] = Array2Map(1, 3, 4, 5, 14, 15, 17),
  [Kin.Def.Career_Elder] = Array2Map(1, 5, 17, 15, 14),
  [Kin.Def.Career_Normal] = Array2Map(),
  [Kin.Def.Career_New] = Array2Map(),
  [Kin.Def.Career_Elite] = Array2Map(),
  [Kin.Def.Career_Retire] = Array2Map(),
  [Kin.Def.Career_Leader] = Array2Map(1),
  [Kin.Def.Career_Mascot] = Array2Map()
}
Kin.Def.Career_Name = {
  [Kin.Def.Career_Master] = "族长",
  [Kin.Def.Career_ViceMaster] = "副族长",
  [Kin.Def.Career_Elder] = "长老",
  [Kin.Def.Career_Normal] = "成员",
  [Kin.Def.Career_New] = "见习",
  [Kin.Def.Career_Elite] = "精英",
  [Kin.Def.Career_Retire] = "退隐",
  [Kin.Def.Career_Mascot] = "家族宝贝",
  [Kin.Def.Career_Leader] = "领袖"
}
Kin.Def.CareerRewardAdditionRate = {
  [Kin.Def.Career_Master] = 0,
  [Kin.Def.Career_ViceMaster] = 0,
  [Kin.Def.Career_Elder] = 0,
  [Kin.Def.Career_Normal] = 0,
  [Kin.Def.Career_New] = 0,
  [Kin.Def.Career_Elite] = 0,
  [Kin.Def.Career_Retire] = 0,
  [Kin.Def.Career_Mascot] = 0,
  [Kin.Def.Career_Leader] = 0
}
Kin.Def.Career2Authority = {
  [Kin.Def.Career_Master] = Kin.Def.Authority_GrantMaster,
  [Kin.Def.Career_ViceMaster] = Kin.Def.Authority_GrantViceMaster,
  [Kin.Def.Career_Elder] = Kin.Def.Authority_GrantOlder,
  [Kin.Def.Career_Normal] = Kin.Def.Authority_Recruit,
  [Kin.Def.Career_Elite] = Kin.Def.Authority_Recruit,
  [Kin.Def.Career_Mascot] = Kin.Def.Authority_Recruit
}
Kin.Def.Building_Main = 1
Kin.Def.Building_Totem = 2
Kin.Def.Building_Auction = 3
Kin.Def.Building_Treasure = 4
Kin.Def.Building_DrugStore = 5
Kin.Def.Building_FangJuHouse = 6
Kin.Def.Building_WeaponStore = 7
Kin.Def.Building_ShouShiHouse = 8
Kin.Def.Building_War = 9
Kin.Def.BuildingName = {
  [Kin.Def.Building_Main] = "主殿",
  [Kin.Def.Building_Totem] = "图腾",
  [Kin.Def.Building_Auction] = "拍卖行",
  [Kin.Def.Building_Treasure] = "金库",
  [Kin.Def.Building_DrugStore] = "珍宝坊",
  [Kin.Def.Building_WeaponStore] = "兵甲坊",
  [Kin.Def.Building_War] = "战争坊",
  [Kin.Def.Building_FangJuHouse] = "防具坊",
  [Kin.Def.Building_ShouShiHouse] = "首饰坊"
}
Kin.Def.BuildingCanUpdate = {
  [Kin.Def.Building_Main] = true,
  [Kin.Def.Building_War] = true,
  [Kin.Def.Building_DrugStore] = true,
  [Kin.Def.Building_WeaponStore] = true,
  [Kin.Def.Building_Treasure] = true,
  [Kin.Def.Building_FangJuHouse] = true,
  [Kin.Def.Building_ShouShiHouse] = true
}
Kin.Def.BuildingDiscountRate = {
  [1] = 1,
  [2] = 0.8,
  [3] = 0.7,
  [4] = 0.6,
  [5] = 0.5,
  [6] = 0.4,
  [7] = 0.3,
  [8] = 0.3,
  [9] = 0.3,
  [10] = 0.3
}
Kin.Def.GiftBoxItemIdByLevel = {
  [1] = 1226,
  [2] = 1227,
  [3] = 4687,
  [4] = 4687,
  [5] = 4687,
  [6] = 4687,
  [7] = 4687,
  [8] = 4687,
  [9] = 4687,
  [10] = 4687
}
Kin.Def.nDonationMaxRecordCount = 13
Kin.Def.nRedBagMaxCount = 100
Kin.Def.nRedBagListMaxCount = 80
Kin.Def.nRedBagReceiverShowCount = 50
Kin.Def.nRedBagActiveDelta = 300
Kin.Def.nRedbagExpireTime = 86400
Kin.Def.tbRedBagNextCheckTimes = {}
Kin.Def.BuildingOpenLimit = {
  [Kin.Def.Building_Main] = 1,
  [Kin.Def.Building_Totem] = 1,
  [Kin.Def.Building_War] = 4,
  [Kin.Def.Building_DrugStore] = 1,
  [Kin.Def.Building_WeaponStore] = 2,
  [Kin.Def.Building_Auction] = 1,
  [Kin.Def.Building_Treasure] = 1,
  [Kin.Def.Building_FangJuHouse] = 2,
  [Kin.Def.Building_ShouShiHouse] = 2
}
Kin.RobDef = {
  FailLostFound = {2000, 4000},
  RewardItemId = 1005,
  FirstKillContrib = 100,
  MaxRewardPerDay = 4,
  KillRobberContribution = 50,
  KillAllRobberPrestige = {
    20,
    10,
    10,
    10
  },
  ActivityTime = 1800
}
Kin.NestDef = {
  tbClueRewards = {
    [0] = {
      {
        "Item",
        1363,
        1
      }
    },
    [1] = {
      {
        "Item",
        1363,
        1
      }
    },
    [2] = {
      {
        "Item",
        1363,
        2
      }
    },
    [3] = {
      {
        "Item",
        1363,
        3
      }
    }
  }
}
Kin.MonsterNianDef = {
  nFireworkPickId = 2173,
  nFireworkPickTime = 2,
  nFireworkRefreshInterval = 15,
  szFireworkUseAtlas = "UI/Atlas/Home/HomeScreenAtlas.prefab ",
  szFireworkUseSprite = "Fireworks",
  nFireworkId = 3688,
  nFireworkSkillIds = {
    3507,
    3509,
    3511
  },
  nMaxFireworkSkillDist = 400,
  nFireworkCD = 5,
  nFireworksCountMult = 2,
  nFireworkMaxInBag = 3,
  tbFireworksPos = {
    {3072, 7598},
    {3057, 6701},
    {2157, 6766},
    {3280, 6861},
    {2377, 6493},
    {2089, 7259},
    {2006, 7022},
    {2454, 6935},
    {2920, 7022},
    {2897, 6526},
    {2879, 7319},
    {2478, 7310},
    {2262, 7365},
    {2581, 7583},
    {2215, 7069},
    {2847, 7560},
    {3128, 7374},
    {2815, 6726},
    {2445, 6699},
    {3155, 7102},
    {2898, 7731},
    {2667, 6971},
    {2643, 6708},
    {2661, 6475},
    {2256, 6617},
    {2726, 7681},
    {2250, 6892},
    {2782, 6874},
    {2499, 7119},
    {2670, 7374},
    {3037, 6880},
    {3001, 7223},
    {2714, 7167}
  },
  nMonsterId = 2172,
  tbMonsterPos = {2597, 7243},
  szMapMonsterIndex = "MonsterNianPos",
  nMaxHpRewardsPerDay = 10,
  nMonsterHpPercentRewardId = 2185,
  tbMonsterHpPercentRewards = {
    70,
    40,
    0
  },
  tbGatherBoxPos = {
    {2376, 7467},
    {2941, 6743},
    {3061, 7470},
    {2267, 6741},
    {2297, 7260},
    {2914, 7475},
    {2880, 6879},
    {3111, 7265},
    {2414, 6626},
    {2565, 6589},
    {2358, 6855},
    {2185, 6985},
    {2299, 7121},
    {2528, 6810},
    {2555, 7366},
    {2504, 7571},
    {2424, 7193},
    {2568, 7020},
    {2688, 6804},
    {2794, 6621},
    {3026, 7020},
    {3170, 6940},
    {2810, 7041},
    {2784, 7257},
    {2786, 7436},
    {2757, 7563},
    {2986, 7364},
    {3127, 6834},
    {3250, 7084},
    {3210, 7300}
  },
  nValuePerMember = 100000,
  tbAuctionSettings = {
    [3709] = {0.5, 1350000},
    [3714] = {0.5, 500000}
  },
  nMinJoinLevel = 20,
  nClearGatherBoxDelay = 60
}
Kin.GatherDef = {
  PrepareTime = 180,
  ActivityTime = 600,
  MaxExtraExpBuff = 200,
  MaxExtraMemberExpBuff = 150,
  DrinkCost = 60,
  DrinkReward = {
    {"Contrib", 300}
  },
  DrinkExpBuff = 5,
  FireNpcPosX = 5066,
  FireNpcPosY = 4252,
  FireNpcTemplateId = 516,
  DiceTimeOut = 50,
  DicePriceTime = 60,
  DiceOpenAnswerCount = 2,
  DicePricePercent = 0.2,
  WeekendDicePriceExtraPercent = 0.2,
  DicePriceMail = {
    To = nil,
    Title = "家族骰子奖励",
    Text = "恭喜少侠在家族烤火活动中获得骰子排名奖励，请查收附件奖励。",
    From = "家族系统",
    tbAttach = {
      {
        "item",
        1307,
        1
      }
    }
  },
  FirstQuestionTime = 120,
  QuestionAnwserTime = 74,
  NextQuestionTime = 1,
  QuizCount = 4,
  AutoSendRedBagTime = 5,
  AutoSendRedBagInterval = 30,
  AnswerWrongRewardContrib = 60,
  AnswerRightRewardContrib = 90,
  AnswerRightRewardItem = {
    "item",
    3103,
    1
  },
  WeekendExtraAnswerRate = 1,
  GatherJoinContribution = 10,
  KinPrestigeReward = {
    15,
    20,
    25,
    25,
    30,
    30,
    35,
    35,
    40,
    40,
    50,
    50,
    60
  },
  KinMaxPrestigeReward = 60,
  CurQuestionIdx = "nCurQuestionIdx",
  MemberNum = "nMemberNum",
  Quotiety = "nQuotiety",
  LastTime = "nLastTime",
  QuestionData = "tbQuestionData",
  QuestionOver = "bQuestionOver",
  DrinkFlag = "bDrink"
}
Kin.Task2Prestige = {
  [1] = 15,
  [51] = 5,
  [101] = 5,
  [151] = 5,
  [201] = 5,
  [251] = 5,
  [301] = 10,
  [351] = 10
}
Kin.Def.nRedBagMaxGrabPerDay = 50
Kin.Def.nRedBagPlayerGrabGrp = 97
Kin.Def.nRedBagPlayerGrabCount = 1
Kin.Def.nRedBagPlayerLastGrabTime = 2
Kin.tbRedBagEvents = {
  charge_count = 1,
  vip_level = 2,
  wsd_rank = 3,
  all_strength = 4,
  all_insert = 5,
  title = 6,
  newbie_king = 7,
  big_brother = 8,
  white_tiger_boss = 9,
  battle_rank = 10,
  battle_rank_cross = 34,
  battle_hundred = 37,
  battle_monthly = 45,
  leader_rank = 11,
  tower_floor = 12,
  tower_floor_monthly = 60,
  first_master = 13,
  top10_master = 14,
  good_master = 15,
  first_leader = 16,
  top10_leader = 17,
  good_leader = 18,
  buy_weekly_gift = 30,
  buy_weekly_suit = 61,
  buy_monthly_gift = 31,
  buy_invest_1 = 32,
  buy_invest_2 = 33,
  buy_invest_3 = 35,
  buy_invest_4 = 38,
  buy_invest_5 = 43,
  buy_invest_6 = 44,
  in_differ_battle = 36,
  new_year_gift_1 = 42,
  new_year_gift_2 = 41,
  new_year_gift_3 = 40,
  new_year_gift_4 = 39,
  qyh_win = 46,
  oneyear1 = 48,
  oneyear2 = 49,
  oneyear3 = 50,
  oneyear4 = 51,
  beauty_hx_1 = 52,
  beauty_g_hx_1 = 56,
  beauty_hx_10 = 53,
  beauty_hx_vote = 54,
  beauty_final_1 = 55,
  beauty_g_final_1 = 58,
  beauty_final_10 = 59,
  beauty_g_final_10 = 57,
  beauty_final_vote = 62,
  beauty_g_final_vote = 63,
  wldh_top1 = 65,
  wldh_top4 = 66,
  wldh_top16 = 67,
  wldh_elite = 68,
  wldh_g_top1 = 69,
  wldh_g_top4 = 70,
  summer_gift_1 = 71,
  summer_gift_2 = 72,
  summer_gift_3 = 73,
  summer_gift_4 = 74,
  travel_seller_1 = 75,
  travel_seller_2 = 76,
  travel_seller_3 = 77,
  travel_seller_4 = 78,
  travel_seller_5 = 79,
  travel_seller_6 = 80,
  travel_seller_7 = 81,
  travel_seller_8 = 82,
  travel_seller_9 = 83,
  travel_seller_10 = 84,
  travel_seller_11 = 85,
  wedding_1 = 90,
  wedding_2 = 91,
  wedding_3 = 92
}
Kin.tbRedBagBattleTypes = {
  BattleKill = Kin.tbRedBagEvents.battle_rank,
  BattleDota = Kin.tbRedBagEvents.battle_rank,
  BattleCross = Kin.tbRedBagEvents.battle_rank_cross,
  BattleHundred = Kin.tbRedBagEvents.battle_hundred,
  BattleMonth = Kin.tbRedBagEvents.battle_monthly
}
Kin.tbActivityCareerSalary = {
  [Kin.Def.Career_Master] = 6,
  [Kin.Def.Career_ViceMaster] = 3,
  [Kin.Def.Career_Elder] = 2,
  [Kin.Def.Career_Mascot] = 2
}
Kin.tbCareerNewTimeFrames = {
  OpenLevel49 = {35, 40},
  OpenLevel59 = {45, 50},
  OpenLevel69 = {55, 60},
  OpenLevel79 = {65, 70},
  OpenLevel89 = {75, 80},
  OpenLevel99 = {85, 90},
  OpenLevel109 = {95, 100},
  OpenLevel119 = {105, 110},
  OpenLevel129 = {115, 120}
}
Kin.Def.tbCareerProfitRate = {
  [Kin.Def.Career_Master] = 0.4,
  [Kin.Def.Career_ViceMaster] = 0.2,
  [Kin.Def.Career_Elder] = 0.1,
  [Kin.Def.Career_Mascot] = 0.05
}
Kin.Def.tbProfitRate = {
  {300010, 0.01},
  {200010, 0.02},
  {100010, 0.04},
  {0, 0.06}
}
Kin.Def.nSalaryCreateMinHours = 24
Kin.Def.nSalaryCareerMinHours = 24
Kin.Def.tbSalaryRedBagCfgs = {
  [Kin.Def.Career_Master] = {
    {10000, 46},
    {5000, 47},
    {2500, 48},
    {1000, 49}
  },
  [Kin.Def.Career_ViceMaster] = {
    {5000, 50},
    {2500, 51},
    {1250, 52},
    {500, 53}
  },
  [Kin.Def.Career_Elder] = {
    {2500, 54},
    {1250, 55},
    {625, 56}
  }
}
Kin.Def.tbExcludeAddContribLogReasons = {
  [Env.LogWay_ShopSell] = true
}
Kin.Def.tbVipRedBagMaxMulti = {
  {2, 2},
  {4, 3},
  {7, 6}
}
Kin.Def.tbForbiddenTitleNames = {}
Kin.Def.tbTitle2RedBagEvent = {
  [4000] = Kin.tbRedBagEvents.first_master,
  [4005] = Kin.tbRedBagEvents.top10_master,
  [4010] = Kin.tbRedBagEvents.good_master,
  [4015] = Kin.tbRedBagEvents.first_leader,
  [4016] = Kin.tbRedBagEvents.top10_leader,
  [4017] = Kin.tbRedBagEvents.good_leader
}
Kin.Def.nChangeNameItem = 2640
Kin.Def.bMascotClosed = false
Kin.Def.nCharge2Activity = 0.7
Kin.Def.nMaxChargeActiveGolds = 10000
Kin.Def.tbCareersOrder = {
  [Kin.Def.Career_Leader] = 1,
  [Kin.Def.Career_Master] = 2,
  [Kin.Def.Career_ViceMaster] = 3,
  [Kin.Def.Career_Elder] = 4,
  [Kin.Def.Career_Mascot] = 5,
  [Kin.Def.Career_Elite] = 6,
  [Kin.Def.Career_Normal] = 7,
  [Kin.Def.Career_New] = 8,
  [Kin.Def.Career_Retire] = 9
}
Kin.Def.nPushMailCD = 1206000
Kin.Def.tbJoinCD = {nDefault = 3600, nKickedOut = 3600}
