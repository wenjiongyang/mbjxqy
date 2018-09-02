local tb = {
  em_pg1 = {
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
        {1, 70},
        {20, 90},
        {30, 130},
        {32, 150}
      }
    },
    attack_waterdamage_v = {
      [1] = {
        {1, 40},
        {20, 142.5},
        {30, 285},
        {32, 380}
      },
      [3] = {
        {1, 40},
        {20, 157.5},
        {30, 315},
        {32, 420}
      }
    },
    state_npchurt_attack = {100, 6},
    state_slowall_attack = {
      {
        {1, 30},
        {20, 30},
        {30, 30},
        {32, 30}
      },
      {
        {1, 22.5},
        {20, 22.5},
        {30, 22.5},
        {32, 22.5}
      }
    },
    missile_hitcount = {
      {
        {1, 2},
        {20, 2},
        {30, 2},
        {32, 2}
      }
    }
  },
  em_pg2 = {
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
        {1, 70},
        {20, 90},
        {30, 140},
        {32, 160}
      }
    },
    attack_waterdamage_v = {
      [1] = {
        {1, 40},
        {20, 142.5},
        {30, 380},
        {32, 475}
      },
      [3] = {
        {1, 40},
        {20, 157.5},
        {30, 420},
        {32, 525}
      }
    },
    state_npchurt_attack = {100, 6},
    state_slowall_attack = {
      {
        {1, 50},
        {20, 50},
        {30, 50},
        {32, 50}
      },
      {
        {1, 22.5},
        {20, 22.5},
        {30, 22.5},
        {32, 22.5}
      }
    },
    missile_hitcount = {
      {
        {1, 2},
        {20, 2},
        {30, 2},
        {32, 2}
      }
    }
  },
  em_pg3 = {
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
        {1, 70},
        {20, 90},
        {30, 170},
        {32, 170}
      }
    },
    attack_waterdamage_v = {
      [1] = {
        {1, 40},
        {20, 142.5},
        {30, 285},
        {32, 570}
      },
      [3] = {
        {1, 40},
        {20, 157.5},
        {30, 315},
        {32, 630}
      }
    },
    state_slowall_attack = {
      {
        {1, 70},
        {20, 70},
        {30, 70},
        {32, 70}
      },
      {
        {1, 22.5},
        {20, 22.5},
        {30, 30},
        {32, 30}
      }
    },
    state_npchurt_attack = {100, 6},
    missile_hitcount = {
      {
        {1, 3},
        {20, 3},
        {30, 3},
        {32, 3}
      }
    }
  },
  em_pg4 = {
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
        {1, 100},
        {20, 150},
        {30, 220},
        {32, 240}
      }
    },
    attack_waterdamage_v = {
      [1] = {
        {1, 90},
        {20, 285},
        {30, 760},
        {32, 950}
      },
      [3] = {
        {1, 90},
        {20, 315},
        {30, 840},
        {32, 1050}
      }
    },
    state_slowall_attack = {
      {
        {1, 90},
        {20, 90},
        {30, 90},
        {32, 90}
      },
      {
        {1, 22.5},
        {20, 22.5},
        {30, 30},
        {32, 30}
      }
    },
    state_npchurt_attack = {80, 6},
    missile_hitcount = {
      {
        {1, 4},
        {20, 4},
        {30, 4},
        {32, 4}
      }
    }
  },
  em_jhnb = {
    userdesc_000 = {311}
  },
  em_jhnb_child = {
    state_slowall_attack = {
      {
        {1, 30},
        {15, 30},
        {16, 30},
        {21, 40}
      },
      {
        {1, 22.5},
        {15, 22.5},
        {16, 22.5},
        {21, 30}
      }
    },
    attack_usebasedamage_p = {
      {
        {1, 70},
        {15, 110},
        {16, 120},
        {20, 170},
        {21, 180}
      }
    },
    attack_waterdamage_v = {
      [1] = {
        {1, 72},
        {15, 360},
        {16, 396},
        {21, 720}
      },
      [3] = {
        {1, 88},
        {15, 440.00000000000006},
        {16, 484.00000000000006},
        {21, 880.0000000000001}
      }
    }
  },
  em_twbl = {
    vitality_recover_life = {
      {
        {1, 40},
        {15, 160},
        {16, 180},
        {21, 240}
      },
      15
    },
    skill_statetime = {
      {
        {1, 20},
        {15, 20},
        {16, 20},
        {21, 20}
      }
    },
    userdesc_000 = {313}
  },
  em_twbl_child1 = {
    attack_usebasedamage_p = {
      {
        {1, 30},
        {10, 60},
        {15, 80},
        {16, 85},
        {20, 110},
        {21, 120}
      }
    },
    attack_waterdamage_v = {
      [1] = {
        {1, 63},
        {10, 180},
        {15, 220.5},
        {16, 234},
        {21, 450}
      },
      [3] = {
        {1, 77},
        {10, 220.00000000000003},
        {15, 269.5},
        {16, 286},
        {21, 550}
      }
    },
    state_slowall_attack = {
      {
        {1, 70},
        {15, 70},
        {16, 70},
        {21, 70}
      },
      {
        {1, 45},
        {15, 45},
        {16, 45},
        {21, 45}
      }
    },
    state_nojump_attack = {
      {
        {1, 60},
        {15, 60},
        {16, 60},
        {21, 60}
      },
      {
        {1, 8},
        {15, 8},
        {16, 8},
        {21, 8}
      }
    },
    missile_hitcount = {
      {
        {1, 6},
        {15, 6},
        {16, 6},
        {21, 6}
      }
    }
  },
  em_twbl_child3 = {
    reverse_hide = {},
    skill_statetime = {
      {
        {1, 30},
        {15, 30},
        {16, 30},
        {21, 30}
      }
    }
  },
  em_chpd = {
    userdesc_000 = {307},
    missile_hitcount = {
      {
        {1, 1},
        {15, 1},
        {16, 1},
        {21, 1}
      }
    },
    skill_mintimepercast_v = {
      {
        {1, 600},
        {15, 450},
        {16, 450},
        {21, 450}
      }
    }
  },
  em_chpd_child = {
    vitality_recover_life = {
      {
        {1, 100},
        {15, 600},
        {16, 700},
        {21, 940}
      },
      15
    },
    skill_statetime = {
      {
        {1, 75},
        {15, 75},
        {16, 75},
        {21, 75}
      }
    }
  },
  em_jxtm = {
    physics_potentialdamage_p = {
      {
        {1, 24},
        {10, 70},
        {11, 80}
      }
    },
    lifemax_p = {
      {
        {1, 45},
        {10, 60},
        {11, 62}
      }
    },
    runspeed_v = {
      {
        {1, 20},
        {10, 50},
        {11, 53}
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
  em_blns = {
    attack_usebasedamage_p = {
      {
        {1, 140},
        {15, 220},
        {16, 230},
        {21, 280}
      }
    },
    attack_waterdamage_v = {
      [1] = {
        {1, 270},
        {15, 720},
        {16, 810},
        {21, 1260}
      },
      [3] = {
        {1, 330},
        {15, 880.0000000000001},
        {16, 990.0000000000001},
        {21, 1540.0000000000002}
      }
    },
    missile_hitcount = {
      {
        {1, 3},
        {15, 3},
        {16, 3}
      }
    }
  },
  em_blns_child = {
    attack_usebasedamage_p = {
      {
        {1, 140},
        {15, 220},
        {16, 230},
        {21, 280}
      }
    },
    attack_waterdamage_v = {
      [1] = {
        {1, 270},
        {15, 720},
        {16, 810},
        {21, 1260}
      },
      [3] = {
        {1, 330},
        {15, 880.0000000000001},
        {16, 990.0000000000001},
        {21, 1540.0000000000002}
      }
    },
    missile_hitcount = {
      {
        {1, 5},
        {15, 5},
        {16, 5},
        {21, 5}
      }
    }
  },
  em_bxys = {
    weaken_deadlystrike_v = {
      {
        {1, 20},
        {10, 200},
        {11, 220}
      }
    },
    weaken_deadlystrike_damage_p = {
      {
        {1, 5},
        {10, 30},
        {11, 33}
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
  em_gjjf = {
    addaction_event1 = {304, 324},
    add_skill_level = {
      301,
      {
        {1, 1},
        {10, 10},
        {11, 11}
      },
      0
    },
    add_skill_level2 = {
      302,
      {
        {1, 1},
        {10, 10},
        {11, 11}
      },
      0
    },
    add_skill_level3 = {
      303,
      {
        {1, 1},
        {10, 10},
        {11, 11}
      },
      0
    },
    add_skill_level4 = {
      304,
      {
        {1, 1},
        {10, 10},
        {11, 11}
      },
      0
    },
    userdesc_000 = {361},
    skill_statetime = {
      {
        {1, -1},
        {10, -1},
        {11, -1}
      }
    }
  },
  em_gjjf_child1 = {
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
        {1, 100},
        {20, 150},
        {30, 180},
        {32, 186}
      }
    },
    attack_waterdamage_v = {
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
    state_slowall_attack = {
      {
        {1, 80},
        {20, 80},
        {30, 80},
        {32, 80}
      },
      {
        {1, 7.5},
        {20, 7.5},
        {30, 7.5},
        {32, 7.5}
      }
    },
    state_npchurt_attack = {80, 6},
    missile_hitcount = {
      {
        {1, 4},
        {20, 4},
        {30, 4},
        {32, 4}
      }
    }
  },
  em_gjjf_child2 = {
    attack_usebasedamage_p = {
      {
        {1, 3},
        {10, 30},
        {11, 33}
      }
    },
    attack_waterdamage_v = {
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
  em_fxcy = {
    resist_allseriesstate_rate_v = {
      {
        {1, 20},
        {10, 80},
        {11, 86}
      }
    },
    resist_allseriesstate_time_v = {
      {
        {1, 20},
        {10, 80},
        {11, 86}
      }
    },
    resist_allspecialstate_rate_v = {
      {
        {1, 20},
        {10, 80},
        {11, 86}
      }
    },
    resist_allspecialstate_time_v = {
      {
        {1, 20},
        {10, 80},
        {11, 86}
      }
    },
    userdesc_101 = {
      {
        {1, 20},
        {10, 80},
        {11, 86}
      }
    },
    userdesc_102 = {
      {
        {1, 20},
        {10, 80},
        {11, 86}
      }
    },
    userdesc_103 = {
      {
        {1, 20},
        {10, 80},
        {11, 86}
      }
    },
    userdesc_104 = {
      {
        {1, 20},
        {10, 80},
        {11, 86}
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
  em_fxcy_team = {
    resist_allseriesstate_rate_v = {
      {
        {1, 20},
        {10, 80},
        {11, 90}
      }
    },
    resist_allseriesstate_time_v = {
      {
        {1, 20},
        {10, 80},
        {11, 90}
      }
    },
    resist_allspecialstate_rate_v = {
      {
        {1, 20},
        {10, 80},
        {11, 90}
      }
    },
    resist_allspecialstate_time_v = {
      {
        {1, 20},
        {10, 80},
        {11, 90}
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
  em_mlcz = {
    autoskill = {
      31,
      {
        {1, 1},
        {10, 10},
        {11, 11}
      }
    },
    userdesc_000 = {318},
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
  em_mlcz_child1 = {
    recover_life_p = {
      {
        {1, 3},
        {10, 6},
        {11, 7}
      },
      15
    },
    skill_statetime = {
      {
        {1, 30},
        {10, 90},
        {11, 105}
      }
    }
  },
  em_mlcz_child2 = {
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
    spe_knock_param1 = {1}
  },
  em_ffwb = {
    physics_potentialdamage_p = {
      {
        {1, 40},
        {20, 90},
        {21, 100}
      }
    },
    lifemax_p = {
      {
        {1, 5},
        {20, 25},
        {21, 28}
      }
    },
    attackspeed_v = {
      {
        {1, 15},
        {20, 50},
        {21, 55}
      }
    },
    state_slowall_attackrate = {
      {
        {1, 80},
        {20, 200},
        {21, 220}
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
  em_90_qxps = {
    add_hitskill1 = {
      312,
      358,
      {
        {1, 1},
        {10, 10}
      }
    },
    addstartskill = {
      307,
      359,
      {
        {1, 1},
        {10, 10}
      }
    },
    lifereplenish_p = {
      {
        {1, 2},
        {10, 15},
        {11, 17}
      }
    },
    userdesc_000 = {358},
    userdesc_101 = {
      {
        {1, 60},
        {10, 180},
        {11, 198}
      },
      15
    },
    skill_statetime = {
      {
        {1, -1},
        {10, -1}
      }
    }
  },
  em_90_qxps_child1 = {
    vitality_recover_life = {
      {
        {1, 16},
        {10, 64},
        {11, 70.4}
      },
      15
    },
    skill_statetime = {
      {
        {1, 20},
        {10, 20},
        {11, 20}
      }
    }
  },
  em_90_qxps_child2 = {
    vitality_recover_life = {
      {
        {1, 60},
        {10, 180},
        {11, 198}
      },
      15
    },
    skill_statetime = {
      {
        {1, 75},
        {10, 75},
        {11, 75}
      }
    }
  },
  em_bphlj = {
    state_freeze_attack = {
      {
        {1, 100},
        {10, 100}
      },
      {
        {1, 75},
        {10, 75}
      }
    },
    attack_usebasedamage_p = {
      {
        {1, 1000},
        {10, 1000}
      }
    },
    attack_waterdamage_v = {
      [1] = {
        {1, 270},
        {10, 1800}
      },
      [3] = {
        {1, 330},
        {10, 2200}
      }
    }
  },
  em_bphlj_child1 = {
    all_series_resist_v = {
      {
        {1, -2000},
        {10, -2000}
      }
    },
    skill_statetime = {
      {
        {1, 225},
        {10, 225}
      }
    }
  },
  em_bphlj_child2 = {
    ignore_series_state = {},
    ignore_abnor_state = {},
    skill_statetime = {
      {
        {1, 35},
        {10, 35}
      }
    }
  }
}
FightSkill:AddMagicData(tb)
