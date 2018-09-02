local tbFubenSetting = {}
Fuben:SetFubenSetting(52, tbFubenSetting)
tbFubenSetting.szFubenClass = "PersonalFubenBase"
tbFubenSetting.szName = "测试副本"
tbFubenSetting.szNpcPointFile = "Setting/Fuben/PersonalFuben/3_8/NpcPos.tab"
tbFubenSetting.szPathFile = "Setting/Fuben/PersonalFuben/3_8/NpcPath.tab"
tbFubenSetting.tbBeginPoint = {5100, 1816}
tbFubenSetting.nStartDir = 48
tbFubenSetting.NPC = {
  [1] = {
    nTemplate = 1351,
    nLevel = 32,
    nSeries = -1
  },
  [2] = {
    nTemplate = 1352,
    nLevel = 32,
    nSeries = -1
  },
  [3] = {
    nTemplate = 1353,
    nLevel = 34,
    nSeries = -1
  },
  [4] = {
    nTemplate = 684,
    nLevel = 34,
    nSeries = 0
  },
  [5] = {
    nTemplate = 1354,
    nLevel = 34,
    nSeries = 0
  },
  [8] = {
    nTemplate = 74,
    nLevel = 32,
    nSeries = 0
  },
  [9] = {
    nTemplate = 104,
    nLevel = 32,
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
        1096,
        false
      }
    },
    tbUnLockEvent = {
      {
        "SetShowTime",
        2
      },
      {
        "OpenDynamicObstacle",
        "obs1"
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
        "ChangeTrap",
        "trap1",
        nil,
        nil,
        nil,
        nil,
        nil,
        true
      },
      {
        "SetTargetPos",
        3635,
        1845
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
        32
      },
      {
        "RaiseEvent",
        "CloseDynamicObstacle",
        "obs1"
      },
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
        0.5,
        9005,
        0.5
      },
      {
        "AddNpc",
        2,
        1,
        4,
        "gw",
        "guaiwu2",
        false,
        0,
        0.5,
        9005,
        0.5
      },
      {
        "BlackMsg",
        "击败忽然出现的狐狸！"
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
        "trap2",
        5
      },
      {
        "SetTargetPos",
        2234,
        2014
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
        26
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
        "jump1",
        100
      },
      {
        "ChangeTrap",
        "jump1",
        nil,
        {
          1939,
          3770,
          2
        }
      },
      {
        "ChangeTrap",
        "jump2",
        nil,
        {
          2254,
          4071,
          2
        }
      },
      {
        "SetTargetPos",
        1663,
        3550
      }
    },
    tbUnLockEvent = {
      {
        "SetTargetPos",
        2057,
        4990
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
        "trap3",
        7
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
        30
      }
    }
  },
  [8] = {
    nTime = 0,
    nNum = 1,
    tbPrelock = {7},
    tbStartEvent = {
      {
        "BlackMsg",
        "出现了好大一只狐狸，小心应付！"
      },
      {
        "AddNpc",
        1,
        5,
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
        2,
        2,
        0,
        "gw",
        "guaiwu6",
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
        "guaiwu6",
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
        "obs4"
      },
      {"DoDeath", "wall"},
      {"DoDeath", "gw"}
    }
  },
  [9] = {
    nTime = 0,
    nNum = 1,
    tbPrelock = {8},
    tbStartEvent = {
      {
        "AddNpc",
        8,
        1,
        0,
        "qg",
        "qinggong",
        false,
        0
      },
      {
        "BlackMsg",
        "前方应该就是他二人比试之处！"
      },
      {
        "ChangeTrap",
        "jump4",
        nil,
        {
          3030,
          4743,
          2
        }
      },
      {
        "ChangeTrap",
        "jump5",
        nil,
        {
          3595,
          4349,
          2
        }
      },
      {
        "ChangeTrap",
        "jump6",
        nil,
        {
          4053,
          4033,
          2
        }
      },
      {
        "TrapUnlock",
        "jump4",
        9
      },
      {
        "SetTargetPos",
        2878,
        5289
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
        4432,
        4575
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
        "MoveCameraToPosition",
        11,
        1.5,
        5053,
        5346,
        0
      },
      {
        "AddNpc",
        4,
        1,
        0,
        "npc",
        "yangyingfeng",
        false,
        12,
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
        "mengzhiqiu",
        false,
        44,
        0,
        0,
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
        "SetNpcBloodVisable",
        "npc",
        false,
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
        "ChangeFightState",
        0
      },
      {
        "RaiseEvent",
        "ShowPartnerAndHelper",
        false
      }
    },
    tbUnLockEvent = {}
  },
  [12] = {
    nTime = 2,
    nNum = 0,
    tbPrelock = {11},
    tbStartEvent = {
      {
        "NpcBubbleTalk",
        "npc",
        "（大喊）晚辈杨影枫拜见孟谷主！",
        4,
        0.5,
        1
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
        "MoveCameraToPosition",
        13,
        1.5,
        6626,
        6713,
        5
      }
    },
    tbUnLockEvent = {}
  },
  [14] = {
    nTime = 2,
    nNum = 0,
    tbPrelock = {13},
    tbStartEvent = {
      {
        "NpcBubbleTalk",
        "npc1",
        "不必多礼。",
        4,
        0.5,
        1
      }
    },
    tbUnLockEvent = {}
  },
  [15] = {
    nTime = 1.2,
    nNum = 0,
    tbPrelock = {14},
    tbStartEvent = {
      {
        "DoCommonAct",
        "npc1",
        6,
        0,
        0,
        0
      },
      {
        "CastSkill",
        "npc1",
        53,
        1,
        -1,
        -1
      }
    },
    tbUnLockEvent = {
      {"DelNpc", "npc1"}
    }
  },
  [16] = {
    nTime = 0,
    nNum = 1,
    tbPrelock = {15},
    tbStartEvent = {
      {
        "MoveCameraToPosition",
        16,
        1,
        5144,
        5455,
        5
      }
    },
    tbUnLockEvent = {}
  },
  [17] = {
    nTime = 1,
    nNum = 0,
    tbPrelock = {16},
    tbStartEvent = {
      {
        "AddNpc",
        5,
        1,
        0,
        "npc1",
        "mengzhiqiu1",
        false,
        44,
        0,
        9005,
        0.5
      },
      {
        "ChangeNpcFightState",
        "npc1",
        0,
        0.7
      }
    },
    tbUnLockEvent = {}
  },
  [18] = {
    nTime = 0,
    nNum = 1,
    tbPrelock = {17},
    tbStartEvent = {
      {
        "RaiseEvent",
        "ShowTaskDialog",
        18,
        1097,
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
  [19] = {
    nTime = 5,
    nNum = 0,
    tbPrelock = {18},
    tbStartEvent = {
      {
        "ChangeNpcCamp",
        "npc1",
        1
      },
      {
        "NpcAddBuff",
        "npc1",
        100,
        1,
        100
      },
      {
        "NpcAddBuff",
        "npc",
        100,
        1,
        100
      },
      {
        "MoveCamera",
        0,
        3,
        40,
        47.8,
        70.4,
        31,
        105,
        0
      }
    },
    tbUnLockEvent = {}
  },
  [101] = {
    nTime = 1,
    nNum = 0,
    tbPrelock = {19},
    tbStartEvent = {
      {
        "DoCommonAct",
        "npc1",
        6,
        0,
        0,
        0
      },
      {
        "CastSkill",
        "npc1",
        2375,
        1,
        -1,
        -1
      }
    },
    tbUnLockEvent = {}
  },
  [20] = {
    nTime = 1,
    nNum = 0,
    tbPrelock = {101},
    tbStartEvent = {
      {
        "SetNpcProtected",
        "npc1",
        1
      },
      {
        "SetNpcDir",
        "npc1",
        32
      },
      {
        "DoCommonAct",
        "npc",
        36,
        0,
        1,
        0
      }
    },
    tbUnLockEvent = {}
  },
  [21] = {
    nTime = 4,
    nNum = 0,
    tbPrelock = {20},
    tbStartEvent = {
      {
        "NpcBubbleTalk",
        "npc",
        "孟谷主不愧是武林盟主，晚辈输得口服心服！",
        4,
        0,
        1
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
      {"GameWin"}
    }
  }
}
