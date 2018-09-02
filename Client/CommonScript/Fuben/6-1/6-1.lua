local tbFubenSetting = {}
Fuben:SetFubenSetting(47, tbFubenSetting)
tbFubenSetting.szFubenClass = "PersonalFubenBase"
tbFubenSetting.szName = "测试副本"
tbFubenSetting.szNpcPointFile = "Setting/Fuben/PersonalFuben/6_1/NpcPos.tab"
tbFubenSetting.szPathFile = "Setting/Fuben/PersonalFuben/6_1/NpcPath.tab"
tbFubenSetting.tbBeginPoint = {3239, 4234}
tbFubenSetting.nStartDir = 48
tbFubenSetting.ANIMATION = {
  [1] = "Scenes/Maps/yw_luoyegu/Main Camera.controller"
}
tbFubenSetting.NPC = {
  [1] = {
    nTemplate = 1394,
    nLevel = -1,
    nSeries = -1
  },
  [2] = {
    nTemplate = 1395,
    nLevel = -1,
    nSeries = -1
  },
  [3] = {
    nTemplate = 1396,
    nLevel = -1,
    nSeries = -1
  },
  [4] = {
    nTemplate = 747,
    nLevel = -1,
    nSeries = 0
  },
  [5] = {
    nTemplate = 853,
    nLevel = -1,
    nSeries = 0
  },
  [6] = {
    nTemplate = 1397,
    nLevel = -1,
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
        1066,
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
        2419,
        4381
      },
      {
        "AddNpc",
        9,
        1,
        0,
        "wall",
        "men1",
        false,
        19
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
        "没想到这林对儿带了这么多手下！"
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
        1610,
        2083
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
        30
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
      }
    },
    tbUnLockEvent = {
      {
        "OpenDynamicObstacle",
        "obs2"
      },
      {"DoDeath", "wall"},
      {
        "BlackMsg",
        "居然还有高手，林对儿在此处干嘛？"
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
      },
      {
        "SetTargetPos",
        4164,
        2377
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
        3,
        1,
        0,
        "boss",
        "boss",
        false,
        60,
        0,
        0,
        0
      },
      {
        "NpcHpUnlock",
        "boss",
        8,
        30
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
      },
      {
        "ChangeNpcFightState",
        "boss",
        0,
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
        4758,
        2147,
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
        36,
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
        28,
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
        "ruhua",
        false,
        52,
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
        "ChangeNpcFightState",
        "npc2",
        0,
        0
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
        1067,
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
    nTime = 2,
    nNum = 0,
    tbPrelock = {13},
    tbStartEvent = {
      {
        "NpcAddBuff",
        "npc2",
        2452,
        1,
        100
      },
      {
        "ChangeNpcAi",
        "npc2",
        "Move",
        "path1",
        0,
        0,
        0,
        1,
        0
      },
      {
        "NpcBubbleTalk",
        "npc2",
        "哎呀！打起来啦，快跑啊！",
        4,
        0,
        1
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
        "击败华山派林对儿"
      }
    }
  },
  [15] = {
    nTime = 0,
    nNum = 1,
    tbPrelock = {8},
    tbStartEvent = {
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
        "boss",
        false,
        0
      },
      {
        "SetNpcProtected",
        "boss",
        1
      },
      {
        "SetAiActive",
        "boss",
        0
      },
      {
        "RaiseEvent",
        "ShowTaskDialog",
        15,
        1068,
        false
      }
    },
    tbUnLockEvent = {
      {"GameWin"}
    }
  }
}
