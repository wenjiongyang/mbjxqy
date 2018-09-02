
local tbFubenSetting = Fuben.RandomFuben:GetRandomFubenSetting("a_7");

tbFubenSetting.tbMultiBeginPoint = {{843, 1611},{1223, 1658},{923, 1368},{1221, 1953}}	-- 副本出生点
tbFubenSetting.tbTempRevivePoint = {1098, 1834};
tbFubenSetting.nStartDir		 = 0;

--NPC模版ID，NPC等级，NPC五行；

--[[

260	山贼
274	机关
261 山贼·精英
]]


tbFubenSetting.NPC = 
{
	[1] = {nTemplate = 1313, nLevel = -1, nSeries = -1},  --山贼
	[2] = {nTemplate = 1314, nLevel = -1, nSeries = -1},  --山贼头目
	[3] = {nTemplate = 274,  nLevel = -1, nSeries = 0},  --机关
	[4] = {nTemplate = 104,  nLevel = -1, nSeries = 0},  --动态障碍墙
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
			{"SetFubenProgress", -1,"等待秘境開啟"},
			{"AddNpc", 4, 1, 1, "wall_1", "wall_1_1",false, 22},
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
			{"DoDeath", "wall_1"},
			{"OpenDynamicObstacle", "ops1"},
			{"AddNpc", 4, 1, 1, "wall_2", "wall_1_2",false, 32},
			{"AddNpc", 4, 1, 1, "wall_3", "wall_1_3",false, 37},
			{"SetTargetPos", 1744, 4638},
		},
	},
	[3] = {nTime = 0, nNum = 1,
		tbPrelock = {2},
		tbStartEvent = 
		{			
			{"ChangeFightState", 1},
			{"SetFubenProgress", 0, "探索凌絕峰"},
			{"TrapUnlock", "TrapLock1", 3},

			--机关
			{"AddNpc", 3, 1, 4, "jiguan", "RandomFuben1_7_jiguan1", false, 0, 0, 0, 0},
		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},
			{"BlackMsg", "咦？這裡怎麼會有這麼多奇怪的機關？"},
			{"SetFubenProgress", 20, "開啟機關"},
		},
	},
	[4] = {nTime = 0, nNum = 1,
		tbPrelock = {3},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"SetFubenProgress", 40, "擊退山賊"},

			--山贼
			{"AddNpc", 1, 6, 5, "guaiwu", "RandomFuben1_7_1", false, 0, 0, 9005, 0.5},
			{"NpcBubbleTalk", "guaiwu", "又有肥羊送上門了，大夥一起上啊！", 4, 1, 1},	
		},
	},
	[5] = {nTime = 0, nNum = 6,
		tbPrelock = {4},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"SetFubenProgress", 60, "繼續前進"},	
			{"BlackMsg", "這條路有些奇怪，大夥小心為上！"},		
			{"SetTargetPos", 3805, 6238},	
			{"OpenDynamicObstacle", "ops2"},
			{"DoDeath", "wall_2"},

			--掉落房间奖励
			{"RaiseEvent", "DropAward", "Setting/Fuben/RandomFuben/HouseAward/A.tab", 2064, 5154},
			{"RaiseEvent", "DropAward", "Setting/Fuben/RandomFuben/HouseAward/A.tab", 1784, 5107},						
		},
	},
	[6] = {nTime = 0, nNum = 1,
		tbPrelock = {5},
		tbStartEvent = 
		{			
			{"TrapUnlock", "TrapLock2", 6},
			{"AddNpc", 1, 4, 7, "guaiwu", "RandomFuben1_7_2", false, 0, 0, 0, 0},
		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},
			{"SetFubenProgress", 80, "擊退山賊"},
			{"BlackMsg", "糟糕，中埋伏了！"},

			--山贼 & 山贼首领
			{"AddNpc", 1, 4, 7, "guaiwu", "RandomFuben1_7_3", false, 0, 3, 0, 0},
			{"AddNpc", 2, 1, 7, "BOSS", "RandomFuben1_7_BOSS", false, 0, 4, 9011, 1},
			{"NpcBubbleTalk", "guaiwu", "此山是我開，此樹是我栽！要想從此過，留下買路財！", 4, 1, 1},	
			{"NpcBubbleTalk", "BOSS", "乖乖束手就擒吧！", 4, 6, 1},	
		},
	},
	[7] = {nTime = 0, nNum = 9,
		tbPrelock = {5},
		tbStartEvent = 
		{		
		},
		tbUnLockEvent = 
		{
			--掉落房间奖励
			{"RaiseEvent", "DropAward", "Setting/Fuben/RandomFuben/HouseAward/A.tab", 4371, 6442},
			{"RaiseEvent", "DropAward", "Setting/Fuben/RandomFuben/HouseAward/A.tab", 5087, 2579},
			{"RaiseEvent", "AddMissionScore", 12},
			{"SetFubenProgress", 100, "擊退山賊"},
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
			{"BlackMsg", "這些山賊真是厲害，還是趕緊離去為妙！"},
			{"OpenWindow", "LingJueFengLayerPanel", "Fail"},			
			{"GameLost"},
		},
	},
}

