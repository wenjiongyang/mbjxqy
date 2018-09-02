local tbItem = Item:GetClass("BeautyPageantPaper")
local tbAct = Activity.BeautyPageant

function tbItem:GetUseSetting(nTemplateId)
	if not tbAct:IsInProcess() or not tbAct:IsSignUp() then
		return {}
	end

	local tbUseSetting = 
	{
		["szFirstName"] = "我的頁面",
		["fnFirst"] = function ()
			Ui.HyperTextHandle:Handle(string.format("[url=openBeautyUrl:PlayerPage, %s][-]", string.format(tbAct.szPlayerUrl, me.dwID, Sdk:GetServerId())));
			Ui:CloseWindow("ItemTips")
		end,

		["szSecondName"] = "分享",
		["fnSecond"] = function ()
			local nChannel = ChatMgr.ChannelType.Public
			if Kin:HasKin() then
				nChannel = ChatMgr.ChannelType.Kin
			end
			Ui:OpenWindow("ChatLargePanel", nChannel, nil, "OpenEmotionLink")
			Ui:CloseWindow("ItemTips")
		end,
	}

	return tbUseSetting;		
end

function tbItem:GetIntrol(dwTemplateId)

	local tbTime = tbAct.STATE_TIME[tbAct.STATE_TYPE.LOCAL]
	local szMatch = "海選賽（本服評選）"
	if dwTemplateId == tbAct.SIGNUP_ITEM_FINAL then
		tbTime = tbAct.STATE_TIME[tbAct.STATE_TYPE.FINAL]
		szMatch = "決賽"
	end

	return string.format("[FFFE0D]%s：%s~%s[-]\n\n記錄著參賽佳人資訊的紙張，可以通過它在任意聊天頻道宣傳個人的選美資訊，或打開自己的參賽頁面", szMatch, Lib:TimeDesc10(tbTime[1]), Lib:TimeDesc10(tbTime[2]+1))
end
