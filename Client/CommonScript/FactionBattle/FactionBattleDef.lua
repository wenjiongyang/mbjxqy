local preEnv
if FactionBattle then
  preEnv = _G
  setfenv(1, FactionBattle)
end
FREEDOMPK_POINT = "Setting/FactionBattle/freedompk_point.tab"
ELIMINATION_POINT = "Setting/FactionBattle/elimination_point.tab"
BOX_POINT = "Setting/FactionBattle/box_point.tab"
MIN_LEVEL = 30
MAX_ATTEND_PLAYER = 300
MIN_ATTEND_PLAYER = 4
AREA_PLAYER = 30
PREPARE_MAP_TAMPLATE_ID = 1024
FREEPK_MAP_TAMPLATE_ID = 1025
FREEDOM_PK_PROTECT_TIME = 3
FREEDOM_PK_REVIVE_TIME = 60
ELIMI_PROTECT_TIME = 3
END_DELAY = 5
FLAG_TEMPLATE_ID = 728
FLAG_EXIST_TIME = 180
GOUHUO_NPC_ID = 729
BOX_NPC_ID = 727
PICK_BOX_TIME = 2
BOX_EXSIT_TIME = 120
BOX_MAX_GET = 8
NOTHING = 0
SIGN_UP = 1
FREE_PK = 2
FREE_PK_REST = 3
READY_ELIMINATION = 4
ELIMINATION = 5
ELIMINATION_REST = 6
CHAMPION_AWARD = 7
END_AWARD = 8
END = 9
BEFORE_REMIND_TIME = 30
START_NOTIFY_TIME = 1380
WINNER_NOTIFY_TIME = 600
MAX_SAVE_DATA_COUNT = 30
PK_DMG_RATE = {
  [1] = 75,
  [2] = 90,
  [3] = 60,
  [4] = 60,
  [5] = 65,
  [6] = 60,
  [7] = 70,
  [8] = 60,
  [9] = 60,
  [10] = 60,
  [11] = 70,
  [12] = 60,
  [13] = 60,
  [14] = 70
}
ENTER_POS = {
  {3175, 8023},
  {3815, 8023},
  {6160, 8038},
  {7582, 8028},
  {8222, 8033},
  {6830, 7261},
  {6849, 6572},
  {4695, 7207},
  {4714, 6621},
  {3112, 5478},
  {3879, 5492}
}
FLAG_POS = {5726, 6592}
AWARD_POS = {5789, 7300}
FALG_TICK_BACK = {5171, 7794}
GOUHUO_POS = {6844, 5517}
tbRevPos = {5491, 8038}
FINAL_AWARD_MAIL_TITLE = preEnv.XT("门派竞技奖励")
FINAL_AWARD_MAIL_CONTENT = preEnv.XT("恭喜你在门派竞技中获得%s，获得如下奖励！")
HONOR_2_BOX_RATE = 1000
HONOR_BOX_ITEM_ID = 2182
FINAL_AWARD_16TH_FIX = {
  [1] = {
    {szType = "BasicExp", nCount = 150},
    {
      szType = "Item",
      nItemId = {
        [1] = 2424,
        [2] = 2424,
        [3] = 2424,
        [4] = 2424,
        [5] = 2424,
        [6] = 2424,
        [7] = 2424,
        [8] = 2424,
        [9] = 2424,
        [10] = 2424,
        [11] = 2424,
        [12] = 2424,
        [13] = 2424,
        [14] = 2424
      },
      nCount = 20
    }
  },
  [2] = {
    {szType = "BasicExp", nCount = 120},
    {
      szType = "Item",
      nItemId = {
        [1] = 2424,
        [2] = 2424,
        [3] = 2424,
        [4] = 2424,
        [5] = 2424,
        [6] = 2424,
        [7] = 2424,
        [8] = 2424,
        [9] = 2424,
        [10] = 2424,
        [11] = 2424,
        [12] = 2424,
        [13] = 2424,
        [14] = 2424
      },
      nCount = 16
    }
  },
  [4] = {
    {szType = "BasicExp", nCount = 110},
    {
      szType = "Item",
      nItemId = {
        [1] = 2424,
        [2] = 2424,
        [3] = 2424,
        [4] = 2424,
        [5] = 2424,
        [6] = 2424,
        [7] = 2424,
        [8] = 2424,
        [9] = 2424,
        [10] = 2424,
        [11] = 2424,
        [12] = 2424,
        [13] = 2424,
        [14] = 2424
      },
      nCount = 14
    }
  },
  [8] = {
    {szType = "BasicExp", nCount = 100},
    {
      szType = "Item",
      nItemId = {
        [1] = 2424,
        [2] = 2424,
        [3] = 2424,
        [4] = 2424,
        [5] = 2424,
        [6] = 2424,
        [7] = 2424,
        [8] = 2424,
        [9] = 2424,
        [10] = 2424,
        [11] = 2424,
        [12] = 2424,
        [13] = 2424,
        [14] = 2424
      },
      nCount = 12
    }
  },
  [16] = {
    {szType = "BasicExp", nCount = 90},
    {
      szType = "Item",
      nItemId = {
        [1] = 2424,
        [2] = 2424,
        [3] = 2424,
        [4] = 2424,
        [5] = 2424,
        [6] = 2424,
        [7] = 2424,
        [8] = 2424,
        [9] = 2424,
        [10] = 2424,
        [11] = 2424,
        [12] = 2424,
        [13] = 2424,
        [14] = 2424
      },
      nCount = 10
    }
  }
}
FINAL_AWARD_16TH_FIX_HIGH = {
  [1] = {
    {szType = "BasicExp", nCount = 150},
    {
      szType = "Item",
      nItemId = {
        [1] = 2424,
        [2] = 2424,
        [3] = 2424,
        [4] = 2424,
        [5] = 2424,
        [6] = 2424,
        [7] = 2424,
        [8] = 2424,
        [9] = 2424,
        [10] = 2424,
        [11] = 2424,
        [12] = 2424,
        [13] = 2424,
        [14] = 2424
      },
      nCount = 30
    }
  },
  [2] = {
    {szType = "BasicExp", nCount = 120},
    {
      szType = "Item",
      nItemId = {
        [1] = 2424,
        [2] = 2424,
        [3] = 2424,
        [4] = 2424,
        [5] = 2424,
        [6] = 2424,
        [7] = 2424,
        [8] = 2424,
        [9] = 2424,
        [10] = 2424,
        [11] = 2424,
        [12] = 2424,
        [13] = 2424,
        [14] = 2424
      },
      nCount = 24
    }
  },
  [4] = {
    {szType = "BasicExp", nCount = 110},
    {
      szType = "Item",
      nItemId = {
        [1] = 2424,
        [2] = 2424,
        [3] = 2424,
        [4] = 2424,
        [5] = 2424,
        [6] = 2424,
        [7] = 2424,
        [8] = 2424,
        [9] = 2424,
        [10] = 2424,
        [11] = 2424,
        [12] = 2424,
        [13] = 2424,
        [14] = 2424
      },
      nCount = 20
    }
  },
  [8] = {
    {szType = "BasicExp", nCount = 100},
    {
      szType = "Item",
      nItemId = {
        [1] = 2424,
        [2] = 2424,
        [3] = 2424,
        [4] = 2424,
        [5] = 2424,
        [6] = 2424,
        [7] = 2424,
        [8] = 2424,
        [9] = 2424,
        [10] = 2424,
        [11] = 2424,
        [12] = 2424,
        [13] = 2424,
        [14] = 2424
      },
      nCount = 18
    }
  },
  [16] = {
    {szType = "BasicExp", nCount = 90},
    {
      szType = "Item",
      nItemId = {
        [1] = 2424,
        [2] = 2424,
        [3] = 2424,
        [4] = 2424,
        [5] = 2424,
        [6] = 2424,
        [7] = 2424,
        [8] = 2424,
        [9] = 2424,
        [10] = 2424,
        [11] = 2424,
        [12] = 2424,
        [13] = 2424,
        [14] = 2424
      },
      nCount = 16
    }
  }
}
FINAL_AWARD_16TH_RATE_BY_FACTION = {
  [1] = {
    {
      szType = "Item",
      nRate = 0,
      nCount = 1,
      nItemId = {
        [1] = 598,
        [2] = 598,
        [3] = 598,
        [4] = 598,
        [5] = 598,
        [6] = 598,
        [7] = 598,
        [8] = 598,
        [9] = 598,
        [10] = 598,
        [11] = 598,
        [12] = 598,
        [13] = 598,
        [14] = 598
      }
    }
  },
  [2] = {
    {
      szType = "Item",
      nRate = 0,
      nCount = 1,
      nItemId = {
        [1] = 598,
        [2] = 598,
        [3] = 598,
        [4] = 598,
        [5] = 598,
        [6] = 598,
        [7] = 598,
        [8] = 598,
        [9] = 598,
        [10] = 598,
        [11] = 598,
        [12] = 598,
        [13] = 598,
        [14] = 598
      }
    }
  },
  [4] = {
    {
      szType = "Item",
      nRate = 0,
      nCount = 1,
      nItemId = {
        [1] = 598,
        [2] = 598,
        [3] = 598,
        [4] = 598,
        [5] = 598,
        [6] = 598,
        [7] = 598,
        [8] = 598,
        [9] = 598,
        [10] = 598,
        [11] = 598,
        [12] = 598,
        [13] = 598,
        [14] = 598
      }
    }
  },
  [8] = {
    {
      szType = "Item",
      nRate = 0,
      nCount = 1,
      nItemId = {
        [1] = 598,
        [2] = 598,
        [3] = 598,
        [4] = 598,
        [5] = 598,
        [6] = 598,
        [7] = 598,
        [8] = 598,
        [9] = 598,
        [10] = 598,
        [11] = 598,
        [12] = 598,
        [13] = 598,
        [14] = 598
      }
    }
  },
  [16] = {
    {
      szType = "Item",
      nRate = 0,
      nCount = 1,
      nItemId = {
        [1] = 598,
        [2] = 598,
        [3] = 598,
        [4] = 598,
        [5] = 598,
        [6] = 598,
        [7] = 598,
        [8] = 598,
        [9] = 598,
        [10] = 598,
        [11] = 598,
        [12] = 598,
        [13] = 598,
        [14] = 598
      }
    }
  }
}
FINAL_AWARD_ALL_FIX = {
  [20] = {
    {szType = "BasicExp", nCount = 85},
    {
      szType = "Item",
      nItemId = {
        [1] = 2424,
        [2] = 2424,
        [3] = 2424,
        [4] = 2424,
        [5] = 2424,
        [6] = 2424,
        [7] = 2424,
        [8] = 2424,
        [9] = 2424,
        [10] = 2424,
        [11] = 2424,
        [12] = 2424,
        [13] = 2424,
        [14] = 2424
      },
      nCount = 9
    }
  },
  [40] = {
    {szType = "BasicExp", nCount = 80},
    {
      szType = "Item",
      nItemId = {
        [1] = 2424,
        [2] = 2424,
        [3] = 2424,
        [4] = 2424,
        [5] = 2424,
        [6] = 2424,
        [7] = 2424,
        [8] = 2424,
        [9] = 2424,
        [10] = 2424,
        [11] = 2424,
        [12] = 2424,
        [13] = 2424,
        [14] = 2424
      },
      nCount = 8
    }
  },
  [60] = {
    {szType = "BasicExp", nCount = 75},
    {
      szType = "Item",
      nItemId = {
        [1] = 2424,
        [2] = 2424,
        [3] = 2424,
        [4] = 2424,
        [5] = 2424,
        [6] = 2424,
        [7] = 2424,
        [8] = 2424,
        [9] = 2424,
        [10] = 2424,
        [11] = 2424,
        [12] = 2424,
        [13] = 2424,
        [14] = 2424
      },
      nCount = 7
    }
  },
  [80] = {
    {szType = "BasicExp", nCount = 70},
    {
      szType = "Item",
      nItemId = {
        [1] = 2424,
        [2] = 2424,
        [3] = 2424,
        [4] = 2424,
        [5] = 2424,
        [6] = 2424,
        [7] = 2424,
        [8] = 2424,
        [9] = 2424,
        [10] = 2424,
        [11] = 2424,
        [12] = 2424,
        [13] = 2424,
        [14] = 2424
      },
      nCount = 6
    }
  },
  [100] = {
    {szType = "BasicExp", nCount = 60},
    {
      szType = "Item",
      nItemId = {
        [1] = 2424,
        [2] = 2424,
        [3] = 2424,
        [4] = 2424,
        [5] = 2424,
        [6] = 2424,
        [7] = 2424,
        [8] = 2424,
        [9] = 2424,
        [10] = 2424,
        [11] = 2424,
        [12] = 2424,
        [13] = 2424,
        [14] = 2424
      },
      nCount = 5
    }
  }
}
FINAL_AWARD_ALL_FIX_HIGH = {
  [20] = {
    {szType = "BasicExp", nCount = 85},
    {
      szType = "Item",
      nItemId = {
        [1] = 2424,
        [2] = 2424,
        [3] = 2424,
        [4] = 2424,
        [5] = 2424,
        [6] = 2424,
        [7] = 2424,
        [8] = 2424,
        [9] = 2424,
        [10] = 2424,
        [11] = 2424,
        [12] = 2424,
        [13] = 2424,
        [14] = 2424
      },
      nCount = 14
    }
  },
  [40] = {
    {szType = "BasicExp", nCount = 80},
    {
      szType = "Item",
      nItemId = {
        [1] = 2424,
        [2] = 2424,
        [3] = 2424,
        [4] = 2424,
        [5] = 2424,
        [6] = 2424,
        [7] = 2424,
        [8] = 2424,
        [9] = 2424,
        [10] = 2424,
        [11] = 2424,
        [12] = 2424,
        [13] = 2424,
        [14] = 2424
      },
      nCount = 12
    }
  },
  [60] = {
    {szType = "BasicExp", nCount = 75},
    {
      szType = "Item",
      nItemId = {
        [1] = 2424,
        [2] = 2424,
        [3] = 2424,
        [4] = 2424,
        [5] = 2424,
        [6] = 2424,
        [7] = 2424,
        [8] = 2424,
        [9] = 2424,
        [10] = 2424,
        [11] = 2424,
        [12] = 2424,
        [13] = 2424,
        [14] = 2424
      },
      nCount = 10
    }
  },
  [80] = {
    {szType = "BasicExp", nCount = 70},
    {
      szType = "Item",
      nItemId = {
        [1] = 2424,
        [2] = 2424,
        [3] = 2424,
        [4] = 2424,
        [5] = 2424,
        [6] = 2424,
        [7] = 2424,
        [8] = 2424,
        [9] = 2424,
        [10] = 2424,
        [11] = 2424,
        [12] = 2424,
        [13] = 2424,
        [14] = 2424
      },
      nCount = 9
    }
  },
  [100] = {
    {szType = "BasicExp", nCount = 60},
    {
      szType = "Item",
      nItemId = {
        [1] = 2424,
        [2] = 2424,
        [3] = 2424,
        [4] = 2424,
        [5] = 2424,
        [6] = 2424,
        [7] = 2424,
        [8] = 2424,
        [9] = 2424,
        [10] = 2424,
        [11] = 2424,
        [12] = 2424,
        [13] = 2424,
        [14] = 2424
      },
      nCount = 8
    }
  }
}
FINAL_AWARD_ALL_RATE_BY_FACTION = {
  [20] = {
    {
      szType = "Item",
      nRate = 0,
      nCount = 1,
      nItemId = {
        [1] = 598,
        [2] = 598,
        [3] = 598,
        [4] = 598,
        [5] = 598,
        [6] = 598,
        [7] = 598,
        [8] = 598,
        [9] = 598,
        [10] = 598,
        [11] = 598,
        [12] = 598,
        [13] = 598,
        [14] = 598
      }
    }
  },
  [40] = {
    {
      szType = "Item",
      nRate = 0,
      nCount = 1,
      nItemId = {
        [1] = 598,
        [2] = 598,
        [3] = 598,
        [4] = 598,
        [5] = 598,
        [6] = 598,
        [7] = 598,
        [8] = 598,
        [9] = 598,
        [10] = 598,
        [11] = 598,
        [12] = 598,
        [13] = 598,
        [14] = 598
      }
    }
  },
  [60] = {
    {
      szType = "Item",
      nRate = 0,
      nCount = 1,
      nItemId = {
        [1] = 598,
        [2] = 598,
        [3] = 598,
        [4] = 598,
        [5] = 598,
        [6] = 598,
        [7] = 598,
        [8] = 598,
        [9] = 598,
        [10] = 598,
        [11] = 598,
        [12] = 598,
        [13] = 598,
        [14] = 598
      }
    }
  },
  [80] = {
    {
      szType = "Item",
      nRate = 0,
      nCount = 1,
      nItemId = {
        [1] = 598,
        [2] = 598,
        [3] = 598,
        [4] = 598,
        [5] = 598,
        [6] = 598,
        [7] = 598,
        [8] = 598,
        [9] = 598,
        [10] = 598,
        [11] = 598,
        [12] = 598,
        [13] = 598,
        [14] = 598
      }
    }
  },
  [100] = {
    {
      szType = "Item",
      nRate = 0,
      nCount = 1,
      nItemId = {
        [1] = 598,
        [2] = 598,
        [3] = 598,
        [4] = 598,
        [5] = 598,
        [6] = 598,
        [7] = 598,
        [8] = 598,
        [9] = 598,
        [10] = 598,
        [11] = 598,
        [12] = 598,
        [13] = 598,
        [14] = 598
      }
    }
  }
}
ELIMINATION_AWARD = {
  [0] = 0.6,
  [1] = 0.2,
  [2] = 0.3,
  [3] = 0.4,
  [4] = 0.5
}
BOX_AWARD_RANDOM_ID = {
  [1] = {nLevelLimit = 1, nAwardId = 1448},
  [2] = {nLevelLimit = 60, nAwardId = 1449},
  [3] = {nLevelLimit = 70, nAwardId = 1450},
  [4] = {nLevelLimit = 80, nAwardId = 1451},
  [5] = {nLevelLimit = 90, nAwardId = 1452},
  [6] = {nLevelLimit = 100, nAwardId = 4430},
  [7] = {nLevelLimit = 110, nAwardId = 4431}
}
CHAMPION_TITLE = {
  [1] = 301,
  [2] = 304,
  [3] = 303,
  [4] = 302,
  [5] = 305,
  [6] = 306,
  [7] = 307,
  [8] = 308,
  [9] = 309,
  [10] = 310,
  [11] = 321,
  [12] = 323,
  [13] = 325,
  [14] = 327
}
CHAMPION_TITLE_TIMEOUT = 2592000
ELIMI_VS_TABLE = {
  {1, 16},
  {8, 9},
  {4, 13},
  {5, 12},
  {2, 15},
  {7, 10},
  {3, 14},
  {6, 11}
}
RETURN_TO_PK_TIME = 30
OPEN_AREA = {
  30,
  60,
  90,
  120
}
FREE_PK_SCORE = {
  {
    60,
    100,
    80,
    80
  },
  {
    60,
    70,
    64,
    80
  },
  {
    60,
    50,
    50,
    80
  },
  {
    60,
    35,
    40,
    80
  }
}
STATE_TRANS = {
  {
    SIGN_UP,
    preEnv.XT("报名"),
    300,
    "StartFreedomPK"
  },
  {
    FREE_PK,
    preEnv.XT("第1轮晋级赛"),
    240,
    "CloseFreedomPK"
  },
  {
    FREE_PK_REST,
    preEnv.XT("第2轮晋级赛"),
    15,
    "StartFreedomPK"
  },
  {
    FREE_PK,
    preEnv.XT("第2轮晋级赛"),
    240,
    "CloseFreedomPK"
  },
  {
    FREE_PK_REST,
    preEnv.XT("第3轮晋级赛"),
    15,
    "StartFreedomPK"
  },
  {
    FREE_PK,
    preEnv.XT("第3轮晋级赛"),
    240,
    "EndFreedomPK"
  },
  {
    READY_ELIMINATION,
    preEnv.XT("16强赛"),
    60,
    "StartElimination"
  },
  {
    ELIMINATION,
    preEnv.XT("16强赛"),
    120,
    "CloseElimination"
  },
  {
    ELIMINATION_REST,
    preEnv.XT("8强赛"),
    60,
    "StartElimination"
  },
  {
    ELIMINATION,
    preEnv.XT("8强赛"),
    120,
    "CloseElimination"
  },
  {
    ELIMINATION_REST,
    preEnv.XT("半决赛"),
    60,
    "StartElimination"
  },
  {
    ELIMINATION,
    preEnv.XT("半决赛"),
    120,
    "CloseElimination"
  },
  {
    ELIMINATION_REST,
    preEnv.XT("决赛"),
    60,
    "StartElimination"
  },
  {
    ELIMINATION,
    preEnv.XT("决赛"),
    120,
    "EndElimination"
  },
  {
    CHAMPION_AWARD,
    preEnv.XT("颁奖"),
    180,
    "EndChampionAward"
  },
  {
    END_AWARD,
    preEnv.XT("颁奖结束"),
    120,
    "EndBattle"
  },
  {END}
}
WATCH_TRAP = {
  trap_watch_in_1 = 1,
  trap_watch_in_2 = 2,
  trap_watch_in_3 = 3,
  trap_watch_in_4 = 4,
  trap_watch_in_5 = 5,
  trap_watch_in_6 = 7,
  trap_watch_in_7 = 6,
  trap_watch_in_8 = 8
}
STATE_ACHIEVEMENT = {
  [preEnv.XT("16强赛")] = "FactionBattle_2",
  [preEnv.XT("8强赛")] = "FactionBattle_3",
  [preEnv.XT("半决赛")] = "FactionBattle_4",
  [preEnv.XT("决赛")] = "FactionBattle_5"
}
if preEnv then
  preEnv.setfenv(1, preEnv)
end
