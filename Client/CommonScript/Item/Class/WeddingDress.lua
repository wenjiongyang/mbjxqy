local tbItem = Item:GetClass("WeddingDress")
local nParamLevel = 1
local nParamGender = 2
local tbCanUseMapTemplateIds = {
  10,
  999,
  1004,
  4000,
  4001,
  4002,
  4003,
  4004,
  4005,
  4006,
  4007
}
function tbItem:OnUse(it)
  if not Lib:IsInArray(tbCanUseMapTemplateIds, me.nMapTemplateId) then
    me.CenterMsg("婚服只允许在主城、新手村、家族属地、家园中使用")
    return 0
  end
  local nGender = KItem.GetItemExtParam(it.dwTemplateId, nParamGender)
  if Gift:CheckSex(me.nFaction) ~= nGender then
    me.CenterMsg("此婚服与你的性别不符")
    return 0
  end
  local nWeddingLevel = KItem.GetItemExtParam(it.dwTemplateId, nParamLevel)
  local nBuffId = Wedding:GetWeddingDressBuffId(nWeddingLevel, nGender, me.nFaction)
  if not nBuffId then
    Log("[x] WeddingDress:OnUse", me.dwID, it.dwTemplateId, nWeddingLevel, nGender, me.nFaction, tostring(nBuffId))
    return 0
  end
  if me.GetNpc().GetSkillState(nBuffId) then
    me.CenterMsg("你已经穿上婚服了")
    return 0
  end
  me.AddSkillState(nBuffId, 1, 0, -1, 0, 1)
  Wedding:ChangeDressState(me, true)
  return 0
end
