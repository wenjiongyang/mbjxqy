ViewRole.tbAllRole = {}
ViewRole.tbAllRoleId = {}
ViewRole.MAX_SAVE_ROLE_NUM = 30
ViewRole.UPDATE_TIME_CD = 600
function ViewRole:GetRoleInfoById(dwRoleId)
  local tbRole = self.tbAllRole[dwRoleId]
  if not tbRole then
    return
  end
  if GetTime() - tbRole.nUpdateTime > self.UPDATE_TIME_CD then
    return
  end
  return tbRole
end
function ViewRole:OpenWindow(szWnd, dwRoleId, ...)
  local tbArgs = {
    ...
  }
  local tbEquip, tbNpcRes, tbPartnerInfo, pAsyncRole = self:GetCurResInfo(dwRoleId, szWnd)
  if not tbEquip then
    self.szWaitWnd = szWnd
    function self.fWaitCallback()
      ViewRole:OpenWindow(szWnd, dwRoleId, unpack(tbArgs))
    end
    return
  end
  Ui:OpenWindow(szWnd, tbEquip, tbNpcRes, tbPartnerInfo, pAsyncRole, ...)
end
function ViewRole:OpenWindowWithFaction(szWnd, nFaction, ...)
  local pAsyncRole = {}
  function pAsyncRole.GetFaction()
    return nFaction
  end
  local tbNpcRes = {}
  local tbPlayerInfo = KPlayer.GetPlayerInitInfo(nFaction)
  tbNpcRes[0] = tbPlayerInfo.nBodyResId
  tbNpcRes[1] = tbPlayerInfo.nWeaponResId
  Ui:OpenWindow(szWnd, {}, tbNpcRes, {}, pAsyncRole, ...)
end
function ViewRole:OpenWindowWithNpcResId(szWnd, nNpcResId, szActName, ...)
  local pAsyncRole = {}
  function pAsyncRole.GetActName()
    return szActName
  end
  local tbNpcRes = {}
  tbNpcRes[0] = nNpcResId
  Ui:OpenWindow(szWnd, {}, tbNpcRes, {}, pAsyncRole, ...)
end
function ViewRole:OnGetSyncData(tbRole)
  if not tbRole then
    return
  end
  local dwRoleId = tbRole.dwID
  tbRole.nUpdateTime = GetTime()
  if #self.tbAllRoleId >= self.MAX_SAVE_ROLE_NUM then
    local dwRoleId = table.remove(self.tbAllRoleId, 1)
    self.tbAllRole[dwRoleId] = nil
  end
  self.tbAllRole[dwRoleId] = tbRole
  table.insert(self.tbAllRoleId, dwRoleId)
  if not self.szWaitWnd or Ui:WindowVisible(self.szWaitWnd) then
    return
  end
  local pAsyncRole = KPlayer.GetAsyncData(dwRoleId)
  if not pAsyncRole then
    return
  end
  if self.fWaitCallback then
    self.fWaitCallback()
    self.fWaitCallback = nil
    self.szWaitWnd = nil
  end
end
function ViewRole:GetCurResInfo(dwRoleId, szWnd)
  local pAsyncRole = KPlayer.GetAsyncData(dwRoleId)
  local tbRole = self:GetRoleInfoById(dwRoleId)
  if not pAsyncRole or not tbRole then
    RemoteServer.ViewPlayerInfo(dwRoleId, szWnd)
    return
  end
  pAsyncRole.tbRoleInfo = tbRole
  if self.dwRoleId then
    KPlayer.CloseAsyncData(self.dwRoleId)
    self.pAsyncRole = nil
    self.dwRoleId = nil
  end
  local tbEquip, tbNpcRes, tbPartnerInfo = KPlayer.ViewAsyncData(dwRoleId)
  self.tbEquip = tbEquip
  self.tbNpcRes = tbNpcRes
  self.tbPartnerInfo = tbPartnerInfo
  if tbEquip then
    local tbActiedSuitIndex = {}
    for k, v in pairs(tbEquip) do
      local pEquip = KItem.GetItemObj(v)
      if pEquip then
        local tbSetting = Item.GoldEquip:GetSuitSetting(pEquip.dwTemplateId)
        if tbSetting then
          tbActiedSuitIndex[tbSetting.SuitIndex] = (tbActiedSuitIndex[tbSetting.SuitIndex] or 0) + 1
        end
      end
    end
    pAsyncRole.tbActiedSuitIndex = tbActiedSuitIndex
    self.dwRoleId = dwRoleId
    local nFaction = pAsyncRole.GetFaction()
    local tbPlayerInfo = KPlayer.GetPlayerInitInfo(nFaction)
    if not tbNpcRes[0] or tbNpcRes[0] == 0 then
      tbNpcRes[0] = tbPlayerInfo.nBodyResId
    end
    if not tbNpcRes[1] or tbNpcRes[1] == 0 then
      tbNpcRes[1] = tbPlayerInfo.nWeaponResId
    end
    return tbEquip, tbNpcRes, tbPartnerInfo, pAsyncRole
  end
end
function ViewRole:GetScale(tbParent)
  if tbParent.nScale then
    return tbParent.nScale
  end
  local tbSceenszie = tbParent.pPanel:Panel_GetSize("Main")
  if tbSceenszie.y == 0 then
    tbParent.nScale = 0.45
  else
    tbParent.nScale = 0.22456140350877202 * (tbSceenszie.x / tbSceenszie.y - 1.7786458333333333) + 0.45
  end
  return tbParent.nScale
end
