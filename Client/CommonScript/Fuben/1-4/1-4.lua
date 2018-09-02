local tbFubenSetting = {}
Fuben:SetFubenSetting(23, tbFubenSetting)
tbFubenSetting.szFubenClass = "PersonalFubenBase"
tbFubenSetting.szName = "测试副本"
tbFubenSetting.szNpcPointFile = "Setting/Fuben/PersonalFuben/1_4/NpcPos.tab"
tbFubenSetting.szPathFile = "Setting/Fuben/PersonalFuben/1_4/NpcPath.tab"
tbFubenSetting.tbBeginPoint = {2267, 2786}
tbFubenSetting.nStartDir = 56
tbFubenSetting.ANIMATION = {
  [1] = "Scenes/Maps/yw_luoyegu/Main Camera.controller",
  [2] = "Scenes/camera/bosscamer110.controller"
}
tbFubenSetting.NPC = {
  [1] = {
    nTemplate = 768,
    nLevel = 9,
    nSeries = -1
  },
  [2] = {
    nTemplate = 767,
    nLevel = 9,
    nSeries = -1
  },
  [3] = {
    nTemplate = 738,
    nLevel = 9,
    nSeries = -1
  },
  [4] = {
    nTemplate = 740,
    nLevel = 9,
    nSeries = -1
  },
  [5] = {
    nTemplate = 5,
    nLevel = 10,
    nSeries = -1
  },
  [6] = {
    nTemplate = 764,
    nLevel = -1,
    nSeries = 0
  },
  [7] = {
    nTemplate = 682,
    nLevel = -1,
    nSeries = 0
  },
  [8] = {
    nTemplate = 104,
    nLevel = -1,
    nSeries = 0
  },
  [9] = {
    nTemplate = 680,
    nLevel = -1,
    nSeries = 0
  },
  [16] = {
    nTemplate = 742,
    nLevel = 10,
    nSeries = 0
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
        "ShowTaskDialog",
        1,
        1009,
        false
      },
      {
        "AddNpc",
        9,
        1,
        0,
        "Start_Npc1",
        "Start_Npc1",
        1,
        58,
        0,
        0,
        0
      },
      {
        "AddNpc",
        7,
        1,
        0,
        "Start_Npc2",
        "Start_Npc2",
        1,
        58,
        0,
        0,
        0
      }
    },
    tbUnLockEvent = {
      {
        "AddNpc",
        8,
        1,
        1,
        "wall",
        "wall_1_1",
        false,
        16
      },
      {
        "AddNpc",
        8,
        1,
        1,
        "wall",
        "wall_1_2",
        false,
        32
      },
      {
        "SetShowTime",
        19
      }
    }
  },
  [2] = {
    nTime = 0,
    nNum = 1,
    tbPrelock = {100},
    tbStartEvent = {
      {
        "ChangeFightState",
        1
      },
      {
        "SetTargetPos",
        1900,
        3833
      },
      {
        "TrapUnlock",
        "TrapLock1",
        2
      }
    },
    tbUnLockEvent = {
      {
        "ClearTargetPos"
      },
      {
        "RaiseEvent",
        "CallPartner"
      },
      {
        "AddNpc",
        2,
        2,
        3,
        "guaiwu1",
        "Stage_1_1",
        1,
        32,
        0,
        9005,
        0.2
      },
      {
        "AddNpc",
        1,
        1,
        3,
        "guaiwu",
        "Stage_1_2",
        1,
        32,
        1.5,
        0,
        0
      },
      {
        "AddNpc",
        2,
        3,
        3,
        "guaiwu",
        "Stage_1_3",
        1,
        32,
        2.5,
        0,
        0
      },
      {
        "BlackMsg",
        "去山洞深处会合！"
      }
    }
  },
  [3] = {
    nTime = 0,
    nNum = 6,
    tbPrelock = {2},
    tbStartEvent = {},
    tbUnLockEvent = {
      {
        "SetTargetPos",
        1697,
        5656
      }
    }
  },
  [4] = {
    nTime = 0,
    nNum = 0,
    tbPrelock = {3},
    tbStartEvent = {},
    tbUnLockEvent = {
      {"AddAnger", 150},
      {
        "OpenDynamicObstacle",
        "ops1"
      },
      {"DoDeath", "wall"},
      {
        "AddNpc",
        8,
        1,
        4,
        "wall",
        "wall_1_2",
        false,
        32
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
    nNum = 9,
    tbPrelock = {5},
    tbStartEvent = {
      {
        "AddNpc",
        3,
        4,
        6,
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
        4,
        1,
        6,
        "guaiwu",
        "Stage_2_2",
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
        "Stage_2_3",
        1,
        0,
        2,
        9009,
        0.5
      },
      {
        "AddNpc",
        2,
        2,
        6,
        "guaiwu",
        "Stage_2_4",
        1,
        0,
        2,
        9009,
        0.5
      }
    },
    tbUnLockEvent = {
      {"AddAnger", 150},
      {
        "SetTargetPos",
        4193,
        5476
      },
      {
        "TrapCastSkill",
        "BuffPoint",
        1508,
        1,
        -1,
        -1,
        1,
        206,
        3156,
        5492
      },
      {"DoDeath", "wall"},
      {
        "OpenDynamicObstacle",
        "ops2"
      },
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
      }
    },
    tbUnLockEvent = {
      {
        "BatchPlaySceneAnimation",
        "wyqf0",
        1,
        9,
        "Take 001",
        0.8,
        true
      },
      {
        "BatchPlaySceneAnimation",
        "wyqf",
        10,
        11,
        "Take 001",
        0.8,
        true
      }
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
        "AddNpc",
        8,
        2,
        9,
        "wall",
        "wall_1_4",
        false,
        48
      }
    }
  },
  [9] = {
    nTime = 0,
    nNum = 9,
    tbPrelock = {8},
    tbStartEvent = {
      {"AddAnger", 150},
      {
        "AddNpc",
        3,
        6,
        9,
        "guaiwu",
        "Stage_3_1",
        1,
        0,
        0.5,
        9009,
        0.5
      },
      {
        "AddNpc",
        2,
        1,
        9,
        "guaiwu",
        "Stage_3_2",
        1,
        8,
        1.5,
        0,
        0
      },
      {
        "AddNpc",
        4,
        1,
        9,
        "guaiwu",
        "Stage_3_3",
        1,
        39,
        2.5,
        0,
        0
      },
      {
        "AddNpc",
        1,
        1,
        9,
        "guaiwu",
        "Stage_3_4",
        1,
        29,
        3.5,
        0,
        0
      }
    },
    tbUnLockEvent = {}
  },
  [10] = {
    nTime = 0,
    nNum = 8,
    tbPrelock = {9},
    tbStartEvent = {
      {"AddAnger", 250},
      {
        "AddNpc",
        2,
        3,
        10,
        "guaiwu",
        "Stage_4_1",
        1,
        0,
        0,
        9009,
        0
      },
      {
        "AddNpc",
        4,
        1,
        10,
        "guaiwu",
        "Stage_4_2",
        1,
        0,
        0,
        9009,
        0
      },
      {
        "AddNpc",
        3,
        2,
        10,
        "guaiwu",
        "Stage_4_3",
        1,
        0,
        0,
        9009,
        0
      },
      {
        "AddNpc",
        1,
        2,
        10,
        "guaiwu",
        "Stage_4_4",
        1,
        0,
        0,
        9009,
        0
      },
      {
        "NpcAddBuff",
        "guaiwu",
        2401,
        1,
        100
      }
    },
    tbUnLockEvent = {
      {
        "OpenDynamicObstacle",
        "ops4"
      },
      {
        "SetTargetPos",
        5151,
        3072
      },
      {"DoDeath", "wall"}
    }
  },
  [11] = {
    nTime = 0,
    nNum = 1,
    tbPrelock = {10},
    tbStartEvent = {
      {
        "TrapUnlock",
        "TrapLock6",
        11
      }
    },
    tbUnLockEvent = {
      {
        "PlayEffect",
        2801,
        0,
        0,
        0
      }
    }
  },
  [12] = {
    nTime = 0,
    nNum = 1,
    tbPrelock = {11},
    tbStartEvent = {
      {
        "TrapUnlock",
        "TrapLock5",
        12
      }
    },
    tbUnLockEvent = {
      {
        "ClearTargetPos"
      }
    }
  },
  [13] = {
    nTime = 3,
    nNum = 0,
    tbPrelock = {36},
    tbStartEvent = {
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
        2,
        0
      },
      {
        "AddNpc",
        5,
        1,
        16,
        "BOSS",
        "Stage_5_BOSS",
        false,
        42
      },
      {
        "ChangeNpcCamp",
        "BOSS",
        0
      },
      {
        "SetHeadVisiable",
        "BOSS",
        false
      }
    },
    tbUnLockEvent = {
      {
        "PlaySceneAnimation",
        "fb_erengu_men01_open",
        "open",
        1,
        false
      }
    }
  },
  [14] = {
    nTime = 0.5,
    nNum = 0,
    tbPrelock = {13},
    tbStartEvent = {},
    tbUnLockEvent = {
      {
        "OpenDynamicObstacle",
        "ops5"
      }
    }
  },
  [15] = {
    nTime = 3,
    nNum = 0,
    tbPrelock = {102},
    tbStartEvent = {
      {
        "OpenWindowAutoClose",
        "BossReferral",
        "烈",
        "焰骷髅",
        "离忧山洞霸主"
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
      },
      {
        "RaiseEvent",
        "CloseDynamicObstacle",
        "ops5"
      },
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
      },
      {
        "ChangeNpcCamp",
        "BOSS",
        1
      },
      {
        "SetHeadVisiable",
        "BOSS",
        true
      },
      {
        "SetNpcBloodVisable",
        "Start_Npc1",
        true,
        0
      },
      {
        "SetNpcBloodVisable",
        "Start_Npc2",
        true,
        0
      },
      {
        "RaiseEvent",
        "ShowPartnerAndHelper",
        true
      },
      {
        "NpcBubbleTalk",
        "BOSS",
        "这里就是你的葬身之地！",
        3,
        0.5,
        1
      },
      {
        "NpcBubbleTalk",
        "Start_Npc1",
        "杨大哥，这个家伙...长得好丑啊！",
        3,
        2.5,
        1
      },
      {
        "NpcBubbleTalk",
        "Start_Npc2",
        "没事，外强中干而已！",
        3,
        3.5,
        1
      }
    }
  },
  [16] = {
    nTime = 0,
    nNum = 1,
    tbPrelock = {15},
    tbStartEvent = {
      {
        "AddNpc",
        2,
        4,
        0,
        "guaiwu",
        "Stage_5_1",
        1,
        0,
        0.5,
        9009,
        0.5
      },
      {
        "AddNpc",
        3,
        4,
        0,
        "guaiwu",
        "Stage_5_2",
        1,
        0,
        0.5,
        9009,
        0.5
      },
      {
        "AddNpc",
        1,
        2,
        0,
        "guaiwu",
        "Stage_5_2",
        1,
        0,
        1,
        9009,
        0.5
      },
      {
        "StartTimeCycle",
        "cycle",
        8,
        5,
        {
          "AddNpc",
          1,
          2,
          0,
          "guaiwu",
          "Stage_5_1",
          false,
          0,
          0.5,
          9009,
          0.5
        }
      },
      {
        "StartTimeCycle",
        "cycle1",
        8,
        5,
        {
          "AddNpc",
          2,
          4,
          0,
          "guaiwu",
          "Stage_5_1",
          false,
          0,
          0.5,
          9009,
          0.5
        }
      },
      {
        "StartTimeCycle",
        "cycle2",
        8,
        5,
        {
          "AddNpc",
          3,
          4,
          0,
          "guaiwu",
          "Stage_5_2",
          false,
          0,
          0.5,
          9009,
          0.5
        }
      }
    },
    tbUnLockEvent = {
      {"PauseLock", 19},
      {
        "StopEndTime"
      },
      {
        "CastSkill",
        "guaiwu",
        3,
        1,
        -1,
        -1
      },
      {"CloseCycle", "cycle"},
      {"CloseCycle", "cycle1"},
      {"CloseCycle", "cycle2"}
    }
  },
  [17] = {
    nTime = 2.1,
    nNum = 0,
    tbPrelock = {16},
    tbStartEvent = {
      {
        "SetGameWorldScale",
        0.3
      }
    },
    tbUnLockEvent = {
      {
        "SetGameWorldScale",
        1
      },
      {
        "CastSkill",
        "guaiwu",
        3,
        1,
        -1,
        -1
      },
      {"ResumeLock", 19},
      {
        "SetShowTime",
        19
      }
    }
  },
  [18] = {
    nTime = 0,
    nNum = 2,
    tbPrelock = {17},
    tbStartEvent = {
      {
        "MoveCameraToPosition",
        18,
        2,
        5931,
        2653,
        10
      },
      {
        "SetNpcBloodVisable",
        "Start_Npc1",
        false,
        0
      },
      {
        "SetNpcBloodVisable",
        "Start_Npc2",
        false,
        0
      },
      {
        "RaiseEvent",
        "ShowPartnerAndHelper",
        false
      },
      {
        "ChangeNpcAi",
        "Start_Npc1",
        "Move",
        "npath1",
        18,
        1,
        1,
        0,
        0
      },
      {
        "ChangeNpcAi",
        "Start_Npc2",
        "Move",
        "npath2",
        0,
        1,
        1,
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
      }
    },
    tbUnLockEvent = {}
  },
  [19] = {
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
  [20] = {
    nTime = 1,
    nNum = 0,
    tbPrelock = {18},
    tbStartEvent = {
      {
        "NpcBubbleTalk",
        "Start_Npc1",
        "这里什么都没有的样子，好无聊！",
        3,
        0,
        1
      },
      {
        "NpcBubbleTalk",
        "Start_Npc2",
        "真儿，你在找什么呀？",
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
        "ChangeNpcAi",
        "Start_Npc1",
        "Move",
        "npath3",
        21,
        1,
        1,
        0,
        0
      }
    },
    tbUnLockEvent = {}
  },
  [22] = {
    nTime = 1,
    nNum = 0,
    tbPrelock = {21},
    tbStartEvent = {
      {
        "NpcBubbleTalk",
        "Start_Npc1",
        "这也空无一物！",
        3,
        0,
        1
      },
      {
        "NpcBubbleTalk",
        "Start_Npc2",
        "......",
        3,
        1,
        1
      }
    },
    tbUnLockEvent = {}
  },
  [23] = {
    nTime = 0,
    nNum = 1,
    tbPrelock = {22},
    tbStartEvent = {
      {
        "ChangeNpcAi",
        "Start_Npc1",
        "Move",
        "npath4",
        23,
        1,
        1,
        0,
        0
      }
    },
    tbUnLockEvent = {}
  },
  [24] = {
    nTime = 2,
    nNum = 0,
    tbPrelock = {23},
    tbStartEvent = {
      {
        "NpcBubbleTalk",
        "Start_Npc1",
        "咦？这是什么？",
        3,
        0,
        1
      },
      {
        "NpcBubbleTalk",
        "Start_Npc1",
        "啊......",
        3,
        2,
        1
      }
    },
    tbUnLockEvent = {}
  },
  [25] = {
    nTime = 1,
    nNum = 0,
    tbPrelock = {24},
    tbStartEvent = {
      {
        "DoCommonAct",
        "Start_Npc1",
        26,
        0,
        0,
        0
      },
      {
        "NpcAddBuff",
        "Start_Npc2",
        2452,
        1,
        100
      },
      {
        "ChangeNpcAi",
        "Start_Npc2",
        "Move",
        "npath5",
        0,
        1,
        1,
        0,
        0
      },
      {
        "NpcBubbleTalk",
        "Start_Npc2",
        "真儿！！",
        3,
        0.5,
        1
      }
    },
    tbUnLockEvent = {}
  },
  [26] = {
    nTime = 2,
    nNum = 0,
    tbPrelock = {25},
    tbStartEvent = {
      {"DelNpc", "Start_Npc1"},
      {
        "BlackMsg",
        "纳兰真忽然掉了下去！"
      }
    },
    tbUnLockEvent = {
      {
        "RemovePlayerSkillState",
        2216
      },
      {
        "SetForbiddenOperation",
        false
      },
      {"GameWin"}
    }
  },
  [30] = {
    nTime = 5,
    nNum = 1,
    tbPrelock = {10},
    tbStartEvent = {
      {
        "RaiseEvent",
        "PartnerSay",
        "你受伤了！赶紧[FFFE0D]打坐疗伤[-]！！",
        4,
        1
      },
      {
        "RaiseEvent",
        "ChangeAutoFight",
        false
      },
      {
        "OpenGuide",
        30,
        "PopT",
        "请点击使用打坐",
        "HomeScreenBattle",
        "BtnDazuo",
        {0, -40},
        true,
        true
      },
      {
        "OpenWindowAutoClose",
        "RockerGuideNpcPanel",
        "点击箭头指引的[FFFE0D]打坐技能[-]可进行生命恢复！"
      }
    },
    tbUnLockEvent = {
      {"AddAnger", -300},
      {
        "CloseWindow",
        "Guide"
      },
      {
        "CloseWindow",
        "RockerGuideNpcPanel"
      }
    }
  },
  [32] = {
    nTime = 0,
    nNum = 1,
    tbPrelock = {12},
    tbStartEvent = {
      {
        "RaiseEvent",
        "ShowPartnerAndHelper",
        false
      },
      {
        "AddNpc",
        16,
        1,
        0,
        "bs",
        "bianshen",
        false,
        8
      },
      {
        "AddNpc",
        6,
        1,
        0,
        "Start_Npc1",
        "Start_Npc1_1",
        1,
        24,
        0,
        0,
        0
      },
      {
        "AddNpc",
        7,
        1,
        0,
        "Start_Npc2",
        "Start_Npc2_1",
        1,
        24,
        0,
        0,
        0
      },
      {
        "SetNpcBloodVisable",
        "Start_Npc1",
        false,
        0
      },
      {
        "SetNpcBloodVisable",
        "Start_Npc2",
        false,
        0
      },
      {
        "MoveCameraToPosition",
        32,
        1.5,
        5368,
        2372,
        5
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
  [34] = {
    nTime = 7,
    nNum = 0,
    tbPrelock = {32},
    tbStartEvent = {
      {
        "NpcBubbleTalk",
        "Start_Npc1",
        "啊，这个是...我小时候玩的玄天武机？",
        3,
        0,
        1
      },
      {
        "NpcBubbleTalk",
        "Start_Npc1",
        "没想到还能找到它！",
        3,
        2,
        1
      },
      {
        "NpcBubbleTalk",
        "Start_Npc2",
        "好大啊！",
        3,
        4,
        1
      },
      {
        "NpcBubbleTalk",
        "Start_Npc1",
        "少侠，你进去试试吧！",
        3,
        6,
        1
      }
    },
    tbUnLockEvent = {}
  },
  [35] = {
    nTime = 3,
    nNum = 0,
    tbPrelock = {34},
    tbStartEvent = {
      {
        "RaiseEvent",
        "PlayerRunTo",
        5399,
        2286
      }
    },
    tbUnLockEvent = {}
  },
  [36] = {
    nTime = 4,
    nNum = 0,
    tbPrelock = {35},
    tbStartEvent = {
      {"DelNpc", "bs"},
      {
        "AddBuff",
        2216,
        1,
        300,
        0,
        0
      },
      {
        "NpcBubbleTalk",
        "Start_Npc1",
        "太好了！",
        3,
        0.5,
        1
      },
      {
        "NpcBubbleTalk",
        "Start_Npc2",
        "好像有什么声音？",
        3,
        2.5,
        1
      }
    },
    tbUnLockEvent = {}
  },
  [100] = {
    nTime = 1,
    nNum = 0,
    tbPrelock = {1},
    tbStartEvent = {
      {
        "NpcBubbleTalk",
        "Start_Npc1",
        "你们快点来呀！",
        3,
        0,
        1
      },
      {
        "NpcAddBuff",
        "Start_Npc1",
        2452,
        1,
        100
      },
      {
        "NpcAddBuff",
        "Start_Npc2",
        2452,
        1,
        100
      },
      {
        "ChangeNpcAi",
        "Start_Npc1",
        "Move",
        "path1_1",
        0,
        0,
        0,
        1,
        0
      }
    },
    tbUnLockEvent = {
      {
        "ChangeNpcAi",
        "Start_Npc2",
        "Move",
        "path1_2",
        0,
        0,
        0,
        1,
        0
      },
      {
        "NpcBubbleTalk",
        "Start_Npc2",
        "真儿等等我！",
        3,
        0,
        1
      }
    }
  },
  [101] = {
    nTime = 0,
    nNum = 1,
    tbPrelock = {14},
    tbStartEvent = {
      {
        "ChangeNpcAi",
        "BOSS",
        "Move",
        "Path4",
        101,
        1,
        1,
        0
      }
    },
    tbUnLockEvent = {}
  },
  [102] = {
    nTime = 0,
    nNum = 1,
    tbPrelock = {101},
    tbStartEvent = {
      {
        "MoveCameraToPosition",
        102,
        0.5,
        5813,
        2615,
        -10
      }
    },
    tbUnLockEvent = {}
  }
}
