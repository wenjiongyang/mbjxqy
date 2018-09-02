local tbUi = Ui:CreateClass("ArenaAccount")
tbUi.tbSeq = {
  [1] = {
    [1] = {
      [1] = {1},
      [2] = {2}
    },
    [2] = {
      [1] = {1},
      [2] = {1, 2}
    },
    [3] = {
      [1] = {1},
      [2] = {
        0,
        1,
        2
      }
    },
    [4] = {
      [1] = {1},
      [2] = {
        0,
        1,
        2,
        3
      }
    }
  },
  [2] = {
    [1] = {
      [1] = {1, 2},
      [2] = {1}
    },
    [2] = {
      [1] = {1, 2},
      [2] = {1, 2}
    },
    [3] = {
      [1] = {1, 2},
      [2] = {
        0,
        1,
        2
      }
    },
    [4] = {
      [1] = {1, 2},
      [2] = {
        0,
        1,
        2,
        3
      }
    }
  },
  [3] = {
    [1] = {
      [1] = {
        0,
        1,
        2
      },
      [2] = {1}
    },
    [2] = {
      [1] = {
        0,
        1,
        2
      },
      [2] = {1, 2}
    },
    [3] = {
      [1] = {
        0,
        1,
        2
      },
      [2] = {
        1,
        2,
        3
      }
    },
    [4] = {
      [1] = {
        0,
        1,
        2
      },
      [2] = {
        0,
        1,
        2,
        3
      }
    }
  },
  [4] = {
    [1] = {
      [1] = {
        0,
        1,
        2,
        3
      },
      [2] = {1}
    },
    [2] = {
      [1] = {
        0,
        1,
        2,
        3
      },
      [2] = {1, 2}
    },
    [3] = {
      [1] = {
        0,
        1,
        2,
        3
      },
      [2] = {
        0,
        1,
        2
      }
    },
    [4] = {
      [1] = {
        0,
        1,
        2,
        3
      },
      [2] = {
        0,
        1,
        2,
        3
      }
    }
  }
}
function tbUi:OnOpen(nMyCamp, tbShowInfo, nWinCamp)
  self:OnClearAll()
  local bBalance = nWinCamp ~= nil
  local nWindowStayTime = 0
  if bBalance then
    nWindowStayTime = 3
    if nMyCamp == nWinCamp then
      self.pPanel:SetActive("Victory", true)
      self.pPanel:SetActive("Failure", false)
    else
      self.pPanel:SetActive("Victory", false)
      self.pPanel:SetActive("Failure", true)
    end
  else
    nWindowStayTime = 3
    self.pPanel:SetActive("Victory", false)
    self.pPanel:SetActive("Failure", false)
  end
  local nMyCount, nEnemyCount = self:GetMemberCount(nMyCamp, tbShowInfo)
  local tbSeqPos = self.tbSeq[nMyCount][nEnemyCount] or {}
  self.nTimeTimer = Timer:Register(nWindowStayTime * Env.GAME_FPS, self.onClose, self)
  for k, v in pairs(tbShowInfo) do
    local szCamp = ""
    local tbPos = {}
    if k == nMyCamp then
      szCamp = "My"
      tbPos = tbSeqPos[1] or {}
    else
      szCamp = "Enemy"
      tbPos = tbSeqPos[2] or {}
    end
    local nIndex = 1
    for l, m in pairs(v) do
      local nPos = tbPos[nIndex] or 1
      self.pPanel:SetActive(szCamp .. tostring(nPos), true)
      self:SetInfoIndexAt(bBalance, m, szCamp, nPos)
      nIndex = nIndex + 1
    end
  end
end
function tbUi:GetMemberCount(nMyCamp, tbShowInfo)
  local nMyCount, nEnemyCount = 0, 0
  for nCamp, tbInfo in pairs(tbShowInfo) do
    if nCamp == nMyCamp then
      nMyCount = #tbInfo
    else
      nEnemyCount = #tbInfo
    end
  end
  return nMyCount, nEnemyCount
end
function tbUi:SetInfoIndexAt(bBalance, tbInfo, szCamp, nIndex)
  if tbInfo.nHonorLevel > 0 then
    self.pPanel:SetActive(szCamp .. "Rank" .. tostring(nIndex), true)
    self.pPanel:Sprite_Animation(szCamp .. "Rank" .. tostring(nIndex), "Title" .. tbInfo.nHonorLevel .. "_")
  else
    self.pPanel:SetActive(szCamp .. "Rank" .. tostring(nIndex), false)
  end
  local szHead, szAtlas = PlayerPortrait:GetPortraitBigIcon(tbInfo.nPortrait)
  self.pPanel:Sprite_SetSprite(szCamp .. "Head" .. tostring(nIndex), szHead, szAtlas)
  local szFactionIcon = Faction:GetIcon(tbInfo.nFaction)
  self.pPanel:Sprite_SetSprite(szCamp .. "Faction" .. tostring(nIndex), szFactionIcon)
  self.pPanel:Label_SetText(szCamp .. "Level" .. tostring(nIndex), tbInfo.nLevel .. "级")
  self.pPanel:Label_SetText(szCamp .. "Name" .. tostring(nIndex), tbInfo.szName)
  if bBalance then
    self.pPanel:Label_SetText(szCamp .. "FightTitle" .. tostring(nIndex), "杀人数：")
    self.pPanel:Label_SetText(szCamp .. "FightValue" .. tostring(nIndex), tbInfo.nKillCount)
    self.pPanel:SetActive(szCamp .. "DmgValue" .. tostring(nIndex), true)
    self.pPanel:SetActive(szCamp .. "DamageTitle" .. tostring(nIndex), true)
    self.pPanel:Label_SetText(szCamp .. "DmgValue" .. tostring(nIndex), tbInfo.nDamage)
  else
    self.pPanel:Label_SetText(szCamp .. "FightTitle" .. tostring(nIndex), "战力：")
    self.pPanel:Label_SetText(szCamp .. "FightValue" .. tostring(nIndex), tbInfo.nFightPower)
    self.pPanel:SetActive(szCamp .. "DmgValue" .. tostring(nIndex), false)
    self.pPanel:SetActive(szCamp .. "DamageTitle" .. tostring(nIndex), false)
  end
end
function tbUi:OnClearAll()
  self.pPanel:SetActive("Victory", false)
  self.pPanel:SetActive("Failure", false)
  for i = 0, 3 do
    self.pPanel:SetActive("My" .. tostring(i), false)
    self.pPanel:SetActive("Enemy" .. tostring(i), false)
  end
end
function tbUi:onClose()
  Ui:CloseWindow(self.UI_NAME)
end
tbUi.tbOnClick = tbUi.tbOnClick or {}
function tbUi.tbOnClick:BtnClose()
  self:onClose()
end
