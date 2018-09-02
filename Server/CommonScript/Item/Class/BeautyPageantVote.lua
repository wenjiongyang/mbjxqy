local tbItem = Item:GetClass("BeautyPageantVote")
local tbAct = Activity.BeautyPageant

function tbItem:GetUseSetting(nTemplateId)
	if not tbAct:IsInProcess() then
		return {}
	end

	local tbUseSetting = 
	{
		["szFirstName"] = "贈予佳人",
		["fnFirst"] = function ()
			Ui:OpenWindow("BeautyCompetitionPanel")
			Ui:CloseWindow("ItemTips")
		end,
	}

	return tbUseSetting;		
end