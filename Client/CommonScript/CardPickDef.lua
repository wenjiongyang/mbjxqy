CardPicker.Def = {
  nFreeGoldPickCdTime = 172800,
  nFreeCoinPickCdTime = 28800,
  nFreeGoldCdTimeFromCreate = 3600,
  OpenLevel = 10,
  nGoldPickResetFubenLevel = 1,
  nGoldPickResetSectionIdx = 2,
  nGoldPickResetSubSectionIdx = 4,
  nCoinPickResetFubenLevel = 1,
  nCoinPickResetSectionIdx = 1,
  nCoinPickResetSubSectionIdx = 4,
  nCoinCost = 20000,
  nCoinTenCost = 180000,
  nGoldCost = 240,
  nGoldTenCost = 1980,
  nVipProbDivide = 10,
  nCurSpecialCountBegin = 20000,
  nGoldTenSpecialCount = 20,
  tbHighVipSpecialPartnerRate = {
    [1] = 0.001,
    [2] = 0.003,
    [3] = 0.006,
    [4] = 0.01,
    [5] = 0.015,
    [6] = 0.02,
    [7] = 0.03,
    [8] = 0.04,
    [9] = 0.06,
    [10] = 0.09,
    [11] = 0.12,
    [12] = 0.18,
    [13] = 0.24,
    [14] = 0.3,
    [15] = 0.4,
    [16] = 0.5,
    [17] = 0.6,
    [18] = 0.7,
    [19] = 0.85,
    [20] = 1
  },
  tbSpecialTenGoldSPartner = {
    szItemType = "Partner",
    nItemId = 13,
    nCount = 1
  },
  tbGoldPickGift = {szItemType = "item", nItemId = 1968},
  tbCoinPickGift = {szItemType = "item", nItemId = 1016},
  CARD_SAVE_GROUP = 87,
  SAVE_GOLD_PICK_COUNT_KEY = 1,
  SAVE_COIN_PICK_COUNT_KEY = 2,
  SAVE_GOLD_PICK_CACHE_BEGIN = 3,
  SAVE_GOLD_PICK_CACHE_END = 22,
  SAVE_FRIST_THREE_S_BEGIN = 23,
  SAVE_FRIST_THREE_S_END = 25,
  SAVE_TEN_GOLD_COUNT_KEY = 26,
  CARD_SAVE_SYNC_GROUP = 88,
  SAVE_NEXT_GOLD_FREE_TIME = 1,
  SAVE_NEXT_COIN_FREE_TIME = 3,
  SAVE_LEFT_S_TIME = 2,
  CARD_GOLD_TEN_SALE_GROUP = 78,
  CARD_GOLD_TEN_SALE_KEY = 1
}
Require("CommonScript/lib.lua")
CardPicker.Def.tbGoldTenOnSaleSetting = {
  {
    "2017-01-21 00:00:00",
    "2017-01-21 23:59:59",
    9,
    0.6,
    version_vn,
    "OpenLevel39"
  },
  {
    "2017-03-08 00:00:00",
    "2017-03-10 23:59:59",
    13,
    0.6,
    version_hk
  },
  {
    "2017-03-25 00:00:00",
    "2017-03-26 23:59:59",
    14,
    0.6,
    version_xm,
    "OpenDay15"
  },
  {
    "2017-06-14 00:00:00",
    "2017-06-14 23:59:59",
    15,
    0.6,
    version_vn,
    "OpenLevel39"
  },
  {
    "2017-06-21 00:00:00",
    "2017-06-21 23:59:59",
    16,
    0.6,
    version_vn,
    "OpenLevel39"
  }
}
CardPicker.Def.tbGoldFreeTimeCdTabel = {}
CardPicker.Def.tbCoinFreeTimeCdTabel = {}
local tbGoldTenTmpTable = {}
for nIdx, tbInfo in ipairs(CardPicker.Def.tbGoldTenOnSaleSetting) do
  if tbInfo[5] then
    tbInfo[1] = Lib:ParseDateTime(tbInfo[1])
    tbInfo[2] = Lib:ParseDateTime(tbInfo[2])
    table.insert(tbGoldTenTmpTable, tbInfo)
  end
end
CardPicker.Def.tbGoldTenOnSaleSetting = tbGoldTenTmpTable
for _, tbInfo in ipairs(CardPicker.Def.tbGoldFreeTimeCdTabel) do
  tbInfo[1] = Lib:ParseDateTime(tbInfo[1])
  tbInfo[2] = Lib:ParseDateTime(tbInfo[2])
end
for _, tbInfo in ipairs(CardPicker.Def.tbCoinFreeTimeCdTabel) do
  tbInfo[1] = Lib:ParseDateTime(tbInfo[1])
  tbInfo[2] = Lib:ParseDateTime(tbInfo[2])
end
function CardPicker:GetFreeGoldCDTime()
  local nNow = GetTime()
  for _, tbInfo in ipairs(CardPicker.Def.tbGoldFreeTimeCdTabel) do
    if nNow >= tbInfo[1] and nNow <= tbInfo[2] then
      return tbInfo[3]
    end
  end
  return CardPicker.Def.nFreeGoldPickCdTime
end
function CardPicker:GetFreeCoinCDTime()
  local nNow = GetTime()
  for _, tbInfo in ipairs(CardPicker.Def.tbCoinFreeTimeCdTabel) do
    if nNow >= tbInfo[1] and nNow <= tbInfo[2] then
      return tbInfo[3]
    end
  end
  return CardPicker.Def.nFreeCoinPickCdTime
end
function CardPicker:CheckPickCutAct()
  Log("CardPicker:CheckPickCutAct")
  if CardPicker:IsPickCutActOpen() then
    local nNow = GetTime()
    local nOpenDayTime = 14400
    local nOpenWeekDay = 3
    local nWeekDay = Lib:GetLocalWeekDay(nNow - nOpenDayTime)
    if nWeekDay == nOpenWeekDay then
      self.nCardPickCutActValidTime = nNow - Lib:GetLocalDayTime(nNow - nOpenDayTime) + 86400
      self.nCardPickCutActOnSaleFlag = Lib:GetLocalDay(nNow - nOpenDayTime)
      local szNewInfoMsg = "    诸位侠士，截止至%s，通过元宝招募同伴首次十连抽将享受六折优惠，有心的侠士赶快前往招募心仪的同伴吧！"
      local szTimeDesc = Lib:TimeDesc9(self.nCardPickCutActValidTime)
      szNewInfoMsg = string.format(szNewInfoMsg, szTimeDesc)
      local tbSetting = {
        szTitle = "十连抽限时优惠"
      }
      NewInformation:AddInfomation("CardPickAct", self.nCardPickCutActValidTime, {szNewInfoMsg}, tbSetting)
      Log("CardPickCutAct Open", self.nCardPickCutActOnSaleFlag)
    end
  else
    self.nCardPickCutActValidTime = nil
    self.nCardPickCutActOnSaleFlag = nil
  end
end
function CardPicker:IsPickCutActOpen()
  return version_tx or version_vn
end
function CardPicker:IsOnPickCutAct()
  if not CardPicker:IsPickCutActOpen() then
    return false
  end
  if self.nCardPickCutActValidTime and GetTime() < self.nCardPickCutActValidTime then
    return true
  end
  return false
end
function CardPicker:GetPickCutActInfo()
  return self.nCardPickCutActOnSaleFlag, 0.6
end
function CardPicker:GetGoldTenCostInfo(pPlayer)
  local nNow = GetTime()
  local nOnSaleFlag
  local nRate = 1
  for _, tbInfo in ipairs(CardPicker.Def.tbGoldTenOnSaleSetting) do
    if nNow >= tbInfo[1] and nNow <= tbInfo[2] then
      local szTimeFrame = tbInfo[6]
      if not szTimeFrame or GetTimeFrameState(szTimeFrame) == 1 then
        nOnSaleFlag = tbInfo[3]
        nRate = tbInfo[4]
        break
      end
    end
  end
  if CardPicker:IsOnPickCutAct() then
    nOnSaleFlag, nRate = CardPicker:GetPickCutActInfo()
  end
  if not nOnSaleFlag then
    return CardPicker.Def.nGoldTenCost, nil
  end
  local nCurFlag = pPlayer.GetUserValue(CardPicker.Def.CARD_GOLD_TEN_SALE_GROUP, CardPicker.Def.CARD_GOLD_TEN_SALE_KEY)
  if nCurFlag == nOnSaleFlag then
    return CardPicker.Def.nGoldTenCost, nil
  end
  return math.floor(CardPicker.Def.nGoldTenCost * nRate), nOnSaleFlag
end
CardPicker.tbSpecialReplaceCard = nil
function CardPicker:GetSpecialReplaceCard()
  return self.tbSpecialReplaceCard
end
function CardPicker:SetSpecialReplaceCard(tbReplaceCard)
  self.tbSpecialReplaceCard = tbReplaceCard
end
CardPicker.tbCardPickProbTimeFrameMap = {
  [1] = "OpenDay7",
  [2] = "OpenDay35",
  [3] = "OpenDay116"
}
function CardPicker:LoadCardPickSetting()
  local tbResult = {}
  local tbCardPickerSetting = LoadTabFile("Setting/CardPicker/CardPicker.tab", "ssddddddddddddddddddddd", nil, {
    "PickerType",
    "ItemType",
    "ItemId",
    "Prob0",
    "Prob1",
    "Prob2",
    "Prob3",
    "Prob4",
    "Prob5",
    "Prob6",
    "Prob7",
    "Prob8",
    "Prob9",
    "ProbHighVip0",
    "ProbHighVip1",
    "ProbHighVip2",
    "ProbHighVip3",
    "ProbHighVip4",
    "ProbHighVip5",
    "ProbHighVip6",
    "ProbHighVip7",
    "ProbHighVip8",
    "ProbHighVip9"
  })
  local function LoadProbSetting(szProbKey, szPickType)
    local tbItems = {}
    for _, tbLineData in ipairs(tbCardPickerSetting) do
      if szPickType == tbLineData.PickerType and tbLineData[szProbKey] > 0 then
        local tbItem = {
          szItemType = tbLineData.ItemType,
          nItemId = tbLineData.ItemId,
          nCount = 1,
          nProb = tbLineData[szProbKey]
        }
        if tbItem.szItemType == "Partner" then
          local szName, nQualityLevel = GetOnePartnerBaseInfo(tbLineData.ItemId)
          if nQualityLevel then
            tbItem.nQualityLevel = nQualityLevel
          else
            Log("Get Partner Info Fail: ", tbLineData.ItemId)
          end
        end
        table.insert(tbItems, tbItem)
      end
    end
    return tbItems
  end
  for nProbIdx = 0, #CardPicker.tbCardPickProbTimeFrameMap do
    local szTypeKey = CardPicker.tbCardPickProbTimeFrameMap[nProbIdx] or "Default"
    tbResult[szTypeKey] = {
      tbItems = {},
      tbHighVipItems = {}
    }
    local tbProbItems = tbResult[szTypeKey]
    tbProbItems.tbItems.Gold = LoadProbSetting("Prob" .. nProbIdx, "Gold")
    tbProbItems.tbHighVipItems.Gold = LoadProbSetting("ProbHighVip" .. nProbIdx, "Gold")
    tbProbItems.tbItems.Coin = LoadProbSetting("Prob" .. nProbIdx, "Coin")
    tbProbItems.tbHighVipItems.Coin = LoadProbSetting("ProbHighVip" .. nProbIdx, "Coin")
  end
  self.tbPickerSetting = tbResult
end
function CardPicker:LoadSpecialCardsSchedule()
  local nMaxCardLen = 15
  local szType = "s"
  local tbField = {"TimeFrame"}
  for i = 1, nMaxCardLen do
    szType = szType .. "d"
    table.insert(tbField, "Card" .. i)
  end
  local tbSchedules = LoadTabFile("Setting/CardPicker/SpecailCardSchedule.tab", szType, "TimeFrame", tbField)
  local tbDealedTimeFrame = {}
  for szTimeFrame, tbInfo in pairs(tbSchedules) do
    tbDealedTimeFrame[szTimeFrame] = {}
    for nIdx = 1, nMaxCardLen do
      local nPartnerId = tbInfo["Card" .. nIdx]
      if nPartnerId and nPartnerId > 0 then
        table.insert(tbDealedTimeFrame[szTimeFrame], nPartnerId)
      end
    end
  end
  self.tbSpecialCardSchedule = tbDealedTimeFrame
end
function CardPicker:GetCurTimeFramsSpecialCards()
  local szMaxTimeFrame = Lib:GetMaxTimeFrame(self.tbSpecialCardSchedule or {})
  return self.tbSpecialCardSchedule and self.tbSpecialCardSchedule[szMaxTimeFrame]
end
function CardPicker:Init()
  CardPicker:LoadCardPickSetting()
  if MODULE_GAMESERVER then
    CardPicker:CheckPickCutAct()
    CardPicker:LoadSpecialCardsSchedule()
  end
end
function CardPicker:GetCardPickItems(pPlayer, szPickType, fnCheck)
  local szItemsKey = "Default"
  for _, szTimeFrame in ipairs(CardPicker.tbCardPickProbTimeFrameMap) do
    if GetTimeFrameState(szTimeFrame) ~= 1 then
      break
    end
    szItemsKey = szTimeFrame
  end
  local tbItems = {}
  local nVipLevel = pPlayer.GetVipLevel()
  if nVipLevel >= CardPicker.Def.nVipProbDivide then
    tbItems = self.tbPickerSetting[szItemsKey].tbHighVipItems[szPickType]
  else
    tbItems = self.tbPickerSetting[szItemsKey].tbItems[szPickType]
  end
  if not fnCheck then
    return tbItems
  end
  local tbFilteredItems = {}
  for _, tbItem in ipairs(tbItems) do
    if fnCheck(tbItem) then
      table.insert(tbFilteredItems, tbItem)
    end
  end
  return tbFilteredItems
end
function CardPicker:IsSpecialPartnerHit(nGoldTenCount)
  local nRate = CardPicker.Def.tbHighVipSpecialPartnerRate[nGoldTenCount] or 1
  return nRate >= MathRandom()
end
