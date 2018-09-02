
local tbFubenSetting = Fuben.RandomFuben:GetRandomFubenSetting("f_8");

tbFubenSetting.tbMultiBeginPoint = {{5725, 978},{5711, 1230},{5937, 1228},{5941, 978}}	-- 副本出生点
tbFubenSetting.tbTempRevivePoint = {5818, 1093};
tbFubenSetting.nStartDir		 = 52;


tbFubenSetting.NPC = 
{
	[1] = {nTemplate = 1805, nLevel = -1, nSeries = -1}, --喷火龙柱
	[2] = {nTemplate = 1806, nLevel = -1, nSeries = -1}, --拉人NPC
	[3] = {nTemplate = 1807, nLevel = -1, nSeries = -1}, --放技能NPC
	[4] = {nTemplate = 1808, nLevel = -1, nSeries = -1}, --曲霞
	[5] = {nTemplate = 104,  nLevel = -1, nSeries = 0},  --动态障碍墙
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
			{"AddNpc", 5, 2, 1, "wall", "wall_1_1",false, 32},
			{"OpenWindow", "LingJueFengLayerPanel", "Info",3, 9, "第六層 熔岩密洞"},
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
			{"SetTargetPos", 4897, 1379},
			{"SetFubenProgress", 0, "探索凌絕峰"},
		},
	},
	[3] = {nTime = 0, nNum = 1,
		tbPrelock = {2},
		tbStartEvent = 
		{
			{"TrapUnlock", "TrapLock1", 3},

			--曲霞
			{"AddNpc", 4, 1, 4, "BOSS", "RandomFuben6_8_BOSS", false, 40, 0, 0, 0},	
			{"SetHeadVisiable", "BOSS", false, 1},
			{"NpcHpUnlock", "BOSS", 30, 70},
			{"SetNpcProtected", "BOSS", 1},
			{"SetAiActive", "BOSS", 0},
		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},
			{"SetFubenProgress", 50, "擊敗曲霞"},
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
			{"NpcBubbleTalk", "BOSS", "沒想到你們倒還有些棘手，那我也不能大意了！！", 4, 0, 1},
			{"NpcHpUnlock", "BOSS", 40, 40},

			--喷火怪
			{"AddNpc", 1, 1, 0, "Fire_1", "RandomFuben6_8_Fire1", false, 22, 0, 0, 0},	
			{"AddNpc", 1, 1, 0, "Fire_2", "RandomFuben6_8_Fire2", false, 40, 0, 0, 0},	
			{"AddNpc", 1, 1, 0, "Fire_3", "RandomFuben6_8_Fire3", false, 8, 0, 0, 0},	
			{"AddNpc", 1, 1, 0, "Fire_4", "RandomFuben6_8_Fire4", false, 52, 0, 0, 0},	

			--拉人怪
			{"AddNpc", 2, 1, 0, "Pull_1", "RandomFuben6_8_Pull1", false, 30, 0, 0, 0},	
			{"AddNpc", 2, 1, 0, "Pull_2", "RandomFuben6_8_Pull2", false, 0, 0, 0, 0},	


			--放技能NPC
			{"AddNpc", 3, 1, 0, "SkillNpc_1", "RandomFuben6_8_Fire1", false, 22, 0, 0, 0},	
			{"AddNpc", 3, 1, 0, "SkillNpc_2", "RandomFuben6_8_Fire2", false, 40, 0, 0, 0},
			{"AddNpc", 3, 1, 0, "SkillNpc_3", "RandomFuben6_8_Fire3", false, 8, 0, 0, 0},	
			{"AddNpc", 3, 1, 0, "SkillNpc_4", "RandomFuben6_8_Fire4", false, 52, 0, 0, 0},

			{"NpcAddBuff", "Pull_1", 1058, 1, 180},	
			{"NpcAddBuff", "Pull_2", 1058, 1, 180},	

			--喷火
			{"CastSkill", "SkillNpc_1", 2387, 30, 4438, 1880}, 
			{"CastSkill", "SkillNpc_2", 2387, 30, 4438, 1880}, 
			{"CastSkill", "SkillNpc_3", 2387, 30, 4414, 854}, 
			{"CastSkill", "SkillNpc_4", 2387, 30, 4414, 854}, 

			{"StartTimeCycle", "cycle_1", 3, 100, 
				{"CastSkill", "SkillNpc_1", 2387, 30, 4438, 1880}, 
				{"CastSkill", "SkillNpc_2", 2387, 30, 4438, 1880}, 
				{"CastSkill", "SkillNpc_3", 2387, 30, 4414, 854}, 
				{"CastSkill", "SkillNpc_4", 2387, 30, 4414, 854}, 
			},
			
			{"SetAiActive", "Pull_1", 0},
			{"SetAiActive", "Pull_2", 0},
		},
	},
	[32] = {nTime = 2, nNum = 0,
		tbPrelock = {30},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"BlackMsg", "注意躲避黑衣刺客的[FFFE0D]奪魂鏈[-]，避免被其拉中！！"},
			{"SetAiActive", "Pull_1", 1},
			{"SetAiActive", "Pull_2", 1},
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
			{"SetFubenProgress", 100, "擊敗曲霞"},

			--判断模式篝火&踢出
			{"IfCase", "self.nFubenLevel == 2",
				{"AddSimpleNpc", 1611, 4425, 1370, 0},
				{"RaiseEvent", "KickOutAllPlayer", 40},
			},
			--判断模式获得积分
			{"RaiseEvent", "AddMissionScore", "f_score_win"},

			{"OpenWindow", "LingJueFengLayerPanel", "Win"},
			{"GameWin"},
		},
	},
	-------------闯关时间------------------------
	[5] = {nTime = "f_8_time", nNum = 0,    --总计时
		tbPrelock = {2},
		tbStartEvent = 
		{
			{"SetShowTime", 5},
		},
		tbUnLockEvent = 
		{
			--关闭循环
			{"CloseCycle", "cycle_1"},
			{"CloseCycle", "cycle_2"},

			{"SetFubenProgress", -1, "闖關失敗"},
			{"BlackMsg", "曲霞武藝高強，還是先撤退為妙！"},

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
}

