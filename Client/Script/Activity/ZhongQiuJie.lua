local tbAct = Activity:GetUiSetting("ZhongQiuJie")
tbAct.nShowLevel = 20
tbAct.szTitle = "中秋节"
tbAct.szUiName = "Normal"
tbAct.szContent = "[FFFE0D]中秋佳节倍思亲[-]\n\n[FFFE0D]活动时间：[-]%s~%s\n[FFFE0D]参加条件：[-]等级达到%d级\n\n    中秋节是中国的传统佳节。根据史籍的记载，“中秋”一词最早出现在《周礼》一书中。到魏晋时，有“谕尚书镇牛淆，中秋夕与左右微服泛江”的记载。直到唐朝初年，中秋节才成为固定的节日。\n\n[FFFE0D]1、月饼寄相思[-]\n    月饼香甜，寓意家人团员，寄托了美好的思念。活动期间，完成[FFFE0D]每日目标[-]可能获得[11adf6][url=openwnd:精制面团, ItemTips, \"Item\", nil, 2872][-]，[11adf6][url=openwnd:月饼馅, ItemTips, \"Item\", nil, 2873][-]，[11adf6][url=openwnd:蛋黄液, ItemTips, \"Item\", nil, 2874][-]三种月饼制作原料。通过消耗三种原料可制作出中秋月饼：[11adf6][url=openwnd:月满西楼, ItemTips, \"Item\", nil, 2876][-]、[11adf6][url=openwnd:彩云追月, ItemTips, \"Item\", nil, 2877][-]、[11adf6][url=openwnd:沧海月明, ItemTips, \"Item\", nil, 2878][-]。\n\n2、中秋答题\n    活动期间，在[FFFE0D]家族属地[-]中会出现“[FFFE0D]中秋使者[-]”，每天可以进行一次答题。根据答题正确数和耗费的时间进行排行并获得奖励。\n    每天[FFFE0D]4点[-]答题参与次数重置，答题截止时间为当天24点。\n    答题排行榜每日24点结算。\n    每题有[FFFE0D]30秒[-]的回答时间，超时视为回答错误。\n    若答题中途关闭答题界面，当前题目的计时不会中断。\n"
function tbAct.FnCustomData(szKey, tbData)
  local szStart = Lib:TimeDesc10(tbData.nStartTime)
  local szEnd = Lib:TimeDesc10(tbData.nEndTime)
  return {
    string.format(tbAct.szContent, szStart, szEnd, Activity.ZhongQiuJie.JOIN_LEVEL)
  }
end
