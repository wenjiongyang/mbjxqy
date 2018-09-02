local tbUi = Ui:CreateClass("TreeMenu")
function tbUi:OnCreate()
  self.pPanel:InitScrollView("Main")
end
function tbUi:SetTreeMenu(tbTree, fnSetItem, fnClickBranch)
  self.tbTree = tbTree
  self.tbCurDown = nil
  function self.fnSetItem(itemObj, nIdx)
    local tbItemData = self.tbItems[nIdx]
    fnSetItem(itemObj, tbItemData, nIdx)
    if tbItemData.tbLeaves then
      itemObj.BaseClass.pPanel:SetActive("BtnDownS", not tbItemData.bDown)
      itemObj.BaseClass.pPanel:SetActive("BtnUpS", tbItemData.bDown and true or false)
    end
    local fnOldTouch = itemObj.BaseClass.pPanel.OnTouchEvent
    function itemObj.BaseClass.pPanel.OnTouchEvent(btnObj)
      for _, tbNode in ipairs(self.tbTree) do
        if tbNode.tbLeaves and tbNode ~= tbItemData then
          tbNode.bDown = false
        end
      end
      self.tbCurDown = tbItemData
      if tbItemData.tbLeaves then
        tbItemData.bDown = not tbItemData.bDown
        if fnClickBranch then
          fnClickBranch(tbItemData)
        end
      elseif fnOldTouch then
        fnOldTouch(btnObj)
      end
      self:Update()
    end
  end
  self:Update()
end
function tbUi:GetCurBaseNode()
  return self.tbCurDown
end
function tbUi:Update()
  local tbItems = {}
  for _, tbNode in ipairs(self.tbTree) do
    table.insert(tbItems, tbNode)
    if tbNode.tbLeaves and tbNode.bDown then
      self.tbCurDown = tbNode
      for _, tbLeaf in ipairs(tbNode.tbLeaves) do
        table.insert(tbItems, tbLeaf)
      end
    end
  end
  self.tbItems = tbItems
  self.pPanel:UpdateScrollView(#tbItems)
end
