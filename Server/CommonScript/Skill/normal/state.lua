
local tb    = {
	taskspeed=
    { 
		runspeed_v={{{1,200},{2,300},{3,300}}},
		skill_statetime={{{1,15*10},{30,15*10}}},
    },
	protect=
    { 
		protected={1},
		skill_statetime={15*3},
    },
	pray_gold=
    { 
		enhance_exp_p={10},
	--	physical_damage_v={
	--		[1]={{1,12},{2,24},{3,42},{4,60},{5,80},{6,100},{7,150},{8,200},{9,200}},
	--		[3]={{1,12},{2,24},{3,42},{4,60},{5,80},{6,100},{7,150},{8,200},{9,200}}
	--		},
	--	skill_statetime={{{1,15*60*60*2},{30,15*60*60*2}}},
    },
	pray_wood=
    { 
		exp_coin_contrib={0,10, 0},
	--	lifemax_v={{{1,240},{2,480},{3,840},{4,1200},{5,1600},{6,2000},{7,3000},{8,4000},{9,4000}}},
	--	skill_statetime={{{1,15*60*60*2},{30,15*60*60*2}}},
    },
	pray_water=
    { 
		exp_coin_contrib={0,0, 10},
	--	defense_v={{{1,12},{2,24},{3,42},{4,60},{5,80},{6,100},{7,150},{8,200},{9,200}}},
	--	weaken_deadlystrike_v={{{1,6},{2,12},{3,21},{4,30},{5,40},{6,50},{7,75},{8,100},{9,100}}},
	--	skill_statetime={{{1,15*60*60*2},{30,15*60*60*2}}},
    },
	pray_fire=
    { 
		recdot_wood_p={{{1,-10},{2,-10}}},
	
		resist_allseriesstate_time_v={{{1,300},{2,300},{30,3000}}},		--抗属性时间
		resist_allspecialstate_time_v={{{1,300},{2,300},{30,3000}}},	--抗负面时间
		state_npchurt_ignore={1},									--免疫NPC受伤状态
		state_npcknock_ignore={1},									--免疫NPC击退状态
		state_stun_ignore={1},										--免疫眩晕状态
		state_zhican_ignore={1},									--免疫致残状态
		state_slowall_ignore={1},									--免疫迟缓状态
		state_palsy_ignore={1},										--免疫麻痹状态
		state_float_ignore={1},										--免疫浮空状态		
		damage4npc_p={{{1,-20},{2,-40},{3,-50},{30,-50}}},					--减少对同伴的攻击伤害
		skill_statetime={{{1,-1},{30,-1}}},
    },
	pray_earth=
    { 
		all_series_resist_v={{{1,6},{2,12},{3,21},{4,30},{5,40},{6,50},{7,75},{8,100},{9,100}}},
		skill_statetime={{{1,15*60*60*2},{30,15*60*60*2}}},
    },
	ttt_protect = --通天塔强力隐身
    { 
		protected={1},
		hide = {15*60*60, 0};
		super_hide = {};
		end_breakhide = {};
		locked_state ={--是否不能移动,使用技能,使用物品
			[1] = {{1,0},{10,0}},
			[2] = {{1,1},{10,1}},
			[3] = {{1,0},{10,0}},
			},
		skill_statetime={15*60*60},
    },
	hs_protect = --华山强力隐身
    { 
		hide = {15*60*60, 0};
		super_hide = {};
		end_breakhide = {};
		locked_state ={--是否不能移动,使用技能,使用物品
			[1] = {{1,0},{10,0}},
			[2] = {{1,1},{10,1}},
			[3] = {{1,0},{10,0}},
			},
		skill_statetime={15*60*60},
    },
	buff_xiulianzhu=
    { 
		call_script={},
		skill_statetime={{{1,15*60},{30,15*60}}},
    },
	dazuo =
    { 
		recover_life_p={{{1,7},{20,7}},30},
		skill_statetime={{{1,15*30},{20,15*30}}},
    },
	addexp_5=
    { 
		enhance_exp_p={5},
		skill_statetime={15*60*30},
    },
	addexp_20=
    { 
		enhance_exp_p={20},
		skill_statetime={15*60*30},
    },
	forbidmove=
    {
		locked_state ={--是否不能移动,使用技能,使用物品
			[1] = {{1,1},{10,1}},
			[2] = {{1,0},{10,0}},
			[3] = {{1,0},{10,0}},
			},
		skill_statetime={15*60*30},
    },
	forbidall=
    {
		locked_state ={--是否不能移动,使用技能,使用物品
			[1] = {{1,1},{10,1}},
			[2] = {{1,1},{10,1}},
			[3] = {{1,1},{10,1}},
			},
		invincible_b={1},
		skill_statetime={15*60*30},
    },
	forbidallandhide=
    {
		hide = {15*60*60, 0};
		super_hide = {};
		end_breakhide = {};
		locked_state ={--是否不能移动,使用技能,使用物品
			[1] = {{1,1},{10,1}},
			[2] = {{1,1},{10,1}},
			[3] = {{1,1},{10,1}},
			},
		invincible_b={1},
		skill_statetime={15*60*30},
    },
	buff_zongzi=
    { 
		physical_damage_v={
			[1]={{1,60},{2,60}},
			[3]={{1,60},{2,60}}
			},
		lifemax_v={{{1,1200},{1,1200}}},
		all_series_resist_v={{{1,60},{2,60}}},		
		skill_statetime={{{1,15*60*60*2},{30,15*60*60*2}}},
    },
	debuff_qiankuan=
    { 
	--	physical_damage_v={
	--		[1]={{1,-100},{5,-500}},
	--		[3]={{1,-100},{5,-500}}
	--		},
		physics_potentialdamage_p={{{1,-50},{2,-100},{5,-500}}},
		all_series_resist_p={{{1,-100},{2,-200},{5,-500}}},
		enhance_exp_p={{{1,-20},{2,-40},{5,-80}}},		
		skill_statetime={{{1,15*60*60*2},{30,15*60*60*2}}},
    },
	debuff_qiankuan_fightpower=  --欠款减战力
    { 
		fightpower_v1={{{1,-50000},{100,-5000000}}},
		skill_statetime={{{1,15*60*60*2},{30,15*60*60*2}}},
    },
	
	buff_jiebai=
    { 
		physical_damage_v={
			[1]={{1,30},{2,60}},
			[3]={{1,30},{2,60}}
			},
		lifemax_v={{{1,500},{1,1200}}},
		all_series_resist_v={{{1,30},{2,60}}},		
		skill_statetime={{{1,15*60*60*2},{30,15*60*60*2}}},
    },
	buff_forbidsteallife=
    { 
		steallife_p={-100},
		skill_statetime={{{1,15*60*10},{30,15*60*10}}},
    },
	buff_chongjujianghu=
    { 
		enhance_exp_p={5},
		basic_damage_v={
			[1]={{1,70},{2,70}},
			[3]={{1,70},{2,70}}
			},
		all_series_resist_v={{{1,70},{2,70}}},	 
		lifemax_v={{{1,1500},{2,1500}}},
		skill_statetime={{{1,15*60*10},{2,15*60*10}}},
    },
	buff_arborday=  --植树节活动
    { 
		damage4npc_p={50},
		skill_statetime={{{1,15*60*30},{30,15*60*30}}},
    },
	buff_qingming=  --清明鬼魂状态
    { 
		all_series_resist_v={1},		
		skill_statetime={{{1,-1},{30,-1}}},	
    },
}

FightSkill:AddMagicData(tb)