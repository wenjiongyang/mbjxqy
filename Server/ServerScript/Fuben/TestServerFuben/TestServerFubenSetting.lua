
local tbFubenSetting = {};
Fuben:SetFubenSetting(-1, tbFubenSetting)		-- 绑定副本内容和地图

tbFubenSetting.szFubenClass 			= "TeamFubenBase";									-- 副本类型
tbFubenSetting.szName 					= "測試副本"											-- 单纯的名字，后台输出或统计使用
tbFubenSetting.szNpcPointFile 			= "Setting/Fuben/PersonalFuben/1_1/NpcPos.tab"			-- NPC点
--tbFubenSetting.szPathFile = "Setting/Fuben/TestFuben/NpcPos.tab"								-- 寻路点
tbFubenSetting.tbBeginPoint 			= {2091, 3213}											-- 副本出生点
tbFubenSetting.tbTempRevivePoint 		= {2091, 3213}											-- 临时复活点，副本内有效，出副本则移除

-- AddNpc						说明：添加NPC 			
--								参数：nIndex npc序号(可用NUM内参数), nNum 添加数量(可用NUM内参数), nLock 死亡解锁Id, szGroup 所在分组名, szPointName 刷新点名, bRevive 是否重生
--								示例：{"AddNpc", "NpcIndex2", "NpcNum2", 3, "Test1", "NpcPos2"},

-- ChangeTrap					说明：更换trap传送点		
--								参数：szClassName Trap点名字, tbPoint 传送点坐标, bFight 传送后是否为战斗状态, bExit 是否离开副本
--								示例：{"ChangeTrap", "Trapname", {1533, 3660}, 0, 1},

-- TrapUnlock					说明：玩家踩Trap 解锁
--								参数：szClassName Trap点名字, nLockId 解锁ID
--								示例：{"TrapUnlock", "Trapname", 1},

-- CloseLock					说明：关闭锁
--								参数：nBeginLockId 起始LockId, nEndLockId 结束Id
--								示例：{"CloseLock", 2, 4}, (关闭了 2，3，4 三个锁)， {"CloseLock", 2}, (只关闭 2号锁)

-- ChangeNpcAi					说明：改变AI, 参数: npc分组名,AI子指令（AI有以下类型可以更改)：
		-- Move 移动， 参数：路径名, 到达解锁ID, 是否主动攻击，是否还击，是否到达删除，例 {"ChangeNpcAi", "guaiwu", "Move", "Path1", 4, 1, 1, 1},

-- GameWin						说明：副本胜利，无参数

-- GameLost						说明：副本失败，无参数

-- RaiseEvent					说明：触发副本事件，不同类型副本所支持事件不同，具体事件说明请直接联系相关程序
--								参数：szEventName 事件名，... 事件所需参数
--								示例：{"RaiseEvent", "Log", "unlock lock 4"},

-- SetPos						说明：改变所有玩家所在坐标
--								参数：nX 设置X坐标, nY 设置Y坐标
--								示例：{"SetPos", 1589, 3188},

-- BlackMsg						说明：给所有副本内玩家黑条提示
--								参数：szMsg
--								示例：{"BlackMsg", "那啥？"},

-- UseSkill						说明：让指定NPC在某个坐标点释放技能
--								参数：szGroup npc组, nSkillId 技能ID, nMpsX, nMpsY
--								示例：{ "CastSkill", "guaiwu", 734, 51224, 101860},

-- OpenDynamicObstacle			说明：打开当前地图的动态障碍
--								参数：szObsName 动态障碍名
--								示例：{"OpenDynamicObstacle", "ops1"},

-- PlayCameraAnimation			说明：播放录制好的摄像机动画，同时摄像机进入动画模式，此模式下，摄像机不跟随玩家移动，播放结束后解锁 nLockId
--								参数：nAnimationId 动画Id 在 tbFubenSetting.ANIMATION 中定义, nLockId 播放结束后解锁的ID
--								示例：{"PlayCameraAnimation", 1, 2},

-- MoveCamera					说明：在nTime时间内平滑移动摄像机到目标位置，同时摄像机进入动画模式，此模式下，摄像机不跟随玩家移动，移动到目标位置时解锁 nLockId
--								参数：nLockId 播放结束后解锁的Id, nTime 移动到目标点需要耗时, 
--										nX 目标点 X 坐标（参数为 0 表示保持原参数）, nY 目标点 Y 坐标（参数为 0 表示保持原参数）, nZ 目标点 Z 坐标（参数为 0 表示保持原参数）, 
--										nrX 目标旋转 X（参数为 0 表示保持原参数）, nrY 目标旋转 Y（参数为 0 表示保持原参数）, nrZ 目标旋转 Z（参数为 0 表示保持原参数）
--								示例：{"MoveCamera", 3, 2, 28.06, 34.81, 20.03, 60.44, 81.254, 178.59},

-- LeaveAnimationState			说明：摄像机离开动画模式，恢复为摄像机跟随玩家，无参数

-- SetTargetPos					说明：设置玩家当前寻路目标点
--								参数：nX, nY
--								示例：{"SetTargetPos", 1000, 2000},

-- 单机副本支持接口
-- AddNpcWithoutAward			说明：添加 Npc，并且此Npc死亡不掉落任何物品，随机分配掉落不会对此Npc进行分配
--								参数：nIndex npc序号(可用NUM内参数), nNum 添加数量(可用NUM内参数), nLock 死亡解锁Id, szGroup 所在分组名, szPointName 刷新点名, bRevive 是否重生
--								示例：{"RaiseEvent", "AddNpcWithoutAward", "NpcIndex2", "NpcNum2", 3, "Test1", "NpcPos2"},

-- AddBoss						说明：添加 BOSS
--								参数：nIndex npc序号(可用NUM内参数), nLock 死亡解锁Id, szGroup 所在分组名, szPointName 刷新点名, szAwardType Boss奖励名
--								示例：{"RasieEvent", "AddBoss", "BossId1", 4, "BossGroup1", "BossPos1", "szBossAward_2"},

-- CheckResult					说明：检测当前副本结果，无参数
--								示例：{"RasieEvent", "CheckResult"},

-- 可用变量 NUM 的地方 
-- 每个 LOCK 的 nTime  nNum  
-- AddNpc 的参数 nIndex 和 nNum
-- 单机副本的 AddNpcWithoutAward 参数 nIndex
-- 单机副本的 AddBoss 参数 nIndex


-- ID可以随便 普通副本NPC数量 ；精英模式NPC数量
tbFubenSetting.NUM = 
{
	NpcIndex1	 	= {1, 1},
	NpcIndex2	 	= {2, 2},
	NpcIndex3	 	= {3, 3},
	NpcIndex4	 	= {4, 4},
	NpcIndex5	 	= {5, 5},
	NpcIndex6	 	= {6, 6},
	NpcNum1 		= {3, 6},
	NpcNum2 		= {4, 4},
	NpcNum3 		= {5, 10},
	NpcNum4 		= {5, 5},
	NpcNum5 		= {1, 2},
	NpcNum6 		= {1, 1},
	LockNum1		= {3, 6},
	LockNum2		= {7, 12},
	LockNum3		= {1, 1},
}

--NPC模版ID，NPC等级，NPC五行；
tbFubenSetting.NPC = 
{
	[1] = {nTemplate = 3, nLevel = 20, nSeries = 1},
	[2] = {nTemplate = 4, nLevel = 20, nSeries = 2},
	[3] = {nTemplate = 5, nLevel = 20, nSeries = 3},
	[4] = {nTemplate = 6, nLevel = 20, nSeries = 4},
	[5] = {nTemplate = 7, nLevel = 1, nSeries = 0},
	[6] = {nTemplate = 38, nLevel = 1, nSeries = 0},
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
			--{"RaiseEvent", "AddBoss",}, (nIndex, nLock, szGroup, szPointName, szAwardType)
			--{"RaiseEvent", "AddNpcWithoutAward",}, (nIndex, nNum, nLock, szGroup, szPointName, bRevive)
		},
	},
	[2] = {nTime = 0, nNum = 1,
			tbPrelock = {1},
			tbStartEvent = 
		{
			--{"AddNpc", "NpcIndex1", 1, 2, "1_1_1", "1_1_1"},
			{"ChangeFightState", 1},
			{"TrapUnlock", "TrapLock1", 2},
			{"SetTargetPos", 1908, 3667},
			--{"PlayCameraAnimation", 1, 2},
		},
			tbUnLockEvent = 
		{
			{"RaiseEvent", "Log", "unlock lock 2"},
			{"BlackMsg", "淫賊休走！光天化日之下竟然盜取我家小姐內衣！"},
			{"AddNpc", "NpcIndex1", "NpcNum1", 3, "1_2_1", "1_2_1"},
		},
	},
	[3] = {nTime = 0, nNum = "NpcNum1",
			tbPrelock = {2},
			tbStartEvent = 
		{
			--{"MoveCamera", 3, 2, 28.06, 34.81, 20.03, 60.44, 81.254, 178.59},
		},
			tbUnLockEvent = 
		{
			{"RaiseEvent", "Log", "unlock lock 3"},
			{"SetTargetPos", 1809, 5911},	
			{"BlackMsg", "總算是解決掉這些追兵了，暫時到北方躲一躲吧！！"},		
				--{"LeaveAnimationState"},
		},
	},
	[4] = {nTime = 0, nNum = 1,		-- 总计时
		tbPrelock = {3},
		tbStartEvent = 
		{				
			{"TrapUnlock", "TrapLock2", 4},	
		},
		tbUnLockEvent = 
		{
			--{"RaiseEvent", "ShowCurAward"},
			{"RaiseEvent", "Log", "unlock lock 4"},
			{"BlackMsg", "你已經走投無路了！乖乖束手就擒吧！"},		
			{"AddNpc", "NpcIndex2", "NpcNum2", 5, "1_2_2", "1_2_2"},
		},
	},
	[5] = {nTime = 0, nNum = "NpcNum2",		-- 总计时
		tbPrelock = {4},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			--{"RaiseEvent", "ShowCurAward"},
			{"RaiseEvent", "Log", "unlock lock 5"},
			{"SetTargetPos", 3300, 5400},	
			{"BlackMsg", "雙拳難敵四手啊！不行！那兒有座橋！趕緊跑！"},		
		},
	},
	[6] = {nTime = 0, nNum = 1,		-- 总计时
		tbPrelock = {5},
		tbStartEvent = 
		{				
			{"TrapUnlock", "TrapLock3", 6},		
		},
		tbUnLockEvent = 
		{
			--{"RaiseEvent", "ShowCurAward"},
			{"RaiseEvent", "Log", "unlock lock 6"},
			{"BlackMsg", "哈哈哈！中埋伏了吧！此橋就是你的葬身之所！"},		
			{"AddNpc", "NpcIndex3", "NpcNum3", 7, "1_2_3", "1_2_3"},
		},
	},
	[7] = {nTime = 0, nNum = "NpcNum3",		-- 总计时
		tbPrelock = {6},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			--{"RaiseEvent", "ShowCurAward"},
			{"RaiseEvent", "Log", "unlock lock 7"},
			{"SetTargetPos", 5029, 4945},	
			{"BlackMsg", "總算是解決掉他們了，現在應該安全了吧。"},		
		},
	},
	[8] = {nTime = 0, nNum = 1,		-- 总计时
		tbPrelock = {7},
		tbStartEvent = 
		{				
			{"TrapUnlock", "TrapLock4", 8},		
		},
		tbUnLockEvent = 
		{
			--{"RaiseEvent", "ShowCurAward"},
			{"RaiseEvent", "Log", "unlock lock 8"},
			{"BlackMsg", "哈哈哈！你以為到這裡就安全了嗎？真是天真！"},		
			{"AddNpc", "NpcIndex4", "NpcNum4", 9, "1_2_4", "1_2_4"},
		},
	},
	[9] = {nTime = 0, nNum = "NpcNum4",
		tbPrelock = {8},
		tbStartEvent = 
		{			
		},
		tbUnLockEvent = 
		{
			{"SetTargetPos", 5352, 2259},
			{"BlackMsg", "不要和主角光環作對，記住我的名字，我叫蕭動塵。"},
		
		},
	},	
	[10] = {nTime = 0, nNum = 1,		-- 总计时
		tbPrelock = {9},
		tbStartEvent = 
		{				
			{"TrapUnlock", "TrapLock5", 10},		
		},
		tbUnLockEvent = 
		{
			--{"RaiseEvent", "ShowCurAward"},
			{"RaiseEvent", "Log", "unlock lock 8"},
			{"BlackMsg", "哈哈哈，總算是等到你了！乖乖的束手就擒吧！"},		
			{"AddNpc", "NpcIndex5", "NpcNum5", 11, "1_2_5", "1_2_5"},
		},
	},
	[11] = {nTime = 0, nNum = "NpcNum5",
		tbPrelock = {10},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"BlackMsg", "LOK'TAR OGAR"},
			--{"SetGameWorldScale", 0.1},		-- 慢镜头开始
		},
	},
	[12] = {nTime = 3, nNum = 0,
		tbPrelock = {11},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			--{"SetGameWorldScale", 1},		-- 慢镜头开始
			{"BlackMsg", "為了部落！"},
		},
	},
	[13] = {nTime = 2, nNum = 0,
		tbPrelock = {12},
		tbStartEvent = 
		{					
		},
		tbUnLockEvent = 
		{
			--{"RaiseEvent", "ShowCurAward"},
			{"RaiseEvent", "Log", "unlock lock 5"},
			--{"RaiseEvent", "CheckResult"},
			{"GameWin"},
		},
	},
	[14] = {nTime = 300, nNum = 0,
		tbPrelock = {1},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			--{"RaiseEvent", "ShowCurAward"},
			{"RaiseEvent", "Log", "unlock lock 6, game lost !!"},
			{"GameLost"},
		},
	},
}