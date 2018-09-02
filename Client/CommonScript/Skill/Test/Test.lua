local tb = {
  empty = {
    userdesc_000 = {0}
  },
  emptyforbuff = {
    userdesc_000 = {0},
    lifemax_v = {1},
    skill_statetime = {
      {
        {1, -1},
        {30, -1}
      }
    }
  },
  test_recoverlife = {
    recover_life_v = {
      {
        {1, 1000},
        {30, 1000},
        {31, 1000}
      },
      7.5
    },
    skill_statetime = {
      {
        {1, 162},
        {30, 162}
      }
    }
  },
  test1 = {
    attack_usebasedamage_p = {10000},
    dotdamage_holy = {
      10000,
      10,
      2
    },
    state_knock_attack = {
      100,
      6,
      32
    }
  },
  test2 = {
    attack_usebasedamage_p = {100},
    state_knock_attack = {
      100,
      11,
      0
    }
  },
  test3 = {
    physical_damage_v = {
      [1] = {
        {1, 1000000},
        {30, 50000000}
      },
      [3] = {
        {1, 1000000},
        {30, 50000000}
      }
    },
    physics_potentialdamage_p = {
      {
        {1, 10000},
        {30, 10000}
      }
    },
    runspeed_v = {
      {
        {1, 300},
        {30, 500}
      }
    },
    skill_statetime = {
      {
        {1, 900},
        {30, 900}
      }
    }
  },
  test4 = {
    attack_usebasedamage_p = {50}
  },
  test_strong = {
    physics_potentialdamage_p = {
      {
        {1, 100},
        {30, 3000},
        {50, 5000}
      }
    },
    lifemax_p = {
      {
        {1, 100},
        {30, 3000},
        {50, 5000}
      }
    },
    skill_statetime = {
      {
        {1, 900},
        {30, 900}
      }
    }
  },
  test_mustkill = {
    attack_usebasedamage_p = {10000},
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
    }
  },
  test_npc = {
    attack_usebasedamage_p = {100}
  },
  test_npc2 = {
    attack_usebasedamage_p = {100}
  },
  test_npc3 = {
    attack_usebasedamage_p = {100}
  },
  test_slowall = {
    state_slowall_attack = {
      {
        {1, 100},
        {10, 100},
        {11, 100}
      },
      {
        {1, 75},
        {10, 75},
        {11, 75}
      }
    }
  },
  test_fixed = {
    state_fixed_attack = {
      {
        {1, 100},
        {10, 100},
        {11, 100}
      },
      {
        {1, 75},
        {10, 75},
        {11, 75}
      }
    }
  },
  test_zhican = {
    state_zhican_attack = {
      {
        {1, 100},
        {10, 100},
        {11, 100}
      },
      {
        {1, 75},
        {10, 75},
        {11, 75}
      }
    }
  },
  test_palsy = {
    state_palsy_attack = {
      {
        {1, 100},
        {10, 100},
        {11, 100}
      },
      {
        {1, 75},
        {10, 75},
        {11, 75}
      }
    }
  },
  test_float = {
    state_float_attack = {
      {
        {1, 100},
        {10, 100},
        {11, 100}
      },
      {
        {1, 75},
        {10, 75},
        {11, 75}
      }
    }
  },
  test_burn = {
    state_burn_attack = {
      {
        {1, 100},
        {10, 100},
        {11, 100}
      },
      {
        {1, 75},
        {10, 75},
        {11, 75}
      }
    }
  },
  test_silence = {
    state_silence_attack = {
      {
        {1, 100},
        {10, 100},
        {11, 100}
      },
      {
        {1, 75},
        {10, 75},
        {11, 75}
      }
    }
  },
  test_confuse = {
    state_confuse_attack = {
      {
        {1, 100},
        {10, 100},
        {11, 100}
      },
      {
        {1, 75},
        {10, 75},
        {11, 75}
      }
    }
  },
  test_weak = {
    state_weak_attack = {
      {
        {1, 100},
        {10, 100},
        {11, 100}
      },
      {
        {1, 75},
        {10, 75},
        {11, 75}
      }
    }
  },
  test_sleep = {
    state_sleep_attack = {
      {
        {1, 100},
        {10, 100},
        {11, 100}
      },
      {
        {1, 75},
        {10, 75},
        {11, 75}
      }
    }
  },
  test_stun = {
    state_stun_attack = {
      {
        {1, 100},
        {10, 100},
        {11, 100}
      },
      {
        {1, 75},
        {10, 75},
        {11, 75}
      }
    }
  },
  magictest = {
    vitality_v = {1000}
  },
  test_buff = {
    recover_life_v = {
      {
        {1, 100},
        {30, 100},
        {31, 100}
      },
      75
    },
    steallife_p = {
      {
        {1, 5},
        {30, 5}
      }
    },
    meleedamagereturn_p = {
      {
        {1, 5},
        {30, 5}
      }
    },
    rangedamagereturn_p = {
      {
        {1, 5},
        {30, 5}
      }
    },
    skill_statetime = {
      {
        {1, 900},
        {30, 900}
      }
    }
  },
  testmag1 = {
    playerdmg_npc_p = {
      {
        {1, -10},
        {10, -50}
      }
    },
    skill_statetime = {
      {
        {1, 108000},
        {30, 108000}
      }
    }
  },
  testmag2 = {
    miss_alldmg_v = {
      {
        {1, 100},
        {30, 3000}
      }
    },
    skill_statetime = {
      {
        {1, 108000},
        {30, 108000}
      }
    }
  },
  testmag3 = {
    steallife_resist_v = {
      {
        {1, 100},
        {30, 3000}
      }
    },
    skill_statetime = {
      {
        {1, 108000},
        {30, 108000}
      }
    }
  },
  testmag4 = {
    steallife_resist_p = {
      {
        {1, 5},
        {20, 100}
      }
    },
    skill_statetime = {
      {
        {1, 108000},
        {30, 108000}
      }
    }
  },
  testmag5 = {
    steallife_p = {
      {
        {1, 5},
        {20, 100}
      }
    },
    skill_statetime = {
      {
        {1, 108000},
        {30, 108000}
      }
    }
  }
}
FightSkill:AddMagicData(tb)
