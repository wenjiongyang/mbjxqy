Fuben.WhiteTigerFuben = Fuben.WhiteTigerFuben or {}
local WhiteTigerFuben = Fuben.WhiteTigerFuben
WhiteTigerFuben.OPEN_LEVEL = 30
WhiteTigerFuben.DEGREE_KEY = "WhiteTigerFuben"
WhiteTigerFuben.PREPARE_MAPID = 1026
WhiteTigerFuben.FIGHT_MAPID = 1027
WhiteTigerFuben.OUTSIDE_MAPID = 1028
WhiteTigerFuben.SUB_ROOM_NUM = 8
WhiteTigerFuben.tbSubRoomTrap = {3344, 3693}
WhiteTigerFuben.ACTIVITY_NAME = "白虎堂"
WhiteTigerFuben.PREPARE_POS = {6940, 7268}
WhiteTigerFuben.PREPARE_TIME = 300
WhiteTigerFuben.PREPARE4PK = 60
WhiteTigerFuben.PEACE_TIME = 240
WhiteTigerFuben.BOSS_START = {
  WhiteTigerFuben.PREPARE_TIME + 90,
  300,
  420,
  630
}
WhiteTigerFuben.AUTO_JOIN_TIME = 10
WhiteTigerFuben.PREPARE_FIRE = "1304|8043|7307"
WhiteTigerFuben.tbMainRoomTrap = {
  {2527, 8150},
  {6930, 16416},
  {17500, 11427},
  {10185, 3601}
}
WhiteTigerFuben.STATE_NONE = 0
WhiteTigerFuben.STATE_PREPARE = 1
WhiteTigerFuben.STATE_FIGHTING = 2
WhiteTigerFuben.nState = WhiteTigerFuben.nState or WhiteTigerFuben.STATE_NONE
WhiteTigerFuben.tbSubDegree = WhiteTigerFuben.tbSubDegree or {}
WhiteTigerFuben.tbComboInfo = WhiteTigerFuben.tbComboInfo or {}
WhiteTigerFuben.tbEnterTime = {}
WhiteTigerFuben.tbKinJoinNum = {}
WhiteTigerFuben.MAX_PRESTIGE = 100
WhiteTigerFuben.tbBossKinPrestige = {
  [932] = {
    5,
    3,
    2
  },
  [712] = {
    10,
    5,
    3
  },
  [713] = {
    20,
    10,
    5
  },
  [714] = {
    50,
    25,
    15
  }
}
WhiteTigerFuben.JOIN_CONTRIBUTION = 100
WhiteTigerFuben.tbFloorContribution = {
  [1] = 50,
  [2] = 50,
  [3] = 50,
  [4] = 50
}
WhiteTigerFuben.tbFloorAwardRate = {
  {
    nMinLevel = 40,
    nMaxLevel = 60,
    nJoinRate = 200,
    nFloorRate = 65
  },
  {
    nMinLevel = 60,
    nMaxLevel = 100,
    nJoinRate = 300,
    nFloorRate = 100
  }
}
WhiteTigerFuben.tbFloorAwardRate[#WhiteTigerFuben.tbFloorAwardRate].nMaxLevel = 999
WhiteTigerFuben.tbFloorAward = {
  "Item",
  3083,
  1
}
WhiteTigerFuben.FIT_KIN_IN_MAP = 3
WhiteTigerFuben.CROSS_MAP_TID = 1029
WhiteTigerFuben.CROSS_BOSS_TID = 1953
WhiteTigerFuben.CROSS_FLOOR_BOSS_TID = 1954
WhiteTigerFuben.tbCross_Award = {
  [3022] = {0.4, 1350000},
  [2161] = {0.15, 5000000},
  [2160] = {0.25, 1500000},
  [788] = {0.2, 200000}
}
WhiteTigerFuben.tbCross_Award_TF = {
  [4849] = {0.4, 4000000},
  [3022] = {0.2, 1350000},
  [2161] = {0.1, 5000000},
  [2160] = {0.05, 1500000},
  [788] = {0.1, 200000},
  [1526] = {0.15, 5000000}
}
WhiteTigerFuben.CROSS_TOP_FLOOR = 5
function WhiteTigerFuben:IsPrepareMap(nMapTemplateId)
  if MODULE_GAMECLIENT and not nMapTemplateId then
    nMapTemplateId = me.nMapTemplateId
  end
  return nMapTemplateId == self.PREPARE_MAPID
end
