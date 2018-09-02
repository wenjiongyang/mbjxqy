
local tbAct = Activity:GetClass("RechargeCardActExt");

tbAct.tbTimerTrigger = 
{ 
}
tbAct.tbTrigger = { 
	Init 	= { }, 
	Start 	= { }, 
	End 	= { }, 
}


function tbAct:OnTrigger(szTrigger)
	if szTrigger == "Start" then
		Activity:RegisterPlayerEvent(self, "Act_OnPlayerLogin", "OnLogin");
		local szParam1, szParam2 = self.tbParam[1], self.tbParam[2];
		self.nExtWeekAmount = tonumber(szParam1)
		if self.nExtWeekAmount == 0 then
			self.nExtWeekAmount = nil;
		end
		self.nExtMonAmount = tonumber(szParam2)
		if self.nExtMonAmount == 0 then
			self.nExtMonAmount = nil;
		end

		--self:SendNews()
		Recharge:OnCardActStart({self.nExtWeekAmount, self.nExtMonAmount})
		KPlayer.BoardcastScript(1, "Recharge:OnCardActStart", {self.nExtWeekAmount, self.nExtMonAmount})
	elseif szTrigger == "End" then
		self.nExtWeekAmount = nil;
		self.nExtMonAmount = nil;
		Recharge:OnCardActEnd()
		KPlayer.BoardcastScript(1, "Recharge:OnCardActEnd")
	end
end

function tbAct:OnLogin(pPlayer)
	pPlayer.CallClientScript("Recharge:OnCardActStart", {self.nExtWeekAmount, self.nExtMonAmount})
end

function tbAct:SendNews()
	if not self.nExtMonAmount and not self.nExtWeekAmount then
		return
	end

	local nIndex = 0

	local strContent = "[FFFE0D]週末來臨，歡慶武林[-]\n     諸位俠士，喜迎週末，武林將開啟歡慶活動！\n\n";

	if self.nExtWeekAmount then
		nIndex = nIndex + 1
		strContent = strContent .. string.format("活動%s：\n", Lib:Transfer4LenDigit2CnNum(nIndex)) ;
		strContent = strContent .. string.format("金秋九月，五穀豐登；福利狂歡，元寶為鄰；活動期間，福利界面中元寶大禮7日禮包可額外領取[FFFE0D] %d%%元寶[-]\n\n", self.nExtWeekAmount)	
	end

	if self.nExtMonAmount then
		nIndex = nIndex + 1
		strContent = strContent .. string.format("活動%s：\n", Lib:Transfer4LenDigit2CnNum(nIndex)) ;
		strContent = strContent .. string.format("金秋九月，五穀豐登；福利狂歡，元寶為鄰；活動期間，福利界面中元寶大禮30日禮包可額外領取[FFFE0D] %d%%元寶[-]\n\n", self.nExtMonAmount)	
	end
	strContent = strContent .. "\n  [url=openwnd:前往儲值, CommonShop, 'Recharge', 'Recharge']"

	local _, nEndTime = self:GetOpenTimeInfo()
	NewInformation:AddInfomation("RechargeCardActExt", nEndTime, {strContent}, {szTitle = "週末狂歡", nReqLevel = 1})
end

function tbAct:GetUiData()
	return {self.nExtWeekAmount, self.nExtMonAmount}
end