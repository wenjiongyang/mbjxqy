Require("Script/Ui/Windows/AthleticsHonorPanel.lua")
local tbUi = Ui:CreateClass("NewInfo_HonorMonthRank")
local tbMainUi = Ui:CreateClass("AthleticsHonor")
tbUi.tbActPlatnumIcon = {}
for _, szAct in ipairs(tbMainUi.tbActList) do
  tbUi.tbActPlatnumIcon[szAct] = tbMainUi.tbAthleticsAct[szAct].tbDivisionIcon[#Calendar.tbDivisionKey]
end
function tbUi:OnOpen(tbData)
  local function fn(itemObj, nIdx)
    local tbPlayerData = tbData[nIdx]
    itemObj.Button.pPanel:Label_SetText("Name", tbPlayerData.szName)
    itemObj.Button.pPanel:Label_SetText("FamilyName", tbPlayerData.szKinName or "")
    local nHonorLevel = tbPlayerData.nHonorLevel
    itemObj.Button.pPanel:SetActive("PlayerTitle", nHonorLevel and nHonorLevel > 0)
    if nHonorLevel and nHonorLevel > 0 then
      local tbHonorInfo = Player.tbHonorLevelSetting[nHonorLevel]
      itemObj.Button.pPanel:Sprite_Animation("PlayerTitle", tbHonorInfo.ImgPrefix)
    end
    local tbPlatnumAct = {}
    for _, szAct in ipairs(tbMainUi.tbActList) do
      if tbPlayerData.tbPlatnumAct[szAct] then
        table.insert(tbPlatnumAct, szAct)
      end
    end
    for i = 1, #tbMainUi.tbActList do
      local szAct = tbPlatnumAct[i]
      itemObj.Button.pPanel:SetActive("NameIcon" .. i, szAct or false)
      if szAct then
        itemObj.Button.pPanel:Sprite_SetSprite("NameIcon" .. i, self.tbActPlatnumIcon[szAct])
      end
    end
    local function fnOpenRightPopup()
      Ui:OpenWindowAtPos("RightPopup", 160, -90, "RankView", {
        dwRoleId = tbPlayerData.nPlayerId,
        szName = tbPlayerData.szName,
        dwKinId = 0
      })
    end
    itemObj.Button.pPanel.OnTouchEvent = fnOpenRightPopup
  end
  self.ScrollView:Update(#tbData, fn)
end
