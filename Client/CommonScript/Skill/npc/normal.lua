local tb = {
  buff_recover = {
    recover_life_p = {
      {
        {1, 5},
        {30, 150}
      },
      15
    },
    skill_statetime = {
      {
        {1, 75},
        {30, 75}
      }
    }
  },
  buff_recover2 = {
    recover_life_p = {
      {
        {1, 5},
        {30, 5}
      },
      15
    },
    skill_statetime = {
      {
        {1, 75},
        {30, 510}
      }
    }
  },
  buff_adddamage = {
    physics_potentialdamage_p = {
      {
        {1, 30},
        {30, 30}
      }
    },
    skill_statetime = {
      {
        {1, 75},
        {30, 510}
      }
    }
  },
  buff_series = {
    all_series_resist_p = {
      {
        {1, 30},
        {30, 30}
      }
    },
    skill_statetime = {
      {
        {1, 75},
        {30, 510}
      }
    }
  },
  buff_runspeed = {
    runspeed_p = {
      {
        {1, 50},
        {30, 50}
      }
    },
    skill_statetime = {
      {
        {1, 75},
        {30, 510}
      }
    }
  },
  buff_heal = {
    recover_life_p = {
      {
        {1, 10},
        {30, 10}
      },
      15
    },
    skill_statetime = {
      {
        {1, 15},
        {30, 15}
      }
    }
  },
  showknock = {
    state_knock_attack = {
      100,
      15,
      30
    },
    state_npcknock_attack = {
      100,
      15,
      30
    },
    spe_knock_param = {
      4,
      4,
      4
    }
  },
  npc_xx_chongfeng = {
    attack_usebasedamage_p = {
      {
        {1, 200},
        {30, 200}
      }
    },
    state_knock_attack = {
      {
        {1, 30},
        {10, 100}
      },
      35,
      30
    },
    state_npcknock_attack = {
      {
        {1, 30},
        {10, 100}
      },
      35,
      30
    },
    spe_knock_param = {
      26,
      26,
      26
    }
  },
  npc_xx_hengsao = {
    attack_usebasedamage_p = {
      {
        {1, 100},
        {30, 100}
      }
    }
  },
  npc_xx_fazhen = {
    attack_usebasedamage_p = {
      {
        {1, 100},
        {30, 100}
      }
    }
  },
  npc_xx_fanwei_1 = {
    attack_usebasedamage_p = {
      {
        {1, 100},
        {30, 390}
      }
    }
  },
  npc_xx_fanwei_2 = {
    attack_usebasedamage_p = {
      {
        {1, 50},
        {30, 50}
      }
    }
  },
  npc_xx_shanxing = {
    attack_usebasedamage_p = {
      {
        {1, 50},
        {30, 50}
      }
    }
  },
  npc_xx_fukong = {
    attack_usebasedamage_p = {
      {
        {1, 300},
        {30, 300}
      }
    },
    state_float_attack = {
      {
        {1, 30},
        {8, 100},
        {30, 100}
      },
      {
        {1, 45},
        {30, 45}
      }
    }
  },
  npc_fantan = {
    meleedamagereturn_p = {
      {
        {1, 100},
        {30, 100}
      }
    },
    rangedamagereturn_p = {
      {
        {1, 100},
        {30, 100}
      }
    }
  },
  npc_fanshe = {
    meleedamagereturn_p = {
      {
        {1, 10},
        {10, 100}
      }
    },
    rangedamagereturn_p = {
      {
        {1, 10},
        {10, 100}
      }
    }
  },
  npc_jingji_buff = {
    meleedamagereturn_p = {
      {
        {1, 20},
        {9, 100}
      }
    },
    rangedamagereturn_p = {
      {
        {1, 20},
        {9, 100}
      }
    }
  },
  npc_zhongdu = {
    attack_usebasedamage_p = {
      {
        {1, 30},
        {30, 320}
      }
    }
  },
  npc_adddamage = {
    physics_potentialdamage_p = {
      {
        {1, 300},
        {30, 300},
        {31, 300}
      }
    },
    skill_statetime = {
      {
        {1, 75},
        {30, 510}
      }
    }
  },
  npc_xj_huoyan = {
    attack_usebasedamage_p = {
      {
        {1, 100},
        {30, 100}
      }
    }
  },
  npc_mustkill = {
    attack_usebasedamage_p = {10000},
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
    attack_earthdamage_v = {
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
  npc_wudi_bd = {
    invincible_b = {1},
    skill_statetime = {
      {
        {1, -1},
        {30, -1}
      }
    }
  },
  npc_wudi = {
    invincible_b = {1},
    skill_statetime = {
      {
        {1, 75},
        {30, 510},
        {31, 510}
      }
    }
  },
  npc_shibao = {
    autoskill = {
      91,
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
  npc_shibao_child = {
    attack_usebasedamage_p = {
      {
        {1, 300},
        {30, 880}
      }
    }
  },
  npc_runspeed = {
    runspeed_v = {
      {
        {1, 100},
        {10, 1100},
        {12, 1100}
      }
    },
    skill_statetime = {
      {
        {1, 225},
        {30, 225}
      }
    }
  },
  act_mingxia_pg = {
    attack_usebasedamage_p = {
      {
        {1, 250},
        {20, 250}
      }
    }
  }
}
FightSkill:AddMagicData(tb)
