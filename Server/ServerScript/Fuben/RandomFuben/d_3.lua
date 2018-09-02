
local tbFubenSetting = Fuben.RandomFuben:GetRandomFubenSetting("d_3");

tbFubenSetting.tbMultiBeginPoint = {{5909, 1726},{6180, 1918},{6111, 1461},{6357, 1691}}	-- 副本出生点
tbFubenSetting.tbTempRevivePoint = {6117, 1688}
tbFubenSetting.nStartDir		 = 61;	


--NPC模版ID，NPC等级，NPC五行；

--[[

]]


tbFubenSetting.NPC = 
{
	[1] = {nTemplate = 1321, nLevel = -1, nSeries = 0},   --秒杀机关
	[2] = {nTemplate = 1322, nLevel = -1, nSeries = -1},  --石碑
	[3] = {nTemplate = 1323, nLevel = -1, nSeries = -1},  --机关守卫
	[4] = {nTemplate = 1324, nLevel = -1, nSeries = -1},  --机关守卫
	[5] = {nTemplate = 1576, nLevel = -1, nSeries = -1},  --蔷薇
	[6] = {nTemplate = 104,  nLevel = -1, nSeries = 0},   --动态障碍墙
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
			{"AddNpc", 6, 2, 1, "wall", "wall_1_1",false, 9},
			{"OpenWindow", "LingJueFengLayerPanel", "Info",3, 9, "第四層 石窟密洞"},
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
		},
	},
	[3] = {nTime = 0, nNum = 1,
		tbPrelock = {2},
		tbStartEvent = 
		{			
			{"TrapUnlock", "TrapLock1", 3},
			{"SetFubenProgress", 0, "探索凌絕峰"},

			--秒杀机关
			{"AddNpc", 1, 9, 0, "jiguan1", "RandomFuben4_3_jiguan_1",false, 0, 0, 0, 0},

		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},
			{"BlackMsg", "此地毒水縱橫，切記不可碰到毒水！"},
			{"SetFubenProgress", 20, "尋找出路"},

			--石碑
			{"AddNpc", 2, 1, 5, "shibei", "RandomFuben4_3_jiguan_2",false, 0, 0, 0, 0},
		},
	},
	[4] = {nTime = 0, nNum = 1,
		tbPrelock = {2},
		tbStartEvent = 
		{
			{"TrapUnlock", "TrapLock2", 4},
		},
		tbUnLockEvent = 
		{
			{"SetFubenProgress", 30, "擊敗敵人"},
			{"BlackMsg", "發現機關！將機關守衛擊退並破壞機關！"},

			--机关守卫
			{"AddNpc", 3, 7, 5, "guaiwu", "RandomFuben4_3_1",false, 0, 0, 0, 0},
			{"NpcBubbleTalk", "guaiwu", "你們是什麼人？膽敢在大爺的地盤撒野！", 4, 1, 1},
		},
	},
	[5] = {nTime = 0, nNum = 8,
		tbPrelock = {4},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"SetFubenProgress", 40, "尋找出路"},
			{"DelNpc", "jiguan1"},
			{"BlackMsg", "繼續尋找出路！"},

			--秒杀机关
			{"AddNpc", 1, 10, 0, "jiguan2", "RandomFuben4_3_jiguan_3",false, 0, 0, 0, 0},

			--石碑
			{"AddNpc", 2, 1, 7, "shibei", "RandomFuben4_3_jiguan_4",false, 0, 0, 0, 0},
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
			{"SetFubenProgress", 60, "擊敗敵人"},
			{"BlackMsg", "發現機關！將機關守衛擊退並破壞機關！"},

			--机关守卫
			{"AddNpc", 4, 8, 7, "guaiwu", "RandomFuben4_3_2",false, 0, 0, 0, 0},
			{"NpcBubbleTalk", "guaiwu", "不知死活的傢伙，就讓我們送你上路！", 4, 1, 1},
		},
	},
	[7] = {nTime = 0, nNum = 9,
		tbPrelock = {6},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"SetFubenProgress", 80, "擊敗薔薇"},
			{"DelNpc", "jiguan2"},
			{"SetTargetPos", 4305, 4353},

			--蔷薇
			{"AddNpc", 5, 1, 9, "BOSS", "RandomFuben4_3_BOSS",false, 0, 1, 9011, 1},
		},
	},	
	[8] = {nTime = 0, nNum = 1,
		tbPrelock = {7},
		tbStartEvent = 
		{
			{"TrapUnlock", "TrapLock4", 8},
		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},
		},
	},

-------------胜利判定------------------------
	[9] = {nTime = 0, nNum = 1,
		tbPrelock = {7},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"SetFubenProgress", 100, "擊敗薔薇"},

			--判断模式获得积分
			{"RaiseEvent", "AddMissionScore", "d_score_win"},

			{"OpenWindow", "LingJueFengLayerPanel", "Win"},
			{"GameWin"},
		},
	},
-------------闯关时间------------------------	
	[10] = {nTime = "d_3_time", nNum = 0,
		tbPrelock = {2},
		tbStartEvent = 
		{
			{"SetShowTime", 10},
		},
		tbUnLockEvent = 
		{
			--判断模式获得积分
			{"RaiseEvent", "AddMissionScore", "d_score_lost"},

			{"OpenWindow", "LingJueFengLayerPanel", "Fail"},
			{"GameLost"},
		},
	},

}
