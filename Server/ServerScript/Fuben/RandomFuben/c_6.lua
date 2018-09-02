
local tbFubenSetting = Fuben.RandomFuben:GetRandomFubenSetting("c_6");

tbFubenSetting.tbMultiBeginPoint = {{1823, 1001},{2151, 849},{1655, 722},{2018, 546}}	-- 副本出生点
tbFubenSetting.tbTempRevivePoint = {1929, 768}
tbFubenSetting.nStartDir		 = 8;


--NPC模版ID，NPC等级，NPC五行；
tbFubenSetting.NPC = 
{
	[1] = {nTemplate = 1326, nLevel = -1, nSeries = -1},  --猛虎
	[2] = {nTemplate = 1327, nLevel = -1, nSeries = -1},  --猛虎·精英
	[3] = {nTemplate = 1328, nLevel = -1, nSeries = -1},  --火狐
	[4] = {nTemplate = 1329, nLevel = -1, nSeries = -1},  --火狐·精英
	[5] = {nTemplate = 1330, nLevel = -1, nSeries = -1},  --蝎子
	[6] = {nTemplate = 1331, nLevel = -1, nSeries = -1},  --蝎子·精英
	[7] = {nTemplate = 1332, nLevel = -1, nSeries = 0},  --赵无双
	[8] = {nTemplate = 1333, nLevel = -1, nSeries = 0},  --篝火
	[9] = {nTemplate = 104,  nLevel = -1, nSeries = 0},  --墙
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
			{"SetFubenProgress", -1,"等待秘境開啟"},
			{"AddNpc", 9, 2, 1, "wall", "wall_1_1",false, 16},
			{"OpenWindow", "LingJueFengLayerPanel", "Info",3, 9, "第三層 山腰小路"},
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
			{"ShowTaskDialog", 10002, false},
			{"DoDeath", "wall"},
			{"OpenDynamicObstacle", "ops1"},
		},
	},
	[3] = {nTime = 0, nNum = 1,
		tbPrelock = {2},
		tbStartEvent = 
		{			
			{"TrapUnlock", "TrapLock1", 3},
			{"SetFubenProgress", 0, "探索凌絕峰"},
			{"SetTargetPos", 3055, 3413},

			--赵无双
			{"AddNpc", 7, 1, 0, "Npc", "RandomFuben3_6_zhaowushuang",false, 39, 0, 0, 0},

			-- --篝火
			-- {"AddNpc", 8, 2, 0, "Gouhuo", "RandomFuben3_6_gouhuo",false, 0, 0, 0, 0},
		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},
			{"BlackMsg", "前方似乎有人歇腳，前去看看！"},
			{"SetFubenProgress", 20, "前往小屋"},
			{"NpcBubbleTalk", "Npc", "沒想到會在這山腰處遇到人！你們也是來凌絕峰探險的嗎？", 4, 1, 1},	
		},
	},
	[4] = {nTime = 4, nNum = 0,
		tbPrelock = {3},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"NpcBubbleTalk", "Npc", "糟糕，遇到猛獸群了！", 4, 1, 1},	
			{"SetFubenProgress", 40, "抵禦猛獸"},

			--猛虎
			{"AddNpc", 1, 5, 6, "guaiwu", "RandomFuben3_6_1",false, 0, 0, 9005, 0.5},
			{"AddNpc", 2, 1, 6, "guaiwu", "RandomFuben3_6_2",false, 0, 1, 9011, 1},
		},
	},
	[5] = {nTime = 3, nNum = 0,
		tbPrelock = {4},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"BlackMsg", "優先擊殺精英怪物！"},
			{"NpcBubbleTalk", "Npc", "精英怪物會加強其他野獸的攻擊，要優先擊殺！", 4, 1, 1},
		},
	},
	[6] = {nTime = 0, nNum = 6,
		tbPrelock = {4},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"SetFubenProgress", 60, "擊退火狐"},
			{"BlackMsg", "有更多的野獸衝過來了！"},

			--火狐
			{"AddNpc", 3, 5, 8, "guaiwu", "RandomFuben3_6_1",false, 0, 0, 9005, 0.5},
			{"AddNpc", 4, 1, 8, "guaiwu", "RandomFuben3_6_2",false, 0, 1, 9011, 1},	
		},
	},	
	[7] = {nTime = 3, nNum = 0,
		tbPrelock = {6},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"BlackMsg", "優先擊殺精英怪物！"},
			{"NpcBubbleTalk", "Npc", "精英怪物會恢復其他野獸的血量，要優先擊殺！", 4, 1, 1},
		},
	},

	[8] = {nTime = 0, nNum = 6,
		tbPrelock = {6},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"SetFubenProgress", 80, "擊退蠍子"},
			{"BlackMsg", "有更多的野獸衝過來了！"},

			--蝎子
			{"AddNpc", 5, 5, 10, "guaiwu", "RandomFuben3_6_1",false, 0, 0, 9005, 0.5},
			{"AddNpc", 6, 1, 10, "guaiwu", "RandomFuben3_6_2",false, 0, 1, 9011, 1},	
		},
	},	
	[9] = {nTime = 3, nNum = 0,
		tbPrelock = {8},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"BlackMsg", "怪物死亡後會屍爆，請務必小心！"},
			{"NpcBubbleTalk", "Npc", "這些毒蠍死亡後會爆出毒水，要小心不要踩到！", 4, 1, 1},
		},
	},
-------------胜利判定------------------------
	[10] = {nTime = 0, nNum = 6,
		tbPrelock = {8},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			--掉落首领奖励 ——  赵无双
			{"RaiseEvent", "DropAward", "Setting/Npc/DropFile/RandomFuben/House_C/zhaowushuang.tab", 3517, 3765},	
			{"RaiseEvent", "DropAward", "Setting/Npc/DropFile/RandomFuben/House_C/zhaowushuang.tab", 3600, 3700},	
			{"RaiseEvent", "DropAward", "Setting/Npc/DropFile/RandomFuben/House_C/zhaowushuang.tab", 3500, 3800},	

			--判断模式获得积分
			{"RaiseEvent", "AddMissionScore", "c_score_win"},
			
			{"OpenWindow", "LingJueFengLayerPanel", "Win"},
			{"GameWin"},
		},
	},
-------------闯关时间和积分------------------------
	[11] = {nTime = "c_6_time", nNum = 0,
		tbPrelock = {2},
		tbStartEvent = 
		{
			{"SetShowTime", 11},
		},
		tbUnLockEvent = 
		{
			--判断模式获得积分
			{"RaiseEvent", "AddMissionScore", "c_score_lost"},
			
			{"OpenWindow", "LingJueFengLayerPanel", "Fail"},
			{"GameLost"},
		},
	},
}

