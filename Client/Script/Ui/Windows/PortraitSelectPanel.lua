local PortraitSelectPanel = Ui:CreateClass("PortraitSelectPanel")
PortraitSelectPanel.tbOnClick = {
  BtnClose = function(self)
    Ui:CloseWindow(self.UI_NAME)
  end,
  BtnSource = function(self)
    local _1, _2, szOpenUi = self:GetDesc(self.nSelectPortrait or -1)
    if szOpenUi and szOpenUi ~= "" then
      Ui:OpenWindow(szOpenUi)
    end
  end
}
PortraitSelectPanel.nSelectPortrait = nil
PortraitSelectPanel.tbPortraits = nil
function PortraitSelectPanel:OnOpen()
  self.nSelectPortrait = me.nPortrait
  self:Update()
end
function PortraitSelectPanel:OnClose()
  RemoteServer.ChangePortrait(self.nSelectPortrait)
  UiNotify.OnNotify(UiNotify.emNOTIFY_CHANGE_PORTRAIT)
end
function PortraitSelectPanel:UpdatePortraitList()
  self.tbPortraits = {}
  local tbFactionPortraits = PlayerPortrait:GetFactionPortraits(me.nFaction)
  for k, v in pairs(tbFactionPortraits) do
    if PlayerPortrait:IsAvaliablePortraits(v.nId) then
      self.tbPortraits[v.nId] = v
    end
  end
end
function PortraitSelectPanel:UpdateScrollView()
  local tbPortraits = {}
  for k, v in pairs(self.tbPortraits) do
    table.insert(tbPortraits, v)
  end
  local function fnClickItem(buttonObj)
    local nPortrait = buttonObj.nPortrait
    self.nSelectPortrait = nPortrait
    self:UpdateDetail()
    self:UpdateScrollView()
  end
  local function fnSetItem(itemObj, nIndex)
    for i = 1, 4 do
      local nSuffix = (nIndex - 1) * 4 + i
      local tbData = tbPortraits[nSuffix]
      local bShow = tbData and true or false
      itemObj.pPanel:SetActive("Head" .. i, bShow)
      itemObj.pPanel:SetActive("SpRoleHead" .. i, bShow)
      itemObj.pPanel:SetActive("SelectMark" .. i, bShow and self.nSelectPortrait == tbData.nId)
      if bShow then
        itemObj["Head" .. i].nPortrait = tbData.nId
        itemObj["Head" .. i].pPanel.OnTouchEvent = fnClickItem
        local szSprite, szAtlas = PlayerPortrait:GetPortraitIcon(tbData.nId)
        itemObj.pPanel:Sprite_SetSprite("SpRoleHead" .. i, szSprite, szAtlas)
      end
      itemObj.pPanel.OnTouchEvent = nil
    end
  end
  local nLen = math.ceil(#tbPortraits / 4)
  self.ScrollView:Update(nLen, fnSetItem)
end
function PortraitSelectPanel:Update()
  self:UpdatePortraitList()
  self:UpdateScrollView()
  self:UpdateDetail()
end
function PortraitSelectPanel:UpdateDetail()
  local szDesc, szLimit, szOpenUi = self:GetDesc(self.nSelectPortrait)
  local szDesc = string.gsub(szDesc or "", "\\n", "\n")
  self.pPanel:Label_SetText("HeadDetails", szDesc or "")
  self.pPanel:Label_SetText("AccessWay", szLimit or "")
  local szIcon, szIconAtlas = self:GetIcon(self.nSelectPortrait)
  self.pPanel:Sprite_SetSprite("Head", szIcon, szIconAtlas)
  if szOpenUi and szOpenUi ~= "" then
    self.pPanel:SetActive("BtnSource", true)
  else
    self.pPanel:SetActive("BtnSource", false)
  end
end
function PortraitSelectPanel:RegisterEvent()
  local tbRegEvent = {
    {
      UiNotify.emNOTIFY_ADD_PORTRAIT,
      self.Update
    }
  }
  return tbRegEvent
end
function PortraitSelectPanel:GetDesc(nPortrait)
  local tbSetting = self.tbPortraits[nPortrait]
  if not tbSetting then
    return
  end
  return tbSetting.szDesc, tbSetting.szLimit, tbSetting.szOpenUi
end
function PortraitSelectPanel:GetIcon(nPortrait)
  local tbSetting = PlayerPortrait:GetPortraitSetting(nPortrait)
  return tbSetting.szBigIcon, tbSetting.szBigIconAtlas
end
