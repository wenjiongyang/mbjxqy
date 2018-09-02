
local tb    = {
    jm_renmai = --任脉技能
    { 
		autoskill={103,{{1,1},{20,20}}},
		userdesc_101={{{1,30},{20,50}}},		--描述用，实际触发几率请查看autoskill.tab中的任脉技能
		userdesc_102={{{1,15*10},{20,15*5}}},	--描述用，实际触发间隔请查看autoskill.tab中的任脉技能
		userdesc_000={4802},	
		skill_statetime={{{1,-1},{20,-1}}},
    },
    jm_renmai_child = --任脉技能
    { 
		attack_usebasedamage_p={{{1,200},{20,500}}},
		missile_hitcount={0,0,6},
    },
    jm_dumai = --督脉技能
    { 
		autoskill={104,{{1,1},{20,20}}},
		userdesc_101={{{1,5},{20,15}}},			--描述用，实际触发几率请查看autoskill.tab中的督脉技能
		userdesc_102={{{1,15*15},{20,15*10}}},	--描述用，实际触发间隔请查看autoskill.tab中的督脉技能
		userdesc_000={4805},
		skill_statetime={{{1,-1},{20,-1}}},
    },
    jm_dumai_child = --督脉技能
    { 
		attack_usebasedamage_p={{{1,50},{20,260}}},
		state_confuse_attack={{{1,100},{20,100}},{{1,15*2},{20,15*2}}},
		missile_hitcount={0,0,1},
    },
}

FightSkill:AddMagicData(tb)