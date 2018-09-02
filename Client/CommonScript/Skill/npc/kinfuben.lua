local tb = {
  kinfuben_1 = {
    attack_usebasedamage_p = {
      {
        {1, 100},
        {20, 100}
      }
    },
    state_stun_attack = {
      {
        {1, 100},
        {20, 100}
      },
      {
        {1, 45},
        {20, 45}
      }
    }
  },
  kinfuben_2 = {
    attack_usebasedamage_p = {
      {
        {1, 100},
        {20, 100}
      }
    },
    state_knock_attack = {
      100,
      35,
      30
    },
    state_npcknock_attack = {
      100,
      35,
      30
    },
    spe_knock_param = {
      26,
      26,
      26
    }
  },
  kinfuben_3 = {
    attack_usebasedamage_p = {
      {
        {1, 100},
        {20, 100}
      }
    }
  },
  kinfuben_4 = {
    meleedamagereturn_p = {
      {
        {1, 100},
        {20, 100}
      }
    },
    rangedamagereturn_p = {
      {
        {1, 100},
        {20, 100}
      }
    }
  }
}
FightSkill:AddMagicData(tb)
