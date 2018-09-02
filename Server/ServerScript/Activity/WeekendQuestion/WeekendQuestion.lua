local tbAct = Activity:GetClass("WeekendQuestion")
tbAct.tbTimerTrigger = 
{ 
    [1] = {szType = "Day", Time = "4:01"  , Trigger = "RefreshOnlinePlayerData"},
}
tbAct.tbTrigger  = {Init = {}, Start = {{"StartTimerTrigger", 1}}, End = {}, RefreshOnlinePlayerData = {}}
tbAct.tbTeamData = tbAct.tbTeamData or {}

function tbAct:OnTrigger(szTrigger)
    if szTrigger == "Start" then
        self:LoadSetting()
        self:AddNpc()
        self:BeginClearDataTimer()
        Activity:RegisterNpcDialog(self, 99,  {Text = "五一江湖動靈機", Callback = self.OnNpcDialog, Param = {self}})
        Activity:RegisterNpcDialog(self, "WeekendQuestionNpc",  {Text = "五一江湖動靈機", Callback = self.OnQuestionDialog, Param = {self}})
        Activity:RegisterPlayerEvent(self, "Act_OnPlayerLogin", "OnPlayerLogin")
        Activity:RegisterPlayerEvent(self, "Act_WeekendTryAnswer", "TryAnswer")
        Activity:RegisterPlayerEvent(self, "Act_SysData", "SysData")
        self:SynSwitch()
        Calendar:OnActivityBegin("WeekendQuestion")
    elseif szTrigger == "End" then
        self:DelNpc()
        self:CloseClearDataTimer()
        self.tbTeamData = {}
        self:SynSwitch(true)
        Calendar:OnActivityEnd("WeekendQuestion")
    elseif szTrigger == "RefreshOnlinePlayerData" then
        self:RefreshOnlinePlayerData()
    end
    Log("WeekendQuestion OnTrigger:", szTrigger)
end

function tbAct:SysData(pPlayer)
    pPlayer.CallClientScript("Activity:GetUiSetting('WeekendQuestion'):OnSynData", self:GetData(pPlayer))
end

function tbAct:GetData(pPlayer)
    local szTips,tbLinkData,nScore,tbTip = self:GetTips(pPlayer,true)
    local tbData = {
            szTips = szTips,
            tbLinkData = tbLinkData,
            nScore = nScore,
            tbTip = tbTip,
            nEndTime = Activity:GetActEndTime(self.szKeyName),
        }
    return tbData
end

-- 同步活动开关
function tbAct:SynSwitch(bClose) 
    local tbPlayer = KPlayer.GetAllPlayer()
    for _, pPlayer in pairs(tbPlayer) do
        local tbData 
        if not bClose then
            tbData = self:GetData(pPlayer)
        end
        pPlayer.CallClientScript("Activity:GetUiSetting('WeekendQuestion'):OnSynData",tbData)
    end
end

function tbAct:LoadSetting()
    self.tbNpcTip   = {}
    self.tbNpcList  = {}
    self.tbNpcQuestion = {}
    self.tbNpcPosInfo = {}

    local szTabPath = "Setting/Activity/WeekendQuestionNpcPos.tab";
    local szParamType = "sdsdddd";
    local tbParams = {"szTimeFrame","nNpcTID","Name","nMapId","nX","nY","nDir"};
    local tbFile = LoadTabFile(szTabPath, szParamType, nil, tbParams);

    szTabPath = "Setting/Activity/WeekendQuestionNpc.tab";
    szParamType = "sdsssss";
    tbParams = {"szTimeFrame","nNpcTID","Name","Map","szTips1","szTips2","szTips3"};
    local tbData = LoadTabFile(szTabPath, szParamType, nil, tbParams);
    local tbAllWeekendQuestionNpc = {}
    for _,v in pairs(tbData) do
        tbAllWeekendQuestionNpc[v.szTimeFrame] = tbAllWeekendQuestionNpc[v.szTimeFrame] or {}
        tbAllWeekendQuestionNpc[v.szTimeFrame][v.nNpcTID] = v
    end

    local tbAllNpc = {}
    for _,tbInfo in pairs(tbFile) do
        tbAllNpc[tbInfo.szTimeFrame] = tbAllNpc[tbInfo.szTimeFrame] or {}
        table.insert(tbAllNpc[tbInfo.szTimeFrame],tbInfo)
    end
    local szCurTimeFrame = Lib:GetMaxTimeFrame(tbAllNpc);

    local tbTimeFrameNpc = tbAllNpc[szCurTimeFrame]
    if not tbTimeFrameNpc then
        Log("[WeekendQuestion] LoadSetting fail",szCurTimeFrame == "" and "nil" or szCurTimeFrame)
        Lib:LogTB(tbAllNpc)
        return
    end

    local tbTimeFrameNpcIndex = {}

    local tbAllWeekendQuestionTimeFrameNpc = tbAllWeekendQuestionNpc[szCurTimeFrame]
    assert(tbAllWeekendQuestionTimeFrameNpc)

    for _, tbInfo in ipairs(tbTimeFrameNpc) do
        tbTimeFrameNpcIndex[tbInfo.nNpcTID] = true

        self.tbNpcPosInfo[tbInfo.nNpcTID] = tbInfo

        local tbAllWeekendQuestionNpcInfo = tbAllWeekendQuestionTimeFrameNpc[tbInfo.nNpcTID]
        if tbAllWeekendQuestionTimeFrameNpc[tbInfo.nNpcTID] then
            table.insert(self.tbNpcList, tbInfo.nNpcTID)
            local tbTip = {}
            for i = 1, 3 do
                table.insert(tbTip, tbAllWeekendQuestionNpcInfo["szTips" .. i])
            end
            self.tbNpcTip[tbInfo.nNpcTID] = tbTip
        else
            Log("[WeekendQuestion] LoadSetting error",tbInfo.nNpcTID,szCurTimeFrame)
        end
    end

    for nQID, tbInfo in pairs(DaTi.tbAllQuestion["WeekendQuestion"]) do

        local nNpcTID = tbInfo.nNpcTID
        if tbTimeFrameNpcIndex[nNpcTID] then
            self.tbNpcQuestion[nNpcTID] = self.tbNpcQuestion[nNpcTID] or {}
            table.insert(self.tbNpcQuestion[nNpcTID], nQID)
        end
    end
    Log("WeekendQuestion LoadSetting")
end

function tbAct:AddNpc()
    self.tbCreateNpc = {}
    self.tbCreateNpc2Id = {}
    for _, tbInfo in pairs(self.tbNpcPosInfo) do
        local pNpc = KNpc.Add(tbInfo.nNpcTID, 1, -1, tbInfo.nMapId, tbInfo.nX, tbInfo.nY, tbInfo.nDir)
        table.insert(self.tbCreateNpc, pNpc.nId)

        self.tbCreateNpc2Id[tbInfo.nNpcTID] = pNpc.nId
    end
    Log("WeekendQuestion AddNpc")
end

function tbAct:DelNpc()
    for _, nNpcId in ipairs(self.tbCreateNpc or {}) do
        local pNpc = KNpc.GetById(nNpcId)
        if pNpc then
            pNpc.Delete()
        end
    end
    self.tbCreateNpc = nil
    Log("WeekendQuestion DelNpc")
end

function tbAct:BeginClearDataTimer()
    self.nClearTimer = Timer:Register(Env.GAME_FPS * 60 *30, self.ClearNullTeam, self)
end

function tbAct:CloseClearDataTimer()
    if self.nClearTimer then
        Timer:Close(self.nClearTimer)
    end
    self.nClearTimer = nil
end

function tbAct:ClearNullTeam()
    for nTeamId, _ in pairs(self.tbTeamData) do
        if not TeamMgr:GetTeamById(nTeamId) then
            self.tbTeamData[nTeamId] = nil
        end
    end
    return true
end

function tbAct:OnNpcDialog()
    local szTips,tbLinkData = self:GetTips()
    if not szTips then
        return
    end

    ChatMgr:SendTeamOrSysMsg(me, szTips,nil,tbLinkData)
end

function tbAct:OnQuestionDialog()
    local szTips,tbLinkData = self:GetTips()
    if not szTips then
        return
    end

    local tbData = self.tbTeamData[me.dwTeamID]
    if tbData.nNpcTID ~= him.nTemplateId then
        ChatMgr:SendTeamOrSysMsg(me, szTips,nil,tbLinkData)
        return
    end
    self:TryBeginQuestion()
end

function tbAct:CheckTeamMember(pP)
    local pTarget = pP or me
    if pTarget.dwTeamID == 0 then
        return false, "請組成兩人隊伍再來"
    end

    local tbTeamMember = TeamMgr:GetMembers(pTarget.dwTeamID)
    if #tbTeamMember ~= 2 then
        return false, "隊伍人數必須為兩人"
    end

    table.sort(tbTeamMember, function (a, b)
        return a == pTarget.dwID and b ~= pTarget.dwID
    end)

    local tbSecOK = {}
    local tbMember = {}
    for nIdx, nPlayerId in ipairs(tbTeamMember) do
        local pPlayer = KPlayer.GetPlayerObjById(nPlayerId)
        if not pPlayer then
            return false, "沒找到玩家"
        end

        if pPlayer.nLevel < self.JOIN_LEVEL then
            return false, string.format("「%s」等級不足%d級", pPlayer.szName, self.JOIN_LEVEL)
        end

        tbSecOK[nIdx] = Gift:CheckSex(pPlayer.nFaction)
        local bRet, szMsg = self:CheckMemberData(pPlayer)
        if not bRet then
            if nPlayerId ~= pTarget.dwID then
                szMsg = "隊友" .. szMsg
            end
            return false, szMsg
        end
        table.insert(tbMember, pPlayer)
    end
    if tbSecOK[1] == tbSecOK[2] then
        return false, "必須異性組隊"
    end

    self:CheckTeamData(tbMember,pTarget)
    return true
end

function tbAct:CheckMemberData(pPlayer)
    self:CheckPlayerData(pPlayer)
    if pPlayer.GetUserValue(self.DATA_GROUP, self.ANSWERD) >= self.MAX_COUNT then
        return false, "今日題目已答完"
    end
    if pPlayer.GetUserValue(self.DATA_GROUP, self.AWARD_FLAG) ~= 0 then
        return false, "已完成今日的答題"
    end
    return true
end

function tbAct:CheckPlayerData(pPlayer)
    local nLocalDay = Lib:GetLocalDay(GetTime() - 4*3600)
    if pPlayer.GetUserValue(self.DATA_GROUP, self.DATA_DAY) == nLocalDay then
        return
    end

    pPlayer.SetUserValue(self.DATA_GROUP, self.DATA_DAY, nLocalDay)
    pPlayer.SetUserValue(self.DATA_GROUP, self.RIGHT, 0)
    pPlayer.SetUserValue(self.DATA_GROUP, self.ANSWERD, 0)
    pPlayer.SetUserValue(self.DATA_GROUP, self.AWARD_FLAG, 0)
    pPlayer.SetUserValue(self.DATA_GROUP, self.NPC_FLAG, 0)
end

function tbAct:CheckTeamData(tbMember,pP)
    local pTarget = pP or me
    local nTeamId = pTarget.dwTeamID
    if self.tbTeamData[nTeamId] then
        local tbId = self.tbTeamData[nTeamId].tbPlayerId
        if (tbId[1] == tbMember[1].dwID and tbId[2] == tbMember[2].dwID) or (tbId[1] == tbMember[2].dwID and tbId[2] == tbMember[1].dwID) then
            return
        end
    end
    local nIdx, nNpc = self:GetNpcTID(tbMember)
    local nBoyQuestionId, nGirlQuestionId = self:GetQuestionId(nNpc)
    self.tbTeamData[nTeamId] = {
        nScore       = 0,
        nNpcIdx      = nIdx,
        nNpcTID      = nNpc,
        nLocalDay    = Lib:GetLocalDay(GetTime() - 4*3600),
        tbPlayerId   = {tbMember[1].dwID, tbMember[2].dwID},
        tbPlayerData = {
                        [Gift.Sex.Boy] = {bAnswered = false, nBeginTime = 0, nQuestionId = nBoyQuestionId, nScore = 0},
                        [Gift.Sex.Girl] = {bAnswered = false, nBeginTime = 0, nQuestionId = nGirlQuestionId, nScore = 0}},
    }
end

function tbAct:CheckDistance()
    local tbTeamMember = TeamMgr:GetMembers(me.dwTeamID)
    local pPlayer1 = KPlayer.GetPlayerObjById(tbTeamMember[1])
    local pPlayer2 = KPlayer.GetPlayerObjById(tbTeamMember[2])
    local nMapId1, nX1, nY1 = pPlayer1.GetWorldPos()
    local nMapId2, nX2, nY2 = pPlayer2.GetWorldPos()

    local szName = ""
    if pPlayer1.dwID == me.dwID then
        szName = pPlayer2.szName
    elseif pPlayer2.dwID == me.dwID then
         szName = pPlayer1.szName
    end

    if nMapId1 ~= nMapId2 then
        return false, string.format("隊友%s不在本地圖",szName)
    end

    local fDists = Lib:GetDistsSquare(nX1, nY1, nX2, nY2)
    if fDists > (self.MIN_DISTANCE * self.MIN_DISTANCE) then
        return false, string.format("隊友%s不在附近",szName)
    end

    return true
end

function tbAct:GetNpcTID(tbMember)
    local tbCanChoose = {}
    local nFlag1 = tbMember[1].GetUserValue(self.DATA_GROUP, self.NPC_FLAG)
    local nFlag2 = tbMember[2].GetUserValue(self.DATA_GROUP, self.NPC_FLAG)
    local nNpcLen = math.min(32, #self.tbNpcList)
    for i = 1, nNpcLen do
        if KLib.GetBit(nFlag1, i) == 0 and KLib.GetBit(nFlag2, i) == 0 then
            table.insert(tbCanChoose, self.tbNpcList[i])
        end
    end
    if #tbCanChoose > 0 then
        local nIdx = MathRandom(#tbCanChoose)
        return nIdx, tbCanChoose[nIdx]
    else
        local nIdx = MathRandom(#self.tbNpcList)
        return nIdx, self.tbNpcList[nIdx]
    end
end

function tbAct:GetQuestionId(nNpcTID)
    local tbQuestion = {unpack(self.tbNpcQuestion[nNpcTID])}
    local nQuestionId1 = table.remove(tbQuestion, MathRandom(#tbQuestion))
    local nQuestionId2 = table.remove(tbQuestion, MathRandom(#tbQuestion))
    return nQuestionId1, nQuestionId2
end

function tbAct:OnPlayerLogin()
    self:CheckPlayerData(me)
    self:SysData(me)
    self:CheckAllRight(me)

end

function tbAct:CheckAllRight(pPlayer)
    local nStartTime = Activity:GetActBeginTime(self.szKeyName)
    local nSaveStartTime = pPlayer.GetUserValue(self.DATA_GROUP, self.START_TIME)
    if nStartTime ~= 0 and nStartTime ~= nSaveStartTime then
        local nAllRight = pPlayer.GetUserValue(self.DATA_GROUP, self.ALL_RIGHT)
        pPlayer.SetUserValue(self.DATA_GROUP, self.START_TIME,nStartTime)
        pPlayer.SetUserValue(self.DATA_GROUP, self.ALL_RIGHT,0)
        Log("[WeekendQuestion] CheckAllRight reset",nStartTime,nSaveStartTime,nAllRight)
    end
end

function tbAct:RefreshOnlinePlayerData()
    local tbPlayer = KPlayer.GetAllPlayer()
    for _, pPlayer in ipairs(tbPlayer) do
        self:CheckPlayerData(pPlayer)
    end
end

function tbAct:GetTips(pP,bNoTip)
    local pPlayer = pP or me
    local bRet, szMsg = self:CheckTeamMember(pPlayer)
    if not bRet then
        if not bNoTip then
            pPlayer.CenterMsg(szMsg)
        end
        return
    end
    local szTip = "下個出題人線索："
    local nTeamId = pPlayer.dwTeamID
    local nScore  = self.tbTeamData[nTeamId].nScore
    local nNpcTID = self.tbTeamData[nTeamId].nNpcTID

    local tbOk = {}
    local tbPlayerId = self.tbTeamData[nTeamId].tbPlayerId
    for _,dwID in ipairs(tbPlayerId) do
        local pPlayer = KPlayer.GetPlayerObjById(dwID)
        if pPlayer then
            local nAnswered = pPlayer.GetUserValue(self.DATA_GROUP, self.ANSWERD)
            if nAnswered == 0 then
                table.insert(tbOk,dwID)
            end
        end
    end

    if #tbOk == 2 then
        nScore = 2
    end
   
    local tbInfo = self.tbNpcPosInfo[nNpcTID]
    local tbTip = self.tbNpcTip[nNpcTID]

    szTip = szTip ..self.tbNpcTip[nNpcTID][nScore + 1]
    local tbLinkData
    if nScore == 2 and tbInfo then
        local tbMapSetting = Map:GetMapSetting(tbInfo.nMapId);
        local pNpc = KNpc.GetById(self.tbCreateNpc2Id[nNpcTID] or 0)
        local szNpcName = pNpc and pNpc.szName or "NPC"
        local szLocaltion = string.format("%s，位於<%s(%d,%d)>",szNpcName, tbMapSetting.MapName, tbInfo.nX*Map.nShowPosScale, tbInfo.nY*Map.nShowPosScale);
        szTip = szTip ..szLocaltion
        tbLinkData = {nLinkType = ChatMgr.LinkType.Position,nMapId = tbInfo.nMapId,nX = tbInfo.nX,nY = tbInfo.nY,nMapTemplateId = tbInfo.nMapId,szNpcName = szNpcName}
    end

    return string.format(szTip),tbLinkData,nScore,tbTip
end

function tbAct:TryBeginQuestion()
     
    local bRet, szMsg = self:CheckTeamMember()
    if not bRet then
        me.CenterMsg(szMsg)
        return
    end
    bRet, szMsg = self:CheckDistance()
    if not bRet then
        me.CenterMsg(szMsg)
        ChatMgr:SendTeamOrSysMsg(me, szMsg)
        return
    end 
    local nTeamId = me.dwTeamID
    local tbData = self.tbTeamData[nTeamId]
    local tbBoyData = tbData.tbPlayerData[Gift.Sex.Boy]
    local tbGirlData = tbData.tbPlayerData[Gift.Sex.Girl]
    if Gift:CheckSex(me.nFaction) == Gift.Sex.Boy then
        if tbBoyData.bAnswered or (tbBoyData.nBeginTime > 0 and (GetTime() - tbBoyData.nBeginTime) >= self.TIME_OUT) then
            me.CenterMsg("你已完成這輪答題")
            return
        end

        tbBoyData.nBeginTime = tbBoyData.nBeginTime > 0 and tbBoyData.nBeginTime or GetTime()
        DaTi:TryBeginQuestion(me, "WeekendQuestion", tbBoyData.nQuestionId, tbBoyData.nBeginTime + self.TIME_OUT)
    else
        if not tbBoyData.bAnswered then
            if tbBoyData.nBeginTime > 0 and GetTime() - tbBoyData.nBeginTime >= self.TIME_OUT then
                tbBoyData.bAnswered = true
                tbBoyData.nScore = 0
            else
                me.CenterMsg("請等待隊友完成答題")
                return
            end
        end
        if tbGirlData.bAnswered then
            me.CenterMsg("已完成回答，請開始下一輪答題")
            return
        end
        if tbGirlData.nBeginTime > 0 and (GetTime() - tbGirlData.nBeginTime) >= self.TIME_OUT then
            self:BeginNextQuestion()
            Log("WeekendQuestion TryBeginQuestion Girl TimeOut", me.dwID)
            return
        end
        tbGirlData.nBeginTime = tbGirlData.nBeginTime > 0 and tbGirlData.nBeginTime or GetTime()
        DaTi:TryBeginQuestion(me, "WeekendQuestion", tbGirlData.nQuestionId, tbGirlData.nBeginTime + self.TIME_OUT)
    end
end

function tbAct:TryAnswer(pPlayer,bRight)
    local bRet, szMsg = self:CheckTeamMember(pPlayer)
    if not bRet then
        pPlayer.CenterMsg(szMsg)
        return
    end

    self:CheckAllRight(pPlayer)

    local nTeamId = pPlayer.dwTeamID
    local tbData = self.tbTeamData[nTeamId]
    local tbBoyData = tbData.tbPlayerData[Gift.Sex.Boy]
    local tbGirlData = tbData.tbPlayerData[Gift.Sex.Girl]
    if Gift:CheckSex(pPlayer.nFaction) == Gift.Sex.Boy then
        if tbBoyData.bAnswered then
            pPlayer.CenterMsg("你已完成這輪答題")
            return
        end
        if tbBoyData.nBeginTime == 0 then
            pPlayer.CenterMsg("請先開始答題")
            return
        end
        if GetTime() - tbBoyData.nBeginTime >= self.TIME_OUT then
            bRight = false
            Log("WeekendQuestion TryAnswer Boy TIME_OUT",pPlayer.dwID,pPlayer.szName,pPlayer.nFaction)
        end

        tbBoyData.nBeginTime = 0
        tbBoyData.bAnswered = true
        tbBoyData.nScore = bRight and 1 or 0

        if bRight then
            ChatMgr:SendTeamOrSysMsg(pPlayer, string.format("%s答對了題目，真是機智過人！",pPlayer.szName))
        end

        for _, nPlayerId in ipairs(tbData.tbPlayerId) do
            if nPlayerId ~= pPlayer.dwID then
                local pGirl = KPlayer.GetPlayerObjById(nPlayerId)
                if not pGirl then
                    return
                end
                pGirl.CenterMsg("隊友已經回答完畢，輪到你進行答題了")
                bRet,szMsg = self:CheckDistance()
                if not bRet then
                    ChatMgr:SendTeamOrSysMsg(pGirl, szMsg)
                    return
                end

                tbGirlData.nBeginTime = GetTime()
                DaTi:TryBeginQuestion(pGirl, "WeekendQuestion", tbGirlData.nQuestionId, tbGirlData.nBeginTime + self.TIME_OUT)
            end
        end
    else
        if not tbBoyData.bAnswered then
            if tbBoyData.nBeginTime > 0 and GetTime() - tbBoyData.nBeginTime >= self.TIME_OUT then
                tbBoyData.nBeginTime = 0
                tbBoyData.bAnswered  = true
                tbBoyData.nScore     = 0
            else
                pPlayer.CenterMsg("請等待隊友完成答題")
                return
            end
        end
        if tbGirlData.bAnswered then
            pPlayer.CenterMsg("已完成回答，請開始下一輪答題")
            return
        end
        if tbGirlData.nBeginTime == 0 then
            pPlayer.CenterMsg("請先開始答題")
            return
        end
        if GetTime() - tbGirlData.nBeginTime >= self.TIME_OUT then
            bRight = false
            Log("WeekendQuestion TryAnswer Girl TIME_OUT",pPlayer.dwID,pPlayer.szName,pPlayer.nFaction)
        end

        tbGirlData.nBeginTime = 0
        tbGirlData.bAnswered = true
        tbGirlData.nScore = bRight and 1 or 0
        if bRight then
            ChatMgr:SendTeamOrSysMsg(pPlayer, string.format("%s答對了題目，真是機智過人！",pPlayer.szName))
        end

        self:BeginNextQuestion()

        Log("WeekendQuestion Complete A Group Question", unpack(tbData.tbPlayerId))
    end
end

function tbAct:TryCheckEndAward(pPlayer)
    if not next(self.END_AWARD) then
        return 
    end
    local nAnswered = pPlayer.GetUserValue(self.DATA_GROUP, self.ANSWERD)
    if nAnswered == self.MAX_COUNT then
        pPlayer.SendAward(self.END_AWARD, nil, true, Env.LogWay_WeekendQuestionCompleted)
        Log("[WeekendQuestion] TryCheckEndAward ok",pPlayer.szName,pPlayer.dwID,nAnswered,self.MAX_COUNT)
    end
end

function tbAct:TryCheckAllRightAward(pPlayer)
    local nAllRight = pPlayer.GetUserValue(self.DATA_GROUP, self.ALL_RIGHT)
    local tbAward = self.ALL_RIGHT_AWARD[nAllRight]

    if tbAward then
        local tbFormatAward = self:FormatReward(tbAward)
        pPlayer.SendAward(tbFormatAward, nil, true, Env.LogWay_WeekendQuestionAllRight)
        Log("[WeekendQuestion] TryCheckAllRightAward ok",pPlayer.szName,pPlayer.dwID,nAllRight)
    else
        Log("[WeekendQuestion] TryCheckAllRightAward warn",pPlayer.szName,pPlayer.dwID,nAllRight)
    end
end

function tbAct:BeginNextQuestion()
    local tbTeamMember = TeamMgr:GetMembers(me.dwTeamID)
    local tbTeamData = self.tbTeamData[me.dwTeamID]
    for i = 1, 2 do
        local pPlayer = KPlayer.GetPlayerObjById(tbTeamMember[i])
        local nSex = Gift:CheckSex(pPlayer.nFaction)
        local bRight = false
        if tbTeamData.tbPlayerData[nSex].nScore > 0 then
            local nRight = pPlayer.GetUserValue(self.DATA_GROUP, self.RIGHT) + 1
            pPlayer.SetUserValue(self.DATA_GROUP, self.RIGHT, nRight)
            pPlayer.SendAward(self.RIGHT_AWARD, nil, true, Env.LogWay_WeekendQuestion)
            bRight = true
        else
            pPlayer.SendAward(self.WRONG_AWARD, nil, true, Env.LogWay_WeekendQuestion)
        end
        local nAnswered = pPlayer.GetUserValue(self.DATA_GROUP, self.ANSWERD) + 1
        pPlayer.SetUserValue(self.DATA_GROUP, self.ANSWERD, nAnswered)
        local nNpcFlag = pPlayer.GetUserValue(self.DATA_GROUP, self.NPC_FLAG)
        nNpcFlag = KLib.SetBit(nNpcFlag, tbTeamData.nNpcIdx, 1)
        pPlayer.SetUserValue(self.DATA_GROUP, self.NPC_FLAG, nNpcFlag)

        local nAllRight = pPlayer.GetUserValue(self.DATA_GROUP, self.ALL_RIGHT)
        if bRight then
            pPlayer.SetUserValue(self.DATA_GROUP, self.ALL_RIGHT,nAllRight + 1)
            self:TryCheckAllRightAward(pPlayer)
        end
        self:TryCheckEndAward(pPlayer)

        if nAnswered >= self.MAX_COUNT then
            pPlayer.CenterMsg("本日答題已完成")
        end
    end
    self:RefreshTeamData()
    self:SendTips()
    self:SysData(me,true)
end

function tbAct:RefreshTeamData()
    local tbTeamMember = TeamMgr:GetMembers(me.dwTeamID)
    local tbMember = {}
    for i = 1, 2 do
        table.insert(tbMember, KPlayer.GetPlayerObjById(tbTeamMember[i]))
    end
    local nIdx, nNpc = self:GetNpcTID(tbMember)
    local tbTeamData = self.tbTeamData[me.dwTeamID]
    local nBoyQuestionId, nGirlQuestionId = self:GetQuestionId(nNpc)
    tbTeamData.nScore  = tbTeamData.tbPlayerData[1].nScore + tbTeamData.tbPlayerData[2].nScore
    tbTeamData.nNpcIdx = nIdx
    tbTeamData.nNpcTID = nNpc
    tbTeamData.tbPlayerData = {
                        [Gift.Sex.Boy]  = {bAnswered = false, nBeginTime = 0, nQuestionId = nBoyQuestionId,  nScore = 0},
                        [Gift.Sex.Girl] = {bAnswered = false, nBeginTime = 0, nQuestionId = nGirlQuestionId, nScore = 0}}
end

function tbAct:SendTips()
    local szTips,tbLinkData = self:GetTips()
    if not szTips then
        return
    end
    ChatMgr:SendTeamOrSysMsg(me, szTips,nil,tbLinkData)
end