Require("CommonScript/KinBattle/KinBattleCommon.lua");
Require("CommonScript/Npc/NpcDefine.lua")
Require("CommonScript/EnvDef.lua")

Battle.ONLY_SIGNUP_TIME = 60 * 5; --

if MODULE_ZONESERVER then
	Battle.ONLY_SIGNUP_TIME = Battle.ONLY_SIGNUP_TIME + 60 --跨区服为了数据先通知到本服，所以是提前一分钟开启的
end

Battle.NEXT_SIGNUP_TIME = 600; -- 第一场过后的匹配时间
Battle.WIN_ADD_SCORE_PER = 1.2;  	--胜利方增加 20% 积分

Battle.SAVE_GROUP = 11;
Battle.tbQualifyBattleOpemTime = { hour = 20, min = 25 };--开启是晚上的八点半，现用于称号的截至时间

Battle.tbMinAward = {  				--对应最小奖励
	{"BattleHonor", 300},
} ; 
-- Battle.tbAttendAward = {  --战场参与奖励
-- 	{nLevel = 39,  Award = {{"item", 1006, 1}} }, --39级及以前拿的奖励
-- 	{nLevel = 150, Award = {{"item", 764, 1}} },
-- }

Battle.tbRevieBuff = {1008, 1, 5} --复活时5秒加速buff



Battle.STATE_TRANS =  --战场流程控制
{
	{	--元帅，杀戮，跨服,百人
		{nSeconds = 10,   	szFunc = "StartFight",  szDesc = "準備階段"}, --30秒后执行StartFight todo
		{nSeconds = 60*12, 	 szFunc = "StopFight",   szDesc = "戰鬥階段"}, --进入结算时间
		{nSeconds = 10,   	szFunc = "CloseBattle", szDesc = "結算階段"},
	},
	{
		--新手战场
		{nSeconds = 5,   		szFunc = "StartFight",    szDesc = "準備階段"},  
		{nSeconds = 60*3,   	szFunc = "StopFight",   szDesc = "戰鬥階段"}, 
		{nSeconds = 10,   		szFunc = "CloseBattle", szDesc = "結算階段"},
	},
	{
		{nSeconds = 5,   	szFunc = "StartFight",  szDesc = "準備階段"}, 
		{nSeconds = 60*12,  szFunc = "StopFight",   szDesc = "戰鬥階段"}, 
		{nSeconds = 10,   	szFunc = "CloseBattle", szDesc = "結算階段"},
	},
	{	--6v6
		{nSeconds = 10,   	szFunc = "StartFight",  szDesc = "準備階段"}, 
		{nSeconds = 60*12, 	 szFunc = "StopFight",   szDesc = "戰鬥階段"},
		{nSeconds = 10,   	szFunc = "CloseBattle", szDesc = "結算階段"},
	},
}

--辅助计时显示，单独timer会卡顿时时间对应不上,为了显示一致现在 HomeScreenBattleInfo 的timer里调用的，
Battle.Second_StateTrans = 
{
	[2] =  --对应 新手战场的nUseSchedule
	{
		[1] = { --第一个state
				[3] = {szFunc = "ShowReadyInfo", szDesc = "提示倒數計時"}, --剩3s时
			  },
		[2] = {
				[10]= {szFunc = "ShowMsg", tbParam = { "本場戰場將在10秒後結束"}, szDesc = "結束前倒計時"},
				[5] = {szFunc = "ShowMsg", tbParam = { "本場戰場將在5秒後結束" }, szDesc = "結束前倒計時"},
				[3] = {szFunc = "ShowMsg", tbParam = { "本場戰場將在3秒後結束" }, szDesc = "結束前倒計時"},
				[2] = {szFunc = "ShowMsg", tbParam = { "本場戰場將在2秒後結束" }, szDesc = "結束前倒計時"},
				[1] = {szFunc = "ShowMsg", tbParam = { "本場戰場將在1秒後結束" }, szDesc = "結束前倒計時"},
			  },
	},

	--阵营攻防战
	[4] = {
		[1] = { 
			[8] = {szFunc = "ShowReportUi", szDesc = "顯示對陣圖"}, --剩3s时
			[7] = {szFunc = "ShowReportUi", szDesc = "顯示對陣圖"}, --剩3s时
			[2] = {szFunc = "CloseReportUi", szDesc = "關閉對陣圖"};
		  },
		[2] = {
			[0] = {szFunc = "CloseReportUi", szDesc = "關閉對陣圖"}; --切状态时也执行
		}
	};

}


Battle.JOIN_TASK = 19;

Battle.READY_MAP_ID = 1014; --战场准备场
Battle.ZONE_READY_MAP_ID = 1055; --跨服战场准备场

Battle.READY_MAP_POS = { --准备地图出生点
	{2634, 5679}; 
    {2746, 4812};
    {6996, 6777};
    {7025, 4638};
}

Battle.tbAllBattleSetting = {
	["BattleKill"] = 
	{	
		szName 			= "殺戮戰場",
		nMapTemplateId  = 1010,
		bCanLowerZone   = true; --可以是低阶战场
		nCalendarType   = 1;
		nShowLevel  	= 1; --同时出现多个战场时的优先级别，越高优先级越高,同时在Battle.tbMapSetting的配置就在前面
		nMinLevel 		= 24, 			--参加最小等级
		nPlayerMinNum 	= 2, 		 	--开启战场的最小人数
		nPlayerMaxNum 	= 20,  	 		--开启战场的最大人数
		szLogicClass 	= "BattleKill",	    
		tbPos  			= {
							{{1386,  3594}, {1968,  3625},{2308,  3213},{1875,  2888},{1391,  3172},{1772,  3290},}, 
							{{19107, 3630},{19627, 3650},{20091, 3295},{19972, 2796},{19112, 2822},{19488, 3218},}, 
						  },

		tbPosBattle 	= {  --战斗区域 大营的起始点
							{{4679,  3822},{4431,  3213},{4937,  2608},{5600,  2626},{5523,  3163},{5501,  3745},{6101,  3781},{6204,  2734},},
							{{14898, 3641},{15467,  3682},{16225,  3767},{16585,  3402},{16622,  3055},{15949,  2599},{15385,  2310},{14830,  2874},},
						  }, 
		tbAwardSetBig	= "BattleAward1",
		tbAwardSetSmall	= "BattleAward1",
		tbTeamNames		= {"宋方", "金方"},
		tbInitDir 	  	= {18, 49},
		tbCamVal 		= {Npc.CampTypeDef.camp_type_song, Npc.CampTypeDef.camp_type_jin},
		nUseSchedule	= 1, --使用哪一套流程控制	
		fileTrapBuff = "Setting/Battle/BattleKill/TrapBuff.tab",
		BACK_IN_CAMP_TIME = 30;  	--最多在后营待的时间
		nQualifyMinRank = 3; --普通战场进入过前3名 就有资格进入月度
		szQualifyBattleLogic = "BattleMonth"; --满足条件进入的资格赛类型
		nMin_AWARD_SCORE = 100;
	},

	["BattleDota"] = 
	{
		szName 			= "元帥保衛戰場",
		nMapTemplateId 	= 1002, 		--是可以同地图模版的
		bCanLowerZone   = true; --可以是低阶战场
		nCalendarType   = 1;
		nShowLevel  	= 1;
		nMinLevel 		= 24, 	
		nPlayerMinNum 	= 2,
		nPlayerMaxNum 	= 20, 		 
		szLogicClass 	= "BattleDota",	 
		tbPos  			= {
							{{543,  6830}, {583,  6428},{1014,  6225},{1227,  7142},{1024,  6676},{826,  7048},{1376,  6696},{717,  6626},}, 
							{{17481, 7028},{17476, 6701},{17476, 6334},{17902, 6706},{17887, 7058},{17887, 6259},{18304, 6929},{18309, 6567},}, 
						  },

		tbPosBattle 	= {  --战斗区域 大营的起始点
							{{3688,  7643},{3901,  7226},{3851,  6611},{3831,  5798},{4605,  5228},{4516,  8144},{4555,  7559},{4615,  5917},},
							{{14039, 7916},{14842,  7876},{14817,  5714},{13935,  5624},{14773,  7251},{14783,  6572},{13359,  7881},{13225,  6076},},
						  }, 
		tbAwardSetBig	= "BattleAward1",
		tbAwardSetSmall	= "BattleAward1",
		tbTeamNames 	= {"宋方", "金方"},
		tbNpcTimeFrame 	= { 
							{"OpenLevel39", 40 };
							{"OpenDay10", 	45 };
							{"OpenLevel59", 50 };
						  };
		tbInitDir 	  	= {18, 49},
		tbCamVal 		= {Npc.CampTypeDef.camp_type_song, Npc.CampTypeDef.camp_type_jin},
		nUseSchedule	= 1,
		nNpcRefreshTime = 60, --60s 刷新一波士兵
		fileWildNpc = "Setting/Battle/Dota/WildNpcSetting.tab",
		fileMovePath= "Setting/Battle/Dota/MovePath.tab",
		BACK_IN_CAMP_TIME = 30;  	--最多在后营待的时间 
		nQualifyMinRank = 3; --普通战场进入过前3名 就有资格进入月度
		szQualifyBattleLogic = "BattleMonth"; --满足条件进入的资格赛类型
		nMin_AWARD_SCORE = 100;
	},

	["BattleCross"] = 
	{
		szName 			= "跨服戰場",
		bZone 			= true;--是否只是跨服开
		bShowName  		= true; --对应叹号和滚屏会显示其名字而不是宋金战场；
		nShowLevel  	= 2;
		nCalendarType   = 2;
		OpenTimeFrame 	= "OpenLevel79";
		nMapTemplateId 	= 1002, 		--是可以同地图模版的
		nPlayerMinNum 	= 2,
		nPlayerMaxNum 	= 20, 		 
		szLogicClass 	= "BattleCross",	 
		tbPos  			= {
							{{543,  6830}, {583,  6428},{1014,  6225},{1227,  7142},{1024,  6676},{826,  7048},{1376,  6696},{717,  6626},}, 
							{{17481, 7028},{17476, 6701},{17476, 6334},{17902, 6706},{17887, 7058},{17887, 6259},{18304, 6929},{18309, 6567},}, 
						  },

		tbPosBattle 	= {  --战斗区域 大营的起始点
							{{3688,  7643},{3901,  7226},{3851,  6611},{3831,  5798},{4605,  5228},{4516,  8144},{4555,  7559},{4615,  5917},},
							{{14039, 7916},{14842,  7876},{14817,  5714},{13935,  5624},{14773,  7251},{14783,  6572},{13359,  7881},{13225,  6076},},
						  }, 
		tbAwardSetBig	= "BattleAwardCross",
		tbAwardSetSmall	= "BattleAwardCross",
		tbTeamNames		= {"宋方", "金方"},
		tbInitDir 	  	= {18, 49},
		tbCamVal 		= {Npc.CampTypeDef.camp_type_song, Npc.CampTypeDef.camp_type_jin},
		nUseSchedule	= 1, --使用哪一套流程控制	
		fileTrapBuff = "Setting/Battle/BattleKill/TrapBuff.tab",
		BACK_IN_CAMP_TIME = 30;  	--最多在后营待的时间
		nQualifyMinRank = 10; 
		szQualifyBattleLogic = "BattleMonth"; 
		nMin_AWARD_SCORE = 100;
	},

	["BattleHundred"] = 
	{
		szName 			= "百人戰場",
		bZone 			= true;
		bShowName  		= true; --对应叹号和滚屏会显示其名字而不是宋金战场；
		nShowLevel  	= 3;
		nCalendarType   = 3;
		OpenTimeFrame 	= "OpenLevel79";
		nRealNeedLevel  = 90; --开百人时实际会也会开跨服的，实际参与百人的等级要求是 90级
		nMapTemplateId 	= 1002, 		--是可以同地图模版的
		nPlayerMinNum 	= 2,
		nPlayerMaxNum 	= 100, 		 
		szLogicClass 	= "BattleHundred",	 
		tbPos  			= {
							{{543,  6830}, {583,  6428},{1014,  6225},{1227,  7142},{1024,  6676},{826,  7048},{1376,  6696},{717,  6626},}, 
							{{17481, 7028},{17476, 6701},{17476, 6334},{17902, 6706},{17887, 7058},{17887, 6259},{18304, 6929},{18309, 6567},}, 
						  },

		tbPosBattle 	= {  --战斗区域 大营的起始点
							{{3688,  7643},{3901,  7226},{3851,  6611},{3831,  5798},{4605,  5228},{4516,  8144},{4555,  7559},{4615,  5917},},
							{{14039, 7916},{14842,  7876},{14817,  5714},{13935,  5624},{14773,  7251},{14783,  6572},{13359,  7881},{13225,  6076},},
						  }, 
		tbAwardSetBig	= "BattleAwardHundred",
		tbAwardSetSmall	= "BattleAwardHundred",
		tbTeamNames		= {"宋方", "金方"},
		tbInitDir 	  	= {18, 49},
		tbCamVal 		= {Npc.CampTypeDef.camp_type_song, Npc.CampTypeDef.camp_type_jin},
		nUseSchedule	= 1, --使用哪一套流程控制	
		BACK_IN_CAMP_TIME = 30;  	--最多在后营待的时间
		nQualifyMinRank = 20; 
		szQualifyBattleLogic = "BattleMonth"; 
		nMin_AWARD_SCORE = 100;
	},

	["BattleMonth"] = 
	{
		szName 			= "月度戰場",
		bZone 			= true;
		bShowName  		= true; --对应叹号和滚屏会显示其名字而不是宋金战场；
		nShowLevel  	= 4;
		OpenTimeFrame 	= "OpenLevel109";
		nMapTemplateId 	= 1002, 		--是可以同地图模版的
		nPlayerMinNum 	= 2,
		nPlayerMaxNum 	= 40, 		 
		szLogicClass 	= "BattleMonth",	 
		tbPos  			= {
							{{543,  6830}, {583,  6428},{1014,  6225},{1227,  7142},{1024,  6676},{826,  7048},{1376,  6696},{717,  6626},}, 
							{{17481, 7028},{17476, 6701},{17476, 6334},{17902, 6706},{17887, 7058},{17887, 6259},{18304, 6929},{18309, 6567},}, 
						  },

		tbPosBattle 	= {  --战斗区域 大营的起始点
							{{3688,  7643},{3901,  7226},{3851,  6611},{3831,  5798},{4605,  5228},{4516,  8144},{4555,  7559},{4615,  5917},},
							{{14039, 7916},{14842,  7876},{14817,  5714},{13935,  5624},{14773,  7251},{14783,  6572},{13359,  7881},{13225,  6076},},
						  }, 
		tbAwardSetBig	= "BattleAwardMonth",
		tbAwardSetSmall	= "BattleAwardMonth",
		tbTeamNames		= {"宋方", "金方"},
		tbInitDir 	  	= {18, 49},
		tbCamVal 		= {Npc.CampTypeDef.camp_type_song, Npc.CampTypeDef.camp_type_jin},
		nUseSchedule	= 1, --使用哪一套流程控制	
		BACK_IN_CAMP_TIME = 30;  	--最多在后营待的时间

		nKeyQualifyTime = 5; --获取月度赛资格的时间key
		nQualifyMinRank = 20; --进入季度的最小资格
		nQualifyTitleId = 216; --获取资格时获得的称号id
		szQUalifyNotifyMsg = "恭喜您獲得下個月的月度戰場資格"; --获取资格时的提示文字
		szQualifyType = "Month"; --用于打开获得资格ui提示，通用与其他类似
		szQualifyBattleLogic = "BattleSeason"; 
		fnGetQualifyMatchTime = "GetQualifyMatchTimeMonth";
		ChechConditionFunc = "IsQualifyInMonthBattle";
		tbRankNotify = {
			{nRankEnd = 1, szKinNotify = "恭喜本幫派的%s獲得了月度戰場的第%d名", szWorldNotify = "恭喜%s獲得了月度戰場的第%d名"}; --排名对应的家族，世界公告
			{nRankEnd = 3, szKinNotify = "恭喜本幫派的%s獲得了月度戰場的第%d名", };
		};	
	},

	["BattleSeason"] = 
	{
		szName 			= "季度戰場",
		bZone 			= true;
		bShowName  		= true; --对应叹号和滚屏会显示其名字而不是宋金战场；
		nShowLevel  	= 5;
		OpenTimeFrame 	= "OpenLevel109";
		nMapTemplateId 	= 1002, 		--是可以同地图模版的
		nPlayerMinNum 	= 2,
		nPlayerMaxNum 	= 60, 		 
		szLogicClass 	= "BattleSeason",	 
		tbPos  			= {
							{{543,  6830}, {583,  6428},{1014,  6225},{1227,  7142},{1024,  6676},{826,  7048},{1376,  6696},{717,  6626},}, 
							{{17481, 7028},{17476, 6701},{17476, 6334},{17902, 6706},{17887, 7058},{17887, 6259},{18304, 6929},{18309, 6567},}, 
						  },

		tbPosBattle 	= {  --战斗区域 大营的起始点
							{{3688,  7643},{3901,  7226},{3851,  6611},{3831,  5798},{4605,  5228},{4516,  8144},{4555,  7559},{4615,  5917},},
							{{14039, 7916},{14842,  7876},{14817,  5714},{13935,  5624},{14773,  7251},{14783,  6572},{13359,  7881},{13225,  6076},},
						  }, 
		tbAwardSetBig	= "BattleAwardHundred",
		tbAwardSetSmall	= "BattleAwardHundred",
		tbTeamNames		= {"宋方", "金方"},
		tbInitDir 	  	= {18, 49},
		tbCamVal 		= {Npc.CampTypeDef.camp_type_song, Npc.CampTypeDef.camp_type_jin},
		nUseSchedule	= 1, --使用哪一套流程控制	
		BACK_IN_CAMP_TIME = 30;  	--最多在后营待的时间

		nKeyQualifyTime = 6; --获取季度战场的时间
		nQualifyMinRank = 20; 
		nQualifyTitleId = 217; --获取资格时获得的称号id
		szQUalifyNotifyMsg = "恭喜您獲得本季度的季度戰場資格"; --获取资格时的提示文字
		szQualifyType = "Season"; 
		szQualifyBattleLogic = "BattleYear"; 
		fnGetQualifyMatchTime = "GetQualifyMatchTimeSeason";
		ChechConditionFunc = "IsQualifyInSeasonBattle";
		tbRankNotify = {
			{nRankEnd = 1, szKinNotify = "恭喜%s獲得了月度戰場的第%d名", szWorldNotify = "恭喜%s獲得了月度戰場的第%d名"}; --排名对应的家族，世界公告
			{nRankEnd = 3, szKinNotify = "恭喜%s獲得了月度戰場的第%d名", };
		};	
	},

	["BattleYear"] = 
	{
		szName 			= "年度戰場",
		bZone 			= true;
		bShowName  		= true; --对应叹号和滚屏会显示其名字而不是宋金战场；
		nShowLevel  	= 6;
		OpenTimeFrame 	= "OpenLevel109";
		nMapTemplateId 	= 1002, 		--是可以同地图模版的
		nPlayerMinNum 	= 2,
		nPlayerMaxNum 	= 100, 		 
		szLogicClass 	= "BattleYear",	 
		tbPos  			= {
							{{543,  6830}, {583,  6428},{1014,  6225},{1227,  7142},{1024,  6676},{826,  7048},{1376,  6696},{717,  6626},}, 
							{{17481, 7028},{17476, 6701},{17476, 6334},{17902, 6706},{17887, 7058},{17887, 6259},{18304, 6929},{18309, 6567},}, 
						  },

		tbPosBattle 	= {  --战斗区域 大营的起始点
							{{3688,  7643},{3901,  7226},{3851,  6611},{3831,  5798},{4605,  5228},{4516,  8144},{4555,  7559},{4615,  5917},},
							{{14039, 7916},{14842,  7876},{14817,  5714},{13935,  5624},{14773,  7251},{14783,  6572},{13359,  7881},{13225,  6076},},
						  }, 
		tbAwardSetBig	= "BattleAwardHundred",
		tbAwardSetSmall	= "BattleAwardHundred",
		tbTeamNames		= {"宋方", "金方"},
		tbInitDir 	  	= {18, 49},
		tbCamVal 		= {Npc.CampTypeDef.camp_type_song, Npc.CampTypeDef.camp_type_jin},
		nUseSchedule	= 1, --使用哪一套流程控制	
		BACK_IN_CAMP_TIME = 30;  	--最多在后营待的时间

		nKeyQualifyTime = 7; --获取年度赛资格的时间
		nQualifyTitleId = 218; --获取资格时获得的称号id
		szQUalifyNotifyMsg = "恭喜您獲得明年一月份的年度戰場資格"; --获取资格时的提示文字
		szQualifyType = "Year"; 
		fnGetQualifyMatchTime = "GetQualifyMatchTimeYear";
		ChechConditionFunc = "IsQualifyInYearBattle";

		tbRankNotify = {
			{nRankEnd = 1, szKinNotify = "恭喜本幫派的%s獲得了月度戰場的第%d名", szWorldNotify = "恭喜%s獲得了月度戰場的第%d名"}; --排名对应的家族，世界公告
			{nRankEnd = 3, szKinNotify = "恭喜本幫派的%s獲得了月度戰場的第%d名", };
		};	
	};

	["BattleMoba"] = 
	{
		szName 			= "宋金攻防戰",
		nShowLevel  	= 4;
		bShowName  		= true; --对应叹号和滚屏会显示其名字而不是宋金战场；
		OpenTimeFrame 	= "OpenLevel99";
		nMapTemplateId 	= 1060, 		--是可以同地图模版的
		nPlayerMinNum 	= 2,			--单个战场最少人数
		nPlayerMaxNum 	= 20, 		 
		nMinLevel  		= 20;
		szLogicClass 	= "BattleMoba",	 
		tbPos  			= {
							{
								{3335,8577}, 
								{3348,8307},
								{3650,8572},
								{3642,8304},
								{3907,8559},
								{3901,8302},
							}, 
							{
								{18636,8543},
								{18641,8307},
								{18980,8593},
								{18986,8278},
								{19340,8572},
								{19325,8275},
							}, 
						  },

		tbPosBattle 	= {  --战斗区域 大营的起始点
							{
								{5181,8663},
								{5190,8390},
								{5160,8077},
							},
							{
								{17461,8741},
								{17454,8467},
								{17445,8102},
							},
						  }, 
		tbAward  		= { 
							[Env.LogRound_SUCCESS] =  {{"BasicExp", 80}, {"Item", 6110, 2} };
							[Env.LogRound_FAIL]    =  {{"BasicExp", 60}, {"Item", 6111, 2} };
						  },
		tbAwardMsg  	= {
							[Env.LogRound_SUCCESS] = "    恭喜，本次陣營攻防戰中，本方[FFFE0D]（%s）[-]獲勝！附件是%s後勤準備的些許獎勵，以資鼓勵！";
							[Env.LogRound_FAIL] = "    很遺憾，本次陣營攻防戰中，本方[FFFE0D]（%s）[-]惜敗！附件是%s後勤準備的些許獎勵，以資鼓勵！";
						  };
		tbTeamNames		= {"宋方", "金方"},
		tbInitDir 	  	= {18, 49},
		tbCamVal 		= {Npc.CampTypeDef.camp_type_song, Npc.CampTypeDef.camp_type_jin},
		nUseSchedule	= 4, --使用哪一套流程控制	
		BACK_IN_CAMP_TIME = 30;  	--最多在后营待的时间
		fileMovePath    = "Setting/Battle/Camp/MovePath.tab";
	};

	["BattleAlone"] = 
	{
		szLogicClass 	= "BattleAlone",
		nShowLevel  	= 0;
		szName 			= "新手戰場",
		nMapTemplateId 	= 1020, 		--是可以同地图模版的
		tbPos  			= {
							{{1281,  3232},{1347,  3519},{1289,  2862},{1632,  3211},{1539,  3466},{1498,  2850},}, 
							{{9980, 3211},{9912,  3396},{9546,  3379},{9552,  3211},{9627,  2920},{9918,  2908},}, 
						  },
		tbTeamNames 	= {"宋方", "金方"},
		tbCamVal 		= {Npc.CampTypeDef.camp_type_song, Npc.CampTypeDef.camp_type_jin},
		nUseSchedule	= 2, --流程控制
		nUseScheduleSecond	= 1,
		nOpenDialogId   = 30001,
		nNpcRefreshTime = 2*60, --30s 刷新一波士兵
		nSideNum 		= 6, --一边6个人
		nFakeAttriId	= 101, --对应 Setting\RankBattle\RankNpcAttrib.tab
		tbHomeBuildingId= {670, 671}, --大本营的建筑物id
		tbMovePathIndex = {
							{3,4,5}, --可填多个， 对应到 Setting/Battle/Dota/MovePath.tab 里面的路径 点要取路口处，玩家逃跑也会走该反路线
							{6,7,8},
						  },

		tbFactionBuff = 
		{
		--门派   变身Buff TODO 更换，需
		    [1] = 1711;
		    [2] = 1712;
		    [3] = 1713;
		    [4] = 1714;
		    [5] = 1715;
		    [6] = 1716;
		    [7] = 1734;
		    [8] = 1735;
		    [9] = 1736;
		    [10] = 1737;
		    [11] = 1738;
		    [12] = 1739;
		    [13] = 1740;
		    [14] = 1741;
		},

		tbBornBuff = {1708, 1}, --玩家获取的增强buff

		nMeLevel = 30,
		nHimLevel = 29,

		-- nLevelModify = -3; --假玩家的等级 = 玩家等级 + nLevelModify

		fileWildNpc = "Setting/Battle/DotaClient/WildNpcSettingClient.tab",
		fileMovePath= "Setting/Battle/DotaClient/MovePathClient.tab",
		BACK_IN_CAMP_TIME = 2;  
	},

	["KinBattle"] = 
	{
		nUseSchedule	= 3,
		nMapTemplateId  = KinBattle.FIGHT_MAP_ID,
		tbPos 			= 	{
								{KinBattle.tbFightMapBeginPoint[1]},
								{KinBattle.tbFightMapBeginPoint[2]},
							},
		nNpcRefreshTime = KinBattle.nNpcRefreshTime,
		fileCommNpc		= KinBattle.fileCommNpc,
		fileWildNpc 	= KinBattle.fileWildNpc,
		fileMovePath	= KinBattle.fileMovePath,
		BACK_IN_CAMP_TIME = 10;  
	},
}

--战场地图设置
--这里不好动态，因为一些配置表对应的配置已经定死了
Battle.tbMapSetting = {
	Battle.tbAllBattleSetting.BattleKill,
	Battle.tbAllBattleSetting.BattleDota,
	Battle.tbAllBattleSetting.BattleCross,--全服跨服
	Battle.tbAllBattleSetting.BattleHundred, --全服跨服
	Battle.tbAllBattleSetting.BattleMonth, --月度战场
	Battle.tbAllBattleSetting.BattleSeason, 
	Battle.tbAllBattleSetting.BattleYear, 
	Battle.tbAllBattleSetting.BattleMoba, 
}


--低阶跨服， 低阶跨服和常规战场是并存关系 ,而且同时能开多个类型的战场

--跨区战场报名条件设置
Battle.tbZoneSignupSetting = 
{
	{ TimeFrame = "OpenLevel59", nMaxLevel = 45, nMaxFightPower = 50000 };
	{ TimeFrame = "OpenLevel69", nMaxLevel = 55, nMaxFightPower = 100000 };
	{ TimeFrame = "OpenLevel79", nMaxLevel = 65, nMaxFightPower = 200000 };
	{ TimeFrame = "OpenLevel89", nMaxLevel = 75, nMaxFightPower = 400000 };
	{ TimeFrame = "OpenLevel99", nMaxLevel = 85, nMaxFightPower = 800000 };
	{ TimeFrame = "OpenLevel109", nMaxLevel = 95, nMaxFightPower = 1000000 };
	{ TimeFrame = "OpenLevel119", nMaxLevel = 105, nMaxFightPower = 1500000 };
	{ TimeFrame = "OpenLevel129", nMaxLevel = 115, nMaxFightPower = 2000000 };
}

--开跨区战场的时间轴限制
Battle.OpenLowZoneBattleTimeFrame = Battle.tbZoneSignupSetting[1].TimeFrame;

--跨区战场开启场次设置
Battle.tbZoneLevelSetting = {
	{ nLevelFrom = 20, nLevelEnd = 39, nBattleModeIndex = 2}, -- 有nBattleModeIndex的是强制开指定战场（2元帅战场）
	{ nLevelFrom = 40, nLevelEnd = 49, nBattleModeIndex = 2},
	{ nLevelFrom = 50, nLevelEnd = 59, },
	{ nLevelFrom = 60, nLevelEnd = 69, },
	{ nLevelFrom = 70, nLevelEnd = 79, },
	{ nLevelFrom = 80, nLevelEnd = 89, },
	{ nLevelFrom = 90, nLevelEnd = 99, },
	{ nLevelFrom = 100, nLevelEnd = 109, },
	{ nLevelFrom = 110, nLevelEnd = 119, },
	{ nLevelFrom = 120, nLevelEnd = 129, },
}


--全服跨服战场， 开的时候就只有跨服战场了，可以依然共存，只是都满足报名条件了， 现在是3，4类型战场同时开了
Battle.tbHighZoneLevelSetting = {
	{ nLevelFrom = 1,  nLevelEnd = 39, nBattleModeIndex = 3}, -- 有nBattleModeIndex的是强制开指定战场（2元帅战场）
	{ nLevelFrom = 40, nLevelEnd = 49, nBattleModeIndex = 3},
	{ nLevelFrom = 50, nLevelEnd = 59, nBattleModeIndex = 3},
	{ nLevelFrom = 60, nLevelEnd = 69, nBattleModeIndex = 3},
	{ nLevelFrom = 70, nLevelEnd = 79, nBattleModeIndex = 3},
	{ nLevelFrom = 80, nLevelEnd = 89, nBattleModeIndex = 3},
	{ nLevelFrom = 90, nLevelEnd = 129, }, --只有90级以上的是会按照配置开百人战场，其他的还是只会强制开普通高阶跨服

}


--现在是根据连斩数获得的称号等级, 同时设置击杀对应头衔等级下会获得的积分

--连斩对应称号及被击杀获得积分设置
Battle.tbTitleLevelSet = {
										--击杀对应称号获得积分， --被击杀时的提示  					 	 --获得称号时提示
	{nNeedScore = 0,	  	tbTitleID = {210, 219},  nKillAddScore = 50 , },  --称号分别对应宋金
	{nNeedScore = 200,   	tbTitleID = {211, 220},  nKillAddScore = 70 , }, 
	{nNeedScore = 500,   	tbTitleID = {212, 221},  nKillAddScore = 100, }, 
	{nNeedScore = 1000,   	tbTitleID = {213, 222},  nKillAddScore = 150, }, 
	{nNeedScore = 2000,   	tbTitleID = {214, 223},  nKillAddScore = 200, }, 
	{nNeedScore = 3000,   	tbTitleID = {215, 224},  nKillAddScore = 300, }, 
}

Battle.tbComboLevelSet = 
{
	{nComboCount = 0,   																			},
	{nComboCount = 3,	szKilledNotify = "%s終結了%s的勇冠三軍",  szNotify = "%s已經勇冠三軍！",	},
	{nComboCount = 5,	szKilledNotify = "%s終結了%s的接近暴走",  szNotify = "%s已經接近暴走！",	},
	{nComboCount = 10,	szKilledNotify = "%s終結了%s的無人可擋",  szNotify = "%s已經無人可擋！",	},
	{nComboCount = 15,	szKilledNotify = "%s終結了%s的主宰比賽",  szNotify = "%s已經主宰比賽！",	},
	{nComboCount = 20,	szKilledNotify = "%s終結了%s的接近神",    szNotify = "%s已經接近神了！",	},
	{nComboCount = 30,	szKilledNotify = "%s終結了%s的超神",      szNotify = "%s已經超神！",		},
}




--战场 npc 模板中阵营需要为0


--战场奖励设置 
Battle.tbAllAwardSet = {
	tbExChangeBoxInfo = 
	{
		{4687, 1000, "黃金寶箱"}, --荣誉兑换的黄金宝箱id, 所需要的荣誉
		{4687, 500, "白銀寶箱"} , --白银宝箱Id，需要荣誉
	},

	tbExtRandomAward = { --打完可能获得的随机奖励道具, 从高时间轴到低填写
		{"OpenLevel69", 3080, 0.3 },
		{"OpenLevel49", 3080, 0.2 }, --产出时间轴， 道具id， 产出概率
	},

	BattleAward1 = { --如果分时间轴就后面带_1， 对应几档时间轴, 不分就不加
		{nRandEnd = 1,  Award = {{"BasicExp", 80}, {"BattleHonor", 20000} } },  				--第1名的奖励
		{nRandEnd = 2,  Award = {{"BasicExp", 76}, {"BattleHonor", 15000} } },  						--第2名的奖励
		{nRandEnd = 5,  Award = {{"BasicExp", 72}, {"BattleHonor", 12000} } },  				--第3-5名的奖励
		{nRandEnd = 10,  Award = {{"BasicExp", 68},{"BattleHonor", 10000} } },  				--第6-10名的奖励
		{nRandEnd = 15,  Award = {{"BasicExp", 64},{"BattleHonor", 9000} } },  				--第11-15名的奖励
		{nRandEnd = 20,  Award = {{"BasicExp", 60},{"BattleHonor", 8500} } },  				--第16-20名的奖励
		{nRandEnd = 25,  Award = {{"BasicExp", 58},{"BattleHonor", 8000} } },  				--第21-25名的奖励
		{nRandEnd = 30,  Award = {{"BasicExp", 56},{"BattleHonor", 7500} } }, 				--第26-30名的奖励
		{nRandEnd = 35,  Award = {{"BasicExp", 52},{"BattleHonor", 7000} } }, 				--第31-35名的奖励
		{nRandEnd = 40,  Award = {{"BasicExp", 48},{"BattleHonor", 6500} } }, 				--第36-40名的奖励
	},
	
	BattleAwardCross = { --如果分时间轴就后面带_1， 对应几档时间轴, 不分就不加
		{nRandEnd = 1,  Award = {{"BasicExp", 80}, {"BattleHonor", 30000} } },  				--第1名的奖励
		{nRandEnd = 2,  Award = {{"BasicExp", 76}, {"BattleHonor", 25000} } },  				--第2名的奖励
		{nRandEnd = 5,  Award = {{"BasicExp", 72}, {"BattleHonor", 20000} } },  				--第3-5名的奖励
		{nRandEnd = 10,  Award = {{"BasicExp", 70},{"BattleHonor", 16000} } },  				--第6-10名的奖励
		{nRandEnd = 15,  Award = {{"BasicExp", 68},{"BattleHonor", 14000} } },  				--第11-15名的奖励
		{nRandEnd = 20,  Award = {{"BasicExp", 66},{"BattleHonor", 13000} } },  				--第16-20名的奖励
		{nRandEnd = 25,  Award = {{"BasicExp", 64},{"BattleHonor", 12000} } },  				--第21-25名的奖励
		{nRandEnd = 30,  Award = {{"BasicExp", 62},{"BattleHonor", 11000} } }, 				--第26-30名的奖励
		{nRandEnd = 35,  Award = {{"BasicExp", 60},{"BattleHonor", 10000} } }, 				--第31-35名的奖励
		{nRandEnd = 40,  Award = {{"BasicExp", 58},{"BattleHonor", 9500} } }, 				--第36-40名的奖励
		{nRandEnd = 45,  Award = {{"BasicExp", 56},{"BattleHonor", 9000} } }, 				--第41-45名的奖励
		{nRandEnd = 50,  Award = {{"BasicExp", 54},{"BattleHonor", 8500} } }, 				--第46-50名的奖励
		{nRandEnd = 55,  Award = {{"BasicExp", 52},{"BattleHonor", 8000} } }, 				--第51-55名的奖励
		{nRandEnd = 60,  Award = {{"BasicExp", 50},{"BattleHonor", 7500} } }, 				--第56-60名的奖励
	},
	
	BattleAwardHundred = { --如果分时间轴就后面带_1， 对应几档时间轴, 不分就不加
		{nRandEnd = 1,  Award = {{"BasicExp", 80}, {"BattleHonor", 40000} } },  				--第1名的奖励
		{nRandEnd = 2,  Award = {{"BasicExp", 78}, {"BattleHonor", 35000} } },  				--第2名的奖励
		{nRandEnd = 5,  Award = {{"BasicExp", 76}, {"BattleHonor", 3000} } },  				--第3-5名的奖励
		{nRandEnd = 10,  Award = {{"BasicExp", 74},{"BattleHonor", 25000} } },  				--第6-10名的奖励
		{nRandEnd = 15,  Award = {{"BasicExp", 72},{"BattleHonor", 20000} } },  				--第11-15名的奖励
		{nRandEnd = 20,  Award = {{"BasicExp", 70},{"BattleHonor", 18000} } },  				--第16-20名的奖励
		{nRandEnd = 30,  Award = {{"BasicExp", 68},{"BattleHonor", 16000} } },  				--第21-25名的奖励
		{nRandEnd = 40,  Award = {{"BasicExp", 66},{"BattleHonor", 14000} } }, 				--第26-30名的奖励
		{nRandEnd = 50,  Award = {{"BasicExp", 64},{"BattleHonor", 13000} } }, 				--第31-35名的奖励
		{nRandEnd = 60,  Award = {{"BasicExp", 62},{"BattleHonor", 12000} } }, 				--第36-40名的奖励
		{nRandEnd = 70,  Award = {{"BasicExp", 60},{"BattleHonor", 11000} } }, 				--第41-45名的奖励
		{nRandEnd = 80,  Award = {{"BasicExp", 58},{"BattleHonor", 10000} } }, 				--第46-50名的奖励
		{nRandEnd = 90,  Award = {{"BasicExp", 54},{"BattleHonor", 9000} } }, 				--第51-55名的奖励
		{nRandEnd = 100,  Award = {{"BasicExp", 50},{"BattleHonor", 8000} } }, 				--第56-60名的奖励
	},
	
	BattleAwardMonth = { --如果分时间轴就后面带_1， 对应几档时间轴, 不分就不加
		{nRandEnd = 1,  Award = {{"BasicExp", 80}, {"Energy", 100000} } },  				--第1名的奖励
		{nRandEnd = 2,  Award = {{"BasicExp", 78}, {"Energy", 85000} } },  				--第2名的奖励
		{nRandEnd = 5,  Award = {{"BasicExp", 76}, {"Energy", 70000} } },  				--第3-5名的奖励
		{nRandEnd = 10,  Award = {{"BasicExp", 74},{"Energy", 60000} } },  				--第6-10名的奖励
		{nRandEnd = 15,  Award = {{"BasicExp", 72},{"Energy", 50000} } },  				--第11-15名的奖励
		{nRandEnd = 20,  Award = {{"BasicExp", 70},{"Energy", 40000} } },  				--第16-20名的奖励
		{nRandEnd = 25,  Award = {{"BasicExp", 68},{"Energy", 30000} } },  				--第21-25名的奖励
		{nRandEnd = 30,  Award = {{"BasicExp", 66},{"Energy", 25000} } }, 				--第26-30名的奖励
		{nRandEnd = 35,  Award = {{"BasicExp", 64},{"Energy", 20000} } }, 				--第31-35名的奖励
		{nRandEnd = 40,  Award = {{"BasicExp", 62},{"Energy", 16000} } }, 				--第36-40名的奖励

	},

}

Battle.tbTimeFrameAward = {
}

--能传入战场的地图
local tbLegalMap = {
	1,2,3,4,5,6,7,8,9,10,999, Battle.READY_MAP_ID, Battle.ZONE_READY_MAP_ID,
}

--------------设置end---------------------

Battle.LegalMap = {};

local fnSetIndex = function ()
	for i,v in ipairs(Battle.tbMapSetting) do
		v.nIndex = i;
		assert(v.szName, i);
		assert(v.nMapTemplateId, i);
		assert(v.nPlayerMinNum, i);
		assert(#v.tbPos[1] >= 1, i);
		assert(#v.tbPos[2] >= 1, i);
		for _, tbAwardSet in ipairs({"tbAwardSetBig", "tbAwardSetSmall"}) do
			local tbAwardDesc = v[tbAwardSet]
			if tbAwardDesc then
				if Battle.tbTimeFrameAward[tbAwardDesc] then
					for i2, _ in ipairs(Battle.tbTimeFrameAward[tbAwardDesc]) do
						assert( Battle.tbAllAwardSet[tbAwardDesc .. "_" .. i2], tbAwardSet ..":".. i.." and "..i2)
					end
				else
					assert( Battle.tbAllAwardSet[tbAwardDesc], i)
				end
			end
			
		end
	end
	for i,v in ipairs(tbLegalMap) do
		Battle.LegalMap[v] = 1
	end

	local szExchangeTip = ""
	local tbExChangeBoxInfo = Battle.tbAllAwardSet.tbExChangeBoxInfo
	for i, v in ipairs(tbExChangeBoxInfo) do
		szExchangeTip = szExchangeTip .. string.format(", 每%d榮譽兌換1個%s", v[2], v[3])
	end
	szExchangeTip = string.sub(szExchangeTip, 2)
	Battle.szBoxExchangeTip = szExchangeTip

end
fnSetIndex();

--检查能否报名
function Battle:CheckCanSignUp(pPlayer, tbBattleSetting)
	if self.LegalMap[pPlayer.nMapTemplateId] ~= 1 then
		if Map:GetClassDesc(pPlayer.nMapTemplateId) ~= "fight" or pPlayer.nFightMode ~= 0 then
			return false, "您目前所在地不能被傳入戰場"
		end
	end


	if tbBattleSetting and not tbBattleSetting.nQualifyTitleId and DegreeCtrl:GetDegree(pPlayer, "Battle") < 1 then
		--客户端的话，次数不足直接提示购买
		if not MODULE_GAMESERVER then
			local nBuyDegree = DegreeCtrl:GetDegree(pPlayer, "BattleBuy")
			if nBuyDegree > 0 then
				local nBuyCount = math.min(5, nBuyDegree); --一次买5次
				local fnConfirmBuy = function ()
					local szBuyDegree, szMoneyType, nCost = DegreeCtrl:BuyCountCostPrice(me, "Battle", nBuyCount)
					if me.GetMoney(szMoneyType) < nCost then
						me.CenterMsg(string.format("您的%s不足%d", Shop.tbMoney[szMoneyType].Name, nCost) )
						return 0
					end 

					RemoteServer.BuyCount("Battle", nBuyCount) --self.szRefreshUi
				end

				Ui:OpenWindow("MessageBox", string.format("次數不足，確定購買 [FFFE0D]%d次[-] 次數嗎", nBuyCount), 
					{ {fnConfirmBuy}  }, {"確定", "取消"})
			end
		end
		return false, "您的次數不足"
	end

	--其他条件 todo 
	return true
end

function Battle:GetRandInitPos(nTeamIndex, tbBattleSetting) --传tbBattleSetting 是因为有可能是报名结束了，然后最后场战场调了这里
	local tbPos = tbBattleSetting.tbPos[nTeamIndex]
	return tbPos[MathRandom(#tbPos)]
end


function Battle:GetAward(nRank, nScore, tbAwardSet, nMinScore)
	local tbAward = {}
	
	--划水奖
	if nScore and nMinScore and  nScore <= nMinScore then 
		return Lib:MergeTable(tbAward, Battle.tbMinAward); 
	end
	--排名奖
	for i,v in ipairs(tbAwardSet) do
		if nRank <= v.nRandEnd then
			return Lib:MergeTable(tbAward, v.Award); 
		end
	end
	return tbAward
end

function Battle:Honor2Box(dwRoleId, nGetHonor, tbAwardList)
	local nCurHonor = 0;
	local nBoxCount = 0;
	local nLeftHonor = 0;

	if not tbAwardList then
		return nCurHonor, nBoxCount, nLeftHonor;
	end

	local pAsync = KPlayer.GetAsyncData(dwRoleId);
	if  not pAsync then
		return nCurHonor, nBoxCount, nLeftHonor;
	end

	nCurHonor = pAsync.GetBattleHonor();

	nLeftHonor = nCurHonor + nGetHonor;

	local tbExChangeBoxInfo = Battle.tbAllAwardSet.tbExChangeBoxInfo

	for _, v in ipairs(tbExChangeBoxInfo) do
		local nCanChangeNum = math.floor(nLeftHonor / v[2])
		if nCanChangeNum > 0 then
			local nCostHonor = nCanChangeNum * v[2]
			nLeftHonor = nLeftHonor - nCostHonor

			table.insert(tbAwardList, {"item", v[1], nCanChangeNum })
			nBoxCount = nBoxCount + nCanChangeNum
		end
	end

	return nCurHonor, nBoxCount, nLeftHonor;
end

function Battle:GetCanSignLowZoneBattle(pPlayer)
	for i2 = #self.tbZoneSignupSetting, 1, -1 do
		local v2 = self.tbZoneSignupSetting[i2]
		if GetTimeFrameState(v2.TimeFrame) == 1 then
			if pPlayer.nLevel <= v2.nMaxLevel and pPlayer.GetFightPower() <= v2.nMaxFightPower then
				return true
			end
			break;
		end
	end
end

function Battle:IsQualifyBattleByType(pPlayer, szType, bNotNext)
	local tbSetting = Battle.tbAllBattleSetting[szType]
	if not tbSetting then
	    return
	end
	local fnFunc = self[tbSetting.ChechConditionFunc] 
	if not fnFunc then
	    return
	end
	return fnFunc(self, pPlayer, not bNotNext)
end

--判读月度赛资格
function Battle:IsQualifyInMonthBattle(pPlayer, bNext)
	local nNowQualifyTime = pPlayer.GetUserValue(self.SAVE_GROUP, self.tbAllBattleSetting.BattleMonth.nKeyQualifyTime)
	if nNowQualifyTime == 0 then
		return false
	end

	local nCurOpenBattleTime = Battle:GetQualifyMatchTimeMonth(bNext)
	return Lib:GetLocalDay(nNowQualifyTime) == Lib:GetLocalDay(nCurOpenBattleTime)
end

function Battle:IsQualifyInSeasonBattle(pPlayer)
	local nNowQualifyTime = pPlayer.GetUserValue(self.SAVE_GROUP, self.tbAllBattleSetting.BattleSeason.nKeyQualifyTime)
	if nNowQualifyTime == 0 then
		return false
	end

	local nCurOpenBattleTime = Battle:GetQualifyMatchTimeSeason()
	return Lib:GetLocalDay(nNowQualifyTime) == Lib:GetLocalDay(nCurOpenBattleTime)
end

function Battle:IsQualifyInYearBattle(pPlayer, bNext)
	local nNowQualifyTime = pPlayer.GetUserValue(self.SAVE_GROUP, self.tbAllBattleSetting.BattleYear.nKeyQualifyTime)
	if nNowQualifyTime == 0 then
		return false
	end
	local nCurOpenBattleTime = Battle:GetQualifyMatchTimeYear(bNext)
	return Lib:GetLocalDay(nNowQualifyTime) == Lib:GetLocalDay(nCurOpenBattleTime)
end

function Battle:GetQualifyMatchTimeMonth(bNext)
	--缓存下时间吧，
	local nNow = GetTime()
	if not bNext then
		nNow = nNow - 4800 ;--开启时是到9点多点了
	end
	if not self.nCahcheMatchTimeMonth then
		local tbTimeNow = os.date("*t", nNow)
		local tbOpemTime = self.tbQualifyBattleOpemTime
		local nSec = os.time({year = tbTimeNow.year, month = tbTimeNow.month, day = 1, hour = tbOpemTime.hour, min = tbOpemTime.min, sec = 0});
		local nNewSec = 0;
		for i2=0,6 do
			nNewSec = nSec + 3600 * 24 * i2
			local tbToTime = os.date("*t", nNewSec)
			if tbToTime.wday == 1 then
				self.nCahcheMatchTimeMonth = nNewSec
				break;
			end
		end
		local nSec = os.time({year = tbTimeNow.year, month = tbTimeNow.month + 1, day = 1, hour = tbOpemTime.hour, min = tbOpemTime.min, sec = 0});
		local nNewSec = 0;
		for i2=0,6 do
			nNewSec = nSec + 3600 * 24 * i2
			local tbToTime = os.date("*t", nNewSec)
			if tbToTime.wday == 1 then
				self.nCahcheMatchTimeMonthNext = nNewSec
				break;
			end
		end	
	end

	if nNow > self.nCahcheMatchTimeMonth then
		return self.nCahcheMatchTimeMonthNext
	else
		return  self.nCahcheMatchTimeMonth
	end
end

function Battle:GetQualifyMatchTimeSeason()
	if self.nCahcheMatchTimeSeason then
		return self.nCahcheMatchTimeSeason
	end

	local tbTimeNow = os.date("*t", GetTime())
	local nSeason = math.ceil(tbTimeNow.month / 3) 
	if tbTimeNow.year == 2017 and nSeason == 2 then
		nSeason = 3;
	end
	local tbOpemTime = self.tbQualifyBattleOpemTime
	local nSec = os.time({year = tbTimeNow.year, month = nSeason * 3 + 1, day = 1, hour = tbOpemTime.hour, min = tbOpemTime.min, sec = 0});
	nSec = nSec - 3600 * 24; --这样获取的是季度的最后一天的时间
	--找出最后一个周末
	local nNewSec = 0
	for i2=0,6 do
		nNewSec = nSec - 3600 * 24 * i2
		local tbToTime = os.date("*t", nNewSec)
		if tbToTime.wday == 1 then
			self.nCahcheMatchTimeSeason = nNewSec
			return nNewSec
		end
	end
end

function Battle:GetQualifyMatchTimeYear(bNext)
	local nNow = GetTime()
	if not bNext then
		nNow = nNow - 4800 ;--开启时是到9点多点了
	end
	if not self.nCahcheMatchTimeYear then
		local tbTimeNow = os.date("*t", nNow)
		local tbOpemTime = self.tbQualifyBattleOpemTime
		local nSec = os.time({year = tbTimeNow.year, month = 2, day = 1, hour = tbOpemTime.hour, min = tbOpemTime.min, sec = 0});
		nSec = nSec - 3600 * 24; 
		local nNewSec = 0
		for i2=0,6 do
			nNewSec = nSec - 3600 * 24 * i2
			local tbToTime = os.date("*t", nNewSec)
			if tbToTime.wday == 1 then
				self.nCahcheMatchTimeYear = nNewSec
				break;
			end
		end
		local nSec = os.time({year = tbTimeNow.year + 1, month = 2, day = 1, hour = tbOpemTime.hour, min = tbOpemTime.min, sec = 0});
		nSec = nSec - 3600 * 24; 
		local nNewSec = 0
		for i2=0,6 do
			nNewSec = nSec - 3600 * 24 * i2
			local tbToTime = os.date("*t", nNewSec)
			if tbToTime.wday == 1 then
				self.nCahcheMatchTimeYearNext = nNewSec
				break;
			end
		end
	end

	if nNow > self.nCahcheMatchTimeYear then
		return self.nCahcheMatchTimeYearNext
	else
		return  self.nCahcheMatchTimeYear
	end
end


function Battle:GetCanSignBattleSetting(pPlayer)
	if Calendar:IsActivityInOpenState("BattleMoba") then --开BattleMoba时不会开Battle 日历状态，虽然低阶跨服也是开的，但是让其参与moba优先
		return Battle.tbAllBattleSetting.BattleMoba
	end
	if not Calendar:IsActivityInOpenState("Battle") then
		return;
	end
	--本服开的都是能参加的，
	local bBattleZone = Calendar:IsActivityInOpenState("BattleZone") --当前是否有跨服战场
	--根据showLevel 重新排序下
	if not self.tbSortMapSetting then
		self.tbSortMapSetting = {};
		for i,v in ipairs(Battle.tbMapSetting) do
			table.insert(self.tbSortMapSetting, v)
		end
		table.sort( self.tbSortMapSetting, function (a, b)
			return a.nShowLevel > b.nShowLevel
		end )
	end

	for i, v in ipairs(self.tbSortMapSetting) do
		if Calendar:IsActivityInOpenState(v.szLogicClass) then
			if v.ChechConditionFunc then
				if Battle[v.ChechConditionFunc](self, pPlayer) then
					return v,  1  --目前资格赛都只有一个
				end
			elseif bBattleZone then
				local tbGroupSetting;
				if v.bZone then
					tbGroupSetting = self.tbHighZoneLevelSetting
				elseif v.bCanLowerZone and Battle:GetCanSignLowZoneBattle(pPlayer) then
					tbGroupSetting = self.tbZoneLevelSetting
				end
				if tbGroupSetting then
					local tbReadyMapIndexs = {};
					for i2,v2 in ipairs(tbGroupSetting) do
						if v2.nBattleModeIndex then
							tbReadyMapIndexs[v2.nBattleModeIndex] = (tbReadyMapIndexs[v2.nBattleModeIndex] or 0) + 1;
						else
							tbReadyMapIndexs[v.nIndex] = (tbReadyMapIndexs[v.nIndex] or 0) + 1;
						end
						if pPlayer.nLevel >= v2.nLevelFrom and  pPlayer.nLevel <= v2.nLevelEnd  then
							if v2.nBattleModeIndex then
								return self.tbMapSetting[v2.nBattleModeIndex], tbReadyMapIndexs[v2.nBattleModeIndex] --这个场次只是准备场场次，不区分类型的
							else
								return v, tbReadyMapIndexs[v.nIndex]
							end
						end
					end
				end
			end
			if not v.bZone then --不是非要在跨服开的前面都没资格进就可以直接进了
				return v
			end
		end
	end
end

