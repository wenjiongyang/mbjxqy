Require("CommonScript/Item/Class/Equip.lua")

local tbHorse = Item:GetClass("horse");
local tbEquip = Item:GetClass("equip");

local tbExtip = 
{
	[2400] = {"OpenLevel69", "(開啟79級上限後，可進階到70級坐騎)"},
	[3012] = {"OpenLevel89", "(開啟99級上限後，可進階到90級坐騎)"},
}

    
function tbHorse:FormatTips(nTemplateId, pEquip)
	local tbNormal = {};
	local tbRider = {};

	local tbAttrib = KItem.GetEquipBaseProp(nTemplateId).tbBaseAttrib;
	local tbBaseProp = KItem.GetItemBaseProp(nTemplateId)

	if not tbAttrib then
		return szTips;
	end
	
	table.insert(tbNormal, {"", 1});	

	for i, tbMA in ipairs(tbAttrib) do
		local szDesc = tbEquip:GetMagicAttribDesc(tbMA.szName, tbMA.tbValue, 0);
		if (szDesc and szDesc ~= "") then
			if tbMA.nActiveReq == Item.emEquipActiveReq_Ride then
				table.insert(tbRider, {szDesc, 1})
				
			else
				table.insert(tbNormal, {szDesc, 1})
			end
		end
	end
	
	if #tbRider > 0 then
		table.insert(tbNormal, {"上馬後啟動"})
		Lib:MergeTable(tbNormal, tbRider)
	end
	
	local szTips = self:GetHorseEnhanceTips(nTemplateId);
	if szTips then
		table.insert(tbNormal, {"", 1});	
		table.insert(tbNormal, {szTips, 2});
	end


	if pEquip and pEquip.GetIntValue(-9996) > 0 then
		table.insert(tbNormal, {"有效期"})
		table.insert(tbNormal, {os.date("%Y年%m月%d日 %H:%M:%S", pEquip.GetIntValue(-9996)), 1})
	end

	return tbNormal, tbBaseProp.nQuality;
end

function tbHorse:GetHorseEnhanceTips(nTemplateId)
	if tbExtip[nTemplateId] then
		local szTimeFrame, szDesc = unpack(tbExtip[nTemplateId])
		if GetTimeFrameState(szTimeFrame) == 1 then
			return szDesc;
		end
	end
end

function tbHorse:GetTip(pEquip, pPlayer, bIsCompare)            -- 获取普通道具Tip
    local tbBaseAttrib, nQuality = self:FormatTips(pEquip.dwTemplateId, pEquip) 
    return tbBaseAttrib, nQuality;
end

function tbHorse:GetTipByTemplate(nTemplateId, tbSaveRandomAttrib)
    local tbBaseAttrib, nQuality = self:FormatTips(nTemplateId) 
    return tbBaseAttrib, nQuality;
end

function tbHorse:IsUsableItem(pPlayer, dwTemplateId)
	 --目前只是心魔用
	local tbItems = pPlayer.FindItemInPlayer("horse")
	if #tbItems > 0 then
		return false
	end

	return true
end