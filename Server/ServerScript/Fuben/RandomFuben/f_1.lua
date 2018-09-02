
local tbFubenSetting = Fuben.RandomFuben:GetRandomFubenSetting("f_1");

tbFubenSetting.tbMultiBeginPoint = {{5998, 6154},{6118, 6024},{6304, 6156},{6204, 6290}}  
tbFubenSetting.tbTempRevivePoint = {6154, 6148};
tbFubenSetting.nStartDir		 = 42;


tbFubenSetting.NPC = 
{
	[1] = {nTemplate = 1793, nLevel = -1, nSeries = -1}, --巡逻机关人
	[2] = {nTemplate = 1794, nLevel = -1, nSeries = -1}, --唐影
	[3] = {nTemplate = 104,  nLevel = -1, nSeries = 0},  --动态障碍墙
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
			-- {"ChangeCameraSetting", 28, 35, 20},

			{"SetFubenProgress", -1,"等待秘境開啟"},
			{"AddNpc", 3, 1, 0, "wall", "wall_1_1",false, 26},
			{"OpenWindow", "LingJueFengLayerPanel", "Info",3, 9, "第六層 石崖峭壁"},
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
			{"SetFubenProgress", 0, "探索凌絕峰"},
			{"SetTargetPos", 4897, 5061},
		},
	},
	[3] = {nTime = 0, nNum = 1,
		tbPrelock = {2},
		tbStartEvent = 
		{
			{"TrapUnlock", "TrapLock1", 3},

			--唐影
			{"AddNpc", 2, 1, 4, "BOSS", "RandomFuben6_1_BOSS", false, 0, 0, 0, 0},	
			{"NpcHpUnlock", "BOSS", 30, 95},   --改回正常
			{"SetNpcProtected", "BOSS", 1},
			{"SetAiActive", "BOSS", 0},
			{"SetHeadVisiable", "BOSS", false, 1},
			{"NpcAddBuff", "BOSS", 1058, 1, 180},
		},
		tbUnLockEvent = 
		{
			{"SetFubenProgress", 50, "擊敗唐影"},
			{"ClearTargetPos"},		    
			{"SetNpcProtected", "BOSS", 0},
			{"SetAiActive", "BOSS", 1},
			{"SetHeadVisiable", "BOSS", true, 0},
			{"NpcBubbleTalk", "BOSS", "沒想到竟會在此處遇到你們，那就讓我們來切磋一番吧！！", 4, 1, 1},
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
			{"NpcBubbleTalk", "BOSS", "沒想到你們倒還有些棘手，那我也不能大意了！接招吧！！", 4, 0, 1},
			{"NpcHpUnlock", "BOSS", 40, 60},

			--巡逻机关人
			{"AddNpc", 1, 1, 0, "Xunluo1", "RandomFuben6_1_Xunluo1", false, 40, 0, 0, 0},	

			{"CastSkill", "Xunluo1", 2369, 30, -1, -1}, 

			{"StartTimeCycle", "cycle_1", 3, 100, 
				{"CastSkill", "Xunluo1", 2369, 30, -1, -1}, 
			},

			{"ChangeNpcAi", "Xunluo1", "Move", "Path1", 0, 1, 1, 0, 1},

		},
	},
	[31] = {nTime = 2, nNum = 0,
		tbPrelock = {30},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"BlackMsg", "唐影召喚出[FFFE0D]巡邏機關人[-]，各位俠士請小心應對！"},
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
			{"NpcBubbleTalk", "BOSS", "不要太得意了，就讓你們見識一下我唐門機關術的威力！！", 4, 0, 1},

			--巡逻机关人
			{"AddNpc", 1, 1, 0, "Xunluo2", "RandomFuben6_1_Xunluo2", false, 8, 0, 0, 0},

			{"CastSkill", "Xunluo2", 2369, 30, -1, -1}, 

			{"StartTimeCycle", "cycle_2", 3, 100, 
				{"CastSkill", "Xunluo2", 2369, 30, -1, -1}, 
			},

			{"ChangeNpcAi", "Xunluo2", "Move", "Path2", 0, 1, 1, 0, 1},
		},
	},
	[41] = {nTime = 2, nNum = 0,
		tbPrelock = {40},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"BlackMsg", "唐影召喚出[FFFE0D]巡邏機關人[-]，各位俠士請小心應對！"},
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
			{"SetFubenProgress", 100, "擊敗唐影"},

			--判断模式篝火&踢出
			{"IfCase", "self.nFubenLevel == 2",
				{"AddSimpleNpc", 1611, 4654, 4515, 0},
				{"RaiseEvent", "KickOutAllPlayer", 40},
			},
			--判断模式获得积分
			{"RaiseEvent", "AddMissionScore", "f_score_win"},

			{"OpenWindow", "LingJueFengLayerPanel", "Win"},
			{"GameWin"},
		},
	},
	-------------闯关时间------------------------
	[5] = {nTime = "f_1_time", nNum = 0,    --总计时
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
			{"BlackMsg", "唐影武藝高強，還是先撤退為妙！"},

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

