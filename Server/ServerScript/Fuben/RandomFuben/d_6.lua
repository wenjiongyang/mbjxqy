
local tbFubenSetting = Fuben.RandomFuben:GetRandomFubenSetting("d_6");

tbFubenSetting.tbMultiBeginPoint = {{4809, 2447},{5194, 2447},{4816, 2120},{5201, 2109}}	-- 副本出生点
tbFubenSetting.tbTempRevivePoint = {5010, 2292}
tbFubenSetting.nStartDir		 = 1;

--NPC模版ID，NPC等级，NPC五行；

--[[

]]

tbFubenSetting.NPC = 
{
	[1] = {nTemplate = 1362, nLevel = -1, nSeries = -1}, --宋兵
	[2] = {nTemplate = 1363, nLevel = -1, nSeries = -1}, --机关人控制器
	[3] = {nTemplate = 1364, nLevel = -1, nSeries = -1}, --刀盾兵
	[4] = {nTemplate = 1365, nLevel = -1, nSeries = -1}, --巡逻机关人
	[5] = {nTemplate = 1366, nLevel = -1, nSeries = -1}, --赵节
	[6] = {nTemplate = 104,  nLevel = -1, nSeries = 0},  --动态障碍墙

	[7] = {nTemplate = 1821,  nLevel = -1, nSeries = 0},  --卡片收集
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
			{"AddNpc", 6, 2, 1, "wall_1", "wall_1_1",false, 16},
			{"OpenWindow", "LingJueFengLayerPanel", "Info",3, 9, "第四層 機關密室"},
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
			{"ShowTaskDialog", 10003, false},
			{"DoDeath", "wall_1"},
			{"AddNpc", 6, 1, 1, "wall_2", "wall_1_2",false, 32},
			{"OpenDynamicObstacle", "ops1"},
		},
	},
	[3] = {nTime = 0, nNum = 1,
		tbPrelock = {2},
		tbStartEvent = 
		{
			{"SetFubenProgress", 0, "探索機關密室"},
			{"TrapUnlock", "TrapLock1", 3},
		},
		tbUnLockEvent = 
		{
			{"SetFubenProgress", 20, "躲避巡邏機關人"},
			
			--关闭剧情对话
			{"CloseWindow", "SituationalDialogue"},
			{"PlayCameraEffect", 9119},	
			{"MoveCamera", 0, 1, 43.05, 14.79, 26.12, 35, 45, 0},
			{"SetAllUiVisiable", false}, 

			--巡逻机关人
			{"AddNpc", 4, 1, 0, "Xunluo1", "RandomFuben4_6_xunluo1",false, 0, 0, 0, 0},
			{"ChangeNpcAi", "Xunluo1", "Move", "Path1", 0, 1, 1, 0, 1},
			{"NpcAddBuff", "Xunluo1", 1884, 1, 150},

			--加定身BUFF
			{"AddBuff", 1058, 1, 8, 0, 0},

			--判断是否为普通模式
			{"IfCase", "not self.bElite", 
				{"PauseLock", 14},
			},

			--判断是否为噩梦模式
			{"IfCase", "self.bElite", 
				{"PauseLock", 13},
			},

			--加副本后台时间
			{"ChangeTime", -6},
		},
	},
	[4] = {nTime = 2, nNum = 0,
		tbPrelock = {3},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"MoveCamera", 0, 3, 60.9, 14.79, 23.4, 35, 45, 0},
		},
	},
	[5] = {nTime = 4, nNum = 0,
		tbPrelock = {4},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"BlackMsg", "前方出現巡邏機關人，不要被發現了！"},	
			{"PlayCameraEffect", 9119},	
			{"LeaveAnimationState", false},
			{"SetAllUiVisiable", true}, 

			--移除定身
			{"RemovePlayerSkillState", 1058},

			--判断是否为普通模式
			{"IfCase", "not self.bElite", 
				{"ResumeLock", 14},
				{"SetShowTime", 14},
			},

			--判断是否为噩梦模式
			{"IfCase", "self.bElite", 
				{"ResumeLock", 13},
				{"SetShowTime", 13},
			},
		},
	},
	[6] = {nTime = 0, nNum = 1,
		tbPrelock = {3},
		tbStartEvent = 
		{
			{"TrapUnlock", "TrapLock2", 6},

			--宋兵 & 机关人控制器 & 射手						
			{"AddNpc", 1, 3, 7, "guaiwu1", "RandomFuben4_6_1",false, 0, 0, 0, 0},
			{"AddNpc", 2, 1, 7, "guaiwu", "RandomFuben4_6_jiguan1",false, 0, 0, 0, 0},
			{"AddNpc", 3, 2, 7, "guaiwu", "RandomFuben4_6_2",false, 0, 3, 0, 0},
		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},
			{"SetFubenProgress", 40, "破壞機關裝置"},
			{"BlackMsg", "看來這就是控制機關人的裝置了，將它破壞掉！！"},	
			{"NpcBubbleTalk", "guaiwu1", "來者何人，這密室已經被我們承包了，閒雜人等趕緊滾出去！", 4, 1, 1},	
		},
	},
	[7] = {nTime = 0, nNum = 6,
		tbPrelock = {5},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"SetFubenProgress", 60, "探索機關密室"},
			{"OpenDynamicObstacle", "ops2"},
			{"DoDeath", "wall_2"},
			{"DelNpc", "Xunluo1"},
			{"BlackMsg", "繼續探索機關密室！"},
		},
	},
	[8] = {nTime = 0, nNum = 1,
		tbPrelock = {7},
		tbStartEvent = 
		{
			{"TrapUnlock", "TrapLock5", 8},
		},
		tbUnLockEvent = 
		{
			{"SetFubenProgress", 70, "躲避巡邏機關人"},
			{"BlackMsg", "前方出現巡邏機關人！請務必小心行事！"},

			--巡逻机关人
			{"AddNpc", 4, 1, 0, "Xunluo2", "RandomFuben4_6_xunluo2",false, 0, 0, 0, 0},
			{"AddNpc", 4, 1, 0, "Xunluo3", "RandomFuben4_6_xunluo3",false, 0, 0, 0, 0},
			{"ChangeNpcAi", "Xunluo2", "Move", "Path2", 0, 1, 1, 0, 1},
			{"ChangeNpcAi", "Xunluo3", "Move", "Path3", 0, 1, 1, 0, 1},
			{"NpcAddBuff", "Xunluo2", 1884, 1, 150},
			{"NpcAddBuff", "Xunluo3", 1884, 1, 150},
		},
	},
	[9] = {nTime = 0, nNum = 1,
		tbPrelock = {8},
		tbStartEvent = 
		{
			{"TrapUnlock", "TrapLock3", 9},

			--宋兵 & 机关人控制器 & 射手						
			{"AddNpc", 1, 3, 10, "guaiwu1", "RandomFuben4_6_3",false, 0, 0, 0, 0},
			{"AddNpc", 2, 1, 10, "guaiwu", "RandomFuben4_6_jiguan2",false, 0, 0, 0, 0},
			{"AddNpc", 3, 2, 10, "guaiwu", "RandomFuben4_6_4",false, 0, 3, 0, 0},
		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},
			{"SetFubenProgress", 80, "破壞機關裝置"},
			{"BlackMsg", "擊敗敵人，並破壞掉控制機關人的裝置！！"},
			{"NpcBubbleTalk", "guaiwu1", "來者何人，這密室已經被我們承包了，閒雜人等趕緊滾出去！", 4, 1, 1},	
		},
	},
	[10] = {nTime = 0, nNum = 6,
		tbPrelock = {8},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"SetFubenProgress", 80, "擊敗趙節"},
			{"DelNpc", "Xunluo2"},
			{"DelNpc", "Xunluo3"},
			{"SetTargetPos", 4337, 9285},
		},
	},
	[11] = {nTime = 0, nNum = 1,
		tbPrelock = {10},
		tbStartEvent = 
		{
			{"TrapUnlock", "TrapLock4", 11},
		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},

			--赵节
			{"AddNpc", 5, 1, 12, "BOSS", "RandomFuben4_6_BOSS",false, 0, 1, 9011, 1},
			{"NpcBubbleTalk", "BOSS", "何人敢造次，還不給本將速速領死！", 4, 3, 1},
		},
	},

-------------胜利判定------------------------
	[12] = {nTime = 0, nNum = 1,
		tbPrelock = {11},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"SetFubenProgress", 100, "擊敗趙節"},

			--判断模式获得积分
			{"RaiseEvent", "AddMissionScore", "d_score_win"},

			{"OpenWindow", "LingJueFengLayerPanel", "Win"},
			{"GameWin"},
		},
	},
-------------闯关时间------------------------
	
	[13] = {nTime = "d_6_time", nNum = 0,
		tbPrelock = {2},
		tbStartEvent = 
		{
			{"SetShowTime", 13},
		},
		tbUnLockEvent = 
		{
			{"BlackMsg", "此地危險重重，不宜久留！"},
			
			--判断模式获得积分
			{"RaiseEvent", "AddMissionScore", "d_score_lost"},

			{"OpenWindow", "LingJueFengLayerPanel", "Fail"},
			{"GameLost"},
		},
	},

----------------------卡片收集----------------
	[15] = {nTime = 0, nNum = 1,
		tbPrelock = {8},
		tbStartEvent = 
		{
			{"RaiseEvent", "CheckCollectionAct", {"UnLock", 15}},
		},
		tbUnLockEvent = 
		{
			{"Random", {250000, 16}},
		},
	},
	[16] = {nTime = 3, nNum = 0,
		tbPrelock = {},
		tbStartEvent = 
		{
			{"AddNpc", 7, 1, 0, "Card", "RandomFuben4_6_xunluo2",false, 0, 0, 0, 0},
		},
		tbUnLockEvent = 
		{
			{"BlackMsg", "好像聽到什麼東西掉在地上的聲音！！！"},
		},
	},

}

