RegressionPrivilege.GROUP = 61
RegressionPrivilege.TOTAL_RECHARGE = 1
RegressionPrivilege.GAINED_MAXLEVEL = 2
RegressionPrivilege.BEGIN_TIME = 3
RegressionPrivilege.ITEM_USED_FLAG = 4
RegressionPrivilege.OUTLINE_DAY = 5
RegressionPrivilege.ACTIVITY_TRIGGER = 6
RegressionPrivilege.OLD_VIPLEVEL = 7
RegressionPrivilege.KINDONATE_TIMES = 8
RegressionPrivilege.KINDONATE_TIMES_MAX = 9
RegressionPrivilege.REFRESHSHOP_TIMES = 10
RegressionPrivilege.REFRESHSHOP_TIMES_MAX = 11
RegressionPrivilege.GIFTBOX_TIMES = 12
RegressionPrivilege.GIFTBOX_TIMES_MAX = 13
RegressionPrivilege.CHUANGONG_TIMES = 14
RegressionPrivilege.CHUANGONG_TIMES_MAX = 15
RegressionPrivilege.XIULIAN_TIMES = 16
RegressionPrivilege.XIULIAN_TIMES_MAX = 17
RegressionPrivilege.MONEYTREE_TIMES = 18
RegressionPrivilege.MONEYTREE_TIMES_MAX = 19
RegressionPrivilege.TIANJIAN_FLAG = 20
RegressionPrivilege.PAUSE_FLAG = 21
RegressionPrivilege.KINSTORE_TIMES = 35
RegressionPrivilege.KINSTORE_TIMES_MAX = 36
RegressionPrivilege.YUANQI_AWARD = 43
RegressionPrivilege.NEW_VERSION = 22
RegressionPrivilege.FREE_GAIN = 23
RegressionPrivilege.HONOR_TITLE = 1
RegressionPrivilege.YINLIANG_CHOUJIANG = 2
RegressionPrivilege.YUANBAO_CHOUJIANG = 3
RegressionPrivilege.XIUWEI = 4
RegressionPrivilege.YUANQI = 5
RegressionPrivilege.WAIZHUANG = 6
RegressionPrivilege.CHONGZHI = 7
RegressionPrivilege.FREE_GAIN_ITEM = {
  {
    "Item",
    2708,
    1
  },
  {
    "Item",
    2760,
    1
  },
  {
    "Item",
    3526,
    1
  },
  {"SkillExp", 360},
  {"Energy", 1},
  {
    "Item",
    4759,
    1
  },
  {
    "Item",
    3564,
    1
  }
}
RegressionPrivilege.DOUBLE_ACT = {
  Boss = {
    nSaveKey = 24,
    nMaxSaveKey = 37,
    nDayPer = 2.5,
    szMsg = "(回归特权额外获得[FFFE0D]%d贡献[-])",
    tbUiInfo = {
      szTitle = "武林盟主奖励翻倍",
      szContent = "武林盟主单人奖励贡献翻倍",
      szBtnContent = "查看活动",
      bCloseMyself = true,
      szBtnUrl = "[url=openwnd:test, CalendarPanel, 1, 1]"
    }
  },
  CommerceTask = {
    nSaveKey = 25,
    nMaxSaveKey = 38,
    nDayPer = 5,
    szMsg = "商会任务回归特权额外奖励",
    tbUiInfo = {
      szTitle = "商会任务奖励翻倍",
      szContent = "商会任务奖励的银两及藏宝图或卷轴奖励加倍",
      szBtnContent = "查看活动",
      bCloseMyself = true,
      szBtnUrl = "[url=openwnd:test, CalendarPanel, 1, 2]"
    }
  },
  HeroChallenge = {
    nSaveKey = 26,
    nMaxSaveKey = 39,
    nDayPer = 0.5,
    szMsg = "英雄挑战回归特权额外奖励",
    tbUiInfo = {
      szTitle = "英雄挑战奖励翻倍",
      szContent = "英雄挑战每次挑战获得两次随机奖励",
      szBtnContent = "查看活动",
      bCloseMyself = true,
      szBtnUrl = "[url=openwnd:test, CalendarPanel, 1, 23]"
    }
  },
  KinGather = {
    nSaveKey = 27,
    nMaxSaveKey = 40,
    nDayPer = 1.25,
    szMsg = "家族答题回归特权额外奖励",
    tbUiInfo = {
      szTitle = "烤火答题奖励翻倍",
      szContent = "家族烤火答题时获得双倍贡献",
      szBtnContent = "查看活动",
      bCloseMyself = true,
      szBtnUrl = "[url=openwnd:test, CalendarPanel, 1, 18]"
    }
  },
  RankBattle = {
    nSaveKey = 28,
    nMaxSaveKey = 41,
    nDayPer = 5,
    szMsg = "武神殿回归特权额外奖励",
    tbUiInfo = {
      szTitle = "武神殿奖励翻倍",
      szContent = "武神殿领取奖励时额外获得一个同样的武神宝箱",
      szBtnContent = "查看活动",
      bCloseMyself = true,
      szBtnUrl = "[url=openwnd:test, CalendarPanel, 1, 9]"
    }
  }
}
RegressionPrivilege.DayTargetEXT = {
  nSaveKey = 29,
  nMaxSaveKey = 42,
  nDayPer = 1,
  tbUiInfo = {
    szTitle = "每日目标额外奖励",
    szContent = "完成每日目标可额外获得大量经验、银两、贡献奖励",
    szBtnContent = "前去查看",
    bCloseMyself = true,
    szBtnUrl = "[url=openwnd:test, CalendarPanel, 3]"
  }
}
RegressionPrivilege.RECHARGE_AWARD = {
  {
    nSaveKey = 30,
    nShowPro = 2,
    nDayPer = 3,
    nRechargeIdx = 1,
    szContent = "$0.99回归元宝礼包"
  },
  {
    nSaveKey = 31,
    nShowPro = 1,
    nDayPer = 30,
    nRechargeIdx = 2,
    szContent = "$4.99回归元宝礼包"
  },
  {
    nSaveKey = 32,
    nShowPro = 5,
    nDayPer = 6,
    nRechargeIdx = 3,
    szContent = "$5.99超值福利礼包"
  },
  {
    nSaveKey = 33,
    nShowPro = 4,
    nDayPer = 2,
    nRechargeIdx = 4,
    szContent = "$3.99超值回归礼包"
  },
  {
    nSaveKey = 34,
    nShowPro = 3,
    nDayPer = 4,
    nRechargeIdx = 5,
    szContent = "$14.99超值豪华礼包"
  }
}
local DAY_SEC = 86400
RegressionPrivilege.Privilege_Time = 30 * DAY_SEC
RegressionPrivilege.Privilege_CD = 60 * DAY_SEC
RegressionPrivilege.Outline_Days = 15
RegressionPrivilege.Max_OutlineDays = 150
RegressionPrivilege.Privilege_Lv = 55
RegressionPrivilege.nClearItemVipLv = 4
RegressionPrivilege.nRechargeVipLv = 5
RegressionPrivilege.LvUp_VipLv = 6
RegressionPrivilege.tbTianJian = {
  nItemTID = 2682,
  nPrice = 1500,
  nOriginalPrice = 5000
}
RegressionPrivilege.LEVEL_GOLD_ITEM_ID = 2854
RegressionPrivilege.LEVEL_GIFT_ITEM_ID = 2855
RegressionPrivilege.tbEnergy = {
  {6, 2000},
  {7, 2200},
  {8, 2800},
  {11, 4000},
  {14, 5200},
  {999, 6000}
}
RegressionPrivilege.tbDayTargetAward = {
  {
    {"BasicExp", 30},
    {"Coin", 2000},
    {"Contrib", 200}
  },
  {
    {"BasicExp", 30},
    {"Coin", 4000},
    {"Contrib", 400}
  },
  {
    {"BasicExp", 30},
    {"Coin", 6000},
    {"Contrib", 600}
  },
  {
    {"BasicExp", 30},
    {"Coin", 8000},
    {"Contrib", 800}
  },
  {
    {"BasicExp", 30},
    {"Coin", 10000},
    {"Contrib", 1000}
  }
}
function RegressionPrivilege:IsCloseMarketStall(pPlayer)
  if not Activity:__IsActInProcessByType("NewServerPrivilege") then
    return
  end
  return self:IsTriggerByAct(pPlayer), "摆摊暂时关闭，请领取老玩家回归特权"
end
function RegressionPrivilege:IsInPrivilegeTime(pPlayer)
  local nPrivilegeEndTime = self:GetPrivilegeTime(pPlayer)
  return nPrivilegeEndTime > GetTime()
end
function RegressionPrivilege:IsNewVersionPlayer(pPlayer)
  return pPlayer.GetUserValue(self.GROUP, self.NEW_VERSION) > 0
end
function RegressionPrivilege:GetPrivilegeTime(pPlayer)
  return pPlayer.GetUserValue(self.GROUP, self.BEGIN_TIME) + self.Privilege_Time
end
function RegressionPrivilege:IsTriggerByAct(pPlayer)
  return pPlayer.GetUserValue(self.GROUP, self.ACTIVITY_TRIGGER) > 0 and 0 >= pPlayer.GetUserValue(self.GROUP, self.ITEM_USED_FLAG)
end
function RegressionPrivilege:GetEnergy(nVip, nOutday)
  local nEnergy = 0
  if GetTimeFrameState("OpenLevel69") ~= 1 then
    return nEnergy
  end
  local nTimeFrameOpenDay = TimeFrame:CalcRealOpenDay("OpenLevel69")
  local nOpenDay = Lib:GetServerOpenDay()
  nOpenDay = math.max(0, nOpenDay - nTimeFrameOpenDay)
  for _, tbInfo in ipairs(self.tbEnergy) do
    if nVip <= tbInfo[1] then
      nEnergy = tbInfo[2]
      break
    end
  end
  nEnergy = nEnergy * 0.6 * math.min(90, nOpenDay, nOutday)
  return math.floor(nEnergy)
end
function RegressionPrivilege:CheckFreeGain(pPlayer, nId)
  local nFreeGain = pPlayer.GetUserValue(self.GROUP, self.FREE_GAIN)
  local nFlag = KLib.GetBit(nFreeGain, nId)
  return nFlag == 0
end
function RegressionPrivilege:CheckFreeGainExt(pPlayer, nId)
  if nId == self.WAIZHUANG then
    if pPlayer.GetUserValue(self.GROUP, self.OLD_VIPLEVEL) < self.nClearItemVipLv then
      return false, string.format("需达到VIP%d才可领取", self.nClearItemVipLv)
    end
  elseif nId == self.YUANQI then
    return pPlayer.GetUserValue(self.GROUP, self.YUANQI_AWARD) > 0, "尚未开放"
  end
  return true
end
function RegressionPrivilege:GetFreeGainAward(pPlayer, nId)
  local tbAward = {
    unpack(self.FREE_GAIN_ITEM[nId])
  }
  local nCountPos = #tbAward
  local nOutlineDay = pPlayer.GetUserValue(self.GROUP, self.OUTLINE_DAY)
  if nId == self.YINLIANG_CHOUJIANG or nId == self.XIUWEI then
    tbAward[nCountPos] = tbAward[nCountPos] * nOutlineDay
  elseif nId == self.YUANBAO_CHOUJIANG then
    tbAward[nCountPos] = tbAward[nCountPos] * math.ceil(nOutlineDay / 3)
  elseif nId == self.YUANQI then
    tbAward[nCountPos] = pPlayer.GetUserValue(self.GROUP, self.YUANQI_AWARD)
  end
  if Player.AwardType[tbAward[1]] == Player.award_type_item then
    tbAward[4] = self:GetPrivilegeTime(pPlayer)
  end
  return {tbAward}
end
function RegressionPrivilege:GetChuanGongTimes(pPlayer)
  if not self:IsInPrivilegeTime(pPlayer) then
    return 0
  end
  if self:IsTriggerByAct(pPlayer) then
    return 0
  end
  return pPlayer.GetUserValue(self.GROUP, self.CHUANGONG_TIMES)
end
function RegressionPrivilege:IsShowGrowInvest(pPlayer)
  if not (self:IsInPrivilegeTime(pPlayer) and self:IsNewVersionPlayer(pPlayer)) or pPlayer.GetVipLevel() < self.nRechargeVipLv then
    return
  end
  local nBeginDay = Lib:GetLocalDay(pPlayer.GetUserValue(self.GROUP, self.BEGIN_TIME))
  if Lib:GetLocalDay() - nBeginDay <= 0 then
    return
  end
  return true
end
Require("CommonScript/Recharge/Recharge.lua")
for _, tbInfo in ipairs(RegressionPrivilege.RECHARGE_AWARD) do
  tbInfo.nMoney = Recharge.tbSettingGroup.BackGift[tbInfo.nRechargeIdx].nMoney
  tbInfo.tbAward = Recharge.tbSettingGroup.BackGift[tbInfo.nRechargeIdx].tbAward
end
if MODULE_GAMESERVER then
  return
end
function RegressionPrivilege:OnLogin()
  MarketStall:RegisterCheckOpen("RegressionPrivilege", function(pPlayer)
    local bRet, szMsg = self:IsCloseMarketStall(pPlayer)
    return not bRet, szMsg
  end)
end
function RegressionPrivilege:OnBuyCallBack()
  UiNotify.OnNotify(UiNotify.emNOTIFY_PRIVILEGE_CALLBACK)
end
function RegressionPrivilege:IsShowButton()
  if self:IsInPrivilegeTime(me) then
    return true
  end
  return Activity:__IsActInProcessByType("NewServerPrivilege") and self:IsTriggerByAct(me)
end
function RegressionPrivilege:GetDayTargetAward(nIdx)
  if not self:IsInPrivilegeTime(me) then
    return
  end
  if not self:IsNewVersionPlayer(me) then
    return
  end
  if me.GetUserValue(self.GROUP, self.DayTargetEXT.nSaveKey) <= 0 then
    return
  end
  local tbAward = self.tbDayTargetAward[nIdx]
  return tbAward
end
