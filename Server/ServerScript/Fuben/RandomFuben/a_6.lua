
local tbFubenSetting = Fuben.RandomFuben:GetRandomFubenSetting("a_6");

tbFubenSetting.tbMultiBeginPoint = {{4969, 1587},{5268, 1587},{4980, 1328},{5257, 1317}}	-- 副本出生点
tbFubenSetting.tbTempRevivePoint = {5112, 1460};
tbFubenSetting.nStartDir		 = 0;


--NPC模版ID，NPC等级，NPC五行；

--[[

256	猛虎
650	石碑
255 猛虎·精英

]]


tbFubenSetting.NPC = 
{
	[1] = {nTemplate = 1315, nLevel = -1, nSeries = -1},  --猛虎
	[2] = {nTemplate = 1316, nLevel = -1, nSeries = -1},  --虎王
	[3] = {nTemplate = 650,  nLevel = -1, nSeries = 0},   --石碑
	[4] = {nTemplate = 264,  nLevel = -1, nSeries = 0},   --机关技能
	[5] = {nTemplate = 104,  nLevel = -1, nSeries = 0},   --动态障碍墙
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
			{"AddNpc", 5, 2, 1, "wall", "wall_1_1",false, 15},
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
			{"SetTargetPos", 3869, 2515},	
		},
	},
	[3] = {nTime = 0, nNum = 1,
		tbPrelock = {2},
		tbStartEvent = 
		{			
			{"SetFubenProgress", 0, "探索凌絕峰"},
			{"TrapUnlock", "TrapLock1", 3},

			--石碑
			{"AddNpc", 3, 1, 4, "jiguan", "RandomFuben1_6_jiguan1", false, 0, 0, 0, 0},
			{"AddNpc", 4, 1, 4, "npc", "RandomFuben1_6_jiguan1", false, 0, 0, 0, 0},
		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},
			{"BlackMsg", "這竹林內怎麼會有這些奇怪的石碑？"},
			{"SetFubenProgress", 20, "調查石碑"},
		},
	},
	[4] = {nTime = 0, nNum = 1,
		tbPrelock = {3},
		tbStartEvent = 
		{			
		},
		tbUnLockEvent = 
		{
			{"CastSkill", "npc", 1552, 1, -1, -1},
			{"SetFubenProgress", 40, "擊退敵人"},

			--猛虎
			{"AddNpc", 1, 4, 5, "guaiwu", "RandomFuben1_6_1", false, 0, 0, 0, 0},		
			{"AddNpc", 1, 4, 5, "guaiwu", "RandomFuben1_6_2", false, 0, 4, 0, 0},
		},
	},
	[5] = {nTime = 0, nNum = 8,
		tbPrelock = {4},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"DelNpc", "npc"},	
			{"BlackMsg", "這條路危機四伏，大夥還是小心為上！"},
			{"SetFubenProgress", 60, "繼續前進"},
			{"OpenDynamicObstacle", "ops2"},	
			{"SetTargetPos", 3134, 4900},

			--掉落房间奖励
			{"RaiseEvent", "DropAward", "Setting/Fuben/RandomFuben/HouseAward/A.tab", 2879, 2746},		
			{"RaiseEvent", "DropAward", "Setting/Fuben/RandomFuben/HouseAward/A.tab", 2875, 2426},								
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
			{"SetFubenProgress", 70, "調查石碑"},
		},
	},
	[7] = {nTime = 0, nNum = 1,
		tbPrelock = {6},
		tbStartEvent = 
		{
			{"AddNpc", 3, 1, 7, "jiguan", "RandomFuben1_6_jiguan2", false, 0, 0, 0, 0},
			{"AddNpc", 4, 1, 7, "npc", "RandomFuben1_6_jiguan2", false, 0, 0, 0, 0},
		},
		tbUnLockEvent = 
		{
			{"CastSkill", "npc", 1568, 1, -1, -1},
			{"SetFubenProgress", 80, "擊退敵人"},

			--虎王 & 猛虎
			{"AddNpc", 2, 1, 8, "BOSS", "RandomFuben1_6_BOSS", false, 0, 1, 9011, 1},
			{"AddNpc", 1, 6, 8, "guaiwu", "RandomFuben1_6_3", false, 0, 3, 0, 0},
		},
	},
	[8] = {nTime = 0, nNum = 7,
		tbPrelock = {7},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			--掉落房间奖励
			{"RaiseEvent", "DropAward", "Setting/Fuben/RandomFuben/HouseAward/A.tab", 3670, 5429},
			{"RaiseEvent", "DropAward", "Setting/Fuben/RandomFuben/HouseAward/A.tab", 3929, 5205},
			{"RaiseEvent", "AddMissionScore", 12},
			{"SetFubenProgress", 100, "擊退敵人"},
			{"OpenWindow", "LingJueFengLayerPanel", "Win"},
			{"GameWin"},
		},
	},
	[9] = {nTime = 90, nNum = 0,
		tbPrelock = {2},
		tbStartEvent = 
		{
			{"SetShowTime", 9},
		},
		tbUnLockEvent = 
		{
			{"RaiseEvent", "AddMissionScore", 8},
			{"BlackMsg", "這條路上危險重重，還是選擇別的路上山吧！"},
			{"OpenWindow", "LingJueFengLayerPanel", "Fail"},
			{"GameLost"},
		},
	},
}

