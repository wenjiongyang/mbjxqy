local tbUi = Ui:CreateClass("BattleReport")
function tbUi:OnOpen()
  if not Battle.tbBattleRank then
    return 0
  end
  self:Update(Battle.tbBattleRank)
  if Battle.tbCurBattleSetting.tbAwardSetBig ~= "BattleAwardMonth" then
    self.pPanel:Label_SetText("BattlefieldHonor", "战场荣誉")
  else
    self.pPanel:Label_SetText("BattlefieldHonor", "元气")
  end
  self.pPanel:SetActive("BtnBack", false)
end
function tbUi:FindTargetItem()
  if not Battle.tbBattleRank then
    return
  end
  for i, v in ipairs(Battle.tbBattleRank) do
    if v.dwID == me.dwID then
      self.ScrollView.pPanel:ScrollViewGoToIndex("Main", i)
      return
    end
  end
end
function tbUi:OnOpenEnd()
  self:FindTargetItem()
end
function tbUi:OnCreate()
  local RepresentSetting = luanet.import_type("RepresentSetting")
  self.tbColorTop = {}
  self.tbColorBottom = {}
  self.tbColorOutline = {}
  table.insert(self.tbColorTop, RepresentSetting.CreateColor(0.7490196078431373, 0.9058823529411765, 1, 1))
  table.insert(self.tbColorTop, RepresentSetting.CreateColor(1, 0.9647058823529412, 0.47843137254901963, 1))
  table.insert(self.tbColorBottom, RepresentSetting.CreateColor(0, 0.7098039215686275, 1, 1))
  table.insert(self.tbColorBottom, RepresentSetting.CreateColor(1, 0.5568627450980392, 0, 1))
  table.insert(self.tbColorOutline, RepresentSetting.CreateColor(0, 0.24313725490196078, 0.5803921568627451, 1))
  table.insert(self.tbColorOutline, RepresentSetting.CreateColor(0.3254901960784314, 0.10196078431372549, 0, 1))
end
function tbUi:Update(tbBattleRank)
  local tbCurBattleSetting = Battle.tbCurBattleSetting
  local tbTeamNames = tbCurBattleSetting.tbTeamNames
  local tbMyInfo
  for i, v in ipairs(tbBattleRank) do
    if v.dwID == me.dwID then
      tbMyInfo = v
      break
    end
  end
  local bShowHonor = false
  local nCampVal = tbCurBattleSetting.tbCamVal[tbMyInfo.nTeamIndex]
  local szCampName = Npc.tbCampTypeName[nCampVal]
  if Battle.nWinTeam then
    if tbMyInfo.nTeamIndex == Battle.nWinTeam then
      self.pPanel:SetActive("Victory", true)
      self.pPanel:SetActive("Fail", false)
      self.pPanel:Label_SetText("VictoryTitle", string.format("本方(%s)获胜", szCampName))
    else
      self.pPanel:SetActive("Victory", false)
      self.pPanel:SetActive("Fail", true)
      self.pPanel:Label_SetText("FailTitle", string.format("本方(%s)惜败", szCampName))
    end
    if tbBattleRank[1] and tbBattleRank[1].nGetHonor then
      bShowHonor = true
    end
    self.pPanel:ChangePosition("content", 0, 0)
  else
    self.pPanel:ChangePosition("content", 0, 70)
    self.pPanel:SetActive("Victory", false)
    self.pPanel:SetActive("Fail", false)
  end
  self.pPanel:SetActive("BattlefieldHonor", bShowHonor)
  self.nShowScrollMax = 0
  local function tbSetLabelColor(pPanel, szLabel, nTeamIndex, szContent)
    pPanel:Label_SetText(szLabel, szContent)
    pPanel:Label_SetGradientByColor(szLabel, self.tbColorTop[nTeamIndex], self.tbColorBottom[nTeamIndex])
    pPanel:Label_SetOutlineColor(szLabel, self.tbColorOutline[nTeamIndex])
  end
  local function fnSetData(itemClass, index)
    if self.nShowScrollMax - index >= 10 then
      self.nShowScrollMax = index
    end
    self.nShowScrollMax = math.max(self.nShowScrollMax, index)
    if self.nShowScrollMax > 10 then
      self.pPanel:SetActive("BtnBack", true)
    else
      self.pPanel:SetActive("BtnBack", false)
    end
    local tbData = tbBattleRank[index]
    for i = 1, 3 do
      itemClass.pPanel:SetActive("NO" .. i, i == index)
    end
    if index <= 3 then
      itemClass.pPanel:SetActive("Rank", false)
    else
      itemClass.pPanel:SetActive("Rank", true)
      tbSetLabelColor(itemClass.pPanel, "Rank", tbData.nTeamIndex, index)
    end
    tbSetLabelColor(itemClass.pPanel, "CampName", tbData.nTeamIndex, tbTeamNames[tbData.nTeamIndex])
    tbSetLabelColor(itemClass.pPanel, "FactionName", tbData.nTeamIndex, Login.tbSelRoleInfo[tbData.nFaction].szFaction)
    tbSetLabelColor(itemClass.pPanel, "TxtScore", tbData.nTeamIndex, tbData.nScore)
    tbSetLabelColor(itemClass.pPanel, "TxtKill", tbData.nTeamIndex, tbData.nKillCount)
    tbSetLabelColor(itemClass.pPanel, "TxtCombo", tbData.nTeamIndex, tbData.nMaxCombo)
    tbSetLabelColor(itemClass.pPanel, "TxtName", tbData.nTeamIndex, tbData.szName)
    if bShowHonor then
      itemClass.pPanel:SetActive("TxtBattlefieldHonor", true)
      tbSetLabelColor(itemClass.pPanel, "TxtBattlefieldHonor", tbData.nTeamIndex, tbData.nGetHonor)
    else
      itemClass.pPanel:SetActive("TxtBattlefieldHonor", false)
    end
    itemClass.pPanel:Sprite_SetSprite("BattleListBar", tbData.dwID == me.dwID and "ListBgLight" or "ListBgDark")
  end
  self.ScrollView:Update(tbBattleRank, fnSetData)
end
tbUi.tbOnClick = {}
function tbUi.tbOnClick:BtnClose()
  Ui:CloseWindow(self.UI_NAME)
end
function tbUi.tbOnClick:BtnBack()
  self.ScrollView:GoTop()
end
function tbUi:OnScreenClick()
  Ui:CloseWindow(self.UI_NAME)
end
function tbUi:RegisterEvent()
  return {
    {
      UiNotify.emNOTIFY_SYNC_BATTLE_REPORT,
      self.Update
    }
  }
end
