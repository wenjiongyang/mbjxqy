local tbUi = Ui:CreateClass("TaskFinish")
function tbUi:OnOpen(nTaskId, nNpcId)
  local tbTask = Task:GetTask(nTaskId or 0)
  if not tbTask then
    return 0
  end
  if Ui:WindowVisible("HomeScreenTask") and Ui("HomeScreenTask").nAutoFinishTaskId == nTaskId then
    RemoteServer.OnFinishTaskDialog(nTaskId, Task.STATE_CAN_FINISH, nNpcId)
    return 0
  end
  self.nTaskId = nTaskId
  self.nNpcId = nNpcId
  self.pPanel:Label_SetText("TaskTitle", tbTask.szTaskTitle)
  self.pPanel:Label_SetText("TaskDesc", tbTask.szDetailDesc)
  local tbAward = tbTask.tbAward or {}
  for i = 1, 4 do
    if tbAward[i] then
      self.pPanel:SetActive("itemframe" .. i, true)
      self["itemframe" .. i]:SetGenericItem(tbAward[i])
      self["itemframe" .. i].fnClick = self["itemframe" .. i].DefaultClick
    else
      self.pPanel:SetActive("itemframe" .. i, false)
    end
  end
end
tbUi.tbOnClick = tbUi.tbOnClick or {}
function tbUi.tbOnClick:BtnClose()
  Ui:CloseWindow(self.UI_NAME)
end
function tbUi.tbOnClick:Btnchallenge()
  Ui:CloseWindow(self.UI_NAME)
  RemoteServer.OnFinishTaskDialog(self.nTaskId, Task.STATE_CAN_FINISH, self.nNpcId)
end
