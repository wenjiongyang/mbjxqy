
local tbFubenSetting = Fuben.RandomFuben:GetRandomFubenSetting("c_7");

tbFubenSetting.tbMultiBeginPoint = {{1970, 1633},{2141, 1625},{1959, 1483},{2119, 1461}}
tbFubenSetting.tbTempRevivePoint = {1970, 1633};
tbFubenSetting.nStartDir		 = 4;

--NPC模版ID，NPC等级，NPC五行；

--[[

]]


tbFubenSetting.NPC = 
{
	[1] = {nTemplate = 260,  nLevel = -1, nSeries = -1},   --山贼
	[2] = {nTemplate = 1369, nLevel = -1, nSeries = -1},   --神射手
	[3] = {nTemplate = 261,  nLevel = -1, nSeries = -1},   --山贼头目
	[4] = {nTemplate = 1670, nLevel = -1, nSeries = -1},   --疯和尚
	[5] = {nTemplate = 1671, nLevel = -1, nSeries = -1},   --降头术士
	[6] = {nTemplate = 1574, nLevel = -1, nSeries = -1},   --无相
	[7] = {nTemplate = 104,  nLevel = -1, nSeries = 0},    --动态障碍墙

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
			{"AddNpc", 7, 2, 0, "wall_1", "wall_1_1",false, 16},
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
		    {"DoDeath", "wall_1"},
		    {"AddNpc", 7, 1, 0, "wall_2", "wall_1_2",false, 23},
			{"OpenDynamicObstacle", "ops1"},
			{"ShowTaskDialog", 10003, false},
			{"SetFubenProgress", 0, "探索凌絕峰"},
			{"SetTargetPos", 2434, 2645},
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
			{"SetFubenProgress", 40, "擊退敵人"},
			{"ClearTargetPos"},

			--山贼 & 山贼头目 & 神射手
			{"AddNpc", 1, 6, 4, "guaiwu", "RandomFuben3_7_1", false, 0, 0, 0, 0},
			{"AddNpc", 3, 1, 4, "Elite", "RandomFuben3_7_Elite1", false, 0, 0, 0, 0},
			{"AddNpc", 1, 6, 4, "guaiwu", "RandomFuben3_7_2", false, 0, 3, 9009, 0.5},
		},
	},
	[4] = {nTime = 0, nNum = 12,
		tbPrelock = {3},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"SetFubenProgress", 60, "探索凌絕峰"},
			{"OpenDynamicObstacle", "ops2"},
			{"DoDeath", "wall_2"},
			{"SetTargetPos", 3816, 4275},

			--无相
			{"AddNpc", 6, 1, 6, "BOSS", "RandomFuben3_7_BOSS", false, 0, 0, 0, 0},
			{"SetNpcProtected", "BOSS", 1},	
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
			{"SetFubenProgress", 80, "擊退無相"},
			{"ClearTargetPos"},
			{"SetNpcProtected", "BOSS", 0},	
			{"NpcHpUnlock", "BOSS", 30, 75},

			--山贼
			{"AddNpc", 1, 6, 0, "guaiwu", "RandomFuben3_7_3", false, 0, 3, 9009, 0.5},
		},
	},
	[30] = {nTime = 0, nNum = 1,
		tbPrelock = {5},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			--疯和尚 & 降头术士
			{"AddNpc", 4, 8, 0, "Crazy1", "RandomFuben3_7_3", false, 0, 0, 9009, 0.5},
			{"AddNpc", 5, 1, 32, "Control1", "RandomFuben3_7_Control", false, 0, 1, 9011, 1},

			{"NpcHpUnlock", "BOSS", 34, 40},
		},
	},
	[31] = {nTime = 3, nNum = 0,
		tbPrelock = {30},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"BlackMsg", "擊敗[FFFE0D]降頭術士[-]，讓這群瘋和尚停下來！"},
		},
	},
	[32] = {nTime = 0, nNum = 1,
		tbPrelock = {30},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"CastSkillCycle", "cycle1", "Crazy1", 1, 3, 1, -1, -1},
		},
	},
	[33] = {nTime = 2, nNum = 0,
		tbPrelock = {32},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"CloseCycle", "cyle1"},
		},
	},
	[34] = {nTime = 0, nNum = 1,
		tbPrelock = {30},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			--疯和尚 & 降头术士
			{"AddNpc", 4, 6, 0, "Crazy2", "RandomFuben3_7_4", false, 0, 0, 9009, 0.5},
			{"AddNpc", 5, 1, 36, "Control2", "RandomFuben3_7_Contro2", false, 0, 1, 9011, 1},
		},
	},
	[35] = {nTime = 3, nNum = 0,
		tbPrelock = {34},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"BlackMsg", "擊敗[FFFE0D]降頭術士[-]，讓這群瘋和尚停下來！"},
		},
	},
	[36] = {nTime = 0, nNum = 1,
		tbPrelock = {34},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"CastSkillCycle", "cycle2", "Crazy2", 1, 3, 1, -1, -1},
		},
	},
	[37] = {nTime = 2, nNum = 0,
		tbPrelock = {36},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"CloseCycle", "cyle2"},
		},
	},
-------------胜利判定------------------------
	[6] = {nTime = 0, nNum = 1,
		tbPrelock = {4},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"SetFubenProgress", 100, "擊退敵人"},			

			--判断模式获得积分
			{"RaiseEvent", "AddMissionScore", "c_score_win"},
			
			{"OpenWindow", "LingJueFengLayerPanel", "Win"},
			{"GameWin"},
		},
	},
-------------闯关时间和积分------------------------
	[7] = {nTime = "c_7_time", nNum = 0,
		tbPrelock = {2},
		tbStartEvent = 
		{
			{"SetShowTime", 7},
		},
		tbUnLockEvent = 
		{
			--判断模式获得积分
			{"RaiseEvent", "AddMissionScore", "c_score_lost"},
			
			{"OpenWindow", "LingJueFengLayerPanel", "Fail"},
			{"GameLost"},
		},
	},
}

