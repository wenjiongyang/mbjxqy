local tbUi = Ui:CreateClass("GetPosition")
function tbUi:OnOpen()
  self.tbPos = {}
end
function tbUi:Save()
  local szInfo = [[


]]
  for szPosName, tbAllPos in pairs(self.tbPos) do
    for _, tbPos in pairs(tbAllPos) do
      szInfo = szInfo .. string.format("%s\t%s\t%s\n", szPosName, tbPos[1], tbPos[2])
    end
  end
  Log(szInfo)
  self.tbPos = {}
end
function tbUi:GetPos()
  local szPosName = self.PosName:GetText()
  self.tbPos[szPosName] = self.tbPos[szPosName] or {}
  local _, x, y = me.GetWorldPos()
  self.tbPos[szPosName] = self.tbPos[szPosName] or {}
  table.insert(self.tbPos[szPosName], {x, y})
end
tbUi.tbOnClick = {}
function tbUi.tbOnClick:BtnGetPos()
  self:GetPos()
end
function tbUi.tbOnClick:BtnSave()
  self:Save()
end
function tbUi.tbOnClick:BtnClose()
  self:Save()
  Ui:CloseWindow("GetPosition")
end
