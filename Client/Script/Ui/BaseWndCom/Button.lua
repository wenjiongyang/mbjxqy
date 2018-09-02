local tbUi = Ui:CreateClass("Button")
function tbUi:SetText(szText)
  self.pPanel:Label_SetText("Text", szText)
end
function tbUi:SetState(nState)
  self.pPanel:Button_SetState("Main", nState)
end
function tbUi:SetVisible(bVisible)
  self.pPanel:SetActive("Main", bVisible)
end
function tbUi:SetGroup(nGroup)
  self.pPanel:Toggle_SetGroup("Main", nGroup)
end
function tbUi:SetChecked(bChecked)
  self.pPanel:Toggle_SetChecked("Main", bChecked)
end
function tbUi:SetCD(nCD)
  self.cd = nCD
end
function tbUi:Countdown()
end
