--服务器判定时间，超过则出结果
RankBattle.BATTLE_TIME_OUT = 90;	-- 战斗超时

--竞技场地图
RankBattle.FIGHT_MAP = 1003

RankBattle.FIGHT_TYPE_NPC = 1
RankBattle.FIGHT_TYPE_PLAYER = 2

--战斗时锁定视角的点
RankBattle.ENTER_POINT = {1900, 2450}
RankBattle.CAMERA_PARAM = 
{
	16.7, 34.87, 48.5,
	40, 90, 0
}

--默认排名
RankBattle.DEF_NO = 3001
RankBattle.DEF_TIMER_AWARD = 500		-- 默认时间奖励

--购买次数价格
RankBattle.BUY_TIMES_COST =	100

--刷新对手时间间隔
RankBattle.FRESH_CD_TIME = 	5

--每次刷新对手消耗元宝
RankBattle.REFRESH_GOLD = 20

--战斗持续时间，时间到则攻方负
RankBattle.BATTLE_TIME = 60		-- 战斗时间

RankBattle.STATUE_ID = 1		-- 雕像ID

RankBattle.NPC_AI = "Setting/Npc/Ai/RankBattle.ini";

RankBattle.tbAWARD_TIME = {22} -- 奖励时间，这里仅仅是UI判断发奖时间，实际时间在ScheduleTask

-- 单场奖励货币
RankBattle.BATTLE_AWARD_TYPE =  "Honor"
RankBattle.WIN_AWARD = 12;
RankBattle.LOST_AWARD = 8;

--RankBattle.GOLD_BOX_ID = 2178				-- 黄金宝箱ID
--RankBattle.SLV_BOX_ID = 2179				-- 白银宝箱ID
RankBattle.AWARD_ITEM = 
{
	{"OpenLevel39", 2178, 2179},			--3级家具	
	{"OpenLevel79", 4465, 4466},			--不产家具	
	{"OpenDay99", 2178, 2179},				--3级家具
	{"OpenLevel99", 4465, 4466},			--不产家具
	{"OpenDay224", 4591, 4592},				--4级家具
	{"OpenLevel119", 4465, 4466},			--不产家具
	{"OpenDay399", 4593, 4594},				--5级家具	
}

RankBattle.GOLD_BOX_VALUE = 1000		-- 黄金宝箱兑换价值
RankBattle.SLV_BOX_VALUE = 500			-- 白银宝箱兑换价值
RankBattle.GOLD_BOX_REQUIRE_NO = 400	-- 黄金宝箱兑换排名要求

-- 定时奖励货币类型
RankBattle.TIME_AWARD_TYPE = "BasicExp";	-- 基准经验



RankBattle.AWARD_ASYNC_VALUE = 43;

RankBattle.tbNPC_POS = 
{
	{	-- 我方点		
		{2600, 2758,},	
		{2038, 2778,},	
		{1500, 2765,},		
		{2600, 3087,},
		{2047, 3078,},
		{1500, 3052,},
		
	}, 
	{	-- 敌方点	
		{1500, 1556,},	
		{2020, 1547,},		
		{2600, 1552,},						
		{1500, 1225,},			
		{2047, 1225,},
		{2600, 1225,},			
	}
}

--优先攻击目标
RankBattle.LOCK_TARGET = 
{
	{3, 6, 2, 5, 1, 4},	-- 1号位
	{2, 5, 3, 6, 1, 4},	-- 2号位
	{1, 4, 2, 5, 3, 6},	-- 3号位
	{3, 6, 2, 5, 1, 4},	-- 4号位
	{2, 5, 3, 6, 1, 4},	-- 5号位
	{1, 4, 2, 5, 3, 6},	-- 6号位
}

RankBattle.NO_LIMIT_RANK = 5;


