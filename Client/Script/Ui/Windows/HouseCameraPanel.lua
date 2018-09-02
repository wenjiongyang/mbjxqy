local tbUi = Ui:CreateClass("HouseCameraPanel")
local szUiScreeShot = "HouseSharePanel"
function tbUi:OnOpen(bFirstOpened)
  if bFirstOpened then
    self.nSelectIndex = 0
  end
  self.tbAllSetting = {
    House.tbNormalCameraSetting,
    House.tbPlayCameraSetting1,
    House.tbPlayCameraSetting2
  }
  for i, _ in ipairs(self.tbAllSetting) do
    self.pPanel:Toggle_SetChecked("Position" .. i, self.nSelectIndex == i)
  end
end
function tbUi:OnScreenClick()
  Ui:CloseWindow(self.UI_NAME)
end
function tbUi:ChangeCamera(nIndex)
  if self.nSelectIndex ~= nIndex then
    House:ChangeCameraSetting(unpack(self.tbAllSetting[nIndex]))
    self.nSelectIndex = nIndex
  end
  Ui:CloseWindow(self.UI_NAME)
  if Ui:WindowVisible(szUiScreeShot) ~= 1 then
    Ui:OpenWindow(szUiScreeShot)
  end
end
tbUi.tbOnClick = tbUi.tbOnClick or {}
function tbUi.tbOnClick:Position1()
  self:ChangeCamera(1)
end
function tbUi.tbOnClick:Position2()
  self:ChangeCamera(2)
end
function tbUi.tbOnClick:Position3()
  self:ChangeCamera(3)
end
