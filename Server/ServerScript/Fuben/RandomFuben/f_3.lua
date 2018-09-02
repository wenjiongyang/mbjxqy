
local tbFubenSetting = Fuben.RandomFuben:GetRandomFubenSetting("f_3");

tbFubenSetting.tbMultiBeginPoint = {{1269, 1540},{1596, 1310},{1080, 1310},{1382, 1098}}	-- 副本出生点
tbFubenSetting.tbTempRevivePoint = {1453, 1361};
tbFubenSetting.nStartDir		 = 6;


tbFubenSetting.NPC = 
{
	[1] = {nTemplate = 1799, nLevel = -1, nSeries = -1}, --石头
	[2] = {nTemplate = 1800, nLevel = -1, nSeries = -1}, --放技能NPC
	[3] = {nTemplate = 1801, nLevel = -1, nSeries = -1}, --孟知秋
	[4] = {nTemplate = 104,  nLevel = -1, nSeries = 0},  --动态障碍墙
	[5] = {nTemplate = 1123, nLevel = -1, nSeries = 0},  --隐藏NPC（E5房间用的）
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
			{"SetNearbyRange", 4},

			--调整摄像机基础参数
			{"ChangeCameraSetting", 28, 35, 20},

			{"SetFubenProgress", -1,"等待秘境開啟"},
			{"AddNpc", 4, 2, 1, "wall", "wall_1_1",false, 23},
			{"OpenWindow", "LingJueFengLayerPanel", "Info",3, 9, "第六層 峰頂山門"},
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
			{"SetTargetPos", 3213, 3085},
			{"SetFubenProgress", 0, "探索凌絕峰"},
		},
	},
	[3] = {nTime = 0, nNum = 1,
		tbPrelock = {2},
		tbStartEvent = 
		{
			{"TrapUnlock", "TrapLock1", 3},

			--孟知秋
			{"AddNpc", 3, 1, 4, "BOSS", "RandomFuben6_3_BOSS", false, 40, 0, 0, 0},	

			--放技能NPC
			{"AddNpc", 2, 1, 4, "SkillNpc", "RandomFuben6_3_SkillNpc", false, 40, 0, 0, 0},	

			--石头 
			{"AddNpc", 1, 1, 0, "Stone", "RandomFuben6_3_Stone1", false, 0, 0, 0, 0},
			{"AddNpc", 1, 1, 0, "Stone", "RandomFuben6_3_Stone2", false, 0, 0, 0, 0},
			{"AddNpc", 1, 1, 0, "Stone", "RandomFuben6_3_Stone3", false, 0, 0, 0, 0},
			{"AddNpc", 1, 1, 0, "Stone", "RandomFuben6_3_Stone4", false, 0, 0, 0, 0},
			{"AddNpc", 1, 1, 0, "Stone", "RandomFuben6_3_Stone5", false, 0, 0, 0, 0},
			{"AddNpc", 1, 1, 0, "Stone", "RandomFuben6_3_Stone6", false, 0, 0, 0, 0},	

			{"SetHeadVisiable", "BOSS", false, 1},
			{"NpcHpUnlock", "BOSS", 30, 60},
			{"SetNpcProtected", "BOSS", 1},
			{"SetAiActive", "BOSS", 0},
		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},
			{"SetFubenProgress", 50, "擊敗孟知秋"},
			{"SetNpcProtected", "BOSS", 0},
			{"SetAiActive", "BOSS", 1},
			{"SetHeadVisiable", "BOSS", true, 0},
			{"NpcBubbleTalk", "BOSS", "小輩們，就讓我來考驗一下你們的武藝吧！！", 4, 0, 1},	
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
			{"NpcBubbleTalk", "BOSS", "沒想到你們武藝竟竟已到如此境地，那麼你們就來試試這招吧！", 4, 1, 1},
			{"NpcHpUnlock", "BOSS", 40, 30},

			--BOSS加跑速
			{"NpcAddBuff", "BOSS", 2452, 2, 180},

			{"ChangeNpcAi", "BOSS", "Move", "Path1", 31, 0, 0, 0, 0},

			--改变BOSS的视野和巡逻范围
			{"SetNpcRange", "BOSS", 200, 200, 0},
		},
	},
	[31] = {nTime = 0, nNum = 1,
		tbPrelock = {30},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			--旋风往前推
			{"CastSkill", "SkillNpc", 2786, 1, 4465, 4403}, 

			--BOSS定身 & 锁足（不能使用轻功）
			{"NpcAddBuff", "BOSS", 1058, 1, 150},
			{"AddBuff", 1457, 1, 180, 1, 0},
			{"NpcRemoveBuff", "BOSS", 2452},

			--石头下的挡技能NPC
			{"AddNpc", 5, 3, 0, "Hide",  "RandomFuben6_3_Hide1", false, 0, 0, 0, 0},
			{"AddNpc", 5, 3, 0, "Hide",  "RandomFuben6_3_Hide2", false, 0, 0, 0, 0},
			{"AddNpc", 5, 3, 0, "Hide",  "RandomFuben6_3_Hide3", false, 0, 0, 0, 0},
			{"AddNpc", 5, 3, 0, "Hide",  "RandomFuben6_3_Hide4", false, 0, 0, 0, 0},
			{"AddNpc", 5, 3, 0, "Hide",  "RandomFuben6_3_Hide5", false, 0, 0, 0, 0},
			{"AddNpc", 5, 3, 0, "Hide",  "RandomFuben6_3_Hide6", false, 0, 0, 0, 0},
			{"AddNpc", 5, 3, 0, "Hide",  "RandomFuben6_3_Hide7", false, 0, 0, 0, 0},
		},
	},
	[32] = {nTime = 4, nNum = 0,
		tbPrelock = {31},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"BlackMsg", "前方雷電襲來！[FFFE0D]尋找岩石躲避[-]，並[FFFE0D]接近孟知秋[-]！！"},

			{"NpcFindEnemyUnlock", "BOSS", 33, 1},

			--大范围旱地雷前推
			{"CastSkill", "SkillNpc", 2787, 11, 4465, 4403}, 

			{"StartTimeCycle", "cycle_1", 3, 100, 
				{"CastSkill", "SkillNpc", 2787, 11, 4465, 4465}, 
			},
		},
	},
	[33] = {nTime = 0, nNum = 1,
		tbPrelock = {31},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"NpcBubbleTalk", "BOSS", "哈哈哈，長江後浪推前浪，你們果然沒有讓老夫失望！！！", 4, 1, 1},

			--移除定身 & 锁足BUFF
			{"NpcRemoveBuff", "BOSS", 1058},
			{"RemovePlayerSkillState", 1457},
			{"SetNpcRange", "BOSS", 1500, 1500, 0},

			--关闭循环
			{"CloseCycle", "cycle_1"},
		},
	},
	[34] = {nTime = 20, nNum = 0,
		tbPrelock = {31},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"UnLock", 33}, 
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
			{"NpcBubbleTalk", "BOSS", "沒想到竟能與老夫戰至如此境地，看來老夫也不能藏拙了，你們繼續來試試這招吧！", 4, 1, 1},

			--BOSS加跑速
			{"NpcAddBuff", "BOSS", 2452, 2, 180},

			{"ChangeNpcAi", "BOSS", "Move", "Path1", 41, 0, 0, 0, 0},

			--改变BOSS的视野和巡逻范围
			{"SetNpcRange", "BOSS", 200, 200, 0},
		},
	},
	[41] = {nTime = 0, nNum = 1,
		tbPrelock = {40},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			--旋风往前推
			{"CastSkill", "SkillNpc", 2786, 1, 4465, 4403}, 

			--BOSS定身 & 锁足（不能使用轻功）
			{"NpcAddBuff", "BOSS", 1058, 1, 150},
			{"AddBuff", 1457, 1, 180, 1, 0},
			{"NpcRemoveBuff", "BOSS", 2452},

		},
	},
	[42] = {nTime = 4, nNum = 0,
		tbPrelock = {41},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"BlackMsg", "前方雷電襲來！[FFFE0D]尋找岩石躲避[-]並[FFFE0D]接近孟知秋[-]！！"},

			{"NpcFindEnemyUnlock", "BOSS", 43, 1},

			--大范围旱地雷前推
			{"CastSkill", "SkillNpc", 2787, 11, 4465, 4403}, 

			{"StartTimeCycle", "cycle_2", 3, 100, 
				{"CastSkill", "SkillNpc", 2787, 11, 4465, 4465}, 
			},
		},
	},
	[43] = {nTime = 0, nNum = 1,
		tbPrelock = {41},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"NpcBubbleTalk", "BOSS", "哈哈哈，長江後浪推前浪，你們果然沒有讓老夫失望！！", 4, 1, 1},

			--移除定身 & 锁足BUFF
			{"NpcRemoveBuff", "BOSS", 1058},
			{"RemovePlayerSkillState", 1457},
			{"SetNpcRange", "BOSS", 1500, 1500, 0},

			--关闭循环
			{"CloseCycle", "cycle_2"},
		},
	},
	[44] = {nTime = 20, nNum = 0,
		tbPrelock = {41},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"UnLock", 43}, 
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
			{"SetFubenProgress", 100, "擊敗孟知秋"},

			--判断模式篝火&踢出
			{"IfCase", "self.nFubenLevel == 2",
				{"AddSimpleNpc", 1611, 3766, 3695, 0},
				{"RaiseEvent", "KickOutAllPlayer", 40},
			},
			--判断模式获得积分
			{"RaiseEvent", "AddMissionScore", "f_score_win"},

			{"OpenWindow", "LingJueFengLayerPanel", "Win"},
			{"GameWin"},
		},
	},
	-------------闯关时间------------------------
	[5] = {nTime = "f_3_time", nNum = 0,    --总计时
		tbPrelock = {2},
		tbStartEvent = 
		{
			{"SetShowTime", 5},
		},
		tbUnLockEvent = 
		{
			{"SetFubenProgress", -1, "闖關失敗"},
			{"BlackMsg", "孟知秋武藝高強，還是先撤退為妙！"},

			--判断模式踢出
			{"IfCase", "self.nFubenLevel == 2",
				{"RaiseEvent", "KickOutAllPlayer", 10},
			},
			--判断模式获得积分
			{"RaiseEvent", "AddMissionScore", "f_score_lost"},

			{"OpenWindow", "LingJueFengLayerPanel", "Fail"},
			{"GameLost"},
		},
	},
}

