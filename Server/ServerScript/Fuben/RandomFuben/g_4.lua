
local tbFubenSetting = Fuben.RandomFuben:GetRandomFubenSetting("g_4");

tbFubenSetting.tbMultiBeginPoint = {{3951, 7199},{4106, 7141},{3777, 7061},{3994, 7040}}  
tbFubenSetting.tbTempRevivePoint = {3994, 7040};
tbFubenSetting.nStartDir		 = 32;


tbFubenSetting.NPC = 
{
	[1] = {nTemplate = 2034, nLevel = -1, nSeries = -1}, --boss端木睿
	[2] = {nTemplate = 2035, nLevel = -1, nSeries = 0}, --巡逻怪物

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
			{"ChangeCameraSetting", 30, 35, 20},

			{"OpenWindow", "LingJueFengLayerPanel", "Info",3, 9, "第七層 陰風岩窟"},
		},
	},
	[2] = {nTime = 10, nNum = 0,
		tbPrelock = {1},
		tbStartEvent = 
		{
			{"SetFubenProgress", -1,"等待秘境開啟"},
			{"AddNpc", 100, 2, 0, "wall", "wall1",false, 49},
		},
		tbUnLockEvent = 
		{
			{"RaiseEvent", "Start"},
			{"BlackMsg", "此處寂靜地太詭異，恐怕有強敵！"},
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
			{"BlackMsg", "此地不宜久留，還是另覓他路吧！"},
			{"OpenWindow", "LingJueFengLayerPanel", "Fail"},
			{"GameLost"},
		},
	},

	[4] = {nTime = 0, nNum = 1,
		tbPrelock = {2},
		tbStartEvent = 
		{
			{"TrapUnlock", "trap1", 4},
			{"SetTargetPos", 3359, 4419},
			{"SetFubenProgress", 0, "探索凌絕峰"},
		},
		tbUnLockEvent = 
		{
			{"SetFubenProgress", 60, "擊敗端木睿"},
			{"ClearTargetPos"},		    
			{"SetNpcProtected", "boss", 0},
			{"SetAiActive", "boss", 1},
			{"SetHeadVisiable", "boss", true, 0},
			{"NpcBubbleTalk", "boss", "此處已經很久沒人來了，或許你們能陪在下練練！", 4, 1, 1},
		},
	},
	[5] = {nTime = 0, nNum = 1,
		tbPrelock = {2},
		tbStartEvent = 
		{
			{"AddNpc", 1, 1, 5, "boss", "boss1", false, 0, 0, 0, 0},	
			{"SetNpcProtected", "boss", 1},
			{"SetAiActive", "boss", 0},
			{"SetHeadVisiable", "boss", false, 1},
		},
		tbUnLockEvent = 
		{
			--判断模式篝火&踢出
			{"IfCase", "self.nFubenLevel == 3",
				{"AddSimpleNpc", 1611, 3359, 4419, 0},
				{"RaiseEvent", "KickOutAllPlayer", 40},
			},
			--判断模式获得积分
			{"RaiseEvent", "AddMissionScore", "g_score_win"},

			{"SetFubenProgress", 100, "擊敗端木睿"},
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
			{"NpcBubbleTalk", "boss", "來見識下我潛心研究多年的絕技！", 4, 0, 1},
		},
	},
	[7] = {nTime = 4, nNum = 0,
		tbPrelock = {6},
		tbStartEvent = 
		{
			{"BlackMsg", "注意躲避忽然出現的詭異火焰！"},
			--巡逻陷阱
			{"AddNpc", 2, 1, 0, "gw1", "guaiwu1", false, 0, 0, 0, 0},
			{"ChangeNpcAi", "gw1", "Move", "path1", 0, 0, 0, 0, 1},
		},
		tbUnLockEvent = 
		{
		},
	},
	[8] = {nTime = 4, nNum = 0,
		tbPrelock = {7},
		tbStartEvent = 
		{
			--巡逻陷阱
			{"AddNpc", 2, 1, 0, "gw2", "guaiwu1", false, 0, 0, 0, 0},
			{"ChangeNpcAi", "gw2", "Move", "path1", 0, 0, 0, 0, 1},
		},
		tbUnLockEvent = 
		{
		},
	},
	[9] = {nTime = 4, nNum = 0,
		tbPrelock = {8},
		tbStartEvent = 
		{
			--巡逻陷阱
			{"AddNpc", 2, 1, 0, "gw3", "guaiwu1", false, 0, 0, 0, 0},
			{"ChangeNpcAi", "gw3", "Move", "path1", 0, 0, 0, 0, 1},
		},
		tbUnLockEvent = 
		{
		},
	},
	[10] = {nTime = 4, nNum = 0,
		tbPrelock = {9},
		tbStartEvent = 
		{
			--巡逻陷阱
			{"AddNpc", 2, 1, 0, "gw4", "guaiwu1", false, 0, 0, 0, 0},
			{"ChangeNpcAi", "gw4", "Move", "path1", 0, 0, 0, 0, 1},
		},
		tbUnLockEvent = 
		{
		},
	},
	-------------------阶段2----------------------
	[11] = {nTime = 0, nNum = 1,
		tbPrelock = {4},
		tbStartEvent = 
		{
			{"NpcHpUnlock", "boss", 11, 70},
		},
		tbUnLockEvent = 
		{
			{"NpcBubbleTalk", "boss", "再來見識下我潛心研究多年的絕技！", 4, 0, 1},
		},
	},
	[12] = {nTime = 4, nNum = 0,
		tbPrelock = {11},
		tbStartEvent = 
		{
			{"BlackMsg", "注意躲避忽然出現的詭異火焰！"},
			--巡逻陷阱
			{"AddNpc", 2, 1, 0, "gw5", "guaiwu1", false, 0, 0, 0, 0},
			{"ChangeNpcAi", "gw5", "Move", "path1", 0, 0, 0, 0, 1},
		},
		tbUnLockEvent = 
		{
		},
	},
	[13] = {nTime = 4, nNum = 0,
		tbPrelock = {12},
		tbStartEvent = 
		{
			--巡逻陷阱
			{"AddNpc", 2, 1, 0, "gw6", "guaiwu1", false, 0, 0, 0, 0},
			{"ChangeNpcAi", "gw6", "Move", "path1", 0, 0, 0, 0, 1},
		},
		tbUnLockEvent = 
		{
		},
	},
	[14] = {nTime = 4, nNum = 0,
		tbPrelock = {13},
		tbStartEvent = 
		{
			--巡逻陷阱
			{"AddNpc", 2, 1, 0, "gw7", "guaiwu1", false, 0, 0, 0, 0},
			{"ChangeNpcAi", "gw7", "Move", "path1", 0, 0, 0, 0, 1},
		},
		tbUnLockEvent = 
		{
		},
	},
	[15] = {nTime = 4, nNum = 0,
		tbPrelock = {14},
		tbStartEvent = 
		{
			--巡逻陷阱
			{"AddNpc", 2, 1, 0, "gw8", "guaiwu1", false, 0, 0, 0, 0},
			{"ChangeNpcAi", "gw8", "Move", "path1", 0, 0, 0, 0, 1},
		},
		tbUnLockEvent = 
		{
		},
	},
	-------------------阶段3----------------------
	[16] = {nTime = 0, nNum = 1,
		tbPrelock = {4},
		tbStartEvent = 
		{
			{"NpcHpUnlock", "boss", 16, 50},
		},
		tbUnLockEvent = 
		{
			{"NpcBubbleTalk", "boss", "可惡，見識我的怒火吧！！", 4, 0, 1},
		},
	},
	[17] = {nTime = 4, nNum = 0,
		tbPrelock = {16},
		tbStartEvent = 
		{
			{"BlackMsg", "注意躲避忽然出現的詭異火焰！"},
			--巡逻陷阱
			{"AddNpc", 2, 1, 0, "gw9", "guaiwu1", false, 0, 0, 0, 0},
			{"ChangeNpcAi", "gw9", "Move", "path1", 0, 0, 0, 0, 1},
		},
		tbUnLockEvent = 
		{
		},
	},
	[18] = {nTime = 4, nNum = 0,
		tbPrelock = {17},
		tbStartEvent = 
		{
			--巡逻陷阱
			{"AddNpc", 2, 1, 0, "gw10", "guaiwu1", false, 0, 0, 0, 0},
			{"ChangeNpcAi", "gw10", "Move", "path1", 0, 0, 0, 0, 1},
		},
		tbUnLockEvent = 
		{
		},
	},
	[19] = {nTime = 4, nNum = 0,
		tbPrelock = {18},
		tbStartEvent = 
		{
			--巡逻陷阱
			{"AddNpc", 2, 1, 0, "gw11", "guaiwu1", false, 0, 0, 0, 0},
			{"ChangeNpcAi", "gw11", "Move", "path1", 0, 0, 0, 0, 1},
		},
		tbUnLockEvent = 
		{
		},
	},
	[20] = {nTime = 4, nNum = 0,
		tbPrelock = {19},
		tbStartEvent = 
		{
			--巡逻陷阱
			{"AddNpc", 2, 1, 0, "gw12", "guaiwu1", false, 0, 0, 0, 0},
			{"ChangeNpcAi", "gw12", "Move", "path1", 0, 0, 0, 0, 1},
		},
		tbUnLockEvent = 
		{
		},
	},

}

