
local tbFubenSetting = Fuben.RandomFuben:GetRandomFubenSetting("c_9");

tbFubenSetting.tbMultiBeginPoint = {{3892, 1974},{4181, 2014},{3992, 1691},{4253, 1769}}	-- 副本出生点
tbFubenSetting.tbTempRevivePoint = {4066, 1872}
tbFubenSetting.nStartDir		 = 8;


--NPC模版ID，NPC等级，NPC五行；
tbFubenSetting.NPC = 
{
	[1] = {nTemplate = 1334, nLevel = -1, nSeries = -1},  --蒙面杀手
	[2] = {nTemplate = 1335, nLevel = -1, nSeries = -1},  --泼皮
	[3] = {nTemplate = 1336, nLevel = -1, nSeries = -1},  --杀手
	[4] = {nTemplate = 1337, nLevel = -1, nSeries = 0},  --旗帜
	[5] = {nTemplate = 1338, nLevel = -1, nSeries = 0},  --紫轩
	[6] = {nTemplate = 104,  nLevel = -1, nSeries = 0},  --墙
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
			{"AddNpc", 6, 1, 1, "wall", "wall_1_1",false, 14},
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
			{"ShowTaskDialog", 10002, false},
			{"DoDeath", "wall"},
			{"OpenDynamicObstacle", "ops1"},

			--紫轩
			{"AddNpc", 5, 1, 0, "Npc", "RandomFuben3_9_zixuan",false, 1, 0, 0, 0},
			{"SetNpcProtected", "Npc", 1},
		},
	},
	[3] = {nTime = 0, nNum = 1,
		tbPrelock = {2},
		tbStartEvent = 
		{			
			{"TrapUnlock", "TrapLock1", 3},
			{"SetFubenProgress", 0, "探索凌絕峰"},

			--旗帜
			{"AddNpc", 4, 1, 6, "Qizhi", "RandomFuben3_9_qizhi1",false, 0, 0, 0, 0},
			{"AddNpc", 4, 1, 6, "Qizhi", "RandomFuben3_9_qizhi2",false, 0, 0, 0, 0},
			{"AddNpc", 4, 1, 6, "Qizhi", "RandomFuben3_9_qizhi3",false, 0, 0, 0, 0},
			{"AddNpc", 4, 1, 6, "Qizhi", "RandomFuben3_9_qizhi4",false, 0, 0, 0, 0},

			--杀手
			{"AddNpc", 3, 4, 6, "guaiwu", "RandomFuben3_9_1",false, 0, 0, 0, 0},
			{"AddNpc", 3, 4, 6, "guaiwu", "RandomFuben3_9_2",false, 0, 0, 0, 0},
			{"AddNpc", 3, 4, 6, "guaiwu", "RandomFuben3_9_3",false, 0, 0, 0, 0},
			{"AddNpc", 3, 4, 6, "guaiwu", "RandomFuben3_9_4",false, 0, 0, 0, 0},
		},
		tbUnLockEvent = 
		{
			--关闭剧情对话
			{"CloseWindow", "SituationalDialogue"},
			
			{"PlayCameraEffect", 9119},	
			{"MoveCamera", 0, 4, 27.66, 38.97, 37.96, 35, 45, 0},
			{"SetAllUiVisiable", false}, 

			--加定身BUFF
			{"AddBuff", 1058, 1, 7, 0, 0},

			--暂停UI显示时间
			{"PauseLock", 7},

			--加副本后台时间
			{"ChangeTime", -5},
		},
	},
	[4] = {nTime = 5, nNum = 0,
		tbPrelock = {3},
		tbStartEvent = 
		{
			
		},
		tbUnLockEvent = 
		{
			{"SetFubenProgress", 50, "擊殺全部敵人"},
			{"LeaveAnimationState", false},
			{"SetAllUiVisiable", true}, 
			{"PlayCameraEffect", 9119},	

			--移除定身
			{"RemovePlayerSkillState", 1058},

			--恢复UI显示时间
			{"ResumeLock", 7},
			{"SetShowTime", 7},
		},
	},
	[5] = {nTime = 2, nNum = 0,
		tbPrelock = {4},
		tbStartEvent = 
		{
			
		},
		tbUnLockEvent = 
		{
			{"BlackMsg", "旗幟帶有反彈光環，請優先破壞旗幟！"},
			{"NpcBubbleTalk", "Npc", "旗幟帶有反彈光環，會反彈傷害，你們要多加小心！", 3, 0, 1},
			{"NpcBubbleTalk", "Npc", "將敵人引出光環的影響範圍，優先破壞旗幟！", 4, 3, 1},
		},
	},
-------------胜利判定------------------------
	[6] = {nTime = 0, nNum = 20,
		tbPrelock = {2},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			--掉落首领奖励 ——  紫轩
			{"RaiseEvent", "DropAward", "Setting/Npc/DropFile/RandomFuben/House_C/zixuan.tab", 3761, 2958},	
			{"RaiseEvent", "DropAward", "Setting/Npc/DropFile/RandomFuben/House_C/zixuan.tab", 3700, 2858},	
			{"RaiseEvent", "DropAward", "Setting/Npc/DropFile/RandomFuben/House_C/zixuan.tab", 3741, 2900},	

			{"RaiseEvent", "DropCard", 2603, 300000},	--卡片收集掉落

			--判断模式获得积分
			{"RaiseEvent", "AddMissionScore", "c_score_win"},
			
			{"OpenWindow", "LingJueFengLayerPanel", "Win"},
			{"GameWin"},
		},
	},
-------------闯关时间和积分------------------------
	[7] = {nTime = "c_9_time", nNum = 0,
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

