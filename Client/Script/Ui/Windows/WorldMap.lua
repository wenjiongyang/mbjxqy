local tbUi = Ui:CreateClass("WorldMap")
local tbWorldMapSetting = {
  Birthplace = {999},
  yewai_10_1 = {400},
  yewai_10_2 = {401},
  yewai_10_3 = {402},
  yewai_20_1 = {403},
  yewai_20_2 = {404},
  yewai_20_3 = {405},
  City = {10},
  yewai_40_1 = {406},
  yewai_40_2 = {407},
  yewai_40_3 = {408},
  yewai_40_pvp = {409},
  yewai_50_pvp = {419},
  yewai_70_pvp = {420},
  yewai_60_1 = {410},
  yewai_60_2 = {411},
  yewai_60_3 = {412},
  yewai_80_1 = {413},
  yewai_80_2 = {414},
  yewai_80_3 = {415},
  yewai_100_1 = {416},
  yewai_100_2 = {417},
  yewai_100_3 = {418},
  yewai_90_pvp = {421},
  yewai_110_pvp = {422}
}
function tbUi:OnOpen()
  for key, tbInfo in pairs(tbWorldMapSetting) do
    local nMapTemplateId = tbInfo[1]
    local bTimeOpen = Map:IsTimeFrameOpen(nMapTemplateId)
    local nMapLevel = Map:GetEnterLevel(nMapTemplateId)
    self[key].pPanel:SetActive("CurrentLocation", me.nMapTemplateId == nMapTemplateId)
    self[key].pPanel:SetActive("NotOpen", nMapLevel > me.nLevel or not bTimeOpen)
    self[key].pPanel:Button_SetText("Main", Map:GetMapDesc(nMapTemplateId))
  end
end
tbUi.tbOnClick = {}
function tbUi.tbOnClick:BtnClose()
  Guide.tbNotifyGuide:ClearNotifyGuide("WorldMap")
  Ui:CloseWindow("WorldMap")
end
function tbUi.tbOnClick:WorldMapBg()
  Guide.tbNotifyGuide:ClearNotifyGuide("WorldMap")
end
local function fnTouchItem(panel, szBtnName)
  local nMapTemplateId = tbWorldMapSetting[szBtnName][1]
  if me.nMapTemplateId == nMapTemplateId then
    Ui:OpenWindow("MiniMap", me.nMapTemplateId)
  else
    local nMapLevel = Map:GetEnterLevel(nMapTemplateId)
    if nMapLevel > me.nLevel then
      me.CenterMsg(string.format("达到%d级才可进入该地图", nMapLevel))
      return
    end
    if not Map:IsTimeFrameOpen(nMapTemplateId) then
      me.CenterMsg("当前地图尚未开放")
      return
    end
    if AutoFight:IsAuto() then
      AutoFight:StopAll()
      Timer:Register(Env.GAME_FPS * 1.3, function()
        Map:SwitchMap(nMapTemplateId)
      end)
    else
      Map:SwitchMap(nMapTemplateId)
    end
  end
  Guide.tbNotifyGuide:ClearNotifyGuide("WorldMap")
  Ui:CloseWindow("WorldMap")
end
for key, _ in pairs(tbWorldMapSetting) do
  tbUi.tbOnClick[key] = fnTouchItem
end
