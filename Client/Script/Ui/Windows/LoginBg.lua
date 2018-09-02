local tbLogin = Ui:CreateClass("LoginBg")
function tbLogin:OnOpen()
  self.pPanel:SetActive("movieCg", false)
  if IOS then
    self.pPanel:SetActive("movieBg", true)
    self.pPanel:SetActive("Bg", false)
  else
    self.pPanel:SetActive("movieBg", false)
    self.pPanel:SetActive("Bg", true)
  end
  Ui:CloseWindow("MapLoading")
end
function tbLogin:ShowCG()
  self.pPanel:SetActive("movieBg", false)
  self.pPanel:SetActive("movieCg", true)
end
function tbLogin:HideAllMovie()
  self.pPanel:SetActive("movieBg", false)
  self.pPanel:SetActive("movieCg", false)
end
function tbLogin:OnOpenEnd()
  Ui:OpenWindow("Login")
  if not IOS then
    Ui.CameraMgr.SetMainCameraActive(false)
  end
end
