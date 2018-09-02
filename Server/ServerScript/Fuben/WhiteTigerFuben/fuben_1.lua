Require("ServerScript/Fuben/WhiteTigerFuben.lua")

local tbFubenSetting = {};
local nMapTemplateId = Fuben.WhiteTigerFuben.FIGHT_MAPID
local nPrepareTime   = Fuben.WhiteTigerFuben.PREPARE_TIME --准备时间
local tbBossTime     = Fuben.WhiteTigerFuben.BOSS_START --boss刷新时间
Fuben:SetFubenSetting(nMapTemplateId, tbFubenSetting)      -- 绑定副本内容和地图

tbFubenSetting.szFubenClass   = "WhiteTigerFubenBase";                                  -- 副本类型
tbFubenSetting.szName         = Fuben.WhiteTigerFuben.ACTIVITY_NAME                  -- 单纯的名字，后台输出或统计使用
tbFubenSetting.szNpcPointFile = "Setting/Fuben/WhiteTigerFuben/NpcPos.tab"          -- NPC点

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
    [1] = {nTemplate = 709,  nLevel = -1, nSeries = -1, nReviveFrame = 60},
    [2] = {nTemplate = 710,  nLevel = -1, nSeries = -1, nReviveFrame = 60},
    [3] = {nTemplate = 711,  nLevel = -1, nSeries = -1, nReviveFrame = 60},
    [4] = {nTemplate = 712,  nLevel = -1, nSeries = -1},
    [5] = {nTemplate = 713,  nLevel = -1, nSeries = -1},
    [6] = {nTemplate = 714,  nLevel = -1, nSeries = -1},   
    [7] = {nTemplate = 104,  nLevel = -1, nSeries = -1},
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
        },
        --tbStartEvent 锁解开时的事件
        tbUnLockEvent = 
        {
            {"SetShowTime", 10},    
            {"ChangeFightState", 1},
        },
    },
    [2] = {nTime = 0, nNum = 0,
        tbPrelock = {1},
        tbStartEvent = 
        {    
            {"AddNpc", "NpcIndex1", 20, 2, "guaiwu1_1", "Lv1_1", false, 0, 0, 9005, 0},
			{"AddNpc", "NpcIndex1", 20, 2, "guaiwu1_2", "Lv1_2", false, 0, 0, 9005, 0},
			{"AddNpc", "NpcIndex1", 20, 2, "guaiwu1_3", "Lv1_3", false, 0, 0, 9005, 0},
			{"AddNpc", "NpcIndex1", 20, 2, "guaiwu1_4", "Lv1_4", false, 0, 0, 9005, 0},
			
			{"AddNpc", "NpcIndex2", 20, 2, "guaiwu2_1", "Lv2_1", false, 0, 0, 9005, 0},
			{"AddNpc", "NpcIndex2", 20, 2, "guaiwu2_2", "Lv2_2", false, 0, 0, 9005, 0},
			
			{"AddNpc", "NpcIndex3", 20, 2, "guaiwu3", "Lv3", false, 0, 0, 9005, 0},
			

            {"AddNpc", "NpcIndex7", "NpcNum2", 3, "wall_Lv1_1", "wall_1_1", false, 32},
			{"AddNpc", "NpcIndex7", "NpcNum2", 3, "wall_Lv1_1", "wall_1_2", false, 16},
			
            {"AddNpc", "NpcIndex7", "NpcNum2", 3, "wall_Lv1_2", "wall_2_1", false, 16},
			{"AddNpc", "NpcIndex7", "NpcNum2", 3, "wall_Lv1_2", "wall_2_2", false, 16},
			
            {"AddNpc", "NpcIndex7", "NpcNum2", 3, "wall_Lv1_3", "wall_3_1", false, 32},
			{"AddNpc", "NpcIndex7", "NpcNum2", 3, "wall_Lv1_3", "wall_3_2", false, 16},
					
            {"AddNpc", "NpcIndex7", "NpcNum2", 3, "wall_Lv1_4", "wall_4_1", false, 32},
			{"AddNpc", "NpcIndex7", "NpcNum2", 3, "wall_Lv1_4", "wall_4_2", false, 16},
			
			{"AddNpc", "NpcIndex7", "NpcNum4", 3, "wall_Lv2_1", "wall_5", false, 32},
			{"AddNpc", "NpcIndex7", "NpcNum4", 3, "wall_Lv2_2", "wall_6", false, 32}, 		
        },
        tbUnLockEvent = 
        {
        },
    },
	[3] = {nTime = tbBossTime[2], nNum = 0,
        tbPrelock = {1},
        tbStartEvent = 
        {                 
        },
        tbUnLockEvent = 
        { 
			{"BlackMsg", "二層頭目出現！"}, 		
        },
    },
	
    [4] = {nTime = 0, nNum = 1,
        tbPrelock = {3},
        tbStartEvent = 
        {                
            --Boss附带两个参数，第一个是第几层，第二个是房间索引(第一层可以不带)
            {"AddNpc", 4, 1, 4, "BOSS", "Lv1_1_Boss",false, 0 , 1, 9011, 1, 2, 1}, 
            {"RaiseEvent", "ChangeRoomState", 2, 1, "擊敗二層頭目"},
        },
        tbUnLockEvent = 
        {
            {"DoDeath", "wall_Lv1_1"},
			{"DelNpc", "guaiwu1_1"},
            {"OpenDynamicObstacle", "ops1"},
            {"RaiseEvent", "ChangeRoomState", 2, 1, "前往下一層", true, 5370, 8213},
			{"BatchPlaySceneAnimation", "jz_mendonghua0", 5, 6, "wind", 0.5, true},
        },
    },
    [5] = {nTime = 0, nNum = 1,
        tbPrelock = {3},
        tbStartEvent = 
        {    
            {"AddNpc", 4, 1, 5, "BOSS", "Lv1_2_Boss",false, 0 , 1, 9011, 1, 2, 2},                      
            {"RaiseEvent", "ChangeRoomState", 2, 2, "擊敗二層頭目"},
        },
        tbUnLockEvent = 
        {
            {"DoDeath", "wall_Lv1_2"},
            {"DelNpc", "guaiwu1_2"},
            {"OpenDynamicObstacle", "ops2"},
            {"RaiseEvent", "ChangeRoomState", 2, 2, "前往下一層", true, 5831, 13505},
			{"BatchPlaySceneAnimation", "jz_mendonghua0", 7, 8, "wind", 0.5, true},
        },
    },
    [6] = {nTime = 0, nNum = 1,
        tbPrelock = {3},
        tbStartEvent = 
        {    
            {"AddNpc", 4, 1, 6, "BOSS", "Lv1_3_Boss",false, 0 , 1, 9011, 1, 2, 3},                      
            {"RaiseEvent", "ChangeRoomState", 2, 3, "擊敗二層頭目"},
        },
        tbUnLockEvent = 
        {
            {"DoDeath", "wall_Lv1_3"},
            {"DelNpc", "guaiwu1_3"},
            {"OpenDynamicObstacle", "ops3"},
            {"RaiseEvent", "ChangeRoomState", 2, 3, "前往下一層", true, 13966, 10155},
			{"BatchPlaySceneAnimation", "jz_mendonghua0", 3, 4, "wind", 0.5, true},
        },
    },
    [7] = {nTime = 0, nNum = 1,
        tbPrelock = {3},
        tbStartEvent = 
        {    
            {"AddNpc", 4, 1, 7, "BOSS", "Lv1_4_Boss",false, 0 , 1, 9011, 1, 2, 4},                      
            {"RaiseEvent", "ChangeRoomState", 2, 4, "擊敗二層頭目"},
        },
        tbUnLockEvent = 
        {
            {"DoDeath", "wall_Lv1_4"},
            {"OpenDynamicObstacle", "ops4"},
            {"DelNpc", "guaiwu1_4"},
            {"RaiseEvent", "ChangeRoomState", 2, 4, "前往下一層", true, 13904, 5556},
			{"BatchPlaySceneAnimation", "jz_mendonghua0", 1, 2, "wind", 0.5, true},
        },
    },
    [8] = {nTime = tbBossTime[3], nNum = 0,
        tbPrelock = {1},
        tbStartEvent = 
        {                
     
        },
        tbUnLockEvent = 
        {          
            {"BlackMsg", "三層頭目出現！"}, 
        },
    },
    [9] = {nTime = 0, nNum = 1,
        tbPrelock = {8},
        tbStartEvent = 
        {    
            {"AddNpc", 5, 1, 9, "BOSS", "Lv2_1_Boss",false, 0 , 1, 9011, 1, 3, 1},          
            {"RaiseEvent", "ChangeRoomState", 3, 1, "擊敗三層頭目"},
        },
        tbUnLockEvent = 
        {
            {"DoDeath", "wall_Lv2_1"},
            {"DelNpc", "guaiwu2_1"},
            {"OpenDynamicObstacle", "ops5"},
            {"RaiseEvent", "ChangeRoomState", 3, 1, "前往下一層", true, 8172, 10157},
			{"PlaySceneAnimation", "jz_mendonghua11", "wind", 0.5, true},
			{"PlaySceneAnimation", "jz_mendonghua12", "wind", 0.5, true},
        },
    },
    [10] = {nTime = 0, nNum = 1,
        tbPrelock = {8},
        tbStartEvent = 
        {    
            {"AddNpc", 5, 1, 10, "BOSS", "Lv2_2_Boss",false, 0 , 1, 9011, 1, 3, 2},          
            {"RaiseEvent", "ChangeRoomState", 3, 2, "擊敗三層頭目"},
        },
        tbUnLockEvent = 
        {
            {"DoDeath", "wall_Lv2_2"},
            {"DelNpc", "guaiwu2_2"},
            {"OpenDynamicObstacle", "ops6"},
			
            {"RaiseEvent", "ChangeRoomState", 3, 2, "前往下一層", true, 11850, 7678},
		--	{"BatchPlaySceneAnimation", "jz_mendonghua0", 9, 10, "wind", 1, true},
			{"PlaySceneAnimation", "jz_mendonghua09", "wind", 0.5, true},
			{"PlaySceneAnimation", "jz_mendonghua10", "wind", 0.5, true},
        },
    },
    [11] = {nTime = tbBossTime[4], nNum = 0,
        tbPrelock = {1},
        tbStartEvent = 
        {                
     
        },
        tbUnLockEvent = 
        {          
            {"BlackMsg", "四層首領出現！"}, 
        },
    },
    [12] = {nTime = 0, nNum = 1,
        tbPrelock = {11},
        tbStartEvent = 
        {    
            {"AddNpc", 6, 1, 12, "BOSS", "Lv3_Boss",false, 0 , 1, 9011, 1, 4, 1},     
            {"RaiseEvent", "ChangeRoomState", 4, 1, "擊敗四層首領"},
        },
        tbUnLockEvent = 
        {
			{"DelNpc", "guaiwu3"},
            {"RaiseEvent", "ChangeRoomState", 4, 1, "離開白虎堂", true, 0, 0},
            {"RaiseEvent", "OpenCrossDoor"},
            {"GameWin"},
        },
    },

    
}