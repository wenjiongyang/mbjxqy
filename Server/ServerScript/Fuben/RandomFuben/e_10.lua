
local tbFubenSetting = Fuben.RandomFuben:GetRandomFubenSetting("e_10");

tbFubenSetting.tbMultiBeginPoint = {{528, 863},{793, 815},{472, 613},{762, 553}}	-- 副本出生点
tbFubenSetting.tbTempRevivePoint = {639, 701};
tbFubenSetting.nStartDir		 = 2;


--NPC模版ID，NPC等级，NPC五行；

--[[
]]


tbFubenSetting.NPC = 
{
	[1] = {nTemplate = 1598, nLevel = -1, nSeries = -1}, --赵升权
	[2] = {nTemplate = 104,  nLevel = -1, nSeries = 0},  --动态障碍墙
	[3] = {nTemplate = 1782, nLevel = -1, nSeries = 0},  --灵魂球（红）
	[4] = {nTemplate = 1783, nLevel = -1, nSeries = 0},  --灵魂球（金）
	[5] = {nTemplate = 1785, nLevel = -1, nSeries = 0},  --灵魂球（绿）
	[6] = {nTemplate = 1786, nLevel = -1, nSeries = 0},  --灵魂球（紫）
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

			--调整摄像机基础参数
			{"ChangeCameraSetting", 29, 35, 20},

			{"SetFubenProgress", -1,"等待秘境開啟"},
			{"AddNpc", 2, 1, 1, "wall", "wall_1_1",false, 20},
			{"OpenWindow", "LingJueFengLayerPanel", "Info",3, 9, "第五層 詭影密林"},
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
			{"ShowTaskDialog", 10004, false},
			{"DoDeath", "wall"},
			{"OpenDynamicObstacle", "ops1"},			
			{"SetTargetPos", 1712, 2197},
		},
	},
	[3] = {nTime = 0, nNum = 1,
		tbPrelock = {2},
		tbStartEvent = 
		{
			{"SetFubenProgress", 0, "探索凌絕峰"},
			{"TrapUnlock", "TrapLock1", 3},

			--赵升权
			{"AddNpc", 1, 1, 4, "BOSS", "RandomFuben5_10_BOSS", false, 45, 0, 0, 0},	
			{"UseSkill", "BOSS", 2404, -1, -1},
			{"NpcHpUnlock", "BOSS", 30, 80},
			{"SetNpcProtected", "BOSS", 1},
			{"SetAiActive", "BOSS", 0},
			{"SetHeadVisiable", "BOSS", false, 1},
		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},
			{"SetFubenProgress", 50, "擊敗趙升權"},
			{"SetNpcProtected", "BOSS", 0},
			{"SetAiActive", "BOSS", 1},
			{"SetHeadVisiable", "BOSS", true, 0},
			{"NpcBubbleTalk", "BOSS", "少年人，閑來無事你們便陪我切磋一番吧！", 4, 0, 1},	
		},
	},
------------------------------------流程阶段------------------------------
----------------------阶段1---------------------------
	[30] = {nTime = 0, nNum = 1,
		tbPrelock = {3},
		tbStartEvent = 
		{				
		},
		tbUnLockEvent = 
		{	
			{"NpcBubbleTalk", "BOSS", "實力當真不錯！那麼就讓你們見識一下我風雪山莊的絕技吧！", 3, 1, 1},	
			{"NpcHpUnlock", "BOSS", 40, 50},	

			{"BlackMsg", "靈魂球出現！在[FFFE0D]靈魂球[-]到達前將其[FFFE0D]擊殺[-]！"},			

			--光球
			{"AddNpc", 3, 1, 0, "Ball_1", "RandomFuben5_10_Ball1", false, 0, 1, 9011, 1},	
		},
	},
	[31] = {nTime = 3, nNum = 0,
		tbPrelock = {30},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{	
			{"ChangeNpcAi", "Ball_1", "Move", "Path1", 32, 0, 0, 1, 0},	
		},
	},
	[32] = {nTime = 0, nNum = 1,
		tbPrelock = {30},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{	
			--加攻BUFF				
			{"NpcAddBuff", "BOSS", 1535, 10, 30},	
		},
	},
	[33] = {nTime = 0.1, nNum = 0,
		tbPrelock = {32},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{	
			{"BlackMsg", "趙升權吸收了靈魂球的力量， 請諸位小心應對！！"},
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
			{"NpcBubbleTalk", "BOSS", "長江後浪推前浪，你們當真不錯！既然如此老夫也不能藏拙了！！", 4, 0, 1},		

			{"BlackMsg", "靈魂球出現！在[FFFE0D]靈魂球[-]到達前將其[FFFE0D]擊殺[-]！"},			

			--光球
			{"AddNpc", 4, 1, 0, "Ball_2", "RandomFuben5_10_Ball2", false, 0, 1, 9011, 1},
			{"AddNpc", 6, 1, 0, "Ball_3", "RandomFuben5_10_Ball3", false, 0, 1, 9011, 1},	
		},
	},
	[41] = {nTime = 3, nNum = 0,
		tbPrelock = {40},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{	
			{"ChangeNpcAi", "Ball_2", "Move", "Path1", 42, 0, 0, 1, 0},	
			{"ChangeNpcAi", "Ball_3", "Move", "Path1", 43, 0, 0, 1, 0},	
		},
	},
	[42] = {nTime = 0, nNum = 1,
		tbPrelock = {40},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{	
			--加抗性			
			{"NpcAddBuff", "BOSS", 1509, 5, 30},		
		},
	},
	[43] = {nTime = 0, nNum = 1,
		tbPrelock = {40},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{	
			--中毒光环（范围持续伤害）			
			{"UseSkill", "BOSS", 2404, -1, -1},
		},
	},
	[44] = {nTime = 30, nNum = 0,
		tbPrelock = {43},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{	
			--关闭中毒光环		
			{"UseSkill", "BOSS", 2404, -1, -1},
		},
	},
	[45] = {nTime = 0.1, nNum = 0,
		tbPrelock = {{42, 43}},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{	
			{"BlackMsg", "趙升權吸收了靈魂球的力量， 請諸位小心應對！！"},
		},
	},

-------------胜利判定------------------------
	[4] = {nTime = 0, nNum = 1,
		tbPrelock = {3},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"SetFubenProgress", 100, "擊敗趙升權"},			

			--判断模式篝火&踢出
			{"IfCase", "self.nFubenLevel == 1",
				{"AddSimpleNpc", 1611, 2449, 2606, 0},
				{"RaiseEvent", "KickOutAllPlayer", 40},
			},

			--判断模式获得积分
			{"RaiseEvent", "AddMissionScore", "e_score_win"},

			{"OpenWindow", "LingJueFengLayerPanel", "Win"},
			{"GameWin"},
		},
	},
-------------闯关时间------------------------	
	[5] = {nTime = "e_10_time", nNum = 0,
		tbPrelock = {2},
		tbStartEvent = 
		{
			{"SetShowTime", 5},
		},
		tbUnLockEvent = 
		{
			{"BlackMsg", "這趙升權武功果然高強，在下自愧不如！"},

			--判断模式踢出
			{"IfCase", "self.nFubenLevel == 1",
				{"RaiseEvent", "KickOutAllPlayer", 10},
			},
			--判断模式获得积分
			{"RaiseEvent", "AddMissionScore", "e_score_lost"},

			{"OpenWindow", "LingJueFengLayerPanel", "Fail"},
			{"GameLost"},
		},
	},

}
