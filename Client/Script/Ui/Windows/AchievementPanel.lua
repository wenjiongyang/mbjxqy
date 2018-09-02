local tbUi = Ui:CreateClass("AchievementPanel")
tbUi.tbOnClick = {
  BtnClose = function(self)
    Ui:CloseWindow(self.UI_NAME)
  end,
  BtnFurniture = function(self)
    self:OpenAchList(1)
  end
}
function tbUi:RegisterEvent()
  local tbRegEvent = {
    {
      UiNotify.emNOTIFY_ACHIEVEMENT_DATA_SYNC,
      self.Update,
      self
    }
  }
  return tbRegEvent
end
local UI_MAX_STAR = 6
function tbUi:OnOpenEnd(nIndex)
  self.nSelectGroup = nIndex or self.nSelectGroup or 1
  self:Update()
  Achievement:CheckSpecilAchievement()
end
function tbUi:Update()
  self:UpdateCatalog()
  self:UpdateContent()
end
function tbUi:UpdateCatalog()
  local function fnOnClick(buttonObj)
    self.nSelectGroup = buttonObj.nIndex
    self:Update()
  end
  local function fnSetItem(itemObj, nIndex)
    local bSelect = nIndex == self.nSelectGroup
    local szName = Achievement.tbGroup[nIndex].szName
    itemObj.pPanel:Label_SetText("TxtBaseClass", szName)
    itemObj.pPanel:Label_SetText("TxtBaseClassDark", szName)
    itemObj.pPanel:SetActive("TxtBaseClass", bSelect)
    itemObj.pPanel:SetActive("TxtBaseClassDark", not bSelect)
    itemObj.pPanel:Sprite_SetSprite("Main", bSelect and "BtnListMainPress" or "BtnListMainNormal")
    local nCanGainNum = Achievement:GetKindGainNum(nIndex)
    itemObj.pPanel:SetActive("RedPoint", nCanGainNum > 0)
    itemObj.nIndex = nIndex
    itemObj.pPanel.OnTouchEvent = fnOnClick
  end
  self.ScrollViewCatalog:Update(#Achievement.tbGroup, fnSetItem)
end
local function fnSetStar(pPanel, nStar, nMaxLevel)
  local nStarBgCount = math.max(5, nMaxLevel)
  nStar = nStar == nMaxLevel and nStarBgCount or nStar
  for i = 1, UI_MAX_STAR do
    pPanel:SetActive("Star" .. i .. "_Bg", i <= nStarBgCount)
    local bAcitve = i <= nStar
    pPanel:SetActive("Star" .. i, bAcitve)
  end
end
local fnSetAward = function(itemObj, szKind, nShowLevel)
  local tbAward, nTitle = Achievement:GetAwardInfo(szKind, nShowLevel)
  local nGold = 0
  local szItemLink
  for _, tbInfo in ipairs(tbAward or {}) do
    local szType = tbInfo[1]
    local nValue = tbInfo[2]
    if szType == "Gold" or szType == "gold" then
      nGold = nGold + nValue
    elseif Player.AwardType[szType] == Player.award_type_item then
      local szName = KItem.GetItemShowInfo(nValue, me.nFaction)
      szItemLink = string.format("[url=openwnd:%s, ItemTips, 'Item', nil, %d, %d]", szName, nValue, me.nFaction)
    end
  end
  itemObj.pPanel:Label_SetText("Number", nGold)
  itemObj.pPanel:SetActive("TitliLabel", not szItemLink and nTitle > 0)
  itemObj.pPanel:SetActive("ItemAward", szItemLink or false)
  if not szItemLink and nTitle > 0 then
    PlayerTitle:SetTitleLabel(itemObj, "TitliLabel", nTitle)
  end
  if szItemLink then
    itemObj.ItemAward:SetLinkText(string.format("[73CBD5FF]家具奖励：[-][ff8f06]%s[-]", szItemLink))
  end
end
function tbUi:UpdateContent()
  local tbGroupKind = Achievement:GetGroupAchList(self.nSelectGroup) or {}
  local fnClickGain = function(buttonObj)
    RemoteServer.TryGainAchievementAward(buttonObj.szKind)
  end
  local function fnInitItem(itemObj, nIndex)
    local szKind = tbGroupKind[nIndex]
    local nCompletedLevel, nGainLevel, nCount = Achievement:GetGainData(szKind)
    local nMaxLevel = Achievement:GetMaxLevel(szKind)
    local bAllFinish = nCompletedLevel >= nMaxLevel
    local bCanGain = nGainLevel < nCompletedLevel
    local nStar = bCanGain and nGainLevel + 1 or nGainLevel
    fnSetStar(itemObj.pPanel, nStar, nMaxLevel)
    local nShowLevel = math.min(nGainLevel + 1, nMaxLevel)
    local nFinishCount = Achievement:GetFinishCount(szKind, nShowLevel)
    itemObj.pPanel:SetActive("ProgressBar", not bCanGain and not bAllFinish)
    itemObj.pPanel:Label_SetText("Percentage", string.format("%d/%d", nCount, nFinishCount))
    itemObj.pPanel:Sprite_SetFillPercent("ProgressFore", nCount / nFinishCount)
    local szTitle, szDesc = Achievement:GetTitleAndDesc(szKind, nShowLevel)
    itemObj.pPanel:Label_SetText("Achievement", szTitle)
    itemObj.pPanel:Label_SetText("Condition", szDesc)
    itemObj.pPanel:SetActive("Completed", nGainLevel == nMaxLevel)
    itemObj.pPanel:SetActive("BtnGain", bCanGain)
    fnSetAward(itemObj, szKind, nShowLevel)
    itemObj.BtnGain.szKind = szKind
    itemObj.BtnGain.pPanel.OnTouchEvent = fnClickGain
  end
  self.ScrollViewContent:Update(#tbGroupKind, fnInitItem)
end
function tbUi:OpenAchList(nType)
  Ui:OpenWindow("AchievementList", nType)
end
local AchievementDisplay = Ui:CreateClass("AchievementDisplay")
AchievementDisplay.tbOnClick = {
  BtnGain = function(self)
    RemoteServer.TryGainAchievementAward(self.szKind, self.nLevel)
    Ui:CloseWindowAni(self.UI_NAME, false)
  end
}
function AchievementDisplay:OnOpen(szMainKind, nLevel)
  self.szKind = szMainKind
  self.nLevel = nLevel
  local szTitle, szDesc = Achievement:GetTitleAndDesc(szMainKind, nLevel)
  self.pPanel:Label_SetText("Achievement", szTitle)
  self.pPanel:Label_SetText("Condition", szDesc)
  local nMaxLevel = Achievement:GetMaxLevel(szMainKind)
  local nStar = nLevel
  fnSetStar(self.pPanel, nStar, nMaxLevel)
  fnSetAward(self, szMainKind, nLevel)
  function self.pPanel.OnTouchEvent()
    local nGroupId = Achievement:GetGroupByKind(szMainKind)
    if nGroupId then
      Ui:OpenWindow("AchievementPanel", nGroupId)
    end
    Ui:CloseWindowAni(self.UI_NAME, false)
  end
  self.pPanel:Tween_Play("Main")
  self.nTimer = Timer:Register(Env.GAME_FPS * 6, self.FinishAnimation, self)
end
function AchievementDisplay:FinishAnimation()
  self:CloseTimer()
  Ui:CloseWindow(self.UI_NAME)
end
function AchievementDisplay:OnClose()
  self:CloseTimer()
end
function AchievementDisplay:CloseTimer()
  if self.nTimer then
    Timer:Close(self.nTimer)
    self.nTimer = nil
  end
end
local ChatAchievementPopup = Ui:CreateClass("ChatAchievementPopup")
local function fnSetStar_NoBg(pPanel, szKind, nLevel)
  local nMaxLevel = Achievement:GetMaxLevel(szKind)
  local nStar = nLevel == nMaxLevel and math.max(5, nMaxLevel) or nLevel
  for i = 1, UI_MAX_STAR do
    pPanel:SetActive("Star" .. i, i <= nStar)
  end
end
function ChatAchievementPopup:OnOpen(nId, nLevel, szName)
  local szKind = Achievement:GetKindById(nId)
  local szTitle, szDesc = Achievement:GetTitleAndDesc(szKind, nLevel)
  self.pPanel:Label_SetText("Achievement", szTitle)
  self.pPanel:Label_SetText("Condition", szDesc)
  self.pPanel:Label_SetText("Name", szName)
  fnSetStar_NoBg(self.pPanel, szKind, nLevel)
end
function ChatAchievementPopup:OnScreenClick(szClickUi)
  if szClickUi ~= self.UI_NAME then
    Ui:CloseWindow(self.UI_NAME)
  end
end
local ChatAchievement = Ui:CreateClass("ChatAchievement")
function ChatAchievement:SetContent(szKind, nLevel)
  local szTitle = Achievement:GetTitleAndDesc(szKind, nLevel)
  self.pPanel:Label_SetText("AchievementName", szTitle)
  fnSetStar_NoBg(self.pPanel, szKind, nLevel)
end
local TitlePop = Ui:CreateClass("AchievementTitle")
function TitlePop:OnOpen(nTitleId)
  if not nTitleId or nTitleId <= 0 then
    Ui:CloseWindow(self.UI_NAME)
    return
  end
  PlayerTitle:SetTitleLabel(self, "Label", nTitleId)
end
function TitlePop:OnScreenClick()
  Ui:CloseWindow(self.UI_NAME)
end
local ListPanel = Ui:CreateClass("AchievementList")
function ListPanel:RegisterEvent()
  local tbRegEvent = {
    {
      UiNotify.emNOTIFY_ACHIEVEMENT_DATA_SYNC,
      self.Update,
      self
    }
  }
  return tbRegEvent
end
function ListPanel:OnOpenEnd(nType)
  self.nType = nType
  self:Update()
end
function ListPanel:Update()
  local tbList = Achievement:GetListByType(self.nType)
  local function fnSet(itemObj, nIdx)
    local szKind = tbList[nIdx][1]
    local nShowLevel = tbList[nIdx][2]
    local szSubKind = Achievement:GetSubKind(szKind, nShowLevel)
    local nCount = Achievement:GetSubKindCount(me, szSubKind)
    local nFinishCount = Achievement:GetFinishCount(szKind, nShowLevel)
    local bFinish = nCount >= nFinishCount
    local nCompletedLevel, nGainLevel = Achievement:GetGainData(szKind)
    local bCanGain = nGainLevel == nShowLevel - 1
    itemObj.pPanel:SetActive("ProgressBar", not bFinish)
    itemObj.pPanel:Label_SetText("Percentage", string.format("%d/%d", nCount, nFinishCount))
    itemObj.pPanel:Sprite_SetFillPercent("ProgressFore", nCount / nFinishCount)
    itemObj.pPanel:SetActive("Completed", bFinish and not bCanGain)
    itemObj.pPanel:SetActive("BtnGain", bFinish and bCanGain)
    local szTitle, szDesc = Achievement:GetTitleAndDesc(szKind, nShowLevel)
    itemObj.pPanel:Label_SetText("Achievement", szTitle)
    itemObj.pPanel:Label_SetText("Condition", szDesc)
    local nMaxLevel = Achievement:GetMaxLevel(szKind)
    fnSetStar(itemObj.pPanel, nCompletedLevel, nMaxLevel)
    fnSetAward(itemObj, szKind, nShowLevel)
    function itemObj.BtnGain.pPanel.OnTouchEvent()
      RemoteServer.TryGainAchievementAward(szKind, nShowLevel)
    end
  end
  self.ScrollView:Update(#tbList, fnSet)
end
ListPanel.tbOnClick = {
  BtnClose = function(self)
    Ui:CloseWindow(self.UI_NAME)
  end
}
