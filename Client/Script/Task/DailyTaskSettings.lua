Task.emDAILY_COMMERCE = "Commerce"
Task.emDAILY_ACT_QUES = "ActQues"
Task.szDailyDefaultKey = Task.emDAILY_COMMERCE
Task.tbDailyTaskSettings = {
  [Task.emDAILY_COMMERCE] = {
    nTaskId = -20001,
    szTitle = "[常]商会任务",
    szTarget = "缴纳商会老板所需的货物",
    szMsg = "商会每日可完成1次；\n上缴道具类货物将获得奖励；\n上缴采集类货物只计算完成次数，不获得奖励；\n缴纳的货物越多，基础奖励越多，所有货物缴齐将获得额外奖励。",
    bShowAwards = false,
    IsInCurTaskList = function()
      return CommerceTask:IsDoingTask(me)
    end,
    OnTrack = function()
      if not CommerceTask:IsDoingTask(me) then
        CommerceTask:AutoPathToTaskNpc()
      else
        Ui:OpenWindow("CommerceTaskPanel")
      end
    end
  },
  [Task.emDAILY_ACT_QUES] = {
    nTaskId = ActivityQuestion.TASK_ID,
    szTitle = "[常]每日答题",
    szTarget = "回答10道题目",
    szMsg = "每日可以答10道题目；\n每回答一道题目都将获得一份奖励，无论对错；\n答完全部10道题目后，无论对错多少，都将额外获得一份奖励",
    bShowAwards = true,
    tbAward = {
      ActivityQuestion.tbMaxAward
    },
    IsInCurTaskList = function()
      return ActivityQuestion:IsTaskDoing()
    end,
    OnTrack = function()
      ActivityQuestion:OnTrack()
    end
  }
}
