local SceneMgr = luanet.import_type("SceneMgr")
Map.nUnLoadResourceTime = 1800
local tbMapEnterBlackBoardMsg = {
  [409] = "你已进入PK地图，自动开启家族模式",
  [1030] = "你已进入PK地图，自动开启家族模式",
  [1031] = "你已进入PK地图，自动开启家族模式",
  [1032] = "你已进入PK地图，自动开启家族模式",
  [1033] = "你已进入PK地图，自动开启家族模式",
  [1034] = "你已进入PK地图，自动开启家族模式",
  [1035] = "你已进入PK地图，自动开启家族模式"
}
Map.tbFieldFightMap = {
  [400] = true,
  [401] = true,
  [402] = true,
  [403] = true,
  [404] = true,
  [405] = true,
  [406] = true,
  [407] = true,
  [408] = true,
  [409] = true,
  [410] = true,
  [411] = true,
  [412] = true,
  [413] = true,
  [414] = true,
  [415] = true,
  [416] = true,
  [417] = true,
  [418] = true,
  [419] = true,
  [420] = true
}
function Map:OnEnter(nTemplateID, nMapID, nIsLocal)
  self.nMapId = nMapID
  self.bLoading = true
  if not PlayerEvent.bLogin then
    PlayerEvent.tbMapOnEnterParam = {
      nTemplateID,
      nMapID,
      nIsLocal
    }
    return
  end
  AutoPath:OnEnterMap(nTemplateID, nMapID, nIsLocal)
  Task:OnEnter(nTemplateID)
  local nState, bHide = Map:GetMapUiState(nTemplateID)
  Ui:ChangeUiState(nState, bHide)
  UiNotify.OnNotify(UiNotify.emNOTIFY_MAP_ENTER, nTemplateID, nMapID)
  if nIsLocal == 1 then
    Fuben:OnEnter(nTemplateID, nMapID)
    AsyncBattle:OnEnterMap(nTemplateID)
    ActionMode:OnEnterMap(me, nTemplateID)
  end
  Player:UpdateHeadState()
  ClientNpc:OnEnterMap(nTemplateID)
  NewInformation:OnEnterMap()
  if self.nUnLoadResourceTimer then
    Timer:Close(self.nUnLoadResourceTimer)
    self.nUnLoadResourceTimer = nil
  end
  self.nUnLoadResourceTimer = Timer:Register(Env.GAME_FPS * self.nUnLoadResourceTime, self.UnLoadResource, self)
  ArenaBattle:OnMapEnter(nTemplateID)
  Kin.Snowman:OnEnterMap(nTemplateID)
  AutoFight:OnEnterMap(nTemplateID)
  Lib:CallBack({
    House.OnEnterMap,
    House,
    nTemplateID
  })
  Lib:CallBack({
    Pandora.OnEnterMap,
    Pandora,
    nTemplateID,
    nMapID,
    nIsLocal
  })
  Lib:CallBack({
    JingMai.OnClientEnterMap,
    JingMai
  })
  Log("Client Map:OnEnter......>>>", me.dwID, nMapID, me.nAlone, nTemplateID, nIsLocal)
end
Map.tbSTOP_PEEK_REASON = {
  "对方网络异常，远程观战终止",
  "对方离开了地图，远程观战终止",
  "您的网络异常，远程观战终止",
  "您切换了地图，远程观战终止"
}
function Map:OnEnterPeek(nTemplateID, nMapID, nPeekNpcId, nReason)
  Ui:CloseWindow("SocialPanel")
  local function fnOnLeavePeeking(nReason)
    Ui.CameraMgr.ResetMainCamera(true)
    BindCameraToNpc(0, 0)
    Ui:ChangeUiState(0, true)
    Ui:CloseWindow("QYHLeftInfo")
    local pNpc = me.GetNpc()
    if pNpc then
      pNpc.SetHideNpc(0)
    end
    if self.tbSTOP_PEEK_REASON[nReason] then
      Ui:OpenWindow("MessageBox", self.tbSTOP_PEEK_REASON[nReason], {}, {"知道了"})
    end
  end
  local pNpc = me.GetNpc()
  if nPeekNpcId ~= pNpc.nId then
    function self.fnOnPeekingLoadMapEnd()
      local pNpc = me.GetNpc()
      Ui.CameraMgr.ResetMainCamera(true)
      BindCameraToNpc(nPeekNpcId, 0)
      Ui:ChangeUiState(Ui.STATE_ASYNC_BATTLE)
      Ui:OpenWindow("QYHLeftInfo", "PeekPlayer", {})
      if pNpc then
        pNpc.SetHideNpc(1)
      end
      Map.fnOnPeekingEnd = fnOnLeavePeeking
    end
    if me.nMapTemplateId == nTemplateID then
      Loading.nCurLeaveMapId = self.nCurLeaveMapId
      Lib:CallBack({
        self.fnOnPeekingLoadMapEnd
      })
      self.fnOnPeekingLoadMapEnd = nil
    end
  else
    fnOnLeavePeeking(nReason)
    Map.fnOnPeekingEnd = nil
  end
end
function Map:UnLoadResource()
  if not PlayerEvent.bLogin then
    self.nUnLoadResourceTimer = nil
    return
  end
  Log("Map:UnLoadResource.................")
  Ui.ResourceLoader.UnLoadResource()
  return true
end
function Map:OnLeave(nTemplateID, nMapID)
  UiNotify.OnNotify(UiNotify.emNOTIFY_MAP_LEAVE, nTemplateID, nMapID)
  if IsAlone() == 1 then
    SetGameWorldScale(1)
    AsyncBattle:OnLeaveMap(nTemplateID)
  end
  Sdk:GsdkEnd()
  ArenaBattle:OnMapLeave(nTemplateID)
  Kin.Snowman:OnLeaveMap(nTemplateID)
  BiWuZhaoQin:OnClientMapLeave(nTemplateID)
  Lib:CallBack({
    House.OnLeaveMap,
    House,
    nTemplateID
  })
  Lib:CallBack({
    WeatherMgr.OnLeaveMap,
    WeatherMgr,
    nTemplateID
  })
  HousePlant:OnLeaveMap(nTemplateID)
  self.nCurLeaveMapId = nMapID
  Timer:Register(5, function()
    if not Loading.nCurLeaveMapId or Loading.nCurLeaveMapId == self.nCurLeaveMapId then
      return
    end
    Ui:SetForbiddenOperation(false)
    Ui:SetAllUiVisable(true)
    SetGameWorldScale(1)
    Operation:SetGuidingJoyStick(false)
    Ui:ShowAllRepresentObj(true)
    Map:OnEnter(nTemplateID, nMapID, IsAlone() == 0 and 1 or 0)
    Timer:Register(1, function()
      Map:OnMapLoaded(nTemplateID)
    end)
  end)
  Log("Map:OnLeave", nTemplateID, nMapID)
end
function Map:OnLostConnect()
  if self.fnOnPeekingEnd then
    self.fnOnPeekingEnd(3)
    self.fnOnPeekingEnd = nil
  end
end
function Map:OnDestroy(nTemplateID, nMapID, nIsLocal)
  if nIsLocal == 1 then
    Fuben:OnDestroyMap(nMapID)
  end
  Ui:CloseWindow("CalendarPanel")
  Operation:OnDestroyMap()
  Map:StopMapSound()
  Map:CheckCloseUi(self.tbOnLeaveCloseUi, nMapID)
  Ui:ClearCanLoadResPath()
  Lib:CallBack({
    Map.ClearAllObjRep,
    Map
  })
  Lib:CallBack({
    Decoration.OnMapDestroy,
    Decoration,
    nTemplateID,
    nMapID
  })
  Log("Client Map:OnDestroy......", me.dwID, nMapID, nTemplateID)
end
function Map:UpdateMapLoaded(nMapTemplateID)
  Ui:SetSceneSoundScale(100)
  Ui:SetDialogueSoundScale(Npc.nDialogSoundScale)
  local nSoundScale = 100
  if nMapTemplateID > 0 then
    nSoundScale = Map:GetEffectSoundVolume(nMapTemplateID)
    if nSoundScale <= 0 then
      nSoundScale = 100
    end
  end
  Ui:SetEffectSoundScale(nSoundScale)
end
function Map:ClearAllObjRep()
  if not Ui.Effect then
    return
  end
  Ui.Effect.ClearAllObjRepresent()
end
function Map:UpdateCamera(nMapTemplateID)
  local tbSetting = self:GetCameraSettings(nMapTemplateID)
  if not tbSetting then
    return
  end
  Ui.CameraMgr.ChangeCameraSetting(tbSetting.nDistance, tbSetting.nLookDownAngle, tbSetting.nFov)
end
function Map:OnMapLoaded(nMapTemplateID)
  self.bLoading = false
  Lib:CallBack({
    WeatherMgr.OnMapLoaded,
    WeatherMgr,
    nMapTemplateID
  })
  self:UpdateCamera(nMapTemplateID)
  Map:UpdateMapLoaded(nMapTemplateID)
  if nMapTemplateID == 0 then
    Login:OnMapLoaded()
    Ui:UpateUseRes()
    return
  end
  AsyncBattle:OnLoadMapEnd(nMapTemplateID)
  UiNotify.OnNotify(UiNotify.emNOTIFY_MAP_LOADED, nMapTemplateID)
  Fuben:OnMapLoaded(nMapTemplateID)
  Client:DoSetPlayerDir()
  Partner.PartnerTalk:OnMapLoaded()
  Map:RestartPlayMapSound()
  Task:OnMapLoaded()
  me.OnEvent("OnMapLoaded", nMapTemplateID)
  if me and me.nMapId then
    Map:CheckCloseUi(self.tbOnLoadCloseUi, me.nMapId)
  end
  if tbMapEnterBlackBoardMsg[nMapTemplateID] then
    me.SendBlackBoardMsg(tbMapEnterBlackBoardMsg[nMapTemplateID])
  end
  Player:FlyChar()
  Fuben.WhiteTigerFuben:OnMapLoaded(nMapTemplateID)
  Fuben.KinTrainMgr:OnMapLoaded(nMapTemplateID)
  SeriesFuben:OnMapLoaded(nMapTemplateID)
  CameraAnimation:OnMapLoaded(nMapTemplateID)
  Sdk:GsdkStart()
  Ui:UpdateLoadShowUI(nMapTemplateID)
  Ui:GetClass("HomeScreenTip"):OnMapLoaded(nMapTemplateID)
  Lib:CallBack({
    Map.DoCacheCmd,
    Map
  })
  Lib:CallBack({
    Decoration.OnMapLoaded,
    Decoration
  })
  Lib:CallBack({
    House.OnMapLoaded,
    House,
    nMapTemplateID
  })
  Lib:CallBack({
    Calendar.OnMapLoaded,
    Calendar,
    nMapTemplateID
  })
  Lib:CallBack({
    Wedding.OnMapLoaded,
    Wedding,
    nMapTemplateID
  })
  AutoPath:OnMapLoaded(nMapTemplateID)
  if self.fnOnPeekingLoadMapEnd then
    Lib:CallBack({
      self.fnOnPeekingLoadMapEnd
    })
    self.fnOnPeekingLoadMapEnd = nil
  end
  Log("Client Map:OnMapLoaded ...", nMapTemplateID)
end
function Map:OnPlayerTrap(nMapTemplateID, nMapID, szTrapName, nIsLocal)
  if nIsLocal == 1 then
    Fuben:OnPlayerTrap(nMapID, szTrapName)
  end
  Task:OnPlayerTrap(nMapTemplateID, szTrapName)
  Map:OnChangeCamera(nMapTemplateID, szTrapName)
  Lib:CallBack({
    WeatherMgr.OnPlayerTrap,
    WeatherMgr,
    nMapTemplateID,
    szTrapName
  })
end
function Map:OnNpcTrap(nMapTemplateID, nMapID, szTrapName, nIsLocal)
end
local tbMiniMapNpcPositions = {}
function Map:OnSyncNpcsPos(szType, tbPos)
  tbMiniMapNpcPositions[szType] = tbPos
end
function Map:GetMiniMapPos(szType)
  return tbMiniMapNpcPositions[szType] or {}
end
Map.tbPlaySceneSound = Map.tbPlaySceneSound or {}
function Map:PlayMapSound(nTemplateMapID)
  local tbSound = Map:GetExtraSoundId(nTemplateMapID) or self:GetSoundID(nTemplateMapID)
  for _, nSoundID in pairs(tbSound) do
    if nSoundID and nSoundID > 0 then
      self:PlaySceneSound(nSoundID)
    end
  end
end
function Map:StopMapSound(nDuration)
  nDuration = nDuration or 1500
  for nSoundID, _ in pairs(self.tbPlaySceneSound) do
    Ui:StopSceneSound(nSoundID, nDuration)
  end
  self.tbPlaySceneSound = {}
end
function Map:PlaySceneSound(nSoundID)
  if self.tbPlaySceneSound[nSoundID] then
    return
  end
  Ui:PlaySceneSound(nSoundID)
  self.tbPlaySceneSound[nSoundID] = 1
end
function Map:PlaySceneOneSound(nSoundID)
  self:StopMapSound(1)
  self:PlaySceneSound(nSoundID)
end
function Map:RestartPlayMapSound()
  self:StopMapSound(1)
  self:PlayMapSound(me.nMapTemplateId)
end
function Map:SetCloseUiOnLoad(nMapId, szUiName)
  self.tbOnLoadCloseUi = self.tbOnLoadCloseUi or {}
  self.tbOnLoadCloseUi[szUiName] = nMapId
end
function Map:SetCloseUiOnLeave(nMapId, szUiName)
  self.tbOnLeaveCloseUi = self.tbOnLeaveCloseUi or {}
  self.tbOnLeaveCloseUi[szUiName] = nMapId
end
function Map:CheckCloseUi(tbCloseInfo, nMapId)
  if not tbCloseInfo then
    return
  end
  tbCloseInfo = tbCloseInfo or {}
  local tbInfo = {}
  for szUiName, nMd in pairs(tbCloseInfo) do
    if nMapId == nMd then
      Ui:CloseWindow(szUiName)
      table.insert(tbInfo, szUiName)
    end
  end
  for _, szUiName in pairs(tbInfo) do
    tbCloseInfo[szUiName] = nil
  end
end
function Map:OnSynAllRolePos(tbPosList)
  UiNotify.OnNotify(UiNotify.emNOTIFY_SYN_MAP_ALL_POS, tbPosList)
end
function Map:SwitchMap(nMapId, nMapTemplateId)
  assert(type(nMapId) == "number")
  RemoteServer.OnMapRequest("SwitchMap", nMapId, nMapTemplateId)
end
function Map:GetTransmitPath(nMapTemplateId, nMapId, nX, nY, nParam)
  if ImperialTomb:IsTombMap(nMapTemplateId) then
    return ImperialTomb:GetTransmitPath(nMapTemplateId, nMapId, nX, nY, nParam)
  end
end
function Map:GetAutoFightRadius(nMapTemplateId, nMapId)
  if ImperialTomb:IsTombMap(nMapTemplateId) then
    return ImperialTomb:GetAutoFightRadius(nMapTemplateId, nMapId)
  end
end
function Map:DoCmdWhenMapLoadFinish(nMapId, ...)
  if not self.bLoading and self.nMapId and nMapId == self.nMapId then
    me.CallClientScript(...)
    return
  end
  self.tbCacheCmd = self.tbCacheCmd or {}
  self.tbCacheCmd[nMapId] = self.tbCacheCmd[nMapId] or {}
  table.insert(self.tbCacheCmd[nMapId], {
    ...
  })
end
function Map:DoCacheCmd()
  if not self.nMapId or not self.tbCacheCmd then
    return
  end
  local tbCacheCmd = self.tbCacheCmd[self.nMapId] or {}
  self.tbCacheCmd = {}
  for _, tbCmd in pairs(tbCacheCmd) do
    me.CallClientScript(unpack(tbCmd))
  end
end
function Map:IsMapOnLoading()
  return self.bLoading
end
function Map:LoadMapChangeCamera()
  self.tbSettingMapChangeCamera = {}
  local tbFileData = Lib:LoadTabFile("Setting/Map/MapChangeCamera.tab", {
    MapTID = 1,
    XRoate = 1,
    YRoate = 1,
    ZRoate = 1,
    RoateSpeed = 1
  })
  for _, tbInfo in pairs(tbFileData) do
    self.tbSettingMapChangeCamera[tbInfo.MapTID] = self.tbSettingMapChangeCamera[tbInfo.MapTID] or {}
    self.tbSettingMapChangeCamera[tbInfo.MapTID][tbInfo.TrapName] = tbInfo
  end
end
Map:LoadMapChangeCamera()
function Map:GetMapChangeCamera(nMapTemplateID, szTrapName)
  local tbMapInfo = self.tbSettingMapChangeCamera[nMapTemplateID]
  if not tbMapInfo then
    return
  end
  return tbMapInfo[szTrapName]
end
function Map:OnChangeCamera(nMapTemplateID, szTrapName)
  local tbInfo = self:GetMapChangeCamera(nMapTemplateID, szTrapName)
  if not tbInfo then
    return
  end
  Ui.CameraMgr.CreateCameraCrossRoate(tbInfo.XRoate, tbInfo.YRoate, tbInfo.ZRoate, tbInfo.RoateSpeed)
end
function Map:GetMapPos(nX, nY)
  return nX * Map.CELL_WIDTH + SceneMgr.s_vCurMapInfo.x, nY * Map.CELL_WIDTH + SceneMgr.s_vCurMapInfo.z
end
function Map:IsInMap(nX, nY, tbMapSetting)
  nX, nY = Map:GetMapPos(nX, nY)
  if nX < tbMapSetting.BeginPosX or nX > tbMapSetting.BeginPosX + tbMapSetting.SizeX then
    return false
  end
  if nY < tbMapSetting.BeginPosY or nY > tbMapSetting.BeginPosY + tbMapSetting.SizeY then
    return false
  end
  return true
end
