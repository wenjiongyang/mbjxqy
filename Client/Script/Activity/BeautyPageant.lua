Require("CommonScript/Activity/BeautyPageant.lua")
local tbAct = Activity.BeautyPageant
local tbActUiSetting = Activity:GetUiSetting("BeautyPageant")
tbActUiSetting.szUiName = "BeautySelection"
tbActUiSetting.szTitle = "武林第一美女评选"
tbActUiSetting.nShowLevel = tbAct.LEVEL_LIMIT
tbActUiSetting.nShowPriority = 2
tbAct.REFRESH_SIGNUP_FRIEND_INTERVAL = 30
tbAct.tbLocalWinnerAward = {
  [1] = {
    {
      "Item",
      4872,
      1
    },
    {
      "Item",
      4838,
      2
    },
    {
      "Item",
      4863,
      1
    },
    {
      "Item",
      4822,
      1
    },
    {
      "Item",
      4830,
      1
    },
    {
      "Item",
      4846,
      1
    },
    {
      "Item",
      4842,
      1
    },
    {
      "Item",
      4832,
      1
    },
    {
      "Item",
      4856,
      1
    },
    {
      "Item",
      4852,
      1
    }
  },
  [2] = {
    {
      "Item",
      4838,
      1
    },
    {
      "Item",
      4823,
      1
    },
    {
      "Item",
      4847,
      1
    },
    {
      "Item",
      4843,
      1
    },
    {
      "Item",
      4832,
      1
    },
    {
      "Item",
      4853,
      1
    }
  }
}
tbAct.tbFinalWinnerAward = {
  [1] = {
    {
      "Item",
      4839,
      1
    },
    {
      "Item",
      4837,
      2
    },
    {
      "Item",
      4869,
      1
    },
    {
      "Item",
      4821,
      1
    },
    {
      "Item",
      4828,
      1
    },
    {
      "Item",
      4844,
      1
    },
    {
      "Item",
      4840,
      1
    },
    {
      "Item",
      4831,
      1
    },
    {
      "Item",
      4858,
      1
    },
    {
      "Item",
      4855,
      1
    }
  },
  [2] = {
    {
      "Item",
      4837,
      1
    },
    {
      "Item",
      4864,
      1
    },
    {
      "Item",
      4821,
      1
    },
    {
      "Item",
      4829,
      1
    },
    {
      "Item",
      4845,
      1
    },
    {
      "Item",
      4841,
      1
    },
    {
      "Item",
      4831,
      1
    },
    {
      "Item",
      4857,
      1
    },
    {
      "Item",
      4870,
      1
    }
  }
}
tbAct.tbParticipateAward = {
  {
    "Item",
    4848,
    1
  },
  {
    "Item",
    4824,
    1
  },
  {
    "Item",
    4854,
    1
  },
  {"Energy", 15000}
}
tbAct.tbFinalParticipateAward = {
  {
    "Item",
    4838,
    1
  },
  {
    "Item",
    4820,
    1
  },
  {
    "Item",
    5252,
    1
  },
  {
    "Item",
    5253,
    1
  },
  {"Energy", 30000},
  {
    "Item",
    5255,
    1
  },
  {
    "Item",
    5254,
    1
  }
}
function tbAct:OnLogout()
  self.nSignUpTimeOut = 0
  self.nLastSyncSignUpFriend = 0
  self.tbSignUpFriendList = {}
end
function tbAct:IsShowMainButton()
  if not self:IsInProcess() then
    return false
  end
  if not me or me.nLevel < self.LEVEL_LIMIT then
    return false
  end
  return true
end
function tbAct:RequestSignUpFriend()
  local nNow = GetTime()
  self.nLastSyncSignUpFriend = self.nLastSyncSignUpFriend or 0
  if nNow - self.nLastSyncSignUpFriend >= self.REFRESH_SIGNUP_FRIEND_INTERVAL then
    self.nLastSyncSignUpFriend = nNow
    RemoteServer.BeautyPageantSignUpFriendReq()
  end
end
function tbAct:SyncIsSignUp(nSignUpTimeOut)
  self.nSignUpTimeOut = nSignUpTimeOut
end
function tbAct:SyncSignUpFriendList(tbList)
  self.tbSignUpFriendList = {}
  for _, nPlayerId in ipairs(tbList) do
    self.tbSignUpFriendList[nPlayerId] = 1
  end
  UiNotify.OnNotify(UiNotify.emNOTIFY_BEAUTY_FRIEND_LIST)
end
function tbAct:GetSignUpFriendList()
  return self.tbSignUpFriendList or {}
end
function tbAct:IsSignUp()
  return self.nSignUpTimeOut and GetTime() < self.nSignUpTimeOut
end
function tbAct:SendMsg(nType, nParam)
  local nChannelType = nParam
  if nType == tbAct.MSG_CHANNEL_TYPE.PRIVATE then
    nChannelType = ChatMgr.ChannelType.Private
    if FriendShip:IsHeInMyBlack(nParam) then
      me.CenterMsg("对方在您的黑名单中")
      return
    end
  end
  if not ChatMgr:CheckSendMsg(nChannelType, "1", false) then
    return false
  end
  if nType == tbAct.MSG_CHANNEL_TYPE.PRIVATE then
    local szMsg, tbLinkData = self:GetSendMsg(me)
    ChatMgr:CachePrivateMsg(nParam, szMsg, tbLinkData)
  end
  RemoteServer.SendBeautyPageantChannelMsg(nType, nParam)
end
function tbAct:CheckPlayerData(pPlayer)
end
function tbAct:SyncFurnitureAwardFrame(szFrame)
  self.szFurnitureAwardFrame = szFrame
end
function tbAct:GetFurnitureAwardFrame()
  return self.szFurnitureAwardFrame
end
function tbAct:OnRefreshVotedAward()
  local bHaveAward = NewInformation.tbCustomCheckRP.fnBeautyRewardCheckRp()
  if bHaveAward then
    Activity:CheckRedPoint()
    NewInformation:CheckRedPoint()
  end
  UiNotify.OnNotify(UiNotify.emNOTIFY_BEAUTY_VOTE_AWARD, UiNotify.emNOTIFY_BEAUTY_VOTE_AWARD, bHaveAward)
end
function tbAct:OpenSignUpPage()
  Ui.HyperTextHandle:Handle(string.format("[url=openBeautyUrl:SignUp, %s][-]", self.szSignUpUrl))
end
function tbAct:OpenMainPage()
  Ui.HyperTextHandle:Handle(string.format("[url=openBeautyUrl:MainPage, %s][-]", self.szMainEntryUrl))
end
function tbAct:OnSynMiniMainMapInfo()
  local tbMapTextPosInfo = Map:GetMapTextPosInfo(me.nMapTemplateId)
  for i, v in ipairs(tbMapTextPosInfo) do
    if v.Index == "BeautyPageant_diaoxiang" then
      v.Text = "选美冠军"
    end
  end
end
