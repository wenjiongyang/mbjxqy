local tb = {
  xmhj_buff_recover = {
    recover_life_p = {
      {
        {1, 4},
        {20, 100}
      },
      15
    },
    skill_statetime = {
      {
        {1, 75},
        {20, 75}
      }
    }
  },
  xmhj_buff_adddamage = {
    physics_potentialdamage_p = {
      {
        {1, 100},
        {20, 200}
      }
    },
    skill_statetime = {
      {
        {1, 2700},
        {20, 2700}
      }
    }
  },
  xmhj_buff_series = {
    all_series_resist_p = {
      {
        {1, 200},
        {20, 300}
      }
    },
    skill_statetime = {
      {
        {1, 2700},
        {30, 2700}
      }
    }
  },
  xmhj_buff_runspeed = {
    runspeed_p = {
      {
        {1, 40},
        {20, 100}
      }
    },
    skill_statetime = {
      {
        {1, 2700},
        {30, 2700}
      }
    }
  },
  xmhj_buff_huixin = {
    deadlystrike_v = {
      {
        {1, 1500},
        {30, 1500}
      }
    },
    deadlystrike_damage_p = {
      {
        {1, 30},
        {30, 30}
      }
    },
    skill_statetime = {
      {
        {1, 2700},
        {30, 2700}
      }
    }
  },
  xmhj_buff_wudi = {
    invincible_b = {1},
    skill_statetime = {
      {
        {1, 225},
        {30, 225}
      }
    }
  },
  xmhj_jujin = {
    attack_usebasedamage_p = {
      {
        {1, 250},
        {30, 540}
      }
    },
    state_hurt_attack = {50, 37.5},
    state_npchurt_attack = {50, 37.5}
  },
  xmhj_jumu = {
    attack_usebasedamage_p = {
      {
        {1, 250},
        {30, 540}
      }
    },
    state_zhican_attack = {50, 37.5}
  },
  xmhj_jushui = {
    attack_usebasedamage_p = {
      {
        {1, 250},
        {30, 540}
      }
    },
    state_slowall_attack = {50, 37.5}
  },
  xmhj_juhuo = {
    attack_usebasedamage_p = {
      {
        {1, 250},
        {30, 540}
      }
    },
    state_confuse_attack = {50, 37.5}
  },
  xmhj_jutu = {
    attack_usebasedamage_p = {
      {
        {1, 250},
        {30, 540}
      }
    },
    state_stun_attack = {50, 37.5}
  },
  xmhj_gunshi = {
    attack_usebasedamage_p = {
      {
        {1, 150},
        {30, 440}
      }
    },
    state_knock_attack = {
      {
        {1, 100},
        {10, 100}
      },
      7,
      20
    },
    state_npcknock_attack = {
      {
        {1, 100},
        {10, 100}
      },
      7,
      20
    },
    spe_knock_param = {
      0,
      9,
      9
    }
  },
  xmhj_jlxj = {
    attack_usebasedamage_p = {
      {
        {1, 150},
        {30, 440}
      }
    },
    state_stun_attack = {100, 22.5}
  },
  xmhj_dgjg = {
    attack_usebasedamage_p = {
      {
        {1, 150},
        {30, 440}
      }
    },
    state_hurt_attack = {100, 22.5},
    state_npchurt_attack = {100, 22.5}
  },
  xmhj_dwjg = {
    attack_usebasedamage_p = {
      {
        {1, 100},
        {30, 390}
      }
    },
    state_zhican_attack = {100, 22.5}
  },
  xmhj_psjg = {
    attack_usebasedamage_p = {
      {
        {1, 150},
        {30, 440}
      }
    },
    state_slowall_attack = {100, 37.5}
  },
  xmhj_jianzhanli = {
    fightpower_v1 = {
      {
        {1, -89100},
        {100, -500000}
      }
    },
    lifereplenish_p = {
      {
        {1, -30},
        {100, -30}
      }
    },
    steallife_p = {
      {
        {1, -10},
        {100, -10}
      }
    },
    skill_statetime = {
      {
        {1, -1},
        {30, -1}
      }
    }
  },
  xmhj_bzjg = {
    attack_usebasedamage_p = {
      {
        {1, 150},
        {30, 440}
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
  }
}
FightSkill:AddMagicData(tb)
