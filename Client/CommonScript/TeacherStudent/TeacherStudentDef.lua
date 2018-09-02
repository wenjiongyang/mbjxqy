TeacherStudent.Def = {
  tbTargetStates = {
    NotReport = 1,
    NotFinish = 2,
    Reported = 3,
    FinishedBefore = 4
  },
  TIME_DELAY = 600,
  nGiftMsgMax = 50,
  nTeacherDeclarationMax = 42,
  szTeacherNoticeDefault = "漫漫江湖路，我想找一个徒弟！",
  nForceDissmissTime = 604800,
  nForceGraduateTime = 604800,
  nDismissWaitTime = 86400,
  nMaxUndergraduate = 2,
  nMaxTeachers = 2,
  nDismissPunishTime = 86400,
  nGraduateDismissWaitTime = 1209600,
  nGraduateDismissCost = 1000,
  nAddStudentNoCdCount = 2,
  nAddStudentInterval = 604800,
  nGraduateConnectDaysMin = 14,
  nGraduateTargetMin = 50,
  nChuanGongTeacherExpBase = 30,
  nChuanGongRefreshOffset = 14400,
  nDailyChuanGongMax = 4,
  nFindTeacherListMax = 30,
  nFindStudentListMax = 30,
  nApplyListMax = 30,
  nGraduateDistance = 500,
  tbGraduateTeacherRewards = {
    {
      nMin = 50,
      szJudgement = "普通",
      szJudgement2 = "普通",
      tbAttach = {
        {"Renown", 5000}
      }
    },
    {
      nMin = 60,
      bEliteAchieve = true,
      szJudgement = "杰出",
      szJudgement2 = "顶级",
      tbAttach = {
        {"Renown", 10000}
      }
    }
  },
  tbGraduateStudentRewards = {
    {
      nMin = 50,
      szJudgement = "普通",
      szJudgement2 = "普通",
      tbAttach = {
        {
          "Item",
          2762,
          1
        }
      }
    },
    {
      nMin = 60,
      bEliteAchieve = true,
      szJudgement = "杰出",
      szJudgement2 = "顶级",
      tbAttach = {
        {
          "Item",
          2763,
          1
        }
      }
    }
  },
  nTargetProgressGroup = 106,
  nTitleGroup = 107,
  tbTitleIds = {
    6100,
    6101,
    6102,
    6103,
    6104
  },
  tbTargetTypeToIds = {
    OpenGoldBox = {1, 2},
    JoinKin = {3},
    BuyKinGift = {4, 5},
    KinDonate = {6, 7},
    KinSalary = {8, 9},
    DigGoods = {10, 11},
    BuyMarketStall = {12},
    SellMarketStall = {13},
    WashEquipFull1 = {14},
    WashEquipFull10 = {15},
    AllEquipCC = {16},
    AllEquipXY = {17},
    DailyTargetFull = {18, 19},
    OpenXiuLian = {20, 21},
    ChengEr = {22, 23},
    FuBenS = {24},
    FuBenSSS = {25},
    WuShenDian1500 = {26},
    WuShenDian500 = {27},
    ChallegeHero6 = {28},
    ChallegeHero10 = {29},
    MengZhu1500 = {30},
    MengZhu500 = {31},
    FieldBoss = {32},
    HistoryBoss = {33},
    CommerceTask = {34, 35},
    BattleField = {36, 37},
    KinPractice = {38, 39},
    AllEquipStrength20 = {40},
    AllEquipStrength30 = {41},
    AllEquipStrength40 = {42},
    EquipInsert1 = {43},
    EquipInsert2 = {44},
    EquipInsert3 = {45},
    EquipInsert4 = {46},
    FactionBattle = {47, 48},
    JingHongTitle = {49},
    LingYunTitle = {50},
    YuKongTitle = {51},
    QianLongTitle = {52},
    BuyCutOffWhite = {56, 57},
    BuyCutOffGreen = {58},
    Buy7DaysGift = {59},
    Buy30DaysGift = {60},
    BuyDailyGift = {61, 62},
    BuyInvestGift = {63},
    Vip6 = {64}
  },
  tbCustomTargetTypeToIds = {
    BattleField = {1},
    HistoryBoss = {2},
    Tower = {3},
    KinEscort = {4},
    FactionBattle = {5},
    FieldBoss = {6},
    KinPractice = {7},
    CityWar = {8},
    WhiteTiger = {9},
    MengZhu = {10},
    KinGather = {11},
    SoulGhost = {12},
    QinShiHuang = {13}
  },
  nMaxImityReportCount = 6,
  tbImityTargetsIdToLevels = {
    [53] = 10,
    [54] = 15,
    [55] = 20
  },
  tbCustomTaskRewards = {
    [1] = {500, 500},
    [2] = {750, 750},
    [3] = {1000, 1000},
    [4] = {1250, 1250},
    [5] = {1500, 1500},
    [6] = {2000, 2000},
    [7] = {2500, 2500},
    [8] = {3000, 3000}
  },
  nCustomTaskReportMin = 1,
  nCustomTaskCount = 8,
  nCustomTaskLvDiff = 1,
  nCustomTaskRemindCD = 600,
  nCustomTaskRewardTop = 2
}
