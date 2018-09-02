local tbUi = Ui:CreateClass("FirstRecharge")
tbUi.NORMAL_VALUE = {
  {
    40,
    2660000,
    {
      2990000,
      3660000,
      4660000,
      5660000,
      5990000,
      6660000
    }
  },
  {
    50,
    2660000,
    {
      2990000,
      3660000,
      4660000,
      5660000,
      5990000,
      6660000
    }
  },
  {
    60,
    2660000,
    {
      2990000,
      3660000,
      4660000,
      5660000,
      5990000,
      6660000
    }
  },
  {
    70,
    2660000,
    {
      2990000,
      3660000,
      4660000,
      5660000,
      5990000,
      6660000
    }
  },
  {
    80,
    2990000,
    {
      3660000,
      4660000,
      4990000,
      5660000,
      6660000,
      7660000
    }
  },
  {
    90,
    3660000,
    {
      3990000,
      4660000,
      5660000,
      6660000,
      6990000,
      7660000
    }
  },
  {
    100,
    4660000,
    {
      4990000,
      5660000,
      6660000,
      7990000,
      7990000,
      8660000
    }
  },
  {
    999,
    4660000,
    {
      4990000,
      5660000,
      6660000,
      7990000,
      7990000,
      8660000
    }
  }
}
tbUi.tbComItem = {
  {"Contrib", 2000},
  {"Coin", 20000},
  {
    "Item",
    212,
    20
  },
  {
    "Item",
    2154,
    2
  },
  {
    "Item",
    786,
    5
  },
  {
    "Item",
    787,
    5
  }
}
tbUi.tbRes = {
  301,
  311,
  321,
  331,
  341,
  351,
  361,
  371,
  381,
  391,
  401,
  411,
  421,
  431
}
function tbUi:OnOpen()
  self.bNpcOpen = true
  self:Update()
end
function tbUi:Update()
  local bGetFirstRecharge = me.GetUserValue(Recharge.SAVE_GROUP, Recharge.KEY_GET_FIRST_RECHARGE) == 1
  self.pPanel:SetActive("BtnRecharge", not bGetFirstRecharge)
  self.pPanel:SetActive("GiveOut", bGetFirstRecharge)
  self.pPanel:Label_SetText("GiveOut", "已发放至背包中")
  local nOffTime = 14400
  local nServerCreateDay = Lib:GetLocalDay(GetServerCreateTime() - nOffTime)
  local nPlayerCreateDay = Lib:GetLocalDay(me.dwCreateTime - nOffTime)
  local nCompensationDay = math.min(nPlayerCreateDay - nServerCreateDay, Recharge.MAX_COMPENSATION)
  local nAllValue = 0
  for _, tbInfo in ipairs(self.NORMAL_VALUE) do
    if me.nLevel < tbInfo[1] then
      if nCompensationDay > 0 then
        nAllValue = tbInfo[3][nCompensationDay]
        break
      end
      nAllValue = tbInfo[2]
      break
    end
  end
  if version_hk or version_tw then
  else
    local fMoney, szMoneyName = Recharge:GetMoneyShowDesc(math.floor(nAllValue / 100))
    if version_vn then
      self.pPanel:Label_SetText("GiftNum", string.format("%s%s", Lib:ThousandSplit(fMoney), szMoneyName))
    else
      self.pPanel:Label_SetText("GiftNum", string.format("%d%s", fMoney, szMoneyName))
    end
  end
  local nParamId = KItem.GetItemExtParam(Recharge.nFirstAwardItem, 1)
  nParamId = Item:GetClass("RandomItemByLevel"):GetRandomKindId(me.nLevel, nParamId)
  local _, _, tbItem = Item:GetClass("RandomItem"):RandomItemAward(me, nParamId)
  local nAwardLen = #tbItem
  for nIdx, tbInfo in ipairs(tbItem) do
    self["itemflame" .. nIdx]:SetGenericItem(tbInfo)
    self["itemflame" .. nIdx].fnClick = self["itemflame" .. nIdx].DefaultClick
  end
  if nCompensationDay > 0 then
    for nIdx, tbInfo in ipairs(self.tbComItem) do
      local tbMulAward = {
        unpack(tbInfo)
      }
      local nLen = #tbMulAward
      tbMulAward[nLen] = tbMulAward[nLen] * nCompensationDay
      nAwardLen = nAwardLen + 1
      self["itemflame" .. nAwardLen]:SetGenericItem(tbMulAward)
      self["itemflame" .. nAwardLen].fnClick = self["itemflame" .. nAwardLen].DefaultClick
    end
  end
  for i = nAwardLen + 1, 99 do
    if not self["itemflame" .. i] then
      break
    end
    self.pPanel:SetActive("itemflame" .. i, false)
  end
  self.pPanel:NpcView_Open("ShowRole")
  self.pPanel:NpcView_ChangePartRes("ShowRole", 0, self.tbRes[me.nFaction])
end
function tbUi:OnClose()
  if self.bNpcOpen then
    self.bNpcOpen = false
    self.pPanel:NpcView_Close("ShowRole")
  end
end
tbUi.tbOnClick = {
  BtnRecharge = function()
    Ui:CloseWindow("WelfareActivity")
    Ui:OpenWindow("CommonShop", "Recharge", "Recharge")
  end
}
tbUi.tbOnDrag = {
  ShowRole = function(self, szWnd, nX, nY)
    self.pPanel:NpcView_ChangeDir("ShowRole", -nX, true)
  end
}
