local ChannelColor = {
  [ChatMgr.ChannelType.Public] = "44ee76",
  [ChatMgr.ChannelType.Nearby] = "ffffff",
  [ChatMgr.ChannelType.Color] = "00ffea",
  [ChatMgr.ChannelType.Map] = "ffaa00",
  [ChatMgr.ChannelType.Team] = "ff8adf",
  [ChatMgr.ChannelType.Kin] = "68cff5",
  [ChatMgr.nChannelFriendName] = "db25ff",
  [ChatMgr.ChannelType.System] = "f56161",
  [ChatMgr.ChannelType.Friend] = "ffbbcc",
  SystemMsgTip = "eacc00"
}
ChatMgr.tbVoiceError = {
  XT("请在手机设置中打开麦克风权限"),
  XT("没有说话或请检查是否开启录音权限"),
  XT("操作过快，请稍候再试")
}
ChatMgr.tbNewMsgChannel = ChatMgr.tbNewMsgChannel or {}
ChatMgr.tbChatEmotionMap = {}
ChatMgr.PrivateChatUnReadCache = ChatMgr.PrivateChatUnReadCache or {}
ChatMgr.PrivateChatReadCache = ChatMgr.PrivateChatReadCache or {}
ChatMgr.MAX_PRIVATE_LIST_NUM = 20
ChatMgr.MAX_PRIVATE_MSG_NUM = 50
ChatMgr.RecentPrivateList = ChatMgr.RecentPrivateList or {}
ChatMgr.VOICE_REQUEST_TIME_OUT = 10
ChatMgr.VoiceInfo = ChatMgr.VoiceInfo or {}
ChatMgr.VoiceInfo.autoQueue = ChatMgr.VoiceInfo.autoQueue or {}
ChatMgr.tbDynamicChannel = ChatMgr.tbDynamicChannel or {}
ChatMgr.ChatRoom = ChatMgr.ChatRoom or {}
local ChatRoomMgr = luanet.import_type("ChatRoomMgr")
ChatMgr.bApolloVoice = false
ChatMgr.bApolloVoiceInit = false
ChatMgr.ApolloVoiceErr = {
  APOLLO_VOICE_SUCC = 0,
  APOLLO_VOICE_NONE = 1,
  APOLLO_VOICE_UNKNOWN = 3,
  APOLLO_VOICE_STATE_ERR = 4,
  APOLLO_VOICE_JOIN_TIMEOUT = 50,
  APOLLO_VOICE_JOIN_SUCC = 51
}
ChatMgr.ApolloVoiceMode = {
  REALTIME_VOICE = 0,
  OFFLINE_VOICE = 1,
  STT_VOICE = 2
}
ChatMgr.tbLinkClickFns = {
  [ChatMgr.LinkType.Position] = function(tbLinkInfo)
    local tbParam = tbLinkInfo.linkParam
    if tbParam then
      local nMapId, nX, nY, nMapTemplateId = unpack(tbParam)
      AutoPath:GotoAndCall(nMapId, nX, nY, nil, nil, nMapTemplateId)
      return
    end
    if not tbLinkInfo.nMapId then
      return
    end
    AutoPath:GotoAndCall(tbLinkInfo.nMapId, tbLinkInfo.nX, tbLinkInfo.nY, nil, nil, tbLinkInfo.nMapTemplateId)
  end,
  [ChatMgr.LinkType.Partner] = function(tbLinkInfo)
    if tbLinkInfo.linkParam then
      local nPartnerId = tbLinkInfo.linkParam
      local tbSkillInfo, pPartner = Partner:GetPartnerAllSkillInfo(me, nPartnerId)
      Ui:OpenWindow("PartnerDetail", me.GetPartnerInfo(nPartnerId), pPartner.GetAttribInfo(), tbSkillInfo)
      return
    end
    Ui:OpenWindow("PartnerDetail", tbLinkInfo.tbPartnerInfo, tbLinkInfo.tbPartnerAttribInfo, tbLinkInfo.tbPartnnerSkillInfo)
  end,
  [ChatMgr.LinkType.Item] = function(tbLinkInfo)
    local tbInfo = {
      nTemplate = tbLinkInfo.nTemplateId,
      nFaction = tbLinkInfo.nFaction,
      tbRandomAtrrib = tbLinkInfo.tbRandomAtrrib
    }
    if type(tbLinkInfo.linkParam) == "number" then
      tbInfo.nItemId = tbLinkInfo.linkParam
    elseif type(tbLinkInfo.linkParam) == "table" then
      tbInfo.nItemId = tbLinkInfo.linkParam[1]
      tbInfo.nTemplate = tbLinkInfo.linkParam[2]
      tbInfo.nFaction = me.nFaction
    end
    Item:ShowItemDetail(tbInfo)
  end,
  [ChatMgr.LinkType.Team] = function(tbLinkInfo)
    TeamMgr:ApplyActivityTeam(tbLinkInfo.nActivityId, tbLinkInfo.nTeamId)
  end,
  [ChatMgr.LinkType.Achievement] = function(tbLinkInfo)
    local szName, nId, nLevel
    if tbLinkInfo.linkParam then
      nId = math.floor(tbLinkInfo.linkParam / 100)
      nLevel = tbLinkInfo.linkParam - nId * 100
      szName = me.szName
    elseif tbLinkInfo.szKind then
      nId = Achievement:GetGroupKey(tbLinkInfo.szKind)
      nLevel = tbLinkInfo.nLevel
      szName = tbLinkInfo.szComName
    else
      local nAchievement = tbLinkInfo.dwAchievement
      nId = math.floor(nAchievement / 100)
      nLevel = math.floor(nAchievement % 100)
      szName = tbLinkInfo.szName or ""
    end
    Ui:OpenWindow("ChatAchievementPopup", nId, nLevel, szName)
  end,
  [ChatMgr.LinkType.KinDrink] = function()
    Kin:GatherDrink()
  end,
  [ChatMgr.LinkType.KinQuestion] = function(tbLinkInfo)
    local tbQuestion = tbLinkInfo.tbQuestionData
    if not tbQuestion then
      return
    end
    Ui:OpenWindow("KinAnswerPanel", tbQuestion)
  end,
  [ChatMgr.LinkType.Commerce] = function(tbLinkInfo)
    if not tbLinkInfo.dwPlayerID then
      return
    end
    local dwPlayerID = tbLinkInfo.dwPlayerID
    if dwPlayerID == me.dwID then
      Ui:OpenWindow("CommerceTaskPanel")
    else
      Ui:OpenWindow("CommerceHelpPanel", dwPlayerID)
    end
  end,
  [ChatMgr.LinkType.KinRedBag] = function(tbLinkInfo)
    local szId = tbLinkInfo.szId
    if not szId then
      return
    end
    Ui:OpenWindow("RedBagDetailPanel", "viewgrab", szId)
  end,
  [ChatMgr.LinkType.OpenUrl] = function(tbLinkInfo)
    if not tbLinkInfo.szUrl then
      return
    end
    local szUrl = tbLinkInfo.szUrl
    szUrl = string.gsub(szUrl, "%$PlayerId%$", me.dwID or 0)
    szUrl = string.gsub(szUrl, "%$SeverId%$", Sdk:GetServerId() or 0)
    szUrl = string.gsub(szUrl, "%$ArenaId%$", Sdk:GetAreaId() or 0)
    Sdk:OpenUrl(szUrl)
  end,
  [ChatMgr.LinkType.OpenWnd] = function(tbLinkInfo)
    local tbParams = tbLinkInfo.tbParams
    if not next(tbParams or {}) then
      return
    end
    Ui:OpenWindow(tbParams[1], unpack(tbParams, 2))
  end,
  [ChatMgr.LinkType.HyperText] = function(tbLinkInfo)
    if tbLinkInfo.linkParam and tbLinkInfo.linkParam.szHyperText then
      Ui.HyperTextHandle:Handle(tbLinkInfo.linkParam.szHyperText)
    end
  end,
  [ChatMgr.LinkType.OpenUrlLunTanJiuLou] = function(tbLinkInfo)
    local tbWebView = WebView:GetClass("LunTan")
    tbWebView:OpenUrlLunTan(tbLinkInfo.szParam)
  end
}
local tbLinkColor = {
  [ChatMgr.LinkType.None] = "68cff5",
  [ChatMgr.LinkType.Item] = "000000",
  [ChatMgr.LinkType.Position] = "47f005",
  [ChatMgr.LinkType.Partner] = "000000",
  [ChatMgr.LinkType.Team] = "47f005",
  [ChatMgr.LinkType.Achievement] = "ffaa00",
  [ChatMgr.LinkType.KinDrink] = "47f005",
  [ChatMgr.LinkType.KinQuestion] = "47f005",
  [ChatMgr.LinkType.Commerce] = "47f005",
  [ChatMgr.LinkType.KinRedBag] = "47f005",
  [ChatMgr.LinkType.OpenUrl] = "1717ff",
  [ChatMgr.LinkType.OpenWnd] = "47f005",
  [ChatMgr.LinkType.HyperText] = "47f005"
}
function ChatMgr:DealMsgWithLinkColor(szMsg, tbLinkInfo)
  if not tbLinkInfo or tbLinkInfo.nLinkType == ChatMgr.LinkType.None then
    return szMsg
  end
  local szLinkColor = tbLinkColor[tbLinkInfo.nLinkType]
  if tbLinkInfo.nLinkType == ChatMgr.LinkType.Item then
    local nItemId = 0
    local nTemplateId = tbLinkInfo.nTemplateId
    local nQuality
    if type(tbLinkInfo.linkParam) == "number" then
      nItemId = tbLinkInfo.linkParam
    elseif type(tbLinkInfo.linkParam) == "table" then
      nItemId = tbLinkInfo.linkParam[1]
      nTemplateId = tbLinkInfo.linkParam[2]
    end
    local pItem = KItem.GetItemObj(nItemId)
    if pItem then
      nQuality = pItem.nQuality
    elseif tbLinkInfo.bIsEquip then
      local tbInfo = KItem.GetItemBaseProp(nTemplateId) or {}
      if tbInfo.szClass == "equip" then
        local tbClass = Item:GetClass("equip")
        local _, nMaxQuality = tbClass:GetTipByTemplate(nTemplateId, tbLinkInfo.tbRandomAtrrib)
        nQuality = nMaxQuality
      else
        nQuality = tbInfo.nQuality
      end
    elseif nTemplateId then
      local tbInfo = KItem.GetItemBaseProp(nTemplateId) or {}
      nQuality = tbInfo.nQuality
    end
    local _, _, _, _, szColor = Item:GetQualityColor(nQuality or 1)
    szLinkColor = szColor
  elseif tbLinkInfo.nLinkType == ChatMgr.LinkType.Partner then
    local tbPartnerInfo = tbLinkInfo.tbPartnerInfo or {}
    if tbLinkInfo.linkParam then
      tbPartnerInfo = me.GetPartnerInfo(tbLinkInfo.linkParam) or {}
    end
    local _, nStarLevel = Partner:GetStarValue(tbPartnerInfo.nFightPower or 1)
    szLinkColor = Partner.tbFightPowerToTxtColor[nStarLevel] or "848484"
  end
  local szLinkFormat = szLinkColor and string.format("[%s]%%1[-]%%2", szLinkColor)
  return szLinkFormat and string.gsub(szMsg, "(%<.+%>)(.*)", szLinkFormat) or szMsg
end
function ChatMgr:Init()
  local szChannelSettingPath = "Setting/Chat/ChannelSetting.tab"
  ChatMgr.tbChannelSetting = LoadTabFile(szChannelSettingPath, "dsddds", "nType", {
    "nType",
    "szName",
    "nCharge",
    "nCd",
    "nLevel",
    "szChannelName"
  })
  ChatMgr.tbChatEmotionList = LoadTabFile("Setting/Chat/ChatEmotionArray.tab", "d", nil, {"EmotionId"})
  local tbEmotionAtlas = LoadTabFile("Setting/EmotionSetting.tab", "ds", "EmotionId", {"EmotionId", "Atlas"})
  for _, tbInfo in ipairs(ChatMgr.tbChatEmotionList) do
    tbInfo.Atlas = tbEmotionAtlas[tbInfo.EmotionId].Atlas
    ChatMgr.tbChatEmotionMap[tbInfo.EmotionId] = true
  end
  self.ChatDataCache = self.ChatDataCache or {}
end
ChatMgr:Init()
function ChatMgr:ClearCache()
  self.ChatDataCache = {}
end
function ChatMgr:InitPrivateList()
  self.RecentPrivateList = {}
  self.PrivateChatUnReadCache = {}
  self.PrivateChatReadCache = {}
  local tbSaveData = Client:GetPrivateMsgData()
  local tbData = tbSaveData.tbData
  if not tbData then
    return
  end
  for i, v in ipairs(tbData) do
    table.insert(self.RecentPrivateList, v[1])
    self.PrivateChatUnReadCache[v[1].dwID] = v[2]
    self.PrivateChatReadCache[v[1].dwID] = v[3]
  end
  self.nInitPrivateList = 0
end
function ChatMgr:CheckUpdateStrangerState()
  local nNow = GetTime()
  if not self.nInitPrivateList or nNow - self.nInitPrivateList < 3600 then
    return
  end
  local tbCheckRoleIDs = {}
  for i, v in ipairs(self.RecentPrivateList) do
    local tbData = FriendShip:GetFriendDataInfo(v.dwID)
    if not tbData then
      table.insert(tbCheckRoleIDs, v.dwID)
    end
  end
  if next(tbCheckRoleIDs) then
    RemoteServer.RequestChatRoleBaseInfo(tbCheckRoleIDs)
  end
  self.nInitPrivateList = nNow
end
function ChatMgr:SavePriveMsg()
  local tbSaveData = Client:GetPrivateMsgData()
  tbSaveData.tbData = nil
  local tbSavePrivateMsgs = {}
  local PrivateChatUnReadCache = self.PrivateChatUnReadCache
  local PrivateChatReadCache = self.PrivateChatReadCache
  for i, v in ipairs(self.RecentPrivateList) do
    local tbUnRead = PrivateChatUnReadCache[v.dwID] or {}
    local tbReaded = PrivateChatReadCache[v.dwID] or {}
    local nToTal = #tbUnRead + #tbReaded
    local nNeedDel = nToTal - self.MAX_PRIVATE_MSG_NUM
    if nNeedDel > 0 then
      for i2 = 1, #tbReaded do
        table.remove(tbReaded, 1)
        nNeedDel = nNeedDel - 1
        if nNeedDel == 0 then
          break
        end
      end
      if nNeedDel > 0 then
        for i2 = 1, #tbUnRead do
          table.remove(tbUnRead, 1)
          nNeedDel = nNeedDel - 1
          if nNeedDel == 0 then
            break
          end
        end
      end
    end
    table.insert(tbSavePrivateMsgs, {
      v,
      tbUnRead,
      tbReaded
    })
  end
  tbSaveData.tbData = tbSavePrivateMsgs
  Client:SavePrivateMsgData()
end
function ChatMgr:CheckSavePrivateMsg()
  if self.nTimerSavePrivate then
    return
  end
  self.nTimerSavePrivate = Timer:Register(Env.GAME_FPS * 60, function()
    ChatMgr:SavePriveMsg()
    self.nTimerSavePrivate = nil
  end)
end
function ChatMgr:IsValidVoiceMsg(nChannelType, uFileIdHigh, uFileIdLow, strFilePath, szApolloVoiceId)
  if szApolloVoiceId and szApolloVoiceId ~= "" then
    return true
  end
  if uFileIdHigh and uFileIdHigh > 0 and uFileIdLow and uFileIdLow > 0 and strFilePath and strFilePath ~= "" and Lib:IsFileExsit(strFilePath) then
    return true
  end
  return false
end
function ChatMgr:Filter4CharString(szMsg)
  local tbWords = Lib:GetUft8Chars(szMsg)
  local tbValidWords = {}
  for _, c in pairs(tbWords) do
    if string.len(c) <= 3 then
      table.insert(tbValidWords, c)
    end
  end
  return table.concat(tbValidWords)
end
function ChatMgr:SendMsg(nChannelType, szMsg, bVoice, uFileIdHigh, uFileIdLow, strFilePath, nVoiceTime, szApolloVoiceId)
  if not ChatMgr:CheckSendMsg(nChannelType, szMsg, false, uFileIdHigh, uFileIdLow, strFilePath, nVoiceTime, szApolloVoiceId) then
    return false
  end
  szMsg = ChatMgr:Filter4CharString(szMsg)
  local tbChatLink = self.tbChatLink or {}
  local nLinkType = tbChatLink.nLinkType
  local linkParam = tbChatLink.linkParam
  self.tbChatLink = nil
  if not ChatMgr:CheckLinkAvailable(szMsg, nLinkType, linkParam) then
    nLinkType = 0
    linkParam = 0
  end
  if ChatMgr:CheckVoiceSendEnable() and ChatMgr:IsValidVoiceMsg(nChannelType, uFileIdHigh, uFileIdLow, strFilePath, szApolloVoiceId) then
    if szApolloVoiceId then
      SendChannelMessageWithApolloVoice(nChannelType, szMsg, nLinkType, linkParam, szApolloVoiceId, nVoiceTime)
    else
      local voiceData, dataLen = Lib:ReadFileBinary(strFilePath)
      if voiceData and dataLen > 0 then
        FileServer:SendVoiceFile(uFileIdHigh, uFileIdLow, voiceData, function(bRet)
          if bRet then
            SendChannelMessage(nChannelType, szMsg, nLinkType, linkParam, uFileIdHigh, uFileIdLow, nVoiceTime)
          else
            SendChannelMessage(nChannelType, szMsg, nLinkType, linkParam)
          end
        end, ChatMgr:IsNeedZoneFileServer(nChannelType))
      end
    end
  else
    SendChannelMessage(nChannelType, szMsg, nLinkType, linkParam)
  end
  ChatMgr:DealAchievement(nChannelType, szMsg, bVoice)
  ChatMgr:InsertRecentSendMsg(szMsg)
  return true
end
function ChatMgr:DealAchievement(nChannelId, szMsg, bVoice)
  if bVoice then
    Achievement:AddCount("Chat_Voice")
  end
  if string.find(szMsg, "#%d") then
    Achievement:AddCount("Chat_Emotion")
  end
  if nChannelId == ChatMgr.ChannelType.Public then
    Achievement:AddCount("Chat_Public")
  end
  if nChannelId == ChatMgr.ChannelType.Color then
    Achievement:AddCount("Chat_Color")
  end
end
function ChatMgr:InsertRecentSendMsg(szMsg)
  if not szMsg and string.len(szMsg) <= 1 then
    return
  end
  local tbRecentMsg = Client:GetUserInfo("ChatMsgHistory")
  for nIdx, szOldMsg in ipairs(tbRecentMsg) do
    if szOldMsg == szMsg then
      table.remove(tbRecentMsg, nIdx)
      break
    end
  end
  table.insert(tbRecentMsg, 1, szMsg)
  if #tbRecentMsg > ChatMgr.nMaxMsgHistoryCount then
    table.remove(tbRecentMsg)
  end
  Client:SaveUserInfo()
end
function ChatMgr:GetRecentMsgs()
  return Client:GetUserInfo("ChatMsgHistory")
end
function ChatMgr:SetChatLink(nLinkType, linkParam)
  self.tbChatLink = self.tbChatLink or {}
  self.tbChatLink = {nLinkType = nLinkType, linkParam = linkParam}
end
function ChatMgr:GetChannelEmotion(nChannelType, nSenderId)
  local tbChannelCfg = ChatMgr.tbDynamicChannel[nChannelType]
  if tbChannelCfg then
    return tbChannelCfg.szIcon or ""
  end
  if nChannelType == ChatMgr.ChannelType.System then
    local nRealChannel = ChatMgr.SystemTypeChannel[nSenderId]
    if nRealChannel ~= ChatMgr.ChannelType.System then
      return ChatMgr.ChannelEmotion[nRealChannel] or ""
    end
    if nSenderId == ChatMgr.SystemMsgType.Tip then
      return ChatMgr.ChannelEmotion.SystemMsgTip
    end
  end
  return ChatMgr.ChannelEmotion[nChannelType] or ""
end
function ChatMgr:GetChannelColor(nChannelType, nSenderId)
  if nChannelType >= self.nDynChannelBegin then
    return self.DynamicColor
  end
  if nChannelType == ChatMgr.ChannelType.System then
    local nRealChannel = ChatMgr.SystemTypeChannel[nSenderId]
    if nRealChannel ~= ChatMgr.ChannelType.System then
      return ChannelColor[nRealChannel]
    end
    if nSenderId == ChatMgr.SystemMsgType.Tip then
      return ChannelColor.SystemMsgTip
    end
  end
  return ChannelColor[nChannelType]
end
function ChatMgr:GetChatSmallMsg()
  return ChatMgr:GetChannelChatData("chatSmall")
end
function ChatMgr:GetChannelChatData(nChannelType)
  if not self.ChatDataCache[nChannelType] then
    self.ChatDataCache[nChannelType] = {}
  end
  return self.ChatDataCache[nChannelType]
end
function ChatMgr:ParseLinkInfo(tbLinkInfo)
  if not tbLinkInfo or tbLinkInfo.nLinkType == ChatMgr.LinkType.None or not tbLinkInfo.nLinkParam then
    return tbLinkInfo
  end
  local tbResult = ParseLinkData(tbLinkInfo.nLinkType, tbLinkInfo.nLinkParam, tbLinkInfo.byData)
  if tbResult and tbResult.nLinkType == ChatMgr.LinkType.LuaPacker then
    tbResult = tbResult.tbData
  end
  return tbResult
end
function ChatMgr:OnSyncChatOfflineData(tbData)
  for nChannelType, tbChannelData in pairs(tbData) do
    self.ChatDataCache[nChannelType] = tbChannelData
    for nIdx, tbMsg in ipairs(tbChannelData) do
      tbMsg.tbLinkInfo = ChatMgr:ParseLinkInfo(tbMsg.tbLinkInfo)
      self:InsertTimeTips(tbChannelData, tbMsg, nIdx - 1)
    end
  end
  UiNotify.OnNotify(UiNotify.emNOTIFY_CHAT_NEW_MSG)
  if self.nColorUpdateTimer then
    Timer:Close(self.nColorUpdateTimer)
  end
  self.nColorUpdateTimer = Timer:Register(Env.GAME_FPS * ChatMgr.nColorMsgFreshTime, self.ColorUpdate, self)
  self:ColorUpdate()
end
function ChatMgr:ColorUpdate()
  local tbColorMsg = self:GetChannelChatData(ChatMgr.ChannelType.Color)
  local preColorMsg = self.tbCurColorMsg
  self.tbCurColorMsg = table.remove(tbColorMsg, 1)
  UiNotify.OnNotify(UiNotify.emNOTIFY_CHAT_COLOR_MSG)
  if not self.tbCurColorMsg and not preColorMsg then
    self.nColorUpdateTimer = nil
    return false
  end
  return true
end
function ChatMgr:GetColorMsg()
  return self.tbCurColorMsg or {}
end
function ChatMgr:InsertTimeTips(tbChatData, tbMsg, nIdx)
  if tbMsg.nChannelType ~= ChatMgr.ChannelType.Kin then
    return
  end
  local tbLastMsg = tbChatData[nIdx] or {}
  if tbLastMsg.nTime and tbMsg.nTime < tbLastMsg.nTime + 600 then
    return
  end
  table.insert(tbChatData, nIdx + 1, {
    nChannelType = ChatMgr.ChannelType.System,
    nSenderId = ChatMgr.SystemMsgType.TimeTips,
    szSenderName = "",
    nTime = tbMsg.nTime
  })
end
function ChatMgr:SpecialMsg(nChannelType, nSenderId, szSenderName, szMsg)
  if nChannelType == ChatMgr.ChannelType.System and nSenderId == ChatMgr.SystemMsgType.Boss then
    local tbBossChatData = ChatMgr:GetChannelChatData("Boss")
    table.insert(tbBossChatData, szMsg)
    if #tbBossChatData > 5 then
      table.remove(tbBossChatData, 1)
    end
    UiNotify.OnNotify(UiNotify.emNOTIFY_SYNC_BOSS_DATA, "BroadcastMsg")
    return true
  end
  return false
end
function ChatMgr:ClearColorFlag(szMsg)
  szMsg = string.gsub(szMsg or "", "(%[)", "%[ ")
  szMsg = string.gsub(szMsg or "", "(%])", " %]")
  return szMsg
end
local IsPlayerEmotion = function(nEmotionId)
  if ChatMgr.tbChatEmotionMap[nEmotionId] then
    return true
  end
  return ChatMgr.tbSpcialUserEmotion[nEmotionId]
end
function ChatMgr:FilterPlayerMsg(nChannelId, szMsg)
  if nChannelId == ChatMgr.ChannelType.System then
    return szMsg
  end
  szMsg = ChatMgr:ClearColorFlag(szMsg)
  local tbMsg = Lib:SplitStr(szMsg, "#")
  for nIth, szStr in ipairs(tbMsg) do
    local szEmoId = string.match(szStr, "^%d%d?%d?")
    if szEmoId and not IsPlayerEmotion(tonumber(szEmoId)) then
      tbMsg[nIth] = " " .. szStr
    end
  end
  szMsg = table.concat(tbMsg, "#")
  return szMsg
end
function ChatMgr:OnChannelApolloTrans(nChannelType, nSenderId, szSenderName, nFaction, nPortrait, nLevel, szMsg, uFileIdHigh, uFileIdLow, uVoiceTime, nNamePrefix, nHeadBg, nChatBg, tbLinkInfo, szApolloVoiceId)
  local nRealChannel = nChannelType
  if nChannelType == ChatMgr.ChannelType.System then
    nRealChannel = ChatMgr:GetSystemMsgChannel(nSenderId)
  end
  if nChannelType == ChatMgr.ChannelType.Color then
    nRealChannel = ChatMgr.ChannelType.Public
  end
  local tbChatData = self:GetChannelChatData(nRealChannel)
  if tbChatData then
    for _, tbMsg in pairs(tbChatData) do
      if tbMsg.szApolloVoiceId == szApolloVoiceId then
        tbMsg.szMsg = szMsg
        UiNotify.OnNotify(UiNotify.emNOTIFY_CHAT_NEW_MSG, nRealChannel)
        break
      end
    end
  end
end
function ChatMgr:OnChannelMessage(nChannelType, nSenderId, szSenderName, nFaction, nPortrait, nLevel, szMsg, uFileIdHigh, uFileIdLow, uVoiceTime, nNamePrefix, nHeadBg, nChatBg, tbLinkInfo, szApolloVoiceId)
  if ChatMgr:InBlackList(nChannelType, nSenderId) then
    return
  end
  if ChatMgr:SpecialMsg(nChannelType, nSenderId, szSenderName, szMsg) then
    return
  end
  if szApolloVoiceId and szApolloVoiceId ~= "" and szMsg and szMsg ~= "" then
    self:OnChannelApolloTrans(nChannelType, nSenderId, szSenderName, nFaction, nPortrait, nLevel, szMsg, uFileIdHigh, uFileIdLow, uVoiceTime, nNamePrefix, nHeadBg, nChatBg, tbLinkInfo, szApolloVoiceId)
    ChatMgr:DealChatBubbleTalk(nChannelType, nSenderId, szMsg)
    return
  end
  szMsg = ChatMgr:FilterPlayerMsg(nChannelType, szMsg) or szMsg
  nSenderId, szSenderName = ChatMgr:SpecialRule4Senders(nChannelType, nSenderId, szSenderName)
  if tbLinkInfo and tbLinkInfo.nLinkType == ChatMgr.LinkType.LuaPacker then
    tbLinkInfo = tbLinkInfo.tbData
  end
  local nNow = GetTime()
  local tbMsg = {}
  tbMsg.nChannelType = nChannelType
  tbMsg.nSenderId = nSenderId
  tbMsg.szSenderName = szSenderName
  tbMsg.nNamePrefix = nNamePrefix
  tbMsg.nHeadBg = nHeadBg
  tbMsg.nChatBg = nChatBg
  tbMsg.nPortrait = nPortrait
  tbMsg.nFaction = nFaction
  tbMsg.nLevel = nLevel
  tbMsg.szMsg = szMsg
  tbMsg.nTime = nNow
  tbMsg.tbLinkInfo = tbLinkInfo
  tbMsg.uFileIdHigh = uFileIdHigh
  tbMsg.uFileIdLow = uFileIdLow
  tbMsg.uVoiceTime = uVoiceTime
  tbMsg.szApolloVoiceId = szApolloVoiceId
  if szApolloVoiceId and szApolloVoiceId ~= "" then
    local fileIdHigh, fileIdLow = FileServer:CreateFileId()
    uFileIdHigh = fileIdHigh
    uFileIdLow = fileIdLow
    tbMsg.uFileIdHigh = fileIdHigh
    tbMsg.uFileIdLow = fileIdLow
  end
  local nRealChannel = nChannelType
  if nChannelType == ChatMgr.ChannelType.System then
    nRealChannel = ChatMgr:GetSystemMsgChannel(nSenderId)
  end
  if nChannelType == ChatMgr.ChannelType.Color then
    nRealChannel = ChatMgr.ChannelType.Public
    table.insert(self:GetChannelChatData(nChannelType), tbMsg)
  end
  local tbChatData = self:GetChannelChatData(nRealChannel)
  self:InsertTimeTips(tbChatData, tbMsg, #tbChatData)
  table.insert(tbChatData, tbMsg)
  if #tbChatData > ChatMgr.nMaxChannelMsgCount then
    table.remove(tbChatData, 1)
  end
  local tbChatSmallData = self:GetChannelChatData("chatSmall")
  if ChatMgr:CheckShowInSmall(nRealChannel) then
    table.insert(tbChatSmallData, tbMsg)
    if #tbChatSmallData > 6 then
      table.remove(tbChatSmallData, 1)
    end
  end
  if nChannelType == ChatMgr.ChannelType.Color and not self.nColorUpdateTimer then
    self.nColorUpdateTimer = Timer:Register(Env.GAME_FPS * ChatMgr.nColorMsgFreshTime, self.ColorUpdate, self)
    self:ColorUpdate()
  end
  if szMsg and szMsg ~= "" then
    ChatMgr:DealChatBubbleTalk(nChannelType, nSenderId, szMsg)
  end
  ChatMgr:OnReceiveMsgTip(tbMsg)
  ChatMgr.tbNewMsgChannel[nRealChannel] = true
  UiNotify.OnNotify(UiNotify.emNOTIFY_CHAT_NEW_MSG, nRealChannel, tbMsg)
  if ChatMgr:CheckVoiceRequestTimeOut() and ChatMgr.VoiceInfo.curPlayVoice == nil and self.VoiceInfo.requestPlayVoice == nil then
    ChatMgr:AutoPlayNextVoice()
  end
  if self:CheckVoiceId(uFileIdHigh, uFileIdLow, szApolloVoiceId) and tbMsg.nSenderId ~= me.dwID and ChatMgr:CheckVoiceAutoEnable(nChannelType) then
    ChatMgr:AddAutoPlayVoice(nChannelType, uFileIdHigh, uFileIdLow, szApolloVoiceId)
    if ChatMgr.VoiceInfo.curPlayVoice == nil and self.VoiceInfo.requestPlayVoice == nil then
      ChatMgr:AutoPlayNextVoice()
    end
  end
end
function ChatMgr:CheckVoiceId(uFileIdHigh, uFileIdLow, szApolloVoiceId)
  if szApolloVoiceId and szApolloVoiceId ~= "" then
    return true
  end
  if uFileIdHigh and uFileIdHigh > 0 and uFileIdLow and uFileIdLow > 0 then
    return true
  end
  return false
end
function ChatMgr:OnReceiveMsgTip(tbMsg)
  if tbMsg.nChannelType == ChatMgr.ChannelType.Public and tbMsg.nSenderId == me.dwID then
    local tbChatData = self:GetChannelChatData(tbMsg.nChannelType)
    local nLeftPublicCount = ChatMgr:GetPublicChatLeftCount(me)
    local tbLeftCountTip = {
      nChannelType = ChatMgr.ChannelType.System,
      nSenderId = ChatMgr.SystemMsgType.Tip,
      szSenderName = "",
      nTime = GetTime(),
      szMsg = string.format("您在世界频道还有 [FFFE0D]%d次[-] 发言机会。", nLeftPublicCount)
    }
    table.insert(tbChatData, tbLeftCountTip)
  elseif tbMsg.nChannelType == ChatMgr.ChannelType.Cross and tbMsg.nSenderId == me.dwID then
    local tbChatData = self:GetChannelChatData(tbMsg.nChannelType)
    local nLeftCount = ChatMgr:GetCrossChatLeftCount(me)
    local tbLeftCountTip = {
      nChannelType = ChatMgr.ChannelType.System,
      nSenderId = ChatMgr.SystemMsgType.Tip,
      szSenderName = "",
      nTime = GetTime(),
      szMsg = string.format("您在主播频道还有 [FFFE0D]%d次[-] 发言机会。", nLeftCount)
    }
    table.insert(tbChatData, tbLeftCountTip)
  end
end
function ChatMgr:SpecialRule4Senders(nChannelId, nSenderId, szSenderName)
  if not version_tx or nChannelId ~= ChatMgr.ChannelType.Cross then
    return nSenderId, szSenderName
  end
  local szServerName, bRealServer = Sdk:GetServerDesc(nSenderId)
  if ChatMgr:IsCrossHost(me) and bRealServer then
    szSenderName = string.format("%s（%s）", szSenderName, szServerName)
    return 0, szSenderName
  elseif bRealServer then
    return 0, "来自其他服的神秘人"
  end
  return nSenderId, szSenderName
end
function ChatMgr:DealChatBubbleTalk(nChannelId, nSenderId, szMsg)
  if nChannelId ~= ChatMgr.ChannelType.Nearby then
    return
  end
  local pSenderNpc = me.GetNpc().GetNearbyNpcByPlayerId(nSenderId)
  if pSenderNpc then
    szMsg = ChatMgr:CutMsg(szMsg, ChatMgr.nMaxBubbleMsgLen)
    pSenderNpc.BubbleTalk(szMsg, tostring(ChatMgr.nBubbleLastingTime))
  end
end
function ChatMgr:InBlackList(nChannelType, nSenderId)
  if nChannelType == ChatMgr.ChannelType.System then
    return false
  end
  return FriendShip:IsHeInMyBlack(nSenderId)
end
function ChatMgr:GetUnReadPrivateMsgNum()
  local nNUM = 0
  for k, v in pairs(ChatMgr.PrivateChatUnReadCache) do
    nNUM = nNUM + #v
  end
  return nNUM
end
local CheckInSertPrivateMsgTime = function(lastV, tbReaded, nTime)
  if not lastV or nTime - lastV.nTime >= 600 then
    table.insert(tbReaded, {
      nChannelType = ChatMgr.ChannelType.System,
      nSenderId = ChatMgr.SystemMsgType.TimeTips,
      szSenderName = "",
      nTime = nTime
    })
  end
end
function ChatMgr:SendPrivateMessage(dwReceive, szMsg, uFileIdHigh, uFileIdLow, strFilePath, nVoiceTime, szApolloVoiceId)
  if not ChatMgr:CheckSendMsg(ChatMgr.ChannelType.Private, szMsg, false, uFileIdHigh, uFileIdLow, strFilePath, nVoiceTime, szApolloVoiceId) then
    return
  end
  if FriendShip:IsHeInMyBlack(dwReceive) then
    me.CenterMsg("对方在您的黑名单中")
    return
  end
  szMsg = ChatMgr:Filter4CharString(szMsg)
  local tbChatLink = self.tbChatLink or {}
  local nLinkType = tbChatLink.nLinkType
  local linkParam = tbChatLink.linkParam
  if not ChatMgr:CheckLinkAvailable(szMsg, nLinkType, linkParam) then
    nLinkType = 0
    linkParam = 0
  end
  if ChatMgr:CheckVoiceSendEnable() and ChatMgr:IsValidVoiceMsg(ChatMgr.ChannelType.Private, uFileIdHigh, uFileIdLow, strFilePath, szApolloVoiceId) then
    if szApolloVoiceId then
      SendPrivateMessageWithApolloVoice(dwReceive, szMsg, nLinkType, linkParam, szApolloVoiceId, nVoiceTime)
    else
      local voiceData, dataLen = Lib:ReadFileBinary(strFilePath)
      if voiceData and dataLen > 0 then
        FileServer:SendVoiceFile(uFileIdHigh, uFileIdLow, voiceData, function(bRet)
          if bRet then
            SendPrivateMessage(dwReceive, szMsg, nLinkType, linkParam, uFileIdHigh, uFileIdLow, nVoiceTime)
          else
            SendPrivateMessage(dwReceive, szMsg, nLinkType, linkParam)
          end
        end, false)
      end
    end
  else
    uFileIdHigh = 0
    uFileIdLow = 0
    nVoiceTime = 0
    SendPrivateMessage(dwReceive, szMsg, nLinkType, linkParam)
  end
  self:CachePrivateMsg(dwReceive, szMsg, tbChatLink, uFileIdHigh, uFileIdLow, szApolloVoiceId, nVoiceTime)
  return true
end
function ChatMgr:CachePrivateMsg(dwReceive, szMsg, tbChatLink, uFileIdHigh, uFileIdLow, szApolloVoiceId, nVoiceTime)
  Log("CachePrivateMsg", dwReceive, szMsg)
  local nNow = GetTime()
  local tbReaded = ChatMgr.PrivateChatReadCache[dwReceive] or {}
  local lastV = next(tbReaded) and tbReaded[#tbReaded]
  CheckInSertPrivateMsgTime(lastV, tbReaded, nNow)
  table.insert(tbReaded, {
    nSenderId = me.dwID,
    szSenderName = me.szName,
    szMsg = szMsg,
    tbLinkInfo = tbChatLink,
    uFileIdHigh = uFileIdHigh,
    uFileIdLow = uFileIdLow,
    szApolloVoiceId = szApolloVoiceId,
    uVoiceTime = nVoiceTime,
    nTime = nNow,
    nHeadBg = me.GetUserValue(ChatMgr.CHAT_BACKGROUND_USERVAULE_GROUP, ChatMgr.CHAT_BACKGROUND_USERVAULE_HEAD),
    nChatBg = me.GetUserValue(ChatMgr.CHAT_BACKGROUND_USERVAULE_GROUP, ChatMgr.CHAT_BACKGROUND_USERVAULE_CHAT),
    nFaction = me.nFaction
  })
  ChatMgr.PrivateChatReadCache[dwReceive] = tbReaded
  self:SortRecentPrivateList(dwReceive)
  self:CheckSavePrivateMsg()
  Achievement:AddCount("Chat_Private")
  ChatMgr:InsertRecentSendMsg(szMsg)
end
function ChatMgr:SortRecentPrivateList(dwRoleId, bOnline)
  if not dwRoleId then
    return false
  end
  local RecentPrivateList = self.RecentPrivateList
  for i, v in ipairs(RecentPrivateList) do
    if v.dwID == dwRoleId then
      local tbData = FriendShip:GetFriendDataInfo(dwRoleId)
      if tbData then
        v = Lib:CopyTB1(tbData)
      end
      if bOnline then
        v.nState = 2
      end
      table.remove(RecentPrivateList, i)
      table.insert(RecentPrivateList, 1, v)
      return v
    end
  end
  if #RecentPrivateList >= self.MAX_PRIVATE_LIST_NUM then
    table.remove(RecentPrivateList)
  end
  local tbData = FriendShip:GetFriendDataInfo(dwRoleId)
  if tbData then
    table.insert(RecentPrivateList, 1, Lib:CopyTB1(tbData))
    return tbData
  else
    table.insert(RecentPrivateList, 1, {
      dwID = dwRoleId,
      szName = "陌生人",
      nPortrait = 1,
      nLevel = 1,
      nHonorLevel = 0,
      nFaction = 1,
      nVipLevel = 0,
      nState = 2
    })
    RemoteServer.RequestChatRoleBaseInfo({dwRoleId})
    return false
  end
end
function ChatMgr:DelPrivateChat(dwRoleId)
  for i, v in ipairs(self.RecentPrivateList) do
    if v.dwID == dwRoleId then
      table.remove(self.RecentPrivateList, i)
      self.PrivateChatUnReadCache[dwRoleId] = nil
      self.PrivateChatReadCache[dwRoleId] = nil
      UiNotify.OnNotify(UiNotify.emNOTIFY_CHAT_DEL_PRIVATE, dwRoleId)
      UiNotify.OnNotify(UiNotify.emNoTIFY_NEW_PRIVATE_MSG)
      self:CheckSavePrivateMsg()
      return
    end
  end
end
function ChatMgr:RemoveRecentPrivateTarget(dwRoleId)
  for i, v in ipairs(self.RecentPrivateList) do
    if v.dwID == dwRoleId then
      table.remove(self.RecentPrivateList, i)
      return
    end
  end
end
function ChatMgr:OnPrivateApolloTrans(dwSender, nTime, szMsg, uFileIdHigh, uFileIdLow, uVoiceTime, nHeadBg, nChatBg, tbLinkInfo, szApolloVoiceId)
  local tbPersonCache = ChatMgr.PrivateChatUnReadCache[dwSender] or {}
  local tbPersonReadedCache = ChatMgr.PrivateChatReadCache[dwSender] or {}
  for _, tbMsg in pairs(tbPersonCache) do
    if tbMsg.szApolloVoiceId == szApolloVoiceId then
      tbMsg.szMsg = szMsg
      UiNotify.OnNotify(UiNotify.emNoTIFY_NEW_PRIVATE_MSG, dwSender)
      return
    end
  end
  for _, tbMsg in pairs(tbPersonReadedCache) do
    if tbMsg.szApolloVoiceId == szApolloVoiceId then
      tbMsg.szMsg = szMsg
      UiNotify.OnNotify(UiNotify.emNoTIFY_NEW_PRIVATE_MSG, dwSender)
      return
    end
  end
end
function ChatMgr:OnPrivateMessage(dwSender, nTime, szMsg, uFileIdHigh, uFileIdLow, uVoiceTime, nHeadBg, nChatBg, tbLinkInfo, szApolloVoiceId)
  if FriendShip:IsHeInMyBlack(dwSender) then
    return
  end
  if szApolloVoiceId and szApolloVoiceId ~= "" and szMsg and szMsg ~= "" then
    self:OnPrivateApolloTrans(dwSender, nTime, szMsg, uFileIdHigh, uFileIdLow, uVoiceTime, nHeadBg, nChatBg, tbLinkInfo, szApolloVoiceId)
    return
  end
  if tbLinkInfo and tbLinkInfo.nLinkType == ChatMgr.LinkType.LuaPacker then
    tbLinkInfo.nLinkType = tbLinkInfo.tbData and tbLinkInfo.tbData.nLinkType
    tbLinkInfo = tbLinkInfo.tbData
  end
  local tbPersonCache = ChatMgr.PrivateChatUnReadCache[dwSender] or {}
  ChatMgr.PrivateChatUnReadCache[dwSender] = tbPersonCache
  local tbPersonReadedCache = ChatMgr.PrivateChatReadCache[dwSender] or {}
  local tbMsg = {
    nSenderId = dwSender,
    nTime = nTime,
    szMsg = szMsg,
    tbLinkInfo = tbLinkInfo,
    uFileIdHigh = uFileIdHigh,
    uFileIdLow = uFileIdLow,
    szApolloVoiceId = szApolloVoiceId,
    uVoiceTime = uVoiceTime,
    nHeadBg = nHeadBg,
    nChatBg = nChatBg
  }
  if szApolloVoiceId and szApolloVoiceId ~= "" then
    local fileIdHigh, fileIdLow = FileServer:CreateFileId()
    uFileIdHigh = fileIdHigh
    uFileIdLow = fileIdLow
    tbMsg.uFileIdHigh = fileIdHigh
    tbMsg.uFileIdLow = fileIdLow
  end
  if nTime <= GetTime() - 5 then
    table.insert(tbPersonCache, 1, tbMsg)
  else
    table.insert(tbPersonCache, tbMsg)
  end
  if #tbPersonReadedCache + #tbPersonCache > FriendShip.nMaxPrivateMessages then
    if #tbPersonReadedCache == 0 then
      table.remove(tbPersonCache, 1)
    else
      table.remove(tbPersonReadedCache, 1)
    end
  end
  self:SortRecentPrivateList(dwSender, true)
  UiNotify.OnNotify(UiNotify.emNoTIFY_NEW_PRIVATE_MSG, dwSender)
  if self:IsValidVoiceFileId(uFileIdHigh, uFileIdLow, szApolloVoiceId) and tbMsg.nSenderId ~= me.dwID and ChatMgr:CheckVoiceAutoEnable(ChatMgr.ChannelType.Private) then
    ChatMgr:AddAutoPlayVoice(ChatMgr.ChannelType.Private, uFileIdHigh, uFileIdLow, szApolloVoiceId)
  end
  self:CheckSavePrivateMsg()
end
function ChatMgr:OpenPrivateWindow(dwRoleId, tbPassData)
  assert(dwRoleId)
  local tbBlack = FriendShip:IsHeInMyBlack(dwRoleId)
  if tbBlack then
    local function fnCallBack()
      FriendShip:DelBlack(dwRoleId)
      ChatMgr:OpenPrivateWindow(dwRoleId, tbBlack)
    end
    Ui:OpenWindow("MessageBox", string.format("[FFFE0D]%s[-] 在您的黑名单中，是否要解除对他的屏蔽且发起密聊？", tbBlack.szName), {
      {fnCallBack},
      {}
    }, {"同意", "取消"})
    return
  end
  local tbData = self:SortRecentPrivateList(dwRoleId)
  if not tbData then
    tbData = tbPassData
    tbData.dwID = dwRoleId
  end
  if not tbData.szName then
    Log(debug.traceback())
    return
  end
  Ui:OpenWindow("ChatLargePanel", ChatMgr.nChannelFriendName, dwRoleId, tbData.szName)
end
function ChatMgr:OnPrivateChatOffline(dwRoleId)
  if FriendShip:GetFriendDataInfo(dwRoleId) then
    return
  end
  for i, v in ipairs(self.RecentPrivateList) do
    if v.dwID == dwRoleId then
      v.nState = 0
      UiNotify.OnNotify(UiNotify.emNoTIFY_NEW_PRIVATE_MSG)
      return
    end
  end
end
function ChatMgr:GetFriendOrPrivatePlayerData(dwRoleId)
  local tbPlayerData = FriendShip:GetFriendDataInfo(dwRoleId)
  if not tbPlayerData then
    for i, v in ipairs(self.RecentPrivateList) do
      if v.dwID == dwRoleId then
        tbPlayerData = v
        break
      end
    end
  end
  return tbPlayerData or {}
end
function ChatMgr:OnSynChatRoleBaseInfo(tbRoles)
  local bFind = false
  for i, v in ipairs(self.RecentPrivateList) do
    for i2, v2 in ipairs(tbRoles) do
      if v.dwID == v2.dwID then
        self.RecentPrivateList[i] = v2
        table.remove(tbRoles, i2)
        bFind = true
        break
      end
    end
    if not next(tbRoles) then
      break
    end
  end
  if bFind then
    UiNotify.OnNotify(UiNotify.emNoTIFY_NEW_PRIVATE_MSG)
  end
end
function ChatMgr:GetPrivateMsg(dwSender)
  if FriendShip:IsHeInMyBlack(dwSender) then
    ChatMgr.PrivateChatUnReadCache[dwSender] = nil
    ChatMgr.PrivateChatReadCache[dwSender] = nil
    return
  end
  local tbUnRead = ChatMgr.PrivateChatUnReadCache[dwSender] or {}
  local tbReaded = ChatMgr.PrivateChatReadCache[dwSender] or {}
  local tbRoleInfo = self:SortRecentPrivateList(dwSender)
  if not tbRoleInfo then
    return
  end
  local lastV = next(tbReaded) and tbReaded[#tbReaded]
  for i, v in ipairs(tbUnRead) do
    v.szSenderName = tbRoleInfo.szName
    v.nPortrait = tbRoleInfo.nPortrait
    v.nFaction = tbRoleInfo.nFaction
    CheckInSertPrivateMsgTime(lastV, tbReaded, v.nTime)
    table.insert(tbReaded, v)
    lastV = v
  end
  ChatMgr.PrivateChatReadCache[dwSender] = tbReaded
  ChatMgr.PrivateChatUnReadCache[dwSender] = nil
  UiNotify.OnNotify(UiNotify.emNOTIFY_PRIVATE_MSG_NUM_CHANGE)
  if next(tbUnRead) then
    self:CheckSavePrivateMsg()
  end
  return tbReaded
end
local tbSettingNameMap = {
  [ChatMgr.ChannelType.Public] = "CheckPublic",
  [ChatMgr.ChannelType.Nearby] = "CheckNearby",
  [ChatMgr.ChannelType.Team] = "CheckTeam",
  [ChatMgr.ChannelType.Kin] = "CheckKin",
  [ChatMgr.ChannelType.System] = "CheckSystem",
  [ChatMgr.ChannelType.Friend] = "CheckFriend"
}
local tbVoiceAutoSettingNameMap = {
  [ChatMgr.ChannelType.Public] = "CheckPublicVoice",
  [ChatMgr.ChannelType.Nearby] = "CheckNearbyVoice",
  [ChatMgr.ChannelType.Team] = "CheckTeamVoice",
  [ChatMgr.ChannelType.Kin] = "CheckKinVoice",
  [ChatMgr.ChannelType.Friend] = "CheckFriendVoice"
}
function ChatMgr:CheckShowInSmall(nChannelId)
  local tbChannelCfg = ChatMgr.tbDynamicChannel[nChannelId]
  if tbChannelCfg and tbChannelCfg.szIcon and tbChannelCfg.szIcon ~= "" then
    return true
  end
  local szCheckName = tbSettingNameMap[nChannelId]
  local tbSetting = ChatMgr:GetSetting()
  return tbSetting[szCheckName]
end
function ChatMgr:CheckVoiceSendEnable()
  local tbSetting = ChatMgr:GetSetting()
  return not tbSetting.CheckTextVoice
end
function ChatMgr:CheckVoiceAutoEnable(nChannelId)
  local szCheckName = tbVoiceAutoSettingNameMap[nChannelId]
  if not szCheckName then
    return false
  end
  if ChatMgr:IsCrossHost(me) and ChatMgr:HasJoinedCrossChannel() then
    return false
  end
  local tbSetting = ChatMgr:GetSetting()
  return tbSetting[szCheckName]
end
function ChatMgr:GetSetting()
  local tbSetting = Client:GetUserInfo("ChatSetting")
  if not next(tbSetting) then
    tbSetting.CheckKin = true
    tbSetting.CheckTeam = true
    tbSetting.CheckPublic = true
    tbSetting.CheckFriend = true
    tbSetting.CheckNearby = true
    tbSetting.CheckSystem = true
    tbSetting.CheckTextVoice = false
    tbSetting.TeamBubble = false
    tbSetting.CheckKinVoice = true
    tbSetting.CheckFriendVoice = true
    tbSetting.CheckTeamVoice = true
    tbSetting.CheckNearbyVoice = true
    tbSetting.CheckPublicVoice = false
  end
  return tbSetting
end
function ChatMgr:SaveSetting()
  Client:SaveUserInfo()
end
function ChatMgr:CutMsg(szMsg, nLen)
  nLen = nLen or ChatMgr.nMaxMsgLengh
  local nMsgLen = Lib:Utf8Len(szMsg)
  if nLen < nMsgLen then
    szMsg = Lib:CutUtf8(szMsg, nLen - 1) .. "…"
  else
    szMsg = Lib:CutUtf8(szMsg, nMsgLen)
  end
  return szMsg
end
function ChatMgr:UpdateColorMsgCount()
  UiNotify.OnNotify(UiNotify.emNOTIFY_UPDATE_COLORMSG_COUNT)
end
function ChatMgr:GetVoiceFilePath(uFileIdHigh, uFileIdLow)
  return string.format("%s/voice/%u%u.voice", Ui.ToolFunction.LibarayPath, uFileIdHigh, uFileIdLow)
end
function ChatMgr:IsVoiceFileAvailable(uFileIdHigh, uFileIdLow)
  return Lib:IsFileExsit(ChatMgr:GetVoiceFilePath(uFileIdHigh, uFileIdLow))
end
function ChatMgr:AddAutoPlayVoice(nChannelType, uFileIdHigh, uFileIdLow, szApolloVoiceId)
  if self.ChatRoom.bMicState then
    return
  end
  table.insert(self.VoiceInfo.autoQueue, {
    nChannelType = nChannelType,
    uFileIdHigh = uFileIdHigh,
    uFileIdLow = uFileIdLow,
    szApolloVoiceId = szApolloVoiceId
  })
end
function ChatMgr:ClearAutoPlayVoice()
  self.VoiceInfo.autoQueue = {}
end
function ChatMgr:IsInAutoPlayQueue(uFileIdHigh, uFileIdLow)
  for _, fileInfo in pairs(self.VoiceInfo.autoQueue) do
    if fileInfo.uFileIdHigh == uFileIdHigh and fileInfo.uFileIdLow == uFileIdLow then
      return true
    end
  end
  return false
end
function ChatMgr:IsCurPlayVoice(uFileIdHigh, uFileIdLow, szApolloVoiceId)
  if not self.VoiceInfo.curPlayVoice then
    return false
  end
  if szApolloVoiceId then
    return szApolloVoiceId == self.VoiceInfo.curPlayVoice.szApolloVoiceId
  end
  return self.VoiceInfo.curPlayVoice.uFileIdHigh == uFileIdHigh and self.VoiceInfo.curPlayVoice.uFileIdLow == uFileIdLow
end
function ChatMgr:AutoPlayNextVoice()
  if self.bStartedVoice then
    return
  end
  if self.VoiceInfo.curPlayVoice ~= nil then
    return
  end
  if #self.VoiceInfo.autoQueue <= 0 then
    return false
  end
  local uFileIdHigh = self.VoiceInfo.autoQueue[1].uFileIdHigh
  local uFileIdLow = self.VoiceInfo.autoQueue[1].uFileIdLow
  local szApolloVoiceId = self.VoiceInfo.autoQueue[1].szApolloVoiceId
  local nChannelType = self.VoiceInfo.autoQueue[1].nChannelType
  if self.VoiceInfo.requestPlayVoice then
    UiNotify.OnNotify(UiNotify.emNOTIFY_VOICE_PLAY_END, self.VoiceInfo.requestPlayVoice.uFileIdHigh, self.VoiceInfo.requestPlayVoice.uFileIdLow, self.VoiceInfo.requestPlayVoice.szApolloVoiceId)
    self:StopRequestApolloVoice(self.VoiceInfo.requestPlayVoice)
    self.VoiceInfo.requestPlayVoice = nil
  end
  UiNotify.OnNotify(UiNotify.emNOTIFY_VOICE_PLAY_START, uFileIdHigh, uFileIdLow, szApolloVoiceId)
  if not ChatMgr:IsVoiceFileAvailable(uFileIdHigh, uFileIdLow) then
    self.VoiceInfo.requestPlayVoice = {
      uFileIdHigh = uFileIdHigh,
      uFileIdLow = uFileIdLow,
      szApolloVoiceId = szApolloVoiceId,
      nTime = GetTime()
    }
    do
      local function OnDownLoaded()
        if #self.VoiceInfo.autoQueue > 0 and not self.VoiceInfo.curPlayVoice and (self.VoiceInfo.autoQueue[1].szApolloVoiceId and self.VoiceInfo.autoQueue[1].szApolloVoiceId == szApolloVoiceId or self.VoiceInfo.autoQueue[1].uFileIdHigh == uFileIdHigh and self.VoiceInfo.autoQueue[1].uFileIdLow == uFileIdLow) then
          self.VoiceInfo.curPlayVoice = self.VoiceInfo.autoQueue[1]
          table.remove(self.VoiceInfo.autoQueue, 1)
          if szApolloVoiceId then
            local nRet = ChatRoomMgr.PlayeVoiceFile(self:GetVoiceFilePath(uFileIdHigh, uFileIdLow))
            if nRet == ChatMgr.ApolloVoiceErr.APOLLO_VOICE_SUCC then
              self:OnStartPlayApolloVoice()
            end
            Log("OnDownLoaded PlayeVoiceFile", nRet)
          else
            Ui.UiManager.PlayVoice(uFileIdHigh, uFileIdLow)
          end
        end
        self:StopRequestApolloVoice(self.VoiceInfo.requestPlayVoice)
        self.VoiceInfo.requestPlayVoice = nil
      end
      if szApolloVoiceId then
        local nDownState = ChatRoomMgr.GetVoiceDownloadState()
        Log("AutoPlayNextVoice GetVoiceDownloadState", nDownState)
        if nDownState == ChatMgr.ApolloVoiceErr.APOLLO_VOICE_SUCC then
          local nRet = ChatRoomMgr.DownloadVoiceFile(self:GetVoiceFilePath(uFileIdHigh, uFileIdLow), szApolloVoiceId)
          Log("AutoPlayNextVoice DownloadVoiceFile", nRet)
          if nRet == ChatMgr.ApolloVoiceErr.APOLLO_VOICE_SUCC then
            do
              local requestPlayVoice = self.VoiceInfo.requestPlayVoice
              requestPlayVoice.nDownLoadTimer = Timer:Register(Env.GAME_FPS, function()
                local nState = ChatRoomMgr.GetVoiceDownloadState()
                if nState == ChatMgr.ApolloVoiceErr.APOLLO_VOICE_SUCC then
                  requestPlayVoice.nDownLoadTimer = nil
                  OnDownLoaded()
                  return false
                end
                return true
              end)
            end
          end
        end
      else
        FileServer:AskVoiceFile({nRoleId = uFileIdHigh, nMixFlag = uFileIdLow}, function(szVoiceData)
          Lib:WriteFileBinary(ChatMgr:GetVoiceFilePath(uFileIdHigh, uFileIdLow), szVoiceData)
          OnDownLoaded()
        end, ChatMgr:IsNeedZoneFileServer(nChannelType))
      end
      return false
    end
  end
  self.VoiceInfo.curPlayVoice = self.VoiceInfo.autoQueue[1]
  table.remove(self.VoiceInfo.autoQueue, 1)
  self:StopRequestApolloVoice(self.VoiceInfo.requestPlayVoice)
  self.VoiceInfo.requestPlayVoice = nil
  if szApolloVoiceId then
    local nRet = ChatRoomMgr.PlayeVoiceFile(self:GetVoiceFilePath(uFileIdHigh, uFileIdLow))
    if nRet == ChatMgr.ApolloVoiceErr.APOLLO_VOICE_SUCC then
      self:OnStartPlayApolloVoice()
    end
    Log("AutoPlayNextVoice PlayeVoiceFile", nRet)
  else
    Ui.UiManager.PlayVoice(uFileIdHigh, uFileIdLow)
  end
end
function ChatMgr:PlayVoice(nChannelType, uFileIdHigh, uFileIdLow, szApolloVoiceId)
  if self.bStartedVoice then
    self:AddAutoPlayVoice(nChannelType, uFileIdHigh, uFileIdLow, szApolloVoiceId)
    return
  end
  if self.VoiceInfo.requestPlayVoice then
    UiNotify.OnNotify(UiNotify.emNOTIFY_VOICE_PLAY_END, self.VoiceInfo.requestPlayVoice.uFileIdHigh, self.VoiceInfo.requestPlayVoice.uFileIdLow, self.VoiceInfo.requestPlayVoice.szApolloVoiceId)
    self:StopRequestApolloVoice(self.VoiceInfo.requestPlayVoice)
    self.VoiceInfo.requestPlayVoice = nil
  end
  if self.VoiceInfo.curPlayVoice then
    local curPlayVoice = self.VoiceInfo.curPlayVoice
    self:StopVoice()
    if curPlayVoice.uFileIdHigh == uFileIdHigh and curPlayVoice.uFileIdLow == uFileIdLow or szApolloVoiceId and szApolloVoiceId == curPlayVoice.szApolloVoiceId then
      return
    end
  end
  UiNotify.OnNotify(UiNotify.emNOTIFY_VOICE_PLAY_START, uFileIdHigh, uFileIdLow, szApolloVoiceId)
  if not ChatMgr:IsVoiceFileAvailable(uFileIdHigh, uFileIdLow) then
    self.VoiceInfo.requestPlayVoice = {
      uFileIdHigh = uFileIdHigh,
      uFileIdLow = uFileIdLow,
      szApolloVoiceId = szApolloVoiceId,
      nTime = GetTime()
    }
    do
      local function OnDownLoaded()
        if not self.VoiceInfo.curPlayVoice then
          self.VoiceInfo.curPlayVoice = {
            uFileIdHigh = uFileIdHigh,
            uFileIdLow = uFileIdLow,
            szApolloVoiceId = szApolloVoiceId
          }
          if szApolloVoiceId then
            local nRet = ChatRoomMgr.PlayeVoiceFile(self:GetVoiceFilePath(uFileIdHigh, uFileIdLow))
            if nRet == ChatMgr.ApolloVoiceErr.APOLLO_VOICE_SUCC then
              self:OnStartPlayApolloVoice()
            end
            Log("PlayVoice PlayeVoiceFile", nRet)
          else
            Ui.UiManager.PlayVoice(uFileIdHigh, uFileIdLow)
          end
        end
        self:StopRequestApolloVoice(self.VoiceInfo.requestPlayVoice)
        self.VoiceInfo.requestPlayVoice = nil
      end
      if szApolloVoiceId then
        local nDownState = ChatRoomMgr.GetVoiceDownloadState()
        Log("PlayVoice GetVoiceDownloadState", nDownState)
        if nDownState == ChatMgr.ApolloVoiceErr.APOLLO_VOICE_SUCC then
          local nRet = ChatRoomMgr.DownloadVoiceFile(self:GetVoiceFilePath(uFileIdHigh, uFileIdLow), szApolloVoiceId)
          Log("PlayVoice DownloadVoiceFile", nRet)
          if nRet == ChatMgr.ApolloVoiceErr.APOLLO_VOICE_SUCC then
            do
              local requestPlayVoice = self.VoiceInfo.requestPlayVoice
              requestPlayVoice.nDownLoadTimer = Timer:Register(Env.GAME_FPS, function()
                local nState = ChatRoomMgr.GetVoiceDownloadState()
                if nState == ChatMgr.ApolloVoiceErr.APOLLO_VOICE_SUCC then
                  requestPlayVoice.nDownLoadTimer = nil
                  OnDownLoaded()
                  return false
                end
                return true
              end)
            end
          end
        end
      else
        FileServer:AskVoiceFile({nRoleId = uFileIdHigh, nMixFlag = uFileIdLow}, function(szVoiceData)
          Lib:WriteFileBinary(ChatMgr:GetVoiceFilePath(uFileIdHigh, uFileIdLow), szVoiceData)
          OnDownLoaded()
        end, ChatMgr:IsNeedZoneFileServer(nChannelType))
      end
      return false
    end
  end
  self.VoiceInfo.curPlayVoice = {
    uFileIdHigh = uFileIdHigh,
    uFileIdLow = uFileIdLow,
    szApolloVoiceId = szApolloVoiceId
  }
  self:StopRequestApolloVoice(self.VoiceInfo.requestPlayVoice)
  self.VoiceInfo.requestPlayVoice = nil
  if szApolloVoiceId then
    local nRet = ChatRoomMgr.PlayeVoiceFile(self:GetVoiceFilePath(uFileIdHigh, uFileIdLow))
    if nRet == ChatMgr.ApolloVoiceErr.APOLLO_VOICE_SUCC then
      self:OnStartPlayApolloVoice()
    end
    Log("PlayVoice PlayeVoiceFile", nRet)
  else
    Ui.UiManager.PlayVoice(uFileIdHigh, uFileIdLow)
  end
end
function ChatMgr:StopVoice()
  local bUseApolloVoice = ChatMgr:CheckUseApollo()
  if bUseApolloVoice then
    ChatRoomMgr.StopPlayVoiceFile()
  else
    Ui.UiManager.StopVoice()
  end
  if self.VoiceInfo.curPlayVoice then
    UiNotify.OnNotify(UiNotify.emNOTIFY_VOICE_PLAY_END, self.VoiceInfo.curPlayVoice.uFileIdHigh, self.VoiceInfo.curPlayVoice.uFileIdLow, self.VoiceInfo.curPlayVoice.szApolloVoiceId)
  end
  self.VoiceInfo.curPlayVoice = nil
end
function ChatMgr:OnVoicePlayStart()
  Ui:SetMusicVolume(0)
  Ui:SetSoundEffect(0)
end
function ChatMgr:OnVoicePlayEnd()
  if ChatMgr.VoiceInfo.curPlayVoice then
    UiNotify.OnNotify(UiNotify.emNOTIFY_VOICE_PLAY_END, ChatMgr.VoiceInfo.curPlayVoice.uFileIdHigh, ChatMgr.VoiceInfo.curPlayVoice.uFileIdLow, ChatMgr.VoiceInfo.curPlayVoice.szApolloVoiceId)
  end
  self:CheckMusicVolume()
  ChatMgr.VoiceInfo.curPlayVoice = nil
  ChatMgr:AutoPlayNextVoice()
end
function ChatMgr:OnVoiceRecordChangeVolume(nVolume)
  UiNotify.OnNotify(UiNotify.emNOTIFY_VOICE_RECORD_VOLUME_CHANG, nVolume)
end
function ChatMgr:OnVoicePlayChangeVolume(nVolume)
  UiNotify.OnNotify(UiNotify.emNOTIFY_VOICE_PLAY_VOLUME_CHANG, nVolume)
end
function ChatMgr:OnVoiceError(szError)
  Ui:EndVoice()
  local szErrorCode = string.match(szError, "^Err%((%d+)%):.*$")
  local nErrorCode = szErrorCode and tonumber(szErrorCode) or 1
  me.CenterMsg(ChatMgr.tbVoiceError[nErrorCode] or XT("未知错误"))
end
function ChatMgr:IsValidVoiceFileId(uFileIdHigh, uFileIdLow, szApolloVoiceId)
  if szApolloVoiceId then
    return szApolloVoiceId ~= ""
  end
  return uFileIdHigh and uFileIdHigh > 0 and uFileIdLow and uFileIdLow > 0
end
function ChatMgr:OnLogin(bIsReconnect)
  if not bIsReconnect then
    RemoteServer.ReportTextVoiceSetting(not ChatMgr:CheckVoiceSendEnable())
  end
end
function ChatMgr:OnLostConnect()
  self:ClearDynChannelInfo()
  self:LeaveCurChatRoom()
end
function ChatMgr:OnLeaveGame()
  self:ClearCache()
  self:SavePriveMsg()
  self:ClearDynChannelInfo()
  if ANDROID or IOS then
    self:ClearAutoPlayVoice()
    self:StopVoice()
  end
  self:LeaveCurChatRoom()
  self.bHasJoinedCrossChannel = nil
  self.nNextCheckNamePrefixInfoTime = nil
end
function ChatMgr:CheckNamePrefixInfo()
  local nNow = GetTime()
  if self.nNextCheckNamePrefixInfoTime and nNow < self.nNextCheckNamePrefixInfoTime then
    return
  end
  self.nNextCheckNamePrefixInfoTime = nNow + 60
  if GetTimeFrameState(ChatMgr.szNamePrefixPowerTop10TimeFrame) ~= 1 then
    return
  end
  RemoteServer.DoChatRequest("CheckPlayerNamePrefixInfo")
end
function ChatMgr:OnNamePrefixInfoChanged(nPrefixId)
  Ui:SetRedPointNotify("ChatNamePrefix")
end
function ChatMgr:SetCurrentNamePrefixInfo(nPrefixId)
  RemoteServer.DoChatRequest("SetCurrentNamePrefixInfo", nPrefixId)
end
function ChatMgr:OnSyncEnterChatChannel(...)
  local tbChannelList = {
    ...
  }
  for _, tbInfo in pairs(tbChannelList) do
    self.tbDynamicChannel[tbInfo[1]] = {
      nId = tbInfo[1],
      szName = tbInfo[2],
      szIcon = tbInfo[3]
    }
  end
  UiNotify.OnNotify(UiNotify.emNOTIFY_DYN_CHANNEL_CHANGE)
end
function ChatMgr:OnSyncLeaveChatChannel(nChannelId)
  self.tbDynamicChannel[nChannelId] = nil
  UiNotify.OnNotify(UiNotify.emNOTIFY_DYN_CHANNEL_CHANGE)
end
function ChatMgr:ClearDynChannelInfo()
  self.tbDynamicChannel = {}
  UiNotify.OnNotify(UiNotify.emNOTIFY_DYN_CHANNEL_CHANGE)
end
function ChatMgr:IsChatRoomAvailable()
  if self.ChatRoom.dwRoomHighId and self.ChatRoom.dwRoomLowId and (self.ChatRoom.dwRoomHighId ~= 0 or self.ChatRoom.dwRoomLowId ~= 0) then
    return true
  end
  return false
end
function ChatMgr:OnSyncEnterChatRoom(dwRoomHighId, dwRoomLowId, dwRoomHighKey, dwRoomLowKey, uBusinessId, nIsLarge, nPrivilege, uMemberId, tbUrl)
  Log("OnSyncEnterChatRoom", dwRoomHighId, dwRoomLowId, dwRoomHighKey, dwRoomLowKey, nIsLarge, nPrivilege, uMemberId)
  Lib:LogTB(tbUrl)
  if self.ChatRoom.dwRoomHighId == dwRoomHighId and self.ChatRoom.dwRoomLowId == dwRoomLowId then
    return
  end
  self:LeaveCurChatRoom()
  self.ChatRoom.dwRoomHighId = dwRoomHighId
  self.ChatRoom.dwRoomLowId = dwRoomLowId
  self.ChatRoom.dwRoomHighKey = dwRoomHighKey
  self.ChatRoom.dwRoomLowKey = dwRoomLowKey
  self.ChatRoom.uBusinessId = uBusinessId
  self.ChatRoom.nIsLarge = nIsLarge
  self.ChatRoom.nPrivilege = nPrivilege
  self.ChatRoom.uMemberId = uMemberId
  self.ChatRoom.isEnterRoom = false
  self.ChatRoom.bSpeakerState = false
  self.ChatRoom.bMicState = false
  for idx, szUrl in pairs(tbUrl) do
    if nIsLarge ~= 1 and string.sub(tbUrl[idx], 1, string.len("udp://")) ~= "udp://" then
      tbUrl[idx] = "udp://" .. szUrl
    end
  end
  self.ChatRoom.tbUrl = tbUrl
  self:StartEnterRoom()
end
function ChatMgr:OnSyncLeaveChatRoom(dwRoomHighId, dwRoomLowId)
  if self.ChatRoom.dwRoomHighId ~= dwRoomHighId or self.ChatRoom.dwRoomLowId ~= dwRoomLowId then
    return
  end
  self:LeaveCurChatRoom()
end
function ChatMgr:LeaveCurChatRoom()
  Log("LeaveCurChatRoom", tostring(self:IsChatRoomAvailable()))
  if not self:IsChatRoomAvailable() then
    return
  end
  self:CloseCheckEnterTimer()
  ChatRoomMgr.LeaveRoom(self.ChatRoom.dwRoomHighId, self.ChatRoom.dwRoomLowId, self.ChatRoom.uMemberId, self.ChatRoom.nIsLarge)
  self.ChatRoom.dwRoomHighId = 0
  self.ChatRoom.dwRoomLowId = 0
  self.ChatRoom.dwRoomHighKey = 0
  self.ChatRoom.dwRoomLowKey = 0
  self.ChatRoom.uBusinessId = 0
  self.ChatRoom.nIsLarge = 0
  self.ChatRoom.nPrivilege = 0
  self.ChatRoom.uMemberId = 0
  self.ChatRoom.isEnterRoom = false
  self.ChatRoom.bSpeakerState = false
  self.ChatRoom.bMicState = false
  self.ChatRoom.tbUrl = {}
  self:CheckMusicVolume()
  Ui:CloseWindow("HomeScreenVoice")
end
function ChatMgr:CheckMusicVolume()
  if self.ChatRoom.bMicState then
    self:ClearAutoPlayVoice()
    self:StopVoice()
  end
  if self.checkVolumeTimer then
    return
  end
  local function checkVolume()
    self.checkVolumeTimer = nil
    if self.ChatRoom.bSpeakerState or self.ChatRoom.bMicState or ChatMgr.VoiceInfo.curPlayVoice or self.bStartedVoice then
      Ui:SetMusicVolume(0)
      Ui:SetSoundEffect(0)
    else
      Ui:UpdateSoundSetting()
    end
  end
  self.checkVolumeTimer = Timer:Register(Env.GAME_FPS * 1, checkVolume)
end
function ChatMgr:OpenChatRoomSpeaker()
  if not self:IsChatRoomAvailable() then
    return
  end
  self.ChatRoom.bSpeakerState = ChatRoomMgr.OpenSpeaker()
  self:CheckMusicVolume()
end
function ChatMgr:CloseChatRoomSpeaker()
  if not self:IsChatRoomAvailable() then
    return
  end
  self.ChatRoom.bSpeakerState = ChatRoomMgr.CloseSpeaker()
  self:CheckMusicVolume()
end
function ChatMgr:CloseChatRoomTmp()
  self.ChatRoom.bSpeakerStateTmp = self.ChatRoom.bSpeakerState
  self.ChatRoom.bMicStateTmp = self.ChatRoom.bMicState
  self:CloseChatRoomSpeaker()
  self:CloseChatRoomMic()
  UiNotify.OnNotify(UiNotify.emNOTIFY_CHAT_ROOM_STATUS)
end
function ChatMgr:RestoreChatRoomTmp()
  if self.ChatRoom.bSpeakerStateTmp then
    self:OpenChatRoomSpeaker()
  end
  if self.ChatRoom.bMicStateTmp then
    self:OpenChatRoomMic()
  end
  self.ChatRoom.bSpeakerStateTmp = false
  self.ChatRoom.bMicStateTmp = false
  UiNotify.OnNotify(UiNotify.emNOTIFY_CHAT_ROOM_STATUS)
end
function ChatMgr:OpenChatRoomMic()
  if not self:IsChatRoomAvailable() then
    return
  end
  self.ChatRoom.bMicState = ChatRoomMgr.OpenMic()
  self:CheckMusicVolume()
end
function ChatMgr:CloseChatRoomMic()
  if not self:IsChatRoomAvailable() then
    return
  end
  self.ChatRoom.bMicState = ChatRoomMgr.CloseMic()
  self:CheckMusicVolume()
end
function ChatMgr:ClearRoleChatMsg(dwRoleID)
  for nRealChannel, tbChatData in pairs(self.ChatDataCache) do
    for idx = #tbChatData, 1, -1 do
      if tbChatData[idx].nSenderId == dwRoleID then
        table.remove(tbChatData, idx)
      end
    end
    UiNotify.OnNotify(UiNotify.emNOTIFY_CHAT_NEW_MSG, nRealChannel)
  end
end
function ChatMgr:StartEnterRoom()
  if not self:IsChatRoomAvailable() then
    return
  end
  ChatRoomMgr.SetMode(ChatMgr.ApolloVoiceMode.REALTIME_VOICE)
  local bHasJoined, bJoinedHost = ChatMgr:HasJoinedCrossChannel()
  if bHasJoined and bJoinedHost then
    ChatRoomMgr.SetAnchorUsed(true)
    ChatRoomMgr.SetMemberCount(1)
  end
  if IOS and not self.bInitFixApollo then
    ChatRoomMgr.OpenMic()
    self.bInitFixApollo = true
    Timer:Register(Env.GAME_FPS * 2, function()
      ChatRoomMgr.CloseMic()
    end)
  end
  ChatRoomMgr.EnterRoom(self.ChatRoom.dwRoomHighId, self.ChatRoom.dwRoomLowId, self.ChatRoom.dwRoomHighKey, self.ChatRoom.dwRoomLowKey, self.ChatRoom.uBusinessId, self.ChatRoom.nIsLarge, self.ChatRoom.nPrivilege, self.ChatRoom.uMemberId, self.ChatRoom.tbUrl[1] or "", self.ChatRoom.tbUrl[2] or "", self.ChatRoom.tbUrl[3] or "")
  self:CloseCheckEnterTimer()
  self:StartCheckEnterTimer()
end
function ChatMgr:IsCanUseRoomMic()
  if not self:IsChatRoomAvailable() or not self.ChatRoom.isEnterRoom then
    return false
  end
  if self.ChatRoom.nIsLarge == 1 and self.ChatRoom.nPrivilege ~= ChatMgr.RoomPrivilege.emSpeaker then
    return false
  end
  return true
end
function ChatMgr:IsCanUseRoomSpeaker()
  if not self:IsChatRoomAvailable() or not self.ChatRoom.isEnterRoom then
    return false
  end
  return true
end
function ChatMgr:OnEnterChatRoom()
  self.ChatRoom.isEnterRoom = true
  ChatMgr:OpenChatRoomSpeaker()
  if Ui:WindowVisible("HomeScreenVoice") == 1 then
    local isMicAvailable, isTmpDisable = ChatMgr:IsCanUseRoomMic()
    UiNotify.OnNotify(UiNotify.emNOTIFY_CHAT_ROOM_STATUS, true, isMicAvailable, self:IsCanUseRoomSpeaker())
  else
    Ui:OpenWindow("HomeScreenVoice")
  end
end
function ChatMgr:StartCheckEnterTimer()
  Log("StartCheckEnterTimer", tostring(self.ChatRoom.nCheckTimer))
  if self.ChatRoom.nCheckTimer then
    return
  end
  local nRet = ChatRoomMgr.GetEnterRoomResult(self.ChatRoom.nIsLarge)
  Log("GetEnterRoomResult", nRet)
  if nRet == ChatMgr.ApolloVoiceErr.APOLLO_VOICE_JOIN_SUCC then
    ChatMgr:OnEnterChatRoom()
    return
  end
  local nCheckCount = 0
  self.ChatRoom.nCheckTimer = Timer:Register(Env.GAME_FPS * 1, function()
    local nRet = ChatRoomMgr.GetEnterRoomResult(self.ChatRoom.nIsLarge)
    Log("GetEnterRoomResult", nRet, nCheckCount)
    if nRet == ChatMgr.ApolloVoiceErr.APOLLO_VOICE_JOIN_SUCC then
      ChatMgr:OnEnterChatRoom()
      return false
    end
    if nCheckCount >= 30 then
      ChatRoomMgr.LeaveRoom(self.ChatRoom.dwRoomHighId, self.ChatRoom.dwRoomLowId, self.ChatRoom.uMemberId, self.ChatRoom.nIsLarge)
      ChatMgr:StartEnterRoom()
      return false
    end
    nCheckCount = nCheckCount + 1
    return true
  end)
end
function ChatMgr:CloseCheckEnterTimer()
  if not self.ChatRoom.nCheckTimer then
    return
  end
  Timer:Close(self.ChatRoom.nCheckTimer)
  self.ChatRoom.nCheckTimer = nil
end
function ChatMgr:CheckVoiceRequestTimeOut()
  if self.VoiceInfo.requestPlayVoice == nil then
    return true
  end
  if self.VoiceInfo.requestPlayVoice.nTime + self.VOICE_REQUEST_TIME_OUT > GetTime() then
    return false
  end
  if self.VoiceInfo.autoQueue[1] and (self.VoiceInfo.autoQueue[1].uFileIdHigh == self.VoiceInfo.requestPlayVoice.uFileIdHigh and self.VoiceInfo.autoQueue[1].uFileIdLow == self.VoiceInfo.requestPlayVoice.uFileIdLow or self.VoiceInfo.autoQueue[1].szApolloVoiceId and self.VoiceInfo.autoQueue[1].szApolloVoiceId == self.VoiceInfo.requestPlayVoice.szApolloVoiceId) then
    table.remove(self.VoiceInfo.autoQueue, 1)
  end
  self:StopRequestApolloVoice(self.VoiceInfo.requestPlayVoice)
  self.VoiceInfo.requestPlayVoice = nil
  return true
end
function ChatMgr:IsApolloEnable()
  if ANDROID or IOS then
    return true
  end
  return false
end
function ChatMgr:GetMaxVoiceTime(nChannelType)
  local tbVoiceTimeInfo = ChatMgr.tbMaxVoiceTimes[nChannelType]
  if not tbVoiceTimeInfo then
    return ChatMgr.MAX_VOICE_TIME_DEFAULT
  end
  local tbMyData = Kin:GetMyMemberData()
  local nCareer = tbMyData and tbMyData.nCareer or Kin.Def.Career_Normal
  local nVipLevel = me.GetVipLevel()
  local tbCareerTimes = tbVoiceTimeInfo.tbCareer or {}
  local tbVipTimes = tbVoiceTimeInfo.tbVip or {}
  local nVipTimes
  for nNeedLevel, nTime in pairs(tbVipTimes) do
    if nNeedLevel <= nVipLevel and (not nVipTimes or nTime > nVipTimes) then
      nVipTimes = nTime
    end
  end
  return nVipTimes or tbCareerTimes[nCareer] or ChatMgr.MAX_VOICE_TIME_DEFAULT
end
function ChatMgr:OnSyncApolloVoice(bEnable)
  self.bApolloVoice = bEnable
end
function ChatMgr:OnApolloAuth(uMainId, szMainUrl1, szMainUrl2, uMainIp1, uMainIp2, uSlaveId, szSlaveUrl1, szSlaveUrl2, uSlaveIp1, uSlaveIp2, uExpireTime, szAuthKey)
  Log("OnApolloAuth", uMainId, szMainUrl1, szMainUrl2, uMainIp1, uMainIp2, uSlaveId, szSlaveUrl1, szSlaveUrl2, uSlaveIp1, uSlaveIp2, uExpireTime, szAuthKey)
  local function delayAuth()
    ChatRoomMgr.CreateEngine()
    ChatRoomMgr.SetMode(ChatMgr.ApolloVoiceMode.STT_VOICE)
    local nRet = ChatRoomMgr.SetAuthkey(szAuthKey)
    Log("SetAuthkey", nRet)
    nRet = ChatRoomMgr.SetServiceInfo(uMainIp1, uMainIp2, uSlaveIp1, uSlaveIp2, 80, 20000)
    Log("SetServiceInfo", nRet)
    self.bApolloVoiceInit = true
  end
  if IOS then
  else
    delayAuth()
  end
end
function ChatMgr:CheckUseApollo()
  Log("CheckUseApollo", tostring(self.bApolloVoice), tostring(self.bApolloVoiceInit))
  if not self:CheckVoiceSendEnable() then
    return false
  end
  return self.bApolloVoice and self.bApolloVoiceInit
end
function ChatMgr:StartApolloVoice(uFileIdHigh, uFileIdLow)
  local szFilePath = self:GetVoiceFilePath(uFileIdHigh, uFileIdLow)
  Log("StartApolloVoice", szFilePath)
  local nUploadState = ChatRoomMgr.GetVoiceUploadState()
  Log("GetVoiceUploadState", nUploadState)
  if nUploadState ~= ChatMgr.ApolloVoiceErr.APOLLO_VOICE_SUCC then
    me.CenterMsg(XT("请稍候再试"))
    return nUploadState
  end
  local nRet = ChatRoomMgr.StartRecord(szFilePath)
  Log("StartRecord", nRet)
  if nRet == ChatMgr.ApolloVoiceErr.APOLLO_VOICE_SUCC then
    self:StartApolloMicTimer()
  end
  return nRet
end
function ChatMgr:StopApolloVoice()
  self:StopApolloMicTimer()
  local nRet = ChatRoomMgr.StopRecord(true)
  Log("StopApolloVoice", nRet)
  if nRet == ChatMgr.ApolloVoiceErr.APOLLO_VOICE_SUCC then
    self:StartApolloUploadTimer()
  end
end
function ChatMgr:StartApolloMicTimer()
  self:StopApolloMicTimer()
  self.nApolloMicTimer = Timer:Register(math.floor(Env.GAME_FPS * 0.3), function()
    local nVolume = ChatRoomMgr.GetMicLevel()
    nVolume = math.floor(nVolume * 30 / 65535)
    UiNotify.OnNotify(UiNotify.emNOTIFY_VOICE_RECORD_VOLUME_CHANG, nVolume)
    return true
  end)
end
function ChatMgr:StopApolloMicTimer()
  if self.nApolloMicTimer then
    Timer:Close(self.nApolloMicTimer)
    self.nApolloMicTimer = nil
  end
end
function ChatMgr:StartApolloUploadTimer()
  self:StopApolloUploadTimer()
  self.nApolloUploadTimer = Timer:Register(Env.GAME_FPS, function()
    self:CheckApolloUploaded()
    return true
  end)
end
function ChatMgr:StopApolloUploadTimer()
  if self.nApolloUploadTimer then
    Timer:Close(self.nApolloUploadTimer)
    self.nApolloUploadTimer = nil
  end
end
function ChatMgr:CheckApolloUploaded()
  local nUploadState = ChatRoomMgr.GetVoiceUploadState()
  Log("CheckApolloUploaded", nUploadState)
  if self.nApolloUploadTimer and nUploadState == ChatMgr.ApolloVoiceErr.APOLLO_VOICE_SUCC then
    local szFileId = ChatRoomMgr.GetCurVoiceFileId()
    local nFileSize = ChatRoomMgr.GetCurVoiceFileSize()
    local nVoiceTime = ChatRoomMgr.GetCurVoiceFileTime()
    Log("Upload Ended", szFileId, nFileSize, nVoiceTime)
    if Ui.fnVoiceCallBack then
      if not szFileId or szFileId == "" then
        me.CenterMsg("语音发送失败")
      else
        Ui.fnVoiceCallBack("", 0, 0, "", nVoiceTime * 1000, szFileId)
      end
    end
    Ui.fnVoiceCallBack = nil
    self:StopApolloUploadTimer()
  end
end
function ChatMgr:StopRequestApolloVoice(requestPlayVoice)
  if requestPlayVoice and requestPlayVoice.nDownLoadTimer then
    Timer:Close(requestPlayVoice.nDownLoadTimer)
    requestPlayVoice.nDownLoadTimer = nil
  end
end
function ChatMgr:OnStartPlayApolloVoice()
  if self.nPlayApolloVoiceTimer then
    return
  end
  self.nPlayApolloVoiceTimer = Timer:Register(Env.GAME_FPS, function()
    local nState = ChatRoomMgr.GetPlayVoiceState()
    if nState == 0 then
      self:OnVoicePlayEnd()
      self.nPlayApolloVoiceTimer = nil
      return false
    end
    return true
  end)
end
function ChatMgr:IsNeedZoneFileServer(nChannelId)
  local tbChannelInfo = ChatMgr.NeedZoneFileServer[nChannelId]
  if not tbChannelInfo then
    return false
  end
  local nMapTemplateId = me.nMapTemplateId
  if not nMapTemplateId then
    return false
  end
  if not tbChannelInfo[nMapTemplateId] then
    return false
  end
  return true
end
function ChatMgr:JoinCrossChannel()
  RemoteServer.DoChatRequest("JoinCrossChannel")
end
function ChatMgr:JoinCrossChannelHost()
  RemoteServer.DoChatRequest("JoinCrossChannelHost")
end
function ChatMgr:LeaveCrossChannel()
  RemoteServer.DoChatRequest("LeaveCrossChannel")
end
function ChatMgr:AskCrossHostInfo()
  RemoteServer.DoChatRequest("AskCrossHostInfo")
end
function ChatMgr:AskCrossHostState()
  RemoteServer.DoChatRequest("AskCrossHostState", self.bHasHost or false)
end
function ChatMgr:OnSynCrossHostState(bHasHost)
  self.bHasHost = bHasHost
  UiNotify.OnNotify(UiNotify.emNOTIFY_CHAT_CROSS_HOST)
end
function ChatMgr:IsHostOnline()
  return self.bHasHost or false
end
function ChatMgr:OnSyncCrossChannelState(bJoined, nAuth)
  self.bHasJoinedCrossChannel = bJoined
  self.nCrossChannelJoinedAuth = nAuth
  UiNotify.OnNotify(UiNotify.emNOTIFY_CHAT_CROSS_HOST)
end
function ChatMgr:OnSyncCurCrossHostInfo(tbHostInfo)
  self.tbCurHostInfo = tbHostInfo
  self.bHasHost = next(tbHostInfo or {}) and true or false
  UiNotify.OnNotify(UiNotify.emNOTIFY_CHAT_CROSS_HOST)
end
function ChatMgr:GetCurCrossHostInfo()
  local tbCurHostInfo = self.tbCurHostInfo and self.tbCurHostInfo[1]
  if tbCurHostInfo then
    local tbFollowingMap = ChatMgr:GetCrossHostFollowMap(me)
    return tbCurHostInfo.szName, tbCurHostInfo.nPlayerId, tbCurHostInfo.szHeadUrl, tbFollowingMap[tbCurHostInfo.nPlayerId or 0]
  end
end
function ChatMgr:HasJoinedCrossChannel()
  return self.bHasJoinedCrossChannel or false, self.nCrossChannelJoinedAuth == ChatMgr.ChatCrossAuthType.emHost
end
function ChatMgr:AskCrossHostListInfo()
  RemoteServer.DoChatRequest("Ask4CrossHostList", self.nHostInfoListVersion)
end
function ChatMgr:OnSynChatHostList(tbHostSchedule, tbHostScheduleDetail, nHostListVersion)
  self.tbHostListInfo = tbHostSchedule
  for _, tbInfo in ipairs(self.tbHostListInfo) do
    local tbDetail = tbHostScheduleDetail[tbInfo.PlayerId]
    if tbDetail then
      tbInfo.Name = tbDetail.Name
      tbInfo.HeadUrl = tbDetail.HeadUrl
      tbInfo.Signature = tbDetail.Signature
      tbInfo.DateDesc, tbInfo.TimeDesc = unpack(Lib:SplitStr(tbInfo.TimeDesc or "", "\\n"))
    end
  end
  self.nHostInfoListVersion = nHostListVersion
  UiNotify.OnNotify(UiNotify.emNOTIFY_CHAT_CROSS_HOST, "HostList")
end
function ChatMgr:GetHostListInfo()
  local nNow = GetTime()
  local tbHostList = {}
  for _, tbInfo in ipairs(self.tbHostListInfo or {}) do
    if not tbInfo.TimeOut or nNow < tbInfo.TimeOut then
      table.insert(tbHostList, tbInfo)
    end
  end
  return tbHostList
end
function ChatMgr:FollowHostOpt(nHostId, bFollow)
  RemoteServer.DoChatRequest("FollowHostOpt", nHostId, bFollow)
end
function ChatMgr:OnHostFollowChanged()
  UiNotify.OnNotify(UiNotify.emNOTIFY_CHAT_CROSS_HOST, "HostList")
end
function ChatMgr:GetGVoiceParam()
  return self.szGVoiceAppId, self.szGVoiceAppKey, Sdk:GetUid()
end
function ChatMgr:OnTryReJoinRoom()
  self:StartEnterRoom()
end
function ChatMgr:OnSyncGVoiceParam(szGVoiceAppId, szGVoiceAppKey)
  self.szGVoiceAppId = szGVoiceAppId
  self.szGVoiceAppKey = szGVoiceAppKey
end
