local tbUi = Ui:CreateClass("CardPickingItem")
function tbUi:Init(szType, nItemId, fnCardBackTouch, nShowBackLevel, nPartnerId)
  self.fnCardBackTouch = fnCardBackTouch
  self.pPanel:SetActive("CardBack", false)
  self.pPanel:SetActive("Mark", false)
  self.nItemId = nItemId
  self.IsItemFlop = false
  self.Item.fnClick = nil
  if szType == "item" then
    self.pPanel:SetActive("Item", true)
    self.pPanel:SetActive("PartnerHead", false)
    self.Item:SetItemByTemplate(nItemId, 1, me.nFaction)
    self.Item.fnClick = self.Item.DefaultClick
    local szName = KItem.GetItemShowInfo(nItemId)
    self.pPanel:Label_SetText("TxtResultName", szName)
  elseif szType == "Partner" then
    self.pPanel:SetActive("Item", false)
    self.pPanel:SetActive("PartnerHead", true)
    self:InitPartner(nItemId, nShowBackLevel, nPartnerId)
  else
    assert(false)
  end
  self.pPanel:SetActive("Effect", false)
  Timer:Register(3, function()
    self.pPanel:SetActive("Effect", true)
    if CardPicker:IsItemFlop(szType, nItemId, nShowBackLevel) then
      self.pPanel:SetActive("texiao", false)
      local bIsSEffect = CardPicker:IsItemFlop(szType, nItemId, Partner.tbDes2QualityLevel.S)
      self.pPanel:SetActive("texiao3", bIsSEffect)
      self.pPanel:SetActive("texiao2", not bIsSEffect)
      self.pPanel:PlayParticleSystem("Particle System")
    else
      self.pPanel:SetActive("texiao", true)
      self.pPanel:SetActive("texiao2", false)
      self.pPanel:SetActive("texiao3", false)
      self.pPanel:PlayParticleSystem("shanguang")
    end
  end)
end
function tbUi:InitPartner(nPartnerTemplateId, nShowBackLevel, nPartnerId)
  self.PartnerHead:SetPartnerById(nPartnerTemplateId)
  local szName = GetOnePartnerBaseInfo(nPartnerTemplateId)
  self.pPanel:Label_SetText("TxtResultName", szName)
  if nPartnerId then
    local tbPartnerInfo = me.GetPartnerInfo(nPartnerId)
    local bIsBY = tbPartnerInfo.nIsNormal == 0
    self.pPanel:SetActive("Mark", bIsBY)
  end
  if CardPicker:IsItemFlop("Partner", nPartnerTemplateId, nShowBackLevel) then
    self.pPanel:SetActive("CardBack", true)
    self.pPanel:SetActive("PartnerHead", false)
    self.IsItemFlop = true
    self.nPartnerTemplateId = nPartnerTemplateId
  end
end
tbUi.tbOnClick = {}
function tbUi.tbOnClick:CardBack(szClickType)
  if not self.IsItemFlop then
    return
  end
  local bShowBigEffect = false
  for nKey, nId in pairs(Ui:GetClass("CompanionShow").tbShowCompanion) do
    local pPartner = me.GetPartnerObj(nId)
    if pPartner and pPartner.nTemplateId == self.nPartnerTemplateId then
      if szClickType ~= "FlopAll" then
        bShowBigEffect = true
        Ui:OpenWindow("CompanionShow", nId, 2)
        table.remove(Ui:GetClass("CompanionShow").tbShowCompanion, nKey)
      end
      break
    end
  end
  self.IsItemFlop = false
  self.pPanel:PlayUiAnimation("TurnoverCard", false, false, {
    tostring(self.pPanel)
  })
  if self.fnCardBackTouch then
    self.fnCardBackTouch()
  end
  if bShowBigEffect then
    self.pPanel:SetActive("texiao2", false)
    self.pPanel:SetActive("texiao3", false)
    self.pPanel:SetActive("texiao", false)
    self.pPanel:SetActive("PartnerHead", true)
  else
    Timer:Register(7, function()
      self.pPanel:SetActive("texiao3", false)
      self.pPanel:SetActive("texiao2", false)
      self.pPanel:SetActive("texiao", true)
      self.pPanel:PlayParticleSystem("shanguang")
      self.pPanel:SetActive("PartnerHead", true)
    end)
  end
end
