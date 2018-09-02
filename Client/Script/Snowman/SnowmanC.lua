local Snowman = Kin.Snowman
function Snowman:Detail(szKeyName)
  Activity:OpenActUi(szKeyName)
end
function Snowman:OnEnterMap(nTemplateID)
  if nTemplateID ~= Kin.Def.nKinMapTemplateId then
    return
  end
  if Activity:__IsActInProcessByType("SnowmanAct") then
    self:ShowEffect()
  end
end
function Snowman:ShowEffect()
end
function Snowman:OnLeaveMap(nTemplateID)
end
