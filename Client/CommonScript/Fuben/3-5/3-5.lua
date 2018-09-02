local tbFubenSetting = {}
Fuben:SetFubenSetting(34, tbFubenSetting)
tbFubenSetting.szFubenClass = "PersonalFubenBase"
tbFubenSetting.szName = "测试副本"
tbFubenSetting.szNpcPointFile = "Setting/Fuben/PersonalFuben/3_5/NpcPos.tab"
tbFubenSetting.szPathFile = "Setting/Fuben/PersonalFuben/3_5/NpcPath.tab"
tbFubenSetting.tbBeginPoint = {7067, 5882}
tbFubenSetting.nStartDir = 48
tbFubenSetting.ANIMATION = {
  [1] = "Scenes/camera/Camera_chusheng.controller"
}
tbFubenSetting.NPC = {
  [1] = {
    nTemplate = 832,
    nLevel = 26,
    nSeries = -1
  },
  [2] = {
    nTemplate = 836,
    nLevel = 26,
    nSeries = -1
  },
  [3] = {
    nTemplate = 839,
    nLevel = 28,
    nSeries = -1
  },
  [5] = {
    nTemplate = 684,
    nLevel = 28,
    nSeries = 0
  },
  [6] = {
    nTemplate = 840,
    nLevel = 28,
    nSeries = 0
  },
  [9] = {
    nTemplate = 104,
    nLevel = 26,
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
        1040,
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
        5193,
        5891
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
        3,
        4,
        "gw",
        "guaiwu2",
        false,
        0,
        1.5,
        9005,
        0.5
      },
      {
        "AddNpc",
        2,
        1,
        4,
        "gw1",
        "guaiwu2",
        false,
        0,
        1.5,
        9005,
        0.5
      },
      {
        "NpcBubbleTalk",
        "gw1",
        "居然自己闯入摘星地牢，你是不是疯了？",
        4,
        2.5,
        1
      },
      {
        "BlackMsg",
        "击败守卫地牢的无忧弟子。"
      },
      {
        "RaiseEvent",
        "PartnerSay",
        "你们把纳兰姑娘关在哪里了？",
        3,
        1
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
    tbPrelock = {14},
    tbStartEvent = {
      {
        "RaiseEvent",
        "PartnerSay",
        "此处戒备森严，必然关押着重要的人！",
        3,
        1
      },
      {
        "TrapUnlock",
        "trap2",
        5
      },
      {
        "SetTargetPos",
        2602,
        4218
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
        16
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
        "gw1",
        "guaiwu4",
        false,
        0,
        1.5,
        9005,
        0.5
      },
      {
        "NpcBubbleTalk",
        "gw1",
        "不知死活的家伙，自己送上门来了！",
        4,
        2.5,
        2
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
    tbPrelock = {15},
    tbStartEvent = {
      {
        "TrapUnlock",
        "trap3",
        7
      },
      {
        "SetTargetPos",
        4435,
        1312
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
        16
      }
    }
  },
  [8] = {
    nTime = 0,
    nNum = 1,
    tbPrelock = {7},
    tbStartEvent = {
      {
        "AddNpc",
        1,
        6,
        0,
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
        "sl",
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
        2,
        0,
        "gw1",
        "guaiwu6",
        false,
        0,
        2,
        9005,
        0.5
      },
      {
        "AddNpc",
        1,
        4,
        0,
        "gw",
        "guaiwu5",
        false,
        0,
        2,
        9005,
        0.5
      },
      {
        "NpcBubbleTalk",
        "sl",
        "胆敢劫狱？吃我一枪！",
        4,
        1.5,
        1
      },
      {
        "NpcBubbleTalk",
        "gw1",
        "兄弟们上啊！",
        4,
        3,
        1
      },
      {
        "RaiseEvent",
        "PartnerSay",
        "好像有大家伙出现了！",
        3,
        2
      },
      {
        "BlackMsg",
        "击败守卫此处的牢头"
      }
    },
    tbUnLockEvent = {
      {
        "OpenDynamicObstacle",
        "obs3"
      },
      {"DoDeath", "wall"},
      {"DoDeath", "gw"},
      {"DoDeath", "gw1"}
    }
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
    tbPrelock = {9},
    tbStartEvent = {
      {
        "RaiseEvent",
        "FllowPlayer",
        false
      },
      {
        "RaiseEvent",
        "ShowPartnerAndHelper",
        false
      },
      {
        "MoveCameraToPosition",
        10,
        2,
        5020,
        2094,
        5
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
        5,
        1,
        0,
        "npc",
        "yangyingfeng",
        false,
        40,
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
        "zixuan",
        false,
        32,
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
        "ChangeNpcAi",
        "npc",
        "Move",
        "path1",
        0,
        0,
        0,
        0,
        0
      },
      {
        "ChangeNpcAi",
        "npc1",
        "Move",
        "path2",
        0,
        0,
        0,
        0,
        0
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
        1041,
        false
      }
    },
    tbUnLockEvent = {
      {
        "SetForbiddenOperation",
        false
      },
      {"GameWin"}
    }
  },
  [14] = {
    nTime = 0,
    nNum = 1,
    tbPrelock = {4},
    tbStartEvent = {
      {
        "TrapUnlock",
        "way1",
        14
      },
      {
        "SetTargetPos",
        2609,
        5795
      }
    },
    tbUnLockEvent = {
      {
        "ClearTargetPos"
      }
    }
  },
  [15] = {
    nTime = 0,
    nNum = 1,
    tbPrelock = {6},
    tbStartEvent = {
      {
        "TrapUnlock",
        "way2",
        15
      },
      {
        "SetTargetPos",
        2659,
        1405
      }
    },
    tbUnLockEvent = {
      {
        "ClearTargetPos"
      }
    }
  }
}
