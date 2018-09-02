Lottery.szOpenTimeFrame = "OpenLevel69"
Lottery.USER_GROUP = 143
Lottery.USER_KEY_WEEK = 1
Lottery.USER_KEY_TICKET = 2
Lottery.NOTIFY_TIME = 70200
Lottery.DRAW_GAP = 604800
Lottery.DRAW_TIME = 588600
Lottery.NEWINFO_TIME_RESULT = 86400
Lottery.NEWINFO_TIME_NOTIFY = 518400
Lottery.NEWINFO_KEY_RESULT = "LotteryResult"
Lottery.NEWINFO_KEY_NOTIFY = "LotteryNotify"
Lottery.VIP_MIN = 6
Lottery.VIP_MAX = 12
Lottery.tbTicketItem = {OpenLevel69 = 6144}
Lottery.tbGiftTicketCount = {
  Daily1 = 1,
  Daily2 = 1,
  Daily3 = 2,
  Weekly = 1,
  Monthly = 1
}
Lottery.tbAwardSetting = {
  OpenLevel69 = {
    [1] = {
      {
        "item",
        1126,
        1
      },
      {
        "item",
        1186,
        1
      }
    },
    [2] = {
      {
        "item",
        2400,
        1
      }
    },
    [3] = {
      {
        "item",
        2169,
        1
      }
    },
    [4] = {
      {
        "item",
        5415,
        1
      }
    },
    [-1] = {
      {
        "item",
        224,
        1
      }
    }
  },
  OpenLevel79 = {
    [1] = {
      {
        "item",
        1127,
        1
      },
      {
        "item",
        1187,
        1
      }
    },
    [2] = {
      {
        "item",
        2400,
        1
      }
    },
    [3] = {
      {
        "item",
        2169,
        1
      }
    },
    [4] = {
      {
        "item",
        5415,
        1
      }
    },
    [-1] = {
      {
        "item",
        224,
        1
      }
    }
  },
  OpenLevel89 = {
    [1] = {
      {
        "item",
        2795,
        1
      }
    },
    [2] = {
      {
        "item",
        6091,
        1
      }
    },
    [3] = {
      {
        "item",
        2169,
        1
      }
    },
    [4] = {
      {
        "item",
        5415,
        1
      }
    },
    [-1] = {
      {
        "item",
        224,
        1
      }
    }
  },
  OpenLevel99 = {
    [1] = {
      {
        "item",
        2795,
        1
      }
    },
    [2] = {
      {
        "item",
        6091,
        1
      }
    },
    [3] = {
      {
        "item",
        2169,
        1
      }
    },
    [4] = {
      {
        "item",
        5415,
        1
      }
    },
    [-1] = {
      {
        "item",
        224,
        1
      }
    }
  },
  OpenLevel109 = {
    [1] = {
      {
        "item",
        2794,
        1
      }
    },
    [2] = {
      {
        "item",
        1396,
        2
      }
    },
    [3] = {
      {
        "item",
        3693,
        1
      }
    },
    [4] = {
      {
        "item",
        5415,
        1
      }
    },
    [-1] = {
      {
        "item",
        224,
        1
      }
    }
  },
  OpenLevel119 = {
    [1] = {
      {
        "item",
        6148,
        1
      }
    },
    [2] = {
      {
        "item",
        1396,
        2
      }
    },
    [3] = {
      {
        "item",
        2169,
        1
      }
    },
    [4] = {
      {
        "item",
        5415,
        1
      }
    },
    [-1] = {
      {
        "item",
        224,
        1
      }
    }
  },
  OpenLevel129 = {
    [1] = {
      {
        "item",
        6148,
        1
      }
    },
    [2] = {
      {
        "item",
        1396,
        2
      }
    },
    [3] = {
      {
        "item",
        2169,
        1
      }
    },
    [4] = {
      {
        "item",
        5415,
        1
      }
    },
    [-1] = {
      {
        "item",
        224,
        1
      }
    }
  }
}
Lottery.tbRankSetting = {
  [1] = {
    nNum = 1,
    szWorldNotify = "「%s」在盟主的赠礼活动中被盟主赏识，被盟主赠予了[FFFE0D]特等礼包[-]，真是鸿运当头啊！",
    szKinNotify = "家族成员「%s」在盟主的赠礼活动中被盟主赏识，被盟主赠予[FFFE0D]特等礼包[-]！"
  },
  [2] = {
    nNum = 3,
    szWorldNotify = "「%s」在盟主的赠礼活动中被盟主赏识，被盟主赠予了[FFFE0D]一等礼包[-]，真是鸿运当头啊！",
    szKinNotify = "家族成员「%s」在盟主的赠礼活动中被盟主赏识，被盟主赠予[FFFE0D]一等礼包[-]！"
  },
  [3] = {
    nNum = 10,
    szWorldNotify = "「%s」在盟主的赠礼活动中被盟主赏识，被盟主赠予了[FFFE0D]二等礼包[-]，真是鸿运当头啊！",
    szKinNotify = "家族成员「%s」在盟主的赠礼活动中被盟主赏识，被盟主赠予[FFFE0D]二等礼包[-]！"
  },
  [4] = {
    nNum = 50,
    szWorldNotify = nil,
    szKinNotify = "家族成员「%s」在盟主的赠礼活动中被盟主赏识，被盟主赠予[FFFE0D]三等礼包[-]！"
  }
}
Lottery.MAX_JOIN_AWARD_COUNT = 3000
function Lottery:GetAwardSetting(nRank)
  local tbSetting = Lottery.tbAwardSetting
  local szTimeFrame = Lib:GetMaxTimeFrame(tbSetting)
  local tbAward = tbSetting[szTimeFrame]
  if not tbAward then
    return
  end
  return tbAward[nRank]
end
function Lottery:GetTicketItem()
  local tbSetting = Lottery.tbTicketItem
  local szTimeFrame = Lib:GetMaxTimeFrame(tbSetting)
  return tbSetting[szTimeFrame]
end
function Lottery:GetAwardTicketCount(szType)
  return self.tbGiftTicketCount[szType]
end
function Lottery:GetDrawTime(nTime)
  nTime = nTime or GetTime()
  local nPassTime = Lib:GetLocalWeekTime(nTime)
  local nLeftTime = self.DRAW_TIME - nPassTime
  if nLeftTime < 0 then
    nLeftTime = nLeftTime + self.DRAW_GAP
  end
  return nTime + nLeftTime
end
function Lottery:GetDrawWeek()
  local nTime = self:GetDrawTime()
  return Lib:GetLocalWeek(nTime)
end
