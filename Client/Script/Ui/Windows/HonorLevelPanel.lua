Require("CommonScript/Player/HonorLevel.lua")
local tbHonorLevel = Player.tbHonorLevel
local tbUi = Ui:CreateClass("HonorLevelPanel")
tbUi.tbTitleUpgradePos = {
  tbNormal = {0, -241},
  tbRepair = {100, -241}
}
function tbUi:OnOpen()
  if tbHonorLevel.nMinOpenLevel > me.nLevel then
    me.CenterMsg(string.format("需要%s级才开启头衔", tbHonorLevel.nMinOpenLevel))
    return 0
  end
  self:UpdateInfo()
  self:StartHelpTips()
end
tbUi.tbOnClick = {
  BtnClose = function(self)
    Ui:CloseWindow("HonorLevelPanel")
  end,
  BtnStronger = function(self)
    Ui:OpenWindow("StrongerPanel")
  end,
  BtnFuben = function(self)
    Ui:OpenWindow("FubenSectionPanel")
  end,
  BtnTitleUpgrade = function(self)
    RemoteServer.FinishHonorLevel()
  end,
  BtnPay = function(self)
    Ui:OpenWindow("HonorLevelPayPop")
  end,
  HelpClicker = function(self)
    self:UpdateHelpTips()
  end
}
function tbUi:GetAttribMsg(nHonorLevel)
  if nHonorLevel <= 0 then
    return ""
  end
  local tbExtAttrib = KItem.GetExternAttrib(tbHonorLevel.XD_EX_HONOR_ATTRIB_GROUP, nHonorLevel)
  local szAttribMsg = ""
  for _, tbAttrib in ipairs(tbExtAttrib) do
    local szDesc = FightSkill:GetMagicDesc(tbAttrib.szAttribName, tbAttrib.tbValue)
    if not Lib:IsEmptyStr(szDesc) then
      szAttribMsg = szAttribMsg .. szDesc .. "\n"
    end
  end
  return szAttribMsg
end
function tbUi:UpdateInfo()
  local bRet, tbAddHonorInfo = tbHonorLevel:CheckTimeFrameRedPoint(me)
  if bRet then
    local tbUserSet = Client:GetUserInfo("HonorLevelData")
    tbUserSet.szRedPoint = tbAddHonorInfo.TimeFrame
    Client:SaveUserInfo()
    Log("HonorLevel UpdateRedPoint", tbUserSet.szRedPoint)
  end
  tbHonorLevel:UpdateRedPoint()
  local nAddHonorLevel = me.nHonorLevel + 1
  local tbCurHonorInfo = tbHonorLevel:GetHonorLevelInfo(me.nHonorLevel)
  self.pPanel:SetActive("Title1", true)
  if not tbCurHonorInfo then
    self.pPanel:SetActive("Title1", false)
  else
    self.pPanel:Sprite_Animation("Title1", tbCurHonorInfo.ImgPrefix)
  end
  local nFPLevel = me.nHonorLevel
  local nFightPower = 0
  if nFPLevel == me.nHonorLevel and tbCurHonorInfo then
    nFightPower = tbCurHonorInfo.PowerValue
  end
  if nFightPower > 0 then
    self.pPanel:SetActive("FightValue1", true)
    local szMsg = self:GetAttribMsg(me.nHonorLevel)
    self.pPanel:Label_SetText("FightValue1", string.format("战力  +%s\n%s", nFightPower, szMsg))
  else
    self.pPanel:SetActive("FightValue1", false)
  end
  local tbHonorInfo = tbHonorLevel:GetHonorLevelInfo(nAddHonorLevel)
  if not tbHonorInfo or GetTimeFrameState(tbHonorInfo.TimeFrame) ~= 1 then
    self.pPanel:SetActive("NextTitle", false)
    self.pPanel:SetActive("Arrow", false)
    self.pPanel:SetActive("PowerContainer", false)
    self.pPanel:SetActive("YXLContainer", false)
    if tbHonorInfo then
      self.pPanel:SetActive("NextTitle", true)
      self.pPanel:SetActive("Arrow", true)
      self.pPanel:Sprite_Animation("Title2", tbHonorInfo.ImgPrefix)
      self.pPanel:Label_SetText("FightValue2", "暂未开放\n敬请期待")
    end
    return
  end
  self.pPanel:SetActive("NextTitle", true)
  self.pPanel:SetActive("Arrow", true)
  self.pPanel:SetActive("PromotionConditions", true)
  self.pPanel:SetActive("PowerContainer", true)
  self.pPanel:SetActive("YXLContainer", true)
  local nItemCount = 0
  if 0 < tbHonorInfo.ItemID then
    nItemCount = me.GetItemCountInAllPos(tbHonorInfo.ItemID)
  end
  self.pPanel:SetActive("NextTitle", true)
  self.pPanel:SetActive("Arrow", true)
  self.pPanel:Sprite_Animation("Title2", tbHonorInfo.ImgPrefix)
  if 0 < tbHonorInfo.PowerValue and nFPLevel == me.nHonorLevel and (nItemCount >= tbHonorInfo.ItemCount or GetTimeFrameState(tbHonorInfo.RepairTimeFrame) ~= 1) then
    local szMsg = self:GetAttribMsg(me.nHonorLevel + 1)
    self.pPanel:SetActive("FightValue2", true)
    self.pPanel:Label_SetText("FightValue2", string.format("战力  +%s\n%s", tbHonorInfo.PowerValue, szMsg))
  else
    self.pPanel:SetActive("FightValue2", false)
  end
  local pNpc = me.GetNpc()
  local nFightPower = pNpc.GetFightPower()
  self.pPanel:Label_SetText("Fight", string.format("%s / %s", nFightPower, tbHonorInfo.NeedPower))
  if nFightPower >= tbHonorInfo.NeedPower then
    self.pPanel:Label_SetColorByName("Fight", "Green")
  else
    self.pPanel:Label_SetColorByName("Fight", "White")
  end
  local bGreen = false
  if 0 < tbHonorInfo.ItemCount and (nItemCount >= tbHonorInfo.ItemCount or GetTimeFrameState(tbHonorInfo.RepairTimeFrame) ~= 1) then
    self.pPanel:SetActive("YXLContainer", true)
    local szName = KItem.GetItemShowInfo(tbHonorInfo.ItemID)
    self.pPanel:Label_SetText("YXLMsg", string.format("集齐%s：", szName))
    self.pPanel:Label_SetText("YXL", string.format("%s / %s", nItemCount, tbHonorInfo.ItemCount))
  else
    bGreen = true
    self.pPanel:Label_SetText("YXL", "免费")
    self.pPanel:SetActive("YXLContainer", false)
  end
  if nItemCount >= tbHonorInfo.ItemCount or bGreen then
    self.pPanel:Label_SetColorByName("YXL", "Green")
  else
    self.pPanel:Label_SetColorByName("YXL", "White")
  end
end
local _tbHelp = {
  {
    "HelpClicker",
    "GuideStep1"
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
function tbUi:StartHelpTips()
  if Guide.tbNotifyGuide:IsFinishGuide("TitleGuide") == 0 then
    self.pPanel:SetActive("HelpClicker", true)
    self.nHelpStep = 0
    self:UpdateHelpTips()
    Guide.tbNotifyGuide:ClearNotifyGuide("TitleGuide", true)
  else
    self.pPanel:SetActive("HelpClicker", false)
  end
end
function tbUi:UpdateHelpTips()
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
function tbUi:RegisterEvent()
  local tbRegEvent = {
    {
      UiNotify.emNOTIFY_SYNC_ITEM,
      self.UpdateInfo
    }
  }
  return tbRegEvent
end
local tbHonorPop = Ui:CreateClass("HonorLevelPayPop")
tbHonorPop.tbOnClick = {
  BtnClose = function(self)
    Ui:CloseWindow("HonorLevelPayPop")
  end,
  BtnOk = function(self)
    local bRet, szMsg = tbHonorLevel:CheckRepairItem(me)
    if not bRet then
      me.CenterMsg(szMsg)
      return
    end
    Ui:CloseWindow("HonorLevelPayPop")
  end
}
function tbHonorPop:OnOpen()
  local nFPLevel = me.GetUserValue(tbHonorLevel.nSaveGroupID, tbHonorLevel.nSaveFightPower) + 1
  local tbHonorInfo = tbHonorLevel:GetHonorLevelInfo(nFPLevel)
  if not tbHonorInfo then
    return 0
  end
  self.pPanel:Sprite_Animation("Title", tbHonorInfo.ImgPrefix)
  local szShow = string.format("晋升          未缴纳英雄令，是否补交英雄令     [FFFE0D]%s[-]个，将获得 [FFFE0D]%s[-] 战力", tbHonorInfo.ItemCount, tbHonorInfo.PowerValue)
  self.pPanel:Label_SetText("TextInfo", szShow)
end
