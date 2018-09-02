ArenaBattle.STATE_TRANS = {
  {
    nSeconds = 3,
    szFunc = "ShowTeamInfo",
    szDesc = "对战展示"
  },
  {
    nSeconds = 3,
    szFunc = "StartCountDown",
    szDesc = "对战准备"
  },
  {
    nSeconds = 180,
    szFunc = "StartFight",
    szDesc = "对战开始"
  },
  {
    nSeconds = 3,
    szFunc = "ClcResult",
    szDesc = "对战结算"
  }
}
ArenaBattle.nArenaNum = 4
ArenaBattle.nArenaMapId = 3000
ArenaBattle.nMaxSynData = 100
ArenaBattle.nDeathSkillState = 1520
ArenaBattle.nWaitChooseChallegerTime = 60
ArenaBattle.nCheckApplyTime = 5
ArenaBattle.nArenaManagerNpcId = 1830
ArenaBattle.szArenaManagerNpcBubbleTalkTime = "10"
ArenaBattle.tbForeachType = {ARENA_MAN = 1, CHALLENGER = 2}
ArenaBattle.tbPos = {
  [1] = {
    tbEnterPos = {
      [ArenaBattle.tbForeachType.ARENA_MAN] = {
        {7711, 5167}
      },
      [ArenaBattle.tbForeachType.CHALLENGER] = {
        {9130, 3701}
      }
    },
    tbLeavePos = {
      [ArenaBattle.tbForeachType.ARENA_MAN] = {
        {6449, 5694}
      },
      [ArenaBattle.tbForeachType.CHALLENGER] = {
        {6449, 5694}
      }
    }
  },
  [2] = {
    tbEnterPos = {
      [ArenaBattle.tbForeachType.ARENA_MAN] = {
        {5268, 5176}
      },
      [ArenaBattle.tbForeachType.CHALLENGER] = {
        {3870, 3697}
      }
    },
    tbLeavePos = {
      [ArenaBattle.tbForeachType.ARENA_MAN] = {
        {5690, 6318}
      },
      [ArenaBattle.tbForeachType.CHALLENGER] = {
        {5690, 6318}
      }
    }
  },
  [3] = {
    tbEnterPos = {
      [ArenaBattle.tbForeachType.ARENA_MAN] = {
        {7688, 7406}
      },
      [ArenaBattle.tbForeachType.CHALLENGER] = {
        {9075, 8893}
      }
    },
    tbLeavePos = {
      [ArenaBattle.tbForeachType.ARENA_MAN] = {
        {7159, 6320}
      },
      [ArenaBattle.tbForeachType.CHALLENGER] = {
        {7159, 6320}
      }
    }
  },
  [4] = {
    tbEnterPos = {
      [ArenaBattle.tbForeachType.ARENA_MAN] = {
        {5276, 7432}
      },
      [ArenaBattle.tbForeachType.CHALLENGER] = {
        {3822, 8912}
      }
    },
    tbLeavePos = {
      [ArenaBattle.tbForeachType.ARENA_MAN] = {
        {6464, 6907}
      },
      [ArenaBattle.tbForeachType.CHALLENGER] = {
        {6464, 6907}
      }
    }
  }
}
ArenaBattle.defaultLeavePos = {6626, 6438}
ArenaBattle.defaultEnterMapPos = {6626, 6438}
ArenaBattle.TrapType = {In = 1, Out = 2}
ArenaBattle.TrapData = {
  WatchTrap1 = {nArenaId = 1, nType = 1},
  WatchTrapOut1 = {nArenaId = 1, nType = 2},
  WatchTrap2 = {nArenaId = 2, nType = 1},
  WatchTrapOut2 = {nArenaId = 2, nType = 2},
  WatchTrap3 = {nArenaId = 3, nType = 1},
  WatchTrapOut3 = {nArenaId = 3, nType = 2},
  WatchTrap4 = {nArenaId = 4, nType = 1},
  WatchTrapOut4 = {nArenaId = 4, nType = 2}
}
