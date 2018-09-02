
Env.LOGD_LoginIn 		 = 11;--账号登录
Env.LOGD_LoginOut 		 = 12;--账号登出
Env.LOGD_RechargeGetGold = 13; --“充值”获得人民币代币
Env.LOGD_OtherWagGetGold = 14; --“非充值”获得人民币代币
Env.LOGD_CostGold		 = 15; -- 人民币代币消费
Env.LOGD_RoleLevelUp 	 = 16; --角色升级
Env.LOGD_ActivityPlay 	 = 17; --任务&活动参与
Env.LOGD_ActivityAward	 = 18; --任务&活动奖励获取
Env.LOGD_GetOtherMoney	 = 19; --游戏币/数值货币产出
Env.LOGD_CostOtherMoney	 = 20; --游戏币/数值货币消耗
Env.LOGD_Guide			 = 23; --新手强制引导行为漏斗
Env.LOGD_CostInfo	 	 = 25; --行动力相关行为
Env.LOGD_DailyKin	 	 = 101; --家族数据每日记录 --只记文件
Env.LOGD_ParterInfo	 	 = 102; --玩家下线时记录调用 伙伴信息（必要） --只记文件
Env.LOGD_EquipInfo	 	 = 103; --玩家下线时记录调用 装备信息			--只记文件

Env.LOGD_VAL_TAKE_TASK 	 = 1;  --接受任务
Env.LOGD_VAL_FINISH_TASK = 99; --完成任务

Env.LOGD_MIS_TASK 			= "Task" 			--主线
Env.LOGD_MIS_SUB_TASK 		= "SubTask" 		--支线
Env.LOGD_MIS_COMMERCE	 	= "Commerce_Task"	--商会
Env.LOGD_MIS_BOSS		 	= "Boss"			--挑战武林盟主
Env.LOGD_MIS_BOSS_ROB	 	= "BossRob"			--挑战武林抢夺
Env.LOGD_MIS_KIN_ROBBER	 	= "KinRobber"		--家族盗贼
Env.LOGD_MIS_BATTLE 		= "Battle"			--战场
Env.LOGD_MIS_CANBAOTU 		= "CangBaoTu"		--藏宝图
Env.LOGD_MIS_DEBRIS 		= "Debris" 		--碎片
Env.LOGD_MIS_PUNISH_TASK 	= "PunishTask" 	--惩恶
Env.LOGD_MIS_TEAM_FUBEN		= "TeamFuben"		-- 组队副本
Env.LOGD_MIS_EXPLOR			= "ExplorationFuben" -- 探索
Env.LOGD_MIS_RANKBATTLE		= "RankBattle"		-- 武神殿
Env.LOGD_MIS_RANDOM_FUBEN 	= "RandomFuben"	-- 随机副本
Env.LOGD_MIS_QYH	 		= "QunYingHui" 	-- 群英会
Env.LOGD_MIS_HERO_CHELL	    = "HeroChallenge" 	-- 英雄挑战
Env.LOGD_MIS_FIELDBOSS 		= "FieldBoss"		-- 野外BOSS
Env.LOGD_MIS_FIELDLEADER	= "FieldLeader"	-- 野外首领
Env.LOGD_MIS_QUESTION		= "Question"		-- 答题
Env.LOGD_MIS_PERSONAL_FUBEN	= "PersonalFuben"		-- 关卡
Env.LOGD_MIS_MISSION_AWARD	= "MissionAward"		-- 事后抽奖
Env.LOGD_MIS_KINNEST		= "KinNest"			--家族盗贼巢穴
Env.LOGD_MIS_FACTION_BATTLE 	= "FactionBattle"		--门派竞技


--如果是rondFlow里的类型，请后面注释 round， 这里所有值还需要更新到 tlog_stand.xml
--logway的配置在 Setting\LogWay.tab










Env.LogType_Athletics = "Athletics"; --竞技类型活动
Env.LogType_Activity  = "Activity"; --普通活动类型
Env.LogType_Carnet  = "Carnet"; --通关活动类型
Env.LogType_AsynAthletics  = "AsynAthletics"; --异步竞技类型活动



-- QQ登入时的信息上报
Env.QQReport_Faction              = 35;	-- 职业信息	玩家上线时上报
Env.QQReport_KinId                = 30;	-- 公会ID	玩家上线时上报
Env.QQReport_LevelUp              = 1;	-- 角色等级	变化时上报
Env.QQReport_FightPower           = 17;	-- 战力	变化时上报
Env.QQReport_KinLevel             = 302;	-- 公会等级	变化时上报
Env.QQReport_KinCreateTime        = 306;	-- 公会创建时间	创建时上报
Env.QQReport_KinMemberChange      = 309;	-- 公会成员变动     1-加入    2-退出	变化时上报
Env.QQReport_KinMemberTitleChange = 311;	-- 公会成员身份变更（会长or普通成员）	变化时上报
Env.QQReport_KillCount            = 1013;	-- 累计杀人数	变化时上报
Env.QQReport_Name                 = 29;	-- 角色名	创建角色时上报
Env.QQReport_QQGrpBind            = 312;	-- 公会绑定的QQ群	会长上线时上报
Env.QQReport_QQGrpBindTime        = 313;	-- QQ群的绑定时间	变化时通过会长上报
Env.QQReport_LoginDays            = 1050;	-- 连续登录天数	变化时上报
Env.QQReport_DayOnlineTime        = 6000; -- 当天累计游戏时长
Env.QQReport_KinName              = 301;	-- 公会名称	变化时上报(无法修改, 现创建时也上报)
Env.QQReport_RegisterTime         = 25; --用户注册时间
Env.QQReport_Gold                 = 2; --元宝变化
Env.QQReport_VipLevel             = 45;	-- vip等级变化或登出时
Env.QQReport_RechargeTime         = 46;	-- 充值发生时时间
Env.QQReport_ChangeRoleName       = 47;	-- 创建角色或名称变更时

Env.QQReport_KinDismissTime = 307;	-- 公会解散时间	解散时上报(无法解散)

Env.QQReport_IsJoinSongJin 		  = 1016;	-- 今日是否参与宋金战场	参与宋金战场时进行上报, 没参加则不进行上报
Env.QQReport_SongJinKillCount	  = 1017;	-- 宋金战场杀敌数(每局上报杀敌数)	宋金战场结束时进行上报
Env.QQReport_IsJoinWhiteTiger	  = 1018;	-- 今日是否参与白虎堂	参与白虎堂时进行上报, 没参加则不进行上报
Env.QQReport_IsJoinTeamFuben	  = 1019;	-- 今日是否参与组队副本	 参与组队副本时进行上报, 没参加则不进行上报
Env.QQReport_IsJoinHeroChanllenge = 1020;	-- 今日是否参与英雄挑战	 参与英雄挑战时进行上报, 没参加则不进行上报
Env.QQReport_HeroChanllengeFloor  = 1021;	-- 今日英雄挑战层数（每日上报最大值，每日清零）	 完成英雄挑战时进行上报层数, 没有则不上报
Env.QQReport_IsJoinChuangGong     = 1022;	-- 今日是否参与家族传功	 参与家族传功时进行上报, 没有则不上报
Env.QQReport_IsJoinKinFire        = 1023;	-- 今日是否参与家族烤火	 参与家族烤火时进行上报, 没有则不上报
Env.QQReport_IsJoinSeriesFuben    = 1024;	-- 今日是否参与江湖试练	 参与江湖试练时进行上报, 没有则不上报
Env.QQReport_IsJoinRankBattle	  = 1025;	-- 今日是否参与武神殿	 参与武神殿时进行上报, 没有则不上报
Env.QQReport_IsJoinExploreFuben	  = 1026;	-- 今日是否参与关卡探索	 参与关卡探索时进行上报, 没有则不上报
Env.QQReport_IsJoinBossFight	  = 1027;	-- 今日是否参与武林盟主	 参与武林盟主时进行上报, 没有则不上报
Env.QQReport_IsJoinCangBaoTu	  = 1028;	-- 今日是否参与藏宝图	 使用藏宝图时进行上报, 没有则不上报
Env.QQReport_IsJoinCommerceTask	  = 1029;	-- 今日是否参与商会任务	 领取商会任务时进行上报, 没有则不上报

Env.QQReport_PartnenrSSCount	  = 1030;	-- SS级伙伴数量	SS级同伴数量变化时上报
Env.QQReport_PartnenrSCount	  	  = 1031;	-- S级伙伴数量	S级同伴数量变化时上报
Env.QQReport_PartnenrACount	  	  = 1032;	-- A级伙伴数量	A级同伴数量变化时上报
Env.QQReport_PartnenrBCount		  = 1033;	-- B级伙伴数量	B级同伴数量变化时上报
Env.QQReport_PartnenrCCount		  = 1034;	-- C级伙伴数量	C级同伴数量变化时上报
Env.QQReport_FriendShopTop3		  = 1040;	-- 好友亲密度前3 登出时上报

Env.QQReport_HSLJResult           = 1041;   -- 华山论剑单场胜负结果
Env.QQReport_HSLJKillCount        = 1042;   -- 华山论剑单场杀人数
Env.QQReport_HSLJDeathCount       = 1043;   -- 华山论剑单场死亡次数
Env.QQReport_HSLJPlayTime         = 1044;   -- 华山论剑单场战斗时长

Env.QQReport_SJBattleResult        = 1045;   -- 宋金战场单场胜负结果	
Env.QQReport_SJBattleMaxCombo	   = 1047; 	 --	宋金战场单场连斩数
Env.QQReport_SJBattleDeathCount	   = 1048; 	 --	宋金战场单场死亡数

Env.QQReport_InDifferBattleScore 	= 1054; 	 --	心魔幻境单场积分
Env.QQReport_InDifferBattleKillCount= 1055; 	 --	心魔幻境杀人数


Env.QQReport_RechargeTotalCount	  = 43;		-- 累积充值金额（截止到目前所有的充值金额总和 单位：元）	累计充值金额变动时进行上报
Env.QQReport_RechargeSingleCount  = 44;		-- 单笔的充值金额（单位：元）	有充值发生时进行上报

Env.QQReport_TeamBattle_Result 		= 1049;			-- 通天塔单场胜负结果
Env.QQReport_TeamBattle_KillCount 	= 1056;			-- 单场杀人数
Env.QQReport_TeamBattle_KillCount2	= 1051;			-- 单场连斩数
Env.QQReport_TeamBattle_DeathCount	= 1052;			-- 单场死亡数
Env.QQReport_TeamBattle_FinalFloor	= 1053;			-- 单日达到层数

Env.LogSellType_MarketStall = 1; --拍卖类型（1，摆摊、2家族拍卖，3世界拍卖）
Env.LogSellType_AuctionKin 	= 2;
Env.LogSellType_AuctionAll 	= 3;

Env.LogOnDealType_BidOver	 = 1; --拍品成交状态（1，一口价成交、2，时间截至被竞拍、3，流拍）
Env.LogOnDealType_OnDeal 	 = 2;
Env.LogOnDealType_TimeOut 	 = 3;


local fnCheckData = function ( )
	local tbUseIds = {}
	local tbLogWaySet = LoadTabFile("Setting/LogWay.tab", "sds", nil, {"WayName", "Value", "Desc"  });
	for i,v in ipairs(tbLogWaySet) do
		assert(not tbUseIds[v.Value], v.WayName)
		tbUseIds[v.Value] = 1;
	end
end
fnCheckData()