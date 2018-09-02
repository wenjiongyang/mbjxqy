local tbUi = Ui:CreateClass("GMListPanel")
local tbAllTestAIPartner = "{57, 23, 13, 20, 22, 29, 12, 52, 26, 41, 37, 11, 21, 66}"
local tbDataIndex = {
  OneKeyShow = 1,
  QuicklyEquipment = 2,
  RefreshHp = 3,
  ActivtyOpen = 4,
  AddPower = 5,
  Money = 6,
  GainItem = 7,
  Revive = 8,
  nPartnerDataIndex = 9,
  Role = 10,
  KinTool = 11,
  House = 12,
  nLevelUpDataIndex = 13,
  nHonorDataIndex = 14,
  BattleSignIn = 15,
  BaoZang = 16,
  TeamFuben = 17,
  RandomFuben = 18,
  AddItem = 19,
  TestClientPk = 20,
  UnlockFuben = 21,
  CleanBag = 22,
  Refresh = 23,
  ChangeFaction = 24
}
local nAllPartnerIndex = 9
local nSSPartnerSingleIndex = 2
local nSPartnerSingleIndex = 4
local nAPartnerSingleIndex = 6
local nCodeGift = 11
local tbRoleData = {
  [1] = {
    nLevel = 20,
    tbStrong = {
      5,
      10,
      20
    },
    tbInsert = {
      5,
      10,
      20
    }
  },
  [2] = {
    nLevel = 30,
    tbStrong = {
      10,
      20,
      30
    },
    tbInsert = {
      10,
      20,
      30
    }
  },
  [3] = {
    nLevel = 40,
    tbStrong = {
      20,
      30,
      40
    },
    tbInsert = {
      20,
      30,
      40
    }
  },
  [4] = {
    nLevel = 50,
    tbStrong = {
      30,
      40,
      50
    },
    tbInsert = {
      30,
      40,
      50
    }
  },
  [5] = {
    nLevel = 60,
    tbStrong = {
      40,
      50,
      60
    },
    tbInsert = {
      40,
      50,
      60
    }
  },
  [6] = {
    nLevel = 70,
    tbStrong = {
      50,
      60,
      70
    },
    tbInsert = {
      50,
      60,
      70
    }
  },
  [7] = {
    nLevel = 80,
    tbStrong = {
      60,
      70,
      80
    },
    tbInsert = {
      60,
      70,
      80
    }
  },
  [8] = {
    nLevel = 90,
    tbStrong = {
      70,
      80,
      90
    },
    tbInsert = {
      70,
      80,
      90
    }
  },
  [9] = {
    nLevel = 100,
    tbStrong = {
      80,
      90,
      100
    },
    tbInsert = {
      80,
      90,
      100
    }
  },
  [10] = {
    nLevel = 110,
    tbStrong = {
      90,
      100,
      110
    },
    tbInsert = {
      90,
      100,
      110
    }
  },
  [11] = {
    nLevel = 120,
    tbStrong = {
      90,
      100,
      110
    },
    tbInsert = {
      100,
      110,
      120
    }
  }
}
local nMaxLevelUp = 12
tbUi.tbGMData = {
  [tbDataIndex.OneKeyShow] = {
    Text = "一键演示",
    szCallback = "GM:OneKeyShow()"
  },
  [tbDataIndex.QuicklyEquipment] = {
    Text = "一键N级",
    tbChild = {
      [1] = {
        Text = "一键40级",
        szCallback = "GM:QuicklyEquipment()"
      },
      [2] = {
        Text = "一键80级",
        szCallback = "GM:QuicklyEquipment2()"
      },
      [3] = {
        Text = "一键100级",
        szCallback = "GM:QuicklyEquipment3()"
      },
      [4] = {
        Text = "一键110级",
        szCallback = "GM:QuicklyEquipment4()"
      },
      [5] = {
        Text = "一键120级",
        szCallback = "GM:QuicklyEquipment5()"
      }
    }
  },
  [tbDataIndex.RefreshHp] = {
    Text = "回满血",
    szCallback = "GM:RefreshHp()"
  },
  [tbDataIndex.ActivtyOpen] = {
    Text = "活动开启",
    tbChild = {
      {
        Text = "武林盟主",
        tbChild = {
          {
            Text = "挑战武林盟主",
            szCallback = "GM:OpenBossActivity()"
          },
          {
            Text = "关闭武林盟主",
            szCallback = "GM:EndFinishBoss()"
          },
          {
            Text = "去除CD",
            szCallback = "GM:BossFightCd()"
          },
          {
            Text = "开启跨服盟主",
            szCallback = "GM:StartZBoss()"
          },
          {
            Text = "关闭跨服盟主",
            szCallback = "GM:EndZBoss()"
          },
          {
            Text = "跨服累计积分",
            szCallback = "GM:AddKinScoreToZBoss()"
          }
        }
      },
      {
        Text = "拍卖行",
        tbChild = {
          {
            Text = "开启家族拍卖",
            szCallback = "GM:KinAuction()"
          },
          {
            Text = "开启行脚商人",
            szCallback = "GM:StartAuctionDealer()"
          }
        }
      },
      {
        Text = "武神殿",
        szCallback = "GM:OpenRankPanel()"
      },
      {
        Text = "群英会",
        tbChild = {
          [1] = {
            Text = "开启群英会",
            szCallback = "GM:QunYingHuiOpen()"
          },
          [2] = {
            Text = "进入群英会",
            szCallback = "GM:QunYingHuiJoin()"
          }
        }
      },
      {
        Text = "战场",
        tbChild = {
          {
            Text = "开启新手战场",
            szCallback = "GM:OpenAloneBattle()"
          },
          {
            Text = "开启元帅战场",
            szCallback = "GM:OpenBattle()"
          },
          {
            Text = "开启杀戮战场",
            szCallback = "GM:OpenBatte1()"
          },
          {
            Text = "开启宋金攻防战",
            szCallback = "GM:OpenBatte8()"
          },
          {
            Text = "关闭战场报名",
            szCallback = "GM:StopBattleSignUp()"
          },
          {
            Text = "增加战场次数",
            szCallback = "GM:AddDegreeBattle()"
          }
        }
      },
      {
        Text = "野外首领",
        tbChild = {
          [1] = {
            Text = "开启野外首领",
            szCallback = "GM:OpenBoss()"
          },
          [2] = {
            Text = "关闭野外首领",
            szCallback = "GM:CloseBoss()"
          }
        }
      },
      {
        Text = "历代名将",
        tbChild = {
          [1] = {
            Text = "开启历代名将地图",
            szCallback = "GM:PreStartBossLeader()"
          },
          [2] = {
            Text = "开启历代名将",
            szCallback = "GM:StartBossLeader()"
          },
          [3] = {
            Text = "关闭历代名将",
            szCallback = "GM:CloseBossLeader()"
          }
        }
      },
      {
        Text = "白虎堂",
        tbChild = {
          [1] = {
            Text = "开启白虎堂",
            szCallback = "GM:OpenWhiteTigerFuben()"
          },
          [2] = {
            Text = "进入白虎堂准备场",
            szCallback = "GM:EnterWhiteTigerFuben()"
          },
          [3] = {
            Text = "关闭白虎堂",
            szCallback = "GM:CloseWhiteTigerFuben()"
          },
          [4] = {
            Text = "白虎堂次数+1",
            szCallback = "GM:AddDegreeWhiteTigerFuben()"
          }
        }
      },
      {
        Text = "门派竞技",
        tbChild = {
          [1] = {
            Text = "开启门派竞技",
            szCallback = "GM:OpenFactionBattle()"
          },
          [2] = {
            Text = "参加门派竞技",
            szCallback = "GM:JoinFactionBattle()"
          },
          [3] = {
            Text = "关闭门派竞技",
            szCallback = "GM:CloseFactionBattle()"
          },
          [4] = {
            Text = "开启评选",
            szCallback = "GM:StartFactionMonkey()"
          },
          [5] = {
            Text = "关闭评选",
            szCallback = "GM:EndFactionMonkey()"
          }
        }
      },
      {
        Text = "通天塔",
        tbChild = {
          {
            Text = "开启通天塔",
            szCallback = "GM:OpenTeamBattle()"
          },
          {
            Text = "开启跨服通天塔",
            szCallback = "GM:OpenTeamBattle_Cross()"
          },
          {
            Text = "进入通天塔",
            szCallback = "GM:EnterTeamBattle()"
          },
          {
            Text = "所有在线玩家参加通天塔\n(组队除外)",
            szCallback = "GM:TryJoinPreMapTeamBattle()"
          },
          {
            Text = "重置通天塔消耗次数",
            szCallback = "GM:TeamBattleUserValue()"
          },
          {
            Text = "[B03060]在线[-]所有玩家重置消耗次数",
            szCallback = "GM:TeamBattlePlayerUserValue()"
          },
          {
            Text = "[B03060]在线[-]所有玩家去除门票",
            szCallback = "GM:TeamBatlePlayerSetUserValue()"
          },
          {
            Text = "查询通天塔剩余荣誉",
            szCallback = "GM:TeamBattleHONOR()"
          }
        }
      },
      {
        Text = "家族试炼",
        tbChild = {
          [1] = {
            Text = "开启家族试炼",
            szCallback = "GM:OpenKinTrain()"
          },
          [2] = {
            Text = "进入家族试炼",
            szCallback = "GM:EnterKinTrain()"
          },
          [3] = {
            Text = "家族试炼开启(精简版 - 一人即可)",
            szCallback = "GM:KinTrainMgrStart()"
          }
        }
      },
      {
        Text = "攻城战",
        tbChild = {
          [1] = {
            Text = "开启攻城战宣战",
            szCallback = "GM:StartDomainBattleDeclareWar()"
          },
          [2] = {
            Text = "开启攻城战战场",
            szCallback = "GM:StartDomainBattleActivity()"
          },
          [3] = {
            Text = "查看攻城战届数",
            szCallback = "GM:GetValueDomainBattle()"
          },
          [4] = {
            Text = "领地行商(需占领领地)",
            szCallback = "GM:AddOnwenrDomainBattle()"
          },
          [5] = {
            Text = "在线的人都参战\n(需要家族宣战)",
            szCallback = "GM:CometomeDomain()"
          }
        }
      },
      {
        Text = "秦始皇陵",
        tbChild = {
          {
            Text = "进入皇陵",
            szCallback = "GM:EnterTombRequest()"
          },
          {
            Text = "进入2层",
            szCallback = "GM:EnterNormalFloor2()"
          },
          {
            Text = "进入3层",
            szCallback = "GM:EnterNormalFloor3()"
          },
          {
            Text = "增加表秦陵时间",
            szCallback = "GM:ImperialTombAddTime()"
          },
          {
            Text = "清除表秦陵时间\n（需先消耗再执行）",
            szCallback = "GM:ImperialTombClearTime()"
          },
          {
            Text = "召唤百将",
            szCallback = "GM:ImperialTombCallLeader()"
          },
          {
            Text = "密室邀请",
            szCallback = "GM:ImperialTombSecretRoom()"
          },
          {
            Text = "密室刷怪",
            szCallback = "GM:ImperialTombSpawnSecret()"
          },
          {
            Text = "开启始皇降世",
            szCallback = "GM:OpenEmperor()"
          },
          {
            Text = "开启女帝疑冢",
            szCallback = "GM:OpenEmperor1()"
          },
          {
            Text = "进入始皇降世地图",
            szCallback = "GM:EnterEmperorRoom()"
          },
          {
            Text = "刷新始皇降世首领",
            szCallback = "GM:CallBoss()"
          },
          {
            Text = "刷新始皇降世秦始皇",
            szCallback = "GM:CallEmperor()"
          },
          {
            Text = "关闭始皇降世",
            szCallback = "GM:CloseEmperor()"
          }
        }
      },
      {
        Text = "华山论剑",
        tbChild = {
          [1] = {
            Text = "开启预选赛",
            szCallback = "GM:StartEnterHuaShanLunJian()"
          },
          [2] = {
            Text = "进入预选赛准备场",
            szCallback = "GM:EnterHuaShanLunJian()"
          },
          [3] = {
            Text = "拉人入战队(需组队)",
            szCallback = "GM:JoinFightTeamHuaShanLunJian()"
          },
          [4] = {
            Text = "关闭预选赛",
            szCallback = "GM:CloseEnterHuaShanLunJian()"
          },
          [5] = {
            Text = "开启决赛\n(重复开需要重启服务器哦)",
            szCallback = "GM:StartFinalsHuaShanLunJian()"
          },
          [6] = {
            Text = "进入决赛场",
            szCallback = "GM:PlayerEnterHuaShanLunJian()"
          },
          [7] = {
            Text = "获取八强信息(最新消息)",
            szCallback = "GM:InformFinalsFightTeamListHuaShanLunJian()"
          }
        }
      },
      {
        Text = "跨服",
        tbChild = {
          {
            Text = "去跨服",
            szCallback = "GM:GoZoneserver()"
          },
          {
            Text = "设置跨服1",
            szCallback = "GM:ChangeZoneConnect()"
          }
        }
      },
      {
        Text = "心魔幻境(跨服)",
        tbChild = {
          {
            Text = "开启心魔幻境",
            szCallback = "GM:InDifferBattleStart()"
          },
          {
            Text = "增加心魔次数",
            szCallback = "GM:InDifferBattleDegree()"
          },
          {
            Text = "添加心魔宝珠",
            szCallback = "GM:AddInDifferBattleItem()"
          }
        }
      },
      {
        Text = "结婚相关",
        tbChild = {
          {
            Text = "获得求婚道具",
            szCallback = "GM:AddProposeItem()"
          },
          {
            Text = "队员互加好友",
            szCallback = "GM:ForceTeamAddFriend()"
          },
          {
            Text = "队员设置亲密度",
            szCallback = "GM:ForceTeamSetImitity()"
          },
          {
            Text = "查看预约婚期数据",
            szCallback = "GM:LogScheduleData()"
          },
          {
            Text = "庄园·晚樱连理道具",
            szCallback = "GM:WeddingItem1()"
          },
          {
            Text = "海岛·红鸾揽月道具",
            szCallback = "GM:WeddingItem2()"
          },
          {
            Text = "舫舟·乘龙配凤道具",
            szCallback = "GM:WeddingItem3()"
          },
          {
            Text = "开启婚礼",
            szCallback = "GM:TryStartBookWedding()"
          },
          {
            Text = "增加请柬",
            szCallback = "GM:WeedingWelcomeCount()"
          },
          {
            Text = "设置结婚关系",
            szCallback = "GM:MakeMarry()"
          },
          {
            Text = "离婚",
            szCallback = "GM:Divorce()"
          },
          {
            Text = "花轿游程开启",
            szCallback = "GM:StartCityTour()"
          },
          {
            Text = "迎宾开启",
            szCallback = "GM:StartWeddingPlay('StartWelcome')"
          },
          {
            Text = "迎宾结束",
            szCallback = "GM:StartWeddingPlay('EndWelcome')"
          },
          {
            Text = "山盟海誓开启",
            szCallback = "GM:StartWeddingPlay('StartPromise')"
          },
          {
            Text = "山盟海誓结束",
            szCallback = "GM:StartWeddingPlay('EndPromise')"
          },
          {
            Text = "拜堂开启",
            szCallback = "GM:StartWeddingPlay('StartMarryCeremony')"
          },
          {
            Text = "拜堂结束",
            szCallback = "GM:StartWeddingPlay('EndMarryCeremony')"
          },
          {
            Text = "开心爆竹开启",
            szCallback = "GM:StartWeddingPlay('AddFirecracker')"
          },
          {
            Text = "开心爆竹结束",
            szCallback = "GM:StartWeddingPlay('EndFirecracker')"
          },
          {
            Text = "同食用心果开启",
            szCallback = "GM:StartWeddingPlay('AddConcentricFruit')"
          },
          {
            Text = "同食用心果结束",
            szCallback = "GM:StartWeddingPlay('EndConcentricFruit')"
          },
          {
            Text = "宴席开启",
            szCallback = "GM:StartWeddingPlay('StartTableFood')"
          },
          {
            Text = "宴席结束",
            szCallback = "GM:StartWeddingPlay('EndTableFood')"
          },
          {
            Text = "派喜糖开启",
            szCallback = "GM:StartWeddingPlay('StartCandy')"
          }
        }
      }
    }
  },
  [tbDataIndex.AddPower] = {
    Text = "角色能力添加\n [B0E2FF]乀(ˉεˉ乀)[-] ",
    tbChild = {
      [1] = {
        Text = "全能小强变身\n[FF1493]╮(╯▽╰)╭ [-]",
        szCallback = "GM:SwitchSkillState()"
      },
      [2] = {
        Text = "全能大强变身\n[FF1493]╰(`□′)╯[-]",
        szCallback = "GM:SwitchSkillState1()"
      },
      [3] = {
        Text = "10倍界王拳\n[FF1493]～(￣▽￣～)[-]",
        szCallback = "GM:SwitchSkillState2()"
      },
      [4] = {
        Text = "20倍界王拳\n[FF1493]┑(￣Д ￣)┍ [-]",
        szCallback = "GM:SwitchSkillState3()"
      },
      [5] = {
        Text = "30倍界王拳\n[FF1493](～￣▽￣)～ [-]",
        szCallback = "GM:SwitchSkillState4()"
      }
    }
  },
  [tbDataIndex.Money] = {
    Text = "大侠，发财吗 \n [B03060](～o▔▽▔)～o [-]",
    tbChild = {
      [1] = {
        Text = "加钱999999",
        szCallback = "GM:GMAddMoney(999999)"
      },
      [2] = {
        Text = "购买周卡",
        szCallback = "GM:BuyWeekCardCallBack()"
      },
      [3] = {
        Text = "购买月卡",
        szCallback = "GM:BuyMonCardCallBack()"
      },
      [4] = {
        Text = "0.99美元礼包",
        szCallback = "GM:OnBuyDayCardCallBack1()"
      },
      [5] = {
        Text = "1.99美元礼包",
        szCallback = "GM:OnBuyDayCardCallBack3()"
      },
      [6] = {
        Text = "2.99美元礼包",
        szCallback = "GM:OnBuyDayCardCallBack6()"
      },
      [7] = {
        Text = "30级的一本万利",
        szCallback = "GM:OnBuyInvestCallBack1()"
      },
      [8] = {
        Text = "65级的一本万利\n[00FF00](先买上面的(╬▔皿▔)凸)[-]",
        szCallback = "GM:OnBuyInvestCallBack2()"
      },
      [9] = {
        Text = "充值档次\n(实际只加赠送的元宝)",
        tbChild = {
          [1] = {
            Text = "6 RMB",
            szCallback = "GM:OnTotalRechargeChange6RMB()"
          },
          [2] = {
            Text = "30 RMB",
            szCallback = "GM:OnTotalRechargeChange30RMB()"
          },
          [3] = {
            Text = "98 RMB",
            szCallback = "GM:OnTotalRechargeChange98RMB()"
          },
          [4] = {
            Text = "198 RMB",
            szCallback = "GM:OnTotalRechargeChange198RMB()"
          },
          [5] = {
            Text = "328 RMB",
            szCallback = "GM:OnTotalRechargeChange328RMB()"
          },
          [6] = {
            Text = "648 RMB",
            szCallback = "GM:OnTotalRechargeChange648RMB()"
          }
        }
      }
    }
  },
  [tbDataIndex.GainItem] = {
    Text = "获取道具",
    szCallback = "GM:GetItem()"
  },
  [tbDataIndex.Revive] = {
    Text = "信春哥，满血复活",
    szCallback = "GM:Revive()"
  },
  [tbDataIndex.nPartnerDataIndex] = {
    Text = "叱咤江湖岂能没有同伴\n [8B864E]~@^_^@~[-]",
    tbChild = {
      [1] = {
        Text = "我要SS级所有同伴",
        szCallback = string.format("GM:AddQualityPartner(2)")
      },
      [nSSPartnerSingleIndex] = {
        Text = "我要SS级单个同伴",
        tbChild = {}
      },
      [3] = {
        Text = "我要S级所有同伴",
        szCallback = string.format("GM:AddQualityPartner(3)")
      },
      [nSPartnerSingleIndex] = {
        Text = "我要S级单个同伴",
        tbChild = {}
      },
      [5] = {
        Text = "我要A级所有同伴",
        szCallback = string.format("GM:AddQualityPartner(4)")
      },
      [nAPartnerSingleIndex] = {
        Text = "我要A级单个同伴",
        tbChild = {}
      },
      [7] = {
        Text = "我要各个AI的同伴",
        szCallback = string.format("GM:AddAIPartner(%s)", tbAllTestAIPartner)
      },
      [8] = {
        Text = "给上阵同伴升级",
        szCallback = string.format("GM:AddPartnerExp()")
      },
      [nAllPartnerIndex] = {
        Text = "所有同伴",
        tbChild = {}
      }
    }
  },
  [tbDataIndex.Role] = {
    Text = "XX级角色\n 各种强化镶嵌妥妥的",
    tbChild = {}
  },
  [tbDataIndex.nLevelUpDataIndex] = {
    Text = "等级升级",
    tbChild = {}
  },
  [tbDataIndex.nHonorDataIndex] = {
    Text = "头衔升级",
    tbChild = {}
  },
  [tbDataIndex.BattleSignIn] = {
    Text = "战场报名",
    szCallback = "GM:OpenBattleSignUp()"
  },
  [tbDataIndex.BaoZang] = {
    Text = "兄弟，寻宝吗\n[40E0D0]ㄟ(▔皿▔ㄟ)[-] ",
    tbChild = {
      [1] = {
        Text = "来一打藏宝图",
        szCallback = "GM:AddCangbaotu()"
      },
      [2] = {
        Text = "来一打高级藏宝图",
        szCallback = "GM:AddSeniorCangbaotu()"
      }
    }
  },
  [tbDataIndex.TeamFuben] = {
    Text = "组队副本",
    tbChild = {
      [1] = {
        Text = "20级秘境",
        szCallback = "GM:Go2TeamFuben(1,1)"
      },
      [2] = {
        Text = "40级秘境",
        szCallback = "GM:Go2TeamFuben(1,2)"
      },
      [3] = {
        Text = "60级秘境",
        szCallback = "GM:Go2TeamFuben(1,3)"
      }
    }
  },
  [tbDataIndex.RandomFuben] = {
    Text = "凌绝峰\n ########### \n 地宫副本",
    tbChild = {}
  },
  [tbDataIndex.AddItem] = {
    Text = "增加指定道具",
    szCallback = "GM:AddItemList()"
  },
  [tbDataIndex.TestClientPk] = {
    Text = "客户端同屏PK测试",
    szCallback = "GM:TestClientPk()"
  },
  [tbDataIndex.UnlockFuben] = {
    Text = "开关卡",
    szCallback = "GM:UnlockFuben()"
  },
  [tbDataIndex.CleanBag] = {
    Text = "清空背包",
    szCallback = "GM:CleanBag()"
  },
  [tbDataIndex.Refresh] = {
    Text = "Test小功能\n [C1FFC1]（*^灬^*）[-]",
    tbChild = {
      {
        Text = "刷新HotFix",
        szCallback = "GM:CheckFixCmd()"
      },
      {
        Text = "刷新主播配置文件",
        szCallback = "GM:ChatHostInfo()"
      },
      {
        Text = "时间轴相关",
        tbChild = {
          {
            Text = "查看开服天数",
            szCallback = "GM:GetServerOpenDay()"
          },
          {
            Text = "查看开服时间",
            szCallback = "GM:ServerCreateTime()"
          },
          {
            Text = "输出所有时间轴的开启时间",
            szCallback = "GM:OutPutAllTimeFrameInfo()"
          },
          {
            Text = "查询时间轴是否开启",
            szCallback = "GM:QueryTimeFrameIsOpen()"
          },
          {
            Text = "查询时间轴开启时间",
            szCallback = "GM:QueryTimeFrameOpenTime()"
          }
        }
      },
      {
        Text = "强制存盘",
        szCallback = "GM:ForceSaveData()"
      },
      {
        Text = "查看在线人数",
        szCallback = "GM:OnlinePlayerCount()"
      },
      {
        Text = "查看当前地图人数",
        szCallback = "GM:GetMapPlayer()"
      },
      {
        Text = "查看当前地图内所有玩家的战力",
        szCallback = "GM:GetMapPlayerPower()"
      },
      {
        Text = "获得活跃度",
        szCallback = "GM:EverydayTarget()"
      },
      {
        Text = "清除转门派CD",
        szCallback = "GM:RemoveUesrValue()"
      },
      {
        Text = "解除动态禁言",
        szCallback = "GM:ChatMgrSetFilterText()"
      },
      {
        Text = "所有人来我身边",
        szCallback = "GM:Cometome()"
      },
      {
        Text = "召唤1号位同伴",
        szCallback = "GM:CreatePartnerByPos()"
      },
      {
        Text = "礼包码",
        szCallback = "GM:ShowCodeGift()"
      },
      {
        Text = "头衔所需令牌",
        tbChild = {
          {
            Text = "升级[ADFF2F]凌云[-]所需令牌",
            szCallback = "GM:HonorLingYun()"
          },
          {
            Text = "升级[ADFF2F]御空[-]所需令牌",
            szCallback = "GM:HonorYuKong()"
          },
          {
            Text = "升级[ADFF2F]潜龙[-]所需令牌",
            szCallback = "GM:HonorQianLong()"
          },
          {
            Text = "升级[ADFF2F]傲世[-]所需令牌",
            szCallback = "GM:HonorAoShi()"
          },
          {
            Text = "升级[ADFF2F]倚天[-]所需令牌",
            szCallback = "GM:HonorYiTian()"
          },
          {
            Text = "升级[ADFF2F]至尊[-]所需令牌",
            szCallback = "GM:HonorZhiZun()"
          },
          {
            Text = "升级[ADFF2F]武圣[-]所需令牌",
            szCallback = "GM:HonorWuShen()"
          },
          {
            Text = "升级[ADFF2F]无双[-]所需令牌",
            szCallback = "GM:HonorWuShuang()"
          }
        }
      },
      {
        Text = "在线的人建家族\n(需执行两次)",
        szCallback = "GM:KinIsNameValid()"
      },
      {
        Text = "家族在线进组\n(需先创建队伍)",
        szCallback = "GM:Kinteam()"
      },
      {
        Text = "测试挂机/经验",
        tbChild = {
          {
            Text = "开启怪物计数",
            szCallback = "GM:StartMonsterCount()"
          },
          {
            Text = "显示怪物计数",
            szCallback = "GM:ShowMonsterCount()"
          },
          {
            Text = "清空经验",
            szCallback = "GM:ClearExp()"
          },
          {
            Text = "定时自动战斗",
            szCallback = "GM:TryAutoFight()"
          }
        }
      },
      {
        Text = "Debug信息开关",
        szCmd = "Ui:ShowDebugInfo(not Ui.FTDebug.bShowDebugInfo); me.CenterMsg((Ui.FTDebug.bShowDebugInfo and '开启' or '关闭') .. '成功');"
      },
      {
        Text = "主播",
        tbChild = {
          {
            Text = "获取主播权限",
            szCallback = "GM:GetHostAuth()"
          },
          {
            Text = "撤销主播权限",
            szCallback = "GM:CancelHostAuth()"
          }
        }
      },
      {
        Text = "手Q数据上报\n（需用SDK登陆）",
        szCallback = "GM:ReportQQData()"
      }
    }
  },
  [tbDataIndex.House] = {
    Text = "家园",
    tbChild = {
      {
        Text = "获得家园",
        szCallback = "GM:GetHouse()"
      },
      {
        Text = "升级家园",
        szCallback = "GM:LevelupHouse()"
      },
      {
        Text = "获得所有家具材料",
        szCallback = "GM:GetAllHouseMaterial()"
      },
      {
        Text = "获得所有家具",
        szCallback = "GM:GetAllHouseFurniture()"
      }
    }
  },
  [tbDataIndex.KinTool] = {
    Text = "家族工具&活动\n惊喜多多，还不快来",
    tbChild = {
      {
        Text = "开启家族运镖",
        szCallback = "GM:StartKinEscort()"
      },
      {
        Text = "开启家族烤火",
        szCallback = "GM:StartKinGatherActivity()"
      },
      {
        Text = "增加家族建设资金",
        szCallback = "GM:AddKinFound()"
      },
      {
        Text = "开启家族宝贝",
        szCallback = "GM:OpenMascot()"
      },
      {
        Text = "关闭家族宝贝",
        szCallback = "GM:CloseMascot()"
      },
      {
        Text = "清除传功CD",
        szCallback = "GM:ChuangGongUserValue()"
      },
      {
        Text = "增加被传功次数",
        szCallback = "GM:AddDegreeChuangGong()"
      },
      {
        Text = "增加可传功次数",
        szCallback = "GM:AddDegreeChuangGongSend()"
      },
      {
        Text = "师徒目标完成",
        szCallback = "GM:TargetAddCount()"
      },
      {
        Text = "获取家族ID",
        szCallback = "GM:KinId()"
      },
      {
        Text = "查询家族活跃状态",
        szCallback = "GM:KinLastJudge()"
      },
      {
        Text = "在线的人加我家族\n(需族长且自己同意申请)",
        szCallback = "GM:KinGetAllPlayer()"
      },
      {
        Text = "解散家族\n[FF0000]慎点 {{{(>_<)}}}[-]",
        szCallback = "GM:DismissMyKin()"
      }
    }
  },
  [tbDataIndex.ChangeFaction] = {
    Text = "去PK场或转门派",
    tbChild = {
      [1] = {
        Text = "去PK场",
        szCallback = "me.SwitchMap(1006, 0, 0)"
      },
      [2] = {
        Text = "天王",
        szCallback = "ChangeFaction.tbDef.nMapTID = me.nMapTemplateId; ChangeFaction:PlayerChangeFaction(me, 1)"
      },
      [3] = {
        Text = "峨眉",
        szCallback = "ChangeFaction.tbDef.nMapTID = me.nMapTemplateId; ChangeFaction:PlayerChangeFaction(me, 2)"
      },
      [4] = {
        Text = "桃花",
        szCallback = "ChangeFaction.tbDef.nMapTID = me.nMapTemplateId; ChangeFaction:PlayerChangeFaction(me, 3)"
      },
      [5] = {
        Text = "逍遥",
        szCallback = "ChangeFaction.tbDef.nMapTID = me.nMapTemplateId; ChangeFaction:PlayerChangeFaction(me, 4)"
      },
      [6] = {
        Text = "武当",
        szCallback = "ChangeFaction.tbDef.nMapTID = me.nMapTemplateId; ChangeFaction:PlayerChangeFaction(me, 5)"
      },
      [7] = {
        Text = "天忍",
        szCallback = "ChangeFaction.tbDef.nMapTID = me.nMapTemplateId; ChangeFaction:PlayerChangeFaction(me, 6)"
      },
      [8] = {
        Text = "少林",
        szCallback = "ChangeFaction.tbDef.nMapTID = me.nMapTemplateId; ChangeFaction:PlayerChangeFaction(me, 7)"
      },
      [9] = {
        Text = "翠烟",
        szCallback = "ChangeFaction.tbDef.nMapTID = me.nMapTemplateId; ChangeFaction:PlayerChangeFaction(me, 8)"
      },
      [10] = {
        Text = "唐门",
        szCallback = "ChangeFaction.tbDef.nMapTID = me.nMapTemplateId; ChangeFaction:PlayerChangeFaction(me, 9)"
      },
      [11] = {
        Text = "昆仑",
        szCallback = "ChangeFaction.tbDef.nMapTID = me.nMapTemplateId; ChangeFaction:PlayerChangeFaction(me, 10)"
      },
      [12] = {
        Text = "丐帮",
        szCallback = "ChangeFaction.tbDef.nMapTID = me.nMapTemplateId; ChangeFaction:PlayerChangeFaction(me, 11)"
      },
      [13] = {
        Text = "五毒",
        szCallback = "ChangeFaction.tbDef.nMapTID = me.nMapTemplateId; ChangeFaction:PlayerChangeFaction(me, 12)"
      },
      [14] = {
        Text = "藏剑",
        szCallback = "ChangeFaction.tbDef.nMapTID = me.nMapTemplateId; ChangeFaction:PlayerChangeFaction(me, 13)"
      },
      [15] = {
        Text = "长歌",
        szCallback = "ChangeFaction.tbDef.nMapTID = me.nMapTemplateId; ChangeFaction:PlayerChangeFaction(me, 14)"
      }
    }
  }
}
function tbUi:OnOpen()
  self:UpdateData()
  self:ResetUi()
  self:UpdateMainUi()
  self:ClearObj(1, 2, 3)
end
function tbUi:UpdateData()
  self.tbGMData[tbDataIndex.nPartnerDataIndex].tbChild = self.tbGMData[tbDataIndex.nPartnerDataIndex].tbChild or {}
  local tbAllPartner = self.tbGMData[tbDataIndex.nPartnerDataIndex].tbChild[nAllPartnerIndex]
  if tbAllPartner then
    tbAllPartner.tbChild = {}
  end
  local tbAllSSPartner = self.tbGMData[tbDataIndex.nPartnerDataIndex].tbChild[nSSPartnerSingleIndex]
  if tbAllSSPartner then
    tbAllSSPartner.tbChild = {}
  end
  local tbAllSPartner = self.tbGMData[tbDataIndex.nPartnerDataIndex].tbChild[nSPartnerSingleIndex]
  if tbAllSPartner then
    tbAllSPartner.tbChild = {}
  end
  local tbAllAPartner = self.tbGMData[tbDataIndex.nPartnerDataIndex].tbChild[nAPartnerSingleIndex]
  if tbAllAPartner then
    tbAllAPartner.tbChild = {}
  end
  local tbAllPartnerBaseInfo = Partner:GetAllPartnerBaseInfo()
  for nId, tbInfo in pairs(tbAllPartnerBaseInfo or {}) do
    if tbAllSSPartner.tbChild and tbInfo.nQualityLevel == 2 then
      table.insert(tbAllSSPartner.tbChild, {
        Text = string.format("我要 %s ", tbInfo.szName),
        szCallback = string.format("GM:AddOnePartner(%d,true)", nId)
      })
    end
    if tbAllSPartner.tbChild and tbInfo.nQualityLevel == 3 then
      table.insert(tbAllSPartner.tbChild, {
        Text = string.format("我要 %s ", tbInfo.szName),
        szCallback = string.format("GM:AddOnePartner(%d,true)", nId)
      })
    end
    if tbAllAPartner.tbChild and tbInfo.nQualityLevel == 4 then
      table.insert(tbAllAPartner.tbChild, {
        Text = string.format("我要 %s ", tbInfo.szName),
        szCallback = string.format("GM:AddOnePartner(%d,true)", nId)
      })
    end
    if tbAllPartner.tbChild then
      table.insert(tbAllPartner.tbChild, {
        Text = string.format("我要 %s ", tbInfo.szName),
        szCallback = string.format("GM:AddOnePartner(%d,true)", nId)
      })
    end
  end
  self.tbGMData[tbDataIndex.nLevelUpDataIndex].tbChild = {}
  for i = 0, nMaxLevelUp do
    table.insert(self.tbGMData[tbDataIndex.nLevelUpDataIndex].tbChild, {
      Text = string.format("%s0+ 等级段", i),
      tbChild = {}
    })
    for j = 0, 9 do
      local nLevel = i * 10 + j
      if nLevel > 0 then
        table.insert(self.tbGMData[tbDataIndex.nLevelUpDataIndex].tbChild[i + 1].tbChild, {
          Text = string.format("升级到 %s ", i * 10 + j),
          szCallback = string.format("GM:AddPlayerLevel(math.max(%d * 10 + %d, 1))", i, j)
        })
      end
    end
  end
  self.tbGMData[tbDataIndex.nHonorDataIndex].tbChild = {}
  for nHonorLevel = 1, #Player.tbHonorLevelSetting do
    local szHonorName = Player.tbHonorLevel:GetHonorName(nHonorLevel)
    table.insert(self.tbGMData[tbDataIndex.nHonorDataIndex].tbChild, {
      Text = "升级" .. szHonorName,
      szCallback = string.format("GM:SetHonorLevel(%d)", nHonorLevel)
    })
  end
  local tbEquipDesc = {
    [1] = "获得%d级装备（低）",
    [2] = "获得%d级装备（中）",
    [3] = "获得%d级装备（高）"
  }
  local tbInsertDesc = {
    [1] = "镶嵌%d级（低）",
    [2] = "镶嵌%d级（中）",
    [3] = "镶嵌%d级（高）"
  }
  self.tbGMData[tbDataIndex.Role].tbChild = {}
  local tbAllRole = self.tbGMData[tbDataIndex.Role].tbChild
  for nIndex, tbData in ipairs(tbRoleData) do
    local nLevel = tbData.nLevel or 0
    local tbStrong = tbData.tbStrong or {}
    local tbInsert = tbData.tbInsert or {}
    if nLevel ~= 0 then
      tbAllRole[nIndex] = {
        Text = string.format("%d级角色", nLevel),
        tbChild = {}
      }
      local tbRole = tbAllRole[nIndex].tbChild
      local nBaseIndex = #tbStrong + 1
      tbRole[1] = {
        Text = string.format("升级到%d级", nLevel),
        szCallback = string.format("GM:AddPlayerLevel(%d)", nLevel)
      }
      tbRole[nBaseIndex + 1] = {
        Text = "技能学满",
        szCallback = "GM:SkillUpFull()"
      }
      for i = 1, #tbStrong do
        local nStrong = tbStrong[i]
        tbRole[#tbRole + 1] = {
          Text = string.format("强化+%d", nStrong),
          szCallback = string.format("GM:EnhanceEquip(%d)", nStrong)
        }
      end
      for nType = 1, #tbEquipDesc do
        tbRole[#tbRole + 1] = {
          Text = string.format(tbEquipDesc[nType], nLevel),
          szCallback = string.format("GM:AddEquips(%d,%d)", nLevel, nType)
        }
      end
      for nType = 1, #tbInsert do
        local nInsert = tbInsert[nType]
        tbRole[#tbRole + 1] = {
          Text = string.format(tbInsertDesc[nType], nInsert),
          szCallback = string.format("GM:InsetEquip(%d,%d)", nInsert, nType)
        }
      end
    end
  end
  local tbRandomDesc = {
    [1] = "1层秘境",
    [2] = "2层秘境",
    [3] = "3层秘境",
    [4] = "4层秘境",
    [5] = "5层秘境",
    [6] = "6层秘境"
  }
  local tbRandomBefore = {
    [1] = {
      Text = "随机秘境(需二人组队)",
      szCallback = "GM:Go2RandomFuben()"
    },
    [2] = {
      Text = "凌绝峰卡片收集开启",
      szCallback = "GM:BeginNewSession()"
    },
    [3] = {
      Text = "全套卡片",
      szCallback = "GM:BeginNewSessionItem()"
    }
  }
  local tbRandomAfter = {
    [1] = {
      Text = "直接胜利",
      szCallback = "GM:GameWinFubenInstance()"
    },
    [2] = {
      Text = "退出凌绝峰",
      szCallback = "GM:GotoEntryPoint()"
    },
    [3] = {
      Text = "重置凌绝峰次数",
      szCallback = "GM:RemoveUesrValueRandomFuben()"
    },
    [4] = {
      Text = "地宫小副本",
      tbChild = {
        [1] = {
          Text = "直接地宫",
          szCallback = "GM:DirectGotoDungeon()"
        },
        [2] = {
          Text = "地宫二层(水晶)\n需在地宫一层使用",
          szCallback = "GM:DirectGotoDungeonCrystal()"
        },
        [3] = {
          Text = "地宫二层(BOSS)\n需在地宫一层使用",
          szCallback = "GM:DirectGotoDungeonBoss()"
        }
      }
    }
  }
  if not self.tbRandomSetting then
    local tbFile = LoadTabFile("Setting/Fuben/RandomFuben/RoomSetting.tab", "sd", nil, {"Info", "MapId"})
    for _, tbRow in pairs(tbFile) do
      local tbRoom = Lib:SplitStr(tbRow.Info, "_")
      local nLayer = tonumber(tbRoom[1]) or 0
      local nRoom = tonumber(tbRoom[2]) or 0
      self.tbRandomSetting = self.tbRandomSetting or {}
      self.tbRandomSetting[nLayer] = self.tbRandomSetting[nLayer] or {}
      self.tbRandomSetting[nLayer][nRoom] = tbRow.MapId
    end
  end
  self.tbGMData[tbDataIndex.RandomFuben].tbChild = {}
  local tbRandomFuben = self.tbGMData[tbDataIndex.RandomFuben].tbChild
  local nBeforeLen = #tbRandomFuben
  for i, tbChild in ipairs(tbRandomBefore) do
    tbRandomFuben[nBeforeLen + i] = tbChild
  end
  local nMiddleLen = #tbRandomFuben
  for nLayer = 1, #tbRandomDesc do
    local szLayerDesc = tbRandomDesc[nLayer]
    if not szLayerDesc then
      break
    end
    if self.tbRandomSetting[nLayer] then
      for nRoom = 1, #self.tbRandomSetting[nLayer] do
        local nMapId = self.tbRandomSetting[nLayer][nRoom]
        if nMapId then
          tbRandomFuben[nLayer + nMiddleLen] = tbRandomFuben[nLayer + nMiddleLen] or {
            Text = szLayerDesc,
            tbChild = {}
          }
          tbRandomFuben[nLayer + nMiddleLen].tbChild[nRoom] = {
            Text = string.format("%d号房间", nRoom),
            szCallback = string.format("GM:Go2RandomFuben(%d)", nMapId)
          }
        end
      end
    end
  end
  local nAfterLen = #tbRandomFuben
  for i, tbChild in ipairs(tbRandomAfter) do
    tbRandomFuben[nAfterLen + i] = tbChild
  end
end
tbUi.tbHideUI = {
  ScrollView1 = true,
  ScrollView2 = true,
  ScrollView3 = true,
  Title1 = true,
  Title2 = true,
  Title3 = true
}
function tbUi:ResetUi()
  for szUiName, _ in pairs(self.tbHideUI) do
    self.pPanel:SetActive(szUiName, false)
  end
end
function tbUi:ShowUi(...)
  self:ResetUi()
  local tbIdx = {
    ...
  }
  for _, nIdx in pairs(tbIdx) do
    self.pPanel:SetActive("ScrollView" .. nIdx, true)
    self.pPanel:SetActive("Title" .. nIdx, true)
  end
end
function tbUi:UpdateMainUi()
  self:ShowUi(1)
  local function fnOnClick(itemObj)
    if self.tbGMData[itemObj.nId].tbChild then
      self:UpdateChildUi(itemObj.nId)
    else
      local szCallBack = self.tbGMData[itemObj.nId].szCallback
      if self.tbGMData[itemObj.nId].szCmd then
        local fn = loadstring(self.tbGMData[itemObj.nId].szCmd)
        Lib:CallBack({fn})
      else
        GMCommand(szCallBack)
      end
      me.CenterMsg(string.format("【%s】 成功上车", self.tbGMData[itemObj.nId].Text))
    end
    self:ClearObj(1, 2, 3)
    itemObj.pPanel:SetActive("Choose", true)
  end
  local function fnSetItem(itemObj, nIdx)
    self.tbGMData[nIdx].nId = nIdx
    itemObj.pPanel:Label_SetText("Name", self.tbGMData[nIdx].Text or "")
    itemObj.nId = nIdx
    itemObj.pPanel.OnTouchEvent = fnOnClick
    itemObj.pPanel:SetActive("Mark", self.tbGMData[nIdx].tbChild)
  end
  self.ScrollView1:Update(#self.tbGMData, fnSetItem)
end
function tbUi:UpdateChildUi(nPartnerId)
  self:ShowUi(1, 2)
  local tbChildData = self.tbGMData[nPartnerId].tbChild
  local function fnOnClick(itemObj)
    local nId = itemObj.nId
    if tbChildData[nId].tbChild then
      self:UpdateChild2Ui(nPartnerId, nId)
    else
      local szCallBack = tbChildData[nId].szCallback
      if tbChildData[itemObj.nId].szCmd then
        local fn = loadstring(tbChildData[itemObj.nId].szCmd)
        Lib:CallBack({fn})
      else
        GMCommand(szCallBack)
      end
      me.CenterMsg(string.format("【%s】 成功上车", tbChildData[nId].Text))
    end
    self:ClearObj(2, 3)
    itemObj.pPanel:SetActive("Choose", true)
  end
  local function fnSetItem(itemObj, nIdx)
    itemObj.pPanel:Label_SetText("Name", tbChildData[nIdx].Text or "")
    itemObj.nId = nIdx
    itemObj.pPanel.OnTouchEvent = fnOnClick
    itemObj.pPanel:SetActive("Mark", tbChildData[nIdx].tbChild)
  end
  self.ScrollView2:Update(#tbChildData, fnSetItem)
end
function tbUi:UpdateChild2Ui(nGrandParentId, nPartnerId)
  self:ShowUi(1, 2, 3)
  local tbChildData = self.tbGMData[nGrandParentId].tbChild[nPartnerId].tbChild
  local function fnOnClick(itemObj)
    local nId = itemObj.nId
    if tbChildData[nId].tbChild then
      self:UpdateChild3Ui()
    else
      local szCallBack = tbChildData[nId].szCallback
      if tbChildData[itemObj.nId].szCmd then
        local fn = loadstring(tbChildData[itemObj.nId].szCmd)
        Lib:CallBack({fn})
      else
        GMCommand(szCallBack)
      end
      me.CenterMsg(string.format("【%s】 成功上车", tbChildData[nId].Text))
    end
    self:ClearObj(3)
    itemObj.pPanel:SetActive("Choose", true)
  end
  local function fnSetItem(itemObj, nIdx)
    itemObj.pPanel:Label_SetText("Name", tbChildData[nIdx].Text or "")
    itemObj.nId = nIdx
    itemObj.pPanel.OnTouchEvent = fnOnClick
    itemObj.pPanel:SetActive("Mark", tbChildData[nIdx].tbChild)
  end
  self.ScrollView3:Update(#tbChildData, fnSetItem)
end
function tbUi:UpdateChild3Ui()
end
function tbUi:ClearObj(...)
  local tbIdx = {
    ...
  }
  for _, nIdx in pairs(tbIdx) do
    for i = 0, 300 do
      local itemObj = self["ScrollView" .. nIdx].Grid["Item" .. i]
      if not itemObj then
        break
      end
      itemObj.pPanel:SetActive("Choose", false)
    end
  end
end
function tbUi:SearchSaveList(szSearch)
  local tbSaveCommond
  if szSearch == "" then
    tbSaveCommond = self.tbGMData
  else
    tbSaveCommond = self:GetSaveCommondByStr(szSearch)
  end
  if not tbSaveCommond then
    return
  end
  local function fnOnClick(itemObj)
    local nId = tbSaveCommond[itemObj.nId].nId
    if tbSaveCommond[itemObj.nId].tbChild then
      self:UpdateChildUi(nId)
    else
      local szCallBack = tbSaveCommond[itemObj.nId].szCallback
      if tbSaveCommond[itemObj.nId].szCmd then
        local fn = loadstring(tbSaveCommond[itemObj.nId].szCmd)
        Lib:CallBack({fn})
      else
        GMCommand(szCallBack)
      end
      me.CenterMsg(string.format("【%s】 成功上车", tbSaveCommond[itemObj.nId].Text))
    end
    self:ClearObj(1, 2, 3)
    itemObj.pPanel:SetActive("Choose", true)
  end
  local function fnSetItem(itemObj, nIdx)
    itemObj.pPanel:Label_SetText("Name", tbSaveCommond[nIdx].Text or "")
    itemObj.nId = nIdx
    itemObj.pPanel.OnTouchEvent = fnOnClick
    itemObj.pPanel:SetActive("Mark", tbSaveCommond[nIdx].tbChild)
  end
  self.ScrollView1:Update(#tbSaveCommond, fnSetItem)
end
function tbUi:GetSaveCommondByStr(szSearch)
  local tbCommond = {}
  for index, info in ipairs(self.tbGMData) do
    info.nId = nil
    local szCommond = info.Text
    local isShow = string.find(szCommond, szSearch)
    if isShow then
      info.nId = index
      table.insert(tbCommond, info)
    end
  end
  return tbCommond
end
tbUi.tbUiInputOnChange = {}
function tbUi.tbUiInputOnChange:Input()
  local szSearch = self.Input:GetText()
  self:SearchSaveList(szSearch)
end
tbUi.tbOnClick = {
  BtnClose = function(self)
    Ui:CloseWindow(self.UI_NAME)
  end
}
