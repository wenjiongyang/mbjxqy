local tb = {
  zhenyuan_1 = {
    lifecurmax_p = {
      {
        {1, 10},
        {7, 22},
        {8, 25}
      }
    },
    autoskill = {
      100,
      {
        {1, 1},
        {10, 10}
      }
    },
    userdesc_101 = {
      {
        {1, 900},
        {3, 750},
        {8, 600}
      }
    },
    skill_statetime = {
      {
        {1, -1},
        {10, -1}
      }
    }
  },
  zhenyuan_1_child = {
    allfactionskill_cd = {
      {
        {1, -900},
        {10, -900}
      }
    },
    skill_statetime = {1}
  },
  zhenyuan_2 = {
    enhance_final_damage_p = {
      {
        {1, 10},
        {7, 22},
        {8, 25}
      }
    },
    ignoreattackontime = {
      {
        {1, 900},
        {3, 750},
        {8, 600}
      },
      {
        {1, 7.5},
        {2, 7.5},
        {3, 9},
        {5, 9},
        {6, 10.5},
        {7, 12},
        {8, 15}
      },
      1
    },
    skill_statetime = {
      {
        {1, -1},
        {10, -1}
      }
    }
  },
  zhenyuan_3 = {
    enhance_final_damage_p = {
      {
        {1, 10},
        {7, 22},
        {8, 25}
      }
    },
    autoskill = {
      101,
      {
        {1, 1},
        {10, 10}
      }
    },
    skill_statetime = {
      {
        {1, -1},
        {10, -1}
      }
    },
    userdesc_000 = {3805}
  },
  zhenyuan_3_child = {
    ignore_series_state = {},
    ignore_abnor_state = {},
    userdesc_101 = {
      {
        {1, 750},
        {3, 600},
        {8, 450}
      }
    },
    skill_statetime = {
      {
        {1, 15},
        {3, 15},
        {4, 18},
        {6, 18},
        {7, 19.5},
        {8, 22.5}
      }
    }
  },
  zhenyuan_4 = {
    enhance_final_damage_p = {
      {
        {1, 10},
        {7, 22},
        {8, 25}
      }
    },
    attackrate_p = {
      {
        {1, 20},
        {6, 30},
        {7, 35},
        {8, 40}
      }
    },
    deadlystrike_p = {
      {
        {1, 20},
        {6, 30},
        {7, 35},
        {8, 40}
      }
    },
    defense_p = {
      {
        {1, 20},
        {6, 30},
        {7, 35},
        {8, 40}
      }
    },
    all_series_resist_p = {
      {
        {1, 20},
        {6, 30},
        {7, 35},
        {8, 40}
      }
    },
    skill_statetime = {
      {
        {1, -1},
        {10, -1}
      }
    }
  },
  zhenyuan_5 = {
    lifecurmax_p = {
      {
        {1, 10},
        {7, 22},
        {8, 25}
      }
    },
    reduce_final_damage_p = {
      {
        {1, 5},
        {4, 8},
        {6, 12},
        {7, 13},
        {8, 15}
      }
    },
    skill_statetime = {
      {
        {1, -1},
        {10, -1}
      }
    }
  }
}
FightSkill:AddMagicData(tb)
