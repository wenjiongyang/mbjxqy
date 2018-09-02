local RefinementPanel = Ui:CreateClass("RefinementPanel")
local fnClickTarAttrib = function(nIndex)
  local function fnRet(self)
    if self.tbForbitTar[nIndex] then
      return
    end
    if self.nTarPos == nIndex then
      self.nSrcPos = nil
      self.nTarPos = nil
      self.tbForbitTar = {}
    else
      self.nTarPos = nIndex
    end
    self:UpdateTargetPanel(false)
    self:UpdateSourcePanel(false)
    self:SetCheckState(true)
    self:CalcCost()
  end
  return fnRet
end
local fnClickSrcAttrib = function(nIndex)
  local function fnRet(self)
    if self.tbForbitSrc[nIndex] then
      return
    end
    if self.nSrcPos == nIndex then
      self.nSrcPos = nil
      self.nTarPos = nil
    else
      self.nSrcPos = nIndex
    end
    self.tbForbitTar = {}
    self:UpdateSourcePanel(false)
    self:UpdateTargetPanel(true)
    self:SetCheckState(false)
    self:CalcCost()
  end
  return fnRet
end
function RefinementPanel:SetCheckState(isTar)
  local szComName, nSelectIndex
  if isTar then
    szComName = "BtnAttrib"
    nSelectIndex = self.nTarPos
  else
    szComName = "BtnSrcAttrib"
    nSelectIndex = self.nSrcPos
  end
  for i = 1, 6 do
    local bSelect = i == nSelectIndex
    self[szComName .. i].pPanel:SetActive("CheckMark", bSelect)
    self[szComName .. i].pPanel:SetActive("Highlight", bSelect)
  end
end
RefinementPanel.tbOnClick = {
  BtnClose = function(self)
    self.bAllReturn = false
    if not self.tbRefinemRecord then
      Ui:CloseWindow(self.UI_NAME)
      return
    end
    local function fnYes()
      Item.GoldEquip:ClientPorcessUpgrade(self.tbRefinemRecord)
      Ui:CloseWindow(self.UI_NAME)
    end
    local function fnNo()
      Ui:CloseWindow(self.UI_NAME)
    end
    Ui:OpenWindow("MessageBox", string.format("确认消耗掉 %s 进行升阶吗", self.pSrcEquip.szName), {
      {fnYes},
      {fnNo}
    }, {"同意", "取消"})
  end,
  BtnOK = function(self)
    if not self:HaveEnoughMoney() then
      me.CenterMsg("银两不足")
      return
    end
    local nTarPos
    if self.tbTarAttribs[self.nTarPos] then
      nTarPos = self.nTarPos
    else
      nTarPos = nil
    end
    if not self.nSrcPos then
      me.CenterMsg("请选择洗练属性")
      return
    end
    if not self.nTarPos then
      me.CenterMsg("请选择被替换属性")
      return
    end
    if self.bRequest then
      me.CenterMsg("请等待洗练结果")
      return
    end
    local function fnYes()
      self.bRequest = true
      if self.tbRefinemRecord then
        local bRet, szMsg = Item.tbRefinement:FakeRefinement(me, self.pTarEquip, self.pSrcEquip, nTarPos, self.nSrcPos, self.tbRefinemRecord)
        Item.tbRefinement:OnRefinementResult(bRet, szMsg)
      else
        RemoteServer.OnRefinement(self.nTarEquipId, self.nSrcEquipId, nTarPos, self.nSrcPos)
      end
    end
    if nTarPos and self.tbTarAttribs[self.nTarPos].nAttribLevel > self.tbSrcAttribs[self.nSrcPos].nAttribLevel then
      Ui:OpenWindow("MessageBox", "确认将 [FFFE0D]高级属性[-] 替换为 [FFFE0D]低级属性[-] 吗？", {
        {fnYes},
        {}
      }, {"同意", "取消"})
    else
      fnYes()
    end
  end,
  HelpClicker = function(self)
    self:UpdateHelp()
  end
}
function RefinementPanel:OpenHelpClicker()
  if Guide.tbNotifyGuide:IsFinishGuide("RefineGuide") == 0 then
    self.nHelpStep = 0
    self:UpdateHelp()
    Guide.tbNotifyGuide:ClearNotifyGuide("RefineGuide", true)
  else
    self.pPanel:SetActive("RefineGuide", false)
  end
end
local _tbHelp = {
  {
    "HelpClicker",
    "GuideStep1"
  },
  {
    "HelpClicker",
    "GuideStep2"
  },
  {
    "HelpClicker",
    "GuideStep3"
  },
  {
    "HelpClicker",
    "GuideStep4"
  },
  {
    "HelpClicker",
    "GuideStep5"
  }
}
local tbHelp = {}
local tbAllHelpWnd = {}
for nSetpId, tbInfo in ipairs(_tbHelp) do
  tbHelp[nSetpId] = {}
  for _, szWnd in ipairs(tbInfo) do
    tbHelp[nSetpId][szWnd] = true
    tbAllHelpWnd[szWnd] = true
  end
end
function RefinementPanel:UpdateHelp()
  self.nHelpStep = self.nHelpStep + 1
  if tbHelp[self.nHelpStep] then
    for szWnd, _ in pairs(tbAllHelpWnd) do
      self.pPanel:SetActive(szWnd, tbHelp[self.nHelpStep][szWnd])
    end
  else
    for szWnd, _ in pairs(tbAllHelpWnd) do
      self.pPanel:SetActive(szWnd, false)
    end
  end
end
for i = 1, 6 do
  RefinementPanel.tbOnClick["BtnAttrib" .. i] = fnClickTarAttrib(i)
  RefinementPanel.tbOnClick["BtnSrcAttrib" .. i] = fnClickSrcAttrib(i)
end
function RefinementPanel:OnOpen(nSrcEquipId, nTarEquipId, tbRefinemRecord)
  self.bRequest = false
  self.tbRefinemRecord = tbRefinemRecord
  self.nSrcEquipId = nSrcEquipId
  self.nTarEquipId = nTarEquipId
  if not tbRefinemRecord then
    self.pSrcEquip = me.GetItemInBag(nSrcEquipId)
    self.pTarEquip = me.GetItemInBag(nTarEquipId)
  else
    self.pSrcEquip = Item:GetFakeItem(nSrcEquipId)
    self.pTarEquip = Item:GetFakeItem(nTarEquipId)
  end
  self:Update()
  self:OpenHelpClicker()
end
function RefinementPanel:Update()
  self.nSrcPos = nil
  self.nTarPos = nil
  self.tbForbitTar = {}
  self.tbForbitSrc = {}
  local tbControls = {bShowTip = false}
  local szNameSrc, szNameTar
  if self.tbRefinemRecord then
    self.ItemTar:SetItemByTemplate(self.pTarEquip.dwTemplateId, 1, nil, tbControls)
    self.ItemSrc:SetItemByTemplate(self.pSrcEquip.dwTemplateId, 1, nil, tbControls)
    szNameSrc = self.pSrcEquip.szName
    szNameTar = self.pTarEquip.szName
  else
    self.ItemTar:SetItem(self.pTarEquip.dwId, tbControls)
    self.ItemSrc:SetItem(self.pSrcEquip.dwId, tbControls)
    szNameSrc = self.pSrcEquip.GetItemShowInfo(me.nFaction)
    szNameTar = self.pTarEquip.GetItemShowInfo(me.nFaction)
  end
  local tbSrcAttribs = Item.tbRefinement:GetRandomAttrib(self.pSrcEquip)
  local tbTarAttribs = Item.tbRefinement:GetRandomAttrib(self.pTarEquip)
  self.tbSrcAttribs = tbSrcAttribs
  self.tbTarAttribs = tbTarAttribs
  self.pPanel:Label_SetText("TxtCoin", 0)
  self.pPanel:Label_SetText("TxtSrcEquipName", szNameSrc)
  self.pPanel:Label_SetText("TxtTarEquipName", szNameTar)
  self:UpdateSourcePanel()
  self:UpdateTargetPanel()
end
function RefinementPanel:UpdateSourcePanel(bAutoSelect)
  local bExistSame = false
  local szSameAttribName
  if self.nTarPos then
    local tbTarAttrib = self.tbTarAttribs[self.nTarPos]
    if tbTarAttrib then
      bExistSame = Item.tbRefinement:IsExistSameTypeAttrib(self.tbSrcAttribs, tbTarAttrib.szAttrib)
      szSameAttribName = tbTarAttrib.szAttrib
    end
  end
  if bAutoSelect then
    for i = 1, 6 do
      local tbSrcAttrib = self.tbSrcAttribs[i]
      if tbSrcAttrib and bExistSame and tbSrcAttrib.szAttrib == szSameAttribName then
        self.nSrcPos = i
      end
    end
  end
  for i = 1, 6 do
    local pPanelSrcAttrib = self["BtnSrcAttrib" .. i].pPanel
    local tbAttrib = self.tbSrcAttribs[i]
    if tbAttrib then
      pPanelSrcAttrib:SetActive("Main", true)
      self:UpdateAttrib(self.pTarEquip.nLevel, tbAttrib, "Source", i, self.pTarEquip.nItemType)
      local bCanSelelct = true
      for j = 1, 6 do
        local tbTarAttrib = self.tbTarAttribs[j]
        if tbTarAttrib and tbTarAttrib.szAttrib == tbAttrib.szAttrib then
          if tbAttrib.nAttribLevel <= tbTarAttrib.nAttribLevel then
            bCanSelelct = false
          end
          break
        end
      end
      pPanelSrcAttrib:SetActive("CheckBox", bCanSelelct)
      pPanelSrcAttrib:Button_SetEnabled("Main", bCanSelelct)
    else
      pPanelSrcAttrib:SetActive("Main", false)
    end
  end
  self:SetCheckState(false)
end
function RefinementPanel:UpdateTargetPanel(bAutoSelect)
  local bExistSame = false
  local szSameAttribName
  if self.nSrcPos then
    local tbSrcAttrib = self.tbSrcAttribs[self.nSrcPos]
    bExistSame = Item.tbRefinement:IsExistSameTypeAttrib(self.tbTarAttribs, tbSrcAttrib.szAttrib)
    szSameAttribName = tbSrcAttrib.szAttrib
  end
  if bAutoSelect then
    self.nTarPos = nil
    for i = 1, 6 do
      local tbTarAttrib = self.tbTarAttribs[i]
      if tbTarAttrib then
        if bExistSame and tbTarAttrib.szAttrib == szSameAttribName then
          self.nTarPos = i
          break
        end
      else
        self.nTarPos = i
        break
      end
    end
  end
  local nFullCount = Item.tbRefinement:GetAttribFullCount(self.pTarEquip.dwTemplateId)
  for i = 1, 6 do
    local tbTarAttrib = self.tbTarAttribs[i]
    if tbTarAttrib then
      self["BtnAttrib" .. i].pPanel:SetActive("Main", true)
      if bAutoSelect and bExistSame and tbTarAttrib.szAttrib ~= szSameAttribName then
        self.tbForbitTar[i] = true
        self["BtnAttrib" .. i].pPanel:SetActive("CheckBox", false)
      else
        self["BtnAttrib" .. i].pPanel:SetActive("CheckBox", true)
      end
    else
      if i > nFullCount then
        self["BtnAttrib" .. i].pPanel:SetActive("Main", false)
      else
        self["BtnAttrib" .. i].pPanel:SetActive("CheckBox", not bExistSame)
        self["BtnAttrib" .. i].pPanel:SetActive("CheckBox", not bExistSame)
      end
      if bAutoSelect and bExistSame then
        self.tbForbitTar[i] = true
      end
    end
    self:UpdateAttrib(self.pTarEquip.nLevel, tbTarAttrib, "Target", i, self.pTarEquip.nItemType)
  end
  self:SetCheckState(true)
  self:CalcCost()
end
function RefinementPanel:UpdateAttrib(nEquipLevel, tbAttrib, szFrom, nIndex, nItemType)
  local szPre = szFrom == "Target" and "BtnAttrib" or "BtnSrcAttrib"
  local szComName = szPre .. nIndex
  local szColor
  if not tbAttrib then
    self[szComName].pPanel:Label_SetText("TxtAttrib", "（空属性）")
    szColor = Item:GetQualityColor(1)
    self[szComName].pPanel:Label_SetGradientColor("TxtAttrib", szColor)
    return
  end
  local tbMA, szDesc = Item.tbRefinement:GetAttribMA(tbAttrib, nItemType)
  local nQuality = Item.tbRefinement:GetAttribColor(nEquipLevel, tbAttrib.nAttribLevel, nItemType)
  if Lib:IsEmptyStr(szDesc) then
    szDesc = FightSkill:GetMagicDesc(tbAttrib.szAttrib, tbMA)
  end
  self[szComName].pPanel:Label_SetText("TxtAttrib", szDesc)
  szColor = Item:GetQualityColor(nQuality)
  self[szComName].pPanel:Label_SetGradientColor("TxtAttrib", szColor)
end
function RefinementPanel:HaveEnoughMoney()
  local nCoin = me.GetMoney("Coin")
  return nCoin >= self.nCost
end
function RefinementPanel:CalcCost()
  local nCost = 0
  local tbSrcAttrib = self.tbSrcAttribs[self.nSrcPos]
  if tbSrcAttrib then
    nCost = Item.tbRefinement:GetRefineCost(tbSrcAttrib.nSaveData, self.pTarEquip.nItemType)
  end
  self.nCost = nCost
  self.pPanel:Label_SetText("TxtCoin", nCost)
end
function RefinementPanel:OnRespond(bRet, szMsg)
  self.bRequest = false
  if szMsg then
    me.CenterMsg(szMsg)
  end
  if not bRet then
    self:Update()
    return
  end
  local tbSrcAttrib = self.tbSrcAttribs[self.nSrcPos]
  local tbTarAttrib = self.tbTarAttribs[self.nTarPos]
  local szOrgDesc, nOrgAttribLevel
  if tbTarAttrib then
    nOrgAttribLevel = tbTarAttrib.nAttribLevel
    local tbMA = Item.tbRefinement:GetAttribMA(tbTarAttrib, self.pTarEquip.nItemType)
    szOrgDesc = FightSkill:GetMagicDesc(tbTarAttrib.szAttrib, tbMA)
  end
  local tbMA = Item.tbRefinement:GetAttribMA(tbSrcAttrib, self.pSrcEquip.nItemType)
  local szCurDesc = FightSkill:GetMagicDesc(tbSrcAttrib.szAttrib, tbMA)
  local nCurAttribLevel = tbSrcAttrib.nAttribLevel
  if Item.tbRefinement:CanRefinement(self.pTarEquip, self.pSrcEquip) then
    self:Update()
  else
    Ui:CloseWindow(self.UI_NAME)
    Ui:OpenWindow("RefineNotice", szOrgDesc, szCurDesc, nOrgAttribLevel, nCurAttribLevel, self.pTarEquip.nLevel, self.pTarEquip.nItemType)
    if self.tbRefinemRecord then
      Item.GoldEquip:ClientPorcessUpgrade(self.tbRefinemRecord)
    else
      local tbSrcAttribs = Item.tbRefinement:GetRandomAttrib(self.pSrcEquip)
      if not next(tbSrcAttribs) and (self.pSrcEquip.szClass ~= "ZhenYuan" or self.pSrcEquip.GetIntValue(Item.tbZhenYuan.nItemKeySKillInfo) == 0) then
        Shop:QuickSellItem(self.pSrcEquip.dwId, "当前装备已无随机属性，建议出售\n出售可以获得%d%s")
      end
    end
  end
end
