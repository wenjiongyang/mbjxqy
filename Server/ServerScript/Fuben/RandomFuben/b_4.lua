
local tbFubenSetting = Fuben.RandomFuben:GetRandomFubenSetting("b_4");

tbFubenSetting.tbMultiBeginPoint = {{1738, 4371},{1755, 3965},{1434, 4374},{1431, 3936}}	-- 副本出生点
tbFubenSetting.tbTempRevivePoint = {1555, 4143}
tbFubenSetting.nStartDir		 = 11;

--NPC模版ID，NPC等级，NPC五行；

--[[

]]

tbFubenSetting.NPC = 
{
	[1] = {nTemplate = 1614, nLevel = -1, nSeries = -1},  --猛虎
	[2] = {nTemplate = 1615, nLevel = -1, nSeries = -1},  --虎王
	[3] = {nTemplate = 104,  nLevel = -1, nSeries = 0},   --动态障碍墙
	[4] = {nTemplate = 1553, nLevel = -1, nSeries = 0},   --小殷方（稀有） 
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
			{"AddNpc", 3, 2, 1, "wall", "wall_1_1",false, 32},
			{"OpenWindow", "LingJueFengLayerPanel", "Info",3, 9, "第二層 後山小道"},
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
			{"ShowTaskDialog", 10001, false},
			{"DoDeath", "wall"},
			{"OpenDynamicObstacle", "ops1"},

			--稀有几率
			{"Random", {350000, 30}},
		},
	},
	[3] = {nTime = 0, nNum = 1,
		tbPrelock = {2},
		tbStartEvent = 
		{
			{"ChangeFightState", 1},
			{"SetFubenProgress", 0, "探索凌絕峰"},
			{"TrapUnlock", "TrapLock1", 3},
			{"SetTargetPos", 2883, 4137},
		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},
			{"SetFubenProgress", 20, "擊退猛虎"},
			{"BlackMsg", "沒想到會在這裡遇到虎群，速速解決牠們吧！"},

			--猛虎
			{"AddNpc", 1, 5, 4, "guaiwu", "RandomFuben2_4_1",false, 0 , 0, 0, 0},
			{"AddNpc", 1, 4, 4, "guaiwu", "RandomFuben2_4_2",false, 0 , 3, 0, 0},
		},
	},
	[4] = {nTime = 0, nNum = 9,
		tbPrelock = {3},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"SetFubenProgress", 40, "擊退猛虎"},
			{"SetTargetPos", 6153, 4733},
			{"RaiseEvent", "DropAward", "Setting/Fuben/RandomFuben/HouseAward/B.tab", 4421, 3783},
			{"RaiseEvent", "DropAward", "Setting/Fuben/RandomFuben/HouseAward/B.tab", 4356, 3432},	
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
			{"SetFubenProgress", 60, "擊退猛虎"},

			--猛虎
			{"AddNpc", 1, 4, 6, "guaiwu", "RandomFuben2_4_3",false, 0 , 0, 0, 0},
		},
	},
	[6] = {nTime = 0, nNum = 4,
		tbPrelock = {5},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"SetFubenProgress", 80, "擊退猛虎"},
			{"AddNpc", 1, 4, 7, "guaiwu", "RandomFuben2_4_4",false, 0 , 0, 0, 0},
			{"AddNpc", 2, 1, 7, "BOSS", "RandomFuben2_4_BOSS",false, 0 , 1, 9011, 1},
		},
	},

-------------胜利判定------------------------
	[7] = {nTime = 0, nNum = 5,
		tbPrelock = {6},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
		},
	},
	[8] = {nTime = 0.1, nNum = 0,
		tbPrelock = {7},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"RaiseEvent", "DropAward", "Setting/Fuben/RandomFuben/HouseAward/B.tab", 5547, 6196},
			{"RaiseEvent", "DropAward", "Setting/Fuben/RandomFuben/HouseAward/B.tab", 5212, 6086},	

			--判断模式获得积分
			{"RaiseEvent", "AddMissionScore", "b_score_win"},
			
			{"OpenWindow", "LingJueFengLayerPanel", "Win"},
			{"GameWin"},
		},
	},
-------------闯关时间------------------------
	[9] = {nTime = "b_4_time", nNum = 0,
		tbPrelock = {2},
		tbStartEvent = 
		{
			{"SetShowTime", 9},
		},
		tbUnLockEvent = 
		{
			--判断模式获得积分
			{"RaiseEvent", "AddMissionScore", "b_score_lost"},

			{"BlackMsg", "這群老虎實在太厲害了，趕緊撤！"},
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

			--殷方
			{"AddNpc", 4, 1, 33, "Yinfang", "RandomFuben2_4_Xiyou",false, 22 , 0, 0, 0},
		},
		tbUnLockEvent = 
		{
			{"ChangeNpcAi", "Yinfang", "Move", "Path1", 0, 1, 1, 0, 0},	
			{"NpcBubbleTalk", "Yinfang", "沒想到會在這裡碰到你們，我們一起前進吧！", 4, 1, 1},
		},
	},
	[31] = {nTime = 1, nNum = 0,
		tbPrelock = {30, 4},
		tbStartEvent = 
		{
			{"ChangeNpcAi", "Yinfang", "Move", "Path2", 0, 1, 1, 0, 0},	
		},
		tbUnLockEvent = 
		{
			
		},
	},
	[32] = {nTime = 1, nNum = 0,
		tbPrelock = {31, 7},
		tbStartEvent = 
		{
			{"RaiseEvent", "DropAward", "Setting/Npc/DropFile/RandomFuben/House_B/yinfang.tab", 5203, 6114},
			{"RaiseEvent", "DropAward", "Setting/Npc/DropFile/RandomFuben/House_B/yinfang.tab", 5472, 6283},
		},
		tbUnLockEvent = 
		{				
		},
	},

	--小殷方死亡锁
	[33] = {nTime = 0, nNum = 1,
		tbPrelock = {30},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"CloseLock", 32},
		},
	},
}

