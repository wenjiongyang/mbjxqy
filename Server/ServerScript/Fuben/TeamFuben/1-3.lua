
local tbFubenSetting = {};
Fuben:SetFubenSetting(302, tbFubenSetting)		-- 绑定副本内容和地图

tbFubenSetting.szFubenClass 			= "TeamFubenBase";									-- 副本类型
tbFubenSetting.szName 					= "熔火霹靂"										-- 单纯的名字，后台输出或统计使用
tbFubenSetting.szNpcPointFile 			= "Setting/Fuben/TeamFuben/1_3/NpcPos.tab"			-- NPC点
tbFubenSetting.szPathFile 				= "Setting/Fuben/TeamFuben/1_3/NpcPath.tab"				-- 寻路点								
tbFubenSetting.tbMultiBeginPoint        = {{4373, 7435},{3940, 7771},{4223, 7118},{3872, 7455}}	-- 副本出生点
tbFubenSetting.tbTempRevivePoint 		= {4170, 7664}											-- 临时复活点，副本内有效，出副本则移除
tbFubenSetting.nStartDir				= 32;


-- ID可以随便 普通副本NPC数量 ；精英模式NPC数量
tbFubenSetting.NUM = 
{
	NpcIndex1	 	= {1, 1},
	NpcIndex2	 	= {2, 2},
	NpcIndex3	 	= {3, 3},
	NpcIndex4	 	= {4, 4},
	NpcIndex5	 	= {5, 5},
	NpcIndex6	 	= {6, 6},
	NpcIndex7	 	= {7, 7},
	NpcIndex8	 	= {8, 8},
	NpcIndex9	 	= {9, 9},
	NpcIndex10	 	= {10, 10},
	NpcIndex11	 	= {11, 11},
	NpcIndex12	 	= {12, 12},
	NpcIndex13	 	= {13, 13},
	NpcIndex14	 	= {14, 14},
	NpcIndex15	 	= {15, 15},
	NpcIndex16	 	= {16, 16},
	NpcIndex17	 	= {17, 17},
	NpcIndex18	 	= {18, 18},
	NpcIndex19	 	= {19, 19},
	NpcIndex20	 	= {20, 20},
	NpcIndex21	 	= {21, 21},
	NpcIndex22	 	= {22, 22},
	NpcIndex23	 	= {23, 23},
	NpcNum1 		= {1, 1},
	NpcNum2 		= {2, 2},
	NpcNum3 		= {3, 3},
	NpcNum4 		= {4, 4},
	NpcNum5 		= {5, 5},
	NpcNum6 		= {6, 6},
	NpcNum7 		= {7, 7},
	NpcNum8 		= {8, 8},
	NpcNum9 		= {9, 9},
	NpcNum10 		= {10, 10},
	NpcNum11 		= {11, 11},
	NpcNum12 		= {12, 12},
	NpcNum13 		= {13, 13},
	NpcNum14 		= {14, 14},
	NpcNum15 		= {15, 15},
	NpcNum16 		= {16, 16},
	NpcNum17 		= {17, 17},
	NpcNum18 		= {18, 18},
	LockNum1		= {3, 6},
	LockNum2		= {7, 12},
	LockNum3		= {1, 1},
}

tbFubenSetting.ANIMATION = 
{
	[1] = "Scenes/camera/Main Camera.controller",
}

--NPC模版ID，NPC等级，NPC五行；
--[[

]]

tbFubenSetting.NPC = 
{
	[1]  = {nTemplate = 61,   nLevel = -1, nSeries = -1},  --南宫灭
	[2]  = {nTemplate = 963,  nLevel = -1, nSeries = -1},  --张风
	[3]  = {nTemplate = 964,  nLevel = -1, nSeries = -1},  --方勉
	[4]  = {nTemplate = 977,  nLevel = -1, nSeries = -1},  --金兵
	[5]  = {nTemplate = 978,  nLevel = -1, nSeries = -1},  --百夫长
	[6]  = {nTemplate = 1633, nLevel = -1, nSeries = -1},  --东瀛忍者（分身）
	[7]  = {nTemplate = 1634, nLevel = -1, nSeries = -1},  --五色教弟子
	[8]  = {nTemplate = 1635, nLevel = -1, nSeries = -1},  --五色教杀手
	[9]  = {nTemplate = 1636, nLevel = -1, nSeries = -1},  --五色教头目
	[10] = {nTemplate = 1637, nLevel = -1, nSeries = -1},  --傀儡机关人
	[11] = {nTemplate = 1638, nLevel = -1, nSeries = -1},  --机关战车
	[12] = {nTemplate = 1639, nLevel = -1, nSeries = -1},  --强力机关人
	[13] = {nTemplate = 1640, nLevel = -1, nSeries = -1},  --制式机关人
	[14] = {nTemplate = 1641, nLevel = -1, nSeries = -1},  --劲弩手
	[15] = {nTemplate = 1642, nLevel = -1, nSeries = -1},  --玄天武机
	[16] = {nTemplate = 1643, nLevel = -1, nSeries = -1},  --玄天武机（变身）
	[17] = {nTemplate = 104,  nLevel = -1, nSeries = 0},   --动态障碍墙
	[18] = {nTemplate = 983,  nLevel = -1, nSeries = 0},   --吊桥机关

	[19] = {nTemplate = 1644, nLevel = -1, nSeries = 0},   --放技能NPC
	[20] = {nTemplate = 1645, nLevel = -1, nSeries = 0},   --影分身
	[21] = {nTemplate = 989,  nLevel = -1, nSeries = 0},   --独孤剑
	[22] = {nTemplate = 1494, nLevel = -1, nSeries = 0},   --曲霞
	[23] = {nTemplate = 1663, nLevel = -1, nSeries = 0},   --五色教堂主
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
			{"SetShowTime", 22},	

			--设置同步范围
			{"SetNearbyRange", 3},		
		},
	},
	[2] = {nTime = 0, nNum = 1,
		tbPrelock = {1},
		tbStartEvent = 
		{
			{"TrapUnlock", "TrapLock1", 2},
			{"SetTargetPos", 4325, 5578},
			{"AddNpc", "NpcIndex17", 1, 1, "wall", "wall_1_1", false, 2},
			{"SetFubenProgress", -1,"探索熔火霹靂"},

			--金兵 & 百夫长
			{"AddNpc", "NpcIndex4", "NpcNum5", 3, "guaiwu", "TeamFuben3_1_1", false, 0, 0, 0, 0},
			{"AddNpc", "NpcIndex5", "NpcNum1", 3, "Elite", "TeamFuben3_1_2_Elite", false, 0, 0, 0, 0}, 
		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},
			{"SetFubenProgress", -1,"擊敗金兵"},
			{"NpcBubbleTalk", "Elite", "來者何人！竟敢擅闖我五色教禁地，真是自尋死路！", 4, 0, 1},

			--金兵 & 劲弩手
			{"AddNpc", "NpcIndex4", "NpcNum6", 3, "guaiwu", "TeamFuben3_1_3", false, 0, 3, 9005, 0.5},
			{"AddNpc", "NpcIndex14", "NpcNum4", 3, "guaiwu", "TeamFuben3_1_3", false, 0, 6, 9005, 0.5},
		},
	},	
	[3] = {nTime = 0, nNum = "NpcNum16",
		tbPrelock = {1},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"SetFubenProgress", -1,"探索熔火霹靂"},
			{"OpenDynamicObstacle", "ops1"},
			{"SetTargetPos", 6195,4594},
			{"DoDeath", "wall"},
			{"AddNpc", "NpcIndex17", 1, 1, "wall", "wall_1_2", false, 48},	
			{"TrapUnlock", "TrapLock2", 4},			
			{"TrapCastSkill", "BuffPoint1", 1507, 1, -1, -1, 1, 203, 6906, 2864},
			{"RaiseEvent", "AddMissionScore", 10},

			--张风
			{"AddNpc", "NpcIndex2", "NpcNum1", 5, "Leader", "TeamFuben3_Leader_1", false, 55, 0, 0, 0},
			{"NpcHpUnlock", "Leader", 30, 80},
			{"SetNpcProtected", "Leader", 1},
		},
	},	
	[4] = {nTime = 0, nNum = 1,
		tbPrelock = {3},
		tbStartEvent = 
		{
			{"TrapUnlock", "TrapLock2", 4},
		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},
			{"SetNpcProtected", "Leader", 0},
			{"NpcBubbleTalk", "Leader", "居然是你們？你們不該來這裡的！", 4, 1, 1},
			{"SetFubenProgress", -1,"擊敗張風"},

			--金兵 
			{"AddNpc", "NpcIndex4", "NpcNum5", 0, "guaiwu", "TeamFuben3_Area1_1", false, 0, 4, 9005, 0.5},
		},
	},
	[30] = {nTime = 0, nNum = 1,
		tbPrelock = {4},
		tbStartEvent = 
		{		
		},
		tbUnLockEvent = 
		{
			{"NpcBubbleTalk", "Leader", "果然不錯！但就憑這樣你們還無法通過這裡！！", 4, 1, 1},	
			{"NpcHpUnlock", "Leader", 31, 40},

			--东瀛忍者
			{"AddNpc", "NpcIndex6", "NpcNum1", 60, "guaiwu", "TeamFuben3_Area1_Fenshen1", false, 0, 0, 9009, 0.5},

			--影分身
			{"StartTimeCycle", "cycle_1", 5, 100, {"AddNpc", 20, 4, 0, "Fenshen", "TeamFuben3_Fenshen1", false, 0, 0, 9009, 0.5}},
			{"BlackMsg", "[FFFE0D]東瀛忍者[-]會不斷[FFFE0D]召喚分身[-]，請優先將其擊殺！"},
		},
	},
	[31] = {nTime = 0, nNum = 1,
		tbPrelock = {30},
		tbStartEvent = 
		{				
		},
		tbUnLockEvent = 
		{	
			{"NpcBubbleTalk", "Leader", "可惡... 沒想到竟會如此棘手！！", 4, 1, 1},

			--东瀛忍者
			{"AddNpc", "NpcIndex6", "NpcNum1", 61, "guaiwu", "TeamFuben3_Area1_Fenshen2", false, 0, 0, 9009, 0.5},
			{"AddNpc", "NpcIndex6", "NpcNum1", 62, "guaiwu", "TeamFuben3_Area1_Fenshen3", false, 0, 0, 9009, 0.5},

			--影分身
			{"StartTimeCycle", "cycle_2", 5, 100, {"AddNpc", 20, 3, 0, "Fenshen", "TeamFuben3_Fenshen2", false, 0, 0, 9009, 0.5}},
			{"StartTimeCycle", "cycle_3", 5, 100, {"AddNpc", 20, 3, 0, "Fenshen", "TeamFuben3_Fenshen3", false, 0, 0, 9009, 0.5}},
			{"BlackMsg", "[FFFE0D]東瀛忍者[-]會不斷[FFFE0D]召喚分身[-]，請優先將其擊殺！"},
		},
	},

	--忍者被杀时的锁
	[60] = {nTime = 0, nNum = 1,
		tbPrelock = {4},
		tbStartEvent = 
		{

		},
		tbUnLockEvent = 
		{
			--关闭循环
			{"CloseCycle", "cycle_1"},
		},
	},
	[61] = {nTime = 0, nNum = 1,
		tbPrelock = {4},
		tbStartEvent = 
		{

		},
		tbUnLockEvent = 
		{
			--关闭循环
			{"CloseCycle", "cycle_2"},
		},
	},
	[62] = {nTime = 0, nNum = 1,
		tbPrelock = {4},
		tbStartEvent = 
		{

		},
		tbUnLockEvent = 
		{
			--关闭循环
			{"CloseCycle", "cycle_3"},
		},
	},

	--忍者召唤分身上限的时间锁
	[63] = {nTime = 16, nNum = 0,
		tbPrelock = {30},
		tbStartEvent = 
		{

		},
		tbUnLockEvent = 
		{
			--关闭循环
			{"CloseCycle", "cycle_1"},
		},
	},
	[64] = {nTime = 16, nNum = 0,
		tbPrelock = {31},
		tbStartEvent = 
		{

		},
		tbUnLockEvent = 
		{
			--关闭循环
			{"CloseCycle", "cycle_2"},
			{"CloseCycle", "cycle_3"},
		},
	},


	[5] = {nTime = 0, nNum = 1,
		tbPrelock = {3},
		tbStartEvent = 
		{

		},
		tbUnLockEvent = 
		{
			{"SetFubenProgress", -1,"探索熔火霹靂"},
			{"SetTargetPos", 6646, 2450},	
			{"OpenDynamicObstacle", "ops2"},
			{"RaiseEvent", "AddMissionScore", 10},
			{"DoDeath", "wall"},
			{"AddNpc", "NpcIndex17", 1, 1, "wall", "wall_1_3", false, 36},	

			--秒杀小兵
			{"CastSkill", "guaiwu", 3, 1, -1, -1},			

			{"StartTimeCycle", "cycle_4", 1, 3, 
				{"CastSkill", "Fenshen", 3, 1, -1, -1},
			},

			--独孤剑
			{"AddNpc", "NpcIndex21", "NpcNum1", 0, "Temporary", "TeamFuben3_Dugujian", false, 35, 0, 0, 0},
			{"SetNpcProtected", "Temporary", 1},

			--重新设置复活点
			{"SetDynamicRevivePoint", 6804, 4241},
		},
	},
	[6] = {nTime = 0, nNum = 1,
		tbPrelock = {5},
		tbStartEvent = 
		{
			{"TrapUnlock", "TrapLock3", 6},

			--五色教弟子 & 五色教头目
			{"AddNpc", "NpcIndex7", "NpcNum5", 7, "guaiwu", "TeamFuben3_2_1", false, 0, 0, 0, 0},
			{"AddNpc", "NpcIndex9", "NpcNum1", 7, "Elite", "TeamFuben3_2_2_Elite", false, 0, 0, 0, 0}, 
		},
		tbUnLockEvent = 
		{
			--关闭循环
			{"CloseCycle", "cycle_4"},

			{"ClearTargetPos"},
			{"SetNpcProtected", "Temporary", 0},
			{"SetFubenProgress", -1,"擊敗五色教弟子"},
			{"NpcBubbleTalk", "Elite", "來者何人！竟敢擅闖我五色教禁地，真是自尋死路！", 4, 0, 1},	

			--劲弩手 & 五色教弟子
			{"AddNpc", "NpcIndex7", "NpcNum6", 7, "guaiwu", "TeamFuben3_2_3", false, 0, 3, 9005, 0.5},
			{"AddNpc", "NpcIndex14",  "NpcNum4", 7, "guaiwu", "TeamFuben3_2_3", false, 0, 6, 9005, 0.5},
		},
	},
	[7] = {nTime = 0, nNum = "NpcNum16",
		tbPrelock = {5},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{	
			{"SetFubenProgress", -1,"探索熔火霹靂"},
			{"BlackMsg", "與獨孤劍一同前行！"},
			{"NpcBubbleTalk", "Temporary", "多謝諸位出手相助，此處危險重重，不如我們結伴前行吧！", 4, 0, 1},
			{"OpenDynamicObstacle", "ops3"},
			{"SetTargetPos", 4825, 2723},		
			{"DoDeath", "wall"},
			{"AddNpc", "NpcIndex17", 1, 1, "wall", "wall_1_4", false, 22},
			{"RaiseEvent", "AddMissionScore", 10},
			{"TrapUnlock", "TrapLock4", 10},
			{"TrapCastSkill", "BuffPoint2", 1507, 1, -1, -1, 1, 203, 3689, 1991},

			--独孤剑移动
			{"ChangeNpcAi", "Temporary", "Move", "Path1", 0, 1, 1, 0},

			--方勉
			{"AddNpc", "NpcIndex3", "NpcNum1", 9, "Leader1", "TeamFuben3_Leader_2", false, 0, 0, 0, 0},
			{"SetNpcProtected", "Leader1", 1},

			--放技能NPC
			{"AddNpc", "NpcIndex19", "NpcNum1", 0, "SkillNpc", "TeamFuben3_SkillNpc1", false, 0, 0, 0, 0},
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
			{"SetFubenProgress", -1,"擊敗方勉"},
			{"SetNpcProtected", "Leader1", 0},
			{"NpcBubbleTalk", "Leader1", "來者何人，竟敢擅闖我五色教禁地！！", 3, 0, 1},
			{"NpcBubbleTalk", "Temporary", "方... 方勉！！！沒想到你竟然是五色教的人！！身為中原武林總堂主，你為何要投敵賣國！！", 3, 3, 1},
			{"NpcBubbleTalk", "Leader1", "獨孤劍，居然是你！哼，你也無須多言，擅闖我教禁地今日你必死無疑！！", 3, 6, 1},
			{"NpcHpUnlock", "Leader1", 32, 80},

			--五色教弟子 
			{"AddNpc", "NpcIndex7", "NpcNum6", 0, "guaiwu", "TeamFuben3_Area2_1", false, 0, 3, 9005, 0.5},
		},
	},
	[32] = {nTime = 0, nNum = 1,
		tbPrelock = {8},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{	
			{"NpcBubbleTalk", "Leader1", "你們無法再進一步！也休想活著離開這裡！", 4, 0, 1},	
			{"NpcHpUnlock", "Leader1", 34, 40},

			--五色教弟子 & 五色教杀手
			{"AddNpc", "NpcIndex7", "NpcNum4", 0, "guaiwu", "TeamFuben3_Area2_1", false, 0, 2, 9005, 0.5},
			{"AddNpc", "NpcIndex8", "NpcNum4", 0, "guaiwu", "TeamFuben3_Area2_2", false, 0, 4, 9005, 0.5},

		},
	},
	[33] = {nTime = 1, nNum = 0,
		tbPrelock = {32},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{	
			{"BlackMsg", "地底熔岩即將噴發，請盡速躲入[FFFE0D]安全區域[-]！！"},

			--熔岩喷发
			{"SetNpcAi", "SkillNpc", "Setting/Npc/Ai/teamfb/60fb_Rongyan.ini"},
		},
	},
	[34] = {nTime = 0, nNum = 1,
		tbPrelock = {32},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{	
			{"NpcBubbleTalk", "Leader1", "可惡的傢伙，你們已經成功將我激怒！！準備好領死吧！！！", 4, 0, 1},	

			--五色教杀手 & 五色教头目
			{"AddNpc", "NpcIndex8", "NpcNum6", 0, "guaiwu", "TeamFuben3_Area2_2", false, 0, 2, 9005, 0.5},
			{"AddNpc", "NpcIndex9", "NpcNum2", 0, "guaiwu", "TeamFuben3_Area2_Elite", false, 0, 4, 9005, 0.5},
		},
	},
	[9] = {nTime = 0, nNum = 1,
		tbPrelock = {7},
		tbStartEvent = 
		{		
		},
		tbUnLockEvent = 
		{	
			{"SetFubenProgress", -1,"探索熔火霹靂"},
			{"OpenDynamicObstacle", "ops4"},
			{"SetTargetPos", 3421, 1540},		
			{"RaiseEvent", "AddMissionScore", 10},
			{"DoDeath", "wall"},
			{"AddNpc", "NpcIndex17", 1, 1, "wall", "wall_1_5", false, 40},

			--删除放技能NPC
			{"DelNpc", "SkillNpc"},

			--秒杀小兵
			{"CastSkill", "guaiwu", 3, 1, -1, -1},

			--独孤剑移动
			{"ChangeNpcAi", "Temporary", "Move", "Path2", 0, 1, 1, 0},

			--重新设置复活点
			{"SetDynamicRevivePoint", 4291, 2906},
		},
	},


	[10] = {nTime = 0, nNum = 1,
		tbPrelock = {9},
		tbStartEvent = 
		{
			{"TrapUnlock", "TrapLock5", 10},

			--傀儡机关人 & 强力机关人
			{"AddNpc", "NpcIndex10", "NpcNum5", 11, "guaiwu", "TeamFuben3_3_1", false, 0, 0, 0, 0},
			{"AddNpc", "NpcIndex12", "NpcNum1", 11, "Elite", "TeamFuben3_3_2_Elite", false, 0, 0, 0, 0}, 	
		},
		tbUnLockEvent = 
		{	
			{"ClearTargetPos"},	
			{"SetFubenProgress", -1,"擊敗機關人"},
			{"AddNpc", "NpcIndex11", "NpcNum6", 11, "guaiwu", "TeamFuben3_3_3", false, 0, 3, 9005, 0.5},
			{"AddNpc", "NpcIndex10", "NpcNum4", 11, "guaiwu", "TeamFuben3_3_3", false, 0, 4, 9005, 0.5}, 
		},
	},
	[11] = {nTime = 0, nNum = "NpcNum16",
		tbPrelock = {9},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"SetFubenProgress", -1,"探索熔火霹靂"},
			{"OpenDynamicObstacle", "ops5"},
			{"SetTargetPos", 1677, 1963},		
			{"RaiseEvent", "AddMissionScore", 10},
			{"DoDeath", "wall"},
			{"AddNpc", "NpcIndex17", 1, 1, "wall", "wall_1_6", false, 16},

			--独孤剑移动
			{"ChangeNpcAi", "Temporary", "Move", "Path3", 0, 1, 1, 0},

			--稀有几率
			{"Random", {350000, 100}},
		},
	},

	--稀有锁
	[100] = {nTime = 0, nNum = 1,
		tbPrelock = {},
		tbStartEvent = 
		{
			{"TrapUnlock", "Xiyou", 100},

			{"SetTargetPos", 1614, 2043},	

			--关闭锁
			{"CloseLock", 12, 13},

			--曲霞 & 稀有怪物
			{"AddNpc", "NpcIndex23", "NpcNum1", 103, "Xiyou", "TeamFuben3_Xiyou", false, 7, 0, 0, 0},
			{"AddNpc", "NpcIndex22", "NpcNum1", 0, "Quxia", "TeamFuben3_Quxia", false, 38, 0, 0, 0},
			{"NpcHpUnlock", "Xiyou", 101, 70},

			{"SetNpcProtected", "Xiyou", 1},
			{"SetNpcProtected", "Quxia", 1},
		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},	
			{"BlackMsg", "前方似乎有位姑娘遇到了麻煩！"},
			{"NpcBubbleTalk", "Xiyou", "哈哈哈，獨身一人竟敢擅闖我五色教的地盤，真是不知死活！！", 3, 0, 1},
			{"NpcBubbleTalk", "Temporary", "師妹！！你怎麼會在這裡！！！", 3, 1, 1},
			{"NpcBubbleTalk", "Quxia", "師兄！！沒想到真的是你！！", 3, 3, 1},
			{"NpcBubbleTalk", "Temporary", "師妹，你且退後休息，這傢伙就交給我們來對付吧！！", 3, 6, 1},
			{"NpcBubbleTalk", "Xiyou", "哈哈，大言不慚的小子！你們一併領死吧！！！", 3, 9, 1},

			{"SetNpcProtected", "Xiyou", 0},
			{"SetNpcProtected", "Quxia", 0},
		},
	},
	[101] = {nTime = 0, nNum = 1,
		tbPrelock = {100},
		tbStartEvent = 
		{
			
		},
		tbUnLockEvent = 
		{
			{"NpcBubbleTalk", "Xiyou", "沒想到你們倒還有兩下子嘛，但這還遠遠不夠！！", 3, 0, 1},
			{"NpcHpUnlock", "Xiyou", 102, 40},
		},
	},
	[102] = {nTime = 0, nNum = 1,
		tbPrelock = {101},
		tbStartEvent = 
		{
			
		},
		tbUnLockEvent = 
		{
			{"NpcBubbleTalk", "Xiyou", "可惡的傢伙，你們成功把我激怒了，準備好領死吧！！！", 3, 0, 1},
		},
	},
	[103] = {nTime = 0, nNum = 1,
		tbPrelock = {100},
		tbStartEvent = 
		{
			
		},
		tbUnLockEvent = 
		{
			{"DoDeath", "wall"},
			{"OpenDynamicObstacle", "ops6"},
			{"SetFubenProgress", -1,"探索熔火霹靂"},
			{"SetNpcProtected", "Quxia", 1},
			{"NpcBubbleTalk", "Temporary", "師妹，此事就交給我吧！！你趕緊離開這裡！！", 3, 0, 1},
			{"NpcBubbleTalk", "Quxia", "師兄... 切記萬事小心！！", 3, 0, 1},

			--吊桥机关
			{"AddNpc", "NpcIndex18", "NpcNum1", 14, "jiguan", "TeamFuben3_jiguan", false, 0, 0, 0, 0},
			{"PlaySceneAnimation", "fb_cangjian_kaiguan", "sta", 1, false},	
			{"SetTargetPos", 1920, 4501},

			--独孤剑移动
			{"ChangeNpcAi", "Temporary", "Move", "Path4", 0, 1, 1, 0},
		},
	},


	[12] = {nTime = 0, nNum = 1,
		tbPrelock = {11},
		tbStartEvent = 
		{
			{"TrapUnlock", "TrapLock6", 12},

			--傀儡机关人 & 机关战车 & 强力机关人
			{"AddNpc", "NpcIndex10", "NpcNum2", 13, "guaiwu", "TeamFuben3_4_1", false, 0, 0, 0, 0},
			{"AddNpc", "NpcIndex11", "NpcNum3", 13, "guaiwu", "TeamFuben3_4_2", false, 0, 0, 0, 0},
			{"AddNpc", "NpcIndex12", "NpcNum1", 13, "guaiwu", "TeamFuben3_4_3", false, 0, 0, 0, 0}, 	
		},
		tbUnLockEvent = 
		{	
			{"ClearTargetPos"},	
			{"SetFubenProgress", -1,"擊敗機關人"},
			{"AddNpc", "NpcIndex10", "NpcNum4", 13, "guaiwu", "TeamFuben3_4_4", false, 0, 3, 9005, 0.5},
			{"AddNpc", "NpcIndex11", "NpcNum4", 13, "guaiwu", "TeamFuben3_4_6", false, 0, 3, 9005, 0.5},
		},
	},
	[13] = {nTime = 0, nNum = "NpcNum14",
		tbPrelock = {11},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{	
			{"DoDeath", "wall"},
			{"OpenDynamicObstacle", "ops6"},
			{"SetFubenProgress", -1,"探索熔火霹靂"},

			--吊桥机关
			{"AddNpc", "NpcIndex18", "NpcNum1", 14, "jiguan", "TeamFuben3_jiguan", false, 0, 0, 0, 0},
			{"PlaySceneAnimation", "fb_cangjian_kaiguan", "sta", 1, false},	
			{"SetTargetPos", 1920, 4501},

			--独孤剑移动
			{"ChangeNpcAi", "Temporary", "Move", "Path4", 0, 1, 1, 0},
		},
	},

	--吊桥机关击杀锁
	[14] = {nTime = 0, nNum = 1,
		tbPrelock = {11},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"PlaySceneAnimation", "fb_cangjian_kaiguan", "die", 1, false},
			{"RaiseEvent", "AddMissionScore", 10},
		},
	},
	[15] = {nTime = 1.5, nNum = 0,
		tbPrelock = {14},
		tbStartEvent = 
		{			
		},
		tbUnLockEvent = 
		{		
			{"PlayCameraAnimation", 1, nil},    -- 播放摄像机动画			
			{"SetAllUiVisiable", false}, 		--显示/隐藏UI			
			{"AddBuff", 1058, 1, 10.2, 0, 0},	--加定身BUFF
		},
	},
	[16] = {nTime = 2.7, nNum = 0,
		tbPrelock = {15},
		tbStartEvent = 
		{			
		},
		tbUnLockEvent = 
		{		
			{"PlaySceneAnimation", "fb_cangjian_zhizhu01", "wind", 1, false},
		},
	},
	[17] = {nTime = 1, nNum = 0,
		tbPrelock = {16},
		tbStartEvent = 
		{			
		},
		tbUnLockEvent = 
		{					
			{"PlaySceneAnimation", "fb_cangjian_chilun02", "wind2", 0.1, false},
		},
	},
	[18] = {nTime = 1.5, nNum = 0,
		tbPrelock = {17},
		tbStartEvent = 
		{			
		},
		tbUnLockEvent = 
		{		
			{"PlaySceneAnimation", "fb_cangjian_lianjie01", "wind2", 1, false},	
		},
	},
	[19] = {nTime = 3.5, nNum = 0,
		tbPrelock = {18},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"OpenDynamicObstacle", "ops7"},
			{"LeaveAnimationState", true},						--摄像机动画结束，视角切回玩家
			{"SetForbiddenOperation", false},					--解开操作
			{"SetAllUiVisiable", true}, 						--显示UI		

			{"RemovePlayerSkillState", 1058},					--移除定身

			--重新设置复活点
			{"SetDynamicRevivePoint", 1889, 3979},

			--独孤剑移动
			{"ChangeNpcAi", "Temporary", "Move", "Path5", 0, 1, 1, 0},

			--南宫灭
			{"AddNpc", "NpcIndex1", "NpcNum1", 21, "BOSS", "TeamFuben3_BOSS", false, 32, 0, 0, 0},
			{"NpcHpUnlock", "BOSS", 37, 70},
			{"SetNpcProtected", "BOSS", 1},
			{"SetAiActive", "BOSS", 0},

			--放技能NPC
			{"AddNpc", "NpcIndex19", "NpcNum1", 0, "SkillNpc", "TeamFuben3_Jiguang1", false, 0, 0, 0, 0},
			{"AddNpc", "NpcIndex19", "NpcNum1", 0, "SkillNpc", "TeamFuben3_Jiguang2", false, 0, 0, 0, 0},
		},
	},
	[20] = {nTime = 0, nNum = 1,
		tbPrelock = {19},
		tbStartEvent = 
		{		
			{"TrapUnlock", "TrapLock7", 20},	
		},
		tbUnLockEvent = 
		{	
			{"ClearTargetPos"},		
			{"SetNpcBloodVisable", "BOSS", false, 0},
			{"SetFubenProgress", -1,"擊敗南宮滅"},
			{"NpcBubbleTalk", "BOSS", "不得不讚歎你們的實力，但你們接下來你們將面對我！", 3, 0, 1},
			{"NpcBubbleTalk", "Temporary", "南宮滅！少在那裡說大話了，我們手底下見真章吧！！", 3, 2, 1},
			{"NpcBubbleTalk", "BOSS", "獨孤劍，你屢次破壞我教大事，老夫正愁沒機會解決掉你，沒想到今日你卻送上門來了！", 3, 5, 1},
			{"NpcBubbleTalk", "BOSS", "老夫這就送你們去見閻王，領死吧！！！", 3, 8, 1},
		},
	},
	[36] = {nTime = 9, nNum = 0,
		tbPrelock = {20},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{	
			{"SetNpcProtected", "BOSS", 0},
			{"SetAiActive", "BOSS", 1},
			{"SetNpcBloodVisable", "BOSS", true, 0},

			--制式机关人
			{"AddNpc", "NpcIndex13", "NpcNum6", 0, "guaiwu", "TeamFuben3_Area3_1", false, 0, 3, 9005, 0.5},
		},
	},
	[37] = {nTime = 0, nNum = 1,
		tbPrelock = {20},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{	
			{"NpcBubbleTalk", "BOSS", "遊戲結束了！就讓你們見識一下我機關之術的威力吧！", 4, 1, 1},				
			{"NpcHpUnlock", "BOSS", 40, 40},

			--玄天武机			
			{"AddNpc", "NpcIndex15", "NpcNum1", 38, "Bianshen", "TeamFuben3_Area3_Bianshen", false, 48, 0, 9005, 0.5},
			{"SaveNpcInfo", "Bianshen"},
			{"BlackMsg", "玄天武機出現！將其擊敗後可以駕駛機關攻擊敵人！"},
		},
	},

	--喷激光的时间锁
	[110] = {nTime = 5, nNum = 0,
		tbPrelock = {37},
		tbStartEvent =
		{
		},
		tbUnLockEvent =
		{
			--喷激光
			-- {"SetNpcAi", "SkillNpc", "Setting/Npc/Ai/teamfb/60fb_Jiguang.ini"},
		},
	},
	[38] = {nTime = 0, nNum = 1,
		tbPrelock = {37},
		tbStartEvent =
		{
		},
		tbUnLockEvent =
		{
			{"AddNpc", "NpcIndex16", "NpcNum1", 0, "Bianshen", "SAVE_POS", false, "SAVE_DIR", 0, 0, 0},
		},
	},
	[39] = {nTime = 3, nNum = 0,
		tbPrelock = {38},
		tbStartEvent =
		{
		},
		tbUnLockEvent =
		{
			{"BlackMsg", "出現大量機關人！利用玄天武機擊退機關人！！"},

			--制式机关人
			{"AddNpc", "NpcIndex13", "NpcNum8", 0, "guaiwu", "TeamFuben3_Area3_2", false, 0, 3, 9005, 0.5},
			{"AddNpc", "NpcIndex13", "NpcNum8", 0, "guaiwu", "TeamFuben3_Area3_2", false, 0, 6, 9005, 0.5},
		},
	},
	[40] = {nTime = 0, nNum = 1,
		tbPrelock = {37},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{	
			{"NpcBubbleTalk", "BOSS", "不要做徒勞的掙扎了，你們的死亡是必然的結局！", 4, 1, 1},	

			--玄天武机			
			{"AddNpc", "NpcIndex15", "NpcNum1", 41, "Bianshen", "TeamFuben3_Area3_Bianshen", false, 48, 0, 9005, 0.5},
			{"SaveNpcInfo", "Bianshen"},
			{"BlackMsg", "玄天武機出現！將其擊敗後可以駕駛機關攻擊敵人！"},
		},
	},
	[41] = {nTime = 0, nNum = 1,
		tbPrelock = {40},
		tbStartEvent =
		{
		},
		tbUnLockEvent =
		{
			{"AddNpc", "NpcIndex16", "NpcNum1", 0, "Bianshen", "SAVE_POS", false, "SAVE_DIR", 0, 0, 0},
		},
	},
	[42] = {nTime = 3, nNum = 0,
		tbPrelock = {41},
		tbStartEvent =
		{
		},
		tbUnLockEvent =
		{
			{"BlackMsg", "出現大量機關人！利用玄天武機擊退機關人！！"},

			--制式机关人
			{"AddNpc", "NpcIndex13", "NpcNum8", 0, "guaiwu", "TeamFuben3_Area3_2", false, 0, 3, 9005, 0.5},
			{"AddNpc", "NpcIndex13", "NpcNum8", 0, "guaiwu", "TeamFuben3_Area3_2", false, 0, 6, 9005, 0.5},
		},
	},
	[21] = {nTime = 0, nNum = 1,
		tbPrelock = {19},
		tbStartEvent = 
		{

		},
		tbUnLockEvent = 
		{			
			{"RaiseEvent", "AddMissionScore", 15},
			{"RemovePlayerSkillState", 2216},
			{"SetFubenProgress", -1,"闖關成功"},
			{"OpenWindow", "LingJueFengLayerPanel", "Win"},
			{"RaiseEvent", "KickOutAllPlayer", 70},
			{"BlackMsg", "闖關成功！篝火已刷出，可持續獲得經驗！"},
			{"GameWin"},
			{"AddSimpleNpc", 1610, 1843, 5668, 0},
		},
	},
	[22] = {nTime = 900, nNum = 0,
		tbPrelock = {1},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"SetFubenProgress", -1,"闖關失敗"},
			{"BlackMsg", "時間耗盡，本次挑戰失敗！"},
			{"RaiseEvent", "KickOutAllPlayer", 10},
			{"OpenWindow", "LingJueFengLayerPanel", "Fail"},
			{"GameLost"},
		},
	},
}