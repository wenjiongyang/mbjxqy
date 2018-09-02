
local tbFubenSetting = Fuben.RandomFuben:GetRandomFubenSetting("d_5");


tbFubenSetting.tbMultiBeginPoint = {{1665, 2154},{1950, 2050},{1792, 2344},{2052, 2214}}
tbFubenSetting.tbTempRevivePoint = {1665, 2154};
tbFubenSetting.nStartDir		 = 10;

tbFubenSetting.NPC = 
{
	[1] = {nTemplate = 1621, nLevel = -1, nSeries = 0},  --柱子
	[2] = {nTemplate = 1622, nLevel = -1, nSeries = 0},  --放技能NPC
	[3] = {nTemplate = 1581, nLevel = -1, nSeries = -1}, --燕若雪
	[4] = {nTemplate = 104,  nLevel = -1, nSeries = 0},  --动态障碍墙
	[5] = {nTemplate = 1123, nLevel = -1, nSeries = 0},  --隐藏BNPC
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
		},
	},
	[2] = {nTime = 10, nNum = 0,
		tbPrelock = {1},
		tbStartEvent = 
		{
			--设置同步范围
			{"SetNearbyRange", 3},

			--调整摄像机基础参数
			{"ChangeCameraSetting", 29, 35, 20},				

			{"SetFubenProgress", -1,"等待秘境開啟"},
			{"AddNpc", 4, 2, 0, "wall", "wall_1_1",false, 24},
			{"OpenWindow", "LingJueFengLayerPanel", "Info",3, 9, "第四層 峰頂天池"},

		},
		tbUnLockEvent = 
		{
			{"RaiseEvent", "Start"},
		    {"DoDeath", "wall"},
			{"OpenDynamicObstacle", "ops1"},
			{"ShowTaskDialog", 10003, false},
			{"SetFubenProgress", 0, "探索凌絕峰"},

			--柱子
			{"AddNpc", 1, 2, 0, "Zhuzi", "RandomFuben4_5_Zhuzi1", false, 24, 0, 0, 0},	
			{"AddNpc", 1, 2, 0, "Zhuzi", "RandomFuben4_5_Zhuzi2", false, 24, 0, 0, 0},	
			{"AddNpc", 1, 2, 0, "Zhuzi", "RandomFuben4_5_Zhuzi3", false, 24, 0, 0, 0},	
			{"AddNpc", 1, 2, 0, "Zhuzi", "RandomFuben4_5_Zhuzi4", false, 24, 0, 0, 0},	

			--柱子下的隐藏NPC
			{"AddNpc", 5, 2, 0, "Hide", "RandomFuben4_5_Zhuzi1", false, 0, 0, 0, 0},	
			{"AddNpc", 5, 2, 0, "Hide", "RandomFuben4_5_Zhuzi2", false, 0, 0, 0, 0},	
			{"AddNpc", 5, 2, 0, "Hide", "RandomFuben4_5_Zhuzi3", false, 0, 0, 0, 0},	
			{"AddNpc", 5, 2, 0, "Hide", "RandomFuben4_5_Zhuzi4", false, 0, 0, 0, 0},	

			{"SetHeadVisiable", "Zhuzi", false, 1},
			{"SetHeadVisiable", "Hide", false, 1},

			--放技能NPC	
			{"AddNpc", 2, 1, 0, "SkillNpc_1", "RandomFuben4_5_SkillNpc1", false, 25, 0, 0, 0},
			{"AddNpc", 2, 1, 0, "SkillNpc_2", "RandomFuben4_5_SkillNpc2", false, 55, 0, 0, 0},
			{"AddNpc", 2, 1, 0, "SkillNpc_3", "RandomFuben4_5_SkillNpc3", false, 40, 0, 0, 0},

			--燕若雪
			{"AddNpc", 3, 1, 4, "BOSS", "RandomFuben4_5_BOSS", false, 0, 0, 0, 0},	
			{"SetNpcProtected", "BOSS", 1},
			{"NpcHpUnlock", "BOSS", 30, 80},
			{"SetAiActive", "BOSS", 0},	
		},
	},
	[3] = {nTime = 0, nNum = 1,
		tbPrelock = {2},
		tbStartEvent = 
		{
			{"SetTargetPos", 2738, 3101},
			{"TrapUnlock", "TrapLock1", 3},
		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},
			{"SetFubenProgress", 50, "擊敗燕若雪"},
			{"SetNpcProtected", "BOSS", 0},
			{"SetAiActive", "BOSS", 1},
			{"NpcBubbleTalk", "BOSS", "你們是什麼人，出現於此地意欲何為？！", 4, 3, 1},
		},
	},
--------------------------------流程阶段-------------------------------------
-------------------阶段1-------------------------
	[30] = {nTime = 0, nNum = 1,
		tbPrelock = {3},
		tbStartEvent = 
		{		
		},
		tbUnLockEvent = 
		{	
			{"NpcBubbleTalk", "BOSS", "沒想想到還有點本事，倒是小瞧你們了！來嘗嘗這招吧！", 4, 0, 1},
			{"NpcHpUnlock", "BOSS", 40, 55},

			{"BlackMsg", "[FFFE0D]左方[-]有巨浪襲來，盡速尋找[FFFE0D]石柱[-]進行躲避！"},

			--大范围推浪
			{"CastSkill", "SkillNpc_1", 2777, 30, 3500, 3687},

			--放技能NPC	
			{"AddNpc", 2, 1, 0, "Xianjin1", "RandomFuben4_5_Xianjin1", false, 0, 0, 0, 0},
			{"AddNpc", 2, 1, 0, "Xianjin2", "RandomFuben4_5_Xianjin2", false, 0, 0, 0, 0},
			{"AddNpc", 2, 1, 0, "Xianjin3", "RandomFuben4_5_Xianjin3", false, 0, 0, 0, 0},
			{"AddNpc", 2, 1, 0, "Xianjin4", "RandomFuben4_5_Xianjin4", false, 0, 0, 0, 0},
			{"AddNpc", 2, 1, 0, "Xianjin5", "RandomFuben4_5_Xianjin5", false, 0, 0, 0, 0},
			{"AddNpc", 2, 1, 0, "Xianjin6", "RandomFuben4_5_Xianjin6", false, 0, 0, 0, 0},
			{"AddNpc", 2, 1, 0, "Xianjin7", "RandomFuben4_5_Xianjin7", false, 0, 0, 0, 0},
			{"AddNpc", 2, 1, 0, "Xianjin8", "RandomFuben4_5_Xianjin8", false, 0, 0, 0, 0},
			{"AddNpc", 2, 1, 0, "Xianjin9", "RandomFuben4_5_Xianjin9", false, 0, 0, 0, 0},

			--冰霜陷阱	
			{"StartTimeCycle", "cycle_1", 5, 100, 
				{"CastSkill", "Xianjin1", 2781, 1, -1, -1},
				{"CastSkill", "Xianjin2", 2781, 1, -1, -1},
				{"CastSkill", "Xianjin3", 2781, 1, -1, -1},
				{"CastSkill", "Xianjin4", 2781, 1, -1, -1},
				{"CastSkill", "Xianjin5", 2781, 1, -1, -1},
				{"CastSkill", "Xianjin6", 2781, 1, -1, -1},
				{"CastSkill", "Xianjin7", 2781, 1, -1, -1},
				{"CastSkill", "Xianjin8", 2781, 1, -1, -1},
				{"CastSkill", "Xianjin9", 2781, 1, -1, -1},
			},
		},
	},
	[31] = {nTime = 0.1, nNum = 0,
		tbPrelock = {30},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"NpcAddBuff", "Xianjin1", 2402, 1, 100},
			{"NpcAddBuff", "Xianjin2", 2402, 1, 100},
			{"NpcAddBuff", "Xianjin3", 2402, 1, 100},
			{"NpcAddBuff", "Xianjin4", 2402, 1, 100},
			{"NpcAddBuff", "Xianjin5", 2402, 1, 100},
			{"NpcAddBuff", "Xianjin6", 2402, 1, 100},
			{"NpcAddBuff", "Xianjin7", 2402, 1, 100},
			{"NpcAddBuff", "Xianjin8", 2402, 1, 100},
			{"NpcAddBuff", "Xianjin9", 2402, 1, 100},									
		},
	},
	[32] = {nTime = 2, nNum = 0,
		tbPrelock = {31},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"CastSkill", "Xianjin1", 2781, 1, -1, -1},
			{"CastSkill", "Xianjin2", 2781, 1, -1, -1},
			{"CastSkill", "Xianjin3", 2781, 1, -1, -1},
			{"CastSkill", "Xianjin4", 2781, 1, -1, -1},
			{"CastSkill", "Xianjin5", 2781, 1, -1, -1},
			{"CastSkill", "Xianjin6", 2781, 1, -1, -1},
			{"CastSkill", "Xianjin7", 2781, 1, -1, -1},
			{"CastSkill", "Xianjin8", 2781, 1, -1, -1},
			{"CastSkill", "Xianjin9", 2781, 1, -1, -1},		

			--移除BUFF
			{"NpcRemoveBuff", "Xianjin1", 2402},
			{"NpcRemoveBuff", "Xianjin2", 2402},
			{"NpcRemoveBuff", "Xianjin3", 2402},
			{"NpcRemoveBuff", "Xianjin4", 2402},
			{"NpcRemoveBuff", "Xianjin5", 2402},
			{"NpcRemoveBuff", "Xianjin6", 2402},
			{"NpcRemoveBuff", "Xianjin7", 2402},
			{"NpcRemoveBuff", "Xianjin8", 2402},
			{"NpcRemoveBuff", "Xianjin9", 2402},				
		},
	},
	[33] = {nTime = 15, nNum = 0,
		tbPrelock = {30},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			--删除NPC
			{"DelNpc", "Xianjin1"},
			{"DelNpc", "Xianjin2"},
			{"DelNpc", "Xianjin3"},
			{"DelNpc", "Xianjin4"},
			{"DelNpc", "Xianjin5"},
			{"DelNpc", "Xianjin6"},
			{"DelNpc", "Xianjin7"},
			{"DelNpc", "Xianjin8"},
			{"DelNpc", "Xianjin9"},

			--关闭循环
			{"CloseCycle", "cycle_1"},				
		},
	},
------------------阶段2-------------------------
	[40] = {nTime = 0, nNum = 1,
		tbPrelock = {30},
		tbStartEvent = 
		{		
		},
		tbUnLockEvent = 
		{	

			{"NpcBubbleTalk", "BOSS", "沒想想到還有點本事，倒是小瞧你們了！來嘗嘗這招吧！", 4, 0, 1},
			{"NpcHpUnlock", "BOSS", 50, 25},

			{"BlackMsg", "[FFFE0D]右方[-]有巨浪襲來，盡速尋找[FFFE0D]石柱[-]進行躲避！"},

			--大范围推浪
			{"CastSkill", "SkillNpc_2", 2777, 30, 3500, 3687},

			--放技能NPC	
			{"AddNpc", 2, 1, 0, "Xianjin10", "RandomFuben4_5_Xianjin1", false, 0, 0, 0, 0},
			{"AddNpc", 2, 1, 0, "Xianjin11", "RandomFuben4_5_Xianjin2", false, 0, 0, 0, 0},
			{"AddNpc", 2, 1, 0, "Xianjin12", "RandomFuben4_5_Xianjin3", false, 0, 0, 0, 0},
			{"AddNpc", 2, 1, 0, "Xianjin13", "RandomFuben4_5_Xianjin4", false, 0, 0, 0, 0},
			{"AddNpc", 2, 1, 0, "Xianjin14", "RandomFuben4_5_Xianjin5", false, 0, 0, 0, 0},
			{"AddNpc", 2, 1, 0, "Xianjin15", "RandomFuben4_5_Xianjin6", false, 0, 0, 0, 0},
			{"AddNpc", 2, 1, 0, "Xianjin16", "RandomFuben4_5_Xianjin7", false, 0, 0, 0, 0},
			{"AddNpc", 2, 1, 0, "Xianjin17", "RandomFuben4_5_Xianjin8", false, 0, 0, 0, 0},
			{"AddNpc", 2, 1, 0, "Xianjin18", "RandomFuben4_5_Xianjin9", false, 0, 0, 0, 0},

			--冰霜陷阱	
			{"StartTimeCycle", "cycle_2", 5, 100, 
				{"CastSkill", "Xianjin10", 2781, 1, -1, -1},
				{"CastSkill", "Xianjin11", 2781, 1, -1, -1},
				{"CastSkill", "Xianjin12", 2781, 1, -1, -1},
				{"CastSkill", "Xianjin13", 2781, 1, -1, -1},
				{"CastSkill", "Xianjin14", 2781, 1, -1, -1},
				{"CastSkill", "Xianjin15", 2781, 1, -1, -1},
				{"CastSkill", "Xianjin16", 2781, 1, -1, -1},
				{"CastSkill", "Xianjin17", 2781, 1, -1, -1},
				{"CastSkill", "Xianjin18", 2781, 1, -1, -1},
			},
		},
	},
	[41] = {nTime = 0.1, nNum = 0,
		tbPrelock = {40},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"NpcAddBuff", "Xianjin10", 2402, 1, 100},
			{"NpcAddBuff", "Xianjin11", 2402, 1, 100},
			{"NpcAddBuff", "Xianjin12", 2402, 1, 100},
			{"NpcAddBuff", "Xianjin13", 2402, 1, 100},
			{"NpcAddBuff", "Xianjin14", 2402, 1, 100},
			{"NpcAddBuff", "Xianjin15", 2402, 1, 100},
			{"NpcAddBuff", "Xianjin16", 2402, 1, 100},
			{"NpcAddBuff", "Xianjin17", 2402, 1, 100},
			{"NpcAddBuff", "Xianjin18", 2402, 1, 100},									
		},
	},
	[42] = {nTime = 2, nNum = 0,
		tbPrelock = {41},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"CastSkill", "Xianjin10", 2781, 1, -1, -1},
			{"CastSkill", "Xianjin11", 2781, 1, -1, -1},
			{"CastSkill", "Xianjin12", 2781, 1, -1, -1},
			{"CastSkill", "Xianjin13", 2781, 1, -1, -1},
			{"CastSkill", "Xianjin14", 2781, 1, -1, -1},
			{"CastSkill", "Xianjin15", 2781, 1, -1, -1},
			{"CastSkill", "Xianjin16", 2781, 1, -1, -1},
			{"CastSkill", "Xianjin17", 2781, 1, -1, -1},
			{"CastSkill", "Xianjin18", 2781, 1, -1, -1},	

			--移除BUFF
			{"NpcRemoveBuff", "Xianjin10", 2402},
			{"NpcRemoveBuff", "Xianjin11", 2402},
			{"NpcRemoveBuff", "Xianjin12", 2402},
			{"NpcRemoveBuff", "Xianjin13", 2402},
			{"NpcRemoveBuff", "Xianjin14", 2402},
			{"NpcRemoveBuff", "Xianjin15", 2402},
			{"NpcRemoveBuff", "Xianjin16", 2402},
			{"NpcRemoveBuff", "Xianjin17", 2402},
			{"NpcRemoveBuff", "Xianjin18", 2402},						
		},
	},
	[43] = {nTime = 15, nNum = 0,
		tbPrelock = {40},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			--删除NPC
			{"DelNpc", "Xianjin10"},
			{"DelNpc", "Xianjin11"},
			{"DelNpc", "Xianjin12"},
			{"DelNpc", "Xianjin13"},
			{"DelNpc", "Xianjin14"},
			{"DelNpc", "Xianjin15"},
			{"DelNpc", "Xianjin16"},
			{"DelNpc", "Xianjin17"},
			{"DelNpc", "Xianjin18"},

			--关闭循环
			{"CloseCycle", "cycle_2"},					
		},
	},
----------------------------阶段3--------------------------------
	[50] = {nTime = 0, nNum = 1,
		tbPrelock = {40},
		tbStartEvent = 
		{		
		},
		tbUnLockEvent = 
		{	

			{"NpcBubbleTalk", "BOSS", "可惡.... 你們不要太得意了，嘗嘗這招的滋味吧！", 4, 0, 1},

			{"BlackMsg", "巨浪從[FFFE0D]正面[-]襲來，盡速尋找[FFFE0D]石柱[-]進行躲避！"},

			--大范围推浪
			{"CastSkill", "SkillNpc_3", 2777, 30, 3500, 3687},

			--放技能NPC	
			{"AddNpc", 2, 1, 0, "Xianjin19", "RandomFuben4_5_Xianjin1", false, 0, 0, 0, 0},
			{"AddNpc", 2, 1, 0, "Xianjin20", "RandomFuben4_5_Xianjin2", false, 0, 0, 0, 0},
			{"AddNpc", 2, 1, 0, "Xianjin21", "RandomFuben4_5_Xianjin3", false, 0, 0, 0, 0},
			{"AddNpc", 2, 1, 0, "Xianjin22", "RandomFuben4_5_Xianjin4", false, 0, 0, 0, 0},
			{"AddNpc", 2, 1, 0, "Xianjin23", "RandomFuben4_5_Xianjin5", false, 0, 0, 0, 0},
			{"AddNpc", 2, 1, 0, "Xianjin24", "RandomFuben4_5_Xianjin6", false, 0, 0, 0, 0},
			{"AddNpc", 2, 1, 0, "Xianjin25", "RandomFuben4_5_Xianjin7", false, 0, 0, 0, 0},
			{"AddNpc", 2, 1, 0, "Xianjin26", "RandomFuben4_5_Xianjin8", false, 0, 0, 0, 0},
			{"AddNpc", 2, 1, 0, "Xianjin27", "RandomFuben4_5_Xianjin9", false, 0, 0, 0, 0},

			--冰霜陷阱	
			{"StartTimeCycle", "cycle_3", 5, 100, 
				{"CastSkill", "Xianjin19", 2781, 1, -1, -1},
				{"CastSkill", "Xianjin20", 2781, 1, -1, -1},
				{"CastSkill", "Xianjin21", 2781, 1, -1, -1},
				{"CastSkill", "Xianjin22", 2781, 1, -1, -1},
				{"CastSkill", "Xianjin23", 2781, 1, -1, -1},
				{"CastSkill", "Xianjin24", 2781, 1, -1, -1},
				{"CastSkill", "Xianjin25", 2781, 1, -1, -1},
				{"CastSkill", "Xianjin26", 2781, 1, -1, -1},
				{"CastSkill", "Xianjin27", 2781, 1, -1, -1},
			},
		},
	},
	[51] = {nTime = 0.1, nNum = 0,
		tbPrelock = {50},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"NpcAddBuff", "Xianjin19", 2402, 1, 100},
			{"NpcAddBuff", "Xianjin20", 2402, 1, 100},
			{"NpcAddBuff", "Xianjin21", 2402, 1, 100},
			{"NpcAddBuff", "Xianjin22", 2402, 1, 100},
			{"NpcAddBuff", "Xianjin23", 2402, 1, 100},
			{"NpcAddBuff", "Xianjin24", 2402, 1, 100},
			{"NpcAddBuff", "Xianjin25", 2402, 1, 100},
			{"NpcAddBuff", "Xianjin26", 2402, 1, 100},
			{"NpcAddBuff", "Xianjin27", 2402, 1, 100},									
		},
	},
	[52] = {nTime = 2, nNum = 0,
		tbPrelock = {51},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"CastSkill", "Xianjin19", 2781, 1, -1, -1},
			{"CastSkill", "Xianjin20", 2781, 1, -1, -1},
			{"CastSkill", "Xianjin21", 2781, 1, -1, -1},
			{"CastSkill", "Xianjin22", 2781, 1, -1, -1},
			{"CastSkill", "Xianjin23", 2781, 1, -1, -1},
			{"CastSkill", "Xianjin24", 2781, 1, -1, -1},
			{"CastSkill", "Xianjin25", 2781, 1, -1, -1},
			{"CastSkill", "Xianjin26", 2781, 1, -1, -1},
			{"CastSkill", "Xianjin27", 2781, 1, -1, -1},

			--移除BUFF
			{"NpcRemoveBuff", "Xianjin19", 2402},
			{"NpcRemoveBuff", "Xianjin20", 2402},
			{"NpcRemoveBuff", "Xianjin21", 2402},
			{"NpcRemoveBuff", "Xianjin22", 2402},
			{"NpcRemoveBuff", "Xianjin23", 2402},
			{"NpcRemoveBuff", "Xianjin24", 2402},
			{"NpcRemoveBuff", "Xianjin25", 2402},
			{"NpcRemoveBuff", "Xianjin26", 2402},
			{"NpcRemoveBuff", "Xianjin27", 2402},							
		},
	},
	[53] = {nTime = 15, nNum = 0,
		tbPrelock = {50},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			--删除NPC
			{"DelNpc", "Xianjin19"},
			{"DelNpc", "Xianjin20"},
			{"DelNpc", "Xianjin21"},
			{"DelNpc", "Xianjin22"},
			{"DelNpc", "Xianjin23"},
			{"DelNpc", "Xianjin24"},
			{"DelNpc", "Xianjin25"},
			{"DelNpc", "Xianjin26"},
			{"DelNpc", "Xianjin27"},

			--关闭循环
			{"CloseCycle", "cycle_3"},					
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
			{"SetFubenProgress", 100, "擊敗燕若雪"},

			--判断模式获得积分
			{"RaiseEvent", "AddMissionScore", "d_score_win"},
			
			{"OpenWindow", "LingJueFengLayerPanel", "Win"},
			{"GameWin"},										
		},
	},
-------------闯关时间------------------------
	
	[5] = {nTime = "d_5_time", nNum = 0,    --总计时
		tbPrelock = {2},
		tbStartEvent = 
		{
			{"SetShowTime", 5},
		},
		tbUnLockEvent = 
		{
			{"BlackMsg", "燕若雪武藝高強不宜硬拼，還是撤退為妙！"},

			--判断模式获得积分
			{"RaiseEvent", "AddMissionScore", "d_score_lost"},

			{"OpenWindow", "LingJueFengLayerPanel", "Fail"},
			{"GameLost"},
		},
	},

}

