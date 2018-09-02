local tbFubenSetting = {}
Fuben:SetFubenSetting(51, tbFubenSetting)
tbFubenSetting.szFubenClass = "PersonalFubenBase"
tbFubenSetting.szName = "测试副本"
tbFubenSetting.szNpcPointFile = "Setting/Fuben/PersonalFuben/6_5/NpcPos.tab"
tbFubenSetting.szPathFile = "Setting/Fuben/PersonalFuben/6_5/NpcPath.tab"
tbFubenSetting.tbBeginPoint = {1576, 3307}
tbFubenSetting.nStartDir = 24
tbFubenSetting.ANIMATION = {
  [1] = "Scenes/camera/luoyegu04/luoyegu04_jisha.controller"
}
tbFubenSetting.NPC = {
  [1] = {
    nTemplate = 1414,
    nLevel = -1,
    nSeries = -1
  },
  [2] = {
    nTemplate = 1415,
    nLevel = -1,
    nSeries = -1
  },
  [3] = {
    nTemplate = 1416,
    nLevel = -1,
    nSeries = -1
  },
  [4] = {
    nTemplate = 1417,
    nLevel = -1,
    nSeries = -1
  },
  [5] = {
    nTemplate = 747,
    nLevel = -1,
    nSeries = 0
  },
  [6] = {
    nTemplate = 853,
    nLevel = -1,
    nSeries = 0
  },
  [7] = {
    nTemplate = 1418,
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
        1079,
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
        2278,
        2344
      }
    },
    tbUnLockEvent = {
      {
        "AddNpc",
        9,
        1,
        0,
        "wall",
        "men1",
        false,
        56
      },
      {
        "ClearTargetPos"
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
        0.5,
        9005,
        0.5
      }
    }
  },
  [4] = {
    nTime = 0,
    nNum = 9,
    tbPrelock = {1},
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
        0,
        0,
        0
      },
      {
        "AddNpc",
        3,
        1,
        4,
        "gw",
        "pao1",
        false,
        0,
        0,
        0,
        0
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
        5009,
        2432
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
        9005,
        0.5
      }
    }
  },
  [6] = {
    nTime = 0,
    nNum = 9,
    tbPrelock = {4},
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
        3,
        1,
        6,
        "gw",
        "pao2",
        false,
        0,
        0.5,
        9005,
        0.5
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
        5896,
        5342
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
        "men3",
        false,
        40
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
        2.5,
        9005,
        0.5
      }
    }
  },
  [8] = {
    nTime = 0,
    nNum = 9,
    tbPrelock = {6},
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
        3,
        1,
        8,
        "gw",
        "pao3",
        false,
        0,
        0.5,
        9005,
        0.5
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
        "gopos1",
        9
      },
      {
        "SetTargetPos",
        4811,
        4628
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
        "TrapUnlock",
        "trap4",
        10
      },
      {
        "SetTargetPos",
        3170,
        5194
      },
      {
        "ChangeTrap",
        "trap4",
        nil,
        nil,
        nil,
        nil,
        nil,
        true
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
        "men4",
        false,
        38
      },
      {
        "RaiseEvent",
        "CloseDynamicObstacle",
        "obs4"
      }
    }
  },
  [12] = {
    nTime = 0,
    nNum = 2,
    tbPrelock = {10},
    tbStartEvent = {
      {
        "MoveCameraToPosition",
        0,
        1.5,
        2625,
        5335,
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
        "AddNpc",
        4,
        1,
        0,
        "boss",
        "boss",
        false,
        56,
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
      },
      {
        "ChangeNpcFightState",
        "boss",
        0,
        0
      },
      {
        "AddNpc",
        5,
        1,
        0,
        "npc",
        "dugujian",
        false,
        8,
        0,
        0,
        0
      },
      {
        "AddNpc",
        6,
        1,
        0,
        "npc1",
        "zhanglinxin",
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
        "npc2",
        "jinwuzhu",
        false,
        24,
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
        "ChangeNpcFightState",
        "npc",
        0,
        0
      },
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
      },
      {
        "ChangeNpcAi",
        "npc",
        "Move",
        "path1",
        12,
        1,
        1,
        0,
        0
      },
      {
        "ChangeNpcAi",
        "npc1",
        "Move",
        "path2",
        12,
        1,
        1,
        0,
        0
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
        "SetNpcDir",
        "boss",
        24
      },
      {
        "RaiseEvent",
        "ShowTaskDialog",
        13,
        1080,
        false
      }
    },
    tbUnLockEvent = {
      {
        "SetForbiddenOperation",
        true
      }
    }
  },
  [14] = {
    nTime = 8,
    nNum = 0,
    tbPrelock = {13},
    tbStartEvent = {
      {
        "ChangeNpcAi",
        "npc2",
        "Move",
        "path3",
        0,
        0,
        0,
        1,
        0
      },
      {
        "NpcBubbleTalk",
        "boss",
        "天堂大路你不走，地狱无门——你自来投！好，我就送你们去见两个死鬼老爹！",
        4,
        0,
        1
      },
      {
        "NpcBubbleTalk",
        "npc",
        "呸！南宫狗贼，你作恶多端，今日便是你的死期！",
        3,
        3,
        1
      },
      {
        "NpcBubbleTalk",
        "npc1",
        "我要为父亲报仇！",
        3,
        5,
        1
      },
      {
        "NpcBubbleTalk",
        "boss",
        "不自量力，受死吧！",
        3,
        7,
        1
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
        "NpcHpUnlock",
        "boss",
        15,
        30
      },
      {
        "SetNpcProtected",
        "boss",
        0
      },
      {
        "SetNpcBloodVisable",
        "boss",
        true,
        0
      },
      {
        "SetAiActive",
        "boss",
        1
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
        "击败南宫灭！"
      }
    },
    tbUnLockEvent = {}
  },
  [16] = {
    nTime = 0.2,
    nNum = 0,
    tbPrelock = {15},
    tbStartEvent = {
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
        "SetAiActive",
        "npc",
        0
      },
      {
        "SetAiActive",
        "npc1",
        0
      },
      {
        "MoveCameraToPosition",
        0,
        0.5,
        2625,
        5335,
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
        "PlayCameraEffect",
        9119
      }
    },
    tbUnLockEvent = {}
  },
  [100] = {
    nTime = 0.3,
    nNum = 0,
    tbPrelock = {16},
    tbStartEvent = {
      {
        "SetNpcPos",
        "boss",
        2489,
        5454
      },
      {
        "SetNpcPos",
        "npc",
        2711,
        5370
      },
      {
        "SetNpcPos",
        "npc1",
        2512,
        5266
      },
      {
        "RaiseEvent",
        "ShowPlayer",
        false
      },
      {
        "RaiseEvent",
        "ShowPartnerAndHelper",
        false
      }
    },
    tbUnLockEvent = {}
  },
  [17] = {
    nTime = 1,
    nNum = 0,
    tbPrelock = {100},
    tbStartEvent = {
      {
        "DoCommonAct",
        "boss",
        16,
        0,
        0,
        0
      },
      {
        "CastSkill",
        "boss",
        2375,
        1,
        -1,
        -1
      }
    },
    tbUnLockEvent = {}
  },
  [18] = {
    nTime = 1,
    nNum = 0,
    tbPrelock = {17},
    tbStartEvent = {
      {
        "DoCommonAct",
        "npc",
        3,
        0,
        0,
        0
      },
      {
        "DoCommonAct",
        "npc1",
        3,
        0,
        0,
        0
      },
      {
        "NpcBubbleTalk",
        "npc1",
        "啊……",
        2,
        0,
        1
      }
    },
    tbUnLockEvent = {
      {
        "DoCommonAct",
        "npc1",
        36,
        0,
        1,
        0
      }
    }
  },
  [19] = {
    nTime = 8,
    nNum = 0,
    tbPrelock = {18},
    tbStartEvent = {
      {
        "NpcBubbleTalk",
        "npc",
        "（惊呼）啊？！琳儿！……",
        3,
        0,
        1
      },
      {
        "NpcBubbleTalk",
        "boss",
        "（咆哮）哼！不自量力就只有死路一条！",
        3,
        2,
        1
      },
      {
        "NpcBubbleTalk",
        "npc",
        "（疯狂）你！……我跟你拼了！",
        3,
        4,
        1
      },
      {
        "NpcBubbleTalk",
        "boss",
        "啊！你……你竟然学会了“天魔解体大法”？！",
        3,
        6,
        1
      }
    },
    tbUnLockEvent = {
      {
        "LeaveAnimationState",
        true
      }
    }
  },
  [20] = {
    nTime = 0,
    nNum = 1,
    tbPrelock = {19},
    tbStartEvent = {
      {
        "ShowAllRepresentObj",
        false
      },
      {
        "PlayCameraAnimation",
        1,
        20
      },
      {
        "PlayEffect",
        9144,
        0,
        0,
        0,
        1
      },
      {
        "PlayCameraEffect",
        9145
      }
    },
    tbUnLockEvent = {
      {
        "ShowAllRepresentObj",
        true
      },
      {
        "LeaveAnimationState",
        true
      }
    }
  },
  [101] = {
    nTime = 0,
    nNum = 1,
    tbPrelock = {20},
    tbStartEvent = {
      {
        "MoveCameraToPosition",
        101,
        0.8,
        2625,
        5335,
        0
      },
      {
        "RaiseEvent",
        "ShowPlayer",
        false
      },
      {
        "RaiseEvent",
        "ShowPartnerAndHelper",
        false
      }
    },
    tbUnLockEvent = {}
  },
  [21] = {
    nTime = 2.1,
    nNum = 0,
    tbPrelock = {101},
    tbStartEvent = {
      {"DoDeath", "boss"},
      {"DoDeath", "npc"},
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
  [22] = {
    nTime = 1,
    nNum = 0,
    tbPrelock = {21},
    tbStartEvent = {},
    tbUnLockEvent = {
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
      {"GameWin"}
    }
  }
}
