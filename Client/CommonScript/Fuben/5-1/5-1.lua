local tbFubenSetting = {}
Fuben:SetFubenSetting(42, tbFubenSetting)
tbFubenSetting.szFubenClass = "PersonalFubenBase"
tbFubenSetting.szName = "测试副本"
tbFubenSetting.szNpcPointFile = "Setting/Fuben/PersonalFuben/5_1/NpcPos.tab"
tbFubenSetting.szPathFile = "Setting/Fuben/PersonalFuben/5_1/NpcPath.tab"
tbFubenSetting.tbBeginPoint = {2478, 10288}
tbFubenSetting.nStartDir = 28
tbFubenSetting.ANIMATION = {
  [1] = "Scenes/Maps/yw_luoyegu/Main Camera.controller"
}
tbFubenSetting.NPC = {
  [1] = {
    nTemplate = 842,
    nLevel = 42,
    nSeries = -1
  },
  [2] = {
    nTemplate = 843,
    nLevel = 42,
    nSeries = -1
  },
  [3] = {
    nTemplate = 844,
    nLevel = 44,
    nSeries = -1
  },
  [4] = {
    nTemplate = 747,
    nLevel = 44,
    nSeries = 0
  },
  [5] = {
    nTemplate = 853,
    nLevel = 44,
    nSeries = 0
  },
  [6] = {
    nTemplate = 1383,
    nLevel = 44,
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
    nTime = 0.5,
    nNum = 0,
    tbPrelock = {},
    tbStartEvent = {
      {
        "BlackMsg",
        "前方就是武夷派了，前去查探一番罢！"
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
        2959,
        9313
      },
      {
        "AddNpc",
        9,
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
        4,
        4,
        "gw",
        "guaiwu2",
        false,
        0,
        2,
        9005,
        0.5
      },
      {
        "AddNpc",
        1,
        6,
        0,
        "gw",
        "guaiwu2_1",
        false,
        0,
        4,
        0,
        0
      },
      {
        "BlackMsg",
        "击败忽然出现的五色教徒！"
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
    tbPrelock = {4},
    tbStartEvent = {
      {
        "TrapUnlock",
        "trap2",
        5
      },
      {
        "SetTargetPos",
        2996,
        4730
      },
      {
        "BlackMsg",
        "看来五色教早来一步，武夷派怕是凶多吉少了！"
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
        0,
        0
      },
      {
        "AddNpc",
        1,
        8,
        0,
        "gw",
        "guaiwu4_1",
        false,
        0,
        4,
        0,
        0
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
    tbPrelock = {6},
    tbStartEvent = {
      {
        "TrapUnlock",
        "trap3",
        7
      },
      {
        "SetTargetPos",
        7755,
        3310
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
    nNum = 14,
    tbPrelock = {7},
    tbStartEvent = {
      {
        "BlackMsg",
        "胆大妄为的宵小之徒！"
      },
      {
        "AddNpc",
        1,
        4,
        8,
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
        4,
        8,
        "gw",
        "guaiwu6",
        false,
        0,
        2,
        0,
        0
      },
      {
        "AddNpc",
        1,
        6,
        8,
        "gw",
        "guaiwu6_1",
        false,
        0,
        4,
        9005,
        0.5
      }
    },
    tbUnLockEvent = {
      {
        "OpenDynamicObstacle",
        "obs3"
      },
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
        "BlackMsg",
        "前方有古怪，赶紧前去查探！"
      },
      {
        "TrapUnlock",
        "trap4",
        9
      },
      {
        "SetTargetPos",
        7459,
        7991
      }
    },
    tbUnLockEvent = {
      {
        "ClearTargetPos"
      },
      {
        "RaiseEvent",
        "CloseDynamicObstacle",
        "obs4"
      },
      {
        "AddNpc",
        9,
        2,
        0,
        "wall",
        "men4",
        false,
        16
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
        3,
        1,
        10,
        "boss",
        "boss",
        false,
        64,
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
        "SetAiActive",
        "boss",
        0
      }
    },
    tbUnLockEvent = {}
  },
  [11] = {
    nTime = 2.1,
    nNum = 0,
    tbPrelock = {10},
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
  [12] = {
    nTime = 0,
    nNum = 1,
    tbPrelock = {9},
    tbStartEvent = {
      {
        "MoveCameraToPosition",
        12,
        1,
        7496,
        9186,
        10
      },
      {
        "AddNpc",
        6,
        1,
        0,
        "npc",
        "zhanglin",
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
        "SetNpcProtected",
        "npc",
        1
      },
      {
        "SetAiActive",
        "npc",
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
  [13] = {
    nTime = 4,
    nNum = 0,
    tbPrelock = {12},
    tbStartEvent = {
      {
        "NpcBubbleTalk",
        "boss",
        "武夷派大弟子不过如此嘛！",
        4,
        0.5,
        1
      },
      {
        "NpcBubbleTalk",
        "npc",
        "咳咳...要杀要剐，悉听尊便...废话少说！",
        4,
        2,
        1
      }
    },
    tbUnLockEvent = {}
  },
  [14] = {
    nTime = 0,
    nNum = 2,
    tbPrelock = {13},
    tbStartEvent = {
      {
        "AddNpc",
        4,
        1,
        0,
        "npc1",
        "dugujian",
        false,
        64,
        0,
        0,
        0
      },
      {
        "AddNpc",
        5,
        1,
        0,
        "npc2",
        "zhanglinxin",
        false,
        64,
        0,
        0,
        0
      },
      {
        "ChangeNpcAi",
        "npc1",
        "Move",
        "path1",
        14,
        1,
        1,
        0,
        0
      },
      {
        "ChangeNpcAi",
        "npc2",
        "Move",
        "path2",
        14,
        1,
        1,
        0,
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
        "NpcBubbleTalk",
        "npc1",
        "住手！",
        4,
        1,
        1
      }
    },
    tbUnLockEvent = {
      {
        "SetNpcDir",
        "boss",
        32
      }
    }
  },
  [15] = {
    nTime = 17,
    nNum = 1,
    tbPrelock = {14},
    tbStartEvent = {
      {
        "NpcBubbleTalk",
        "boss",
        "来者何人？",
        3,
        0,
        1
      },
      {
        "NpcBubbleTalk",
        "npc1",
        "衡山独孤剑！",
        3,
        2,
        1
      },
      {
        "NpcBubbleTalk",
        "boss",
        "怎么？那个刘轻舟不是死了吗？衡山派还在？",
        3,
        4,
        1
      },
      {
        "NpcBubbleTalk",
        "npc1",
        "（大怒）是你们害我师傅？！今日...又来武夷派，有何阴谋？",
        3,
        7,
        1
      },
      {
        "NpcBubbleTalk",
        "boss",
        "哈哈哈！乳臭未干的小子懂什么？现在离开还来得及！",
        3,
        10,
        1
      },
      {
        "NpcBubbleTalk",
        "npc2",
        "独孤大哥，此人看来是不会说实话了，先救下张兄再说！",
        3,
        13,
        1
      },
      {
        "NpcBubbleTalk",
        "boss",
        "找死！",
        3,
        16,
        1
      }
    },
    tbUnLockEvent = {
      {
        "SetNpcBloodVisable",
        "npc1",
        true,
        0
      },
      {
        "SetNpcBloodVisable",
        "npc2",
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
        "击败五色教头目，救下张林！"
      }
    }
  },
  [16] = {
    nTime = 0,
    nNum = 1,
    tbPrelock = {11},
    tbStartEvent = {
      {
        "RaiseEvent",
        "ShowTaskDialog",
        16,
        1098,
        false
      }
    },
    tbUnLockEvent = {
      {"GameWin"}
    }
  }
}
