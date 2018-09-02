local tbFubenSetting = {}
Fuben:SetFubenSetting(6002, tbFubenSetting)
tbFubenSetting.szFubenClass = "PersonalFubenBase"
tbFubenSetting.szNpcPointFile = "Setting/Fuben/PersonalFuben/jm_2/NpcPos.tab"
tbFubenSetting.tbBeginPoint = {3310, 4250}
tbFubenSetting.nStartDir = 48
tbFubenSetting.NPC = {
  [1] = {
    nTemplate = 2528,
    nLevel = -1,
    nSeries = 0
  },
  [2] = {
    nTemplate = 2529,
    nLevel = -1,
    nSeries = 0
  }
}
tbFubenSetting.LOCK = {
  [1] = {
    nTime = 1,
    nNum = 0,
    tbPrelock = {},
    tbStartEvent = {
      {
        "BlackMsg",
        "重新探查密洞"
      }
    },
    tbUnLockEvent = {
      {
        "SetTargetPos",
        2261,
        4615
      }
    }
  },
  [2] = {
    nTime = 0,
    nNum = 1,
    tbPrelock = {1},
    tbStartEvent = {
      {
        "TrapUnlock",
        "TrapLock1",
        2
      }
    },
    tbUnLockEvent = {
      {
        "BlackMsg",
        "空气中突然蔓延出一阵诡异的气氛"
      },
      {
        "AddNpc",
        1,
        1,
        3,
        "boss1",
        "boss1",
        false,
        0,
        5,
        9010,
        1
      },
      {
        "AddNpc",
        2,
        1,
        3,
        "boss2",
        "boss2",
        false,
        0,
        5,
        9010,
        1
      }
    }
  },
  [8] = {
    nTime = 1.5,
    nNum = 0,
    tbPrelock = {2},
    tbStartEvent = {},
    tbUnLockEvent = {
      {
        "PlayerBubbleTalk",
        "啊，我头有点晕......"
      }
    }
  },
  [5] = {
    nTime = 7,
    nNum = 0,
    tbPrelock = {2},
    tbStartEvent = {},
    tbUnLockEvent = {
      {
        "PlayerBubbleTalk",
        "难道这就是我的心魔？"
      },
      {
        "SetFubenProgress",
        50,
        "击败心魔"
      },
      {
        "NpcBubbleTalk",
        "boss1",
        "黑暗来了，害怕么！",
        4,
        1,
        1
      },
      {
        "NpcBubbleTalk",
        "boss2",
        "你不相信我嘛？",
        4,
        1,
        1
      },
      {
        "NpcHpUnlock",
        "boss1",
        4,
        40
      },
      {
        "NpcHpUnlock",
        "boss2",
        6,
        40
      }
    }
  },
  [4] = {
    nTime = 0,
    nNum = 1,
    tbPrelock = {5},
    tbStartEvent = {},
    tbUnLockEvent = {
      {
        "NpcBubbleTalk",
        "boss1",
        "前路无数险阻，莫要再前进了啊！",
        4,
        1,
        1
      }
    }
  },
  [6] = {
    nTime = 0,
    nNum = 1,
    tbPrelock = {5},
    tbStartEvent = {},
    tbUnLockEvent = {
      {
        "NpcBubbleTalk",
        "boss2",
        "跟随自己内心的想法，吃喝玩乐岂不美哉？",
        4,
        1,
        1
      }
    }
  },
  [3] = {
    nTime = 0,
    nNum = 2,
    tbPrelock = {2},
    tbStartEvent = {},
    tbUnLockEvent = {
      {
        "SetFubenProgress",
        100,
        "战胜心魔"
      },
      {
        "BlackMsg",
        "经过一番苦斗终于战胜了自己的心魔"
      }
    }
  },
  [7] = {
    nTime = 2.1,
    nNum = 0,
    tbPrelock = {3},
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
      },
      {"GameWin"}
    }
  },
  [18] = {
    nTime = 600,
    nNum = 0,
    tbPrelock = {1},
    tbStartEvent = {
      {
        "RaiseEvent",
        "RegisterTimeoutLock"
      },
      {
        "SetShowTime",
        18
      }
    },
    tbUnLockEvent = {
      {"GameLost"}
    }
  }
}
