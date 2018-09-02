if not MODULE_GAMESERVER then
  Activity.LoverRecallAct = Activity.LoverRecallAct or {}
end
local tbAct = MODULE_GAMESERVER and Activity:GetClass("LoverRecallAct") or Activity.LoverRecallAct
tbAct.szFubenClass = "LoverRecallFubenBase"
tbAct.tbActiveAward = {
  [1] = {
    {
      "item",
      4606,
      1
    }
  },
  [2] = {
    {
      "item",
      4606,
      1
    }
  },
  [3] = {
    {
      "item",
      4606,
      1
    }
  },
  [4] = {
    {
      "item",
      4606,
      1
    }
  },
  [5] = {
    {
      "item",
      4606,
      1
    }
  }
}
tbAct.nClueCompose = 5
tbAct.nClueItemTID = 4606
tbAct.nMapItemTID = 4617
tbAct.nJoinLevel = 20
tbAct.nUseMapImityLevel = 5
tbAct.MIN_DISTANCE = 1000
tbAct.nMaxAssistCount = 1
tbAct.nAssistRefreshTime = 14400
tbAct.tbMapInfo = {
  {
    nMapTID = 1611,
    szText = "月影传说·忘忧少女"
  },
  {
    nMapTID = 1612,
    szText = "月影传说·飞龙女侠"
  },
  {
    nMapTID = 1613,
    szText = "月影传说·多情红颜"
  },
  {
    nMapTID = 1614,
    szText = "月影传说·落叶千金"
  },
  {
    nMapTID = 1615,
    szText = "剑侠情缘·名门闺秀"
  },
  {
    nMapTID = 1616,
    szText = "剑侠情缘·天王巾帼"
  },
  {
    nMapTID = 1617,
    szText = "剑侠情缘贰·金国公主"
  }
}
tbAct.tbAssistAward = {
  {"Contrib", 200}
}
tbAct.tbUseMapAward = {
  {
    "Item",
    4683,
    1
  }
}
function tbAct:CheckLevel(pPlayer)
  return pPlayer.nLevel >= self.nJoinLevel
end
if not MODULE_GAMESERVER then
  function tbAct:OnLeaveLoverRecallMap()
    Ui:CloseWindow("HomeScreenFuben")
  end
end
