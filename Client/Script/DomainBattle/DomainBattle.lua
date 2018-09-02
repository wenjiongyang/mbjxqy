DomainBattle.tbFightData = {}
local define = DomainBattle.define
function DomainBattle:GetFlogNpcName(nMapTemplateId, nIndex)
  local tbFlogNpcPos = self.tbMapPosSetting[nMapTemplateId].tbFlogNpcPos
  local tbNpcInfo = tbFlogNpcPos[nIndex]
  if tbNpcInfo then
    return KNpc.GetNameByTemplateId(tbNpcInfo[1])
  end
end
function DomainBattle:SynFightData()
  RemoteServer.DomainBattleSynFightData(self.nBattleReportVersion)
end
function DomainBattle:OnSynFightData(tbData, nBattleReportVersion)
  tbData = tbData or {}
  DomainBattle.tbFightData.nAttackMapId = tbData.nAttackMapId
  DomainBattle.tbFightData.nDefendMapId = tbData.nDefendMapId
  DomainBattle.tbFightData.tbAttakInfo = tbData.tbAttakInfo
  DomainBattle.tbFightData.tbDefendInfo = tbData.tbDefendInfo
  self:SetClientLeftTime(tbData.nLeftTime)
  DomainBattle.tbFightData.nAttackCampIndex = tbData.nAttackCampIndex
  DomainBattle.tbFightData.tbScore = self:FormatScore(tbData.tbScore)
  DomainBattle.tbFightData.tbField = self:FormatField()
  self.nBattleReportVersion = nBattleReportVersion
  UiNotify.OnNotify(UiNotify.emNOTIFY_ONSYNC_DOMAIN_REPORT)
end
function DomainBattle:OnSynBattleSupply(tbBattleSupply, tbUseTimes)
  self.tbBattleSupply = tbBattleSupply
  self.tbBattleSupplyUseTimes = tbUseTimes
  UiNotify.OnNotify(UiNotify.emNOTIFY_ONSYNC_DOMAIN_SUPPLY)
end
function DomainBattle:OnSynDomainGameTime(nLeftTime)
  self:SetClientLeftTime(nLeftTime)
end
function DomainBattle:OnSyncBaseInfo(tbData, tbBattleSupply, nVersionBaseData)
  if nVersionBaseData then
    self.nVersionBaseData = nVersionBaseData
  end
  if tbData then
    self.tbBaseInfo = tbData
    local tbMapDeclareNum = {}
    for dwKinId, nMapId in pairs(tbData.tbMapDeclare) do
      tbMapDeclareNum[nMapId] = (tbMapDeclareNum[nMapId] or 0) + 1
    end
    self.tbBaseInfo.tbMapDeclareNum = tbMapDeclareNum
    self.tbBaseInfo.nWarDeclareMap = tbData.tbMapDeclare[me.dwKinId]
    for nMapId, v in pairs(tbData.tbMapOwner) do
      if v[1] == me.dwKinId then
        self.nMyOwnerMapId = nMapId
        break
      end
    end
  end
  if tbBattleSupply then
    self.tbBattleSupply = tbBattleSupply
  end
  UiNotify.OnNotify(UiNotify.emNOTIFY_ONSYNC_DOMAIN_BASE)
  UiNotify.OnNotify(UiNotify.emNOTIFY_ONSYNC_DOMAIN_SUPPLY)
end
function DomainBattle:GetCanUseBattleSupplys()
  if not self:CanUseBattleSupplys() then
    return
  end
  local tbBattleSupply = self.tbBattleSupply or {}
  local tbBattleSupplyUseTimes = self.tbBattleSupplyUseTimes or {}
  local tbRes = {}
  for nTemplateId, nNum in pairs(tbBattleSupply) do
    local nLimit = define.tbBattleApplyLimit[nTemplateId]
    if nLimit then
      nNum = math.min(nNum, nLimit - (tbBattleSupplyUseTimes[nTemplateId] or 0))
    end
    tbRes[nTemplateId] = nNum
  end
  return tbRes
end
function DomainBattle:OnSynMiniMapInfo(tbSynInfo)
  local tbMapTextPosInfo = Map:GetMapTextPosInfo(me.nMapTemplateId)
  for i, v in ipairs(tbMapTextPosInfo) do
    local szNewName = tbSynInfo[v.Index]
    if szNewName then
      v.Text = szNewName
    end
  end
end
function DomainBattle:OnSynMiniMainMapInfo(nLeaderId)
  local tbSynInfo = {}
  tbSynInfo[self.define.szMapMasterIndex] = nLeaderId and "襄阳城主" or ""
  self:OnSynMiniMapInfo(tbSynInfo)
end
function DomainBattle:OnDeclareWarscucces(nMapTemplateId)
  local szMsg = string.format("本家族当前宣战目标变更为「%s」，开战后只能攻打宣战目标。", Map:GetMapName(nMapTemplateId))
  me.CenterMsg(szMsg)
  self.tbBaseInfo = self.tbBaseInfo or {}
  self.tbBaseInfo.nWarDeclareMap = nMapTemplateId
  Ui:CloseWindow("DomainBattleTip")
  UiNotify.OnNotify(UiNotify.emNOTIFY_ONSYNC_DOMAIN_BASE)
end
function DomainBattle:FormatField()
  local tbField = {}
  if DomainBattle.tbFightData.nAttackMapId then
    table.insert(tbField, {
      nMapId = DomainBattle.tbFightData.nAttackMapId,
      tbKinInfo = DomainBattle.tbFightData.tbAttakInfo
    })
  end
  if DomainBattle.tbFightData.nDefendMapId then
    table.insert(tbField, {
      nMapId = DomainBattle.tbFightData.nDefendMapId,
      tbKinInfo = DomainBattle.tbFightData.tbDefendInfo
    })
  end
  return tbField
end
function DomainBattle:FormatScore(tbTemp)
  tbTemp = tbTemp or {}
  local tbScore = {}
  for nPlayerId, tbInfo in pairs(tbTemp) do
    local tbPlayerInfo = {}
    tbPlayerInfo.nScore = tbInfo[1]
    tbPlayerInfo.nKillNum = tbInfo[2]
    tbPlayerInfo.szRoleName = tbInfo[3]
    tbPlayerInfo.nPlayerId = nPlayerId
    table.insert(tbScore, tbPlayerInfo)
  end
  return self:SortScore(tbScore)
end
function DomainBattle:SortScore(tbScore)
  local Sort = function(a, b)
    if a.nScore == b.nScore then
      return a.nKillNum > b.nKillNum
    end
    return a.nScore > b.nScore
  end
  table.sort(tbScore, Sort)
  return tbScore
end
function DomainBattle:MyRank(pPlayer)
  for nRank, tbInfo in pairs(DomainBattle.tbFightData.tbScore) do
    if pPlayer.dwID == tbInfo.nPlayerId then
      return nRank
    end
  end
end
function DomainBattle:CanUseBattleSupplys()
  local tbCareer = Kin:GetMemberCareer()
  if not tbCareer or not next(tbCareer) then
    Kin:UpdateMemberCareer()
    return
  end
  local nCareer = tbCareer[me.dwID]
  return define.tbCanUseItemCareer[nCareer]
end
function DomainBattle:UseBattleSupplys(nTemplateId)
  local nNow = GetTime()
  if self.RequestUseSupplysTime == nNow then
    return
  end
  self.RequestUseSupplysTime = nNow
  if not self:CanUseBattleSupplys() then
    me.CenterMsg("您的权限不够")
    return
  end
  RemoteServer.DomainBattleUseSupplys(nTemplateId)
end
function DomainBattle:UpdateDomainBattleInfo()
  if not Kin:HasKin() then
    return
  end
  if GetTimeFrameState(define.szOpenTimeFrame) ~= 1 then
    return
  end
  RemoteServer.DomainBattleRequestBaseInfo(self.nVersionBaseData)
  return true
end
function DomainBattle:DeclareWar(nMapTemplateId)
  local tbCareer = Kin:GetMemberCareer()
  if not tbCareer or not next(tbCareer) then
    Kin:UpdateMemberCareer()
    return
  end
  local nCareer = tbCareer[me.dwID]
  if not define.tbCanDeclareCareer[nCareer] then
    me.CenterMsg("您不是家族族长或副族长，无法宣战")
    return
  end
  RemoteServer.DomainBattleDeclareWar(nMapTemplateId)
end
function DomainBattle:PlayerSign()
  RemoteServer.DomainBattlePlayerSignUp()
end
function DomainBattle:EnterFightMap(nState, nTime, tbCampNpcs)
  Ui:OpenWindow("BloodPanel", tbCampNpcs)
  self:CanUseBattleSupplys()
  self:UpdateDomainBattleInfo()
  Ui:OpenWindow("DomainBattleHomeInfo", nState, nTime)
  Ui:CloseWindow("KinDetailPanel")
  local nUiState, bHide = Map:GetMapUiState(me.nMapTemplateId)
  Ui:ChangeUiState(nUiState, bHide)
  self:OnMapLoaded()
  if not self.bRegistNotofy then
    UiNotify:RegistNotify(UiNotify.emNOTIFY_MAP_ENTER, self.OnEnterNewMap, self)
    UiNotify:RegistNotify(UiNotify.emNOTIFY_MAP_LEAVE, self.OnLeaveCurMap, self)
    UiNotify:RegistNotify(UiNotify.emNOTIFY_MAP_LOADED, self.OnMapLoaded, self)
    self.bRegistNotofy = true
  end
end
function DomainBattle:OnMapLoaded()
  Timer:Register(1, function()
    UiNotify.OnNotify(UiNotify.emNOTIFY_SHOWTEAM_NO_TASK)
  end)
end
function DomainBattle:GetClientLeftTime()
  return self.nClientLeftTime
end
function DomainBattle:SetClientLeftTime(nSetTime, nAddTime)
  if nSetTime == 0 then
    return
  end
  if nSetTime then
    self.nClientLeftTime = nSetTime
  end
  if nAddTime then
    self.nClientLeftTime = self.nClientLeftTime + nAddTime
  end
end
function DomainBattle:ShowComboKillCount(nComboCount)
  if Ui:WindowVisible("DomainBattleHomeInfo") == 1 then
    local tbWndUi = Ui("DomainBattleHomeInfo")
    tbWndUi:PlayComboAni(nComboCount)
  end
end
function DomainBattle:OnLeaveCurMap(nMapTemplateId)
  self:OnCloseBattleMap()
end
function DomainBattle:OnEnterNewMap(nMapTemplateId)
  if not self:GetMapLevel(nMapTemplateId) then
    self:OnCloseBattleMap()
  end
end
function DomainBattle:OnCloseBattleMap()
  Ui:ChangeUiState(0, true)
  Ui:CloseWindow("DomainBattleHomeInfo")
  if self.bRegistNotofy then
    UiNotify:UnRegistNotify(UiNotify.emNOTIFY_MAP_ENTER, self)
    UiNotify:UnRegistNotify(UiNotify.emNOTIFY_MAP_LEAVE, self)
    UiNotify:UnRegistNotify(UiNotify.emNOTIFY_MAP_LOADED, self)
    self.bRegistNotofy = nil
  end
end
function DomainBattle:ClearData()
  self.nVersionBaseData = nil
  self.tbBaseInfo = nil
  self.nBattleReportVersion = 0
  self.tbBattleSupply = nil
  self.tbBattleSupplyUseTimes = nil
  self.tbCampNpcs = nil
end
