local tbFubenSetting = {};
Fuben:SetFubenSetting(6002, tbFubenSetting)

tbFubenSetting.szFubenClass 			= "PersonalFubenBase";									-- 副本类型
tbFubenSetting.szNpcPointFile 			= "Setting/Fuben/PersonalFuben/jm_2/NpcPos.tab"			-- NPC点
tbFubenSetting.tbBeginPoint 			= {3310, 4250}											-- 副本出生点
tbFubenSetting.nStartDir				= 48;

--NPC模版ID，NPC等级，NPC五行；
tbFubenSetting.NPC = 
{
	[1]  = {nTemplate = 2528,  nLevel = -1, nSeries = 0}, -- 恐惧
	[2]  = {nTemplate = 2529,  nLevel = -1, nSeries = 0}, -- 欲望
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
			{"BlackMsg", "重新探查密洞"},
		},
		--tbStartEvent 锁解开时的事件
		tbUnLockEvent = 
		{
			{"SetTargetPos", 2261, 4615},
		},
	},
	[2] = {nTime = 0, nNum = 1,
		tbPrelock = {1},
		tbStartEvent = 
		{
			{"TrapUnlock", "TrapLock1", 2},
		},
			tbUnLockEvent = 
		{
			{"BlackMsg", "空氣中突然蔓延出一陣詭異的氣氛"},
			{"AddNpc", 1, 1, 3, "boss1", "boss1", false, 0, 5, 9010, 1},
			{"AddNpc", 2, 1, 3, "boss2", "boss2", false, 0, 5, 9010, 1},
		},
	},
	[8] = {nTime = 1.5, nNum = 0,
		tbPrelock = {2},
		tbStartEvent = 
		{
		},
			tbUnLockEvent = 
		{
			{"PlayerBubbleTalk", "啊，我頭有點暈......"},
		},
	},
	[5] = {nTime = 7, nNum = 0,
		tbPrelock = {2},
		tbStartEvent = 
		{
		},
			tbUnLockEvent = 
		{
			{"PlayerBubbleTalk", "難道這就是我的心魔？"},
			{"SetFubenProgress", 50, "擊敗心魔"},
			{"NpcBubbleTalk", "boss1", "黑暗來了，害怕麼！", 4, 1, 1},
			{"NpcBubbleTalk", "boss2", "你不相信我嘛？", 4, 1, 1},
			{"NpcHpUnlock", "boss1", 4, 40},
			{"NpcHpUnlock", "boss2", 6, 40},
		},
	},
	[4] = {nTime = 0, nNum = 1,
		tbPrelock = {5},
		tbStartEvent = 
		{
		},
			tbUnLockEvent = 
		{
			{"NpcBubbleTalk", "boss1", "前路無數險阻，莫要再前進了啊！", 4, 1, 1},
		},
	},
	[6] = {nTime = 0, nNum = 1,
		tbPrelock = {5},
		tbStartEvent = 
		{
		},
			tbUnLockEvent = 
		{
			{"NpcBubbleTalk", "boss2", "跟隨自己內心的想法，吃喝玩樂豈不美哉？", 4, 1, 1},
		},
	},
	[3] = {nTime = 0, nNum = 2,
		tbPrelock = {2},
		tbStartEvent = 
		{
		},
			tbUnLockEvent = 
		{
			{"SetFubenProgress", 100, "戰勝心魔"},
			{"BlackMsg", "經過一番苦鬥終於戰勝了自己的心魔"},
		},
	},
	[7] = {nTime = 2.1, nNum = 0,
		tbPrelock = {3},
		tbStartEvent = 
		{
			{"SetGameWorldScale", 0.1},		-- 慢镜头开始
		},
		tbUnLockEvent = 
		{
			{"SetGameWorldScale", 1},		-- 慢镜头结束
			{"GameWin"},
		},
	},
	[18] = {nTime = 600, nNum = 0,
		tbPrelock = {1},
		tbStartEvent = 
		{
			{"RaiseEvent", "RegisterTimeoutLock"},
			{"SetShowTime", 18},
		},
		tbUnLockEvent = 
		{
			{"GameLost"},
		},
	},
}


