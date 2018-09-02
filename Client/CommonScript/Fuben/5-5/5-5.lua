local tbFubenSetting = {}
Fuben:SetFubenSetting(46, tbFubenSetting)
tbFubenSetting.szFubenClass = "PersonalFubenBase"
tbFubenSetting.szName = "测试副本"
tbFubenSetting.szNpcPointFile = "Setting/Fuben/PersonalFuben/5_5/NpcPos.tab"
tbFubenSetting.szPathFile = "Setting/Fuben/PersonalFuben/5_5/NpcPath.tab"
tbFubenSetting.tbBeginPoint = {4369, 1844}
tbFubenSetting.nStartDir = 0
tbFubenSetting.ANIMATION = {
  [1] = "Scenes/camera/Camera_chusheng.controller"
}
tbFubenSetting.NPC = {
  [1] = {
    nTemplate = 871,
    nLevel = 50,
    nSeries = -1
  },
  [2] = {
    nTemplate = 1282,
    nLevel = 51,
    nSeries = -1
  },
  [3] = {
    nTemplate = 872,
    nLevel = 52,
    nSeries = -1
  },
  [4] = {
    nTemplate = 747,
    nLevel = 52,
    nSeries = 0
  },
  [5] = {
    nTemplate = 853,
    nLevel = 52,
    nSeries = 0
  },
  [6] = {
    nTemplate = 1390,
    nLevel = 52,
    nSeries = 0
  },
  [7] = {
    nTemplate = 873,
    nLevel = 52,
    nSeries = 0
  },
  [8] = {
    nTemplate = 874,
    nLevel = 52,
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
        1064,
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
        3872,
        3018
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
        0,
        0,
        0
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
        0,
        0
      },
      {
        "BlackMsg",
        "没想到这姚公子竟雇佣了不少的护卫！"
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
    tbPrelock = {4},
    tbStartEvent = {
      {
        "TrapUnlock",
        "gopoint1",
        100
      },
      {
        "SetTargetPos",
        1931,
        3864
      }
    },
    tbUnLockEvent = {
      {
        "ClearTargetPos"
      }
    }
  },
  [5] = {
    nTime = 0,
    nNum = 1,
    tbPrelock = {100},
    tbStartEvent = {
      {
        "TrapUnlock",
        "trap2",
        5
      },
      {
        "SetTargetPos",
        1915,
        5777
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
        32
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
        9005,
        0.5
      },
      {
        "BlackMsg",
        "有高手出现，小心！"
      }
    },
    tbUnLockEvent = {
      {
        "OpenDynamicObstacle",
        "obs2"
      },
      {
        "OpenDynamicObstacle",
        "obs3"
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
        4550,
        6317
      }
    },
    tbUnLockEvent = {
      {
        "AddNpc",
        9,
        1,
        0,
        "wall",
        "men3",
        false,
        32
      },
      {
        "RaiseEvent",
        "CloseDynamicObstacle",
        "obs3"
      },
      {
        "ClearTargetPos"
      }
    }
  },
  [12] = {
    nTime = 0,
    nNum = 1,
    tbPrelock = {7},
    tbStartEvent = {
      {
        "MoveCameraToPosition",
        12,
        2,
        5246,
        6221,
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
        "npc",
        "dugujian",
        false,
        16,
        0,
        0,
        0
      },
      {
        "AddNpc",
        5,
        1,
        0,
        "npc1",
        "zhanglinxin",
        false,
        16,
        0,
        0,
        0
      },
      {
        "AddNpc",
        6,
        1,
        0,
        "npc2",
        "yaogongzi",
        false,
        16,
        0,
        0,
        0
      },
      {
        "AddNpc",
        7,
        1,
        0,
        "npc3",
        "lisan",
        false,
        48,
        0,
        0,
        0
      },
      {
        "AddNpc",
        8,
        1,
        0,
        "npc4",
        "yanghu",
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
        "SetNpcBloodVisable",
        "npc2",
        false,
        0
      },
      {
        "SetNpcBloodVisable",
        "npc3",
        false,
        0
      },
      {
        "SetNpcBloodVisable",
        "npc4",
        false,
        0
      },
      {
        "ChangeNpcFightState",
        "npc",
        0,
        0.5
      },
      {
        "ChangeNpcFightState",
        "npc1",
        0,
        0.5
      },
      {
        "ChangeNpcFightState",
        "npc2",
        0,
        0.5
      },
      {
        "ChangeNpcFightState",
        "npc3",
        0,
        0.5
      },
      {
        "ChangeNpcFightState",
        "npc4",
        0,
        0.5
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
        1065,
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
    nTime = 0,
    nNum = 2,
    tbPrelock = {13},
    tbStartEvent = {
      {
        "ChangeNpcAi",
        "npc3",
        "Move",
        "path1",
        14,
        1,
        1,
        1,
        0
      },
      {
        "ChangeNpcAi",
        "npc4",
        "Move",
        "path2",
        14,
        1,
        1,
        1,
        0
      },
      {
        "NpcBubbleTalk",
        "npc3",
        "多谢大侠相助！",
        4,
        0,
        1
      },
      {
        "NpcBubbleTalk",
        "npc4",
        "后会有期！",
        4,
        0,
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
        "AddNpc",
        3,
        1,
        15,
        "boss",
        "boss",
        false,
        48,
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
        "ChangeNpcAi",
        "boss",
        "Move",
        "path3",
        16,
        1,
        1,
        0,
        0
      },
      {
        "NpcBubbleTalk",
        "boss",
        "你们是何人？胆敢私放囚犯？",
        4,
        0.5,
        1
      }
    },
    tbUnLockEvent = {
      {"DoDeath", "gw"}
    }
  },
  [16] = {
    nTime = 0,
    nNum = 1,
    tbPrelock = {14},
    tbStartEvent = {},
    tbUnLockEvent = {
      {
        "SetAiActive",
        "boss",
        0
      }
    }
  },
  [17] = {
    nTime = 12,
    nNum = 0,
    tbPrelock = {16},
    tbStartEvent = {
      {
        "SetNpcProtected",
        "npc2",
        1
      },
      {
        "NpcBubbleTalk",
        "npc2",
        "冯...冯麻子，你...你怎么来了？",
        3,
        1,
        1
      },
      {
        "NpcBubbleTalk",
        "boss",
        "姚公子？你带人放了囚犯，如何向知府交代啊？",
        3,
        3,
        1
      },
      {
        "NpcBubbleTalk",
        "npc2",
        "我...我自会...向我爹交...交代，你...你管不着！",
        3,
        5,
        1
      },
      {
        "NpcBubbleTalk",
        "npc",
        "人是我让他放的，如何？",
        3,
        7,
        1
      },
      {
        "NpcBubbleTalk",
        "boss",
        "嘿嘿，哪来的臭小子，找死！姚公子你最好站远点！",
        3,
        9,
        1
      },
      {
        "NpcBubbleTalk",
        "npc2",
        "好！你...你们动手，我...我看戏。",
        3,
        11,
        1
      }
    },
    tbUnLockEvent = {}
  },
  [18] = {
    nTime = 1.5,
    nNum = 0,
    tbPrelock = {17},
    tbStartEvent = {
      {
        "ChangeNpcAi",
        "npc2",
        "Move",
        "path4",
        0,
        0,
        0,
        1,
        0
      }
    },
    tbUnLockEvent = {
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
        "击败忽然出现的牢头！"
      },
      {
        "NpcBubbleTalk",
        "boss",
        "兄弟们出来！一起上！",
        3,
        2.5,
        1
      },
      {
        "AddNpc",
        1,
        6,
        0,
        "gw",
        "guaiwu5",
        false,
        48,
        2.5,
        9005,
        0.5
      },
      {
        "AddNpc",
        2,
        2,
        0,
        "gw",
        "guaiwu6",
        false,
        48,
        5.5,
        9005,
        0.5
      }
    }
  },
  [19] = {
    nTime = 2.1,
    nNum = 0,
    tbPrelock = {15},
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
  [20] = {
    nTime = 0.5,
    nNum = 0,
    tbPrelock = {19},
    tbStartEvent = {},
    tbUnLockEvent = {
      {"GameWin"}
    }
  }
}
