if not MODULE_GAMESERVER then
  Activity.WomanAct = Activity.WomanAct or {}
  Activity.WomanAct.tbLabelInfo = Activity.WomanAct.tbLabelInfo or {}
  Activity.WomanAct.tbPlayerRequestCD = {}
end
local tbAct = MODULE_GAMESERVER and Activity:GetClass("WomanAct") or Activity.WomanAct
tbAct.nImityLevel = 0
tbAct.nPayLabelCost = 199
tbAct.nSavePayCount = 5
tbAct.nLevelLimit = 20
tbAct.FreeLabel = 1
tbAct.PayLabel = 2
tbAct.nLabelMin = 1
tbAct.nLabelMax = 7
tbAct.nVNLabelMin = 4
tbAct.nVNLabelMax = 14
tbAct.tbFree = {
  "名师风范",
  "美腻的师父",
  "严厉的师傅",
  "厉害的师父",
  "幽默的大大",
  "三人行必有我师",
  "一日为师终身父",
  "有师如此复何求",
  "师父今天去哪玩",
  "师父稀有武器呢"
}
tbAct.nBoxLimit = 5
tbAct.nBoxRefreshTime = 14400
tbAct.nMaxLabel = 15
tbAct.nAddImitity = 100
tbAct.szMailTitle = "留下你的祝福"
tbAct.szMailText = "    佳节将至，侠士经历了如此之久的江湖生活，想必已除了识不少挚友，也应当结识了一位好师父，或是为人师表，有道是一日为师终生为父，何不与师父组队，就快打开祝福册，为与你一同闯荡江湖的师父写上祝福吧！"
tbAct.szMailFrom = ""
tbAct.szAcceptMailTitle = "新的祝福"
tbAct.szAcceptMailFrom = "系统"
tbAct.szAcceptMailText = "    侠士[FFFE0D]%s[-]对你留下了新的祝福——[FFFE0D]%s[-]，赶快去[64db00] [url=openwnd:查看祝福, FriendImpressionPanel] [-]吧！"
tbAct.tbSendAward = {
  [tbAct.FreeLabel] = {
    {
      "item",
      4889,
      1
    }
  },
  [tbAct.PayLabel] = {
    {
      "item",
      4889,
      1
    }
  }
}
tbAct.tbAcceptAward = {
  [tbAct.FreeLabel] = {
    {
      "item",
      4889,
      1
    }
  },
  [tbAct.PayLabel] = {
    {
      "item",
      4889,
      1
    }
  }
}
tbAct.nGirlAwardLabelCount = 15
tbAct.nGirlAward = {
  {
    "item",
    4890,
    1
  }
}
tbAct.tbActiveIndex = {
  [Gift.Sex.Boy] = {
    [1] = {
      {
        "item",
        3910,
        1
      }
    },
    [2] = {
      {
        "item",
        3910,
        1
      }
    },
    [3] = {
      {
        "item",
        3910,
        1
      }
    },
    [4] = {
      {
        "item",
        3910,
        1
      }
    },
    [5] = {
      {
        "item",
        3910,
        1
      }
    }
  },
  [Gift.Sex.Girl] = {
    [1] = {
      {
        "item",
        3909,
        1
      }
    },
    [2] = {
      {
        "item",
        3909,
        1
      }
    },
    [3] = {
      {
        "item",
        3909,
        1
      }
    },
    [4] = {
      {
        "item",
        3909,
        1
      }
    },
    [5] = {
      {
        "item",
        3909,
        1
      }
    }
  }
}
tbAct.tbFree2Label = tbAct.tbFree2Label or {}
if not next(tbAct.tbFree2Label) then
  for k, v in pairs(tbAct.tbFree) do
    tbAct.tbFree2Label[v] = k
  end
end
tbAct.nImpressionLabelItemID = 3910
tbAct.nNeedConsumeImpressionLabel = 1
tbAct.szSendLabelEndTime = "2017-6-18-23-59-59"
function tbAct:InitData()
  local tbEndDateTime = Lib:SplitStr(self.szSendLabelEndTime, "-")
  local year, month, day, hour, minute, second = unpack(tbEndDateTime)
  local nEndTime = os.time({
    year = tonumber(year),
    month = tonumber(month),
    day = tonumber(day),
    hour = tonumber(hour),
    min = tonumber(minute),
    sec = tonumber(second)
  })
  self.nSendLabelEndTime = nEndTime
end
tbAct:InitData()
function tbAct:IsEndSendLabel()
  if GetTime() >= self.nSendLabelEndTime then
    return true, "活动已结束，无法添加祝福"
  end
  return false
end
function tbAct:CheckCommon(pPlayer, nAcceptId, nType, szLabel, bNotCheckGold)
  local bRet, szMsg = self:IsEndSendLabel()
  if bRet then
    return false, szMsg
  end
  if nType ~= self.FreeLabel and nType ~= self.PayLabel then
    return false, "未知类型"
  end
  if szLabel == "" then
    return false, "未知标签"
  end
  if pPlayer.nLevel < self.nLevelLimit then
    return false, string.format("参与等级不足%s", self.nLevelLimit)
  end
  if MODULE_GAMESERVER and not TeacherStudent:IsMyTeacher(pPlayer, nAcceptId) then
    return false, "只能为师父添加祝福"
  end
  local nImityLevel = FriendShip:GetFriendImityLevel(pPlayer.dwID, nAcceptId) or 0
  if nImityLevel < self.nImityLevel then
    return false, string.format("双方亲密度不足%s级", self.nImityLevel)
  end
  if nType == self.FreeLabel then
    if pPlayer.GetItemCountInAllPos(self.nImpressionLabelItemID) < self.nNeedConsumeImpressionLabel then
      return false, string.format("您拥有的%s不足", KItem.GetItemShowInfo(self.nImpressionLabelItemID, pPlayer.nFaction) or "祝福签")
    end
    if not self.tbFree2Label[szLabel] then
      return false, "未知的标签描述"
    end
  elseif nType == self.PayLabel then
    if not bNotCheckGold and pPlayer.GetMoney("Gold") < self.nPayLabelCost then
      return false, "元宝不足"
    end
    if version_vn then
      local nVNLen = string.len(szLabel)
      if nVNLen > self.nVNLabelMax or nVNLen < self.nVNLabelMin then
        return false, string.format("自定义标签需在%d~%d字之间", self.nVNLabelMin, self.nVNLabelMax)
      end
    else
      local nNameLen = Lib:Utf8Len(szLabel)
      if nNameLen > self.nLabelMax or nNameLen < self.nLabelMin then
        return false, string.format("自定义标签需在%d~%d字之间", self.nLabelMin, self.nLabelMax)
      end
    end
    if not CheckNameAvailable(szLabel) then
      return false, "含有非法字符，请修改后重试"
    end
  end
  return true
end
function tbAct:OnSendLabelSuccess()
  UiNotify.OnNotify(UiNotify.emNOTIFY_WOMAN_SYNDATA)
end
function tbAct:OnAcceptLabelSuccess()
end
function tbAct:OnSynData(tbData, nStartTime, nEndTime)
  self.nStartTime = nStartTime
  self.nEndTime = nEndTime
  self:FormatData(tbData)
  UiNotify.OnNotify(UiNotify.emNOTIFY_WOMAN_SYNDATA)
end
function tbAct:FormatData(tbData)
  for dwID, tbInfo in pairs(tbData or {}) do
    self.tbLabelInfo[dwID] = self.tbLabelInfo[dwID] or {}
    self.tbLabelInfo[dwID].nPlayerId = dwID
    self.tbLabelInfo[dwID].tbFreeLabel = tbInfo.tbFreeLabel or self.tbLabelInfo[dwID].tbFreeLabel or {}
    self.tbLabelInfo[dwID].tbPayLabel = tbInfo.tbPayLabel or self.tbLabelInfo[dwID].tbPayLabel or {}
    self.tbLabelInfo[dwID].tbLabelTime = tbInfo.tbLabelTime or self.tbLabelInfo[dwID].tbLabelTime or {}
    self.tbLabelInfo[dwID].tbPayLabelPlayer = tbInfo.tbPayLabelPlayer or self.tbLabelInfo[dwID].tbPayLabelPlayer or {}
    self.tbLabelInfo[dwID].nHadLabelCount = tbInfo.nHadLabelCount or self.tbLabelInfo[dwID].nHadLabelCount or 0
  end
end
function tbAct:OnSynLabelPlayer(tbData)
  self.tbPriorData = tbData
  Ui:OpenWindow("FriendImpressionPanel")
end
function tbAct:GetLabelInfo()
  return self.tbLabelInfo
end
function tbAct:GetPriorData()
  return self.tbPriorData
end
function tbAct:ClearPriorData()
  self.tbPriorData = nil
end
function tbAct:OpenLabelWindow(nTargetId)
  if FriendShip:IsFriend(me.dwID, nTargetId) then
    Ui:OpenWindow("FriendImpressionPanel", nTargetId)
  else
    RemoteServer.TrySynLabelPlayer(nTargetId)
  end
end
function tbAct:GetTimeInfo()
  return self.nStartTime, self.nEndTime
end
