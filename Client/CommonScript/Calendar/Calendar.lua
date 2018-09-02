Calendar.Def = {OPEN_LEVEL = 20}
Calendar.GROUP = 72
Calendar.DATA_MONTH = 1
Calendar.DIVISION_HOUR = {
  400,
  600,
  800,
  1000,
  1500
}
Calendar.JOIN_LV = 60
Calendar.tbHonorInfo = {
  Battle = {
    nJoinTimesKey = 11,
    Operation = {
      1,
      0,
      0,
      0
    },
    Iron = {
      4,
      15,
      20,
      50
    },
    Bronze = {
      8,
      8,
      12,
      30
    },
    Silver = {
      16,
      4,
      6,
      15
    },
    Gold = {
      nil,
      2,
      3,
      6
    },
    Platnum = {
      nil,
      nil,
      1,
      3
    }
  },
  TeamBattle = {
    nJoinTimesKey = 21,
    Operation = {1, 1},
    Iron = {2, 4},
    Bronze = {4, 5},
    Silver = {8, 6},
    Gold = {nil, 7},
    Platnum = {nil, 8}
  },
  FactionBattle = {
    nJoinTimesKey = 31,
    Operation = {
      1,
      0,
      1
    },
    Iron = {
      2,
      16,
      1
    },
    Bronze = {3, 16},
    Silver = {4, 8},
    Gold = {nil, 4},
    Platnum = {nil, 1}
  },
  InDifferBattle = {
    nJoinTimesKey = 41,
    Operation = {1, 1},
    Iron = {2, 2},
    Bronze = {4, 3},
    Silver = {8, 4},
    Gold = {nil, 5},
    Platnum = {nil, 6}
  },
  HuaShanLunJian = {
    nJoinTimesKey = 51,
    Operation = {1, 0},
    Iron = {8, 256},
    Bronze = {16, 128},
    Silver = {32, 64},
    Gold = {nil, 32},
    Platnum = {nil, 8}
  },
  QunYingHui = {
    nJoinTimesKey = 61,
    Operation = {1, 1},
    Iron = {2, 2},
    Bronze = {3, 3},
    Silver = {4, 4},
    Gold = {nil, 5},
    Platnum = {nil, 6}
  }
}
Calendar.tbDivisionAward = {
  {
    {"Energy", 5000}
  },
  {
    {"Energy", 6000},
    {
      "Item",
      4462,
      1
    }
  },
  {
    {"Energy", 6000},
    {
      "Item",
      4816,
      1
    }
  },
  {
    {"Energy", 9000},
    {
      "Item",
      4816,
      1
    }
  },
  {
    {"Energy", 6000},
    {
      "Item",
      4817,
      1
    }
  }
}
Calendar.tbDivisionKey = {
  "Iron",
  "Bronze",
  "Silver",
  "Gold",
  "Platnum"
}
Calendar.tbUnopenHonor = {}
function Calendar:GetDivision(pPlayer, szKey, nLastDivision)
  local tbInfo = self.tbHonorInfo[szKey]
  local tbData = {}
  for i = 1, #tbInfo.Operation do
    table.insert(tbData, pPlayer.GetUserValue(self.GROUP, tbInfo.nJoinTimesKey + i - 1))
  end
  for nDivision = #self.tbDivisionKey, 1, -1 do
    if nLastDivision and nDivision <= nLastDivision then
      return nLastDivision
    end
    local tbDivision = tbInfo[self.tbDivisionKey[nDivision]]
    for nIdx = 1, #tbDivision do
      local nData = tbData[nIdx]
      local nRequire = tbDivision[nIdx]
      if nRequire and nData > 0 then
        local bComplete = tbInfo.Operation[nIdx] > 0 and nData >= nRequire or tbInfo.Operation[nIdx] == 0 and nData <= nRequire
        if bComplete then
          return nDivision
        end
      end
    end
  end
  return 0
end
Calendar.tbMsgFormatInfo = {
  "进入前%d名",
  "获得第%d名",
  "登上第%d层",
  "获得卓越以上评价",
  "获得最佳以上评价",
  "单场获胜%d轮",
  "单场%d轮全胜"
}
Calendar.tbActMsgInfo = {
  Battle = {
    tbName = {
      "宋金战场",
      "跨服战场",
      "百人战场"
    },
    Gold = {
      1,
      1,
      1
    },
    Platnum = {
      nil,
      2,
      1
    }
  },
  TeamBattle = {
    tbName = {"通天塔"},
    Gold = {3},
    Platnum = {3}
  },
  FactionBattle = {
    tbName = {
      "门派竞技"
    },
    Gold = {1},
    Platnum = {2}
  },
  InDifferBattle = {
    tbName = {
      "心魔幻境"
    },
    Gold = {4},
    Platnum = {5}
  },
  HuaShanLunJian = {
    tbName = {
      "华山论剑"
    },
    Gold = {1},
    Platnum = {1}
  },
  QunYingHui = {
    tbName = {"群英会"},
    Gold = {6},
    Platnum = {7}
  }
}
Calendar.tbDivisionName = {
  "黑铁",
  "青铜",
  "白银",
  "黄金",
  "白金"
}
