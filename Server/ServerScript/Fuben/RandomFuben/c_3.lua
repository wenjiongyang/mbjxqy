
local tbFubenSetting = Fuben.RandomFuben:GetRandomFubenSetting("c_3");

tbFubenSetting.tbMultiBeginPoint = {{1823, 1001},{2151, 849},{1655, 722},{2018, 546}}	-- 副本出生点
tbFubenSetting.tbTempRevivePoint = {1929, 768}
tbFubenSetting.nStartDir		 = 8;


--NPC模版ID，NPC等级，NPC五行；

--[[

442  姬御天

]]

tbFubenSetting.NPC = 
{
	[1] = {nTemplate = 1624,  nLevel = -1, nSeries = -1},	-- 江湖流寇
	[2] = {nTemplate = 1625,  nLevel = -1, nSeries = -1},	-- 劲弩手
	[3] = {nTemplate = 1569,  nLevel = -1, nSeries = -1},	-- 无名壮汉
	[4] = {nTemplate = 104,   nLevel = -1, nSeries = 0},    --动态障碍墙
	[5] = {nTemplate = 1570,  nLevel = -1, nSeries = 0},	-- 唐潇(稀有)

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
			{"SetTargetPos", 2378, 2091},

			--稀有几率
			{"Random", {350000, 30}},
		},
	},
	[3] = {nTime = 0, nNum = 1,
		tbPrelock = {2},
		tbStartEvent = 
		{
			{"SetFubenProgress", 0, "探索凌絕峰"},
			{"TrapUnlock", "TrapLock1", 3},
		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},
			{"SetFubenProgress", 30, "擊敗五色教弟子"},

			--江湖流寇  & 劲弩手
			{"AddNpc", 1, 4, 4, "guaiwu", "RandomFuben3_3_1", false, 0, 0, 0, 0},
			{"AddNpc", 2, 6, 4, "guaiwu", "RandomFuben3_3_2", false, 0, 2, 9008, 0.5},
			{"NpcBubbleTalk", "guaiwu", "來者何人，還不速速退去！莫非想找死不成？", 4, 2, 1},
		},
	},
	[4] = {nTime = 0, nNum = 10,
		tbPrelock = {3},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			--掉落房间奖励
			{"RaiseEvent", "DropAward", "Setting/Fuben/RandomFuben/HouseAward/C.tab", 2779, 3014},
			{"RaiseEvent", "DropAward", "Setting/Fuben/RandomFuben/HouseAward/C.tab", 3000, 2920},

			{"SetFubenProgress", 50, "探索凌絕峰"},
			{"ClearTargetPos"},
			{"SetTargetPos", 3095, 3217},
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
			{"ClearTargetPos"},
			{"SetFubenProgress", 70, "擊敗無名壯漢"},

			--无名壮汉 & 江湖流寇
			{"AddNpc", 3, 1, 6, "BOSS", "RandomFuben3_3_BOSS", false, 0, 1, 9011, 1},	
			{"AddNpc", 1, 8, 6, "guaiwu", "RandomFuben3_3_3", false, 0, 4, 9008, 0.5},
			{"NpcBubbleTalk", "BOSS", "不知死活的傢伙，既然來了那就留下來吧！", 4, 3, 1},
	
		},
	},
-------------胜利判定------------------------
	[6] = {nTime = 0, nNum = 9,
		tbPrelock = {5},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
		},
	},
	[7] = {nTime = 0.1, nNum = 0,
		tbPrelock = {6},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			--掉落房间奖励
			{"RaiseEvent", "DropAward", "Setting/Fuben/RandomFuben/HouseAward/C.tab", 3356, 3852},
			{"RaiseEvent", "DropAward", "Setting/Fuben/RandomFuben/HouseAward/C.tab", 3651, 3669},

			--判断模式获得积分
			{"RaiseEvent", "AddMissionScore", "c_score_win"},
			
			{"SetFubenProgress", 100, "擊敗無名壯漢"},
			{"OpenWindow", "LingJueFengLayerPanel", "Win"},
			{"GameWin"},
		},
	},
-------------闯关时间和积分------------------------
	[8] = {nTime = "c_3_time", nNum = 0,
		tbPrelock = {2},
		tbStartEvent = 
		{
			{"SetShowTime", 8},
		},
		tbUnLockEvent = 
		{
			{"BlackMsg", "這壯漢武功高強不能力敵，還是先撤退吧！"},

			--判断模式获得积分
			{"RaiseEvent", "AddMissionScore", "c_score_lost"},
	
			{"OpenWindow", "LingJueFengLayerPanel", "Fail"},
			{"GameLost"},
		},
	},

	--稀有锁
	[30] = {nTime = 0, nNum = 1,
		tbPrelock = {},
		tbStartEvent = 
		{
			{"TrapUnlock", "Xiyou", 30},

			--唐潇
			{"AddNpc", 5, 1, 33, "Tangxiao", "RandomFuben3_3_Xiyou",false, 3 , 0, 0, 0},
		},
		tbUnLockEvent = 
		{
			{"NpcBubbleTalk", "Tangxiao", "沒想到會在這裡碰到你們，我們一起前進吧！", 4, 1, 1},
			{"ChangeNpcAi", "Tangxiao", "Move", "Path1", 0, 1, 1, 0, 0},	
		},
	},
	[31] = {nTime = 1, nNum = 0,
		tbPrelock = {30, 4},
		tbStartEvent = 
		{
			
		},
		tbUnLockEvent = 
		{
			{"ChangeNpcAi", "Tangxiao", "Move", "Path2", 0, 1, 1, 0, 0},	
		},
	},
	[32] = {nTime = 1, nNum = 0,
		tbPrelock = {31, 6},
		tbStartEvent = 
		{
			{"RaiseEvent", "DropAward", "Setting/Npc/DropFile/RandomFuben/House_C/tangxiao.tab", 3356, 3852},
			{"RaiseEvent", "DropAward", "Setting/Npc/DropFile/RandomFuben/House_C/tangxiao.tab", 3651, 3669},
			{"RaiseEvent", "DropAward", "Setting/Npc/DropFile/RandomFuben/House_C/tangxiao.tab", 3655, 3913},
			
			{"RaiseEvent", "DropCard", 2597, 350000},	--卡片收集掉落
		},
		tbUnLockEvent = 
		{				
		},
	},

	--唐潇死亡锁
	[33] = {nTime = 0, nNum = 1,
		tbPrelock = {30},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"CloseLock", 32},
		},
	},
}

