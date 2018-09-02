local AvatarHead = luanet.import_type("AvatarHeadMgr")
print("tbPlayerHeadMgr", AvatarHead)
Ui.tbPlayerHeadMgr = Ui.tbPlayerHeadMgr or {}
local tbPlayerHeadMgr = Ui.tbPlayerHeadMgr
local tbBloodType = {
  "TeammateBlood",
  "StripRed",
  "StripRed",
  "StripPurple",
  "TeammateBlood2"
}
local tbMonsterBloodStyle = {
  [1] = {
    "MonsterBlood",
    "MonsterBlood"
  },
  [2] = {
    "BossBlood",
    "MonsterBlood"
  },
  [3] = {
    "BossBlood",
    "BossBlood",
    "StripGreen"
  }
}
function tbPlayerHeadMgr:Init()
  for nType, szType in pairs(tbBloodType) do
    AvatarHead.RegisterBloodType(nType, szType)
  end
  for nIndex, tbStyle in pairs(tbMonsterBloodStyle) do
    local szStyle = tbStyle[1]
    AvatarHead.RegisterMonsterBlood(nIndex, szStyle)
    for i = 2, #tbStyle do
      AvatarHead.RegisterMonsterBloodLevel(nIndex, tbStyle[i])
    end
  end
end
