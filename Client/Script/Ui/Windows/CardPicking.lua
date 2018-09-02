local tbUi = Ui:CreateClass("CardPicking")
function tbUi:Init()
  CardPicker:UpdateRemoteInfo()
  self:Update()
  self.pPanel:Label_SetText("TxtGoldPickCost", CardPicker.Def.nGoldCost)
  self.pPanel:Label_SetText("TxtJadePickCost", CardPicker.Def.nCoinCost)
  self.pPanel:Label_SetText("TxtJadePickTenCost", CardPicker.Def.nCoinTenCost)
  if not self.nCountDownTimer then
    self.nCountDownTimer = Timer:Register(Env.GAME_FPS, self.LeftTimeCountDown, self)
  end
  self:LeftTimeCountDown()
end
function tbUi:LeftTimeCountDown()
  local nNow = GetTime()
  local nLeftFreeTime = CardPicker:GetNextFreePickTime() - nNow
  if nLeftFreeTime <= 0 then
    self.pPanel:Label_SetText("TxtGoldFreePickCountdown", "本次免费")
    self.pPanel:SetActive("BtnGoldFreePick", true)
    self.pPanel:SetActive("BtnGoldPick", false)
  else
    self.pPanel:SetActive("BtnGoldFreePick", false)
    self.pPanel:SetActive("BtnGoldPick", true)
    local szLeftTime = Lib:TimeDesc3(nLeftFreeTime)
    local szCountdown = string.format("%s 后免费", szLeftTime)
    self.pPanel:Label_SetText("TxtGoldFreePickCountdown", szCountdown)
  end
  local nLeftCoinFreeTime = CardPicker:GetNextCoinFreePickTime() - nNow
  if nLeftCoinFreeTime <= 0 then
    self.pPanel:Label_SetText("TxtCoinFreePickCountdown", "本次免费")
    self.pPanel:SetActive("BtnJadeFreePick", true)
    self.pPanel:SetActive("BtnJadePick", false)
  else
    self.pPanel:SetActive("BtnJadeFreePick", false)
    self.pPanel:SetActive("BtnJadePick", true)
    local szLeftTime = Lib:TimeDesc3(nLeftCoinFreeTime)
    local szCountdown = string.format("%s 后免费", szLeftTime)
    self.pPanel:Label_SetText("TxtCoinFreePickCountdown", szCountdown)
  end
  return true
end
function tbUi:Update()
  Partner:UpdateRedPoint()
  self.pPanel:Label_SetText("TxtMyJade", me.GetMoney("Coin"))
  self.pPanel:Label_SetText("TxtMyGold", me.GetMoney("Gold"))
  local nGoldTenCost, nOnSaleFlag = CardPicker:GetGoldTenCost()
  self.pPanel:Label_SetText("TxtGoldTenPickCost", nGoldTenCost)
  self.pPanel:Label_SetText("TxtOriginalPrice", CardPicker.Def.nGoldTenCost)
  self.pPanel:Label_SetText("TxtPresentprice", nGoldTenCost)
  self.pPanel:SetActive("Discount", nOnSaleFlag and true or false)
  self.pPanel:SetActive("WeekenderTip", nOnSaleFlag and true or false)
  self.pPanel:SetActive("IconGoldTenCost", not nOnSaleFlag)
  self:SetAllButtonState(true)
  local nLeftSTime = CardPicker:GetLeftSTime()
  if not nLeftSTime or nLeftSTime == 10 then
    self.pPanel:SetActive("GoldPickLeft10Tip", true)
    self.pPanel:SetActive("GoldPickLeftTip", false)
  else
    self.pPanel:SetActive("GoldPickLeft10Tip", false)
    self.pPanel:SetActive("GoldPickLeftTip", true)
    local szPickCountDown = string.format("再招募%d次必得  #956  级同伴", nLeftSTime)
    self.pPanel:Label_SetText("TxtGoldPickTips", szPickCountDown)
  end
end
function tbUi:SetAllButtonState(bEnable)
  self.pPanel:Button_SetEnabled("BtnGoldPick", bEnable)
  self.pPanel:Button_SetEnabled("BtnGoldFreePick", bEnable)
  self.pPanel:Button_SetEnabled("BtnJadePick", bEnable)
  self.pPanel:Button_SetEnabled("BtnJadeFreePick", bEnable)
  self.pPanel:Button_SetEnabled("BtnJadeTenPick", bEnable)
  self.pPanel:Button_SetEnabled("BtnGoldTenPick", bEnable)
end
function tbUi:OnClose()
  if self.nCountDownTimer then
    Timer:Close(self.nCountDownTimer)
    self.nCountDownTimer = nil
  end
end
tbUi.tbOnClick = {}
function tbUi.tbOnClick:BtnJadePick()
  if me.GetMoney("Coin") < CardPicker.Def.nCoinCost then
    me.CenterMsg("您的银两不足")
    return false
  end
  if me.GetFreeBagCount() < 1 then
    me.CenterMsg("背包将达到上限, 请先清理背包")
    return false
  end
  self:SetAllButtonState(false)
  Ui:OpenWindow("CardPickingResult", "CoinPick")
  CardPicker:ClearResultCache()
  RemoteServer.OnCardPickerRequest("CoinPick")
end
function tbUi.tbOnClick:BtnJadeFreePick()
  if me.GetFreeBagCount() < 1 then
    me.CenterMsg("背包将达到上限, 请先清理背包")
    return false
  end
  local nLeftFreeTime = CardPicker:GetNextCoinFreePickTime() - GetTime()
  if nLeftFreeTime > 0 then
    me.CenterMsg("免费招募时间未到")
    return
  end
  self:SetAllButtonState(false)
  Ui:OpenWindow("CardPickingResult", "CoinPick")
  CardPicker:ClearResultCache()
  RemoteServer.OnCardPickerRequest("CoinFreePick")
end
function tbUi.tbOnClick:BtnJadeTenPick()
  if me.GetMoney("Coin") < CardPicker.Def.nCoinTenCost then
    me.CenterMsg("您的银两不足")
    return false
  end
  if me.GetFreeBagCount() < 10 then
    me.CenterMsg("背包将达到上限, 请先清理背包")
    return false
  end
  self:SetAllButtonState(false)
  Ui:OpenWindow("CardPickingResult", "CoinTenPick")
  CardPicker:ClearResultCache()
  RemoteServer.OnCardPickerRequest("CoinTenPick")
end
function tbUi.tbOnClick:BtnGoldPick()
  if me.GetMoney("Gold") < CardPicker.Def.nGoldCost then
    me.CenterMsg("您的元宝不足")
    return false
  end
  if me.GetFreeBagCount() < 1 then
    me.CenterMsg("背包将达到上限, 请先清理背包")
    return false
  end
  self:SetAllButtonState(false)
  Ui:OpenWindow("CardPickingResult", "GoldPick")
  CardPicker:ClearResultCache()
  RemoteServer.OnCardPickerRequest("GoldPick")
end
function tbUi.tbOnClick:BtnGoldTenPick()
  local nGoldTenCost = CardPicker:GetGoldTenCost()
  if nGoldTenCost > me.GetMoney("Gold") then
    me.CenterMsg("您的元宝不足")
    return false
  end
  if me.GetFreeBagCount() < 10 then
    me.CenterMsg("背包将达到上限, 请先清理背包")
    return false
  end
  self:SetAllButtonState(false)
  Ui:OpenWindow("CardPickingResult", "GoldTenPick")
  CardPicker:ClearResultCache()
  RemoteServer.OnCardPickerRequest("GoldTenPick", nGoldTenCost)
end
function tbUi.tbOnClick:BtnGoldFreePick()
  self.pPanel:SetActive("BtnGoldFreePick", false)
  local nNow = GetTime()
  local nLeftFreeTime = CardPicker:GetNextFreePickTime() - nNow
  if nLeftFreeTime > 0 then
    me.CenterMsg("免费招募时间未到")
    return
  end
  if me.GetFreeBagCount() < 1 then
    me.CenterMsg("背包将达到上限, 请先清理背包")
    return false
  end
  self:SetAllButtonState(false)
  Ui:OpenWindow("CardPickingResult", "GoldFreePick")
  CardPicker:ClearResultCache()
  RemoteServer.OnCardPickerRequest("GoldFreePick")
  Guide.tbNotifyGuide:ClearNotifyGuide("PickCard", true)
end
function tbUi.tbOnClick:BtnPreview1()
  Ui:OpenWindow("CardPreview", "Coin")
end
function tbUi.tbOnClick:BtnPreview2()
  Ui:OpenWindow("CardPreview", "Gold")
end
