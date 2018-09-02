local tbSpeaker = Item:GetClass("Speaker");

function tbSpeaker:OnUse(it)
	local nBuyChatCount = KItem.GetItemExtParam(it.dwTemplateId, 1);
	local nType = KItem.GetItemExtParam(it.dwTemplateId, 2);

	if nType == ChatMgr.ChannelType.Public then
		ChatMgr:AddPublicChatCount(me, nBuyChatCount);
		me.CenterMsg(string.format("增加了%d次世界頻道發言機會", nBuyChatCount));
		return 1;
	elseif nType == ChatMgr.ChannelType.Color then
		ChatMgr:AddColorChatCount(me, nBuyChatCount);
		me.CenterMsg(string.format("增加了%d次彩聊頻道發言機會", nBuyChatCount));
		me.CallClientScript("ChatMgr:UpdateColorMsgCount");
		return 1;
	elseif nType == ChatMgr.ChannelType.Cross then
		ChatMgr:AddCrossChatCount(me, nBuyChatCount);
		me.CenterMsg(string.format("增加了%d次主播頻道發言機會", nBuyChatCount));
		return 1;
	else
		me.CenterMsg("未知喇叭類型");
	end
end