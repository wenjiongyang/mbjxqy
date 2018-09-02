local tbFubenSetting = {}
Fuben:SetFubenSetting(37, tbFubenSetting)
tbFubenSetting.szFubenClass = "PersonalFubenBase"
tbFubenSetting.szName = "测试副本"
tbFubenSetting.szNpcPointFile = "Setting/Fuben/PersonalFuben/4_1/NpcPos.tab"
tbFubenSetting.szPathFile = "Setting/Fuben/PersonalFuben/4_1/NpcPath.tab"
tbFubenSetting.tbBeginPoint = {2231, 3306}
tbFubenSetting.nStartDir = 29
tbFubenSetting.ANIMATION = {
  [1] = "Scenes/Maps/yw_luoyegu/Main Camera.controller"
}
tbFubenSetting.NPC = {
  [1] = {
    nTemplate = 842,
    nLevel = 32,
    nSeries = -1
  },
  [2] = {
    nTemplate = 843,
    nLevel = 33,
    nSeries = -1
  },
  [3] = {
    nTemplate = 34,
    nLevel = 32,
    nSeries = -1
  },
  [4] = {
    nTemplate = 37,
    nLevel = 32,
    nSeries = -1
  },
  [5] = {
    nTemplate = 29,
    nLevel = 32,
    nSeries = -1
  },
  [6] = {
    nTemplate = 844,
    nLevel = 34,
    nSeries = -1
  },
  [7] = {
    nTemplate = 747,
    nLevel = 34,
    nSeries = 0
  },
  [8] = {
    nTemplate = 104,
    nLevel = 32,
    nSeries = 0
  },
  [16] = {
    nTemplate = 1355,
    nLevel = 32,
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
        1046,
        false
      }
    },
    tbUnLockEvent = {
      {
        "SetShowTime",
        30
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
        2538,
        2134
      },
      {
        "AddNpc",
        8,
        1,
        2,
        "wall",
        "wall_1_1",
        false,
        29
      }
    },
    tbUnLockEvent = {
      {
        "ClearTargetPos"
      },
      {
        "AddNpc",
        1,
        4,
        3,
        "guaiwu",
        "4_1_1_1",
        1,
        0,
        0,
        9005,
        0.5
      },
      {
        "AddNpc",
        4,
        4,
        3,
        "guaiwu",
        "4_1_1_2",
        1,
        0,
        4,
        9005,
        0.5
      },
      {
        "NpcBubbleTalk",
        "guaiwu",
        "小子，这块地方已经被我们承包了！不想死的话赶紧滚！",
        4,
        1,
        1
      }
    }
  },
  [3] = {
    nTime = 0,
    nNum = 8,
    tbPrelock = {2},
    tbStartEvent = {},
    tbUnLockEvent = {
      {
        "SetTargetPos",
        6289,
        2921
      },
      {
        "OpenDynamicObstacle",
        "ops1"
      },
      {"DoDeath", "wall"},
      {
        "AddNpc",
        8,
        1,
        2,
        "wall",
        "wall_1_2",
        false,
        17
      },
      {
        "NpcBubbleTalk",
        "Start_Npc1",
        "他们究竟是什么人，出现在这里有什么目的？",
        4,
        0,
        1
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
        "ClearTargetPos"
      },
      {
        "AddNpc",
        3,
        2,
        5,
        "guaiwu",
        "4_1_2_1",
        1,
        0,
        0,
        0,
        0
      },
      {
        "AddNpc",
        3,
        2,
        5,
        "guaiwu",
        "4_1_2_2",
        1,
        0,
        2,
        0,
        0
      },
      {
        "AddNpc",
        3,
        2,
        5,
        "guaiwu",
        "4_1_2_3",
        1,
        0,
        4,
        0,
        0
      }
    }
  },
  [5] = {
    nTime = 0,
    nNum = 6,
    tbPrelock = {4},
    tbStartEvent = {},
    tbUnLockEvent = {
      {
        "SetTargetPos",
        6074,
        5210
      },
      {
        "OpenDynamicObstacle",
        "ops2"
      },
      {"DoDeath", "wall"},
      {
        "AddNpc",
        8,
        1,
        2,
        "wall",
        "wall_1_3",
        false,
        7
      },
      {
        "NpcBubbleTalk",
        "Start_Npc1",
        "这群人似乎正在搜寻什么东西？莫非....",
        4,
        0,
        1
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
        "ClearTargetPos"
      },
      {
        "AddNpc",
        1,
        4,
        7,
        "guaiwu",
        "4_1_3_1",
        1,
        0,
        0,
        9005,
        0.5
      },
      {
        "AddNpc",
        5,
        2,
        7,
        "guaiwu",
        "4_1_3_2",
        1,
        0,
        3,
        0,
        0
      },
      {
        "AddNpc",
        1,
        3,
        7,
        "guaiwu",
        "4_1_3_3",
        1,
        0,
        5,
        9005,
        0.5
      },
      {
        "AddNpc",
        2,
        1,
        7,
        "guaiwu",
        "4_1_3_4",
        1,
        0,
        5,
        9005,
        0.5
      },
      {
        "NpcBubbleTalk",
        "guaiwu",
        "哪里来的家伙，竟敢阻碍本教办事！真是找死！",
        4,
        1,
        1
      }
    }
  },
  [7] = {
    nTime = 0,
    nNum = 10,
    tbPrelock = {6},
    tbStartEvent = {},
    tbUnLockEvent = {
      {
        "SetTargetPos",
        3367,
        5348
      },
      {
        "OpenDynamicObstacle",
        "ops3"
      },
      {"DoDeath", "wall"}
    }
  },
  [8] = {
    nTime = 0,
    nNum = 1,
    tbPrelock = {7},
    tbStartEvent = {
      {
        "TrapUnlock",
        "TrapLock4",
        8
      }
    },
    tbUnLockEvent = {
      {
        "ClearTargetPos"
      },
      {
        "RaiseEvent",
        "CloseDynamicObstacle",
        "ops3"
      },
      {
        "AddNpc",
        8,
        1,
        2,
        "wall",
        "wall_1_3",
        false,
        7
      }
    }
  },
  [9] = {
    nTime = 0,
    nNum = 1,
    tbPrelock = {8},
    tbStartEvent = {
      {
        "MoveCameraToPosition",
        9,
        2,
        2790,
        5724,
        10
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
        16,
        1,
        0,
        "npc",
        "shibei",
        false,
        32,
        0,
        0,
        0
      },
      {
        "AddNpc",
        7,
        1,
        0,
        "Start_Npc1",
        "Start_Npc1",
        false,
        64,
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
    tbUnLockEvent = {}
  },
  [10] = {
    nTime = 0,
    nNum = 1,
    tbPrelock = {9},
    tbStartEvent = {
      {
        "DoCommonAct",
        "Start_Npc1",
        38,
        0,
        0,
        0
      },
      {
        "RaiseEvent",
        "ShowTaskDialog",
        10,
        1047,
        false,
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
  [11] = {
    nTime = 0,
    nNum = 1,
    tbPrelock = {10},
    tbStartEvent = {
      {
        "AddNpc",
        6,
        1,
        11,
        "BOSS",
        "4_1_5",
        false,
        0,
        0,
        0,
        0
      },
      {
        "SetNpcProtected",
        "BOSS",
        1
      },
      {
        "SetNpcBloodVisable",
        "BOSS",
        false,
        0
      },
      {
        "ChangeNpcAi",
        "BOSS",
        "Move",
        "path1",
        13,
        1,
        1,
        0,
        0
      },
      {
        "SetNpcDir",
        "Start_Npc1",
        32
      },
      {
        "NpcBubbleTalk",
        "Start_Npc1",
        "什么人？",
        4,
        0,
        1
      },
      {
        "NpcBubbleTalk",
        "BOSS",
        "哈哈，踏破铁鞋无觅处，得来全不费功夫！",
        4,
        0,
        1
      }
    },
    tbUnLockEvent = {
      {
        "SetGameWorldScale",
        0.1
      }
    }
  },
  [12] = {
    nTime = 2.1,
    nNum = 0,
    tbPrelock = {11},
    tbStartEvent = {},
    tbUnLockEvent = {
      {
        "SetGameWorldScale",
        1
      },
      {"GameWin"}
    }
  },
  [13] = {
    nTime = 0,
    nNum = 1,
    tbPrelock = {10},
    tbStartEvent = {},
    tbUnLockEvent = {
      {
        "SetAiActive",
        "BOSS",
        0
      }
    }
  },
  [14] = {
    nTime = 0,
    nNum = 1,
    tbPrelock = {10},
    tbStartEvent = {
      {
        "RaiseEvent",
        "ShowTaskDialog",
        14,
        1094,
        false,
        1.5
      }
    },
    tbUnLockEvent = {
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
        "SetNpcProtected",
        "BOSS",
        0
      },
      {
        "SetAiActive",
        "BOSS",
        1
      },
      {
        "SetNpcBloodVisable",
        "BOSS",
        true,
        0
      },
      {
        "SetNpcBloodVisable",
        "Start_Npc1",
        false,
        0
      },
      {
        "NpcBubbleTalk",
        "Start_Npc1",
        "我要为我师傅报仇！",
        4,
        0,
        1
      },
      {
        "NpcBubbleTalk",
        "BOSS",
        "找死！",
        4,
        1,
        1
      }
    }
  },
  [30] = {
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
  }
}
