Require("ServerScript/Fuben/WhiteTigerFuben.lua")

local tbFubenSetting = {};
local nMapTemplateId = Fuben.WhiteTigerFuben.OUTSIDE_MAPID
local nPrepareTime   = Fuben.WhiteTigerFuben.PREPARE_TIME --准备时间
local nFirstBoss     = Fuben.WhiteTigerFuben.BOSS_START[1] --第一个boss时间
Fuben:SetFubenSetting(nMapTemplateId, tbFubenSetting)      -- 绑定副本内容和地图

tbFubenSetting.szFubenClass   = "WhiteTigerFubenBase";                                  -- 副本类型
tbFubenSetting.szName         = Fuben.WhiteTigerFuben.ACTIVITY_NAME                  -- 单纯的名字，后台输出或统计使用
tbFubenSetting.szNpcPointFile = "Setting/Fuben/WhiteTigerFuben/NpcPos1.tab"          -- NPC点

-- ID可以随便 普通副本NPC数量 ；精英模式NPC数量
tbFubenSetting.NUM = 
{
    NpcIndex1       = {1, 1},
    NpcIndex2       = {2, 2},
    NpcIndex3       = {3, 3},
    NpcIndex4       = {4, 4},
    NpcIndex5       = {5, 5},
    NpcIndex6       = {6, 6},
    NpcIndex7       = {7, 7},
    NpcIndex8       = {8, 8},
    NpcIndex9       = {9, 9},
    NpcNum1         = {1, 1},
    NpcNum2         = {2, 2},
    NpcNum3         = {3, 3},
    NpcNum4         = {4, 4},
    NpcNum5         = {5, 5},
    NpcNum6         = {6, 6},
    NpcNum7         = {7, 7},
}

tbFubenSetting.ANIMATION = 
{
    [1] = "Scenes/camera/Main Camera.controller",
}

--NPC模版ID，NPC等级，NPC五行；
--[[


]]

tbFubenSetting.NPC = 
{
    [1] = {nTemplate = 931,  nLevel = -1, nSeries = -1, nReviveFrame = 60},
    [2] = {nTemplate = 932,  nLevel = -1, nSeries = -1},
    [3] = {nTemplate = 73,   nLevel = -1, nSeries = -1},
	[4] = {nTemplate = 104,  nLevel = -1, nSeries = -1},
	[100] = {nTemplate = 1304,  nLevel = -1, nSeries = -1},
}

tbFubenSetting.LOCK = 
{
    -- 1号锁不能不填，默认1号为起始锁，nTime是到时间自动解锁，nNum表示需要解锁的次数，如填3表示需要被解锁3次才算真正解锁，可以配置字符串
    [1] = {nTime = 1, nNum = 0,
        --tbPrelock 前置锁，激活锁的必要条件{1 , 2, {3, 4}}，代表1和2号必须解锁，3和4任意解锁一个即可
        tbPrelock = {},
        --tbStartEvent 锁激活时的事件
        tbStartEvent = 
        {
        },
        --tbStartEvent 锁解开时的事件
        tbUnLockEvent = 
        {
            {"SetShowTime", 7},    
            {"ChangeFightState", 1},      
            {"SetFubenProgress", -1, "等待開啟"},  
			{"AddNpc", 100, 1, 0, "gouhuo", "gouhuo", false, 0},
			{"AddNpc", "NpcIndex4", "NpcNum1", 0, "wall", "wall_1", false, 16},
        },
    },
    [2] = {nTime = nPrepareTime, nNum = 0,
        tbPrelock = {1},
        tbStartEvent = 
        {    
           
        },
        tbUnLockEvent = 
        {
			{"BlackMsg", "白虎堂開啟"},  
			{"DelNpc", "gouhuo"},
            {"AddNpc", "NpcIndex1", 20, 2, "guaiwu", "WhiteTiger_1", false, 0, 0, 9005, 0.5},
			{"SetFubenProgress", -1, "等待開啟PK模式"},  
        },
    },
	[3] = {nTime = nFirstBoss, nNum = 0,
        tbPrelock = {1},
        tbStartEvent = 
        {
                                
        },
        tbUnLockEvent = 
        {
             {"AddNpc", 2, 1, 4, "BOSS", "WhiteTiger_2",false, 0 , 1, 9011, 1, 1}, 
			 {"SetFubenProgress", -1, "擊敗一層頭目"},  
        },
    },
	
    [4] = {nTime = 0, nNum = 1,
        tbPrelock = {3},
        tbStartEvent = 
        {                
            
			 
        },
        tbUnLockEvent = 
        {
			{"SetTargetPos", 3625, 1990},
			{"AddNpc", 3, 1, 0, "GotoNext", "GotoNext", false, 0},  
			{"SetFubenProgress", -1, "進入白虎堂二層"},  
			{"BlackMsg", "入口打開，可進入白虎堂二層"}, 
            {"RaiseEvent", "BossDeath"},
			{"DelNpc", "wall"},
            {"DelNpc", "guaiwu"},
        },
    },
    [7] = {nTime = 30*60, nNum = 0,
        tbPrelock = {1},
        tbStartEvent = 
        {
        },
        tbUnLockEvent = 
        {
            {"BlackMsg", "時間耗盡，本次活動結束！"},
            {"SetFubenProgress", -1, "離開白虎堂"}, 
            {"GameLost"},
        },
    },
}