local tbUi = Ui:CreateClass("RoleHeadPop")
function tbUi:OnOpen(tbInfo, bIsNpc)
  if bIsNpc then
    return self:OpenNpcHead(unpack(tbInfo))
  else
    return self:OpenPlayerHead(unpack(tbInfo))
  end
end
function tbUi:OpenNpcHead(nNpcID)
  local pNpc = KNpc.GetById(nNpcID)
  if not pNpc then
    return 0
  end
  local nTemplateId = pNpc.nTemplateId
  if CommerceTask:IsCommerceGather(nTemplateId) and not CommerceTask:GatherThingInTask(me, nTemplateId) then
    return 0
  end
  self.nNpcID = nNpcID
  self.nPlayerID = nil
  Operation:SetNpcSelected(nNpcID)
  self.BgSprite.pPanel:SetActive("SpFaction", false)
  self.BgSprite.pPanel:SetActive("lbLevel", false)
  local nFaceId = KNpc.GetNpcShowInfo(pNpc.nTemplateId)
  local szAtlas, szSprite = Npc:GetFace(nFaceId)
  self.BgSprite.pPanel:Sprite_SetSprite("SpRoleHead", szSprite, szAtlas)
  function self.BgSprite.pPanel.OnTouchEvent()
    Operation:SimpleTap(self.nNpcID)
  end
end
function tbUi:OpenPlayerHead(nPlayerID, nNpcID, szName, nLevel, nFaction, nProtrait)
  if me.nMapTemplateId == XinShouLogin.tbDef.nFubenMapID then
    return 0
  end
  local pNpc = KNpc.GetById(nNpcID)
  szName = szName or pNpc and pNpc.szName
  nLevel = nLevel or pNpc and pNpc.nLevel
  nFaction = nFaction or pNpc and pNpc.nFaction
  if not nFaction then
    return 0
  end
  self.nPlayerID = nPlayerID
  self.nNpcID = nil
  local szFaction = Faction:GetIcon(nFaction)
  local szIcon, szAtlas = PlayerPortrait:GetSmallIcon(nProtrait or nFaction)
  self.BgSprite.pPanel:Sprite_SetSprite("SpRoleHead", szIcon, szAtlas)
  self.BgSprite.pPanel:SetActive("SpFaction", true)
  self.BgSprite.pPanel:Sprite_SetSprite("SpFaction", szFaction)
  self.BgSprite.pPanel:SetActive("lbLevel", true)
  self.BgSprite.pPanel:Label_SetText("lbLevel", nLevel)
  function self.BgSprite.pPanel.OnTouchEvent()
    local tbData = {
      dwRoleId = nPlayerID,
      szName = szName,
      nNpcID = nNpcID,
      nLevel = nLevel
    }
    local tbPos = self.pPanel:GetRealPosition("Main")
    Ui:OpenWindowAtPos("RightPopup", tbPos.x - 232, tbPos.y - 380, "RoleSelect", tbData)
  end
end
function tbUi:OnClose()
  Operation:UnselectNpc()
end
function tbUi:OnScreenClick()
  Ui:CloseWindow(self.UI_NAME)
end
function tbUi:OnCloseToNpc(nCurNpcId, nLastNpcId)
  if nCurNpcId == 0 and self.nNpcID and self.nNpcID == nLastNpcId then
    Ui:CloseWindow(self.UI_NAME)
    return
  end
  if nCurNpcId and nCurNpcId > 0 and nCurNpcId ~= self.nNpcID then
    self:OpenNpcHead(nCurNpcId)
    return
  end
end
function tbUi:OnMapLoaded()
  Ui:CloseWindow(self.UI_NAME)
end
function tbUi:RegisterEvent()
  local tbRegEvent = {
    {
      UiNotify.emNOTIFY_CLOSE_TO_NCP,
      self.OnCloseToNpc
    },
    {
      UiNotify.emNOTIFY_MAP_LOADED,
      self.OnMapLoaded
    }
  }
  return tbRegEvent
end
