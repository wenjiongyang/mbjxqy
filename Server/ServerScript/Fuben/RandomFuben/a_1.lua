
local tbFubenSetting = Fuben.RandomFuben:GetRandomFubenSetting("a_1");

tbFubenSetting.tbMultiBeginPoint = {{3857, 1640},{3695, 1459},{3937, 1312},{4077, 1525}}	-- 副本出生点
tbFubenSetting.tbTempRevivePoint = {3919, 1469}
tbFubenSetting.nStartDir		 = 56;

--NPC模版ID，NPC等级，NPC五行；
--[[

]]

tbFubenSetting.NPC = 
{
	[1] = {nTemplate = 269,  nLevel = -1, nSeries = -1},  --黑熊
	[2] = {nTemplate = 1312, nLevel = -1, nSeries = -1},  --黑熊王
	[3] = {nTemplate = 104,  nLevel = -1, nSeries = 0},  --动态障碍墙
}

-- 不同门派对应 Npc索引
tbFubenSetting.tbCopyPlayer = 
{
	[1] = {nNpcIndex = 1, szName = "%s的心魔"},
	[2] = {nNpcIndex = 2, szName = "%s的幻象"},
	[3] = {nNpcIndex = 1, szName = "%s的哥哥"},
	[4] = {nNpcIndex = 1, szName = "%s的弟弟"},
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
			{"AddNpc", 3, 2, 1, "wall1", "wall_1_1",false, 43},
			{"OpenWindow", "LingJueFengLayerPanel", "Info",3, 9, "第一層 後山小道"},
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
			{"ShowTaskDialog", 10000, false},
			{"DoDeath", "wall1"},
			{"AddNpc", 3, 1, 1, "wall2", "wall_1_2",false, 44},
			{"OpenDynamicObstacle", "ops1"},
		},
	},
	[3] = {nTime = 0, nNum = 1,
		tbPrelock = {2},
		tbStartEvent = 
		{
			{"ChangeFightState", 1},
			{"TrapUnlock", "TrapLock1", 3},
			{"SetFubenProgress", 0, "探索凌絕峰"},
			{"SetTargetPos", 3220, 1966},
		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},
			{"BlackMsg", "天呐！好大的熊！牠朝著我們衝過來了！"},
			{"SetFubenProgress", 20, "擊敗黑熊"},

			--黑熊
			{"AddNpc", 1, 4, 4, "guaiwu", "RandomFuben1_1_1",false, 0 , 0, 0, 0},
		},
	},
	[4] = {nTime = 0, nNum = 4,
		tbPrelock = {3},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			--黑熊
			{"AddNpc", 1, 5, 5, "guaiwu", "RandomFuben1_1_2",false, 0 , 0, 0, 0},

			{"BlackMsg", "這後山內竟出現如此之多的黑熊，真是奇怪！"},
			{"SetFubenProgress", 40, "擊敗黑熊"},
		},
	},	
	[5] = {nTime = 0, nNum = 5,
		tbPrelock = {4},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"SetTargetPos", 1919, 3842},
			{"OpenDynamicObstacle", "ops2"},
			{"DoDeath", "wall2"},
			{"SetFubenProgress", 60, "擊敗黑熊"},

			--掉落房间奖励
			{"RaiseEvent", "DropAward", "Setting/Fuben/RandomFuben/HouseAward/A.tab", 2268, 2485},
			{"RaiseEvent", "DropAward", "Setting/Fuben/RandomFuben/HouseAward/A.tab", 2333, 2512},
		},
	},	
	[6] = {nTime = 0, nNum = 1,
		tbPrelock = {5},
		tbStartEvent = 
		{
			{"TrapUnlock", "TrapLock2", 6},
		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},
			{"SetFubenProgress", 80, "擊敗黑熊王"},		

			--黑熊王 & 黑熊
			{"AddNpc", 1, 5, 7, "guaiwu", "RandomFuben1_1_3",false, 0 , 0, 0, 0},
			{"AddNpc", 2, 1, 7, "guaiwu", "RandomFuben1_1_BOSS",false, 0 , 1, 9011, 1},
		},
	},
	[7] = {nTime = 0, nNum = 6,
		tbPrelock = {6},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{			
			--掉落房间奖励
			{"RaiseEvent", "DropAward", "Setting/Fuben/RandomFuben/HouseAward/A.tab", 2535, 4815},
			{"RaiseEvent", "DropAward", "Setting/Fuben/RandomFuben/HouseAward/A.tab", 2452, 4826},
			{"RaiseEvent", "AddMissionScore", 12},
			{"OpenWindow", "LingJueFengLayerPanel", "Win"},
			{"GameWin"},
		},
	},
	[8] = {nTime = 90, nNum = 0,
		tbPrelock = {2},
		tbStartEvent = 
		{
			{"SetShowTime", 8},
		},
		tbUnLockEvent = 
		{
			{"RaiseEvent", "AddMissionScore", 8},
			{"OpenWindow", "LingJueFengLayerPanel", "Fail"},
			{"GameLost"},
			{"BlackMsg", "這群黑熊真是難纏，還是選別的路上山吧！"},
		},
	},
}

