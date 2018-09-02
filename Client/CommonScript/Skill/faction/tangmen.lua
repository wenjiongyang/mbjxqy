local tb = {
  tm_pg1 = {
    attack_attackrate_v = {
      {
        {1, 100},
        {20, 100},
        {30, 100},
        {32, 100}
      }
    },
    attack_usebasedamage_p = {
      {
        {1, 40},
        {20, 70},
        {30, 100},
        {32, 120}
      }
    },
    attack_wooddamage_v = {
      [1] = {
        {1, 30},
        {20, 123.5},
        {30, 285},
        {32, 332.5}
      },
      [3] = {
        {1, 30},
        {20, 136.5},
        {30, 315},
        {32, 367.5}
      }
    },
    state_npchurt_attack = {100, 7},
    keephide = {},
    missile_hitcount = {
      1,
      1,
      1
    }
  },
  tm_pg2 = {
    attack_attackrate_v = {
      {
        {1, 100},
        {20, 100},
        {30, 100},
        {32, 100}
      }
    },
    attack_usebasedamage_p = {
      {
        {1, 40},
        {20, 70},
        {30, 110},
        {32, 120}
      }
    },
    attack_wooddamage_v = {
      [1] = {
        {1, 30},
        {20, 133},
        {30, 285},
        {32, 332.5}
      },
      [3] = {
        {1, 30},
        {20, 147},
        {30, 315},
        {32, 367.5}
      }
    },
    state_npchurt_attack = {100, 7},
    keephide = {},
    missile_hitcount = {
      1,
      1,
      1
    }
  },
  tm_pg3 = {
    attack_attackrate_v = {
      {
        {1, 100},
        {20, 100},
        {30, 100},
        {32, 100}
      }
    },
    attack_usebasedamage_p = {
      {
        {1, 60},
        {20, 80},
        {30, 110},
        {32, 120}
      }
    },
    attack_wooddamage_v = {
      [1] = {
        {1, 60},
        {20, 171},
        {30, 332.5},
        {32, 380}
      },
      [3] = {
        {1, 60},
        {20, 189},
        {30, 367.5},
        {32, 420}
      }
    },
    state_npchurt_attack = {100, 7},
    keephide = {},
    missile_hitcount = {
      1,
      1,
      1
    }
  },
  tm_pg4 = {
    attack_attackrate_v = {
      {
        {1, 100},
        {20, 100},
        {30, 100},
        {32, 100}
      }
    },
    attack_usebasedamage_p = {
      {
        {1, 80},
        {20, 130},
        {30, 170},
        {32, 180}
      }
    },
    attack_wooddamage_v = {
      [1] = {
        {1, 90},
        {20, 285},
        {30, 475},
        {32, 522.5}
      },
      [3] = {
        {1, 90},
        {20, 315},
        {30, 525},
        {32, 577.5}
      }
    },
    state_zhican_attack = {
      {
        {1, 40},
        {20, 40},
        {30, 40},
        {32, 40}
      },
      {
        {1, 7.5},
        {20, 7.5},
        {30, 7.5},
        {32, 7.5}
      }
    },
    state_npchurt_attack = {100, 7},
    keephide = {},
    missile_hitcount = {
      1,
      1,
      1
    }
  },
  tm_dgc = {
    userdesc_000 = {4007},
    skill_point = {
      {
        {1, 200},
        {7, 200},
        {8, 300},
        {10, 300},
        {11, 400},
        {13, 400},
        {14, 500},
        {15, 600},
        {16, 600},
        {21, 600}
      },
      {
        {1, 100},
        {15, 100},
        {16, 100},
        {21, 100}
      }
    },
    skill_maxmissile = {
      {
        {1, 2},
        {8, 3},
        {15, 6},
        {16, 6},
        {21, 6}
      }
    },
    keephide = {},
    missile_hitcount = {
      {
        {1, 3},
        {15, 3},
        {16, 3}
      }
    }
  },
  tm_dgc_child = {
    attack_usebasedamage_p = {
      {
        {1, 150},
        {15, 240},
        {16, 250},
        {21, 290}
      }
    },
    attack_wooddamage_v = {
      [1] = {
        {1, 180},
        {15, 540},
        {16, 630},
        {21, 1080}
      },
      [3] = {
        {1, 220.00000000000003},
        {15, 660},
        {16, 770.0000000000001},
        {21, 1320}
      }
    },
    state_zhican_attack = {
      {
        {1, 100},
        {15, 100},
        {16, 100},
        {21, 100}
      },
      {
        {1, 22.5},
        {15, 22.5},
        {16, 22.5},
        {21, 22.5}
      }
    },
    state_fixed_attack = {
      {
        {1, 100},
        {15, 100},
        {16, 100},
        {21, 100}
      },
      {
        {1, 30},
        {15, 37.5},
        {16, 37.5},
        {21, 37.5}
      }
    }
  },
  tm_bylh = {
    skill_point = {
      {
        {1, 100},
        {6, 100},
        {7, 200},
        {13, 200},
        {14, 300},
        {15, 400},
        {16, 400},
        {21, 400}
      },
      {
        {1, 100},
        {15, 100},
        {21, 100}
      }
    },
    attack_usebasedamage_p = {
      {
        {1, 150},
        {15, 200},
        {16, 220},
        {21, 320}
      }
    },
    attack_wooddamage_v = {
      [1] = {
        {1, 200},
        {15, 600},
        {16, 650},
        {21, 900}
      },
      [3] = {
        {1, 200},
        {15, 600},
        {16, 650},
        {21, 900}
      }
    },
    state_npchurt_attack = {100, 6},
    keephide = {},
    missile_hitcount = {
      {
        {1, 3},
        {15, 3},
        {16, 3},
        {21, 3}
      }
    }
  },
  tm_bylh_child = {
    attack_usebasedamage_p = {
      {
        {1, 70},
        {15, 100},
        {16, 110},
        {21, 160}
      }
    },
    attack_wooddamage_v = {
      [1] = {
        {1, 100},
        {15, 300},
        {16, 320},
        {21, 420}
      },
      [3] = {
        {1, 100},
        {15, 300},
        {16, 320},
        {21, 420}
      }
    },
    state_npchurt_attack = {100, 6},
    missile_hitcount = {
      {
        {1, 1},
        {15, 1},
        {16, 1},
        {21, 1}
      }
    }
  },
  tm_myz = {
    skill_mintimepercast_v = {
      {
        {1, 150},
        {15, 105},
        {16, 90},
        {21, 75}
      }
    },
    keephide = {}
  },
  tm_xp = {
    miss_remote_rate = {
      {
        {1, 100},
        {10, 1000},
        {11, 1200}
      }
    },
    skill_statetime = {
      {
        {1, -1},
        {10, -1},
        {11, -1}
      }
    }
  },
  tm_jgfx = {
    userdesc_000 = {4013},
    keephide = {},
    skill_mintimepercast_v = {
      {
        {1, 675},
        {15, 525},
        {16, 510},
        {21, 510}
      }
    }
  },
  tm_jgfx_child = {
    attack_usebasedamage_p = {
      {
        {1, 45},
        {15, 65},
        {16, 67},
        {21, 77}
      }
    },
    attack_wooddamage_v = {
      [1] = {
        {1, 200},
        {15, 400},
        {16, 420},
        {21, 520}
      },
      [3] = {
        {1, 200},
        {15, 400},
        {16, 420},
        {21, 520}
      }
    },
    state_zhican_attack = {
      {
        {1, 20},
        {15, 20},
        {16, 20},
        {21, 20}
      },
      {
        {1, 22.5},
        {15, 22.5},
        {16, 22.5},
        {21, 22.5}
      }
    },
    spe_knock_param1 = {1},
    state_npcknock_attack = {
      100,
      14,
      30
    },
    spe_knock_param = {
      11,
      4,
      26
    },
    missile_hitcount = {
      {
        {1, 1},
        {15, 1},
        {16, 1},
        {21, 1}
      }
    }
  },
  tm_cds = {
    physics_potentialdamage_p = {
      {
        {1, 20},
        {10, 40},
        {11, 42}
      }
    },
    deadlystrike_damage_p = {
      {
        {1, 5},
        {10, 30},
        {11, 32}
      }
    },
    userdesc_102 = {
      {
        {1, 2},
        {10, 15},
        {11, 16}
      }
    },
    skill_statetime = {
      {
        {1, 45},
        {10, 45},
        {11, 45}
      }
    }
  },
  tm_cds_team = {
    deadlystrike_damage_p = {
      {
        {1, 2},
        {10, 15},
        {11, 16}
      }
    },
    skill_statetime = {
      {
        {1, 45},
        {10, 45},
        {11, 45}
      }
    }
  },
  tm_gjaq = {
    add_skill_level = {
      4001,
      {
        {1, 1},
        {10, 10},
        {11, 11}
      },
      0
    },
    add_skill_level2 = {
      4002,
      {
        {1, 1},
        {10, 10},
        {11, 11}
      },
      0
    },
    add_skill_level3 = {
      4003,
      {
        {1, 1},
        {10, 10},
        {11, 11}
      },
      0
    },
    add_skill_level4 = {
      4004,
      {
        {1, 1},
        {10, 10},
        {11, 11}
      },
      0
    },
    userdesc_000 = {4018},
    skill_statetime = {
      {
        {1, -1},
        {10, -1},
        {11, -1}
      }
    }
  },
  tm_gjaq_child = {
    attack_usebasedamage_p = {
      {
        {1, 3},
        {10, 30},
        {11, 34}
      }
    },
    attack_wooddamage_v = {
      [1] = {
        {1, 12},
        {10, 120},
        {11, 132}
      },
      [3] = {
        {1, 12},
        {10, 120},
        {11, 132}
      }
    }
  },
  tm_xy = {
    autoskill = {
      54,
      {
        {1, 1},
        {10, 10},
        {11, 11}
      }
    },
    userdesc_000 = {4020},
    skill_statetime = {
      {
        {1, -1},
        {10, -1},
        {11, -1}
      }
    }
  },
  tm_xy_child = {
    ignore_defense_v = {
      {
        {1, 50},
        {10, 100},
        {11, 105}
      }
    },
    physics_potentialdamage_p = {
      {
        {1, 2},
        {10, 5},
        {11, 5}
      }
    },
    superposemagic = {
      {
        {1, 3},
        {10, 8},
        {11, 8}
      }
    },
    skill_statetime = {
      {
        {1, 45},
        {10, 45},
        {11, 45}
      }
    }
  },
  tm_yxhy = {
    autoskill = {
      55,
      {
        {1, 1},
        {10, 10},
        {11, 11}
      }
    },
    userdesc_000 = {4029},
    userdesc_101 = {
      {
        {1, 40},
        {10, 90},
        {11, 95}
      }
    },
    userdesc_102 = {
      {
        {1, 450},
        {10, 450},
        {11, 450}
      }
    },
    skill_statetime = {
      {
        {1, -1},
        {10, -1},
        {11, -1}
      }
    }
  },
  tm_yxhy_child1 = {
    hide = {
      {
        {1, 30},
        {15, 30},
        {16, 30}
      },
      1
    },
    skill_statetime = {
      {
        {1, 30},
        {10, 30},
        {11, 30}
      }
    }
  },
  tm_yxhy_child2 = {
    reduce_cd_time1 = {
      4010,
      {
        {1, 900},
        {10, 900},
        {11, 900}
      }
    },
    reduce_cd_time2 = {
      4006,
      {
        {1, 75},
        {10, 150},
        {12, 165}
      }
    },
    reduce_cd_time3 = {
      4008,
      {
        {1, 75},
        {10, 150},
        {12, 165}
      }
    },
    reduce_cd_time4 = {
      4012,
      {
        {1, 150},
        {10, 300},
        {12, 330}
      }
    },
    skill_statetime = {
      {
        {1, 2},
        {10, 2},
        {11, 2}
      }
    }
  },
  tm_yxhy_child3 = {
    call_mirror1 = {1965, 1},
    remove_call_npc = {1965},
    skill_statetime = {
      {
        {1, 30},
        {15, 30},
        {16, 30}
      }
    }
  },
  tm_yxhy_child4 = {
    call_masterlife = {
      1965,
      {
        {1, 200},
        {10, 200}
      }
    },
    callnpc_damage = {
      1965,
      {
        {1, 0},
        {10, 0}
      }
    },
    skill_statetime = {
      {
        {1, 30},
        {15, 30}
      }
    }
  },
  tm_xm = {
    physics_potentialdamage_p = {
      {
        {1, 15},
        {20, 40},
        {21, 42}
      }
    },
    lifemax_p = {
      {
        {1, 15},
        {20, 35},
        {21, 36}
      }
    },
    attackspeed_v = {
      {
        {1, 5},
        {20, 20},
        {21, 21}
      }
    },
    state_zhican_attackrate = {
      {
        {1, 80},
        {20, 200},
        {21, 206}
      }
    },
    skill_statetime = {
      {
        {1, -1},
        {20, -1},
        {21, -1}
      }
    }
  },
  tm_zxzd = {
    autoskill = {
      58,
      {
        {1, 1},
        {10, 10},
        {11, 11}
      }
    },
    skill_statetime = {
      {
        {1, -1},
        {10, -1},
        {11, -1}
      }
    },
    userdesc_000 = {4061}
  },
  tm_zxzd_child = {
    state_fixed_attack = {
      {
        {1, 50},
        {10, 80},
        {11, 85}
      },
      {
        {1, 15},
        {10, 37.5},
        {11, 37.5}
      }
    },
    missile_hitcount = {
      {
        {1, 1},
        {10, 1},
        {11, 1}
      }
    }
  },
  tm_qjkql_child1 = {
    attack_usebasedamage_p = {
      {
        {1, 800},
        {30, 800}
      }
    },
    attack_wooddamage_v = {
      [1] = {
        {1, 1800},
        {30, 1800},
        {31, 1800}
      },
      [3] = {
        {1, 2200},
        {30, 2200},
        {31, 2200}
      }
    }
  },
  tm_qjkql_child2 = {
    ignore_series_state = {},
    ignore_abnor_state = {},
    skill_statetime = {
      {
        {1, 20},
        {30, 20}
      }
    }
  }
}
FightSkill:AddMagicData(tb)
