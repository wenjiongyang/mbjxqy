Activity.tbDaXueZhang = Activity.tbDaXueZhang or {}
local tbDaXueZhang = Activity.tbDaXueZhang
tbDaXueZhang.tbDef = tbDaXueZhang.tbDef or {}
local tbDef = tbDaXueZhang.tbDef
tbDef.nSaveGroup = 122
tbDef.nSaveJoin = 1
tbDef.nSaveJoinTime = 2
tbDef.nSaveVersion = 6
tbDef.nSaveHonor = 5
tbDef.nMaxTeamVS = 2
tbDef.nUpdateDmgTime = 2
tbDef.tbMatchingCount = {
  [3] = {1},
  [2] = {2, 1},
  [1] = {1}
}
tbDef.nWinType = 1
tbDef.nFailType = 2
tbDef.nActivityVersion = 2
tbDef.nLimitLevel = 20
tbDef.nTeamCount = 4
tbDef.nPrepareMapTID = 1700
tbDef.tbCanJoinMap = {
  [10] = 1,
  [999] = 1
}
tbDef.tbHonorInfo = {
  {nNeed = 2000, nItemID = 3538},
  {nNeed = 1000, nItemID = 3537}
}
tbDef.tbPreMapState = {
  [1] = {
    nNextTime = 300,
    szCall = "Freedom",
    szRMsg = "等待打雪仗开始"
  },
  [2] = {
    nNextTime = 270,
    szCall = "StartPlay",
    szRMsg = "等待打雪仗开始"
  },
  [3] = {
    nNextTime = 270,
    szCall = "StartPlay",
    szRMsg = "等待打雪仗开始"
  },
  [4] = {
    nNextTime = 10,
    szCall = "StartPlay",
    szRMsg = "活动结束请离开"
  },
  [5] = {
    nNextTime = 10,
    szCall = "GameEnd",
    szRMsg = "离开场地"
  }
}
tbDef.nPlayMapTID = 1701
tbDef.tbPlayerAward = {
  tbWin = {
    tbRankAward = {
      [1] = {
        {"BasicExp", 90},
        {"DXZHonor", 3000}
      },
      [2] = {
        {"BasicExp", 75},
        {"DXZHonor", 2500}
      },
      [3] = {
        {"BasicExp", 60},
        {"DXZHonor", 2000}
      },
      [4] = {
        {"BasicExp", 45},
        {"DXZHonor", 1500}
      }
    },
    szMailContent = "恭喜阁下在刚刚结束的打雪仗比赛中，获得了一场胜利，附件为奖励请查收！",
    szMsg = "您的队伍赢得了本次比赛！"
  },
  tbFail = {
    tbRankAward = {
      [1] = {
        {"BasicExp", 75},
        {"DXZHonor", 2500}
      },
      [2] = {
        {"BasicExp", 60},
        {"DXZHonor", 2000}
      },
      [3] = {
        {"BasicExp", 45},
        {"DXZHonor", 1500}
      },
      [4] = {
        {"BasicExp", 30},
        {"DXZHonor", 1000}
      }
    },
    szMailContent = "阁下在刚刚结束的打雪仗比赛中，遗憾败北，附件为奖励请查收，以资鼓励！",
    szMsg = "您失利了，再接再厉！"
  }
}
tbDef.nDogfallJiFen = 10
tbDef.szMatchEmpyMsg = "本轮轮空，没有匹配到对手"
tbDef.szPanelContent = "打雪仗比赛\n·活动时间：2017年12月24日~2018年1月3日\n·单人或组队报名后，变身为打雪仗的小孩，进入特殊地图，进行队伍间的扔雪球大战。\n·比赛共分三轮，给对手造成伤害能增加队伍积分，结束时积分多的队伍获胜。\n·战场上会出现随机的雪人、陷阱及神符，采集后能获得强力技能，一定要善加利用。\n·另外，还要注意躲避年兽放出的强力技能。\n"
tbDef.nPerDayAddCount = 1
tbDef.nMaxJoinCount = 3
tbDef.szTimeUpdateTime = "4:00"
function tbDaXueZhang:GetDXZJoinCount(pPlayer)
  if MODULE_GAMESERVER then
    local nVersion = pPlayer.GetUserValue(tbDef.nSaveGroup, tbDef.nSaveVersion)
    if nVersion ~= tbDef.nActivityVersion and tbDaXueZhang.bHaveDXZ then
      pPlayer.SetUserValue(tbDef.nSaveGroup, tbDef.nSaveJoinTime, 0)
      pPlayer.SetUserValue(tbDef.nSaveGroup, tbDef.nSaveJoin, 0)
      pPlayer.SetUserValue(tbDef.nSaveGroup, tbDef.nSaveVersion, tbDef.nActivityVersion)
      Log("DaXueZhang GetDXZJoinCount nSaveVersion", pPlayer.dwID, tbDef.nActivityVersion)
    end
  end
  local nTime = GetTime()
  local nLastTime = pPlayer.GetUserValue(tbDef.nSaveGroup, tbDef.nSaveJoinTime)
  local nParseTodayTime = Lib:ParseTodayTime(tbDef.szTimeUpdateTime)
  local nUpdateDay = Lib:GetLocalDay(nTime - nParseTodayTime)
  local nUpdateLastDay = 0
  if nLastTime == 0 then
    nUpdateLastDay = nUpdateDay - 1
  else
    nUpdateLastDay = Lib:GetLocalDay(nLastTime - nParseTodayTime)
  end
  local nJoin = pPlayer.GetUserValue(tbDef.nSaveGroup, tbDef.nSaveJoin)
  local nAddDay = math.abs(nUpdateDay - nUpdateLastDay)
  if nAddDay == 0 then
    return nJoin
  end
  if nJoin < tbDef.nMaxJoinCount then
    local nAddResiduTime = nAddDay * tbDef.nPerDayAddCount
    nJoin = nJoin + nAddResiduTime
    nJoin = math.min(nJoin, tbDef.nMaxJoinCount)
  end
  if MODULE_GAMESERVER then
    pPlayer.SetUserValue(tbDef.nSaveGroup, tbDef.nSaveJoinTime, nTime)
    pPlayer.SetUserValue(tbDef.nSaveGroup, tbDef.nSaveJoin, nJoin)
  end
  return nJoin
end
