Require("CommonScript/Kin/KinDef.lua")
ChuangGong.nGetMinLevel = 15
ChuangGong.nSendMinLevel = 30
ChuangGong.nDoubleExpLevel = 20
ChuangGong.nSendExp = 60
ChuangGong.nSendAddContrib = 100
ChuangGong.TIME_DELAY = 600
ChuangGong.TIME_DELTA = 6
ChuangGong.TIMES = 10
ChuangGong.SEND_CD = 1800
ChuangGong.tbCDVip = {17, 18}
ChuangGong.tbGetLevelExp = {
  {30, 360},
  {40, 480},
  {120, 720}
}
ChuangGong.tbXinShowMapPos = {
  {
    10,
    {
      {10711, 18074},
      {10878, 18073}
    }
  },
  {
    10,
    {
      {10488, 19108},
      {10317, 19107}
    }
  },
  {
    10,
    {
      {10008, 18885},
      {10007, 18720}
    }
  },
  {
    10,
    {
      {8863, 17765},
      {8752, 17654}
    }
  },
  {
    10,
    {
      {8386, 18632},
      {8216, 18632}
    }
  },
  {
    10,
    {
      {8190, 19026},
      {8023, 19026}
    }
  },
  {
    10,
    {
      {7463, 18857},
      {7630, 18858}
    }
  },
  {
    10,
    {
      {7154, 18632},
      {7322, 18630}
    }
  },
  {
    10,
    {
      {7518, 18101},
      {7689, 18101}
    }
  },
  {
    10,
    {
      {9143, 18492},
      {8973, 18492}
    }
  },
  {
    10,
    {
      {9141, 18185},
      {8970, 18185}
    }
  },
  {
    10,
    {
      {8386, 18015},
      {8218, 18015}
    }
  },
  {
    10,
    {
      {8385, 17568},
      {8219, 17571}
    }
  },
  {
    10,
    {
      {8779, 19219},
      {8775, 19053}
    }
  },
  {
    10,
    {
      {7519, 18465},
      {7688, 18465}
    }
  },
  {
    10,
    {
      {7573, 16896},
      {7742, 16896}
    }
  },
  {
    10,
    {
      {8131, 16895},
      {8303, 16895}
    }
  },
  {
    10,
    {
      {9170, 16949},
      {9281, 17065}
    }
  },
  {
    10,
    {
      {9898, 17711},
      {10064, 17710}
    }
  },
  {
    10,
    {
      {8584, 16194},
      {8749, 16198}
    }
  },
  {
    10,
    {
      {9142, 22356},
      {9310, 22356}
    }
  },
  {
    10,
    {
      {11521, 23056},
      {11691, 23058}
    }
  },
  {
    10,
    {
      {13454, 21235},
      {13454, 21067}
    }
  },
  {
    10,
    {
      {15862, 18659},
      {15860, 18495}
    }
  },
  {
    10,
    {
      {17736, 12696},
      {17738, 12528}
    }
  }
}
ChuangGong.tbHouseMapPos = {
  {
    {1557, 6592},
    {1555, 6424}
  }
}
ChuangGong.tbKinMapPos = {
  {
    {4493, 5081},
    {4660, 5080}
  },
  {
    {4326, 3734},
    {4495, 3738}
  },
  {
    {5641, 4356},
    {5813, 4353}
  },
  {
    {5165, 3685},
    {5332, 3681}
  },
  {
    {5246, 5109},
    {5417, 5109}
  },
  {
    {5666, 4044},
    {5839, 4045}
  },
  {
    {4238, 4186},
    {4411, 4187}
  },
  {
    {3991, 3961},
    {4155, 3963}
  },
  {
    {5361, 4773},
    {5528, 4771}
  },
  {
    {4634, 3344},
    {4799, 3346}
  },
  {
    {4772, 4857},
    {4940, 4857}
  },
  {
    {5247, 3344},
    {5415, 3345}
  },
  {
    {4383, 4688},
    {4553, 4687}
  },
  {
    {5695, 3740},
    {5864, 3737}
  },
  {
    {6174, 3905},
    {6343, 3906}
  },
  {
    {5640, 5389},
    {5806, 5387}
  },
  {
    {5279, 6006},
    {5136, 6005}
  }
}
ChuangGong.tbSelfKinMapPos = {
  {5191, 4924},
  {5761, 4881},
  {5937, 4204},
  {4924, 3644},
  {4444, 3981},
  {4404, 4511},
  {4452, 4924},
  {5564, 5229},
  {6245, 4090},
  {4981, 5267}
}
ChuangGong.tbSelfGetLevelExp = {
  {150, 30}
}
ChuangGong.nSelfTimes = 5
ChuangGong.nSelfDelayTime = 6
ChuangGong.SAVE_GROUP = 23
ChuangGong.KEY_SEND_TIME = 7
ChuangGong.KEY_USE_CHUANGGONGDAN_TIME = 8
ChuangGong.KEY_EXTRA_CHUANGGONG = 9
ChuangGong.KEY_EXTRA_CHUANGGONGSEND = 10
ChuangGong.MaxDistance = 2000
ChuangGong.szOpenFrame = "OpenDay2"
ChuangGong.szRequestGoSafeTip = "您当前无法传功，是否需要回到安全区申请传功？"
ChuangGong.szBtnGoSafeTip = "您当前无法传功，是否需要回到安全区进行传功？"
local tbLegalMap = {
  1,
  2,
  3,
  4,
  5,
  6,
  7,
  8,
  9,
  10,
  999,
  Kin.Def.nKinMapTemplateId
}
ChuangGong.tbLegalMap = {}
for i, v in ipairs(tbLegalMap) do
  ChuangGong.tbLegalMap[v] = 1
end
ChuangGong.tbWithoutCDVip = {}
for _, nVip in ipairs(ChuangGong.tbCDVip) do
  ChuangGong.tbWithoutCDVip[nVip] = true
end
function ChuangGong:IsWhiteMap(nMapTemplateId)
  if ChuangGong.tbLegalMap[nMapTemplateId] then
    return true
  end
  if Map:IsHouseMap(nMapTemplateId) then
    return true
  end
  return false
end
function ChuangGong:CheckSelfChuanGong(pPlayer)
  local tbKinData = Kin:GetKinById(pPlayer.dwKinId)
  if not tbKinData then
    return false, "请先加入家族"
  end
  if GetTimeFrameState(self.szOpenFrame) ~= 1 then
    return false, "当前还没开放传功"
  end
  if not Env:CheckSystemSwitch(pPlayer, Env.SW_ChuangGong) then
    return false, "当前状态不允许修炼"
  end
  return true
end
function ChuangGong:IsUsedChuangGongDan(pPlayer)
  return not Lib:IsDiffDay(Item:GetClass("ChuangGongDan"):GetChuangGongDanUseResetTime(), self:ChuangGongDanUseTime(pPlayer))
end
function ChuangGong:ChuangGongDanUseTime(pPlayer)
  return pPlayer.GetUserValue(self.SAVE_GROUP, self.KEY_USE_CHUANGGONGDAN_TIME)
end
function ChuangGong:CheckLevelLimi(nSendLevel, nGetLevel, nSendVip, nGetVip)
  if nGetLevel < self.nGetMinLevel then
    return false, self.nGetMinLevel .. "级后才能接受传功"
  end
  if GetTimeFrameState(self.szOpenFrame) ~= 1 then
    return false, "当前还没开放传功"
  end
  if nSendLevel < self.nSendMinLevel then
    return false, string.format("传功者需要%d级", self.nSendMinLevel)
  end
  local nMinusMinLevel = 1
  if nSendVip and nGetVip then
    local tbMinusLevelSet = Recharge.tbVipExtSetting.ChuangGongLevelMinus
    local nVipLevel = nGetVip < nSendVip and nSendVip or nGetVip
    for i, v in ipairs(tbMinusLevelSet) do
      if nVipLevel >= v[1] then
        nMinusMinLevel = v[2]
      else
        break
      end
    end
  end
  if nMinusMinLevel > nSendLevel - nGetLevel then
    return false, string.format("双方等级差不足%d, 无法传功", nMinusMinLevel)
  end
  return true
end
function ChuangGong:IsCanChuangGong(tbParam)
  local bIsMeSend = me.nLevel > tbParam.nLevel and true or false
  local nSendLevel = bIsMeSend and me.nLevel or tbParam.nLevel or 0
  local nGetLevel = bIsMeSend and (tbParam.nLevel or 0) or me.nLevel
  local nSendVip = bIsMeSend and me.GetVipLevel() or tbParam.nVipLevel or 0
  local nGetVip = bIsMeSend and (tbParam.nVipLevel or 0) or me.GetVipLevel()
  local nChuangGongTimes = tbParam.nChuangGongTimes or 0
  local nChuangGongSendTimes = tbParam.nChuangGongSendTimes or 0
  local nLastChuangGongSendTime = tbParam.nLastChuangGongSendTime or 0
  if nSendLevel == nGetLevel then
    return false
  end
  if not self:CheckLevelLimi(nSendLevel, nGetLevel, nSendVip, nGetVip) then
    return false
  end
  local nMyChuangGongTimes = ChuangGong:GetDegree(me, "ChuangGong")
  local nMyChuangGongSendTimes = ChuangGong:GetDegree(me, "ChuangGongSend")
  local nMyLastChuangGongSendTime = me.GetUserValue(self.SAVE_GROUP, self.KEY_SEND_TIME)
  local nCDTime = 0
  local nTimeNow = GetTime()
  if bIsMeSend then
    nCDTime = nMyLastChuangGongSendTime + self.SEND_CD - nTimeNow
    if nMyChuangGongSendTimes < 1 or nChuangGongTimes < 1 or not ChuangGong.tbWithoutCDVip[nSendVip] and nCDTime > 0 then
      return false
    end
  else
    nCDTime = nLastChuangGongSendTime + self.SEND_CD - nTimeNow
    if nMyChuangGongTimes < 1 or nChuangGongSendTimes < 1 or not ChuangGong.tbWithoutCDVip[nSendVip] and nCDTime > 0 then
      return false
    end
  end
  return true
end
function ChuangGong:GetDegree(pPlayer, szType)
  local nDefault = 0
  local nChuangGongDan = 0
  local nSaveIndex
  if szType == "ChuangGong" then
    nDefault = DegreeCtrl:GetDegree(pPlayer, "ChuangGong")
    nChuangGongDan = pPlayer.GetUserValue(self.SAVE_GROUP, self.KEY_EXTRA_CHUANGGONG)
    nSaveIndex = ChuangGong.KEY_EXTRA_CHUANGGONG
  elseif szType == "ChuangGongSend" then
    nDefault = DegreeCtrl:GetDegree(pPlayer, "ChuangGongSend")
    nChuangGongDan = pPlayer.GetUserValue(self.SAVE_GROUP, self.KEY_EXTRA_CHUANGGONGSEND)
    nSaveIndex = ChuangGong.KEY_EXTRA_CHUANGGONGSEND
  end
  return nDefault + nChuangGongDan, nDefault, nChuangGongDan, nSaveIndex
end
function ChuangGong:CheckIsDegreeOut(pPlayer)
  local nCount = ChuangGong:GetDegree(pPlayer, "ChuangGong")
  local nSendCount = ChuangGong:GetDegree(pPlayer, "ChuangGongSend")
  return nCount + nSendCount <= 0 and not Item:GetClass("ChuangGongDan"):CheckUse(pPlayer)
end
function ChuangGong:CheckIsDegreeOutCanUseCGD(pPlayer)
  local nCount = ChuangGong:GetDegree(pPlayer, "ChuangGong")
  local nSendCount = ChuangGong:GetDegree(pPlayer, "ChuangGongSend")
  return nCount + nSendCount <= 0 and Item:GetClass("ChuangGongDan"):CheckUse(pPlayer)
end
