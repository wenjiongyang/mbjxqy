
local tbFubenSetting = Fuben.RandomFuben:GetRandomFubenSetting("a_2");

tbFubenSetting.tbMultiBeginPoint = {{4969, 1587},{5268, 1587},{4980, 1328},{5257, 1317}}	-- 副本出生点
tbFubenSetting.tbTempRevivePoint = {5112, 1460};
tbFubenSetting.nStartDir		 = 0;


--NPC模版ID，NPC等级，NPC五行；

--[[

]]

tbFubenSetting.NPC = 
{
	[1] = {nTemplate = 270, nLevel = -1, nSeries = -1}, --金钱豹
	[2] = {nTemplate = 271, nLevel = -1, nSeries = -1}, --金钱豹王
	[3] = {nTemplate = 104, nLevel = -1, nSeries = 0}, --动态障碍墙
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
			{"SetTargetPos", 3843, 2549},
		},
	},
	[3] = {nTime = 0, nNum = 1,
		tbPrelock = {2},
		tbStartEvent = 
		{
			{"TrapUnlock", "TrapLock1", 3},
			{"SetFubenProgress", 0, "探索凌絕峰"},
		},
		tbUnLockEvent = 
		{
			{"BlackMsg", "糟糕，似乎是遇到豹群了！"},
			{"ClearTargetPos"},
			{"SetFubenProgress", 20, "擊退金錢豹"},

			--金钱豹
			{"AddNpc", 1, 4, 4, "guaiwu", "RandomFuben1_2_1",false, 0, 0, 0, 0},
		},
	},
	[4] = {nTime = 0, nNum = 4,
		tbPrelock = {3},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"SetFubenProgress", 40, "擊退金錢豹"},	

			--金钱豹
			{"AddNpc", 1, 5, 5, "guaiwu", "RandomFuben1_2_2",false, 0, 0, 0, 0},
		},
	},
	[5] = {nTime = 0, nNum = 5,
		tbPrelock = {4},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			--掉落房间奖励
			{"RaiseEvent", "DropAward", "Setting/Fuben/RandomFuben/HouseAward/A.tab", 2999, 2790},
			{"RaiseEvent", "DropAward", "Setting/Fuben/RandomFuben/HouseAward/A.tab", 2808, 2370},
			{"SetFubenProgress", 60, "擊退金錢豹"},
			{"OpenDynamicObstacle", "ops2"},	
			{"SetTargetPos", 3104, 4892},
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
			{"SetFubenProgress", 80, "擊退金錢豹"},	
			{"BlackMsg", "沒想到這條路上竟有如此多的野獸！"},

			--金钱豹
			{"AddNpc", 1, 5, 7, "guaiwu", "RandomFuben1_2_3",false, 0, 0, 0, 0},
			{"AddNpc", 2, 1, 7, "guaiwu", "RandomFuben1_2_BOSS",false, 0, 1, 9011, 1},
		},
	},
	[7] = {nTime = 0, nNum = 6,
		tbPrelock = {6},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"RaiseEvent", "DropAward", "Setting/Fuben/RandomFuben/HouseAward/A.tab", 3657, 5327},
			{"RaiseEvent", "DropAward", "Setting/Fuben/RandomFuben/HouseAward/A.tab", 3916, 5113},
			{"SetFubenProgress", 100, "擊退金錢豹"},	
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
			{"OpenWindow", "LingJueFengLayerPanel", "Fail"},
			{"BlackMsg", "這群野獸兇猛異常，得暫避鋒芒才行！"},
			{"GameLost"},
		},
	},
}

