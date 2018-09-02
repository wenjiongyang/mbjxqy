function Task:CheckRequireMinLevel(pPlayer, value)
  return value <= pPlayer.nLevel, "等级不足" .. value
end
function Task:CheckRequireMaxLevel(pPlayer, value)
  if value == 0 then
    return true
  end
  local szFailMsg = string.format("等级超过 %s", value)
  return value >= pPlayer.nLevel, szFailMsg
end
function Task:CheckRequireFinishTask(pPlayer, value)
  local nFlag = self:GetTaskFlag(pPlayer, tonumber(value) or 9999999)
  return nFlag == 1, "前置任务未完成"
end
function Task:CheckTargetExtInfo(pPlayer, nTaskId, szTarget, tbCurInfo)
  if tbCurInfo and tbCurInfo[szTarget] then
    return true
  end
  return false
end
function Task:CheckTargetOnTrap(pPlayer, nTaskId, tbTargetInfo, tbCurInfo)
  if tbCurInfo and tbCurInfo[tbTargetInfo.nMapTemplateId] and tbCurInfo[tbTargetInfo.nMapTemplateId][tbTargetInfo.szTrap] then
    return true
  end
  return false
end
function Task:CheckTargetEnterMap(pPlayer, nTaskId, nTargetMapId, tbCurInfo)
  tbCurInfo = tbCurInfo or {}
  return tbCurInfo[nTargetMapId] and true or false
end
function Task:CheckTargetKillNpc(pPlayer, nTaskId, tbTargetInfo, tbCurInfo)
  for nNpcTemplateId, nCount in pairs(tbTargetInfo) do
    if not (tbCurInfo and tbCurInfo[nNpcTemplateId]) or nCount > tbCurInfo[nNpcTemplateId] then
      return false
    end
  end
  return true
end
function Task:CheckTargetPersonalFuben(pPlayer, nTaskId, tbTargetInfo)
  local szSectionName = PersonalFuben:GetSectionName(tbTargetInfo.nSectionIdx, tbTargetInfo.nSubSectionIdx, tbTargetInfo.nFubenLevel)
  if not szSectionName then
    return false
  end
  local nStarLevel = PersonalFuben:GetFubenStarLevel(pPlayer, tbTargetInfo.nSectionIdx, tbTargetInfo.nSubSectionIdx, tbTargetInfo.nFubenLevel)
  return nStarLevel > 0, "未完成" .. szSectionName
end
function Task:CheckTargetCollectItem(pPlayer, nTaskId, tbTargetInfo)
  for nItemId, nCount in pairs(tbTargetInfo) do
    if nCount > pPlayer.GetItemCountInAllPos(nItemId) then
      return false, "任务目标未达成！"
    end
  end
  return true
end
function Task:CheckTargetMinLevel(pPlayer, nTaskId, nTargetMinLevel)
  if nTargetMinLevel < 0 then
    return false, "旧的故事暂告段落，新的篇章未完待续，敬请期待"
  end
  if nTargetMinLevel > pPlayer.nLevel then
    return false, string.format("少侠等级不足 %s ，还是历练一番再来吧！", nTargetMinLevel)
  end
  return true
end
function Task:CheckTargetExtPoint(pPlayer, nTaskId, nTargetValue, tbCurInfo)
  if not (tbCurInfo and tbCurInfo.nValue) or nTargetValue > tbCurInfo.nValue then
    return false, "任务目标未达成！"
  end
  return true
end
function Task:CheckTargetAchievement(pPlayer, nTaskId, tbTargetAchievement)
  if not Achievement:CheckCompleteLevel(pPlayer, unpack(tbTargetAchievement)) then
    return false, "任务目标未达成！"
  end
  return true
end
