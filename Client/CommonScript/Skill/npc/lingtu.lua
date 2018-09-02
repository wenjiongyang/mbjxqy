local tb = {
  lingtu_damagebuff = {
    special_dmg_taget = {1}
  },
  lingtu_gongchengche = {
    attack_holydamage_v = {
      [1] = {
        {1, 7500},
        {2, 10800},
        {3, 15800},
        {4, 21600},
        {5, 26600}
      },
      [3] = {
        {1, 7500},
        {2, 10800},
        {3, 15800},
        {4, 21600},
        {5, 26600}
      }
    }
  },
  lingtu_fangyu = {
    reduce_final_damage_p = {
      {
        {1, 10},
        {10, 100}
      }
    }
  },
  lingtu_jingnuche_normal = {
    attack_holydamage_v = {
      [1] = {
        {1, 1950},
        {2, 2800},
        {3, 4100},
        {4, 5600},
        {5, 6900}
      },
      [3] = {
        {1, 1950},
        {2, 2800},
        {3, 4100},
        {4, 5600},
        {5, 6900}
      }
    }
  },
  lingtu_jingnuche_shanxing = {
    attack_holydamage_v = {
      [1] = {
        {1, 5850},
        {2, 8400},
        {3, 12300},
        {4, 16800},
        {5, 20700}
      },
      [3] = {
        {1, 5850},
        {2, 8400},
        {3, 12300},
        {4, 16800},
        {5, 20700}
      }
    }
  },
  lingtu_paoche_normal = {
    attack_holydamage_v = {
      [1] = {
        {1, 2250},
        {2, 3250},
        {3, 4750},
        {4, 6500},
        {5, 8000}
      },
      [3] = {
        {1, 2250},
        {2, 3250},
        {3, 4750},
        {4, 6500},
        {5, 8000}
      }
    }
  },
  lingtu_paoche_sp = {
    attack_holydamage_v = {
      [1] = {
        {1, 6750},
        {2, 9750},
        {3, 14250},
        {4, 19500},
        {5, 24000}
      },
      [3] = {
        {1, 6750},
        {2, 9750},
        {3, 14250},
        {4, 19500},
        {5, 24000}
      }
    }
  },
  lingtu_npc_normal = {
    attack_usebasedamage_p = {
      {
        {1, 100},
        {30, 390}
      }
    }
  },
  lingtu_npc_buff = {
    basic_damage_v = {
      [1] = {
        {1, 100},
        {5, 100}
      },
      [3] = {
        {1, 100},
        {5, 100}
      }
    },
    lifemax_v = {
      {
        {1, 1500},
        {5, 1500}
      }
    },
    all_series_resist_v = {
      {
        {1, 60},
        {5, 60}
      }
    },
    add_seriesstate_rate_v = {
      {
        {1, 100},
        {5, 100}
      }
    },
    add_seriesstate_time_v = {
      {
        {1, 100},
        {5, 100}
      }
    },
    skill_statetime = {
      {
        {1, 45},
        {30, 45}
      }
    }
  }
}
FightSkill:AddMagicData(tb)
