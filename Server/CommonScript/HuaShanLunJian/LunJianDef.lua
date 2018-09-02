
HuaShanLunJian.tbDef = HuaShanLunJian.tbDef or {};

local tbDef = HuaShanLunJian.tbDef;
tbDef.nPlayStateNone = 0; --赛季的状态没有
tbDef.nPlayStatePrepare = 1; --赛季的状态预选赛
tbDef.nPlayStateFinals = 2; --赛季的状态决赛
tbDef.nPlayStateEnd = 3; --赛季的状态结束
tbDef.nPlayStateMail = 4; --赛季的状态开始发邮件

tbDef.nPlayGameStateNone = 1; --比赛没有
tbDef.nPlayGameStateStart = 2; --比赛开始
tbDef.nPlayGameStateEnd   = 3; --比赛结束

tbDef.nSaveGroupID = 103; --保存的Group
tbDef.nSaveMonth   = 1; --保存月
tbDef.nSaveFightTeamID  = 2; --保存战队
tbDef.nSaveFightTeamTime = 3; --创建战队的时间

tbDef.nSaveGuessGroupID = 105; --保存竞猜的Group
tbDef.nSaveGuessVer = 1; --保存竞猜的版本
tbDef.nSaveGuessTeam = 2; --保存竞猜的队伍
tbDef.nSaveGuessOneNote = 3; --保存竞猜的注数

tbDef.nSaveHonorGroupID = 110; --保存荣誉
tbDef.nSaveHonorValue   = 1; --保存荣誉值

tbDef.nTeamTypeName   = 1; --战队的名称
tbDef.nTeamTypePlayer = 2; --战队的成员
tbDef.nTeamTypeValue  = 3; --战队的参加的值 积分 * 100 * 100 + 胜利场数 * 100 + 总共场数
tbDef.nTeamTypeTime   = 4; --战队的参加的时间
tbDef.nTeamTypePlayDay   = 5; --战队的天的时间
tbDef.nTeamTypePerCount   = 6; --战队的每天的次数
tbDef.nTeamTypeServerIdx = 7; --战队的服务器索引，只在武林大会中用到 --前20强, 因为要传回本服时设置新的队伍id，所以还是设值的
tbDef.nTeamTypeServerName = 8; --战队的服务器名，只在武林大会中用到 --前20强
tbDef.nTeamTypeRank = 9; --战队的排名，跨服上排一次存回本服 武林大会用 

tbDef.nPrePlayTotalTime = 100000; --设置一个最大的时间 

tbDef.nMaxFightTeamVer     = 10000; --最大版本号
tbDef.nMaxFightTeamCount   = 500; --最大战队数
tbDef.nUpateDmgTime        = 2;


tbDef.nGuessTypeTeam    = 1; --竞猜的战队
tbDef.nGuessTypeOneNote = 2; --竞猜的注数
tbDef.nSaveGuessingCount = 1500; --保存玩家竞猜数
tbDef.nMaxGuessingVer    = 1000; --保存最大竞猜数版本

tbDef.nNextPreGamePreMap  = 2; --使用完准备场数加载数
tbDef.nPreGamePreMapTime  = 5; --重新创建地图的时间




-------下面策划填写 ----------------------------------------
tbDef.szRankBoard      = "LunJianRank";
tbDef.szOpenTimeFrame = "HuaShanLunJian"; --开启时间轴
tbDef.fPlayerToNpcDmg = 0.1; --玩家对Npc的伤害占得比例
tbDef.nGameMaxRank    = 1002; --最大排行
tbDef.nMinPlayerLevel = 60; --最小等级开启
tbDef.nFightTeamNameMin = 3; --战队长度最小
tbDef.nFightTeamNameMax = 6; --战队长度最大

if version_vn then
tbDef.bStringLenName = true;
tbDef.nFightTeamNameMin = 4; --越南战队长度最小
tbDef.nFightTeamNameMax = 14; --越南战队长度最大
end

if version_th then
tbDef.nFightTeamNameMin = 6;
tbDef.nFightTeamNameMax = 10;
end    

tbDef.nFightTeamJoinMemebr = 2; --组入队员 两人单独组队

tbDef.nDeathSkillState = 1520; --死亡后状态
tbDef.nPartnerFightPos = 1; --伙伴的出战位置
tbDef.nHSLJCrateLimitTime = 4 * 3600;
tbDef.nChampionshipNewTime = 15 * 60 * 60 * 24;
tbDef.nHSLJHonorBox = 2000; --多少荣誉一个宝箱
tbDef.nHSLJHonorBoxItem = 2853; --荣誉宝箱ID

tbDef.nFightTeamShowTitle = 
{
    [1] = 7006;
    [2] = 7007;
};

tbDef.nStatueMapID = 10; --雕像的地图ID
tbDef.tbFactionStatueNpc = --门派雕像Npc
{
    [1] = 1886; --天王
    [2] = 1887; --峨嵋
    [3] = 1888; --桃花
    [4] = 1889; --逍遥
    [5] = 1890; --武当
    [6] = 1891; --天忍
    [7] = 1892; --少林
    [8] = 1893; --翠烟
    [9] = 2118;--唐门
    [10] = 2119;--昆仑
    [11] = 2221;--丐帮
    [12] = 2220;--五毒
    [13] = 2381;--藏剑
    [14] = 2382;--长歌
}

--赛制
tbDef.tbGameFormat =
{
    [1] = 
    {
        szName = "雙人賽";
        nFightTeamCount = 2; --战队的人数
        bOpenPartner = true; --是否开启同伴
        szOpenHSLJMail =
[[  武林盛會華山論劍開始了！
    本屆華山論劍為[FFFE0D]雙人賽[-]賽制，每人可攜帶一名同伴助陣。各位大俠請帶上自己的好友一起戰鬥，早日成為武林至尊！
    注意：華山論劍開始後，每週日的門派競技比賽將被其替代。
]];
        szHSLJPanelContent = --比赛面板介绍文字,需要能取到赛制信息
[[
[FFFE0D]本月華山論劍雙人賽開始了！[-]
    雙人賽限制戰隊成員為[FFFE0D]2名[-]，每人可攜帶一位同伴助戰。在準備場可以點擊[FFFE0D]隊伍[-]旁同伴頭像更換助戰同伴。
    預選賽開始每週可獲得[FFFE0D]16次[-]比賽次數，最多獲得[FFFE0D]32次[-]。每日最多參加[FFFE0D]6場[-]比賽。
    戰隊至少參加[FFFE0D]4場[-]預選賽，賽季結束才能獲得獎勵。
]];
        tbStatueInfo =  --雕像信息
        {
            nTitleID = 7004;
            tbAllPos = 
            {
                [1] = {11630, 15865, 0};
                [2] = {11079, 15330, 0};
                --[3] = {12200, 15323, 0};
                --[4] = {11620, 14723, 0};
            };
        };
    };

    [2] =
    {
        szName = "三人賽";
        nFightTeamCount = 3; --战队的人数
        bOpenPartner = true; --是否开启同伴
        szOpenHSLJMail =
[[  武林盛會華山論劍開始了！
    本屆華山論劍為[FFFE0D]三人賽[-]賽制，每人可攜帶一名同伴助陣。各位大俠請帶上自己的好友一起戰鬥，早日成為武林至尊！
    注意：華山論劍開始後，每週日的門派競技比賽將被其替代。
]];
        szHSLJPanelContent = --比赛面板介绍文字,需要能取到赛制信息
[[
[FFFE0D]本月華山論劍三人賽開始了！[-]
    三人賽限制戰隊成員為[FFFE0D]3名[-]，每人可攜帶一位同伴助戰。在準備場可以點擊[FFFE0D]隊伍[-]旁同伴頭像更換助戰同伴。
    預選賽開始每週可獲得[FFFE0D]16次[-]比賽次數，最多獲得[FFFE0D]32次[-]。每日最多參加[FFFE0D]6場[-]比賽。
    戰隊至少參加[FFFE0D]4場[-]預選賽，賽季結束才能獲得獎勵。
]];
        tbStatueInfo =  --雕像信息
        {
            nTitleID = 7004;
            tbAllPos = 
            {
                [1] = {11630, 15865, 0};
                [2] = {11079, 15330, 0};
                [3] = {12200, 15323, 0};
                --[4] = {11620, 14723, 0};
            };
        };
    };

    [3] =
    {
        szName = "三人決鬥賽";
        nFightTeamCount = 3; --战队的人数
        bOpenPartner = false; --是否开启同伴
        nPartnerPos  = 4; --上阵的同伴位置
        szPKClass = "PlayDuel"; --决斗赛的类别 新增赛季通知程序
        nFinalsMapCount = 3; --创建决赛地图数量
        szOpenHSLJMail =
[[  武林盛會華山論劍開始了！
    本屆華山論劍為[FFFE0D]三人決鬥[-]賽制，每人可攜帶所有已上陣同伴助陣。各位大俠請帶上自己的好友一起戰鬥，早日成為武林至尊！
    注意：華山論劍開始後，每週日的門派競技比賽將被其替代。
]];
        szHSLJPanelContent = --比赛面板介绍文字,需要能取到赛制信息
[[
[FFFE0D]本月華山論劍三人決鬥賽開始了！[-]
    三人決鬥賽限制戰隊成員為[FFFE0D]3名[-]，根據隊員編號與其他戰隊成員分別對戰，已上陣同伴均可助戰。
    預選賽開始每週可獲得[FFFE0D]16次[-]比賽次數，最多獲得[FFFE0D]32次[-]。每日最多參加[FFFE0D]6場[-]比賽。
    戰隊至少參加[FFFE0D]4場[-]預選賽，賽季結束才能獲得獎勵。
]];
        tbStatueInfo =  --雕像信息
        {
            nTitleID = 7004;
            tbAllPos = 
            {
                [1] = {11630, 15865, 0};
                [2] = {11079, 15330, 0};
                [3] = {12200, 15323, 0};
                --[4] = {11620, 14723, 0};
            };
        };
    };

    [4] =
    {
        szName = "單人賽";
        nFightTeamCount = 1; --战队的人数
        bOpenPartner = false; --是否开启同伴
        nPartnerPos  = 4; --上阵的同伴位置
        szOpenHSLJMail =
[[  武林盛會華山論劍開始了！
    本屆華山論劍為[FFFE0D]單人賽[-]賽制，每人可攜帶所有已上陣同伴助陣。各位大俠請踴躍參加，早日成為武林至尊！
    注意：華山論劍開始後，每週日的門派競技比賽將被其替代。
]];
        szHSLJPanelContent = --比赛面板介绍文字,需要能取到赛制信息
[[
[FFFE0D]本月華山論劍單人賽開始了！[-]
    單人賽限制戰隊成員為[FFFE0D]1名[-]，已上陣同伴均可助戰。
    預選賽開始每週可獲得[FFFE0D]16次[-]比賽次數，最多獲得[FFFE0D]32次[-]。每日最多參加[FFFE0D]6場[-]比賽。
    戰隊至少參加[FFFE0D]4場[-]預選賽，賽季結束才能獲得獎勵。
]];
        tbStatueInfo =  --雕像信息
        {
            nTitleID = 7004;
            tbAllPos = 
            {
                [1] = {11630, 15865, 0};
                --[2] = {11079, 15330, 0};
                --[3] = {12200, 15323, 0};
                --[4] = {11620, 14723, 0};
            };
        };
    };
};

tbDef.tbChangeGameFormat = --更换赛季:暂时关闭单人赛
{
    [4] = 1;
};

-- if version_tx then
--     tbDef.tbChangeGameFormat = --更换赛季
--     {
--         [3] = 4;
--     };
-- end

--冠军竞猜
tbDef.tbChampionGuessing =
{
    nMinLevel = 60; --最小等级
    nOneNoteGold  = 200; --猜中给多少钱
    nMaxOneNote   = 5; -- 最大投注数 废弃
    szAwardMail = "大俠，本次華山論劍冠軍為%s戰隊，您參加了本次華山論劍競猜並預測正確，獲得了%s元寶，請領取附件。";
};


--预选赛
tbDef.tbPrepareGame =
{
    szStartWorldNotify = "今日華山論劍將於3分鐘後開啟報名，請大家提前準備！";
    szPreOpenWorldMsg = "新一輪華山論劍預選賽開始報名了，時間3分鐘，請大家儘快通過活動日曆報名參加！";
    bShowMSgWhenEnterMatchTime = true; ---在每次等待下次匹配的时候都世界公告
    nStartMonthDay = 7; --每月开始几号
    nStartOpenTime = 10 * 3600; --每月开始几号的时间

    nPreGamePreMap    = 5; --开始加载准备场数
    
    nStartEndMonthDay = 15; --未超过本月几号开始活动
    nEndMothDay = 27;  --结束时间

    nMaxPlayerJoinCount = 32; --最大参加场数
    nPerWeekJoinCount = 16; --每周获得场数
    nWinJiFen = 3; --胜利积分
    nFailJiFen = 0; --失败积分
    nDogfallJiFen = 1; --平局积分

    nPrepareTime = 180; --准备时间秒
    nPlayGameTime = 150; --比赛时间秒
    nFreeGameTime = 30; --间隔时间
    nKickOutTime = 3 * 60; --踢出去的时间
    nPlayerGameCount = 8; --每天中共开启次数
    nMatchMaxFindCount = 8; --向下寻找多少战队
    nPerDayJoinCount = 6; --每天参加多少次

    nDefWinPercent = 0.5; --默认胜率
    nPrepareMapTID = 1200; --准备场的地图
    nPlayMapTID = 1201; --比赛地图

    nMatchEmptyTime = 1.5 * 60; --轮空的时间
    tbPlayMapEnterPos = --进入比赛地图的位置
    {
        [1] = {1440, 2961};
        [2] = {3697, 2949};
    };

    nShowInfoPlayTeamTime = 8; --显示对阵图的时间
    nPlayDelayTime        = 3; --321延迟多么后开战
    nEndDelayLeaveMap     = 8; --结束延迟多少秒离开地图
    nMaxEnterTeamCount    = 50; --最多进入战队数

    tbAllAward =  --奖励
    {
        tbWin = --赢
        {
            {"BasicExp", 15};
            {"item", 2424, 2};
        };

        tbDogfall = --平
        {
            {"BasicExp", 10};
            {"item", 2424, 1};
        };

        tbFail = --失败
        {
            {"BasicExp", 10};
            {"item", 2424, 1};
        };
    };

    tbAwardMail =
    {
        szWin = "恭喜閣下所在戰隊參加華山論劍預選賽，獲得了一場勝利，附件獎勵請查收！";
        szDogfall = "閣下所在戰隊參加華山論劍預選賽，與對手旗鼓相當，附件獎勵請查收！";
        szFail = "閣下所在戰隊參加華山論劍預選賽，遺憾敗北，附件獎勵請查收，以資鼓勵！";
    };
};


--决赛
tbDef.tbFinalsGame =
{
    szInformFinals = "恭喜少俠所在戰隊進入八強，成功晉級。決賽將於[FFFE0D]本月28日21：30[-]舉行，請準時參加！"; --八强邮件内容
    nMonthDay = 28; --决赛日期
    nFinalsMapTID = 1202; --决赛的地图
    nAudienceMinLevel = 20; --观众最少等级
    nEnterPlayerCount = 300; --进入观众的人数
    nFrontRank = 8; --前几名进入决赛
    nChampionPlan = 2; --冠军赛的对阵表
    nChampionWinCount = 2; --冠军赛最多赢多少场
    nShowInfoPlayTeamTime = 8; --显示对阵图的时间
    nPlayDelayTime = 3; --321延迟多少秒后PK
    nEndDelayLeaveMap  = 8; --结束延迟多少秒离开
    --tbPlayGameAward = {{"BasicExp", 8}};

    tbAgainstPlan = --对阵图
    {
        [8] = --8强
        {
            [1] = {tbIndex = {1, 8},  tbPos = { [1] = {1529, 6364}, [2] = {3643, 6346} } };
            [2] = {tbIndex = {4, 5},  tbPos = { [1] = {9104, 6291}, [2] = {11249, 6279} } };
            [3] = {tbIndex = {2, 7},  tbPos = { [1] = {2505, 3141}, [2] = {4671, 3141} } };
            [4] = {tbIndex = {3, 6},  tbPos = { [1] = {8617, 3277}, [2] = {10774, 3254} } };
        };

        [4] = --4强
        {
            [1] = {tbIndex = {1, 2}, tbPos = { [1] = {1529, 6364}, [2] = {3643, 6346} } };
            [2] = {tbIndex = {3, 4}, tbPos = { [1] = {9104, 6291}, [2] = {11249, 6279} } };
        };

        [2] = --2强
        {
            [1] = {tbIndex = {1, 2},  tbPos = { [1] = {5170, 9474}, [2] = {7765, 9420} } };
        };
    };

    --决赛状态
    tbPlayGameState =
    {
        [1]  = 
        {
            nNextTime = 180,
            szCall = "Freedom", 
            szRMsg = "比賽即將開始", 
            szWorld = "本屆華山論劍冠軍爭奪戰將在[FFFE0D]3分鐘[-]後開始，玩家可以進場支援心儀的參賽選手！";
        };
        [2]  = 
        {   
            nNextTime = 150, 
            szCall = "StartPK",  
            szRMsg = "八強賽進行中",
            szWorld = "本屆華山論劍[FFFE0D]八強賽[-]正式開始了！";
            nPlan = 8;
            tbTeamMsg = 
            {
                tbWin = 
                {
                    szMsg = "恭喜您的戰隊成功晉級華山論劍半決賽！";
                    szKinMsg = "恭喜幫派成員「%s」所在戰隊成功晉級華山論劍半決賽！";
                    szFriend = "恭喜您的好友「%s」所在戰隊成功晉級華山論劍半決賽！";
                };
                tbFail =
                {
                    szMsg = "您的戰隊失利了，沒能進入半決賽，再接再厲！";
                };
            };
        };
        [3]  = 
        {
            nNextTime = 60, 
            szCall = "StopPK", 
            szRMsg = "半決賽即將開始";
            --szWorld = "本届华山论剑半决赛将在[FFFE0D]30秒[-]后开始，请大家进场观战并支持心仪的选手！";

        };
        [4]  = 
        {
            nNextTime = 150, 
            szCall = "StartPK",
            szRMsg = "半決賽進行中",
            nPlan = 4;
            szWorld = "本屆華山論劍[FFFE0D]半決賽[-]開始了！";
            szEndWorldNotify = "恭喜%s成功晉級本屆華山論劍決賽，將在華山之巔一決雌雄！";
            tbTeamMsg = 
            {
                tbWin = 
                {
                    szMsg = "恭喜您的戰隊成功晉級華山論劍決賽！";
                    szKinMsg = "恭喜幫派成員「%s」所在戰隊成功晉級華山論劍決賽，冠軍榮耀觸手可及！";
                    szFriend = "恭喜您的好友「%s」所在戰隊成功晉級華山論劍決賽，冠軍榮耀觸手可及！";
                };
                tbFail =
                {
                    szMsg = "您的戰隊失利了，沒能進入決賽，再接再厲！";
                };
            };

        };
        [5]  = 
        {
            nNextTime = 60, 
            szCall = "StopPK", 
            szRMsg = "決賽即將開始";
            --szWorld = "本届华山论剑决赛将在5分钟后开始，谁才是真正的强者？拭目以待！";
        };
        [6]  = 
        {
            nNextTime = 150, 
            szCall = "StartPK", 
            szRMsg = "第一場決賽進行中", 
            szWorld = "本屆華山論劍[FFFE0D]決賽第一場[-]開始了，頂尖高手強力碰撞！";
            nPlan = 2; 
        };
        [7]  = 
        {
            nNextTime = 60, 
            szCall = "StopPK", 
            szRMsg = "第二場決賽即將開始";
        };
        [8]  = 
        {
            nNextTime = 150, 
            szCall = "StartPK", 
            szRMsg = "第二場決賽進行中", 
            szWorld = "本屆華山論劍[FFFE0D]決賽第二場[-]開始了，冠軍或許就要產生了？！";
            nPlan = 2; 
        };
        [9]  = 
        {
            nNextTime = 60, 
            szCall = "StopPK", 
            szRMsg = "第三場決賽即將開始",
            bCanStop = true;
        };
        [10] = 
        {
            nNextTime = 150, 
            szCall = "StartPK", 
            szRMsg = "第三場決賽進行中",
            nPlan = 2;
            bCanStop = true;
            szWorld = "本屆華山論劍[FFFE0D]決賽最後一場[-]開始了，這真是宿命的對決！";

        };
        [11] = 
        {
            nNextTime = 60, 
            szCall = "StopPK", 
            szRMsg = "比賽結束";
        };
        [12] = 
        {
            nNextTime = 180, 
            szCall = "SendAward", 
            szRMsg = "離開場地";
        };
        [13] = 
        {
            nNextTime = 300, 
            szCall = "KickOutAllPlayer", 
            szRMsg = "離開場地",
        };
    };
}

tbDef.szEightRankMail =  --八强邮件给全服发
[[  本屆華山論劍[FFFE0D]八強[-]已經產生，將於[FFFE0D]本月28日21：30[-]舉行最終決賽，屆時大家可以進入決賽地圖觀戰。當前已經開啟[FFFE0D]冠軍競猜[-]活動，請查看最新消息相應介面！
]]