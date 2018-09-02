
local tbFubenSetting = Fuben.RandomFuben:GetRandomFubenSetting("a_4");

tbFubenSetting.tbMultiBeginPoint = {{1481, 600},{1914, 587},{1462, 342},{1874, 311}}	-- 副本出生点
tbFubenSetting.tbTempRevivePoint = {1644, 455}
tbFubenSetting.nStartDir		 = 61;	


--NPC模版ID，NPC等级，NPC五行；

--[[

]]

tbFubenSetting.NPC = 
{
	[1] = {nTemplate = 258, nLevel = -1, nSeries = -1},  --火狐
	[2] = {nTemplate = 259, nLevel = -1, nSeries = -1},  --火狐王
	[3] = {nTemplate = 74,  nLevel = -1, nSeries = 0},  --上升气流
	[4] = {nTemplate = 104, nLevel = -1, nSeries = 0},  --动态障碍墙
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
			{"AddNpc", 4, 2, 1, "wall", "wall_1_1",false, 17},
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
		},
	},
	[3] = {nTime = 0, nNum = 1,
		tbPrelock = {2},
		tbStartEvent = 
		{			
			{"TrapUnlock", "TrapLock1", 3},
			{"SetFubenProgress", 0, "探索凌絕峰"},
			{"SetTargetPos", 2737, 1740},
		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},
			{"BlackMsg", "糟糕，沒想到會碰到火狐群！"},
			{"SetFubenProgress", 20, "擊退火狐"},

			--火狐
			{"AddNpc", 1, 4, 4, "guaiwu", "RandomFuben1_4_1",false, 0 , 0, 0, 0},
		},
	},
	[4] = {nTime = 0, nNum = 4,
		tbPrelock = {3},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			--火狐
			{"AddNpc", 1, 5, 5, "guaiwu", "RandomFuben1_4_2",false, 0 , 0, 0, 0},
			{"SetFubenProgress", 40, "擊退火狐"},
		},
	},
	[5] = {nTime = 0, nNum = 5,
		tbPrelock = {4},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"RaiseEvent", "DropAward", "Setting/Fuben/RandomFuben/HouseAward/A.tab", 4108, 1610},
			{"RaiseEvent", "DropAward", "Setting/Fuben/RandomFuben/HouseAward/A.tab", 4124, 1800},
			{"SetFubenProgress", 60, "擊退火狐"},
			{"BlackMsg", "看來只有將牠們全部擊退才能繼續前進了！"},
			{"SetTargetPos", 5163, 2201},
			{"AddNpc", 3, 1, 5, "qinggong", "RandomFuben1_4_qinggong", 1},
			{"ChangeTrap", "Jump1", nil, {5152, 2652, 2}},
			{"ChangeTrap", "Jump2", nil, {5146, 3143, 2}},	
			{"ChangeTrap", "Jump3", nil, {5129, 3731, 2}},	
		},
	},	
	[6] = {nTime = 0, nNum = 1,
		tbPrelock = {5},
		tbStartEvent = 
		{
			{"TrapUnlock", "Jump1", 6}, 
		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},
		},
	},
	[7] = {nTime = 0, nNum = 1,
		tbPrelock = {5},
		tbStartEvent = 
		{
			{"TrapUnlock", "TrapLock3", 7}, 
		},
		tbUnLockEvent = 
		{
			{"SetTargetPos", 4452, 4190},
		},
	},
	[8] = {nTime = 0, nNum = 1,
		tbPrelock = {7},
		tbStartEvent = 
		{
			{"TrapUnlock", "TrapLock2", 8},
		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},
			
			--火狐
			{"AddNpc", 1, 5, 9, "guaiwu", "RandomFuben1_4_3",false, 0 , 0, 0, 0},
			{"AddNpc", 2, 1, 9, "guaiwu", "RandomFuben1_4_BOSS",false, 0 , 1, 9011, 1},
			{"SetFubenProgress", 80, "擊退火狐"},
		},
	},
	[9] = {nTime = 0, nNum = 6,
		tbPrelock = {8},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			--掉落房间奖励
			{"RaiseEvent", "DropAward", "Setting/Fuben/RandomFuben/HouseAward/A.tab", 3920, 4353},
			{"RaiseEvent", "DropAward", "Setting/Fuben/RandomFuben/HouseAward/A.tab", 3846, 4211},
			{"RaiseEvent", "AddMissionScore", 12},
			{"OpenWindow", "LingJueFengLayerPanel", "Win"},
			{"SetFubenProgress", 100, "擊退火狐"},	
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
			{"BlackMsg", "這火狐群還真是厲害，還是趕緊撤退為妙！"},
			{"RaiseEvent", "AddMissionScore", 8},
			{"OpenWindow", "LingJueFengLayerPanel", "Fail"},
			{"GameLost"},
		},
	},
}

