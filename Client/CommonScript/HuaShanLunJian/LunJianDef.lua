HuaShanLunJian.tbDef = HuaShanLunJian.tbDef or {}
local tbDef = HuaShanLunJian.tbDef
tbDef.nPlayStateNone = 0
tbDef.nPlayStatePrepare = 1
tbDef.nPlayStateFinals = 2
tbDef.nPlayStateEnd = 3
tbDef.nPlayStateMail = 4
tbDef.nPlayGameStateNone = 1
tbDef.nPlayGameStateStart = 2
tbDef.nPlayGameStateEnd = 3
tbDef.nSaveGroupID = 103
tbDef.nSaveMonth = 1
tbDef.nSaveFightTeamID = 2
tbDef.nSaveFightTeamTime = 3
tbDef.nSaveGuessGroupID = 105
tbDef.nSaveGuessVer = 1
tbDef.nSaveGuessTeam = 2
tbDef.nSaveGuessOneNote = 3
tbDef.nSaveHonorGroupID = 110
tbDef.nSaveHonorValue = 1
tbDef.nTeamTypeName = 1
tbDef.nTeamTypePlayer = 2
tbDef.nTeamTypeValue = 3
tbDef.nTeamTypeTime = 4
tbDef.nTeamTypePlayDay = 5
tbDef.nTeamTypePerCount = 6
tbDef.nTeamTypeServerIdx = 7
tbDef.nTeamTypeServerName = 8
tbDef.nTeamTypeRank = 9
tbDef.nPrePlayTotalTime = 100000
tbDef.nMaxFightTeamVer = 10000
tbDef.nMaxFightTeamCount = 500
tbDef.nUpateDmgTime = 2
tbDef.nGuessTypeTeam = 1
tbDef.nGuessTypeOneNote = 2
tbDef.nSaveGuessingCount = 1500
tbDef.nMaxGuessingVer = 1000
tbDef.nNextPreGamePreMap = 2
tbDef.nPreGamePreMapTime = 5
tbDef.szRankBoard = "LunJianRank"
tbDef.szOpenTimeFrame = "HuaShanLunJian"
tbDef.fPlayerToNpcDmg = 0.1
tbDef.nGameMaxRank = 1002
tbDef.nMinPlayerLevel = 60
tbDef.nFightTeamNameMin = 3
tbDef.nFightTeamNameMax = 6
if version_vn then
  tbDef.bStringLenName = true
  tbDef.nFightTeamNameMin = 4
  tbDef.nFightTeamNameMax = 14
end
if version_th then
  tbDef.nFightTeamNameMin = 6
  tbDef.nFightTeamNameMax = 10
end
tbDef.nFightTeamJoinMemebr = 2
tbDef.nDeathSkillState = 1520
tbDef.nPartnerFightPos = 1
tbDef.nHSLJCrateLimitTime = 14400
tbDef.nChampionshipNewTime = 1296000
tbDef.nHSLJHonorBox = 2000
tbDef.nHSLJHonorBoxItem = 2853
tbDef.nFightTeamShowTitle = {
  [1] = 7006,
  [2] = 7007
}
tbDef.nStatueMapID = 10
tbDef.tbFactionStatueNpc = {
  [1] = 1886,
  [2] = 1887,
  [3] = 1888,
  [4] = 1889,
  [5] = 1890,
  [6] = 1891,
  [7] = 1892,
  [8] = 1893,
  [9] = 2118,
  [10] = 2119,
  [11] = 2221,
  [12] = 2220,
  [13] = 2381,
  [14] = 2382
}
tbDef.tbGameFormat = {
  [1] = {
    szName = "双人赛",
    nFightTeamCount = 2,
    bOpenPartner = true,
    szOpenHSLJMail = "  武林盛会华山论剑开始了！\n    本届华山论剑为[FFFE0D]双人赛[-]赛制，每人可携带一名同伴助阵。各位大侠请带上自己的好友一起战斗，早日成为武林至尊！\n    注意：华山论剑开始后，每周日的门派竞技比赛将被其替代。\n",
    szHSLJPanelContent = "[FFFE0D]本月华山论剑双人赛开始了！[-]\n    双人赛限制战队成员为[FFFE0D]2名[-]，每人可携带一位同伴助战。在准备场可以点击[FFFE0D]队伍[-]旁同伴头像更换助战同伴。\n    预选赛开始每周可获得[FFFE0D]16次[-]比赛次数，最多获得[FFFE0D]32次[-]。每日最多参加[FFFE0D]6场[-]比赛。\n    战队至少参加[FFFE0D]4场[-]预选赛，赛季结束才能获得奖励。\n",
    tbStatueInfo = {
      nTitleID = 7004,
      tbAllPos = {
        [1] = {
          11630,
          15865,
          0
        },
        [2] = {
          11079,
          15330,
          0
        }
      }
    }
  },
  [2] = {
    szName = "三人赛",
    nFightTeamCount = 3,
    bOpenPartner = true,
    szOpenHSLJMail = "  武林盛会华山论剑开始了！\n    本届华山论剑为[FFFE0D]三人赛[-]赛制，每人可携带一名同伴助阵。各位大侠请带上自己的好友一起战斗，早日成为武林至尊！\n    注意：华山论剑开始后，每周日的门派竞技比赛将被其替代。\n",
    szHSLJPanelContent = "[FFFE0D]本月华山论剑三人赛开始了！[-]\n    三人赛限制战队成员为[FFFE0D]3名[-]，每人可携带一位同伴助战。在准备场可以点击[FFFE0D]队伍[-]旁同伴头像更换助战同伴。\n    预选赛开始每周可获得[FFFE0D]16次[-]比赛次数，最多获得[FFFE0D]32次[-]。每日最多参加[FFFE0D]6场[-]比赛。\n    战队至少参加[FFFE0D]4场[-]预选赛，赛季结束才能获得奖励。\n",
    tbStatueInfo = {
      nTitleID = 7004,
      tbAllPos = {
        [1] = {
          11630,
          15865,
          0
        },
        [2] = {
          11079,
          15330,
          0
        },
        [3] = {
          12200,
          15323,
          0
        }
      }
    }
  },
  [3] = {
    szName = "三人决斗赛",
    nFightTeamCount = 3,
    bOpenPartner = false,
    nPartnerPos = 4,
    szPKClass = "PlayDuel",
    nFinalsMapCount = 3,
    szOpenHSLJMail = "  武林盛会华山论剑开始了！\n    本届华山论剑为[FFFE0D]三人决斗[-]赛制，每人可携带所有已上阵同伴助阵。各位大侠请带上自己的好友一起战斗，早日成为武林至尊！\n    注意：华山论剑开始后，每周日的门派竞技比赛将被其替代。\n",
    szHSLJPanelContent = "[FFFE0D]本月华山论剑三人决斗赛开始了！[-]\n    三人决斗赛限制战队成员为[FFFE0D]3名[-]，根据队员编号与其他战队成员分别对战，已上阵同伴均可助战。\n    预选赛开始每周可获得[FFFE0D]16次[-]比赛次数，最多获得[FFFE0D]32次[-]。每日最多参加[FFFE0D]6场[-]比赛。\n    战队至少参加[FFFE0D]4场[-]预选赛，赛季结束才能获得奖励。\n",
    tbStatueInfo = {
      nTitleID = 7004,
      tbAllPos = {
        [1] = {
          11630,
          15865,
          0
        },
        [2] = {
          11079,
          15330,
          0
        },
        [3] = {
          12200,
          15323,
          0
        }
      }
    }
  },
  [4] = {
    szName = "单人赛",
    nFightTeamCount = 1,
    bOpenPartner = false,
    nPartnerPos = 4,
    szOpenHSLJMail = "  武林盛会华山论剑开始了！\n    本届华山论剑为[FFFE0D]单人赛[-]赛制，每人可携带所有已上阵同伴助阵。各位大侠请踊跃参加，早日成为武林至尊！\n    注意：华山论剑开始后，每周日的门派竞技比赛将被其替代。\n",
    szHSLJPanelContent = "[FFFE0D]本月华山论剑单人赛开始了！[-]\n    单人赛限制战队成员为[FFFE0D]1名[-]，已上阵同伴均可助战。\n    预选赛开始每周可获得[FFFE0D]16次[-]比赛次数，最多获得[FFFE0D]32次[-]。每日最多参加[FFFE0D]6场[-]比赛。\n    战队至少参加[FFFE0D]4场[-]预选赛，赛季结束才能获得奖励。\n",
    tbStatueInfo = {
      nTitleID = 7004,
      tbAllPos = {
        [1] = {
          11630,
          15865,
          0
        }
      }
    }
  }
}
tbDef.tbChangeGameFormat = {
  [4] = 1
}
tbDef.tbChampionGuessing = {
  nMinLevel = 60,
  nOneNoteGold = 200,
  nMaxOneNote = 5,
  szAwardMail = "大侠，本次华山论剑冠军为%s战队，您参加了本次华山论剑竞猜并预测正确，获得了%s元宝，请领取附件。"
}
tbDef.tbPrepareGame = {
  szStartWorldNotify = "今日华山论剑将于3分钟后开启报名，请大家提前准备！",
  szPreOpenWorldMsg = "新一轮华山论剑预选赛开始报名了，时间3分钟，请大家尽快通过活动日历报名参加！",
  bShowMSgWhenEnterMatchTime = true,
  nStartMonthDay = 7,
  nStartOpenTime = 36000,
  nPreGamePreMap = 5,
  nStartEndMonthDay = 15,
  nEndMothDay = 27,
  nMaxPlayerJoinCount = 32,
  nPerWeekJoinCount = 16,
  nWinJiFen = 3,
  nFailJiFen = 0,
  nDogfallJiFen = 1,
  nPrepareTime = 180,
  nPlayGameTime = 150,
  nFreeGameTime = 30,
  nKickOutTime = 180,
  nPlayerGameCount = 8,
  nMatchMaxFindCount = 8,
  nPerDayJoinCount = 6,
  nDefWinPercent = 0.5,
  nPrepareMapTID = 1200,
  nPlayMapTID = 1201,
  nMatchEmptyTime = 90,
  tbPlayMapEnterPos = {
    [1] = {1440, 2961},
    [2] = {3697, 2949}
  },
  nShowInfoPlayTeamTime = 8,
  nPlayDelayTime = 3,
  nEndDelayLeaveMap = 8,
  nMaxEnterTeamCount = 50,
  tbAllAward = {
    tbWin = {
      {"BasicExp", 15},
      {
        "item",
        2424,
        2
      }
    },
    tbDogfall = {
      {"BasicExp", 10},
      {
        "item",
        2424,
        1
      }
    },
    tbFail = {
      {"BasicExp", 10},
      {
        "item",
        2424,
        1
      }
    }
  },
  tbAwardMail = {
    szWin = "恭喜阁下所在战队参加华山论剑预选赛，获得了一场胜利，附件奖励请查收！",
    szDogfall = "阁下所在战队参加华山论剑预选赛，与对手旗鼓相当，附件奖励请查收！",
    szFail = "阁下所在战队参加华山论剑预选赛，遗憾败北，附件奖励请查收，以资鼓励！"
  }
}
tbDef.tbFinalsGame = {
  szInformFinals = "恭喜少侠所在战队进入八强，成功晋级。决赛将于[FFFE0D]本月28日21：30[-]举行，请准时参加！",
  nMonthDay = 28,
  nFinalsMapTID = 1202,
  nAudienceMinLevel = 20,
  nEnterPlayerCount = 300,
  nFrontRank = 8,
  nChampionPlan = 2,
  nChampionWinCount = 2,
  nShowInfoPlayTeamTime = 8,
  nPlayDelayTime = 3,
  nEndDelayLeaveMap = 8,
  tbAgainstPlan = {
    [8] = {
      [1] = {
        tbIndex = {1, 8},
        tbPos = {
          [1] = {1529, 6364},
          [2] = {3643, 6346}
        }
      },
      [2] = {
        tbIndex = {4, 5},
        tbPos = {
          [1] = {9104, 6291},
          [2] = {11249, 6279}
        }
      },
      [3] = {
        tbIndex = {2, 7},
        tbPos = {
          [1] = {2505, 3141},
          [2] = {4671, 3141}
        }
      },
      [4] = {
        tbIndex = {3, 6},
        tbPos = {
          [1] = {8617, 3277},
          [2] = {10774, 3254}
        }
      }
    },
    [4] = {
      [1] = {
        tbIndex = {1, 2},
        tbPos = {
          [1] = {1529, 6364},
          [2] = {3643, 6346}
        }
      },
      [2] = {
        tbIndex = {3, 4},
        tbPos = {
          [1] = {9104, 6291},
          [2] = {11249, 6279}
        }
      }
    },
    [2] = {
      [1] = {
        tbIndex = {1, 2},
        tbPos = {
          [1] = {5170, 9474},
          [2] = {7765, 9420}
        }
      }
    }
  },
  tbPlayGameState = {
    [1] = {
      nNextTime = 180,
      szCall = "Freedom",
      szRMsg = "比赛即将开始",
      szWorld = "本届华山论剑冠军争夺战将在[FFFE0D]3分钟[-]后开始，玩家可以进场支持心仪的参赛选手！"
    },
    [2] = {
      nNextTime = 150,
      szCall = "StartPK",
      szRMsg = "八强赛进行中",
      szWorld = "本届华山论剑[FFFE0D]八强赛[-]正式开始了！",
      nPlan = 8,
      tbTeamMsg = {
        tbWin = {
          szMsg = "恭喜您的战队成功晋级华山论剑半决赛！",
          szKinMsg = "恭喜家族成员「%s」所在战队成功晋级华山论剑半决赛！",
          szFriend = "恭喜您的好友「%s」所在战队成功晋级华山论剑半决赛！"
        },
        tbFail = {
          szMsg = "您的战队失利了，没能进入半决赛，再接再厉！"
        }
      }
    },
    [3] = {
      nNextTime = 60,
      szCall = "StopPK",
      szRMsg = "半决赛即将开始"
    },
    [4] = {
      nNextTime = 150,
      szCall = "StartPK",
      szRMsg = "半决赛进行中",
      nPlan = 4,
      szWorld = "本届华山论剑[FFFE0D]半决赛[-]开始了！",
      szEndWorldNotify = "恭喜%s成功晋级本届华山论剑决赛，将在华山之巅一决雌雄！",
      tbTeamMsg = {
        tbWin = {
          szMsg = "恭喜您的战队成功晋级华山论剑决赛！",
          szKinMsg = "恭喜家族成员「%s」所在战队成功晋级华山论剑决赛，冠军荣耀触手可及！",
          szFriend = "恭喜您的好友「%s」所在战队成功晋级华山论剑决赛，冠军荣耀触手可及！"
        },
        tbFail = {
          szMsg = "您的战队失利了，没能进入决赛，再接再厉！"
        }
      }
    },
    [5] = {
      nNextTime = 60,
      szCall = "StopPK",
      szRMsg = "决赛即将开始"
    },
    [6] = {
      nNextTime = 150,
      szCall = "StartPK",
      szRMsg = "第一场决赛进行中",
      szWorld = "本届华山论剑[FFFE0D]决赛第一场[-]开始了，顶尖高手强力碰撞！",
      nPlan = 2
    },
    [7] = {
      nNextTime = 60,
      szCall = "StopPK",
      szRMsg = "第二场决赛即将开始"
    },
    [8] = {
      nNextTime = 150,
      szCall = "StartPK",
      szRMsg = "第二场决赛进行中",
      szWorld = "本届华山论剑[FFFE0D]决赛第二场[-]开始了，冠军或许就要产生了？！",
      nPlan = 2
    },
    [9] = {
      nNextTime = 60,
      szCall = "StopPK",
      szRMsg = "第三场决赛即将开始",
      bCanStop = true
    },
    [10] = {
      nNextTime = 150,
      szCall = "StartPK",
      szRMsg = "第三场决赛进行中",
      nPlan = 2,
      bCanStop = true,
      szWorld = "本届华山论剑[FFFE0D]决赛最后一场[-]开始了，这真是宿命的对决！"
    },
    [11] = {
      nNextTime = 60,
      szCall = "StopPK",
      szRMsg = "比赛结束"
    },
    [12] = {
      nNextTime = 180,
      szCall = "SendAward",
      szRMsg = "离开场地"
    },
    [13] = {
      nNextTime = 300,
      szCall = "KickOutAllPlayer",
      szRMsg = "离开场地"
    }
  }
}
tbDef.szEightRankMail = "  本届华山论剑[FFFE0D]八强[-]已经产生，将于[FFFE0D]本月28日21：30[-]举行最终决赛，届时大家可以进入决赛地图观战。当前已经开启[FFFE0D]冠军竞猜[-]活动，请查看最新消息相应界面！\n"
