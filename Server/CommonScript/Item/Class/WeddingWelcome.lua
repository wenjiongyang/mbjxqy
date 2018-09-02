local tbItem = Item:GetClass("WeddingWelcome");
function tbItem:OnUse(it)
	if Wedding:IsPlayerMarring(me.dwID) then
		me.CenterMsg("您正在舉行婚禮，暫不能前往", true)
		return 
	end
	if Wedding:IsPlayerTouring(me.dwID) then
		me.CenterMsg("您正在進行花轎遊城，暫不能前往", true)
		return 
	end
	if not Env:CheckSystemSwitch(me, Env.SW_ChuangGong) then
		me.CenterMsg("當前狀態不能前往", true)
		return 
	end
	if not Env:CheckSystemSwitch(me, Env.SW_Muse) then
		me.CenterMsg("當前狀態不能前往", true)
		return 
	end
	local nMapId = it.GetIntValue(1)
	if not nMapId then
		return
	end
	local tbInst = Fuben.tbFubenInstance[nMapId]
	if not tbInst then
		me.CenterMsg("該場婚禮已經結束", true)
		return
	end
	tbInst:SynWelcomeInfo(me)
end

function tbItem:GetTip(it)
	if type(it) ~= "userdata" then
		return ""
	end
	local szNameStr = it.GetStrValue(1) or ""
	local szManName, szFemanName = unpack(Lib:SplitStr(szNameStr, ";"))
	return string.format("新郎：%s\n新娘：%s", szManName or "", szFemanName or "")
end