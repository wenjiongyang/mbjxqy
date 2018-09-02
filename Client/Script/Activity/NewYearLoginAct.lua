local tbNewYearLoginAct = Activity:GetUiSetting("NewYearLoginAct")
tbNewYearLoginAct.nShowLevel = 1
tbNewYearLoginAct.szTitle = "周年庆感恩回馈"
tbNewYearLoginAct.nBottomAnchor = -50
function tbNewYearLoginAct.FuncContent(tbData)
  local tbTime1 = os.date("*t", tbData.nStartTime)
  local tbTime2 = os.date("*t", tbData.nEndTime + 1)
  local szContent = "\n    一年前，我们一起踏上无忧岛，探索剑侠情缘的未知江湖；一年里，数以万计的侠士加入了我们，剑侠因你们的加入而情缘未了；一年后，回想我们一起奋斗的家族，一起暧昧的情缘，一起欢乐的师徒……\n    周年庆活动期间，只要登录游戏即可获得丰厚奖励。剑侠的江湖，等着你和你的伙伴们。"
  return string.format("活动时间：[c8ff00]%d年%d月%d日%d点-%d月%d日%d点[-]\n%s", tbTime1.year, tbTime1.month, tbTime1.day, tbTime1.hour, tbTime2.month, tbTime2.day, tbTime2.hour, szContent)
end
tbNewYearLoginAct.tbSubInfo = {
  {
    szType = "Item2",
    szInfo = "活动一     感恩回馈，登录有奖\n     活动期间，[FFFE0D]40级[-]以上侠士每日均可领取奖励[-]！若当天未登录，活动结束前可花费元宝补领。",
    szBtnText = "去领奖",
    szBtnTrap = "[url=openwnd:text, LoginAwardsPanel, true]"
  },
  {
    szType = "Item2",
    szInfo = "活动二     周年庆典，活跃无限\n     活动期间，通过登录领奖领取[FFFE0D]糕点·不忘初心[-]，使用后可获得[FFFE0D]20点活跃度[-]，[FFFE0D]有效期24小时[-]！"
  }
}
function tbNewYearLoginAct.fnCustomCheckRP(tbData)
  if me.nLevel < LoginAwards.NEWYEAR_ACT_LEVEL then
    return
  end
  local nDayIdx = LoginAwards:GetCurDayIdx(tbData.tbCustomInfo.nStartTime)
  for i = 1, nDayIdx do
    local nSaveKey, nFlagIdx = LoginAwards:GetSaveInfo(i, tbData.tbCustomInfo.nAwardFlag)
    local nFlag = me.GetUserValue(tbData.tbCustomInfo.nGroup, nSaveKey)
    if KLib.GetBit(nFlag, nFlagIdx) == 0 then
      return true
    end
  end
end
