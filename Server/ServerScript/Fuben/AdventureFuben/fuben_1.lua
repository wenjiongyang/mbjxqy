Require("ServerScript/Fuben/AdventureFuben.lua")

local tbFubenSetting = {};
local nMapTemplateId = Fuben.AdventureFuben.MAP_TEMPLATEID
Fuben:SetFubenSetting(nMapTemplateId, tbFubenSetting)      -- 绑定副本内容和地图

tbFubenSetting.szFubenClass             = "AdventureFubenBase";                                  -- 副本类型
tbFubenSetting.szName                   = Fuben.AdventureFuben.ACTIVITY_NAME                  -- 单纯的名字，后台输出或统计使用
tbFubenSetting.szNpcPointFile           = "Setting/Fuben/AdventureFuben/NpcPos.tab"          -- NPC点
--tbFubenSetting.szPathFile = "Setting/Fuben/TestFuben/NpcPos.tab"                              -- 寻路点                              
tbFubenSetting.tbMultiBeginPoint        = {{2227, 2799},{2703, 2807},{2204, 2380},{2681, 2382}} -- 副本出生点
tbFubenSetting.tbTempRevivePoint        = {2432, 2552}                                          -- 临时复活点，副本内有效，出副本则移除



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
    NpcNum2         = {5, 5},
    NpcNum3         = {10, 10},
    NpcNum4         = {15, 15},
    NpcNum5         = {20, 20},
    NpcNum6         = {25, 25},
    NpcNum7         = {30, 30},
}

tbFubenSetting.ANIMATION = 
{
    [1] = "Scenes/camera/Main Camera.controller",
}

--NPC模版ID，NPC等级，NPC五行；
--[[

635  劣质机关人
636  武林恶徒
637  蒙面杀手
639  护法
640  守护者
638  怒气机关（天王）
674  怒气机关（桃花）
675  怒气机关（峨眉）
676  怒气机关（逍遥）

]]

tbFubenSetting.NPC = 
{
    [1] = {nTemplate = 635,  nLevel = -1, nSeries = -1},
    [2] = {nTemplate = 636,  nLevel = -1, nSeries = -1},
    [3] = {nTemplate = 637,  nLevel = -1, nSeries = -1},
    [4] = {nTemplate = 639,  nLevel = -1, nSeries = -1},
    [5] = {nTemplate = 640,  nLevel = -1, nSeries = -1},
    [6] = {nTemplate = 638,  nLevel = -1, nSeries = -1},   
    [7] = {nTemplate = 674,  nLevel = -1, nSeries = -1},
    [8] = {nTemplate = 675,  nLevel = -1, nSeries = -1},
    [9] = {nTemplate = 676,  nLevel = -1, nSeries = -1},
}

tbFubenSetting.LOCK = 
{
    -- 1号锁不能不填，默认1号为起始锁，nTime是到时间自动解锁，nNum表示需要解锁的次数，如填3表示需要被解锁3次才算真正解锁，可以配置字符串
    [1] = {nTime = 2, nNum = 0,
        --tbPrelock 前置锁，激活锁的必要条件{1 , 2, {3, 4}}，代表1和2号必须解锁，3和4任意解锁一个即可
        tbPrelock = {},
        --tbStartEvent 锁激活时的事件
        tbStartEvent = 
        {
        },
        --tbStartEvent 锁解开时的事件
        tbUnLockEvent = 
        {
            {"SetShowTime", 18},    
            {"ChangeFightState", 1},        
            -- {"RaiseEvent", "AddBossTest"},
            --{"RaiseEvent", "AddNpcWithoutAward",}, (nIndex, nNum, nLock, szGroup, szPointName, bRevive)
        },
    },
    [2] = {nTime = 5, nNum = 0,
        tbPrelock = {1},
        tbStartEvent = 
        {           
            {"SetFubenProgress", -1, "山賊秘窟"},
            {"BlackMsg", "敵人將在5秒後出現，做好準備！"},
        },
        tbUnLockEvent = 
        {                        
        },
    },    
    [3] = {nTime = 0, nNum = "NpcNum3",
        tbPrelock = {2},
        tbStartEvent = 
        {    
            {"SetFubenProgress", -1, "1/9 擊敗敵人"},
            {"AddNpc", "NpcIndex1", "NpcNum2", 3, "guaiwu", "Fuben1_1_1", false, 0, 0, 0, 0},
            {"AddNpc", "NpcIndex1", "NpcNum2", 3, "guaiwu", "Fuben1_1_2", false, 0, 3, 0, 0},               
        },
        tbUnLockEvent = 
        {
            {"SetFubenProgress", -1, "等待下一波敵人"},
        },
    },
    [4] = {nTime = 5, nNum = 0,
        tbPrelock = {3},
        tbStartEvent = 
        {           
            {"BlackMsg", "下一波敵人將在5秒後出現！"},
        },
        tbUnLockEvent = 
        {
 
        },
    },   
    [5] = {nTime = 0, nNum = "NpcNum4",
        tbPrelock = {4},
        tbStartEvent = 
        {    
			{"SetFubenProgress", -1, "2/9 擊敗敵人"},
            {"AddNpc", "NpcIndex1", "NpcNum2", 5, "guaiwu", "Fuben1_2_1", false, 0, 0, 0, 0},
            {"AddNpc", "NpcIndex1", "NpcNum2", 5, "guaiwu", "Fuben1_2_2", false, 0, 3, 0, 0}, 
            {"AddNpc", "NpcIndex1", "NpcNum2", 5, "guaiwu", "Fuben1_2_3", false, 0, 6, 0, 0},              
        },
        tbUnLockEvent = 
        {
            {"SetFubenProgress", -1, "等待下一波敵人"},
            {"RaiseEvent", "AddRandomAngerNpc", "nuqi", 2451, 2559, 48, { {1000000, 675} }},
            {"BlackMsg", "開啟機關，可獲得怒氣！"},
        },
    },
    [6] = {nTime = 10, nNum = 0,
        tbPrelock = {5},
        tbStartEvent = 
        {           
        },
        tbUnLockEvent = 
        {
            {"SetFubenProgress", -1, "等待下一波敵人"},
        },
    },   
    [7] = {nTime = 0, nNum = "NpcNum5",
        tbPrelock = {6},
        tbStartEvent = 
        {    
            {"DelNpc", "nuqi"},
			{"SetFubenProgress", -1, "3/9擊敗敵人"},
            {"AddNpc", "NpcIndex2", "NpcNum5", 7, "guaiwu", "Fuben1_3_1", false, 0, 0, 0, 0},
        },
        tbUnLockEvent = 
        {
        },
    },
    [20] = {nTime = 3, nNum = 0,
        tbPrelock = {7},
        tbStartEvent = 
        {    
        },
        tbUnLockEvent = 
        {
			{"SetFubenProgress", -1, "4/9 擊敗馬賊"},
            {"AddNpc", "NpcIndex4", 4, 8, "Leader", "Fuben1_3_2", false, 0, 0, 0, 0},
        },
    },
    [8] = {nTime = 0, nNum = 4,
        tbPrelock = {7},
        tbStartEvent = 
        {    
        },
        tbUnLockEvent = 
        {
            {"SetFubenProgress", -1, "等待下一波敵人"},            
            {"RaiseEvent", "AddRandomAngerNpc", "nuqi", 2451, 2559, 48, { {1000000, 675} }},
        },
    },
    [9] = {nTime = 10, nNum = 0,
        tbPrelock = {8},
        tbStartEvent = 
        {           
           {"BlackMsg", "開啟機關，可獲得怒氣！"},
        },
        tbUnLockEvent = 
        {
            {"SetFubenProgress", -1, "等待下一波敵人"},
        },
    },  
    [10] = {nTime = 0, nNum = "NpcNum6",
        tbPrelock = {9},
        tbStartEvent = 
        {   
            {"DelNpc", "nuqi"},
			{"SetFubenProgress", -1, "5/9 擊敗敵人"},
            {"AddNpc", "NpcIndex2", "NpcNum6", 10, "guaiwu", "Fuben1_4_1", false, 0, 0, 0, 0},
        },
        tbUnLockEvent = 
        {   
            {"SetFubenProgress", -1, "等待下一波敵人"},
            {"RaiseEvent", "AddRandomAngerNpc", "nuqi", 2451, 2559, 48, { {1000000, 675} }},
        },
    },

    [11] = {nTime = 10, nNum = 0,
        tbPrelock = {10},
        tbStartEvent = 
        {           
            {"BlackMsg", "開啟機關，可獲得怒氣！"},
        },
        tbUnLockEvent = 
        {
            {"SetFubenProgress", -1, "等待下一波敵人"},
        },
    },  
    [12] = {nTime = 0, nNum = "NpcNum7",
        tbPrelock = {11},
        tbStartEvent = 
        {   
            {"DelNpc", "nuqi"},
			{"SetFubenProgress", -1, "6/9 擊敗敵人"},
            {"AddNpc", "NpcIndex3", "NpcNum7", 12, "guaiwu", "Fuben1_5_1", false, 0, 0, 0, 0},
        },
        tbUnLockEvent = 
        {   
        },
    },
    [21] = {nTime = 3, nNum = 0,
        tbPrelock = {12},
        tbStartEvent = 
        {    
        },
        tbUnLockEvent = 
        {
			{"SetFubenProgress", -1, "7/9 擊敗馬賊"},
            {"AddNpc", "NpcIndex4", 4, 13, "Leader1", "Fuben1_5_2", false, 0, 0, 0, 0},
        },
    },
    [13] = {nTime = 0, nNum = 4,
        tbPrelock = {12},
        tbStartEvent = 
        {               
        },
        tbUnLockEvent = 
        {
            {"SetFubenProgress", -1, "等待下一波敵人"},
            {"RaiseEvent", "AddRandomAngerNpc", "nuqi", 2451, 2559, 48, { {1000000, 675} }},
        },
    },
    [14] = {nTime = 10, nNum = 0,
        tbPrelock = {13},
        tbStartEvent = 
        {           
           {"BlackMsg", "開啟機關，可獲得怒氣！"},
        },
        tbUnLockEvent = 
        {
            {"SetFubenProgress", -1, "等待下一波敵人"},   
        },
    },  
    [15] = {nTime = 0, nNum = "NpcNum7",
        tbPrelock = {14},
        tbStartEvent = 
        {   
            {"DelNpc", "nuqi"},
			{"SetFubenProgress", -1, "8/9 擊敗敵人"},
            {"AddNpc", "NpcIndex3", "NpcNum7", 15, "guaiwu", "Fuben1_6_1", false, 0, 0, 0, 0},
        },
        tbUnLockEvent = 
        {   
            {"SetFubenProgress", -1, "9/9 擊敗山賊首領"},            
        },
    },
    [22] = {nTime = 3, nNum = 0,
        tbPrelock = {15},
        tbStartEvent = 
        {    
        },
        tbUnLockEvent = 
        {
            {"AddNpc", "NpcIndex5", "NpcNum1", 16, "BOSS", "Fuben1_6_2", false, 0, 1, 9011, 1},
        },
    },
    [16] = {nTime = 0, nNum = "NpcNum1",
        tbPrelock = {15},
        tbStartEvent = 
        {               
        },
        tbUnLockEvent = 
        {
        },
    },
    [17] = {nTime = 3, nNum = 0,
        tbPrelock = {16},
        tbStartEvent = 
        {
            {"BlackMsg", "已擊敗所有敵人!"},
        --    {"AddSimpleNpc", 436, 2433, 2570, 0},
	        {"SetFubenProgress", -1, "離開秘境"}, 
			{"GameWin"},
        },
        tbUnLockEvent = 
        {

        },
    },
    [18] = {nTime = 900, nNum = 0,
        tbPrelock = {1},
        tbStartEvent = 
        {
        },
        tbUnLockEvent = 
        {
            {"BlackMsg", "時間耗盡，本次懲惡失敗！"},
            {"SetFubenProgress", -1, "離開秘境"}, 
            {"GameLost"},
        },
    },
}