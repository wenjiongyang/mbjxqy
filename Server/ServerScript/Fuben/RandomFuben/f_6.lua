
local tbFubenSetting = Fuben.RandomFuben:GetRandomFubenSetting("f_6");

tbFubenSetting.tbMultiBeginPoint = {{6270, 5271},{6255, 4979},{6505, 4967},{6526, 5245}}	-- 副本出生点
tbFubenSetting.tbTempRevivePoint = {6395, 5121};
tbFubenSetting.nStartDir		 = 49;


tbFubenSetting.NPC = 
{
	[1] = {nTemplate = 1818, nLevel = -1, nSeries = -1}, --召唤NPC1
	[2] = {nTemplate = 1819, nLevel = -1, nSeries = -1}, --召唤NPC2
	[3] = {nTemplate = 1820, nLevel = -1, nSeries = -1}, --月明遥
	[4] = {nTemplate = 104,  nLevel = -1, nSeries = 0},  --动态障碍墙
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
			{"OpenWindow", "LingJueFengLayerPanel", "Info",3, 9, "第六層 千壑雪嶺"},
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
			{"SetTargetPos", 5092, 5319},
			{"SetFubenProgress", 0, "探索凌絕峰"},
		},
	},
	[3] = {nTime = 0, nNum = 1,
		tbPrelock = {2},
		tbStartEvent = 
		{
			{"TrapUnlock", "TrapLock1", 3},

			--月明遥
			{"AddNpc", 3, 1, 4, "BOSS", "RandomFuben6_6_BOSS", false, 40, 0, 0, 0},	
			{"SetHeadVisiable", "BOSS", false, 1},
			{"NpcHpUnlock", "BOSS", 30, 80},
			{"SetNpcProtected", "BOSS", 1},
			{"SetAiActive", "BOSS", 0},
		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},
			{"SetFubenProgress", 50, "擊敗月明遙"},
			{"SetNpcProtected", "BOSS", 0},
			{"SetAiActive", "BOSS", 1},
			{"SetHeadVisiable", "BOSS", true, 0},
			{"NpcBubbleTalk", "BOSS", "沒想到竟會在此處遇到你們，那就讓我們來切磋一番吧！！", 4, 0, 1},	
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

			--巡逻怪（混乱）
			{"AddNpc", 1, 1, 0, "Xunluo1", "RandomFuben6_6_Xunluo1", false, 0, 0, 0, 0},	

			--远程放技能怪
			{"AddNpc", 2, 1, 0, "Special1", "RandomFuben6_6_Special1", false, 0, 0, 0, 0},	
			{"AddNpc", 2, 1, 0, "Special2", "RandomFuben6_6_Special2", false, 0, 0, 0, 0},

			{"ChangeNpcAi", "Xunluo1", "Move", "Path1", 0, 0, 0, 0, 1},			
		},
	},
	[31] = {nTime = 2, nNum = 0,
		tbPrelock = {30},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"BlackMsg", "月明遙[FFFE0D]召集援手助陣[-]，請各位俠士小心應對！！"},
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
			{"NpcBubbleTalk", "BOSS", "諸位武藝高強，既然如此那小女子也不能繼續藏拙了，接招吧！！", 4, 0, 1},

			--巡逻怪（混乱）
			{"AddNpc", 1, 1, 0, "Xunluo2", "RandomFuben6_6_Xunluo2", false, 0, 0, 0, 0},

			--远程放技能怪
			{"AddNpc", 2, 1, 0, "Special3", "RandomFuben6_6_Special3", false, 0, 0, 0, 0},	
			{"AddNpc", 2, 1, 0, "Special4", "RandomFuben6_6_Special4", false, 0, 0, 0, 0},
			{"AddNpc", 2, 1, 0, "Special5", "RandomFuben6_6_Special5", false, 0, 0, 0, 0},

			{"ChangeNpcAi", "Xunluo2", "Move", "Path2", 0, 0, 0, 0, 1},
		},
	},
	[41] = {nTime = 2, nNum = 0,
		tbPrelock = {40},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"BlackMsg", "月明遙[FFFE0D]召集援手助陣[-]，請各位俠士小心應對！！"},
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
			{"SetFubenProgress", 100, "擊敗月明遙"},

			--判断模式篝火&踢出
			{"IfCase", "self.nFubenLevel == 2",
				{"AddSimpleNpc", 1611, 4412, 5369, 0},
				{"RaiseEvent", "KickOutAllPlayer", 40},
			},
			--判断模式获得积分
			{"RaiseEvent", "AddMissionScore", "f_score_win"},

			{"OpenWindow", "LingJueFengLayerPanel", "Win"},
			{"GameWin"},
		},
	},
	-------------闯关时间------------------------
	[5] = {nTime = "f_6_time", nNum = 0,    --总计时
		tbPrelock = {2},
		tbStartEvent = 
		{
			{"SetShowTime", 5},
		},
		tbUnLockEvent = 
		{
			{"SetFubenProgress", -1, "闖關失敗"},
			{"BlackMsg", "月明遙武藝高強，還是先撤退為妙！"},

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

