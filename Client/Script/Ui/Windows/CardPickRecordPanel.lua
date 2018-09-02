local tbUi = Ui:CreateClass("CardPickRecordPanel")
local szCardPickProbTip = "\n[73cbd5]1)同伴招募-银两购买[-]\n招募[ff42c7]A级[-]同伴概率：[c8ff00]5%[-]\n招募[42ccff]B级[-]同伴概率：[c8ff00]27.5%[-]\n招募[42ff58]C级[-]同伴概率：[c8ff00]67.5%[-]\n\n[73cbd5]2)同伴招募-元宝购买[-]\n招募[ff5f63]S级[-]同伴概率：[c8ff00]1%[-]\n招募[ff42c7]A级[-]同伴概率：[c8ff00]12.5%[-]\n招募[42ccff]B级[-]同伴概率：[c8ff00]30.61%[-]\n招募洗髓丹的概率：[c8ff00]55.89%[-]\n[73cbd5]除此之外游戏内设定每十次招募必出S级或S级以上同伴，此次招募概率如下：[-]\n招募[ffa23e]SS级[-]同伴概率：[c8ff00]8%[-]\n招募[ff5f63]S级[-]同伴概率：[c8ff00]92%[-]\n\n[73cbd5]3)摇钱树[-]\n普通摇钱概率：[c8ff00]72%[-]\n双倍暴击概率：[c8ff00]24%[-]\n十倍暴击概率：[c8ff00]4%[-]\n\n[73cbd5]4)黄金宝箱[-]\n开出银两概率约为：[c8ff00]20%[-]\n开出2阶传承装备的概率为：[c8ff00]20%[-]\n开出3阶传承装备的概率为：[c8ff00]10%[-]\n开出4阶传承装备碎片的概率为：[c8ff00]24%[-]\n开出5阶传承装备碎片的概率为：[c8ff00]12%[-]\n开出6阶传承装备碎片的概率为：[c8ff00]10%[-]\n开出7阶传承装备碎片的概率为：[c8ff00]6%[-]\n开出8阶传承装备碎片的概率为：[c8ff00]4.8%[-]\n开出9阶传承装备碎片的概率为：[c8ff00]4.2%[-]\n开出10阶传承装备碎片的概率为：[c8ff00]3%[-]\n开出1级魂石的概率约为：[c8ff00]10%[-]\n开出2级魂石的概率约为：[c8ff00]2%[-]\n开出3级魂石的概率约为：[c8ff00]0.6%[-]\n开出4级魂石的概率约为：[c8ff00]0.1%[-]\n\n[73cbd5]5)每日礼包-0.99美元礼包[-]\n必然获得白水晶*6、20元宝、2000银两、黄金宝箱。\n开出头衔令牌概率约为：[c8ff00]0.2%[-]\n开出稀有装备概率约为：[c8ff00]0.5%[-]\n开出随机魂石概率约为：[c8ff00]0.8%[-]\n\n[73cbd5]6)每日礼包-1.99美元礼包[-]\n[73cbd5]开放69级上限前：[-]\n必然获得白水晶*6、随机1级魂石*1、洗髓丹*1、30元宝、200贡献。\n开出头衔令牌概率约为：[c8ff00]0.2%[-]\n开出稀有装备概率约为：[c8ff00]0.5%[-]\n开出随机魂石概率约为：[c8ff00]0.8%[-]\n[73cbd5]开放69级上限后：[-]\n必然获得绿水晶*2、元气道具*1、30元宝、200贡献。\n开出头衔令牌概率约为：[c8ff00]0.1%[-]\n开出稀有装备概率约为：[c8ff00]0.1%[-]\n开出随机魂石概率约为：[c8ff00]0.15%[-]\n\n[73cbd5]7)每日礼包-2.99美元礼包[-]\n[73cbd5]开放79级上限前：[-]\n必然获得随机2级魂石*1、60元宝、500贡献。\n开出头衔令牌概率约为：[c8ff00]0.2%[-]\n开出稀有装备概率约为：[c8ff00]0.5%[-]\n开出随机魂石概率约为：[c8ff00]0.8%[-]\n[73cbd5]开放79级上限至开放99级上限前：[-]\n必然获得元气道具*1、蓝水晶*1、60元宝、400贡献。\n开出头衔令牌概率约为：[c8ff00]0.6%[-]\n开出稀有装备概率约为：[c8ff00]0.08%[-]\n开出随机魂石概率约为：[c8ff00]1.2%[-]\n[73cbd5]开放99级上限后：[-]\n必然获得元气道具*1、蓝水晶*1、60元宝、任务卷轴*1、黄金宝箱*2。\n开出头衔令牌概率约为：[c8ff00]0.2%[-]\n开出稀有装备概率约为：[c8ff00]0.01%[-]\n开出随机魂石概率约为：[c8ff00]0.6%[-]\n\n"
function tbUi:OnOpen(szType)
  if szType == "History" then
    CardPicker:Ask4CardPickHistory()
  end
end
function tbUi:OnOpenEnd(szType)
  self.szType = szType
  self:Update()
end
function tbUi:Update()
  if self.szType ~= "History" then
    self.pPanel:Label_SetText("Title", "随机概率公示")
    self.pPanel:Label_SetText("Content", szCardPickProbTip)
    self.pPanel:Label_SetText("Tip", "")
  else
    local szHistory = CardPicker:GetLatestPickHistory()
    self.pPanel:Label_SetText("Title", "本服招募记录")
    self.pPanel:Label_SetText("Content", szHistory)
    self.pPanel:Label_SetText("Tip", "＊招募记录只显示最近50条。")
  end
  local tbTextSize = self.pPanel:Label_GetPrintSize("Content")
  local tbSize = self.pPanel:Widget_GetSize("datagroup")
  self.pPanel:Widget_SetSize("datagroup", tbSize.x, tbTextSize.y + 50)
  self.pPanel:DragScrollViewGoTop("datagroup")
  self.pPanel:UpdateDragScrollView("datagroup")
end
function tbUi:RegisterEvent()
  local tbRegEvent = {
    {
      UiNotify.emNOTIFY_CARD_PICKING,
      self.Update
    }
  }
  return tbRegEvent
end
tbUi.tbOnClick = tbUi.tbOnClick or {}
function tbUi.tbOnClick:BtnClose()
  Ui:CloseWindow(self.UI_NAME)
end
