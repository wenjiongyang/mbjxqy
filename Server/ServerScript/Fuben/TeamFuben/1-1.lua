
local tbFubenSetting = {};
Fuben:SetFubenSetting(300, tbFubenSetting)		-- 绑定副本内容和地图

tbFubenSetting.szFubenClass 			= "TeamFubenBase";									-- 副本类型
tbFubenSetting.szName 					= "藏劍山莊"											-- 单纯的名字，后台输出或统计使用
tbFubenSetting.szNpcPointFile 			= "Setting/Fuben/TeamFuben/1_1/NpcPos.tab"			-- NPC点
tbFubenSetting.szPathFile				= "Setting/Fuben/TeamFuben/1_1/NpcPath.tab"				-- 寻路点
tbFubenSetting.tbMultiBeginPoint        = {{5988, 1594},{5982, 1350},{5666, 1584},{5658, 1333}}	-- 副本出生点
tbFubenSetting.tbTempRevivePoint 		= {5818, 1460}											-- 临时复活点，副本内有效，出副本则移除
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
	NpcIndex19	 	= {19, 19},
	NpcIndex20	 	= {20, 20},
	NpcIndex21	 	= {21, 21},
	NpcIndex22	 	= {22, 22},
	NpcIndex23	 	= {23, 23},
	NpcIndex24	 	= {24, 24},
	NpcIndex25	 	= {25, 25},
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
	NpcNum13 		= {19, 19},
	NpcNum14 		= {20, 20},
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

436 篝火

]]

tbFubenSetting.NPC =
{
	[1] = {nTemplate = 51,    nLevel = -1, nSeries = -1},  --卓非凡
	[2] = {nTemplate = 959,   nLevel = -1, nSeries = -1},  --紫轩
	[3] = {nTemplate = 960,   nLevel = -1, nSeries = -1},  --蔷薇
	[4] = {nTemplate = 967,   nLevel = -1, nSeries = -1},  --庄丁
	[5] = {nTemplate = 968,   nLevel = -1, nSeries = -1},  --庄丁头目
	[6] = {nTemplate = 969,   nLevel = -1, nSeries = -1},  --山庄护卫
	[7] = {nTemplate = 970,   nLevel = -1, nSeries = -1},  --山庄高手
	[8] = {nTemplate = 971,   nLevel = -1, nSeries = -1},  --武林人士
	[9] = {nTemplate = 972,   nLevel = -1, nSeries = -1},  --武林高手1
	[10] = {nTemplate = 973,  nLevel = -1, nSeries = -1},  --武林高手2
	[11] = {nTemplate = 974,  nLevel = -1, nSeries = -1},  --武林高手3
	[12] = {nTemplate = 975,  nLevel = -1, nSeries = -1},  --藏剑弟子
	[13] = {nTemplate = 976,  nLevel = -1, nSeries = -1},  --藏剑精英
	[14] = {nTemplate = 1319, nLevel = -1, nSeries = -1},  --内堂弟子
	[15] = {nTemplate = 1320, nLevel = -1, nSeries = -1},  --贴身护卫
	[16] = {nTemplate = 74,   nLevel = -1, nSeries = 0},  --上升气流
	[17] = {nTemplate = 104,  nLevel = -1, nSeries = 0},  --动态障碍墙
	[18] = {nTemplate = 957,  nLevel = -1, nSeries = 0},  --弩车（变身）
	[19] = {nTemplate = 958,  nLevel = 15, nSeries = 0},  --弩车
	[20] = {nTemplate = 993,  nLevel = -1, nSeries = -1},  --山庄侍女
	[21] = {nTemplate = 994,  nLevel = -1, nSeries = -1},  --神射手
	[22] = {nTemplate = 1492,  nLevel = -1, nSeries = 0},  --月明瑶（稀有）
	[23] = {nTemplate = 1601,  nLevel = -1, nSeries = -1},  --无忧杀手
	[24] = {nTemplate = 991,  nLevel = -1, nSeries = 0},  --卓非凡(非战斗NPC)
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
			{"SetShowTime", 32},

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
			{"SetTargetPos", 5831, 2097},
			{"SetFubenProgress", -1,"探索藏劍山莊"},
			{"AddNpc", "NpcIndex17", 1, 1, "wall_1", "wall_1_1", false, 16},
			{"AddNpc", "NpcIndex17", 1, 1, "wall_2", "wall_1_2", false, 32},
			{"AddNpc", "NpcIndex17", 1, 1, "wall_3", "wall_1_3", false, 32},
			{"AddNpc", "NpcIndex17", 1, 1, "wall_4", "wall_1_4", false, 16},
			{"AddNpc", "NpcIndex17", 2, 1, "wall_5", "wall_1_5", false, 16},
		},
		tbUnLockEvent =
		{
			{"ClearTargetPos"},
			{"SetFubenProgress", -1,"擊敗敵人"},
			{"NpcBubbleTalk", "guaiwu1", "何人擅闖藏劍山莊，還不速速退去！", 3, 2, 1},

			--刷怪
			{"AddNpc", "NpcIndex4", "NpcNum2", 3, "guaiwu", "TeamFuben1_1_1", false, 0, 0, 9005, 0.5},
			{"AddNpc", "NpcIndex20", "NpcNum2", 3, "guaiwu", "TeamFuben1_1_2", false, 0, 0, 9005, 0.5},
			{"AddNpc", "NpcIndex5", "NpcNum1", 3, "guaiwu1", "TeamFuben1_1_3", false, 0, 0, 9005, 0.5},
			{"AddNpc", "NpcIndex12", "NpcNum4", 3, "guaiwu", "TeamFuben1_1_4", false, 0, 5, 9005, 0.5},
		},
	},
	[3] = {nTime = 0, nNum = "NpcNum9",
		tbPrelock = {2},
		tbStartEvent =
		{
		},
		tbUnLockEvent =
		{
			{"SetTargetPos", 5830, 4922},
			{"SetFubenProgress", -1,"探索藏劍山莊"},
			{"RaiseEvent", "AddMissionScore", 5},
			{"OpenDynamicObstacle", "ops1"},
			{"DoDeath", "wall_1"},
		},
	},
	[4] = {nTime = 0, nNum = 1,
		tbPrelock = {3},
		tbStartEvent =
		{
			{"TrapUnlock", "TrapLock2", 4},

			--紫轩
			{"AddNpc", "NpcIndex2", "NpcNum1", 0, "Leader", "TeamFuben1_Leader_1", false, 31, 0, 0, 0},
			{"SetNpcProtected", "Leader", 1},
			{"ChangeNpcFightState", "Leader", 0, 0},
			{"SetAiActive", "Leader", 0},
		},
		tbUnLockEvent =
		{
			{"SetNpcBloodVisable", "Leader", false, 0},
			{"SetFubenProgress", -1,"擊敗守衛"},
			{"ClearTargetPos"},
			{"NpcBubbleTalk", "Leader", "你們是什麼人？為何擅闖藏劍山莊！", 4, 2, 1},
			{"NpcBubbleTalk", "Leader", "守衛何在！趕緊將這群不速之客趕出山莊！", 4, 3, 1},
			{"NpcBubbleTalk", "Leader", "沒想到你們還有點本事！守衛們，繼續給我上！", 4, 8, 1},


			{"AddNpc", "NpcIndex6", "NpcNum4", 5, "guaiwu", "TeamFuben1_2_2", false, 0, 3, 9005, 0.5},
			{"AddNpc", "NpcIndex6", "NpcNum2", 5, "guaiwu", "TeamFuben1_2_3", false, 0, 6, 9005, 0.5},
			{"AddNpc", "NpcIndex7", "NpcNum1", 5, "guaiwu", "TeamFuben1_2_4", false, 0, 6, 9005, 0.5},
			{"AddNpc", "NpcIndex6", "NpcNum2", 5, "guaiwu", "TeamFuben1_2_5", false, 0, 10, 9005, 0.5},
			{"AddNpc", "NpcIndex7", "NpcNum1", 5, "guaiwu", "TeamFuben1_2_6", false, 0, 10, 9005, 0.5},
		},
	},
	[5] = {nTime = 0, nNum = "NpcNum10",
		tbPrelock = {4},
		tbStartEvent =
		{
		},
		tbUnLockEvent =
		{
			{"RaiseEvent", "AddMissionScore", 9},
			{"SetFubenProgress", -1,"擊敗紫軒"},
			{"NpcBubbleTalk", "Leader", "就讓小女子親自來領教各位的高招吧！", 4, 1, 1},
			{"SetNpcProtected", "Leader", 0},
			{"ChangeNpcFightState", "Leader", 1, 0},
			{"SetNpcBloodVisable", "Leader", true, 0},
			{"SetAiActive", "Leader", 1},
			{"NpcHpUnlock", "Leader", 50, 70},
		},
	},
	[50] = {nTime = 1, nNum = 0,
		tbPrelock = {5},
		tbStartEvent =
		{
		},
		tbUnLockEvent =
		{
			{"NpcBubbleTalk", "Leader", "討厭的傢伙，我會讓你們吃些苦頭的！", 3, 1, 1},
			{"NpcHpUnlock", "Leader", 51, 30},
		},
	},
	[51] = {nTime = 0, nNum = 1,
		tbPrelock = {50},
		tbStartEvent =
		{
		},
		tbUnLockEvent =
		{
			{"NpcBubbleTalk", "Leader", "可惡.... 不要以為這就結束了！", 3, 1, 1},
			{"NpcHpUnlock", "Leader", 6, 1},
		},
	},
	[6] = {nTime = 0, nNum = 1,
		tbPrelock = {5},
		tbStartEvent =
		{

		},
		tbUnLockEvent =
		{
			--奖励掉落
			{"RaiseEvent", "DropAward", "Setting/Npc/DropFile/TeamFuben/zixuan.tab", 5706, 5501},
			--{"RaiseEvent", "DropAward", "Setting/Npc/DropFile/TeamFuben/zixuan.tab", 5892, 5556},
			{"NpcBubbleTalk", "Leader", "藏劍山莊臥虎藏龍，總有你們無法匹敵的對手！", 4, 1, 1},
			{"SetNpcProtected", "Leader", 1},
			{"ChangeNpcFightState", "Leader", 0, 0},
			{"SetNpcBloodVisable", "Leader", false, 0},
			{"SetAiActive", "Leader", 0},

			{"RaiseEvent", "AddMissionScore", 10},
			{"OpenDynamicObstacle", "ops2"},
			{"DoDeath", "wall_2"},
			{"SetTargetPos", 8597, 5809},
			{"SetFubenProgress", -1,"探索藏劍山莊"},

			--重新设置复活点
			{"SetDynamicRevivePoint", 5836, 5201},

			--稀有几率
			{"Random", {330000, 60}},
		},
	},
	[7] = {nTime = 0, nNum = 1,
		tbPrelock = {6},
		tbStartEvent =
		{
			{"TrapUnlock", "TrapLock3", 7},
			{"AddNpc", "NpcIndex8", "NpcNum2", 8, "guaiwu", "TeamFuben1_3_1", false, 45, 0, 0, 0},
			{"AddNpc", "NpcIndex21", "NpcNum2", 8, "guaiwu", "TeamFuben1_3_2", false, 45, 0, 0, 0},
			{"AddNpc", "NpcIndex9", "NpcNum1", 8, "guaiwu1", "TeamFuben1_3_3", false, 45, 0, 0, 0},
		},
		tbUnLockEvent =
		{
			{"ClearTargetPos"},
			{"DelNpc", "Leader"},
			{"NpcBubbleTalk", "guaiwu1", "你們是什麼人？大夥一起拿下他們！", 3, 1, 1},
			{"SetFubenProgress", -1,"擊敗武林人士"},
			{"AddNpc", "NpcIndex8", "NpcNum2", 8, "guaiwu", "TeamFuben1_3_4", false, 28, 5, 9005, 0.5},
			{"AddNpc", "NpcIndex8", "NpcNum2", 8, "guaiwu", "TeamFuben1_3_4", false, 28, 5, 9005, 0.5},
			{"AddNpc", "NpcIndex8", "NpcNum2", 8, "guaiwu", "TeamFuben1_3_4", false, 28, 5, 9005, 0.5},
		},
	},
	[8] = {nTime = 0, nNum = "NpcNum11",
		tbPrelock = {6},
		tbStartEvent =
		{
		},
		tbUnLockEvent =
		{
			{"RaiseEvent", "AddMissionScore", 6},
			{"OpenDynamicObstacle", "ops3"},
			{"DoDeath", "wall_3"},
			{"SetTargetPos", 7892, 7846},
		},
	},
	[9] = {nTime = 0, nNum = 1,
		tbPrelock = {8},
		tbStartEvent =
		{
			{"TrapUnlock", "TrapLock4", 9},
			{"AddNpc", "NpcIndex8", "NpcNum4", 10, "guaiwu", "TeamFuben1_4_1", false, 32, 0, 9005, 0.5},
		},
		tbUnLockEvent =
		{
			{"ClearTargetPos"},
			{"NpcBubbleTalk", "guaiwu1", "不知死活的傢伙，就讓我們送你上路吧！", 3, 1, 1},
		},
	},
	[10] = {nTime = 0, nNum = "NpcNum4",
		tbPrelock = {8},
		tbStartEvent =
		{
		},
		tbUnLockEvent =
		{
			{"SetTargetPos", 8233, 8667},
			{"AddNpc", "NpcIndex8", "NpcNum2", 12, "guaiwu", "TeamFuben1_4_2", false, 32, 0, 9005, 0.5},
			{"AddNpc", "NpcIndex21", "NpcNum2", 12, "guaiwu", "TeamFuben1_4_3", false, 32, 0, 9005, 0.5},
			{"AddNpc", "NpcIndex9", "NpcNum1", 12, "guaiwu1", "TeamFuben1_4_4", false, 32, 0, 9005, 0.5},
		},
	},

	--藏剑山庄稀有
	[60] = {nTime = 0, nNum = 1,
		tbPrelock = {},
		tbStartEvent =
		{
			{"TrapUnlock", "Xiyou", 60},

			--关闭锁
			{"CloseLock", 12},

			--月明瑶
			{"AddNpc", "NpcIndex22", "NpcNum1", 0, "Xiyou", "TeamFuben1_Xiyou", false, 14, 0, 0, 0},
			{"SetNpcProtected", "Xiyou", 1},
		},
		tbUnLockEvent =
		{
			{"BlackMsg", "前方的姑娘似乎遇到了麻煩，去助她一臂之力"},
			{"SetNpcProtected", "Xiyou", 0},
			{"NpcBubbleTalk", "guaiwu", "小娘子，遇到我們你就乖乖的留下來吧！", 4, 0, 1},
			{"NpcBubbleTalk", "Xiyou", "可惡的傢伙，你們休要阻我！！", 4, 2, 1},
		},
	},
	[61] = {nTime = 0, nNum = 1,
		tbPrelock = {8},
		tbStartEvent =
		{
			--寻路
			{"ChangeNpcAi", "Xiyou", "Move", "Path1", 61, 0, 0, 0, 0},
			{"NpcBubbleTalk", "Xiyou", "多謝各位俠士相助，還請繼續護送小女子一程！", 4, 0, 1},
			{"NpcBubbleTalk", "Xiyou", "小女子受父親所托前往此處尋找一物，也不知究竟藏匿於何處...", 4, 3, 1},
		},
		tbUnLockEvent =
		{

		},
	},
	[62] = {nTime = 0, nNum = 1,
		tbPrelock = {10},
		tbStartEvent =
		{
			--寻路
			{"ChangeNpcAi", "Xiyou", "Move", "Path2", 62, 1, 1, 0, 0},
		},
		tbUnLockEvent =
		{
			{"ClearTargetPos"},

			--无忧杀手
			{"AddNpc", "NpcIndex23", "NpcNum1", 63, "Xiyou_Guaiwu", "TeamFuben1_XiyouGuaiwu", false, 0, 0, 0, 0},
			{"NpcBubbleTalk", "Xiyou_Guaiwu", "月明瑤，總算是找到你了！交出《武道德經》然後乖乖的跟我們走吧！", 4, 1, 1},
			{"NpcBubbleTalk", "Xiyou", "糟糕，是無憂教的人！！", 4, 2, 1},
			{"BlackMsg", "擊敗無憂教刺客，保護月明瑤！"},
		},
	},
	[63] = {nTime = 0, nNum = 1,
		tbPrelock = {62},
		tbStartEvent =
		{

		},
		tbUnLockEvent =
		{
			{"NpcBubbleTalk", "Xiyou", "一路上給諸位添了不少麻煩，小女子在此謝過各位！", 4, 0, 1},

			{"SetTargetPos", 7833, 9315},
			{"RaiseEvent", "AddMissionScore", 6},
			{"AddNpc", 16, 1, 1, "TeamFuben1_4", "TeamFuben1_4", 1},
			{"ChangeTrap", "Jump1", nil, {7129, 9404, 2}},
			{"ChangeTrap", "Jump2", nil, {6587, 8832, 2}},
			{"ChangeTrap", "Jump3", nil, {6132, 9045, 2}},
		},
	},

	[11] = {nTime = 0, nNum = 1,
		tbPrelock = {8},
		tbStartEvent =
		{
			{"TrapUnlock", "TrapLock7", 11},
		},
		tbUnLockEvent =
		{
			{"ClearTargetPos"},
		},
	},
	[12] = {nTime = 0, nNum = "NpcNum5",
		tbPrelock = {10},
		tbStartEvent =
		{
		},
		tbUnLockEvent =
		{
			{"SetTargetPos", 7833, 9315},
			{"RaiseEvent", "AddMissionScore", 6},
			{"AddNpc", 16, 1, 1, "TeamFuben1_4", "TeamFuben1_4", 1},
			{"ChangeTrap", "Jump1", nil, {7129, 9404, 2}},
			{"ChangeTrap", "Jump2", nil, {6587, 8832, 2}},
			{"ChangeTrap", "Jump3", nil, {6132, 9045, 2}},
		},
	},
	[13] = {nTime = 0, nNum = 1,
		tbPrelock = {11},
		tbStartEvent =
		{
			{"TrapUnlock", "Jump1", 13},
		},
		tbUnLockEvent =
		{
			{"ClearTargetPos"},

			--蔷薇
			{"AddNpc", "NpcIndex3", "NpcNum1", 0, "Leader1", "TeamFuben1_Leader_2", false, 0, 0, 0, 0},
		},
	},
	[14] = {nTime = 0, nNum = 1,
		tbPrelock = {11},
		tbStartEvent =
		{
			{"TrapUnlock", "Jump3", 14},
		},
		tbUnLockEvent =
		{
			{"NpcBubbleTalk", "Leader1", "你們是什麼人，莫非也是爹爹派來的人嗎？", 3, 1, 1},
			{"NpcBubbleTalk", "Leader1", "哼！想要帶我回去的話，就讓我看看你們的本事吧！", 4, 4, 1},
			{"SetFubenProgress", -1,"擊敗薔薇"},
			{"NpcHpUnlock", "Leader1", 52, 70},
		},
	},
	[52] = {nTime = 0, nNum = 1,
		tbPrelock = {14},
		tbStartEvent =
		{
		},
		tbUnLockEvent =
		{
			{"NpcBubbleTalk", "Leader1", "沒想到你們還有點本事，本小姐也要認真了！", 4, 1, 1},
			{"AddNpc", "NpcIndex8", "NpcNum3", 0, "guaiwu", "TeamFuben1_5_2", false, 0, 1, 9005, 0.5},
			{"AddNpc", "NpcIndex8", "NpcNum3", 0, "guaiwu", "TeamFuben1_5_3", false, 0, 1, 9005, 0.5},
			{"NpcHpUnlock", "Leader1", 53, 30},
		},
	},
	[53] = {nTime = 0, nNum = 1,
		tbPrelock = {52},
		tbStartEvent =
		{
		},
		tbUnLockEvent =
		{
			{"NpcBubbleTalk", "Leader1", "可惡... 沒想到你們竟會如此棘手！", 3, 1, 1},
			{"AddNpc", "NpcIndex9", "NpcNum1", 0, "guaiwu", "TeamFuben1_5_4", false, 0, 0, 9005, 0.5},
			{"AddNpc", "NpcIndex10", "NpcNum1", 0, "guaiwu", "TeamFuben1_5_5", false, 0, 0, 9005, 0.5},
			{"AddNpc", "NpcIndex11", "NpcNum1", 0, "guaiwu", "TeamFuben1_5_6", false, 0, 0, 9005, 0.5},
			{"BlackMsg", "武林高手會增強薔薇的能力，優先將其擊殺！"},
			{"NpcHpUnlock", "Leader1", 15, 1},
		},
	},
	[15] = {nTime = 0, nNum = 1,
		tbPrelock = {11},
		tbStartEvent =
		{

		},
		tbUnLockEvent =
		{
			--奖励掉落
			{"RaiseEvent", "DropAward", "Setting/Npc/DropFile/TeamFuben/qiangwei.tab", 5630, 8427},
			--{"RaiseEvent", "DropAward", "Setting/Npc/DropFile/TeamFuben/qiangwei.tab", 5611, 8235},
			{"CastSkill", "guaiwu", 3, 1, -1, -1},

			{"RaiseEvent", "AddMissionScore", 10},
			{"NpcBubbleTalk", "Leader1", "哼，算你們厲害！", 4, 1, 1},
			{"SetNpcProtected", "Leader1", 1},
			{"ChangeNpcFightState", "Leader1", 0, 0},
			{"SetNpcBloodVisable", "Leader1", false, 0},
			{"SetAiActive", "Leader1", 0},

			{"SetFubenProgress", -1,"探索藏劍山莊"},
			{"OpenDynamicObstacle", "ops4"},
			{"DoDeath", "wall_4"},
			{"SetTargetPos", 2796, 5051},

			--重新设置复活点
			{"SetDynamicRevivePoint", 5675, 8216},
		},
	},
	[16] = {nTime = 0, nNum = 1,
		tbPrelock = {15},
		tbStartEvent =
		{
			{"TrapUnlock", "TrapLock5", 16},
		},
		tbUnLockEvent =
		{
			{"ClearTargetPos"},
			{"DelNpc", "Leader1"},
			{"NpcBubbleTalk", "guaiwu1", "你們是什麼人？大夥一起拿下他們！", 3, 1, 1},
			{"SetFubenProgress", -1,"擊敗藏劍弟子"},
		}
	},
	[17] = {nTime = 3, nNum = 0,
		tbPrelock = {16},
		tbStartEvent =
		{
		},
		tbUnLockEvent =
		{
			{"BlackMsg", "弩車出現！擊殺弩車後可操控弩車攻擊敵人！"},
			{"AddNpc", "NpcIndex19", "NpcNum1", 18, "nuche", "TeamFuben1_6_4", false, 17, 0, 9005, 0.5},
			{"SaveNpcInfo", "nuche"},
		},
	},
	[18] = {nTime = 0, nNum = 1,
		tbPrelock = {17},
		tbStartEvent =
		{
		},
		tbUnLockEvent =
		{
			{"BlackMsg", "弩車出現！操縱弩車來攻擊藏劍弟子！"},
			{"CloseLock", 21},
			{"AddNpc", "NpcIndex18", "NpcNum1", 0, "nuche", "SAVE_POS", false, "SAVE_DIR", 0, 0, 0},
		},
	},
	[19] = {nTime = 0, nNum = "NpcNum14", 
		tbPrelock = {18},
		tbStartEvent =
		{
			{"AddNpc", "NpcIndex12", "NpcNum10",19, "guaiwu", "TeamFuben1_6_7", false, 0, 2, 9005, 0.5},
			{"AddNpc", "NpcIndex12", "NpcNum10",19, "guaiwu", "TeamFuben1_6_7", false, 0, 6, 9005, 0.5},
		},
		tbUnLockEvent =
		{
		},
	},
	[20] = {nTime = 0, nNum = "NpcNum13",
		tbPrelock = {16},
		tbStartEvent =
		{
			{"AddNpc", "NpcIndex12", "NpcNum2", 20, "guaiwu", "TeamFuben1_6_1", false, 11, 0, 0, 0},
			{"AddNpc", "NpcIndex21", "NpcNum2", 20, "guaiwu", "TeamFuben1_6_2", false, 11, 0, 0, 0},
			{"AddNpc", "NpcIndex13", "NpcNum1", 20, "guaiwu1", "TeamFuben1_6_3", false, 11, 0, 0, 0},
			{"AddNpc", "NpcIndex12", "NpcNum2", 20, "guaiwu", "TeamFuben1_6_5", false, 0, 5, 9005, 0.5},
			{"AddNpc", "NpcIndex12", "NpcNum2", 20, "guaiwu", "TeamFuben1_6_6", false, 0, 5, 9005, 0.5},
			{"AddNpc", "NpcIndex12", "NpcNum10",20, "guaiwu", "TeamFuben1_6_7", false, 0, 9, 9005, 0.5},
		},
		tbUnLockEvent =
		{
			{"UnLock", 21},
		}
	},
	[21] = {nTime = 0, nNum = 1,  --杀弩车后关闭此锁
		tbPrelock = {15},
		tbStartEvent =
		{			
		},
		tbUnLockEvent =
		{
		},
	},
	[22] = {nTime = 0.1, nNum = 0, 
		tbPrelock = {19, 20},
		tbStartEvent =
		{
		},
		tbUnLockEvent =
		{
		},
	},
	[23] = {nTime = 0.1, nNum = 0,  
		tbPrelock = {{21, 22}},
		tbStartEvent =
		{
		},
		tbUnLockEvent =
		{
			{"RaiseEvent", "AddMissionScore", 14},
			{"SetFubenProgress", -1,"探索藏劍山莊"},
			{"DelNpc", "nuche"},
			{"RemovePlayerSkillState", 2215},
			{"OpenDynamicObstacle", "ops5"},
			{"DoDeath", "wall_5"},
			{"SetTargetPos", 1925, 6898},

			--重新设置复活点
			{"SetDynamicRevivePoint", 1920, 4330},
		},
	},
	[24] = {nTime = 0, nNum = 1,
		tbPrelock = {23},
		tbStartEvent =
		{
			{"TrapUnlock", "TrapLock6", 24},

			--卓非凡
			{"AddNpc", "NpcIndex1", "NpcNum1", 31, "BOSS", "TeamFuben1_BOSS", false, 0, 0, 0, 0},
		},
		tbUnLockEvent =
		{
			{"ClearTargetPos"},
			{"NpcBubbleTalk", "BOSS", "沒想到你們竟能闖入這裡！但是，到此為止了！", 4, 1, 1},
			{"AddNpc", "NpcIndex14", "NpcNum4", 0, "guaiwu", "TeamFuben1_7_1", false, 0, 6, 9005, 0.5},
			{"SetFubenProgress", -1,"擊敗卓非凡"},
			{"NpcHpUnlock", "BOSS", 25, 70},
		},
	},
	[25] = {nTime = 0, nNum = 1,
		tbPrelock = {23},
		tbStartEvent =
		{
		},
		tbUnLockEvent =
		{
			{"NpcBubbleTalk", "BOSS", "哼，沒想到你們還有點本事，既然如此卓某也能不能托大了！", 3, 1, 1},
			{"AddNpc", "NpcIndex14", "NpcNum4", 0, "guaiwu", "TeamFuben1_7_1", false, 0, 0, 9005, 0.5},
			{"AddNpc", "NpcIndex14", "NpcNum2", 0, "guaiwu", "TeamFuben1_7_2", false, 0, 3, 9005, 0.5},
			{"AddNpc", "NpcIndex15", "NpcNum2", 0, "guaiwu", "TeamFuben1_7_4", false, 0, 3, 9005, 0.5},
			{"NpcHpUnlock", "BOSS", 28, 40},
		},
	},
	[26] = {nTime = 3, nNum = 0,
		tbPrelock = {25},
		tbStartEvent =
		{

		},
		tbUnLockEvent =
		{
			{"AddNpc", "NpcIndex19", "NpcNum1", 27, "nuche", "TeamFuben1_7_6", false, 48, 0, 9005, 0.5},
			{"SaveNpcInfo", "nuche"},
			{"BlackMsg", "弩車出現！利用弩車來擊敗敵人！"},
		},
	},
	[27] = {nTime = 0, nNum = 1,
		tbPrelock = {26},
		tbStartEvent =
		{
		},
		tbUnLockEvent =
		{
			{"AddNpc", "NpcIndex18", "NpcNum1", 0, "nuche", "SAVE_POS", false, "SAVE_DIR", 0, 0, 0},
		},
	},
	[28] = {nTime = 0, nNum = 1,
		tbPrelock = {25},
		tbStartEvent =
		{
		},
		tbUnLockEvent =
		{
			{"DelNpc", "nuche"},
			{"NpcBubbleTalk", "BOSS", "可惡... 沒想到竟會如此棘手！藏劍弟子們，都給我上！", 3, 1, 1},
			{"AddNpc", "NpcIndex14", "NpcNum4", 0, "guaiwu", "TeamFuben1_7_1", false, 0, 0, 9005, 0.5},
			{"AddNpc", "NpcIndex14", "NpcNum2", 0, "guaiwu", "TeamFuben1_7_2", false, 0, 0, 9005, 0.5},
			{"AddNpc", "NpcIndex15", "NpcNum1", 0, "guaiwu", "TeamFuben1_7_3", false, 0, 0, 9005, 0.5},
			{"AddNpc", "NpcIndex14", "NpcNum2", 0, "guaiwu", "TeamFuben1_7_4", false, 0, 0, 9005, 0.5},
			{"AddNpc", "NpcIndex15", "NpcNum1", 0, "guaiwu", "TeamFuben1_7_5", false, 0, 0, 9005, 0.5},
		},
	},
	[29] = {nTime = 3, nNum = 0,
		tbPrelock = {28},
		tbStartEvent =
		{

		},
		tbUnLockEvent =
		{
			{"AddNpc", "NpcIndex19", "NpcNum1", 30, "nuche", "TeamFuben1_7_6", false, 48, 0, 9005, 0.5},
			{"SaveNpcInfo", "nuche"},
			{"BlackMsg", "弩車出現！利用弩車來擊敗敵人！"},
		},
	},
	[30] = {nTime = 0, nNum = 1,
		tbPrelock = {29},
		tbStartEvent =
		{
		},
		tbUnLockEvent =
		{
			{"AddNpc", "NpcIndex18", "NpcNum1", 0, "nuche", "SAVE_POS", false, "SAVE_DIR", 0, 0, 0},
		},
	},
	[31] = {nTime = 0, nNum = "NpcNum1",
		tbPrelock = {23},
		tbStartEvent =
		{

		},
		tbUnLockEvent =
		{
			--奖励掉落
			{"RaiseEvent", "DropAward", "Setting/Npc/DropFile/TeamFuben/zhuofeifan.tab", 1826, 7928},
			--{"RaiseEvent", "DropAward", "Setting/Npc/DropFile/TeamFuben/zhuofeifan.tab", 2008, 7908},

			{"SetFubenProgress", -1,"闖關成功"},
			{"RaiseEvent", "AddMissionScore", 15},
			{"CastSkill", "guaiwu", 3, 1, -1, -1},
			{"DelNpc", "nuche"},
			{"RemovePlayerSkillState", 2215},
			{"OpenWindow", "LingJueFengLayerPanel", "Win"},
			{"RaiseEvent", "KickOutAllPlayer", 70},
			{"BlackMsg", "闖關成功！篝火已刷出，可持續獲得經驗！"},
			{"GameWin"},
			{"AddSimpleNpc", 1610, 1932, 7223, 0},
			{"AddSimpleNpc", 991, 1944, 7593, 32},

		},
	},
	[32] = {nTime = 900, nNum = 0,
		tbPrelock = {1},
		tbStartEvent =
		{
		},
		tbUnLockEvent =
		{
			{"SetFubenProgress", -1,"闖關失敗"},
			{"RaiseEvent", "KickOutAllPlayer", 10},
			{"BlackMsg", "時間耗盡，本次挑戰失敗！"},
			{"OpenWindow", "LingJueFengLayerPanel", "Fail"},
			{"GameLost"},
		},
	},
}