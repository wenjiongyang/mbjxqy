function LoginAwards:OnNewDayBegin()
	local tbAllPlayer = KPlayer.GetAllPlayer()
	for _, pPlayer in pairs(tbAllPlayer) do
		if pPlayer then
			self:CheckPlayerData(pPlayer)
		end
	end
end

function LoginAwards:OnLogin()
	self:CheckPlayerData(me)
end

function LoginAwards:OnGetAwards(nDayIdx)
	local bRet, szMsg = self:CheckAwards(nDayIdx);
	if bRet then
		self:SetFlag(nDayIdx);
		local tbAward = self:GetDayAward(nDayIdx)
		me.SendAward(tbAward, nil, nil, Env.LogWay_GetLoginAwards);
		Log("LoginAwards GetAwards Success", me.dwID, nDayIdx)
	end

	me.CallClientScript("LoginAwards:OnGetAwardsCallback", szMsg);
end

function LoginAwards:CheckPlayerData(pPlayer)
	local nMaxDays = self:GetActLen()
	if pPlayer.GetUserValue(self.LOGIN_AWARDS_GROUP, self.LOGIN_DAYS) >= nMaxDays then
		return;
	end

	local nLastlyTime = pPlayer.GetUserValue(self.LOGIN_AWARDS_GROUP, self.LAST_LOGIN_TIME);
	local nCurTime    = GetTime()
	if nLastlyTime == 0 or Lib:IsDiffDay(self.REFRESH_TIME, nLastlyTime, nCurTime) then
		local nLoginDays = pPlayer.GetUserValue(self.LOGIN_AWARDS_GROUP, self.LOGIN_DAYS) + 1
		pPlayer.SetUserValue(self.LOGIN_AWARDS_GROUP, self.LOGIN_DAYS, nLoginDays);
		pPlayer.SetUserValue(self.LOGIN_AWARDS_GROUP, self.LAST_LOGIN_TIME, nCurTime)
		pPlayer.CallClientScript("LoginAwards:OnDataRefresh")
		Log("[LoginAwards Refresh Player Data]", pPlayer.dwID, pPlayer.szName, Lib:GetLocalDay(nCurTime - self.REFRESH_TIME))
	end
end

function LoginAwards:GetTotalLoginDays(pPlayer)
	return pPlayer.GetUserValue(self.LOGIN_AWARDS_GROUP, self.LOGIN_DAYS)
end

function LoginAwards:CheckAwards(nDayIdx)
	if (not nDayIdx) or (nDayIdx < 1) or not self:GetDayAward(nDayIdx) then
		return false, "未知原因，領取失敗";
	end

	self:CheckPlayerData(me)

	if nDayIdx > me.GetUserValue(self.LOGIN_AWARDS_GROUP, self.LOGIN_DAYS) then
		return false, "領取失敗";
	end

	local nFlag = me.GetUserValue(self.LOGIN_AWARDS_GROUP, self.RECEIVE_FLAG);
	if Lib:LoadBits(nFlag, nDayIdx - 1, nDayIdx - 1) ~= 0 then
		return false, "您已領過今天獎勵";
	end
	return true, "領取成功";
end

function LoginAwards:SetFlag(nDayIdx)
	local nFlag = me.GetUserValue(self.LOGIN_AWARDS_GROUP, self.RECEIVE_FLAG);
	nFlag = Lib:SetBits(nFlag, 1, nDayIdx - 1, nDayIdx - 1);
	me.SetUserValue(self.LOGIN_AWARDS_GROUP, self.RECEIVE_FLAG, nFlag);
end