local SdkMgr = luanet.import_type("SdkInterface")
local tbUi = Ui:CreateClass("CreateNameInput")
function tbUi:OnOpen(nFaction)
  assert(nFaction)
  self.nFaction = nFaction
  self.bLockButton = nil
end
function tbUi:OnCreateRoleRespond(nCode, nRoleId)
  self.bLockButton = nil
  if nCode == 0 then
    local tbInst = Fuben:GetFubenInstance(me)
    assert(tbInst)
    tbInst:OnCreateRoleRespond(nRoleId)
  end
  if self.nCheckTimeOutTimer then
    Timer:Close(self.nCheckTimeOutTimer)
    self.nCheckTimeOutTimer = nil
  end
  SdkMgr.ReportDataLoadRole(tostring(nCode), Sdk:GetCurAppId(), tostring(SERVER_ID), Login.szReportRoleList, 1)
end
function tbUi:OnConnectLost()
  self.bLockButton = nil
end
tbUi.tbOnClick = {
  Dice = function(self)
    self.NameInputFrame:SetText(Login:GetRandomName(nil, self.nFaction))
  end,
  BtnSure = function(self)
    if self.bLockButton then
      return
    end
    local szName = self.NameInputFrame:GetText()
    if not Login:CheckNameinValid(szName) then
      return
    end
    self.bLockButton = true
    SdkMgr.SetReportTime()
    CreateRole(szName, self.nFaction)
    if not self.nCheckTimeOutTimer then
      self.nCheckTimeOutTimer = Timer:Register(Env.GAME_FPS * 4, function()
        self.nCheckTimeOutTimer = nil
        SdkMgr.ReportDataLoadRole("96002", Sdk:GetCurAppId(), tostring(SERVER_ID), Login.szReportRoleList, 1)
      end)
    end
  end
}
function tbUi:RegisterEvent()
  local tbRegEvent = {
    {
      UiNotify.emNOTIFY_CREATE_ROLE_RESPOND,
      self.OnCreateRoleRespond
    },
    {
      UiNotify.emNOTIFY_SERVER_CONNECT_LOST,
      self.OnConnectLost
    }
  }
  return tbRegEvent
end
