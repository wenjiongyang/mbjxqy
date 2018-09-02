Battle.tbCampSetting = {}
local tbCampSetting = Battle.tbCampSetting
local tbBatttleSetting = Battle.tbAllBattleSetting.BattleMoba
tbCampSetting.RandWildNpcSetting = {
  {
    {
      2436,
      2502,
      2504
    },
    206,
    3760,
    1,
    45
  },
  {
    {
      2435,
      2501,
      2503
    },
    205,
    3761,
    1,
    900
  }
}
tbCampSetting.tbBossNpcTeamplate = {
  2448,
  2495,
  2496
}
tbCampSetting.tbInitFuncs = {
  {
    "AddBuildNpc",
    {
      2440,
      2486,
      2488
    },
    1,
    1,
    9127,
    8443,
    16,
    "WaiTa1",
    "外\n塔",
    "son_waita"
  },
  {
    "AddBuildNpc",
    {
      2440,
      2486,
      2488
    },
    1,
    2,
    7718,
    8441,
    16,
    "NeiTa1",
    "内\n塔",
    "son_neita"
  },
  {
    "AddBuildNpc",
    {
      2443,
      2490,
      2492
    },
    1,
    3,
    6080,
    8435,
    0,
    "DaYin1",
    "大\n营",
    "son_daying"
  },
  {
    "AddBuildNpc",
    {
      2442,
      2487,
      2489
    },
    2,
    1,
    13401,
    8436,
    45,
    "WaiTa2",
    "外\n塔",
    "jin_waita"
  },
  {
    "AddBuildNpc",
    {
      2442,
      2487,
      2489
    },
    2,
    2,
    14821,
    8433,
    45,
    "NeiTa2",
    "内\n塔",
    "jin_neita"
  },
  {
    "AddBuildNpc",
    {
      2444,
      2491,
      2493
    },
    2,
    3,
    16474,
    8439,
    0,
    "DaYin2",
    "大\n营",
    "jin_daying"
  }
}
tbCampSetting.tbNpcCreateWith = {
  [2440] = 2439,
  [2442] = 2441,
  [2486] = 2439,
  [2487] = 2441,
  [2488] = 2439,
  [2489] = 2441
}
tbCampSetting.tbCampActivesSaw = {
  {
    10,
    45,
    "AddCampNpcMovePath",
    {
      2431,
      2478,
      2482
    },
    1,
    6403,
    8443,
    16,
    1
  },
  {
    11,
    45,
    "AddCampNpcMovePath",
    {
      2431,
      2478,
      2482
    },
    1,
    6403,
    8443,
    16,
    1
  },
  {
    12,
    45,
    "AddCampNpcMovePath",
    {
      2431,
      2478,
      2482
    },
    1,
    6403,
    8443,
    16,
    1
  },
  {
    13,
    45,
    "AddCampNpcMovePath",
    {
      2432,
      2479,
      2483
    },
    1,
    6403,
    8443,
    16,
    1
  },
  {
    10,
    45,
    "AddCampNpcMovePath",
    {
      2433,
      2480,
      2484
    },
    2,
    16194,
    8440,
    16,
    2
  },
  {
    11,
    45,
    "AddCampNpcMovePath",
    {
      2433,
      2480,
      2484
    },
    2,
    16194,
    8440,
    16,
    2
  },
  {
    12,
    45,
    "AddCampNpcMovePath",
    {
      2433,
      2480,
      2484
    },
    2,
    16194,
    8440,
    16,
    2
  },
  {
    13,
    45,
    "AddCampNpcMovePath",
    {
      2434,
      2481,
      2485
    },
    2,
    16194,
    8440,
    16,
    2
  },
  {
    60,
    0,
    "AddRandWildNpc",
    60,
    12384,
    10468,
    38
  },
  {
    60,
    0,
    "AddRandWildNpc",
    60,
    10249,
    10387,
    25
  },
  {
    60,
    0,
    "AddRandWildNpc",
    60,
    9827,
    6520,
    13
  },
  {
    60,
    0,
    "AddRandWildNpc",
    60,
    9929,
    5319,
    13
  },
  {
    60,
    0,
    "AddRandWildNpc",
    60,
    12692,
    5643,
    48
  },
  {
    60,
    0,
    "AddRandWildNpc",
    60,
    12809,
    6920,
    48
  },
  {
    180,
    0,
    "AddBossNpc",
    11324,
    5572,
    30
  },
  {
    90,
    90,
    "AddRandBuff",
    10398,
    7096,
    "3001|25;3002|25;3003|25;3004|25;1"
  },
  {
    90,
    90,
    "AddRandBuff",
    11281,
    9337,
    "3001|25;3002|25;3003|25;3004|25;1"
  },
  {
    90,
    90,
    "AddRandBuff",
    12054,
    7021,
    "3001|25;3002|25;3003|25;3004|25;1"
  },
  {
    90,
    90,
    "AddRandBuff",
    11362,
    4678,
    "3001|25;3002|25;3003|25;3004|25;1"
  }
}
tbCampSetting.tbBuffBuilding = {
  3766,
  1,
  10800
}
tbCampSetting.nRevieTime = 15
tbCampSetting.szBuildNpcAiFile = "Setting/Npc/Ai/battle/MobaTower.ini"
tbCampSetting.szBossHelpAiFile = "Setting/Npc/Ai/battle/moba_xiongwang_tuita.ini"
tbCampSetting.tbBuidLowAttackBuff = {
  3767,
  1,
  15
}
tbCampSetting.nBuildDamagePFlagBuffId = 1717
tbCampSetting.nPlayerDamagePFlagBuffId = 3754
tbCampSetting.nBuildDamagePFlagRanage = 800
tbCampSetting.nBossDmgNotChangeInterval = 10
tbCampSetting.nBossLastDmgPercent = 0.15
tbCampSetting.nBossReBorntTime = 180
tbCampSetting.tbBossReBorntNotifyTime = {20, 10}
tbCampSetting.nBossHelpTime = 150
tbCampSetting.tbBossHelpMovePath = {
  {
    6403,
    8443,
    16,
    1
  },
  {
    16194,
    8440,
    45,
    2
  }
}
tbCampSetting.tbFightPowerNpcLevel = {
  {
    nPlyerLevel = 0,
    tbFigPowerLevel = {
      0,
      1200000,
      1500000
    }
  },
  {
    nPlyerLevel = 90,
    tbFigPowerLevel = {
      0,
      1600000,
      2000000
    }
  },
  {
    nPlyerLevel = 100,
    tbFigPowerLevel = {
      0,
      2700000,
      3500000
    }
  },
  {
    nPlyerLevel = 110,
    tbFigPowerLevel = {
      0,
      3300000,
      4500000
    }
  },
  {
    nPlyerLevel = 120,
    tbFigPowerLevel = {
      0,
      4000000,
      5000000
    }
  }
}
local function fnCheck()
  assert(tbCampSetting.tbFightPowerNpcLevel[1].nPlyerLevel == 0)
  local LastV
  local nFPLevels = 3
  for i, v in ipairs(tbCampSetting.tbFightPowerNpcLevel) do
    if LastV then
      assert(v.nPlyerLevel >= LastV.nPlyerLevel, i)
    end
    assert(#v.tbFigPowerLevel == nFPLevels, i)
    assert(v.tbFigPowerLevel[1] <= v.tbFigPowerLevel[2])
    assert(v.tbFigPowerLevel[2] <= v.tbFigPowerLevel[3])
    LastV = v
  end
  local tbBuildNpc = {}
  for i, v in ipairs(tbCampSetting.tbInitFuncs) do
    if v[1] == "AddBuildNpc" then
      tbBuildNpc[v[3]] = tbBuildNpc[v[3]] or {}
      tbBuildNpc[v[3]][v[4]] = 1
      assert(#v[2] == nFPLevels, i)
    end
  end
  assert(#tbBuildNpc[1] == 3)
  assert(#tbBuildNpc[2] == 3)
  local tbCampActives = {}
  local tbSche = Battle.STATE_TRANS[tbBatttleSetting.nUseSchedule]
  local nTotalFightTime = tbSche[2].nSeconds
  for i, v in ipairs(tbCampSetting.tbCampActivesSaw) do
    local nTime1, nTime2 = v[1], v[2]
    local tbRepeat = {nTime1}
    if nTime2 ~= 0 then
      local nRepeatTime = math.floor((nTotalFightTime - nTime1) / nTime2)
      if nRepeatTime > 0 then
        for i2 = 1, nRepeatTime do
          table.insert(tbRepeat, nTime1 + i2 * nTime2)
        end
      end
    end
    for _, v2 in ipairs(tbRepeat) do
      tbCampActives[v2] = tbCampActives[v2] or {}
      table.insert(tbCampActives[v2], {
        unpack(v, 3)
      })
    end
    if v[3] == "AddBossNpc" then
      tbCampSetting.nBossBornTime = nTime1
    end
  end
  tbCampSetting.tbCampActives = tbCampActives
end
tbCampSetting.nTotalFightTime = Battle.STATE_TRANS[tbBatttleSetting.nUseSchedule][2].nSeconds
if MODULE_GAMESERVER then
  fnCheck()
end
