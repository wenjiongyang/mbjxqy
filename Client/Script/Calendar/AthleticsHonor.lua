function Calendar:OnDivisionChange(szAct, nNotifyLevel)
  if not Fuben.tbSafeMap[me.nMapTemplateId] and Map:GetClassDesc(me.nMapTemplateId) ~= "fight" or Map:GetClassDesc(me.nMapTemplateId) == "fight" and me.nFightMode ~= 0 then
    Calendar.tbShowDivisionChange = {szAct, nNotifyLevel}
    return
  end
  Ui:OpenWindow("AthleticsHonorAni", szAct, nNotifyLevel)
end
function Calendar:OnMapLoaded(nMapTemplateId)
  if not self.tbShowDivisionChange then
    return
  end
  self:OnDivisionChange(unpack(self.tbShowDivisionChange))
  self.tbShowDivisionChange = nil
end
Calendar.tbTicketFunc = {
  Battle = function(nTickType, bNotNext)
    local tbType = {
      "BattleMonth",
      "BattleSeason",
      "BattleYear"
    }
    return Battle:IsQualifyBattleByType(me, tbType[nTickType], bNotNext)
  end,
  TeamBattle = function(nType, nTime)
    local tbType = {
      TeamBattle.TYPE_MONTHLY,
      TeamBattle.TYPE_QUARTERLY,
      TeamBattle.TYPE_YEAR
    }
    return TeamBattle:CheckTicket(me, tbType[nType], nTime)
  end,
  InDifferBattle = function(nType)
    local tbType = {
      "Month",
      "Season",
      "Year"
    }
    return InDifferBattle:IsQualifyInBattleType(me, tbType[nType])
  end
}
function Calendar:CheckPlayerTicket(szAct, nTickType, ...)
  local fn = self.tbTicketFunc[szAct]
  if fn then
    return fn(nTickType, ...)
  end
  return false
end
Calendar.tbGetNextTimeFn = {
  Battle = function(nType, bNotNext)
    local nOpenTime
    if nType == 1 then
      nOpenTime = Battle:GetQualifyMatchTimeMonth(not bNotNext)
    elseif nType == 2 then
      nOpenTime = Battle:GetQualifyMatchTimeSeason()
    elseif nType == 3 then
      nOpenTime = Battle:GetQualifyMatchTimeYear(not bNotNext)
    end
    if nOpenTime then
      return nOpenTime, Lib:TimeDesc11(nOpenTime)
    end
  end,
  TeamBattle = function(nType, nTime)
    local tbType = {
      TeamBattle.TYPE_MONTHLY,
      TeamBattle.TYPE_QUARTERLY,
      TeamBattle.TYPE_YEAR
    }
    local nOpenTime = TeamBattle:GetNextOpenTime(tbType[nType], nTime)
    if nOpenTime then
      return nOpenTime, Lib:GetTimeStr4(nOpenTime)
    end
  end,
  InDifferBattle = function(nType, bNotNext)
    local tbType = {
      "Month",
      "Season",
      "Year"
    }
    local nNow = GetTime()
    if bNotNext then
      nNow = nNow - 3600
    end
    local nTime = InDifferBattle:GetNextOpenTime(tbType[nType], nNow)
    if nTime then
      return nTime, Lib:GetTimeStr3(nTime)
    end
  end
}
function Calendar:GetNextOpenTime(szAct, nType, ...)
  local fn = self.tbGetNextTimeFn[szAct]
  if fn then
    return fn(nType, ...)
  end
end
Calendar.tbTicketOpenTF = {
  Battle = {
    Battle.tbAllBattleSetting.BattleMonth.OpenTimeFrame,
    Battle.tbAllBattleSetting.BattleSeason.OpenTimeFrame,
    Battle.tbAllBattleSetting.BattleYear.OpenTimeFrame
  },
  TeamBattle = {
    TeamBattle.szLeagueOpenTimeFrame,
    TeamBattle.szLeagueOpenTimeFrame,
    TeamBattle.szLeagueOpenTimeFrame
  },
  InDifferBattle = {
    InDifferBattle.tbBattleTypeSetting.Month.szOpenTimeFrame,
    InDifferBattle.tbBattleTypeSetting.Season.szOpenTimeFrame,
    InDifferBattle.tbBattleTypeSetting.Year.szOpenTimeFrame
  }
}
function Calendar:GetTicketOpenTimeFrame(szAct, nType)
  return self.tbTicketOpenTF[szAct] and self.tbTicketOpenTF[szAct][nType] or "NerverOpenTF"
end
Calendar.tbCheckMarkTypeFn = {
  Battle = function(nType)
    local bCanJoin = Calendar:CheckPlayerTicket("Battle", nType, true)
    if not bCanJoin then
      return
    end
    local nTime = Calendar:GetNextOpenTime("Battle", nType, true)
    if not nTime or Lib:GetLocalDay() ~= Lib:GetLocalDay(nTime) then
      return
    end
    return math.abs(Lib:GetTodaySec(nTime) - Lib:GetTodaySec()) < 7200
  end,
  TeamBattle = function(nType)
    local nCheckTime = GetTime() - 3600
    local bCanJoin = Calendar:CheckPlayerTicket("TeamBattle", nType, nCheckTime)
    if not bCanJoin then
      return
    end
    local nTime = Calendar:GetNextOpenTime("TeamBattle", nType, nCheckTime)
    if not nTime then
      return
    end
    return Lib:GetLocalDay() == Lib:GetLocalDay(nTime)
  end,
  InDifferBattle = function(nType)
    local bCanJoin = Calendar:CheckPlayerTicket("InDifferBattle", nType)
    if not bCanJoin then
      return
    end
    local nTime = Calendar:GetNextOpenTime("InDifferBattle", nType, true)
    if not nTime or Lib:GetLocalDay() ~= Lib:GetLocalDay(nTime) then
      return
    end
    return math.abs(Lib:GetTodaySec(nTime) - Lib:GetTodaySec()) < 7200
  end
}
function Calendar:GetMarkTypeOfPlayer(szAct)
  if not self.tbHonorInfo[szAct] then
    return
  end
  for nType = 1, 3 do
    local szTF = self:GetTicketOpenTimeFrame(szAct, nType)
    if GetTimeFrameState(szTF) == 1 then
      local fn = self.tbCheckMarkTypeFn[szAct]
      if fn and fn(nType) then
        return nType
      end
    end
  end
end
function Calendar:GetActOpenInfo(szAct)
  local nId = self:GetActivityId(szAct)
  if not nId then
    return
  end
  local tbSettting = self.tbCalendarSetting[nId]
  return tbSettting.szTimeFrameOpen, tbSettting.nLevelMin
end
