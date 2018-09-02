local tbFubenSetting = {}
Fuben:SetFubenSetting(45, tbFubenSetting)
tbFubenSetting.szFubenClass = "PersonalFubenBase"
tbFubenSetting.szName = "测试副本"
tbFubenSetting.szNpcPointFile = "Setting/Fuben/PersonalFuben/5_4/NpcPos.tab"
tbFubenSetting.szPathFile = "Setting/Fuben/PersonalFuben/5_4/NpcPath.tab"
tbFubenSetting.tbBeginPoint = {1578, 1632}
tbFubenSetting.nStartDir = 5
tbFubenSetting.ANIMATION = {
  [1] = "Scenes/Maps/yw_luoyegu/Main Camera.controller"
}
tbFubenSetting.NPC = {
  [1] = {
    nTemplate = 868,
    nLevel = 48,
    nSeries = -1
  },
  [2] = {
    nTemplate = 867,
    nLevel = 48,
    nSeries = -1
  },
  [3] = {
    nTemplate = 869,
    nLevel = 48,
    nSeries = -1
  },
  [4] = {
    nTemplate = 870,
    nLevel = 50,
    nSeries = -1
  },
  [5] = {
    nTemplate = 1373,
    nLevel = 50,
    nSeries = 0
  },
  [6] = {
    nTemplate = 747,
    nLevel = 50,
    nSeries = 0
  },
  [7] = {
    nTemplate = 853,
    nLevel = 50,
    nSeries = 0
  },
  [8] = {
    nTemplate = 1385,
    nLevel = 50,
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
        1061,
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
        1918,
        3163
      },
      {
        "AddNpc",
        9,
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
        3782,
        4909
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
        40
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
        2,
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
        3,
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
        "trappos1",
        100
      },
      {
        "SetTargetPos",
        4952,
        3111
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
    nNum = 1,
    tbPrelock = {100},
    tbStartEvent = {
      {
        "TrapUnlock",
        "trap3",
        7
      },
      {
        "SetTargetPos",
        4678,
        2276
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
        4,
        1,
        0,
        "boss",
        "boss",
        false,
        7,
        0,
        0,
        0
      },
      {
        "AddNpc",
        2,
        6,
        0,
        "gw",
        "guaiwu5",
        false,
        7,
        0,
        0,
        0
      },
      {
        "AddNpc",
        3,
        2,
        0,
        "gw",
        "guaiwu6",
        false,
        7,
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
        "SetNpcProtected",
        "gw",
        1
      },
      {
        "SetNpcBloodVisable",
        "boss",
        false,
        0
      },
      {
        "SetNpcBloodVisable",
        "gw",
        false,
        0
      },
      {
        "SetAiActive",
        "boss",
        0
      },
      {
        "SetAiActive",
        "gw",
        0
      },
      {
        "NpcHpUnlock",
        "boss",
        8,
        30
      },
      {
        "AddNpc",
        8,
        1,
        0,
        "npc",
        "dujuan",
        false,
        32,
        0,
        0,
        0
      },
      {
        "SetAiActive",
        "npc",
        0
      }
    },
    tbUnLockEvent = {
      {"DoDeath", "gw"}
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
        4253,
        1871,
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
    nTime = 0,
    nNum = 1,
    tbPrelock = {12},
    tbStartEvent = {
      {
        "RaiseEvent",
        "ShowTaskDialog",
        13,
        1062,
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
    nNum = 1,
    tbPrelock = {13},
    tbStartEvent = {
      {
        "AddNpc",
        5,
        1,
        0,
        "npc1",
        "zhangrumeng",
        false,
        0,
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
        "NpcBubbleTalk",
        "npc1",
        "你……就是那个姚，姚什么东西？",
        4,
        0.5,
        1
      },
      {
        "SetNpcBloodVisable",
        "npc1",
        false,
        0
      },
      {
        "ChangeNpcFightState",
        "npc1",
        0,
        2
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
        "RaiseEvent",
        "ShowTaskDialog",
        15,
        1063,
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
  [16] = {
    nTime = 2,
    nNum = 0,
    tbPrelock = {15},
    tbStartEvent = {
      {
        "SetNpcDir",
        "npc1",
        56
      },
      {
        "NpcBubbleTalk",
        "npc1",
        "姑娘还不走？",
        4,
        0.5,
        1
      }
    },
    tbUnLockEvent = {}
  },
  [17] = {
    nTime = 2,
    nNum = 0,
    tbPrelock = {16},
    tbStartEvent = {
      {
        "SetAiActive",
        "npc",
        1
      },
      {
        "NpcAddBuff",
        "npc",
        2452,
        1,
        100
      },
      {
        "ChangeNpcAi",
        "npc",
        "Move",
        "path2",
        0,
        0,
        0,
        1,
        0
      },
      {
        "NpcBubbleTalk",
        "npc",
        "啊...？哎呀...打架了，快跑啊！",
        3,
        0,
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
        "boss",
        true,
        0
      },
      {
        "SetNpcBloodVisable",
        "gw",
        true,
        0
      },
      {
        "SetNpcProtected",
        "boss",
        0
      },
      {
        "SetNpcProtected",
        "gw",
        0
      },
      {
        "SetAiActive",
        "boss",
        1
      },
      {
        "SetAiActive",
        "gw",
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
        "教训姚公子及其帮手！"
      }
    }
  },
  [18] = {
    nTime = 0.5,
    nNum = 0,
    tbPrelock = {8},
    tbStartEvent = {
      {
        "PlayCameraEffect",
        9119
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
        "SetNpcBloodVisable",
        "npc1",
        false,
        0
      },
      {
        "SetAiActive",
        "boss",
        0
      },
      {
        "SetAiActive",
        "npc1",
        0
      }
    },
    tbUnLockEvent = {
      {
        "SetNpcPos",
        "boss",
        4191,
        1814
      },
      {
        "SetNpcPos",
        "npc1",
        4272,
        1891
      },
      {
        "SetNpcDir",
        "boss",
        0
      },
      {
        "SetNpcDir",
        "npc1",
        32
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
      }
    }
  },
  [19] = {
    nTime = 0,
    nNum = 1,
    tbPrelock = {18},
    tbStartEvent = {
      {
        "MoveCameraToPosition",
        19,
        1,
        4221,
        1883,
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
  [20] = {
    nTime = 4,
    nNum = 0,
    tbPrelock = {19},
    tbStartEvent = {
      {
        "AddNpc",
        6,
        1,
        0,
        "npc2",
        "dugujian",
        false,
        39,
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
        "zhanglinxin",
        false,
        39,
        0,
        0,
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
        "NpcBubbleTalk",
        "boss",
        "大、大爷，不，干、干爹...饶命啊！",
        3,
        0,
        1
      },
      {
        "NpcBubbleTalk",
        "npc1",
        "嘿嘿，好干儿子，你做的坏事已经够你死一千次了，饶你不得！",
        4,
        2,
        1
      }
    },
    tbUnLockEvent = {}
  },
  [21] = {
    nTime = 0,
    nNum = 2,
    tbPrelock = {19},
    tbStartEvent = {
      {
        "ChangeNpcAi",
        "npc2",
        "Move",
        "path3",
        21,
        0,
        0,
        0,
        0
      },
      {
        "ChangeNpcAi",
        "npc3",
        "Move",
        "path4",
        21,
        0,
        0,
        0,
        0
      },
      {
        "NpcBubbleTalk",
        "npc2",
        "且慢！",
        4,
        0,
        1
      }
    },
    tbUnLockEvent = {}
  },
  [22] = {
    nTime = 0,
    nNum = 1,
    tbPrelock = {21},
    tbStartEvent = {
      {
        "ChangeNpcFightState",
        "npc2",
        0,
        0
      },
      {
        "ChangeNpcFightState",
        "npc3",
        0,
        0
      },
      {
        "RaiseEvent",
        "ShowTaskDialog",
        22,
        1099,
        false,
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
