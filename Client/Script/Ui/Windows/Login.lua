local SdkMgr = luanet.import_type("SdkInterface")
local tbLogin = Ui:CreateClass("Login")
local STATE_UNLOGIN = 0
local STATE_LOGINED = 1
local GATEWAY_HANDE_SCUCESS = 0
local GATEWAY_HANDE_FAIL = 1
local GATEWAY_HANDE_BANED = 2
local NOTIFY_REG_OUT_TIME = 1
local NOTIFY_REG_LIMIT_COUNT = 2
local QUEUE_FORWARD_DEFAULT_SPEED = 3
local QUEUE_FORWARD_POS_LIMIT = 100
local SetServrGridSprite = function(tbUi, szUiName, tbSerInfo)
  local szShowSprite
  if tbSerInfo.nType == Login.SERVER_TYPE_NEW or tbSerInfo.nType == Login.SERVER_TYPE_RECOMMAND then
    szShowSprite = "ServerTag_02"
  end
  if szShowSprite then
    tbUi.pPanel:SetActive(szUiName, true)
    tbUi.pPanel:Sprite_SetSprite(szUiName, szShowSprite)
  else
    tbUi.pPanel:SetActive(szUiName, false)
  end
end
local GetServerStateSprite = function(nStateType)
  if nStateType == Login.SERVER_TYPE_OFFLINE then
    return "Server_gray"
  elseif nStateType == Login.SERVER_TYPE_NEW or nStateType == Login.SERVER_TYPE_RECOMMAND or nStateType == Login.SERVER_TYPE_HOT then
    return "Server_red"
  elseif nStateType == Login.SERVER_TYPE_BUSY then
    return "Server_yellow"
  else
    return "Server_green"
  end
end
function tbLogin:OnOpen()
  self.bRequestedServerList = nil
  local szDesc = self:GetVersionDesc()
  self.pPanel:Label_SetText("VersionNum", string.format("版本号 %s", szDesc))
end
function tbLogin:OnOpenEnd()
  if not version_xm then
    Ui:OpenWindow("NoticePanel")
  end
  Login:CheckShowUserProtol()
  self.pPanel:SetActive("ServerSelectionWidget", false)
  self.pPanel:SetActive("Register&Entrance", true)
  self.nState = STATE_UNLOGIN
  self.bGateHanded = false
  self:Update()
  Log("open login ui")
  Login:PlaySceneSound()
  Ui:ShowNewPackTips()
  if version_vn then
    self.pPanel:SetActive("BtnHelp", false)
  end
  if version_xm and not tbLogin.bFirstOpen then
    tbLogin.bFirstOpen = true
    Sdk:XGXMTrackEvent("EVENT_FINISH_LOADRING")
  end
end
function tbLogin:RequestServerList()
  self.bRequestedServerList = true
  RequestServerList()
  if not self.nRequestedServerListCheckTimer then
    self.nRequestedServerListCheckTimer = Timer:Register(Env.GAME_FPS * 4, function()
      self.nRequestedServerListCheckTimer = nil
      SdkMgr.ReportDataSelServer(Sdk:GetCurAppId(), tostring(SERVER_ID), "95002")
    end)
  end
end
function tbLogin:OnCreate()
end
function tbLogin:OnClose()
  if self.nConnectServerTimer then
    Timer:Close(self.nConnectServerTimer)
    self.nConnectServerTimer = nil
  end
  if self.nRequestedServerListCheckTimer then
    Timer:Close(self.nRequestedServerListCheckTimer)
    self.nRequestedServerListCheckTimer = nil
  end
  self.nSelPageIndex = nil
  self:CloseQueueForwardTimer()
  self.nLastSyncPos = nil
  self.nLastSyncTime = nil
  self.nCurPos = nil
  Ui:CloseWindow("MessageBox")
  Login.tbAccSerInfo[GetAccountName()] = nil
end
local fnGetLastLoginInfo = function()
  local szAccount = GetAccountName()
  local tbLastLoginfo = Client:GetUserInfo("Login", -1)
  return tbLastLoginfo[szAccount]
end
function tbLogin:Update()
  if self.nState == STATE_UNLOGIN then
    self.pPanel:SetActive("RegisterWidget", true)
    self.pPanel:SetActive("EntranceWidget", false)
    local bMsdk = Sdk:IsMsdk()
    local bSdk = Sdk:Available()
    local bPCVersion = Sdk:IsPCVersion()
    self.pPanel:SetActive("LoginInputNode", not bSdk)
    self.pPanel:SetActive("TouristEntrance", bSdk and IOS and bMsdk and not bPCVersion)
    self.pPanel:SetActive("WeixinQQEntrance", bSdk and ANDROID and bMsdk and not bPCVersion)
    self.pPanel:SetActive("PCEntrance", bSdk and bMsdk and bPCVersion)
    self.pPanel:SetActive("BtnSingleEnter", bSdk and not bMsdk)
    if bSdk and IOS and bMsdk then
      local bWXInstalled = Sdk:IsPlatformInstalled(Sdk.ePlatform_Weixin)
      self.pPanel:SetActive("BtnWeixin2", bWXInstalled)
    end
    if bSdk and Login:IsAutoLogin() then
      if version_xm then
        Timer:Register(2, function()
          Sdk:LoginWithLocalInfo()
        end)
      else
        Sdk:LoginWithLocalInfo()
      end
      Ui:OpenWindow("LoadingTips", "自动登入中..", 5, function()
        Ui:CloseWindow("LoadingTips")
      end)
    end
  else
    self.pPanel:SetActive("RegisterWidget", false)
    self.pPanel:SetActive("EntranceWidget", true)
    local tbMyLogin = fnGetLastLoginInfo()
    if tbMyLogin then
      self:SelectServer(tbMyLogin)
    elseif self.bGateHanded then
      self:RequestServerList()
    else
      self.bWairtForShowSelServer = true
    end
  end
end
function tbLogin:SelectServer(nIdxOrTb)
  local tbSerInfo = nIdxOrTb
  if type(nIdxOrTb) == "number" then
    tbSerInfo = self.tbSerList[nIdxOrTb]
  end
  if not tbSerInfo then
    Log(debug.traceback())
    return
  end
  if tbSerInfo.nType == Login.SERVER_TYPE_OFFLINE then
    me.CenterMsg("该服正在维护，请选择其他服！")
    return
  end
  self.pPanel:SetActive("Register&Entrance", true)
  self.pPanel:SetActive("ServerSelectionWidget", false)
  self.tbSerInfo = tbSerInfo
  self:UpdateSelSerInfo()
end
function tbLogin:UpdateSelSerInfo()
  if not self.tbSerInfo then
    self.pPanel:Label_SetText("lbNewSerName", "请选择区服")
    return
  end
  self.pPanel:Label_SetText("lbNewSerName", self.tbSerInfo.szName)
end
function tbLogin:ShowSelServer()
  self.pPanel:SetActive("Register&Entrance", false)
  self.pPanel:SetActive("ServerSelectionWidget", true)
  self:RequestServerList()
  if self.tbSerList then
    self:UpdateServerList()
  end
  local tbAccSerInfo = Login:GetAccSerInfo()
  if not next(tbAccSerInfo) then
    RequestAccSerInfo()
    Login.tbAccSerInfo[GetAccountName()] = {}
  end
end
function tbLogin:UpdateServerList()
  if #self.tbSerList == 0 then
    self.ScrollView:Update(0)
    self.ScrollViewBtn:Update(0)
    return
  end
  if not self.tbSerInfo then
    local nRecmmandIndex = 1
    local nRecmmandVal = 0
    for i, v in ipairs(self.tbSerList) do
      local nTempVal = 0
      if v.nType == Login.SERVER_TYPE_RECOMMAND then
        nTempVal = 3 + MathRandom(10)
      elseif v.nType == Login.SERVER_TYPE_NEW then
        nTempVal = 2
      elseif v.nType == Login.SERVER_TYPE_NORMAL then
        nTempVal = 1
      end
      if nRecmmandVal < nTempVal then
        nRecmmandVal = nTempVal
        nRecmmandIndex = i
      end
    end
    if nRecmmandVal ~= 0 then
      self.tbSerInfo = self.tbSerList[nRecmmandIndex]
    end
  else
    local dwIndex = self.tbSerInfo.dwIndex
    self.tbSerInfo = nil
    for i, v in ipairs(self.tbSerList) do
      if v.dwIndex == dwIndex then
        self.tbSerInfo = v
        break
      end
    end
  end
  self:UpdateSelSerInfo()
  if not self.pPanel:IsActive("ServerSelectionWidget") then
    return
  end
  local tbMyAccSerInfo = Login:GetAccSerInfo()
  local tbSerGroup = {}
  local nPage = math.ceil(#self.tbSerList / 10)
  local tbHasLoginSer = {}
  local tbCanReCommandPage = {}
  local nLastCanUsePage = 1
  for j = nPage, 1, -1 do
    local tbPage = {}
    for i = 1, 5 do
      local tb = {
        [1] = self.tbSerList[(j - 1) * 10 + 1 + (i - 1) * 2],
        [2] = self.tbSerList[(j - 1) * 10 + 2 + (i - 1) * 2]
      }
      if next(tb) then
        table.insert(tbPage, tb)
        for i2, v2 in ipairs(tb) do
          if tbMyAccSerInfo[v2.dwServerId] then
            table.insert(tbHasLoginSer, v2)
          end
          if v2.nType == Login.SERVER_TYPE_RECOMMAND then
            tbCanReCommandPage[#tbSerGroup + 2] = 1
          elseif v2.nType ~= Login.SERVER_TYPE_OFFLINE then
            nLastCanUsePage = #tbSerGroup + 2
          end
        end
      end
    end
    table.insert(tbSerGroup, tbPage)
  end
  local tbHasLoginSerGroup = {}
  for nGroup = 1, math.ceil(#tbHasLoginSer / 2) do
    local tb = {
      [1] = tbHasLoginSer[1 + (nGroup - 1) * 2],
      [2] = tbHasLoginSer[2 + (nGroup - 1) * 2]
    }
    if next(tb) then
      table.insert(tbHasLoginSerGroup, tb)
    end
  end
  table.insert(tbSerGroup, 1, tbHasLoginSerGroup)
  self.nSelPageIndex = self.nSelPageIndex or 1
  if not next(tbMyAccSerInfo) then
    local nCPage, _ = next(tbCanReCommandPage)
    self.nSelPageIndex = nCPage or nLastCanUsePage
  end
  local function fnClickLeftItem(itemObj)
    local nIndex = itemObj.nIndex
    self.nSelPageIndex = nIndex
    self:UpdateServerListScrollView(tbSerGroup[nIndex])
  end
  local function fnSetLeftBnt(itemObj, nIndex)
    itemObj.nIndex = nIndex
    local tbPage = tbSerGroup[nIndex]
    if nIndex ~= 1 then
      local nFrom = 1 + 10 * (nPage + 1 - nIndex)
      local nTo = 10 * (nPage + 1 - nIndex + 1)
      itemObj.pPanel:Label_SetText("ServerName", string.format("%d~%d服", nFrom, nTo))
    else
      itemObj.pPanel:Label_SetText("ServerName", "我的服务器")
    end
    itemObj.pPanel:SetActive("NewTagNow", tbCanReCommandPage[nIndex] and true or false)
    itemObj.pPanel:Toggle_SetChecked("Main", self.nSelPageIndex == nIndex)
    itemObj.pPanel.OnTouchEvent = fnClickLeftItem
  end
  self.ScrollViewBtn:Update(#tbSerGroup, fnSetLeftBnt)
  self:UpdateServerListScrollView(tbSerGroup[self.nSelPageIndex])
end
function tbLogin:UpdateServerListScrollView(tbPage)
  if not tbPage then
    self.ScrollView:Update(0)
    return
  end
  local tbMyAccSerInfo = Login:GetAccSerInfo()
  local function fnSetServer(itemClass, nIndex)
    itemClass:SetData(self, tbPage[nIndex], nIndex, tbMyAccSerInfo)
  end
  self.ScrollView:Update(tbPage, fnSetServer)
end
tbLogin.tbOnClick = {
  BtnEnter = function(self, tbGameObj)
    if self.nState == STATE_UNLOGIN then
      local szAccount = self.InputAccount:GetText()
      if szAccount == "" then
        Ui:OpenWindow("MessageBox", "请输入账号")
        return
      end
      local NetworkSet = Login.ClientSet.Network
      local szToken = Ui.FTDebug.szToken == "" and NetworkSet.Token or Ui.FTDebug.szToken
      Login:ConnectGateWay(szAccount, szToken)
    end
  end,
  lbChangeSer = function(self)
    SdkMgr.SetReportTime()
    if self.nConnectServerTimer then
      Ui:CloseWindow("LoadingTips")
      Timer:Close(self.nConnectServerTimer)
      self.nConnectServerTimer = nil
    end
    self:ShowSelServer()
  end,
  BtnBack = function(self)
    self.pPanel:SetActive("Register&Entrance", true)
    self.pPanel:SetActive("ServerSelectionWidget", false)
  end,
  btnEntrance = function(self, szCallType)
    self.bGiveUpQueue = false
    if not self.tbSerInfo then
      Ui:OpenWindow("MessageBox", "请选择区服")
      return
    end
    if self.nConnectServerTimer then
      return
    end
    if not Login:FreeFlowReceived() and szCallType ~= "IgnoreFreeFlow" then
      Ui:OpenWindow("LoadingTips", nil, 3, function()
        self.tbOnClick.btnEntrance(self, "IgnoreFreeFlow")
        Ui:CloseWindow("LoadingTips")
      end)
      return
    end
    ConnectServer(self.tbSerInfo.dwIndex)
    if not self.bRequestedServerList then
      SdkMgr.ReportDataSelServer(Sdk:GetCurAppId(), tostring(SERVER_ID), "0")
    end
    Ui:OpenWindow("LoadingTips")
    self.bServerConnectResponse = nil
    self.nConnectServerTimer = Timer:Register(Env.GAME_FPS * 20, function()
      if not self.bServerConnectResponse then
        SdkMgr.ReportDataLoadRole("96002", Sdk:GetCurAppId(), tostring(SERVER_ID), "", 2)
        Ui:CloseWindow("LoadingTips")
        self.tbSerInfo = nil
        self:NeedReturnToLogin()
      end
      self.nConnectServerTimer = nil
    end)
    local tbLastLoginfo = Client:GetUserInfo("Login", -1)
    tbLastLoginfo[GetAccountName()] = self.tbSerInfo
    Client:SaveUserInfo()
  end,
  BtnHelp = function(self)
    if Sdk:IsMsdk() then
      if IOS then
        Sdk:OpenUrl("https://kf.qq.com/touch/scene_faq.html?scene_id=kf1386")
      else
        Sdk:OpenUrl("https://kf.qq.com/touch/scene_faq.html?scene_id=kf1384")
      end
    elseif version_xm then
      Sdk:OpenUrl("https://efunjxqy.efunen.com/event/client")
    end
  end,
  BtnNotice = function(self)
    Ui:OpenWindow("NoticePanel", true)
  end,
  BtnSwitchAccount = function(self)
    Sdk:Logout(true)
    self.nState = STATE_UNLOGIN
    self.bGateHanded = false
    Login:SetAutoLogin(false)
    self:Update()
    self:CloseQueueForwardTimer()
    self.nLastSyncPos = nil
    self.nLastSyncTime = nil
    self.nCurPos = nil
    Ui:CloseWindow("MessageBox")
  end
}
if version_tx then
  function tbLogin.tbOnClick:BtnAgreement()
    Ui:OpenWindow("AgreementPanel")
  end
end
if version_xm then
  function tbLogin.tbOnClick:BtnService()
    Sdk:OpenUrl("https://www.facebook.com/252128865154649")
  end
end
local tbSdkLoginBtn = {
  BtnWeixin = Sdk.ePlatform_Weixin,
  BtnWeixin2 = Sdk.ePlatform_Weixin,
  BtnQQ = Sdk.ePlatform_QQ,
  BtnQQ2 = Sdk.ePlatform_QQ,
  BtnTourist = Sdk.ePlatform_Guest,
  BtnWeixinIos = Sdk.ePlatform_Weixin,
  BtnWeixinAndroid = Sdk.ePlatform_Weixin,
  BtnQQIos = Sdk.ePlatform_QQ,
  BtnQQAndroid = Sdk.ePlatform_QQ
}
local tbForIOSServer = {BtnQQIos = true, BtnWeixinIos = true}
local fnConfirm = function()
  Sdk:OpenUrlByOutsideWeb("http://guanjia.qq.com/product/gameassitant/")
  Sdk:DirectExit()
end
if Sdk:IsMsdk() then
  for szBtnName, nPlatform in pairs(tbSdkLoginBtn) do
    tbLogin.tbOnClick[szBtnName] = function(self)
      if Sdk:IsPCVersion() then
        local szEquipId = Ui.UiManager.GetEquipId()
        if not szEquipId or string.sub(szEquipId, 1, 5) ~= "66666" then
          Ui:OpenWindow("MessageBox", "您当前使用的模拟器不支持《剑侠情缘电脑版》，请在腾讯手游助手中安装。", {
            {fnConfirm}
          }, {"确定"})
          return
        end
      end
      if self.nState == STATE_UNLOGIN then
        Sdk:Login(nPlatform, tbForIOSServer[szBtnName])
      end
    end
  end
else
  function tbLogin.tbOnClick:BtnSingleEnter()
    if self.nState == STATE_UNLOGIN then
      Sdk:Login()
    end
  end
end
function tbLogin:GatewayConnectResult(nResult)
  if nResult ~= 1 then
    Ui:CloseWindow("MessageBox")
    if ANDROID and GetTime() < Lib:GetDate2Time(201605311000) then
      Ui:OpenWindow("MessageBoxBig", string.format(XT("      亲爱的少侠，当前服务器尚未开启。本次限量不删档测试开启时间，安卓版本：[FFFE0D]5月31日上午12点[-]；iOS版本：[FFFE0D]6月2日[-]。请到时再尝试登录抢注！如有疑问，欢迎通过官方QQ群或官方微信公众号进行反馈，《剑侠情缘》感谢您的支持！\n      官方QQ群：174387680，119195846\n      官方微信公众号：jianxqy\n"), szTimeDesc), {
        {}
      }, {"确定"}, 0)
    elseif IOS and GetTime() < Lib:GetDate2Time(201606021000) then
      Ui:OpenWindow("MessageBoxBig", string.format(XT("      亲爱的少侠，当前服务器尚未开启。服务器开启时间：[FFFE0D]6月2日上午12点[-]。\n      如有疑问，欢迎通过官方QQ群或官方微信公众号进行反馈，《剑侠情缘》感谢您的支持！\n      官方QQ群：174387680，119195846\n      官方微信公众号：jianxqy\n"), szTimeDesc), {
        {}
      }, {"确定"}, 0)
    else
      Ui:OpenWindow("MessageBox", "连接服务器失败")
    end
    Login:SetNextLoginTime()
  end
end
function tbLogin:GatewayConnectLost()
  Ui:OpenWindow("MessageBox", "与服务器断开连接")
  self.nState = STATE_UNLOGIN
  Login:SetAutoLogin(false)
  self:Update()
  self.bGateHanded = false
  self:CloseQueueForwardTimer()
  self.nLastSyncPos = nil
  self.nLastSyncTime = nil
  self.nCurPos = nil
end
function tbLogin:ServerConnnectResult(nResult)
  if self.nConnectServerTimer then
    Ui:CloseWindow("LoadingTips")
    Timer:Close(self.nConnectServerTimer)
    self.nConnectServerTimer = nil
  end
  if nResult ~= 1 then
    self:NeedReturnToLogin()
  end
end
function tbLogin:OnQueueNotify(nPos, nGiveUp)
  if self.nConnectServerTimer then
    Ui:CloseWindow("LoadingTips")
    Timer:Close(self.nConnectServerTimer)
    self.nConnectServerTimer = nil
  end
  if nPos ~= 0 then
    if not self.bGiveUpQueue then
      self:OnShowQueuePos(nPos)
    else
      self:CloseQueueForwardTimer()
    end
  elseif nGiveUp == 1 then
    self:CloseQueueForwardTimer()
    self.nLastSyncPos = nil
    self.nLastSyncTime = nil
    self.nCurPos = nil
    Ui:CloseWindow("MessageBox")
  end
end
function tbLogin:OnShowQueuePos(nPos)
  self:CloseQueueForwardTimer()
  if nPos <= QUEUE_FORWARD_POS_LIMIT then
    self:ShowQueMsg(nPos)
    self:CloseQueueForwardTimer()
  else
    if not self.nCurPos then
      self:ShowQueMsg(nPos)
    end
    local nForwardInterval = QUEUE_FORWARD_DEFAULT_SPEED
    if self.nLastSyncPos and self.nLastSyncTime then
      local nPosDiff = self.nLastSyncPos - nPos
      local nTimeDiff = GetTime() - self.nLastSyncTime
      if nPosDiff ~= 0 then
        local nInterval = nTimeDiff / nPosDiff
        if self.nCurPos and nPos < self.nCurPos then
          nInterval = nInterval * 0.5
        else
          nInterval = nInterval * 1.5
        end
        if nInterval > 0 then
          nForwardInterval = nInterval
        end
      else
        nForwardInterval = nForwardInterval * 5
      end
    end
    nForwardInterval = math.max(nForwardInterval, 0.5)
    self.nQueueTimer = Timer:Register(Env.GAME_FPS * nForwardInterval, function()
      local nFakePos = self.nCurPos - 1
      if nFakePos > 0 then
        self:ShowQueMsg(self.nCurPos - 1)
      end
      return true
    end)
  end
  self.nLastSyncPos = nPos
  self.nLastSyncTime = GetTime()
end
function tbLogin:CloseQueueForwardTimer()
  if not self.nQueueTimer then
    return
  end
  Timer:Close(self.nQueueTimer)
  self.nQueueTimer = nil
end
function tbLogin:OnHandShakeEnd(byRet)
  if byRet == 5 then
    Ui:ShowVersionTips()
  end
  self.bServerConnectResponse = true
  Ui:CloseWindow("LoadingTips")
  SdkMgr.SetReportTime()
end
function tbLogin:ShowQueMsg(nPos)
  self.nCurPos = nPos
  if self.nState == STATE_UNLOGIN then
    return
  end
  local szContent = string.format("服务器排队中,前面还有 [FFFE0D]%d位[-]", nPos)
  if Ui:WindowVisible("MessageBox") then
    UiNotify.OnNotify(UiNotify.emNOTIFY_REFRESH_MESSAGE_BOX, szContent)
    return
  end
  local function fnNo()
    GiveUpWaitQueue()
    self.bGiveUpQueue = true
    self:CloseQueueForwardTimer()
    self.nLastSyncPos = nil
    self.nLastSyncTime = nil
    self.nCurPos = nil
  end
  Ui:OpenWindow("MessageBox", szContent, {
    {fnNo}
  }, {"放弃"})
end
function tbLogin:OnSyncServerListDone()
  if self.nRequestedServerListCheckTimer then
    Timer:Close(self.nRequestedServerListCheckTimer)
    self.nRequestedServerListCheckTimer = nil
  end
  self.tbSerList = GetServerList()
  self:UpdateServerList()
  SdkMgr.ReportDataSelServer(Sdk:GetCurAppId(), tostring(SERVER_ID), "0")
  local szServerMapName = "ServerMap" .. Sdk:GetCurPlatform()
  local tbServerMap = Client:GetDirFileData(szServerMapName)
  for _, tbServerInfo in ipairs(self.tbSerList) do
    tbServerMap[tbServerInfo.dwServerId] = tbServerInfo.szName
  end
  Client:SaveDirFileData(szServerMapName)
end
function tbLogin:GatewayHandSuccess(nRetCode)
  if nRetCode ~= 0 then
    if nRetCode == GATEWAY_HANDE_BANED then
      Ui:OpenWindow("MessageBox", XT("此帐号已被冻结"))
    else
      Ui:OpenWindow("MessageBox", string.format("登入失败, 错误代码:%d", nRetCode))
    end
    Login:SetNextLoginTime()
    return
  end
  if Sdk:IsMsdk() then
    Sdk:QueryFriendsInfo()
  end
  self.nState = STATE_LOGINED
  self:Update()
  self.bGateHanded = true
  if self.bWairtForShowSelServer then
    self:RequestServerList()
    self.bWairtForShowSelServer = nil
  end
  Ui:CloseWindow("MessageBox")
  Ui:CloseWindow("LoadingTips")
  Login:ResetNextLoginTime()
end
function tbLogin:OnNeedAccountActive(nRetCode)
  Ui:CloseWindow("LoadingTips")
  if nRetCode == 0 then
    local fnCallBack = function(szInputCode)
      if szInputCode == "" then
        return 1
      end
      RequestAccountActive(szInputCode)
    end
    Ui:OpenWindow("InputBox", "请输入激活码", fnCallBack)
  else
    Ui:OpenWindow("MessageBox", "激活码不正确")
  end
end
function tbLogin:OnNeedAccountReg(nRetCode)
  if nRetCode == NOTIFY_REG_OUT_TIME then
    Ui:OpenWindow("MessageBoxBig", XT("   亲爱的少侠目前限量的测试资格已经发放完毕。您可以前往官方网站进行预约，将有机会获得额外的测试资格！\n   如有疑问,欢迎通过官方QQ群或官方微信公众号进行反馈,《剑侠情缘》感谢您的支持！\n   官方QQ群：174387680，119195846\n   官方微信公众号：jianxqy\n   "), {
      {}
    }, {"确定"}, 0)
  else
    local nCurTime = GetTime()
    local tbTime = os.date("*t", nCurTime - 36000 + 86400)
    local szTimeDesc = string.format(XT("%d月%d日上午10点"), tbTime.month, tbTime.day)
    Ui:OpenWindow("MessageBoxBig", string.format(XT("      亲爱的少侠，今日登录注册的帐号已经达到上限。请于[FFFE0D]%s[-]再尝试登录抢注。\n      如有疑问，欢迎通过官方QQ群或官方微信公众号进行反馈，《剑侠情缘》感谢您的支持！\n      官方QQ群：174387680，119195846\n      官方微信公众号：jianxqy\n"), szTimeDesc), {
      {}
    }, {"确定"}, 0)
  end
end
function tbLogin:GetVersionDesc(nVersion)
  nVersion = nVersion or GAME_VERSION
  local szDesc = string.format("v1.%d.%d", math.floor(nVersion / 100000), nVersion % 100000)
  return szDesc
end
function tbLogin:NeedReturnToLogin()
  Ui:OpenWindow("MessageBox", "连接服务器失败", {
    {
      function()
        Ui:ReturnToLogin()
        CloseServerConnect()
      end
    }
  }, {
    "重新登录"
  }, nil, nil, true)
end
function tbLogin:OnNeedClientUpdate(nGameVersion)
  local szVersionInfo = self:GetVersionDesc(nGameVersion)
  Ui:OpenWindow("MessageBox", string.format("有新的客户端[%s]更新，请重进游戏更新", szVersionInfo), {
    {
      Sdk.DirectExit,
      Sdk
    }
  }, {
    "退出游戏"
  }, nil, nil, true)
end
function tbLogin:OnServerUnavailable(dwServerIndex)
  me.CenterMsg(XT("该服正在维护，请选择其他服！"))
  if self.nConnectServerTimer then
    Ui:CloseWindow("LoadingTips")
    Timer:Close(self.nConnectServerTimer)
    self.nConnectServerTimer = nil
  end
  self:ShowSelServer()
end
function tbLogin:OnServerLoginFail(nRetCode)
  local tbMsg = {
    "维护中",
    "需要排队",
    "服务器人数过多",
    "服务器关闭创建角色功能",
    "      亲爱的少侠，您所选择服务器的注册帐号数已达上限。请尝试在其他服务器进行登录抢注。\n      如有疑问，欢迎通过官方QQ群或官方微信公众号进行反馈，《剑侠情缘》感谢您的支持！\n      官方QQ群：174387680，119195846\n      官方微信公众号：jianxqy"
  }
  if self.nConnectServerTimer then
    Ui:CloseWindow("LoadingTips")
    Timer:Close(self.nConnectServerTimer)
    self.nConnectServerTimer = nil
  end
  Ui:OpenWindow("MessageBoxBig", tbMsg[nRetCode] or "登录失败，未知错误！", {
    {}
  }, {"确定"}, 0)
end
function tbLogin:OnTouchReturn()
  if self.pPanel:IsActive("ServerSelectionWidget") then
    self.pPanel:SetActive("ServerSelectionWidget", false)
    self.pPanel:SetActive("Register&Entrance", true)
  else
    Sdk:Exit()
  end
end
function tbLogin:RegisterEvent()
  local tbRegEvent = {
    {
      UiNotify.emNOTIFY_GATEWAY_CONNECT,
      self.GatewayConnectResult
    },
    {
      UiNotify.emNOTIFY_GATEWAY_CONNECT_LOST,
      self.GatewayConnectLost
    },
    {
      UiNotify.emNOTIFY_GATEWAY_LOGIN_RSP,
      self.GatewayHandSuccess
    },
    {
      UiNotify.emNOTIFY_SERVER_CONNECT,
      self.ServerConnnectResult
    },
    {
      UiNotify.emNOTIFY_LOGIN_QUEUE_NOTIFY,
      self.OnQueueNotify
    },
    {
      UiNotify.emNOTIFY_LOGIN_HAND_SHAKE_END,
      self.OnHandShakeEnd
    },
    {
      UiNotify.emNOTIFY_UPDATE_SERVER_LIST,
      self.OnSyncServerListDone
    },
    {
      UiNotify.emNOTIFY_SYNC_ACC_SER_INFO,
      self.UpdateServerList
    },
    {
      UiNotify.emNOTIFY_NEED_ACCOUT_ACTIVE,
      self.OnNeedAccountActive
    },
    {
      UiNotify.emNOTIFY_NEED_CLIENT_UPDATE,
      self.OnNeedClientUpdate
    },
    {
      UiNotify.emNOTIFY_NEED_ACCOUT_REG,
      self.OnNeedAccountReg
    },
    {
      UiNotify.emNOTIFY_LOGIN_SERVER_UNAVAILABLE,
      self.OnServerUnavailable
    },
    {
      UiNotify.emNOTIFY_LOGIN_SERVER_FAIL,
      self.OnServerLoginFail
    }
  }
  return tbRegEvent
end
local tbUi = Ui:CreateClass("ServerListGrid")
function tbUi:SetData(tbParent, tbSerGroup, nIndex, tbAccSerInfo)
  self.tbParent = tbParent
  self.tbSerGroup = tbSerGroup
  self.nIndex = nIndex
  tbAccSerInfo = tbAccSerInfo or {}
  for i = 1, 2 do
    local tbSerInfo = tbSerGroup[i]
    if not tbSerInfo then
      self.pPanel:SetActive("btnServer" .. i, false)
    else
      self.pPanel:SetActive("btnServer" .. i, true)
      SetServrGridSprite(self, "NewTag" .. i, tbSerInfo)
      self.pPanel:Label_SetText("lbSerName" .. i, tbSerInfo.szName)
      if tbAccSerInfo[tbSerInfo.dwServerId] then
        self.pPanel:SetActive("severTag_role" .. i, true)
        if version_tx then
          self.pPanel:Label_SetText("lbRoleLevel" .. i, string.format("%s级", tbAccSerInfo[tbSerInfo.dwServerId]))
        else
          self.pPanel:Label_SetText("lbRoleLevel" .. i, "Lv." .. tbAccSerInfo[tbSerInfo.dwServerId])
        end
      else
        self.pPanel:SetActive("severTag_role" .. i, false)
      end
      self.pPanel:Sprite_SetSprite("severTag_State" .. i, GetServerStateSprite(tbSerInfo.nType))
    end
  end
end
tbUi.tbOnClick = {}
function tbUi.tbOnClick:btnServer1()
  self.tbParent:SelectServer(self.tbSerGroup[1])
end
function tbUi.tbOnClick:btnServer2()
  self.tbParent:SelectServer(self.tbSerGroup[2])
end
