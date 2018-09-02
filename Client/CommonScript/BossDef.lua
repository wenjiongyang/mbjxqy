Boss.Def = {
  nTimeDuration = 720,
  nPlayerEnterLevel = 20,
  nFinishWaitTime = 5,
  nRobCd = 180,
  nRobHate = 30000,
  nProtectRobCd = 60,
  nExtraProtectRobCd = 120,
  nBossFightCd = 180,
  nRobFightMap = 1017,
  nBossFightMap = 1017,
  nSortRankWaitingTime = 5,
  nCheckEndTime = 2,
  tbNPC_POS = {
    {
      {2761, 2490},
      {2184, 2490},
      {1569, 2490},
      {2761, 2787},
      {2166, 2787},
      {1559, 2787}
    },
    {
      {1582, 1469},
      {2221, 1466},
      {2759, 1479},
      {1582, 1150},
      {2234, 1153},
      {2770, 1171}
    }
  },
  nRobBattleTime = 150,
  nRobScoreBaseRateMin = 5,
  nRobScoreBaseRateMax = 20,
  nNoKinRewardScore = 40000,
  nNoKinIgnoreItemId = 1378,
  nWeekendExtraAuctionActivityRate = 0.5,
  KinRwardRankScore = {
    {Rank = 1, Score = 900000},
    {Rank = 2, Score = 600000},
    {Rank = 4, Score = 500000},
    {Rank = 10, Score = 400000},
    {Rank = 20, Score = 250000},
    {Rank = 30, Score = 300000},
    {Rank = 40, Score = 200000},
    {
      Rank = math.huge,
      Score = 50000
    }
  },
  KinPrestigeRward = {
    {Rank = 1, Prestige = 100},
    {Rank = 2, Prestige = 80},
    {Rank = 3, Prestige = 60},
    {Rank = 4, Prestige = 50},
    {Rank = 6, Prestige = 40},
    {Rank = 11, Prestige = 35},
    {Rank = 16, Prestige = 30},
    {Rank = 21, Prestige = 25},
    {Rank = 26, Prestige = 20},
    {Rank = 36, Prestige = 15},
    {
      Rank = math.huge,
      Prestige = 15
    }
  },
 nBossHpMaxValue = 2000000000,
  tbBossSetting = {
    {
      TimeFrame = "OpenDay1A",
      Data = {
        Hp = 5000000,
        NpcIds = {634}
      }
    },
    {
      TimeFrame = "OpenDay2A",
      Data = {
        Hp = 15000000,
        NpcIds = {634}
      }
    },
    {
      TimeFrame = "OpenDay2C",
      Data = {
        Hp = 30000000,
        NpcIds = {634}
      }
    },
    {
      TimeFrame = "OpenDay3A",
      Data = {
        Hp = 80000000,
        NpcIds = {634}
      }
    },
    {
      TimeFrame = "OpenDay3B",
      Data = {
        Hp = 150000000,
        NpcIds = {634}
      }
    },
    {
      TimeFrame = "OpenLevel49",
      Data = {
        Hp = 200000000,
        NpcIds = {634}
      }
    },
    {
      TimeFrame = "OpenDay7",
      Data = {
        Hp = 200000000,
        NpcIds = {634}
      }
    },
    {
      TimeFrame = "OpenDay10",
      Data = {
        Hp = 300000000,
        NpcIds = {634}
      }
    },
    {
      TimeFrame = "OpenDay12",
      Data = {
        Hp = 500000000,
        NpcIds = {634}
      }
    },
    {
      TimeFrame = "OpenLevel59",
      Data = {
        Hp = 800000000,
        NpcIds = {634}
      }
    },
    {
      TimeFrame = "OpenDay15",
      Data = {
        Hp = 800000000,
        NpcIds = {634}
      }
    },
    {
      TimeFrame = "OpenDay20",
      Data = {
        Hp = 1200000000,
        NpcIds = {634}
      }
    },
    {
      TimeFrame = "OpenLevel69",
      Data = {
        Hp = 1500000000,
        NpcIds = {63}
      }
    },
    {
      TimeFrame = "OpenDay33",
      Data = {
        Hp = 2000000000,
        NpcIds = {634}
      }
    },
    {
      TimeFrame = "OpenDay45",
      Data = {
        Hp = 2000000000,
        NpcIds = {634}
      }
    },
    {
      TimeFrame = "OpenLevel79",
      Data = {
        Hp = 2000000000,
        NpcIds = {634, 1896}
      }
    },
    {
      TimeFrame = "OpenDay70",
      Data = {
        Hp = 2000000000,
        NpcIds = {634, 1896}
      }
    },
    {
      TimeFrame = "OpenDay90",
      Data = {
        Hp = 2000000000,
        NpcIds = {634, 1896}
      }
    },
    {
      TimeFrame = "OpenDay100",
      Data = {
        Hp = 2000000000,
        NpcIds = {634, 1896}
      }
    },
    {
      TimeFrame = "OpenLevel89",
      Data = {
        Hp = 2000000000,
        NpcIds = {
          634,
          1896,
          1897
        }
      }
    },
    {
      TimeFrame = "OpenDay130",
      Data = {
        Hp = 2000000000,
        NpcIds = {
          634,
          1896,
          1897
        }
      }
    },
    {
      TimeFrame = "OpenDay160",
      Data = {
        Hp = 200000000000,
        NpcIds = {
          634,
          1896,
          1897
        }
      }
    },
    {
      TimeFrame = "OpenDay180",
      Data = {
        Hp = 200000000000,
        NpcIds = {
          634,
          1896,
          1897
        }
      }
    },
    {
      TimeFrame = "OpenLevel99",
      Data = {
        Hp = 200000000000,
        NpcIds = {
          634,
          1896,
          1897
        }
      }
    },
    {
      TimeFrame = "OpenLevel109",
      Data = {
        Hp = 200000000000,
        NpcIds = {
          634,
          1896,
          1897,
          2189
        }
      }
    }
  },
  tbBossHpStage = {
    {
      HpRate = 0.3,
      ScoreRate = 3,
      Texture = "BossStage03",
      RateTexture = "Points03"
    },
    {
      HpRate = 0.6,
      ScoreRate = 2,
      Texture = "BossStage02",
      RateTexture = "Points02"
    },
    {
      HpRate = 1,
      ScoreRate = 1,
      Texture = "BossStage01",
      RateTexture = "Points01"
    }
  },
  nBossKinMemberN = 5,
  nBossKinMemberNMinScore = 80,
  nBossPlayerScoreN = 2000,
  nBossPlayerScoreNMinScore = 80,
  szAwardMoneyType = "Gold",
  tbPlayerBoxRankScore = {
    {Rank = 1, Honor = 30000},
    {Rank = 2, Honor = 26000},
    {Rank = 10, Honor = 24000},
    {Rank = 20, Honor = 22000},
    {Rank = 50, Honor = 20000},
    {Rank = 100, Honor = 18000},
    {Rank = 200, Honor = 16000},
    {Rank = 400, Honor = 14000},
    {Rank = 700, Honor = 12000},
    {Rank = 1000, Honor = 10000},
    {
      Rank = math.huge,
      Honor = 90
    }
  },
  tbKinBoxRankScore = {
    {Rank = 1, Honor = 30000},
    {Rank = 2, Honor = 24000},
    {Rank = 4, Honor = 20000},
    {Rank = 8, Honor = 17000},
    {Rank = 12, Honor = 15000},
    {Rank = 18, Honor = 12000},
    {Rank = 24, Honor = 10000},
    {
      Rank = math.huge,
      Honor = 90
    }
  },
  tbAuctionRewards = {
    {
      TimeFrame = "OpenLevel39",
      Rewards = {
        {
          nRate = 0.7727272727272727,
          Items = {1393}
        },
        {
          nRate = 0.22727272727272727,
          Items = {1183}
        }
      }
    },
    {
      TimeFrame = "OpenLevel49",
      Rewards = {
        {
          nRate = 0.6818181818181818,
          Items = {1393}
        },
        {
          nBossId = 634,
          nRate = 0.09090909090909091,
          Items = {1378}
        },
        {
          nRate = 0.22727272727272727,
          Items = {1184}
        }
      }
    },
    {
      TimeFrame = "OpenLevel59",
      Rewards = {
        {
          nRate = 0.45454545454545453,
          Items = {1393}
        },
        {
          nRate = 0.18181818181818182,
          Items = {1394}
        },
        {
          nBossId = 634,
          nRate = 0.13636363636363635,
          Items = {1378}
        },
        {
          nRate = 0.22727272727272727,
          Items = {2124}
        }
      }
    },
    {
      TimeFrame = "OpenLevel69",
      Rewards = {
        {
          nRate = 0.09090909090909091,
          Items = {1393}
        },
        {
          nRate = 0.2727272727272727,
          Items = {1394}
        },
        {
          nBossId = 634,
          nRate = 0.18181818181818182,
          Items = {1378}
        },
        {
          nRate = 0.13636363636363635,
          Items = {4307}
        },
        {
          nRate = 0.18181818181818182,
          Items = {2125}
        },
        {
          nBossId = 634,
          nRate = 0.13636363636363635,
          Items = {2668}
        }
      }
    },
    {
      TimeFrame = "OpenDay42",
      Rewards = {
        {
          nRate = 0.09090909090909091,
          Items = {1393}
        },
        {
          nRate = 0.22727272727272727,
          Items = {1394}
        },
        {
          nBossId = 634,
          nRate = 0.18181818181818182,
          Items = {1378}
        },
        {
          nRate = 0.13636363636363635,
          Items = {4307}
        },
        {
          nRate = 0.13636363636363635,
          Items = {2125}
        },
        {
          nBossId = 634,
          nRate = 0.13636363636363635,
          Items = {2668}
        },
        {
          nRate = 0.09090909090909091,
          Items = {2396}
        }
      }
    },
    {
      TimeFrame = "OpenLevel79",
      Rewards = {
        {
          nRate = 0.045454545454545456,
          Items = {1393}
        },
        {
          nRate = 0.13636363636363635,
          Items = {1394}
        },
        {
          nRate = 0.13636363636363635,
          Items = {1395}
        },
        {
          nBossId = 634,
          nRate = 0.18181818181818182,
          Items = {1378}
        },
        {
          nBossId = 1896,
          nRate = 0.18181818181818182,
          Items = {2253}
        },
        {
          nRate = 0.13636363636363635,
          Items = {4307}
        },
        {
          nRate = 0.13636363636363635,
          Items = {2126}
        },
        {
          nBossId = 634,
          nRate = 0.13636363636363635,
          Items = {2668}
        },
        {
          nBossId = 1896,
          nRate = 0.13636363636363635,
          Items = {2880}
        },
        {
          nRate = 0.09090909090909091,
          Items = {2396}
        }
      }
    },
    {
      TimeFrame = "OpenDay99",
      Rewards = {
        {
          nRate = 0.045454545454545456,
          Items = {1393}
        },
        {
          nRate = 0.13636363636363635,
          Items = {1394}
        },
        {
          nRate = 0.13636363636363635,
          Items = {1395}
        },
        {
          nBossId = 634,
          nRate = 0.18181818181818182,
          Items = {1378}
        },
        {
          nBossId = 1896,
          nRate = 0.18181818181818182,
          Items = {2253}
        },
        {
          nRate = 0.045454545454545456,
          Items = {4307}
        },
        {
          nRate = 0.09090909090909091,
          Items = {4308}
        },
        {
          nRate = 0.13636363636363635,
          Items = {2126}
        },
        {
          nBossId = 634,
          nRate = 0.13636363636363635,
          Items = {2668}
        },
        {
          nBossId = 1896,
          nRate = 0.13636363636363635,
          Items = {2880}
        },
        {
          nRate = 0.09090909090909091,
          Items = {2396}
        }
      }
    },
    {
      TimeFrame = "OpenLevel89",
      Rewards = {
        {
          nRate = 0.045454545454545456,
          Items = {1393}
        },
        {
          nRate = 0.09090909090909091,
          Items = {1394}
        },
        {
          nRate = 0.13636363636363635,
          Items = {1395}
        },
        {
          nBossId = 634,
          nRate = 0.09090909090909091,
          Items = {1378}
        },
        {
          nBossId = 1896,
          nRate = 0.09090909090909091,
          Items = {2253}
        },
        {
          nBossId = 1897,
          nRate = 0.09090909090909091,
          Items = {2254}
        },
        {
          nRate = 0.045454545454545456,
          Items = {4307}
        },
        {
          nRate = 0.09090909090909091,
          Items = {4308}
        },
        {
          nRate = 0.09090909090909091,
          Items = {2979}
        },
        {
          nRate = 0.09090909090909091,
          Items = {3462}
        },
        {
          nRate = 0.045454545454545456,
          Items = {3461}
        },
        {
          nBossId = 634,
          nRate = 0.09090909090909091,
          Items = {2668}
        },
        {
          nBossId = 1896,
          nRate = 0.09090909090909091,
          Items = {2880}
        },
        {
          nBossId = 1897,
          nRate = 0.09090909090909091,
          Items = {2881}
        },
        {
          nRate = 0.09090909090909091,
          Items = {2396}
        },
        {
          nRate = 0.09090909090909091,
          Items = {2804}
        }
      }
    },
    {
      TimeFrame = "OpenLevel99",
      Rewards = {
        {
          nRate = 0.045454545454545456,
          Items = {1393}
        },
        {
          nRate = 0.09090909090909091,
          Items = {1394}
        },
        {
          nRate = 0.13636363636363635,
          Items = {1395}
        },
        {
          nBossId = 634,
          nRate = 0.09090909090909091,
          Items = {1378}
        },
        {
          nBossId = 1896,
          nRate = 0.09090909090909091,
          Items = {2253}
        },
        {
          nBossId = 1897,
          nRate = 0.09090909090909091,
          Items = {2254}
        },
        {
          nRate = 0.03636363636363637,
          Items = {4307}
        },
        {
          nRate = 0.1,
          Items = {4308}
        },
        {
          nRate = 0.09090909090909091,
          Items = {2980}
        },
        {
          nRate = 0.09090909090909091,
          Items = {3462}
        },
        {
          nRate = 0.045454545454545456,
          Items = {3461}
        },
        {
          nBossId = 634,
          nRate = 0.09090909090909091,
          Items = {2668}
        },
        {
          nBossId = 1896,
          nRate = 0.09090909090909091,
          Items = {2880}
        },
        {
          nBossId = 1897,
          nRate = 0.09090909090909091,
          Items = {2881}
        },
        {
          nRate = 0.09090909090909091,
          Items = {2396}
        },
        {
          nRate = 0.09090909090909091,
          Items = {2804}
        }
      }
    },
    {
      TimeFrame = "OpenDay188",
      Rewards = {
        {
          nRate = 0.045454545454545456,
          Items = {1393}
        },
        {
          nRate = 0.045454545454545456,
          Items = {1394}
        },
        {
          nRate = 0.09090909090909091,
          Items = {1395}
        },
        {
          nBossId = 634,
          nRate = 0.09090909090909091,
          Items = {1378}
        },
        {
          nBossId = 1896,
          nRate = 0.09090909090909091,
          Items = {2253}
        },
        {
          nBossId = 1897,
          nRate = 0.09090909090909091,
          Items = {2254}
        },
        {
          nRate = 0.045454545454545456,
          Items = {4307}
        },
        {
          nRate = 0.1,
          Items = {4308}
        },
        {
          nRate = 0.09090909090909091,
          Items = {2980}
        },
        {
          nRate = 0.09090909090909091,
          Items = {1396}
        },
        {
          nRate = 0.09090909090909091,
          Items = {3462}
        },
        {
          nRate = 0.045454545454545456,
          Items = {3461}
        },
        {
          nBossId = 634,
          nRate = 0.09090909090909091,
          Items = {2668}
        },
        {
          nBossId = 1896,
          nRate = 0.09090909090909091,
          Items = {2880}
        },
        {
          nBossId = 1897,
          nRate = 0.09090909090909091,
          Items = {2881}
        },
        {
          nRate = 0.09090909090909091,
          Items = {2396}
        },
        {
          nRate = 0.09090909090909091,
          Items = {2804}
        }
      }
    },
    {
      TimeFrame = "OpenDay224",
      Rewards = {
        {
          nRate = 0.045454545454545456,
          Items = {1393}
        },
        {
          nRate = 0.045454545454545456,
          Items = {1394}
        },
        {
          nRate = 0.09090909090909091,
          Items = {1395}
        },
        {
          nBossId = 634,
          nRate = 0.09090909090909091,
          Items = {1378}
        },
        {
          nBossId = 1896,
          nRate = 0.09090909090909091,
          Items = {2253}
        },
        {
          nBossId = 1897,
          nRate = 0.09090909090909091,
          Items = {2254}
        },
        {
          nRate = 0.045454545454545456,
          Items = {4308}
        },
        {
          nRate = 0.09090909090909091,
          Items = {4309}
        },
        {
          nRate = 0.09090909090909091,
          Items = {2980}
        },
        {
          nRate = 0.09090909090909091,
          Items = {1396}
        },
        {
          nRate = 0.09090909090909091,
          Items = {3462}
        },
        {
          nRate = 0.045454545454545456,
          Items = {3461}
        },
        {
          nBossId = 634,
          nRate = 0.09090909090909091,
          Items = {2668}
        },
        {
          nBossId = 1896,
          nRate = 0.09090909090909091,
          Items = {2880}
        },
        {
          nBossId = 1897,
          nRate = 0.09090909090909091,
          Items = {2881}
        },
        {
          nRate = 0.09090909090909091,
          Items = {2396}
        },
        {
          nRate = 0.09090909090909091,
          Items = {2804}
        }
      }
    },
    {
      TimeFrame = "OpenLevel109",
      Rewards = {
        {
          nRate = 0.045454545454545456,
          Items = {1393}
        },
        {
          nRate = 0.045454545454545456,
          Items = {1394}
        },
        {
          nRate = 0.045454545454545456,
          Items = {1395}
        },
        {
          nBossId = 634,
          nRate = 0.09090909090909091,
          Items = {1378}
        },
        {
          nBossId = 1896,
          nRate = 0.09090909090909091,
          Items = {2253}
        },
        {
          nBossId = 1897,
          nRate = 0.09090909090909091,
          Items = {2254}
        },
        {
          nBossId = 2189,
          nRate = 0.09090909090909091,
          Items = {2255}
        },
        {
          nRate = 0.045454545454545456,
          Items = {4308}
        },
        {
          nRate = 0.09090909090909091,
          Items = {4309}
        },
        {
          nRate = 0.09090909090909091,
          Items = {2981}
        },
        {
          nRate = 0.13636363636363635,
          Items = {1396}
        },
        {
          nRate = 0.09090909090909091,
          Items = {3462}
        },
        {
          nRate = 0.045454545454545456,
          Items = {3461}
        },
        {
          nBossId = 634,
          nRate = 0.09090909090909091,
          Items = {2668}
        },
        {
          nBossId = 1896,
          nRate = 0.09090909090909091,
          Items = {2880}
        },
        {
          nBossId = 1897,
          nRate = 0.09090909090909091,
          Items = {2881}
        },
        {
          nBossId = 2189,
          nRate = 0.09090909090909091,
          Items = {3897}
        },
        {
          nRate = 0.09090909090909091,
          Items = {2396}
        },
        {
          nRate = 0.09090909090909091,
          Items = {2804}
        }
      }
    },
    {
      TimeFrame = "OpenLevel119",
      Rewards = {
        {
          nRate = 0.045454545454545456,
          Items = {1393}
        },
        {
          nRate = 0.045454545454545456,
          Items = {1394}
        },
        {
          nRate = 0.045454545454545456,
          Items = {1395}
        },
        {
          nBossId = 634,
          nRate = 0.09090909090909091,
          Items = {1378}
        },
        {
          nBossId = 1896,
          nRate = 0.09090909090909091,
          Items = {2253}
        },
        {
          nBossId = 1897,
          nRate = 0.09090909090909091,
          Items = {2254}
        },
        {
          nBossId = 2189,
          nRate = 0.09090909090909091,
          Items = {2255}
        },
        {
          nRate = 0.03636363636363637,
          Items = {4308}
        },
        {
          nRate = 0.1,
          Items = {4309}
        },
        {
          nRate = 0.09090909090909091,
          Items = {3679}
        },
        {
          nRate = 0.18181818181818182,
          Items = {1396}
        },
        {
          nRate = 0.045454545454545456,
          Items = {3462}
        },
        {
          nRate = 0.045454545454545456,
          Items = {3461}
        },
        {
          nBossId = 634,
          nRate = 0.09090909090909091,
          Items = {2668}
        },
        {
          nBossId = 1896,
          nRate = 0.09090909090909091,
          Items = {2880}
        },
        {
          nBossId = 1897,
          nRate = 0.09090909090909091,
          Items = {2881}
        },
        {
          nBossId = 2189,
          nRate = 0.09090909090909091,
          Items = {3897}
        },
        {
          nRate = 0.09090909090909091,
          Items = {2396}
        },
        {
          nRate = 0.09090909090909091,
          Items = {2804}
        }
      }
    },
    {
      TimeFrame = "OpenDay399",
      Rewards = {
        {
          nRate = 0.045454545454545456,
          Items = {1393}
        },
        {
          nRate = 0.045454545454545456,
          Items = {1394}
        },
        {
          nRate = 0.045454545454545456,
          Items = {1395}
        },
        {
          nBossId = 634,
          nRate = 0.09090909090909091,
          Items = {1378}
        },
        {
          nBossId = 1896,
          nRate = 0.09090909090909091,
          Items = {2253}
        },
        {
          nBossId = 1897,
          nRate = 0.09090909090909091,
          Items = {2254}
        },
        {
          nBossId = 2189,
          nRate = 0.09090909090909091,
          Items = {2255}
        },
        {
          nRate = 0.045454545454545456,
          Items = {4309}
        },
        {
          nRate = 0.09090909090909091,
          Items = {4310}
        },
        {
          nRate = 0.09090909090909091,
          Items = {3679}
        },
        {
          nRate = 0.18181818181818182,
          Items = {1396}
        },
        {
          nRate = 0.045454545454545456,
          Items = {3462}
        },
        {
          nRate = 0.045454545454545456,
          Items = {3461}
        },
        {
          nBossId = 634,
          nRate = 0.09090909090909091,
          Items = {2668}
        },
        {
          nBossId = 1896,
          nRate = 0.09090909090909091,
          Items = {2880}
        },
        {
          nBossId = 1897,
          nRate = 0.09090909090909091,
          Items = {2881}
        },
        {
          nBossId = 2189,
          nRate = 0.09090909090909091,
          Items = {3897}
        },
        {
          nRate = 0.09090909090909091,
          Items = {2396}
        },
        {
          nRate = 0.09090909090909091,
          Items = {2804}
        }
      }
    },
    {
      TimeFrame = "OpenLevel129",
      Rewards = {
        {
          nRate = 0.03636363636363637,
          Items = {1393}
        },
        {
          nRate = 0.03636363636363637,
          Items = {1394}
        },
        {
          nRate = 0.045454545454545456,
          Items = {1395}
        },
        {
          nBossId = 634,
          nRate = 0.09090909090909091,
          Items = {1378}
        },
        {
          nBossId = 1896,
          nRate = 0.09090909090909091,
          Items = {2253}
        },
        {
          nBossId = 1897,
          nRate = 0.09090909090909091,
          Items = {2254}
        },
        {
          nBossId = 2189,
          nRate = 0.09090909090909091,
          Items = {2255}
        },
        {
          nRate = 0.03636363636363637,
          Items = {4309}
        },
        {
          nRate = 0.09090909090909091,
          Items = {4310}
        },
        {
          nRate = 0.09090909090909091,
          Items = {5821}
        },
        {
          nRate = 0.21818181818181817,
          Items = {1396}
        },
        {
          nRate = 0.045454545454545456,
          Items = {3462}
        },
        {
          nRate = 0.03636363636363637,
          Items = {3461}
        },
        {
          nBossId = 634,
          nRate = 0.09090909090909091,
          Items = {2668}
        },
        {
          nBossId = 1896,
          nRate = 0.09090909090909091,
          Items = {2880}
        },
        {
          nBossId = 1897,
          nRate = 0.09090909090909091,
          Items = {2881}
        },
        {
          nBossId = 2189,
          nRate = 0.09090909090909091,
          Items = {3897}
        },
        {
          nRate = 0.09090909090909091,
          Items = {2396}
        },
        {
          nRate = 0.09090909090909091,
          Items = {2804}
        }
      }
    }
  },
  nJoinBossContrib = 0
}
Boss.Def.tbLegalBossFightScore = {
  {6000000, 450000},
  {5000000, 337500},
  {4000000, 225000},
  {3000000, 180000},
  {2000000, 135000},
  {1000000, 115000},
  {500000, 67500},
  {300000, 30000},
  {200000, 22500},
  {100000, 16500},
  {50000, 13500},
  {0, 6000}
}
Boss.Def.nMaxFightBossScoreScaleRate = 2
Boss.Def.nFightBossScoreExpireTime = 604800
Boss.Def.BOSS_FIGHT_SCORE_GROUP = 100
Boss.Def.BOSS_FIGHT_SCORE_TIME = 1
Boss.Def.BOSS_FIGHT_SCORE_SCORE = 2
function Boss:GetLimitBossFightScore(pPlayer)
  local nNow = GetTime()
  local nLastServerTime = pPlayer.GetUserValue(Boss.Def.BOSS_FIGHT_SCORE_GROUP, Boss.Def.BOSS_FIGHT_SCORE_TIME)
  local nLastServerScore = pPlayer.GetUserValue(Boss.Def.BOSS_FIGHT_SCORE_GROUP, Boss.Def.BOSS_FIGHT_SCORE_SCORE)
  if nNow - nLastServerTime < Boss.Def.nFightBossScoreExpireTime and nLastServerScore > 0 then
    return nLastServerScore * Boss.Def.nMaxFightBossScoreScaleRate
  end
  local nFightPower = pPlayer.GetFightPower()
  local tbLastInfo = Boss.Def.tbLegalBossFightScore[1]
  for _, tbInfo in ipairs(Boss.Def.tbLegalBossFightScore) do
    if nFightPower > tbInfo[1] then
      return tbInfo[2]
    end
    tbLastInfo = tbInfo
  end
  return tbLastInfo[2]
end
function Boss:UpdateServerBossFightScore(pPlayer, nOrgScore)
  local nNow = GetTime()
  pPlayer.SetUserValue(Boss.Def.BOSS_FIGHT_SCORE_GROUP, Boss.Def.BOSS_FIGHT_SCORE_TIME, nNow)
  pPlayer.SetUserValue(Boss.Def.BOSS_FIGHT_SCORE_GROUP, Boss.Def.BOSS_FIGHT_SCORE_SCORE, nOrgScore)
end
function Boss:GetAuctionRewards()
  local tbCurAwards = Boss.Def.tbAuctionRewards[1]
  for _, tbItem in ipairs(Boss.Def.tbAuctionRewards) do
    if GetTimeFrameState(tbItem.TimeFrame) ~= 1 then
      break
    end
    tbCurAwards = tbItem.Rewards
  end
  return tbCurAwards
end
function Boss:GetBossHpStageInfo(nHpRate)
  for _, tbStageInfo in ipairs(Boss.Def.tbBossHpStage) do
    if nHpRate <= tbStageInfo.HpRate then
      return tbStageInfo.ScoreRate, tbStageInfo.RateTexture, tbStageInfo.Texture
    end
  end
  Log("Error:Wrong in GetBossHpStageInfo")
  return 1, "Points01", "Error:Wrong in GetBossHpStageInfo"
end
function Boss:CanJoinBoss(pPlayer)
  return AsyncBattle:CanStartAsyncBattle(pPlayer) or Map:IsKinMap(pPlayer.nMapTemplateId)
end
function Boss:IsAuctionRewardOnSale()
  local nWeekDay = Lib:GetLocalWeekDay()
  return nWeekDay == 6 or nWeekDay == 7
end
function Boss:GetAuctionRewardScale()
  local nExtraReward = 0
  if Boss:IsAuctionRewardOnSale() then
    nExtraReward = Boss.Def.nWeekendExtraAuctionActivityRate
  end
  return 1 + nExtraReward
end
