local tbItem = Item:GetClass("WorshipMap");
tbItem.PARAM_MAPID = 1

function tbItem:OnUse(it)
	if not Activity:__IsActInProcessByType("QingMingAct") then
		me.CenterMsg("活動已經結束", true)
		return 
	end

	Activity:OnPlayerEvent(me, "Act_UseWorshipMap", it);
end

function tbItem:GetTip(it)
	local nMapTID = self:GetMapTID(it)
	local tbMapSetting = Activity.QingMingAct:GetMapSetting(nMapTID) or {}
	return  tbMapSetting.szTip or ""
end

function tbItem:GetIntrol(nTemplateId, nItemId)
	local pItem = KItem.GetItemObj(nItemId);
	if not pItem then
		return ""
	end
	local nMapTID = self:GetMapTID(pItem)
	local tbMapSetting = Activity.QingMingAct:GetMapSetting(nMapTID) or {}
	return  tbMapSetting.szIntrol or ""
end

function tbItem:GetDefineName(it)
	local nMapTID = self:GetMapTID(it)
	local tbMapSetting = Activity.QingMingAct:GetMapSetting(nMapTID) or {}
	return  tbMapSetting.szName
end

function tbItem:GetMapTID(pItem)
	return pItem.GetIntValue(self.PARAM_MAPID);
end

