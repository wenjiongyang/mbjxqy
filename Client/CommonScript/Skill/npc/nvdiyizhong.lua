local tb = {
  wzt_normal = {
    attack_usebasedamage_p = {
      {
        {1, 200},
        {30, 200}
      }
    }
  },
  wzt_s1 = {
    attack_usebasedamage_p = {
      {
        {1, 250},
        {30, 250}
      }
    },
    state_freeze_attack = {
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
  wzt_s2 = {
    call_npc1 = {
      2531,
      -1,
      5
    },
    call_npc2 = {
      2531,
      -1,
      5
    },
    call_npc3 = {
      2531,
      -1,
      5
    },
    call_npc4 = {
      2531,
      -1,
      5
    },
    call_npc5 = {
      2531,
      -1,
      5
    },
    remove_call_npc = {1880},
    skill_statetime = {
      {
        {1, 900},
        {30, 900}
      }
    }
  },
  wzt_s2_child = {
    callnpc_life = {
      2531,
      {
        {1, 1},
        {10, 1}
      }
    },
    callnpc_damage = {
      2531,
      {
        {1, 0},
        {10, 0}
      }
    },
    skill_statetime = {
      {
        {1, 900},
        {30, 900}
      }
    }
  }
}
FightSkill:AddMagicData(tb)
