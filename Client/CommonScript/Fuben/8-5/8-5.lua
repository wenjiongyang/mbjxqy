local tbFubenSetting = {}
Fuben:SetFubenSetting(64, tbFubenSetting)
tbFubenSetting.szFubenClass = "PersonalFubenBase"
tbFubenSetting.szName = "测试副本"
tbFubenSetting.szNpcPointFile = "Setting/Fuben/PersonalFuben/8_5/NpcPos.tab"
tbFubenSetting.szPathFile = "Setting/Fuben/PersonalFuben/8_5/NpcPath.tab"
tbFubenSetting.tbBeginPoint = {1605, 1644}
tbFubenSetting.nStartDir = 0
tbFubenSetting.ANIMATION = {
  [1] = "Scenes/Maps/yw_luoyegu/Main Camera.controller"
}
tbFubenSetting.NPC = {
  [1] = {
    nTemplate = 1930,
    nLevel = -1,
    nSeries = -1
  },
  [2] = {
    nTemplate = 1931,
    nLevel = -1,
    nSeries = -1
  },
  [3] = {
    nTemplate = 1932,
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
        1124,
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
        1896,
        3212
      },
      {
        "AddNpc",
        7,
        1,
        0,
        "wall",
        "men1",
        false,
        24
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
        "果然有人！",
        3,
        1
      }
    },
    tbUnLockEvent = {
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
        3854,
        4854
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
        38
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
        2,
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
        "唐门禁地，闲杂人等退下！",
        4,
        1,
        1
      }
    },
    tbUnLockEvent = {
      {
        "RaiseEvent",
        "PartnerSay",
        "我就要看看这禁地！",
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
        "trappos1",
        7
      },
      {
        "SetTargetPos",
        5003,
        2984
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
        "TrapUnlock",
        "trap3",
        8
      },
      {
        "SetTargetPos",
        4705,
        2211
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
    nNum = 1,
    tbPrelock = {8},
    tbStartEvent = {
      {
        "AddNpc",
        1,
        8,
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
        2,
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
        1,
        8,
        0,
        "gw",
        "guaiwu3",
        false,
        32,
        4,
        9009,
        0.5
      },
      {
        "AddNpc",
        2,
        2,
        0,
        "gw1",
        "guaiwu3",
        false,
        32,
        4,
        9009,
        0.5
      },
      {
        "AddNpc",
        3,
        1,
        9,
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
        "快快退下，否则不客气了！",
        4,
        1,
        1
      },
      {
        "NpcBubbleTalk",
        "sl",
        "可恶！",
        4,
        1,
        1
      }
    },
    tbUnLockEvent = {}
  },
  [10] = {
    nTime = 2.1,
    nNum = 0,
    tbPrelock = {9},
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
