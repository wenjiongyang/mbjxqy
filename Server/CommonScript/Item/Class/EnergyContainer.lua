local tbItem = Item:GetClass("EnergyContainer");
function tbItem:OnUse(it)
	local nItemTemplateId = tonumber(KItem.GetItemExtParam(it.dwTemplateId, 1))
	assert(nItemTemplateId, "illegal param: " .. it.dwTemplateId);

	local tbItemInfo = KItem.GetItemBaseProp(nItemTemplateId);
	if not tbItemInfo or tbItemInfo.szClass ~= "EnergyItem" then
		me.CenterMsg("道具異常！");
		return;
	end

	local nEnergy = math.floor(tonumber(KItem.GetItemExtParam(nItemTemplateId, 1)));
	if nEnergy <= 0 then
		me.CenterMsg("道具異常！");
		return;
	end

	if me.GetMoney("Energy") < nEnergy then
		me.CenterMsg("元氣不足");
		return;
	end

	if me.CheckNeedArrangeBag() then
		me.CenterMsg("背包道具數量過多，請整理一下！");
		return;
	end

	if not me.CostMoney("Energy", nEnergy, Env.LogWay_UseEnergyContainer) then
		me.CenterMsg("扣除元氣失敗");
		return;
	end

	me.SendAward({{"item", nItemTemplateId, 1}}, true, true, Env.LogWay_UseEnergyContainer);

	Log("[EnergyContainer] OnUse ", it.dwTemplateId, "==>", nItemTemplateId);

	return 1;
end