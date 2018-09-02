
local tbFubenSetting = Fuben.RandomFuben:GetRandomFubenSetting("a_3");

tbFubenSetting.tbMultiBeginPoint = {{4969, 1587},{5268, 1587},{4980, 1328},{5257, 1317}}	-- 副本出生点
tbFubenSetting.tbTempRevivePoint = {5112, 1460};
tbFubenSetting.nStartDir		 = 0;

--NPC模版ID，NPC等级，NPC五行；

--[[

]]


tbFubenSetting.NPC = 
{
	[1] = {nTemplate = 1539,  nLevel = -1, nSeries = -1}, --机关人
	[2] = {nTemplate = 1540,  nLevel = -1, nSeries = -1}, --强力机关人
	[3] = {nTemplate = 104,   nLevel = -1, nSeries = 0}, --动态障碍墙
	[4] = {nTemplate = 1541,  nLevel = -1, nSeries = 0}, --莺儿
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
			{"AddNpc", 3, 2, 1, "wall", "wall_1_1",false, 15},
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
			{"SetTargetPos", 4660, 2330},

			--莺儿
			{"AddNpc", 4, 1, 10, "Yinger", "RandomFuben1_3_Yinger",false, 48, 0, 0, 0},
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
			{"ChangeNpcAi", "Yinger", "Move", "Path1", 1, 1, 0, 0, 0},	
			{"NpcBubbleTalk", "Yinger", "凌絕峰山路崎嶇，還請各位俠士能護送小女子一程！", 4, 0, 1},	
		},
	},
	[4] = {nTime = 0, nNum = 1,
		tbPrelock = {3},
		tbStartEvent = 
		{			
			{"SetFubenProgress", 20, "護送鶯兒"},
			{"TrapUnlock", "TrapLock2", 4},
			{"SetTargetPos", 3843, 2549},
		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},
			{"SetFubenProgress", 20, "擊退機關人"},
			{"NpcBubbleTalk", "Yinger", "糟糕，前方出現機關人！趕緊將它們擊退！", 4, 1, 1},

			--机关人
			{"AddNpc", 1, 4, 5, "guaiwu", "RandomFuben1_3_1", false, 0, 0, 0, 0},
			{"AddNpc", 1, 5, 5, "guaiwu", "RandomFuben1_3_2", false, 0, 2, 0, 0},
		},
	},
	[5] = {nTime = 0, nNum = 9,
		tbPrelock = {4},
		tbStartEvent = 
		{			

		},
		tbUnLockEvent = 
		{	
			{"SetFubenProgress", 40, "離開竹林小道"},
			{"SetTargetPos", 3104, 4892},
			-- {"AddNpc", 3, 1, 1, "wall", "wall_1_2",false, 61},
			{"BlackMsg", "護送鶯兒離開此地！！"},	
			{"NpcBubbleTalk", "Yinger", "總算是將這群機關人擊退了，我們繼續前進！", 4, 1, 1},
			{"ChangeNpcAi", "Yinger", "Move", "Path2", 1, 1, 0, 0, 0},	
			{"OpenDynamicObstacle", "ops2"},	
		},
	},
	[6] = {nTime = 0, nNum = 1,
		tbPrelock = {5},
		tbStartEvent = 
		{
			{"TrapUnlock", "TrapLock3", 6},
		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},
			{"NpcBubbleTalk", "Yinger", "糟糕，又遇到這群機關人了，趕緊將他們擊退！", 4, 1, 1},
			{"SetFubenProgress", 60, "擊退機關人"},

			--机关人 & 强力机关人
			{"AddNpc", 1, 5, 7, "guaiwu", "RandomFuben1_3_3", false, 0, 3, 0, 0},
			{"AddNpc", 2, 1, 7, "BOSS", "RandomFuben1_3_BOSS", false, 0, 1, 9011, 1},			
		},
	},
	[7] = {nTime = 0, nNum = 6,
		tbPrelock = {6},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			--掉落首领奖励 ——  莺儿
			{"RaiseEvent", "DropAward", "Setting/Npc/DropFile/RandomFuben/House_A/yinger.tab", 3536, 5177},	
			{"RaiseEvent", "DropAward", "Setting/Npc/DropFile/RandomFuben/House_A/yinger.tab", 3341, 5285},	

			{"SetFubenProgress", 100, "擊退機關人"},	
			{"RaiseEvent", "AddMissionScore", 12},
			{"OpenWindow", "LingJueFengLayerPanel", "Win"},
			{"GameWin"},
		},
	},
	[8] = {nTime = 90, nNum = 0,
		tbPrelock = {2},
		tbStartEvent = 
		{
			{"SetShowTime", 8},
		},
		tbUnLockEvent = 
		{
			{"RaiseEvent", "AddMissionScore", 8},
			{"BlackMsg", "這些機關人還真是厲害，還是趕緊離去為妙！"},
			{"OpenWindow", "LingJueFengLayerPanel", "Fail"},
			{"GameLost"},
		},
	},
}

