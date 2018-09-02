Require("CommonScript/ChatDef.lua")
Require("CommonScript/GiftSystem/Gift.lua")
Require("CommonScript/Kin/KinDef.lua")
ChatMgr.ChatDecorate = ChatMgr.ChatDecorate or {}
local ChatDecorate = ChatMgr.ChatDecorate
ChatDecorate.PartsType = {HEAD_FRAME = 1, BUBBLE = 2}
ChatDecorate.tbChatDecorateSetting = {
  [ChatDecorate.PartsType.HEAD_FRAME] = {
    nSaveKey = ChatMgr.CHAT_BACKGROUND_USERVAULE_HEAD,
    szFnCur = "GetCurHeadFrame"
  },
  [ChatDecorate.PartsType.BUBBLE] = {
    nSaveKey = ChatMgr.CHAT_BACKGROUND_USERVAULE_CHAT,
    szFnCur = "GetCurBubble"
  }
}
ChatDecorate.tbTheme = ChatDecorate.tbTheme or {}
ChatDecorate.tbParts = ChatDecorate.tbParts or {}
ChatDecorate.Valid_Type = {FOREVER = -1, NONE = 0}
ChatDecorate.Condition = {
  Vip = {
    fnCheckValid = function(pPlayer, szVip)
      local nNeedVip = szVip and tonumber(szVip)
      return nNeedVip and nNeedVip <= pPlayer.GetVipLevel()
    end
  },
  KinMascot = {
    fnCheckValid = function(pPlayer)
      if MODULE_GAMESERVER then
        return Kin:GetPlayerCareer(pPlayer.dwID) == Kin.Def.Career_Mascot
      else
        local tbCareers = Kin:GetMemberCareer() or {}
        local nCareer = tbCareers[pPlayer.dwID] or -1
        return nCareer == Kin.Def.Career_Mascot
      end
    end,
    fnCheckOverdure = function(pPlayer)
      for _, nType in pairs(ChatDecorate.PartsType) do
        local tbSetting = ChatDecorate.tbChatDecorateSetting[nType]
        local nCurPartsID = ChatDecorate[tbSetting.szFnCur](ChatDecorate, pPlayer)
        if not ChatDecorate:CheckDefault(nCurPartsID) then
          local tbPartsInfo = ChatDecorate:GetPartsInfo(nCurPartsID)
          local tbTheme = ChatDecorate:GetThemeInfo(tbPartsInfo.nThemeID)
          if tbTheme.szCondition == "KinMascot" then
            if MODULE_GAMESERVER then
              local bReset = Kin:GetPlayerCareer(pPlayer.dwID) ~= Kin.Def.Career_Mascot
              if bReset then
                pPlayer.SetUserValue(ChatMgr.CHAT_BACKGROUND_USERVAULE_GROUP, tbSetting.nSaveKey, 0)
                Log("[ChatDecorate] fnCheckOverdure KinMascot reset default", pPlayer.dwID, pPlayer.szName, nCurPartsID, tbPartsInfo.nThemeID)
              end
            else
              local tbCareers = Kin:GetMemberCareer() or {}
              local nCareer = tbCareers[pPlayer.dwID] or -1
              return nCareer ~= Kin.Def.Career_Mascot
            end
          end
        end
      end
    end
  }
}
function ChatDecorate:LoadSetting()
  self.Default = {}
  local szThemeTabPath = "Setting/Chat/ChatDecorate/ChatTheme.tab"
  local szThemeParamType = "dddssssssdddddddd"
  local szThemeKey = "nThemeID"
  local tbThemeParams = {
    "nThemeID",
    "nDefault",
    "nSort",
    "szTitle",
    "szGet",
    "szCondition",
    "szParam",
    "szGirlGet",
    "szGirlTitle",
    "version_tx",
    "version_vn",
    "version_hk",
    "version_tw",
    "version_xm",
    "version_en",
    "version_kor",
    "version_th"
  }
  local tbTheme = LoadTabFile(szThemeTabPath, szThemeParamType, szThemeKey, tbThemeParams)
  local szPartsTabPath = "Setting/Chat/ChatDecorate/ChatParts.tab"
  local szPartsParamType = "ddddd"
  local szPartsKey = "nPartsID"
  local tbPartsParams = {
    "nPartsID",
    "nThemeID",
    "nType",
    "nIcon",
    "nGirlIcon"
  }
  local tbParts = LoadTabFile(szPartsTabPath, szPartsParamType, szPartsKey, tbPartsParams)
  local tbTempTheme = {}
  for nPartsID, tbInfo in pairs(tbParts) do
    assert(not ChatDecorate.tbParts[nPartsID], "[ChatDecorate] assert fail parts fail")
    assert(tbInfo.nType == ChatDecorate.PartsType.HEAD_FRAME or tbInfo.nType == ChatDecorate.PartsType.BUBBLE, "[ChatDecorate] assert fail PartsType fail")
    assert(tbTheme[tbInfo.nThemeID], "[ChatDecorate] assert fail parts no theme fail")
    if self:CheckVersion(tbTheme[tbInfo.nThemeID]) then
      if tbTheme[tbInfo.nThemeID].nDefault == 1 then
        ChatDecorate.Default[tbInfo.nType] = ChatDecorate.Default[tbInfo.nType] or {}
        assert(not ChatDecorate.Default[tbInfo.nType].nIcon, "[ChatDecorate] assert fail repeat default theme")
        ChatDecorate.Default[tbInfo.nType].nIcon = tbInfo.nIcon
        assert(not ChatDecorate.Default[tbInfo.nType].nPartsID, "[ChatDecorate] assert fail repeat default theme")
        ChatDecorate.Default[tbInfo.nType].nPartsID = nPartsID
      end
      ChatDecorate.tbParts[nPartsID] = {}
      ChatDecorate.tbParts[nPartsID].nThemeID = tbInfo.nThemeID
      ChatDecorate.tbParts[nPartsID].nType = tbInfo.nType
      ChatDecorate.tbParts[nPartsID].nIcon = tbInfo.nIcon
      ChatDecorate.tbParts[nPartsID].nDefault = tbTheme[tbInfo.nThemeID].nDefault
      ChatDecorate.tbParts[nPartsID].nGirlIcon = tbInfo.nGirlIcon
      tbTempTheme[tbInfo.nThemeID] = tbTempTheme[tbInfo.nThemeID] or {}
      tbTempTheme[tbInfo.nThemeID][tbInfo.nType] = nPartsID
    end
  end
  for nThemeID, tbInfo in pairs(tbTheme) do
    if self:CheckVersion(tbInfo) then
      assert(not ChatDecorate.tbTheme[nThemeID], "[ChatDecorate] assfail theme fail")
      ChatDecorate.tbTheme[nThemeID] = {}
      ChatDecorate.tbTheme[nThemeID].szTitle = tbInfo.szTitle
      ChatDecorate.tbTheme[nThemeID].szGet = tbInfo.szGet
      ChatDecorate.tbTheme[nThemeID].szCondition = tbInfo.szCondition
      ChatDecorate.tbTheme[nThemeID].szParam = tbInfo.szParam
      ChatDecorate.tbTheme[nThemeID].nDefault = tbInfo.nDefault
      ChatDecorate.tbTheme[nThemeID].tbParts = tbTempTheme[nThemeID]
      ChatDecorate.tbTheme[nThemeID].szGirlGet = tbInfo.szGirlGet
      ChatDecorate.tbTheme[nThemeID].szGirlTitle = tbInfo.szGirlTitle
      ChatDecorate.tbTheme[nThemeID].nThemeID = nThemeID
      ChatDecorate.tbTheme[nThemeID].nSort = tbInfo.nSort or 0
    end
  end
end
function ChatDecorate:CheckVersion(tbInfo)
  if tbInfo.version_tx == 1 and version_tx or tbInfo.version_vn == 1 and version_vn or tbInfo.version_hk == 1 and version_hk or tbInfo.version_tw == 1 and version_tw or tbInfo.version_xm == 1 and version_xm or tbInfo.version_en == 1 and version_en or tbInfo.version_kor == 1 and version_kor or tbInfo.version_th == 1 and version_th then
    return true
  end
  return false
end
function ChatDecorate:GetAllShowTheme(pPlayer, bCan)
  local tbTheme = {}
  local tbFlag = {}
  for nThemeID, tbInfo in pairs(ChatDecorate.tbTheme) do
    if bCan then
      for _, nPartsID in pairs(tbInfo.tbParts) do
        if not tbFlag[nThemeID] and self:CanApply(pPlayer, nPartsID) then
          table.insert(tbTheme, tbInfo)
          tbFlag[nThemeID] = true
        end
      end
    else
      table.insert(tbTheme, tbInfo)
      tbFlag[nThemeID] = true
    end
  end
  local fnSort = function(a, b)
    return a.nSort < b.nSort
  end
  if #tbTheme > 1 then
    table.sort(tbTheme, fnSort)
  end
  return tbTheme
end
if not next(ChatDecorate.tbTheme) then
  ChatDecorate:LoadSetting()
end
function ChatDecorate:CheckConditionOverdure(pPlayer)
  for szKey, tbCondition in pairs(ChatDecorate.Condition) do
    if tbCondition.fnCheckOverdure then
      if MODULE_GAMESERVER then
        tbCondition.fnCheckOverdure(pPlayer)
      else
        return tbCondition.fnCheckOverdure(pPlayer)
      end
    end
  end
end
function ChatDecorate:GetIcon(nFaction, nPartsID)
  local tbPartsInfo = ChatDecorate:GetPartsInfo(nPartsID)
  local nIcon = tbPartsInfo.nIcon
  if self:CheckDefault(nPartsID) then
    return nIcon
  end
  if self:CheckSexIcon(nPartsID) then
    local nSex = Gift:CheckSex(nFaction)
    if nSex and nSex == Gift.Sex.Girl then
      nIcon = tbPartsInfo.nGirlIcon
    end
  end
  return nIcon
end
function ChatDecorate:CanApply(pPlayer, nPartsID)
  local tbPartsInfo = ChatDecorate.tbParts[nPartsID]
  if not tbPartsInfo then
    return false, XT("找不到应用数据？？")
  end
  local nThemeID = tbPartsInfo.nThemeID
  local tbThemeInfo = ChatDecorate.tbTheme[nThemeID]
  if not tbThemeInfo then
    return false, XT("找不到主题？？")
  end
  if self:CheckDefault(nPartsID) then
    return true
  end
  local tbCondition = ChatDecorate.Condition[tbThemeInfo.szCondition]
  if tbCondition and tbCondition.fnCheckValid then
    return tbCondition.fnCheckValid(pPlayer, tbThemeInfo.szParam)
  end
  local nCurTime = ValueItem.ValueDecorate:GetValue(pPlayer, nThemeID)
  if nCurTime == ChatDecorate.Valid_Type.FOREVER then
    return true
  end
  if nCurTime < GetTime() then
    return false, XT(string.format("请先获得%s主题,或该主题已经过期", self:GetTitleByThemeId(nThemeID, pPlayer.nFaction) or ""))
  end
  return true
end
function ChatDecorate:CheckValidTime(pPlayer)
  local tbReset
  for _, nType in pairs(ChatDecorate.PartsType) do
    local tbSetting = self.tbChatDecorateSetting[nType]
    local nCurPartsID = ChatDecorate[tbSetting.szFnCur](self, pPlayer)
    if not ChatDecorate:CheckDefault(nCurPartsID) then
      local tbPartsInfo = ChatDecorate:GetPartsInfo(nCurPartsID)
      local tbTheme = self:GetThemeInfo(tbPartsInfo.nThemeID)
      local nThemeID = tbPartsInfo.nThemeID
      local nTime = ValueItem.ValueDecorate:GetValue(pPlayer, nThemeID)
      if tbTheme.szCondition == "" and nTime ~= ChatDecorate.Valid_Type.FOREVER and nTime < GetTime() then
        tbReset = tbReset or {}
        tbReset[nType] = true
      end
    end
  end
  return tbReset
end
function ChatDecorate:CheckTimeOverdue(pPlayer)
  local tbOverdue
  local tbThmeValue = ValueItem.ValueDecorate:GetAllValue(pPlayer)
  for nThemeID, nTime in pairs(tbThmeValue) do
    if nTime ~= ChatDecorate.Valid_Type.FOREVER and nTime ~= 0 and nTime < GetTime() then
      tbOverdue = tbOverdue or {}
      tbOverdue[nThemeID] = nTime
    end
  end
  return tbOverdue
end
function ChatDecorate:GetTips(nPartsID, nFaction)
  local tbPartsInfo = self:GetPartsInfo(nPartsID)
  local tbTheme = self:GetThemeInfo(tbPartsInfo.nThemeID)
  local bSex = self:CheckSexIcon(nPartsID)
  local szTip = tbTheme.szGet
  if bSex then
    local nSex = Gift:CheckSex(nFaction)
    if nSex and nSex == Gift.Sex.Girl and tbTheme.szGirlGet ~= "" then
      szTip = tbTheme.szGirlGet
    end
  end
  return szTip
end
function ChatDecorate:GetTitle(nPartsID, nFaction)
  local tbPartsInfo = self:GetPartsInfo(nPartsID)
  local tbTheme = self:GetThemeInfo(tbPartsInfo.nThemeID)
  local bSex = self:CheckSexIcon(nPartsID)
  local szTitle = tbTheme.szTitle
  if bSex then
    local nSex = Gift:CheckSex(nFaction)
    if nSex and nSex == Gift.Sex.Girl and tbTheme.szGirlTitle ~= "" then
      szTitle = tbTheme.szGirlTitle
    end
  end
  return szTitle
end
function ChatDecorate:GetTitleByThemeId(nThemeID, nFaction)
  local tbTheme = self:GetThemeInfo(nThemeID)
  local szTitle = tbTheme.szTitle
  local nSex = Gift:CheckSex(nFaction)
  if nSex and nSex == Gift.Sex.Girl and tbTheme.szGirlTitle ~= "" then
    szTitle = tbTheme.szGirlTitle
  end
  return szTitle
end
function ChatDecorate:CheckVip(nVipLevel)
  for _, tbInfo in pairs(ChatDecorate.tbTheme) do
    if tbInfo.szCondition == "Vip" then
      local nVip = tonumber(tbInfo.szParam)
      if nVip and nVip == nVipLevel then
        return true
      end
    end
  end
end
function ChatDecorate:CheckMatch(nType, nPartsID)
  local tbPartsInfo = ChatDecorate.tbParts[nPartsID]
  if not tbPartsInfo then
    return false
  end
  return tbPartsInfo.nType == nType
end
function ChatDecorate:CheckDefault(nPartsID)
  return ChatDecorate.tbParts[nPartsID] and ChatDecorate.tbParts[nPartsID].nDefault == 1
end
function ChatDecorate:CheckSexIcon(nPartsID)
  return ChatDecorate.tbParts[nPartsID] and ChatDecorate.tbParts[nPartsID].nGirlIcon > 0
end
function ChatDecorate:GetThemeInfo(nThemeID)
  return ChatDecorate.tbTheme[nThemeID]
end
function ChatDecorate:GetPartsInfo(nPartsID)
  return ChatDecorate.tbParts[nPartsID]
end
function ChatDecorate:GetCurHeadFrame(pPlayer)
  local nCurHeadFrame = pPlayer.GetUserValue(ChatMgr.CHAT_BACKGROUND_USERVAULE_GROUP, ChatMgr.CHAT_BACKGROUND_USERVAULE_HEAD)
  return nCurHeadFrame == 0 and self.Default[ChatDecorate.PartsType.HEAD_FRAME].nPartsID or nCurHeadFrame
end
function ChatDecorate:GetCurBubble(pPlayer)
  local nCurBubble = pPlayer.GetUserValue(ChatMgr.CHAT_BACKGROUND_USERVAULE_GROUP, ChatMgr.CHAT_BACKGROUND_USERVAULE_CHAT)
  return nCurBubble == 0 and self.Default[ChatDecorate.PartsType.BUBBLE].nPartsID or nCurBubble
end
