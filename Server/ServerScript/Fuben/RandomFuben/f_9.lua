
local tbFubenSetting = Fuben.RandomFuben:GetRandomFubenSetting("f_9");

tbFubenSetting.tbMultiBeginPoint = {{1649, 840},{2022, 874},{1694, 579},{2056, 600}}	-- 副本出生点
tbFubenSetting.tbTempRevivePoint = {1872, 739};
tbFubenSetting.nStartDir		 = 1;


tbFubenSetting.NPC = 
{
	[1] = {nTemplate = 1809, nLevel = -1, nSeries = -1}, --江湖流寇
	[2] = {nTemplate = 1810, nLevel = -1, nSeries = -1}, --流寇头领
	[3] = {nTemplate = 1811, nLevel = -1, nSeries = -1}, --死士
	[4] = {nTemplate = 104,  nLevel = -1, nSeries = 0},  --动态障碍墙
	[5] = {nTemplate = 1826, nLevel = -1, nSeries = 0},  --清晓师太（稀有）
	[6] = {nTemplate = 1812, nLevel = -1, nSeries = 0}, --东瀛武士
	[7] = {nTemplate = 2474, nLevel = -1, nSeries = 0}, --邪火
	[8] = {nTemplate = 2475, nLevel = -1, nSeries = 0}, --邪火
	[9] = {nTemplate = 2476, nLevel = -1, nSeries = 0}, --邪火
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
			{"AddNpc", 4, 1, 1, "wall", "wall_1_1",false, 22},
			{"OpenWindow", "LingJueFengLayerPanel", "Info",3, 9, "第六層 石壁懸崖"},
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
			{"ShowTaskDialog", 10004, false},
			{"DoDeath", "wall"},
			{"OpenDynamicObstacle", "ops1"},
			{"SetTargetPos", 2374, 1748},
			{"SetFubenProgress", 0, "探索凌絕峰"},
		},
	},
	[3] = {nTime = 0, nNum = 1,
		tbPrelock = {2},
		tbStartEvent = 
		{
			{"TrapUnlock", "TrapLock1", 3},
		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},
			{"SetFubenProgress", 40, "擊敗江湖流寇"},

			--江湖流寇 &　流寇精英
			{"AddNpc", 1, 5, 5, "guaiwu", "RandomFuben6_9_1", false, 0, 0, 0, 0},	
			{"AddNpc", 6, 1, 5, "Elite_1", "RandomFuben6_9_2", false, 0, 1, 9011, 1},	
			{"AddNpc", 1, 8, 5, "guaiwu", "RandomFuben6_9_3", false, 0, 4, 9008, 0.5},	
			{"NpcBubbleTalk", "guaiwu", "哈哈，又有肥羊送上門來了，兄弟們抄傢伙一起上啊！！", 4, 0, 1},	
		},
	},
	[4] = {nTime = 8, nNum = 0,
		tbPrelock = {3},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"SetFubenProgress", 80, "擊敗敵人"},

			{"BlackMsg", "突然燃起的邪火貌似對我們不利！"},
			{"AddNpc", 7, 1, 20, "jiguan", "RandomFuben6_9_jiguan1", false, 0, 0, 0, 0},
			{"AddNpc", 8, 1, 20, "jiguan", "RandomFuben6_9_jiguan2", false, 0, 0, 0, 0},
			{"AddNpc", 9, 1, 20, "jiguan", "RandomFuben6_9_jiguan3", false, 0, 0, 0, 0},
			{"AddNpc", 1, 8, 0, "guaiwu", "RandomFuben6_9_3", false, 0, 4, 9008, 0.5},	
			--稀有几率
			{"Random", {350000, 30}},
		},
	},
	[5] = {nTime = 0, nNum = 14,
		tbPrelock = {3},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
		},
	},
	
	[6] = {nTime = 15, nNum = 0,
		tbPrelock = {4},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"BlackMsg", "糟了！邪火召喚出了新的敵人！"},
			{"DelNpc", "jiguan"},
			{"AddNpc", 2, 1, 8, "boss", "RandomFuben6_9_4", false, 0, 1, 9011, 1},
		},
	},
	[20] = {nTime = 0, nNum = 3,
		tbPrelock = {4},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"CloseLock", 6},
		},
	},
	[7] = {nTime = 0.1, nNum = 0,
		tbPrelock = {5, 20},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
		},
	},
	[8] = {nTime = 0, nNum = 1,
		tbPrelock = {6},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
		},
	},
	-------------胜利判定------------------------
	[11] = {nTime = 0.1, nNum = 0,
		tbPrelock = {{7, 8}},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
		},
	},
	[9] = {nTime = 0.1, nNum = 0,
		tbPrelock = {11},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			--掉落房间奖励
			{"RaiseEvent", "DropAward", "Setting/Fuben/RandomFuben/HouseAward/F.tab", 3354, 3137},
			{"RaiseEvent", "DropAward", "Setting/Fuben/RandomFuben/HouseAward/F.tab", 3596, 2991},
			{"RaiseEvent", "DropAward", "Setting/Fuben/RandomFuben/HouseAward/F.tab", 3203, 2976},
			{"RaiseEvent", "DropAward", "Setting/Fuben/RandomFuben/HouseAward/F.tab", 3500, 2839},

			{"SetFubenProgress", 100, "擊敗所有敵人"},

			--判断模式篝火&踢出
			{"IfCase", "self.nFubenLevel == 2",
				{"AddSimpleNpc", 1611, 3391, 2922, 0},
				{"RaiseEvent", "KickOutAllPlayer", 40},
			},
			--判断模式获得积分
			{"RaiseEvent", "AddMissionScore", "f_score_win"},

			{"OpenWindow", "LingJueFengLayerPanel", "Win"},
			{"GameWin"},
		},
	},
	-------------闯关时间------------------------
	[10] = {nTime = "f_9_time", nNum = 0,    --总计时
		tbPrelock = {2},
		tbStartEvent = 
		{
			{"SetShowTime", 10},
		},
		tbUnLockEvent = 
		{
			{"SetFubenProgress", -1, "闖關失敗"},
			{"BlackMsg", "這群流寇武藝高強，還是先撤退為妙！"},

			--判断模式踢出
			{"IfCase", "self.nFubenLevel == 2",
				{"RaiseEvent", "KickOutAllPlayer", 10},
			},
			--判断模式获得积分
			{"RaiseEvent", "AddMissionScore", "f_score_lost"},

			{"OpenWindow", "LingJueFengLayerPanel", "Fail"},
			{"GameLost"},
		},
	},

---------------------稀有锁---------------------------------
	[30] = {nTime = 0, nNum = 1,
		tbPrelock = {},
		tbStartEvent = 
		{
			{"AddNpc", 5, 1, 32, "Qingxiao", "RandomFuben6_9_Xiyou",false, 7 , 0, 0, 0},
			{"NpcBubbleTalk", "Qingxiao", "這就是邪教中的祭魂大法，擊毀所有邪火就可破解！", 4, 1, 1},
			{"ChangeNpcAi", "Qingxiao", "Move", "Path2", 0, 1, 1, 0, 0},
			{"UnLock", 30},
		},
		tbUnLockEvent = 
		{
		},
	},
	[31] = {nTime = 0.1, nNum = 0,
		tbPrelock = {30, 11},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{		
			{"RaiseEvent", "DropAward", "Setting/Npc/DropFile/RandomFuben/House_F/qingxiaoshitai.tab", 3264, 3068},
			{"RaiseEvent", "DropAward", "Setting/Npc/DropFile/RandomFuben/House_F/qingxiaoshitai.tab", 3589, 2908},
			{"RaiseEvent", "DropAward", "Setting/Npc/DropFile/RandomFuben/House_F/qingxiaoshitai.tab", 3045, 2873},
			{"RaiseEvent", "DropAward", "Setting/Npc/DropFile/RandomFuben/House_F/qingxiaoshitai.tab", 3489, 2660},

			{"RaiseEvent", "DropCard", 2639, 350000},	--卡片收集掉落		
		},
	},

	--清晓师太死亡锁
	[32] = {nTime = 0, nNum = 1,
		tbPrelock = {30},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"CloseLock", 31},
		},
	},
}

