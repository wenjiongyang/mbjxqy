local tbItem = Item:GetClass("ComposeMeterial");

function tbItem:GetTip(it)
	if not it.dwId then
		return "";
	end
	return Compose.EntityCompose:GetTip(it);
end

function tbItem:GetIntroBottom(nTemplateId)
	if Compose.EntityCompose:IsNeedConsume(nTemplateId) then
		local szConsumeType,nConsumeCount = Compose.EntityCompose:GetConsumeInfo(nTemplateId);
		local _, szMoneyEmotion = Shop:GetMoneyName(szConsumeType)
		return string.format("合成消耗 %s %d", szMoneyEmotion, nConsumeCount);
	end
end

function tbItem:GetIntrol(nTemplateId, nItemId)
	local nSumPrice, szMoneyType = Shop:GetSellSumPrice(me, nTemplateId, 1)
	local tbItemBase = KItem.GetItemBaseProp(nTemplateId)
	if nSumPrice then
		local _, szMoneyEmotion = Shop:GetMoneyName(szMoneyType)
		return  string.format("%s\n\n\n[73cbd5]出售可獲得：%s%d[-]", tbItemBase.szIntro, szMoneyEmotion, nSumPrice)
	end
	return tbItemBase.szIntro
end

function tbItem:GetUseSetting(nTemplateId, nItemId)

	local nTargetTemplate = Compose.EntityCompose.tbChildInfo[nTemplateId];
	local tbItemBase = KItem.GetItemBaseProp(nTargetTemplate);
	if not Compose.EntityCompose:CheckIsCanCompose(me, nTemplateId) then--and tbItemBase.szClass == "horse_equip" then
		local fnPreview = function ()
			local tbInfo = {};
			tbInfo.nTemplate = nTargetTemplate
			tbInfo.nFaction = me.nFaction;
			Item:ShowItemDetail(tbInfo);
		end
		if Shop:CanSellWare(me, nItemId, 1) then
			return {szFirstName = "出售", fnFirst = "SellItem", szSecondName = "預覽", fnSecond = fnPreview};
		end
		return {szFirstName = "預覽", fnFirst = fnPreview};
	else
		if Shop:CanSellWare(me, nItemId, 1) then
			return {szFirstName = "出售", fnFirst = "SellItem", szSecondName = "合成", fnSecond = "ComposeEntityItem"};
		end
		return {szFirstName = "合成", fnFirst = "ComposeEntityItem"};
	end
end

local EquipMeterial = Item:NewClass("EquipMeterial", "ComposeMeterial");	-- 派生，一定要放在最后
function EquipMeterial:GetIntrol(nTemplateId, nItemId)
	local nSumPrice, szMoneyType = Shop:GetSellSumPrice(me, nTemplateId, 1)
	local tbItemBase = KItem.GetItemBaseProp(nTemplateId)
	local szSellIntro = "";
	local szTimeFrameIntro = "";
	if nSumPrice then
		local _, szMoneyEmotion = Shop:GetMoneyName(szMoneyType)
		szSellIntro = string.format("\n\n\n[73cbd5]出售可獲得：%s%d[-]", szMoneyEmotion, nSumPrice)
	end
	local nTargerItemId, nComposeNum = Compose.EntityCompose:GetEquipComposeInfo(nTemplateId)	
	local tbItemBaseTar = KItem.GetItemBaseProp(nTargerItemId)
	if tbItemBaseTar.szClass == "horse_equip" then
		--坐骑装备碎片 ，获取其合成的，然后看对应时间轴到了而且看其消耗材料里有没有这个
		local TarItemEvo = Item.GoldEquip:CanEvolutionTarItem(nTargerItemId)
		if TarItemEvo then
			local tbItemBaseTarItemEvo = KItem.GetItemBaseProp(TarItemEvo)
			szTimeFrameIntro = string.format("\n\n可作為升到[FFFE0D]%d階%s[-]的材料", tbItemBaseTarItemEvo.nLevel, tbItemBaseTarItemEvo.szName) 
		end
	end
	return string.format("%s%s%s", tbItemBase.szIntro, szTimeFrameIntro, szSellIntro) 
end