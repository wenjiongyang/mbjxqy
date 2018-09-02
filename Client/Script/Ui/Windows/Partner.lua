local tbPartnerListItem = Ui:CreateClass("PartnerSelect")
local tbUi = Ui:CreateClass("Partner")
tbUi.MAIN_PANEL = "PartnerMainPanel"
tbUi.GRALLERY_PANEL = "PartnerGralleryPanel"
tbUi.DECOMPOSE_PANEL = "PartnerDecomposePanel"
tbUi.CARDPICKING_PANEL = "CardPickingPanel"
tbUi.tbAllPanel = {}
tbUi.tbTitleInfo = {
  [tbUi.MAIN_PANEL] = "同伴",
  [tbUi.GRALLERY_PANEL] = "图鉴",
  [tbUi.DECOMPOSE_PANEL] = "遣散",
  [tbUi.CARDPICKING_PANEL] = "招募"
}
local tbToggleButton = {
  BtnCompanion = 1,
  BtnGrallery = 2,
  BtnDecompose = 3,
  BtnCardPicking = 4
}
function Partner:SetFace(tbObj, szChildName, nNpcTemplateId)
  local nFaceId = KNpc.GetNpcShowInfo(nNpcTemplateId)
  local szAtlas, szSprite = Npc:GetFace(nFaceId)
  tbObj.pPanel:Sprite_SetSprite(szChildName, szSprite, szAtlas)
end
function tbUi:OnOpen()
  local pNpc = me.GetNpc()
  if pNpc.nShapeShiftNpcTID > 0 then
    me.CenterMsg("变身状态时不能操作", true)
    return 0
  end
end
function tbUi:OnOpenEnd(szPageType, szSubType)
  self.szPageType = szPageType or self.MAIN_PANEL
  self.PartnerMainPanel.pPanel:NpcView_Open("PartnerView")
  self.pPanel:SetActive("BtnCardPicking", me.nLevel >= CardPicker.Def.OpenLevel)
  self.pPanel:SetActive("BtnDecompose", me.nLevel >= CardPicker.Def.OpenLevel)
  self.pPanel:SetActive("BtnGrallery", me.nLevel >= CardPicker.Def.OpenLevel)
  self:Update(self.szPageType, szSubType)
  RemoteServer.CallPartnerFunc("CheckReinitResult", true)
end
function tbUi:OnClose()
  self.PartnerMainPanel.pPanel:NpcView_Close("PartnerView")
  self.CardPickingPanel:OnClose()
  Partner:UpdateRedPoint()
  Ui:CloseWindow("SkillShow")
  self.PartnerMainPanel:DoSyncPartnerPos()
  RemoteServer.CallPartnerFunc("SetPartnerPos", self.PartnerMainPanel.tbPosInfo)
  RemoteServer.ConfirmPartnerPos()
  Partner:CloseOtherUi()
  Ui:SetDebugInfo("")
end
function tbUi:Update(szMainType, szSubType)
  self.szPageType = szMainType or self.szPageType
  Partner:CloseOtherUi()
  local szUpdateFunc = self.szPageType .. "Update"
  if not self[szUpdateFunc] then
    self.szPageType = self.MAIN_PANEL
  end
  self.pPanel:Label_SetText("Title", self.tbTitleInfo[self.szPageType] or "同伴")
  self.pPanel:SetActive(self.MAIN_PANEL, false)
  self.pPanel:SetActive(self.GRALLERY_PANEL, false)
  self.pPanel:SetActive(self.DECOMPOSE_PANEL, false)
  self.pPanel:SetActive(self.CARDPICKING_PANEL, false)
  self:SelectPageShow("BtnCompanion")
  self.PartnerMainPanel.pPanel:NpcView_ShowNpc("PartnerView", 0)
  self.PartnerMainPanel.pPanel:NpcView_Close("PartnerView")
  self[szUpdateFunc](self, szSubType)
  if szSubType ~= self.MAIN_PANEL then
    self.PartnerMainPanel:DoSyncPartnerPos()
  end
end
function tbUi:CloseAll()
end
function tbUi:CardPickingPanelUpdate()
  self:SelectPageShow("BtnCardPicking")
  self.pPanel:SetActive(self.CARDPICKING_PANEL, true)
  self.CardPickingPanel:Init()
end
function tbUi:PartnerMainPanelUpdate(szSubType)
  self:SelectPageShow("BtnCompanion")
  self.pPanel:SetActive(self.MAIN_PANEL, true)
  self.PartnerMainPanel.pPanel:NpcView_Open("PartnerView")
  self.PartnerMainPanel.pPanel:NpcView_ShowNpc("PartnerView", 0)
  self.PartnerMainPanel:Update(szSubType)
end
function tbUi:PartnerGralleryPanelUpdate()
  self:SelectPageShow("BtnGrallery")
  self.pPanel:SetActive(self.GRALLERY_PANEL, true)
  self.PartnerGralleryPanel:Update()
end
function tbUi:PartnerDecomposePanelUpdate()
  self:SelectPageShow("BtnDecompose")
  self.pPanel:SetActive(self.DECOMPOSE_PANEL, true)
  self.PartnerDecomposePanel:Update()
end
function tbUi:OnAddPartner(nPartnerId)
end
function tbUi:OnDeletePartner(nPartnerId)
  if self.pPanel:IsActive(self.DECOMPOSE_PANEL) then
    self.PartnerDecomposePanel:OnDeletePartner(nPartnerId)
  end
end
function tbUi:OnUpdatePartner(nPartnerId)
  if self.pPanel:IsActive(self.MAIN_PANEL) then
    self.PartnerMainPanel:OnUpdatePartner(nPartnerId)
  end
end
function tbUi:OnAwareness(nPartnerId)
  if self.pPanel:IsActive(self.MAIN_PANEL) then
    self.PartnerMainPanel:UpdatePartnerList()
  end
end
function tbUi:OnSyncItem(nItemId, bUpdateAll)
  if self.pPanel:IsActive(self.MAIN_PANEL) then
    self.PartnerMainPanel:OnSyncItem(nItemId, bUpdateAll)
  end
end
function tbUi:OnSyncPartnerPos()
  if self.pPanel:IsActive(self.MAIN_PANEL) then
    self.PartnerMainPanel:UpdatePartnerPosInfo()
  end
end
function tbUi:SelectPageShow(szBtnName)
  for szName, _ in pairs(tbToggleButton) do
    self.pPanel:Toggle_SetChecked(szName, szBtnName == szName)
  end
end
function tbUi:CardPickingUpdate()
  self.CardPickingPanel:Update()
end
function tbUi:OnNotifyReinitData(bHasData)
  self.PartnerMainPanel.bHasReinitData = bHasData
  self.PartnerMainPanel.pPanel:Label_SetText("TxtSeverance", bHasData and "洗髓结果" or "洗髓")
end
function tbUi:OnPartnerGradeLevelup(nPartnerId, nOldGradeLevel, nNewGradeLevel)
  if self.pPanel:IsActive(self.MAIN_PANEL) then
    self.PartnerMainPanel:OnPartnerGradeLevelup(nPartnerId, nOldGradeLevel, nNewGradeLevel)
  end
end
function tbUi:RegisterEvent()
  local tbRegEvent = {
    {
      UiNotify.emNOTIFY_SYNC_PARTNER_POS,
      self.OnSyncPartnerPos
    },
    {
      UiNotify.emNOTIFY_SYNC_PARTNER_ADD,
      self.OnAddPartner
    },
    {
      UiNotify.emNOTIFY_SYNC_PARTNER_UPDATE,
      self.OnUpdatePartner
    },
    {
      UiNotify.emNOTIFY_SYNC_PARTNER_DELETE,
      self.OnDeletePartner
    },
    {
      UiNotify.emNOTIFY_PG_PARTNER_AWARENESS,
      self.OnAwareness
    },
    {
      UiNotify.emNOTIFY_CARD_PICKING,
      self.CardPickingUpdate
    },
    {
      UiNotify.emNOTIFY_SYNC_ITEM,
      self.OnSyncItem
    },
    {
      UiNotify.emNOTIFY_DEL_ITEM,
      self.OnSyncItem
    },
    {
      UiNotify.emNOTIFY_PARTNER_REINITDATA,
      self.OnNotifyReinitData
    },
    {
      UiNotify.emNOTIFY_PARTNER_GRADE_LEVELUP,
      self.OnPartnerGradeLevelup
    }
  }
  return tbRegEvent
end
tbUi.tbOnClick = tbUi.tbOnClick or {}
function tbUi.tbOnClick:BtnClose()
  Ui:CloseWindow("Partner")
end
function tbUi.tbOnClick:BtnCompanion()
  self:Update(self.MAIN_PANEL)
end
function tbUi.tbOnClick:BtnGrallery()
  self:Update(self.GRALLERY_PANEL)
end
function tbUi.tbOnClick:BtnDecompose()
  self:Update(self.DECOMPOSE_PANEL)
end
function tbUi.tbOnClick:BtnCardPicking()
  self:Update(self.CARDPICKING_PANEL)
end
