FactionBattle.FactionMonkey = FactionBattle.FactionMonkey or {}
FactionBattle.MONKEY_VOTE_TIME = 24
FactionBattle.MONKEY_SESSION_LIMIT_COUNT = 3
FactionBattle.MONKEY_START_DAY = 1
FactionBattle.MONKEY_END_DAY = 2
FactionBattle.tbHonorVoteScore = {
  [0] = 1,
  [1] = 1,
  [2] = 2,
  [3] = 4,
  [4] = 8,
  [5] = 16,
  [6] = 32,
  [7] = 64,
  [8] = 128,
  [9] = 256,
  [10] = 512,
  [11] = 1024,
  [12] = 2048,
  [13] = 4096
}
FactionBattle.tbFactionMonkeyReward = {
  {
    "Item",
    3358,
    1
  }
}
FactionBattle.MAX_VOTE = 1
FactionBattle.MONKEY_TITLE_ID = {
  [1] = 311,
  [2] = 314,
  [3] = 313,
  [4] = 312,
  [5] = 315,
  [6] = 316,
  [7] = 317,
  [8] = 318,
  [9] = 319,
  [10] = 320,
  [11] = 322,
  [12] = 324,
  [13] = 326,
  [14] = 328
}
FactionBattle.MONKEY_TITLE_TIMEOUT = 2592000
FactionBattle.nNewInfomationValidTime = 604800
FactionBattle.tbMailSetting = {
  [1] = {
    szTitle = "掌门的贺信",
    szText = "    做得很好！你已经历生死较量，又得军心所向！此后你就是我天王的大师兄，勤加练习，将来必能成为名动一方的豪侠，只是切勿沾沾自喜，与同门相处也莫要盛气凌人，将无兵卒，又有何用？谨记。"
  },
  [2] = {
    szTitle = "掌门的贺信",
    szText = "    峨嵋派一向以相互扶助，救死扶伤为己任，如今你成为了峨嵋大师姐，更是应当凡事心怀善念，一切以大局为重。同门之中，你武功最高，自然不免多担待一些，要保护好同门。任重而道远，不可懈怠。"
  },
  [3] = {
    szTitle = "掌门的贺信",
    szText = "    我桃花创立不过数十载，却已有你这般优秀的人才，着实令人欣喜不已，今日你成为桃花的大师姐，武艺自然是冠绝同门，可要切记勿要藏私，多与同门姐妹交流，桃花盛放所依者，是诸位的一同努力。"
  },
  [4] = {
    szTitle = "掌门的贺信",
    szText = "    做得不错，此番较技，称得上是潇洒自如，而与诸位同门之间的情谊，也助你成就今日之名。既身为大师兄，自然是样样都要强于同门，此事虽不易，然既入我门下，理应如此，否则如何能逍遥自在？"
  },
  [5] = {
    szTitle = "掌门的贺信",
    szText = "    如今战火不断，天下纷乱，值此多事之秋，我派能够有你如此杰出的弟子，实在令老道欣慰，将来这掌门之位，不免从你们这些年轻弟子中选中，还望你除了修行武功，更需修心养性，切不可过于自负。"
  },
  [6] = {
    szTitle = "掌门的贺信",
    szText = "    哼，有点意思，能从同门中脱颖而出，说明你天赋卓绝，已掌握我天忍之精髓，所欠缺的，不过是时间，待得技艺日渐成熟，将来天下之中，已无你不可暗杀之人，终有一日，你会成为天忍最锋锐的刃。"
  },
  [7] = {
    szTitle = "掌门的贺信",
    szText = "    阿弥陀佛，善哉善哉。如今你学艺有成，技冠同门，自是令人欣喜，然需谨防心魔，戒骄戒躁，不可放下佛法修行，不可心高气傲，同门之间，多加指导，相互印证，佛武并修，未来自当如虎添翼。"
  },
  [8] = {
    szTitle = "掌门的贺信",
    szText = "    卿之技艺，已日渐成熟，同门翘楚甚多，却独你一人青出于蓝而胜于蓝，行走江湖，四处历练之际，需多加小心，莫要轻易相信他人，男女皆然。还有，照顾好那只小家伙，它才是你最忠诚的同伴。"
  },
  [9] = {
    szTitle = "掌门的贺信",
    szText = "    哼，你既身为唐门子弟，理应为唐家堡名扬武林尽一份力，总算是你天资颇佳，不负我等期望，去吧，要记住，韬光养晦如此之久，而你，要成为青年名侠中的翘楚，方乃我唐门踏出武林的第一步。"
  },
  [10] = {
    szTitle = "掌门的贺信",
    szText = "   不错不错，我昆仑韬光养晦如此之久，近些年来总算是出了这般优秀的子弟，你长年累月在这极寒之地修炼，着实不易，而今能在众多同门中脱颖而出，绝非侥幸，还得多在江湖走动，日后必成大器。"
  },
  [11] = {
    szTitle = "掌门的贺信",
    szText = "   丐帮自创立以来，数百年来被称为天下第一大帮，靠的并非冠绝武林的功夫，除了武林同道给面子，最重要的便是帮众弟子相互扶持，你既是其中翘楚，更应谨守此道，戒骄戒躁，方能一方有难，八方支援。"
  },
  [12] = {
    szTitle = "掌门的贺信",
    szText = "   哼，我等偏居一隅，却叫中原武林小瞧，道什么五毒教，如此也好，如今你学艺有成，是教中年轻一辈掌控五圣蛊最娴熟者，也是时候还以颜色，让那些中原蛮子知道我教中五圣的厉害！去吧，记住，一切小心！"
  },
  [13] = {
    szTitle = "掌门的贺信",
    szText = "   我藏剑山庄始于唐而兴于唐，如今经历卓非凡之祸，武林对于藏剑颇有微辞，然此并非武学衰败，亦非我藏剑无人，如今你身负重振藏剑之名的重任，还望你此后仗剑江湖，能够处处留心，让江湖众人都知道，我藏剑山庄，剑心依旧。"
  },
  [14] = {
    szTitle = "掌门的贺信",
    szText = "   长歌始于唐，原本乃风雅之地，承蒙各路文人异客集思广益，悟得独到武学，以此创立长歌，如今你已是门中第一人，还望你莫忘初心，习武之余，切不可放下一门技艺，此乃长歌区别于他派之根本。"
  }
}
FactionBattle.MonkeyNamePrefix = {
  [1] = "#964",
  [2] = "#963",
  [3] = "#961",
  [4] = "#962",
  [5] = "#960",
  [6] = "#959",
  [7] = "#957",
  [8] = "#958",
  [9] = "#950",
  [10] = "#951",
  [11] = "#946",
  [12] = "#947",
  [13] = "#938",
  [14] = "#939"
}
FactionBattle.SAVE_GROUP_MONKEY = 96
FactionBattle.KEY_VOTE = 1
FactionBattle.KEY_STARTTIME = 2
function FactionBattle:CheckCommondVote(pPlayer)
  if self:RemainVote(pPlayer) <= 0 then
    return false, "您已经没有投票次数"
  end
  return true
end
function FactionBattle:RemainVote(pPlayer)
  return pPlayer.GetUserValue(FactionBattle.SAVE_GROUP_MONKEY, FactionBattle.KEY_VOTE)
end
function FactionBattle:IsMonkey(pPlayer)
  pPlayer = pPlayer or me
  local tbTitleData = PlayerTitle:GetPlayerTitleData(pPlayer)
  for _, tbTitle in pairs(tbTitleData.tbAllTitle) do
    if tbTitle.nTitleID == FactionBattle.MONKEY_TITLE_ID[pPlayer.nFaction] then
      return true
    end
  end
  return false
end
function FactionBattle:GetMonkeyNamePrefix(nFaction)
  return FactionBattle.MonkeyNamePrefix[nFaction] or ""
end
