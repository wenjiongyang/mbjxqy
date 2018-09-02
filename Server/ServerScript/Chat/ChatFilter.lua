
function ChatMgr:LoadFilterText()
	local tbList = ScriptData:GetValue("ChatFilterText")
	for szText,_ in pairs(tbList) do
		if szText and szText ~= "" then
			KChat.AddFilterText(string.format("*%s*", szText))
			AddNameFilterText(string.format("*%s*", szText))
		end
	end
end


function ChatMgr:SetFilterText(tbList)
	KChat.ClearFilterText()
	local tbSaveList = {}
	for _,szText in pairs(tbList) do
		if szText and szText ~= "" then
			KChat.AddFilterText(string.format("*%s*", szText))
			AddNameFilterText(string.format("*%s*", szText))
			tbSaveList[szText] = true
		end
	end

	ScriptData:SaveValue("ChatFilterText", tbSaveList)
	ScriptData:AddModifyFlag("ChatFilterText")
end

function ChatMgr:AddFilterText(szText)
	local tbList = ScriptData:GetValue("ChatFilterText")
	if not tbList[szText] then
		if szText and szText ~= "" then
			KChat.AddFilterText(string.format("*%s*", szText))
			AddNameFilterText(string.format("*%s*", szText))
			tbList[szText] = true
		end
		ScriptData:AddModifyFlag("ChatFilterText")
	end
end

function ChatMgr:DelFilterText(szText)
	local tbList = ScriptData:GetValue("ChatFilterText")
	if tbList[szText] then
		tbList[szText] = nil
		ScriptData:AddModifyFlag("ChatFilterText")
	end
end
