
local tbFubenSetting = Fuben.RandomFuben:GetRandomFubenSetting("e_9");

tbFubenSetting.tbMultiBeginPoint = {{2867, 669},{2215, 719},{2437, 741},{2653, 759}}	-- 副本出生点
tbFubenSetting.tbTempRevivePoint = {2594, 642};
tbFubenSetting.nStartDir		 = 62;

--NPC模版ID，NPC等级，NPC五行；
tbFubenSetting.NPC = 
{
	[1]  = {nTemplate = 275,  nLevel = -1, nSeries = 1}, -- 天王主角
	[2]  = {nTemplate = 276,  nLevel = -1, nSeries = 3}, -- 峨眉主角
	[3]  = {nTemplate = 277,  nLevel = -1, nSeries = 4}, -- 桃花主角
	[4]  = {nTemplate = 278,  nLevel = -1, nSeries = 2}, -- 逍遥主角
	[5]  = {nTemplate = 1231, nLevel = -1, nSeries = 5}, -- 武当主角
	[6]  = {nTemplate = 1232, nLevel = -1, nSeries = 4}, -- 天忍主角
	[7]  = {nTemplate = 1849, nLevel = -1, nSeries = 1}, -- 少林主角
	[8]  = {nTemplate = 1850, nLevel = -1, nSeries = 3}, -- 翠烟主角
	[9]  = {nTemplate = 2032, nLevel = -1, nSeries = 2}, -- 唐门主角
	[10] = {nTemplate = 2033, nLevel = -1, nSeries = 5}, -- 昆仑主角
	[11] = {nTemplate = 2233, nLevel = -1, nSeries = 4}, -- 丐帮主角
	[12] = {nTemplate = 2234, nLevel = -1, nSeries = 2}, -- 五毒主角
	[13] = {nTemplate = 2383, nLevel = -1, nSeries = 4}, -- 藏剑主角
	[14] = {nTemplate = 2384, nLevel = -1, nSeries = 2}, -- 长歌主角
	[20] = {nTemplate = 273,  nLevel = -1, nSeries = 0}, -- 巨剑
	[21] = {nTemplate = 74,   nLevel = -1, nSeries = 0}, -- 上升气流
	[22] = {nTemplate = 104,  nLevel = -1, nSeries = 0}, -- 动态障碍墙
	[23] = {nTemplate = 1597, nLevel = -1, nSeries = 3}, -- 无想

	[24] = {nTemplate = 1824, nLevel = 1, nSeries = 0},--卡片收集
}
-- 不同门派对应 Npc索引
tbFubenSetting.tbCopyPlayer = 
{
	[1] = {nNpcIndex = 1, szName = "%s的心魔"},
	[2] = {nNpcIndex = 2, szName = "%s的心魔"},
	[3] = {nNpcIndex = 3, szName = "%s的心魔"},
	[4] = {nNpcIndex = 4, szName = "%s的心魔"},
	[5] = {nNpcIndex = 5, szName = "%s的心魔"},
	[6] = {nNpcIndex = 6, szName = "%s的心魔"},
	[7] = {nNpcIndex = 7, szName = "%s的心魔"},
	[8] = {nNpcIndex = 8, szName = "%s的心魔"},
	[9] = {nNpcIndex = 9, szName = "%s的心魔"},
	[10] = {nNpcIndex = 10, szName = "%s的心魔"},
	[11] = {nNpcIndex = 11, szName = "%s的心魔"},
	[12] = {nNpcIndex = 12, szName = "%s的心魔"},
	[13] = {nNpcIndex = 13, szName = "%s的心魔"},
	[14] = {nNpcIndex = 14, szName = "%s的心魔"},
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
			{"OpenWindow", "LingJueFengLayerPanel", "Info",3, 9, "第五層 天玄之巔"},
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
			{"SetFubenProgress", 0, "探索凌絕峰"},
			{"ShowTaskDialog", 10004, false},
			{"AddNpc", 21, 1, 1, "Qinggong", "RandomFuben5_9_qinggong", false},
			{"ChangeTrap", "Jump1", nil, {2539, 1975}},
			{"ChangeTrap", "Jump2", nil, {2518, 2355}},	
			{"ChangeTrap", "Jump3", nil, {2270, 2807}},	
			{"ChangeTrap", "Jump4", nil, {3016, 2620}},	
			{"ChangeTrap", "Jump5", nil, {2937, 3065}},	
			{"ChangeTrap", "Jump6", nil, {3413, 3547}},	
			{"SetTargetPos", 2561, 1284},

			--稀有几率
			{"Random", {350000, 30}},
		},
	},
	[100] = {nTime = 0, nNum = 1,
		tbPrelock = {2},
		tbStartEvent = 
		{
			{"TrapUnlock", "Jump1", 100},
		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},
		},
	},
	[101] = {nTime = 0, nNum = 1,
		tbPrelock = {100},
		tbStartEvent = 
		{
			{"TrapUnlock", "Jump6", 101},
		},
		tbUnLockEvent = 
		{
			{"SetTargetPos", 3654, 4075},
		},
	},
	[3] = {nTime = 0, nNum = 1,
		tbPrelock = {2},
		tbStartEvent = 
		{			
			{"TrapUnlock", "TrapLock1", 3},
			{"AddNpc", 20, 1, 4, "Sword", "RandomFuben5_9_sword", false},
		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},
			{"BlackMsg", "這便是當年的決戰之地嗎！咦？這把巨劍是..."},
		},
	},
	[4] = {nTime = 0, nNum = 1,
		tbPrelock = {3},
		tbStartEvent = 
		{
			{"SetFubenProgress", 20, "拔出巨劍"},
		},
		tbUnLockEvent = 
		{
			{"SetFubenProgress", 50, "擊敗心魔"},
			{"BlackMsg", "這... 這是什麼？"},
			{"RaiseEvent", "CopyPlayer", 5, "guaiwu", "RandomFuben5_9_1",false, 0 , 1, 9011, 1},
		},
	},

-------------胜利判定------------------------
	[5] = {nTime = 0, nNum = 999,
		tbPrelock = {4},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
		},
	},
	[6] = {nTime = 0.1, nNum = 0,
		tbPrelock = {5},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"SetFubenProgress", 100, "擊敗心魔"},
			{"RaiseEvent", "DropAward", "Setting/Fuben/RandomFuben/HouseAward/E.tab", 4079, 4633},
			{"RaiseEvent", "DropAward", "Setting/Fuben/RandomFuben/HouseAward/E.tab", 4079, 4633},
			{"RaiseEvent", "DropAward", "Setting/Fuben/RandomFuben/HouseAward/E.tab", 4079, 4633},
			{"RaiseEvent", "DropAward", "Setting/Fuben/RandomFuben/HouseAward/E.tab", 4079, 4633},

			--卡片收集
			{"RaiseEvent", "CheckCollectionAct", 
				{"IfCase", "MathRandom(100) <= 25", 
					{"AddSimpleNpc", 1824, 4094, 4642, 0}
				}
			},

			--判断模式篝火&踢出
			{"IfCase", "self.nFubenLevel == 1",
				{"AddSimpleNpc", 1611, 4079, 4633, 0},
				{"RaiseEvent", "KickOutAllPlayer", 40},				
			},

			--判断模式获得积分
			{"RaiseEvent", "AddMissionScore", "e_score_win"},

			{"OpenWindow", "LingJueFengLayerPanel", "Win"},
			{"GameWin"},
		},
	},
-------------闯关时间------------------------	
	[7] = {nTime = "e_9_time", nNum = 0,
		tbPrelock = {2},
		tbStartEvent = 
		{
			{"SetShowTime", 7},
		},
		tbUnLockEvent = 
		{
			--判断模式踢出
			{"IfCase", "self.nFubenLevel == 1",
				{"RaiseEvent", "KickOutAllPlayer", 10},
			},
			--判断模式获得积分
			{"RaiseEvent", "AddMissionScore", "e_score_lost"},

			{"BlackMsg", "沒想到居然無法戰勝心魔，看來還得努力修行才是！"},
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

			--无想
			{"AddNpc", 23, 1, 33, "Wuxiang", "RandomFuben5_9_Xiyou",false, 8 , 0, 0, 0},
		},
		tbUnLockEvent = 
		{
			{"NpcBubbleTalk", "Wuxiang", "沒想到會在這裡碰到你們，我們一起前進吧！", 4, 1, 1},
			{"ChangeNpcAi", "Wuxiang", "Move", "Path1", 31, 1, 1, 0, 0},	
		},
	},
	[31] = {nTime = 0, nNum = 1,
		tbPrelock = {30},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"NpcBubbleTalk", "Wuxiang", "這把巨劍是....", 4, 1, 1},
		},
	},
	[32] = {nTime = 1, nNum = 0,
		tbPrelock = {30, 5},
		tbStartEvent = 
		{
			{"RaiseEvent", "DropAward", "Setting/Npc/DropFile/RandomFuben/House_E/wuxiang.tab", 4037, 4833},
			{"RaiseEvent", "DropAward", "Setting/Npc/DropFile/RandomFuben/House_E/wuxiang.tab", 4329, 4651},
			{"RaiseEvent", "DropAward", "Setting/Npc/DropFile/RandomFuben/House_E/wuxiang.tab", 3782, 4638},
			{"RaiseEvent", "DropAward", "Setting/Npc/DropFile/RandomFuben/House_E/wuxiang.tab", 4077, 4333},

			{"RaiseEvent", "DropCard", 2625, 350000},	--卡片收集掉落
		},
		tbUnLockEvent = 
		{				
		},
	},

	--无想死亡锁
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

