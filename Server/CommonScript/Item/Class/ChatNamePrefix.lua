local tbItem = Item:GetClass("ChatNamePrefix");

function tbItem:OnUse(it)
	local nNamePrefixType = KItem.GetItemExtParam(it.dwTemplateId, 1);
	local nValidTime = KItem.GetItemExtParam(it.dwTemplateId, 2);

	if not ChatMgr:GetNamePrefixInfo(nNamePrefixType).NamePrefixId then
		me.CenterMsg("未知聊天首碼類型");
		return;
	end

	if nValidTime <= 0 then
		me.CenterMsg("過期時間參數無效");
		return;
	end

	local nExpireTime = GetTime() + nValidTime;
	ChatMgr:SetNamePrefixById(me, nNamePrefixType, nExpireTime);
	return 1;
end