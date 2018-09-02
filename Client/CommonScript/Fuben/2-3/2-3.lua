local tbFubenSetting = {}
Fuben:SetFubenSetting(26, tbFubenSetting)
tbFubenSetting.szFubenClass = "PersonalFubenBase"
tbFubenSetting.szName = "测试副本"
tbFubenSetting.szNpcPointFile = "Setting/Fuben/PersonalFuben/2_3/NpcPos.tab"
tbFubenSetting.szPathFile = "Setting/Fuben/PersonalFuben/2_3/NpcPath.tab"
tbFubenSetting.tbBeginPoint = {416, 2678}
tbFubenSetting.nStartDir = 26
tbFubenSetting.ANIMATION = {
  [1] = "Scenes/camera/boss110_canghai.controller"
}
tbFubenSetting.NPC = {
  [1] = {
    nTemplate = 1114,
    nLevel = -1,
    nSeries = -1
  },
  [2] = {
    nTemplate = 826,
    nLevel = -1,
    nSeries = -1
  },
  [3] = {
    nTemplate = 29,
    nLevel = -1,
    nSeries = -1
  },
  [4] = {
    nTemplate = 824,
    nLevel = -1,
    nSeries = -1
  },
  [5] = {
    nTemplate = 782,
    nLevel = -1,
    nSeries = -1
  },
  [6] = {
    nTemplate = 684,
    nLevel = -1,
    nSeries = 0
  },
  [7] = {
    nTemplate = 1287,
    nLevel = -1,
    nSeries = 0
  },
  [8] = {
    nTemplate = 74,
    nLevel = -1,
    nSeries = 0
  },
  [9] = {
    nTemplate = 104,
    nLevel = -1,
    nSeries = 0
  }
}
tbFubenSetting.LOCK = {
  [1] = {
    nTime = 0,
    nNum = 1,
    tbPrelock = {},
    tbStartEvent = {
      {
        "RaiseEvent",
        "ShowTaskDialog",
        1,
        1018,
        false
      },
      {
        "AddNpc",
        6,
        1,
        0,
        "Start_Npc1",
        "Start_Npc1",
        1,
        25,
        0,
        0,
        0
      },
      {
        "SetNpcBloodVisable",
        "Start_Npc1",
        false,
        0
      }
    },
    tbUnLockEvent = {
      {
        "SetShowTime",
        18
      },
      {
        "NpcBubbleTalk",
        "Start_Npc1",
        "紫轩...........",
        4,
        0,
        1
      },
      {
        "SetNpcProtected",
        "Start_Npc1",
        1
      },
      {
        "SetAiActive",
        "Start_Npc1",
        0
      }
    }
  },
  [2] = {
    nTime = 0,
    nNum = 1,
    tbPrelock = {1},
    tbStartEvent = {
      {
        "ChangeFightState",
        1
      },
      {
        "TrapUnlock",
        "TrapLock1",
        2
      },
      {
        "SetTargetPos",
        679,
        1467
      },
      {
        "TrapCastSkill",
        "BuffPoint",
        1507,
        1,
        -1,
        -1,
        1,
        203,
        2875,
        5692
      },
      {
        "AddNpc",
        9,
        1,
        2,
        "wall",
        "wall_1_1",
        false,
        32
      }
    },
    tbUnLockEvent = {
      {
        "ClearTargetPos"
      }
    }
  },
  [3] = {
    nTime = 0,
    nNum = 8,
    tbPrelock = {2},
    tbStartEvent = {
      {
        "AddNpc",
        1,
        2,
        3,
        "guaiwu",
        "Stage_1_1",
        1,
        -1,
        0,
        9008,
        0.5
      },
      {
        "AddNpc",
        1,
        2,
        3,
        "guaiwu",
        "Stage_1_2",
        1,
        -1,
        0,
        9008,
        0.5
      },
      {
        "AddNpc",
        3,
        2,
        3,
        "guaiwu",
        "Stage_1_3",
        1,
        -1,
        1.5,
        0,
        0
      },
      {
        "AddNpc",
        3,
        2,
        3,
        "guaiwu",
        "Stage_1_4",
        1,
        -1,
        1.5,
        0,
        0
      }
    },
    tbUnLockEvent = {
      {
        "RaiseEvent",
        "Log",
        "unlock lock 2"
      },
      {
        "SetTargetPos",
        3050,
        1340
      },
      {
        "OpenDynamicObstacle",
        "ops1"
      },
      {"DoDeath", "wall"},
      {
        "AddNpc",
        9,
        1,
        0,
        "wall",
        "wall_1_2",
        false,
        32
      }
    }
  },
  [4] = {
    nTime = 0,
    nNum = 1,
    tbPrelock = {3},
    tbStartEvent = {
      {
        "TrapUnlock",
        "TrapLock2",
        4
      }
    },
    tbUnLockEvent = {
      {
        "RaiseEvent",
        "Log",
        "unlock lock 3"
      },
      {
        "ClearTargetPos"
      }
    }
  },
  [5] = {
    nTime = 0,
    nNum = 8,
    tbPrelock = {4},
    tbStartEvent = {
      {
        "AddNpc",
        1,
        2,
        5,
        "guaiwu",
        "Stage_2_1",
        1,
        -1,
        0,
        9008,
        0.5
      },
      {
        "AddNpc",
        1,
        2,
        5,
        "guaiwu",
        "Stage_2_2",
        1,
        -1,
        0,
        9008,
        0.5
      },
      {
        "AddNpc",
        3,
        2,
        5,
        "guaiwu",
        "Stage_2_3",
        1,
        -1,
        1,
        0,
        0
      },
      {
        "AddNpc",
        4,
        2,
        5,
        "guaiwu",
        "Stage_2_4",
        1,
        -1,
        2,
        9008,
        0.5
      }
    },
    tbUnLockEvent = {
      {
        "SetTargetPos",
        2979,
        2228
      }
    }
  },
  [6] = {
    nTime = 0,
    nNum = 1,
    tbPrelock = {5},
    tbStartEvent = {
      {
        "TrapUnlock",
        "TrapLock3",
        6
      }
    },
    tbUnLockEvent = {
      {
        "RaiseEvent",
        "Log",
        "unlock lock 3"
      },
      {
        "ClearTargetPos"
      }
    }
  },
  [7] = {
    nTime = 0,
    nNum = 4,
    tbPrelock = {6},
    tbStartEvent = {
      {
        "AddNpc",
        1,
        4,
        7,
        "guaiwu",
        "Stage_3_1",
        1,
        -1,
        0,
        9008,
        0.5
      }
    },
    tbUnLockEvent = {
      {
        "BlackMsg",
        "前方居然是断崖？嘿嘿，这可难不倒我！"
      },
      {
        "OpenDynamicObstacle",
        "ops2"
      },
      {
        "SetTargetPos",
        3397,
        2885
      },
      {
        "AddNpc",
        8,
        1,
        7,
        "Stage_3_qinggong",
        "Stage_3_qinggong",
        1
      },
      {
        "TrapUnlock",
        "Jump1",
        20
      },
      {
        "ChangeTrap",
        "Jump1",
        nil,
        {3897, 2996}
      },
      {
        "ChangeTrap",
        "Jump2",
        nil,
        {4483, 3578}
      },
      {
        "ChangeTrap",
        "Jump3",
        nil,
        {3814, 4141}
      },
      {
        "ChangeTrap",
        "Jump4",
        nil,
        {3507, 4994}
      },
      {
        "TrapUnlock",
        "Jump4",
        21
      }
    }
  },
  [8] = {
    nTime = 0,
    nNum = 1,
    tbPrelock = {7},
    tbStartEvent = {
      {
        "ChangeTrap",
        "TrapLock4",
        nil,
        nil,
        nil,
        nil,
        nil,
        true
      },
      {
        "TrapUnlock",
        "TrapLock5",
        8
      }
    },
    tbUnLockEvent = {
      {
        "ClearTargetPos"
      },
      {"DelNpc", "Start_Npc1"},
      {"CloseLock", 30}
    }
  },
  [9] = {
    nTime = 0,
    nNum = 11,
    tbPrelock = {8},
    tbStartEvent = {
      {
        "AddNpc",
        1,
        3,
        9,
        "guaiwu",
        "Stage_4_1",
        1,
        -1,
        0,
        9008,
        0.5
      },
      {
        "AddNpc",
        1,
        3,
        9,
        "guaiwu",
        "Stage_4_2",
        1,
        -1,
        0,
        9008,
        0.5
      },
      {
        "AddNpc",
        2,
        1,
        9,
        "Leader",
        "Stage_4",
        1,
        -1,
        2,
        9011,
        1
      },
      {
        "AddNpc",
        3,
        1,
        9,
        "guaiwu",
        "Stage_4_3_1",
        1,
        -1,
        3.5,
        0,
        0
      },
      {
        "AddNpc",
        3,
        1,
        9,
        "guaiwu",
        "Stage_4_3_2",
        1,
        -1,
        3.5,
        0,
        0
      },
      {
        "AddNpc",
        4,
        1,
        9,
        "guaiwu",
        "Stage_4_3_3",
        1,
        -1,
        3,
        9008,
        0.5
      },
      {
        "AddNpc",
        4,
        1,
        9,
        "guaiwu",
        "Stage_4_3_4",
        1,
        -1,
        3,
        9008,
        0.5
      }
    },
    tbUnLockEvent = {
      {
        "OpenDynamicObstacle",
        "ops3"
      },
      {
        "SetTargetPos",
        5359,
        5693
      },
      {"DoDeath", "wall"}
    }
  },
  [10] = {
    nTime = 0,
    nNum = 1,
    tbPrelock = {9},
    tbStartEvent = {
      {
        "TrapUnlock",
        "TrapLock6",
        10
      },
      {
        "AddNpc",
        7,
        1,
        0,
        "Npc",
        "Stage_5_2",
        1,
        0,
        0,
        0,
        0
      },
      {
        "AddNpc",
        1,
        3,
        0,
        "guaiwu",
        "Stage_5_3",
        1,
        32,
        0,
        0,
        0
      },
      {
        "AddNpc",
        4,
        3,
        0,
        "guaiwu",
        "Stage_5_4",
        1,
        1,
        0,
        0,
        0
      },
      {
        "SetNpcProtected",
        "Npc",
        1
      },
      {
        "SetNpcBloodVisable",
        "Npc",
        false,
        0
      },
      {
        "SetAiActive",
        "Npc",
        0
      },
      {
        "SetNpcProtected",
        "guaiwu",
        1
      },
      {
        "SetNpcBloodVisable",
        "guaiwu",
        false,
        0
      },
      {
        "SetAiActive",
        "guaiwu",
        0
      }
    },
    tbUnLockEvent = {
      {"PauseLock", 18}
    }
  },
  [11] = {
    nTime = 0,
    nNum = 1,
    tbPrelock = {10},
    tbStartEvent = {
      {
        "ClearTargetPos"
      },
      {
        "ChangeCameraSetting",
        35,
        35,
        20
      },
      {
        "MoveCameraByTarget",
        11,
        2,
        450
      },
      {
        "SetForbiddenOperation",
        true
      },
      {
        "SetAllUiVisiable",
        false
      },
      {
        "RaiseEvent",
        "PlayerRunTo",
        5359,
        5693
      }
    },
    tbUnLockEvent = {}
  },
  [12] = {
    nTime = 1.2,
    nNum = 0,
    tbPrelock = {11},
    tbStartEvent = {
      {
        "PlayCameraAnimation",
        1,
        13
      }
    },
    tbUnLockEvent = {}
  },
  [13] = {
    nTime = 0,
    nNum = 1,
    tbPrelock = {12},
    tbStartEvent = {
      {
        "AddNpc",
        5,
        1,
        15,
        "BOSS",
        "Stage_5_BOSS",
        1,
        48
      },
      {
        "SetHeadVisiable",
        "BOSS",
        false,
        0
      },
      {
        "ChangeNpcCamp",
        "BOSS",
        0
      },
      {
        "SetAiActive",
        "BOSS",
        0
      },
      {
        "DoCommonAct",
        "BOSS",
        21,
        2001
      }
    },
    tbUnLockEvent = {}
  },
  [100] = {
    nTime = 0,
    nNum = 1,
    tbPrelock = {13},
    tbStartEvent = {
      {
        "MoveCamera",
        100,
        1,
        204,
        57,
        148,
        14,
        90,
        0
      }
    },
    tbUnLockEvent = {}
  },
  [101] = {
    nTime = 4,
    nNum = 0,
    tbPrelock = {100},
    tbStartEvent = {
      {
        "OpenWindowAutoClose",
        "BossReferral",
        "秦",
        "沐白",
        "飞龙堡叛变护法"
      },
      {
        "DoCommonAct",
        "BOSS",
        17,
        0,
        0,
        0
      }
    },
    tbUnLockEvent = {
      {
        "CloseWindow",
        "BossReferral"
      }
    }
  },
  [14] = {
    nTime = 0,
    nNum = 1,
    tbPrelock = {101},
    tbStartEvent = {
      {
        "LeaveAnimationState",
        false
      },
      {
        "RaiseEvent",
        "ShowTaskDialog",
        14,
        1019,
        false
      }
    },
    tbUnLockEvent = {
      {"ResumeLock", 18},
      {
        "SetShowTime",
        18
      },
      {
        "SetNpcPos",
        "BOSS",
        5965,
        5685
      },
      {
        "BlackMsg",
        "乳臭未干的小家伙，受死吧！"
      },
      {
        "SetAllUiVisiable",
        true
      },
      {
        "SetForbiddenOperation",
        false
      },
      {
        "ChangeNpcCamp",
        "BOSS",
        1
      },
      {
        "SetAiActive",
        "BOSS",
        1
      },
      {
        "SetHeadVisiable",
        "BOSS",
        true,
        0
      },
      {
        "SetNpcProtected",
        "Start_Npc1",
        0
      },
      {
        "SetNpcBloodVisable",
        "Start_Npc1",
        true,
        0
      },
      {
        "SetAiActive",
        "Start_Npc1",
        1
      },
      {
        "SetNpcProtected",
        "Npc",
        0
      },
      {
        "SetNpcBloodVisable",
        "Npc",
        true,
        0
      },
      {
        "SetAiActive",
        "Npc",
        1
      },
      {
        "SetNpcProtected",
        "guaiwu",
        0
      },
      {
        "SetNpcBloodVisable",
        "guaiwu",
        true,
        0
      },
      {
        "SetAiActive",
        "guaiwu",
        1
      }
    }
  },
  [15] = {
    nTime = 0,
    nNum = 1,
    tbPrelock = {14},
    tbStartEvent = {},
    tbUnLockEvent = {
      {"PauseLock", 18},
      {
        "StopEndTime"
      },
      {
        "SetGameWorldScale",
        0.1
      },
      {
        "CastSkill",
        "guaiwu",
        3,
        1,
        -1,
        -1
      }
    }
  },
  [16] = {
    nTime = 2.1,
    nNum = 0,
    tbPrelock = {15},
    tbStartEvent = {},
    tbUnLockEvent = {
      {
        "SetGameWorldScale",
        1
      }
    }
  },
  [17] = {
    nTime = 2,
    nNum = 0,
    tbPrelock = {16},
    tbStartEvent = {},
    tbUnLockEvent = {
      {"ResumeLock", 18},
      {
        "SetShowTime",
        18
      },
      {"GameWin"}
    }
  },
  [18] = {
    nTime = 330,
    nNum = 0,
    tbPrelock = {1},
    tbStartEvent = {
      {
        "RaiseEvent",
        "RegisterTimeoutLock"
      }
    },
    tbUnLockEvent = {
      {"GameLost"}
    }
  },
  [20] = {
    nTime = 0,
    nNum = 1,
    tbPrelock = {5},
    tbStartEvent = {},
    tbUnLockEvent = {
      {
        "ClearTargetPos"
      }
    }
  },
  [21] = {
    nTime = 0,
    nNum = 1,
    tbPrelock = {5},
    tbStartEvent = {},
    tbUnLockEvent = {
      {
        "SetTargetPos",
        3527,
        5493
      }
    }
  },
  [30] = {
    nTime = 5,
    nNum = 0,
    tbPrelock = {20},
    tbStartEvent = {},
    tbUnLockEvent = {
      {
        "SetPos",
        3507,
        4994
      }
    }
  },
  [31] = {
    nTime = 0,
    nNum = 1,
    tbPrelock = {10},
    tbStartEvent = {
      {
        "AddNpc",
        6,
        1,
        0,
        "Start_Npc1",
        "Stage_5_1",
        1,
        16,
        0,
        0,
        0
      },
      {
        "ChangeNpcAi",
        "Start_Npc1",
        "Move",
        "Path1",
        31,
        1,
        1,
        0,
        0
      }
    },
    tbUnLockEvent = {
      {
        "SetNpcProtected",
        "Start_Npc1",
        1
      },
      {
        "SetNpcBloodVisable",
        "Start_Npc1",
        false,
        0
      },
      {
        "SetAiActive",
        "Start_Npc1",
        0
      }
    }
  }
}
