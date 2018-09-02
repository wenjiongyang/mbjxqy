local tbItem = Item:GetClass("MarriagePaper")

function tbItem:OnUse(it)
	me.CallClientScript("Ui:CloseWindow", "ItemTips")
	me.CallClientScript("Ui:CloseWindow", "ItemBox")
	me.CallClientScript("Ui:OpenWindow", "MarriagePaperPanel", it.dwTemplateId, it.dwId)
	return 0
end

function tbItem:GetUseSetting(nItemTemplateId, nItemId)
    return {szFirstName = "查看", fnFirst = "UseItem"}
end