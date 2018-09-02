
local tbFubenSetting = Fuben.RandomFuben:GetRandomFubenSetting("d_1");

tbFubenSetting.tbMultiBeginPoint = {{1269, 1540},{1596, 1310},{1080, 1310},{1382, 1098}}	-- 副本出生点
tbFubenSetting.tbTempRevivePoint = {1453, 1361};
tbFubenSetting.nStartDir		 = 6;


--NPC模版ID，NPC等级，NPC五行；

--[[
]]

tbFubenSetting.NPC = 
{
	[1] = {nTemplate = 1622, nLevel = -1, nSeries = 0},  --放技能NPC
	[2] = {nTemplate = 1138, nLevel = -1, nSeries = -1}, --张琳心（首领）
	[3] = {nTemplate = 1618, nLevel = -1, nSeries = -1}, --红樱侍（关键NPC）
	[4] = {nTemplate = 104,  nLevel = -1, nSeries = 0},
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

			--调整摄像机基础参数
			{"ChangeCameraSetting", 30, 35, 20},

			{"SetFubenProgress", -1,"等待秘境開啟"},
			{"AddNpc", 4, 2, 1, "wall", "wall_1_1",false, 23},
			{"OpenWindow", "LingJueFengLayerPanel", "Info",3, 9, "第四層 峰頂山門"},
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
			{"ShowTaskDialog", 10003, false},
			{"DoDeath", "wall"},
			{"OpenDynamicObstacle", "ops1"},
			{"SetTargetPos", 3213, 3085},
		},
	},
	[3] = {nTime = 0, nNum = 1,
		tbPrelock = {2},
		tbStartEvent = 
		{
			{"SetFubenProgress", 0, "探索凌絕峰"},
			{"TrapUnlock", "TrapLock1", 3},

			--张琳心
			{"AddNpc", 2, 1, 4, "BOSS", "RandomFuben4_1_BOSS", false, 40, 0, 0, 0},	
			{"SetHeadVisiable", "BOSS", false, 1},
			{"NpcHpUnlock", "BOSS", 30, 80},
			{"SetNpcProtected", "BOSS", 1},
			{"SetAiActive", "BOSS", 0},
		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},
			{"SetFubenProgress", 50, "擊敗張琳心"},
			{"SetNpcProtected", "BOSS", 0},
			{"SetAiActive", "BOSS", 1},
			{"SetHeadVisiable", "BOSS", true, 0},
			{"NpcBubbleTalk", "BOSS", "你們是什麼人，在這裡做什麼？！", 4, 0, 1},	
		},
	},
------------------------------------流程阶段------------------------------
----------------------阶段1---------------------------
	[30] = {nTime = 0, nNum = 1,
		tbPrelock = {3},
		tbStartEvent = 
		{		
		},
		tbUnLockEvent = 
		{	
			{"NpcBubbleTalk", "BOSS", "沒想到你們倒還有點本事，既然如此就讓你們嘗嘗我的厲害！！", 4, 1, 1},	
			{"NpcHpUnlock", "BOSS", 40, 40},

			--无敌				
			{"NpcAddBuff", "BOSS", 2417, 1, 120},

			--关闭AI
			{"SetAiActive", "BOSS", 0},

			--苗疆女子
			{"AddNpc", 3, 1, 35, "Control_1", "RandomFuben4_1_Control1", false, 12, 0, 0, 0},	
			{"AddNpc", 3, 1, 36, "Control_2", "RandomFuben4_1_Control2", false, 3, 0, 0, 0},

			--放技能NPC
			{"AddNpc", 1, 1, 0, "SkillNpc_1", "RandomFuben4_1_SkillNpc1", false, 0, 0, 0, 0},
			{"AddNpc", 1, 1, 0, "SkillNpc_2", "RandomFuben4_1_SkillNpc2", false, 0, 0, 0, 0},
			{"AddNpc", 1, 1, 0, "SkillNpc_3", "RandomFuben4_1_SkillNpc3", false, 0, 0, 0, 0},
			{"AddNpc", 1, 1, 0, "SkillNpc_4", "RandomFuben4_1_SkillNpc4", false, 0, 0, 0, 0},
			{"AddNpc", 1, 1, 0, "SkillNpc_5", "RandomFuben4_1_SkillNpc5", false, 0, 0, 0, 0},
			{"AddNpc", 1, 1, 0, "SkillNpc_6", "RandomFuben4_1_SkillNpc6", false, 0, 0, 0, 0},
			{"AddNpc", 1, 1, 0, "SkillNpc_7", "RandomFuben4_1_SkillNpc7", false, 0, 0, 0, 0},
			{"AddNpc", 1, 1, 0, "SkillNpc_8", "RandomFuben4_1_SkillNpc8", false, 0, 0, 0, 0},
		},
	},
	[31] = {nTime = 10, nNum = 0,
		tbPrelock = {30},
		tbStartEvent = 
		{				
		},
		tbUnLockEvent = 
		{		
			{"NpcBubbleTalk", "BOSS", "來嘗嘗這招「雷動九天」的威力吧！！", 4, 1, 1},	

			--释放全屏技能	
			{"CastSkill", "SkillNpc_1", 1312, 30, -1, -1},
			{"CastSkill", "SkillNpc_2", 1312, 30, -1, -1},
			{"CastSkill", "SkillNpc_3", 1312, 30, -1, -1},
			{"CastSkill", "SkillNpc_4", 1312, 30, -1, -1},
			{"CastSkill", "SkillNpc_5", 1312, 30, -1, -1},
			{"CastSkill", "SkillNpc_6", 1312, 30, -1, -1},
			{"CastSkill", "SkillNpc_7", 1312, 30, -1, -1},
			{"CastSkill", "SkillNpc_8", 1312, 30, -1, -1},

			--恢复AI
			{"SetAiActive", "BOSS", 1},

			--移除无敌BUFF
			{"NpcRemoveBuff", "BOSS", 2417},

			--删除火焰陷阱 & 守护NPC
			{"DelNpc", "Control_1"},
			{"DelNpc", "Control_2"},
			{"DelNpc", "Temporary_1"},
			{"DelNpc", "Temporary_2"},
			{"DelNpc", "Fire_1"},
			{"DelNpc", "Fire_2"},
			{"DelNpc", "Fire_3"},
			{"DelNpc", "Fire_4"},
			{"DelNpc", "Fire_5"},
			{"DelNpc", "Fire_6"},
			{"DelNpc", "Fire_7"},
			{"DelNpc", "Fire_8"},
			{"DelNpc", "Fire_9"},

			--关闭循环
			{"CloseCycle", "cycle_1"},	
			{"CloseCycle", "cycle_2"},	

			--关闭锁
			{"CloseLock", 37},
		},
	},
	[32] = {nTime = 1, nNum = 0,
		tbPrelock = {30},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"BlackMsg", "[FFFE0D]苗疆女子[-]似乎在施展秘術，請儘快將其擊殺！"},

			--播放攻击动作
			{"DoCommonAct", "Control_1", 16, 0, 1, 0},
			{"DoCommonAct", "Control_2", 16, 0, 1, 0},
			{"CastSkill", "Temporary_1", 1444, 1, -1, -1},
			{"CastSkill", "Temporary_2", 1444, 1, -1, -1},
			{"AddNpc", 1, 1, 0, "Temporary_1", "RandomFuben4_1_Control1", false, 0, 0, 0, 0},	
			{"AddNpc", 1, 1, 0, "Temporary_2", "RandomFuben4_1_Control2", false, 0, 0, 0, 0},	

			--蓄力
			{"StartTimeCycle", "cycle_2", 2, 100, 
				{"CastSkill", "Temporary_1", 1444, 1, -1, -1},
				{"CastSkill", "Temporary_2", 1444, 1, -1, -1},
			},

			--陷阱
			{"AddNpc", 1, 1, 0, "Fire_1", "RandomFuben4_1_Fire1", false, 0, 0, 0, 0},	
			{"AddNpc", 1, 1, 0, "Fire_2", "RandomFuben4_1_Fire2", false, 0, 0, 0, 0},	
			{"AddNpc", 1, 1, 0, "Fire_3", "RandomFuben4_1_Fire3", false, 0, 0, 0, 0},	
			{"AddNpc", 1, 1, 0, "Fire_4", "RandomFuben4_1_Fire4", false, 0, 0, 0, 0},	
			{"AddNpc", 1, 1, 0, "Fire_5", "RandomFuben4_1_Fire5", false, 0, 0, 0, 0},	
			{"AddNpc", 1, 1, 0, "Fire_6", "RandomFuben4_1_Fire6", false, 0, 0, 0, 0},	
			{"AddNpc", 1, 1, 0, "Fire_7", "RandomFuben4_1_Fire7", false, 0, 0, 0, 0},	
			{"AddNpc", 1, 1, 0, "Fire_8", "RandomFuben4_1_Fire8", false, 0, 0, 0, 0},	
			{"AddNpc", 1, 1, 0, "Fire_9", "RandomFuben4_1_Fire9", false, 0, 0, 0, 0},	
		},
	},
	[33] = {nTime = 0.1, nNum = 0,
		tbPrelock = {32},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"NpcAddBuff", "Fire_1", 2402, 1, 100},
			{"NpcAddBuff", "Fire_2", 2402, 1, 100},
			{"NpcAddBuff", "Fire_3", 2402, 1, 100},
			{"NpcAddBuff", "Fire_4", 2402, 1, 100},
			{"NpcAddBuff", "Fire_5", 2402, 1, 100},
			{"NpcAddBuff", "Fire_6", 2402, 1, 100},
			{"NpcAddBuff", "Fire_7", 2402, 1, 100},
			{"NpcAddBuff", "Fire_8", 2402, 1, 100},
			{"NpcAddBuff", "Fire_9", 2402, 1, 100},									
		},
	},
	[34] = {nTime = 2, nNum = 0,
		tbPrelock = {33},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"CastSkill", "Fire_1", 2779, 30, -1, -1},
			{"CastSkill", "Fire_2", 2779, 30, -1, -1},
			{"CastSkill", "Fire_3", 2779, 30, -1, -1},
			{"CastSkill", "Fire_4", 2779, 30, -1, -1},
			{"CastSkill", "Fire_5", 2779, 30, -1, -1},
			{"CastSkill", "Fire_6", 2779, 30, -1, -1},
			{"CastSkill", "Fire_7", 2779, 30, -1, -1},
			{"CastSkill", "Fire_8", 2779, 30, -1, -1},
			{"CastSkill", "Fire_9", 2779, 30, -1, -1},

			--火焰陷阱	
			{"StartTimeCycle", "cycle_1", 9, 100, 
				{"CastSkill", "Fire_1", 2779, 30, -1, -1},
				{"CastSkill", "Fire_2", 2779, 30, -1, -1},
				{"CastSkill", "Fire_3", 2779, 30, -1, -1},
				{"CastSkill", "Fire_4", 2779, 30, -1, -1},
				{"CastSkill", "Fire_5", 2779, 30, -1, -1},
				{"CastSkill", "Fire_6", 2779, 30, -1, -1},
				{"CastSkill", "Fire_7", 2779, 30, -1, -1},
				{"CastSkill", "Fire_8", 2779, 30, -1, -1},
				{"CastSkill", "Fire_9", 2779, 30, -1, -1},
			},
		},
	},
	[35] = {nTime = 0, nNum = 1,
		tbPrelock = {30},
		tbStartEvent = 
		{				
		},
		tbUnLockEvent = 
		{
		},
	},
	[36] = {nTime = 0, nNum = 1,
		tbPrelock = {30},
		tbStartEvent = 
		{				
		},
		tbUnLockEvent = 
		{
		},
	},
	[37] = {nTime = 0.1, nNum = 0,
		tbPrelock = {35, 36},
		tbStartEvent = 
		{				
		},
		tbUnLockEvent = 
		{		
			--恢复AI
			{"SetAiActive", "BOSS", 1},

			--移除无敌BUFF
			{"NpcRemoveBuff", "BOSS", 2417},

			--删除火焰陷阱
			{"DelNpc", "Temporary_1"},
			{"DelNpc", "Temporary_2"},
			{"DelNpc", "Fire_1"},
			{"DelNpc", "Fire_2"},
			{"DelNpc", "Fire_3"},
			{"DelNpc", "Fire_4"},
			{"DelNpc", "Fire_5"},
			{"DelNpc", "Fire_6"},
			{"DelNpc", "Fire_7"},
			{"DelNpc", "Fire_8"},
			{"DelNpc", "Fire_9"},

			--关闭循环
			{"CloseCycle", "cycle_1"},
			{"CloseCycle", "cycle_2"},	

			--关闭锁
			{"CloseLock", 31},
		},
	},
----------------------阶段2---------------------------
	[40] = {nTime = 0, nNum = 1,
		tbPrelock = {30},
		tbStartEvent = 
		{		
		},
		tbUnLockEvent = 
		{	
			{"NpcBubbleTalk", "BOSS", "可惡... 沒想到竟會如此棘手！！但你們也不要太得意了！！", 4, 1, 1},	

			--无敌				
			{"NpcAddBuff", "BOSS", 2417, 1, 120},

			--关闭AI
			{"SetAiActive", "BOSS", 0},

			--苗疆女子
			{"AddNpc", 3, 1, 45, "Control_3", "RandomFuben4_1_Control1", false, 12, 0, 0, 0},	
			{"AddNpc", 3, 1, 46, "Control_4", "RandomFuben4_1_Control2", false, 3, 0, 0, 0},
		},
	},
	[41] = {nTime = 10, nNum = 0,
		tbPrelock = {40},
		tbStartEvent = 
		{				
		},
		tbUnLockEvent = 
		{		
			{"NpcBubbleTalk", "BOSS", "來嘗嘗這招「雷動九天」的威力吧！！", 4, 1, 1},	

			--释放全屏技能	
			{"CastSkill", "SkillNpc_1", 1312, 30, -1, -1},
			{"CastSkill", "SkillNpc_2", 1312, 30, -1, -1},
			{"CastSkill", "SkillNpc_3", 1312, 30, -1, -1},
			{"CastSkill", "SkillNpc_4", 1312, 30, -1, -1},
			{"CastSkill", "SkillNpc_5", 1312, 30, -1, -1},
			{"CastSkill", "SkillNpc_6", 1312, 30, -1, -1},
			{"CastSkill", "SkillNpc_7", 1312, 30, -1, -1},
			{"CastSkill", "SkillNpc_8", 1312, 30, -1, -1},

			--恢复AI
			{"SetAiActive", "BOSS", 1},

			--移除无敌BUFF
			{"NpcRemoveBuff", "BOSS", 2417},

			--删除火焰陷阱 & 守护NPC
			{"DelNpc", "Control_3"},
			{"DelNpc", "Control_4"},
			{"DelNpc", "Temporary_3"},
			{"DelNpc", "Temporary_4"},
			{"DelNpc", "Fire_10"},
			{"DelNpc", "Fire_11"},
			{"DelNpc", "Fire_12"},
			{"DelNpc", "Fire_13"},
			{"DelNpc", "Fire_14"},
			{"DelNpc", "Fire_15"},
			{"DelNpc", "Fire_16"},
			{"DelNpc", "Fire_17"},
			{"DelNpc", "Fire_18"},

			--关闭循环
			{"CloseCycle", "cycle_3"},	
			{"CloseCycle", "cycle_4"},	

			--关闭锁
			{"CloseLock", 47},
		},
	},
	[42] = {nTime = 1, nNum = 0,
		tbPrelock = {40},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"BlackMsg", "[FFFE0D]苗疆女子[-]似乎在施展秘術，請儘快將其擊殺！"},

			--播放攻击动作
			{"DoCommonAct", "Control_3", 16, 0, 1, 0},
			{"DoCommonAct", "Control_4", 16, 0, 1, 0},
			{"CastSkill", "Temporary_3", 1444, 1, -1, -1},
			{"CastSkill", "Temporary_4", 1444, 1, -1, -1},
			{"AddNpc", 1, 1, 0, "Temporary_3", "RandomFuben4_1_Control1", false, 0, 0, 0, 0},	
			{"AddNpc", 1, 1, 0, "Temporary_4", "RandomFuben4_1_Control2", false, 0, 0, 0, 0},	

			--蓄力
			{"StartTimeCycle", "cycle_4", 2, 100, 
				{"CastSkill", "Temporary_3", 1444, 1, -1, -1},
				{"CastSkill", "Temporary_4", 1444, 1, -1, -1},
			},

			--陷阱
			{"AddNpc", 1, 1, 0, "Fire_10", "RandomFuben4_1_Fire1", false, 0, 0, 0, 0},	
			{"AddNpc", 1, 1, 0, "Fire_11", "RandomFuben4_1_Fire2", false, 0, 0, 0, 0},	
			{"AddNpc", 1, 1, 0, "Fire_12", "RandomFuben4_1_Fire3", false, 0, 0, 0, 0},	
			{"AddNpc", 1, 1, 0, "Fire_13", "RandomFuben4_1_Fire4", false, 0, 0, 0, 0},	
			{"AddNpc", 1, 1, 0, "Fire_14", "RandomFuben4_1_Fire5", false, 0, 0, 0, 0},	
			{"AddNpc", 1, 1, 0, "Fire_15", "RandomFuben4_1_Fire6", false, 0, 0, 0, 0},	
			{"AddNpc", 1, 1, 0, "Fire_16", "RandomFuben4_1_Fire7", false, 0, 0, 0, 0},	
			{"AddNpc", 1, 1, 0, "Fire_17", "RandomFuben4_1_Fire8", false, 0, 0, 0, 0},	
			{"AddNpc", 1, 1, 0, "Fire_18", "RandomFuben4_1_Fire9", false, 0, 0, 0, 0},	
		},
	},
	[43] = {nTime = 0.1, nNum = 0,
		tbPrelock = {42},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"NpcAddBuff", "Fire_10", 2402, 1, 100},
			{"NpcAddBuff", "Fire_11", 2402, 1, 100},
			{"NpcAddBuff", "Fire_12", 2402, 1, 100},
			{"NpcAddBuff", "Fire_13", 2402, 1, 100},
			{"NpcAddBuff", "Fire_14", 2402, 1, 100},
			{"NpcAddBuff", "Fire_15", 2402, 1, 100},
			{"NpcAddBuff", "Fire_16", 2402, 1, 100},
			{"NpcAddBuff", "Fire_17", 2402, 1, 100},
			{"NpcAddBuff", "Fire_18", 2402, 1, 100},									
		},
	},
	[44] = {nTime = 2, nNum = 0,
		tbPrelock = {43},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"CastSkill", "Fire_10", 2779, 30, -1, -1},
			{"CastSkill", "Fire_11", 2779, 30, -1, -1},
			{"CastSkill", "Fire_12", 2779, 30, -1, -1},
			{"CastSkill", "Fire_13", 2779, 30, -1, -1},
			{"CastSkill", "Fire_14", 2779, 30, -1, -1},
			{"CastSkill", "Fire_15", 2779, 30, -1, -1},
			{"CastSkill", "Fire_16", 2779, 30, -1, -1},
			{"CastSkill", "Fire_17", 2779, 30, -1, -1},
			{"CastSkill", "Fire_18", 2779, 30, -1, -1},

			--火焰陷阱	
			{"StartTimeCycle", "cycle_3", 9, 100, 
				{"CastSkill", "Fire_10", 2779, 30, -1, -1},
				{"CastSkill", "Fire_11", 2779, 30, -1, -1},
				{"CastSkill", "Fire_12", 2779, 30, -1, -1},
				{"CastSkill", "Fire_13", 2779, 30, -1, -1},
				{"CastSkill", "Fire_14", 2779, 30, -1, -1},
				{"CastSkill", "Fire_15", 2779, 30, -1, -1},
				{"CastSkill", "Fire_16", 2779, 30, -1, -1},
				{"CastSkill", "Fire_17", 2779, 30, -1, -1},
				{"CastSkill", "Fire_18", 2779, 30, -1, -1},
			},
		},
	},
	[45] = {nTime = 0, nNum = 1,
		tbPrelock = {40},
		tbStartEvent = 
		{				
		},
		tbUnLockEvent = 
		{
		},
	},
	[46] = {nTime = 0, nNum = 1,
		tbPrelock = {40},
		tbStartEvent = 
		{				
		},
		tbUnLockEvent = 
		{
		},
	},
	[47] = {nTime = 0.1, nNum = 0,
		tbPrelock = {45, 46},
		tbStartEvent = 
		{				
		},
		tbUnLockEvent = 
		{		
			--恢复AI
			{"SetAiActive", "BOSS", 1},

			--移除无敌BUFF
			{"NpcRemoveBuff", "BOSS", 2417},

			--删除火焰陷阱
			{"DelNpc", "Temporary_3"},
			{"DelNpc", "Temporary_4"},
			{"DelNpc", "Fire_10"},
			{"DelNpc", "Fire_11"},
			{"DelNpc", "Fire_12"},
			{"DelNpc", "Fire_13"},
			{"DelNpc", "Fire_14"},
			{"DelNpc", "Fire_15"},
			{"DelNpc", "Fire_16"},
			{"DelNpc", "Fire_17"},
			{"DelNpc", "Fire_18"},

			--关闭循环
			{"CloseCycle", "cycle_3"},
			{"CloseCycle", "cycle_4"},	

			--关闭锁
			{"CloseLock", 41},
		},
	},

-------------胜利判定------------------------
	[4] = {nTime = 0, nNum = 1,
		tbPrelock = {3},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"SetFubenProgress", 100, "擊敗張琳心"},

			--判断模式获得积分
			{"RaiseEvent", "AddMissionScore", "d_score_win"},

			{"OpenWindow", "LingJueFengLayerPanel", "Win"},
			{"GameWin"},
		},
	},
-------------闯关时间------------------------
	
	[5] = {nTime = "d_1_time", nNum = 0,
		tbPrelock = {2},
		tbStartEvent = 
		{
			{"SetShowTime", 5},
		},
		tbUnLockEvent = 
		{
			--判断模式获得积分
			{"RaiseEvent", "AddMissionScore", "d_score_lost"},

			{"BlackMsg", "這女子武功竟然如此厲害，看來得另尋道路了！"},
			{"OpenWindow", "LingJueFengLayerPanel", "Fail"},
			{"GameLost"},
		},
	},

}

