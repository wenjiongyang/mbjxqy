
local tbFubenSetting = Fuben.RandomFuben:GetRandomFubenSetting("d_4");

tbFubenSetting.tbMultiBeginPoint = {{2329, 5063},{2347, 4673},{1982, 5051},{1963, 4681}}	-- 副本出生点
tbFubenSetting.tbTempRevivePoint = {2167, 4847};
tbFubenSetting.nStartDir		 = 14;


tbFubenSetting.NPC = 
{
	[1] = {nTemplate = 1599, nLevel = -1, nSeries = -1}, --天星道长-boss
	[2] = {nTemplate = 104,  nLevel = -1, nSeries = 0},  --动态障碍墙
	[3] = {nTemplate = 1140, nLevel = -1, nSeries = 0},  --放技能NPC
	[4] = {nTemplate = 1620, nLevel = -1, nSeries = 0},  --引雷剑
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
			{"AddNpc", 2, 2, 1, "wall", "wall_1_1",false, 33},
			{"OpenWindow", "LingJueFengLayerPanel", "Info",3, 9, "第四層 千壑雪嶺"},
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
			{"SetFubenProgress", 0, "探索凌絕峰"},
			{"SetTargetPos", 4238, 5252},
		},
	},
	[3] = {nTime = 0, nNum = 1,
		tbPrelock = {2},
		tbStartEvent = 
		{
			{"TrapUnlock", "TrapLock1", 3},

			--天星道长
			{"AddNpc", 1, 1, 4, "BOSS", "RandomFuben4_4_BOSS", false, 0, 0, 0, 0},	
			{"SetNpcProtected", "BOSS", 1},
			{"SetAiActive", "BOSS", 0},	
		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},
			{"SetFubenProgress", 50, "擊敗天星道長"},
			{"SetNpcProtected", "BOSS", 0},
			{"SetAiActive", "BOSS", 1},	
			{"NpcBubbleTalk", "BOSS", "少年人，來向貧道展示一下你們的武功吧！", 4, 1, 1},
			{"NpcHpUnlock", "BOSS", 30, 90},	
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
			{"SetFubenProgress", 100, "擊敗天星道長"},

			--判断模式获得积分
			{"RaiseEvent", "AddMissionScore", "d_score_win"},
			
			{"OpenWindow", "LingJueFengLayerPanel", "Win"},
			{"GameWin"},
		},
	},
-------------闯关时间------------------------
	
	[5] = {nTime = "d_4_time", nNum = 0,
		tbPrelock = {2},
		tbStartEvent = 
		{
			{"SetShowTime", 5},
		},
		tbUnLockEvent = 
		{
			{"BlackMsg", "道長的武功果然高強，在下自愧不如！"},

			--判断模式获得积分
			{"RaiseEvent", "AddMissionScore", "d_score_lost"},

			{"OpenWindow", "LingJueFengLayerPanel", "Fail"},
			{"GameLost"},
		},
	},

----------------------------流程阶段---------------------------
--------------阶段1--------------------
	[30] = {nTime = 0, nNum = 1,
		tbPrelock = {3},
		tbStartEvent = 
		{		
		},
		tbUnLockEvent = 
		{	
			{"NpcBubbleTalk", "BOSS", "當真不錯，沒想到你們竟有如此實力！老夫也不能藏拙了，接招吧！", 3, 0, 1},	
			{"NpcHpUnlock", "BOSS", 40, 70},

			--引雷剑 & 放技能NPC
			{"AddNpc", 4, 1, 33, "Sword_1", "RandomFuben4_4_Sword1", false, 0, 0, 0, 0},
			{"AddNpc", 3, 1, 0, "SkillNpc_1", "RandomFuben4_4_SkillNpc1", false, 0, 0, 0, 0},	
		},
	},	
	[31] = {nTime = 1, nNum = 0,
		tbPrelock = {30},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{	
			{"BlackMsg", "[FFFE0D]引雷劍[-]準備召喚雷電，盡速將其破壞掉！！"},
		},
	},
	[32] = {nTime = 6, nNum = 0,
		tbPrelock = {31},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{	
			--循环放技能
			{"StartTimeCycle", "cycle_1", 4, 100, {"CastSkill", "SkillNpc_1", 1312, 30, -1, -1},},
		},
	},
	[33] = {nTime = 0, nNum = 1,
		tbPrelock = {30},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{	
			--关闭循环
			{"CloseCycle", "cycle_1"},	
			{"DelNpc", "SkillNpc_1"},
		},
	},

-------------阶段2------------------------
	[40] = {nTime = 0, nNum = 1,
		tbPrelock = {30},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{	
			{"NpcBubbleTalk", "BOSS", "當真不錯，沒想到你們竟有如此實力！", 3, 1, 1},	
			{"NpcHpUnlock", "BOSS", 50, 50},

			--引雷剑 & 放技能NPC
			{"AddNpc", 4, 1, 43, "Sword_2", "RandomFuben4_4_Sword2", false, 0, 0, 0, 0},
			{"AddNpc", 3, 1, 0, "SkillNpc_2", "RandomFuben4_4_SkillNpc2", false, 0, 0, 0, 0},
		},
	},	
	[41] = {nTime = 1, nNum = 0,
		tbPrelock = {40},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{	
			{"BlackMsg", "[FFFE0D]引雷劍[-]準備召喚雷電，盡速將其破壞掉！！"},
		},
	},
	[42] = {nTime = 6, nNum = 0,
		tbPrelock = {41},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{	
			--循环放技能
			{"StartTimeCycle", "cycle_2", 4, 100, {"CastSkill", "SkillNpc_2", 1312, 30, -1, -1},},	
		},
	},
	[43] = {nTime = 0, nNum = 1,
		tbPrelock = {40},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{	
			--关闭循环
			{"CloseCycle", "cycle_2"},	
			{"DelNpc", "SkillNpc_2"},
		},
	},
-------------阶段3------------------------
	[50] = {nTime = 0, nNum = 1,
		tbPrelock = {30},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{	
			{"NpcBubbleTalk", "BOSS", "長江後浪推前浪，看來老道也不能藏拙了！", 4, 1, 1},	
			{"NpcHpUnlock", "BOSS", 60, 30},

			--引雷剑 & 放技能NPC
			{"AddNpc", 4, 1, 53, "Sword_3", "RandomFuben4_4_Sword3", false, 0, 0, 0, 0},
			{"AddNpc", 3, 1, 0, "SkillNpc_3", "RandomFuben4_4_SkillNpc3", false, 0, 0, 0, 0},				
		},
	},
	[51] = {nTime = 1, nNum = 0,
		tbPrelock = {50},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{	
			{"BlackMsg", "[FFFE0D]引雷劍[-]準備召喚雷電，盡速將其破壞掉！！"},
		},
	},
	[52] = {nTime = 6, nNum = 0,
		tbPrelock = {51},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{	
			--循环放技能
			{"StartTimeCycle", "cycle_3", 4, 100, {"CastSkill", "SkillNpc_3", 1312, 30, -1, -1},},	
		},
	},
	[53] = {nTime = 0, nNum = 1,
		tbPrelock = {50},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{	
			--关闭循环
			{"CloseCycle", "cycle_3"},	
			{"DelNpc", "SkillNpc_3"},
		},
	},
-------------阶段4------------------------
	[60] = {nTime = 0, nNum = 1,
		tbPrelock = {30},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{	
			{"NpcBubbleTalk", "BOSS", "長江後浪推前浪，看來老道也不能藏拙了！", 4, 1, 1},	

			--引雷剑 & 放技能NPC
			{"AddNpc", 4, 1, 63, "Sword_4", "RandomFuben4_4_Sword4", false, 0, 0, 0, 0},
			{"AddNpc", 3, 1, 0, "SkillNpc_4", "RandomFuben4_4_SkillNpc4", false, 0, 0, 0, 0},	
		},
	},
	[61] = {nTime = 1, nNum = 0,
		tbPrelock = {60},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{	
			{"BlackMsg", "[FFFE0D]引雷劍[-]準備召喚雷電，盡速將其破壞掉！！"},
		},
	},
	[62] = {nTime = 6, nNum = 0,
		tbPrelock = {61},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{	
			--循环放技能
			{"StartTimeCycle", "cycle_4", 4, 100, {"CastSkill", "SkillNpc_4", 1312, 30, -1, -1},},	
		},
	},
	[63] = {nTime = 0, nNum = 1,
		tbPrelock = {60},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{	
			--关闭循环
			{"CloseCycle", "cycle_4"},	
			{"DelNpc", "SkillNpc_4"},
		},
	},
----------------卡片收集-----------
	[100] = {nTime = 1, nNum = 0,
		tbPrelock = {{33, 43, 53, 63}},
		tbStartEvent = 
		{
			{"CloseLock", 101},
		},
		tbUnLockEvent = 
		{	
		},
	},
	[101] = {nTime = 0, nNum = 1,
		tbPrelock = {3},
		tbStartEvent = 
		{
			{"NpcHpUnlock", "BOSS", 101, 1},	
		},
		tbUnLockEvent = 
		{
			{"RaiseEvent", "DropCard", 2613, 350000},
		},
	},

}

