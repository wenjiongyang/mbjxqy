
local tbFubenSetting = Fuben.RandomFuben:GetRandomFubenSetting("f_10");

tbFubenSetting.tbMultiBeginPoint = {{3892, 1974},{4181, 2014},{3992, 1691},{4253, 1769}}	-- 副本出生点
tbFubenSetting.tbTempRevivePoint = {4066, 1872}
tbFubenSetting.nStartDir		 = 8;


tbFubenSetting.NPC = 
{
	[1] = {nTemplate = 1813, nLevel = -1, nSeries = -1}, --无忧教弟子
	[2] = {nTemplate = 1814, nLevel = -1, nSeries = -1}, --无忧教精英
	[3] = {nTemplate = 1815, nLevel = -1, nSeries = -1}, --无忧教高手
	[4] = {nTemplate = 104,  nLevel = -1, nSeries = 0},  --动态障碍墙
	[5] = {nTemplate = 1825, nLevel = -1, nSeries = 0},  --清晓师太（稀有）
	[6] = {nTemplate = 2421, nLevel = -1, nSeries = 0}, --妖道
	[7] = {nTemplate = 2473, nLevel = -1, nSeries = 0}, --招魂幡
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
			{"AddNpc", 4, 1, 1, "wall", "wall_1_1",false, 14},
			{"OpenWindow", "LingJueFengLayerPanel", "Info",3, 9, "第六層 桃源小徑"},
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
			{"SetTargetPos", 3850, 3006},


		},
	},
	[3] = {nTime = 0, nNum = 1,
		tbPrelock = {2},
		tbStartEvent = 
		{
			{"TrapUnlock", "TrapLock1", 3},
		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},
			{"SetFubenProgress", 40, "擊敗無憂教弟子"},

			--无忧教弟子 &　无忧教精英
			{"AddNpc", 1, 5, 4, "guaiwu", "RandomFuben6_10_1", false, 0, 0, 0, 0},	
			{"AddNpc", 2, 1, 4, "Elite_1", "RandomFuben6_10_2", false, 0, 1, 9011, 1},	
			{"AddNpc", 1, 8, 4, "guaiwu", "RandomFuben6_10_3", false, 0, 4, 0, 0},	
			{"NpcBubbleTalk", "guaiwu", "哈哈，又有肥羊送上門來了，兄弟們抄傢伙一起上啊！！", 4, 0, 1},	
		},
	},
	[4] = {nTime = 0, nNum = 14,
		tbPrelock = {3},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"SetFubenProgress", 80, "擊敗無憂教高手"},

			--无忧教高手 &  无忧教弟子  
			{"NpcBubbleTalk", "Leader", "看來你們還有些本事，那就讓我來收拾你們吧！", 5, 3, 1},
			{"AddNpc", 3, 1, 14, "Leader", "RandomFuben6_10_Leader1", false, 0, 1, 9011, 1},	
			{"AddNpc", 1, 5, 0, "guaiwu", "RandomFuben6_10_4", false, 0, 4, 9008, 0.5},	
			--{"AddNpc", 1, 5, 5, "guaiwu", "RandomFuben6_10_5", false, 0, 7, 9008, 0.5},	
		},
	},
	[11] = {nTime = 5, nNum = 0,
		tbPrelock = {4},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{	
			{"BlackMsg", "阻止妖道做法！"},
			{"AddNpc", 6, 1, 5, "jiguan", "RandomFuben6_10_6", false, 0, 0, 0, 0},
			{"AddNpc", 7, 1, 0, "qizi", "RandomFuben6_10_7", false, 11, 0, 0, 0},
			{"ChangeNpcAi", "jiguan", "Move", "Path2", 12, 0, 0, 0, 0},
			--稀有几率
			{"Random", {350000, 30}},
		},
	},
	[12] = {nTime = 0, nNum = 1,
		tbPrelock = {11},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{	
			{"CastSkill", "jiguan", 1523, 1, -1, -1},
		},
	},
	[13] = {nTime = 2, nNum = 0,
		tbPrelock = {12},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{	
			{"CloseLock", 5},
			{"BlackMsg", "糟了，又複製出一個無憂教組長！"},
			{"AddNpc", 2, 1, 15, "Elite_1", "RandomFuben6_10_7", false, 0, 1, 9011, 1},
		},
	},
	[5] = {nTime = 0, nNum = 1,
		tbPrelock = {11, 14},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{	
		},
	},
	[14] = {nTime = 0, nNum = 1,
		tbPrelock = {4},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{	
		},
	},
	[15] = {nTime = 0, nNum = 1,
		tbPrelock = {13, 14},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{	
		},
	},

	-------------胜利判定------------------------
	[8] = {nTime = 0.1, nNum = 0,
		tbPrelock = {{5, 15}},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
		},
	},
	[6] = {nTime = 0.1, nNum = 0,
		tbPrelock = {8},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{	
			--掉落房间奖励
			{"RaiseEvent", "DropAward", "Setting/Fuben/RandomFuben/HouseAward/F.tab", 3415, 4803},
			{"RaiseEvent", "DropAward", "Setting/Fuben/RandomFuben/HouseAward/F.tab", 3675, 4789},
			{"RaiseEvent", "DropAward", "Setting/Fuben/RandomFuben/HouseAward/F.tab", 3234, 4636},
			{"RaiseEvent", "DropAward", "Setting/Fuben/RandomFuben/HouseAward/F.tab", 3543, 4629},

			{"SetFubenProgress", 100, "擊敗無憂教高手"},
			
			--判断模式篝火&踢出
			{"IfCase", "self.nFubenLevel == 2",
				{"AddSimpleNpc", 1611, 3530, 4169, 0},
				{"RaiseEvent", "KickOutAllPlayer", 40},
			},
			--判断模式获得积分
			{"RaiseEvent", "AddMissionScore", "f_score_win"},

			{"OpenWindow", "LingJueFengLayerPanel", "Win"},
			{"GameWin"},
		},
	},
	-------------闯关时间------------------------
	[7] = {nTime = "f_10_time", nNum = 0,    --总计时
		tbPrelock = {2},
		tbStartEvent = 
		{
			{"SetShowTime", 7},
		},
		tbUnLockEvent = 
		{
			{"SetFubenProgress", -1, "闖關失敗"},
			{"BlackMsg", "這群惡徒武藝高強，還是先撤退為妙！"},

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
---------------------稀有锁---------------------------------
	[30] = {nTime = 0, nNum = 1,
		tbPrelock = {},
		tbStartEvent = 
		{
			--清晓师太
			{"AddNpc", 5, 1, 32, "Qingxiao", "RandomFuben6_10_Xiyou",false, 0 , 0, 0, 0},
			{"ChangeNpcAi", "Qingxiao", "Move", "Path1", 0, 1, 1, 0, 0},
			{"NpcBubbleTalk", "Qingxiao", "這就是邪教中的招魂大法，速速擊殺妖道！", 4, 1, 1},
			{"UnLock", 30},
		},
		tbUnLockEvent = 
		{
		},
	},
	[31] = {nTime = 0.1, nNum = 0,
		tbPrelock = {30, 8},
		tbStartEvent = 
		{
			
		},
		tbUnLockEvent = 
		{	
			{"RaiseEvent", "DropAward", "Setting/Npc/DropFile/RandomFuben/House_F/qingxiaoshitai.tab", 3204, 4233},
			{"RaiseEvent", "DropAward", "Setting/Npc/DropFile/RandomFuben/House_F/qingxiaoshitai.tab", 3539, 4249},
			{"RaiseEvent", "DropAward", "Setting/Npc/DropFile/RandomFuben/House_F/qingxiaoshitai.tab", 3224, 4009},
			{"RaiseEvent", "DropAward", "Setting/Npc/DropFile/RandomFuben/House_F/qingxiaoshitai.tab", 3459, 3993},

			{"RaiseEvent", "DropCard", 2639, 350000},	--卡片收集掉落			
		},
	},

	--清晓师太死亡锁
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

