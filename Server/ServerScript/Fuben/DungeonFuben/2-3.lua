--秘银矿洞
Require("ServerScript/Fuben/DungeonFuben/DungeonMgr.lua")
local tbFubenSetting = {};
Fuben:SetFubenSetting(Fuben.DungeonFubenMgr.nMapTemplateIdSilver, tbFubenSetting)		-- 绑定副本内容和地图

tbFubenSetting.nDuraTime 				=  300; -- 副本时长
tbFubenSetting.szFubenClass 			= "DungeonFubenFloor2";									-- 副本类型
tbFubenSetting.szName 					= "水晶洞窟"											-- 单纯的名字，后台输出或统计使用
tbFubenSetting.szNpcPointFile 			= "Setting/Fuben/DungeonFuben/2_3/NpcPos.tab"			-- NPC点
--tbFubenSetting.szPathFile = "Setting/Fuben/TestFuben/NpcPos.tab"								-- 寻路点
tbFubenSetting.tbBeginPoint 			= {4588, 3967}											-- 副本出生点
tbFubenSetting.nNpcRegionPart			= 5; --刷出的魂石在5个区域内随机
tbFubenSetting.szRegionPrefix			= "Mine"; --刷出的魂石点集前缀
tbFubenSetting.tbGuohuoPoint 			= {4588, 3967};
tbFubenSetting.nGuohuoNpcId 			= 695		--篝火npcid


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
	
}

--NPC模版ID，NPC等级，NPC五行；
tbFubenSetting.NPC = 
{
	[1] = {nTemplate = 436, nLevel = 1, nSeries = 0}, --篝火
	[2] = {nTemplate = 435, nLevel = 1, nSeries = 0}, --魂石
	[3] = {nTemplate = 187, nLevel = 1, nSeries = 0}, --水晶
}

--npc 朝向
tbFubenSetting.NPC_DIR = 
{
	[1] = 0,
	[2] = 15,
	[3] = 35,
}

tbFubenSetting.LOCK = 
{
	-- 1号锁不能不填，默认1号为起始锁，nTime是到时间自动解锁，nNum表示需要解锁的次数，如填3表示需要被解锁3次才算真正解锁，可以配置字符串
	[1] = {nTime = 1, nNum = 0,
		--tbPrelock 前置锁，激活锁的必要条件{1 , 2, {3, 4}}，代表1和2号必须解锁，3和4任意解锁一个即可
		tbPrelock = {1},
		--tbStartEvent 锁激活时的事件
		tbStartEvent = 
		{
		},
		--tbStartEvent 锁解开时的事件
		tbUnLockEvent = 
		{
			{"RaiseEvent", "OwnerShowTaskDialog", 4005, true},	--对创建者的剧情对话 
			--{"RaiseEvent", "AddBoss",}, (nIndex, nLock, szGroup, szPointName, szAwardType)
			--{"RaiseEvent", "AddNpcWithoutAward",}, (nIndex, nNum, nLock, szGroup, szPointName, bRevive)
		},
	},

		--
	[2] = {nTime = 1, nNum = 0, 
		tbPrelock = {1},
		tbStartEvent = 
		{
			-- {"AddNpc", 1, 1, 0, "Gouhuo", "fire"},
		},
		tbUnLockEvent = 
		{
			
		},
	},
	[3] = {nTime = 30, nNum = 0, 
		tbPrelock = {2},
		tbStartEvent = 
		{
			
		},
		tbUnLockEvent = 
		{			
			{"DelNpc", "Gouhuo"},
		},
	},
	[4] = {nTime = tbFubenSetting.nDuraTime, nNum = 0,
		tbPrelock = {1},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"GameLost"},
		},
	},
	
}