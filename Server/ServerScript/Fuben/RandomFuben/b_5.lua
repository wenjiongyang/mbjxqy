
local tbFubenSetting = Fuben.RandomFuben:GetRandomFubenSetting("b_5");

tbFubenSetting.tbMultiBeginPoint = {{1705, 1459},{1961, 1323},{1539, 1177},{1776, 1009}}	-- 副本出生点
tbFubenSetting.tbTempRevivePoint = {1757, 1255};
tbFubenSetting.nStartDir		 = 8;

--NPC模版ID，NPC等级，NPC五行；

--[[

]]


tbFubenSetting.NPC = 
{
	[1] = {nTemplate = 1554,  nLevel = -1, nSeries = -1}, --机关人
	[2] = {nTemplate = 1555,  nLevel = -1, nSeries = -1}, --机关战车
	[3] = {nTemplate = 1556,  nLevel = -1, nSeries = -1}, --秦沐白
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
			{"SetFubenProgress", -1,"等待秘境開啟"},
			{"AddNpc", 4, 2, 1, "wall", "wall_1_1",false, 23},
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

			--机关人 & 机关战车
			{"AddNpc", 1, 5, 4, "guaiwu", "RandomFuben2_5_1", false, 0, 0, 0, 0},
			{"AddNpc", 2, 4, 4, "guaiwu", "RandomFuben2_5_2", false, 0, 2, 9008, 0.5},	
			{"BlackMsg", "這後山怎會出現如此多的機關人？"},
			{"SetFubenProgress", 30, "擊退機關人"},
		},
	},
	[4] = {nTime = 0, nNum = 9,
		tbPrelock = {3},
		tbStartEvent = 
		{	
		},
		tbUnLockEvent = 
		{
			{"SetFubenProgress", 60, "探索凌絕峰"},
			{"SetTargetPos", 4662, 2573},
		},
	},
	[5] = {nTime = 0, nNum = 1,
		tbPrelock = {4},
		tbStartEvent = 
		{			
			{"TrapUnlock", "TrapLock2", 5},	

			--秦沐白
			{"AddNpc", 3, 1, 6, "BOSS", "RandomFuben2_5_BOSS", false, 0, 0, 0, 0},		
		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},
			{"SetFubenProgress", 80, "擊退秦沐白"},
			{"BlackMsg", "糟糕，居然遇到了秦沐白！"},
			{"NpcBubbleTalk", "BOSS", "哈哈，真是冤家路窄！你們多次壞我大事，今日就是你們的死期！", 4, 0, 1},

			--机关人 & 机关战车
			{"AddNpc", 1, 4, 0, "guaiwu", "RandomFuben2_5_3", false, 0, 5, 9008, 0.5},
			{"AddNpc", 2, 4, 0, "guaiwu", "RandomFuben2_5_4", false, 0, 8, 9008, 0.5},
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
			{"SetFubenProgress", 100, "擊退秦沐白"},	

			--判断模式获得积分
			{"RaiseEvent", "AddMissionScore", "b_score_win"},
			
			{"OpenWindow", "LingJueFengLayerPanel", "Win"},
			{"GameWin"},
		},
	},
-------------闯关时间------------------------
	[7] = {nTime = "b_5_time", nNum = 0,
		tbPrelock = {2},
		tbStartEvent = 
		{
			{"SetShowTime", 7},
		},
		tbUnLockEvent = 
		{
			--判断模式获得积分
			{"RaiseEvent", "AddMissionScore", "b_score_lost"},

			{"BlackMsg", "這秦沐白還真是厲害，還是趕緊離去為妙！"},
			{"OpenWindow", "LingJueFengLayerPanel", "Fail"},
			{"GameLost"},
		},
	},

}