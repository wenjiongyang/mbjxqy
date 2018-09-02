Require("CommonScript/GiftSystem/Gift.lua")
Wedding.nSaveGrp = 139
Wedding.nSaveKeyLastMemorialMailMonth = 2
Wedding.nSaveKeyLastMemorialNpcMonth = 3
Wedding.nSaveKeyGender = 4
Wedding.nSaveKeyWeddingLevel = 7
Wedding.nOperationType_Propose = 1
Wedding.nOperationType_Book = 2
Wedding.nOperationType_Open = 3
Wedding.nOperationType_CancelPropose = 4
Wedding.nOperationType_Divorce = 5
Wedding.tbWeddingFurniture = {
  [5239] = 1,
  [5240] = 1,
  [5241] = 1,
  [5242] = 1,
  [5243] = 1,
  [5244] = 1,
  [5245] = 1,
  [5246] = 1,
  [5256] = 8
}
Wedding.tbAllNpc = {
  {
    2374,
    {15590, 13056},
    6
  },
  {
    2374,
    {15596, 12205},
    23
  },
  {
    2374,
    {14696, 12172},
    38
  },
  {
    2374,
    {14675, 13075},
    55
  },
  {
    2374,
    {16009, 13448},
    42
  },
  {
    2374,
    {14443, 15626},
    48
  },
  {
    2374,
    {13939, 15631},
    17
  },
  {
    2374,
    {14886, 14991},
    17
  },
  {
    2374,
    {15369, 14982},
    48
  },
  {
    2374,
    {13963, 17102},
    17
  },
  {
    2374,
    {14274, 17523},
    32
  },
  {
    2374,
    {14799, 16943},
    48
  },
  {
    2374,
    {13786, 18152},
    48
  },
  {
    2374,
    {13781, 17804},
    48
  },
  {
    2374,
    {12797, 17821},
    3
  },
  {
    2374,
    {11271, 17487},
    17
  },
  {
    2374,
    {11271, 16981},
    17
  },
  {
    2374,
    {12000, 17487},
    48
  },
  {
    2374,
    {11998, 16981},
    48
  },
  {
    2374,
    {9254, 15694},
    32
  },
  {
    2374,
    {9254, 14965},
    0
  },
  {
    2374,
    {9983, 15695},
    32
  },
  {
    2374,
    {9983, 14965},
    0
  },
  {
    2374,
    {9202, 12475},
    32
  },
  {
    2374,
    {9195, 11750},
    0
  },
  {
    2374,
    {9704, 11748},
    0
  },
  {
    2374,
    {9703, 12475},
    32
  },
  {
    2374,
    {14013, 12317},
    13
  },
  {
    2388,
    {17404, 12443},
    63
  },
  {
    2388,
    {17401, 12833},
    32
  },
  {
    2374,
    {12501, 16186},
    41
  },
  {
    2374,
    {12359, 14372},
    56
  },
  {
    2374,
    {10730, 14456},
    11
  },
  {
    2374,
    {10742, 16208},
    23
  },
  {
    2375,
    {14943, 14204},
    0
  },
  {
    2375,
    {15304, 14202},
    0
  },
  {
    2375,
    {14473, 17777},
    48
  },
  {
    2375,
    {14478, 18178},
    48
  },
  {
    2375,
    {11273, 17232},
    17
  },
  {
    2375,
    {11999, 17235},
    48
  },
  {
    2375,
    {9645, 15695},
    32
  },
  {
    2375,
    {9646, 14963},
    0
  },
  {
    2375,
    {8537, 13316},
    32
  },
  {
    2375,
    {8959, 13321},
    32
  },
  {
    2375,
    {9477, 12474},
    32
  },
  {
    2375,
    {9481, 11745},
    0
  },
  {
    2375,
    {12093, 12823},
    48
  },
  {
    2375,
    {12093, 12427},
    48
  },
  {
    2390,
    {16957, 12860},
    48
  },
  {
    2390,
    {16967, 12442},
    48
  },
  {
    2376,
    {16763, 12854},
    48
  },
  {
    2376,
    {16756, 12427},
    48
  },
  {
    2386,
    {17152, 12643},
    48
  },
  {
    2370,
    {17377, 12640},
    48
  },
  {
    2362,
    {17768, 12642},
    48
  },
  {
    2387,
    {18190, 12640},
    48
  }
}
Wedding.nBoyNpcTID = 2370
Wedding.nGirlNpcTID = 2362
Wedding.nBoyViewNpcTID = 2370
Wedding.nGirlViewNpcTID = 2370
Wedding.nBubbleRangeNpcTID = 2370
Wedding.nBubbleDistance = 1000
Wedding.nBubblePlayerDistance = 1500
Wedding.tbBubbleMsg = {
  [633] = "若是有机会，我也想披上那一身红色的嫁衣。那个“他”，你可知我的心意？#58",
  [97] = "哇！这是哪家的俊男俏女？真是郎才女貌，天生一对！",
  [190] = "如此气派的迎亲队伍！我得去凑个热闹……#6",
  [2326] = "万叔，已经能听到迎亲队的奏乐了，我们差不多该动身了。#43",
  [625] = "先前有几个孩童在隐香楼前鬼鬼祟祟，侠士的迎亲队可是要多加留意啊！#43",
  [1528] = "新婚快乐！防火防盗防熊孩子，少侠可要担心啊！#116",
  [1829] = "以前师傅常说“山下的女人是老虎”，我倒是愿意还俗娶如此漂亮的“老虎”！#13",
  [2279] = "前些日子红娘在家具坊定制了一批上等家具，说是要等侠士的成婚纪念日时给个惊喜！#43"
}
Wedding.szBubbleTime = "2"
Wedding.nTourMapTemplateId = 10
Wedding.nTourMsgListTimeOut = 180
Wedding.nTourMsgListGoNpcTId = 2373
Wedding.szTempNpcBubbleTime = "5"
Wedding.szTempNpcBubbleRange = 1000
Wedding.nWeddingFeelDay = 172800
Wedding.nTourDelayOfflineTime = 1800
Wedding.nTourSynMapPosNpcTId = 2362
Wedding.tbPath = {
  [1] = {
    [2386] = {
      {
        nTime = 180,
        tbPos = {17096, 12642},
        tbTrigger = {
          1,
          2,
          3,
          4
        },
        nDir = 50
      }
    },
    [2370] = {
      {
        nTime = 180,
        tbPos = {17377, 12640},
        tbTrigger = {
          10,
          11,
          12,
          13,
          10,
          11,
          10,
          13,
          12,
          11,
          14,
          15
        }
      }
    },
    [2362] = {
      {
        nTime = 180,
        tbPos = {17768, 12642}
      }
    },
    [2387] = {
      {
        nTime = 180,
        tbPos = {18190, 12640}
      }
    }
  },
  [2] = {
    [2386] = {
      {
        nTime = nil,
        tbPos = {16263, 12663}
      }
    },
    [2370] = {
      {
        nTime = nil,
        tbPos = {16263, 12663}
      }
    },
    [2362] = {
      {
        nTime = nil,
        tbPos = {16263, 12663}
      }
    },
    [2387] = {
      {
        nTime = nil,
        tbPos = {16263, 12663}
      }
    }
  },
  [3] = {
    [2386] = {
      {
        nTime = nil,
        tbPos = {15597, 13593},
        tbTrigger = {16}
      }
    },
    [2370] = {
      {
        nTime = nil,
        tbPos = {15597, 13593}
      }
    },
    [2362] = {
      {
        nTime = nil,
        tbPos = {15597, 13593}
      }
    },
    [2387] = {
      {
        nTime = nil,
        tbPos = {15597, 13593}
      }
    }
  },
  [4] = {
    [2386] = {
      {
        nTime = nil,
        tbPos = {15136, 13779}
      }
    },
    [2370] = {
      {
        nTime = nil,
        tbPos = {15136, 13779}
      }
    },
    [2362] = {
      {
        nTime = nil,
        tbPos = {15136, 13779}
      }
    },
    [2387] = {
      {
        nTime = nil,
        tbPos = {15136, 13779}
      }
    }
  },
  [5] = {
    [2386] = {
      {
        nTime = nil,
        tbPos = {15138, 15325},
        tbTrigger = {17}
      }
    },
    [2370] = {
      {
        nTime = nil,
        tbPos = {15138, 15325}
      }
    },
    [2362] = {
      {
        nTime = nil,
        tbPos = {15138, 15325}
      }
    },
    [2387] = {
      {
        nTime = nil,
        tbPos = {15138, 15325}
      }
    }
  },
  [6] = {
    [2386] = {
      {
        nTime = nil,
        tbPos = {14212, 15334}
      }
    },
    [2370] = {
      {
        nTime = nil,
        tbPos = {14212, 15334}
      }
    },
    [2362] = {
      {
        nTime = nil,
        tbPos = {14212, 15334}
      }
    },
    [2387] = {
      {
        nTime = nil,
        tbPos = {14212, 15334}
      }
    }
  },
  [7] = {
    [2386] = {
      {
        nTime = nil,
        tbPos = {14208, 17280},
        tbTrigger = {18}
      }
    },
    [2370] = {
      {
        nTime = nil,
        tbPos = {14208, 17280}
      }
    },
    [2362] = {
      {
        nTime = nil,
        tbPos = {14208, 17280}
      }
    },
    [2387] = {
      {
        nTime = nil,
        tbPos = {14208, 17280}
      }
    }
  },
  [8] = {
    [2386] = {
      {
        nTime = nil,
        tbPos = {14808, 17284}
      }
    },
    [2370] = {
      {
        nTime = nil,
        tbPos = {14808, 17284}
      }
    },
    [2362] = {
      {
        nTime = nil,
        tbPos = {14808, 17284}
      }
    },
    [2387] = {
      {
        nTime = nil,
        tbPos = {14808, 17284}
      }
    }
  },
  [9] = {
    [2386] = {
      {
        nTime = nil,
        tbPos = {14780, 17983},
        tbTrigger = {19}
      }
    },
    [2370] = {
      {
        nTime = nil,
        tbPos = {14780, 17983}
      }
    },
    [2362] = {
      {
        nTime = nil,
        tbPos = {14780, 17983}
      }
    },
    [2387] = {
      {
        nTime = nil,
        tbPos = {14780, 17983}
      }
    }
  },
  [10] = {
    [2386] = {
      {
        nTime = nil,
        tbPos = {12694, 18060}
      }
    },
    [2370] = {
      {
        nTime = nil,
        tbPos = {12694, 18060}
      }
    },
    [2362] = {
      {
        nTime = nil,
        tbPos = {12694, 18060}
      }
    },
    [2387] = {
      {
        nTime = nil,
        tbPos = {12694, 18060}
      }
    }
  },
  [11] = {
    [2386] = {
      {
        nTime = nil,
        tbPos = {11646, 18020},
        tbTrigger = {20}
      }
    },
    [2370] = {
      {
        nTime = nil,
        tbPos = {11646, 18020}
      }
    },
    [2362] = {
      {
        nTime = nil,
        tbPos = {11646, 18020}
      }
    },
    [2387] = {
      {
        nTime = nil,
        tbPos = {11646, 18020}
      }
    }
  },
  [12] = {
    [2386] = {
      {
        nTime = 199,
        tbPos = {11635, 16786},
        tbTrigger = {
          100,
          101,
          102,
          103,
          104,
          105,
          106,
          107,
          130,
          131,
          132,
          133,
          134,
          136,
          133,
          132,
          131,
          130,
          137,
          138,
          134,
          135,
          108,
          109,
          30,
          120,
          121,
          5
        }
      }
    },
    [2370] = {
      {
        nTime = 199,
        tbPos = {11634, 17066},
        nDir = 32,
        tbTrigger = {122, 123}
      }
    },
    [2362] = {
      {
        nTime = 199,
        tbPos = {11635, 17457},
        tbTrigger = {5}
      }
    },
    [2387] = {
      {
        nTime = 199,
        tbPos = {11634, 17853}
      }
    }
  },
  [13] = {
    [2386] = {
      {
        nTime = nil,
        tbPos = {11645, 16304}
      }
    },
    [2370] = {
      {
        nTime = nil,
        tbPos = {11645, 16304}
      }
    },
    [2362] = {
      {
        nTime = nil,
        tbPos = {11645, 16304}
      }
    },
    [2387] = {
      {
        nTime = nil,
        tbPos = {11645, 16304}
      }
    }
  },
  [14] = {
    [2386] = {
      {
        nTime = nil,
        tbPos = {10316, 15318},
        tbTrigger = {18}
      }
    },
    [2370] = {
      {
        nTime = nil,
        tbPos = {10316, 15318}
      }
    },
    [2362] = {
      {
        nTime = nil,
        tbPos = {10316, 15318}
      }
    },
    [2387] = {
      {
        nTime = nil,
        tbPos = {10316, 15318}
      }
    }
  },
  [15] = {
    [2386] = {
      {
        nTime = nil,
        tbPos = {8726, 15325},
        tbTrigger = {16}
      }
    },
    [2370] = {
      {
        nTime = nil,
        tbPos = {8726, 15325}
      }
    },
    [2362] = {
      {
        nTime = nil,
        tbPos = {8726, 15325}
      }
    },
    [2387] = {
      {
        nTime = nil,
        tbPos = {8726, 15325}
      }
    }
  },
  [16] = {
    [2386] = {
      {
        nTime = nil,
        tbPos = {8719, 12159}
      }
    },
    [2370] = {
      {
        nTime = nil,
        tbPos = {8719, 12159}
      }
    },
    [2362] = {
      {
        nTime = nil,
        tbPos = {8719, 12159}
      }
    },
    [2387] = {
      {
        nTime = nil,
        tbPos = {8719, 12159}
      }
    }
  },
  [17] = {
    [2386] = {
      {
        nTime = 256,
        tbPos = {9927, 12107},
        tbTrigger = {
          200,
          201,
          202,
          203,
          204,
          205,
          206,
          207,
          208,
          209,
          210,
          211,
          212,
          250,
          251,
          252,
          250,
          251,
          252,
          253,
          250,
          251,
          252,
          254,
          250,
          252,
          253,
          254,
          213,
          214,
          215,
          216,
          217,
          230,
          231,
          5
        }
      }
    },
    [2370] = {
      {
        nTime = 256,
        tbPos = {9647, 12106},
        tbTrigger = {
          232,
          233,
          30
        }
      }
    },
    [2362] = {
      {
        nTime = 256,
        tbPos = {9252, 12110},
        tbTrigger = {5}
      }
    },
    [2387] = {
      {
        nTime = 256,
        tbPos = {8865, 12111}
      }
    }
  },
  [18] = {
    [2386] = {
      {
        nTime = nil,
        tbPos = {11633, 12111}
      }
    },
    [2370] = {
      {
        nTime = nil,
        tbPos = {11633, 12111}
      }
    },
    [2362] = {
      {
        nTime = nil,
        tbPos = {11633, 12111}
      }
    },
    [2387] = {
      {
        nTime = nil,
        tbPos = {11633, 12111}
      }
    }
  },
  [19] = {
    [2386] = {
      {
        nTime = nil,
        tbPos = {11634, 12637}
      }
    },
    [2370] = {
      {
        nTime = nil,
        tbPos = {11634, 12637}
      }
    },
    [2362] = {
      {
        nTime = nil,
        tbPos = {11634, 12637}
      }
    },
    [2387] = {
      {
        nTime = nil,
        tbPos = {11634, 12637}
      }
    }
  },
  [20] = {
    [2386] = {
      {
        nTime = nil,
        tbPos = {14167, 12635}
      }
    },
    [2370] = {
      {
        nTime = nil,
        tbPos = {14167, 12635}
      }
    },
    [2362] = {
      {
        nTime = nil,
        tbPos = {14167, 12635}
      }
    },
    [2387] = {
      {
        nTime = nil,
        tbPos = {14167, 12635}
      }
    }
  },
  [21] = {
    [2386] = {
      {
        nTime = nil,
        tbPos = {14515, 11625}
      }
    },
    [2370] = {
      {
        nTime = nil,
        tbPos = {14515, 11625}
      }
    },
    [2362] = {
      {
        nTime = nil,
        tbPos = {14515, 11625}
      }
    },
    [2387] = {
      {
        nTime = nil,
        tbPos = {14515, 11625}
      }
    }
  },
  [22] = {
    [2386] = {
      {
        nTime = nil,
        tbPos = {15625, 11625}
      }
    },
    [2370] = {
      {
        nTime = nil,
        tbPos = {15625, 11625}
      }
    },
    [2362] = {
      {
        nTime = nil,
        tbPos = {15625, 11625}
      }
    },
    [2387] = {
      {
        nTime = nil,
        tbPos = {15625, 11625}
      }
    }
  },
  [23] = {
    [2386] = {
      {
        nTime = nil,
        tbPos = {16174, 12664}
      }
    },
    [2370] = {
      {
        nTime = nil,
        tbPos = {16174, 12664}
      }
    },
    [2362] = {
      {
        nTime = nil,
        tbPos = {16174, 12664}
      }
    },
    [2387] = {
      {
        nTime = nil,
        tbPos = {16174, 12664}
      }
    }
  },
  [24] = {
    [2386] = {
      {
        nTime = 15,
        tbPos = {17095, 12641},
        tbTrigger = {300, 301}
      }
    },
    [2370] = {
      {
        nTime = 15,
        tbPos = {16841, 12641}
      }
    },
    [2362] = {
      {
        nTime = 15,
        tbPos = {16450, 12638}
      }
    },
    [2387] = {
      {
        nTime = 15,
        tbPos = {16057, 12640}
      }
    }
  },
  [25] = {
    [2386] = {
      {
        nTime = nil,
        tbPos = {17095, 12641}
      }
    },
    [2370] = {
      {
        nTime = nil,
        tbPos = {16841, 12641}
      }
    },
    [2362] = {
      {
        nTime = nil,
        tbPos = {16450, 12638}
      }
    },
    [2387] = {
      {
        nTime = nil,
        tbPos = {16057, 12640}
      }
    }
  }
}
Wedding.tbTrigger = {
  [1] = {
    nTime = 5,
    tbExe = {
      {
        szType = "SendNotify",
        tbParam = {
          szMsg = "[FFFE0D]「%s」[-]和[FFFE0D]「%s」[-]即将举行花轿游城，大家快去[FFFE0D]襄阳城月老[-]那观礼送祝福、抢喜糖吧，距离开始还有[FFFE0D]3分钟[-]。",
          nMinLevel = 1,
          nMaxLevel = 999
        }
      }
    }
  },
  [2] = {
    nTime = 55,
    tbExe = {
      {
        szType = "SendNotify",
        tbParam = {
          szMsg = "[FFFE0D]「%s」[-]和[FFFE0D]「%s」[-]即将举行花轿游城，大家快去[FFFE0D]襄阳城月老[-]那观礼送祝福、抢喜糖吧，距离开始还有[FFFE0D]2分钟[-]。",
          nMinLevel = 1,
          nMaxLevel = 999
        }
      }
    }
  },
  [3] = {
    nTime = 60,
    tbExe = {
      {
        szType = "SendNotify",
        tbParam = {
          szMsg = "[FFFE0D]「%s」[-]和[FFFE0D]「%s」[-]即将举行花轿游城，大家快去[FFFE0D]襄阳城月老[-]那观礼送祝福、抢喜糖吧，距离开始还有[FFFE0D]1分钟[-]。",
          nMinLevel = 1,
          nMaxLevel = 999
        }
      }
    }
  },
  [4] = {
    nTime = 59,
    tbExe = {
      {
        szType = "SendNotify",
        tbParam = {
          szMsg = "[FFFE0D]「%s」[-]和[FFFE0D]「%s」[-]正在[FFFE0D]襄阳城[-]举行花轿游城，大家快去观礼送祝福、抢喜糖吧。",
          nMinLevel = 1,
          nMaxLevel = 999
        }
      }
    }
  },
  [5] = {
    nTime = 1,
    tbExe = {
      {
        szType = "SendNotify",
        tbParam = {
          szMsg = "[FFFE0D]「%s」[-]和[FFFE0D]「%s」[-]正在[FFFE0D]襄阳城[-]举行花轿游城，大家快去观礼送祝福、抢喜糖吧。",
          nMinLevel = 1,
          nMaxLevel = 999
        }
      }
    }
  },
  [10] = {
    nTime = 15,
    tbExe = {
      {
        szType = "NpcBubbleTalk",
        tbParam = {
          nNpcTId = 2386,
          szBubble = "新婚快乐，百年好合！#66#66#66#66#66#66#66",
          szBubbleTime = "10"
        }
      },
      {
        szType = "NpcBubbleTalk",
        tbParam = {
          nNpcTId = 2387,
          szBubble = "新婚快乐，百年好合！#66#66#66#66#66#66#66",
          szBubbleTime = "10"
        }
      }
    }
  },
  [11] = {
    nTime = 15,
    tbExe = {
      {
        szType = "NpcBubbleTalk",
        tbParam = {
          nNpcTId = 2386,
          szBubble = "花轿准备就绪，等待良时起轿。#124#124",
          szBubbleTime = "10"
        }
      },
      {
        szType = "NpcBubbleTalk",
        tbParam = {
          nNpcTId = 2387,
          szBubble = "花轿准备就绪，等待良时起轿。#124#124",
          szBubbleTime = "10"
        }
      }
    }
  },
  [12] = {
    nTime = 15,
    tbExe = {
      {
        szType = "NpcBubbleTalk",
        tbParam = {
          nNpcTId = 2386,
          szBubble = "新娘好漂亮啊，等我长大了我也要这么美美哒！#13#13",
          szBubbleTime = "10"
        }
      },
      {
        szType = "NpcBubbleTalk",
        tbParam = {
          nNpcTId = 2387,
          szBubble = "新娘好漂亮啊，等我长大了我也要这么美美哒！#13#13",
          szBubbleTime = "10"
        }
      }
    }
  },
  [13] = {
    nTime = 15,
    tbExe = {
      {
        szType = "NpcBubbleTalk",
        tbParam = {
          nNpcTId = 2386,
          szBubble = "有情人终成眷属呐！祝你们恩恩爱爱，甜甜美美！#11#11#11",
          szBubbleTime = "10"
        }
      },
      {
        szType = "NpcBubbleTalk",
        tbParam = {
          nNpcTId = 2387,
          szBubble = "有情人终成眷属呐！祝你们恩恩爱爱，甜甜美美！#11#11#11",
          szBubbleTime = "10"
        }
      }
    }
  },
  [14] = {
    nTime = 15,
    tbExe = {
      {
        szType = "NpcBubbleTalk",
        tbParam = {
          nNpcTId = 2386,
          szBubble = "良时已到，准备起轿！#124#124#124",
          szBubbleTime = "10"
        }
      },
      {
        szType = "NpcBubbleTalk",
        tbParam = {
          nNpcTId = 2387,
          szBubble = "良时已到，准备起轿！#124#124#124",
          szBubbleTime = "10"
        }
      },
      {
        szType = "NpcBubbleTalk",
        tbParam = {
          nNpcTId = 2388,
          szBubble = "良时已到，准备起轿！#124#124#124",
          szBubbleTime = "10"
        }
      },
      {
        szType = "NpcBubbleTalk",
        tbParam = {
          nNpcTId = 2376,
          szBubble = "良时已到，准备起轿！#124#124#124",
          szBubbleTime = "10"
        }
      },
      {
        szType = "NpcBubbleTalk",
        tbParam = {
          nNpcTId = 2390,
          szBubble = "良时已到，准备起轿！#124#124#124",
          szBubbleTime = "10"
        }
      }
    }
  },
  [15] = {
    nTime = 15,
    tbExe = {
      {
        szType = "NpcBubbleTalk",
        tbParam = {
          nNpcTId = 2386,
          szBubble = "起轿~#124#124#124",
          szBubbleTime = "10"
        }
      },
      {
        szType = "NpcBubbleTalk",
        tbParam = {
          nNpcTId = 2387,
          szBubble = "起轿~#124#124#124",
          szBubbleTime = "10"
        }
      },
      {
        szType = "NpcBubbleTalk",
        tbParam = {
          nNpcTId = 2388,
          szBubble = "起轿~#124#124#124",
          szBubbleTime = "10"
        }
      },
      {
        szType = "NpcBubbleTalk",
        tbParam = {
          nNpcTId = 2376,
          szBubble = "起轿~#124#124#124",
          szBubbleTime = "10"
        }
      },
      {
        szType = "NpcBubbleTalk",
        tbParam = {
          nNpcTId = 2390,
          szBubble = "起轿~#124#124#124",
          szBubbleTime = "10"
        }
      }
    }
  },
  [16] = {
    nTime = 1,
    tbExe = {
      {
        szType = "NpcBubbleTalk",
        tbParam = {
          nNpcTId = 2386,
          szBubble = "今日结成幸福侣，毕生共绘锦绣图！祝你们幸福美满。#11#11#11",
          szBubbleTime = "10"
        }
      },
      {
        szType = "NpcBubbleTalk",
        tbParam = {
          nNpcTId = 2387,
          szBubble = "今日结成幸福侣，毕生共绘锦绣图！祝你们幸福美满。#11#11#11",
          szBubbleTime = "10"
        }
      }
    }
  },
  [17] = {
    nTime = 1,
    tbExe = {
      {
        szType = "NpcBubbleTalk",
        tbParam = {
          nNpcTId = 2386,
          szBubble = "百年修得同船渡，千年修得共枕眠！祝你们恩恩爱爱。#11#11#11",
          szBubbleTime = "10"
        }
      },
      {
        szType = "NpcBubbleTalk",
        tbParam = {
          nNpcTId = 2387,
          szBubble = "百年修得同船渡，千年修得共枕眠！祝你们恩恩爱爱。#11#11#11",
          szBubbleTime = "10"
        }
      }
    }
  },
  [18] = {
    nTime = 1,
    tbExe = {
      {
        szType = "NpcBubbleTalk",
        tbParam = {
          nNpcTId = 2386,
          szBubble = "新婚永结同心果，燕尔欣成并蒂花！祝你们永结同心。#11#11#11",
          szBubbleTime = "10"
        }
      },
      {
        szType = "NpcBubbleTalk",
        tbParam = {
          nNpcTId = 2387,
          szBubble = "新婚永结同心果，燕尔欣成并蒂花！祝你们永结同心。#11#11#11",
          szBubbleTime = "10"
        }
      }
    }
  },
  [19] = {
    nTime = 1,
    tbExe = {
      {
        szType = "NpcBubbleTalk",
        tbParam = {
          nNpcTId = 2386,
          szBubble = "鸳鸯比翼新婚乐，龙凤呈祥花烛辉！祝你们白头偕老。#11#11#11",
          szBubbleTime = "10"
        }
      },
      {
        szType = "NpcBubbleTalk",
        tbParam = {
          nNpcTId = 2387,
          szBubble = "鸳鸯比翼新婚乐，龙凤呈祥花烛辉！祝你们白头偕老。#11#11#11",
          szBubbleTime = "10"
        }
      }
    }
  },
  [20] = {
    nTime = 1,
    tbExe = {
      {
        szType = "NpcBubbleTalk",
        tbParam = {
          nNpcTId = 2386,
          szBubble = "连理枝头蝶对舞，碧空万里鸾凤鸣！祝你们百年好合。#11#11#11",
          szBubbleTime = "10"
        }
      },
      {
        szType = "NpcBubbleTalk",
        tbParam = {
          nNpcTId = 2387,
          szBubble = "连理枝头蝶对舞，碧空万里鸾凤鸣！祝你们百年好合。#11#11#11",
          szBubbleTime = "10"
        }
      }
    }
  },
  [30] = {
    nTime = 7,
    tbExe = {
      {
        szType = "ClearTempNpc"
      }
    }
  },
  [100] = {
    nTime = 2,
    tbExe = {
      {
        szType = "AddTempNpc",
        tbParam = {
          szGroup = "wanjincai",
          nNpcTID = 2624,
          nX = 11353,
          nY = 16195,
          nDir = 0
        }
      },
      {
        szType = "AddTempNpc",
        tbParam = {
          szGroup = "lingengxin",
          nNpcTID = 2625,
          nX = 11357,
          nY = 16028,
          nDir = 0
        }
      },
      {
        szType = "TempNpcGoAndTalk",
        tbParam = {
          szGroup = "wanjincai",
          nX = 11358,
          nY = 17207,
          nDir = 13,
          szBubble = "恭喜恭喜！"
        }
      },
      {
        szType = "TempNpcGoAndTalk",
        tbParam = {
          szGroup = "lingengxin",
          nX = 11354,
          nY = 16920,
          nDir = 13,
          szBubble = "恭喜恭喜！"
        }
      }
    }
  },
  [101] = {
    nTime = 12,
    tbExe = {
      {
        szType = "TempNpcBubbleTalk",
        tbParam = {
          szGroup = "wanjincai",
          nNpcTId = 2624,
          szBubble = "少侠莫要紧张，我万某可不是来抢亲的哦！#6",
          szBubbleTime = "8"
        }
      }
    }
  },
  [102] = {
    nTime = 8,
    tbExe = {
      {
        szType = "TempNpcBubbleTalk",
        tbParam = {
          szGroup = "lingengxin",
          nNpcTId = 2625,
          szBubble = "哈哈~这事也就只有财大气粗的万叔能办到。#121",
          szBubbleTime = "8"
        }
      }
    }
  },
  [103] = {
    nTime = 8,
    tbExe = {
      {
        szType = "TempNpcBubbleTalk",
        tbParam = {
          szGroup = "wanjincai",
          nNpcTId = 2624,
          szBubble = "听闻二位今日成婚，我特差人提前在此布置了烟花盛宴，以贺二位新婚快乐……#2",
          szBubbleTime = "8"
        }
      }
    }
  },
  [104] = {
    nTime = 8,
    tbExe = {
      {
        szType = "TempNpcBubbleTalk",
        tbParam = {
          szGroup = "lingengxin",
          nNpcTId = 2625,
          szBubble = "为了此事，我和万叔可没少奔波哦！#23",
          szBubbleTime = "8"
        }
      }
    }
  },
  [105] = {
    nTime = 8,
    tbExe = {
      {
        szType = "TempNpcBubbleTalk",
        tbParam = {
          szGroup = "wanjincai",
          nNpcTId = 2624,
          szBubble = "万某祝二位永结同心、白头偕老！#58",
          szBubbleTime = "8"
        }
      }
    }
  },
  [106] = {
    nTime = 8,
    tbExe = {
      {
        szType = "TempNpcBubbleTalk",
        tbParam = {
          szGroup = "lingengxin",
          nNpcTId = 2625,
          szBubble = "在下也祝二位幸福美满、恩恩爱爱！#58",
          szBubbleTime = "8"
        }
      }
    }
  },
  [107] = {
    nTime = 8,
    tbExe = {
      {
        szType = "TempNpcBubbleTalk",
        tbParam = {
          szGroup = "wanjincai",
          nNpcTId = 2624,
          szBubble = "燃放烟花~#69#69",
          szBubbleTime = "8"
        }
      },
      {
        szType = "TempNpcBubbleTalk",
        tbParam = {
          szGroup = "lingengxin",
          nNpcTId = 2625,
          szBubble = "燃放烟花~#69#69",
          szBubbleTime = "8"
        }
      },
      {
        szType = "PlayFirework",
        tbParam = {nId = 50}
      }
    }
  },
  [108] = {
    nTime = 8,
    tbExe = {
      {
        szType = "TempNpcBubbleTalk",
        tbParam = {
          szGroup = "wanjincai",
          nNpcTId = 2624,
          szBubble = "烟花盛宴已结束，万某先行告辞，再次祝二位新婚快乐！",
          szBubbleTime = "8"
        }
      },
      {
        szType = "TempNpcBubbleTalk",
        tbParam = {
          szGroup = "lingengxin",
          nNpcTId = 2625,
          szBubble = "告辞~",
          szBubbleTime = "8"
        }
      }
    }
  },
  [109] = {
    nTime = 3,
    tbExe = {
      {
        szType = "TempNpcGoAndTalk",
        tbParam = {
          szGroup = "wanjincai",
          nX = 11353,
          nY = 16195
        }
      },
      {
        szType = "TempNpcGoAndTalk",
        tbParam = {
          szGroup = "lingengxin",
          nX = 11357,
          nY = 16028
        }
      }
    }
  },
  [120] = {
    nTime = 2,
    tbExe = {
      {
        szType = "NpcBubbleTalk",
        tbParam = {
          nNpcTId = 2386,
          szBubble = "[FFFE0D]喜糖[-]已经准备好了，新郎新娘可以派喜糖啦！#10#10#10#10",
          szBubbleTime = "10"
        }
      },
      {
        szType = "NpcBubbleTalk",
        tbParam = {
          nNpcTId = 2387,
          szBubble = "[FFFE0D]喜糖[-]已经准备好了，新郎新娘可以派喜糖啦！#10#10#10#10",
          szBubbleTime = "10"
        }
      },
      {
        szType = "RetsetCandyTimes"
      },
      {szType = "StartCandy"}
    }
  },
  [121] = {
    nTime = 10,
    tbExe = {
      {
        szType = "NpcBubbleTalk",
        tbParam = {
          nNpcTId = 2386,
          szBubble = "派喜糖时间持续[FFFE0D]90秒[-]哦，新郎新娘快派喜糖吧！#10#10#10#10",
          szBubbleTime = "10"
        }
      },
      {
        szType = "NpcBubbleTalk",
        tbParam = {
          nNpcTId = 2387,
          szBubble = "派喜糖时间持续[FFFE0D]90秒[-]哦，新郎新娘快派喜糖吧！#10#10#10#10",
          szBubbleTime = "10"
        }
      }
    }
  },
  [122] = {
    nTime = 184,
    tbExe = {
      {
        szType = "NpcBubbleTalk",
        tbParam = {
          nNpcTId = 2386,
          szBubble = "准备起轿~",
          szBubbleTime = "10"
        }
      },
      {
        szType = "NpcBubbleTalk",
        tbParam = {
          nNpcTId = 2387,
          szBubble = "准备起轿~",
          szBubbleTime = "10"
        }
      }
    }
  },
  [123] = {
    nTime = 15,
    tbExe = {
      {
        szType = "NpcBubbleTalk",
        tbParam = {
          nNpcTId = 2386,
          szBubble = "起轿~#124#124#124",
          szBubbleTime = "10"
        }
      },
      {
        szType = "NpcBubbleTalk",
        tbParam = {
          nNpcTId = 2387,
          szBubble = "起轿~#124#124#124",
          szBubbleTime = "10"
        }
      },
      {szType = "EndCandy"}
    }
  },
  [130] = {
    nTime = 2,
    tbExe = {
      {
        szType = "PlayFirework",
        tbParam = {nId = 51}
      }
    }
  },
  [131] = {
    nTime = 2,
    tbExe = {
      {
        szType = "PlayFirework",
        tbParam = {nId = 52}
      }
    }
  },
  [132] = {
    nTime = 2,
    tbExe = {
      {
        szType = "PlayFirework",
        tbParam = {nId = 53}
      }
    }
  },
  [133] = {
    nTime = 2,
    tbExe = {
      {
        szType = "PlayFirework",
        tbParam = {nId = 54}
      }
    }
  },
  [134] = {
    nTime = 2,
    tbExe = {
      {
        szType = "PlayFirework",
        tbParam = {nId = 55}
      }
    }
  },
  [135] = {
    nTime = 2,
    tbExe = {
      {
        szType = "PlayFirework",
        tbParam = {nId = 56}
      }
    }
  },
  [136] = {
    nTime = 3,
    tbExe = {
      {
        szType = "PlayFirework",
        tbParam = {nId = 50}
      }
    }
  },
  [137] = {
    nTime = 2,
    tbExe = {
      {
        szType = "PlayFirework",
        tbParam = {nId = 51}
      },
      {
        szType = "PlayFirework",
        tbParam = {nId = 53}
      }
    }
  },
  [138] = {
    nTime = 2,
    tbExe = {
      {
        szType = "PlayFirework",
        tbParam = {nId = 52}
      },
      {
        szType = "PlayFirework",
        tbParam = {nId = 54}
      }
    }
  },
  [200] = {
    nTime = 2,
    tbExe = {
      {
        szType = "AddTempNpc",
        tbParam = {
          szGroup = "xiaoziyan",
          nNpcTID = 2626,
          nX = 10404,
          nY = 11917,
          nDir = 0
        }
      },
      {
        szType = "AddTempNpc",
        tbParam = {
          szGroup = "xiaoyinfang",
          nNpcTID = 2627,
          nX = 10600,
          nY = 11915,
          nDir = 0
        }
      },
      {
        szType = "AddTempNpc",
        tbParam = {
          szGroup = "xiaoyintong",
          nNpcTID = 2628,
          nX = 10799,
          nY = 11914,
          nDir = 0
        }
      },
      {
        szType = "TempNpcGoAndTalk",
        tbParam = {
          szGroup = "xiaoziyan",
          nX = 9588,
          nY = 11827,
          nDir = 0,
          szBubble = "好气派的婚礼啊！#10"
        }
      },
      {
        szType = "TempNpcGoAndTalk",
        tbParam = {
          szGroup = "xiaoyinfang",
          nX = 9758,
          nY = 12280,
          nDir = 30,
          szBubble = "哇！好漂亮的新娘啊~#13"
        }
      },
      {
        szType = "TempNpcGoAndTalk",
        tbParam = {
          szGroup = "xiaoyintong",
          nX = 9755,
          nY = 11828,
          nDir = 0,
          szBubble = "我也想当新娘……#10"
        }
      }
    }
  },
  [201] = {
    nTime = 14,
    tbExe = {
      {
        szType = "TempNpcBubbleTalk",
        tbParam = {
          szGroup = "xiaoyintong",
          nNpcTId = 2628,
          szBubble = "呐~其实呢，我们是来送祝福的哟，小紫烟你先说。#32",
          szBubbleTime = "8"
        }
      }
    }
  },
  [202] = {
    nTime = 8,
    tbExe = {
      {
        szType = "TempNpcBubbleTalk",
        tbParam = {
          szGroup = "xiaoziyan",
          nNpcTId = 2626,
          szBubble = "小紫烟祝新郎越来越帅，新娘越来越美！#118",
          szBubbleTime = "8"
        }
      }
    }
  },
  [203] = {
    nTime = 8,
    tbExe = {
      {
        szType = "TempNpcBubbleTalk",
        tbParam = {
          szGroup = "xiaoziyan",
          nNpcTId = 2626,
          szBubble = "有空常来我家听雨舫做客哦~#1",
          szBubbleTime = "8"
        }
      }
    }
  },
  [204] = {
    nTime = 8,
    tbExe = {
      {
        szType = "TempNpcBubbleTalk",
        tbParam = {
          szGroup = "xiaoyinfang",
          nNpcTId = 2626,
          szBubble = "新郎凭什么能娶到这么漂亮的新娘？哼！可敢与我上比武台比划比划？#119",
          szBubbleTime = "8"
        }
      }
    }
  },
  [205] = {
    nTime = 8,
    tbExe = {
      {
        szType = "TempNpcBubbleTalk",
        tbParam = {
          szGroup = "xiaoyintong",
          nNpcTId = 2628,
          szBubble = "#30小殷童？别打岔，按咱们事先说好的进行……",
          szBubbleTime = "8"
        }
      }
    }
  },
  [206] = {
    nTime = 8,
    tbExe = {
      {
        szType = "TempNpcBubbleTalk",
        tbParam = {
          szGroup = "xiaoyinfang",
          nNpcTId = 2626,
          szBubble = "好吧好吧~小殷方也祝新郎新娘恩恩爱爱，白头偕老！#124",
          szBubbleTime = "8"
        }
      }
    }
  },
  [207] = {
    nTime = 8,
    tbExe = {
      {
        szType = "TempNpcBubbleTalk",
        tbParam = {
          szGroup = "xiaoyintong",
          nNpcTId = 2628,
          szBubble = "呐~小殷童祝新郎新娘永结同心、百年好合哦！#12",
          szBubbleTime = "8"
        }
      }
    }
  },
  [208] = {
    nTime = 8,
    tbExe = {
      {
        szType = "TempNpcBubbleTalk",
        tbParam = {
          szGroup = "xiaoyintong",
          nNpcTId = 2628,
          szBubble = "#116嘻嘻~好戏还在后头呢，小殷方、小紫烟，准备一下……",
          szBubbleTime = "8"
        }
      }
    }
  },
  [209] = {
    nTime = 8,
    tbExe = {
      {
        szType = "TempNpcBubbleTalk",
        tbParam = {
          szGroup = "xiaoziyan",
          nNpcTId = 2626,
          szBubble = "三#8",
          szBubbleTime = "5"
        }
      },
      {
        szType = "TempNpcBubbleTalk",
        tbParam = {
          szGroup = "xiaoyinfang",
          nNpcTId = 2626,
          szBubble = "三#8",
          szBubbleTime = "5"
        }
      },
      {
        szType = "TempNpcBubbleTalk",
        tbParam = {
          szGroup = "xiaoyintong",
          nNpcTId = 2628,
          szBubble = "三#8",
          szBubbleTime = "5"
        }
      }
    }
  },
  [210] = {
    nTime = 5,
    tbExe = {
      {
        szType = "TempNpcBubbleTalk",
        tbParam = {
          szGroup = "xiaoziyan",
          nNpcTId = 2626,
          szBubble = "二#7",
          szBubbleTime = "5"
        }
      },
      {
        szType = "TempNpcBubbleTalk",
        tbParam = {
          szGroup = "xiaoyinfang",
          nNpcTId = 2626,
          szBubble = "二#7",
          szBubbleTime = "5"
        }
      },
      {
        szType = "TempNpcBubbleTalk",
        tbParam = {
          szGroup = "xiaoyintong",
          nNpcTId = 2628,
          szBubble = "二#7",
          szBubbleTime = "5"
        }
      }
    }
  },
  [211] = {
    nTime = 5,
    tbExe = {
      {
        szType = "TempNpcBubbleTalk",
        tbParam = {
          szGroup = "xiaoziyan",
          nNpcTId = 2626,
          szBubble = "一#124",
          szBubbleTime = "5"
        }
      },
      {
        szType = "TempNpcBubbleTalk",
        tbParam = {
          szGroup = "xiaoyinfang",
          nNpcTId = 2626,
          szBubble = "一#124",
          szBubbleTime = "5"
        }
      },
      {
        szType = "TempNpcBubbleTalk",
        tbParam = {
          szGroup = "xiaoyintong",
          nNpcTId = 2628,
          szBubble = "一#124",
          szBubbleTime = "5"
        }
      }
    }
  },
  [212] = {
    nTime = 5,
    tbExe = {
      {
        szType = "TempNpcBubbleTalk",
        tbParam = {
          szGroup = "xiaoziyan",
          nNpcTId = 2626,
          szBubble = "新婚快乐~#66#66",
          szBubbleTime = "8"
        }
      },
      {
        szType = "TempNpcBubbleTalk",
        tbParam = {
          szGroup = "xiaoyinfang",
          nNpcTId = 2626,
          szBubble = "新婚快乐~#66#66",
          szBubbleTime = "8"
        }
      },
      {
        szType = "TempNpcBubbleTalk",
        tbParam = {
          szGroup = "xiaoyintong",
          nNpcTId = 2628,
          szBubble = "新婚快乐~#66#66",
          szBubbleTime = "8"
        }
      }
    }
  },
  [213] = {
    nTime = 5,
    tbExe = {
      {
        szType = "TempNpcBubbleTalk",
        tbParam = {
          szGroup = "xiaoziyan",
          nNpcTId = 2626,
          szBubble = "惊不惊喜？#116",
          szBubbleTime = "8"
        }
      },
      {
        szType = "TempNpcBubbleTalk",
        tbParam = {
          szGroup = "xiaoyinfang",
          nNpcTId = 2626,
          szBubble = "意不意外？#116",
          szBubbleTime = "8"
        }
      },
      {
        szType = "TempNpcBubbleTalk",
        tbParam = {
          szGroup = "xiaoyintong",
          nNpcTId = 2628,
          szBubble = "嘻嘻嘻~#116",
          szBubbleTime = "8"
        }
      }
    }
  },
  [214] = {
    nTime = 8,
    tbExe = {
      {
        szType = "TempNpcBubbleTalk",
        tbParam = {
          szGroup = "xiaoyintong",
          nNpcTId = 2628,
          szBubble = "这可是我们缠着万老头，千辛万苦才弄到手的烟花哦！#115",
          szBubbleTime = "5"
        }
      }
    }
  },
  [215] = {
    nTime = 8,
    tbExe = {
      {
        szType = "TempNpcBubbleTalk",
        tbParam = {
          szGroup = "xiaoziyan",
          nNpcTId = 2626,
          szBubble = "嘻嘻~祝福也祝福过了，烟花也放了，言归正传，我们是来讨喜糖的！#119",
          szBubbleTime = "8"
        }
      }
    }
  },
  [216] = {
    nTime = 8,
    tbExe = {
      {
        szType = "TempNpcBubbleTalk",
        tbParam = {
          szGroup = "xiaoyinfang",
          nNpcTId = 2627,
          szBubble = "对对对，喜糖呢？不派喜糖我们就赖着不走了。#115",
          szBubbleTime = "8"
        }
      },
      {
        szType = "TempNpcBubbleTalk",
        tbParam = {
          szGroup = "xiaoyintong",
          nNpcTId = 2628,
          szBubble = "糖糖糖，我们要喜糖~#115",
          szBubbleTime = "8"
        }
      }
    }
  },
  [217] = {
    nTime = 8,
    tbExe = {
      {
        szType = "TempNpcBubbleTalk",
        tbParam = {
          szGroup = "xiaoziyan",
          nNpcTId = 2626,
          szBubble = "糖糖糖，快点派喜糖~#125",
          szBubbleTime = "8"
        }
      },
      {
        szType = "TempNpcBubbleTalk",
        tbParam = {
          szGroup = "xiaoyinfang",
          nNpcTId = 2627,
          szBubble = "糖糖糖，快点派喜糖~#125",
          szBubbleTime = "8"
        }
      },
      {
        szType = "TempNpcBubbleTalk",
        tbParam = {
          szGroup = "xiaoyintong",
          nNpcTId = 2628,
          szBubble = "糖糖糖，快点派喜糖~#125",
          szBubbleTime = "8"
        }
      }
    }
  },
  [230] = {
    nTime = 2,
    tbExe = {
      {
        szType = "NpcBubbleTalk",
        tbParam = {
          nNpcTId = 2386,
          szBubble = "[FFFE0D]喜糖[-]已经准备好了，新郎新娘可以派喜糖啦！#10#10#10#10",
          szBubbleTime = "10"
        }
      },
      {
        szType = "NpcBubbleTalk",
        tbParam = {
          nNpcTId = 2387,
          szBubble = "[FFFE0D]喜糖[-]已经准备好了，新郎新娘可以派喜糖啦！#10#10#10#10",
          szBubbleTime = "10"
        }
      },
      {
        szType = "RetsetCandyTimes"
      },
      {szType = "StartCandy"}
    }
  },
  [231] = {
    nTime = 10,
    tbExe = {
      {
        szType = "NpcBubbleTalk",
        tbParam = {
          nNpcTId = 2386,
          szBubble = "派喜糖时间持续[FFFE0D]90秒[-]哦，新郎新娘快派喜糖吧！#10#10#10#10",
          szBubbleTime = "10"
        }
      },
      {
        szType = "NpcBubbleTalk",
        tbParam = {
          nNpcTId = 2387,
          szBubble = "派喜糖时间持续[FFFE0D]90秒[-]哦，新郎新娘快派喜糖吧！#10#10#10#10",
          szBubbleTime = "10"
        }
      }
    }
  },
  [232] = {
    nTime = 241,
    tbExe = {
      {
        szType = "NpcBubbleTalk",
        tbParam = {
          nNpcTId = 2386,
          szBubble = "准备起轿回程~",
          szBubbleTime = "10"
        }
      },
      {
        szType = "NpcBubbleTalk",
        tbParam = {
          nNpcTId = 2387,
          szBubble = "准备起轿回程~",
          szBubbleTime = "10"
        }
      }
    }
  },
  [233] = {
    nTime = 15,
    tbExe = {
      {
        szType = "NpcBubbleTalk",
        tbParam = {
          nNpcTId = 2386,
          szBubble = "起轿回程~#124#124#124",
          szBubbleTime = "10"
        }
      },
      {
        szType = "NpcBubbleTalk",
        tbParam = {
          nNpcTId = 2387,
          szBubble = "起轿回程~#124#124#124",
          szBubbleTime = "10"
        }
      },
      {szType = "EndCandy"}
    }
  },
  [250] = {
    nTime = 2,
    tbExe = {
      {
        szType = "PlayFirework",
        tbParam = {nId = 250}
      },
      {
        szType = "PlayFirework",
        tbParam = {nId = 250}
      }
    }
  },
  [251] = {
    nTime = 2,
    tbExe = {
      {
        szType = "PlayFirework",
        tbParam = {nId = 251}
      },
      {
        szType = "PlayFirework",
        tbParam = {nId = 251}
      }
    }
  },
  [252] = {
    nTime = 2,
    tbExe = {
      {
        szType = "PlayFirework",
        tbParam = {nId = 252}
      },
      {
        szType = "PlayFirework",
        tbParam = {nId = 252}
      }
    }
  },
  [253] = {
    nTime = 2,
    tbExe = {
      {
        szType = "PlayFirework",
        tbParam = {nId = 253}
      },
      {
        szType = "PlayFirework",
        tbParam = {nId = 253}
      }
    }
  },
  [254] = {
    nTime = 2,
    tbExe = {
      {
        szType = "PlayFirework",
        tbParam = {nId = 254}
      },
      {
        szType = "PlayFirework",
        tbParam = {nId = 254}
      }
    }
  },
  [300] = {
    nTime = 2,
    tbExe = {
      {
        szType = "NpcBubbleTalk",
        tbParam = {
          nNpcTId = 2386,
          szBubble = "请新郎新娘登上[FFFE0D]三生舫[-]，举行[FFFE0D]舫舟·乘龙配凤[-]婚礼。#66#66",
          szBubbleTime = "10"
        }
      },
      {
        szType = "NpcBubbleTalk",
        tbParam = {
          nNpcTId = 2387,
          szBubble = "请新郎新娘登上[FFFE0D]三生舫[-]，举行[FFFE0D]舫舟·乘龙配凤[-]婚礼。#66#66",
          szBubbleTime = "10"
        }
      },
      {
        szType = "NpcBubbleTalk",
        tbParam = {
          nNpcTId = 2388,
          szBubble = "请新郎新娘登上[FFFE0D]三生舫[-]，举行[FFFE0D]舫舟·乘龙配凤[-]婚礼。#66#66",
          szBubbleTime = "10"
        }
      },
      {
        szType = "NpcBubbleTalk",
        tbParam = {
          nNpcTId = 2376,
          szBubble = "请新郎新娘登上[FFFE0D]三生舫[-]，举行[FFFE0D]舫舟·乘龙配凤[-]婚礼。#66#66",
          szBubbleTime = "10"
        }
      },
      {
        szType = "NpcBubbleTalk",
        tbParam = {
          nNpcTId = 2390,
          szBubble = "请新郎新娘登上[FFFE0D]三生舫[-]，举行[FFFE0D]舫舟·乘龙配凤[-]婚礼。#66#66",
          szBubbleTime = "10"
        }
      }
    }
  },
  [301] = {
    nTime = 13,
    tbExe = {
      {szType = "TourEnd"}
    }
  }
}
Wedding.tbTourPlayFireworkSetting = {
  [50] = {
    {
      9183,
      11638,
      17058,
      0
    },
    {
      9183,
      11632,
      17443,
      0
    }
  },
  [51] = {
    {
      9184,
      11358,
      16840,
      0
    },
    {
      9185,
      11919,
      16841,
      0
    }
  },
  [52] = {
    {
      9186,
      11360,
      17164,
      0
    },
    {
      9187,
      11920,
      17160,
      0
    }
  },
  [53] = {
    {
      9188,
      11358,
      17471,
      0
    },
    {
      9189,
      11927,
      17470,
      0
    }
  },
  [54] = {
    {
      9186,
      11356,
      17848,
      0
    },
    {
      9187,
      11917,
      17856,
      0
    }
  },
  [55] = {
    {
      9184,
      11358,
      16840,
      0
    },
    {
      9185,
      11360,
      17164,
      0
    },
    {
      9186,
      11358,
      17471,
      0
    },
    {
      9187,
      11356,
      17848,
      0
    },
    {
      9188,
      11919,
      16841,
      0
    },
    {
      9189,
      11920,
      17160,
      0
    },
    {
      9186,
      11927,
      17470,
      0
    },
    {
      9187,
      11917,
      17856,
      0
    }
  },
  [56] = {
    {
      9182,
      11634,
      17114,
      0
    }
  },
  [250] = {
    {
      9184,
      9759,
      12412,
      0
    },
    {
      9185,
      9788,
      11819,
      0
    }
  },
  [251] = {
    {
      9186,
      9447,
      12415,
      0
    },
    {
      9187,
      9452,
      11823,
      0
    }
  },
  [252] = {
    {
      9188,
      9141,
      12414,
      0
    },
    {
      9189,
      9167,
      11821,
      0
    }
  },
  [253] = {
    {
      9184,
      9141,
      12414,
      0
    },
    {
      9185,
      9447,
      12415,
      0
    },
    {
      9186,
      9759,
      12412,
      0
    },
    {
      9187,
      9167,
      11821,
      0
    },
    {
      9188,
      9452,
      11823,
      0
    },
    {
      9189,
      9788,
      11819,
      0
    }
  },
  [254] = {
    {
      9183,
      9241,
      12111,
      0
    },
    {
      9183,
      9657,
      12105,
      0
    }
  }
}
Wedding.szOpenPropose_version_tx = nil
Wedding.szOpenPropose_version_vn = nil
Wedding.szOpenPropose_version_hk = nil
Wedding.szOpenPropose_version_xm = nil
Wedding.szOpenPropose_version_en = nil
Wedding.szOpenPropose_version_kor = nil
Wedding.szOpenPropose_version_th = nil
Wedding.szProposeTimeFrame = "OpenLevel69"
Wedding.nProposeLevel = 50
Wedding.nProposeImitity = 30
Wedding.MIN_PROPOSE_DISTANCE = 1000
Wedding.nProposeDecideTime = 60
Wedding.PROPOSE_OK = 0
Wedding.PROPOSE_REFUSE = 1
Wedding.PROPOSE_CANCEL = 2
Wedding.ProposeItemId = 6155
Wedding.ProposeTitleId = 8201
Wedding.tbProposeLegalMap = {
  10,
  999,
  1004
}
Wedding.tbAllProposeLegalMap = {}
for _, nMapTID in ipairs(Wedding.tbProposeLegalMap) do
  Wedding.tbAllProposeLegalMap[nMapTID] = true
end
Wedding.szProposeTimeoutTip = "「%s」也许正沉浸在突如其来的幸福中，一时未作出回应"
Wedding.szBeProposeTimeoutTip = "不要只顾沉浸在幸福中！要记得及时同意「%s」的求婚哦！"
Wedding.szProposeSuccessTip = "今日结成幸福侣，毕生共绘锦绣图。祝福两位情定此生！"
Wedding.szBeProposeSuccessTip = "今日结成幸福侣，毕生共绘锦绣图。祝福两位情定此生！"
Wedding.szProposeSuccessNotify = "相遇于剑侠，相识于江湖，缘起于情缘，缘定于今生。恭喜[FFFE0D]「%s」[-]向[FFFE0D]「%s」[-]求婚成功，祝有情人终成眷属！"
Wedding.szProposeFailTip = "「%s」也许还未做好准备，拒绝了你的求婚"
Wedding.szBeProposeFailTip = "你拒绝了「%s」的求婚"
Wedding.szProposeBreakTip = "求婚中断啦，有些耐心，过程中要静静等待对方答复哦！"
Wedding.szProposeBeBreakTip = "「%s」也许是有些害羞，鼓起勇气再尝试一次吧！"
Wedding.tbProposePromise = {
  "[ff72c5]愿得一人心，白首不相离！\n[-]亲爱的[c8fe00]%s[-]，我们在一起吧\n愿与您携手共度剑侠的每一天！",
  "[ff72c5]身无彩凤双飞翼，心有灵犀一点通！\n[-]亲爱的[c8fe00]%s[-]，弱水三千，只取一瓢\n之所以执剑成侠，只为守护一世情缘！",
  "[ff72c5]金风玉露一相逢，便胜却人间无数！\n[-]亲爱的[c8fe00]%s[-]，与你相遇无比幸运\n而最大的幸运，就是能与你相守一生！",
  "[ff72c5]在天愿作比翼鸟，在地愿为连理枝！\n[-]亲爱的[c8fe00]%s[-]，无论何时，无论何地\n我都会牢牢牵着你的手，永不分离！",
  "[ff72c5]两情若是久长时，又岂在朝朝暮暮！\n[-]亲爱的[c8fe00]%s[-]，我只是个平凡的人\n别无他求，只求朝朝暮暮与你在一起！"
}
Wedding.tbProposeCloseWnd = {
  "Task",
  "TeamPanel",
  "NewInformationPanel",
  "AuctionPanel",
  "WelfareActivity",
  "CalendarPanel",
  "ItemBox",
  "AthleticsHonor",
  "RankBoardPanel",
  "RoleInformationPanel",
  "CommonShop",
  "SkillPanel",
  "Partner",
  "KinDetailPanel",
  "SocialPanel",
  "ChatLargePanel",
  "ViewRolePanel",
  "WeddingChoosePromisePanel",
  "StrongerPanel",
  "MarketStallPanel",
  "ChatSetting",
  "HonorLevelPanel",
  "MiniMap",
  "WorldMap",
  "NotifyMsgList"
}
Wedding.nMarryMinDistance = 1000
Wedding.nMarryOpenStart = "10:00"
Wedding.nMarryOpenEnd = "23:59"
Wedding.szFubenBase = "WeddingFubenBase"
Wedding.NO_LIMIT = -1
Wedding.Level_1 = 1
Wedding.Level_2 = 2
Wedding.Level_3 = 3
Wedding.nNoMoveBuffId = 1058
Wedding.nBuffTime = 86400
Wedding.nHideHeadUiBuff = 3549
Wedding.nHideHeadUiBuffTime = 120
Wedding.szWeddingDecorateUiName = "jiehunfengfu01"
Wedding.tbLoli = {3, 12}
Wedding.szxLoliGrowUpMsg = "穿上这身嫁衣，从此就长大成人啦"
Wedding.OPEN_WEDDING_MIN_DISTANCE = 1000
Wedding.BOOK_WEDDING_MIN_DISTANCE = 1000
Wedding.nBookOpenDate = Lib:ParseDateTime("2017-09-01 00:00:00")
Wedding.tbAllWeddingWnd = {
  "MarriageTitlePanel",
  "MarriagePaperPanel",
  "WeddingBookPanel",
  "WeddingBookDetailPanel",
  "WeddingCashGiftPanel",
  "WeddingChoosePromisePanel",
  "WeddingEnterPanel",
  "WeddingWelcomeApplyPanel",
  "WeddingDatePanel",
  "WeddingSendPromisePanel",
  "WeddingWelcomePanel",
  "WeddingBlessingPanel",
  "RoleHeadPop",
  "ItemBox",
  "FloatingWindowDisplay",
  "NpcDialog",
  "BuffTip",
  "ChatLargePanel"
}
Wedding.nMarryCeremonyAddImitity = 9999
Wedding.tbWeddingLevelMapSetting = {
  [Wedding.Level_1] = {
    nMapTID = 5000,
    nMaxTimes = Wedding.NO_LIMIT,
    fnGetDate = function(nBookTime)
      return Lib:GetLocalDay(nBookTime)
    end,
    fnGetDateStr = function(nBookTime)
      return Lib:TimeDesc14(nBookTime)
    end,
    nNeedVip = 5,
    nCost = "6231;2|2180;1|2181;1",
    nMarryCeremonySound = 1009,
    nBoyBuffId = 3540,
    nGirlBuffId = 3543,
    nDefaultMaxPlayer = 2000,
    szWeddingScene = "jiehun_diji_scene",
    tbMarryCeremonyRolePath = {
      Man = "jiehun_diji_scene/zhujue/jiehunzhujue/man/npc_183a/HeadUiPoint",
      Woman = "jiehun_diji_scene/zhujue/jiehunzhujue/woman/npc_184a/HeadUiPoint",
      Loli = "jiehun_diji_scene/zhujue/jiehunzhujue/woman/npc_185a/HeadUiPoint"
    },
    tbMarryCeremonyGirlRolePath = {
      Woman = "jiehun_diji_scene/zhujue/jiehunzhujue/woman/npc_184a",
      Loli = "jiehun_diji_scene/zhujue/jiehunzhujue/woman/npc_185a"
    },
    nDefaultWelcome = 20,
    szWeddingName = "庄园·晚樱连理",
    tbInviteAward = {
      {
        "item",
        6233,
        1
      }
    },
    nInviteCost = 99,
    nWholeTime = 1800,
    tbMarryAward = {
      {
        {
          "item",
          6167,
          1
        }
      },
      {
        {
          "item",
          6282,
          1
        }
      }
    },
    nStartDay = Lib:ParseDateTime("2017-09-01 00:00:00"),
    szOrderUiTexturePath = "UI/Textures/MarryScene1.png",
    tbShowAward = {
      {
        7,
        {
          {
            "item",
            6156,
            1
          },
          {
            "item",
            6157,
            1
          },
          {
            "item",
            6163,
            1
          },
          {
            "item",
            6164,
            1
          },
          {
            "item",
            6263,
            1
          },
          {
            "item",
            6243,
            1
          },
          {
            "item",
            6244,
            1
          },
          {
            "item",
            6162,
            1
          },
          {
            "item",
            5241,
            1
          },
          {
            "item",
            5244,
            1
          },
          {
            "item",
            5256,
            2
          }
        }
      },
      {
        9,
        {
          {
            "item",
            6156,
            1
          },
          {
            "item",
            6157,
            1
          },
          {
            "item",
            6163,
            1
          },
          {
            "item",
            6164,
            1
          },
          {
            "item",
            6263,
            1
          },
          {
            "item",
            6245,
            1
          },
          {
            "item",
            6246,
            1
          },
          {
            "item",
            6162,
            1
          },
          {
            "item",
            5241,
            1
          },
          {
            "item",
            5244,
            1
          },
          {
            "item",
            5256,
            2
          }
        }
      },
      {
        10,
        {
          {
            "item",
            6156,
            1
          },
          {
            "item",
            6157,
            1
          },
          {
            "item",
            6163,
            1
          },
          {
            "item",
            6164,
            1
          },
          {
            "item",
            6263,
            1
          },
          {
            "item",
            6247,
            1
          },
          {
            "item",
            6248,
            1
          },
          {
            "item",
            6162,
            1
          },
          {
            "item",
            5241,
            1
          },
          {
            "item",
            5244,
            1
          },
          {
            "item",
            5256,
            2
          }
        }
      }
    },
    szDate = "当天",
    szFullDate = "明天",
    szCurDate = "今天",
    nReplayMapTId = 5003,
    tbTrapInfo = {
      TrapIn = {
        tbPos = {6021, 4961}
      },
      TrapOut_l = {
        tbPos = {5648, 4952}
      },
      TrapOut_r = {
        tbPos = {6282, 4971}
      },
      TrapOut_t = {
        tbPos = {6038, 5247}
      },
      TrapOut_b = {
        tbPos = {6043, 4668}
      }
    },
    nWitness = 4,
    nWitnessTitle = 8205
  },
  [Wedding.Level_2] = {
    nMapTID = 5001,
    nMaxTimes = 1,
    nPre = 7,
    fnCheckBook = function(pPlayer, nBookTime)
      return Wedding:CheckBookDay(pPlayer, Wedding.Level_2, nBookTime)
    end,
    fnGetDate = function(nBookTime)
      return Lib:GetLocalDay(nBookTime)
    end,
    fnGetDateStr = function(nBookTime)
      return Lib:TimeDesc14(nBookTime)
    end,
    nOverdueClearDay = 60,
    nCompleteClearDay = 1,
    fnCheckBookOverdue = function(nBookDay)
      return nBookDay < Lib:GetLocalDay()
    end,
    fnCheckBookIsOpen = function(nBookDay)
      return nBookDay == Lib:GetLocalDay()
    end,
    bBook = true,
    nNeedVip = 9,
    nCost = "6231;19|2180;9|2181;9",
    nMissCost = "6231;9|2180;4|2181;4",
    nMarryCeremonySound = 1008,
    nBoyBuffId = 3541,
    nGirlBuffId = 3544,
    nDefaultMaxPlayer = 2000,
    szWeddingScene = "jiehun_zhongji_scene",
    tbMarryCeremonyRolePath = {
      Man = "jiehun_zhongji_scene/zhujue/jiehunzhujue/man/npc_183b/HeadUiPoint",
      Woman = "jiehun_zhongji_scene/zhujue/jiehunzhujue/woman/npc_184b/HeadUiPoint",
      Loli = "jiehun_zhongji_scene/zhujue/jiehunzhujue/woman/npc_185b/HeadUiPoint"
    },
    tbMarryCeremonyGirlRolePath = {
      Woman = "jiehun_zhongji_scene/zhujue/jiehunzhujue/woman/npc_184b",
      Loli = "jiehun_zhongji_scene/zhujue/jiehunzhujue/woman/npc_185b"
    },
    nDefaultWelcome = 30,
    szWeddingName = "海岛·红鸾揽月",
    tbInviteAward = {
      {
        "item",
        6233,
        1
      }
    },
    nInviteCost = 99,
    nWholeTime = 1800,
    tbMarryAward = {
      {
        {
          "item",
          6168,
          1
        }
      },
      {
        {
          "item",
          6283,
          1
        }
      }
    },
    nStartDay = Lib:ParseDateTime("2017-09-01 00:00:00"),
    szOrderUiTexturePath = "UI/Textures/MarryScene2.png",
    tbShowAward = {
      {
        10,
        {
          {
            "item",
            6158,
            1
          },
          {
            "item",
            6159,
            1
          },
          {
            "item",
            6163,
            1
          },
          {
            "item",
            6164,
            1
          },
          {
            "item",
            6263,
            1
          },
          {
            "item",
            6166,
            30
          },
          {
            "item",
            6249,
            3
          },
          {
            "item",
            6250,
            3
          },
          {
            "item",
            6162,
            1
          },
          {
            "item",
            5242,
            1
          },
          {
            "item",
            5245,
            1
          },
          {
            "item",
            5256,
            6
          }
        }
      },
      {
        12,
        {
          {
            "item",
            6158,
            1
          },
          {
            "item",
            6159,
            1
          },
          {
            "item",
            6163,
            1
          },
          {
            "item",
            6164,
            1
          },
          {
            "item",
            6263,
            1
          },
          {
            "item",
            6166,
            30
          },
          {
            "item",
            6251,
            3
          },
          {
            "item",
            6252,
            3
          },
          {
            "item",
            6162,
            1
          },
          {
            "item",
            5242,
            1
          },
          {
            "item",
            5245,
            1
          },
          {
            "item",
            5256,
            6
          }
        }
      },
      {
        13,
        {
          {
            "item",
            6158,
            1
          },
          {
            "item",
            6159,
            1
          },
          {
            "item",
            6163,
            1
          },
          {
            "item",
            6164,
            1
          },
          {
            "item",
            6263,
            1
          },
          {
            "item",
            6166,
            30
          },
          {
            "item",
            6253,
            3
          },
          {
            "item",
            6254,
            3
          },
          {
            "item",
            6162,
            1
          },
          {
            "item",
            5242,
            1
          },
          {
            "item",
            5245,
            1
          },
          {
            "item",
            5256,
            6
          }
        }
      }
    },
    szDate = "当天",
    szFullDate = "明天",
    szCurDate = "今天",
    szStartWeddingTip = "确定要现在举行[FFFE0D]海岛·红鸾揽月[-]婚礼吗？\n[FFFE0D]提示：婚礼时长大约为27分钟[-]",
    nReplayMapTId = 5004,
    tbTrapInfo = {
      TrapIn = {
        tbPos = {6724, 6045}
      },
      TrapOut_l = {
        tbPos = {6349, 6023}
      },
      TrapOut_r = {
        tbPos = {6981, 6017}
      },
      TrapOut_t = {
        tbPos = {6723, 6358}
      },
      TrapOut_b = {
        tbPos = {6707, 5708}
      }
    },
    nWitness = 4,
    nWitnessTitle = 8205
  },
  [Wedding.Level_3] = {
    nMapTID = 5002,
    nMaxTimes = 1,
    nPre = 3,
    fnCheckBook = function(pPlayer, nBookTime)
      return Wedding:CheckBookWeek(pPlayer, Wedding.Level_3, nBookTime)
    end,
    fnGetDate = function(nBookTime)
      return Lib:GetLocalWeek(nBookTime)
    end,
    fnGetDateStr = function(nBookTime)
      local nWeek = Lib:GetLocalWeek(nBookTime)
      local nWeekTime1 = Lib:GetTimeByWeek(nWeek, 1, 0, 0, 0)
      local nWeekTime7 = Lib:GetTimeByWeek(nWeek, 7, 0, 0, 0)
      return string.format("%s ~ %s", Lib:TimeDesc14(nWeekTime1), Lib:TimeDesc14(nWeekTime7))
    end,
    nOverdueClearDay = 60,
    nCompleteClearDay = 7,
    fnCheckBookOverdue = function(nBookWeek)
      return nBookWeek < Lib:GetLocalWeek()
    end,
    fnCheckBookIsOpen = function(nBookWeek)
      return nBookWeek == Lib:GetLocalWeek()
    end,
    bBook = true,
    nNeedVip = 12,
    nCost = "6231;99|2180;19|2181;19",
    nMissCost = "6231;49|2180;9|2181;9",
    nMarryCeremonySound = 1008,
    nBoyBuffId = 3542,
    nGirlBuffId = 3545,
    nDefaultMaxPlayer = 2000,
    bCity = true,
    szWeddingScene = "jiehun_gaoji_scene",
    tbMarryCeremonyRolePath = {
      Man = "jiehun_gaoji_scene/zhujue/jiehunzhujue/man/npc_183c/HeadUiPoint",
      Woman = "jiehun_gaoji_scene/zhujue/jiehunzhujue/woman/npc_184c/HeadUiPoint",
      Loli = "jiehun_gaoji_scene/zhujue/jiehunzhujue/woman/npc_185c/HeadUiPoint"
    },
    tbMarryCeremonyGirlRolePath = {
      Woman = "jiehun_gaoji_scene/zhujue/jiehunzhujue/woman/npc_184c",
      Loli = "jiehun_gaoji_scene/zhujue/jiehunzhujue/woman/npc_185c"
    },
    nDefaultWelcome = 50,
    szWeddingName = "舫舟·乘龙配凤",
    tbInviteAward = {
      {
        "item",
        6233,
        1
      }
    },
    nInviteCost = 99,
    nWholeTime = 1800,
    tbMarryAward = {
      {
        {
          "item",
          6169,
          1
        }
      },
      {
        {
          "item",
          6284,
          1
        }
      }
    },
    nStartDay = Lib:ParseDateTime("2017-09-01 00:00:00"),
    szOrderUiTexturePath = "UI/Textures/MarryScene3.png",
    tbShowAward = {
      {
        13,
        {
          {
            "item",
            6160,
            1
          },
          {
            "item",
            6161,
            1
          },
          {
            "item",
            6163,
            1
          },
          {
            "item",
            6164,
            1
          },
          {
            "item",
            6264,
            1
          },
          {
            "item",
            6166,
            50
          },
          {
            "item",
            6255,
            5
          },
          {
            "item",
            6256,
            5
          },
          {
            "item",
            6162,
            1
          },
          {
            "item",
            5243,
            1
          },
          {
            "item",
            5246,
            1
          },
          {
            "item",
            5256,
            8
          }
        }
      },
      {
        16,
        {
          {
            "item",
            6160,
            1
          },
          {
            "item",
            6161,
            1
          },
          {
            "item",
            6163,
            1
          },
          {
            "item",
            6164,
            1
          },
          {
            "item",
            6264,
            1
          },
          {
            "item",
            6166,
            50
          },
          {
            "item",
            6257,
            5
          },
          {
            "item",
            6258,
            5
          },
          {
            "item",
            6162,
            1
          },
          {
            "item",
            5243,
            1
          },
          {
            "item",
            5246,
            1
          },
          {
            "item",
            5256,
            8
          }
        }
      },
      {
        17,
        {
          {
            "item",
            6160,
            1
          },
          {
            "item",
            6161,
            1
          },
          {
            "item",
            6163,
            1
          },
          {
            "item",
            6164,
            1
          },
          {
            "item",
            6264,
            1
          },
          {
            "item",
            6166,
            50
          },
          {
            "item",
            6259,
            5
          },
          {
            "item",
            6260,
            5
          },
          {
            "item",
            6162,
            1
          },
          {
            "item",
            5243,
            1
          },
          {
            "item",
            5246,
            1
          },
          {
            "item",
            5256,
            8
          }
        }
      }
    },
    szDate = "当周",
    szFullDate = "下周",
    szCurDate = "本周",
    szStartWeddingTip = "确定要现在举行[FFFE0D]舫舟·乘龙配凤[-]婚礼吗？\n[FFFE0D]提示：婚礼时长大约为45分钟[-]",
    nReplayMapTId = 5005,
    tbTrapInfo = {
      TrapIn = {
        tbPos = {7873, 6308}
      },
      TrapOut_l = {
        tbPos = {7503, 6302}
      },
      TrapOut_r = {
        tbPos = {8124, 6316}
      },
      TrapOut_t = {
        tbPos = {7894, 6649}
      },
      TrapOut_b = {
        tbPos = {7871, 5985}
      }
    },
    nWitness = 4,
    nWitnessTitle = 8205
  }
}
Wedding.tbAllWeddingMap = {}
for nLevel, v in ipairs(Wedding.tbWeddingLevelMapSetting) do
  Wedding.tbAllWeddingMap[v.nMapTID] = nLevel
end
Wedding.PROCESS_NONE = 0
Wedding.PROCESS_WELCOME = 1
Wedding.PROCESS_STARTWEDDING = 2
Wedding.PROCESS_PROMISE = 3
Wedding.PROCESS_MARRYCEREMONY = 4
Wedding.PROCESS_FIRECRACKER = 5
Wedding.PROCESS_CONCENTRIC = 6
Wedding.PROCESS_WEDDINGTABLE = 7
Wedding.PROCESS_CANDY = 8
Wedding.PROCESS_END = 9
Wedding.State_None = 0
Wedding.State_Engaged = 1
Wedding.State_Marry = 2
Wedding.Welcome_Onekey_Frined = 1
Wedding.Welcome_Onekey_Kin = 2
Wedding.Welcome_Onekey_Apply = 3
Wedding.Welcome_PersonalApply = 4
Wedding.Welcome_PersonalFriend = 5
Wedding.Welcome_PersonalKin = 6
Wedding.nWelcomeItemTId = 6165
Wedding.nRequestJumpWelcomeTime = 10
Wedding.nRequestStartWeddingTime = 10
Wedding.nPromiseEndTime = 120
Wedding.szPromiseStartTip = "爱要大声说出来！下面有请「%s」和「%s」写下爱的誓言"
Wedding.szPromiseDefault = "生死契阔，与子相悦，执子之手，与子偕老。"
Wedding.nVNPromiseMax = 20
Wedding.nVNPromiseMin = 4
Wedding.nTHPromiseMax = 16
Wedding.nTHPromiseMin = 3
Wedding.nPromiseMax = 24
Wedding.nPromiseMin = 3
Wedding.szPromiseNotice = "%s[FFFE0D]「%s」[-]在[FFFE0D]%s[-]婚礼上向%s[FFFE0D]「%s」[-]许下山盟海誓：“%s”"
Wedding.nFirecrackerNpcTId = 2396
Wedding.nFirecrackerDis = 1000
Wedding.nFirecrackerBoomTime = 60
Wedding.tbFirecrackerMsg = {
  [1] = "开心爆竹已在[FFFE0D]舞台[-]点燃，距燃放还有[FFFE0D]%d秒[-]，内藏绣球及随手礼！",
  [20] = "开心爆竹已在[FFFE0D]舞台[-]点燃，距燃放还有[FFFE0D]%d秒[-]，内藏绣球及随手礼！",
  [40] = "开心爆竹已在[FFFE0D]舞台[-]点燃，距燃放还有[FFFE0D]%d秒[-]，内藏绣球及随手礼！",
  [50] = "开心爆竹已在[FFFE0D]舞台[-]点燃，距燃放还有[FFFE0D]%d秒[-]，内藏绣球及随手礼！",
  [55] = "开心爆竹已在[FFFE0D]舞台[-]点燃，距燃放还有[FFFE0D]%d秒[-]，内藏绣球及随手礼！"
}
Wedding.tbFirecrackerAwardSetting = {
  {
    {
      "item",
      6272,
      1
    }
  },
  {
    {
      "item",
      6273,
      1
    }
  },
  {
    {
      "item",
      6274,
      1
    }
  }
}
Wedding.szFirecrackerBoomMsg = "新婚快乐，百年好合！"
Wedding.nFirecrackerActionID = 7
Wedding.nFirecrackerRoleActionID = 6
Wedding.nFirecrackerTitle = 8204
Wedding.nFirecrackerTitleOverdueTime = 864000
Wedding.nFirecrackerTitleMsg = "[FFFE0D]「%s」[-]在[FFFE0D]「%s」[-]和[FFFE0D]「%s」[-]婚礼上的开心爆竹环节中幸运夺得绣球，获得特殊称号[FF69B4]「花落我家」[-]"
Wedding.nConcentricFruitWaitTime = 5
Wedding.nConcentricFruitHitTime = 1
Wedding.nConcentricFruitNpcTId = 2398
Wedding.nConcentricFruitEndTime = 120
Wedding.tbConcentricFruitAwardSetting = {
  {
    {
      "item",
      6166,
      1
    }
  },
  {
    {
      "item",
      6166,
      30
    }
  },
  {
    {
      "item",
      6166,
      50
    }
  }
}
Wedding.szConcentricFruitSuccessMsg = "两位新人心有灵犀，真是天造地设的一对啊！"
Wedding.szConcentricFruitFailMsg = "实在可惜！只差分毫，两位新人莫紧张，再试试！"
Wedding.nDinnerWaitTime = 5
Wedding.nMaxDinnerEat = 1
Wedding.tbDinnerAwardSetting = {
  {
    {
      "item",
      6266,
      1
    }
  },
  {
    {
      "item",
      6267,
      1
    }
  },
  {
    {
      "item",
      6268,
      1
    }
  }
}
Wedding.nDinnerActionID = 5
Wedding.nDinnerRoleActionID = 5
Wedding.tbTitleSuffix = {
  "永结同心",
  "白头偕老"
}
Wedding.nCandyNpcTId = 2397
Wedding.nCandyWaitTime = 4
Wedding.Candy_Type_Free = 1
Wedding.Candy_Type_Pay = 2
Wedding.szFubenCandy = "FubenCandy"
Wedding.szCandyFubenThrowMsg = "月老在四周布置了[FFFE0D]喜糖[-]，希望吃到的侠士也能甜甜蜜蜜"
Wedding.szCandyFubenSendMsg = "「%s」和「%s」感谢大家的祝福，特备[FFFE0D]喜糖[-]一同分享甜蜜"
Wedding.tbCandySetting = {
  {
    tbSendTimes = {3, 3},
    nPayCost = 199,
    nCandyCount = 10,
    tbAward = {
      {
        "item",
        6269,
        1
      }
    },
    nAwardCount = 10
  },
  {
    tbSendTimes = {5, 5},
    nPayCost = 399,
    nCandyCount = 10,
    tbAward = {
      {
        "item",
        6270,
        1
      }
    },
    nAwardCount = 15
  },
  {
    tbSendTimes = {8, 8},
    nPayCost = 399,
    nCandyCount = 10,
    tbAward = {
      {
        "item",
        6271,
        1
      }
    },
    nAwardCount = 20
  }
}
Wedding.szCandyFreeTip = "是否派发喜糖，让大家一同分享这份甜蜜？\n[FFFE0D]（本次免费）[-]"
Wedding.szCandyPayTip = "是否以[FFFE0D]%d元宝[-]购置喜糖赠予宾客，让大家与你一同分享这份甜蜜？"
Wedding.szTourCandy = "TourCandy"
Wedding.nCandyTourCount = 20
Wedding.nCandyTourCost = 599
Wedding.tbCandyTourAward = {
  {
    "item",
    6271,
    1
  }
}
Wedding.szSendCandyTourMsg = "「%s」和「%s」诚挚感谢大家的祝福，特备[FFFE0D]喜糖[-]一同分享这份甜蜜"
Wedding.tbCandyTourPos = {
  {
    {11378, 17672},
    {11412, 17522},
    {11347, 17417},
    {11430, 17349},
    {11357, 17190},
    {11443, 17143},
    {11357, 17004},
    {11453, 16917},
    {11772, 16921},
    {11845, 17005},
    {11814, 17132},
    {11862, 17245},
    {11819, 17378},
    {11885, 17476},
    {11824, 17572},
    {11865, 17683},
    {11913, 17346},
    {11907, 17143},
    {11887, 16924},
    {11448, 17027}
  },
  {
    {9097, 12377},
    {9218, 12383},
    {9340, 12354},
    {9483, 12340},
    {9559, 12373},
    {9717, 12330},
    {9122, 11858},
    {9311, 11878},
    {9162, 11954},
    {9381, 11919},
    {9517, 11897},
    {9615, 11914},
    {9718, 11899},
    {9814, 11902},
    {9303, 11962},
    {9753, 11989},
    {9885, 12227},
    {9925, 11999},
    {9030, 11979},
    {9937, 11902}
  }
}
Wedding.nCandyTourMaxFreeSend = 2
Wedding.nCandyTourMaxPaySend = 2
Wedding.tbBlessMsg = {
  {
    "幸福美满",
    "今日结成幸福侣，毕生共绘锦绣图！祝「%s」和「%s」幸福美满。#124"
  },
  {
    "恩恩爱爱",
    "百年修得同船渡，千年修得共枕眠！祝「%s」和「%s」恩恩爱爱。#11"
  },
  {
    "永结同心",
    "新婚永结同心果，燕尔欣成并蒂花！祝「%s」和「%s」永结同心。#58"
  },
  {
    "白头偕老",
    "鸳鸯比翼新婚乐，龙凤呈祥花烛辉！祝「%s」和「%s」白头偕老。#120"
  },
  {
    "百年好合",
    "连理枝头蝶对舞，碧空万里鸾凤鸣！祝「%s」和「%s」百年好合。#66"
  }
}
Wedding.nDismissProtectTime = 2592000
Wedding.nForceDivorcePlayerOffline = 1209600
Wedding.nForceDivorceDelayTime = 86400
Wedding.nForceDivorceCost = 1000
Wedding.nReduceImitity = 9999
Wedding.tbTitleIds = {
  [Wedding.Level_1] = 8200,
  [Wedding.Level_2] = 8202,
  [Wedding.Level_3] = 8203
}
Wedding.nChangeTitleWaitTime = 20
Wedding.nChangeTitleCost = 999
Wedding.nTitleNameMin = 1
Wedding.nTitleNameMax = 4
if version_vn then
  Wedding.nTitleNameMin = 4
  Wedding.nTitleNameMax = 20
end
if version_th then
  Wedding.nTitleNameMin = 3
  Wedding.nTitleNameMax = 16
end
Wedding.tbRingIds = {
  [Wedding.Level_1] = {6163, 6164},
  [Wedding.Level_2] = {6163, 6164},
  [Wedding.Level_3] = {6163, 6164}
}
Wedding.tbAllDressIds = {
  6156,
  6157,
  6158,
  6159,
  6160,
  6161
}
Wedding.tbSmallSizeWeddingDress = {
  3546,
  3547,
  3548
}
function Wedding:GetWeddingDressBuffId(nWeddingLevel, nGender, nFaction)
  local tbSetting = self.tbWeddingLevelMapSetting[nWeddingLevel]
  local szBuffKey = nGender == Gift.Sex.Boy and "nBoyBuffId" or "nGirlBuffId"
  local nBuffId = Lib:IsInArray(self.tbLoli, nFaction) and self.tbSmallSizeWeddingDress[nWeddingLevel] or tbSetting[szBuffKey]
  if not nBuffId then
    Log("[x] WeddingDress:GetWeddingDressBuffId", nWeddingLevel, nGender, nFaction, tostring(nBuffId))
    return
  end
  return nBuffId
end
Wedding.tbOperationSetting = {
  [Wedding.State_Engaged] = {
    fnGet = function(pPlayer)
      return Wedding:GetEngaged(pPlayer.dwID)
    end,
    nTitleId = Wedding.ProposeTitleId
  },
  [Wedding.State_Marry] = {
    fnGet = function(pPlayer)
      return Wedding:GetLover(pPlayer.dwID)
    end,
    nTitleId = Wedding.nTitleId
  }
}
Wedding.tbMemorialMonthRewards = {
  [1] = {
    tbMail = {
      {
        "item",
        6233,
        2
      }
    },
    tbNpc = {
      {
        "item",
        5239,
        1
      },
      {
        "item",
        5240,
        1
      }
    }
  }
}
Wedding.tbCashGiftSettings = {
  [10] = {0},
  [19] = {3},
  [99] = {5},
  [199] = {6},
  [299] = {7},
  [599] = {8},
  [999] = {9, true},
  [1999] = {10, true},
  [2999] = {11, true},
  [5999] = {12, true},
  [9999] = {14, true},
  [19999] = {15, true},
  [29999] = {16, true},
  [39999] = {17, true},
  [59999] = {18, true}
}
Wedding.nMarriagePaperId = 6162
Wedding.nMPHusbandNameIdx = 1
Wedding.nMPWifeNameIdx = 2
Wedding.nMPHusbandPledgeIdx = 3
Wedding.nMPWifePledgeIdx = 4
Wedding.nMPTimestamp = 5
Wedding.nMPLevel = 6
Wedding.tbPlayFireworkSetting = {
  [1] = {
    {
      9184,
      5772,
      5534,
      0
    },
    {
      9185,
      6269,
      5517,
      0
    },
    {
      9186,
      6000,
      5272,
      0
    },
    {
      9187,
      6006,
      4621,
      0
    },
    {
      9188,
      6295,
      5024,
      0
    },
    {
      9189,
      5718,
      4935,
      0
    },
    {
      9184,
      5794,
      4364,
      0
    },
    {
      9185,
      6283,
      4390,
      0
    },
    {
      9186,
      5422,
      5098,
      0
    },
    {
      9187,
      5430,
      4804,
      0
    },
    {
      9188,
      4970,
      5096,
      0
    },
    {
      9189,
      4954,
      4798,
      0
    },
    {
      9184,
      4587,
      4642,
      0
    },
    {
      9185,
      2826,
      5267,
      0
    },
    {
      9186,
      2774,
      4644,
      0
    },
    {
      9187,
      3419,
      4639,
      0
    },
    {
      9188,
      3423,
      5249,
      0
    },
    {
      9189,
      4031,
      5247,
      0
    },
    {
      9188,
      3999,
      4631,
      0
    },
    {
      9189,
      4580,
      5240,
      0
    }
  },
  [2] = {
    {
      9182,
      6188,
      5302,
      0
    },
    {
      9182,
      6195,
      4623,
      0
    },
    {
      9182,
      4607,
      5269,
      0
    },
    {
      9182,
      4593,
      4641,
      0
    },
    {
      9182,
      2818,
      5261,
      0
    },
    {
      9182,
      2768,
      4626,
      0
    },
    {
      9182,
      3701,
      4639,
      0
    },
    {
      9182,
      3701,
      5250,
      0
    }
  },
  [10] = {
    {
      9184,
      5901,
      6129,
      0
    },
    {
      9185,
      5894,
      5884,
      0
    },
    {
      9186,
      4727,
      5699,
      0
    },
    {
      9187,
      3298,
      6325,
      0
    },
    {
      9188,
      3298,
      5707,
      0
    },
    {
      9189,
      4039,
      5700,
      0
    },
    {
      9184,
      5353,
      5709,
      0
    },
    {
      9185,
      4722,
      6325,
      0
    },
    {
      9186,
      4047,
      6331,
      0
    },
    {
      9187,
      5332,
      6327,
      0
    },
    {
      9188,
      6756,
      6021,
      0
    },
    {
      9189,
      6748,
      6262,
      0
    },
    {
      9184,
      6749,
      5785,
      0
    },
    {
      9185,
      6731,
      5251,
      0
    },
    {
      9186,
      6741,
      6801,
      0
    },
    {
      9187,
      6747,
      6469,
      0
    },
    {
      9188,
      7042,
      6019,
      0
    },
    {
      9189,
      6349,
      6048,
      0
    },
    {
      9184,
      6731,
      5555,
      0
    },
    {
      9185,
      6159,
      6641,
      0
    },
    {
      9186,
      7236,
      6707,
      0
    },
    {
      9186,
      6201,
      5385,
      0
    },
    {
      9186,
      7212,
      5350,
      0
    },
    {
      9186,
      6464,
      5748,
      0
    }
  },
  [11] = {
    {
      9182,
      6954,
      5806,
      0
    },
    {
      9182,
      6951,
      6251,
      0
    },
    {
      9182,
      5358,
      5699,
      0
    },
    {
      9182,
      4455,
      5699,
      0
    },
    {
      9182,
      3525,
      5698,
      0
    },
    {
      9182,
      5343,
      6333,
      0
    },
    {
      9182,
      4444,
      6337,
      0
    },
    {
      9182,
      3526,
      6335,
      0
    }
  },
  [12] = {
    {
      9183,
      6749,
      6019,
      0
    }
  },
  [20] = {
    {
      9184,
      7567,
      6652,
      0
    },
    {
      9185,
      8181,
      6666,
      0
    },
    {
      9186,
      7542,
      5981,
      0
    },
    {
      9187,
      8161,
      5925,
      0
    },
    {
      9188,
      7912,
      6881,
      0
    },
    {
      9189,
      7887,
      5712,
      0
    },
    {
      9184,
      7397,
      6334,
      0
    },
    {
      9185,
      8181,
      6288,
      0
    },
    {
      9186,
      7928,
      6506,
      0
    },
    {
      9187,
      7919,
      6087,
      0
    },
    {
      9188,
      7049,
      6461,
      0
    },
    {
      9189,
      7049,
      6123,
      0
    },
    {
      9184,
      6628,
      6001,
      0
    },
    {
      9185,
      6189,
      6599,
      0
    },
    {
      9186,
      5634,
      5998,
      0
    },
    {
      9187,
      6184,
      5994,
      0
    },
    {
      9188,
      5660,
      6607,
      0
    },
    {
      9189,
      6640,
      6596,
      0
    },
    {
      9184,
      4436,
      6552,
      0
    },
    {
      9185,
      4440,
      6007,
      0
    },
    {
      9186,
      5013,
      6482,
      0
    },
    {
      9186,
      5020,
      6090,
      0
    }
  },
  [21] = {
    {
      9182,
      8068,
      6660,
      0
    },
    {
      9182,
      8088,
      5994,
      0
    },
    {
      9182,
      6519,
      6603,
      0
    },
    {
      9182,
      6513,
      5991,
      0
    },
    {
      9182,
      5911,
      6601,
      0
    },
    {
      9182,
      5891,
      5995,
      0
    },
    {
      9182,
      4871,
      6501,
      0
    },
    {
      9182,
      4875,
      6058,
      0
    },
    {
      9182,
      3930,
      6315,
      0
    }
  },
  [22] = {
    {
      9183,
      7915,
      6289,
      0
    }
  }
}
Wedding.tbRedbags = {
  [Wedding.Level_1] = {
    nEventType = Kin.tbRedBagEvents.wedding_1,
    nCount = 1
  },
  [Wedding.Level_2] = {
    nEventType = Kin.tbRedBagEvents.wedding_2,
    nCount = 3
  },
  [Wedding.Level_3] = {
    nEventType = Kin.tbRedBagEvents.wedding_3,
    nCount = 5
  }
}
Wedding.szReplayFubenBase = "WeddingReplayFubenBase"
function Wedding:GetCashGiftValidList(nVip)
  self.tbCashGiftValidListCache = self.tbCashGiftValidListCache or {}
  if not self.tbCashGiftValidListCache[nVip] then
    local tbRet = {}
    for nGold, tbSetting in pairs(self.tbCashGiftSettings) do
      local nMinVip = tbSetting[1]
      if nVip >= nMinVip then
        table.insert(tbRet, nGold)
      end
    end
    table.sort(tbRet, function(a, b)
      return a < b
    end)
    self.tbCashGiftValidListCache[nVip] = tbRet
  end
  return self.tbCashGiftValidListCache[nVip]
end
function Wedding:GetCashGiftMax(nVip)
  self.tbCashGiftMaxCache = self.tbCashGiftMaxCache or {}
  if not self.tbCashGiftMaxCache[nVip] then
    local tbList = self:GetCashGiftValidList(nVip)
    self.tbCashGiftMaxCache[nVip] = #tbList > 0 and tbList[#tbList] or 0
  end
  return self.tbCashGiftMaxCache[nVip]
end
function Wedding:GetMaxMemorialMonth(nWeddingTime, nNow)
  local nRet = 0
  local nDiffMonth = Lib:GetDiffMonth(nWeddingTime, nNow)
  if nDiffMonth <= 0 then
    return nRet
  end
  for nMonth in pairs(self.tbMemorialMonthRewards) do
    if nMonth > nRet and nMonth <= nDiffMonth then
      nRet = nMonth
    end
  end
  return nRet
end
function Wedding:GetMemorialCfgMaxMonth()
  if not self.nMemorialCfgMaxMonth then
    local nMax = 0
    for nMonth in pairs(self.tbMemorialMonthRewards) do
      if nMonth > nMax then
        nMax = nMonth
      end
    end
    self.nMemorialCfgMaxMonth = nMax
  end
  return self.nMemorialCfgMaxMonth
end
function Wedding:GetLover(dwID)
  local nLover = Wedding:GetLoverId(dwID)
  if nLover > 0 then
    local tbFriendData = FriendShip.fnGetFriendData(dwID, nLover)
    if tbFriendData and tbFriendData[FriendShip:WeddingStateType()] == Wedding.State_Marry then
      return nLover, tbFriendData[FriendShip:WeddingTimeType()]
    end
  end
end
function Wedding:IsLover(dwRoleId1, dwRoleId2)
  local tbFriendData = FriendShip.fnGetFriendData(dwRoleId1, dwRoleId2)
  if tbFriendData and tbFriendData[FriendShip:WeddingStateType()] == Wedding.State_Marry then
    return true
  end
end
function Wedding:GetEngaged(dwID)
  local nLover = Wedding:GetLoverId(dwID)
  if nLover > 0 then
    local tbFriendData = FriendShip.fnGetFriendData(dwID, nLover)
    if tbFriendData and tbFriendData[FriendShip:WeddingStateType()] == Wedding.State_Engaged then
      return nLover
    end
  end
end
function Wedding:IsEngaged(dwRoleId1, dwRoleId2)
  local tbFriendData = FriendShip.fnGetFriendData(dwRoleId1, dwRoleId2)
  if tbFriendData and tbFriendData[FriendShip:WeddingStateType()] == Wedding.State_Engaged then
    return true
  end
end
function Wedding:IsSingle(pPlayer)
  local nLover = Wedding:GetLoverId(pPlayer.dwID)
  if nLover > 0 then
    local tbFriendData = FriendShip.fnGetFriendData(pPlayer.dwID, nLover)
    return not tbFriendData or tbFriendData[FriendShip:WeddingStateType()] == Wedding.State_None
  end
  return true
end
function Wedding:GetLoverId(dwID)
  local nLoverId
  if MODULE_GAMESERVER then
    nLoverId = KFriendShip.GetMarriageRelationRoleId(dwID)
  else
    nLoverId = FriendShip:GetMarriageRoleId()
  end
  return nLoverId or 0
end
function Wedding:GetStartOpen(tbMapSetting)
  local nOpen = tbMapSetting.fnGetDate()
  local nStartOpen = 0
  if tbMapSetting.nStartDay then
    nStartOpen = tbMapSetting.fnGetDate(tbMapSetting.nStartDay)
  end
  return math.max(nOpen, nStartOpen)
end
function Wedding:NormalizeIds(nId1, nId2)
  if nId2 < nId1 then
    nId1, nId2 = nId2, nId1
  end
  return nId1, nId2
end
function Wedding:GetNormalizedIdsKey(nPid1, nPid2)
  nPid1, nPid2 = Wedding:NormalizeIds(nPid1, nPid2)
  return string.format("%s_%s", nPid1, nPid2)
end
function Wedding:CheckProposeC(pPlayer, nPlayerId)
  if not Wedding:CheckOpenProposeTime() then
    return false, "暂未开放"
  end
  if GetTimeFrameState(Wedding.szProposeTimeFrame) ~= 1 then
    return false, "暂未开放"
  end
  if not Wedding:IsSingle(pPlayer) then
    return false, string.format("[FFFE0D]「%s」[-]已经成婚或已有订婚对象", pPlayer.szName)
  end
  if pPlayer.nLevel < Wedding.nProposeLevel then
    return false, string.format("[FFFE0D]「%s」[-]等级需达到 [FFFE0D]%d[-] 级", pPlayer.szName, Wedding.nProposeLevel)
  end
  if not Wedding.tbAllProposeLegalMap[pPlayer.nMapTemplateId] and not Map:IsHouseMap(pPlayer.nMapTemplateId) then
    return false, string.format("[FFFE0D]「%s」[-]所在场景不允许求婚，请在[FFFE0D]忘忧岛、襄阳城、家园、家族属地[-]进行", pPlayer.szName)
  end
  if nPlayerId then
    if not FriendShip:IsFriend(pPlayer.dwID, nPlayerId) then
      return false, "你们还不是好友"
    end
    local nImityLevel = FriendShip:GetFriendImityLevel(pPlayer.dwID, nPlayerId) or 0
    if nImityLevel < Wedding.nProposeImitity then
      return false, string.format("求婚需双方亲密度达到 [FFFE0D]%s[-] 级", Wedding.nProposeImitity)
    end
  end
  return true
end
function Wedding:CheckTimeFrame()
  if GetTimeFrameState(Wedding.szProposeTimeFrame) ~= 1 then
    local _, nOpenTime = TimeFrame:CalcRealOpenDay(Wedding.szProposeTimeFrame)
    local nNowDay = Lib:GetLocalDay()
    local nOpenDay = Lib:GetLocalDay(nOpenTime)
    return nOpenDay - nNowDay, nOpenTime
  end
end
function Wedding:CheckOpen(nLevel, nBookTime)
  if self.bForceOpen then
    return true
  end
  local nNowTime = GetTime()
  local nActStartTime, nActEndTime
  if MODULE_GAMESERVER then
    nActStartTime = Wedding.nOpenStartTime
    nActEndTime = Wedding.nOpenEndTime
  else
    nActStartTime, nActEndTime = Activity:__GetActTimeInfo("WeddingAct")
  end
  if not (nActStartTime and nActEndTime) or nNowTime < nActStartTime or nNowTime >= nActEndTime then
    return false
  end
  if nLevel and nBookTime then
    local tbMapSetting = Wedding.tbWeddingLevelMapSetting[nLevel]
    if not tbMapSetting then
      return false
    end
    local nBook = tbMapSetting.fnGetDate(nBookTime)
    local nEndBook = tbMapSetting.fnGetDate(nActEndTime)
    local nStartBook = tbMapSetting.fnGetDate(nActStartTime)
    if nBook > nEndBook or nBook < nStartBook then
      return false, "暂不开放预定该日期"
    end
  end
  if Wedding.nBookOpenDate then
    return nNowTime > Wedding.nBookOpenDate
  end
  return true
end
function Wedding:CheckOpenTime()
  local nStartHour, nStartMin = string.match(Wedding.nMarryOpenStart, "(%d+):(%d+)")
  local nEndHour, nEndMin = string.match(Wedding.nMarryOpenEnd, "(%d+):(%d+)")
  local nTodayTime = Lib:GetTodaySec()
  if nTodayTime < nStartHour * 3600 + nStartMin * 60 or nTodayTime > nEndHour * 3600 + nEndMin * 60 then
    return false, "只能在每天的[FFFE0D]10:00~24:00时间段[-]举行婚礼"
  end
  return true
end
function Wedding:CheckDelFriend(dwRoleId1, dwRoleId2)
  if self:IsEngaged(dwRoleId1, dwRoleId2) then
    return false, "订婚关系不能删除好友"
  end
  if self:IsLover(dwRoleId1, dwRoleId2) then
    return false, "结婚关系不能删除好友"
  end
  return true
end
function Wedding:GetCostItemInfo(szItem, bAward)
  local tbResult = {}
  local tbStrItem = Lib:SplitStr(szItem, "|")
  for _, szItemInfo in ipairs(tbStrItem) do
    local tbItem = Lib:SplitStr(szItemInfo, ";")
    local nItemId = tonumber(tbItem[1])
    local nCount = tonumber(tbItem[2])
    local tbInfo = {nItemId, nCount}
    if bAward then
      table.insert(tbInfo, 1, "item")
    end
    table.insert(tbResult, tbInfo)
  end
  return tbResult
end
function Wedding:GetWeddingMapLevel(nMapTID)
  return Wedding.tbAllWeddingMap[nMapTID]
end
function Wedding:CheckOpenProposeTime()
  local nNowTime = GetTime()
  return nNowTime > (Wedding.nProposeOpenDate or 0), "暂未开放"
end
function Wedding:CheckVersion()
  Wedding.nProposeOpenDate = nil
  local szProposeOpen
  if version_tx then
    szProposeOpen = Wedding.szOpenPropose_version_tx
  elseif version_vn then
    szProposeOpen = Wedding.szOpenPropose_version_vn
  elseif version_hk then
    szProposeOpen = Wedding.szOpenPropose_version_hk
  elseif version_xm then
    szProposeOpen = Wedding.szOpenPropose_version_xm
  elseif version_en then
    szProposeOpen = Wedding.szOpenPropose_version_en
  elseif version_kor then
    szProposeOpen = Wedding.szOpenPropose_version_kor
  elseif version_th then
    szProposeOpen = Wedding.szOpenPropose_version_th
  end
  if szProposeOpen then
    Wedding.nProposeOpenDate = Lib:ParseDateTime(szProposeOpen)
  end
  Log("Wedding fnCheckVersion ", Wedding.nProposeOpenDate or 0)
end
Wedding:CheckVersion()
