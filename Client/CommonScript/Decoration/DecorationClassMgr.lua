if not Decoration.tbClassBase then
  Decoration.tbClassBase = {}
end
if not Decoration.tbClass then
  Decoration.tbClass = {
    default = Decoration.tbClassBase,
    [""] = Decoration.tbClassBase
  }
end
function Decoration:GetClass(szClass, bNotCreate)
  local tbClass = self.tbClass[szClass]
  if not tbClass and bNotCreate ~= 1 then
    tbClass = Lib:NewClass(self.tbClassBase)
    self.tbClass[szClass] = tbClass
  end
  return tbClass
end
function Decoration:OnCreate(nId)
  local tbDecoration = self.tbAllDecoration[nId]
  if not tbDecoration then
    return
  end
  local tbTemplate = self.tbAllTemplate[tbDecoration.nTemplateId]
  if not tbTemplate then
    return
  end
  local tbClass = self:GetClass(tbTemplate.szType, 1)
  if tbClass and tbClass.OnCreate then
    tbClass:OnCreate(nId)
  end
end
function Decoration:OnClientCmd(pPlayer, nId, ...)
  local tbDecoration = self.tbAllDecoration[nId]
  if not tbDecoration or not self:CanOperation(tbDecoration, pPlayer) then
    return
  end
  local tbTemplate = self.tbAllTemplate[tbDecoration.nTemplateId]
  if not tbTemplate then
    return
  end
  local tbClass = self:GetClass(tbTemplate.szType, 1)
  if tbClass and tbClass.OnClientCmd then
    tbClass:OnClientCmd(pPlayer, nId, ...)
  end
end
function Decoration:OnDelete(nId)
  Decoration:ExitPlayerActStateByDecorationId(nId, true)
  local tbDecoration = self.tbAllDecoration[nId]
  if not tbDecoration then
    return
  end
  local tbTemplate = self.tbAllTemplate[tbDecoration.nTemplateId]
  if not tbTemplate then
    return
  end
  local tbClass = self:GetClass(tbTemplate.szType, 1)
  if tbClass and tbClass.OnDelete then
    tbClass:OnDelete(nId)
  end
end
function Decoration:OnLogin(pPlayer)
  self:PlayerOnEnterMap(pPlayer.nMapId)
  self:ExitPlayerActState(pPlayer.dwID)
  for _, tbClass in pairs(self.tbClass) do
    if tbClass.OnLogin then
      tbClass:OnLogin(pPlayer)
    end
  end
end
function Decoration:OnLeaveMap(nMapTemplateId, nMapId)
  Decoration:ExitPlayerActState(me.dwID)
  for _, tbClass in pairs(self.tbClass) do
    if tbClass.OnLeaveMap then
      tbClass:OnLeaveMap(me)
    end
  end
end
function Decoration:OnCheckChangePos(nId)
  local tbDecoration = self.tbAllDecoration[nId]
  if not tbDecoration then
    return
  end
  Decoration:ClearAllPlayerActState(tbDecoration.nMapId)
  for _, tbClass in pairs(self.tbClass) do
    if tbClass.OnCheckChangePos then
      tbClass:OnCheckChangePos(me, nId)
    end
  end
end
function Decoration:OnCreateClientRep(tbRepInfo, pRep)
  local tbTemplate = self.tbAllTemplate[tbRepInfo.nTemplateId]
  if not tbTemplate then
    return
  end
  local tbClass = self:GetClass(tbTemplate.szType, 1)
  if tbClass then
    if tbClass.OnCreateClientRep then
      tbClass:OnCreateClientRep(tbRepInfo, pRep)
    end
  elseif tbTemplate.szType == "Land" then
    HousePlant:OnCreateRepresent(tbRepInfo.nRepId)
  end
end
function Decoration:OnRepObjSimpleTap(nRepId)
  if House.bDecorationMode then
    return
  end
  local nId, tbRepInfo = self:GetRepInfoByRepId(nRepId)
  if not nId or tbRepInfo.bTest then
    return
  end
  local bRet = self:CanOperation(tbRepInfo, me)
  if not bRet then
    return
  end
  local tbTemplate = self.tbAllTemplate[tbRepInfo.nTemplateId]
  if not tbTemplate then
    return
  end
  local fnOnRepObjSimpleTap = self["OnRepObjSimpleTap_" .. tbTemplate.szSubType]
  if fnOnRepObjSimpleTap then
    fnOnRepObjSimpleTap(self, nId, nRepId, tbRepInfo, tbTemplate)
  else
    local tbClass = self:GetClass(tbTemplate.szType, 1)
    if tbClass then
      if tbClass.OnRepObjSimpleTap then
        tbClass:OnRepObjSimpleTap(nId, nRepId, tbRepInfo)
      end
    elseif tbTemplate.szType == "Land" then
      HousePlant:OnClick(nRepId)
    end
  end
end
