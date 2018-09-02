
local tbFubenSetting = Fuben.RandomFuben:GetRandomFubenSetting("b_6");

tbFubenSetting.tbMultiBeginPoint = {{1396, 1577},{1628, 1374},{1203, 1374},{1467, 1159}}	-- 副本出生点
tbFubenSetting.tbTempRevivePoint = {1479, 1381}
tbFubenSetting.nStartDir		 = 8;

--NPC模版ID，NPC等级，NPC五行；

--[[

]]


tbFubenSetting.NPC = 
{
	[1] = {nTemplate = 1557,  nLevel = -1, nSeries = -1}, --苍鹰
	[2] = {nTemplate = 1558,  nLevel = -1, nSeries = -1}, --大型苍鹰
	[3] = {nTemplate = 1559,  nLevel = -1, nSeries = 0}, --胡神医
	[4] = {nTemplate = 104,   nLevel = -1, nSeries = 0},  --动态障碍墙
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
			{"OpenWindow", "LingJueFengLayerPanel", "Info",3, 9, "第二層 竹林小道"},
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
			{"SetTargetPos", 2058, 1865},

			--胡神医
			{"AddNpc", 3, 1, 10, "Hushenyi", "RandomFuben2_6_hushenyi",false, 16, 0, 0, 0},
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
			{"SetFubenProgress", 30, "保護胡神醫"},
			{"BlackMsg", "前方似乎有人遇到了麻煩！"},

			--苍鹰 & 大型苍鹰
			{"AddNpc", 1, 4, 4, "guaiwu", "RandomFuben2_6_1", false, 0, 0, 0, 0},
			{"AddNpc", 1, 6, 4, "guaiwu", "RandomFuben2_6_2", false, 0, 2, 9008, 0.5},
			{"AddNpc", 2, 1, 4, "Elite", "RandomFuben2_6_Elite1", false, 0, 1, 9011, 1},
			{"NpcBubbleTalk", "Hushenyi", "沒想到竟會在此處遇到這群蒼鷹，真是麻煩啊！", 4, 1, 1},
		},
	},
	[4] = {nTime = 0, nNum = 11,
		tbPrelock = {3},
		tbStartEvent = 
		{	
		},
		tbUnLockEvent = 
		{
			{"SetFubenProgress", 60, "護送胡神醫"},
			{"NpcBubbleTalk", "Hushenyi", "小娃娃們，你們便助老頭子一臂之力吧！", 4, 0, 1},
			{"SetTargetPos", 4648, 2406},
			{"ChangeNpcAi", "Hushenyi", "Move", "Path1", 1, 1, 0, 0, 0},
			{"OpenDynamicObstacle", "ops2"},
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
			{"SetFubenProgress", 80, "保護胡神醫"},
			{"NpcBubbleTalk", "Hushenyi", "又遇到這群蒼鷹了，將牠們擊退！", 4, 1, 1},

			--苍鹰 & 大型苍鹰
			{"AddNpc", 1, 7, 6, "guaiwu", "RandomFuben2_6_3", false, 0, 2, 0, 0},
			{"AddNpc", 2, 1, 6, "Elite", "RandomFuben2_6_Elite2", false, 0, 1, 9011, 1},
		},
	},

-------------胜利判定------------------------
	[6] = {nTime = 0, nNum = 8,
		tbPrelock = {5},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			--掉落首领奖励 ——  胡神医
			{"RaiseEvent", "DropAward", "Setting/Npc/DropFile/RandomFuben/House_B/hushenyi.tab", 5967, 2796},	
			{"RaiseEvent", "DropAward", "Setting/Npc/DropFile/RandomFuben/House_B/hushenyi.tab", 5900, 2900},	

			{"SetFubenProgress", 100, "保護胡神醫"},	

			--判断模式获得积分
			{"RaiseEvent", "AddMissionScore", "b_score_win"},

			{"OpenWindow", "LingJueFengLayerPanel", "Win"},
			{"GameWin"},
		},
	},
-------------闯关时间------------------------
	[7] = {nTime = "b_6_time", nNum = 0,
		tbPrelock = {2},
		tbStartEvent = 
		{
			{"SetShowTime", 7},
		},
		tbUnLockEvent = 
		{
			--判断模式获得积分
			{"RaiseEvent", "AddMissionScore", "b_score_lost"},

			{"BlackMsg", "這群刺客還真是厲害，還是趕緊離去為妙！"},
			{"OpenWindow", "LingJueFengLayerPanel", "Fail"},
			{"GameLost"},
		},
	},

}