FriendRecall.Def = {
  MAIN_ICON_SHOW_TIME = {
    Lib:ParseDateTime("2017-03-01 00:00:00"),
    Lib:ParseDateTime("2017-03-28 23:59:59")
  },
  BEGIN_DATE = 1,
  END_DATE = 31,
  LAST_ONLINE_TIME_LIMIT = 1296000,
  AWARD_TIME = 2592000,
  MAX_RENOWN_WEEKLY = 10000,
  MAX_RENOWN_COUNT_WEEKLY = 3,
  RENOWN_FRESH_TIME = 14400,
  MAX_AWARD_PLAYER_COUNT = 100,
  MAX_SHOW_CAN_RECALL_COUNT = 10,
  IMITY_LEVEL_LIMIT = 10,
  RESH_LIST_INTERVAL = 10,
  IMITY_BONUS = 2,
  MAX_RECALLED_COUNT = 5,
  TEAM_BUFF_TIME = 259200,
  TEAM_BUFF_ID = 2317,
  RENOWN_VALUE = {
    TeamFuben = 100,
    RandomFuben = 100,
    AdventureFuben = 100,
    PunishTask = 40,
    TeamBattle = 500,
    InDifferBattle = 500
  },
  SAVE_GROUP = 61,
  ACTIVITY_VERSION = 101,
  RECALL = 102,
  AWARD_END_TIME = 103,
  GET_RENOWN = 104,
  RESET_RENOWN_WEEK = 105,
  HAVE_RECALL_PLAYER = 106,
  TEAM_BATTLE_RENOWN = 107,
  PUNISH_TASK_RENOWN = 108,
  TEAM_FUBEN_RENOWN = 109,
  RANDOM_FUBEN_RENOWN = 110,
  ADVENTURE_FUBEN_RENOWN = 111,
  INDIFFER_BATTLE_RENOWN = 112
}
FriendRecall.Def.RENOWN_SAVE_MAP = {
  TeamFuben = FriendRecall.Def.TEAM_FUBEN_RENOWN,
  RandomFuben = FriendRecall.Def.RANDOM_FUBEN_RENOWN,
  AdventureFuben = FriendRecall.Def.ADVENTURE_FUBEN_RENOWN,
  PunishTask = FriendRecall.Def.PUNISH_TASK_RENOWN,
  TeamBattle = FriendRecall.Def.TEAM_BATTLE_RENOWN,
  InDifferBattle = FriendRecall.Def.INDIFFER_BATTLE_RENOWN
}
FriendRecall.RecallType = {
  TEACHER = 1,
  STUDENT = 2,
  FIREND = 3,
  KIN = 4
}
FriendRecall.AwardInfo = {
  szTitle = "许久不见，如今安好？\n   往日征战江湖的伙伴，是否渐行渐远，如今功成名就，是否想与他们同享喜悦？若有此心，不若行动，通过Facebook找到他们，一同再战江湖！",
  szDesc = "规则&奖励说明\n  1、与被召回侠士完成[FFFE0D]组队秘境、凌绝峰、山贼秘窟、惩恶任务、心魔幻境、通天塔[-]时将获得名望，每个活动每周最多3次\n  2、与召回玩家组队时将获得属性加成的增益状态（跨服无效）\n  3、与召回玩家提升亲密度时将获得100%加成\n  4、与召回玩家提升亲密度时将获得100%加成",
  tbAward = {
    {3640, 1},
    {3641, 1},
    {3642, 1}
  }
}
FriendRecall.RecalledAwardInfo = {
  szTitle = "侠士重回江湖，实在可喜可贺！如今江湖风云变动，武林福利不减，少侠还需多提升等级，早日重新融入江湖。",
  szDesc = "规则&奖励说明\n     1、侠士只需从好友列表中寻找符合条件的人一起组队，均可享受「重聚江湖」状态\n     2、55级以上的侠士可以通过主界面的回归福利按钮领取老玩家回归的奖励\n     3、与召回玩家组队时将获得属性加成的增益状态（跨服无效）\n     4、与召回玩家提升亲密度时将获得100%加成",
  tbAward = {
    {3640, 1},
    {3641, 1},
    {3643, 1}
  }
}
FriendRecall.RecallDesc = {
  [FriendRecall.RecallType.TEACHER] = {
    szTitle = "师徒再聚，情缘再续",
    szDesc = "徒儿，许久未见，为师甚是挂念，可要一同再闯江湖？"
  },
  [FriendRecall.RecallType.STUDENT] = {
    szTitle = "一日为师，一世为师",
    szDesc = "师父，十大门派有趣得紧，你何时再带徒儿闯荡江湖？"
  },
  [FriendRecall.RecallType.FIREND] = {
    szTitle = "酒仍暖，人未远",
    szDesc = "好兄弟！话不在多，回来我们再一块大口喝酒，大块吃肉！"
  },
  [FriendRecall.RecallType.KIN] = {
    szTitle = "有你之处，才是江湖",
    szDesc = "如今江湖风云变幻，群豪争霸，正是你回来大展身手之时！"
  }
}
function FriendRecall:IsInShowMainIcon()
  local nNow = GetTime()
  local nBegin = self.Def.MAIN_ICON_SHOW_TIME[1]
  local nEnd = self.Def.MAIN_ICON_SHOW_TIME[2]
  if not nBegin or not nEnd then
    return false
  end
  return nNow >= nBegin and nNow <= nEnd
end
function FriendRecall:IsInProcess()
  local nDate = Lib:GetMonthDay()
  return nDate >= self.Def.BEGIN_DATE and nDate <= self.Def.END_DATE
end
function FriendRecall:IsRecallPlayer(pPlayer)
  return pPlayer.GetUserValue(self.Def.SAVE_GROUP, self.Def.RECALL) == 1
end
function FriendRecall:IsHaveRecallAward(pPlayer)
  local nEndTime = pPlayer.GetUserValue(self.Def.SAVE_GROUP, self.Def.AWARD_END_TIME)
  return nEndTime > 0 and nEndTime > GetTime()
end
