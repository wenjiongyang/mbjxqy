Require("CommonScript/Activity/LoverRecallActC.lua");
local tbAct = Activity:GetClass("LoverRecallAct")
local tbFubenSetting = {};
local nMapTemplateId = 1614

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
    [1] = {nTemplate = 2291, nLevel = -1, nSeries = 0},  --蔷薇
    [2] = {nTemplate = 2287, nLevel = -1, nSeries = 0},  --杨影枫
    [3] = {nTemplate = 746, nLevel = -1, nSeries = 0},  --银丝草
    [4] = {nTemplate = 829, nLevel = -1, nSeries = 0},  --飞龙堡弟子
    [5] = {nTemplate = 830, nLevel = -1, nSeries = 0},  --飞龙堡护法
    [6] = {nTemplate = 830, nLevel = -1, nSeries = 0},  --飞龙堡头目         
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
            {"BlackMsg", "這是…心魔幻境？不知楊少俠與薔薇姑娘在哪！去前方看看！"},
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

            {"NpcBubbleTalk", "Npc2", "（怎麼辦怎麼辦，爹爹這回是無論如何也找不到我了）", 4, 1, 1},
            {"NpcBubbleTalk", "Npc2", "（完了完了，這下子可真的死定了，都怪我到處亂跑）", 4, 6, 1},
            {"NpcBubbleTalk", "Npc2", "嗚嗚嗚嗚嗚…（我寧可死也不能讓他們糟蹋！）", 4, 11, 1},
            {"NpcBubbleTalk", "Npc2", "（還有楊大哥…你現在在哪裡…楊大哥…）", 4, 16, 1},  
        },
        tbUnLockEvent = 
        {

        },
    },    
    [4] = {nTime = 3, nNum = 0,
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

            --杨影枫 
            {"AddNpc", 2, 1, 1, "Npc1", "LoverRecall_Npc1_Pos1", false, 0, 0, 0, 0},
            --{"SetNpcProtected", "Npc1", 1},
            {"NpcBubbleTalk", "Npc1", "住手！", 4, 3, 1},

            {"BlackMsg", "薔薇姑娘為強人所擄，險些受辱，所幸楊少俠出現救了她"},               
        },
        tbUnLockEvent = 
        {   
            {"PlayEffect", 9005, 5963, 7552, 0, 1},
            {"DelNpc", "Npc2"},
            {"DelNpc", "Npc1"},
            {"BlackMsg", "楊少俠和薔薇姑娘的幻影忽然消失了"}, 
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
            {"BlackMsg", "薔薇姑娘第一次見楊少俠，還刁難了一番，真是不是冤家不聚頭"}, 
            --设置Npc朝向
            --{"SetNpcDir", "Npc1", 0}
        },
    },
    [7] = {nTime = 43, nNum = 0,
        tbPrelock = {6},
        tbStartEvent = 
        {
            {"NpcBubbleTalk", "Npc2", "看你身負長劍，又如此好管閒事，身手應當不凡，姑娘近日新學了一些武功，就拿你先試試招罷！", 4, 1, 1},
            {"NpcBubbleTalk", "Npc1", "在下無意冒犯姑娘……", 4, 4, 1},
            {"NpcBubbleTalk", "Npc2", "看不出你還有兩下子嘛！我本來住在山腳下。上山來打獵，現在迷路了。你送我回家好不好？", 4, 8, 1},
            {"NpcBubbleTalk", "Npc1", "姑娘，我們已走了許久，你家住在……？", 4, 12, 1}, 
            {"NpcBubbleTalk", "Npc2", "哎呀，我的發釵掉了，如果你幫我找回來，我就跟你回去！", 4, 16, 1},
            {"NpcBubbleTalk", "Npc1", "一言為定！", 4, 20, 1}, 
            {"NpcBubbleTalk", "Npc2", "天池水奇寒徹骨，還生活著一種食人魚。在水裡即使不被食人魚吃掉，也會因受不住陰寒而凍死！", 4, 24, 1},   
            {"NpcBubbleTalk", "Npc1", "天下之大真是無奇不有！人吃魚不過尋常事，魚吃人當真稀罕！我定要親眼看看！", 4, 28, 1}, 
            {"NpcBubbleTalk", "Npc1", "請問姑娘是不是這枚……？", 4, 32, 1}, 
            {"NpcBubbleTalk", "Npc2", "為什麼要下去？若非你功力深厚…唉，沒見過你這樣的人！從小大家都說我任性，沒人陪我玩，只有你不一樣…", 4, 36, 1}, 
            {"NpcBubbleTalk", "Npc2", "你這個人真有意思！好，我們回去罷！", 4, 40, 1}, 

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
    [10] = {nTime = 14, nNum = 0,
        tbPrelock = {9},
        tbStartEvent = 
        {
            {"NpcBubbleTalk", "Npc2", "影楓哥……只要能和你在一起，去哪裡都行", 4, 1, 1}, 
            {"NpcBubbleTalk", "Npc1", "薇兒，我們以後不管去哪都在一起，再也不分開了", 4, 6, 1}, 
            {"NpcBubbleTalk", "Npc2", "嗯，影楓哥，我們再也不分開了", 4, 11, 1}, 

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