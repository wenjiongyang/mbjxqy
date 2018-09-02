local tbUi = Ui:CreateClass("StoryBlackBg")
function tbUi:OnOpen(szContent)
  if not szContent then
    return 0
  end
end
function tbUi:OnOpenEnd(szContent, szTitle, nRowAniTime, nContentStayTime, nAlphaTime)
  self.szContent = szContent
  self.szTitle = szTitle
  self.nRowAniTime = nRowAniTime or 1
  self.nContentStayTime = nContentStayTime or 1
  self.nAlphaTime = nAlphaTime or 1
  self.tbTitlePos = self.tbTitlePos or self.pPanel:GetPosition("BgTitle1")
  self.nTitleHeight = self.nTitleHeight or self.pPanel:Sprite_GetSize("BgTitle1").y
  self.tbColPos = self.tbColPos or self.pPanel:GetPosition("BgCol1")
  self.nRowHeight = self.nRowHeight or self.pPanel:Sprite_GetSize("BgCol1").y
  self.nBgNum = self.nBgNum or 1
  self.pPanel:SetActive("Bg", false)
  self.pPanel:SetActive("_Bg", true)
  self.pPanel:Tween_AlphaWithStart("_Bg", 0, 1, self.nAlphaTime)
  self.nTimer = Timer:Register(Env.GAME_FPS * self.nAlphaTime, self.InitBg, self)
end
function tbUi:InitBg()
  self.pPanel:SetActive("Bg", true)
  self.pPanel:Tween_Disable("Bg")
  self.pPanel:SetActive("_Bg", false)
  self:InitTitleBg()
  self:InitContentBg()
  if not Lib:IsEmptyStr(self.szTitle) then
    self:PlayTitleAni()
  else
    self:PlayContentAni(1)
  end
end
function tbUi:InitTitleBg()
  self.pPanel:SetActive("Title", self.szTitle and true or false)
  if self.szTitle then
    self.pPanel:SetActive("BgTitle", true)
    self.pPanel:Label_SetText("Title", self.szTitle)
    self.pPanel:ChangePosition("BgTitle1", self.tbTitlePos.x, self.tbTitlePos.y)
  end
end
function tbUi:InitContentBg()
  self.pPanel:SetActive("BgColumn", true)
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
end
function tbUi:PlayTitleAni()
  local tbLabelSize = self.pPanel:Label_GetSize("Title")
  local tbPos = self.pPanel:GetPosition("BgTitle1")
  self.pPanel:Tween_RunWhithStartPos("BgTitle1", tbPos.x, tbPos.y, tbPos.x + tbLabelSize.x, tbPos.y, self.nRowAniTime)
  self.nTimer = Timer:Register(Env.GAME_FPS * self.nRowAniTime, function()
    self:PlayContentAni(1)
  end, self)
end
function tbUi:PlayContentAni(nIdx)
  local tbLabelSize = self.pPanel:Label_GetSize("PlotDescription")
  local tbPos = self.pPanel:GetPosition("BgCol" .. nIdx)
  self.pPanel:Tween_RunWhithStartPos("BgCol" .. nIdx, tbPos.x, tbPos.y, tbPos.x + tbLabelSize.x, tbPos.y, self.nRowAniTime)
  if nIdx == self.nBgNum then
    self.nTimer = Timer:Register(Env.GAME_FPS * (self.nContentStayTime + self.nRowAniTime), function()
      self:PlayCloseAni()
    end, self)
  else
    self.nTimer = Timer:Register(Env.GAME_FPS * self.nRowAniTime, function()
      self:PlayContentAni(nIdx + 1)
    end, self)
  end
end
function tbUi:PlayCloseAni()
  self.pPanel:SetActive("Bg", false)
  self.pPanel:SetActive("Bg", true)
  self.pPanel:Tween_AlphaWithStart("Bg", 1, 0, self.nAlphaTime)
  self.pPanel:SetActive("BgColumn", false)
  self.pPanel:SetActive("BgTitle", false)
  self.nTimer = Timer:Register(Env.GAME_FPS * self.nAlphaTime, function()
    Ui:CloseWindow(self.UI_NAME)
    self.nTimer = nil
  end)
end
function tbUi:OnClose()
  if self.nTimer then
    Timer:Close(self.nTimer)
    self.nTimer = nil
  end
  self.pPanel:Tween_Reset("_Bg")
  self.pPanel:Tween_Reset("Bg")
end
