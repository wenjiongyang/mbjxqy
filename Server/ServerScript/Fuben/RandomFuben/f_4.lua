
local tbFubenSetting = Fuben.RandomFuben:GetRandomFubenSetting("f_4");

tbFubenSetting.tbMultiBeginPoint = {{6278,6102},{6049, 5907},{5802, 6145},{6142, 6349}}	-- 副本出生点
tbFubenSetting.tbTempRevivePoint = {5863,5916};
tbFubenSetting.nStartDir		 = 32;


tbFubenSetting.NPC = 
{
	[1] = {nTemplate = 2412, nLevel = -1, nSeries = 6}, --秒杀陷阱
	[2] = {nTemplate = 2413, nLevel = -1, nSeries = -1}, --灵魂球（红）
	[3] = {nTemplate = 2408, nLevel = -1, nSeries = 0}, --宋秋石
	[4] = {nTemplate = 104,  nLevel = -1, nSeries = 0},  --动态障碍墙
	[5] = {nTemplate = 2418, nLevel = -1, nSeries = -1}, --灵魂球（金）
	[6] = {nTemplate = 73,   nLevel = -1, nSeries = 0},   --传送门
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
			{"SetNearbyRange", 4},
			
			{"SetFubenProgress", -1,"等待秘境開啟"},
			{"AddNpc", 4, 2, 1, "wall_1", "wall_1_1",false, 23},                            
			{"OpenWindow", "LingJueFengLayerPanel", "Info",3, 9, "第六層 雪山之巔"},
			{"ChangeCameraSetting", 30, 35, 20},
			{"AddNpc", 6, 1, 0, "Chuansong", "ChuanSongMen",false, 33},
			{"AddNpc", 4, 2, 0, "wall_2", "wall_1_2",false, 23},
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
			--{"ShowTaskDialog", 10004, false},
			{"DoDeath", "wall_1"},
			{"OpenDynamicObstacle", "ops1"},
			{"SetTargetPos", 5502, 5558},
			{"ChangeTrap", "TrapLock1", {4675, 4088}, nil},
			{"AddNpc", 1, 34, 0, "xianjing", "RandomFuben6_4_xianjing", false, 0, 0, 0, 0},
		},
	},
	[3] = {nTime = 0, nNum = 1,
		tbPrelock = {2},
		tbStartEvent = 
		{
			{"SetFubenProgress", 0, "探索凌絕峰"},
			{"TrapUnlock", "TrapLock2", 3},
		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},
			{"AddNpc", 3, 1, 4, "BOSS", "RandomFuben6_4_BOSS", false, 8, 0, 9010, 0},	
			{"NpcHpUnlock", "BOSS", 21, 80},
			{"SetFubenProgress", 50, "擊敗宋秋石"},
			{"NpcBubbleTalk", "BOSS", "何人敢到我昆侖門下撒野！", 4, 3, 1},	
		},
	},
	------------------------------------流程阶段------------------------------
	[21] = {nTime = 0, nNum = 1,
		tbPrelock = {3},
		tbStartEvent = 
		{				
		},
		tbUnLockEvent = 
		{	
			{"BlackMsg", "注意躲避宋秋石的[FFFE0D]三分歸元氣[-]！！"},
			{"NpcBubbleTalk", "BOSS", "爾等速速報上名來，昆侖派劍下不誅無名之輩！！", 4, 0, 1},
			{"NpcHpUnlock", "BOSS", 11, 60},		
		},
	},
----------------------阶段1---------------------------	
	[11] = {nTime = 0, nNum = 1,
		tbPrelock = {21},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"BlackMsg", "注意擊殺[FFFE0D]靈魂球[-]！否則宋秋石會增強！"},
			{"NpcHpUnlock", "BOSS", 31, 40},
			{"AddNpc", 2, 1, 0, "Ball_1", "RandomFuben6_4_Ball1", false, 0, 0, 9011, 0},
		},
	},
	[12] = {nTime = 1, nNum = 0,
		tbPrelock = {11},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{	
			{"ChangeNpcAi", "Ball_1", "Move", "Path1", 13, 0, 0, 1, 0},
		},
	},
	[13] = {nTime = 0, nNum = 1,
		tbPrelock = {12},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"NpcAddBuff", "BOSS", 1535, 2, 60},	
		},
	},
	[15] = {nTime = 0.1, nNum = 0,
		tbPrelock = {13},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{	
			{"BlackMsg", "宋秋石吸收了靈魂球的力量， 諸位小心！！"},
		},
	},
--------------------------------------------------------
	[31] = {nTime = 0, nNum = 1,
		tbPrelock = {11},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"BlackMsg", "注意擊殺[FFFE0D]靈魂球[-]！否則宋秋石會增強！"},
			{"AddNpc", 5, 1, 0, "Ball_2", "RandomFuben6_4_Ball2", false, 0, 0, 9011, 0},
			
		},
	},
	[32] = {nTime = 1, nNum = 0,
		tbPrelock = {31},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{		
			{"ChangeNpcAi", "Ball_2", "Move", "Path1", 34, 0, 0, 1, 0},	
		},
	},
	[34] = {nTime = 0, nNum = 1,
		tbPrelock = {32},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"NpcAddBuff", "BOSS", 1509, 1, 60},	
		},
	},
	[36] = {nTime = 0.1, nNum = 0,
		tbPrelock = {34},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{	
			{"BlackMsg", "宋秋石吸收了靈魂球的力量， 諸位小心！！"},
		},
	},
-------------胜利判定------------------------
	[4] = {nTime = 0, nNum = 1,
		tbPrelock = {3},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"SetFubenProgress", 100, "擊敗宋秋石"},			

			--判断模式篝火&踢出
			{"IfCase", "self.nFubenLevel == 2",
				{"AddSimpleNpc", 1611, 4147, 4618, 0},
				{"RaiseEvent", "KickOutAllPlayer", 40},
			},

			--判断模式获得积分
			{"RaiseEvent", "AddMissionScore", "f_score_win"},

			{"OpenWindow", "LingJueFengLayerPanel", "Win"},
			{"GameWin"},
		},
	},
-------------闯关时间------------------------	
	[5] = {nTime = "f_4_time", nNum = 0,
		tbPrelock = {2},
		tbStartEvent = 
		{
			{"SetShowTime", 5},
		},
		tbUnLockEvent = 
		{
			{"BlackMsg", "這宋秋石武功果然高強，在下自愧不如！"},

			--判断模式踢出
			{"IfCase", "self.nFubenLevel == 2",
				{"RaiseEvent", "KickOutAllPlayer", 10},
			},
			--判断模式获得积分
			{"RaiseEvent", "AddMissionScore", "f_score_lost"},

			{"OpenWindow", "LingJueFengLayerPanel", "Fail"},
			{"GameLost"},
		},
	},

}