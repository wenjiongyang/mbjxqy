function MoneyTree:OnLogin()
	self:CheckPlayerData(me)
end

function MoneyTree:OnNewDayBegin()
	local tbAllPlayer = KPlayer.GetAllPlayer()
	for _, pPlayer in pairs(tbAllPlayer) do
		if pPlayer then
			self:CheckPlayerData(pPlayer)
		end
	end
end

function MoneyTree:TryShaking(pPlayer, bMulti, nTryShakeIdx, bLaunchExtra) --bMulti 是否十连抽
	self:CheckPlayerData(pPlayer)

	local nShakeIdx = pPlayer.GetUserValue(self.Def.SAVE_GROUP, self.Def.SHAKE_TIMES)
	if nTryShakeIdx ~= nShakeIdx then
		return
	end

	local nCost = self:GetShakePrice(bMulti) --当玩家单抽并且是免费单抽时这个结果是0
	if nCost > 0 then
		if pPlayer.GetMoney("Gold") < nCost then
			pPlayer.CenterMsg("元寶不足");
			pPlayer.CallClientScript("Ui:OpenWindow", "CommonShop", "Recharge", "Recharge");
			return;
		end

		pPlayer.CostGold(nCost, Env.LogWay_MoneyTreeShake, nil,
			function (nPlayerId, bSuccess)
				local bRet, szMsg = self:OnCostCallback(nPlayerId, bSuccess, bMulti, nTryShakeIdx, bLaunchExtra)
				Log("MoneyTree TryMultiShaking Success", pPlayer.dwID, tostring(bMulti), Lib:GetLocalDay(), nCost)
				return bRet, szMsg
			end)
	else
		self:DoShaking(pPlayer, bMulti, bLaunchExtra)
		Log("MoneyTree TryOnceShaking Success", pPlayer.dwID, tostring(bMulti), Lib:GetLocalDay())
	end
end

function MoneyTree:OnCostCallback(nPlayerId, bSuccess, bMulti, nTryShakeIdx, bLaunchExtra)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return false, "離線了，請重試"
	end

	if not bSuccess then
		return false, "支付失敗"
	end

	local nShakeIdx = pPlayer.GetUserValue(self.Def.SAVE_GROUP, self.Def.SHAKE_TIMES)
	if nTryShakeIdx ~= nShakeIdx then
		return false, "請重試"
	end

	self:CheckPlayerData(pPlayer)
	self:DoShaking(pPlayer, bMulti, bLaunchExtra)
	return true
end

function MoneyTree:DoShaking(pPlayer, bMulti, bLaunchExtra)
	local nTotalCoin = 0;
	local tbGain     = {};
	local nRate      = pPlayer.GetVipLevel() >= self.Def.BONUSES_VIPLEVEL and self.Def.BONUSES_RATE or 1
	local nTime      = bMulti and self.Def.MULTI_TIMES or 1

	-- 手Q, 微信启动特权
	if bLaunchExtra then
		nRate = nRate + self.Def.LAUNCH_PRIVILEGE_RATE;
	end

	-- QQ会员加成
	-- local _, nVipAddRate = pPlayer.GetQQVipInfo();
	-- nRate = nRate + nVipAddRate;

	for i = 1, nTime do
		local nCoin = self:RandomReward() * nRate
		nTotalCoin = nTotalCoin + nCoin;
		if nCoin >= self.nMaxCoin and pPlayer.dwKinId ~= 0 then
			local szMsg = string.format("天降鴻福，%s在搖錢樹上搖到了%d銀兩!", pPlayer.szName, nCoin);
			ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.Kin, szMsg, pPlayer.dwKinId);
		end
		table.insert(tbGain, nCoin);
	end

	if not bMulti and pPlayer.GetUserValue(self.Def.SAVE_GROUP, self.Def.FREE_SHAKE) == 0 then
		pPlayer.SetUserValue(self.Def.SAVE_GROUP, self.Def.FREE_SHAKE, nTime)
	else
		local nShakeTimes = pPlayer.GetUserValue(self.Def.SAVE_GROUP, self.Def.SHAKE_TIMES) + nTime
		pPlayer.SetUserValue(self.Def.SAVE_GROUP, self.Def.SHAKE_TIMES, nShakeTimes)
	end

	pPlayer.AddMoney("Coin", nTotalCoin, Env.LogWay_MoneyTreeShake);
	pPlayer.CallClientScript("MoneyTree:OnRespond", tbGain);
	for i = 1, #tbGain do
		Achievement:AddCount(pPlayer, "MoneyTree_1");
	end
	return nTotalCoin
end

function MoneyTree:CheckPlayerData(pPlayer)
	local nLocalDay = Lib:GetLocalDay(GetTime() - self.Def.REFRESH_TIME)
	if nLocalDay ~= pPlayer.GetUserValue(self.Def.SAVE_GROUP, self.Def.LOGIN_DAY) then
		pPlayer.SetUserValue(self.Def.SAVE_GROUP, self.Def.LOGIN_DAY, nLocalDay)
		pPlayer.SetUserValue(self.Def.SAVE_GROUP, self.Def.FREE_SHAKE, 0)
		pPlayer.SetUserValue(self.Def.SAVE_GROUP, self.Def.SHAKE_TIMES, 0)
		pPlayer.CallClientScript("MoneyTree:CheckRedPoint")
	end
end

function MoneyTree:IsHaveFreeTimes(pPlayer)
	self:CheckPlayerData(pPlayer)
	return pPlayer.GetUserValue(self.Def.SAVE_GROUP, self.Def.FREE_SHAKE) == 0
end

function MoneyTree:RestoreFreeTimes(pPlayer)
	self:CheckPlayerData(pPlayer)
	pPlayer.SetUserValue(self.Def.SAVE_GROUP, self.Def.FREE_SHAKE, 0)
end