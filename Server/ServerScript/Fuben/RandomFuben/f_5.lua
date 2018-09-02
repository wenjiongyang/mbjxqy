
local tbFubenSetting = Fuben.RandomFuben:GetRandomFubenSetting("f_5");

tbFubenSetting.tbMultiBeginPoint = {{5968,5563},{6140, 5385},{6318, 5522},{6146, 5688}}	-- 副本出生点
tbFubenSetting.tbTempRevivePoint = {6113,5524};
tbFubenSetting.nStartDir		 = 45;

tbFubenSetting.NPC = 
{
	[1] = {nTemplate = 2453, nLevel = -1, nSeries = 6}, --古嫣然
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
			--设置同步范围
			{"SetNearbyRange", 3},
			
			{"SetFubenProgress", -1,"等待秘境開啟"},
			{"AddNpc", 2, 1, 1, "wall", "wall",false, 23},                            
			{"OpenWindow", "LingJueFengLayerPanel", "Info",3, 9, "第六層 怒梅雪園"},
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
			{"DoDeath", "wall"},
			{"OpenDynamicObstacle", "ops1"},
			{"SetTargetPos", 3993, 4193},
			{"SetFubenProgress", 0, "探索凌絕峰"},
		},
	},
----------------------闯关时间--------------------------
	[3] = {nTime = "g_time", nNum = 0,    --总计时
		tbPrelock = {2},
		tbStartEvent = 
		{
			{"SetShowTime", 3},
		},
		tbUnLockEvent = 
		{
			--判断模式踢出
			{"IfCase", "self.nFubenLevel == 2",
				{"RaiseEvent", "KickOutAllPlayer", 10},
			},
			--判断模式获得积分
			{"RaiseEvent", "AddMissionScore", "g_score_lost"},

			{"SetFubenProgress", -1, "闖關失敗"},
			{"BlackMsg", "此地不宜久留，還是另覓他路吧！"},
			{"OpenWindow", "LingJueFengLayerPanel", "Fail"},
			{"GameLost"},
		},
	},
	[4] = {nTime = 0, nNum = 1,
		tbPrelock = {2},
		tbStartEvent = 
		{
			{"TrapUnlock", "TrapLock1", 4},
		},
		tbUnLockEvent = 
		{
			{"BlackMsg", "此處似乎有武林中人出沒"},
			{"SetFubenProgress", 50, "擊敗古嫣然"},
			{"ClearTargetPos"},
			{"AddNpc", 1, 1, 10, "BOSS", "boss", false, 0, 0, 9010, 0},
			{"NpcBubbleTalk", "BOSS", "你們也要來吃我的毒蟲麼？", 4, 3, 1},
			{"NpcHpUnlock", "BOSS", 7, 80},
		},
	},
	[7] = {nTime = 0, nNum = 1,
		tbPrelock = {4},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{	
			{"NpcBubbleTalk", "BOSS", "不知好歹的東西，姑奶奶就不留手了！", 4, 3, 1},
			{"BlackMsg", "注意觀察古嫣然狀態，不要被狂暴古嫣然近身！"},
			
			{"ChangeNpcAi", "BOSS", "RandomAiTarget"},
		},
	},
	[8] = {nTime = 0.5, nNum = 0,
		tbPrelock = {7},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"SetNpcAi", "BOSS", "Setting/Npc/Ai/random/guyanrankb.ini"}, 
			{"NpcAddBuff", "BOSS", 2452, 1, 180},
			{"NpcAddBuff", "BOSS", 1535, 2, 200},
			{"StartTimeCycle", "cycle_1", 40, nil, {"SetNpcAi", "BOSS", "Setting/Npc/Ai/random/guyanrankb.ini"}, {"NpcAddBuff", "BOSS", 2452, 1, 180},{"NpcAddBuff", "BOSS", 1535, 2, 200}},
		},
	},
	[9] = {nTime = 20, nNum = 0,
		tbPrelock = {8},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"SetNpcAi", "BOSS", "Setting/Npc/Ai/random/guyanranzc.ini"}, 
			{"NpcRemoveBuff", "BOSS", 2452},
			{"NpcRemoveBuff", "BOSS", 1535},
			{"StartTimeCycle", "cycle_2", 40, nil, {"SetNpcAi", "BOSS", "Setting/Npc/Ai/random/guyanranzc.ini"}, {"NpcRemoveBuff", "BOSS", 2452},{"NpcRemoveBuff", "BOSS", 1535}},
		},
	},
------------胜负判定----------------
	[10] = {nTime = 0, nNum = 1,
		tbPrelock = {4},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"SetFubenProgress", 100, "擊敗古嫣然"},			

			--判断模式篝火&踢出
			{"IfCase", "self.nFubenLevel == 2",
				{"AddSimpleNpc", 1611, 3481, 3698, 0},
				{"RaiseEvent", "KickOutAllPlayer", 40},
			},

			--判断模式获得积分
			{"RaiseEvent", "AddMissionScore", "f_score_win"},

			{"OpenWindow", "LingJueFengLayerPanel", "Win"},
			{"GameWin"},
		},
	},
}