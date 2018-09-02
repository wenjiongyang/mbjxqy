Require("CommonScript/Activity/LoverRecallActC.lua");
local tbAct = Activity:GetClass("LoverRecallAct")
local tbFubenSetting = {};
local nMapTemplateId = 1611

Fuben:SetFubenSetting(nMapTemplateId, tbFubenSetting)   -- 绑定副本内容和地图

tbFubenSetting.szNpcPointFile           = "Setting/Fuben/LoverRecallFuben/NpcPos.tab"         -- NPC点
tbFubenSetting.szPathFile               = "Setting/Fuben/LoverRecallFuben/NpcPath.tab"        -- 寻路点

tbFubenSetting.szFubenClass   = tbAct.szFubenClass;                                  -- 副本类型
tbFubenSetting.szName         = "心魔幻境"                                             -- 单纯的名字，后台输出或统计使用
tbFubenSetting.tbBeginPoint   = {5000, 9800}  
tbFubenSetting.tbTempRevivePoint = {5000, 9800}  


-- ID可以随便 普通副本NPC数量 ；精英模式NPC数量
tbFubenSetting.NUM = 
{
    
}

tbFubenSetting.ANIMATION = 
{
   
}

--NPC模版ID，NPC等级，NPC五行；
--[[

]]

tbFubenSetting.NPC = 
{
    [1] = {nTemplate = 2288, nLevel = -1, nSeries = 0},  --纳兰真
    [2] = {nTemplate = 2287, nLevel = -1, nSeries = 0},  --杨影枫
    [3] = {nTemplate = 746, nLevel = -1, nSeries = 0},  --银丝草
    [4] = {nTemplate = 756, nLevel = -1, nSeries = 0},  --毒蜂
    [5] = {nTemplate = 757, nLevel = -1, nSeries = 0},  --大型毒蜂
    [6] = {nTemplate = 758, nLevel = -1, nSeries = 0},  --大型毒蜂         
}

-- ChangeRoomState              更改房间title
--                              参数：nFloor 层, nRoomIdx 房间序列, szTitile 标题, nX, nY自动寻路点坐标, bKillBoss 是否杀死了BOSS
--                              示例：{"AddNpc", "NpcIndex2", "NpcNum2", 3, "Test1", "NpcPos2", true, 30, 2, 206, 1},

tbFubenSetting.LOCK = 
{
    -- 1号锁不能不填，默认1号为起始锁，nTime是到时间自动解锁，nNum表示需要解锁的次数，如填3表示需要被解锁3次才算真正解锁，可以配置字符串
    [1] = {nTime = 1, nNum = 0,
        --tbPrelock 前置锁，激活锁的必要条件{1 , 2, {3, 4}}，代表1和2号必须解锁，3和4任意解锁一个即可
        tbPrelock = {},
        --tbStartEvent 锁激活时的事件
        tbStartEvent = 
        {
            {"OpenWindow", "RockerGuideNpcPanel", "心魔幻境 純真"},
            {"SetKickoutPlayerDealyTime", 20},

            {"SetTargetPos", 6000, 7500},

            {"SetFubenProgress", -1, "四處探索"}, 
        },
        --tbStartEvent 锁解开时的事件
        tbUnLockEvent = 
        {            
            {"BlackMsg", "這是…心魔幻境？不知楊少俠與納蘭姑娘在哪！去前方看看！"},
        },
    },
    [2] = {nTime = 0, nNum = 1,
        tbPrelock = {1},
        tbStartEvent = 
        {
            --杨影枫 
            --{"AddNpc", 1, 1, 1, "Npc1", "LoverRecall_Npc1_Pos1", false, 0, 0, 0, 0},

            --纳兰真 
            {"AddNpc", 1, 1, 1, "Npc2", "LoverRecall_Npc2_Pos1", false, 30, 0, 0, 0},   
            {"SetNpcProtected", "Npc2", 1},

            --解锁
            {"TrapUnlock", "TrapLock1", 2},        
        },
        tbUnLockEvent = 
        {
            {"ClearTargetPos"},
        },
    },
    [3] = {nTime = 20, nNum = 0,
        tbPrelock = {2},
        tbStartEvent = 
        {
            --纳兰真 
            --{"AddNpc", 1, 1, 1, "Npc2", "LoverRecall_Npc2_Pos1", false, 0, 0, 0, 0},

            {"NpcBubbleTalk", "Npc2", "楊大哥受傷很重，我一定要采來銀絲草為他療傷……", 4, 1, 1},
            {"NpcBubbleTalk", "Npc2", "幫他恢復內功，他一定會很高興的！想想就覺得開心！", 4, 6, 1},
            {"NpcBubbleTalk", "Npc2", "可是，也許他恢復內功，就要離開了……", 4, 11, 1},
            {"NpcBubbleTalk", "Npc2", "若真是那樣…我還會覺得高興嗎…", 4, 16, 1},         

            {"BlackMsg", "楊少俠從懸崖墜落，身受重傷，是納蘭姑娘救了他，因此結緣"},
        },
        tbUnLockEvent = 
        {

        },
    },    
    [4] = {nTime = 0, nNum = 12,
        tbPrelock = {3},
        tbStartEvent = 
        {
            --刷毒蜂
            {"AddNpc", 4, 8, 4, "guaiwu1", "guaiwu1_pos", 1, 0, 0, 0, 0},
            {"AddNpc", 5, 3, 4, "guaiwu1", "guaiwu2_pos", 1, 0, 0, 0, 0},
            {"AddNpc", 6, 1, 4, "guaiwu1", "guaiwu3_pos", 1, 0, 0, 0, 0},

            --纳兰真
            {"NpcBubbleTalk", "Npc2", "這麼多毒蜂…我該怎麼辦…", 4, 1, 1},

            {"BlackMsg", "前方忽然出現了大批的毒蜂！幫幫納蘭姑娘！"},               
        },
        tbUnLockEvent = 
        {   
            {"PlayEffect", 9005, 5963, 7552, 0, 1},
            {"DelNpc", "Npc2"},
            {"BlackMsg", "納蘭姑娘的幻影忽然消失了"}, 
            {"SetFubenProgress", -1, "繼續前進"}, 
        },
    },   
    [5] = {nTime = 0, nNum = 1,
        tbPrelock = {4},
        tbStartEvent = 
        {
            --纳兰真
            {"AddNpc", 1, 1, 1, "Npc2", "LoverRecall_Npc2_Pos2", false, 42, 0, 0, 0},

            --杨影枫 
            {"AddNpc", 2, 1, 1, "Npc1", "LoverRecall_Npc1_Pos2", false, 12, 0, 0, 0},

            {"TrapUnlock", "TrapLock2", 5},   
            
            {"SetTargetPos", 5500, 3100},
        },
        tbUnLockEvent = 
        {
            {"ClearTargetPos"},
            {"BlackMsg", "唉，納蘭姑娘實在是太善良了"}, 
            --设置Npc朝向
            --{"SetNpcDir", "Npc1", 0}
        },
    },
    [6] = {nTime = 30, nNum = 0,
        tbPrelock = {5},
        tbStartEvent = 
        {
            {"NpcBubbleTalk", "Npc2", "楊大哥…剛才掉下來的時候，我、我很害怕你會扔下我…", 4, 1, 1},
            {"NpcBubbleTalk", "Npc1", "怎麼會呢？我怎麼會扔下你不管呢？", 4, 6, 1},
            {"NpcBubbleTalk", "Npc2", "可若是我們無法離開，你要成為天下第一的願望就會落空", 4, 11, 1},
            {"NpcBubbleTalk", "Npc1", "方才倒是未曾多想，只知不可扔你一人不管。", 4, 16, 1}, 
            {"NpcBubbleTalk", "Npc2", "謝、謝謝你…楊大哥…", 4, 21, 1},
            {"NpcBubbleTalk", "Npc1", "嗯。只不過，這到底是哪兒呢？", 4, 26, 1}, 
            {"NpcBubbleTalk", "Npc2", "（楊大哥…有那麼一瞬，你願為我暫放天下第一，我已心滿意足…）", 4, 26, 1},   

            {"SetFubenProgress", -1, "聆聽二人對話"},  
        },
        tbUnLockEvent = 
        {
            --删除杨影枫
            {"PlayEffect", 9005, 5800, 2400, 0, 1},
            {"DelNpc", "Npc1"},
            --删除纳兰真
            {"PlayEffect", 9005, 5380, 2240, 0, 1},
            {"DelNpc", "Npc2"},            
            --设置Npc朝向
            --{"SetNpcDir", "Npc1", 0}
        },
    },
    [7] = {nTime = 3, nNum = 0,
        tbPrelock = {6},
        tbStartEvent = 
        {
 
            {"SetFubenProgress", -1, "繼續前進"},  
        },
        tbUnLockEvent = 
        {
            --纳兰真
            {"AddNpc", 1, 1, 1, "Npc2", "LoverRecall_Npc2_Pos3", false, 10, 0, 0, 0},

            --杨影枫 
            {"AddNpc", 2, 1, 1, "Npc1", "LoverRecall_Npc1_Pos3", false, 42, 0, 0, 0},
        },
    },    
    [8] = {nTime = 0, nNum = 1,
        tbPrelock = {6},
        tbStartEvent = 
        {
            {"SetTargetPos", 3000, 4500},

            {"TrapUnlock", "TrapLock3", 8},   

        },
        tbUnLockEvent = 
        {
            {"ClearTargetPos"},
        },
    },       
    [9] = {nTime = 20, nNum = 0,
        tbPrelock = {8},
        tbStartEvent = 
        {
            {"NpcBubbleTalk", "Npc2", "影楓哥哥，我好擔心你再次陷入絕境…不要走", 4, 1, 1}, 
            {"NpcBubbleTalk", "Npc1", "真兒，不必為我擔心，男子漢大丈夫若有所做為，怎能縮頭縮尾！", 4, 6, 1}, 
            {"NpcBubbleTalk", "Npc2", "除非你殺了我！否則你休想離開忘憂島半步！", 4, 11, 1}, 
            {"NpcBubbleTalk", "Npc1", "想來這便是我心中的貪逸所幻化，如果我不能破除此結，將來行道江湖決心必不會堅定！", 4, 16, 1},

            {"SetFubenProgress", -1, "聆聽二人對話"},  
        },
        tbUnLockEvent = 
        {

        },
    },    
    [10] = {nTime = 3, nNum = 0,
        tbPrelock = {9},
        tbStartEvent = 
        {
            --杨影枫秀一波
            {"DoCommonAct", "Npc1", 16, 0, 0, 0},
            {"CastSkill", "Npc1", 1763, 1, 2350, 5000},
            --重伤动作
            {"DoCommonAct", "Npc2", 36, 0, 1, 0},
        },
        tbUnLockEvent = 
        {
            --定时器自杀
            {"CastSkill", "Npc2", 3, 1, -1, -1},            
        },
    },
    [11] = {nTime = 2, nNum = 0,
        tbPrelock = {10},
        tbStartEvent = 
        {
 

        },
        tbUnLockEvent = 
        {
            --纳兰真
            {"AddNpc", 1, 1, 1, "Npc2", "LoverRecall_Npc2_Pos3", false, 10, 0, 0, 0},

        },
    },      
    [12] = {nTime = 20, nNum = 0,
        tbPrelock = {11},
        tbStartEvent = 
        {
            {"NpcBubbleTalk", "Npc2", "影楓哥哥，你怎麼如此狠心？", 4, 1, 1}, 
            {"NpcBubbleTalk", "Npc1", "真兒，你知道我必須完成爹爹的遺願！相信我會再回來的！", 4, 6, 1}, 
            {"NpcBubbleTalk", "Npc2", "不，我不要聽……我不讓你走，我不管什麼遺願，什麼天下第一！", 4, 11, 1}, 
            {"NpcBubbleTalk", "Npc1", "怎麼會變成這樣……？魔由心出……心魔，一定是心魔！", 4, 16, 1},
        },
        tbUnLockEvent = 
        {

        },
    },    
    [13] = {nTime = 3, nNum = 0,
        tbPrelock = {12},
        tbStartEvent = 
        {
            --杨影枫秀一波
            {"DoCommonAct", "Npc1", 16, 0, 0, 0},
            {"CastSkill", "Npc1", 1763, 1, 2350, 5000},
            --重伤动作
            {"DoCommonAct", "Npc2", 36, 0, 1, 0},
        },
        tbUnLockEvent = 
        {
            --定时器自杀
            {"CastSkill", "Npc2", 3, 1, -1, -1},            
        },
    },
    [14] = {nTime = 2, nNum = 0,
        tbPrelock = {13},
        tbStartEvent = 
        {
 

        },
        tbUnLockEvent = 
        {
            --纳兰真
            {"AddNpc", 1, 1, 1, "Npc2", "LoverRecall_Npc2_Pos3", false, 10, 0, 0, 0},

        },
    },  
    [15] = {nTime = 20, nNum = 0,
        tbPrelock = {14},
        tbStartEvent = 
        {
            {"NpcBubbleTalk", "Npc2", "天下第一真的那麼重要？成為了天下第一你又能如何？你會後悔的……", 4, 1, 1}, 
            {"NpcBubbleTalk", "Npc1", "又是心魔！", 4, 6, 1}, 
            {"NpcBubbleTalk", "Npc2", "影楓，你很討厭我，要離開我是嗎？你會後悔的……", 4, 11, 1}, 
            {"NpcBubbleTalk", "Npc1", "不是這樣的，真兒！你……不是真兒，是我的心結！", 4, 16, 1},
        },
        tbUnLockEvent = 
        {

        },
    },    
    [16] = {nTime = 3, nNum = 0,
        tbPrelock = {15},
        tbStartEvent = 
        {
            --杨影枫秀一波
            {"DoCommonAct", "Npc1", 16, 0, 0, 0},
            {"CastSkill", "Npc1", 1763, 1, 2350, 5000},
            --重伤动作
            {"DoCommonAct", "Npc2", 36, 0, 1, 0},
        },
        tbUnLockEvent = 
        {
            --定时器自杀
            {"CastSkill", "Npc2", 3, 1, -1, -1},            
        },
    },
    [17] = {nTime = 2, nNum = 0,
        tbPrelock = {16},
        tbStartEvent = 
        {
 

        },
        tbUnLockEvent = 
        {
            --纳兰真
            {"AddNpc", 1, 1, 1, "Npc2", "LoverRecall_Npc2_Pos3", false, 10, 0, 0, 0},

        },
    },  
    [18] = {nTime = 20, nNum = 0,
        tbPrelock = {17},
        tbStartEvent = 
        {
            {"NpcBubbleTalk", "Npc2", "天下第一真的那麼重要？成為了天下第一你又能如何？你會後悔的……", 4, 1, 1}, 
            {"NpcBubbleTalk", "Npc1", "又是心魔！", 4, 6, 1}, 
            {"NpcBubbleTalk", "Npc2", "影楓，你很討厭我，要離開我是嗎？你會後悔的……", 4, 11, 1}, 
            {"NpcBubbleTalk", "Npc1", "不是這樣的，真兒！你……不是真兒，是我的心結！", 4, 16, 1},
        },
        tbUnLockEvent = 
        {

        },
    },    
    [19] = {nTime = 3, nNum = 0,
        tbPrelock = {18},
        tbStartEvent = 
        {
            --杨影枫秀一波
            {"DoCommonAct", "Npc1", 16, 0, 0, 0},
            {"CastSkill", "Npc1", 1763, 1, 2350, 5000},
            --重伤动作
            {"DoCommonAct", "Npc2", 36, 0, 1, 0},
        },
        tbUnLockEvent = 
        {
            --定时器自杀
            {"CastSkill", "Npc2", 3, 1, -1, -1},            
        },
    },   
    [20] = {nTime = 2, nNum = 0,
        tbPrelock = {19},
        tbStartEvent = 
        {
 

        },
        tbUnLockEvent = 
        {
            --纳兰真
            {"AddNpc", 1, 1, 1, "Npc2", "LoverRecall_Npc2_Pos3", false, 10, 0, 0, 0},

        },
    },  
    [21] = {nTime = 10, nNum = 0,
        tbPrelock = {20},
        tbStartEvent = 
        {
            {"NpcBubbleTalk", "Npc1", "大丈夫在世有所為，有所不為，我寧可出不了此陣，也萬萬不會對真兒下手", 4, 1, 1}, 
            {"NpcBubbleTalk", "Npc2", "你……我不理你了！", 4, 6, 1}, 
        },
        tbUnLockEvent = 
        {
            --删除纳兰真
            {"PlayEffect", 9005, 2350, 5000, 0, 1},
            {"DelNpc", "Npc2"},            
            --设置Npc朝向
            --{"SetNpcDir", "Npc1", 0}
        },
    },  
    [22] = {nTime = 2, nNum = 0,
        tbPrelock = {21},
        tbStartEvent = 
        {
 

        },
        tbUnLockEvent = 
        {
            --纳兰真
            {"AddNpc", 1, 1, 1, "Npc2", "LoverRecall_Npc2_Pos3", false, 10, 0, 0, 0},

        },
    }, 
    [23] = {nTime = 15, nNum = 0,
        tbPrelock = {22},
        tbStartEvent = 
        {
            {"NpcBubbleTalk", "Npc1", "真兒，此時此刻，我才知道你在我心中有多重要！", 4, 1, 1},   --Npc2已经挂了，这句执行不到
            {"NpcBubbleTalk", "Npc2", "謝謝你，楊大哥…你竟為了我克制住了幻境中的心魔…", 4, 6, 1},
            {"NpcBubbleTalk", "Npc1", "真兒，此生此世，我們再也不分開了！", 4, 11, 1},   --Npc2已经挂了，这句执行不到
        },
        tbUnLockEvent = 
        {

        },
    },
    [24] = {nTime = 5, nNum = 0,
        tbPrelock = {23},
        tbStartEvent = 
        {
        },
        tbUnLockEvent = 
        {
            {"SetFubenProgress", -1, "離開幻境"}, 
            {"BlackMsg", "現在可以離開了！"},
            {"GameWin"},
        },
    },       
    [100] = {nTime = 600, nNum = 0,
        tbPrelock = {1},
        tbStartEvent = 
        {
            {"SetShowTime", 100},
            --{"SetFubenProgress", -1, "即将离开"}, 
        },
        tbUnLockEvent = 
        {
            {"GameLost"},
        },
    },
}