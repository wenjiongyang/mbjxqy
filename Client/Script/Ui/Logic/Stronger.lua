Ui.Stronger = Ui.Stronger or {}
local Stronger = Ui.Stronger
Stronger.RecommendFPType = {
  stone = 1,
  skill = 2,
  equip = 3,
  level = 4,
  strengthen = 5,
  honor = 6,
  partner = 7,
  house = 8,
  zhenyuan = 9
}
Stronger.panelCfg = LoadTabFile("Setting/Help/StrongerPanel.tab", "dddssssddss", nil, {
  "BaseId",
  "SubId",
  "DetailId",
  "Name",
  "Desc",
  "Icon",
  "IconAtlas",
  "Stars",
  "Level",
  "TimeFrame",
  "Action"
})
Stronger.RecommendFP = LoadTabFile("Setting/Help/RecommendFP.tab", "dd", "Level", {"Level", "FightPower"})
Stronger.RecommendEquipFP = LoadTabFile("Setting/Help/RecommendEquipFP.tab", "dd", "Level", {"Level", "FightPower"})
Stronger.RecommendHonorFP = LoadTabFile("Setting/Help/RecommendHonorFP.tab", "dd", "Level", {"Level", "FightPower"})
Stronger.RecommendLevelFP = LoadTabFile("Setting/Help/RecommendLevelFP.tab", "dd", "Level", {"Level", "FightPower"})
Stronger.RecommendPartnerFP = LoadTabFile("Setting/Help/RecommendPartnerFP.tab", "dd", "Level", {"Level", "FightPower"})
Stronger.RecommendSkillFP = LoadTabFile("Setting/Help/RecommendSkillFP.tab", "dd", "Level", {"Level", "FightPower"})
Stronger.RecommendStoneFP = LoadTabFile("Setting/Help/RecommendStoneFP.tab", "dd", "Level", {"Level", "FightPower"})
Stronger.RecommendStrenthenFP = LoadTabFile("Setting/Help/RecommendStrenthenFP.tab", "dd", "Level", {"Level", "FightPower"})
Stronger.RecommendHouseFP = LoadTabFile("Setting/Help/RecommendHouseFP.tab", "dd", "Level", {"Level", "FightPower"})
Stronger.RecommendZhenYuanFP = LoadTabFile("Setting/Help/RecommendZhenYuanFP.tab", "dd", "Level", {"Level", "FightPower"})
Stronger.RecommendDetail = {
  [Stronger.RecommendFPType.stone] = Stronger.RecommendStoneFP,
  [Stronger.RecommendFPType.skill] = Stronger.RecommendSkillFP,
  [Stronger.RecommendFPType.equip] = Stronger.RecommendEquipFP,
  [Stronger.RecommendFPType.level] = Stronger.RecommendLevelFP,
  [Stronger.RecommendFPType.strengthen] = Stronger.RecommendStrenthenFP,
  [Stronger.RecommendFPType.honor] = Stronger.RecommendHonorFP,
  [Stronger.RecommendFPType.partner] = Stronger.RecommendPartnerFP,
  [Stronger.RecommendFPType.house] = Stronger.RecommendHouseFP,
  [Stronger.RecommendFPType.zhenyuan] = Stronger.RecommendZhenYuanFP
}
Stronger.StateColor = {
  ["急需提升"] = {
    r = 255,
    g = 50,
    b = 50
  },
  ["勉勉强强"] = {
    r = 0,
    g = 244,
    b = 255
  },
  ["成绩平平"] = {
    r = 255,
    g = 164,
    b = 0
  },
  ["出类拔萃"] = {
    r = 114,
    g = 255,
    b = 0
  },
  ["出神入化"] = {
    r = 255,
    g = 248,
    b = 0
  }
}
Stronger.nCurFightPower = Stronger.nCurFightPower or 0
Stronger.detailFightPower = Stronger.detailFightPower or {}
if not version_tx then
  Stronger.tbMarkSprite = {
    Smark = "Smark",
    Amark = "Amark",
    Bmark = "Bmark",
    Cmark = "Cmark"
  }
else
  Stronger.tbMarkSprite = {
    Smark = "Amark4",
    Amark = "Amark3",
    Bmark = "Amark2",
    Cmark = "Amark1"
  }
end
function Stronger:InitPanelCfg()
  self.baseList = {}
  self.subList = {}
  self.detailList = {}
  for _, cfg in ipairs(Stronger.panelCfg) do
    if cfg.DetailId and cfg.DetailId > 0 then
      local subId = 1
      if cfg.SubId and 0 < cfg.SubId then
        subId = cfg.SubId
      end
      self.detailList[cfg.BaseId] = self.detailList[cfg.BaseId] or {}
      self.detailList[cfg.BaseId][subId] = self.detailList[cfg.BaseId][subId] or {}
      self.detailList[cfg.BaseId][subId][cfg.DetailId] = cfg
    elseif cfg.SubId and 0 < cfg.SubId then
      self.subList[cfg.BaseId] = self.subList[cfg.BaseId] or {}
      self.subList[cfg.BaseId][cfg.SubId] = cfg
    else
      self.baseList[cfg.BaseId] = cfg
    end
  end
end
function Stronger:SyncFightPower(nCurFightPower, detailList)
  self.nCurFightPower = nCurFightPower
  self.detailFightPower = detailList
  UiNotify.OnNotify(UiNotify.emNOTIFY_FIGHT_POWER_CHANGE)
end
function Stronger:GetPlayerFightPower()
  return self.nCurFightPower
end
function Stronger:GetFightPowerByType(nType)
  return self.detailFightPower[nType] or 0
end
function Stronger:GetPlayerJudge(nLevel, nFightPower)
  local cfg = self.RecommendFP[nLevel]
  local nRecommend = 0
  local judgeDesc = Stronger.tbMarkSprite.Cmark
  if not cfg then
    return judgeDesc, nRecommend
  end
  nRecommend = cfg.FightPower
  if nFightPower >= nRecommend then
    judgeDesc = Stronger.tbMarkSprite.Smark
  elseif nFightPower >= nRecommend * 0.8 then
    judgeDesc = Stronger.tbMarkSprite.Amark
  elseif nFightPower >= nRecommend * 0.6 then
    judgeDesc = Stronger.tbMarkSprite.Bmark
  end
  return judgeDesc, nRecommend
end
function Stronger:GetDetailFightPowerJudge(nType, nLevel, nFightPower)
  local nRecommend = 0
  local judgeDesc = "急需提升"
  local cfg = self.RecommendDetail[nType][nLevel]
  if not cfg then
    return judgeDesc, nRecommend
  end
  nRecommend = cfg.FightPower
  if nFightPower >= nRecommend then
    judgeDesc = "出神入化"
  elseif nFightPower >= nRecommend * 0.7 then
    judgeDesc = "出类拔萃"
  elseif nFightPower >= nRecommend * 0.5 then
    judgeDesc = "成绩平平"
  elseif nFightPower >= nRecommend * 0.3 then
    judgeDesc = "勉勉强强"
  end
  return judgeDesc, Stronger.StateColor[judgeDesc], nRecommend
end
Stronger:InitPanelCfg()
