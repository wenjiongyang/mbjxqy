
local tbFubenSetting = Fuben.RandomFuben:GetRandomFubenSetting("a_5");

tbFubenSetting.tbMultiBeginPoint = {{1122, 1240},{1287, 1068},{899, 1091},{1101, 875}}	-- 副本出生点
tbFubenSetting.tbTempRevivePoint = {1094, 1051};
tbFubenSetting.nStartDir		 = 9;

--NPC模版ID，NPC等级，NPC五行；

--[[

]]


tbFubenSetting.NPC = 
{
	[1] = {nTemplate = 1542,  nLevel = -1, nSeries = -1}, --灰狼
	[2] = {nTemplate = 1543,  nLevel = -1, nSeries = -1}, --狼王
	[3] = {nTemplate = 104,   nLevel = -1, nSeries = 0},  --动态障碍墙
	[4] = {nTemplate = 1544,  nLevel = -1, nSeries = 0},  --卢青
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
			--设置同步范围
			{"SetNearbyRange", 3},
			
			{"SetFubenProgress", -1,"等待秘境開啟"},
			{"AddNpc", 3, 2, 1, "wall", "wall_1_1",false, 24},
			{"OpenWindow", "LingJueFengLayerPanel", "Info",3, 9, "第一層 竹林小道"},
		},
	},
	[2] = {nTime = 10, nNum = 0,
		tbPrelock = {1},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"RaiseEvent", "Start"},
			{"ShowTaskDialog", 10000, false},
			{"DoDeath", "wall"},
			{"OpenDynamicObstacle", "ops1"},			
			{"SetTargetPos", 1877, 1836},

			--卢青
			{"AddNpc", 4, 1, 10, "Luqing", "RandomFuben1_5_Luqing",false, 8, 0, 0, 0},
		},
	},
	[3] = {nTime = 0, nNum = 1,
		tbPrelock = {2},
		tbStartEvent = 
		{			
			{"SetFubenProgress", 0, "探索凌絕峰"},
			{"TrapUnlock", "TrapLock1", 3},
		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},
			{"SetFubenProgress", 20, "擊退狼群"},
			{"NpcBubbleTalk", "Luqing", "哈哈，總算來人了！！還請各位俠士能助在下將狼群擊退！", 4, 0, 1},
			-- {"ChangeNpcAi", "Luqing", "Move", "Path1", 0, 0, 0, 0, 0},

			--灰狼
			{"AddNpc", 1, 4, 4, "guaiwu", "RandomFuben1_5_1", false, 0, 0, 0, 0},
			{"AddNpc", 1, 4, 4, "guaiwu", "RandomFuben1_5_2", false, 0, 2, 0, 0},
			{"AddNpc", 1, 6, 4, "guaiwu", "RandomFuben1_5_3", false, 0, 4, 0, 0},
		},
	},
	[4] = {nTime = 0, nNum = 14,
		tbPrelock = {3},
		tbStartEvent = 
		{		
		},
		tbUnLockEvent = 
		{
			{"SetFubenProgress", 50, "護送盧青"},
			{"SetTargetPos", 2320, 3489},
			{"ChangeNpcAi", "Luqing", "Move", "Path1", 1, 1, 0, 0, 0},
			{"NpcBubbleTalk", "Luqing", "總算是將狼群擊退了，我們繼續前進！", 4, 0, 1},

			--狼王 
			{"AddNpc", 2, 1, 6, "BOSS", "RandomFuben1_5_BOSS", false, 0, 0, 0, 0},
		},
	},
	[5] = {nTime = 0, nNum = 1,
		tbPrelock = {4},
		tbStartEvent = 
		{			
			{"TrapUnlock", "TrapLock2", 5},	
		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},
			{"SetFubenProgress", 80, "擊退狼王"},
			{"NpcBubbleTalk", "Luqing", "糟糕，居然遇到狼王了！", 4, 0, 1},
		},
	},
	[6] = {nTime = 0, nNum = 1,
		tbPrelock = {5},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			--掉落首领奖励 ——  卢青
			{"RaiseEvent", "DropAward", "Setting/Npc/DropFile/RandomFuben/House_A/luqing.tab", 2154, 4049},	
			{"RaiseEvent", "DropAward", "Setting/Npc/DropFile/RandomFuben/House_A/luqing.tab", 2411, 4045},	

			{"SetFubenProgress", 100, "擊退狼王"},	
			{"RaiseEvent", "AddMissionScore", 12},
			{"OpenWindow", "LingJueFengLayerPanel", "Win"},
			{"GameWin"},
		},
	},
	[7] = {nTime = 90, nNum = 0,
		tbPrelock = {2},
		tbStartEvent = 
		{
			{"SetShowTime", 7},
		},
		tbUnLockEvent = 
		{
			{"RaiseEvent", "AddMissionScore", 8},
			{"BlackMsg", "這些猛獸兇猛異常害，還是趕緊離去為妙！"},
			{"OpenWindow", "LingJueFengLayerPanel", "Fail"},
			{"GameLost"},
		},
	},
}

