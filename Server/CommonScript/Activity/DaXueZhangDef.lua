

Activity.tbDaXueZhang = Activity.tbDaXueZhang or {}
local tbDaXueZhang = Activity.tbDaXueZhang;
tbDaXueZhang.tbDef = tbDaXueZhang.tbDef or {};

local tbDef = tbDaXueZhang.tbDef;
tbDef.nSaveGroup = 122;
tbDef.nSaveJoin = 1;
tbDef.nSaveJoinTime = 2;
tbDef.nSaveVersion = 6;

tbDef.nSaveHonor = 5; --保存的雪站荣誉

tbDef.nMaxTeamVS = 2; --队伍数
tbDef.nUpdateDmgTime = 2; --更新伤害的时间
tbDef.tbMatchingCount = --匹配规则
{
    [3] = {1};
    [2] = {2, 1};
    [1] = {1};
}

tbDef.nWinType = 1; --胜利的奖励类型
tbDef.nFailType = 2; --失败的奖励类型


--------------策划填写 --------------------------------------------
tbDef.nActivityVersion = 1; --活动的版本号 注意重新开启要加版本号
tbDef.nLimitLevel = 20; --最小等级
tbDef.nTeamCount  = 4; --一个队伍的人数

tbDef.nPrepareMapTID = 1700; --准备场地图的ID
tbDef.tbCanJoinMap = --能够参加活动的地图
{
    [10] = 1;
    [999] = 1;
};

tbDef.tbHonorInfo = --兑换荣誉 优先级从上到下
{
    {nNeed = 2000, nItemID = 3538};
    {nNeed = 1000, nItemID = 3537};
};

tbDef.tbPreMapState =  --准备场的的状态
{
    [1] = { nNextTime = 300, szCall = "Freedom", szRMsg = "等待打雪仗開始"};
    [2] = { nNextTime = 270, szCall = "StartPlay", szRMsg = "等待打雪仗開始"};
    [3] = { nNextTime = 270, szCall = "StartPlay", szRMsg = "等待打雪仗開始"};
    [4] = { nNextTime = 10, szCall = "StartPlay", szRMsg = "活動結束請離開"};
    [5] = { nNextTime = 10, szCall = "GameEnd", szRMsg = "離開場地"};
};

tbDef.nPlayMapTID = 1701; --PK地图的ID

tbDef.tbPlayerAward = --玩家的奖励
{
    tbWin = --胜利的奖励
    {
        tbRankAward =
        {
            [1] = 
            {
                {"BasicExp", 90};
                {"DXZHonor", 3000};
            };
            [2] = 
            {
                {"BasicExp", 75};
                {"DXZHonor", 2500};
            };
            [3] = 
            {
                {"BasicExp", 60};
                {"DXZHonor", 2000};
            };
            [4] = 
            {
                {"BasicExp", 45};
                {"DXZHonor", 1500};
            };
        };

        szMailContent = "恭喜閣下在剛剛結束的打雪仗比賽中，獲得了一場勝利，附件為獎勵請查收！";
        szMsg = "您的隊伍贏得了本次比賽！";
    };

    tbFail = --失败的奖励
    {
        tbRankAward =
        {
            [1] = 
            {
                {"BasicExp", 75};
                {"DXZHonor", 2500};
            };
            [2] = 
            {
                {"BasicExp", 60};
                {"DXZHonor", 2000};
            };
            [3] = 
            {
                {"BasicExp", 45};
                {"DXZHonor", 1500};
            };
            [4] = 
            {
                {"BasicExp", 30};
                {"DXZHonor", 1000};
            };
        };
        szMailContent = "閣下在剛剛結束的打雪仗比賽中，遺憾敗北，附件為獎勵請查收，以資鼓勵！";
        szMsg = "您失利了，再接再厲！";
    };
};

tbDef.nDogfallJiFen = 10; --平局的额外的积分
tbDef.szMatchEmpyMsg = "本輪輪空，沒有匹配到對手"; --轮空描述
tbDef.szPanelContent = [[打雪仗比賽
·活動時間：2016年12月24日~2017年1月3日
·單人或組隊報名後，變身為打雪仗的小孩，進入特殊地圖，進行隊伍間的扔雪球大戰。
·比賽共分三輪，給對手造成傷害能增加隊伍積分，結束時積分多的隊伍獲勝。
·戰場上會出現隨機的雪人、陷阱及神符，採集後能獲得強力技能，一定要善加利用。
·另外，還要注意躲避年獸放出的強力技能。
]];


tbDef.nPerDayAddCount = 1; --每天可以参加多少次
tbDef.nMaxJoinCount = 3; --最多可以参加多少次
tbDef.szTimeUpdateTime = "4:00"; --每天更新的时间

function tbDaXueZhang:GetDXZJoinCount(pPlayer)
    if MODULE_GAMESERVER then
        local nVersion = pPlayer.GetUserValue(tbDef.nSaveGroup, tbDef.nSaveVersion);
        if nVersion ~= tbDef.nActivityVersion and tbDaXueZhang.bHaveDXZ then
            pPlayer.SetUserValue(tbDef.nSaveGroup, tbDef.nSaveJoinTime, 0);
            pPlayer.SetUserValue(tbDef.nSaveGroup, tbDef.nSaveJoin, 0);
            pPlayer.SetUserValue(tbDef.nSaveGroup, tbDef.nSaveVersion, tbDef.nActivityVersion);
            Log("DaXueZhang GetDXZJoinCount nSaveVersion", pPlayer.dwID, tbDef.nActivityVersion);
        end    
    end
        
    local nTime           = GetTime();
    local nLastTime       = pPlayer.GetUserValue(tbDef.nSaveGroup, tbDef.nSaveJoinTime);
    local nParseTodayTime = Lib:ParseTodayTime(tbDef.szTimeUpdateTime);
    local nUpdateDay      = Lib:GetLocalDay((nTime - nParseTodayTime));
    local nUpdateLastDay  = 0;
    if nLastTime == 0 then
        nUpdateLastDay = nUpdateDay - 1;
    else
        nUpdateLastDay  = Lib:GetLocalDay((nLastTime - nParseTodayTime));    
    end

    local nJoin   = pPlayer.GetUserValue(tbDef.nSaveGroup, tbDef.nSaveJoin);
    local nAddDay = math.abs(nUpdateDay - nUpdateLastDay);
    if nAddDay == 0 then
        return nJoin;
    end

    if nJoin < tbDef.nMaxJoinCount then
        local nAddResiduTime = nAddDay * tbDef.nPerDayAddCount;
        nJoin = nJoin + nAddResiduTime;
        nJoin = math.min(nJoin, tbDef.nMaxJoinCount);
    end    

    if MODULE_GAMESERVER then
        pPlayer.SetUserValue(tbDef.nSaveGroup, tbDef.nSaveJoinTime, nTime);
        pPlayer.SetUserValue(tbDef.nSaveGroup, tbDef.nSaveJoin, nJoin);
    end
    
    return nJoin;     
end