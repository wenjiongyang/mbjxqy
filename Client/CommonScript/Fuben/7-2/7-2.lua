local tbFubenSetting = {}
Fuben:SetFubenSetting(54, tbFubenSetting)
tbFubenSetting.szFubenClass = "PersonalFubenBase"
tbFubenSetting.szName = "测试副本"
tbFubenSetting.szNpcPointFile = "Setting/Fuben/PersonalFuben/7_2/NpcPos.tab"
tbFubenSetting.tbBeginPoint = {4031, 2939}
tbFubenSetting.nStartDir = 20
tbFubenSetting.ANIMATION = {
  [1] = "Scenes/Maps/yw_luoyegu/Main Camera.controller"
}
tbFubenSetting.NPC = {
  [1] = {
    nTemplate = 1680,
    nLevel = -1,
    nSeries = -1
  },
  [2] = {
    nTemplate = 1681,
    nLevel = -1,
    nSeries = -1
  },
  [3] = {
    nTemplate = 1682,
    nLevel = -1,
    nSeries = -1
  },
  [4] = {
    nTemplate = 1683,
    nLevel = -1,
    nSeries = -1
  },
  [5] = {
    nTemplate = 1684,
    nLevel = -1,
    nSeries = -1
  },
  [6] = {
    nTemplate = 853,
    nLevel = -1,
    nSeries = 0
  },
  [7] = {
    nTemplate = 104,
    nLevel = -1,
    nSeries = 0
  }
}
tbFubenSetting.LOCK = {
  [1] = {
    nTime = 1,
    nNum = 0,
    tbPrelock = {},
    tbStartEvent = {
      {
        "BlackMsg",
        "这迷宫如此阴森，看来得小心查探了！"
      },
      {
        "RaiseEvent",
        "PartnerSay",
        "好冷！阴风蚀骨！",
        3,
        1
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
        5601,
        2717
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
        2,
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
        "RaiseEvent",
        "PartnerSay",
        "这里好多蜘蛛啊！",
        3,
        1
      },
      {
        "BlackMsg",
        "击败怪物，找到出路！"
      },
      {
        "AddNpc",
        7,
        1,
        0,
        "wall",
        "wall1",
        false,
        16,
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
      {
        "OpenDynamicObstacle",
        "obs2"
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
        "trapgo1",
        5
      },
      {
        "SetTargetPos",
        7315,
        3951
      }
    },
    tbUnLockEvent = {}
  },
  [6] = {
    nTime = 0,
    nNum = 1,
    tbPrelock = {5},
    tbStartEvent = {
      {
        "TrapUnlock",
        "trap2",
        6
      },
      {
        "SetTargetPos",
        7343,
        6563
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
    nNum = 7,
    tbPrelock = {6},
    tbStartEvent = {
      {
        "AddNpc",
        3,
        6,
        7,
        "gw",
        "guaiwu2",
        false,
        0,
        0,
        9005,
        0.5
      },
      {
        "AddNpc",
        4,
        1,
        7,
        "gw",
        "guaiwu2",
        false,
        0,
        0,
        9005,
        0.5
      },
      {
        "AddNpc",
        7,
        1,
        0,
        "wall",
        "wall2",
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
        "wall",
        "wall3",
        false,
        28,
        0,
        0,
        0
      },
      {
        "RaiseEvent",
        "CloseDynamicObstacle",
        "obs2"
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
  [8] = {
    nTime = 0,
    nNum = 1,
    tbPrelock = {7},
    tbStartEvent = {
      {
        "TrapUnlock",
        "trap3",
        8
      },
      {
        "SetTargetPos",
        5596,
        6703
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
    nNum = 10,
    tbPrelock = {8},
    tbStartEvent = {
      {
        "AddNpc",
        1,
        4,
        9,
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
        4,
        9,
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
        1,
        9,
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
        4,
        1,
        9,
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
        7,
        1,
        0,
        "wall",
        "wall3",
        false,
        28,
        0,
        0,
        0
      },
      {
        "RaiseEvent",
        "CloseDynamicObstacle",
        "obs3"
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
        "TrapUnlock",
        "trap4",
        10
      },
      {
        "SetTargetPos",
        5392,
        5307
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
        "AddNpc",
        5,
        1,
        11,
        "sl",
        "shouling",
        false,
        40,
        0,
        9005,
        0.5
      },
      {
        "AddNpc",
        1,
        3,
        0,
        "gw",
        "guaiwu4",
        false,
        0,
        3,
        9005,
        0.5
      },
      {
        "AddNpc",
        3,
        3,
        0,
        "gw",
        "guaiwu4",
        false,
        0,
        6,
        9005,
        0.5
      },
      {
        "AddNpc",
        2,
        1,
        0,
        "gw",
        "guaiwu4",
        false,
        0,
        3,
        9005,
        0.5
      },
      {
        "AddNpc",
        4,
        1,
        0,
        "gw",
        "guaiwu4",
        false,
        0,
        6,
        9005,
        0.5
      },
      {
        "RaiseEvent",
        "PartnerSay",
        "这个蝎子是修炼成精了么？如此之大！",
        3,
        1
      },
      {
        "BlackMsg",
        "击败巨型蝎子，离开此处！"
      }
    },
    tbUnLockEvent = {}
  },
  [12] = {
    nTime = 2.1,
    nNum = 0,
    tbPrelock = {11},
    tbStartEvent = {
      {
        "SetGameWorldScale",
        0.1
      },
      {"DoDeath", "gw"}
    },
    tbUnLockEvent = {
      {
        "SetGameWorldScale",
        1
      },
      {"GameWin"}
    }
  }
}
