
local tbFubenSetting = {};
Fuben:SetFubenSetting(305, tbFubenSetting)		-- 绑定副本内容和地图

tbFubenSetting.szFubenClass 			= "TeamFubenBase";									-- 副本类型
tbFubenSetting.szName 					= "雪峰硝煙"										-- 单纯的名字，后台输出或统计使用
tbFubenSetting.szNpcPointFile 			= "Setting/Fuben/TeamFuben/1_6/NpcPos.tab"			-- NPC点
tbFubenSetting.szPathFile 				= "Setting/Fuben/TeamFuben/1_6/NpcPath.tab"				-- 寻路点								
tbFubenSetting.tbMultiBeginPoint        = {{1212, 2857},{1083, 2509},{1484, 2774},{1341, 2406}}	-- 副本出生点
tbFubenSetting.tbTempRevivePoint 		= {1212, 2857}											-- 临时复活点，副本内有效，出副本则移除
tbFubenSetting.nStartDir				= 24;


-- ID可以随便 普通副本NPC数量 ；精英模式NPC数量
tbFubenSetting.NUM = 
{
}

tbFubenSetting.ANIMATION = 
{
	[1] = "Scenes/camera/Main Camera.controller",
}

tbFubenSetting.NPC = 
{
	[1]  = {nTemplate = 2458, nLevel = -1, nSeries = -1},  --十夫长-精英1
	[2]  = {nTemplate = 2459, nLevel = -1, nSeries = -1},  --江湖高手-精英2
	[3]  = {nTemplate = 2460, nLevel = -1, nSeries = -1},  --降卒军官-精英3
	[4]  = {nTemplate = 2461, nLevel = -1, nSeries = -1},  --护卫头目-精英4
	[5]  = {nTemplate = 2462, nLevel = -1, nSeries = -1},  --武夫头领-精英5
	[6]  = {nTemplate = 2463, nLevel = -1, nSeries = -1},  --控尸人-精英6
	[7]  = {nTemplate = 2464, nLevel = -1, nSeries = -1},  --凶恶金兵-怪物1
	[8]  = {nTemplate = 2465, nLevel = -1, nSeries = -1},  --江湖人士-怪物2
	[9]  = {nTemplate = 2466, nLevel = -1, nSeries = -1},  --宋朝降卒-怪物3
	[10] = {nTemplate = 2467, nLevel = -1, nSeries = -1},  --贴身护卫-怪物4
	[11] = {nTemplate = 2468, nLevel = -1, nSeries = -1},  --失节武夫-怪物5
	[12] = {nTemplate = 2469, nLevel = -1, nSeries = -1},  --五毒行者-怪物6

	[13] = {nTemplate = 2470, nLevel = -1, nSeries = -1},  --刺客头目-精英
	[14] = {nTemplate = 2471, nLevel = -1, nSeries = -1},  --阴险刺客-怪物

	[15] = {nTemplate = 2454, nLevel = -1, nSeries = 3},   --尹筱雨-boss
	[16] = {nTemplate = 2455, nLevel = -1, nSeries = 5},   --宋秋石-boss
	[17] = {nTemplate = 2456, nLevel = -1, nSeries = 2},   --古嫣然-boss
	[18] = {nTemplate = 2457, nLevel = -1, nSeries = 4},   --石轩辕-稀有

	[19] = {nTemplate = 74, nLevel = -1, nSeries = 0},   --上身气流
	[20] = {nTemplate = 104,  nLevel = -1, nSeries = 0},   --障碍门

}

tbFubenSetting.LOCK = 
{
	-- 1号锁不能不填，默认1号为起始锁，nTime是到时间自动解锁，nNum表示需要解锁的次数，如填3表示需要被解锁3次才算真正解锁，可以配置字符串
	[1] = {nTime = 2, nNum = 0,
		--tbPrelock 前置锁，激活锁的必要条件{1 , 2, {3, 4}}，代表1和2号必须解锁，3和4任意解锁一个即可
		tbPrelock = {},
		--tbStartEvent 锁激活时的事件
		tbStartEvent = 
		{
			--{"HomeScreenTip", "呼啸栈道", "", 5, 0.5},
		},
		--tbStartEvent 锁解开时的事件
		tbUnLockEvent = 
		{
			--设置同步范围
			{"SetNearbyRange", 3},	
		},
	},
	[2] = {nTime = 900, nNum = 0,
		tbPrelock = {1},
		tbStartEvent = 
		{
			{"SetFubenProgress", -1,"探索雪峰硝煙"},
			{"SetShowTime", 2},	

			--障碍门
			{"AddNpc", 20, 2, 0, "wall1", "men1", false, 32, 0, 0, 0},
			{"AddNpc", 20, 2, 0, "wall2", "men2", false, 16, 0, 0, 0},
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
	[3] = {nTime = 0, nNum = 1,
		tbPrelock = {1},
		tbStartEvent = 
		{
			{"BlackMsg", "冰雪寒風夾雜著鮮血與硝煙的味道迎面撲來......"},
			{"TrapUnlock", "trap1", 3},
			{"SetTargetPos", 2365, 2060},
		},
		tbUnLockEvent = 
		{
		},
	},	
	[4] = {nTime = 0, nNum = 12,
		tbPrelock = {3},
		tbStartEvent = 
		{
			{"ClearTargetPos"},
			--区域1
			{"AddNpc", 1, 2, 4, "jy", "guaiwu1_1", false, 0, 0.5, 9010, 0.5},
			{"AddNpc", 7, 10, 4, "gw", "guaiwu1_2", false, 0, 0.5, 9005, 0.5},

			{"BlackMsg", "這些士兵散發著暴戾之氣！"},
			{"NpcBubbleTalk", "jy", "無人能阻擋我大金的鐵騎！", 4, 2, 1},
		},
		tbUnLockEvent = 
		{
			{"RaiseEvent", "AddMissionScore", 5},
		},
	},
	[5] = {nTime = 0, nNum = 1,
		tbPrelock = {4},
		tbStartEvent = 
		{
			{"TrapUnlock", "trap2", 5},
			{"SetTargetPos", 4033, 2548},
		},
		tbUnLockEvent = 
		{
		},
	},	
	[6] = {nTime = 0, nNum = 12,
		tbPrelock = {5},
		tbStartEvent = 
		{
			{"ClearTargetPos"},
			--区域2
			{"AddNpc", 1, 2, 6, "jy", "guaiwu2_1", false, 0, 0.5, 9010, 0.5},
			{"AddNpc", 7, 10, 6, "gw", "guaiwu2_2", false, 0, 0.5, 9005, 0.5},

			{"BlackMsg", "這些金軍在此處與何人戰鬥？！"},
			{"NpcBubbleTalk", "jy", "哼...又有來送死的南宋武人嗎？", 4, 2, 1},
		},
		tbUnLockEvent = 
		{
			--稀有几率
			{"Random", {330000, 40}},

			{"DoDeath", "wall1"},
			{"OpenDynamicObstacle", "obs1"},

			{"RaiseEvent", "AddMissionScore", 5},
		},
	},

	[7] = {nTime = 0, nNum = 1,
		tbPrelock = {6},
		tbStartEvent = 
		{
			{"TrapUnlock", "trap3", 7},
			{"SetTargetPos", 6354, 2705},
		},
		tbUnLockEvent = 
		{
		},
	},
	[8] = {nTime = 0, nNum = 14,
		tbPrelock = {7},
		tbStartEvent = 
		{
			{"ClearTargetPos"},
			--区域3
			{"AddNpc", 13, 2, 8, "jy", "guaiwu3_1", false, 0, 0.5, 9010, 0.5},
			{"AddNpc", 14, 12, 8, "gw", "guaiwu3_2", false, 0, 0.5, 9005, 0.5},

			{"BlackMsg", "小心刺客！"},
			{"NpcBubbleTalk", "jy", "來了就別想走!", 4, 2, 1},
		},
		tbUnLockEvent = 
		{
			{"RaiseEvent", "AddMissionScore", 6},
		},
	},	
	[9] = {nTime = 0, nNum = 1,
		tbPrelock = {8},
		tbStartEvent = 
		{
			{"BlackMsg", "這些人的武功...似乎不是金人！"},
			{"TrapUnlock", "trap4", 9},
			{"SetTargetPos", 8128, 2727},
		},
		tbUnLockEvent = 
		{
		},
	},
	[10] = {nTime = 0, nNum = 1,			--boss1
		tbPrelock = {9},
		tbStartEvent = 
		{
			{"ClearTargetPos"},
			--区域4
			{"AddNpc", 15, 1, 10, "boss1", "boss1", false, 0, 0.5, 9011, 0.5},

			{"NpcBubbleTalk", "boss1", "（憤怒）你們也投靠金人了嗎？受死吧！", 4, 2, 1},
			{"SetFubenProgress", -1,"擊敗尹筱雨的幻影"},
		},
		tbUnLockEvent = 
		{
			--重新设置复活点
			{"SetDynamicRevivePoint", 9291, 2038},

			{"DoDeath", "gw"},
			{"DoDeath", "jy"},

			{"DoDeath", "wall2"},
			{"OpenDynamicObstacle", "obs2"},

			{"RaiseEvent", "AddMissionScore", 10},
		},
	},
	[11] = {nTime = 0, nNum = 1,
		tbPrelock = {10},
		tbStartEvent = 
		{
			{"SetFubenProgress", -1,"繼續探索雪峰硝煙"},
			{"BlackMsg", "尹筱雨昔日怨氣凝結而成的幻影竟如此厲害！"},
			{"TrapUnlock", "trap5", 11},
			{"SetTargetPos", 8076, 5022},
		},
		tbUnLockEvent = 
		{
		},
	},	
	[12] = {nTime = 0, nNum = 14,
		tbPrelock = {11},
		tbStartEvent = 
		{
			{"ClearTargetPos"},
			--区域5
			{"AddNpc", 13, 2, 12, "jy", "guaiwu5_1", false, 0, 0.5, 9010, 0.5},
			{"AddNpc", 14, 12, 12, "gw", "guaiwu5_2", false, 0, 0.5, 9005, 0.5},

			{"BlackMsg", "小心刺客！"},
			{"NpcBubbleTalk", "jy", "明年今日就是你們的祭日！", 4, 2, 1},
		},
		tbUnLockEvent = 
		{
			{"RaiseEvent", "AddMissionScore", 6},
		},
	},

	[13] = {nTime = 0, nNum = 1,
		tbPrelock = {12},
		tbStartEvent = 
		{
			{"TrapUnlock", "trap6", 13},
			{"SetTargetPos", 8080, 6499},
		},
		tbUnLockEvent = 
		{
		},
	},
	[14] = {nTime = 0, nNum = 12,
		tbPrelock = {13},
		tbStartEvent = 
		{
			{"ClearTargetPos"},
			--区域6
			{"AddNpc", 3, 2, 14, "jy", "guaiwu6_1", false, 0, 0.5, 9010, 0.5},
			{"AddNpc", 9, 10, 14, "gw", "guaiwu6_2", false, 0, 0.5, 9005, 0.5},

			{"BlackMsg", "投降金人的宋兵居然如此之多!"},
			{"NpcBubbleTalk", "jy", "識時務者為俊傑也！", 4, 2, 1},
		},
		tbUnLockEvent = 
		{
			{"RaiseEvent", "AddMissionScore", 6},
		},
	},	
	[15] = {nTime = 0, nNum = 1,			--boss2
		tbPrelock = {14},
		tbStartEvent = 
		{
			--区域6
			{"AddNpc", 16, 1, 15, "boss2", "boss2", false, 0, 0.5, 9011, 0.5},
			{"BlackMsg", "一股高手的淩冽氣息忽然蔓延過來！"},

			{"NpcBubbleTalk", "boss2", "我無法容忍叛徒！", 4, 2, 1},
			{"SetFubenProgress", -1,"擊敗宋秋石的幻影"},
		},
		tbUnLockEvent = 
		{
			--重新设置复活点
			{"SetDynamicRevivePoint", 6350, 6843},

			{"DoDeath", "gw"},
			{"DoDeath", "jy"},
			{"RaiseEvent", "AddMissionScore", 10},
		},
	},
	[16] = {nTime = 0, nNum = 1,	--轻功
		tbPrelock = {15},
		tbStartEvent = 
		{
			{"SetFubenProgress", -1,"繼續探索雪峰硝煙"},
			{"BlackMsg", "幻影沒有意識，只會將我們視為敵人！"},
			{"TrapUnlock", "jump1", 16},
			{"SetTargetPos", 7363, 6862},

			{"AddNpc", 19, 1, 0, "qg", "qinggong1", false, 0, 0, 0, 0},
			{"ChangeTrap", "jump1", nil, {6780, 6828, 2}},
			{"ChangeTrap", "jump1_1", nil, {6468, 6810, 2}},
		},
		tbUnLockEvent = 
		{
		},
	},
	[17] = {nTime = 0, nNum = 1,
		tbPrelock = {16},
		tbStartEvent = 
		{
			{"TrapUnlock", "trap7", 17},
			{"SetTargetPos", 5746, 6625},
		},
		tbUnLockEvent = 
		{
		},
	},	
	[18] = {nTime = 0, nNum = 12,
		tbPrelock = {17},
		tbStartEvent = 
		{
			{"ClearTargetPos"},
			--区域7
			{"AddNpc", 5, 2, 18, "jy", "guaiwu7_1", false, 0, 0.5, 9010, 0.5},
			{"AddNpc", 11, 10, 18, "gw", "guaiwu7_2", false, 0, 0.5, 9005, 0.5},

			{"BlackMsg", "看來這些人都是投奔金人的武林敗類了！"},
			{"NpcBubbleTalk", "jy", "各位不如和我們一起去吃香的喝辣的，哈哈！", 4, 2, 2},
		},
		tbUnLockEvent = 
		{
			{"RaiseEvent", "AddMissionScore", 6},
		},
	},
	[19] = {nTime = 0, nNum = 1,
		tbPrelock = {18},
		tbStartEvent = 
		{
			{"TrapUnlock", "trap8", 19},
			{"SetTargetPos", 3786, 5249},
		},
		tbUnLockEvent = 
		{
		},
	},	
	[20] = {nTime = 0, nNum = 12,
		tbPrelock = {19},
		tbStartEvent = 
		{
			{"ClearTargetPos"},
			--区域8
			{"AddNpc", 5, 2, 20, "jy", "guaiwu8_1", false, 0, 0.5, 9010, 0.5},
			{"AddNpc", 11, 10, 20, "gw", "guaiwu8_2", false, 0, 0.5, 9005, 0.5},

			{"BlackMsg", "這些武林敗類沒完沒了！"},
			{"NpcBubbleTalk", "jy", "不要敬酒不吃吃罰酒！", 4, 2, 1},
		},
		tbUnLockEvent = 
		{
			{"RaiseEvent", "AddMissionScore", 6},
		},
	},
	[21] = {nTime = 0, nNum = 1,	--轻功
		tbPrelock = {20},
		tbStartEvent = 
		{
			{"TrapUnlock", "jump2", 21},
			{"SetTargetPos", 2653, 4798},

			{"AddNpc", 19, 1, 0, "qg", "qinggong2", false, 0, 0, 0, 0},
			{"ChangeTrap", "jump2", nil, {1986, 5161, 2}},
			{"ChangeTrap", "jump2_1", nil, {2021, 5646, 2}},
			{"ChangeTrap", "jump2_2", nil, {2358, 6395, 2}},
		},
		tbUnLockEvent = 
		{
		},
	},
	[22] = {nTime = 0, nNum = 1,
		tbPrelock = {21},
		tbStartEvent = 
		{
			{"SetTargetPos", 2778, 7166},
			{"TrapUnlock", "trap9", 22},
		},
		tbUnLockEvent = 
		{

		},
	},	
	[23] = {nTime = 0, nNum = 1,			--boss3
		tbPrelock = {22},
		tbStartEvent = 
		{
			{"ClearTargetPos"},
			--区域9
			{"AddNpc", 17, 1, 23, "boss3", "boss3", false, 0, 0.5, 9011, 0.5},

			{"BlackMsg", "這是...五毒大師姐？小心應付！"},
			{"NpcBubbleTalk", "boss3", "中原武人欺我教太甚，今天別想逃！", 4, 2, 1},
			{"SetFubenProgress", -1,"擊敗古嫣然的幻影"},
		},
		tbUnLockEvent = 
		{
			{"DoDeath", "gw"},
			{"DoDeath", "jy"},

			{"AddSimpleNpc", 1610, 2845, 7562, 0},
			{"BlackMsg", "闖關成功！篝火已刷出，可持續獲得經驗！"},
			{"RaiseEvent", "AddMissionScore", 15},
			{"SetFubenProgress", -1,"闖關成功"},
			{"OpenWindow", "LingJueFengLayerPanel", "Win"},
			{"RaiseEvent", "KickOutAllPlayer", 70},
			{"GameWin"},
		},
	},


-----------------------------------boss血量解锁--------------------------------------
	[30] = {nTime = 1.5, nNum = 0,			--boss1
		tbPrelock = {9},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
		},
	},
	[31] = {nTime = 0, nNum = 1,			--boss1
		tbPrelock = {30},
		tbStartEvent = 
		{
			{"NpcHpUnlock", "boss1", 31, 85},
		},
		tbUnLockEvent = 
		{
			{"NpcBubbleTalk", "boss1", "哼...欺負我翠煙人少麼？！", 4, 0, 1},
			--{"BlackMsg", "帮手出现，小心应付！"},
			--召唤怪物
			{"AddNpc", 2, 2, 0, "jy", "guaiwu4_1", false, 0, 0.5, 9005, 0.5},
			{"AddNpc", 8, 10, 0, "gw", "guaiwu4_2", false, 0, 0.5, 9009, 0.5},
		},
	},
	[32] = {nTime = 0, nNum = 1,			--boss1
		tbPrelock = {20},
		tbStartEvent = 
		{
			{"NpcHpUnlock", "boss1", 32, 70},
		},
		tbUnLockEvent = 
		{
			{"NpcBubbleTalk", "boss1", "你們徹底激怒了我！", 4, 0, 1},
			--{"BlackMsg", "帮手出现，小心应付！"},
			--召唤怪物
			{"AddNpc", 2, 2, 0, "jy", "guaiwu4_1", false, 0, 0.5, 9005, 0.5},
			{"AddNpc", 8, 10, 0, "gw", "guaiwu4_2", false, 0, 0.5, 9009, 0.5},
		},
	},


	[33] = {nTime = 1.5, nNum = 0,			--boss2
		tbPrelock = {14},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
		},
	},
	[34] = {nTime = 0, nNum = 1,			--boss2
		tbPrelock = {33},
		tbStartEvent = 
		{
			{"NpcHpUnlock", "boss2", 34, 70},
		},
		tbUnLockEvent = 
		{
			{"NpcBubbleTalk", "boss2", "你們還有些本事！", 4, 0, 1},
			{"BlackMsg", "幫手出現，小心應付！"},
			--召唤怪物
			{"AddNpc", 4, 2, 0, "jy", "guaiwu6_1", false, 0, 0.5, 9005, 0.5},
			{"AddNpc", 10, 10, 0, "gw", "guaiwu6_2", false, 0, 0.5, 9009, 0.5},
			{"NpcBubbleTalk", "jy", "宋大俠，我們來幫你！", 4, 2, 2},
		},
	},

	[35] = {nTime = 1.5, nNum = 0,			--boss3
		tbPrelock = {22},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
		},
	},
	[36] = {nTime = 0, nNum = 1,			--boss3
		tbPrelock = {35},
		tbStartEvent = 
		{
			{"NpcHpUnlock", "boss3", 36, 85},
		},
		tbUnLockEvent = 
		{
			{"NpcBubbleTalk", "boss3", "我五毒門人也不少！", 4, 0, 1},
			{"BlackMsg", "幫手出現，小心應付！"},
			--召唤怪物
			{"AddNpc", 6, 2, 0, "jy", "guaiwu9_1", false, 0, 0.5, 9005, 0.5},
			{"AddNpc", 12, 10, 0, "gw", "guaiwu9_2", false, 0, 0.5, 9009, 0.5},
		},
	},
	[37] = {nTime = 0, nNum = 1,			--boss3
		tbPrelock = {36},
		tbStartEvent = 
		{
			{"NpcHpUnlock", "boss3", 37, 65},
		},
		tbUnLockEvent = 
		{
			{"NpcBubbleTalk", "boss3", "沒想到中你們武藝如此厲害！", 4, 0, 1},
			--{"BlackMsg", "帮手出现，小心应付！"},
			--召唤怪物
			{"AddNpc", 6, 2, 0, "jy", "guaiwu9_1", false, 0, 0.5, 9005, 0.5},
			{"AddNpc", 12, 10, 0, "gw", "guaiwu9_2", false, 0, 0.5, 9009, 0.5},
		},
	},
	[38] = {nTime = 0, nNum = 1,			--boss3
		tbPrelock = {37},
		tbStartEvent = 
		{
			{"NpcHpUnlock", "boss3", 38, 45},
		},
		tbUnLockEvent = 
		{
			{"NpcBubbleTalk", "boss3", "你們不要欺負奴家啊！", 4, 0, 1},
			{"BlackMsg", "幫手出現，小心應付！"},
			--召唤怪物
			{"AddNpc", 6, 2, 0, "jy", "guaiwu9_1", false, 0, 0.5, 9005, 0.5},
			{"AddNpc", 12, 10, 0, "gw", "guaiwu9_2", false, 0, 0.5, 9009, 0.5},
		},
	},

--------------------------------稀有锁开始-------------------------------------------
	[40] = {nTime = 0.5, nNum = 0,
		tbPrelock = {},
		tbStartEvent = 
		{
			{"BlackMsg", "好像有高手出現了！"},
			{"AddNpc", 18, 1, 0, "xy", "xiyou", false, 0, 0.5, 9011, 0.5},
		},
		tbUnLockEvent = 
		{
		},
	},
	[41] = {nTime = 2, nNum = 0,
		tbPrelock = {40},
		tbStartEvent = 
		{
			{"ClearTargetPos"},
			{"SetFubenProgress", -1,"擊敗石軒轅的幻影"},
		},
		tbUnLockEvent = 
		{
		},
	},
	[42] = {nTime = 0, nNum = 1,
		tbPrelock = {41},
		tbStartEvent = 
		{
			{"NpcHpUnlock", "xy", 42, 30},
			{"NpcBubbleTalk", "xy", "各位先別走，與叫花子過幾招再說！", 3, 1, 1},
			{"NpcBubbleTalk", "xy", "你們可知在這雪峰發生了什麼？", 3, 4, 1},
			{"NpcBubbleTalk", "xy", "我中原武林人士本在此處紮營準備偷襲金兵糧草部隊！", 3, 7, 1},
			{"NpcBubbleTalk", "xy", "誰能想到竟然有奸細出賣，在一個寒夜裡，我們被大批金軍包圍...", 3, 10, 1},
			{"NpcBubbleTalk", "xy", "這一次，我們死的兄弟很多，中原武林損失慘重啊，唉...", 3, 13, 1},
		},
		tbUnLockEvent = 
		{
		},
	},
	[43] = {nTime = 2, nNum = 0,
		tbPrelock = {42},
		tbStartEvent = 
		{
			{"SetNpcProtected", "xy", 1},
			{"ChangeNpcFightState", "xy", 0, 0},
			{"SetAiActive", "xy", 0},
			{"SetNpcBloodVisable", "xy", false, 0},

			{"NpcBubbleTalk", "xy", "打了一架，我冷靜了很多，你們走吧！", 4, 0, 1},

			{"RaiseEvent", "DropAward", "Setting/Npc/DropFile/TeamFuben/120fb_xiyou.tab", 4466, 3263},
		},
		tbUnLockEvent = 
		{
			{"BlackMsg", "丐幫大弟子果然武藝非凡！"},
			{"SetFubenProgress", -1,"繼續探索雪峰硝煙"},
			{"SetTargetPos", 6354, 2705},
		},
	},

}