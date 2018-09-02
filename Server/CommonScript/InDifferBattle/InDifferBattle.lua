Require("CommonScript/EnvDef.lua")
Require("CommonScript/Item/Define.lua")

InDifferBattle.tbRandSkillBook = {3434, 3435, 3436, 3437}; --分别对应四个位置的秘籍


InDifferBattle.tbBattleTypeSetting = {
        Normal = { 
            szName = "";
            NextType = "Month";
            szScroeDescHelpKey = "InDifferBattleScoreHelp";
        };
        Month  = { 
            szName = "月度";
            NextType = "Season";
            szOpenTimeFrame = "OpenLevel109";
            nKeyQualifyTime = 7;
            nNeedGrade = 3; --进入月度的评级邀请
            nQualifyTitleId = 7703; --获取资格时获得的称号id

            szOpenTimeFunc = "GetNextOpenTimeMonth";
            OpenTimeWeek    = 1; --第一个周六
            OpenTimeWeekDay = 6;
            OpenTimeHour    = 20;
            OpenTimeMinute  = 25;
            tbLeagueTipMailInfo = {"月度心魔幻境參賽通知", "      您已獲得本次月度心魔幻境競技的參賽資格，比賽時間為[EACC00]%s[-]，請您務必準時參加。屆時會有更豐厚的獎勵以及更高的榮譽等著您！"};
            szScroeDescHelpKey = "InDifferBattleScoreHelpMonth";
        };
        Season = { 
            szName = "季度";
            NextType = "Year";
            szOpenTimeFrame = "OpenLevel109";
            nKeyQualifyTime = 8;
            nNeedGrade = 3; 
            nQualifyTitleId = 7704;

            szOpenTimeFunc = "GetNextOpenTimeSeason";
            OpenTimeWeek    = -1; --最后一个周六
            OpenTimeWeekDay = 6;
            OpenTimeHour    = 20;
            OpenTimeMinute  = 25;
            tbLeagueTipMailInfo = {"季度心魔幻境參賽通知", "      您已獲得本次季度心魔幻境競技的參賽資格，比賽時間為[EACC00]%s[-]，請您務必準時參加。屆時會有更豐厚的獎勵以及更高的榮譽等著您！"};
            szScroeDescHelpKey = "InDifferBattleScoreHelpMonth";
        };
        Year   = { 
            szName = "年度";
            szOpenTimeFrame = "OpenLevel109";
            nKeyQualifyTime = 9;
            nNeedGrade = 3; 
            nQualifyTitleId = 7705;

            szOpenTimeFunc = "GetNextOpenTimeYear";
            OpenTimeWeek    = -1; --最后一个周六
            OpenTimeWeekDay = 6;
            OpenTimeHour    = 20;
            OpenTimeMinute  = 25;
            tbLeagueTipMailInfo = {"年度心魔幻境參賽通知", "      您已獲得本次年度心魔幻境競技的參賽資格，比賽時間為[EACC00]%s[-]，請您務必準時參加。屆時會有更豐厚的獎勵以及更高的榮譽等著您！"};
            szScroeDescHelpKey = "InDifferBattleScoreHelpMonth";
        };
    };

InDifferBattle.tbBattleTypeList = { "Normal","Month","Season", "Year"}; --资格赛从低到高的顺序
for i,v in ipairs(InDifferBattle.tbBattleTypeList) do
    InDifferBattle.tbBattleTypeSetting[v].nLevel = i;
end

InDifferBattle.tbDefine = {
    SAVE_GROUP = 118;
    KEY_CUR_HONOR = 3;
    KEY_WIN_TIMES = 6; --暂时只是记获胜次数
    UPDATE_SYNC_DMG_INTERVAL = 10; --更新实时伤害排行间隔
    szDmgUiTips = "獎勵規則：\n·輸出排名進入前3的隊伍，可獲得獎勵\n·獎勵獲得的多少，與排名相關\n·最後一擊有額外的獎勵加成"; --打开伤害输出界面的提示
    szDmgUiTipsBoss = "獎勵規則：\n·輸出排名進入前5的隊伍，可獲得獎勵\n·獎勵獲得的多少，與排名相關\n·最後一擊有額外的獎勵加成"; --打开伤害输出界面的提示
    szMonoeyType = "Jade",--幻玉直接使用已经废弃的 Jade 货币了
    szOpenTimeFrame = "OpenDay118"; --开启的时间轴，开启累积次数
    nPreTipTime = 2 * 24 * 3600;            -- 开赛前提示，提前时间


    szCalenddayKey = "InDifferBattle"; --日历的key
    nReadyMapTemplateId = 3002; --准备场地图模板
    nFightMapTemplateId = 3001; --战斗场地图模板 --托管时间需要等于赛事时长
    MATCH_SIGNUP_TIME   = 5*60; --匹配时间
    nMinLevel     = 60;     --最小参与等级
    nMaxTeamRoleNum   = 3;      --最大队伍内人数
    nMinTeamNum       = 1;  --最小队伍数
    nMaxTeamNum       = 36;  --最大队伍数
    nPlayerLevel      = 80; --调整后的等级
    nCloseRoomPunishPersent = 0.9; -- 关闭房间时设置该房间玩家的血量百分比（掉当前血量的10%）
    nCloseRoomSkillId = 3083; --关闭房间时播放的技能特效
    tbInitBuffId = {3182, 1, 3600}; --初始状态给的buffid ，等级， 时间（默认拥有一个-89100战力的buff）
    nReviveItemId     = 3309; -- 重生道具id
    nReviveDelayTime  = 20; --死亡延迟复活时长，帧数
    nReviveEffectSkillId = 3084; --死亡重生的技能效果id
    tbReviveSafeBuff = { 1517, 45 }; --复活时保护buff, 状态时间帧数
    szAvatarEquipKey  = "InDiffer"; --初始状态对应装备key
    tbKillGetMoneyRand = { 30, 50, 5};--抢夺幻玉的数量 30%~50%，最少抢夺5幻玉
    tbKillGetItemNumRand = { 30, 50 };--随机抢夺的道具数量 30%~50%
    nTempCastSKillNpcId = 2113 ; --释放机关陷阱技能召唤出来的npc
    nGateNpcId  = 73;--门的npcID
    tbGateDirectionModify = {
        LeftNpc   = { 0, -1};
        RightNpc  = { 0,  1};
        TopNpc    = {-1,  0};
        BottomNpc = {1,  0};
    };

    tbCastSkillNpcPos = { --每个房间释放技能的npc所在的位置 ，一般在地图外的region，玩家不能主动同步到
        [1]  = {293,294};
        [2]  = {293,294};
        [3]  = {293,294};
        [4]  = {293,294};
        [5]  = {293,294};
        [6]  = {293,294};
        [7]  = {293,294};
        [8]  = {293,294};
        [9]  = {293,294};
        [10] = {293,294};
        [11] = {293,294};
        [12] = {293,294};
        [13] = {293,294};
        [14] = {293,294};
        [15] = {293,294};
        [16] = {293,294};
        [17] = {293,294};
        [18] = {293,294};
        [19] = {293,294};
        [20] = {293,294};
        [21] = {293,294};
        [22] = {293,294};
        [23] = {293,294};
        [24] = {293,294};
        [25] = {293,294};
    };

    tbStateGetScore = { --每个阶段的存活得分 --TODO ,阶段检查
        [2] = { nSurviveScore = 2, nKillScore = 2 };
        [4] = { nSurviveScore = 4, nKillScore = 4 };
        [6] = { nSurviveScore = 6, nKillScore = 6 };
        [8] = { nSurviveScore = 8, nKillScore = 8 };
    };

    tbWinTeamAddScore = { 60, 40  }; --优胜分，存活\死亡

    tbLastSwitchRandPosSet = { "center", "center_2", "center_3", "center_4", "center_5", "center_6", "center_7", "center_8" };--最后阶段传送的随机点名 TODO 检查里面都在一房间里的
    tbLastSkillBuff = { 1517,1,5*15 };--技能id，等级，帧数（最后一阶段开始时无敌5秒）
    tbFirstSkillBuff = { 1517,1,8*15 };--技能id，等级，帧数（第一阶段开始时无敌8秒）

    nSafeStateSkillBuffId = 1517;   --休息阶段的保护状态

    tbOpenBoxType     = { --打开宝箱Npc模板对应的事件类型， class对应 IndifferBox 
        [1994] = {  --宝箱，不同阶段 不同的概率事件
                    [2] = 
                    {   
                        { 0.2, { 
                                 {"OnOpenBoxCastSkillCycle", -1, 3183, 1, -1, -1};  --对应位置释放循环技能，释放间隔（帧数，-1为只释放1次），技能Id，技能等级，参数1，参数2
                                 {"OnBlackBoardMsg", "寶箱內空空如也！糟糕，竟觸發了幻境機關。"}; --黑条提示
                               },};
                        { 0.8, { 
                                 {"OnSendRandDropAwardToTeam", "tbBoxAward_1", 2, 4 }; --随机赠送2-4 份奖励表给全队伍
                               },};
                    };
                    [4] = 
                    {   
                        { 0.2, { 
                                     {"OnOpenBoxCastSkillCycle", -1, 3183, 1, -1, -1}; 
                                     {"OnBlackBoardMsg", "寶箱內空空如也！糟糕，竟觸發了幻境機關。"}; 
                                 },};
                        { 0.8, { 
                                    {"OnSendRandDropAwardToTeam", "tbBoxAward_2", 2, 4 }; 
                                  },};
                    };
                    [6] = 
                    {   
                        { 0.2, { 
                                     {"OnOpenBoxCastSkillCycle", -1, 3183, 1, -1, -1}; 
                                     {"OnBlackBoardMsg", "寶箱內空空如也！糟糕，竟觸發了幻境機關。"}; 
                                 },};
                        { 0.8, { 
                                    {"OnSendRandDropAwardToTeam", "tbBoxAward_3", 2, 4 }; 
                               },};
                    };
                 };  

        [2101] = {  --幻象
                    [2] = 
                    {   
                        { 1, { 
                                 {"OnSendRandDropAwardToTeam", "tbSuperBoxAward_1", 6, 10 }; --随机赠送6-10 份奖励表给全队伍
                                 {"OnSendAwardTeamAll", {{"RandBuff"}} };  --随机获得buff
                                 {"OnAddRandPosNpcSet", 1994, 1, 4, 6 };--再该npc周围随机放一波箱子，templateid, nlevel, nRandMin, nRandMax
                            },};
                    };
                    [4] = 
                    {   

                        { 1, { 
                                 {"OnSendRandDropAwardToTeam", "tbSuperBoxAward_2", 6, 10 };
                                 {"OnSendAwardTeamAll", {{"RandBuff"}} }; 
                                 {"OnAddRandPosNpcSet", 1994, 1, 4, 6 };
                            },};
                    };
                    [6] = 
                    {   
    
                        { 1, { 
                                 {"OnSendRandDropAwardToTeam", "tbSuperBoxAward_3", 6, 10 };
                                 {"OnSendAwardTeamAll", {{"RandBuff"}} }; 
                                 {"OnAddRandPosNpcSet", 1994, 1, 4, 6 };
                            },};
                    };
                 };  
    }; 

    tbAutoDeleteWhenStateChangeNpc = { --阶段变化时会自动删除的npc模板
        [1994] = 1; --宝箱，因为宝箱是有可能事件里开出来的，容易漏配存活时间
    };  

    tbBattleNpcDropSettingItem = { --小怪的掉落表 先不用了
        --{203,  500  }; --道具id， 随机值，总值10000
    };

    tbBattleNpcDropSettingMoney = { --小怪掉落的货币范围,等概率
        [2] = {{ "RandMoney", 8, 16 }, { "RandItemCount", 3299, 2,4  }  }; --阶段对应奖励
        [4] = {{ "RandMoney", 15, 25 },{ "RandItemCount", 3299, 4,6  } };
        [6] = {{ "RandMoney", 32, 40 },{ "RandItemCount", 3299, 6,12 } };
    };

    tbRandBuffSet = {  --随机buff配置表 ，目前是所有buff等概率的
        --回血：30%
        { 3166, 1, 5*15 }; --buffid ,等级，持续帧数
        { 3166, 1, 5*15 };
        { 3166, 1, 5*15 };
        { 3166, 1, 5*15 };
        { 3166, 1, 5*15 };
        { 3166, 1, 5*15 };
        --攻击力：15%
        { 3167, 1, 60*15*3 };
        { 3167, 1, 60*15*3 };
        { 3167, 1, 60*15*3 };
        --全抗：15%
        { 3168, 1, 60*15*3 };
        { 3168, 1, 60*15*3 };
        { 3168, 1, 60*15*3 };
        --跑速：15%
        { 3169, 1, 60*15*3 };
        { 3169, 1, 60*15*3 };
        { 3169, 1, 60*15*3 };
        --会心：15%
        { 3191, 1, 60*15*3 };
        { 3191, 1, 60*15*3 };
        { 3191, 1, 60*15*3 };
        --无敌：10%
        { 3192, 1, 15*15 };
        { 3192, 1, 15*15 };
    };

    nLastDmgBossHPPercent = 15; --首领  的最后一击加成百分比
    nLastDmgBigBossHPPercent = 10; --boos的最后一击加成

    READY_MAP_POS = {       -- 准备场的随机点
        {2706,5659}; 
        {2666,6319}; 
        {2684,5001}; 
        {6931,5712}; 
        {6947,6462}; 
        {6947,4994}; 
    };     

    tbRandMoney = { 5 , 15 }; --随机给的勾玉范围
    nDefaultStrengthLevel = 40; --默认的强化等级
    nStrengthStep = 10; --每次强化级别
    nEnhanceItemId = 3299; --强化水晶道具id
    tbEnhanceScroll = {
        { szDesc = "武器", tbEquipPos = { Item.EQUIPPOS_WEAPON}, tbEnhanceCost = { [50] = 5, [60] = 10, [70] = 20, [80] = 40, [90] = 80, [100] = 160}}; --tbEnhanceCost 对应强化等级和消耗
        { szDesc = "衣服", tbEquipPos = {Item.EQUIPPOS_BODY},   tbEnhanceCost = { [50] = 3, [60] = 6,  [70] = 12, [80] = 24, [90] = 48, [100] = 96} };
        { szDesc = "首飾", tbEquipPos = { Item.EQUIPPOS_NECKLACE, Item.EQUIPPOS_RING, Item.EQUIPPOS_PENDANT, Item.EQUIPPOS_AMULET }, tbEnhanceCost = { [50] = 8, [60] = 16, [70] = 32, [80] = 64, [90] = 128, [100] = 256} };
        { szDesc = "防具", tbEquipPos = {Item.EQUIPPOS_HEAD, Item.EQUIPPOS_CUFF, Item.EQUIPPOS_BELT, Item.EQUIPPOS_FOOT }, tbEnhanceCost = { [50] = 4, [60] = 8, [70] = 16, [80] = 32, [90] = 64, [100] = 128 } };
    }; --每个位置需要的强化卷轴数
    --tbEnhanceScroll = {  --强化卷轴对应的装备位置 和最大等级 --class IndifferScrollEnhance
      --  --武器强化卷轴
      --  [3299] = { tbEquipPos = {Item.EQUIPPOS_WEAPON}, nMaxEnhance = 60  };
      --  [3300] = { tbEquipPos = {Item.EQUIPPOS_WEAPON}, nMaxEnhance = 80, nMinEnhance = 60  };
      --  --衣服强化卷轴
      --  [3301] = { tbEquipPos = {Item.EQUIPPOS_BODY},  nMaxEnhance = 60  };
      --  [3302] = { tbEquipPos = {Item.EQUIPPOS_BODY},  nMaxEnhance = 80, nMinEnhance = 60  };
      --  --项链强化卷轴
      --  [3303] = { tbEquipPos = {Item.EQUIPPOS_NECKLACE},  nMaxEnhance = 60  };
      --  [3304] = { tbEquipPos = {Item.EQUIPPOS_NECKLACE},  nMaxEnhance = 80, nMaxEnhance = 60  };
      --  --戒指强化卷轴
      --  [3305] = { tbEquipPos = {Item.EQUIPPOS_RING},  nMaxEnhance = 60  };
      --  [3306] = { tbEquipPos = {Item.EQUIPPOS_RING},  nMaxEnhance = 80, nMaxEnhance = 60  };
      --  --玉佩强化卷轴
      --  [3422] = { tbEquipPos = {Item.EQUIPPOS_PENDANT},  nMaxEnhance = 60  };
      --  [3423] = { tbEquipPos = {Item.EQUIPPOS_PENDANT},  nMaxEnhance = 80, nMaxEnhance = 60  };
      --  --护身符强化卷轴
      --  [3424] = { tbEquipPos = {Item.EQUIPPOS_AMULET},  nMaxEnhance = 60  };
      --  [3425] = { tbEquipPos = {Item.EQUIPPOS_AMULET},  nMaxEnhance = 80, nMaxEnhance = 60  };
      --  --帽子强化卷轴
      --  [3426] = { tbEquipPos = {Item.EQUIPPOS_HEAD},  nMaxEnhance = 60  };
      --  [3427] = { tbEquipPos = {Item.EQUIPPOS_HEAD},  nMaxEnhance = 80, nMaxEnhance = 60  };
      --  --护腕强化卷轴
      --  [3428] = { tbEquipPos = {Item.EQUIPPOS_CUFF},  nMaxEnhance = 60  };
      --  [3429] = { tbEquipPos = {Item.EQUIPPOS_CUFF},  nMaxEnhance = 80, nMaxEnhance = 60  };
      --  --腰带强化卷轴
      --  [3430] = { tbEquipPos = {Item.EQUIP_BELT},  nMaxEnhance = 60  };
      --  [3431] = { tbEquipPos = {Item.EQUIP_BELT},  nMaxEnhance = 80, nMaxEnhance = 60  };
      --  --鞋子强化卷轴
      --  [3432] = { tbEquipPos = {Item.EQUIPPOS_FOOT},  nMaxEnhance = 60  };
      --  [3433] = { tbEquipPos = {Item.EQUIPPOS_FOOT},  nMaxEnhance = 80, nMaxEnhance = 60  };
    --}; 
    --坐骑进化卷轴class 是 IndifferScrollHorse
    tbHorseUpgrade = { 2400, 3012 };
    --秘籍进化道具class 是 IndifferScrollBook
    nMaxSkillBookType = 1; --最大使用中级秘籍

    tbInitGiveItem = {  --初始随机给的道具 ,总概率值10000
      {7000, {"RandItemCount", 3299, 3,5 } };  --随机水晶
      {500,  { "item", 2400, 1 } }; --随机值, 类型，道具id，个数，
      {2000, { "SkillBook", 0 } }; --门派秘籍 ,0是随机，否则是对应的type
      {500,  { "item", 1391, 1 }}; 
    };

    nMaxRoomNum = 25;


    -----------奖励
    tbExChangeBoxInfo = 
    {
        {3481,  2000, "幻境黃金寶箱"}, --荣誉兑换的黄金宝箱id, 所需要的荣誉
        {3482, 1000, "幻境白銀寶箱"} , --白银宝箱Id，需要荣誉
    },
    tbGetHonorSetting = {  --积分获得对应荣誉设定
        { nScoreMin = 0,   tbAwardNormal = { {"IndifferHonor", 1200}, { "BasicExp", 50 } }; 
                            tbAwardMonth = { {"IndifferHonor", 4000}, { "BasicExp", 50 } }; 
                            tbAwardSeason = { {"IndifferHonor", 4000}, { "BasicExp", 50 } }; 
                            tbAwardYear = { {"IndifferHonor", 4000}, { "BasicExp", 50 } };    
                            };
        { nScoreMin = 6,   tbAwardNormal = { {"IndifferHonor", 1500}, { "BasicExp", 60 } }; 
                           tbAwardMonth = { {"IndifferHonor", 6000}, { "BasicExp", 60 } }; 
                           tbAwardSeason = { {"IndifferHonor", 6000}, { "BasicExp", 60 } }; 
                           tbAwardYear = { {"IndifferHonor", 6000}, { "BasicExp", 60 } };  
                           };
        { nScoreMin = 16,  tbAwardNormal = { {"IndifferHonor", 2000}, { "BasicExp", 70 } }; 
                           tbAwardMonth = { {"IndifferHonor", 8000}, { "BasicExp", 70 } }; 
                           tbAwardSeason = { {"IndifferHonor", 8000}, { "BasicExp", 70 } };
                           tbAwardYear = { {"IndifferHonor", 8000}, { "BasicExp", 70 } };    
                           };
        { nScoreMin = 32,  tbAwardNormal = { {"IndifferHonor", 2500}, { "BasicExp", 80 } }; 
                           tbAwardMonth = { {"IndifferHonor", 10000}, { "BasicExp", 80 } };
                           tbAwardSeason = { {"IndifferHonor", 10000}, { "BasicExp", 80 } }; 
                           tbAwardYear = { {"IndifferHonor", 10000}, { "BasicExp", 80 } };    
                           };
        { nScoreMin = 48,  tbAwardNormal = { {"IndifferHonor", 3000}, { "BasicExp", 100 } };
                           tbAwardMonth = { {"IndifferHonor", 12000}, { "BasicExp", 100 } };
                           tbAwardSeason = { {"IndifferHonor", 12000}, { "BasicExp", 100 } };
                           tbAwardYear = { {"IndifferHonor", 12000}, { "BasicExp", 100 } };   
                           };
        { nScoreMin = 96,  tbAwardNormal = { {"IndifferHonor", 4000}, { "BasicExp", 100 } };
                           tbAwardMonth = { {"IndifferHonor", 16000}, { "BasicExp", 100 } };
                           tbAwardSeason = { {"IndifferHonor", 16000}, { "BasicExp", 100 } };
                           tbAwardYear = { {"IndifferHonor", 16000}, { "BasicExp", 100 } };    
                           };
    };

    tbEvaluationSetting = { --积分对应评价
        { nScoreMin = 0,  szName = "普通", szColor = "FFFFFF"   };
        { nScoreMin = 6,  szName = "一般", szColor = "64db00"   };
        { nScoreMin = 16, szName = "良好", szColor = "11adf6"   };
        { nScoreMin = 32, szName = "優秀", szColor = "aa62fc"   };
        { nScoreMin = 48, szName = "卓越", szColor = "ff578c"   };
        { nScoreMin = 96, szName = "最佳", szColor = "ff8f06"   };
    };

    tbAddImitySetting = {  --增加亲密度
        [0] = 100; --最终存活
        [2] = 60;
        [4] = 70;
        [6] = 80;
        [8] = 90;
        [12] = 120; --优胜
    };
    
    ------------------商人设置
     --不能买到的也要配置以获取价格
    nSelllPricePercent = 0.5;--出售价格目前为0.5 * nPrice
    nCanBuyDistance = 500; --距离商人购买的最远距离
    tbSellWareSetting = {
        --强化水晶
        [3299] = { nPrice = 4,  nSort = 1  }, 

        --2级附魔石
        [1392] = { nPrice = 60, nSort = 2  }, 
        --1级附魔石
        [1391] = { nPrice = 16, nSort = 3  }, 
        --乌云踏雪
        [2400] = { nPrice = 24, nSort = 4  }, 

        --随机门派秘籍
        [3434] = { nPrice = 20, nSort = 5  }, 
        [3435] = { nPrice = 20, nSort = 6  }, 
        [3436] = { nPrice = 20, nSort = 7  }, 
        [3437] = { nPrice = 20, nSort = 8  }, 

        --坐骑进阶卷轴
        [3307] = { nPrice = 30, nSort = 9  }, 
        --秘籍进阶卷轴
        [3308] = { nPrice = 90, nSort = 10  }, 




        --高级强化卷轴
        -- [3300] = { nPrice = 120, nSort = 10  }, 
        -- [3302] = { nPrice = 72,  nSort = 11  }, 
        -- [3304] = { nPrice = 48,  nSort = 12  }, 
        -- [3306] = { nPrice = 48,  nSort = 13  }, 
        -- [3423] = { nPrice = 48,  nSort = 14  }, 
        -- [3425] = { nPrice = 48,  nSort = 15  }, 
        -- [3427] = { nPrice = 24,  nSort = 16  }, 
        -- [3429] = { nPrice = 24,  nSort = 17  }, 
        -- [3431] = { nPrice = 24,  nSort = 18  }, 
        -- [3433] = { nPrice = 24,  nSort = 19  }, 

        --初级强化卷轴
        -- [3299] = { nPrice = 30,  nSort = 20  }, 
        -- [3301] = { nPrice = 18,  nSort = 21  }, 
        -- [3303] = { nPrice = 12,  nSort = 22  }, 
        -- [3305] = { nPrice = 12,  nSort = 23  }, 
        -- [3422] = { nPrice = 12,  nSort = 24  }, 
        -- [3424] = { nPrice = 12,  nSort = 25  }, 
        -- [3426] = { nPrice = 6,   nSort = 26  }, 
        -- [3428] = { nPrice = 6,   nSort = 27  }, 
        -- [3430] = { nPrice = 6,   nSort = 28  }, 
        -- [3432] = { nPrice = 6,   nSort = 29  }, 
    };
    ----商人不同刷新道具设置设定 TODO 出售道具的价格设定检查
    tbSellWarePropSetting = { 
        --第一阶段
        [2] = { 
                { 3299, 300, 600, }; --道具id， 随机最小，最大
                { 2400, 4, 10, };  --乌云踏雪
                { InDifferBattle.tbRandSkillBook, 12, 20, }; --table 的话就先从table里随机 
                { 1391, 4, 10, };  --1级附魔石
              };

        --第二阶段
        [4] = {
                { 3299, 300, 600, };
                { 2400, 2, 4, };  --乌云踏雪
                { 3307, 1, 2, }; 
                { InDifferBattle.tbRandSkillBook, 4, 8, }; --随机门派秘籍
                { 3308, 2, 4, }; 
                { 1391, 2, 4, };  --1级附魔石
                { 1392, 1, 2, };  --2级附魔石
              };

        --第三阶段
        [6] = {
                { 3299, 300, 600, };
                { 2400, 2, 4, };  --乌云踏雪
                { 3307, 2, 4, }; 
                { InDifferBattle.tbRandSkillBook, 4, 8, }; --随机门派秘籍
                { 3308, 4, 8, }; 
                { 1391, 2, 4, };  --1级附魔石
                { 1392, 2, 4, };  --2级附魔石
              };
    };


    ------------------流程 
    STATE_TRANS = {
        [1] = {nSeconds = 90,     szFunc = "StartFight1",   szDesc = "請選擇你在幻境中的門派"}, 
        [2] = {nSeconds = 360,    szFunc = "ResetTime",     szDesc = "階段一：探索幻境", szBeginNotify = "探索幻境提升能力，生存到最後！"}, 
        [3] = {nSeconds = 90,     szFunc = "ReStartFight",  szDesc = "休整階段",         szBeginNotify = "本階段禁止戰鬥，可前往商人處購買物品！"}, 
        [4] = {nSeconds = 360,    szFunc = "ResetTime",     szDesc = "階段二：探索幻境", szBeginNotify = "幻境異變，部分區域的入口已坍塌！"}, 
        [5] = {nSeconds = 90,     szFunc = "ReStartFight",  szDesc = "休整階段",         szBeginNotify = "本階段禁止戰鬥，可前往商人處購買物品！"}, 
        [6] = {nSeconds = 360,    szFunc = "ResetTime",     szDesc = "階段三：探索幻境", szBeginNotify = "幻境異變，部分區域的入口已坍塌！"}, 
        [7] = {nSeconds = 90,     szFunc = "ReStartFight",  szDesc = "休整階段",         szBeginNotify = "本階段禁止戰鬥，可前往商人處購買物品！"}, 
        [8] = {nSeconds = 240,    szFunc = "StopFight",     szDesc = "階段四：擊敗其他對手",     szBeginNotify = "擊敗其他對手，生存到最後！"}, 
        [9] = {nSeconds = 60,     szFunc = "CloseBattle",   szDesc = "活動結束，離開幻境"},
    };



    tbActiveTrans = {
        [1] = 
        {
            [60]  = {
                        { "SynGameTime",};
                   };
            [80]  = {
                        { "SynGameTime",};
                   };
        };
	
	     --第一个战斗阶段
        [2] = 
        {   
            [1]   = { 
                        --同步一下客户端时间
                        { "SynGameTime",};

                        --Templateid, nLevel, nRoomIndex, 随机点集合，随机个数，重生时间
                        {"AddRandPosNpcSet", 2096, 80, 24, {"npc_1", "npc_2", "npc_3", "npc_4", "npc_5"}, {3,5}, 20 }; --刷小怪的,一个小区域随机刷多少怪
                        {"AddRandPosNpcSet", 2097, 80, 25, {"npc_1", "npc_2", "npc_3", "npc_4", "npc_5"}, {3,5}, 20 };
                        {"AddRandPosNpcSet", 2098, 80, 10, {"npc_1", "npc_2", "npc_3", "npc_4", "npc_5"}, {3,5}, 20 };
                        {"AddRandPosNpcSet", 2099, 80, 11, {"npc_1", "npc_2", "npc_3", "npc_4", "npc_5"}, {3,5}, 20 };
                        {"AddRandPosNpcSet", 2100, 80, 12, {"npc_1", "npc_2", "npc_3", "npc_4", "npc_5"}, {3,5}, 20 };
                        {"AddRandPosNpcSet", 2097, 80, 23, {"npc_1", "npc_2", "npc_3", "npc_4", "npc_5"}, {3,5}, 20 };
                        {"AddRandPosNpcSet", 2098, 80, 9,  {"npc_1", "npc_2", "npc_3", "npc_4", "npc_5"}, {3,5}, 20 };
                        {"AddRandPosNpcSet", 2099, 80, 2,  {"npc_1", "npc_2", "npc_3", "npc_4", "npc_5"}, {3,5}, 20 };
                        {"AddRandPosNpcSet", 2100, 80, 3,  {"npc_1", "npc_2", "npc_3", "npc_4", "npc_5"}, {3,5}, 20 };
                        {"AddRandPosNpcSet", 2096, 80, 13, {"npc_1", "npc_2", "npc_3", "npc_4", "npc_5"}, {3,5}, 20 };
                        {"AddRandPosNpcSet", 2098, 80, 22, {"npc_1", "npc_2", "npc_3", "npc_4", "npc_5"}, {3,5}, 20 };
                        {"AddRandPosNpcSet", 2099, 80, 8,  {"npc_1", "npc_2", "npc_3", "npc_4", "npc_5"}, {3,5}, 20 };
                        {"AddRandPosNpcSet", 2100, 80, 1,  {"npc_1", "npc_2", "npc_3", "npc_4", "npc_5"}, {3,5}, 20 };
                        {"AddRandPosNpcSet", 2096, 80, 4,  {"npc_1", "npc_2", "npc_3", "npc_4", "npc_5"}, {3,5}, 20 };
                        {"AddRandPosNpcSet", 2097, 80, 14, {"npc_1", "npc_2", "npc_3", "npc_4", "npc_5"}, {3,5}, 20 };
                        {"AddRandPosNpcSet", 2099, 80, 21, {"npc_1", "npc_2", "npc_3", "npc_4", "npc_5"}, {3,5}, 20 };
                        {"AddRandPosNpcSet", 2100, 80, 7,  {"npc_1", "npc_2", "npc_3", "npc_4", "npc_5"}, {3,5}, 20 };
                        {"AddRandPosNpcSet", 2096, 80, 6,  {"npc_1", "npc_2", "npc_3", "npc_4", "npc_5"}, {3,5}, 20 };
                        {"AddRandPosNpcSet", 2097, 80, 5,  {"npc_1", "npc_2", "npc_3", "npc_4", "npc_5"}, {3,5}, 20 };
                        {"AddRandPosNpcSet", 2098, 80, 15, {"npc_1", "npc_2", "npc_3", "npc_4", "npc_5"}, {3,5}, 20 };
                        {"AddRandPosNpcSet", 2100, 80, 20, {"npc_1", "npc_2", "npc_3", "npc_4", "npc_5"}, {3,5}, 20 };
                        {"AddRandPosNpcSet", 2096, 80, 19, {"npc_1", "npc_2", "npc_3", "npc_4", "npc_5"}, {3,5}, 20 };
                        {"AddRandPosNpcSet", 2097, 80, 18, {"npc_1", "npc_2", "npc_3", "npc_4", "npc_5"}, {3,5}, 20 };
                        {"AddRandPosNpcSet", 2098, 80, 17, {"npc_1", "npc_2", "npc_3", "npc_4", "npc_5"}, {3,5}, 20 };
                        {"AddRandPosNpcSet", 2099, 80, 16, {"npc_1", "npc_2", "npc_3", "npc_4", "npc_5"}, {3,5}, 20 };

                        
                        {"AddRandTypeSetTimer", --在对应点随机执行一种事件，
                            1, "box_buff", 60, -- 房间号，点名, 下一次执行时间
                            { 
                              {0.5, "AddMapNpcByPosName", 1994, 1, 59},  --前面的是概率，后面的是函数及传参，存活时间
                              {0.5, "AddDropBuffByPosName", "1000|30;1001|15;1002|15;1003|15;1004|15;1005|10;1", } --如：1|20;2|30;5   1号buff概率20   2号buff概率30   总共随机5次；1号是buffid这个对应的是在  Setting\Item\DropBuffList.tab，这个表里的nObjId对应模型是在 Setting\Item\ObjData.tab 里
                            }, 
                        }; 
                        {"AddRandTypeSetTimer",
                            2, "box_buff" , 60,
                            { 
                              {0.5, "AddMapNpcByPosName", 1994, 1, 59},
                              {0.5, "AddDropBuffByPosName", "1000|30;1001|15;1002|15;1003|15;1004|15;1005|10;1", }
                            },
                        }; 
                        {"AddRandTypeSetTimer",
                            3, "box_buff" , 60,
                            { 
                              {0.5, "AddMapNpcByPosName", 1994, 1, 59},
                              {0.5, "AddDropBuffByPosName", "1000|30;1001|15;1002|15;1003|15;1004|15;1005|10;1", }
                            },
                        }; 
                        {"AddRandTypeSetTimer",
                            4, "box_buff" , 60,
                            { 
                              {0.5, "AddMapNpcByPosName", 1994, 1, 59},
                              {0.5, "AddDropBuffByPosName", "1000|30;1001|15;1002|15;1003|15;1004|15;1005|10;1", }
                            },
                        }; 
                        {"AddRandTypeSetTimer",
                            5, "box_buff" , 60,
                            { 
                              {0.5, "AddMapNpcByPosName", 1994, 1, 59},
                              {0.5, "AddDropBuffByPosName", "1000|30;1001|15;1002|15;1003|15;1004|15;1005|10;1", }
                            },
                        }; 
                        {"AddRandTypeSetTimer",
                            6, "box_buff" , 60,
                            { 
                              {0.5, "AddMapNpcByPosName", 1994, 1, 59},
                              {0.5, "AddDropBuffByPosName", "1000|30;1001|15;1002|15;1003|15;1004|15;1005|10;1", }
                            },
                        }; 
                        {"AddRandTypeSetTimer",
                            7, "box_buff" , 60,
                            { 
                              {0.5, "AddMapNpcByPosName", 1994, 1, 59},
                              {0.5, "AddDropBuffByPosName", "1000|30;1001|15;1002|15;1003|15;1004|15;1005|10;1", }
                            },
                        }; 
                        {"AddRandTypeSetTimer",
                            8, "box_buff" , 60,
                            { 
                              {0.5, "AddMapNpcByPosName", 1994, 1, 59},
                              {0.5, "AddDropBuffByPosName", "1000|30;1001|15;1002|15;1003|15;1004|15;1005|10;1", }
                            },
                        }; 
                        {"AddRandTypeSetTimer",
                            9, "box_buff" , 60,
                            { 
                              {0.5, "AddMapNpcByPosName", 1994, 1, 59},
                              {0.5, "AddDropBuffByPosName", "1000|30;1001|15;1002|15;1003|15;1004|15;1005|10;1", }
                            },
                        };
                        {"AddRandTypeSetTimer",
                            10, "box_buff" , 60,
                            { 
                              {0.5, "AddMapNpcByPosName", 1994, 1, 59},
                              {0.5, "AddDropBuffByPosName", "1000|30;1001|15;1002|15;1003|15;1004|15;1005|10;1", }
                            },
                        }; 
                        {"AddRandTypeSetTimer",
                            11, "box_buff" , 60,
                            { 
                              {0.5, "AddMapNpcByPosName", 1994, 1, 59},
                              {0.5, "AddDropBuffByPosName", "1000|30;1001|15;1002|15;1003|15;1004|15;1005|10;1", }
                            },
                        }; 
                        {"AddRandTypeSetTimer",
                            12, "box_buff" , 60,
                            { 
                              {0.5, "AddMapNpcByPosName", 1994, 1, 59},
                              {0.5, "AddDropBuffByPosName", "1000|30;1001|15;1002|15;1003|15;1004|15;1005|10;1", }
                            },
                        }; 
                        {"AddRandTypeSetTimer",
                            13, "box_buff" , 60,
                            { 
                              {0.5, "AddMapNpcByPosName", 1994, 1, 59},
                              {0.5, "AddDropBuffByPosName", "1000|30;1001|15;1002|15;1003|15;1004|15;1005|10;1", }
                            },
                        }; 
                        {"AddRandTypeSetTimer",
                            14, "box_buff" , 60,
                            { 
                              {0.5, "AddMapNpcByPosName", 1994, 1, 59},
                              {0.5, "AddDropBuffByPosName", "1000|30;1001|15;1002|15;1003|15;1004|15;1005|10;1", }
                            },
                        }; 
                        {"AddRandTypeSetTimer",
                            15, "box_buff" , 60,
                            { 
                              {0.5, "AddMapNpcByPosName", 1994, 1, 59},
                              {0.5, "AddDropBuffByPosName", "1000|30;1001|15;1002|15;1003|15;1004|15;1005|10;1", }
                            },
                        }; 
                        {"AddRandTypeSetTimer",
                            16, "box_buff" , 60,
                            { 
                              {0.5, "AddMapNpcByPosName", 1994, 1, 59},
                              {0.5, "AddDropBuffByPosName", "1000|30;1001|15;1002|15;1003|15;1004|15;1005|10;1", }
                            },
                        }; 
                        {"AddRandTypeSetTimer",
                            17, "box_buff" , 60,
                            { 
                              {0.5, "AddMapNpcByPosName", 1994, 1, 59},
                              {0.5, "AddDropBuffByPosName", "1000|30;1001|15;1002|15;1003|15;1004|15;1005|10;1", }
                            },
                        }; 
                        {"AddRandTypeSetTimer",
                            18, "box_buff" , 60,
                            { 
                              {0.5, "AddMapNpcByPosName", 1994, 1, 59},
                              {0.5, "AddDropBuffByPosName", "1000|30;1001|15;1002|15;1003|15;1004|15;1005|10;1", }
                            },
                        }; 
                        {"AddRandTypeSetTimer",
                            19, "box_buff" , 60,
                            { 
                              {0.5, "AddMapNpcByPosName", 1994, 1, 59},
                              {0.5, "AddDropBuffByPosName", "1000|30;1001|15;1002|15;1003|15;1004|15;1005|10;1", }
                            },
                        }; 
                        {"AddRandTypeSetTimer",
                            20, "box_buff" , 60,
                            { 
                              {0.5, "AddMapNpcByPosName", 1994, 1, 59},
                              {0.5, "AddDropBuffByPosName", "1000|30;1001|15;1002|15;1003|15;1004|15;1005|10;1", }
                            },
                        }; 
                        {"AddRandTypeSetTimer",
                            21, "box_buff" , 60,
                            { 
                              {0.5, "AddMapNpcByPosName", 1994, 1, 59},
                              {0.5, "AddDropBuffByPosName", "1000|30;1001|15;1002|15;1003|15;1004|15;1005|10;1", }
                            },
                        }; 
                        {"AddRandTypeSetTimer",
                            22, "box_buff" , 60,
                            { 
                              {0.5, "AddMapNpcByPosName", 1994, 1, 59},
                              {0.5, "AddDropBuffByPosName", "1000|30;1001|15;1002|15;1003|15;1004|15;1005|10;1", }
                            },
                        }; 
                        {"AddRandTypeSetTimer",
                            23, "box_buff" , 60,
                            { 
                              {0.5, "AddMapNpcByPosName", 1994, 1, 59},
                              {0.5, "AddDropBuffByPosName", "1000|30;1001|15;1002|15;1003|15;1004|15;1005|10;1", }
                            },
                        }; 
                        {"AddRandTypeSetTimer",
                            24, "box_buff" , 60,
                            { 
                              {0.5, "AddMapNpcByPosName", 1994, 1, 59},
                              {0.5, "AddDropBuffByPosName", "1000|30;1001|15;1002|15;1003|15;1004|15;1005|10;1", }
                            },
                        }; 
                        {"AddRandTypeSetTimer",
                            25, "box_buff" , 60,
                            { 
                              {0.5, "AddMapNpcByPosName", 1994, 1, 59},
                              {0.5, "AddDropBuffByPosName", "1000|30;1001|15;1002|15;1003|15;1004|15;1005|10;1", }
                            },
                        }; 
                        
                        
                    };

            [10]   = {
                        --同步一下客户端时间
                        { "SynGameTime",};

                        --第一阶段10秒刷出：商人*2
                        {"OnWorldNotify", "神秘商人現身幻境，據說專賣一些幻境中特有之物（可通過地圖查看出現區域）"};
                        {"OnAddSingleRoomNpc", 1987, 50 + 5*60 + 90}; --添加单房间npc，npcId, 存活时间
                        {"OnAddSingleRoomNpc", 1987, 50 + 5*60 + 90};
                     };
            [50]   = {

                        --1-1房间陷阱
                        { "AddActiveCastSkill", 24, 
                            {
                                --先预警
                                { 2*15, {
                                        {3160, 1, 2610,20774},
                                        {3160, 1, 3583,20757},
                                        {3160, 1, 2615,19801},
                                        {3160, 1, 3562,19793},
                                        },
                                }, 
                                --第1个喷水
                                { 5,   	{
                                        {3189, 1, 2610,20774},
                                        {3189, 1, 3583,20757},
                                        {3189, 1, 2615,19801},
                                        {3189, 1, 3562,19793},
                                        },
                                }, 

                                --先预警
                                { 2*15, {
                                        {3160, 1, 3096,20320},
                                        {3160, 1, 2555,20323},
                                        {3160, 1, 3742,20307},
                                        },
                                }, 
                                --第2个喷水
                                { 5,   	{
                                        {3189, 1, 3096,20320},
                                        {3189, 1, 2555,20323},
                                        {3189, 1, 3742,20307},
                                        },
                                }, 

                                { 2*15, {
                                        {3160, 1, 3105,20917},
                                        {3160, 1, 3093,20323},
                                        {3160, 1, 3093,19714},
                                        },
                                }, 
                                --第3个喷水
                                { 5,   	{
                                        {3189, 1, 3105,20917},
                                        {3189, 1, 3093,20323},
                                        {3189, 1, 3093,19714},
                                        },
                                }, 

                                --先预警
                                { 2*15, {
                                        {3160, 1, 2610,20774},
                                        {3160, 1, 3583,20757},
                                        {3160, 1, 2615,19801},
                                        {3160, 1, 3562,19793},
                                        },
                                }, 
                                --第1个喷水
                                { 5,   	{
                                        {3189, 1, 2610,20774},
                                        {3189, 1, 3583,20757},
                                        {3189, 1, 2615,19801},
                                        {3189, 1, 3562,19793},
                                        },
                                }, 

                                --先预警
                                { 2*15, {
                                        {3160, 1, 3096,20320},
                                        {3160, 1, 2555,20323},
                                        {3160, 1, 3742,20307},
                                        },
                                }, 
                                --第2个喷水
                                { 5,   	{
                                        {3189, 1, 3096,20320},
                                        {3189, 1, 2555,20323},
                                        {3189, 1, 3742,20307},
                                        },
                                }, 

                                { 2*15, {
                                        {3160, 1, 3105,20917},
                                        {3160, 1, 3093,20323},
                                        {3160, 1, 3093,19714},
                                        },
                                }, 
                                --第3个喷水
                                {70*15, {
                                        {3189, 1, 3105,20917},
                                        {3189, 1, 3093,20323},
                                        {3189, 1, 3093,19714},
                                        },
                                }, 


                            }, 
                        };

                        --1-2房间陷阱
                        { "AddActiveCastSkill", 25, 
                            {
                                --先警示2秒
                                { 2*15, {
                                          {3160, 1, 7466,20281},
                                        },
                                }, 
                                --第1次毒雾
                                { 4*15, {
                                          {3185, 1, 7466,20281},
                                        },
                                }, 

                                --先警示2秒
                                { 2*15, {
                                          {3160, 1, 7466,20281},
                                        },
                                }, 
                                --第2次毒雾
                                { 4*15, {
                                          {3185, 1, 7466,20281},
                                        },
                                }, 

                                --先警示2秒
                                { 2*15, {
                                          {3160, 1, 7466,20281},
                                        },
                                }, 
                                --第3次毒雾
                                { 70*15, {
                                          {3185, 1, 7466,20281},
                                        },
                                }, 
                            }, 
                        };

                        --2-1房间陷阱
                        { "AddActiveCastSkill", 23, 
                            {
                                --第一排预警
                                { 2*15, {
                                        {3160, 1, 2345,16587},
                                        {3160, 1, 2941,16591},
                                        {3160, 1, 3448,16598},
                                        },
                                }, 
                                --第一排喷水
                                { 5,   {
                                        {3189, 1, 2345,16587},
                                        {3189, 1, 2941,16591},
                                        {3189, 1, 3448,16598},
                                        },
                                }, 

                                --第二排预警
                                { 2*15, {
                                        {3160, 1, 2345,16077},
                                        {3160, 1, 2959,16063},
                                        {3160, 1, 3506,16067},
                                        },
                                }, 
                                --第二排喷水
                                { 5,   	{
                                        {3189, 1, 2345,16077},
                                        {3189, 1, 2959,16063},
                                        {3189, 1, 3506,16067},
                                        },
                                }, 

                                --第三排预警
                                { 2*15, {
                                        {3160, 1, 2373,15605},
                                        {3160, 1, 2959,15584},
                                        {3160, 1, 3496,15591},
                                        },
                                }, 
                                --第三排喷水
                                { 5,   	{
                                        {3189, 1, 2373,15605},
                                        {3189, 1, 2959,15584},
                                        {3189, 1, 3496,15591},
                                        },
                                }, 

                                --第一排预警
                                { 2*15, {
                                        {3160, 1, 2345,16587},
                                        {3160, 1, 2941,16591},
                                        {3160, 1, 3448,16598},
                                        },
                                }, 
                                --第一排喷水
                                { 5,   	{
                                        {3189, 1, 2345,16587},
                                        {3189, 1, 2941,16591},
                                        {3189, 1, 3448,16598},
                                        },
                                }, 

                                --第二排预警
                                { 2*15, {
                                        {3160, 1, 2345,16077},
                                        {3160, 1, 2959,16063},
                                        {3160, 1, 3506,16067},
                                        },
                                }, 
                                --第二排喷水
                                { 5,   	{
                                        {3189, 1, 2345,16077},
                                        {3189, 1, 2959,16063},
                                        {3189, 1, 3506,16067},
                                        },
                                }, 

                                --第三排预警
                                { 2*15, {
                                        {3160, 1, 2373,15605},
                                        {3160, 1, 2959,15584},
                                        {3160, 1, 3496,15591},
                                        },
                                }, 
                                --第三排喷水
                                {70*15, {
                                        {3189, 1, 2373,15605},
                                        {3189, 1, 2959,15584},
                                        {3189, 1, 3496,15591},
                                        },
                                }, 

                            }, 
                        };

                        --2-5房间陷阱
                        { "AddActiveCastSkill", 13, 
                            {
                                --先警示2秒
                                { 2*15, {
                                          {3160, 1, 21798,16220},
                                        },
                                }, 
                                --第1次毒雾
                                { 4*15, {
                                          {3185, 1, 21798,16220},
                                        },
                                }, 

                                --先警示2秒
                                { 2*15, {
                                          {3160, 1, 21798,16220},
                                        },
                                }, 
                                --第2次毒雾
                                { 4*15, {
                                          {3185, 1, 21798,16220},
                                        },
                                }, 

                                --先警示2秒
                                { 2*15, {
                                          {3160, 1, 21798,16220},
                                        },
                                }, 
                                --第3次毒雾
                                { 70*15, {
                                          {3185, 1, 21798,16220},
                                        },
                                }, 
                            }, 
                        };

                        --3-1房间陷阱
                        { "AddActiveCastSkill", 22, 
                            {
                                --第1秒
                                { 15, {
                                        {3160, 1, 2373,15605},
                                      },
                                }, 
                                { 5,  {
                                        --1号喷水
                                        {3189, 1, 2373,15605},
                                      },
                                }, 

                                --第2秒
                                { 15, {
                                        {3160, 1, 2592,12141},
                                      },
                                }, 
                                { 5,  {
                                        --2号喷水
                                        {3189, 1, 2592,12141},
                                      },
                                }, 

                                --第3秒
                                { 15, {
                                        {3160, 1, 3427,12606},
                                        {3160, 1, 3400,11646},
                                      },
                                }, 
                                { 5,  {
                                        --3、4号喷水
                                        {3189, 1, 3427,12606},
                                        {3189, 1, 3400,11646},
                                      },
                                }, 

                                --第4秒
                                { 15, {
                                        {3160, 1, 3400,11646},
                                        {3160, 1, 2829,12605},
                                      },
                                }, 
                                { 5,  {
                                        --4、5号喷水
                                        {3189, 1, 3400,11646},
                                        {3189, 1, 2829,12605},
                                      },
                                }, 

                                --第5秒
                                { 15, {
                                        {3160, 1, 3103,12134},
                                        {3160, 1, 2829,12605},
                                        {3160, 1, 2780,11679},
                                      },
                                }, 
                                { 5,  {
                                        --5、6、1号喷水
                                        {3189, 1, 3103,12134},
                                        {3189, 1, 2829,12605},
                                        {3189, 1, 2780,11679},
                                      },
                                }, 

                                --第6秒
                                { 15, {
                                        {3160, 1, 2592,12141},
                                        {3160, 1, 2780,11679},
                                        {3160, 1, 3612,12080},
                                      },
                                }, 
                                { 5,  {
                                        --6、7、2号喷水
                                        {3189, 1, 2592,12141},
                                        {3189, 1, 2780,11679},
                                        {3189, 1, 3612,12080},
                                      },
                                }, 

                                --第7秒
                                { 15, {
                                        {3160, 1, 3103,12134},
                                        {3160, 1, 3427,12606},
                                        {3160, 1, 3612,12080},
                                      },
                                }, 
                                { 5,  {
                                        --7、1、3号喷水
                                        {3189, 1, 3103,12134},
                                        {3189, 1, 3427,12606},
                                        {3189, 1, 3612,12080},
                                      },
                                }, 

                                --第8秒
                                { 15, {
                                        {3160, 1, 2592,12141},
                                        {3160, 1, 3400,11646},
                                      },
                                }, 
                                { 5,  {
                                        --2、4号喷水
                                        {3189, 1, 2592,12141},
                                        {3189, 1, 3400,11646},
                                      },
                                }, 

                                --第9秒
                                { 15, {
                                        {3160, 1, 3427,12606},
                                        {3160, 1, 2829,12605},
                                      },
                                }, 
                                { 5,  {
                                        --3、5号喷水
                                        {3189, 1, 3427,12606},
                                        {3189, 1, 2829,12605},
                                      },
                                }, 

                                --第10秒
                                { 15, {
                                        {3160, 1, 2780,11679},
                                      },
                                }, 
                                { 5,  {
                                        --6号喷水
                                        {3189, 1, 2780,11679},
                                      },
                                }, 

                                --第11秒
                                { 15, {
                                        {3160, 1, 3612,12080},
                                      },
                                }, 
                                { 70*15,  {
                                        --7号喷水
                                        {3189, 1, 3612,12080},
                                      },
                                }, 

                            }, 
                        };

                        --3-5房间陷阱
                        { "AddActiveCastSkill", 14, 
                            {
                                --先警示2秒
                                { 2*15, {
                                        {3160, 1, 21769,12082},
                                        },
                                }, 
                                --第1次毒雾
                                { 4*15, {
                                        {3185, 1, 21769,12082},
                                        },
                                }, 

                                --先警示2秒
                                { 2*15, {
                                        {3160, 1, 21769,12082},
                                        },
                                }, 
                                --第2次毒雾
                                { 4*15, {
                                        {3185, 1, 21769,12082},
                                        },
                                }, 

                                --先警示2秒
                                { 2*15, {
                                        {3160, 1, 21769,12082},
                                        },
                                }, 
                                --第3次毒雾
                                { 70*15,{
                                        {3185, 1, 21769,12082},
                                        },
                                }, 
                            }, 
                        };

                        --4-5房间陷阱
                        { "AddActiveCastSkill", 15, 
                            {
                                --先警示2秒
                                { 2*15, {
                                        {3160, 1, 22131,7366},
                                        },
                                }, 

                                --第1次毒雾
                                { 4*15, {
                                        {3185, 1, 22131,7366},
                                        },
                                }, 

                                --先警示2秒
                                { 2*15, {
                                        {3160, 1, 22131,7366},
                                        },
                                }, 

                                --第2次毒雾
                                { 4*15, {
                                        {3185, 1, 22131,7366},
                                        },
                                }, 

                                --先警示2秒
                                { 2*15, {
                                        {3160, 1, 22131,7366},
                                        },
                                }, 

                                --第3次毒雾
                                { 70*15, {
                                          {3185, 1, 22131,7366},
                                       },
                                }, 
                            }, 
                        };

                        --指定位置添加沿路径行走的npc 
                        --1-3房间陷阱
                        {"AddAutoHideWalkPathNpc", 10, 2117, 80, "1_3_skill_A_1", 14*15, 70*15 }; --房间号，npcId，等级 ,路径 ,存活帧，增加间隔帧(从删除后算)
                        {"AddAutoHideWalkPathNpc", 10, 2117, 80, "1_3_skill_A_2", 14*15, 70*15 };
                        {"AddAutoHideWalkPathNpc", 10, 2117, 80, "1_3_skill_A_3", 14*15, 70*15 };
                        {"AddAutoHideWalkPathNpc", 10, 2117, 80, "1_3_skill_A_4", 14*15, 70*15 };
                        {"AddAutoHideWalkPathNpc", 10, 2117, 80, "1_3_skill_A_5", 14*15, 70*15 };
 
                        --1-4房间陷阱
                        {"AddAutoHideWalkPathNpc", 11, 2117, 80, "1_4_skill_A_1", 14*15, 70*15 }; 
                        {"AddAutoHideWalkPathNpc", 11, 2117, 80, "1_4_skill_A_2", 14*15, 70*15 };
                        {"AddAutoHideWalkPathNpc", 11, 2117, 80, "1_4_skill_A_3", 14*15, 70*15 };
                        {"AddAutoHideWalkPathNpc", 11, 2117, 80, "1_4_skill_A_4", 14*15, 70*15 };
                        {"AddAutoHideWalkPathNpc", 11, 2117, 80, "1_4_skill_A_5", 14*15, 70*15 };

                        --1-5房间陷阱
                        {"AddAutoHideWalkPathNpc", 12, 2117, 80, "1_5_skill_A_1", 14*15, 70*15 }; 
                        {"AddAutoHideWalkPathNpc", 12, 2117, 80, "1_5_skill_A_2", 14*15, 70*15 };
                        {"AddAutoHideWalkPathNpc", 12, 2117, 80, "1_5_skill_A_3", 14*15, 70*15 };
                        {"AddAutoHideWalkPathNpc", 12, 2117, 80, "1_5_skill_A_4", 14*15, 70*15 };
                        {"AddAutoHideWalkPathNpc", 12, 2117, 80, "1_5_skill_A_5", 14*15, 70*15 };

                        --2-2房间陷阱
                        { "AddActiveCastSkill", 9,
                            {
                                { 4*15, {                       
                                        {3170, 1, 7446,16050},
                                        },
                                }, 
                                { 4*15, {                       
                                        {3170, 1, 7446,16050},
                                        },
                                }, 
                                { 70*15,   {
                                        {3170, 1, 7446,16050},
                                        },
                                }, 
                            }, 
                        };

                        --2-3房间陷阱
                        { "AddActiveCastSkill", 2, 
                            {
                                { 4*15, {                       
                                        {3172, 1, 12009,16068},
                                        },
                                }, 
                                { 4*15, {                       
                                        {3172, 1, 12009,16068},
                                        },
                                }, 
                                { 70*15,   {
                                        {3172, 1, 12009,16068},
                                        },
                                }, 
                            }, 
                        };

                        --2-4房间陷阱
                        { "AddActiveCastSkill", 3, 
                            {
                                { 4*15, {                       
                                        {3174, 1, 16905,16080},
                                        },
                                }, 
                                { 4*15, {                       
                                        {3174, 1, 16905,16080},
                                        },
                                }, 
                                { 70*15,  {
                                        {3174, 1, 16905,16080},
                                        },
                                }, 
                            }, 
                        };

                        --3-2房间陷阱
                        { "AddActiveCastSkill", 8, 
                            {
                                { 4*15, {                       
                                        {3176, 1, 7382,11998},
                                        },
                                }, 
                                { 4*15, {                       
                                        {3176, 1, 7382,11998},
                                        },
                                }, 
                                { 70*15,  {
                                        {3176, 1, 7382,11998},
                                        },
                                }, 
                            }, 
                        };

                        --3-4房间陷阱
                        { "AddActiveCastSkill", 4, 
                            {
                                { 4*15, {                       
                                        {3178, 1, 17185,11881},
                                        },
                                }, 
                                { 4*15, {                       
                                        {3178, 1, 17185,11881},
                                        },
                                }, 
                                { 70*15,  {
                                        {3178, 1, 17185,11881},
                                        },
                                }, 
                            }, 
                        };

                        --4-1房间陷阱
                        { "AddActiveCastSkill", 21, 
                            {
                                --先警示2秒
                                { 2*15, {
                                        {3160, 1, 3036,8081},
                                        },
                                }, 
                                --第1次刀光
                                { 4*15, {
                                        {3187, 1, 3036,8081},
                                        },
                                }, 

                                --先警示2秒
                                { 2*15, {
                                        {3160, 1, 3036,8081},
                                        },
                                }, 
                                --第2次刀光
                                { 4*15, {
                                        {3187, 1, 3036,8081},
                                        },
                                }, 

                                --先警示2秒
                                { 2*15, {
                                        {3160, 1, 3036,8081},
                                        },
                                }, 
                                --第3次刀光
                                { 70*15,{
                                        {3187, 1, 3036,8081},
                                        },
                                }, 
                            }, 
                        };

                        --4-2房间陷阱
                        { "AddActiveCastSkill", 7, 
                            {
                                { 4*15, {                       
                                        {3170, 1, 7358,7546},
                                        },
                                }, 
                                { 4*15, {                       
                                        {3170, 1, 7358,7546},
                                        },
                                }, 
                                { 70*15,  {
                                        {3170, 1, 7358,7546},
                                        },
                                }, 
                            }, 
                        };

                        --4-3房间陷阱
                        { "AddActiveCastSkill", 6, 
                            {
                                { 4*15, {                       
                                        {3176, 1, 12023,7407},
                                        },
                                }, 
                                { 4*15, {                       
                                        {3176, 1, 12023,7407},
                                        },
                                }, 
                                { 70*15,{
                                        {3176, 1, 12023,7407},
                                        },
                                }, 
                            }, 
                        };

                        --4-4房间陷阱
                        { "AddActiveCastSkill", 5, 
                            {
                                { 4*15, {                       
                                        {3174, 1, 16932,7415},
                                        },
                                }, 
                                { 4*15, {                       
                                        {3174, 1, 16932,7415},
                                        },
                                }, 
                                { 70*15,  {
                                        {3174, 1, 16932,7415},
                                        },
                                }, 
                            }, 
                        };

                        --5-1房间陷阱
                        { "AddActiveCastSkill", 20, 
                            {
                                --先警示2秒
                                { 2*15, {
                                        {3160, 1, 3053,4009},
                                        },
                                }, 
                                --第1次刀光
                                { 4*15, {
                                        {3187, 1, 3053,4009},
                                        },
                                }, 

                                --先警示2秒
                                { 2*15, {
                                        {3160, 1, 3053,4009},
                                        },
                                }, 
                                --第2次刀光
                                { 4*15, {
                                        {3187, 1, 3053,4009},
                                        },
                                }, 

                                --先警示2秒
                                { 2*15, {
                                        {3160, 1, 3053,4009},
                                        },
                                }, 
                                --第3次刀光
                                { 70*15,{
                                        {3187, 1, 3053,4009},
                                        },
                                }, 
                            }, 
                        };

                        --5-2房间陷阱
                        { "AddActiveCastSkill", 19, --执行函数，房间号
                            {
                                --第一排落雷
                                { 2*15, {                       --多少帧执行下一个
                                        {3157, 1, 7300,3298},  --技能ID，技能等级，技能释放坐标
                                        {3157, 1, 6726,3319}, 
                                        {3157, 1, 7885,3319},

                                        {3160, 1, 7300,3298},
                                        {3160, 1, 6726,3319},
                                        {3160, 1, 7885,3319},
                                        },
                                }, 
                                --第二排落雷
                                { 2*15, {
                                        {3157, 1, 6466,2963}, 
                                        {3157, 1, 6983,2958}, 
                                        {3157, 1, 7502,2958},
                                        {3157, 1, 8011,2974},

                                        {3160, 1, 6466,2963},
                                        {3160, 1, 6983,2958},
                                        {3160, 1, 7502,2958},
                                        {3160, 1, 8011,2974},
                                        },
                                }, 
                                --第三排落雷
                                { 2*15, {
                                        {3157, 1, 6187,2588},
                                        {3157, 1, 6726,2578},
                                        {3157, 1, 7280,2575},
                                        {3157, 1, 7837,2588},

                                        {3160, 1, 6187,2588},
                                        {3160, 1, 6726,2578},
                                        {3160, 1, 7280,2575},
                                        {3160, 1, 7837,2588},
                                        },
                                }, 
                                --第四排落雷
                                { 2*15, {
                                        {3157, 1, 7743,2163}, 
                                        {3157, 1, 6436,2141}, 
                                        {3157, 1, 7039,2141},

                                        {3160, 1, 7743,2163}, 
                                        {3160, 1, 6436,2141}, 
                                        {3160, 1, 7039,2141},
                                        },
                                }, 

                                -------------
                                 --第一排落雷
                                { 2*15, {
                                        {3157, 1, 7300,3298},
                                        {3157, 1, 6726,3319}, 
                                        {3157, 1, 7885,3319},

                                        {3160, 1, 7300,3298},
                                        {3160, 1, 6726,3319},
                                        {3160, 1, 7885,3319},
                                        },
                                }, 
                                --第二排落雷
                                { 2*15, {
                                        {3157, 1, 6466,2963}, 
                                        {3157, 1, 6983,2958}, 
                                        {3157, 1, 7502,2958},
                                        {3157, 1, 8011,2974},

                                        {3160, 1, 6466,2963},
                                        {3160, 1, 6983,2958},
                                        {3160, 1, 7502,2958},
                                        {3160, 1, 8011,2974},
                                        },
                                }, 
                                --第三排落雷
                                { 2*15, {
                                        {3157, 1, 6187,2588},
                                        {3157, 1, 6726,2578},
                                        {3157, 1, 7280,2575},
                                        {3157, 1, 7837,2588},

                                        {3160, 1, 6187,2588},
                                        {3160, 1, 6726,2578},
                                        {3160, 1, 7280,2575},
                                        {3160, 1, 7837,2588},
                                        },
                                }, 
                                --第四排落雷
                                { 70*15,   {
                                        {3157, 1, 7743,2163}, 
                                        {3157, 1, 6436,2141}, 
                                        {3157, 1, 7039,2141},

                                        {3160, 1, 7743,2163}, 
                                        {3160, 1, 6436,2141}, 
                                        {3160, 1, 7039,2141},
                                        },
                                }, 
                            }, 
                        };

                        --5-3房间陷阱
                        { "AddActiveCastSkill", 18, 
                            {
                                { 15,   {--1
                                        --1号雷，第1次
                                        {3157, 1, 11710,2258},
                                        {3160, 1, 11710,2258},
                                        },
                                },
                                { 15,   {--2
                                        --2号雷，第1次
                                        {3157, 1, 12010,3350},
                                        {3160, 1, 12010,3350},
                                        },
                                },
                                { 15,   {--3
                                        --1号雷，第2次
                                        {3157, 1, 11710,2258},
                                        {3160, 1, 11710,2258},
                                        --3号雷，第1次
                                        {3157, 1, 12932,2778},
                                        {3160, 1, 12932,2778},
                                        },
                                },
                                { 15,   {--4
                                        --2号雷，第2次
                                        {3157, 1, 12010,3350},
                                        {3160, 1, 12010,3350},
                                        --4号雷，第1次
                                        {3157, 1, 11649,2844},
                                        {3160, 1, 11649,2844},
                                        },
                                },
                                { 15,   {--5
                                        --1号雷，第3次
                                        {3157, 1, 11710,2258},
                                        {3160, 1, 11710,2258},
                                        --3号雷，第2次
                                        {3157, 1, 12932,2778},
                                        {3160, 1, 12932,2778},
                                        --5号雷，第1次
                                        {3157, 1, 12814,2237},
                                        {3160, 1, 12814,2237},
                                        },
                                },
                                { 15,   {--6
                                        --2号雷，第3次
                                        {3157, 1, 12010,3350},
                                        {3160, 1, 12010,3350},
                                        --4号雷，第2次
                                        {3157, 1, 11649,2844},
                                        {3160, 1, 11649,2844},
                                        --6号雷，第1次
                                        {3157, 1, 12834,3295},
                                        {3160, 1, 12834,3295},
                                        },
                                },
                                { 15,   {--7
                                        --3号雷，第3次
                                        {3157, 1, 12932,2778},
                                        {3160, 1, 12932,2778},
                                        --5号雷，第2次
                                        {3157, 1, 12814,2237},
                                        {3160, 1, 12814,2237},
                                        --7号雷，第1次
                                        {3157, 1, 12275,2427},
                                        {3160, 1, 12275,2427},
                                        },
                                },
                                { 15,   {--8
                                        --4号雷，第3次
                                        {3157, 1, 11649,2844},
                                        {3160, 1, 11649,2844},
                                        --6号雷，第2次
                                        {3157, 1, 12834,3295},
                                        {3160, 1, 12834,3295},
                                        --8号雷，第1次
                                        {3157, 1, 12382,3000},
                                        {3160, 1, 12382,3000},
                                        },
                                },
                                { 15,  {--9
                                        --5号雷，第3次
                                        {3157, 1, 12814,2237},
                                        {3160, 1, 12814,2237},
                                        --7号雷，第2次
                                        {3157, 1, 12275,2427},
                                        {3160, 1, 12275,2427},
                                        },
                                },
                                { 15,   {--10
                                        --6号雷，第3次
                                        {3157, 1, 12834,3295},
                                        {3160, 1, 12834,3295},
                                        --8号雷，第2次
                                        {3157, 1, 12382,3000},
                                        {3160, 1, 12382,3000},
                                        },
                                },
                                { 15,   {--11
                                        --7号雷，第3次
                                        {3157, 1, 12275,2427},
                                        {3160, 1, 12275,2427},
                                        },
                                },
                                { 70*15,   {--12
                                        --8号雷，第3次
                                        {3157, 1, 12382,3000},
                                        {3160, 1, 12382,3000},
                                        },
                                },

                            }, 
                        };


                        --5-4房间陷阱
                        { "AddActiveCastSkill", 17, 
                            {
                                --第1次落雷
                                { 2*15, {
                                        {3157, 1, 17859,2223},
                                        {3157, 1, 16864,2245}, 
                                        {3157, 1, 16867,3168},
                                        {3157, 1, 17875,3159},

                                        {3160, 1, 17859,2223},
                                        {3160, 1, 16864,2245}, 
                                        {3160, 1, 16867,3168},
                                        {3160, 1, 17875,3159},
                                        },
                                }, 

                                --第2次落雷
                                { 2*15, {

                                        {3157, 1, 17368,3161},
                                        {3157, 1, 17368,2157}, 
                                        {3157, 1, 17368,2635},

                                        {3160, 1, 17368,3161},
                                        {3160, 1, 17368,2157}, 
                                        {3160, 1, 17368,2635},
                                        },
                                }, 

                                --第3次落雷
                                { 2*15, {
                                        {3157, 1, 16833,2692},
                                        {3157, 1, 17381,2688}, 
                                        {3157, 1, 17881,2670},

                                        {3160, 1, 16833,2692},
                                        {3160, 1, 17381,2688}, 
                                        {3160, 1, 17881,2670},
                                        },
                                }, 

                                --第1次落雷
                                { 2*15, {
                                        {3157, 1, 17859,2223},
                                        {3157, 1, 16864,2245}, 
                                        {3157, 1, 16867,3168},
                                        {3157, 1, 17875,3159},

                                        {3160, 1, 17859,2223},
                                        {3160, 1, 16864,2245}, 
                                        {3160, 1, 16867,3168},
                                        {3160, 1, 17875,3159},
                                        },
                                }, 

                                --第2次落雷
                                { 2*15, {

                                        {3157, 1, 17368,3161},
                                        {3157, 1, 17368,2157}, 
                                        {3157, 1, 17368,2635},

                                        {3160, 1, 17368,3161},
                                        {3160, 1, 17368,2157}, 
                                        {3160, 1, 17368,2635},
                                        },
                                }, 

                                --第3次落雷
                                { 70*15,   {
                                        {3157, 1, 16833,2692},
                                        {3157, 1, 17381,2688}, 
                                        {3157, 1, 17881,2670},

                                        {3160, 1, 16833,2692},
                                        {3160, 1, 17381,2688}, 
                                        {3160, 1, 17881,2670},
                                        },
                                }, 
                            }, 
                        };

                        --5-5房间陷阱
                        { "AddActiveCastSkill", 16, 
                            {
                                --先警示2秒
                                { 2*15, {
                                        {3160, 1, 22307,2681},
                                        },
                                }, 
                                --第1次刀光
                                { 4*15, {
                                        {3187, 1, 22307,2681},
                                        },
                                }, 

                                --先警示2秒
                                { 2*15, {
                                        {3160, 1, 22307,2681},
                                        },
                                }, 
                                --第2次刀光
                                { 4*15, {
                                        {3187, 1, 22307,2681},
                                        },
                                }, 

                                --先警示2秒
                                { 2*15, {
                                        {3160, 1, 22307,2681},
                                        },
                                }, 
                                --第3次刀光
                                { 70*15,{
                                        {3187, 1, 22307,2681},
                                        },
                                }, 
                            }, 
                        };
 
                    };


            [2*60] = {
                        --同步一下客户端时间
                        { "SynGameTime",};
                     };

            [3*60] = {
                        --同步一下客户端时间
                        { "SynGameTime",};

                        --第一阶段3分钟刷出：幻兽·寒玉鹿王、幻兽·大地狼王、幻兽·白眉猴王
                        {"OnWorldNotify", "幻境中出現了心魔幻獸、心魔幻象（可通過地圖查看出現區域）"};
                        {"OnAddSingleRoomNpc", 2102, 3*60}; 
                        {"OnAddSingleRoomNpc", 2103, 3*60}; 
                        {"OnAddSingleRoomNpc", 2104, 3*60}; 

                        --第一阶段3分钟刷出：幻象*3
                        {"OnAddSingleRoomNpc", 2101, 3*60}; 
                        {"OnAddSingleRoomNpc", 2101, 3*60}; 
                        {"OnAddSingleRoomNpc", 2101, 3*60}; 
                    };
            [5*60+50] = {
                        --最后1分钟提前10秒同步一下时间
                        { "SynGameTime",};
                     };
        };

        [3] =
        {
             --第一个休息阶段的第30s执行的函数
            [60] = { 
                        { "ReadyCloseRoom",  "", "tbRandomCloseRoomState1"};  --关最外层8个房间
                        { "SynGameTime",};
                    }; 

            [80] = {
                        --休息阶段剩余10秒时同步一下时间
                        { "SynGameTime",};
                     };
        };

        --第二个战斗阶段
        [4] =
        {
            [10]   = {
                        --同步一下客户端时间
                        { "SynGameTime",};

                        --第二阶段10秒刷出：商人*2
                        {"OnWorldNotify", "神秘商人現身幻境，據說專賣一些幻境中特有之物（可通過地圖查看出現區域）"};
                        {"OnAddSingleRoomNpc", 1987, 50 + 5*60 + 90};
                        {"OnAddSingleRoomNpc", 1987, 50 + 5*60 + 90};
                     };

            [2*60] = {
                        --同步一下客户端时间
                        { "SynGameTime",};
                     };

            [3*60] = {
                        --同步一下客户端时间
                        { "SynGameTime",};

                        --第二阶段3分钟刷出：幻兽·奔焰豹王、幻兽·九尾狐王、幻兽·双首异兽
                        {"OnWorldNotify", "幻境中出現了心魔幻獸、心魔幻象（可通過地圖查看出現區域）"};
                        {"OnAddSingleRoomNpc", 2105, 3*60}; 
                        {"OnAddSingleRoomNpc", 2106, 3*60}; 
                        {"OnAddSingleRoomNpc", 2107, 3*60}; 

                        --第二阶段3分钟刷出：幻兽·紫背鳄皇（BOSS)
                        {"OnAddSingleRoomNpc", 2111, 3*60}; 

                        --第二阶段3分钟刷出：幻象*3
                        {"OnAddSingleRoomNpc", 2101, 3*60}; 
                        {"OnAddSingleRoomNpc", 2101, 3*60}; 
                        {"OnAddSingleRoomNpc", 2101, 3*60}; 
                    };

            [5*60+50] = {
                        --最后1分钟提前10秒同步一下时间
                        { "SynGameTime",};
                     };
        };

        [5] = 
        {
            [60] = { 
                        { "ReadyCloseRoom",  "tbRoomIndex1",};  --关最外层全部房间
                        { "SynGameTime",};
                    }; 

            [80] = {
                        --休息阶段剩余10秒时同步一下时间
                        { "SynGameTime",};
                     };
        };

        --第三个战斗阶段
        [6] =
        {
            [10]   = {
                        --同步一下客户端时间
                        { "SynGameTime",};

                        --第三阶段10秒刷出：商人*2
                        {"OnWorldNotify", "神秘商人現身幻境，據說專賣一些幻境中特有之物（可通過地圖查看出現區域）"};
                        {"OnAddSingleRoomNpc", 1987, 50 + 5*60 + 90};
                        {"OnAddSingleRoomNpc", 1987, 50 + 5*60 + 90};
                     };

            [2*60] = {
                        --同步一下客户端时间
                        { "SynGameTime",};
                     };

            [3*60] = {
                        --同步一下客户端时间
                        { "SynGameTime",};
                        
                        --第三阶段3分钟刷出：幻兽·定海金刚、幻兽·金翅鹏皇、幻兽·银角犀皇
                        {"OnWorldNotify", "幻境中出現了心魔幻獸、心魔幻象（可通過地圖查看出現區域）"};
                        {"OnAddSingleRoomNpc", 2108, 3*60}; 
                        {"OnAddSingleRoomNpc", 2109, 3*60}; 
                        {"OnAddSingleRoomNpc", 2110, 3*60}; 

                        --第三阶段3分钟刷出：幻兽·撼天熊皇（BOSS)
                        {"OnAddSingleRoomNpc", 2112, 3*60}; 

                        --第三阶段3分钟刷出：幻象*3
                        {"OnAddSingleRoomNpc", 2101, 3*60}; 
                        {"OnAddSingleRoomNpc", 2101, 3*60}; 
                        {"OnAddSingleRoomNpc", 2101, 3*60}; 
                    };

            [5*60+50] = {
                        --最后1分钟提前10秒同步一下时间
                        { "SynGameTime",};
                     };
        };

        [7] = 
        {
            [60] = { 
                        { "ReadyCloseRoom",  "tbRoomIndex2",};  --关最外层全部房间
                        { "SynGameTime",};
                   }; 

            [80] = {
                        --休息阶段剩余10秒时同步一下时间
                        { "SynGameTime",};
                     };
        };

        [8] = 
        {
            [1] = { 
                        { "SynGameTime",};

                        {"AddRandPosBuffSet", "1000|30;1001|15;1002|15;1003|15;1004|15;1005|10;1", 1, {"last_buff_1", "last_buff_2", "last_buff_3", "last_buff_4"}, {1,1} };--点集里刷随机buff，buff，房间号，点集，随机个数--TODO 配置检查
                   }; 

            [61] = { 
                        { "SynGameTime",};

                        {"AddRandPosBuffSet", "1000|30;1001|15;1002|15;1003|15;1004|15;1005|10;1", 1, {"last_buff_1", "last_buff_2", "last_buff_3", "last_buff_4"}, {1,1} };
                   }; 

            [121] = { 
                        { "SynGameTime",};

                        {"AddRandPosBuffSet", "1000|30;1001|15;1002|15;1003|15;1004|15;1005|10;1", 1, {"last_buff_1", "last_buff_2", "last_buff_3", "last_buff_4"}, {1,1} };
                   }; 

            [181] = { 
                        { "SynGameTime",};

                        {"AddRandPosBuffSet", "1000|30;1001|15;1002|15;1003|15;1004|15;1005|10;1", 1, {"last_buff_1", "last_buff_2", "last_buff_3", "last_buff_4"}, {1,1} };
                   }; 
        };
    };

    --客户端指定阶段时间会执行的函数 这里是剩余时间， 上面的是逝去时间区分下！！
    -- 由于卡帧和同步原因是有可能错过的，放不重要的客户端检测函数
    tbActiveTransClient = {
        [3] = {  
            [30] = { szFunc = "CheckNotSafeRoom",        tbParam = {  }  }; 
            [20] = { szFunc = "CheckNotSafeRoom",        tbParam = {  }  }; 
            [10] = { szFunc = "CheckNotSafeRoom",        tbParam = {  }  }; 
            [2] =  { szFunc = "ShowRoomCloseEffect", tbParam = {  }  }; 
        };
        [5] = 
        {
            [30] = { szFunc = "CheckNotSafeRoom",        tbParam = {  }  }; 
            [20] = { szFunc = "CheckNotSafeRoom", tbParam = {  }  }; 
            [10] = { szFunc = "CheckNotSafeRoom", tbParam = {  }  }; 
            [2] =  { szFunc = "ShowRoomCloseEffect", tbParam = {  }  }; 
        };
        [7] = 
        {
            [30] = { szFunc = "CheckNotSafeRoom",        tbParam = { }  }; 
            [20] = { szFunc = "CheckNotSafeRoom", tbParam = {  }  }; 
            [10] = { szFunc = "CheckNotSafeRoom", tbParam = {  }  }; 
            [2] =  { szFunc = "ShowRoomCloseEffect", tbParam = {  }  }; 
        };
    };

    --宝箱，幻象，boss，首领的掉落表
    tbDrapList = {
        --阶段1的普通宝箱奖励
        tbBoxAward_1 = {
            { 0.625, {"RandItemCount", 3299, 2,4  } }; --随机水晶
            { 0.025, {"item", 2400, 1} };  --乌云踏雪
            { 0.075, {"SkillBook", 0} }; --随机门派秘籍
            { 0.025, {"item", 1391, 1} };  --1级附魔石
            { 0.25,  {"RandMoney", 15, 25} }; --随机的勾玉
        };

        --阶段2的普通宝箱奖励
        tbBoxAward_2 = {
            { 0.71,   {"RandItemCount", 3299, 4,8  } }; --随机水晶
            { 0.015,  {"item", 2400, 1} }; --乌云踏雪
            { 0.0075, {"item", 3307, 1} };
            { 0.05,   {"SkillBook", 0}  }; --随机门派秘籍
            { 0.025,  {"item", 3308, 1} };
            { 0.015,  {"item", 1391, 1} };  --1级附魔石
            { 0.0075, {"item", 1392, 1} };  --2级附魔石
            { 0.17,   {"RandMoney", 20, 40} }; --随机的勾玉
        };

        --阶段3的普通宝箱奖励
        tbBoxAward_3 = {

            { 0.625, {"RandItemCount", 3299, 8,16  } }; --随机水晶
            { 0.025, {"item", 3307, 1} };
            { 0.075, {"item", 3308, 1} };
            { 0.025, {"item", 1392, 1} };  --2级附魔石
            { 0.25,  {"RandMoney", 30, 60} }; --随机的勾玉
        };

        --阶段1的首领掉落奖励
        tbLeaderAward_1 = {
            { 0.6,  {"RandItemCount", 3299, 2,4  } }; --随机水晶
            { 0.02, {"item", 2400, 1} }; --乌云踏雪
            { 0.06, {"SkillBook", 0}  }; --随机门派秘籍
            { 0.02, {"item", 1391, 1} };  --1级附魔石
            { 0.3,  {"RandMoney", 15, 25} }; --随机的勾玉
        };

        --阶段2的首领掉落奖励
        tbLeaderAward_2 = {
            { 0.592, {"RandItemCount", 3299, 4,8  } }; --随机水晶
            { 0.016, {"item", 2400, 1} }; --乌云踏雪
            { 0.008, {"item", 3307, 1} };
            { 0.04,  {"SkillBook", 0}  }; --随机门派秘籍
            { 0.02,  {"item", 3308, 1} };
            { 0.016, {"item", 1391, 1} };  --1级附魔石
            { 0.008, {"item", 1392, 1} };  --2级附魔石
            { 0.3,   {"RandMoney", 20, 40} }; --随机的勾玉
        };

        --阶段3的首领掉落奖励
        tbLeaderAward_3 = {
            { 0.6,  {"RandItemCount", 3299, 8,12  } }; --随机水晶
            { 0.02, {"item", 3307, 1} };
            { 0.06, {"item", 3308, 1} };
            { 0.02, {"item", 1392, 1} };  --2级附魔石
            { 0.3,  {"RandMoney", 40, 80} }; --随机的勾玉
        };

        --阶段1的幻象奖励
        tbSuperBoxAward_1 = {
            { 0.6,  {"RandItemCount", 3299, 2,4  } }; --随机水晶
            { 0.02, {"item", 2400, 1} }; --乌云踏雪
            { 0.06, {"SkillBook", 0}  }; --随机门派秘籍
            { 0.02, {"item", 1391, 1} };  --1级附魔石
            { 0.3,  {"RandMoney", 15, 25} }; --随机的勾玉
        };

        --阶段2的幻象奖励
        tbSuperBoxAward_2 = {
            { 0.592, {"RandItemCount", 3299, 4,8  } }; --随机水晶
            { 0.016, {"item", 2400, 1} }; --乌云踏雪
            { 0.008, {"item", 3307, 1} };
            { 0.04,  {"SkillBook", 0}  }; --随机门派秘籍
            { 0.02,  {"item", 3308, 1} };
            { 0.016, {"item", 1391, 1} };  --1级附魔石
            { 0.008, {"item", 1392, 1} };  --2级附魔石
            { 0.3,   {"RandMoney", 20, 40} }; --随机的勾玉
        };

        --阶段3的幻象奖励
        tbSuperBoxAward_3 = {
            { 0.6,  {"RandItemCount", 3299, 8,12  } }; --随机水晶
            { 0.02, {"item", 3307, 1} };
            { 0.06, {"item", 3308, 1} };
            { 0.02, {"item", 1392, 1} };  --2级附魔石
            { 0.3,  {"RandMoney", 40, 80} }; --随机的勾玉
        };

        --阶段2的Boss奖励
        tbBossAward_2 = {
            { 0.6,   {"RandItemCount", 3299, 4,8  } }; --随机水晶
            { 0.016, {"item", 2400, 1} }; --乌云踏雪
            { 0.008, {"item", 3307, 1} };
            { 0.04,  {"SkillBook", 0}  }; --随机门派秘籍
            { 0.02,  {"item", 3308, 1} };
            { 0.016, {"item", 1391, 1} };  --1级附魔石
            { 0.008, {"item", 1392, 1} };  --2级附魔石
            { 0.292, {"RandMoney", 30, 50} }; --随机的勾玉
        };

        --阶段3的Boss奖励
        tbBossAward_3 = {
            { 0.6,  {"RandItemCount", 3299, 8,16  } }; --随机水晶
            { 0.02, {"item", 3307, 1} };
            { 0.06, {"item", 3308, 1} };
            { 0.02, {"item", 1392, 1} };  --2级附魔石
            { 0.3,  {"RandMoney", 40, 80} }; --随机的勾玉
        };
    };
}

local tbDefine = InDifferBattle.tbDefine
    
InDifferBattle.tbRoomSetting = {
    --- 时间约定， {30 (从第二阶段开始往后的时间, -1随机时间),  40（存活时间, 0则不会自动删除）  } --有重生时间的就不应该有存活时间， 不能填nil,不然unpack 时蛋疼
    --指定某些房间刷新的且每个房间最多只有一个在该group的npc,可多个npc用同个group
    tbSignleRooms = {
        {1},  --3层
        {2,3,4,5,6,7,8,9},  --2层
    };
    tbSingleRoomNpc = {

        --第一、二、三阶段3分钟刷出：商人 * 2
        [1987] = {
                    nLevel = 1;  --npc等级
                    nDir = 48,
                    szName = "商人",
                    nRoomGroup = 2,   --房间组
                    szIcon = "DreamlandIcon1",  
                }; 

        --第一、二、三阶段3分钟刷出：幻象 * 3
        [2101] = {
                    nLevel = 1;  --npc等级
                    nDir = 48,
                    szName = "幻象",
                    nRoomGroup = 2,   --房间组
                    szIcon = "DreamlandIcon4",  
                }; 

        --第一阶段3分钟刷出：幻兽·寒玉鹿王
        [2102] = {
                    nLevel = 80;  --npc等级
                    szName = "組長",
                    nRoomGroup = 2,   --房间组
                    szIcon = "DreamlandIcon2",  
                    szDropAwardList = { --有这个掉落表的进房间才会显示伤害输出
                                         [2] = "tbLeaderAward_1"; --不同阶段对应的掉落表
                                      }; 
                    tbRankAwardNum = { 8, 5, 3 }; --排名一到3分别获得的奖励次数 
                }; 

        --第一阶段3分钟刷出：幻兽·大地狼王
        [2103] = {
                    nLevel = 80;
                    szName = "組長",
                    nRoomGroup = 2,
                    szIcon = "DreamlandIcon2",  
                    szDropAwardList = {
                                         [2] = "tbLeaderAward_1";
                                      }; 
                    tbRankAwardNum = { 8, 5, 3 };
                }; 

        --第一阶段3分钟刷出：幻兽·白眉猴王
        [2104] = {
                    nLevel = 80;
                    szName = "組長",
                    nRoomGroup = 2,
                    szIcon = "DreamlandIcon2",  
                    szDropAwardList = {
                                         [2] = "tbLeaderAward_1";
                                      }; 
                    tbRankAwardNum = { 8, 5, 3 };
                }; 

        --第二阶段3分钟刷出：幻兽·奔焰豹王
        [2105] = {
                    nLevel = 80;
                    szName = "組長",
                    nRoomGroup = 2,
                    szIcon = "DreamlandIcon2",  
                    szDropAwardList = {
                                         [4] = "tbLeaderAward_2";
                                      }; 
                    tbRankAwardNum = { 8, 5, 3 };
                }; 

        --第二阶段3分钟刷出：幻兽·九尾狐王
        [2106] = {
                    nLevel = 80;
                    szName = "組長",
                    nRoomGroup = 2,
                    szIcon = "DreamlandIcon2",  
                    szDropAwardList = {
                                         [4] = "tbLeaderAward_2";
                                      }; 
                    tbRankAwardNum = { 8, 5, 3 };
                }; 

        --第二阶段3分钟刷出：幻兽·双首异兽
        [2107] = {
                    nLevel = 80;
                    szName = "組長",
                    nRoomGroup = 2,
                    szIcon = "DreamlandIcon2",  
                    szDropAwardList = {
                                         [4] = "tbLeaderAward_2";
                                      }; 
                    tbRankAwardNum = { 8, 5, 3 };
                }; 

        --第二阶段3分钟刷出：幻兽·紫背鳄皇（BOSS)
        [2111] = {
                    nLevel = 80;
                    szName = "首領",
                    nRoomGroup = 1,
                    szIcon = "DreamlandIcon3",  
                    bBoss = true; --是BOss 有*排名第1的队伍所有成员获得随机Buff 和 获得复活石的机制
                    szDropAwardList = {
                                         [4] = "tbBossAward_2";
                                      }; 
                    tbRankAwardNum = { 18, 12, 8, 6, 4 };
                }; 

        --第三阶段3分钟刷出：幻兽·定海金刚
        [2108] = {
                    nLevel = 80;
                    szName = "組長",
                    nRoomGroup = 2,
                    szIcon = "DreamlandIcon2",  
                    szDropAwardList = {
                                         [6] = "tbLeaderAward_3";
                                      }; 
                    tbRankAwardNum = { 8, 5, 3 };
                }; 

        --第三阶段3分钟刷出：幻兽·金翅鹏皇
        [2109] = {
                    nLevel = 80;
                    szName = "組長",
                    nRoomGroup = 2,
                    szIcon = "DreamlandIcon2",  
                    szDropAwardList = {
                                         [6] = "tbLeaderAward_3";
                                      }; 
                    tbRankAwardNum = { 8, 5, 3 };
                }; 

        --第三阶段3分钟刷出：幻兽·银角犀皇
        [2110] = {
                    nLevel = 80;
                    szName = "組長",
                    nRoomGroup = 2,
                    szIcon = "DreamlandIcon2",  
                    szDropAwardList = {
                                         [6] = "tbLeaderAward_3";
                                      }; 
                    tbRankAwardNum = { 8, 5, 3 };
                }; 

        --第三阶段3分钟刷出：幻兽·撼天熊皇（BOSS)
        [2112] = {
                    nLevel = 80;
                    szName = "首領",
                    nRoomGroup = 1,
                    szIcon = "DreamlandIcon3",  
                    bBoss = true; --是BOss 有*排名第1的队伍所有成员获得随机Buff 和 获得复活石的机制
                    szDropAwardList = {
                                         [6] = "tbBossAward_3";
                                      }; 
                    tbRankAwardNum = { 18, 12, 8, 6, 4 };
                }; 
               
    } ;

    --第一次关闭房间时的随机情况 , 防止有角落被锁死就使用配置形式
    tbRandomCloseRoomState1 = {
        {24,25,11,12,14,16,18,22};
        {24,25,12,14,16,19,22,23};
        {10,11,12,13,14,17,21,23};
        {25,10,12,14,17,20,21,22};
        {10,12,14,15,18,21,22,23};
        {25,12,14,15,16,19,20,21};
        {24,11,12,14,17,19,22,23};
        {10,12,14,15,16,19,20,21};
        {24,25,11,12,14,15,18,19};
        {24,25,10,11,12,13,18,17};
        {12,13,14,15,18,20,21,23};
        {10,11,12,17,18,19,22,23};
        {13,14,15,16,18,21,22,23};
        {24,11,15,16,17,18,22,23};
    };
}




--房间的trap传送点位置 每个房间的trap 名就是 

local tbDefine = InDifferBattle.tbDefine;


function InDifferBattle:CanSignUp(pPlayer, szBattleType)
    if MODULE_GAMESERVER then
        if not Env:CheckSystemSwitch(pPlayer, Env.SW_SwitchMap) then
            return false, "目前狀態不允許切換地圖"
        end
    end
    if szBattleType then
        if szBattleType == "Normal" then
            if DegreeCtrl:GetDegree(pPlayer, "InDifferBattle") < 1 then
                return false, "參與次數不足"
            end
        else
            if not self:IsQualifyInBattleType(pPlayer, szBattleType) then
                local szQualifyName = InDifferBattle.tbBattleTypeSetting[szBattleType].szName
                return false, string.format("未獲得%s賽資格", szQualifyName), szQualifyName
            end
        end    
    end
    
    if Battle.LegalMap[pPlayer.nMapTemplateId] ~= 1 then
        if Map:GetClassDesc(pPlayer.nMapTemplateId) ~= "fight" or pPlayer.nFightMode ~= 0 then
            return false, "當前所在地不能被傳入心魔幻境準備場"
        end
    end
    
    return true
end

function InDifferBattle:GetRoomIndexByRowCol(nRow, nCol)
    local tbTemp = self.tbRooomPosSetting[nRow]
    if not tbTemp then
        return
    end
    local tbCol = tbTemp[nCol]
    if tbCol then
        return tbCol.Index
    end
end

function InDifferBattle:CanEnhance(pPlayer, nIndex)
    local v = self.tbDefine.tbEnhanceScroll[nIndex]
    if not v then
        return
    end
    local nCurLevel = Strengthen:GetStrengthenLevel(pPlayer, v.tbEquipPos[1])
    local nNextLevel = nCurLevel + self.tbDefine.nStrengthStep
    local nCost = v.tbEnhanceCost[nNextLevel]
    if not nCost then
        return
    end

    local nItemCount = pPlayer.GetItemCountInBags(self.tbDefine.nEnhanceItemId)
    if nItemCount < nCost then
        return false, "強化水晶不足"
    end
    return true, nCost,v.tbEquipPos,nNextLevel
end

function InDifferBattle:ComInit()
        --读取房间的点名
    local tbRooomPosSet = {}; --[index][posName] = {x1,y1}
    local tbFile = LoadTabFile("Setting/InDifferBattle/RandPosSet.tab", "dsddd", nil, 
      {"Index", "Name", "PosX", "PosY", "Dir"});
    for i,v in ipairs(tbFile) do
        tbRooomPosSet[v.Index] = tbRooomPosSet[v.Index] or {};
        tbRooomPosSet[v.Index][v.Name] = { v.PosX, v.PosY, v.Dir};
    end
    self.tbRooomPosSet = tbRooomPosSet

    --填每个房间的上下左右的传送到的位置点，
    local tbFile = LoadTabFile("Setting/InDifferBattle/RoomPos.tab", "ddddddddddd", nil, 
      {"row","col","Index", "LeftX","LeftY","RightX","RightY","BottomX","BottomY", "TopX", "TopY"});
    local tbRooomPosSetting = {}
    local tbRoomIndex = {}
    
    for i,v in ipairs(tbFile) do
        tbRooomPosSetting[v.row] = tbRooomPosSetting[v.row] or {};
        tbRooomPosSetting[v.row][v.col] = {
            L = { v.LeftX, v.LeftY, v.Index };
            R = { v.RightX, v.RightY, v.Index };
            B = { v.BottomX, v.BottomY, v.Index };
            T = { v.TopX, v.TopY, v.Index };
            Index = v.Index;
        }   
        tbRoomIndex[v.Index] = {v.row, v.col }
    end
    self.tbRoomIndex = tbRoomIndex
    local tbRoomIndex1 = {}; --最外层的房间编号
    local tbRoomIndex2 = {}; --第二层的房间编号
    
    self.tbRooomPosSetting = tbRooomPosSetting

    -- 先计算出来各个trap点对应的传送位置， trap 名 Trap11L Trap12R  这种
    local tbRoomTrapToPos = {}
    for i=1,5 do
        for j=1,5 do
            if j > 1 then
                tbRoomTrapToPos["Trap" .. i ..j .. "L"] = tbRooomPosSetting[i][j - 1].R
            end
            if j < 5 then
                tbRoomTrapToPos["Trap" .. i ..j .. "R"] = tbRooomPosSetting[i][j + 1].L
            end
            if i > 1 then
                tbRoomTrapToPos["Trap" .. i ..j .. "T"] = tbRooomPosSetting[i - 1][j].B
            end
            if i < 5 then
                tbRoomTrapToPos["Trap" .. i ..j .. "B"] = tbRooomPosSetting[i + 1][j].T
            end
            if  i == 1  or i == 5 or j == 1  or j == 5 then
               table.insert(tbRoomIndex1, tbRooomPosSetting[i][j].Index ) 
            elseif  i ~= 3 or j ~= 3 then
                table.insert(tbRoomIndex2, tbRooomPosSetting[i][j].Index ) 
            end
        end
    end
    self.tbRoomTrapToPos = tbRoomTrapToPos
    self.tbRoomSetting.tbRoomIndex1 = tbRoomIndex1;
    self.tbRoomSetting.tbRoomIndex2 = tbRoomIndex2; --



    --门派秘籍的反向
    self.tbRandSkillBookRevrse = {}
    for i,v in ipairs(self.tbRandSkillBook) do
        self.tbRandSkillBookRevrse[v] = i;
    end

    if MODULE_ZONESERVER then
        --读取movepath
        local tbFile = LoadTabFile("Setting/InDifferBattle/NpcPath.tab", "sdd", nil, 
          {"ClassName", "X", "Y"});
        local tbNpcMovePath = {};
        for i, v in ipairs(tbFile) do
            tbNpcMovePath[v.ClassName] = tbNpcMovePath[v.ClassName] or {};
            table.insert(tbNpcMovePath[v.ClassName], {v.X, v.Y })
        end
        self.tbNpcMovePath = tbNpcMovePath;

        local fnCheckIsStateFight = function (nState)
            if nState == 2 or nState == 4 or nState == 6 or nState == 8 then
                return true
            end
        end

        local fnCheckAwardParam = function (tbParam)
            local szType, nParam1, nParam2, nParam3 = unpack(tbParam)
            if szType == "item" then
            elseif szType == "Jade" then
            elseif szType == "SkillBook" then
                if nParam1 > 4 and nParam1 < 0 then
                    return false
                end
            elseif szType == "RandMoney" then
            elseif szType == "RandBuff" then
            elseif szType == "RandItemCount" then
                if nParam2 > nParam3 then
                    return false
                end
            else
                return false
            end
            return  true
        end

        --概率转换
        for k1, v1 in pairs(tbDefine.tbOpenBoxType) do
            for k2,v2 in pairs(v1) do
                assert(fnCheckIsStateFight(k2), k2)
                local nTotal = 0
                for i3,v3 in ipairs(v2) do
                    nTotal = nTotal + v3[1]
                    v3[1] = nTotal
                    for i4,v4 in ipairs(v3[2]) do
                        -- assert( InDifferBattle.tbBattleBase[v4[1]], k1 .. '.' ..  k2 .. ',' .. i3 .. ',' .. i4)
                        if v4[1] == "OnSendRandDropAwardToTeam" then
                            assert(tbDefine.tbDrapList[ v4[2] ],  k1 .. '.' ..  k2 .. ',' .. i3 .. ',' .. i4)
                        end

                    end
                end
                assert(nTotal <= 1.01, k1)
            end
        end
        --掉落表的概率转换
        for k1,v1 in pairs(tbDefine.tbDrapList) do
            local nRate = 0;
            for i2,v2 in ipairs(v1) do
                nRate = nRate + v2[1]
                v2[1] = nRate
                assert(fnCheckAwardParam(v2[2]), k1 .. ',' .. i2)
            end
            assert(nRate <= 1.01, k1)
        end

        for k1, v1 in pairs(InDifferBattle.tbRoomSetting.tbSingleRoomNpc) do
            assert( InDifferBattle.tbRoomSetting.tbSignleRooms[v1.nRoomGroup], k1 .. "nRoomGroup11" );
            if v1.szDropAwardList then
                for k2,v2 in pairs(v1.szDropAwardList) do
                    assert(fnCheckIsStateFight(k2), k1 ..',' .. k2 )
                    assert(tbDefine.tbDrapList[ v2 ],  k1 ..',' .. k2)
                end
                assert(v1.tbRankAwardNum, k1)
                assert(v1.nLevel, k1)
                assert(v1.nRoomGroup, k1)
                assert(v1.szName, k1)
                assert(v1.szIcon, k1)
            end

        end

        --商店配置检查
        for k1,v1 in pairs(tbDefine.tbSellWarePropSetting) do
            assert(fnCheckIsStateFight(k1), k1)
            for i2,v2 in ipairs(v1) do
                local v3 = v2[1]
                if type(v3) == "number" then
                    assert(tbDefine.tbSellWareSetting[v3], v3)
                else
                    for _,v4 in ipairs(v3) do
                        assert(tbDefine.tbSellWareSetting[v4], v4)
                    end
                end
            end
        end

        
        

    end
end

--指定道具id获得对应的门派秘籍id
function InDifferBattle:GetRandSkillBookId( nRandBook, nFaction )
    local nType = self.tbRandSkillBookRevrse[nRandBook]
    if not nType then
        return
    end
    return Item:GetClass("SkillBook"):GetFactionTypeBook(nType, nFaction)
end

function InDifferBattle:GetRandSkillBookOriId(nBookId)
    local nType = Item:GetClass("SkillBook"):GetBookType(nBookId)
    if nType then
      return self.tbRandSkillBook[nType]
    end
end


function InDifferBattle:GetSellSumPrice(dwTemplateId, nCount)
    local nOriBook = self:GetRandSkillBookOriId(dwTemplateId)
    if nOriBook then
        dwTemplateId = nOriBook;
    end
    local tbItemInfo = self.tbDefine.tbSellWareSetting[dwTemplateId]
    if tbItemInfo then
        return math.floor(tbItemInfo.nPrice * nCount * self.tbDefine.nSelllPricePercent), tbDefine.szMonoeyType
    end
end

function InDifferBattle:GetBuySumPrice(dwTemplateId, nCount)
   local nOriBook = self:GetRandSkillBookOriId(dwTemplateId)
    if nOriBook then
        dwTemplateId = nOriBook;
    end
    local tbItemInfo = self.tbDefine.tbSellWareSetting[dwTemplateId]
    if tbItemInfo then
        return math.floor(tbItemInfo.nPrice * nCount), tbDefine.szMonoeyType
    end
end

function InDifferBattle:GetEvaluationFromScore( nScore )
    local nGrade = 1
    local tbEvaluationSetting = InDifferBattle.tbDefine.tbEvaluationSetting
    for i,v in ipairs(tbEvaluationSetting) do
        if nScore >= v.nScoreMin then
            nGrade = i
        end
    end
    return nGrade, tbEvaluationSetting[nGrade]
end

function InDifferBattle:GetNextOpenTime(szType, nTime)
    nTime = nTime or GetTime() --如果是判断当前的进入时间时，就是用当前时间前一个小时来判断是不是同一场的时间
    local tbType = self.tbBattleTypeSetting[szType]
    local szFunc = tbType.szOpenTimeFunc
    return self[szFunc](self, tbType, nTime)
end

function InDifferBattle:GetNextOpenTimeMonth(tbType, nTime)
    local nTimeRet = Lib:GetTimeByWeekInMonth(nTime, tbType.OpenTimeWeek, tbType.OpenTimeWeekDay, tbType.OpenTimeHour, tbType.OpenTimeMinute, 0)
    if nTimeRet < nTime  then --对应要求的开启时间是传过来时间之前，就应该是传下个月的时间
        local tbTimeNow = os.date("*t", nTime)    
        local nSec = os.time({year = tbTimeNow.year, month = tbTimeNow.month + 1, day = 1, hour = 1, min = 0, sec = 0});
        nTimeRet = Lib:GetTimeByWeekInMonth(nSec, tbType.OpenTimeWeek, tbType.OpenTimeWeekDay, tbType.OpenTimeHour, tbType.OpenTimeMinute, 0)
    end
    local tbTimeNow = os.date("*t", nTimeRet)    
    if tbTimeNow.year == 2017 and (tbTimeNow.month == 6 or tbTimeNow.month == 7) then
        local nSec = os.time({year = 2017, month = 8, day = 1, hour = 1, min = 0, sec = 0});
       nTimeRet =  Lib:GetTimeByWeekInMonth(nSec, tbType.OpenTimeWeek, tbType.OpenTimeWeekDay, tbType.OpenTimeHour, tbType.OpenTimeMinute, 0)
    end
    return  nTimeRet
end

function InDifferBattle:GetNextOpenTimeSeason(tbType, nTime)
    local tbTimeNow = os.date("*t", nTime)
    local nSeason = math.ceil(tbTimeNow.month / 3) 
    local nSec = os.time({year = tbTimeNow.year, month = nSeason * 3, day = 1, hour = tbType.OpenTimeHour, min = tbType.OpenTimeMinute, sec = 0});
    return Lib:GetTimeByWeekInMonth(nSec, tbType.OpenTimeWeek, tbType.OpenTimeWeekDay, tbType.OpenTimeHour, tbType.OpenTimeMinute, 0)
end

function InDifferBattle:GetNextOpenTimeYear( tbType, nTime )
    --因为是不确定的，先是写死为 2018年7月，确定后要类似 GetNextOpenTimeMonth 的处理，
    local nSec = os.time({year = 2020, month = 7, day = 1, hour = tbType.OpenTimeHour, min = tbType.OpenTimeMinute, sec = 0});
    return Lib:GetTimeByWeekInMonth(nSec, tbType.OpenTimeWeek, tbType.OpenTimeWeekDay, tbType.OpenTimeHour, tbType.OpenTimeMinute, 0)
end

function InDifferBattle:IsQualifyInBattleType(pPlayer, szType, bNext) --bNext 就是判断是否能参加下次，非next是参与当前的会减少1小时
    local tbType = self.tbBattleTypeSetting[szType]
    local nNowQualifyTime = pPlayer.GetUserValue(self.tbDefine.SAVE_GROUP, tbType.nKeyQualifyTime)
    if nNowQualifyTime == 0 then
        return
    end
    local nNow = GetTime()
    if not bNext then
        nNow = nNow - 360;--大于报名的持续时间
    end
    local nCurOpenBattleTime = self:GetNextOpenTime(szType, nNow)
    local bRet = Lib:GetLocalDay(nNowQualifyTime) == Lib:GetLocalDay(nCurOpenBattleTime)
    return bRet, nCurOpenBattleTime
end


function InDifferBattle:GetCurOpenQualifyType()
    local nNow = GetTime()
    for k,v in pairs(self.tbBattleTypeSetting) do
        if v.nNeedGrade then
            if MODULE_ZONESERVER or (v.szOpenTimeFrame and GetTimeFrameState(v.szOpenTimeFrame) == 1)  then
                local nCurOpenBattleTime = self:GetNextOpenTime(k, nNow - 3600)    
                if math.abs(nCurOpenBattleTime - nNow) < 1800 then
                    return k;
                end
            end
        end
    end
end

function InDifferBattle:GetTopCanSignBattleType(tbPlayers, tbReadyMapList)
    --从高到底的，如果有一个人能参与， 则就是参与该类型的
    for i,v in ipairs(tbReadyMapList) do
        local nReadyMapId, szBattleType, nLevel = unpack(v)
        if szBattleType == "Normal" then
            return szBattleType, nReadyMapId, ""
        else
            for i, pPlayer in ipairs(tbPlayers) do
                if self:IsQualifyInBattleType(pPlayer, szBattleType) then
                    return  szBattleType, nReadyMapId, pPlayer.szName
                end 
            end
        end
    end
end


InDifferBattle:ComInit();


if MODULE_ZONESERVER then
    local fnCheckData = function ( )
        local nTotalGameFightTime = 0;
        for i = 2, #tbDefine.STATE_TRANS -1 do
            local v = tbDefine.STATE_TRANS[i]
            nTotalGameFightTime = nTotalGameFightTime + v.nSeconds
        end
        tbDefine.nTotalGameFightTime = nTotalGameFightTime

        assert(#InDifferBattle.tbRoomSetting.tbRandomCloseRoomState1 > 1) --小于1随机会有问题
        for i,v in ipairs(InDifferBattle.tbRoomSetting.tbRandomCloseRoomState1) do
            assert(#v == 8, i);
            local tbV = {}
            for i2,v2 in ipairs(v) do
                assert(not tbV[v2], i .."," .. i2)
                tbV[v2] = true
            end
        end

        assert(tbDefine.nCloseRoomPunishPersent > 0 and tbDefine.nCloseRoomPunishPersent < 1)

        --预关闭房间的时间要小于 流程结束时间
        for nState, v1 in pairs(tbDefine.tbActiveTrans) do
            local tbManinTrans = tbDefine.STATE_TRANS[nState]
            for nScends,v2 in pairs(v1) do
                assert(nScends < tbManinTrans.nSeconds,  nState .. ',' .. nScends)
                --检查流程里的函数参数
                for i3, v3 in ipairs(v2) do
                    local szFuncName = v3[1]
                    -- assert( InDifferBattle.tbBattleBase[szFuncName], szFuncName)
                    if szFuncName == "AddRandPosNpcSet" then
                        local szTag = table.concat({nState,nScends,i3,}, ",")
                        for _,v4 in ipairs(v3[5]) do
                            assert(InDifferBattle.tbRooomPosSet[v3[4]][ v4 ], szTag .. "," .. v4)
                        end
                        local nMin,nMax = unpack( v3[6] )
                        assert(nMin<=nMax, szTag)
                        assert( #v3[5] >= nMax, szTag) --点集合数应小于等于最大随机数
                    elseif szFuncName == "AddRandTypeSet" then
                        local nRate = 0
                        for i4, v4 in ipairs(v3[4]) do
                            nRate = v4[1] + nRate 
                            v4[1] = nRate
                        end
                        assert(nRate <= 1.01, table.concat({nState,nScends,i3, }, ",") )
                    elseif szFuncName == "AddRandTypeSetTimer" then
                        local nRate = 0
                        for i4, v4 in ipairs(v3[5]) do
                            nRate = v4[1] + nRate 
                            v4[1] = nRate
                        end
                        assert(nRate <= 1.01, table.concat({nState,nScends,i3, }, ",") )

                    elseif szFuncName == "AddAutoHideWalkPathNpc" then
                        assert( InDifferBattle.tbNpcMovePath[ v3[5] ] , table.concat({nState,nScends,i3, }, ",") )
                    end
                end

            end
        end

        for k, v in pairs(InDifferBattle.tbRoomSetting.tbSignleRooms) do
            local tbHased = {}
            for i2,v2 in ipairs(v) do
                assert(not tbHased[v2], k .. " tbSignleRooms")
                tbHased[v2] = 1;
            end
        end
        --道具的随机总值小于10000
        local nTotalRate = 0
        for i, v in ipairs(tbDefine.tbBattleNpcDropSettingItem) do
            nTotalRate = nTotalRate + v[2]
            v[2] = nTotalRate
        end
        assert(nTotalRate <= 10000)

        local nTotalRate = 0
        for i, v in ipairs(tbDefine.tbInitGiveItem) do
            nTotalRate = nTotalRate + v[1]
            v[1] = nTotalRate
        end
        assert(nTotalRate <= 10000)

        --每个房间点都有center
        for nRoomIndex=1,25 do
            local tbPosSet = InDifferBattle.tbRooomPosSet[nRoomIndex]
            local v = tbPosSet.center;
            assert(v, nRoomIndex)
            local nRow, nCol = unpack(InDifferBattle.tbRoomIndex[nRoomIndex])
            for szPosName, tbRowCol in pairs(tbDefine.tbGateDirectionModify) do
                local nRowModi, nColModi = unpack(tbRowCol)
                local nTarRoomIndex = InDifferBattle:GetRoomIndexByRowCol(nRow + nRowModi, nCol + nColModi)
                if nTarRoomIndex then
                    assert(tbPosSet[szPosName], nRoomIndex .. ',' ..  szPosName ..',' .. nTarRoomIndex)
                end
            end
        end

        for _, v in ipairs(tbDefine.tbLastSwitchRandPosSet) do
            assert(InDifferBattle.tbRooomPosSet[1][v], v)
        end
    end
    fnCheckData()
end
