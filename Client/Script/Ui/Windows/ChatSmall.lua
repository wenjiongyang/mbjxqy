local tbUi = Ui:CreateClass("ChatSmall")
tbUi.nMsgSizeHeight = 0
tbUi.nMsgCount = 0
local MAX_ROW = 6
function tbUi:OnOpenEnd()
  self.bButtonsShow = true
  self.pPanel:SetActive("BtnChatTeamVoice", TeamMgr:HasTeam())
  self.pPanel:SetActive("BtnChatKinVoice", Kin:HasKin())
  self.pPanel:SetActive("ColorMsgground", false)
  self.pPanel:SetActive("Lantern", false)
  self.pPanel:SetActive("NewYear", false)
  self:UpdateChatMsg()
  self:UpdateColorMsg()
  self:UpdatePriveMsgNum()
  self:UpdateProcessMsgNum()
  self.pPanel:SetActive("RedPaper", false)
  if self.bSmall == nil then
    self.tbOnClick.BtnChatStretch(self)
  end
  local fnKinCallback = function(szMsg, uFileIdHigh, uFileIdLow, strFilePath, nVoiceTime, szApolloVoiceId)
    szMsg = ChatMgr:CutMsg(szMsg)
    ChatMgr:SendMsg(ChatMgr.ChannelType.Kin, szMsg, true, uFileIdHigh, uFileIdLow, strFilePath, nVoiceTime, szApolloVoiceId)
  end
  local fnCheckKin = function()
    return ChatMgr:CheckSendMsg(ChatMgr.ChannelType.Kin, "check", true)
  end
  local nVoiceTime = ChatMgr:GetMaxVoiceTime(ChatMgr.ChannelType.Kin)
  self.pPanel:FlyCom_Init("BtnChatKinVoice", fnKinCallback, fnCheckKin, nVoiceTime)
  local fnTeamCallback = function(szMsg, uFileIdHigh, uFileIdLow, strFilePath, nVoiceTime, szApolloVoiceId)
    szMsg = ChatMgr:CutMsg(szMsg)
    ChatMgr:SendMsg(ChatMgr.ChannelType.Team, szMsg, true, uFileIdHigh, uFileIdLow, strFilePath, nVoiceTime, szApolloVoiceId)
  end
  local fnCheckTeam = function()
    return ChatMgr:CheckSendMsg(ChatMgr.ChannelType.Team, "check", true)
  end
  local nVoiceTime = ChatMgr:GetMaxVoiceTime(ChatMgr.ChannelType.Team)
  self.pPanel:FlyCom_Init("BtnChatTeamVoice", fnTeamCallback, fnCheckTeam, nVoiceTime)
  if Ui:WindowVisible("BossPanel") and not Ui:IsAutoHide() then
    self:WndOpened("BossPanel")
  else
    self:WndClosed("BossPanel")
  end
end
function tbUi:UpdateChatMsg()
  local tbItems = ChatMgr:GetChatSmallMsg()
  self.nMsgCount = #tbItems
  local tbHeight = {}
  self.nMsgSizeHeight = 0
  local function fnSetItem(itemObj, nIndex)
    local tbMsgData = tbItems[nIndex]
    if not tbMsgData.szSenderName then
      return
    end
    local tbLinkInfo = tbMsgData.tbLinkInfo
    local szCurMsg = ChatMgr:DealMsgWithLinkColor(tbMsgData.szMsg, tbLinkInfo)
    local szMsg
    if tbMsgData.szSenderName == "" then
      szMsg = string.format("%s[%s]%s%s[-]", ChatMgr:GetChannelEmotion(tbMsgData.nChannelType, tbMsgData.nSenderId), ChatMgr:GetChannelColor(tbMsgData.nChannelType, tbMsgData.nSenderId), ChatMgr:IsValidVoiceFileId(tbMsgData.uFileIdHigh, tbMsgData.uFileIdLow, tbMsgData.szApolloVoiceId) and "#107" or "", szCurMsg)
    else
      szMsg = string.format("%s%s%s: [%s]%s%s[-]", ChatMgr:GetChannelEmotion(tbMsgData.nChannelType, tbMsgData.nSenderId), ChatMgr:GetNamePrefix(tbMsgData.nNamePrefix, true, tbMsgData.nChannelType, tbMsgData.nFaction, tbMsgData.nSenderId), tbMsgData.szSenderName, ChatMgr:GetChannelColor(tbMsgData.nChannelType, tbMsgData.nSenderId), ChatMgr:IsValidVoiceFileId(tbMsgData.uFileIdHigh, tbMsgData.uFileIdLow, tbMsgData.szApolloVoiceId) and "#107" or "", szCurMsg)
    end
    if not (tbLinkInfo and tbLinkInfo.nLinkType) or not ChatMgr.tbLinkClickFns[tbLinkInfo.nLinkType] then
      itemObj.Msg.pPanel.OnTouchEvent = nil
    else
      function itemObj.Msg.pPanel.OnTouchEvent(msgObj, nClickId)
        if tbLinkInfo.nLinkType and ChatMgr.tbLinkClickFns[tbLinkInfo.nLinkType] then
          ChatMgr.tbLinkClickFns[tbLinkInfo.nLinkType](tbLinkInfo)
        end
      end
    end
    itemObj.pPanel:Label_SetText("Msg", szMsg)
    local tbSize = itemObj.pPanel:Widget_GetSize("Msg")
    self.nMsgSizeHeight = self.nMsgSizeHeight + tbSize.y
    itemObj.pPanel:ChangePosition("Msg", -183, tbSize.y / 2)
    itemObj.pPanel:Widget_SetSize("Main", tbSize.x, tbSize.y)
    if not tbHeight[nIndex] then
      tbHeight[nIndex] = tbSize.y
      self.MsgScrollView:UpdateItemHeight(tbHeight)
    end
  end
  self.MsgScrollView:Update(tbItems, fnSetItem)
  self:UpdateMsgContainer()
  self.MsgScrollView:GoBottom()
end
function tbUi:UpdatePriveMsgNum(dwSender)
  local nMailNum = Mail:GetUnreadMailCount()
  local szShowTag
  if nMailNum > 0 then
    szShowTag = "NewMail"
  else
    local nPrivateNum = ChatMgr:GetUnReadPrivateMsgNum()
    if nPrivateNum > 0 then
      szShowTag = "NewWhisper"
    end
  end
  if dwSender then
    Ui.SoundManager.PlayUISound(8011)
  end
  if szShowTag then
    self.pPanel:SetActive("BtnNewMsg", true)
    self.pPanel:SetActive("NewMail", "NewMail" == szShowTag)
    self.pPanel:SetActive("NewWhisper", "NewWhisper" == szShowTag)
  else
    self.pPanel:SetActive("BtnNewMsg", false)
  end
end
local tbMultis = {
  2,
  3,
  6
}
function tbUi:NewRedBag(szId, nMulti)
  Ui:SetRedPointNotify("KinRedBagNotify")
  self.szRedBagId = szId
  local bGlobal = Kin:RedBagIsIdGlobal(self.szRedBagId)
  self.pPanel:Texture_SetTexture("RedPaper", bGlobal and "UI/Textures/RedPaper6.png" or "UI/Textures/RedPaper2.png")
  self.pPanel:SetActive("RedPaper", true)
  self.pPanel:SetActive("effect", true)
  for i = 1, 3 do
    self.pPanel:SetActive("texiao" .. i, tbMultis[i] == nMulti)
  end
end
function tbUi:UpdateProcessMsgNum()
  if #Ui.tbNotifyMsgDatas <= 0 then
    self.pPanel:SetActive("BtnActivityMsg", false)
    return
  end
  local szSprite = Ui:GetNotifyMsgIcon()
  if szSprite then
    self.pPanel:Button_SetSprite("BtnActivityMsg", szSprite, 1)
  end
  self.pPanel:SetActive("BtnActivityMsg", true)
  self.pPanel:PlayUiAnimation("NewMsg", false, true, {})
  local nUnReadNum = Ui.nUnReadNotifyMsgNum
  if nUnReadNum > 0 then
    self.pPanel:SetActive("NewMsg", true)
    self.pPanel:Label_SetText("NewMsgNum", nUnReadNum)
  else
    self.pPanel:SetActive("NewMsg", false)
  end
end
function tbUi:UpdateColorMsg()
  local tbColorMsg = ChatMgr:GetColorMsg()
  if tbColorMsg.szMsg then
    local szMsg = string.format("       「%s」:%s %s", tbColorMsg.szSenderName, ChatMgr:IsValidVoiceFileId(tbColorMsg.uFileIdHigh, tbColorMsg.uFileIdLow) and "#107" or "", tbColorMsg.szMsg)
    self.pPanel:Label_SetText("ColorMsgText", szMsg)
    self.pPanel:SetActive("ColorIcon", true)
    self.pPanel:SetActive("ColorMsgground", false)
    self.pPanel:SetActive("ColorMsgground", true)
  else
    self.pPanel:Label_SetText("ColorMsgText", "")
    self.pPanel:SetActive("ColorMsgground", false)
    self.pPanel:SetActive("ColorIcon", false)
  end
end
function tbUi:UpdateTeamButton(szType)
  if szType == "new" then
    self.pPanel:SetActive("BtnChatTeamVoice", true)
  elseif szType == "quite" then
    self.pPanel:SetActive("BtnChatTeamVoice", false)
  end
end
tbUi.tbOnClick = tbUi.tbOnClick or {}
function tbUi.tbOnClick:BtnChatLarge()
  Ui:SwitchWindow("ChatLargePanel")
end
function tbUi.tbOnClick:BtnChatSetting()
  Ui:OpenWindow("ChatSetting")
end
function tbUi.tbOnClick:BtnActivityMsg()
  Ui:OpenWindow("NotifyMsgList")
end
function tbUi.tbOnClick:RedPaper()
  self.pPanel:SetActive("RedPaper", false)
  if self.szRedBagId then
    Ui:OpenWindow("RedBagDetailPanel", "viewgrab", self.szRedBagId, true)
  end
  Kin:RedBagUpdateRedPoint(false)
end
local nExtra = 1
function tbUi:UpdateMsgContainer()
  local nMsgScrollViewY = self.bSmall and 72 + nExtra or 0 + nExtra
  if self.nMsgCount < MAX_ROW and self.nMsgSizeHeight <= 140 then
    if self.bSmall then
      if 72 >= self.nMsgSizeHeight then
        nMsgScrollViewY = -4
      elseif self.nMsgSizeHeight <= 96 then
        nMsgScrollViewY = 20
      elseif self.nMsgSizeHeight <= 120 then
        nMsgScrollViewY = 44
      elseif self.nMsgSizeHeight <= 140 then
        nMsgScrollViewY = 68
      end
    elseif self.nMsgSizeHeight <= 140 then
      nMsgScrollViewY = -4
    end
  end
  self.pPanel:ChangePosition("UpContainer", 0, self.bSmall and -72 + nExtra or 0 + nExtra)
  self.pPanel:ChangePosition("MsgScrollView", 0, nMsgScrollViewY)
  self.pPanel:ChangePanelOffset("MsgScrollView", 0, -4)
end
function tbUi.tbOnClick:BtnChatStretch()
  self.bSmall = not self.bSmall
  self.pPanel:ChangeRotate("BtnChatStretch", self.bSmall and 0 or 180)
  self:UpdateChatMsg()
end
function tbUi.tbOnClick:BtnNewMsg()
  if self.pPanel:IsActive("NewMail") then
    Ui:OpenWindow("ChatLargePanel", ChatMgr.nChannelMail)
  elseif self.pPanel:IsActive("NewWhisper") then
    Ui:OpenWindow("ChatLargePanel", ChatMgr.ChannelType.Private)
  end
end
function tbUi:WndOpened(szUiName)
  if szUiName == "BossPanel" and not Ui:IsAutoHide() then
    Ui.UiManager.ChangeUiLayer("ChatSmall", Ui.LAYER_NORMAL)
    self.pPanel:ChangePosition("PosCtrl", -310, 0)
  end
end
function tbUi:WndClosed(szUiName)
  if szUiName == "BossPanel" then
    Ui.UiManager.ChangeUiLayer("ChatSmall", Ui.LAYER_HOME)
    self.pPanel:ChangePosition("PosCtrl", 0, 0)
  end
end
function tbUi:UpdateKinButton()
  self.pPanel:SetActive("BtnChatKinVoice", Kin:HasKin())
end
function tbUi:ChangeFightState(bFight)
  if bFight then
    self.pPanel:ChangePosition("PosCtrl", 0, 0)
  elseif Ui:WindowVisible("BossPanel") then
    self.pPanel:ChangePosition("PosCtrl", -310, 0)
  end
end
function tbUi:OnTouchReturn()
  if Ui:WindowVisible("BossPanel") then
    Ui:CloseWindow("BossPanel")
  end
end
function tbUi:OnGetSendBless(dwRoleId, bGold)
  if not dwRoleId then
    return
  end
  local tbActSetting = SendBless:GetActSetting()
  local szImg = tbActSetting.szNotifyUi
  if tbActSetting.szGoldSprite then
    if bGold then
      self.pPanel:Sprite_SetSprite(szImg, tbActSetting.szGoldSprite)
      self.pPanel:SetActive("texiao_F", true)
      self.pPanel:SetActive("texiao_J", false)
    else
      self.pPanel:Sprite_SetSprite(szImg, tbActSetting.szNormalSprite)
      self.pPanel:SetActive("texiao_F", false)
      self.pPanel:SetActive("texiao_J", true)
    end
  end
  self.pPanel:SetActive(szImg, true)
  if self.nTimrGetSendBless then
    Timer:Close(self.nTimrGetSendBless)
  end
  self.nTimrGetSendBless = Timer:Register(Env.GAME_FPS * 3, function(...)
    self.pPanel:SetActive(szImg, false)
    self.nTimrGetSendBless = nil
  end)
end
function tbUi:OnClose()
  if self.pPanel:IsActive("BtnChatTeamVoice") then
    local wndTeamVoice = self.pPanel:FindChildTransform("BtnChatTeamVoice")
    if wndTeamVoice then
      local iflyCom = wndTeamVoice:GetComponent("IFlyCom")
      if iflyCom then
        iflyCom:SendMessage("OnPress", false)
      end
    end
  end
  if self.pPanel:IsActive("BtnChatKinVoice") then
    local wndKinVoice = self.pPanel:FindChildTransform("BtnChatKinVoice")
    if wndKinVoice then
      local iflyCom = wndKinVoice:GetComponent("IFlyCom")
      if iflyCom then
        iflyCom:SendMessage("OnPress", false)
      end
    end
  end
end
function tbUi:RegisterEvent()
  local tbRegEvent = {
    {
      UiNotify.emNOTIFY_CHAT_NEW_MSG,
      self.UpdateChatMsg
    },
    {
      UiNotify.emNOTIFY_SYNC_KIN_DATA,
      self.UpdateKinButton
    },
    {
      UiNotify.emNoTIFY_NEW_PRIVATE_MSG,
      self.UpdatePriveMsgNum
    },
    {
      UiNotify.emNOTIFY_PRIVATE_MSG_NUM_CHANGE,
      self.UpdatePriveMsgNum
    },
    {
      UiNotify.emNOTIFY_CHAT_COLOR_MSG,
      self.UpdateColorMsg
    },
    {
      UiNotify.emNOTIFY_TEAM_UPDATE,
      self.UpdateTeamButton
    },
    {
      UiNotify.emNOTIFY_IFLY_IAT_RESULT,
      self.UpdateTeamButton
    },
    {
      UiNotify.emNOTIFY_NOTIFY_NEW_MAIL,
      self.UpdatePriveMsgNum
    },
    {
      UiNotify.emNOTIFY_WND_OPENED,
      self.WndOpened
    },
    {
      UiNotify.emNOTIFY_WND_CLOSED,
      self.WndClosed
    },
    {
      UiNotify.emNOTIFY_UI_AUTO_HIDE,
      self.ChangeFightState
    },
    {
      UiNotify.emNOTIFY_NOTIFY_PROCESS_MSG,
      self.UpdateProcessMsgNum
    },
    {
      UiNotify.emNOTIFY_NEW_REDBAG,
      self.NewRedBag
    },
    {
      UiNotify.emNOTIFY_SEND_BLESS_CHANGE,
      self.OnGetSendBless
    }
  }
  return tbRegEvent
end
