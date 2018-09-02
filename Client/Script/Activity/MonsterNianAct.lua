local tbAct = Activity:GetUiSetting("MonsterNianAct")
tbAct.nShowLevel = 10
tbAct.szTitle = "年兽来袭"
tbAct.szUiName = "Normal"
tbAct.szContent = "[FFFE0D]新年驱逐年兽活动开始了！[-]\n\n[FFFE0D]活动时间：[-]%s~%s\n[FFFE0D]参与等级：[-]20级\n\n    年兽又称年，是古代汉族神话传说中的恶兽。相传古时候每到年末的午夜，年兽就会进攻村庄，大肆破坏。后来人们发现年兽惧怕红色及放鞭炮，故以此驱赶年兽的进攻。为了防止年兽的再次骚扰，放爆竹、贴春联渐渐成为节日习俗，春节由此成为中华民族的象征之一，潜移默化地沿袭至今以及影响世界各地。\n    活动期间，家族烤火时会在[FFFE0D]家族属地[-]中出现捣乱的[FFFE0D]年兽[-]，其有上古戾气护体，传言只能通过燃放[FFFE0D]烟花[-]对其造成有效伤害。\n    当年兽血量达到[FFFE0D]70%%[-]，[FFFE0D]40%%[-]，[FFFE0D]0%%[-]时，会在附近出现宝箱，但每人每天最多可以采集[FFFE0D]10个[-]宝箱。\n    活动结束后，年兽掉落的宝物会在家族中进行拍卖，参与驱逐年兽活动的玩家能获得[FFFE0D]拍卖分红[-]。\n    年兽活动期间，家族答题将暂停，同时烤火经验在家族属地[FFFE0D]全地图[-]均可获得。\n"
function tbAct.FnCustomData(szKey, tbData)
  local szStart = Lib:TimeDesc10(tbData.nStartTime)
  local szEnd = Lib:TimeDesc10(tbData.nEndTime)
  return {
    string.format(tbAct.szContent, szStart, szEnd)
  }
end
