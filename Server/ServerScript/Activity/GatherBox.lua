local tbAct = Activity:GetClass("GatherBox")

tbAct.tbTrigger = {
    Init    = { },
    Start   = { },
    End     = { },
}

tbAct.tbRefreshTime = {1.5, 7.5, 9.5}
tbAct.tbCreateBoxCount = {
{10, 1},
{40, 3},
{70, 6},
{100, 9},
{130, 12},
{9999, 20},
}
tbAct.nBoxTemplateId = 1840
tbAct.nGroup = 60
tbAct.nDataDay = 1
tbAct.nTimes = 2
tbAct.nCanOpenTimes = 10
tbAct.tbPos = {
    {4657,3766},
    {4922,5011},
    {5311,3529},
    {5740,3611},
    {4246,4752},
    {4300,4310},
    {4205,3548},
    {5955,4796},
    {6132,4278},
    {6034,3946},
    {4325,5428},
    {4025,5077},
    {5074,5450},
    {5456,5437},
    {5800,5279},
    {3892,4537},
    {3911,4205},
    {4600,4038},
    {4764,4632},
    {5099,4708},
    {5140,3823},
    {3943,3744},
    {4306,3924},
    {5545,3867},
    {5627,4231},
    {4600,5254},
    {4663,5602},
    {5263,5728},
    {4158,5794},
    {3934,5542},
    {5775,5750},
    {3665,3915},
    {3580,4335},
    {3513,4689},
    {3637,3567},
    {4913,3425},
    {6217,3738},
    {6448,4158},
    {5898,4509},
    {5510,4597},
    {5475,4979},
    {4818,5940},
    {6454,4572},
}

tbAct.tbNewInfo = {
    GatherBox = function (self)
        local nStartTime, nEndTime = self:GetOpenTimeInfo()
        local nStartDay = Lib:GetLocalDay(nStartTime)
        local nEndDay = Lib:GetLocalDay(nEndTime)
        local nMaxLevel = self.tbParam[1]
        local szTitle = string.format("%d級開放慶典", nMaxLevel)
        local szContent = string.format("[FFFE0D]等級上限開放慶典[-]\n    諸位俠士，如今%d級已然開放，諸位可通過新活動多加磨練，將武藝修煉至登峰造極，早日功成名就。\n    值此歡盛之際，%d天內的幫派烤火都將舉行歡慶，屆時幫派地圖將刷新大量慶典寶箱，烤火答題前刷新一波，答題後刷新兩波，拾取者將獲得大量獎勵，可莫要忘記參與！天下武功，唯快不破！速速去搶奪寶箱吧！\n    另傳聞行腳商人賈有錢西行歸來，將會在拍賣行[FFFE0D]停留3天[-]，[FFFE0D]每天19:05[-]開設專場拍賣。屆時將競拍[FFFE0D]各類稀有珍品[-]，諸位俠士們可不要錯過哦！", nMaxLevel, nEndDay - nStartDay)
        return {szContent}, {szTitle = szTitle, nReqLevel = 10}
    end,
    ServerCelebration = function (self)
        local _, nEndTime = self:GetOpenTimeInfo()
        local nMonthDay = Lib:GetMonthDay(nEndTime - 1)
        local szContent = string.format("[FFFE0D]迎資料片江湖狂歡[-]\n    諸位俠士，如今江湖即將迎來重大變革，武林中諸多幫派將開啟慶典，共襄盛舉。\n    值此歡盛之際，各大幫派的幫派烤火都將舉行歡慶，屆時幫派地圖將刷新大量慶典寶箱，烤火答題前刷新一波，答題後刷新兩波，拾取者將獲得大量獎勵，可莫要忘記參與！天下武功，唯快不破！速速去搶奪寶箱吧！", nMonthDay)
        return {szContent}, {szTitle = "迎資料片江湖狂歡", nReqLevel = 10}
    end,
}

function tbAct:OnTrigger(szTrigger)
    local tbData = ScriptData:GetValue("GatherBox")
    tbData.tbCloseKey = tbData.tbCloseKey or {}
    if tbData.tbCloseKey[self.szKeyName] then
        Log("GatherBox Always Close", self.szKeyName)
        return
    end

    if szTrigger == "Init" then
        self:ChangeEndTime()
        self:SendNews()
    elseif szTrigger == "Start" then
        Activity:RegisterPlayerEvent(self, "Act_KinGather_Open", "OnKinGatherBebin")
        Activity:RegisterPlayerEvent(self, "Act_KinGather_Close", "OnKinGatherStop")
        Activity:RegisterPlayerEvent(self, "Act_TryOpenGatherBox", "TryOpenGatherBox")
        Log("GatherBox Begin", self.szKeyName)
    end
end

function tbAct:CheckConflictTime()
    local nSelfStartTime, nSelfEndTime = self:GetOpenTimeInfo()
    for _, tbInfo in ipairs(Activity.tbActivityPlan) do
        if tbInfo.Type == "GatherBox" and self.szKeyName ~= tbInfo.KeyName then
            local nStartTime = Activity:GetActBeginTime(tbInfo.KeyName)
            local nEndTime = Activity:GetActEndTime(tbInfo.KeyName)
            if nStartTime > 0 and nEndTime > 0 and
                (nSelfStartTime == nStartTime or nSelfEndTime == nEndTime or
                (nSelfStartTime < nStartTime and nSelfEndTime > nStartTime) or (nSelfStartTime > nStartTime and nSelfStartTime < nEndTime)) then
                local tbData = ScriptData:GetValue("GatherBox")
                tbData.tbCloseKey = tbData.tbCloseKey or {}
                tbData.tbCloseKey[tbInfo.KeyName] = true
                ScriptData:AddModifyFlag("GatherBox")
                Log("GatherBox CheckConflictTime True", tbInfo.KeyName)
                return nEndTime - nStartTime
            end
        end
    end
end

function tbAct:ChangeEndTime()
    local nDelayEndTime = self:CheckConflictTime()
    if nDelayEndTime and nDelayEndTime > 0 then
        local tbActData, tbRunning = Activity:GetActivityData()
        tbActData[self.szKeyName].nEndTime = tbActData[self.szKeyName].nEndTime + nDelayEndTime
        tbRunning[self.szKeyName].nEndTime = tbRunning[self.szKeyName].nEndTime + nDelayEndTime
        Log("GatherBox ChangeEndTime", self.szKeyName, nDelayEndTime)
    end
end

function tbAct:OnKinGatherBebin()
    self.tbBoxNpc = self.tbBoxNpc or {}
    self:ClearNpc()
    if self.nCreateBoxTimer then
        Timer:Close(self.nCreateBoxTimer)
    end

    self.nCreateBoxTimer = Timer:Register(Env.GAME_FPS * 60 * self.tbRefreshTime[1], self.OnTime2CreateBox, self, 1)
    Log("GatherBox OnKinGatherBebin")
end

function tbAct:OnTime2CreateBox(nTimeIdx)
    Kin:TraverseKinInDiffTime(1, function (kinData)
        self:CreateBox(kinData.nKinId)
    end);

    nTimeIdx = nTimeIdx + 1
    if not self.tbRefreshTime[nTimeIdx] then
        self.nCreateBoxTimer = nil
        Log("GatherBox DayClose")
        return
    end

    local nTime = self.tbRefreshTime[nTimeIdx] - self.tbRefreshTime[nTimeIdx - 1]
    self.nCreateBoxTimer = Timer:Register(Env.GAME_FPS * 60 * nTime, self.OnTime2CreateBox, self, nTimeIdx)
    Log("GatherBox OnTime2CreateBox")
end

function tbAct:CreateBox(nKinId)
    local kinData = Kin:GetKinById(nKinId)
    if not kinData then
        return
    end
    local nMapId = kinData:GetMapId()
    if not nMapId then
        return
    end

    local tbPlayer, nPlayerCount = KPlayer.GetMapPlayer(nMapId)
    local nCreateNpcCount = nPlayerCount * 3
    for i = 1, nCreateNpcCount do
        local tbPos = self.tbPos[MathRandom(#self.tbPos)]
        local nX, nY = unpack(tbPos)
        local pNpc = KNpc.Add(self.nBoxTemplateId, 1, 0, nMapId, nX, nY)
        table.insert(self.tbBoxNpc, pNpc.nId)
    end

    KPlayer.MapBoardcastScript(nMapId, "Ui:OpenWindow", "GatherBoxAnimation")
    local szMsg = "幫派總管：諸位幫派弟兄，慶典寶箱已經運到，天下武功，唯快不破！諸位弟兄！此刻不動手，更待何時！"
    ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.Kin, szMsg, kinData.nKinId)
    Log("GatherBox CreateBox", nKinId, nCreateNpcCount)
end

function tbAct:OnKinGatherStop()
    self.tbBoxNpc = self.tbBoxNpc or {}
    Timer:Register(Env.GAME_FPS * 60 * 3, self.ClearNpc, self)
end

function tbAct:ClearNpc()
    if #self.tbBoxNpc == 0 then
        return
    end

    for _, nId in ipairs(self.tbBoxNpc) do
        local pNpc = KNpc.GetById(nId)
        if pNpc then
            pNpc.Delete()
        end
    end
    self.tbBoxNpc = {}
    Log("GatherBox Today Act Close Delete Npc")
end

function tbAct:CheckCanOpen(pPlayer, pNpc)
    if pPlayer.CheckNeedArrangeBag() then
        return false, "背包已滿，請清理背包"
    end

    local nDataDay = pPlayer.GetUserValue(self.nGroup, self.nDataDay)
    local nOpenTimes = pPlayer.GetUserValue(self.nGroup, self.nTimes)
    if Lib:GetLocalDay() ~= nDataDay then
        pPlayer.SetUserValue(self.nGroup, self.nDataDay, nDataDay)
        pPlayer.SetUserValue(self.nGroup, self.nTimes, 0)
        return true
    end

    return nOpenTimes < self.nCanOpenTimes, string.format("每天只能打開%d個%s", self.nCanOpenTimes, pNpc.szName)
end

function tbAct:TryOpenGatherBox(pPlayer, pBox)
    local bRet, szMsg = self:CheckCanOpen(pPlayer, pBox)
    if not bRet then
        pPlayer.CenterMsg(szMsg)
        return
    end
    GeneralProcess:StartProcess(pPlayer, Env.GAME_FPS, "開啟中", self.EndProcess, self, pPlayer.dwID, pBox.nId)
end

function tbAct:EndProcess(dwID, nNpcId)
    local pPlayer = KPlayer.GetPlayerObjById(dwID)
    local pNpc    = KNpc.GetById(nNpcId)
    if not pPlayer then
        return
    end

    if not pNpc or pNpc.IsDelayDelete() then
        pPlayer:CenterMsg("已被其他人搶先打開啦")
        return
    end

    local bRet, szMsg = self:CheckCanOpen(pPlayer, pNpc)
    if not bRet then
        pPlayer.CenterMsg(szMsg)
        return
    end

    pNpc.Delete()

    local nRandomItemId = tonumber(pNpc.szScriptParam)
    if not nRandomItemId then
        Log("GatherBox Award Error")
        return
    end

    local nDataDay = pPlayer.SetUserValue(self.nGroup, self.nDataDay, Lib:GetLocalDay())
    local nOpenTimes = pPlayer.GetUserValue(self.nGroup, self.nTimes)
    pPlayer.SetUserValue(self.nGroup, self.nTimes, nOpenTimes + 1)
    pPlayer.SendAward({{"Item", nRandomItemId, 1}}, false, true, Env.LogWay_GatherBox)
end

function tbAct:SendNews()
    for szKey, fn in pairs(self.tbNewInfo) do
        if string.find(self.szKeyName, szKey) then
            local tbData, tbSetting = fn(self)
            local _, nEndTime = self:GetOpenTimeInfo()
            NewInformation:AddInfomation(self.szKeyName, nEndTime, tbData, tbSetting)
            return
        end
    end
end