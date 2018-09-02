Require("CommonScript/Fuben/IdiomsFubenCommon.lua");
local tbFubenSetting = {};
local nMapTemplateId = IdiomFuben.nFubenMapTemplateId

Fuben:SetFubenSetting(nMapTemplateId, tbFubenSetting)   -- 绑定副本内容和地图

tbFubenSetting.szFubenClass   = IdiomFuben.szFubenClass;                                  -- 副本类型
tbFubenSetting.szName         = "成語接龍"                                               -- 单纯的名字，后台输出或统计使用
tbFubenSetting.tbBeginPoint   = {4195, 4033}  
tbFubenSetting.tbTempRevivePoint = {4195, 4033}  

-- ID可以随便 普通副本NPC数量 ；精英模式NPC数量
tbFubenSetting.NUM = 
{
    
}

tbFubenSetting.ANIMATION = 
{
   
}

--NPC模版ID，NPC等级，NPC五行；
--[[

]]

tbFubenSetting.NPC = 
{
    
}

-- ChangeRoomState              更改房间title
--                              参数：nFloor 层, nRoomIdx 房间序列, szTitile 标题, nX, nY自动寻路点坐标, bKillBoss 是否杀死了BOSS
--                              示例：{"AddNpc", "NpcIndex2", "NpcNum2", 3, "Test1", "NpcPos2", true, 30, 2, 206, 1},

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
        },
    },
    [2] = {nTime = 0, nNum = 0,
        tbPrelock = {1},
        tbStartEvent = 
        {
            {"BlackMsg", "開始成語接龍"},
            {"SetShowTime", 100},
            {"ChangeFightState", 1},
            {"RaiseEvent", "CallIdiomNpc"},
			{"SetFubenProgress", -1, "擊敗小怪,名字接龍"},
        },
        tbUnLockEvent = 
        {
        },
    },

    [100] = {nTime = 60*5, nNum = 0,
        tbPrelock = {1},
        tbStartEvent = 
        {
        },
        tbUnLockEvent = 
        {
            {"GameWin"},
			{"BlackMsg", "時間已到，挑戰結束！"},
			{"SetFubenProgress", -1, "挑戰結束"},
            {"SetShowTime", IdiomFuben.KICK_TIME},

        },
    },
}