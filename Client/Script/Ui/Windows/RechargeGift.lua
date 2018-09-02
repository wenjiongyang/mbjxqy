local tbUi = Ui:CreateClass("RechargeGift")
function tbUi:OnOpen()
  self:RefreshUi()
end
function tbUi:OnClose()
end
function tbUi:RefreshUi()
  local tbCardExtPrams = Recharge:IsOnActvityDay()
  if tbCardExtPrams then
    local nWeekParam, nMonParam = tbCardExtPrams[1], tbCardExtPrams[2]
    self.pPanel:SetActive("RechargeGiftTip", false)
    if nWeekParam then
      self.pPanel:SetActive("Extra1", true)
      self.pPanel:Label_SetText("ExtraAmount1", string.format("%d%%", nWeekParam))
    else
      self.pPanel:SetActive("Extra1", false)
    end
    if nMonParam then
      self.pPanel:SetActive("Extra2", true)
      self.pPanel:Label_SetText("ExtraAmount2", string.format("%d%%", nMonParam))
    else
      self.pPanel:SetActive("Extra2", false)
    end
  else
    self.pPanel:SetActive("RechargeGiftTip", false)
    self.pPanel:SetActive("Extra1", false)
    self.pPanel:SetActive("Extra2", false)
  end
  local tbGroup = Recharge.tbSettingGroup.DaysCard
  local nState, nLeftAwardDay = Recharge:GetMonthCardAwardState()
  local tbBuyInfo = tbGroup[2]
  local nBuyGetGold = Recharge:GetGoldNumFromAward(tbBuyInfo.tbAward)
  local nDayGetGold = Recharge:GetGoldNumFromAward(Recharge:GetMonthCardAward())
  local nTotalGold = nBuyGetGold + nDayGetGold * tbBuyInfo.nLastingDay
  self.pPanel:Label_SetText("Label2_1", nBuyGetGold)
  self.pPanel:Label_SetText("Label2_2", nDayGetGold)
  self.pPanel:Label_SetText("Label2_3", nTotalGold)
  if nState == 0 then
    self.pPanel:SetActive("BtnBuy30", true)
    self.pPanel:SetActive("BtnRenew30", false)
    self.pPanel:SetActive("BtnReceive30", false)
    self.pPanel:SetActive("LimitTxt30day", false)
    local tbMoneyShowInfo = Recharge.tbMoneyName[tbBuyInfo.szMoneyType]
    local szMoneyAmout = string.format(tbMoneyShowInfo[3], tbBuyInfo.nMoney * tbMoneyShowInfo[4])
    if version_vn then
      szMoneyAmout = Lib:ThousandSplit(tbBuyInfo.nMoney * tbMoneyShowInfo[4])
    end
    self.pPanel:Button_SetText("BtnBuy30", string.format("%s%s购买", szMoneyAmout, tbMoneyShowInfo[1]))
  else
    self.pPanel:SetActive("BtnBuy30", false)
    local nLeftTime = Recharge:GetDaysCardLeftTime(me, 2)
    self.pPanel:SetActive("BtnRenew30", nLeftTime <= Recharge.tbDaysCardBuyLimitDay[2] * 3600 * 24)
    self.pPanel:SetActive("BtnReceive30", true)
    self.pPanel:SetActive("LimitTxt30day", true)
    self.pPanel:Label_SetText("LimitTxt30day", string.format("剩余%d天", nLeftAwardDay))
    if nState == 1 then
      self.pPanel:Button_SetEnabled("BtnReceive30", true)
      self.pPanel:Button_SetText("BtnReceive30", "领取")
    elseif nState == 2 then
      self.pPanel:Button_SetEnabled("BtnReceive30", false)
      self.pPanel:Button_SetText("BtnReceive30", "已领取")
    end
  end
  local tbBuyInfo = tbGroup[1]
  local nBuyGetGold = Recharge:GetGoldNumFromAward(tbBuyInfo.tbAward)
  local nDayGetGold = Recharge:GetGoldNumFromAward(Recharge:GetWeekCardAward())
  local nTotalGold = nBuyGetGold + nDayGetGold * tbBuyInfo.nLastingDay
  self.pPanel:Label_SetText("Label1_1", nBuyGetGold)
  self.pPanel:Label_SetText("Label1_2", nDayGetGold)
  self.pPanel:Label_SetText("Label1_3", nTotalGold)
  local nState, nLeftAwardDay = Recharge:GetWeekCardAwardState()
  if nState == 0 then
    self.pPanel:SetActive("BtnBuy7", true)
    self.pPanel:SetActive("BtnRenew7", false)
    self.pPanel:SetActive("BtnReceive7", false)
    self.pPanel:SetActive("LimitTxt7day", false)
    local tbMoneyShowInfo = Recharge.tbMoneyName[tbBuyInfo.szMoneyType]
    local szMoneyAmout = string.format(tbMoneyShowInfo[3], tbBuyInfo.nMoney * tbMoneyShowInfo[4])
    if version_vn then
      szMoneyAmout = Lib:ThousandSplit(tbBuyInfo.nMoney * tbMoneyShowInfo[4])
    end
    self.pPanel:Button_SetText("BtnBuy7", string.format("%s%s购买", szMoneyAmout, tbMoneyShowInfo[1]))
  else
    self.pPanel:SetActive("BtnBuy7", false)
    local nLeftTime = Recharge:GetDaysCardLeftTime(me, 1)
    self.pPanel:SetActive("BtnRenew7", nLeftTime <= Recharge.tbDaysCardBuyLimitDay[1] * 3600 * 24)
    self.pPanel:SetActive("BtnReceive7", true)
    self.pPanel:SetActive("LimitTxt7day", true)
    self.pPanel:Label_SetText("LimitTxt7day", string.format("剩余%d天", nLeftAwardDay))
    if nState == 1 then
      self.pPanel:Button_SetEnabled("BtnReceive7", true)
      self.pPanel:Button_SetText("BtnReceive7", "领取")
    elseif nState == 2 then
      self.pPanel:Button_SetEnabled("BtnReceive7", false)
      self.pPanel:Button_SetText("BtnReceive7", "已领取")
    end
  end
  if IOS and Sdk:IsEfunHKTW() then
    self.pPanel:SetActive("BtnBuy7", false)
    self.pPanel:SetActive("BtnRenew7", false)
    self.pPanel:SetActive("BtnBuy30", false)
    self.pPanel:SetActive("BtnRenew30", false)
  end
  local bIsLotteryOpen = Lottery:IsOpen()
  for i = 1, 2 do
    local szKey = "Vips0" .. i
    self.pPanel:SetActive(szKey, bIsLotteryOpen)
    if bIsLotteryOpen then
      self.pPanel:Label_SetText(szKey, string.format("另获盟主的馈赠%d张", Lottery:GetAwardTicketCount(i == 1 and "Weekly" or "Monthly")))
    end
  end
  local bNotGetedFirst = me.GetUserValue(Recharge.SAVE_GROUP, Recharge.KEY_GET_FIRST_RECHARGE) == 0
  self.pPanel:SetActive("RechargeGiftTxt", bNotGetedFirst)
end
function tbUi:RegisterEvent()
  local tbRegEvent = {
    {
      UiNotify.emNOTIFY_SYNC_LOTTERY_DATA,
      self.RefreshUi
    }
  }
  return tbRegEvent
end
tbUi.tbOnClick = {}
function tbUi.tbOnClick:BtnReceive30()
  RemoteServer.TakeMonthCardAward()
end
function tbUi.tbOnClick:BtnReceive7()
  RemoteServer.TakeWeekMonthCardAward()
end
function tbUi.tbOnClick:BtnRenew30()
  Recharge:RequestBuyDaysCard(Recharge.PAGE_ID_GIFT, Recharge.CLICK_ID_GIFT_MON_RE, 2)
end
function tbUi.tbOnClick:BtnRenew7()
  Recharge:RequestBuyDaysCard(Recharge.PAGE_ID_GIFT, Recharge.CLICK_ID_GIFT_WEEK_RE, 1)
end
function tbUi.tbOnClick:BtnBuy30()
  Recharge:RequestBuyDaysCard(Recharge.PAGE_ID_GIFT, Recharge.CLICK_ID_GIFT_MON_NEW, 2)
end
function tbUi.tbOnClick:BtnBuy7()
  Recharge:RequestBuyDaysCard(Recharge.PAGE_ID_GIFT, Recharge.CLICK_ID_GIFT_WEEK_NEW, 1)
end
