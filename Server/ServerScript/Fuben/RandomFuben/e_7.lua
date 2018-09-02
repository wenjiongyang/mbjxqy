
local tbFubenSetting = Fuben.RandomFuben:GetRandomFubenSetting("e_7");

tbFubenSetting.tbMultiBeginPoint = {{1105, 1309},{1417, 1040},{749, 1051},{1043, 788}}	-- 副本出生点
tbFubenSetting.tbTempRevivePoint = {1084, 1046};
tbFubenSetting.nStartDir		 = 8;


tbFubenSetting.NPC = 
{
	[1] = {nTemplate = 1589, nLevel = -1, nSeries = 0}, --指引圈
	[2] = {nTemplate = 104,  nLevel = -1, nSeries = 0}, --动态障碍墙
	[3] = {nTemplate = 1592, nLevel = -1, nSeries = 0}, --柴嵩
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
			{"ChangeCameraSetting", 29, 35, 20},
			
			{"SetFubenProgress", -1,"等待秘境開啟"},
			{"AddNpc", 2, 2, 1, "wall", "wall_1_1",false, 25},
			{"OpenWindow", "LingJueFengLayerPanel", "Info",3, 9, "第五層 雪山之巔"},
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
			{"SetTargetPos", 2647, 2224},
		},
	},
	[3] = {nTime = 0, nNum = 1,
		tbPrelock = {2},
		tbStartEvent = 
		{
			{"ChangeFightState", 1},
			{"SetFubenProgress", 0, "探索凌絕峰"},
			{"TrapUnlock", "TrapLock1", 3},

			--柴嵩
			{"AddNpc", 3, 1, 4, "BOSS", "RandomFuben5_7_BOSS", false, 46, 0, 0, 0},	 

			{"NpcHpUnlock", "BOSS", 30, 70},
			{"SetNpcProtected", "BOSS", 1},
			{"SetAiActive", "BOSS", 0},
			{"SetHeadVisiable", "BOSS", false, 1},
		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},
			{"SetFubenProgress", 50, "擊敗柴嵩"},
			{"SetNpcProtected", "BOSS", 0},
			{"SetAiActive", "BOSS", 1},
			{"SetHeadVisiable", "BOSS", true, 0},
			{"NpcBubbleTalk", "BOSS", "沒想到會在此處與你們巧遇，閒來無事不如來切磋一番吧！", 4, 0, 1},

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

			{"BlackMsg", "觸碰地面[FFFE0D]所有光圈[-]，獲取[FFFE0D]強力技能[-]來對抗柴嵩！"},

			--BOSS回血
			{"NpcAddBuff", "BOSS", 1507, 1, 8},

			--光圈
			{"AddNpc", 1, 1, 31, "Circle_1", "RandomFuben5_7_Circle1", false, 0, 0, 0, 0},	
			{"AddNpc", 1, 1, 31, "Circle_2", "RandomFuben5_7_Circle2", false, 0, 0, 0, 0},
			{"AddNpc", 1, 1, 31, "Circle_3", "RandomFuben5_7_Circle3", false, 0, 0, 0, 0},
			{"AddNpc", 1, 1, 31, "Circle_4", "RandomFuben5_7_Circle4", false, 0, 0, 0, 0},
			{"AddNpc", 1, 1, 31, "Circle_5", "RandomFuben5_7_Circle5", false, 0, 0, 0, 0},

			{"NpcFindEnemyUnlock", "Circle_1", 31, 0},
			{"NpcFindEnemyUnlock", "Circle_2", 32, 0},
			{"NpcFindEnemyUnlock", "Circle_3", 33, 0},
			{"NpcFindEnemyUnlock", "Circle_4", 34, 0},
			{"NpcFindEnemyUnlock", "Circle_5", 35, 0},
		},
	},
	[31] = {nTime = 0, nNum = 1,
		tbPrelock = {30},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"DelNpc", "Circle_1"},
		},
	},
	[32] = {nTime = 0, nNum = 1,
		tbPrelock = {30},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"DelNpc", "Circle_2"},
		},
	},
	[33] = {nTime = 0, nNum = 1,
		tbPrelock = {30},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"DelNpc", "Circle_3"},
		},
	},
	[34] = {nTime = 0, nNum = 1,
		tbPrelock = {30},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"DelNpc", "Circle_4"},
		},
	},
	[35] = {nTime = 0, nNum = 1,
		tbPrelock = {30},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"DelNpc", "Circle_5"},
		},
	},
	[36] = {nTime = 0.1, nNum = 0,
		tbPrelock = {31, 32, 33, 34, 35},
		tbStartEvent = 
		{
			--添加强力BUFF
			{"AddBuff", 1508, 1, 20, 0, 0},
			{"AddBuff", 1690, 12, 20, 0, 0},

			--关闭提醒锁
			{"CloseLock", 37},
		},
		tbUnLockEvent = 
		{			
		},
	},
	[37] = {nTime = 6, nNum = 0,
		tbPrelock = {30},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"DelNpc", "Circle_1"},
			{"DelNpc", "Circle_2"},
			{"DelNpc", "Circle_3"},
			{"DelNpc", "Circle_4"},
			{"DelNpc", "Circle_5"},

			{"BlackMsg", "[FFFE0D]光圈已消失[-]，各位俠士請小心應對柴嵩！！"},	
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
			{"NpcBubbleTalk", "BOSS", "沒想到你們竟會如此棘手，不過單憑如此還是無法戰勝我的！！你們當心了！！", 4, 0, 1},

			{"BlackMsg", "觸碰地面[FFFE0D]所有光圈[-]，獲取[FFFE0D]強力技能[-]來對抗柴嵩！"},

			--BOSS回血
			{"NpcAddBuff", "BOSS", 1507, 1, 8},

			--光圈
			{"AddNpc", 1, 1, 31, "Circle_6", "RandomFuben5_7_Circle1", false, 0, 0, 0, 0},	
			{"AddNpc", 1, 1, 31, "Circle_7", "RandomFuben5_7_Circle2", false, 0, 0, 0, 0},
			{"AddNpc", 1, 1, 31, "Circle_8", "RandomFuben5_7_Circle3", false, 0, 0, 0, 0},
			{"AddNpc", 1, 1, 31, "Circle_9", "RandomFuben5_7_Circle4", false, 0, 0, 0, 0},
			{"AddNpc", 1, 1, 31, "Circle_10", "RandomFuben5_7_Circle5", false, 0, 0, 0, 0},

			{"NpcFindEnemyUnlock", "Circle_6", 41, 0},
			{"NpcFindEnemyUnlock", "Circle_7", 42, 0},
			{"NpcFindEnemyUnlock", "Circle_8", 43, 0},
			{"NpcFindEnemyUnlock", "Circle_9", 44, 0},
			{"NpcFindEnemyUnlock", "Circle_10", 45, 0},
		},
	},
	[41] = {nTime = 0, nNum = 1,
		tbPrelock = {40},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"DelNpc", "Circle_6"},
		},
	},
	[42] = {nTime = 0, nNum = 1,
		tbPrelock = {40},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"DelNpc", "Circle_7"},
		},
	},
	[43] = {nTime = 0, nNum = 1,
		tbPrelock = {40},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"DelNpc", "Circle_8"},
		},
	},
	[44] = {nTime = 0, nNum = 1,
		tbPrelock = {40},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"DelNpc", "Circle_9"},
		},
	},
	[45] = {nTime = 0, nNum = 1,
		tbPrelock = {40},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"DelNpc", "Circle_10"},
		},
	},
	[46] = {nTime = 0.1, nNum = 0,
		tbPrelock = {41, 42, 43, 44, 45},
		tbStartEvent = 
		{
			--添加强力BUFF
			{"AddBuff", 1508, 1, 20, 0, 0},
			{"AddBuff", 1690, 12, 20, 0, 0},

			--关闭提醒锁
			{"CloseLock", 47},
		},
		tbUnLockEvent = 
		{			
		},
	},
	[47] = {nTime = 6, nNum = 0,
		tbPrelock = {40},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"DelNpc", "Circle_6"},
			{"DelNpc", "Circle_7"},
			{"DelNpc", "Circle_8"},
			{"DelNpc", "Circle_9"},
			{"DelNpc", "Circle_10"},

			{"BlackMsg", "[FFFE0D]光圈已消失[-]，各位俠士請小心應對柴嵩！！"},	
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
			{"SetFubenProgress", 100, "擊敗柴嵩"},

			--判断模式篝火&踢出
			{"IfCase", "self.nFubenLevel == 1",
				{"AddSimpleNpc", 1611, 2946, 2501, 0},
				{"RaiseEvent", "KickOutAllPlayer", 40},
			},

			--判断模式获得积分
			{"RaiseEvent", "AddMissionScore", "e_score_win"},

			{"OpenWindow", "LingJueFengLayerPanel", "Win"},
			{"GameWin"},
		},
	},
-------------闯关时间------------------------	
	[5] = {nTime = "e_7_time", nNum = 0,
		tbPrelock = {2},
		tbStartEvent = 
		{
			{"SetShowTime", 5},
		},
		tbUnLockEvent = 
		{
			{"BlackMsg", "柴嵩武藝果然高強不宜硬拼，還是先撤退為妙！"},

			--判断模式踢出
			{"IfCase", "self.nFubenLevel == 1",
				{"RaiseEvent", "KickOutAllPlayer", 10},
			},
			--判断模式获得积分
			{"RaiseEvent", "AddMissionScore", "e_score_lost"},

			{"OpenWindow", "LingJueFengLayerPanel", "Fail"},
			{"GameLost"},
		},
	},

}
