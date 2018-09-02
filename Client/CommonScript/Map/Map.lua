Map.CELL_WIDTH = 0.01
Map.MiniMapScale = 4
Map.MiniMapSize = 512
Map.nShowPosScale = 0.005
Map.tbMapList = Map.tbMapList or LoadTabFile("Setting/Map/maplist.tab", "dsssdsdddddddddsdddddsdddddsddd", "TemplateId", {
  "TemplateId",
  "ResName",
  "InfoFilePath",
  "MapName",
  "CameraDirAngle",
  "Class",
  "DefaultPosX",
  "DefaultPosY",
  "TeamForbidden",
  "TransForbidden",
  "IsRunSpeed",
  "MapLevel",
  "MapType",
  "SoundID",
  "SoundID1",
  "UiState",
  "NearbyChat",
  "ForcePkMode",
  "ForbidRide",
  "IsPerformance",
  "EffectSoundVolume",
  "LoadingTexture",
  "CamDistance",
  "CamLookDownAngle",
  "CamFOV",
  "Excercise",
  "FightState",
  "MiniMap",
  "FocusAllPet",
  "ForbidTransEnter",
  "ForbidPeeking"
})
Map.tbLoadingTexture = Map.tbLoadingTexture or LoadTabFile("Setting/Map/LoadingTexture.tab", "s", nil, {"szTexture"})
Map.tbMapNpcInfo = Map.tbMapNpcInfo or {}
Map.tbMapTextPosInfo = Map.tbMapTextPosInfo or {}
Map.tbMapExtraSetting = LoadTabFile("Setting/Map/MapExtraInfo.tab", "dss", "MapId", {
  "MapId",
  "ChatDisplay",
  "MiniMapDesc"
})
Map.emMap_None = 0
Map.emMap_Public = 1
Map.emMap_Fuben = 2
Map.emMap_Public_Fuben = 3
Map.tbMapTimeFrame = {
  [406] = "OpenLevel49",
  [407] = "OpenLevel49",
  [408] = "OpenLevel49",
  [410] = "OpenLevel69",
  [411] = "OpenLevel69",
  [412] = "OpenLevel69",
  [413] = "OpenLevel89",
  [414] = "OpenLevel89",
  [415] = "OpenLevel89",
  [416] = "OpenLevel109",
  [417] = "OpenLevel109",
  [418] = "OpenLevel109",
  [419] = "OpenLevel59",
  [420] = "OpenLevel79",
  [421] = "OpenLevel99",
  [422] = "OpenLevel119"
}
Map.tbPublicMapDesc = {
  [999] = "忘忧岛",
  [400] = "锁云渊-10级",
  [401] = "武夷山-10级",
  [402] = "雁荡山-10级",
  [403] = "洞庭湖畔-20级",
  [404] = "苗岭-20级",
  [405] = "点苍山-20级",
  [10] = "襄阳",
  [406] = "响水洞-40级",
  [407] = "见性峰-40级",
  [408] = "剑门关-40级",
  [409] = "夜郎废墟-30级",
  [410] = "荐菊洞-60级",
  [411] = "伏牛山-60级",
  [412] = "古战场-60级",
  [413] = "祁连山-80级",
  [414] = "沙漠遗迹-80级",
  [415] = "敦煌古城-80级",
  [416] = "药王谷-100级",
  [417] = "漠北草原-100级",
  [418] = "长白山-100级",
  [419] = "风陵渡-50级",
  [420] = "太行古径-70级",
  [421] = "昆虚脉藏-90级",
  [422] = "残桓铁城-110"
}
Map.WEDDING_TOUR = 1
Map.WEDDING_TOUR_AFTER = 2
Map.tbExtraSoundSetting = Map.tbExtraSoundSetting or {}
Map.tbExtraSound = Map.tbExtraSound or {}
function Map:InitSetting()
  Map.tbExtraSoundSetting = {
    [Wedding.nTourMapTemplateId] = {
      [Map.WEDDING_TOUR] = {nSoundId = 1002, nPriority = 2},
      [Map.WEDDING_TOUR_AFTER] = {nSoundId = 1001, nPriority = 1}
    }
  }
end
function Map:UpdateExtraSound(nMapTemplateId, tbSound, tbOverdueSound)
  local tbExtraSoundSetting = self:GetExtraSoundSetting(nMapTemplateId)
  if tbExtraSoundSetting and (next(tbSound or {}) or next(tbOverdueSound or {})) then
    local tbExtraSoundCache = self:GetExtraSoundCache(nMapTemplateId)
    for _, nSoundType in ipairs(tbSound) do
      local tbSoundSetting = tbExtraSoundSetting[nSoundType]
      if tbSoundSetting then
        tbSoundSetting.nSoundType = nSoundType
        tbExtraSoundCache[nSoundType] = tbSoundSetting
      end
    end
    for _, nSoundType in ipairs(tbOverdueSound) do
      tbExtraSoundCache[nSoundType] = nil
    end
  end
end
function Map:GetExtraSoundId(nMapTemplateId)
  local fnSort = function(a, b)
    return a.nPriority > b.nPriority
  end
  local tbExtraSoundCache = self:GetExtraSoundCache(nMapTemplateId)
  local tbTempSoundCache = {}
  for _, v in pairs(tbExtraSoundCache) do
    table.insert(tbTempSoundCache, v)
  end
  if #tbTempSoundCache > 1 then
    table.sort(tbTempSoundCache, fnSort)
  end
  return tbTempSoundCache[1] and {
    tbTempSoundCache[1].nSoundId
  }
end
function Map:GetExtraSoundSetting(nMapTemplateId)
  return Map.tbExtraSoundSetting[nMapTemplateId] and Lib:CopyTB(Map.tbExtraSoundSetting[nMapTemplateId])
end
function Map:GetExtraSoundCache(nMapTemplateId)
  Map.tbExtraSound[nMapTemplateId] = Map.tbExtraSound[nMapTemplateId] or {}
  return Map.tbExtraSound[nMapTemplateId]
end
function Map:GetMapDesc(nMapTemplateId)
  return self.tbPublicMapDesc[nMapTemplateId] or self:GetMapName(nMapTemplateId)
end
function Map:LoadTransmit()
  local tbResult = {}
  local tbSetting = Lib:LoadTabFile("Setting/Map/transmit.txt", {JumpKind = 1})
  for _, tbLineData in pairs(tbSetting or {}) do
    local nFromMapID = assert(tonumber(tbLineData.FromMapID))
    tbResult[nFromMapID] = tbResult[nFromMapID] or {}
    tbResult[nFromMapID][tbLineData.Name] = {
      FromPosX = tonumber(tbLineData.FromPosX) or 0,
      FromPosY = tonumber(tbLineData.FromPosY) or 0,
      ToMapID = assert(tonumber(tbLineData.ToMapID)),
      ToPosX = assert(tonumber(tbLineData.ToPosX)),
      ToPosY = assert(tonumber(tbLineData.ToPosY)),
      ToFightState = assert(tonumber(tbLineData.ToFightState)),
      JumpKind = tbLineData.JumpKind,
      JumpGroup = tbLineData.JumpGroup
    }
  end
  self.tbTransferSetting = tbResult
end
function Map:GetCameraSettings(nTemplateId)
  local tbSetting = self:GetMapSetting(nTemplateId)
  if not tbSetting then
    return
  end
  if tbSetting.CamDistance > 0 and tbSetting.CamLookDownAngle ~= 0 and 0 < tbSetting.CamFOV then
    return {
      nDistance = tbSetting.CamDistance,
      nLookDownAngle = tbSetting.CamLookDownAngle,
      nFov = tbSetting.CamFOV
    }
  end
  return nil
end
function Map:GetMapSetting(nTemplateId)
  return Map.tbMapList[nTemplateId]
end
function Map:GetForcePkMode(nTemplateId)
  local tbMapSetting = Map:GetMapSetting(nTemplateId)
  return tbMapSetting.ForcePkMode
end
function Map:GetEnterLevel(nTemplateId)
  local tbMapSetting = Map:GetMapSetting(nTemplateId)
  return tbMapSetting.MapLevel
end
function Map:IsTimeFrameOpen(nTemplateId)
  local szTimeFrame = Map.tbMapTimeFrame[nTemplateId]
  if not szTimeFrame then
    return true
  end
  return GetTimeFrameState(szTimeFrame) == 1
end
function Map:GetMapName(nTemplateId)
  local tbMapSetting = Map:GetMapSetting(nTemplateId)
  return tbMapSetting.MapName
end
function Map:GetMapDescInChat(nTemplateId)
  local tbInfo = Map.tbMapExtraSetting[nTemplateId] or {}
  if Lib:IsEmptyStr(tbInfo.ChatDisplay) then
    return Map:GetMapName(nTemplateId)
  end
  return tbInfo.ChatDisplay
end
function Map:GetMiniMapDesc(nTemplateId)
  local tbInfo = Map.tbMapExtraSetting[nTemplateId] or {}
  return tbInfo.MiniMapDesc
end
function Map:GetMapType(nTemplateId)
  local tbMapSetting = Map:GetMapSetting(nTemplateId) or {}
  return tbMapSetting.MapType or Map.emMap_None
end
function Map:GetMapUiState(nTemplateId)
  local tbMapSetting = Map:GetMapSetting(nTemplateId) or {}
  if not tbMapSetting.tbUiState then
    tbMapSetting.tbUiState = {0, true}
    local nState, szType = string.match(tbMapSetting.UiState, "^(%d+)|*([^|]*)$")
    tbMapSetting.tbUiState[1] = tonumber(nState or "nil") or 0
    if szType and szType == "show" then
      tbMapSetting.tbUiState[2] = false
    end
  end
  return unpack(tbMapSetting.tbUiState)
end
function Map:CanNearbyChat(nTemplateId)
  local tbMapSetting = Map:GetMapSetting(nTemplateId) or {}
  return tbMapSetting.NearbyChat == 1
end
function Map:GetMapInfoPath(nTemplateId)
  local tbMapInfo = Map:GetMapSetting(nTemplateId)
  local szPath = tbMapInfo and "Setting/Map/" .. tbMapInfo.InfoFilePath .. "/npc_info.txt"
  return szPath
end
function Map:GetMapTextPosInfoPath(nTemplateId)
  local tbMapInfo = Map:GetMapSetting(nTemplateId)
  local szPath = tbMapInfo and "Setting/Map/" .. tbMapInfo.InfoFilePath .. "/text_pos_info.tab"
  return szPath
end
function Map:LoadMapNpcInfo(nMapTemplateId)
  local szPath = Map:GetMapInfoPath(nMapTemplateId)
  self.tbMapNpcInfo[nMapTemplateId] = LoadTabFile(szPath, "sdsdddddd", nil, {
    "Index",
    "NpcTemplateId",
    "NpcName",
    "CanAutoPath",
    "XPos",
    "YPos",
    "WalkNearLength",
    "TitleID",
    "HideTaskId"
  })
  self.tbMapNpcByNpcId = self.tbMapNpcByNpcId or {}
  self.tbMapNpcByNpcId[nMapTemplateId] = {}
  if self.tbMapNpcInfo[nMapTemplateId] then
    for _, tbRow in pairs(self.tbMapNpcInfo[nMapTemplateId]) do
      self.tbMapNpcByNpcId[nMapTemplateId][tbRow.NpcTemplateId] = self.tbMapNpcByNpcId[nMapTemplateId][tbRow.NpcTemplateId] or {}
      table.insert(self.tbMapNpcByNpcId[nMapTemplateId][tbRow.NpcTemplateId], tbRow)
    end
  end
end
function Map:GetMapNpcInfoByNpcTemplate(nMapTemplateId, nNpcTemplateId)
  if not Map:GetMapSetting(nMapTemplateId) then
    return
  end
  if not self.tbMapNpcByNpcId[nMapTemplateId] then
    self:LoadMapNpcInfo(nMapTemplateId)
  end
  return self.tbMapNpcByNpcId[nMapTemplateId][nNpcTemplateId]
end
function Map:GetMapNpcInfo(nMapTemplateId)
  if not Map:GetMapSetting(nMapTemplateId) then
    return
  end
  if not self.tbMapNpcInfo[nMapTemplateId] then
    self:LoadMapNpcInfo(nMapTemplateId)
  end
  return self.tbMapNpcInfo[nMapTemplateId]
end
function Map:LoadMapTextPosInfo(nMapTemplateId)
  local szPath = Map:GetMapTextPosInfoPath(nMapTemplateId)
  self.tbMapTextPosInfo[nMapTemplateId] = LoadTabFile(szPath, "sddssdd", nil, {
    "Index",
    "XPos",
    "YPos",
    "Text",
    "Color",
    "FontSize",
    "NotShow"
  }) or {}
end
function Map:GetMapTextPosInfo(nMapTemplateId)
  if not Map:GetMapSetting(nMapTemplateId) then
    return
  end
  if not self.tbMapTextPosInfo[nMapTemplateId] then
    self:LoadMapTextPosInfo(nMapTemplateId)
  end
  return self.tbMapTextPosInfo[nMapTemplateId]
end
function Map:GetClassDesc(nTemplateId)
  local tbMapSetting = Map:GetMapSetting(nTemplateId)
  return tbMapSetting and tbMapSetting.Class or ""
end
function Map:GetSoundID(nTemplateId)
  local tbMapSetting = Map:GetMapSetting(nTemplateId)
  return {
    tbMapSetting.SoundID,
    tbMapSetting.SoundID1
  }
end
function Map:GetDefaultPos(nTemplateId)
  if MODULE_GAMESERVER then
    local _, nX, nY = PlayerEvent:GetRevivePos(nTemplateId)
    if nX and nY then
      return nX, nY
    end
  end
  local tbMapSetting = Map:GetMapSetting(nTemplateId)
  return tbMapSetting.DefaultPosX, tbMapSetting.DefaultPosY, tbMapSetting.FightState
end
function Map:IsRunSpeedMap(nTemplateId)
  local tbMapSetting = Map:GetMapSetting(nTemplateId)
  if tbMapSetting.IsRunSpeed ~= 1 then
    return false
  end
  return true
end
function Map:IsForbidRide(nTemplateId)
  local tbMapSetting = Map:GetMapSetting(nTemplateId)
  if tbMapSetting.ForbidRide ~= 1 then
    return false
  end
  return true
end
function Map:GetEffectSoundVolume(nTemplateId)
  local tbMapSetting = Map:GetMapSetting(nTemplateId)
  if not tbMapSetting then
    return 0
  end
  return tbMapSetting.EffectSoundVolume or 0
end
function Map:IsPerformance(nTemplateId)
  local tbMapSetting = Map:GetMapSetting(nTemplateId)
  if tbMapSetting.IsPerformance ~= 1 then
    return false
  end
  return true
end
function Map:IsFocusAllPet(nTemplateId)
  if WuLinDaHui:IsInMap(nTemplateId) then
    return WuLinDaHui:CanOperateParnter()
  end
  local tbMapSetting = Map:GetMapSetting(nTemplateId)
  if tbMapSetting.FocusAllPet ~= 1 then
    return false
  end
  return true
end
function Map:IsForbidTransEnter(nTemplateId)
  local tbMapSetting = Map:GetMapSetting(nTemplateId)
  if tbMapSetting.ForbidTransEnter ~= 1 then
    return false
  end
  return true
end
function Map:IsForbidPeeking(nTemplateId)
  local tbMapSetting = Map:GetMapSetting(nTemplateId)
  if tbMapSetting.ForbidPeeking ~= 1 then
    return false
  end
  return true
end
function Map:IsFieldFightMap(nTemplateId)
  local szClass = Map:GetClassDesc(nTemplateId)
  if szClass ~= "fight" then
    return false
  end
  return true
end
function Map:IsBossMap(nTemplateId)
  local szClass = Map:GetClassDesc(nTemplateId)
  if szClass ~= "boss" then
    return false
  end
  return true
end
function Map:IsBattleMap(nTemplateId)
  local szClass = Map:GetClassDesc(nTemplateId)
  return szClass == "battle"
end
function Map:IsKinMap(nTemplateId)
  local szClass = Map:GetClassDesc(nTemplateId)
  return szClass == "kin"
end
function Map:IsCityMap(nTemplateId)
  local szClass = Map:GetClassDesc(nTemplateId)
  return szClass == "city"
end
function Map:IsHouseMap(nTemplateId)
  local szClass = Map:GetClassDesc(nTemplateId)
  return szClass == "house"
end
function Map:IsTransForbid(nTemplateId)
  local tbMapSetting = Map:GetMapSetting(nTemplateId)
  return tbMapSetting.TransForbidden > 0
end
local tbHomeMiniMapScale = {battle = 0.5}
function Map:GetMapScale(nTemplateId, bHomeMiniMap)
  local nScale = 1
  local szClass = Map:GetClassDesc(nTemplateId)
  if tbHomeMiniMapScale[szClass] then
    nScale = nScale * tbHomeMiniMapScale[szClass]
  end
  return nScale
end
local tbMapOrgScale = {
  fb_rongyan04 = 0.8,
  fb_rongyan05 = 0.8,
  fb_rongyan07 = 0.8,
  yw_luoyegu = 0.8,
  fb_tianjifang = 0.8,
  yw_xuedi01 = 0.64,
  yw_xuedi02 = 0.64,
  yewai_01 = 0.64,
  yewai_02 = 0.8,
  yw_zhulin01 = 0.64,
  yw_zhulin02 = 0.64,
  fb_xuedi06 = 0.8,
  yw_xiangshuidong = 0.64,
  yw_wuyishan01 = 0.64,
  yw_yelangfeixu01 = 0.64,
  yw_jianmenguan = 0.64,
  baihutang01 = 0.64,
  jj_menpaijingji01 = 0.8,
  jiazhushilian01 = 0.7,
  zc_zhanchang = 0.6,
  cj_luoyang01 = 0.57,
  yw_jianmenguan2 = 0.6,
  yw_jianjudong = 0.64,
  zc_lingtuzhan01 = 0.6,
  zc_lingtuzhan02 = 0.64,
  yw_fenglingdu = 0.64,
  zc_zhanchang03 = 0.6,
  yw_dunhuanggucheng01 = 0.6,
  yw_qilianshan = 0.6,
  yw_shamomigong = 0.6,
  yw_taihanggujing01 = 0.6,
  jj_zhuduileitai01 = 0.8,
  q_qinshi01 = 0.64,
  q_qinshi02 = 0.8,
  q_shinei01 = 0.64,
  q_shinei02 = 0.8,
  q_shinei03 = 0.8,
  q_shinei04 = 0.8,
  fb_huxiaozhandao01 = 0.71,
  yw_mobeicaoyuan = 0.5,
  yw_changbaishan = 0.53,
  yw_yaowanggu = 0.64,
  yw_shunanzhuhai = 0.64,
  cj_linan01 = 0.5,
  lt_yewai_01 = 0.64,
  lt_yw_zhulin02 = 0.64,
  lt_yw_xuedi02 = 0.64,
  lt_yw_xiangshuidong = 0.64,
  lt_yw_xuedi01 = 0.64,
  lt_yw_jianmenguan2 = 0.6,
  lt_yw_jianjudong = 0.64,
  lt_yw_jianmenguan = 0.64,
  jj_wulindahui02 = 0.64,
  yw_canhuantiecheng = 0.6,
  zc_zhanchang04 = 0.56,
  nd_nvdiyizhong01 = 0.56,
  nd_nvdiyizhong02 = 0.9
}
function Map:GetMapOrgScale(szMiniMap)
  local nScale = Map.MiniMapScale
  if tbMapOrgScale[szMiniMap] then
    nScale = nScale * tbMapOrgScale[szMiniMap]
  end
  return nScale
end
local tbMiniMapReplaceTabel = {
  [202] = 201,
  [204] = 201,
  [206] = 201,
  [207] = 201,
  [208] = 201,
  [210] = 201,
  [213] = 201,
  [214] = 201,
  [218] = 201,
  [220] = 201,
  [221] = 201,
  [223] = 201,
  [224] = 201,
  [225] = 201,
  [227] = 201,
  [228] = 201,
  [231] = 201,
  [233] = 201,
  [234] = 201,
  [235] = 201,
  [238] = 201,
  [239] = 201,
  [241] = 201,
  [242] = 201,
  [243] = 201,
  [244] = 201,
  [245] = 201,
  [246] = 201,
  [249] = 201
}
function Map:GetMiniMapInfo(nTemplateId)
  nTemplateId = tbMiniMapReplaceTabel[nTemplateId] or nTemplateId
  local tbMapSetting = Map:GetMapSetting(nTemplateId)
  local szMiniMap = tbMapSetting.MiniMap == "" and tbMapSetting.ResName or tbMapSetting.MiniMap
  local szSettingPath = "Setting/Map/" .. tbMapSetting.InfoFilePath .. "/info.ini"
  local tbIniSetting = Lib:LoadIniFile(szSettingPath)
  local tbMiniMapSetting = tbIniSetting.Setting
  for szKey, szValue in pairs(tbMiniMapSetting) do
    tbMiniMapSetting[szKey] = tonumber(szValue)
  end
  local tbChildMapSetting
  if tbMiniMapSetting.ChildMapCount and tbMiniMapSetting.ChildMapCount > 0 then
    tbChildMapSetting = {}
    for i = 1, tbMiniMapSetting.ChildMapCount do
      local tbChildSetting = tbIniSetting["ChildMap_" .. i]
      assert(tbChildSetting, "unknown child map: " .. nTemplateId .. "*" .. i)
      for szKey, szValue in pairs(tbChildSetting) do
        tbChildSetting[szKey] = tonumber(szValue)
      end
      table.insert(tbChildMapSetting, {
        szMiniMap = string.format("%s_childmap%d", szMiniMap, i),
        tbSetting = tbChildSetting
      })
    end
  end
  return tbMiniMapSetting, szMiniMap, tbChildMapSetting
end
function Map:CheckCanLeave(nTemplateId)
  if not self.tbSafeMap then
    self.tbSafeMap = {
      [QunYingHui.tbDefInfo.nPrepareTempMapID] = 1,
      [Battle.READY_MAP_ID] = 1,
      [Battle.ZONE_READY_MAP_ID] = 1,
      [InDifferBattle.tbDefine.nReadyMapTemplateId] = 1,
      [KinBattle.PRE_MAP_ID] = 1,
      [TeamBattle.PRE_MAP_ID] = 1,
      [TeamBattle.TOP_MAP_ID] = 1,
      [FactionBattle.PREPARE_MAP_TAMPLATE_ID] = 1,
      [FactionBattle.FREEPK_MAP_TAMPLATE_ID] = 1,
      [Fuben.WhiteTigerFuben.PREPARE_MAPID] = 1,
      [BiWuZhaoQin.nPreMapTID] = 1
    }
  end
  return nTemplateId and self.tbSafeMap[nTemplateId]
end
function Map:GetLoadingTexture(bRandom)
  if bRandom then
    self.nLoadingTextureIdx = MathRandom(#self.tbLoadingTexture)
  end
  return (self.tbLoadingTexture[self.nLoadingTextureIdx or 0] or {}).szTexture or "UI/Textures/Loading.jpg"
end
function Map:CheckEnterOtherMap(pPlayer)
  if not Fuben.tbSafeMap[pPlayer.nMapTemplateId] and Map:GetClassDesc(pPlayer.nMapTemplateId) ~= "fight" then
    return false, "所在地图不允许进入！"
  end
  if pPlayer.nFightMode ~= 0 then
    return false, "不在安全区，不允许进入！"
  end
  local bRet = Map:IsForbidTransEnter(pPlayer.nMapTemplateId)
  if bRet then
    return false, "目标地图无法传送!"
  end
  if not Env:CheckSystemSwitch(pPlayer, Env.SW_SwitchMap) then
    return false, "当前状态不允许切换地图"
  end
  return true, ""
end
function Map:GetDesTransTrap(nFromId, nToId)
  local tbList = {}
  for nFromMapId, tbTrapList in pairs(self.tbTransferSetting) do
    if nFromId == nFromMapId then
      for szTrapName, tbTrapInfo in pairs(tbTrapList) do
        if nToId == tbTrapInfo.ToMapID then
          table.insert(tbList, {
            nFromMapId = nFromMapId,
            szTrapName = szTrapName,
            nFromX = tbTrapInfo.FromPosX,
            nFromY = tbTrapInfo.FromPosY,
            nToMapId = nToId,
            nToX = tbTrapInfo.ToPosX,
            nToY = tbTrapInfo.ToPosY
          })
        end
      end
    end
  end
  return tbList
end
function Map:GetNearestTransTrap(nFromId, nFromX, nFromY, nToId, nX, nY)
  local tbList = self:GetDesTransTrap(nFromId, nToId)
  if #tbList <= 0 then
    return nil
  end
  local nLen, tbTrapInfo
  for _, tbInfo in pairs(tbList) do
    local nDistance = 0
    if nX and nY then
      nDistance = nDistance + Lib:GetDistance(nX, nY, tbInfo.nToX, tbInfo.nToY)
    end
    if nFromX and nFromY then
      nDistance = nDistance + Lib:GetDistance(nFromX, nFromY, tbInfo.nFromX, tbInfo.nFromY)
    end
    if not nLen or nLen > nDistance then
      nLen = nDistance
      tbTrapInfo = tbInfo
    end
  end
  return tbTrapInfo, nLen
end
function Map:SetMapNpcInfoCanAutoPath(nMapTemplateId, szInfoIndex, nCanAutoPath)
  if not self.tbMapNpcInfo[nMapTemplateId] then
    self:LoadMapNpcInfo(nMapTemplateId)
  end
  if not self.tbMapNpcInfo[nMapTemplateId] then
    return
  end
  for _, tbRow in pairs(self.tbMapNpcInfo[nMapTemplateId]) do
    if tbRow.Index == szInfoIndex then
      tbRow.CanAutoPath = nCanAutoPath
    end
  end
end
function Map:SetMapTextPosInfoNotShow(nMapTemplateId, szInfoIndex, nNotShow)
  if not self.tbMapTextPosInfo[nMapTemplateId] then
    self:LoadMapTextPosInfo(nMapTemplateId)
  end
  if not self.tbMapTextPosInfo[nMapTemplateId] then
    return
  end
  for _, tbRow in pairs(self.tbMapTextPosInfo[nMapTemplateId]) do
    if tbRow.Index == szInfoIndex then
      tbRow.NotShow = nNotShow
    end
  end
end
Map:LoadTransmit()
