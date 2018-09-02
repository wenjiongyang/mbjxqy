PKValue.PKValue_GroupId = 37
PKValue.PKValue_ValueId = 1
PKValue.MAX_VALUE = 10
PKValue.tbSetting = PKValue.tbSetting or {}
function PKValue:LoadSetting()
  PKValue.tbSetting = LoadTabFile("Setting/Player/PKValue.tab", "dd", "nValue", {"nValue", "nBaseExp"})
  for i = 1, self.MAX_VALUE do
    assert(PKValue.tbSetting[i])
  end
end
PKValue:LoadSetting()
function PKValue:GetPKValue(pPlayer)
  return pPlayer.GetUserValue(self.PKValue_GroupId, self.PKValue_ValueId)
end
function PKValue:AddValue(pPlayer)
  local nCurValue = self:GetPKValue(pPlayer)
  nCurValue = math.min(nCurValue + 1, self.MAX_VALUE)
  pPlayer.Msg(string.format("恶名值增加，当前恶名值%s", nCurValue))
  if nCurValue >= self.MAX_VALUE and pPlayer.nPkMode == Player.MODE_KILLER then
    pPlayer.SetPkMode(Player.MODE_PK)
  end
  pPlayer.SetUserValue(self.PKValue_GroupId, self.PKValue_ValueId, nCurValue)
  AssistClient:ReportQQScore(pPlayer, Env.QQReport_KillCount, nCurValue, 0, 1)
end
function PKValue:ReduceValue(pPlayer)
  local nCurValue = self:GetPKValue(pPlayer)
  if nCurValue <= 0 then
    return
  end
  nCurValue = nCurValue - 1
  pPlayer.Msg(string.format("恶名值减少，当前恶名值%s", nCurValue))
  pPlayer.SetUserValue(self.PKValue_GroupId, self.PKValue_ValueId, nCurValue)
end
function PKValue:CheckMaxValue(pPlayer)
  return self:GetPKValue(pPlayer) >= self.MAX_VALUE
end
function PKValue:SetLostExpPercent(nPercent)
  self.nPercent = nPercent
end
function PKValue:GetExpCount(pPlayer)
  local nPKValue = math.min(self:GetPKValue(pPlayer), self.MAX_VALUE)
  local tbSetting = self.tbSetting[nPKValue]
  local nExpCount = math.min(pPlayer.GetExp(), math.floor(math.max(self.nPercent or 1, 0) * pPlayer.GetBaseAwardExp() * tbSetting.nBaseExp / 10))
  nExpCount = math.max(nExpCount, 0)
  return nExpCount
end
