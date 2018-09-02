local tb = {
  th_pg1 = {
    attack_usebasedamage_p = {
      {
        {1, 60},
        {20, 90},
        {30, 120},
        {32, 126}
      }
    },
    attack_firedamage_v = {
      [1] = {
        {1, 30},
        {20, 142.5},
        {30, 256.5},
        {32, 279.3}
      },
      [3] = {
        {1, 30},
        {20, 157.5},
        {30, 283.5},
        {32, 308.7}
      }
    },
    state_npchurt_attack = {100, 7},
    missile_hitcount = {
      {
        {1, 2},
        {20, 2},
        {30, 2},
        {32, 2}
      }
    },
    attack_attackrate_v = {
      {
        {1, 100},
        {20, 100},
        {30, 100},
        {32, 100}
      }
    }
  },
  th_pg2 = {
    attack_usebasedamage_p = {
      {
        {1, 60},
        {20, 90},
        {30, 120},
        {32, 126}
      }
    },
    attack_firedamage_v = {
      [1] = {
        {1, 30},
        {20, 142.5},
        {30, 256.5},
        {32, 279.3}
      },
      [3] = {
        {1, 30},
        {20, 157.5},
        {30, 283.5},
        {32, 308.7}
      }
    },
    state_npchurt_attack = {100, 7},
    missile_hitcount = {
      {
        {1, 2},
        {20, 2},
        {30, 2},
        {32, 2}
      }
    },
    attack_attackrate_v = {
      {
        {1, 100},
        {20, 100},
        {30, 100},
        {32, 100}
      }
    }
  },
  th_pg3 = {
    attack_usebasedamage_p = {
      {
        {1, 60},
        {20, 90},
        {30, 120},
        {32, 126}
      }
    },
    attack_firedamage_v = {
      [1] = {
        {1, 60},
        {20, 171},
        {30, 285},
        {32, 307.8}
      },
      [3] = {
        {1, 60},
        {20, 189},
        {30, 315},
        {32, 340.2}
      }
    },
    state_npchurt_attack = {100, 7},
    missile_hitcount = {
      {
        {1, 3},
        {20, 3},
        {30, 3},
        {32, 3}
      }
    },
    attack_attackrate_v = {
      {
        {1, 100},
        {20, 100},
        {30, 100},
        {32, 100}
      }
    }
  },
  th_pg4 = {
    attack_usebasedamage_p = {
      {
        {1, 90},
        {20, 150},
        {30, 180},
        {32, 186}
      }
    },
    attack_firedamage_v = {
      [1] = {
        {1, 90},
        {20, 285},
        {30, 399},
        {32, 421.79999999999995}
      },
      [3] = {
        {1, 90},
        {20, 315},
        {30, 441},
        {32, 466.20000000000005}
      }
    },
    state_npchurt_attack = {100, 7},
    state_palsy_attack = {
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
    missile_hitcount = {
      {
        {1, 3},
        {20, 3},
        {30, 3},
        {32, 3}
      }
    },
    attack_attackrate_v = {
      {
        {1, 100},
        {20, 100},
        {30, 100},
        {32, 100}
      }
    }
  },
  th_fhlx = {
    attack_usebasedamage_p = {
      {
        {1, 150},
        {15, 260},
        {16, 271},
        {21, 326}
      }
    },
    attack_firedamage_v = {
      [1] = {
        {1, 152},
        {15, 475},
        {16, 497.79999999999995},
        {21, 611.8}
      },
      [3] = {
        {1, 168},
        {15, 525},
        {16, 550.2},
        {21, 676.2}
      }
    },
    state_knock_attack = {
      40,
      12,
      30
    },
    state_npcknock_attack = {
      100,
      12,
      30
    },
    spe_knock_param = {
      9,
      4,
      9
    },
    state_palsy_attack = {
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
    }
  },
  th_jylz_root = {
    userdesc_000 = {411}
  },
  th_jylz = {
    attack_usebasedamage_p = {
      {
        {1, 40},
        {15, 70},
        {16, 72},
        {21, 82}
      }
    },
    attack_firedamage_v = {
      [1] = {
        {1, 57},
        {15, 171},
        {16, 178.6},
        {21, 216.6}
      },
      [3] = {
        {1, 63},
        {15, 189},
        {16, 197.4},
        {21, 239.4}
      }
    },
    state_palsy_attack = {
      {
        {1, 10},
        {15, 10},
        {16, 10},
        {21, 10}
      },
      {
        {1, 7.5},
        {15, 7.5},
        {16, 7.5},
        {21, 7.5}
      }
    },
    state_npchurt_attack = {100, 9}
  },
  th_hfly = {
    runspeed_v = {
      {
        {1, 100},
        {15, 200},
        {16, 210},
        {21, 260}
      }
    },
    attackspeed_v = {
      {
        {1, 20},
        {15, 50},
        {16, 52},
        {21, 62}
      }
    },
    defense_p = {
      {
        {1, 50},
        {15, 100},
        {16, 103},
        {21, 118}
      }
    },
    skill_statetime = {
      {
        {1, 150},
        {15, 150},
        {16, 150},
        {21, 150}
      }
    }
  },
  th_lfhx = {
    physics_potentialdamage_p = {
      {
        {1, 20},
        {10, 50},
        {11, 53}
      }
    },
    state_hurt_resistrate = {
      {
        {1, 20},
        {10, 50},
        {11, 53}
      }
    },
    skill_statetime = {
      {
        {1, -1},
        {10, -1}
      }
    }
  },
  th_cypy_root = {
    userdesc_000 = {438}
  },
  th_cypy = {
    attack_usebasedamage_p = {
      {
        {1, 380},
        {15, 440},
        {16, 444},
        {21, 464}
      }
    },
    attack_firedamage_v = {
      [1] = {
        {1, 900},
        {15, 1440},
        {16, 1476},
        {21, 1656}
      },
      [3] = {
        {1, 1100},
        {15, 1760.0000000000002},
        {16, 1804.0000000000002},
        {21, 2024.0000000000002}
      }
    },
    state_npcknock_attack = {
      100,
      12,
      30
    },
    spe_knock_param = {
      9,
      4,
      26
    },
    missile_hitcount = {
      {
        {1, 4},
        {15, 4},
        {16, 4},
        {21, 4}
      }
    }
  },
  th_nzjy = {
    autoskill = {
      42,
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
    userdesc_000 = {444}
  },
  th_nzjy_child = {
    state_knock_attack = {
      100,
      3,
      80
    },
    state_npcknock_attack = {
      100,
      3,
      80
    },
    spe_knock_param = {
      0,
      9,
      9
    },
    userdesc_105 = {
      {
        {1, 10},
        {10, 30},
        {11, 32}
      },
      {
        {1, 45},
        {10, 45},
        {11, 45}
      }
    }
  },
  th_gjjs = {
    addaction_event1 = {404, 421},
    add_skill_level = {
      401,
      {
        {1, 1},
        {10, 10},
        {11, 11}
      },
      0
    },
    add_skill_level2 = {
      402,
      {
        {1, 1},
        {10, 10},
        {11, 11}
      },
      0
    },
    add_skill_level3 = {
      403,
      {
        {1, 1},
        {10, 10},
        {11, 11}
      },
      0
    },
    add_skill_level4 = {
      404,
      {
        {1, 1},
        {10, 10},
        {11, 11}
      },
      0
    },
    userdesc_000 = {439},
    skill_statetime = {
      {
        {1, -1},
        {20, -1}
      }
    }
  },
  th_gjjs_child1 = {
    attack_usebasedamage_p = {
      {
        {1, 90},
        {20, 150},
        {30, 180},
        {32, 186}
      }
    },
    attack_firedamage_v = {
      [1] = {
        {1, 90},
        {20, 285},
        {30, 399},
        {32, 421.79999999999995}
      },
      [3] = {
        {1, 90},
        {20, 315},
        {30, 441},
        {32, 466.20000000000005}
      }
    },
    state_npchurt_attack = {100, 7},
    state_palsy_attack = {
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
    missile_hitcount = {
      {
        {1, 3},
        {20, 3},
        {30, 3},
        {32, 3}
      }
    },
    attack_attackrate_v = {
      {
        {1, 100},
        {20, 100},
        {30, 100},
        {32, 100}
      }
    }
  },
  th_gjjs_child2 = {
    attack_usebasedamage_p = {
      {
        {1, 3},
        {10, 30},
        {12, 36}
      }
    },
    attack_firedamage_v = {
      [1] = {
        {1, 12},
        {10, 120},
        {12, 144}
      },
      [3] = {
        {1, 12},
        {10, 120},
        {12, 144}
      }
    }
  },
  th_qyby = {
    addpowerwhencol = {
      401,
      {
        {1, 10},
        {10, 30},
        {11, 32},
        {12, 32}
      },
      {
        {1, 30},
        {10, 90},
        {11, 96},
        {12, 96}
      }
    },
    addpowerwhencol1 = {
      402,
      {
        {1, 10},
        {10, 30},
        {11, 32},
        {12, 32}
      },
      {
        {1, 30},
        {10, 90},
        {11, 96},
        {12, 96}
      }
    },
    addpowerwhencol2 = {
      403,
      {
        {1, 10},
        {10, 30},
        {11, 32},
        {12, 32}
      },
      {
        {1, 30},
        {10, 90},
        {11, 96},
        {12, 96}
      }
    },
    addpowerwhencol3 = {
      421,
      {
        {1, 10},
        {10, 30},
        {11, 32},
        {12, 32}
      },
      {
        {1, 30},
        {10, 90},
        {11, 96},
        {12, 96}
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
  th_yhcs = {
    autoskill = {
      41,
      {
        {1, 1},
        {10, 10},
        {11, 11}
      }
    },
    userdesc_000 = {426},
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
  th_yhcs_child = {
    recover_life_p = {
      {
        {1, 1},
        {10, 4},
        {11, 4}
      },
      15
    },
    autoskill2 = {
      43,
      {
        {1, 1},
        {10, 10},
        {11, 11}
      }
    },
    skill_statetime = {
      {
        {1, 30},
        {10, 45},
        {11, 45}
      }
    }
  },
  th_fync = {
    physics_potentialdamage_p = {
      {
        {1, 10},
        {20, 30},
        {21, 31}
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
    state_palsy_attackrate = {
      {
        {1, 80},
        {20, 200},
        {21, 206}
      }
    },
    skill_statetime = {
      {
        {1, -1},
        {10, -1}
      }
    }
  },
  th_90_ylxc = {
    autoskill = {
      44,
      {
        {1, 1},
        {10, 10},
        {11, 11}
      }
    },
    userdesc_101 = {
      {
        {1, 75},
        {10, 60},
        {11, 60}
      }
    },
    userdesc_102 = {
      {
        {1, 100},
        {10, 100},
        {11, 100}
      }
    },
    userdesc_000 = {465},
    skill_statetime = {
      {
        {1, -1},
        {10, -1}
      }
    }
  },
  th_90_ylxc_child1 = {
    addstartskill = {
      401,
      465,
      {
        {1, 1},
        {10, 10}
      }
    },
    addstartskill2 = {
      402,
      465,
      {
        {1, 1},
        {10, 10}
      }
    },
    skill_statetime = {
      {
        {1, 2},
        {30, 2}
      }
    }
  },
  th_90_ylxc_child2 = {
    addstartskill = {
      403,
      466,
      {
        {1, 1},
        {10, 10}
      }
    },
    addstartskill2 = {
      421,
      466,
      {
        {1, 1},
        {10, 10}
      }
    },
    skill_statetime = {
      {
        {1, 2},
        {30, 2}
      }
    }
  },
  th_90_ylxc_child3 = {
    dotdamage_maxlife_p = {
      {
        {1, 10},
        {10, 30},
        {12, 33}
      },
      15,
      30000
    },
    skill_statetime = {
      {
        {1, 1},
        {30, 1}
      }
    },
    missile_hitcount = {
      2,
      2,
      2
    }
  },
  th_90_ylxc_child4 = {
    dotdamage_maxlife_p = {
      {
        {1, 10},
        {10, 25},
        {12, 28}
      },
      15,
      30000
    },
    skill_statetime = {
      {
        {1, 1},
        {30, 1}
      }
    },
    missile_hitcount = {
      3,
      3,
      3
    }
  },
  th_lhfxy = {},
  th_lhfxy_child1 = {
    attack_usebasedamage_p = {
      {
        {1, 800},
        {30, 800}
      }
    },
    attack_firedamage_v = {
      [1] = {
        {1, 180},
        {30, 180},
        {31, 180}
      },
      [3] = {
        {1, 220.00000000000003},
        {30, 220.00000000000003},
        {31, 220.00000000000003}
      }
    }
  },
  th_lhfxy_child2 = {
    ignore_series_state = {},
    ignore_abnor_state = {},
    skill_statetime = {
      {
        {1, 37},
        {30, 37}
      }
    }
  },
  th_blhq = {
    deadlystrike_v = {
      {
        {1, 50},
        {10, 200}
      }
    },
    deadlystrike_damage_p = {
      {
        {1, 5},
        {10, 20}
      }
    },
    skill_statetime = {
      {
        {1, 45},
        {10, 45}
      }
    }
  },
  th_blhq_team = {
    deadlystrike_v = {
      {
        {1, 25},
        {10, 100}
      }
    },
    deadlystrike_damage_p = {
      {
        {1, 2},
        {10, 10}
      }
    },
    skill_statetime = {
      {
        {1, 45},
        {10, 45}
      }
    }
  }
}
FightSkill:AddMagicData(tb)
