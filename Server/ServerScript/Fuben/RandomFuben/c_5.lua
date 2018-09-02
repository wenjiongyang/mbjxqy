
local tbFubenSetting = Fuben.RandomFuben:GetRandomFubenSetting("c_5");

tbFubenSetting.tbMultiBeginPoint = {{1068, 1338},{1248, 1194},{900, 1191},{1105, 1048}}	-- 副本出生点
tbFubenSetting.tbTempRevivePoint = {1068, 1338}
tbFubenSetting.nStartDir		 = 8;


--NPC模版ID，NPC等级，NPC五行；
tbFubenSetting.NPC = 
{
	[1] = {nTemplate = 998,  nLevel = -1,  nSeries = -1},   --金兵
	[2] = {nTemplate = 999,  nLevel = -1,  nSeries = -1},   --十夫长-精英
	[3] = {nTemplate = 1000, nLevel = -1,  nSeries = -1},   --天忍教徒
	[4] = {nTemplate = 1001, nLevel = -1,  nSeries = -1},   --天忍高手-精英
	[5] = {nTemplate = 1572, nLevel = -1,  nSeries = 0},   --唐潇(稀有)
	[6] = {nTemplate = 104,  nLevel = -1,  nSeries = 0},    --墙
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
		    {"AddNpc", 6, 1, 0, "wall", "wall_1_1",false, 25},
		    {"OpenWindow", "LingJueFengLayerPanel", "Info",3, 9, "第三層 石壁懸崖"},
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
			{"OpenDynamicObstacle", "obs"},
			{"ShowTaskDialog", 10001, false},
			{"DoDeath", "wall"},

			--稀有几率
			{"Random", {350000, 30}},
		},
	},
	[3] = {nTime = 0, nNum = 1,
		tbPrelock = {2},
		tbStartEvent = 
		{	
			{"TrapUnlock", "TrapLock1", 3},	
			{"SetFubenProgress", 0, "探索凌絕峰"},
			{"SetTargetPos", 1746, 1957},
		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},
			{"SetFubenProgress", 20, "擊敗金兵"},
			{"AddNpc", 1, 6, 4, "guaiwu", "RandomFuben3_5_1",false, 0},
			{"AddNpc", 1, 6, 4, "guaiwu", "RandomFuben3_5_2",false, 0},
			{"BlackMsg", "此處竟會有這麼多金兵，不知他們有什麼陰謀？"},
		},
	},
	[4] = {nTime = 0, nNum = 12,
		tbPrelock = {3},
		tbStartEvent = 
		{	
		},
		tbUnLockEvent = 
		{
			{"SetFubenProgress", 40, "探索凌絕峰"},
			{"SetTargetPos", 4634, 3625},
			{"OpenDynamicObstacle", "ops1"},

			--掉落房间奖励
			{"RaiseEvent", "DropAward", "Setting/Fuben/RandomFuben/HouseAward/C.tab", 4222, 3129},
			{"RaiseEvent", "DropAward", "Setting/Fuben/RandomFuben/HouseAward/C.tab", 4515, 2977},
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
			{"SetFubenProgress", 60, "擊敗天忍教徒"},				
		    {"AddNpc", 3, 6, 6, "guaiwu", "RandomFuben3_5_3",false, 0},
		},
	},
	[6] = {nTime = 0, nNum = 6,
		tbPrelock = {5},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"SetFubenProgress", 80, "擊敗天忍高手"},	
			{"AddNpc", 4, 1, 7, "BOSS", "RandomFuben3_5_BOSS", false, 0, 1, 9011, 1},
			{"NpcBubbleTalk", "BOSS", "看來你們還有些本事，那就讓我來收拾你們吧！", 5, 3, 1},
		},
	},
-------------胜利判定------------------------
	[7] = {nTime = 0, nNum = 1,
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
			--掉落房间奖励
			{"RaiseEvent", "DropAward", "Setting/Fuben/RandomFuben/HouseAward/C.tab", 4472, 4517},
			{"RaiseEvent", "DropAward", "Setting/Fuben/RandomFuben/HouseAward/C.tab", 4873, 4533},

			--判断模式获得积分
			{"RaiseEvent", "AddMissionScore", "c_score_win"},

			{"SetFubenProgress", 100, "擊敗天忍高手"},
			{"OpenWindow", "LingJueFengLayerPanel", "Win"},
			{"GameWin"},  
		},
	},
-------------闯关时间和积分------------------------
	[9] = {nTime = "c_5_time", nNum = 0,     --总计时
		tbPrelock = {2},
		tbStartEvent = 
		{
		    {"SetShowTime", 9},
		},
		tbUnLockEvent = 
		{
			--判断模式获得积分
			{"RaiseEvent", "AddMissionScore", "c_score_lost"},
			
			{"BlackMsg", "這一路真是兇險，我們還是先撤退吧！"},
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

			--唐潇
			{"AddNpc", 5, 1, 34, "Tangxiao", "RandomFuben3_5_Xiyou",false, 4 , 0, 0, 0},
		},
		tbUnLockEvent = 
		{
			{"ChangeNpcAi", "Tangxiao", "Move", "Path1", 31, 0, 1, 0, 0},
			{"NpcBubbleTalk", "Tangxiao", "沒想到會在這裡碰到你們，我們一起前進吧！", 4, 1, 1},
		},
	},
	[31] = {nTime = 0, nNum = 1,
		tbPrelock = {30},
		tbStartEvent = 
		{
			
		},
		tbUnLockEvent = 
		{
			{"ChangeNpcAi", "Tangxiao", "Move", "Path2", 0, 1, 1, 0, 0},	
		},
	},
	[32] = {nTime = 1, nNum = 0,
		tbPrelock = {30, 4},
		tbStartEvent = 
		{
			{"ChangeNpcAi", "Tangxiao", "Move", "Path3", 0, 1, 1, 0, 0},	
		},
		tbUnLockEvent = 
		{
			
		},
	},
	[33] = {nTime = 1, nNum = 0,
		tbPrelock = {30, 7},
		tbStartEvent = 
		{
			{"RaiseEvent", "DropAward", "Setting/Npc/DropFile/RandomFuben/House_C/tangxiao.tab", 4646, 4756},
			{"RaiseEvent", "DropAward", "Setting/Npc/DropFile/RandomFuben/House_C/tangxiao.tab", 4519, 4572},
			{"RaiseEvent", "DropAward", "Setting/Npc/DropFile/RandomFuben/House_C/tangxiao.tab", 4811, 4566},

			{"RaiseEvent", "DropCard", 2597, 350000},	--卡片收集掉落
		},
		tbUnLockEvent = 
		{				
		},
	},

	--唐潇死亡锁
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

