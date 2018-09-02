local tbFubenSetting = {}
Fuben:SetFubenSetting(1, tbFubenSetting)
tbFubenSetting.szFubenClass = "XinShouFuben"
tbFubenSetting.szName = "新手副本"
tbFubenSetting.szNpcPointFile = "Setting/Fuben/XinshouFuben/NpcPos.tab"
tbFubenSetting.szNpcExtAwardPath = "Setting/Fuben/XinshouFuben/ExtNpcAwardInfo.tab"
tbFubenSetting.szPathFile = "Setting/Fuben/XinshouFuben/NpcPath.tab"
tbFubenSetting.tbBeginPoint = {6514, 11207}
tbFubenSetting.nStartDir = 32
tbFubenSetting.NUM = {}
tbFubenSetting.ANIMATION = {
  [1] = "Scenes/camera/xsgk_cam2.controller",
  [2] = "Scenes/camera/xinshouboss.controller",
  [3] = "Scenes/camera/shanchujingtou.controller",
  [4] = "Scenes/camera/xsg_eyecam.controller",
  [5] = "Scenes/camera/QingGong.controller"
}
tbFubenSetting.NPC = {
  [1] = {
    nTemplate = 1150,
    nLevel = 70,
    nSeries = 0
  },
  [2] = {
    nTemplate = 451,
    nLevel = 70,
    nSeries = 0
  },
  [3] = {
    nTemplate = 452,
    nLevel = 70,
    nSeries = 0
  },
  [4] = {
    nTemplate = 1151,
    nLevel = 70,
    nSeries = 0
  },
  [5] = {
    nTemplate = 1158,
    nLevel = 70,
    nSeries = 0
  },
  [6] = {
    nTemplate = 1152,
    nLevel = 70,
    nSeries = 0
  },
  [7] = {
    nTemplate = 1153,
    nLevel = 70,
    nSeries = 0
  },
  [8] = {
    nTemplate = 1154,
    nLevel = 70,
    nSeries = 0
  },
  [9] = {
    nTemplate = 1155,
    nLevel = 5,
    nSeries = 0
  },
  [10] = {
    nTemplate = 452,
    nLevel = 1,
    nSeries = 0
  },
  [11] = {
    nTemplate = 74,
    nLevel = 1,
    nSeries = 0
  },
  [12] = {
    nTemplate = 104,
    nLevel = 1,
    nSeries = 0
  },
  [13] = {
    nTemplate = 518,
    nLevel = 5,
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
        "PreLoadWindow",
        "CreateNameInput"
      },
      {
        "SetDialogueSoundScale",
        250
      },
      {
        "AddNpc",
        1,
        1,
        0,
        "npc",
        "shibing",
        false,
        0,
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
        "MoveCamera",
        1,
        1.5,
        87.12,
        77.83,
        205.9,
        0,
        0,
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
        "RaiseEvent",
        "Tlog",
        2
      }
    },
    tbUnLockEvent = {}
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
        1087,
        false
      },
      {
        "NpcBubbleTalk",
        "npc",
        "快救大将军...咳咳",
        3,
        0,
        1
      },
      {
        "SetForbiddenOperation",
        false
      }
    },
    tbUnLockEvent = {
      {
        "NpcBubbleTalk",
        "npc",
        "大侠，你终于来了...",
        4,
        0,
        1
      }
    }
  },
  [3] = {
    nTime = 0,
    nNum = 1,
    tbPrelock = {2},
    tbStartEvent = {
      {
        "MoveCamera",
        3,
        1,
        82.4,
        77.52,
        210.55,
        0,
        0,
        0
      }
    },
    tbUnLockEvent = {
      {
        "SetAllUiVisiable",
        true
      },
      {
        "LeaveAnimationState",
        true
      }
    }
  },
  [4] = {
    nTime = 0,
    nNum = 1,
    tbPrelock = {3},
    tbStartEvent = {
      {
        "ChangeFightState",
        1
      },
      {
        "BlackMsg",
        "看来我得赶紧前去看看了！"
      },
      {
        "OpenWindow",
        "RockerGuideNpcPanel",
        "按住[FFFE0D]左边的摇杆[-]不松，然后滑动手指\n移动到[FFFE0D]光圈[-]内！"
      },
      {
        "SetForbiddenOperation",
        true,
        true
      },
      {
        "SetGuidingJoyStick",
        true
      },
      {
        "TrapUnlock",
        "zhiyin1",
        4
      },
      {
        "AddNpc",
        10,
        1,
        0,
        "zy",
        "zhiyin1",
        false,
        0,
        0,
        0,
        0
      }
    },
    tbUnLockEvent = {
      {
        "CloseWindow",
        "RockerGuideNpcPanel"
      },
      {
        "SetForbiddenOperation",
        false,
        true
      },
      {
        "SetGuidingJoyStick",
        false
      },
      {"DelNpc", "zy"},
      {
        "OpenWindow",
        "QYHLeavePanel",
        "XinShouFuben",
        {BtnChallenge = true}
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
        "zhiyin2",
        5
      },
      {
        "AddNpc",
        10,
        1,
        0,
        "zy",
        "zhiyin2",
        false,
        0,
        0,
        0,
        0
      }
    },
    tbUnLockEvent = {
      {"DelNpc", "zy"}
    }
  },
  [6] = {
    nTime = 0,
    nNum = 1,
    tbPrelock = {5},
    tbStartEvent = {
      {
        "TrapUnlock",
        "action1",
        6
      },
      {
        "AddNpc",
        10,
        1,
        0,
        "zy",
        "action1",
        false,
        0,
        0,
        0,
        0
      }
    },
    tbUnLockEvent = {
      {"DelNpc", "zy"},
      {"DelNpc", "npc"}
    }
  },
  [7] = {
    nTime = 0,
    nNum = 1,
    tbPrelock = {6},
    tbStartEvent = {
      {
        "SetForbiddenOperation",
        true
      },
      {
        "SetAllUiVisiable",
        false
      },
      {"PlaySound", 4},
      {
        "PlayCameraAnimation",
        1,
        7
      },
      {
        "PlayEffect",
        9101,
        0,
        0,
        0,
        true
      },
      {
        "PlayEffect",
        9102,
        0,
        0,
        0,
        true
      },
      {
        "PlayCameraEffect",
        9103
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
      }
    }
  },
  [8] = {
    nTime = 0,
    nNum = 10,
    tbPrelock = {7},
    tbStartEvent = {
      {
        "BlackMsg",
        "击败登上城墙的金兵！"
      },
      {
        "AddNpc",
        12,
        2,
        0,
        "men",
        "men",
        false,
        16,
        0,
        0,
        0
      },
      {
        "AddNpc",
        4,
        5,
        8,
        "guaiwu",
        "jinbing1_1",
        false,
        0,
        0,
        0,
        0
      },
      {
        "AddNpc",
        5,
        1,
        8,
        "guaiwu1",
        "jinbing1_2",
        false,
        0,
        0,
        0,
        0
      },
      {
        "NpcBubbleTalk",
        "guaiwu1",
        "宋人真是不堪一击！",
        4,
        1,
        1
      },
      {
        "AddNpc",
        6,
        2,
        8,
        "guaiwu",
        "sishi1_1",
        false,
        16,
        2,
        0,
        0
      },
      {
        "AddNpc",
        6,
        2,
        8,
        "guaiwu2",
        "sishi1_2",
        false,
        48,
        2,
        0,
        0
      },
      {
        "NpcBubbleTalk",
        "guaiwu2",
        "嘿嘿，我们也来凑热闹！",
        4,
        2.5,
        1
      },
      {
        "NpcBubbleTalk",
        "guaiwu1",
        "哈哈，一起上，废掉这个武士。",
        4,
        3.5,
        1
      },
      {
        "RaiseEvent",
        "Tlog",
        3
      }
    },
    tbUnLockEvent = {
      {
        "OpenDynamicObstacle",
        "obs"
      },
      {"DoDeath", "men"}
    }
  },
  [9] = {
    nTime = 0,
    nNum = 1,
    tbPrelock = {7},
    tbStartEvent = {
      {
        "OpenGuide",
        9,
        "PopT",
        "请点击使用武功",
        "HomeScreenBattle",
        "Skill2",
        {0, -40},
        false,
        true,
        true
      }
    },
    tbUnLockEvent = {
      {
        "CloseWindow",
        "Guide"
      }
    }
  },
  [13] = {
    nTime = 0,
    nNum = 1,
    tbPrelock = {8},
    tbStartEvent = {
      {
        "BlackMsg",
        "继续前进！"
      },
      {
        "TrapUnlock",
        "zhiyin4",
        13
      },
      {
        "AddNpc",
        10,
        1,
        0,
        "zy",
        "zhiyin4",
        false,
        0,
        0,
        0,
        0
      },
      {
        "CloseWindow",
        "Guide"
      }
    },
    tbUnLockEvent = {
      {"DelNpc", "zy"}
    }
  },
  [14] = {
    nTime = 0,
    nNum = 1,
    tbPrelock = {13},
    tbStartEvent = {
      {
        "TrapUnlock",
        "action2",
        14
      },
      {
        "AddNpc",
        10,
        1,
        0,
        "zy",
        "action2",
        false,
        0,
        0,
        0,
        0
      }
    },
    tbUnLockEvent = {
      {"DelNpc", "zy"}
    }
  },
  [15] = {
    nTime = 0,
    nNum = 1,
    tbPrelock = {14},
    tbStartEvent = {
      {
        "MoveCamera",
        15,
        1.5,
        74.28,
        82.7,
        157.68,
        0,
        0,
        0
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
  [16] = {
    nTime = 0,
    nNum = 13,
    tbPrelock = {14},
    tbStartEvent = {
      {
        "AddNpc",
        4,
        6,
        16,
        "guaiwu",
        "jinbing2_1",
        false,
        0,
        0,
        0,
        0
      },
      {
        "AddNpc",
        5,
        1,
        16,
        "guaiwu1",
        "jinbing2_2",
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
        "npc1",
        "jiangjun",
        false,
        0,
        0,
        0,
        0
      },
      {
        "AddNpc",
        8,
        1,
        0,
        "npc2",
        "zhuofeifan",
        false,
        0,
        0,
        0,
        0
      },
      {
        "AddNpc",
        6,
        2,
        16,
        "guaiwu",
        "sishi2_1",
        false,
        16,
        6,
        0,
        0
      },
      {
        "AddNpc",
        6,
        2,
        16,
        "guaiwu",
        "sishi2_2",
        false,
        48,
        6,
        0,
        0
      },
      {
        "AddNpc",
        6,
        2,
        16,
        "guaiwu2",
        "sishi2_3",
        false,
        0,
        6,
        0,
        0
      },
      {
        "NpcBubbleTalk",
        "npc1",
        "大侠终于来了，快来助我一臂之力！",
        3,
        1.5,
        1
      },
      {
        "NpcBubbleTalk",
        "guaiwu1",
        "又来一个陪葬的！",
        3,
        2.5,
        1
      },
      {
        "NpcBubbleTalk",
        "guaiwu2",
        "嘿嘿，我们也来凑热闹！",
        3,
        6.5,
        1
      },
      {
        "NpcBubbleTalk",
        "npc1",
        "哼，他们终于也出手了！",
        3,
        8,
        1
      },
      {
        "NpcBubbleTalk",
        "npc2",
        "无耻鼠辈，与金人勾结，暗中埋伏。",
        3,
        9.5,
        1
      },
      {
        "RaiseEvent",
        "Tlog",
        4
      }
    },
    tbUnLockEvent = {
      {
        "DoCommonAct",
        "npc1",
        1,
        0,
        1,
        0
      }
    }
  },
  [17] = {
    nTime = 2,
    nNum = 0,
    tbPrelock = {15},
    tbStartEvent = {},
    tbUnLockEvent = {
      {
        "LeaveAnimationState",
        true
      },
      {
        "SetForbiddenOperation",
        false
      },
      {
        "SetAllUiVisiable",
        true
      }
    }
  },
  [20] = {
    nTime = 0,
    nNum = 1,
    tbPrelock = {16},
    tbStartEvent = {
      {
        "RaiseEvent",
        "ShowTaskDialog",
        20,
        1086,
        false,
        1
      },
      {
        "SetNpcDir",
        "npc1",
        60
      },
      {
        "SetNpcDir",
        "npc2",
        52
      }
    },
    tbUnLockEvent = {
      {
        "AddNpc",
        11,
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
        "ChangeNpcAi",
        "npc2",
        "Move",
        "path1",
        0,
        1,
        1,
        1,
        0
      },
      {
        "NpcBubbleTalk",
        "npc2",
        "大侠，跟我来，这边可以登上山崖。",
        3,
        0,
        1
      },
      {
        "SetTargetPos",
        6162,
        4693
      }
    }
  },
  [18] = {
    nTime = 0,
    nNum = 1,
    tbPrelock = {20},
    tbStartEvent = {
      {
        "TrapUnlock",
        "jump1",
        18
      }
    },
    tbUnLockEvent = {
      {
        "ClearTargetPos"
      },
      {
        "AddNpc",
        8,
        1,
        0,
        "npc",
        "zhuofeifan1",
        false,
        32,
        6,
        0,
        0
      },
      {"DelNpc", "qg"},
      {"DelNpc", "npc1"}
    }
  },
  [21] = {
    nTime = 0,
    nNum = 1,
    tbPrelock = {18},
    tbStartEvent = {
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
      },
      {
        "PlayCameraAnimation",
        5,
        21
      },
      {"PlaySound", 5},
      {
        "PlayCameraEffect",
        9111
      },
      {
        "PlayEffect",
        9113,
        0,
        0,
        0,
        1
      },
      {
        "PlayFactionEffect",
        {
          9116,
          9112,
          9114,
          9115,
          9118,
          9117,
          9157,
          9152,
          9163,
          9162,
          9166,
          9167,
          9175,
          9174
        }
      }
    },
    tbUnLockEvent = {
      {
        "SetPos",
        7555,
        3476
      },
      {
        "ShowAllRepresentObj",
        true
      }
    }
  },
  [22] = {
    nTime = 0.1,
    nNum = 0,
    tbPrelock = {21},
    tbStartEvent = {},
    tbUnLockEvent = {
      {
        "SetPlayerDir",
        32
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
      }
    }
  },
  [23] = {
    nTime = 0,
    nNum = 1,
    tbPrelock = {21},
    tbStartEvent = {
      {
        "TrapUnlock",
        "action3",
        23
      },
      {
        "AddNpc",
        10,
        1,
        0,
        "zy",
        "action3",
        false,
        0,
        0,
        0,
        0
      }
    },
    tbUnLockEvent = {
      {"DelNpc", "zy"}
    }
  },
  [26] = {
    nTime = 4.6,
    nNum = 0,
    tbPrelock = {6},
    tbStartEvent = {},
    tbUnLockEvent = {
      {
        "SetGameWorldScale",
        0.2
      }
    }
  },
  [27] = {
    nTime = 0.8,
    nNum = 0,
    tbPrelock = {26},
    tbStartEvent = {},
    tbUnLockEvent = {
      {
        "SetGameWorldScale",
        1.6
      }
    }
  },
  [28] = {
    nTime = 0.9,
    nNum = 0,
    tbPrelock = {27},
    tbStartEvent = {},
    tbUnLockEvent = {
      {
        "SetGameWorldScale",
        1
      }
    }
  },
  [29] = {
    nTime = 0,
    nNum = 1,
    tbPrelock = {23},
    tbStartEvent = {
      {
        "PlayCameraAnimation",
        2,
        29
      },
      {"PlaySound", 2},
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
        13,
        1,
        0,
        "simpleboss",
        "boss",
        false,
        0,
        0,
        0,
        0
      },
      {
        "PlayEffect",
        9038,
        0,
        0,
        0,
        1
      },
      {
        "PlayEffect",
        9121,
        0,
        0,
        0,
        1
      },
      {
        "RaiseEvent",
        "Tlog",
        5
      }
    },
    tbUnLockEvent = {
      {
        "SetForbiddenOperation",
        false
      },
      {
        "LeaveAnimationState",
        true
      }
    }
  },
  [30] = {
    nTime = 8.8,
    nNum = 0,
    tbPrelock = {23},
    tbStartEvent = {},
    tbUnLockEvent = {}
  },
  [31] = {
    nTime = 0,
    nNum = 1,
    tbPrelock = {30},
    tbStartEvent = {
      {
        "RaiseEvent",
        "ShowTaskDialog",
        31,
        1085,
        false,
        1
      }
    },
    tbUnLockEvent = {
      {"DelNpc", "simpleboss"},
      {
        "SetAllUiVisiable",
        true
      }
    }
  },
  [32] = {
    nTime = 0,
    nNum = 1,
    tbPrelock = {31},
    tbStartEvent = {
      {
        "AddNpc",
        9,
        1,
        0,
        "BOSS",
        "boss",
        false,
        0,
        0,
        0,
        0
      },
      {
        "NpcBubbleTalk",
        "BOSS",
        "就让我来送你们上路吧！",
        4,
        2,
        1
      },
      {
        "NpcBubbleTalk",
        "npc",
        "大言不惭！",
        4,
        3,
        1
      },
      {
        "NpcHpUnlock",
        "BOSS",
        32,
        45
      }
    },
    tbUnLockEvent = {
      {
        "NpcBubbleTalk",
        "npc",
        "谁？！",
        3,
        0.5,
        1
      },
      {
        "SetAiActive",
        "BOSS",
        0
      },
      {"DelNpc", "npc"},
      {
        "AddNpc",
        8,
        1,
        0,
        "npc",
        "boss",
        false,
        2,
        0,
        0,
        0
      },
      {
        "SetAiActive",
        "npc",
        0
      },
      {
        "NpcBubbleTalk",
        "npc",
        "谁？！",
        4,
        0.5,
        1
      },
      {
        "DoCommonAct",
        nil,
        7
      },
      {"PlaySound", 3},
      {
        "PlayEffect",
        9027,
        0,
        0,
        0,
        1
      },
      {
        "PlayFactionEffect",
        {
          9037,
          9041,
          9042,
          9043,
          9106,
          9107,
          9156,
          9153,
          9161,
          9160,
          9169,
          9168,
          9176,
          9177
        }
      },
      {
        "PlayCameraAnimation",
        3,
        39
      },
      {
        "SetForbiddenOperation",
        true
      },
      {
        "PlayCameraEffect",
        9028
      },
      {
        "SetAllUiVisiable",
        false
      }
    }
  },
  [33] = {
    nTime = 2.4,
    nNum = 0,
    tbPrelock = {32},
    tbStartEvent = {},
    tbUnLockEvent = {
      {
        "CastSkill",
        "npc",
        2151,
        1,
        7555,
        3476
      }
    }
  },
  [34] = {
    nTime = 5.3,
    nNum = 0,
    tbPrelock = {32},
    tbStartEvent = {},
    tbUnLockEvent = {
      {
        "ShowAllRepresentObj",
        false
      }
    }
  },
  [35] = {
    nTime = 6.9,
    nNum = 0,
    tbPrelock = {32},
    tbStartEvent = {},
    tbUnLockEvent = {
      {
        "PlaySceneAnimation",
        "fb_xueshan_niutai",
        "wind",
        1,
        false
      },
      {
        "ShowAllRepresentObj",
        false
      },
      {
        "SetGameWorldScale",
        0.08
      }
    }
  },
  [36] = {
    nTime = 8.6,
    nNum = 0,
    tbPrelock = {32},
    tbStartEvent = {},
    tbUnLockEvent = {
      {
        "SetGameWorldScale",
        0.7
      }
    }
  },
  [37] = {
    nTime = 12.8,
    nNum = 0,
    tbPrelock = {32},
    tbStartEvent = {},
    tbUnLockEvent = {
      {
        "RaiseEvent",
        "Log",
        "SetGameWorldScale Start!!!!"
      },
      {
        "SetGameWorldScale",
        0.3
      }
    }
  },
  [38] = {
    nTime = 2,
    nNum = 0,
    tbPrelock = {36},
    tbStartEvent = {},
    tbUnLockEvent = {
      {
        "SetGameWorldScale",
        0.55
      }
    }
  },
  [39] = {
    nTime = 0,
    nNum = 1,
    tbPrelock = {37},
    tbStartEvent = {},
    tbUnLockEvent = {
      {
        "SetGameWorldScale",
        1
      },
      {
        "RaiseEvent",
        "OpenBgBlackAll"
      }
    }
  },
  [40] = {
    nTime = 0.2,
    nNum = 0,
    tbPrelock = {39},
    tbStartEvent = {},
    tbUnLockEvent = {}
  },
  [41] = {
    nTime = 0,
    nNum = 1,
    tbPrelock = {40},
    tbStartEvent = {
      {
        "SetForbiddenOperation",
        false
      },
      {
        "RaiseEvent",
        "ShowTaskDialog",
        41,
        1081,
        false
      },
      {
        "PreLoadWindow",
        "CreateNameInput"
      }
    },
    tbUnLockEvent = {}
  },
  [42] = {
    nTime = 5.1,
    nNum = 0,
    tbPrelock = {41},
    tbStartEvent = {
      {
        "SetForbiddenOperation",
        true
      },
      {
        "PlayCameraAnimation",
        4,
        0
      },
      {
        "PlayCameraEffect",
        9104
      },
      {
        "PlayEffect",
        9105,
        0,
        0,
        0,
        true
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
      }
    }
  },
  [43] = {
    nTime = 0,
    nNum = 1,
    tbPrelock = {42},
    tbStartEvent = {
      {
        "CloseWindow",
        "QYHLeavePanel"
      },
      {
        "RaiseEvent",
        "OpenBgBlackAll"
      },
      {
        "RaiseEvent",
        "ShowTaskDialog",
        43,
        1082,
        false
      }
    },
    tbUnLockEvent = {
      {
        "RaiseEvent",
        "ShowTaskDialog",
        0,
        1083,
        false
      },
      {
        "RaiseEvent",
        "OpenCreatNamePanel"
      },
      {
        "RaiseEvent",
        "Tlog",
        6
      }
    }
  },
  [44] = {
    nTime = 0,
    nNum = 1,
    tbPrelock = {43},
    tbStartEvent = {},
    tbUnLockEvent = {}
  },
  [45] = {
    nTime = 0,
    nNum = 1,
    tbPrelock = {44},
    tbStartEvent = {
      {
        "RaiseEvent",
        "ShowTaskDialog",
        45,
        1084,
        false
      }
    },
    tbUnLockEvent = {
      {
        "RaiseEvent",
        "PostXinshouData",
        8
      },
      {"GameWin"}
    }
  },
  [46] = {
    nTime = 3000,
    nNum = 0,
    tbPrelock = {1},
    tbStartEvent = {},
    tbUnLockEvent = {
      {"GameLost"}
    }
  },
  [47] = {
    nTime = 0.1,
    nNum = 0,
    tbPrelock = {41},
    tbStartEvent = {},
    tbUnLockEvent = {
      {
        "CloseWindow",
        "BgBlackAll"
      }
    }
  },
  [48] = {
    nTime = 1,
    nNum = 0,
    tbPrelock = {33},
    tbStartEvent = {},
    tbUnLockEvent = {
      {"DelNpc", "npc"}
    }
  },
  [100] = {
    nTime = 2.8,
    nNum = 0,
    tbPrelock = {23},
    tbStartEvent = {},
    tbUnLockEvent = {}
  },
  [101] = {
    nTime = 3,
    nNum = 0,
    tbPrelock = {100},
    tbStartEvent = {
      {
        "OpenWindow",
        "BossReferral",
        "神",
        "秘人",
        "身份未知"
      }
    },
    tbUnLockEvent = {
      {
        "CloseWindow",
        "BossReferral"
      }
    }
  }
}
