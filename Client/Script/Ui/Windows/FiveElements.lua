local tbUi = Ui:CreateClass("FiveElements")
tbUi.tbFactionRelation = {
  {2, 4},
  {5, 1},
  {4, 5},
  {1, 3},
  {3, 2}
}
function tbUi:OnOpenEnd(nFaction)
  nFaction = nFaction or me.nFaction
  local szFactionIcon = Faction:GetIcon(nFaction)
  self.pPanel:Sprite_SetSprite("MyFactionIcon", szFactionIcon)
  self.pPanel:Label_SetText("MyFactionName", Faction:GetName(nFaction))
  local tbRelation = {"Restrain", "Resist"}
  local nMySeries = KPlayer.GetPlayerInitInfo(nFaction).nSeries
  for i = 1, 2 do
    local tbFaction = {}
    for nFaction = 1, Faction.MAX_FACTION_COUNT do
      local tbInfo = KPlayer.GetPlayerInitInfo(nFaction)
      if tbInfo.nSeries == self.tbFactionRelation[nMySeries][i] then
        table.insert(tbFaction, nFaction)
      end
    end
    for j = 1, 4 do
      local nFac = tbFaction[j]
      self.pPanel:SetActive(tbRelation[i] .. "Icon" .. j, nFac and true or false)
      self.pPanel:SetActive(tbRelation[i] .. "Name" .. j, nFac and true or false)
      if nFac then
        self.pPanel:Sprite_SetSprite(tbRelation[i] .. "Icon" .. j, Faction:GetIcon(nFac))
        self.pPanel:Label_SetText(tbRelation[i] .. "Name" .. j, Faction:GetName(nFac))
      end
    end
  end
end
tbUi.tbOnClick = {
  BtnClose = function(self)
    Ui:CloseWindow(self.UI_NAME)
  end
}
