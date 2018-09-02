BiWuZhaoQin.tbBasePreMapLogic = BiWuZhaoQin.tbBasePreMapLogic or {};
local tbPreMapLogic = BiWuZhaoQin.tbBasePreMapLogic;

function BiWuZhaoQin:CreatePreMapLogic(nMapId)
    local nTargetId = self.tbApplyPreMapID[nMapId];
    if not nTargetId then
        Log("Error BiWuZhaoQin fnCreatePreMapLogic nTargetId", nMapId);
        return;
    end

    self.tbApplyPreMapID[nMapId] = nil;

    local tbPrLogic = self:GetPreMapLogic(nMapId);
    if tbPrLogic then
        Log("Error BiWuZhaoQin fnCreatePreMapLogic Exist tbPrLogic", nMapId, nTargetId);
        return;
    end

    local tbFightInfo = BiWuZhaoQin:GetFightInfo(nTargetId)
    if not tbFightInfo then
        Log("Error BiWuZhaoQin fnCreatePreMapLogic tbFightInfo", nMapId, nTargetId);
        return;
    end

    tbPrLogic = Lib:NewClass(tbPreMapLogic);
    self.tbAllPreMapLogic[nMapId] = tbPrLogic;
    tbPrLogic:OnCreate(nMapId, nTargetId);

    local tbMapInfo = self:GetServerPreMapInfo(nTargetId);
    tbMapInfo.nMapId = nMapId;
    tbMapInfo.bApplyMap = false;
    CallZoneClientScript(tbFightInfo.nConnectIdx, "BiWuZhaoQin:OnSynData", nTargetId, tbFightInfo)
    Log("BiWuZhaoQin fnCreatePreMapLogic PrLogic", nMapId, nTargetId, tbFightInfo.bNpcType and "true" or "false");
end

function BiWuZhaoQin:ClosePreMapLogic(nMapId)
    local tbPrLogic = self:GetPreMapLogic(nMapId);
    if not tbPrLogic then
        return;
    end

    if tbPrLogic.OnClose then
        tbPrLogic:OnClose();
    end

    local nTargetId = tbPrLogic.nTargetId

    BiWuZhaoQin:ClearServerPreMapInfo(nTargetId)

    self.tbAllPreMapLogic[nMapId] = nil;
    Log("BiWuZhaoQin ClosePreMapLogic",nMapId,nTargetId or -1);
end

-- >>>>>>>>>>>>>>>>>>>> 准备场逻辑
function tbPreMapLogic:OnCreate(nMapId, nTargetId)
    local tbFightInfo = BiWuZhaoQin:GetFightInfo(nTargetId)
    if not tbFightInfo then
        Log("BiWuZhaoQin fnOnCreate no tbFightInfo", nMapId, nTargetId);
        return
    end

    tbFightInfo.nPreMapId = nMapId
    self.nConnectIdx = tbFightInfo.nConnectIdx
    self.nMapId = nMapId
    self.nTargetId = nTargetId
    self.nType = tbFightInfo.nType
    self.nFightCount = 0
    self.nKinId = tbFightInfo.nKinId
    self.szTimeFrame = tbFightInfo.szTimeFrame
    self.bNpcType = tbFightInfo.bNpcType;

    self.tbFightMapLogic = {}                       -- 淘汰赛战斗逻辑
    self.tbArenaLogic = {}                          -- 8强赛战斗逻辑
    self.tbJoinPlayerInfo = {}                      -- 所有参加玩家的信息（缓存玩家信息是因为8强决出的时候玩家不一定在线，无法再ZoneServer获取信息）
    self.tbWilling = {}                             -- 进入准备场的玩家参加比赛的意愿
    self.tbWaitWatch = {}                           -- 等待观战列表

    BiWuZhaoQin:OnStartZhaoQin(self)
    self:CloseAllTimer()
    self.nFirstFightTimer = Timer:Register(Env.GAME_FPS * BiWuZhaoQin.nFirstFightWaitTime, self.TryFirstFight, self)
    self:ForeachMapPlayer(self.UpdatePlayerUi)
    Log("BiWuZhaoQin PreMapLogic fnOnCreate " , self:GetLog());
end

function tbPreMapLogic:GetLog()
    return self.nTargetId, self.nConnectIdx, self.nMapId, self.nType, self.nFightCount, self.nKinId, self.szTimeFrame
end

function tbPreMapLogic:TryFirstFight()
    self.nFirstFightTimer = nil
    local tbFightInfo = BiWuZhaoQin:GetFightInfo(self.nTargetId)
    if not tbFightInfo then
        Log("BiWuZhaoQin fnTryFirstFight no tbFightInfo ", self:GetLog());
        return
    end
    tbFightInfo.nProcess = BiWuZhaoQin.Process_Fight
    BiWuZhaoQin:Process(self.nMapId, true)
    Log("BiWuZhaoQin fnTryFirstFight ", self:GetLog());
end

function tbPreMapLogic:TryFight(tbFightInfo,tbAllPlayer)

    self:CloseAutoMatchTimer()
    -- 每次匹配完开启下一次自动匹配
    self.nAutoMatchTimer = Timer:Register(Env.GAME_FPS * BiWuZhaoQin.nAutoMatchTime, BiWuZhaoQin.OnNextMatch,BiWuZhaoQin, self.nMapId,true)
    self:ForeachMapPlayer(self.UpdatePlayerUi)

    -- 加一轮统计玩家
    tbFightInfo.nRound = tbFightInfo.nRound + 1
    tbFightInfo.tbPlayer[tbFightInfo.nRound] = {}

    self:MakeFight(tbAllPlayer)
end

function tbPreMapLogic:MakeFight(tbAllPlayer)
    -- 先打乱
    Lib:SmashTable(tbAllPlayer)
    local nCount = #tbAllPlayer
    local fbSelect = Lib:GetRandomSelect(nCount)
    if nCount % 2 > 0 then
        self:OnEnterNextRoundDirect(tbAllPlayer[fbSelect()])
        nCount = nCount - 1
    end
    local nFightCount = math.ceil(nCount / 2)
    self.nFightCount = nFightCount
    for i = 1,nFightCount do
        local tbFightPlayer = {}
        for j=1,2 do
           tbFightPlayer[tbAllPlayer[fbSelect()]] = self.nTargetId
        end
        self:AssistMap(tbFightPlayer)
    end
    Log("BiWuZhaoQin fnMakeFight ok",self.nFightCount,self:GetLog())
end

function tbPreMapLogic:AssistMap(tbFightPlayer)
    local nFightMapId = CreateMap(BiWuZhaoQin.nTaoTaiMapTID)
    BiWuZhaoQin.tbAllMapFight2Pre[nFightMapId] = {nPreMapId = self.nMapId,tbFightPlayer = tbFightPlayer}
end

function tbPreMapLogic:UpdatePlayer(bLimit)
    local tbFightInfo = BiWuZhaoQin:GetFightInfo(self.nTargetId)
    if not tbFightInfo then
        Log("BiWuZhaoQin no tbFightInfo", self:GetLog());
        return
    end
    local nNowTime = GetTime()
    local tbPlayer = {}
    -- 顺序表玩家，方便操作
    local tbFormatPlayer = {}
    local tbTempPlayer = tbFightInfo.tbPlayer[tbFightInfo.nRound]
    for dwID,_ in pairs(tbTempPlayer) do
        local pPlayer = KPlayer.GetPlayerObjById(dwID)
        if not tbPlayer[dwID] then
            -- bLimit 为true时，会将不在线和不在准备场地图的玩家筛掉
            if not bLimit or (pPlayer and pPlayer.nMapId == self.nMapId) then
                tbPlayer[dwID] = nNowTime
                table.insert(tbFormatPlayer,dwID)
            else
                Log("BiWuZhaoQin fnUpdatePlayer lost qualification ", dwID, tbFightInfo.nRound, pPlayer and pPlayer.nMapTemplateId or -1, self:GetLog())
            end
        else
            Log("BiWuZhaoQin fnUpdatePlayer repeat", dwID, tbPlayer[dwID], tbFightInfo.nRound, pPlayer and pPlayer.nMapTemplateId or -1, self:GetLog())
        end
    end
    -- 更新筛选后玩家
    tbFightInfo.tbPlayer[tbFightInfo.nRound] = tbPlayer

    return tbFormatPlayer
end

function tbPreMapLogic:UpdatePlayerUi(pPlayer,nState)
    local nRestTime = 0;
    local nType = 0
    local nFightState = 0
    if self.nFirstFightTimer then
        nRestTime = math.floor(Timer:GetRestTime(self.nFirstFightTimer) / Env.GAME_FPS);
        nType = BiWuZhaoQin.nFirstMatch
    elseif self.nTaoTaiFightTimer then
        nRestTime = math.floor(Timer:GetRestTime(self.nTaoTaiFightTimer) / Env.GAME_FPS);
        nType = BiWuZhaoQin.nFightMatch
    elseif self.nAutoMatchTimer then
        nRestTime = math.floor(Timer:GetRestTime(self.nAutoMatchTimer) / Env.GAME_FPS);
        nType = BiWuZhaoQin.nAutoMatch
    elseif self.nFinalFightTimer then
        nRestTime = math.floor(Timer:GetRestTime(self.nFinalFightTimer) / Env.GAME_FPS);
        nType = BiWuZhaoQin.nFinalMatch
    elseif self.nAutoMatchFinalTimer then
        nRestTime = math.floor(Timer:GetRestTime(self.nAutoMatchFinalTimer) / Env.GAME_FPS);
        nType = BiWuZhaoQin.nAutoMatchFinal
    end
    local tbFightInfo = BiWuZhaoQin:GetFightInfo(self.nTargetId) or {}
    nFightState = nState or self:GetFightState(pPlayer,tbFightInfo)
    pPlayer.CallClientScript("BiWuZhaoQin:SynPreMapState", nRestTime, nType, tbFightInfo.nProcess, nFightState)
end

function tbPreMapLogic:GetFightState(pPlayer,tbFightInfo)
    local nProcess = tbFightInfo.nProcess
    local nFightState = BiWuZhaoQin.tbFightState.NoJoin
    if nProcess then
        local bNoJoin = self:GetPlayerWilling(pPlayer.dwID)
        if nProcess == BiWuZhaoQin.Process_Pre then
            -- 参战准备阶段
            if not bNoJoin then
                nFightState = BiWuZhaoQin.tbFightState.StandBy
            end
        else
            if tbFightInfo.tbFailPlayer and tbFightInfo.tbFailPlayer[pPlayer.dwID] then
                nFightState = BiWuZhaoQin.tbFightState.Out
            else
                 -- 是否参加过
                local bHadJoin = tbFightInfo.tbPlayer and tbFightInfo.tbPlayer[1] and tbFightInfo.tbPlayer[1][pPlayer.dwID]
                -- 是否进入了下一轮
                local bNextRound = tbFightInfo.tbPlayer and tbFightInfo.tbPlayer[tbFightInfo.nRound] and tbFightInfo.tbPlayer[tbFightInfo.nRound][pPlayer.dwID]

                if bHadJoin then
                    if bNextRound then
                        nFightState = BiWuZhaoQin.tbFightState.Next
                    else
                        nFightState = BiWuZhaoQin.tbFightState.Out
                    end
                end
                if nProcess == BiWuZhaoQin.Process_Final then
                    -- 是否是8强玩家
                    local bFinalPlayer = tbFightInfo.tbFinalPlayer and tbFightInfo.tbFinalPlayer[pPlayer.dwID]
                    -- 第一次进入8强
                    local bFirstFinal = tbFightInfo.nFinalRound and tbFightInfo.nFinalRound > 0 and tbFightInfo.nFinalRound == (tbFightInfo.nRound - 1)
                    if bFinalPlayer then
                        -- 是否晋级下一轮8强
                        if bFirstFinal or tbFightInfo.tbPlayer and tbFightInfo.tbPlayer[tbFightInfo.nRound - 1] and tbFightInfo.tbPlayer[tbFightInfo.nRound - 1][pPlayer.dwID] then
                            nFightState = BiWuZhaoQin.tbFightState.Next
                        else
                            nFightState = BiWuZhaoQin.tbFightState.Out
                        end
                    end
                end
            end
        end
    end
    return nFightState
end

function tbPreMapLogic:CreateFightLogic(nFightMapId)
    local tbFightLogic = Lib:NewClass(BiWuZhaoQin.BWZQBattle)
    tbFightLogic.nMapId = nFightMapId
    tbFightLogic.nPreMapId = self.nMapId
    tbFightLogic.nTargetId = self.nTargetId
    tbFightLogic.nConnectIdx = self.nConnectIdx
    tbFightLogic.nType = self.nType
    tbFightLogic.nFightType = BiWuZhaoQin.FIGHT_TYPE_MAP
    tbFightLogic.szTimeFrame = self.szTimeFrame
    return tbFightLogic
end

function tbPreMapLogic:GetFightLogic(nFightMapId)
    return self.tbFightMapLogic[nFightMapId]
end

function tbPreMapLogic:OnEnterNextRoundDirect(dwID)
    local tbFightInfo = BiWuZhaoQin:GetFightInfo(self.nTargetId)
    if not tbFightInfo then
        Log("BiWuZhaoQin fnOnEnterNextRoundDirect no tbFightInfo", dwID,self:GetLog());
        return
    end
    tbFightInfo.tbPlayer[tbFightInfo.nRound][dwID] = GetTime()
    local pPlayer = KPlayer.GetPlayerObjById(dwID)
    if pPlayer then
        local szMsg = "您輪空了，恭喜勝利晉級！"
        pPlayer.Msg(szMsg)
        Dialog:SendBlackBoardMsg(pPlayer, szMsg)
        self:UpdatePlayerUi(pPlayer,BiWuZhaoQin.tbFightState.Next)
    end
     Log("BiWuZhaoQin fnOnEnterNextRoundDirect ", dwID,self:GetLog());
end

function tbPreMapLogic:TrySynFinalData(pPlayer)
    local tbFightInfo = BiWuZhaoQin:GetFightInfo(self.nTargetId)
    if not tbFightInfo then
        Log("BiWuZhaoQin fnTrySynFinalData no tbFightInfo", dwID,self:GetLog());
        return
    end
    if tbFightInfo.nProcess == BiWuZhaoQin.Process_Final then
        local tbData = {}
        tbData.tbPlayer = {}
        tbData.tbFinalPlayer = {}
        tbData.nFinalRound = tbFightInfo.nFinalRound
        local tbFinalPlayer = tbFightInfo.tbFinalPlayer or {}
        for dwID,nSeq in pairs(tbFinalPlayer) do
            tbData.tbFinalPlayer[dwID] = self.tbJoinPlayerInfo[dwID] or {}
            tbData.tbFinalPlayer[dwID].nSeq = nSeq
        end

        for i = tbFightInfo.nFinalRound,tbFightInfo.nRound - 1 do
            if next(tbFightInfo.tbPlayer[i]) then
                tbData.tbPlayer[i] = tbFightInfo.tbPlayer[i]
            end
        end
        pPlayer.CallClientScript("BiWuZhaoQin:OnSynFinalData",tbData)
    end
end

function tbPreMapLogic:ForeachMapPlayer(fnFunc,...)
    local tbPlayer = KPlayer.GetMapPlayer(self.nMapId)
    for _,pPlayer in pairs(tbPlayer) do
        Lib:CallBack({fnFunc, self, pPlayer, ...});
    end
end

-- 进入8强
function tbPreMapLogic:OnEnterFinal(dwID)
    local pPlayer = KPlayer.GetPlayerObjById(dwID)
    if pPlayer then
         pPlayer.CenterMsg("恭喜晉級八強",true)
    end
    Log("BiWuZhaoQin fnOnEnterFinal ",dwID,self:GetLog())
end

function tbPreMapLogic:GetArenaLogic(nArenaId)
    return self.tbArenaLogic[nArenaId]
end

function tbPreMapLogic:OnStartFinal(tbFightInfo,tbAllPlayer)
     for nArenaId = 1,BiWuZhaoQin.nArenaNum do
        local tbFightLogic = self:CreateFightLogic(nArenaId)
         tbFightLogic.nMapId = nArenaId
         tbFightLogic.nPreMapId = self.nMapId
         tbFightLogic.nTargetId = self.nTargetId
         tbFightLogic.nConnectIdx = self.nConnectIdx
         tbFightLogic.nType = self.nType
         tbFightLogic.nFightType = BiWuZhaoQin.FIGHT_TYPE_ARENA
         if tbFightLogic.OnCreate then
            tbFightLogic:OnCreate()
        end
        self.tbArenaLogic[nArenaId] = tbFightLogic
        Log("BiWuZhaoQin init arena ok ",nArenaId,self:GetLog())
    end

    -- 确定8强，位置，擂台（根据nSeq从小到大，擂台号从小到达依次分配）
   for nSeq,dwID in pairs(tbAllPlayer) do
        tbFightInfo.tbFinalPlayer[dwID] = nSeq
        self:OnEnterFinal(dwID)
    end

    -- 确定八强赛是第几轮开始，主要客户端显示用到
    tbFightInfo.nFinalRound = tbFightInfo.nRound

    CallZoneClientScript(self.nConnectIdx,"BiWuZhaoQin:OnStartFinalS",self.nTargetId)
    Log("BiWuZhaoQin fnOnStartFinal ",self:GetLog())
end

function tbPreMapLogic:OnFinalFight(tbAllPlayer)
    Lib:SmashTable(tbAllPlayer)
    local tbFightInfo = BiWuZhaoQin:GetFightInfo(self.nTargetId)
    if not tbFightInfo then
        Log("BiWuZhaoQin fnOnFinalFight no tbFightInfo", self:GetLog());
        return
    end

    local bFirst,bStep

    self:CloseAllTimer()

    if tbFightInfo.nProcess == BiWuZhaoQin.Process_Fight then
        self:OnStartFinal(tbFightInfo,tbAllPlayer)
        bFirst = true
    end

    tbFightInfo.nProcess = BiWuZhaoQin.Process_Final

     -- 加一轮统计下一轮玩家
    tbFightInfo.nRound = tbFightInfo.nRound + 1
    tbFightInfo.tbPlayer[tbFightInfo.nRound] = {}

    self:ForeachMapPlayer(self.TrySynFinalData)

    -- 全都失去资格
    if #tbAllPlayer < 1 then
        BiWuZhaoQin:OnEndZhaoQin(self, tbFightInfo)
        self:ForeachMapPlayer(self.UpdatePlayerUi)
        return
    end

    if #tbAllPlayer == 1 then
        BiWuZhaoQin:OnCompleteZhaoQin(tbFightInfo, self,tbAllPlayer[1])
        self:ForeachMapPlayer(self.UpdatePlayerUi)
        return
    end

    local tbPlayer = self:FormatFinalPlayer(tbFightInfo.tbFinalPlayer,tbAllPlayer)
    local nCount = #tbPlayer
    -- 首进8强首位直接晋级，其他末位直接晋级（为解决统一玩家会出现两次轮空的情况）
    local nWinIndex = bFirst and 1 or nCount
     if nCount % 2 > 0 then
        -- 多余一位直接晋级
        self:OnEnterNextRoundDirect(tbPlayer[nWinIndex].dwID)
        -- 是否将擂台推进一号进行分配（即从2号擂台开始分配）
        bStep = bFirst
    end

    self.nFinalFightTimer = Timer:Register(Env.GAME_FPS * BiWuZhaoQin.nMatchWaitTime, self.TryFinalFight, self,bStep)
    self:ForeachMapPlayer(self.UpdatePlayerUi)
    Log("BiWuZhaoQin fnOnFinalFight ", self:GetLog())
end

function tbPreMapLogic:FormatFinalPlayer(tbFinalPlayer,tbAllPlayer)
    local tbTempPlayer = {}
    for _,dwID in pairs(tbAllPlayer) do
        local nSeq = tbFinalPlayer[dwID]
        if nSeq then
            table.insert(tbTempPlayer,{dwID = dwID,nSeq = nSeq})
        else
            Log("BiWuZhaoQin fnFormatFinalPlayer no seq ",dwID,self:GetLog())
        end
    end

    local function fnSort(a,b)
        return a.nSeq < b.nSeq
    end

    table.sort(tbTempPlayer,fnSort)

    return tbTempPlayer
end

function tbPreMapLogic:TryFinalFight(bStep)
    self.nFinalFightTimer = nil
    local tbFightInfo = BiWuZhaoQin:GetFightInfo(self.nTargetId)
    if not tbFightInfo then
        Log("BiWuZhaoQin fnTryFinalFight no tbFightInfo", self.nMapId, self.nTargetId, self.nType);
        return
    end
    -- 每次匹配完开启下一次自动匹配
     self.nAutoMatchFinalTimer = Timer:Register(Env.GAME_FPS * BiWuZhaoQin.nAutoMatchTime, BiWuZhaoQin.OnNextMatch,BiWuZhaoQin, self.nMapId,true)
     self:ForeachMapPlayer(self.UpdatePlayerUi)

    -- 当前的8强对战玩家
    local tbPlayer = tbFightInfo.tbPlayer[tbFightInfo.nRound - 1]
    local tbAllPlayer = {}
    for dwID,_ in pairs(tbPlayer) do
        table.insert(tbAllPlayer,dwID)
    end

    -- {{dwID = dwID,nSeq = 2},{dwID = dwID,nSeq = 5}}
    local tbFormatPlayer = self:FormatFinalPlayer(tbFightInfo.tbFinalPlayer,tbAllPlayer)
    local nCount = #tbFormatPlayer
    if nCount % 2 > 0 then
        nCount = nCount - 1
    end
    local tbFightPlayer = {}
    -- 启用几个擂台
    local nFightCount = nCount / 2
    -- 分配到几号擂台为止
    nFightCount = bStep and nFightCount + 1 or nFightCount
    if nFightCount > BiWuZhaoQin.nArenaNum then
        Log("BiWuZhaoQin fnTryFinalFight ERR Arena Num !!!", bStep and 1 or 0, nFightCount, self:GetLog())
        nFightCount = BiWuZhaoQin.nArenaNum
    end
    -- 从几号索引开始分配玩家
    local i = bStep and 1 or 0
    -- 从几号擂台开始分配
    local nStartArenaId = bStep and 2 or 1

    local nNowTime = GetTime()

    for nArenaId = nStartArenaId,nFightCount do
        tbFightPlayer[nArenaId] = tbFightPlayer[nArenaId] or {}
        tbFightPlayer[nArenaId].tbPlayer = tbFightPlayer[nArenaId].tbPlayer or {}
        -- 几个人失去资格
        local nLost = 0
        for nPos = 1,2 do
           i = i + 1
           local tbEnterPos = BiWuZhaoQin.tbPos[nArenaId].tbEnterPos[nPos]
           local tbPlayerInfo = tbFormatPlayer[i]
           if tbPlayerInfo then
                tbPlayerInfo.tbEnterPos = tbEnterPos
                local pPlayer = KPlayer.GetPlayerObjById(tbPlayerInfo.dwID)
                -- 失去资格
                if not pPlayer or pPlayer.nMapId ~= self.nMapId then
                   nLost = nLost + 1
                   tbPlayerInfo.bLost = true
                   tbFightInfo.tbFinalLostPlayer[tbPlayerInfo.dwID] = nNowTime             -- 8强赛失去资格的玩家记录
                   tbFightInfo.tbFailPlayer[tbPlayerInfo.dwID] = nNowTime
                   Log("BiWuZhaoQin fnTryFinalFight lost qualification ", tbPlayerInfo.dwID, tbFightInfo.nRound, self:GetLog())
                end
                table.insert(tbFightPlayer[nArenaId].tbPlayer,tbPlayerInfo)
            else
                Log("BiWuZhaoQin fnTryFinalFight no tbPlayerInfo !!!", i, nArenaId, self:GetLog())
            end
        end
        tbFightPlayer[nArenaId].nLost = nLost
    end

    -- 几场开打
    self.nFightCount = 0

    for nArenaId,tbArenaInfo in pairs(tbFightPlayer) do
        local tbPosInfo = BiWuZhaoQin.tbPos[nArenaId] or {}
        if tbArenaInfo.nLost < 2 then
            -- 一人失去资格
            if tbArenaInfo.nLost == 1 then
                for _,tbInfo in ipairs(tbArenaInfo.tbPlayer) do
                    if not tbInfo.bLost then
                        -- 有资格的直接晋级
                        self:OnEnterNextRoundDirect(tbInfo.dwID)
                    end
                end
            else
                -- 没人失去资格
                local tbTeamNpcID = {}
                local tbFightLogic = self:GetArenaLogic(nArenaId)
                if tbFightLogic then
                    if #tbArenaInfo.tbPlayer == 2 then
                        self.nFightCount = self.nFightCount + 1
                        tbFightLogic:OnInit()
                        for nCamp,tbInfo in ipairs(tbArenaInfo.tbPlayer) do
                            -- 上面的判断已经确保玩家在线
                            local pPlayer = KPlayer.GetPlayerObjById(tbInfo.dwID)
                            local tbEnterPos = tbPosInfo.tbEnterPos
                            pPlayer.SetPosition(unpack(tbEnterPos[nCamp]))
                            tbFightLogic:OnEnter(pPlayer)
                            tbTeamNpcID[nCamp] = tbTeamNpcID[nCamp] or {}
                            local pNpc = pPlayer.GetNpc();
                            if pNpc and not pNpc.GetSkillState(BiWuZhaoQin.nDeathSkillState) then
                                 tbTeamNpcID[nCamp][pNpc.nId] = true
                            end
                        end
                    else
                        Log("BiWuZhaoQin fnTryFinalFight ERR Player Num", nArenaId, self:GetLog())
                    end
                else
                    Log("BiWuZhaoQin fnTryFinalFight no tbFightLogic",nArenaId,self:GetLog())
                end
               self:SynWatch(nArenaId,tbTeamNpcID)
            end
        else
            local tbPlayer = tbArenaInfo.tbPlayer or {}
            local tbPlayerInfo1 = tbPlayer[1] or {}
            local tbPlayerInfo2 = tbPlayer[2] or {}
            -- 两人都失去资格
            Log("BiWuZhaoQin fnTryFinalFight lost both ",nArenaId,tbPlayerInfo1.dwID or -1,tbPlayerInfo2.dwID or -1,self:GetLog())
        end
    end
    -- 没人开打，检查下一步，这时自动匹配的定时器还在跑
    if self.nFightCount == 0 then
        BiWuZhaoQin:CheckNextStep(self)
    end
    Log("BiWuZhaoQin fnTryFinalFight ok ",self.nFightCount,self:GetLog())
end

function tbPreMapLogic:RemoveFromWaitList(dwID)
    for nArenaId = 1,BiWuZhaoQin.nArenaNum do
        local tbWaitList = self:GetWaitList(nArenaId)
         tbWaitList[dwID] = nil
    end
end

function tbPreMapLogic:GetWaitList(nArenaId)
    self.tbWaitWatch[nArenaId] = self.tbWaitWatch[nArenaId] or {}
    return self.tbWaitWatch[nArenaId]
end

function tbPreMapLogic:OnLeaveArena(pPlayer)
    self:UpdatePlayerUi(pPlayer)
end

-- 为所有等待观战的人同步观战信息
function tbPreMapLogic:SynWatch(nArenaId,tbTeamNpcID)
    local tbWaitList = self:GetWaitList(nArenaId)
    for dwID,_ in pairs(tbWaitList) do
        local pPlayer = KPlayer.GetPlayerObjById(dwID)
        if pPlayer and pPlayer.nMapId == self.nMapId then
            CommonWatch:WatchNpc(pPlayer, tbTeamNpcID)
        else
            tbWaitList[dwID] = nil
        end
    end
end

-- 比赛结束，结束所有正在观战的人
function tbPreMapLogic:EndArenaWatch(nArenaId)
     -- 8强赛才会创建
    local tbArenaLogic = self:GetArenaLogic(nArenaId)
    if not tbArenaLogic then
        return
    end
    local tbWaitList = self:GetWaitList(nArenaId)
    for dwID,_ in pairs(tbWaitList) do
        local pPlayer = KPlayer.GetPlayerObjById(dwID)
        if pPlayer and pPlayer.nMapId == self.nMapId then
            CommonWatch:DoEndWatch(pPlayer)
        else
            tbWaitList[dwID] = nil
        end
    end
end

function tbPreMapLogic:OnClose()
     Log("BiWuZhaoQin PreMapLogic OnClose",self.nMapId, self.nTargetId);
end

function tbPreMapLogic:CacheJoinPlayerInfo(pPlayer)
    local pKinData = Kin:GetKinById(pPlayer.dwKinId or 0) or {};
    self.tbJoinPlayerInfo[pPlayer.dwID] = {
        szName = pPlayer.szName,
        nPlayerId = pPlayer.dwID,
        nLevel = pPlayer.nLevel,
        nFightPower = FightPower:GetFightPower(pPlayer.dwID),
        nFaction = pPlayer.nFaction,
        nHonorLevel = pPlayer.nHonorLevel,
        nPortrait = pPlayer.nPortrait,
        szKinName = pKinData.szName,
    }
end

function tbPreMapLogic:CachePlayerWilling(dwID,bNoJoin)
    self.tbWilling[dwID] =  bNoJoin
end

function tbPreMapLogic:GetPlayerWilling(dwID)
    return self.tbWilling[dwID]
end

function tbPreMapLogic:ClearPlayerWilling(dwID)
    self.tbWilling[dwID] = nil
end

function tbPreMapLogic:OnEnd()
    self:CloseKickOutTimer()
    self.nKickOutTimer = Timer:Register(Env.GAME_FPS * BiWuZhaoQin.nDelayKictoutTime, self.KickOutMapPlayer, self)
end

function tbPreMapLogic:KickOutMapPlayer()
    self.nKickOutTimer = nil
    local fnKick = function (self,pPlayer)
        pPlayer.ZoneLogout();
    end
    self:ForeachMapPlayer(fnKick)
end

function tbPreMapLogic:CloseKickOutTimer()
     if self.nKickOutTimer then
        Timer:Close(self.nKickOutTimer)
        self.nKickOutTimer = nil
    end
end

function tbPreMapLogic:OnEnter(pPlayer)
    local tbFightInfo = BiWuZhaoQin:GetFightInfo(self.nTargetId)
    if not tbFightInfo then
        Log("BiWuZhaoQin fnOnEnter no tbFightInfo", self:GetLog());
        return
    end

    pPlayer.SetPosition(unpack(BiWuZhaoQin.tbPreEnterPos[MathRandom(#BiWuZhaoQin.tbPreEnterPos)]));

    local bNoJoin = self:GetPlayerWilling(pPlayer.dwID)

    -- 招亲的人不能参加
    if pPlayer.dwID ~= self.nTargetId and tbFightInfo.nJoin < BiWuZhaoQin.nMaxJoin and tbFightInfo.nProcess == BiWuZhaoQin.Process_Pre and not bNoJoin then
        -- 全服随意参加，家族得家族ID匹配上才能参加
        if tbFightInfo.nKinId == 0 or tbFightInfo.nKinId == pPlayer.dwKinId then
            tbFightInfo.tbPlayer[tbFightInfo.nRound][pPlayer.dwID] = GetTime()
            tbFightInfo.nJoin = tbFightInfo.nJoin + 1
            self:CacheJoinPlayerInfo(pPlayer)
            CallZoneClientScript(tbFightInfo.nConnectIdx,"BiWuZhaoQin:OnSynJoinS",tbFightInfo.nTargetId,tbFightInfo.nJoin)
            Log("BiWuZhaoQin sign up ",pPlayer.dwID,pPlayer.szName,tbFightInfo.nJoin,self:GetLog())
        else
            Log("BiWuZhaoQin try sign up no match???",pPlayer.dwID,pPlayer.szName,self:GetLog())
        end
    end
    self:UpdatePlayerUi(pPlayer)
    self:TrySynFinalData(pPlayer)
end

function tbPreMapLogic:OnLeave(pPlayer)

    self:RemoveFromWaitList(pPlayer.dwID)

    local tbFightInfo = BiWuZhaoQin:GetFightInfo(self.nTargetId)
    if not tbFightInfo then
        return
    end
    self:ClearPlayerWilling(pPlayer.dwID)
     if tbFightInfo.nProcess == BiWuZhaoQin.Process_Pre and tbFightInfo.tbPlayer[tbFightInfo.nRound][pPlayer.dwID] then
        tbFightInfo.tbPlayer[tbFightInfo.nRound][pPlayer.dwID] = nil
        tbFightInfo.nJoin = tbFightInfo.nJoin - 1
        CallZoneClientScript(tbFightInfo.nConnectIdx,"BiWuZhaoQin:OnSynJoinS",tbFightInfo.nTargetId,tbFightInfo.nJoin)
        Log("BiWuZhaoQin give up ",pPlayer.dwID,pPlayer.szName,tbFightInfo.nJoin,self:GetLog())
    end
    if pPlayer.nBWZQFightMapId then
        local tbArenaLogic = self:GetArenaLogic(pPlayer.nBWZQFightMapId)
        if tbArenaLogic then
            tbArenaLogic:EndFightForce(pPlayer)
        end
    end
end

function tbPreMapLogic:OnLogin(pPlayer)
    if pPlayer.nBWZQFightMapId then
        local tbArenaLogic = self:GetArenaLogic(pPlayer.nBWZQFightMapId)
        if tbArenaLogic then
            -- 更新战斗ui
            tbArenaLogic:UpdatePlayerUi(pPlayer)
        end
    else
        self:UpdatePlayerUi(pPlayer)
    end
    Log("BiWuZhaoQin PreMapLogic OnLogin",self.nMapId, self.nTargetId);
end

function tbPreMapLogic:CloseAllTimer()
    self:CloseAutoMatchTimer()
    self:CloseFirstFightTimer()
    self:CloseTaoTaiFightTimer()
    self:CloseFinalFightTimer()
    self:CloseAutoMatchFinalTimer()
end

function tbPreMapLogic:CloseFirstFightTimer()
    if self.nFirstFightTimer then
        Timer:Close(self.nFirstFightTimer)
        self.nFirstFightTimer = nil
    end
end

function tbPreMapLogic:CloseTaoTaiFightTimer()
    if self.nTaoTaiFightTimer then
        Timer:Close(self.nTaoTaiFightTimer)
        self.nTaoTaiFightTimer = nil
    end
end

function tbPreMapLogic:CloseFinalFightTimer()
    if self.nFinalFightTimer then
        Timer:Close(self.nFinalFightTimer)
        self.nFinalFightTimer = nil
    end
end

function tbPreMapLogic:CloseAutoMatchTimer()
    if self.nAutoMatchTimer then
        Timer:Close(self.nAutoMatchTimer)
        self.nAutoMatchTimer = nil
    end
end

function tbPreMapLogic:CloseAutoMatchFinalTimer()
    if self.nAutoMatchFinalTimer then
        Timer:Close(self.nAutoMatchFinalTimer)
        self.nAutoMatchFinalTimer = nil
    end
end

function BiWuZhaoQin:CreateFightMapLogic(nMapId)
    local tbFightData = BiWuZhaoQin.tbAllMapFight2Pre[nMapId]
    if not tbFightData then
         Log("BiWuZhaoQin fnCreateFightMapLogic no tbFightData", nMapId);
        return
    end
    local nPreMapId = tbFightData.nPreMapId
    local tbFightPlayer = tbFightData.tbFightPlayer
    if not nPreMapId or not tbFightPlayer then
        Log("BiWuZhaoQin fnCreateFightMapLogic no nPreMapId", nMapId,nPreMapId or -1);
        return
    end
    local tbPrLogic = BiWuZhaoQin:GetPreMapLogic(nPreMapId);
    if not tbPrLogic then
        Log("BiWuZhaoQin fnCreateFightMapLogic no tbPrLogic",nPreMapId,nMapId)
        return;
    end
    local tbFightLogic = tbPrLogic:CreateFightLogic(nMapId)
    if tbFightLogic.OnCreate then
        tbFightLogic:OnCreate()
    end

    tbPrLogic.tbFightMapLogic[nMapId] = tbFightLogic

    for dwID,_ in pairs(tbFightPlayer) do
       local pPlayer = KPlayer.GetPlayerObjById(dwID)
       if pPlayer then
            pPlayer.SwitchMap(nMapId,0,0)
       else
            Log("BiWuZhaoQin fnCreateFightMapLogic Enter Fight map no Player",dwID,tbPrLogic.nTargetId)
       end
    end
end

function BiWuZhaoQin:CloseFightMapLogic(nMapId)
    local tbFightData = BiWuZhaoQin.tbAllMapFight2Pre[nMapId]
    if not tbFightData then
        Log("BiWuZhaoQin fnCloseFightMapLogic no tbFightData", nMapId);
        return
    end
    local nPreMapId = tbFightData.nPreMapId
    if not nPreMapId then
        Log("BiWuZhaoQin fnCloseFightMapLogic no nPreMapId", nMapId);
        return
    end
    local tbPrLogic = BiWuZhaoQin:GetPreMapLogic(nPreMapId);
    if not tbPrLogic then
        Log("BiWuZhaoQin fnCloseFightMapLogic no tbPrLogic",nPreMapId,nMapId)
        return;
    end

    local tbFightLogic = tbPrLogic:GetFightLogic(nMapId)
    if not tbFightLogic then
         Log("BiWuZhaoQin fnCloseFightMapLogic no tbFightLogic",tbPrLogic.nTargetId,nPreMapId,nMapId)
         return
    end

    if tbFightLogic.OnClose then
        tbFightLogic:OnClose()
    end

    tbPrLogic.tbFightMapLogic[nMapId] = nil
    BiWuZhaoQin.tbAllMapFight2Pre[nMapId] = nil
    Log("BiWuZhaoQin fnCloseFightMapLogic ",tbFightLogic.nTargetId,nMapId,nPreMapId)
end

-- >>>>>>>>>>>>>>>>>>>> 淘汰场
local tbFightMap = Map:GetClass(BiWuZhaoQin.nTaoTaiMapTID);

function tbFightMap:OnCreate(nMapId)
    BiWuZhaoQin:CreateFightMapLogic(nMapId)
    Log("BiWuZhaoQin FightMap OnCreate", nMapId);
end

function tbFightMap:OnDestroy(nMapId)
    BiWuZhaoQin:CloseFightMapLogic(nMapId)
    Log("BiWuZhaoQin FightMap OnDestroy", nMapId);
end

function tbFightMap:OnEnter(nMapId)

    local tbFightData = BiWuZhaoQin.tbAllMapFight2Pre[nMapId]
    if not tbFightData then
        Log("BiWuZhaoQin tbFightMap OnEnter no tbFightData", nMapId);
        return
    end
    local nPreMapId = tbFightData.nPreMapId
    if not nPreMapId then
        Log("BiWuZhaoQin tbFightMap OnEnter no nPreMapId", nMapId);
        return
    end
    local tbPrLogic = BiWuZhaoQin:GetPreMapLogic(nPreMapId);
    if not tbPrLogic then
        Log("BiWuZhaoQin tbFightMap OnEnter no tbPrLogic",nPreMapId,nMapId)
        return;
    end

    local tbFightLogic = tbPrLogic:GetFightLogic(nMapId)
    if not tbFightLogic then
         Log("BiWuZhaoQin tbFightMap OnEnter no tbFightLogic",tbPrLogic.nTargetId,nPreMapId,nMapId)
         return
    end

    if tbFightLogic.OnEnter then
        tbFightLogic:OnEnter(me)
    end
end

function tbFightMap:OnLeave(nMapId)

    local tbFightData = BiWuZhaoQin.tbAllMapFight2Pre[nMapId]
    if not tbFightData then
        Log("BiWuZhaoQin tbFightMap OnLeave no tbFightData", nMapId);
        return
    end
    local nPreMapId = tbFightData.nPreMapId
    if not nPreMapId then
        Log("BiWuZhaoQin tbFightMap OnLeave no nPreMapId", nMapId);
        return
    end
    local tbPrLogic = BiWuZhaoQin:GetPreMapLogic(nPreMapId);
    if not tbPrLogic then
        Log("BiWuZhaoQin tbFightMap OnLeave no tbPrLogic",nPreMapId,nMapId)
        return;
    end

    local tbFightLogic = tbPrLogic:GetFightLogic(nMapId)
    if not tbFightLogic then
         Log("BiWuZhaoQin tbFightMap OnLeave no tbFightLogic",tbPrLogic.nTargetId,nPreMapId,nMapId)
         return
    end

    -- 正在打的时候离开地图直接认输结算
    if me.nBWZQFightMapId then
        tbFightLogic:EndFightForce(me)
    end

    if tbFightLogic.OnLeave then
        tbFightLogic:OnLeave(me)
    end
end

function tbFightMap:OnLogin(nMapId)
     local tbFightData = BiWuZhaoQin.tbAllMapFight2Pre[nMapId]
    if not tbFightData then
        Log("BiWuZhaoQin tbFightMap fnOnLogin no tbFightData", nMapId);
        return
    end
    local nPreMapId = tbFightData.nPreMapId
    if not nPreMapId then
        Log("BiWuZhaoQin tbFightMap fnOnLogin no nPreMapId", nMapId);
        return
    end
    local tbPrLogic = BiWuZhaoQin:GetPreMapLogic(nPreMapId);
    if not tbPrLogic then
        Log("BiWuZhaoQin tbFightMap fnOnLogin no tbPrLogic",nPreMapId,nMapId)
        return;
    end

    local tbFightLogic = tbPrLogic:GetFightLogic(nMapId)
    if not tbFightLogic then
         Log("BiWuZhaoQin tbFightMap fnOnLogin no tbFightLogic",tbPrLogic.nTargetId,nPreMapId,nMapId)
         return
    end

    if me.nBWZQFightMapId and me.nBWZQFightMapId == nMapId then
        tbFightLogic:UpdatePlayerUi(me)
    end
end

-- >>>>>>>>>>>>>>>>>>>> 准备场
local tbPreMap = Map:GetClass(BiWuZhaoQin.nPreMapTID);

function tbPreMap:OnCreate(nMapId)
    BiWuZhaoQin:CreatePreMapLogic(nMapId)
    Log("BiWuZhaoQin PreMap OnCreate", nMapId);
end

function tbPreMap:OnDestroy(nMapId)
    BiWuZhaoQin:ClosePreMapLogic(nMapId)
    Log("BiWuZhaoQin PreMap OnDestroy", nMapId);
end

function tbPreMap:OnEnter(nMapId)
    me.nInBattleState = 1
    Lib:CallBack({BiWuZhaoQin.UpdateNormalKinName,BiWuZhaoQin,me});
    local tbPrLogic = BiWuZhaoQin:GetPreMapLogic(nMapId);
    if not tbPrLogic then
        return;
    end
    me.CallClientScript("AutoFight:StopFollowTeammate");
    tbPrLogic:OnEnter(me);
end

function tbPreMap:OnLeave(nMapId)
    me.nInBattleState = 0
    local tbPrLogic = BiWuZhaoQin:GetPreMapLogic(nMapId);
    if not tbPrLogic then
        return;
    end

    tbPrLogic:OnLeave(me);
end

function tbPreMap:OnLogin(nMapId)
    local tbPrLogic = BiWuZhaoQin:GetPreMapLogic(nMapId);
    if not tbPrLogic then
        return;
    end

    tbPrLogic:OnLogin(me);
end

function tbPreMap:OnPlayerTrap(nMapId, szClassName)
     local tbPrLogic = BiWuZhaoQin:GetPreMapLogic(nMapId);
    if not tbPrLogic then
        Log("BiWuZhaoQin fnOnPlayerTrap no tbPrLogic",nMapId)
        return;
    end

    local tbTrapInfo = BiWuZhaoQin:GetWatchTrapInfo(szClassName)
    if not tbTrapInfo then
        Log("BiWuZhaoQin no find trap info",szClassName,tbPrLogic:GetLog())
        return
    end

    local nArenaId = tbTrapInfo.nArenaId
    local nTrapType = tbTrapInfo.nType

    tbPrLogic.tbWaitWatch = tbPrLogic.tbWaitWatch or {}

    tbPrLogic.tbWaitWatch[nArenaId] = tbPrLogic.tbWaitWatch[nArenaId] or {}

    if nTrapType == ArenaBattle.TrapType.In then
       tbPrLogic:OnPlayerTrapIn(me,nArenaId)
    elseif nTrapType == ArenaBattle.TrapType.Out then
       tbPrLogic:OnPlayerTrapOut(me,nArenaId)
    end
end

function tbPreMapLogic:OnPlayerTrapIn(pPlayer,nArenaId)
    self.tbWaitWatch[nArenaId][me.dwID] = true
      -- 8强赛才会创建
    local tbArenaLogic = self:GetArenaLogic(nArenaId)
    if not tbArenaLogic then
        return
    end
    if tbArenaLogic.bStart then
        local tbPlayer = tbArenaLogic.tbPlayer or {}
        local tbTeamNpcID = {}
        for dwID,nCamp in pairs(tbPlayer) do
            local pFightPlayer = KPlayer.GetPlayerObjById(dwID)
            if pFightPlayer then
                local pNpc = pFightPlayer.GetNpc();
                if pNpc and not pNpc.GetSkillState(BiWuZhaoQin.nDeathSkillState) then
                    tbTeamNpcID[nCamp] = tbTeamNpcID[nCamp] or {}
                     tbTeamNpcID[nCamp][pNpc.nId] = true
                end
            end
        end
        CommonWatch:WatchNpc(pPlayer, tbTeamNpcID)
    end
end

function tbPreMapLogic:OnPlayerTrapOut(pPlayer,nArenaId)
    self.tbWaitWatch[nArenaId][me.dwID] = nil
      -- 8强赛才会创建
    local tbArenaLogic = self:GetArenaLogic(nArenaId)
    if not tbArenaLogic then
        return
    end
    CommonWatch:DoEndWatch(pPlayer)
end

