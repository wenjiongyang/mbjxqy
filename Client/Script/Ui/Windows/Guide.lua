local tbGuide = Ui:CreateClass("Guide")
local tbDescPanel = {
  "TargetTop",
  "TargetButtom",
  "TargetLeft",
  "TargetRight",
  "DownDesc",
  "UpDesc"
}
local tbDescType = {
  PopT = {"TargetTop", "TxtDescT"},
  PopB = {
    "TargetButtom",
    "TxtDescB"
  },
  PopL = {"TargetLeft", "TxtDescL"},
  PopR = {
    "TargetRight",
    "TxtDescR"
  },
  NpcDown = {
    "DownDesc",
    "TxtDownDesc"
  },
  NpcUp = {"UpDesc", "TxtUpDesc"}
}
function tbGuide:OnOpen(szDescType, szDesc, pPanel, szWnd, tbPointer, bDisableClick, bBlackBg)
  self:BeginStep(szDescType, szDesc, pPanel, szWnd, tbPointer, bDisableClick, bBlackBg)
end
function tbGuide:BeginStep(szDescType, szDesc, pPanel, szWnd, tbPointer, bDisableClick, bBlackBg)
  self:EndStep()
  self:SetDesc(szDescType, szDesc)
  if pPanel and szWnd then
    self:SetLockWnd(pPanel, szWnd, tbPointer, bDisableClick, bBlackBg)
    self.pPanel:SetActive("BtnBg", false)
  else
    self.pPanel:SetActive("BtnBg", bDisableClick)
    self.pPanel:SetActive("SprBg", bBlackBg)
  end
end
function tbGuide:SetLockWnd(pPanel, szWnd, tbPointer, bDisableClick, bBlackBg)
  self:CloseLockWnd()
  print("Lock Wnd", szWnd)
  if not Ui.UiManager.LockWndToGuideLayer(pPanel, szWnd, bDisableClick, bBlackBg) then
    return
  end
  self.pOrgPanel = pPanel
  self.szOrgWnd = szWnd
  self.pPanel:SetActive("LockTarget", true)
  self.pPanel:ChangeWnd2SamePosition("LockTarget", pPanel, szWnd)
  if tbPointer then
    local tbPos = self.pPanel:GetPosition("LockTarget")
    self.pPanel:ChangePosition("LockTarget", tbPos.x + tbPointer[1], tbPos.y + tbPointer[2], 0)
  end
end
function tbGuide:CloseLockWnd()
  if self.pOrgPanel and self.szOrgWnd then
    print("Recover Lock Wnd")
    Ui.UiManager.ReleaseWndFromGuideLayer()
    self.pOrgPanel = nil
    self.szOrgWnd = nil
    self.pPanel:SetActive("LockTarget", false)
  end
end
function tbGuide:SetDesc(szDescType, szDesc)
  local szPanelWnd, szTxtWnd, szPivot = unpack(tbDescType[szDescType] or {})
  for _, szDescPanel in ipairs(tbDescPanel) do
    if szDescPanel == szPanelWnd then
      self.pPanel:SetActive(szPanelWnd, true)
      self.pPanel:Label_SetText(szTxtWnd, szDesc)
    else
      self.pPanel:SetActive(szDescPanel, false)
    end
  end
end
function tbGuide:EndStep()
  self:CloseLockWnd()
  self.bCheckClckScreen = false
end
function tbGuide:OnClose()
  self:EndStep()
end
function tbGuide:OnGuideClick(szUi, szWnd)
  if not self.szOrgWnd or szWnd == self.szOrgWnd then
  end
end
tbGuide.tbOnClick = {}
function tbGuide.tbOnClick:BtnBg()
  Guide:OnCheckClickScreen()
end
function tbGuide.tbOnClick:BtnSkipGuide()
  RemoteServer.__FinishAllGuide()
  Ui:CloseWindow(self.UI_NAME)
end
function tbGuide:RegisterEvent()
  local tbRegEvent = {}
  return tbRegEvent
end
