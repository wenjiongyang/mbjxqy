
local tbFubenSetting = Fuben.RandomFuben:GetRandomFubenSetting("e_3");

tbFubenSetting.tbMultiBeginPoint = {{4889, 1759},{4413, 1662},{4356, 1933},{4807, 2071}}	-- 副本出生点
tbFubenSetting.tbTempRevivePoint = {4722, 1763};
tbFubenSetting.nStartDir		 = 59;

tbFubenSetting.NPC = 
{
	[1] = {nTemplate = 1386, nLevel = -1, nSeries = -1},  --庄丁
	[2] = {nTemplate = 1387, nLevel = -1, nSeries = -1},  --庄丁头目
	[3] = {nTemplate = 1388, nLevel = -1, nSeries = -1},  --五色教弟子
	[4] = {nTemplate = 1389, nLevel = -1, nSeries = -1},  --方勉
	[5] = {nTemplate = 1393, nLevel = -1, nSeries = -1},  --放技能
	[6] = {nTemplate = 104,  nLevel = -1, nSeries = 0},

	[7] = {nTemplate = 1823,  nLevel = -1, nSeries = 0},	--卡片收集
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
			{"SetFubenProgress", -1,"等待秘境開啟"},
			{"AddNpc", 6, 1, 0, "wall", "wall_1_1",false, 13},
			{"OpenWindow", "LingJueFengLayerPanel", "Info",3, 9, "第五層 寒梅山莊"},
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
		},
	},
	[3] = {nTime = 0, nNum = 1,
		tbPrelock = {2},
		tbStartEvent = 
		{
			{"SetFubenProgress", 0, "探索凌絕峰"},
			{"SetTargetPos", 4187, 3648},			
			{"TrapUnlock", "TrapLock1", 3},

			--方勉
			{"AddNpc", 4, 1, 7, "BOSS", "RandomFuben4_3_BOSS", false, 0, 1, 9011, 1},
		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},
			{"SetFubenProgress", 50, "擊敗方勉"},
			{"NpcBubbleTalk", "BOSS", "何人敢在此造次，還不速速領死！", 4, 1, 1},
			{"NpcHpUnlock", "BOSS", 4, 75},	
		},
	},
	[4] = {nTime = 0, nNum = 1,
		tbPrelock = {3},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"NpcBubbleTalk", "BOSS", "讓老夫看看你們究竟有何本領！", 4, 0, 1},	
			{"AddNpc", 5, 1, 0, "Fire", "[NpcGroup=BOSS]", false, 0, 0, 0, 0},
			{"StartTimeCycle", "cycle_1", 5, 100, {"AddNpc", 5, 1, 0, "Fire", "[NpcGroup=BOSS]", false, 0, 0, 0, 0}},
			{"NpcHpUnlock", "BOSS", 5, 50},
		},
	},
	[5] = {nTime = 0, nNum = 1,
		tbPrelock = {4},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			--关闭循环
			{"CloseCycle", "cycle_1"},
			{"NpcBubbleTalk", "BOSS", "沒想到你們倒還有點本事，倒是小瞧你們了！", 4, 0, 1},	
			{"NpcHpUnlock", "BOSS", 6, 25},
		},
	},
	[6] = {nTime = 0, nNum = 1,
		tbPrelock = {4},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"NpcBubbleTalk", "BOSS", "你們成功將我激怒了，受死吧！！", 4, 0, 1},	
			{"AddNpc", 5, 1, 0, "Fire", "[NpcGroup=BOSS]", false, 0, 0, 0, 0},
			{"StartTimeCycle", "cycle_1", 5, 100, {"AddNpc", 5, 1, 0, "Fire", "[NpcGroup=BOSS]", false, 0, 0, 0, 0}},
		},
	},

-------------胜利判定------------------------
	[7] = {nTime = 0, nNum = 1,
		tbPrelock = {2},
		tbStartEvent = 
		{		

		},
		tbUnLockEvent = 
		{
			{"SetFubenProgress", 100, "擊敗方勉"},
			--关闭循环
			{"CloseCycle", "cycle_1"},

			--判断模式篝火&踢出
			{"IfCase", "self.nFubenLevel == 1",
				{"AddSimpleNpc", 1611, 3962, 4159, 0},
				{"RaiseEvent", "KickOutAllPlayer", 40},
			},
			--判断模式获得积分
			{"RaiseEvent", "AddMissionScore", "e_score_win"},
			
			--卡片收集
			{"RaiseEvent", "CheckCollectionAct", 
				{"IfCase", "MathRandom(100) <= 25", 
					{"AddSimpleNpc", 1823, 3730, 4505, 0}
				}
			},

			{"OpenWindow", "LingJueFengLayerPanel", "Win"},
			{"GameWin"},	
		},
	},
-------------闯关时间------------------------	
	[8] = {nTime = "e_3_time", nNum = 0,
		tbPrelock = {2},
		tbStartEvent = 
		{
			{"SetShowTime", 8},
		},
		tbUnLockEvent = 
		{
			{"SetFubenProgress", -1, "闖關失敗"},
			{"BlackMsg", "這方勉的武藝真是高深莫測！"},
			
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

