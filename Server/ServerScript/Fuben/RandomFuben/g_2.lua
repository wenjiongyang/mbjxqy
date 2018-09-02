
local tbFubenSetting = Fuben.RandomFuben:GetRandomFubenSetting("g_2");

tbFubenSetting.tbMultiBeginPoint = {{4768, 1804},{5279, 1728},{4795, 1389},{5134, 1348}}  
tbFubenSetting.tbTempRevivePoint = {5279, 1728};
tbFubenSetting.nStartDir		 = 64;


tbFubenSetting.NPC = 
{
	[1] = {nTemplate = 1988, nLevel = -1, nSeries = -1}, --boss
	[2] = {nTemplate = 1989, nLevel = -1, nSeries = 0}, --控制机关
	[3] = {nTemplate = 1990, nLevel = -1, nSeries = 0}, --巡逻陷阱

	[100] = {nTemplate = 104,  nLevel = -1, nSeries = 0},  --动态障碍墙
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
			{"ChangeCameraSetting", 35, 35, 20},

			{"OpenWindow", "LingJueFengLayerPanel", "Info",3, 9, "第七層 冰寒地窟"},
		},
	},
	[2] = {nTime = 10, nNum = 0,
		tbPrelock = {1},
		tbStartEvent = 
		{
			{"SetFubenProgress", -1,"等待秘境開啟"},
			{"AddNpc", 100, 2, 0, "wall", "wall1",false, 18},
		},
		tbUnLockEvent = 
		{
			{"RaiseEvent", "Start"},
			{"BlackMsg", "此處冷氣浸體陰風陣陣，恐怕有險惡機關！"},
			--{"ShowTaskDialog", 10004, false},
		    {"DoDeath", "wall"},
			{"OpenDynamicObstacle", "obs1"},
			
			
		},
	},
	-------------闯关时间------------------------
	[3] = {nTime = "g_time", nNum = 0,    --总计时
		tbPrelock = {2},
		tbStartEvent = 
		{
			{"SetShowTime", 3},
		},
		tbUnLockEvent = 
		{
			--判断模式踢出
			{"IfCase", "self.nFubenLevel == 3",
				{"RaiseEvent", "KickOutAllPlayer", 10},
			},
			--判断模式获得积分
			{"RaiseEvent", "AddMissionScore", "g_score_lost"},

			{"SetFubenProgress", -1, "闖關失敗"},
			{"BlackMsg", "此處如此兇險，我們還是先走為上！"},
			{"OpenWindow", "LingJueFengLayerPanel", "Fail"},
			{"GameLost"},
		},
	},

	[4] = {nTime = 0, nNum = 1,
		tbPrelock = {2},
		tbStartEvent = 
		{
			{"TrapUnlock", "trap1", 4},
			{"SetTargetPos", 5101, 4697},
			{"SetFubenProgress", 0, "探索凌絕峰"},
		},
		tbUnLockEvent = 
		{
			{"SetFubenProgress", 50, "與道一真人比試"},
			{"ClearTargetPos"},		    
			{"SetNpcProtected", "boss", 0},
			{"SetAiActive", "boss", 1},
			{"SetHeadVisiable", "boss", true, 0},
			{"NpcBubbleTalk", "boss", "小友們不錯，讓老朽試試你們的功夫！", 4, 1, 1},
		},
	},
	[5] = {nTime = 0, nNum = 1,
		tbPrelock = {2},
		tbStartEvent = 
		{
			{"AddNpc", 1, 1, 5, "boss", "boss1", false, 32, 0, 0, 0},	
			{"SetNpcProtected", "boss", 1},
			{"SetAiActive", "boss", 0},
			{"SetHeadVisiable", "boss", false, 1},
		},
		tbUnLockEvent = 
		{
			--判断模式篝火&踢出
			{"IfCase", "self.nFubenLevel == 3",
				{"AddSimpleNpc", 1611, 5146, 5659, 0},
				{"RaiseEvent", "KickOutAllPlayer", 40},
			},
			--判断模式获得积分
			{"RaiseEvent", "AddMissionScore", "g_score_win"},

			{"SetFubenProgress", 100, "與道一真人比試"},
			{"OpenWindow", "LingJueFengLayerPanel", "Win"},
			{"GameWin"},
		},
	},
	-------------------阶段1----------------------
	[6] = {nTime = 0, nNum = 1,
		tbPrelock = {4},
		tbStartEvent = 
		{
			{"NpcHpUnlock", "boss", 6, 70},
		},
		tbUnLockEvent = 
		{
			{"NpcBubbleTalk", "boss", "果然有點真本事，那就試試這裡的妙處！", 4, 0, 1},
		},
	},
	[7] = {nTime = 0, nNum = 2,
		tbPrelock = {6},
		tbStartEvent = 
		{
			--控制机关
			{"AddNpc", 2, 2, 7, "jg", "jiguan", false, 0, 0, 0, 0},
			{"BlackMsg", "去[FFFE0D]高臺週邊[-]找到並摧毀[FFFE0D]陣眼[-]，阻止其施法！"},

			--boss循环技能
			{"SetAiActive", "boss", 0},
			{"StartTimeCycle", "cycle_1", 2, nil, 
				{"CastSkill", "boss", 3105, 3, -1, -1}, 
				{"DoCommonAct", "boss", 16, 0, 0, 0},
			},
			--巡逻陷阱
			{"AddNpc", 3, 1, 0, "xj1", "xianjing1", false, 0, 0, 0, 0},
			{"ChangeNpcAi", "xj1", "Move", "path_xj1", 0, 0, 0, 0, 1},
			{"AddNpc", 3, 1, 0, "xj2", "xianjing2", false, 0, 0, 0, 0},
			{"ChangeNpcAi", "xj2", "Move", "path_xj2", 0, 0, 0, 0, 1},
			{"AddNpc", 3, 1, 0, "xj3", "xianjing3", false, 0, 0, 0, 0},
			{"ChangeNpcAi", "xj3", "Move", "path_xj3", 0, 0, 0, 0, 1},
			{"AddNpc", 3, 1, 0, "xj4", "xianjing4", false, 0, 0, 0, 0},
			{"ChangeNpcAi", "xj4", "Move", "path_xj4", 0, 0, 0, 0, 1},
			--添加锁足BUFF
			{"AddBuff", 1457, 1, 600, 1, 1},
		},
		tbUnLockEvent = 
		{
			{"BlackMsg", "繼續戰鬥！"},
			{"NpcBubbleTalk", "boss", "居然找到此處機關，還算聰明！", 10, 4, 1},
			--终止boss循环技能
			{"CloseCycle", "cycle_1"},
			{"SetAiActive", "boss", 1},
			--删除巡逻陷阱
			{"DoDeath", "xj1"},
			{"DoDeath", "xj2"},
			{"DoDeath", "xj3"},
			{"DoDeath", "xj4"},
			--移除锁足BUFF
			{"RemovePlayerSkillState", 1457},
		},
	},
	-------------------阶段2----------------------
	[8] = {nTime = 0, nNum = 1,
		tbPrelock = {4},
		tbStartEvent = 
		{
			{"NpcHpUnlock", "boss", 8, 30},
		},
		tbUnLockEvent = 
		{
			{"NpcBubbleTalk", "boss", "很好，很好！真是後生可畏啊！", 4, 0, 1},
		},
	},
	[9] = {nTime = 0, nNum = 2,
		tbPrelock = {8},
		tbStartEvent = 
		{
			--控制机关
			{"AddNpc", 2, 2, 9, "jg", "jiguan", false, 0, 0, 0, 0},
			{"BlackMsg", "去[FFFE0D]高臺週邊[-]找到並摧毀[FFFE0D]陣眼[-]，阻止其施法！"},

			--boss循环技能
			{"SetAiActive", "boss", 0},
			{"StartTimeCycle", "cycle_2", 2, nil, 
				{"CastSkill", "boss", 3105, 3, -1, -1}, 
				{"DoCommonAct", "boss", 16, 0, 0, 0},
			},
			--巡逻陷阱
			{"AddNpc", 3, 1, 0, "xj1", "xianjing1", false, 0, 0, 0, 0},
			{"ChangeNpcAi", "xj1", "Move", "path_xj1", 0, 0, 0, 0, 1},
			{"AddNpc", 3, 1, 0, "xj2", "xianjing2", false, 0, 0, 0, 0},
			{"ChangeNpcAi", "xj2", "Move", "path_xj2", 0, 0, 0, 0, 1},
			{"AddNpc", 3, 1, 0, "xj3", "xianjing3", false, 0, 0, 0, 0},
			{"ChangeNpcAi", "xj3", "Move", "path_xj3", 0, 0, 0, 0, 1},
			{"AddNpc", 3, 1, 0, "xj4", "xianjing4", false, 0, 0, 0, 0},
			{"ChangeNpcAi", "xj4", "Move", "path_xj4", 0, 0, 0, 0, 1},
			--添加锁足BUFF
			{"AddBuff", 1457, 1, 600, 1, 1},
		},
		tbUnLockEvent = 
		{
			{"BlackMsg", "繼續戰鬥！"},
			{"NpcBubbleTalk", "boss", "真是英雄出少年啊!", 10, 4, 1},
			--终止boss循环技能
			{"CloseCycle", "cycle_2"},
			{"SetAiActive", "boss", 1},
			--删除巡逻陷阱
			{"DoDeath", "xj1"},
			{"DoDeath", "xj2"},
			{"DoDeath", "xj3"},
			{"DoDeath", "xj4"},
			--移除锁足BUFF
			{"RemovePlayerSkillState", 1457},
		},
	},

}

