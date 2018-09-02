
local tbFubenSetting = Fuben.RandomFuben:GetRandomFubenSetting("c_4");

tbFubenSetting.tbMultiBeginPoint = {{3354, 1254},{3103, 1073},{3465, 1017},{3228, 866}}	-- 副本出生点
tbFubenSetting.tbTempRevivePoint = {3354, 1254}
tbFubenSetting.nStartDir		 = 57;


--NPC模版ID，NPC等级，NPC五行；
tbFubenSetting.NPC = 
{
	[1] = {nTemplate = 943,  nLevel = -1, nSeries = -1},   --无忧弟子
	[2] = {nTemplate = 944,  nLevel = -1, nSeries = -1},   --无忧杀手-精英
	[3] = {nTemplate = 945,  nLevel = -1, nSeries = -1},   --无忧高手-精英
	[4] = {nTemplate = 1568, nLevel = -1, nSeries = -1},   --南宫彩虹-首领
	[5] = {nTemplate = 104,  nLevel = -1, nSeries = 0},    --墙
	[6] = {nTemplate = 945,  nLevel = -1, nSeries = 0},    --机关NPC（拉人）
	[7] = {nTemplate = 946, nLevel = -1, nSeries = 0},    --隐藏NPC
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
		    {"AddNpc", 5, 1, 0, "wall", "wall_1_1",false, 11},
		    {"OpenWindow", "LingJueFengLayerPanel", "Info",3, 9, "第三層 石壁平台"},
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
			{"OpenDynamicObstacle", "obs"},
			{"DoDeath", "wall"},
		},
	},	
	[3] = {nTime = 0, nNum = 1,
		tbPrelock = {2},
		tbStartEvent = 
		{
			{"SetFubenProgress", 0, "探索凌絕峰"},
			{"TrapUnlock", "TrapLock1", 3},
			{"SetTargetPos", 2687, 1718},
		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},
			{"SetFubenProgress", 20, "擊退敵人"},

            --无忧弟子 & 无忧杀手
            {"AddNpc", 1, 6, 4, "guaiwu", "RandomFuben3_4_1", false, 0},
			{"AddNpc", 2, 1, 4, "Elite", "RandomFuben3_4_Elite1", false, 0},
			{"NpcBubbleTalk", "guaiwu", "來者何人！！此處被我五色教承包了，閒雜人等還不速速退去？！", 4, 3, 1},
   		},
	},
	[4] = {nTime = 0, nNum = 7,
		tbPrelock = {3},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"SetTargetPos", 2868, 3972},
			{"SetFubenProgress", 40, "探索凌絕峰"},
		},
	},
	[5] = {nTime = 0, nNum = 1,
		tbPrelock = {4},
		tbStartEvent = 
		{
          {"TrapUnlock", "TrapLock2", 5},
   		},
		tbUnLockEvent = 
		{
		   {"ClearTargetPos"},
		   {"SetFubenProgress", 60, "擊退敵人"},

             --无忧弟子 & 无忧杀手
            {"AddNpc", 1, 6, 6, "guaiwu", "RandomFuben3_4_2", false, 0},
			{"AddNpc", 2, 1, 6, "Elite", "RandomFuben3_4_Elite2", false, 0},
		},
	},
	[6] = {nTime = 0, nNum = 7,
		tbPrelock = {5},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"SetFubenProgress", 80, "探索凌絕峰"},
			{"SetTargetPos", 5590, 4336},

			--南宫彩虹
			{"AddNpc", 4, 1, 8, "BOSS", "RandomFuben3_4_BOSS", false, 0},
			{"SetNpcProtected", "BOSS", 1},

			--重新设置复活点
			{"SetDynamicRevivePoint", 4473, 4101},
		},
	},
	[7] = {nTime = 0, nNum = 1,
		tbPrelock = {6},
		tbStartEvent = 
		{
            {"TrapUnlock", "TrapLock3", 7},
   		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},
			{"SetFubenProgress", 80, "擊敗南宮彩虹"},	
			{"SetNpcProtected", "BOSS", 0},
			{"NpcHpUnlock", "BOSS", 30, 80},
		},
	},

------------------------------------阶段锁----------------------------------------------
----------------阶段一----------------------
	[30] = {nTime = 0, nNum = 1,
		tbPrelock = {7},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"NpcHpUnlock", "BOSS", 35, 30},
			{"NpcBubbleTalk", "BOSS", "沒想到你們倒還有兩下子，既然如此讓你們看看我的厲害吧！！！", 4, 0, 1},

			--机关 & 隐藏NPC
			{"AddNpc", 6, 1, 31, "Jiguan", "RandomFuben3_4_jiguan", false, 0},
			{"AddNpc", 7, 1, 0, "SkillNpc", "RandomFuben3_4_jiguan", false, 0},

			--循环拉人
			{"StartTimeCycle", "cycle_1", 0.3, 100, {"CastSkill", "Jiguan", 2775, 1, -1, -1},},
		},
	},
	[31] = {nTime = 0, nNum = 1,
		tbPrelock = {30},
		tbStartEvent = 
		{

		},
		tbUnLockEvent = 
		{
			{"RemovePlayerSkillState", 2776},

			--关闭循环
			{"CloseCycle", "cycle_1"},	
		},
	},
	--放技能
	[32] = {nTime = 1, nNum = 0,
		tbPrelock = {30},
		tbStartEvent = 
		{

		},
		tbUnLockEvent = 
		{
			{"SetAiActive", "BOSS", 0},
			{"NpcAddBuff", "SkillNpc", 1884, 1, 100},

			{"BlackMsg", "將[FFFE0D]機關破壞[-]並盡速逃離此區域！！！"},

			--BOSS循环蓄力
			{"StartTimeCycle", "cycle_2", 2, 100, {"CastSkill", "BOSS", 1444, 1, -1, -1},},
		},
	},
	[33] = {nTime = 10, nNum = 0,
		tbPrelock = {32},
		tbStartEvent = 
		{

		},
		tbUnLockEvent = 
		{
			--关闭循环
			{"CloseCycle", "cycle_2"},

			--清除BUFF
			{"NpcRemoveBuff", "SkillNpc", 1884},

			--放强力技能
			{"CastSkill", "SkillNpc", 2430, 30, -1, -1},
			{"SetAiActive", "BOSS", 1},

			{"CloseLock", 50}, 
		},
	},
	[34] = {nTime = 1, nNum = 0,
		tbPrelock = {33},
		tbStartEvent = 
		{

		},
		tbUnLockEvent = 
		{
			{"SetAiActive", "BOSS", 1},

			--删除机关NPC
			{"DelNpc", "Jiguan"},

			{"RemovePlayerSkillState", 2776},

			--关闭循环
			{"CloseCycle", "cycle_1"},
		},
	},
	[50] = {nTime = 2, nNum = 0,
		tbPrelock = {31},
		tbStartEvent = 
		{

		},
		tbUnLockEvent = 
		{
			{"CloseLock", 33, 34}, 

			--放强力技能
			{"CastSkill", "SkillNpc", 2430, 30, -1, -1},

			--清除BUFF
			{"NpcRemoveBuff", "SkillNpc", 1884},

			--关闭循环
			{"CloseCycle", "cycle_1"},
			{"CloseCycle", "cycle_2"},	

			{"SetAiActive", "BOSS", 1},
		},
	},

	--保险锁
	[60] = {nTime = 0, nNum = 1,
		tbPrelock = {30},
		tbStartEvent = 
		{

		},
		tbUnLockEvent = 
		{
			{"CloseLock", 33, 34, 50}, 

			--关闭循环
			{"CloseCycle", "cycle_1"},
			{"CloseCycle", "cycle_2"},	

			--删除机关NPC
			{"DelNpc", "Jiguan"},

			{"SetAiActive", "BOSS", 1},
		},
	},
----------------阶段二----------------------
	[35] = {nTime = 0, nNum = 1,
		tbPrelock = {30},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"UnLock", 60}, 
			{"NpcBubbleTalk", "BOSS", "沒想到你們倒還有兩下子，既然如此讓你們看看我的厲害吧！！！", 4, 0, 1},

			--机关
			{"AddNpc", 6, 1, 36, "Jiguan1", "RandomFuben3_4_jiguan", false, 0},

			--循环拉人
			{"StartTimeCycle", "cycle_3", 1, 100, {"CastSkill", "Jiguan1", 2775, 1, -1, -1},},
		},
	},
	[36] = {nTime = 0, nNum = 1,
		tbPrelock = {35},
		tbStartEvent = 
		{

		},
		tbUnLockEvent = 
		{
			{"RemovePlayerSkillState", 2776},

			--关闭循环
			{"CloseCycle", "cycle_3"},	
		},
	},

	--放技能
	[37] = {nTime = 1, nNum = 0,
		tbPrelock = {35},
		tbStartEvent = 
		{

		},
		tbUnLockEvent = 
		{
			{"SetAiActive", "BOSS", 0},
			{"NpcAddBuff", "SkillNpc", 1884, 1, 100},
			{"BlackMsg", "將[FFFE0D]機關破壞[-]並盡速逃離此區域！！！"},

			--BOSS循环蓄力
			{"StartTimeCycle", "cycle_4", 2, 100, {"CastSkill", "BOSS", 1444, 1, -1, -1},},
		},
	},
	[38] = {nTime = 10, nNum = 0,
		tbPrelock = {37},
		tbStartEvent = 
		{

		},
		tbUnLockEvent = 
		{
			{"SetNpcDir", "BOSS", 20},

			--关闭循环
			{"CloseCycle", "cycle_3"},	
			{"CloseCycle", "cycle_4"},

			--清除BUFF
			{"NpcRemoveBuff", "SkillNpc", 1884},

			--放强力技能
			{"CastSkill", "SkillNpc", 2430, 30, -1, -1},
			{"SetAiActive", "BOSS", 1},
		},
	},
	[39] = {nTime = 1, nNum = 0,
		tbPrelock = {38},
		tbStartEvent = 
		{

		},
		tbUnLockEvent = 
		{
			{"SetAiActive", "BOSS", 1},

			--删除机关NPC
			{"DelNpc", "Jiguan1"},

			{"RemovePlayerSkillState", 2776},

			--关闭循环
			{"CloseCycle", "cycle_4"},
		},
	},
	[51] = {nTime = 2, nNum = 0,
		tbPrelock = {36},
		tbStartEvent = 
		{

		},
		tbUnLockEvent = 
		{
			{"CloseLock", 38, 39}, 

			--放强力技能
			{"CastSkill", "SkillNpc", 2430, 30, -1, -1},

			--关闭循环
			{"CloseCycle", "cycle_3"},
			{"CloseCycle", "cycle_4"},	

			--清除BUFF
			{"NpcRemoveBuff", "SkillNpc", 1884},

			{"SetAiActive", "BOSS", 1},
		},
	},
-------------胜利判定------------------------
	[8] = {nTime = 0, nNum = 1,
		tbPrelock = {7},
		tbStartEvent = 
		{

		},
		tbUnLockEvent = 
		{
			--判断模式获得积分
			{"RaiseEvent", "AddMissionScore", "c_score_win"},
			
			{"SetFubenProgress", 100, "擊敗南宮彩虹"},
			{"OpenWindow", "LingJueFengLayerPanel", "Win"},
			{"GameWin"},  
		},
	},
-------------闯关时间和积分------------------------
	[9] = {nTime = "c_4_time", nNum = 0,     --总计时
		tbPrelock = {2},
		tbStartEvent = 
		{
		    {"SetShowTime", 9},
		},
		tbUnLockEvent = 
		{
			--判断模式获得积分
			{"RaiseEvent", "AddMissionScore", "c_score_lost"},
			
			{"BlackMsg", "這一路真是兇險，我們還是先撤退吧！"},
			{"OpenWindow", "LingJueFengLayerPanel", "Fail"},
			{"GameLost"},
		},
	},
}

