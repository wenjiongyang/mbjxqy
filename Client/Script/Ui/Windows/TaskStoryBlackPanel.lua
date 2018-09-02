local tbUi = Ui:CreateClass("TaskStoryBlackPanel")
function tbUi:RegisterEvent()
  return {
    {
      UiNotify.emNOTIFY_MAP_ENTER,
      self.OnEnterMap,
      self
    }
  }
end
function tbUi:OnOpen(szTitle, szContent)
  if not szContent then
    return 0
  end
  self.bCloseEnabled = false
end
function tbUi:OnOpenEnd(szTitle, szContent, fnCallBack, bDelayClose)
  self.szTitle = szTitle
  self.szContent = szContent
  self.fnCallBack = fnCallBack
  self.bDelayClose = bDelayClose
  self.tbTitlePos = self.tbTitlePos or self.pPanel:GetPosition("BgTitle1")
  self.nTitleHeight = self.nTitleHeight or self.pPanel:Sprite_GetSize("BgTitle1").y
  self.tbColPos = self.tbColPos or self.pPanel:GetPosition("BgCol1")
  self.nRowHeight = self.nRowHeight or self.pPanel:Sprite_GetSize("BgCol1").y
  self.nBgNum = self.nBgNum or 1
  self:InitBg()
  function self.pPanel.OnTouchEvent()
    if self.bCloseEnabled then
      Ui:CloseWindow(self.UI_NAME)
    end
  end
  self.szOpenAni = self.pPanel:GetOpenAni(self.UI_NAME)
  self.szCloseAni = self.pPanel:GetCloseAni(self.UI_NAME)
end
function tbUi:OnAniEnd(szAniName)
  if Lib:IsEmptyStr(szAniName) then
    return
  end
  if not Lib:IsEmptyStr(self.szOpenAni) and self.szOpenAni == szAniName then
    if not Lib:IsEmptyStr(self.szTitle) then
      self:PlayTitleAni()
    else
      self:InitContentAni()
    end
  elseif not Lib:IsEmptyStr(self.szCloseAni) and self.szCloseAni == szAniName and self.fnCallBack then
    self.fnCallBack()
    self.fnCallBack = nil
  end
end
function tbUi:InitBg()
  self.pPanel:SetActive("Title", not Lib:IsEmptyStr(self.szTitle))
  self.pPanel:SetActive("BgTitle", true)
  self.pPanel:SetActive("BgColumn", true)
  if not Lib:IsEmptyStr(self.szTitle) then
    self.pPanel:Label_SetText("Title", "")
    self.pPanel:ChangePosition("BgTitle1", self.tbTitlePos.x, self.tbTitlePos.y)
  end
  self.pPanel:Label_SetText("PlotDescription", "")
end
local nTextTime = 1
function tbUi:PlayTitleAni()
  self.pPanel:Label_SetText("Title", self.szTitle)
  local tbLabelSize = self.pPanel:Label_GetSize("Title")
  local tbPos = self.pPanel:GetPosition("BgTitle1")
  self.pPanel:Tween_RunWhithStartPos("BgTitle1", tbPos.x, tbPos.y, tbPos.x + tbLabelSize.x, tbPos.y, nTextTime)
  self.nTimer = Timer:Register(Env.GAME_FPS * nTextTime, function()
    self:InitContentAni()
  end)
end
function tbUi:InitContentAni()
  self.pPanel:Label_SetText("PlotDescription", self.szContent or "")
  local nLabelH = self.pPanel:Label_GetSize("PlotDescription").y
  local nRowNum = math.ceil(nLabelH / self.nRowHeight)
  for i = self.nBgNum + 1, nRowNum do
    self.pPanel:CreateWnd("BgCol1", "BgCol" .. i)
  end
  self.nBgNum = math.max(self.nBgNum, nRowNum)
  for i = 1, self.nBgNum do
    self.pPanel:ChangePosition("BgCol" .. i, self.tbColPos.x, self.tbColPos.y - (i - 1) * self.nRowHeight)
  end
  self:PlayContentAni(1)
end
function tbUi:PlayContentAni(nIdx)
  local tbLabelSize = self.pPanel:Label_GetSize("PlotDescription")
  local tbPos = self.pPanel:GetPosition("BgCol" .. nIdx)
  self.pPanel:Tween_RunWhithStartPos("BgCol" .. nIdx, self.tbColPos.x, tbPos.y, self.tbColPos.x + tbLabelSize.x, tbPos.y, nTextTime)
  if nIdx == self.nBgNum then
    self.nTimer = Timer:Register(Env.GAME_FPS * nTextTime, function()
      self:OnContentAniEnd()
    end, self)
  else
    self.nTimer = Timer:Register(Env.GAME_FPS * nTextTime, function()
      self:PlayContentAni(nIdx + 1)
    end, self)
  end
end
function tbUi:OnContentAniEnd()
  self.nTimer = nil
  self.pPanel:SetActive("BgColumn", false)
  self.pPanel:SetActive("BgTitle", false)
  Timer:Register(Env.GAME_FPS * 1, function()
    self.bCloseEnabled = true
    if self.fnCallBack then
      self.nTimer = nil
      if self.bDelayClose then
        self.fnCallBack()
        self.fnCallBack = nil
      else
        Ui:CloseWindow(self.UI_NAME)
      end
    else
      Ui:CloseWindow(self.UI_NAME)
    end
  end)
end
function tbUi:OnClose()
  if self.nTimer then
    Timer:Close(self.nTimer)
    self.nTimer = nil
  end
end
function tbUi:OnEnterMap()
  Ui:CloseWindow(self.UI_NAME)
end
