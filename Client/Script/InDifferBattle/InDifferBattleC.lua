function InDifferBattle:DoSignUp()
  local bRet, szMsg = self:CanSignUp(me)
  if not bRet then
    me.CenterMsg(szMsg)
    return
  end
  RemoteServer.InDifferBattleSignUp()
end
function InDifferBattle:UnRegisterLevelEvent()
  if PlayerEvent.nRegisterIdOnLevelUp then
    PlayerEvent:UnRegisterGlobal("OnLevelUp", PlayerEvent.nRegisterIdOnLevelUp)
    PlayerEvent.nRegisterIdOnLevelUp = nil
  end
end
function InDifferBattle:EnterFightMap(nState, nTime, tbFactions, tbChoosedFactions, tbTeamRoomInfo)
  Ui:ClearRedPointNotify("IndifferMapRed")
  self.tbTeamRoomInfo = tbTeamRoomInfo
  self.nSynClientDataVersion = 0
  self.tbRoomNpcDmgInfo = {}
  self.nLastGetRoomNpcDmgInfo = 0
  self.tbDeadTeamIds = {}
  self.tbTeamReportInfo = {}
  self:SetClientLeftTime(nState, nTime)
  if not self.bRegistNotofy then
    UiNotify:RegistNotify(UiNotify.emNOTIFY_MAP_ENTER, self.OnEnterNewMap, self)
    UiNotify:RegistNotify(UiNotify.emNOTIFY_MAP_LEAVE, self.OnLeaveCurMap, self)
    UiNotify:RegistNotify(UiNotify.emNOTIFY_SET_PLAYER_NAME, self.OnSetPlayerName, self)
    self.bRegistNotofy = true
  end
  self.tbChoosedFactions = tbChoosedFactions
  self.tbCanUseRoomIndex = Lib:CopyTB(InDifferBattle.tbRoomIndex)
  Ui:OpenWindow("DreamlandInfoPanel")
  if nState == 1 then
    Ui:OpenWindow("DreamlandPanel", tbFactions)
  end
  InDifferBattle:UnRegisterLevelEvent()
  AutoFight:ChangeState(AutoFight.OperationType.Auto, true)
end
function InDifferBattle:OnSynChooseFactionInfo(tbChoosedFactions)
  self.tbChoosedFactions = tbChoosedFactions
  UiNotify.OnNotify(UiNotify.emNOTIFY_INDIFFER_BATTLE_FACTION)
end
function InDifferBattle:OnEnterNewMap(nMapTemplateId)
  self:OnCloseBattleMap()
end
function InDifferBattle:OnLeaveCurMap(nMapTemplateId)
  self:OnCloseBattleMap()
end
function InDifferBattle:OnSetPlayerName(nNpcId)
  local pNpc = KNpc.GetById(nNpcId)
  if not pNpc then
    return
  end
  if pNpc.dwTeamID == TeamMgr:GetTeamId() then
    return
  end
  pNpc.SetName("神秘人")
end
function InDifferBattle:OnCloseBattleMap()
  ChatMgr:LeaveCurChatRoom()
  Ui:ChangeUiState(0, true)
  if self.bRegistNotofy then
    UiNotify:UnRegistNotify(UiNotify.emNOTIFY_MAP_ENTER, self)
    UiNotify:UnRegistNotify(UiNotify.emNOTIFY_MAP_LEAVE, self)
    UiNotify:UnRegistNotify(UiNotify.emNOTIFY_SET_PLAYER_NAME, self)
    if not PlayerEvent.nRegisterIdOnLevelUp then
      PlayerEvent.nRegisterIdOnLevelUp = PlayerEvent:RegisterGlobal("OnLevelUp", PlayerEvent.OnLevelUp, PlayerEvent)
    end
    self.bRegistNotofy = nil
  end
  Ui:CloseWindow("DreamlandInfoPanel")
  Ui:CloseWindow("ChatLargePanel")
  Ui:CloseWindow("DreamlandPanel")
  Ui:CloseWindow("DreamlandGivePanel")
  Operation:EnableWalking()
  if self.nTimerLeftTime then
    Timer:Close(self.nTimerLeftTime)
    self.nTimerLeftTime = nil
  end
  self.tbDeadTeamIds = nil
  self.nLastGetRoomNpcDmgInfo = nil
  self.dwAliveMemberNpcId = nil
  self.nSynClientDataVersion = nil
  self.tbCurSingleNpcRoomIndex = nil
  self.tbCanUseRoomIndex = nil
  self.tbChoosedFactions = nil
  self.tbTeamRoomInfo = nil
  self.tbReadyCloseRoomIndex = nil
  self.bMyIsDeath = nil
  self.tbRoomNpcDmgInfo = nil
  self.tbTeamReportInfo = nil
  self.dwWinnerTeam = nil
  self.tbTeamMemberInfos = nil
end
function InDifferBattle:SetClientLeftTime(nState, nTime)
  self.nState = nState
  if not nTime then
    nTime = InDifferBattle.tbDefine.STATE_TRANS[self.nState].nSeconds
    Ui:CloseWindow("ChatLargePanel")
    Ui:CloseWindow("DreamlandPanel")
    local tbCurTrans = InDifferBattle.tbDefine.STATE_TRANS[nState]
    if tbCurTrans.szBeginNotify then
      Dialog:SendBlackBoardMsg(me, tbCurTrans.szBeginNotify)
      me.Msg(tbCurTrans.szBeginNotify)
    end
    if nState == 2 then
      Ui:OpenWindow("HomeScreenBattle")
    end
    if nState == 3 or nState == 5 or nState == 7 then
      Ui:SetRedPointNotify("IndifferMapRed")
    end
  end
  self.nLeftTime = nTime
  UiNotify.OnNotify(UiNotify.emNOTIFY_INDIFFER_BATTLE_UI)
  if self.nTimerLeftTime then
    Timer:Close(self.nTimerLeftTime)
  end
  self.nTimerLeftTime = Timer:Register(Env.GAME_FPS * 1, function()
    self.nLeftTime = self.nLeftTime - 1
    if self.nLeftTime <= 0 then
      self.nState = self.nState + 1
      UiNotify.OnNotify(UiNotify.emNOTIFY_INDIFFER_BATTLE_UI)
      local tbNextTrans = InDifferBattle.tbDefine.STATE_TRANS[self.nState]
      if not tbNextTrans then
        self.nState = self.nState - 1
        self.nTimerLeftTime = nil
        return false
      end
      self.nLeftTime = tbNextTrans.nSeconds
    end
    local tbTrans = InDifferBattle.tbDefine.tbActiveTransClient[self.nState]
    if tbTrans then
      local tbTransFunc = tbTrans[self.nLeftTime]
      if tbTransFunc then
        Lib:CallBack({
          self[tbTransFunc.szFunc],
          self,
          unpack(tbTransFunc.tbParam)
        })
      end
    end
    return true
  end)
end
function InDifferBattle:SynRoomReadyCloseInfo(tbReadyCloseRoomIndex)
  self.tbReadyCloseRoomIndex = tbReadyCloseRoomIndex
  self:CheckNotSafeRoom()
end
function InDifferBattle:SynTeamRoomInfo(tbTeamRoomInfo, bStopMove)
  self.tbTeamRoomInfo = tbTeamRoomInfo
  if bStopMove then
    local fnCheckWhenSwithRooom = self.fnCheckWhenSwithRooom
    self.fnCheckWhenSwithRooom = nil
    if fnCheckWhenSwithRooom then
      fnCheckWhenSwithRooom()
    else
      AutoFight:StopGoto()
      AutoAI.SetTargetIndex(0)
      Operation:StopMoveNow()
    end
  end
  if self.bMyIsDeath and self.dwAliveMemberNpcId then
    AutoFight:StartFollowTeammate(self.dwAliveMemberNpcId)
  end
  self:CheckNotSafeRoom()
  self.tbRoomNpcDmgInfo = {}
end
function InDifferBattle:SynRoomOpenInfo(tbCanUseRoomIndex)
  self.tbCanUseRoomIndex = tbCanUseRoomIndex
  UiNotify.OnNotify(UiNotify.emNOTIFY_INDIFFER_BATTLE_UI, "room")
end
function InDifferBattle:SynSingleNpcRoomInfo(tbCurSingleNpcRoomIndex, nSynClientDataVersion)
  self.nSynClientDataVersion = nSynClientDataVersion
  self.tbCurSingleNpcRoomIndex = tbCurSingleNpcRoomIndex
  UiNotify.OnNotify(UiNotify.emNOTIFY_INDIFFER_BATTLE_UI, "room")
end
function InDifferBattle:SynNpcDmgInfo(nRoomIndex, tbNpcDmgInfo)
  self.tbRoomNpcDmgInfo[nRoomIndex] = tbNpcDmgInfo
  local tbRankList = self:GetRoomNpcDmgInfo(nRoomIndex)
  if tbRankList then
    UiNotify.OnNotify(UiNotify.emNOTIFY_DMG_RANK_UPDATE, tbRankList)
  end
end
function InDifferBattle:GetRoomNpcDmgInfo(nRoomIndex)
  local tbNpcDmgInfo = self.tbRoomNpcDmgInfo[nRoomIndex]
  if not tbNpcDmgInfo then
    return
  end
  local tbRankList = {}
  local dwMyTeamId = TeamMgr:GetTeamId()
  for i, v in ipairs(tbNpcDmgInfo) do
    local szName = dwMyTeamId == v.nTeamId and "已方队伍" or "神秘人队伍"
    table.insert(tbRankList, {
      szName,
      v.nPercent * 100
    })
  end
  table.sort(tbRankList, function(a, b)
    return a[2] > b[2]
  end)
  return tbRankList
end
function InDifferBattle:GetCurRoomNpcDmgInfo(nRoomIndex)
  local nNow = GetTime()
  if nNow >= self.nLastGetRoomNpcDmgInfo + 5 then
    return
  end
  self.nLastGetRoomNpcDmgInfo = nNow
  return self:GetRoomNpcDmgInfo(nRoomIndex)
end
function InDifferBattle:OnGameDeath(dwAliveMemberNpcId)
  self.bMyIsDeath = true
  Operation:DisableWalking()
  UiNotify.OnNotify(UiNotify.emNOTIFY_INDIFFER_BATTLE_UI)
  self.dwAliveMemberNpcId = dwAliveMemberNpcId
  if dwAliveMemberNpcId then
    AutoFight:StartFollowTeammate(dwAliveMemberNpcId)
  end
  self:OnMemberGameDeath(me.dwID)
  Ui:OpenWindow("DreamlandReportPanel")
end
function InDifferBattle:OnMemberGameDeath(dwMemberId)
  self.tbDeadTeamIds[dwMemberId] = 1
  if not self.tbTeamMemberInfos then
    self.tbTeamMemberInfos = {}
    local tbMembers = TeamMgr:GetTeamMember()
    for i, v in ipairs(tbMembers) do
      self.tbTeamMemberInfos[i] = v
    end
  end
  local nDeadNum = 0
  for k, v in pairs(self.tbDeadTeamIds) do
    nDeadNum = nDeadNum + 1
  end
  local nAllMember = 0
  for k, v in pairs(self.tbTeamRoomInfo) do
    nAllMember = nAllMember + 1
  end
  if nDeadNum >= nAllMember then
    Ui:OpenWindow("DreamlandReportPanel")
  end
  UiNotify.OnNotify(UiNotify.emNOTIFY_TEAM_UPDATE)
end
function InDifferBattle:IsPlayerDeath(dwRoleId)
  if not self.bRegistNotofy then
    return
  end
  return self.tbDeadTeamIds[dwRoleId]
end
function InDifferBattle:IsInDangerRoom()
  return self.tbReadyCloseRoomIndex and self.tbReadyCloseRoomIndex[self.tbTeamRoomInfo[me.dwID]]
end
function InDifferBattle:CheckNotSafeRoom()
  if self:IsInDangerRoom() then
    UiNotify.OnNotify(UiNotify.emNOTIFY_CHANG_ROLE_WARN, true)
    Dialog:SendBlackBoardMsg(me, string.format(self.nState == 7 and "此区域将在%d秒后坍塌，请前往1号区域" or "此区域将在%d秒后坍塌，请迅速离开", self.nLeftTime))
  else
    UiNotify.OnNotify(UiNotify.emNOTIFY_CHANG_ROLE_WARN, false)
  end
  UiNotify.OnNotify(UiNotify.emNOTIFY_INDIFFER_BATTLE_UI, "room")
end
function InDifferBattle:ShowRoomCloseEffect()
  if not self:IsInDangerRoom() then
    return
  end
  local nRoomIndex = self.tbTeamRoomInfo[me.dwID]
  local nX, nY = unpack(self.tbRooomPosSet[nRoomIndex].center)
  me.GetNpc().CastSkill(self.tbDefine.nCloseRoomSkillId, 1, nX, nY)
end
function InDifferBattle:GetMemberRoomIndex(dwRoleId)
  local nRoomIndex = self.tbTeamRoomInfo[dwRoleId]
  return nRoomIndex or 0
end
function InDifferBattle:OnGiveMoneySuc()
  me.CenterMsg("勾玉赠送成功")
  Ui:OpenWindow("DreamlandGivePanel")
end
function InDifferBattle:OnBuyShopWareSuc(tbCurSellWares, nNpcId)
  me.CenterMsg("购买成功")
  UiNotify.OnNotify(UiNotify.emNOTIFY_SYNC_SHOP_WARE, tbCurSellWares, nNpcId)
end
function InDifferBattle:OnLevelUpItemSuc(szType, ...)
  local tbArgs = {
    ...
  }
  if szType == "Strengthen" then
    local tbEquipPos, nNextLevel, nIndex = unpack(tbArgs)
    for i, nEquipPos in ipairs(tbEquipPos) do
      Strengthen:OnResponse(true, nil, nEquipPos, nNextLevel)
    end
    local tbInfo = self.tbDefine.tbEnhanceScroll[nIndex]
    local szMsg = string.format("%s成功强化至+%d", tbInfo.szDesc, nNextLevel)
    Dialog:SendBlackBoardMsg(me, szMsg)
  elseif szType == "HorseUpgrade" then
    local szMsg = "「乌云踏雪」成功进阶为「追影」"
    Dialog:SendBlackBoardMsg(me, szMsg)
  elseif szType == "BookUpgrade" then
    local nOldItem, nNewItemId = unpack(tbArgs)
    local tbItemBase1 = KItem.GetItemBaseProp(nOldItem)
    local tbItemBase2 = KItem.GetItemBaseProp(nNewItemId)
    local szMsg = string.format("「%s」成功进阶为「%s」", tbItemBase1.szName, tbItemBase2.szName)
    Dialog:SendBlackBoardMsg(me, szMsg)
  end
  UiNotify.OnNotify(UiNotify.emNOTIFY_INDIFFER_BATTLE_UI, "DreamlandLevelUpPanel")
end
function InDifferBattle:DropBuff(nPosX, nPosY)
  local tbDropInfo = {
    tbUserDef = {
      {nObjID = -1, szTitle = ""}
    }
  }
  me.DropItemInPos(nPosX, nPosY, tbDropInfo)
end
function InDifferBattle:UseItem(nItemId)
  local pItem = me.GetItemInBag(nItemId)
  if not pItem then
    me.CenterMsg("道具不存在")
    return
  end
  if not self.bRegistNotofy then
    me.CenterMsg("已不在活动内")
    return
  end
  RemoteServer.InDifferBattleRequestInst("UseItem", nItemId)
end
function InDifferBattle:SellItem(nItemId)
  local pItem = me.GetItemInBag(nItemId)
  if not pItem then
    me.CenterMsg("道具不存在")
    return
  end
  if not self.bRegistNotofy then
    me.CenterMsg("已不在活动内")
    return
  end
  RemoteServer.InDifferBattleRequestInst("SellItem", nItemId)
end
function InDifferBattle:IsShowHomeScreenDmgBtn()
  local tbTeamRoomInfo = self.tbTeamRoomInfo
  if not tbTeamRoomInfo then
    return
  end
  local tbCurSingleNpcRoomIndex = self.tbCurSingleNpcRoomIndex
  if not tbCurSingleNpcRoomIndex then
    return
  end
  local nMyRoomIndex = tbTeamRoomInfo[me.dwID]
  for nRoomIndex, nNpcTemplateId in pairs(tbCurSingleNpcRoomIndex) do
    if nRoomIndex == nMyRoomIndex then
      local tbNpcInfo = InDifferBattle.tbRoomSetting.tbSingleRoomNpc[nNpcTemplateId]
      if tbNpcInfo and tbNpcInfo.szDropAwardList then
        return nRoomIndex, nNpcTemplateId
      end
      return
    end
  end
end
function InDifferBattle:CheckOpenIsShowHomeScreenDmgBtn()
  local nRoomIndex, nNpcTemplateId = self:IsShowHomeScreenDmgBtn()
  if not nRoomIndex then
    return
  end
  local szName = KNpc.GetNameByTemplateId(nNpcTemplateId)
  local tbDmg = self:GetCurRoomNpcDmgInfo(nRoomIndex)
  local tbNpcInfo = self.tbRoomSetting.tbSingleRoomNpc[nNpcTemplateId]
  local szDmgUiTips = tbNpcInfo.bBoss and self.tbDefine.szDmgUiTipsBoss or InDifferBattle.tbDefine.szDmgUiTips
  Ui:OpenWindow("BossLeaderOutputPanel", "InDifferBattle", szName, szDmgUiTips, tbDmg)
end
function InDifferBattle:OnSynBattleScoreInfo(tbTeamReportInfo, dwWinnerTeam)
  self.tbTeamReportInfo = tbTeamReportInfo
  self.dwWinnerTeam = dwWinnerTeam
  UiNotify.OnNotify(UiNotify.emNOTIFY_INDIFFER_BATTLE_UI, "BattleScore")
end
function InDifferBattle:OnSynWinTeam(dwWinnerTeam)
  self.dwWinnerTeam = dwWinnerTeam
  Ui:OpenWindow("DreamlandReportPanel")
end
function InDifferBattle:IsDeathInBattle()
  if self.bRegistNotofy and self.bMyIsDeath then
    me.CenterMsg("当前状态不能操作")
    return true
  end
end
function InDifferBattle:GotoTeamateRoom(tbTeammate)
  local nRoomIndexMe = self.tbTeamRoomInfo[me.dwID]
  local nRoomIndexHim = self.tbTeamRoomInfo[tbTeammate.nPlayerID]
  if nRoomIndexMe == nRoomIndexHim then
    return
  end
  self:_StartAutoGotoRoom(nRoomIndexHim, true)
  return true
end
function InDifferBattle:_StartAutoGotoRoom(nRoomIndex, bClear)
  self.fnCheckWhenSwithRooom = nil
  local nRoomIndexMe = self.tbTeamRoomInfo[me.dwID]
  if nRoomIndexMe == nRoomIndex then
    return
  end
  if not self.tbCanUseRoomIndex[nRoomIndex] then
    return
  end
  local xMe, yMe = unpack(self.tbRoomIndex[nRoomIndexMe])
  if not self.tbAutoPathGrid or bClear then
    local tbGrird = {}
    for i = 1, 5 do
      tbGrird[i] = {}
    end
    for _nRoomIndex, v in pairs(self.tbCanUseRoomIndex) do
      local row, col = unpack(self.tbRoomIndex[_nRoomIndex])
      tbGrird[row][col] = 1
    end
    self.tbAutoPathGrid = tbGrird
    self.nAutoPathTarRoomIndex = nRoomIndex
    self.tbMoveedPath = {}
    table.insert(self.tbMoveedPath, {xMe, yMe})
  end
  local xTar, yTar = unpack(self.tbRoomIndex[nRoomIndex])
  local nMinusX, nMinusY = self:GetAutoPathTowradPos(xTar, yTar, xMe, yMe)
  if nMinusX then
    table.insert(self.tbMoveedPath, {
      xMe + nMinusX,
      yMe + nMinusY
    })
  else
    for i, v in ipairs(self.tbMoveedPath) do
      local row, col = unpack(v)
      self.tbAutoPathGrid[row][col] = 2
    end
    nMinusX, nMinusY = self:GetAutoPathTowradPos(xTar, yTar, xMe, yMe)
  end
  assert(nMinusX)
  local szTarPosName
  for k, v in pairs(self.tbDefine.tbGateDirectionModify) do
    local nRow, nCol = unpack(v)
    if nMinusX == nRow and nMinusY == nCol then
      szTarPosName = k
      break
    end
  end
  local nPosX, nPosY = unpack(self.tbRooomPosSet[nRoomIndexMe][szTarPosName])
  function self.fnCheckWhenSwithRooom()
    if self.tbTeamRoomInfo[me.dwID] ~= nRoomIndex then
      self:_StartAutoGotoRoom(nRoomIndex)
    else
      self.nAutoPathTarRoomIndex = nil
    end
  end
  Operation:ClickMap(nPosX, nPosY, true)
end
function InDifferBattle:GetAutoPathTowradPos(xTar, yTar, xMe, yMe)
  local x = xTar - xMe
  local y = yTar - yMe
  if x ~= 0 then
    x = math.floor(math.abs(x) / x)
    local xTemp = xMe + x
    if self.tbAutoPathGrid[xTemp][yMe] then
    else
      self.tbAutoPathGrid[xMe][yMe] = nil
      x = 0
      if y == 0 then
        y = 3 - yMe
        y = math.floor(math.abs(y) / y)
        if not self.tbAutoPathGrid[xMe][yMe + y] then
          y = 0
        end
      end
    end
  end
  if y ~= 0 then
    y = math.floor(math.abs(y) / y)
    local yTemp = yMe + y
    if self.tbAutoPathGrid[xMe][yTemp] then
    else
      self.tbAutoPathGrid[xMe][yMe] = nil
      y = 0
      if x == 0 then
        x = 3 - xMe
        x = math.floor(math.abs(x) / x)
        if not self.tbAutoPathGrid[xMe + x][yMe] then
          x = 0
        end
      end
    end
  end
  if x ~= 0 and y ~= 0 then
    if self.tbAutoPathGrid[x + xMe][yMe] == 2 then
      return 0, y
    else
      return x, 0
    end
  end
  if x ~= 0 then
    return x, 0
  elseif y ~= 0 then
    return 0, y
  end
end
