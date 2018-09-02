
local tbFubenSetting = Fuben.RandomFuben:GetRandomFubenSetting("a_9");

tbFubenSetting.tbMultiBeginPoint = {{1122, 1240},{1287, 1068},{899, 1091},{1101, 875}}	-- 副本出生点
tbFubenSetting.tbTempRevivePoint = {1094, 1051};
tbFubenSetting.nStartDir		 = 9;

--NPC模版ID，NPC等级，NPC五行；

--[[

]]


tbFubenSetting.NPC = 
{
	[1] = {nTemplate = 1545,  nLevel = -1, nSeries = -1}, --山贼
	[2] = {nTemplate = 1546,  nLevel = -1, nSeries = -1}, --山贼头目
	[3] = {nTemplate = 104,  nLevel = -1, nSeries = 0}, --动态障碍墙
	[4] = {nTemplate = 1338, nLevel = -1, nSeries = 0}, --紫轩
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
			{"AddNpc", 3, 2, 1, "wall", "wall_1_1",false, 24},
			{"OpenWindow", "LingJueFengLayerPanel", "Info",3, 9, "第一層 竹林小道"},
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
			{"DoDeath", "wall"},
			{"OpenDynamicObstacle", "ops1"},			
			{"SetTargetPos", 1877, 1836},

			--紫轩
			{"AddNpc", 4, 1, 10, "Zixuan", "RandomFuben1_9_Zixuan",false, 6, 0, 0, 0},
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
			{"SetFubenProgress", 40, "保護紫軒"},
			{"BlackMsg", "前方似乎有位姑娘遇到了麻煩！"},

			--山贼
			{"AddNpc", 1, 5, 4, "guaiwu", "RandomFuben1_9_1", false, 0, 0, 0, 0},
			{"NpcBubbleTalk", "Zixuan", "你們這群山賊真是可惡，可有人來幫助小女子！", 4, 1, 1},
			{"NpcBubbleTalk", "guaiwu", "哈哈哈，小娘子乖乖跟兄弟們回去吧！", 4, 2, 1},
		},
	},
	[4] = {nTime = 0, nNum = 5,
		tbPrelock = {3},
		tbStartEvent = 
		{			

		},
		tbUnLockEvent = 
		{
			--掉落房间奖励
			{"RaiseEvent", "DropAward", "Setting/Fuben/RandomFuben/HouseAward/A.tab", 2236, 2337},
			{"RaiseEvent", "DropAward", "Setting/Fuben/RandomFuben/HouseAward/A.tab", 2443, 2138},

			{"SetFubenProgress", 60, "擊退山賊頭目"},
			{"NpcBubbleTalk", "BOSS", "哪裡來的傢伙，竟敢壞兄弟們的好事！真是自尋死路！！", 4, 3, 1},

			--山贼 & 山贼头目
			{"AddNpc", 1, 6, 5, "guaiwu", "RandomFuben1_9_2", false, 0, 0, 0, 0},
			{"AddNpc", 2, 1, 5, "BOSS", "RandomFuben1_9_BOSS", false, 0, 1, 9011, 1},
		},
	},
	[5] = {nTime = 0, nNum = 7,
		tbPrelock = {4},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			--掉落房间奖励
			{"RaiseEvent", "DropAward", "Setting/Fuben/RandomFuben/HouseAward/A.tab", 2723, 2958},
			{"RaiseEvent", "DropAward", "Setting/Fuben/RandomFuben/HouseAward/A.tab", 2926, 2835},

			{"SetFubenProgress", 100, "擊退山賊頭目"},	
			{"RaiseEvent", "AddMissionScore", 12},
			{"OpenWindow", "LingJueFengLayerPanel", "Win"},
			{"GameWin"},
		},
	},
	[6] = {nTime = 90, nNum = 0,
		tbPrelock = {2},
		tbStartEvent = 
		{
			{"SetShowTime", 6},
		},
		tbUnLockEvent = 
		{
			{"RaiseEvent", "AddMissionScore", 8},
			{"BlackMsg", "這群山賊還真是厲害，還是趕緊離去為妙！"},
			{"OpenWindow", "LingJueFengLayerPanel", "Fail"},
			{"GameLost"},
		},
	},
}

