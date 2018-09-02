Require("CommonScript/KinBattle/KinBattleCommon.lua")
Require("CommonScript/Npc/NpcDefine.lua")
Require("CommonScript/EnvDef.lua")
Battle.ONLY_SIGNUP_TIME = 300
if MODULE_ZONESERVER then
  Battle.ONLY_SIGNUP_TIME = Battle.ONLY_SIGNUP_TIME + 60
end
Battle.NEXT_SIGNUP_TIME = 600
Battle.WIN_ADD_SCORE_PER = 1.2
Battle.SAVE_GROUP = 11
Battle.tbQualifyBattleOpemTime = {hour = 20, min = 25}
Battle.tbMinAward = {
  {
    "BattleHonor",
    300
  }
}
Battle.tbRevieBuff = {
  1008,
  1,
  5
}
Battle.STATE_TRANS = {
  {
    {
      nSeconds = 10,
      szFunc = "StartFight",
      szDesc = "准备阶段"
    },
    {
      nSeconds = 720,
      szFunc = "StopFight",
      szDesc = "战斗阶段"
    },
    {
      nSeconds = 10,
      szFunc = "CloseBattle",
      szDesc = "结算阶段"
    }
  },
  {
    {
      nSeconds = 5,
      szFunc = "StartFight",
      szDesc = "准备阶段"
    },
    {
      nSeconds = 180,
      szFunc = "StopFight",
      szDesc = "战斗阶段"
    },
    {
      nSeconds = 10,
      szFunc = "CloseBattle",
      szDesc = "结算阶段"
    }
  },
  {
    {
      nSeconds = 5,
      szFunc = "StartFight",
      szDesc = "准备阶段"
    },
    {
      nSeconds = 720,
      szFunc = "StopFight",
      szDesc = "战斗阶段"
    },
    {
      nSeconds = 10,
      szFunc = "CloseBattle",
      szDesc = "结算阶段"
    }
  },
  {
    {
      nSeconds = 10,
      szFunc = "StartFight",
      szDesc = "准备阶段"
    },
    {
      nSeconds = 720,
      szFunc = "StopFight",
      szDesc = "战斗阶段"
    },
    {
      nSeconds = 10,
      szFunc = "CloseBattle",
      szDesc = "结算阶段"
    }
  }
}
Battle.Second_StateTrans = {
  [2] = {
    [1] = {
      [3] = {
        szFunc = "ShowReadyInfo",
        szDesc = "提示倒计时"
      }
    },
    [2] = {
      [10] = {
        szFunc = "ShowMsg",
        tbParam = {
          "本场战场将在10秒后结束"
        },
        szDesc = "结束前倒计时"
      },
      [5] = {
        szFunc = "ShowMsg",
        tbParam = {
          "本场战场将在5秒后结束"
        },
        szDesc = "结束前倒计时"
      },
      [3] = {
        szFunc = "ShowMsg",
        tbParam = {
          "本场战场将在3秒后结束"
        },
        szDesc = "结束前倒计时"
      },
      [2] = {
        szFunc = "ShowMsg",
        tbParam = {
          "本场战场将在2秒后结束"
        },
        szDesc = "结束前倒计时"
      },
      [1] = {
        szFunc = "ShowMsg",
        tbParam = {
          "本场战场将在1秒后结束"
        },
        szDesc = "结束前倒计时"
      }
    }
  },
  [4] = {
    [1] = {
      [8] = {
        szFunc = "ShowReportUi",
        szDesc = "显示对阵图"
      },
      [7] = {
        szFunc = "ShowReportUi",
        szDesc = "显示对阵图"
      },
      [2] = {
        szFunc = "CloseReportUi",
        szDesc = "关闭对阵图"
      }
    },
    [2] = {
      [0] = {
        szFunc = "CloseReportUi",
        szDesc = "关闭对阵图"
      }
    }
  }
}
Battle.JOIN_TASK = 19
Battle.READY_MAP_ID = 1014
Battle.ZONE_READY_MAP_ID = 1055
Battle.READY_MAP_POS = {
  {2634, 5679},
  {2746, 4812},
  {6996, 6777},
  {7025, 4638}
}
Battle.tbAllBattleSetting = {
  BattleKill = {
    szName = "杀戮战场",
    nMapTemplateId = 1010,
    bCanLowerZone = true,
    nCalendarType = 1,
    nShowLevel = 1,
    nMinLevel = 24,
    nPlayerMinNum = 2,
    nPlayerMaxNum = 20,
    szLogicClass = "BattleKill",
    tbPos = {
      {
        {1386, 3594},
        {1968, 3625},
        {2308, 3213},
        {1875, 2888},
        {1391, 3172},
        {1772, 3290}
      },
      {
        {19107, 3630},
        {19627, 3650},
        {20091, 3295},
        {19972, 2796},
        {19112, 2822},
        {19488, 3218}
      }
    },
    tbPosBattle = {
      {
        {4679, 3822},
        {4431, 3213},
        {4937, 2608},
        {5600, 2626},
        {5523, 3163},
        {5501, 3745},
        {6101, 3781},
        {6204, 2734}
      },
      {
        {14898, 3641},
        {15467, 3682},
        {16225, 3767},
        {16585, 3402},
        {16622, 3055},
        {15949, 2599},
        {15385, 2310},
        {14830, 2874}
      }
    },
    tbAwardSetBig = "BattleAward1",
    tbAwardSetSmall = "BattleAward1",
    tbTeamNames = {"宋方", "金方"},
    tbInitDir = {18, 49},
    tbCamVal = {
      Npc.CampTypeDef.camp_type_song,
      Npc.CampTypeDef.camp_type_jin
    },
    nUseSchedule = 1,
    fileTrapBuff = "Setting/Battle/BattleKill/TrapBuff.tab",
    BACK_IN_CAMP_TIME = 30,
    nQualifyMinRank = 3,
    szQualifyBattleLogic = "BattleMonth",
    nMin_AWARD_SCORE = 100
  },
  BattleDota = {
    szName = "元帅保卫战场",
    nMapTemplateId = 1002,
    bCanLowerZone = true,
    nCalendarType = 1,
    nShowLevel = 1,
    nMinLevel = 24,
    nPlayerMinNum = 2,
    nPlayerMaxNum = 20,
    szLogicClass = "BattleDota",
    tbPos = {
      {
        {543, 6830},
        {583, 6428},
        {1014, 6225},
        {1227, 7142},
        {1024, 6676},
        {826, 7048},
        {1376, 6696},
        {717, 6626}
      },
      {
        {17481, 7028},
        {17476, 6701},
        {17476, 6334},
        {17902, 6706},
        {17887, 7058},
        {17887, 6259},
        {18304, 6929},
        {18309, 6567}
      }
    },
    tbPosBattle = {
      {
        {3688, 7643},
        {3901, 7226},
        {3851, 6611},
        {3831, 5798},
        {4605, 5228},
        {4516, 8144},
        {4555, 7559},
        {4615, 5917}
      },
      {
        {14039, 7916},
        {14842, 7876},
        {14817, 5714},
        {13935, 5624},
        {14773, 7251},
        {14783, 6572},
        {13359, 7881},
        {13225, 6076}
      }
    },
    tbAwardSetBig = "BattleAward1",
    tbAwardSetSmall = "BattleAward1",
    tbTeamNames = {"宋方", "金方"},
    tbNpcTimeFrame = {
      {
        "OpenLevel39",
        40
      },
      {"OpenDay10", 45},
      {
        "OpenLevel59",
        50
      }
    },
    tbInitDir = {18, 49},
    tbCamVal = {
      Npc.CampTypeDef.camp_type_song,
      Npc.CampTypeDef.camp_type_jin
    },
    nUseSchedule = 1,
    nNpcRefreshTime = 60,
    fileWildNpc = "Setting/Battle/Dota/WildNpcSetting.tab",
    fileMovePath = "Setting/Battle/Dota/MovePath.tab",
    BACK_IN_CAMP_TIME = 30,
    nQualifyMinRank = 3,
    szQualifyBattleLogic = "BattleMonth",
    nMin_AWARD_SCORE = 100
  },
  BattleCross = {
    szName = "跨服战场",
    bZone = true,
    bShowName = true,
    nShowLevel = 2,
    nCalendarType = 2,
    OpenTimeFrame = "OpenLevel79",
    nMapTemplateId = 1002,
    nPlayerMinNum = 2,
    nPlayerMaxNum = 60,
    szLogicClass = "BattleCross",
    tbPos = {
      {
        {543, 6830},
        {583, 6428},
        {1014, 6225},
        {1227, 7142},
        {1024, 6676},
        {826, 7048},
        {1376, 6696},
        {717, 6626}
      },
      {
        {17481, 7028},
        {17476, 6701},
        {17476, 6334},
        {17902, 6706},
        {17887, 7058},
        {17887, 6259},
        {18304, 6929},
        {18309, 6567}
      }
    },
    tbPosBattle = {
      {
        {3688, 7643},
        {3901, 7226},
        {3851, 6611},
        {3831, 5798},
        {4605, 5228},
        {4516, 8144},
        {4555, 7559},
        {4615, 5917}
      },
      {
        {14039, 7916},
        {14842, 7876},
        {14817, 5714},
        {13935, 5624},
        {14773, 7251},
        {14783, 6572},
        {13359, 7881},
        {13225, 6076}
      }
    },
    tbAwardSetBig = "BattleAwardCross",
    tbAwardSetSmall = "BattleAwardCross",
    tbTeamNames = {"宋方", "金方"},
    tbInitDir = {18, 49},
    tbCamVal = {
      Npc.CampTypeDef.camp_type_song,
      Npc.CampTypeDef.camp_type_jin
    },
    nUseSchedule = 1,
    fileTrapBuff = "Setting/Battle/BattleKill/TrapBuff.tab",
    BACK_IN_CAMP_TIME = 30,
    nQualifyMinRank = 10,
    szQualifyBattleLogic = "BattleMonth",
    nMin_AWARD_SCORE = 100
  },
  BattleHundred = {
    szName = "百人战场",
    bZone = true,
    bShowName = true,
    nShowLevel = 3,
    nCalendarType = 3,
    OpenTimeFrame = "OpenLevel79",
    nRealNeedLevel = 90,
    nMapTemplateId = 1002,
    nPlayerMinNum = 2,
    nPlayerMaxNum = 100,
    szLogicClass = "BattleHundred",
    tbPos = {
      {
        {543, 6830},
        {583, 6428},
        {1014, 6225},
        {1227, 7142},
        {1024, 6676},
        {826, 7048},
        {1376, 6696},
        {717, 6626}
      },
      {
        {17481, 7028},
        {17476, 6701},
        {17476, 6334},
        {17902, 6706},
        {17887, 7058},
        {17887, 6259},
        {18304, 6929},
        {18309, 6567}
      }
    },
    tbPosBattle = {
      {
        {3688, 7643},
        {3901, 7226},
        {3851, 6611},
        {3831, 5798},
        {4605, 5228},
        {4516, 8144},
        {4555, 7559},
        {4615, 5917}
      },
      {
        {14039, 7916},
        {14842, 7876},
        {14817, 5714},
        {13935, 5624},
        {14773, 7251},
        {14783, 6572},
        {13359, 7881},
        {13225, 6076}
      }
    },
    tbAwardSetBig = "BattleAwardHundred",
    tbAwardSetSmall = "BattleAwardHundred",
    tbTeamNames = {"宋方", "金方"},
    tbInitDir = {18, 49},
    tbCamVal = {
      Npc.CampTypeDef.camp_type_song,
      Npc.CampTypeDef.camp_type_jin
    },
    nUseSchedule = 1,
    BACK_IN_CAMP_TIME = 30,
    nQualifyMinRank = 20,
    szQualifyBattleLogic = "BattleMonth",
    nMin_AWARD_SCORE = 100
  },
  BattleMonth = {
    szName = "月度战场",
    bZone = true,
    bShowName = true,
    nShowLevel = 4,
    OpenTimeFrame = "OpenLevel109",
    nMapTemplateId = 1002,
    nPlayerMinNum = 2,
    nPlayerMaxNum = 40,
    szLogicClass = "BattleMonth",
    tbPos = {
      {
        {543, 6830},
        {583, 6428},
        {1014, 6225},
        {1227, 7142},
        {1024, 6676},
        {826, 7048},
        {1376, 6696},
        {717, 6626}
      },
      {
        {17481, 7028},
        {17476, 6701},
        {17476, 6334},
        {17902, 6706},
        {17887, 7058},
        {17887, 6259},
        {18304, 6929},
        {18309, 6567}
      }
    },
    tbPosBattle = {
      {
        {3688, 7643},
        {3901, 7226},
        {3851, 6611},
        {3831, 5798},
        {4605, 5228},
        {4516, 8144},
        {4555, 7559},
        {4615, 5917}
      },
      {
        {14039, 7916},
        {14842, 7876},
        {14817, 5714},
        {13935, 5624},
        {14773, 7251},
        {14783, 6572},
        {13359, 7881},
        {13225, 6076}
      }
    },
    tbAwardSetBig = "BattleAwardMonth",
    tbAwardSetSmall = "BattleAwardMonth",
    tbTeamNames = {"宋方", "金方"},
    tbInitDir = {18, 49},
    tbCamVal = {
      Npc.CampTypeDef.camp_type_song,
      Npc.CampTypeDef.camp_type_jin
    },
    nUseSchedule = 1,
    BACK_IN_CAMP_TIME = 30,
    nKeyQualifyTime = 5,
    nQualifyMinRank = 20,
    nQualifyTitleId = 216,
    szQUalifyNotifyMsg = "恭喜您获得下个月的月度战场资格",
    szQualifyType = "Month",
    szQualifyBattleLogic = "BattleSeason",
    fnGetQualifyMatchTime = "GetQualifyMatchTimeMonth",
    ChechConditionFunc = "IsQualifyInMonthBattle",
    tbRankNotify = {
      {
        nRankEnd = 1,
        szKinNotify = "恭喜本家族的%s获得了月度战场的第%d名",
        szWorldNotify = "恭喜%s获得了月度战场的第%d名"
      },
      {
        nRankEnd = 3,
        szKinNotify = "恭喜本家族的%s获得了月度战场的第%d名"
      }
    }
  },
  BattleSeason = {
    szName = "季度战场",
    bZone = true,
    bShowName = true,
    nShowLevel = 5,
    OpenTimeFrame = "OpenLevel109",
    nMapTemplateId = 1002,
    nPlayerMinNum = 2,
    nPlayerMaxNum = 60,
    szLogicClass = "BattleSeason",
    tbPos = {
      {
        {543, 6830},
        {583, 6428},
        {1014, 6225},
        {1227, 7142},
        {1024, 6676},
        {826, 7048},
        {1376, 6696},
        {717, 6626}
      },
      {
        {17481, 7028},
        {17476, 6701},
        {17476, 6334},
        {17902, 6706},
        {17887, 7058},
        {17887, 6259},
        {18304, 6929},
        {18309, 6567}
      }
    },
    tbPosBattle = {
      {
        {3688, 7643},
        {3901, 7226},
        {3851, 6611},
        {3831, 5798},
        {4605, 5228},
        {4516, 8144},
        {4555, 7559},
        {4615, 5917}
      },
      {
        {14039, 7916},
        {14842, 7876},
        {14817, 5714},
        {13935, 5624},
        {14773, 7251},
        {14783, 6572},
        {13359, 7881},
        {13225, 6076}
      }
    },
    tbAwardSetBig = "BattleAwardHundred",
    tbAwardSetSmall = "BattleAwardHundred",
    tbTeamNames = {"宋方", "金方"},
    tbInitDir = {18, 49},
    tbCamVal = {
      Npc.CampTypeDef.camp_type_song,
      Npc.CampTypeDef.camp_type_jin
    },
    nUseSchedule = 1,
    BACK_IN_CAMP_TIME = 30,
    nKeyQualifyTime = 6,
    nQualifyMinRank = 20,
    nQualifyTitleId = 217,
    szQUalifyNotifyMsg = "恭喜您获得本季度的季度战场资格",
    szQualifyType = "Season",
    szQualifyBattleLogic = "BattleYear",
    fnGetQualifyMatchTime = "GetQualifyMatchTimeSeason",
    ChechConditionFunc = "IsQualifyInSeasonBattle",
    tbRankNotify = {
      {
        nRankEnd = 1,
        szKinNotify = "恭喜%s获得了月度战场的第%d名",
        szWorldNotify = "恭喜%s获得了月度战场的第%d名"
      },
      {
        nRankEnd = 3,
        szKinNotify = "恭喜%s获得了月度战场的第%d名"
      }
    }
  },
  BattleYear = {
    szName = "年度战场",
    bZone = true,
    bShowName = true,
    nShowLevel = 6,
    OpenTimeFrame = "OpenLevel109",
    nMapTemplateId = 1002,
    nPlayerMinNum = 2,
    nPlayerMaxNum = 100,
    szLogicClass = "BattleYear",
    tbPos = {
      {
        {543, 6830},
        {583, 6428},
        {1014, 6225},
        {1227, 7142},
        {1024, 6676},
        {826, 7048},
        {1376, 6696},
        {717, 6626}
      },
      {
        {17481, 7028},
        {17476, 6701},
        {17476, 6334},
        {17902, 6706},
        {17887, 7058},
        {17887, 6259},
        {18304, 6929},
        {18309, 6567}
      }
    },
    tbPosBattle = {
      {
        {3688, 7643},
        {3901, 7226},
        {3851, 6611},
        {3831, 5798},
        {4605, 5228},
        {4516, 8144},
        {4555, 7559},
        {4615, 5917}
      },
      {
        {14039, 7916},
        {14842, 7876},
        {14817, 5714},
        {13935, 5624},
        {14773, 7251},
        {14783, 6572},
        {13359, 7881},
        {13225, 6076}
      }
    },
    tbAwardSetBig = "BattleAwardHundred",
    tbAwardSetSmall = "BattleAwardHundred",
    tbTeamNames = {"宋方", "金方"},
    tbInitDir = {18, 49},
    tbCamVal = {
      Npc.CampTypeDef.camp_type_song,
      Npc.CampTypeDef.camp_type_jin
    },
    nUseSchedule = 1,
    BACK_IN_CAMP_TIME = 30,
    nKeyQualifyTime = 7,
    nQualifyTitleId = 218,
    szQUalifyNotifyMsg = "恭喜您获得明年一月份的年度战场资格",
    szQualifyType = "Year",
    fnGetQualifyMatchTime = "GetQualifyMatchTimeYear",
    ChechConditionFunc = "IsQualifyInYearBattle",
    tbRankNotify = {
      {
        nRankEnd = 1,
        szKinNotify = "恭喜本家族的%s获得了月度战场的第%d名",
        szWorldNotify = "恭喜%s获得了月度战场的第%d名"
      },
      {
        nRankEnd = 3,
        szKinNotify = "恭喜本家族的%s获得了月度战场的第%d名"
      }
    }
  },
  BattleMoba = {
    szName = "宋金攻防战",
    nShowLevel = 4,
    bShowName = true,
    OpenTimeFrame = "OpenLevel99",
    nMapTemplateId = 1060,
    nPlayerMinNum = 2,
    nPlayerMaxNum = 20,
    nMinLevel = 20,
    szLogicClass = "BattleMoba",
    tbPos = {
      {
        {3335, 8577},
        {3348, 8307},
        {3650, 8572},
        {3642, 8304},
        {3907, 8559},
        {3901, 8302}
      },
      {
        {18636, 8543},
        {18641, 8307},
        {18980, 8593},
        {18986, 8278},
        {19340, 8572},
        {19325, 8275}
      }
    },
    tbPosBattle = {
      {
        {5181, 8663},
        {5190, 8390},
        {5160, 8077}
      },
      {
        {17461, 8741},
        {17454, 8467},
        {17445, 8102}
      }
    },
    tbAward = {
      [Env.LogRound_SUCCESS] = {
        {"BasicExp", 80},
        {
          "Item",
          6110,
          2
        }
      },
      [Env.LogRound_FAIL] = {
        {"BasicExp", 60},
        {
          "Item",
          6111,
          2
        }
      }
    },
    tbAwardMsg = {
      [Env.LogRound_SUCCESS] = "    恭喜，本次阵营攻防战中，本方[FFFE0D]（%s）[-]获胜！附件是%s后勤准备的些许奖励，以资鼓励！",
      [Env.LogRound_FAIL] = "    很遗憾，本次阵营攻防战中，本方[FFFE0D]（%s）[-]惜败！附件是%s后勤准备的些许奖励，以资鼓励！"
    },
    tbTeamNames = {"宋方", "金方"},
    tbInitDir = {18, 49},
    tbCamVal = {
      Npc.CampTypeDef.camp_type_song,
      Npc.CampTypeDef.camp_type_jin
    },
    nUseSchedule = 4,
    BACK_IN_CAMP_TIME = 30,
    fileMovePath = "Setting/Battle/Camp/MovePath.tab"
  },
  BattleAlone = {
    szLogicClass = "BattleAlone",
    nShowLevel = 0,
    szName = "新手战场",
    nMapTemplateId = 1020,
    tbPos = {
      {
        {1281, 3232},
        {1347, 3519},
        {1289, 2862},
        {1632, 3211},
        {1539, 3466},
        {1498, 2850}
      },
      {
        {9980, 3211},
        {9912, 3396},
        {9546, 3379},
        {9552, 3211},
        {9627, 2920},
        {9918, 2908}
      }
    },
    tbTeamNames = {"宋方", "金方"},
    tbCamVal = {
      Npc.CampTypeDef.camp_type_song,
      Npc.CampTypeDef.camp_type_jin
    },
    nUseSchedule = 2,
    nUseScheduleSecond = 1,
    nOpenDialogId = 30001,
    nNpcRefreshTime = 120,
    nSideNum = 6,
    nFakeAttriId = 101,
    tbHomeBuildingId = {670, 671},
    tbMovePathIndex = {
      {
        3,
        4,
        5
      },
      {
        6,
        7,
        8
      }
    },
    tbFactionBuff = {
      [1] = 1711,
      [2] = 1712,
      [3] = 1713,
      [4] = 1714,
      [5] = 1715,
      [6] = 1716,
      [7] = 1734,
      [8] = 1735,
      [9] = 1736,
      [10] = 1737,
      [11] = 1738,
      [12] = 1739,
      [13] = 1740,
      [14] = 1741
    },
    tbBornBuff = {1708, 1},
    nMeLevel = 30,
    nHimLevel = 29,
    fileWildNpc = "Setting/Battle/DotaClient/WildNpcSettingClient.tab",
    fileMovePath = "Setting/Battle/DotaClient/MovePathClient.tab",
    BACK_IN_CAMP_TIME = 2
  },
  KinBattle = {
    nUseSchedule = 3,
    nMapTemplateId = KinBattle.FIGHT_MAP_ID,
    tbPos = {
      {
        KinBattle.tbFightMapBeginPoint[1]
      },
      {
        KinBattle.tbFightMapBeginPoint[2]
      }
    },
    nNpcRefreshTime = KinBattle.nNpcRefreshTime,
    fileCommNpc = KinBattle.fileCommNpc,
    fileWildNpc = KinBattle.fileWildNpc,
    fileMovePath = KinBattle.fileMovePath,
    BACK_IN_CAMP_TIME = 10
  }
}
Battle.tbMapSetting = {
  Battle.tbAllBattleSetting.BattleKill,
  Battle.tbAllBattleSetting.BattleDota,
  Battle.tbAllBattleSetting.BattleCross,
  Battle.tbAllBattleSetting.BattleHundred,
  Battle.tbAllBattleSetting.BattleMonth,
  Battle.tbAllBattleSetting.BattleSeason,
  Battle.tbAllBattleSetting.BattleYear,
  Battle.tbAllBattleSetting.BattleMoba
}
Battle.tbZoneSignupSetting = {
  {
    TimeFrame = "OpenLevel59",
    nMaxLevel = 45,
    nMaxFightPower = 50000
  },
  {
    TimeFrame = "OpenLevel69",
    nMaxLevel = 55,
    nMaxFightPower = 100000
  },
  {
    TimeFrame = "OpenLevel79",
    nMaxLevel = 65,
    nMaxFightPower = 200000
  },
  {
    TimeFrame = "OpenLevel89",
    nMaxLevel = 75,
    nMaxFightPower = 400000
  },
  {
    TimeFrame = "OpenLevel99",
    nMaxLevel = 85,
    nMaxFightPower = 800000
  },
  {
    TimeFrame = "OpenLevel109",
    nMaxLevel = 95,
    nMaxFightPower = 1000000
  },
  {
    TimeFrame = "OpenLevel119",
    nMaxLevel = 105,
    nMaxFightPower = 1500000
  },
  {
    TimeFrame = "OpenLevel129",
    nMaxLevel = 115,
    nMaxFightPower = 2000000
  }
}
Battle.OpenLowZoneBattleTimeFrame = Battle.tbZoneSignupSetting[1].TimeFrame
Battle.tbZoneLevelSetting = {
  {
    nLevelFrom = 20,
    nLevelEnd = 39,
    nBattleModeIndex = 2
  },
  {
    nLevelFrom = 40,
    nLevelEnd = 49,
    nBattleModeIndex = 2
  },
  {nLevelFrom = 50, nLevelEnd = 59},
  {nLevelFrom = 60, nLevelEnd = 69},
  {nLevelFrom = 70, nLevelEnd = 79},
  {nLevelFrom = 80, nLevelEnd = 89},
  {nLevelFrom = 90, nLevelEnd = 99},
  {nLevelFrom = 100, nLevelEnd = 109},
  {nLevelFrom = 110, nLevelEnd = 119},
  {nLevelFrom = 120, nLevelEnd = 129}
}
Battle.tbHighZoneLevelSetting = {
  {
    nLevelFrom = 1,
    nLevelEnd = 39,
    nBattleModeIndex = 3
  },
  {
    nLevelFrom = 40,
    nLevelEnd = 49,
    nBattleModeIndex = 3
  },
  {
    nLevelFrom = 50,
    nLevelEnd = 59,
    nBattleModeIndex = 3
  },
  {
    nLevelFrom = 60,
    nLevelEnd = 69,
    nBattleModeIndex = 3
  },
  {
    nLevelFrom = 70,
    nLevelEnd = 79,
    nBattleModeIndex = 3
  },
  {
    nLevelFrom = 80,
    nLevelEnd = 89,
    nBattleModeIndex = 3
  },
  {nLevelFrom = 90, nLevelEnd = 129}
}
Battle.tbTitleLevelSet = {
  {
    nNeedScore = 0,
    tbTitleID = {210, 219},
    nKillAddScore = 50
  },
  {
    nNeedScore = 200,
    tbTitleID = {211, 220},
    nKillAddScore = 70
  },
  {
    nNeedScore = 500,
    tbTitleID = {212, 221},
    nKillAddScore = 100
  },
  {
    nNeedScore = 1000,
    tbTitleID = {213, 222},
    nKillAddScore = 150
  },
  {
    nNeedScore = 2000,
    tbTitleID = {214, 223},
    nKillAddScore = 200
  },
  {
    nNeedScore = 3000,
    tbTitleID = {215, 224},
    nKillAddScore = 300
  }
}
Battle.tbComboLevelSet = {
  {nComboCount = 0},
  {
    nComboCount = 3,
    szKilledNotify = "%s终结了%s的勇冠三军",
    szNotify = "%s已经勇冠三军！"
  },
  {
    nComboCount = 5,
    szKilledNotify = "%s终结了%s的接近暴走",
    szNotify = "%s已经接近暴走！"
  },
  {
    nComboCount = 10,
    szKilledNotify = "%s终结了%s的无人可挡",
    szNotify = "%s已经无人可挡！"
  },
  {
    nComboCount = 15,
    szKilledNotify = "%s终结了%s的主宰比赛",
    szNotify = "%s已经主宰比赛！"
  },
  {
    nComboCount = 20,
    szKilledNotify = "%s终结了%s的接近神",
    szNotify = "%s已经接近神了！"
  },
  {
    nComboCount = 30,
    szKilledNotify = "%s终结了%s的超神",
    szNotify = "%s已经超神！"
  }
}
Battle.tbAllAwardSet = {
  tbExChangeBoxInfo = {
    {
      4687,
      1000,
      "黄金宝箱"
    },
    {
      4687,
      500,
      "白银宝箱"
    }
  },
  tbExtRandomAward = {
    {
      "OpenLevel69",
      3080,
      0.3
    },
    {
      "OpenLevel49",
      3080,
      0.2
    }
  },
  BattleAward1 = {
    {
      nRandEnd = 1,
      Award = {
        {"BasicExp", 80},
        {
          "BattleHonor",
          20000
        }
      }
    },
    {
      nRandEnd = 2,
      Award = {
        {"BasicExp", 76},
        {
          "BattleHonor",
          15000
        }
      }
    },
    {
      nRandEnd = 5,
      Award = {
        {"BasicExp", 72},
        {
          "BattleHonor",
          12000
        }
      }
    },
    {
      nRandEnd = 10,
      Award = {
        {"BasicExp", 68},
        {
          "BattleHonor",
          10000
        }
      }
    },
    {
      nRandEnd = 15,
      Award = {
        {"BasicExp", 64},
        {
          "BattleHonor",
          9000
        }
      }
    },
    {
      nRandEnd = 20,
      Award = {
        {"BasicExp", 60},
        {
          "BattleHonor",
          8500
        }
      }
    },
    {
      nRandEnd = 25,
      Award = {
        {"BasicExp", 58},
        {
          "BattleHonor",
          8000
        }
      }
    },
    {
      nRandEnd = 30,
      Award = {
        {"BasicExp", 56},
        {
          "BattleHonor",
          7500
        }
      }
    },
    {
      nRandEnd = 35,
      Award = {
        {"BasicExp", 52},
        {
          "BattleHonor",
          7000
        }
      }
    },
    {
      nRandEnd = 40,
      Award = {
        {"BasicExp", 48},
        {
          "BattleHonor",
          6500
        }
      }
    }
  },
  BattleAwardCross = {
    {
      nRandEnd = 1,
      Award = {
        {"BasicExp", 80},
        {
          "BattleHonor",
          30000
        }
      }
    },
    {
      nRandEnd = 2,
      Award = {
        {"BasicExp", 76},
        {
          "BattleHonor",
          25000
        }
      }
    },
    {
      nRandEnd = 5,
      Award = {
        {"BasicExp", 72},
        {
          "BattleHonor",
          20000
        }
      }
    },
    {
      nRandEnd = 10,
      Award = {
        {"BasicExp", 70},
        {
          "BattleHonor",
          16000
        }
      }
    },
    {
      nRandEnd = 15,
      Award = {
        {"BasicExp", 68},
        {
          "BattleHonor",
          14000
        }
      }
    },
    {
      nRandEnd = 20,
      Award = {
        {"BasicExp", 66},
        {
          "BattleHonor",
          13000
        }
      }
    },
    {
      nRandEnd = 25,
      Award = {
        {"BasicExp", 64},
        {
          "BattleHonor",
          12000
        }
      }
    },
    {
      nRandEnd = 30,
      Award = {
        {"BasicExp", 62},
        {
          "BattleHonor",
          11000
        }
      }
    },
    {
      nRandEnd = 35,
      Award = {
        {"BasicExp", 60},
        {
          "BattleHonor",
          10000
        }
      }
    },
    {
      nRandEnd = 40,
      Award = {
        {"BasicExp", 58},
        {
          "BattleHonor",
          9500
        }
      }
    },
    {
      nRandEnd = 45,
      Award = {
        {"BasicExp", 56},
        {
          "BattleHonor",
          9000
        }
      }
    },
    {
      nRandEnd = 50,
      Award = {
        {"BasicExp", 54},
        {
          "BattleHonor",
          8500
        }
      }
    },
    {
      nRandEnd = 55,
      Award = {
        {"BasicExp", 52},
        {
          "BattleHonor",
          8000
        }
      }
    },
    {
      nRandEnd = 60,
      Award = {
        {"BasicExp", 50},
        {
          "BattleHonor",
          7500
        }
      }
    }
  },
  BattleAwardHundred = {
    {
      nRandEnd = 1,
      Award = {
        {"BasicExp", 80},
        {
          "BattleHonor",
          40000
        }
      }
    },
    {
      nRandEnd = 2,
      Award = {
        {"BasicExp", 78},
        {
          "BattleHonor",
          35000
        }
      }
    },
    {
      nRandEnd = 5,
      Award = {
        {"BasicExp", 76},
        {
          "BattleHonor",
          30000
        }
      }
    },
    {
      nRandEnd = 10,
      Award = {
        {"BasicExp", 74},
        {
          "BattleHonor",
          25000
        }
      }
    },
    {
      nRandEnd = 15,
      Award = {
        {"BasicExp", 72},
        {
          "BattleHonor",
          20000
        }
      }
    },
    {
      nRandEnd = 20,
      Award = {
        {"BasicExp", 70},
        {
          "BattleHonor",
          18000
        }
      }
    },
    {
      nRandEnd = 30,
      Award = {
        {"BasicExp", 68},
        {
          "BattleHonor",
          16000
        }
      }
    },
    {
      nRandEnd = 40,
      Award = {
        {"BasicExp", 66},
        {
          "BattleHonor",
          14000
        }
      }
    },
    {
      nRandEnd = 50,
      Award = {
        {"BasicExp", 64},
        {
          "BattleHonor",
          13000
        }
      }
    },
    {
      nRandEnd = 60,
      Award = {
        {"BasicExp", 62},
        {
          "BattleHonor",
          12000
        }
      }
    },
    {
      nRandEnd = 70,
      Award = {
        {"BasicExp", 60},
        {
          "BattleHonor",
          11000
        }
      }
    },
    {
      nRandEnd = 80,
      Award = {
        {"BasicExp", 58},
        {
          "BattleHonor",
          10000
        }
      }
    },
    {
      nRandEnd = 90,
      Award = {
        {"BasicExp", 54},
        {
          "BattleHonor",
          9000
        }
      }
    },
    {
      nRandEnd = 100,
      Award = {
        {"BasicExp", 50},
        {
          "BattleHonor",
          8000
        }
      }
    }
  },
  BattleAwardMonth = {
    {
      nRandEnd = 1,
      Award = {
        {"BasicExp", 80},
        {"Energy", 100000}
      }
    },
    {
      nRandEnd = 2,
      Award = {
        {"BasicExp", 78},
        {"Energy", 85000}
      }
    },
    {
      nRandEnd = 5,
      Award = {
        {"BasicExp", 76},
        {"Energy", 70000}
      }
    },
    {
      nRandEnd = 10,
      Award = {
        {"BasicExp", 74},
        {"Energy", 60000}
      }
    },
    {
      nRandEnd = 15,
      Award = {
        {"BasicExp", 72},
        {"Energy", 50000}
      }
    },
    {
      nRandEnd = 20,
      Award = {
        {"BasicExp", 70},
        {"Energy", 40000}
      }
    },
    {
      nRandEnd = 25,
      Award = {
        {"BasicExp", 68},
        {"Energy", 30000}
      }
    },
    {
      nRandEnd = 30,
      Award = {
        {"BasicExp", 66},
        {"Energy", 25000}
      }
    },
    {
      nRandEnd = 35,
      Award = {
        {"BasicExp", 64},
        {"Energy", 20000}
      }
    },
    {
      nRandEnd = 40,
      Award = {
        {"BasicExp", 62},
        {"Energy", 16000}
      }
    }
  }
}
Battle.tbTimeFrameAward = {}
local tbLegalMap = {
  1,
  2,
  3,
  4,
  5,
  6,
  7,
  8,
  9,
  10,
  999,
  Battle.READY_MAP_ID,
  Battle.ZONE_READY_MAP_ID
}
Battle.LegalMap = {}
local function fnSetIndex()
  for i, v in ipairs(Battle.tbMapSetting) do
    v.nIndex = i
    assert(v.szName, i)
    assert(v.nMapTemplateId, i)
    assert(v.nPlayerMinNum, i)
    assert(1 <= #v.tbPos[1], i)
    assert(1 <= #v.tbPos[2], i)
    for _, tbAwardSet in ipairs({
      "tbAwardSetBig",
      "tbAwardSetSmall"
    }) do
      local tbAwardDesc = v[tbAwardSet]
      if tbAwardDesc then
        if Battle.tbTimeFrameAward[tbAwardDesc] then
          for i2, _ in ipairs(Battle.tbTimeFrameAward[tbAwardDesc]) do
            assert(Battle.tbAllAwardSet[tbAwardDesc .. "_" .. i2], tbAwardSet .. ":" .. i .. " and " .. i2)
          end
        else
          assert(Battle.tbAllAwardSet[tbAwardDesc], i)
        end
      end
    end
  end
  for i, v in ipairs(tbLegalMap) do
    Battle.LegalMap[v] = 1
  end
  local szExchangeTip = ""
  local tbExChangeBoxInfo = Battle.tbAllAwardSet.tbExChangeBoxInfo
  for i, v in ipairs(tbExChangeBoxInfo) do
    szExchangeTip = szExchangeTip .. string.format(", 每%d荣誉兑换1个%s", v[2], v[3])
  end
  szExchangeTip = string.sub(szExchangeTip, 2)
  Battle.szBoxExchangeTip = szExchangeTip
end
fnSetIndex()
function Battle:CheckCanSignUp(pPlayer, tbBattleSetting)
  if self.LegalMap[pPlayer.nMapTemplateId] ~= 1 and (Map:GetClassDesc(pPlayer.nMapTemplateId) ~= "fight" or pPlayer.nFightMode ~= 0) then
    return false, "您当前所在地不能被传入战场"
  end
  if tbBattleSetting and not tbBattleSetting.nQualifyTitleId and 1 > DegreeCtrl:GetDegree(pPlayer, "Battle") then
    if not MODULE_GAMESERVER then
      local nBuyDegree = DegreeCtrl:GetDegree(pPlayer, "BattleBuy")
      if nBuyDegree > 0 then
        do
          local nBuyCount = math.min(5, nBuyDegree)
          local function fnConfirmBuy()
            local szBuyDegree, szMoneyType, nCost = DegreeCtrl:BuyCountCostPrice(me, "Battle", nBuyCount)
            if nCost > me.GetMoney(szMoneyType) then
              me.CenterMsg(string.format("您的%s不足%d", Shop.tbMoney[szMoneyType].Name, nCost))
              return 0
            end
            RemoteServer.BuyCount("Battle", nBuyCount)
          end
          Ui:OpenWindow("MessageBox", string.format("次数不足，确定购买 [FFFE0D]%d次[-] 次数吗", nBuyCount), {
            {fnConfirmBuy}
          }, {"确定", "取消"})
        end
      end
    end
    return false, "您的次数不足"
  end
  return true
end
function Battle:GetRandInitPos(nTeamIndex, tbBattleSetting)
  local tbPos = tbBattleSetting.tbPos[nTeamIndex]
  return tbPos[MathRandom(#tbPos)]
end
function Battle:GetAward(nRank, nScore, tbAwardSet, nMinScore)
  local tbAward = {}
  if nScore and nMinScore and nScore <= nMinScore then
    return Lib:MergeTable(tbAward, Battle.tbMinAward)
  end
  for i, v in ipairs(tbAwardSet) do
    if nRank <= v.nRandEnd then
      return Lib:MergeTable(tbAward, v.Award)
    end
  end
  return tbAward
end
function Battle:Honor2Box(dwRoleId, nGetHonor, tbAwardList)
  local nCurHonor = 0
  local nBoxCount = 0
  local nLeftHonor = 0
  if not tbAwardList then
    return nCurHonor, nBoxCount, nLeftHonor
  end
  local pAsync = KPlayer.GetAsyncData(dwRoleId)
  if not pAsync then
    return nCurHonor, nBoxCount, nLeftHonor
  end
  nCurHonor = pAsync.GetBattleHonor()
  nLeftHonor = nCurHonor + nGetHonor
  local tbExChangeBoxInfo = Battle.tbAllAwardSet.tbExChangeBoxInfo
  for _, v in ipairs(tbExChangeBoxInfo) do
    local nCanChangeNum = math.floor(nLeftHonor / v[2])
    if nCanChangeNum > 0 then
      local nCostHonor = nCanChangeNum * v[2]
      nLeftHonor = nLeftHonor - nCostHonor
      table.insert(tbAwardList, {
        "item",
        v[1],
        nCanChangeNum
      })
      nBoxCount = nBoxCount + nCanChangeNum
    end
  end
  return nCurHonor, nBoxCount, nLeftHonor
end
function Battle:GetCanSignLowZoneBattle(pPlayer)
  for i2 = #self.tbZoneSignupSetting, 1, -1 do
    local v2 = self.tbZoneSignupSetting[i2]
    if GetTimeFrameState(v2.TimeFrame) == 1 then
      if pPlayer.nLevel <= v2.nMaxLevel and pPlayer.GetFightPower() <= v2.nMaxFightPower then
        return true
      end
      break
    end
  end
end
function Battle:IsQualifyBattleByType(pPlayer, szType, bNotNext)
  local tbSetting = Battle.tbAllBattleSetting[szType]
  if not tbSetting then
    return
  end
  local fnFunc = self[tbSetting.ChechConditionFunc]
  if not fnFunc then
    return
  end
  return fnFunc(self, pPlayer, not bNotNext)
end
function Battle:IsQualifyInMonthBattle(pPlayer, bNext)
  local nNowQualifyTime = pPlayer.GetUserValue(self.SAVE_GROUP, self.tbAllBattleSetting.BattleMonth.nKeyQualifyTime)
  if nNowQualifyTime == 0 then
    return false
  end
  local nCurOpenBattleTime = Battle:GetQualifyMatchTimeMonth(bNext)
  return Lib:GetLocalDay(nNowQualifyTime) == Lib:GetLocalDay(nCurOpenBattleTime)
end
function Battle:IsQualifyInSeasonBattle(pPlayer)
  local nNowQualifyTime = pPlayer.GetUserValue(self.SAVE_GROUP, self.tbAllBattleSetting.BattleSeason.nKeyQualifyTime)
  if nNowQualifyTime == 0 then
    return false
  end
  local nCurOpenBattleTime = Battle:GetQualifyMatchTimeSeason()
  return Lib:GetLocalDay(nNowQualifyTime) == Lib:GetLocalDay(nCurOpenBattleTime)
end
function Battle:IsQualifyInYearBattle(pPlayer, bNext)
  local nNowQualifyTime = pPlayer.GetUserValue(self.SAVE_GROUP, self.tbAllBattleSetting.BattleYear.nKeyQualifyTime)
  if nNowQualifyTime == 0 then
    return false
  end
  local nCurOpenBattleTime = Battle:GetQualifyMatchTimeYear(bNext)
  return Lib:GetLocalDay(nNowQualifyTime) == Lib:GetLocalDay(nCurOpenBattleTime)
end
function Battle:GetQualifyMatchTimeMonth(bNext)
  local nNow = GetTime()
  if not bNext then
    nNow = nNow - 4800
  end
  if not self.nCahcheMatchTimeMonth then
    local tbTimeNow = os.date("*t", nNow)
    local tbOpemTime = self.tbQualifyBattleOpemTime
    local nSec = os.time({
      year = tbTimeNow.year,
      month = tbTimeNow.month,
      day = 1,
      hour = tbOpemTime.hour,
      min = tbOpemTime.min,
      sec = 0
    })
    local nNewSec = 0
    for i2 = 0, 6 do
      nNewSec = nSec + 86400 * i2
      local tbToTime = os.date("*t", nNewSec)
      if tbToTime.wday == 1 then
        self.nCahcheMatchTimeMonth = nNewSec
        break
      end
    end
    local nSec = os.time({
      year = tbTimeNow.year,
      month = tbTimeNow.month + 1,
      day = 1,
      hour = tbOpemTime.hour,
      min = tbOpemTime.min,
      sec = 0
    })
    local nNewSec = 0
    for i2 = 0, 6 do
      nNewSec = nSec + 86400 * i2
      local tbToTime = os.date("*t", nNewSec)
      if tbToTime.wday == 1 then
        self.nCahcheMatchTimeMonthNext = nNewSec
        break
      end
    end
  end
  if nNow > self.nCahcheMatchTimeMonth then
    return self.nCahcheMatchTimeMonthNext
  else
    return self.nCahcheMatchTimeMonth
  end
end
function Battle:GetQualifyMatchTimeSeason()
  if self.nCahcheMatchTimeSeason then
    return self.nCahcheMatchTimeSeason
  end
  local tbTimeNow = os.date("*t", GetTime())
  local nSeason = math.ceil(tbTimeNow.month / 3)
  if tbTimeNow.year == 2017 and nSeason == 2 then
    nSeason = 3
  end
  local tbOpemTime = self.tbQualifyBattleOpemTime
  local nSec = os.time({
    year = tbTimeNow.year,
    month = nSeason * 3 + 1,
    day = 1,
    hour = tbOpemTime.hour,
    min = tbOpemTime.min,
    sec = 0
  })
  nSec = nSec - 86400
  local nNewSec = 0
  for i2 = 0, 6 do
    nNewSec = nSec - 86400 * i2
    local tbToTime = os.date("*t", nNewSec)
    if tbToTime.wday == 1 then
      self.nCahcheMatchTimeSeason = nNewSec
      return nNewSec
    end
  end
end
function Battle:GetQualifyMatchTimeYear(bNext)
  local nNow = GetTime()
  if not bNext then
    nNow = nNow - 4800
  end
  if not self.nCahcheMatchTimeYear then
    local tbTimeNow = os.date("*t", nNow)
    local tbOpemTime = self.tbQualifyBattleOpemTime
    local nSec = os.time({
      year = tbTimeNow.year,
      month = 2,
      day = 1,
      hour = tbOpemTime.hour,
      min = tbOpemTime.min,
      sec = 0
    })
    nSec = nSec - 86400
    local nNewSec = 0
    for i2 = 0, 6 do
      nNewSec = nSec - 86400 * i2
      local tbToTime = os.date("*t", nNewSec)
      if tbToTime.wday == 1 then
        self.nCahcheMatchTimeYear = nNewSec
        break
      end
    end
    local nSec = os.time({
      year = tbTimeNow.year + 1,
      month = 2,
      day = 1,
      hour = tbOpemTime.hour,
      min = tbOpemTime.min,
      sec = 0
    })
    nSec = nSec - 86400
    local nNewSec = 0
    for i2 = 0, 6 do
      nNewSec = nSec - 86400 * i2
      local tbToTime = os.date("*t", nNewSec)
      if tbToTime.wday == 1 then
        self.nCahcheMatchTimeYearNext = nNewSec
        break
      end
    end
  end
  if nNow > self.nCahcheMatchTimeYear then
    return self.nCahcheMatchTimeYearNext
  else
    return self.nCahcheMatchTimeYear
  end
end
function Battle:GetCanSignBattleSetting(pPlayer)
  if Calendar:IsActivityInOpenState("BattleMoba") then
    return Battle.tbAllBattleSetting.BattleMoba
  end
  if not Calendar:IsActivityInOpenState("Battle") then
    return
  end
  local bBattleZone = Calendar:IsActivityInOpenState("BattleZone")
  if not self.tbSortMapSetting then
    self.tbSortMapSetting = {}
    for i, v in ipairs(Battle.tbMapSetting) do
      table.insert(self.tbSortMapSetting, v)
    end
    table.sort(self.tbSortMapSetting, function(a, b)
      return a.nShowLevel > b.nShowLevel
    end)
  end
  for i, v in ipairs(self.tbSortMapSetting) do
    if Calendar:IsActivityInOpenState(v.szLogicClass) then
      if v.ChechConditionFunc then
        if Battle[v.ChechConditionFunc](self, pPlayer) then
          return v, 1
        end
      elseif bBattleZone then
        local tbGroupSetting
        if v.bZone then
          tbGroupSetting = self.tbHighZoneLevelSetting
        elseif v.bCanLowerZone and Battle:GetCanSignLowZoneBattle(pPlayer) then
          tbGroupSetting = self.tbZoneLevelSetting
        end
        if tbGroupSetting then
          local tbReadyMapIndexs = {}
          for i2, v2 in ipairs(tbGroupSetting) do
            if v2.nBattleModeIndex then
              tbReadyMapIndexs[v2.nBattleModeIndex] = (tbReadyMapIndexs[v2.nBattleModeIndex] or 0) + 1
            else
              tbReadyMapIndexs[v.nIndex] = (tbReadyMapIndexs[v.nIndex] or 0) + 1
            end
            if pPlayer.nLevel >= v2.nLevelFrom and pPlayer.nLevel <= v2.nLevelEnd then
              if v2.nBattleModeIndex then
                return self.tbMapSetting[v2.nBattleModeIndex], tbReadyMapIndexs[v2.nBattleModeIndex]
              else
                return v, tbReadyMapIndexs[v.nIndex]
              end
            end
          end
        end
      end
      if not v.bZone then
        return v
      end
    end
  end
end
