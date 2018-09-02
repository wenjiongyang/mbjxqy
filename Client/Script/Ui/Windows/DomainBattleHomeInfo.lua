local tbUi = Ui:CreateClass("DomainBattleHomeInfo")
tbUi.nShowComboTime = 3
function tbUi:OnOpen(nState, nTimeFrame)
  self:SetEndTime(nState or 1, nTimeFrame)
  self:UpdateApplyData()
  self:PlayComboAni(0)
end
function tbUi:ClickItem(nTemplateId)
  DomainBattle:UseBattleSupplys(nTemplateId)
end
function tbUi:UpdateComboNum(nCombo)
  if nCombo > 999 then
    nCombo = 999
  end
  self.pPanel:SetActive("Lianzhan", true)
  local nHun = math.floor(nCombo / 100)
  local nTen = math.floor((nCombo - 100 * nHun) / 10)
  local nSingle = nCombo - 100 * nHun - 10 * nTen
  if nHun > 0 then
    self.pPanel:SetActive("SpHundred", true)
    self.pPanel:Sprite_SetSprite("SpHundred", string.format("Deadly_Hurt_%d_a", nHun))
  else
    self.pPanel:SetActive("SpHundred", false)
  end
  if nTen > 0 or nHun > 0 then
    self.pPanel:SetActive("SpTen", true)
    self.pPanel:Sprite_SetSprite("SpTen", string.format("Deadly_Hurt_%d_a", nTen))
  else
    self.pPanel:SetActive("SpTen", false)
  end
  self.pPanel:Sprite_SetSprite("SpSingle", string.format("Deadly_Hurt_%d_a", nSingle))
end
function tbUi:CloseLianZhen()
  self.pPanel:SetActive("Lianzhan", false)
  self.nComboTimer = nil
end
function tbUi:PlayComboAni(nCombo, nShowTime)
  self:CloseComboTimer()
  if nCombo == 0 then
    self.pPanel:SetActive("Lianzhan", false)
    return
  end
  if nShowTime then
    self.nComboTimer = Timer:Register(nShowTime * Env.GAME_FPS, self.CloseLianZhen, self)
  end
  self:UpdateComboNum(nCombo)
  self.pPanel:SetActive("Lianzhan", false)
  self.pPanel:SetActive("Lianzhan", true)
  self.pPanel:Play_Animator("Lianzhan", "lianzhan_gou1")
end
function tbUi:SetEndTime(nState, nSynEndTime)
  local tbState = DomainBattle.STATE_TRANS[nState]
  if not tbState then
    return
  end
  self.nState = nState
  DomainBattle.tbFightData.nState = nState
  DomainBattle:SetClientLeftTime(nSynEndTime or tbState.nSeconds)
  if self.nTimerId then
    Timer:Close(self.nTimerId)
    self.nTimerId = nil
  end
  self.pPanel:Label_SetText("InfoTxt", tbState.szDesc)
  local nEndTime = DomainBattle:GetClientLeftTime()
  self.pPanel:Label_SetText("LastTime", string.format("%02d:%02d", math.floor(nEndTime / 60), nEndTime % 60))
  self.nTimerId = Timer:Register(Env.GAME_FPS, self.ShowTime, self)
end
function tbUi:ShowTime()
  DomainBattle:SetClientLeftTime(nil, -1)
  local nEndTime = DomainBattle:GetClientLeftTime()
  if nEndTime <= 0 then
    self.pPanel:Label_SetText("LastTime", "00:00")
    self.nTimerId = nil
    self:SetEndTime(self.nState + 1)
    return
  end
  self.pPanel:Label_SetText("LastTime", string.format("%02d:%02d", math.floor(nEndTime / 60), nEndTime % 60))
  return true
end
function tbUi:OnClose()
  if self.nTimerId then
    Timer:Close(self.nTimerId)
    self.nTimerId = nil
  end
  self:CloseComboTimer()
end
function tbUi:CloseComboTimer()
  if self.nComboTimer then
    Timer:Close(self.nComboTimer)
    self.nComboTimer = nil
  end
end
function tbUi:OnLeave(nTemplateID)
  if DomainBattle:GetMapLevel(nTemplateID) then
    Ui:CloseWindow(self.UI_NAME)
    return
  end
end
function tbUi:UpdateApplyData()
  local tbBattleSupply = DomainBattle:GetCanUseBattleSupplys()
  for i, nTemplateId in ipairs(DomainBattle.define.tbBattleApplyIdOrder) do
    local itemGrid = self["itemframe" .. i]
    if tbBattleSupply then
      local nNum = tbBattleSupply[nTemplateId] or 0
      local tbControls = {}
      if nNum == 0 then
        tbControls.bShowCDLayer = true
      end
      itemGrid:SetItemByTemplate(nTemplateId, nNum, nil, tbControls)
      function itemGrid.fnClick(itemObj)
        self:ClickItem(nTemplateId)
      end
      local tbItem = KItem.GetItemBaseProp(nTemplateId)
      self.pPanel:Label_SetText("ItemName" .. i, tbItem.szName)
      itemGrid.pPanel:SetActive("Main", true)
      self.pPanel:SetActive("ItemName" .. i, true)
    else
      itemGrid.pPanel:SetActive("Main", false)
      self.pPanel:SetActive("ItemName" .. i, false)
    end
  end
end
function tbUi:OnSynKinData(szType)
  if szType ~= "MemberCareer" then
    return
  end
  self:UpdateApplyData()
end
tbUi.tbOnClick = {}
function tbUi.tbOnClick:BtnBattleReport()
  Ui:OpenWindow("DomainBattleReport")
end
function tbUi.tbOnClick:BtnLeave()
  local fnYes = function()
    RemoteServer.DomainBattleLeave()
  end
  if me.nFightMode == 0 then
    Ui:OpenWindow("MessageBox", "您确定要离开攻城战吗", {
      {fnYes},
      {}
    }, {"确认", "取消"})
  else
    fnYes()
  end
end
function tbUi:RegisterEvent()
  return {
    {
      UiNotify.emNOTIFY_MAP_LEAVE,
      self.OnLeave
    },
    {
      UiNotify.emNOTIFY_ONSYNC_DOMAIN_SUPPLY,
      self.UpdateApplyData
    },
    {
      UiNotify.emNOTIFY_SYNC_KIN_DATA,
      self.OnSynKinData
    }
  }
end
