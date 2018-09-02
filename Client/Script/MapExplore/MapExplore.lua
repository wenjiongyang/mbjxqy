local nBoxNpcId = 208
local tbCharacterIds = {
  [1] = 275,
  [2] = 276,
  [3] = 277,
  [4] = 278,
  [5] = 1231,
  [6] = 1232,
  [7] = 1849,
  [8] = 1850
}
local tbMapStepSetting = MapExplore.tbMapStepSetting
function MapExplore:CheckTimes()
  local nDegree = DegreeCtrl:GetDegree(me, "MapExplore")
  if nDegree <= 0 then
    me.BuyTimes("MapExplore", 5)
    return
  end
  return true
end
function MapExplore:Begin(nMapTemplateId, nStep)
  self.nMapTemplateId = nMapTemplateId
  self.nStep = nStep
  self.bCanMove = false
  self.nSerCallBackCalledTime = nil
  self.nRequestTime = 0
  self.bMapLoaded = false
  self.nMapLoadCallBack = PlayerEvent:Register(me, "OnMapLoaded", self.OnMapLoaded, self)
  Ui:OpenWindow("ExplorationFubenPanel", self:GetMapGetItems(nMapTemplateId))
end
function MapExplore:GetMapGetItems(nMapTemplateId)
  if self.nLastnMapTemplateId and self.nLastnMapTemplateId == nMapTemplateId then
    self.tbLastGetItems = self.tbLastGetItems or {}
    self.nTotalCoin = self.nTotalCoin or 0
  else
    self.tbLastGetItems = {}
    self.nTotalCoin = 0
    self.nLastnMapTemplateId = nMapTemplateId
  end
  return self.tbLastGetItems
end
function MapExplore:OnMapLoaded(nMapTemplateId)
  self.bMapLoaded = true
  MapExplore.bCanMove = true
  if nMapTemplateId ~= MapExplore.nMapTemplateId then
    me.OnEvent("StopAutoPath")
    MapExplore:RequestLeave()
    self:CloseExplore()
    return
  end
  MapExplore:CheckLeave()
  OpenAllDynamicObstacle(nMapTemplateId)
  if MapExplore.nStep == 0 then
    local tbStepInfo = tbMapStepSetting[nMapTemplateId][1]
    me.GetNpc().SetDir(tbStepInfo[3])
  end
  Ui:ChangeUiState(Ui.STATE_MAPEXPLORE, true)
  AutoFight:Stop()
  local npcRep = Ui.Effect.GetNpcRepresent(me.GetNpc().nId)
  if npcRep then
    npcRep:ShowHeadUI(false)
  end
end
function MapExplore:CloseExplore()
  self.nMapTemplateId = nil
  self.nStep = nil
  Ui:CloseWindow("ExplorationFubenPanel")
  if self.nMapLoadCallBack then
    PlayerEvent:UnRegister(me, "OnMapLoaded", self.nMapLoadCallBack)
    self.nMapLoadCallBack = nil
  end
end
function MapExplore:OnWalkEnd()
  self.nStep = self.nStep + 1
  self.tbMapStepInfo[self.nMapTemplateId] = self.nStep
  RemoteServer.MapExploreWalkEnd(self.nMapTemplateId)
end
function MapExplore:OnServerWalkEnd(nKind, ...)
  self.nSerCallBackCalledTime = GetTime()
  if nKind == MapExplore.KIND_ENNEMY then
    local tbRoleInfo = select(1, ...)
    if not tbRoleInfo then
      UiNotify.OnNotify(UiNotify.emNOTIFY_MAP_EXPLORE_PANEL, "OnEndFindNothing")
      self:CheckLeave()
    else
      Ui:OpenWindow("MeetEnemyPanel", tbRoleInfo)
    end
  elseif nKind == MapExplore.KIND_ITEM then
    UiNotify.OnNotify(UiNotify.emNOTIFY_MAP_EXPLORE_PANEL, "PlayerAniGetItem", ...)
    self:CheckLeave()
  elseif nKind == MapExplore.KIND_COIN then
    UiNotify.OnNotify(UiNotify.emNOTIFY_MAP_EXPLORE_PANEL, "PlayerAniGetCoin", ...)
    self:CheckLeave()
  end
end
function MapExplore:OnFindEnemy(tbEnemyInfo, nStep)
  if not tbEnemyInfo then
    self:OnFindAward()
    return
  end
  local nNpcTempId = tbCharacterIds[tbEnemyInfo.nFaction]
  nNpcTempId = nNpcTempId or KPlayer.GetPlayerInitInfo(tbEnemyInfo.nFaction).nNpcTemplateId
  local tbNextPos = tbMapStepSetting[self.nMapTemplateId][nStep + 1]
  local _, _, nX, nY, nDir = unpack(tbNextPos)
  local nDir = nDir + 32
  if nDir > 63 then
    nDir = nDir - 63
  end
  local pNpc = KNpc.Add(nNpcTempId, 1, 0, 0, nX, nY, 0, nDir)
  assert(pNpc)
  pNpc.SetAiActive(0)
  pNpc.szName = tbEnemyInfo.szName
  pNpc.nCamp = 2
  pNpc.nStep = nStep
  if tbEnemyInfo.szKinName then
    pNpc.szKinTitle = tbEnemyInfo.szKinName
  end
  self.nBoxNpcId = pNpc.nId
end
function MapExplore:OnFindAward(nStep)
  local tbNextPos = tbMapStepSetting[self.nMapTemplateId][nStep + 1]
  local _, _, nX, nY, nDir = unpack(tbNextPos)
  local pNpc = KNpc.Add(nBoxNpcId, 1, -1, 0, nX, nY, 0, nDir)
  assert(pNpc)
  self.nBoxNpcId = pNpc.nId
  pNpc.nStep = nStep
end
function MapExplore:GetMapStepInfo()
  local nToDay = Lib:GetLocalDay(GetTime() - 14400)
  if not self.nLastUpdateDay or self.nLastUpdateDay ~= nToDay then
    self:RequestData()
    self.nLastUpdateDay = nToDay
  elseif self.tbMapStepInfo then
    return true
  end
end
function MapExplore:ResponseUpdateMapExplore(tbMapStepInfo, tbResetInfo)
  self.tbMapStepInfo = tbMapStepInfo
  self.tbResetInfo = tbResetInfo
  UiNotify.OnNotify(UiNotify.emNOTIFY_FUBEN_SECTION_PANEL, "UpdateMapExplore")
end
function MapExplore:CheckLeave()
  if self.nStep == self.MAX_STEP then
    MapExplore:ReadyToLeave()
  end
end
function MapExplore:ReadyToLeave()
  local nTime = 5
  local bOpened = false
  self.nTimer = Timer:Register(Env.GAME_FPS * 1, function()
    if self.bCanMove and not bOpened then
      Ui:OpenWindow("AutoLeaveTip", nTime)
      bOpened = true
    end
    nTime = nTime - 1
    if nTime < 0 then
      self.nTimer = nil
      RemoteServer.MapExploreWalkLeave()
      return
    else
      return true
    end
  end)
end
function MapExplore:RequestLeave()
  if not self.bCanMove then
    return
  end
  if self.nTimer then
    Timer:Close(self.nTimer)
    self.nTimer = nil
  end
  local function fnYes()
    Ui:CloseWindow("AutoLeaveTip")
    RemoteServer.MapExploreWalkLeave()
    self.nLastnMapTemplateId = nil
  end
  if DegreeCtrl:GetDegree(me, "MapExplore") > 0 and self.nStep and self.nStep >= 1 and self.nStep < self.MAX_STEP then
    me.MsgBox("你还有当前副本的探索次数，请问确定离开吗？", {
      {"确定", fnYes},
      {"取消"}
    })
  else
    fnYes()
  end
end
function MapExplore:ClearData()
  self.tbMapStepInfo = nil
  self.tbResetInfo = {}
  self.nLastUpdateDay = nil
end
function MapExplore:RequestData()
  RemoteServer.RequestUpdateMapExplore()
  MapExplore.tbMapStepInfo = {}
  MapExplore.tbResetInfo = {}
end
function MapExplore:ClentRequeestReset(nMapTemplateId)
  local function fnYes()
    if me.GetMoney("Gold") < self.RESET_COST then
      Ui:OpenWindow("CommonShop", "Recharge", "Recharge")
      return
    end
    RemoteServer.MapExploreReset(nMapTemplateId)
  end
  Ui:OpenWindow("MessageBox", string.format("您是否要花费 [FFFE0D]%d元宝[-] 来重置当前地图的探索进度？", self.RESET_COST), {
    {fnYes},
    {}
  }, {"确定", "取消"})
end
local fnOnCLoseMapAttackCallBack = function()
  me.Revive()
  Ui:CloseWindow("QYHbattleInfo")
  RemoteServer.ReEnterExplore()
end
function MapExplore:OnClientAttackResult(nResult, tbRoleInfo, nMinusHate, nRobCoin)
  Ui:OpenWindow("WantedAccountS", nResult == 1, tbRoleInfo, nMinusHate, {
    "Coin",
    nRobCoin,
    szKindName = "巧遇目标"
  }, true, fnOnCLoseMapAttackCallBack)
end
