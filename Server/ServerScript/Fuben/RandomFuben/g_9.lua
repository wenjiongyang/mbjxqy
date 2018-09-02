
local tbFubenSetting = Fuben.RandomFuben:GetRandomFubenSetting("g_9");

tbFubenSetting.tbMultiBeginPoint = {{8430, 6669},{8430, 6400},{8628, 6649},{8633, 6405}}  
tbFubenSetting.tbTempRevivePoint = {8633, 6405};
tbFubenSetting.nStartDir		 = 48;


tbFubenSetting.NPC = 
{
	[1] = {nTemplate = 2062, nLevel = -1, nSeries = -1}, --快刀客
	[2] = {nTemplate = 2505, nLevel = -1, nSeries = -1}, --中原一点红
	[3] = {nTemplate = 2428, nLevel = -1, nSeries = -1}, --中原二点红
	[4] = {nTemplate = 2429, nLevel = -1, nSeries = -1}, --中原三点红
	[5] = {nTemplate = 2430, nLevel = -1, nSeries = -1}, --中原四点红
	[6] = {nTemplate = 2426, nLevel = -1, nSeries = 0}, --玩家方技能npc
	[7] = {nTemplate = 2427, nLevel = -1, nSeries = 0}, --怪物方技能npc
	[8] = {nTemplate = 2437, nLevel = -1, nSeries = 0}, --自爆蝎子
	[9] = {nTemplate = 2438, nLevel = -1, nSeries = 0}, --指引圈

	[10] = {nTemplate = 2065, nLevel = -1, nSeries = -1}, --稀有-玄天道人
	[11] = {nTemplate = 2494, nLevel = -1, nSeries = 0}, --机关

	
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
			--{"ChangeCameraSetting", 30, 35, 20},

			{"OpenWindow", "LingJueFengLayerPanel", "Info",3, 9, "第七層 詭異廢莊"},
		},
	},
	[2] = {nTime = 10, nNum = 0,
		tbPrelock = {1},
		tbStartEvent = 
		{
			{"SetFubenProgress", -1,"等待秘境開啟"},
			{"AddNpc", 100, 2, 0, "wall1", "wall1",false, 32},
			--{"AddNpc", 100, 2, 0, "wall2", "wall2",false, 48},
		},
		tbUnLockEvent = 
		{
			{"RaiseEvent", "Start"},
			{"BlackMsg", "一個廢棄的山莊，空氣中有濃厚的怨氣在流動。"},
			--{"ShowTaskDialog", 10004, false},
		    {"DoDeath", "wall1"},
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
			{"SetTargetPos", 6877, 8667},
			{"SetFubenProgress", 0, "探索凌絕峰"},
		},
		tbUnLockEvent = 
		{
			{"BlackMsg", "此處似乎有武林中人出沒"},
			{"SetFubenProgress", 20, "擊敗大頭領"},
			{"ClearTargetPos"},
			{"AddNpc", 2, 1, 40, "sl", "shouling1", false, 0, 0, 9010, 0},
			{"NpcBubbleTalk", "sl", "來者何人？膽敢闖到此處，活得不耐煩啦！", 4, 3, 1},
			{"NpcHpUnlock", "sl", 5, 80},
		},
	},
	[5] = {nTime = 0, nNum = 1,
		tbPrelock = {4},
		tbStartEvent = 
		{
			
		},
		tbUnLockEvent = 
		{	
			{"AddNpc", 7, 12, 0, "skill", "skillnpc1", false, 0, 0, 0, 0},
			{"AddNpc", 7, 1, 0, "skill", "[NpcGroup=sl]", false, 0, 0, 0, 0},
			{"BlackMsg", "小心！中原一點紅在[FFFE0D]回血陣[-]內會持續回復血量！"},
			
			{"NpcHpUnlock", "sl", 6, 40},
		},
	},
	[6] = {nTime = 0, nNum = 1,
		tbPrelock = {5},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"BlackMsg", "小心！[FFFE0D]回血陣[-]位置改變了！"},
			{"DelNpc", "skill"},
			{"AddNpc", 7, 12, 0, "skill", "skillnpc1", false, 0, 0, 0, 0},
			{"AddNpc", 7, 1, 0, "skill", "[NpcGroup=sl]", false, 0, 0, 0, 0},
			{"NpcHpUnlock", "sl", 21, 20},
		},
	},
	[21] = {nTime = 0, nNum = 1,
		tbPrelock = {6},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"CastSkill", "sl", 2351, 1, -1, -1},
		},
	},
	[40] = {nTime = 0, nNum = 1,
		tbPrelock = {4},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"DelNpc", "skill"},
			{"SetTargetPos", 6318, 5076},
			{"SetFubenProgress", 40, "擊敗二頭領"},
		},
	},
	[7] = {nTime = 0, nNum = 1,
		tbPrelock = {40},
		tbStartEvent = 
		{
			{"TrapUnlock", "trap2", 7},
		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},
			{"AddNpc", 3, 1, 41, "sl", "shouling2", false, 0, 0, 9010, 0},
			{"NpcBubbleTalk", "sl", "你們居然殺了我大哥？我要報仇！", 4, 1, 1},
			{"NpcHpUnlock", "sl", 8, 80},
		},
	},
	[8] = {nTime = 0, nNum = 1,
		tbPrelock = {7},
		tbStartEvent = 
		{
			
		},
		tbUnLockEvent = 
		{
			{"BlackMsg", "尋找並打開[FFFE0D]機關[-]召喚雷電！"},
			{"AddNpc", 11, 1, 23, "jg1", "jiguan1", false, 0, 0, 0, 0},
			{"NpcHpUnlock", "sl", 9, 40},
		},
	},
	[22] = {nTime = 2, nNum = 0,
		tbPrelock = {8},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"NpcAddBuff", "sl", 1503, 5, 100},
		},
	},
	[23] = {nTime = 0, nNum = 1,
		tbPrelock = {8},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"AddNpc", 6, 4, 0, "skill", "skillnpc2", false, 0, 0, 0, 0},
			{"AddNpc", 6, 1, 0, "skill", "[NpcGroup=sl]", false, 0, 0, 0, 0},
		},
	},
	[32] = {nTime = 0.5, nNum = 0,
		tbPrelock = {23},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"CastSkill", "skill", 3713, 1, -1, -1},
			{"CastSkillCycle", "cycle3", "skill", 5, 3713, 1, -1, -1},
		},
	},
	[9] = {nTime = 0, nNum = 1,
		tbPrelock = {8},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"BlackMsg", "糟了！雷電停了！快去重新開啟[FFFE0D]機關[-]！"},
			{"DelNpc", "jg1"},
			{"CloseCycle", "cycle3"},
			{"DelNpc", "skill"},
			{"AddNpc", 11, 1, 24, "jg2", "jiguan2", false, 0, 0, 0, 0},
			{"NpcHpUnlock", "sl", 25, 20},
			{"NpcRemoveBuff", "sl", 1503},
		},
	},
	[27] = {nTime = 4, nNum = 0,
		tbPrelock = {9},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"NpcAddBuff", "sl", 1503, 5, 100},
		},
	},
	
	[24] = {nTime = 0, nNum = 1,
		tbPrelock = {9},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"AddNpc", 6, 4, 0, "skill", "skillnpc2", false, 0, 0, 0, 0},
			{"AddNpc", 6, 1, 0, "skill", "[NpcGroup=sl]", false, 0, 0, 0, 0},
		},
	},
	[28] = {nTime = 0.5, nNum = 0,
		tbPrelock = {24},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"CastSkill", "skill", 3713, 1, -1, -1},
			{"CastSkillCycle", "cycle4", "skill", 5, 3713, 1, -1, -1},
		},
	},
	[25] = {nTime = 0, nNum = 1,
		tbPrelock = {9},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"CastSkill", "sl", 2351, 1, -1, -1},
		},
	},
	[41] = {nTime = 0, nNum = 1,
		tbPrelock = {7},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"CloseCycle", "cycle4"},
			{"DelNpc", "skill"},
			{"SetTargetPos", 3439, 5140},
			{"SetFubenProgress", 60, "擊敗三頭領"},
		},
	},
	[10] = {nTime = 0, nNum = 1,
		tbPrelock = {41},
		tbStartEvent = 
		{
			{"TrapUnlock", "trap3", 10},
		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},
			{"AddNpc", 4, 1, 42, "sl", "shouling3", false, 0, 0, 9010, 0},
			{"NpcBubbleTalk", "sl", "你們居然殺了我大哥二哥？我要報仇！", 4, 1, 1},
			{"NpcHpUnlock", "sl", 11, 80},
		},
	},
	[11] = {nTime = 0, nNum = 1,
		tbPrelock = {10},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"NpcBubbleTalk", "sl", "來嘗嘗這個的滋味！", 4, 1, 1},
			{"AddNpc", 8, 1, 51, "xiezi", "xiezi1", false, 0, 0, 9008, 0.5},
			{"AddNpc", 8, 1, 52, "xiezi", "xiezi2", false, 0, 0, 9008, 0.5},
			{"AddNpc", 8, 1, 53, "xiezi", "xiezi3", false, 0, 0, 9008, 0.5},
			{"AddNpc", 8, 1, 54, "xiezi", "xiezi4", false, 0, 0, 9008, 0.5},
		},
	},
	[42] = {nTime = 0, nNum = 1,
		tbPrelock = {10},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"DelNpc", "xiezi"},
			{"SetTargetPos", 3437, 8466},
			{"SetFubenProgress", 80, "擊敗四頭領"},
		},
	},
	[12] = {nTime = 0, nNum = 1,
		tbPrelock = {42},
		tbStartEvent = 
		{
			{"TrapUnlock", "trap4", 12},
		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},
			{"AddNpc", 5, 1, 20, "sl", "shouling4", false, 0, 0, 9010, 0},
			{"NpcBubbleTalk", "sl", "你們居然殺了我大哥二哥三哥四哥？哦不對，我是老四。我要報仇！！", 4, 1, 1},
			{"NpcHpUnlock", "sl", 13, 80},
		},
	},
	[13] = {nTime = 0, nNum = 1,
		tbPrelock = {12},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"NpcBubbleTalk", "sl", "他們都說我傻，其實我一點都不傻，看我的！回來吧哥哥們！！", 4, 1, 1},
			{"NpcAddBuff", "sl", 1509, 1, 20},
			{"AddNpc", 9, 1, 0, "Circle_1", "chongsheng1", false, 0, 0, 0, 0},
			{"AddNpc", 9, 1, 0, "Circle_2", "chongsheng2", false, 0, 0, 0, 0},
			{"AddNpc", 9, 1, 0, "Circle_3", "chongsheng3", false, 0, 0, 0, 0},
			{"NpcFindEnemyUnlock", "Circle_1", 14, 0},
			{"NpcFindEnemyUnlock", "Circle_2", 15, 0},
			{"NpcFindEnemyUnlock", "Circle_3", 16, 0},
			--稀有锁
			{"Random", {350000, 30}},
		},
	},
	[14] = {nTime = 0, nNum = 1,
		tbPrelock = {13},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"DelNpc", "Circle_1"},
			{"CloseLock", 17},
		},
	},
	[15] = {nTime = 0, nNum = 1,
		tbPrelock = {13},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"DelNpc", "Circle_2"},
			{"CloseLock", 18},
		},
	},
	[16] = {nTime = 0, nNum = 1,
		tbPrelock = {13},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"DelNpc", "Circle_3"},
			{"CloseLock", 19},
		},
	},
	[17] = {nTime = 6, nNum = 0,
		tbPrelock = {13},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"AddNpc", 2, 1, 0, "sl1", "[NpcGroup=Circle_1]", false, 0, 0, 9010, 0.5},
			{"NpcAddBuff", "sl1", 1508, 1, 100},
			{"DelNpc", "Circle_1"},
		},
	},
	[18] = {nTime = 6, nNum = 0,
		tbPrelock = {13},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"AddNpc", 3, 1, 0, "sl2", "[NpcGroup=Circle_2]", false, 0, 0, 9010, 0.5},
			{"NpcAddBuff", "sl2", 1508, 1, 100},
			{"DelNpc", "Circle_2"},
		},
	},
	[19] = {nTime = 6, nNum = 0,
		tbPrelock = {13},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"AddNpc", 4, 1, 0, "sl3", "[NpcGroup=Circle_3]", false, 0, 0, 9010, 0.5},
			{"NpcAddBuff", "sl3", 1508, 1, 100},
			{"DelNpc", "Circle_3"},
		},
	},
------------------------胜利判定----------------------
	[20] = {nTime = 0, nNum = 1,
		tbPrelock = {12},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			--掉落房间奖励
			{"RaiseEvent", "DropAward", "Setting/Fuben/RandomFuben/HouseAward/G.tab", 3780, 8735},
			{"RaiseEvent", "DropAward", "Setting/Fuben/RandomFuben/HouseAward/G.tab", 3780, 8935},
			{"RaiseEvent", "DropAward", "Setting/Fuben/RandomFuben/HouseAward/G.tab", 3980, 8735},
			{"RaiseEvent", "DropAward", "Setting/Fuben/RandomFuben/HouseAward/G.tab", 3980, 8935},
			--判断模式篝火&踢出
			{"IfCase", "self.nFubenLevel == 3",
				{"AddSimpleNpc", 1611, 3880, 8835, 0},
				{"RaiseEvent", "KickOutAllPlayer", 40},
			},
			--判断模式获得积分
			{"RaiseEvent", "AddMissionScore", "g_score_win"},

			{"SetFubenProgress", 100, "擊敗所有敵人"},
			{"OpenWindow", "LingJueFengLayerPanel", "Win"},
			{"GameWin"},
		},
	},


----------------稀有锁-------------------------------
	[30] = {nTime = 0, nNum = 1,
		tbPrelock = {},
		tbStartEvent = 
		{
			{"BlackMsg", "一位老者忽然出現，氣宇軒昂！"},
			{"AddNpc", 10, 1, 0, "xy", "chongsheng1", false, 8, 0, 0, 0},
			{"UnLock", 14},
			{"NpcBubbleTalk", "xy", "我來幫你們壓住這個法陣！", 4, 0, 1},
			{"NpcBubbleTalk", "sl", "又是你這個牛鼻子來壞我的好事！", 4, 3, 1},
			{"NpcBubbleTalk", "xy", "懲奸除惡，我輩本分！", 4, 6, 1},
			{"UnLock", 30},

		},
		tbUnLockEvent = 
		{	
		},
	},
	[31] = {nTime = 15, nNum = 0,
		tbPrelock = {30},
		tbStartEvent = 
		{	
		},
		tbUnLockEvent = 
		{
		--稀有掉落
			{"BlackMsg", "玄天道人給大家留下一些寶物後離開了。"},
			{"RaiseEvent", "DropAward", "Setting/Npc/DropFile/RandomFuben/House_G/xy_xuantiandaoren.tab", 3493, 8462},
			{"RaiseEvent", "DropAward", "Setting/Npc/DropFile/RandomFuben/House_G/xy_xuantiandaoren.tab", 3493, 8662},
			{"RaiseEvent", "DropAward", "Setting/Npc/DropFile/RandomFuben/House_G/xy_xuantiandaoren.tab", 3693, 8462},
			{"RaiseEvent", "DropAward", "Setting/Npc/DropFile/RandomFuben/House_G/xy_xuantiandaoren.tab", 3693, 8662},
			--卡片收集
			{"RaiseEvent", "CheckCollectionAct", 
				{"IfCase", "MathRandom(100) <= 30", 
					{"AddSimpleNpc", 2066, 3593, 8562, 0}
				}
			},
			{"DelNpc", "xy"},
		},
	},



-----------------------蝎子重生部分--------------------------
	[51] = {nTime = 0, nNum = 1,
		tbPrelock = {11},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"AddNpc", 8, 1, 55, "xiezi", "xiezi1", false, 0, 0, 9008, 0.5},
		},
	},
	[52] = {nTime = 0, nNum = 1,
		tbPrelock = {11},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"AddNpc", 8, 1, 56, "xiezi", "xiezi2", false, 0, 0, 9008, 0.5},
		},
	},
	[53] = {nTime = 0, nNum = 1,
		tbPrelock = {11},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"AddNpc", 8, 1, 57, "xiezi", "xiezi3", false, 0, 0, 9008, 0.5},
		},
	},
	[54] = {nTime = 0, nNum = 1,
		tbPrelock = {11},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"AddNpc", 8, 1, 58, "xiezi", "xiezi4", false, 0, 0, 9008, 0.5},
		},
	},
	[55] = {nTime = 0, nNum = 1,
		tbPrelock = {51},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"AddNpc", 8, 1, 61, "xiezi", "xiezi1", false, 0, 0, 9008, 0.5},
		},
	},
	[56] = {nTime = 0, nNum = 1,
		tbPrelock = {52},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"AddNpc", 8, 1, 62, "xiezi", "xiezi2", false, 0, 0, 9008, 0.5},
		},
	},
	[57] = {nTime = 0, nNum = 1,
		tbPrelock = {53},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"AddNpc", 8, 1, 63, "xiezi", "xiezi3", false, 0, 0, 9008, 0.5},
		},
	},
	[58] = {nTime = 0, nNum = 1,
		tbPrelock = {54},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"AddNpc", 8, 1, 64, "xiezi", "xiezi4", false, 0, 0, 9008, 0.5},
		},
	},
	[61] = {nTime = 0, nNum = 1,
		tbPrelock = {55},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"AddNpc", 8, 1, 65, "xiezi", "xiezi1", false, 0, 0, 9008, 0.5},
		},
	},
	[62] = {nTime = 0, nNum = 1,
		tbPrelock = {56},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"AddNpc", 8, 1, 66, "xiezi", "xiezi2", false, 0, 0, 9008, 0.5},
		},
	},
	[63] = {nTime = 0, nNum = 1,
		tbPrelock = {57},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"AddNpc", 8, 1, 67, "xiezi", "xiezi3", false, 0, 0, 9008, 0.5},
		},
	},
	[64] = {nTime = 0, nNum = 1,
		tbPrelock = {58},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"AddNpc", 8, 1, 68, "xiezi", "xiezi4", false, 0, 0, 9008, 0.5},
		},
	},
	[65] = {nTime = 0, nNum = 1,
		tbPrelock = {61},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"AddNpc", 8, 1, 71, "xiezi", "xiezi1", false, 0, 0, 9008, 0.5},
		},
	},
	[66] = {nTime = 0, nNum = 1,
		tbPrelock = {62},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"AddNpc", 8, 1, 72, "xiezi", "xiezi2", false, 0, 0, 9008, 0.5},
		},
	},
	[67] = {nTime = 0, nNum = 1,
		tbPrelock = {63},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"AddNpc", 8, 1, 73, "xiezi", "xiezi3", false, 0, 0, 9008, 0.5},
		},
	},
	[68] = {nTime = 0, nNum = 1,
		tbPrelock = {64},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"AddNpc", 8, 1, 74, "xiezi", "xiezi4", false, 0, 0, 9008, 0.5},
		},
	},
	[71] = {nTime = 0, nNum = 1,
		tbPrelock = {65},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"AddNpc", 8, 1, 75, "xiezi", "xiezi1", false, 0, 0, 9008, 0.5},
		},
	},
	[72] = {nTime = 0, nNum = 1,
		tbPrelock = {66},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"AddNpc", 8, 1, 76, "xiezi", "xiezi2", false, 0, 0, 9008, 0.5},
		},
	},
	[73] = {nTime = 0, nNum = 1,
		tbPrelock = {67},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"AddNpc", 8, 1, 77, "xiezi", "xiezi3", false, 0, 0, 9008, 0.5},
		},
	},
	[74] = {nTime = 0, nNum = 1,
		tbPrelock = {68},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"AddNpc", 8, 1, 78, "xiezi", "xiezi4", false, 0, 0, 9008, 0.5},
		},
	},
	[75] = {nTime = 0, nNum = 1,
		tbPrelock = {71},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"AddNpc", 8, 1, 81, "xiezi", "xiezi1", false, 0, 0, 9008, 0.5},
		},
	},
	[76] = {nTime = 0, nNum = 1,
		tbPrelock = {72},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"AddNpc", 8, 1, 82, "xiezi", "xiezi2", false, 0, 0, 9008, 0.5},
		},
	},
	[77] = {nTime = 0, nNum = 1,
		tbPrelock = {73},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"AddNpc", 8, 1, 83, "xiezi", "xiezi3", false, 0, 0, 9008, 0.5},
		},
	},
	[78] = {nTime = 0, nNum = 1,
		tbPrelock = {74},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"AddNpc", 8, 1, 84, "xiezi", "xiezi4", false, 0, 0, 9008, 0.5},
		},
	},
	[81] = {nTime = 0, nNum = 1,
		tbPrelock = {75},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"AddNpc", 8, 1, 85, "xiezi", "xiezi1", false, 0, 0, 9008, 0.5},
		},
	},
	[82] = {nTime = 0, nNum = 1,
		tbPrelock = {76},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"AddNpc", 8, 1, 86, "xiezi", "xiezi2", false, 0, 0, 9008, 0.5},
		},
	},
	[83] = {nTime = 0, nNum = 1,
		tbPrelock = {77},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"AddNpc", 8, 1, 87, "xiezi", "xiezi3", false, 0, 0, 9008, 0.5},
		},
	},
	[84] = {nTime = 0, nNum = 1,
		tbPrelock = {78},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"AddNpc", 8, 1, 88, "xiezi", "xiezi4", false, 0, 0, 9008, 0.5},
		},
	},
	[85] = {nTime = 0, nNum = 1,
		tbPrelock = {81},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"AddNpc", 8, 1, 91, "xiezi", "xiezi1", false, 0, 0, 9008, 0.5},
		},
	},
	[86] = {nTime = 0, nNum = 1,
		tbPrelock = {82},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"AddNpc", 8, 1, 92, "xiezi", "xiezi2", false, 0, 0, 9008, 0.5},
		},
	},
	[87] = {nTime = 0, nNum = 1,
		tbPrelock = {83},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"AddNpc", 8, 1, 93, "xiezi", "xiezi3", false, 0, 0, 9008, 0.5},
		},
	},
	[88] = {nTime = 0, nNum = 1,
		tbPrelock = {84},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"AddNpc", 8, 1, 94, "xiezi", "xiezi4", false, 0, 0, 9008, 0.5},
		},
	},
	[91] = {nTime = 0, nNum = 1,
		tbPrelock = {85},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"AddNpc", 8, 1, 95, "xiezi", "xiezi1", false, 0, 0, 9008, 0.5},
		},
	},
	[92] = {nTime = 0, nNum = 1,
		tbPrelock = {86},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"AddNpc", 8, 1, 96, "xiezi", "xiezi2", false, 0, 0, 9008, 0.5},
		},
	},
	[93] = {nTime = 0, nNum = 1,
		tbPrelock = {87},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"AddNpc", 8, 1, 97, "xiezi", "xiezi3", false, 0, 0, 9008, 0.5},
		},
	},
	[94] = {nTime = 0, nNum = 1,
		tbPrelock = {88},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"AddNpc", 8, 1, 98, "xiezi", "xiezi4", false, 0, 0, 9008, 0.5},
		},
	},
	[95] = {nTime = 0, nNum = 1,
		tbPrelock = {91},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"AddNpc", 8, 1, 0, "xiezi", "xiezi1", false, 0, 0, 9008, 0.5},
		},
	},
	[96] = {nTime = 0, nNum = 1,
		tbPrelock = {92},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"AddNpc", 8, 1, 0, "xiezi", "xiezi2", false, 0, 0, 9008, 0.5},
		},
	},
	[97] = {nTime = 0, nNum = 1,
		tbPrelock = {93},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"AddNpc", 8, 1, 0, "xiezi", "xiezi3", false, 0, 0, 9008, 0.5},
		},
	},
	[98] = {nTime = 0, nNum = 1,
		tbPrelock = {94},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"AddNpc", 8, 1, 0, "xiezi", "xiezi4", false, 0, 0, 9008, 0.5},
		},
	},
}