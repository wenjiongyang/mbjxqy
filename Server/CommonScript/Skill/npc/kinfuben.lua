
local tb    = {
	kinfuben_1= --铜锤蛮士-重锤砸地
    { 
		attack_usebasedamage_p={{{1,100},{20,100}}},
		state_stun_attack={{{1,100},{20,100}},{{1,15*3},{20,15*3}}},
    },
	kinfuben_2= --火炮-火炮
    { 
		attack_usebasedamage_p={{{1,100},{20,100}}},
		state_knock_attack={100,35,30},			--概率，持续时间，速度
		state_npcknock_attack={100,35,30},
		spe_knock_param={26 , 26, 26},			--停留时间，角色动作ID，NPC动作ID		
    },
	kinfuben_3= --蒙面杀手-无形蛊
    { 
		attack_usebasedamage_p={{{1,100},{20,100}}},
    },
    kinfuben_4= --反弹卫士
    {
		meleedamagereturn_p={{{1,100},{20,100}}},
		rangedamagereturn_p={{{1,100},{20,100}}},
    },
}

FightSkill:AddMagicData(tb)