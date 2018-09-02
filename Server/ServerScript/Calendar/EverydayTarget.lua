function EverydayTarget:OnLogin()
	if self:CheckNewDay(me) then
		self:RefreshData(me)
	end
end

function EverydayTarget:OnTryUpdateData(pPlayer)
	if self:CheckNewDay(pPlayer) then
		self:RefreshData(pPlayer)
		pPlayer.CallClientScript("EverydayTarget:OnValueChanged")
	end
end

function EverydayTarget:RefreshData(pPlayer)
	local nLocalDay = Lib:GetLocalDay(GetTime() - self.Def.REFRESH_CLOCK)
	pPlayer.SetUserValue(self.Def.SAVE_GROUP_DAY_AWARD, self.Def.GAIN_AWARD_INFO, 0)

	local tbSaveKey = self:GetAllTargetSaveKey()
	for _, nSaveKey in ipairs(tbSaveKey or {}) do
		pPlayer.SetUserValue(self.Def.SAVE_GROUP_DAY_AWARD, nSaveKey, 0)
	end
	pPlayer.SetUserValue(self.Def.SAVE_GROUP_DAY_AWARD, self.Def.LOGIN_TIME, nLocalDay)
	pPlayer.SetUserValue(self.Def.SAVE_GROUP_DAY_AWARD, self.Def.LOGIN_LEVEL, pPlayer.nLevel)
	pPlayer.SetUserValue(self.Def.SAVE_GROUP_EXT_ACT, self.Def.EXT_ACT_KEY, 0)
end

function EverydayTarget:AddCount(pPlayer, szKey, nAdd)
	SummerGift:OnJoinAct(pPlayer, szKey)

	local nSaveKey = self:GetTargetSaveKey(szKey)
	if not nSaveKey then
		Log("[EverydayTarget AddCount] No Such Key", pPlayer.dwID, szKey)
		return
	end

	if self:CheckNewDay(pPlayer) then
		self:RefreshData(pPlayer)
	end

	local _, _, nOldActive = self:GetTargetCurActive(pPlayer, szKey)

	local nCount = pPlayer.GetUserValue(self.Def.SAVE_GROUP_DAY_AWARD, nSaveKey) + (nAdd or 1)
	pPlayer.SetUserValue(self.Def.SAVE_GROUP_DAY_AWARD, nSaveKey, nCount)

	local _, _, nNewActive = self:GetTargetCurActive(pPlayer, szKey)
	if nNewActive > nOldActive then
		pPlayer.TLog("TaskFlow", pPlayer.nLevel, pPlayer.GetVipLevel(), Env.LogWay_EverydayTargetAward, nSaveKey, self:GetTotalActiveValue(pPlayer))
	end
	
	pPlayer.CallClientScript("EverydayTarget:OnValueChanged")
	
	self:NotifyAchievement(pPlayer)
	
	local nKinId = pPlayer.dwKinId
	if nKinId and nKinId>0 then
		local tbMemberData = Kin:GetMemberData(pPlayer.dwID)
		if tbMemberData then
			local nActive = self:GetTotalActiveValue(pPlayer)
			tbMemberData:SetTodayActive(nActive)
		end
	end
end

function EverydayTarget:AddActExtActiveValue(pPlayer, nValue, szReason)
	if not pPlayer or not nValue or nValue <= 0 then
		return
	end

	if self:CheckNewDay(pPlayer) then
		self:RefreshData(pPlayer)
	end
	local nCurValue = pPlayer.GetUserValue(self.Def.SAVE_GROUP_EXT_ACT, self.Def.EXT_ACT_KEY) + nValue
	pPlayer.SetUserValue(self.Def.SAVE_GROUP_EXT_ACT, self.Def.EXT_ACT_KEY, nCurValue)
	pPlayer.CallClientScript("EverydayTarget:OnValueChanged")
	Log("EverydayTarget AddActExtActiveValue Success", pPlayer.dwID, nValue, szReason)
end

function EverydayTarget:TryGainAward(pPlayer, nAwardIdx)
	local bRet, szMsg = self:CheckGainAward(pPlayer, nAwardIdx)
	if not bRet then
		pPlayer.CenterMsg(szMsg)
		return
	end

	if self:CheckNewDay(pPlayer) then
		self:RefreshData(pPlayer)
	end

	local nGainInfo = pPlayer.GetUserValue(self.Def.SAVE_GROUP_DAY_AWARD, self.Def.GAIN_AWARD_INFO)
	nGainInfo = KLib.SetBit(nGainInfo, nAwardIdx, 1) 
	pPlayer.SetUserValue(self.Def.SAVE_GROUP_DAY_AWARD, self.Def.GAIN_AWARD_INFO, nGainInfo)

	pPlayer.CenterMsg("獎勵領取成功")
	local tbAward = {}
	local tbLevelAward = self:GetActiveAward(pPlayer, nAwardIdx)
	if tbLevelAward then
		table.insert(tbAward, tbLevelAward)
	end
	self:SendRandomAward(nAwardIdx)
	Activity:OnPlayerEvent(pPlayer, "Act_EverydayTarget_Award", nAwardIdx);
	pPlayer.SendAward(tbAward, true, false, Env.LogWay_EverydayTargetAward)
	RegressionPrivilege:OnGainEverydayTargetAward(pPlayer, nAwardIdx)
	Log("[EverydayTarget GetAward Success]", pPlayer.dwID, szAwardName)

	local kinData = Kin:GetKinById(pPlayer.dwKinId)
	if kinData then
		local nAddFound = kinData:AddFound(pPlayer.dwID, self.Def.KIN_FOUND)
		pPlayer.CenterMsg(string.format("幫派增加了%d建設資金", nAddFound))
	end

	pPlayer.CallClientScript("EverydayTarget:OnValueChanged")

	Activity:OnPlayerEvent(pPlayer, "Act_EverydayTargetGainAward", nAwardIdx);

end

function EverydayTarget:NotifyAchievement(pPlayer)
	local nValue = self:GetTotalActiveValue(pPlayer)
	Achievement:SetCount(pPlayer, "PerfectDay_1", nValue)

	if nValue >= 100 then
		--连续7天满活跃度
		local nLastMaxDay = pPlayer.GetUserValue(self.Def.SAVE_GROUP_DAY_AWARD, self.Def.LAST_MAX_ACTIVE_TIME)
		local nLocalDay   = Lib:GetLocalDay(GetTime() - self.Def.REFRESH_CLOCK)
		if (nLocalDay - nLastMaxDay) == 1 then
			local nSerDayMax = pPlayer.GetUserValue(self.Def.SAVE_GROUP_DAY_AWARD, self.Def.MAX_ACTIVE_DAY_NUM) + 1
			if nSerDayMax >= 7 then
				Achievement:SetCount(pPlayer, "PerfectDay_2", 1)
			end

			pPlayer.SetUserValue(self.Def.SAVE_GROUP_DAY_AWARD, self.Def.LAST_MAX_ACTIVE_TIME, nLocalDay)
			pPlayer.SetUserValue(self.Def.SAVE_GROUP_DAY_AWARD, self.Def.MAX_ACTIVE_DAY_NUM, nSerDayMax)
		elseif (nLocalDay - nLastMaxDay) > 1 then
			pPlayer.SetUserValue(self.Def.SAVE_GROUP_DAY_AWARD, self.Def.LAST_MAX_ACTIVE_TIME, nLocalDay)
			pPlayer.SetUserValue(self.Def.SAVE_GROUP_DAY_AWARD, self.Def.MAX_ACTIVE_DAY_NUM, 1)
		end

		if nLastMaxDay~=nLocalDay then
			TeacherStudent:TargetAddCount(pPlayer, "DailyTargetFull", 1)
		end
	end
end
