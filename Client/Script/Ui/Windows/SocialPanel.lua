Require("Script/Ui/Windows/FriendGrid.lua")
local tbUi = Ui:CreateClass("SocialPanel")
local emPLAYER_STATE_NORMAL = 2
local tbPanels = {
  "FriendPanel",
  "WantedPanel",
  "MasterPanel",
  "FriendsRankPanel"
}
function tbUi:OnOpen()
end
function tbUi:OnOpenEnd(szPanel, ...)
  if szPanel == "FriendPanel" then
    self:UpdateSideBtn("BtnFriends")
    self.tbOnClick.BtnFriends(self)
  elseif szPanel == "EnemyPanel" then
    self:UpdateSideBtn("BtnEnemys")
    self.pPanel:Toggle_SetChecked("BtnEnemys2", true)
    self.tbOnClick.BtnEnemys(self)
    self.tbOnClick.BtnEnemys2(self)
  elseif szPanel == "WantedPanel" then
    self:UpdateSideBtn("BtnEnemys")
    self.pPanel:Toggle_SetChecked("BtnWanted", true)
    self.tbOnClick.BtnEnemys(self)
    self.tbOnClick.BtnWanted(self)
  elseif szPanel == "FriendsRankPanel" then
    self:UpdateSideBtn("BtnFriendsRank")
    self.tbOnClick.BtnFriendsRank(self)
  elseif szPanel == "MasterPanel" then
    self:UpdateSideBtn("BtnMaster")
    self.tbOnClick.BtnMaster(self, ...)
  elseif self.pPanel:Toggle_GetChecked("BtnFriends") then
    self.tbOnClick.BtnFriends(self)
  elseif self.pPanel:Toggle_GetChecked("BtnEnemys") then
    self.tbOnClick.BtnEnemys(self)
    self.tbOnClick.BtnEnemys2(self)
  elseif self.pPanel:Toggle_GetChecked("BtnMaster") then
    self.tbOnClick.BtnMaster(self)
  elseif self.pPanel:Toggle_GetChecked("BtnFriendsRank") then
    self.tbOnClick.BtnFriendsRank(self)
  else
    self.pPanel:Toggle_SetChecked("BtnFriends", true)
    self.tbOnClick.BtnFriends(self)
  end
  self.nTimerUpdateCd = Timer:Register(Env.GAME_FPS, self.UpdateCDTime, self)
  FriendShip:CheckWhenOpenUi()
  self.nSelFriendIndex = 0
  if Client:IsCloseIOSEntry() then
    self.pPanel:SetActive("BtnFriendsRank", false)
  elseif Sdk:IsMsdk() then
    self.pPanel:SetActive("BtnFriendsRank", not Sdk:IsLoginByGuest())
  else
    self.pPanel:SetActive("BtnFriendsRank", Sdk:HasEfunRank())
  end
  local szBtnName = Sdk:IsLoginByQQ() and "QQ好友" or "微信好友"
  szBtnName = Sdk:HasEfunRank() and "FB\n好\n友" or szBtnName
  self.pPanel:Label_SetText("TxtBtnFriend1", szBtnName)
  self.pPanel:Label_SetText("TxtBtnFriend2", szBtnName)
  local bShowMaster = TeacherStudent:CanShowEnterance()
  self.pPanel:SetActive("BtnMaster", bShowMaster)
  if not bShowMaster then
    self.pPanel:Toggle_SetChecked("BtnMaster", false)
  end
  local bIsHouseOpen = House:CheckOpen(me)
  self.pPanel:SetActive("BtnHelp", bIsHouseOpen)
  if bIsHouseOpen then
    self:CheckPlantCure()
  end
end
function tbUi:CheckPlantCure()
  RemoteServer.CheckPlayerCanCure()
  self.nCheckPlantCureTimerId = Timer:Register(Env.GAME_FPS * 5, function()
    if DegreeCtrl:GetDegree(me, "PlantHelpCure") > 0 then
      if Ui:WindowVisible("PlantHelpCurePanel") ~= 1 then
        RemoteServer.CheckPlayerCanCure()
      end
      return true
    end
    HousePlant:ClearHelpCureRedPoint()
    self.nCheckPlantCureTimerId = nil
  end)
end
local tbSideButtons = {
  "BtnFriends",
  "BtnEnemys",
  "BtnMaster",
  "BtnFriendsRank"
}
function tbUi:UpdateSideBtn(szBtnName)
  for _, szName in ipairs(tbSideButtons) do
    self.pPanel:Toggle_SetChecked(szName, szName == szBtnName)
  end
end
function tbUi:ShowPanel(szPanel)
  for i, v in ipairs(tbPanels) do
    self.pPanel:SetActive(v, v == szPanel)
  end
end
function tbUi:UpdateCDTime()
  if self.nCdTime and self.nCdTime > 0 then
    self.nCdTime = self.nCdTime - 1
    if self.nCdTime > 0 then
      self.pPanel:Label_SetText("CDtime", Lib:TimeDesc3(self.nCdTime))
    else
      self.pPanel:Label_SetText("CDtime", "0")
    end
    if self.nCdTime >= 3600 then
      self.pPanel:SetActive("btnEliminate", true)
      self.pPanel:Label_SetColor("CDtime", 255, 100, 100)
    else
      self.pPanel:SetActive("btnEliminate", false)
      self.pPanel:Label_SetColor("CDtime", 255, 255, 255)
    end
  end
  local bRemoved = false
  local tbWantedData = FriendShip.tbWantedData
  for i = #tbWantedData, 1, -1 do
    local tbWantedGrid = self.ScrollViewWanted.Grid["Item" .. i - 1]
    if tbWantedGrid then
      local bRet = tbWantedGrid:UpdateWantedTimer()
      if not bRet then
        table.remove(tbWantedData, i)
        bRemoved = true
      end
    end
  end
  if bRemoved then
    self:RefreshWanteds()
  end
  return true
end
function tbUi:OnClose()
  if self.nTimerUpdateCd then
    Timer:Close(self.nTimerUpdateCd)
    self.nTimerUpdateCd = nil
  end
  if self.nCheckPlantCureTimerId then
    Timer:Close(self.nCheckPlantCureTimerId)
    self.nCheckPlantCureTimerId = nil
  end
  Ui:CloseWindow("RightPopup")
end
function tbUi:RefreshAllFriend(bModify)
  if not self.pPanel:IsActive("FriendPanel") then
    return
  end
  if bModify then
    self.tbAllFriend = FriendShip:GetAllFriendData(true)
    self:UpdateFriendList()
    return
  end
  local tbAllFriend = FriendShip:GetAllFriendData()
  local function fnSort(a, b)
    if a.nState == emPLAYER_STATE_NORMAL and b.nState == emPLAYER_STATE_NORMAL then
      if a.nImity == b.nImity then
        return a.nLevel > b.nLevel
      else
        return a.nImity > b.nImity
      end
    elseif a.nState == emPLAYER_STATE_NORMAL then
      return true
    elseif b.nState == emPLAYER_STATE_NORMAL then
      return false
    elseif a.nImity == b.nImity then
      return a.nLevel > b.nLevel
    else
      return a.nImity > b.nImity
    end
  end
  table.sort(tbAllFriend, fnSort)
  self.tbAllFriend = tbAllFriend
  self:UpdateFriendList()
  self.pPanel:SetActive("BtnQQFriend", Sdk:IsLoginByQQ())
end
function tbUi:UpdateFriendList()
  local tbAllFriend = self.tbAllFriend
  if not tbAllFriend then
    return false
  end
  local function fnOnClick(itemClass)
    self.nSelFriendIndex = itemClass.index
  end
  local pScrollView = self.ScrollViewFriends
  local function fnSetFriend(itemClass, index)
    pScrollView:CheckShowGridMax(itemClass, index)
    itemClass:SetData(tbAllFriend[index], 0, 0)
    itemClass.index = index
    itemClass.pPanel.OnTouchEvent = fnOnClick
    itemClass.pPanel:Toggle_SetChecked("Main", self.nSelFriendIndex == index)
  end
  pScrollView:Update(tbAllFriend, fnSetFriend, 7, self.BackTop, self.BackBottom)
  self.pPanel:Label_SetText("Number", string.format("%d / %d", #tbAllFriend, FriendShip:GetMaxFriendNum(me.nLevel, me.GetVipLevel())))
  return true
end
function tbUi:RefreshEnemys()
  if not self.pPanel:IsActive("Enemy") then
    return
  end
  local tbAllEnemys = FriendShip:GetAllEnemyData()
  self.tbAllEnemys = tbAllEnemys
  local fnSort = function(a, b)
    return a.nHate > b.nHate
  end
  table.sort(tbAllEnemys, fnSort)
  if #tbAllEnemys > FriendShip.nMaxEnemyNum then
    for i = #tbAllEnemys, FriendShip.nMaxEnemyNum + 1, -1 do
      table.remove(tbAllEnemys)
    end
  end
  local pScrollView = self.ScrollViewEnemy
  local function fnSetEnemy(itemClass, index)
    pScrollView:CheckShowGridMax(itemClass, index)
    itemClass:SetData(tbAllEnemys[index])
  end
  pScrollView:Update(tbAllEnemys, fnSetEnemy, 7, self.BackTop2, self.BackBottom2)
  local nNow = GetTime()
  self.pPanel:Label_SetText("RevegeTime", DegreeCtrl:GetDegree(me, "Revenge", nNow))
  self.nCdTime = FriendShip:GetRevengeCDTiem(nNow)
  if self.nCdTime <= 0 then
    self.pPanel:SetActive("btnEliminate", false)
    self.pPanel:Label_SetText("CDtime", "0")
    self.pPanel:Label_SetColor("CDtime", 255, 255, 255)
  end
end
function tbUi:RefreshWanteds()
  if not self.pPanel:IsActive("Wanted") then
    return
  end
  FriendShip:ClearNewWantedMsg()
  if not self.nRequestWantedTime or GetTime() - self.nRequestWantedTime > FriendShip.nRequsetWantedCdTime then
    RemoteServer.RequestWantedData()
    self.nRequestWantedTime = GetTime()
  end
  local nCathchTime = DegreeCtrl:GetDegree(me, "Catch")
  self.pPanel:Label_SetText("WantedTime", nCathchTime)
  self.pPanel:SetActive("BtnPlusWanted", nCathchTime <= 0)
  local tbWantedData = FriendShip.tbWantedData
  if #tbWantedData == 0 then
    self.ScrollViewWanted:Update(0)
    return
  end
  local fnSort = function(a, b)
    if a.bSended and not b.bSended then
      return false
    elseif not a.bSended and b.bSended then
      return true
    elseif a.szCactherName and not b.szCactherName then
      return false
    elseif not a.szCactherName and b.szCactherName then
      return true
    else
      return a.nEndTime < b.nEndTime
    end
  end
  table.sort(tbWantedData, fnSort)
  local function fnSetWanted(itemClass, index)
    itemClass:SetData(tbWantedData[index])
  end
  self.ScrollViewWanted:Update(tbWantedData, fnSetWanted)
end
function tbUi:UpdateFriendData(bModify)
  self:RefreshAllFriend(bModify)
  self:RefreshEnemys()
  self:RefreshWanteds()
end
function tbUi:RefreshFriendRank()
  self.FriendsRankPanel:Init()
end
function tbUi:RefreshTeacherStudent(...)
  self.MasterPanel:OnOpen(...)
end
function tbUi:OpenHelpClicker()
  self.nHelpStep = 0
  self:UpdateHelp()
end
local _tbHelp = {
  {
    "HelpClicker",
    "GuideStep1"
  },
  {
    "HelpClicker",
    "GuideStep2"
  },
  {
    "HelpClicker",
    "GuideStep3"
  },
  {
    "HelpClicker",
    "GuideStep4"
  },
  {
    "HelpClicker",
    "GuideStep5"
  }
}
local tbHelp = {}
local tbAllHelpWnd = {}
for nSetpId, tbInfo in ipairs(_tbHelp) do
  tbHelp[nSetpId] = {}
  for _, szWnd in ipairs(tbInfo) do
    tbHelp[nSetpId][szWnd] = true
    tbAllHelpWnd[szWnd] = true
  end
end
function tbUi:UpdateHelp()
  self.nHelpStep = self.nHelpStep + 1
  if tbHelp[self.nHelpStep] then
    for szWnd, _ in pairs(tbAllHelpWnd) do
      self.pPanel:SetActive(szWnd, tbHelp[self.nHelpStep][szWnd])
    end
  else
    for szWnd, _ in pairs(tbAllHelpWnd) do
      self.pPanel:SetActive(szWnd, false)
    end
  end
end
tbUi.tbOnClick = {}
function tbUi.tbOnClick:HelpClicker()
  self:UpdateHelp()
end
function tbUi.tbOnClick:BtnClose()
  Ui:CloseWindow(self.UI_NAME)
end
function tbUi.tbOnClick:BtnFriendApply()
  Ui:OpenWindow("FriendApplyPanel")
end
function tbUi.tbOnClick:BtnFriends()
  self:ShowPanel("FriendPanel")
  self:RefreshAllFriend()
end
function tbUi.tbOnClick:BtnHelp()
  Ui:OpenWindow("PlantHelpCurePanel")
  HousePlant:ClearHelpCureRedPoint()
end
function tbUi:UpdateEnemyTogggle(szBtnName)
  local tbBtns = {"BtnWanted", "BtnEnemys2"}
  for i, v in ipairs(tbBtns) do
    self.pPanel:Toggle_SetChecked(v, v == szBtnName)
  end
end
function tbUi.tbOnClick:BtnEnemys()
  self:ShowPanel("WantedPanel")
  if Ui:GetRedPointState("Wanted") then
    self:UpdateEnemyTogggle("BtnWanted")
    self.tbOnClick.BtnWanted(self)
  else
    self:UpdateEnemyTogggle("BtnEnemys2")
    self.tbOnClick.BtnEnemys2(self)
  end
end
function tbUi.tbOnClick:BtnEnemys2()
  self.pPanel:SetActive("Enemy", true)
  self.pPanel:SetActive("Wanted", false)
  self:RefreshEnemys()
  if Ui:GetRedPointState("NG_Enemy") then
    Guide.tbNotifyGuide:ClearNotifyGuide("Enemy")
    self:OpenHelpClicker()
  end
end
function tbUi.tbOnClick:BtnWanted()
  self.pPanel:SetActive("Enemy", false)
  self.pPanel:SetActive("Wanted", true)
  self:RefreshWanteds()
end
function tbUi.tbOnClick:BtnMaster(...)
  self:ShowPanel("MasterPanel")
  self:RefreshTeacherStudent(...)
end
function tbUi.tbOnClick:BtnFriendsRank()
  self:ShowPanel("FriendsRankPanel")
  self:RefreshFriendRank()
end
function tbUi.tbOnClick:btnEliminate()
  local fnAgree = function()
    RemoteServer.RequestClearRevengeTime()
  end
  local nCdTime = FriendShip:GetRevengeCDTiem()
  local nRevengeGold = FriendShip:GetRevengeCDMoney(nCdTime)
  if nRevengeGold > me.GetMoney("Gold") then
    me.CenterMsg("您的元宝不足了")
    Ui:OpenWindow("CommonShop", "Recharge", "Recharge")
    return
  end
  Ui:OpenWindow("MessageBox", string.format("是否花费 [FFFE0D]%d元宝[-]，清除冷却时间？", nRevengeGold), {
    {fnAgree},
    {}
  }, {"同意", "取消"})
end
function tbUi.tbOnClick:BtnSearchFriend()
  Ui:OpenWindow("AddFriendPanel")
end
function tbUi.tbOnClick:BtnPlusWanted()
  me.BuyTimes("Catch", 1)
end
function tbUi.tbOnClick:BtnQQFriend()
  Ui:OpenWindow("QQFriendApplyPanel")
end
if not version_tx then
  function tbUi.tbOnClick:BtnReunionOverseas()
    Ui:OpenWindow("FriendRecallPanel")
  end
end
function tbUi:RegisterEvent()
  local tbRegEvent = {
    {
      UiNotify.emNoTIFY_SYNC_FRIEND_DATA,
      self.UpdateFriendData
    },
    {
      UiNotify.emNOTIFY_BUY_DEGREE_SUCCESS,
      self.UpdateFriendData
    },
    {
      UiNotify.emNOTIFY_UPDATE_PLAT_FRIEND_INFO,
      self.RefreshFriendRank
    },
    {
      UiNotify.emNOTIFY_TS_REFRESH_MAIN_INFO,
      self.TS_RefreshMainInfo,
      self
    },
    {
      UiNotify.emNOTIFY_TS_REFRESH_TEACHER_LIST,
      self.TS_RefreshFindTeacher,
      self
    },
    {
      UiNotify.emNOTIFY_TS_REFRESH_STUDENT_LIST,
      self.TS_RefreshFindStudent,
      self
    },
    {
      UiNotify.emNOTIFY_TS_REFRESH_APPLY_LIST,
      self.TS_RefreshApplyList,
      self
    },
    {
      UiNotify.emNOTIFY_TS_REFRESH_OTHER_STATUS,
      self.TS_RefreshOtherStatus,
      self
    },
    {
      UiNotify.emNOTIFY_UPDATE_RECALL_LIST,
      self.UpdateFriendData
    }
  }
  return tbRegEvent
end
function tbUi:TS_RefreshMainInfo(...)
  self.MasterPanel:RefreshMainInfo(...)
end
function tbUi:TS_RefreshFindTeacher(...)
  self.MasterPanel:RefreshFindTeacher(...)
end
function tbUi:TS_RefreshFindStudent(...)
  self.MasterPanel:RefreshFindStudent(...)
end
function tbUi:TS_RefreshApplyList(...)
  self.MasterPanel:RefreshApplyList(...)
end
function tbUi:TS_RefreshOtherStatus(...)
  self.MasterPanel:RefreshOtherStatus(...)
end
