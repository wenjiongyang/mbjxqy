--白虎堂
Fuben.WhiteTigerFuben = Fuben.WhiteTigerFuben or {};
local WhiteTigerFuben = Fuben.WhiteTigerFuben;

local tbWhiteFunc = {
    ["TryEnterPrepareMap"]   = 1,
    ["TryEnterOutSideFuben"] = 1,
    ["OnTargetEnterFight"]   = 1,
    ["TryBackToPrepareMap"]  = 1,
}
--call by client
function WhiteTigerFuben:OnClientCall(szFunc, ...)
    if tbWhiteFunc[szFunc] then
        self[szFunc](self, ...)
    end
end

function WhiteTigerFuben:Init()
    self:LoadNpcExtInfo()
    self:SetupPreMapCallback()
end

function WhiteTigerFuben:LoadNpcExtInfo()
    local tbSetting = Lib:LoadTabFile("Setting/Fuben/WhiteTigerFuben/NpcInfo.tab", { BuffProbability = 1, TemplateId = 1, Level = 1, Treasure1 = 1, Treasure2 = 1, Treasure3 = 1, DropType = 1 })
    assert(tbSetting, "[WhiteTigerFuben LoadNpcExtInfo Error] File Not Found")

    self.tbNpcExtInfo = {}
    for _, tbSet in ipairs(tbSetting) do
        local tbInfo      = {}
        tbInfo.nProb      = tbSet.BuffProbability
        tbInfo.szTime     = tbSet.Time
        tbInfo.nLevel     = tbSet.Level
        tbInfo.szDropFile = tbSet.DropFile
        tbInfo.nDropType  = tbSet.DropType
        for nTreaIdx = 1, 3 do
            local szKey = "Treasure" .. nTreaIdx
            tbInfo["n" .. szKey] = tbSet[szKey]
        end

        self.tbNpcExtInfo[tbSet.TemplateId] = self.tbNpcExtInfo[tbSet.TemplateId] or {}
        table.insert(self.tbNpcExtInfo[tbSet.TemplateId], tbInfo)
    end
end

function WhiteTigerFuben:SetupPreMapCallback()
    local tbReadyMap = Map:GetClass(self.PREPARE_MAPID)
    tbReadyMap.OnCreate = function (tbMap, nMapId)
        self:OnReadyMapCreate()

        local fnGetFirePar = function ()
            local szP1, szP2, szP3 = unpack(Lib:SplitStr(self.PREPARE_FIRE, "|"))
            return tonumber(szP1), tonumber(szP2), tonumber(szP3)
        end
        local nFireNpcTemplateId, nX, nY = fnGetFirePar()
        self.pFireNpc = KNpc.Add(nFireNpcTemplateId, 1, 0, nMapId, nX, nY)
        Log(self.pFireNpc and "[WhiteTigerFuben SetupPreMapCallback] AddFireNpc Success" or "[WhiteTigerFuben SetupPreMapCallback] AddFireNpc Fail")
    end

    tbReadyMap.OnEnter = function (tbMap, nMapId)
        if not self.nStartTime then
            return
        end

        local nEndTime = self:GetPrepareRestTime() or 0
        me.CallClientScript("Ui:OpenWindow", "HomeScreenFuben", "WhiteTigerFuben", {nEndTime, true})
        me.CallClientScript("Fuben:SetFubenProgress", -1, "選擇一個入口進入")

        me.SetPkMode(Player.MODE_PEACE)
    end

    tbReadyMap.OnLeave = function (tbMap, nMapId)
        me.CallClientScript("Fuben.WhiteTigerFuben:OnLeavePrepareMap")
    end
end

function WhiteTigerFuben:OnReconnect(bReconnect)
    if not bReconnect then
        return
    end

    if me.nMapTemplateId ~= self.PREPARE_MAPID then
        return
    end

    local tbUiParam = {0, true}
    local szTitle = "請離開"
    if self.nStartTime then
        local nEndTime = self:GetPrepareRestTime() or 0
        if nEndTime > 0 then
            tbUiParam[1] = nEndTime
            szTitle = "選擇一個入口進入"
        end
    end

    me.CallClientScript("Ui:OpenWindow", "HomeScreenFuben", "WhiteTigerFuben", tbUiParam)
    me.CallClientScript("Fuben:SetFubenProgress", -1, szTitle)

    me.SetPkMode(Player.MODE_PEACE)
end

function WhiteTigerFuben:OnReadyMapCreate()
    self.nAutoJoinTimer = Timer:Register((self.PREPARE_TIME - self.AUTO_JOIN_TIME - 2) * Env.GAME_FPS, self.NotifyAutoJoin, self)
    self.nStartTimer = Timer:Register(self.PREPARE_TIME * Env.GAME_FPS, self.StartFight, self)
    self:NotifyPlayer()
end

function WhiteTigerFuben:NotifyAutoJoin()
    local tbMapPlayer = KPlayer.GetMapPlayer(self.nPrepareMapId)
    for _, pPlayer in ipairs(tbMapPlayer) do
        pPlayer.CallClientScript("Fuben.WhiteTigerFuben:BeginAutoEnter")
    end
end

function WhiteTigerFuben:NotifyPlayer()
    local szMsg = "各位少俠！白虎堂已經準時開啟！通過「活動」前去挑戰吧！"
    KPlayer.SendWorldNotify(self.OPEN_LEVEL, 1000, szMsg, ChatMgr.ChannelType.Public, 1)

    local tbMsgData = { szType = "WhiteTigerFuben", nTimeOut = GetTime() + 60*30 }
    local tbPlayer = KPlayer.GetAllPlayer()
    for _, pPlayer in pairs(tbPlayer) do
        if pPlayer.nLevel >= self.OPEN_LEVEL and DegreeCtrl:GetDegree(pPlayer, self.DEGREE_KEY) > 0 then
            pPlayer.CallClientScript("Ui:SynNotifyMsg", tbMsgData)
        end
    end
end

-- scheduleTask
function WhiteTigerFuben:Start()
    if self.nState ~= self.STATE_NONE then
        Log("[WhiteTigerFuben Start Error] Fuben's Underway")
        return
    end

    self.nState        = self.STATE_PREPARE
    self.tbOutSideMap  = {}
    for i = 1, self.SUB_ROOM_NUM do
        self.tbOutSideMap[i] = CreateMap(self.OUTSIDE_MAPID)
    end
    self.nPrepareMapId = CreateMap(self.PREPARE_MAPID)
    self.tbSubDegree   = {}
    self.tbComboInfo   = {}
    self.nStartTime    = GetTime()
    self.tbEnterTime   = {}
    self.tbKinJoinNum  = {}
    self.tbEnterNpcInfo= {}
    self.bFinalBossDeath = false
    self:CalcNpcInfo()
    self:CheckDayPretige()

    self.nCrossMapId = nil
    self.nCrossRoomIdx = nil
    Calendar:OnActivityBegin("WhiteTigerFuben")
    Log("WhiteTigerFuben Start", GetTime())
end

function WhiteTigerFuben:CheckOpenCross()
    return GetTimeFrameState("OpenDay89") == 1
end

function WhiteTigerFuben:CheckDayPretige()
    local tbData = ScriptData:GetValue("WTF_KinPrestige")
    local nToday = Lib:GetLocalDay()
    if not tbData.nDay or tbData.nDay ~= nToday then
        tbData.nDay = nToday
        tbData.tbKinPrestige = {}
        ScriptData:AddModifyFlag("WTF_KinPrestige")
        Log("[WhiteTigerFuben CheckDayPretige] Refresh Pretige", nToday)
    end
end

function WhiteTigerFuben:CalcNpcInfo()
    self.tbCurNpcExtInfo = {}
    for nTemId, tbExtInfo in pairs(self.tbNpcExtInfo) do
        local nIndex = 1
        for nIdx, tbInfo in ipairs(tbExtInfo) do
            if GetTimeFrameState(tbInfo.szTime) == 0 then
                break
            end

            nIndex = nIdx
        end
        self.tbCurNpcExtInfo[nTemId] = nIndex
    end
end

function WhiteTigerFuben:TryEnterPrepareMap(pPlayer, bMsg)
    if pPlayer.nMapId == self.nPrepareMapId then
        return false, "已在準備場裡"
    end

    local bRet, szMsg = self:CheckCanEnter(pPlayer)
    if not bRet then
        szMsg = szMsg or ""
        if bMsg then
            pPlayer.CenterMsg(szMsg)
        end
        return false, szMsg
    end

    pPlayer.SetEntryPoint()
    pPlayer.SwitchMap(self.nPrepareMapId, unpack(self.PREPARE_POS))
    return true
end

function WhiteTigerFuben:TryBackToPrepareMap(pPlayer)
    if self.nState == self.STATE_NONE or self.bFinalBossDeath then
        pPlayer.GotoEntryPoint()
        return
    elseif self.nState == self.STATE_FIGHTING then
        pPlayer.CenterMsg("戰鬥已開始，無法回到準備場")
        return
    end

    pPlayer.SwitchMap(self.nPrepareMapId, unpack(self.PREPARE_POS))
end

function WhiteTigerFuben:TryEnterOutSideFuben(pPlayer, nRoomId)
    if not pPlayer or not nRoomId then
        Log("[WhiteTigerFuben TryEnterOutSideFuben Player Nil Or RoomId Nil]", nRoomId)
        return
    end

    local bRet, szMsg = self:CheckCanEnter(pPlayer)
    if not bRet then
        pPlayer.CenterMsg(szMsg or "")
        return
    end

    local nMapId = self.tbOutSideMap[nRoomId]
    if not nMapId then
        Log("[WhiteTigerFuben TryEnterOutSideFuben] Error", nRoomId)
        return
    end

    pPlayer.SwitchMap(nMapId, unpack(self.tbSubRoomTrap))
    pPlayer.SetPkMode(Player.MODE_PEACE)

    self.tbEnterTime[pPlayer.dwID] = GetTime()
    Achievement:AddCount(pPlayer, "WhiteTiger_1")
    Log("[WhiteTigerFuben TryEnterFuben] Player Enter OutSideFuben", pPlayer.dwID, nMapId)
end

function WhiteTigerFuben:CheckCanEnter(pPlayer)
    if not pPlayer then
        return false, "未知錯誤，請重試"
    end

    if self.nState == self.STATE_NONE then
        return false, "活動尚未開始"
    end

    if self.nState ~= self.STATE_PREPARE then
        return false, "已過參加時間，無法參加"
    end

    if pPlayer.nLevel < self.OPEN_LEVEL then
        return false, "等級不足"
    end

    if DegreeCtrl:GetDegree(pPlayer, self.DEGREE_KEY) <= 0 then
        return false, "次數不足"
    end

    if not Env:CheckSystemSwitch(pPlayer, Env.SW_SwitchMap) then
        return false, "目前狀態不允許切換地圖"
    end

    if not Fuben.tbSafeMap[pPlayer.nMapTemplateId] and Map:GetClassDesc(pPlayer.nMapTemplateId) ~= "fight" and
        pPlayer.nMapTemplateId ~= self.PREPARE_MAPID and pPlayer.nMapTemplateId ~= self.OUTSIDE_MAPID then
        return false, "所在地圖不允許進入副本！";
    end

    if Map:GetClassDesc(pPlayer.nMapTemplateId) == "fight" and pPlayer.nFightMode ~= 0 then
        return false, "非安全區不允許進入副本！";
    end

    return true
end

--call by fuben
function WhiteTigerFuben:GotoMainFuben(pPlayer, nFromMapId)
    local nRoomId = 1
    for i = 1, self.SUB_ROOM_NUM do
        if self.tbOutSideMap[i] == nFromMapId then
            nRoomId = math.floor((i+1)/2)
        end
    end
    if not pPlayer or not nRoomId then
        Log("[WhiteTigerFuben GotoMainFuben] Error", nRoomId)
        return
    end

    Log("WhiteTigerFuben GotoMainFuben", pPlayer.dwID, nRoomId, self.nFightMapId)
    local tbPosition = self.tbMainRoomTrap[nRoomId] or self.tbMainRoomTrap[1]
    local tbMainInst = Fuben.tbFubenInstance[self.nFightMapId]
    if not tbMainInst then
        pPlayer.CenterMsg("活動已結束")
        pPlayer.GotoEntryPoint()
        Log(debug.traceback())
        return
    end

    tbMainInst:SetPlayerRoomId(pPlayer.dwID, nRoomId)
    pPlayer.SwitchMap(self.nFightMapId, unpack(tbPosition))

    local tbAward = {{"Contrib", self.tbFloorContribution[1]}}
    self:MergeAward(tbAward, pPlayer.nLevel, nil, 1)
    pPlayer.SendAward(tbAward, nil, true, Env.LogWay_WhiteTiger)
end

function WhiteTigerFuben:DoPlayerStartFight(pPlayer)
    self.tbSubDegree[pPlayer.dwID] = true
    local tbAward = {{"Contrib", self.JOIN_CONTRIBUTION}}
    self:MergeAward(tbAward, pPlayer.nLevel, true)
    pPlayer.SendAward(tbAward, nil, true, Env.LogWay_WhiteTiger)
    EverydayTarget:AddCount(pPlayer, "WhiteTigerFuben")
    TeacherStudent:CustomTargetAddCount(pPlayer, "WhiteTiger", 1)
    AssistClient:ReportQQScore(pPlayer, Env.QQReport_IsJoinWhiteTiger, 1, 0, 1)
    local dwKinId = pPlayer.dwKinId
    if dwKinId > 0 then
        self.tbKinJoinNum[dwKinId] = self.tbKinJoinNum[dwKinId] and self.tbKinJoinNum[dwKinId] + 1 or 1
    end
end

function WhiteTigerFuben:MergeAward(tbBaseAward, nLevel, bJoin, nFloor)
    local nRate = self:GetRandomAwardRate(nLevel, bJoin, nFloor)
    if nRate > 0 and nRate >= MathRandom(1000) then
        table.insert(tbBaseAward, self.tbFloorAward)
        return
    end
end

function WhiteTigerFuben:GetRandomAwardRate(nLevel, bJoin)
    local nRate = 0
    for _, tbInfo in ipairs(self.tbFloorAwardRate) do
        if nLevel >= tbInfo.nMinLevel and nLevel < tbInfo.nMaxLevel then
            nRate = bJoin and tbInfo.nJoinRate or tbInfo.nFloorRate
            break
        end
    end
    return nRate
end

function WhiteTigerFuben:StartFight()
    Log("[WhiteTigerFuben StartFight]", GetTime())
    if self.nState ~= self.STATE_PREPARE then
        return
    end

    --删除篝火
    if self.pFireNpc then
        self.pFireNpc.Delete()
        self.pFireNpc = nil
    end

    local fnStart = function (pPlayer)
        if DegreeCtrl:ReduceDegree(pPlayer, self.DEGREE_KEY, 1) then
            self:DoPlayerStartFight(pPlayer)
            pPlayer.CallClientScript("Ui:OpenWindow", "HomeScreenFuben", "WhiteTigerFuben", {self.PREPARE4PK, false})
        else
            pPlayer.GotoEntryPoint()
        end
    end
    self:TraverseAllFubenPlayer(fnStart)

    self.nFightMapId     = CreateMap(self.FIGHT_MAPID)
    self.nState          = self.STATE_FIGHTING
    self.nStartTimer     = nil
    self.nAutoJoinTimer  = nil
    self.nStartFightTime = GetTime()

    for _, nMapId in ipairs(self.tbOutSideMap) do
        local tbFubenInst = Fuben.tbFubenInstance[nMapId]
        if tbFubenInst and tbFubenInst.OnStartFight then
            tbFubenInst:OnStartFight()
        end
    end

    if self:CheckOpenCross() then
        CallZoneServerScript("Fuben.WhiteTigerFuben:OnWSBeginFight")
    end
end

function WhiteTigerFuben:TraverseAllFubenPlayer( fnCall, ... )
    local tbMapList = {unpack(self.tbOutSideMap)}
    table.insert(tbMapList, self.nFightMapId)
    for _, nMapId in ipairs(tbMapList) do
        local tbPlayer = KPlayer.GetMapPlayer(nMapId)
        for _, pPlayer in ipairs(tbPlayer or {}) do
            fnCall(pPlayer, ... )
        end
    end
end

function WhiteTigerFuben:OnTopBossDeath()
    if self.nState == self.STATE_NONE then
        return
    end

    self.bFinalBossDeath = true
    local fnShowLeave =  function (pPlayer)
        pPlayer.CallClientScript("Fuben.WhiteTigerFuben:OnClose")
    end
    self:TraverseAllFubenPlayer(fnShowLeave)

    for _, nMapId in pairs(self.tbOutSideMap) do
        local tbFubenInst = Fuben.tbFubenInstance[nMapId]
        if tbFubenInst then
            tbFubenInst:GameWin()
        end
    end

    self:AddPrestigeByJoinNum()
    Calendar:OnActivityEnd("WhiteTigerFuben")
end

function WhiteTigerFuben:AddPrestigeByJoinNum()
    for dwKinId, nNum in pairs(self.tbKinJoinNum) do
        self:AddPrestige(dwKinId, nNum)
    end
    Log("[WhiteTigerFuben AddPrestigeByJoinNum] Success")
end

--scheduleTask
function WhiteTigerFuben:CloseFuben()
    if self.nState == self.STATE_NONE then
        Log("[WhiteTigerFuben CloseFuben] Fuben Is Not Opening")
        return
    end

    self.nState = self.STATE_NONE
    self:CloseAllFubenInstance()

    self.nFightMapId     = nil
    self.nPrepareMapId   = nil
    self.tbOutSideMap    = nil
    self.nStartFightTime = nil
    self.nStartTime      = nil
    self.tbSubDegree     = {}
    self.tbComboInfo     = {}
    self.tbEnterNpcInfo  = {}
    self.bFinalBossDeath = false

    if self.nStartTimer then
        Timer:Close(self.nStartTimer)
        Timer:Close(self.nAutoJoinTimer)
        self.nStartTimer = nil
        self.nAutoJoinTimer = nil
    end

    Calendar:OnActivityEnd("WhiteTigerFuben")
    Log("[WhiteTigerFuben CloseFuben]", GetTime())
end

function WhiteTigerFuben:CloseAllFubenInstance()
    local tbMapList = {unpack(self.tbOutSideMap)}
    table.insert(tbMapList, self.nFightMapId)
    for _, nMapId in ipairs(tbMapList) do
        local tbFubenInst = Fuben.tbFubenInstance[nMapId]
        if tbFubenInst then
            tbFubenInst:OnTimeOut()
        end
    end

    local tbPlayer = KPlayer.GetMapPlayer(self.nPrepareMapId)
    for _, pPlayer in ipairs(tbPlayer or {}) do
        pPlayer.SetPkMode(Player.MODE_PEACE)
        pPlayer.GotoEntryPoint()
    end
end

function WhiteTigerFuben:OnCrossMapCreated(nMapId, nRoomIdx)
    self.nCrossMapId = nMapId
    self.nCrossRoomIdx = nRoomIdx
    Log("WhiteTigerFuben OnCrossMapCreated", nMapId, nRoomIdx)
end

function WhiteTigerFuben:GetKillNpcKin(pNpc)
    if not pNpc then
        Log("WhiteTigerFuben Not Found Npc")
        return
    end

    local tbSortDamage = pNpc.GetDamageInfo()
    if not tbSortDamage or #tbSortDamage <= 0 then
        Log("WhiteTigerFuben Not Damage")
        return
    end
    local tbKinSort = {}
    for _, tbDmgInfo in ipairs(tbSortDamage) do
        local nCaptainId = -1
        local tbTeam = nil
        if tbDmgInfo.nTeamId > 0 then
            tbTeam = TeamMgr:GetTeamById(tbDmgInfo.nTeamId)
        end
        if tbTeam then
            nCaptainId = tbTeam:GetCaptainId()
        elseif tbDmgInfo.nAttackRoleId > 0 then
            nCaptainId = tbDmgInfo.nAttackRoleId
        end

        if nCaptainId > 0 then
            local nKinId = self:GetPlayerKinID(nCaptainId)
            if nKinId > 0 then
                tbKinSort[nKinId] = tbKinSort[nKinId] or 0
                tbKinSort[nKinId] = tbKinSort[nKinId] + tbDmgInfo.nTotalDamage
            end
        end
    end

    local tbTmp = {}
    local tbRank = {}
    for nKinId, nDamage in pairs(tbKinSort) do
        table.insert(tbTmp, {nKinId, nDamage})
    end
    table.sort(tbTmp, function (a, b)
        return a[2] > b[2]
    end)
    for _, tbInfo in ipairs(tbTmp) do
        table.insert(tbRank, tbInfo[1])
    end
    return tbRank, tbKinSort
end

function WhiteTigerFuben:GetPlayerKinID(nPlayerID)
    local pPlayer = KPlayer.GetPlayerObjById(nPlayerID)
    local nKinId = 0
    if pPlayer then
        nKinId = pPlayer.dwKinId
    else
        local tbStayInfo = KPlayer.GetRoleStayInfo(nPlayerID);
        if tbStayInfo then
            nKinId = tbStayInfo.dwKinId
        end
    end

    return nKinId
end

function WhiteTigerFuben:GetCrossAward(nValue)
    local tbCrossAward = GetTimeFrameState("OpenLevel109") == 1 and self.tbCross_Award_TF or self.tbCross_Award
    local tbAward = {}
    for nItemTID, tbInfo in pairs(tbCrossAward) do
        local nCreateNum, nRandomNum = math.modf((nValue/tbInfo[2]) * tbInfo[1])
        if (nRandomNum*1000000) > MathRandom(1000000) then
            nCreateNum = nCreateNum + 1
        end
        if nCreateNum > 0 then
            table.insert(tbAward, {nItemTID, nCreateNum})
        end
    end
    return tbAward
end

function WhiteTigerFuben:BeginSendCrossAward(nKinId, tbJoinPlayer, nValue)
    local tbAward = self:GetCrossAward(nValue)
    if #tbAward == 0 then
        Log("WhiteTigerFuben BeginSendCrossAward No Award", nKinId, nValue)
        return
    end
    Kin:AddAuction(nKinId, "WhiteTigerFuben_Cross", tbJoinPlayer, tbAward)
    Log("WhiteTigerFuben BeginSendCrossAward", nKinId)
    Lib:LogTB(tbJoinPlayer)
    Lib:LogTB(tbAward)
end

function WhiteTigerFuben:OnKillCrossBoss(nKillKinId, tbHostileKin)
    local tbKinData = Kin:GetKinById(nKillKinId)
    local szBossName = KNpc.GetNameByTemplateId(self.CROSS_BOSS_TID)
    local szDefeatMsg = string.format("本服%s幫派英勇擊敗了", tbKinData.szName)
    for i, tbInfo in ipairs(tbHostileKin) do
        szDefeatMsg = string.format("%s%d服的%s幫派%s", szDefeatMsg, tbInfo[1], tbInfo[2], i == #tbHostileKin and "" or "和")
    end
    KPlayer.SendWorldNotify(1, 999, szDefeatMsg, 1, 1)

    local szMsg = string.format("恭喜%s幫派成功擊殺了跨服白虎堂5層中的%s", tbKinData.szName, szBossName)
    KPlayer.SendWorldNotify(1, 999, szMsg, 1, 1)
end

function WhiteTigerFuben:OnBeDefeatInCross(tbKinInfo, nKinId)
    if not tbKinInfo or not nKinId then
        return
    end
    local szMsg = string.format("本幫派在跨服白虎堂中被來自%d服的%s幫派擊敗", tbKinInfo[1], tbKinInfo[2])
    ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.Kin, szMsg, nKinId)
end

function WhiteTigerFuben:OnLeaveCross(nPlayerID, nKillNum)
    local pPlayer = KPlayer.GetPlayerObjById(nPlayerID)
    if not pPlayer then
        return
    end

    if nKillNum and nKillNum > 0 then
        RecordStone:AddRecordCount(pPlayer, "WhiteTiger", nKillNum)
    end
    Log("WhiteTigerFuben OnKillPlayerOnCross", nPlayerID, nKillNum or 0)
    pPlayer.CallClientScript("Ui:CloseWindow", "HomeScreenFuben")
end

function WhiteTigerFuben:OnCrossTopBossKill(dwKillID)
    local pPlayer = KPlayer.GetPlayerObjById(dwKillID)
    if not pPlayer then
        return
    end

    self:SendRedbag(self.CROSS_TOP_FLOOR, pPlayer)
end

function WhiteTigerFuben:SendRedbag(nFloor, pPlayer)
    Kin:RedBagOnEvent(pPlayer, Kin.tbRedBagEvents.white_tiger_boss, nFloor)
    Log("WhiteTigerFuben SendRedbagEvent", nFloor, pPlayer.dwID)
end

WhiteTigerFuben:Init()

function WhiteTigerFuben:OnTargetEnterFight(pPlayer, nMapId)
    local tbInfo = self.tbEnterNpcInfo[nMapId]
    if not tbInfo then
        local tbNpc = KNpc.GetMapNpc(self.nPrepareMapId)
        for _, pNpc in ipairs(tbNpc) do
            if pNpc.szClass == "WhiteTiger" then
                local nRoomId = tonumber(pNpc.szScriptParam)
                local nFMapId = self.tbOutSideMap[nRoomId]
                local _, nX, nY = pNpc.GetWorldPos()
                self.tbEnterNpcInfo[nFMapId] = {nRoomId, nX, nY}
            end
        end
    end

    tbInfo = self.tbEnterNpcInfo[nMapId]
    pPlayer.CallClientScript("Fuben.WhiteTigerFuben:GotoTargetPos", nMapId, tbInfo)
end

-- ===================================================白虎堂IDIP用到=================================================================
function WhiteTigerFuben:PlayerDmgInfo(dwID)

    local nMyRank = 0
    local nMyDmg = 0

    local nKinRank = 0
    local nKinDmg = 0

    local pPlayer = KPlayer.GetPlayerObjById(dwID);
    if not pPlayer then
        return nMyDmg,nMyRank,nKinDmg,nKinRank;
    end

    local tbInstance = Fuben:GetFubenInstance(pPlayer)
    if not tbInstance or not tbInstance.GetWtfBossId then
        return nMyDmg,nMyRank,nKinDmg,nKinRank;
    end

    local nNpcId = tbInstance:GetWtfBossId(dwID)
    if not nNpcId then
        return nMyDmg,nMyRank,nKinDmg,nKinRank;
    end

    -- 和野外首领那边一样的计算方法
    local nMyDmg,nMyRank = BossLeader:GetPlayerDmgInfo(nNpcId,dwID);
    local nKinDmg,nKinRank = BossLeader:GetPlayerKinDmgInfo(nNpcId,dwID);

    return nMyDmg,nMyRank,nKinDmg,nKinRank;
end
