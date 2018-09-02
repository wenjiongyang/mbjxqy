local tbFubenSetting = Fuben.RandomFuben:GetRandomFubenSetting("g_7");

tbFubenSetting.tbMultiBeginPoint = {{7952, 8153},{7829, 7907},{7589, 8024},{7723, 8229}}  
tbFubenSetting.tbTempRevivePoint = {7487, 8421};
tbFubenSetting.nStartDir		 = 22;


tbFubenSetting.NPC = 
{
	[1] = {nTemplate = 2044, nLevel = -1, nSeries = -1}, --蒙面人
	[2] = {nTemplate = 2045, nLevel = -1, nSeries = -1}, --浪客
	[3] = {nTemplate = 2046, nLevel = -1, nSeries = -1}, --李天目
	--[4] = {nTemplate = 2422, nLevel = -1, nSeries = -1}, --护法弟子
	[5] = {nTemplate = 2423, nLevel = -1, nSeries = 0}, --邪火
	[6] = {nTemplate = 2424, nLevel = -1, nSeries = -1}, --巡逻机关人
	[7] = {nTemplate = 2477, nLevel = -1, nSeries = 0}, --机关
	[99] = {nTemplate = 74,   nLevel = -1, nSeries = 0}, -- 上升气流
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
			{"ChangeCameraSetting", 30, 35, 20},
			{"SetFubenProgress", -1,"等待秘境開啟"},
			{"AddNpc", 100, 2, 0, "wall", "wall1",false, 38},
			{"OpenWindow", "LingJueFengLayerPanel", "Info",3, 9, "第七層 荒城之外"},
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
			{"BlackMsg", "遺棄的荒城中飄來硝煙的餘味..."},
			--{"ShowTaskDialog", 10004, false},
		    {"DoDeath", "wall"},
			{"OpenDynamicObstacle", "obs1"},
			{"SetTargetPos", 8970, 7626},
			{"SetFubenProgress", 0, "探索凌絕峰"},			
		},
	},
	[3] = {nTime = 0, nNum = 1,
		tbPrelock = {2},
		tbStartEvent = 
		{
			{"TrapUnlock", "trap1", 3},
			
		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},
			{"AddNpc", 1, 1, 20, "jy", "jingying1", false, 0, 0, 0, 0},
			{"AddNpc", 2, 6, 5, "gw", "guaiwu1", false, 0, 0, 9005, 0.5},
			{"AddNpc", 5, 1, 4, "jg", "jiguan1", false, 0, 0, 0, 0},
			{"NpcAddBuff", "jy", 2417, 1, 300},
			{"NpcBubbleTalk", "jy", "來到這裡，就別想走了！", 4, 1, 1},
			{"NpcBubbleTalk", "gw", "兄弟們一起上啊！", 4, 1, 2},
			{"BlackMsg", "[FFFE0D]熄滅邪火[-]破掉護身術！"},
			{"SetFubenProgress", 5, "破掉護身術"},
		},
	},
	[20] = {nTime = 0, nNum = 1,
		tbPrelock = {3},
		tbStartEvent = 
		{			
		},
		tbUnLockEvent = 
		{
			{"SetFubenProgress", 25, "繼續探索"},
		},
	},
	[4] = {nTime = 0, nNum = 1,
		tbPrelock = {3},
		tbStartEvent = 
		{
			
		},
		tbUnLockEvent = 
		{
			{"NpcRemoveBuff", "jy", 2417},
			{"SetFubenProgress", 10, "擊殺蒙面人"},
		},
	},
	[5] = {nTime = 0, nNum = 7,
		tbPrelock = {20},
		tbStartEvent = 
		{
			{"TrapUnlock", "trap2", 5},
			{"SetTargetPos", 7749, 3676},
		},
		tbUnLockEvent = 
		{
			{"BlackMsg", "[FFFE0D]開啟機關[-]摧毀機關人！！"},
			{"ClearTargetPos"},
			{"AddNpc", 1, 1, 7, "jy", "jingying2", false, 0, 0, 9010, 0},
			{"AddNpc", 2, 6, 7, "gw", "guaiwu2", false, 0, 0, 9005, 0.5},
			{"AddNpc", 6, 1, 0, "Xl3", "xunluo3",false, 0, 0, 0, 0},
			{"AddNpc", 6, 1, 0, "Xl4", "xunluo4",false, 0, 0, 0, 0},
			{"ChangeNpcAi", "Xl3", "Move", "Path3", 0, 1, 1, 0, 1},
			{"ChangeNpcAi", "Xl4", "Move", "Path4", 0, 1, 1, 0, 1},
			{"NpcAddBuff", "Xl3", 1883, 1, 300},
			{"NpcAddBuff", "Xl4", 1883, 1, 300},
			{"AddNpc", 7, 1, 6, "jg", "jiguan2",false, 0, 0, 0, 0},
			{"NpcBubbleTalk", "jy", "找死！", 4, 1, 1},
			{"NpcBubbleTalk", "gw", "殺啊！", 4, 1, 3},
		},
	},
	[21] = {nTime = 3, nNum = 0,
		tbPrelock = {5},
		tbStartEvent = 
		{
			
		},
		tbUnLockEvent = 
		{
			{"SetFubenProgress", 35, "關掉機關"},
		},
	},
	[6] = {nTime = 0, nNum = 1,
		tbPrelock = {5},
		tbStartEvent = 
		{
			
		},
		tbUnLockEvent = 
		{
			{"DoDeath", "Xl3"},
			{"DoDeath", "Xl4"},

		},
	},
	[7] = {nTime = 0, nNum = 7,
		tbPrelock = {5},
		tbStartEvent = 
		{
			
		},
		tbUnLockEvent = 
		{
			{"DoDeath", "Xl3"},
			{"DoDeath", "Xl4"},
		},
	},	
	[10] = {nTime = 0, nNum = 1,
		tbPrelock = {7},
		tbStartEvent = 
		{
			{"BlackMsg", "前方有一斷崖，過去看看"},
			{"SetFubenProgress", 50, "繼續探索"},

			{"AddNpc", 99, 1, 0, "qg", "qinggong", false, 0, 0, 0, 0},
			{"TrapUnlock", "jump1", 10},
			{"SetTargetPos", 6206, 3633},
			{"ChangeTrap", "jump1", nil, {5278, 3883}},
			{"ChangeTrap", "jump2", nil, {4552, 4420}},	
		},
		tbUnLockEvent = 
		{
		},
	},
	[11] = {nTime = 0, nNum = 1,
		tbPrelock = {10},
		tbStartEvent = 
		{
			{"TrapUnlock", "trap3", 11},
			{"SetTargetPos", 3623, 4969},
		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},

			{"SetFubenProgress", 75, "擊敗李天目"},
			{"BlackMsg", "似乎有強敵出沒！"},
			{"AddNpc", 3, 1, 12, "sl", "shouling1", false, 0, 0, 9010, 0},
			{"NpcAddBuff", "sl", 2417, 1, 300},
			{"AddNpc", 5, 1, 50, "jg", "jiguan3", false, 0, 0, 0, 0},
			{"AddNpc", 6, 1, 0, "Xl1", "xunluo1",false, 0, 0, 0, 0},
			{"AddNpc", 6, 1, 0, "Xl2", "xunluo2",false, 0, 0, 0, 0},

			
			{"ChangeNpcAi", "Xl1", "Move", "Path1", 0, 1, 1, 0, 1},
			{"ChangeNpcAi", "Xl2", "Move", "Path2", 0, 1, 1, 0, 1},
			
			{"NpcAddBuff", "Xl1", 1883, 1, 300},
			{"NpcAddBuff", "Xl2", 1883, 1, 300},
			

			{"NpcBubbleTalk", "sl", "你們還有些本事，居然來到了此處！", 4, 1, 1},
		},
	},
	[50] = {nTime = 0, nNum = 1,
		tbPrelock = {11},
		tbStartEvent = 
		{
			
		},
		tbUnLockEvent = 
		{
			{"NpcRemoveBuff", "sl", 2417},
		},
	},
	[30] = {nTime = 0.1, nNum = 0,
		tbPrelock = {11},
		tbStartEvent = 
		{	
		},
		tbUnLockEvent = 
		{
			{"Random", {250000, 31}, {250000, 32}, {250000, 33}, {250000, 34}},
			{"BlackMsg", "真的機關定是其中一個！"},
		},
	},
	[31] = {nTime = 0, nNum = 1,
		tbPrelock = {},
		tbStartEvent = 
		{
			{"AddNpc", 7, 1, 40, "zjg", "jiguan4", false, 0, 0, 0, 0},
			{"AddNpc", 7, 1, 41, "jjg", "jiguan5", false, 0, 0, 0, 0},
			{"AddNpc", 7, 1, 42, "jjg", "jiguan6", false, 0, 0, 0, 0},
			{"AddNpc", 7, 1, 43, "jjg", "jiguan7", false, 0, 0, 0, 0},
			{"UnLock", 31},
		},
		tbUnLockEvent = 
		{
		},
	},
	[32] = {nTime = 0, nNum = 1,
		tbPrelock = {},
		tbStartEvent = 
		{
			{"AddNpc", 7, 1, 40, "zjg", "jiguan5", false, 0, 0, 0, 0},
			{"AddNpc", 7, 1, 41, "jjg", "jiguan4", false, 0, 0, 0, 0},
			{"AddNpc", 7, 1, 42, "jjg", "jiguan6", false, 0, 0, 0, 0},
			{"AddNpc", 7, 1, 43, "jjg", "jiguan7", false, 0, 0, 0, 0},
			{"UnLock", 32},
		},
		tbUnLockEvent = 
		{
		},
	},
	[33] = {nTime = 0, nNum = 1,
		tbPrelock = {},
		tbStartEvent = 
		{
			{"AddNpc", 7, 1, 40, "zjg", "jiguan6", false, 0, 0, 0, 0},
			{"AddNpc", 7, 1, 41, "jjg", "jiguan5", false, 0, 0, 0, 0},
			{"AddNpc", 7, 1, 42, "jjg", "jiguan4", false, 0, 0, 0, 0},
			{"AddNpc", 7, 1, 43, "jjg", "jiguan7", false, 0, 0, 0, 0},
			{"UnLock", 33},
		},
		tbUnLockEvent = 
		{
		},
	},
	[34] = {nTime = 0, nNum = 1,
		tbPrelock = {},
		tbStartEvent = 
		{
			{"AddNpc", 7, 1, 40, "zjg", "jiguan7", false, 0, 0, 0, 0},
			{"AddNpc", 7, 1, 41, "jjg", "jiguan5", false, 0, 0, 0, 0},
			{"AddNpc", 7, 1, 42, "jjg", "jiguan6", false, 0, 0, 0, 0},
			{"AddNpc", 7, 1, 43, "jjg", "jiguan4", false, 0, 0, 0, 0},
			{"UnLock", 34},
		},
		tbUnLockEvent = 
		{
		},
	},
	[40] = {nTime = 0, nNum = 1,
		tbPrelock = {{31, 32, 33, 34}},
		tbStartEvent = 
		{
			
		},
		tbUnLockEvent = 
		{
			{"DoDeath", "Xl1"},
			{"DoDeath", "Xl2"},
			{"DoDeath", "jjg"},
		},
	},
	[41] = {nTime = 0, nNum = 1,
		tbPrelock = {{31, 32, 33, 34}},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"BlackMsg", "糟了！這是個假機關！"},
		},
	},
	[42] = {nTime = 0, nNum = 1,
		tbPrelock = {{31, 32, 33, 34}},
		tbStartEvent = 
		{
			
		},
		tbUnLockEvent = 
		{
			{"BlackMsg", "糟了！這是個假機關！"},
		},
	},
	[43] = {nTime = 0, nNum = 1,
		tbPrelock = {{31, 32, 33, 34}},
		tbStartEvent = 
		{
			
		},
		tbUnLockEvent = 
		{
			{"BlackMsg", "糟了！這是個假機關！"},
		},
	},
------------------胜负判断----------------------
	[12] = {nTime = 0, nNum = 1,
		tbPrelock = {11},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			--判断模式篝火&踢出
			{"IfCase", "self.nFubenLevel == 3",
				{"AddSimpleNpc", 1611, 3377, 5252, 0},
				{"RaiseEvent", "KickOutAllPlayer", 40},
			},
			--判断模式获得积分
			{"RaiseEvent", "AddMissionScore", "g_score_win"},

			{"SetFubenProgress", 100, "擊敗李天目"},
			{"OpenWindow", "LingJueFengLayerPanel", "Win"},
			{"GameWin"},
		},
	},
------------------闯关时间-------------------------
	[13] = {nTime = "g_time", nNum = 0,    --总计时
		tbPrelock = {2},
		tbStartEvent = 
		{
			{"SetShowTime", 13},
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
}