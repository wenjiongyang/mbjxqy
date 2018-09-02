function ActivityQuestion:OnLogin()
    self:RefreshData(me);
end

function ActivityQuestion:OnNewDayBegin()
    local tbAllPlayer = KPlayer.GetAllPlayer()
    for _, pPlayer in pairs(tbAllPlayer) do
        self:RefreshData(pPlayer)
    end
end

local nOffset = 4 * 3600;
function ActivityQuestion:RefreshData(pPlayer)
    local nCurTime    = GetTime();
    local nLastlyTime = pPlayer.GetUserValue(self.GROUP, self.LAST_LOGIN_TIME);

    if nLastlyTime == 0 or Lib:IsDiffDay(nOffset, nCurTime, nLastlyTime) then
        pPlayer.SetUserValue(self.GROUP, self.LAST_LOGIN_TIME, nCurTime)
        pPlayer.SetUserValue(self.GROUP, self.LOGIN_LEVEL, pPlayer.nLevel)

        local nSubmit = pPlayer.GetUserValue(self.GROUP, self.SUBMIT_TASK)
        local nAccept = pPlayer.GetUserValue(self.GROUP, self.RECEIVE_TASK)
        if nAccept ~= 1 and nSubmit == 0 then --没提交任务就不刷新任务数据
            Log("[ActivityQuestion RefreshData Without QuestionData] >>>>", pPlayer.dwID, pPlayer.szName)
            return
        end

        pPlayer.SetUserValue(self.GROUP, self.HAD_ANSWER_NUM, 0);
        pPlayer.SetUserValue(self.GROUP, self.CORRECT_NUM, 0);
        pPlayer.SetUserValue(self.GROUP, self.RECEIVE_TASK, 0)
        pPlayer.SetUserValue(self.GROUP, self.SUBMIT_TASK, 0)

        pPlayer.CallClientScript("ActivityQuestion:OnDataUpdate")
        Log("[ActivityQuestion RefreshData] >>>>", pPlayer.dwID, pPlayer.szName)
    end
end

function ActivityQuestion:TryAcceptTask()
    if not self:CheckPlayerLevel(me.nLevel) then
        me.CenterMsg("不在等級範圍內")
        return
    end

    self:RefreshData(me)

    local bReceived = me.GetUserValue(self.GROUP, self.RECEIVE_TASK) == 1
    local nDegree   = DegreeCtrl:GetDegree(me, "ActivityQuestion")

    if not bReceived and nDegree > 0 then
        DegreeCtrl:ReduceDegree(me, "ActivityQuestion", 1)
        self:CreateDayQuestionGroup(me)
        self:CreateQuestionId(me)
        me.SetUserValue(self.GROUP, self.RECEIVE_TASK, 1)
        me.CallClientScript("ActivityQuestion:OnAcceptSuccess")
        Log("[ActivityQuestion TryAcceptTask]", me.dwID, me.szName)
    else
        me.CenterMsg("任務接受失敗")
    end
end

function ActivityQuestion:TrySubmitTask()
    local bRet, szMsg = self:CheckSubmitTask()
    if bRet then
        me.SetUserValue(self.GROUP, self.SUBMIT_TASK, 1)
        me.SendAward({self.tbMaxAward}, nil, true, Env.LogWay_ActivityQuestion)
        local nDegree = DegreeCtrl:GetDegree(me, "ActivityQuestion")
        if nDegree > 0 then
            self:RefreshData(me)
        end
        EverydayTarget:AddCount(me, "ActivityQuestion");

        me.CallClientScript("ActivityQuestion:OnDataUpdate")
        me.CenterMsg("任務提交成功")
        Log("[ActivityQuestion TrySubmitTask] Success", me.dwID, me.szName, nDegree)
    else
        me.CenterMsg(szMsg)
    end
end

function ActivityQuestion:TryAnswer(pPlayer, nQuestionId, bRight)

    self:RefreshData(pPlayer)

    local bRet, szMsg = self:CheckCanAnswer(nQuestionId)
    if not bRet then
        pPlayer.CenterMsg(szMsg or "")
        return
    end

    local nHadAnswer = pPlayer.GetUserValue(self.GROUP, self.HAD_ANSWER_NUM) + 1;
    pPlayer.SetUserValue(self.GROUP, self.HAD_ANSWER_NUM, nHadAnswer);
    if not self:IsAnswerNumMax() then
        self:CreateQuestionId(pPlayer);
    end

    local nCorrect = pPlayer.GetUserValue(self.GROUP, self.CORRECT_NUM);
    nCorrect = bRight and nCorrect + 1 or nCorrect;
    pPlayer.SetUserValue(self.GROUP, self.CORRECT_NUM, nCorrect);
    Log("[ActivityQuestion TryAnswer] Success", pPlayer.dwID, pPlayer.szName, GetTime())

    local tbAward = {}
    table.insert(tbAward, bRight and self.tbRightAward or self.tbWrongAward)
    pPlayer.SendAward(tbAward, true, nil, Env.LogWay_ActivityQuestion)

    Task:OnTaskExtInfo(pPlayer, Task.ExtInfo_DaTi);
    pPlayer.CallClientScript("ActivityQuestion:OnDataUpdate");
    pPlayer.TLogRoundFlow(Env.LogWay_ActivityQuestion, nQuestionId, 0, 0, bRight and Env.LogRound_SUCCESS or Env.LogRound_FAIL, 0, 0);
end

function ActivityQuestion:CheckCanAnswer(nQuestionId)
    if me.GetUserValue(self.GROUP, self.RECEIVE_TASK) == 0 then
        return false, "請先接受任務"
    end

    if self:IsAnswerNumMax() then
        return false, "已答完今日題目"
    end

    if not self:CheckQuestionId(nQuestionId) then
        return false, "答題失敗，請重試"
    end

    return true
end

function ActivityQuestion:CreateQuestionId(pPlayer)
    local nAnswerNum = pPlayer.GetUserValue(self.GROUP, self.HAD_ANSWER_NUM);
    local nQuesID    = self:GetRandomQuestionID(pPlayer, nAnswerNum)
    pPlayer.SetUserValue(self.GROUP, self.CURRENT_QUESTION_ID, nQuesID);
end

function ActivityQuestion:CheckQuestionId(nQuestionId)
    if not nQuestionId or nQuestionId < 1 then
        return false;
    end

    local nCurId = me.GetUserValue(self.GROUP, self.CURRENT_QUESTION_ID);
    return nCurId == nQuestionId;
end

function ActivityQuestion:IsAnswerRight(nQuestionId, nAnswerId)
    if not nAnswerId or type(nAnswerId) ~= "number" then
        return false;
    end

    return nAnswerId == self:GetAnswer(nQuestionId);
end

function ActivityQuestion:CreateDayQuestionGroup(pPlayer)
    local tbRand = {}
    local tbList = {}
    for i = 1, self.ANSWER_NUM_MAX do
        if not next(tbList) then
            tbList = {unpack( self.tbNpcList )} --在npc不足最大答题数量时，此处会执行多次
        end
        local nRand = MathRandom(#tbList)
        tbRand[i] = table.remove(tbList, nRand)
    end
    for i = 1, self.ANSWER_NUM_MAX do
        pPlayer.SetUserValue(self.GROUP, self.GROUP_BEGIN_IDX + i - 1, tbRand[i])
    end
end

function ActivityQuestion:GetRandomQuestionID(pPlayer, nHadAnswerNum)
    local nNpcTemId     = math.max(1, pPlayer.GetUserValue(self.GROUP, self.GROUP_BEGIN_IDX + nHadAnswerNum))
    local tbQuesInGroup = self.tbNpcQuestions[nNpcTemId] or {};
    local nQuesID       = MathRandom(1, #tbQuesInGroup);
    return tbQuesInGroup[nQuesID] or 1;
end

function ActivityQuestion:CheckPlayerLevel(nLevel)
    return nLevel >= self.MIN_LEVEL and nLevel <= self.MAX_LEVEL
end

function ActivityQuestion:CheckYesterdayOpen(pPlayer)
    local nLoginLevel = pPlayer.GetUserValue(self.GROUP, self.LOGIN_LEVEL)
    return self:CheckPlayerLevel(nLoginLevel)
end

function ActivityQuestion:OnPlayerLevelUp(nNewLevel)
    if nNewLevel == self.MAX_LEVEL + 1 then
        Task:OnTaskExtInfo(me, Task.ExtInfo_DaTi)
        Log("[ActivityQuestion OnPlayerLevelUp] AutoComplete", me.dwID)
    end
end



-------------------------------------任务答题-------------------------------------
function ActivityQuestion.tbTaskQuestion:TryAnswer(pPlayer, nQuestionId, bRight)
    if not nQuestionId or not self:CheckCanAnswer(nQuestionId) then
        return
    end

    if bRight then
        local nCorrect = pPlayer.GetUserValue(ActivityQuestion.GROUP, ActivityQuestion.TASK_CORRECT_NUM)
        pPlayer.SetUserValue(ActivityQuestion.GROUP, ActivityQuestion.TASK_CORRECT_NUM, nCorrect + 1)
    end

    local nCurIdx = pPlayer.GetUserValue(ActivityQuestion.GROUP, ActivityQuestion.TASK_ANSWERID_NUM) + 1
    local nQuestionNum = self:GetQuestionNum()
    pPlayer.SetUserValue(ActivityQuestion.GROUP, ActivityQuestion.TASK_ANSWERID_NUM, nCurIdx)
    if nCurIdx == nQuestionNum then
        Task:OnTaskExtInfo(pPlayer, Task.ExtInfo_TaskQuestion)
    end
end