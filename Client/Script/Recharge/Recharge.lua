Recharge.PAGE_ID_SHOP = 2
Recharge.PAGE_ID_INVEST = 3
Recharge.PAGE_ID_GIFT = 4
Recharge.PAGE_ID_DAILY_GIFT = 5
Recharge.PAGE_ID_YEAR_GIFT = 6
Recharge.PAGE_ID_DIR_ENHANCE = 7
Recharge.CLICK_ID_INVEST = 1
Recharge.CLICK_ID_GIFT_MON_RE = 2
Recharge.CLICK_ID_GIFT_WEEK_RE = 3
Recharge.CLICK_ID_GIFT_MON_NEW = 4
Recharge.CLICK_ID_GIFT_WEEK_NEW = 5
Recharge.CLICK_ID_GIFT_ONE = 6
Recharge.CLICK_ID_GIFT_THREE = 7
Recharge.CLICK_ID_GIFT_SIX = 8
Recharge.CLICK_ID_SHOP_WEEK = 201
Recharge.CLICK_ID_SHOP_MONTH = 202
Recharge.CLICK_ID_GOLD_FROM = 100
Recharge.CLICK_ID_GIFT_YEAR_FROM = 300
Recharge.CLICK_ID_DIR_ENHANCE_FROM = 400
function Recharge:OnNewVipLevel(nNewVipLevel)
  if not nNewVipLevel then
    local nOldVipLevel = me.GetVipLevel()
    nNewVipLevel = me.GetVipLevel(true)
    if nOldVipLevel == nNewVipLevel then
      return
    end
  end
  me.GetVipLevel(true)
  local function fnConfirm()
    Ui:OpenWindow("CommonShop", "Recharge", "Vip", nNewVipLevel)
  end
  me.MsgBox(string.format("恭喜侠士成为【剑侠尊享%d】", nNewVipLevel), {
    {
      "查看特权",
      fnConfirm
    },
    {"取消"}
  })
  self:CheckCanBuyVipAward()
  UiNotify.OnNotify(UiNotify.emNOTIFY_CHANGE_VIP_LEVEL)
  UiNotify.OnNotify(UiNotify.emNOTIFY_RECHARGE_PANEL, true)
  Sdk:OnVipLevelChanged()
  ChatMgr.ChatDecorate:OnVipChange(nNewVipLevel)
end
function Recharge:OnBuyVipAwardScucess()
  me.CenterMsg("购买特权礼包成功")
  self:CheckCanBuyVipAward()
  UiNotify.OnNotify(UiNotify.emNOTIFY_RECHARGE_PANEL)
end
function Recharge:OnRechargeGoldScucess(nRechareRMB, tbAward)
  local szMsg
  local nGetGold = Recharge:GetGoldNumFromAward(tbAward)
  if Sdk:IsMsdk() then
    szMsg = string.format("成功充值%d元宝", self.RATE * nRechareRMB + nGetGold)
  else
    szMsg = string.format("成功充值%d元宝", nGetGold)
  end
  if szMsg then
    me.CenterMsg(szMsg, true)
  end
  UiNotify.OnNotify(UiNotify.emNOTIFY_RECHARGE_PANEL, true)
end
function Recharge:BuyCardScucess()
  me.CenterMsg("购买成功")
  Recharge:CheckRedPoint()
  UiNotify.OnNotify(UiNotify.emNOTIFY_RECHARGE_PANEL, true)
  UiNotify.OnNotify(UiNotify.emNOTIFY_WELFARE_UPDATE, "RechargeGift")
  UiNotify.OnNotify(UiNotify.emNOTIFY_WELFARE_UPDATE, "DailyRechargeGift")
  UiNotify.OnNotify(UiNotify.emNOTIFY_WELFARE_UPDATE, "NewYearBuyGift")
end
function Recharge:CheckCanBuyVipAward()
  if not Recharge.IS_OPEN then
    return
  end
  if me.nLevel < Shop.SHOW_LEVEL then
    Ui:ClearRedPointNotify("VipAward")
    return
  end
  if Client:GetFlag("ShowRedPoint") == Lib:GetLocalDay() then
    Ui:ClearRedPointNotify("VipAward")
    return
  end
  local nMyVipLevel = me.GetVipLevel()
  local nBuyedVal = me.GetUserValue(self.SAVE_GROUP, self.KEY_VIP_AWARD)
  local bCanBuy = false
  for i = 0, nMyVipLevel do
    local nBuydeBit = KLib.GetBit(nBuyedVal, i + 1)
    if nBuydeBit == 0 then
      bCanBuy = true
      Ui:SetRedPointNotify("VipAward" .. i)
    end
  end
  if not bCanBuy then
    Ui:ClearRedPointNotify("VipAward")
  end
end
function Recharge:OnBuyGrowInvestScuess()
  me.CenterMsg("购买一本万利成功")
  self:CheckRedPoint()
  UiNotify.OnNotify(UiNotify.emNOTIFY_WELFARE_UPDATE, "GrowInvest")
end
function Recharge:OnTakedGrowInvestAward()
  self:CheckRedPoint()
  UiNotify.OnNotify(UiNotify.emNOTIFY_WELFARE_UPDATE, "GrowInvest")
end
function Recharge:OnTakeCardAwardScuess()
  self:CheckRedPoint()
  UiNotify.OnNotify(UiNotify.emNOTIFY_WELFARE_UPDATE, "RechargeGift")
end
function Recharge:_IsShowGrowInvest(nGroupIndex)
  if not Recharge.tbSettingGroup.GrowInvest[nGroupIndex] then
    return
  end
  if me.nLevel < Recharge.tbGrowInvestGroup[nGroupIndex][1].nLevel then
    return
  end
  if me.GetUserValue(Recharge.SAVE_GROUP, Recharge.tbKeyGrowBuyed[nGroupIndex]) == 0 then
    return true
  end
  local tbGetBit = KLib.GetBitTB(me.GetUserValue(self.SAVE_GROUP, self.tbKeyGrowTaked[nGroupIndex]))
  for i, v in ipairs(self.tbGrowInvestGroup[nGroupIndex]) do
    if tbGetBit[i] == 0 then
      return true
    end
  end
end
function Recharge:IsShowGrowInvestAct()
  local nGroupIndex = 4
  if Activity:__IsActInProcessByType("RechargeNewyearGrowInvest") then
    if self:_IsShowGrowInvest(nGroupIndex) then
      return true
    end
  elseif me.GetUserValue(Recharge.SAVE_GROUP, Recharge.tbKeyGrowBuyed[nGroupIndex]) == 1 then
    local tbGetBit = KLib.GetBitTB(me.GetUserValue(self.SAVE_GROUP, self.tbKeyGrowTaked[nGroupIndex]))
    for i, v in ipairs(self.tbGrowInvestGroup[nGroupIndex]) do
      if tbGetBit[i] == 0 then
        return true
      end
    end
  end
  return false
end
function Recharge:IsShowGrowInvestBack()
  local nGroupIndex = 7
  if RegressionPrivilege:IsShowGrowInvest(me) then
    if self:_IsShowGrowInvest(nGroupIndex) then
      return true
    end
  elseif me.GetUserValue(Recharge.SAVE_GROUP, Recharge.tbKeyGrowBuyed[nGroupIndex]) == 1 then
    local tbGetBit = KLib.GetBitTB(me.GetUserValue(self.SAVE_GROUP, self.tbKeyGrowTaked[nGroupIndex]))
    for i, v in ipairs(self.tbGrowInvestGroup[nGroupIndex]) do
      if tbGetBit[i] == 0 then
        return true
      end
    end
  end
  return false
end
function Recharge:IsShowGrowInvest()
  if not self.IS_OPEN_INVEST then
    return false
  end
  if not self:IsShowProGroupInPanel("GrowInvest", "GrowInvest") then
    return false
  end
  if self:_IsShowGrowInvest(1) then
    return true
  end
  if self:_IsShowGrowInvest(2) then
    return true
  end
  if self:_IsShowGrowInvest(3) then
    return true
  end
  if self:IsShowGrowInvestAct() then
    return true, true
  end
  if self:_IsShowGrowInvest(5) then
    return true
  end
  if self:_IsShowGrowInvest(6) then
    return true
  end
  if self:IsShowGrowInvestBack() then
    return true
  end
  return false
end
function Recharge:_IsRedPointInvestActive(nIndex)
  if not self.tbKeyGrowBuyed[nIndex] then
    return false
  end
  local nBuyedVal = me.GetUserValue(self.SAVE_GROUP, self.tbKeyGrowBuyed[nIndex])
  if nBuyedVal == 0 then
    if nIndex >= 2 and not Client:GetFlag("hasViewRechargeInvest" .. nIndex) then
      if Recharge:GetAutoShowGrowInvest() == nIndex then
        return true
      elseif nIndex == 4 and Recharge:IsShowGrowInvestAct() then
        return true
      elseif nIndex == 7 and RegressionPrivilege:IsShowGrowInvest(me) then
        return true
      end
    end
    return false
  end
  local nMyLevel = me.nLevel
  local nTaked = me.GetUserValue(self.SAVE_GROUP, self.tbKeyGrowTaked[nIndex])
  local tbGrowInvestSetting = self.tbGrowInvestGroup[nIndex]
  for i, v in ipairs(tbGrowInvestSetting) do
    if nMyLevel < v.nLevel then
      return false
    end
    local nTakeeBit = KLib.GetBit(nTaked, i)
    if nTakeeBit == 0 then
      if v.nDay and (nIndex == 4 or nIndex == 7) then
        local nSaveKey = Recharge:GetDayInvestTaskedDayKey(nIndex)
        if not nSaveKey then
          return false
        end
        local nTakedDay = me.GetUserValue(self.SAVE_GROUP, nSaveKey)
        local nRefreshDay = Recharge:GetRefreshDay()
        local nNowMinus = nRefreshDay - nTakedDay
        if nNowMinus > 0 then
          if i == 1 then
            do return true end
            break
          end
          local nDayMinus = v.nDay - tbGrowInvestSetting[i - 1].nDay
          if nNowMinus >= nDayMinus then
            return true
          end
        end
        break
      else
        return true
      end
    end
  end
  return false
end
function Recharge:IsRedPointInvestActive()
  if not self.IS_OPEN_INVEST then
    return false
  end
  for i, v in ipairs(self.tbGrowInvestGroup) do
    if self:_IsRedPointInvestActive(i) then
      return true, i
    end
  end
  return false
end
function Recharge:CheckRedPoint()
  local bLevelEnough = me.nLevel >= WelfareActivity:GetActivityOpenLevel("GrowInvest")
  local bSetRP = self:IsRedPointInvestActive()
  if bLevelEnough and bSetRP then
    Ui:SetRedPointNotify("Activity_GrowInvest")
  else
    Ui:ClearRedPointNotify("Activity_GrowInvest")
  end
  local nMonState = Recharge:GetMonthCardAwardState()
  if nMonState == 1 then
    Ui:SetRedPointNotify("MonthCarad")
  else
    Ui:ClearRedPointNotify("MonthCarad")
  end
  local nWeekState = Recharge:GetWeekCardAwardState()
  if nWeekState == 1 then
    Ui:SetRedPointNotify("WeekCard")
  else
    Ui:ClearRedPointNotify("WeekCard")
  end
  local nToday = Lib:GetLocalDay(GetTime() - 14400)
  local nViewDay = Client:GetFlag("hasViewRechargeGift") or 0
  local bShowBuyRed = Recharge:CanTakeOneDayCardPlusAward(me)
  if not bShowBuyRed and nToday ~= nViewDay and Recharge.tbSettingGroup.DayGift then
    local nYestDay = nToday - 1
    for i, v in ipairs(Recharge.tbSettingGroup.DayGift) do
      local nCardBuyDay = me.GetUserValue(Recharge.SAVE_GROUP, v.nBuyDayKey)
      if nCardBuyDay == nYestDay then
        bShowBuyRed = true
        break
      end
    end
  end
  if bShowBuyRed then
    Ui:SetRedPointNotify("Activity_DailyRechargeGift")
  else
    Ui:ClearRedPointNotify("Activity_DailyRechargeGift")
  end
  local bShowNewYearGift = false
  if Activity:__IsActInProcessByType("RechargeNewYearBuyGift") then
    local nSeeDay = Client:GetFlag("SeeRedNewYearBuyGift")
    if not nSeeDay then
      bShowNewYearGift = true
    else
      local nStartTime = Activity:__GetActTimeInfo("RechargeNewYearBuyGift")
      if nSeeDay < Lib:GetLocalDay(nStartTime - 14400) then
        bShowNewYearGift = true
      elseif nSeeDay ~= nToday then
        local nYestDay = nToday - 1
        local tbBuyLimitInfo = Recharge.tbNewYearBuySetting[1]
        if tbBuyLimitInfo and 1 < tbBuyLimitInfo.nBuyCount and me.GetUserValue(self.SAVE_GROUP, tbBuyLimitInfo.nSaveCountKey) < tbBuyLimitInfo.nBuyCount then
          local tbProdInfo = self.tbSettingGroup.YearGift[1]
          local nCardBuyDay = me.GetUserValue(self.SAVE_GROUP, tbProdInfo.nBuyDayKey)
          if nCardBuyDay == nYestDay then
            bShowNewYearGift = true
          end
        end
      end
    end
  end
  if bShowNewYearGift then
    Ui:SetRedPointNotify("Activity_NewYearBuyGift")
  else
    Ui:ClearRedPointNotify("Activity_NewYearBuyGift")
  end
end
function Recharge:GetMonthCardAwardState()
  local nToday = Lib:GetLocalDay(GetTime() - 14400)
  local nState = 0
  local nLeftAwardDay = Recharge:GetDaysCardLeftDay(me, 2)
  if nLeftAwardDay > 0 then
    if me.GetUserValue(self.SAVE_GROUP, self.KEY_TAKE_MON) ~= nToday then
      nState = 1
    else
      nState = 2
      local tbExtParams = Recharge:IsOnActvityDay()
      if tbExtParams and tbExtParams[2] and me.GetUserValue(Recharge.SaveGroupActiviy, Recharge.SaveKeyActiviyMon) ~= nToday then
        nState = 1
      end
    end
  end
  return nState, nLeftAwardDay
end
function Recharge:GetWeekCardAwardState()
  local nToday = Lib:GetLocalDay(GetTime() - 14400)
  local nState = 0
  local nLeftAwardDay = Recharge:GetDaysCardLeftDay(me, 1)
  if nLeftAwardDay > 0 then
    if me.GetUserValue(self.SAVE_GROUP, self.KEY_TAKE_WEEK) ~= nToday then
      nState = 1
    else
      nState = 2
      local tbExtParams = Recharge:IsOnActvityDay()
      if tbExtParams and tbExtParams[1] and me.GetUserValue(Recharge.SaveGroupActiviy, Recharge.SaveKeyActiviyWeek) ~= nToday then
        nState = 1
      end
    end
  end
  return nState, nLeftAwardDay
end
function Recharge:IsRechareGetted()
  if Recharge.nLastTotalRechare then
    return Recharge.nLastTotalRechare ~= Recharge:GetTotoalRecharge(me)
  end
  return true
end
function Recharge:OnLogin()
  me.GetVipLevel(true)
  UiNotify.OnNotify(UiNotify.emNOTIFY_CHANGE_VIP_LEVEL)
end
function Recharge:IsShowGrowInvestPanel(nIndex)
  if not self.tbKeyGrowBuyed[nIndex] then
    return false
  end
  if me.GetUserValue(self.SAVE_GROUP, self.tbKeyGrowBuyed[nIndex]) == 1 then
    return false
  end
  for i, v in ipairs(self.tbProptGrowInvestLevel[nIndex]) do
    if v <= me.nLevel then
      if not Client:GetFlag("GrowInvestBuy" .. v) then
        Ui:OpenWindow("GrowInvestPanel", nIndex)
        Client:SetFlag("GrowInvestBuy" .. v, true)
        return true
      end
      break
    end
  end
  return false
end
function Recharge:IsFinishGrowInvest(nIndex)
  if not self.tbKeyGrowBuyed[nIndex] then
    return
  end
  if me.GetUserValue(self.SAVE_GROUP, self.tbKeyGrowBuyed[nIndex]) == 0 then
    return
  end
  local nTaked = me.GetUserValue(self.SAVE_GROUP, self.tbKeyGrowTaked[nIndex])
  for i, v in ipairs(self.tbGrowInvestGroup[nIndex]) do
    local nTakeeBit = KLib.GetBit(nTaked, i)
    if nTakeeBit == 0 then
      return
    end
  end
  return true
end
function Recharge:GetAutoShowGrowInvest()
  local tbLevels = {
    6,
    5,
    3,
    2,
    1
  }
  for i = 1, #tbLevels - 1 do
    local nLevelNow, nLevelPre = tbLevels[i], tbLevels[i + 1]
    if self:IsFinishGrowInvest(nLevelPre) and Recharge.tbSettingGroup.GrowInvest[nLevelNow] and me.nLevel >= Recharge.tbGrowInvestGroup[nLevelNow][1].nLevel then
      return nLevelNow
    end
  end
  return 1
end
function Recharge:CheckNewLevel()
  if not self.IS_OPEN_INVEST then
    return
  end
  local tbLevels = {
    1,
    2,
    3,
    5,
    6
  }
  for i, nLevel in ipairs(tbLevels) do
    if self:IsShowGrowInvestPanel(nLevel) then
      return
    end
    if not self:IsFinishGrowInvest(nLevel) then
      return
    end
  end
end
function Recharge:RequestBuyOneDayCard(szProductId)
  if not Recharge:CanBuyProduct(me, szProductId) then
    return
  end
  if Sdk:IsXgSdk() then
    RemoteServer.RequestRecharge(szProductId)
  else
    local tbBuyInfo = Recharge.tbProductionSettingAll[szProductId]
    local nBuy_dia_id = Recharge.CLICK_ID_GIFT_ONE - 1 + tbBuyInfo.nGroupIndex
    Sdk:PayCard(tbBuyInfo.szServiceCode, tbBuyInfo.szDesc, szProductId, tbBuyInfo.nLastingDay, {
      buy_dia_channel = Recharge.PAGE_ID_DAILY_GIFT,
      buy_dia_id = nBuy_dia_id,
      buy_quantity = 0
    })
  end
end
function Recharge:RequestBuyOneDayCardSet()
  local tbGroup = self.tbSettingGroup.DayGiftSet
  if not tbGroup then
    return
  end
  local tbBuyInfo = tbGroup[1]
  if not tbBuyInfo then
    return
  end
  if not Recharge:CanBuyProduct(me, tbBuyInfo.ProductId) then
    return
  end
  if Sdk:IsXgSdk() then
  else
    local nBuy_dia_id = Recharge.CLICK_ID_GIFT_ONE - 1 + tbBuyInfo.nGroupIndex + 10
    Sdk:PayCard(tbBuyInfo.szServiceCode, tbBuyInfo.szDesc, tbBuyInfo.ProductId, tbBuyInfo.nLastingDay, {
      buy_dia_channel = Recharge.PAGE_ID_DAILY_GIFT,
      buy_dia_id = nBuy_dia_id,
      buy_quantity = 0
    })
  end
end
function Recharge:RequestBuyGrowInvest(nGroupIndex)
  if not Recharge:CanBuyGrowInvest(me, nGroupIndex) then
    return
  end
  local tbBuyInfo = Recharge.tbSettingGroup.GrowInvest[nGroupIndex]
  if Sdk:IsXgSdk() then
    RemoteServer.RequestRecharge(tbBuyInfo.ProductId)
  else
    Sdk:PayCard(tbBuyInfo.szServiceCode, tbBuyInfo.szDesc, tbBuyInfo.ProductId, tbBuyInfo.nLastingDay, {
      buy_dia_channel = Recharge.PAGE_ID_INVEST,
      buy_dia_id = Recharge.CLICK_ID_INVEST,
      buy_quantity = 0
    })
  end
end
function Recharge:RequestBuyDaysCard(buy_dia_channel, buy_dia_id, nGroupIndex)
  if (version_hk or version_tw) and IOS then
    me.CenterMsg("该商品现在无法购买")
    return
  end
  local tbBuyInfo = Recharge.tbSettingGroup.DaysCard[nGroupIndex]
  if not Recharge:CanBuyProduct(me, tbBuyInfo.ProductId) then
    return
  end
  if Sdk:IsXgSdk() then
    RemoteServer.RequestRecharge(tbBuyInfo.ProductId)
  else
    Sdk:PayCard(tbBuyInfo.szServiceCode, tbBuyInfo.szDesc, tbBuyInfo.ProductId, tbBuyInfo.nLastingDay, {
      buy_dia_channel = buy_dia_channel,
      buy_dia_id = buy_dia_id,
      buy_quantity = 0
    })
  end
end
function Recharge:RequestBuyGold(tbBuyInfo)
  if Sdk:IsXgSdk() then
    RemoteServer.RequestRecharge(tbBuyInfo.ProductId)
  else
    Sdk:Pay(tbBuyInfo.nMoney * Recharge.RATE, tbBuyInfo.ProductId, {
      buy_dia_channel = Recharge.PAGE_ID_SHOP,
      buy_dia_id = Recharge.CLICK_ID_GOLD_FROM + tbBuyInfo.nGroupIndex,
      buy_quantity = tbBuyInfo.nMoney * Recharge.RATE
    })
  end
end
function Recharge:RequestBuyYearGift(szProductId)
  if not Recharge:CanBuyProduct(me, szProductId) then
    return
  end
  if Sdk:IsXgSdk() then
    RemoteServer.RequestRecharge(szProductId)
  else
    local tbBuyInfo = Recharge.tbProductionSettingAll[szProductId]
    local nBuy_dia_id = Recharge.CLICK_ID_GIFT_YEAR_FROM - 1 + tbBuyInfo.nGroupIndex
    Sdk:PayCard(tbBuyInfo.szServiceCode, tbBuyInfo.szDesc, szProductId, tbBuyInfo.nLastingDay, {
      buy_dia_channel = Recharge.PAGE_ID_YEAR_GIFT,
      buy_dia_id = nBuy_dia_id,
      buy_quantity = 0
    })
  end
end
function Recharge:RequestBuyDirectEnhance(tbBuyInfo)
  if not Recharge:CanBuyProduct(me, tbBuyInfo.ProductId) then
    return
  end
  if Sdk:IsXgSdk() then
    me.CenterMsg("暂时不可购买")
  else
    local nBuy_dia_id = Recharge.CLICK_ID_DIR_ENHANCE_FROM - 1 + tbBuyInfo.nGroupIndex
    Sdk:PayCard(tbBuyInfo.szServiceCode, tbBuyInfo.szDesc, tbBuyInfo.ProductId, tbBuyInfo.nLastingDay, {
      buy_dia_channel = Recharge.PAGE_ID_DIR_ENHANCE,
      buy_dia_id = nBuy_dia_id,
      buy_quantity = 0
    })
  end
end
function Recharge:IsShowProGroupInPanel(szGroup, szUi)
  if szGroup == "DaysCard" then
    if szUi == "RechargePanel" then
      if IOS then
        return false
      end
    elseif szUi == "RechargeGift" then
      return not Client:IsCloseIOSEntry()
    end
  elseif szGroup == "GrowInvest" and not Sdk:IsEfunHKTW() and not version_xm then
    return not Client:IsCloseIOSEntry()
  end
  return true
end
function Recharge:GetMoneyShowDesc(nRMBfen)
  local nRate = self.tbMoneyRMBRate[self.szDefMoneyType]
  local nMoney = math.ceil(nRMBfen / nRate)
  local szMoneyType = Recharge.tbSettingGroup.BuyGold[1].szMoneyType
  local tbMoneShowInfo = Recharge.tbMoneyName[szMoneyType]
  return nMoney * tbMoneShowInfo[4], tbMoneShowInfo[1]
end
function Recharge:GetShowBuyPriceDesc(nMoney, szMoneyType)
  local tbMoneyShowInfo = Recharge.tbMoneyName[szMoneyType]
  local szMoneyAmout = string.format(tbMoneyShowInfo[3], nMoney * tbMoneyShowInfo[4])
  if version_vn then
    szMoneyAmout = Lib:ThousandSplit(nMoney * tbMoneyShowInfo[4])
  end
  return szMoneyAmout .. tbMoneyShowInfo[1]
end
function Recharge:GetTrasnMoneyShow(szMoney1, szMoney2, nMoney)
  local tbMoneShowInfo1 = self.tbMoneyName[szMoney1]
  local tbMoneShowInfo2 = self.tbMoneyName[szMoney2]
  if szMoney1 ~= szMoney2 then
    local nRate1 = self.tbMoneyRMBRate[szMoney1]
    local nRate2 = self.tbMoneyRMBRate[szMoney2]
    nMoney = nMoney * nRate1 / nRate2
  end
  return string.format(tbMoneShowInfo2[3], nMoney * tbMoneShowInfo2[4])
end
function Recharge:GetMoneyPriceShow(nMoney)
  local szMoneyType1 = self.szDefMoneyType
  local szMoneyType2 = self.szDefMoneyType
  if version_kor then
    szMoneyType2 = self.tbSettingGroup.BuyGold[1].szMoneyType
  end
  return self:GetTrasnMoneyShow(szMoneyType1, szMoneyType2, nMoney)
end
function Recharge:GetFilterVipDesc(nVipLevel)
  local szDesc = self.tbVipDesc[nVipLevel + 1]
  if not szDesc then
    return ""
  end
  if me.nLevel >= MapExplore.MAX_LEVEL then
    szDesc = string.gsub(szDesc, "●  每天宝藏探索次数：.-\n", "")
  end
  return szDesc
end
function Recharge:GetCanBuyDirectEnhanceProds()
  local tbProds = {}
  if not Recharge.tbSettingGroup.DirectEnhance then
    return tbProds
  end
  for i, v in ipairs(Recharge.tbSettingGroup.DirectEnhance) do
    if self:CanBuyDirectEnhance(me, v.ProductId) then
      table.insert(tbProds, v)
    end
  end
  return tbProds
end
function Recharge:OnBuyDirectEnhanceSuc()
  UiNotify.OnNotify(UiNotify.emNOTIFY_WELFARE_UPDATE, "StrengthenUpGift")
end
function Recharge:RequestBuyDressMoney()
  local nNow = GetTime()
  self.nLastRequestTime = self.nLastRequestTime or 0
  if nNow - self.nLastRequestTime < 6 then
    me.CenterMsg(string.format("请%s秒后再尝试", 6 - (nNow - self.nLastRequestTime)))
    return
  end
  local szMsg = "您确定花13.99美金购买1000黎饰吗"
  local fnYes = function()
    Recharge.nLastRequestTime = GetTime()
    RemoteServer.RequestBuyDressMoney()
  end
  if Sdk:IsXgSdk() then
    do
      local tbGroup = self.tbSettingGroup.DressMoney
      if not tbGroup then
        return
      end
      local tbBuyInfo = tbGroup[1]
      if not tbBuyInfo then
        return
      end
      local szShowBuyPrice = self:GetShowBuyPriceDesc(tbBuyInfo.nMoney, tbBuyInfo.szMoneyType)
      szMsg = string.format("您确定花%s购买%s吗", szShowBuyPrice, tbBuyInfo.szDesc)
      function fnYes()
        Recharge.nLastRequestTime = GetTime()
        RemoteServer.RequestRecharge(tbBuyInfo.ProductId)
      end
    end
  end
  me.MsgBox(szMsg, {
    {"确认", fnYes},
    {"取消"}
  })
end
function Recharge:RequestBuyOrTakeOneDayCardPlus()
  local bCanTake, szMsg, nLeftCount = Recharge:CanTakeOneDayCardPlusAward(me)
  if nLeftCount and nLeftCount > 0 then
    if bCanTake then
      RemoteServer.TakeOneDayCardPlusAward()
    else
      me.CenterMsg(szMsg)
    end
    return
  end
  local bRet, szMsg = self:CanBuyOneDayCardPlus(me)
  if not bRet then
    me.CenterMsg(szMsg)
    return
  end
  local tbBuyInfo = self.tbSettingGroup.DayGiftPlus[1]
  local szShowBuyPrice = self:GetShowBuyPriceDesc(tbBuyInfo.nMoney, tbBuyInfo.szMoneyType)
  me.MsgBox(string.format("尊敬的侠士，是否花费[FFFE0D] %s [-]购买[FFFE0D] %s [-]？相当于[FFFE0D] 买六送一 [-]喔！购买后需每日登录领取，当日未领次数将保留\n", szShowBuyPrice, tbBuyInfo.szDesc), {
    {
      "确认",
      function()
        if Sdk:IsXgSdk() then
        else
          local nBuy_dia_id = Recharge.CLICK_ID_GIFT_ONE - 1 + 21
          Sdk:PayCard(tbBuyInfo.szServiceCode, tbBuyInfo.szDesc, tbBuyInfo.ProductId, tbBuyInfo.nLastingDay, {
            buy_dia_channel = Recharge.PAGE_ID_DAILY_GIFT,
            buy_dia_id = nBuy_dia_id,
            buy_quantity = 0
          })
        end
      end
    },
    {"取消"}
  })
end
function Recharge:RequestBuyBackGift(tbBuyInfo)
  if not Recharge:CanBuyProduct(me, tbBuyInfo.ProductId) then
    return
  end
  if Sdk:IsXgSdk() then
    RemoteServer.RequestRecharge(tbBuyInfo.ProductId)
  else
    Sdk:PayCard(tbBuyInfo.szServiceCode, tbBuyInfo.szDesc, tbBuyInfo.ProductId, tbBuyInfo.nLastingDay, {
      buy_dia_channel = 1,
      buy_dia_id = 1,
      buy_quantity = 0
    })
  end
end
function Recharge:GetVipPrivilegeDesc(szKey)
  local nVipLv = me.GetVipLevel()
  local tbDesc = Recharge.tbVipPrivilegeDesc[szKey] or {}
  return tbDesc[nVipLv]
end
