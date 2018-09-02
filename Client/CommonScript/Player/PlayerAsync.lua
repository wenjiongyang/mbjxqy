function PlayerAsync:OnCreateNpc(pPlayerAsync, pNpc)
  local nLightID = pPlayerAsync.GetOpenLight()
  local nFactionID = pPlayerAsync.GetFaction()
  if nLightID > 0 then
    local tbLightInfo = OpenLight:GetLightSetting(nLightID)
    if tbLightInfo then
      pNpc.ApplyExternAttrib(OpenLight.nExtAttribGroupID, tbLightInfo.ExtAttribLevel)
      local nEffectResId = OpenLight:GetFactionEffect(tbLightInfo.EffectID, nFactionID)
      pNpc.ModifyPartFeatureEquip(Npc.NpcResPartsDef.npc_part_weapon, nEffectResId, Npc.NpcPartLayerDef.npc_part_layer_effect)
    end
  end
  for i = 1, 10 do
    local nVal = pPlayerAsync.GetSuit(i)
    if nVal ~= 0 then
      local AttribGroup = math.floor(nVal / 100)
      local AttribLevel = nVal % 100
      pNpc.ApplyExternAttrib(AttribGroup, AttribLevel)
    else
      break
    end
  end
  Lib:CallBack({
    JingMai.UpdateAsyncPlayerAttrib,
    JingMai,
    pPlayerAsync,
    pNpc
  })
  PlayerAttribute:UpdateAsyncPlayerAllAttrib(pPlayerAsync, pNpc)
  pNpc.RestoreHP()
end
