if not MODULE_ZONESERVER then
    return
end

Fuben.WhiteTigerFuben = Fuben.WhiteTigerFuben or {};
local WhiteTigerFuben = Fuben.WhiteTigerFuben;

function WhiteTigerFuben:OnWSBeginFight()
    self.tbWS = self.tbWS or {}
    self.tbWS[Server.nCurConnectIdx] = true
    Log("WhiteTigerFuben OnWSBeginFight:", Server.nCurConnectIdx)
end

function WhiteTigerFuben:SyncKillBossKinId(nKinId, szKinName, nServerIdx)
    self.tbKin2WS[nKinId] = Server.nCurConnectIdx
    self.tbKinInfo[nKinId] = {nServerIdx, szKinName}
    Log("WhiteTigerFuben SyncKillBossKinId", nKinId, Server.nCurConnectIdx, nServerIdx)
end

--scheduletask
function WhiteTigerFuben:BeginCrossFight()
    self.nLastWS = 0
    for nWsIdx, _ in pairs(self.tbWS or {}) do
        self.nLastWS = self.nLastWS + 1
    end
    if self.nLastWS <= 0 then
        Log("WhiteTigerFuben BeginCrossFight Fail Not WsBegin")
        return
    end

    self.tbWSMap = {}
    self:CreateFightMap(self.nLastWS)
    self:BoardcastMapId()
    self.tbWS = {}
    self.tbKin2WS = {}
    self.tbKinInfo = {}
    Log("WhiteTigerFuben BeginCrossFight", self.nLastWS)
end

function WhiteTigerFuben:CreateFightMap(nWSCount)    
    local nCreateNum = math.floor(nWSCount/self.FIT_KIN_IN_MAP)
    --这些情况下地图数量不足
    if nWSCount == 1 or nWSCount == 2 or nWSCount == 5 then
        nCreateNum = nCreateNum + 1
    end
    local tbMapInfo = {}
    for i = 1, nCreateNum do
        local nMapId = CreateMap(self.CROSS_MAP_TID)
        table.insert(tbMapInfo, {nMapId = nMapId, nWSNum = 0})
    end

    for nWsIdx, _ in pairs(self.tbWS or {}) do
        local nMapId, nRoomIdx = self:DistributionMap(tbMapInfo, nWSCount)
        if nMapId then
            self.tbWSMap[nWsIdx] = {nMapId = nMapId, nRoomIdx = nRoomIdx}
            Log("WhiteTigerFuben CreateFightMap", nWsIdx, nWSCount, nMapId, nRoomIdx)
            nWSCount = nWSCount - 1
        end
    end
end

function WhiteTigerFuben:DistributionMap(tbMapInfo, nLastWS)
    --先按照每个地图三个服务器分配，当分配不下来时按照每个地图四个服务器分配
    for nMax = self.FIT_KIN_IN_MAP, self.FIT_KIN_IN_MAP + 1 do
        for _, tbInfo in ipairs(tbMapInfo) do
            if tbInfo.nWSNum < nMax then
                tbInfo.nWSNum = tbInfo.nWSNum + 1
                return tbInfo.nMapId, tbInfo.nWSNum
            end
        end
    end
    Log("WhiteTigerFuben DistributionMap Err", nLastWS)
end

function WhiteTigerFuben:BoardcastMapId()
    for nWsIdx, tbInfo in pairs(self.tbWSMap) do
        CallZoneClientScript(nWsIdx, "Fuben.WhiteTigerFuben:OnCrossMapCreated", tbInfo.nMapId, tbInfo.nRoomIdx)
        Log("WhiteTigerFuben BoardcastMapId", nWsIdx, tbInfo.nMapId, tbInfo.nRoomIdx)
    end
end

function WhiteTigerFuben:GetKinIdByMap(nMapId, nRoomIdx)
    for nKinId, nWs in pairs(self.tbKin2WS) do
        local tbInfo = self.tbWSMap[nWs] or {}
        if tbInfo.nMapId == nMapId and tbInfo.nRoomIdx == nRoomIdx then
            return nKinId
        end
    end
end

function WhiteTigerFuben:GetWsByKinId(pPlayer)
    local nKinId = pPlayer.dwKinId
    return self.tbKin2WS[nKinId]
end

function WhiteTigerFuben:SendCrossAward(nMapId, tbKinValue, tbKinJoinPlayer, nKillKinId)
    for nKinId, nValue in pairs(tbKinValue) do
        local nWs = self.tbKin2WS[nKinId]
        if nWs then
            local tbJoin = tbKinJoinPlayer[nKinId] or {}
            CallZoneClientScript(nWs, "Fuben.WhiteTigerFuben:BeginSendCrossAward", nKinId, tbJoin, nValue)
        end
    end

    self:SendFightResult(nMapId, nKillKinId)
    Log("WhiteTigerFuben SendCrossAward", nKillKinId or "-")
end

function WhiteTigerFuben:SendFightResult(nMapId, nKillKinId)
    if not nKillKinId then
        Log("WhiteTigerFuben SendFightResult Err Not KillInfo")
        return
    end

    local tbHostileKin = {}
    for i = 1, 4 do
        local nKinId = self:GetKinIdByMap(nMapId, i)
        if nKinId then
            if nKillKinId ~= nKinId then
                table.insert(tbHostileKin, self.tbKinInfo[nKinId])
                local nWs = self.tbKin2WS[nKinId]
                if nWs then
                    CallZoneClientScript(nWs, "Fuben.WhiteTigerFuben:OnBeDefeatInCross", self.tbKinInfo[nKillKinId], nKinId)
                end
            end
        end
    end

    local nWs = self.tbKin2WS[nKillKinId]
    if nWs then
        CallZoneClientScript(nWs, "Fuben.WhiteTigerFuben:OnKillCrossBoss", nKillKinId, tbHostileKin)
    end
end

--scheduletask
function WhiteTigerFuben:StopCrossFight()
    local fnLeaveMap = function (pPlayer)
        local nWs = self:GetWsByKinId(pPlayer)
        if nWs then
            CallZoneClientScript(nWs, "Fuben.WhiteTigerFuben:OnLeaveCross", pPlayer.dwID)
        end    
        pPlayer.ZoneLogout()
    end
    for nWsIdx, tbInfo in pairs(self.tbWSMap or {}) do
        local tbInst = Fuben.tbFubenInstance[tbInfo.nMapId]
        if tbInst then
            tbInst:Close()
            tbInst:AllPlayerInMapExcute(fnLeaveMap)
        end
    end
    self.tbWSMap = {}
    Log("WhiteTigerFuben StopCrossFight")
end