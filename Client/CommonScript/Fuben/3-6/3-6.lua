local tbFubenSetting = {}
Fuben:SetFubenSetting(35, tbFubenSetting)
tbFubenSetting.szFubenClass = "PersonalFubenBase"
tbFubenSetting.szName = "测试副本"
tbFubenSetting.szNpcPointFile = "Setting/Fuben/PersonalFuben/3_6/NpcPos.tab"
tbFubenSetting.szPathFile = "Setting/Fuben/PersonalFuben/3_6/NpcPath.tab"
tbFubenSetting.tbBeginPoint = {1422, 4915}
tbFubenSetting.nStartDir = 32
tbFubenSetting.ANIMATION = {
  [1] = "Scenes/camera/Camera_chusheng.controller"
}
tbFubenSetting.NPC = {
  [1] = {
    nTemplate = 1486,
    nLevel = 28,
    nSeries = -1
  },
  [2] = {
    nTemplate = 1488,
    nLevel = 28,
    nSeries = -1
  },
  [3] = {
    nTemplate = 1487,
    nLevel = 29,
    nSeries = -1
  },
  [4] = {
    nTemplate = 29,
    nLevel = 28,
    nSeries = -1
  },
  [5] = {
    nTemplate = 1489,
    nLevel = 30,
    nSeries = -1
  },
  [6] = {
    nTemplate = 684,
    nLevel = 30,
    nSeries = 0
  },
  [7] = {
    nTemplate = 104,
    nLevel = 28,
    nSeries = 0
  },
  [8] = {
    nTemplate = 1348,
    nLevel = 30,
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
        1042,
        false
      }
    },
    tbUnLockEvent = {
      {
        "SetShowTime",
        12
      }
    }
  },
  [2] = {
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
        "TrapLock1",
        2
      },
      {
        "AddNpc",
        7,
        2,
        0,
        "wall1",
        "wall_1_1",
        false,
        32
      },
      {
        "SetTargetPos",
        1246,
        2664
      },
      {
        "AddNpc",
        1,
        4,
        3,
        "guaiwu",
        "3_6_1_1",
        false,
        0,
        0,
        0,
        0
      },
      {
        "AddNpc",
        3,
        1,
        3,
        "guaiwu",
        "3_6_1_2",
        false,
        0,
        0,
        0,
        0
      }
    },
    tbUnLockEvent = {
      {
        "ClearTargetPos"
      }
    }
  },
  [3] = {
    nTime = 0,
    nNum = 8,
    tbPrelock = {2},
    tbStartEvent = {
      {
        "AddNpc",
        2,
        3,
        3,
        "guaiwu",
        "3_6_1_2",
        false,
        0,
        1,
        9005,
        0.5
      },
      {
        "NpcBubbleTalk",
        "guaiwu",
        "来者何人，通天塔已归我无忧教，闲杂人等还不速速退去！？",
        4,
        2,
        1
      }
    },
    tbUnLockEvent = {
      {
        "OpenDynamicObstacle",
        "ops1"
      },
      {"DoDeath", "wall1"},
      {
        "AddNpc",
        7,
        2,
        0,
        "wall2",
        "wall_1_2",
        false,
        16
      },
      {
        "SetTargetPos",
        4977,
        2328
      }
    }
  },
  [4] = {
    nTime = 0,
    nNum = 1,
    tbPrelock = {3},
    tbStartEvent = {
      {
        "TrapUnlock",
        "TrapLock2",
        4
      },
      {
        "AddNpc",
        1,
        3,
        5,
        "guaiwu",
        "3_6_2_1",
        1,
        0,
        0,
        9005,
        0.5
      },
      {
        "AddNpc",
        3,
        2,
        5,
        "guaiwu1",
        "3_6_2_2",
        1,
        0,
        0,
        9005,
        0.5
      }
    },
    tbUnLockEvent = {
      {
        "ClearTargetPos"
      },
      {
        "AddNpc",
        2,
        4,
        5,
        "guaiwu",
        "3_6_2_3",
        1,
        0,
        3,
        9005,
        0.5
      },
      {
        "NpcBubbleTalk",
        "guaiwu1",
        "大胆狂徒，真是活的不耐烦了！",
        4,
        1,
        1
      }
    }
  },
  [5] = {
    nTime = 0,
    nNum = 9,
    tbPrelock = {4},
    tbStartEvent = {},
    tbUnLockEvent = {
      {"DoDeath", "wall2"},
      {
        "OpenDynamicObstacle",
        "ops2"
      },
      {
        "OpenDynamicObstacle",
        "ops3"
      },
      {
        "SetTargetPos",
        5476,
        5360
      }
    }
  },
  [6] = {
    nTime = 0,
    nNum = 1,
    tbPrelock = {4},
    tbStartEvent = {
      {
        "TrapUnlock",
        "TrapLock3",
        6
      }
    },
    tbUnLockEvent = {
      {
        "ClearTargetPos"
      },
      {
        "RaiseEvent",
        "CloseDynamicObstacle",
        "ops2"
      },
      {
        "AddNpc",
        7,
        2,
        0,
        "wall2",
        "wall_1_2",
        false,
        16
      }
    }
  },
  [7] = {
    nTime = 0,
    nNum = 10,
    tbPrelock = {6},
    tbStartEvent = {
      {
        "AddNpc",
        1,
        2,
        7,
        "guaiwu",
        "3_6_3_3",
        1,
        0,
        0,
        0,
        0
      },
      {
        "AddNpc",
        2,
        3,
        7,
        "guaiwu",
        "3_6_3_1",
        1,
        0,
        0,
        0,
        0
      },
      {
        "AddNpc",
        3,
        2,
        7,
        "guaiwu",
        "3_6_3_2",
        1,
        0,
        0,
        0,
        0
      },
      {
        "AddNpc",
        4,
        3,
        7,
        "guaiwu",
        "3_6_3_3",
        1,
        0,
        2,
        0,
        0
      },
      {
        "NpcBubbleTalk",
        "guaiwu",
        "擅闯通天塔，杀无赦！",
        4,
        2,
        2
      }
    },
    tbUnLockEvent = {}
  },
  [8] = {
    nTime = 0,
    nNum = 1,
    tbPrelock = {7},
    tbStartEvent = {
      {
        "AddNpc",
        5,
        1,
        8,
        "BOSS",
        "3_6_4",
        2,
        0,
        1,
        9011,
        1
      },
      {
        "NpcBubbleTalk",
        "BOSS",
        "到此为止了！这通天塔可不是你想来能来的地方！",
        4,
        3,
        1
      }
    },
    tbUnLockEvent = {
      {"PauseLock", 12},
      {
        "StopEndTime"
      },
      {
        "SetGameWorldScale",
        0.1
      },
      {
        "CastSkill",
        "guaiwu",
        3,
        1,
        -1,
        -1
      }
    }
  },
  [9] = {
    nTime = 2.1,
    nNum = 0,
    tbPrelock = {8},
    tbStartEvent = {},
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
        "MoveCameraToPosition",
        10,
        2,
        5424,
        6744,
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
        "AddNpc",
        6,
        1,
        0,
        "Start_Npc1",
        "Start_Npc1",
        1,
        32,
        0,
        0,
        0
      },
      {
        "AddNpc",
        8,
        1,
        0,
        "npc",
        "qiangwei",
        false,
        32,
        0,
        0,
        0
      },
      {
        "SetNpcBloodVisable",
        "Start_Npc1",
        false,
        0
      },
      {
        "SetNpcBloodVisable",
        "npc",
        false,
        0
      },
      {
        "ChangeNpcAi",
        "Start_Npc1",
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
        "npc",
        "Move",
        "path2",
        0,
        1,
        1,
        0,
        0
      }
    },
    tbUnLockEvent = {}
  },
  [11] = {
    nTime = 0,
    nNum = 1,
    tbPrelock = {10},
    tbStartEvent = {
      {
        "RaiseEvent",
        "ShowTaskDialog",
        11,
        1043,
        false
      }
    },
    tbUnLockEvent = {
      {
        "SetForbiddenOperation",
        false
      },
      {"GameWin"}
    }
  },
  [12] = {
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
  }
}
