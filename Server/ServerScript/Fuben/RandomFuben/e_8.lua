
local tbFubenSetting = Fuben.RandomFuben:GetRandomFubenSetting("e_8");

tbFubenSetting.tbMultiBeginPoint = {{4997, 4649},{5246, 4439},{5218, 4884},{5442, 4695}}	-- 副本出生点
tbFubenSetting.tbTempRevivePoint = {5228, 4642};
tbFubenSetting.nStartDir		 = 40;


tbFubenSetting.NPC = 
{
	[1] = {nTemplate = 1593, nLevel = -1, nSeries = -1}, --蒙面杀手
	[2] = {nTemplate = 1594, nLevel = -1, nSeries = -1}, --杀手精英
	[3] = {nTemplate = 1595, nLevel = -1, nSeries = -1}, --杀手头目
	[4] = {nTemplate = 104,  nLevel = -1, nSeries = 0},  --动态障碍墙
	[5] = {nTemplate = 1596, nLevel = -1, nSeries = 0},  --纳兰真
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
			{"AddNpc", 4, 2, 1, "wall", "wall_1_1",false, 24},
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
			{"SetTargetPos", 4525, 3857},
		},
	},
	[3] = {nTime = 0, nNum = 1,
		tbPrelock = {2},
		tbStartEvent = 
		{
			{"ChangeFightState", 1},
			{"SetFubenProgress", 0, "探索凌絕峰"},
			{"TrapUnlock", "TrapLock1", 3},

			--纳兰真
			{"AddNpc", 5, 1, 0, "Nalanzhen", "RandomFuben4_8_nalanzhen", false, 40, 0, 0, 0},
		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},
			{"SetFubenProgress", 20, "探索凌絕峰"},
			{"NpcBubbleTalk", "Nalanzhen", "沒想到在這峰頂內竟會遇到你們，既然如此那便一同前行吧！", 4, 0, 1},
			{"SetTargetPos", 4083, 3452},	
			{"ChangeNpcAi", "Nalanzhen", "Move", "Path1", 0, 1, 1, 0, 0},	
		},
	},
	[4] = {nTime = 3, nNum = 0,
		tbPrelock = {3},
		tbStartEvent = 
		{	
			{"TrapUnlock", "TrapLock2", 4},	
		},
		tbUnLockEvent = 
		{	
			{"ClearTargetPos"},
			{"SetFubenProgress", 40, "擊敗蒙面刺客"},
			{"NpcBubbleTalk", "Nalanzhen", "沒想到這裡竟然也會有敵人！", 4, 0, 1},

			--蒙面杀手 & 杀手
			{"AddNpc", 1, 6, 5, "guaiwu", "RandomFuben4_8_1", false, 0, 0, 0, 0},	
			{"AddNpc", 2, 1, 5, "Elite", "RandomFuben4_8_Elite", false, 0, 1, 9011, 1},	
		},
	},
	[5] = {nTime = 0, nNum = 7,
		tbPrelock = {4},
		tbStartEvent = 
		{				
		},
		tbUnLockEvent = 
		{	
			{"SetTargetPos", 3155, 2574},
			{"SetFubenProgress", 60, "探索凌絕峰"},
			{"NpcBubbleTalk", "Nalanzhen", "我們繼續前進吧！！", 4, 0, 1},
			{"ChangeNpcAi", "Nalanzhen", "Move", "Path2", 0, 1, 1, 0, 0},
		},
	},
	[6] = {nTime = 0, nNum = 1,
		tbPrelock = {5},
		tbStartEvent = 
		{	
			{"TrapUnlock", "TrapLock3", 6},	
		},
		tbUnLockEvent = 
		{	
			{"ClearTargetPos"},
			{"SetFubenProgress", 80, "擊敗刺客頭目"},

			--蒙面杀手 & 杀手
			{"AddNpc", 3, 1, 7, "guaiwu", "RandomFuben4_8_BOSS", false, 0, 1, 9011, 1},	
			{"AddNpc", 1, 6, 7, "guaiwu", "RandomFuben4_8_2", false, 0, 3, 9008, 0.5},	
		},
	},

-------------胜利判定------------------------
	[7] = {nTime = 0, nNum = 7,
		tbPrelock = {6},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{	
			--掉落首领奖励 ——  纳兰真
			{"RaiseEvent", "DropAward", "Setting/Fuben/RandomFuben/HouseAward/E.tab", 2752, 2430},
			{"RaiseEvent", "DropAward", "Setting/Fuben/RandomFuben/HouseAward/E.tab", 2991, 2284},
			{"RaiseEvent", "DropAward", "Setting/Fuben/RandomFuben/HouseAward/E.tab", 2632, 2249},
			{"RaiseEvent", "DropAward", "Setting/Fuben/RandomFuben/HouseAward/E.tab", 2840, 2231},

			{"SetFubenProgress", 100, "擊敗刺客頭目"},

			--判断模式篝火&踢出
			{"IfCase", "self.nFubenLevel == 1",
				{"AddSimpleNpc", 1611, 3026, 2435, 0},
				{"RaiseEvent", "KickOutAllPlayer", 40},	
			},

			--判断模式获得积分
			{"RaiseEvent", "AddMissionScore", "e_score_win"},

			{"OpenWindow", "LingJueFengLayerPanel", "Win"},
			{"GameWin"},
		},
	},
-------------闯关时间------------------------	
	[8] = {nTime = "e_8_time", nNum = 0,
		tbPrelock = {2},
		tbStartEvent = 
		{
			{"SetShowTime", 8},
		},
		tbUnLockEvent = 
		{
			{"SetFubenProgress", -1, "闖關失敗"},
			{"BlackMsg", "這群刺客的武功果然高強，還是撤退為妙！"},
			
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
