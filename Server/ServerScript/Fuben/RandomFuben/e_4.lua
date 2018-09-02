
local tbFubenSetting = Fuben.RandomFuben:GetRandomFubenSetting("e_4");

tbFubenSetting.tbMultiBeginPoint = {{2635, 5964},{3049, 5979},{2620, 6393},{3025, 6408}}	-- 副本出生点
tbFubenSetting.tbTempRevivePoint = {2847, 6204};
tbFubenSetting.nStartDir		 = 32;


tbFubenSetting.NPC = 
{
	[1] = {nTemplate = 1585,  nLevel = -1, nSeries = -1},--飞龙堡叛徒
	[2] = {nTemplate = 1586,  nLevel = -1, nSeries = -1},--无忧教精英
	[3] = {nTemplate = 1587,  nLevel = -1, nSeries = -1},--无忧教头目
	[4] = {nTemplate = 104,   nLevel = -1, nSeries = 0}, --动态障碍墙
	[5] = {nTemplate = 1588,  nLevel = -1, nSeries = 0}, --无想
	[6] = {nTemplate = 2425,  nLevel = -1, nSeries = 0}, --受伤的月眉儿
	[7] = {nTemplate = 2472,  nLevel = -1, nSeries = 0}, --滚石
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
			{"AddNpc", 4, 2, 1, "wall", "wall_1_1",false, 16},
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
			{"AddNpc", 6, 1, 20, "mb", "RandomFuben5_4_mb",false, 32, 0, 0, 0},
			{"NpcBubbleTalk", "mb", "這群暗箭傷人的狗東西！！", 4, 7, 1},
			--稀有几率
			{"Random", {350000, 30}},
		},
	},
	[21] = {nTime = 0.2, nNum = 0,
		tbPrelock = {2},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"DoCommonAct", "mb", 36, 0, 1, 0},
		},
	},
	[3] = {nTime = 0, nNum = 1,
		tbPrelock = {2},
		tbStartEvent = 
		{
			{"ChangeFightState", 1},
			{"SetFubenProgress", 0, "保護受傷的月眉兒"},
			{"SetTargetPos", 3521, 4021},
			{"TrapUnlock", "TrapLock1", 3},
		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},
			{"SetFubenProgress", 30, "擊敗第一波敵人"},
			{"AddNpc", 1, 6, 4, "guaiwu", "RandomFuben5_4_1", false, 0, 0, 0, 0},
			{"AddNpc", 2, 1, 4, "Elite", "RandomFuben5_4_2", false, 0, 0, 9011, 0},
			{"ChangeNpcAi", "guaiwu", "AddAiLockTarget", "mb"},
			{"ChangeNpcAi", "Elite", "AddAiLockTarget", "mb"},
			{"NpcBubbleTalk", "Elite", "乖乖歸順我們無憂教吧！", 4, 7, 1},
			{"NpcBubbleTalk", "mb", "呸！大言不慚！", 4, 7, 1},
		},
	},
	[11] = {nTime = 5, nNum = 0,
		tbPrelock = {3},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"BlackMsg", "小心滾石！"},
			{"AddNpc", 7, 1, 0, "Gunshi1", "RandomFuben5_4_Gunshi_1", false, 0, 0, 0, 0},
			{"AddNpc", 7, 1, 0, "Gunshi2", "RandomFuben5_4_Gunshi_2", false, 0, 0, 0, 0},
			{"AddNpc", 7, 1, 0, "Gunshi3", "RandomFuben5_4_Gunshi_3", false, 0, 0, 0, 0},
			{"AddNpc", 7, 1, 0, "Gunshi4", "RandomFuben5_4_Gunshi_4", false, 0, 0, 0, 0},
			{"AddNpc", 7, 1, 0, "Gunshi4", "RandomFuben5_4_Gunshi_5", false, 0, 0, 0, 0},
			{"ChangeNpcAi", "Gunshi1", "Move", "Path1", 0, 0, 0, 1, 0},
			{"ChangeNpcAi", "Gunshi2", "Move", "Path2", 0, 0, 0, 1, 0},
			{"ChangeNpcAi", "Gunshi3", "Move", "Path3", 0, 0, 0, 1, 0},
			{"ChangeNpcAi", "Gunshi4", "Move", "Path4", 0, 0, 0, 1, 0},
			{"ChangeNpcAi", "Gunshi5", "Move", "Path5", 0, 0, 0, 1, 0},
		},
	},
	[4] = {nTime = 0, nNum = 7,
		tbPrelock = {3},
		tbStartEvent = 
		{

		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},
			{"SetFubenProgress", 60, "擊敗第二波敵人"},

			
		
			{"AddNpc", 2, 1, 10, "Elite", "RandomFuben5_4_2", false, 0, 0, 9011, 0},	

			{"AddNpc", 1, 6, 10, "guaiwu", "RandomFuben5_4_1", false, 0, 0, 9008, 0},
			{"ChangeNpcAi", "guaiwu", "AddAiLockTarget", "mb"},
			{"ChangeNpcAi", "Elite", "AddAiLockTarget", "mb"},	
			{"NpcBubbleTalk", "Elite", "抵抗是沒用的！", 4, 7, 1},
			{"NpcBubbleTalk", "mb", "有本事來殺了姑奶奶！", 4, 7, 1},
		},
	},
	[12] = {nTime = 5, nNum = 0,
		tbPrelock = {4},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"BlackMsg", "小心滾石！"},
			{"AddNpc", 7, 1, 0, "Gunshi1", "RandomFuben5_4_Gunshi_1", false, 0, 0, 0, 0},
			{"AddNpc", 7, 1, 0, "Gunshi2", "RandomFuben5_4_Gunshi_2", false, 0, 0, 0, 0},
			{"AddNpc", 7, 1, 0, "Gunshi3", "RandomFuben5_4_Gunshi_3", false, 0, 0, 0, 0},
			{"AddNpc", 7, 1, 0, "Gunshi4", "RandomFuben5_4_Gunshi_4", false, 0, 0, 0, 0},
			{"AddNpc", 7, 1, 0, "Gunshi4", "RandomFuben5_4_Gunshi_5", false, 0, 0, 0, 0},
			{"ChangeNpcAi", "Gunshi1", "Move", "Path1", 0, 0, 0, 1, 0},
			{"ChangeNpcAi", "Gunshi2", "Move", "Path2", 0, 0, 0, 1, 0},
			{"ChangeNpcAi", "Gunshi3", "Move", "Path3", 0, 0, 0, 1, 0},
			{"ChangeNpcAi", "Gunshi4", "Move", "Path4", 0, 0, 0, 1, 0},
			{"ChangeNpcAi", "Gunshi5", "Move", "Path5", 0, 0, 0, 1, 0},
		},
	},
	[10] = {nTime = 0, nNum = 7,
		tbPrelock = {4},
		tbStartEvent = 
		{

		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},
			{"SetFubenProgress", 90, "擊敗第三波敵人"},
			
			{"AddNpc", 3, 1, 5, "BOSS", "RandomFuben5_4_2", false, 0, 0, 9011, 0},	

			{"AddNpc", 1, 6, 5, "guaiwu", "RandomFuben5_4_1", false, 0, 0, 9008, 0},
			{"ChangeNpcAi", "guaiwu", "AddAiLockTarget", "mb"},
			--{"ChangeNpcAi", "BOSS", "AddAiLockTarget", "mb"},
			{"NpcBubbleTalk", "BOSS", "不投降只有死路一條！！", 4, 7, 1},
			{"NpcBubbleTalk", "mb", "一群敗類速來受死！", 4, 7, 1},	
		},
	},
	[13] = {nTime = 5, nNum = 0,
		tbPrelock = {10},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"BlackMsg", "小心滾石！"},
			{"AddNpc", 7, 1, 0, "Gunshi1", "RandomFuben5_4_Gunshi_1", false, 0, 0, 0, 0},
			{"AddNpc", 7, 1, 0, "Gunshi2", "RandomFuben5_4_Gunshi_2", false, 0, 0, 0, 0},
			{"AddNpc", 7, 1, 0, "Gunshi3", "RandomFuben5_4_Gunshi_3", false, 0, 0, 0, 0},
			{"AddNpc", 7, 1, 0, "Gunshi4", "RandomFuben5_4_Gunshi_4", false, 0, 0, 0, 0},
			{"AddNpc", 7, 1, 0, "Gunshi4", "RandomFuben5_4_Gunshi_5", false, 0, 0, 0, 0},
			{"ChangeNpcAi", "Gunshi1", "Move", "Path1", 0, 0, 0, 1, 0},
			{"ChangeNpcAi", "Gunshi2", "Move", "Path2", 0, 0, 0, 1, 0},
			{"ChangeNpcAi", "Gunshi3", "Move", "Path3", 0, 0, 0, 1, 0},
			{"ChangeNpcAi", "Gunshi4", "Move", "Path4", 0, 0, 0, 1, 0},
			{"ChangeNpcAi", "Gunshi5", "Move", "Path5", 0, 0, 0, 1, 0},
		},
	},
-------------胜利判定------------------------
	[5] = {nTime = 0, nNum = 7,
		tbPrelock = {4},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
		},
	},
	[6] = {nTime = 0.1, nNum = 0,
		tbPrelock = {5},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			--掉落房间奖励
			{"RaiseEvent", "DropAward", "Setting/Fuben/RandomFuben/HouseAward/E.tab", 4380, 3541},
			{"RaiseEvent", "DropAward", "Setting/Fuben/RandomFuben/HouseAward/E.tab", 4112, 3388},
			{"RaiseEvent", "DropAward", "Setting/Fuben/RandomFuben/HouseAward/E.tab", 3815, 3842},
			{"RaiseEvent", "DropAward", "Setting/Fuben/RandomFuben/HouseAward/E.tab", 3539, 3677},

			{"SetFubenProgress", 100, "成功保護月眉兒"},

			--判断模式篝火&踢出
			{"IfCase", "self.nFubenLevel == 1",
				{"AddSimpleNpc", 1611, 4018, 3615, 0},
				{"RaiseEvent", "KickOutAllPlayer", 40},
			},
			--判断模式获得积分
			{"RaiseEvent", "AddMissionScore", "e_score_win"},

			{"OpenWindow", "LingJueFengLayerPanel", "Win"},
			{"GameWin"},
		},
	},
-------------闯关时间------------------------	
	[7] = {nTime = "e_4_time", nNum = 0,
		tbPrelock = {2},
		tbStartEvent = 
		{
			{"SetShowTime", 7},
		},
		tbUnLockEvent = 
		{
			{"SetFubenProgress", -1, "闖關失敗"},
			{"BlackMsg", "無憂教果然厲害，還是趕緊撤退為妙！"},

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
-------------月眉儿死亡锁------------------------
	[20] = {nTime = 0, nNum = 1,
		tbPrelock = {2},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"SetFubenProgress", -1, "闖關失敗"},
			{"BlackMsg", "我等無用沒能護月眉兒周全，無顏上山！"},

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

---------------------稀有锁---------------------------------
	[30] = {nTime = 0, nNum = 1,
		tbPrelock = {},
		tbStartEvent = 
		{
			{"UnLock", 30},

			--无想
			{"AddNpc", 5, 1, 32, "Wuxiang", "RandomFuben5_4_Xiyou",false, 26 , 0, 0, 0},
		},
		tbUnLockEvent = 
		{
			{"NpcBubbleTalk", "Wuxiang", "沒想到會在這裡碰到你們，我們一起守護月眉兒吧吧！", 4, 1, 1},
		},
	},
	[31] = {nTime = 1, nNum = 0,
		tbPrelock = {30, 5},
		tbStartEvent = 
		{
			{"RaiseEvent", "DropAward", "Setting/Npc/DropFile/RandomFuben/House_E/wuxiang.tab", 4646, 4756},
			{"RaiseEvent", "DropAward", "Setting/Npc/DropFile/RandomFuben/House_E/wuxiang.tab", 4519, 4572},
			{"RaiseEvent", "DropAward", "Setting/Npc/DropFile/RandomFuben/House_E/wuxiang.tab", 4811, 4566},
			{"RaiseEvent", "DropAward", "Setting/Npc/DropFile/RandomFuben/House_E/wuxiang.tab", 4811, 4566},

			{"RaiseEvent", "DropCard", 2625, 350000},	--卡片收集掉落
		},
		tbUnLockEvent = 
		{				
		},
	},

	--无想死亡锁
	[32] = {nTime = 0, nNum = 1,
		tbPrelock = {30},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"CloseLock", 31},
		},
	},
}

