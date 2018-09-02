local tbUi = Ui:CreateClass("DreamlandPanel")
function tbUi:OnOpen(tbFactions)
  local nState = InDifferBattle.nState
  if nState ~= 1 then
    return 0
  end
  self.tbFactions = tbFactions
  self:UpdateMain()
  self.nTimer = Timer:Register(Env.GAME_FPS, self.TimerUpdate, self)
end
function tbUi:OnOpenEnd()
  Ui:OpenWindow("ChatLargePanel", ChatMgr.ChannelType.Team)
end
function tbUi:TimerUpdate()
  self.pPanel:Label_SetText("TitleTxt", (InDifferBattle.tbChoosedFactions[me.dwID] ~= 0 and "等待活动开始：" or "请选择你在幻境中的门派：") .. InDifferBattle.nLeftTime)
  if InDifferBattle.nState ~= 1 then
    Ui:CloseWindow(self.UI_NAME)
  end
  return true
end
function tbUi:UpdateMain()
  local tbChoosedFaction = InDifferBattle.tbChoosedFactions
  local tbChoosedFactionRevert = {}
  local tbMembers = TeamMgr:GetTeamMember()
  local tbRoleIdKeyVal = {}
  for i, v in ipairs(tbMembers) do
    tbRoleIdKeyVal[v.nPlayerID] = v
  end
  tbRoleIdKeyVal[me.dwID] = {
    szName = me.szName
  }
  for dwRoleId, nFaction in pairs(tbChoosedFaction) do
    if nFaction ~= 0 then
      tbChoosedFactionRevert[nFaction] = dwRoleId
    end
  end
  for i, nFaction in ipairs(self.tbFactions) do
    local v = Faction.tbFactionInfo[nFaction]
    local _, _, szPrefixStr = string.find(v.szBigIcon, "^(.*)%d%d$")
    local dwChoosedRoleId = tbChoosedFactionRevert[nFaction]
    if dwChoosedRoleId then
      self.pPanel:Button_SetSprite("Faction" .. i, szPrefixStr .. "02")
      local tbMenmberInfo = tbRoleIdKeyVal[dwChoosedRoleId]
      self.pPanel:Label_SetText("Name" .. i, string.format("[%s]%s[-]", dwChoosedRoleId == me.dwID and "c8ff00" or "92D2FF", tbMenmberInfo.szName))
    else
      self.pPanel:Button_SetSprite("Faction" .. i, szPrefixStr .. "01")
      self.pPanel:Label_SetText("Name" .. i, "")
    end
  end
end
function tbUi:SelFaction(nIndex)
  local nFaction = self.tbFactions[nIndex]
  if InDifferBattle.nState ~= 1 then
    me.CenterMsg("当前阶段已不可选择")
    return
  end
  if InDifferBattle.tbChoosedFactions[me.dwID] == nFaction then
    return
  end
  for k, v in pairs(InDifferBattle.tbChoosedFactions) do
    if v == nFaction then
      me.CenterMsg("该门派已被其他队员选择")
      return
    end
  end
  RemoteServer.InDifferBattleRequestInst("ChooseFaction", nFaction)
end
function tbUi:OnClose()
  if self.nTimer then
    Timer:Close(self.nTimer)
    self.nTimer = nil
  end
end
tbUi.tbOnClick = {}
for i = 1, 6 do
  tbUi.tbOnClick["Faction" .. i] = function(self)
    self:SelFaction(i)
  end
end
function tbUi.tbOnClick:Bg()
  if Ui:WindowVisible("ChatLargePanel") then
    return
  end
  Ui:OpenWindow("ChatLargePanel", ChatMgr.ChannelType.Team)
end
function tbUi:RegisterEvent()
  local tbRegEvent = {
    {
      UiNotify.emNOTIFY_INDIFFER_BATTLE_FACTION,
      self.UpdateMain
    }
  }
  return tbRegEvent
end
