local tbFubenSetting = {}
Fuben:SetFubenSetting(59, tbFubenSetting)
tbFubenSetting.szFubenClass = "PersonalFubenBase"
tbFubenSetting.szName = "测试副本"
tbFubenSetting.szNpcPointFile = "Setting/Fuben/PersonalFuben/7_7/NpcPos.tab"
tbFubenSetting.szPathFile = "Setting/Fuben/PersonalFuben/7_7/NpcPath.tab"
tbFubenSetting.tbBeginPoint = {2217, 6670}
tbFubenSetting.nStartDir = 32
tbFubenSetting.ANIMATION = {
  [1] = "Scenes/camera/canghai04/canghai04_jisha.controller"
}
tbFubenSetting.NPC = {
  [1] = {
    nTemplate = 1713,
    nLevel = -1,
    nSeries = -1
  },
  [2] = {
    nTemplate = 1714,
    nLevel = -1,
    nSeries = -1
  },
  [3] = {
    nTemplate = 1715,
    nLevel = -1,
    nSeries = -1
  },
  [4] = {
    nTemplate = 1716,
    nLevel = -1,
    nSeries = -1
  },
  [6] = {
    nTemplate = 74,
    nLevel = -1,
    nSeries = 0
  },
  [7] = {
    nTemplate = 104,
    nLevel = -1,
    nSeries = 0
  },
  [8] = {
    nTemplate = 747,
    nLevel = -1,
    nSeries = 0
  },
  [9] = {
    nTemplate = 853,
    nLevel = -1,
    nSeries = 0
  },
  [10] = {
    nTemplate = 1690,
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
        1116,
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
        2370,
        6171
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
        7,
        4,
        "gw",
        "guaiwu1",
        false,
        0,
        0,
        9005,
        0.5
      },
      {
        "AddNpc",
        3,
        1,
        4,
        "gw",
        "guaiwu1",
        false,
        0,
        0,
        9005,
        0.5
      },
      {
        "NpcBubbleTalk",
        "gw",
        "想救岳飞，没那么容易！!",
        3,
        1,
        1
      },
      {
        "RaiseEvent",
        "PartnerSay",
        "方勉果然投敌了！",
        3,
        1
      },
      {
        "BlackMsg",
        "击败拦路的敌人！"
      },
      {
        "AddNpc",
        7,
        1,
        0,
        "wall",
        "wall1",
        false,
        40,
        0,
        0,
        0
      }
    },
    tbUnLockEvent = {}
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
        2539,
        4910
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
    nNum = 4,
    tbPrelock = {5},
    tbStartEvent = {
      {
        "AddNpc",
        2,
        4,
        6,
        "gw",
        "guaiwu2",
        false,
        0,
        0,
        9005,
        0.5
      },
      {
        "NpcBubbleTalk",
        "gw",
        "留下狗命!",
        3,
        1,
        1
      },
      {
        "RaiseEvent",
        "PartnerSay",
        "有金兵！",
        3,
        1
      },
      {
        "BlackMsg",
        "击败拦路的金兵！"
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
  [100] = {
    nTime = 0,
    nNum = 1,
    tbPrelock = {6},
    tbStartEvent = {
      {
        "TrapUnlock",
        "trap3",
        100
      },
      {
        "SetTargetPos",
        2908,
        2905
      }
    },
    tbUnLockEvent = {
      {
        "ClearTargetPos"
      }
    }
  },
  [7] = {
    nTime = 0,
    nNum = 12,
    tbPrelock = {100},
    tbStartEvent = {
      {
        "AddNpc",
        2,
        7,
        7,
        "gw",
        "guaiwu3",
        false,
        0,
        0,
        9005,
        0.5
      },
      {
        "AddNpc",
        3,
        1,
        7,
        "gw",
        "guaiwu3",
        false,
        0,
        0,
        9005,
        0.5
      },
      {
        "AddNpc",
        2,
        4,
        7,
        "gw",
        "guaiwu3",
        false,
        0,
        3,
        9005,
        0.5
      },
      {
        "NpcBubbleTalk",
        "gw",
        "杀啊！杀了这些宋人！",
        3,
        1,
        2
      },
      {
        "RaiseEvent",
        "PartnerSay",
        "小心！",
        3,
        1
      },
      {
        "AddNpc",
        7,
        1,
        0,
        "wall",
        "wall2",
        false,
        28,
        0,
        0,
        0
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
  [8] = {
    nTime = 0,
    nNum = 1,
    tbPrelock = {7},
    tbStartEvent = {
      {
        "TrapUnlock",
        "trap4",
        8
      },
      {
        "SetTargetPos",
        5172,
        4944
      }
    },
    tbUnLockEvent = {
      {
        "ClearTargetPos"
      }
    }
  },
  [9] = {
    nTime = 0,
    nNum = 12,
    tbPrelock = {8},
    tbStartEvent = {
      {
        "AddNpc",
        2,
        6,
        9,
        "gw",
        "guaiwu4_1",
        false,
        0,
        0,
        9005,
        0.5
      },
      {
        "AddNpc",
        3,
        2,
        9,
        "gw",
        "guaiwu4_1",
        false,
        0,
        0,
        9005,
        0.5
      },
      {
        "AddNpc",
        1,
        4,
        9,
        "gw",
        "guaiwu4_2",
        false,
        0,
        4,
        9005,
        0.5
      },
      {
        "NpcBubbleTalk",
        "gw",
        "兄弟们一起上！",
        3,
        1,
        2
      }
    },
    tbUnLockEvent = {
      {
        "OpenDynamicObstacle",
        "obs3"
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
        6,
        1,
        0,
        "qg",
        "qinggong",
        false,
        0,
        0,
        0,
        0
      },
      {
        "TrapUnlock",
        "jump1",
        10
      },
      {
        "SetTargetPos",
        5988,
        4357
      },
      {
        "ChangeTrap",
        "jump1",
        nil,
        {5984, 3971}
      },
      {
        "ChangeTrap",
        "jump2",
        nil,
        {6403, 3542}
      },
      {
        "ChangeTrap",
        "jump3",
        nil,
        {6264, 3210}
      }
    },
    tbUnLockEvent = {
      {
        "ClearTargetPos"
      }
    }
  },
  [11] = {
    nTime = 0,
    nNum = 1,
    tbPrelock = {10},
    tbStartEvent = {
      {
        "TrapUnlock",
        "trap5",
        11
      },
      {
        "ChangeTrap",
        "trap5",
        nil,
        nil,
        nil,
        nil,
        nil,
        true
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
        "TrapUnlock",
        "trap6",
        12
      },
      {
        "SetTargetPos",
        6323,
        2494
      }
    },
    tbUnLockEvent = {
      {
        "ClearTargetPos"
      }
    }
  },
  [13] = {
    nTime = 0,
    nNum = 1,
    tbPrelock = {11},
    tbStartEvent = {
      {
        "AddNpc",
        4,
        1,
        13,
        "boss",
        "fangmian",
        false,
        8,
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
        "AddNpc",
        8,
        1,
        0,
        "npc",
        "dugujian",
        false,
        32,
        0,
        0,
        0
      },
      {
        "AddNpc",
        9,
        1,
        0,
        "npc1",
        "zhanglinxin",
        false,
        40,
        0,
        0,
        0
      },
      {
        "SetNpcBloodVisable",
        "boss",
        false,
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
        "boss",
        0
      }
    },
    tbUnLockEvent = {}
  },
  [14] = {
    nTime = 0,
    nNum = 1,
    tbPrelock = {12},
    tbStartEvent = {
      {
        "MoveCameraToPosition",
        14,
        1,
        5986,
        2026,
        2
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
  [15] = {
    nTime = 0,
    nNum = 1,
    tbPrelock = {14},
    tbStartEvent = {
      {
        "RaiseEvent",
        "ShowTaskDialog",
        15,
        1117,
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
      {
        "LeaveAnimationState",
        true
      },
      {
        "BlackMsg",
        "击败方勉！"
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
        "SetAiActive",
        "boss",
        1
      }
    }
  },
  [16] = {
    nTime = 2.1,
    nNum = 0,
    tbPrelock = {13},
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
      },
      {
        "PlayCameraEffect",
        9119
      }
    }
  },
  [17] = {
    nTime = 0,
    nNum = 1,
    tbPrelock = {16},
    tbStartEvent = {
      {
        "RaiseEvent",
        "ShowPlayer",
        false
      },
      {
        "RaiseEvent",
        "ShowPartnerAndHelper",
        false
      },
      {
        "MoveCameraToPosition",
        0,
        1,
        5986,
        2026,
        2
      },
      {
        "AddNpc",
        4,
        1,
        0,
        "boss",
        "fangmian",
        false,
        8,
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
        "DoCommonAct",
        "boss",
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
        "SetNpcBloodVisable",
        "npc1",
        false,
        0
      },
      {
        "ChangeNpcFightState",
        "npc",
        0
      },
      {
        "ChangeNpcFightState",
        "npc1",
        0
      },
      {
        "RaiseEvent",
        "ShowTaskDialog",
        17,
        1118,
        false
      }
    },
    tbUnLockEvent = {
      {
        "LeaveAnimationState",
        true
      }
    }
  },
  [18] = {
    nTime = 0,
    nNum = 1,
    tbPrelock = {17},
    tbStartEvent = {
      {
        "PlayCameraAnimation",
        1,
        18
      },
      {
        "PlayEffect",
        9146,
        0,
        0,
        0,
        1
      },
      {
        "PlayCameraEffect",
        9147
      },
      {"PlaySound", 49},
      {
        "ShowAllRepresentObj",
        false
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
    tbUnLockEvent = {
      {
        "ShowAllRepresentObj",
        true
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
      },
      {
        "LeaveAnimationState",
        true
      }
    }
  },
  [19] = {
    nTime = 8,
    nNum = 0,
    tbPrelock = {18},
    tbStartEvent = {
      {"DelNpc", "npc"},
      {"DelNpc", "npc1"},
      {
        "AddNpc",
        8,
        1,
        0,
        "npc",
        "dugujian1",
        false,
        32,
        0,
        0,
        0
      },
      {
        "AddNpc",
        10,
        1,
        0,
        "npc1",
        "yangying",
        false,
        40,
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
        0,
        1,
        5986,
        2026,
        5
      },
      {
        "DoCommonAct",
        "npc",
        16,
        0,
        1,
        0
      },
      {
        "NpcBubbleTalk",
        "npc",
        "（咬牙）我要杀了你！杀了你……",
        5,
        1,
        1
      },
      {
        "NpcBubbleTalk",
        "npc1",
        "（难过）独孤大哥！他已经死了……",
        3,
        4,
        1
      },
      {
        "NpcBubbleTalk",
        "npc1",
        "他死了……",
        3,
        6,
        1
      }
    },
    tbUnLockEvent = {}
  },
  [20] = {
    nTime = 0,
    nNum = 1,
    tbPrelock = {19},
    tbStartEvent = {
      {
        "MoveCameraToPosition",
        0,
        2,
        5297,
        1861,
        2
      },
      {
        "DoCommonAct",
        "npc",
        16,
        0,
        0,
        0
      },
      {
        "ChangeNpcAi",
        "npc",
        "Move",
        "path1",
        20,
        0,
        0,
        0,
        0
      },
      {
        "NpcBubbleTalk",
        "npc",
        "（流泪）琳...儿...",
        3,
        1,
        1
      }
    },
    tbUnLockEvent = {}
  },
  [21] = {
    nTime = 0,
    nNum = 1,
    tbPrelock = {20},
    tbStartEvent = {
      {
        "ChangeNpcFightState",
        "npc",
        0
      },
      {
        "ChangeNpcFightState",
        "npc1",
        0
      },
      {
        "SetNpcDir",
        "npc",
        48
      },
      {
        "ChangeNpcAi",
        "npc1",
        "Move",
        "path2",
        21,
        0,
        0,
        0,
        0
      },
      {
        "NpcBubbleTalk",
        "npc1",
        "（难过）……",
        3,
        1,
        1
      }
    },
    tbUnLockEvent = {
      {
        "SetNpcDir",
        "npc1",
        48
      }
    }
  },
  [22] = {
    nTime = 1,
    nNum = 0,
    tbPrelock = {21},
    tbStartEvent = {},
    tbUnLockEvent = {}
  },
  [23] = {
    nTime = 0,
    nNum = 1,
    tbPrelock = {22},
    tbStartEvent = {
      {
        "OpenWindow",
        "StoryBlackBg",
        "独孤剑和杨瑛二人面对断崖，一直站着...",
        "",
        1,
        2,
        1
      },
      {
        "RaiseEvent",
        "ShowTaskDialog",
        23,
        1119,
        false,
        6
      }
    },
    tbUnLockEvent = {}
  },
  [24] = {
    nTime = 6,
    nNum = 0,
    tbPrelock = {23},
    tbStartEvent = {
      {
        "OpenWindow",
        "StoryBlackBg",
        "两人默默告别。凤凰顶上，杨瑛黯然注视着那个单薄的背影，寂寞远去……不知是对，是错……",
        "",
        2,
        2,
        1
      }
    },
    tbUnLockEvent = {
      {"GameWin"}
    }
  }
}
