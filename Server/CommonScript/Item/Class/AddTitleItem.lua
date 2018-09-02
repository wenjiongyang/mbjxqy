
local tbItem = Item:GetClass("AddTitleItem");
tbItem.nExtTitleId = 1;
tbItem.nExtTime = 2;

function tbItem:OnUse(it)
	local nTitleId    = KItem.GetItemExtParam(it.dwTemplateId, self.nExtTitleId);
	local nTime = KItem.GetItemExtParam(it.dwTemplateId, self.nExtTime);
	
	if nTitleId <= 0 then
		Log("Error AddTitleItem Not nTitleId", it.dwTemplateId, nTitleId);
		return;
	end


	me.AddTitle(nTitleId, nTime, false, true)

	Log("AddTitleItem", me.dwID, nTitleId, nTime);
	return 1;
end