local tbUi = Ui:CreateClass("HonorLevelUp")
tbUi.nOpenTime = 1
tbUi.tbFactionAction = {
  [-1] = "at01",
  [1] = "jn02",
  [2] = "jn04",
  [3] = "jn01",
  [4] = "at04",
  [5] = "jn03",
  [6] = "jn03"
}
tbUi.tbOnClick = {
  BtnSure = function(self)
    Ui:CloseWindow("HonorLevelUp")
  end
}
function tbUi.tbOnClick:BtnShowOff()
  Ui:OpenWindow("SharePanel", nil, self.szOpenShareTag, "HonorUp", me.nHonorLevel)
end
function tbUi:OnOpen()
  self.szOpenShareTag = nil
  self:UpdateInfo()
  if Sdk:IsLoginByWeixin() or Sdk:IsLoginByQQ() or Sdk:IsEfunHKTW() or version_xm then
    self.pPanel:SetActive("BtnShowOff", not Client:IsCloseIOSEntry())
  else
    self.pPanel:SetActive("BtnShowOff", false)
  end
end
function tbUi:IniNpcView()
  local tbNpcRes, tbEffectRes = me.GetNpcResInfo()
  for nPartId, nResId in pairs(tbNpcRes) do
    self.pPanel:NpcView_ChangePartRes("PartnerView", nPartId, 0)
  end
  for nPartId, nResId in pairs(tbEffectRes) do
    self.pPanel:NpcView_ChangePartEffect("PartnerView", nPartId, 0)
  end
end
function tbUi:UpdateInfo()
  local tbHonorLevel = Player.tbHonorLevel
  local tbHonorInfo = tbHonorLevel:GetHonorLevelInfo(me.nHonorLevel)
  if not tbHonorInfo then
    return
  end
  self.pPanel:Sprite_Animation("PlayerTitle", tbHonorInfo.ImgPrefix)
  self.pPanel:NpcView_Open("PartnerView")
  self:IniNpcView()
  if self.nShowTimer then
    Timer:Close(self.nShowTimer)
    self.nShowTimer = nil
  end
  self.nShowTimer = Timer:Register(Env.GAME_FPS * self.nOpenTime, self.ShowPlayer, self)
end
function tbUi:ShowPlayer()
  local tbNpcRes, tbEffectRes = me.GetNpcResInfo()
  for nPartId, nResId in pairs(tbNpcRes) do
    local nCurResId = nResId
    if nPartId == Npc.NpcResPartsDef.npc_part_horse then
      nCurResId = 0
    end
    self.pPanel:NpcView_ChangePartRes("PartnerView", nPartId, nCurResId)
  end
  for nPartId, nResId in pairs(tbEffectRes) do
    self.pPanel:NpcView_ChangePartEffect("PartnerView", nPartId, nResId)
  end
  self.nShowTimer = nil
end
function tbUi:OnClose()
  self:IniNpcView()
  self.pPanel:NpcView_Close("PartnerView")
  if self.nShowTimer then
    Timer:Close(self.nShowTimer)
    self.nShowTimer = nil
  end
  if self.nPlayStTimer then
    Timer:Close(self.nPlayStTimer)
    self.nPlayStTimer = nil
  end
end
function tbUi:PlayStandAnimaion()
  self.pPanel:NpcView_PlayAnimation("PartnerView", "sta", 1, true)
  self.nPlayStTimer = nil
end
function tbUi:PlayAnimation()
  local szAction = self.tbFactionAction[me.nFaction] or self.tbFactionAction[-1]
  self.pPanel:NpcView_PlayAnimation("PartnerView", szAction, 0.1, false)
  if self.nPlayStTimer then
    Timer:Close(self.nPlayStTimer)
    self.nPlayStTimer = nil
  end
  self.nPlayStTimer = Timer:Register(2, self.PlayStandAnimaion, self)
end
function tbUi:WndOpened(szUiName)
  if szUiName == "SharePanel" then
    self.pPanel:SetActive("BtnShowOff", false)
    self.pPanel:SetActive("BtnSure", false)
  end
end
function tbUi:WndClosed(szUiName)
  if szUiName == "SharePanel" then
    self.pPanel:SetActive("BtnShowOff", true)
    self.pPanel:SetActive("BtnSure", true)
  end
end
function tbUi:OnShareResult(bSucc, szShareType)
  if bSucc and szShareType == "WXMo" then
    self.szOpenShareTag = "ForbidWXMo"
  end
end
function tbUi:RegisterEvent()
  local tbRegEvent = {
    {
      UiNotify.emNOTIFY_LOAD_RES_FINISH,
      self.PlayAnimation,
      self
    },
    {
      UiNotify.emNOTIFY_WND_OPENED,
      self.WndOpened,
      self
    },
    {
      UiNotify.emNOTIFY_WND_CLOSED,
      self.WndClosed,
      self
    },
    {
      UiNotify.emNOTIFY_PLAT_SHARE_RESULT,
      self.OnShareResult,
      self
    }
  }
  return tbRegEvent
end
