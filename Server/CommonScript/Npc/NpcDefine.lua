Npc.KIND = {
	none = -1,
	normal = 0,
	player = 1,
	dialoger = 2,
	partner = 3,
	silencer = 4,
	num = 5,
}

Npc.Series = {
	[1] = "金",
	[2] = "木",
	[3] = "水",
	[4] = "火",
	[5] = "土",
}

Npc.SeriesColor = {
	[1] = "F8CE26";
	[2] = "2CC517";
	[3] = "32B3DD";
	[4] = "F4480D";
	[5] = "87683D";
};

-- 与NpcDefine.h当中的枚举保持一致
Npc.Doing = {
	none            = 0,
	stand           = 1,
	run             = 2,
	skill           = 3,
	jump            = 4,
	death           = 5,
	revive          = 6,
	knockback       = 7,
	force_attack    = 8,
	rand_move       = 9,
	runattack       = 10,
	ctrl_run_attack = 11,
	common          = 12,
	runattackmany   = 13,
	float           = 14,
	sit             = 15,
}

-- 与NpcRelation.h当中的枚举保持一致
Npc.RELATION =
{
	self   = 0,
	obj    = 1,
	npc    = 2,
	player = 3,
	hide   = 4,
	enemy  = 5,
	team   = 6,
	kin    = 7,
	num    = 8,
};

Npc.RELATION_TYPE =
{
	Must = 1;
	Allow = 2;
	Forbid = 3;
}

Npc.DIALOG_DISTANCE = 250;

--npc 状态 和 skiidefine.h 中枚举一样
Npc.STATE = {
	HURT			= 0;		-- 受伤动作状态
	ZHICAN 			= 1;		-- 致残
	SLOWALL			= 2;		-- 迟缓状态
	PALSY			= 3;		-- 麻痹状态
	STUN			= 4;		-- 眩晕状态

	FIXED			= 5; 		-- 定身
	WEAK			= 6;		-- 虚弱状态
	BURN			= 7;		-- 灼伤状态
	SLOWRUN			= 8;		-- 减跑速状态
	FREEZE			= 9;		-- 冻结状态
	CONFUSE			= 10;		-- 混乱状态
	KNOCK			= 11;		-- 击退状态
	DRAG			= 12;		-- 拉回
	SILENCE			= 13;		-- 沉默
	FLOAT			= 14;		-- 浮空
	SELFFREEZE		= 15;		-- 冰箱
	SLEEP			= 16;		-- 睡眠
	KNOCK2			= 17;		-- 击退
	NOJUMP 			= 18; 		-- 禁用轻功
	FORCEATK 		= 19; 		-- 嘲讽
	DRAGFLOAT 		= 20; 		-- 空中拉到地上
	NPC_HURT 		= 21;   	-- Npc受伤
	NPC_KNOCK		= 22;		-- Npc击退

	NPC_HIDE        = 23;       --隐身
}


Npc.FIGHT_MODE =
{
	emFightMode_None = 0,			--非战斗状态
	emFightMode_Fight = 1,			--战斗状态
	emFightMode_Death = 2,			--幽灵状态，和所有Npc（包括玩家）都是非敌对关系，但是表现为战斗状态
};

Npc.ActEventNameType =
{
	act_cast_skill = 1,
	act_play_effect = 2,
	act_clear_effect = 3,
	act_unbind_effect = 4,
	act_event_print = 5,
	act_event_play_shake = 6,
	act_event_stop_shake = 7,
	act_link_init = 8,
	act_cast_link_skill = 9,
	act_event_move_pos = 10,
	act_event_instant_dir = 11,
	act_cross_fade = 12,
	act_use_last_act = 13,
	act_play_scene_effect = 14,
	act_npc_change_size = 15,
	act_open_scene_gray = 16,
	act_close_scene_gray = 17,
};


Npc.CampTypeDef =
{
	camp_type_player = 0,
	camp_type_npc    = 1,
	camp_type_neutrality = 2, --中立
	camp_type_song   = 3, --宋
	camp_type_jin    = 4, --金
}

Npc.tbCampTypeName =
{
	[Npc.CampTypeDef.camp_type_neutrality] = "中立";
	[Npc.CampTypeDef.camp_type_song]       = "宋";
	[Npc.CampTypeDef.camp_type_jin]        = "金";
}

Npc.NpcResPartsDef =
{
	npc_part_body = 0,
	npc_part_weapon = 1,
	npc_part_wing = 2,
	npc_part_horse = 3,
	npc_res_part_count = 4,
};

Npc.NpcPartLayerDef =
{
	npc_part_layer_base = 0,
	npc_part_layer_effect = 1,
	npc_part_layer_count = 2,
};

Npc.emNPC_FLYCHAR_ADD_EXP = 8;

Npc.MAX_NPC_LEVEL = 255; --Npc最大等级

Npc.NpcActionModeType =
{
	act_mode_none = 0,
	act_mode_ride = 1,
};

Npc.nMaxAwardLen = 1400; --野外打怪Npc的奖励范围（经验、掉落）

Npc.nDialogSoundScale = 300	-- NPC说话的音量缩放(100为原始大小，500为原始大小的5倍，依次类推)

Npc.tbActionBQNpcID = --可以播放表情的NpcID
{
	[2353] = 1,
	[2354] = 1,
	[2355] = 1,
	[2356] = 1,
	[2357] = 1,
	[2358] = 1,
	[2359] = 1,
	[2360] = 1,
	[2361] = 1,
};