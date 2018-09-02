CollectionSystem.OPEN_TIMEFRAME = "OpenLevel59"
CollectionSystem.KILL_NPC = 1
CollectionSystem.GATHER = 2
CollectionSystem.CONDITION = 3
CollectionSystem.RANK_KEY = "CardCollection_"

function CollectionSystem:OnLogin()
    self:CheckCollectionData(me)
    local tbState = self:GetActivityState()
    me.CallClientScript("CollectionSystem:OnSyncActivityState", tbState)
end

function CollectionSystem:CheckCollectionData(pPlayer)
    local tbData = self:GetData()
    for nCollectionId, tbInfo in pairs(self.tbCollection) do
        if nCollectionId == self.RANDOMFUBEN_ID then
            local tbCollectionData = tbData[nCollectionId]
            if tbCollectionData then
                local nItemTemplateId = self:GetCollectionItemId(nCollectionId)
                local _, tbItem = pPlayer.GetItemCountInAllPos(nItemTemplateId)
                for _, pItem in ipairs(tbItem) do
                    if pItem.GetIntValue(-9996) == 0 then
                        pItem.Delete(Env.LogWay_CollectionSystem)
                    end
                end

                self:CheckSession(tbCollectionData, pPlayer)
                local nSaveGroup = self:GetSaveInfo(nCollectionId)
                local nCurSession = pPlayer.GetUserValue(nSaveGroup, self.DATA_SESSION)
                if tbCollectionData.nSession ~= nCurSession then
                    self:ResetPlayerData(pPlayer, nCollectionId, tbCollectionData.nSession)
                else
                    self:UpdateItemData(pPlayer, nCollectionId)
                end
            end
        elseif nCollectionId == self.JINXIUSHANHE then
            self:UpdateItemData(pPlayer, nCollectionId)
        end
    end
end

function CollectionSystem:CheckSession(tbCollectionData, pPlayer)
    if not tbCollectionData.tbCombineInfo then --合服时修改，开启新的活动时清空
        return
    end
    local nSaveGroup        = self:GetSaveInfo(self.RANDOMFUBEN_ID)
    local nServerOldSession = tbCollectionData.tbCombineInfo[pPlayer.nOrgServerId]
    local nPlayerOldSession = pPlayer.GetUserValue(nSaveGroup, self.DATA_SESSION)
    if nServerOldSession and nPlayerOldSession ~= tbCollectionData.nSession and nPlayerOldSession == nServerOldSession then
        pPlayer.SetUserValue(nSaveGroup, self.DATA_SESSION, tbCollectionData.nSession)
        Log("CollectionSystem CheckCollectionData ResetPlayerSession", pPlayer.dwID, pPlayer.nOrgServerId, nServerOldSession, nPlayerOldSession, tbCollectionData.nSession)
    end
end

function CollectionSystem:UpdateItemData(pPlayer, nCollectionId)
    local tbValue = {}
    local tbPosData = {}
    local nSaveGroup = self:GetSaveInfo(nCollectionId)
    for i = 1, self.SAVE_LEN do
        local nFlag = pPlayer.GetUserValue(nSaveGroup, i + self.DATA_SESSION)
        table.insert(tbPosData, nFlag)
        tbValue[i + self.DATA_SESSION] = nFlag
    end
    local nRank = self:GetPlayerRank("CardCollection_" .. nCollectionId, pPlayer.dwID)
    tbValue[self.ITEM_RANK] = nRank or 0
    self:ChangeItemValue(pPlayer, nCollectionId, tbValue)
end

function CollectionSystem:GetPlayerRank(szKey, dwID)
    local pRank = KRank.GetRankBoard(szKey)
    if not pRank then
        return
    end

    for i = 1, 500 do
        local tbInfo = pRank.GetRankInfoByPos(i - 1)
        if not tbInfo or tbInfo.dwUnitID == dwID then
            return i
        end
    end
end

function CollectionSystem:ResetPlayerData(pPlayer, nCollectionId, nSession)
    local nSaveGroup = self:GetSaveInfo(nCollectionId)
    local tbItemData = {}
    for i = 1, self.SAVE_LEN do
        pPlayer.SetUserValue(nSaveGroup, i + self.DATA_SESSION, 0)
        tbItemData[i + self.DATA_SESSION] = 0
    end
    pPlayer.SetUserValue(nSaveGroup, self.DATA_SESSION, nSession)
    tbItemData[self.ITEM_RANK] = 0
    self:ChangeItemValue(pPlayer, nCollectionId, tbItemData)
end

function CollectionSystem:GetActivityState()
    local tbState = {}
    local tbData = self:GetData()
    for nCollectionId, _ in pairs(self.tbCollection) do
        local tbCollectionData = tbData[nCollectionId]
        if tbCollectionData then
            table.insert(tbState, nCollectionId)
        end
    end
    return tbState
end
--todo
function CollectionSystem:CheckNewMonth()
    if GetTimeFrameState(self.OPEN_TIMEFRAME) == 0 then
        return
    end

    if tonumber(os.date("%d", GetTime())) ~= 1 then
        return
    end

    self:BeginNewSession(self.RANDOMFUBEN_ID)
    self:SyncStateToAllPlayer()
    Log("[CollectionSystem BeginNewMonth]")
end
--todo
function CollectionSystem:CheckBeginFirstActivity()
    if GetTimeFrameState(self.OPEN_TIMEFRAME) == 0 then
        return
    end

    if tonumber(os.date("%d", GetTime())) > 20 then
        return
    end

    local tbData = self:GetData()
    local tbCollectionData = tbData[self.RANDOMFUBEN_ID]
    if not tbCollectionData then
        self:BeginNewSession(self.RANDOMFUBEN_ID)
    end
    self:SyncStateToAllPlayer()
    Log("[CollectionSystem BeginFirstActivity]")
end

function CollectionSystem:SyncStateToAllPlayer()
    local tbState = self:GetActivityState() or {}
    if not next(tbState) then
        return
    end

    local tbPlayer = KPlayer.GetAllPlayer()
    for _, pPlayer in pairs(tbPlayer) do
        pPlayer.CallClientScript("CollectionSystem:OnSyncActivityState", tbState)
    end
end

function CollectionSystem:CloseOldSession(nCollectionId)
    local tbData = self:GetData()
    if not tbData[nCollectionId] then
        return
    end

    self:SendRankAward(nCollectionId)
    if CollectionSystem:IsHaveRankBoard(nCollectionId) then
        RankBoard:ClearRank(self.RANK_KEY .. nCollectionId)
    end
    Log("[CollectionSystem CloseOldSession]", tbData[nCollectionId].nSession)
end

function CollectionSystem:BeginNewSession(nCollectionId)
    self:CloseOldSession(nCollectionId)

    local tbData = self:GetData()
    tbData[nCollectionId] = tbData[nCollectionId] or {}
    tbData[nCollectionId].nSession = Lib:GetLocalMonth()
    tbData[nCollectionId].tbPlayerInfo = nil --不再需要这个数据，为了清除旧的活动数据，所以每次清空一下
    tbData[nCollectionId].tbCombineInfo = nil
    self:SaveData()

    local tbPlayer = KPlayer.GetAllPlayer()
    for _, pPlayer in pairs(tbPlayer) do
        self:ResetPlayerData(pPlayer, nCollectionId, tbData[nCollectionId].nSession)
    end

    Log("[CollectionSystem BeginNewSession]", tbData[nCollectionId].nSession)
end

function CollectionSystem:GetData()
    local tbData = ScriptData:GetValue("CollectionSystem")
    return tbData
end

function CollectionSystem:SaveData()
    ScriptData:AddModifyFlag("CollectionSystem")
end

function CollectionSystem:OnRandomFubenKillNpc(pNpc, pKiller)
    if not self:IsInProcess(self.RANDOMFUBEN_ID) then
        return
    end

    if not pNpc or not pKiller then
        return
    end

    local tbDrop = self.tbNpcDrop[pNpc.nTemplateId]
    if not tbDrop then
        return
    end

    local pPlayer = pKiller.GetPlayer()
    if not pPlayer then
        return
    end

    local tbMember = TeamMgr:GetMembers(pPlayer.dwTeamID)
    if not tbMember or #tbMember <= 0 then
        tbMember = { pPlayer.dwID }
    end

    for _, nId in ipairs(tbMember or {}) do
        local pMember = KPlayer.GetPlayerObjById(nId)
        if pMember and pMember.nMapId == pPlayer.nMapId then
            local tbCard = self:RandomAward(tbDrop)
            if tbCard and next(tbCard) then
                for _, nCard in ipairs(tbCard) do
                    self:AddCard(pMember, nCard, self.KILL_NPC)
                end
            end
        end
    end
    Log("[CollectionSystem OnKillNpc] GetCards From Npc:", pNpc.nTemplateId, #tbMember)
end

function CollectionSystem:OnUseShenZhouKa()
    if not self:IsInProcess(self.JINXIUSHANHE) then
        me.CenterMsg("不在活動時間內")
        return
    end

    local _, tbNotCom = self:GetNotCompleteCardList(self.JINXIUSHANHE)
    local nCard
    if not next(tbNotCom) then
        local nPos = MathRandom(#self.tbCollection[self.JINXIUSHANHE].tbCard)
        nCard = self.tbCollection[self.JINXIUSHANHE].tbCard[nPos].nCard
    else
        local nPos = MathRandom(#tbNotCom)
        nCard = tbNotCom[nPos]
    end
    self:AddCard(me, nCard)
end

function CollectionSystem:AddCard(pPlayer, nCardTemplateId, nReason)
    if not pPlayer or not nCardTemplateId then
        Log("[CollectionSystem AddCard] Param Err", nCardTemplateId, nReason)
        return
    end

    local szTimeOut = self:CalcCardValidDate(nCardTemplateId)
    pPlayer.AddItem(nCardTemplateId, 1, szTimeOut, Env.LogWay_CollectionSystem)
    pPlayer.CallClientScript("Ui:OpenAwardUi", {{"Item", nCardTemplateId, 1}}, Env.LogWay_CollectionSystem)
    Log("[CollectionSystem AddCard]", pPlayer.dwID, nCardTemplateId, szTimeOut, nReason)
end

function CollectionSystem:OnUseCard(nCardTemplateId)
    local tbInfo = self.tbCard[nCardTemplateId] or {}
    local nCollectionId = tbInfo.nCollectionId
    if not nCollectionId then
        me.CenterMsg("沒找到對應收集冊")
        return 0
    end

    local bInProcess, szMsg = self:IsInProcess(nCollectionId)
    if not bInProcess then
        me.CenterMsg(szMsg or "活動尚未開啟")
        return 0
    end

    if tbInfo.szTimeFrame ~= "" and GetTimeFrameState(tbInfo.szTimeFrame) == 0 then
        me.CenterMsg("卡位尚未開放")
        return 0
    end

    self:ActivatePosition(nCollectionId, nCardTemplateId)
    return 1
end

function CollectionSystem:IsInProcess(nCollectionId)
    if nCollectionId == self.JINXIUSHANHE then
        local bInProcess = Activity:__IsActInProcessByType("JinXiuShanHe")
        return bInProcess
    end
    local tbData = self:GetData()
    return tbData[nCollectionId]
end

function CollectionSystem:CreateCollection(nCollectionId)
    local nItemTemplateId = self:GetCollectionItemId(nCollectionId)
    local nCount, _ = me.GetItemCountInAllPos(nItemTemplateId)
    if nCount > 0 then
        return
    end

    local szTimeOut = self:CalcBookValidDate(nCollectionId)
    local pItem = me.AddItem(nItemTemplateId, 1, szTimeOut, Env.LogWay_CollectionSystem)
    if not pItem then
        Log(debug.traceback())
        return
    end
    Log("[CollectionSystem CreateCollection]", me.dwID, nCollectionId)
    return true
end

function CollectionSystem:ActivatePosition(nCollectionId, nCardTemplateId)
    local bCreate = self:CreateCollection(nCollectionId)
    local nPos = self:GetCardPosition(nCollectionId, nCardTemplateId)
    if not nPos then
        Log("[CollectionSystem ActivatePosition] Not Match", nCollectionId, nCardTemplateId)
        return
    end

    local nSaveGroup, nSaveKey, nSavePos = self:GetSaveInfo(nCollectionId, nPos)
    local nFlag = me.GetUserValue(nSaveGroup, nSaveKey)
    local bActivated = self:GetDecimalBits(nFlag, nSavePos) > 0
    local tbItemData = {}
    local nRare = 0
    if not bActivated then
        nFlag = self:SetDecimalBits(nFlag, 1, nSavePos)
        me.SetUserValue(nSaveGroup, nSaveKey, nFlag)
        tbItemData[nSaveKey] = nFlag

        local tbPosData = {}
        for i = 1, self.SAVE_LEN do
            local nFlag = me.GetUserValue(nSaveGroup, i + self.DATA_SESSION)
            table.insert(tbPosData, nFlag)
        end
        if nCollectionId == self.RANDOMFUBEN_ID then
            nRare = self:GetAllRare(nCollectionId, tbPosData)
        end
        self:UpdateMyRankData(nCollectionId, nRare)
        self:ChangeItemValue(me, nCollectionId, tbItemData)
    end

    local szCardName, _, _, nQuality       = KItem.GetItemShowInfo(nCardTemplateId, me.nFaction)
    local nItemTemplateId  = self:GetCollectionItemId(nCollectionId)
    local szCollectionName = KItem.GetItemShowInfo(nItemTemplateId, me.nFaction)
    local _, _, _, _, TxtColor = Item:GetQualityColor(nQuality or 1);
    
    local szMsg = string.format("你成功收集了[%s]%s[-]（淩絕峰卡片）", TxtColor or "848484", szCardName )
    me.Msg(szMsg)

    local tbAward = self:GetCardUseAward(nCardTemplateId) or {}
    if tbAward and #tbAward > 0 then
        me.SendAward(tbAward, nil, not bCreate, Env.LogWay_CollectionSystem)
    end
    if bCreate then
        local tbAllAward = {unpack(tbAward or {})}
        table.insert(tbAllAward, 1, {"Item", nItemTemplateId, 1})
        me.CallClientScript("Ui:OpenAwardUi", tbAllAward, Env.LogWay_CollectionSystem)
    end
    Log("[CollectionSystem ActivatePosition] Success", me.dwID, nCollectionId, nPos, tostring(bActivated), nRare)
end

function CollectionSystem:GetCardUseAward(nCardTemplateId)
    local tbCardInfo = self.tbCard[nCardTemplateId]
    return tbCardInfo.tbAward
end

function CollectionSystem:ChangeItemValue(pPlayer, nCollectionId, tbValue)
    local nItemTemplateId = self:GetCollectionItemId(nCollectionId)
    local nCount, tbItem = pPlayer.GetItemCountInAllPos(nItemTemplateId)
    if nCount == 0 then
        return
    end

    local pItem = tbItem[1]
    for nSaveKey, nValue in pairs(tbValue) do
        pItem.SetIntValue(nSaveKey, nValue)
    end
end

function CollectionSystem:UpdateMyRankData(nCollectionId, nRare)
    if not self:IsHaveRankBoard(nCollectionId) then
        return
    end

    local nCompletion = self:GetCompletion(nCollectionId)
    if nCollectionId == self.JINXIUSHANHE then
        RankBoard:UpdateRankVal(self.RANK_KEY .. nCollectionId, me.dwID, nCompletion)
    else
        RankBoard:UpdateRankVal(self.RANK_KEY .. nCollectionId, me.dwID, nRare + nCompletion, nRare)
    end
end

function CollectionSystem:SendRankAward(nCollectionId)
    local tbData = self:GetData()
    local tbCollectionData = tbData[nCollectionId]
    if not tbCollectionData or not CollectionSystem:IsHaveRankBoard(nCollectionId) then
        return
    end

    RankBoard:Rank(self.RANK_KEY .. nCollectionId)
    if self["SendRankAward_" .. nCollectionId] then
        self["SendRankAward_" .. nCollectionId](self)
    end
end

function CollectionSystem:SendRankAward_1()
    local nCollectionId = self.RANDOMFUBEN_ID
    local tbRankPlayer = RankBoard:GetRankBoardWithLength("CardCollection_" .. nCollectionId, 99999, 1)
    local tbNewInfoRank = {}
    local tbMail = {Title = "凌絕峰卡片收集", From = "", nLogReazon = Env.LogWay_CollectionSystem}
    local szMailText = "少俠，上個月的凌絕峰卡片收集活動已結束，你的排名為第%d名，獎勵已隨附件發放，請查收。本月，新的收集活動已經開始，依然要繼續努力收集哦！"
    for nRank, tbRankInfo in ipairs(tbRankPlayer or {}) do
        local tbAward = self:GetRankAward(nCollectionId, nRank)
        if tbAward and next(tbAward) then
            tbMail.To = tbRankInfo.dwUnitID
            tbMail.Text = string.format(szMailText, nRank)
            tbMail.tbAttach = tbAward
            Mail:SendSystemMail(tbMail)
        end

        if nRank <= 10 then
            table.insert(tbNewInfoRank, {nRank = nRank, szName = tbRankInfo.szName, szKin = tbRankInfo.szKinName, nRare = tbRankInfo.nLowValue, nCompletion = tbRankInfo.nHighValue - tbRankInfo.nLowValue})
        end
    end
    NewInformation:AddInfomation("RandomFubenCollection", GetTime() + 3*24*60*60, tbNewInfoRank)
    Log("[CollectionSystem SendRankAward]", nCollectionId, #(tbRankPlayer or {}))
end

function CollectionSystem:SendRankAward_2()
    local nCollectionId = self.JINXIUSHANHE
    local tbRankPlayer = RankBoard:GetRankBoardWithLength("CardCollection_" .. nCollectionId, 99999, 1)
    local tbNewInfoRank = {}
    local tbMail = {Title = "錦繡山河集", From = "", nLogReazon = Env.LogWay_CollectionSystem}
    local szMailText = "大俠，雙十“錦繡山河”收集活動已結束，您獲得了第%d名，附件為獎勵，請查收！"
    for nRank, tbRankInfo in ipairs(tbRankPlayer or {}) do
        local tbAward = self:GetRankAward(nCollectionId, nRank)
        if tbAward and next(tbAward) then
            tbMail.To = tbRankInfo.dwUnitID
            tbMail.Text = string.format(szMailText, nRank)
            tbMail.tbAttach = tbAward
            Mail:SendSystemMail(tbMail)
        elseif nRank > 10 then
            break
        end

        if nRank <= 10 then
            table.insert(tbNewInfoRank, {nRank = nRank, szName = tbRankInfo.szName, szKin = tbRankInfo.szKinName, nCompletion = tbRankInfo.szValue})
        end
    end
    NewInformation:AddInfomation("JXSH_Collection", GetTime() + 3*24*60*60, tbNewInfoRank)
    Log("[CollectionSystem SendRankAward]", nCollectionId, #(tbRankPlayer or {}))
end

function CollectionSystem:GetRankAward(nCollectionId, nRank)
    local tbCollection = self.tbCollection[nCollectionId]
    for _, tbInfo in ipairs(tbCollection.tbRankAward or {}) do
        if nRank <= tbInfo[1] then
            local tbAward = {}
            for _, tb in ipairs(tbInfo[2]) do
                if Player.AwardType[tb[1]] == Player.award_type_add_timetitle and tb[3] ~= -1 then
                    table.insert(tbAward, {tb[1], tb[2], GetTime() + tb[3]})
                else
                    table.insert(tbAward, tb)
                end
            end
            return tbAward
        end
    end
end

function CollectionSystem:UpdateRank()
    for nCollectionId, _ in pairs(self.tbCollection) do
        self:UpdateActivityRank(nCollectionId)
    end
end

function CollectionSystem:UpdateActivityRank(nCollectionId)
    if not CollectionSystem:IsInProcess(nCollectionId) then
        return
    end

    local tbRank = RankBoard:GetRankBoardWithLength("CardCollection_" .. self.RANDOMFUBEN_ID, 500, 1) or {}
    local tbPlayerRank = {}
    for nRank, tbInfo in ipairs(tbRank) do
        tbPlayerRank[tbInfo.dwUnitID] = nRank
    end
    local tbPlayer = KPlayer.GetAllPlayer()
    for _, pPlayer in ipairs(tbPlayer) do
        local tbValue = {}
        tbValue[self.ITEM_RANK] = tbPlayerRank[pPlayer.dwID] or 0
        self:ChangeItemValue(pPlayer, self.RANDOMFUBEN_ID, tbValue)
    end
    Log("CollectionSystem UpdateRandomFubenRank", #tbPlayer, #tbRank)
end