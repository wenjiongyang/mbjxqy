
local tbAct = Activity:GetClass("ServerVipeExChange");

tbAct.tbTimerTrigger =
{
}
tbAct.tbTrigger = {
	Init 	= { },
	Start 	= { },
	End 	= { },
}

tbAct.SAVE_GROUP = 102
tbAct.SAVE_KEY_ServerSend = 1; --ServerSend 的 key


function tbAct:OnTrigger(szTrigger)

	if szTrigger == "Start" then
		self:LoadSetting();
		-- Activity:RegisterNpcDialog(self, 97,  {Text = "bug补偿", Callback = self.OnNpcDialog, Param = {self}})
	elseif szTrigger == "Init" then
		self:LoadSetting();
		self:SendAllMails();
	end
end

function tbAct:SendAllMails()
	for dwRoldId, nCount in pairs(self.tbLimitServerSend) do
		Mail:SendSystemMail({
			To = dwRoldId;
			Title = "劍俠V禮包BUG補償";
			Text = string.format("尊敬的玩家，由於之前VIP禮包中的4級魂石BUG，導致你獲得一些錯誤的4級魂石。我們深表歉意。\n現提供兌換功能，可以使用任意一個4級的中級魂石（如中級魂石·少年楊影楓等），兌換一個隨機4級的初級魂石。\n根據你之前VIP禮包獲得情況，你有%d次兌換機會，可以兌換%d個4級的初級魂石。\n請前往襄陽城的 [url=npc:NPC月眉兒, 97, 10] 處兌換", nCount, nCount);
		 })
	end
end

function tbAct:LoadSetting()
	if self.tbLimitServerSend then
		return
	end
	local tbLimitServerSend = {}
	local _, _, nServerIdentity = GetWorldConfifParam()
	local file  = LoadTabFile("Setting/Exchange/LimitServerSend.tab", "ddd", nil, {"ServerId", "RoleId", "Count"});
	for i,v in ipairs(file) do
		if v.ServerId == nServerIdentity then
			tbLimitServerSend[v.RoleId] = v.Count
		end
	end
	self.tbLimitServerSend = tbLimitServerSend
end


function tbAct:OnNpcDialog()
	local nTotalCount = self.tbLimitServerSend[me.dwID]
	if not nTotalCount then
		me.CenterMsg("當前沒有bug補償")
		return
	end

	local nUseCount = me.GetUserValue(self.SAVE_GROUP, self.SAVE_KEY_ServerSend)
	Dialog:Show(
	{
	    Text    = string.format("為了補償之前的BUG，你現在還有 %d/%d 次兌換隨機4級初級魂石的機會。可使用4級中級魂石兌換", (nTotalCount - nUseCount), nTotalCount) ,
	    OptList = {
	        { Text = "兌換4級初級魂石", Callback = self.AskExchangeItem, Param = {self} },
	    },
	}, me, him)
end

function tbAct:AskExchangeItem()
	if not self:Can_ServerVipeExChange(me) then
		return
	end
	Exchange:AskItem(me, "ServerVipeExChange", self.ExchangeItem, self)
end

function tbAct:Can_ServerVipeExChange(pPlayer, nAddCount)
	local nTotalCount = self.tbLimitServerSend[pPlayer.dwID]
	if not nTotalCount then
		return
	end
	nAddCount = nAddCount or 1
	local nUseCount = pPlayer.GetUserValue(self.SAVE_GROUP, self.SAVE_KEY_ServerSend)
	if nUseCount + nAddCount > nTotalCount then
		if nUseCount == nTotalCount then
			pPlayer.CenterMsg("兌換次數已經用完")
		else
			pPlayer.CenterMsg(string.format("兌換次數不足%d次", nAddCount) )
		end
		return
	end

	return true
end

function tbAct:ExchangeItem(tbItems) --有me 的
	for dwTemplateId, nCount in pairs(tbItems) do
		if me.GetItemCountInAllPos(dwTemplateId) < nCount then
			return
		end
	end

	local tbSetting = Exchange.tbExchangeSetting["ServerVipeExChange"];
	local tbExchangeIndex =  Exchange:DefaultCheck(tbItems, tbSetting)
	if not tbExchangeIndex then
		return
	end

	if not self:Can_ServerVipeExChange(me, #tbExchangeIndex) then
		return
	end
	local tbAllExchange = tbSetting.tbAllExchange
	me.SetUserValue(self.SAVE_GROUP, self.SAVE_KEY_ServerSend, me.GetUserValue(self.SAVE_GROUP, self.SAVE_KEY_ServerSend) + #tbExchangeIndex)
	for _,nIdex in ipairs(tbExchangeIndex) do
		local tbSet = tbAllExchange[nIdex]
		for nItemId,nCount in pairs(tbSet.tbAllItem) do
			if  me.ConsumeItemInAllPos(nItemId, nCount, Env.LogWay_ExchangeSeverSend) ~= nCount then
				Log(debug.traceback(), me.dwID)
				return
			end
		end

		me.SendAward(tbSet.tbAllAward, nil,nil, Env.LogWay_ExchangeSeverSend)
	end
	me.CenterMsg("兌換成功")
end