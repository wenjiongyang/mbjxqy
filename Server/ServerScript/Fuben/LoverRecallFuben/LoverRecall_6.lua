Require("CommonScript/Activity/LoverRecallActC.lua");
local tbAct = Activity:GetClass("LoverRecallAct")
local tbFubenSetting = {};
local nMapTemplateId = 1616

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
    [1] = {nTemplate = 2294, nLevel = -1, nSeries = 0},  --杨瑛
    [2] = {nTemplate = 2292, nLevel = -1, nSeries = 0},  --独孤剑
    [3] = {nTemplate = 746, nLevel = -1, nSeries = 0},  --银丝草
    [4] = {nTemplate = 1687, nLevel = -1, nSeries = 0},  --飞龙堡弟子
    [5] = {nTemplate = 1688, nLevel = -1, nSeries = 0},  --飞龙堡护法
    [6] = {nTemplate = 1689, nLevel = -1, nSeries = 0},  --飞龙堡头目         
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
            {"BlackMsg", "這是…心魔幻境？不知獨孤少俠與楊姑娘在哪！去前方看看！"},
        },
    },
    [2] = {nTime = 0, nNum = 1,
        tbPrelock = {1},
        tbStartEvent = 
        {
            --杨影枫 
            {"AddNpc", 2, 1, 1, "Npc1", "LoverRecall_Npc1_Pos1", false, 28, 0, 0, 0},
            --{"SetNpcProtected", "Npc1", 1},
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

            {"NpcBubbleTalk", "Npc2", "多年來我隱藏身份，唯恐弟兄知道帶著他們冒性命之危闖蕩江湖的，竟是弱質女流…", 4, 1, 1},
            {"NpcBubbleTalk", "Npc1", "幫主雖然是女子，但膽識過人，顧識大體，沒有你，就不會有如今的天王幫", 4, 6, 1},
            {"NpcBubbleTalk", "Npc2", "獨孤公子，我不願將圖交給嶽飛，但是我欠你一個人情，既然你要，那我就交給公子", 4, 11, 1},
            {"NpcBubbleTalk", "Npc1", "幫主…（此情此義，卻又讓我如何報答…）", 4, 16, 1},         

            {"BlackMsg", "獨孤少俠剛發現楊姑娘的女兒身，其實當時楊姑娘已對獨孤少俠懷有情意"},

            {"SetFubenProgress", -1, "聆聽二人對話"}, 
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
            {"NpcBubbleTalk", "Npc2", "是你！封左使！原來你早就包藏禍心，一直監視我的行蹤！", 4, 1, 1},

            {"BlackMsg", "前方忽然出現了大批的天王叛徒！幫幫楊姑娘與獨孤少俠！"},               
        },
        tbUnLockEvent = 
        {   
            {"PlayEffect", 9005, 5963, 7552, 0, 1},
            {"DelNpc", "Npc2"},
            {"DelNpc", "Npc1"},
            {"BlackMsg", "楊姑娘與獨孤少俠的幻影忽然消失了"}, 
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

            {"SetFubenProgress", -1, "繼續前進"}, 
        },
        tbUnLockEvent = 
        {
            {"BlackMsg", "那時獨孤少俠方得知，其實這已經不是他們第一次見面了"}, 
            --设置Npc朝向
            --{"SetNpcDir", "Npc1", 0}
            {"ClearTargetPos"},
        },
    },
    [6] = {nTime = 30, nNum = 0,
        tbPrelock = {5},
        tbStartEvent = 
        {
            {"NpcBubbleTalk", "Npc1", "可惜讓他跑了！楊……姑娘，原來，一直暗中幫助我的人是你……", 4, 1, 1},
            {"NpcBubbleTalk", "Npc2", "獨孤大哥，我可以這樣叫你嗎？碧霞島上的局是我安排的，為了山河社稷圖", 4, 6, 1},
            {"NpcBubbleTalk", "Npc2", "整個事情都在我的計畫之中，但是我卻沒有預料到會遇上你……", 4, 10, 1},
            {"NpcBubbleTalk", "Npc2", "你先別說話，獨孤大哥，自從碧霞島一別後，楊瑛，就已經不再是以前的楊瑛了", 4, 15, 1}, 
            {"NpcBubbleTalk", "Npc2", "獨孤大哥，我明白，你和那位張姑娘情投意合，我……是不會讓你為難的", 4, 21, 1},
            {"NpcBubbleTalk", "Npc2", "上天真是愛捉弄人！我最恨的人，偏偏是一個大英雄，我最…的人，偏偏又情有所屬…", 4, 26, 1}, 
            {"NpcBubbleTalk", "Npc1", "楊姑娘，你一定會遇上一個比我好千百倍的人……", 4, 26, 1},   

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
    [9] = {nTime = 18, nNum = 0,
        tbPrelock = {8},
        tbStartEvent = 
        {
            {"NpcBubbleTalk", "Npc2", "獨孤大哥！", 4, 1, 1}, 
            {"NpcBubbleTalk", "Npc1", "……", 4, 5, 1}, 
            {"NpcBubbleTalk", "Npc2", "好風成意秋正濃，紙鳶迭做卻難升。天意從來高難問，總把雲霞晚鷺分……", 4, 10, 1},
            {"NpcBubbleTalk", "Npc1", "阿瑛……", 4, 15, 1}, 

            {"SetFubenProgress", -1, "聆聽二人對話"}, 
        },
        tbUnLockEvent = 
        {

        },
    },  
    [10] = {nTime = 13, nNum = 0,
        tbPrelock = {9},
        tbStartEvent = 
        {
            {"NpcBubbleTalk", "Npc1", "泰山武林大會？還是讓年輕人去吧", 4, 1, 1}, 
            {"NpcBubbleTalk", "Npc2", "劍哥，灩心年紀尚小，不會有什麼事吧？", 4, 5, 1},
            {"NpcBubbleTalk", "Npc1", "阿瑛，不必擔心，她的武功足以自保，我們也該逍遙自在了", 4, 10, 1}, 

            {"BlackMsg", "光陰轉瞬即逝……眨眼來到了十年後……"},
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