
local tbFubenSetting = Fuben.RandomFuben:GetRandomFubenSetting("g_10");

tbFubenSetting.tbMultiBeginPoint = {{1713, 6714},{1723, 6489},{1476, 6674},{1491, 6453}}  
tbFubenSetting.tbTempRevivePoint = {1476, 6674};
tbFubenSetting.nStartDir		 = 16;


tbFubenSetting.NPC = 
{
	[1] = {nTemplate = 2057, nLevel = -1, nSeries = -1}, --普通精英
	[2] = {nTemplate = 2058, nLevel = -1, nSeries = -1}, --怪物
	[3] = {nTemplate = 2059, nLevel = -1, nSeries = -1}, --机关
	[4] = {nTemplate = 2060, nLevel = -1, nSeries = -1}, --首领

	[5] = {nTemplate = 2065, nLevel = -1, nSeries = -1}, --稀有-玄天道人

	--[99] = {nTemplate = 74,   nLevel = -1, nSeries = 0}, -- 上升气流
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
			{"SetNearbyRange", 2},
			--{"ChangeCameraSetting", 30, 35, 20},

			{"OpenWindow", "LingJueFengLayerPanel", "Info",3, 9, "第七層 噩運神社"},
		},
	},
	[2] = {nTime = 10, nNum = 0,
		tbPrelock = {1},
		tbStartEvent = 
		{
			{"SetFubenProgress", -1,"等待秘境開啟"},
			{"AddNpc", 100, 2, 0, "wall1", "wall1",false, 32},
		},
		tbUnLockEvent = 
		{
			{"RaiseEvent", "Start"},
			{"BlackMsg", "冰冷的風雪中似乎有隱約的禪音..."},
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
			--{"SetTargetPos", 1449, 5816},
			{"SetFubenProgress", 0, "探索凌絕峰"},
		},
		tbUnLockEvent = 
		{
			{"BlackMsg", "看來這些機關衛士在守衛周圍的區域！"},
			{"SetFubenProgress", 10, "擊敗所有敵人"},
		},
	},
	[5] = {nTime = 0, nNum = 4,
		tbPrelock = {2},
		tbStartEvent = 
		{
			{"AddNpc", 1, 4, 5, "jy", "jingying1", false, 0, 0, 9010, 0.5},
			{"AddNpc", 2, 32, 0, "gw", "guaiwu1", false, 0, 0, 9005, 0.5},

			{"AddNpc", 3, 1, 0, "jg1", "jiguan1", false, 0, 0, 0, 0},
			{"ChangeNpcAi", "jg1", "Move", "path1", 0, 1, 1, 0, 1},
			{"NpcAddBuff", "jg1", 1884, 1, 150},

			{"AddNpc", 3, 1, 0, "jg2", "jiguan2", false, 0, 0, 0, 0},
			{"ChangeNpcAi", "jg2", "Move", "path2", 0, 1, 1, 0, 1},
			{"NpcAddBuff", "jg2", 1884, 1, 150},
		},
		tbUnLockEvent = 
		{
			{"DoDeath", "jg1"},
			{"DoDeath", "jg2"},
			{"DoDeath", "gw"},
		},
	},
	[6] = {nTime = 0, nNum = 1,
		tbPrelock = {5},
		tbStartEvent = 
		{
			{"BlackMsg", "機關衛士已消失，可以離開了！"},
			{"SetFubenProgress", 60, "離開此處"},
			{"TrapUnlock", "trap2", 6},
			{"SetTargetPos", 7242, 6593},
		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},

			--稀有几率
			{"Random", {350000, 100}},
		},
	},
	[7] = {nTime = 0, nNum = 1,
		tbPrelock = {6},
		tbStartEvent = 
		{
			{"SetFubenProgress", 75, "擊敗武林高手"},
			{"BlackMsg", "擊敗忽然出現攔住去路的武林高手"},
			{"AddNpc", 4, 1, 7, "sl", "shouling1", false, 0, 0, 9010, 0.5},
			{"AddNpc", 2, 8, 0, "gw", "guaiwu2", false, 0, 0, 9005, 0.5},
			{"NpcBubbleTalk", "sl", "想跑？沒那麼容易。", 4, 1, 1},
		},
		tbUnLockEvent = 
		{
		},
	},
	[8] = {nTime = 0.1, nNum = 0,
		tbPrelock = {7},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			--掉落房间奖励
			{"RaiseEvent", "DropAward", "Setting/Fuben/RandomFuben/HouseAward/G.tab", 7541, 6551},
			{"RaiseEvent", "DropAward", "Setting/Fuben/RandomFuben/HouseAward/G.tab", 7541, 6751},
			{"RaiseEvent", "DropAward", "Setting/Fuben/RandomFuben/HouseAward/G.tab", 7741, 6551},
			{"RaiseEvent", "DropAward", "Setting/Fuben/RandomFuben/HouseAward/G.tab", 7741, 6751},
			--判断模式篝火&踢出
			{"IfCase", "self.nFubenLevel == 3",
				{"AddSimpleNpc", 1611, 7641, 6651, 0},
				{"RaiseEvent", "KickOutAllPlayer", 40},
			},
			--判断模式获得积分
			{"RaiseEvent", "AddMissionScore", "g_score_win"},

			{"SetFubenProgress", 100, "擊敗武林高手"},
			{"OpenWindow", "LingJueFengLayerPanel", "Win"},
			{"GameWin"},
		},
	},
	------------------稀有npc--------------
	[100] = {nTime = 0, nNum = 1,
		tbPrelock = {},
		tbStartEvent = 
		{
			{"AddNpc", 5, 1, 0, "xy", "xiyou", false, 0, 0, 0, 0},
			{"SetNpcProtected", "xy", 1},
			{"ChangeNpcAi", "xy", "Move", "path3", 100, 0, 0, 0, 0},
		},
		tbUnLockEvent = 
		{
			{"BlackMsg", "遠處走來一個人，氣勢非凡的樣子！"},
			{"NpcBubbleTalk", "sl", "原來是傳說中的玄天道人，閣下該不會...", 4, 1, 1},
			{"NpcBubbleTalk", "xy", "老夫已很久不與人動手了，今日只是碰巧路過，來瞧個熱鬧！", 4, 3, 1},
			{"NpcBubbleTalk", "sl", "老爺子果然有世外高人風範，在下佩服！", 4, 6, 1},
			{"NpcBubbleTalk", "xy", "好說好說...小友們，好好打！打贏了老夫有獎，哈哈哈！", 4, 9, 1},
		},
	},
	[101] = {nTime = 0.1, nNum = 0,
		tbPrelock = {100, 7},
		tbStartEvent = 
		{
			--稀有掉落
			{"BlackMsg", "老爺子給大家留下一些寶物後離開了。"},
			{"RaiseEvent", "DropAward", "Setting/Npc/DropFile/RandomFuben/House_G/xy_xuantiandaoren.tab", 6887, 6842},
			{"RaiseEvent", "DropAward", "Setting/Npc/DropFile/RandomFuben/House_G/xy_xuantiandaoren.tab", 6887, 7042},
			{"RaiseEvent", "DropAward", "Setting/Npc/DropFile/RandomFuben/House_G/xy_xuantiandaoren.tab", 7087, 6842},
			{"RaiseEvent", "DropAward", "Setting/Npc/DropFile/RandomFuben/House_G/xy_xuantiandaoren.tab", 7087, 7042},
			--卡片收集
			{"RaiseEvent", "CheckCollectionAct", 
				{"IfCase", "MathRandom(100) <= 30", 
					{"AddSimpleNpc", 2066, 6987, 6942, 0}
				}
			},
		},
		tbUnLockEvent = 
		{
		},
	},

}

