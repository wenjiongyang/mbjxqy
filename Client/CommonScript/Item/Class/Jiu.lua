local tbJiuItem = Item:GetClass("jiu")
tbJiuItem.nTemplateId = 1927
tbJiuItem.nJiuSkillId = 2306
tbJiuItem.tbJiuName = {
  XT("陈年女儿红")
}
tbJiuItem.tbQuotiety = {
  [0] = 1000,
  [1] = 1100
}
function tbJiuItem:OnUse(it)
  local dwTemplateId = it.dwTemplateId
  local nType = KItem.GetItemExtParam(dwTemplateId, 1)
  local nDuraTime = KItem.GetItemExtParam(dwTemplateId, 2)
  if not (nType and nDuraTime) or nDuraTime == 0 or nType == 0 then
    me.CenterMsg("酒道具参数错误")
    return 0
  end
  if me.GetNpc().GetSkillState(self.nJiuSkillId) then
    me.CenterMsg("少侠酒劲未过，还是稍后再喝吧")
    return 0
  end
  me.AddSkillState(self.nJiuSkillId, nType, 1, nDuraTime * Env.GAME_FPS, 0, 1)
  me.CenterMsg("你喝了一瓶陈年女儿红")
  if me.dwTeamID ~= 0 then
    ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.Team, string.format("「%s」喝了一瓶%s", me.szName, it.szName), me.dwTeamID)
  else
    me.Msg(string.format("你喝了一瓶%s", it.szName))
  end
  return 1
end
function tbJiuItem:CalcQuotiety(tbPlayer)
  local tbDrinkedNum = {}
  for i, pPlayer in pairs(tbPlayer) do
    if pPlayer then
      local tbState = pPlayer.GetNpc().GetSkillState(self.nJiuSkillId)
      if tbState then
        local nSkillLevel = tbState.nSkillLevel
        if nSkillLevel > 0 then
          tbDrinkedNum[nSkillLevel] = tbDrinkedNum[nSkillLevel] or 0
          tbDrinkedNum[nSkillLevel] = tbDrinkedNum[nSkillLevel] + 1
        end
      end
    end
  end
  local nMaxTimes = 0
  local nCurDrinkId = 0
  for nType, v in pairs(tbDrinkedNum) do
    if v > nMaxTimes then
      nCurDrinkId = nType
      nMaxTimes = v
    end
  end
  if nMaxTimes > 4 then
    nMaxTimes = 4
  end
  return nMaxTimes, (self.tbQuotiety[nCurDrinkId] - 100) * nMaxTimes + 100, self.tbJiuName[nCurDrinkId]
end
