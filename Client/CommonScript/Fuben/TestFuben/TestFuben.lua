local tbFubenSetting = {}
Fuben:SetFubenSetting(6, tbFubenSetting)
tbFubenSetting.szFubenClass = "PersonalFubenBase"
tbFubenSetting.szName = "测试副本"
tbFubenSetting.szNpcPointFile = "Setting/Fuben/PersonalFuben/TestFuben/NpcPos.tab"
tbFubenSetting.szNpcExtAwardPath = "Setting/Fuben/PersonalFuben/TestFuben/ExtNpcAwardInfo.tab"
tbFubenSetting.szPathFile = "Setting/Fuben/TestFuben/NpcPos.tab"
tbFubenSetting.tbBeginPoint = {404, 640}
tbFubenSetting.tbRevivePos = {444, 666}
tbFubenSetting.NUM = {
  NpcIndex1 = {1, 1},
  NpcIndex2 = {2, 2},
  NpcIndex3 = {3, 3},
  NpcIndex4 = {4, 4},
  NpcIndex5 = {5, 5},
  NpcIndex6 = {6, 6},
  NpcNum1 = {3, 6},
  NpcNum2 = {4, 4},
  NpcNum3 = {5, 10},
  NpcNum4 = {5, 5},
  NpcNum5 = {1, 2},
  NpcNum6 = {1, 1},
  LockNum1 = {3, 6},
  LockNum2 = {7, 12},
  LockNum3 = {1, 1}
}
tbFubenSetting.ANIMATION = {
  [1] = "Scenes/Maps/yw_luoyegu/Main Camera.controller"
}
tbFubenSetting.NPC = {
  [1] = {
    nTemplate = 3,
    nLevel = 20,
    nSeries = 1
  },
  [2] = {
    nTemplate = 4,
    nLevel = 20,
    nSeries = 2
  },
  [3] = {
    nTemplate = 5,
    nLevel = 20,
    nSeries = 3
  },
  [4] = {
    nTemplate = 6,
    nLevel = 20,
    nSeries = 4
  },
  [5] = {
    nTemplate = 7,
    nLevel = 1,
    nSeries = 0
  },
  [6] = {
    nTemplate = 12,
    nLevel = 1,
    nSeries = 0
  }
}
tbFubenSetting.TEXT_CONTNET = {
  NpcTalk = {
    [1] = "1111",
    [2] = "2222",
    [3] = "3333"
  }
}
tbFubenSetting.LOCK = {
  [1] = {
    nTime = 5,
    nNum = 0,
    tbPrelock = {},
    tbStartEvent = {},
    tbUnLockEvent = {}
  },
  [2] = {
    nTime = 0,
    nNum = 1,
    tbPrelock = {1},
    tbStartEvent = {
      {
        "SetFubenType",
        "Protect",
        3
      },
      {
        "BlackMsg",
        "战斗开始了！撒！一狗！消灭他们！"
      },
      {
        "ChangeFightState",
        1
      },
      {
        "TrapUnlock",
        "TrapLock2",
        2
      },
      {
        "SetTargetPos",
        118,
        814
      }
    },
    tbUnLockEvent = {
      {
        "RaiseEvent",
        "Log",
        "unlock lock 2"
      },
      {
        "BlackMsg",
        "你身上有八哥！我要对你进行纷争根绝！武力介入开始！"
      },
      {
        "RaiseEvent",
        "AddNpcWithAward",
        "NpcIndex1",
        "NpcNum1",
        3,
        "Protect",
        "1_1_1",
        1
      }
    }
  },
  [3] = {
    nTime = 0,
    nNum = "NpcNum1",
    tbPrelock = {2},
    tbStartEvent = {},
    tbUnLockEvent = {
      {
        "RaiseEvent",
        "Log",
        "unlock lock 3"
      },
      {
        "BlackMsg",
        "西南方传来了一段话：女施主，等等，面试完这个就到你了"
      },
      {
        "RaiseEvent",
        "AddNpcWithAward",
        "NpcIndex2",
        "NpcNum2",
        4,
        "1_1_1",
        "1_1_2",
        2
      }
    }
  },
  [4] = {
    nTime = 0,
    nNum = "NpcNum2",
    tbPrelock = {3},
    tbStartEvent = {},
    tbUnLockEvent = {
      {
        "RaiseEvent",
        "Log",
        "unlock lock 4"
      },
      {
        "BlackMsg",
        "这个应该很简单的吧？这里改一下就好了啊！你惹怒了他们！"
      },
      {
        "RaiseEvent",
        "AddNpcWithAward",
        "NpcIndex3",
        "NpcNum3",
        5,
        "1_1_1",
        "1_1_3",
        3
      }
    }
  },
  [5] = {
    nTime = 0,
    nNum = "NpcNum3",
    tbPrelock = {4},
    tbStartEvent = {},
    tbUnLockEvent = {
      {
        "RaiseEvent",
        "Log",
        "unlock lock 5"
      },
      {
        "BlackMsg",
        "南方忽然传来了一道声音：来人啊！抓住吊起来打！"
      },
      {
        "RaiseEvent",
        "AddNpcWithAward",
        "NpcIndex4",
        "NpcNum4",
        6,
        "1_1_1",
        "1_1_4",
        4
      },
      {
        "ChangeNpcAi",
        "guaiwu",
        "Move",
        "Path1",
        4,
        1,
        1,
        1
      }
    }
  },
  [6] = {
    nTime = 0,
    nNum = "NpcNum4",
    tbPrelock = {5},
    tbStartEvent = {},
    tbUnLockEvent = {
      {
        "BlackMsg",
        "东边忽然出现了一股灵压…这查克拉的感觉…马萨卡…"
      },
      {
        "RaiseEvent",
        "AddNpcWithAward",
        "NpcIndex5",
        "NpcNum5",
        7,
        "1_1_1",
        "1_1_5",
        5
      }
    }
  },
  [7] = {
    nTime = 0,
    nNum = "NpcNum5",
    tbPrelock = {6},
    tbStartEvent = {},
    tbUnLockEvent = {
      {
        "BlackMsg",
        "你的前面忽然出现了奇怪的物体…难道是…"
      },
      {
        "AddNpc",
        "NpcIndex6",
        1,
        8,
        "1_1_1",
        "1_1_5"
      }
    }
  },
  [8] = {
    nTime = 0,
    nNum = 1,
    tbPrelock = {7},
    tbStartEvent = {},
    tbUnLockEvent = {
      {
        "BlackMsg",
        "哈哈哈！天真！那只是本座的小伙伴分身！再来揍我啊！"
      },
      {
        "AddNpc",
        "NpcIndex5",
        "NpcNum5",
        9,
        "1_1_1",
        "1_1_5"
      }
    }
  },
  [9] = {
    nTime = 0,
    nNum = "NpcNum5",
    tbPrelock = {8},
    tbStartEvent = {},
    tbUnLockEvent = {
      {
        "RaiseEvent",
        "ShowCurAward"
      },
      {
        "RaiseEvent",
        "Log",
        "unlock lock 9"
      },
      {"GameWin"}
    }
  },
  [10] = {
    nTime = 300,
    nNum = 0,
    tbPrelock = {1},
    tbStartEvent = {},
    tbUnLockEvent = {
      {
        "RaiseEvent",
        "ShowCurAward"
      },
      {
        "RaiseEvent",
        "Log",
        "unlock lock 10, game lost !!"
      },
      {"GameLost"}
    }
  }
}
