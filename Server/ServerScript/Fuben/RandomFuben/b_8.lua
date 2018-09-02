
local tbFubenSetting = Fuben.RandomFuben:GetRandomFubenSetting("b_8");

tbFubenSetting.tbMultiBeginPoint = {{5423, 5564},{5653, 5379},{5227, 5366},{5450, 5165}}	-- 副本出生点
tbFubenSetting.tbTempRevivePoint = {5423, 5564}
tbFubenSetting.nStartDir		 = 38;


--NPC模版ID，NPC等级，NPC五行；
tbFubenSetting.NPC = 
{
	[1] = {nTemplate = 774, nLevel = -1, nSeries = 0},    --杨影枫-护送
	[2] = {nTemplate = 810, nLevel = -1, nSeries = 0},    --杨影枫-对话
	[3] = {nTemplate = 811, nLevel = -1, nSeries = -1},    --心魔-首领
	[4] = {nTemplate = 812, nLevel = -1, nSeries = -1},    --恐惧图腾-标识npc
	[5] = {nTemplate = 813, nLevel = -1, nSeries = -1},    --恐惧幻象-免控npc
	[6] = {nTemplate = 814, nLevel = -1, nSeries = -1},    --恐惧实体-召唤精英
	[7] = {nTemplate = 104, nLevel = -1, nSeries = 0},    --墙
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
		    {"AddNpc", 7, 2, 0, "wall_1", "wall_1_1",false, 24},
		    {"OpenWindow", "LingJueFengLayerPanel", "Info",3, 9, "第二層 後山小道"},
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
			{"SetFubenProgress", 0, "探索凌絕峰"},

			--临时NPC（杨影枫）
		    {"AddNpc", 1, 1, 0, "Temporary", "RandomFuben2_8_Temporary",false, 30},
			{"OpenDynamicObstacle", "obs"},
			{"ChangeFightState", 1},
			{"DoDeath", "wall_1"},
			{"SetTargetPos", 4860, 4805},
		},
	},
	[3] = {nTime = 0, nNum = 1,
		tbPrelock = {2},
		tbStartEvent = 
		{	
			{"TrapUnlock", "TrapLock1", 3},
		},
		tbUnLockEvent = 
		{	
			{"ClearTargetPos"},
			{"ChangeNpcAi", "Temporary", "Move", "Path1", 5, 0, 0, 1, 0},
			{"NpcBubbleTalk", "Temporary", "此地讓我想起在忘憂島闖心魔陣時的情況，去前面看看吧！", 4, 1, 1},
			{"BlackMsg", "居然在這裡遇到了悲魔山莊的楊影楓！"},
			{"SetFubenProgress", 20, "跟隨楊影楓"},
			{"SetTargetPos", 3260, 2959},
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
		},
	},
	[5] = {nTime = 0, nNum = 1,
		tbPrelock = {3},
		tbStartEvent = 
		{	
		},
		tbUnLockEvent = 
		{
			{"AddNpc", 2, 1, 0, "Yangyingfeng", "RandomFuben2_8_Yangyingfeng", false, 30},
			{"NpcBubbleTalk", "Yangyingfeng", "就是這裡了，我來告訴你們遭遇心魔時的感受吧！", 4, 1, 1},
		},
	},
	[6] = {nTime = 3, nNum = 0,     --等待BOSS时间
		tbPrelock = {5},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{	
			{"AddNpc", 3, 1, 8, "BOSS", "RandomFuben2_8_BOSS", false, 0, 1, 9011, 1},
			{"BlackMsg", "心魔出現，挑戰試試看吧！"},
			{"SetFubenProgress", 50, "擊敗心魔"},
			{"NpcBubbleTalk", "Yangyingfeng", "小心應付，我會提醒你們的！", 4, 0, 1},
		},
	},
	[7] = {nTime = 3, nNum = 0,
		tbPrelock = {6},
		tbStartEvent = 
		{            
   		},
		tbUnLockEvent = 
		{
			{"NpcHpUnlock", "BOSS", 30, 70},
		},
	},
------------------------------------流程阶段------------------------------
----------------------阶段1---------------------------	
	[30] = {nTime = 0, nNum = 1,
		tbPrelock = {6},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"NpcHpUnlock", "BOSS", 40, 30},
		    {"AddNpc", 5, 2, 31, "Summon_1", "RandomFuben2_8_Summon", false, 0},
		    {"NpcBubbleTalk", "BOSS", "直面自己內心的恐懼吧！！", 4, 1, 1},
			{"NpcBubbleTalk", "Yangyingfeng", "恐懼幻象出現了，小心應付！！！", 3, 1, 1},
			{"BlackMsg", "[FFFE0D]恐懼幻象[-]出現，請盡速將其[FFFE0D]擊殺[-]！！"},		
			{"ChangeNpcAi", "Summon_1", "Move", "Path2", 32, 0, 0, 1, 0},	
		},
	},
	[31] = {nTime = 0, nNum = 2,
		tbPrelock = {30},
		tbStartEvent = 
		{		    
		},
		tbUnLockEvent = 
		{	
		    {"NpcBubbleTalk", "BOSS", "不要高興得太早！", 4, 0, 1},
			{"NpcBubbleTalk", "Yangyingfeng", "就是這樣，在恐懼幻象召喚怪物前擊退它。", 4, 0, 1},
		},
	},
	[32] = {nTime = 0, nNum = 1,
		tbPrelock = {30},
		tbStartEvent = 
		{            
   		},
		tbUnLockEvent = 
		{
		    {"DelNpc", "Summon_1"},
		    {"AddNpc", 6, 1, 0, "Elite_1", "RandomFuben2_8_BOSS", false, 0, 1, 9011, 1},
		    {"NpcBubbleTalk", "Elite_1", "啊啊啊，我變強大了！", 3, 4, 1},
		    {"NpcBubbleTalk", "BOSS", "向恐懼臣服吧！", 4, 1, 1},
			{"NpcBubbleTalk", "Yangyingfeng", "恐懼實體出現了，小心應付吧！!", 4, 1, 1},
		},
	},
----------------------阶段2---------------------------	
	[40] = {nTime = 0, nNum = 1,
		tbPrelock = {30},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"AddNpc", 5, 2, 41, "Summon_2", "RandomFuben2_8_Summon", false, 0},
		    {"NpcBubbleTalk", "BOSS", "更大的恐懼來臨了！", 3, 1, 1},
			{"NpcBubbleTalk", "Yangyingfeng", "恐懼幻象來了，小心行事！！", 3, 1, 1},
			{"BlackMsg", "[FFFE0D]恐懼幻象[-]出現，請盡速將其[FFFE0D]擊殺[-]！！"},		
			{"ChangeNpcAi", "Summon_2", "Move", "Path2", 42, 0, 0, 1, 0},
		},
	},
	[41] = {nTime = 0, nNum = 2,
		tbPrelock = {40},
		tbStartEvent = 
		{		    
		},
		tbUnLockEvent = 
		{	
		    {"NpcBubbleTalk", "BOSS", "不，我不信你們能抵禦心魔！", 4, 1, 1},
			{"NpcBubbleTalk", "Yangyingfeng", "接下來只要幹掉這個心魔就行了！", 4, 1, 1},
		},
	},
	[42] = {nTime = 0, nNum = 1,
		tbPrelock = {40},
		tbStartEvent = 
		{            
   		},
		tbUnLockEvent = 
		{
		    {"DelNpc", "Summon_2"},
		    {"AddNpc", 6, 1, 0, "Elite_2", "RandomFuben2_8_BOSS", false, 0, 1, 9011, 1},
		    {"NpcBubbleTalk", "Elite_2", "啊啊啊，我變強大了！", 3, 4, 1},
		    {"NpcBubbleTalk", "BOSS", "向恐懼臣服吧！", 4, 1, 1},
			{"NpcBubbleTalk", "Yangyingfeng", "恐懼實體出現了，小心應付吧！", 4, 1, 1},
		},
	},

-------------胜利判定------------------------
	[8] = {nTime = 0, nNum = 1,
		tbPrelock = {6},
		tbStartEvent = 
		{		
		},
		tbUnLockEvent = 
		{
			--掉落房间奖励
			{"RaiseEvent", "DropAward", "Setting/Fuben/RandomFuben/HouseAward/B.tab", 2898, 2890},
			{"RaiseEvent", "DropAward", "Setting/Fuben/RandomFuben/HouseAward/B.tab", 3189, 2915},
			{"RaiseEvent", "DropAward", "Setting/Fuben/RandomFuben/HouseAward/B.tab", 2906, 2632},
			{"RaiseEvent", "DropAward", "Setting/Fuben/RandomFuben/HouseAward/B.tab", 3189, 2636},

			--判断模式获得积分
			{"RaiseEvent", "AddMissionScore", "b_score_win"},
			
			{"SetFubenProgress", 100, "擊敗心魔"},
			{"OpenWindow", "LingJueFengLayerPanel", "Win"},
			{"GameWin"},  
		},
	},
-------------闯关时间------------------------
	[9] = {nTime = "b_8_time", nNum = 0,     --总计时
		tbPrelock = {2},
		tbStartEvent = 
		{
			{"SetShowTime", 9},
		},
		tbUnLockEvent = 
		{
			--判断模式获得积分
			{"RaiseEvent", "AddMissionScore", "b_score_lost"},

			{"BlackMsg", "心魔果然不是好對付的，我們還是不挑戰了吧！"},
			{"OpenWindow", "LingJueFengLayerPanel", "Fail"},
			{"GameLost"},
		},
	},

}
