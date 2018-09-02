Require("CommonScript/Activity/LoverRecallActC.lua");
local tbAct = Activity:GetClass("LoverRecallAct")
local tbFubenSetting = {};
local nMapTemplateId = 1613

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
    [1] = {nTemplate = 2290, nLevel = -1, nSeries = 0},  --紫轩
    [2] = {nTemplate = 2287, nLevel = -1, nSeries = 0},  --杨影枫
    [3] = {nTemplate = 2300, nLevel = -1, nSeries = 0},  --卓非凡
    [4] = {nTemplate = 846, nLevel = -1, nSeries = 0},  --流氓
    [5] = {nTemplate = 847, nLevel = -1, nSeries = 0},  --流氓头目
    [6] = {nTemplate = 2303, nLevel = -1, nSeries = 0},  --贾少         
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
            {"BlackMsg", "這是…心魔幻境？不知楊少俠與紫軒姑娘在哪！去前方看看！"},
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

            {"NpcBubbleTalk", "Npc2", "父親自小離我而去，如今母親也因病而逝…", 4, 1, 1},
            {"NpcBubbleTalk", "Npc2", "罷了，我孤身一人，無依無靠，還不如去尋我的父母…", 4, 6, 1},
            {"NpcBubbleTalk", "Npc2", "天大地大，竟沒有我的容身之所，也無人關懷", 4, 11, 1},
            {"NpcBubbleTalk", "Npc2", "但願來生，我能夠生於一戶三口之家，得享天倫…", 4, 16, 1},         

            {"BlackMsg", "不想紫軒姑娘的身世如此淒涼"},

            {"SetFubenProgress", -1, "聆聽二人對話"}, 
        },
        tbUnLockEvent = 
        {

        },
    },    
    [4] = {nTime = 1, nNum = 0,
        tbPrelock = {3},
        tbStartEvent = 
        {
            --杨影枫 
            --{"AddNpc", 1, 1, 1, "Npc1", "LoverRecall_Npc1_Pos1", false, 0, 0, 0, 0},              
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
            {"NpcBubbleTalk", "Npc2", "你、你們是誰！不要！不要靠近我！救命！", 4, 1, 1},

            --卓非凡
            {"AddNpc", 3, 1, 1, "Npc3", "LoverRecall_Npc1_Pos1", false, 0, 0, 0, 0},  
            --{"SetNpcProtected", "Npc3", 1},
            {"NpcBubbleTalk", "Npc3", "住手！光天化日之下欺淩弱女！你們這群武林敗類！", 4, 3, 1},

            {"BlackMsg", "原來是卓非凡救了她，因此紫軒姑娘才對她言聽計從吧"},               
        },
        tbUnLockEvent = 
        {   
            {"PlayEffect", 9005, 5963, 7552, 0, 1},
            {"DelNpc", "Npc2"},
            {"DelNpc", "Npc3"},
            {"BlackMsg", "卓非凡和紫軒姑娘的幻影忽然消失了"}, 
            {"SetFubenProgress", -1, "繼續前進"}, 
        },
    },   
    [6] = {nTime = 0, nNum = 1,
        tbPrelock = {5},
        tbStartEvent = 
        {
            --紫轩
            {"AddNpc", 1, 1, 1, "Npc2", "LoverRecall_Npc2_Pos2", false, 42, 0, 0, 0},

            --杨影枫 
            {"AddNpc", 2, 1, 1, "Npc1", "LoverRecall_Npc1_Pos2", false, 12, 0, 0, 0},

            {"TrapUnlock", "TrapLock2", 6},   
            
            {"SetTargetPos", 5500, 3100},
        },
        tbUnLockEvent = 
        {
            {"ClearTargetPos"},
            {"BlackMsg", "昔日紫軒聽命卓非凡，以美人計接近楊少俠，日久生情，傾心于楊少俠"}, 
            --设置Npc朝向
            --{"SetNpcDir", "Npc1", 0}
        },
    },
    [7] = {nTime = 35, nNum = 0,
        tbPrelock = {6},
        tbStartEvent = 
        {
            {"NpcBubbleTalk", "Npc2", "唉，公子，在你眼中，我便只是一件工具麼？", 4, 1, 1},
            {"NpcBubbleTalk", "Npc1", "方才的簫聲可是姑娘吹奏的嗎？為何如此淒涼？", 4, 4, 1}, 
            {"NpcBubbleTalk", "Npc2", "難道公子竟聽懂了我的蕭韻…？", 4, 8, 1},
            {"NpcBubbleTalk", "Npc1", "簫為心聲，在下魯鈍，但也聽出姑娘似乎有心事？", 4, 12, 1}, 
            {"NpcBubbleTalk", "Npc2", "（想不到……他……竟是我的知音……）", 4, 16, 1},
            {"NpcBubbleTalk", "Npc1", "是不是在下太冒昧了？", 4, 20, 1}, 
            {"NpcBubbleTalk", "Npc2", "不，公子，我适才只是想起自己的身世，一時感傷……", 4, 24, 1}, 
            {"NpcBubbleTalk", "Npc1", "原來在下無意之中觸動了姑娘的心事，惹得姑娘傷心，真是抱歉……", 4, 28, 1}, 
            {"NpcBubbleTalk", "Npc2", "（楊公子，若有機會，你會願意與我遠走高飛嗎？）", 4, 32, 1},              

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
    [8] = {nTime = 3, nNum = 0,
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
        },
    },    
    [9] = {nTime = 0, nNum = 1,
        tbPrelock = {8},
        tbStartEvent = 
        {
            {"SetTargetPos", 3000, 4500},

            {"TrapUnlock", "TrapLock3", 9},   

            {"SetFubenProgress", -1, "繼續前進"}, 
        },
        tbUnLockEvent = 
        {
            {"ClearTargetPos"},
        },
    },        
    [10] = {nTime = 20, nNum = 0,
        tbPrelock = {9},
        tbStartEvent = 
        {
            {"NpcBubbleTalk", "Npc2", "楊大哥，你還恨我嗎？", 4, 1, 1}, 
            {"NpcBubbleTalk", "Npc1", "紫軒，我已經原諒你了，你就不要再自責了，好嗎？", 4, 4, 1}, 
            {"NpcBubbleTalk", "Npc2", "楊大哥，你還愛我嗎？", 4, 9, 1}, 
            {"NpcBubbleTalk", "Npc1", "這個……紫軒……我……", 4, 14, 1},
            {"NpcBubbleTalk", "Npc2", "楊大哥，不用說了，我明白……", 4, 17, 1},

            {"SetFubenProgress", -1, "聆聽二人對話"}, 
        },
        tbUnLockEvent = 
        {

        },
    },    
    [11] = {nTime = 15, nNum = 0,
        tbPrelock = {10},
        tbStartEvent = 
        {
            {"NpcBubbleTalk", "Npc1", "紫軒！以前的事就不要再提了！", 4, 1, 1},   --Npc2已经挂了，这句执行不到
            {"NpcBubbleTalk", "Npc2", "謝謝你，楊大哥…以後我們再也不分開了…", 4, 6, 1},
            {"NpcBubbleTalk", "Npc1", "紫軒，此生此世，我們再也不分開了！", 4, 11, 1},   --Npc2已经挂了，这句执行不到
        },
        tbUnLockEvent = 
        {

        },
    },   
    [12] = {nTime = 5, nNum = 0,
        tbPrelock = {11},
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