local tbUi = Ui:CreateClass("AttributeDescription")
tbUi.tbSpecilKeys = {
  InDifferBattleScoreHelp = "[92D2FF]积分：[-]0~5           [92D2FF]评价：[-][FFFFFF]普通[-] \n[92D2FF]积分：[-]6~15         [92D2FF]评价：[-][64db00]一般[-] \n[92D2FF]积分：[-]16~31       [92D2FF]评价：[-][11adf6]良好[-] \n[92D2FF]积分：[-]32~47       [92D2FF]评价：[-][aa62fc]优秀[-] \n[92D2FF]积分：[-]48~95       [92D2FF]评价：[-][ff578c]卓越[-] \n[92D2FF]积分：[-]96+           [92D2FF]评价：[-][ff8f06]最佳[-]\n\n[C8FF00]常规赛奖励：[-]\n[92D2FF]积分：[-]0~5           [92D2FF]奖励：[-]1200荣誉 \n[92D2FF]积分：[-]6~15         [92D2FF]奖励：[-]1500荣誉 \n[92D2FF]积分：[-]16~31       [92D2FF]奖励：[-]2000荣誉 \n[92D2FF]积分：[-]32~47       [92D2FF]奖励：[-]2500荣誉 \n[92D2FF]积分：[-]48~95       [92D2FF]奖励：[-]3000荣誉 \n[92D2FF]积分：[-]96+           [92D2FF]奖励：[-]4000荣誉\n\n小提示：幻境荣誉将自动兑换幻境宝箱 ",
  InDifferBattleScoreHelpMonth = "[92D2FF]积分：[-]0~5           [92D2FF]评价：[-][FFFFFF]普通[-] \n[92D2FF]积分：[-]6~15         [92D2FF]评价：[-][64db00]一般[-] \n[92D2FF]积分：[-]16~31       [92D2FF]评价：[-][11adf6]良好[-] \n[92D2FF]积分：[-]32~47       [92D2FF]评价：[-][aa62fc]优秀[-] \n[92D2FF]积分：[-]48~95       [92D2FF]评价：[-][ff578c]卓越[-] \n[92D2FF]积分：[-]96+           [92D2FF]评价：[-][ff8f06]最佳[-]\n\n[C8FF00]月度赛奖励：[-]\n[92D2FF]积分：[-]0~5           [92D2FF]奖励：[-]4000荣誉 \n[92D2FF]积分：[-]6~15         [92D2FF]奖励：[-]6000荣誉 \n[92D2FF]积分：[-]16~31       [92D2FF]奖励：[-]8000荣誉 \n[92D2FF]积分：[-]32~47       [92D2FF]奖励：[-]10000荣誉 \n[92D2FF]积分：[-]48~95       [92D2FF]奖励：[-]12000荣誉 \n[92D2FF]积分：[-]96+           [92D2FF]奖励：[-]16000荣誉\n\n小提示：幻境荣誉将自动兑换幻境宝箱 ",
  BeautyPageantVoteItem = "[FF69B4][url=openwnd:红粉佳人, ItemTips, \"Item\", nil, 4692][-]获得途径[FFFE0D]（只限活动期间）[-]\n\n[C8FF00]每日目标100活跃[-]        [92D2FF]附赠：[-]    1朵\n[C8FF00]购买0.99美元礼包[-]               [92D2FF]附赠：[-]    1朵\n[C8FF00]购买1.99美元礼包[-]               [92D2FF]附赠：[-]    2朵\n[C8FF00]购买2.99美元礼包[-]               [92D2FF]附赠：[-]    3朵\n[C8FF00]购买7日元宝大礼[-]         [92D2FF]附赠：[-]  18朵\n[C8FF00]购买30日元宝大礼[-]       [92D2FF]附赠：[-]  30朵\n[C8FF00]兑换黎饰[-]                    [92D2FF]附赠：[-]  34朵\n[C8FF00]充值0.99美元[-]                     [92D2FF]附赠：[-]    2朵\n[C8FF00]充值4.99美元[-]                   [92D2FF]附赠：[-]  10朵\n[C8FF00]充值9.99美元[-]                   [92D2FF]附赠：[-]  33朵\n[C8FF00]充值19.99美元[-]                 [92D2FF]附赠：[-]  66朵\n[C8FF00]充值49.99美元[-]                 [92D2FF]附赠：[-]110朵\n[C8FF00]充值99.99美元[-]                 [92D2FF]附赠：[-]216朵\n\n提示：每个途径可重复获得[FF69B4][url=openwnd:红粉佳人, ItemTips, \"Item\", nil, 4692][-] ",
  Lottery = "[FF69B4][url=openwnd:盟主的馈赠, ItemTips, \"Item\", nil, 6144][-]获得途径[FFFE0D][-]\n\n[C8FF00]每次购买/领取 0.99美元礼包[-]    [92D2FF]附赠：[-] 1张\n[C8FF00]每次购买/领取 1.99美元礼包[-]    [92D2FF]附赠：[-] 1张\n[C8FF00]每次购买/领取 2.99美元礼包[-]    [92D2FF]附赠：[-] 2张\n[C8FF00]每天领取7日元宝大礼[-]       [92D2FF]附赠：[-] 1张\n[C8FF00]每天领取30日元宝大礼[-]     [92D2FF]附赠：[-] 1张\n\n提示：\n·每个途径可重复获得\n·每周平均最多可获得[C8FF00]42[-]张",
  WeddingWelcome = "婚礼正式开始前迎接宾客，新郎和新娘可以向好友、家族成员派发请柬\n\n[FFFE0D]建议婚礼举办前提前通知亲朋好友哦[-] ",
  WeddingPromise = "爱是包容、关怀、今生，爱他/她就大声说出来，向世界宣誓你们的爱\n\n[FFFE0D]你们的爱情誓言将永久记录在婚书上[-] ",
  WeddingCeremony = "成婚：一拜天地，二拜高祖，夫妻对拜\n\n[FFFE0D]完成拜堂后获得夫妻称号、婚书、婚戒[-] ",
  WeddingFirecracker = "开心婚礼大爆竹，新人、宾客齐跳舞、观礼花、祝福新人新婚快乐",
  WeddingConcentricFurit = "夫妻心心相印，1秒内同食同心果，宾客呐喊加油，其乐融融",
  WeddingTableFood = "婚宴酒席，喝喜酒，贺新人，其乐融融",
  WeddingCandy = "新郎、新娘派发喜糖，分享新婚喜悦",
  WeddingTourMap = "新娘、新娘的花轿队伍游襄阳城，江湖人士齐齐来贺，跟随花轿还有机会获得喜糖\n\n[FFFE0D]襄阳城还会换上婚礼装饰，并且奏响欢快的婚礼音乐[-] ",
  MarriageMDRewards_0 = "已领完全部纪念日奖励\n",
  MarriageMDRewards_1 = "[92D2FF]以下是你们[FFFE0D]成婚1个月[-]纪念日的奖励：[-]\n\n[ff8f06][url=openwnd:金童, ItemTips, \"Item\", nil, 5239]、[url=openwnd:玉女, ItemTips, \"Item\", nil, 5240][-] "
}
tbUi.tbSpecilFuncs = {
  TS_CustomTaskRewards = function(self, tbArgs)
    local nTeacherRewards = tbArgs.nTeacherRewards or 0
    local nStudentRewards = tbArgs.nStudentRewards or 0
    local nCurTeacherRewards = tbArgs.nCurTeacherRewards or 0
    local nCurStudentRewards = tbArgs.nCurStudentRewards or 0
    local nCurFinished = tbArgs.nCurFinished or 0
    local szDesc = "完成师父布置的%d个任务后双方可得奖励\n[92D2FF]师父奖励：[-][FFFE0D]%d名望[-]\n[92D2FF]徒弟奖励：[-][ff4cfd]%d经验[-]\n\n当前徒弟已完成%d个任务，预计可得奖励\n[92D2FF]师父奖励：[-][FFFE0D]%d名望[-]\n[92D2FF]徒弟奖励：[-][ff4cfd]%d经验[-]\n\n小提示：\n·徒弟经验奖励随等级的提升而增加\n·师父奖励每周以完成任务数最多的2个徒弟计算 "
    return string.format(szDesc, TeacherStudent.Def.nCustomTaskCount, nTeacherRewards, nStudentRewards, nCurFinished, nCurTeacherRewards, nCurStudentRewards)
  end,
  TS_CustomTaskRewardsNone = function(self, tbArgs)
    local nTeacherRewards = tbArgs.nTeacherRewards or 0
    local nStudentRewards = tbArgs.nStudentRewards or 0
    local szDesc = "完成师父布置的%d个任务后双方可得奖励\n[92D2FF]师父奖励：[-][FFFE0D]%d名望[-]\n[92D2FF]徒弟奖励：[-][ff4cfd]%d经验[-]\n\n小提示：\n·徒弟经验奖励随等级的提升而增加\n·师父奖励每周以完成任务数最多的2个徒弟计算 "
    return string.format(szDesc, TeacherStudent.Def.nCustomTaskCount, nTeacherRewards, nStudentRewards)
  end
}
function tbUi:GetText(szKey, tbArgs)
  if self.tbSpecilFuncs[szKey] then
    return self.tbSpecilFuncs[szKey](self, tbArgs)
  end
  return self.tbSpecilKeys[szKey]
end
function tbUi:OnOpen(szDesc, bShowArrow, szKey, tbArgs)
  local szDescTemp = self:GetText(szKey or "", tbArgs)
  if szDescTemp then
    szDesc = szDescTemp
  end
  self.pPanel:SetActive("Arrow", bShowArrow and true or false)
  self.Description:SetLinkText(szDesc)
end
function tbUi:OnScreenClick(szClickUi)
  Ui:CloseWindow(self.UI_NAME)
end
