Require("ServerScript/Fuben/WhiteTigerFuben.lua")

local tbFubenSetting = {};
local nMapTemplateId = Fuben.WhiteTigerFuben.CROSS_MAP_TID
Fuben:SetFubenSetting(nMapTemplateId, tbFubenSetting)      -- 绑定副本内容和地图

tbFubenSetting.szFubenClass   = "WhiteTigerFubenCross";                                  -- 副本类型
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
    [4] = {nTemplate = 1954,  nLevel = -1, nSeries = -1},
    [5] = {nTemplate = 713,  nLevel = -1, nSeries = -1},
    [6] = {nTemplate = 1953,  nLevel = -1, nSeries = -1},   
    [7] = {nTemplate = 104,  nLevel = -1, nSeries = -1},
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
            {"SetShowTime", 3},    
            {"ChangeFightState", 1},
			{"SetFubenProgress", -1, "等待大門打開"},
        },
    },
    
        [2] = {nTime = 0, nNum = 0,
        tbPrelock = {1},
        tbStartEvent = 
        {    
    
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

			{"AddNpc", 4, 1, 0, "BOSS", "Lv1_1_Boss",false, 0 , 1, 9011, 1, 2, 1}, 
			{"AddNpc", 4, 1, 0, "BOSS", "Lv1_2_Boss",false, 0 , 1, 9011, 1, 2, 2}, 
			{"AddNpc", 4, 1, 0, "BOSS", "Lv1_3_Boss",false, 0 , 1, 9011, 1, 2, 3},
			{"AddNpc", 4, 1, 0, "BOSS", "Lv1_4_Boss",false, 0 , 1, 9011, 1, 2, 4},	
		
        },
        tbUnLockEvent = 
        {
        },
    },
    [3] = {nTime = 60*7, nNum = 0,
        tbPrelock = {1},
        tbStartEvent = 
        {                 
        },
        tbUnLockEvent = 
        { 
			{"BlackMsg", "大門打開，請前往中央大殿"},  
            {"DoDeath", "wall_Lv1_1"},
            {"DoDeath", "wall_Lv1_2"},
            {"DoDeath", "wall_Lv1_3"},
            {"DoDeath", "wall_Lv1_4"},
			{"DoDeath", "wall_Lv2_1"},
			{"DoDeath", "wall_Lv2_2"},
			{"BatchPlaySceneAnimation", "jz_mendonghua0", 5, 6, "wind", 0.5, true},
			{"BatchPlaySceneAnimation", "jz_mendonghua0", 7, 8, "wind", 0.5, true},
			{"BatchPlaySceneAnimation", "jz_mendonghua0", 3, 4, "wind", 0.5, true},
			{"BatchPlaySceneAnimation", "jz_mendonghua0", 1, 2, "wind", 0.5, true},
			{"PlaySceneAnimation", "jz_mendonghua11", "wind", 0.5, true},
			{"PlaySceneAnimation", "jz_mendonghua12", "wind", 0.5, true},
			{"PlaySceneAnimation", "jz_mendonghua09", "wind", 0.5, true},
			{"PlaySceneAnimation", "jz_mendonghua10", "wind", 0.5, true},
            {"OpenDynamicObstacle", "ops1"},
            {"OpenDynamicObstacle", "ops2"},
            {"OpenDynamicObstacle", "ops3"},
            {"OpenDynamicObstacle", "ops4"},
            {"OpenDynamicObstacle", "ops5"},
            {"OpenDynamicObstacle", "ops6"},
			
			{"DelNpc", "BOSS"},
            
        },
    },
    
	[4] = {nTime = 60*2.5, nNum = 1,
        tbPrelock = {3},
        tbStartEvent = 
        {     
			{"SetShowTime", 4}, 	
			{"SetFubenProgress", -1, "前往中央大殿"},
        },
        tbUnLockEvent = 
        { 

        },
    },
	
    [5] = {nTime = 0, nNum = 1,
        tbPrelock = {4},
        tbStartEvent = 
        {
			{"BlackMsg", "五層頭目出現！"},   
			{"SetFubenProgress", -1, "擊敗五層頭目"},
            --Boss附带两个参数，第一个是第几层，第二个是房间索引(第一层可以不带)
            {"AddNpc", 6, 1, 5, "BOSS", "Lv3_Boss",false, 0 , 1, 9011, 1, 4, 1},    
        },
        tbUnLockEvent = 
        { 
			{"BlackMsg", "五層頭目已被擊敗！"}, 
			{"SetFubenProgress", -1, "離開白虎堂"},
			{"GameWin"},
        },
    },
}