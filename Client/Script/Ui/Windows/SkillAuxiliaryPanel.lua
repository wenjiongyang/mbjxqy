Ui.tbSkillAuxiliaryShow = Ui.tbSkillAuxiliaryShow or {}
local tbAuxiliaryShow = Ui.tbSkillAuxiliaryShow
function tbAuxiliaryShow:LoadSetting()
  self.tbLoadAuxiliary = {}
  local tbSetting = Lib:LoadTabFile("Setting/Skill/SkillAuxiliaryShow.tab", {ItemTID = 1})
  for _, tbInfo in ipairs(tbSetting) do
    if tbInfo.ItemTID > 0 then
      table.insert(self.tbLoadAuxiliary, tbInfo)
    end
  end
end
tbAuxiliaryShow:LoadSetting()
local tbUi = Ui:CreateClass("SkillAuxiliaryPanel")
tbUi.tbOnClick = {}
function tbUi.tbOnClick:BtnClose()
  Ui:CloseWindow("SkillAuxiliaryPanel")
end
function tbUi:OnOpen()
  self:UpdateInfo()
end
function tbUi:GetAllShowInfo()
  local tbAllShowInfo = {}
  for _, tbInfo in ipairs(tbAuxiliaryShow.tbLoadAuxiliary) do
    if Lib:IsEmptyStr(tbInfo.TimeFrame) or GetTimeFrameState(tbInfo.TimeFrame) == 1 then
      table.insert(tbAllShowInfo, tbInfo)
    end
  end
  return tbAllShowInfo
end
function tbUi:UpdateInfo()
  self.tbAllShowInfo = self:GetAllShowInfo()
  local function fnSetItem(tbItemObj, nIndex)
    local tbInfo = self.tbAllShowInfo[nIndex]
    if not tbInfo then
      return
    end
    self:SetSubItemInfo(tbItemObj, tbInfo)
  end
  local nUpdateCount = #self.tbAllShowInfo
  self.ScrollView:Update(nUpdateCount, fnSetItem)
end
tbUi.tbFunUpdateSub = {
  SkillHelp = function(tbSub, tbData)
    local tbItem = Item:GetClass("SkillPointBook")
    local tbInfo = tbItem.tbBookInfo[tbData.ItemTID]
    if tbInfo then
      local nCount = me.GetUserValue(tbItem.nSavePointGroup, tbInfo.nSaveID)
      tbSub.pPanel:Label_SetText("Number", string.format("%s/%s", nCount, tbInfo.nMaxCount))
    end
    return
  end,
  AddAttributeItemHelp = function(tbSub, tbData)
    local tbItem = Item:GetClass("AddPlayerAttributeItem")
    local tbInfo = tbItem.tbItemInfo[tbData.ItemTID]
    if tbInfo then
      local nCount = me.GetUserValue(tbItem.nSaveGroup, tbInfo.nSaveID)
      tbSub.pPanel:Label_SetText("Number", string.format("%s/%s", nCount, tbInfo.nMaxCount))
    end
    return
  end,
  AddSkillMaxLevel = function(tbSub, tbData)
    local tbItem = Item:GetClass("SkillMaxLevel")
    local tbInfo = tbItem.tbItemLimitInfo[tbData.ItemTID]
    if tbInfo then
      local nCount = me.GetUserValue(tbItem.nSaveLevelGroup, tbInfo.nSaveID)
      tbSub.pPanel:Label_SetText("Number", string.format("%s/%s", nCount, tbInfo.nMaxCount))
    end
    return
  end
}
function tbUi:SetSubItemInfo(tbSub, tbInfo)
  tbSub.Item:SetItemByTemplate(tbInfo.ItemTID, 1)
  tbSub.Item.fnClick = tbSub.Item.DefaultClick
  local szItemName = KItem.GetItemShowInfo(tbInfo.ItemTID, me.nFaction)
  tbSub.pPanel:Label_SetText("Name", szItemName)
  tbSub.pPanel:Label_SetText("Effect", tbInfo.UseInfo)
  tbSub.pPanel:Label_SetText("Channel", tbInfo.Channel)
  tbSub.pPanel:Label_SetText("Number", "-")
  if not Lib:IsEmptyStr(tbInfo.Class) then
    local fnBack = tbUi.tbFunUpdateSub[tbInfo.Class]
    if fnBack then
      fnBack(tbSub, tbInfo)
    end
  end
end
