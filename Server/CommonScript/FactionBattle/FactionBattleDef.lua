local preEnv;
-- 两种模式下通用定义
if FactionBattle then --调试需要
	preEnv = _G;	--保存旧的环境
	setfenv(1, FactionBattle)
end

FREEDOMPK_POINT = "Setting/FactionBattle/freedompk_point.tab";
ELIMINATION_POINT = "Setting/FactionBattle/elimination_point.tab";
BOX_POINT		= "Setting/FactionBattle/box_point.tab";

MIN_LEVEL				= 30;		-- 参加等级下限
MAX_ATTEND_PLAYER		= 300; 		-- 最大参赛人数
MIN_ATTEND_PLAYER		= 4;		-- 最小参加人数 
AREA_PLAYER			= 30;		-- 自由PK场地标准人数

PREPARE_MAP_TAMPLATE_ID	= 1024		-- 准备场/淘汰赛地图
FREEPK_MAP_TAMPLATE_ID	= 1025		-- 晋级赛地图

FREEDOM_PK_PROTECT_TIME	= 3;		-- 混战重分场地后保护时间 3秒
FREEDOM_PK_REVIVE_TIME		= 60;		-- 混战复活固定间隔 30秒
ELIMI_PROTECT_TIME		= 3;		-- 淘汰赛保护时间 3秒
END_DELAY				= 5;		-- 淘汰赛延迟结束（给玩家认知结果的一个缓冲时间）

FLAG_TEMPLATE_ID 			= 728		-- 冠军旗子ID
FLAG_EXIST_TIME			= 3*60;		-- 冠军旗子生存期

GOUHUO_NPC_ID			= 729;		-- 篝火NPC ID
BOX_NPC_ID				= 727		-- 箱子NPC模板ID

PICK_BOX_TIME			= 2		-- 拾取奖励箱子的时间
BOX_EXSIT_TIME			= 2*60;		-- 箱子的存在时间
BOX_MAX_GET			= 8		-- 一场比赛最多开启多少个宝箱

NOTHING				= 0;		-- 活动未启动
SIGN_UP				= 1;  		-- 报名阶段
FREE_PK				= 2;		-- 混战阶段
FREE_PK_REST			= 3;		-- 休息时间
READY_ELIMINATION			= 4;		-- 淘汰准备阶段
ELIMINATION				= 5;		-- 淘汰赛阶段
ELIMINATION_REST			= 6;		-- 淘汰赛休息阶段
CHAMPION_AWARD			= 7;		-- 冠军颁奖
END_AWARD				= 8;		-- 领奖结束
END					= 9;		-- 结束

BEFORE_REMIND_TIME		= 30;		-- 提前提醒时间

START_NOTIFY_TIME			= 23*60	-- 开始通知存在时间
WINNER_NOTIFY_TIME		= 10*60	-- 结果通知存在时间

MAX_SAVE_DATA_COUNT 		= 30; --最多存储多少届冠军信息

PK_DMG_RATE = 
{
	--天王：
	[1] = 75,
	--峨眉：
	[2] = 90,
	--桃花：
	[3] = 60,
	--逍遥：
	[4] = 60,
	--武当：
	[5] = 65,
	--天忍：
	[6] = 60,
	--少林：
	[7] = 70,
	--翠烟：
	[8] = 60,
	--唐门：
	[9] = 60,
	--昆仑：
	[10] = 60,
	--丐帮：
	[11] = 70,
	--五毒：
	[12] = 60,
	--藏剑：
	[13] = 60,
	--长歌：
	[14] = 70,
}

-- 进入点
ENTER_POS = 
{
	{3175, 8023},
	{3815, 8023},
	{6160, 8038},
	{7582, 8028},
	{8222, 8033},
	{6830, 7261},
	{6849, 6572},
	{4695, 7207},
	{4714, 6621},
	{3112, 5478},
	{3879, 5492},
	
}

-- 冠军旗子点
FLAG_POS = {5726,6592}

-- 冠军自动传送至领奖台
AWARD_POS = {5789,7300}

-- 领奖台弹回点
FALG_TICK_BACK = {5171, 7794}

-- 篝火点
GOUHUO_POS = {6844, 5517}

-- 临时重生点
tbRevPos = {5491, 8038}

FINAL_AWARD_MAIL_TITLE = preEnv.XT("門派競技獎勵")

--FINAL_AWARD_MAIL_CONTENT = preEnv.XT("恭喜你在门派竞技中获得%s，奖励%d门派竞技荣誉，上届剩余%d荣誉，自动兑换成%d个荣誉宝箱后剩余%d荣誉！")
FINAL_AWARD_MAIL_CONTENT = preEnv.XT("恭喜你在門派競技中獲得%s，獲得如下獎勵！")

--结算时多少荣誉自动兑换成箱子
HONOR_2_BOX_RATE = 1000

HONOR_BOX_ITEM_ID = 2182

--16强必奖
FINAL_AWARD_16TH_FIX = 
{
	[1] = { {szType = "BasicExp", nCount = 150}, {szType = "Item", nItemId = { [1] = 2424, [2] = 2424, [3] = 2424, [4] = 2424, [5] = 2424, [6] = 2424, [7] = 2424, [8] = 2424, [9] = 2424, [10] = 2424, [11] = 2424, [12] = 2424, [13] = 2424, [14] = 2424},  nCount = 20}, },
	[2] = { {szType = "BasicExp", nCount = 120}, {szType = "Item", nItemId = { [1] = 2424, [2] = 2424, [3] = 2424, [4] = 2424, [5] = 2424, [6] = 2424, [7] = 2424, [8] = 2424, [9] = 2424, [10] = 2424, [11] = 2424, [12] = 2424, [13] = 2424, [14] = 2424},  nCount = 16},  },
	[4] = { {szType = "BasicExp", nCount = 110}, {szType = "Item", nItemId = { [1] = 2424, [2] = 2424, [3] = 2424, [4] = 2424, [5] = 2424, [6] = 2424, [7] = 2424, [8] = 2424, [9] = 2424, [10] = 2424, [11] = 2424, [12] = 2424, [13] = 2424, [14] = 2424},  nCount = 14},  },
	[8] = { {szType = "BasicExp", nCount = 100}, {szType = "Item", nItemId = { [1] = 2424, [2] = 2424, [3] = 2424, [4] = 2424, [5] = 2424, [6] = 2424, [7] = 2424, [8] = 2424, [9] = 2424, [10] = 2424, [11] = 2424, [12] = 2424, [13] = 2424, [14] = 2424},  nCount = 12},  },
	[16] = { {szType = "BasicExp", nCount = 90}, {szType = "Item", nItemId = { [1] = 2424, [2] = 2424, [3] = 2424, [4] = 2424, [5] = 2424, [6] = 2424, [7] = 2424, [8] = 2424, [9] = 2424, [10] = 2424, [11] = 2424, [12] = 2424, [13] = 2424, [14] = 2424},  nCount = 10}, },
}
FINAL_AWARD_16TH_FIX_HIGH = 
{
	[1] = { {szType = "BasicExp", nCount = 150}, {szType = "Item", nItemId = { [1] = 2424, [2] = 2424, [3] = 2424, [4] = 2424, [5] = 2424, [6] = 2424, [7] = 2424, [8] = 2424, [9] = 2424, [10] = 2424, [11] = 2424, [12] = 2424, [13] = 2424, [14] = 2424},  nCount = 30}, },
	[2] = { {szType = "BasicExp", nCount = 120}, {szType = "Item", nItemId = { [1] = 2424, [2] = 2424, [3] = 2424, [4] = 2424, [5] = 2424, [6] = 2424, [7] = 2424, [8] = 2424, [9] = 2424, [10] = 2424, [11] = 2424, [12] = 2424, [13] = 2424, [14] = 2424},  nCount = 24},  },
	[4] = { {szType = "BasicExp", nCount = 110}, {szType = "Item", nItemId = { [1] = 2424, [2] = 2424, [3] = 2424, [4] = 2424, [5] = 2424, [6] = 2424, [7] = 2424, [8] = 2424, [9] = 2424, [10] = 2424, [11] = 2424, [12] = 2424, [13] = 2424, [14] = 2424},  nCount = 20},  },
	[8] = { {szType = "BasicExp", nCount = 100}, {szType = "Item", nItemId = { [1] = 2424, [2] = 2424, [3] = 2424, [4] = 2424, [5] = 2424, [6] = 2424, [7] = 2424, [8] = 2424, [9] = 2424, [10] = 2424, [11] = 2424, [12] = 2424, [13] = 2424, [14] = 2424},  nCount = 18},  },
	[16] = { {szType = "BasicExp", nCount = 90}, {szType = "Item", nItemId = { [1] = 2424, [2] = 2424, [3] = 2424, [4] = 2424, [5] = 2424, [6] = 2424, [7] = 2424, [8] = 2424, [9] = 2424, [10] = 2424, [11] = 2424, [12] = 2424, [13] = 2424, [14] = 2424},  nCount = 16}, },
}


--16强概率奖，分门派，100000是满概率
FINAL_AWARD_16TH_RATE_BY_FACTION = 
{
	[1] =  { {szType = "Item", nRate = 0,  nCount = 1, nItemId={ [1] = 598, [2] = 598, [3] = 598, [4] = 598, [5] = 598, [6] = 598, [7] = 598, [8] = 598, [9] = 598, [10] = 598, [11] = 598, [12] = 598, [13] = 598, [14] = 598 } } },
	[2] = { {szType = "Item", nRate = 0,  nCount = 1, nItemId={ [1] = 598, [2] = 598, [3] = 598, [4] = 598, [5] = 598, [6] = 598, [7] = 598, [8] = 598, [9] = 598, [10] = 598, [11] = 598, [12] = 598, [13] = 598, [14] = 598  } } },
	[4] = { {szType = "Item", nRate = 0,  nCount = 1, nItemId={ [1] = 598, [2] = 598, [3] = 598, [4] = 598, [5] = 598, [6] = 598, [7] = 598, [8] = 598, [9] = 598, [10] = 598, [11] = 598, [12] = 598, [13] = 598, [14] = 598  } } },
	[8] = { {szType = "Item", nRate = 0,  nCount = 1, nItemId={ [1] = 598, [2] = 598, [3] = 598, [4] = 598, [5] = 598, [6] = 598, [7] = 598, [8] = 598, [9] = 598, [10] = 598, [11] = 598, [12] = 598, [13] = 598, [14] = 598  } } },
	[16] = { {szType = "Item", nRate = 0,  nCount = 1, nItemId={ [1] = 598, [2] = 598, [3] = 598, [4] = 598, [5] = 598, [6] = 598, [7] = 598, [8] = 598, [9] = 598, [10] = 598, [11] = 598, [12] = 598, [13] = 598, [14] = 598  } } },
}

--参与必奖
FINAL_AWARD_ALL_FIX = 
{
	--前20%名--所有人
	[20] = { {szType = "BasicExp", nCount = 85}, {szType = "Item", nItemId = { [1] = 2424, [2] = 2424, [3] = 2424, [4] = 2424, [5] = 2424, [6] = 2424, [7] = 2424, [8] = 2424, [9] = 2424, [10] = 2424, [11] = 2424, [12] = 2424 , [13] = 2424 , [14] = 2424},  nCount = 9},  },
	[40] = { {szType = "BasicExp", nCount = 80}, {szType = "Item", nItemId = { [1] = 2424, [2] = 2424, [3] = 2424, [4] = 2424, [5] = 2424, [6] = 2424, [7] = 2424, [8] = 2424, [9] = 2424, [10] = 2424, [11] = 2424, [12] = 2424 , [13] = 2424 , [14] = 2424 },  nCount = 8},  },
	[60] = { {szType = "BasicExp", nCount = 75}, {szType = "Item", nItemId = { [1] = 2424, [2] = 2424, [3] = 2424, [4] = 2424, [5] = 2424, [6] = 2424, [7] = 2424, [8] = 2424, [9] = 2424, [10] = 2424, [11] = 2424, [12] = 2424 , [13] = 2424 , [14] = 2424 },  nCount = 7},  },
	[80] = { {szType = "BasicExp", nCount = 70}, {szType = "Item", nItemId = { [1] = 2424, [2] = 2424, [3] = 2424, [4] = 2424, [5] = 2424, [6] = 2424, [7] = 2424, [8] = 2424, [9] = 2424, [10] = 2424, [11] = 2424, [12] = 2424 , [13] = 2424 , [14] = 2424 },  nCount = 6},  },
	[100] = { {szType = "BasicExp", nCount = 60}, {szType = "Item", nItemId = { [1] = 2424, [2] = 2424, [3] = 2424, [4] = 2424, [5] = 2424, [6] = 2424, [7] = 2424, [8] = 2424, [9] = 2424, [10] = 2424, [11] = 2424, [12] = 2424 , [13] = 2424 , [14] = 2424 },  nCount = 5},  },
}
FINAL_AWARD_ALL_FIX_HIGH = 
{
	--前20%名--所有人
	[20] = { {szType = "BasicExp", nCount = 85}, {szType = "Item", nItemId = { [1] = 2424, [2] = 2424, [3] = 2424, [4] = 2424, [5] = 2424, [6] = 2424, [7] = 2424, [8] = 2424, [9] = 2424, [10] = 2424, [11] = 2424, [12] = 2424 , [13] = 2424 , [14] = 2424 },  nCount = 14},  },
	[40] = { {szType = "BasicExp", nCount = 80}, {szType = "Item", nItemId = { [1] = 2424, [2] = 2424, [3] = 2424, [4] = 2424, [5] = 2424, [6] = 2424, [7] = 2424, [8] = 2424, [9] = 2424, [10] = 2424, [11] = 2424, [12] = 2424 , [13] = 2424 , [14] = 2424 },  nCount = 12},  },
	[60] = { {szType = "BasicExp", nCount = 75}, {szType = "Item", nItemId = { [1] = 2424, [2] = 2424, [3] = 2424, [4] = 2424, [5] = 2424, [6] = 2424, [7] = 2424, [8] = 2424, [9] = 2424, [10] = 2424, [11] = 2424, [12] = 2424 , [13] = 2424 , [14] = 2424 },  nCount = 10},  },
	[80] = { {szType = "BasicExp", nCount = 70}, {szType = "Item", nItemId = { [1] = 2424, [2] = 2424, [3] = 2424, [4] = 2424, [5] = 2424, [6] = 2424, [7] = 2424, [8] = 2424, [9] = 2424, [10] = 2424, [11] = 2424, [12] = 2424 , [13] = 2424 , [14] = 2424 },  nCount = 9},  },
	[100] = { {szType = "BasicExp", nCount = 60}, {szType = "Item", nItemId = { [1] = 2424, [2] = 2424, [3] = 2424, [4] = 2424, [5] = 2424, [6] = 2424, [7] = 2424, [8] = 2424, [9] = 2424, [10] = 2424, [11] = 2424, [12] = 2424 , [13] = 2424 , [14] = 2424 },  nCount = 8},  },
}


--参与概率奖，分门派，100000是满概率
FINAL_AWARD_ALL_RATE_BY_FACTION = 
{
	[20] =  { {szType = "Item", nRate = 0,  nCount = 1, nItemId={ [1] = 598, [2] = 598, [3] = 598, [4] = 598, [5] = 598, [6] = 598, [7] = 598, [8] = 598, [9] = 598, [10] = 598, [11] = 598, [12] = 598, [13] = 598, [14] = 598 } } },
	[40] = { {szType = "Item", nRate = 0,  nCount = 1, nItemId={ [1] = 598, [2] = 598, [3] = 598, [4] = 598, [5] = 598, [6] = 598, [7] = 598, [8] = 598, [9] = 598, [10] = 598, [11] = 598, [12] = 598, [13] = 598, [14] = 598} } },
	[60] = { {szType = "Item", nRate = 0,  nCount = 1, nItemId={ [1] = 598, [2] = 598, [3] = 598, [4] = 598, [5] = 598, [6] = 598, [7] = 598, [8] = 598, [9] = 598, [10] = 598, [11] = 598, [12] = 598, [13] = 598, [14] = 598} } },
	[80] = { {szType = "Item", nRate = 0,  nCount = 1, nItemId={ [1] = 598, [2] = 598, [3] = 598, [4] = 598, [5] = 598, [6] = 598, [7] = 598, [8] = 598, [9] = 598, [10] = 598, [11] = 598, [12] = 598, [13] = 598, [14] = 598} } },
	[100] = { {szType = "Item", nRate = 0,  nCount = 1, nItemId={ [1] = 598, [2] = 598, [3] = 598, [4] = 598, [5] = 598, [6] = 598, [7] = 598, [8] = 598, [9] = 598, [10] = 598, [11] = 598, [12] = 598, [13] = 598, [14] = 598} } },
}

-- 淘汰赛刷箱子数量表
ELIMINATION_AWARD =
{--	个数系数
	[0] = 0.6,		-- 领奖台奖励
	[1] = 0.2,		-- 16强奖励
	[2] = 0.3,		-- 8强奖励
	[3] = 0.4,		-- 半决赛奖励
	[4] = 0.5,		-- 决赛奖励
}

BOX_AWARD_RANDOM_ID = 
{
	[1] = {nLevelLimit = 1, nAwardId = 1448},
	[2] = {nLevelLimit = 60, nAwardId = 1449},
	[3] = {nLevelLimit = 70, nAwardId = 1450},
	[4] = {nLevelLimit = 80, nAwardId = 1451},
	[5] = {nLevelLimit = 90, nAwardId = 1452},
	[6] = {nLevelLimit = 100, nAwardId = 4430},
	[7] = {nLevelLimit = 110, nAwardId = 4431},
}

CHAMPION_TITLE = 
{
	[1] = 301,
	[2] = 304,
	[3] = 303,
	[4] = 302,
	[5] = 305,
	[6] = 306,
	[7] = 307,
	[8] = 308,
	[9] = 309,
	[10] = 310,
	[11] = 321,
	[12] = 323,
	[13] = 325,
	[14] = 327,
}

CHAMPION_TITLE_TIMEOUT = 30 * 24 * 60 * 60

-- 对阵表
ELIMI_VS_TABLE =
{
	{1, 	16},
	{8,	9},
	{4,	13},
	{5,	12},
	{2,	15},
	{7,	10},
	{3,	14},
	{6,	11},
}

-- 自由PK重新投入战斗时间表
RETURN_TO_PK_TIME = 30

-- 自由PK场地人数规则表
OPEN_AREA = {30, 60, 90, 120}


FREE_PK_SCORE = 
{
	-- 第一轮	第二轮		第三轮		第四轮
	{60,		100, 		80, 		80},	--场地1
	{60,		70 , 		64, 		80},	--场地2
	{60,		50 , 		50, 		80},	--场地3
	{60,		35 , 		40, 		80},	--场地4
}

-- 状态转换
STATE_TRANS	=
{
--	 状态 					阶段名称,				定时时间	时间到回调函数					5 区战替换信息
	{SIGN_UP, 				preEnv.XT("報名"),			5*60,		"StartFreedomPK"	},		-- 报名定时,自由PK开始
	{FREE_PK,				preEnv.XT("第1輪晉級賽"),		4*60,		"CloseFreedomPK"	},		-- 
	{FREE_PK_REST,			preEnv.XT("第2輪晉級賽"),		15,		"StartFreedomPK"	},
	{FREE_PK,				preEnv.XT("第2輪晉級賽"),		4*60,		"CloseFreedomPK"	},		-- 
	{FREE_PK_REST,			preEnv.XT("第3輪晉級賽"),		15,		"StartFreedomPK"	},
	{FREE_PK,				preEnv.XT("第3輪晉級賽"),		4*60,		"EndFreedomPK"	},		-- 
--	{FREE_PK_REST,			preEnv.XT("第4轮晋级赛"),		15,		"StartFreedomPK"	},
--	{FREE_PK,				preEnv.XT("第4轮晋级赛"),		3*60,		"EndFreedomPK"	},		-- 
	{READY_ELIMINATION,		preEnv.XT("16強賽"),			1*60,		"StartElimination",	}, 		-- 
	{ELIMINATION,				preEnv.XT("16強賽"),			2*60,		"CloseElimination"	}, 		-- 淘汰赛1阶	决出8强
	{ELIMINATION_REST,			preEnv.XT("8強賽"),			60,		"StartElimination",	}, 		-- 休息
	{ELIMINATION,				preEnv.XT("8強賽"),			2*60,		"CloseElimination"	}, 		-- 淘汰赛2阶	决出4强
	{ELIMINATION_REST,			preEnv.XT("半決賽"),			60,		"StartElimination",	}, 		-- 休息
	{ELIMINATION,				preEnv.XT("半決賽"),			2*60,		"CloseElimination"	}, 		-- 淘汰赛3阶	决出2强
	{ELIMINATION_REST,			preEnv.XT("決賽"),			60,		"StartElimination",	}, 		-- 淘汰赛准备
	{ELIMINATION,				preEnv.XT("決賽"),			2*60,		"EndElimination"	}, 		-- 淘汰赛4阶	冠军
	{CHAMPION_AWARD,		preEnv.XT("頒獎"),			3*60,		"EndChampionAward"	}, 		-- 冠军奖励
	{END_AWARD,			preEnv.XT("頒獎結束"),		2*60,		"EndBattle"	}, 		-- 等待结束
	{END}
};                     


WATCH_TRAP = 
{
	["trap_watch_in_1"] = 1,
	["trap_watch_in_2"] = 2,
	["trap_watch_in_3"] = 3,
	["trap_watch_in_4"] = 4,
	["trap_watch_in_5"] = 5,
	["trap_watch_in_6"] = 7,	--不是写错了，6和7对调
	["trap_watch_in_7"] = 6,
	["trap_watch_in_8"] = 8,
}

--阶段成就
STATE_ACHIEVEMENT	= 
{
	[preEnv.XT("16強賽")] = "FactionBattle_2",
	[preEnv.XT("8強賽")] = "FactionBattle_3",
	[preEnv.XT("半決賽")] = "FactionBattle_4",
	[preEnv.XT("決賽")] = "FactionBattle_5",
}

if preEnv then
	preEnv.setfenv(1, preEnv); --恢复全局环境
end
