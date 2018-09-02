
local tbFubenSetting = Fuben.RandomFuben:GetRandomFubenSetting("e_1");

tbFubenSetting.tbMultiBeginPoint = {{1049, 1986},{1273, 1526},{888, 1364},{665, 1804}}	-- 副本出生点
tbFubenSetting.tbTempRevivePoint = {988, 1665};
tbFubenSetting.nStartDir		 = 9;


tbFubenSetting.NPC =
{
	[1] = {nTemplate = 1125, nLevel = -1, nSeries = -1}, --杨熙烈
	[2] = {nTemplate = 104,  nLevel = -1, nSeries = 0},  --动态障碍墙
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
			{"AddNpc", 2, 2, 1, "wall_1", "wall_1_1",false, 28},
			{"OpenWindow", "LingJueFengLayerPanel", "Info",3, 9, "第五層 詭影密林"},
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
			{"ShowTaskDialog", 10004, false},
			{"DoDeath", "wall_1"},
			{"OpenDynamicObstacle", "ops1"},
		},
	},
	[3] = {nTime = 0, nNum = 1,
		tbPrelock = {2},
		tbStartEvent =
		{
			{"SetFubenProgress", 0, "詭影密林"},
			{"TrapUnlock", "TrapLock1", 3},
			{"SetTargetPos", 2767, 2592},

			--杨熙烈
			{"AddNpc", 1, 1, 4, "BOSS", "RandomFuben5_1_BOSS", false, 0, 0, 0, 0},
		},
		tbUnLockEvent =
		{
			{"ClearTargetPos"},
			{"SetFubenProgress", 50, "擊敗楊熙烈"},
			{"NpcBubbleTalk", "BOSS", "小孬孬們，來與我楊熙烈一戰吧！", 4, 1, 1},

		},
	},

-------------胜利判定------------------------
	[4] = {nTime = 0, nNum = 1,
		tbPrelock = {2},
		tbStartEvent =
		{
		},
		tbUnLockEvent =
		{
			--关闭循环
			{"CloseCycle", "cycle_1"},
			{"SetFubenProgress", 100, "擊敗楊熙烈"},

			--判断模式篝火&踢出
			{"IfCase", "self.nFubenLevel == 1",
				{"AddSimpleNpc", 1611, 3367, 2933, 0},
				{"RaiseEvent", "KickOutAllPlayer", 40},
			},
			--判断模式获得积分
			{"RaiseEvent", "AddMissionScore", "e_score_win"},

			{"OpenWindow", "LingJueFengLayerPanel", "Win"},
			{"GameWin"},
		},
	},
-------------闯关时间------------------------
	[5] = {nTime = "e_1_time", nNum = 0,
		tbPrelock = {2},
		tbStartEvent =
		{
			{"SetShowTime", 5},
		},
		tbUnLockEvent =
		{	--关闭循环
			{"CloseCycle", "cycle_1"},

			{"SetFubenProgress", -1, "闖關失敗"},
			{"BlackMsg", "好險，差點就小命不保！"},

			--判断模式踢出
			{"IfCase", "self.nFubenLevel == 1",
				{"RaiseEvent", "KickOutAllPlayer", 10},
			},
			--判断模式获得积分
			{"RaiseEvent", "AddMissionScore", "e_score_lost"},

			{"OpenWindow", "LingJueFengLayerPanel", "Fail"},
			{"GameLost"},
		},
	},

	--BOSS战阶段一
	[30] = {nTime = 0, nNum = 1,
		tbPrelock = {3},
		tbStartEvent =
		{
			{"NpcHpUnlock", "BOSS", 30, 85},
		},
		tbUnLockEvent =
		{
			{"NpcBubbleTalk", "BOSS", "哈哈哈，痛快！既然如此老夫也不能藏拙了，接招吧！", 4, 1, 1},

			--大范围中毒光环
			{"NpcAddBuff", "BOSS", 1881, 25, 150},
			{"NpcHpUnlock", "BOSS", 32, 60},
		},
	},
	[31] = {nTime = 2, nNum = 0,
		tbPrelock = {30},
		tbStartEvent =
		{
		},
		tbUnLockEvent =
		{
			{"BlackMsg", "楊熙烈附帶劇毒光環，拾取補血球以抵禦傷害！"},

			--补血球
			{"DropBuffer", "[NpcGroup=BOSS]", 2841,"3|100;5"},
			{"StartTimeCycle", "cycle_1", 20, 100, {"DropBuffer", "[NpcGroup=BOSS]", 2841,"3|100;5"},},
		},
	},
	[32] = {nTime = 0, nNum = 1,
		tbPrelock = {30},
		tbStartEvent =
		{
		},
		tbUnLockEvent =
		{
			{"NpcBubbleTalk", "BOSS", "沒想到竟與老夫戰到這種程度，小孬孬們還不錯！", 4, 1, 1},
			{"NpcRemoveBuff", "BOSS", 1881},
			{"RemovePlayerSkillState", 1529},
			{"NpcHpUnlock", "BOSS", 33, 40},

			--关闭循环
			{"CloseCycle", "cycle_1"},
		},
	},

	--BOSS战阶段二
	[33] = {nTime = 0, nNum = 1,
		tbPrelock = {32},
		tbStartEvent =
		{
		},
		tbUnLockEvent =
		{
			{"NpcBubbleTalk", "BOSS", "沒想到你們竟能將老夫逼至如此境地，當真是後生可畏！！", 4, 1, 1},

			--大范围中毒光环
			{"NpcAddBuff", "BOSS", 1881, 25, 150},
		},
	},
	[34] = {nTime = 2, nNum = 0,
		tbPrelock = {33},
		tbStartEvent =
		{
		},
		tbUnLockEvent =
		{
			{"BlackMsg", "楊熙烈附帶劇毒光環，拾取補血球以抵禦傷害！"},

			--补血球
			{"DropBuffer", "[NpcGroup=BOSS]", 2841,"3|100;5"},
			{"StartTimeCycle", "cycle_1", 20, 100, {"DropBuffer", "[NpcGroup=BOSS]", 2841,"3|100;5"},},
		},
	},
}

