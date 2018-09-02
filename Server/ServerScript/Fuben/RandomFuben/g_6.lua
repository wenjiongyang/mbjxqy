
local tbFubenSetting = Fuben.RandomFuben:GetRandomFubenSetting("g_6");

tbFubenSetting.tbMultiBeginPoint = {{5090, 1958},{5427, 2114},{5215, 1699},{5546, 1819}}  
tbFubenSetting.tbTempRevivePoint = {5546, 1819};
tbFubenSetting.nStartDir		 = 56;


tbFubenSetting.NPC = 
{
	[1] = {nTemplate = 2041, nLevel = -1, nSeries = -1}, --普通精英
	[2] = {nTemplate = 2042, nLevel = -1, nSeries = -1}, --普通怪物
	[3] = {nTemplate = 2043, nLevel = -1, nSeries = -1}, --首领
	[4] = {nTemplate = 2115, nLevel = -1, nSeries = -1}, --技能怪物

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

			{"OpenWindow", "LingJueFengLayerPanel", "Info",3, 9, "第七層 顫慄之地"},
		},
	},
	[2] = {nTime = 10, nNum = 0,
		tbPrelock = {1},
		tbStartEvent = 
		{
			{"SetFubenProgress", -1,"等待秘境開啟"},
			{"AddNpc", 100, 2, 0, "wall", "wall1",false, 11},
		},
		tbUnLockEvent = 
		{
			{"RaiseEvent", "Start"},
			{"BlackMsg", "冷風似刀，刮過荒涼的廣場。"},
			--{"ShowTaskDialog", 10004, false},
		    {"DoDeath", "wall"},
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
			{"SetTargetPos", 4636, 3807},
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
			{"BlackMsg", "如此荒涼之處也有人在？"},

			{"AddNpc", 1, 1, 5, "jy", "jingying1", false, 0, 0, 9010, 0.5},
			{"AddNpc", 2, 8, 5, "gw", "guaiwu1", false, 0, 0, 9005, 0.5},

			{"NpcBubbleTalk", "jy", "來到這裡，就別想走了！", 4, 1, 1},
			{"NpcBubbleTalk", "gw", "兄弟們一起上啊！", 4, 1, 2},
		},
		tbUnLockEvent = 
		{
		},
	},
	[6] = {nTime = 0, nNum = 9,
		tbPrelock = {5},
		tbStartEvent = 
		{
			{"SetFubenProgress", 25, "一探究竟"},
			{"BlackMsg", "繼續探索此地。"},
			{"AddNpc", 1, 1, 6, "jy", "jingying2", false, 0, 0.5, 9010, 0.5},
			{"AddNpc", 2, 8, 6, "gw", "guaiwu2", false, 0, 0.5, 9005, 0.5},
		},
		tbUnLockEvent = 
		{
		},
	},
	[7] = {nTime = 0, nNum = 1,
		tbPrelock = {6},
		tbStartEvent = 
		{
			{"TrapUnlock", "trap2", 7},
			{"SetTargetPos", 3411, 4408},
			{"SetFubenProgress", 50, "搜尋敵人"},
			{"BlackMsg", "某處似乎有強敵出沒！"},
		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},
			{"SetFubenProgress", 75, "擊敗武林高手"},

			{"SetNpcProtected", "sl", 0},
			{"SetAiActive", "sl", 1},
			{"SetHeadVisiable", "sl", true, 0},
			{"SetNpcProtected", "gw", 0},
			{"SetAiActive", "gw", 1},
			{"SetHeadVisiable", "gw", true, 0},

			{"NpcBubbleTalk", "sl", "那我們就來較量一番吧！", 4, 1, 1},
		},
	},
	[8] = {nTime = 0, nNum = 1,
		tbPrelock = {6},
		tbStartEvent = 
		{
			{"AddNpc", 3, 1, 8, "sl", "shouling1", false, 0, 0, 0, 0},
			{"AddNpc", 2, 8, 0, "gw", "guaiwu3", false, 0, 0, 0, 0},

			{"SetNpcProtected", "sl", 1},
			{"SetAiActive", "sl", 0},
			{"SetHeadVisiable", "sl", false, 0},

			{"SetNpcProtected", "gw", 1},
			{"SetAiActive", "gw", 0},
			{"SetHeadVisiable", "gw", false, 0},
		},
		tbUnLockEvent = 
		{
			--判断模式篝火&踢出
			{"IfCase", "self.nFubenLevel == 3",
				{"AddSimpleNpc", 1611, 2813, 3752, 0},
				{"RaiseEvent", "KickOutAllPlayer", 40},
			},
			--判断模式获得积分
			{"RaiseEvent", "AddMissionScore", "g_score_win"},

			{"SetFubenProgress", 100, "擊敗武林高手"},
			{"OpenWindow", "LingJueFengLayerPanel", "Win"},
			{"GameWin"},
		},
	},

	-------------------技能怪物----------------------
	[9] = {nTime = 0, nNum = 1,
		tbPrelock = {7},
		tbStartEvent = 
		{
			{"NpcHpUnlock", "sl", 9, 80},
		},
		tbUnLockEvent = 
		{
			{"AddNpc", 4, 2, 0, "gw", "guaiwu4", false, 0, 0, 9010, 0.5},
			{"NpcBubbleTalk", "sl", "我要叫幫手了！", 4, 0, 1},
		},
	},

}

