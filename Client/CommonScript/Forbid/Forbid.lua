Forbid.BanType = {
  LevelRank = 1,
  FightPowerRank = 2,
  KinRank = 3,
  WuShenRank = 4,
  WuLinMengZhu = 5,
  FightPower_Faction = 6,
  FightPower_Equip = 7,
  FightPower_Strengthen = 8,
  FightPower_Stone = 9,
  FightPower_Partner = 10,
  CardCollection_1 = 11,
  HouseRank = 12
}
Forbid.szBanName = {
  [Forbid.BanType.LevelRank] = "等级排行榜",
  [Forbid.BanType.FightPowerRank] = "战力排行榜",
  [Forbid.BanType.KinRank] = "家族排行榜",
  [Forbid.BanType.WuShenRank] = "武神殿",
  [Forbid.BanType.WuLinMengZhu] = "武林盟主",
  [Forbid.BanType.FightPower_Faction] = "门派排行榜",
  [Forbid.BanType.FightPower_Equip] = "洗练排行榜",
  [Forbid.BanType.FightPower_Strengthen] = "强化排行榜",
  [Forbid.BanType.FightPower_Stone] = "镶嵌排行榜",
  [Forbid.BanType.FightPower_Partner] = "同伴排行榜",
  [Forbid.BanType.CardCollection_1] = "凌绝峰收集榜",
  [Forbid.BanType.HouseRank] = "家园排行榜"
}
Forbid.szRankKey = {
  FightPower = Forbid.BanType.FightPowerRank,
  Level = Forbid.BanType.LevelRank,
  kin = Forbid.BanType.KinRank,
  FightPower_Faction = Forbid.BanType.FightPower_Faction,
  FightPower_Equip = Forbid.BanType.FightPower_Equip,
  FightPower_Strengthen = Forbid.BanType.FightPower_Strengthen,
  FightPower_Stone = Forbid.BanType.FightPower_Stone,
  FightPower_Partner = Forbid.BanType.FightPower_Partner,
  CardCollection_1 = Forbid.BanType.CardCollection_1,
  House = Forbid.BanType.HouseRank
}
Forbid.RankType = {
  [Forbid.BanType.LevelRank] = "Level",
  [Forbid.BanType.FightPowerRank] = "FightPower",
  [Forbid.BanType.KinRank] = "kin",
  [Forbid.BanType.FightPower_Faction] = "FightPower_Faction",
  [Forbid.BanType.FightPower_Equip] = "FightPower_Equip",
  [Forbid.BanType.FightPower_Strengthen] = "FightPower_Strengthen",
  [Forbid.BanType.FightPower_Stone] = "FightPower_Stone",
  [Forbid.BanType.FightPower_Partner] = "FightPower_Partner",
  [Forbid.BanType.CardCollection_1] = "CardCollection_1",
  [Forbid.BanType.HouseRank] = "House"
}
Forbid.RankUpdateVal = {
  [Forbid.BanType.LevelRank] = function(pPlayer)
    return "Level", pPlayer
  end,
  [Forbid.BanType.FightPowerRank] = function(pPlayer)
    return "FightPower", pPlayer
  end,
  [Forbid.BanType.FightPower_Faction] = function(pPlayer)
    return "FightPower", pPlayer
  end,
  [Forbid.BanType.FightPower_Equip] = function(pPlayer)
    local nCurFightPower = FightPower:CalcEquipFightPower(pPlayer)
    return "FightPower", pPlayer, "Equip", nCurFightPower
  end,
  [Forbid.BanType.FightPower_Strengthen] = function(pPlayer)
    local nCurFightPower = FightPower:CalcStrengthenFightPower(pPlayer)
    return "FightPower", pPlayer, "Strengthen", nCurFightPower
  end,
  [Forbid.BanType.FightPower_Stone] = function(pPlayer)
    local nCurFightPower = FightPower:CalcStoneFightPower(pPlayer)
    return "FightPower", pPlayer, "Stone", nCurFightPower
  end,
  [Forbid.BanType.FightPower_Partner] = function(pPlayer)
    local nCurFightPower = FightPower:CalcPartnerFightPower(pPlayer)
    return "FightPower", pPlayer, "Partner", nCurFightPower
  end,
  [Forbid.BanType.CardCollection_1] = function(pPlayer)
    local tbPosData = {}
    local nSaveGroup = CollectionSystem:GetSaveInfo(CollectionSystem.RANDOMFUBEN_ID)
    for i = 1, CollectionSystem.SAVE_LEN do
      local nFlag = pPlayer.GetUserValue(nSaveGroup, i + CollectionSystem.DATA_SESSION)
      table.insert(tbPosData, nFlag)
    end
    local nRare = CollectionSystem:GetAllRare(CollectionSystem.RANDOMFUBEN_ID, tbPosData)
    local nCompletion = CollectionSystem:GetCompletion(CollectionSystem.RANDOMFUBEN_ID)
    return "CardCollection_1", pPlayer.dwID, nCompletion + nRare, nRare
  end,
  [Forbid.BanType.HouseRank] = function(pPlayer)
    return "House", pPlayer, House:GetComfortValue(pPlayer)
  end
}
Forbid.ActRankType = {
  [Forbid.BanType.WuShenRank] = true,
  [Forbid.BanType.WuLinMengZhu] = true
}
Forbid.IsClear = {NOCLEAR = 0, CLEAR = 1}
