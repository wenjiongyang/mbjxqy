local function IsDiffMonth(nTime1, nTime2)
	local nMonth1 = Lib:GetLocalMonth(nTime1 - SignInAwards.TIME_OFFSET);
	local nMonth2 = Lib:GetLocalMonth(nTime2 - SignInAwards.TIME_OFFSET);

	return nMonth1 ~= nMonth2;
end

function SignInAwards:OnNewDayBegin()
	local tbAllPlayer = KPlayer.GetAllPlayer()
	for _, pPlayer in pairs(tbAllPlayer) do
		if pPlayer then
			self:CheckPlayerData(pPlayer)
			pPlayer.CallClientScript("SignInAwards:OnNewDayBegin")
		end
	end
end

function SignInAwards:OnLogin()
	self:CheckPlayerData(me);
end

function SignInAwards:OnLogout()
	self:CheckPlayerData(me)
end

function SignInAwards:CheckPlayerData(pPlayer)
	local nCurTime 		= GetTime();
	local nLastlyTime 	= pPlayer.GetUserValue(self.SIGNIN_AWARD_GROUP, self.LAST_LOGIN_TIME);

	if nLastlyTime == 0 or IsDiffMonth(nCurTime, nLastlyTime) then
		pPlayer.SetUserValue(self.SIGNIN_AWARD_GROUP, self.NORMAL_FLAG, 0);
		pPlayer.SetUserValue(self.SIGNIN_AWARD_GROUP, self.LOGIN_DAYS, 1);
		pPlayer.SetUserValue(self.SIGNIN_AWARD_GROUP, self.VIPLEVEL_ONGET, 0);
	elseif Lib:IsDiffDay(self.TIME_OFFSET, nCurTime, nLastlyTime) then
		local nLoginDays = pPlayer.GetUserValue(self.SIGNIN_AWARD_GROUP, self.LOGIN_DAYS) + 1;
		pPlayer.SetUserValue(self.SIGNIN_AWARD_GROUP, self.LOGIN_DAYS, nLoginDays);
		pPlayer.SetUserValue(self.SIGNIN_AWARD_GROUP, self.VIPLEVEL_ONGET, 0);
	end

	pPlayer.SetUserValue(self.SIGNIN_AWARD_GROUP, self.LAST_LOGIN_TIME, nCurTime);
end

function SignInAwards:OnGetAwards(nDayIdx, nLaunchPlatform)
	local szMsg = "您已領過獎勵";
	local bNormal, bVip, tbAwards = self:CheckAwards(nDayIdx);
	if bNormal or bVip then
		self:SetFlag(nDayIdx);

		if nLaunchPlatform ~= Sdk.ePlatform_None then
			local tbExtraAwards = Sdk.Def.tbLaunchPrivilegeAward;
			table.insert(tbAwards, tbExtraAwards);
		end

		if nLaunchPlatform == Sdk.ePlatform_Weixin then
			Sdk:CheckWeixinTitleReward(me);
		end

		if bNormal and bVip then
			me.SendAward(tbAwards, nil, nil, Env.LogWay_SignInAwardVip);
		else
			local bLogType = bNormal and Env.LogWay_SignInAwardNormal or Env.LogWay_SignInAwardVip
			me.SendAward(tbAwards, nil, nil, bLogType);
		end

		szMsg = "領取成功";
		if bNormal then
			Achievement:AddCount(me, "SignIn_1");
		end
		AssistClient:ReportQQScore(me, Env.QQReport_LoginDays, nDayIdx, 0, 1)
		Log("SignInAwards GetAwards Success", me.dwID, nDayIdx)
	end

	me.CallClientScript("SignInAwards:OnGetAwardsCallback", szMsg);
end

function SignInAwards:CheckAwards(nDayIdx)
	if (not nDayIdx) or (nDayIdx < 1) then
		return;
	end

	self:CheckPlayerData(me)

	if nDayIdx > me.GetUserValue(self.SIGNIN_AWARD_GROUP, self.LOGIN_DAYS) then
		return
	end

	local bNormal, bVip;
	local nFlag = me.GetUserValue(self.SIGNIN_AWARD_GROUP, self.NORMAL_FLAG);
	local tbAwardsInfo = self:GetAwardInfo(nDayIdx);

	if Lib:LoadBits(nFlag, nDayIdx - 1, nDayIdx - 1) == 0 then
		bNormal = true;
	end
	if tbAwardsInfo.nVipLevel ~= 0 and me.GetVipLevel() >= tbAwardsInfo.nVipLevel then
		if bNormal then	--正常领取双倍奖励
			bVip = true;
		elseif 	(nDayIdx == me.GetUserValue(self.SIGNIN_AWARD_GROUP, self.LOGIN_DAYS)) and
				(tbAwardsInfo.nVipLevel > me.GetUserValue(self.SIGNIN_AWARD_GROUP, self.VIPLEVEL_ONGET)) then
				--补领当天双倍奖励，非当天vip奖励无法补领
			bVip = true;
		end
	end

	local tbAwards = {tbAwardsInfo.tbAwards}
	if bVip and bNormal then
		table.insert(tbAwards, tbAwardsInfo.tbAwards)
	end
	return bNormal, bVip, tbAwards
end

function SignInAwards:SetFlag(nDayIdx)
	local nFlag = me.GetUserValue(self.SIGNIN_AWARD_GROUP, self.NORMAL_FLAG);
	nFlag = Lib:SetBits(nFlag, 1, nDayIdx - 1, nDayIdx - 1);

	me.SetUserValue(self.SIGNIN_AWARD_GROUP, self.NORMAL_FLAG, nFlag);
	if nDayIdx == me.GetUserValue(self.SIGNIN_AWARD_GROUP, self.LOGIN_DAYS) then
		me.SetUserValue(self.SIGNIN_AWARD_GROUP, self.VIPLEVEL_ONGET, me.GetVipLevel());
	end
end
