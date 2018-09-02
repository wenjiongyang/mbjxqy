local tbWomensDay = Activity:GetUiSetting("WomensDay")
tbWomensDay.nShowLevel = 20
tbWomensDay.szTitle = "三月八号女侠节"
tbWomensDay.nBottomAnchor = -50
function tbWomensDay.FuncContent(tbData)
  local tbTime1 = os.date("*t", tbData.nStartTime)
  local tbTime2 = os.date("*t", tbData.nEndTime + 1)
  local szContent = "\n    诸位侠士，如今三月八号将近，江湖中的诸位男性侠士固然武功卓绝，令人钦佩，然而咱们武林中不少女侠同样是巾帼不让须眉，声名远播。今日，便是这些女侠们的节日！"
  return string.format("活动时间：[c8ff00]%d年%d月%d日%d点-%d月%d日%d点[-]\n%s", tbTime1.year, tbTime1.month, tbTime1.day, tbTime1.hour, tbTime2.month, tbTime2.day, tbTime2.hour, szContent)
end
tbWomensDay.tbSubInfo = {
  {
    szType = "Item2",
    szInfo = "活动一     女侠带你闯天关\n     活动期间，男性角色进行[FFFE0D]组队秘境、凌绝峰、山贼秘窟、惩恶任务[-]时，与[FFFE0D]女性好友[-]获得[FFFE0D]10倍亲密度[-]；若是女性角色，则与[FFFE0D]队伍中好友[-]获得[FFFE0D]10倍亲密度[-]；若侠士上述四项活动[FFFE0D]全部次数[-]均达成[FFFE0D]10倍亲密度[-]条件，还将额外获得[FFFE0D]999贡献[-]！",
    szBtnText = "前往",
    szBtnTrap = "[url=openwnd:text, CalendarPanel]"
  },
  {
    szType = "Item2",
    szInfo = "活动二     女侠虽美亦爱花\n     再英姿飒爽的女侠，也抵不过万紫千红的鲜花的芬芳。活动期间，每天[FFFE0D]前9次赠送[-] [aa62fc][url=openwnd:99朵玫瑰花, ItemTips, 'Item', nil, 2180] [-]，将额外获得[64db00] [url=openwnd:女侠的青睐, ItemTips, 'Item', nil, 3914] [-]，女侠虽美，不免爱花，可不要忘记为你心仪的女侠时常送上花朵噢！",
    szBtnText = "前往",
    szBtnTrap = "[url=openwnd:test, CommonShop,'Treasure', 'tabAllShop']"
  }
}
