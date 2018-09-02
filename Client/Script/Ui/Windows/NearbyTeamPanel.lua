local tbUI = Ui:CreateClass("NearbyTeamPanel")
tbUI.tbOnClick = {
  btnClose = function(self)
    Ui:CloseWindow(self.UI_NAME)
  end,
  btnInvite = function(self)
    self:Apply()
  end
}
function tbUI:RegisterEvent()
  local tbRegEvent = {
    {
      UiNotify.emNOTIFY_SYNC_NEARBY_TEAMS,
      self.Refresh,
      self
    }
  }
  return tbRegEvent
end
function tbUI:OnOpen()
  self:Refresh({})
  TeamMgr:SyncNearbyTeams()
end
function tbUI:Refresh(tbTeams)
  local nRows = #tbTeams
  self.tbTeams = tbTeams
  self.tbItemGrids = {}
  local function fnSetItem(tbItemGrid, nIdx)
    local tbData = tbTeams[nIdx]
    local tbCaptainInfo = tbData.tbCaptainInfo
    tbItemGrid.pPanel:Label_SetText("lbLevel", tbCaptainInfo.nLevel)
    local szFactionIcon = Faction:GetIcon(tbCaptainInfo.nFaction)
    local szHead, szAtlas = PlayerPortrait:GetSmallIcon(tbCaptainInfo.nPortrait)
    tbItemGrid.pPanel:Sprite_SetSprite("SpFaction", szFactionIcon)
    tbItemGrid.pPanel:Sprite_SetSprite("SpRoleHead", szHead, szAtlas)
    local tbHonorInfo = Player.tbHonorLevelSetting[tbCaptainInfo.nHonorLevel]
    if tbHonorInfo and tbHonorInfo.ImgPrefix then
      tbItemGrid.pPanel:Sprite_Animation("PlayerTitle", tbHonorInfo.ImgPrefix)
    end
    tbItemGrid.pPanel:SetActive("PlayerTitle", tbHonorInfo and tbHonorInfo.ImgPrefix)
    tbItemGrid.pPanel:Label_SetText("lbRoleName", string.format("%s的队伍", tbCaptainInfo.szName))
    local szActivityName = tbData.nTargetActivityId > 0 and TeamMgr:GetActivityInfo(tbData.nTargetActivityId) or "无"
    tbItemGrid.pPanel:Label_SetText("TeamTarget", szActivityName)
    tbItemGrid.pPanel:Label_SetText("MemberCount", tbData.nMemberCount)
    tbItemGrid.pPanel:Toggle_SetChecked("CheckTeam", false)
    table.insert(self.tbItemGrids, tbItemGrid.pPanel)
  end
  self.ScrollView:Update(nRows, fnSetItem)
end
function tbUI:Apply()
  local bSend = false
  for i, pGrid in ipairs(self.tbItemGrids) do
    if pGrid:Toggle_GetChecked("CheckTeam") then
      TeamMgr:Apply(self.tbTeams[i].nTeamID, self.tbTeams[i].tbCaptainInfo.nPlayerID, true)
      bSend = true
    end
  end
  me.CenterMsg(bSend and "入队申请已发送" or "请指定要申请的队伍")
  if bSend then
    Ui:CloseWindow(self.UI_NAME)
  end
end
