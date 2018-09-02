local tbFubenSetting = {}
Fuben:SetFubenSetting(43, tbFubenSetting)
tbFubenSetting.szFubenClass = "PersonalFubenBase"
tbFubenSetting.szName = "测试副本"
tbFubenSetting.szNpcPointFile = "Setting/Fuben/PersonalFuben/5_2/NpcPos.tab"
tbFubenSetting.szPathFile = "Setting/Fuben/PersonalFuben/5_2/NpcPath.tab"
tbFubenSetting.tbBeginPoint = {1031, 949}
tbFubenSetting.nStartDir = 16
tbFubenSetting.ANIMATION = {
  [1] = "Scenes/Maps/yw_luoyegu/Main Camera.controller"
}
tbFubenSetting.NPC = {
  [1] = {
    nTemplate = 859,
    nLevel = 44,
    nSeries = -1
  },
  [2] = {
    nTemplate = 860,
    nLevel = 44,
    nSeries = -1
  },
  [3] = {
    nTemplate = 861,
    nLevel = 46,
    nSeries = -1
  },
  [4] = {
    nTemplate = 747,
    nLevel = 46,
    nSeries = 0
  },
  [5] = {
    nTemplate = 853,
    nLevel = 46,
    nSeries = 0
  },
  [6] = {
    nTemplate = 862,
    nLevel = 46,
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
        1055,
        false
      }
    },
    tbUnLockEvent = {
      {
        "SetShowTime",
        2
      }
    }
  },
  [2] = {
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
  [3] = {
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
        "trap1",
        3
      },
      {
        "SetTargetPos",
        2371,
        2205
      },
      {
        "AddNpc",
        9,
        1,
        0,
        "wall",
        "men1",
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
  [4] = {
    nTime = 0,
    nNum = 8,
    tbPrelock = {3},
    tbStartEvent = {
      {
        "AddNpc",
        1,
        4,
        4,
        "gw",
        "guaiwu1",
        false,
        0,
        0.5,
        9005,
        0.5
      },
      {
        "AddNpc",
        1,
        4,
        4,
        "gw",
        "guaiwu2",
        false,
        0,
        2,
        9005,
        0.5
      },
      {
        "BlackMsg",
        "击败此处的五色教徒！"
      }
    },
    tbUnLockEvent = {
      {
        "OpenDynamicObstacle",
        "obs1"
      },
      {"DoDeath", "wall"}
    }
  },
  [5] = {
    nTime = 0,
    nNum = 1,
    tbPrelock = {4},
    tbStartEvent = {
      {
        "TrapUnlock",
        "trap2",
        5
      },
      {
        "SetTargetPos",
        5558,
        2518
      }
    },
    tbUnLockEvent = {
      {
        "ClearTargetPos"
      },
      {
        "AddNpc",
        9,
        1,
        0,
        "wall",
        "men2",
        false,
        48
      }
    }
  },
  [6] = {
    nTime = 0,
    nNum = 8,
    tbPrelock = {5},
    tbStartEvent = {
      {
        "AddNpc",
        1,
        6,
        6,
        "gw",
        "guaiwu3",
        false,
        0,
        0.5,
        9005,
        0.5
      },
      {
        "AddNpc",
        2,
        2,
        6,
        "gw",
        "guaiwu4",
        false,
        0,
        2,
        0,
        0
      },
      {
        "BlackMsg",
        "还有刺客出没？五色教雇佣的？"
      }
    },
    tbUnLockEvent = {
      {
        "OpenDynamicObstacle",
        "obs2"
      },
      {"DoDeath", "wall"}
    }
  },
  [7] = {
    nTime = 0,
    nNum = 1,
    tbPrelock = {6},
    tbStartEvent = {
      {
        "TrapUnlock",
        "trap3",
        7
      },
      {
        "SetTargetPos",
        6103,
        5165
      }
    },
    tbUnLockEvent = {
      {
        "ClearTargetPos"
      },
      {
        "AddNpc",
        9,
        2,
        0,
        "wall",
        "men3",
        false,
        32
      }
    }
  },
  [8] = {
    nTime = 0,
    nNum = 8,
    tbPrelock = {7},
    tbStartEvent = {
      {
        "AddNpc",
        1,
        4,
        8,
        "gw",
        "guaiwu5",
        false,
        0,
        0.5,
        9005,
        0.5
      },
      {
        "AddNpc",
        2,
        4,
        8,
        "gw",
        "guaiwu6",
        false,
        0,
        2,
        0,
        0
      }
    },
    tbUnLockEvent = {
      {
        "OpenDynamicObstacle",
        "obs3"
      },
      {
        "OpenDynamicObstacle",
        "obs4"
      },
      {"DoDeath", "wall"}
    }
  },
  [9] = {
    nTime = 0,
    nNum = 1,
    tbPrelock = {8},
    tbStartEvent = {
      {
        "TrapUnlock",
        "trap4",
        9
      },
      {
        "SetTargetPos",
        3110,
        5583
      }
    },
    tbUnLockEvent = {
      {
        "ClearTargetPos"
      },
      {
        "RaiseEvent",
        "CloseDynamicObstacle",
        "obs4"
      },
      {
        "AddNpc",
        9,
        2,
        0,
        "wall",
        "men4",
        false,
        32
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
        3,
        1,
        10,
        "boss",
        "boss",
        false,
        64,
        0,
        0,
        0
      },
      {
        "SetNpcProtected",
        "boss",
        1
      },
      {
        "SetNpcBloodVisable",
        "boss",
        false,
        0
      },
      {
        "SetAiActive",
        "boss",
        0
      }
    },
    tbUnLockEvent = {}
  },
  [11] = {
    nTime = 2.1,
    nNum = 0,
    tbPrelock = {10},
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
  [12] = {
    nTime = 0,
    nNum = 1,
    tbPrelock = {9},
    tbStartEvent = {
      {
        "MoveCameraToPosition",
        12,
        2,
        2357,
        5551,
        5
      },
      {
        "AddNpc",
        4,
        1,
        0,
        "npc1",
        "dugujian",
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
        "zhanglinxin",
        false,
        32,
        0,
        0,
        0
      },
      {
        "SetNpcBloodVisable",
        "npc1",
        false,
        0
      },
      {
        "SetNpcBloodVisable",
        "npc2",
        false,
        0
      },
      {
        "ChangeNpcAi",
        "npc1",
        "Move",
        "path1",
        0,
        1,
        1,
        0,
        0
      },
      {
        "ChangeNpcAi",
        "npc2",
        "Move",
        "path2",
        0,
        1,
        1,
        0,
        0
      },
      {
        "NpcBubbleTalk",
        "npc1",
        "无耻恶徒，休得无礼！",
        4,
        0.5,
        1
      },
      {
        "SetForbiddenOperation",
        true
      },
      {
        "SetAllUiVisiable",
        false
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
        "RaiseEvent",
        "ShowTaskDialog",
        13,
        1056,
        false
      }
    },
    tbUnLockEvent = {
      {
        "SetNpcBloodVisable",
        "npc1",
        true,
        0
      },
      {
        "SetNpcBloodVisable",
        "npc2",
        true,
        0
      },
      {
        "SetNpcBloodVisable",
        "boss",
        true,
        0
      },
      {
        "SetNpcProtected",
        "boss",
        0
      },
      {
        "SetAiActive",
        "boss",
        1
      },
      {
        "SetForbiddenOperation",
        false
      },
      {
        "SetAllUiVisiable",
        true
      },
      {
        "LeaveAnimationState",
        true
      },
      {
        "BlackMsg",
        "击败刺客头目，救下柳中原！"
      }
    }
  },
  [14] = {
    nTime = 0,
    nNum = 1,
    tbPrelock = {11},
    tbStartEvent = {
      {
        "MoveCameraToPosition",
        14,
        2,
        1633,
        5585,
        5
      },
      {
        "AddNpc",
        6,
        1,
        0,
        "npc",
        "liuzhongyuan",
        false,
        32,
        0,
        0,
        0
      },
      {
        "DoCommonAct",
        "npc",
        36,
        0,
        1,
        0
      },
      {
        "SetNpcBloodVisable",
        "npc",
        false,
        0
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
        "SetNpcBloodVisable",
        "npc1",
        false,
        0
      },
      {
        "SetNpcBloodVisable",
        "npc2",
        false,
        0
      },
      {
        "ChangeNpcAi",
        "npc1",
        "Move",
        "path3",
        0,
        1,
        1,
        0,
        0
      },
      {
        "ChangeNpcAi",
        "npc2",
        "Move",
        "path4",
        0,
        1,
        1,
        0,
        0
      },
      {
        "NpcBubbleTalk",
        "npc1",
        "柳老前辈！",
        3,
        0.5,
        1
      }
    },
    tbUnLockEvent = {
      {
        "ChangeNpcFightState",
        "npc1",
        0,
        0
      },
      {
        "ChangeNpcFightState",
        "npc2",
        0,
        0
      }
    }
  },
  [15] = {
    nTime = 18,
    nNum = 0,
    tbPrelock = {14},
    tbStartEvent = {
      {
        "NpcBubbleTalk",
        "npc",
        "是独孤少侠吗？",
        3,
        0.5,
        1
      },
      {
        "NpcBubbleTalk",
        "npc1",
        "柳前辈，是我！",
        3,
        3,
        1
      },
      {
        "NpcBubbleTalk",
        "npc",
        "看来你师傅得到的是、是五色教的暗杀名单，快、快去长安通知顾枫……",
        3,
        5,
        1
      },
      {
        "NpcBubbleTalk",
        "npc1",
        "那您……",
        3,
        8,
        1
      },
      {
        "NpcBubbleTalk",
        "npc",
        "我、我不行了……",
        3,
        10,
        1
      },
      {
        "NpcBubbleTalk",
        "npc1",
        "柳伯伯，方勉真的是五色教第一把剑吗？",
        3,
        12,
        1
      },
      {
        "NpcBubbleTalk",
        "npc",
        "绝无可能……还有……你们两家的恩、恩仇，其实……",
        3,
        15,
        1
      }
    },
    tbUnLockEvent = {}
  },
  [16] = {
    nTime = 3,
    nNum = 0,
    tbPrelock = {15},
    tbStartEvent = {
      {"DoDeath", "npc"},
      {
        "NpcBubbleTalk",
        "npc1",
        "柳老前辈！",
        3,
        0.5,
        1
      },
      {
        "NpcBubbleTalk",
        "npc2",
        "……",
        3,
        1.5,
        1
      }
    },
    tbUnLockEvent = {}
  },
  [17] = {
    nTime = 0,
    nNum = 1,
    tbPrelock = {16},
    tbStartEvent = {
      {
        "RaiseEvent",
        "ShowTaskDialog",
        17,
        1057,
        false
      }
    },
    tbUnLockEvent = {
      {
        "SetForbiddenOperation",
        false
      },
      {
        "SetAllUiVisiable",
        true
      },
      {"GameWin"}
    }
  }
}
