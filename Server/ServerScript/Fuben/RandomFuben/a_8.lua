
local tbFubenSetting = Fuben.RandomFuben:GetRandomFubenSetting("a_8");

tbFubenSetting.tbMultiBeginPoint = {{1396, 1577},{1628, 1374},{1203, 1374},{1467, 1159}}	-- 副本出生点
tbFubenSetting.tbTempRevivePoint = {1479, 1381}
tbFubenSetting.nStartDir		 = 8;	


--NPC模版ID，NPC等级，NPC五行；

--[[

]]

tbFubenSetting.NPC = 
{
	[1] = {nTemplate = 262, nLevel = -1,  nSeries = 0},  --沐紫衣
	[2] = {nTemplate = 1313, nLevel = -1, nSeries = -1},  --山贼
	[3] = {nTemplate = 1314, nLevel = -1, nSeries = -1},  --顾武
	[4] = {nTemplate = 104, nLevel = -1,  nSeries = 0},  --动态障碍墙
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
			{"AddNpc", 4, 2, 1, "wall", "wall_1_1",false, 23},
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

			--沐紫衣
			{"AddNpc", 1, 1, 10, "npc", "RandomFuben1_8_muziyi",false, 0 , 0, 0, 0},
		},
	},
	[3] = {nTime = 0, nNum = 1,
		tbPrelock = {2},
		tbStartEvent = 
		{			
			{"ChangeFightState", 1},
			{"TrapUnlock", "TrapLock1", 3},
			{"SetFubenProgress", 0, "探索凌絕峰"},
			{"SetTargetPos", 2058, 1865},
		},
		tbUnLockEvent = 
		{			
			{"SetFubenProgress", 20, "擊退山賊"},
			{"BlackMsg", "這不是沐姑娘嗎？看樣子她似乎遭遇了些麻煩！"},
			{"ClearTargetPos"},

			--山贼
			{"AddNpc", 2, 5, 4, "guaiwu", "RandomFuben1_8_1",false, 0 , 0, 0, 0},
			{"NpcBubbleTalk", "guaiwu", "小屁孩，總算是抓到你了！乖乖跟我們回去吧！", 4, 1, 1},	
		},
	},
	[4] = {nTime = 0, nNum = 5,
		tbPrelock = {3},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"SetFubenProgress", 40, "護送沐紫衣"},
			{"BlackMsg", "護送沐紫衣離開此地！"},
			{"NpcBubbleTalk", "npc", "嘻嘻，居然是你們啊，那就麻煩你們帶我離開這裡啦！", 4, 1, 1},	
			{"ChangeNpcAi", "npc", "Move", "Path1", 0, 0, 0, 0, 0},
			{"SetTargetPos", 4648, 2406},

			--掉落房间奖励
			{"RaiseEvent", "DropAward", "Setting/Fuben/RandomFuben/HouseAward/A.tab", 2750, 2415},
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
			{"SetFubenProgress", 60, "擊退山賊"},		
			{"ClearTargetPos"},

			--山贼
			{"AddNpc", 2, 5, 6, "guaiwu", "RandomFuben1_8_2",false, 0 , 0, 0, 0},
			{"NpcBubbleTalk", "guaiwu", "你們是什麼人，莫非是那小屁孩的同夥不成？", 4, 1, 1},	
			{"NpcBubbleTalk", "npc", "這群山賊真是可惡，竟敢欺負本姑娘！你們要好好教訓他們一頓哦！", 4, 3, 1},
		},
	},
	[6] = {nTime = 0, nNum = 5,
		tbPrelock = {5},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"SetFubenProgress", 80, "擊退山賊頭目"},

			--掉落房间奖励
			{"RaiseEvent", "DropAward", "Setting/Fuben/RandomFuben/HouseAward/A.tab", 5318, 2784},			

			--山贼头目 & 山贼			
			{"AddNpc", 3, 1, 7, "BOSS", "RandomFuben1_8_BOSS",false, 0 , 1, 9011, 1},
			{"AddNpc", 2, 4, 7, "guaiwu", "RandomFuben1_8_3",false, 0 , 2, 9004, 0.5},
			{"NpcBubbleTalk", "BOSS", "小屁孩，戲弄完我們就想走？哪有這麼容易的事情！", 4, 2, 1},
			{"NpcBubbleTalk", "npc", "這群山賊真是可惡，竟敢欺負本姑娘！你們要好好教訓他們一頓哦！", 4, 4, 1},
		},
	},
	[7] = {nTime = 0, nNum = 5,
		tbPrelock = {6},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			--掉落房间奖励
			{"RaiseEvent", "DropAward", "Setting/Fuben/RandomFuben/HouseAward/A.tab", 5967, 2796},
			{"RaiseEvent", "DropAward", "Setting/Fuben/RandomFuben/HouseAward/A.tab", 5900, 2900},
			{"NpcBubbleTalk", "npc", "你們還真是厲害啊！幾下就把這群山賊給打的流落花流水！", 4, 1, 1},
			{"RaiseEvent", "AddMissionScore", 12},
			{"SetFubenProgress", 100, "擊退山賊"},	
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
			{"BlackMsg", "這群山賊還真是厲害啊！趕緊撤退為妙！"},
			{"OpenWindow", "LingJueFengLayerPanel", "Fail"},
			{"RaiseEvent", "AddMissionScore", 8},
			{"GameLost"},
		},
	},
	[9] = {nTime = 0, nNum = 1,
		tbPrelock = {2},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"BlackMsg", "糟糕！沐姑娘有危險了！"},
			{"NpcBubbleTalk", "npc", "哎呀，你真是沒用！本姑娘先閃了！", 5, 0, 1},
			{"OpenWindow", "LingJueFengLayerPanel", "Fail"},
			{"GameLost"},
		},
	},
}

