local tbFubenSetting = {}
Fuben:SetFubenSetting(62, tbFubenSetting)
tbFubenSetting.szFubenClass = "PersonalFubenBase"
tbFubenSetting.szName = "测试副本"
tbFubenSetting.szNpcPointFile = "Setting/Fuben/PersonalFuben/8_3/NpcPos.tab"
tbFubenSetting.szPathFile = "Setting/Fuben/PersonalFuben/8_3/NpcPath.tab"
tbFubenSetting.tbBeginPoint = {2371, 1170}
tbFubenSetting.nStartDir = 0
tbFubenSetting.ANIMATION = {
  [1] = "Scenes/Maps/yw_luoyegu/Main Camera.controller"
}
tbFubenSetting.NPC = {
  [1] = {
    nTemplate = 1922,
    nLevel = -1,
    nSeries = -1
  },
  [2] = {
    nTemplate = 1923,
    nLevel = -1,
    nSeries = -1
  },
  [3] = {
    nTemplate = 1924,
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
        1122,
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
        2377,
        2251
      },
      {
        "AddNpc",
        7,
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
        "有人来了！",
        3,
        1
      }
    },
    tbUnLockEvent = {
      {
        "RaiseEvent",
        "PartnerSay",
        "不堪一击...",
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
        5630,
        2517
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
        48
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
        1,
        8,
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
        2,
        1,
        6,
        "gw1",
        "guaiwu2",
        false,
        0,
        0.5,
        9005,
        0.5
      },
      {
        "NpcBubbleTalk",
        "gw1",
        "来者何人？擅闯官府重地，绑起来！",
        4,
        1,
        1
      }
    },
    tbUnLockEvent = {
      {
        "RaiseEvent",
        "PartnerSay",
        "大言不惭！",
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
        6109,
        5255
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
        "men3",
        false,
        32
      }
    }
  },
  [8] = {
    nTime = 0,
    nNum = 12,
    tbPrelock = {7},
    tbStartEvent = {
      {
        "AddNpc",
        1,
        10,
        8,
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
        8,
        "gw1",
        "guaiwu3",
        false,
        0,
        0.5,
        9005,
        0.5
      },
      {
        "NpcBubbleTalk",
        "gw1",
        "兄弟们一起上，有重赏！",
        4,
        1,
        1
      }
    },
    tbUnLockEvent = {
      {
        "RaiseEvent",
        "PartnerSay",
        "重赏之下，必有勇夫啊，哈哈！",
        3,
        1
      },
      {
        "BlackMsg",
        "继续前进"
      },
      {
        "OpenDynamicObstacle",
        "obs3"
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
        2687,
        5590
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
        "AddNpc",
        1,
        10,
        0,
        "gw",
        "guaiwu4",
        false,
        32,
        0.5,
        9009,
        0.5
      },
      {
        "AddNpc",
        2,
        2,
        0,
        "gw1",
        "guaiwu4",
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
        10,
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
        "杀啊！",
        4,
        1,
        1
      },
      {
        "NpcBubbleTalk",
        "sl",
        "有两下子，居然闯到此处，找死！",
        4,
        1,
        1
      }
    },
    tbUnLockEvent = {}
  },
  [11] = {
    nTime = 2.1,
    nNum = 0,
    tbPrelock = {10},
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
