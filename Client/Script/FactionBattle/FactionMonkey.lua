local FactionMonkey = FactionBattle.FactionMonkey
FactionMonkey.tbMonkeyData = FactionMonkey.tbMonkeyData or {}
FactionMonkey.nRequestInterval = 30
function FactionMonkey:SynData()
  if me.nRequestTime and GetTime() < me.nRequestTime then
    return
  end
  me.nRequestTime = GetTime() + FactionMonkey.nRequestInterval
  RemoteServer.SynFactionMonkeyData()
end
function FactionMonkey:OnSynData(tbMonkeyData)
  FactionMonkey.tbMonkeyData = tbMonkeyData
  if tbMonkeyData.tbMonkey and next(tbMonkeyData.tbMonkey) then
    FactionMonkey.tbMonkeyData.tbMonkey = self:SortMonkey(FactionMonkey.tbMonkeyData.tbMonkey)
  end
  UiNotify.OnNotify(UiNotify.emNOTIFY_ONSYNC_MONKEY)
end
function FactionMonkey:IsMonkeyStarting()
  local nStartTime = FactionMonkey.tbMonkeyData.nStartTime or 0
  return nStartTime ~= 0 and nStartTime < GetTime()
end
function FactionMonkey:CheckVote()
  if not self:IsMonkeyStarting() then
    return false, "评选活动已经结束！"
  end
  return FactionBattle:CheckCommondVote(me)
end
function FactionMonkey:SynSwitch(nStartTime)
  FactionMonkey.tbMonkeyData.nStartTime = nStartTime
end
function FactionMonkey:SortMonkey(tbMonkey)
  local SortBySession = function(a, b)
    return a.nSession < b.nSession
  end
  table.sort(tbMonkey, SortBySession)
  return tbMonkey
end
function FactionMonkey:ManageMonkey(tbMonkey)
  local tbResultMonkey = {}
  for nFaction = 1, Faction.MAX_FACTION_COUNT do
    if tbMonkey[nFaction] then
      table.insert(tbResultMonkey, tbMonkey[nFaction])
    end
  end
  return tbResultMonkey
end
