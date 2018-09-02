
local tbFubenSetting = Fuben.RandomFuben:GetRandomFubenSetting("d_8");


tbFubenSetting.tbMultiBeginPoint = {{1970, 1633},{2141, 1625},{1959, 1483},{2119, 1461}}
tbFubenSetting.tbTempRevivePoint = {1970, 1633};
tbFubenSetting.nStartDir		 = 4;


tbFubenSetting.NPC = 
{
	[1] = {nTemplate = 1585, nLevel = -1, nSeries = -1}, --蒙面杀手
	[2] = {nTemplate = 1586, nLevel = -1, nSeries = -1}, --杀手精英
	[3] = {nTemplate = 1587, nLevel = -1, nSeries = -1}, --杀手头目
	[4] = {nTemplate = 104,  nLevel = -1, nSeries = 0},  --门
	[5] = {nTemplate = 1580, nLevel = -1, nSeries = 0},  --何暮雪
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
			{"AddNpc", 4, 2, 0, "wall_1", "wall_1_1",false, 16},
			{"OpenWindow", "LingJueFengLayerPanel", "Info",3, 9, "第四層 峰頂幻境"},
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
		    {"DoDeath", "wall_1"},
		    {"AddNpc", 4, 1, 0, "wall_2", "wall_1_2",false, 23},
			{"OpenDynamicObstacle", "ops1"},
			{"ShowTaskDialog", 10003, false},
			{"SetFubenProgress", 0, "探索凌絕峰"},
			{"SetTargetPos", 2434, 2645},

			--稀有几率
			{"Random", {350000, 30}},
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
			{"SetFubenProgress", 20, "擊敗蒙面刺客"},

			--蒙面杀手 & 杀手精英
			{"AddNpc", 1, 6, 4, "guaiwu", "RandomFuben4_8_1", false, 0, 0, 0, 0},
			{"AddNpc", 2, 1, 4, "Elite", "RandomFuben4_8_Elite", false, 0, 1, 9011, 1},
			{"AddNpc", 1, 6, 4, "guaiwu", "RandomFuben4_8_2", false, 0, 3, 9009, 0.5},
		},
	},
	[4] = {nTime = 0, nNum = 13,
		tbPrelock = {3},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"SetFubenProgress", 50, "探索凌絕峰"},
		    {"DoDeath", "wall_2"},
			{"OpenDynamicObstacle", "ops2"},			

			--掉落房间奖励
			{"RaiseEvent", "DropAward", "Setting/Fuben/RandomFuben/HouseAward/D.tab", 3069, 3683},
			{"RaiseEvent", "DropAward", "Setting/Fuben/RandomFuben/HouseAward/D.tab", 3343, 3501},

			{"SetTargetPos", 3816, 4275},

			--杀手头目 
			{"AddNpc", 3, 1, 6, "BOSS", "RandomFuben4_8_BOSS", false, 0, 0, 0, 0},
			{"SetNpcProtected", "BOSS", 1},
			{"SetAiActive", "BOSS", 0},	
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
			{"SetFubenProgress", 80, "擊敗刺客頭目"},
			{"SetNpcProtected", "BOSS", 0},
			{"SetAiActive", "BOSS", 1},	

			--蒙面杀手 
			{"AddNpc", 1, 8, 6, "guaiwu", "RandomFuben4_8_3", false, 0, 4, 9009, 0.5},
		},
	},

-------------胜利判定------------------------
	[6] = {nTime = 0, nNum = 9,
		tbPrelock = {4},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{								
		},
	},
	[7] = {nTime = 0.1, nNum = 0,
		tbPrelock = {6},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			--掉落房间奖励
			{"RaiseEvent", "DropAward", "Setting/Fuben/RandomFuben/HouseAward/D.tab", 4140, 4903},
			{"RaiseEvent", "DropAward", "Setting/Fuben/RandomFuben/HouseAward/D.tab", 4298, 4766},
			
			{"SetFubenProgress", 100, "擊敗刺客頭目"},

			--判断模式获得积分
			{"RaiseEvent", "AddMissionScore", "d_score_win"},
			
			{"OpenWindow", "LingJueFengLayerPanel", "Win"},
			{"GameWin"},										
		},
	},
-------------闯关时间------------------------
	[8] = {nTime = "d_8_time", nNum = 0,    --总计时
		tbPrelock = {2},
		tbStartEvent = 
		{
			{"SetShowTime", 8},
		},
		tbUnLockEvent = 
		{
			{"BlackMsg", "好險，差點就小命不保！"},
			
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
			{"AddNpc", 5, 1, 33, "Hemuxue", "RandomFuben4_8_Xiyou",false, 8 , 0, 0, 0},
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
	[32] = {nTime = 1, nNum = 0,
		tbPrelock = {31, 6},
		tbStartEvent = 
		{
			{"RaiseEvent", "DropAward", "Setting/Npc/DropFile/RandomFuben/House_D/hemuxue.tab", 4202, 4969 },
			{"RaiseEvent", "DropAward", "Setting/Npc/DropFile/RandomFuben/House_D/hemuxue.tab", 4435, 4853},
			{"RaiseEvent", "DropAward", "Setting/Npc/DropFile/RandomFuben/House_D/hemuxue.tab", 4044, 4824},
			{"RaiseEvent", "DropAward", "Setting/Npc/DropFile/RandomFuben/House_D/hemuxue.tab", 4236, 4687},

			{"RaiseEvent", "DropCard", 2619, 350000},	--卡片收集掉落
		},
		tbUnLockEvent = 
		{				
		},
	},

	--何暮雪死亡锁
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

