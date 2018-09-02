QuickBuy.DegreePrice = {}
local DegreePrice = QuickBuy.DegreePrice
function DegreePrice:Init()
  local tbSetting = LoadTabFile("Setting/QuickBuy/DegreePrice.tab", "sdd", nil, {
    "Key",
    "Degree",
    "Price"
  })
  self.tbSetting = {}
  for _, v in pairs(tbSetting) do
    self.tbSetting[v.Key] = self.tbSetting[v.Key] or {}
    self.tbSetting[v.Key][v.Degree] = v.Price
  end
end
DegreePrice:Init()
function DegreePrice:GetPrice(szKey, nDegree)
  if not self.tbSetting[szKey] then
    Log("Error in DegreePrice. Does not Exist Key:", szKey)
    return
  end
  if not self.tbSetting[szKey][nDegree] then
    Log("Error in DegreePrice. Does not Exist Degree:", szKey, nDegree)
    return
  end
  return self.tbSetting[szKey][nDegree]
end
local tbSettings = {
  PrayTimes = {
    Index = 2,
    GetMsg = function(pPlayer)
      return "是否购买1次祈福次数？"
    end,
    Enable = function(pPlayer)
      local nDegree = DegreeCtrl:GetDegree(pPlayer, "PrayBuy")
      return nDegree > 0, "今日的祈福购买次数已经用完"
    end,
    GetMoney = function(pPlayer)
      local nMaxDegree = DegreeCtrl:GetMaxDegree("PrayBuy", pPlayer)
      local nDegree = DegreeCtrl:GetDegree(pPlayer, "PrayBuy")
      local nTime = nMaxDegree - nDegree + 1
      local nPrice = DegreePrice:GetPrice("Pray", nTime)
      return nPrice, "Gold"
    end,
    QuickBuy = function(pPlayer)
      if not DegreeCtrl:ReduceDegree(pPlayer, "PrayBuy", 1) then
        return false
      end
      DegreeCtrl:AddDegree(pPlayer, "Pray", 1)
      pPlayer.CallClientScript("Pray:PrayAnimationControl", 1)
      Pray:DoPray(pPlayer)
      return true
    end,
    GetLeftTimes = function(pPlayer)
      return DegreeCtrl:GetDegree(pPlayer, "PrayBuy")
    end
  }
}
function QuickBuy:OpenQuickBuyUI(szMsg, szBuyType, tbParams)
  local function OnOk()
    RemoteServer.QuickBuy(szBuyType, tbParams)
  end
  local bNotShow = Ui:CheckNotShowTips(szBuyType)
  if bNotShow then
    OnOk()
  else
    Ui:OpenWindow("MessageBox", szMsg, {
      {OnOk},
      {}
    }, nil, szBuyType)
  end
end
function QuickBuy:NoticeToCharge()
  me.CenterMsg("元宝不足！请先充值")
  Ui:OpenWindow("CommonShop", "Recharge", "Recharge")
end
function QuickBuy:NotifyQuickBuy(pPlayer, szBuyType, tbParams)
  tbParams = tbParams or {}
  local tbSetting = tbSettings[szBuyType]
  if not tbSetting then
    return
  end
  local bEnabled, szErrorMsg = tbSetting.Enable(pPlayer, unpack(tbParams))
  if not bEnabled then
    if szErrorMsg then
      pPlayer.CenterMsg(szErrorMsg)
    end
    return
  end
  local nMoney, szMoneyType = tbSetting.GetMoney(pPlayer, unpack(tbParams))
  assert(nMoney >= 0)
  local szTip = tbSetting.GetMsg(pPlayer)
  local _, szMoneyName = Shop:GetMoneyName(szMoneyType)
  local szMsg = string.format("%s(花费%d%s) \n今日剩余可购买%d次", szTip, nMoney, szMoneyName, tbSetting.GetLeftTimes(pPlayer))
  if MODULE_GAMESERVER then
    pPlayer.CallClientScript("QuickBuy:OpenQuickBuyUI", szMsg, szBuyType, tbParams)
  else
    self:OpenQuickBuyUI(szMsg, szBuyType, tbParams)
  end
end
function QuickBuy:DoQuickBuy(pPlayer, szBuyType, tbParams)
  tbParams = tbParams or {}
  local tbSetting = tbSettings[szBuyType]
  if not tbSetting then
    return
  end
  local bEnabled, szErrorMsg = tbSetting.Enable(pPlayer, unpack(tbParams))
  if not bEnabled then
    if szErrorMsg then
      pPlayer.CenterMsg(szErrorMsg)
    end
    return
  end
  local nMoney, szMoneyType = tbSetting.GetMoney(pPlayer, unpack(tbParams))
  assert(nMoney >= 0)
  local szMoneyName = Shop:GetMoneyName(szMoneyType)
  if nMoney > pPlayer.GetMoney(szMoneyType) then
    pPlayer.CallClientScript("QuickBuy:NoticeToCharge")
    return
  end
  pPlayer.CostMoney(szMoneyType, nMoney, Env.LogWay_QuickBuy, tbSetting.Index)
  if not tbSetting.QuickBuy(pPlayer, unpack(tbParams)) then
    pPlayer.AddMoney(szMoneyType, nMoney, Env.LogWay_QuickBuyRecu)
    return
  end
  local szTip = "购买成功！"
  if tbSetting.SuccessTip then
    szTip = tbSetting.SuccessTip(nMoney)
  end
  pPlayer.CenterMsg(szTip)
end
