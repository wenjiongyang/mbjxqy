local tbItem = Item:GetClass("SwornFriendsTitleToken")

function tbItem:OnUse(it)
	if not SwornFriends:IsConnectedState(me) then
		me.CenterMsg("你沒有結拜，無法使用")
		return
	end

	me.CallClientScript("Ui:CloseWindow", "ItemTips")
	me.CallClientScript("Ui:CloseWindow", "ItemBox")
	me.CallClientScript("Ui:OpenWindow", "SwornFriendsPersonalTitlePanel", true)
end
