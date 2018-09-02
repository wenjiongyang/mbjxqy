Require("CommonScript/BossLeader/BossLeaderDef.lua")
BossLeader.nCrossDayTime = 1
BossLeader.tbCrossKinJiFenRank = {
  [1] = 10,
  [2] = 8,
  [3] = 7,
  [4] = 5,
  [5] = 4
}
BossLeader.nCanCrossFront = 3
BossLeader.tbCrossKinDmgRankValue = {
  OpenLevel119 = {
    [-1] = {
      Boss = {
        [1] = 6000000,
        [2] = 6000000,
        [3] = 6000000,
        [4] = 6000000,
        [5] = 6000000
      },
      FalseBoss = {
        [1] = 3000000,
        [2] = 3000000,
        [3] = 3000000,
        [4] = 3000000,
        [5] = 3000000
      }
    },
    [1] = {
      Boss = {
        [1] = 15000000,
        [2] = 15000000,
        [3] = 15000000,
        [4] = 15000000,
        [5] = 15000000
      },
      FalseBoss = {
        [1] = 7500000,
        [2] = 7500000,
        [3] = 7500000,
        [4] = 7500000,
        [5] = 7500000
      }
    },
    [2] = {
      Boss = {
        [1] = 20000000,
        [2] = 20000000,
        [3] = 20000000,
        [4] = 20000000,
        [5] = 20000000
      },
      FalseBoss = {
        [1] = 10000000,
        [2] = 10000000,
        [3] = 10000000,
        [4] = 10000000,
        [5] = 10000000
      }
    }
  }
}
BossLeader.tbEndJiFenCrossKinMail = {
  szTitle = "跨服历代名将资格获取",
  szContent = "      恭喜侠士，您所在的家族[FFFE0D]%s[-]于普通历代名将中表现优异，战绩超群！现已获得跨服历代名将的参与资格。此次跨服历代名将的开启时间为[FFFE0D]%s[-]，请你务必准时参加，携手家族兄弟再拔头筹，夺取更加丰厚的奖励！\n"
}
BossLeader.szEndJiFenKinNotice = "恭喜本家族在普通历代名将中表现优异，战绩超群！现已获得跨服历代名将的参与资格，可喜可贺！#49"
BossLeader.szEndJiFenWorldNotice = "恭喜本服家族[FFFE0D]%s[-]在普通历代名将中表现优异，战绩超群！现已获得跨服历代名将的参与资格，可喜可贺！"
