
local tbFubenSetting = Fuben.RandomFuben:GetRandomFubenSetting("e_6");

tbFubenSetting.tbMultiBeginPoint = {{1064, 4127},{1078, 3770},{752, 4113},{757, 3747}}	-- 副本出生点
tbFubenSetting.tbTempRevivePoint = {1064, 4127};
tbFubenSetting.nStartDir		 = 16;


tbFubenSetting.NPC = 
{
	[1] = {nTemplate = 1133, nLevel = -1, nSeries = -1},  --上官飞龙
	[2] = {nTemplate = 104,  nLevel = -1, nSeries = 0},
	[3] = {nTemplate = 1622, nLevel = -1, nSeries = 0},  --放技能NPC
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

			--调整摄像机基础参数
			{"ChangeCameraSetting", 29, 35, 20},

			{"SetFubenProgress", -1,"等待秘境開啟"},
			{"AddNpc", 2, 2, 0, "wall_1", "wall_1_1",false, 0},
			{"OpenWindow", "LingJueFengLayerPanel", "Info",3, 9, "第五層 尖嘯雪崖"},
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
			{"OpenDynamicObstacle", "obs"},
			{"SetTargetPos", 2981, 2919},
		},
	},
	[3] = {nTime = 0, nNum = 1,
		tbPrelock = {2},
		tbStartEvent = 
		{
			{"SetFubenProgress", 0, "探索凌絕峰"},			
			{"TrapUnlock", "TrapLock1", 3},

			--上官飞龙
			{"AddNpc", 1, 1, 4, "BOSS", "RandomFuben5_6_BOSS", false, 55, 0, 0, 0},	 

			--第一阶段（80%血量触发）
			{"NpcHpUnlock", "BOSS", 30, 80},
			{"SetNpcProtected", "BOSS", 1},
			{"SetAiActive", "BOSS", 0},
			{"SetHeadVisiable", "BOSS", false, 1},
		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},
			{"SetFubenProgress", 50, "擊敗上官飛龍"},
			{"SetNpcProtected", "BOSS", 0},
			{"SetAiActive", "BOSS", 1},
			{"SetHeadVisiable", "BOSS", true, 0},
			{"NpcBubbleTalk", "BOSS", "少年們，來與上官飛龍我大戰一場吧！", 4, 0, 1},
		},
	},
------------------------------------流程阶段------------------------------
----------------------阶段1（80%血量触发）---------------------------
	[30] = {nTime = 0, nNum = 1,
		tbPrelock = {3},
		tbStartEvent = 
		{				
		},
		tbUnLockEvent = 
		{	
			{"NpcBubbleTalk", "BOSS", "沒想到你們竟有如此本領，老夫倒是小覷你們了！那麼來嘗嘗這招的滋味吧！！", 4, 0, 1},	
			{"NpcHpUnlock", "BOSS", 40, 40},

			{"BlackMsg", "上官飛龍準備[FFFE0D]釋放強力技能[-]，快[FFFE0D]使用輕功[-]躲避！！"},	

			--熔岩喷火
			{"AddNpc", 3, 1, 0, "Fire_1", "RandomFuben5_6_Fire1", false, 0, 0, 0, 0},	
			{"AddNpc", 3, 1, 0, "Fire_2", "RandomFuben5_6_Fire2", false, 0, 0, 0, 0},	
			{"AddNpc", 3, 1, 0, "Fire_3", "RandomFuben5_6_Fire3", false, 0, 0, 0, 0},	
			{"AddNpc", 3, 1, 0, "Fire_4", "RandomFuben5_6_Fire4", false, 0, 0, 0, 0},	
			{"AddNpc", 3, 1, 0, "Fire_5", "RandomFuben5_6_Fire5", false, 0, 0, 0, 0},	
			{"AddNpc", 3, 1, 0, "Fire_6", "RandomFuben5_6_Fire6", false, 0, 0, 0, 0},	
			{"AddNpc", 3, 1, 0, "Fire_7", "RandomFuben5_6_Fire7", false, 0, 0, 0, 0},	
			{"AddNpc", 3, 1, 0, "Fire_8", "RandomFuben5_6_Fire8", false, 0, 0, 0, 0},	
			{"AddNpc", 3, 1, 0, "Fire_9", "RandomFuben5_6_Fire9", false, 0, 0, 0, 0},	
			{"AddNpc", 3, 1, 0, "Fire_10", "RandomFuben5_6_Fire10", false, 0, 0, 0, 0},	
			{"AddNpc", 3, 1, 0, "Fire_11", "RandomFuben5_6_Fire11", false, 0, 0, 0, 0},	
			{"AddNpc", 3, 1, 0, "Fire_12", "RandomFuben5_6_Fire12", false, 0, 0, 0, 0},	
			{"AddNpc", 3, 1, 0, "Fire_13", "RandomFuben5_6_Fire13", false, 0, 0, 0, 0},	
			{"AddNpc", 3, 1, 0, "Fire_14", "RandomFuben5_6_Fire14", false, 0, 0, 0, 0},	
			{"AddNpc", 3, 1, 0, "Fire_15", "RandomFuben5_6_Fire15", false, 0, 0, 0, 0},	
			{"AddNpc", 3, 1, 0, "Fire_16", "RandomFuben5_6_Fire16", false, 0, 0, 0, 0},	
			{"AddNpc", 3, 1, 0, "Fire_17", "RandomFuben5_6_Fire17", false, 0, 0, 0, 0},	
			{"AddNpc", 3, 1, 0, "Fire_18", "RandomFuben5_6_Fire18", false, 0, 0, 0, 0},	
			{"AddNpc", 3, 1, 0, "Fire_19", "RandomFuben5_6_Fire19", false, 0, 0, 0, 0},	
			{"AddNpc", 3, 1, 0, "Fire_20", "RandomFuben5_6_Fire20", false, 0, 0, 0, 0},	
			{"AddNpc", 3, 1, 0, "Fire_21", "RandomFuben5_6_Fire21", false, 0, 0, 0, 0},	
			{"AddNpc", 3, 1, 0, "Fire_22", "RandomFuben5_6_Fire22", false, 0, 0, 0, 0},	
			{"AddNpc", 3, 1, 0, "Fire_23", "RandomFuben5_6_Fire23", false, 0, 0, 0, 0},	
			{"AddNpc", 3, 1, 0, "Fire_24", "RandomFuben5_6_Fire24", false, 0, 0, 0, 0},	
		},
	},
	[31] = {nTime = 2, nNum = 0,
		tbPrelock = {30},
		tbStartEvent = 
		{				
		},
		tbUnLockEvent = 
		{	
			--熔岩喷火（放技能）
			{"CastSkill", "Fire_1", 2771, 17, -1, -1},
			{"CastSkill", "Fire_2", 2771, 17, -1, -1},
			{"CastSkill", "Fire_3", 2771, 17, -1, -1},
			{"CastSkill", "Fire_4", 2771, 17, -1, -1},
			{"CastSkill", "Fire_5", 2771, 17, -1, -1},
			{"CastSkill", "Fire_6", 2771, 17, -1, -1},
			{"CastSkill", "Fire_7", 2771, 17, -1, -1},
			{"CastSkill", "Fire_8", 2771, 17, -1, -1},
			{"CastSkill", "Fire_9", 2771, 17, -1, -1},
			{"CastSkill", "Fire_10", 2771, 17, -1, -1},
			{"CastSkill", "Fire_11", 2771, 17, -1, -1},
			{"CastSkill", "Fire_12", 2771, 17, -1, -1},
			{"CastSkill", "Fire_13", 2771, 17, -1, -1},
			{"CastSkill", "Fire_14", 2771, 17, -1, -1},
			{"CastSkill", "Fire_15", 2771, 17, -1, -1},
			{"CastSkill", "Fire_16", 2771, 17, -1, -1},
			{"CastSkill", "Fire_17", 2771, 17, -1, -1},
			{"CastSkill", "Fire_18", 2771, 17, -1, -1},
			{"CastSkill", "Fire_19", 2771, 17, -1, -1},
			{"CastSkill", "Fire_20", 2771, 17, -1, -1},
			{"CastSkill", "Fire_21", 2771, 17, -1, -1},
			{"CastSkill", "Fire_22", 2771, 17, -1, -1},
			{"CastSkill", "Fire_23", 2771, 17, -1, -1},
			{"CastSkill", "Fire_24", 2771, 17, -1, -1},
		},
	},
----------------------阶段2（40%血量触发）---------------------------
	[40] = {nTime = 0, nNum = 1,
		tbPrelock = {30},
		tbStartEvent = 
		{				
		},
		tbUnLockEvent = 
		{	
			{"NpcBubbleTalk", "BOSS", "沒想到你們竟有如此本領，老夫倒是小覷你們了！那麼來嘗嘗這招的滋味吧！！", 4, 0, 1},	

			{"BlackMsg", "上官飛龍準備[FFFE0D]釋放強力技能[-]，快[FFFE0D]使用輕功[-]躲避！！"},	
		},
	},
	[41] = {nTime = 2, nNum = 0,
		tbPrelock = {40},
		tbStartEvent = 
		{				
		},
		tbUnLockEvent = 
		{	
			--熔岩喷火（放技能）
			{"CastSkill", "Fire_1", 2771, 17, -1, -1},
			{"CastSkill", "Fire_2", 2771, 17, -1, -1},
			{"CastSkill", "Fire_3", 2771, 17, -1, -1},
			{"CastSkill", "Fire_4", 2771, 17, -1, -1},
			{"CastSkill", "Fire_5", 2771, 17, -1, -1},
			{"CastSkill", "Fire_6", 2771, 17, -1, -1},
			{"CastSkill", "Fire_7", 2771, 17, -1, -1},
			{"CastSkill", "Fire_8", 2771, 17, -1, -1},
			{"CastSkill", "Fire_9", 2771, 17, -1, -1},
			{"CastSkill", "Fire_10", 2771, 17, -1, -1},
			{"CastSkill", "Fire_11", 2771, 17, -1, -1},
			{"CastSkill", "Fire_12", 2771, 17, -1, -1},
			{"CastSkill", "Fire_13", 2771, 17, -1, -1},
			{"CastSkill", "Fire_14", 2771, 17, -1, -1},
			{"CastSkill", "Fire_15", 2771, 17, -1, -1},
			{"CastSkill", "Fire_16", 2771, 17, -1, -1},
			{"CastSkill", "Fire_17", 2771, 17, -1, -1},
			{"CastSkill", "Fire_18", 2771, 17, -1, -1},
			{"CastSkill", "Fire_19", 2771, 17, -1, -1},
			{"CastSkill", "Fire_20", 2771, 17, -1, -1},
			{"CastSkill", "Fire_21", 2771, 17, -1, -1},
			{"CastSkill", "Fire_22", 2771, 17, -1, -1},
			{"CastSkill", "Fire_23", 2771, 17, -1, -1},
			{"CastSkill", "Fire_24", 2771, 17, -1, -1},
		},
	},

-------------普通/噩梦模式的胜利判定------------------------
	[4] = {nTime = 0, nNum = 1,
		tbPrelock = {2},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"SetFubenProgress", 100, "擊敗上官飛龍"},

			--判断模式篝火&踢出
			{"IfCase", "self.nFubenLevel == 1",
				{"AddSimpleNpc", 1611, 3378, 2478, 0},
				{"RaiseEvent", "KickOutAllPlayer", 40},
	
			},
			
			--判断模式获得积分
			{"RaiseEvent", "AddMissionScore", "e_score_win"},

			{"OpenWindow", "LingJueFengLayerPanel", "Win"},
			{"GameWin"},
		},
	},
-------------闯关时间------------------------	
	[5] = {nTime = "e_6_time", nNum = 0,
		tbPrelock = {2},
		tbStartEvent = 
		{
			{"SetShowTime", 5},
		},
		tbUnLockEvent = 
		{
			--判断模式踢出
			{"IfCase", "self.nFubenLevel == 1",
				{"RaiseEvent", "KickOutAllPlayer", 10},
			},
			--判断模式获得积分
			{"RaiseEvent", "AddMissionScore", "e_score_lost"},

			{"SetFubenProgress", -1, "闖關失敗"},
			{"BlackMsg", "上官飛龍武藝高強，還是先撤退為妙！"},
			{"OpenWindow", "LingJueFengLayerPanel", "Fail"},
			{"GameLost"},
		},
	},

}

