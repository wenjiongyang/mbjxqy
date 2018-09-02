local tbUi = Ui:CreateClass("ChangeFactionPanel")
tbUi.tbOnClick = {}
tbUi.nTotalSub = 2
tbUi.tbSeriesWorld = {
  [1] = "Gold",
  [2] = "Wood",
  [3] = "Water",
  [4] = "Fire",
  [5] = "Earth"
}
function tbUi.tbOnClick:BtnClose()
  Ui:CloseWindow(self.UI_NAME)
end
function tbUi:OnOpen(tbFaction)
  self:UpdateInfo(tbFaction)
end
function tbUi:UpdateInfo(tbFaction)
  local tbSeriesFaction = {}
  for nFaction, _ in pairs(tbFaction) do
    local tbPlayerInfo = KPlayer.GetPlayerInitInfo(nFaction)
    local tbInfo = {}
    tbInfo.nSeries = tbPlayerInfo.nSeries
    tbInfo.nFaction = nFaction
    tbSeriesFaction[tbInfo.nSeries] = tbSeriesFaction[tbInfo.nSeries] or {}
    tbSeriesFaction[tbInfo.nSeries][tbInfo.nFaction] = tbInfo
  end
  self.tbSubFaction = {}
  for _, tbAllFaction in pairs(tbSeriesFaction) do
    local tbSubItem = {}
    for _, tbFaction in pairs(tbAllFaction) do
      local nCount = #tbSubItem
      if nCount == tbUi.nTotalSub then
        table.insert(self.tbSubFaction, tbSubItem)
        tbSubItem = {}
      end
      table.insert(tbSubItem, tbFaction)
    end
    local nCount1 = #tbSubItem
    if nCount1 > 0 then
      table.insert(self.tbSubFaction, tbSubItem)
    end
  end
  table.sort(self.tbSubFaction, function(a, b)
    return a[1].nSeries < b[1].nSeries
  end)
  for _, tbSubItem in pairs(self.tbSubFaction) do
    table.sort(tbSubItem, function(a, b)
      return a.nFaction < b.nFaction
    end)
  end
  local function fnSetItem(tbItemObj, nIndex)
    self:UpdateSubItem(tbItemObj, self.tbSubFaction[nIndex])
  end
  local nUpdateCount = #self.tbSubFaction
  self.ScrollView:Update(nUpdateCount, fnSetItem)
end
function tbUi:UpdateSubItem(tbItemObj, tbSubInfo)
  self:ClearSubItem(tbItemObj)
  if not tbSubInfo then
    return
  end
  local nTotalCount = #tbSubInfo
  if nTotalCount == 0 then
    return
  end
  local fnSelectFaction = function(BtnObj)
    if not BtnObj.tbFactionInfo then
      return
    end
    local szMsg = string.format("您想转[FFFE0D]%s[-],确认吗？", Faction:GetName(BtnObj.tbFactionInfo.nFaction))
    me.MsgBox(szMsg, {
      {
        "确认",
        function()
          RemoteServer.DoChangeFaction(BtnObj.tbFactionInfo.nFaction)
          Ui:CloseWindow("ChangeFactionPanel")
        end
      },
      {"取消"}
    })
  end
  tbItemObj.pPanel:SetActive(tbUi.tbSeriesWorld[tbSubInfo[1].nSeries], true)
  for nIndex, tbFaction in ipairs(tbSubInfo) do
    tbItemObj.pPanel:SetActive("FactionRole" .. nIndex, true)
    tbItemObj["FactionRole" .. nIndex].tbFactionInfo = tbFaction
    tbItemObj["FactionRole" .. nIndex]:UpdateInfo(tbFaction)
    tbItemObj["FactionRole" .. nIndex].pPanel.OnTouchEvent = fnSelectFaction
    local szSelecIcon = Faction:GetBGSelectIcon(tbFaction.nFaction)
    tbItemObj.pPanel:Button_SetSprite("FactionRole" .. nIndex, szSelecIcon)
    local szWordIcon = Faction:GetWordIcon(tbFaction.nFaction)
    tbItemObj["FactionRole" .. nIndex].pPanel:Sprite_SetSprite("FactionIcon", szWordIcon)
  end
end
function tbUi:ClearSubItem(tbItemObj)
  for _, szWorld in pairs(tbUi.tbSeriesWorld) do
    tbItemObj.pPanel:SetActive(szWorld, false)
  end
  for nI = 1, tbUi.nTotalSub do
    tbItemObj.pPanel:SetActive("FactionRole" .. nI, false)
  end
end
local tbChangeSubItem = Ui:CreateClass("ChangeFactionItem")
function tbChangeSubItem:UpdateInfo(tbFactionInfo)
end
