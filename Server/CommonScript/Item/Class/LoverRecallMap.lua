local tbItem = Item:GetClass("LoverRecallMap");

function tbItem:OnUse(it)
	if not Activity:__IsActInProcessByType("LoverRecallAct") then
		me.CenterMsg("活動已經結束", true)
		return 1
	end
	local nMapTID =  KItem.GetItemExtParam(it.dwTemplateId, 1);
	Activity:OnPlayerEvent(me, "Act_UseLoverRecallMap", nMapTID, it.dwTemplateId);
end