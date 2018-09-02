local tb = {
  marry_change_man1 = {
    shapeshift = {2353},
    skill_statetime = {
      {
        {1, 300},
        {30, 3000}
      }
    }
  },
  marry_change_man2 = {
    shapeshift = {2354},
    skill_statetime = {
      {
        {1, 300},
        {30, 3000}
      }
    }
  },
  marry_change_man3 = {
    shapeshift = {2355},
    skill_statetime = {
      {
        {1, 300},
        {30, 3000}
      }
    }
  },
  marry_change_woman1 = {
    shapeshift = {2356},
    skill_statetime = {
      {
        {1, 300},
        {30, 3000}
      }
    }
  },
  marry_change_woman2 = {
    shapeshift = {2357},
    skill_statetime = {
      {
        {1, 300},
        {30, 3000}
      }
    }
  },
  marry_change_woman3 = {
    shapeshift = {2358},
    skill_statetime = {
      {
        {1, 300},
        {30, 3000}
      }
    }
  },
  marry_change_loli1 = {
    shapeshift = {2359},
    skill_statetime = {
      {
        {1, 300},
        {30, 3000}
      }
    }
  },
  marry_change_loli2 = {
    shapeshift = {2360},
    skill_statetime = {
      {
        {1, 300},
        {30, 3000}
      }
    }
  },
  marry_change_loli3 = {
    shapeshift = {2361},
    skill_statetime = {
      {
        {1, 300},
        {30, 3000}
      }
    }
  },
  buff_couple = {
    physical_damage_v = {
      [1] = {
        {1, 100},
        {2, 100}
      },
      [3] = {
        {1, 100},
        {2, 100}
      }
    },
    lifemax_v = {
      {
        {1, 2000},
        {1, 2000}
      }
    },
    all_series_resist_v = {
      {
        {1, 60},
        {2, 60}
      }
    },
    defense_v = {
      {
        {1, 100},
        {2, 100}
      }
    },
    skill_statetime = {
      {
        {1, 108000},
        {30, 108000}
      }
    }
  },
  buff_couplebless = {
    physical_damage_v = {
      [1] = {
        {1, 50},
        {2, 50}
      },
      [3] = {
        {1, 50},
        {2, 50}
      }
    },
    lifemax_v = {
      {
        {1, 1000},
        {1, 1000}
      }
    },
    all_series_resist_v = {
      {
        {1, 50},
        {2, 50}
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
