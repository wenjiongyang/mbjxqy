local tbUi = Ui:CreateClass("HouseSharePanel")
tbUi.tbOnClick = {
  BtnOut = function(self)
    Ui:CloseWindow(self.UI_NAME)
  end,
  BtnSave = function(self)
    self:TakeScreenShot(function()
      local szFileName = string.format("house_%d.jpg", os.time())
      Ui.ToolFunction.SaveScreenShot(szFileName)
      Ui:AddCenterMsg("拍照成功！照片已保存至相册")
    end)
  end,
  BtnShareWeixin = function(self)
    self:TakeScreenShot(function()
      Sdk:TlogShare("House")
      local szType = Sdk:IsLoginByQQ() and "QQ" or "WX"
      Sdk:SharePhoto(szType)
    end)
  end,
  BtnShareQQ = function(self)
    self:TakeScreenShot(function()
      Sdk:TlogShare("House")
      local szType = Sdk:IsLoginByQQ() and "QZone" or "WXMo"
      Sdk:SharePhoto(szType)
    end)
  end,
  BtnCamera = function(self)
    Ui:OpenWindowAtPos("HouseCameraPanel", 433, 130)
  end
}
function tbUi:OnOpen(bDisableViewChange)
  Ui:SetAllUiVisable(false)
  self.pPanel:SetActive("Logo", false)
  self.pPanel:SetActive("BtnCamera", not bDisableViewChange)
  if version_tx then
    local bLoginByQQ = Sdk:IsLoginByQQ()
    self.pPanel:Label_SetText("Txt1", bLoginByQQ and "分享给QQ好友" or "分享给微信好友")
    self.pPanel:Label_SetText("Txt2", bLoginByQQ and "分享到QQ空间" or "分享到朋友圈")
  end
end
function tbUi:OnClose()
  Ui:SetAllUiVisable(true)
  House:ChangeCameraSetting(unpack(House.tbNormalCameraSetting))
end
function tbUi:TakeScreenShot(fnTake)
  self.pPanel:SetActive("BtnCamera", false)
  self.pPanel:SetActive("Button", false)
  self.pPanel:SetActive("Logo", true)
  UiNotify.OnNotify(UiNotify.emNOTIFY_SHARE_PHOTO)
  Timer:Register(3, function()
    fnTake()
    return false
  end)
  Timer:Register(8, function()
    self.pPanel:SetActive("BtnCamera", true)
    self.pPanel:SetActive("Button", true)
    self.pPanel:SetActive("Logo", false)
    return false
  end)
end
