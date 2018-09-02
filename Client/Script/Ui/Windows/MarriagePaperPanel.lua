local tbUi = Ui:CreateClass("MarriagePaperPanel")
local NpcViewMgr = luanet.import_type("NpcViewMgr")
tbUi.tbOnClick = {
  BtnClose = function(self)
    Ui:CloseWindow(self.UI_NAME)
  end,
  BtnVideo = function(self)
    local nLoveId = Wedding:GetLover(me.dwID)
    if not nLoveId then
      me.CenterMsg("没有录像数据", true)
      return
    end
    RemoteServer.OnWeddingRequest("ReplayWedding")
  end
}
tbUi.tbSettings = {
  tbPosDirs = {
    {
      -60,
      -32,
      -100,
      0,
      180,
      0
    },
    {
      138.07,
      -32,
      -100,
      0,
      180,
      0
    }
  },
  tbLevelNpcIds = {
    {601, 602},
    {590, 603},
    {591, 604}
  }
}
function tbUi:OnClickLinkNpc(nNpcTemplateId, nMapTemplateId)
  Ui:CloseWindow(self.UI_NAME)
end
function tbUi:RegisterEvent()
  return {
    {
      UiNotify.emNOTIFY_LOAD_RES_FINISH,
      self.LoadBodyFinish
    },
    {
      UiNotify.emNOTIFY_WND_OPENED,
      self.OnWndOpened
    },
    {
      UiNotify.emNOTIFY_WND_CLOSED,
      self.OnWndClosed
    },
    {
      UiNotify.emNOTIFY_CLICK_LINK_NPC,
      self.OnClickLinkNpc
    }
  }
end
tbUi.tbHideWnds = {GeneralHelpPanel = true, MapLoading = true}
function tbUi:OnWndOpened(szWndName)
  if not self.tbHideWnds[szWndName] then
    return
  end
  self:SetModelsVisible(false)
end
function tbUi:OnWndClosed(szWndName)
  if not self.tbHideWnds[szWndName] then
    return
  end
  self:SetModelsVisible(true)
end
function tbUi:OnOpen(nItemTemplateId, nItemId)
  local pItem = KItem.GetItemObj(nItemId)
  if not pItem then
    Log("[x] MarriagePaperPanel:OnOpen item nil", nItemTemplateId, nItemId)
    return
  end
  local szHusbandName = pItem.GetStrValue(Wedding.nMPHusbandNameIdx)
  local szWifeName = pItem.GetStrValue(Wedding.nMPWifeNameIdx)
  local szHusbandPledge = pItem.GetStrValue(Wedding.nMPHusbandPledgeIdx)
  local szWifePledge = pItem.GetStrValue(Wedding.nMPWifePledgeIdx)
  local nTimestamp = pItem.GetIntValue(Wedding.nMPTimestamp)
  self.pPanel:SetActive("BtnVideo", true)
  self.pPanel:Label_SetText("Name1", szHusbandName)
  self.pPanel:Label_SetText("Name2", szWifeName)
  self.pPanel:Label_SetText("Declaration1", szHusbandPledge)
  self.pPanel:Label_SetText("Declaration2", szWifePledge)
  self.pPanel:Label_SetText("Time", string.format("成婚时间：%s，已成婚[FFFE0D]%d天[-]", Lib:TimeDesc11(nTimestamp), Lib:SecondsToDays(GetTime() - nTimestamp) + 1))
  local nNow = GetTime()
  local nCurMaxMonth = Wedding:GetMaxMemorialMonth(nTimestamp, nNow)
  local nCfgMaxMonth = Wedding:GetMemorialCfgMaxMonth()
  local szNextMemorialDay, nMemorialTime
  for i = nCurMaxMonth, nCfgMaxMonth do
    if Wedding.tbMemorialMonthRewards[i] then
      local nGuessTimestamp = nTimestamp + 2419200 * i
      local nGuessMaxTimestamp = nTimestamp + 2678400 * i
      for nTmpTime = nGuessTimestamp, nGuessMaxTimestamp, 86400 do
        if Wedding:GetMaxMemorialMonth(nTimestamp, nTmpTime) == i then
          szNextMemorialDay = Lib:TimeDesc11(nTmpTime)
          nMemorialTime = nTmpTime
          break
        end
      end
      break
    end
  end
  local szTips = szNextMemorialDay and Lib:GetLocalDay(nNow) <= Lib:GetLocalDay(nMemorialTime) and string.format("下个纪念日：%s [00FF00][url=openwnd:纪念日奖励, GeneralHelpPanel, 'MarriageMDHelp'][-]", szNextMemorialDay) or "下个纪念日：你们已经是老夫老妻了，祝恩爱百年！"
  self.Time1:SetLinkText(szTips)
  local nLevel = pItem.GetIntValue(Wedding.nMPLevel)
  self:ShowModels(nLevel)
end
function tbUi:SetModelsVisible(bVisible)
  self.tbViewModelIds = self.tbViewModelIds or {}
  for _, v in ipairs(self.tbViewModelIds) do
    NpcViewMgr.SetUiViewFeatureActive(v, bVisible)
  end
end
function tbUi:ShowModels(nLevel)
  self.tbViewModelIds = self.tbViewModelIds or {}
  if #self.tbViewModelIds > 0 then
    self:SetModelsVisible(true)
    return
  end
  for i = 1, 2 do
    local nX, nY, nZ, rX, rY, rZ = unpack(self.tbSettings.tbPosDirs[i])
    local nShowId = self.tbViewModelIds[i]
    if nShowId then
      NpcViewMgr.SetUiViewFeatureActive(nShowId, true)
      NpcViewMgr.SetModePos(nShowId, nX, nY, nZ)
      NpcViewMgr.ChangeAllDir(nShowId, rX, rY, rZ, false)
    else
      nShowId = NpcViewMgr.CreateUiViewFeature(nX, nY, nZ, rX, rY, rZ)
      self.tbViewModelIds[i] = nShowId
    end
    NpcViewMgr.ScaleModel(nShowId, 1)
    local nNpcId = self.tbSettings.tbLevelNpcIds[nLevel][i]
    NpcViewMgr.ChangePartBody(nShowId, nNpcId, true)
  end
end
function tbUi:LoadBodyFinish(nViewId)
  NpcViewMgr.ScaleModel(nViewId, ViewRole:GetScale(self))
end
function tbUi:OnClose()
  self:SetModelsVisible(false)
end
function tbUi:OnDestroyUi()
  for _, v in ipairs(self.tbViewModelIds or {}) do
    NpcViewMgr.DestroyUiViewFeature(v)
  end
end
