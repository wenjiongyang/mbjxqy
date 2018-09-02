
local tbFubenSetting = Fuben.RandomFuben:GetRandomFubenSetting("b_10");

tbFubenSetting.tbMultiBeginPoint = {{1140, 1623},{1129, 1183},{852, 1626},{857, 1194}}	-- 副本出生点
tbFubenSetting.tbTempRevivePoint = {992, 1410}
tbFubenSetting.nStartDir		 = 16;

--NPC模版ID，NPC等级，NPC五行；
tbFubenSetting.NPC = 
{
	[1] = {nTemplate = 818, nLevel = -1, nSeries = 0},    --小殷方-护送
	[2] = {nTemplate = 819, nLevel = -1, nSeries = -1},   --小殷方-首领
	[3] = {nTemplate = 820, nLevel = -1, nSeries = -1},   --藏剑弟子
	[4] = {nTemplate = 821, nLevel = -1, nSeries = -1},   --藏剑高手-中毒
	[5] = {nTemplate = 822, nLevel = -1, nSeries = -1},   --藏剑高手-反射
	[6] = {nTemplate = 104, nLevel = -1, nSeries = 0},    --门
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
			{"AddNpc", 6, 2, 0, "wall", "wall_1_1",false, 32},

			--判断是否为普通模式
			{"IfCase", "not self.bElite", 
				--殷方（护送）
				{"AddNpc", 1, 1, 12, "hs", "RandomFuben2_10_jiantong",false, 12},
			},
			
			--判断是否为噩梦模式
			{"IfCase", "self.bElite", 
				--殷方（护送）
				{"AddNpc", 1, 1, 14, "hs", "RandomFuben2_10_jiantong",false, 12},
			},

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
		    {"DoDeath", "wall"},
			{"OpenDynamicObstacle", "obs"},
			{"ShowTaskDialog", 10001, false},
		},
	},
	[3] = {nTime = 0, nNum = 1,
		tbPrelock = {2},
		tbStartEvent = 
		{
			{"TrapUnlock", "TrapLock1", 3},
			{"SetFubenProgress", 0, "探索凌絕峰"},
			{"SetTargetPos", 1908, 1416},
		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},
			{"SetFubenProgress", 20, "跟隨小殷方"},
			{"ChangeNpcAi", "hs", "Move", "Path1", 4, 1, 1, 0, 0},
			{"NpcBubbleTalk", "hs", "沒想到會在這碰到你們，我們一同前行吧！", 4, 1, 1},
			{"BlackMsg", "跟隨小殷方探索凌絕峰。"},
		},
	},
	[4] = {nTime = 0, nNum = 1,
		tbPrelock = {3},
		tbStartEvent = 
		{
			{"TrapUnlock", "TrapLock2", 4},
		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},
			{"NpcBubbleTalk", "hs", "糟糕，此地有埋伏！", 4, 0, 1},
			{"AddNpc", 3, 6, 5, "guaiwu", "RandomFuben2_10_1",false, 0},
			{"AddNpc", 4, 1, 5, "jy", "RandomFuben2_10_1_Elite1",false, 0},
			{"NpcBubbleTalk", "jy", "你們無路可退了，乖乖束手就擒吧！", 4, 2, 1},
			{"SetFubenProgress", 30, "擊敗藏劍弟子"},
		},
	},
	[5] = {nTime = 0, nNum = 7,
		tbPrelock = {4},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			--掉落房间奖励
			{"RaiseEvent", "DropAward", "Setting/Fuben/RandomFuben/HouseAward/B.tab", 3568, 1886},
			{"RaiseEvent", "DropAward", "Setting/Fuben/RandomFuben/HouseAward/B.tab", 3858, 1692},

			{"SetFubenProgress", 40, "跟隨小殷方"},
			{"SetTargetPos", 4558, 2806},
			{"NpcBubbleTalk", "hs", "看來這些刺客都是卓非凡派來的人，我們得小心前進了！", 4, 1, 1},
			{"ChangeNpcAi", "hs", "Move", "Path2", 7, 1, 1, 0, 0},
			{"BlackMsg", "繼續跟隨小殷方前行"},
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
			{"SetTargetPos", 3123, 3859},
		},
	},
	[7] = {nTime = 0, nNum = 1,
		tbPrelock = {5},
		tbStartEvent = 
		{
			{"TrapUnlock", "TrapLock4", 7},
		},
		tbUnLockEvent = 
		{
			{"SetFubenProgress", 60, "擊敗藏劍弟子"},
			{"ClearTargetPos"},
			{"NpcBubbleTalk", "hs", "可惡，又是藏劍山莊的人！", 4, 0, 1},
			{"AddNpc", 3, 7, 8, "guaiwu", "RandomFuben2_10_2",false, 0},
			{"AddNpc", 5, 1, 8, "jy", "RandomFuben2_10_1_Elite2",false, 0},
			{"NpcBubbleTalk", "jy", "哼，真是自尋死路！", 4, 4, 1},
		},
	},
	[8] = {nTime = 0, nNum = 8,
		tbPrelock = {7},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"SetFubenProgress", 70, "擊敗藏劍高手"},
		    {"ChangeNpcAi", "hs", "Move", "Path3", 0, 1, 1, 0, 0},
		    {"NpcBubbleTalk", "hs", "總算是把他們擊退了！你們的武藝不錯，我們來切磋一下吧！", 4, 1, 1},
		},
	},
	[9] = {nTime = 2, nNum = 0,
		tbPrelock = {8},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"SetFubenProgress", 80, "與小殷方比試"},
			{"BlackMsg", "與小殷方切磋武藝！"},
			{"DelNpc", "hs"},
			{"AddNpc", 2, 1, 10, "BOSS", "RandomFuben2_10_BOSS",false, 0},
			{"NpcBubbleTalk", "BOSS", "你們可千萬不要小看我，否則會吃大虧的！", 4, 2, 1},
		},
	},

-------------胜利判定------------------------
	[10] = {nTime = 0, nNum = 1,
		tbPrelock = {9},
		tbStartEvent = 
		{

		},
		tbUnLockEvent = 
		{
			{"SetFubenProgress", 100, "與小殷方比試"},

			--掉落房间奖励
			{"RaiseEvent", "DropAward", "Setting/Fuben/RandomFuben/HouseAward/B.tab", 2861, 3970},
			{"RaiseEvent", "DropAward", "Setting/Fuben/RandomFuben/HouseAward/B.tab", 2855, 3589},

			--判断模式获得积分
			{"RaiseEvent", "AddMissionScore", "b_score_win"},

			{"AddNpc", 1, 1, 0, "hs", "BOSS",false, 0},
			{"NpcBubbleTalk", "hs", "你們的武藝真不錯啊！", 4, 2, 1},
			{"OpenWindow", "LingJueFengLayerPanel", "Win"},
			{"GameWin"},  
		},
	},
-------------闯关时间------------------------
	[11] = {nTime = "b_10_time", nNum = 0,    --总计时
		tbPrelock = {2},
		tbStartEvent = 
		{
			{"SetShowTime", 11},
		},
		tbUnLockEvent = 
		{
			{"BlackMsg", "小殷方身負重傷，護送他先行撤退！"},

			--判断模式获得积分
			{"RaiseEvent", "AddMissionScore", "b_score_lost"},

			{"GameLost"},
		},
	},
	[12] = {nTime = 0, nNum = 1,    --npc死亡失败
		tbPrelock = {2},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"BlackMsg", "小殷方身負重傷，護送他先行撤退！"},

			--判断模式获得积分
			{"IfCase", "self.nFubenLevel == 1",
				{"RaiseEvent", "AddMissionScore", 10},
			},
			{"IfCase", "self.nFubenLevel == 2",
				{"RaiseEvent", "AddMissionScore", 8},
			},

			{"OpenWindow", "LingJueFengLayerPanel", "Fail"},
			{"GameLost"},
		},
	},
}

