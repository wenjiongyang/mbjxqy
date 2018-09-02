local ChatDecorate = ChatMgr.ChatDecorate
function ChatDecorate:ApplyDecorate(tbData)
  if self:IsOldServer() then
    return
  end
  if not tbData or not next(tbData) then
    return
  end
  if ChatDecorate:GetCurHeadFrame(me) == tbData[ChatDecorate.PartsType.HEAD_FRAME] and ChatDecorate:GetCurBubble(me) == tbData[ChatDecorate.PartsType.BUBBLE] then
    return
  end
  RemoteServer.TryApplyDecorate(tbData)
end
function ChatDecorate:IsOldServer()
  return false
end
function ChatDecorate:TryCheckValid()
  if self:IsOldServer() then
    return
  end
  if ChatDecorate:CheckValidTime(me) or ChatDecorate:CheckConditionOverdure(me) or ChatDecorate:CheckTimeOverdue(me) then
    RemoteServer.CheckChatDecorate()
  end
end
function ChatDecorate:OnDecorateChange()
  if self:IsOldServer() then
    return
  end
  Ui:SetRedPointNotify("Theme")
  Client:SetFlag("nChatDecorate", 1)
end
function ChatDecorate:OnLogin()
  if self:IsOldServer() then
    return
  end
  Ui:ClearRedPointNotify("Theme")
  local nChatDecorate = Client:GetFlag("nChatDecorate") or 0
  if nChatDecorate == 1 then
    Ui:SetRedPointNotify("Theme")
  end
end
function ChatDecorate:ChatDecorateGuide(nLevel)
  if self:IsOldServer() then
    return
  end
  if nLevel == 10 then
    self:OnDecorateChange()
  end
end
function ChatDecorate:OnVipChange(nVipLevel)
  if self:CheckVip(nVipLevel) then
    self:OnDecorateChange()
  end
end
function ChatDecorate:OnPartsReset()
  UiNotify.OnNotify(UiNotify.emNOTIFY_CHAT_THEME_OVERDUE, true)
end
function ChatDecorate:ChanePosition(nCareer, nOldCareer)
  if nOldCareer and nOldCareer == Kin.Def.Career_Mascot then
    me.CenterMsg("您的「家族宝贝」头像框已经过期", true)
    self:ApplyKinData()
  elseif nCareer and nCareer == Kin.Def.Career_Mascot then
    self:OnDecorateChange()
  end
end
function ChatDecorate:ApplyKinData()
  if Kin:HasKin() then
    Kin:UpdateMemberCareer()
  end
end
