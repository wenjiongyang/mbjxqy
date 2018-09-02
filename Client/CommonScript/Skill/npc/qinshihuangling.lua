local tb = {
  ls_normal = {
    attack_usebasedamage_p = {
      {
        {1, 200},
        {30, 200}
      }
    }
  },
  ls_s1 = {
    attack_usebasedamage_p = {
      {
        {1, 250},
        {30, 250}
      }
    },
    state_drag_attack = {
      {
        {1, 50},
        {30, 50}
      },
      4,
      60
    },
    skill_drag_npclen = {20}
  },
  ls_s2 = {
    attack_usebasedamage_p = {
      {
        {1, 100},
        {30, 100}
      }
    }
  },
  ls_s3 = {
    state_knock_attack = {
      100,
      15,
      70
    },
    state_npcknock_attack = {
      100,
      15,
      70
    },
    spe_knock_param = {
      3,
      4,
      9
    }
  },
  ls_s4 = {
    call_npc1 = {
      1881,
      -1,
      5
    },
    call_npc2 = {
      1881,
      -1,
      5
    },
    skill_statetime = {
      {
        {1, 450},
        {30, 450}
      }
    }
  },
  ls_s4_child = {
    callnpc_life = {
      1881,
      {
        {1, 0},
        {10, 0},
        {30, 0}
      }
    },
    callnpc_damage = {
      1881,
      {
        {1, 0},
        {10, 0},
        {30, 0}
      }
    },
    skill_statetime = {
      {
        {1, 450},
        {30, 450}
      }
    }
  },
  ls_s4_5count = {
    call_npc1 = {
      1881,
      -1,
      5
    },
    call_npc2 = {
      1881,
      -1,
      5
    },
    call_npc3 = {
      1881,
      -1,
      5
    },
    call_npc4 = {
      1881,
      -1,
      5
    },
    call_npc5 = {
      1881,
      -1,
      5
    },
    skill_statetime = {
      {
        {1, 450},
        {30, 450}
      }
    }
  },
  ls_s4_5count_child = {
    callnpc_life = {
      1881,
      {
        {1, 0},
        {10, 0},
        {30, 0}
      }
    },
    callnpc_damage = {
      1881,
      {
        {1, 0},
        {10, 0},
        {30, 0}
      }
    },
    skill_statetime = {
      {
        {1, 450},
        {30, 450}
      }
    }
  },
  ls_s5 = {
    autoskill = {
      15,
      {
        {1, 1},
        {30, 30},
        {31, 30}
      }
    },
    skill_statetime = {
      {
        {1, -1},
        {30, -1}
      }
    }
  },
  ls_s5_child1 = {
    autoskill = {
      16,
      {
        {1, 1},
        {30, 30},
        {31, 30}
      }
    },
    attack_usebasedamage_p = {
      {
        {1, 10},
        {30, 10}
      }
    },
    skill_statetime = {
      {
        {1, 225},
        {30, 225}
      }
    }
  },
  ls_s5_child2 = {
    state_knock_ignore = {1},
    skill_statetime = {
      {
        {1, 75},
        {30, 75}
      }
    }
  },
  ls_s6 = {
    call_npc1 = {
      1882,
      -1,
      5
    },
    call_npc2 = {
      1882,
      -1,
      5
    },
    skill_statetime = {
      {
        {1, 1800},
        {30, 1800}
      }
    }
  },
  ls_s6_child = {
    callnpc_life = {
      1882,
      {
        {1, 3},
        {10, 3},
        {30, 3}
      }
    },
    callnpc_damage = {
      1882,
      {
        {1, 0},
        {10, 0},
        {30, 0}
      }
    },
    skill_statetime = {
      {
        {1, 1800},
        {30, 1800}
      }
    }
  },
  ls_s6_die = {
    autoskill = {
      18,
      {
        {1, 1},
        {30, 30},
        {31, 30}
      }
    },
    skill_statetime = {
      {
        {1, -1},
        {30, -1}
      }
    }
  },
  ls_s6_die_child = {
    remove_call_npc = {1882},
    skill_statetime = {
      {
        {1, 3},
        {30, 3}
      }
    }
  },
  ls_s7 = {
    attack_usebasedamage_p = {
      {
        {1, 100},
        {30, 100}
      }
    },
    state_slowrun_attack = {50, 30}
  },
  ls_s8 = {
    attack_usebasedamage_p = {
      {
        {1, 300},
        {30, 300}
      }
    },
    state_knock_attack = {
      100,
      35,
      0
    },
    state_npcknock_attack = {
      100,
      35,
      0
    },
    spe_knock_param = {
      35,
      26,
      26
    }
  },
  bq_normal = {
    attack_usebasedamage_p = {
      {
        {1, 200},
        {30, 200}
      }
    }
  },
  bq_s1 = {
    attack_usebasedamage_p = {
      {
        {1, 200},
        {30, 200}
      }
    }
  },
  bq_s2 = {
    attack_usebasedamage_p = {
      {
        {1, 150},
        {30, 150}
      }
    }
  },
  bq_s2_child = {
    attack_usebasedamage_p = {
      {
        {1, 150},
        {30, 150}
      }
    }
  },
  bq_s3 = {
    physical_damage_v = {
      [1] = {
        {1, 500},
        {30, 790}
      },
      [3] = {
        {1, 500},
        {30, 790}
      }
    },
    attackspeed_v = {
      {
        {1, 40},
        {30, 70}
      }
    },
    skill_statetime = {
      {
        {1, 300},
        {30, 300}
      }
    }
  },
  bq_s4 = {
    attack_usebasedamage_p = {
      {
        {1, 500},
        {30, 500}
      }
    },
    state_knock_attack = {
      100,
      3,
      100
    },
    state_npcknock_attack = {
      100,
      3,
      100
    },
    spe_knock_param = {
      0,
      9,
      9
    }
  },
  bq_s4_child = {
    attack_usebasedamage_p = {
      {
        {1, 50},
        {30, 50}
      }
    },
    state_slowrun_attack = {100, 30}
  },
  bq_s5 = {
    call_npc1 = {
      1880,
      -1,
      5
    },
    call_npc2 = {
      1880,
      -1,
      5
    },
    call_npc3 = {
      1880,
      -1,
      5
    },
    call_npc4 = {
      1880,
      -1,
      5
    },
    call_npc5 = {
      1880,
      -1,
      5
    },
    skill_statetime = {
      {
        {1, 1800},
        {30, 1800}
      }
    }
  },
  bq_s5_child = {
    callnpc_life = {
      1880,
      {
        {1, 1},
        {10, 1}
      }
    },
    callnpc_damage = {
      1880,
      {
        {1, 0},
        {10, 0}
      }
    },
    skill_statetime = {
      {
        {1, 1800},
        {30, 1800}
      }
    }
  },
  bq_s5_die = {
    autoskill = {
      17,
      {
        {1, 1},
        {30, 30},
        {31, 30}
      }
    },
    skill_statetime = {
      {
        {1, -1},
        {30, -1}
      }
    }
  },
  bq_s5_die_child = {
    remove_call_npc = {1880},
    skill_statetime = {
      {
        {1, 3},
        {30, 3}
      }
    }
  },
  bq_s6 = {
    call_npc1 = {
      1883,
      -1,
      5
    },
    call_npc2 = {
      1883,
      -1,
      5
    },
    remove_call_npc = {1883},
    skill_statetime = {
      {
        {1, 450},
        {30, 450}
      }
    }
  },
  bq_s6_child = {
    call_masterlife = {
      1883,
      {
        {1, 100},
        {10, 100}
      }
    },
    callnpc_damage = {
      1883,
      {
        {1, 0},
        {10, 0}
      }
    },
    skill_statetime = {
      {
        {1, 450},
        {30, 450}
      }
    }
  },
  qsh_normal = {
    attack_usebasedamage_p = {
      {
        {1, 200},
        {30, 200}
      }
    }
  },
  qsh_s1 = {
    attack_usebasedamage_p = {
      {
        {1, 100},
        {30, 100}
      }
    }
  },
  qsh_s1_child1 = {
    attack_usebasedamage_p = {
      {
        {1, 300},
        {30, 590}
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
  qsh_s1_child2 = {
    state_knock_attack = {
      100,
      5,
      70
    },
    state_npcknock_attack = {
      100,
      5,
      70
    },
    spe_knock_param = {
      3,
      4,
      9
    }
  },
  qsh_s2 = {
    call_npc1 = {
      1885,
      -1,
      5
    },
    remove_call_npc = {1885},
    skill_statetime = {
      {
        {1, 45},
        {30, 45}
      }
    }
  },
  qsh_s2_child = {
    callnpc_life = {
      1885,
      {
        {1, 100},
        {10, 100}
      }
    },
    callnpc_damage = {
      1885,
      {
        {1, 100},
        {10, 100}
      }
    },
    skill_statetime = {
      {
        {1, 45},
        {30, 45}
      }
    }
  },
  qsh_s3 = {
    call_npc1 = {
      1884,
      -1,
      5
    },
    remove_call_npc = {1884},
    skill_statetime = {
      {
        {1, 45},
        {30, 45}
      }
    }
  },
  qsh_s3_child = {
    callnpc_life = {
      1884,
      {
        {1, 100},
        {10, 100}
      }
    },
    callnpc_damage = {
      1884,
      {
        {1, 100},
        {10, 100}
      }
    },
    skill_statetime = {
      {
        {1, 45},
        {30, 45}
      }
    }
  },
  qsh_s4 = {
    call_npc1 = {
      1894,
      -1,
      5
    },
    call_npc2 = {
      1894,
      -1,
      5
    },
    call_npc3 = {
      1894,
      -1,
      5
    },
    remove_call_npc = {1894},
    skill_statetime = {
      {
        {1, 75},
        {30, 75}
      }
    }
  },
  qsh_s4_child = {
    callnpc_life = {
      1894,
      {
        {1, 100},
        {10, 100}
      }
    },
    callnpc_damage = {
      1894,
      {
        {1, 100},
        {10, 100}
      }
    },
    skill_statetime = {
      {
        {1, 75},
        {30, 75}
      }
    }
  },
  qsh_s5 = {
    attack_usebasedamage_p = {
      {
        {1, 200},
        {30, 200}
      }
    }
  },
  qsh_s6 = {
    attack_usebasedamage_p = {
      {
        {1, 100000},
        {30, 100000}
      }
    },
    attack_earthdamage_v = {
      [1] = {
        {1, 1000000},
        {30, 1000000}
      },
      [3] = {
        {1, 1000000},
        {30, 1000000}
      }
    },
    attack_wooddamage_v = {
      [1] = {
        {1, 1000000},
        {30, 1000000}
      },
      [3] = {
        {1, 1000000},
        {30, 1000000}
      }
    },
    attack_waterdamage_v = {
      [1] = {
        {1, 1000000},
        {30, 1000000}
      },
      [3] = {
        {1, 1000000},
        {30, 1000000}
      }
    },
    attack_firedamage_v = {
      [1] = {
        {1, 1000000},
        {30, 1000000}
      },
      [3] = {
        {1, 1000000},
        {30, 1000000}
      }
    },
    attack_metaldamage_v = {
      [1] = {
        {1, 1000000},
        {30, 1000000}
      },
      [3] = {
        {1, 1000000},
        {30, 1000000}
      }
    },
    missile_hitcount = {
      {
        {1, 1},
        {30, 1}
      }
    }
  },
  xtwj_normal = {
    attack_usebasedamage_p = {
      {
        {1, 150},
        {30, 150}
      }
    }
  },
  xtwj_s1 = {
    attack_usebasedamage_p = {
      {
        {1, 150},
        {30, 390}
      }
    }
  },
  xtwj_s2 = {
    physics_potentialdamage_p = {
      {
        {1, 1},
        {30, 1}
      }
    },
    skill_statetime = {
      {
        {1, -1},
        {30, -1}
      }
    }
  },
  xtwj_s3 = {
    attack_usebasedamage_p = {
      {
        {1, 400},
        {30, 400}
      }
    },
    state_knock_attack = {
      100,
      20,
      30
    },
    state_npcknock_attack = {
      100,
      20,
      30
    },
    spe_knock_param = {
      11,
      26,
      26
    }
  },
  xtwj_s4 = {
    missile_hitcount = {
      {
        {1, 1},
        {20, 1}
      }
    }
  },
  xtwj_s4_child = {
    attack_usebasedamage_p = {
      {
        {1, 400},
        {30, 400}
      }
    }
  },
  buff_forqsh = {
    skill_statetime = {
      {
        {1, 900},
        {30, 900}
      }
    }
  },
  buff_stay10second = {
    invincible_b = {1},
    skill_statetime = {
      {
        {1, 180},
        {30, 180}
      }
    }
  }
}
FightSkill:AddMagicData(tb)
