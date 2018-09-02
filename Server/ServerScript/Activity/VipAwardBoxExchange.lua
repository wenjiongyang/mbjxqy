
local tbAct = Activity:GetClass("VipAwardBoxExchange");

tbAct.tbTimerTrigger =
{
}
tbAct.tbTrigger = {
	Init 	= { },
	Start 	= { },
	End 	= { },
}

tbAct.tbVipLevelCount  = {
	[14] = 4;
	[15] = 6;
	[16] = 6;
}

tbAct.SAVE_GROUP = 102
tbAct.SAVE_KEY_Count = 2;

function tbAct:OnTrigger(szTrigger)
	if szTrigger == "Start" then
		if not self.nRegisterLogin then
			self.nRegisterLogin = PlayerEvent:RegisterGlobal("OnLogin",  self.OnLogin, self);
		end

		Activity:RegisterNpcDialog(self, 97,  {Text = "Bug補償", Callback = self.OnNpcDialog, Param = {self}})

	elseif szTrigger == "End" then
		if self.nRegisterLogin then
			PlayerEvent:UnRegisterGlobal("OnLogin", self.nRegisterLogin)
			self.nRegisterLogin = nil;
		end
	end
end

function tbAct:OnNpcDialog()
	local nHasCout = me.GetUserValue(self.SAVE_GROUP, self.SAVE_KEY_Count)
	if nHasCout <= 0 then
		me.CenterMsg("當前沒有bug補償")
		return
	end

	Dialog:Show(
	{
	    Text    = string.format("你現在還有 %d 次兌換4級魂石任選箱的機會。可使用4級初級魂石兌換", nHasCout) ,
	    OptList = {
	        { Text = "兌換4級魂石任選箱", Callback = self.AskExchangeItem, Param = {self} },
	    },
	}, me, him)
end

function tbAct:CanChange(pPlayer, nUseCount)
	local nHasCout = pPlayer.GetUserValue(self.SAVE_GROUP, self.SAVE_KEY_Count)
	if nHasCout <= 0 then
		pPlayer.CenterMsg("當前沒有兌換次數")
		return
	end

	if nUseCount then
		if nUseCount > nHasCout then
			pPlayer.CenterMsg(string.format("兌換次數不足%d次", nUseCount))
			return
		end
	end

	return true
end

function tbAct:AskExchangeItem()
	if not self:CanChange(me) then
		return
	end
	Exchange:AskItem(me, "VipAwardBoxExchange", self.ExchangeItem, self)
end

function tbAct:ExchangeItem(tbItems)
	for dwTemplateId, nCount in pairs(tbItems) do
		if me.GetItemCountInAllPos(dwTemplateId) < nCount then
			return
		end
	end

	local tbSetting = Exchange.tbExchangeSetting["VipAwardBoxExchange"];
	local tbExchangeIndex =  Exchange:DefaultCheck(tbItems, tbSetting)
	if not tbExchangeIndex then
		return
	end

	local nHasCout = me.GetUserValue(self.SAVE_GROUP, self.SAVE_KEY_Count)
	if not self:CanChange(me, #tbExchangeIndex) then
		return
	end


	local tbAllExchange = tbSetting.tbAllExchange
	local tbGetItems = {}
	for i,nIdex in ipairs(tbExchangeIndex) do
		local tbSet = tbAllExchange[nIdex]
		for nItemId,nCount in pairs(tbSet.tbAllItem) do
			if  me.ConsumeItemInAllPos(nItemId, nCount, Env.LogWay_VipAwardBoxExchange) ~= nCount then
				Log(debug.traceback(), me.dwID)
				return
			end
		end
		Lib:MergeTable(tbGetItems, tbSet.tbAllAward)
	end

	me.SetUserValue(self.SAVE_GROUP, self.SAVE_KEY_Count, nHasCout - #tbExchangeIndex)
	me.SendAward(tbGetItems, nil,nil, Env.LogWay_VipAwardBoxExchange)

	me.CenterMsg("兌換成功")
end

function tbAct:OnLogin()
	if me.GetUserValue(self.SAVE_GROUP, self.SAVE_KEY_Count) > 0 then
		return
	end

	local nVipLevel = me.GetVipLevel()
	if nVipLevel < 14 then
		return;
	end

	local nBuyedVal = me.GetUserValue(Recharge.SAVE_GROUP, Recharge.KEY_VIP_AWARD)
	local nCount = 0
	local _, nEndTime = self:GetOpenTimeInfo()
	for nNeedVipLevel, nSaveKey in pairs(Recharge.tbVipAwardTakeTimeKey) do
		local nBuydeBit = KLib.GetBit(nBuyedVal, nNeedVipLevel + 1)
		if nBuydeBit == 1 and me.GetUserValue(Recharge.SAVE_GROUP, nSaveKey) == 0 then
			nCount = nCount + self.tbVipLevelCount[nNeedVipLevel]
			me.SetUserValue(Recharge.SAVE_GROUP, nSaveKey, nEndTime)
		end
	end
	if nCount > 0 then
		me.SetUserValue(self.SAVE_GROUP, self.SAVE_KEY_Count, nCount)
		Log("VipAwardBoxExchange AddCount ", me.dwID, nCount, me.GetVipLevel())
		Mail:SendSystemMail({
			To = me.dwID;
			Title = "劍俠V禮包補償";
			Text = string.format("尊敬的玩家，由於原VIP禮包中的4級隨機魂石，調整為4級魂石任選箱。為彌補您的損失，現提供兌換功能，可以使用任意一個4級的初級魂石，兌換一個4級魂石任選箱。\n根據你之前VIP禮包獲得情況，你有%d次兌換機會\n請前往襄陽城的 [00ff00][url=npc:NPC月眉兒, 97, 10][-] 處兌換", nCount);
		 })

	end
end