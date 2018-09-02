local tbUi = Ui:CreateClass("HomeScreenFuben")
tbUi.nGuideLen = 200
tbUi.tbGuideCenterPos = {x = -568, y = 0}
function tbUi:OnOpen(szType, tbFubenInfo)
  self:Update(0, 0)
  self:Clear()
  self.pPanel:Label_SetText("FubenLastTime", "--")
  self.pPanel:SetActive("FubenLastTime", true)
  self.pPanel:SetActive("Infos", true)
  self.szType = szType or "normal"
  self.nGuideRangenRadius = 100
  if self.szType == "KinNest" then
  elseif self.szType == "DungeonFuben" then
    self:SetFubenProgress(nil, tbFubenInfo.szName)
    Fuben:SetEndTime(tbFubenInfo.nEndTime)
    self:SetEndTime(tbFubenInfo.nEndTime)
    if tbFubenInfo.bOwner then
      self.pPanel:SetActive("BtnInvite", true)
      self.BtnInvite.pPanel:SetActive("tuoguan", true)
    end
  elseif self.szType == "WhiteTigerFuben" then
    self.pPanel:SetActive("ItemCoinSet", false)
    self.pPanel:SetActive("ItemCoinSet2", false)
    self.pPanel:SetActive("WhiteTigerFubenHelp", true)
    tbFubenInfo = tbFubenInfo or {0, false}
    local nTime = tbFubenInfo[1] or 0
    local bShowLeave = tbFubenInfo[2] or false
    self.pPanel:SetActive("FubenLastTime", nTime > 0)
    self.pPanel:SetActive("Sprite", nTime > 0)
    self.pPanel:SetActive("BtnLeaveFuben", bShowLeave)
    if nTime > 0 then
      if tbFubenInfo[3] then
        self:SetEndTime(nTime)
      else
        self:SetEndTime(nTime + GetTime())
      end
    end
  elseif self.szType == "TeamFuben" or self.szType == "RandomFuben" then
    self.pPanel:SetActive("ItemCoinSet", false)
  elseif self.szType == "KinTrain" then
    self.pPanel:SetActive("ItemCoinSet", false)
  elseif self.szType == "XinShouFuben" then
    self.pPanel:SetActive("Infos", false)
    self.pPanel:SetActive("Direction", true)
  elseif self.szType == "normal" then
    self.pPanel:SetActive("ItemCoinSet", false)
  elseif self.szType == "SeriesFuben" then
    self.pPanel:SetActive("BtnLeaveFuben", false)
  elseif self.szType == "ArborDayCureAct" then
    self.pPanel:SetActive("FubenLastTime", false)
    self.pPanel:SetActive("BtnLeaveFuben", true)
  elseif self.szType == "WeddingFuben" then
    self.pPanel:SetActive("ItemCoinSet", false)
    self.pPanel:SetActive("Marry", true)
    self.pPanel:SetActive("BtnInvitation", false)
    self.pPanel:SetActive("BtnCash", true)
    self.pPanel:SetActive("BtnCamera", true)
    self.pPanel:SetActive("BtnBlessing", true)
    self.pPanel:SetActive("BtnCandy", false)
    self.pPanel:SetActive("BtnBag", true)
  elseif self.szType == "WeddingFubenRole" then
    self.pPanel:SetActive("ItemCoinSet", false)
    self.pPanel:SetActive("Marry", true)
    self.pPanel:SetActive("BtnInvitation", true)
    self.pPanel:SetActive("BtnCash", true)
    self.pPanel:SetActive("BtnCamera", true)
    self.pPanel:SetActive("BtnBlessing", false)
    self.pPanel:SetActive("BtnCandy", false)
    self.pPanel:SetActive("BtnBag", true)
  elseif self.szType == "WeddingTour" then
    self.pPanel:SetActive("FubenLastTime", false)
    self.pPanel:SetActive("ItemCoinSet", false)
    self.pPanel:SetActive("Sprite", false)
    self.pPanel:SetActive("Marry", true)
    self.pPanel:SetActive("BtnInvitation", false)
    self.pPanel:SetActive("BtnCash", false)
    self.pPanel:SetActive("BtnCamera", false)
    self.pPanel:SetActive("BtnCandy", false)
    self.pPanel:SetActive("BtnBlessing", false)
  else
    self.pPanel:SetActive("ItemCoinSet", true)
  end
  if self.nGuideX and not self.nGuideTimerId then
    self:UpdateGuide()
  end
  if self.szType == "normal" or self.szType == "DungeonFuben" or self.szType == "KinNest" then
    self.pPanel:SetActive("BtnLeaveFuben", true)
  end
  self.bOpen = true
  self:OnFubenTargetChange()
end
function tbUi:Clear()
  self.pPanel:SetActive("BtnLeaveFuben", false)
  self.pPanel:SetActive("Direction", false)
  self.pPanel:SetActive("ScroePanel", false)
  self.pPanel:SetActive("Persent", false)
  self.pPanel:SetActive("TargetInfo", false)
  self.pPanel:SetActive("ItemCoinSet", false)
  self.pPanel:SetActive("ItemCoinSet2", false)
  self.pPanel:SetActive("BtnInvite", false)
  self.pPanel:SetActive("WhiteTigerFubenHelp", false)
  self.pPanel:SetActive("Marry", false)
  self.pPanel:SetActive("BtnBag", false)
end
function tbUi:ShowLeave()
  self.pPanel:SetActive("BtnLeaveFuben", true)
end
function tbUi:Update(nItemCount, nCoinCount)
  self.pPanel:Label_SetText("ItemCount", nItemCount)
  self.pPanel:Label_SetText("CoinCount", nCoinCount)
end
function tbUi:SetEndTime(nEndTime, szTimeTitle)
  self.nEndTime = nEndTime
  if self.nTimerId then
    Timer:Close(self.nTimerId)
  end
  self.pPanel:SetActive("FubenLastTime", true)
  self.pPanel:SetActive("Sprite", true)
  self.nTimerId = Timer:Register(Env.GAME_FPS, function()
    local nLastTime = nEndTime - GetTime()
    if nLastTime < 0 then
      if self.szType == "WhiteTigerFuben" then
        self.pPanel:SetActive("FubenLastTime", false)
        self.pPanel:SetActive("Sprite", false)
      else
        self.pPanel:Label_SetText("FubenLastTime", "00:00")
      end
      self.nTimerId = nil
      return
    end
    self.pPanel:Label_SetText("FubenLastTime", self:GetLastTimeStr(nLastTime, szTimeTitle))
    return true
  end)
end
function tbUi:GetLastTimeStr(nLastTime, szTimeTitle)
  if self.szType == "KinNest" then
    return Lib:TimeDesc3(nLastTime)
  end
  return string.format("%s%02d:%02d", szTimeTitle or "", math.floor(nLastTime / 60), nLastTime % 60)
end
function tbUi:StopEndTime()
  if self.nTimerId then
    Timer:Close(self.nTimerId)
    self.nTimerId = nil
  end
end
function tbUi:SetTargetInfo(szTargetInfo, nEndTime)
  if szTargetInfo == "" then
    self.pPanel:SetActive("TargetInfo", false)
    return
  end
  self.pPanel:SetActive("TargetInfo", true)
  self.nTargetEndTime = nEndTime
  if self.nTargetTimerId then
    Timer:Close(self.nTargetTimerId)
    self.nTargetTimerId = nil
  end
  nEndTime = nEndTime or GetTime()
  local nLastTime = math.max(nEndTime - GetTime(), 0)
  self.pPanel:Label_SetText("TargetInfo", string.format(szTargetInfo, string.format("%02d:%02d", math.floor(nLastTime / 60), nLastTime % 60)))
  self.nTargetTimerId = Timer:Register(Env.GAME_FPS, function()
    local nCurLastTime = math.max(nEndTime - GetTime(), 0)
    local szInfo = string.format(szTargetInfo, string.format("%02d:%02d", math.floor(nCurLastTime / 60), nCurLastTime % 60))
    self.pPanel:Label_SetText("TargetInfo", szInfo)
    if nCurLastTime <= 0 then
      self.nTargetTimerId = nil
      return false
    end
    return true
  end)
end
function tbUi:UpdateGuide()
  local isAlreadyHaveGuide = self.pPanel:IsActive("Direction")
  self.nGuideTimerId = nil
  if not (self.nGuideX and self.nGuideY) or self.nGuideX == 0 or self.nGuideY == 0 then
    self:CloseGuide()
    return
  end
  local _, nX, nY = me:GetWorldPos()
  local nGuideRangenRadius = self.nGuideRangenRadius or 100
  if nGuideRangenRadius > math.abs(nX - self.nGuideX) and nGuideRangenRadius > math.abs(nY - self.nGuideY) then
    self:CloseGuide()
    return
  end
  if not Ui.CameraMgr.s_CurSceneCamera then
    self.nGuideTimerId = Timer:Register(5, self.UpdateGuide, self)
    return
  end
  local tbPos = Ui.CameraMgr.GetScreenDirection(self.nGuideX, self.nGuideY)
  if not tbPos or tbPos.x == tbPos.y and tbPos.x == 0 then
    self.pPanel:SetActive("Direction", false)
    return
  end
  local nPosLen = math.sqrt(tbPos.x * tbPos.x + tbPos.y * tbPos.y)
  local nPosX = tbPos.x * self.nGuideLen / nPosLen
  local nPosY = tbPos.y * self.nGuideLen / nPosLen
  if isAlreadyHaveGuide then
    self.pPanel:Tween_Run("Direction", self.tbGuideCenterPos.x + nPosX, self.tbGuideCenterPos.y + nPosY, 0.5)
  else
    self.pPanel:ChangePosition("Direction", self.tbGuideCenterPos.x + nPosX, self.tbGuideCenterPos.y + nPosY)
    self.pPanel:Tween_SetPos("Direction")
  end
  local nAngle = 0
  if nPosX == 0 then
    nAngle = nPosX >= 0 and 179.9 or 0
  elseif nPosX > 0 then
    nAngle = math.deg(math.atan(nPosY / nPosX))
    nAngle = nAngle + 90
  else
    nAngle = 270 + math.deg(math.atan(nPosY / nPosX))
  end
  if isAlreadyHaveGuide then
    self.pPanel:Tween_Rotate("Guide", nAngle, 0.5)
  else
    self.pPanel:ChangeRotate("Guide", nAngle)
    self.pPanel:Tween_SetRotate("Guide")
  end
  if not isAlreadyHaveGuide then
    self.pPanel:SetActive("Direction", true)
    self.pPanel:Tween_AlphaWithStart("Direction", 0, 1, 0.5)
  end
  self.nGuideTimerId = Timer:Register(5, self.UpdateGuide, self)
end
function tbUi:CloseGuide()
  self.nGuideX = nil
  self.nGuideY = nil
  self.pPanel:SetActive("Direction", false)
  me.tbFubenInfo = me.tbFubenInfo or {}
  me.tbFubenInfo.tbTargetPos = {}
end
function tbUi:SetGuidePos(nX, nY)
  self.nGuideX = nX
  self.nGuideY = nY
  if Ui:WindowVisible("HomeScreenFuben") ~= 1 and not self.bOpen then
    return
  end
  if not self.nGuideTimerId then
    self:UpdateGuide()
  end
end
function tbUi:GetGuidePos()
  return self.nGuideX, self.nGuideY
end
function tbUi:SetScroe(nScroe)
  self.pPanel:SetActive("ScroePanel", true)
  self.pPanel:Label_SetText("Scroe", nScroe)
end
function tbUi:SetFubenProgress(nPersent, szInfo)
  if szInfo then
    self:SetTargetInfo(szInfo)
  end
  if nPersent and nPersent >= 0 then
    self.pPanel:SetActive("Persent", true)
    self.pPanel:Label_SetText("Persent", string.format("（%s%%）", nPersent))
  else
    self.pPanel:SetActive("Persent", false)
  end
end
function tbUi:OnClose()
  self.bOpen = false
  self.nEndTime = 0
  if self.nGuideTimerId then
    Timer:Close(self.nGuideTimerId)
    self.nGuideTimerId = nil
  end
  if self.nTimerId then
    Timer:Close(self.nTimerId)
    self.nTimerId = nil
  end
  if self.nTargetTimerId then
    Timer:Close(self.nTargetTimerId)
    self.nTargetTimerId = nil
  end
  self:CloseGuide()
end
local LEAVE_MSG = {
  WhiteTigerFuben = "确定要离开白虎堂？",
  WeddingFuben = "是否要离开婚礼现场"
}
function tbUi:LeaveFuben(bConfirm)
  if not bConfirm then
    local szMsg = LEAVE_MSG[self.szType] or "确认要离开副本？"
    Ui:OpenWindow("MessageBox", szMsg, {
      {
        self.LeaveFuben,
        self,
        true
      },
      {}
    }, {"离开", "取消"})
    return
  end
  if IsAlone() == 1 then
    PersonalFuben:DoLeaveFuben()
  else
    RemoteServer.LeaveFuben(false)
  end
end
function tbUi:HideInviteButton()
  self.pPanel:SetActive("BtnInvite", false)
end
function tbUi:OnFubenTargetChange()
  me.tbFubenInfo = me.tbFubenInfo or {}
  me.tbFubenInfo.tbTargetPos = me.tbFubenInfo.tbTargetPos or {0, 0}
  local nX, nY = unpack(me.tbFubenInfo.tbTargetPos)
  if nX and nX > 0 and nY and nY > 0 then
    self:SetGuidePos(nX, nY)
  else
    self:CloseGuide()
  end
  me.tbFubenInfo.tbTargetInfo = me.tbFubenInfo.tbTargetInfo or {}
  local szInfo, nEndTime = unpack(me.tbFubenInfo.tbTargetInfo)
  if szInfo then
    self:SetTargetInfo(szInfo, nEndTime)
    me.tbFubenInfo.tbTargetInfo = nil
  end
  me.tbFubenInfo.tbProgress = me.tbFubenInfo.tbProgress or {}
  local nProgress, szProgressInfo = unpack(me.tbFubenInfo.tbProgress)
  if nProgress then
    self:SetFubenProgress(nProgress, szProgressInfo)
    me.tbFubenInfo.tbProgress = nil
  end
  if me.tbFubenInfo.nScore and 0 < me.tbFubenInfo.nScore then
    self:SetScroe(me.tbFubenInfo.nScore)
    me.tbFubenInfo.nScore = nil
  end
  if me.tbFubenInfo.nEndTime and 0 < me.tbFubenInfo.nEndTime then
    self:SetEndTime(me.tbFubenInfo.nEndTime, me.tbFubenInfo.szTimeTitle)
    me.tbFubenInfo.nEndTime = nil
    me.tbFubenInfo.szTimeTitle = nil
  end
  me.tbFubenInfo.tbShowInfo = me.tbFubenInfo.tbShowInfo or {}
  local nItemCount, nCoinCount = unpack(me.tbFubenInfo.tbShowInfo)
  if nItemCount then
    self:Update(nItemCount, nCoinCount)
    me.tbFubenInfo.tbShowInfo = nil
  end
  if me.tbFubenInfo.bCanLeave then
    self:ShowLeave()
    me.tbFubenInfo.bCanLeave = nil
  end
end
function tbUi:OnTeamUpdate(szType)
  if szType == "MemberChanged" and self.pPanel:IsActive("BtnInvite") then
    if #TeamMgr:GetTeamMember() >= TeamMgr.MAX_MEMBER_COUNT then
      self.BtnInvite.pPanel:SetActive("tuoguan", false)
    else
      self.BtnInvite.pPanel:SetActive("tuoguan", true)
    end
  end
end
function tbUi:PlayTargetChange()
  if self.szType == "RandomFuben" then
    return
  end
  self.pPanel:SetActive("zhangjieshuaxin", true)
  Timer:Register(Env.GAME_FPS * 0.7, function()
    self.pPanel:SetActive("zhangjieshuaxin", false)
  end)
end
function tbUi:ChangeGuideRange(nRadius)
  self.nGuideRangenRadius = nRadius or 100
end
function tbUi:OnFubenTargetClose()
  self.pPanel:SetActive("BtnLeaveFuben", false)
  me.tbFubenInfo = me.tbFubenInfo or {}
  me.tbFubenInfo.bCanLeave = nil
end
function tbUi:CheckBagRedPoint()
  local tbTopUi = Ui:GetClass("TopButton")
  if tbTopUi then
    tbTopUi:CheckHasCanEquipItem(1)
  end
end
function tbUi:SetWeddingBtnActive(szBtnName, bActive)
  self.pPanel:SetActive(szBtnName, bActive)
end
function tbUi:RegisterEvent()
  local tbRegEvent = {
    {
      UiNotify.emNOTIFY_FUBEN_TARGET_CHANGE,
      self.OnFubenTargetChange,
      self
    },
    {
      UiNotify.emNOTIFY_TEAM_UPDATE,
      self.OnTeamUpdate,
      self
    },
    {
      UiNotify.emNOTIFY_FUBEN_STOP_ENDTIME,
      self.StopEndTime,
      self
    },
    {
      UiNotify.emNoTIFY_FUBEN_PROGRESS_REFRESH,
      self.PlayTargetChange,
      self
    },
    {
      UiNotify.emNOTIFY_GUIDE_RANGE_CHANGE,
      self.ChangeGuideRange,
      self
    },
    {
      UiNotify.emNOTIFY_FUBEN_TARGET_CHANGE_CLOSE,
      self.OnFubenTargetClose,
      self
    },
    {
      UiNotify.emNOTIFY_SYNC_ITEM,
      self.CheckBagRedPoint
    },
    {
      UiNotify.emNOTIFY_DEL_ITEM,
      self.CheckBagRedPoint
    },
    {
      UiNotify.emNOTIFY_FUBEN_TARGET_CHANGE_WEDDING_BTN,
      self.SetWeddingBtnActive
    }
  }
  return tbRegEvent
end
tbUi.tbOnClick = {}
function tbUi.tbOnClick:BtnLeaveFuben()
  self:LeaveFuben()
end
function tbUi.tbOnClick:BtnInvite()
  Ui:OpenWindow("DungeonInviteList")
end
function tbUi.tbOnClick:BtnGo()
  if not self.nGuideX or not self.nGuideY then
    return
  end
  AutoPath:GotoAndCall(me.nMapId, self.nGuideX, self.nGuideY)
end
function tbUi.tbOnClick:BtnCash()
  RemoteServer.OnWeddingRequest("TryOpenCashPanel")
end
function tbUi.tbOnClick:BtnInvitation()
  Ui:OpenWindow("WeddingWelcomeApplyPanel")
end
function tbUi.tbOnClick:BtnCamera()
  Ui:OpenWindowAtPos("HouseCameraPanel", 433, 130, true)
end
function tbUi.tbOnClick:BtnCandy()
  RemoteServer.OnWeddingRequest("TrySendCandy")
end
function tbUi.tbOnClick:BtnBlessing()
  Ui:OpenWindow("WeddingBlessingPanel")
end
function tbUi.tbOnClick.BtnBag()
  Ui:OpenWindow("ItemBox")
end
