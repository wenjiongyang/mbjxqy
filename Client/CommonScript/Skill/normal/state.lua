local tb = {
  taskspeed = {
    runspeed_v = {
      {
        {1, 200},
        {2, 300},
        {3, 300}
      }
    },
    skill_statetime = {
      {
        {1, 150},
        {30, 150}
      }
    }
  },
  protect = {
    protected = {1},
    skill_statetime = {45}
  },
  pray_gold = {
    enhance_exp_p = {10}
  },
  pray_wood = {
    exp_coin_contrib = {
      0,
      10,
      0
    }
  },
  pray_water = {
    exp_coin_contrib = {
      0,
      0,
      10
    }
  },
  pray_fire = {
    recdot_wood_p = {
      {
        {1, -10},
        {2, -10}
      }
    },
    resist_allseriesstate_time_v = {
      {
        {1, 300},
        {2, 300},
        {30, 3000}
      }
    },
    resist_allspecialstate_time_v = {
      {
        {1, 300},
        {2, 300},
        {30, 3000}
      }
    },
    state_npchurt_ignore = {1},
    state_npcknock_ignore = {1},
    state_stun_ignore = {1},
    state_zhican_ignore = {1},
    state_slowall_ignore = {1},
    state_palsy_ignore = {1},
    state_float_ignore = {1},
    damage4npc_p = {
      {
        {1, -20},
        {2, -40},
        {3, -50},
        {30, -50}
      }
    },
    skill_statetime = {
      {
        {1, -1},
        {30, -1}
      }
    }
  },
  pray_earth = {
    all_series_resist_v = {
      {
        {1, 6},
        {2, 12},
        {3, 21},
        {4, 30},
        {5, 40},
        {6, 50},
        {7, 75},
        {8, 100},
        {9, 100}
      }
    },
    skill_statetime = {
      {
        {1, 108000},
        {30, 108000}
      }
    }
  },
  ttt_protect = {
    protected = {1},
    hide = {54000, 0},
    super_hide = {},
    end_breakhide = {},
    locked_state = {
      [1] = {
        {1, 0},
        {10, 0}
      },
      [2] = {
        {1, 1},
        {10, 1}
      },
      [3] = {
        {1, 0},
        {10, 0}
      }
    },
    skill_statetime = {54000}
  },
  hs_protect = {
    hide = {54000, 0},
    super_hide = {},
    end_breakhide = {},
    locked_state = {
      [1] = {
        {1, 0},
        {10, 0}
      },
      [2] = {
        {1, 1},
        {10, 1}
      },
      [3] = {
        {1, 0},
        {10, 0}
      }
    },
    skill_statetime = {54000}
  },
  buff_xiulianzhu = {
    call_script = {},
    skill_statetime = {
      {
        {1, 900},
        {30, 900}
      }
    }
  },
  dazuo = {
    recover_life_p = {
      {
        {1, 7},
        {20, 7}
      },
      30
    },
    skill_statetime = {
      {
        {1, 450},
        {20, 450}
      }
    }
  },
  addexp_5 = {
    enhance_exp_p = {5},
    skill_statetime = {27000}
  },
  addexp_20 = {
    enhance_exp_p = {20},
    skill_statetime = {27000}
  },
  forbidmove = {
    locked_state = {
      [1] = {
        {1, 1},
        {10, 1}
      },
      [2] = {
        {1, 0},
        {10, 0}
      },
      [3] = {
        {1, 0},
        {10, 0}
      }
    },
    skill_statetime = {27000}
  },
  forbidall = {
    locked_state = {
      [1] = {
        {1, 1},
        {10, 1}
      },
      [2] = {
        {1, 1},
        {10, 1}
      },
      [3] = {
        {1, 1},
        {10, 1}
      }
    },
    invincible_b = {1},
    skill_statetime = {27000}
  },
  forbidallandhide = {
    hide = {54000, 0},
    super_hide = {},
    end_breakhide = {},
    locked_state = {
      [1] = {
        {1, 1},
        {10, 1}
      },
      [2] = {
        {1, 1},
        {10, 1}
      },
      [3] = {
        {1, 1},
        {10, 1}
      }
    },
    invincible_b = {1},
    skill_statetime = {27000}
  },
  buff_zongzi = {
    physical_damage_v = {
      [1] = {
        {1, 60},
        {2, 60}
      },
      [3] = {
        {1, 60},
        {2, 60}
      }
    },
    lifemax_v = {
      {
        {1, 1200},
        {1, 1200}
      }
    },
    all_series_resist_v = {
      {
        {1, 60},
        {2, 60}
      }
    },
    skill_statetime = {
      {
        {1, 108000},
        {30, 108000}
      }
    }
  },
  debuff_qiankuan = {
    physics_potentialdamage_p = {
      {
        {1, -50},
        {2, -100},
        {5, -500}
      }
    },
    all_series_resist_p = {
      {
        {1, -100},
        {2, -200},
        {5, -500}
      }
    },
    enhance_exp_p = {
      {
        {1, -20},
        {2, -40},
        {5, -80}
      }
    },
    skill_statetime = {
      {
        {1, 108000},
        {30, 108000}
      }
    }
  },
  debuff_qiankuan_fightpower = {
    fightpower_v1 = {
      {
        {1, -50000},
        {100, -5000000}
      }
    },
    skill_statetime = {
      {
        {1, 108000},
        {30, 108000}
      }
    }
  },
  buff_jiebai = {
    physical_damage_v = {
      [1] = {
        {1, 30},
        {2, 60}
      },
      [3] = {
        {1, 30},
        {2, 60}
      }
    },
    lifemax_v = {
      {
        {1, 500},
        {1, 1200}
      }
    },
    all_series_resist_v = {
      {
        {1, 30},
        {2, 60}
      }
    },
    skill_statetime = {
      {
        {1, 108000},
        {30, 108000}
      }
    }
  },
  buff_forbidsteallife = {
    steallife_p = {-100},
    skill_statetime = {
      {
        {1, 9000},
        {30, 9000}
      }
    }
  },
  buff_chongjujianghu = {
    enhance_exp_p = {5},
    basic_damage_v = {
      [1] = {
        {1, 70},
        {2, 70}
      },
      [3] = {
        {1, 70},
        {2, 70}
      }
    },
    all_series_resist_v = {
      {
        {1, 70},
        {2, 70}
      }
    },
    lifemax_v = {
      {
        {1, 1500},
        {2, 1500}
      }
    },
    skill_statetime = {
      {
        {1, 9000},
        {2, 9000}
      }
    }
  },
  buff_arborday = {
    damage4npc_p = {50},
    skill_statetime = {
      {
        {1, 27000},
        {30, 27000}
      }
    }
  },
  buff_qingming = {
    all_series_resist_v = {1},
    skill_statetime = {
      {
        {1, -1},
        {30, -1}
      }
    }
  }
}
FightSkill:AddMagicData(tb)
