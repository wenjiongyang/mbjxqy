do return end
Debris.SAVE_GROUP = 10
Debris.KEY_AVOID_BEGIN = 1
Debris.KEY_AVOID_DUR = 2
Debris.AysncTop1From = 4
Debris.AysncTop2From = 14
Debris.AysncKeyUse = 20
Debris.tbSettingLevel = {
  {
    nNum = 3,
    tbItems = {
      1022,
      1032,
      1042,
      1052,
      1062,
      1072,
      1082,
      1092,
      1102,
      1112
    },
    nFlipCardSetIndex = 1,
    nAvoidRobTime = 3600,
    nRobProb = 1.875,
    nValue = 5333
  },
  {
    nNum = 4,
    tbItems = {
      1023,
      1033,
      1043,
      1053,
      1063,
      1073,
      1083,
      1093,
      1103,
      1113
    },
    nFlipCardSetIndex = 2,
    nAvoidRobTime = 7200,
    nRobProb = 1.25,
    nValue = 8000
  },
  {
    nNum = 4,
    tbItems = {
      1024,
      1034,
      1044,
      1054,
      1064,
      1074,
      1084,
      1094,
      1104,
      1114
    },
    nFlipCardSetIndex = 3,
    nAvoidRobTime = 14400,
    nRobProb = 0.625,
    nValue = 16000
  },
  {
    nNum = 5,
    tbItems = {
      1025,
      1035,
      1045,
      1055,
      1065,
      1075,
      1085,
      1095,
      1105,
      1115
    },
    nFlipCardSetIndex = 4,
    nAvoidRobTime = 21600,
    nRobProb = 0.3125,
    nValue = 32000
  },
  {
    nNum = 5,
    tbItems = {
      1026,
      1036,
      1046,
      1056,
      1066,
      1076,
      1086,
      1096,
      1106,
      1116
    },
    nFlipCardSetIndex = 5,
    nAvoidRobTime = 43200,
    nRobProb = 0.1875,
    nValue = 80000
  },
  {
    nNum = 6,
    tbItems = {
      1027,
      1037,
      1047,
      1057,
      1067,
      1077,
      1087,
      1097,
      1107,
      1117
    },
    nFlipCardSetIndex = 6,
    nAvoidRobTime = 86400,
    nRobProb = 0.125,
    nValue = 160000
  }
}
Debris.tbFipCardSetting = {
  {
    {Award = 0, nProb = 0.6},
    {
      Award = {
        "item",
        1021,
        1
      },
      nProb = 0.06
    },
    {
      Award = {
        "item",
        1020,
        1
      },
      nProb = 0.08
    },
    {
      Award = {"Coin", 1000},
      nProb = 0.1
    },
    {
      Award = {"Coin", 500},
      nProb = 0.08
    },
    {
      Award = {"Coin", 300},
      nProb = 0
    },
    {
      Award = {
        "item",
        601,
        1
      },
      nProb = 0.08
    }
  },
  {
    {Award = 0, nProb = 0.6},
    {
      Award = {
        "item",
        1021,
        1
      },
      nProb = 0.08
    },
    {
      Award = {
        "item",
        1020,
        1
      },
      nProb = 0.1
    },
    {
      Award = {"Coin", 1000},
      nProb = 0.08
    },
    {
      Award = {"Coin", 500},
      nProb = 0.06
    },
    {
      Award = {"Coin", 300},
      nProb = 0
    },
    {
      Award = {
        "item",
        601,
        1
      },
      nProb = 0.08
    }
  },
  {
    {Award = 0, nProb = 0.4375},
    {
      Award = {
        "item",
        1021,
        1
      },
      nProb = 0.1
    },
    {
      Award = {
        "item",
        1020,
        1
      },
      nProb = 0.1
    },
    {
      Award = {"Coin", 1000},
      nProb = 0.085
    },
    {
      Award = {"Coin", 500},
      nProb = 0.0888
    },
    {
      Award = {"Coin", 300},
      nProb = 0.0687
    },
    {
      Award = {
        "item",
        601,
        1
      },
      nProb = 0.12
    }
  },
  {
    {Award = 0, nProb = 0.25},
    {
      Award = {
        "item",
        1021,
        1
      },
      nProb = 0.08
    },
    {
      Award = {
        "item",
        1020,
        1
      },
      nProb = 0.15
    },
    {
      Award = {"Coin", 1000},
      nProb = 0.07
    },
    {
      Award = {"Coin", 500},
      nProb = 0.1
    },
    {
      Award = {"Coin", 300},
      nProb = 0.15
    },
    {
      Award = {
        "item",
        601,
        1
      },
      nProb = 0.2
    }
  },
  {
    {Award = 0, nProb = 0.11},
    {
      Award = {
        "item",
        1021,
        1
      },
      nProb = 0.05
    },
    {
      Award = {
        "item",
        1020,
        1
      },
      nProb = 0.2
    },
    {
      Award = {"Coin", 1000},
      nProb = 0.0828
    },
    {
      Award = {"Coin", 500},
      nProb = 0.1502
    },
    {
      Award = {"Coin", 300},
      nProb = 0.207
    },
    {
      Award = {
        "item",
        601,
        1
      },
      nProb = 0.2
    }
  },
  {
    {Award = 0, nProb = 0.075},
    {
      Award = {
        "item",
        1021,
        1
      },
      nProb = 0.04
    },
    {
      Award = {
        "item",
        1020,
        1
      },
      nProb = 0.2
    },
    {
      Award = {"Coin", 1000},
      nProb = 0.12
    },
    {
      Award = {"Coin", 500},
      nProb = 0.1525
    },
    {
      Award = {"Coin", 300},
      nProb = 0.2125
    },
    {
      Award = {
        "item",
        601,
        1
      },
      nProb = 0.2
    }
  }
}
Debris.tbBuyAvoidRobSet = {
  [1] = {
    "item",
    7200,
    1020,
    1
  },
  [2] = {
    "item",
    28800,
    1021,
    1
  },
  [3] = {
    "Gold",
    43200,
    {
      {1, 10},
      {19, 10},
      {20, 20},
      {39, 20},
      {40, 30},
      {59, 30},
      {60, 40},
      {79, 40},
      {80, 50}
    }
  }
}
function Debris:GetProbFactor(nHonorMinus)
  if nHonorMinus <= -2 then
    return 0.4
  elseif nHonorMinus == -1 then
    return 0.6
  elseif nHonorMinus == 0 then
    return 1
  else
    return 2.4
  end
end
Debris.tbItemIndex = {}
local CheckSetingInvalid = function()
  for i, v in ipairs(Debris.tbFipCardSetting) do
    local nLastProb = 0
    for i2, v2 in ipairs(v) do
      v2.nProb = nLastProb + v2.nProb
      nLastProb = v2.nProb
    end
    assert(math.abs(nLastProb - 1) <= 0.001, i .. " but " .. nLastProb)
  end
  for i, v in ipairs(Debris.tbSettingLevel) do
    assert(#v.tbItems <= 10, i)
    assert(v.nNum <= 32, i)
    local tbCard = Debris.tbFipCardSetting[v.nFlipCardSetIndex]
    assert(tbCard, i)
    for i2, v2 in ipairs(v.tbItems) do
      Debris.tbItemIndex[v2] = i
    end
  end
end
CheckSetingInvalid()
local fnGet14HTime = function(nTime)
  local nDay = math.floor(nTime / 86400)
  local nPassTime = nTime - 86400 * nDay - 36000
  nPassTime = nPassTime < 0 and 0 or nPassTime
  return 50400 * nDay + nPassTime
end
function Debris:GetAvoidRobLeftTime(nBeginTime, nDuraTime, nTimeNow)
  nTimeNow = nTimeNow + Lib:GetGMTSec()
  nBeginTime = nBeginTime + Lib:GetGMTSec()
  nTimeNow = fnGet14HTime(nTimeNow)
  nBeginTime = fnGet14HTime(nBeginTime)
  local nLeftTime = nBeginTime + nDuraTime - nTimeNow
  nLeftTime = nLeftTime < 0 and 0 or nLeftTime
  return nLeftTime
end
function Debris:GetAvoidRobEndTime(nBeginTime, nDuraTime)
  local nBeginDay = Lib:GetLocalDay(nBeginTime)
  local nBeginPassSecs = Lib:GetLocalDayTime(nBeginTime)
  nBeginPassSecs = nBeginPassSecs - 36000
  nBeginPassSecs = nBeginPassSecs > 0 and nBeginPassSecs or 0
  nDuraTime = nDuraTime + nBeginPassSecs
  local nDuraDays = math.floor(nDuraTime / 50400)
  nDuraTime = nDuraTime - nDuraDays * 3600 * 14
  return nBeginTime - nBeginPassSecs + nDuraTime + nDuraDays * 3600 * 24
end
function Debris:GetAvoidRobBeginTime(nEndTime, nTimeNow)
  if nEndTime < nTimeNow then
    return 0
  end
  local nEndDay = Lib:GetLocalDay(nEndTime)
  local nEndPassSecs = Lib:GetLocalDayTime(nEndTime)
  nEndPassSecs = nEndPassSecs - 36000
  nEndPassSecs = nEndPassSecs > 0 and nEndPassSecs or 0
  local nToday = Lib:GetLocalDay(nTimeNow)
  local nTodaySecs = Lib:GetLocalDayTime(nTimeNow)
  nTodaySecs = nTodaySecs - 36000
  nTodaySecs = nTodaySecs > 0 and nTodaySecs or 0
  return nEndPassSecs - nTodaySecs + (nEndDay - nToday) * 14 * 3600
end
function Debris:GetItemValue(nItemId)
  local nKind = self.tbItemIndex[nItemId]
  if not nKind then
    return 0
  end
  return self.tbSettingLevel[nKind].nValue
end
