local tbUi = Ui:CreateClass("PartnerDecompose")
function tbUi:Update()
  self.tbSelectInfo = {}
  self:UpdateDecomposeList()
end
function tbUi:UpdateDecomposeList()
  self.tbPartnerList, self.tbAllPartner = Partner:GetSortedPartnerList(me)
  for i = #self.tbPartnerList, 1, -1 do
    local tbPartner = self.tbAllPartner[self.tbPartnerList[i]]
    if tbPartner.nPos then
      table.remove(self.tbPartnerList, i)
    end
  end
  self.tbSelectInfo = self.tbSelectInfo or {}
  local function fnOnSelect(itemObj)
    if Ui.bShowDebugInfo then
      local tbPartnerInfo = self.tbAllPartner[itemObj.nPartnerId]
      if tbPartnerInfo then
        Ui:SetDebugInfo("TemplateId: " .. tbPartnerInfo.nTemplateId)
      end
    end
    self:OnSelectPartner(itemObj.nPartnerId)
  end
  local function fnSetItem(itemObj, index)
    local nPartnerId = self.tbPartnerList[index]
    local tbPartner = self.tbAllPartner[nPartnerId]
    itemObj.nPartnerId = nPartnerId
    itemObj.PartnerHead:SetPartnerInfo(tbPartner)
    itemObj.pPanel:Label_SetText("Name", tbPartner.szName)
    itemObj.pPanel:Label_SetText("Fighting", string.format("战力：%s", tbPartner.nFightPower))
    itemObj.pPanel:SetActive("Mark", tbPartner.nIsNormal == 0)
    itemObj.pPanel:Sprite_SetSprite("Main", self.tbSelectInfo[nPartnerId] and "BtnListThirdPress" or "BtnListThirdNormal")
    itemObj.BtnCheck.pPanel:SetActive("GuideTips", false)
    itemObj.BtnCheck.nPartnerId = nPartnerId
    itemObj.BtnCheck:SetCheck(self.tbSelectInfo[nPartnerId] and true or false)
    itemObj.BtnCheck.pPanel.OnTouchEvent = fnOnSelect
    itemObj.pPanel.OnTouchEvent = fnOnSelect
  end
  self.PartnerListScrollView2:Update(self.tbPartnerList, fnSetItem)
end
function tbUi:OnSelectPartner(nPartnerId)
  if self.tbSelectInfo[nPartnerId] then
    self.tbSelectInfo[nPartnerId] = nil
  else
    self.tbSelectInfo[nPartnerId] = true
  end
  self:UpdateDecomposeList()
end
function tbUi:OnDeletePartner(nPartnerId)
  self:Update()
end
tbUi.tbOnClick = {}
function tbUi.tbOnClick:BtnDoDecompose()
  if not self.tbSelectInfo or Lib:CountTB(self.tbSelectInfo) <= 0 then
    me.CenterMsg("当前没有同伴")
    return
  end
  local bRet, szMsg = Partner:CheckCanDecomposePartner(me, self.tbSelectInfo)
  if not bRet then
    me.CenterMsg(szMsg)
    return
  end
  local bNeedNote = false
  for nPartnerId in pairs(self.tbSelectInfo) do
    local tbPartner = me.GetPartnerInfo(nPartnerId)
    if tbPartner.nLevel > 1 or tbPartner.nQualityLevel <= 3 then
      bNeedNote = true
      break
    end
  end
  if bNeedNote then
    me.MsgBox(string.format("当前选中同伴含有[FFFE0D]S级[-]以上或[FFFE0D]等级大于1级[-]，是否要遣散？\n[FFFE0D]（遣散后的同伴将会消失）[-]"), {
      {
        "确认",
        function()
          RemoteServer.CallPartnerFunc("DecomposePartner", self.tbSelectInfo)
        end
      },
      {"取消"}
    })
  else
    RemoteServer.CallPartnerFunc("DecomposePartner", self.tbSelectInfo)
  end
end
