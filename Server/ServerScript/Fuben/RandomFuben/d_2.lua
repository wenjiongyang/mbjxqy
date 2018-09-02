
local tbFubenSetting = Fuben.RandomFuben:GetRandomFubenSetting("d_2");

tbFubenSetting.tbMultiBeginPoint = {{2175, 2933},{2157, 2506},{1745, 2928},{1730, 2526}}	-- 副本出生点
tbFubenSetting.tbTempRevivePoint = {1951, 2727}
tbFubenSetting.nStartDir		 = 11;

--NPC模版ID，NPC等级，NPC五行；

--[[

]]

tbFubenSetting.NPC = 
{
	[1] = {nTemplate = 1356, nLevel = -1, nSeries = -1}, --金兵
	[2] = {nTemplate = 1357, nLevel = -1, nSeries = -1}, --十夫长
	[3] = {nTemplate = 1358, nLevel = -1, nSeries = -1}, --天忍弟子
	[4] = {nTemplate = 1359, nLevel = -1, nSeries = -1}, --酒坛
	[5] = {nTemplate = 1360, nLevel = -1, nSeries = -1}, --炮车
	[6] = {nTemplate = 1361, nLevel = -1, nSeries = -1}, --邵骑风
	[7] = {nTemplate = 104,  nLevel = -1, nSeries = 0},  --动态障碍墙
	[8] = {nTemplate = 1358,  nLevel = -1, nSeries = 0},  --放技能NPC
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
			{"AddNpc", 7, 2, 1, "wall_1", "wall_1_1",false, 32},
			{"OpenWindow", "LingJueFengLayerPanel", "Info",3, 9, "第四層 松壑雪嶺"},
		},
	},
	[2] = {nTime = 10, nNum = 1,
		tbPrelock = {1},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"RaiseEvent", "Start"},
			{"ShowTaskDialog", 10003, false},
			{"SetTargetPos", 3231, 2688},
			{"DoDeath", "wall_1"},
			{"OpenDynamicObstacle", "ops1"},
			{"AddNpc", 7, 2, 1, "wall_2", "wall_1_2",false, 32},
			
			--放技能NPC
			{"AddNpc", 8, 1, 0, "SkillNpc1", "RandomFuben4_2_SkillNpc1",false, 0, 0, 0, 0},
			{"AddNpc", 8, 1, 0, "SkillNpc2", "RandomFuben4_2_SkillNpc2",false, 0, 0, 0, 0},
			{"AddNpc", 8, 1, 0, "SkillNpc3", "RandomFuben4_2_SkillNpc3",false, 0, 0, 0, 0},
		},
	},
	[3] = {nTime = 0, nNum = 1,
		tbPrelock = {2},
		tbStartEvent = 
		{
			{"SetFubenProgress", 0, "探索凌絕峰"},
			{"TrapUnlock", "TrapLock1", 3},

			--酒坛子
			{"AddNpc", 4, 1, 30, "Tanzi1", "RandomFuben4_2_tanzi1",false, 0, 0, 0, 0},
			{"AddNpc", 4, 1, 31, "Tanzi2", "RandomFuben4_2_tanzi2",false, 0, 0, 0, 0},
			{"AddNpc", 4, 1, 32, "Tanzi3", "RandomFuben4_2_tanzi3",false, 0, 0, 0, 0},

			--金兵
			{"AddNpc", 1, 3, 4, "guaiwu1", "RandomFuben4_2_1",false, 0, 0, 0, 0},
			{"AddNpc", 1, 3, 4, "guaiwu2", "RandomFuben4_2_2",false, 0, 0, 0, 0},
			{"AddNpc", 1, 3, 4, "guaiwu3", "RandomFuben4_2_3",false, 0, 0, 0, 0},
		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},
			{"SetFubenProgress", 20, "擊敗金兵"},
			{"BlackMsg", "這群金兵似乎在守衛著什麼東西？"},
			{"NpcBubbleTalk", "guaiwu1", "來者何人，閒雜人等趕緊滾出去！", 4, 1, 1},	
		},
	},
	[4] = {nTime = 0, nNum = 9,
		tbPrelock = {3},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"SetFubenProgress", 40, "探索凌絕峰"},
			{"DoDeath", "wall_2"},
			{"OpenDynamicObstacle", "ops2"},
			{"SetTargetPos", 6502, 4305},	
		},
	},
	[5] = {nTime = 0, nNum = 1,
		tbPrelock = {4},
		tbStartEvent = 
		{
			{"TrapUnlock", "TrapLock2", 5},

			--酒坛子
			{"AddNpc", 4, 1, 33, "Tanzi4", "RandomFuben4_2_tanzi4",false, 0, 0, 0, 0},
			{"AddNpc", 4, 1, 34, "Tanzi5", "RandomFuben4_2_tanzi5",false, 0, 0, 0, 0},

			--金兵
			{"AddNpc", 1, 3, 6, "guaiwu4", "RandomFuben4_2_4",false, 0, 0, 0, 0},
			{"AddNpc", 1, 3, 6, "guaiwu5", "RandomFuben4_2_5",false, 0, 0, 0, 0},
		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},
			{"SetFubenProgress", 60, "擊敗金兵"},
			{"NpcBubbleTalk", "guaiwu4", "來者何人，閒雜人等趕緊滾出去！", 4, 1, 1},	

			--删除放技能NPC
			{"DelNpc", "SkillNpc1"},	
			{"DelNpc", "SkillNpc2"},
		},
	},
	[6] = {nTime = 0, nNum = 6,
		tbPrelock = {5},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"SetFubenProgress", 80, "探索凌絕峰"},
			{"SetTargetPos", 4209, 5487},

			--邵骑风 & 天忍教弟子
			{"AddNpc", 6, 1, 8, "BOSS", "RandomFuben4_2_BOSS",false, 0, 0, 0, 0},
			{"AddNpc", 1, 4, 0, "guaiwu", "RandomFuben4_2_6",false, 0, 0, 0, 0},
		},
	},
	[7] = {nTime = 0, nNum = 1,
		tbPrelock = {6},
		tbStartEvent = 
		{
			{"TrapUnlock", "TrapLock3", 7},
		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},
			{"SetFubenProgress", 80, "擊敗邵騎風"},
			{"BlackMsg", "沒想到這裡竟會有埋伏！！"},
			-- {"BlackMsg", "没想到这里竟会出现火炮，优先将火炮摧毁！！"},
			{"NpcBubbleTalk", "BOSS", "哪裡來的傢伙，竟敢壞我大事！", 4, 1, 1},

			--火炮
			{"AddNpc", 5, 1, 0, "guaiwu", "RandomFuben4_huopao1",false, 39, 0, 0, 0},
			{"AddNpc", 5, 1, 0, "guaiwu", "RandomFuben4_huopao2",false, 48, 0, 0, 0},	

			--删除放技能NPC
			{"DelNpc", "SkillNpc3"},	
		},
	},

-------------胜利判定------------------------
	[8] = {nTime = 0, nNum = 1,
		tbPrelock = {6},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"SetFubenProgress", 100, "擊敗邵騎風"},

			--判断模式获得积分
			{"RaiseEvent", "AddMissionScore", "d_score_win"},
			
			{"OpenWindow", "LingJueFengLayerPanel", "Win"},
			{"GameWin"},
		},
	},
-------------闯关时间------------------------

	[9] = {nTime = "d_2_time", nNum = 0,
		tbPrelock = {2},
		tbStartEvent = 
		{
			{"SetShowTime", 9},
		},
		tbUnLockEvent = 
		{
			{"BlackMsg", "此地危險重重不宜久留，還是趕緊撤退為妙！"},

			--判断模式获得积分
			{"RaiseEvent", "AddMissionScore", "d_score_lost"},

			{"OpenWindow", "LingJueFengLayerPanel", "Fail"},
			{"GameLost"},
		},
	},


	--酒坛子
	[30] = {nTime = 0, nNum = 1,
		tbPrelock = {2},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"CastSkill", "SkillNpc1", 2493, 20, 4017, 3087},
		},
	},
	[31] = {nTime = 0, nNum = 1,
		tbPrelock = {2},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"CastSkill", "SkillNpc1", 2493, 20, 4116, 2062},
		},
	},
	[32] = {nTime = 0, nNum = 1,
		tbPrelock = {2},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"CastSkill", "SkillNpc2", 2493, 20, 4863, 2708},
		},
	},
	[33] = {nTime = 0, nNum = 1,
		tbPrelock = {2},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"CastSkill", "SkillNpc3", 2493, 20, 6078, 4940},
		},
	},
	[34] = {nTime = 0, nNum = 1,
		tbPrelock = {2},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"CastSkill", "SkillNpc3", 2493, 20, 6910, 5344},
		},
	},
	
-----------------卡片收集掉落-------------
	[40] = {nTime = 1, nNum = 0,
		tbPrelock = {{30, 31, 32, 33, 34}},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"CloseLock", 41},
		},
	},
	[41] = {nTime = 1, nNum = 0,
		tbPrelock = {7},
		tbStartEvent = 
		{
			{"RaiseEvent", "DropCard", 2610, 400000},
		},
		tbUnLockEvent = 
		{
		},
	},

	-- --随机放技能(Stage1)
	-- [35] = {nTime = 2, nNum = 0,
	-- 	tbPrelock = {3},
	-- 	tbStartEvent = 
	-- 	{
	-- 	},
	-- 	tbUnLockEvent = 
	-- 	{
	-- 		{"IfCase", "GetTime() % 1 == 0", {"StartTimeCycle", "cycle_1", 2, 1, {"Random", {1000000, 36}}},
	-- 										 {"StartTimeCycle", "cycle_2", 4, 1, {"Random", {1000000, 37}}},
	-- 										 {"StartTimeCycle", "cycle_3", 6, 1, {"Random", {1000000, 38}}},
	-- 										 {"StartTimeCycle", "cycle_4", 8, 1, {"Random", {1000000, 39}}},
	-- 										 {"StartTimeCycle", "cycle_5", 10, 1, {"Random", {1000000, 40}}},
	-- 										{"StartTimeCycle", 4, 1, {"UseSkill", ...}, {},}, 
	-- 										{"StartTimeCycle", 6, 1, {"UseSkill", ...}, {},}, 
	-- 										{"StartTimeCycle", 8, 1, {"UseSkill", ...}, {},}, 
	-- 										{"StartTimeCycle", 10, 1, {"UseSkill", ...}, {},}, 
	-- 		},
	-- 		{"IfCase", "GetTime() % 3 == 2", }
	-- 		{"IfCase", "GetTime() % 3 == 0", }			
	-- 	},
	-- },
	-- [36] = {nTime = 2, nNum = 0,
	-- 	tbPrelock = {},
	-- 	tbStartEvent = 
	-- 	{
	-- 		{"CastSkill", "SkillNpc1", 1420, 1, 4196, 2567},
	-- 		{"StartTimeCycle","cycle_1", 10, nil, 
	-- 			{"CastSkill", "SkillNpc1", 1420, 1, 4196, 2567},
	-- 			{"StartTimeCycle","cycle_1", 2, 1, {"CastSkill", "SkillNpc1", 2375, 20, 4196, 2567},},
	-- 		},
	-- 	},
	-- 	tbUnLockEvent = 
	-- 	{
	-- 		{"CastSkill", "SkillNpc1", 2375, 20, 4196, 2567}, 
	-- 	},
	-- },
	-- [37] = {nTime = 2, nNum = 0,
	-- 	tbPrelock = {},
	-- 	tbStartEvent = 
	-- 	{
	-- 		{"CastSkill", "SkillNpc1", 1420, 1, 3459, 3047},
	-- 		{"StartTimeCycle","cycle_2", 10, nil, 
	-- 			{"CastSkill", "SkillNpc1", 1420, 1, 3459, 3047},
	-- 			{"StartTimeCycle", "cycle_2", 2, 1, {"CastSkill", "SkillNpc1", 2375, 1, 3459, 3047},},
	-- 		},
	-- 	},
	-- 	tbUnLockEvent = 
	-- 	{
	-- 		{"CastSkill", "SkillNpc1", 2375, 20, 3459, 3047}, 
	-- 	},
	-- },
	-- [38] = {nTime = 2, nNum = 0,
	-- 	tbPrelock = {},
	-- 	tbStartEvent = 
	-- 	{
	-- 		{"CastSkill", "SkillNpc1", 1420, 1, 3524, 2034},
	-- 		{"StartTimeCycle","cycle_3", 10, nil, 
	-- 			{"CastSkill", "SkillNpc1", 1420, 1, 3524, 2034},
	-- 			{"StartTimeCycle", "cycle_3", 2, 1, {"CastSkill", "SkillNpc1", 2375, 1, 3524, 2034},},
	-- 		},
	-- 	},
	-- 	tbUnLockEvent = 
	-- 	{
	-- 		{"CastSkill", "SkillNpc1", 2375, 20, 3524, 2034},
	-- 	},
	-- },
	-- [39] = {nTime = 2, nNum = 0,
	-- 	tbPrelock = {},
	-- 	tbStartEvent = 
	-- 	{
	-- 		{"CastSkill", "SkillNpc1", 1420, 1, 4777, 3287},
	-- 		{"StartTimeCycle","cycle_4", 10, nil, 
	-- 			{"CastSkill", "SkillNpc1", 1420, 1, 4777, 3287},
	-- 			{"StartTimeCycle", "cycle_4", 2, 1, {"CastSkill", "SkillNpc1", 2375, 1, 4777, 3287},},
	-- 		},
	-- 	},
	-- 	tbUnLockEvent = 
	-- 	{
	-- 		{"CastSkill", "SkillNpc1", 2375, 20, 4777, 3287},
	-- 	},
	-- },
	-- [40] = {nTime = 2, nNum = 0,
	-- 	tbPrelock = {},
	-- 	tbStartEvent = 
	-- 	{
	-- 		{"CastSkill", "SkillNpc1", 1420, 1, 4960, 2209},
	-- 		{"StartTimeCycle","cycle_5", 10, nil, 
	-- 			{"CastSkill", "SkillNpc1", 1420, 1, 4960, 2209},
	-- 			{"StartTimeCycle", "cycle_5", 2, 1, {"CastSkill", "SkillNpc1", 2375, 1, 4960, 2209},},
	-- 		},
	-- 	},
	-- 	tbUnLockEvent = 
	-- 	{
	-- 		{"CastSkill", "SkillNpc1", 2375, 20, 4960, 2209},
	-- 	},
	-- },

	-- --随机放技能(Stage2)
	-- [41] = {nTime = 2, nNum = 0,
	-- 	tbPrelock = {5},
	-- 	tbStartEvent = 
	-- 	{
	-- 	},
	-- 	tbUnLockEvent = 
	-- 	{
	-- 		{"IfCase", "GetTime() % 1 == 0", {"StartTimeCycle", "cycle_1", 2, 1, {"Random", {1000000, 42}}},
	-- 										 {"StartTimeCycle", "cycle_2", 4, 1, {"Random", {1000000, 43}}},
	-- 		},
	-- 	},
	-- },
	-- [42] = {nTime = 2, nNum = 0,
	-- 	tbPrelock = {},
	-- 	tbStartEvent = 
	-- 	{
	-- 		{"CastSkill", "SkillNpc4", 1420, 1, 6628, 5090},
	-- 		{"StartTimeCycle","cycle_1", 10, nil, 
	-- 			{"CastSkill", "SkillNpc4", 1420, 1, 6628, 5090},
	-- 			{"StartTimeCycle", "cycle_1", 2, 1, {"CastSkill", "SkillNpc4", 2375, 20, 6628, 5090},},
	-- 		},
	-- 	},
	-- 	tbUnLockEvent = 
	-- 	{
	-- 		{"CastSkill", "SkillNpc4", 2375, 20, 6628, 5090},
	-- 	},
	-- },
	-- [43] = {nTime = 2, nNum = 0,
	-- 	tbPrelock = {},
	-- 	tbStartEvent = 
	-- 	{
	-- 		{"CastSkill", "SkillNpc4", 1420, 1, 6553, 4313},
	-- 		{"StartTimeCycle","cycle_2", 10, nil, 
	-- 			{"CastSkill", "SkillNpc4", 1420, 1, 6553, 4313},
	-- 			{"StartTimeCycle", "cycle_2", 2, 1, {"CastSkill", "SkillNpc4", 2375, 20, 6553, 4313},},
	-- 		},
	-- 	},
	-- 	tbUnLockEvent = 
	-- 	{
	-- 		{"CastSkill", "SkillNpc4", 2375, 20, 6553, 4313},
	-- 	},
	-- },

	--随机放技能(Stage3)
	-- [44] = {nTime = 2, nNum = 0,
	-- 	tbPrelock = {7},
	-- 	tbStartEvent = 
	-- 	{
	-- 	},
	-- 	tbUnLockEvent = 
	-- 	{			
	-- 		{"IfCase", "GetTime() % 1 == 0", {"StartTimeCycle", "cycle_1", 2, 1, {"Random", {1000000, 45}}},
	-- 										 {"StartTimeCycle", "cycle_2", 4, 1, {"Random", {1000000, 46}}},
	-- 										 {"StartTimeCycle", "cycle_3", 6, 1, {"Random", {1000000, 47}}},
	-- 										 {"StartTimeCycle", "cycle_4", 8, 1, {"Random", {1000000, 48}}},
	-- 										 {"StartTimeCycle", "cycle_5", 10, 1, {"Random", {1000000, 49}}},
	-- 		},
	-- 	},
	-- },
	-- [45] = {nTime = 2, nNum = 0,
	-- 	tbPrelock = {},
	-- 	tbStartEvent = 
	-- 	{
	-- 		{"CastSkill", "SkillNpc6", 1420, 1, 3978, 5989},
	-- 		{"StartTimeCycle","cycle_1", 10, nil, 
	-- 			{"CastSkill", "SkillNpc6", 1420, 1, 3978, 5989},
	-- 			{"StartTimeCycle", "cycle_1", 2, 1, {"CastSkill", "SkillNpc6", 2375, 20, 3978, 5989},},
	-- 		},
	-- 	},
	-- 	tbUnLockEvent = 
	-- 	{
	-- 		{"CastSkill", "SkillNpc6", 2375, 20, 3978, 5989},
	-- 	},
	-- },
	-- [46] = {nTime = 2, nNum = 0,
	-- 	tbPrelock = {},
	-- 	tbStartEvent = 
	-- 	{
	-- 		{"CastSkill", "SkillNpc6", 1420, 1, 4022, 4963},
	-- 		{"StartTimeCycle","cycle_2", 10, nil, 
	-- 			{"CastSkill", "SkillNpc6", 1420, 1, 4022, 4963},
	-- 			{"StartTimeCycle", "cycle_2", 2, 1, {"CastSkill", "SkillNpc6", 2375, 20, 4022, 4963},},
	-- 		},
	-- 	},
	-- 	tbUnLockEvent = 
	-- 	{
	-- 		{"CastSkill", "SkillNpc6", 2375, 20, 4022, 4963},
	-- 	},
	-- },
	-- [47] = {nTime = 2, nNum = 0,
	-- 	tbPrelock = {},
	-- 	tbStartEvent = 
	-- 	{
	-- 		{"CastSkill", "SkillNpc6", 1420, 1, 3031, 5945},
	-- 		{"StartTimeCycle","cycle_3", 10, nil, 
	-- 			{"CastSkill", "SkillNpc6", 1420, 1, 3031, 5945},
	-- 			{"StartTimeCycle", "cycle_3", 2, 1, {"CastSkill", "SkillNpc6", 2375, 20, 3031, 5945},},
	-- 		},
	-- 	},
	-- 	tbUnLockEvent = 
	-- 	{
	-- 		{"CastSkill", "SkillNpc6", 2375, 20, 3031, 5945},
	-- 	},
	-- },
	-- [48] = {nTime = 2, nNum = 0,
	-- 	tbPrelock = {},
	-- 	tbStartEvent = 
	-- 	{
	-- 		{"CastSkill", "SkillNpc6", 1420, 1, 2983, 4871},
	-- 		{"StartTimeCycle","cycle_4", 10, nil, 
	-- 			{"CastSkill", "SkillNpc6", 1420, 1, 2983, 4871},
	-- 			{"StartTimeCycle", "cycle_4", 2, 1, {"CastSkill", "SkillNpc6", 2375, 20, 2983, 4871},},
	-- 		},
	-- 	},
	-- 	tbUnLockEvent = 
	-- 	{
	-- 		{"CastSkill", "SkillNpc6", 2375, 20, 2983, 4871},
	-- 	},
	-- },
	-- [49] = {nTime = 2, nNum = 0,
	-- 	tbPrelock = {},
	-- 	tbStartEvent = 
	-- 	{
	-- 		{"CastSkill", "SkillNpc6", 1420, 1, 3537, 5400},
	-- 		{"StartTimeCycle","cycle_6", 10, nil, 
	-- 			{"CastSkill", "SkillNpc6", 1420, 1, 3537, 5400},
	-- 			{"StartTimeCycle", "cycle_6", 2, 1, {"CastSkill", "SkillNpc6", 2375, 20, 3537, 5400},},
	-- 		},
	-- 	},
	-- 	tbUnLockEvent = 
	-- 	{
	-- 		{"CastSkill", "SkillNpc6", 2375, 20, 3537, 5400},
	-- 	},
	-- },
}
