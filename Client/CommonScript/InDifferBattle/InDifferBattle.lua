Require("CommonScript/EnvDef.lua")
Require("CommonScript/Item/Define.lua")
InDifferBattle.tbRandSkillBook = {
  3434,
  3435,
  3436,
  3437
}
InDifferBattle.tbBattleTypeSetting = {
  Normal = {
    szName = "",
    NextType = "Month",
    szScroeDescHelpKey = "InDifferBattleScoreHelp"
  },
  Month = {
    szName = "月度",
    NextType = "Season",
    szOpenTimeFrame = "OpenLevel109",
    nKeyQualifyTime = 7,
    nNeedGrade = 3,
    nQualifyTitleId = 7703,
    szOpenTimeFunc = "GetNextOpenTimeMonth",
    OpenTimeWeek = 1,
    OpenTimeWeekDay = 6,
    OpenTimeHour = 20,
    OpenTimeMinute = 25,
    tbLeagueTipMailInfo = {
      "月度心魔幻境参赛通知",
      "      您已获得本次月度心魔幻境竞技的参赛资格，比赛时间为[EACC00]%s[-]，请您务必准时参加。届时会有更丰厚的奖励以及更高的荣誉等着您！"
    },
    szScroeDescHelpKey = "InDifferBattleScoreHelpMonth"
  },
  Season = {
    szName = "季度",
    NextType = "Year",
    szOpenTimeFrame = "OpenLevel109",
    nKeyQualifyTime = 8,
    nNeedGrade = 3,
    nQualifyTitleId = 7704,
    szOpenTimeFunc = "GetNextOpenTimeSeason",
    OpenTimeWeek = -1,
    OpenTimeWeekDay = 6,
    OpenTimeHour = 20,
    OpenTimeMinute = 25,
    tbLeagueTipMailInfo = {
      "季度心魔幻境参赛通知",
      "      您已获得本次季度心魔幻境竞技的参赛资格，比赛时间为[EACC00]%s[-]，请您务必准时参加。届时会有更丰厚的奖励以及更高的荣誉等着您！"
    },
    szScroeDescHelpKey = "InDifferBattleScoreHelpMonth"
  },
  Year = {
    szName = "年度",
    szOpenTimeFrame = "OpenLevel109",
    nKeyQualifyTime = 9,
    nNeedGrade = 3,
    nQualifyTitleId = 7705,
    szOpenTimeFunc = "GetNextOpenTimeYear",
    OpenTimeWeek = -1,
    OpenTimeWeekDay = 6,
    OpenTimeHour = 20,
    OpenTimeMinute = 25,
    tbLeagueTipMailInfo = {
      "年度心魔幻境参赛通知",
      "      您已获得本次年度心魔幻境竞技的参赛资格，比赛时间为[EACC00]%s[-]，请您务必准时参加。届时会有更丰厚的奖励以及更高的荣誉等着您！"
    },
    szScroeDescHelpKey = "InDifferBattleScoreHelpMonth"
  }
}
InDifferBattle.tbBattleTypeList = {
  "Normal",
  "Month",
  "Season",
  "Year"
}
for i, v in ipairs(InDifferBattle.tbBattleTypeList) do
  InDifferBattle.tbBattleTypeSetting[v].nLevel = i
end
InDifferBattle.tbDefine = {
  SAVE_GROUP = 118,
  KEY_CUR_HONOR = 3,
  KEY_WIN_TIMES = 6,
  UPDATE_SYNC_DMG_INTERVAL = 10,
  szDmgUiTips = "奖励规则：\n·输出排名进入前3的队伍，可获得奖励\n·奖励获得的多少，与排名相关\n·最后一击有额外的奖励加成",
  szDmgUiTipsBoss = "奖励规则：\n·输出排名进入前5的队伍，可获得奖励\n·奖励获得的多少，与排名相关\n·最后一击有额外的奖励加成",
  szMonoeyType = "Jade",
  szOpenTimeFrame = "OpenDay118",
  nPreTipTime = 172800,
  szCalenddayKey = "InDifferBattle",
  nReadyMapTemplateId = 3002,
  nFightMapTemplateId = 3001,
  MATCH_SIGNUP_TIME = 300,
  nMinLevel = 60,
  nMaxTeamRoleNum = 3,
  nMinTeamNum = 1,
  nMaxTeamNum = 36,
  nPlayerLevel = 80,
  nCloseRoomPunishPersent = 0.9,
  nCloseRoomSkillId = 3083,
  tbInitBuffId = {
    3182,
    1,
    3600
  },
  nReviveItemId = 3309,
  nReviveDelayTime = 20,
  nReviveEffectSkillId = 3084,
  tbReviveSafeBuff = {1517, 45},
  szAvatarEquipKey = "InDiffer",
  tbKillGetMoneyRand = {
    30,
    50,
    5
  },
  tbKillGetItemNumRand = {30, 50},
  nTempCastSKillNpcId = 2113,
  nGateNpcId = 73,
  tbGateDirectionModify = {
    LeftNpc = {0, -1},
    RightNpc = {0, 1},
    TopNpc = {-1, 0},
    BottomNpc = {1, 0}
  },
  tbCastSkillNpcPos = {
    [1] = {293, 294},
    [2] = {293, 294},
    [3] = {293, 294},
    [4] = {293, 294},
    [5] = {293, 294},
    [6] = {293, 294},
    [7] = {293, 294},
    [8] = {293, 294},
    [9] = {293, 294},
    [10] = {293, 294},
    [11] = {293, 294},
    [12] = {293, 294},
    [13] = {293, 294},
    [14] = {293, 294},
    [15] = {293, 294},
    [16] = {293, 294},
    [17] = {293, 294},
    [18] = {293, 294},
    [19] = {293, 294},
    [20] = {293, 294},
    [21] = {293, 294},
    [22] = {293, 294},
    [23] = {293, 294},
    [24] = {293, 294},
    [25] = {293, 294}
  },
  tbStateGetScore = {
    [2] = {nSurviveScore = 2, nKillScore = 2},
    [4] = {nSurviveScore = 4, nKillScore = 4},
    [6] = {nSurviveScore = 6, nKillScore = 6},
    [8] = {nSurviveScore = 8, nKillScore = 8}
  },
  tbWinTeamAddScore = {60, 40},
  tbLastSwitchRandPosSet = {
    "center",
    "center_2",
    "center_3",
    "center_4",
    "center_5",
    "center_6",
    "center_7",
    "center_8"
  },
  tbLastSkillBuff = {
    1517,
    1,
    75
  },
  tbFirstSkillBuff = {
    1517,
    1,
    120
  },
  nSafeStateSkillBuffId = 1517,
  tbOpenBoxType = {
    [1994] = {
      [2] = {
        {
          0.2,
          {
            {
              "OnOpenBoxCastSkillCycle",
              -1,
              3183,
              1,
              -1,
              -1
            },
            {
              "OnBlackBoardMsg",
              "宝箱内空空如也！糟糕，竟触发了幻境机关。"
            }
          }
        },
        {
          0.8,
          {
            {
              "OnSendRandDropAwardToTeam",
              "tbBoxAward_1",
              2,
              4
            }
          }
        }
      },
      [4] = {
        {
          0.2,
          {
            {
              "OnOpenBoxCastSkillCycle",
              -1,
              3183,
              1,
              -1,
              -1
            },
            {
              "OnBlackBoardMsg",
              "宝箱内空空如也！糟糕，竟触发了幻境机关。"
            }
          }
        },
        {
          0.8,
          {
            {
              "OnSendRandDropAwardToTeam",
              "tbBoxAward_2",
              2,
              4
            }
          }
        }
      },
      [6] = {
        {
          0.2,
          {
            {
              "OnOpenBoxCastSkillCycle",
              -1,
              3183,
              1,
              -1,
              -1
            },
            {
              "OnBlackBoardMsg",
              "宝箱内空空如也！糟糕，竟触发了幻境机关。"
            }
          }
        },
        {
          0.8,
          {
            {
              "OnSendRandDropAwardToTeam",
              "tbBoxAward_3",
              2,
              4
            }
          }
        }
      }
    },
    [2101] = {
      [2] = {
        {
          1,
          {
            {
              "OnSendRandDropAwardToTeam",
              "tbSuperBoxAward_1",
              6,
              10
            },
            {
              "OnSendAwardTeamAll",
              {
                {"RandBuff"}
              }
            },
            {
              "OnAddRandPosNpcSet",
              1994,
              1,
              4,
              6
            }
          }
        }
      },
      [4] = {
        {
          1,
          {
            {
              "OnSendRandDropAwardToTeam",
              "tbSuperBoxAward_2",
              6,
              10
            },
            {
              "OnSendAwardTeamAll",
              {
                {"RandBuff"}
              }
            },
            {
              "OnAddRandPosNpcSet",
              1994,
              1,
              4,
              6
            }
          }
        }
      },
      [6] = {
        {
          1,
          {
            {
              "OnSendRandDropAwardToTeam",
              "tbSuperBoxAward_3",
              6,
              10
            },
            {
              "OnSendAwardTeamAll",
              {
                {"RandBuff"}
              }
            },
            {
              "OnAddRandPosNpcSet",
              1994,
              1,
              4,
              6
            }
          }
        }
      }
    }
  },
  tbAutoDeleteWhenStateChangeNpc = {
    [1994] = 1
  },
  tbBattleNpcDropSettingItem = {},
  tbBattleNpcDropSettingMoney = {
    [2] = {
      {
        "RandMoney",
        8,
        16
      },
      {
        "RandItemCount",
        3299,
        2,
        4
      }
    },
    [4] = {
      {
        "RandMoney",
        15,
        25
      },
      {
        "RandItemCount",
        3299,
        4,
        6
      }
    },
    [6] = {
      {
        "RandMoney",
        32,
        40
      },
      {
        "RandItemCount",
        3299,
        6,
        12
      }
    }
  },
  tbRandBuffSet = {
    {
      3166,
      1,
      75
    },
    {
      3166,
      1,
      75
    },
    {
      3166,
      1,
      75
    },
    {
      3166,
      1,
      75
    },
    {
      3166,
      1,
      75
    },
    {
      3166,
      1,
      75
    },
    {
      3167,
      1,
      2700
    },
    {
      3167,
      1,
      2700
    },
    {
      3167,
      1,
      2700
    },
    {
      3168,
      1,
      2700
    },
    {
      3168,
      1,
      2700
    },
    {
      3168,
      1,
      2700
    },
    {
      3169,
      1,
      2700
    },
    {
      3169,
      1,
      2700
    },
    {
      3169,
      1,
      2700
    },
    {
      3191,
      1,
      2700
    },
    {
      3191,
      1,
      2700
    },
    {
      3191,
      1,
      2700
    },
    {
      3192,
      1,
      225
    },
    {
      3192,
      1,
      225
    }
  },
  nLastDmgBossHPPercent = 15,
  nLastDmgBigBossHPPercent = 10,
  READY_MAP_POS = {
    {2706, 5659},
    {2666, 6319},
    {2684, 5001},
    {6931, 5712},
    {6947, 6462},
    {6947, 4994}
  },
  tbRandMoney = {5, 15},
  nDefaultStrengthLevel = 40,
  nStrengthStep = 10,
  nEnhanceItemId = 3299,
  tbEnhanceScroll = {
    {
      szDesc = "武器",
      tbEquipPos = {
        Item.EQUIPPOS_WEAPON
      },
      tbEnhanceCost = {
        [50] = 5,
        [60] = 10,
        [70] = 20,
        [80] = 40,
        [90] = 80,
        [100] = 160
      }
    },
    {
      szDesc = "衣服",
      tbEquipPos = {
        Item.EQUIPPOS_BODY
      },
      tbEnhanceCost = {
        [50] = 3,
        [60] = 6,
        [70] = 12,
        [80] = 24,
        [90] = 48,
        [100] = 96
      }
    },
    {
      szDesc = "首饰",
      tbEquipPos = {
        Item.EQUIPPOS_NECKLACE,
        Item.EQUIPPOS_RING,
        Item.EQUIPPOS_PENDANT,
        Item.EQUIPPOS_AMULET
      },
      tbEnhanceCost = {
        [50] = 8,
        [60] = 16,
        [70] = 32,
        [80] = 64,
        [90] = 128,
        [100] = 256
      }
    },
    {
      szDesc = "防具",
      tbEquipPos = {
        Item.EQUIPPOS_HEAD,
        Item.EQUIPPOS_CUFF,
        Item.EQUIPPOS_BELT,
        Item.EQUIPPOS_FOOT
      },
      tbEnhanceCost = {
        [50] = 4,
        [60] = 8,
        [70] = 16,
        [80] = 32,
        [90] = 64,
        [100] = 128
      }
    }
  },
  tbHorseUpgrade = {2400, 3012},
  nMaxSkillBookType = 1,
  tbInitGiveItem = {
    {
      7000,
      {
        "RandItemCount",
        3299,
        3,
        5
      }
    },
    {
      500,
      {
        "item",
        2400,
        1
      }
    },
    {
      2000,
      {"SkillBook", 0}
    },
    {
      500,
      {
        "item",
        1391,
        1
      }
    }
  },
  nMaxRoomNum = 25,
  tbExChangeBoxInfo = {
    {
      3481,
      2000,
      "幻境黄金宝箱"
    },
    {
      3482,
      1000,
      "幻境白银宝箱"
    }
  },
  tbGetHonorSetting = {
    {
      nScoreMin = 0,
      tbAwardNormal = {
        {
          "IndifferHonor",
          1200
        },
        {"BasicExp", 50}
      },
      tbAwardMonth = {
        {
          "IndifferHonor",
          4000
        },
        {"BasicExp", 50}
      },
      tbAwardSeason = {
        {
          "IndifferHonor",
          4000
        },
        {"BasicExp", 50}
      },
      tbAwardYear = {
        {
          "IndifferHonor",
          4000
        },
        {"BasicExp", 50}
      }
    },
    {
      nScoreMin = 6,
      tbAwardNormal = {
        {
          "IndifferHonor",
          1500
        },
        {"BasicExp", 60}
      },
      tbAwardMonth = {
        {
          "IndifferHonor",
          6000
        },
        {"BasicExp", 60}
      },
      tbAwardSeason = {
        {
          "IndifferHonor",
          6000
        },
        {"BasicExp", 60}
      },
      tbAwardYear = {
        {
          "IndifferHonor",
          6000
        },
        {"BasicExp", 60}
      }
    },
    {
      nScoreMin = 16,
      tbAwardNormal = {
        {
          "IndifferHonor",
          2000
        },
        {"BasicExp", 70}
      },
      tbAwardMonth = {
        {
          "IndifferHonor",
          8000
        },
        {"BasicExp", 70}
      },
      tbAwardSeason = {
        {
          "IndifferHonor",
          8000
        },
        {"BasicExp", 70}
      },
      tbAwardYear = {
        {
          "IndifferHonor",
          8000
        },
        {"BasicExp", 70}
      }
    },
    {
      nScoreMin = 32,
      tbAwardNormal = {
        {
          "IndifferHonor",
          2500
        },
        {"BasicExp", 80}
      },
      tbAwardMonth = {
        {
          "IndifferHonor",
          10000
        },
        {"BasicExp", 80}
      },
      tbAwardSeason = {
        {
          "IndifferHonor",
          10000
        },
        {"BasicExp", 80}
      },
      tbAwardYear = {
        {
          "IndifferHonor",
          10000
        },
        {"BasicExp", 80}
      }
    },
    {
      nScoreMin = 48,
      tbAwardNormal = {
        {
          "IndifferHonor",
          3000
        },
        {"BasicExp", 100}
      },
      tbAwardMonth = {
        {
          "IndifferHonor",
          12000
        },
        {"BasicExp", 100}
      },
      tbAwardSeason = {
        {
          "IndifferHonor",
          12000
        },
        {"BasicExp", 100}
      },
      tbAwardYear = {
        {
          "IndifferHonor",
          12000
        },
        {"BasicExp", 100}
      }
    },
    {
      nScoreMin = 96,
      tbAwardNormal = {
        {
          "IndifferHonor",
          4000
        },
        {"BasicExp", 100}
      },
      tbAwardMonth = {
        {
          "IndifferHonor",
          16000
        },
        {"BasicExp", 100}
      },
      tbAwardSeason = {
        {
          "IndifferHonor",
          16000
        },
        {"BasicExp", 100}
      },
      tbAwardYear = {
        {
          "IndifferHonor",
          16000
        },
        {"BasicExp", 100}
      }
    }
  },
  tbEvaluationSetting = {
    {
      nScoreMin = 0,
      szName = "普通",
      szColor = "FFFFFF"
    },
    {
      nScoreMin = 6,
      szName = "一般",
      szColor = "64db00"
    },
    {
      nScoreMin = 16,
      szName = "良好",
      szColor = "11adf6"
    },
    {
      nScoreMin = 32,
      szName = "优秀",
      szColor = "aa62fc"
    },
    {
      nScoreMin = 48,
      szName = "卓越",
      szColor = "ff578c"
    },
    {
      nScoreMin = 96,
      szName = "最佳",
      szColor = "ff8f06"
    }
  },
  tbAddImitySetting = {
    [0] = 100,
    [2] = 60,
    [4] = 70,
    [6] = 80,
    [8] = 90,
    [12] = 120
  },
  nSelllPricePercent = 0.5,
  nCanBuyDistance = 500,
  tbSellWareSetting = {
    [3299] = {nPrice = 4, nSort = 1},
    [1392] = {nPrice = 60, nSort = 2},
    [1391] = {nPrice = 16, nSort = 3},
    [2400] = {nPrice = 24, nSort = 4},
    [3434] = {nPrice = 20, nSort = 5},
    [3435] = {nPrice = 20, nSort = 6},
    [3436] = {nPrice = 20, nSort = 7},
    [3437] = {nPrice = 20, nSort = 8},
    [3307] = {nPrice = 30, nSort = 9},
    [3308] = {nPrice = 90, nSort = 10}
  },
  tbSellWarePropSetting = {
    [2] = {
      {
        3299,
        300,
        600
      },
      {
        2400,
        4,
        10
      },
      {
        InDifferBattle.tbRandSkillBook,
        12,
        20
      },
      {
        1391,
        4,
        10
      }
    },
    [4] = {
      {
        3299,
        300,
        600
      },
      {
        2400,
        2,
        4
      },
      {
        3307,
        1,
        2
      },
      {
        InDifferBattle.tbRandSkillBook,
        4,
        8
      },
      {
        3308,
        2,
        4
      },
      {
        1391,
        2,
        4
      },
      {
        1392,
        1,
        2
      }
    },
    [6] = {
      {
        3299,
        300,
        600
      },
      {
        2400,
        2,
        4
      },
      {
        3307,
        2,
        4
      },
      {
        InDifferBattle.tbRandSkillBook,
        4,
        8
      },
      {
        3308,
        4,
        8
      },
      {
        1391,
        2,
        4
      },
      {
        1392,
        2,
        4
      }
    }
  },
  STATE_TRANS = {
    [1] = {
      nSeconds = 90,
      szFunc = "StartFight1",
      szDesc = "请选择你在幻境中的门派"
    },
    [2] = {
      nSeconds = 360,
      szFunc = "ResetTime",
      szDesc = "阶段一：探索幻境",
      szBeginNotify = "探索幻境提升能力，生存到最后！"
    },
    [3] = {
      nSeconds = 90,
      szFunc = "ReStartFight",
      szDesc = "休整阶段",
      szBeginNotify = "本阶段禁止战斗，可前往商人处购买物品！"
    },
    [4] = {
      nSeconds = 360,
      szFunc = "ResetTime",
      szDesc = "阶段二：探索幻境",
      szBeginNotify = "幻境异变，部分区域的入口已坍塌！"
    },
    [5] = {
      nSeconds = 90,
      szFunc = "ReStartFight",
      szDesc = "休整阶段",
      szBeginNotify = "本阶段禁止战斗，可前往商人处购买物品！"
    },
    [6] = {
      nSeconds = 360,
      szFunc = "ResetTime",
      szDesc = "阶段三：探索幻境",
      szBeginNotify = "幻境异变，部分区域的入口已坍塌！"
    },
    [7] = {
      nSeconds = 90,
      szFunc = "ReStartFight",
      szDesc = "休整阶段",
      szBeginNotify = "本阶段禁止战斗，可前往商人处购买物品！"
    },
    [8] = {
      nSeconds = 240,
      szFunc = "StopFight",
      szDesc = "阶段四：击败其他对手",
      szBeginNotify = "击败其他对手，生存到最后！"
    },
    [9] = {
      nSeconds = 60,
      szFunc = "CloseBattle",
      szDesc = "活动结束，离开幻境"
    }
  },
  tbActiveTrans = {
    [1] = {
      [60] = {
        {
          "SynGameTime"
        }
      },
      [80] = {
        {
          "SynGameTime"
        }
      }
    },
    [2] = {
      [1] = {
        {
          "SynGameTime"
        },
        {
          "AddRandPosNpcSet",
          2096,
          80,
          24,
          {
            "npc_1",
            "npc_2",
            "npc_3",
            "npc_4",
            "npc_5"
          },
          {3, 5},
          20
        },
        {
          "AddRandPosNpcSet",
          2097,
          80,
          25,
          {
            "npc_1",
            "npc_2",
            "npc_3",
            "npc_4",
            "npc_5"
          },
          {3, 5},
          20
        },
        {
          "AddRandPosNpcSet",
          2098,
          80,
          10,
          {
            "npc_1",
            "npc_2",
            "npc_3",
            "npc_4",
            "npc_5"
          },
          {3, 5},
          20
        },
        {
          "AddRandPosNpcSet",
          2099,
          80,
          11,
          {
            "npc_1",
            "npc_2",
            "npc_3",
            "npc_4",
            "npc_5"
          },
          {3, 5},
          20
        },
        {
          "AddRandPosNpcSet",
          2100,
          80,
          12,
          {
            "npc_1",
            "npc_2",
            "npc_3",
            "npc_4",
            "npc_5"
          },
          {3, 5},
          20
        },
        {
          "AddRandPosNpcSet",
          2097,
          80,
          23,
          {
            "npc_1",
            "npc_2",
            "npc_3",
            "npc_4",
            "npc_5"
          },
          {3, 5},
          20
        },
        {
          "AddRandPosNpcSet",
          2098,
          80,
          9,
          {
            "npc_1",
            "npc_2",
            "npc_3",
            "npc_4",
            "npc_5"
          },
          {3, 5},
          20
        },
        {
          "AddRandPosNpcSet",
          2099,
          80,
          2,
          {
            "npc_1",
            "npc_2",
            "npc_3",
            "npc_4",
            "npc_5"
          },
          {3, 5},
          20
        },
        {
          "AddRandPosNpcSet",
          2100,
          80,
          3,
          {
            "npc_1",
            "npc_2",
            "npc_3",
            "npc_4",
            "npc_5"
          },
          {3, 5},
          20
        },
        {
          "AddRandPosNpcSet",
          2096,
          80,
          13,
          {
            "npc_1",
            "npc_2",
            "npc_3",
            "npc_4",
            "npc_5"
          },
          {3, 5},
          20
        },
        {
          "AddRandPosNpcSet",
          2098,
          80,
          22,
          {
            "npc_1",
            "npc_2",
            "npc_3",
            "npc_4",
            "npc_5"
          },
          {3, 5},
          20
        },
        {
          "AddRandPosNpcSet",
          2099,
          80,
          8,
          {
            "npc_1",
            "npc_2",
            "npc_3",
            "npc_4",
            "npc_5"
          },
          {3, 5},
          20
        },
        {
          "AddRandPosNpcSet",
          2100,
          80,
          1,
          {
            "npc_1",
            "npc_2",
            "npc_3",
            "npc_4",
            "npc_5"
          },
          {3, 5},
          20
        },
        {
          "AddRandPosNpcSet",
          2096,
          80,
          4,
          {
            "npc_1",
            "npc_2",
            "npc_3",
            "npc_4",
            "npc_5"
          },
          {3, 5},
          20
        },
        {
          "AddRandPosNpcSet",
          2097,
          80,
          14,
          {
            "npc_1",
            "npc_2",
            "npc_3",
            "npc_4",
            "npc_5"
          },
          {3, 5},
          20
        },
        {
          "AddRandPosNpcSet",
          2099,
          80,
          21,
          {
            "npc_1",
            "npc_2",
            "npc_3",
            "npc_4",
            "npc_5"
          },
          {3, 5},
          20
        },
        {
          "AddRandPosNpcSet",
          2100,
          80,
          7,
          {
            "npc_1",
            "npc_2",
            "npc_3",
            "npc_4",
            "npc_5"
          },
          {3, 5},
          20
        },
        {
          "AddRandPosNpcSet",
          2096,
          80,
          6,
          {
            "npc_1",
            "npc_2",
            "npc_3",
            "npc_4",
            "npc_5"
          },
          {3, 5},
          20
        },
        {
          "AddRandPosNpcSet",
          2097,
          80,
          5,
          {
            "npc_1",
            "npc_2",
            "npc_3",
            "npc_4",
            "npc_5"
          },
          {3, 5},
          20
        },
        {
          "AddRandPosNpcSet",
          2098,
          80,
          15,
          {
            "npc_1",
            "npc_2",
            "npc_3",
            "npc_4",
            "npc_5"
          },
          {3, 5},
          20
        },
        {
          "AddRandPosNpcSet",
          2100,
          80,
          20,
          {
            "npc_1",
            "npc_2",
            "npc_3",
            "npc_4",
            "npc_5"
          },
          {3, 5},
          20
        },
        {
          "AddRandPosNpcSet",
          2096,
          80,
          19,
          {
            "npc_1",
            "npc_2",
            "npc_3",
            "npc_4",
            "npc_5"
          },
          {3, 5},
          20
        },
        {
          "AddRandPosNpcSet",
          2097,
          80,
          18,
          {
            "npc_1",
            "npc_2",
            "npc_3",
            "npc_4",
            "npc_5"
          },
          {3, 5},
          20
        },
        {
          "AddRandPosNpcSet",
          2098,
          80,
          17,
          {
            "npc_1",
            "npc_2",
            "npc_3",
            "npc_4",
            "npc_5"
          },
          {3, 5},
          20
        },
        {
          "AddRandPosNpcSet",
          2099,
          80,
          16,
          {
            "npc_1",
            "npc_2",
            "npc_3",
            "npc_4",
            "npc_5"
          },
          {3, 5},
          20
        },
        {
          "AddRandTypeSetTimer",
          1,
          "box_buff",
          60,
          {
            {
              0.5,
              "AddMapNpcByPosName",
              1994,
              1,
              59
            },
            {
              0.5,
              "AddDropBuffByPosName",
              "1000|30;1001|15;1002|15;1003|15;1004|15;1005|10;1"
            }
          }
        },
        {
          "AddRandTypeSetTimer",
          2,
          "box_buff",
          60,
          {
            {
              0.5,
              "AddMapNpcByPosName",
              1994,
              1,
              59
            },
            {
              0.5,
              "AddDropBuffByPosName",
              "1000|30;1001|15;1002|15;1003|15;1004|15;1005|10;1"
            }
          }
        },
        {
          "AddRandTypeSetTimer",
          3,
          "box_buff",
          60,
          {
            {
              0.5,
              "AddMapNpcByPosName",
              1994,
              1,
              59
            },
            {
              0.5,
              "AddDropBuffByPosName",
              "1000|30;1001|15;1002|15;1003|15;1004|15;1005|10;1"
            }
          }
        },
        {
          "AddRandTypeSetTimer",
          4,
          "box_buff",
          60,
          {
            {
              0.5,
              "AddMapNpcByPosName",
              1994,
              1,
              59
            },
            {
              0.5,
              "AddDropBuffByPosName",
              "1000|30;1001|15;1002|15;1003|15;1004|15;1005|10;1"
            }
          }
        },
        {
          "AddRandTypeSetTimer",
          5,
          "box_buff",
          60,
          {
            {
              0.5,
              "AddMapNpcByPosName",
              1994,
              1,
              59
            },
            {
              0.5,
              "AddDropBuffByPosName",
              "1000|30;1001|15;1002|15;1003|15;1004|15;1005|10;1"
            }
          }
        },
        {
          "AddRandTypeSetTimer",
          6,
          "box_buff",
          60,
          {
            {
              0.5,
              "AddMapNpcByPosName",
              1994,
              1,
              59
            },
            {
              0.5,
              "AddDropBuffByPosName",
              "1000|30;1001|15;1002|15;1003|15;1004|15;1005|10;1"
            }
          }
        },
        {
          "AddRandTypeSetTimer",
          7,
          "box_buff",
          60,
          {
            {
              0.5,
              "AddMapNpcByPosName",
              1994,
              1,
              59
            },
            {
              0.5,
              "AddDropBuffByPosName",
              "1000|30;1001|15;1002|15;1003|15;1004|15;1005|10;1"
            }
          }
        },
        {
          "AddRandTypeSetTimer",
          8,
          "box_buff",
          60,
          {
            {
              0.5,
              "AddMapNpcByPosName",
              1994,
              1,
              59
            },
            {
              0.5,
              "AddDropBuffByPosName",
              "1000|30;1001|15;1002|15;1003|15;1004|15;1005|10;1"
            }
          }
        },
        {
          "AddRandTypeSetTimer",
          9,
          "box_buff",
          60,
          {
            {
              0.5,
              "AddMapNpcByPosName",
              1994,
              1,
              59
            },
            {
              0.5,
              "AddDropBuffByPosName",
              "1000|30;1001|15;1002|15;1003|15;1004|15;1005|10;1"
            }
          }
        },
        {
          "AddRandTypeSetTimer",
          10,
          "box_buff",
          60,
          {
            {
              0.5,
              "AddMapNpcByPosName",
              1994,
              1,
              59
            },
            {
              0.5,
              "AddDropBuffByPosName",
              "1000|30;1001|15;1002|15;1003|15;1004|15;1005|10;1"
            }
          }
        },
        {
          "AddRandTypeSetTimer",
          11,
          "box_buff",
          60,
          {
            {
              0.5,
              "AddMapNpcByPosName",
              1994,
              1,
              59
            },
            {
              0.5,
              "AddDropBuffByPosName",
              "1000|30;1001|15;1002|15;1003|15;1004|15;1005|10;1"
            }
          }
        },
        {
          "AddRandTypeSetTimer",
          12,
          "box_buff",
          60,
          {
            {
              0.5,
              "AddMapNpcByPosName",
              1994,
              1,
              59
            },
            {
              0.5,
              "AddDropBuffByPosName",
              "1000|30;1001|15;1002|15;1003|15;1004|15;1005|10;1"
            }
          }
        },
        {
          "AddRandTypeSetTimer",
          13,
          "box_buff",
          60,
          {
            {
              0.5,
              "AddMapNpcByPosName",
              1994,
              1,
              59
            },
            {
              0.5,
              "AddDropBuffByPosName",
              "1000|30;1001|15;1002|15;1003|15;1004|15;1005|10;1"
            }
          }
        },
        {
          "AddRandTypeSetTimer",
          14,
          "box_buff",
          60,
          {
            {
              0.5,
              "AddMapNpcByPosName",
              1994,
              1,
              59
            },
            {
              0.5,
              "AddDropBuffByPosName",
              "1000|30;1001|15;1002|15;1003|15;1004|15;1005|10;1"
            }
          }
        },
        {
          "AddRandTypeSetTimer",
          15,
          "box_buff",
          60,
          {
            {
              0.5,
              "AddMapNpcByPosName",
              1994,
              1,
              59
            },
            {
              0.5,
              "AddDropBuffByPosName",
              "1000|30;1001|15;1002|15;1003|15;1004|15;1005|10;1"
            }
          }
        },
        {
          "AddRandTypeSetTimer",
          16,
          "box_buff",
          60,
          {
            {
              0.5,
              "AddMapNpcByPosName",
              1994,
              1,
              59
            },
            {
              0.5,
              "AddDropBuffByPosName",
              "1000|30;1001|15;1002|15;1003|15;1004|15;1005|10;1"
            }
          }
        },
        {
          "AddRandTypeSetTimer",
          17,
          "box_buff",
          60,
          {
            {
              0.5,
              "AddMapNpcByPosName",
              1994,
              1,
              59
            },
            {
              0.5,
              "AddDropBuffByPosName",
              "1000|30;1001|15;1002|15;1003|15;1004|15;1005|10;1"
            }
          }
        },
        {
          "AddRandTypeSetTimer",
          18,
          "box_buff",
          60,
          {
            {
              0.5,
              "AddMapNpcByPosName",
              1994,
              1,
              59
            },
            {
              0.5,
              "AddDropBuffByPosName",
              "1000|30;1001|15;1002|15;1003|15;1004|15;1005|10;1"
            }
          }
        },
        {
          "AddRandTypeSetTimer",
          19,
          "box_buff",
          60,
          {
            {
              0.5,
              "AddMapNpcByPosName",
              1994,
              1,
              59
            },
            {
              0.5,
              "AddDropBuffByPosName",
              "1000|30;1001|15;1002|15;1003|15;1004|15;1005|10;1"
            }
          }
        },
        {
          "AddRandTypeSetTimer",
          20,
          "box_buff",
          60,
          {
            {
              0.5,
              "AddMapNpcByPosName",
              1994,
              1,
              59
            },
            {
              0.5,
              "AddDropBuffByPosName",
              "1000|30;1001|15;1002|15;1003|15;1004|15;1005|10;1"
            }
          }
        },
        {
          "AddRandTypeSetTimer",
          21,
          "box_buff",
          60,
          {
            {
              0.5,
              "AddMapNpcByPosName",
              1994,
              1,
              59
            },
            {
              0.5,
              "AddDropBuffByPosName",
              "1000|30;1001|15;1002|15;1003|15;1004|15;1005|10;1"
            }
          }
        },
        {
          "AddRandTypeSetTimer",
          22,
          "box_buff",
          60,
          {
            {
              0.5,
              "AddMapNpcByPosName",
              1994,
              1,
              59
            },
            {
              0.5,
              "AddDropBuffByPosName",
              "1000|30;1001|15;1002|15;1003|15;1004|15;1005|10;1"
            }
          }
        },
        {
          "AddRandTypeSetTimer",
          23,
          "box_buff",
          60,
          {
            {
              0.5,
              "AddMapNpcByPosName",
              1994,
              1,
              59
            },
            {
              0.5,
              "AddDropBuffByPosName",
              "1000|30;1001|15;1002|15;1003|15;1004|15;1005|10;1"
            }
          }
        },
        {
          "AddRandTypeSetTimer",
          24,
          "box_buff",
          60,
          {
            {
              0.5,
              "AddMapNpcByPosName",
              1994,
              1,
              59
            },
            {
              0.5,
              "AddDropBuffByPosName",
              "1000|30;1001|15;1002|15;1003|15;1004|15;1005|10;1"
            }
          }
        },
        {
          "AddRandTypeSetTimer",
          25,
          "box_buff",
          60,
          {
            {
              0.5,
              "AddMapNpcByPosName",
              1994,
              1,
              59
            },
            {
              0.5,
              "AddDropBuffByPosName",
              "1000|30;1001|15;1002|15;1003|15;1004|15;1005|10;1"
            }
          }
        }
      },
      [10] = {
        {
          "SynGameTime"
        },
        {
          "OnWorldNotify",
          "神秘商人现身幻境，据说专卖一些幻境中特有之物（可通过地图查看出现区域）"
        },
        {
          "OnAddSingleRoomNpc",
          1987,
          440
        },
        {
          "OnAddSingleRoomNpc",
          1987,
          440
        }
      },
      [50] = {
        {
          "AddActiveCastSkill",
          24,
          {
            {
              30,
              {
                {
                  3160,
                  1,
                  2610,
                  20774
                },
                {
                  3160,
                  1,
                  3583,
                  20757
                },
                {
                  3160,
                  1,
                  2615,
                  19801
                },
                {
                  3160,
                  1,
                  3562,
                  19793
                }
              }
            },
            {
              5,
              {
                {
                  3189,
                  1,
                  2610,
                  20774
                },
                {
                  3189,
                  1,
                  3583,
                  20757
                },
                {
                  3189,
                  1,
                  2615,
                  19801
                },
                {
                  3189,
                  1,
                  3562,
                  19793
                }
              }
            },
            {
              30,
              {
                {
                  3160,
                  1,
                  3096,
                  20320
                },
                {
                  3160,
                  1,
                  2555,
                  20323
                },
                {
                  3160,
                  1,
                  3742,
                  20307
                }
              }
            },
            {
              5,
              {
                {
                  3189,
                  1,
                  3096,
                  20320
                },
                {
                  3189,
                  1,
                  2555,
                  20323
                },
                {
                  3189,
                  1,
                  3742,
                  20307
                }
              }
            },
            {
              30,
              {
                {
                  3160,
                  1,
                  3105,
                  20917
                },
                {
                  3160,
                  1,
                  3093,
                  20323
                },
                {
                  3160,
                  1,
                  3093,
                  19714
                }
              }
            },
            {
              5,
              {
                {
                  3189,
                  1,
                  3105,
                  20917
                },
                {
                  3189,
                  1,
                  3093,
                  20323
                },
                {
                  3189,
                  1,
                  3093,
                  19714
                }
              }
            },
            {
              30,
              {
                {
                  3160,
                  1,
                  2610,
                  20774
                },
                {
                  3160,
                  1,
                  3583,
                  20757
                },
                {
                  3160,
                  1,
                  2615,
                  19801
                },
                {
                  3160,
                  1,
                  3562,
                  19793
                }
              }
            },
            {
              5,
              {
                {
                  3189,
                  1,
                  2610,
                  20774
                },
                {
                  3189,
                  1,
                  3583,
                  20757
                },
                {
                  3189,
                  1,
                  2615,
                  19801
                },
                {
                  3189,
                  1,
                  3562,
                  19793
                }
              }
            },
            {
              30,
              {
                {
                  3160,
                  1,
                  3096,
                  20320
                },
                {
                  3160,
                  1,
                  2555,
                  20323
                },
                {
                  3160,
                  1,
                  3742,
                  20307
                }
              }
            },
            {
              5,
              {
                {
                  3189,
                  1,
                  3096,
                  20320
                },
                {
                  3189,
                  1,
                  2555,
                  20323
                },
                {
                  3189,
                  1,
                  3742,
                  20307
                }
              }
            },
            {
              30,
              {
                {
                  3160,
                  1,
                  3105,
                  20917
                },
                {
                  3160,
                  1,
                  3093,
                  20323
                },
                {
                  3160,
                  1,
                  3093,
                  19714
                }
              }
            },
            {
              1050,
              {
                {
                  3189,
                  1,
                  3105,
                  20917
                },
                {
                  3189,
                  1,
                  3093,
                  20323
                },
                {
                  3189,
                  1,
                  3093,
                  19714
                }
              }
            }
          }
        },
        {
          "AddActiveCastSkill",
          25,
          {
            {
              30,
              {
                {
                  3160,
                  1,
                  7466,
                  20281
                }
              }
            },
            {
              60,
              {
                {
                  3185,
                  1,
                  7466,
                  20281
                }
              }
            },
            {
              30,
              {
                {
                  3160,
                  1,
                  7466,
                  20281
                }
              }
            },
            {
              60,
              {
                {
                  3185,
                  1,
                  7466,
                  20281
                }
              }
            },
            {
              30,
              {
                {
                  3160,
                  1,
                  7466,
                  20281
                }
              }
            },
            {
              1050,
              {
                {
                  3185,
                  1,
                  7466,
                  20281
                }
              }
            }
          }
        },
        {
          "AddActiveCastSkill",
          23,
          {
            {
              30,
              {
                {
                  3160,
                  1,
                  2345,
                  16587
                },
                {
                  3160,
                  1,
                  2941,
                  16591
                },
                {
                  3160,
                  1,
                  3448,
                  16598
                }
              }
            },
            {
              5,
              {
                {
                  3189,
                  1,
                  2345,
                  16587
                },
                {
                  3189,
                  1,
                  2941,
                  16591
                },
                {
                  3189,
                  1,
                  3448,
                  16598
                }
              }
            },
            {
              30,
              {
                {
                  3160,
                  1,
                  2345,
                  16077
                },
                {
                  3160,
                  1,
                  2959,
                  16063
                },
                {
                  3160,
                  1,
                  3506,
                  16067
                }
              }
            },
            {
              5,
              {
                {
                  3189,
                  1,
                  2345,
                  16077
                },
                {
                  3189,
                  1,
                  2959,
                  16063
                },
                {
                  3189,
                  1,
                  3506,
                  16067
                }
              }
            },
            {
              30,
              {
                {
                  3160,
                  1,
                  2373,
                  15605
                },
                {
                  3160,
                  1,
                  2959,
                  15584
                },
                {
                  3160,
                  1,
                  3496,
                  15591
                }
              }
            },
            {
              5,
              {
                {
                  3189,
                  1,
                  2373,
                  15605
                },
                {
                  3189,
                  1,
                  2959,
                  15584
                },
                {
                  3189,
                  1,
                  3496,
                  15591
                }
              }
            },
            {
              30,
              {
                {
                  3160,
                  1,
                  2345,
                  16587
                },
                {
                  3160,
                  1,
                  2941,
                  16591
                },
                {
                  3160,
                  1,
                  3448,
                  16598
                }
              }
            },
            {
              5,
              {
                {
                  3189,
                  1,
                  2345,
                  16587
                },
                {
                  3189,
                  1,
                  2941,
                  16591
                },
                {
                  3189,
                  1,
                  3448,
                  16598
                }
              }
            },
            {
              30,
              {
                {
                  3160,
                  1,
                  2345,
                  16077
                },
                {
                  3160,
                  1,
                  2959,
                  16063
                },
                {
                  3160,
                  1,
                  3506,
                  16067
                }
              }
            },
            {
              5,
              {
                {
                  3189,
                  1,
                  2345,
                  16077
                },
                {
                  3189,
                  1,
                  2959,
                  16063
                },
                {
                  3189,
                  1,
                  3506,
                  16067
                }
              }
            },
            {
              30,
              {
                {
                  3160,
                  1,
                  2373,
                  15605
                },
                {
                  3160,
                  1,
                  2959,
                  15584
                },
                {
                  3160,
                  1,
                  3496,
                  15591
                }
              }
            },
            {
              1050,
              {
                {
                  3189,
                  1,
                  2373,
                  15605
                },
                {
                  3189,
                  1,
                  2959,
                  15584
                },
                {
                  3189,
                  1,
                  3496,
                  15591
                }
              }
            }
          }
        },
        {
          "AddActiveCastSkill",
          13,
          {
            {
              30,
              {
                {
                  3160,
                  1,
                  21798,
                  16220
                }
              }
            },
            {
              60,
              {
                {
                  3185,
                  1,
                  21798,
                  16220
                }
              }
            },
            {
              30,
              {
                {
                  3160,
                  1,
                  21798,
                  16220
                }
              }
            },
            {
              60,
              {
                {
                  3185,
                  1,
                  21798,
                  16220
                }
              }
            },
            {
              30,
              {
                {
                  3160,
                  1,
                  21798,
                  16220
                }
              }
            },
            {
              1050,
              {
                {
                  3185,
                  1,
                  21798,
                  16220
                }
              }
            }
          }
        },
        {
          "AddActiveCastSkill",
          22,
          {
            {
              15,
              {
                {
                  3160,
                  1,
                  2373,
                  15605
                }
              }
            },
            {
              5,
              {
                {
                  3189,
                  1,
                  2373,
                  15605
                }
              }
            },
            {
              15,
              {
                {
                  3160,
                  1,
                  2592,
                  12141
                }
              }
            },
            {
              5,
              {
                {
                  3189,
                  1,
                  2592,
                  12141
                }
              }
            },
            {
              15,
              {
                {
                  3160,
                  1,
                  3427,
                  12606
                },
                {
                  3160,
                  1,
                  3400,
                  11646
                }
              }
            },
            {
              5,
              {
                {
                  3189,
                  1,
                  3427,
                  12606
                },
                {
                  3189,
                  1,
                  3400,
                  11646
                }
              }
            },
            {
              15,
              {
                {
                  3160,
                  1,
                  3400,
                  11646
                },
                {
                  3160,
                  1,
                  2829,
                  12605
                }
              }
            },
            {
              5,
              {
                {
                  3189,
                  1,
                  3400,
                  11646
                },
                {
                  3189,
                  1,
                  2829,
                  12605
                }
              }
            },
            {
              15,
              {
                {
                  3160,
                  1,
                  3103,
                  12134
                },
                {
                  3160,
                  1,
                  2829,
                  12605
                },
                {
                  3160,
                  1,
                  2780,
                  11679
                }
              }
            },
            {
              5,
              {
                {
                  3189,
                  1,
                  3103,
                  12134
                },
                {
                  3189,
                  1,
                  2829,
                  12605
                },
                {
                  3189,
                  1,
                  2780,
                  11679
                }
              }
            },
            {
              15,
              {
                {
                  3160,
                  1,
                  2592,
                  12141
                },
                {
                  3160,
                  1,
                  2780,
                  11679
                },
                {
                  3160,
                  1,
                  3612,
                  12080
                }
              }
            },
            {
              5,
              {
                {
                  3189,
                  1,
                  2592,
                  12141
                },
                {
                  3189,
                  1,
                  2780,
                  11679
                },
                {
                  3189,
                  1,
                  3612,
                  12080
                }
              }
            },
            {
              15,
              {
                {
                  3160,
                  1,
                  3103,
                  12134
                },
                {
                  3160,
                  1,
                  3427,
                  12606
                },
                {
                  3160,
                  1,
                  3612,
                  12080
                }
              }
            },
            {
              5,
              {
                {
                  3189,
                  1,
                  3103,
                  12134
                },
                {
                  3189,
                  1,
                  3427,
                  12606
                },
                {
                  3189,
                  1,
                  3612,
                  12080
                }
              }
            },
            {
              15,
              {
                {
                  3160,
                  1,
                  2592,
                  12141
                },
                {
                  3160,
                  1,
                  3400,
                  11646
                }
              }
            },
            {
              5,
              {
                {
                  3189,
                  1,
                  2592,
                  12141
                },
                {
                  3189,
                  1,
                  3400,
                  11646
                }
              }
            },
            {
              15,
              {
                {
                  3160,
                  1,
                  3427,
                  12606
                },
                {
                  3160,
                  1,
                  2829,
                  12605
                }
              }
            },
            {
              5,
              {
                {
                  3189,
                  1,
                  3427,
                  12606
                },
                {
                  3189,
                  1,
                  2829,
                  12605
                }
              }
            },
            {
              15,
              {
                {
                  3160,
                  1,
                  2780,
                  11679
                }
              }
            },
            {
              5,
              {
                {
                  3189,
                  1,
                  2780,
                  11679
                }
              }
            },
            {
              15,
              {
                {
                  3160,
                  1,
                  3612,
                  12080
                }
              }
            },
            {
              1050,
              {
                {
                  3189,
                  1,
                  3612,
                  12080
                }
              }
            }
          }
        },
        {
          "AddActiveCastSkill",
          14,
          {
            {
              30,
              {
                {
                  3160,
                  1,
                  21769,
                  12082
                }
              }
            },
            {
              60,
              {
                {
                  3185,
                  1,
                  21769,
                  12082
                }
              }
            },
            {
              30,
              {
                {
                  3160,
                  1,
                  21769,
                  12082
                }
              }
            },
            {
              60,
              {
                {
                  3185,
                  1,
                  21769,
                  12082
                }
              }
            },
            {
              30,
              {
                {
                  3160,
                  1,
                  21769,
                  12082
                }
              }
            },
            {
              1050,
              {
                {
                  3185,
                  1,
                  21769,
                  12082
                }
              }
            }
          }
        },
        {
          "AddActiveCastSkill",
          15,
          {
            {
              30,
              {
                {
                  3160,
                  1,
                  22131,
                  7366
                }
              }
            },
            {
              60,
              {
                {
                  3185,
                  1,
                  22131,
                  7366
                }
              }
            },
            {
              30,
              {
                {
                  3160,
                  1,
                  22131,
                  7366
                }
              }
            },
            {
              60,
              {
                {
                  3185,
                  1,
                  22131,
                  7366
                }
              }
            },
            {
              30,
              {
                {
                  3160,
                  1,
                  22131,
                  7366
                }
              }
            },
            {
              1050,
              {
                {
                  3185,
                  1,
                  22131,
                  7366
                }
              }
            }
          }
        },
        {
          "AddAutoHideWalkPathNpc",
          10,
          2117,
          80,
          "1_3_skill_A_1",
          210,
          1050
        },
        {
          "AddAutoHideWalkPathNpc",
          10,
          2117,
          80,
          "1_3_skill_A_2",
          210,
          1050
        },
        {
          "AddAutoHideWalkPathNpc",
          10,
          2117,
          80,
          "1_3_skill_A_3",
          210,
          1050
        },
        {
          "AddAutoHideWalkPathNpc",
          10,
          2117,
          80,
          "1_3_skill_A_4",
          210,
          1050
        },
        {
          "AddAutoHideWalkPathNpc",
          10,
          2117,
          80,
          "1_3_skill_A_5",
          210,
          1050
        },
        {
          "AddAutoHideWalkPathNpc",
          11,
          2117,
          80,
          "1_4_skill_A_1",
          210,
          1050
        },
        {
          "AddAutoHideWalkPathNpc",
          11,
          2117,
          80,
          "1_4_skill_A_2",
          210,
          1050
        },
        {
          "AddAutoHideWalkPathNpc",
          11,
          2117,
          80,
          "1_4_skill_A_3",
          210,
          1050
        },
        {
          "AddAutoHideWalkPathNpc",
          11,
          2117,
          80,
          "1_4_skill_A_4",
          210,
          1050
        },
        {
          "AddAutoHideWalkPathNpc",
          11,
          2117,
          80,
          "1_4_skill_A_5",
          210,
          1050
        },
        {
          "AddAutoHideWalkPathNpc",
          12,
          2117,
          80,
          "1_5_skill_A_1",
          210,
          1050
        },
        {
          "AddAutoHideWalkPathNpc",
          12,
          2117,
          80,
          "1_5_skill_A_2",
          210,
          1050
        },
        {
          "AddAutoHideWalkPathNpc",
          12,
          2117,
          80,
          "1_5_skill_A_3",
          210,
          1050
        },
        {
          "AddAutoHideWalkPathNpc",
          12,
          2117,
          80,
          "1_5_skill_A_4",
          210,
          1050
        },
        {
          "AddAutoHideWalkPathNpc",
          12,
          2117,
          80,
          "1_5_skill_A_5",
          210,
          1050
        },
        {
          "AddActiveCastSkill",
          9,
          {
            {
              60,
              {
                {
                  3170,
                  1,
                  7446,
                  16050
                }
              }
            },
            {
              60,
              {
                {
                  3170,
                  1,
                  7446,
                  16050
                }
              }
            },
            {
              1050,
              {
                {
                  3170,
                  1,
                  7446,
                  16050
                }
              }
            }
          }
        },
        {
          "AddActiveCastSkill",
          2,
          {
            {
              60,
              {
                {
                  3172,
                  1,
                  12009,
                  16068
                }
              }
            },
            {
              60,
              {
                {
                  3172,
                  1,
                  12009,
                  16068
                }
              }
            },
            {
              1050,
              {
                {
                  3172,
                  1,
                  12009,
                  16068
                }
              }
            }
          }
        },
        {
          "AddActiveCastSkill",
          3,
          {
            {
              60,
              {
                {
                  3174,
                  1,
                  16905,
                  16080
                }
              }
            },
            {
              60,
              {
                {
                  3174,
                  1,
                  16905,
                  16080
                }
              }
            },
            {
              1050,
              {
                {
                  3174,
                  1,
                  16905,
                  16080
                }
              }
            }
          }
        },
        {
          "AddActiveCastSkill",
          8,
          {
            {
              60,
              {
                {
                  3176,
                  1,
                  7382,
                  11998
                }
              }
            },
            {
              60,
              {
                {
                  3176,
                  1,
                  7382,
                  11998
                }
              }
            },
            {
              1050,
              {
                {
                  3176,
                  1,
                  7382,
                  11998
                }
              }
            }
          }
        },
        {
          "AddActiveCastSkill",
          4,
          {
            {
              60,
              {
                {
                  3178,
                  1,
                  17185,
                  11881
                }
              }
            },
            {
              60,
              {
                {
                  3178,
                  1,
                  17185,
                  11881
                }
              }
            },
            {
              1050,
              {
                {
                  3178,
                  1,
                  17185,
                  11881
                }
              }
            }
          }
        },
        {
          "AddActiveCastSkill",
          21,
          {
            {
              30,
              {
                {
                  3160,
                  1,
                  3036,
                  8081
                }
              }
            },
            {
              60,
              {
                {
                  3187,
                  1,
                  3036,
                  8081
                }
              }
            },
            {
              30,
              {
                {
                  3160,
                  1,
                  3036,
                  8081
                }
              }
            },
            {
              60,
              {
                {
                  3187,
                  1,
                  3036,
                  8081
                }
              }
            },
            {
              30,
              {
                {
                  3160,
                  1,
                  3036,
                  8081
                }
              }
            },
            {
              1050,
              {
                {
                  3187,
                  1,
                  3036,
                  8081
                }
              }
            }
          }
        },
        {
          "AddActiveCastSkill",
          7,
          {
            {
              60,
              {
                {
                  3170,
                  1,
                  7358,
                  7546
                }
              }
            },
            {
              60,
              {
                {
                  3170,
                  1,
                  7358,
                  7546
                }
              }
            },
            {
              1050,
              {
                {
                  3170,
                  1,
                  7358,
                  7546
                }
              }
            }
          }
        },
        {
          "AddActiveCastSkill",
          6,
          {
            {
              60,
              {
                {
                  3176,
                  1,
                  12023,
                  7407
                }
              }
            },
            {
              60,
              {
                {
                  3176,
                  1,
                  12023,
                  7407
                }
              }
            },
            {
              1050,
              {
                {
                  3176,
                  1,
                  12023,
                  7407
                }
              }
            }
          }
        },
        {
          "AddActiveCastSkill",
          5,
          {
            {
              60,
              {
                {
                  3174,
                  1,
                  16932,
                  7415
                }
              }
            },
            {
              60,
              {
                {
                  3174,
                  1,
                  16932,
                  7415
                }
              }
            },
            {
              1050,
              {
                {
                  3174,
                  1,
                  16932,
                  7415
                }
              }
            }
          }
        },
        {
          "AddActiveCastSkill",
          20,
          {
            {
              30,
              {
                {
                  3160,
                  1,
                  3053,
                  4009
                }
              }
            },
            {
              60,
              {
                {
                  3187,
                  1,
                  3053,
                  4009
                }
              }
            },
            {
              30,
              {
                {
                  3160,
                  1,
                  3053,
                  4009
                }
              }
            },
            {
              60,
              {
                {
                  3187,
                  1,
                  3053,
                  4009
                }
              }
            },
            {
              30,
              {
                {
                  3160,
                  1,
                  3053,
                  4009
                }
              }
            },
            {
              1050,
              {
                {
                  3187,
                  1,
                  3053,
                  4009
                }
              }
            }
          }
        },
        {
          "AddActiveCastSkill",
          19,
          {
            {
              30,
              {
                {
                  3157,
                  1,
                  7300,
                  3298
                },
                {
                  3157,
                  1,
                  6726,
                  3319
                },
                {
                  3157,
                  1,
                  7885,
                  3319
                },
                {
                  3160,
                  1,
                  7300,
                  3298
                },
                {
                  3160,
                  1,
                  6726,
                  3319
                },
                {
                  3160,
                  1,
                  7885,
                  3319
                }
              }
            },
            {
              30,
              {
                {
                  3157,
                  1,
                  6466,
                  2963
                },
                {
                  3157,
                  1,
                  6983,
                  2958
                },
                {
                  3157,
                  1,
                  7502,
                  2958
                },
                {
                  3157,
                  1,
                  8011,
                  2974
                },
                {
                  3160,
                  1,
                  6466,
                  2963
                },
                {
                  3160,
                  1,
                  6983,
                  2958
                },
                {
                  3160,
                  1,
                  7502,
                  2958
                },
                {
                  3160,
                  1,
                  8011,
                  2974
                }
              }
            },
            {
              30,
              {
                {
                  3157,
                  1,
                  6187,
                  2588
                },
                {
                  3157,
                  1,
                  6726,
                  2578
                },
                {
                  3157,
                  1,
                  7280,
                  2575
                },
                {
                  3157,
                  1,
                  7837,
                  2588
                },
                {
                  3160,
                  1,
                  6187,
                  2588
                },
                {
                  3160,
                  1,
                  6726,
                  2578
                },
                {
                  3160,
                  1,
                  7280,
                  2575
                },
                {
                  3160,
                  1,
                  7837,
                  2588
                }
              }
            },
            {
              30,
              {
                {
                  3157,
                  1,
                  7743,
                  2163
                },
                {
                  3157,
                  1,
                  6436,
                  2141
                },
                {
                  3157,
                  1,
                  7039,
                  2141
                },
                {
                  3160,
                  1,
                  7743,
                  2163
                },
                {
                  3160,
                  1,
                  6436,
                  2141
                },
                {
                  3160,
                  1,
                  7039,
                  2141
                }
              }
            },
            {
              30,
              {
                {
                  3157,
                  1,
                  7300,
                  3298
                },
                {
                  3157,
                  1,
                  6726,
                  3319
                },
                {
                  3157,
                  1,
                  7885,
                  3319
                },
                {
                  3160,
                  1,
                  7300,
                  3298
                },
                {
                  3160,
                  1,
                  6726,
                  3319
                },
                {
                  3160,
                  1,
                  7885,
                  3319
                }
              }
            },
            {
              30,
              {
                {
                  3157,
                  1,
                  6466,
                  2963
                },
                {
                  3157,
                  1,
                  6983,
                  2958
                },
                {
                  3157,
                  1,
                  7502,
                  2958
                },
                {
                  3157,
                  1,
                  8011,
                  2974
                },
                {
                  3160,
                  1,
                  6466,
                  2963
                },
                {
                  3160,
                  1,
                  6983,
                  2958
                },
                {
                  3160,
                  1,
                  7502,
                  2958
                },
                {
                  3160,
                  1,
                  8011,
                  2974
                }
              }
            },
            {
              30,
              {
                {
                  3157,
                  1,
                  6187,
                  2588
                },
                {
                  3157,
                  1,
                  6726,
                  2578
                },
                {
                  3157,
                  1,
                  7280,
                  2575
                },
                {
                  3157,
                  1,
                  7837,
                  2588
                },
                {
                  3160,
                  1,
                  6187,
                  2588
                },
                {
                  3160,
                  1,
                  6726,
                  2578
                },
                {
                  3160,
                  1,
                  7280,
                  2575
                },
                {
                  3160,
                  1,
                  7837,
                  2588
                }
              }
            },
            {
              1050,
              {
                {
                  3157,
                  1,
                  7743,
                  2163
                },
                {
                  3157,
                  1,
                  6436,
                  2141
                },
                {
                  3157,
                  1,
                  7039,
                  2141
                },
                {
                  3160,
                  1,
                  7743,
                  2163
                },
                {
                  3160,
                  1,
                  6436,
                  2141
                },
                {
                  3160,
                  1,
                  7039,
                  2141
                }
              }
            }
          }
        },
        {
          "AddActiveCastSkill",
          18,
          {
            {
              15,
              {
                {
                  3157,
                  1,
                  11710,
                  2258
                },
                {
                  3160,
                  1,
                  11710,
                  2258
                }
              }
            },
            {
              15,
              {
                {
                  3157,
                  1,
                  12010,
                  3350
                },
                {
                  3160,
                  1,
                  12010,
                  3350
                }
              }
            },
            {
              15,
              {
                {
                  3157,
                  1,
                  11710,
                  2258
                },
                {
                  3160,
                  1,
                  11710,
                  2258
                },
                {
                  3157,
                  1,
                  12932,
                  2778
                },
                {
                  3160,
                  1,
                  12932,
                  2778
                }
              }
            },
            {
              15,
              {
                {
                  3157,
                  1,
                  12010,
                  3350
                },
                {
                  3160,
                  1,
                  12010,
                  3350
                },
                {
                  3157,
                  1,
                  11649,
                  2844
                },
                {
                  3160,
                  1,
                  11649,
                  2844
                }
              }
            },
            {
              15,
              {
                {
                  3157,
                  1,
                  11710,
                  2258
                },
                {
                  3160,
                  1,
                  11710,
                  2258
                },
                {
                  3157,
                  1,
                  12932,
                  2778
                },
                {
                  3160,
                  1,
                  12932,
                  2778
                },
                {
                  3157,
                  1,
                  12814,
                  2237
                },
                {
                  3160,
                  1,
                  12814,
                  2237
                }
              }
            },
            {
              15,
              {
                {
                  3157,
                  1,
                  12010,
                  3350
                },
                {
                  3160,
                  1,
                  12010,
                  3350
                },
                {
                  3157,
                  1,
                  11649,
                  2844
                },
                {
                  3160,
                  1,
                  11649,
                  2844
                },
                {
                  3157,
                  1,
                  12834,
                  3295
                },
                {
                  3160,
                  1,
                  12834,
                  3295
                }
              }
            },
            {
              15,
              {
                {
                  3157,
                  1,
                  12932,
                  2778
                },
                {
                  3160,
                  1,
                  12932,
                  2778
                },
                {
                  3157,
                  1,
                  12814,
                  2237
                },
                {
                  3160,
                  1,
                  12814,
                  2237
                },
                {
                  3157,
                  1,
                  12275,
                  2427
                },
                {
                  3160,
                  1,
                  12275,
                  2427
                }
              }
            },
            {
              15,
              {
                {
                  3157,
                  1,
                  11649,
                  2844
                },
                {
                  3160,
                  1,
                  11649,
                  2844
                },
                {
                  3157,
                  1,
                  12834,
                  3295
                },
                {
                  3160,
                  1,
                  12834,
                  3295
                },
                {
                  3157,
                  1,
                  12382,
                  3000
                },
                {
                  3160,
                  1,
                  12382,
                  3000
                }
              }
            },
            {
              15,
              {
                {
                  3157,
                  1,
                  12814,
                  2237
                },
                {
                  3160,
                  1,
                  12814,
                  2237
                },
                {
                  3157,
                  1,
                  12275,
                  2427
                },
                {
                  3160,
                  1,
                  12275,
                  2427
                }
              }
            },
            {
              15,
              {
                {
                  3157,
                  1,
                  12834,
                  3295
                },
                {
                  3160,
                  1,
                  12834,
                  3295
                },
                {
                  3157,
                  1,
                  12382,
                  3000
                },
                {
                  3160,
                  1,
                  12382,
                  3000
                }
              }
            },
            {
              15,
              {
                {
                  3157,
                  1,
                  12275,
                  2427
                },
                {
                  3160,
                  1,
                  12275,
                  2427
                }
              }
            },
            {
              1050,
              {
                {
                  3157,
                  1,
                  12382,
                  3000
                },
                {
                  3160,
                  1,
                  12382,
                  3000
                }
              }
            }
          }
        },
        {
          "AddActiveCastSkill",
          17,
          {
            {
              30,
              {
                {
                  3157,
                  1,
                  17859,
                  2223
                },
                {
                  3157,
                  1,
                  16864,
                  2245
                },
                {
                  3157,
                  1,
                  16867,
                  3168
                },
                {
                  3157,
                  1,
                  17875,
                  3159
                },
                {
                  3160,
                  1,
                  17859,
                  2223
                },
                {
                  3160,
                  1,
                  16864,
                  2245
                },
                {
                  3160,
                  1,
                  16867,
                  3168
                },
                {
                  3160,
                  1,
                  17875,
                  3159
                }
              }
            },
            {
              30,
              {
                {
                  3157,
                  1,
                  17368,
                  3161
                },
                {
                  3157,
                  1,
                  17368,
                  2157
                },
                {
                  3157,
                  1,
                  17368,
                  2635
                },
                {
                  3160,
                  1,
                  17368,
                  3161
                },
                {
                  3160,
                  1,
                  17368,
                  2157
                },
                {
                  3160,
                  1,
                  17368,
                  2635
                }
              }
            },
            {
              30,
              {
                {
                  3157,
                  1,
                  16833,
                  2692
                },
                {
                  3157,
                  1,
                  17381,
                  2688
                },
                {
                  3157,
                  1,
                  17881,
                  2670
                },
                {
                  3160,
                  1,
                  16833,
                  2692
                },
                {
                  3160,
                  1,
                  17381,
                  2688
                },
                {
                  3160,
                  1,
                  17881,
                  2670
                }
              }
            },
            {
              30,
              {
                {
                  3157,
                  1,
                  17859,
                  2223
                },
                {
                  3157,
                  1,
                  16864,
                  2245
                },
                {
                  3157,
                  1,
                  16867,
                  3168
                },
                {
                  3157,
                  1,
                  17875,
                  3159
                },
                {
                  3160,
                  1,
                  17859,
                  2223
                },
                {
                  3160,
                  1,
                  16864,
                  2245
                },
                {
                  3160,
                  1,
                  16867,
                  3168
                },
                {
                  3160,
                  1,
                  17875,
                  3159
                }
              }
            },
            {
              30,
              {
                {
                  3157,
                  1,
                  17368,
                  3161
                },
                {
                  3157,
                  1,
                  17368,
                  2157
                },
                {
                  3157,
                  1,
                  17368,
                  2635
                },
                {
                  3160,
                  1,
                  17368,
                  3161
                },
                {
                  3160,
                  1,
                  17368,
                  2157
                },
                {
                  3160,
                  1,
                  17368,
                  2635
                }
              }
            },
            {
              1050,
              {
                {
                  3157,
                  1,
                  16833,
                  2692
                },
                {
                  3157,
                  1,
                  17381,
                  2688
                },
                {
                  3157,
                  1,
                  17881,
                  2670
                },
                {
                  3160,
                  1,
                  16833,
                  2692
                },
                {
                  3160,
                  1,
                  17381,
                  2688
                },
                {
                  3160,
                  1,
                  17881,
                  2670
                }
              }
            }
          }
        },
        {
          "AddActiveCastSkill",
          16,
          {
            {
              30,
              {
                {
                  3160,
                  1,
                  22307,
                  2681
                }
              }
            },
            {
              60,
              {
                {
                  3187,
                  1,
                  22307,
                  2681
                }
              }
            },
            {
              30,
              {
                {
                  3160,
                  1,
                  22307,
                  2681
                }
              }
            },
            {
              60,
              {
                {
                  3187,
                  1,
                  22307,
                  2681
                }
              }
            },
            {
              30,
              {
                {
                  3160,
                  1,
                  22307,
                  2681
                }
              }
            },
            {
              1050,
              {
                {
                  3187,
                  1,
                  22307,
                  2681
                }
              }
            }
          }
        }
      },
      [120] = {
        {
          "SynGameTime"
        }
      },
      [180] = {
        {
          "SynGameTime"
        },
        {
          "OnWorldNotify",
          "幻境中出现了心魔幻兽、心魔幻象（可通过地图查看出现区域）"
        },
        {
          "OnAddSingleRoomNpc",
          2102,
          180
        },
        {
          "OnAddSingleRoomNpc",
          2103,
          180
        },
        {
          "OnAddSingleRoomNpc",
          2104,
          180
        },
        {
          "OnAddSingleRoomNpc",
          2101,
          180
        },
        {
          "OnAddSingleRoomNpc",
          2101,
          180
        },
        {
          "OnAddSingleRoomNpc",
          2101,
          180
        }
      },
      [350] = {
        {
          "SynGameTime"
        }
      }
    },
    [3] = {
      [60] = {
        {
          "ReadyCloseRoom",
          "",
          "tbRandomCloseRoomState1"
        },
        {
          "SynGameTime"
        }
      },
      [80] = {
        {
          "SynGameTime"
        }
      }
    },
    [4] = {
      [10] = {
        {
          "SynGameTime"
        },
        {
          "OnWorldNotify",
          "神秘商人现身幻境，据说专卖一些幻境中特有之物（可通过地图查看出现区域）"
        },
        {
          "OnAddSingleRoomNpc",
          1987,
          440
        },
        {
          "OnAddSingleRoomNpc",
          1987,
          440
        }
      },
      [120] = {
        {
          "SynGameTime"
        }
      },
      [180] = {
        {
          "SynGameTime"
        },
        {
          "OnWorldNotify",
          "幻境中出现了心魔幻兽、心魔幻象（可通过地图查看出现区域）"
        },
        {
          "OnAddSingleRoomNpc",
          2105,
          180
        },
        {
          "OnAddSingleRoomNpc",
          2106,
          180
        },
        {
          "OnAddSingleRoomNpc",
          2107,
          180
        },
        {
          "OnAddSingleRoomNpc",
          2111,
          180
        },
        {
          "OnAddSingleRoomNpc",
          2101,
          180
        },
        {
          "OnAddSingleRoomNpc",
          2101,
          180
        },
        {
          "OnAddSingleRoomNpc",
          2101,
          180
        }
      },
      [350] = {
        {
          "SynGameTime"
        }
      }
    },
    [5] = {
      [60] = {
        {
          "ReadyCloseRoom",
          "tbRoomIndex1"
        },
        {
          "SynGameTime"
        }
      },
      [80] = {
        {
          "SynGameTime"
        }
      }
    },
    [6] = {
      [10] = {
        {
          "SynGameTime"
        },
        {
          "OnWorldNotify",
          "神秘商人现身幻境，据说专卖一些幻境中特有之物（可通过地图查看出现区域）"
        },
        {
          "OnAddSingleRoomNpc",
          1987,
          440
        },
        {
          "OnAddSingleRoomNpc",
          1987,
          440
        }
      },
      [120] = {
        {
          "SynGameTime"
        }
      },
      [180] = {
        {
          "SynGameTime"
        },
        {
          "OnWorldNotify",
          "幻境中出现了心魔幻兽、心魔幻象（可通过地图查看出现区域）"
        },
        {
          "OnAddSingleRoomNpc",
          2108,
          180
        },
        {
          "OnAddSingleRoomNpc",
          2109,
          180
        },
        {
          "OnAddSingleRoomNpc",
          2110,
          180
        },
        {
          "OnAddSingleRoomNpc",
          2112,
          180
        },
        {
          "OnAddSingleRoomNpc",
          2101,
          180
        },
        {
          "OnAddSingleRoomNpc",
          2101,
          180
        },
        {
          "OnAddSingleRoomNpc",
          2101,
          180
        }
      },
      [350] = {
        {
          "SynGameTime"
        }
      }
    },
    [7] = {
      [60] = {
        {
          "ReadyCloseRoom",
          "tbRoomIndex2"
        },
        {
          "SynGameTime"
        }
      },
      [80] = {
        {
          "SynGameTime"
        }
      }
    },
    [8] = {
      [1] = {
        {
          "SynGameTime"
        },
        {
          "AddRandPosBuffSet",
          "1000|30;1001|15;1002|15;1003|15;1004|15;1005|10;1",
          1,
          {
            "last_buff_1",
            "last_buff_2",
            "last_buff_3",
            "last_buff_4"
          },
          {1, 1}
        }
      },
      [61] = {
        {
          "SynGameTime"
        },
        {
          "AddRandPosBuffSet",
          "1000|30;1001|15;1002|15;1003|15;1004|15;1005|10;1",
          1,
          {
            "last_buff_1",
            "last_buff_2",
            "last_buff_3",
            "last_buff_4"
          },
          {1, 1}
        }
      },
      [121] = {
        {
          "SynGameTime"
        },
        {
          "AddRandPosBuffSet",
          "1000|30;1001|15;1002|15;1003|15;1004|15;1005|10;1",
          1,
          {
            "last_buff_1",
            "last_buff_2",
            "last_buff_3",
            "last_buff_4"
          },
          {1, 1}
        }
      },
      [181] = {
        {
          "SynGameTime"
        },
        {
          "AddRandPosBuffSet",
          "1000|30;1001|15;1002|15;1003|15;1004|15;1005|10;1",
          1,
          {
            "last_buff_1",
            "last_buff_2",
            "last_buff_3",
            "last_buff_4"
          },
          {1, 1}
        }
      }
    }
  },
  tbActiveTransClient = {
    [3] = {
      [30] = {
        szFunc = "CheckNotSafeRoom",
        tbParam = {}
      },
      [20] = {
        szFunc = "CheckNotSafeRoom",
        tbParam = {}
      },
      [10] = {
        szFunc = "CheckNotSafeRoom",
        tbParam = {}
      },
      [2] = {
        szFunc = "ShowRoomCloseEffect",
        tbParam = {}
      }
    },
    [5] = {
      [30] = {
        szFunc = "CheckNotSafeRoom",
        tbParam = {}
      },
      [20] = {
        szFunc = "CheckNotSafeRoom",
        tbParam = {}
      },
      [10] = {
        szFunc = "CheckNotSafeRoom",
        tbParam = {}
      },
      [2] = {
        szFunc = "ShowRoomCloseEffect",
        tbParam = {}
      }
    },
    [7] = {
      [30] = {
        szFunc = "CheckNotSafeRoom",
        tbParam = {}
      },
      [20] = {
        szFunc = "CheckNotSafeRoom",
        tbParam = {}
      },
      [10] = {
        szFunc = "CheckNotSafeRoom",
        tbParam = {}
      },
      [2] = {
        szFunc = "ShowRoomCloseEffect",
        tbParam = {}
      }
    }
  },
  tbDrapList = {
    tbBoxAward_1 = {
      {
        0.625,
        {
          "RandItemCount",
          3299,
          2,
          4
        }
      },
      {
        0.025,
        {
          "item",
          2400,
          1
        }
      },
      {
        0.075,
        {"SkillBook", 0}
      },
      {
        0.025,
        {
          "item",
          1391,
          1
        }
      },
      {
        0.25,
        {
          "RandMoney",
          15,
          25
        }
      }
    },
    tbBoxAward_2 = {
      {
        0.71,
        {
          "RandItemCount",
          3299,
          4,
          8
        }
      },
      {
        0.015,
        {
          "item",
          2400,
          1
        }
      },
      {
        0.0075,
        {
          "item",
          3307,
          1
        }
      },
      {
        0.05,
        {"SkillBook", 0}
      },
      {
        0.025,
        {
          "item",
          3308,
          1
        }
      },
      {
        0.015,
        {
          "item",
          1391,
          1
        }
      },
      {
        0.0075,
        {
          "item",
          1392,
          1
        }
      },
      {
        0.17,
        {
          "RandMoney",
          20,
          40
        }
      }
    },
    tbBoxAward_3 = {
      {
        0.625,
        {
          "RandItemCount",
          3299,
          8,
          16
        }
      },
      {
        0.025,
        {
          "item",
          3307,
          1
        }
      },
      {
        0.075,
        {
          "item",
          3308,
          1
        }
      },
      {
        0.025,
        {
          "item",
          1392,
          1
        }
      },
      {
        0.25,
        {
          "RandMoney",
          30,
          60
        }
      }
    },
    tbLeaderAward_1 = {
      {
        0.6,
        {
          "RandItemCount",
          3299,
          2,
          4
        }
      },
      {
        0.02,
        {
          "item",
          2400,
          1
        }
      },
      {
        0.06,
        {"SkillBook", 0}
      },
      {
        0.02,
        {
          "item",
          1391,
          1
        }
      },
      {
        0.3,
        {
          "RandMoney",
          15,
          25
        }
      }
    },
    tbLeaderAward_2 = {
      {
        0.592,
        {
          "RandItemCount",
          3299,
          4,
          8
        }
      },
      {
        0.016,
        {
          "item",
          2400,
          1
        }
      },
      {
        0.008,
        {
          "item",
          3307,
          1
        }
      },
      {
        0.04,
        {"SkillBook", 0}
      },
      {
        0.02,
        {
          "item",
          3308,
          1
        }
      },
      {
        0.016,
        {
          "item",
          1391,
          1
        }
      },
      {
        0.008,
        {
          "item",
          1392,
          1
        }
      },
      {
        0.3,
        {
          "RandMoney",
          20,
          40
        }
      }
    },
    tbLeaderAward_3 = {
      {
        0.6,
        {
          "RandItemCount",
          3299,
          8,
          12
        }
      },
      {
        0.02,
        {
          "item",
          3307,
          1
        }
      },
      {
        0.06,
        {
          "item",
          3308,
          1
        }
      },
      {
        0.02,
        {
          "item",
          1392,
          1
        }
      },
      {
        0.3,
        {
          "RandMoney",
          40,
          80
        }
      }
    },
    tbSuperBoxAward_1 = {
      {
        0.6,
        {
          "RandItemCount",
          3299,
          2,
          4
        }
      },
      {
        0.02,
        {
          "item",
          2400,
          1
        }
      },
      {
        0.06,
        {"SkillBook", 0}
      },
      {
        0.02,
        {
          "item",
          1391,
          1
        }
      },
      {
        0.3,
        {
          "RandMoney",
          15,
          25
        }
      }
    },
    tbSuperBoxAward_2 = {
      {
        0.592,
        {
          "RandItemCount",
          3299,
          4,
          8
        }
      },
      {
        0.016,
        {
          "item",
          2400,
          1
        }
      },
      {
        0.008,
        {
          "item",
          3307,
          1
        }
      },
      {
        0.04,
        {"SkillBook", 0}
      },
      {
        0.02,
        {
          "item",
          3308,
          1
        }
      },
      {
        0.016,
        {
          "item",
          1391,
          1
        }
      },
      {
        0.008,
        {
          "item",
          1392,
          1
        }
      },
      {
        0.3,
        {
          "RandMoney",
          20,
          40
        }
      }
    },
    tbSuperBoxAward_3 = {
      {
        0.6,
        {
          "RandItemCount",
          3299,
          8,
          12
        }
      },
      {
        0.02,
        {
          "item",
          3307,
          1
        }
      },
      {
        0.06,
        {
          "item",
          3308,
          1
        }
      },
      {
        0.02,
        {
          "item",
          1392,
          1
        }
      },
      {
        0.3,
        {
          "RandMoney",
          40,
          80
        }
      }
    },
    tbBossAward_2 = {
      {
        0.6,
        {
          "RandItemCount",
          3299,
          4,
          8
        }
      },
      {
        0.016,
        {
          "item",
          2400,
          1
        }
      },
      {
        0.008,
        {
          "item",
          3307,
          1
        }
      },
      {
        0.04,
        {"SkillBook", 0}
      },
      {
        0.02,
        {
          "item",
          3308,
          1
        }
      },
      {
        0.016,
        {
          "item",
          1391,
          1
        }
      },
      {
        0.008,
        {
          "item",
          1392,
          1
        }
      },
      {
        0.292,
        {
          "RandMoney",
          30,
          50
        }
      }
    },
    tbBossAward_3 = {
      {
        0.6,
        {
          "RandItemCount",
          3299,
          8,
          16
        }
      },
      {
        0.02,
        {
          "item",
          3307,
          1
        }
      },
      {
        0.06,
        {
          "item",
          3308,
          1
        }
      },
      {
        0.02,
        {
          "item",
          1392,
          1
        }
      },
      {
        0.3,
        {
          "RandMoney",
          40,
          80
        }
      }
    }
  }
}
local tbDefine = InDifferBattle.tbDefine
InDifferBattle.tbRoomSetting = {
  tbSignleRooms = {
    {1},
    {
      2,
      3,
      4,
      5,
      6,
      7,
      8,
      9
    }
  },
  tbSingleRoomNpc = {
    [1987] = {
      nLevel = 1,
      nDir = 48,
      szName = "商人",
      nRoomGroup = 2,
      szIcon = "DreamlandIcon1"
    },
    [2101] = {
      nLevel = 1,
      nDir = 48,
      szName = "幻象",
      nRoomGroup = 2,
      szIcon = "DreamlandIcon4"
    },
    [2102] = {
      nLevel = 80,
      szName = "精英",
      nRoomGroup = 2,
      szIcon = "DreamlandIcon2",
      szDropAwardList = {
        [2] = "tbLeaderAward_1"
      },
      tbRankAwardNum = {
        8,
        5,
        3
      }
    },
    [2103] = {
      nLevel = 80,
      szName = "精英",
      nRoomGroup = 2,
      szIcon = "DreamlandIcon2",
      szDropAwardList = {
        [2] = "tbLeaderAward_1"
      },
      tbRankAwardNum = {
        8,
        5,
        3
      }
    },
    [2104] = {
      nLevel = 80,
      szName = "精英",
      nRoomGroup = 2,
      szIcon = "DreamlandIcon2",
      szDropAwardList = {
        [2] = "tbLeaderAward_1"
      },
      tbRankAwardNum = {
        8,
        5,
        3
      }
    },
    [2105] = {
      nLevel = 80,
      szName = "精英",
      nRoomGroup = 2,
      szIcon = "DreamlandIcon2",
      szDropAwardList = {
        [4] = "tbLeaderAward_2"
      },
      tbRankAwardNum = {
        8,
        5,
        3
      }
    },
    [2106] = {
      nLevel = 80,
      szName = "精英",
      nRoomGroup = 2,
      szIcon = "DreamlandIcon2",
      szDropAwardList = {
        [4] = "tbLeaderAward_2"
      },
      tbRankAwardNum = {
        8,
        5,
        3
      }
    },
    [2107] = {
      nLevel = 80,
      szName = "精英",
      nRoomGroup = 2,
      szIcon = "DreamlandIcon2",
      szDropAwardList = {
        [4] = "tbLeaderAward_2"
      },
      tbRankAwardNum = {
        8,
        5,
        3
      }
    },
    [2111] = {
      nLevel = 80,
      szName = "首领",
      nRoomGroup = 1,
      szIcon = "DreamlandIcon3",
      bBoss = true,
      szDropAwardList = {
        [4] = "tbBossAward_2"
      },
      tbRankAwardNum = {
        18,
        12,
        8,
        6,
        4
      }
    },
    [2108] = {
      nLevel = 80,
      szName = "精英",
      nRoomGroup = 2,
      szIcon = "DreamlandIcon2",
      szDropAwardList = {
        [6] = "tbLeaderAward_3"
      },
      tbRankAwardNum = {
        8,
        5,
        3
      }
    },
    [2109] = {
      nLevel = 80,
      szName = "精英",
      nRoomGroup = 2,
      szIcon = "DreamlandIcon2",
      szDropAwardList = {
        [6] = "tbLeaderAward_3"
      },
      tbRankAwardNum = {
        8,
        5,
        3
      }
    },
    [2110] = {
      nLevel = 80,
      szName = "精英",
      nRoomGroup = 2,
      szIcon = "DreamlandIcon2",
      szDropAwardList = {
        [6] = "tbLeaderAward_3"
      },
      tbRankAwardNum = {
        8,
        5,
        3
      }
    },
    [2112] = {
      nLevel = 80,
      szName = "首领",
      nRoomGroup = 1,
      szIcon = "DreamlandIcon3",
      bBoss = true,
      szDropAwardList = {
        [6] = "tbBossAward_3"
      },
      tbRankAwardNum = {
        18,
        12,
        8,
        6,
        4
      }
    }
  },
  tbRandomCloseRoomState1 = {
    {
      24,
      25,
      11,
      12,
      14,
      16,
      18,
      22
    },
    {
      24,
      25,
      12,
      14,
      16,
      19,
      22,
      23
    },
    {
      10,
      11,
      12,
      13,
      14,
      17,
      21,
      23
    },
    {
      25,
      10,
      12,
      14,
      17,
      20,
      21,
      22
    },
    {
      10,
      12,
      14,
      15,
      18,
      21,
      22,
      23
    },
    {
      25,
      12,
      14,
      15,
      16,
      19,
      20,
      21
    },
    {
      24,
      11,
      12,
      14,
      17,
      19,
      22,
      23
    },
    {
      10,
      12,
      14,
      15,
      16,
      19,
      20,
      21
    },
    {
      24,
      25,
      11,
      12,
      14,
      15,
      18,
      19
    },
    {
      24,
      25,
      10,
      11,
      12,
      13,
      18,
      17
    },
    {
      12,
      13,
      14,
      15,
      18,
      20,
      21,
      23
    },
    {
      10,
      11,
      12,
      17,
      18,
      19,
      22,
      23
    },
    {
      13,
      14,
      15,
      16,
      18,
      21,
      22,
      23
    },
    {
      24,
      11,
      15,
      16,
      17,
      18,
      22,
      23
    }
  }
}
local tbDefine = InDifferBattle.tbDefine
function InDifferBattle:CanSignUp(pPlayer, szBattleType)
  if MODULE_GAMESERVER and not Env:CheckSystemSwitch(pPlayer, Env.SW_SwitchMap) then
    return false, "当前状态不允许切换地图"
  end
  if szBattleType then
    if szBattleType == "Normal" then
      if DegreeCtrl:GetDegree(pPlayer, "InDifferBattle") < 1 then
        return false, "参与次数不足"
      end
    elseif not self:IsQualifyInBattleType(pPlayer, szBattleType) then
      local szQualifyName = InDifferBattle.tbBattleTypeSetting[szBattleType].szName
      return false, string.format("未获得%s赛资格", szQualifyName), szQualifyName
    end
  end
  if Battle.LegalMap[pPlayer.nMapTemplateId] ~= 1 and (Map:GetClassDesc(pPlayer.nMapTemplateId) ~= "fight" or pPlayer.nFightMode ~= 0) then
    return false, "当前所在地不能被传入心魔幻境准备场"
  end
  return true
end
function InDifferBattle:GetRoomIndexByRowCol(nRow, nCol)
  local tbTemp = self.tbRooomPosSetting[nRow]
  if not tbTemp then
    return
  end
  local tbCol = tbTemp[nCol]
  if tbCol then
    return tbCol.Index
  end
end
function InDifferBattle:CanEnhance(pPlayer, nIndex)
  local v = self.tbDefine.tbEnhanceScroll[nIndex]
  if not v then
    return
  end
  local nCurLevel = Strengthen:GetStrengthenLevel(pPlayer, v.tbEquipPos[1])
  local nNextLevel = nCurLevel + self.tbDefine.nStrengthStep
  local nCost = v.tbEnhanceCost[nNextLevel]
  if not nCost then
    return
  end
  local nItemCount = pPlayer.GetItemCountInBags(self.tbDefine.nEnhanceItemId)
  if nCost > nItemCount then
    return false, "强化水晶不足"
  end
  return true, nCost, v.tbEquipPos, nNextLevel
end
function InDifferBattle:ComInit()
  local tbRooomPosSet = {}
  local tbFile = LoadTabFile("Setting/InDifferBattle/RandPosSet.tab", "dsddd", nil, {
    "Index",
    "Name",
    "PosX",
    "PosY",
    "Dir"
  })
  for i, v in ipairs(tbFile) do
    tbRooomPosSet[v.Index] = tbRooomPosSet[v.Index] or {}
    tbRooomPosSet[v.Index][v.Name] = {
      v.PosX,
      v.PosY,
      v.Dir
    }
  end
  self.tbRooomPosSet = tbRooomPosSet
  local tbFile = LoadTabFile("Setting/InDifferBattle/RoomPos.tab", "ddddddddddd", nil, {
    "row",
    "col",
    "Index",
    "LeftX",
    "LeftY",
    "RightX",
    "RightY",
    "BottomX",
    "BottomY",
    "TopX",
    "TopY"
  })
  local tbRooomPosSetting = {}
  local tbRoomIndex = {}
  for i, v in ipairs(tbFile) do
    tbRooomPosSetting[v.row] = tbRooomPosSetting[v.row] or {}
    tbRooomPosSetting[v.row][v.col] = {
      L = {
        v.LeftX,
        v.LeftY,
        v.Index
      },
      R = {
        v.RightX,
        v.RightY,
        v.Index
      },
      B = {
        v.BottomX,
        v.BottomY,
        v.Index
      },
      T = {
        v.TopX,
        v.TopY,
        v.Index
      },
      Index = v.Index
    }
    tbRoomIndex[v.Index] = {
      v.row,
      v.col
    }
  end
  self.tbRoomIndex = tbRoomIndex
  local tbRoomIndex1 = {}
  local tbRoomIndex2 = {}
  self.tbRooomPosSetting = tbRooomPosSetting
  local tbRoomTrapToPos = {}
  for i = 1, 5 do
    for j = 1, 5 do
      if j > 1 then
        tbRoomTrapToPos["Trap" .. i .. j .. "L"] = tbRooomPosSetting[i][j - 1].R
      end
      if j < 5 then
        tbRoomTrapToPos["Trap" .. i .. j .. "R"] = tbRooomPosSetting[i][j + 1].L
      end
      if i > 1 then
        tbRoomTrapToPos["Trap" .. i .. j .. "T"] = tbRooomPosSetting[i - 1][j].B
      end
      if i < 5 then
        tbRoomTrapToPos["Trap" .. i .. j .. "B"] = tbRooomPosSetting[i + 1][j].T
      end
      if i == 1 or i == 5 or j == 1 or j == 5 then
        table.insert(tbRoomIndex1, tbRooomPosSetting[i][j].Index)
      elseif i ~= 3 or j ~= 3 then
        table.insert(tbRoomIndex2, tbRooomPosSetting[i][j].Index)
      end
    end
  end
  self.tbRoomTrapToPos = tbRoomTrapToPos
  self.tbRoomSetting.tbRoomIndex1 = tbRoomIndex1
  self.tbRoomSetting.tbRoomIndex2 = tbRoomIndex2
  self.tbRandSkillBookRevrse = {}
  for i, v in ipairs(self.tbRandSkillBook) do
    self.tbRandSkillBookRevrse[v] = i
  end
  if MODULE_ZONESERVER then
    local tbFile = LoadTabFile("Setting/InDifferBattle/NpcPath.tab", "sdd", nil, {
      "ClassName",
      "X",
      "Y"
    })
    local tbNpcMovePath = {}
    for i, v in ipairs(tbFile) do
      tbNpcMovePath[v.ClassName] = tbNpcMovePath[v.ClassName] or {}
      table.insert(tbNpcMovePath[v.ClassName], {
        v.X,
        v.Y
      })
    end
    self.tbNpcMovePath = tbNpcMovePath
    local fnCheckIsStateFight = function(nState)
      if nState == 2 or nState == 4 or nState == 6 or nState == 8 then
        return true
      end
    end
    local fnCheckAwardParam = function(tbParam)
      local szType, nParam1, nParam2, nParam3 = unpack(tbParam)
      if szType == "item" then
      elseif szType == "Jade" then
      elseif szType == "SkillBook" then
        if nParam1 > 4 and nParam1 < 0 then
          return false
        end
      elseif szType == "RandMoney" then
      elseif szType == "RandBuff" then
      elseif szType == "RandItemCount" then
        if nParam3 < nParam2 then
          return false
        end
      else
        return false
      end
      return true
    end
    for k1, v1 in pairs(tbDefine.tbOpenBoxType) do
      for k2, v2 in pairs(v1) do
        assert(fnCheckIsStateFight(k2), k2)
        local nTotal = 0
        for i3, v3 in ipairs(v2) do
          nTotal = nTotal + v3[1]
          v3[1] = nTotal
          for i4, v4 in ipairs(v3[2]) do
            if v4[1] == "OnSendRandDropAwardToTeam" then
              assert(tbDefine.tbDrapList[v4[2]], k1 .. "." .. k2 .. "," .. i3 .. "," .. i4)
            end
          end
        end
        assert(nTotal <= 1.01, k1)
      end
    end
    for k1, v1 in pairs(tbDefine.tbDrapList) do
      local nRate = 0
      for i2, v2 in ipairs(v1) do
        nRate = nRate + v2[1]
        v2[1] = nRate
        assert(fnCheckAwardParam(v2[2]), k1 .. "," .. i2)
      end
      assert(nRate <= 1.01, k1)
    end
    for k1, v1 in pairs(InDifferBattle.tbRoomSetting.tbSingleRoomNpc) do
      assert(InDifferBattle.tbRoomSetting.tbSignleRooms[v1.nRoomGroup], k1 .. "nRoomGroup11")
      if v1.szDropAwardList then
        for k2, v2 in pairs(v1.szDropAwardList) do
          assert(fnCheckIsStateFight(k2), k1 .. "," .. k2)
          assert(tbDefine.tbDrapList[v2], k1 .. "," .. k2)
        end
        assert(v1.tbRankAwardNum, k1)
        assert(v1.nLevel, k1)
        assert(v1.nRoomGroup, k1)
        assert(v1.szName, k1)
        assert(v1.szIcon, k1)
      end
    end
    for k1, v1 in pairs(tbDefine.tbSellWarePropSetting) do
      assert(fnCheckIsStateFight(k1), k1)
      for i2, v2 in ipairs(v1) do
        local v3 = v2[1]
        if type(v3) == "number" then
          assert(tbDefine.tbSellWareSetting[v3], v3)
        else
          for _, v4 in ipairs(v3) do
            assert(tbDefine.tbSellWareSetting[v4], v4)
          end
        end
      end
    end
  end
end
function InDifferBattle:GetRandSkillBookId(nRandBook, nFaction)
  local nType = self.tbRandSkillBookRevrse[nRandBook]
  if not nType then
    return
  end
  return Item:GetClass("SkillBook"):GetFactionTypeBook(nType, nFaction)
end
function InDifferBattle:GetRandSkillBookOriId(nBookId)
  local nType = Item:GetClass("SkillBook"):GetBookType(nBookId)
  if nType then
    return self.tbRandSkillBook[nType]
  end
end
function InDifferBattle:GetSellSumPrice(dwTemplateId, nCount)
  local nOriBook = self:GetRandSkillBookOriId(dwTemplateId)
  if nOriBook then
    dwTemplateId = nOriBook
  end
  local tbItemInfo = self.tbDefine.tbSellWareSetting[dwTemplateId]
  if tbItemInfo then
    return math.floor(tbItemInfo.nPrice * nCount * self.tbDefine.nSelllPricePercent), tbDefine.szMonoeyType
  end
end
function InDifferBattle:GetBuySumPrice(dwTemplateId, nCount)
  local nOriBook = self:GetRandSkillBookOriId(dwTemplateId)
  if nOriBook then
    dwTemplateId = nOriBook
  end
  local tbItemInfo = self.tbDefine.tbSellWareSetting[dwTemplateId]
  if tbItemInfo then
    return math.floor(tbItemInfo.nPrice * nCount), tbDefine.szMonoeyType
  end
end
function InDifferBattle:GetEvaluationFromScore(nScore)
  local nGrade = 1
  local tbEvaluationSetting = InDifferBattle.tbDefine.tbEvaluationSetting
  for i, v in ipairs(tbEvaluationSetting) do
    if nScore >= v.nScoreMin then
      nGrade = i
    end
  end
  return nGrade, tbEvaluationSetting[nGrade]
end
function InDifferBattle:GetNextOpenTime(szType, nTime)
  nTime = nTime or GetTime()
  local tbType = self.tbBattleTypeSetting[szType]
  local szFunc = tbType.szOpenTimeFunc
  return self[szFunc](self, tbType, nTime)
end
function InDifferBattle:GetNextOpenTimeMonth(tbType, nTime)
  local nTimeRet = Lib:GetTimeByWeekInMonth(nTime, tbType.OpenTimeWeek, tbType.OpenTimeWeekDay, tbType.OpenTimeHour, tbType.OpenTimeMinute, 0)
  if nTime > nTimeRet then
    local tbTimeNow = os.date("*t", nTime)
    local nSec = os.time({
      year = tbTimeNow.year,
      month = tbTimeNow.month + 1,
      day = 1,
      hour = 1,
      min = 0,
      sec = 0
    })
    nTimeRet = Lib:GetTimeByWeekInMonth(nSec, tbType.OpenTimeWeek, tbType.OpenTimeWeekDay, tbType.OpenTimeHour, tbType.OpenTimeMinute, 0)
  end
  local tbTimeNow = os.date("*t", nTimeRet)
  if tbTimeNow.year == 2017 and (tbTimeNow.month == 6 or tbTimeNow.month == 7) then
    local nSec = os.time({
      year = 2017,
      month = 8,
      day = 1,
      hour = 1,
      min = 0,
      sec = 0
    })
    nTimeRet = Lib:GetTimeByWeekInMonth(nSec, tbType.OpenTimeWeek, tbType.OpenTimeWeekDay, tbType.OpenTimeHour, tbType.OpenTimeMinute, 0)
  end
  return nTimeRet
end
function InDifferBattle:GetNextOpenTimeSeason(tbType, nTime)
  local tbTimeNow = os.date("*t", nTime)
  local nSeason = math.ceil(tbTimeNow.month / 3)
  local nSec = os.time({
    year = tbTimeNow.year,
    month = nSeason * 3,
    day = 1,
    hour = tbType.OpenTimeHour,
    min = tbType.OpenTimeMinute,
    sec = 0
  })
  return Lib:GetTimeByWeekInMonth(nSec, tbType.OpenTimeWeek, tbType.OpenTimeWeekDay, tbType.OpenTimeHour, tbType.OpenTimeMinute, 0)
end
function InDifferBattle:GetNextOpenTimeYear(tbType, nTime)
  local nSec = os.time({
    year = 2020,
    month = 7,
    day = 1,
    hour = tbType.OpenTimeHour,
    min = tbType.OpenTimeMinute,
    sec = 0
  })
  return Lib:GetTimeByWeekInMonth(nSec, tbType.OpenTimeWeek, tbType.OpenTimeWeekDay, tbType.OpenTimeHour, tbType.OpenTimeMinute, 0)
end
function InDifferBattle:IsQualifyInBattleType(pPlayer, szType, bNext)
  local tbType = self.tbBattleTypeSetting[szType]
  local nNowQualifyTime = pPlayer.GetUserValue(self.tbDefine.SAVE_GROUP, tbType.nKeyQualifyTime)
  if nNowQualifyTime == 0 then
    return
  end
  local nNow = GetTime()
  if not bNext then
    nNow = nNow - 360
  end
  local nCurOpenBattleTime = self:GetNextOpenTime(szType, nNow)
  local bRet = Lib:GetLocalDay(nNowQualifyTime) == Lib:GetLocalDay(nCurOpenBattleTime)
  return bRet, nCurOpenBattleTime
end
function InDifferBattle:GetCurOpenQualifyType()
  local nNow = GetTime()
  for k, v in pairs(self.tbBattleTypeSetting) do
    if v.nNeedGrade and (MODULE_ZONESERVER or v.szOpenTimeFrame and GetTimeFrameState(v.szOpenTimeFrame) == 1) then
      local nCurOpenBattleTime = self:GetNextOpenTime(k, nNow - 3600)
      if math.abs(nCurOpenBattleTime - nNow) < 1800 then
        return k
      end
    end
  end
end
function InDifferBattle:GetTopCanSignBattleType(tbPlayers, tbReadyMapList)
  for i, v in ipairs(tbReadyMapList) do
    local nReadyMapId, szBattleType, nLevel = unpack(v)
    if szBattleType == "Normal" then
      return szBattleType, nReadyMapId, ""
    else
      for i, pPlayer in ipairs(tbPlayers) do
        if self:IsQualifyInBattleType(pPlayer, szBattleType) then
          return szBattleType, nReadyMapId, pPlayer.szName
        end
      end
    end
  end
end
InDifferBattle:ComInit()
if MODULE_ZONESERVER then
  local function fnCheckData()
    local nTotalGameFightTime = 0
    for i = 2, #tbDefine.STATE_TRANS - 1 do
      local v = tbDefine.STATE_TRANS[i]
      nTotalGameFightTime = nTotalGameFightTime + v.nSeconds
    end
    tbDefine.nTotalGameFightTime = nTotalGameFightTime
    assert(1 < #InDifferBattle.tbRoomSetting.tbRandomCloseRoomState1)
    for i, v in ipairs(InDifferBattle.tbRoomSetting.tbRandomCloseRoomState1) do
      assert(#v == 8, i)
      local tbV = {}
      for i2, v2 in ipairs(v) do
        assert(not tbV[v2], i .. "," .. i2)
        tbV[v2] = true
      end
    end
    assert(0 < tbDefine.nCloseRoomPunishPersent and 1 > tbDefine.nCloseRoomPunishPersent)
    for nState, v1 in pairs(tbDefine.tbActiveTrans) do
      local tbManinTrans = tbDefine.STATE_TRANS[nState]
      for nScends, v2 in pairs(v1) do
        assert(nScends < tbManinTrans.nSeconds, nState .. "," .. nScends)
        for i3, v3 in ipairs(v2) do
          local szFuncName = v3[1]
          if szFuncName == "AddRandPosNpcSet" then
            local szTag = table.concat({
              nState,
              nScends,
              i3
            }, ",")
            for _, v4 in ipairs(v3[5]) do
              assert(InDifferBattle.tbRooomPosSet[v3[4]][v4], szTag .. "," .. v4)
            end
            local nMin, nMax = unpack(v3[6])
            assert(nMin <= nMax, szTag)
            assert(nMax <= #v3[5], szTag)
          elseif szFuncName == "AddRandTypeSet" then
            local nRate = 0
            for i4, v4 in ipairs(v3[4]) do
              nRate = v4[1] + nRate
              v4[1] = nRate
            end
            assert(nRate <= 1.01, table.concat({
              nState,
              nScends,
              i3
            }, ","))
          elseif szFuncName == "AddRandTypeSetTimer" then
            local nRate = 0
            for i4, v4 in ipairs(v3[5]) do
              nRate = v4[1] + nRate
              v4[1] = nRate
            end
            assert(nRate <= 1.01, table.concat({
              nState,
              nScends,
              i3
            }, ","))
          elseif szFuncName == "AddAutoHideWalkPathNpc" then
            assert(InDifferBattle.tbNpcMovePath[v3[5]], table.concat({
              nState,
              nScends,
              i3
            }, ","))
          end
        end
      end
    end
    for k, v in pairs(InDifferBattle.tbRoomSetting.tbSignleRooms) do
      local tbHased = {}
      for i2, v2 in ipairs(v) do
        assert(not tbHased[v2], k .. " tbSignleRooms")
        tbHased[v2] = 1
      end
    end
    local nTotalRate = 0
    for i, v in ipairs(tbDefine.tbBattleNpcDropSettingItem) do
      nTotalRate = nTotalRate + v[2]
      v[2] = nTotalRate
    end
    assert(nTotalRate <= 10000)
    local nTotalRate = 0
    for i, v in ipairs(tbDefine.tbInitGiveItem) do
      nTotalRate = nTotalRate + v[1]
      v[1] = nTotalRate
    end
    assert(nTotalRate <= 10000)
    for nRoomIndex = 1, 25 do
      local tbPosSet = InDifferBattle.tbRooomPosSet[nRoomIndex]
      local v = tbPosSet.center
      assert(v, nRoomIndex)
      local nRow, nCol = unpack(InDifferBattle.tbRoomIndex[nRoomIndex])
      for szPosName, tbRowCol in pairs(tbDefine.tbGateDirectionModify) do
        local nRowModi, nColModi = unpack(tbRowCol)
        local nTarRoomIndex = InDifferBattle:GetRoomIndexByRowCol(nRow + nRowModi, nCol + nColModi)
        if nTarRoomIndex then
          assert(tbPosSet[szPosName], nRoomIndex .. "," .. szPosName .. "," .. nTarRoomIndex)
        end
      end
    end
    for _, v in ipairs(tbDefine.tbLastSwitchRandPosSet) do
      assert(InDifferBattle.tbRooomPosSet[1][v], v)
    end
  end
  fnCheckData()
end
