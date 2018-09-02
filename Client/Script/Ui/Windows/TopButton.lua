local TopButton = Ui:CreateClass("TopButton")
Sdk._BRIEFING_TIME = 20170604
TopButton.tBtn2Ui = {
  ItemBox = "BtnBag",
  KinDetailPanel = "BtnFamily",
  KinJoinPanel = "BtnFamily",
  SkillPanel = "BtnSkill",
  SocialPanel = "BtnSocial",
  CommonShop = "BtnShop",
  RankBoardPanel = "BtnRanking",
  HonorLevelPanel = "BtnHonorLevel",
  Partner = "BtnCompanion",
  CalendarPanel = "BtnCalendar",
  WelfareActivity = "BtnActivity",
  StrongerPanel = "BtnStronger",
  ExpUpPanel = "BtnExpUp",
  AuctionPanel = "BtnAuction",
  MarketStallPanel = "BtnMarketStall",
  LoginAwardsPanel = "BtnLoginAward",
  SurveyPanel = "BtnSurvey",
  HomeScreenCommunity = "BtnGameCommunity",
  NewInformationPanel = "BtnNewMessage",
  RegressionPrivilegePanel = "BtnReturnPrivilege",
  FriendRecallPanel = "BtnReunionArena",
  AthleticsHonor = "BtnHonor",
  WLDHJoinPanel = "BtnWLDH"
}
TopButton.tBtnLevelShow = {
  {
    nLevel = 1,
    "BtnBag",
    "BtnFold",
    "BtnCalendar",
    "BtnNewMessage",
    "BtnGameCommunity",
    "BtnInvitationFriend",
    "BtnReturnPrivilege"
  },
  {nLevel = 4, "BtnSkill"},
  {
    nLevel = 5,
    "BtnLoginAward"
  },
  {
    nLevel = 8,
    "BtnActivity",
    "BtnQQMember"
  },
  {
    nLevel = 9,
    "BtnCompanion"
  },
  {
    nLevel = Shop.SHOW_LEVEL,
    "BtnShop"
  },
  {nLevel = 11, "BtnFamily"},
  {
    nLevel = FriendShip.SHOW_LEVEL,
    "BtnSocial"
  },
  {
    nLevel = Kin.AuctionDef.nAuctionLevelLimit,
    "BtnAuction"
  },
  {
    nLevel = 15,
    "BtnStronger"
  },
  {
    nLevel = 18,
    "BtnHonorLevel"
  },
  {nLevel = 19, "BtnRanking"},
  {
    nLevel = 20,
    "BtnMarketStall"
  },
  {nLevel = 999, "BtnTP"}
}
local tbTopWnds = {
  "BtnLeave",
  "BtnTopFold",
  "Weather",
  "House",
  "House2",
  "Top",
  "Anchor",
  "LevelGuide",
  "BtnRank",
  "WeddingDress"
}
function TopButton:OnOpen()
  for szUi, szWnd in pairs(self.tBtn2Ui) do
    self.pPanel:Button_SetCheck(szWnd, Ui:WindowVisible(szUi) == 1 and true or false)
    self.pPanel:SetActive(szWnd, false)
  end
  for _, tbInfo in pairs(self.tBtnLevelShow) do
    for _, szWnd in ipairs(tbInfo) do
      self.pPanel:SetActive(szWnd, false)
    end
  end
  self:TopButtonLevelShow()
  self:UpdateFriendRedInfo()
  self:CheckHasCanEquipItem()
  self:CheckHasCanUpgradeSkill()
  self:CheckFirstRechargeShow()
  local tbSkillBook = Item:GetClass("SkillBook")
  tbSkillBook:UpdateRedPoint(me)
  Timer:Register(3, function()
    self:UpdateShowLoginAwardBtn()
    self:UpdateHomeScreenBattleShowInfo()
    self:UpdateShowFriendRecallBtn()
    self:UpdateBeautyPageantBtn()
    self:UpdateWLDHBtn()
  end)
  self.pPanel:SetActive("HideGroup", false)
  self.nNextBtnFoldTime = 0
  local tbHonorLevel = Player.tbHonorLevel
  tbHonorLevel:UpdateRedPoint()
  local nCurTime = GetTime()
  if Sdk:IsLoginByQQ() and tonumber(os.date("%Y%m%d", nCurTime)) == Sdk._BRIEFING_TIME then
    self.pPanel:SetActive("BtnQiesport", true)
    self.pPanel:SetActive("QiesportTimesBg", true)
    if Lib:GetLocalDayTime(nCurTime) < 72000 then
      self.pPanel:Label_SetText("QiesportTimes", "20:00")
    elseif Lib:GetLocalDayTime(nCurTime) < 79200 then
      self.pPanel:Label_SetText("QiesportTimes", "直播中")
    else
      self.pPanel:SetActive("QiesportTimesBg", false)
    end
  else
    self.pPanel:SetActive("BtnQiesport", false)
  end
end
function TopButton:OnOpenEnd()
  Sdk:CheckRedPoint()
  Shop:CheckRedPoint()
  Ui:CheckRedPoint("Activity")
  Ui:CheckRedPoint("Fuben")
  Ui:CheckRedPoint("Partner")
  Ui:CheckRedPoint("EverydayTarget")
  House:CheckMuseRedPoint()
  self:CheckShowSurvey()
  self:UpdatePartnerTime()
  self:UpdateActivityGuide()
  self.pPanel:SetActive("BtnNewMessage", not Client:IsCloseIOSEntry())
  self:UpdateTXLiveInfo()
  self.pPanel:SetActive("House", false)
  self.pPanel:SetActive("House2", false)
  local bIsInHouse = Map:IsHouseMap(me.nMapTemplateId)
  if bIsInHouse and not self.BtnTopFoldState then
    self.tbOnClick.BtnTopFold(self)
  end
  self:RestoreSavedState()
  self:UpdateWeatherShowState()
  self:RefreshSpecialButton()
  self:RefreshSpecialButton(50)
  self.pPanel:SetActive("BtnLeave", bIsInHouse)
end
function TopButton:UpdateTXLiveInfo()
  self:CloseTXLiveTimer()
  local szTXLiveMsg, bCountDown, nLeftTime = Sdk:GetTXLiveInfo()
  if szTXLiveMsg and not Activity.BeautyPageant:IsShowMainButton() then
    self.pPanel:SetActive("BtnBriefing", true)
    if bCountDown then
      local function fnSetTxt()
        if nLeftTime <= 0 then
          self:UpdateTXLiveInfo()
          return false
        else
          self.pPanel:Label_SetText("BriefingTimes", szTXLiveMsg .. Lib:TimeDesc3(nLeftTime))
        end
        nLeftTime = nLeftTime - 1
        return true
      end
      self.nTXLiveCountDownTimer = Timer:Register(Env.GAME_FPS, fnSetTxt)
    else
      self.pPanel:Label_SetText("BriefingTimes", szTXLiveMsg)
    end
  else
    self.pPanel:SetActive("BtnBriefing", false)
  end
end
function TopButton:CloseTXLiveTimer()
  if self.nTXLiveCountDownTimer then
    Timer:Close(self.nTXLiveCountDownTimer)
    self.nTXLiveCountDownTimer = nil
  end
end
function TopButton:UpdateMarketStallOpenTime()
  self.dwRoleCreateTime = me.dwCreateTime
  self.dwRoleId = me.dwID
  self.nUpdateMarketStallOpenTime = Timer:Register(Env.GAME_FPS, function()
    local nLastTime = MarketStall.nCreateRoleTimeLimit - (GetTime() - self.dwRoleCreateTime)
    if not PlayerEvent.bLogin or self.dwRoleId ~= me.dwID or nLastTime <= 0 then
      self.nUpdateMarketStallOpenTime = nil
      self.pPanel:SetActive("MarketStallTimesBg", false)
      return false
    end
    self.pPanel:Label_SetText("MarketStallTimes", Lib:TimeDesc3(nLastTime))
    return true
  end)
end
function TopButton:CloseMarketStallTime()
  if self.nUpdateMarketStallOpenTime then
    Timer:Close(self.nUpdateMarketStallOpenTime)
    self.nUpdateMarketStallOpenTime = nil
  end
end
function TopButton:UpdateSideBar(szUiName)
  if self.tBtn2Ui[szUiName] then
    self.pPanel:Button_SetCheck(self.tBtn2Ui[szUiName], Ui:WindowVisible(szUiName) == 1 and true or false)
  end
end
function TopButton:UpdateFriendRedInfo(dwID)
  if me.nLevel < FriendShip.SHOW_LEVEL then
    return
  end
  local tbAllRequet = FriendShip:GetAllFriendRequestData()
  if #tbAllRequet > 0 then
    Ui:SetRedPointNotify("Friend_Request")
  else
    Ui:ClearRedPointNotify("Friend_Request")
  end
end
function TopButton:UpdateCalendarFlag(bVisible)
  self.pPanel:SetActive("CalendarRedPoint", bVisible)
end
function TopButton:OnButtonClick(szWnd)
  if szWnd == "BtnFamily" then
    if Kin:HasKin() then
      self.tBtn2Ui.KinJoinPanel = nil
      self.tBtn2Ui.KinDetailPanel = "BtnFamily"
    else
      self.tBtn2Ui.KinJoinPanel = "BtnFamily"
      self.tBtn2Ui.KinDetailPanel = nil
    end
  end
  for szUi, szUiWnd in pairs(self.tBtn2Ui) do
    if szWnd == szUiWnd then
      if self.pPanel:Button_GetCheck(szUiWnd) then
        Ui:OpenWindow(szUi)
        break
      end
      Ui:CloseWindow(szUi)
      break
    end
  end
end
function TopButton:CheckHasCanEquipItem(nItemId, bNew)
  local tbAllEquips = me.FindItemInBag("Unidentify")
  for i, pItem in ipairs(tbAllEquips) do
    if Item:CheckUsable(pItem, pItem.szClass) == 1 then
      Ui:SetRedPointNotify("ItemBox")
      Ui:SetRedPointNotify("ItemBox_Battle")
      Ui:SetRedPointNotify("ItemBox_HomeScreeFuben")
      return
    end
  end
  local tbEquip = me.GetEquips()
  local tbAllEquips = me.FindItemInPlayer("equip")
  for i, pItem in ipairs(tbAllEquips) do
    local nEquipingId = tbEquip[pItem.nEquipPos]
    if not nEquipingId then
      if pItem.nUseLevel <= me.nLevel then
        Ui:SetRedPointNotify("ItemBox")
        Ui:SetRedPointNotify("ItemBox_Battle")
        Ui:SetRedPointNotify("ItemBox_HomeScreeFuben")
        return
      end
    elseif nEquipingId ~= pItem.dwId then
      local pCurEquip = KItem.GetItemObj(nEquipingId)
      if pItem.nRealLevel > pCurEquip.nRealLevel and pItem.nUseLevel <= me.nLevel then
        Ui:SetRedPointNotify("ItemBox")
        Ui:SetRedPointNotify("ItemBox_Battle")
        Ui:SetRedPointNotify("ItemBox_HomeScreeFuben")
        return
      end
    end
  end
  Ui:ClearRedPointNotify("ItemBox")
  Ui:ClearRedPointNotify("ItemBox_Battle")
  Ui:ClearRedPointNotify("ItemBox_HomeScreeFuben")
  return
end
TopButton.tbOnClick = TopButton.tbOnClick or {}
for _, szWndName in pairs(TopButton.tBtn2Ui) do
  TopButton.tbOnClick[szWndName] = TopButton.OnButtonClick
end
function TopButton.tbOnClick:BtnFold()
  local nBtnTime = 5
  local nCurTime = GetFrame()
  if self.nNextBtnFoldTime and nCurTime < self.nNextBtnFoldTime then
    return
  end
  self.nNextBtnFoldTime = GetFrame() + nBtnTime
  self:UpdateHomeScreenBattleShowInfo(true)
end
function TopButton.tbOnClick:BtnTP()
  Map:SwitchMap(10)
end
function TopButton.tbOnClick:BtnRecharge()
  Ui:OpenWindow("WelfareActivity", "FirstRecharge")
  WelfareActivity:ClearFirstLogin()
  self.pPanel:SetActive("texiao1", false)
end
function TopButton.tbOnClick:BtnTopFold()
  self.BtnTopFoldState = not self.BtnTopFoldState
  if self.BtnTopFoldState then
    self.pPanel:PlayUiAnimation("HomeScreenButtonRetract", false, false, {})
  else
    self.pPanel:PlayUiAnimation("HomeScreenButtonStretch", false, false, {})
  end
  self.pPanel:SetActive("House", false)
  self.pPanel:SetActive("House2", false)
  self:UpdateWeatherShowState()
  self:RefreshSpecialButton()
  self:RefreshSpecialButton(50)
end
function TopButton.tbOnClick:BtnZeroIncome()
  Ui:OpenWindow("MessageBoxBig", Forbid:GetDesc(Forbid:IsForbidAward()), {
    {}
  }, {"确定"}, 3)
end
function TopButton.tbOnClick:BtnQQMember()
  Ui:OpenWindow("WelfareActivity", "QQVipPrivilege")
end
function TopButton.tbOnClick:BtnInvitationFriend()
  if Sdk:IsLoginByQQ() then
    Sdk:OpenUrl(Sdk.szQQInvitationUrl)
  elseif Sdk:IsLoginByWeixin() then
    Sdk:OpenUrl(Sdk.szWXInvitationUrl)
  else
    me.CenterMsg("请使用手Q或微信登入")
  end
end
function TopButton.tbOnClick:BtnRealName()
  local szUrlFormat = "http://jxqy.qq.com/ingame/all/act/a20160918name/index.shtml?roleid=%d&serverid=%d&platid=%d&area=%d"
  local nArea = Sdk:GetAreaId()
  local nPlatId = Sdk:GetPlatId()
  local nServerId = Sdk:GetServerId()
  local szUrl = string.format(szUrlFormat, me.dwID, nServerId, nPlatId, nArea)
  Sdk:OpenUrl(szUrl)
  Client:SetFlag("SeenRealNameAuth", true)
  Ui:ClearRedPointNotify("RealNameAuth")
end
function TopButton.tbOnClick:BtnZhuangxiuL()
  TopButton.tbOnClick.BtnZhuangxiu(self)
end
function TopButton.tbOnClick:BtnZhuangxiu()
  House:EnterDecorationMode()
  Guide.tbNotifyGuide:ClearNotifyGuide("ZhuangXiu")
end
function TopButton.tbOnClick:BtnZhizuo()
  Ui:OpenWindow("FurnitureMake")
end
function TopButton.tbOnClick:BtnJiayuan()
  Ui:OpenWindow("HouseManagerPanel")
end
function TopButton.tbOnClick:BtnCamera()
  Ui:OpenWindowAtPos("HouseCameraPanel", 317, 139, true)
end
function TopButton.tbOnClick:BtnBriefing()
  Sdk:OpenTXLiveUrl()
end
function TopButton.tbOnClick:BtnJiayuan2()
  self.tbOnClick.BtnJiayuan(self)
end
function TopButton.tbOnClick:BtnCamera2()
  self.tbOnClick.BtnCamera(self)
end
function TopButton.tbOnClick:BtnLeave()
  RemoteServer.GoBackFromHome()
end
function TopButton.tbOnClick:BtnQiesport()
  local szUrl = "https://youxi.vip.qq.com/m/act/83001a7c86_jxqy_197680.html?_wv=1&_wwv=4"
  Sdk:OpenUrl(szUrl)
end
function TopButton.tbOnClick:BtnBeauty()
  Activity.BeautyPageant:OpenMainPage()
end
function TopButton.tbOnClick:BtnCamera3()
  if Map:IsHouseMap(me.nMapTemplateId) then
    self.tbOnClick.BtnCamera(self)
  else
    local szUiScreeShot = "HouseSharePanel"
    if Ui:WindowVisible(szUiScreeShot) ~= 1 then
      Ui:OpenWindow(szUiScreeShot, true)
    end
  end
end
function TopButton.tbOnClick:TakeOff()
  RemoteServer.OnWeddingRequest("ChangeDressState", false)
end
if Sdk:IsEfunHKTW() then
  function TopButton.tbOnClick:BtnFB()
    Ui:OpenWindow("SocialPanel", "FriendsRankPanel")
  end
  function TopButton.tbOnClick:BtnDirectSeeding()
    Sdk:XGStartBroadcast()
  end
end
if version_xm then
  function TopButton.tbOnClick:BtnInvitationFriend_xm()
    Sdk:XGXMInvitation()
  end
end
function TopButton:OnSyncItem(nItemId, bNew)
  self.CheckHasCanEquipItem(nItemId, bNew)
  local tbHonorLevel = Player.tbHonorLevel
  tbHonorLevel:UpdateRedPoint()
  local tbSkillBook = Item:GetClass("SkillBook")
  tbSkillBook:UpdateRedPoint(me)
end
function TopButton:FinishPersonalFuben()
  local tbHonorLevel = Player.tbHonorLevel
  tbHonorLevel:UpdateRedPoint()
end
function TopButton:UpdateHomeScreenBattleShowInfo(bExchange)
  self.pPanel:SetActive("BattleHide", me.nFightMode ~= 1)
  if not Ui:WindowVisible(self.UI_NAME) then
    return
  end
  local bFight = me.nFightMode == 1
  if bExchange then
    bFight = self.bHideState
  end
  self.bHideState = not bFight
  local bShow = self.pPanel:IsActive("HideGroup")
  if bFight and bShow or not bFight and not bShow then
    if not bFight then
      self.pPanel:SetActive("HideGroup", true)
    end
    self.pPanel:PlayUiAnimation(bFight and "HomeScreenTopButtonDelete" or "HomeScreenTopButtonOpen", false, false, {})
  end
  if bFight and not Ui:WindowVisible("HomeScreenBattle") then
    Ui:OpenWindow("HomeScreenBattle")
  end
  if not bFight and Ui:WindowVisible("HomeScreenBattle") then
    Ui:CloseWindow("HomeScreenBattle")
  end
  local nScale = Ui:WindowVisible("HomeScreenBattle") and 0.8 or 0.01
  self.pPanel:ChangeScale("BtnFoldRedmark", nScale, nScale, nScale)
end
function TopButton:OnCheckOut(dwOwnerId)
  local nHouseMapId = House:GetHouseMap(dwOwnerId)
  if not nHouseMapId or nHouseMapId ~= me.nMapId then
    return
  end
  self.pPanel:SetActive("House2", false)
  self:UpdateWeatherShowState()
end
function TopButton:UpdateWeatherShowState()
  local bIsInHouse = Map:IsHouseMap(me.nMapTemplateId)
  self.pPanel:SetActive("Weather", self.BtnTopFoldState and bIsInHouse)
  self:UpdateWeatherInfo()
end
function TopButton:OnCheckIn(dwOwnerId)
  local nHouseMapId = House:GetHouseMap(dwOwnerId)
  if not nHouseMapId or nHouseMapId ~= me.nMapId then
    return
  end
  self.pPanel:SetActive("House2", true)
  self:UpdateWeatherShowState()
end
function TopButton:RefreshSpecialButton(nWaiteTime)
  Timer:Register(math.max(10, nWaiteTime or 0), function()
    self:RefreshHouseButton()
  end)
end
function TopButton:RefreshHouseButton()
  local pos = self.pPanel:GetPosition("Top")
  if pos.y < 179 then
    self.pPanel:SetActive("House", false)
    self.pPanel:SetActive("House2", false)
    self.BtnTopFoldState = false
    self:UpdateWeatherShowState()
    return
  end
  self.BtnTopFoldState = true
  local bIsInOwnHouse = House:IsInOwnHouse(me)
  local bIsInLivingRoom = House:IsInLivingRoom(me)
  self.pPanel:SetActive("House", bIsInOwnHouse)
  self.pPanel:SetActive("House2", bIsInLivingRoom)
  self:UpdateWeatherShowState()
  local bHasDecorationAccess = false
  if bIsInLivingRoom then
    bHasDecorationAccess = House:HasDecorationAccess(me)
  end
  self.pPanel:SetActive("BtnZhuangxiuL", bHasDecorationAccess)
  self.pPanel:ChangePosition("BtnJiayuan2", bHasDecorationAccess and -350 or -265, -47, 0)
  self:CheckHouseUpradeTimer()
end
function TopButton:HideTopWnds()
  for _, szWnd in ipairs(tbTopWnds) do
    self.pPanel:SetActive(szWnd, false)
  end
end
function TopButton:SaveCurState()
  self.tbCurState = {}
  for _, szWnd in ipairs(tbTopWnds) do
    self.tbCurState[szWnd] = self.pPanel:IsActive(szWnd)
  end
end
function TopButton:RestoreSavedState()
  for szWnd, bActive in pairs(self.tbCurState or {}) do
    self.pPanel:SetActive(szWnd, bActive)
  end
end
function TopButton:EnableWeddingDressMode(bEnable)
  if bEnable then
    self:SaveCurState()
    self:HideTopWnds()
    self.pPanel:SetActive("WeddingDress", true)
  else
    self:RestoreSavedState()
  end
end
function TopButton:CheckHouseUpradeTimer()
  self:CloseHouseUpgradeTimer()
  local bIsUpgrating = false
  local bIsInOwnHouse = House:IsInOwnHouse(me)
  if bIsInOwnHouse and House.nStartLeveupTime then
    bIsUpgrating = true
  end
  self.pPanel:SetActive("LevelUp", bIsUpgrating)
  if not bIsUpgrating then
    return
  end
  local tbSetting = House.tbHouseSetting[House.nHouseLevel]
  local nLeftTime = House.nStartLeveupTime + tbSetting.nLevelupTime - GetTime()
  local function fnRefreshUi()
    if nLeftTime <= 0 then
      self.pPanel:Label_SetText("LevelUpTxt", "升级完成")
      return false
    end
    self.pPanel:Label_SetText("LevelUpTxt", Lib:TimeDesc3(nLeftTime))
    return true
  end
  local bRet = fnRefreshUi()
  if not bRet then
    return
  end
  self.nHouseUpgradeTimerId = Timer:Register(Env.GAME_FPS, function()
    nLeftTime = nLeftTime - 1
    local bRet = fnRefreshUi()
    if not bRet then
      self.nHouseUpgradeTimerId = nil
      return false
    end
    return true
  end)
end
function TopButton:CloseHouseUpgradeTimer()
  if self.nHouseUpgradeTimerId then
    Timer:Close(self.nHouseUpgradeTimerId)
    self.nHouseUpgradeTimerId = nil
  end
end
function TopButton:OnSyncHouseInfo()
  self:RefreshHouseButton()
end
function TopButton:OnSyncData(szType)
  if szType == "ChangeSkillPoint" or szType == "SkillPanelUpdate" then
    self:CheckHasCanUpgradeSkill()
  elseif szType == "UpdateTopButton" then
    self:TopButtonLevelShow()
  end
end
function TopButton:OnWeddingDressChange(bOn)
  self:EnableWeddingDressMode(bOn)
end
function TopButton:UpdateWeatherInfo()
  local nMapTemplateId = me.nMapTemplateId
  local bIsNight = WeatherMgr:CheckIsNight(nMapTemplateId)
  local _, szTimeInfo = WeatherMgr:GetTimeNow(nMapTemplateId)
  local szExtInfo = "晴"
  local szShowSprite = bIsNight and "WeatherNight" or "WeatherDay"
  if WeatherMgr.szWeatherType then
    if WeatherMgr.szWeatherType == "Rain" then
      szShowSprite = "WeatherRain"
    end
    szExtInfo = WeatherMgr.tbAllWeatherType[WeatherMgr.szWeatherType] or szExtInfo
  end
  self.pPanel:Button_SetSprite("Weather", szShowSprite)
  self.pPanel:Label_SetText("WeatherTime", string.format("%s时（%s）", szTimeInfo, szExtInfo))
end
function TopButton:RegisterEvent()
  local tbRegEvent = {
    {
      UiNotify.emNOTIFY_WND_OPENED,
      self.UpdateSideBar
    },
    {
      UiNotify.emNOTIFY_WND_CLOSED,
      self.UpdateSideBar
    },
    {
      UiNotify.emNoTIFY_SYNC_FRIEND_DATA,
      self.UpdateFriendRedInfo
    },
    {
      UiNotify.emNOTIFY_CHANGE_PLAYER_LEVEL,
      self.TopButtonLevelShow
    },
    {
      UiNotify.emNOTIFY_SYNC_ITEM,
      self.OnSyncItem
    },
    {
      UiNotify.emNOTIFY_DEL_ITEM,
      self.CheckHasCanEquipItem
    },
    {
      UiNotify.emNOTIFY_CHANGE_MONEY,
      self.CheckHasCanUpgradeSkill
    },
    {
      UiNotify.emNOTIFY_SKILL_LEVELUP,
      self.CheckHasCanUpgradeSkill
    },
    {
      UiNotify.emNOTIFY_FINISH_PERSONALFUBEN,
      self.FinishPersonalFuben
    },
    {
      UiNotify.emNOTIFY_RECHARGE_PANEL,
      self.CheckFirstRechargeShow
    },
    {
      UiNotify.emNOTIFY_UPDATE_SURVEY_STATE,
      self.CheckShowSurvey
    },
    {
      UiNotify.emNOTIFY_FORBID_STATE_CHANGE,
      self.OnForbidStateChange
    },
    {
      UiNotify.emNOTIFY_PANDORA_REFRESH_ICON,
      self.OnRefreshPandoraIcon
    },
    {
      UiNotify.emNOTIFY_PRECISE_CAST,
      self.OnPreciseCastSkill
    },
    {
      UiNotify.emNOTIFY_XGSDK_CALLBACK,
      self.TopButtonLevelShow
    },
    {
      UiNotify.emNOTIFY_UPDATE_RECALL_BUTTON,
      self.UpdateShowFriendRecallBtn
    },
    {
      UiNotify.emNOTIFY_ROOMER_CHECKOUT,
      self.OnCheckOut
    },
    {
      UiNotify.emNOTIFY_SYNC_DATA,
      self.OnSyncData
    },
    {
      UiNotify.emNOTIFY_ROOMER_CHECKIN,
      self.OnCheckIn
    },
    {
      UiNotify.emNOTIFY_HOUSE_LEVELUP,
      self.CheckHouseUpradeTimer
    },
    {
      UiNotify.emNOTIFY_SYNC_HOUSE_INFO,
      self.OnSyncHouseInfo
    },
    {
      UiNotify.emNOTIFY_SYNC_WEATHER_CHANGE,
      self.UpdateWeatherInfo
    },
    {
      UiNotify.emNOTIFY_WEDDING_DRESS_CHANGE,
      self.OnWeddingDressChange
    }
  }
  return tbRegEvent
end
function TopButton:TopButtonLevelShow()
  self:CheckHasCanUpgradeSkill()
  for _, LevelUi in pairs(self.tBtnLevelShow) do
    if me.nLevel >= LevelUi.nLevel then
      for nId = 1, #LevelUi do
        if LevelUi[nId] ~= "BtnStronger" or not Forbid:IsForbidAward() then
          self.pPanel:SetActive(LevelUi[nId], true)
        end
      end
    end
  end
  self:CheckFirstRechargeShow()
  self:UpdateShowLoginAwardBtn()
  self:UpdateHomeScreenBattleShowInfo()
  self:CheckLevelUpGuide()
  Recharge:CheckCanBuyVipAward()
  if not (not Sdk:IsMsdk() or Sdk:IsLoginByGuest()) or version_xm then
    self.pPanel:SetActive("BtnGameCommunity", true)
  else
    self.pPanel:SetActive("BtnGameCommunity", false)
  end
  self.pPanel:SetActive("BtnFB", Sdk:IsEfunHKTW() and me.nLevel >= FriendShip.SHOW_LEVEL)
  self.pPanel:SetActive("BtnQQMember", Sdk:ShowQQVipPrivilege())
  if Client:IsCloseIOSEntry() then
    self.pPanel:SetActive("BtnSurvey", false)
    self.pPanel:SetActive("BtnGameCommunity", false)
    self.pPanel:SetActive("BtnQQMember", false)
    self.pPanel:SetActive("BtnInvitationFriend", false)
    self.pPanel:SetActive("BtnNewMessage", false)
    self.pPanel:SetActive("BtnFB", false)
    self.pPanel:SetActive("BtnInvitationFriend_xm", false)
  end
  if Sdk:IsLoginByGuest() or Sdk:IsHideTXInvitation() then
    self.pPanel:SetActive("BtnInvitationFriend", false)
  end
  self.pPanel:SetActive("BtnReturnPrivilege", RegressionPrivilege:IsShowButton() and not Sdk:ShowHomeScreenRealAuth())
  self:RefreshFobidState(Forbid:IsForbidAward())
  if Sdk:IsEfunHKTW() then
    self.pPanel:SetActive("BtnDirectSeeding", Sdk:XGIsBroadcastShow())
  end
  self.pPanel:SetActive("BtnRealName", Sdk:ShowHomeScreenRealAuth())
  if not self.nUpdateMarketStallOpenTime and self.pPanel:IsActive("BtnMarketStall") then
    if GetTimeFrameState(MarketStall.szCreateRoleTimeLimitTimeFrame) == 1 and GetTime() - me.dwCreateTime < MarketStall.nCreateRoleTimeLimit then
      self.pPanel:SetActive("MarketStallTimesBg", true)
      self:UpdateMarketStallOpenTime()
    else
      self.pPanel:SetActive("MarketStallTimesBg", false)
    end
  end
  self:UpdateBeautyPageantBtn()
  self:UpdateWLDHBtn()
end
function TopButton:CheckShowSurvey()
  local bSurveyAvailable = Survey:Available()
  if Client:IsCloseIOSEntry() then
    bSurveyAvailable = false
  end
  self.pPanel:SetActive(self.tBtn2Ui.SurveyPanel, bSurveyAvailable)
end
function TopButton:CheckHasCanUpgradeSkill()
  local tbSkillBook = Item:GetClass("SkillBook")
  tbSkillBook:UpdateRedPoint(me)
  local bShowRedPoint = false
  local tbFactionSkill = FightSkill:GetFactionSkill(me.nFaction)
  for _, tbInfo in pairs(tbFactionSkill) do
    local bRet = FightSkill:CheckSkillLeveUp(me, tbInfo.SkillId)
    if bRet then
      bShowRedPoint = true
      break
    end
  end
  if bShowRedPoint == true and me.nLevel >= 4 then
    if not Ui:GetRedPointState("Skill") then
      self.bSkillPointNotify = true
      Ui:SetRedPointNotify("Skill")
    end
  elseif self.bSkillPointNotify then
    self.bSkillPointNotify = false
    Ui:ClearRedPointNotify("Skill")
  end
end
function TopButton:CheckFirstRechargeShow()
  local nHonorLevel = Calendar.JOIN_LV
  self.pPanel:SetActive("BtnHonor", nHonorLevel <= me.nLevel)
  local bGetFirstRecharge = me.GetUserValue(Recharge.SAVE_GROUP, Recharge.KEY_GET_FIRST_RECHARGE) == 1
  local bShow = me.nLevel >= 10 and me.nLevel <= math.min(nHonorLevel - 1, 40) and not bGetFirstRecharge
  local bEffects = WelfareActivity:IsDayFirstLogin()
  self.pPanel:SetActive("BtnRecharge", bShow)
  self.pPanel:SetActive("texiao1", bShow and bEffects)
end
function TopButton:UpdateShowLoginAwardBtn()
  local bEnable = LoginAwards:IsActivityActive()
  if FriendRecall:IsShowMainButton() then
    bEnable = false
  end
  self.pPanel:SetActive("BtnLoginAward", bEnable)
end
function TopButton:CheckLevelUpGuide()
  self.LevelGuide:Update()
end
function TopButton:UpdatePartnerTime()
  self.nLoginAwardsTimer = Timer:Register(Env.GAME_FPS, function()
    local szTime = LoginAwards:GetPartnerTime(true)
    self.pPanel:SetActive("LoginAwardTimesBg", szTime and true or false)
    if not szTime then
      self.nLoginAwardsTimer = nil
      return
    end
    self.pPanel:Label_SetText("LoginAwardTimes", szTime)
    return true
  end)
end
function TopButton:CloseLoginAwardsTimer()
  if self.nLoginAwardsTimer then
    Timer:Close(self.nLoginAwardsTimer)
    self.nLoginAwardsTimer = nil
  end
end
function TopButton:UpdateActivityGuide()
  self:CloseActivityGuideTimer()
  self.LevelGuide:OnOpen()
  local tbSkillBook = Item:GetClass("SkillBook")
  self.nActivityGuideTimer = Timer:Register(Env.GAME_FPS * 5, function()
    if GetTime() % 60 < 5 then
      self.LevelGuide:Update()
      tbSkillBook:UpdateRedPoint(me)
    end
    return true
  end)
end
function TopButton:CloseActivityGuideTimer()
  if self.nActivityGuideTimer then
    Timer:Close(self.nActivityGuideTimer)
    self.nActivityGuideTimer = nil
  end
end
function TopButton:OnClose()
  self:CloseMarketStallTime()
  self:CloseLoginAwardsTimer()
  self:CloseActivityGuideTimer()
  self:CloseHouseUpgradeTimer()
  self.pPanel:SetActive("HideGroup", false)
  self:CloseTXLiveTimer()
  self.pPanel:SetActive("House", false)
  self:UpdateWeatherShowState()
end
function TopButton:CheckButtonLevelVisible(szBtnName)
  for _, LevelUi in pairs(self.tBtnLevelShow) do
    for nId = 1, #LevelUi do
      if LevelUi[nId] == szBtnName then
        return me.nLevel >= LevelUi.nLevel
      end
    end
  end
  return false
end
function TopButton:OnForbidStateChange(bIsForbid)
  self:RefreshFobidState(bIsForbid)
end
function TopButton:RefreshFobidState(bIsForbid)
  self.pPanel:SetActive("BtnZeroIncome", bIsForbid)
  if not bIsForbid and self:CheckButtonLevelVisible("BtnStronger") then
    local bRet = self:CheckOpenExpUp()
    if bRet then
      self.pPanel:SetActive("BtnExpUp", true)
      self.pPanel:SetActive("BtnStronger", false)
      local tbInfo = Client:GetUserInfo("BtnExpUpRed")
      if not tbInfo or not tbInfo.nRedPoint then
        Ui:SetRedPointNotify("ExpUpRedPoint")
      else
        Ui:ClearRedPointNotify("ExpUpRedPoint")
      end
    else
      self.pPanel:SetActive("BtnExpUp", false)
      self.pPanel:SetActive("BtnStronger", not RegressionPrivilege:IsShowButton() and not Sdk:ShowHomeScreenRealAuth())
    end
  else
    self.pPanel:SetActive("BtnStronger", false)
    self.pPanel:SetActive("BtnExpUp", false)
  end
end
function TopButton:CheckOpenExpUp()
  if RegressionPrivilege:IsShowButton() then
    return false
  end
  local tbLevelInfo = Npc:GetPlayerLevelAddExpP() or {}
  local nExpP = tbLevelInfo[me.nLevel]
  if not nExpP or nExpP <= 100 then
    return false
  end
  return true
end
function TopButton:OnRefreshPandoraIcon(szModule, szTab, bIsShowIcon, bIsShowRedPoint)
end
function TopButton:OnPreciseCastSkill(bStart)
  if bStart then
    self.LevelGuide.pPanel:SetActive("Main", false)
  else
    self:CheckLevelUpGuide()
  end
end
function TopButton:UpdateShowFriendRecallBtn()
  self.pPanel:SetActive("BtnReunionArena", FriendRecall:IsShowMainButton())
  self:UpdateShowLoginAwardBtn()
end
function TopButton:UpdateBeautyPageantBtn()
  local bEnable = Activity.BeautyPageant:IsShowMainButton()
  self.pPanel:SetActive("BtnBeauty", bEnable)
  if bEnable then
    local nState = Activity.BeautyPageant:GetCurState()
    self.pPanel:Label_SetText("BeautyTimes", Activity.BeautyPageant.STATE_DESC[nState] or "")
  end
  self:UpdateTXLiveInfo()
end
function TopButton:UpdateWLDHBtn()
  local bShow, szActTime = WuLinDaHui:IsShowTopButton()
  self.pPanel:SetActive("BtnWLDH", bShow)
  WuLinDaHui:CheckRedPoint()
end
