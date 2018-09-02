local tbUi = Ui:CreateClass("HomeScreenCommunity")
function tbUi:OnOpenEnd()
  self.pPanel:SetActive("BtnQQ", Sdk:IsLoginByQQ() or version_th)
  self.pPanel:SetActive("Btnweixin", Sdk:IsLoginByWeixin())
  if Sdk:IsLoginByWeixin() then
    self.pPanel:SetActive("BtnPrivilege", not Sdk:IsOuterChannel())
    self.pPanel:Button_SetSprite("BtnPrivilege", "Weixin_01")
  elseif Sdk:IsLoginByQQ() then
    self.pPanel:SetActive("BtnPrivilege", not Sdk:IsOuterChannel())
    self.pPanel:Button_SetSprite("BtnPrivilege", "QQ_01")
  else
    self.pPanel:SetActive("BtnPrivilege", false)
  end
  if Sdk:IsMsdk() then
    self.pPanel:SetActive("Btnxinyue", not Sdk:IsOuterChannel())
    if not (Sdk:IsLoginByWeixin() or Sdk:IsLoginByQQ()) or Sdk:IsOuterChannel() then
      if not Sdk:IsLoginByWeixin() and not Sdk:IsLoginByQQ() and Sdk:IsOuterChannel() then
        self.pPanel:Widget_SetSize("Bg", 250, 100)
      else
        self.pPanel:Widget_SetSize("Bg", 330, 100)
      end
    else
      self.pPanel:Widget_SetSize("Bg", 495, 100)
    end
  else
    self.pPanel:Widget_SetSize("Bg", 409, 100)
  end
  if Sdk:IsMsdk() then
    if Sdk:IsOuterChannel() then
      self.pPanel:ChangePosition("Btnweixin", -119, -8)
      self.pPanel:ChangePosition("BtnQQ", -119, -8)
    else
      self.pPanel:ChangePosition("Btnweixin", -198, -8)
      self.pPanel:ChangePosition("BtnQQ", -198, -8)
    end
  end
end
function tbUi:OnScreenClick()
  Ui:CloseWindow(self.UI_NAME)
end
function tbUi:OnSyncQQBuluoUrl(szUrl)
  self.szBuluoUrl = szUrl
  Sdk:OpenUrl(szUrl)
end
tbUi.tbOnClick = tbUi.tbOnClick or {}
function tbUi.tbOnClick:BtnCustomerService()
  if Sdk:IsMsdk() then
    Sdk:OpenUrl("https://kf.qq.com/touch/scene_product.html?scene_id=kf1392")
  elseif version_xm then
    Sdk:XGOpenUserCenter()
  elseif version_th then
    Sdk:OpenUrl("https://winner.in.th/main/report")
  end
end
function tbUi.tbOnClick:BtnWebsite()
  if Sdk:IsMsdk() then
    local szUrlFormat = "http://jxqy.qq.com/ingame/all/index.shtml?roleid=%d&partition=%d&platid=%d&area=%d"
    local nArea = Sdk:GetAreaId()
    local nPlatid = Sdk:GetPlatId()
    local szUrl = string.format(szUrlFormat, me.dwID, SERVER_ID, nPlatid, nArea)
    Sdk:OpenUrl(szUrl)
    RemoteServer.TLogClickWeiGuanWang()
    Ui:ClearRedPointNotify("MicroMainPage")
  else
    Sdk:OpenUrl("http://sword.winner.in.th/")
  end
end
function tbUi.tbOnClick:Btnweixin()
  Sdk:OpenUrl("http://game.weixin.qq.com/cgi-bin/h5/static/circle/index.html?jsapi=1&appid=wxacbfe7e1bb3e800f&auth_type=2&ssid=12")
  Ui:ClearRedPointNotify("WxCircle")
end
function tbUi.tbOnClick:BtnQQ()
  if Sdk:IsMsdk() then
    if self.szBuluoUrl then
      Sdk:OpenUrl(self.szBuluoUrl)
    else
      Sdk:UpdateBuluoUrl()
    end
    Ui:ClearRedPointNotify("QQBuluo")
  else
    Sdk:OpenUrl("https://www.facebook.com/groups/LegendofSwordman/")
  end
end
function tbUi.tbOnClick:BtnRestaurant()
  if Sdk:IsMsdk() then
    local szUrlFormat = "http://jxqy.qq.com/ingame/all/colleagues/index.html?roleid=%d&partition=%d&platid=%d&area=%d"
    local nArea = Sdk:GetAreaId()
    local nPlatId = Sdk:GetPlatId()
    local szUrl = string.format(szUrlFormat, me.dwID, SERVER_ID, nPlatId, nArea)
    Sdk:OpenUrl(szUrl)
    Ui:ClearRedPointNotify("Restaurant")
  elseif version_xm then
    Sdk:OpenUrl("https://www.youtube.com/playlist?list=PLWKlIf_1XaMmMlD9YLAs2JzUcjDPPfXAo")
  elseif version_th then
    Sdk:OpenUrl("https://www.facebook.com/sword.in.th/notes/")
  end
end
function tbUi.tbOnClick:Btnxinyue()
  if Sdk:IsPCVersion() then
    me.CenterMsg("请使用手机端登录")
    return
  end
  if Sdk:IsMsdk() then
    Sdk:OpenXinyueUrl()
    Ui:ClearRedPointNotify("XinyueVip")
  elseif version_th then
    Sdk:OpenUrl("https://www.facebook.com/sword.in.th/")
  end
end
function tbUi.tbOnClick:BtnPrivilege()
  if Sdk:IsMsdk() then
    local nCurPlat = Sdk:GetCurPlatform()
    Ui:OpenWindow("PrivilegePanel", nCurPlat)
  end
end
if version_xm then
  function tbUi.tbOnClick:BtnFB()
    Sdk:XGTakeFacebookReward()
    Ui:ClearRedPointNotify("XMFacebook")
    Sdk:OpenUrl("https://www.facebook.com/252128865154649")
  end
  function tbUi.tbOnClick:BtnCorporation()
    Sdk:OpenUrl("https://business.facebook.com/Efunjxqy/notes?business_id=739469666120748&ref=page_internal")
  end
  function tbUi.tbOnClick:BtnWebsite2()
    Sdk:OpenUrl("https://www.youtube.com/playlist?list=PLWKlIf_1XaMmjbyzcbfN2Jo8c6L6tCsus")
  end
end
function tbUi:RegisterEvent()
  local tbRegEvent = {
    {
      UiNotify.emNOTIFY_SYNC_QQ_BULUO_URL,
      self.OnSyncQQBuluoUrl
    }
  }
  return tbRegEvent
end
