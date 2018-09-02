local tbUi = Ui:CreateClass("NewInfo_WLDHChampionship")
local NpcViewMgr = luanet.import_type("NpcViewMgr")
local RepresentSetting = luanet.import_type("RepresentSetting")
tbUi.tbHeightToY = {
  {2, 314},
  {1.6, 228.46}
}
tbUi.tbPos = {
  [1] = {
    {
      tbLevelUi = {87.7, -221},
      Role = {
        113.84,
        -188.5,
        100,
        0,
        180,
        0
      }
    }
  },
  [2] = {
    {
      tbLevelUi = {-70.5, -221},
      Role = {
        -39.3,
        -188.5,
        100,
        0,
        180,
        0
      }
    },
    {
      tbLevelUi = {248.44, -221},
      Role = {
        270.52,
        -188.5,
        100,
        0,
        180,
        0
      }
    }
  },
  [3] = {
    {
      tbLevelUi = {-133.5, -221},
      Role = {
        -122.5,
        -188.5,
        100,
        0,
        180,
        0
      }
    },
    {
      tbLevelUi = {91, -221},
      Role = {
        112.4,
        -188.5,
        100,
        0,
        180,
        0
      }
    },
    {
      tbLevelUi = {317.2, -221},
      Role = {
        350,
        -188.5,
        100,
        0,
        180,
        0
      }
    }
  },
  [4] = {
    {
      tbLevelUi = {-175.1, -221},
      Role = {
        -149.2,
        -188.5,
        100,
        0,
        180,
        0
      }
    },
    {
      tbLevelUi = {-13.1, -221},
      Role = {
        2.6,
        -188.5,
        100,
        0,
        180,
        0
      }
    },
    {
      tbLevelUi = {159.3, -221},
      Role = {
        173.5,
        -188.5,
        100,
        0,
        180,
        0
      }
    },
    {
      tbLevelUi = {332.4, -221},
      Role = {
        358.1,
        -188.5,
        100,
        0,
        180,
        0
      }
    }
  }
}
tbUi.tbTabBtns = {
  "BtnDoublesManMatch",
  "BtnThreeManMatch",
  "BtnThreeManDuel",
  "BtnFourManMatch"
}
function tbUi:OnCreate()
  self.tbViewModelIds = {}
end
function tbUi:GetScale()
  if self.nScale then
    return self.nScale
  end
  local tbParent = Ui("NewInformationPanel")
  local tbSceenszie = tbParent.pPanel:Panel_GetSize("Main")
  if tbSceenszie.y == 0 then
    self.nScale = 0.45
  else
    self.nScale = 0.22456140350877202 * (tbSceenszie.x / tbSceenszie.y - 1.7786458333333333) + 0.45
  end
  return self.nScale
end
function tbUi:GetCurSelGameType()
  local nSelType
  for i, v in ipairs(self.tbTabBtns) do
    if self.pPanel:Toggle_GetChecked(v) then
      nSelType = i
      break
    end
  end
  if not nSelType then
    for i, v in pairs(self.tbData) do
      nSelType = i
      break
    end
    self.pPanel:Toggle_SetChecked(self.tbTabBtns[nSelType], true)
  end
  return nSelType
end
function tbUi:OnOpen(tbData)
  self.tbData = tbData
  for i, v in ipairs(self.tbTabBtns) do
    if not tbData[i] then
      self.pPanel:Toggle_SetChecked(v, false)
      self.pPanel:SetActive(v, false)
    else
      self.pPanel:SetActive(v, true)
    end
  end
  self:Update()
end
function tbUi:Update()
  local nSelGameType = self:GetCurSelGameType()
  local tbSelData = self.tbData[nSelGameType]
  local tbGameFormat = WuLinDaHui.tbGameFormat[nSelGameType]
  local nFightTeamCount = tbGameFormat.tbGameFormat
  self.pPanel:Label_SetText("WLDHInformation", string.format("恭喜来自[FFFE0D]%s[-]的[FFFE0D]%s[-]战队获得了本届武林大会[FFFE0D]%s[-]冠军！", tbSelData.szServerName, tbSelData.szTeamName, tbGameFormat.szName))
  local tbPlayerViewInfo = tbSelData.tbPlayerViewInfo
  local tbPlayerIds = {}
  for k, v in pairs(tbPlayerViewInfo) do
    table.insert(tbPlayerIds, k)
  end
  local tbPosSettingGroup = self.tbPos[#tbPlayerIds]
  for i = 1, 4 do
    local nPlayerId = tbPlayerIds[i]
    if nPlayerId then
      local tbPlayerInfo = tbPlayerViewInfo[nPlayerId]
      local tbPosSetting = tbPosSettingGroup[i]
      local tbLevelUiPos = tbPosSetting.tbLevelUi
      local nFaction = tbPlayerInfo.nFaction
      self.pPanel:SetActive("Fagtion" .. i, true)
      self.pPanel:ChangePosition("Fagtion" .. i, tbLevelUiPos[1], tbLevelUiPos[2])
      local SpFaction = Faction:GetIcon(nFaction)
      self.pPanel:Sprite_SetSprite("Fagtion" .. i, SpFaction)
      self.pPanel:Label_SetText("Level" .. i, tbPlayerInfo.nLevel .. "级")
      self.pPanel:Label_SetText("Fighting" .. i, string.format("战力：%d", tbPlayerInfo.nFightPower))
      self.pPanel:Label_SetText("FamilyName" .. i, Lib:IsEmptyStr(tbPlayerInfo.szKinName) and "" or tbPlayerInfo.szKinName)
      local nHonorLevel = tbPlayerInfo.nHonorLevel
      local tbHonorInfo = Player.tbHonorLevelSetting[nHonorLevel]
      if tbHonorInfo then
        self.pPanel:SetActive("PlayerTitle" .. i, true)
        self.pPanel:Sprite_Animation("PlayerTitle" .. i, tbHonorInfo.ImgPrefix)
      else
        self.pPanel:SetActive("PlayerTitle" .. i, false)
      end
      self.pPanel:Label_SetText("PlayerName" .. i, tbPlayerInfo.szName)
      local nX, nY, nZ, rX, rY, rZ = unpack(tbPosSetting.Role)
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
      local tbPlayerInitInfo = KPlayer.GetPlayerInitInfo(nFaction)
      local nNpcTemplateId = tbPlayerInitInfo.nNpcTemplateId
      local _, nNpcResId = KNpc.GetNpcShowInfo(nNpcTemplateId)
      local NpcRes = RepresentSetting.GetNpcRes(nNpcResId)
      local fNpcHeight = NpcRes.m_fHeight
      local tbPos = self.pPanel:GetPosition("PlayerName" .. i)
      local nSetY = Lib.Calc:Link(fNpcHeight, self.tbHeightToY, true)
      self.pPanel:ChangePosition("PlayerName" .. i, tbPos.x, nSetY)
      local tbNpcRes = {}
      local tbItems = tbPlayerInfo.tbItems
      if not tbItems then
        tbNpcRes[Npc.NpcResPartsDef.npc_part_body] = tbPlayerInitInfo.nBodyResId
        tbNpcRes[Npc.NpcResPartsDef.npc_part_weapon] = tbPlayerInitInfo.nWeaponResId
      else
        local dwTemplateId = tbItems[Item.EQUIPPOS_BODY]
        if dwTemplateId then
          local _, _, _, _, nResId = KItem.GetItemShowInfo(dwTemplateId, nFaction)
          tbNpcRes[Npc.NpcResPartsDef.npc_part_body] = nResId
        end
        local dwTemplateId = tbItems[Item.EQUIPPOS_WEAPON]
        if dwTemplateId then
          local _, _, _, _, nResId = KItem.GetItemShowInfo(dwTemplateId, nFaction)
          tbNpcRes[Npc.NpcResPartsDef.npc_part_weapon] = nResId
        end
        local dwTemplateId = tbItems[Item.EQUIPPOS_WAIYI]
        if dwTemplateId then
          tbNpcRes[Npc.NpcResPartsDef.npc_part_body] = Item.tbChangeColor:GetWaiZhuanRes(dwTemplateId, nFaction)
        end
        local dwTemplateId = tbItems[Item.EQUIPPOS_WAI_WEAPON]
        if dwTemplateId then
          tbNpcRes[Npc.NpcResPartsDef.npc_part_weapon] = Item.tbChangeColor:GetWaiZhuanRes(dwTemplateId, nFaction)
        end
      end
      local nPartId = Npc.NpcResPartsDef.npc_part_weapon
      local nResId = tbNpcRes[nPartId]
      if nResId then
        NpcViewMgr.ChangeNpcPart(nShowId, nPartId, nResId)
      end
      local nPartId = Npc.NpcResPartsDef.npc_part_body
      local nResId = tbNpcRes[nPartId]
      if nResId then
        NpcViewMgr.ChangePartBody(nShowId, nResId)
      end
    else
      self.pPanel:SetActive("Fagtion" .. i, false)
      local nShowId = self.tbViewModelIds[i]
      if nShowId then
        NpcViewMgr.SetUiViewFeatureActive(nShowId, false)
      end
    end
  end
end
function tbUi:CheckIsMyView(nViewId)
  for _, nId in pairs(self.tbViewModelIds or {}) do
    if nViewId == nId then
      return true
    end
  end
end
function tbUi:LoadBodyFinish(nViewId)
  if not self:CheckIsMyView(nViewId) then
    return
  end
  Timer:Register(1, function()
    NpcViewMgr.ScaleModel(nViewId, self:GetScale())
  end)
  NpcViewMgr.PlayAnimation(nViewId, "st", 0, 2, 1)
  NpcViewMgr.AddEffectRendQueToNode(nViewId, "NewInformationPanel", "Content/WLDHChampionship/Sprite")
end
function tbUi:OnClose()
  for i, v in ipairs(self.tbViewModelIds) do
    NpcViewMgr.SetUiViewFeatureActive(v, false)
  end
end
function tbUi:OnDestroyUi()
  for i, v in ipairs(self.tbViewModelIds) do
    NpcViewMgr.DestroyUiViewFeature(v)
  end
end
tbUi.tbOnClick = {}
for i, szBtnName in ipairs(tbUi.tbTabBtns) do
  tbUi.tbOnClick[szBtnName] = function(self)
    self:Update()
  end
end
