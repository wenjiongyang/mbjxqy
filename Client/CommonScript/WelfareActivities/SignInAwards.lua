SignInAwards.SIGNIN_AWARD_GROUP = 22
SignInAwards.LAST_LOGIN_TIME = 1
SignInAwards.LOGIN_DAYS = 2
SignInAwards.NORMAL_FLAG = 3
SignInAwards.VIPLEVEL_ONGET = 4
SignInAwards.TIME_OFFSET = 14400
function SignInAwards:Init()
  local tbSettings = LoadTabFile("Setting/WelfareActivity/SignInAwards.tab", "ddsdd", nil, {
    "nMonth",
    "nVip",
    "szType",
    "nItemId",
    "nCount"
  })
  self.tbAwardsInfo = {}
  for _, tbSet in ipairs(tbSettings or {}) do
    if not self.tbAwardsInfo[tbSet.nMonth] then
      self.tbAwardsInfo[tbSet.nMonth] = {}
    end
    if tbSet.nItemId > 0 then
      table.insert(self.tbAwardsInfo[tbSet.nMonth], {
        nVipLevel = tbSet.nVip,
        tbAwards = {
          tbSet.szType,
          tbSet.nItemId,
          tbSet.nCount
        }
      })
    else
      table.insert(self.tbAwardsInfo[tbSet.nMonth], {
        nVipLevel = tbSet.nVip,
        tbAwards = {
          tbSet.szType,
          tbSet.nCount
        }
      })
    end
  end
  self.nCycle = #self.tbAwardsInfo
end
function SignInAwards:GetAwardInfo(nDayIdx)
  local nMonth = tonumber(os.date("%m", GetTime() - self.TIME_OFFSET))
  nMonth = self.tbAwardsInfo[nMonth] and nMonth or 0
  local nAwardsDay = #self.tbAwardsInfo[nMonth]
  local nAwardsIdx = math.ceil((nDayIdx - 0.1) % nAwardsDay)
  return self.tbAwardsInfo[nMonth][nAwardsIdx]
end
SignInAwards:Init()
