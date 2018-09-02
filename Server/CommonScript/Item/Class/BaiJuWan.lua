local tbItem = Item:GetClass("BaiJuWan");

tbItem.nAddTime = 8 * 60 * 60;						-- 增加挂机时间
tbItem.nPrice = 48;									-- 价格

function tbItem:OnUse(it)
	if not it.dwTemplateId then
		return 
	end

	if not OnHook:IsOpen(me) then
		me.CenterMsg("離線託管尚未開放");
		return
	end

	local nRet = OnHook:OnUseBaiJuWan(me,self.nAddTime,OnHook.OnHookType.Pay);
	
	if not nRet then
		return 0
	end

	return 1
end
