--白虎堂
Require("ServerScript/Fuben/WhiteTigerFuben.lua")
local tbFubenMgr = Fuben.WhiteTigerFuben
function tbFubenMgr:IsFightMap(nMapId)
    return self.nFightMapId and nMapId and self.nFightMapId == nMapId
end

function tbFubenMgr:IsFighting()
    return self.nState == self.STATE_FIGHTING
end

function tbFubenMgr:GetBossCreateTime(nFloor)
    if nFloor == 1 then
        return self.BOSS_START[nFloor] - (GetTime() - self.nStartTime)
    end

    if not self.nStartFightTime then
        return 0
    end

    local nSubTime = self.BOSS_START[nFloor] - (GetTime() - self.nStartFightTime)
    return nSubTime
end

--不能进入：次数不足，副本已结束
function tbFubenMgr:CheckCanJoin(pPlayer)
    if not self:IsFighting() then
        return true
    end

    if not self.tbSubDegree[pPlayer.dwID] then
        if not DegreeCtrl:ReduceDegree(pPlayer, self.DEGREE_KEY, 1) then
            return false
        end
        self:DoPlayerStartFight(pPlayer)
    end

    return true
end

function tbFubenMgr:GetPrepareRestTime()
    if self.nState ~= self.STATE_PREPARE then
        return
    end

    local nRestTime = (self.nStartTime + self.PREPARE_TIME) - GetTime()
    nRestTime = nRestTime > 0 and nRestTime or 0
    return nRestTime
end

function tbFubenMgr:IsFinalBossDeath()
    return self.bFinalBossDeath
end

function tbFubenMgr:GetNpcInfo(nTemplateId)
    local nIdx      = self.tbCurNpcExtInfo[nTemplateId]
    local tbExtInfo = self.tbNpcExtInfo[nTemplateId]
    if not tbExtInfo then
        return
    end

    return tbExtInfo[nIdx]
end

function tbFubenMgr:GetPlayerMatchTime(dwID)
    local nEnter = self.tbEnterTime[dwID]
    if not nEnter then
        return 0
    end

    return GetTime() - nEnter
end

function tbFubenMgr:GetPrestigeAward(nNpcTemplateId) --boss威望
    return self.tbBossKinPrestige[nNpcTemplateId]
end

function tbFubenMgr:IsTopBossDeath()
    return self.bFinalBossDeath
end

function tbFubenMgr:AddPrestige(nKinId, nPrestige)
    if not nKinId or not nPrestige then
        return
    end

    self:CheckDayPretige()

    local tbData = ScriptData:GetValue("WTF_KinPrestige")
    local nCurPrestige = tbData.tbKinPrestige[nKinId] or 0
    local nAddPrestige = nPrestige
    if nCurPrestige + nPrestige > self.MAX_PRESTIGE then
        nAddPrestige = self.MAX_PRESTIGE - nCurPrestige
    end

    local kinData = Kin:GetKinById(nKinId)
    if nCurPrestige >= self.MAX_PRESTIGE or nAddPrestige <= 0 or not kinData then
        Log("[WhiteTigerFuben AddPrestige Max]", nCurPrestige, nAddPrestige, nPrestige, nKinId)
        return
    end

    tbData.tbKinPrestige[nKinId] = nCurPrestige + nAddPrestige
    ScriptData:AddModifyFlag("WTF_KinPrestige")
    kinData:AddPrestige(nAddPrestige, Env.LogWay_WhiteTiger)
    Log("[WhiteTigerFubenBase AddPrestige]", nKinId, nAddPrestige, nCurPrestige)
end

--------------------------------------------白虎堂副本--------------------------------------------
local tbFuben        = Fuben:CreateFubenClass("WhiteTigerFubenBase")
tbFuben.tbNextRoomID = { [1] = 5, [2] = 5, [3] = 6, [4] = 6, [5] = 7, [6] = 7 } --房间ID对应下一个房间的ID
tbFuben.tbRoomNum    = {0, 4, 2, 1} --每层房间数量
tbFuben.nTopRoom     = 7

function tbFuben:OnCreate()
    self:Start()

    self.bFightMap = tbFubenMgr:IsFightMap(self.nMapId)
    if self.bFightMap then
        self:InitFightRoom()

        self.bFighting = false --副本起始为和平模式，过了一段时间后才开pk
        self.nStartPkTimer = Timer:Register(Env.GAME_FPS*tbFubenMgr.PEACE_TIME, self.ChangePkMode, self)
    end
    self:InitReviveInfo()

    self.tbBossNpcId = { tbMainFloor = {} }
    self.nPkMode = Player.MODE_PEACE
end

--Call By Mgr 首层开始时回调
function tbFuben:OnStartFight()
    local tbPlayer = KPlayer.GetMapPlayer(self.nMapId)
    for _, pPlayer in ipairs(tbPlayer or {}) do
        self:AddImitity(pPlayer, Env.LogWay_WhiteTigerFuben_FF)
    end

    --在开始刷怪后某段时间开始开启PK模式
    Timer:Register(Env.GAME_FPS * tbFubenMgr.PREPARE4PK, function ()
        local tbPlayer = KPlayer.GetMapPlayer(self.nMapId)
        for _, pPlayer in ipairs(tbPlayer or {}) do
            self:SetPkMode(pPlayer, Player.MODE_PK)
            pPlayer.CallClientScript("Ui:OpenWindow", "HomeScreenFuben", "WhiteTigerFuben", {tbFubenMgr.BOSS_START[1]-tbFubenMgr.PREPARE_TIME-tbFubenMgr.PREPARE4PK, false})
        end

        self:SetFubenProgress(-1, "等待一層頭目現身")
        self.nPkMode = Player.MODE_PK
    end)
end

function tbFuben:InitFightRoom()
    self.tbPlayerRoomId = {}

    self.tbRoomState    = {}
    local tbFloorName   = {[2] = "二", [3] = "三", [4] = "四"}
    for i = 1, self.nTopRoom do
        local nFloor  = self:GetFloor(i)
        local szTitle = (nFloor <= 2) and "等待開啟PK模式" or string.format("等待%s層頭目出現", tbFloorName[nFloor])
        self.tbRoomState[i] = {["szTitle"] = szTitle, ["nX"] = 0, ["nY"] = 0}
    end
    self.bFinalBossDeath = false

    self:InitTrap()
end

function tbFuben:InitReviveInfo()
    self.tbReviveInfo = {}
    for _, tbInfo in pairs(self.tbSetting.NPC) do
        local nReviveFrame = tbInfo.nReviveFrame
        if nReviveFrame and nReviveFrame > 0 then
            self.tbReviveInfo[tbInfo.nTemplate] = nReviveFrame
        end
    end
end

function tbFuben:InitTrap()
    self:ChangeTrap("Lv2to3", nil, nil, nil, nil, "Trap3Floor")
    self:ChangeTrap("Lv3to4", nil, nil, nil, nil, "Trap4Floor")
end

function tbFuben:OnTrap3Floor()
    self:OnChangeRoom(3)
end

function tbFuben:OnTrap4Floor()
    self:OnChangeRoom(4)
end

function tbFuben:OnChangeRoom(nFloor)
    if self.bClose == 1 then
        return
    end

    local bRet = self:ChangeFloor(nFloor)
    if not bRet then
        return
    end

    local nRestTime = tbFubenMgr:GetBossCreateTime(nFloor)
    if nRestTime > 0 then
        me.CallClientScript("Ui:OpenWindow", "HomeScreenFuben", "WhiteTigerFuben", {nRestTime, false})
    end

    local nRoomId     = self.tbPlayerRoomId[me.dwID]
    local tbRoomState = self:GetRoomState(nRoomId)
    me.CallClientScript("Fuben.WhiteTigerFuben:SetFubenInfo", -1, tbRoomState.szTitle, tbRoomState.nX or 0, tbRoomState.nY or 0)

    if nRoomId == self.nTopRoom and self.bFinalBossDeath then
        Achievement:AddCount(me, "WhiteTiger_3")
    end
    local tbAward = {{"Contrib", tbFubenMgr.tbFloorContribution[nFloor - 1]}}
    tbFubenMgr:MergeAward(tbAward, me.nLevel, nil, nFloor - 1)
    me.SendAward(tbAward, nil, true, Env.LogWay_WhiteTigerFuben_OF)
    self:AddImitity(me, Env.LogWay_WhiteTigerFuben_OF)
end

--call by fuben mgr
function tbFuben:SetPlayerRoomId(dwID, nRoomId)
    self.tbPlayerRoomId[dwID] = nRoomId
end

function tbFuben:ChangeFloor(nFloor)
    local dwId       = me.dwID
    local nOldRoomId = self.tbPlayerRoomId[dwId]
    local nOldFloor  = self:GetFloor(nOldRoomId)
    if nOldFloor >= nFloor then
        return
    end

    self.tbPlayerRoomId[dwId] = self.tbNextRoomID[nOldRoomId]
    return true
end

function tbFuben:GetRoomId(nFloor, nRoomIdx)
    local nRoomId = nRoomIdx
    for nF = 2, nFloor - 1 do
        nRoomId = self.tbRoomNum[nF] + nRoomId
    end
    return nRoomId
end

function tbFuben:GetFloor(nRoomId)
    local nRoom = 0
    for nF = 2, #self.tbRoomNum do
        nRoom = nRoom + self.tbRoomNum[nF]
        if nRoomId <= nRoom then
            return nF
        end
    end

    return 0
end

function tbFuben:ChangePkMode()
    self.nStartPkTimer = nil
    self.bFighting = true

    local szTitle = "等待二層頭目出現"
    for i = 1, 4 do
        self.tbRoomState[i].szTitle = szTitle
    end

    local nRestTime = math.max(tbFubenMgr:GetBossCreateTime(2), 0)
    local tbUiParam = {nRestTime, false}
    local fnChangePkMode = function (pPlayer)
        self:SetPkMode(pPlayer, Player.MODE_PK, true)
        pPlayer.CallClientScript("Ui:OpenWindow", "HomeScreenFuben", "WhiteTigerFuben", tbUiParam)
        pPlayer.CallClientScript("Fuben.WhiteTigerFuben:SetFubenInfo", -1, szTitle, 0, 0)
    end
    self:AllPlayerExcute(fnChangePkMode)
    self.nPkMode = Player.MODE_PK
    Log("[WhiteTigerFuben ChangePkMode] Success")
end

function tbFuben:OnLogin()
    self:OnJoin(me)
end

function tbFuben:OnJoin(pPlayer)
    if not tbFubenMgr:CheckCanJoin(pPlayer) then
        pPlayer.GotoEntryPoint()
        Log("[WhiteTigerFubenBase OnJoin] Player Try Join Closed Fuben Or Not Enough Degree Times", pPlayer.dwID, self.nMapId)
        return
    end

    if not tbFubenMgr:IsFighting() then
        pPlayer.CallClientScript("Ui:OpenWindow", "HomeScreenFuben", "WhiteTigerFuben", {tbFubenMgr:GetPrepareRestTime() or 0, true})
        if self.tbCacheProgressInfo then
            pPlayer.CallClientScript("Fuben:SetFubenProgress", unpack(self.tbCacheProgressInfo))
        end
    else
        --掉线处理
        local bShowExit    = tbFubenMgr:IsFinalBossDeath()
        local fnOpenWindow = function (nFloor)
            local tbUiParam = {0, bShowExit}
            if self.bFightMap then
                if self.bFighting then
                    tbUiParam[1] = math.max(tbFubenMgr:GetBossCreateTime(nFloor), 0)
                else
                    tbUiParam[1] = Timer:GetRestTime(self.nStartPkTimer) / Env.GAME_FPS
                end
            else
                local nBeginTime = GetTime() - tbFubenMgr.nStartTime
                if nBeginTime < (tbFubenMgr.PREPARE4PK + tbFubenMgr.PREPARE_TIME) then
                    tbUiParam[1] = tbFubenMgr.PREPARE4PK + tbFubenMgr.PREPARE_TIME - nBeginTime
                elseif nBeginTime < tbFubenMgr.BOSS_START[1] then
                    tbUiParam[1] = tbFubenMgr.BOSS_START[1] - nBeginTime
                end
            end
            pPlayer.CallClientScript("Ui:OpenWindow", "HomeScreenFuben", "WhiteTigerFuben", tbUiParam)
        end

        if self.bFightMap then
            local nRoomId = self.tbPlayerRoomId[pPlayer.dwID]
            local nFloor  = self:GetFloor(nRoomId)
            fnOpenWindow(nFloor)

            local tbRoomState = self:GetRoomState(nRoomId)
            pPlayer.CallClientScript("Fuben.WhiteTigerFuben:SetFubenInfo", -1, tbRoomState.szTitle, tbRoomState.nX or 0, tbRoomState.nY or 0)
        else
            fnOpenWindow(1)
            if self.tbCacheProgressInfo then
                pPlayer.CallClientScript("Fuben:SetFubenProgress", unpack(self.tbCacheProgressInfo))
            end
        end
    end

    self:SetPkMode(pPlayer, self.nPkMode, true)
end

function tbFuben:SetPkMode(pPlayer, nMode, bForbidChange)
    pPlayer.bForbidChangePk = 0
    pPlayer.SetPkMode(nMode)
    if bForbidChange then
        pPlayer.bForbidChangePk = 1
    end
end

function tbFuben:OnPlayerDeath(pKiller)
    me.Revive(0)
    self:SetPkMode(me, 0)
    me.GotoEntryPoint()

    if not pKiller then
        return
    end
    local pPlayer = pKiller.GetPlayer()
    if pPlayer then
        Achievement:AddCount(pPlayer, "WhiteTiger_2")
        FriendShip:AddHate(me, pPlayer, 20000)
        RecordStone:AddRecordCount(pPlayer, "WhiteTiger", 1)

        local dwID = pPlayer.dwID
        tbFubenMgr.tbComboInfo[dwID] = tbFubenMgr.tbComboInfo[dwID] and tbFubenMgr.tbComboInfo[dwID] + 1 or 1
        pPlayer.CallClientScript("Ui:ShowComboKillCount", tbFubenMgr.tbComboInfo[dwID])

        if pPlayer.dwKinId > 0 then
            local nCombo = tbFubenMgr.tbComboInfo[dwID]
            if nCombo >= 20 and nCombo <= 100 and nCombo%10 == 0 then
                local szMsg = string.format("「%s」在白虎堂中，連斬%d人！", pPlayer.szName, nCombo)
                ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.Kin, szMsg, pPlayer.dwKinId)
            end
        end
    end
end

function tbFuben:OnLeave()
    self:LeaveFuben(me)
    self:OnLeaveMap(me)
    self:SetPkMode(me, Player.MODE_PEACE)

    if tbFubenMgr:IsFighting() then
        local nMatchTime = tbFubenMgr:GetPlayerMatchTime(me.dwID)
        me.TLogRoundFlow(Env.LogWay_WhiteTiger, self.nMapId, 0, nMatchTime, self.bFinalBossDeath and Env.LogRound_SUCCESS or Env.LogRound_FAIL, 0, 0)
    end
    me.CallClientScript("Ui:CloseWindow", "HomeScreenFuben")
end

function tbFuben:OnKillNpc(pNpc, pKiller)
    self:DropAward()
    self:DropBuff(pNpc, pKiller)
    self:ReviveNpc(pNpc)
end

function tbFuben:DropAward()
    local szDropFile, nDropType, tbTreasure = self:GetNpcAward(him.nTemplateId)
    local tbPrestigeAward = tbFubenMgr:GetPrestigeAward(him.nTemplateId)
    if not szDropFile and not tbPrestigeAward then
        return
    end

    local tbDamageInfo = him.GetDamageInfo() or {}
    if not next(tbDamageInfo) then
        return;
    end
    table.sort(tbDamageInfo, function (a, b)
        return a.nTotalDamage > b.nTotalDamage
    end);

    local tbDamageKin = {}
    local nDamageIdx  = 1
    for _, tbDamage in ipairs(tbDamageInfo) do
        local tbPlayer, pFirstPlayer = Npc:GetAssignPlayer(him, tbDamage);
        if tbPlayer and next(tbPlayer) then
            if not Lib:IsEmptyStr(szDropFile) then
                local nTreasure = tbTreasure[nDamageIdx]
                if nTreasure and nTreasure > 0 then
                    if nDropType == Npc.LOST_TYPE_EVERY_PLAYER then
                        Npc:AssignEveryPlayer(him, tbPlayer, nTreasure, szDropFile);
                    else
                        Npc:AssignNormal(him, tbPlayer, nTreasure, szDropFile);
                    end
                end
            end
            if pFirstPlayer and pFirstPlayer.dwKinId ~= 0 then
                tbDamageKin[nDamageIdx] = pFirstPlayer.dwKinId
            end

            nDamageIdx = nDamageIdx + 1
            if nDamageIdx > 3 then
                break
            end
        end
    end
    if tbPrestigeAward then
        self:AddPrestige(tbDamageKin, tbPrestigeAward)
    end
end

function tbFuben:AddPrestige(tbKinInfo, tbPrestigeAward)
    local tbHadAdded = {}
    for nIdx, dwKinId in pairs(tbKinInfo) do
        tbFubenMgr:AddPrestige(dwKinId, tbPrestigeAward[nIdx])
    end
end

function tbFuben:DropBuff(pNpc, pKiller)
    local _, nX, nY = pNpc.GetWorldPos()
    local nProb     = self:GetNpcBuffProb(pNpc.nTemplateId)
    if nProb >= MathRandom(10000) and pKiller then
        local pPlayer = pKiller.GetPlayer()
        if pPlayer then
            pKiller.AddSkillState(1706, 1, 0, Env.GAME_FPS * 15)
            pPlayer.CallClientScript("Fuben.WhiteTigerFuben:DropBuff", nX, nY)
        end
    end
end

function tbFuben:GetNpcBuffProb(nTemplateId)
    local tbNpcInfo = tbFubenMgr:GetNpcInfo(nTemplateId) or {}
    local nProb     = tbNpcInfo.nProb or 0
    return nProb
end

function tbFuben:GetNpcLevel(nTemplateId)
    local tbNpcInfo = tbFubenMgr:GetNpcInfo(nTemplateId)
    if not tbNpcInfo then
        local nLevel = self.nEnemyLevel and self.nEnemyLevel or self:GetAverageLevel()
        return nLevel
    end

    return tbNpcInfo.nLevel
end

function tbFuben:GetNpcAward(nTemplateId)
    local tbNpcInfo = tbFubenMgr:GetNpcInfo(nTemplateId)
    if not tbNpcInfo then
        return
    end

    return tbNpcInfo.szDropFile, tbNpcInfo.nDropType, {tbNpcInfo.nTreasure1, tbNpcInfo.nTreasure2, tbNpcInfo.nTreasure3}
end

function tbFuben:AddNpc(nIndex, nNum, nLock, szGroup, szPointName, bRevive, nDir, nDealyTime, nEffectId, nEffectTime, ...)
    self:_AddNpc(nIndex, nNum, nLock, szGroup, szPointName, bRevive, nDir, nDealyTime, nEffectId, nEffectTime, ...)
end

function tbFuben:DoAddNpc(tbNpcInfo, tbEffectInfo, nLock, szGroup, nFloor, nRoomIdx)
    if self.bClose == 1 then
        return
    end

    local nTemplateId = tbNpcInfo.nTemplateId
    tbNpcInfo.nLevel  = self:GetNpcLevel(nTemplateId)

    local pNpc = KNpc.Add(nTemplateId, tbNpcInfo.nLevel, tbNpcInfo.nSeries or -1, tbNpcInfo.nMapId, tbNpcInfo.nX, tbNpcInfo.nY, tbNpcInfo.bRevive or 0, tbNpcInfo.nDir);
    if pNpc then
        self:AddNpcInLock(pNpc, nLock);
        self:AddNpcInGroup(pNpc, szGroup);
        self:OnAddNpc(pNpc);

        local nReviveFrame = self.tbReviveInfo[nTemplateId]
        if nReviveFrame and nReviveFrame > 0 then
            local tbReviveInfo = {["szGroup"] = szGroup, ["nReviveFrame"] = nReviveFrame, ["nLock"] = nLock}
            tbReviveInfo.tbNpcInfo = tbNpcInfo
            tbReviveInfo.tbEffectInfo = tbEffectInfo
            pNpc.tbReviveInfo = tbReviveInfo
        end

        if nFloor then
            if nFloor == 1 then
                self.tbBossNpcId[nFloor] = pNpc.nId
                Npc:RegNpcOnDeath(pNpc, self.OnRoomBossDeath, self, 1, 0)
            else
                local nRoomId = self:GetRoomId(nFloor, nRoomIdx)
                self.tbBossNpcId.tbMainFloor[nRoomId] = pNpc.nId
                Npc:RegNpcOnDeath(pNpc, self.OnRoomBossDeath, self, nFloor, nRoomId)
            end
        end
        self:OnBossBorn(nFloor, nRoomIdx)
    else
        Log("[WhiteTigerFuben]AddNpc Failed!", self.nMapId, nTemplateId, tbNpcInfo.nLevel, tbNpcInfo.nSeries, tbNpcInfo.nX, tbNpcInfo.nY, tbNpcInfo.nDir)
    end
end

function tbFuben:OnBossBorn(nFloor, nRoomIdx)
    if not nFloor then
        return
    end

    local szGroup = "guaiwu"
    if nFloor == 1 then
    elseif nFloor == 4 then
        szGroup = "guaiwu3"
    else
        nFloor = nFloor - 1
        szGroup = szGroup .. nFloor .. "_" .. nRoomIdx
    end

    self.tbNoRevive = self.tbNoRevive or {}
    self.tbNoRevive[szGroup] = true
end

function tbFuben:ReviveNpc(pNpc)
    if pNpc.tbReviveInfo then
        local nFrame = pNpc.tbReviveInfo.nReviveFrame
        Timer:Register(nFrame, self.DoRevive, self, pNpc.tbReviveInfo)
    end
end

function tbFuben:DoRevive(tbReviveInfo)
    if self.bClose == 1 then
        return
    end

    local szGroup = tbReviveInfo.szGroup
    if not self.tbNpcGroup[szGroup] then
        return
    end

    if self.tbNoRevive and self.tbNoRevive[szGroup] then
        return
    end

    self:DoAddNpc(tbReviveInfo.tbNpcInfo, tbReviveInfo.tbEffectInfo, tbReviveInfo.nLock, tbReviveInfo.szGroup)
end

function tbFuben:SendRedbag(nFloor, pKiller)
    if pKiller.GetPlayer() then
        pKiller = pKiller.GetPlayer()
    end

    if not pKiller.dwID then
        return
    end

    if nFloor == 4 then
        pKiller.CallClientScript("GameSetting.Comment:OnEvent", GameSetting.Comment.Type_WhiteTiger_BOSS);
    end

    tbFubenMgr:SendRedbag(nFloor, pKiller)
end

function tbFuben:OnRoomBossDeath(nFloor, nRoomId, pKiller)
    if nFloor == #self.tbRoomNum then
        local tbKin = tbFubenMgr:GetKillNpcKin(him) or {}
        self.nWinKin = tbKin[1] or 0
        Log("WhiteTigerFuben Kill TopBoss Kin Is", self.nWinKin)
    end

    if not pKiller then
        return
    end
    if nFloor == 1 then
        local tbPlayer = KPlayer.GetMapPlayer(self.nMapId)
        for _, pPlayer in ipairs(tbPlayer or {}) do
            self:AddImitity(pPlayer, Env.LogWay_WhiteTigerFuben_BOSS)
        end
    else
        self:RoomPlayerExcute(nRoomId, function (pPlayer)
            self:AddImitity(pPlayer, Env.LogWay_WhiteTigerFuben_BOSS)
        end)
    end

    self:SendRedbag(nFloor, pKiller)
end

function tbFuben:OnOpenCrossDoor()
    if not self.bFinalBossDeath then
        return
    end

    if not self.bFightMap then
        return
    end

    if not tbFubenMgr.nCrossMapId or not tbFubenMgr.nCrossRoomIdx then
        Log("WhiteTigerFuben OnOpenCrossDoor No CrossFuben Err")
        return
    end

    if self.nWinKin <= 0 then
        Log("WhiteTigerFuben OnOpenCrossDoor GetKillKinId Err")
        return
    end

    local nX = 10260
    local nY = 9563
    local pNpc = KNpc.Add(73, 1, -1, self.nMapId, nX, nY, 0, 0)
    if pNpc then
        self.nGotoCrossTrapNpc = pNpc.nId
    end

    self:ChangeTrap("ToCross", nil, nil, nil, nil, "GotoCrossFuben")
    self:BlackMsg("通往第五層的入口開啟了")

    local szTitle = "前往第五層"
    local tbRoomState = self:GetRoomState(self.nTopRoom)
    tbRoomState.szTitle = szTitle
    tbRoomState.nX = nX
    tbRoomState.nY = nY
    local fnChangeTitle = function (pPlayer)
        pPlayer.CallClientScript("Fuben.WhiteTigerFuben:SetFubenInfo", -1, szTitle, nX or 0, nY or 0)
    end
    self:RoomPlayerExcute(self.nTopRoom, fnChangeTitle)

    local tbKinData = Kin:GetKinById(self.nWinKin) or {szName = ""}
    local nServerIdx = GetServerListIndex()
    CallZoneServerScript("Fuben.WhiteTigerFuben:SyncKillBossKinId", self.nWinKin, tbKinData.szName, nServerIdx)
    Log("WhiteTigerFuben OpenCrossDoor", self.nWinKin)
end

function tbFuben:OnGotoCrossFuben()
    if me.dwKinId ~= 0 and me.dwKinId == self.nWinKin then
        me.GotoEntryPoint()
        local nId = me.dwID
        Timer:Register(2, function ()
            local pPlayer = KPlayer.GetPlayerObjById(nId)
            if not pPlayer then
                return
            end
            if pPlayer.dwTeamID > 0 then
                TeamMgr:QuiteTeam(pPlayer.dwTeamID, pPlayer.dwID)
            end
            local nX, nY = unpack(tbFubenMgr.tbMainRoomTrap[tbFubenMgr.nCrossRoomIdx])
            if not pPlayer.SwitchZoneMap(tbFubenMgr.nCrossMapId, nX, nY) then
                pPlayer.CenterMsg("副本進入失敗")
                return
            end
        end)
    end
end

function tbFuben:IsCaptain(pPlayer)
    if not pPlayer or pPlayer.dwTeamID == 0 then
        return
    end

    local tbTeamData = TeamMgr:GetTeamById(pPlayer.dwTeamID)
    return tbTeamData:GetCaptainId() == pPlayer.dwID
end

function tbFuben:AddImitity(pPlayer, szKind)
    if not self:IsCaptain(pPlayer) then
        return
    end

    local tbTeamData = TeamMgr:GetTeamById(pPlayer.dwTeamID)
    local tbAllMember = tbTeamData:GetMembers()
    if not tbAllMember or #tbAllMember < 2 then
        return
    end

    local tbMember = {}
    for _, nMember in ipairs(tbAllMember) do
        local pMember = KPlayer.GetPlayerObjById(nMember) or {}
        local nMapTID = pMember.nMapTemplateId
        if nMapTID == tbFubenMgr.FIGHT_MAPID or nMapTID == tbFubenMgr.OUTSIDE_MAPID or nMapTID == tbFubenMgr.CROSS_MAP_TID then
            table.insert(tbMember, nMember)
        end
    end
    if #tbMember < 2 then
        return
    end

    local nMemberCount = #tbMember
    for i = 1, nMemberCount - 1 do
        for j = i + 1, nMemberCount do
            FriendShip:AddImitityByKind(tbMember[i], tbMember[j], szKind)
        end
    end
    Log("[WhiteTigerFuben AddImitity]", pPlayer.dwTeamID, szKind)
end

function tbFuben:OnTimeOut()
    local tbPlayer = KPlayer.GetMapPlayer(self.nMapId)
    for _, pPlayer in ipairs(tbPlayer) do
        self:SetPkMode(pPlayer, Player.MODE_PEACE)
        pPlayer.GotoEntryPoint()
    end

    if self.bClose == 1 then
        return
    end

    self:Close()
end

function tbFuben:OnBossDeath()
    self:ChangeTrap("GotoNext", nil, nil, nil, nil, "GotoMainFuben")
end

function tbFuben:OnGotoMainFuben()
    if tbFubenMgr:IsTopBossDeath() then
        return
    end

    self:AddImitity(me, Env.LogWay_WhiteTigerFuben_OF)
    tbFubenMgr:GotoMainFuben(me, self.nMapId)
end

function tbFuben:OnChangeRoomState(nFloor, nRoomIdx, szTitle, bBossDeath, nX, nY)
    local nRoomId       = self:GetRoomId(nFloor, nRoomIdx)
    local tbRoomState   = self:GetRoomState(nRoomId)
    tbRoomState.szTitle = szTitle
    tbRoomState.nX = nX or 0
    tbRoomState.nY = nY or 0
    if bBossDeath then
        tbRoomState.bBossDeath = true
        if nRoomId == self.nTopRoom then
            self.bFinalBossDeath = true
            tbFubenMgr:OnTopBossDeath()

            local nTopFloor = #self.tbRoomNum
            local fnAddAchi = function (pPlayer)
                Achievement:AddCount(pPlayer, "WhiteTiger_3")
                local tbAward = {{"Contrib", tbFubenMgr.tbFloorContribution[nTopFloor]}}
                tbFubenMgr:MergeAward(tbAward, pPlayer.nLevel, nil, nTopFloor)
                pPlayer.SendAward(tbAward, nil, true, Env.LogWay_WhiteTigerFuben_OF)
            end
            self:RoomPlayerExcute(nRoomId, fnAddAchi)
            Log("WhiteTigerFubenBase Final Boss Death")
        elseif self.bFinalBossDeath then
            local tbTopRoomState = self:GetRoomState(self.nTopRoom)
            tbRoomState.szTitle = tbTopRoomState.szTitle
        end
    end

    local fnChangeTitle = function (pPlayer)
        pPlayer.CallClientScript("Fuben.WhiteTigerFuben:SetFubenInfo", -1, szTitle, nX or 0, nY or 0)
    end
    self:RoomPlayerExcute(nRoomId, fnChangeTitle)
end

function tbFuben:GetRoomState(nRoomId)
    self.tbRoomState[nRoomId] = self.tbRoomState[nRoomId] or {}
    return self.tbRoomState[nRoomId]
end

function tbFuben:RoomPlayerExcute(nExcuteRoomId, fnExcute)
    for dwID, tbInfo in pairs(self.tbPlayer) do
        local nRoomId = self.tbPlayerRoomId[dwID]
        if nRoomId and nRoomId == nExcuteRoomId then
            local pPlayer = KPlayer.GetPlayerObjById(dwID)
            if pPlayer and tbInfo and tbInfo.bInFuben == 1 then
                fnExcute(pPlayer)
            end
        end
    end
end

--与通用相比，少了关闭死亡事件监听
function tbFuben:LeaveFuben(pPlayer)
    local nPlayerId = pPlayer.dwID;
    if not self.tbPlayer[nPlayerId] or self.tbPlayer[nPlayerId].bInFuben ~= 1 then
        return;
    end

    self:OnOut(pPlayer);

    for szWnd in pairs(self.tbCacheWnd or {}) do
        pPlayer.CallClientScript("Ui:CloseWindow", szWnd);
    end

    for nSkillId in pairs(self.tbUsedSkillState or {}) do
        pPlayer.GetNpc().RemoveSkillState(nSkillId);
    end

    pPlayer.ClearTempRevivePos();

    pPlayer.CallClientScript("Ui:SetAllUiVisable", true);
    pPlayer.CallClientScript("Ui:SetForbiddenOperation", false);

    self.tbPlayer[nPlayerId].bInFuben = 0;
end

function tbFuben:OnLeaveMap()
    local nPlayerId = me.dwID
    if self.tbPlayer[nPlayerId].nDeathCallbackId then
        PlayerEvent:UnRegister(me, "OnDeath", self.tbPlayer[nPlayerId].nDeathCallbackId)
        self.tbPlayer[nPlayerId].nDeathCallbackId = nil
    end
end

function tbFuben:OnClose()
    if self.nStartPkTimer then
        Timer:Close(self.nStartPkTimer)
        self.nStartPkTimer = nil
    end
end

function tbFuben:GetWtfBossId(dwPlayerID)
    if self.bFightMap then
        local nRoomId = self.tbPlayerRoomId[dwPlayerID]
        if nRoomId then
            return self.tbBossNpcId.tbMainFloor[nRoomId]
        end
    else
        return self.tbBossNpcId[1]
    end
end