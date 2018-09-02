local tbFubenSetting = {}
Fuben:SetFubenSetting(56, tbFubenSetting)
tbFubenSetting.szFubenClass = "PersonalFubenBase"
tbFubenSetting.szName = "测试副本"
tbFubenSetting.szNpcPointFile = "Setting/Fuben/PersonalFuben/7_4/NpcPos.tab"
tbFubenSetting.szPathFile = "Setting/Fuben/PersonalFuben/7_4/NpcPath.tab"
tbFubenSetting.tbBeginPoint = {2661, 1206}
tbFubenSetting.nStartDir = 0
tbFubenSetting.ANIMATION = {
  [1] = "Scenes/camera/Camera_chusheng.controller"
}
tbFubenSetting.NPC = {
  [1] = {
    nTemplate = 1691,
    nLevel = -1,
    nSeries = -1
  },
  [2] = {
    nTemplate = 1692,
    nLevel = -1,
    nSeries = -1
  },
  [3] = {
    nTemplate = 1693,
    nLevel = -1,
    nSeries = -1
  },
  [4] = {
    nTemplate = 1694,
    nLevel = -1,
    nSeries = -1
  },
  [5] = {
    nTemplate = 1695,
    nLevel = -1,
    nSeries = -1
  },
  [6] = {
    nTemplate = 747,
    nLevel = -1,
    nSeries = 0
  },
  [7] = {
    nTemplate = 1690,
    nLevel = -1,
    nSeries = 0
  },
  [8] = {
    nTemplate = 104,
    nLevel = -1,
    nSeries = 0
  },
  [16] = {
    nTemplate = 1696,
    nLevel = -1,
    nSeries = -1
  }
}
tbFubenSetting.bForbidPartner = true
tbFubenSetting.LOCK = {
  [1] = {
    nTime = 0,
    nNum = 1,
    tbPrelock = {},
    tbStartEvent = {
      {
        "RaiseEvent",
        "ChangeAutoFight",
        false
      },
      {
        "PlayCameraEffect",
        9119
      },
      {
        "MoveCamera",
        1,
        4,
        26.4,
        28.37,
        34.7,
        35,
        45,
        0
      },
      {
        "SetAllUiVisiable",
        false
      },
      {
        "SetForbiddenOperation",
        true
      },
      {
        "AddNpc",
        1,
        1,
        34,
        "Patrol_1",
        "Stage_1_1",
        1,
        0,
        0,
        0,
        0
      },
      {
        "AddNpc",
        1,
        1,
        34,
        "Patrol_2",
        "Stage_1_2",
        1,
        0,
        0,
        0,
        0
      },
      {
        "AddNpc",
        1,
        1,
        34,
        "Patrol_3",
        "Stage_1_3",
        1,
        0,
        0,
        0,
        0
      },
      {
        "AddNpc",
        1,
        1,
        34,
        "Patrol_4",
        "Stage_1_4",
        1,
        0,
        0,
        0,
        0
      },
      {
        "ChangeNpcAi",
        "Patrol_1",
        "Move",
        "Path1",
        0,
        1,
        1,
        0,
        1
      },
      {
        "ChangeNpcAi",
        "Patrol_2",
        "Move",
        "Path2",
        0,
        1,
        1,
        0,
        1
      },
      {
        "ChangeNpcAi",
        "Patrol_3",
        "Move",
        "Path3",
        0,
        1,
        1,
        0,
        1
      },
      {
        "ChangeNpcAi",
        "Patrol_4",
        "Move",
        "Path4",
        0,
        1,
        1,
        0,
        1
      },
      {
        "NpcFindEnemyUnlock",
        "Patrol_1",
        30,
        0
      },
      {
        "NpcFindEnemyUnlock",
        "Patrol_2",
        31,
        0
      },
      {
        "NpcFindEnemyUnlock",
        "Patrol_3",
        32,
        0
      },
      {
        "NpcFindEnemyUnlock",
        "Patrol_4",
        33,
        0
      },
      {
        "NpcAddBuff",
        "Patrol_1",
        2402,
        1,
        300
      },
      {
        "NpcAddBuff",
        "Patrol_2",
        2402,
        1,
        300
      },
      {
        "NpcAddBuff",
        "Patrol_3",
        2402,
        1,
        300
      },
      {
        "NpcAddBuff",
        "Patrol_4",
        2402,
        1,
        300
      }
    },
    tbUnLockEvent = {
      {
        "PlayCameraEffect",
        9119
      },
      {
        "SetForbiddenOperation",
        false
      },
      {
        "LeaveAnimationState",
        false
      }
    }
  },
  [2] = {
    nTime = 0,
    nNum = 1,
    tbPrelock = {1},
    tbStartEvent = {
      {
        "RaiseEvent",
        "ShowTaskDialog",
        2,
        1109,
        false
      }
    },
    tbUnLockEvent = {
      {
        "SetShowTime",
        13
      },
      {
        "SetAllUiVisiable",
        true
      },
      {
        "BlackMsg",
        "前方有庄丁巡逻，注意别被发现！"
      },
      {
        "OpenDynamicObstacle",
        "ops1"
      },
      {
        "AddNpc",
        8,
        1,
        0,
        "wall2",
        "wall_1_2",
        false,
        32
      }
    }
  },
  [3] = {
    nTime = 0,
    nNum = 1,
    tbPrelock = {2},
    tbStartEvent = {
      {
        "ChangeFightState",
        1
      },
      {
        "SetTargetPos",
        3035,
        6144
      },
      {
        "TrapUnlock",
        "TrapLock1",
        3
      },
      {
        "AddNpc",
        2,
        3,
        4,
        "guaiwu",
        "Stage_2_1",
        1,
        0,
        0,
        0,
        0
      },
      {
        "AddNpc",
        2,
        2,
        4,
        "guaiwu",
        "Stage_2_2",
        1,
        0,
        0,
        0,
        0
      },
      {
        "SetNpcProtected",
        "guaiwu",
        1
      }
    },
    tbUnLockEvent = {
      {
        "SetNpcProtected",
        "guaiwu",
        0
      },
      {
        "ClearTargetPos"
      },
      {
        "AddNpc",
        3,
        3,
        4,
        "guaiwu",
        "Stage_2_3",
        1,
        0,
        2,
        0,
        0
      },
      {
        "AddNpc",
        2,
        4,
        4,
        "guaiwu",
        "Stage_2_4",
        1,
        0,
        4,
        9008,
        0.5
      },
      {
        "SetNpcRange",
        "guaiwu",
        3000,
        3000,
        5
      }
    }
  },
  [4] = {
    nTime = 0,
    nNum = 12,
    tbPrelock = {2},
    tbStartEvent = {},
    tbUnLockEvent = {
      {
        "OpenDynamicObstacle",
        "ops2"
      },
      {"DelNpc", "Patrol_1"},
      {"DelNpc", "Patrol_2"},
      {"DelNpc", "Patrol_3"},
      {"DelNpc", "Patrol_4"},
      {"DoDeath", "wall2"},
      {
        "AddNpc",
        8,
        1,
        0,
        "wall3",
        "wall_1_3",
        false,
        16
      },
      {
        "SetTargetPos",
        5570,
        7220
      }
    }
  },
  [5] = {
    nTime = 0,
    nNum = 1,
    tbPrelock = {4},
    tbStartEvent = {
      {
        "TrapUnlock",
        "TrapLock2",
        5
      },
      {
        "AddNpc",
        2,
        2,
        6,
        "guaiwu",
        "Stage_3_1",
        1,
        0,
        0,
        0,
        0
      },
      {
        "AddNpc",
        2,
        2,
        6,
        "guaiwu",
        "Stage_3_2",
        1,
        0,
        0,
        0,
        0
      },
      {
        "AddNpc",
        4,
        1,
        6,
        "guaiwu",
        "Stage_3_2",
        1,
        0,
        0,
        0,
        0
      },
      {
        "AddNpc",
        4,
        1,
        6,
        "guaiwu",
        "Stage_3_3",
        1,
        0,
        0,
        0,
        0
      },
      {
        "SetNpcProtected",
        "guaiwu",
        1
      }
    },
    tbUnLockEvent = {
      {
        "ClearTargetPos"
      }
    }
  },
  [6] = {
    nTime = 0,
    nNum = 15,
    tbPrelock = {5},
    tbStartEvent = {
      {
        "SetNpcProtected",
        "guaiwu",
        0
      },
      {
        "AddNpc",
        3,
        3,
        6,
        "guaiwu",
        "Stage_3_4",
        1,
        0,
        4,
        0,
        0
      },
      {
        "AddNpc",
        2,
        6,
        6,
        "guaiwu",
        "Stage_3_5",
        1,
        0,
        7,
        9008,
        0.5
      },
      {
        "SetNpcRange",
        "guaiwu",
        3000,
        3000,
        8
      }
    },
    tbUnLockEvent = {
      {"DoDeath", "wall3"},
      {
        "OpenDynamicObstacle",
        "ops3"
      }
    }
  },
  [7] = {
    nTime = 0,
    nNum = 1,
    tbPrelock = {6},
    tbStartEvent = {
      {
        "TrapUnlock",
        "TrapLock3",
        7
      },
      {
        "SetTargetPos",
        6956,
        4176
      }
    },
    tbUnLockEvent = {
      {
        "ClearTargetPos"
      }
    }
  },
  [8] = {
    nTime = 0,
    nNum = 1,
    tbPrelock = {6},
    tbStartEvent = {
      {
        "AddNpc",
        5,
        1,
        8,
        "sl",
        "shouling",
        false,
        16,
        0,
        0,
        0
      },
      {
        "SetNpcProtected",
        "sl",
        1
      },
      {
        "SetNpcBloodVisable",
        "sl",
        false,
        0
      },
      {
        "SetAiActive",
        "sl",
        0
      }
    },
    tbUnLockEvent = {}
  },
  [9] = {
    nTime = 2.1,
    nNum = 0,
    tbPrelock = {8},
    tbStartEvent = {
      {
        "SetGameWorldScale",
        0.1
      }
    },
    tbUnLockEvent = {
      {
        "SetGameWorldScale",
        1
      }
    }
  },
  [10] = {
    nTime = 0,
    nNum = 1,
    tbPrelock = {7},
    tbStartEvent = {
      {
        "AddNpc",
        6,
        1,
        0,
        "npc",
        "dugujian",
        false,
        48,
        0,
        0,
        0
      },
      {
        "AddNpc",
        7,
        1,
        0,
        "npc1",
        "yangying",
        false,
        48,
        0,
        0,
        0
      },
      {
        "SetNpcBloodVisable",
        "npc",
        false,
        0
      },
      {
        "SetNpcBloodVisable",
        "npc1",
        false,
        0
      },
      {
        "MoveCameraToPosition",
        10,
        2,
        6006,
        3619,
        5
      },
      {
        "SetAllUiVisiable",
        false
      },
      {
        "SetForbiddenOperation",
        true
      }
    },
    tbUnLockEvent = {}
  },
  [11] = {
    nTime = 0,
    nNum = 1,
    tbPrelock = {10},
    tbStartEvent = {
      {
        "RaiseEvent",
        "ShowTaskDialog",
        11,
        1110,
        false
      }
    },
    tbUnLockEvent = {
      {
        "NpcBubbleTalk",
        "sl",
        "惹我五色教，受死吧！",
        4,
        0,
        1
      },
      {
        "NpcBubbleTalk",
        "npc1",
        "无耻鼠辈，大言不惭！",
        4,
        2,
        1
      },
      {
        "BlackMsg",
        "击败五色教头目！"
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
        "LeaveAnimationState",
        true
      },
      {
        "SetNpcBloodVisable",
        "npc",
        true,
        0
      },
      {
        "SetNpcBloodVisable",
        "npc1",
        true,
        0
      },
      {
        "SetNpcBloodVisable",
        "sl",
        true,
        0
      },
      {
        "SetNpcProtected",
        "sl",
        0
      },
      {
        "SetAiActive",
        "sl",
        1
      }
    }
  },
  [12] = {
    nTime = 1,
    nNum = 0,
    tbPrelock = {9},
    tbStartEvent = {},
    tbUnLockEvent = {
      {"GameWin"}
    }
  },
  [13] = {
    nTime = 600,
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
  [30] = {
    nTime = 0,
    nNum = 1,
    tbPrelock = {1},
    tbStartEvent = {},
    tbUnLockEvent = {
      {
        "ClearTargetPos"
      },
      {
        "NpcBubbleTalk",
        "Patrol_1",
        "你是什么人，竟敢擅闯方员外山庄！",
        4,
        0,
        1
      },
      {
        "CastSkill",
        "Patrol_1",
        28,
        10,
        -1,
        -1
      },
      {
        "CloseLock",
        31,
        33
      }
    }
  },
  [31] = {
    nTime = 0,
    nNum = 1,
    tbPrelock = {1},
    tbStartEvent = {},
    tbUnLockEvent = {
      {
        "ClearTargetPos"
      },
      {
        "NpcBubbleTalk",
        "Patrol_2",
        "你是什么人，竟敢擅闯方员外山庄！",
        4,
        0,
        1
      },
      {
        "CastSkill",
        "Patrol_2",
        28,
        10,
        -1,
        -1
      },
      {
        "CloseLock",
        32,
        33
      },
      {"CloseLock", 30}
    }
  },
  [32] = {
    nTime = 0,
    nNum = 1,
    tbPrelock = {1},
    tbStartEvent = {},
    tbUnLockEvent = {
      {
        "ClearTargetPos"
      },
      {
        "NpcBubbleTalk",
        "Patrol_3",
        "你是什么人，竟敢擅闯方员外山庄！",
        4,
        0,
        1
      },
      {
        "CastSkill",
        "Patrol_3",
        28,
        10,
        -1,
        -1
      },
      {
        "CloseLock",
        30,
        31
      },
      {"CloseLock", 33}
    }
  },
  [33] = {
    nTime = 0,
    nNum = 1,
    tbPrelock = {1},
    tbStartEvent = {},
    tbUnLockEvent = {
      {
        "ClearTargetPos"
      },
      {
        "NpcBubbleTalk",
        "Patrol_4",
        "你是什么人，竟敢擅闯方员外山庄！",
        4,
        0,
        1
      },
      {
        "CastSkill",
        "Patrol_4",
        28,
        10,
        -1,
        -1
      },
      {
        "CloseLock",
        30,
        32
      }
    }
  },
  [34] = {
    nTime = 0,
    nNum = 19,
    tbPrelock = {
      {
        30,
        31,
        32,
        33
      }
    },
    tbStartEvent = {
      {"CloseLock", 36},
      {
        "SetNpcAi",
        "Patrol_1",
        "Setting/Npc/Ai/CommonActive4.ini"
      },
      {
        "SetNpcAi",
        "Patrol_2",
        "Setting/Npc/Ai/CommonActive4.ini"
      },
      {
        "SetNpcAi",
        "Patrol_3",
        "Setting/Npc/Ai/CommonActive4.ini"
      },
      {
        "SetNpcAi",
        "Patrol_4",
        "Setting/Npc/Ai/CommonActive4.ini"
      },
      {
        "AddNpc",
        8,
        4,
        0,
        "wall1",
        "wall_1_1",
        false,
        16
      },
      {
        "RaiseEvent",
        "CloseDynamicObstacle",
        "ops1"
      },
      {
        "NpcRemoveBuff",
        "Patrol_1",
        2402
      },
      {
        "NpcRemoveBuff",
        "Patrol_2",
        2402
      },
      {
        "NpcRemoveBuff",
        "Patrol_3",
        2402
      },
      {
        "NpcRemoveBuff",
        "Patrol_4",
        2402
      },
      {
        "SetNpcRange",
        "Patrol_1",
        5000,
        5000,
        2
      },
      {
        "SetNpcRange",
        "Patrol_2",
        5000,
        5000,
        2
      },
      {
        "SetNpcRange",
        "Patrol_3",
        5000,
        5000,
        2
      },
      {
        "SetNpcRange",
        "Patrol_4",
        5000,
        5000,
        2
      },
      {
        "BlackMsg",
        "你被发现了，惊动了周围埋伏的山庄护卫！"
      },
      {
        "AddNpc",
        16,
        1,
        34,
        "Patrol_Leader",
        "Patrol_Leader",
        1,
        0,
        1.5,
        9011,
        1
      },
      {
        "AddNpc",
        3,
        14,
        34,
        "Patrol_1_1",
        "Patrol_1_1",
        1,
        0,
        2,
        0,
        0
      },
      {
        "NpcBubbleTalk",
        "Patrol_Leader",
        "哪里来的家伙，竟敢擅闯方员外山庄，真是不知死活！！",
        5,
        2,
        1
      },
      {
        "SetNpcRange",
        "Patrol_Leader",
        5000,
        5000,
        2
      },
      {
        "SetNpcRange",
        "Patrol_1_1",
        5000,
        5000,
        2
      }
    },
    tbUnLockEvent = {
      {
        "PlayCameraEffect",
        9119
      },
      {
        "ChangeCameraSetting",
        23,
        35,
        20
      },
      {
        "OpenDynamicObstacle",
        "ops1"
      },
      {
        "SetTargetPos",
        3035,
        6144
      },
      {"DoDeath", "wall1"},
      {
        "BlackMsg",
        "居然埋伏了这么多人，真是凶险！"
      }
    }
  },
  [35] = {
    nTime = 2,
    nNum = 0,
    tbPrelock = {
      {
        30,
        31,
        32,
        33
      }
    },
    tbStartEvent = {},
    tbUnLockEvent = {
      {
        "RaiseEvent",
        "CallPartner"
      },
      {
        "ChangeCameraSetting",
        40,
        35,
        20
      }
    }
  },
  [36] = {
    nTime = 1,
    nNum = 0,
    tbPrelock = {3},
    tbStartEvent = {},
    tbUnLockEvent = {
      {
        "RaiseEvent",
        "CallPartner"
      }
    }
  }
}
