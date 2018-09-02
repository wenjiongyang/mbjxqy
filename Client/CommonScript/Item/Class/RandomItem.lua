Require("CommonScript/EnvDef.lua")
local tbRandomItem = Item:GetClass("RandomItem")
tbRandomItem.tbItemLogType = {
  [968] = Env.LogWay_FindDungeonAward,
  [2178] = Env.LogWay_RankBattleAward_Rank,
  [2179] = Env.LogWay_RankBattleAward_Rank
}
function tbRandomItem:LoadItemList()
  local szType = "dssddssddddddd"
  local tbTitle = {
    "ClassParamID",
    "Probability",
    "Name",
    "Item",
    "DebtReplaceItem",
    "OtherType",
    "SubType",
    "Amount",
    "Add2Auction",
    "TimeLimit",
    "WorldMsg",
    "FriendMsg",
    "KinMsg",
    "TeamMsg"
  }
  local tbFile = LoadTabFile("Setting/Item/RandomItem.tab", szType, nil, tbTitle)
  if not tbFile then
    Log("[RandomItem] LoadItemList ERR !! Setting/Item/RandomItem.tab can not find !!")
    return
  end
  self.tbItemList = {}
  local tbTotalPro = {}
  for _, tbRow in pairs(tbFile) do
    if tbRow.ClassParamID and tbRow.ClassParamID > 0 then
      tbRow.Probability = tonumber(tbRow.Probability)
      assert(tbRow.Probability, "[RandomItem] Probability is nil !! ClassParamID = " .. tbRow.ClassParamID)
      self.tbItemList[tbRow.ClassParamID] = self.tbItemList[tbRow.ClassParamID] or {
        tbFixedItem = {},
        tbRandomItem = {}
      }
      local tbAward = {}
      tbAward.nProbability = tbRow.Probability
      tbAward.szName = tbRow.Name
      tbAward.nAmount = tbRow.Amount
      tbAward.nTimeLimit = tbRow.TimeLimit
      tbAward.nWorldMsg = tbRow.WorldMsg
      tbAward.nFriendMsg = tbRow.FriendMsg
      tbAward.nKinMsg = tbRow.KinMsg
      tbAward.szOtherType = tbRow.OtherType
      tbAward.nTeamMsg = tbRow.TeamMsg
      tbAward.nAdd2Auction = tbRow.Add2Auction
      tbAward.nDebtReplaceItem = tbRow.DebtReplaceItem
      if tbRow.Item > 0 then
        tbAward.nItem = tbRow.Item
        tbAward.nAmount = math.max(tbAward.nAmount, 1)
      elseif tbRow.SubType and tbRow.SubType ~= "" then
        tbAward.SubType = tonumber(tbRow.SubType) or tbRow.SubType
      end
      if tbRow.Probability > 0 then
        tbTotalPro[tbRow.ClassParamID] = tbTotalPro[tbRow.ClassParamID] or 0
        tbTotalPro[tbRow.ClassParamID] = tbTotalPro[tbRow.ClassParamID] + tbRow.Probability
        assert(tbTotalPro[tbRow.ClassParamID] <= 1000000, "[RandomItem] TotalRate > 100W ClassParamID = " .. tbRow.ClassParamID)
        table.insert(self.tbItemList[tbRow.ClassParamID].tbRandomItem, tbAward)
      elseif tbRow.Probability < 0 then
        table.insert(self.tbItemList[tbRow.ClassParamID].tbFixedItem, tbAward)
      end
    end
  end
end
tbRandomItem.tbAwardType = {}
function tbRandomItem:AddOtherAward(szType, SubType, nCount, nItem)
  if szType == "EquipDebris" then
    if SubType == 0 or SubType == "" then
      SubType = nil
    end
    return {
      szType,
      nItem,
      SubType
    }
  elseif SubType then
    return {
      szType,
      SubType,
      nCount
    }
  else
    return {szType, nCount}
  end
end
function tbRandomItem:GetItemName(tbItem)
  if tbItem.nItem and tbItem.nItem > 0 then
    local tbBaseInfo = KItem.GetItemBaseProp(tbItem.nItem)
    if not tbBaseInfo then
      return tbItem.szName
    end
    if tbItem.nAmount < 2 then
      return tbBaseInfo.szName
    end
    return string.format("%s*%s", tbBaseInfo.szName, tbItem.nAmount)
  end
  local tbMoneyInfo = Shop.tbMoney[tbItem.szOtherType or "nil"]
  if tbMoneyInfo then
    return string.format("%s%s%s", tbMoneyInfo.Name, tbItem.nAmount, tbMoneyInfo.Unit or "")
  end
  return tbItem.szName
end
function tbRandomItem:GetItemValue(nItemTemplateId)
  self.tbItemValueCache = self.tbItemValueCache or {}
  local nValue = self.tbItemValueCache[nItemTemplateId]
  if nValue then
    return nValue
  end
  local tbBaseInfo = KItem.GetItemBaseProp(nItemTemplateId)
  self.tbItemValueCache[nItemTemplateId] = tbBaseInfo and tbBaseInfo.nValue or -1
  return self.tbItemValueCache[nItemTemplateId]
end
function tbRandomItem:AddAward(pPlayer, tbItem, szFromItemName, nLogReazon, nLogReazon2)
  if pPlayer and tbItem.nDebtReplaceItem > 0 and 0 < tbItem.nItem then
    local nValue = Player:GetRewardValueDebt(pPlayer.dwID)
    if nValue > 0 then
      local nOrgValue = self:GetItemValue(tbItem.nItem)
      local nDstValue = self:GetItemValue(tbItem.nDebtReplaceItem)
      if nOrgValue > 0 and nDstValue >= 0 and nOrgValue > nDstValue then
        tbItem = Lib:CopyTB(tbItem)
        local nCostVale = math.floor((nOrgValue - nDstValue) * tbItem.nAmount / 1000)
        Log("[RandomItem] debt ", tbItem.nItem, tbItem.nDebtReplaceItem, nValue, math.min(nValue, nCostVale), nLogReazon, nLogReazon2)
        tbItem.nKinMsg = 0
        tbItem.nTeamMsg = 0
        tbItem.nWorldMsg = 0
        tbItem.nItem = tbItem.nDebtReplaceItem
        Player:CostRewardValueDebt(pPlayer.dwID, nCostVale, nLogReazon, nLogReazon2)
      end
    end
  end
  local tbGetAward, bAdd2Auction
  local szItemName = self:GetItemName(tbItem)
  local nItemId
  if 0 >= (tbItem.nItem or -1) and not self.tbAwardType[tbItem.szOtherType or "nil"] and not Shop.tbMoney[tbItem.szOtherType or "nil"] and not Player.AwardType[tbItem.szOtherType or "nil"] then
    if pPlayer then
      Log("[RandomItem] AddAward ERR ?? tbItem is error !!", pPlayer.szName, pPlayer.dwID, szFromItemName)
      Lib:LogTB(tbItem)
    end
    return
  end
  if tbItem.nItem and 0 < tbItem.nItem and tbItem.szOtherType == "" then
    local szTimeOut
    if tbItem.nTimeLimit and 0 < tbItem.nTimeLimit then
      szTimeOut = os.date("%Y-%m-%d %H:%M:%S", GetTime() + tbItem.nTimeLimit)
    end
    if tbItem.nAdd2Auction == 1 then
      bAdd2Auction = true
    end
    tbGetAward = {
      "item",
      tbItem.nItem,
      tbItem.nAmount,
      szTimeOut
    }
    nItemId = tbItem.nItem
  else
    tbGetAward = self:AddOtherAward(tbItem.szOtherType, tbItem.SubType, tbItem.nAmount, tbItem.nItem)
    if not tbGetAward then
      Log("[RandomItem] AddOtherAward ERR ?? bRet is false !!", pPlayer and pPlayer.dwID or "", szFromItemName, tbItem.szOtherType, tbItem.SubType or "nil", tbItem.nAmount)
      return
    end
  end
  if pPlayer then
    if nItemId then
      szItemName = string.format("<%s>", szItemName)
    end
    if 0 < tbItem.nWorldMsg then
      local szMsg = MsgInfoCtrl:GetMsg(tbItem.nWorldMsg, pPlayer.szName, szFromItemName or "", szItemName)
      if nItemId then
        KPlayer.SendWorldNotify(0, 999, szMsg, 0, 1)
        ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.System, szMsg, nil, {
          nLinkType = ChatMgr.LinkType.Item,
          nTemplateId = nItemId,
          nFaction = pPlayer.nFaction
        })
      else
        KPlayer.SendWorldNotify(0, 999, szMsg, 1, 1)
      end
    end
    if 0 < tbItem.nKinMsg and 0 < pPlayer.dwKinId then
      local szMsg = MsgInfoCtrl:GetMsg(tbItem.nKinMsg, pPlayer.szName, szFromItemName or "", szItemName)
      if nItemId then
        ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.Kin, szMsg, pPlayer.dwKinId, {
          nLinkType = ChatMgr.LinkType.Item,
          nTemplateId = nItemId,
          nFaction = pPlayer.nFaction
        })
      else
        ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.Kin, szMsg, pPlayer.dwKinId)
      end
    end
    if tbItem.nTeamMsg and 0 < tbItem.nTeamMsg and 0 < pPlayer.dwTeamID then
      local szMsg = MsgInfoCtrl:GetMsg(tbItem.nTeamMsg, pPlayer.szName, szFromItemName or "", szItemName)
      if nItemId then
        ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.Team, szMsg, pPlayer.dwTeamID, {
          nLinkType = ChatMgr.LinkType.Item,
          nTemplateId = nItemId,
          nFaction = pPlayer.nFaction
        })
      else
        ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.Team, szMsg, pPlayer.dwTeamID)
      end
    end
  end
  bAdd2Auction = false
  return tbGetAward, bAdd2Auction
end
function tbRandomItem:OnUse(it)
  local nKind = tonumber(it.nRandomItemKindId or KItem.GetItemExtParam(it.dwTemplateId, 1))
  local nRet, szMsg, tbAllAward = self:GetRandItemAward(me, nKind, it.szName, true, it.dwTemplateId)
  if szMsg then
    me.Msg(szMsg)
  end
  Log("[Item] RandomItem OnUse", it.dwTemplateId, it.szName, me.szName, me.szAccount, me.dwID)
  return nRet, tbAllAward
end
function tbRandomItem:RandomItemAward(pPlayer, nKind, szFromItemName, nLogReazon, nLogReazon2)
  if not self.tbItemList[nKind] then
    return 0, "箱子无法打开"
  end
  local nMaxProbability = 1000000
  local nRate = MathRandom(1, nMaxProbability)
  local tbGetAllAward = {}
  local tbAdd2AuctionIndex = {}
  for _, tbItem in ipairs(self.tbItemList[nKind].tbFixedItem) do
    local tbAward, bAdd2Auction = self:AddAward(pPlayer, tbItem, szFromItemName, nLogReazon, nLogReazon2)
    if tbAward then
      table.insert(tbGetAllAward, tbAward)
      if bAdd2Auction then
        table.insert(tbAdd2AuctionIndex, #tbGetAllAward)
      end
    elseif pPlayer then
      Log(string.format(XT("%s随机获得物品失败 箱子：%s，物品：%s"), pPlayer.szName, szFromItemName, tbItem.szName))
    end
  end
  local nRateSum = 0
  for i, tbItem in ipairs(self.tbItemList[nKind].tbRandomItem) do
    nRateSum = nRateSum + tbItem.nProbability
    if nRate <= nRateSum then
      local tbAward, bAdd2Auction = self:AddAward(pPlayer, tbItem, szFromItemName, nLogReazon, nLogReazon2)
      if tbAward then
        table.insert(tbGetAllAward, tbAward)
        if bAdd2Auction then
          table.insert(tbAdd2AuctionIndex, #tbGetAllAward)
        end
        break
      end
      if pPlayer then
        Log(string.format(XT("%s随机获得物品失败 箱子：%s，物品：%s"), pPlayer.szName, szFromItemName, tbItem.szName))
      end
      break
    end
  end
  return 1, nil, tbGetAllAward, tbAdd2AuctionIndex
end
function tbRandomItem:GetFixRandItemAward(nKind)
  if not self.tbItemList[nKind] then
    return 0, "箱子无法打开"
  end
  local tbGetAllAward = {}
  for _, tbItem in ipairs(self.tbItemList[nKind].tbFixedItem) do
    local tbAward, bAdd2Auction = self:AddAward(nil, tbItem, "")
    if tbAward then
      table.insert(tbGetAllAward, tbAward)
    end
  end
  return 1, tbGetAllAward
end
function tbRandomItem:GetRandItemAward(pPlayer, nKind, szFromItemName, bShowUi, nOrgTemplateId)
  if pPlayer.CheckNeedArrangeBag() then
    return 0, "背包道具数量过多，请整理一下！"
  end
  if not self.tbItemList[nKind] then
    return 0, "箱子无法打开"
  end
  local nRet, szMsg, tbGetAllAward, tbAdd2AuctionIndex = self:RandomItemAward(pPlayer, nKind, szFromItemName)
  if nRet == 0 then
    return 0, szMsg
  end
  local LogWayType = Env.LogWay_RandomItem
  if nOrgTemplateId then
    LogWayType = self.tbItemLogType[nOrgTemplateId]
  end
  if pPlayer.ItemLogWay then
    LogWayType = pPlayer.ItemLogWay
    pPlayer.ItemLogWay = nil
  end
  LogWayType = LogWayType or Env.LogWay_RandomItem
  local tbAuctionAward = {}
  if tbAdd2AuctionIndex and next(tbAdd2AuctionIndex) then
    tbGetAllAward, tbAuctionAward = Kin:FormatAuctionItem(tbGetAllAward, tbAdd2AuctionIndex, tbAuctionAward)
    if tbAuctionAward and next(tbAuctionAward) then
      Kin:AddPersonAuction(pPlayer.dwID, tbAuctionAward)
    end
  end
  local tbAllAward = KPlayer:FormatAward(pPlayer, tbGetAllAward, szFromItemName)
  tbAllAward = KPlayer:MgrAward(pPlayer, tbAllAward)
  Lib:CallBack({
    KPlayer.SendAwardUnsafe,
    KPlayer,
    pPlayer.dwID,
    tbAllAward,
    not bShowUi,
    bShowUi == nil or bShowUi and true or false,
    LogWayType,
    nKind
  })
  return 1, szMsg, tbGetAllAward
end
