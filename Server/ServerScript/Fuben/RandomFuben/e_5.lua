
local tbFubenSetting = Fuben.RandomFuben:GetRandomFubenSetting("e_5");

tbFubenSetting.tbMultiBeginPoint = {{1772, 4049},{1768, 3708},{1520, 4041},{1524, 3704}}	-- 副本出生点
tbFubenSetting.tbTempRevivePoint = {1638, 3857};
tbFubenSetting.nStartDir		 = 15;


tbFubenSetting.NPC = 
{
	[1] = {nTemplate = 1419, nLevel = -1, nSeries = 0},   --机关人
	[2] = {nTemplate = 1420, nLevel = -1, nSeries = -1},  --炮车
	[3] = {nTemplate = 1421, nLevel = -1, nSeries = 0},   --炮车（骑乘NPC）
	[4] = {nTemplate = 1132, nLevel = -1, nSeries = -1},  --南宫灭
	[5] = {nTemplate = 104,  nLevel = -1, nSeries = 0},   --动态障碍墙
	[6] = {nTemplate = 1423, nLevel = -1, nSeries = 0},   --放技能NPC
	[7] = {nTemplate = 73,   nLevel = -1, nSeries = 0},   --传送门
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
			{"AddNpc", 5, 2, 0, "wall_1", "wall_1_1",false, 32},
			{"OpenWindow", "LingJueFengLayerPanel", "Info",3, 9, "第五層 天機工坊"},
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
			-- {"ShowTaskDialog", 10005, false},
			{"OpenDynamicObstacle", "ops1"},
			{"DoDeath", "wall_1"},
			{"AddNpc", 5, 2, 0, "wall_2", "wall_1_2",false, 33},			
			{"ChangeTrap", "TrapLock1", {3223, 3877}, nil},
			{"AddNpc", 7, 1, 0, "Chuansong", "ChuanSongMen",false, 33},
		},
	},
	[3] = {nTime = 0, nNum = 1,
		tbPrelock = {2},
		tbStartEvent = 
		{
			{"SetFubenProgress", 0, "探索天機工坊"},
			{"TrapUnlock", "TrapLock2", 3},
			{"SetTargetPos", 4021, 3896},
		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},
		},
	},

-------------胜利判定------------------------
	[4] = {nTime = 0, nNum = 1,
		tbPrelock = {3},
		tbStartEvent = 
		{
			--南宫灭
			{"AddNpc", 4, 1, 4, "BOSS", "RandomFuben5_5_BOSS", false, 0, 0, 0, 0},
			{"SetFubenProgress", 50, "擊敗南宮滅"},				
			{"NpcBubbleTalk", "BOSS", "沒想到你們竟會闖入這裡，今日你們將在劫難逃！", 4, 1, 1},
		},
		tbUnLockEvent = 
		{
			{"SetFubenProgress", 100, "擊敗南宮滅"},

			--判断模式篝火&踢出
			{"IfCase", "self.nFubenLevel == 1",
				{"AddSimpleNpc", 1611, 4790, 3926, 0},
				{"RaiseEvent", "KickOutAllPlayer", 40},				
			},

			--判断模式获得积分
			{"RaiseEvent", "AddMissionScore", "e_score_win"},

			{"OpenWindow", "LingJueFengLayerPanel", "Win"},			
			{"GameWin"},
		},
	},
-------------闯关时间------------------------	
	[5] = {nTime = "e_5_time", nNum = 0,
		tbPrelock = {2},
		tbStartEvent = 
		{
			{"SetShowTime", 5},
		},
		tbUnLockEvent = 
		{
			--判断模式踢出
			{"IfCase", "self.nFubenLevel == 1",
				{"RaiseEvent", "KickOutAllPlayer", 10},
			},
			--判断模式获得积分
			{"RaiseEvent", "AddMissionScore", "e_score_lost"},

			{"SetFubenProgress", -1, "闖關失敗"},
			{"BlackMsg", "好險，差點就小命不保！"},
			{"OpenWindow", "LingJueFengLayerPanel", "Fail"},
			{"GameLost"},
		},
	},
------------------------列阵枪毙（第一次）------------------------------
	[30] = {nTime = 0, nNum = 1,
		tbPrelock = {3},
		tbStartEvent = 
		{
			{"NpcHpUnlock", "BOSS", 30, 80},
		},
		tbUnLockEvent = 
		{
			{"BlackMsg", "機關人出現，不要與其接觸嘗試破壞其陣型！"},	
			{"NpcBubbleTalk", "BOSS", "哼，就讓你嘗嘗我機關陣的威力！！", 4, 1, 1},
			{"NpcAddBuff", "BOSS", 2452, 1, 180},

			--添加锁足BUFF（不能使用轻功）
			{"AddBuff", 1457, 1, 180, 1, 0},

			{"AddNpc", 1, 1, 0, "paidui1", "RandomFuben5_5_xunluo1", false, 0, 0, 0, 0},
			{"AddNpc", 1, 1, 0, "paidui2", "RandomFuben5_5_xunluo2", false, 0, 0, 0, 0},
			{"AddNpc", 1, 1, 0, "paidui3", "RandomFuben5_5_xunluo3", false, 0, 0, 0, 0},
			{"AddNpc", 1, 1, 0, "paidui4", "RandomFuben5_5_xunluo4", false, 0, 0, 0, 0},
			{"AddNpc", 1, 1, 0, "paidui5", "RandomFuben5_5_xunluo5", false, 0, 0, 0, 0},
			{"AddNpc", 1, 1, 0, "paidui6", "RandomFuben5_5_xunluo6", false, 0, 0, 0, 0},
			{"AddNpc", 1, 1, 0, "paidui7", "RandomFuben5_5_xunluo7", false, 0, 0, 0, 0},
			{"AddNpc", 1, 1, 0, "paidui8", "RandomFuben5_5_xunluo8", false, 0, 0, 0, 0},

			--预警 
			{"NpcAddBuff", "paidui1", 1883, 1, 150},
			{"NpcAddBuff", "paidui2", 1883, 1, 150},
			{"NpcAddBuff", "paidui3", 1883, 1, 150},
			{"NpcAddBuff", "paidui4", 1883, 1, 150},
			{"NpcAddBuff", "paidui5", 1883, 1, 150},
			{"NpcAddBuff", "paidui6", 1883, 1, 150},
			{"NpcAddBuff", "paidui7", 1883, 1, 150},
			{"NpcAddBuff", "paidui8", 1883, 1, 150},


			--开始巡逻
			{"ChangeNpcAi", "paidui1", "Move", "Path1", 0, 0, 0, 1, 0},
			{"ChangeNpcAi", "paidui2", "Move", "Path2", 0, 0, 0, 1, 0},
			{"ChangeNpcAi", "paidui3", "Move", "Path3", 0, 0, 0, 1, 0},
			{"ChangeNpcAi", "paidui4", "Move", "Path4", 0, 0, 0, 1, 0},
			{"ChangeNpcAi", "paidui5", "Move", "Path5", 0, 0, 0, 1, 0},
			{"ChangeNpcAi", "paidui6", "Move", "Path6", 0, 0, 0, 1, 0},
			{"ChangeNpcAi", "paidui7", "Move", "Path7", 0, 0, 0, 1, 0},
			{"ChangeNpcAi", "paidui8", "Move", "Path8", 0, 0, 0, 1, 0},

			--火炮	
			{"AddNpc", 2, 1, 32, "Paoche", "RandomFuben5_5_paoche1", false, 0, 0, 0, 0},
			{"AddNpc", 2, 1, 33, "Paoche", "RandomFuben5_5_paoche2", false, 0, 0, 0, 0},
			{"AddNpc", 2, 1, 34, "Paoche", "RandomFuben5_5_paoche3", false, 0, 0, 0, 0},
			{"AddNpc", 2, 1, 35, "Paoche", "RandomFuben5_5_paoche4", false, 0, 0, 0, 0},
		},
	},
	[31] = {nTime = 4, nNum = 0,
		tbPrelock = {30},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"BlackMsg", "炮車出現！擊殺炮車後可操控炮車攻擊敵人！"},
		},
	},
	[32] = {nTime = 0, nNum = 1,
		tbPrelock = {31},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{			
			{"AddNpc", 3, 1, 0, "Paoche1", "RandomFuben5_5_paoche1", false, 0, 0, 0, 0},
		},
	},
	[33] = {nTime = 0, nNum = 1,
		tbPrelock = {31},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"AddNpc", 3, 1, 0, "Paoche1", "RandomFuben5_5_paoche2", false, 0, 0, 0, 0},
		},
	},
	[34] = {nTime = 0, nNum = 1,
		tbPrelock = {31},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"AddNpc", 3, 1, 0, "Paoche1", "RandomFuben5_5_paoche3", false, 0, 0, 0, 0},
		},
	},
	[35] = {nTime = 0, nNum = 1,
		tbPrelock = {31},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"AddNpc", 3, 1, 0, "Paoche1", "RandomFuben5_5_paoche4", false, 0, 0, 0, 0},
		},
	},
	[36] = {nTime = 0, nNum = 1,
		tbPrelock = {{32, 33, 34, 35}},
		tbStartEvent = 
		{
			{"BlackMsg", "操縱炮車攻擊機關人並破壞它們的陣型！"},
		},
		tbUnLockEvent = 
		{			
		},
	},
	[37] = {nTime = 39, nNum = 0,
		tbPrelock = {30},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			--删除炮车 & 放技能NPC
			{"DelNpc", "Paoche"},
			{"DelNpc", "Paoche1"},
			{"DelNpc", "SkillNpc1"},
			{"DelNpc", "SkillNpc2"},
			{"DelNpc", "SkillNpc3"},
			{"DelNpc", "SkillNpc4"},
			{"DelNpc", "SkillNpc5"},
			{"DelNpc", "SkillNpc6"},
			{"DelNpc", "SkillNpc7"},
			{"DelNpc", "SkillNpc8"},

			--移除锁足BUFF
			{"RemovePlayerSkillState", 1457},

			--移除炮车变身BUFF
			{"RemovePlayerSkillState", 2217},

			{"SetAiActive", "BOSS", 1},
			{"CloseCycle", "cycle_1"},
		},
	},
----------------------列阵枪毙（第二次）------------------------------
	[38] = {nTime = 0, nNum = 1,
		tbPrelock = {3},
		tbStartEvent = 
		{
			{"NpcHpUnlock", "BOSS", 38, 40},
		},
		tbUnLockEvent = 
		{
			{"BlackMsg", "機關人出現，不要與其接觸嘗試破壞其陣型！"},	
			{"NpcBubbleTalk", "BOSS", "哼，就讓你嘗嘗我機關陣的威力！！", 4, 2, 1},	
			{"NpcAddBuff", "BOSS", 2452, 1, 180},		

			--添加锁足BUFF（不能使用轻功）
			{"AddBuff", 1457, 1, 180, 1, 0},

			{"AddNpc", 1, 1, 0, "paidui1", "RandomFuben5_5_xunluo1", false, 0, 0, 0, 0},
			{"AddNpc", 1, 1, 0, "paidui2", "RandomFuben5_5_xunluo2", false, 0, 0, 0, 0},
			{"AddNpc", 1, 1, 0, "paidui3", "RandomFuben5_5_xunluo3", false, 0, 0, 0, 0},
			{"AddNpc", 1, 1, 0, "paidui4", "RandomFuben5_5_xunluo4", false, 0, 0, 0, 0},
			{"AddNpc", 1, 1, 0, "paidui5", "RandomFuben5_5_xunluo5", false, 0, 0, 0, 0},
			{"AddNpc", 1, 1, 0, "paidui6", "RandomFuben5_5_xunluo6", false, 0, 0, 0, 0},
			{"AddNpc", 1, 1, 0, "paidui7", "RandomFuben5_5_xunluo7", false, 0, 0, 0, 0},
			{"AddNpc", 1, 1, 0, "paidui8", "RandomFuben5_5_xunluo8", false, 0, 0, 0, 0},

			--预警 
			{"NpcAddBuff", "paidui1", 1883, 1, 150},
			{"NpcAddBuff", "paidui2", 1883, 1, 150},
			{"NpcAddBuff", "paidui3", 1883, 1, 150},
			{"NpcAddBuff", "paidui4", 1883, 1, 150},
			{"NpcAddBuff", "paidui5", 1883, 1, 150},
			{"NpcAddBuff", "paidui6", 1883, 1, 150},
			{"NpcAddBuff", "paidui7", 1883, 1, 150},
			{"NpcAddBuff", "paidui8", 1883, 1, 150},


			--开始巡逻
			{"ChangeNpcAi", "paidui1", "Move", "Path1", 0, 0, 0, 1, 0},
			{"ChangeNpcAi", "paidui2", "Move", "Path2", 0, 0, 0, 1, 0},
			{"ChangeNpcAi", "paidui3", "Move", "Path3", 0, 0, 0, 1, 0},
			{"ChangeNpcAi", "paidui4", "Move", "Path4", 0, 0, 0, 1, 0},
			{"ChangeNpcAi", "paidui5", "Move", "Path5", 0, 0, 0, 1, 0},
			{"ChangeNpcAi", "paidui6", "Move", "Path6", 0, 0, 0, 1, 0},
			{"ChangeNpcAi", "paidui7", "Move", "Path7", 0, 0, 0, 1, 0},
			{"ChangeNpcAi", "paidui8", "Move", "Path8", 0, 0, 0, 1, 0},

			--火炮	
			{"AddNpc", 2, 1, 40, "Paoche", "RandomFuben5_5_paoche1", false, 0, 0, 0, 0},
			{"AddNpc", 2, 1, 41, "Paoche", "RandomFuben5_5_paoche2", false, 0, 0, 0, 0},
			{"AddNpc", 2, 1, 42, "Paoche", "RandomFuben5_5_paoche3", false, 0, 0, 0, 0},
			{"AddNpc", 2, 1, 43, "Paoche", "RandomFuben5_5_paoche4", false, 0, 0, 0, 0},
		},
	},
	[39] = {nTime = 4, nNum = 0,
		tbPrelock = {38},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"BlackMsg", "炮車出現！擊殺炮車後可操控炮車攻擊敵人！"},
		},
	},	
	[40] = {nTime = 0, nNum = 1,
		tbPrelock = {39},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{			
			{"AddNpc", 3, 1, 0, "Paoche1", "RandomFuben5_5_paoche1", false, 0, 0, 0, 0},
		},
	},
	[41] = {nTime = 0, nNum = 1,
		tbPrelock = {39},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"AddNpc", 3, 1, 0, "Paoche1", "RandomFuben5_5_paoche2", false, 0, 0, 0, 0},
		},
	},
	[42] = {nTime = 0, nNum = 1,
		tbPrelock = {39},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"AddNpc", 3, 1, 0, "Paoche1", "RandomFuben5_5_paoche3", false, 0, 0, 0, 0},
		},
	},
	[43] = {nTime = 0, nNum = 1,
		tbPrelock = {39},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"AddNpc", 3, 1, 0, "Paoche1", "RandomFuben5_5_paoche4", false, 0, 0, 0, 0},
		},
	},
	[44] = {nTime = 0, nNum = 1,
		tbPrelock = {{40, 41, 42, 43}},
		tbStartEvent = 
		{
			{"BlackMsg", "操縱炮車攻擊機關人並破壞它們的陣型！"},
		},
		tbUnLockEvent = 
		{			
		},
	},
	[45] = {nTime = 39, nNum = 0,
		tbPrelock = {38},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			--删除炮车 & 放技能NPC
			{"DelNpc", "Paoche"},
			{"DelNpc", "Paoche1"},
			{"DelNpc", "SkillNpc1"},
			{"DelNpc", "SkillNpc2"},
			{"DelNpc", "SkillNpc3"},
			{"DelNpc", "SkillNpc4"},
			{"DelNpc", "SkillNpc5"},
			{"DelNpc", "SkillNpc6"},
			{"DelNpc", "SkillNpc7"},
			{"DelNpc", "SkillNpc8"},

			--移除锁足BUFF
			{"RemovePlayerSkillState", 1457},

			--移除炮车变身BUFF
			{"RemovePlayerSkillState", 2217},
			
			{"SetAiActive", "BOSS", 1},
			{"CloseCycle", "cycle_1"},
		},
	},

	--南宫灭阶段放技能（阶段一）
	[50] = {nTime = 0, nNum = 1,
		tbPrelock = {30},
		tbStartEvent = 
		{
			{"ChangeNpcAi", "BOSS", "Move", "Path9", 50, 0, 0, 0, 0},

			--放技能NPC
			{"AddNpc", 6, 1, 0, "SkillNpc1", "SkillNpc1", false, 0, 0, 0, 0},	
			{"AddNpc", 6, 1, 0, "SkillNpc2", "SkillNpc2", false, 8, 0, 0, 0},	
			{"AddNpc", 6, 1, 0, "SkillNpc3", "SkillNpc3", false, 16, 0, 0, 0},	
			{"AddNpc", 6, 1, 0, "SkillNpc4", "SkillNpc4", false, 24, 0, 0, 0},
			{"AddNpc", 6, 1, 0, "SkillNpc5", "SkillNpc5", false, 32, 0, 0, 0},	
			{"AddNpc", 6, 1, 0, "SkillNpc6", "SkillNpc6", false, 40, 0, 0, 0},	
			{"AddNpc", 6, 1, 0, "SkillNpc7", "SkillNpc7", false, 48, 0, 0, 0},	
			{"AddNpc", 6, 1, 0, "SkillNpc8", "SkillNpc8", false, 56, 0, 0, 0},
		},
		tbUnLockEvent = 
		{
			{"NpcRemoveBuff", "BOSS", 2452},
			{"SetAiActive", "BOSS", 0},

			{"CastSkill", "SkillNpc1", 2384, 10, 4784, 4053}, 
			{"CastSkill", "SkillNpc2", 2384, 10, 4840, 4003}, 
			{"CastSkill", "SkillNpc3", 2384, 10, 4870, 3947}, 
			{"CastSkill", "SkillNpc4", 2384, 10, 4837, 3887}, 
			{"CastSkill", "SkillNpc5", 2384, 10, 4784, 3854}, 
			{"CastSkill", "SkillNpc6", 2384, 10, 4726, 3887}, 
			{"CastSkill", "SkillNpc7", 2384, 10, 4701, 3942}, 
			{"CastSkill", "SkillNpc8", 2384, 10, 4726, 3997}, 

			{"DoCommonAct", "BOSS", 16, 0, 0, 0},
			{"StartTimeCycle", "cycle_1", 5, 100, 
				{"CastSkill", "SkillNpc1", 2384, 10, 4784, 4053}, 
				{"CastSkill", "SkillNpc2", 2384, 10, 4840, 4003}, 
				{"CastSkill", "SkillNpc3", 2384, 10, 4870, 3947}, 
				{"CastSkill", "SkillNpc4", 2384, 10, 4837, 3887}, 
				{"CastSkill", "SkillNpc5", 2384, 10, 4784, 3854}, 
				{"CastSkill", "SkillNpc6", 2384, 10, 4726, 3887}, 
				{"CastSkill", "SkillNpc7", 2384, 10, 4701, 3942}, 
				{"CastSkill", "SkillNpc8", 2384, 10, 4726, 3997}, 
				{"DoCommonAct", "BOSS", 16, 0, 0, 0},
			},
		},
	},

	--南宫灭阶段放技能（阶段二）
	[51] = {nTime = 0, nNum = 1,
		tbPrelock = {38},
		tbStartEvent = 
		{
			{"ChangeNpcAi", "BOSS", "Move", "Path9", 51, 0, 0, 0, 0},

			--放技能NPC
			{"AddNpc", 6, 1, 0, "SkillNpc1", "SkillNpc1", false, 0, 0, 0, 0},	
			{"AddNpc", 6, 1, 0, "SkillNpc2", "SkillNpc2", false, 8, 0, 0, 0},	
			{"AddNpc", 6, 1, 0, "SkillNpc3", "SkillNpc3", false, 16, 0, 0, 0},	
			{"AddNpc", 6, 1, 0, "SkillNpc4", "SkillNpc4", false, 24, 0, 0, 0},
			{"AddNpc", 6, 1, 0, "SkillNpc5", "SkillNpc5", false, 32, 0, 0, 0},	
			{"AddNpc", 6, 1, 0, "SkillNpc6", "SkillNpc6", false, 40, 0, 0, 0},	
			{"AddNpc", 6, 1, 0, "SkillNpc7", "SkillNpc7", false, 48, 0, 0, 0},	
			{"AddNpc", 6, 1, 0, "SkillNpc8", "SkillNpc8", false, 56, 0, 0, 0},
		},
		tbUnLockEvent = 
		{
			{"NpcRemoveBuff", "BOSS", 2452},
			{"SetAiActive", "BOSS", 0},			

			{"CastSkill", "SkillNpc1", 2384, 10, 4784, 4053}, 
			{"CastSkill", "SkillNpc2", 2384, 10, 4840, 4003}, 
			{"CastSkill", "SkillNpc3", 2384, 10, 4870, 3947}, 
			{"CastSkill", "SkillNpc4", 2384, 10, 4837, 3887}, 
			{"CastSkill", "SkillNpc5", 2384, 10, 4784, 3854}, 
			{"CastSkill", "SkillNpc6", 2384, 10, 4726, 3887}, 
			{"CastSkill", "SkillNpc7", 2384, 10, 4701, 3942}, 
			{"CastSkill", "SkillNpc8", 2384, 10, 4726, 3997}, 

			{"DoCommonAct", "BOSS", 16, 0, 0, 0},
			{"StartTimeCycle", "cycle_1", 5, 100, 
				{"CastSkill", "SkillNpc1", 2384, 10, 4784, 4053}, 
				{"CastSkill", "SkillNpc2", 2384, 10, 4840, 4003}, 
				{"CastSkill", "SkillNpc3", 2384, 10, 4870, 3947}, 
				{"CastSkill", "SkillNpc4", 2384, 10, 4837, 3887}, 
				{"CastSkill", "SkillNpc5", 2384, 10, 4784, 3854}, 
				{"CastSkill", "SkillNpc6", 2384, 10, 4726, 3887}, 
				{"CastSkill", "SkillNpc7", 2384, 10, 4701, 3942}, 
				{"CastSkill", "SkillNpc8", 2384, 10, 4726, 3997}, 
				{"DoCommonAct", "BOSS", 16, 0, 0, 0},
			},
		},
	},
}
-----------------卡片收集-------------------
	-- [100] = {nTime = 0, nNum = 4,
	-- 	tbPrelock = {3},
	-- 	tbStartEvent = 
	-- 	{
	-- 	},
	-- 	tbUnLockEvent = 
	-- 	{
	-- 		{"RaiseEvent", "DropCard", 2627, -1},		
	-- 	},
	-- },

