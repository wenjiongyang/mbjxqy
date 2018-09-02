local tbUi = Ui:CreateClass("KinRecruit")
function tbUi:RegisterEvent()
  local tbRegEvent = {
    {
      UiNotify.emNOTIFY_SYNC_KIN_DATA,
      self.UpdateData,
      self
    }
  }
  return tbRegEvent
end
function tbUi:OnOpen()
  Kin:UpdateRecruitSetting()
  self:UpdateData("RecruitSetting")
end
function tbUi:UpdateData(szType)
  if szType ~= "RecruitSetting" then
    return
  end
  local tbRecruitSetting = Kin:GetRecruitSetting() or {}
  self.pPanel:Label_SetText("TxtFamilyDeclare", tbRecruitSetting.szAddDeclare or "")
end
tbUi.tbOnClick = tbUi.tbOnClick or {}
function tbUi.tbOnClick:BtnSaveChange()
  local szDeclare = self.pPanel:Label_GetText("TxtFamilyDeclare")
  local tbRecruitSetting = Kin:GetRecruitSetting()
  szDeclare = ReplaceLimitWords(szDeclare) or szDeclare
  if Lib:Utf8Len(szDeclare) > Kin.Def.nMaxAddDeclareLength then
    me.CenterMsg("家族宣言超过最大长度:" .. Kin.Def.nMaxAddDeclareLength)
    return false
  end
  szDeclare = ChatMgr:Filter4CharString(szDeclare)
  if szDeclare ~= tbRecruitSetting.szAddDeclare then
    tbRecruitSetting.szAddDeclare = szDeclare
    Kin:ChangeAddDeclare(szDeclare)
  end
  Ui:CloseWindow("KinRecruit")
end
function tbUi.tbOnClick:BtnClose()
  Ui:CloseWindow("KinRecruit")
end
