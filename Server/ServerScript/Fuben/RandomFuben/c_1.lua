
local tbFubenSetting = Fuben.RandomFuben:GetRandomFubenSetting("c_1");

tbFubenSetting.tbMultiBeginPoint = {{3486, 4443},{3487, 4884},{3250, 4948},{3247, 4411}}	-- 副本出生点
tbFubenSetting.tbTempRevivePoint = {3548, 4810};
tbFubenSetting.nStartDir		 = 47;


tbFubenSetting.NPC = 
{
	[1] = {nTemplate = 1566, nLevel = -1, nSeries = -1}, --五色教弟子
	[2] = {nTemplate = 1567, nLevel = -1, nSeries = -1}, --杀手
	[3] = {nTemplate = 1571, nLevel = -1, nSeries = -1}, --张风
	[4] = {nTemplate = 104,  nLevel = -1, nSeries = 0},  --动态障碍墙
	[5] = {nTemplate = 1664, nLevel = -1, nSeries = 0},  --滚石烈焰
	[6] = {nTemplate = 1665, nLevel = -1, nSeries = -1}, --滚石控制者
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
			{"AddNpc", 4, 1, 1, "wall", "wall_1_1",false, 33},
			{"OpenWindow", "LingJueFengLayerPanel", "Info",3, 9, "第三層 熔岩密洞"},
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
		},
	},
	[3] = {nTime = 0, nNum = 1,
		tbPrelock = {2},
		tbStartEvent = 
		{
			{"ChangeFightState", 1},
			{"SetFubenProgress", 0, "探索凌絕峰"},	
			{"TrapUnlock", "TrapLock1", 3},
			{"SetTargetPos", 1423, 4864},
		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},
			{"SetFubenProgress", 20, "擊退敵人"},	

			--五色教弟子 &　杀手
			{"AddNpc", 1, 4, 4, "guaiwu", "RandomFuben3_1_1", false, 0, 0, 0, 0},
			{"AddNpc", 2, 4, 4, "guaiwu", "RandomFuben3_1_2", false, 0, 3, 9005, 0.5},
			{"NpcBubbleTalk", "guaiwu", "你們是什麼人？這洞窟是我教禁地，閒雜人等趕緊滾出去！", 5, 2, 1},	
		},
	},
	[4] = {nTime = 0, nNum = 8,
		tbPrelock = {3},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"OpenDynamicObstacle", "ops2"},	
			{"SetFubenProgress", 40, "擊退敵人"},
			{"SetTargetPos", 1325, 3037},
		},
	},
	[5] = {nTime = 0, nNum = 1,
		tbPrelock = {4},
		tbStartEvent = 
		{
			{"TrapUnlock", "TrapLock2", 5},
		},
		tbUnLockEvent = 
		{
			{"SetFubenProgress", 50, "擊退敵人"},
			{"ClearTargetPos"},
			{"AddNpc", 1, 5, 6, "guaiwu1", "RandomFuben3_1_3", false, 0, 0.5, 9005, 0.5},
			{"AddNpc", 2, 4, 6, "guaiwu", "RandomFuben3_1_4", false, 0, 3, 9005, 0.5},
			{"NpcBubbleTalk", "guaiwu1", "不好，有人來搗亂了！！兄弟們抄傢伙上啊！", 4, 1, 1},	
		},
	},
	[6] = {nTime = 0, nNum = 9,
		tbPrelock = {5},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"OpenDynamicObstacle", "ops3"},										--解锁动态障碍
			{"SetFubenProgress", 60, "探索凌絕峰"},
			{"SetTargetPos", 3955, 1433},

			--张风
			{"AddNpc", 3, 1, 8, "BOSS", "RandomFuben3_1_BOSS", false, 53, 0, 0, 0},	
			{"NpcHpUnlock", "BOSS", 30, 95},
			{"SetNpcProtected", "BOSS", 1},	
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
			{"SetFubenProgress", 80, "擊敗張風"},
			{"SetNpcProtected", "BOSS", 0},	
		},
	},

------------------------------------滚石阶段--------------------------------------------
	[30] = {nTime = 0, nNum = 1,
		tbPrelock = {7},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			--滚石 & 滚石控制者		
			{"AddNpc", 6, 1, 32, "Control_1", "RandomFuben3_Control_1", false, 0, 1, 9011, 1},	
			{"AddNpc", 5, 1, 0, "Gunshi1", "RandomFuben3_Gunshi_1", false, 0, 0, 0, 0},
			{"AddNpc", 5, 1, 0, "Gunshi2", "RandomFuben3_Gunshi_2", false, 0, 0, 0, 0},
			{"AddNpc", 5, 1, 0, "Gunshi3", "RandomFuben3_Gunshi_3", false, 0, 0, 0, 0},
			{"AddNpc", 5, 1, 0, "Gunshi4", "RandomFuben3_Gunshi_4", false, 0, 0, 0, 0},	

			{"ChangeNpcAi", "Gunshi1", "Move", "Path1", 0, 0, 0, 0, 1},
			{"ChangeNpcAi", "Gunshi2", "Move", "Path2", 0, 0, 0, 0, 1},
			{"ChangeNpcAi", "Gunshi3", "Move", "Path3", 0, 0, 0, 0, 1},
			{"ChangeNpcAi", "Gunshi4", "Move", "Path4", 0, 0, 0, 0, 1},

			{"NpcHpUnlock", "BOSS", 33, 70},
		},
	},
	[31] = {nTime = 2, nNum = 0,
		tbPrelock = {30},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"BlackMsg", "[FFFE0D]滾石控制者[-]出現，擊敗控制者可以關閉滾石！"},
		},
	},
	[32] = {nTime = 0, nNum = 1,
		tbPrelock = {30},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"DelNpc", "Gunshi1"},
			{"DelNpc", "Gunshi2"},
			{"DelNpc", "Gunshi3"},
			{"DelNpc", "Gunshi4"},
		},
	},
	[33] = {nTime = 0, nNum = 1,
		tbPrelock = {30},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			--删除上一次的滚石NPC
			{"DelNpc", "Control_1"},
			{"DelNpc", "Gunshi1"},
			{"DelNpc", "Gunshi2"},
			{"DelNpc", "Gunshi3"},
			{"DelNpc", "Gunshi4"},

			--滚石 & 滚石控制者		
			{"AddNpc", 6, 1, 35, "Control_2", "RandomFuben3_Control_2", false, 0, 1, 9011, 1},	
			{"AddNpc", 5, 1, 0, "Gunshi5", "RandomFuben3_Gunshi_5", false, 0, 0, 0, 0},
			{"AddNpc", 5, 1, 0, "Gunshi6", "RandomFuben3_Gunshi_6", false, 0, 0, 0, 0},
			{"AddNpc", 5, 1, 0, "Gunshi7", "RandomFuben3_Gunshi_7", false, 0, 0, 0, 0},
			{"AddNpc", 5, 1, 0, "Gunshi8", "RandomFuben3_Gunshi_8", false, 0, 0, 0, 0},	


			{"ChangeNpcAi", "Gunshi5", "Move", "Path5", 0, 0, 0, 0, 1},
			{"ChangeNpcAi", "Gunshi6", "Move", "Path6", 0, 0, 0, 0, 1},
			{"ChangeNpcAi", "Gunshi7", "Move", "Path7", 0, 0, 0, 0, 1},
			{"ChangeNpcAi", "Gunshi8", "Move", "Path8", 0, 0, 0, 0, 1},

			{"NpcHpUnlock", "BOSS", 36, 30},
		},
	},
	[34] = {nTime = 2, nNum = 0,
		tbPrelock = {33},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"BlackMsg", "[FFFE0D]滾石控制者[-]出現，擊敗控制者可以關閉滾石！"},
		},
	},
	[35] = {nTime = 0, nNum = 1,
		tbPrelock = {33},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"DelNpc", "Gunshi5"},
			{"DelNpc", "Gunshi6"},
			{"DelNpc", "Gunshi7"},
			{"DelNpc", "Gunshi8"},
		},
	},
	[36] = {nTime = 0, nNum = 1,
		tbPrelock = {33},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			--删除上一次的滚石NPC
			{"DelNpc", "Control_2"},
			{"DelNpc", "Gunshi5"},
			{"DelNpc", "Gunshi6"},
			{"DelNpc", "Gunshi7"},
			{"DelNpc", "Gunshi8"},

			--滚石 & 滚石控制者		
			{"AddNpc", 6, 2, 38, "Control_3", "RandomFuben3_Control_2", false, 0, 1, 9011, 1},	
			{"AddNpc", 5, 1, 0, "Gunshi9", "RandomFuben3_Gunshi_1", false, 0, 0, 0, 0},
			{"AddNpc", 5, 1, 0, "Gunshi10", "RandomFuben3_Gunshi_2", false, 0, 0, 0, 0},
			{"AddNpc", 5, 1, 0, "Gunshi11", "RandomFuben3_Gunshi_3", false, 0, 0, 0, 0},
			{"AddNpc", 5, 1, 0, "Gunshi12", "RandomFuben3_Gunshi_4", false, 0, 0, 0, 0},	
			{"AddNpc", 5, 1, 0, "Gunshi13", "RandomFuben3_Gunshi_5", false, 0, 0, 0, 0},
			{"AddNpc", 5, 1, 0, "Gunshi14", "RandomFuben3_Gunshi_6", false, 0, 0, 0, 0},
			{"AddNpc", 5, 1, 0, "Gunshi15", "RandomFuben3_Gunshi_7", false, 0, 0, 0, 0},
			{"AddNpc", 5, 1, 0, "Gunshi16", "RandomFuben3_Gunshi_8", false, 0, 0, 0, 0},	

			{"ChangeNpcAi", "Gunshi9", "Move", "Path1", 0, 0, 0, 0, 1},
			{"ChangeNpcAi", "Gunshi10", "Move", "Path2", 0, 0, 0, 0, 1},
			{"ChangeNpcAi", "Gunshi11", "Move", "Path3", 0, 0, 0, 0, 1},
			{"ChangeNpcAi", "Gunshi12", "Move", "Path4", 0, 0, 0, 0, 1},
			{"ChangeNpcAi", "Gunshi13", "Move", "Path5", 0, 0, 0, 0, 1},
			{"ChangeNpcAi", "Gunshi14", "Move", "Path6", 0, 0, 0, 0, 1},
			{"ChangeNpcAi", "Gunshi15", "Move", "Path7", 0, 0, 0, 0, 1},
			{"ChangeNpcAi", "Gunshi16", "Move", "Path8", 0, 0, 0, 0, 1},
		},
	},
	[37] = {nTime = 2, nNum = 0,
		tbPrelock = {36},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"BlackMsg", "滾石控制者出現，擊敗控制者可以關閉滾石！"},
		},
	},
	[38] = {nTime = 0, nNum = 2,
		tbPrelock = {36},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"DelNpc", "Gunshi9"},
			{"DelNpc", "Gunshi10"},
			{"DelNpc", "Gunshi11"},
			{"DelNpc", "Gunshi12"},
			{"DelNpc", "Gunshi13"},
			{"DelNpc", "Gunshi14"},
			{"DelNpc", "Gunshi15"},
			{"DelNpc", "Gunshi16"},
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
			{"SetFubenProgress", 100, "擊敗張風"},

			--判断模式获得积分
			{"RaiseEvent", "AddMissionScore", "c_score_win"},

			{"OpenWindow", "LingJueFengLayerPanel", "Win"},
			{"GameWin"},
		},
	},
-------------闯关时间和积分------------------------
	[9] = {nTime = "c_1_time", nNum = 0,
		tbPrelock = {2},
		tbStartEvent = 
		{
			{"SetShowTime", 9},
		},
		tbUnLockEvent = 
		{
			--判断模式获得积分
			{"RaiseEvent", "AddMissionScore", "c_score_lost"},

			{"BlackMsg", "張風武藝高強不可力敵，還是趕緊撤退吧！"},
			{"OpenWindow", "LingJueFengLayerPanel", "Fail"},
			{"GameLost"},
		},
	},
}

