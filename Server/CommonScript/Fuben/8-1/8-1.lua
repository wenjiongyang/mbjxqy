
local tbFubenSetting = {};
Fuben:SetFubenSetting(60, tbFubenSetting)		-- 绑定副本内容和地图

tbFubenSetting.szFubenClass 			= "PersonalFubenBase";									-- 副本类型
tbFubenSetting.szName 					= "測試副本"											-- 单纯的名字，后台输出或统计使用
tbFubenSetting.szNpcPointFile 			= "Setting/Fuben/PersonalFuben/8_1/NpcPos.tab"			-- NPC点
--tbFubenSetting.szNpcExtAwardPath 		= "Setting/Fuben/PersonalFuben/8_1/ExtNpcAwardInfo.tab"	-- 掉落表
tbFubenSetting.szPathFile 				= "Setting/Fuben/PersonalFuben/8_1/NpcPath.tab"			-- 寻路点
tbFubenSetting.tbBeginPoint 			= {4224, 5199}											-- 副本出生点
tbFubenSetting.nStartDir				= 48;


-- ID可以随便 普通副本NPC数量 ；精英模式NPC数量

tbFubenSetting.ANIMATION = 
{
	[1] = "Scenes/Maps/yw_luoyegu/Main Camera.controller",
}

--NPC模版ID，NPC等级，NPC五行；
tbFubenSetting.NPC = 
{
	[1] = {nTemplate = 1915,	nLevel = -1,	nSeries = -1},	--恶狼
	[2] = {nTemplate = 1916,	nLevel = -1,	nSeries = -1},	--土匪
	[3] = {nTemplate = 1917,	nLevel = -1,	nSeries = -1},	--土匪精英
	[4] = {nTemplate = 1918,	nLevel = -1,	nSeries = -1},	--斗笠剑客

	[7] = {nTemplate = 104,		nLevel = -1,	nSeries = 0},	--障碍门
}

tbFubenSetting.LOCK = 
{
	-- 1号锁不能不填，默认1号为起始锁，nTime是到时间自动解锁，nNum表示需要解锁的次数，如填3表示需要被解锁3次才算真正解锁，可以配置字符串
	[1] = {nTime = 0, nNum = 1,
		--tbPrelock 前置锁，激活锁的必要条件{1 , 2, {3, 4}}，代表1和2号必须解锁，3和4任意解锁一个即可
		tbPrelock = {},
		--tbStartEvent 锁激活时的事件
		tbStartEvent = 
		{
			{"RaiseEvent", "ShowTaskDialog", 1, 1120, false},
		},
		--tbStartEvent 锁解开时的事件
		tbUnLockEvent = 
		{
			{"SetShowTime", 2},
		},
	},
	[2] = {nTime = 300, nNum = 0,
		tbPrelock = {1},
		tbStartEvent = 
		{
			{"RaiseEvent", "RegisterTimeoutLock"},
		},
		tbUnLockEvent = 
		{
			{"GameLost"},
		},
	},
	[3] = {nTime = 0, nNum = 1,
		tbPrelock = {1},
		tbStartEvent = 
		{
			{"ChangeFightState", 1},
			{"TrapUnlock", "trap1", 3},
			{"SetTargetPos", 3388, 5050},
			{"AddNpc", 7, 1, 0, "wall", "men1",false, 42},
		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},
		},
	},
	[4] = {nTime = 0, nNum = 8,
		tbPrelock = {3},
		tbStartEvent = 
		{
			{"AddNpc", 1, 8, 4, "gw", "guaiwu1", false, 0, 0.5, 9005, 0.5},
			{"RaiseEvent", "PartnerSay", "小心有惡狼！！", 3, 1},
		},
		tbUnLockEvent = 
		{
			{"RaiseEvent", "PartnerSay", "看來此處不甚太平...", 3, 1},
			{"BlackMsg", "繼續前進"},
			{"OpenDynamicObstacle", "obs1"},
			{"DoDeath", "wall"},
		},
	},
	[5] = {nTime = 0, nNum = 1,
		tbPrelock = {4},
		tbStartEvent = 
		{
			{"TrapUnlock", "trap2", 5},
			{"SetTargetPos", 4950, 3050},
		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},
			{"AddNpc", 7, 1, 0, "wall", "men2",false, 64},
		},
	},
	[6] = {nTime = 0, nNum = 10,
		tbPrelock = {5},
		tbStartEvent = 
		{
			{"AddNpc", 2, 9, 6, "gw", "guaiwu2", false, 0, 0.5, 9005, 0.5},
			{"AddNpc", 3, 1, 6, "gw", "guaiwu2", false, 0, 0.5, 9005, 0.5},
			{"NpcBubbleTalk", "gw", "這塊地方已經被我們承包了！不想死的話趕緊滾！", 4, 1, 1},
		},
		tbUnLockEvent = 
		{
			{"RaiseEvent", "PartnerSay", "這些土匪在此處幹什麼？", 3, 1},
			{"BlackMsg", "繼續前進"},
			{"OpenDynamicObstacle", "obs2"},
			{"DoDeath", "wall"},
		},
	},
	[7] = {nTime = 0, nNum = 1,
		tbPrelock = {6},
		tbStartEvent = 
		{
			{"TrapUnlock", "trap3", 7},
			{"SetTargetPos", 2510, 2501},
		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},
		},
	},
	[8] = {nTime = 0, nNum = 1,
		tbPrelock = {7},
		tbStartEvent = 
		{
			{"AddNpc", 2, 9, 0, "gw", "guaiwu3", false, 32, 0.5, 9009, 0.5},
			{"AddNpc", 3, 1, 0, "gw1", "guaiwu3", false, 32, 0.5, 9009, 0.5},
			{"AddNpc", 4, 1, 8, "sl", "shouling", false, 32, 0.5, 9009, 0.5},
			{"NpcBubbleTalk", "gw1", "膽兒挺肥啊，居然敢到這裡撒野！", 4, 1, 1},
			{"NpcBubbleTalk", "sl", "很好！最近正手癢呢！", 4, 1, 1},
			{"RaiseEvent", "PartnerSay", "此人是土匪頭目？", 3, 1},
		},
		tbUnLockEvent = 
		{
		},
	},
	[9] = {nTime = 2.1, nNum = 0,
		tbPrelock = {8},
		tbStartEvent = 
		{
			{"DoDeath", "gw"},
			{"DoDeath", "gw1"},
			{"SetGameWorldScale", 0.1},		-- 慢镜头开始
		},
		tbUnLockEvent = 
		{
			{"SetGameWorldScale", 1},		-- 慢镜头结束
			{"GameWin"},
		},
	},
}