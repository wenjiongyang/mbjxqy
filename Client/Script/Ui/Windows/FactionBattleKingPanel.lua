local GetInfo = function(idx, tbData)
  local info = tbData and tbData[idx] or FactionBattle.tbWinnerInfo[idx]
  if info then
    local tbHonorInfo = Player.tbHonorLevelSetting[info.nHonorLevel]
    local playerTitle
    if tbHonorInfo and tbHonorInfo.ImgPrefix then
      playerTitle = tbHonorInfo.ImgPrefix
    end
    local headIcon, headAtlas = PlayerPortrait:GetPortraitBigIcon(info.nPortrait)
    if info.nPlayerId <= 0 then
      headIcon, headAtlas = nil, nil
    end
    return {
      faction = Faction:GetName(info.nFaction),
      familyName = info.szKinName,
      fightName = info.nFightPower,
      playerName = info.szName,
      playerTitle = playerTitle,
      spRoleHead = headIcon,
      roleHeadAtlas = headAtlas,
      spFaction = Faction:GetIcon(info.nFaction),
      level = info.nLevel,
      nPlayerId = info.nPlayerId
    }
  end
end
local function Update(self, tbNewInfo)
  local nSession = tbNewInfo and tbNewInfo[1] or FactionBattle.nSession
  self.pPanel:Label_SetText("Number", Lib:Transfer4LenDigit2CnNum(nSession))
  local bIAmWinner = false
  local tbSorted = {}
  for i = 1, Faction.MAX_FACTION_COUNT do
    if tbNewInfo then
      if tbNewInfo[2][i] then
        table.insert(tbSorted, tbNewInfo[2][i])
        if tbNewInfo[2][i].nPlayerId == me.dwID then
          bIAmWinner = true
        end
      end
    elseif FactionBattle.tbWinnerInfo[i] then
      table.insert(tbSorted, FactionBattle.tbWinnerInfo[i])
      if FactionBattle.tbWinnerInfo[i].nPlayerId == me.dwID then
        bIAmWinner = true
      end
    end
  end
  self.pPanel:SetActive("BtnFactionShowOff", bIAmWinner)
  local function fnSetItem(obj, i)
    for idx = 1, 2 do
      local info = GetInfo((i - 1) * 2 + idx, tbSorted)
      local factionInfoName = string.format("FactionInfo%d", idx)
      local factionInfoPanel = obj[factionInfoName]
      obj.pPanel:SetActive(factionInfoName, info)
      if info then
        factionInfoPanel.pPanel:Label_SetText("Faction", info.faction)
        factionInfoPanel.pPanel:Label_SetText("TxtFamilyName", info.familyName)
        factionInfoPanel.pPanel:Label_SetText("TxtFightName", info.fightName)
        factionInfoPanel.pPanel:Label_SetText("TxtPlayerName", info.playerName)
        local nameOffsetX = 0
        if info.playerTitle then
          factionInfoPanel.pPanel:Sprite_Animation("PlayerTitle", info.playerTitle)
          nameOffsetX = 35
        else
          nameOffsetX = -22
        end
        local titlePos = factionInfoPanel.pPanel:GetPosition("PlayerTitle")
        factionInfoPanel.pPanel:ChangePosition("TxtPlayerName", titlePos.x + nameOffsetX, titlePos.y - 3)
        factionInfoPanel.pPanel:SetActive("PlayerTitle", info.playerTitle)
        if info.spRoleHead then
          factionInfoPanel.pPanel:Sprite_SetSprite("Role", info.spRoleHead, info.roleHeadAtlas)
          factionInfoPanel.pPanel:SetActive("Role", true)
        else
          factionInfoPanel.pPanel:SetActive("Role", false)
        end
        factionInfoPanel.pPanel:Sprite_SetSprite("FactionIcon", info.spFaction)
        factionInfoPanel.pPanel:Label_SetText("TxtLevel", info.level)
        factionInfoPanel.BtnCheck.nPlayerId = info.nPlayerId
        local fnOnClick = function(itemObj)
          ViewRole:OpenWindow("ViewRolePanel", itemObj.nPlayerId)
        end
        factionInfoPanel.BtnCheck.pPanel.OnTouchEvent = fnOnClick
      end
    end
  end
  local rows = math.ceil(#tbSorted / 2)
  self.ScrollViewFactionItem:Update(rows, fnSetItem)
end
local tbNewInfoUi = Ui:CreateClass("NewInfo_FactionBattle")
function tbNewInfoUi:OnOpen(tbData)
  self.pPanel:SetActive("NewKingTitle", tbData or false)
  self.pPanel:SetActive("ScrollViewFactionItem", tbData or false)
  self.pPanel:SetActive("BtnFactionShowOff", false)
  if not tbData then
    return
  end
  Update(self, tbData)
end
tbNewInfoUi.tbOnClick = tbNewInfoUi.tbOnClick or {}
function tbNewInfoUi.tbOnClick:BtnFactionShowOff()
  Ui:OpenWindow("MainShowOffPanel", "Faction")
end
