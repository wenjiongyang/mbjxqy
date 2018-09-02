local tb = {
  jianta = {
    attack_usebasedamage_p = {
      {
        {1, 100},
        {30, 100}
      }
    }
  },
  zc_buff_adddamage = {
    physics_potentialdamage_p = {
      {
        {1, 200},
        {30, 200}
      }
    },
    skill_statetime = {
      {
        {1, 1350},
        {30, 1350}
      }
    }
  },
  zc_buff_recover = {
    vitality_recover_life = {
      {
        {1, 20},
        {30, 20}
      },
      15
    },
    skill_statetime = {
      {
        {1, 225},
        {30, 225}
      }
    }
  },
  zc_buff_series = {
    all_series_resist_p = {
      {
        {1, 300},
        {30, 300}
      }
    },
    skill_statetime = {
      {
        {1, 1350},
        {30, 1350}
      }
    }
  },
  zc_buff_qiangli = {
    all_series_resist_v = {
      {
        {1, 100},
        {30, 300}
      }
    },
    lifemax_v = {
      {
        {1, 4000},
        {30, 10000}
      }
    },
    resist_allseriesstate_rate_v = {
      {
        {1, 150},
        {10, 500}
      }
    },
    resist_allseriesstate_time_v = {
      {
        {1, 100},
        {10, 200}
      }
    },
    resist_allspecialstate_rate_v = {
      {
        {1, 150},
        {10, 500}
      }
    },
    resist_allspecialstate_time_v = {
      {
        {1, 100},
        {10, 200}
      }
    },
    skill_statetime = {
      {
        {1, 9000},
        {30, 9000}
      }
    }
  },
  moba_maxlife_atk = {
    dotdamage_maxlife_p = {
      {
        {1, 10},
        {30, 39}
      },
      15,
      500000
    },
    skill_statetime = {
      {
        {1, 2},
        {30, 2}
      }
    }
  },
  zc_debuff_player = {
    special_dmg_p = {
      {
        {1, -50},
        {30, -340}
      }
    },
    skill_statetime = {
      {
        {1, 45},
        {30, 45}
      }
    }
  },
  zc_npc_normal = {
    attack_usebasedamage_p = {
      {
        {1, 100},
        {30, 390}
      }
    },
    missile_hitcount = {
      {
        {1, 1},
        {30, 1}
      }
    }
  },
  zc_boss1 = {
    dotdamage_maxlife_p = {
      {
        {1, 10},
        {30, 39}
      },
      15,
      1000000
    },
    skill_statetime = {
      {
        {1, 2},
        {30, 2}
      }
    }
  },
  zc_boss2 = {
    attackspeed_v = {
      {
        {1, 50},
        {30, 50}
      }
    },
    deccdtime = {
      3757,
      {
        {1, 22.5},
        {30, 22.5}
      }
    },
    skill_statetime = {
      {
        {1, 150},
        {30, 150}
      }
    }
  },
  zc_boss3 = {
    dotdamage_maxlife_p = {
      {
        {1, 30},
        {30, 39}
      },
      15,
      2000000
    },
    skill_statetime = {
      {
        {1, 2},
        {30, 2}
      }
    },
    state_npchurt_attack = {100, 9},
    state_hurt_attack = {100, 9}
  },
  moba_buff_recover = {
    recover_life_p = {
      {
        {1, 5},
        {20, 100}
      },
      15
    },
    skill_statetime = {
      {
        {1, 90},
        {20, 90}
      }
    }
  },
  moba_buff_adddamage = {
    physics_potentialdamage_p = {
      {
        {1, 100},
        {20, 200}
      }
    },
    skill_statetime = {
      {
        {1, 900},
        {20, 900}
      }
    }
  },
  moba_buff_series = {
    all_series_resist_p = {
      {
        {1, 200},
        {20, 300}
      }
    },
    skill_statetime = {
      {
        {1, 900},
        {30, 900}
      }
    }
  },
  moba_buff_runspeed = {
    runspeed_p = {
      {
        {1, 40},
        {20, 100}
      }
    },
    skill_statetime = {
      {
        {1, 900},
        {30, 900}
      }
    }
  },
  moba_buff_huixin = {
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
        {1, 900},
        {30, 900}
      }
    }
  },
  moba_buff_wudi = {
    invincible_b = {1},
    skill_statetime = {
      {
        {1, 225},
        {30, 225}
      }
    }
  }
}
FightSkill:AddMagicData(tb)
