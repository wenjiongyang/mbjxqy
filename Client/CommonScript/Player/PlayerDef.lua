Player.MODE_PEACE = 0
Player.MODE_PK = 1
Player.MODE_KILLER = 2
Player.MODE_CUSTOM = 3
Player.MODE_CAMP = 4
Player.MODE_EXCERCISE = 5
Player.CHANGE_PEACE_CD = 60
Player.IMMEDIATE_SAVE_GOLD_LINE = 200
Player.PK_EXCERCISE_DISTANCE = 1200
Player.PK_EXCERCISE_READY = 1
Player.PK_EXCERCISE_GO = 2
Player.PK_EXCERCISE_END = 3
Player.EXCERCISE_WIN_BUFF = 1059
Player.EXCERCISE_LOSE_BUFF = 1060
Player.QQ_VIPINFO_SAVEGROUP = 86
Player.QQ_VIPINFO_VIP_BEGIN = 1
Player.QQ_VIPINFO_VIP_END = 2
Player.QQ_VIPINFO_SVIP_BEGIN = 3
Player.QQ_VIPINFO_SVIP_END = 4
Player.TX_LAUNCH_SAVE_GROUP = 86
Player.TX_LAUNCH_PRIVILEGE_TYPE = 5
Player.TX_LAUNCH_PRIVILEGE_DAY = 6
Player.ONLINE_TIME_GROUP = 86
Player.ONLINE_YESTERDAY_DAY = 11
Player.ONLINE_YESTERDAY_ONLINETIME = 12
Player.QQVIP_NONE = 0
Player.QQVIP_VIP = 1
Player.QQVIP_SVIP = 2
Player.QQVIP_VIP_AWARD_RATE = 0.1
Player.QQVIP_SVIP_AWARD_RATE = 0.15
Player.tbHonorLevelSetting = LoadTabFile("Setting/Player/HonorLevel.tab", "sddsdssdddd", "Level", {
  "Name",
  "Level",
  "PowerValue",
  "ImgPrefix",
  "NeedPower",
  "TimeFrame",
  "RepairTimeFrame",
  "NeedFubenStar",
  "ItemID",
  "ItemCount",
  "IsNotice"
})
Player.tbHeadStateBuff = {
  nAutoPathID = 1009,
  nAutoFightID = 1010,
  nFollowFightID = 1011,
  nWaBaoID = 1012
}
Player.HEAD_STATE_TIME = 86400
Player.nFocusPetTime = 5
Player.DebtAttrDebuff = {
  {nAmount = 10000, nLevel = 1},
  {nAmount = 30000, nLevel = 2}
}
Player.DebtFightPowerDebuff = {
  {nDuration = 259200, nPercent = 5},
  {nDuration = 432000, nPercent = 7},
  {nDuration = 604800, nPercent = 10},
  {nDuration = 1296000, nPercent = 15},
  {nDuration = 1728000, nPercent = 20}
}
Player.DEBT_FIGHT_POWER_REDUCE_PER_LEVEL = 50000
Player.DEBT_FIGHT_POWER_NEED_LEVEL = 2
Player.SAVE_GROUP_LOGIN = 138
Player.SAVE_KEY_LoginTime = 1
