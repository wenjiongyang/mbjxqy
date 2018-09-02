local tbUi = Ui:CreateClass("KinCreatePanel")
function tbUi:OnOpen()
  self.pPanel:Label_SetText("TxtCreateCost", Kin.Def.nCreationCost)
  self.pPanel:Toggle_SetChecked("Neutral", false)
  self.pPanel:Toggle_SetChecked("Song", false)
  self.pPanel:Toggle_SetChecked("Jing", false)
  self.nSelectCamp = nil
  local szAddDeclare = self.pPanel:Input_GetText("FamilyDeclaration")
  if not szAddDeclare or szAddDeclare == "" then
    self.pPanel:Input_SetText("FamilyDeclaration", "风雨历程，你我相伴。四海之内皆兄弟，欢迎加入我们家族！")
  end
  self.pPanel:UIInput_SetCharLimit("FamilyName", Kin.Def.nMaxKinNameLength)
end
tbUi.tbOnClick = tbUi.tbOnClick or {}
function tbUi.tbOnClick:BtnCancel()
  Ui:CloseWindow("KinCreatePanel")
end
function tbUi.tbOnClick:BtnTip()
  me.CenterMsg("Create Kin Tips")
end
function tbUi.tbOnClick:Song()
  self.nSelectCamp = Npc.CampTypeDef.camp_type_song
end
function tbUi.tbOnClick:Jing()
  self.nSelectCamp = Npc.CampTypeDef.camp_type_jin
end
function tbUi.tbOnClick:Neutral()
  self.nSelectCamp = Npc.CampTypeDef.camp_type_neutrality
end
function tbUi.tbOnClick:BtnConfirm()
  local szKinName = self.pPanel:Input_GetText("FamilyName")
  local szAddDeclare = self.pPanel:Input_GetText("FamilyDeclaration")
  if not szAddDeclare or szAddDeclare == "" then
    szAddDeclare = "风雨历程，你我相伴。四海之内皆兄弟，欢迎加入我们家族！"
  end
  Kin:Create(szKinName, szAddDeclare, self.nSelectCamp)
end
