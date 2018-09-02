Require("CommonScript/Activity/LoverRecallActC.lua");
local tbAct = Activity:GetClass("LoverRecallAct")
local tbFubenSetting = {};
local nMapTemplateId = 1612

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
    [1] = {nTemplate = 2289, nLevel = -1, nSeries = 0},  --月眉儿
    [2] = {nTemplate = 2287, nLevel = -1, nSeries = 0},  --杨影枫
    [3] = {nTemplate = 746, nLevel = -1, nSeries = 0},  --银丝草
    [4] = {nTemplate = 789, nLevel = -1, nSeries = 0},  --飞龙堡弟子
    [5] = {nTemplate = 790, nLevel = -1, nSeries = 0},  --飞龙堡护法
    [6] = {nTemplate = 791, nLevel = -1, nSeries = 0},  --飞龙堡头目         
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
            {"BlackMsg", "這是…心魔幻境？不知楊少俠與月姑娘在哪！去前方看看！"},
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

            {"NpcBubbleTalk", "Npc2", "楊熙烈…就是他害得我家破人亡…孤苦伶仃…", 4, 1, 1},
            {"NpcBubbleTalk", "Npc2", "爹…娘…你們放心，眉兒一定會替你們報仇！", 4, 6, 1},
            {"NpcBubbleTalk", "Npc2", "可是楊熙烈已經死了，對了，他還有個兒子！", 4, 11, 1},
            {"NpcBubbleTalk", "Npc2", "雖然我不知道你叫什麼名字，但我知道，總有一天我們會遇見的…", 4, 16, 1},         

            {"BlackMsg", "楊少俠與月姑娘之父均是名劍客，因楊父要求比劍導致二人俱亡"},
        },
        tbUnLockEvent = 
        {

        },
    },    
    [4] = {nTime = 1, nNum = 0,
        tbPrelock = {3},
        tbStartEvent = 
        {
       
        },
        tbUnLockEvent = 
        {   

        },
    },   
    [5] = {nTime = 0, nNum = 12,
        tbPrelock = {4},
        tbStartEvent = 
        {
            --刷毒蜂
            {"AddNpc", 4, 8, 5, "guaiwu1", "guaiwu1_pos", 1, 0, 0, 0, 0},
            {"AddNpc", 5, 3, 5, "guaiwu1", "guaiwu2_pos", 1, 0, 0, 0, 0},
            {"AddNpc", 6, 1, 5, "guaiwu1", "guaiwu3_pos", 1, 0, 0, 0, 0},

            --纳兰真
            {"NpcBubbleTalk", "Npc2", "你們竟敢背叛飛龍堡，加害於我！真是膽大包天！", 4, 1, 1},

            --杨影枫 
            {"AddNpc", 2, 1, 1, "Npc1", "LoverRecall_Npc1_Pos1", false, 0, 0, 0, 0}, 
            --{"SetNpcProtected", "Npc1", 1},
            {"NpcBubbleTalk", "Npc1", "哈哈哈，這麼熱鬧，讓在下也來插一腳怎麼樣！", 4, 3, 1},   

            {"BlackMsg", "是飛龍堡的叛徒！幫幫月姑娘！"},               
        },
        tbUnLockEvent = 
        {   
            {"PlayEffect", 9005, 5963, 7552, 0, 1},
            {"DelNpc", "Npc2"},
            {"PlayEffect", 9005, 5963, 7552, 0, 1},
            {"DelNpc", "Npc1"},
            {"BlackMsg", "楊少俠與月姑娘的幻影忽然消失了"}, 
            {"SetFubenProgress", -1, "繼續前進"}, 
        },
    },  
    [6] = {nTime = 0, nNum = 1,
        tbPrelock = {5},
        tbStartEvent = 
        {
            --纳兰真
            {"AddNpc", 1, 1, 1, "Npc2", "LoverRecall_Npc2_Pos2", false, 42, 0, 0, 0},

            --杨影枫 
            {"AddNpc", 2, 1, 1, "Npc1", "LoverRecall_Npc1_Pos2", false, 12, 0, 0, 0},

            {"TrapUnlock", "TrapLock2", 6},   
            
            {"SetTargetPos", 5500, 3100},
        },
        tbUnLockEvent = 
        {
            {"ClearTargetPos"},
            {"BlackMsg", "楊少俠與月姑娘既有殺父之仇，又有兒女之情，錯綜複雜"}, 
            --设置Npc朝向
            --{"SetNpcDir", "Npc1", 0}
        },
    },
    [7] = {nTime = 30, nNum = 0,
        tbPrelock = {6},
        tbStartEvent = 
        {
            {"NpcBubbleTalk", "Npc1", "月眉兒！你為什麼要綁架納蘭真和薔薇？", 4, 1, 1},
            {"NpcBubbleTalk", "Npc2", "楊影楓，如果我說她們被綁架跟我無關，你相信嗎？", 4, 6, 1},
            {"NpcBubbleTalk", "Npc1", "不信！這是紫軒親眼所見，你還讓我用《武道德經》到飛龍堡換人", 4, 11, 1},
            {"NpcBubbleTalk", "Npc2", "哼！楊影楓，你欺人太甚，閒話少說…納蘭真已經被我殺了，有本事你就殺了我替她報仇！", 4, 16, 1}, 
            {"NpcBubbleTalk", "Npc1", "什麼！？…真兒！…月眉兒…我要殺了你…給我的真兒報仇！", 4, 21, 1}, 
            {"NpcBubbleTalk", "Npc2", "（我為何會說出這種話？難道是他太過關心真兒，讓我生出嫉妒之心嗎？）", 4, 26, 1}, 

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
    [8] = {nTime = 1, nNum = 0,
        tbPrelock = {7},
        tbStartEvent = 
        {
 
        },
        tbUnLockEvent = 
        {
            --纳兰真
            {"AddNpc", 1, 1, 1, "Npc2", "LoverRecall_Npc2_Pos3", false, 10, 0, 0, 0},

            --杨影枫 
            {"AddNpc", 2, 1, 1, "Npc1", "LoverRecall_Npc1_Pos3", false, 42, 0, 0, 0},

            {"SetFubenProgress", -1, "繼續前進"}, 
        },
    },    
    [9] = {nTime = 0, nNum = 1,
        tbPrelock = {8},
        tbStartEvent = 
        {
            {"SetTargetPos", 3000, 4500},

            {"TrapUnlock", "TrapLock3", 9},   

        },
        tbUnLockEvent = 
        {
            {"ClearTargetPos"},
        },
    },       
    [10] = {nTime = 25, nNum = 0,
        tbPrelock = {9},
        tbStartEvent = 
        {
            {"NpcBubbleTalk", "Npc2", "楊大哥，我千方百計留你在我身邊，只是因為，我不想你離開…", 4, 1, 1},
            {"NpcBubbleTalk", "Npc1", "眉兒…你不再找我報仇了嗎…", 4, 6, 1},
            {"NpcBubbleTalk", "Npc2", "上一代的仇怨，就讓它隨風而去吧…", 4, 11, 1},
            {"NpcBubbleTalk", "Npc1", "眉兒，謝謝你，我一定好好待你，絕不辜負你！", 4, 16, 1}, 
            {"NpcBubbleTalk", "Npc2", "謝、謝謝你…楊大哥…", 4, 21, 1}, 

            {"SetFubenProgress", -1, "聆聽二人對話"},  
        },
        tbUnLockEvent = 
        {

        },
    },    
    [11] = {nTime = 5, nNum = 0,
        tbPrelock = {10},
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