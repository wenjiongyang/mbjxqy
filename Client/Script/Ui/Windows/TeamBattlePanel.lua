local tbUi = Ui:CreateClass("TeamBattlePanel")
tbUi.tbMarkText = {
  "月度赛",
  "季度赛",
  "年度赛"
}
function tbUi:OnOpenEnd()
  self.pPanel:Label_SetText("IntroducesTxt", TeamBattle.TeamBattlePanelDescribe.Describe)
  local nLastTimes = TeamBattle:GetLastTimes(me)
  self.pPanel:Label_SetText("TxtTime", nLastTimes)
  for nIndex = 1, 4 do
    local tbReward = TeamBattle.tbReward[nIndex]
    if tbReward then
      self["itemframe" .. nIndex]:SetGenericItem(tbReward)
      self["itemframe" .. nIndex].fnClick = self["itemframe" .. nIndex].DefaultClick
    end
    self["itemframe" .. nIndex].pPanel:SetActive("Main", tbReward and true or false)
  end
  local nMarkType = Calendar:GetMarkTypeOfPlayer("TeamBattle")
  self.pPanel:SetActive("Mark", nMarkType or false)
  if nMarkType then
    self.pPanel:Label_SetText("MarkTxt", self.tbMarkText[nMarkType] or "")
  end
end
tbUi.tbOnClick = tbUi.tbOnClick or {}
function tbUi.tbOnClick:BtnSingle()
  RemoteServer.TeamBattleTryJoinPreMap(true)
end
function tbUi.tbOnClick:BtnTeam()
  RemoteServer.TeamBattleTryJoinPreMap(false)
end
function tbUi.tbOnClick:BtnClose()
  Ui:CloseWindow(self.UI_NAME)
end
