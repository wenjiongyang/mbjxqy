Require("CommonScript/Battle/Battle.lua")
Battle.tbDotaCom = Battle.tbDotaCom or {}
local tbDotaCom = Battle.tbDotaCom
local RREFRESH_ACTIVE_TIME = 2
function tbDotaCom.Setup(tbClass, tbSetting)
  local tbMovePath = {}
  local tbNpcScoreSetting = {}
  local tbWildNpcSetting = {}
  local tbCommNpc = {}
  local tbDropBuff = {}
  local tbTrapBuff = {}
  if tbSetting.fileMovePath then
    local tbFile = LoadTabFile(tbSetting.fileMovePath, "ddd", nil, {
      "Index",
      "nX",
      "nY"
    })
    for _, v in ipairs(tbFile) do
      tbMovePath[v.Index] = tbMovePath[v.Index] or {}
      table.insert(tbMovePath[v.Index], {
        v.nX,
        v.nY
      })
    end
  end
  if tbSetting.fileWildNpc then
    tbWildNpcSetting = LoadTabFile(tbSetting.fileWildNpc, "dddddddddddsssss", nil, {
      "nBornTime",
      "nNpcId",
      "nTeam",
      "nLevel",
      "nNum",
      "nPosX",
      "nPosY",
      "nDir",
      "nScore",
      "nMovePath",
      "nRespawnTime",
      "AwardType",
      "AwadParam",
      "DieMsg",
      "BornMsg",
      "AllNotify"
    })
    for i, v in ipairs(tbWildNpcSetting) do
      v.AwadParam = string.gsub(v.AwadParam, "\"", "")
      v.tbAwardParam = {
        Lib:Str2Val(v.AwadParam)
      }
      v.AwadParam = nil
      tbNpcScoreSetting[v.nNpcId] = tbNpcScoreSetting[v.nNpcId] or {}
      tbNpcScoreSetting[v.nNpcId][v.nLevel] = {
        v.nScore,
        string.gsub(v.DieMsg, "\"", ""),
        string.gsub(v.AllNotify, "\"", "")
      }
      v.nScore = nil
      v.DieMsg = nil
      v.AllNotify = nil
      if v.nTeam == 0 then
        v.nTeam = 3
      end
      v.Index = i
    end
  end
  if tbSetting.fileDropBuff then
    tbDropBuff = LoadTabFile(tbSetting.fileDropBuff, "dsdd", nil, {
      "nBornTime",
      "DropBuffer",
      "nPosX",
      "nPosY"
    })
    for i, v in ipairs(tbDropBuff) do
      assert(Item.Obj:PraseDropInfo(v.DropBuffer), v.DropBuffer)
    end
  end
  if tbSetting.fileTrapBuff then
    tbTrapBuff = LoadTabFile(tbSetting.fileTrapBuff, "dsdddddd", nil, {
      "nBornTime",
      "TrapName",
      "nPosX",
      "nPosY",
      "nBuffNpcId",
      "nBUffId",
      "nBuffLevel",
      "nBuffTime"
    })
  end
  if tbSetting.fileCommNpc then
    local tbFile = LoadTabFile(tbSetting.fileCommNpc, "ddddddddss", nil, {
      "nNpcTemplateId",
      "nLevel",
      "nPosX",
      "nPosY",
      "nDir",
      "nAddScoreTime",
      "nKillAddScore",
      "nNormalScore",
      "szDieMsg",
      "szNormalMsg"
    })
    for nIndex, v in ipairs(tbFile or {}) do
      tbCommNpc[nIndex] = v
      tbCommNpc[nIndex].nNpcId = nil
    end
  end
  tbClass.tbMovePath = tbMovePath
  tbClass.tbNpcScoreSetting = tbNpcScoreSetting
  tbClass.tbWildNpcSetting = tbWildNpcSetting
  tbClass.tbCommNpc = tbCommNpc
  tbClass.tbDropBuff = tbDropBuff
  tbClass.tbTrapBuff = tbTrapBuff
end
function tbDotaCom.Init(tbInst)
  tbInst.nNpcRefreshTime = tbInst.tbBattleSetting.nNpcRefreshTime
  tbInst.nLastRefreshNpcActTime = 0
  tbInst.tbAllMoveNpc = {}
  tbInst.tbWildNpcPos = {}
  tbInst.tbCommNpcInst = Lib:CopyTB(tbInst.tbCommNpc)
end
local fnAddNpcFunc = function(nNpcTemplate, nLevel, nMapId, nX, nY, nDir)
  return KNpc.Add(nNpcTemplate, nLevel, 0, nMapId or 0, nX, nY, 0, nDir)
end
function tbDotaCom.AddBattleNpc(tbInst, tbInfo)
  if not tbInst.nActiveTimer then
    return
  end
  for i = 1, tbInfo.nNum do
    local szPosKey = tbInfo.nPosX .. "," .. tbInfo.nPosY
    if tbInfo.nMovePath == 0 then
      local nOldNpcId = tbInst.tbWildNpcPos[szPosKey]
      if nOldNpcId then
        local pOldNpc = KNpc.GetById(nOldNpcId)
        if pOldNpc then
          pOldNpc.Delete()
        end
        tbInst.tbWildNpcPos[szPosKey] = nil
      end
    end
    local pNpc = fnAddNpcFunc(tbInfo.nNpcId, tbInfo.nLevel, tbInst.nMapId, tbInfo.nPosX, tbInfo.nPosY, tbInfo.nDir)
    if pNpc then
      pNpc.nSettingIndex = tbInfo.Index
      pNpc.SetPkMode(3, tbInfo.nTeam)
      if tbInfo.nMovePath == 0 then
        tbInst.tbWildNpcPos[szPosKey] = pNpc.nId
      else
        table.insert(tbInst.tbAllMoveNpc, pNpc.nId)
        pNpc.SetActiveForever(1)
        pNpc.AI_ClearMovePathPoint()
        for _, Pos in ipairs(tbInst.tbMovePath[tbInfo.nMovePath]) do
          pNpc.AI_AddMovePos(unpack(Pos))
        end
        pNpc.AI_StartPath()
      end
      tbInst.tbWildNpc[pNpc.nId] = tbInfo
      if tbInfo.BornMsg ~= "" then
        tbInst:BlackMsg(tbInfo.BornMsg)
      end
    end
  end
end
function tbDotaCom.StartFight(tbInst)
  tbInst.tbWildNpc = {}
  tbDotaCom.InitCommNpc(tbInst)
  for i, v in ipairs(tbInst.tbWildNpcSetting) do
    Timer:Register(Env.GAME_FPS * v.nBornTime, tbDotaCom.AddBattleNpc, tbInst, v)
  end
end
function tbDotaCom.AddDropBuff(tbInst, tbInfo)
  if not tbInst.nActiveTimer then
    return
  end
  Item.Obj:DropBuffer(tbInst.nMapId, tbInfo.nPosX, tbInfo.nPosY, tbInfo.DropBuffer)
end
function tbDotaCom.StartAddDropBuff(tbInst)
  for i, v in ipairs(tbInst.tbDropBuff) do
    Timer:Register(Env.GAME_FPS * v.nBornTime, tbDotaCom.AddDropBuff, tbInst, v)
  end
end
function tbDotaCom.AddTrapBuff(tbInst, tbInfo)
  if not tbInst.nActiveTimer then
    return
  end
  tbInst.tbTrapBuffInstance = tbInst.tbTrapBuffInstance or {}
  local tbTrap = tbInst.tbTrapBuffInstance[tbInfo.TrapName] or {}
  tbInst.tbTrapBuffInstance[tbInfo.TrapName] = tbTrap
  if tbTrap.nBUffNpcId then
    local pNpc = KNpc.GetById(tbTrap.nBUffNpcId)
    if pNpc then
      pNpc.Delete()
    end
    tbTrap.nBUffNpcId = nil
  end
  tbTrap.tbTrapInfo = tbInfo
  local pNpc = fnAddNpcFunc(tbInfo.nBuffNpcId, 1, tbInst.nMapId, tbInfo.nPosX, tbInfo.nPosY)
  if pNpc then
    tbTrap.nBUffNpcId = pNpc.nId
  end
end
function tbDotaCom.StartAddTrapBuff(tbInst)
  for i, v in ipairs(tbInst.tbTrapBuff) do
    Timer:Register(Env.GAME_FPS * v.nBornTime, tbDotaCom.AddTrapBuff, tbInst, v)
  end
end
function tbDotaCom.OnPlayerTrap(tbInst, szTrapName, pPlayer)
  if tbInst.tbTrapBuffInstance then
    local tbTrap = tbInst.tbTrapBuffInstance[szTrapName]
    if tbTrap then
      local nBUffNpcId = tbTrap.nBUffNpcId
      if nBUffNpcId then
        local pNpc = KNpc.GetById(nBUffNpcId)
        if pNpc then
          pNpc.Delete()
          local tbTrapInfo = tbTrap.tbTrapInfo
          pPlayer.AddSkillState(tbTrapInfo.nBUffId, tbTrapInfo.nBuffLevel, 0, Env.GAME_FPS * tbTrapInfo.nBuffTime)
        end
        tbTrap.nBUffNpcId = nil
      end
    end
  end
end
function tbDotaCom.InitCommNpc(tbInst)
  for nIndex, tbNpcInfo in pairs(tbInst.tbCommNpcInst) do
    tbDotaCom.CreateCommNpc(tbInst, nIndex)
  end
end
function tbDotaCom.CreateCommNpc(tbInst, nIndex, nTeamIndex)
  local tbNpcInfo = tbInst.tbCommNpcInst[nIndex]
  local pNpc = fnAddNpcFunc(tbNpcInfo.nNpcTemplateId, tbNpcInfo.nLevel, tbInst.nMapId, tbNpcInfo.nPosX, tbNpcInfo.nPosY, tbNpcInfo.nDir)
  pNpc.nBattleCommIndex = nIndex
  pNpc.SetName((tbInst.tbTeamNames[nTeamIndex or 3] or "无人") .. "占领")
  pNpc.SetPkMode(3, nTeamIndex or 3)
  pNpc.nTeamIndex = nTeamIndex
  tbNpcInfo.nNextScoreTime = nTeamIndex and GetTime() + tbNpcInfo.nAddScoreTime or 0
  tbNpcInfo.nNpcId = pNpc.nId
end
function tbDotaCom.Active(tbInst, nTimeNow)
  if nTimeNow - tbInst.nLastRefreshNpcActTime >= RREFRESH_ACTIVE_TIME then
    local tbNewMoveNpcs = {}
    for i, nNpcId in ipairs(tbInst.tbAllMoveNpc) do
      local pNpc = KNpc.GetById(nNpcId)
      if pNpc then
        pNpc.SetActiveForever(1)
        table.insert(tbNewMoveNpcs, nNpcId)
      end
    end
    tbInst.tbAllMoveNpc = tbNewMoveNpcs
    tbInst.nLastRefreshNpcActTime = nTimeNow
  end
  if tbInst.nBattleOpen == 1 then
    for nIndex, tbNpcInfo in pairs(tbInst.tbCommNpcInst) do
      if tbNpcInfo.nNpcId > 0 and 0 < tbNpcInfo.nNextScoreTime and nTimeNow >= tbNpcInfo.nNextScoreTime then
        local pNpc = KNpc.GetById(tbNpcInfo.nNpcId)
        if pNpc and pNpc.nTeamIndex then
          tbInst:AddTeamScore(pNpc.nTeamIndex, tbNpcInfo.nNormalScore)
          tbNpcInfo.nNextScoreTime = nTimeNow + tbNpcInfo.nAddScoreTime
          if tbNpcInfo.szNormalMsg ~= "" then
            local function fnNotify(pPlayer)
              local tbPlayerInfo = tbInst.tbPlayerInfos[pPlayer.dwID]
              if tbPlayerInfo.nTeamIndex and tbPlayerInfo.nTeamIndex == pNpc.nTeamIndex then
                pPlayer.CenterMsg(tbNpcInfo.szNormalMsg)
              end
            end
            tbInst:ForEachInMap(fnNotify)
          end
        end
      end
    end
  end
end
function tbDotaCom.OnNpcDeath(tbInst, him, pKiller)
  local nPkMode, nDeadTeamIndex = him.GetPkMode()
  local nTeamIndex
  if nDeadTeamIndex == 1 then
    nTeamIndex = 2
  elseif nDeadTeamIndex == 2 then
    nTeamIndex = 1
  end
  if nTeamIndex and (not pKiller or not pKiller.GetPlayer()) then
    local nScore = tbDotaCom.GetNpcScore(tbInst, him)
    if nScore then
      tbInst:AddTeamScore(nTeamIndex, nScore)
    end
  end
  if him.nBattleCommIndex then
    local nOtherPKMode, nKillerTeamIndex
    if pKiller then
      nOtherPKMode, nKillerTeamIndex = pKiller.GetPkMode()
    end
    tbDotaCom.CreateCommNpc(tbInst, him.nBattleCommIndex, nKillerTeamIndex)
    if nKillerTeamIndex and nDeadTeamIndex == 3 and not pKiller.GetPlayer() then
      local nScore = tbDotaCom.GetNpcScore(tbInst, him)
      if nScore then
        tbInst:AddTeamScore(nKillerTeamIndex, nScore)
      end
    end
  end
  if him.nSettingIndex then
    local tbInfo = tbInst.tbWildNpcSetting[him.nSettingIndex]
    if tbInfo then
      local nRespawnTime = tbInfo.nRespawnTime
      if nRespawnTime ~= 0 then
        Timer:Register(Env.GAME_FPS * nRespawnTime, tbDotaCom.AddBattleNpc, tbInst, tbInfo)
      end
    end
  end
end
function tbDotaCom.GetNpcScore(tbInst, pNpc)
  if pNpc.nBattleCommIndex then
    local tbNpcInfo = tbInst.tbCommNpcInst[pNpc.nBattleCommIndex]
    return tbNpcInfo.nKillAddScore, tbNpcInfo.szDieMsg
  end
  local nTemplateId = pNpc.nTemplateId
  local nLevel = pNpc.nLevel
  local tbNpcScoreSetting = tbInst.tbNpcScoreSetting
  if tbNpcScoreSetting[nTemplateId] and tbNpcScoreSetting[nTemplateId][nLevel] then
    return unpack(tbNpcScoreSetting[nTemplateId][nLevel])
  end
  Log(debug.traceback())
  Log("Error!! dota kill npc  addscore", nTemplateId, nLevel)
end
function tbDotaCom.OnKillNpc(tbInst, pKiller)
  local tbWildNpcInfo = tbInst.tbWildNpc[him.nId]
  if tbWildNpcInfo then
    if tbWildNpcInfo.AwardType == "Buff" then
      local nSkillId, nSkillLevel, nDuraTime = unpack(tbWildNpcInfo.tbAwardParam)
      if pKiller.GetNpc then
        pKiller.GetNpc().AddSkillState(nSkillId, nSkillLevel, 0, Env.GAME_FPS * nDuraTime)
      else
        pKiller.AddSkillState(nSkillId, nSkillLevel, 0, Env.GAME_FPS * nDuraTime)
      end
    end
    tbInst.tbWildNpc[him.nId] = nil
  end
  local nScore, szDieMsg, szNotifyAll = tbDotaCom.GetNpcScore(tbInst, him)
  if nScore then
    tbInst:AddScore(pKiller, nScore)
  end
  if szDieMsg and szDieMsg ~= "" then
    pKiller.CenterMsg(szDieMsg)
  end
  if szNotifyAll and szNotifyAll ~= "" then
    tbInst:BattleFieldTips(string.format(szNotifyAll, pKiller.szName))
  end
end
