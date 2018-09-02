

BossLeader.nMJHonorID = 1394; --名将令
BossLeader.nItemAwardValueParam = 50; --道具奖励系数

BossLeader.nShowMaxRank = 3;
BossLeader.nBaoDiAwardValue = 80000;
BossLeader.nFirstLastDmgMJHPPercent = 10; --首摸和最后一击额外血量百分比
BossLeader.nHPPercentParam = 1 / 1.2; -- 血量的百分比参数
BossLeader.nMinHPPercent = 1; --最少血量百分比
BossLeader.tbComboSkillCount = {[20] = 1, [30] = 1, [40] = 1, [50] = 1, [60] = 1, [70] = 1, [80] = 1, [90] = 1, [100] = 1}; --连斩数

BossLeader.tbTimePlayerValue = --一轮一个参加玩家的价值量
{
    ["OpenLevel39"] = 20000000;
    ["OpenDay89"] = 30000000;
};

BossLeader.tbKinDmgRankValue =
{
    ["OpenLevel39"] =
    {
        [-1] = 
        {
            ["Boss"] = 
            {
                [1] = 400000000;
                [2] = 400000000;
                [3] = 400000000;
                [4] = 400000000;
                [5] = 400000000;
            };
            ["FalseBoss"] =
            {
                [1] = 200000000;
                [2] = 200000000;
                [3] = 200000000;
                [4] = 200000000;
                [5] = 200000000;
            }
        };
        [1] =
        {
            ["Boss"] = 
            {
                [1] = 600000000;
                [2] = 600000000;
                [3] = 600000000;
                [4] = 600000000;
                [5] = 600000000;
            };
            ["FalseBoss"] =
            {
                [1] = 300000000;
                [2] = 300000000;
                [3] = 300000000;
                [4] = 300000000;
                [5] = 300000000;
            }
        };
    };

    ["OpenDay89"] =
    {
        [-1] = 
        {
            ["Boss"] = 
            {
                [1] = 400000000 * 1.5;
                [2] = 400000000 * 1.5;
                [3] = 400000000 * 1.5;
                [4] = 400000000 * 1.5;
                [5] = 400000000 * 1.5;
            };
            ["FalseBoss"] =
            {
                [1] = 200000000 * 1.5;
                [2] = 200000000 * 1.5;
                [3] = 200000000 * 1.5;
                [4] = 200000000 * 1.5;
                [5] = 200000000 * 1.5;
            }
        };
        [1] =
        {
            ["Boss"] = 
            {
                [1] = 600000000 * 1.5;
                [2] = 600000000 * 1.5;
                [3] = 600000000 * 1.5;
                [4] = 600000000 * 1.5;
                [5] = 600000000 * 1.5;
            };
            ["FalseBoss"] =
            {
                [1] = 300000000 * 1.5;
                [2] = 300000000 * 1.5;
                [3] = 300000000 * 1.5;
                [4] = 300000000 * 1.5;
                [5] = 300000000 * 1.5;
            }
        };
    };

    ["OpenLevel119"] =
    {
        [-1] = 
        {
            ["Boss"] = 
            {
                [1] = 400000000 * 1.5;
                [2] = 400000000 * 1.5;
                [3] = 400000000 * 1.5;
                [4] = 400000000 * 1.5;
                [5] = 400000000 * 1.5;
            };
            ["FalseBoss"] =
            {
                [1] = 200000000 * 1.5;
                [2] = 200000000 * 1.5;
                [3] = 200000000 * 1.5;
                [4] = 200000000 * 1.5;
                [5] = 200000000 * 1.5;
            }
        };
        [1] =
        {
            ["Boss"] = 
            {
                [1] = 600000000 * 1.5;
                [2] = 600000000 * 1.5;
                [3] = 600000000 * 1.5;
                [4] = 600000000 * 1.5;
                [5] = 600000000 * 1.5;
            };
            ["FalseBoss"] =
            {
                [1] = 300000000 * 1.5;
                [2] = 300000000 * 1.5;
                [3] = 300000000 * 1.5;
                [4] = 300000000 * 1.5;
                [5] = 300000000 * 1.5;
            }
        };
        [2] =
        {
            ["Boss"] = 
            {
                [1] = 600000000 * 1.5;
                [2] = 600000000 * 1.5;
                [3] = 600000000 * 1.5;
                [4] = 600000000 * 1.5;
                [5] = 600000000 * 1.5;
            };
            ["FalseBoss"] =
            {
                [1] = 300000000 * 1.5;
                [2] = 300000000 * 1.5;
                [3] = 300000000 * 1.5;
                [4] = 300000000 * 1.5;
                [5] = 300000000 * 1.5;
            }
        };
    };
}

BossLeader.tbBaoDiKinAward =
{
    ["Boss"] = true;
};


BossLeader.tbSinglePlayerRank = --玩家单独排行奖励
{
    ["Leader"] = true;
}

BossLeader.tbKinAwardDesc =
{
    ["Boss"]   = "名將";
    ["Leader"] = "首領";
}


BossLeader.tbSendMailTxt = 
{
    ["Boss"] = "歷代名將獲得獎勵";
    ["Leader"] = "野外首領獲得獎勵";
}


BossLeader.tbJoinPrestige = --参加家族威望
{
    ["Boss"] = 0;
    ["Leader"] = 0;
}

BossLeader.tbDmgRankPrestige  = --伤害排行威望
{
    ["Boss"] = 
    {
        [1] = 50;
        [2] = 35;
        [3] = 25;
        [4] = 15;
        [5] = 10;

    };

    ["Leader"] = 
    {
        [1] = 0;
        [2] = 0;
        [3] = 0;
    };
}

BossLeader.tbTouchImitityTeam = --摸到增加亲密度
{
    ["Boss"]   = 30;
    ["Leader"] = 20;
};

BossLeader.tbKillImitityTeam = --杀死增加亲密度
{
    ["Boss"]   = 30;
    ["Leader"] = 30;
}

BossLeader.tbStartWorldNotice = 
{
    ["Boss"]   = "歷代名將現身江湖，各位大俠可前往挑戰！";
    ["Leader"] = "野外首領現身江湖，各位大俠可前往挑戰！";
}

BossLeader.tbEndWorldNotice = 
{
    ["Boss"]   = "歷代名將已經結束";
    ["Leader"] = "野外首領已經結束";
}

BossLeader.tbMapAllKillNotice =
{
    ["Leader"] = "%s的首領被全部擊敗！";
}

BossLeader.tbNpcKillNotice =
{
    ["Boss"] = "%s(真身)被%s的隊伍所擊敗";
}

BossLeader.tbWorldPreNotic = 
{
    ["Boss"] = "歷代名將即將出現，各位大俠可前往挑戰！";
}

BossLeader.tbMapBackNotic = 
{
    ["Boss"] = "你已進入名將藏身地圖，強制進入幫派PK模式";
}

BossLeader.tbFirstTouchAchievement = 
{
    ["Boss"]   = {szKey = "FieldBoss_1", nValue = 1},
    ["Leader"] = {szKey = "FieldLeader_1", nValue = 1},
}

BossLeader.nAchievementRank = 1;
BossLeader.tbKillNpcAchievementRank =
{
    ["Leader"] = {szKey = "FieldLeader_2", nValue = 1},
}

BossLeader.nAchievementKinRank = 1; 
BossLeader.tbKillKinAchievement = 
{
    ["Boss"]   = {szKey = "FieldBoss_2", nValue = 1},
}

--每日目标
BossLeader.tbEveryDayTarget = 
{
    ["Boss"] = "FieldBoss";
}
