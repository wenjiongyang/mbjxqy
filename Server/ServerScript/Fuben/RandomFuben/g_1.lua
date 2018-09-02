
local tbFubenSetting = Fuben.RandomFuben:GetRandomFubenSetting("g_1");

tbFubenSetting.tbMultiBeginPoint = {{1891, 7328},{2126, 7502},{2065, 7067},{2305, 7267}}  
tbFubenSetting.tbTempRevivePoint = {2053, 7397};
tbFubenSetting.nStartDir		 = 24;


tbFubenSetting.NPC = 
{
	[1] = {nTemplate = 1986, nLevel = -1, nSeries = -1}, --boss璇玑子

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

			{"OpenWindow", "LingJueFengLayerPanel", "Info",3, 9, "第七層 哀號危崖"},
		},
	},
	[2] = {nTime = 10, nNum = 0,
		tbPrelock = {1},
		tbStartEvent = 
		{
			{"SetFubenProgress", -1,"等待秘境開啟"},
			{"AddNpc", 100, 2, 0, "wall", "wall1",false, 41},
		},
		tbUnLockEvent = 
		{
			{"RaiseEvent", "Start"},
			{"BlackMsg", "此處似乎有高手出沒，我們還是小心為妙！"},
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
			{"BlackMsg", "此人武藝高強，還是先撤退為妙！"},
			{"OpenWindow", "LingJueFengLayerPanel", "Fail"},
			{"GameLost"},
		},
	},

	[4] = {nTime = 0, nNum = 1,
		tbPrelock = {2},
		tbStartEvent = 
		{
			{"TrapUnlock", "trap1", 4},
			{"SetTargetPos", 4372, 5143},
			{"SetFubenProgress", 0, "探索凌絕峰"},
		},
		tbUnLockEvent = 
		{
			{"SetFubenProgress", 60, "與璿璣子比試"},
			{"ClearTargetPos"},		    
			{"SetNpcProtected", "boss", 0},
			{"SetAiActive", "boss", 1},
			{"SetHeadVisiable", "boss", true, 0},
			{"NpcBubbleTalk", "boss", "沒想到竟會在此處遇到你們，那就讓我們來切磋一番吧！！", 4, 1, 1},
		},
	},
	[5] = {nTime = 0, nNum = 1,
		tbPrelock = {2},
		tbStartEvent = 
		{
			{"AddNpc", 1, 1, 5, "boss", "boss1", false, 56, 0, 0, 0},	
			{"SetNpcProtected", "boss", 1},
			{"SetAiActive", "boss", 0},
			{"SetHeadVisiable", "boss", false, 1},
		},
		tbUnLockEvent = 
		{
			--判断模式篝火&踢出
			{"IfCase", "self.nFubenLevel == 3",
				{"AddSimpleNpc", 1611, 4704, 4883, 0},
				{"RaiseEvent", "KickOutAllPlayer", 40},
			},
			--判断模式获得积分
			{"RaiseEvent", "AddMissionScore", "g_score_win"},

			{"SetFubenProgress", 100, "與璿璣子比試"},
			{"OpenWindow", "LingJueFengLayerPanel", "Win"},
			{"GameWin"},
		},
	},
	-------------------阶段1----------------------
	[6] = {nTime = 0, nNum = 1,
		tbPrelock = {4},
		tbStartEvent = 
		{
			{"NpcHpUnlock", "boss", 6, 90},
		},
		tbUnLockEvent = 
		{
			{"NpcBubbleTalk", "boss", "你們很不錯！那再來見識下我崑崙派的秘術！", 4, 0, 1},
		},
	},
	[7] = {nTime = 22, nNum = 0,
		tbPrelock = {6},
		tbStartEvent = 
		{
			--boss技能
			{"CastSkillMulti", "boss", 3104, 1, "skill_point_1", 2},
			{"CastSkillMulti", "boss", 3104, 1, "skill_point_2", 2},
			{"CastSkillMulti", "boss", 3104, 1, "skill_point_3", 3},
			{"CastSkillMulti", "boss", 3104, 1, "skill_point_4", 8},

			{"StartTimeCycle", "cycle_1", 10, nil, 
				--boss技能
				{"CastSkillMulti", "boss", 3104, 1, "skill_point_1", 2},
				{"CastSkillMulti", "boss", 3104, 1, "skill_point_2", 2},
				{"CastSkillMulti", "boss", 3104, 1, "skill_point_3", 3},
				{"CastSkillMulti", "boss", 3104, 1, "skill_point_4", 8},
			},
		},
		tbUnLockEvent = 
		{
			{"NpcBubbleTalk", "boss", "崑崙秘術，神鬼難測！", 4, 0, 1},
			{"CloseCycle", "cycle_1"},
		},
	},
	-------------------阶段2----------------------
	[8] = {nTime = 0, nNum = 1,
		tbPrelock = {4},
		tbStartEvent = 
		{
			{"NpcHpUnlock", "boss", 8, 60},
		},
		tbUnLockEvent = 
		{
			{"NpcBubbleTalk", "boss", "小心，接下來就是無盡的火海了！", 4, 0, 1},
		},
	},
	[9] = {nTime = 3, nNum = 0,
		tbPrelock = {8},
		tbStartEvent = 
		{
			--boss技能
			{"CastSkillMulti", "boss", 3104, 1, "skill_point_1", 2},
			{"CastSkillMulti", "boss", 3104, 1, "skill_point_2", 2},
			{"CastSkillMulti", "boss", 3104, 1, "skill_point_3", 3},
			{"CastSkillMulti", "boss", 3104, 1, "skill_point_4", 8},
			{"StartTimeCycle", "cycle_2", 11, nil, 
				--boss技能
				{"CastSkillMulti", "boss", 3104, 1, "skill_point_1", 2},
				{"CastSkillMulti", "boss", 3104, 1, "skill_point_2", 2},
				{"CastSkillMulti", "boss", 3104, 1, "skill_point_3", 3},
				{"CastSkillMulti", "boss", 3104, 1, "skill_point_4", 8},
			},
		},
		tbUnLockEvent = 
		{
		},
	},
	
}

