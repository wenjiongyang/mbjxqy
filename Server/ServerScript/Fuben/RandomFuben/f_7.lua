
local tbFubenSetting = Fuben.RandomFuben:GetRandomFubenSetting("f_7");

tbFubenSetting.tbMultiBeginPoint = {{2774, 5711},{2557, 5318},{3068, 5529},{2837, 5189}}	-- 副本出生点
tbFubenSetting.tbTempRevivePoint = {2816, 5413};
tbFubenSetting.nStartDir		 = 23;


tbFubenSetting.NPC = 
{
	[1] = {nTemplate = 1802, nLevel = -1, nSeries = -1}, --滚石
	[2] = {nTemplate = 1803, nLevel = -1, nSeries = -1}, --机关
	[3] = {nTemplate = 1804, nLevel = -1, nSeries = -1}, --封玉书
	[4] = {nTemplate = 104,  nLevel = -1, nSeries = 0},  --动态障碍墙
	[5] = {nTemplate = 1800, nLevel = -1, nSeries = -1}, --放技能NPC
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
			{"AddNpc", 4, 2, 1, "wall", "wall_1_1",false, 37},
			{"OpenWindow", "LingJueFengLayerPanel", "Info",3, 9, "第六層 隱窟密洞"},
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
			{"SetTargetPos", 4166, 4647},
			{"SetFubenProgress", 0, "探索凌絕峰"},
		},
	},
	[3] = {nTime = 0, nNum = 1,
		tbPrelock = {2},
		tbStartEvent = 
		{
			{"TrapUnlock", "TrapLock1", 3},

			--封玉书
			{"AddNpc", 3, 1, 4, "BOSS", "RandomFuben6_7_BOSS", false, 51, 0, 0, 0},	
			{"SetHeadVisiable", "BOSS", false, 1},
			{"NpcHpUnlock", "BOSS", 30, 95},
			{"SetNpcProtected", "BOSS", 1},
			{"SetAiActive", "BOSS", 0},
		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},
			{"SetFubenProgress", 50, "擊敗封玉書"},
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
			{"NpcBubbleTalk", "BOSS", "哼，你們不要太得意了，就讓你們嘗嘗我佈下機關陣法的威力吧！！！", 4, 0, 1},	
			{"NpcHpUnlock", "BOSS", 40, 75},

			--滚石
			{"AddNpc", 1, 1, 0, "Gunshi1", "RandomFuben6_7_Gunshi1", false, 0, 0, 0, 0},	
			{"AddNpc", 1, 1, 0, "Gunshi2", "RandomFuben6_7_Gunshi2", false, 0, 0, 0, 0},
			{"AddNpc", 1, 1, 0, "Gunshi3", "RandomFuben6_7_Gunshi3", false, 0, 0, 0, 0},
			{"AddNpc", 1, 1, 0, "Gunshi4", "RandomFuben6_7_Gunshi4", false, 0, 0, 0, 0},
			{"AddNpc", 1, 1, 0, "Gunshi5", "RandomFuben6_7_Gunshi5", false, 0, 0, 0, 0},
			{"AddNpc", 1, 1, 0, "Gunshi6", "RandomFuben6_7_Gunshi6", false, 0, 0, 0, 0},
			{"AddNpc", 1, 1, 0, "Gunshi7", "RandomFuben6_7_Gunshi7", false, 0, 0, 0, 0},
			{"AddNpc", 1, 1, 0, "Gunshi8", "RandomFuben6_7_Gunshi8", false, 0, 0, 0, 0},
			{"AddNpc", 1, 1, 0, "Gunshi9", "RandomFuben6_7_Gunshi9", false, 0, 0, 0, 0},

			--滚石移动
			{"ChangeNpcAi", "Gunshi1", "Move", "Path1", 0, 0, 0, 0, 1},
			{"ChangeNpcAi", "Gunshi2", "Move", "Path2", 0, 0, 0, 0, 1},
			{"ChangeNpcAi", "Gunshi3", "Move", "Path3", 0, 0, 0, 0, 1},
			{"ChangeNpcAi", "Gunshi4", "Move", "Path4", 0, 0, 0, 0, 1},
			{"ChangeNpcAi", "Gunshi5", "Move", "Path5", 0, 0, 0, 0, 1},
			{"ChangeNpcAi", "Gunshi6", "Move", "Path6", 0, 0, 0, 0, 1},
			{"ChangeNpcAi", "Gunshi7", "Move", "Path7", 0, 0, 0, 0, 1},
			{"ChangeNpcAi", "Gunshi8", "Move", "Path8", 0, 0, 0, 0, 1},
			{"ChangeNpcAi", "Gunshi9", "Move", "Path9", 0, 0, 0, 0, 1},
		},
	},
	[31] = {nTime = 2, nNum = 0,
		tbPrelock = {30},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"BlackMsg", "封玉書開啟[FFFE0D]滾石機關[-]，各位俠士請小心應對！"},
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
			--删除上个阶段的滚石
			{"DelNpc", "Gunshi1"},
			{"DelNpc", "Gunshi2"},
			{"DelNpc", "Gunshi3"},
			{"DelNpc", "Gunshi4"},
			{"DelNpc", "Gunshi5"},
			{"DelNpc", "Gunshi6"},
			{"DelNpc", "Gunshi7"},
			{"DelNpc", "Gunshi8"},
			{"DelNpc", "Gunshi9"},	

			{"NpcBubbleTalk", "BOSS", "哼，你們不要太得意了，就讓你們嘗嘗我佈下機關陣法的威力吧！！！", 4, 0, 1},
			{"NpcHpUnlock", "BOSS", 50, 50},	

			--旋转机关
			{"AddNpc", 2, 1, 0, "Rotation1", "RandomFuben6_7_Rotation1", false, 0, 0, 0, 0},
			{"AddNpc", 2, 1, 0, "Rotation2", "RandomFuben6_7_Rotation2", false, 0, 0, 0, 0},
			{"AddNpc", 2, 1, 0, "Rotation3", "RandomFuben6_7_Rotation3", false, 0, 0, 0, 0},
			{"AddNpc", 2, 1, 0, "Rotation4", "RandomFuben6_7_Rotation4", false, 0, 0, 0, 0},
			{"AddNpc", 2, 1, 0, "Rotation5", "RandomFuben6_7_Rotation5", false, 0, 0, 0, 0},
			{"AddNpc", 2, 1, 0, "Rotation6", "RandomFuben6_7_Rotation6", false, 0, 0, 0, 0},	
		},
	},
	[41] = {nTime = 0.5, nNum = 0,
		tbPrelock = {40},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			--释放旋转技能
			{"CastSkill", "Rotation1", 2449, 10, -1, -1}, 
			{"CastSkill", "Rotation2", 2449, 10, -1, -1}, 
			{"CastSkill", "Rotation3", 2449, 10, -1, -1}, 
			{"CastSkill", "Rotation4", 2449, 10, -1, -1}, 
			{"CastSkill", "Rotation5", 2449, 10, -1, -1}, 
			{"CastSkill", "Rotation6", 2449, 10, -1, -1}, 

			{"StartTimeCycle", "cycle_1", 5.6, 100, 
				{"CastSkill", "Rotation1", 2449, 10, -1, -1}, 
				{"CastSkill", "Rotation2", 2449, 10, -1, -1}, 
				{"CastSkill", "Rotation3", 2449, 10, -1, -1}, 
				{"CastSkill", "Rotation4", 2449, 10, -1, -1}, 
				{"CastSkill", "Rotation5", 2449, 10, -1, -1}, 
				{"CastSkill", "Rotation6", 2449, 10, -1, -1}, 
			},
		},
	},
	[42] = {nTime = 2, nNum = 0,
		tbPrelock = {40},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"BlackMsg", "封玉書開啟[FFFE0D]旋轉機關[-]，各位俠士請小心應對！"},
		},
	},
----------------------阶段3---------------------------	
	[50] = {nTime = 0, nNum = 1,
		tbPrelock = {40},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"NpcBubbleTalk", "BOSS", "哼，你們不要太得意了，就讓你們嘗嘗我佈下機關陣法的威力吧！！！", 4, 0, 1},
			{"NpcHpUnlock", "BOSS", 60, 30},	

			--滚石
			{"AddNpc", 1, 1, 0, "Gunshi1", "RandomFuben6_7_Gunshi1", false, 0, 0, 0, 0},	
			{"AddNpc", 1, 1, 0, "Gunshi2", "RandomFuben6_7_Gunshi2", false, 0, 0, 0, 0},
			{"AddNpc", 1, 1, 0, "Gunshi3", "RandomFuben6_7_Gunshi3", false, 0, 0, 0, 0},
			{"AddNpc", 1, 1, 0, "Gunshi4", "RandomFuben6_7_Gunshi4", false, 0, 0, 0, 0},
			{"AddNpc", 1, 1, 0, "Gunshi5", "RandomFuben6_7_Gunshi5", false, 0, 0, 0, 0},
			{"AddNpc", 1, 1, 0, "Gunshi6", "RandomFuben6_7_Gunshi6", false, 0, 0, 0, 0},
			{"AddNpc", 1, 1, 0, "Gunshi7", "RandomFuben6_7_Gunshi7", false, 0, 0, 0, 0},
			{"AddNpc", 1, 1, 0, "Gunshi8", "RandomFuben6_7_Gunshi8", false, 0, 0, 0, 0},
			{"AddNpc", 1, 1, 0, "Gunshi9", "RandomFuben6_7_Gunshi9", false, 0, 0, 0, 0},

			--滚石移动
			{"ChangeNpcAi", "Gunshi1", "Move", "Path1", 0, 0, 0, 0, 1},
			{"ChangeNpcAi", "Gunshi2", "Move", "Path2", 0, 0, 0, 0, 1},
			{"ChangeNpcAi", "Gunshi3", "Move", "Path3", 0, 0, 0, 0, 1},
			{"ChangeNpcAi", "Gunshi4", "Move", "Path4", 0, 0, 0, 0, 1},
			{"ChangeNpcAi", "Gunshi5", "Move", "Path5", 0, 0, 0, 0, 1},
			{"ChangeNpcAi", "Gunshi6", "Move", "Path6", 0, 0, 0, 0, 1},
			{"ChangeNpcAi", "Gunshi7", "Move", "Path7", 0, 0, 0, 0, 1},
			{"ChangeNpcAi", "Gunshi8", "Move", "Path8", 0, 0, 0, 0, 1},
			{"ChangeNpcAi", "Gunshi9", "Move", "Path9", 0, 0, 0, 0, 1},
		},
	},
	[51] = {nTime = 2, nNum = 0,
		tbPrelock = {50},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"BlackMsg", "封玉書開啟[FFFE0D]滾石機關[-]，各位俠士請小心應對！"},
		},
	},
----------------------阶段4---------------------------	
	[60] = {nTime = 0, nNum = 1,
		tbPrelock = {50},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			--删除场上所有机关NPC
			{"DelNpc", "Gunshi1"},
			{"DelNpc", "Gunshi2"},
			{"DelNpc", "Gunshi3"},
			{"DelNpc", "Gunshi4"},
			{"DelNpc", "Gunshi5"},
			{"DelNpc", "Gunshi6"},
			{"DelNpc", "Gunshi7"},
			{"DelNpc", "Gunshi8"},
			{"DelNpc", "Gunshi9"},	
			{"DelNpc", "Rotation1"},
			{"DelNpc", "Rotation2"},
			{"DelNpc", "Rotation3"},
			{"DelNpc", "Rotation4"},
			{"DelNpc", "Rotation5"},
			{"DelNpc", "Rotation6"},

			--BOSS狂暴
			{"NpcAddBuff", "BOSS", 2405, 1, 30},
			{"NpcAddBuff", "BOSS", 1690, 7, 30},	
			{"NpcBubbleTalk", "BOSS", "可惡的傢伙們，你們成功將我激怒了，準備好迎接我的怒火吧！！！", 4, 1, 1},
		},
	},
	[61] = {nTime = 2, nNum = 0,
		tbPrelock = {60},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"BlackMsg", "封玉書施展秘術，各位俠士請小心應對！"},
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
			{"SetFubenProgress", 100, "擊敗封玉書"},

			--判断模式篝火&踢出
			{"IfCase", "self.nFubenLevel == 2",
				{"AddSimpleNpc", 1611, 4590, 3979, 0},
				{"RaiseEvent", "KickOutAllPlayer", 40},
			},
			--判断模式获得积分
			{"RaiseEvent", "AddMissionScore", "f_score_win"},

			{"OpenWindow", "LingJueFengLayerPanel", "Win"},
			{"GameWin"},
		},
	},
	-------------闯关时间------------------------
	[5] = {nTime = "f_7_time", nNum = 0,    --总计时
		tbPrelock = {2},
		tbStartEvent = 
		{
			{"SetShowTime", 5},
		},
		tbUnLockEvent = 
		{
			{"SetFubenProgress", -1, "闖關失敗"},
			{"BlackMsg", "封玉書武藝高強，還是先撤退為妙！"},

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

