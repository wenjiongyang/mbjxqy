local tbUi = Ui:CreateClass("JingMaiTipsPanel")
function tbUi:OnOpen(tbExtAttrib, tbSkillInfo, bHasNoPartner, bFromItemBox)
  self.bFromItemBox = bFromItemBox
  self.bHasNoPartner = bHasNoPartner
  if self.bHasNoPartner then
    self.tbExtAttrib = {}
    self.tbSkillInfo = {}
  else
    self.tbExtAttrib = tbExtAttrib or {}
    self.tbSkillInfo = tbSkillInfo or {}
  end
  self:Update()
end
function tbUi:Update()
  local nSLine = #self.tbSkillInfo > 0 and 4 or 0
  self.pPanel:Label_SetText("Anchor", #self.tbSkillInfo > 0 and string.rep("\n", 4) or "")
  self.pPanel:SetActive("AdditionalSkillTitle", #self.tbSkillInfo > 0)
  self.pPanel:SetActive("SkillBgRange", #self.tbSkillInfo > 5)
  if #self.tbSkillInfo > 0 then
    do
      local fnOnClickSkill = function(nSkillId, nSkillLevel, nMaxSkillLevel)
        local tbSubInfo = FightSkill:GetSkillShowTipInfo(nSkillId, nSkillLevel, nMaxSkillLevel)
        Ui:OpenWindow("SkillShow", tbSubInfo)
      end
      local function fnSetItem(itemObj, index)
        local nSkillId, nSkillLevel, nMaxSkillLevel = unpack(self.tbSkillInfo[index])
        itemObj.pPanel:Label_SetText("Level", nSkillLevel)
        local tbValue = FightSkill:GetSkillShowInfo(nSkillId)
        itemObj.pPanel:Sprite_SetSprite("Icon", tbValue.szIconSprite, tbValue.szIconAtlas)
        function itemObj.pPanel.OnTouchEvent()
          fnOnClickSkill(nSkillId, nSkillLevel, nMaxSkillLevel)
        end
      end
      self.ScrollViewSkill:Update(self.tbSkillInfo, fnSetItem)
    end
  end
  local szDesc, nLine = JingMai:GetAttribDesc(JingMai:GetAttribInfo(self.tbExtAttrib))
  nSLine = nSLine + nLine
  if self.bHasNoPartner then
    szDesc = "当前无同伴上阵不享受属性加成"
  elseif szDesc == "" then
    szDesc = "尚未打通任何穴位！"
  end
  self.pPanel:SetActive("BtnGo", self.bFromItemBox and true or false)
  self.pPanel:Label_SetText("Attribute", szDesc ~= "" and szDesc or "无经脉属性加成")
  self.pPanel:ResizeScrollViewBound("ScrollView", 40 - nSLine * 20, 120)
  self.pPanel:DragScrollViewGoTop("ScrollView")
end
function tbUi:OnScreenClick()
  Ui:CloseWindow(self.UI_NAME)
end
tbUi.tbOnClick = tbUi.tbOnClick or {}
function tbUi.tbOnClick:BtnClose()
  Ui:CloseWindow(self.UI_NAME)
end
function tbUi.tbOnClick:BtnGo()
  Ui:CloseWindow(self.UI_NAME)
  Ui:CloseWindow("ItemBox")
  Ui:OpenWindow("JingMaiPanel")
end
