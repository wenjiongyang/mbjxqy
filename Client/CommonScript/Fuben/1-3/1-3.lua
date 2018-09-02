local tbFubenSetting = {}
Fuben:SetFubenSetting(22, tbFubenSetting)
tbFubenSetting.szFubenClass = "PersonalFubenBase"
tbFubenSetting.szName = "测试副本"
tbFubenSetting.szNpcPointFile = "Setting/Fuben/PersonalFuben/1_3/NpcPos.tab"
tbFubenSetting.szPathFile = "Setting/Fuben/PersonalFuben/1_3/NpcPath.tab"
tbFubenSetting.tbBeginPoint = {1484, 4677}
tbFubenSetting.nStartDir = 32
tbFubenSetting.NPC = {
  [1] = {
    nTemplate = 764,
    nLevel = -1,
    nSeries = 0
  },
  [2] = {
    nTemplate = 765,
    nLevel = -1,
    nSeries = 0
  },
  [3] = {
    nTemplate = 766,
    nLevel = -1,
    nSeries = 0
  },
  [4] = {
    nTemplate = 1317,
    nLevel = -1,
    nSeries = 0
  },
  [5] = {
    nTemplate = 1318,
    nLevel = -1,
    nSeries = 0
  },
  [6] = {
    nTemplate = 104,
    nLevel = -1,
    nSeries = 0
  },
  [7] = {
    nTemplate = 1430,
    nLevel = 6,
    nSeries = 0
  }
}
tbFubenSetting.bForbidPartner = true
tbFubenSetting.bForbidHelper = true
tbFubenSetting.LOCK = {
  [1] = {
    nTime = 1,
    nNum = 0,
    tbPrelock = {},
    tbStartEvent = {
      {
        "AddNpc",
        1,
        1,
        0,
        "fnpc1",
        "fnpc1",
        false,
        32,
        0,
        0,
        0
      },
      {
        "AddNpc",
        2,
        1,
        0,
        "fnpc2",
        "fnpc2",
        false,
        32,
        0,
        0,
        0
      },
      {
        "AddNpc",
        3,
        1,
        0,
        "npc",
        "nalanqianling",
        false,
        16,
        0,
        0,
        0
      },
      {
        "BlackMsg",
        "深入禁地看看！"
      },
      {
        "NpcBubbleTalk",
        "fnpc1",
        "我们前去禁地看看吧！",
        4,
        1,
        1
      }
    },
    tbUnLockEvent = {
      {
        "SetShowTime",
        2
      },
      {
        "RaiseEvent",
        "FllowPlayer",
        "fnpc1",
        true
      },
      {
        "RaiseEvent",
        "FllowPlayer",
        "fnpc2",
        true
      },
      {
        "ChangeNpcFightState",
        "fnpc1",
        0
      },
      {
        "ChangeNpcFightState",
        "fnpc2",
        0
      },
      {
        "ChangeNpcFightState",
        "npc",
        0
      },
      {
        "AddNpc",
        6,
        1,
        0,
        "wall",
        "wall",
        false,
        32
      }
    }
  },
  [2] = {
    nTime = 300,
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
  [100] = {
    nTime = 0,
    nNum = 1,
    tbPrelock = {1},
    tbStartEvent = {
      {
        "TrapUnlock",
        "trap0",
        100
      },
      {
        "SetTargetPos",
        1470,
        3785
      }
    },
    tbUnLockEvent = {
      {
        "ClearTargetPos"
      },
      {
        "RaiseEvent",
        "ChangeAutoFight",
        false
      }
    }
  },
  [101] = {
    nTime = 0,
    nNum = 1,
    tbPrelock = {100},
    tbStartEvent = {
      {
        "PlayCameraEffect",
        9119
      },
      {
        "MoveCameraToPosition",
        101,
        1.5,
        1627,
        2328,
        2
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
  [3] = {
    nTime = 0,
    nNum = 1,
    tbPrelock = {101},
    tbStartEvent = {
      {
        "RaiseEvent",
        "ShowTaskDialog",
        3,
        1005,
        false
      },
      {
        "SetForbiddenOperation",
        false
      },
      {
        "ChangeFightState",
        1
      }
    },
    tbUnLockEvent = {
      {
        "SetForbiddenOperation",
        true
      }
    }
  },
  [4] = {
    nTime = 2,
    nNum = 0,
    tbPrelock = {3},
    tbStartEvent = {
      {
        "SetNpcDir",
        "npc",
        56
      }
    },
    tbUnLockEvent = {
      {
        "SetNpcDir",
        "npc",
        40
      }
    }
  },
  [5] = {
    nTime = 1,
    nNum = 0,
    tbPrelock = {4},
    tbStartEvent = {},
    tbUnLockEvent = {}
  },
  [6] = {
    nTime = 0,
    nNum = 1,
    tbPrelock = {5},
    tbStartEvent = {
      {
        "ChangeNpcAi",
        "npc",
        "Move",
        "path1",
        6,
        0,
        0,
        1,
        0
      }
    },
    tbUnLockEvent = {
      {
        "AddNpc",
        3,
        1,
        0,
        "npc",
        "nalanqianling1",
        false,
        64,
        0,
        0,
        0
      },
      {
        "ChangeNpcFightState",
        "npc",
        0
      }
    }
  },
  [7] = {
    nTime = 1,
    nNum = 0,
    tbPrelock = {5},
    tbStartEvent = {},
    tbUnLockEvent = {}
  },
  [8] = {
    nTime = 0,
    nNum = 1,
    tbPrelock = {7},
    tbStartEvent = {
      {
        "AddNpc",
        7,
        1,
        0,
        "jg1",
        "jiguan1",
        false,
        0,
        0,
        0,
        0
      },
      {
        "AddNpc",
        7,
        1,
        0,
        "jg2",
        "jiguan2",
        false,
        0,
        0,
        0,
        0
      },
      {
        "AddNpc",
        7,
        1,
        0,
        "jg3",
        "jiguan3",
        false,
        0,
        0,
        0,
        0
      },
      {
        "AddNpc",
        7,
        1,
        0,
        "jg4",
        "jiguan4",
        false,
        0,
        0,
        0,
        0
      },
      {
        "AddNpc",
        7,
        1,
        0,
        "jg5",
        "jiguan5",
        false,
        0,
        0,
        0,
        0
      },
      {
        "AddNpc",
        7,
        1,
        0,
        "jg6",
        "jiguan6",
        false,
        0,
        0,
        0,
        0
      },
      {
        "AddNpc",
        7,
        1,
        0,
        "jg7",
        "jiguan7",
        false,
        0,
        0,
        0,
        0
      },
      {
        "AddNpc",
        7,
        1,
        0,
        "jg8",
        "jiguan8",
        false,
        0,
        0,
        0,
        0
      },
      {
        "ChangeNpcAi",
        "jg1",
        "Move",
        "path6_1",
        0,
        0,
        0,
        0,
        1
      },
      {
        "ChangeNpcAi",
        "jg2",
        "Move",
        "path6_2",
        0,
        0,
        0,
        0,
        1
      },
      {
        "ChangeNpcAi",
        "jg3",
        "Move",
        "path6_3",
        0,
        0,
        0,
        0,
        1
      },
      {
        "ChangeNpcAi",
        "jg4",
        "Move",
        "path6_4",
        0,
        0,
        0,
        0,
        1
      },
      {
        "ChangeNpcAi",
        "jg5",
        "Move",
        "path6_5",
        0,
        0,
        0,
        0,
        1
      },
      {
        "ChangeNpcAi",
        "jg6",
        "Move",
        "path6_6",
        0,
        0,
        0,
        0,
        1
      },
      {
        "ChangeNpcAi",
        "jg7",
        "Move",
        "path6_7",
        0,
        0,
        0,
        0,
        1
      },
      {
        "ChangeNpcAi",
        "jg8",
        "Move",
        "path6_8",
        0,
        0,
        0,
        0,
        1
      },
      {
        "SetForbiddenOperation",
        false
      },
      {
        "RaiseEvent",
        "ShowTaskDialog",
        8,
        1006,
        false
      }
    },
    tbUnLockEvent = {
      {
        "LeaveAnimationState",
        true
      },
      {
        "PlayCameraEffect",
        9119
      },
      {
        "SetAllUiVisiable",
        true
      }
    }
  },
  [9] = {
    nTime = 0,
    nNum = 1,
    tbPrelock = {8},
    tbStartEvent = {
      {
        "TrapUnlock",
        "trap1",
        9
      },
      {
        "SetTargetPos",
        4058,
        2201
      }
    },
    tbUnLockEvent = {
      {
        "ClearTargetPos"
      }
    }
  },
  [10] = {
    nTime = 0,
    nNum = 1,
    tbPrelock = {9},
    tbStartEvent = {
      {
        "AddNpc",
        4,
        1,
        0,
        "npc1",
        "npc1",
        false,
        32,
        0,
        0,
        0
      },
      {
        "AddNpc",
        5,
        1,
        0,
        "npc2",
        "npc2",
        false,
        32,
        0,
        0,
        0
      },
      {
        "ChangeNpcFightState",
        "npc1",
        0
      },
      {
        "ChangeNpcFightState",
        "npc2",
        0
      },
      {
        "MoveCameraToPosition",
        10,
        1,
        5226,
        2731,
        5
      },
      {
        "PlayCameraEffect",
        9119
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
    nNum = 2,
    tbPrelock = {10},
    tbStartEvent = {
      {
        "BlackMsg",
        "纳兰潜凛拍了三下手后，两个人走了出来！"
      },
      {
        "ChangeNpcAi",
        "npc1",
        "Move",
        "path2_1",
        11,
        0,
        0,
        0,
        0
      },
      {
        "ChangeNpcAi",
        "npc2",
        "Move",
        "path2_2",
        11,
        0,
        0,
        0,
        0
      }
    },
    tbUnLockEvent = {}
  },
  [12] = {
    nTime = 0,
    nNum = 1,
    tbPrelock = {11},
    tbStartEvent = {
      {
        "RaiseEvent",
        "ShowTaskDialog",
        12,
        1007,
        false
      },
      {
        "SetForbiddenOperation",
        false
      }
    },
    tbUnLockEvent = {}
  },
  [13] = {
    nTime = 1,
    nNum = 0,
    tbPrelock = {12},
    tbStartEvent = {
      {
        "SetForbiddenOperation",
        true
      },
      {
        "NpcBubbleTalk",
        "npc",
        "什么人？！",
        5,
        0,
        1
      },
      {
        "SetNpcDir",
        "npc",
        40
      },
      {
        "ChangeNpcAi",
        "npc1",
        "Move",
        "path4_1",
        11,
        0,
        0,
        1,
        0
      },
      {
        "ChangeNpcAi",
        "npc2",
        "Move",
        "path4_2",
        11,
        0,
        0,
        1,
        0
      },
      {
        "NpcBubbleTalk",
        "npc1",
        "属下告退！",
        3,
        0,
        1
      },
      {
        "NpcBubbleTalk",
        "npc2",
        "属下告退！",
        3,
        0,
        1
      },
      {
        "RaiseEvent",
        "FllowPlayer",
        "fnpc1",
        false
      },
      {
        "RaiseEvent",
        "FllowPlayer",
        "fnpc2",
        false
      }
    },
    tbUnLockEvent = {}
  },
  [14] = {
    nTime = 0,
    nNum = 2,
    tbPrelock = {13},
    tbStartEvent = {
      {
        "ChangeNpcAi",
        "fnpc1",
        "Move",
        "path3_1",
        14,
        0,
        0,
        0,
        0
      },
      {
        "ChangeNpcAi",
        "fnpc2",
        "Move",
        "path3_2",
        14,
        0,
        0,
        0,
        0
      }
    },
    tbUnLockEvent = {}
  },
  [15] = {
    nTime = 0,
    nNum = 1,
    tbPrelock = {14},
    tbStartEvent = {
      {
        "SetForbiddenOperation",
        false
      },
      {
        "RaiseEvent",
        "ShowTaskDialog",
        15,
        1008,
        false
      }
    },
    tbUnLockEvent = {}
  },
  [16] = {
    nTime = 2,
    nNum = 0,
    tbPrelock = {15},
    tbStartEvent = {
      {
        "ChangeNpcAi",
        "fnpc1",
        "Move",
        "path5_1",
        16,
        0,
        0,
        1,
        0
      },
      {
        "ChangeNpcAi",
        "fnpc2",
        "Move",
        "path5_2",
        16,
        0,
        0,
        1,
        0
      }
    },
    tbUnLockEvent = {
      {"GameWin"}
    }
  }
}
