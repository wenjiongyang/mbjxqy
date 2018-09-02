local tbFubenSetting = {}
Fuben:SetFubenSetting(60, tbFubenSetting)
tbFubenSetting.szFubenClass = "PersonalFubenBase"
tbFubenSetting.szName = "测试副本"
tbFubenSetting.szNpcPointFile = "Setting/Fuben/PersonalFuben/8_1/NpcPos.tab"
tbFubenSetting.szPathFile = "Setting/Fuben/PersonalFuben/8_1/NpcPath.tab"
tbFubenSetting.tbBeginPoint = {4224, 5199}
tbFubenSetting.nStartDir = 48
tbFubenSetting.ANIMATION = {
  [1] = "Scenes/Maps/yw_luoyegu/Main Camera.controller"
}
tbFubenSetting.NPC = {
  [1] = {
    nTemplate = 1915,
    nLevel = -1,
    nSeries = -1
  },
  [2] = {
    nTemplate = 1916,
    nLevel = -1,
    nSeries = -1
  },
  [3] = {
    nTemplate = 1917,
    nLevel = -1,
    nSeries = -1
  },
  [4] = {
    nTemplate = 1918,
    nLevel = -1,
    nSeries = -1
  },
  [7] = {
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
        1120,
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
        3388,
        5050
      },
      {
        "AddNpc",
        7,
        1,
        0,
        "wall",
        "men1",
        false,
        42
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
        8,
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
        "RaiseEvent",
        "PartnerSay",
        "小心有恶狼！！",
        3,
        1
      }
    },
    tbUnLockEvent = {
      {
        "RaiseEvent",
        "PartnerSay",
        "看来此处不甚太平...",
        3,
        1
      },
      {
        "BlackMsg",
        "继续前进"
      },
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
        4950,
        3050
      }
    },
    tbUnLockEvent = {
      {
        "ClearTargetPos"
      },
      {
        "AddNpc",
        7,
        1,
        0,
        "wall",
        "men2",
        false,
        64
      }
    }
  },
  [6] = {
    nTime = 0,
    nNum = 10,
    tbPrelock = {5},
    tbStartEvent = {
      {
        "AddNpc",
        2,
        9,
        6,
        "gw",
        "guaiwu2",
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
        "guaiwu2",
        false,
        0,
        0.5,
        9005,
        0.5
      },
      {
        "NpcBubbleTalk",
        "gw",
        "这块地方已经被我们承包了！不想死的话赶紧滚！",
        4,
        1,
        1
      }
    },
    tbUnLockEvent = {
      {
        "RaiseEvent",
        "PartnerSay",
        "这些土匪在此处干什么？",
        3,
        1
      },
      {
        "BlackMsg",
        "继续前进"
      },
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
        2510,
        2501
      }
    },
    tbUnLockEvent = {
      {
        "ClearTargetPos"
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
        2,
        9,
        0,
        "gw",
        "guaiwu3",
        false,
        32,
        0.5,
        9009,
        0.5
      },
      {
        "AddNpc",
        3,
        1,
        0,
        "gw1",
        "guaiwu3",
        false,
        32,
        0.5,
        9009,
        0.5
      },
      {
        "AddNpc",
        4,
        1,
        8,
        "sl",
        "shouling",
        false,
        32,
        0.5,
        9009,
        0.5
      },
      {
        "NpcBubbleTalk",
        "gw1",
        "胆儿挺肥啊，居然敢到这里撒野！",
        4,
        1,
        1
      },
      {
        "NpcBubbleTalk",
        "sl",
        "很好！最近正手痒呢！",
        4,
        1,
        1
      },
      {
        "RaiseEvent",
        "PartnerSay",
        "此人是土匪头目？",
        3,
        1
      }
    },
    tbUnLockEvent = {}
  },
  [9] = {
    nTime = 2.1,
    nNum = 0,
    tbPrelock = {8},
    tbStartEvent = {
      {"DoDeath", "gw"},
      {"DoDeath", "gw1"},
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
      {"GameWin"}
    }
  }
}
