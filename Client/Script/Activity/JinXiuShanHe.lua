local tbAct = Activity:GetUiSetting("JinXiuShanHe")
tbAct.nShowLevel = 20
tbAct.szTitle = "国庆·锦绣山河"
tbAct.szUiName = "Normal"
tbAct.szContent = "[FFFE0D]国庆“锦绣山河”收集活动开始了！[-]\n\n通过收集中国地名组成的34张地域卡片，按照完成度排行，活动结束时获得高额奖励。\n[FFFE0D]活动时间：[-]%s~%s\n[FFFE0D]参与等级：[-]%d级\n\n[FFFE0D]1、锦绣山河卡[-]\n    活动期间领取[FFFE0D]每日目标[-]奖励或购买任意[FFFE0D]每日礼包[-]（限定获得1张）时，能获得活动道具[11adf6][url=openwnd:锦绣山河卡, ItemTips, \"Item\", nil, 3029][-]，该道具需要点击使用来“[FFFE0D]鉴定[-]”。\n    鉴定后会获得任意一张“[FFFE0D]地域卡片[-]”，如[11adf6][url=openwnd:锦绣山河·台, ItemTips, \"Item\", nil, 3031][-]。地域卡片的名字由我国各省、直辖市、自治区及特别行政区的名字简称组成。\n    使用地域卡片后，其会被加入收集册[11adf6][url=openwnd:锦绣山河集, ItemTips, \"Item\", nil, 3065][-]，通过比较收集册的[FFFE0D]完成度[-]来进行排行，活动结束时按照排名给予奖励。\n    注：每天最多鉴定5张“锦绣山河卡”。\n[FFFE0D]2、神州卡[-]\n    鉴定“锦绣山河卡”时一定几率获得[11adf6][url=openwnd:神州卡, ItemTips, \"Item\", nil, 3030][-]，使用后能获得“锦绣山河集”中还[FFFE0D]未收集到[-]的地域卡片。若已收集满，则随机获得任意地域卡片。\n[FFFE0D]3、活动奖励[-]\n    活动结束时根据排行发放奖励，奖励如下：\n    第1名：60个蓝水晶，橙色永久称号“知天晓地”\n    第2~10名：40个蓝水晶，粉色永久称号“华夏万事通”\n    第11~30名：35个蓝水晶，紫色永久称号“心有丘壑”\n    第31~100名：30个蓝水晶\n    第101~200名：25个蓝水晶\n    第201~300名：20个蓝水晶\n    第301~500名：16个蓝水晶\n    第501~1000名：12个蓝水晶\n    第1001~1500名：10个蓝水晶\n    第1500+名：8个蓝水晶\n"
function tbAct.FnCustomData(szKey, tbData)
  local szStart = Lib:TimeDesc10(tbData.nStartTime)
  local szEnd = Lib:TimeDesc10(tbData.nEndTime)
  return {
    string.format(tbAct.szContent, szStart, szEnd, tbAct.nShowLevel)
  }
end
