
local tbFubenSetting = Fuben.RandomFuben:GetRandomFubenSetting("c_2");

tbFubenSetting.tbMultiBeginPoint = {{2045, 1614},{1758, 1675},{1873, 2052},{2193, 1959}}	-- 副本出生点
tbFubenSetting.tbTempRevivePoint = {1995, 1826};
tbFubenSetting.nStartDir		 = 5;

--NPC模版ID，NPC等级，NPC五行；
tbFubenSetting.NPC = 
{
	[1] = {nTemplate = 1325, nLevel = -1, nSeries = -1},  --林海
	[2] = {nTemplate = 74,   nLevel = -1, nSeries = 0},   --上升气流
	[3] = {nTemplate = 1619, nLevel = -1, nSeries = -1},  --灵魂守卫
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
			{"OpenWindow", "LingJueFengLayerPanel", "Info",3, 9, "第三層 峰頂峭崖"},			
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
			{"ShowTaskDialog", 10002, false},
			{"SetFubenProgress", 0, "探索凌絕峰"},	
			{"OpenDynamicObstacle", "ops1"},
			{"SetTargetPos", 2253, 2735},	
			{"AddNpc", 2, 1, 1, "Qinggong", "RandomFuben3_2_qinggong", false},
			{"ChangeTrap", "Jump1", nil, {2291, 3156}},
			{"ChangeTrap", "Jump2", nil, {2320, 3590}},	
			{"ChangeTrap", "Jump3", nil, {2484, 3977}},	
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
			{"TrapUnlock", "Jump3", 101},
		},
		tbUnLockEvent = 
		{
			{"SetTargetPos", 4206, 3943},
		},
	},
	[3] = {nTime = 0, nNum = 1,
		tbPrelock = {2},
		tbStartEvent = 
		{			
			{"TrapUnlock", "TrapLock1", 3},

			--林海
			{"AddNpc", 1, 1, 4, "BOSS", "RandomFuben3_2_BOSS",false, 0 , 0, 0, 0},
			{"NpcHpUnlock", "BOSS", 30, 75},
			{"SetNpcProtected", "BOSS", 1},	
		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},
			{"SetFubenProgress", 50, "擊敗林海"},	
			{"BlackMsg", "糟糕，竟在此處遇到了林海！！"},
			{"SetNpcProtected", "BOSS", 0},	
			{"NpcBubbleTalk", "BOSS", "哈哈，還真是冤家路窄啊，你們準備受死吧！！", 3, 0, 1},
			{"NpcHpUnlock", "BOSS", 30, 75},	
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
			{"SetFubenProgress", 100, "擊敗林海"},	
			
			--判断模式获得积分
			{"RaiseEvent", "AddMissionScore", "c_score_win"},
			
			{"OpenWindow", "LingJueFengLayerPanel", "Win"},
			{"GameWin"},
		},
	},
-------------闯关时间和积分------------------------
	[5] = {nTime = "c_2_time", nNum = 0,
		tbPrelock = {2},
		tbStartEvent = 
		{
			{"SetShowTime", 5},
		},
		tbUnLockEvent = 
		{
			{"BlackMsg", "林海武藝高強不可力敵，還是趕緊撤退吧！"},

			--判断模式获得积分
			{"RaiseEvent", "AddMissionScore", "c_score_lost"},

			{"OpenWindow", "LingJueFengLayerPanel", "Fail"},
			{"GameLost"},
		},
	},

-----------------------------------怪物巡逻锁（第一阶段）--------------------------------------
	[30] = {nTime = 0, nNum = 1,
		tbPrelock = {3},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"NpcBubbleTalk", "BOSS", "可惡！！！你們不要太得意了！！出來吧，守衛們！！", 4, 0, 1},
			{"NpcHpUnlock", "BOSS", 50, 40},	

			{"BlackMsg", "注意避開林海召喚出的怪物，不要被發現了！！"},

			--无敌				
			{"NpcAddBuff", "BOSS", 2417, 1, 120},

			--定身				
			{"NpcAddBuff", "BOSS", 1058, 1, 120},
			{"DoCommonAct", "BOSS", 1, 0, 1, 0},
			{"SetAiActive", "BOSS", 0},

			--巡逻怪物			
			{"AddNpc", 3, 1, 31, "Patrol_1", "RandomFuben3_2_Patrol1", 0, 0, 0, 0, 0},
			{"AddNpc", 3, 1, 32, "Patrol_2", "RandomFuben3_2_Patrol2", 0, 0, 0, 0, 0},
			{"AddNpc", 3, 1, 33, "Patrol_3", "RandomFuben3_2_Patrol3", 0, 0, 0, 0, 0},
			{"AddNpc", 3, 1, 34, "Patrol_4", "RandomFuben3_2_Patrol4", 0, 0, 0, 0, 0},
			{"AddNpc", 3, 1, 35, "Patrol_5", "RandomFuben3_2_Patrol5", 0, 0, 0, 0, 0},
			{"AddNpc", 3, 1, 36, "Patrol_6", "RandomFuben3_2_Patrol6", 0, 0, 0, 0, 0},
			{"AddNpc", 3, 1, 37, "Patrol_7", "RandomFuben3_2_Patrol7", 0, 0, 0, 0, 0},

			{"ChangeNpcAi", "Patrol_1", "Move", "Path1", 0, 1, 1, 0, 1},
			{"ChangeNpcAi", "Patrol_2", "Move", "Path2", 0, 1, 1, 0, 1},
			{"ChangeNpcAi", "Patrol_3", "Move", "Path3", 0, 1, 1, 0, 1},
			{"ChangeNpcAi", "Patrol_4", "Move", "Path4", 0, 1, 1, 0, 1},
			{"ChangeNpcAi", "Patrol_5", "Move", "Path5", 0, 1, 1, 0, 1},
			{"ChangeNpcAi", "Patrol_6", "Move", "Path6", 0, 1, 1, 0, 1},
			{"ChangeNpcAi", "Patrol_7", "Move", "Path7", 0, 1, 1, 0, 1},

			{"NpcFindEnemyUnlock", "Patrol_1", 31, 0},
			{"NpcFindEnemyUnlock", "Patrol_2", 32, 0},
			{"NpcFindEnemyUnlock", "Patrol_3", 33, 0},
			{"NpcFindEnemyUnlock", "Patrol_4", 34, 0},
			{"NpcFindEnemyUnlock", "Patrol_5", 35, 0},
			{"NpcFindEnemyUnlock", "Patrol_6", 36, 0},
			{"NpcFindEnemyUnlock", "Patrol_7", 37, 0},

			{"NpcAddBuff", "Patrol_1", 1883, 1, 300},
			{"NpcAddBuff", "Patrol_2", 1883, 1, 300},
			{"NpcAddBuff", "Patrol_3", 1883, 1, 300},
			{"NpcAddBuff", "Patrol_4", 1883, 1, 300},
			{"NpcAddBuff", "Patrol_5", 1883, 1, 300},
			{"NpcAddBuff", "Patrol_6", 1883, 1, 300},
			{"NpcAddBuff", "Patrol_7", 1883, 1, 300},
		},
	},	
	[31] = {nTime = 0, nNum = 1,
		tbPrelock = {30},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
		},
	},
	[32] = {nTime = 0, nNum = 1,
		tbPrelock = {30},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
		},
	},
	[33] = {nTime = 0, nNum = 1,
		tbPrelock = {30},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
		},
	},
	[34] = {nTime = 0, nNum = 1,
		tbPrelock = {30},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{

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
	[37] = {nTime = 0, nNum = 1,
		tbPrelock = {30},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{

		},
	},
	[40] = {nTime = 1, nNum = 0,
		tbPrelock = {{31, 32, 33, 34, 35, 36, 37}},
		tbStartEvent = 
		{
			{"BlackMsg", "林海施展了秘術，請務必小心！！"},
			{"NpcBubbleTalk", "BOSS", "哈哈哈，乳臭未乾的傢伙們，準備迎接死亡吧！！！", 4, 0, 1},

			--加攻				
			{"NpcAddBuff", "BOSS", 2405, 1, 20},

			--关闭时间锁
			{"CloseLock", 41},

			--恢复AI
			{"SetAiActive", "BOSS", 1},

			--移除无敌 & 定身 & 视野光环
			{"NpcRemoveBuff", "BOSS", 2417},
			{"NpcRemoveBuff", "BOSS", 1058},			
			{"NpcRemoveBuff", "Patrol_1", 1883},
			{"NpcRemoveBuff", "Patrol_2", 1883},
			{"NpcRemoveBuff", "Patrol_3", 1883},
			{"NpcRemoveBuff", "Patrol_4", 1883},
			{"NpcRemoveBuff", "Patrol_5", 1883},
			{"NpcRemoveBuff", "Patrol_6", 1883},
			{"NpcRemoveBuff", "Patrol_7", 1883},

			--加视野范围
			{"SetNpcRange", "Patrol_1", 3000, 3000, 0},
			{"SetNpcRange", "Patrol_2", 3000, 3000, 0},
			{"SetNpcRange", "Patrol_3", 3000, 3000, 0},
			{"SetNpcRange", "Patrol_4", 3000, 3000, 0},
			{"SetNpcRange", "Patrol_5", 3000, 3000, 0},
			{"SetNpcRange", "Patrol_6", 3000, 3000, 0},
			{"SetNpcRange", "Patrol_7", 3000, 3000, 0},

			--增加跑速
			{"NpcAddBuff", "Patrol_1", 2452, 1, 120},
			{"NpcAddBuff", "Patrol_2", 2452, 1, 120},
			{"NpcAddBuff", "Patrol_3", 2452, 1, 120},
			{"NpcAddBuff", "Patrol_4", 2452, 1, 120},
			{"NpcAddBuff", "Patrol_5", 2452, 1, 120},
			{"NpcAddBuff", "Patrol_6", 2452, 1, 120},
			{"NpcAddBuff", "Patrol_7", 2452, 1, 120},
		},
		tbUnLockEvent = 
		{

		},
	},

--巡逻时间锁
[41] = {nTime = 10, nNum = 0,
		tbPrelock = {30},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			--移除无敌 & 定身 
			{"NpcRemoveBuff", "BOSS", 2417},
			{"NpcRemoveBuff", "BOSS", 1058},	

			--恢复AI
			{"SetAiActive", "BOSS", 1},

			--删除巡逻NPC
			{"DelNpc", "Patrol_1"},
			{"DelNpc", "Patrol_2"},
			{"DelNpc", "Patrol_3"},
			{"DelNpc", "Patrol_4"},
			{"DelNpc", "Patrol_5"},
			{"DelNpc", "Patrol_6"},
			{"DelNpc", "Patrol_7"},
		},
	},

-----------------------------------怪物巡逻锁（第二阶段）--------------------------------------
	[50] = {nTime = 0, nNum = 1,
		tbPrelock = {30},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"NpcBubbleTalk", "BOSS", "可惡！！！你們不要太得意了，讓你們嘗嘗我的厲害！！", 4, 0, 1},

			{"BlackMsg", "注意避開林海召喚出的怪物，不要被發現了！！"},

			--无敌				
			{"NpcAddBuff", "BOSS", 2417, 1, 120},

			--定身				
			{"NpcAddBuff", "BOSS", 1058, 1, 120},
			{"DoCommonAct", "BOSS", 1, 0, 1, 0},
			{"SetAiActive", "BOSS", 0},

			--巡逻怪物			
			{"AddNpc", 3, 1, 51, "Patrol_11", "RandomFuben3_2_Patrol1", 0, 0, 0, 0, 0},
			{"AddNpc", 3, 1, 52, "Patrol_12", "RandomFuben3_2_Patrol2", 0, 0, 0, 0, 0},
			{"AddNpc", 3, 1, 53, "Patrol_13", "RandomFuben3_2_Patrol3", 0, 0, 0, 0, 0},
			{"AddNpc", 3, 1, 54, "Patrol_14", "RandomFuben3_2_Patrol4", 0, 0, 0, 0, 0},
			{"AddNpc", 3, 1, 55, "Patrol_15", "RandomFuben3_2_Patrol5", 0, 0, 0, 0, 0},
			{"AddNpc", 3, 1, 56, "Patrol_16", "RandomFuben3_2_Patrol6", 0, 0, 0, 0, 0},
			{"AddNpc", 3, 1, 57, "Patrol_17", "RandomFuben3_2_Patrol7", 0, 0, 0, 0, 0},

			{"ChangeNpcAi", "Patrol_11", "Move", "Path1", 0, 1, 1, 0, 1},
			{"ChangeNpcAi", "Patrol_12", "Move", "Path2", 0, 1, 1, 0, 1},
			{"ChangeNpcAi", "Patrol_13", "Move", "Path3", 0, 1, 1, 0, 1},
			{"ChangeNpcAi", "Patrol_14", "Move", "Path4", 0, 1, 1, 0, 1},
			{"ChangeNpcAi", "Patrol_15", "Move", "Path5", 0, 1, 1, 0, 1},
			{"ChangeNpcAi", "Patrol_16", "Move", "Path6", 0, 1, 1, 0, 1},
			{"ChangeNpcAi", "Patrol_17", "Move", "Path7", 0, 1, 1, 0, 1},

			{"NpcFindEnemyUnlock", "Patrol_11", 51, 0},
			{"NpcFindEnemyUnlock", "Patrol_12", 52, 0},
			{"NpcFindEnemyUnlock", "Patrol_13", 53, 0},
			{"NpcFindEnemyUnlock", "Patrol_14", 54, 0},
			{"NpcFindEnemyUnlock", "Patrol_15", 55, 0},
			{"NpcFindEnemyUnlock", "Patrol_16", 56, 0},
			{"NpcFindEnemyUnlock", "Patrol_17", 57, 0},

			{"NpcAddBuff", "Patrol_11", 1883, 1, 300},
			{"NpcAddBuff", "Patrol_12", 1883, 1, 300},
			{"NpcAddBuff", "Patrol_13", 1883, 1, 300},
			{"NpcAddBuff", "Patrol_14", 1883, 1, 300},
			{"NpcAddBuff", "Patrol_15", 1883, 1, 300},
			{"NpcAddBuff", "Patrol_16", 1883, 1, 300},
			{"NpcAddBuff", "Patrol_17", 1883, 1, 300},
		},
	},	
	[51] = {nTime = 0, nNum = 1,
		tbPrelock = {50},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
		},
	},
	[52] = {nTime = 0, nNum = 1,
		tbPrelock = {50},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
		},
	},
	[53] = {nTime = 0, nNum = 1,
		tbPrelock = {50},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
		},
	},
	[54] = {nTime = 0, nNum = 1,
		tbPrelock = {50},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{

		},
	},	
	[55] = {nTime = 0, nNum = 1,
		tbPrelock = {50},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{

		},
	},
	[56] = {nTime = 0, nNum = 1,
		tbPrelock = {50},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{

		},
	},
	[57] = {nTime = 0, nNum = 1,
		tbPrelock = {50},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{

		},
	},
	[60] = {nTime = 1, nNum = 0,
		tbPrelock = {{51, 52, 53, 54, 55, 56, 57}},
		tbStartEvent = 
		{
			{"BlackMsg", "林海施展了秘術，請務必小心！！"},
			{"NpcBubbleTalk", "BOSS", "哈哈哈，乳臭未乾的傢伙們，準備迎接死亡吧！！！", 4, 0, 1},

			--加攻				
			{"NpcAddBuff", "BOSS", 2405, 1, 20},

			--关闭时间锁
			{"CloseLock", 61},

			--恢复AI
			{"SetAiActive", "BOSS", 1},

			--移除无敌 & 定身 & 视野光环
			{"NpcRemoveBuff", "BOSS", 2417},
			{"NpcRemoveBuff", "BOSS", 1058},			
			{"NpcRemoveBuff", "Patrol_11", 1883},
			{"NpcRemoveBuff", "Patrol_12", 1883},
			{"NpcRemoveBuff", "Patrol_13", 1883},
			{"NpcRemoveBuff", "Patrol_14", 1883},
			{"NpcRemoveBuff", "Patrol_15", 1883},
			{"NpcRemoveBuff", "Patrol_16", 1883},
			{"NpcRemoveBuff", "Patrol_17", 1883},

			--加视野范围
			{"SetNpcRange", "Patrol_11", 3000, 3000, 0},
			{"SetNpcRange", "Patrol_12", 3000, 3000, 0},
			{"SetNpcRange", "Patrol_13", 3000, 3000, 0},
			{"SetNpcRange", "Patrol_14", 3000, 3000, 0},
			{"SetNpcRange", "Patrol_15", 3000, 3000, 0},
			{"SetNpcRange", "Patrol_16", 3000, 3000, 0},
			{"SetNpcRange", "Patrol_17", 3000, 3000, 0},

			--增加跑速
			{"NpcAddBuff", "Patrol_11", 2452, 1, 120},
			{"NpcAddBuff", "Patrol_12", 2452, 1, 120},
			{"NpcAddBuff", "Patrol_13", 2452, 1, 120},
			{"NpcAddBuff", "Patrol_14", 2452, 1, 120},
			{"NpcAddBuff", "Patrol_15", 2452, 1, 120},
			{"NpcAddBuff", "Patrol_16", 2452, 1, 120},
			{"NpcAddBuff", "Patrol_17", 2452, 1, 120},
		},
		tbUnLockEvent = 
		{

		},
	},

--巡逻时间锁
[61] = {nTime = 10, nNum = 0,
		tbPrelock = {50},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			--移除无敌 & 定身 
			{"NpcRemoveBuff", "BOSS", 2417},
			{"NpcRemoveBuff", "BOSS", 1058},	

			--恢复AI
			{"SetAiActive", "BOSS", 1},

			--删除巡逻NPC
			{"DelNpc", "Patrol_11"},
			{"DelNpc", "Patrol_12"},
			{"DelNpc", "Patrol_13"},
			{"DelNpc", "Patrol_14"},
			{"DelNpc", "Patrol_15"},
			{"DelNpc", "Patrol_16"},
			{"DelNpc", "Patrol_17"},
		},
	},
}

