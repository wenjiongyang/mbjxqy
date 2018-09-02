local tbUi = Ui:CreateClass("ExpUpPanel")
tbUi.tbOnClick = {}
tbUi.szContentTxt = "后起之秀\n    诸位少侠出道之日尚短，然天资卓绝，前途不可限量，故老板娘我与独孤盟主商量过后，让得诸位在[FFFE0D]任意途径获得的经验[-]均将获得加成，早日成为名动一方的大侠！\n    不同等级的经验加成比例不同，低等级段经验加成更多\n"
tbUi.tbShowPos = {
  [1] = {
    [1] = {177, -146}
  },
  [2] = {
    [1] = {57, -146},
    [2] = {297, -146}
  }
}
tbUi.nItemLevel = 50
function tbUi.tbOnClick:BtnClose()
  Ui:CloseWindow("ExpUpPanel")
end
function tbUi.tbOnClick:BtnGoo()
  Ui:OpenWindow("WelfareActivity", "BuyLevelUp")
end
function tbUi.tbOnClick:BtnCalendar()
  Ui:OpenWindow("CalendarPanel")
end
function tbUi:OnOpen()
  self:UpdateInfo()
  local tbInfo = Client:GetUserInfo("BtnExpUpRed")
  if not tbInfo.nRedPoint then
    tbInfo.nRedPoint = 1
    Ui:ClearRedPointNotify("ExpUpRedPoint")
    Client:SaveUserInfo()
  end
end
function tbUi:UpdateInfo()
  local tbShowUI = {}
  local tbLevelInfo = Npc:GetPlayerLevelAddExpP() or {}
  self.pPanel:Label_SetText("ContentTxt", tbUi.szContentTxt)
  self.pPanel:SetActive("Exp1", false)
  self.pPanel:SetActive("Exp3", false)
  local nAddP = tbLevelInfo[me.nLevel]
  if nAddP and nAddP > 100 then
    table.insert(tbShowUI, "Exp1")
    self.pPanel:Label_SetText("ExpTxt1_2", string.format("%s%%", nAddP - 100))
  end
  local bCanBuy, nItemID = self:CheckCanBuy()
  if bCanBuy and me.nLevel >= tbUi.nItemLevel then
    table.insert(tbShowUI, "Exp3")
    self.Item:SetGenericItem({
      "item",
      nItemID,
      1
    })
    self.Item.fnClick = self.Item.DefaultClick
  end
  local nTotalCount = #tbShowUI
  local tbPos = tbUi.tbShowPos[nTotalCount]
  if tbPos then
    for nIndex, szUi in ipairs(tbShowUI) do
      self.pPanel:SetActive(szUi, true)
      self.pPanel:ChangePosition(szUi, tbPos[nIndex][1], tbPos[nIndex][2])
    end
  end
end
function tbUi:CheckCanBuy()
  local nCanBuyID = DirectLevelUp:GetCanBuyItem()
  if not nCanBuyID then
    return false
  end
  local bCanBuy = DirectLevelUp:CheckCanBuy(me, nCanBuyID)
  return bCanBuy, nCanBuyID
end
