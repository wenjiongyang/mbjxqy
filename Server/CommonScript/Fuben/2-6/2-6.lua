
local tbFubenSetting = {};
Fuben:SetFubenSetting(29, tbFubenSetting)		-- 绑定副本内容和地图

tbFubenSetting.szFubenClass 			= "PersonalFubenBase";									-- 副本类型
tbFubenSetting.szName 					= "測試副本"											-- 单纯的名字，后台输出或统计使用
tbFubenSetting.szNpcPointFile 			= "Setting/Fuben/PersonalFuben/2_6/NpcPos.tab"			-- NPC点
--tbFubenSetting.szNpcExtAwardPath 		= "Setting/Fuben/PersonalFuben/2_7/ExtNpcAwardInfo.tab"	-- 掉落表
tbFubenSetting.szPathFile 				= "Setting/Fuben/PersonalFuben/2_6/NpcPath.tab"			-- 寻路点
tbFubenSetting.tbBeginPoint 			= {1981, 4440}											-- 副本出生点
tbFubenSetting.nStartDir				= 32;



-- ID可以随便 普通副本NPC数量 ；精英模式NPC数量


tbFubenSetting.ANIMATION = 
{
	[1] = "Scenes/Maps/yw_luoyegu/Main Camera.controller",
	[2] = "Scenes/camera/xuedi06/xuedi06_chuchang.controller",	--出场
	[3] = "Scenes/camera/xuedi06/xuedi06_jisha.controller",		--击杀
}

--NPC模版ID，NPC等级，NPC五行；

tbFubenSetting.NPC = 
{
	[1] = {nTemplate = 792,			nLevel = 19, nSeries = -1},  --藏剑弟子
	[2] = {nTemplate = 1126,		nLevel = 19, nSeries = -1},  --藏剑亲卫-鼓舞
	[3] = {nTemplate = 29,			nLevel = 19, nSeries = -1},  --刺客
	[4] = {nTemplate = 1127,		nLevel = 19, nSeries = 0},  --卓非凡
	[5] = {nTemplate = 684,			nLevel = 19, nSeries = 0},  --杨影枫

	[6] = {nTemplate  = 74,			nLevel = 19, nSeries = 0},  --上升气流
	[7] = {nTemplate  = 104,		nLevel = 19, nSeries = 0},  --动态障碍墙

	[8] = {nTemplate = 1449,		nLevel = 19, nSeries = -1},  --脆弱藏剑亲卫-迅捷
	[9] = {nTemplate = 1450,		nLevel = 19, nSeries = -1},  --脆弱藏剑亲卫-治愈

	[13] = {nTemplate = 840,		nLevel = 19, nSeries = 0},  --紫轩-表现
	[14] = {nTemplate = 1217,		nLevel = 19, nSeries = 0},  --武林人士-表现
	[15] = {nTemplate = 1218,		nLevel = 19, nSeries = 0},  --武林人士-表现
	[16] = {nTemplate = 1219,		nLevel = 19, nSeries = 0},  --武林人士-表现
	[17] = {nTemplate = 1220,		nLevel = 19, nSeries = 0},  --武林人士-表现
	[18] = {nTemplate = 1127,		nLevel = 19, nSeries = 0},  --卓非凡（表现NPC）
}

tbFubenSetting.LOCK = 
{
	-- 1号锁不能不填，默认1号为起始锁，nTime是到时间自动解锁，nNum表示需要解锁的次数，如填3表示需要被解锁3次才算真正解锁，可以配置字符串
	[1] = {nTime = 0, nNum = 1,
		--tbPrelock 前置锁，激活锁的必要条件{1 , 2, {3, 4}}，代表1和2号必须解锁，3和4任意解锁一个即可
		tbPrelock = {},
		--tbStartEvent 锁激活时的事件
		tbStartEvent = 
		{
			{"RaiseEvent", "ShowTaskDialog", 1, 1029, false},
			--{"AddNpc", 5, 1, 3, "Start_Npc1", "Start_Npc1", 1, 32, 0, 0, 0},
		},
		--tbStartEvent 锁解开时的事件
		tbUnLockEvent = 
		{
			{"SetShowTime", 50},
			{"RaiseEvent", "FllowPlayer", "Start_Npc1", true},
			--{"NpcBubbleTalk", "Start_Npc1", "新仇旧恨，今日终于要清算了！", 4, 0, 1},
			{"RaiseEvent", "PartnerSay", "新仇舊恨，今日終於要清算了！", 4, 1},
		},
	},
	[2] = {nTime = 0, nNum = 1,
		tbPrelock = {1},
		tbStartEvent = 
		{	
			{"ChangeFightState", 1},
			{"TrapUnlock", "TrapLock1", 2},
			{"AddNpc", 7, 2, 0, "wall", "wall_1_1",false, 15},
			{"SetTargetPos", 2204, 3662},
		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},
			{"AddNpc", 3, 3, 3, "guaiwu1", "Stage_1_1", 1, 0, 0, 0, 0},
			{"AddNpc", 3, 2, 3, "guaiwu", "Stage_1_2", 1, 0, 1, 0, 0},		
			{"NpcBubbleTalk", "guaiwu1", "你們總算是來了，我們已等候多時了！", 4, 1, 1},	
		},
	},
	[3] = {nTime = 0, nNum = 5,
		tbPrelock = {2},
		tbStartEvent = 
		{	
		},
		tbUnLockEvent = 
		{
			{"SetTargetPos", 2513, 2733},	
			{"DoDeath", "wall"},	
			{"OpenDynamicObstacle", "ops1"},
			{"AddNpc", 7, 1, 0, "wall", "wall_1_2",false, 31},		
		},
	},
	[4] = {nTime = 0, nNum = 1,
		tbPrelock = {3},
		tbStartEvent = 
		{		
			{"TrapUnlock", "TrapLock2", 4},
			{"AddNpc", 1, 2, 5, "guaiwu", "Stage_1_3", 1, 0, 0, 0, 0},
			{"AddNpc", 1, 2, 5, "guaiwu", "Stage_1_4", 1, 0, 0, 0, 0},
			{"AddNpc", 2, 1, 5, "guaiwu1", "Stage_1_5", 1, 0, 0, 0, 0},

			{"SetNpcProtected", "guaiwu", 1},
			{"SetNpcProtected", "guaiwu1", 1},
		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},
			{"AddNpc", 1, 6, 5, "guaiwu", "Stage_1_6", 1, 0, 3, 9008, 0.5},
			{"NpcBubbleTalk", "guaiwu1", "姓楊的，你休想登上劍氣峰？", 4, 1, 1},

			{"SetNpcProtected", "guaiwu", 0},
			{"SetNpcProtected", "guaiwu1", 0},
		},
	},
	[5] = {nTime = 0, nNum = 11,
		tbPrelock = {3},
		tbStartEvent = 
		{	
		},
		tbUnLockEvent = 
		{
			{"OpenDynamicObstacle", "ops2"},
			{"DoDeath", "wall"},	
			{"AddNpc", 7, 1, 2, "wall", "wall_1_3",false, 24},
			{"SetTargetPos", 4449, 2622},
			--{"NpcBubbleTalk", "Start_Npc1", "鹊巢鸠占，可惜可惜....", 4, 0, 1},
			{"RaiseEvent", "PartnerSay", "鵲巢鳩佔，可惜可惜...", 4, 1},
		},
	},
	[6] = {nTime = 0, nNum = 1,
		tbPrelock = {5},
		tbStartEvent = 
		{	
			{"TrapUnlock", "TrapLock3", 6},
			{"AddNpc", 1, 2, 7, "guaiwu", "Stage_2_1", 1, 0, 0, 0, 0},
			{"AddNpc", 1, 2, 7, "guaiwu", "Stage_2_2", 1, 0, 0, 0, 0},
			{"AddNpc", 2, 1, 7, "guaiwu1", "Stage_2_3", 1, 0, 0, 0, 0},

			{"SetNpcProtected", "guaiwu", 1},
			{"SetNpcProtected", "guaiwu1", 1},
		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},
			{"AddNpc", 3, 3, 7, "guaiwu", "Stage_2_4", 1, 0, 3, 0, 0},
			{"AddNpc", 1, 4, 7, "guaiwu", "Stage_2_5", 1, 0, 5, 9008, 0.5},
			{"NpcBubbleTalk", "guaiwu1", "與我藏劍山莊為敵，自尋死路！", 4, 1, 1},

			{"SetNpcProtected", "guaiwu", 0},
			{"SetNpcProtected", "guaiwu1", 0},
		},
	},
	[7] = {nTime = 0, nNum = 12,
		tbPrelock = {5},
		tbStartEvent = 
		{	
		},
		tbUnLockEvent = 
		{
			{"SetTargetPos", 5116, 3350},
			{"AddNpc", 6, 1, 5, "Stage_2_qinggong", "Stage_2_qinggong", 1},			
			{"ChangeTrap", "Jump1", nil, {5092, 4084}},
			{"ChangeTrap", "Jump2", nil, {5090, 4569}},	
		},
	},
	[8] = {nTime = 0, nNum = 1,
		tbPrelock = {7},
		tbStartEvent = 
		{
			{"TrapUnlock", "Jump1", 8},
		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},		
			{"AddNpc", 1, 2, 10, "guaiwu", "Stage_3_1", 1, 0, 0, 0, 0},
			{"AddNpc", 1, 2, 10, "guaiwu", "Stage_3_2", 1, 0, 0, 0, 0},
			{"AddNpc", 2, 1, 10, "guaiwu1", "Stage_3_3", 1, 0, 0, 0, 0},
		},
	},
	--跳崖保护
	[200] = {nTime = 2, nNum = 0,
		tbPrelock = {8},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"SetPos", 5090, 4569},
		},
	},

	[9] = {nTime = 0, nNum = 1,
		tbPrelock = {7},
		tbStartEvent = 
		{
			{"TrapUnlock", "TrapLock5", 9},
			{"ChangeTrap", "TrapLock5", nil, nil, nil, nil, nil, true},
		},
		tbUnLockEvent = 
		{
			--{"SetNpcPos", "Start_Npc1", 6907, 7022},
			{"AddNpc", 1, 6, 10, "guaiwu", "Stage_3_4", 1, 0, 4, 9008, 0.5},
			{"NpcBubbleTalk", "guaiwu1", "莊主有令，擊殺此人者，賞白銀千兩！", 4, 1, 1},
			{"CloseLock", 200},
		},
	},
	[10] = {nTime = 0, nNum = 11,
		tbPrelock = {7},
		tbStartEvent = 
		{	
		},
		tbUnLockEvent = 
		{
			{"OpenDynamicObstacle", "ops3"},	
			{"DoDeath", "wall"},
			{"SetTargetPos", 7011, 7245},
			--{"NpcBubbleTalk", "Start_Npc1", "前面就是剑气锋了！", 4, 0, 1},
			{"RaiseEvent", "PartnerSay", "前面就是劍氣鋒了！", 4, 1},
		},
	},
	[11] = {nTime = 0, nNum = 1,
		tbPrelock = {10},
		tbStartEvent = 
		{	
			{"TrapUnlock", "TrapLock4", 11},

			{"AddNpc", 5, 1, 0, "Start_Npc1", "Stage_4_yangyingfeng", false, 14, 0, 0, 0},
			{"SetNpcProtected", "Start_Npc1", 1},
			{"SetNpcBloodVisable", "Start_Npc1", false, 0},
			{"SetAiActive", "Start_Npc1", 0},
			--卓非凡
			{"AddNpc", 4, 1, 40, "BOSS", "Stage_4_BOSS", 2, 0, 0, 0, 0},
			{"AddNpc", 13, 1, 0, "zixuan", "Stage_4_zixuan", 1, 0, 0, 0, 0},
			{"AddNpc", 14, 1, 0, "guanzhan1", "Stage_4_guanzhan1", 1, 24, 0, 0, 0},
			{"AddNpc", 15, 1, 0, "guanzhan2", "Stage_4_guanzhan2", 1, 32, 0, 0, 0},
			{"AddNpc", 16, 1, 0, "guanzhan3", "Stage_4_guanzhan3", 1, 39, 0, 0, 0},
			{"AddNpc", 17, 1, 0, "guanzhan4", "Stage_4_guanzhan4", 1, 53, 0, 0, 0},
			{"SetNpcProtected", "BOSS", 1},
			{"SetNpcBloodVisable", "BOSS", false, 0},
			{"ChangeNpcFightState", "BOSS", 0, 0},
			{"SetAiActive", "BOSS", 0},

			{"SetNpcProtected", "zixuan", 1},
			{"SetNpcBloodVisable", "zixuan", false, 0},
			{"ChangeNpcFightState", "zixuan", 0, 0},
			{"SetAiActive", "zixuan", 0},

			{"ChangeNpcFightState", "guanzhan1", 0, 0},
			{"ChangeNpcFightState", "guanzhan2", 0, 0},
			{"ChangeNpcFightState", "guanzhan3", 0, 0},
			{"ChangeNpcFightState", "guanzhan4", 0, 0},
			{"SetNpcBloodVisable", "guanzhan1", false, 0},
			{"SetNpcBloodVisable", "guanzhan2", false, 0},
			{"SetNpcBloodVisable", "guanzhan3", false, 0},
			{"SetNpcBloodVisable", "guanzhan4", false, 0},
			{"SetAiActive", "guanzhan1", 0},
			{"SetAiActive", "guanzhan2", 0},
			{"SetAiActive", "guanzhan3", 0},
			{"SetAiActive", "guanzhan4", 0},
		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},
			{"PauseLock", 50},

			--{"RaiseEvent", "PlayerRunTo", 7874, 8093},
		},
	},
	[12] = {nTime = 12, nNum = 0,									--卓非凡出场镜头
		tbPrelock = {11},
		tbStartEvent = 
		{
			{"SetAllUiVisiable", false}, 
			{"SetForbiddenOperation", true},
			{"ShowAllRepresentObj", false},
			{"PlayCameraAnimation", 2, 0},
			{"PlayCameraEffect", 9122},
			{"PlayEffect", 9124, 0, 0, 0, 1},
			{"PlaySound", 46},
		},
		tbUnLockEvent = 
		{
			{"ShowAllRepresentObj", true},

			{"SetAllUiVisiable", true}, 
			{"SetForbiddenOperation", false},
			{"LeaveAnimationState", true},
			{"SetPos", 7874, 8093},
		},
	},
	
	[13] = {nTime = 0, nNum = 1,
		tbPrelock = {12},
		tbStartEvent = 
		{
			{"RaiseEvent", "ShowTaskDialog", 13, 1030, false},		
		},
		tbUnLockEvent = 
		{
			--{"RaiseEvent", "ShowPartnerAndHelper", true},

			{"SetAllUiVisiable", true}, 			
			--{"LeaveAnimationState", false},
			{"ChangeCameraSetting", 35, 35, 20},		--调整摄像机基础参数

			{"RaiseEvent", "CloseDynamicObstacle", "ops3"},
			{"AddNpc", 7, 1, 2, "wall", "wall_1_3",false, 24},	
			{"SetNpcProtected", "BOSS", 0},
			{"SetNpcBloodVisable", "BOSS", true, 0},
			{"ChangeNpcFightState", "BOSS", 1, 0},
			{"SetAiActive", "BOSS", 1},
			{"NpcBubbleTalk", "BOSS", "今日不是你死就是我亡，接招吧！", 4, 0, 1},

			{"SetAiActive", "Start_Npc1", 1},
			{"SetAiActive", "zixuan", 1},
			{"SetAiActive", "guanzhan1", 1},
			{"SetAiActive", "guanzhan2", 1},
			{"SetAiActive", "guanzhan3", 1},
			{"SetAiActive", "guanzhan4", 1},

			{"ChangeNpcAi", "guanzhan1", "Move", "Path2", 34, 0, 0, 0, 0},
			{"ChangeNpcAi", "guanzhan2", "Move", "Path3", 35, 0, 0, 0, 0},
			{"ChangeNpcAi", "guanzhan3", "Move", "Path4", 36, 0, 0, 0, 0},
			{"ChangeNpcAi", "zixuan", 	 "Move", "Path5", 37, 0, 0, 0, 0},
			{"ChangeNpcAi", "guanzhan4", "Move", "Path6", 38, 0, 0, 0, 0},
			{"ChangeNpcAi", "Start_Npc1", "Move", "Path7", 39, 0, 0, 0, 0},

			{"NpcBubbleTalk", "guanzhan1", "沒想到今日竟然看到了這種大戲，真是沒白來一趟啊！", 4, 0, 1},

			{"ResumeLock", 50},
			{"SetShowTime", 50},
		},
	},
	[31] = {nTime = 3, nNum = 0,
		tbPrelock = {10},
		tbStartEvent = 
		{		
		},
		tbUnLockEvent = 
		{	
						
		},
	},
	[32] = {nTime = 0, nNum = 1,
		tbPrelock = {31},
		tbStartEvent = 
		{
			{"NpcHpUnlock", "BOSS", 32, 80},			
		},
		tbUnLockEvent = 
		{	
			{"NpcBubbleTalk", "BOSS", "我可是藏劍山莊的莊主，怎麼可能會敗在你的手中！！！", 4, 0, 1},	
			{"NpcBubbleTalk", "Start_Npc1", "卓非凡，想想你當初所做的惡事，又有何資格配做藏劍山莊之主！！", 4, 3, 1},
			{"NpcBubbleTalk", "BOSS", "楊影楓！！！你給我住口！！！", 4, 7, 1},		
			{"NpcHpUnlock", "BOSS", 33, 50},		
		},
	},
	[33] = {nTime = 0, nNum = 1,
		tbPrelock = {32},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{	
			{"NpcBubbleTalk", "Start_Npc1", "卓非凡，敗局已定，你還是乖乖束手就擒吧！", 4, 0, 1},	
			{"NpcBubbleTalk", "BOSS", "楊影楓，你給我住口！我還沒有輸！！！", 4, 2, 1},
			{"NpcHpUnlock", "BOSS", 40, 20},
		},
	},
	[34] = {nTime = 0, nNum = 1,
		tbPrelock = {13},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{	
			{"SetNpcDir", "guanzhan1", 24},
			{"SetAiActive", "guanzhan1", 0},
			{"SetNpcProtected", "guanzhan1", 1},
			{"NpcBubbleTalk", "guanzhan1", "沒想到卓非凡竟是這等小人，枉我還將他視為偶像！", 4, 1, 1},			
		},
	},
	[35] = {nTime = 0, nNum = 1,
		tbPrelock = {13},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{	
			{"SetNpcDir", "guanzhan2", 32},
			{"SetAiActive", "guanzhan2", 0},
			{"SetNpcProtected", "guanzhan2", 1},
			{"NpcBubbleTalk", "guanzhan2", "我呸，這藏劍山莊看來也不過如此！", 4, 2, 1},

		},
	},
	[36] = {nTime = 0, nNum = 1,
		tbPrelock = {13},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{	
			{"SetNpcDir", "guanzhan3", 39},
			{"SetAiActive", "guanzhan3", 0},
			{"SetNpcProtected", "guanzhan3", 1},
			{"NpcBubbleTalk", "guanzhan3", "哎...  真是世風日下，道德淪喪啊！", 4, 2, 1},
		},
	},
	[37] = {nTime = 0, nNum = 1,
		tbPrelock = {13},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{	
			{"SetNpcDir", "zixuan", 46},
			{"SetAiActive", "zixuan", 0},
			{"SetNpcProtected", "zixuan", 1},
			{"NpcBubbleTalk", "zixuan", "楊大哥....", 4, 2, 1},
		},
	},
	[38] = {nTime = 0, nNum = 1,
		tbPrelock = {13},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{	
			{"SetNpcDir", "guanzhan4", 53},
			{"SetAiActive", "guanzhan4", 0},
			{"SetNpcProtected", "guanzhan4", 1},
			{"NpcBubbleTalk", "guanzhan4", "沒想到今日竟然看到了這種大戲，真是沒白來一趟啊！", 4, 3, 1},
		},
	},
	[39] = {nTime = 0, nNum = 1,
		tbPrelock = {13},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{	
			{"SetNpcDir", "Start_Npc1", 16},
			{"SetAiActive", "Start_Npc1", 0},
			{"NpcBubbleTalk", "Start_Npc1", "卓非凡，今日便是你的死期！", 4, 1, 1},
		},
	},
	[40] = {nTime = 0, nNum = 1,
		tbPrelock = {13},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{	
			{"PauseLock", 50},
			{"StopEndTime"},
			{"DelNpc", "BOSS"},
			{"DelNpc", "guaiwu"},

			{"AddNpc", 18, 1, 0, "BOSS", "Stage_4_BOSS", 2, 45, 0, 0, 0},
			{"SetNpcAi", "BOSS", "Setting/Npc/Ai/AutoMove.ini"},
			{"SetNpcProtected", "BOSS", 1},
			{"ChangeNpcFightState", "BOSS", 0, 0},
			{"SetNpcBloodVisable", "BOSS", false, 0},	
			{"DoCommonAct", "BOSS", 36, 0, 1, 0},

			{"PlayCameraEffect", 9119},		
			{"SetAllUiVisiable", false}, 
			{"SetForbiddenOperation", true},
			{"SetPos", 7994, 7951},
			{"SetPlayerDir", 0},
		},
	},
	[41] = {nTime = 1, nNum = 0,
		tbPrelock = {40},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"RaiseEvent", "ShowPartnerAndHelper", false},
			{"MoveCamera", 0, 2, 60.19, 33.8, 52.57, 35.00001, 21.15678, 5.211328},	
		},
	},
	[42] = {nTime = 2, nNum = 0,
		tbPrelock = {40},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{	
			{"ChangeNpcAi", "Start_Npc1", "Move", "Path8", 0, 0, 0, 0, 0},	
			{"SetAiActive", "Start_Npc1", 1},	
		},
	},
	[43] = {nTime = 8, nNum = 0,
		tbPrelock = {40},
		tbStartEvent = 
		{
			{"NpcBubbleTalk", "BOSS", "沒想到... 我卓非凡今日竟會一敗塗地....", 4, 2, 1},
			{"NpcBubbleTalk", "Start_Npc1", "卓非凡，多行不義必自斃！", 4, 4, 1},
			{"NpcBubbleTalk", "Start_Npc1", "念在往日的情分上，今日便饒你一命，你好自為之吧！", 4, 6, 1},
		},
		tbUnLockEvent = 
		{	
			{"ChangeNpcAi", "Start_Npc1", "Move", "Path9", 0, 0, 0, 0, 0},				
		},
	},
	
	[45] = {nTime = 1, nNum = 0,
		tbPrelock = {43},
		tbStartEvent = 
		{
			{"NpcBubbleTalk", "BOSS", "好機會！！楊影楓，你給我去死吧！！", 3, 0, 1},	
		},
		tbUnLockEvent = 
		{	
			-- {"NpcBubbleTalk", "Start_Npc1", "什么！卓非凡，你！！！", 4, 0, 1},
			-- {"SetNpcDir", "Start_Npc1", 16},
			-- {"CastSkill", "Start_Npc1", 1486, 1, 7675, 8314},
			-- {"DoCommonAct", "Start_Npc1", 16, 0},
			-- {"SetAiActive", "Start_Npc1", 0},
		},
	},
	[46] = {nTime = 0, nNum = 1,										--击杀镜头动画
		tbPrelock = {45},
		tbStartEvent = 
		{
			{"SetNpcDir", "Start_Npc1", 16},
			{"SetAiActive", "Start_Npc1", 0},
			--{"LeaveAnimationState", true},

			{"ShowAllRepresentObj", false},
			{"PlayCameraAnimation", 3, 46},
			{"PlayCameraEffect", 9123},
			{"PlayEffect", 9125, 0, 0, 0, 1},
			{"PlaySound", 47},
		},
		tbUnLockEvent = 
		{
			{"ShowAllRepresentObj", true},
			{"LeaveAnimationState", true},

			{"DoCommonAct", "BOSS", 37, 0, 1, 0},
			{"NpcBubbleTalk", "Start_Npc1", "...........", 4, 1, 1},
		},
	},
	

	[49] = {nTime = 0, nNum = 1,
		tbPrelock = {46},
		tbStartEvent = 
		{
			{"RaiseEvent", "ShowTaskDialog", 49, 1037, false},				
		},
		tbUnLockEvent = 
		{
			{"ResumeLock", 50},
			{"SetShowTime", 50},
			{"SetAllUiVisiable", true}, 
			{"LeaveAnimationState", true},
			{"GameWin"},
		},
	},
	[50] = {nTime = 360, nNum = 0,
		tbPrelock = {1},
		tbStartEvent = 
		{
			{"RaiseEvent", "RegisterTimeoutLock"},
		},
		tbUnLockEvent = 
		{
			{"GameLost"},
		},
	},
--------------------拦路技能-----------------
	[51] = {nTime = 2, nNum = 0,		--怪物释放技能
		tbPrelock = {6},
		tbStartEvent = 
		{
			{"CastSkill", "guaiwu1", 1420, 1, 4578, 2624},
		},
		tbUnLockEvent = 
		{
			{"CastSkill", "guaiwu1", 2430, 10, 4578, 2624},
		},
	},
	[52] = {nTime = 2, nNum = 0,		--怪物释放技能
		tbPrelock = {9},
		tbStartEvent = 
		{
			{"CastSkill", "guaiwu1", 1420, 1, 5090, 4692},
		},
		tbUnLockEvent = 
		{
			{"CastSkill", "guaiwu1", 2437, 10, 5090, 4692},
		},
	},
	[53] = {nTime = 0.5, nNum = 0,		--怪物释放技能
		tbPrelock = {52},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
		},
	},
	[54] = {nTime = 2, nNum = 0,		--怪物释放技能
		tbPrelock = {53},
		tbStartEvent = 
		{
			{"CastSkill", "guaiwu1", 1420, 1, 5033, 5143},
		},
		tbUnLockEvent = 
		{
			{"CastSkill", "guaiwu1", 2480, 10, 5033, 5143},
		},
	},
--------------------------boss血量召唤光环--------------
	[55] = {nTime = 0, nNum = 1,
		tbPrelock = {13},
		tbStartEvent = 
		{
			{"NpcHpUnlock", "BOSS", 55, 80},
		},
		tbUnLockEvent = 
		{
			{"AddNpc", 8, 1, 0, "guaiwu", "guanghuan1", false, 40, 0, 9009, 0},
			{"NpcBubbleTalk", "guaiwu", "莊主，奴家來助你一臂之力！", 5, 0, 1},
			--{"DoCommonAct", "BOSS", 17, 0, 1, 0},
		},
	},
	[56] = {nTime = 0, nNum = 1,
		tbPrelock = {13},
		tbStartEvent = 
		{
			{"NpcHpUnlock", "BOSS", 56, 50},
		},
		tbUnLockEvent = 
		{
			{"AddNpc", 9, 1, 0, "guaiwu", "guanghuan2", false, 40, 0, 9009, 0},
			{"NpcBubbleTalk", "guaiwu", "莊主，奴家來為你療傷！", 5, 1.5, 1},
			{"NpcBubbleTalk", "Start_Npc1", "少俠，優先擊殺[FFFE0D]攜帶光環[-]的敵人！", 5, 0, 1},
			{"BlackMsg", "出現攜帶[FFFE0D]治癒光環[-]的敵人，優先擊殺！"},
			--{"DoCommonAct", "BOSS", 17, 0, 1, 0},
		},
	},
	[57] = {nTime = 0, nNum = 1,
		tbPrelock = {55},
		tbStartEvent = 
		{
			{"MoveCameraToPosition", 57, 1, 8136, 8130, -15},
			{"SetAllUiVisiable", false}, 
			{"SetForbiddenOperation", true},
		},
		tbUnLockEvent = 
		{
		},
	},
	[58] = {nTime = 5, nNum = 0,
		tbPrelock = {57},
		tbStartEvent = 
		{
			{"SetGameWorldScale", 0.1},
			{"OpenWindowAutoClose", "RockerGuideNpcPanel", "出現了[FFFE0D]光環[-]敵人，優先擊殺！"},
		},
		tbUnLockEvent = 
		{
			{"SetGameWorldScale", 1},
			{"CloseWindow", "RockerGuideNpcPanel"},

			{"SetAllUiVisiable", true}, 
			{"SetForbiddenOperation", false},
			{"LeaveAnimationState", true},
		},
	},

	---------------镜头动画--------------------
	[60] = {nTime = 9, nNum = 0,										--boss介绍计时
		tbPrelock = {11},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
		},
	},
	[61] = {nTime = 2, nNum = 0,										--boss介绍
		tbPrelock = {60},
		tbStartEvent = 
		{
			{"OpenWindowAutoClose", "BossReferral", "卓", "非凡", "藏劍山莊主人"},
		},
		tbUnLockEvent = 
		{
			{"CloseWindow", "BossReferral"},
		},
	},

}
