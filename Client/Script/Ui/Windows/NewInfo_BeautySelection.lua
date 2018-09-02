local tbUi = Ui:CreateClass("NewInfo_BeautySelection")
tbUi.szLocalContent = "[FFFE0D]「武林第一美女评选」[-]活动开始了！各阶段规则请看以下介绍：\n\n[FFFE0D]【报名阶段】[-]\n[FFFE0D]阶段时间：[-]%s ~ %s\n[FFFE0D]等级要求：[-]等级达到[FFFE0D]%d级[-]\n[FFFE0D]报名条件：[-]女性玩家[FFFE0D]（游戏中男女性角色均可报名）[-]\n    前往襄阳城[00ff00] [url=npc:「选美大会司仪」紫轩, 622, 10][-]处报名参赛，报名需要上传[FFFE0D]本人真实的照片及其他信息[-]，报名成功后资料会进入待审核状态，如果提交的资料涉及违规，将不会通过审核，需要重新提交资料再次报名。若资料审核通过则表示成功报名参赛，并且会通过邮件发放[ff8f06][url=openwnd:选美宣传单, ItemTips, \"Item\", nil, 4691][-]，可以通过它在任意聊天频道宣传本人的选美信息，或打开自己的参赛页面。\n\n[FFFE0D]【海选赛（本服评选）】[-]\n[FFFE0D]阶段时间：[-]%s ~ %s\n[FFFE0D]票选对象：[-]本服成功报名参赛的佳人\n    此阶段，玩家可以通过消耗[FF69B4][url=openwnd:红粉佳人, ItemTips, \"Item\", nil, 4692][-]道具给心目中的女神进行投票。[FFFE0D]每消耗1朵，被投佳人票数+1[-]。通过该道具可以打开投票页面，或者点击主屏幕的“美女评选”图标进入投票页面。\n    [FFFE0D]%s[-]将按票数排名评选出海选赛十强佳人，其中票数排名第一名的佳人评为[FF69B4]「本服第一美女」[-]，票数排名前十名的佳人评为[FF69B4]「本服十大美女」[-]，且每个服务器最终排名[FFFE0D]前3名[-]的佳人自动入围[FFFE0D]决赛（跨服评选）[-]。\n    [00FF00][url=openwnd:查看【红粉佳人】获得途径, AttributeDescription, '', false, 'BeautyPageantVoteItem'][-]\n\n[FFFE0D]海选赛奖励[-] "
tbUi.szFinalContent = "\n[FFFE0D]【决赛（跨服评选）】[-]\n[FFFE0D]阶段时间：[-]%s ~ %s\n[FFFE0D]票选对象：[-]入围决赛的佳人\n    每个服务器海选赛[FFFE0D]前3名[-]的佳人自动入围决赛阶段，决赛阶段的投票方式与海选赛相同[FFFE0D]（可以给跨服的佳人投票）[-]。[FFFE0D]%s[-]将按票数排名评选出决赛十强佳人，其中票数排名第一名的佳人评为[FF69B4]「武林第一美女」[-]，票数排名前十名的佳人评为[FF69B4]「武林十大美女」[-]。\n\n[FFFE0D]决赛奖励[-] "
local MAX_SHOW_AWARD = 10
function tbUi:OnOpen(tbData)
  local tbAct = Activity.BeautyPageant
  local tbSignUpTime = tbAct.STATE_TIME[tbAct.STATE_TYPE.SIGN_UP]
  local tbLocalTime = tbAct.STATE_TIME[tbAct.STATE_TYPE.LOCAL]
  local tbFinalTime = tbAct.STATE_TIME[tbAct.STATE_TYPE.FINAL]
  local szContent = string.format(self.szLocalContent, Lib:TimeDesc10(tbSignUpTime[1]), Lib:TimeDesc10(tbLocalTime[2] + 1), tbAct.LEVEL_LIMIT, Lib:TimeDesc10(tbLocalTime[1]), Lib:TimeDesc10(tbLocalTime[2] + 1), Lib:TimeDesc10(tbLocalTime[2] + 1))
  self.Content3:SetLinkText(szContent)
  local szContent = string.format(self.szFinalContent, Lib:TimeDesc10(tbFinalTime[1]), Lib:TimeDesc10(tbFinalTime[2] + 1), Lib:TimeDesc10(tbFinalTime[2] + 1))
  self.Content4:SetLinkText(szContent)
  self:SetWinnerAward(self.BeautyItem1, tbAct.tbLocalWinnerAward[1])
  self:SetWinnerAward(self.BeautyItem2, tbAct.tbLocalWinnerAward[2])
  self:SetWinnerAward(self.BeautyItem3, tbAct.tbParticipateAward)
  self:SetWinnerAward(self.BeautyItem4, tbAct.tbFinalWinnerAward[1])
  self:SetWinnerAward(self.BeautyItem5, tbAct.tbFinalWinnerAward[2])
  self:SetWinnerAward(self.BeautyItem6, tbAct.tbFinalParticipateAward)
  local tbContent3Size = self.pPanel:Label_GetPrintSize("Content3")
  local tbContent4Size = self.pPanel:Label_GetPrintSize("Content4")
  local tbItemGroup1Size = self.pPanel:Widget_GetSize("ItemGroup1")
  local tbItemGroup2Size = self.pPanel:Widget_GetSize("ItemGroup2")
  local tbSize = self.pPanel:Widget_GetSize("datagroup3")
  self.pPanel:Widget_SetSize("datagroup3", tbSize.x, 140 + tbContent3Size.y + tbContent4Size.y + tbItemGroup1Size.y + tbItemGroup2Size.y)
  self.pPanel:DragScrollViewGoTop("datagroup3")
  self.pPanel:UpdateDragScrollView("datagroup3")
end
function tbUi:SetWinnerAward(tbWnd, tbAwardList)
  if tbAwardList then
    tbWnd.pPanel:SetActive("Main", true)
    for i = 1, MAX_SHOW_AWARD do
      local tbAward = tbAwardList[i]
      if tbAward then
        tbWnd["itemframe" .. i].pPanel:SetActive("Main", true)
        tbWnd["itemframe" .. i]:SetGenericItem(tbAward)
        tbWnd["itemframe" .. i].fnClick = tbWnd["itemframe" .. i].DefaultClick
      else
        tbWnd["itemframe" .. i].pPanel:SetActive("Main", false)
      end
    end
  else
    tbWnd.pPanel:SetActive("Main", false)
  end
end
tbUi.tbOnClick = {}
