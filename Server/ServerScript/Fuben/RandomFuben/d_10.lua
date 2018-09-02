
local tbFubenSetting = Fuben.RandomFuben:GetRandomFubenSetting("d_10");

tbFubenSetting.tbMultiBeginPoint = {{7478, 2818},{7769, 2954},{7636, 2537},{7920, 2670}}	-- 副本出生点
tbFubenSetting.tbTempRevivePoint = {7682, 2751};
tbFubenSetting.nStartDir		 = 57;


--NPC模版ID，NPC等级，NPC五行；

--[[

447  霹雳火

]]

tbFubenSetting.NPC = 
{
	[1] = {nTemplate = 1608, nLevel = -1, nSeries = -1},  --流浪剑客
	[2] = {nTemplate = 1625, nLevel = -1, nSeries = -1},  --劲弩手
	[3] = {nTemplate = 1609, nLevel = -1, nSeries = -1},  --神秘剑客
	[4] = {nTemplate = 104,  nLevel = -1, nSeries = 0},   --动态障碍墙
	[5] = {nTemplate = 74,   nLevel = -1, nSeries = 0},   --上升气流
	[6] = {nTemplate = 1583, nLevel = -1, nSeries = 0},   --何暮雪
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
			{"AddNpc", 4, 2, 1, "wall", "wall_1_1",false, 10},
			{"OpenWindow", "LingJueFengLayerPanel", "Info",3, 9, "第四層 熔岩密洞"},
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
			{"ShowTaskDialog", 10003, false},
			{"DoDeath", "wall"},
			{"OpenDynamicObstacle", "ops1"},
			{"SetTargetPos", 7057, 3639},	

			--稀有几率
			{"Random", {350000, 30}},
		},
	},
	[3] = {nTime = 0, nNum = 1,
		tbPrelock = {2},
		tbStartEvent = 
		{
			{"SetFubenProgress", 0, "探索熔岩秘洞"},
			{"TrapUnlock", "TrapLock1", 3},
		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},
			{"SetFubenProgress", 20, "擊敗流浪劍客"},

			--流浪剑客
			{"AddNpc", 1, 4, 4, "guaiwu", "RandomFuben4_10_1",false, 0, 0, 0, 0},
			{"AddNpc", 2, 4, 4, "guaiwu", "RandomFuben4_10_2",false, 0, 2, 9005, 0.5},
		},
	},
	[4] = {nTime = 0, nNum = 8,
		tbPrelock = {3},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			--掉落房间奖励
			{"RaiseEvent", "DropAward", "Setting/Fuben/RandomFuben/HouseAward/D.tab", 6781, 4084},

			{"SetFubenProgress", 40, "探索熔岩秘洞"},
			{"SetTargetPos", 3713, 5886},	
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
			{"SetFubenProgress", 60, "擊敗流浪劍客"},

			--流浪剑客 & 劲弩手
			{"AddNpc", 1, 4, 6, "guaiwu", "RandomFuben4_10_3",false, 0, 0, 0, 0},
			{"AddNpc", 2, 4, 6, "guaiwu", "RandomFuben4_10_4",false, 0, 2, 9005, 0.5},
		},
	},
	[6] = {nTime = 0, nNum = 8,
		tbPrelock = {5},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			--掉落房间奖励
			{"RaiseEvent", "DropAward", "Setting/Fuben/RandomFuben/HouseAward/D.tab", 3341, 6554},
			{"SetFubenProgress", 80, "擊敗流浪劍客"},

			--上升气流
			{"AddNpc", 5, 1, 0, "qinggong", "RandomFuben4_10_qinggong",false, 0, 0, 0, 0},
			{"SetTargetPos", 4442, 7113},	
			{"ChangeTrap", "Jump1", nil, {4830, 7403, 2}},
			{"ChangeTrap", "Jump2", nil, {4953, 8031, 2}},
			{"ChangeTrap", "Jump3", nil, {5524, 8285, 2}},	
		},
	},
	[7] = {nTime = 0, nNum = 1,
		tbPrelock = {6},
		tbStartEvent = 
		{			
			{"TrapUnlock", "Jump1", 7},
		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},
		},
	},
	[8] = {nTime = 0, nNum = 1,
		tbPrelock = {7},
		tbStartEvent = 
		{			
			{"TrapUnlock", "Jump3", 8},
		},
		tbUnLockEvent = 
		{
			{"SetTargetPos", 5933, 9073},	
		},
	},
	[9] = {nTime = 0, nNum = 1,
		tbPrelock = {8},
		tbStartEvent = 
		{
			{"TrapUnlock", "TrapLock3", 9},
		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},
			{"SetFubenProgress", 80, "擊敗神秘劍客"},

			--神秘剑客 & 流浪剑客
			{"AddNpc", 3, 1, 10, "BOSS", "RandomFuben4_10_BOSS",false, 0, 1, 9011, 1},
			{"AddNpc", 1, 5, 10, "guaiwu", "RandomFuben4_10_5",false, 0, 3, 9005, 0.5},
		},
	},

-------------胜利判定------------------------
	[10] = {nTime = 0, nNum = 6,
		tbPrelock = {9},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
		},
	},
	[11] = {nTime = 0.1, nNum = 0,
		tbPrelock = {10},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			--掉落房间奖励
			{"RaiseEvent", "DropAward", "Setting/Fuben/RandomFuben/HouseAward/D.tab", 6174, 9646},
			{"RaiseEvent", "DropAward", "Setting/Fuben/RandomFuben/HouseAward/D.tab", 6456, 9435},

			{"SetFubenProgress", 100, "擊敗神秘劍客"},

			--判断模式获得积分
			{"RaiseEvent", "AddMissionScore", "d_score_win"},
			
			{"OpenWindow", "LingJueFengLayerPanel", "Win"},
			{"GameWin"},
		},
	},
-------------闯关时间------------------------
	
	[12] = {nTime = "d_10_time", nNum = 0,
		tbPrelock = {2},
		tbStartEvent = 
		{
			{"SetShowTime", 12},
		},
		tbUnLockEvent = 
		{
			{"BlackMsg", "這神秘劍客的武藝當真非同凡響！"},

			--判断模式获得积分
			{"RaiseEvent", "AddMissionScore", "d_score_lost"},

			{"OpenWindow", "LingJueFengLayerPanel", "Fail"},
			{"GameLost"},
		},
	},

	--稀有锁
	[30] = {nTime = 0, nNum = 1,
		tbPrelock = {},
		tbStartEvent = 
		{
			{"TrapUnlock", "Xiyou", 30},

			--何暮雪
			{"AddNpc", 6, 1, 34, "Hemuxue", "RandomFuben4_10_Xiyou",false, 55 , 0, 0, 0},
		},
		tbUnLockEvent = 
		{
			{"NpcBubbleTalk", "Hemuxue", "沒想到會在這裡碰到你們，我們一起前進吧！", 4, 1, 1},
		},
	},
	[31] = {nTime = 1, nNum = 0,
		tbPrelock = {30, 4},
		tbStartEvent = 
		{
			{"ChangeNpcAi", "Hemuxue", "Move", "Path1", 0, 1, 1, 0, 0},	
		},
		tbUnLockEvent = 
		{
	
		},
	},
	[32] = {nTime = 0, nNum = 1,
		tbPrelock = {31, 6},
		tbStartEvent = 
		{
			{"ChangeNpcAi", "Hemuxue", "Move", "Path2", 32, 1, 1, 0, 0},	
		},
		tbUnLockEvent = 
		{
			{"SetNpcPos", "Hemuxue", 6016, 9126},
		},
	},
	[33] = {nTime = 1, nNum = 0,
		tbPrelock = {30, 10},
		tbStartEvent = 
		{
			{"RaiseEvent", "DropAward", "Setting/Npc/DropFile/RandomFuben/House_D/hemuxue.tab", 6262, 9739},
			{"RaiseEvent", "DropAward", "Setting/Npc/DropFile/RandomFuben/House_D/hemuxue.tab", 6565, 9587},
			{"RaiseEvent", "DropAward", "Setting/Npc/DropFile/RandomFuben/House_D/hemuxue.tab", 6178, 9564},
			{"RaiseEvent", "DropAward", "Setting/Npc/DropFile/RandomFuben/House_D/hemuxue.tab", 6459, 9412},

			{"RaiseEvent", "DropCard", 2619, 350000},	--卡片收集掉落
		},
		tbUnLockEvent = 
		{				
		},
	},

	--何暮雪死亡锁
	[34] = {nTime = 0, nNum = 1,
		tbPrelock = {30},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"CloseLock", 33},
		},
	},
}

