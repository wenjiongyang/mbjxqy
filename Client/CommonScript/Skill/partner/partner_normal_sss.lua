local tb = {
  partner_qsh_normal = {
    attack_usebasedamage_p = {
      {
        {1, 360},
        {20, 360}
      }
    },
    missile_hitcount = {
      0,
      0,
      3
    }
  },
  partner_qsh_hj = {
    userdesc_000 = {3228}
  },
  partner_qsh_hj_child1 = {
    call_npc1 = {
      2166,
      -1,
      5
    },
    call_npc2 = {
      2166,
      -1,
      5
    },
    call_npc3 = {
      2166,
      -1,
      5
    },
    remove_call_npc = {2166},
    skill_statetime = {
      {
        {1, 75},
        {30, 75}
      }
    }
  },
  partner_qsh_hj_child2 = {
    callnpc_life = {
      2166,
      {
        {1, 100},
        {10, 100}
      }
    },
    callnpc_damage = {
      2166,
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
  partner_qsh_hjgj_child1 = {
    attack_usebasedamage_p = {
      {
        {1, 180},
        {30, 180}
      }
    },
    missile_hitcount = {
      0,
      0,
      3
    }
  },
  partner_qsh_hjgj_child3 = {
    attack_usebasedamage_p = {
      {
        {1, 180},
        {30, 180}
      }
    },
    missile_hitcount = {
      0,
      0,
      3
    }
  },
  partner_wyhl_normal = {
    dotdamage_wood = {
      {
        {1, 120},
        {30, 120}
      },
      {
        {1, 0},
        {30, 0}
      },
      {
        {1, 1},
        {30, 1}
      }
    },
    skill_statetime = {
      {
        {1, 3},
        {30, 3}
      }
    },
    missile_hitcount = {
      0,
      0,
      3
    }
  },
  partner_wyhl_jn = {
    attack_usebasedamage_p = {
      {
        {1, 180},
        {30, 180}
      }
    },
    dotdamage_wood = {
      {
        {1, 180},
        {30, 180}
      },
      {
        {1, 0},
        {30, 0}
      },
      {
        {1, 1},
        {30, 1}
      }
    },
    skill_statetime = {
      {
        {1, 5},
        {30, 5}
      }
    },
    missile_hitcount = {
      0,
      0,
      3
    }
  },
  partner_xy_normal = {
    attack_usebasedamage_p = {
      {
        {1, 400},
        {20, 400}
      }
    },
    missile_hitcount = {
      0,
      0,
      3
    }
  },
  partner_xy_hmby = {
    attack_usebasedamage_p = {
      {
        {1, 1200},
        {30, 1200}
      }
    },
    state_drag_attack = {
      {
        {1, 100},
        {30, 100}
      },
      8,
      70
    },
    skill_drag_npclen = {60},
    state_palsy_attack = {
      {
        {1, 100},
        {30, 100}
      },
      {
        {1, 30},
        {30, 30}
      }
    }
  },
  partner_wzt_normal = {
    attack_usebasedamage_p = {
      {
        {1, 360},
        {20, 360}
      }
    },
    missile_hitcount = {
      0,
      0,
      3
    }
  },
  partner_wzt_ndzl = {
    userdesc_000 = {3922},
    autoskill = {
      102,
      {
        {1, 1},
        {30, 30}
      }
    },
    physics_potentialdamage_p = {
      {
        {1, 50},
        {30, 50}
      }
    },
    all_series_resist_p = {
      {
        {1, 100},
        {30, 100}
      }
    },
    attackspeed_v = {
      {
        {1, 30},
        {30, 30}
      }
    },
    skill_statetime = {
      {
        {1, 225},
        {30, 225}
      }
    }
  },
  partner_wzt_ndzl_child = {
    state_freeze_attack = {
      {
        {1, 100},
        {30, 100}
      },
      {
        {1, 22.5},
        {30, 22.5}
      }
    },
    userdesc_101 = {
      {
        {1, 30},
        {30, 30}
      }
    },
    userdesc_102 = {
      {
        {1, 75},
        {30, 75}
      }
    },
    missile_hitcount = {
      0,
      0,
      1
    }
  }
}
FightSkill:AddMagicData(tb)
