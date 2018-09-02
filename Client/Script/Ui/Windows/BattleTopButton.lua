local tbUi = Ui:CreateClass("BattleTopButton")
function tbUi:OnOpenEnd()
  self:CheckRedPoint()
end
function tbUi:CheckRedPoint()
  local tbTopUi = Ui:GetClass("TopButton")
  if tbTopUi then
    tbTopUi:CheckHasCanEquipItem()
  end
end
tbUi.tbOnClick = {}
function tbUi.tbOnClick.BtnBag()
  Ui:OpenWindow("ItemBox")
end
function tbUi.tbOnClick:BtnTopFold()
  self.BtnTopFoldState = not self.BtnTopFoldState
  if self.BtnTopFoldState then
    self.pPanel:PlayUiAnimation("HomeScreenButtonRetract", false, false, {})
  else
    self.pPanel:PlayUiAnimation("HomeScreenButtonStretch", false, false, {})
  end
end
function tbUi:RegisterEvent()
  local tbRegEvent = {
    {
      UiNotify.emNOTIFY_SYNC_ITEM,
      self.CheckRedPoint
    },
    {
      UiNotify.emNOTIFY_DEL_ITEM,
      self.CheckRedPoint
    }
  }
  return tbRegEvent
end
