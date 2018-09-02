
local tbFubenSetting = {};
Fuben:SetFubenSetting(301, tbFubenSetting)		-- 绑定副本内容和地图

tbFubenSetting.szFubenClass 			= "TeamFubenBase";									-- 副本类型
tbFubenSetting.szName 					= "武夷禁地"										-- 单纯的名字，后台输出或统计使用
tbFubenSetting.szNpcPointFile 			= "Setting/Fuben/TeamFuben/1_2/NpcPos.tab"			-- NPC点
tbFubenSetting.szPathFile 				= "Setting/Fuben/TeamFuben/1_2/NpcPath.tab"				-- 寻路点
tbFubenSetting.tbMultiBeginPoint        = {{1940, 3337},{2228, 3369},{1926, 3659},{2214, 3641}}	-- 副本出生点
tbFubenSetting.tbTempRevivePoint 		= {2082, 3270}											-- 临时复活点，副本内有效，出副本则移除
tbFubenSetting.nStartDir				= 0;													-- 方向


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
	LockNum1		= {3, 6},
	LockNum2		= {7, 12},
	LockNum3		= {1, 1},
}

tbFubenSetting.ANIMATION = 
{
	[1] = "Scenes/Maps/fb_cangjian/Main Camera.controller",
}

--NPC模版ID，NPC等级，NPC五行；
--[[

]]

tbFubenSetting.NPC = 
{
	[1] = {nTemplate = 56,   nLevel = -1, nSeries = -1},  --张琳心
	[2] = {nTemplate = 961,  nLevel = -1, nSeries = -1},  --张如梦
	[3] = {nTemplate = 962,  nLevel = -1, nSeries = -1},  --南宫彩虹
	[4] = {nTemplate = 979,  nLevel = -1, nSeries = -1},  --五色教弟子
	[5] = {nTemplate = 980,  nLevel = -1, nSeries = -1},  --五色教头目
	[6] = {nTemplate = 977,  nLevel = -1, nSeries = -1},  --金兵
	[7] = {nTemplate = 981,  nLevel = -1, nSeries = -1},  --十夫长
	[8] = {nTemplate = 978,  nLevel = -1, nSeries = -1},  --百夫长
	[9] = {nTemplate = 985,  nLevel = -1, nSeries = -1},  --五色教女弟子
	[10] = {nTemplate = 986, nLevel = -1, nSeries = -1},  --五色教头领
	[11] = {nTemplate = 987, nLevel = -1, nSeries = -1},  --神秘杀手
	[12] = {nTemplate = 988, nLevel = -1, nSeries = -1},  --杀手头目
	[13] = {nTemplate = 1493,nLevel = -1, nSeries = -1},  --封玉书（稀有）
	[14] = {nTemplate = 997, nLevel = -1, nSeries = 0},  --张琳心（非战斗NPC）
	[15] = {nTemplate = 992, nLevel = -1, nSeries = 0},  --五毒教物资箱
	[16] = {nTemplate = 994, nLevel = -1, nSeries = -1},  --神射手
	[17] = {nTemplate = 995, nLevel = -1, nSeries = -1},  --神秘杀手
	[18] = {nTemplate = 104, nLevel = -1, nSeries = 0},  --动态障碍墙
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
			{"SetShowTime", 28},

			--设置同步范围
			{"SetNearbyRange", 3},
		},
	},
	[2] = {nTime = 0, nNum = 1,
		tbPrelock = {1},
		tbStartEvent = 
		{
			{"ChangeFightState", 1},
			{"TrapUnlock", "TrapLock1", 2},
			{"SetTargetPos", 2090, 4165},
			{"AddNpc", "NpcIndex18", 1, 1, "wall", "wall_1_1", false, 16},
			{"SetFubenProgress", -1,"探索禁地"},
			{"BlackMsg", "五色教與金人正於此處密會，盡速找到他們！"},

			--张琳心
			{"AddNpc", "NpcIndex14", "NpcNum1", 0, "Temporary", "TeamFuben2_Zhanglinxin", false, 0, 0, 0, 0},

			--第一波怪
			{"AddNpc", "NpcIndex4", "NpcNum3", 3, "guaiwu", "TeamFuben2_1_1", false, 0, 0, 9005, 0.5},
			{"AddNpc", "NpcIndex5", "NpcNum1", 3, "guaiwu", "TeamFuben2_1_2", false, 0, 0, 9005, 0.5}, 

		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},
			{"SetFubenProgress", -1,"擊敗五色教弟子"},
			{"AddNpc", "NpcIndex4", "NpcNum4", 3, "guaiwu1", "TeamFuben2_1_3", false, 0, 0, 9005, 0.5}, 
			{"AddNpc", "NpcIndex16", "NpcNum4", 3, "guaiwu", "TeamFuben2_1_4", false, 0, 0, 0, 0}, 
			{"NpcBubbleTalk", "guaiwu", "你是什麼人？竟敢擅闖禁地！", 4, 1, 1},
			{"NpcBubbleTalk", "Temporary", "可惡的傢伙，你們休要阻我！", 3, 3, 1},
		},
	},	
	[3] = {nTime = 0, nNum = "NpcNum12",
		tbPrelock = {1},
		tbStartEvent = 
		{

		},
		tbUnLockEvent = 
		{
			{"SetFubenProgress", -1,"探索禁地"},
			{"OpenDynamicObstacle", "ops1"},
			{"SetTargetPos", 2129,6506},
			{"DoDeath", "wall"},
			{"AddNpc", "NpcIndex18", 1, 1, "wall", "wall_1_2", false, 16},			
			{"TrapCastSkill", "BuffPoint1", 1507, 1, -1, -1, 1, 203, 2079, 8330},
			{"RaiseEvent", "AddMissionScore", 5},
			{"NpcBubbleTalk", "Temporary", "多謝諸位出手相助，這禁地內危險重重，不如我們結伴前行吧！", 3, 0, 1},
			{"BlackMsg", "與張琳心一同前行！"},

			--张琳心移动
			{"ChangeNpcAi", "Temporary", "Move", "Path1", 4, 1, 1, 0},

			--张如梦
			{"AddNpc", "NpcIndex2", "NpcNum1", 0, "Leader", "TeamFuben2_Leader_1", false, 33, 0, 0, 0},
			{"SetNpcProtected", "Leader", 1},
			{"ChangeNpcFightState", "Leader", 0, 2},
			{"SetNpcBloodVisable", "Leader", false, 2},
			{"SetAiActive", "Leader", 0},
		},
	},	
	[4] = {nTime = 0, nNum = 1,
		tbPrelock = {3},
		tbStartEvent = 
		{

		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},
			{"NpcHpUnlock", "Leader", 51, 80},	
			{"NpcBubbleTalk", "Leader", "琳心，你怎麼會在這裡！", 3, 0, 1},
			{"NpcBubbleTalk", "Temporary", "哥，我要協助你查出五色教的陰謀！", 3, 2, 1},
			{"NpcBubbleTalk", "Leader", "真是胡鬧！這裡危險重重，你一個女孩子家湊什麼熱鬧，快給我離開這裡！", 3, 5, 1},
			{"NpcBubbleTalk", "Temporary", "哥，我心意已決，既然如此那琳心就得罪了！", 3, 8, 1},
			{"NpcBubbleTalk", "Leader", "琳心！你....", 4, 9, 1},
		},
	},
	[50] = {nTime = 9, nNum = 0,
		tbPrelock = {4},
		tbStartEvent = 
		{		
		},
		tbUnLockEvent = 
		{	
			{"SetFubenProgress", -1,"擊敗張如夢"},
			{"SetNpcProtected", "Leader", 0},
			{"ChangeNpcFightState", "Leader", 1, 1},
			{"SetNpcBloodVisable", "Leader", true, 0},
			{"SetAiActive", "Leader", 1},
		},
	},
	[51] = {nTime = 0, nNum = 1,
		tbPrelock = {50},
		tbStartEvent = 
		{				
		},
		tbUnLockEvent = 
		{	
			{"NpcBubbleTalk", "Leader", "琳心，這武夷禁地危險異常，我是絕不會讓你過去的！", 3, 0, 1},	
			{"NpcBubbleTalk", "Temporary", "哥，我意已決，今日我一定要查出五色教的陰謀！", 3, 3, 1},
			{"NpcBubbleTalk", "Leader", "胡鬧！你若有個三長兩短我如何跟爹交代！", 3, 6, 1},
			{"NpcBubbleTalk", "Temporary", "哥，我心意已決，你不要再說了！", 3, 9, 1},
			{"NpcHpUnlock", "Leader", 52, 50},		
		},
	},
	[52] = {nTime = 0, nNum = 1,
		tbPrelock = {51},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{	
			{"NpcBubbleTalk", "Leader", "琳心，你連我的話都不聽了嗎！", 4, 1, 1},	
			{"NpcBubbleTalk", "Temporary", "哥，我心意已決，你不要再說了！", 3, 3, 1},
			{"NpcHpUnlock", "Leader", 53, 30},	
		},
	},
	[53] = {nTime = 0, nNum = 1,
		tbPrelock = {52},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{	
			{"NpcBubbleTalk", "Leader", "可惡，沒想到竟會如此棘手！", 4, 1, 1},		
			{"NpcHpUnlock", "Leader", 5, 1},
		},
	},
	[5] = {nTime = 0, nNum = 1,
		tbPrelock = {4},
		tbStartEvent = 
		{

		},
		tbUnLockEvent = 
		{
			--奖励掉落
			{"RaiseEvent", "DropAward", "Setting/Npc/DropFile/TeamFuben/zhangrumeng.tab", 1993, 6749},
			--{"RaiseEvent", "DropAward", "Setting/Npc/DropFile/TeamFuben/zhangrumeng.tab", 2229, 6775},	
			{"NpcBubbleTalk", "Leader", "罷了... 你們過去吧，這禁地內危險重重，你且記得萬事小心！", 4, 1, 1},	
			{"SetNpcProtected", "Leader", 1},
			{"ChangeNpcFightState", "Leader", 0, 0},
			{"SetNpcBloodVisable", "Leader", false, 0},
			{"SetAiActive", "Leader", 0},	

			{"SetTargetPos", 2616, 8383},	
			{"OpenDynamicObstacle", "ops2"},
			{"DoDeath", "wall"},
			{"AddNpc", "NpcIndex18", 1, 1, "wall", "wall_1_3", false, 32},	
			{"RaiseEvent", "AddMissionScore", 10},
			{"SetFubenProgress", -1,"探查禁地"},
			{"BlackMsg", "繼續探查禁地！"},

			--张琳心移动
			{"ChangeNpcAi", "Temporary", "Move", "Path2", 6, 0, 0, 0},

			--重新设置复活点
			{"SetDynamicRevivePoint", 2115, 6523},
		},
	},
	[6] = {nTime = 0, nNum = 1,
		tbPrelock = {5},
		tbStartEvent = 
		{

		},	
		tbUnLockEvent = 
		{	
			--张琳心移动
			{"ChangeNpcAi", "Temporary", "Move", "Path3", 7, 1, 1, 0},
		},
	},
	[7] = {nTime = 0, nNum = 1,
		tbPrelock = {5},
		tbStartEvent = 
		{
			{"TrapUnlock", "TrapLock3", 7},	
		},	
		tbUnLockEvent = 
		{	
			{"ClearTargetPos"},
			{"DelNpc", "Leader"},
			{"AddNpc", "NpcIndex6", "NpcNum4", 8, "guaiwu3", "TeamFuben2_2_1", false, 0, 0, 9005, 0.5},
			{"NpcBubbleTalk", "guaiwu3", "你是什麼人！此乃我軍禁地，閒雜人等不得入內！", 4, 1, 1},	
		},
	},
	[8] = {nTime = 0, nNum = "NpcNum4",
		tbPrelock = {7},
		{

		},
		tbUnLockEvent = 
		{
			{"AddNpc", "NpcIndex6", "NpcNum4", 9, "guaiwu4", "TeamFuben2_2_1", false, 0, 0, 9005, 0.5},
			{"AddNpc", "NpcIndex6", "NpcNum2", 9, "guaiwu3", "TeamFuben2_2_2", false, 0, 4, 9005, 0.5},
			{"AddNpc", "NpcIndex8", "NpcNum1", 9, "guaiwu3", "TeamFuben2_2_3", false, 0, 4, 9005, 0.5},
			{"AddNpc", "NpcIndex6", "NpcNum2", 9, "guaiwu3", "TeamFuben2_2_4", false, 0, 6, 9005, 0.5},
			{"AddNpc", "NpcIndex8", "NpcNum1", 9, "guaiwu3", "TeamFuben2_2_5", false, 0, 6, 9005, 0.5},
			{"NpcBubbleTalk", "guaiwu4", "快阻止這群人，決不能讓他們闖進去！", 4, 1, 1},
			{"NpcBubbleTalk", "Temporary", "可惡的金兵，你們休要阻我！", 4, 3, 1},
		},
	},
	[9] = {nTime = 0, nNum = "NpcNum10",
		tbPrelock = {8},
		tbStartEvent = 
		{

		},
		tbUnLockEvent = 
		{
			{"RaiseEvent", "AddMissionScore", 6},
			{"OpenDynamicObstacle", "ops3"},				
			{"DoDeath", "wall"},
			{"AddNpc", "NpcIndex18", 2, 1, "wall", "wall_1_4", false, 32},
			{"SetTargetPos", 4875, 7005},
			{"NpcBubbleTalk", "Temporary", "這禁地內危險重重，我們得小心前進！", 4, 0, 1},
			{"SetFubenProgress", -1,"探查禁地"},	

			--BUFF球
			{"TrapCastSkill", "BuffPoint2", 1507, 1, -1, -1, 1, 203, 6004, 6537},

			--张琳心移动
			{"ChangeNpcAi", "Temporary", "Move", "Path4", 10, 0, 0, 0},
			{"SetNpcProtected", "Temporary", 1},

			--南宫彩虹
			{"AddNpc", "NpcIndex3", "NpcNum1", 0, "Leader1", "TeamFuben2_Leader_2", false, 0, 0, 0, 0},
			{"SetNpcProtected", "Leader1", 1},
			{"SetNpcBloodVisable", "Leader1", false, 2},
			{"ChangeNpcFightState", "Leader1", 0, 2},
			{"SetAiActive", "Leader1", 0},
		},
	},
	[10] = {nTime = 0, nNum = 1,
		tbPrelock = {9},
		tbStartEvent = 
		{

		},
		tbUnLockEvent = 
		{
			{"ChangeNpcAi", "Temporary", "Move", "Path5", 12, 0, 0, 0},
		},
	},
	[11] = {nTime = 0, nNum = 1,
		tbPrelock = {9},
		tbStartEvent = 
		{
			{"TrapUnlock", "TrapLock4", 11},	
		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},
			{"NpcBubbleTalk", "Temporary1", "你們是什麼人，竟敢擅闖禁地！莫非是找死不成？！", 4, 1, 1},
			{"SetFubenProgress", -1,"擊敗南宮彩虹"},	
			{"SetNpcProtected", "Leader1", 0},
			{"SetNpcBloodVisable", "Leader1", true, 0},	
			{"ChangeNpcFightState", "Leader1", 1, 0},
			{"SetAiActive", "Leader1", 1},
			{"NpcHpUnlock", "Leader1", 55, 70},	
		},
	},
	[12] = {nTime = 0, nNum = 1,
		tbPrelock = {10},
		tbStartEvent = 
		{		

		},
		tbUnLockEvent = 
		{	
			{"NpcBubbleTalk", "Temporary", "你是... 南宮彩虹！", 3, 0, 1},
			{"NpcBubbleTalk", "Leader1", "張琳心，居然是你！我不想與你為敵，速速離開這裡！", 3, 2, 1},
			{"NpcBubbleTalk", "Temporary", "那可不行，此行我要徹底查清五色教的陰謀！莫非你也要阻我不成？", 3, 5, 1},
			{"NpcBubbleTalk", "Leader1", "不錯！雖然你是他的妹妹，但守衛此處乃是職責所在，我絕不會退讓！", 3, 8, 1},
			{"NpcBubbleTalk", "Temporary", "南宮彩虹！你......", 3, 11, 1},
			{"NpcBubbleTalk", "Leader1", "不必多言，你們拔劍吧！", 3, 13, 1},
		},
	},
	[55] = {nTime = 0, nNum = 1,
		tbPrelock = {11},
		tbStartEvent = 
		{				
		},
		tbUnLockEvent = 
		{	
			{"NpcBubbleTalk", "Leader1", "倒是小瞧你們了，就讓你們瞧瞧我的厲害！", 4, 1, 1},						
			{"AddNpc", "NpcIndex6", "NpcNum3", 0, "guaiwu", "TeamFuben2_3_2", false, 0, 0, 9005, 0.5},
			{"AddNpc", "NpcIndex6", "NpcNum3", 0, "guaiwu", "TeamFuben2_3_4", false, 0, 0, 9005, 0.5},
			{"NpcHpUnlock", "Leader1", 56, 50},		
		},
	},
	[56] = {nTime = 0, nNum = 1,
		tbPrelock = {55},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{	
			{"NpcHpUnlock", "Leader1", 57, 30},	
			{"NpcBubbleTalk", "Leader1", "可惡，沒想到竟會如此棘手！將士們，給我上！", 4, 1, 1},	
			{"AddNpc", "NpcIndex6", "NpcNum3", 0, "guaiwu", "TeamFuben2_3_2", false, 0, 0, 9005, 0.5},
			{"AddNpc", "NpcIndex6", "NpcNum3", 0, "guaiwu", "TeamFuben2_3_4", false, 0, 0, 9005, 0.5},
		},
	},
	[57] = {nTime = 0, nNum = 1,
		tbPrelock = {56},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{	
			{"NpcHpUnlock", "Leader1", 100, 5},
			{"NpcHpUnlock", "Leader1", 13, 1},	
			{"NpcBubbleTalk", "Leader1", "可惡，沒想到竟會如此棘手！將士們，給我上！", 4, 1, 1},	
			{"AddNpc", "NpcIndex6", "NpcNum3", 0, "guaiwu", "TeamFuben2_3_2", false, 0, 0, 9005, 0.5},
			{"AddNpc", "NpcIndex8", "NpcNum1", 0, "guaiwu", "TeamFuben2_3_3", false, 0, 0, 9005, 0.5},
			{"AddNpc", "NpcIndex6", "NpcNum3", 0, "guaiwu", "TeamFuben2_3_4", false, 0, 0, 9005, 0.5},
			{"AddNpc", "NpcIndex8", "NpcNum1", 0, "guaiwu", "TeamFuben2_3_5", false, 0, 0, 9005, 0.5},	
		},
	},
-----------修复南宫彩虹打不死BUG的补丁----------------
	[100] = {nTime = 0, nNum = 1,
		tbPrelock = {57},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
		},
	},
	[101] = {nTime = 10, nNum = 0,
		tbPrelock = {100},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"UnLock", 13}, 
		},
	},
	[13] = {nTime = 0, nNum = 1,
		tbPrelock = {10},
		tbStartEvent = 
		{

		},
		tbUnLockEvent = 
		{
			{"CloseLock", 100, 101}, 

			--奖励掉落
			{"RaiseEvent", "DropAward", "Setting/Npc/DropFile/TeamFuben/nangongcaihong.tab", 4777, 6387},
			--{"RaiseEvent", "DropAward", "Setting/Npc/DropFile/TeamFuben/nangongcaihong.tab", 4959, 6397},
			{"SetNpcProtected", "Leader1", 1},
			{"SetNpcBloodVisable", "Leader1", false, 0},
			{"ChangeNpcFightState", "Leader1", 0, 0},
			{"SetAiActive", "Leader1", 0},

			--秒杀小兵
			{"CastSkill", "guaiwu", 3, 1, -1, -1},
			{"OpenDynamicObstacle", "ops4"},			
			{"DoDeath", "wall"},
			{"AddNpc", "NpcIndex18", 1, 1, "wall", "wall_1_5", false, 16},
			{"SetTargetPos", 6430, 6621},
			{"RaiseEvent", "AddMissionScore", 10},			

			{"NpcBubbleTalk", "Leader1", "敗於你手我無話可說，要殺要剮悉聽尊便...", 3, 0, 1},
			{"NpcBubbleTalk", "Temporary", "南宮彩虹，若你還為金國賣命，你和我大哥又怎麼會有結果！", 3, 3, 1},
			{"NpcBubbleTalk", "Temporary", "言盡於此，希望你好好想想吧！", 3, 6, 1},
			{"NpcBubbleTalk", "Leader1", "你... 說的不錯，容我仔細想想... 你們過去吧。", 3, 9, 1},
			{"NpcBubbleTalk", "Temporary", "禁地內還隱藏著不少秘密，我們分頭行動徹查此地！", 4, 12, 1},	

			--重新设置复活点
			{"SetDynamicRevivePoint", 4854, 6496},		
		},
	},
	[14] = {nTime = 13, nNum = 0,
		tbPrelock = {13},
		tbStartEvent = 
		{

		},
		tbUnLockEvent = 
		{	
			{"SetFubenProgress", -1,"探索禁地"},
			{"BlackMsg", "徹查此地，在禁地盡頭與張琳心會合！"},
		},
	},
	[15] = {nTime = 0, nNum = 1,
		tbPrelock = {13},
		tbStartEvent = 
		{
			{"TrapUnlock", "TrapLock5", 15},
			{"AddNpc", "NpcIndex9", "NpcNum2", 16, "guaiwu6", "TeamFuben2_4_1", false, 0, 0, 9005, 0.5},
			{"AddNpc", "NpcIndex17", "NpcNum2", 16, "guaiwu", "TeamFuben2_4_2", false, 0, 0, 9005, 0.5},
			{"AddNpc", "NpcIndex10", "NpcNum1", 16, "guaiwu", "TeamFuben2_4_3", false, 0, 0, 9005, 0.5},
		},
		tbUnLockEvent = 
		{	
			{"ClearTargetPos"},
			{"DelNpc", "Leader1"},
			{"SetFubenProgress", -1,"擊敗五色教弟子"},
			{"DelNpc", "Temporary"},
			{"DelNpc", "Temporary1"},
			{"AddNpc", "NpcIndex9", "NpcNum4", 16, "guaiwu", "TeamFuben2_4_4", false, 0, 6, 9005, 0.5},
			{"NpcBubbleTalk", "guaiwu6", "來者何人，竟然擅闖此處！當真是活膩了！", 3, 2, 1},	
		},
	},
	[16] = {nTime = 0, nNum = "NpcNum9",
		tbPrelock = {13},
		tbStartEvent = 
		{

		},
		tbUnLockEvent = 
		{
			{"OpenDynamicObstacle", "ops5"},	
			{"SetFubenProgress", -1,"探索禁地"},
			{"SetTargetPos", 7133, 5269},	
			{"DoDeath", "wall"},
			{"RaiseEvent", "AddMissionScore", 6},
			{"AddNpc", "NpcIndex18", 2, 1, "wall", "wall_1_6", false, 32},

			--稀有几率
			{"Random", {330000, 70}},
		},
	},
	[17] = {nTime = 0, nNum = 1,
		tbPrelock = {16},
		tbStartEvent = 
		{
			{"TrapUnlock", "TrapLock6", 17},
			{"AddNpc", "NpcIndex9", "NpcNum2", 18, "guaiwu7", "TeamFuben2_5_1", false, 0, 0, 9005, 0.5},
			{"AddNpc", "NpcIndex17", "NpcNum2", 18, "guaiwu", "TeamFuben2_5_2", false, 0, 0, 9005, 0.5},
			{"AddNpc", "NpcIndex10", "NpcNum1", 18, "guaiwu", "TeamFuben2_5_3", false, 0, 0, 9005, 0.5},
		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},
			{"SetFubenProgress", -1,"擊敗五色教弟子"},
			{"DelNpc", "Temporary"},
			{"AddNpc", "NpcIndex9", "NpcNum3", 18, "guaiwu", "TeamFuben2_5_4", false, 0, 5, 9005, 0.5},
			{"AddNpc", "NpcIndex17", "NpcNum3", 18, "guaiwu", "TeamFuben2_5_5", false, 0, 7, 9005, 0.5},
			{"NpcBubbleTalk", "guaiwu7", "點子扎手！大夥一起上啊！", 3, 2, 1},
		},
	},

	--武夷禁地稀有	
	[70] = {nTime = 0, nNum = 1,
		tbPrelock = {},
		tbStartEvent = 
		{	
			{"TrapUnlock", "Xiyou", 70},

			--关闭锁
			{"CloseLock", 17, 18},

			--封玉书
			{"AddNpc", "NpcIndex13", "NpcNum1", 71, "Xiyou", "TeamFuben2_Xiyou", false, 14, 0, 0, 0},

			--张琳心
			{"AddNpc", "NpcIndex14", "NpcNum1", 0, "Temporary2", "TeamFuben2_Xiyou_1", false, 32, 0, 0, 0},
			{"SetNpcProtected", "Temporary2", 1},		
			{"SetNpcProtected", "Xiyou", 1},	

			{"AddNpc", "NpcIndex9", "NpcNum2", 71, "guaiwu7", "TeamFuben2_5_1", false, 0, 0, 9005, 0.5},
			{"AddNpc", "NpcIndex17", "NpcNum2", 71, "guaiwu", "TeamFuben2_5_2", false, 0, 0, 9005, 0.5},
			{"AddNpc", "NpcIndex10", "NpcNum1", 71, "guaiwu", "TeamFuben2_5_3", false, 0, 0, 9005, 0.5},
		},
		tbUnLockEvent = 
		{	
			{"ClearTargetPos"},
			{"SetNpcProtected", "Temporary2", 0},	
			{"SetNpcProtected", "Xiyou", 0},
			{"NpcBubbleTalk", "Temporary2", "封玉書，你這個叛徒！！為了名利居然投靠金人！", 4, 1, 1},
			{"NpcBubbleTalk", "Xiyou", "哼，當日被獨孤劍破壞好事沒能除掉你，今日看你往哪裡走！", 4, 4, 1},
			{"NpcBubbleTalk", "Xiyou", "你也少做口舌之利了！今日你將插翅難飛，乖乖受死吧！", 4, 7, 1},	

			{"SetFubenProgress", -1,"擊敗封玉書"},
			{"AddNpc", "NpcIndex9", "NpcNum3", 71, "guaiwu", "TeamFuben2_5_4", false, 0, 5, 9005, 0.5},
			{"AddNpc", "NpcIndex17", "NpcNum3", 71, "guaiwu", "TeamFuben2_5_5", false, 0, 7, 9005, 0.5},
		},
	},
	[71] = {nTime = 0, nNum = "NpcNum12",
		tbPrelock = {70},
		tbStartEvent = 
		{		
		
		},
		tbUnLockEvent = 
		{	
			{"NpcBubbleTalk", "Xiyou", "總算是解決了這個叛徒，我們繼續前進吧！", 4, 0, 1},
			{"DoDeath", "wall"},
			{"SetFubenProgress", -1,"探索禁地"},
			{"OpenDynamicObstacle", "ops6"},
			{"SetTargetPos", 5426, 3842},
			{"RaiseEvent", "AddMissionScore", 15},

			{"ChangeNpcAi", "Temporary2", "Move", "Path10", 0, 1, 1, 0},
		},
	},
	[18] = {nTime = 0, nNum = "NpcNum11",
		tbPrelock = {16},
		tbStartEvent = 
		{

		},
		tbUnLockEvent = 
		{	
			{"DoDeath", "wall"},
			{"SetFubenProgress", -1,"探索禁地"},
			{"OpenDynamicObstacle", "ops6"},
			{"SetTargetPos", 5426, 3842},
			{"RaiseEvent", "AddMissionScore", 15},
			--张琳心
			{"AddNpc", "NpcIndex14", "NpcNum1", 0, "Temporary2", "TeamFuben2_6", false, 14, 0, 0, 0},	
		},
	},
	[19] = {nTime = 0, nNum = 1,
		tbPrelock = {16},
		tbStartEvent = 
		{
			{"TrapUnlock", "TrapLock7", 19},
		},
		tbUnLockEvent = 
		{
			{"NpcBubbleTalk", "Temporary2", "琳心此行發現不少五色教弟子出現于此，或許正在醞釀著什麼陰謀。", 4, 0, 1},

			--重新设置复活点
			{"SetDynamicRevivePoint", 5457, 4786},	
		},
	},
	[20] = {nTime = 2, nNum = 0,
		tbPrelock = {19},
		tbStartEvent = 
		{
			{"ChangeNpcAi", "Temporary2", "Move", "Path6", 0, 1, 1, 0},
		},
		tbUnLockEvent = 
		{
			{"NpcBubbleTalk", "Temporary2", "前方有批刺客正在守衛一箱物資，與我一同將他們擊退吧！", 4, 0, 1},					
			{"BlackMsg", "與張琳心同行，並擊敗五色教刺客！"},
			{"SetFubenProgress", -1,"擊敗五色教刺客"},
		},
	},
	[21] = {nTime = 0, nNum = 1,
		tbPrelock = {16},
		tbStartEvent = 
		{
			{"TrapUnlock", "TrapLock8", 21},

			--宝箱
			{"AddNpc", "NpcIndex15", "NpcNum1", 0, "baoxiang", "TeamFuben2_wuzixiang", false, 32, 0, 0, 0},
		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},	

			--神秘杀手
			{"AddNpc", "NpcIndex11", "NpcNum8", 22, "guaiwu", "TeamFuben2_6_1", false, 0, 0, 9009, 0.5},
			{"NpcBubbleTalk", "guaiwu", "來者何人，竟敢覬覦我教重寶，還不速速領死！", 4, 1, 1},
		},
	},
	[22] = {nTime = 0, nNum = "NpcNum8",
		tbPrelock = {21},
		tbStartEvent = 
		{
	
		},
		tbUnLockEvent = 
		{	
			{"NpcBubbleTalk", "Temporary2", "五色教弟子如此看重此物，也不知這寶箱內究竟藏有何物？", 4, 0, 1},	

			--张琳心
			{"ChangeNpcAi", "Temporary2", "Move", "Path7", 23, 0, 0, 0},	
		},
	},
	[23] = {nTime = 0, nNum = 1,
		tbPrelock = {22},
		tbStartEvent = 
		{
	
		},
		tbUnLockEvent = 
		{	
			{"NpcBubbleTalk", "Temporary2", "嗯....  居然上鎖了，不過這可難不倒我。", 4, 1, 1},
		},
	},
	[24] = {nTime = 4, nNum = 0,
		tbPrelock = {23},
		tbStartEvent = 
		{
	
		},
		tbUnLockEvent = 
		{	
			-- {"CastSkill", "baoxiang", 2408, 1, -1, -1},
			{"PlayEffect", 4317, 5422, 3058, 0},
			{"NpcBubbleTalk", "Temporary2", "啊！這是什麼.....", 4, 0, 1},	
			{"BlackMsg", "糟糕，是毒霧！"},
			{"DoCommonAct", "baoxiang", 16, 5001, 1, 0},
			{"SetNpcProtected", "Temporary2", 1},
		},
	},
	[25] = {nTime = 3, nNum = 0,
		tbPrelock = {24},
		tbStartEvent = 
		{
	
		},
		tbUnLockEvent = 
		{	
			{"NpcBubbleTalk", "Temporary2", "頭好暈....  我這是怎麼了....", 4, 0, 1},	

			--神秘杀手
			{"AddNpc", "NpcIndex11", "NpcNum4", 26, "guaiwu", "TeamFuben2_7_1", false, 0, 0, 9009, 0.5},
			{"AddNpc", "NpcIndex12", "NpcNum1", 26, "guaiwu1", "TeamFuben2_7_2", false, 0, 0, 9009, 0.5},
			{"NpcBubbleTalk", "guaiwu1", "這毒煙的滋味不錯吧！身中此毒者，會不斷的喪失理智並最終發狂！", 4, 2, 1},
			{"NpcBubbleTalk", "guaiwu1", "你們就好好的享受吧！哈哈哈哈", 3, 4, 1},
			{"SetFubenProgress", -1,"保護張琳心"},
			{"RaiseEvent", "AddMissionScore", 8},
		}
	},
	[26] = {nTime = 8, nNum = 0,
		tbPrelock = {25},
		tbStartEvent = 
		{
	
		},
		tbUnLockEvent = 
		{	
			{"DelNpc", "Temporary2"},
			{"DelNpc", "baoxiang"},

			--张琳心
			{"AddNpc", "NpcIndex1", "NpcNum1", 27, "BOSS", "TeamFuben2_BOSS", false, 0, 0, 0, 0},
			{"NpcBubbleTalk", "BOSS", "糟糕，我控制不了自己了！！", 4, 1, 1},
			{"BlackMsg", "張琳心失去理智，先將其制服讓她冷靜下來！"},			
			{"SetFubenProgress", -1,"制服張琳心"},
			{"NpcHpUnlock", "BOSS", 58, 80},	
		}
	},
	[58] = {nTime = 0, nNum = 1,
		tbPrelock = {26},
		tbStartEvent = 
		{				
		},
		tbUnLockEvent = 
		{	
			{"NpcBubbleTalk", "BOSS", "殺.... 殺.... 殺！！！！", 4, 0, 1},	
			{"NpcHpUnlock", "BOSS", 59, 60},		
		},
	},
	[59] = {nTime = 0, nNum = 1,
		tbPrelock = {58},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{	
			{"NpcBubbleTalk", "BOSS", "我.... 我在做些什麼...", 4, 0, 1},		
			{"NpcHpUnlock", "BOSS", 60, 30},
		},
	},
	[60] = {nTime = 0, nNum = 1,
		tbPrelock = {59},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{	
			{"NpcBubbleTalk", "BOSS", "沒想到... 這竟是五色教的奸計，當真是大意了...", 5, 0, 1},	
		},
	},
	[27] = {nTime = 0, nNum = 1,
		tbPrelock = {25},
		tbStartEvent = 
		{

		},
		tbUnLockEvent = 
		{			
			{"RaiseEvent", "AddMissionScore", 15},
			{"SetFubenProgress", -1,"闖關成功"},
			{"OpenWindow", "LingJueFengLayerPanel", "Win"},
			{"RaiseEvent", "KickOutAllPlayer", 70},
			{"BlackMsg", "闖關成功！篝火已刷出，可持續獲得經驗！"},
			{"GameWin"},
			{"AddSimpleNpc", 1610, 5423, 3046, 0},
			{"AddSimpleNpc", 997, 5442, 2837, 0},

		},
	},
	[28] = {nTime = 900, nNum = 0,
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