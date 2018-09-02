--家族试炼
Require("ServerScript/Fuben/KinTrain/KinTrainMgr.lua")
Fuben.KinTrainMgr.FubenDef = {
    MATERIAL_TYPE_COUNT = 5, --物资种类数量
    CAR_TEMPLATE        = 1201, --物资车
    tbMaterialInfo      = {100, 100, 100, 100, 100}, --收集物完美数量，客户端(KinTrainMatPanel)显示也有相同的一份
    tbBossTemplateId    = {{16, 1194}, {6, 1193}, {1, 1192}, {0, 1191}},
    tbMaterialCarPos    = {11056, 10680},
    tbBossPos           = {11449, 11852},
    tbMaterialNpc = { --物资npc配置信息
        [1196] = {nType = 1, nDropNum = 5, nCreateNum = 200},--TemplateId, 添加的物资类型数量, 一共产生多少个
        [1197] = {nType = 2, nDropNum = 5, nCreateNum = 200},
        [1198] = {nType = 3, nDropNum = 5, nCreateNum = 200},
        [1199] = {nType = 4, nDropNum = 5, nCreateNum = 200},
        [1200] = {nType = 5, nDropNum = 5, nCreateNum = 200},
    },
    tbDropAward = { --npc掉落，给地图里所有家族成员掉落该数量,第二个参数为掉落概率，概率最大为 100,第三个参数是附加的基准经验
        [1190] = {{"Item", 1463, 1}, 30, 1.2},--金军斥候
        [1254] = {{"Item", 1463, 1}, 50, 1.2},--机关战车
        [1255] = {{"Item", 1463, 1}, 100, 1.2},--金军校尉
        [1256] = {{"Item", 1463, 1}, 100, 1.2},--金军头目
        [1257] = {{"Item", 1463, 1}, 100, 1.2},--蒙面杀手
        [1259] = {{"Item", 1463, 1}, 100, 1.2},--金军斥候·精英
        [1260] = {{"Item", 1463, 3}, 100, 1.2},--火炮
		
        [1191] = {{"Item", 1463, 40}, 100, 1.2},--BOSS1
        [1192] = {{"Item", 1463, 20}, 100, 1.2},--BOSS2
        [1193] = {{"Item", 1463, 10}, 100, 1.2},--BOSS3
        [1194] = {{"Item", 1463, 5}, 100, 1.2},--BOSS4
		
		[1290] = {{"Item", 1463, 1}, 30, 1.2},--金军斥候---2档强度
        [1291] = {{"Item", 1463, 1}, 50, 1.2},--机关战车---2档强度
        [1292] = {{"Item", 1463, 1}, 100, 1.2},--金军校尉---2档强度
        [1293] = {{"Item", 1463, 1}, 100, 1.2},--金军头目---2档强度
        [1294] = {{"Item", 1463, 1}, 100, 1.2},--蒙面杀手---2档强度
        [1295] = {{"Item", 1463, 1}, 100, 1.2},--金军斥候·精英---2档强度
        [1296] = {{"Item", 1463, 3}, 100, 1.2},--火炮---2档强度
		
		[1297] = {{"Item", 1463, 1}, 30, 1.2},--金军斥候---3档强度
        [1298] = {{"Item", 1463, 1}, 50, 1.2},--机关战车---3档强度
        [1299] = {{"Item", 1463, 1}, 100, 1.2},--金军校尉---3档强度
        [1300] = {{"Item", 1463, 1}, 100, 1.2},--金军头目---3档强度
        [1301] = {{"Item", 1463, 1}, 100, 1.2},--蒙面杀手---3档强度
        [1302] = {{"Item", 1463, 1}, 100, 1.2},--金军斥候·精英---3档强度
        [1303] = {{"Item", 1463, 3}, 100, 1.2},--火炮---3档强度
    },
    tbBoxAward = { --开启宝箱的奖励掉落，每一层不一样
        [1] = {{"Item", 1463, 1}, 30, 1.2},
        [2] = {{"Item", 1463, 1}, 50, 1.2},
        [3] = {{"Item", 1463, 1}, 100, 1.2},
        [4] = {{"Item", 1463, 2}, 100, 1.2},
        [5] = {{"Item", 1463, 3}, 100, 1.2},
    },
    tbPlayerNumForNpIdx = {10, 25},
    tbPrestige = { --通关根据人数添加的家族威望
        --第一个参数为人数，第二个是添加的威望
        {5, 40},
        {10, 60},
        {20, 80},
        {30, 100},
        {40, 120},
        {50, 140},
        {60, 160},
        {999, 200},
    },
}

local tbFuben = Fuben:CreateFubenClass("KinTrainBase")
local tbDef = Fuben.KinTrainMgr.FubenDef
function tbFuben:OnCreate(dwKinId)
    self.tbCollection    = {0, 0, 0, 0, 0}
    self.tbCreateNpcNum  = {0, 0, 0, 0, 0}
    self.tbMaterialGroup = {}
    self.tbPushMatInfo   = {} --实时更新物资信息的玩家列表
    self.tbEnterTime     = {} --玩家进入时间，在准备时间内进进出出会重置进入时间
    self.bTrainHadBegin  = false
    self.dwKinId         = dwKinId
    self.tbJoinPlayer    = {}
    self.tbHadAddFlag    = {}
    
    self:Start()
    self:LoadMaterialPos()
end

function tbFuben:LoadMaterialPos()
    self.tbNpcCreatePos = {}
    local tbPath = Lib:LoadTabFile("Setting/Fuben/KinTrail/MaterialNpcPos.tab", {X = 1, Y = 1})
    for _, tbPos in ipairs(tbPath) do
        table.insert(self.tbNpcCreatePos, {tbPos.X, tbPos.Y})
    end
end

function tbFuben:OnLogin()
    self:OnJoin(me)
end

function tbFuben:OnJoin(pPlayer)
    local bShowLeave = not self.bTrainHadBegin
    local nEndTime   = Fuben.KinTrainMgr:GetEndTime() or 0
    pPlayer.CallClientScript("Fuben.KinTrainMgr:OnEntryMap", bShowLeave, nEndTime)

    if self.bClose ~= 1 and self.tbCacheProgressInfo then
        pPlayer.CallClientScript("Fuben:SetFubenProgress", unpack(self.tbCacheProgressInfo))
    end

    self.tbEnterTime[pPlayer.dwID] = self.tbEnterTime[pPlayer.dwID] or GetTime()
    Kin:JoinChatRoom(pPlayer)

    if not self.tbJoinPlayer[pPlayer.dwID] and pPlayer.nHonorLevel > 2 and pPlayer.nLevel > Fuben.KinTrainMgr.AUCTION_LEVEL then
        self.tbJoinPlayer[pPlayer.dwID] = true
    end

    if self.bTrainHadBegin then
        self:OnJoinActiviy(pPlayer)
    end
    pPlayer.nCanLeaveMapId = self.nMapId
    Log("KinTrainBase Join:", pPlayer.dwID, pPlayer.nLevel, pPlayer.nHonorLevel, tostring(self.tbJoinPlayer[pPlayer.dwID]))
end

function tbFuben:OnLeaveMap(pPlayer)
    pPlayer.CallClientScript("Ui:CloseWindow", "HomeScreenFuben")

    if self.bTrainHadBegin then
        local nMatchTime = self.tbEnterTime[pPlayer.dwID] or 0
        nMatchTime = GetTime() - nMatchTime
        local nResult = (self.bClose == 1 and self.nNpcIdx) and Env.LogRound_SUCCESS or Env.LogRound_FAIL --self.nNpcIdx在能开启试炼才会赋值，所以这里可以用一下
        pPlayer.TLogRoundFlow(Env.LogWay_KinTrain, self.nMapId, 0, nMatchTime, nResult, 0, 0)
        pPlayer.TLog("KinMemberFlow", pPlayer.dwKinId, Env.LogWay_KinTrain, self.nMapId, nResult)
    end

    ChatMgr:LeaveKinChatRoom(pPlayer);
end

function tbFuben:BeginTrain()
    self.bTrainHadBegin = true
    local tbPlayer, nPlayerNum = KPlayer.GetMapPlayer(self.nMapId)
    if nPlayerNum < Fuben.KinTrainMgr.OPEN_MEMBER_NUM then
        self:Close()
        KPlayer.MapBoardcastScript(self.nMapId, "Fuben.KinTrainMgr:OnFubenStartFail")
        return
    end

    self.nNpcIdx = nil
    for nIdx, nNum in ipairs(tbDef.tbPlayerNumForNpIdx) do
        if nPlayerNum <= nNum then
            self.nNpcIdx = nIdx
            break
        end
    end
    self.nNpcIdx = self.nNpcIdx or (#tbDef.tbPlayerNumForNpIdx + 1)

    self.nAddPrestige = tbDef.tbPrestige[1][2]
    for _, tbInfo in ipairs(tbDef.tbPrestige) do
        if nPlayerNum <= tbInfo[1] then
            self.nAddPrestige = tbInfo[2]
            break
        end
    end

    for _, pPlayer in pairs(tbPlayer) do
        self:OnJoinActiviy(pPlayer)
    end
    Log("Kin BeginTrain:", self.dwKinId, self.nMapId, self.nNpcIdx, nPlayerNum)

    local nEndTime = Fuben.KinTrainMgr:GetEndTime() or 0
    KPlayer.MapBoardcastScript(self.nMapId, "Fuben.KinTrainMgr:OnTrainBegin", false, nEndTime)
    self:UnLock(100)
end

function tbFuben:OnJoinActiviy(pPlayer)
    if not pPlayer or self.tbHadAddFlag[pPlayer.dwID] then
        return
    end

    self.tbHadAddFlag[pPlayer.dwID] = 1
    EverydayTarget:AddCount(pPlayer, "KinFuben", 1)
    Achievement:AddCount(pPlayer, "KinFuben_1", 1)
    TeacherStudent:TargetAddCount(pPlayer, "KinPractice", 1)
    TeacherStudent:CustomTargetAddCount(pPlayer, "KinPractice", 1)
    Log("KinTrainBase OnJoinActiviy", pPlayer.dwID)
end

function tbFuben:OnBoxOpen(pNpc, bComplete)
    if bComplete then
        self:UnLock(101)
    end

    local tbAwardInfo = tbDef.tbBoxAward[pNpc.nOpenTimes]
    if not tbAwardInfo then
        return
    end

    self:DropAward(pNpc, tbAwardInfo)
end

function tbFuben:OnSecondTrainBegin()
    if self.bClose == 1 then
        return
    end
    for nTemplateId, _ in pairs(tbDef.tbMaterialNpc) do
        self:AddMeterialNpc(nTemplateId, 10)
    end

    local nLevel = self:GetAverageLevel()
    local pCarNpc = KNpc.Add(tbDef.CAR_TEMPLATE, nLevel, -1, self.nMapId, unpack(tbDef.tbMaterialCarPos)) --物资车
    if pCarNpc then
        self.nCarId = pCarNpc.nId
    else
        Log("KinTrainBase CreateCarError", self.nMapId)
    end
end

function tbFuben:OnPlayerDeath()
    me.Revive(1)
    me.SetPosition(unpack(Fuben.KinTrainMgr.ENTRY_POS))
end

function tbFuben:GetNumber(value)
    if type(value) == "number" then
        return value;
    end

    self.tbSetting.NUM = self.tbSetting.NUM or {};
    if not self.tbSetting.NUM[value] then
        assert(false, "KinTrainBase:GetNumber(value) ERR ?? self.tbSetting.NUM[value] is nil !! " .. self.tbSetting.szFubenClass .. "  " .. value);
        return 0;
    end

    if type(self.tbSetting.NUM[value]) == "number" then
        return self.tbSetting.NUM[value];
    end

    if not self.tbSetting.NUM[value][self.nNpcIdx] then
        assert(false, string.format("KinTrainBase:GetNumber(value) ERR ?? szFubenClass %s, value %s, nFubenLevel %s", self.tbSetting.szFubenClass, value, self.nNpcIdx));
        return 0;
    end

    return self.tbSetting.NUM[value][self.nNpcIdx];
end

function tbFuben:OnKillNpc(pNpc)
    local tbAwardInfo = tbDef.tbDropAward[pNpc.nTemplateId]
    if tbAwardInfo then
        self:DropAward(pNpc, tbAwardInfo)
    end

    if self.nBossId and pNpc.nId == self.nBossId then
        self:OnBossDeath()
        return
    end

    local nTemplateId = pNpc.nTemplateId
    local nType = self:GetMaterialType(nTemplateId)
    if not nType then
        return
    end

    local tbNpcInfo = tbDef.tbMaterialNpc[nTemplateId]
    self.tbCollection[nType] = self.tbCollection[nType] + 1
    if self.tbCreateNpcNum[nType] < tbNpcInfo.nCreateNum then
        Timer:Register(Env.GAME_FPS*10, self.AddMeterialNpc, self, nTemplateId, 1)
    end
    self.tbMaterialGroup[pNpc.nId] = nil
    self:UpdateMatPanel()
end

function tbFuben:DropAward(pNpc, tbAwardInfo)
    local nRate   = tbAwardInfo[2]
    local nRandom = MathRandom(100)
    if nRandom > nRate then
        return
    end

    local _, nPosX, nPosY = pNpc.GetWorldPos()
    local nBasicExp = (tbAwardInfo[3] or 0) * (tbAwardInfo[1][3] or 0)

    local fnDrop = function (pPlayer)
        if nBasicExp > 0 then
            local nExp = pPlayer.GetBaseAwardExp() * nBasicExp
            pPlayer.AddExperience(nExp, Env.LogWay_KinTrainNpcAward)
        end
        pPlayer.DropAward(nPosX, nPosY, nil, {tbAwardInfo[1]}, Env.LogWay_KinTrainNpcAward, nil, true)
    end
    self:AllPlayerExcute(fnDrop)
end

function tbFuben:GetMaterialType(nTemplateId)
    local tbNpcInfo = tbDef.tbMaterialNpc[nTemplateId] or {}
    return tbNpcInfo.nType
end

function tbFuben:AddMeterialNpc(nTemplateId, nNum)
    if self.bClose == 1 or self.nBossId then
        return
    end
    
    if #self.tbNpcCreatePos < nNum then
        self:LoadMaterialPos()
    end

    local nLevel = self:GetAverageLevel()
    for i = 1, nNum do
        local nRandom = MathRandom(#self.tbNpcCreatePos)
        local tbPos = table.remove(self.tbNpcCreatePos, nRandom) or {0, 0}
        local pNpc = KNpc.Add(nTemplateId, nLevel, -1, self.nMapId, unpack(tbPos))
        if pNpc then
            self.tbMaterialGroup[pNpc.nId] = true
        end
    end

    local nType = self:GetMaterialType(nTemplateId)
    self.tbCreateNpcNum[nType] = self.tbCreateNpcNum[nType] + nNum
end

function tbFuben:ShowMeterialInfo(pPlayer)
    self.tbPushMatInfo[pPlayer.dwID] = true
    pPlayer.CallClientScript("Fuben.KinTrainMgr:ShowMeterialInfo", unpack(self.tbCollection))
end

function tbFuben:OnCancelMatUpdate(pPlayer)
    self.tbPushMatInfo[pPlayer.dwID] = false
end

function tbFuben:UpdateMatPanel()
    self.nUpdateClock = self.nUpdateClock or 0
    local nClock = os.clock()
    if nClock - self.nUpdateClock < 1 then
        return
    end
    self.nUpdateClock = nClock
    
    for dwID, bNeedUpdate in pairs(self.tbPushMatInfo) do
        if bNeedUpdate then
            local pPlayer = KPlayer.GetPlayerObjById(dwID)
            if pPlayer then
                pPlayer.CallClientScript("Fuben.KinTrainMgr:ShowMeterialInfo", unpack(self.tbCollection))
            end
        end
    end
end

function tbFuben:TryDepart(pPlayer)
    local bRet, szMsg = self:CheckDepart(pPlayer)
    if not bRet then
        pPlayer.CenterMsg(szMsg)
        return
    end

    local nBossTemplateId = self:CalBossTemplateId()
    local nLevel = self:GetAverageLevel()
    local pBoss = KNpc.Add(nBossTemplateId, nLevel, -1, self.nMapId, unpack(tbDef.tbBossPos)) --boss
    if not pBoss then
        Log("KinTrainBase Depart Error", self.nMapId)
        return
    end
    
    self.nBossId = pBoss.nId
    self:DeleteMaterialNpc()

    local szBossMsg = string.format("召喚出了%s", pBoss.szName)
    local fnMsg = function (pPlayer)
        pPlayer.CenterMsg(szBossMsg)
    end
    self:AllPlayerExcute(fnMsg)
    Log("KinTrainBase Boss Create", nBossTemplateId)
end

function tbFuben:CheckDepart(pPlayer)
    if self.nBossId then
        return false, "已發車"
    end

    if self.bClose == 1 then
        return false, "幫派試煉已結束"
    end
    
    if pPlayer.dwKinId == 0 then
        return false, "沒有幫派，發車失敗"
    end

    local tbMemberList = Kin:GetKinMembers(pPlayer.dwKinId)
    if tbMemberList[pPlayer.dwID] ~= Kin.Def.Career_ViceMaster and tbMemberList[pPlayer.dwID] ~= Kin.Def.Career_Master then
        return false, "只有堂主或副堂主才能發車"
    end

    for i = 1, tbDef.MATERIAL_TYPE_COUNT do
        if not self.tbCollection[i] or self.tbCollection[i] < (tbDef.tbMaterialInfo[i] * 0.6) then
            return false, "物資不足，無法發車"
        end
    end

    return true
end

function tbFuben:CalBossTemplateId()
    local nScore = 0
    for i = 1, tbDef.MATERIAL_TYPE_COUNT do
        local nCol = self.tbCollection[i]
        local nStan = tbDef.tbMaterialInfo[i]
        if nCol < 0.6*nStan or nCol > 1.3*nStan then
            nScore = nScore + 5
        elseif (nCol >= 0.6*nStan and nCol > 0.8*nStan) or (nCol > 1.1*nStan and nCol <= 1.3*nStan) then
            nScore = nScore + 3
        elseif (nCol >= 0.8*nStan and nCol < nStan) or (nCol > nStan and nCol <= 1.1*nStan) then
            nScore = nScore + 1
        end
    end

    for _, tbInfo in ipairs(tbDef.tbBossTemplateId) do
        if nScore >= tbInfo[1] then
            return tbInfo[2]
        end
    end

    Log("KinTrainBase CalcBossId Error", self.nMapId)
    return tbDef.tbBossTemplateId[1][2]
end

function tbFuben:DeleteMaterialNpc()
    if self.nCarId then
        local pCarNpc = KNpc.GetById(self.nCarId)
        if pCarNpc then
            pCarNpc.Delete()
        end
    end

    for nNpcId, _ in pairs(self.tbMaterialGroup) do
        local pNpc = KNpc.GetById(nNpcId)
        if pNpc then
            pNpc.Delete()
        end
    end
end

function tbFuben:OnBossDeath()
    if self.bClose == 1 then
        return
    end

    local kinData = Kin:GetKinById(self.dwKinId)
    kinData:AddPrestige(self.nAddPrestige, Env.LogWay_KinTrainCommon)

    self:SendAuctionAward()
    self:Close()
    Log("KinTrainBase Boss Death", self.nMapId)
end

function tbFuben:SendAuctionAward()
    local nJoinNum = 0
    local szPlayerList = ""
    for nPlayerId, _ in pairs(self.tbJoinPlayer or {}) do
        nJoinNum = nJoinNum + 1
        szPlayerList = string.format("%s|%d", szPlayerList, nPlayerId or 0)
    end
    local tbAward = Fuben.KinTrainMgr:GetAward(nJoinNum)
    if tbAward and next(tbAward) then
        Kin:AddAuction(self.dwKinId, "KinTrain", self.tbJoinPlayer, tbAward)
    end
    Log("KinTrainBase SendAuctionAward", self.dwKinId, nJoinNum, tbAward and #tbAward or "Err", szPlayerList)
end

function tbFuben:OnTimeOut()
    if self.nBossId then
        local pNpc = KNpc.GetById(self.nBossId)
        if pNpc then
            pNpc.Delete()
        end
    end
    if self.bClose == 1 then
        return
    end

    self:Close()
    Log("KinTrainBase TimeOut", self.nMapId)
end

function tbFuben:OnClose()
    Timer:Register(Env.GAME_FPS*60*3, self.KickoutPlayer, self)
    KPlayer.MapBoardcastScript(self.nMapId, "Fuben.KinTrainMgr:OnFubenOver", "幫派試煉已結束，請離開")
end

function tbFuben:KickoutPlayer()
    local tbPlayer = KPlayer.GetMapPlayer(self.nMapId)
    for _, pPlayer in ipairs(tbPlayer) do
        pPlayer.GotoEntryPoint()
    end
    Log("KintainBase KickoutPlayer", self.nMapId)
end

function tbFuben:MemberJoinKinChatRoom()
    local tbPlayer = KPlayer.GetMapPlayer(self.nMapId)
    for _, pPlayer in ipairs(tbPlayer) do
         Kin:JoinChatRoom(pPlayer)
    end
end
