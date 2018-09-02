
local tbFubenSetting = Fuben.RandomFuben:GetRandomFubenSetting("c_8");

tbFubenSetting.tbMultiBeginPoint = {{1328, 3574},{1320, 3080},{991, 3563},{1005, 3093}}	-- 副本出生点
tbFubenSetting.tbTempRevivePoint = {938, 3314};
tbFubenSetting.nStartDir		 = 14;


tbFubenSetting.NPC = 
{
	[1] = {nTemplate = 1573,  nLevel = -1, nSeries = -1}, --陆文龙
	[2] = {nTemplate = 1144,  nLevel = -1, nSeries = 0},  --弩车（强力技能）
	[3] = {nTemplate = 1718,  nLevel = -1, nSeries = -1}, --天机工匠
	[4] = {nTemplate = 104,   nLevel = -1, nSeries = 0},  --动态障碍墙
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
			{"AddNpc", 4, 2, 1, "wall", "wall_1_1",false, 32},
			{"OpenWindow", "LingJueFengLayerPanel", "Info",3, 9, "第三層 山腰小路"},
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
			{"DoDeath", "wall"},
			{"OpenDynamicObstacle", "ops1"},
			{"SetTargetPos", 4440, 2946},
		},
	},
	[3] = {nTime = 0, nNum = 1,
		tbPrelock = {2},
		tbStartEvent = 
		{
			{"TrapUnlock", "TrapLock1", 3},
			{"SetFubenProgress", 0, "探索凌絕峰"},

			--陆文龙
			{"AddNpc", 1, 1, 4, "BOSS", "RandomFuben3_8_BOSS", false, 0, 0, 0, 0},
			{"SetNpcProtected", "BOSS", 1},

			--弩车
			{"AddNpc", 2, 1, 0, "Nuche1", "RandomFuben3_8_Nuche1", false, 37, 0, 0, 0},
			{"AddNpc", 2, 1, 0, "Nuche2", "RandomFuben3_8_Nuche2", false, 0, 0, 0, 0},
			{"SetAiActive", "Nuche1", 0},
			{"SetAiActive", "Nuche2", 0},
		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},
			{"SetFubenProgress", 50, "擊敗陸文龍"},
			{"NpcBubbleTalk", "BOSS", "此路不通！", 3, 1, 1},	
			{"SetNpcProtected", "BOSS", 0},
			{"NpcHpUnlock", "BOSS", 30, 85},
		},
	},

--------------------------------阶段流程-------------------------------------
--------------------阶段1-----------------------------
	[30] = {nTime = 0, nNum = 1,
		tbPrelock = {3},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"NpcHpUnlock", "BOSS", 40, 40},

			{"NpcBubbleTalk", "BOSS", "可惡，你們不要太得意了！！天機工匠何在！！", 4, 0, 1},	

			--天机工匠
			{"AddNpc", 3, 1, 35, "Control1", "RandomFuben3_8_Control1", false, 0, 0, 0, 0},
			{"AddNpc", 3, 1, 37, "Control2", "RandomFuben3_8_Control2", false, 0, 0, 0, 0},

			{"ChangeNpcAi", "Control1", "Move", "Path1", 32, 0, 0, 0, 0},
			{"ChangeNpcAi", "Control2", "Move", "Path2", 33, 0, 0, 0, 0},
		},
	},
	[31] = {nTime = 2, nNum = 0,
		tbPrelock = {30},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"BlackMsg", "[FFFE0D]天機工匠[-]準備強化弩車，在抵達前將其擊殺！"},
		},
	},
	[32] = {nTime = 0, nNum = 1,
		tbPrelock = {30},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"SetAiActive", "Control1", 0},

			--播放攻击动作
			{"DoCommonAct", "Control1", 16, 0, 1, 0},
		},
	},
	[33] = {nTime = 0, nNum = 1,
		tbPrelock = {30},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"SetAiActive", "Control2", 0},

			--播放攻击动作
			{"DoCommonAct", "Control2", 16, 0, 1, 0},
		},
	},
	[34] = {nTime = 2, nNum = 0,
		tbPrelock = {32},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"NpcBubbleTalk", "Control1", "哈哈，強化這弩車對我等來說簡直是易如反掌！！", 3, 0, 1},

			--放新NPC释放强力技能
			{"SetAiActive", "Nuche1", 1},

			{"SetAiActive", "Control1", 1},
		},
	},
	[35] = {nTime = 0, nNum = 1,
		tbPrelock = {34},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			--删除NPC停止强力技能
			{"SetAiActive", "Nuche1", 0},
		},
	},	
	[36] = {nTime = 2, nNum = 0,
		tbPrelock = {33},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"NpcBubbleTalk", "Control2", "哈哈，強化這弩車對我等來說簡直是易如反掌！！", 3, 0, 1},

			--放新NPC释放强力技能
			{"SetAiActive", "Nuche2", 1},

			{"SetAiActive", "Control2", 1},
		},
	},	
	[37] = {nTime = 0, nNum = 1,
		tbPrelock = {36},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{	
			--删除NPC停止强力技能
			{"SetAiActive", "Nuche2", 0},	
		},
	},

---------------------阶段2----------------------------------
	[40] = {nTime = 0, nNum = 1,
		tbPrelock = {30},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"NpcBubbleTalk", "BOSS", "可惡，你們不要太得意了！！天機工匠何在！！", 4, 0, 1},	

			--天机工匠
			{"AddNpc", 3, 1, 45, "Control3", "RandomFuben3_8_Control1", false, 0, 0, 0, 0},
			{"AddNpc", 3, 1, 47, "Control4", "RandomFuben3_8_Control2", false, 0, 0, 0, 0},

			{"ChangeNpcAi", "Control3", "Move", "Path1", 42, 0, 0, 0, 0},
			{"ChangeNpcAi", "Control4", "Move", "Path2", 43, 0, 0, 0, 0},
		},
	},
	[41] = {nTime = 2, nNum = 0,
		tbPrelock = {40},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"BlackMsg", "[FFFE0D]天機工匠[-]準備強化弩車，在抵達前將其擊殺！"},
		},
	},
	[42] = {nTime = 0, nNum = 1,
		tbPrelock = {40},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"SetAiActive", "Control3", 0},

			--播放攻击动作
			{"DoCommonAct", "Control3", 16, 0, 1, 0},
		},
	},
	[43] = {nTime = 0, nNum = 1,
		tbPrelock = {40},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"SetAiActive", "Control4", 0},

			--播放攻击动作
			{"DoCommonAct", "Control4", 16, 0, 1, 0},
		},
	},
	[44] = {nTime = 2, nNum = 0,
		tbPrelock = {42},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"NpcBubbleTalk", "Control3", "哈哈，強化這弩車對我等來說簡直是易如反掌！！", 3, 0, 1},

			--放新NPC释放强力技能
			{"SetAiActive", "Nuche1", 1},

			{"SetAiActive", "Control3", 1},
		},
	},
	[45] = {nTime = 0, nNum = 1,
		tbPrelock = {44},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			--停止强力技能
			{"SetAiActive", "Nuche1", 0},
		},
	},	
	[46] = {nTime = 2, nNum = 0,
		tbPrelock = {43},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"NpcBubbleTalk", "Control4", "哈哈，強化這弩車對我等來說簡直是易如反掌！！", 3, 0, 1},

			--放新NPC释放强力技能
			{"SetAiActive", "Nuche2", 1},

			{"SetAiActive", "Control4", 1},
		},
	},	
	[47] = {nTime = 0, nNum = 1,
		tbPrelock = {46},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			--停止强力技能
			{"SetAiActive", "Nuche2", 0},
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
			{"SetFubenProgress", 100, "擊敗陸文龍"},

			--判断模式获得积分
			{"RaiseEvent", "AddMissionScore", "c_score_win"},
			
			{"OpenWindow", "LingJueFengLayerPanel", "Win"},
			{"GameWin"},
		},
	},
-------------闯关时间和积分------------------------
	[5] = {nTime = "c_8_time", nNum = 0,
		tbPrelock = {2},
		tbStartEvent = 
		{
			{"SetShowTime", 5},
		},
		tbUnLockEvent = 
		{
			--判断模式获得积分
			{"RaiseEvent", "AddMissionScore", "c_score_lost"},
			
			{"OpenWindow", "LingJueFengLayerPanel", "Fail"},
			{"GameLost"},
		},
	},
}

