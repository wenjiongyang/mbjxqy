Require("ServerScript/Fuben/SpokespersonFuben/ActivityFubenBase.lua")
local tbFubenSetting = Fuben.ActivityFuben:GetFubenSetting("SpokespersonFuben_1")
local nMapTemplateId = 1618

Fuben:SetFubenSetting(nMapTemplateId, tbFubenSetting)   -- 绑定副本内容和地图

tbFubenSetting.szNpcPointFile           = "Setting/Fuben/SpokespersonFuben/NpcPos.tab"         -- NPC点
tbFubenSetting.szPathFile               = "Setting/Fuben/SpokespersonFuben/NpcPath.tab"        -- 寻路点

tbFubenSetting.szName         = "心魔幻境"                                             -- 单纯的名字，后台输出或统计使用
tbFubenSetting.tbBeginPoint   = {1196, 1423}  
tbFubenSetting.tbTempRevivePoint = {1196, 1423}  


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
    [1] = {nTemplate = 2309, nLevel = -1, nSeries = 0},  --小怪1
    [2] = {nTemplate = 2310, nLevel = -1, nSeries = 0},  --小怪2
    [3] = {nTemplate = 2311, nLevel = -1, nSeries = 0},  --采集
    [4] = {nTemplate  = 74,  nLevel = -1,   nSeries = 0}, --上升气流
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
            {"SetKickoutPlayerDealyTime", 20},            

            {"SetFubenProgress", -1, "四處探索"},             
        },
        --tbStartEvent 锁解开时的事件
        tbUnLockEvent = 
        {            
            {"SetTargetPos", 1988, 2287},
        },
    },
    [2] = {nTime = 0, nNum = 1,
        tbPrelock = {1},
        tbStartEvent = 
        {
            {"OpenWindow", "LingJueFengLayerPanel", "Info", 3, 9, "幽泉石穀"},

            {"TrapUnlock", "TrapLock1", 2},        
            {"PlayerBubbleTalk", "這兒的風景真不錯，我們到處走走散散心吧！"},
        },
        tbUnLockEvent = 
        {
            {"ClearTargetPos"},
            {"SetFubenProgress", -1, "四處探索"}, 

            {"BlackMsg", "風光正好，俠士何不上前欣賞一番？"},
            {"OpenDynamicObstacle", "ops1"},
            {"OpenDynamicObstacle", "ops2"},
            {"OpenDynamicObstacle", "ops3"},

             {"SetTargetPos", 2027, 5353},
        },
    },
    [3] = {nTime = 0, nNum = 1,
        tbPrelock = {2},
        tbStartEvent = 
        {
            {"TrapUnlock", "TrapLock2", 3},      
        },
        tbUnLockEvent = 
        {
            {"ClearTargetPos"},
        },
    },
    [4] = {nTime = 0, nNum = 12,
        tbPrelock = {3},
        tbStartEvent = 
        {
             {"SetFubenProgress", -1, "擊敗敵人"}, 

            --刷怪
            {"AddNpc", 1, 6, 4, "guaiwu1", "Fuben_1_guaiwu_1", 1, 0, 0, 0, 0},
            {"AddNpc", 2, 6, 4, "guaiwu2", "Fuben_1_guaiwu_1", 1, 0, 1, 0, 0},


            {"NpcBubbleTalk", "guaiwu1", "站住！此路不通，若想活命，往後退！", 3, 1, 2},    
            {"NpcBubbleTalk", "guaiwu2", "多說什麼！為防節外生枝！幹掉他們！", 3, 2, 2},  
            {"StartTimeCycle", "cycle_1", 3, 1, {"PlayerBubbleTalk", "這些人蠻不講理！我們教訓教訓他們！"}},
            {"BlackMsg", "忽然出現了一批賊匪，看來是埋伏已久"},               
        },
        tbUnLockEvent = 
        {   
            {"PlayerBubbleTalk", "這些人鬼鬼祟祟的准沒好事，我們到前面看看"},

            {"BlackMsg", "繼續往前方前進"}, 
            {"SetFubenProgress", -1, "繼續前進"}, 
            {"SetTargetPos", 5059, 5531},
        },
    },   
    [5] = {nTime = 0, nNum = 1,
        tbPrelock = {4},
        tbStartEvent = 
        {
            {"TrapUnlock", "TrapLock3", 5},   
        },
        tbUnLockEvent = 
        {
            {"ClearTargetPos"},
            {"SetFubenProgress", -1, "擊敗敵人"}, 
        },
    },
    [6] = {nTime = 0, nNum = 12,
        tbPrelock = {5},
        tbStartEvent = 
        {
            --刷怪
            {"AddNpc", 1, 6, 6, "guaiwu3", "Fuben_1_guaiwu_2", 1, 0, 0, 0, 0},
            {"AddNpc", 2, 6, 6, "guaiwu4", "Fuben_1_guaiwu_2", 1, 0, 1, 0, 0},

            {"BlackMsg", "果不其然再度遇見他們"},     

            {"NpcBubbleTalk", "guaiwu3", "你們是誰！如何闖過前面弟兄布下的防線的？", 3, 1, 2},    
            {"NpcBubbleTalk", "guaiwu4", "看來消息暴露了！幹掉他們！", 3, 2, 2},  
            {"StartTimeCycle", "cycle_1", 3, 1, {"PlayerBubbleTalk", "莫名其妙，真以為我們怕你了不成？"}},
        },
        tbUnLockEvent = 
        {
            {"SetFubenProgress", -1, "繼續前進"},  
            {"SetTargetPos", 4561, 4646},
       },
    },
    [7] = {nTime = 0, nNum = 1,
        tbPrelock = {6},
        tbStartEvent = 
        {
            {"AddNpc", 4, 1, 0, "QiLiu", "QiLiu", 1},           
            {"ChangeTrap", "Jump1", nil, {3983, 4058}},
            {"ChangeTrap", "Jump2", nil, {3170, 3798}}, 
            {"ChangeTrap", "Jump3", nil, {3998, 2517}}, 
            {"TrapUnlock", "Jump1", 7},

            {"PlayerBubbleTalk", "好久未曾與你比試了，嘿嘿，不如比比輕功？"},
        },
            tbUnLockEvent = 
        {
            {"ClearTargetPos"},         
        },
    },
    [8] = {nTime = 0, nNum = 1,
        tbPrelock = {7},
        tbStartEvent = 
        {
            {"TrapUnlock", "TrapLock5", 8},
        },
        tbUnLockEvent = 
        {
            {"SetTargetPos", 4826, 2237},   
            {"CloseLock", 200},     
        },
    },
    --跳崖保护
    [200] = {nTime = 4, nNum = 0,
        tbPrelock = {7},
        tbStartEvent = 
        {
        },
        tbUnLockEvent = 
        {
            {"SetPos", 3998, 2517},
        },
    },
    [9] = {nTime = 0, nNum = 1,
        tbPrelock = {8},
        tbStartEvent = 
        {
            {"TrapUnlock", "TrapLock4", 9},
        },
            tbUnLockEvent = 
        {
            {"ClearTargetPos"},
        },
    },
    [10] = {nTime = 0, nNum = 1,
        tbPrelock = {9},
        tbStartEvent = 
        {
            --刷怪
            {"AddNpc", 3, 1, 10, "BaoXiang", "BaoXiang", 1, 0, 0, 0, 0},

            {"BlackMsg", "前方似乎有一柄斑駁的古劍，去看看怎麼回事"},     

            {"PlayerBubbleTalk", "這柄劍…看來頗有年月，一時間無法辨認，先取走吧！"},
        },
        tbUnLockEvent = 
        {
            {"PlayerBubbleTalk", "咦，古劍中似乎另藏它物，得去問問此劍的來歷"},

            {"SetFubenProgress", -1, "離開此處"}, 
            {"BlackMsg", "似乎沒有什麼只得探索的了"},
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