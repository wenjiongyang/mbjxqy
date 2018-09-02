
local tbAct = Activity:GetClass("ShopAct");

tbAct.tbTimerTrigger = { }
tbAct.tbTrigger = { Init = { }, Start = { }, End = { }, }


function tbAct:OnTrigger(szTrigger)

	if szTrigger == "Init" then
	elseif szTrigger == "Start" then
		local nStartTime = self:GetOpenTimeInfo()
		local szName = self.tbParam[3];
		self.szName  = Lib:IsEmptyStr(szName) and "限時特惠" or szName

		Shop:LoadActShopWare(self:GetShopWares(), nStartTime)
		
	elseif szTrigger == "End" then
		Shop:RemoveActShopWare()
	end
end

function tbAct:GetShopWares()
	local nOutsidePackage = tonumber(self.tbParam[2]) or 0;
	local tbFile = LoadTabFile(self.tbParam[1], "ddddssddssss", "nGoodsId", {"nGoodsId", "nTemplateId", "nPrice", "nLimitNum", "szMoneyType","szShopType", "nSort","nDiscount","szTimeFrame", "szCloseTimeFrame","szOpenTime", "szCloseTime"},1,nOutsidePackage);
	return tbFile;
end

function tbAct:GetUiData( )
	return {szName = self.szName }
end
