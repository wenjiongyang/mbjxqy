if not MODULE_GAMESERVER then
    Activity.ZhongQiuJie = Activity.ZhongQiuJie or {}
end
local tbAct = MODULE_GAMESERVER and Activity:GetClass("ZhongQiuJie") or Activity.ZhongQiuJie
tbAct.nEverydayTargetAward  = 2886
tbAct.REFRESH_TIME          = 4*3600
tbAct.TIME_OUT              = 30
tbAct.MAX_QUESTION          = 10
tbAct.JOIN_LEVEL            = 20
tbAct.tbQuestionAward_Right = {"Contrib", 60}
tbAct.tbQuestionAward_Wrong = {"Contrib", 30}
tbAct.CLEARING_TIME         = 24*3600 - 60 --23:59
----------------------------以上为配置项----------------------------

tbAct.nSaveGroup   = 62
tbAct.DATA_TIME    = 1
tbAct.BEGIN_TIME   = 2
tbAct.COMPLETE_NUM = 3
tbAct.TOTAL_TIME   = 4
tbAct.RIGHT_NUM    = 5

function tbAct:GetComplete(pPlayer)
    return pPlayer.GetUserValue(self.nSaveGroup, self.COMPLETE_NUM)
end

function tbAct:GetRightNum(pPlayer)
    return pPlayer.GetUserValue(self.nSaveGroup, self.RIGHT_NUM)
end

function tbAct:GetTotalTime(pPlayer)
    return pPlayer.GetUserValue(self.nSaveGroup, self.TOTAL_TIME)
end