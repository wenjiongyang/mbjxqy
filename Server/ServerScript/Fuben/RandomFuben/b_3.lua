
local tbFubenSetting = Fuben.RandomFuben:GetRandomFubenSetting("b_3");

tbFubenSetting.tbMultiBeginPoint = {{1327, 826},{1327, 423},{1005, 835},{979, 406}}	-- 副本出生点
tbFubenSetting.tbTempRevivePoint = {1154, 636}
tbFubenSetting.nStartDir		 = 13;


--NPC模版ID，NPC等级，NPC五行；
tbFubenSetting.NPC = 
{
	[1] = {nTemplate = 734, nLevel = -1, nSeries = -1},    --萧动尘
	[2] = {nTemplate = 735, nLevel = -1, nSeries = -1},    --无忧教弟子
	[3] = {nTemplate = 736, nLevel = -1, nSeries = -1},    --无忧教高手-恢复
	[4] = {nTemplate = 737, nLevel = -1, nSeries = -1},    --无忧教高手-反弹
	[5] = {nTemplate = 104, nLevel = -1, nSeries = 0},     --墙
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
		    {"AddNpc", 5, 1, 0, "wall", "wall_1_1",false, 29},
		    {"OpenWindow", "LingJueFengLayerPanel", "Info",3, 9, "第二層 後山小道"},
		},
	},
	[2] = {nTime = 10, nNum = 0,     --总计时
		tbPrelock = {1},
		tbStartEvent = 
		{

		},
		tbUnLockEvent = 
		{
			{"RaiseEvent", "Start"},
			{"OpenDynamicObstacle", "ops1"},
			{"DoDeath", "wall"},
			{"ShowTaskDialog", 10001, false},
			{"SetTargetPos", 2168, 1797},
		},
	},
	[3] = {nTime = 0, nNum = 1,
		tbPrelock = {2},
		tbStartEvent = 
		{	
			{"SetFubenProgress", 0, "探索凌絕峰"},
			{"TrapUnlock", "TrapLock1", 3},	
		},
		tbUnLockEvent = 
		{	
			{"SetFubenProgress", 50, "擊敗蕭動塵"},	
			{"ClearTargetPos"},
			{"BlackMsg", "糟糕！居然在這山腰處碰到了蕭動塵！"},

			--萧动尘
			{"AddNpc", 1, 1, 7, "BOSS", "RandomFuben2_3_BOSS", false, 0, 1, 9011, 1},
			{"NpcBubbleTalk", "BOSS", "哈哈，沒想到你們居然送上門來了！新仇舊恨就在此一併了結吧！", 4, 3, 1},
		},
	},
	[4] = {nTime = 3, nNum = 0,     --等待时间
		tbPrelock = {3},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{	
			{"NpcHpUnlock", "BOSS", 5, 70},
		},
	},
	[5] = {nTime = 0, nNum = 1,
		tbPrelock = {4},
		tbStartEvent = 
		{
            
   		},
		tbUnLockEvent = 
		{
			{"NpcBubbleTalk", "BOSS", "可惡的傢伙！就讓你們看看我無憂教的厲害！", 3, 1, 1},
			{"BlackMsg", "無憂教弟子出現，請小心行事！"},

			--无忧教弟子 & 无忧教高手（带有恢复光环）
			{"AddNpc", 2, 5, 0, "guaiwu", "RandomFuben2_3_1", false, 0, 1, 9008, 0.5},
			{"AddNpc", 3, 1, 0, "Guanghuan", "RandomFuben2_3_2", false, 0, 1, 9011, 1},
			{"ChangeNpcAi", "guaiwu", "Move", "Path1", 0, 1, 1, 0, 0},
			{"ChangeNpcAi", "Guanghuan", "Move", "Path1", 0, 1, 1, 0, 0},
			{"NpcBubbleTalk", "Guanghuan", "哪裡來的傢伙竟敢和無憂教作對，真是自尋死路！", 4, 3, 1},
		},
	},
	[6] = {nTime = 0, nNum = 1,
		tbPrelock = {5},
		tbStartEvent = 
		{
		    {"NpcHpUnlock", "BOSS", 6, 30},
		},
		tbUnLockEvent = 
		{	
			{"NpcBubbleTalk", "BOSS", "可... 可惡，你們不要欺人太甚！小的們，給我上！", 3, 1, 1},
			{"BlackMsg", "新的一批無憂教弟子出現，請小心行事！"},

			--无忧教弟子 & 无忧教高手（带有反弹光环）
			{"AddNpc", 2, 5, 0, "guaiwu", "RandomFuben2_3_3", false, 0, 1, 9008, 0.5},
			{"AddNpc", 4, 1, 0, "Guanghuan", "RandomFuben2_3_4", false, 0, 1, 9011, 1},
			{"ChangeNpcAi", "guaiwu", "Move", "Path1", 0, 1, 1, 9008, 0.5},
			{"ChangeNpcAi", "Guanghuan", "Move", "Path1", 0, 1, 1, 9011, 1},
			{"NpcBubbleTalk", "Guanghuan", "兄弟們一起上，幹掉他們！", 4, 3, 1},
		},
	},

-------------胜利判定------------------------
	[7] = {nTime = 0, nNum = 1,
		tbPrelock = {2},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"SetFubenProgress", 100, "擊敗蕭動塵"},
			{"OpenWindow", "LingJueFengLayerPanel", "Win"},

			--判断模式获得积分
			{"RaiseEvent", "AddMissionScore", "b_score_win"},
			
			{"GameWin"},  
		},
	},
-------------闯关时间------------------------	
	[8] = {nTime = "b_3_time", nNum = 0,     --总计时
		tbPrelock = {2},
		tbStartEvent = 
		{
			{"SetShowTime", 8},
		},
		tbUnLockEvent = 
		{
			--判断模式获得积分
			{"RaiseEvent", "AddMissionScore", "b_score_lost"},

			{"BlackMsg", "可惡，沒想到這傢伙的武功如此之強!！"},
			{"OpenWindow", "LingJueFengLayerPanel", "Fail"},
			{"GameLost"},
		},
	},

}

