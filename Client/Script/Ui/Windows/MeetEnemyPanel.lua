local tbUi = Ui:CreateClass("MeetEnemyPanel")
function tbUi:OnOpen(tbRole)
  local szIcon, szIconAtlas = PlayerPortrait:GetSmallIcon(tbRole.nPortrait)
  self.pPanel:Sprite_SetSprite("SpRoleHead", szIcon, szIconAtlas)
  self.pPanel:Label_SetText("lbLevel", tbRole.nLevel)
  local szFactionIcon = Faction:GetIcon(tbRole.nFaction)
  self.pPanel:Sprite_SetSprite("SpFaction", szFactionIcon)
  local tbHonorInfo = Player.tbHonorLevelSetting[tbRole.nHonorLevel]
  if tbHonorInfo then
    self.pPanel:SetActive("PlayerTitle", true)
    self.pPanel:Sprite_Animation("PlayerTitle", tbHonorInfo.ImgPrefix)
    self.pPanel:SetActive("TxtCaptainName", true)
    self.pPanel:SetActive("TxtCaptainName2", false)
    self.pPanel:Label_SetText("TxtCaptainName", tbRole.szName)
  else
    self.pPanel:SetActive("PlayerTitle", false)
    self.pPanel:SetActive("TxtCaptainName", false)
    self.pPanel:SetActive("TxtCaptainName2", true)
    self.pPanel:Label_SetText("TxtCaptainName2", tbRole.szName)
  end
  if FriendShip:IsHeIsMyEnemy(me.dwID, tbRole.dwID) then
    self.pPanel:Label_SetText("strengthenTip", "[fe6464]*对方是你的仇人[-1]")
  else
    self.pPanel:Label_SetText("strengthenTip", "[C8C8C8]*攻击后将会成为对方的仇人[-1]")
  end
end
tbUi.tbOnClick = {}
function tbUi.tbOnClick:BtnAttack()
  Ui:CloseWindow(self.UI_NAME)
  RemoteServer.MapExploreAttackEnemy()
end
function tbUi.tbOnClick:BtnLeave()
  Ui:CloseWindow(self.UI_NAME)
  MapExplore.bCanMove = true
  MapExplore:CheckLeave()
end
