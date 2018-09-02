local tbItem = Item:GetClass("SpecialBaiJuWan");

tbItem.nAddTime = 8 * 60 * 60;						-- 增加特效白驹丸时间
tbItem.nPrice = 240;								-- 价格

function tbItem:OnUse(it)
	if not it.dwTemplateId then
		return 
	end

	if not OnHook:IsOpen(me) then
		me.CenterMsg("離線託管尚未開放");
		return
	end

	local bRet = OnHook:OnUseBaiJuWan(me,self.nAddTime,OnHook.OnHookType.SpecialPay)

	if not bRet then
		return 0
	end

	return 1
end
