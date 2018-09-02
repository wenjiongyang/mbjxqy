WuLinDaHui.tbDef = {
	nMinPlayerLevel = 60; --参与比赛的最小等级
	nMaxFightTeamCount  = 100; --最大战队数,这样一个块最多就99个战队了， 因为有四人和多的变量，战队数从500减到100 同时方便id的设置
	nMaxFightTeamVer = 1000; --最大版本号--见到1000，就是最多100个scriptdata， 一次武林大会一个服不会超10w的
	nGameTypeInTeamId =  100000 ; -- =nMaxFightTeamVer * nMaxFightTeamCount
	nServerIdxInTeamId = 1000000;--因为是跨服的，要包含serverIdx --目前是不会超过1000的
    nMaxGuessingVer    = 1000; --保存最大竞猜数版本
    nSaveGuessingCount = 500; --保存玩家竞猜数

	--TODO ，代码测试战队id数是不会重的

	nPreGamePreMap = 1;--创建的准备场个数，跨服上就只建一个准备场图了
	nAutoTicketFightPowerRank = 100; --即报名开始时, 时本服战力排名前200的玩家获得参与武林大会的资格。
	nMaxTicketFightPowerRank = 200; --101-200需要买门派的

	nSellTicketGold = 300; --购买门票资格费用，元宝
	nPreMatchJoinCount = 12; --预选赛的参与次数

    tbNotifyMatchTime = { "15:42", "21:27" };--预告滚动条通知时间
    tbStartMatchTime = {"15:45", "21:30"}; --比赛开启时间
    tbEndMatchTime   = {"16:15", "22:00"}; --比赛结束时间 

    szFinalStartMatchTime = "21:30"; --决赛比赛开启时间
    szFinalEndMatchTime   = "22:00"; --决赛比赛结束时间 

	nMaxJoinTeamNum = 2; --同时最大参与的战队数量
	nDefWinPercent = 0.5; --默认胜率
	nPreRankSaveCount = 20; --初赛保留的战队信息数
    nClientRequestTeamDataInterval = 60; --客户端请求战队数据的时间间隔
    nClientRequestTeamDataIntervalInMap = 5; --在比赛地图内的请求战队数据间隔


    tbUiShowItemIds = { 6007, 6008, 6010, 6011, 6013, 6014, 5238, 6012 }; --界面里展示的道具Id
    nNewsInformationTimeLast = 3600*24*14; --最新消息的持续时间
    szNewsKeyNotify = "WLDHNews"; --武林大会的最新消息key
    szNewsContent = [[
      [eebb01]「武林大會」[-]是劍俠江湖最高級別的競技賽事，每個伺服器戰力排名[eebb01]前200[-]的玩家才有資格組成戰隊[eebb01]跨服[-]進行擂臺戰鬥，你可能面對從來也未見過的頂尖高手，最終的強者才能獲得無上的榮耀——“武林至尊”。
      大會共[eebb01]4[-]個賽制，分別為[eebb01]雙人賽[-]，[eebb01]三人賽[-]，[eebb01]三人決鬥賽[-]及[eebb01]四人賽[-]，每種賽制都將決出“[eebb01]武林至尊[-]”，每位俠士可以選擇參與其中的[eebb01]兩[-]種。

[eebb01]1、參與資格[-]
      在[eebb01]預告階段[-]結束時：
      等級達到60級，戰力排名達到[eebb01]前100[-]名的玩家，直接獲得參賽資格。
      等級達到60級，戰力排名為[eebb01]101名~200名[-]的玩家，需要花費300元寶購買[eebb01]門票[-]以獲得參賽資格。

[eebb01]2、賽制及時間[-]
      雙人賽、三人賽及三人決鬥賽的比賽規則與華山論劍活動一致。
      四人賽允許最多4名玩家組成戰隊，戰鬥時同伴無法助戰。
      [eebb01]比賽時間如下：[-]
      [eebb01]雙人賽[-]：初賽時間1月[eebb01]16[-]日15：45~16：15、21：30~22：00，決賽時間為1月[eebb01]20[-]日21：30~22：00。
      [eebb01]三人賽[-]：初賽時間1月[eebb01]17[-]日15：45~16：15、21：30~22：00，決賽時間為1月[eebb01]21[-]日21：30~22：00。
      [eebb01]三人決鬥賽[-]：初賽時間1月[eebb01]18[-]日15：45~16：15、21：30~22：00，決賽時間為1月[eebb01]22[-]日21：30~22：00。
      [eebb01]四人賽[-]：初賽時間1月[eebb01]19[-]日15：45~16：15、21：30~22：00，決賽時間為1月[eebb01]23[-]日21：30~22：00。

[eebb01]3、大會流程[-]
      武林大會分為如下幾個階段：
    [eebb01]預告階段[-]
      大會開始報名前，會預告一段時間，該[eebb01]階段結束[-]時會[eebb01]立即[-]產生具有參賽資格的俠士。
      所以想要參賽的俠士，若未達到參賽要求，請儘快提升自己的戰力排名。
    [eebb01]報名階段[-]
      具有參賽資格（或購買門票）的俠士，在這個階段內自行與[eebb01]本服[-]其他俠士組成戰隊，在武林大會的專屬介面報名各比賽。
      每位俠士最多參與[eebb01]2種[-]比賽，並且每個比賽可以有[eebb01]不同[-]的戰隊和隊友。
      階段結束後，[eebb01]不再允許創建戰隊[-]報名比賽，請各位大俠不要錯過時間！
    [eebb01]初賽階段[-]
      每種賽制的初賽僅進行[eebb01]一天[-]，15：45及21：30各開一輪，持續半小時，每3分鐘開始一場比賽，共開啟18場比賽。
      每個戰隊最多允許參加[eebb01]12[-]場比賽，最終初賽排名前[eebb01]16[-]的戰隊進入決賽階段。
    [eebb01]決賽階段[-]
      決賽會進行[eebb01]16進8[-]比賽、[eebb01]8進4[-]比賽、[eebb01]半決賽[-]各[eebb01]1[-]場，最終冠軍爭奪賽採取[eebb01]3局2勝[-]制。
      決賽時，玩家可以對最終冠軍進行[eebb01]競猜[-]，正確後可以獲得[eebb01]300元寶[-]獎勵。
    ]]; --最新消息里的内容
    szMailTextYuGao = "  大俠，江湖盛事武林大會即將開啟，獲得參與資格後可與知己好友組成戰隊與最頂尖的高手正面碰撞，登上擂臺向各路豪傑展示你們的英雄氣概吧！\n欲知詳情，請點擊前往[00ff00][url=openwnd:武林大會活動介面, WLDHJoinPanel][-]瞭解。";
    szMailTextGetTicket = "  大俠神功蓋世，武林盟一致同意[eebb01]直接邀請[-]閣下參與本屆武林大會，請與其他具有參與資格的俠士組隊前往[00ff00][url=openwnd:武林大會活動介面, WLDHJoinPanel][-]進行報名。";
    szMailTextBuyTicket = "  恭喜俠士的武功獲得武林盟的認可，閣下需要[eebb01]「門票」[-]來獲得參與武林大會的資格，請前往[00ff00][url=openwnd:武林大會活動介面, WLDHJoinPanel][-]購買。";

	SAVE_GROUP = 136; 
	SAVE_KEY_TicketTime = 1; --获取的门票时间, 大于等于报名时间的就是有资格
	SAVE_KEY_CanBuyTicketTime = 2; --能买门票的时间, 大于等于报名时间的就是有资格
}

local tbDef = WuLinDaHui.tbDef;

tbDef.tbPrepareGame = {
    szBeforeNotifyMsg = "【武林大會】[eebb01]%s初賽[-]將於[eebb01]3分鐘[-]後開始，請參賽選手提前準備！";
    szPreOpenWorldMsg = "【武林大會】[eebb01]%s初賽[-]開始了，首場比賽將於3分鐘後開始，請參賽選手儘快入場！";

    szWinNotifyInKin = "【武林大會】恭喜幫派成員[eebb01]%s[-]所在戰隊取得了一場[eebb01]%s初賽[-]勝利。";
    -- szWinNotifyInFriend = "【武林大会】您的好友[eebb01]%s[-]所在战队在刚刚结束的[eebb01]%s初赛[-]中取得了胜利。"

    nPreGamePreMap    = 1; --开始加载准备场数，跨服上就只建一个准备场图不能增加了
    nSynTopZoneTeamDataTimeDelay = 20; --每场比赛完最多20秒一次更新数据

    nWinJiFen = 3; --胜利积分
    nFailJiFen = 0; --失败积分
    nDogfallJiFen = 1; --平局积分

    nPrepareTime = 180; --准备时间秒
    nPlayGameTime = 150; --比赛时间秒
    nFreeGameTime = 30; --间隔时间
    nKickOutTime = 30; --踢出去的时间
    nPlayerGameCount = 9; --每天中共开启次数
    nMatchMaxFindCount = 8; --向下寻找多少战队
    nPerDayJoinCount = 12; --每天参加多少次

    nDefWinPercent = 0.5; --默认胜率
    nPrepareMapTID = 1302; --准备场的地图
    nPlayMapTID = 1303; --比赛地图

    nMatchEmptyTime = 1.5 * 60; --轮空的时间
    tbPlayMapEnterPos = --进入比赛地图的位置
    {
        [1] = {2752, 3213};
        [2] = {4665, 3213};
    };

    nShowInfoPlayTeamTime = 8; --显示对阵图的时间
    nPlayDelayTime        = 3; --321延迟多么后开战
    nEndDelayLeaveMap     = 8; --结束延迟多少秒离开地图

    tbAllAward = {};
};

--冠军竞猜
tbDef.tbChampionGuessing =
{
    nMinLevel = 60; --最小等级
    tbWinAward = {{"Gold", 300}};--猜中给的奖励
    szAwardMail = "大俠，本次武林大會%s冠軍為%s戰隊，您參加了本次武林大會競猜並預測正確，獲得了獎勵，請領取附件。";
};

--武林大会主界面的预告说明
-- tbDef.szYuGaoUiTexture = "UI/Textures/GrowInvest02.png"
tbDef.szYuGaoUiDesc = [[
      [eebb01]「武林大會」[-]是劍俠江湖最高級別的競技賽事，戰力排名[eebb01]前200[-]的玩家有資格組成戰隊[eebb01]跨服[-]進行擂臺戰鬥，最終的強者將獲得無上的榮耀——“武林至尊”。
      大會共[eebb01]4[-]個賽制，分別為[eebb01]雙人賽[-]，[eebb01]三人賽[-]，[eebb01]三人決鬥賽[-]及[eebb01]四人賽[-]，每種賽制都將決出“[eebb01]武林至尊[-]”，每位俠士可以選擇參與其中的[eebb01]兩[-]種。
      在[eebb01]預告階段[-]結束時：
      等級達到60級，戰力排名達到[eebb01]前100[-]名的玩家，直接獲得參賽資格。
      等級達到60級，戰力排名為[eebb01]101名~200名[-]的玩家，需要花費300元寶購買[eebb01]門票[-]以獲得參賽資格。
      大會詳情請查閱[eebb01]最新消息[-]相關頁面！
]]
tbDef.tbMatchUiDesc = 
{
	[1] = [[
雙人賽說明
雙人賽限制戰隊成員為[eebb01]2名[-]，每人可攜帶一位同伴助戰。在準備場可以點擊[eebb01]隊伍[-]旁同伴頭像更換助戰同伴。
	]];
	[2] = [[
三人賽說明
三人賽限制戰隊成員為[eebb01]3名[-]，每人可攜帶一位同伴助戰。在準備場可以點擊[eebb01]隊伍[-]旁同伴頭像更換助戰同伴。
	]];
	[3] = [[
三人決鬥人賽說明
三人決鬥賽限制戰隊成員為[eebb01]3名[-]，根據隊員編號與其他戰隊成員分別對戰，已上陣同伴均可助戰。
	]];
	[4] = [[
四人賽說明
四人賽限制戰隊成員為[eebb01]4名[-]，不允許攜帶同伴助戰。
	]];
}


WuLinDaHui.tbScheduleDay =  {
	[1]  = {
		nGameType = 1;
	};
	[2]  = {
		nGameType = 2;
	};
	[3]  = {
		nGameType = 3;
	};
	[4]  = {
		nGameType = 4;
	};
	[5]  = {
		nGameType = 1;
		bFinal = true;
	};
	[6]  = {
		nGameType = 2;
		bFinal = true;
	};
	[7]  = {
		nGameType = 3;
		bFinal = true;
	};
	[8]  = {
		nGameType = 4;
		bFinal = true;
	};
}

WuLinDaHui.tbGameFormat = {
	[1] = {
		szName = "雙人賽";
		nFightTeamCount = 2;
		bOpenPartner = true; --是否开启同伴
        szDescTip = "兩人組隊參賽"; --界面里的简短说明

	};
	[2] = {
		szName = "三人賽";
		nFightTeamCount = 3;
		bOpenPartner = true; --是否开启同伴
        szDescTip = "三人組隊參賽"; 

	};
	[3] = {
		szName = "三人決鬥賽";
		nFightTeamCount = 3;
		szPKClass = "PlayDuel";
		bOpenPartner = false; --是否开启同伴
        nPartnerPos = 4; --上阵同伴数
		nFinalsMapCount = 3; --会创建三个地图
        szDescTip = "三人組隊，按照編號分別對戰的比賽"; 

	};
	[4] = {
		szName = "四人賽";
		nFightTeamCount = 4;
		bOpenPartner = false; --是否开启同伴
        szDescTip = "四人組隊參賽"; 
	};
};


tbDef.tbFinalsGame =
{
    szBeforeNotifyMsg = "【武林大會】[eebb01]%s冠軍爭奪戰[-]將於[eebb01]3分鐘[-]後開始，玩家可以進場支援心儀的參賽選手！";

    nFinalsMapTID = 1304; --决赛的地图
    nAudienceMinLevel = 20; --观众最少等级
    nEnterPlayerCount = 600; --进入观众的人数
    nFrontRank = 16; --前几名进入决赛
    nChampionPlan = 2; --冠军赛的对阵表
    nChampionWinCount = 2; --冠军赛最多赢多少场
    nShowInfoPlayTeamTime = 8; --显示对阵图的时间
    nPlayDelayTime = 3; --321延迟多少秒后PK
    nEndDelayLeaveMap  = 8; --结束延迟多少秒离开
    --tbPlayGameAward = {{"BasicExp", 8}};

    tbAgainstPlan = --对阵图
    {
        [16] = --16强
        {
            [1] = {tbIndex = {1, 16},  tbPos = { [1] = {9337, 13474},  [2] = {11213, 13480} } };
            [2] = {tbIndex = {8, 9},   tbPos = { [1] = {13667, 13495}, [2] = {15542, 13482} } };
            [3] = {tbIndex = {5, 12},  tbPos = { [1] = {13682, 6310},  [2] = {15531, 6321} } };
            [4] = {tbIndex = {4, 13},  tbPos = { [1] = {9348, 6318},   [2] = {11187, 6307} } };
            [5] = {tbIndex = {2, 15},  tbPos = { [1] = {4944, 8026},   [2] = {6800, 8010} } };
            [6] = {tbIndex = {7, 10},  tbPos = { [1] = {4928, 11860},  [2] = {6799, 11854} } };
            [7] = {tbIndex = {6, 11},  tbPos = { [1] = {18108, 11889}, [2] = {19954, 11881} } };
            [8] = {tbIndex = {3, 14},  tbPos = { [1] = {18076, 8024},  [2] = {19956, 8022} } };
        };

        [8] = --8强
        {
            [1] = {tbIndex = {1, 2},  tbPos = { [1] = {9337, 13474},  [2] = {11213, 13480} } };
            [2] = {tbIndex = {3, 4},  tbPos = { [1] = {13667, 13495}, [2] = {15542, 13482} } };
            [3] = {tbIndex = {5, 6},  tbPos = { [1] = {13682, 6310},  [2] = {15531, 6321} } };
            [4] = {tbIndex = {7, 8},  tbPos = { [1] = {9348, 6318},   [2] = {11187, 6307} } };
        };

        [4] = --4强
        {
            [1] = {tbIndex = {1, 2},  tbPos = { [1] = {9337, 13474},  [2] = {11213, 13480} } };
            [2] = {tbIndex = {3, 4},  tbPos = { [1] = {13667, 13495}, [2] = {15542, 13482} } };
        };

        [2] = --2强
        {
            [1] = {tbIndex = {1, 2},  tbPos = { [1] = {11331, 10095}, [2] = {13594, 10064} } };
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
            szWorld = "【武林大會】[eebb01]%s[-]冠軍爭奪戰將在[eebb01]3分鐘[-]後開始，玩家可以進場支援心儀的參賽選手！";
        };
         [2]  = 
        {   
            nNextTime = 150, 
            szCall = "StartPK",  
            szRMsg = "十六強賽進行中",
            szWorld = "【武林大會】[eebb01]%s[-]十六強賽正式開始了！";
            nPlan = 16;
            tbTeamMsg = 
            {
                tbWin = 
                {
                    szMsg = "恭喜您的戰隊成功晉級武林大會八強賽！";
                    szKinMsg = "【武林大會】恭喜幫派成員[eebb01]%s[-]所在戰隊成功晉級[eebb01]%s[-]八強賽!";
                    szFriend = "【武林大會】恭喜您的好友[eebb01]%s[-]所在戰隊成功晉級[eebb01]%s[-]八強賽!";
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
            szRMsg = "八強賽即將開始";
            --szWorld = "本届武林大会半决赛将在[eebb01]30秒[-]后开始，请大家进场观战并支持心仪的选手！";

        };
        [4]  = 
        {   
            nNextTime = 150, 
            szCall = "StartPK",  
            szRMsg = "八強賽進行中",
            szWorld = "【武林大會】[eebb01]%s[-]八強賽正式開始了！";
            nPlan = 8;
            tbTeamMsg = 
            {
                tbWin = 
                {
                    szMsg = "恭喜您的戰隊成功晉級武林大會半決賽！";
                    szKinMsg = "【武林大會】恭喜幫派成員[eebb01]%s[-]所在戰隊成功晉級[eebb01]%s[-]半決賽！";
                    szFriend = "【武林大會】恭喜您的好友[eebb01]%s[-]所在戰隊成功晉級[eebb01]%s[-]半決賽！";
                };
                tbFail =
                {
                    szMsg = "您的戰隊失利了，沒能進入半決賽，再接再厲！";
                };
            };
        };
        [5]  = 
        {
            nNextTime = 60, 
            szCall = "StopPK", 
            szRMsg = "半決賽即將開始";
            --szWorld = "本届武林大会半决赛将在[eebb01]30秒[-]后开始，请大家进场观战并支持心仪的选手！";

        };
        [6]  = 
        {
            nNextTime = 150, 
            szCall = "StartPK",
            szRMsg = "半決賽進行中",
            nPlan = 4;
            szWorld = "【武林大會】[eebb01]%s[-]半決賽正式開始了！";
            szEndWorldNotify = "恭喜%s成功晉級本屆武林大會[eebb01]%s[-]決賽，將在決賽擂臺一決雌雄！";
            tbTeamMsg = 
            {
                tbWin = 
                {
                    szMsg = "恭喜您的戰隊成功晉級武林大會決賽！";
                    szKinMsg = "【武林大會】恭喜幫派成員[eebb01]%s[-]所在戰隊成功晉級[eebb01]%s[-]決賽，冠軍榮耀觸手可及！";
                    szFriend = "【武林大會】恭喜您的好友[eebb01]%s[-]所在戰隊成功晉級[eebb01]%s[-]決賽，冠軍榮耀觸手可及！";
                };
                tbFail =
                {
                    szMsg = "您的戰隊失利了，沒能進入決賽，再接再厲！";
                };
            };

        };
        [7]  = 
        {
            nNextTime = 60, 
            szCall = "StopPK", 
            szRMsg = "決賽即將開始";
            --szWorld = "本届武林大会决赛将在5分钟后开始，谁才是真正的强者？拭目以待！";
        };
        [8]  = 
        {
            nNextTime = 150, 
            szCall = "StartPK", 
            szRMsg = "第一場決賽進行中", 
            szWorld = "【武林大會】[eebb01]%s[-]決賽第一場開始了，頂尖高手強力碰撞！";
            nPlan = 2; 
        };
        [9]  = 
        {
            nNextTime = 60, 
            szCall = "StopPK", 
            szRMsg = "第二場決賽即將開始";
        };
        [10]  = 
        {
            nNextTime = 150, 
            szCall = "StartPK", 
            szRMsg = "第二場決賽進行中", 
            szWorld = "【武林大會】[eebb01]%s[-]決賽第二場開始了，冠軍或許就要產生了？！";
            nPlan = 2; 
        };
        [11]  = 
        {
            nNextTime = 60, 
            szCall = "StopPK", 
            szRMsg = "第三場決賽即將開始",
            bCanStop = true;
        };
        [12] = 
        {
            nNextTime = 150, 
            szCall = "StartPK", 
            szRMsg = "第三場決賽進行中",
            nPlan = 2;
            bCanStop = true;
            szWorld = "【武林大會】[eebb01]%s[-]決賽最後一場開始了，這真是宿命的對決！";
        };
        [13] = 
        {
            nNextTime = 60, 
            szCall = "StopPK", 
            szRMsg = "比賽結束";
        };
        [14] = 
        {
            nNextTime = 150, 
            szCall = "SendAward", 
            szRMsg = "離開場地";
        };
        [15] = 
        {
            nNextTime = 150, 
            szCall = "KickOutAllPlayer", 
            szRMsg = "離開場地",
        };
    };
};


function WuLinDaHui:GetMatchIndex(nPlan, nRank)
	local tbMathcInfo = tbDef.tbFinalsGame.tbAgainstPlan[ nPlan ]
	for i,v in ipairs(tbMathcInfo) do
		for i2,v2 in ipairs(v.tbIndex) do
			if nRank == v2 then
				return i2, i, #tbMathcInfo;
			end	
		end
	end
end

WuLinDaHui.szActNameYuGao = "WuLinDaHuiActYuGao"
WuLinDaHui.szActNameBaoMing = "WuLinDaHuiActBaoMing"
WuLinDaHui.szActNameMain = "WuLinDaHuiAct"

WuLinDaHui.nActYuGaoTime = 60;-- 活动开始到预告结束的时间


function WuLinDaHui:IsCanBuyTicket(pPlayer)
	local nActStartTime, nActEndTime = Activity:__GetActTimeInfo(WuLinDaHui.szActNameBaoMing)
	if not nActStartTime or nActStartTime == 0 then
		return false, "當前不是報名期"
	end

	local nSaveVal = pPlayer.GetUserValue(tbDef.SAVE_GROUP, tbDef.SAVE_KEY_TicketTime)
	if nSaveVal >= nActStartTime then
		return false, "您當前已經有門票了"
	end

	return pPlayer.GetUserValue(tbDef.SAVE_GROUP, tbDef.SAVE_KEY_CanBuyTicketTime) >= nActStartTime
end

function WuLinDaHui:IsCanSigUp(pPlayer)
	local nActStartTime, nActEndTime = Activity:__GetActTimeInfo(WuLinDaHui.szActNameBaoMing)
	if not nActStartTime or nActStartTime == 0 then
		return false, "當前不是報名期"
	end
	if pPlayer.GetUserValue(tbDef.SAVE_GROUP, tbDef.SAVE_KEY_TicketTime) < nActStartTime then
		return false, "無報名資格"
	end
	return  true
end

function WuLinDaHui:IsBaoMingAndMainActTime()
	local bIsAct = Activity:__IsActInProcessByType(self.szActNameBaoMing)
	if bIsAct then
		return true, self.szActNameBaoMing
	end
	bIsAct = Activity:__IsActInProcessByType(self.szActNameMain)
	if bIsAct then
		return true, self.szActNameMain
	end
end

function WuLinDaHui:IsInMap(nMapTemplateId)
    if self.tbDef.tbPrepareGame.nPrepareMapTID == nMapTemplateId or
          self.tbDef.tbPrepareGame.nPlayMapTID == nMapTemplateId or
          self.tbDef.tbFinalsGame.nFinalsMapTID == nMapTemplateId then
          return true
    end
    return false
end

function WuLinDaHui:GetToydayGameFormat()
    local nStartTime, nEndTime = Activity:__GetActTimeInfo(self.szActNameMain)
    if not nStartTime then
        return
    end

    local nToday = Lib:GetLocalDay()
    local nOpenActDay = Lib:GetLocalDay(nStartTime)
    local nActStartDaySec = Lib:GetLocalDayTime(nStartTime)
    local nMatchDay = nToday - nOpenActDay + 1
    local tbScheInfo = self.tbScheduleDay[nMatchDay]
    if not tbScheInfo then
        return
    end
    return tbScheInfo.nGameType
end

function WuLinDaHui:CanOperateParnter()
    local nGameType = self:GetToydayGameFormat()
    if not nGameType then
        return
    end
    local tbGameFormat = self.tbGameFormat[nGameType]
    if tbGameFormat.bOpenPartner or tbGameFormat.nPartnerPos then
        return true
    end
    return false
end

function WuLinDaHui:GetGameTypeByTeamId(nFightTeamID)
    local nLeft = nFightTeamID % tbDef.nServerIdxInTeamId
    return math.floor(nLeft / tbDef.nGameTypeInTeamId)
end
