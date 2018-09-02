
local tb    = {
	dxz_rxq =  --扔雪球
    { 
		attack_holydamage_v={
			[1]={{1,1},{30,1}},
			[3]={{1,1},{30,1}}
			},
    },
	dxz_xjz =  --雪金针
    { 
		attack_holydamage_v={
			[1]={{1,3},{30,3}},
			[3]={{1,3},{30,3}}
			},
    },
	dxz_cxr =  --绻雪缠
    { 
		attack_holydamage_v={
			[1]={{1,2},{30,2}},
			[3]={{1,2},{30,2}}
			},
		state_fixed_attack={{{1,100},{30,100}},{{1,15*2},{30,15*2}}},
    },
	dxz_rxb =  --柔雪绊
    { 
		attack_holydamage_v={
			[1]={{1,2},{30,2}},
			[3]={{1,2},{30,2}}
			},
		state_freeze_attack={{{1,100},{30,100}},{{1,15*1},{30,15*1}}},
    },
	dxz_mhx =  --迷魂雪
    { 
		attack_holydamage_v={
			[1]={{1,2},{30,2}},
			[3]={{1,2},{30,2}}
			},
		state_confuse_attack={{{1,100},{30,100}},{{1,15*1.5},{30,15*1.5}}},
    },
	dxz_dxj =  --堆雪击
    { 
		attack_holydamage_v={
			[1]={{1,2},{30,2}},
			[3]={{1,2},{30,2}}
			},
		state_stun_attack={{{1,100},{30,100}},{{1,15*1},{30,15*1}}},
    },
	dxz_txwx =  --天仙舞雪
    { 
		attack_holydamage_v={
			[1]={{1,4},{30,4}},
			[3]={{1,4},{30,4}}
			},
		state_slowall_attack={{{1,100},{30,100}},{{1,15*2},{30,15*2}}},
    },
	dxz_tbj =  --踏冰诀
    { 
		runspeed_v={{{1,10},{5,50},{6,50}}},
		skill_statetime={{{1,15*20},{30,15*20}}},
    },
	dxz_css =  --乘霜式
    { 
		addms_speed1={3359,{{1,50},{20,50}}},
		addms_speed2={3360,{{1,80},{20,80}}},
		addms_speed3={3361,{{1,60},{20,60}}},
		addms_life1={3359,{{1,-7},{20,-7}}},
		addms_life2={3360,{{1,-5},{20,-5}}},
		addms_life3={3361,{{1,-7},{20,-7}}},
		skill_statetime={{{1,15*20},{30,15*20}}},
    },
	dxz_css_child1 =  --乘霜式_子1
    { 
		addms_speed1={3362,{{1,60},{20,60}}},
		addms_speed2={3363,{{1,60},{20,60}}},
		addms_speed3={3364,{{1,60},{20,60}}},
		addms_life1={3362,{{1,-7},{20,-7}}},
		addms_life2={3363,{{1,-7},{20,-7}}},
		addms_life3={3364,{{1,-7},{20,-7}}},
		skill_statetime={{{1,15*20},{30,15*20}}},
    },
	dxz_css_child2 =  --乘霜式_子2
    { 
		addms_speed1={3365,{{1,40},{20,40}}},
		addms_life1={3365,{{1,-7},{20,-7}}},
		skill_statetime={{{1,15*20},{30,15*20}}},
    },
    dxz_xyw = --雪影舞
    { 
		ignore_series_state={},	
		ignore_abnor_state={},	
		skill_statetime={{{1,15*20},{10,15*20}}},
    },
	dxz_jby =  --坚冰御
    { 
		invincible_b={1},
		skill_statetime={{{1,15*10},{30,15*10}}},
    },
	dxz_xj_jin =  --陷阱（金）_伤害
    { 
		attack_holydamage_v={
			[1]={{1,4},{30,4}},
			[3]={{1,4},{30,4}}
			},
    },
	dxz_xj_mu =  --陷阱（木）_子
    { 
		attack_holydamage_v={
			[1]={{1,2},{30,2}},
			[3]={{1,2},{30,2}}
			},
    },
	dxz_xj_shui =  --陷阱（水）_子
    { 
		attack_holydamage_v={
			[1]={{1,3},{30,3}},
			[3]={{1,3},{30,3}}
			},
		state_slowall_attack={{{1,100},{30,100}},{{1,15*3},{30,15*3}}},
    },
	dxz_xj_huo =  --陷阱（火）_伤害
    { 
		attack_holydamage_v={
			[1]={{1,5},{30,5}},
			[3]={{1,5},{30,5}}
			},
    },
	dxz_xj_tu =  --陷阱（土）_伤害
    { 
		attack_holydamage_v={
			[1]={{1,4},{30,4}},
			[3]={{1,4},{30,4}}
			},
		state_stun_attack={{{1,100},{30,100}},{{1,15*1},{30,15*1}}},
    }, 
    dxz_nsbz = --年兽冰阵   概率，技能ID，技能等级
    { 
		skill_randskill1={{{1,50},{10,50}},3389,{{1,1},{10,10}}},	
		skill_randskill2={{{1,50},{10,50}},3390,{{1,1},{10,10}}},	
		skill_randskill3={{{1,50},{10,50}},3391,{{1,1},{10,10}}},	
		skill_randskill4={{{1,50},{10,50}},3392,{{1,1},{10,10}}},	
		skill_randskill5={{{1,50},{10,50}},3393,{{1,1},{10,10}}},	
    }, 
    dxz_nsbz_child1 = --年兽冰阵_定身
    { 
		state_fixed_attack={{{1,100},{30,100}},{{1,15*4},{30,15*4}}},
    },
    dxz_nsbz_child2 = --年兽冰阵_冰冻
    { 
		state_freeze_attack={{{1,100},{30,100}},{{1,15*4},{30,15*4}}},
    },
    dxz_nsbz_child3 = --年兽冰阵_混乱
    { 
		state_confuse_attack={{{1,100},{30,100}},{{1,15*4},{30,15*4}}},
    },
    dxz_nsbz_child4 = --年兽冰阵_眩晕
    { 
		state_stun_attack={{{1,100},{30,100}},{{1,15*4},{30,15*4}}},
    },
    dxz_nsbz_child5 = --年兽冰阵_迟缓
    { 
		state_slowall_attack={{{1,100},{30,100}},{{1,15*4},{30,15*4}}},
    },  
	dxz_change_xzboy=  --变身雪仗小男孩
    { 
		shapeshift={2126},								--参数1：npcid
		deadlystrike_v={{{1,-100000},{30,-100000}}},	
		lifemax_v={{{1,100000},{30,100000}}},		
		skill_statetime={{{1,15*200},{30,15*200}}},
    },
	dxz_change_xzgirl=  --变身雪仗小女孩
    { 
		shapeshift={2127},
		deadlystrike_v={{{1,-100000},{30,-100000}}},
		lifemax_v={{{1,100000},{30,100000}}},
		skill_statetime={{{1,15*200},{30,15*200}}},
    },
	dxz_change_smboy=  --变身狮帽小男孩
    { 
		shapeshift={2128},
		deadlystrike_v={{{1,-100000},{30,-100000}}},
		lifemax_v={{{1,100000},{30,100000}}},
		skill_statetime={{{1,15*200},{30,15*200}}},
    },
	dxz_change_smgirl=  --变身狮帽小男孩
    { 
		shapeshift={2129},
		deadlystrike_v={{{1,-100000},{30,-100000}}},
		lifemax_v={{{1,100000},{30,100000}}},
		skill_statetime={{{1,15*200},{30,15*200}}},
    },
	dxz_addskill=  --增加变身技能
    { 
		add_skill_level={{{1, 3360},{2, 3361},{3, 3362},{4, 3363},{5, 3364},{6, 3365}}, 1, 1},  --每个等级对应不同的技能ID，添加的等级，是否添加技能
		skill_statetime={{{1,15*200},{30,15*200}}},
    },
	act_nianshou_yanhua1 =  --烟花技能1
    { 
		attack_holydamage_v={
			[1]={{1,9500},{30,9500}},
			[3]={{1,10500},{30,10500}}
			},
    },
	act_nianshou_yanhua2 =  --烟花技能2
    { 
		attack_holydamage_v={
			[1]={{1,9500},{30,9500}},
			[3]={{1,10500},{30,10500}}
			},
    },
	act_nianshou_yanhua3 =  --烟花技能3
    { 
		attack_holydamage_v={
			[1]={{1,9500},{30,9500}},
			[3]={{1,10500},{30,10500}}
			},
    },
	act_nianshou_chongzhuang =  --年兽冲撞
    { 
		--attack_holydamage_v={
		--	[1]={{1,3000},{30,3000}},
		--	[3]={{1,3000},{30,3000}}
		--	},
		state_knock_attack={100,35,30},			--概率，持续时间，速度
		state_npcknock_attack={100,35,30},
		spe_knock_param={26 , 26, 26},			--停留时间，角色动作ID，NPC动作ID	
    },
	act_nianshou_paoxiao =  --年兽咆哮
    { 
		--attack_holydamage_v={
		--	[1]={{1,3000},{30,3000}},
		--	[3]={{1,3000},{30,3000}}
		--	},
		state_knock_attack={100,35,30},			--概率，持续时间，速度
		state_npcknock_attack={100,35,30},
		spe_knock_param={26 , 26, 26},			--停留时间，角色动作ID，NPC动作ID	
    },
	act_nianshou_bianyang =  --年兽变羊
    { 
		state_confuse_attack={{{1,100},{30,100}},{{1,15*5},{30,15*5}}},	
    },
	act_nianshou_bianyang_child =   --年兽变羊_子
    { 
		shapeshift={2174},								--npcid
		skill_statetime={{{1,15*5},{30,15*5}}},
    },
	act_nianshou_kangxing =   --年兽抗性
    { 
		metal_resist_p={9999},
		wood_resist_p={9999},
		water_resist_p={9999},
		fire_resist_p={9999},
		earth_resist_p={9999},
		skill_statetime={{{1,-1},{30,-1}}},
    },
}

FightSkill:AddMagicData(tb)