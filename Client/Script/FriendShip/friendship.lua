local emFriendData_Type = FriendShip.tbDataType.emFriendData_Type
local emFriendData_Imity = FriendShip.tbDataType.emFriendData_Imity
local emFriendData_Enemy_Left = FriendShip.tbDataType.emFriendData_Enemy_Left
local emFriendData_Enemy_Right = FriendShip.tbDataType.emFriendData_Enemy_Right
local emFriendData_BlackOrRequest = FriendShip.tbDataType.emFriendData_BlackOrRequest
local emFriendData_Temp_Refuse = FriendShip.tbDataType.emFriendData_Temp_Refuse
local emFriendData_WeddingState = FriendShip.tbDataType.emFriendData_WeddingState
local emFriendData_WeddingTime = FriendShip.tbDataType.emFriendData_WeddingTime
local emFriend_Type_Invalid = FriendShip.tbDataVal.emFriend_Type_Invalid
local emFriend_Type_Friend = FriendShip.tbDataVal.emFriend_Type_Friend
local emFriend_Type_Black_Left = FriendShip.tbDataVal.emFriend_Type_Black_Left
local emFriend_Type_Black_Right = FriendShip.tbDataVal.emFriend_Type_Black_Right
local emFriend_Type_Black_Both = FriendShip.tbDataVal.emFriend_Type_Black_Both
local emFriend_Type_Request_Left = FriendShip.tbDataVal.emFriend_Type_Request_Left
local emFriend_Type_Request_Right = FriendShip.tbDataVal.emFriend_Type_Request_Right
function FriendShip:OnSynFriendShipData(dwID, nFaction, nLevel, szName, nState, nPortrait, dwKinId, szKinName, nHonorLevel, emType, emImity, emEnemy_Left, emEnemy_Right, emBlackOrRequest, emTemp_Refuse, nWeddingState, nWeddingTime, nVipLevel)
  local bModify = self.tbAllData[dwID] and self.tbAllData[dwID][emFriendData_Type] == emType and emType ~= 0 and true or false
  self.tbAllData[dwID] = {
    dwID = dwID,
    nFaction = nFaction,
    nLevel = nLevel,
    szName = szName,
    nState = nState,
    nPortrait = nPortrait,
    dwKinId = dwKinId,
    szKinName = szKinName,
    nHonorLevel = nHonorLevel,
    nImity = emImity,
    nVipLevel = nVipLevel,
    nHate = dwID > me.dwID and emEnemy_Left or emEnemy_Right
  }
  local tbData = self.tbAllData[dwID]
  tbData[emFriendData_Type] = emType
  tbData[emFriendData_Imity] = emImity
  tbData[emFriendData_Enemy_Left] = emEnemy_Left
  tbData[emFriendData_Enemy_Right] = emEnemy_Right
  tbData[emFriendData_BlackOrRequest] = emBlackOrRequest
  tbData[emFriendData_WeddingState] = nWeddingState
  tbData[emFriendData_WeddingTime] = nWeddingTime
  if emImity ~= 0 then
    local nImityLevel, nMaxImity = FriendShip:GetImityLevel(emImity)
    tbData.nImityLevel = nImityLevel
    tbData.nMaxImity = nMaxImity
    if self.tbMyBlackList[dwID] then
      FriendShip:DelBlack(dwID)
    end
  end
  if FriendShip:IsMeRequested(me.dwID, dwID, self.tbAllData[dwID]) and self:IsHeInMyBlack(dwID) then
    RemoteServer.RefuseAddFriend(dwID)
  end
  if FriendShip:IsHeIsMyEnemy(me.dwID, dwID, self.tbAllData[dwID]) then
    Guide.tbNotifyGuide:StartNotifyGuide("Enemy")
  end
  self.nVersion = self.nVersion + 1
  UiNotify.OnNotify(UiNotify.emNoTIFY_SYNC_FRIEND_DATA, bModify and dwID or nil)
end
function FriendShip:InitBlackList()
  local tbMyBlack = Client:GetUserInfo("BlackList")
  self.tbMyBlackList = tbMyBlack
end
function FriendShip:CheckWhenOpenUi()
  self:CheckImitiyAchieve()
  if self.nServerFriendNum then
    local tbAllFriend = FriendShip:GetAllFriendData()
    if #tbAllFriend < self.nServerFriendNum - 10 then
      local nNow = GetTime()
      if not self.nLastClientRequestSynTime or nNow - self.nLastClientRequestSynTime > 60 then
        self.nLastClientRequestSynTime = nNow
        RemoteServer.RequestSynAllFriendData(#tbAllFriend)
      end
    end
  end
end
function FriendShip:CheckImitiyAchieve()
  if self.nCheckImityAchieveVersion == self.nVersion then
    return
  end
  self.nCheckImityAchieveVersion = self.nVersion
  local nImityCheckAcheLevel = Achievement:GetCompletedLevel(me, "Friend") + 1
  local nCheckLevel = self.tbImityAchivementLevel[nImityCheckAcheLevel]
  local tbAllFriendData = self:GetAllFriendData()
  if nCheckLevel then
    local nCurCount = Achievement:GetSubKindCount(me, "Friend_" .. nImityCheckAcheLevel)
    if nCurCount == 0 then
      local tbVaildFriendIds = {}
      for i, v in ipairs(tbAllFriendData) do
        if nCheckLevel <= v.nImityLevel then
          table.insert(tbVaildFriendIds, v.dwID)
          if #tbVaildFriendIds == 3 then
            break
          end
        end
      end
      if next(tbVaildFriendIds) then
        RemoteServer.TryCheckImityAchievement(nImityCheckAcheLevel, tbVaildFriendIds)
        return
      end
    end
  end
  local nImityCheckAcheLevel = Achievement:GetCompletedLevel(me, "FriendFamiliar") + 1
  local nCheckLevel = self.tbImityAchivementLevel[nImityCheckAcheLevel]
  if nCheckLevel then
    local tbVaildFriendIds = {}
    for i, v in ipairs(tbAllFriendData) do
      if nCheckLevel <= v.nImityLevel then
        table.insert(tbVaildFriendIds, v.dwID)
        if #tbVaildFriendIds == 3 then
          break
        end
      end
    end
    local nCurCount = Achievement:GetSubKindCount(me, "FriendFamiliar_" .. nImityCheckAcheLevel)
    if nCurCount ~= #tbVaildFriendIds then
      RemoteServer.TryCheckImityAchievement(nImityCheckAcheLevel, tbVaildFriendIds)
      return
    end
  end
end
function FriendShip:DelBlack(dwRoleId2)
  self.tbMyBlackList[dwRoleId2] = nil
  Client:SaveUserInfo()
end
function FriendShip:AddBlack(dwRoleId2, tbRoleInfo)
  if dwRoleId2 == me.dwID then
    return
  end
  self.tbAllData[dwRoleId2] = nil
  self.tbMyBlackList[dwRoleId2] = tbRoleInfo
  Client:SaveUserInfo()
  self.nVersion = self.nVersion + 1
  ChatMgr.PrivateChatUnReadCache[dwRoleId2] = nil
  ChatMgr.PrivateChatReadCache[dwRoleId2] = nil
  ChatMgr:RemoveRecentPrivateTarget(dwRoleId2)
  UiNotify.OnNotify(UiNotify.emNoTIFY_NEW_PRIVATE_MSG)
  UiNotify.OnNotify(UiNotify.emNoTIFY_SYNC_FRIEND_DATA)
end
function FriendShip:GetBlackList()
  local tbBlackList = {}
  for _, tbInfo in pairs(self.tbMyBlackList or {}) do
    table.insert(tbBlackList, tbInfo)
  end
  return tbBlackList
end
function FriendShip:IsHeInMyBlack(dwRoleId2)
  return self.tbMyBlackList[dwRoleId2]
end
function FriendShip:GetOnlineNotice(nPlayerId, szName)
  local nMarrySex = me.GetUserValue(Wedding.nSaveGrp, Wedding.nSaveKeyGender)
  local szTitle = "爱人"
  if Wedding:IsEngaged(me.dwID, nPlayerId) then
    local tbSexTitle = {
      [Gift.Sex.Boy] = "未婚妻",
      [Gift.Sex.Girl] = "未婚夫"
    }
    szTitle = tbSexTitle[nMarrySex] or szTitle
    return string.format("您的%s「%s」上线了", szTitle, szName)
  elseif Wedding:IsLover(me.dwID, nPlayerId) then
    local tbSexTitle = {
      [Gift.Sex.Boy] = "娘子",
      [Gift.Sex.Girl] = "夫君"
    }
    szTitle = tbSexTitle[nMarrySex] or szTitle
    return string.format("您的%s「%s」上线了", szTitle, szName)
  end
  if TeacherStudent:IsMyTeacher(nPlayerId) then
    return string.format("您的师父「%s」上线了", szName)
  elseif TeacherStudent:IsMyStudent(nPlayerId) then
    return string.format("您的徒弟「%s」上线了", szName)
  end
  return string.format("您的好友「%s」上线了", szName)
end
function FriendShip:OnFriendOnLine(dwFriendId)
  local tbRoleInfo = self:GetFriendDataInfo(dwFriendId)
  if not tbRoleInfo then
    return
  end
  tbRoleInfo.nState = 2
  self.nVersion = self.nVersion + 1
  UiNotify.OnNotify(UiNotify.emNoTIFY_SYNC_FRIEND_DATA, dwFriendId)
  local szNotice = self:GetOnlineNotice(dwFriendId, tbRoleInfo.szName)
  me.Msg(szNotice)
end
function FriendShip:OnFriendOffline(dwFriendId)
  local tbRoleInfo = self:GetFriendDataInfo(dwFriendId)
  if not tbRoleInfo then
    return
  end
  tbRoleInfo.nState = 0
  self.nVersion = self.nVersion + 1
  UiNotify.OnNotify(UiNotify.emNoTIFY_SYNC_FRIEND_DATA, dwFriendId)
end
function FriendShip:BeginLoadFriendData(dwRoleId)
  self.tbAllData = {}
  self.tbAllFriendData = nil
  self.tbAllRequestData = nil
  self.tbAllEnemyData = nil
  self.dwMarriageRoleId = 0
end
function FriendShip:EndLoadFriendData(dwRoleId, nServerFriendNum)
  self.nServerFriendNum = nServerFriendNum
end
function FriendShip:GetFriendDataInfo(dwRoleId)
  return self.tbAllData[dwRoleId]
end
function FriendShip:GetAllFriendData(bNoSort)
  if self.tbAllFriendData and self.nAllFriendDataVersion == self.nVersion then
    return self.tbAllFriendData
  end
  if bNoSort and self.tbAllFriendData then
    for i, v in ipairs(self.tbAllFriendData) do
      self.tbAllFriendData[i] = self.tbAllData[v.dwID]
    end
    return self.tbAllFriendData
  end
  local tbFriends = {}
  self.dwMarriageRoleId = 0
  for k, v in pairs(self.tbAllData) do
    if v[emFriendData_Type] == emFriend_Type_Friend then
      table.insert(tbFriends, v)
    end
    if v[emFriendData_WeddingState] ~= 0 then
      self.dwMarriageRoleId = v.dwID
    end
  end
  self.tbAllFriendData = tbFriends
  self.nAllFriendDataVersion = self.nVersion
  return self.tbAllFriendData
end
function FriendShip:GetMarriageRoleId()
  self:GetAllFriendData()
  return self.dwMarriageRoleId
end
function FriendShip:GetAllFriendRequestData()
  if self.tbAllRequestData and self.nAllRequestDataVersion == self.nVersion then
    return self.tbAllRequestData
  end
  local tbFriends = {}
  for k, v in pairs(self.tbAllData) do
    if k > me.dwID and v[emFriendData_BlackOrRequest] == emFriend_Type_Request_Right or k < me.dwID and v[emFriendData_BlackOrRequest] == emFriend_Type_Request_Left then
      table.insert(tbFriends, v)
    end
  end
  self.tbAllRequestData = tbFriends
  self.nAllRequestDataVersion = self.nVersion
  return self.tbAllRequestData
end
function FriendShip:GetAllEnemyData()
  if self.tbAllEnemyData and self.nAllEnemyDataVersion == self.nVersion then
    return self.tbAllEnemyData
  end
  local tbFriends = {}
  for k, v in pairs(self.tbAllData) do
    if k > me.dwID and v[emFriendData_Enemy_Left] and v[emFriendData_Enemy_Left] > 0 or k < me.dwID and v[emFriendData_Enemy_Right] and v[emFriendData_Enemy_Right] > 0 then
      table.insert(tbFriends, v)
    end
  end
  self.tbAllEnemyData = tbFriends
  self.nAllEnemyDataVersion = self.nVersion
  return self.tbAllEnemyData
end
function FriendShip:AddOrDelFriend(tbRoleInfo)
  if me.nLevel < FriendShip.SHOW_LEVEL then
    me.CenterMsg(string.format("%d级后才开放好友系统", FriendShip.SHOW_LEVEL))
    return
  end
  local tbFriendData = self:GetFriendDataInfo(tbRoleInfo.dwID)
  if tbFriendData and tbFriendData[emFriendData_Type] == emFriend_Type_Friend then
    self:RequetDelFriend(tbRoleInfo.dwID, tbFriendData)
  else
    self:OpenAddFriendUI(tbRoleInfo)
  end
end
function FriendShip:BlackHim(dwRoleId2)
  if dwRoleId2 == me.dwID then
    me.CenterMsg("不能拉黑自己")
    return
  end
  local tbFriendData = self:GetFriendDataInfo(dwRoleId2)
  if FriendShip:IsHeInMyBlack(dwRoleId2) then
    me.CenterMsg("对方已经在您的黑名单列表中了")
    return
  end
  local function fnAgreeBlackHim()
    RemoteServer.RequestBlackHim(dwRoleId2)
  end
  local szMsg = "确定要将对方加入您的黑名单列表中吗？"
  if FriendShip:IsFriend(me.dwID, dwRoleId2, tbFriendData) then
    szMsg = string.format("[FFFE0D]%s[-] 是你的好友，确定要拉黑他吗？\n[FFFE0D]（拉黑后双方解除好友关系）[-]", tbFriendData.szName)
  end
  Ui:OpenWindow("MessageBox", szMsg, {
    {fnAgreeBlackHim},
    {}
  }, {"同意", "取消"})
end
function FriendShip:OpenAddFriendUI(tbRoleInfo)
  if me.nLevel < FriendShip.SHOW_LEVEL then
    me.CenterMsg(string.format("%d级开放好友系统", FriendShip.SHOW_LEVEL))
    return
  end
  local function fnAgree()
    return FriendShip:RequetAddFriend(tbRoleInfo.dwID)
  end
  Ui:OpenWindow("MessageBox", string.format("申请添加 [FFFE0D]%s[-] 为好友", tbRoleInfo.szName), {
    {fnAgree},
    {}
  }, {"确认", "取消"})
end
function FriendShip:RequetAddFriend(dwRoleId2, tbFriendData)
  local dwRoleId1 = me.dwID
  if dwRoleId1 == dwRoleId2 then
    me.CenterMsg("不能添加自己为好友")
    return
  end
  tbFriendData = tbFriendData or self:GetFriendDataInfo(dwRoleId2)
  if not tbFriendData then
    RemoteServer.RequestAddFriend(dwRoleId2)
    return
  end
  if FriendShip:IsFriend(dwRoleId1, dwRoleId2, tbFriendData) then
    me.CenterMsg("你们已经是好友关系了")
    return
  end
  if FriendShip:IsInHisTempRefuse(dwRoleId1, dwRoleId2, tbFriendData) then
    me.CenterMsg("添加好友请求已发出，请等待对方回应")
    return
  end
  if FriendShip:IsRequestedAdd(dwRoleId1, dwRoleId2, tbFriendData) then
    me.CenterMsg("添加好友请求已发出，请等待对方回应")
    return
  end
  if FriendShip:IsHeIsMyEnemy(dwRoleId1, dwRoleId2, tbFriendData) then
    local function fnDelay()
      local function fnAgree()
        RemoteServer.RequestAddFriend(dwRoleId2)
      end
      Ui:OpenWindow("MessageBox", string.format("[FFFE0D]%s[-] 是你的仇人，是否要继续添加他为好友？成功添加为好友后将自动解除仇人关系。", tbFriendData.szName), {
        {fnAgree},
        {}
      }, {"同意", "取消"})
      return 0
    end
    Timer:Register(2, fnDelay)
    return
  end
  if FriendShip:IsHeInMyBlack(dwRoleId2) then
    local function fnDelay()
      local function fnAgree()
        self:DelBlack(dwRoleId2)
        RemoteServer.RequestAddFriend(dwRoleId2)
      end
      Ui:OpenWindow("MessageBox", string.format("[FFFE0D]%s[-] 在您的黑名单中，是否要解除对他的屏蔽且申请添加为好友？", tbFriendData.szName), {
        {fnAgree},
        {}
      }, {"同意", "取消"})
      return 0
    end
    Timer:Register(2, fnDelay)
    return
  end
  if FriendShip:IsMeRequested(dwRoleId1, dwRoleId2, tbFriendData) then
    local function fnDelay()
      local function fnAgree()
        RemoteServer.AcceptFriendRequest(dwRoleId2)
      end
      Ui:OpenWindow("MessageBox", string.format("[FFFE0D]%s[-] 已经对您发送了好友申请，确定直接完成添加", tbFriendData.szName), {
        {fnAgree},
        {}
      }, {"同意", "取消"})
      return 0
    end
    Timer:Register(2, fnDelay)
    return
  end
  RemoteServer.RequestAddFriend(dwRoleId2)
  return
end
function FriendShip:AcceptFriendRequest(dwRoleId2, tbFriendData)
  Log("FriendShip:AcceptFriendRequest", dwRoleId2)
  local dwRoleId1 = me.dwID
  if dwRoleId1 == dwRoleId2 then
    me.CenterMsg("不能添加自己为好友")
    return
  end
  tbFriendData = tbFriendData or self:GetFriendDataInfo(dwRoleId2)
  if not tbFriendData then
    Log(debug.traceback())
    return
  end
  if tbFriendData[emFriendData_Type] == emFriend_Type_Friend then
    return me.CenterMsg("你们已经是好友了")
  end
  if FriendShip:IsHeIsMyEnemy(dwRoleId1, dwRoleId2, tbFriendData) then
    local function fnAgree()
      RemoteServer.AcceptFriendRequest(dwRoleId2)
    end
    Ui:OpenWindow("MessageBox", string.format("[FFFE0D]%s[-] 是你的仇人，是否要继续添加他为好友？成功添加为好友后将自动解除仇人关系。", tbFriendData.szName), {
      {fnAgree},
      {}
    }, {"同意", "取消"})
    return
  end
  RemoteServer.AcceptFriendRequest(dwRoleId2)
end
function FriendShip:RequetDelFriend(dwRoleId2, tbFriendData)
  local dwRoleId1 = me.dwID
  if dwRoleId1 == dwRoleId2 then
    Log(debug.traceback())
    return
  end
  tbFriendData = tbFriendData or self:GetFriendDataInfo(dwRoleId2)
  if not tbFriendData then
    Log(debug.traceback())
    return
  end
  if tbFriendData[emFriendData_Type] ~= emFriend_Type_Friend then
    Log(debug.traceback())
    return
  end
  if tbFriendData.nImityLevel and tbFriendData.nImityLevel >= 20 then
    do
      local szConfirm = "确认"
      local function fnAgree(szInput)
        if szInput ~= szConfirm then
          me.CenterMsg("输出错误，请仔细阅读提示信息")
          return true
        end
        RemoteServer.RequesDelFriend(dwRoleId2)
      end
      Ui:OpenWindow("MessageBoxInput", string.format("[FFFE0D]%s[-]与你颇有交情，是否断交？\n请在下方输入：[FF0000]%s[-]\n[FFFE0D]提示：亲密度将会清零[-]", tbFriendData.szName, szConfirm), fnAgree)
    end
  else
    local function fnAgree()
      RemoteServer.RequesDelFriend(dwRoleId2)
    end
    Ui:OpenWindow("MessageBox", string.format("确定要和 [FFFE0D]%s[-] 断交吗？\n[FFFE0D]提示：亲密度将会清零[-]", tbFriendData.szName), {
      {fnAgree},
      {}
    }, {"确定", "取消"})
  end
end
function FriendShip:RefuseAllRequet()
  RemoteServer.RefuseAllRequet()
end
function FriendShip:DelEnemy(tbRoleInfo, tbFriendData)
  local dwRoleId1 = me.dwID
  local dwRoleId2 = tbRoleInfo.dwID
  if dwRoleId1 == dwRoleId2 then
    Log(debug.traceback())
    return
  end
  tbFriendData = tbFriendData or self:GetFriendDataInfo(dwRoleId2)
  if not tbFriendData then
    Log(debug.traceback())
    return
  end
  if not FriendShip:IsHeIsMyEnemy(dwRoleId1, dwRoleId2, tbFriendData) then
    me.CenterMsg("他不是你的仇人")
    return
  end
  local function fnAgree()
    RemoteServer.RequesDelEnemy(dwRoleId2)
  end
  Ui:OpenWindow("MessageBox", string.format("确认删除您的仇人 [FFFE0D]%s[-] 吗？", tbRoleInfo.szName), {
    {fnAgree},
    {}
  }, {"同意", "取消"})
end
function FriendShip:DoRevenge(tbRoleInfo, tbFriendData)
  local dwRoleId1 = me.dwID
  local dwRoleId2 = tbRoleInfo.dwID
  if dwRoleId1 == dwRoleId2 then
    Log(debug.traceback())
    return
  end
  tbFriendData = tbFriendData or self:GetFriendDataInfo(dwRoleId2)
  if not tbFriendData then
    Log(debug.traceback())
    return
  end
  if not FriendShip:IsHeIsMyEnemy(dwRoleId1, dwRoleId2, tbFriendData) then
    me.CenterMsg("他不是你的仇人")
    return
  end
  if me.dwKinId ~= 0 and me.dwKinId == tbRoleInfo.dwKinId then
    me.CenterMsg("同家族不能复仇")
    return
  end
  local nNow = GetTime()
  if 0 >= DegreeCtrl:GetDegree(me, "Revenge") then
    me.CenterMsg("今天复仇次数已用完")
    return
  end
  local nCdTime = FriendShip:GetRevengeCDTiem(nNow)
  if nCdTime > 3600 then
    local nRevengeGold = FriendShip:GetRevengeCDMoney(nCdTime)
    if nRevengeGold > me.GetMoney("Gold") then
      me.CenterMsg("你的元宝不足了")
      Ui:OpenWindow("CommonShop", "Recharge", "Recharge")
      return
    end
    local fnAgree = function()
      RemoteServer.RequestClearRevengeTime()
    end
    Ui:OpenWindow("MessageBox", string.format("是否花费%d元宝，清除冷却时间？", nRevengeGold), {
      {fnAgree},
      {}
    }, {"同意", "取消"})
    return
  end
  RemoteServer.RequesDoRevenge(dwRoleId2)
end
function FriendShip:OnClearRevengeTime()
  UiNotify.OnNotify(UiNotify.emNoTIFY_SYNC_FRIEND_DATA)
end
function FriendShip:SyncWantedData(tbData)
  local nNow = GetTime()
  local tbAllData = {}
  for dwSenderID, v1 in pairs(tbData) do
    for dwWantedID, v2 in pairs(v1) do
      if nNow < v2.nEndTime then
        v2.dwSenderID = dwSenderID
        v2.dwWantedID = dwWantedID
        if v2.nCatchEndTime ~= 0 and v2.nCatchEndTime ~= v2.nEndTime then
          local tbCopy = Lib:CopyTB1(v2)
          tbCopy.nEndTime = v2.nCatchEndTime
          table.insert(tbAllData, tbCopy)
          v2.szCactherName = nil
          table.insert(tbAllData, v2)
        else
          table.insert(tbAllData, v2)
        end
      end
    end
  end
  self.tbWantedData = tbAllData
  UiNotify.OnNotify(UiNotify.emNoTIFY_SYNC_FRIEND_DATA)
end
function FriendShip:SyncOneWantedData(tbOneData)
  local tbWantedData = self.tbWantedData
  if #tbWantedData == 0 then
    self.tbWantedData = {tbOneData}
    UiNotify.OnNotify(UiNotify.emNoTIFY_SYNC_FRIEND_DATA)
    return
  end
  local bFind = false
  for i, v in ipairs(tbWantedData) do
    if v.dwSenderID == tbOneData.dwSenderID and v.dwWantedID == tbOneData.dwWantedID and not v.szCactherName then
      bFind = i
    end
  end
  if bFind then
    tbWantedData[bFind] = tbOneData
    Log("Wanted set----------- ")
  else
    table.insert(tbWantedData, tbOneData)
    Log("Wanted add----------- ")
  end
  UiNotify.OnNotify(UiNotify.emNoTIFY_SYNC_FRIEND_DATA)
end
function FriendShip:OnNewWantedMsg(dwWantedId)
  if dwWantedId and self:IsFriend(me.dwID, dwWantedId) then
    return
  end
  Ui:SetRedPointNotify("Wanted")
end
function FriendShip:ClearNewWantedMsg()
  Ui:ClearRedPointNotify("Wanted")
end
function FriendShip:OnRequestAddFriendRes(bRet, szMsg)
  if bRet then
    me.CenterMsg("好友申请发送成功")
    if Ui:WindowVisible("AddFriendPanel") then
      Ui("AddFriendPanel"):ClearAndClose()
    end
  else
    me.CenterMsg(szMsg or "好友申请失败")
  end
end
local fnOnCloseCallback = function()
  AsyncBattle:LeaveBattle()
end
function FriendShip:OnClientRevengeResult(nResult, tbRoleInfo, nMinusHate, nRobCoin)
  Ui:OpenWindow("WantedAccountS", nResult == 1, tbRoleInfo, nMinusHate, {
    "Coin",
    nRobCoin,
    szKindName = "挑战目标"
  }, true, fnOnCloseCallback)
end
function FriendShip:OnClientWantedResult(nResult, tbRoleInfo, nMinusHate, nRobCoin)
  Ui:OpenWindow("WantedAccountS", nResult == 1, tbRoleInfo, nMinusHate, {
    "Coin",
    nRobCoin,
    szKindName = "挑战目标"
  }, true, fnOnCloseCallback)
end
function FriendShip:InitData()
  self:Init()
  self.tbAllData = {}
  self.nVersion = 0
  self.tbWantedData = {}
  self.tbMyBlackList = {}
  self.tbPlatFriendsInfo = {}
  self.nEndLoadTime = nil
end
if not FriendShip.tbAllData then
  FriendShip:InitData()
end
function FriendShip:GetPlatFriendsInfo()
  return self.tbPlatFriendsInfo
end
function FriendShip:SetPlatFriendsInfo(tbPlatFriendsInfo)
  self.tbPlatFriendsInfo = {}
  local tbUniqueMap = {}
  for _, tbInfo in pairs(tbPlatFriendsInfo) do
    if not tbUniqueMap[tbInfo.szOpenId] then
      tbUniqueMap[tbInfo.szOpenId] = true
      table.insert(self.tbPlatFriendsInfo, tbInfo)
      if tbInfo.szOpenId == Sdk:GetUid() then
        self.tbMyPlatInfo = tbInfo
      end
    end
  end
end
function FriendShip:GetFriendPresentGiven(szOpenId)
  local tbPlatFriendData = Client:GetDirFileData("PlatFriend" .. Sdk:GetUid())
  local tbGiftInfo = tbPlatFriendData.tbGiftInfo
  local nToday = Lib:GetLocalDay()
  if not tbGiftInfo or nToday ~= tbPlatFriendData.nGiftInfoDay then
    Sdk:QueryRankSendInfo()
    return false
  end
  return tbGiftInfo[szOpenId] or false
end
function FriendShip:GetMyPlatInfo()
  return self.tbMyPlatInfo or {}
end
function FriendShip:GetTeamAddExpDesc()
  local bHasTeam = TeamMgr:HasTeam()
  if not bHasTeam then
    return ""
  end
  local tbMembers = TeamMgr:GetTeamMember()
  if #tbMembers == 0 then
    return ""
  end
  local szMsg = ""
  for i, v in ipairs(tbMembers) do
    local tbFriend = FriendShip:GetFriendDataInfo(v.nPlayerID)
    if tbFriend then
      local nImityLevel = FriendShip:GetFriendImityLevel(me.dwID, v.nPlayerID)
      if nImityLevel then
        local nAddExpP = FriendShip:GetFriendImityExpP(nImityLevel)
        if nAddExpP and nAddExpP > 0 then
          local szMsg1 = string.format("与[FFFE0D]%s[-]野外打怪经验共享[00ff00]+%d%%[-]", tbFriend.szName, nAddExpP)
          if szMsg ~= "" then
            szMsg = szMsg .. "\n" .. szMsg1
          else
            szMsg = szMsg1
          end
        end
      end
    end
  end
  return szMsg, true
end
function FriendShip:OnClearAllRequet()
  me.CenterMsg("成功一键清空")
  for k, v in pairs(self.tbAllData) do
    if k > me.dwID and v[emFriendData_BlackOrRequest] == emFriend_Type_Request_Right or k < me.dwID and v[emFriendData_BlackOrRequest] == emFriend_Type_Request_Left then
      self.tbAllData[k] = nil
    end
  end
  self.tbAllRequestData = {}
  UiNotify.OnNotify(UiNotify.emNoTIFY_SYNC_FRIEND_DATA)
end
function FriendShip:GetRemarkName(dwRoleId)
  local tbFriendMarkName = Client:GetUserInfo("FriedMarkName")
  return tbFriendMarkName[dwRoleId]
end
function FriendShip:CheckReMarkNameValid(szName)
  local nlen = Lib:Utf8Len(szName)
  if nlen > 6 then
    return false, "名字长度需要在6个汉字内"
  end
  if not CheckNameAvailable(szName) then
    return false, "名字中包含非法字符"
  end
  return true
end
function FriendShip:SetRemarkName(dwRoleId)
  local tbFriendData = FriendShip:GetFriendDataInfo(dwRoleId)
  if not tbFriendData then
    return
  end
  local function fnAgree(szText)
    local bRet, szMsg = self:CheckReMarkNameValid(szText)
    if not bRet then
      me.CenterMsg(szMsg)
      return true
    end
    local tbFriendMarkName = Client:GetUserInfo("FriedMarkName")
    if Lib:IsEmptyStr(szText) then
      szText = nil
    end
    tbFriendMarkName[dwRoleId] = szText
    UiNotify.OnNotify(UiNotify.emNoTIFY_SYNC_FRIEND_DATA)
    me.CenterMsg("设置成功！")
    Client:SaveUserInfo()
  end
  Ui:OpenWindow("MessageBoxInput", string.format("请输入[FFFE0D]%s[-]的备注名", tbFriendData.szName), fnAgree)
end
