local tbUi = Ui:CreateClass("KinJoinPanel")
function tbUi:RegisterEvent()
  local tbRegEvent = {
    {
      UiNotify.emNOTIFY_SYNC_KIN_DATA,
      self.Update,
      self
    }
  }
  return tbRegEvent
end
function tbUi:OnOpen()
  if me.nLevel < Kin.Def.nLevelLimite then
    me.CenterMsg(string.format("等级达到%d级后开放家族", Kin.Def.nLevelLimite))
    return 0
  end
  self.tbApplied = Kin:GetData("tbKinApplied") or {}
  Kin:CacheData("tbKinApplied", self.tbApplied)
  self.nCurKinId = nil
  Kin:UpdateJoinKinsData(1)
  self.pPanel:Label_SetText("Content", "")
  self:Update("JoinKins")
  local bNoKin = not Kin:HasKin()
  self.pPanel:SetActive("BtnApply", bNoKin)
  self.pPanel:SetActive("BtnCreatFamily", bNoKin)
  self.pPanel:Label_SetText("Title", bNoKin and "加入家族" or "家族列表")
  if Ui:GetRedPointState("NG_KinJoin") then
    self.pPanel:SetActive("GuideTips", true)
  else
    self.pPanel:SetActive("GuideTips", false)
  end
end
function tbUi:Update(szType, tbKinsInfo, nPage, nMaxPage)
  if szType ~= "JoinKins" then
    return
  end
  self.tbKinsInfo = tbKinsInfo or self.tbKinsInfo or {}
  self.nMaxPage = math.max(1, nMaxPage or self.nMaxPage or 1)
  self.nPage = nPage or self.nPage or 1
  self.pPanel:Label_SetText("Pages", string.format("%d/%d", self.nPage, self.nMaxPage))
  local function fnSelect(btnObj)
    self.pPanel:Label_SetText("Content", btnObj.tbItemData.szDeclaration)
    self.nCurKinId = btnObj.tbItemData.nKinId
  end
  local bNoKin = not Kin:HasKin()
  for nIndex = 1, 7 do
    local itemObj = self["FamilyJoinItem" .. nIndex]
    local tbItemData = self.tbKinsInfo[nIndex]
    if tbItemData then
      itemObj.pPanel:SetActive("Main", true)
      itemObj.pPanel:Label_SetText("FamilyName", tbItemData.szName)
      itemObj.pPanel:Label_SetText("FamilyLeadName", tbItemData.szMasterName)
      local nVipLevel = tbItemData.nVipLevel
      if not nVipLevel or nVipLevel == 0 then
        itemObj.pPanel:SetActive("VIP", false)
      else
        itemObj.pPanel:SetActive("VIP", true)
        itemObj.pPanel:Sprite_Animation("VIP", Recharge.VIP_SHOW_LEVEL[nVipLevel])
      end
      itemObj.pPanel:Label_SetText("Level", tbItemData.nLevel)
      itemObj.pPanel:Label_SetText("Number", tbItemData.nMemberCount .. "/" .. tbItemData.nMaxMemberCount)
      itemObj.pPanel:SetActive("Applied", self.tbApplied[tbItemData.nKinId] and bNoKin or false)
      local tbHonorInfo = Player.tbHonorLevelSetting[tbItemData.nHonorLevel]
      if tbHonorInfo and tbHonorInfo.ImgPrefix then
        itemObj.pPanel:SetActive("PlayerTitle", true)
        itemObj.pPanel:Sprite_Animation("PlayerTitle", tbHonorInfo.ImgPrefix)
      else
        itemObj.pPanel:SetActive("PlayerTitle", false)
      end
      itemObj.tbItemData = tbItemData
      itemObj.pPanel.OnTouchEvent = fnSelect
      if not self.nCurKinId and nIndex == 1 then
        fnSelect(itemObj)
      end
      itemObj.pPanel:Toggle_SetChecked("Main", tbItemData.nKinId == self.nCurKinId)
    else
      itemObj.pPanel:SetActive("Main", false)
    end
  end
  self.nKinCount = #self.tbKinsInfo
end
tbUi.tbOnClick = tbUi.tbOnClick or {}
function tbUi.tbOnClick:BtnClose()
  Ui:CloseWindow("KinJoinPanel")
end
function tbUi.tbOnClick:BtnPanel()
  Guide.tbNotifyGuide:ClearNotifyGuide("KinJoin")
  self.pPanel:SetActive("GuideTips", false)
end
function tbUi.tbOnClick:BtnCreatFamily()
  Ui:OpenWindow("KinCreatePanel")
end
function tbUi.tbOnClick:BtnApply()
  if not self.nCurKinId then
    me.CenterMsg("请选择家族")
    return
  end
  local bSuccess = Kin:ApplyKin(self.nCurKinId)
  if bSuccess then
    self.tbApplied[self.nCurKinId] = true
    self:Update("JoinKins")
  end
end
function tbUi.tbOnClick:BtnLeft()
  local nPage = math.max(1, self.nPage - 1)
  if nPage == self.nPage then
    return
  end
  Kin:UpdateJoinKinsData(nPage)
end
function tbUi.tbOnClick:BtnRight()
  local nPage = math.min(self.nMaxPage, self.nPage + 1)
  if nPage == self.nPage then
    return
  end
  Kin:UpdateJoinKinsData(nPage)
end
