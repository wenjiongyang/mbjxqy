Require("CommonScript/Activity/LoverRecallActC.lua");
local tbAct = Activity:GetClass("LoverRecallAct")
local tbFubenSetting = {};
local nMapTemplateId = 1615

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
    [1] = {nTemplate = 2293, nLevel = -1, nSeries = 0},  --张琳心
    [2] = {nTemplate = 2292, nLevel = -1, nSeries = 0},  --独孤剑
    [3] = {nTemplate = 746, nLevel = -1, nSeries = 0},  --银丝草
    [4] = {nTemplate = 1700, nLevel = -1, nSeries = 0},  --采花贼
    [5] = {nTemplate = 1701, nLevel = -1, nSeries = 0},  --采花贼精英
    [6] = {nTemplate = 851, nLevel = -1, nSeries = 0},  --采花贼头目         
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
            {"BlackMsg", "這是…心魔幻境？不知獨孤大俠與張姑娘在哪！去前方看看！"},
        },
    },
    [2] = {nTime = 0, nNum = 1,
        tbPrelock = {1},
        tbStartEvent = 
        {          
            --张琳心 
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
    [3] = {nTime = 6, nNum = 0,
        tbPrelock = {2},
        tbStartEvent = 
        {
            --纳兰真 
            --{"AddNpc", 1, 1, 1, "Npc2", "LoverRecall_Npc2_Pos1", false, 0, 0, 0, 0},


            {"NpcBubbleTalk", "Npc2", "可惡，想不到我竟會落在這麼一群小賊的手上…", 4, 1, 1},
            --独孤剑 
            {"AddNpc", 2, 1, 1, "Npc1", "LoverRecall_Npc1_Pos1", false, 28, 0, 0, 0},
            --{"SetNpcProtected", "Npc1", 1},
            {"NpcBubbleTalk", "Npc1", "姑娘！張姑娘！你沒事吧？", 4, 3, 1},    

            {"BlackMsg", "張姑娘一時不慎，落入採花賊之手，是獨孤少俠拼死相救才得以倖免"},
        },
        tbUnLockEvent = 
        {

        },
    },    
    [4] = {nTime = 0, nNum = 12,
        tbPrelock = {3},
        tbStartEvent = 
        {
            --刷怪
            {"AddNpc", 4, 8, 4, "guaiwu1", "guaiwu1_pos", 1, 0, 0, 0, 0},
            {"AddNpc", 5, 3, 4, "guaiwu1", "guaiwu2_pos", 1, 0, 0, 0, 0},
            {"AddNpc", 6, 1, 4, "guaiwu1", "guaiwu3_pos", 1, 0, 0, 0, 0},

            --纳兰真
            {"NpcBubbleTalk", "Npc1", "竟有這麼多埋伏！即使拼了這條命也得護張姑娘周全！", 4, 1, 1},

            {"BlackMsg", "前方忽然出現了大批的採花賊！幫幫獨孤少俠！"},               
        },
        tbUnLockEvent = 
        {   
            {"PlayEffect", 9005, 5963, 7552, 0, 1},
            {"DelNpc", "Npc2"},
            {"DelNpc", "Npc1"},
            {"BlackMsg", "獨孤少俠和張姑娘的幻影忽然消失了"}, 
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
            {"SetFubenProgress", -1, "繼續前進"},             
            {"SetTargetPos", 5500, 3100},
        },
        tbUnLockEvent = 
        {
            {"ClearTargetPos"},
            {"BlackMsg", "獨孤少俠真俠義！想必張姑娘是因此才對他產生好感！"}, 
            --设置Npc朝向
            --{"SetNpcDir", "Npc1", 0}
        },
    },
    [6] = {nTime = 30, nNum = 0,
        tbPrelock = {5},
        tbStartEvent = 
        {
            {"NpcBubbleTalk", "Npc2", "獨孤雲？我聽我爹每次提起他，都是一臉敬重的神色，仿佛是個很了不起的人物", 4, 1, 1},
            {"NpcBubbleTalk", "Npc1", "真的嗎？你爹倒是一個識英雄重英雄的人！敢問你爹是誰？", 4, 6, 1},
            {"NpcBubbleTalk", "Npc2", "我爹就是當今殿前都指揮使張風張大人！", 4, 11, 1},
            {"NpcBubbleTalk", "Npc1", "什麼？！你……你是張風的女兒！就是你爹“飛劍客”，害死了我的父親！", 4, 16, 1}, 
            {"NpcBubbleTalk", "Npc2", "不！這不可能！你、你是不是後悔救了我——你殺父仇人的女兒？", 4, 21, 1},
            {"NpcBubbleTalk", "Npc1", "我後悔……認識了你……", 4, 26, 1}, 
            {"NpcBubbleTalk", "Npc2", "（獨孤大哥，你說這話的時候可知道，那比你後悔救我更令人心痛…）", 4, 26, 1},   
            {"BlackMsg", "獨孤少俠救下張姑娘時，發現她竟是殺父仇人之女，初嘗甜蜜卻又令人痛苦"},

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

            {"SetFubenProgress", -1, "繼續前進"}, 
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
            {"NpcBubbleTalk", "Npc2", "獨孤哥哥！", 4, 1, 1}, 
            {"NpcBubbleTalk", "Npc1", "原來你並沒有死！這真是太好了，太好了！", 4, 6, 1}, 
            {"NpcBubbleTalk", "Npc2", "獨孤哥哥，全靠真正的方勉大俠。琳兒便是為他所救，我們再也不會分開了……", 4, 11, 1}, 
            {"NpcBubbleTalk", "Npc1", "我們再也不分開了！", 4, 16, 1},

            {"BlackMsg", "張姑娘曾墜落山崖，其時獨孤大俠生不如死，所幸蒼天有眼，兩人得以重逢"},

            {"SetFubenProgress", -1, "聆聽二人對話"}, 
        },
        tbUnLockEvent = 
        {

        },
    },    
    [10] = {nTime = 5, nNum = 0,
        tbPrelock = {9},
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