Gift.tbGirls = {
  [2] = "峨嵋",
  [3] = "桃花",
  [6] = "天忍",
  [8] = "翠烟",
  [10] = "昆仑",
  [12] = "五毒",
  [14] = "长歌"
}
Gift.tbBoys = {
  [1] = "天王",
  [4] = "逍遥",
  [5] = "武当",
  [7] = "少林",
  [9] = "唐门",
  [11] = "丐帮",
  [13] = "藏剑"
}
Gift.Sex = {Boy = 1, Girl = 2}
Gift.GiftType = {
  RoseAndGrass = 1,
  FlowerBox = 2,
  MailGift = 3,
  Lover = 4
}
Gift.AllGift = {
  [Gift.GiftType.RoseAndGrass] = true,
  [Gift.GiftType.FlowerBox] = true,
  [Gift.GiftType.MailGift] = true,
  [Gift.GiftType.Lover] = true
}
Gift.AllGiftNeedOnline = {
  [Gift.GiftType.RoseAndGrass] = true,
  [Gift.GiftType.FlowerBox] = true,
  [Gift.GiftType.MailGift] = false,
  [Gift.GiftType.Lover] = true
}
Gift.MailType = {
  Times2Player = 1,
  Times2Item = 2,
  NoLimit = 3
}
Gift.MailTimesType = {
  [Gift.MailType.Times2Player] = true,
  [Gift.MailType.Times2Item] = true,
  [Gift.MailType.NoLimit] = true
}
Gift.MailTimesTypeNeedOnline = {
  [Gift.MailType.Times2Player] = true,
  [Gift.MailType.Times2Item] = true,
  [Gift.MailType.NoLimit] = false
}
Gift.Times = {Forever = -1}
Gift.nRoseId = 1234
Gift.nGrassId = 1235
Gift.nRoseBoxId = 2180
Gift.nGrassBoxId = 2181
Gift.nQiaoKeLiId = 3789
Gift.nFlowerId = 3788
Gift.SpecialGift = {
  [Gift.GiftType.MailGift] = true
}
Gift.IsReset = {
  [Gift.GiftType.RoseAndGrass] = true,
  [Gift.GiftType.FlowerBox] = true,
  [Gift.GiftType.Lover] = true
}
Gift.SendTimes = {
  [Gift.GiftType.RoseAndGrass] = 5,
  [Gift.GiftType.FlowerBox] = 5,
  [Gift.GiftType.Lover] = 1
}
Gift.Rate = {
  [Gift.GiftType.RoseAndGrass] = 50,
  [Gift.GiftType.FlowerBox] = 999,
  [Gift.GiftType.Lover] = 200
}
Gift.AllItem = {
  [Gift.GiftType.RoseAndGrass] = {
    [Gift.Sex.Boy] = {
      Gift.nGrassId,
      "棵幸运草"
    },
    [Gift.Sex.Girl] = {
      Gift.nRoseId,
      "朵玫瑰花"
    }
  },
  [Gift.GiftType.FlowerBox] = {
    [Gift.Sex.Boy] = {
      Gift.nGrassBoxId,
      "99棵幸运草"
    },
    [Gift.Sex.Girl] = {
      Gift.nRoseBoxId,
      "99朵玫瑰花"
    }
  },
  [Gift.GiftType.Lover] = {
    [Gift.Sex.Boy] = {
      Gift.nQiaoKeLiId,
      "个春蚕悬丝"
    },
    [Gift.Sex.Girl] = {
      Gift.nFlowerId,
      "朵蓝色妖姬"
    }
  }
}
Gift.tbBoxNotice = {
  [Gift.Sex.Boy] = {
    [Gift.Sex.Boy] = "「%s」从火热的胸膛处掏出【%s】送给「%s」，说道：兄弟！天涯何处无芳草，送你一把幸运草……咱俩大块肉，大杯酒，岂不快活！",
    [Gift.Sex.Girl] = "「%s」拿出藏在背后已久的【%s】送给「%s」，说道：此花只应天上有，不及佳人一回眸。最珍贵的花亦远不如你，故此花非你莫属。"
  },
  [Gift.Sex.Girl] = {
    [Gift.Sex.Boy] = "「%s」红着脸颊从香囊取出【%s】送给「%s」，说道：花开草叶侧，只缘君护花。谢谢你一路以来的相伴，希望它能为你带来幸运。",
    [Gift.Sex.Girl] = "「%s」从贴身的锦囊中取出【%s】送给「%s」，说道：唯有闺中蜜，方知两人心，我最最亲爱的姐妹，愿你一世貌美如花，不可方物。"
  }
}
Gift.tbMailGift = {}
Gift.tbAllMailItem = {}
Gift.tbAllMailGirlItem = {}
function Gift:LoadSetting()
  local szTabPath = "Setting/Gift/MailGift.tab"
  local szParamType = "sssdddddddsdddd"
  local szKey = "szKey"
  local tbParams = {
    "szKey",
    "szId",
    "szGirlId",
    "nTimesType",
    "nReset",
    "nTimes",
    "nItemSend",
    "nItemAccept",
    "nSure",
    "nImityLevel",
    "szSureTip",
    "nVip",
    "nAddImitity",
    "nNotSendMail",
    "nNotConsume"
  }
  local tbFile = LoadTabFile(szTabPath, szParamType, szKey, tbParams)
  for szKey, tbInfo in pairs(tbFile) do
    self.tbMailGift[szKey] = self.tbMailGift[szKey] or {}
    assert(tbInfo.szId ~= "", "[Gift] LoadSetting no szId")
    local tbId = Lib:SplitStr(tbInfo.szId, ";")
    assert(next(tbId), "[Gift] LoadSetting fail ! tbItemId is {}")
    local tbGirlId = {}
    if tbInfo.szGirlId ~= "" then
      tbGirlId = Lib:SplitStr(tbInfo.szGirlId, ";")
      assert(#tbId == #tbGirlId, "[Gift] LoadSetting mail item count not equal " .. #tbId .. "====" .. #tbGirlId)
    end
    local tbItemId = {}
    for i, v in pairs(tbId) do
      local nV = tonumber(v)
      if not nV then
        Log("[Gift] not invail id")
        return
      end
      tbItemId[i] = nV
    end
    local tbGirlItemId = {}
    if next(tbGirlId) then
      for k, v in pairs(tbItemId) do
        local nV = tonumber(tbGirlId[k])
        if not nV then
          Log("[Gift] tbGirlItemId not invail id")
          return
        end
        assert(nV ~= v, "[Gift] tbGirlItemId same id " .. nV .. "====" .. v)
        tbGirlItemId[k] = nV
      end
    end
    self.tbMailGift[szKey].tbItemId = tbItemId
    self.tbMailGift[szKey].tbGirlItemId = tbGirlItemId
    if tbInfo.nReset and tbInfo.nReset == 1 then
      self.tbMailGift[szKey].bReset = true
    end
    if tbInfo.nSure and tbInfo.nSure == 1 then
      self.tbMailGift[szKey].bSure = true
    end
    assert(Gift.MailTimesType[tbInfo.nTimesType], "error times type")
    self.tbMailGift[szKey].nTimesType = tbInfo.nTimesType
    self.tbMailGift[szKey].nTimes = tbInfo.nTimes or 0
    self.tbMailGift[szKey].nItemSend = tbInfo.nItemSend
    self.tbMailGift[szKey].nItemAccept = tbInfo.nItemAccept
    self.tbMailGift[szKey].nImityLevel = tbInfo.nImityLevel
    self.tbMailGift[szKey].nVip = tbInfo.nVip
    if tbInfo.nAddImitity > 0 then
      self.tbMailGift[szKey].nAddImitity = tbInfo.nAddImitity
    end
    if tbInfo.nNotSendMail > 0 then
      self.tbMailGift[szKey].bNotSendMail = true
    end
    if tbInfo.nNotConsume > 0 then
      self.tbMailGift[szKey].bNotConsume = true
    end
    if tbInfo.szSureTip ~= "" then
      self.tbMailGift[szKey].szSureTip = tbInfo.szSureTip
    end
    for nIdx, nItemId in pairs(tbItemId) do
      assert(not Gift.tbAllMailItem[nItemId], "gift same item id")
      Gift.tbAllMailItem[nItemId] = {}
      Gift.tbAllMailItem[nItemId].tbData = self.tbMailGift[szKey]
      Gift.tbAllMailItem[nItemId].szKey = szKey
      Gift.tbAllMailItem[nItemId].nIdx = nIdx
    end
    for nIdx, nItemId in pairs(tbGirlItemId) do
      assert(not Gift.tbAllMailGirlItem[nItemId], "gift tbAllMailGirlItem same item id")
      Gift.tbAllMailGirlItem[nItemId] = {}
      Gift.tbAllMailGirlItem[nItemId].tbData = self.tbMailGift[szKey]
      Gift.tbAllMailGirlItem[nItemId].szKey = szKey
      Gift.tbAllMailGirlItem[nItemId].nIdx = nIdx
    end
  end
end
Gift:LoadSetting()
function Gift:CheckMailItemSex(nItemId)
  local nSex
  if Gift.tbAllMailItem[nItemId] then
    nSex = Gift.Sex.Boy
  elseif Gift.tbAllMailGirlItem[nItemId] then
    nSex = Gift.Sex.Girl
  end
  return nSex
end
function Gift:CheckMailSexLimit(szKey)
  local bSexLimit
  local tbInfo = Gift:GetMailGiftInfo(szKey)
  if tbInfo and tbInfo.tbGirlItemId and next(tbInfo.tbGirlItemId) then
    bSexLimit = true
  end
  return bSexLimit
end
function Gift:GetMailGiftItemInfo(nItemId)
  return Gift.tbAllMailItem[nItemId] or Gift.tbAllMailGirlItem[nItemId]
end
function Gift:GetMailGiftInfo(szKey)
  return Gift.tbMailGift[szKey]
end
function Gift:GetSpecialTimes(nGiftType, nItemId)
  local nTimes, tbInfo
  if nGiftType == Gift.GiftType.MailGift then
    tbInfo = self:GetMailGiftItemInfo(nItemId)
    nTimes = tbInfo and tbInfo.tbData.nTimes
  end
  return nTimes
end
function Gift:GetMailAddImitity(nGiftType, nItemId)
  local nAddImitity, tbInfo
  if nGiftType == Gift.GiftType.MailGift then
    tbInfo = self:GetMailGiftItemInfo(nItemId)
    nAddImitity = tbInfo and tbInfo.tbData.nAddImitity
  end
  return nAddImitity
end
function Gift:GetMailTimesType(nGiftType, nItemId)
  local nType, tbInfo
  if nGiftType == Gift.GiftType.MailGift then
    tbInfo = self:GetMailGiftItemInfo(nItemId)
    nType = tbInfo and tbInfo.tbData.nTimesType
  end
  return nType
end
function Gift:GetItemAcceptTimes(nGiftType, nItemId)
  local nTimes, tbInfo
  if nGiftType == Gift.GiftType.MailGift then
    tbInfo = self:GetMailGiftItemInfo(nItemId)
    nTimes = tbInfo and tbInfo.tbData.nItemAccept
  end
  return nTimes
end
function Gift:GetItemSendTimes(nGiftType, nItemId)
  local nTimes, tbInfo
  if nGiftType == Gift.GiftType.MailGift then
    tbInfo = self:GetMailGiftItemInfo(nItemId)
    nTimes = tbInfo and tbInfo.tbData.nItemSend
  end
  return nTimes
end
function Gift:GetIsReset(nGiftType, nItemId)
  if nGiftType == Gift.GiftType.MailGift then
    local tbInfo = self:GetMailGiftItemInfo(nItemId)
    return tbInfo and tbInfo.tbData.bReset
  else
    return Gift.IsReset[nGiftType]
  end
end
function Gift:CheckNeedSure(nGiftType, nItemId)
  if nGiftType == Gift.GiftType.MailGift then
    local tbInfo = self:GetMailGiftItemInfo(nItemId)
    return tbInfo and tbInfo.tbData.bSure
  end
end
function Gift:CheckSex(nFaction)
  if Gift.tbGirls[nFaction] then
    return Gift.Sex.Girl
  elseif Gift.tbBoys[nFaction] then
    return Gift.Sex.Boy
  end
end
function Gift:CheckCommond(pPlayer, nAcceptId, nCount, nGiftType)
  if not nCount or nCount < 1 then
    return false, "请选择要赠送的物品"
  end
  local pAcceptPlayer = KPlayer.GetPlayerObjById(nAcceptId)
  if not pAcceptPlayer then
    return false, "对方不在线"
  end
  local nSex = self:CheckSex(pAcceptPlayer.nFaction)
  if not nSex then
    return false, "对方是男?是女?"
  end
  local bIsFriend = FriendShip:IsFriend(pPlayer.dwID, nAcceptId)
  if not bIsFriend then
    return false, "对方不是你的好友"
  end
  local nItemId = Gift:GetItemId(nGiftType, nSex)
  if not nItemId then
    return false, "找不到要赠送的物品"
  end
  local nOrgCount = pPlayer.GetItemCountInAllPos(nItemId)
  local szItemName = KItem.GetItemShowInfo(nItemId, pPlayer.nFaction)
  if nCount > nOrgCount then
    return false, string.format("您的%s不够", szItemName)
  end
  return true, "", pAcceptPlayer, nSex, nItemId, szItemName
end
function Gift:BoxNotice(nSendSex, nAcceptSex)
  local szNotice = "「%s」对「%s」赠送了%s"
  if Gift.tbBoxNotice[nSendSex] and Gift.tbBoxNotice[nSendSex][nAcceptSex] then
    szNotice = Gift.tbBoxNotice[nSendSex][nAcceptSex]
  end
  return szNotice
end
function Gift:GetItemDesc(nGiftType, nSex)
  return Gift.AllItem[nGiftType] and Gift.AllItem[nGiftType][nSex] and Gift.AllItem[nGiftType][nSex][2]
end
function Gift:GetItemId(nGiftType, nSex)
  return Gift.AllItem[nGiftType] and Gift.AllItem[nGiftType][nSex] and Gift.AllItem[nGiftType][nSex][1]
end
