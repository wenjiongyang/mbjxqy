Require("ServerScript/Fuben/KinTrain/KinTrainMgr.lua")

local tbFubenSetting = {};
local nMapTemplateId = Fuben.KinTrainMgr.MAPTEMPLATEID
Fuben:SetFubenSetting(nMapTemplateId, tbFubenSetting)   -- 绑定副本内容和地图

tbFubenSetting.szFubenClass   = "KinTrainBase";                      -- 副本类型
tbFubenSetting.szName         = Fuben.KinTrainMgr.ACTIVITY_NAME         -- 单纯的名字，后台输出或统计使用
tbFubenSetting.szNpcPointFile = "Setting/Fuben/KinTrail/NpcPos.tab"  -- NPC点

-- ID可以随便 普通副本NPC数量 ；精英模式NPC数量
tbFubenSetting.NUM = 
{
    NpcIndex3       = {23, 13, 3},
	NpcIndex4       = {24, 14, 4},
	NpcIndex5       = {25, 15, 5},
	NpcIndex6       = {26, 16, 6},
	NpcIndex7       = {27, 17, 7},
	NpcIndex8       = {28, 18, 8},
	NpcIndex9       = {29, 19, 9},
	
    NpcNum1         = {1, 1},
}

tbFubenSetting.ANIMATION = 
{
    [1] = "Scenes/camera/Main Camera.controller",
}

tbFubenSetting.NPC = 
{
	[1] = {nTemplate = 104,  nLevel = -1, nSeries = 1},---障碍墙
    [2] = {nTemplate = 1189,  nLevel = -1, nSeries = 1},--旗帜
	[3] = {nTemplate = 1190,  nLevel = -1, nSeries = 1},--金军斥候
	[4] = {nTemplate = 1254,  nLevel = -1, nSeries = 1},--机关战车（冲刺）
	[5] = {nTemplate = 1255,  nLevel = -1, nSeries = 1},--铜锤蛮士
	[6] = {nTemplate = 1256,  nLevel = -1, nSeries = 1},--反弹卫士
	[7] = {nTemplate = 1257,  nLevel = -1, nSeries = 1},--蒙面杀手（无形蛊）
	[8] = {nTemplate = 1259,  nLevel = -1, nSeries = 1},--金军斥候·精英
	[9] = {nTemplate = 1260,  nLevel = -1, nSeries = 1},--火炮
	[10] = {nTemplate = 1258,  nLevel = -1, nSeries = 1},--宝箱
	
	[13] = {nTemplate = 1290,  nLevel = -1, nSeries = 1},--金军斥候--弱
	[14] = {nTemplate = 1291,  nLevel = -1, nSeries = 1},--机关战车（冲刺）--弱
	[15] = {nTemplate = 1292,  nLevel = -1, nSeries = 1},--铜锤蛮士--弱
	[16] = {nTemplate = 1293,  nLevel = -1, nSeries = 1},--反弹卫士--弱
	[17] = {nTemplate = 1294,  nLevel = -1, nSeries = 1},--蒙面杀手（无形蛊）--弱
	[18] = {nTemplate = 1295,  nLevel = -1, nSeries = 1},--金军斥候·精英--弱
	[19] = {nTemplate = 1296,  nLevel = -1, nSeries = 1},--火炮--弱
	
	[23] = {nTemplate = 1297,  nLevel = -1, nSeries = 1},--金军斥候--弱弱
	[24] = {nTemplate = 1298,  nLevel = -1, nSeries = 1},--机关战车（冲刺）--弱弱
	[25] = {nTemplate = 1299,  nLevel = -1, nSeries = 1},--铜锤蛮士--弱弱
	[26] = {nTemplate = 1300,  nLevel = -1, nSeries = 1},--反弹卫士--弱弱
	[27] = {nTemplate = 1301,  nLevel = -1, nSeries = 1},--蒙面杀手（无形蛊）--弱弱
	[28] = {nTemplate = 1302,  nLevel = -1, nSeries = 1},--金军斥候·精英--弱弱
	[29] = {nTemplate = 1303,  nLevel = -1, nSeries = 1},--火炮--弱弱
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
        },
    },
	[2] = {nTime = 1, nNum = 0,
        tbPrelock = {1},
        tbStartEvent = 
        {
		--准备阶段
		{"SetFubenProgress", -1, "等待試煉開啟"},
		{"AddNpc", 1, 2, 0, "Stone1", "Stone1", false, 16, 0, 0, 0},
		{"AddNpc", 1, 2, 0, "Stone2", "Stone2", false, 25, 0, 0, 0},
		{"AddNpc", 1, 2, 0, "Stone3", "Stone3", false, 36, 0, 0, 0},
		{"AddNpc", 1, 2, 0, "Stone4", "Stone4", false, 22, 0, 0, 0},
		
		{"AddNpc", 2, 1, 0, "Flag", "Flag_1_1", false, 0, 0, 0, 0},
	--	{"AddNpc", 2, 1, 0, "Flag", "Flag_1_2", false, 0, 0, 0, 0},
	--	{"AddNpc", 2, 1, 0, "Flag", "Flag_1_3", false, 0, 0, 0, 0},
		
		{"AddNpc", 2, 1, 0, "Flag", "Flag_2_1", false, 0, 0, 0, 0},
	--	{"AddNpc", 2, 1, 0, "Flag", "Flag_2_2", false, 0, 0, 0, 0},
	--	{"AddNpc", 2, 1, 0, "Flag", "Flag_2_3", false, 0, 0, 0, 0},
		
		{"AddNpc", 2, 1, 0, "Flag", "Flag_3_1", false, 0, 0, 0, 0},
	--	{"AddNpc", 2, 1, 0, "Flag", "Flag_3_2", false, 0, 0, 0, 0},
	--	{"AddNpc", 2, 1, 0, "Flag", "Flag_3_3", false, 0, 0, 0, 0},
		
        },
        tbUnLockEvent = 
        {
        --准备阶段结束   
	--	{"SetFubenProgress", -1, "击破岩石，打开道路"},
        },
    },
    [100] = {nTime = 99999, nNum = 0,
        tbPrelock = {1},
        tbStartEvent = 
        {},
        tbUnLockEvent = 
        {},
    },
	[3] = {nTime = 1, nNum = 0,
        tbPrelock = {100},
        tbStartEvent = 
        {
			{"DoDeath", "Stone1"},
			{"BlackMsg", "試煉開始！"},
		
		
        },
        tbUnLockEvent = 
        {
		--	{"BlackMsg", "上路打开"}, 
			{"OpenDynamicObstacle", "door1"},
        },
    },
	[4] = {nTime = 1, nNum = 0,
        tbPrelock = {100},
        tbStartEvent = 
        {
			{"DoDeath", "Stone2"},
		
        },
        tbUnLockEvent = 
        {
		--	{"BlackMsg", "中路打开"}, 
			{"OpenDynamicObstacle", "door2"},
        },
    },
	[5] = {nTime = 1, nNum = 0,
        tbPrelock = {100},
        tbStartEvent = 
        {
			{"DoDeath", "Stone3"},
		
        },
        tbUnLockEvent = 
        {
		--	{"BlackMsg", "下路打开"}, 
			{"OpenDynamicObstacle", "door3"},
        },
    },
	[6] = {nTime = 5, nNum = 0,
        tbPrelock = {3,4,5},
        tbStartEvent = 
        {
		--开始守卫据点1
		
		
        },
        tbUnLockEvent = 
        {
			{"SetFubenProgress", -1, "守衛三路據點1/5"},
			--刷据点1第1波怪
			{"AddNpc", "NpcIndex3", 6, 7, "enemy1", "enemy_1_1", false, 0, 0, 0, 0},
			{"AddNpc", "NpcIndex3", 6, 7, "enemy2", "enemy_2_1", false, 0, 0, 0, 0},
			{"AddNpc", "NpcIndex3", 6, 7, "enemy3", "enemy_3_1", false, 0, 0, 0, 0},
			{"NpcBubbleTalk", "enemy1", "有宋人闖入！", 2, 2, 1},
			{"NpcBubbleTalk", "enemy2", "有宋人闖入！", 2, 2, 1},
			{"NpcBubbleTalk", "enemy3", "有宋人闖入！", 2, 2, 1},
        },
    },
	[7] = {nTime = 0, nNum = 18,
        tbPrelock = {6},
        tbStartEvent = 
        {
		
        },
        tbUnLockEvent = 
        {
			{"SetFubenProgress", -1, "守衛三路據點2/5"},
			{"BlackMsg", "第2波敵人來襲！"},
			{"AddNpc", "NpcIndex3", 6, 8, "enemy", "enemy_1_1", false, 0, 0, 0, 0},
			{"AddNpc", "NpcIndex3", 6, 8, "enemy", "enemy_2_1", false, 0, 0, 0, 0},
			{"AddNpc", "NpcIndex3", 6, 8, "enemy", "enemy_3_1", false, 0, 0, 0, 0},
			
			{"AddNpc", "NpcIndex8", 2, 8, "enemy1", "enemy_1_1", false, 0, 0, 0, 0},
			{"AddNpc", "NpcIndex8", 2, 8, "enemy2", "enemy_2_1", false, 0, 0, 0, 0},
			{"AddNpc", "NpcIndex8", 2, 8, "enemy3", "enemy_3_1", false, 0, 0, 0, 0},
		
			{"NpcBubbleTalk", "enemy1", "阻止他們！", 2, 2, 1},
			{"NpcBubbleTalk", "enemy2", "阻止他們！", 2, 2, 1},
			{"NpcBubbleTalk", "enemy3", "阻止他們！", 2, 2, 1},
        },
    },
	[8] = {nTime = 0, nNum = 24,
        tbPrelock = {7},
        tbStartEvent = 
        {
				
        },
        tbUnLockEvent = 
        {
			{"SetFubenProgress", -1, "守衛三路據點3/5"},
			{"BlackMsg", "第3波敵人來襲！"},
		--	{"AddNpc", 3, 3, 9, "enemy", "enemy_1_1", false, 0, 0, 0, 0},
		--	{"AddNpc", 3, 3, 9, "enemy", "enemy_2_1", false, 0, 0, 0, 0},
		--	{"AddNpc", 3, 3, 9, "enemy", "enemy_3_1", false, 0, 0, 0, 0},
			
			{"AddNpc", "NpcIndex4", 5, 9, "enemy1", "enemy_1_1", false, 0, 0, 0, 0},
			{"AddNpc", "NpcIndex4", 5, 9, "enemy2", "enemy_2_1", false, 0, 0, 0, 0},
			{"AddNpc", "NpcIndex4", 5, 9, "enemy3", "enemy_3_1", false, 0, 0, 0, 0},
			
			{"NpcBubbleTalk", "enemy1", "衝！", 2, 2, 1},
			{"NpcBubbleTalk", "enemy2", "衝！", 2, 2, 1},
			{"NpcBubbleTalk", "enemy3", "衝！", 2, 2, 1},
			
			
        },
    },
	[9] = {nTime = 0, nNum = 15,
        tbPrelock = {8},
        tbStartEvent = 
        {
				
        },
        tbUnLockEvent = 
        {
			{"SetFubenProgress", -1, "守衛三路據點4/5"},
			{"BlackMsg", "第4波敵人來襲！"},
		--	{"AddNpc", 3, 3, 10, "enemy", "enemy_1_1", false, 0, 0, 0, 0},
		--	{"AddNpc", 3, 3, 10, "enemy", "enemy_2_1", false, 0, 0, 0, 0},
		--	{"AddNpc", 3, 3, 10, "enemy", "enemy_3_1", false, 0, 0, 0, 0},
			
			{"AddNpc", "NpcIndex5", 4, 10, "enemy1", "enemy_1_1", false, 0, 0, 0, 0},
			{"AddNpc", "NpcIndex5", 4, 10, "enemy2", "enemy_2_1", false, 0, 0, 0, 0},
			{"AddNpc", "NpcIndex5", 4, 10, "enemy3", "enemy_3_1", false, 0, 0, 0, 0},
			
			{"NpcBubbleTalk", "enemy1", "吃我一錘！", 2, 2, 1},
			{"NpcBubbleTalk", "enemy2", "吃我一錘！", 2, 2, 1},
			{"NpcBubbleTalk", "enemy3", "吃我一錘！", 2, 2, 1},
			
			
        },
    },
	[10] = {nTime = 0, nNum = 12,
        tbPrelock = {9},
        tbStartEvent = 
        {
				
        },
        tbUnLockEvent = 
        {
			{"SetFubenProgress", -1, "守衛三路據點5/5"},
			{"BlackMsg", "第5波敵人來襲！"},
		--	{"AddNpc", 3, 3, 11, "enemy", "enemy_1_1", false, 0, 0, 0, 0},
		--	{"AddNpc", 3, 3, 11, "enemy", "enemy_2_1", false, 0, 0, 0, 0},
		--	{"AddNpc", 3, 3, 11, "enemy", "enemy_3_1", false, 0, 0, 0, 0},
			
			{"AddNpc", "NpcIndex6", 2, 11, "enemy1", "enemy_1_1", false, 0, 0, 0, 0},
			{"AddNpc", "NpcIndex6", 2, 11, "enemy2", "enemy_2_1", false, 0, 0, 0, 0},
			{"AddNpc", "NpcIndex6", 2, 11, "enemy3", "enemy_3_1", false, 0, 0, 0, 0},
			
			{"NpcBubbleTalk", "enemy1", "試試我的軟蝟甲！", 2, 2, 1},
			{"NpcBubbleTalk", "enemy2", "試試我的軟蝟甲！", 2, 2, 1},
			{"NpcBubbleTalk", "enemy3", "試試我的軟蝟甲！", 2, 2, 1},
        },
    },
	[11] = {nTime = 0, nNum = 6,
        tbPrelock = {10},
        tbStartEvent = 
        {
				
        },
        tbUnLockEvent = 
        {
			--刷宝箱
			{"DelNpc", "Flag"},
			{"SetFubenProgress", -1, "開啟寶箱"},
			{"BlackMsg", "據點守衛成功，拾取金軍寶箱"},
			{"AddNpc", 10, 1, 0, "Box", "Flag_1_2", false, 0, 0, 0, 0},
			{"AddNpc", 10, 1, 0, "Box", "Flag_2_2", false, 0, 0, 0, 0},
			{"AddNpc", 10, 1, 0, "Box", "Flag_3_2", false, 0, 0, 0, 0},
        },
    },
    [101] = {nTime = 0, nNum = 3,
        tbPrelock = {11},
        tbStartEvent = 
        {       
        },
        tbUnLockEvent = 
        {
        },
    },
	[12] = {nTime = 0, nNum = 15,
        tbPrelock = {101},
        tbStartEvent = 
        {
		--刷3个守卫将领
			{"SetFubenProgress", -1, "擊敗金軍三雄1/3"},
			{"BlackMsg", "擊敗金軍三雄"},
			{"AddNpc", "NpcIndex3", 5, 12, "enemy", "enemy_1_3", false, 0, 0, 0, 0},
			{"AddNpc", "NpcIndex3", 5, 12, "enemy", "enemy_2_3", false, 0, 0, 0, 0},
			{"AddNpc", "NpcIndex3", 5, 12, "enemy", "enemy_3_3", false, 0, 0, 0, 0},
				
        },
        tbUnLockEvent = 
        {
			--刷据点2第1波怪

        },
    },
	[13] = {nTime = 0, nNum = 6,
        tbPrelock = {12},
        tbStartEvent = 
        {
			{"SetFubenProgress", -1, "擊敗金軍三雄2/3"},
			{"AddNpc", "NpcIndex7", 2, 13, "enemy", "enemy_1_3", false, 0, 0, 0, 0},
			{"AddNpc", "NpcIndex7", 2, 13, "enemy", "enemy_2_3", false, 0, 0, 0, 0},
			{"AddNpc", "NpcIndex7", 2, 13, "enemy", "enemy_3_3", false, 0, 0, 0, 0},	
        },
        tbUnLockEvent = 
        {
			
        },
    },
	[14] = {nTime = 0, nNum = 6,
        tbPrelock = {13},
        tbStartEvent = 
        {
			{"SetFubenProgress", -1, "擊敗金軍三雄3/3"},
			{"AddNpc", "NpcIndex3", 1, 14, "enemy", "enemy_1_3", false, 0, 0, 0, 0},
			{"AddNpc", "NpcIndex3", 1, 14, "enemy", "enemy_2_3", false, 0, 0, 0, 0},
			{"AddNpc", "NpcIndex3", 1, 14, "enemy", "enemy_3_3", false, 0, 0, 0, 0},		
			
			{"AddNpc", "NpcIndex9", 1, 14, "enemy", "enemy_1_3", false, 0, 0, 0, 0},
			{"AddNpc", "NpcIndex9", 1, 14, "enemy", "enemy_2_3", false, 0, 0, 0, 0},
			{"AddNpc", "NpcIndex9", 1, 14, "enemy", "enemy_3_3", false, 0, 0, 0, 0},	
        },
        tbUnLockEvent = 
        {
			
        },
    },
    [15] = {nTime = 0, nNum = 0,
        tbPrelock = {14},
        tbStartEvent = 
		{
			{"DoDeath", "Stone4"},
			{"OpenDynamicObstacle", "door4"},
            {"SetFubenProgress", -1, "收集物資"},
			{"BlackMsg", "進入大營，收集物資"},
            {"RaiseEvent", "SecondTrainBegin"},
        },
        tbUnLockEvent = {
			
        }
    },
}