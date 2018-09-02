
local tbFubenSetting = Fuben.RandomFuben:GetRandomFubenSetting("g_3");

tbFubenSetting.tbMultiBeginPoint = {{2907, 2226},{3331, 2213},{2886, 1876},{3287, 1802}}  
tbFubenSetting.tbTempRevivePoint = {3331, 2213};
tbFubenSetting.nStartDir		 = 64;


tbFubenSetting.NPC = 
{
	[1] = {nTemplate = 1991, nLevel = -1, nSeries = -1}, --boss尹含烟
	[2] = {nTemplate = 1992, nLevel = -1, nSeries = 0}, --抵御大招法阵
	[3] = {nTemplate = 1993, nLevel = -1, nSeries = 0}, --回血怪物

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
			--{"ChangeCameraSetting", 35, 35, 20},

			{"OpenWindow", "LingJueFengLayerPanel", "Info",3, 9, "第七層 低語秘洞"},
		},
	},
	[2] = {nTime = 10, nNum = 0,
		tbPrelock = {1},
		tbStartEvent = 
		{
			{"SetFubenProgress", -1,"等待秘境開啟"},
			{"AddNpc", 100, 2, 0, "wall", "wall1",false, 17},
		},
		tbUnLockEvent = 
		{
			{"RaiseEvent", "Start"},
			{"BlackMsg", "陰森的低語聲在此地縈繞。"},
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
			{"BlackMsg", "此地不宜久留，還是另覓他路吧！"},
			{"OpenWindow", "LingJueFengLayerPanel", "Fail"},
			{"GameLost"},
		},
	},

	[4] = {nTime = 0, nNum = 1,
		tbPrelock = {2},
		tbStartEvent = 
		{
			{"TrapUnlock", "trap1", 4},
			{"SetTargetPos", 3346, 4401},
			{"SetFubenProgress", 0, "探索凌絕峰"},
		},
		tbUnLockEvent = 
		{
			{"SetFubenProgress", 60, "與尹含煙比試"},
			{"ClearTargetPos"},		    
			{"SetNpcProtected", "boss", 0},
			{"SetAiActive", "boss", 1},
			{"SetHeadVisiable", "boss", true, 0},
			{"NpcBubbleTalk", "boss", "你們來得正好，我正手癢呢！", 4, 1, 1},
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
				{"AddSimpleNpc", 1611, 3346, 4401, 0},
				{"RaiseEvent", "KickOutAllPlayer", 40},
			},
			--判断模式获得积分
			{"RaiseEvent", "AddMissionScore", "g_score_win"},

			{"SetFubenProgress", 100, "與尹含煙比試"},
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
			{"NpcBubbleTalk", "boss", "來見識下我最近研習的招式吧！", 4, 0, 1},
		},
	},
	[7] = {nTime = 6, nNum = 0,
		tbPrelock = {6},
		tbStartEvent = 
		{
			{"BlackMsg", "去[FFFE0D]極反法陣[-]中躲避致命攻擊！"},
			--boss技能
			{"CastSkill", "boss", 3111, 1, 3566, 4462},
			{"CastSkill", "boss", 3111, 1, 2666, 5372},
			{"CastSkill", "boss", 3111, 1, 4443, 5363},
			{"CastSkill", "boss", 3111, 1, 4457, 3576},
			{"CastSkill", "boss", 3111, 1, 2633, 3557},
			--抵御法阵
			{"AddNpc", 2, 2, 0, "npc", "fazhen", false, 0, 0, 0, 0},
			--添加锁足BUFF
			{"AddBuff", 1457, 1, 600, 1, 1},
		},
		tbUnLockEvent = 
		{
			{"NpcBubbleTalk", "boss", "嘿嘿，還沒完呢！", 5, 1, 1},
			--删除法阵
			{"DelNpc", "npc"},
			--移除锁足BUFF
			{"RemovePlayerSkillState", 1457},
		},
	},
	[8] = {nTime = 0, nNum = 1,
		tbPrelock = {7},
		tbStartEvent = 
		{
			{"BlackMsg", "阻止[FFFE0D]復蘇之魂[-]到達目的地！"},
			--恢复npc
			{"AddNpc", 3, 1, 0, "gw", "guaiwu1", false, 0, 0, 0, 0},
			{"ChangeNpcAi", "gw", "Move", "path1", 8, 0, 0, 1, 0},
		},
		tbUnLockEvent = 
		{
			--恢复技能施放
			{"NpcBubbleTalk", "boss", "好舒服啊！", 4, 1, 1},
			{"CastSkill", "boss", 2094, 4, -1, -1},
		},
	},
	-------------------阶段2----------------------
	[9] = {nTime = 0, nNum = 1,
		tbPrelock = {4},
		tbStartEvent = 
		{
			{"NpcHpUnlock", "boss", 9, 30},
		},
		tbUnLockEvent = 
		{
			{"NpcBubbleTalk", "boss", "來見識下我最近研習的招式吧！", 4, 0, 1},
		},
	},
	[10] = {nTime = 6, nNum = 0,
		tbPrelock = {9},
		tbStartEvent = 
		{
			{"BlackMsg", "去[FFFE0D]極反法陣[-]中躲避致命攻擊！"},
			--boss技能
			{"CastSkill", "boss", 3111, 1, 3566, 4462},
			{"CastSkill", "boss", 3111, 1, 2666, 5372},
			{"CastSkill", "boss", 3111, 1, 4443, 5363},
			{"CastSkill", "boss", 3111, 1, 4457, 3576},
			{"CastSkill", "boss", 3111, 1, 2633, 3557},
			--抵御法阵
			{"AddNpc", 2, 2, 0, "npc", "fazhen", false, 0, 0, 0, 0},
			--添加锁足BUFF
			{"AddBuff", 1457, 1, 600, 1, 1},
		},
		tbUnLockEvent = 
		{
			{"NpcBubbleTalk", "boss", "嘿嘿，還沒完呢！", 5, 1, 1},
			--删除法阵
			{"DelNpc", "npc"},
			--移除锁足BUFF
			{"RemovePlayerSkillState", 1457},
		},
	},
	[11] = {nTime = 0, nNum = 1,
		tbPrelock = {10},
		tbStartEvent = 
		{
			{"BlackMsg", "阻止[FFFE0D]復蘇之魂[-]到達目的地！"},
			--恢复npc
			{"AddNpc", 3, 1, 0, "gw", "guaiwu1", false, 0, 0, 0, 0},
			{"ChangeNpcAi", "gw", "Move", "path1", 11, 0, 0, 1, 0},
		},
		tbUnLockEvent = 
		{
			--恢复技能施放
			{"NpcBubbleTalk", "boss", "好舒服啊！", 4, 1, 1},
			{"CastSkill", "boss", 2094, 4, -1, -1},
		},
	},

}

