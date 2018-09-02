local tbFubenSetting = {}
Fuben:SetFubenSetting(44, tbFubenSetting)
tbFubenSetting.szFubenClass = "PersonalFubenBase"
tbFubenSetting.szName = "测试副本"
tbFubenSetting.szNpcPointFile = "Setting/Fuben/PersonalFuben/5_3/NpcPos.tab"
tbFubenSetting.szPathFile = "Setting/Fuben/PersonalFuben/5_3/NpcPath.tab"
tbFubenSetting.tbBeginPoint = {7329, 4333}
tbFubenSetting.nStartDir = 32
tbFubenSetting.ANIMATION = {
  [1] = "Scenes/camera/erengu06/erengu06_jszf.controller"
}
tbFubenSetting.NPC = {
  [1] = {
    nTemplate = 865,
    nLevel = 46,
    nSeries = -1
  },
  [2] = {
    nTemplate = 866,
    nLevel = 46,
    nSeries = -1
  },
  [3] = {
    nTemplate = 863,
    nLevel = 48,
    nSeries = -1
  },
  [4] = {
    nTemplate = 747,
    nLevel = 46,
    nSeries = 0
  },
  [5] = {
    nTemplate = 853,
    nLevel = 46,
    nSeries = 0
  },
  [6] = {
    nTemplate = 864,
    nLevel = 46,
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
        1058,
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
        6755,
        3006
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
        "BlackMsg",
        "击败忽然出现的金国探子！"
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
        2935,
        3096
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
        12
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
        2405,
        5779
      },
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
        7,
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
      }
    },
    tbUnLockEvent = {}
  },
  [9] = {
    nTime = 3,
    nNum = 0,
    tbPrelock = {8},
    tbStartEvent = {
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
        "NpcBubbleTalk",
        "boss",
        "两个小鬼给我记着，今天你们乘人之危，下次撞到老夫手里，老夫一定剥了你们的皮！",
        4,
        0.5,
        1
      }
    },
    tbUnLockEvent = {
      {
        "SetAiActive",
        "boss",
        1
      },
      {
        "NpcAddBuff",
        "boss",
        2452,
        1,
        100
      },
      {
        "ChangeNpcAi",
        "boss",
        "Move",
        "path5",
        0,
        0,
        0,
        1,
        0
      },
      {
        "BlackMsg",
        "重伤的南宫灭逃走了！"
      }
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
        2450,
        6867,
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
        6,
        1,
        0,
        "npc",
        "zhangfeng",
        false,
        39,
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
        "ChangeNpcFightState",
        "npc",
        0,
        0.2
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
        "npc2",
        "啊呀，那不是我爹么？",
        4,
        0,
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
        "RaiseEvent",
        "ShowTaskDialog",
        13,
        1059,
        false
      }
    },
    tbUnLockEvent = {
      {
        "ShowAllRepresentObj",
        false
      },
      {
        "SetForbiddenOperation",
        true
      },
      {
        "LeaveAnimationState",
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
        "PlayCameraAnimation",
        1,
        14
      },
      {
        "PlayEffect",
        9136,
        0,
        0,
        0,
        1
      },
      {
        "PlayCameraEffect",
        9137
      },
      {"PlaySound", 6}
    },
    tbUnLockEvent = {
      {
        "DoCommonAct",
        "npc",
        36,
        0,
        1,
        0
      },
      {
        "ShowAllRepresentObj",
        true
      },
      {
        "LeaveAnimationState",
        true
      }
    }
  },
  [100] = {
    nTime = 2,
    nNum = 0,
    tbPrelock = {13},
    tbStartEvent = {},
    tbUnLockEvent = {
      {
        "OpenWindow",
        "BossReferral",
        "张",
        "风",
        "飞剑客"
      }
    }
  },
  [101] = {
    nTime = 0.8,
    nNum = 0,
    tbPrelock = {100},
    tbStartEvent = {},
    tbUnLockEvent = {
      {
        "CloseWindow",
        "BossReferral"
      }
    }
  },
  [102] = {
    nTime = 7.2,
    nNum = 0,
    tbPrelock = {13},
    tbStartEvent = {},
    tbUnLockEvent = {
      {
        "OpenWindow",
        "BossReferral",
        "南",
        "宫灭",
        "天剑客"
      }
    }
  },
  [103] = {
    nTime = 0.8,
    nNum = 0,
    tbPrelock = {102},
    tbStartEvent = {},
    tbUnLockEvent = {
      {
        "CloseWindow",
        "BossReferral"
      }
    }
  },
  [15] = {
    nTime = 4,
    nNum = 0,
    tbPrelock = {14},
    tbStartEvent = {
      {
        "MoveCameraToPosition",
        0,
        1,
        2450,
        6867,
        0
      },
      {
        "NpcBubbleTalk",
        "npc",
        "（身受重伤）你、你……",
        4,
        1,
        1
      },
      {
        "NpcBubbleTalk",
        "boss",
        "哈哈哈哈……咳咳……哼！真……真是不自量力！",
        4,
        2.5,
        1
      }
    },
    tbUnLockEvent = {}
  },
  [16] = {
    nTime = 10,
    nNum = 0,
    tbPrelock = {15},
    tbStartEvent = {
      {
        "ChangeNpcAi",
        "npc1",
        "Move",
        "path1",
        0,
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
        0,
        1,
        1,
        0,
        0
      },
      {
        "NpcBubbleTalk",
        "npc2",
        "爹...爹...",
        3,
        0,
        1
      },
      {
        "NpcBubbleTalk",
        "npc2",
        "南宫灭，我要杀了你，为爹报仇......",
        3,
        2,
        1
      },
      {
        "SetNpcDir",
        "boss",
        32
      },
      {
        "NpcBubbleTalk",
        "boss",
        "刚刚解决了一个老鬼，又来了两个小鬼，哈哈，看来老子今天要大开杀戒了！",
        3,
        4,
        1
      },
      {
        "NpcBubbleTalk",
        "npc1",
        "张姑娘，这老贼已经受了伤，我们合力对付他！",
        3,
        7,
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
        "击败重伤的南宫灭，救下张风！"
      }
    }
  },
  [17] = {
    nTime = 0,
    nNum = 1,
    tbPrelock = {9},
    tbStartEvent = {
      {
        "MoveCameraToPosition",
        17,
        2,
        2563,
        6779,
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
        "ChangeNpcAi",
        "npc1",
        "Move",
        "path3",
        0,
        1,
        1,
        0,
        0
      }
    },
    tbUnLockEvent = {
      {
        "ChangeNpcFightState",
        "npc1",
        0,
        0
      }
    }
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
        1060,
        false
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
  },
  [19] = {
    nTime = 0,
    nNum = 1,
    tbPrelock = {9},
    tbStartEvent = {
      {
        "ChangeNpcAi",
        "npc2",
        "Move",
        "path4",
        19,
        1,
        1,
        0,
        0
      },
      {
        "NpcBubbleTalk",
        "npc2",
        "爹......",
        4,
        0,
        1
      }
    },
    tbUnLockEvent = {
      {
        "ChangeNpcFightState",
        "npc2",
        0,
        0
      },
      {
        "SetNpcDir",
        "npc2",
        53
      },
      {
        "DoCommonAct",
        "npc2",
        37,
        0,
        1,
        0
      }
    }
  }
}
