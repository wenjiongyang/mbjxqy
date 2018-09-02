local tbFubenSetting = {}
Fuben:SetFubenSetting(63, tbFubenSetting)
tbFubenSetting.szFubenClass = "PersonalFubenBase"
tbFubenSetting.szName = "测试副本"
tbFubenSetting.szNpcPointFile = "Setting/Fuben/PersonalFuben/8_4/NpcPos.tab"
tbFubenSetting.szPathFile = "Setting/Fuben/PersonalFuben/8_4/NpcPath.tab"
tbFubenSetting.tbBeginPoint = {2692, 1285}
tbFubenSetting.nStartDir = 0
tbFubenSetting.ANIMATION = {
  [1] = "Scenes/Maps/yw_luoyegu/Main Camera.controller"
}
tbFubenSetting.NPC = {
  [1] = {
    nTemplate = 1925,
    nLevel = -1,
    nSeries = -1
  },
  [2] = {
    nTemplate = 1926,
    nLevel = -1,
    nSeries = -1
  },
  [3] = {
    nTemplate = 1933,
    nLevel = -1,
    nSeries = -1
  },
  [4] = {
    nTemplate = 1927,
    nLevel = -1,
    nSeries = -1
  },
  [5] = {
    nTemplate = 1928,
    nLevel = -1,
    nSeries = 0
  },
  [6] = {
    nTemplate = 1929,
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
    nTime = 0,
    nNum = 1,
    tbPrelock = {},
    tbStartEvent = {
      {
        "RaiseEvent",
        "ShowTaskDialog",
        1,
        1123,
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
        2666,
        2412
      },
      {
        "AddNpc",
        7,
        1,
        0,
        "wall",
        "men1",
        false,
        16
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
    nNum = 16,
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
        "AddNpc",
        2,
        7,
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
        "AddNpc",
        3,
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
        "RaiseEvent",
        "PartnerSay",
        "风雪山庄人多势众啊！",
        3,
        1
      }
    },
    tbUnLockEvent = {
      {
        "RaiseEvent",
        "PartnerSay",
        "不过如此嘛。",
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
        2723,
        6540
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
        32
      }
    }
  },
  [6] = {
    nTime = 0,
    nNum = 18,
    tbPrelock = {5},
    tbStartEvent = {
      {
        "AddNpc",
        1,
        8,
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
        8,
        6,
        "gw",
        "guaiwu4",
        false,
        0,
        0.5,
        9005,
        0.5
      },
      {
        "AddNpc",
        3,
        2,
        6,
        "gw1",
        "guaiwu4",
        false,
        0,
        0.5,
        9005,
        0.5
      },
      {
        "NpcBubbleTalk",
        "gw1",
        "来者何人？居然到风雪山庄撒野！",
        4,
        1,
        1
      }
    },
    tbUnLockEvent = {
      {
        "RaiseEvent",
        "PartnerSay",
        "前面怕是有强敌。",
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
        6043,
        6957
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
        1,
        10,
        0,
        "gw",
        "guaiwu5",
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
        "guaiwu5",
        false,
        32,
        0.5,
        9009,
        0.5
      },
      {
        "AddNpc",
        2,
        10,
        0,
        "gw",
        "guaiwu5",
        false,
        32,
        4,
        9009,
        0.5
      },
      {
        "AddNpc",
        3,
        2,
        0,
        "gw1",
        "guaiwu5",
        false,
        32,
        4,
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
        "兄弟们一起上。",
        4,
        1,
        1
      },
      {
        "NpcBubbleTalk",
        "sl",
        "有两下子，居然闯到此处！",
        4,
        1,
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
      }
    }
  },
  [10] = {
    nTime = 0,
    nNum = 1,
    tbPrelock = {9},
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
        "ChangeFightState",
        0
      },
      {
        "PlayCameraEffect",
        9119
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
        "MoveCameraToPosition",
        0,
        2,
        7685,
        6935,
        2
      },
      {
        "AddNpc",
        5,
        1,
        0,
        "npc",
        "nangongfeiyun",
        false,
        32,
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
        "zhaoshengquan",
        false,
        64,
        0,
        0,
        0
      },
      {
        "RaiseEvent",
        "ShowTaskDialog",
        10,
        1125,
        false,
        2
      }
    },
    tbUnLockEvent = {}
  },
  [11] = {
    nTime = 5,
    nNum = 0,
    tbPrelock = {10},
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
      }
    },
    tbUnLockEvent = {}
  },
  [12] = {
    nTime = 1,
    nNum = 0,
    tbPrelock = {11},
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
        2384,
        1,
        -1,
        -1
      }
    },
    tbUnLockEvent = {}
  },
  [13] = {
    nTime = 1,
    nNum = 0,
    tbPrelock = {12},
    tbStartEvent = {
      {
        "SetNpcProtected",
        "npc1",
        1
      },
      {
        "DoCommonAct",
        "npc",
        3,
        0,
        0,
        0
      }
    },
    tbUnLockEvent = {}
  },
  [14] = {
    nTime = 4,
    nNum = 0,
    tbPrelock = {13},
    tbStartEvent = {
      {
        "NpcBubbleTalk",
        "npc",
        "哎呀，我动不了了！！",
        4,
        0,
        1
      },
      {
        "NpcBubbleTalk",
        "npc1",
        "来人！拿下了！",
        4,
        2,
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
