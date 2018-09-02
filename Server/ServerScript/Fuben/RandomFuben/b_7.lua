
local tbFubenSetting = Fuben.RandomFuben:GetRandomFubenSetting("b_7");

tbFubenSetting.tbMultiBeginPoint = {{1705, 1459},{1961, 1323},{1539, 1177},{1776, 1009}}	-- 副本出生点
tbFubenSetting.tbTempRevivePoint = {1757, 1255};
tbFubenSetting.nStartDir		 = 8;

--NPC模版ID，NPC等级，NPC五行；

--[[

]]


tbFubenSetting.NPC = 
{
	[1] = {nTemplate = 1560,  nLevel = -1, nSeries = -1}, --武林恶徒
	[2] = {nTemplate = 1561,  nLevel = -1, nSeries = -1}, --恶徒头目
	[3] = {nTemplate = 104,   nLevel = -1, nSeries = 0},  --动态障碍墙
	[4] = {nTemplate = 1553,  nLevel = -1, nSeries = 0},  --小殷方（稀有）
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
			{"AddNpc", 3, 2, 1, "wall", "wall_1_1",false, 23},
			{"OpenWindow", "LingJueFengLayerPanel", "Info",3, 9, "第二層 後山小道"},
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
			{"ShowTaskDialog", 10001, false},
			{"DoDeath", "wall"},
			{"OpenDynamicObstacle", "ops1"},			
			{"SetTargetPos", 2447, 2239},

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
			{"SetFubenProgress", 30, "擊退武林惡徒"},	

			--武林恶徒
			{"AddNpc", 1, 5, 4, "guaiwu", "RandomFuben2_7_1", false, 0, 0, 0, 0},			
			{"AddNpc", 1, 4, 4, "guaiwu", "RandomFuben2_7_2", false, 0, 3, 9008, 0.5},		
			{"AddNpc", 2, 1, 4, "Elite", "RandomFuben2_7_Elite1", false, 0, 0, 0, 0},	
			{"NpcBubbleTalk", "guaiwu", "哈哈哈，又有肥羊上門了！兄弟們一起上啊！", 4, 1, 1},
		},
	},
	[4] = {nTime = 0, nNum = 10,
		tbPrelock = {2},
		tbStartEvent = 
		{	
		},
		tbUnLockEvent = 
		{
			--掉落房间奖励
			{"RaiseEvent", "DropAward", "Setting/Fuben/RandomFuben/HouseAward/B.tab", 2525, 3048},
			{"RaiseEvent", "DropAward", "Setting/Fuben/RandomFuben/HouseAward/B.tab", 2715, 2886},
			{"SetFubenProgress", 60, "探索凌絕峰"},
			{"SetTargetPos", 4662, 2573},
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
			{"SetFubenProgress", 80, "擊退武林惡徒"},
			{"ClearTargetPos"},

			--恶徒头目 & 武林恶徒
			{"AddNpc", 1, 5, 6, "guaiwu", "RandomFuben2_7_3", false, 0, 0, 0, 0},			
			{"AddNpc", 1, 4, 6, "guaiwu", "RandomFuben2_7_4", false, 0, 3, 9008, 0.5},		
			{"AddNpc", 2, 1, 6, "Elite", "RandomFuben2_7_Elite2", false, 0, 0, 0, 0},	
		},
	},

-------------胜利判定------------------------
	[6] = {nTime = 0, nNum = 10,
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
			{"RaiseEvent", "DropAward", "Setting/Fuben/RandomFuben/HouseAward/B.tab", 5760, 2799},
			{"RaiseEvent", "DropAward", "Setting/Fuben/RandomFuben/HouseAward/B.tab", 5773, 2536},

			{"SetFubenProgress", 100, "擊退惡徒頭目"},	

			--判断模式获得积分
			{"RaiseEvent", "AddMissionScore", "b_score_win"},
			
			{"OpenWindow", "LingJueFengLayerPanel", "Win"},
			{"GameWin"},
		},
	},
-------------闯关时间------------------------	
	[8] = {nTime = "b_7_time", nNum = 0,
		tbPrelock = {2},
		tbStartEvent = 
		{
			{"SetShowTime", 8},
		},
		tbUnLockEvent = 
		{
			--判断模式获得积分
			{"RaiseEvent", "AddMissionScore", "b_score_lost"},

			{"BlackMsg", "這群惡徒還真是厲害，還是趕緊離去為妙！"},
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

			--殷方
			{"AddNpc", 4, 1, 33, "Yinfang", "RandomFuben2_7_Xiyou",false, 3 , 0, 0, 0},
		},
		tbUnLockEvent = 
		{
			{"NpcBubbleTalk", "Yinfang", "沒想到會在這裡碰到你們，我們一起前進吧！", 4, 0, 1},
		},
	},
	[31] = {nTime = 1, nNum = 0,
		tbPrelock = {30, 4},
		tbStartEvent = 
		{
			{"ChangeNpcAi", "Yinfang", "Move", "Path1", 0, 1, 1, 0, 0},	
		},
		tbUnLockEvent = 
		{
			
		},
	},
	[32] = {nTime = 1, nNum = 0,
		tbPrelock = {31, 6},
		tbStartEvent = 
		{
			{"RaiseEvent", "DropAward", "Setting/Npc/DropFile/RandomFuben/House_B/yinfang.tab", 5776, 2849},
			{"RaiseEvent", "DropAward", "Setting/Npc/DropFile/RandomFuben/House_B/yinfang.tab", 5779, 2531},
		},
		tbUnLockEvent = 
		{				
		},
	},

	--小殷方死亡锁
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