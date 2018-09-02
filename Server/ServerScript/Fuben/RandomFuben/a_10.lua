
local tbFubenSetting = Fuben.RandomFuben:GetRandomFubenSetting("a_10");

tbFubenSetting.tbMultiBeginPoint = {{985, 1124},{1144, 934},{794, 975},{921, 816}}	-- 副本出生点
tbFubenSetting.tbTempRevivePoint = {972, 961};
tbFubenSetting.nStartDir		 = 14;

--NPC模版ID，NPC等级，NPC五行；

--[[

]]


tbFubenSetting.NPC = 
{
	[1] = {nTemplate = 700,  nLevel = -1, nSeries = -1}, --灰狼
	[2] = {nTemplate = 701,  nLevel = -1, nSeries = -1}, --狼王
	[3] = {nTemplate = 104,  nLevel = -1, nSeries = 0}, --动态障碍墙
	[4] = {nTemplate = 1547, nLevel = -1, nSeries = 0}, --李三
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
			{"AddNpc", 3, 2, 1, "wall", "wall_1_1",false, 59},
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
			{"SetTargetPos", 1995, 1281},

			--李三
			{"AddNpc", 4, 1, 11, "Lisan", "RandomFuben1_10_Lisan",false, 12, 0, 0, 0},
		},
	},
	[3] = {nTime = 0, nNum = 1,
		tbPrelock = {2},
		tbStartEvent = 
		{			
			{"SetFubenProgress", 0, "探索凌絕峰"},
			{"TrapUnlock", "Lisan", 3},
		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},
			{"NpcBubbleTalk", "Lisan", "哈哈，總算是來人了，這條路危險重重還請各位俠士能護送我一程！", 4, 1, 1},	
			{"ChangeNpcAi", "Lisan", "Move", "Path1", 1, 1, 0, 0, 0},
		},
	},
	[4] = {nTime = 0, nNum = 1,
		tbPrelock = {3},
		tbStartEvent = 
		{			
			{"SetFubenProgress", 20, "護送李三"},
			{"TrapUnlock", "TrapLock1", 4},
			{"SetTargetPos", 2533, 1624},
		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},
			{"BlackMsg", "糟糕！似乎是遇到惡狼群了！"},
			{"SetFubenProgress", 20, "擊退灰狼"},
			{"NpcBubbleTalk", "Lisan", "糟糕，看來是遇到狼群了，趕緊將牠們擊退！", 4, 1, 1},

			--灰狼
			{"AddNpc", 1, 3, 5, "guaiwu", "RandomFuben1_10_1_1", false, 0, 0, 0, 0},
			{"AddNpc", 1, 2, 5, "guaiwu", "RandomFuben1_10_1_2", false, 0, 2, 0, 0},
			{"AddNpc", 1, 2, 5, "guaiwu", "RandomFuben1_10_1_3", false, 0, 2, 0, 0},
		},
	},
	[5] = {nTime = 0, nNum = 7,
		tbPrelock = {4},
		tbStartEvent = 
		{			

		},
		tbUnLockEvent = 
		{	
			{"SetFubenProgress", 40, "離開竹林小道"},
			{"SetTargetPos", 2795, 4470},
			{"AddNpc", 3, 1, 1, "wall", "wall_1_2",false, 61},
			{"BlackMsg", "狼群數量越來越多，得儘快離開此地才是！"},	
			{"NpcBubbleTalk", "Lisan", "總算是將狼群擊退了，我們繼續前進！", 4, 1, 1},	
			{"ChangeNpcAi", "Lisan", "Move", "Path2", 1, 1, 0, 0, 0},
			{"OpenDynamicObstacle", "ops2"},	
		},
	},
	[6] = {nTime = 0, nNum = 1,
		tbPrelock = {5},
		tbStartEvent = 
		{
			{"TrapUnlock", "TrapLock2", 6},
		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},
			{"BlackMsg", "糟糕，又遇到惡狼群了！"},
			{"NpcBubbleTalk", "Lisan", "糟糕，又遇到狼群了，趕緊將牠們擊退！", 4, 1, 1},
			{"SetFubenProgress", 60, "擊退灰狼"},

			--灰狼
			{"AddNpc", 1, 3, 7, "guaiwu", "RandomFuben1_10_2_1", false, 0, 0, 0, 0},
			{"AddNpc", 1, 2, 7, "guaiwu", "RandomFuben1_10_2_2", false, 0, 2, 0, 0},
			{"AddNpc", 1, 2, 7, "guaiwu", "RandomFuben1_10_2_3", false, 0, 2, 0, 0},				
		},
	},
	[7] = {nTime = 0, nNum = 7,
		tbPrelock = {6},
		tbStartEvent = 
		{				
		},
		tbUnLockEvent = 
		{
			{"SetFubenProgress", 80, "離開竹林小道"},
			{"BlackMsg", "出口就在前方，盡速逃離這裡！"},

			{"ChangeNpcAi", "Lisan", "Move", "Path3", 1, 1, 0, 0, 0},			
			{"OpenDynamicObstacle", "ops3"},
			{"DoDeath", "wall"},
			{"SetTargetPos", 4323, 5321},
		},
	},
	[8] = {nTime = 0, nNum = 1,
		tbPrelock = {7},
		tbStartEvent = 
		{
			{"TrapUnlock", "TrapLock3", 8},
		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},
			{"BlackMsg", "糟糕，居然碰到狼王了！"},
			{"SetFubenProgress", 80, "擊退狼王"},

			--狼王 & 灰狼
			{"AddNpc", 2, 1, 9, "BOSS", "RandomFuben1_10_3_BOSS", false, 0, 1, 9011, 1},		
		},
	},
	[9] = {nTime = 0, nNum = 1,
		tbPrelock = {8},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			--掉落首领奖励 ——  李三
			{"RaiseEvent", "DropAward", "Setting/Npc/DropFile/RandomFuben/House_A/lisan.tab", 4700, 5379},	
			{"RaiseEvent", "DropAward", "Setting/Npc/DropFile/RandomFuben/House_A/lisan.tab", 4753, 5430},	
			{"SetFubenProgress", 100, "擊退狼王"},	
			{"RaiseEvent", "AddMissionScore", 12},
			{"OpenWindow", "LingJueFengLayerPanel", "Win"},
			{"GameWin"},
		},
	},
	[10] = {nTime = 90, nNum = 0,
		tbPrelock = {2},
		tbStartEvent = 
		{
			{"SetShowTime", 10},
		},
		tbUnLockEvent = 
		{
			{"RaiseEvent", "AddMissionScore", 8},
			{"BlackMsg", "這些狼群真是厲害，還是趕緊離去為妙！"},
			{"OpenWindow", "LingJueFengLayerPanel", "Fail"},
			{"GameLost"},
		},
	},

	--李三死亡
	[11] = {nTime = 0, nNum = 1,
		tbPrelock = {2},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"RaiseEvent", "AddMissionScore", 8},
			{"BlackMsg", "這些狼群真是厲害，還是趕緊離去為妙！"},
			{"OpenWindow", "LingJueFengLayerPanel", "Fail"},
			{"GameLost"},
		},
	},
}

