BiWuZhaoQin.SAVE_GROUP = 125
BiWuZhaoQin.INDEX_LAST_DATE = 1
BiWuZhaoQin.INDEX_ID = 2
BiWuZhaoQin.nOpenZhaoQinCD = 3
BiWuZhaoQin.nCostGold_TypeGlobal = 5000
BiWuZhaoQin.nCostGold_TypeKin = 3000
BiWuZhaoQin.nMinPlayerLevel = 50
BiWuZhaoQin.nTitleId = 6200
BiWuZhaoQin.nTitleNameMin = 3
BiWuZhaoQin.nTitleNameMax = 6
BiWuZhaoQin.nVNTitleNameMin = 4
BiWuZhaoQin.nVNTitleNameMax = 20
BiWuZhaoQin.nTHTitleNameMin = 3
BiWuZhaoQin.nTHTitleNameMax = 16
BiWuZhaoQin.szUiDesc = "·[FFFE0D]活动时间[-]：2017年7月7日10点~2017年7月30日21:30。\n·开启的“比武招亲”比赛，系统会自动排期，每[FFFE0D]周日20：30[-]开启比赛。[FFFE0D]活动期间开启场次有限，排期满后不再接受预定。[-]\n·比赛开始报名时，玩家可以去找燕若雪参加比赛，最多允许[FFFE0D]128人[-]参赛。\n·不参赛的玩家可以从燕若雪处以“[FFFE0D]观战[-]”的形式进入比赛地图。\n·比赛冠军能获得“[FFFE0D]定情信物[-]”，可使用该道具与开启比武招亲的玩家结成情缘关系。\n·比赛为[FFFE0D]无差别、无五行相克[-]形式，角色能力由系统设定。\n"
BiWuZhaoQin.szNewInfomationTitle = "比武招亲"
BiWuZhaoQin.szNewInfomation = "[FFFE0D]比武招亲活动开始了！[-]\n\n[FFFE0D]活动时间：[-]2017年7月7日10点~2017年7月30日21:30\n[FFFE0D]参与等级：[-]50级\n      比武招亲是一场[FFFE0D]无差别、无五行相克[-]的竞技比赛，优胜者可以与发布招亲的人结成情缘关系！\n\n[FFFE0D]1、开启招亲[-]\n      活动期间，[FFFE0D]50级[-]以上玩家可去襄阳找[FFFE0D][url=npc:燕若雪, 631, 10][-]开启“比武招亲”，系统会自动排期，每[FFFE0D]周日20：30[-]开启比赛。\n      开启招亲时可以设定招亲范围（全服或本家族），还可以限制参赛者的最低等级和最低头衔。\n      全服和每个家族每周可以开启一场比武招亲，[FFFE0D]活动期间开启场次有限，排期满后不再接受预定。[-]\n\n[FFFE0D]2、参与招亲比赛[-]\n      比赛开始报名时，50级以上的玩家可以去找[FFFE0D][url=npc:燕若雪, 631, 10][-]参加比武招亲比赛，满足条件可以参加比赛，每场最多允许[FFFE0D]128人[-]参赛。\n      比赛为无差别形式，角色[FFFE0D]能力由系统设定[-]，开打后玩家会成为自己门派对应的无差别角色，[FFFE0D]五行相克[-]效果也被取消了。\n      参赛者两两随机配对战斗，赢者晋级，当剩余参赛人数不大于[FFFE0D]8人[-]后进入决赛阶段。\n      决赛阶段比赛在[FFFE0D]场内擂台[-]上进行，玩家可以进行[FFFE0D]观战[-]。\n\n[FFFE0D]3、情缘关系[-]\n      比赛冠军能获得道具“[FFFE0D]定情信物[-]”，与招亲玩家单独组队使用可以结成情缘关系。\n      关系结成时，可以设定[FFFE0D]情缘称号[-]。\n"
BiWuZhaoQin.tbLimitByTimeFrame = {
  {
    "OpenLevel39",
    7,
    69
  },
  {
    "OpenLevel79",
    8,
    79
  },
  {
    "OpenLevel89",
    9,
    89
  },
  {
    "OpenLevel99",
    11,
    99
  },
  {
    "OpenLevel109",
    11,
    109
  }
}
BiWuZhaoQin.szOpenTime = "20:30"
BiWuZhaoQin.tbOpenWeekDay = {
  [7] = 1
}
BiWuZhaoQin.TYPE_GLOBAL = 1
BiWuZhaoQin.TYPE_KIN = 2
BiWuZhaoQin.Process_Pre = 1
BiWuZhaoQin.Process_Fight = 2
BiWuZhaoQin.Process_Final = 3
BiWuZhaoQin.nDealyLeaveTime = 3
BiWuZhaoQin.FIGHT_TYPE_MAP = 1
BiWuZhaoQin.FIGHT_TYPE_ARENA = 2
BiWuZhaoQin.STATE_TRANS = {
  {
    nSeconds = 2,
    szFunc = "PlayerReady",
    szDesc = "玩家准备"
  },
  {
    nSeconds = 3,
    szFunc = "PlayerAvatar",
    szDesc = "玩家准备"
  },
  {
    nSeconds = 3,
    szFunc = "StartCountDown",
    szDesc = "对战准备"
  },
  {
    nSeconds = 150,
    szFunc = "StartFight",
    szDesc = "对战开始"
  },
  {
    nSeconds = 3,
    szFunc = "ClcResult",
    szDesc = "对战结算"
  }
}
BiWuZhaoQin.tbFightState = {
  NoJoin = 0,
  StandBy = 1,
  Next = 2,
  Out = 3
}
BiWuZhaoQin.tbFightStateDes = {
  [BiWuZhaoQin.tbFightState.NoJoin] = "未参赛",
  [BiWuZhaoQin.tbFightState.StandBy] = "待定",
  [BiWuZhaoQin.tbFightState.Next] = "晋级",
  [BiWuZhaoQin.tbFightState.Out] = "淘汰"
}
BiWuZhaoQin.nPreMapTID = 1301
BiWuZhaoQin.tbPreEnterPos = {
  {6451, 6274},
  {8350, 6296},
  {4420, 6273},
  {6506, 8117},
  {6459, 4490}
}
BiWuZhaoQin.nTaoTaiMapTID = 1300
BiWuZhaoQin.nFinalNum = 8
BiWuZhaoQin.nDeathSkillState = 1520
BiWuZhaoQin.nFirstFightWaitTime = 300
BiWuZhaoQin.nMatchWaitTime = 30
BiWuZhaoQin.nAutoMatchTime = 190
BiWuZhaoQin.nDelayKictoutTime = 300
BiWuZhaoQin.nActNpc = 631
BiWuZhaoQin.nMaxJoin = 128
BiWuZhaoQin.nJoinLevel = 50
BiWuZhaoQin.nBaseExpCount = 15
BiWuZhaoQin.nFirstMatch = 1
BiWuZhaoQin.nFightMatch = 2
BiWuZhaoQin.nFinalMatch = 3
BiWuZhaoQin.nAutoMatch = 4
BiWuZhaoQin.nAutoMatchFinal = 5
BiWuZhaoQin.tbMatchSetting = {
  [BiWuZhaoQin.nFirstMatch] = {
    szUiKey = "BiWuZhaoQinFirst"
  },
  [BiWuZhaoQin.nFightMatch] = {
    szUiKey = "BiWuZhaoQinFight"
  },
  [BiWuZhaoQin.nFinalMatch] = {
    szUiKey = "BiWuZhaoQinFinal"
  },
  [BiWuZhaoQin.nAutoMatch] = {
    szUiKey = "BiWuZhaoQinAuto"
  },
  [BiWuZhaoQin.nAutoMatchFinal] = {
    szUiKey = "BiWuZhaoQinAutoFinal"
  }
}
BiWuZhaoQin.tbProcessDes = {
  [BiWuZhaoQin.Process_Pre] = "报名阶段",
  [BiWuZhaoQin.Process_Fight] = "淘汰赛阶段",
  [BiWuZhaoQin.Process_Final] = "决赛阶段"
}
BiWuZhaoQin.szProcessEndDes = "比武招亲比赛已结束！"
BiWuZhaoQin.tbAvatar = {
  OpenLevel39 = {
    nLevel = 50,
    szEquipKey = "InDiffer",
    szInsetKey = "InDiffer",
    nStrengthLevel = 50
  },
  OpenLevel59 = {
    nLevel = 50,
    szEquipKey = "ZhaoQin59",
    szInsetKey = "ZhaoQin59",
    nStrengthLevel = 50
  },
  OpenLevel69 = {
    nLevel = 60,
    szEquipKey = "ZhaoQin69",
    szInsetKey = "ZhaoQin69",
    nStrengthLevel = 60
  },
  OpenLevel79 = {
    nLevel = 70,
    szEquipKey = "ZhaoQin79",
    szInsetKey = "ZhaoQin79",
    nStrengthLevel = 70
  },
  OpenLevel89 = {
    nLevel = 80,
    szEquipKey = "ZhaoQin89",
    szInsetKey = "ZhaoQin89",
    nStrengthLevel = 80
  },
  OpenLevel99 = {
    nLevel = 90,
    szEquipKey = "ZhaoQin99",
    szInsetKey = "ZhaoQin99",
    nStrengthLevel = 90
  }
}
BiWuZhaoQin.tbDefaultAvatar = {
  nLevel = 50,
  szEquipKey = "InDiffer",
  szInsetKey = "InDiffer",
  nStrengthLevel = 50
}
BiWuZhaoQin.tbTaoTaiEnterPos = {
  {5276, 7432},
  {3822, 8912}
}
BiWuZhaoQin.nItemTID = 3592
BiWuZhaoQin.nArenaNum = 4
BiWuZhaoQin.tbPos = {
  {
    tbEnterPos = {
      {7711, 5167},
      {9130, 3701}
    },
    tbLeavePos = {
      {6449, 5694},
      {6449, 5694}
    }
  },
  {
    tbEnterPos = {
      {5268, 5176},
      {3870, 3697}
    },
    tbLeavePos = {
      {5690, 6318},
      {5690, 6318}
    }
  },
  {
    tbEnterPos = {
      {7688, 7406},
      {9075, 8893}
    },
    tbLeavePos = {
      {7159, 6320},
      {7159, 6320}
    }
  },
  {
    tbEnterPos = {
      {5276, 7432},
      {3822, 8912}
    },
    tbLeavePos = {
      {6464, 6907},
      {6464, 6907}
    }
  }
}
function BiWuZhaoQin:OnSyncLoverInfo(nLoverId)
  self.nLoverId = nLoverId
end
