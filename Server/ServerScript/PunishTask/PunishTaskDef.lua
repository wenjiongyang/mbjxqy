
PunishTask.szDegreeName = "PunishTask";


PunishTask.nMinTeamCount   = 1; --最少队伍人数
PunishTask.nMinPlayerLevel = 22; --最小玩家等级
PunishTask.nMinDistance    = 1000; --最少距离
PunishTask.nBuyActivityCount = 5; --购买活动的次数
PunishTask.tbWhiteRefresh = {2 * 3600, 10 * 3600}; --区间白色大盗不会重新刷新
PunishTask.nPerWhiteRefresh = 7200; --每多少秒白色大盗重新刷新一遍
PunishTask.tbAttackRebirthTime = --被击杀后一段时间重生
{
    [1] = 
    {
        tbTime = {10 * 3600, 24 * 3600};
        nRebirthTime = 3 * 60; --重生的时间
    };

    [2] = 
    {
        tbTime = {0, 2 * 3600};
        nRebirthTime = 3 * 60; --重生的时间
    };

    [3] = 
    {
        tbTime = {2 * 3600, 10 * 3600};
        nRebirthTime = 10 * 60; --重生的时间
    };
};

PunishTask.nNotDeathRebirthTime = 5 * 60; --没有死亡重生时间
