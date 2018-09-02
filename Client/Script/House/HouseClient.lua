function House:OnAddMapFurniture(nId, tbInfo)
  self.tbMapFurniture[nId] = tbInfo
  UiNotify.OnNotify(UiNotify.emNOTIFY_SYNC_MAP_FURNITURE)
end
function House:OnRemoveMapFurniture(nId)
  self.tbMapFurniture[nId] = nil
  UiNotify.OnNotify(UiNotify.emNOTIFY_SYNC_MAP_FURNITURE)
end
function House:OnSyncSingleFurniture(nTemplateId, nCount)
  self.tbFurniture = self.tbFurniture or {}
  self.tbFurniture[nTemplateId] = nCount > 0 and nCount or nil
  UiNotify.OnNotify(UiNotify.emNOTIFY_SYNC_FURNITURE)
end
function House:OnSyncFurniture(tbFurniture)
  self.tbFurniture = tbFurniture or {}
  UiNotify.OnNotify(UiNotify.emNOTIFY_SYNC_FURNITURE)
end
function House:OnSyncMapFurniture(tbMapFurniture)
  self.tbMapFurniture = tbMapFurniture or {}
  UiNotify.OnNotify(UiNotify.emNOTIFY_SYNC_MAP_FURNITURE)
end
function House:OnSyncHouseInfo(tbHouseInfo, tbLover)
  self.dwOwnerId = tbHouseInfo.dwOwnerId
  self.szName = tbHouseInfo.szName
  self.nHouseLevel = tbHouseInfo.nLevel
  self.nHouseMapId = tbHouseInfo.nMapId
  self.tbRoomer = tbHouseInfo.tbRoomer or {}
  self.tbAccessInfo = tbHouseInfo.tbAccess or {}
  self.nStartLeveupTime = tbHouseInfo.nStartLeveupTime
  self.tbLover = tbLover
  UiNotify.OnNotify(UiNotify.emNOTIFY_SYNC_HOUSE_INFO)
  if self.bDecorationMode and not self:HasDecorationAccess(me) then
    me.CenterMsg("大侠现在没有装修权限了！")
    self:ExitDecorationMode()
  end
end
function House:OnSyncMakeFurniture(nFurnitureItemId, bResult)
  UiNotify.OnNotify(UiNotify.emNOTIFY_SYNC_MAKE_FURNITURE, nFurnitureItemId, bResult)
end
function House:OnSetAccess(nType, bAccess)
  self.tbAccessInfo = self.tbAccessInfo or {}
  self.tbAccessInfo[nType] = bAccess
  UiNotify.OnNotify(UiNotify.emNOTIFY_SYNC_HOUSE_ACCESS, nType, bAccess)
end
function House:OnStartLevelUp(nStartLeveupTime)
  self.nStartLeveupTime = nStartLeveupTime
  UiNotify.OnNotify(UiNotify.emNOTIFY_HOUSE_LEVELUP)
end
function House:OnSyncSwitchPlace()
  WeatherMgr:OnSyncSwitchPlace()
  UiNotify.OnNotify(UiNotify.emNOTIFY_SYNC_SWITCH_PLACE)
end
function House:OnSyncRoomers(tbRoomer, tbLover)
  self.tbRoomer = tbRoomer or {}
  self.tbLover = tbLover
  UiNotify.OnNotify(UiNotify.emNOTIFY_SYNC_HOUSE_INFO)
end
function House:GetComfortableShowInfo()
  local tbAllInfo = {}
  for _, tbInfo in pairs(self.tbMapFurniture or {}) do
    local tbFurniture = self:GetFurnitureInfo(tbInfo.nTemplateId)
    tbAllInfo[tbFurniture.nType] = tbAllInfo[tbFurniture.nType] or {}
    table.insert(tbAllInfo[tbFurniture.nType], {
      tbInfo.nTemplateId,
      tbFurniture.nComfortValue
    })
  end
  for _, tbInfo in pairs(tbAllInfo) do
    table.sort(tbInfo, function(a, b)
      if a[2] ~= b[2] then
        return a[2] > b[2]
      end
      return a[1] > b[1]
    end)
  end
  local nTotalValue = self:GetLevelComfort(self.nHouseLevel)
  local nMaxCount = #Furniture.tbNormalFurniture
  for i = 1, nMaxCount do
    local nAddCount = self.tbComfortValueLimit[self.nHouseLevel or 1][i] or 0
    if nAddCount > 0 then
      if tbAllInfo[i] and nAddCount < #tbAllInfo[i] then
        local nTCount = #tbAllInfo[i]
        for nIdx = nAddCount + 1, nTCount do
          tbAllInfo[i][nIdx] = nil
        end
      end
      for _, tbInfo in pairs(tbAllInfo[i] or {}) do
        nTotalValue = nTotalValue + tbInfo[2]
      end
    else
      tbAllInfo[i] = nil
    end
  end
  return nTotalValue, tbAllInfo
end
function House:EnterDecorationMode()
  if not self:HasDecorationAccess(me) then
    return
  end
  House:ChangeCameraSetting(unpack(House.tbDecorationModelCameraSetting))
  self.bDecorationMode = true
  Ui:CloseWindow("PlantStatePanel")
  Ui:SetAllUiVisable(false)
  Ui:OpenWindow("HouseDecorationPanel")
  RemoteServer.OnStartDecorationState()
  for _, tbRepInfo in pairs(Decoration.tbClientDecoration or {}) do
    local tbMainSeatInfo = House.tbMainSeatInfo[me.nMapTemplateId] or {-1}
    local tbTemplate = Decoration.tbAllTemplate[tbRepInfo.nTemplateId]
    local pRep = Ui.Effect.GetObjRepresent(tbRepInfo.nRepId)
    if tbRepInfo.nTemplateId ~= tbMainSeatInfo[1] and tbTemplate and pRep then
      pRep:SetColliderLogicSize(tbTemplate.nWidth * Decoration.CELL_LOGIC_WIDTH, tbTemplate.nHeight, tbTemplate.nLength * Decoration.CELL_LOGIC_HEIGHT)
      pRep:SetMapColliderActive(false)
    end
  end
end
function House:ExitDecorationMode()
  if not self.bDecorationMode then
    return
  end
  self.bDecorationMode = false
  House:ChangeCameraSetting(unpack(House.tbNormalCameraSetting))
  Ui:CloseWindow("HouseDecorationPanel")
  Ui:SetAllUiVisable(true)
  HousePlant:ShowPlantTip()
  for _, tbRepInfo in pairs(Decoration.tbClientDecoration or {}) do
    local tbTemplate = Decoration.tbAllTemplate[tbRepInfo.nTemplateId]
    local pRep = Ui.Effect.GetObjRepresent(tbRepInfo.nRepId)
    if tbTemplate and pRep then
      if tbRepInfo.bCanOperation then
        pRep:SetColliderLogicSize(tbTemplate.nWidth * Decoration.CELL_LOGIC_WIDTH, tbTemplate.nHeight, tbTemplate.nLength * Decoration.CELL_LOGIC_HEIGHT)
      else
        pRep:SetColliderLogicSize(1, 1, 1)
      end
      pRep:SetMapColliderActive(true)
    end
  end
end
function House:ChangeCameraSetting(nDistance, nLookDownAngle)
  if self.tbCameraSetting then
    return
  end
  local m, x, y = me.GetWorldPos()
  Ui.CameraMgr.MoveCameraToPositionWhithRotation(0.5, x, y, nDistance - Ui.CameraMgr.s_fCameraDistance, 1, nLookDownAngle)
  self.tbCameraSetting = {nDistance, nLookDownAngle}
end
function House:OnPlayCameraAnimationFinish()
  if not self.tbCameraSetting then
    return
  end
  Ui.CameraMgr.ChangeCameraSetting(self.tbCameraSetting[1], self.tbCameraSetting[2], Ui.CameraMgr.s_fCameraFieldOfView)
  Ui.CameraMgr.LeaveCameraAnimationState()
  self.tbCameraSetting = nil
end
function House:TipsLevelup()
  me.MsgBox("家园已升级完成，请前往[FFFE0D]真妹[-]处确认。", {
    {
      "现在就去",
      function()
        Ui.HyperTextHandle:Handle("[url=npc:testtt,2279,10]", 0, 0)
      end
    },
    {
      "等会儿吧"
    }
  })
end
function House:OnLeaveMap(nMapTemplateId)
  if not nMapTemplateId or not Map:IsHouseMap(nMapTemplateId) then
    return
  end
  if House:IsNormalHouse(nMapTemplateId) then
    Ui:CloseWindow("HouseCameraPanel")
    Ui:CloseWindow("HouseSharePanel")
    self.tbCameraSetting = nil
  end
  if Ui:WindowVisible("TopButton") then
    local tbUi = Ui("TopButton")
    if tbUi.BtnTopFoldState then
      tbUi.tbOnClick.BtnTopFold(tbUi)
    end
  end
end
function House:OnConnectLost()
  if not (me and me.nMapTemplateId) or not House:IsNormalHouse(me.nMapTemplateId) then
    return
  end
  self.bDecorationMode = false
  Ui:CloseWindow("HouseCameraPanel")
  Ui:CloseWindow("HouseSharePanel")
  Ui:CloseWindow("HouseDecorationPanel")
  if PlayerEvent.bLogin then
    Ui:ChangeUiState(Ui.STATE_DEFAULT, true)
    Ui.CameraMgr.ChangeCameraSetting(House.tbNormalCameraSetting[1], House.tbNormalCameraSetting[2], Ui.CameraMgr.s_fCameraFieldOfView)
    Ui.CameraMgr.LeaveCameraAnimationState()
  end
  self.tbCameraSetting = nil
end
function House:OnSyncHasHouse(bHasHouse)
  self.bHasHouse = bHasHouse
  UiNotify.OnNotify(UiNotify.emNOTIFY_SYNC_HAS_HOUSE)
end
function House:OnCheckIn(dwOwnerId)
  Ui:RemoveNotifyMsg("HouseInvite")
  UiNotify.OnNotify(UiNotify.emNOTIFY_ROOMER_CHECKIN, dwOwnerId)
end
function House:OnCheckOut(dwOwnerId)
  UiNotify.OnNotify(UiNotify.emNOTIFY_ROOMER_CHECKOUT, dwOwnerId)
end
function House:OnLogin(bIsReconnect)
  if bIsReconnect and Ui:WindowVisible("TopButton") == 1 then
    Ui("TopButton"):RefreshHouseButton()
  end
end
function House:OnMuseStart()
  Ui:OpenWindow("ProgressBarPanel", "Muse")
end
function House:OnMuseEnd(nLevel)
  Ui:CloseWindow("ProgressBarPanel")
  if nLevel then
    Ui:OpenWindow("VitalityEffectPanel", nLevel)
  end
  self:CheckMuseRedPoint()
end
function House:OnSyncHouesFriendList(tbFriendList)
  House.tbFriendList = {}
  for _, tbInfo in ipairs(tbFriendList) do
    local nImity = FriendShip:GetImity(me.dwID, tbInfo.dwPlayerId)
    if nImity then
      table.insert(House.tbFriendList, {
        dwPlayerId = tbInfo.dwPlayerId,
        nImity = nImity,
        bCanInvite = tbInfo.bCanInvite
      })
    end
  end
  table.sort(House.tbFriendList, function(a, b)
    if a.bCanInvite == b.bCanInvite then
      return a.nImity > b.nImity
    else
      return a.bCanInvite
    end
  end)
  UiNotify.OnNotify(UiNotify.emNOTIFY_SYNC_HOUSE_FRIEND_LIST)
end
function House:GotoMuse()
  if House.bHasHouse then
    RemoteServer.TryMuse()
  else
    me.MsgBox("你还没有家园，传闻[FFFE0D]真妹[-]处可打探到相关信息。", {
      {
        "现在就去",
        function()
          Ui.HyperTextHandle:Handle("[url=npc:testtt,2279,10]", 0, 0)
        end
      },
      {
        "等会儿吧"
      }
    })
  end
end
function House:GotoOwnHouse()
  Ui:CloseWindow("StrongerPanel")
  Ui:CloseWindow("HonorLevelPanel")
  if House.bHasHouse then
    RemoteServer.GoMyHome()
  else
    me.MsgBox("你还没有家园，传闻[FFFE0D]真妹[-]处可打探到相关信息。", {
      {
        "现在就去",
        function()
          Ui.HyperTextHandle:Handle("[url=npc:testtt,2279,10]", 0, 0)
        end
      },
      {
        "等会儿吧"
      }
    })
  end
end
function House:CheckMuseRedPoint()
  local nTimes = DegreeCtrl:GetDegree(me, "Muse")
  if nTimes <= 0 then
    Ui:ClearRedPointNotify("Muse")
  else
    Ui:SetRedPointNotify("Muse")
  end
end
function House:OnEnterMap(nMapTemplateId)
  if not nMapTemplateId or not House:IsNormalHouse(nMapTemplateId) then
    return
  end
  Ui:CloseWindow("SocialPanel")
  Ui:CloseWindow("RankBoardPanel")
  Ui:CloseWindow("HonorLevelPanel")
end
function House:OnMapLoaded(nMapTemplateId)
  if not nMapTemplateId or not Map:IsHouseMap(nMapTemplateId) then
    return
  end
  if House:IsNormalHouse(nMapTemplateId) then
    if House.dwOwnerId and House.dwOwnerId ~= me.dwID then
      me.SendBlackBoardMsg(string.format("进入了「%s」的家", House.szName or ""))
    end
    if House:IsInOwnHouse(me) or House:IsInLivingRoom(me) then
      me.SendBlackBoardMsg("已自动开启在线托管")
    end
  else
    local szMapName = Map:GetMapName(nMapTemplateId)
    me.SendBlackBoardMsg(string.format("进入了「%s」", szMapName or ""))
  end
end
function House:AutoMuse(nMapId, nX, nY)
  AutoPath:GotoAndCall(nMapId, nX, nY, function()
    RemoteServer.TryMuse()
  end)
end
function House:OnSyncExtComfortLevel(nExtComfortLevel, nExtComfortOwnerId)
  self.nExtComfortLevel = nExtComfortLevel
  self.nExtComfortOwnerId = nExtComfortOwnerId
  UiNotify.OnNotify(UiNotify.emNOTIFY_SYNC_EXT_COMFORTLEVEL)
end
function House:OnSyncLoverHouse(bHasHouse)
  self.bLoverHasHouse = bHasHouse
end
