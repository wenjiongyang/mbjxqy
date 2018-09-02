local _Pandora = luanet.import_type("PandoraService")
Pandora.tbShowInfo = Pandora.tbShowInfo or {}
function Pandora:IsEnable()
  if not Sdk:IsMsdk() then
    return false
  end
  if Client:IsCloseIOSEntry() then
    return false
  end
  if IOS or ANDROID then
    return true
  end
  return false
end
function Pandora:GetTotalSwitch()
  return _Pandora.GetTotalSwitch()
end
function Pandora:OnHandleGeneralCmd(tbParam)
  Log("Pandora:OnHandleGeneralCmd")
  Lib:LogTB(tbParam)
  if not Pandora:IsEnable() then
    return
  end
  if not tbParam.type then
    Log("Pandora OnHandleGeneralCmd not have type tbParam")
    return
  end
  local fnProcess = Pandora[tostring(tbParam.type)]
  if fnProcess then
    fnProcess(tbParam)
  else
    Log("Pandora unimpl process", tbParam.type)
  end
end
function Pandora:OnLogin(dwRoleId, nFaction)
  Log("Pandora:OnLogin", tostring(dwRoleId))
  if not Pandora:IsEnable() then
    return
  end
  if not Sdk:IsLoginByQQ() and not Sdk:IsLoginByWeixin() then
    return
  end
  local szAccountType = "qq"
  if Sdk:IsLoginByWeixin() then
    szAccountType = "wx"
  end
  local nQQInstalled = 0
  local nWXInstalled = 0
  if Sdk:IsPlatformInstalled(Sdk.ePlatform_QQ) then
    nQQInstalled = 1
  end
  if Sdk:IsPlatformInstalled(Sdk.ePlatform_Weixin) then
    nWXInstalled = 1
  end
  local msdkInfo = Sdk:GetMsdkInfo()
  local tbParam = {
    sRoleId = tostring(dwRoleId),
    sOpenId = msdkInfo.szOpenId,
    sAcountType = szAccountType,
    sArea = tostring(Sdk:GetAreaId()),
    sPlatID = tostring(Sdk:GetPlatId()),
    sPartition = tostring(Sdk:GetServerId()),
    sAppId = Sdk:GetCurAppId(),
    sAccessToken = msdkInfo.szOpenKey,
    sPayToken = msdkInfo.szPayToken,
    sGameVer = Ui:GetClass("Login"):GetVersionDesc(),
    sQQInstalled = tostring(nQQInstalled),
    sWXInstalled = tostring(nWXInstalled),
    sServiceType = "jxqy",
    sGameName = "jxqy",
    sGuildName = tostring(nFaction),
    sIsPCVersion = tostring(Sdk:IsPCVersion()),
    sIsLoginForIOS = tostring(Sdk:IsLoginForIOS()),
    sExtend = ""
  }
  Lib:LogTB(tbParam)
  _Pandora.PlayerLogin(tbParam)
  UiNotify:RegistNotify(UiNotify.emNOTIFY_CHANGE_FIGHT_STATE, self.OnChangeFightState, self)
end
function Pandora:OnLogout()
  Log("Pandora:OnLogout")
  self.tbShowInfo = {}
  self.bOpenPL = false
  self.bWelfareActivity = false
  self.bWillShowPL = false
  if not Pandora:IsEnable() then
    return
  end
  if Sdk:IsLoginByGuest() then
    return
  end
  UiNotify:UnRegistNotify(UiNotify.emNOTIFY_CHANGE_FIGHT_STATE, self)
  _Pandora.PlayerLogout()
end
function Pandora:IsShowIcon(szModule, szTab)
  if not szModule or not szTab then
    return false
  end
  local tbModule = Pandora.tbShowInfo[szModule]
  if not tbModule then
    return false
  end
  local tbTab = tbModule[szTab]
  if not tbTab then
    return false
  end
  return tbTab.bIsShowIcon
end
function Pandora:IsShowRedPoint(szModule, szTab)
  if not szModule or not szTab then
    return false
  end
  local tbModule = Pandora.tbShowInfo[szModule]
  if not tbModule then
    return false
  end
  local tbTab = tbModule[szTab]
  if not tbTab then
    return false
  end
  return tbTab.bIsShowRedPoint
end
function Pandora:GetShowName(szModule, szTab)
  if not szModule or not szTab then
    return nil
  end
  local tbModule = Pandora.tbShowInfo[szModule]
  if not tbModule then
    return nil
  end
  local tbTab = tbModule[szTab]
  if not tbTab then
    return nil
  end
  if tbTab.szShowName == "" then
    return nil
  end
  return tbTab.szShowName
end
function Pandora:GetItemDesc(szTemplateId)
  local nTemplateId = tonumber(szTemplateId)
  if not nTemplateId then
    return
  end
  local tbInfo = KItem.GetItemBaseProp(nTemplateId)
  if not tbInfo then
    return
  end
  return tbInfo.szIntro
end
function Pandora:OpenPL()
  if not Pandora:IsEnable() then
    return
  end
  Pandora.bOpenPL = true
  _Pandora.DoAction({type = "OpenPL", content = "EnterGame"})
end
function Pandora:Open(szModule, szTab)
  if not Pandora:IsEnable() then
    return
  end
  if szTab == "Webview" then
    _Pandora.DoAction({
      type = "OpenWebview",
      module = szModule,
      tab = szTab
    })
  else
    _Pandora.DoAction({
      type = "Open",
      module = szModule,
      tab = szTab
    })
  end
end
function Pandora:Hide(szModule, szTab)
  if not Pandora:IsEnable() then
    return
  end
  _Pandora.DoAction({
    type = "Hide",
    module = szModule,
    tab = szTab
  })
end
function Pandora:ClosePanel(szModule)
  if not Pandora:IsEnable() then
    return
  end
  _Pandora.DoAction({type = "Close", module = szModule})
end
function Pandora:OnWindowClose(szUiName)
  if not Pandora:IsEnable() then
    return
  end
  _Pandora.DoAction({
    type = "GamePanelClosed",
    content = szUiName
  })
end
function Pandora:CloseAllPanel()
  if not Pandora:IsEnable() then
    return
  end
  _Pandora.CloseAllPanel()
end
function Pandora:CheckPushNewInfomation(szModule, szTab, szShowName, nFlag)
  if szModule ~= "NewInformationPanel" then
    return
  end
  local tbInfo = {
    szKey = szTab,
    szTitle = szShowName,
    nShowPriority = 999,
    nOperationType = nFlag,
    szUiName = "Normal",
    szTimeFunc = "fnCheckPandora",
    szClickFunc = "fnClickPandora",
    szSwitchFunc = "fnSwitchPandora",
    szCheckShowFunc = "fnCheckShowPandora",
    szCheckRpFunc = "fnPandoraCheckRp"
  }
  NewInformation:AddLocalSetting(tbInfo)
  NewInformation:PushLocalInformation()
end
function Pandora.ShowIcon(tbParam)
  local szModule = tostring(tbParam.module)
  local szTab = tostring(tbParam.tab)
  local szContent = tostring(tbParam.content)
  local szShowName = tostring(tbParam.showName)
  local bIsShow = szContent == "1"
  local nFlag = tonumber(tbParam.flag)
  Pandora.tbShowInfo[szModule] = Pandora.tbShowInfo[szModule] or {}
  Pandora.tbShowInfo[szModule][szTab] = Pandora.tbShowInfo[szModule][szTab] or {}
  local tbShowInfo = Pandora.tbShowInfo[szModule][szTab]
  tbShowInfo.bIsShowIcon = bIsShow
  tbShowInfo.szShowName = szShowName
  if szTab ~= "LuckyStar" then
    Pandora:CheckPushNewInfomation(szModule, szTab, szShowName, nFlag)
  elseif bIsShow then
    local tbRedpoint = {}
    table.insert(tbRedpoint, "BtnLuckyStar")
    Ui:InitRedPointNode("NewMessageRedPoint", tbRedpoint)
    Ui:SetRedPointNotify("BtnLuckyStar")
  else
    Ui:ClearRedPointNotify("BtnLuckyStar")
  end
  UiNotify.OnNotify(UiNotify.emNOTIFY_PANDORA_REFRESH_ICON, szModule, szTab, tbShowInfo.bIsShowIcon, tbShowInfo.bIsShowRedPoint)
end
function Pandora.ShowRedPoint(tbParam)
  local szModule = tostring(tbParam.module)
  local szTab = tostring(tbParam.tab)
  local szContent = tostring(tbParam.content)
  local bIsShow = szContent == "1"
  Pandora.tbShowInfo[szModule] = Pandora.tbShowInfo[szModule] or {}
  Pandora.tbShowInfo[szModule][szTab] = Pandora.tbShowInfo[szModule][szTab] or {}
  local tbShowInfo = Pandora.tbShowInfo[szModule][szTab]
  tbShowInfo.bIsShowRedPoint = bIsShow
  NewInformation:CheckRedPoint()
  UiNotify.OnNotify(UiNotify.emNOTIFY_PANDORA_REFRESH_ICON, szModule, szTab, tbShowInfo.bIsShowIcon, tbShowInfo.bIsShowRedPoint)
end
function Pandora.ClosePL(tbParam)
  if Pandora.bWelfareActivity then
    Ui:OpenWindow("WelfareActivity", "OnHook")
  end
  Pandora.bWelfareActivity = false
  Pandora.bOpenPL = false
end
function Pandora.OpenUrl(tbParam)
  Sdk:OpenUrl(tostring(tbParam.content))
end
function Pandora.RefreshDiamond(tbParam)
  Sdk:UpdateBalanceInfo()
end
function Pandora.ShowLoading(tbParam)
  Ui:OpenWindow("LoadingTips", tostring(tbParam.content))
end
function Pandora.HideLoading(tbParam)
  Ui:CloseWindow("LoadingTips")
end
function Pandora.GoTo(tbParam)
  Ui:CloseWindow("NewInformationPanel")
  local szClassName = tostring(tbParam.module)
  local szTabName = tostring(tbParam.tab)
  if szTabName == "" then
    szTabName = nil
  end
  if szClassName == "Mail" then
    Ui:OpenWindow("ChatLargePanel", ChatMgr.nChannelMail)
  elseif szClassName == "WelfareActivity" then
    local nMinLevel, _ = WelfareActivity:GetActivityOpenLevel(szTabName)
    if nMinLevel and nMinLevel > me.nLevel then
      me.CenterMsg("您的级别不够，暂时无法参加活动")
    else
      Ui:OpenWindow("WelfareActivity", szTabName)
    end
  elseif szClassName == "NewInformationPanel" then
    local tbList = NewInformation:GetShowActivity()
    local bShow = false
    if szTabName then
      for _, szKey in pairs(tbList) do
        if szKey == szTabName then
          bShow = true
          break
        end
      end
    else
      bShow = true
    end
    if bShow then
      Ui:OpenWindow("NewInformationPanel", szTabName)
    else
      me.CenterMsg("您的级别不够，暂时无法参加活动")
    end
  elseif szClassName == "CalendarPanel" then
    local nTabIdx = szTabName and tonumber(szTabName) or 1
    Ui:OpenWindow(szClassName, nTabIdx)
  else
    Ui:OpenWindow(szClassName, szTabName)
  end
end
function Pandora.ShowItemDetail(tbParam)
  Log("Pandora.ShowItemDetail")
  local nTemplate = tonumber(tbParam.content)
  if not nTemplate then
    return
  end
  local tbInfo = {
    nTemplate = nTemplate,
    nFaction = me.nFaction
  }
  Item:ShowItemDetail(tbInfo)
end
function Pandora.GoPandora(tbParam)
  local szModule = tostring(tbParam.module)
  local szTab = tostring(tbParam.tab)
  if szModule == "NewInformationPanel" then
    szTab = "Local_" .. szTab
  end
  Ui:OpenWindow(szModule, szTab)
end
function Pandora.ShowPL(tbParam)
  if not Pandora:IsEnable() then
    return
  end
  local szMapClass = Map:GetClassDesc(me.nMapTemplateId)
  if szMapClass == "city" or szMapClass == "fight" and me.nFightMode == 0 then
    Pandora.bWillShowPL = false
    Pandora.bWelfareActivity = Ui:WindowVisible("WelfareActivity") or Ui.tbWaitingForOpen.WelfareActivity ~= nil
    Ui:CloseWindow("WelfareActivity")
    Pandora:OpenPL()
  else
    Pandora.bWillShowPL = true
  end
end
function Pandora.ShowCommonTips(tbParam)
  local szMsg = tostring(tbParam.content)
  me.CenterMsg(szMsg)
end
function Pandora:OnEnterMap(nTemplateID, nMapID, nIsLocal)
  if self.bWillShowPL then
    Pandora.ShowPL({})
  end
end
function Pandora:OnChangeFightState(nFightState)
  if nFightState == 0 and self.bWillShowPL then
    Pandora.ShowPL({})
  end
end
function Pandora:OnEventWithReturn(tbParam)
  Lib:LogTB(tbParam)
  local szType = tbParam.type
  local szContent = tbParam.content
  if szType == "getItemPath" then
    local nItemId = tonumber(szContent)
    local nFaction = tonumber(tbParam.guildName or "") or me.nFaction
    local szName, nIcon, nView, nQuality = KItem.GetItemShowInfo(nItemId, nFaction)
    local szIconAtlas = ""
    local szIconSprite = ""
    if nIcon then
      local _szIconAtlas, _szIconSprite, _, _ = Item:GetIcon(nIcon)
      szIconAtlas = _szIconAtlas
      szIconSprite = _szIconSprite
    end
    return {
      type = "refreshItemPath",
      content = string.format("%s#%s", szIconAtlas, szIconSprite)
    }
  elseif szType == "getItemFramePath" then
    local nItemId = tonumber(szContent)
    local szName, nIcon, nView, nQuality = KItem.GetItemShowInfo(nItemId, me.nFaction)
    local szFrameColor = ""
    if nQuality then
      local _, _szFrameColor, _, _ = Item:GetQualityColor(nQuality)
      szFrameColor = _szFrameColor
    end
    return {
      type = "refreshItemFramePath",
      content = string.format("UI/Atlas/NewAtlas/Panel/NewPanel.prefab#%s", szFrameColor)
    }
  elseif szType == "getUserLevel" then
    return {
      type = "refreshUserLevel",
      content = tostring(me.nLevel)
    }
  end
  return {}
end
