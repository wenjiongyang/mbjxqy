
local tbFubenSetting = Fuben.RandomFuben:GetRandomFubenSetting("b_9");

tbFubenSetting.tbMultiBeginPoint = {{2298, 1518},{2615, 1524},{2292, 1192},{2594, 1192}}	-- 副本出生点
tbFubenSetting.tbTempRevivePoint = {2434, 1333};
tbFubenSetting.nStartDir		 = 1;

--NPC模版ID，NPC等级，NPC五行；

--[[

]]

tbFubenSetting.NPC = 
{
	[1] = {nTemplate = 1563, nLevel = -1, nSeries = -1},  --泼皮
	[2] = {nTemplate = 1564, nLevel = -1, nSeries = -1},  --凶恶打手
	[3] = {nTemplate = 1565, nLevel = -1, nSeries = -1},  --路达
	[4] = {nTemplate = 104,  nLevel = -1, nSeries = 0},   --动态障碍墙
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
			{"AddNpc", 4, 2, 1, "wall_1", "wall_1_1",false, 16},
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
			{"DoDeath", "wall_1"},
			{"AddNpc", 4, 1, 1, "wall_2", "wall_1_2",false, 17},
			{"OpenDynamicObstacle", "ops1"},
		},
	},
	[3] = {nTime = 0, nNum = 1,
		tbPrelock = {2},
		tbStartEvent = 
		{			
			{"SetFubenProgress", 0, "探索凌絕峰"},
			{"TrapUnlock", "TrapLock1", 3},
			{"SetTargetPos", 2445, 2683},
		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},
			{"SetFubenProgress", 30, "擊退潑皮"},
			
			--凶恶打手  & 泼皮
			{"AddNpc", 2, 5, 4, "guaiwu", "RandomFuben2_9_1", false, 0, 0, 0, 0},
			{"AddNpc", 1, 6, 4, "guaiwu", "RandomFuben2_9_2", false, 0, 2, 9008, 0.5},	
		},
	},
	[4] = {nTime = 0, nNum = 11,
		tbPrelock = {3},
		tbStartEvent = 
		{	
		},
		tbUnLockEvent = 
		{
			{"SetFubenProgress", 60, "探索凌絕峰"},
			{"SetTargetPos", 2076, 4803},
			{"OpenDynamicObstacle", "ops2"},
			{"DoDeath", "wall_2"},
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
			{"SetTargetPos", 4225, 4573},
		},
	},
	[6] = {nTime = 0, nNum = 1,
		tbPrelock = {5},
		tbStartEvent = 
		{			
			{"TrapUnlock", "TrapLock3", 6},	

			--路达	& 凶恶打手
			{"AddNpc", 3, 1, 7, "BOSS", "RandomFuben2_9_BOSS", false, 0, 0, 0, 0},		
		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},
			{"SetFubenProgress", 80, "擊敗路達"},
			{"NpcBubbleTalk", "BOSS", "哈哈，真是冤家路窄！你們多次挑釁本大爺，今日就是你們的死期！", 4, 1, 1},
			{"AddNpc", 2, 7, 7, "guaiwu", "RandomFuben2_9_3", false, 0, 3, 9008, 0.5},
		},
	},

-------------胜利判定------------------------
	[7] = {nTime = 0, nNum = 8,
		tbPrelock = {5},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"SetFubenProgress", 100, "擊敗路達"},	

			--判断模式获得积分
			{"RaiseEvent", "AddMissionScore", "b_score_win"},
			
			{"OpenWindow", "LingJueFengLayerPanel", "Win"},
			{"GameWin"},
		},
	},
-------------闯关时间------------------------	
	[8] = {nTime = "b_9_time", nNum = 0,
		tbPrelock = {2},
		tbStartEvent = 
		{
			{"SetShowTime", 8},
		},
		tbUnLockEvent = 
		{
			--判断模式获得积分
			{"RaiseEvent", "AddMissionScore", "b_score_lost"},

			{"BlackMsg", "這路達還真是厲害，還是趕緊離去為妙！"},
			{"OpenWindow", "LingJueFengLayerPanel", "Fail"},
			{"GameLost"},
		},
	},

}