local tbUi = Ui:CreateClass("WLDHJoinPanel")
local tbDef = WuLinDaHui.tbDef
tbUi.tbTabButtons = {
  "BtnDoublesManMatch",
  "BtnThreeManMatch",
  "BtnThreeManDuel",
  "BtnFourManMatch"
}
function tbUi:OnOpen(nGameType)
  Client:SetFlag("WLDHViewPanelTime", GetTime())
  WuLinDaHui:CheckRedPoint()
  local bRet, szActName = WuLinDaHui:IsShowTopButton()
  if not bRet then
    me.CenterMsg("当前没有武林大会")
    return 0
  end
  WuLinDaHui:CheckRequestTeamData()
  self.szActName = szActName
  local nActStartTime, nActEndTime = Activity:__GetActTimeInfo(szActName)
  self.nActEndTime = nActEndTime
  self.nActStartTime = nActStartTime
  local tbUiShowItemIds = WuLinDaHui.tbDef.tbUiShowItemIds
  for j = 1, 16 do
    local tbItemGrid = self["itemframe" .. j]
    local i = j > 8 and j - 8 or j
    local nItemId = tbUiShowItemIds[i]
    if nItemId then
      tbItemGrid.pPanel:SetActive("Main", true)
      tbItemGrid:SetItemByTemplate(nItemId, 1)
      tbItemGrid.fnClick = tbItemGrid.DefaultClick
    else
      tbItemGrid.pPanel:SetActive("Main", false)
    end
  end
end
function tbUi:OnOpenEnd(nGameType)
  if not nGameType and self.szActName == WuLinDaHui.szActNameMain then
    nGameType = WuLinDaHui:GetToydayGameFormat()
  end
  if nGameType then
    for i, v in ipairs(self.tbTabButtons) do
      self.pPanel:Toggle_SetChecked(v, nGameType == i)
    end
  end
  self:Update()
end
function tbUi:Update()
  self.pPanel:SetActive("Panel1", false)
  self.pPanel:SetActive("Panel2", false)
  if self.szActName == WuLinDaHui.szActNameYuGao then
    self.pPanel:Texture_SetTexture("Texture", "UI/Textures/WLDH0.png")
    self.pPanel:SetActive("Tab", false)
    self.pPanel:SetActive("Panel3", true)
    self.pPanel:Label_SetText("Content3", tbDef.szYuGaoUiDesc)
    local tbTextSize2 = self.pPanel:Label_GetPrintSize("Content3")
    local tbSize = self.pPanel:Widget_GetSize("datagroup")
    self.pPanel:Widget_SetSize("datagroup", tbSize.x, 50 + tbTextSize2.y)
    self.pPanel:DragScrollViewGoTop("datagroup")
    self.pPanel:UpdateDragScrollView("datagroup")
    self:UpdateLeftTime()
  else
    self.pPanel:SetActive("Tab", true)
    self.pPanel:SetActive("Panel3", false)
    self:UpdateMatchInfo()
  end
end
function tbUi:GetCurSelectGameType()
  if self.pPanel:Toggle_GetChecked("BtnDoublesManMatch") then
    return 1
  elseif self.pPanel:Toggle_GetChecked("BtnThreeManMatch") then
    return 2
  elseif self.pPanel:Toggle_GetChecked("BtnThreeManDuel") then
    return 3
  elseif self.pPanel:Toggle_GetChecked("BtnFourManMatch") then
    return 4
  end
end
function tbUi:InitPosInfo()
  self.tbTabButtonsPos = {}
  for i, v in ipairs(self.tbTabButtons) do
    local tbPos = self.pPanel:GetPosition(v)
    self.tbTabButtonsPos[i] = tbPos
  end
end
function tbUi:UpdateMatchInfo()
  if not self.tbTabButtonsPos then
    self:InitPosInfo()
  end
  local bOldActive = self.pPanel:IsActive("BtnSignUpStage")
  if self.szActName == WuLinDaHui.szActNameBaoMing then
    self.pPanel:SetActive("BtnSignUpStage", true)
    if not bOldActive then
      for i, v in ipairs(self.tbTabButtons) do
        local tbPos = self.tbTabButtonsPos[i]
        self.pPanel:ChangePosition(v, tbPos.x, tbPos.y)
      end
    end
  else
    self.pPanel:SetActive("BtnSignUpStage", false)
    self.pPanel:Toggle_SetChecked("BtnSignUpStage", false)
    if bOldActive then
      for i, v in ipairs(self.tbTabButtons) do
        local tbPos = self.tbTabButtonsPos[i]
        self.pPanel:ChangePosition(v, tbPos.x - 135, tbPos.y)
      end
    end
  end
  if self.pPanel:Toggle_GetChecked("BtnSignUpStage") then
    self:UpdateSignUpStage()
  else
    local nCurGameType = self:GetCurSelectGameType()
    if nCurGameType then
      self:UpdateBattleType(nCurGameType)
    elseif self.pPanel:IsActive("BtnSignUpStage") then
      self.pPanel:Toggle_SetChecked("BtnSignUpStage", true)
      self:UpdateSignUpStage()
    else
      nCurGameType = 1
      self:UpdateBattleType(nCurGameType)
    end
    for i, v in ipairs(self.tbTabButtons) do
      self.pPanel:Toggle_SetChecked(v, nCurGameType == i)
    end
  end
end
function tbUi:UpdateSignUpStage()
  self.pPanel:Texture_SetTexture("Texture", "UI/Textures/WLDH0.png")
  self.pPanel:SetActive("Panel1", true)
  self:UpdateLeftTime()
  local bCanSigUp = WuLinDaHui:IsCanSigUp(me)
  if bCanSigUp then
    self.pPanel:SetActive("QualificationSituation1", true)
    self.pPanel:SetActive("QualificationSituation2", false)
    self.pPanel:SetActive("QualificationSituation3", false)
    self.pPanel:SetActive("BtnBuy", false)
  elseif WuLinDaHui:IsCanBuyTicket(me) then
    self.pPanel:SetActive("QualificationSituation1", false)
    self.pPanel:SetActive("QualificationSituation2", true)
    self.pPanel:SetActive("QualificationSituation3", false)
    self.pPanel:SetActive("BtnBuy", true)
  else
    self.pPanel:SetActive("QualificationSituation1", false)
    self.pPanel:SetActive("QualificationSituation2", false)
    self.pPanel:SetActive("QualificationSituation3", true)
    self.pPanel:SetActive("BtnBuy", false)
  end
  local nSignTeamNum = WuLinDaHui:GetPlayerTeamNum()
  local bFullTeam = nSignTeamNum >= WuLinDaHui.tbDef.nMaxJoinTeamNum
  for i, v in ipairs(WuLinDaHui.tbGameFormat) do
    self.pPanel:Label_SetText("MatchTitle" .. i, v.szName)
    local nMatchDayTime = self.nActEndTime + 86400 * (i - 1)
    local tbTime = os.date("*t", nMatchDayTime)
    self.pPanel:Label_SetText("SituationTime" .. i, string.format("初赛时间：%d月%d日%s，%s", tbTime.month, tbTime.day, WuLinDaHui.tbDef.tbStartMatchTime[1], WuLinDaHui.tbDef.tbStartMatchTime[2]))
    local tbTeamInfo = Player:GetServerSyncData("WLDHFightTeamInfo" .. i) or {}
    if not tbTeamInfo.szName then
      self.pPanel:SetActive("MatchSituation" .. i, false)
      self.pPanel:SetActive("Team" .. i, false)
      self.pPanel:SetActive("TeamName" .. i, false)
      self.pPanel:SetActive("BtnTip" .. i, false)
      self.pPanel:SetActive("BtnSignUp" .. i, true)
      self.pPanel:SetActive("BtnCancel" .. i, false)
      self.pPanel:SetActive("Describe" .. i, true)
      self.pPanel:Label_SetText("Describe" .. i, v.szDescTip)
      self.pPanel:Button_SetEnabled("BtnSignUp" .. i, not bFullTeam)
    else
      self.pPanel:SetActive("MatchSituation" .. i, true)
      self.pPanel:SetActive("Team" .. i, true)
      self.pPanel:SetActive("TeamName" .. i, true)
      self.pPanel:SetActive("BtnTip" .. i, true)
      self.pPanel:SetActive("BtnSignUp" .. i, false)
      self.pPanel:SetActive("BtnCancel" .. i, true)
      self.pPanel:SetActive("Describe" .. i, false)
      self.pPanel:Label_SetText("TeamName" .. i, tbTeamInfo.szName)
    end
  end
end
function tbUi:UpdateBattleType(nGameType)
  self.pPanel:SetActive("Panel1", false)
  self.pPanel:SetActive("Panel2", true)
  local szDescContent = tbDef.tbMatchUiDesc[nGameType]
  self.pPanel:Label_SetText("Content2", szDescContent)
  self.pPanel:Texture_SetTexture("Texture", string.format("UI/Textures/WLDH%d.png", nGameType))
  local tbTeamInfo = Player:GetServerSyncData("WLDHFightTeamInfo" .. nGameType) or {}
  local tbGameFormat = WuLinDaHui.tbGameFormat[nGameType]
  local nNow = GetTime()
  local nToday = Lib:GetLocalDay()
  local szTimeConent = ""
  local bShowBtnBattlefield = false
  local bShowBtnMatchRank = false
  if self.szActName == WuLinDaHui.szActNameBaoMing then
    local tbTime = os.date("*t", self.nActEndTime + 86400 * (nGameType - 1))
    szTimeConent = string.format("初赛时间：%d月%d日%s", tbTime.month, tbTime.day, WuLinDaHui.tbDef.tbStartMatchTime[1])
    self.pPanel:SetActive("BtnTeamRelated", true)
    self.pPanel:Button_SetText("BtnTeamRelated", "战队相关")
  elseif self.szActName == WuLinDaHui.szActNameMain then
    local tbTimeNode = WuLinDaHui:GetMatchTimeNode(nGameType)
    table.sort(tbTimeNode, function(a, b)
      return a < b
    end)
    local nState = 1
    for i, v in ipairs(tbTimeNode) do
      if v <= nNow then
        nState = i + 1
      else
        break
      end
    end
    if nState == 1 or nState == 3 then
      local tbTime = os.date("*t", tbTimeNode[nState])
      szTimeConent = string.format("初赛时间：%d月%d日%02d:%02d", tbTime.month, tbTime.day, tbTime.hour, tbTime.min)
    elseif nState == 2 or nState == 4 then
      szTimeConent = string.format("初赛进行中")
    elseif nState == 5 then
      local tbTime = os.date("*t", tbTimeNode[nState])
      szTimeConent = string.format("决赛时间：%d月%d日%02d:%02d", tbTime.month, tbTime.day, tbTime.hour, tbTime.min)
    else
      local _, _, nWinTeamId = Player:GetServerSyncData("WLDHTopPreFightTeamList" .. nGameType)
      if nWinTeamId or nState == 7 then
        szTimeConent = "比赛已结束"
      else
        szTimeConent = "决赛进行中"
      end
    end
    bShowBtnBattlefield = nState >= 5
    bShowBtnMatchRank = nState >= 2
    if tbGameFormat.szPKClass == "PlayDuel" and tbTeamInfo.szName then
      self.pPanel:SetActive("BtnTeamRelated", true)
      self.pPanel:Button_SetText("BtnTeamRelated", "调整编号")
    else
      self.pPanel:SetActive("BtnTeamRelated", false)
    end
  end
  self.pPanel:SetActive("BtnMatchRank", bShowBtnMatchRank)
  self.pPanel:SetActive("BtnBattlefield", bShowBtnBattlefield)
  if bShowBtnBattlefield and WuLinDaHui:CanGuessing(nGameType) then
    self.pPanel:SetActive("GuessingMark", true)
  else
    self.pPanel:SetActive("GuessingMark", false)
  end
  self.pPanel:Label_SetText("MatchTime", szTimeConent)
  local szJoinBtnName = "参加比赛"
  if not tbTeamInfo.szName then
    self.pPanel:SetActive("AlreadySignUp", false)
    self.pPanel:SetActive("TeamInformation", false)
    self.pPanel:SetActive("MatchLimite", true)
    self.pPanel:SetActive("TeamTip", false)
    if self.szActName ~= WuLinDaHui.szActNameBaoMing then
      self.pPanel:Label_SetText("MatchLimite", "当前不可报名")
    elseif not WuLinDaHui:IsCanSigUp(me) then
      self.pPanel:Label_SetText("MatchLimite", "当前不具备报名资格")
    elseif WuLinDaHui:GetPlayerTeamNum(me) >= WuLinDaHui.tbDef.nMaxJoinTeamNum then
      self.pPanel:Label_SetText("MatchLimite", "您报名的比赛已达上限")
    else
      self.pPanel:Label_SetText("MatchLimite", "您还未报名该比赛！\n请通过“战队相关--创建战队”来报名")
    end
  else
    self.pPanel:SetActive("AlreadySignUp", true)
    self.pPanel:SetActive("TeamInformation", true)
    self.pPanel:SetActive("MatchLimite", false)
    self.pPanel:SetActive("TeamTip", true)
    self.pPanel:Label_SetText("TeamName", tbTeamInfo.szName)
    self.pPanel:Label_SetText("TeamTime", string.format("%s/%s", tbTeamInfo.nJoinCount or 0, WuLinDaHui.tbDef.tbPrepareGame.nPerDayJoinCount))
    local fWinPer = WuLinDaHui.tbDef.nDefWinPercent * 100
    if tbTeamInfo.nJoinCount > 0 then
      fWinPer = math.floor(100 * tbTeamInfo.nWinCount / tbTeamInfo.nJoinCount)
    end
    self.pPanel:Label_SetText("WinningProbability", fWinPer .. "%")
  end
  if bShowBtnBattlefield and (not tbTeamInfo or tbTeamInfo.nFinals ~= nGameType) then
    szJoinBtnName = "观战"
  end
  self.pPanel:Label_SetText("LbJoin", szJoinBtnName)
end
function tbUi:UpdateLeftTime()
  self:CloseTimer()
  local function fnTimer()
    local nNow = GetTime()
    local nLeftTime = math.max(self.nActEndTime - nNow, 0)
    if self.szActName == WuLinDaHui.szActNameYuGao then
      self.pPanel:Label_SetText("StartTime", string.format("大会即将开始：%s", Lib:TimeDesc5(nLeftTime)))
    else
      self.pPanel:Label_SetText("SignUpTime", string.format("正在报名：%s", Lib:TimeDesc5(nLeftTime)))
    end
    return true
  end
  fnTimer()
  self.nTimer = Timer:Register(Env.GAME_FPS * 1, fnTimer)
end
function tbUi:CloseTimer()
  if self.nTimer then
    Timer:Close(self.nTimer)
    self.nTimer = nil
  end
end
function tbUi:OnClose()
  self:CloseTimer()
end
function tbUi:OnLeaveMap()
  Ui:CloseWindow(self.UI_NAME)
end
function tbUi:RegisterEvent()
  local tbRegEvent = {
    {
      UiNotify.emNOTIFY_SYNC_DATA,
      self.OnSyncData
    },
    {
      UiNotify.emNOTIFY_MAP_LEAVE,
      self.OnLeaveMap
    }
  }
  return tbRegEvent
end
function tbUi:OnSyncData(szType)
  if type(szType) == "string" and string.find(szType, "WLDHFightTeamInfo") then
    self:Update()
  elseif type(szType) == "string" and string.find(szType, "WLDHTopPreFightTeamList") then
    self:Update()
  elseif szType == "WLDHRefreshMainUi" then
    self:Update()
  elseif szType == "WLDHCreateFightTeam" then
    self:CloseFightTeamUI()
  elseif szType == "WLDHJoinFightTeam" then
    self:CloseFightTeamUI()
  elseif szType == "WLDHQuitFightTeam" then
    self:CloseFightTeamUI()
  end
end
function tbUi:CloseFightTeamUI()
  if Ui:WindowVisible("TeamRelatedPanel") == 1 then
    Ui:CloseWindow("TeamRelatedPanel")
  end
  if Ui:WindowVisible("CreateTeamPanel") == 1 then
    Ui:CloseWindow("CreateTeamPanel")
  end
end
function tbUi:OnClickBtnTip(index)
  local tbTeamInfo = Player:GetServerSyncData("WLDHFightTeamInfo" .. index) or {}
  local nFightTeamID = tbTeamInfo.nFightTeamID
  if not nFightTeamID then
    me.CenterMsg("无战队信息")
    return
  end
  Ui:OpenWindow("TeamDetailsPanel", nFightTeamID, false, index)
end
function tbUi:OnClickBtnSignUp(index)
  if not WuLinDaHui:IsCanSigUp(me) then
    if not WuLinDaHui:IsCanBuyTicket(me) then
      me.CenterMsg("很遗憾，阁下不具有参与武林大会的资格！", true)
      return
    end
    me.CenterMsg("阁下未购买门票，请先购买再报名！", true)
    return
  end
  Ui:OpenWindow("CreateTeamPanel", index)
end
function tbUi:OnClickBtnCancel(index)
  RemoteServer.DoRequesWLDH("DeleteFightTeam", index)
end
tbUi.tbOnClick = {}
function tbUi.tbOnClick:BtnClose()
  Ui:CloseWindow(self.UI_NAME)
end
function tbUi.tbOnClick:BtnBuy()
  local bRet, szMsg = WuLinDaHui:IsCanBuyTicket(me)
  if not bRet then
    me.CenterMsg(szMsg)
    return
  end
  if me.GetMoney("Gold") < WuLinDaHui.tbDef.nSellTicketGold then
    me.CenterMsg("元宝不足")
    return
  end
  local fnYes = function()
    RemoteServer.DoRequesWLDH("BuyTicket")
  end
  me.MsgBox(string.format("购买门票将花费%s元宝，阁下确定吗？", WuLinDaHui.tbDef.nSellTicketGold), {
    {"确定", fnYes},
    {"取消"}
  })
end
function tbUi.tbOnClick:BtnSignUpStage()
  self:Update()
end
function tbUi.tbOnClick:BtnDoublesManMatch()
  self:Update()
end
function tbUi.tbOnClick:BtnThreeManMatch()
  self:Update()
end
function tbUi.tbOnClick:BtnThreeManDuel()
  self:Update()
end
function tbUi.tbOnClick:BtnFourManMatch()
  self:Update()
end
function tbUi.tbOnClick:BtnTeamRelated()
  local nGameType = self:GetCurSelectGameType()
  assert(nGameType)
  if self.szActName == WuLinDaHui.szActNameBaoMing then
    Ui:OpenWindow("TeamRelatedPanel", nGameType)
  elseif self.szActName == WuLinDaHui.szActNameMain then
    local tbGameFormat = WuLinDaHui.tbGameFormat[nGameType]
    if tbGameFormat.szPKClass == "PlayDuel" then
      Ui:OpenWindow("PlayerNumberPanel", nGameType)
    else
      Log("Error!!!!!!!!!!BtnTeamRelated")
    end
  end
end
function tbUi.tbOnClick:BtnBattlefield()
  local nGameType = self:GetCurSelectGameType()
  assert(nGameType)
  Ui:OpenWindow("WLDHBattlefieldPanel", nGameType)
end
function tbUi.tbOnClick:BtnJoin()
  local nToDayGameType = WuLinDaHui:GetToydayGameFormat()
  if not nToDayGameType then
    me.CenterMsg("今天没有比赛")
    return
  end
  local nGameType = self:GetCurSelectGameType()
  if nGameType ~= nToDayGameType then
    local tbGameFormat = WuLinDaHui.tbGameFormat[nToDayGameType]
    me.CenterMsg(string.format("今天举行的是%s", tbGameFormat.szName))
    return
  end
  RemoteServer.DoRequesWLDH("ApplyPlayGame")
end
function tbUi.tbOnClick:BtnMatchRank()
  local nGameType = self:GetCurSelectGameType()
  assert(nGameType)
  Ui:OpenWindow("WLDHRankPanel", nGameType)
end
function tbUi.tbOnClick:TeamTip()
  local nGameType = self:GetCurSelectGameType()
  assert(nGameType)
  self:OnClickBtnTip(nGameType)
end
function tbUi.tbOnClick:BtnTip()
  Ui:OpenWindow("NewInformationPanel", WuLinDaHui.tbDef.szNewsKeyNotify)
end
for i = 1, 4 do
  tbUi.tbOnClick["BtnTip" .. i] = function(self)
    self:OnClickBtnTip(i)
  end
  tbUi.tbOnClick["BtnSignUp" .. i] = function(self)
    self:OnClickBtnSignUp(i)
  end
  tbUi.tbOnClick["BtnCancel" .. i] = function(self)
    self:OnClickBtnCancel(i)
  end
end
