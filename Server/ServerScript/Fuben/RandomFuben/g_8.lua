
local tbFubenSetting = Fuben.RandomFuben:GetRandomFubenSetting("g_8");

tbFubenSetting.tbMultiBeginPoint = {{1219, 7062},{1472, 7064},{1203, 7200},{1456, 7203}}  
tbFubenSetting.tbTempRevivePoint = {1456, 7203};
tbFubenSetting.nStartDir		 = 32;


tbFubenSetting.NPC = 
{
	[1] = {nTemplate = 2052, nLevel = -1, nSeries = -1}, --普通精英
	[2] = {nTemplate = 2053, nLevel = -1, nSeries = -1}, --怪物
	[3] = {nTemplate = 2054, nLevel = -1, nSeries = -1}, --机关
	[4] = {nTemplate = 2055, nLevel = -1, nSeries = -1}, --首领

	--[99] = {nTemplate = 74,   nLevel = -1, nSeries = 0}, -- 上升气流
	[100] = {nTemplate = 104,  nLevel = -1, nSeries = 0},  --动态障碍墙
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
			--{"ChangeCameraSetting", 30, 35, 20},

			{"OpenWindow", "LingJueFengLayerPanel", "Info",3, 9, "第七層 無人雪宮"},
		},
	},
	[2] = {nTime = 10, nNum = 0,
		tbPrelock = {1},
		tbStartEvent = 
		{
			{"SetFubenProgress", -1,"等待秘境開啟"},
			{"AddNpc", 100, 2, 0, "wall1", "wall1",false, 48},
			{"AddNpc", 100, 2, 0, "wall2", "wall2",false, 48},
		},
		tbUnLockEvent = 
		{
			{"RaiseEvent", "Start"},
			{"BlackMsg", "空氣中彌漫著塵封已久的味道..."},
			--{"ShowTaskDialog", 10004, false},
		    {"DoDeath", "wall1"},
			{"OpenDynamicObstacle", "obs1"},
			
			
		},
	},
	-------------闯关时间------------------------
	[3] = {nTime = "g_time", nNum = 0,    --总计时
		tbPrelock = {2},
		tbStartEvent = 
		{
			{"SetShowTime", 3},
		},
		tbUnLockEvent = 
		{
			--判断模式踢出
			{"IfCase", "self.nFubenLevel == 3",
				{"RaiseEvent", "KickOutAllPlayer", 10},
			},
			--判断模式获得积分
			{"RaiseEvent", "AddMissionScore", "g_score_lost"},

			{"SetFubenProgress", -1, "闖關失敗"},
			{"BlackMsg", "此地不宜久留，還是另覓他路吧！"},
			{"OpenWindow", "LingJueFengLayerPanel", "Fail"},
			{"GameLost"},
		},
	},

	[4] = {nTime = 0, nNum = 1,
		tbPrelock = {2},
		tbStartEvent = 
		{
			{"TrapUnlock", "trap1", 4},
			{"SetTargetPos", 1449, 5816},
			{"SetFubenProgress", 0, "探索凌絕峰"},
		},
		tbUnLockEvent = 
		{
			{"SetFubenProgress", 10, "擊敗敵人"},
			{"ClearTargetPos"},
		},
	},
	[5] = {nTime = 0, nNum = 9,
		tbPrelock = {4},
		tbStartEvent = 
		{
			{"BlackMsg", "此處看來不太平！"},

			{"AddNpc", 1, 1, 5, "jy", "jingying1", false, 0, 0, 9010, 0.5},
			{"AddNpc", 2, 8, 5, "gw", "guaiwu1", false, 0, 0, 9005, 0.5},

			{"NpcBubbleTalk", "jy", "來到這裡，就別想走了！", 4, 1, 1},
			{"NpcBubbleTalk", "gw", "兄弟們一起上啊！", 4, 1, 2},
		},
		tbUnLockEvent = 
		{
			{"BlackMsg", "此處強敵環伺，沿途小心！"},
			{"SetFubenProgress", 30, "繼續探索"},
		},
	},
	[6] = {nTime = 0, nNum = 9,
		tbPrelock = {5},
		tbStartEvent = 
		{
			{"AddNpc", 3, 1, 6, "jg", "jiguan1", false, 0, 0, 9010, 0.5},
			{"AddNpc", 2, 8, 6, "gw", "guaiwu2", false, 0, 0, 9005, 0.5},
		},
		tbUnLockEvent = 
		{
			{"BlackMsg", "繼續探索此地"},
		},
	},
	[7] = {nTime = 0, nNum = 9,
		tbPrelock = {5},
		tbStartEvent = 
		{
			{"AddNpc", 1, 1, 7, "jy", "jingying2", false, 0, 0, 9010, 0.5},
			{"AddNpc", 2, 8, 7, "gw", "guaiwu3", false, 0, 0, 9005, 0.5},
		},
		tbUnLockEvent = 
		{
		},
	},
	[8] = {nTime = 0, nNum = 9,
		tbPrelock = {5},
		tbStartEvent = 
		{
			{"AddNpc", 3, 1, 8, "jg", "jiguan2", false, 0, 0, 9010, 0.5},
			{"AddNpc", 2, 8, 8, "gw", "guaiwu4", false, 0, 0, 9005, 0.5},
		},
		tbUnLockEvent = 
		{
		},
	},
	[9] = {nTime = 0, nNum = 1,
		tbPrelock = {5, 6, 7, 8},
		tbStartEvent = 
		{
			{"TrapUnlock", "trap2", 9},
			{"SetTargetPos", 3103, 5489},

			{"DoDeath", "wall2"},
			{"OpenDynamicObstacle", "obs2"},

			{"BlackMsg", "某處似乎有強敵出現"},
			{"SetFubenProgress", 60, "搜尋強敵"},
		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},
		},
	},
	[10] = {nTime = 0, nNum = 1,
		tbPrelock = {9},
		tbStartEvent = 
		{
			{"SetFubenProgress", 80, "擊敗耶律辟離"},
			{"BlackMsg", "擊敗盤踞在此處的耶律辟離"},
			{"AddNpc", 4, 1, 10, "sl", "shouling1", false, 0, 0, 9010, 0.5},
			{"AddNpc", 2, 8, 0, "gw", "guaiwu5", false, 0, 0, 9005, 0.5},
			{"NpcBubbleTalk", "sl", "真是冤家路窄啊！哼哼，來了就別想走了！", 4, 1, 1},
		},
		tbUnLockEvent = 
		{
			--判断模式篝火&踢出
			{"IfCase", "self.nFubenLevel == 3",
				{"AddSimpleNpc", 1611, 3108, 6848, 0},
				{"RaiseEvent", "KickOutAllPlayer", 40},
			},
			--判断模式获得积分
			{"RaiseEvent", "AddMissionScore", "g_score_win"},

			{"SetFubenProgress", 100, "擊敗耶律辟離"},
			{"OpenWindow", "LingJueFengLayerPanel", "Win"},
			{"GameWin"},
		},
	},

}

