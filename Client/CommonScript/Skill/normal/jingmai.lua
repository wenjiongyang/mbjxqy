local tb = {
  jm_renmai = {
    autoskill = {
      103,
      {
        {1, 1},
        {20, 20}
      }
    },
    userdesc_101 = {
      {
        {1, 30},
        {20, 50}
      }
    },
    userdesc_102 = {
      {
        {1, 150},
        {20, 75}
      }
    },
    userdesc_000 = {4802},
    skill_statetime = {
      {
        {1, -1},
        {20, -1}
      }
    }
  },
  jm_renmai_child = {
    attack_usebasedamage_p = {
      {
        {1, 200},
        {20, 500}
      }
    },
    missile_hitcount = {
      0,
      0,
      6
    }
  },
  jm_dumai = {
    autoskill = {
      104,
      {
        {1, 1},
        {20, 20}
      }
    },
    userdesc_101 = {
      {
        {1, 5},
        {20, 15}
      }
    },
    userdesc_102 = {
      {
        {1, 225},
        {20, 150}
      }
    },
    userdesc_000 = {4805},
    skill_statetime = {
      {
        {1, -1},
        {20, -1}
      }
    }
  },
  jm_dumai_child = {
    attack_usebasedamage_p = {
      {
        {1, 50},
        {20, 260}
      }
    },
    state_confuse_attack = {
      {
        {1, 100},
        {20, 100}
      },
      {
        {1, 30},
        {20, 30}
      }
    },
    missile_hitcount = {
      0,
      0,
      1
    }
  }
}
FightSkill:AddMagicData(tb)
