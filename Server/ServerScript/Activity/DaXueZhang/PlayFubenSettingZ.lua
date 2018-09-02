
Require("CommonScript/Activity/DaXueZhangDef.lua");

local tbDaXueZhang = Activity.tbDaXueZhang;
local tbDef = tbDaXueZhang.tbDef;

local tbFubenSetting = {};
Fuben:SetFubenSetting(tbDef.nPlayMapTID, tbFubenSetting)       -- 绑定副本内容和地图

tbFubenSetting.szFubenClass             = "DaXueZhangFuben";                                  -- 副本类型
tbFubenSetting.szName                   = "打雪仗"                                            -- 单纯的名字，后台输出或统计使用
tbFubenSetting.szNpcPointFile           = "Setting/Fuben/Daxuezhang/NpcPos.tab"          -- NPC点
tbFubenSetting.szPathFile               = "Setting/Fuben/PersonalFuben/1_1/NpcPath.tab"         -- 寻路点
tbFubenSetting.tbBeginPoint             = {2747, 4732}    -- 副本出生点
tbFubenSetting.szDXZRandomBegin         = "begin";

-- ID可以随便 普通副本NPC数量 ；精英模式NPC数量
tbFubenSetting.NUM =
{
    NpcIndex1       = {1, 1},
}

tbFubenSetting.tbTeamPlayerState = --玩家变身Buff
{-- 队伍    男        女
    [1] = {[1] = 3394, [2] = 3395};
    [2] = {[1] = 3396, [2] = 3397};
};

tbFubenSetting.tbGatherNpcEvent = --采集Npc事件
{
    [2130] = {szEvent = "AddBuff", tbParam = {nSkillID = 3398, nLevel = 1, nTime = 30}};--雪人-金
    [2131] = {szEvent = "AddBuff", tbParam = {nSkillID = 3398, nLevel = 2, nTime = 30}};--雪人-木
    [2132] = {szEvent = "AddBuff", tbParam = {nSkillID = 3398, nLevel = 3, nTime = 30}};--雪人-水
    [2133] = {szEvent = "AddBuff", tbParam = {nSkillID = 3398, nLevel = 4, nTime = 30}};--雪人-火
    [2134] = {szEvent = "AddBuff", tbParam = {nSkillID = 3398, nLevel = 5, nTime = 30}};--雪人-土
    [2135] = {szEvent = "AddBuff", tbParam = {nSkillID = 3398, nLevel = 6, nTime = 30}};--雪人-蓝白

    [2136] = {szEvent = "CastSkill", tbParam = {nSkillID = 3373, nLevel = 1}};--陷阱-金
    [2137] = {szEvent = "CastSkill", tbParam = {nSkillID = 3375, nLevel = 1}};--陷阱-木
    [2138] = {szEvent = "CastSkill", tbParam = {nSkillID = 3377, nLevel = 1}};--陷阱-水
    [2139] = {szEvent = "CastSkill", tbParam = {nSkillID = 3379, nLevel = 1}};--陷阱-火
    [2140] = {szEvent = "CastSkill", tbParam = {nSkillID = 3383, nLevel = 1}};--陷阱-土

    [2141] = {szEvent = "AddBuff", tbParam = {nSkillID = 3370, nLevel = 1, nTime = 15}};--神符-雪影舞
    [2142] = {szEvent = "AddBuff", tbParam = {nSkillID = 3367, nLevel = 1, nTime = 15}};--神符-乘霜式
    [2143] = {szEvent = "AddBuff", tbParam = {nSkillID = 3366, nLevel = 20, nTime = 15}};--神符-踏冰诀
    [2144] = {szEvent = "AddBuff", tbParam = {nSkillID = 3371, nLevel = 1, nTime = 10}};--神符-坚冰御
};

tbFubenSetting.TotalNpcRate = 100; --随机总概率
--NPC模版ID，NPC等级，NPC五行；
tbFubenSetting.NPC = 
{
    [1] = {nTemplate = 2130, nLevel = -1, nSeries = -1, nDir = 56, nRate = 12},  --雪人-金
    [2] = {nTemplate = 2131, nLevel = -1, nSeries = -1, nDir = 56, nRate = 14},  --雪人-木
    [3] = {nTemplate = 2132, nLevel = -1, nSeries = -1, nDir = 56, nRate = 14},  --雪人-水
    [4] = {nTemplate = 2133, nLevel = -1, nSeries = -1, nDir = 56, nRate = 14},  --雪人-火
    [5] = {nTemplate = 2134, nLevel = -1, nSeries = -1, nDir = 56, nRate = 14},  --雪人-土
    [6] = {nTemplate = 2135, nLevel = -1, nSeries = -1, nDir = 56, nRate = 12},  --雪人-蓝白

    [7] = {nTemplate = 2136, nLevel = -1, nSeries = -1, nDir = 56, nRate = 2},  --陷阱-金
    [8] = {nTemplate = 2137, nLevel = -1, nSeries = -1, nDir = 56, nRate = 2},  --陷阱-木
    [9] = {nTemplate = 2138, nLevel = -1, nSeries = -1, nDir = 56, nRate = 2},  --陷阱-水
    [10] = {nTemplate = 2139, nLevel = -1, nSeries = -1, nDir = 56, nRate = 2},  --陷阱-火
    [11] = {nTemplate = 2140, nLevel = -1, nSeries = -1, nDir = 56, nRate = 2},  --陷阱-土

    [12] = {nTemplate = 2141, nLevel = -1, nSeries = -1, nDir = 56, nRate = 3},  --神符-雪影舞
    [13] = {nTemplate = 2142, nLevel = -1, nSeries = -1, nDir = 56, nRate = 2},  --神符-乘霜式
    [14] = {nTemplate = 2143, nLevel = -1, nSeries = -1, nDir = 56, nRate = 3},  --神符-踏冰诀
    [15] = {nTemplate = 2144, nLevel = -1, nSeries = -1, nDir = 56, nRate = 2},  --神符-坚冰御

    [16] = {nTemplate = 2125, nLevel = -1, nSeries = -1, nDir = 32, nRate = 0},  --年兽
    [17] = {nTemplate = 2150, nLevel = -1, nSeries = -1, nDir = 32, nRate = 0},  --年兽-隐藏
}

tbFubenSetting.LOCK = 
{
    -- 1号锁不能不填，默认1号为起始锁，nTime是到时间自动解锁，nNum表示需要解锁的次数，如填3表示需要被解锁3次才算真正解锁，可以配置字符串
    [1] = {nTime = 10, nNum = 0,
        --tbPrelock 前置锁，激活锁的必要条件{1 , 2, {3, 4}}，代表1和2号必须解锁，3和4任意解锁一个即可
        tbPrelock = {},
        --tbStartEvent 锁激活时的事件
        tbStartEvent = 
        {
            {"RaiseEvent", "ShowPlayTime", 1, "等待開始:"},
        },
        --tbStartEvent 锁解开时的事件
        tbUnLockEvent = 
        {  
        },
    },
    [2] = {nTime = 3, nNum = 0,
        tbPrelock = {1},
        tbStartEvent = 
        { 
            {"OpenWindow", "ReadyGo"},
            {"BlackMsg", "打雪仗即將開始，共比賽[FFFE0D]3輪[-]！"},
        },
        tbUnLockEvent = 
        {
            {"AddNpc", 17, 1, 0, "Hide", "nianshou", false, 32, 0, 0, 0},--隐藏npc
        },
    },
    ----------------------------第一阶段-----------------------------
    [3] = {nTime = 150, nNum = 0,
        tbPrelock = {2},
        tbStartEvent = 
        { 
            {"ChangeFightState", 1}; --开始比赛
            {"RaiseEvent", "ShowPlayTime", 3, "第一輪:"},
            -- 设置更新采集Npc  nNum, nLock, szGroup, szPointName, bRevive, nUpdateTime, nDelayTime
            {"RaiseEvent", "RandomAddGatherNpc", 10, 0, "GatherNpc", "NpcPos", false, 20, 10},
        },
        tbUnLockEvent = 
        {
        },
    },
    [4] = {nTime = 120, nNum = 0,--年兽计时
        tbPrelock = {2},
        tbStartEvent = 
        {
        },
        tbUnLockEvent = 
        {
        },
    },
    [5] = {nTime = 1, nNum = 0,
        tbPrelock = {4},
        tbStartEvent = 
        { 
            {"AddNpc", 16, 1, 0, "NS", "nianshou", false, 32, 0, 9010, 0.5},
            {"BlackMsg", "年獸出現了，小心！！"},
            {"NpcBubbleTalk", "NS", "大膽頑童，無端打鬧，擾吾清夢！", 4, 1, 1},
        },
        tbUnLockEvent = 
        {
        },
    },
    [6] = {nTime = 5, nNum = 0,
        tbPrelock = {5},
        tbStartEvent = 
        { 
            {"RaiseEvent", "PlayerToPos", "nianshou"}, --集中到某个点
            {"CastSkill", "Hide", 3386, 1, -1, -1},
            {"StartTimeCycle", "cycle_1", 1.5, 1, {"CastSkill", "Hide", 3386, 1, -1, -1}, {"DoCommonAct", "NS", 16, 0, 1, 0}},
        },
        tbUnLockEvent = 
        {
            {"CloseCycle", "cycle_1"},
        },
    },
    [7] = {nTime = 1, nNum = 0,
        tbPrelock = {6},
        tbStartEvent = 
        { 
            {"DelNpc", "NS"},
            {"BlackMsg", "[FFFE0D]年獸大喊:[-]別再鬧了，我要睡覺！"},
        },
        tbUnLockEvent = 
        {
        },
    },

    [8] = {nTime = 30, nNum = 0,    --休息阶段1
        tbPrelock = {3},
        tbStartEvent = 
        {
            {"RaiseEvent", "ShowPlayTime", 8, "休息階段:"},
            {"ChangeFightState", 0}; --暂停比赛
            {"RaiseEvent", "CloseRandomGatherNpc", "GatherNpc"}, --关闭更新Npc
            {"DelNpc", "GatherNpc"},--删除采集npc
            {"BlackMsg", "休息階段，暫停比賽！"},
        },
        tbUnLockEvent = 
        {
        },
    },
    [9] = {nTime = 3, nNum = 0,
        tbPrelock = {8},
        tbStartEvent = 
        { 
            {"OpenWindow", "ReadyGo"},
            {"BlackMsg", "下一輪打雪仗即將開始，共比賽[FFFE0D]3輪[-]！"},
        },
        tbUnLockEvent = 
        {
        },
    },
    ----------------------------第二阶段-----------------------------
    [11] = {nTime = 150, nNum = 0,
        tbPrelock = {9},
        tbStartEvent = 
        { 
            {"ChangeFightState", 1}; --开始比赛
            {"RaiseEvent", "ShowPlayTime", 11, "第二輪:"},
            -- 设置更新采集Npc  nNum, nLock, szGroup, szPointName, bRevive, nUpdateTime, nDelayTime
            {"RaiseEvent", "RandomAddGatherNpc", 10, 0, "GatherNpc", "NpcPos", false, 20, 10},
        },
        tbUnLockEvent = 
        {
        },
    },
    [12] = {nTime = 120, nNum = 0,--年兽计时
        tbPrelock = {9},
        tbStartEvent = 
        {
        },
        tbUnLockEvent = 
        {
        },
    },
    [13] = {nTime = 1, nNum = 0,
        tbPrelock = {12},
        tbStartEvent = 
        { 
            {"AddNpc", 16, 1, 0, "NS", "nianshou", false, 32, 0, 9010, 0.5},
            {"BlackMsg", "年獸出現了，小心！！"},
            {"NpcBubbleTalk", "NS", "大膽頑童，無端打鬧，擾吾清夢！", 4, 1, 1},
        },
        tbUnLockEvent = 
        {
        },
    },
    [14] = {nTime = 5, nNum = 0,
        tbPrelock = {13},
        tbStartEvent = 
        { 
            {"RaiseEvent", "PlayerToPos", "nianshou"}, --集中到某个点
            {"CastSkill", "Hide", 3386, 1, -1, -1},
            {"StartTimeCycle", "cycle_1", 1.5, 1, {"CastSkill", "Hide", 3386, 1, -1, -1}, {"DoCommonAct", "NS", 16, 0, 1, 0}},
        },
        tbUnLockEvent = 
        {
            {"CloseCycle", "cycle_1"},
        },
    },
    [15] = {nTime = 1, nNum = 0,
        tbPrelock = {14},
        tbStartEvent = 
        { 
            {"DelNpc", "NS"},
            {"BlackMsg", "[FFFE0D]年獸大喊:[-]別再鬧了，我要睡覺！"},
        },
        tbUnLockEvent = 
        {
        },
    },

    [16] = {nTime = 30, nNum = 0,    --休息阶段2
        tbPrelock = {11},
        tbStartEvent = 
        {
            {"RaiseEvent", "ShowPlayTime", 16, "休息階段:"},
            {"ChangeFightState", 0}; --暂停比赛
            {"RaiseEvent", "CloseRandomGatherNpc", "GatherNpc"}, --关闭更新Npc
            {"DelNpc", "GatherNpc"},--删除采集npc
            {"BlackMsg", "休息階段，暫停比賽！"},
        },
        tbUnLockEvent = 
        {
        },
    },
    [17] = {nTime = 3, nNum = 0,
        tbPrelock = {16},
        tbStartEvent = 
        { 
            {"OpenWindow", "ReadyGo"},
            {"BlackMsg", "下一輪打雪仗即將開始，共比賽[FFFE0D]3輪[-]！"},
        },
        tbUnLockEvent = 
        {
        },
    },
    ----------------------------第三阶段-----------------------------
    [18] = {nTime = 150, nNum = 0,
        tbPrelock = {17},
        tbStartEvent = 
        { 
            {"ChangeFightState", 1}; --开始比赛
            {"RaiseEvent", "ShowPlayTime", 18, "最終輪:"},
            -- 设置更新采集Npc  nNum, nLock, szGroup, szPointName, bRevive, nUpdateTime, nDelayTime
            {"RaiseEvent", "RandomAddGatherNpc", 10, 0, "GatherNpc", "NpcPos", false, 20, 10},
        },
        tbUnLockEvent = 
        {
        },
    },
    [19] = {nTime = 120, nNum = 0,--年兽计时
        tbPrelock = {17},
        tbStartEvent = 
        {
        },
        tbUnLockEvent = 
        {
        },
    },
    [20] = {nTime = 1, nNum = 0,
        tbPrelock = {19},
        tbStartEvent = 
        { 
            {"AddNpc", 16, 1, 0, "NS", "nianshou", false, 32, 0, 9010, 0.5},
            {"BlackMsg", "年獸出現了，小心！！"},
            {"NpcBubbleTalk", "NS", "大膽頑童，無端打鬧，擾吾清夢！", 4, 1, 1},
        },
        tbUnLockEvent = 
        {
        },
    },
    [21] = {nTime = 5, nNum = 0,
        tbPrelock = {20},
        tbStartEvent = 
        { 
            {"RaiseEvent", "PlayerToPos", "nianshou"}, --集中到某个点
            {"CastSkill", "Hide", 3386, 1, -1, -1},
            {"StartTimeCycle", "cycle_1", 1.5, 1, {"CastSkill", "Hide", 3386, 1, -1, -1}, {"DoCommonAct", "NS", 16, 0, 1, 0}},
        },
        tbUnLockEvent = 
        {
            {"CloseCycle", "cycle_1"},
        },
    },
    [22] = {nTime = 1, nNum = 0,
        tbPrelock = {21},
        tbStartEvent = 
        { 
            {"DelNpc", "NS"},
            {"BlackMsg", "[FFFE0D]年獸大喊:[-]別再鬧了，我要睡覺！"},
        },
        tbUnLockEvent = 
        {
        },
    },

    [23] = {nTime = 3, nNum = 0,    --结束阶段
        tbPrelock = {18},
        tbStartEvent = 
        {
            {"RaiseEvent", "ShowPlayTime", 23, "比賽結束:"},
            {"ChangeFightState", 0}; --暂停比赛
            {"RaiseEvent", "CloseRandomGatherNpc", "GatherNpc"}, --关闭更新Npc
            {"DelNpc", "GatherNpc"},--删除采集npc
            {"BlackMsg", "打雪仗結束了，稍候片刻將離開賽場！"},
        },
        tbUnLockEvent = 
        {
        },
    },
    [24] = {nTime = 10, nNum = 0,
        tbPrelock = {23},
        tbStartEvent = 
        {
            {"RaiseEvent", "DXZPlayEnd"}, --游戏结束
            {"RaiseEvent", "ShowPlayTime", 24, "離開賽場:"},
        },
        tbUnLockEvent = 
        {
            {"RaiseEvent", "KickOutAllTeam"}, --踢出玩家
        },
    },
}