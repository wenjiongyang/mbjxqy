local nScale = 1.5
local nScaleTime = 1
local nBoxNpcId = 208
local nBoxnActId = 16
local nBoxnnActEventId = 5001
local nEffectMoveTime = 1
local nOpenBoxEffect = 9014
local nOpenBoxEffectHeight = 0.5
local AUTOPATH_DISTANCE = 150
local tbGridPos = {
  {207, 217.3},
  {284.5, 217.3},
  {360.9, 217.3},
  {439, 217.3},
  {517.8, 217.3},
  {207, 217.3},
  {284.5, 217.3},
  {360.9, 217.3},
  {439, 217.3},
  {517.8, 217.3}
}
local tbCoinPos = {285.4, 271.4}
local tbUi = Ui:CreateClass("ExplorationFubenPanel")
local tbMapStepSetting = MapExplore.tbMapStepSetting
local MAX_STEP = MapExplore.MAX_STEP
function tbUi:OnOpen(tbGetItemIds)
  self.tbGetItemIds = tbGetItemIds
  self:UpdateItemGroup()
  Ui:OpenWindow("BgBlack")
  self.pPanel:SetActive("wupin_huishou", false)
  self.pPanel:NumberAni_SetNumberDirect("CoinInfo", MapExplore.nTotalCoin, true)
  self:UpdateUi()
  Operation:HideFakeJoystick()
end
function tbUi:UpdateItemGroup()
  local function fnSetItem(itemObj, index)
    local tbItemGrid = itemObj.itemframe
    local nItemId = self.tbGetItemIds[index]
    if nItemId then
      tbItemGrid:SetItemByTemplate(nItemId)
      tbItemGrid.fnClick = tbItemGrid.DefaultClick
    else
      tbItemGrid:Clear()
    end
  end
  self.ItemGroup:Update(MAX_STEP, fnSetItem)
  if #self.tbGetItemIds > 5 then
    self.ItemGroup.pPanel:ScrollViewGoBottom()
  else
    self.ItemGroup.pPanel:ScrollViewGoTop()
  end
end
function tbUi:OnClose()
  if me.GetNpc() then
    local npcRep = Ui.Effect.GetNpcRepresent(me.GetNpc().nId)
    if npcRep then
      npcRep:ShowHeadUI(true)
    end
    Ui:ChangeUiState(0, true)
    Operation:ShowFakeJoystick()
  end
  Ui:CloseWindow("BgBlack")
  UiNotify.OnNotify(UiNotify.emNOTIFY_FUBEN_SECTION_PANEL, "UpdateMapExplore")
end
function tbUi:UpdateUi()
  self.pPanel:ProgressBar_SetValue("ExplorationProgressSlider", MapExplore.nStep / MAX_STEP)
  self.pPanel:Label_SetText("LabelProg", string.format("%d/%d", MapExplore.nStep, MAX_STEP))
  local nDegree = DegreeCtrl:GetDegree(me, "MapExplore")
  self.pPanel:Label_SetText("Degree", nDegree)
  self.pPanel:SetActive("BtnPlus", false)
end
function tbUi:PlayOpenBoxAni(nMoveToX, nMoveToY)
  if not MapExplore.nBoxNpcId then
    MapExplore.bCanMove = true
    return
  end
  local pNpc = KNpc.GetById(MapExplore.nBoxNpcId)
  if pNpc then
    pNpc.DoCommonAct(nBoxnActId, nBoxnnActEventId, 1)
    Timer:Register(Env.GAME_FPS * 2, function()
      local pNpc = KNpc.GetById(MapExplore.nBoxNpcId)
      if pNpc and pNpc.nStep == MapExplore.nStep then
        pNpc.Delete()
        MapExplore.nBoxNpcId = nil
      end
    end)
  else
    MapExplore.bCanMove = true
    return
  end
  if nMoveToX and nMoveToY then
    local _, nX, nY = pNpc.GetWorldPos()
    Ui.Effect.PlayEffect(nOpenBoxEffect, nX, nY, nOpenBoxEffectHeight)
    local tbPos = Ui.Effect.GetNpcScreenPosToUi(MapExplore.nBoxNpcId)
    self.pPanel:SetActive("wupin_huishou", true)
    self.pPanel:Tween_RunFromTo("wupin_huishou", tbPos.x, tbPos.y, nMoveToX, nMoveToY, nEffectMoveTime)
  end
end
function tbUi:PlayerAniGetItem(nItemId)
  local tbBaseInfo = KItem.GetItemBaseProp(nItemId)
  me.CenterMsg(string.format("获得了%s", tbBaseInfo.szName))
  self:PlayOpenBoxAni(unpack(tbGridPos[#self.tbGetItemIds + 1]))
  function self.fnUiCallBack()
    self:OnEndPlayerAniGetItem(nItemId)
  end
end
function tbUi:OnEndPlayerAniGetItem(nItemId)
  table.insert(self.tbGetItemIds, nItemId)
  self:UpdateItemGroup()
  self.pPanel:SetActive("wupin_huishou", false)
  MapExplore.bCanMove = true
end
function tbUi:PlayerAniGetCoin(nCoin)
  me.CenterMsg(string.format("获得了%d银两", nCoin))
  self:PlayOpenBoxAni(unpack(tbCoinPos))
  function self.fnUiCallBack()
    self:OnEndPlayerAniGetCoin(nCoin)
  end
end
function tbUi:OnEndPlayerAniGetCoin(nCoin)
  self.pPanel:SetActive("wupin_huishou", false)
  MapExplore.nTotalCoin = MapExplore.nTotalCoin + nCoin
  self.pPanel:NumberAni_SetNumber("CoinInfo", MapExplore.nTotalCoin, true)
  MapExplore.bCanMove = true
end
function tbUi:OnEndFindNothing()
  self:PlayOpenBoxAni()
  me.CenterMsg("什么都没发现！")
  MapExplore.bCanMove = true
end
function tbUi:OnNotify(szFunc, ...)
  if not self[szFunc] then
    return
  end
  self[szFunc](self, ...)
end
tbUi.tbOnClick = {}
function tbUi.tbOnClick:BtnExploration()
  if not MapExplore.bMapLoaded then
    return
  end
  if not MapExplore.bCanMove then
    if not MapExplore.nSerCallBackCalledTime and Ui:WindowVisible("MeetEnemyPanel") ~= 1 and GetTime() - 5 >= MapExplore.nRequestTime then
      MapExplore.bCanMove = true
    elseif MapExplore.nSerCallBackCalledTime and GetTime() - 5 >= MapExplore.nSerCallBackCalledTime then
      MapExplore.bCanMove = true
    else
      return
    end
  end
  if MapExplore.nStep >= MapExplore.MAX_STEP then
    me.CenterMsg("当前地图已经探索完了")
    return
  end
  if not MapExplore:CheckTimes() then
    return
  end
  local tbNextPos = tbMapStepSetting[MapExplore.nMapTemplateId][MapExplore.nStep + 2]
  Ui("BgBlack"):Scale(1, 1, nScaleTime)
  MapExplore.bCanMove = false
  MapExplore.nSerCallBackCalledTime = nil
  MapExplore.nRequestTime = GetTime()
  RemoteServer.MapExploreMove(MapExplore.nMapTemplateId, MapExplore.nStep)
  local function fnCallBack()
    Ui("BgBlack"):Scale(nScale, nScale, nScaleTime)
    MapExplore:OnWalkEnd()
    self:UpdateUi()
  end
  AutoPath:GotoAndCall(MapExplore.nMapTemplateId, tbNextPos[1], tbNextPos[2], fnCallBack, AUTOPATH_DISTANCE)
end
function tbUi.tbOnClick:BtnLeaveFuben()
  MapExplore:RequestLeave()
end
function tbUi.tbOnClick:BtnPlus()
  me.BuyTimes("MapExplore", 5)
end
tbUi.tbOnCallBack = {}
function tbUi.tbOnCallBack:Main()
  if self.fnUiCallBack then
    self.fnUiCallBack()
    self.fnUiCallBack = nil
  end
end
function tbUi:RegisterEvent()
  return {
    {
      UiNotify.emNOTIFY_MAP_EXPLORE_PANEL,
      self.OnNotify
    },
    {
      UiNotify.emNOTIFY_BUY_DEGREE_SUCCESS,
      self.UpdateUi
    }
  }
end
