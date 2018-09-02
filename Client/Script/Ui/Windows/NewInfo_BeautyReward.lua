local tbUi = Ui:CreateClass("NewInfo_BeautyReward")
tbUi.szContent = "[FFFE0D]「武林第一美女评选」[-]评选期间（%s~%s），累计赠送[FF69B4][url=openwnd:红粉佳人, ItemTips, \"Item\", nil, 4692][-]达到以下数量可以领取奖励：\n                                                  [FF69B4]剑侠多佳人，美者颜如玉。\n                                                  一笑倾人城，再笑倾人国。[-] "
function tbUi:OnOpen(tbData)
  local tbAct = Activity.BeautyPageant
  local _, tbActData = Activity:GetActUiSetting("BeautyPageant")
  local szStartTime = Lib:TimeDesc10(tbActData.nStartTime)
  local szEndTime = Lib:TimeDesc10(tbActData.nEndTime)
  local tbFinalTime = tbAct.STATE_TIME[tbAct.STATE_TYPE.FINAL]
  local szContent = string.format(self.szContent, szStartTime, Lib:TimeDesc10(tbFinalTime[2] + 1))
  self.DetailsBeauty:SetLinkText(szContent)
  self:UpdateAwardInfo()
end
function tbUi:OnSubPanelNotify(nEvent, pParent, bHaveAward)
  if UiNotify.emNOTIFY_BEAUTY_VOTE_AWARD == nEvent then
    if not bHaveAward then
      pParent:Update()
      Activity:CheckRedPoint()
    else
      self:UpdateAwardInfo()
    end
  end
end
function tbUi:UpdateAwardInfo()
  local tbAct = Activity.BeautyPageant
  self.tbAwardList = {}
  for nIndex, tbAwardInfo in ipairs(tbAct.tbVotedAward) do
    local tbAward, nCanGet, nGotCount, bIsShow = tbAct:GetVotedAward(me, nIndex)
    if bIsShow then
      table.insert(self.tbAwardList, {
        tbAward = tbAward,
        nCanGet = nCanGet,
        nGotCount = nGotCount,
        tbInfo = tbAwardInfo,
        nIndex = nIndex
      })
    end
  end
  local fnSort = function(a, b)
    if a.tbInfo.nMaxCount < 0 or b.tbInfo.nMaxCount < 0 then
      return a.tbInfo.nMaxCount < b.tbInfo.nMaxCount
    elseif 0 < a.nCanGet and 0 < b.nCanGet then
      return a.tbInfo.nNeedCount < b.tbInfo.nNeedCount
    elseif 0 >= a.nCanGet and 0 >= b.nCanGet then
      if 0 >= a.nGotCount and 0 >= b.nGotCount or 0 < a.nGotCount and 0 < b.nGotCount then
        return a.tbInfo.nNeedCount < b.tbInfo.nNeedCount
      else
        return a.nGotCount < b.nGotCount
      end
    else
      return a.nCanGet > b.nCanGet
    end
  end
  table.sort(self.tbAwardList, fnSort)
  local nVotedCount = tbAct:GetVotedCount(me)
  local function fnSetItem(itemObj, index)
    local tbAwardInfo = self.tbAwardList[index]
    local szCondition = ""
    if tbAwardInfo.tbInfo.nMaxCount > 0 then
      szCondition = string.format("累计赠送%d朵", tbAwardInfo.tbInfo.nNeedCount)
    else
      szCondition = string.format("每赠送1朵获得%d元气", tbAwardInfo.tbInfo.tbAward[2])
    end
    itemObj.pPanel:Label_SetText("MarkTxt", szCondition)
    itemObj.itemframe:SetGenericItem(tbAwardInfo.tbAward)
    itemObj.itemframe.fnClick = itemObj.itemframe.DefaultClick
    if 0 >= tbAwardInfo.nCanGet then
      if tbAwardInfo.tbInfo.nMaxCount > 0 then
        itemObj.pPanel:SetActive("BtnGet", false)
        if 0 >= tbAwardInfo.nGotCount then
          itemObj.pPanel:SetActive("Bar", true)
          itemObj.pPanel:SetActive("AlreadyGet", false)
          itemObj.pPanel:Label_SetText("BarTxt", string.format("%d/%d", nVotedCount, tbAwardInfo.tbInfo.nNeedCount))
          itemObj.pPanel:Sprite_SetFillPercent("Bar", math.min(1, nVotedCount / tbAwardInfo.tbInfo.nNeedCount))
        else
          itemObj.pPanel:SetActive("Bar", false)
          itemObj.pPanel:SetActive("AlreadyGet", true)
        end
      else
        itemObj.pPanel:SetActive("Bar", false)
        itemObj.pPanel:SetActive("AlreadyGet", false)
        itemObj.pPanel:SetActive("BtnGet", true)
        itemObj.pPanel:Button_SetEnabled("BtnGet", false)
      end
    else
      itemObj.pPanel:SetActive("BtnGet", true)
      itemObj.pPanel:Button_SetEnabled("BtnGet", true)
      itemObj.pPanel:SetActive("Bar", false)
      itemObj.pPanel:SetActive("AlreadyGet", false)
      function itemObj.BtnGet.pPanel.OnTouchEvent()
        RemoteServer.BeautyPageantVotedAwardReq(tbAwardInfo.nIndex)
      end
    end
  end
  self.ScrollViewBeautyReward:Update(self.tbAwardList, fnSetItem)
end
tbUi.tbOnClick = tbUi.tbOnClick or {}
function tbUi.tbOnClick:BtnGive()
  local nCount, _ = me.GetItemCountInAllPos(Activity.BeautyPageant.VOTE_ITEM)
  if nCount <= 0 then
    local szMsg = "红粉佳人数量不足，可通过充值任意金额获得"
    me.Msg(szMsg)
    me.CenterMsg(szMsg)
    Ui:OpenWindow("CommonShop", "Recharge")
  else
    Ui:OpenWindow("BeautyCompetitionPanel")
  end
end
