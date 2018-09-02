local tbUi = Ui:CreateClass("CompanionShow")
tbUi.tbShowCompanion = tbUi.tbShowCompanion or {}
tbUi.tbLowLevelCompanion = tbUi.tbLowLevelCompanion or {}
tbUi.tbHighLevelCompanion = tbUi.tbHighLevelCompanion or {}
function tbUi:RegisterEvent()
  return {
    {
      UiNotify.emNOTIFY_LOAD_RES_FINISH,
      self.ControlsPlay
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
end
function tbUi:OnShareResult(bSucc, szShareType)
  if bSucc and szShareType == "WXMo" then
    self.szOpenShareTag = "ForbidWXMo"
  end
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
function tbUi:OnOpen(nPartnerId, nType)
  self.szOpenShareTag = nil
  self.nType = 0
  self.nPartnerId = nPartnerId
  self.nType = nType
  local tbPartnerInfo = me.GetPartnerInfo(self.nPartnerId)
  self.pPanel:NpcView_Open("PartnerView")
  self.pPanel:NpcView_SetScale("PartnerView", 0.8)
  self.pPanel:SetActive("Mark", tbPartnerInfo.nIsNormal == 0)
  self.nTimer = Timer:Register(Env.GAME_FPS * 1, self.ShowCompanion, self, tbPartnerInfo)
  self.pPanel:Label_SetText("Name", tbPartnerInfo.szName)
  self.pPanel:Label_SetText("TitleLaber", "恭喜您获得新同伴" .. tbPartnerInfo.szName)
  self.pPanel:Sprite_SetSprite("QualityLevel", Partner.tbQualityLevelToSpr[tbPartnerInfo.nQualityLevel])
  self:Update()
  if Sdk:IsLoginByWeixin() or Sdk:IsLoginByQQ() or Sdk:IsEfunHKTW() or version_xm then
    self.pPanel:SetActive("BtnShowOff", not Client:IsCloseIOSEntry())
  else
    self.pPanel:SetActive("BtnShowOff", false)
  end
end
function tbUi:ShowCompanion(tbPartnerInfo)
  local _, nResId = KNpc.GetNpcShowInfo(tbPartnerInfo.nNpcTemplateId)
  self.pPanel:NpcView_ShowNpc("PartnerView", nResId)
  self.pPanel:NpcView_SetWeaponState("PartnerView", 0)
  self.nTimer = nil
end
function tbUi:ControlsPlay()
  self.pPanel:NpcView_PlayAnimation("PartnerView", "at01", 0.1, false)
  Timer:Register(5, function()
    self.pPanel:NpcView_PlayAnimation("PartnerView", "sta", 0, true)
  end)
end
function tbUi:Update()
end
tbUi.tbOnClick = tbUi.tbOnClick or {}
function tbUi.tbOnClick:BtnSure()
  self.pPanel:NpcView_ShowNpc("PartnerView", 0)
  self.pPanel:NpcView_Close("PartnerView")
  Ui:CloseWindow("CompanionShow")
  self:CloseTimer()
  if self.nType == 0 and 0 < #self.tbShowCompanion then
    table.remove(self.tbShowCompanion, 1)
    Ui:CloseCompanion(self.tbShowCompanion, 0)
  end
  if self.nType == 1 and 0 < #self.tbLowLevelCompanion then
    table.remove(self.tbLowLevelCompanion, 1)
    Ui:CloseCompanion(self.tbLowLevelCompanion, self.nType)
  end
  if self.nType == 2 and Ui:WindowVisible("CardPickingResult") == 1 and Ui:GetClass("CardPickingResult").bClose == true then
    Ui:CloseWindow("CardPickingResult")
  end
end
function tbUi.tbOnClick:BtnShowOff()
  local tbPartnerInfo = me.GetPartnerInfo(self.nPartnerId or 0) or {}
  Ui:OpenWindow("SharePanel", nil, self.szOpenShareTag, "Companion", tbPartnerInfo.nNpcTemplateId)
end
tbUi.tbOnDrag = {}
tbUi.tbOnDrag = {
  PartnerView = function(self, szWnd, nX, nY)
    self.pPanel:NpcView_ChangeDir("PartnerView", -nX, true)
  end
}
function tbUi:CloseTimer()
  if self.nTimer then
    Timer:Close(self.nTimer)
    self.nTimer = nil
  end
end
