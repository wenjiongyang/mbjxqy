local tbUi = Ui:CreateClass("NpcDialog")
function tbUi:OnOpen(tbDialogInfo, bIsClient, szName, nNpcTemplateId, nSoundId, nResId, nBodyResId, nWeaponResId)
  self.szName = szName or "???"
  self.nNpcTemplateId = nNpcTemplateId or 0
  self.nResId = nResId
  self.nBodyResId = nBodyResId
  self.nWeaponResId = nWeaponResId
  self.bIsClient = bIsClient
  self.tbDialogInfo = tbDialogInfo or {}
  if nSoundId and nSoundId > 0 then
    Ui:PlayNpcSond(nSoundId)
  end
  self.pPanel:NpcView_Open("PartnerView")
  self.pPanel:NpcView_SetModePos("PartnerView", unpack(Npc.tbDialogModelPos[0]))
  self.pPanel:NpcView_ChangeDir("PartnerView", 180, false)
  self:Update()
  Ui:CloseWindow("ItemBox")
end
function tbUi:Update()
  if self.nNpcTemplateId and self.nNpcTemplateId > 0 then
    local _, nResId = KNpc.GetNpcShowInfo(self.nNpcTemplateId)
    if self.nResId then
      nResId = self.nResId
    end
    local tbPos = Npc.tbDialogModelPos[nResId] or Npc.tbDialogModelPos[0]
    self.pPanel:NpcView_SetModePos("PartnerView", unpack(tbPos))
    if self.nBodyResId and self.nBodyResId ~= 0 or self.nWeaponResId and self.nWeaponResId ~= 0 then
      if self.nBodyResId then
        self.pPanel:NpcView_ChangePartRes("PartnerView", Npc.NpcResPartsDef.npc_part_body, self.nBodyResId)
      end
      if self.nWeaponResId then
        self.pPanel:NpcView_ChangePartRes("PartnerView", Npc.NpcResPartsDef.npc_part_weapon, self.nWeaponResId)
      end
    else
      self.pPanel:NpcView_ShowNpc("PartnerView", nResId)
    end
    self.pPanel:NpcView_SetAnimationSpeed("PartnerView", 0.5)
    self.pPanel:SetActive("NpcBust", false)
  else
    self.pPanel:NpcView_ShowNpc("PartnerView", 0)
    self.pPanel:SetActive("NpcBust", true)
    local szAtlas, szSprite = Npc:GetFace(100)
    self.pPanel:Sprite_SetSprite("NpcBust", szSprite, szAtlas)
  end
  self.pPanel:Label_SetText("Name", self.szName)
  self.pPanel:Label_SetText("Dialogue", self.tbDialogInfo.Text or "虾米？？")
  self.tbDialogInfo.OptList = self.tbDialogInfo.OptList or {}
  local function fnSetItem(ItemObj, nIndex)
    local tbOpt = self.tbDialogInfo.OptList[nIndex]
    ItemObj.pPanel:Label_SetText("EntranceName", tbOpt.Text)
    if tbOpt.Callback then
      function ItemObj.BtnEntrance.pPanel.OnTouchEvent(ButtonObj)
        if self.bIsClient then
          Dialog:OnDialogSelect(nIndex)
        else
          RemoteServer.OnDialogSelect(nIndex)
        end
        Ui:CloseWindow(self.UI_NAME)
      end
    else
      function ItemObj.BtnEntrance.pPanel.OnTouchEvent(ButtonObj)
        Ui:CloseWindow(self.UI_NAME)
      end
    end
  end
  self.ScrollView:Update(#self.tbDialogInfo.OptList, fnSetItem)
  self.ScrollView:GoTop()
end
function tbUi:AutoClose()
  Ui:CloseWindow(self.UI_NAME)
end
function tbUi:RegisterEvent()
  local tbRegEvent = {
    {
      UiNotify.emNOTIFY_SHOW_DIALOG,
      self.AutoClose
    }
  }
  return tbRegEvent
end
function tbUi:OnScreenClick(szClickUi)
  Ui:CloseWindow(self.UI_NAME)
end
function tbUi:OnClose()
  self.pPanel:NpcView_Close("PartnerView")
end
tbUi.tbOnDrag = {
  PartnerView = function(self, szWnd, nX, nY)
    self.pPanel:NpcView_ChangeDir("PartnerView", -nX, true)
  end
}
