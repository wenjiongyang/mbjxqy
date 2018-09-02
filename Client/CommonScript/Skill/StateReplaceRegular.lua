if not FightSkill.tbStatereplaceregular then
  FightSkill.tbStateReplaceRegular = {}
end
local tbRegular = FightSkill.tbStateReplaceRegular
tbRegular.tbReplaceRegular = {
  tbForceReplace = {
    {1291}
  },
  tbLevelReplace = {},
  tbTimeReplace = {
    {4542, 4543}
  },
  tbRelation = {
    {246, 247},
    {645, 646},
    {341, 342},
    {818, 819},
    {4015, 4016},
    {4341, 4342},
    {4509, 4510}
  },
  tbMagicValue = {},
  tbFirstRecValue = {
    {1766}
  },
  tbSuperpose = {
    {221},
    {241},
    {245},
    {225},
    {228},
    {279},
    {512},
    {523},
    {562},
    {628},
    {2647},
    {743},
    {744},
    {2675},
    {2872},
    {2534},
    {3448},
    {4020},
    {4119},
    {4120},
    {4040},
    {4045},
    {4057},
    {4219},
    {4223},
    {4411},
    {4432},
    {4462},
    {4489}
  },
  tbTimeAdd = {},
  tbSwitch = {},
  tbMerge = {},
  tbDotMerge = {
    {
      4301,
      4302,
      4303,
      4304,
      4309,
      4333,
      4335,
      4339,
      4346
    }
  },
  tbTimeRefresh = {}
}
function tbRegular:AdjustSkillRegular()
  local tbSkillCheck = {}
  for _, tbRegular in pairs(self.tbReplaceRegular) do
    for _, tbSkillId in ipairs(tbRegular) do
      for _, nSkillId in ipairs(tbSkillId) do
        assert(not tbSkillCheck[nSkillId])
        tbSkillCheck[nSkillId] = 1
      end
    end
  end
end
tbRegular:AdjustSkillRegular()
function tbRegular:GetConflictingSkillList(nDesSkillId)
  for _, tbRegular in pairs(self.tbReplaceRegular) do
    for _, tbSkillId in ipairs(tbRegular) do
      for _, nSkillId in ipairs(tbSkillId) do
        if nDesSkillId == nSkillId then
          return tbSkillId
        end
      end
    end
  end
end
function tbRegular:GetStateGroupReplaceType(nDesSkillId)
  for _, tbSkillId in ipairs(self.tbReplaceRegular.tbForceReplace) do
    for _, nSkillId in ipairs(tbSkillId) do
      if nDesSkillId == nSkillId then
        return 1
      end
    end
  end
  for _, tbSkillId in ipairs(self.tbReplaceRegular.tbLevelReplace) do
    for _, nSkillId in ipairs(tbSkillId) do
      if nDesSkillId == nSkillId then
        return 2
      end
    end
  end
  for _, tbSkillId in ipairs(self.tbReplaceRegular.tbTimeReplace) do
    for _, nSkillId in ipairs(tbSkillId) do
      if nDesSkillId == nSkillId then
        return 3
      end
    end
  end
  for _, tbSkillId in ipairs(self.tbReplaceRegular.tbRelation) do
    for _, nSkillId in ipairs(tbSkillId) do
      if nDesSkillId == nSkillId then
        return 4
      end
    end
  end
  for _, tbSkillId in ipairs(self.tbReplaceRegular.tbMagicValue) do
    for _, nSkillId in ipairs(tbSkillId) do
      if nDesSkillId == nSkillId then
        return 5
      end
    end
  end
  for _, tbSkillId in ipairs(self.tbReplaceRegular.tbFirstRecValue) do
    for _, nSkillId in ipairs(tbSkillId) do
      if nDesSkillId == nSkillId then
        return 6
      end
    end
  end
  for _, tbSkillId in ipairs(self.tbReplaceRegular.tbSuperpose) do
    for _, nSkillId in ipairs(tbSkillId) do
      if nDesSkillId == nSkillId then
        return 7
      end
    end
  end
  for _, tbSkillId in ipairs(self.tbReplaceRegular.tbTimeAdd) do
    for _, nSkillId in ipairs(tbSkillId) do
      if nDesSkillId == nSkillId then
        return 8
      end
    end
  end
  for _, tbSkillId in ipairs(self.tbReplaceRegular.tbDotMerge) do
    for _, nSkillId in ipairs(tbSkillId) do
      if nDesSkillId == nSkillId then
        return 9
      end
    end
  end
  for _, tbSkillId in ipairs(self.tbReplaceRegular.tbSwitch) do
    for _, nSkillId in ipairs(tbSkillId) do
      if nDesSkillId == nSkillId then
        return 10
      end
    end
  end
  for _, tbSkillId in ipairs(self.tbReplaceRegular.tbMerge) do
    for _, nSkillId in ipairs(tbSkillId) do
      if nDesSkillId == nSkillId then
        return 11
      end
    end
  end
  for _, tbSkillId in ipairs(self.tbReplaceRegular.tbTimeRefresh) do
    for _, nSkillId in ipairs(tbSkillId) do
      if nDesSkillId == nSkillId then
        return 12
      end
    end
  end
  return 0
end
