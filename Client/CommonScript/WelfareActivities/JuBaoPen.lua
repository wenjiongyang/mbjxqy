JuBaoPen.SAVE_GROUP = 42
JuBaoPen.SAVE_KEY_TAKE = 1
JuBaoPen.OPEN_LEVEL = 999
JuBaoPen.MAX_MONEY = 50000
JuBaoPen.TIME_INTERVAL = 1800
JuBaoPen.TAKE_MONEY_CD = 28800
JuBaoPen.tbEventProp = {
  {Money = 500, nProb = 0.74},
  {Money = 1000, nProb = 0.23},
  {Money = 5000, nProb = 0.03}
}
function JuBaoPen:GetTakeMoneyCDTime(pPlayer)
  local nLastTakeTime = pPlayer.GetUserValue(self.SAVE_GROUP, self.SAVE_KEY_TAKE)
  local nCurTime = GetTime()
  return nLastTakeTime + self.TAKE_MONEY_CD - nCurTime
end
