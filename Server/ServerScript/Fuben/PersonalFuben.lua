Require("CommonScript/Fuben/PersonalFubenCommon.lua");

function PersonalFuben:OnLogin()
	local tbPersonalFubenData = self:GetPersonalFubenData(me);
	me.CallClientScript("PersonalFuben:SetPersonalFubenData", tbPersonalFubenData);
end

function PersonalFuben:ClearCurrentFubenData(pPlayer)
	local tbPersonalFubenData = self:GetPersonalFubenData(pPlayer);
	tbPersonalFubenData.tbCurrentFubenInfo = nil;
end

function PersonalFuben:GetCurrentFubenData(pPlayer)
	local tbPersonalFubenData = self:GetPersonalFubenData(pPlayer);
	tbPersonalFubenData.tbCurrentFubenInfo = tbPersonalFubenData.tbCurrentFubenInfo or {};
	return tbPersonalFubenData.tbCurrentFubenInfo;
end

function PersonalFuben:ClearCacheAward(pPlayer, nSectionIdx, nSubSectionIdx, nFubenLevel)
	local tbRecord = self:GetPlayerFubenRecord(pPlayer);
	local tbAwardBySection = Lib:InitTable(tbRecord, "tbAwardInfo", nFubenLevel, nSectionIdx);

	tbAwardBySection[nSubSectionIdx] = nil;

	if Lib:CountTB(tbAwardBySection) <= 0 then
		tbRecord.tbAwardInfo[nFubenLevel][nSectionIdx] = nil;
	end
end

function PersonalFuben:GetRandomFubenAward(pPlayer, nSectionIdx, nSubSectionIdx, nFubenLevel)
	local nFubenIndex = self:GetFubenIndex(nSectionIdx, nSubSectionIdx, nFubenLevel);
	local tbSetting = self:GetPersonalFubenInfo(nFubenIndex);
	local nMapTemplateId = tbSetting.nMapTemplateId;
	if not Fuben.tbFubenTemplate[nMapTemplateId] then
		return;
	end

	local tbRecord = self:GetPlayerFubenRecord(pPlayer);
	local tbAwardBySection = Lib:InitTable(tbRecord, "tbAwardInfo", nFubenLevel, nSectionIdx);

	-- 如果有未完成的副本，则使用上次随机的奖励
	if tbAwardBySection[nSubSectionIdx] then
		return tbAwardBySection[nSubSectionIdx];
	end

	tbAwardBySection[nSubSectionIdx] = {};
	local tbResult = tbAwardBySection[nSubSectionIdx];
	local function fnMargeAward(tbInfo)
		tbResult[tbInfo.nAwardLevel] = tbResult[tbInfo.nAwardLevel] or {};
		local tbAward = tbResult[tbInfo.nAwardLevel];
		if tbInfo.nItemId > 0 then
			tbAward.tbItem = tbAward.tbItem or {};
			tbAward.tbItem[tbInfo.nItemId] = (tbAward.tbItem[tbInfo.nItemId] or 0) + tbInfo.nCount;
		elseif tbInfo.SubType and tbInfo.SubType ~= "" then
			local tbSubAward = Lib:InitTable(tbAward, "tbWithSubTypeAward", tbInfo.szType);
			table.insert(tbSubAward, {tbInfo.SubType, tbInfo.nCount});
		else
			tbAward[tbInfo.szType] = tbAward[tbInfo.szType] or {};
			table.insert(tbAward[tbInfo.szType], tbInfo.nCount);
		end
	end

	local nStar = self:GetFubenStarLevel(pPlayer, nSectionIdx, nSubSectionIdx, nFubenLevel);
	local tbFirstAward = Fuben.tbFubenTemplate[nMapTemplateId].tbFirstAward or {};
	if nStar < 1 and tbFirstAward[nFubenLevel] then
		for _, tbInfo in pairs(tbFirstAward[nFubenLevel]) do
			fnMargeAward(tbInfo);
		end
	else
		local tbPersonalAward = Fuben.tbFubenTemplate[nMapTemplateId].tbPersonalAward or {};
		local tbTotalRate = Fuben.tbFubenTemplate[nMapTemplateId].tbTotalRate or {};

		local tbSpAward, nSpRate;
		for _, tbInfo in pairs(tbPersonalAward or {}) do
			if tbInfo.nFubenLevel == nFubenLevel and tbInfo.nSpecialRate > 0 then
				tbSpAward = tbInfo;
				nSpRate = tbInfo.nSpecialRate;
			end
		end

		if nSpRate then
			local tbSpInfo = Lib:InitTable(tbRecord, "tbSpecialInfo", nFubenLevel, nSectionIdx);
			tbSpInfo[nSubSectionIdx] = tbSpInfo[nSubSectionIdx] or nSpRate;
			if MathRandom() <= tbSpInfo[nSubSectionIdx] then
				fnMargeAward(tbSpAward);
				tbSpInfo[nSubSectionIdx] = tbSpInfo[nSubSectionIdx] + nSpRate - 1;
			else
				tbSpInfo[nSubSectionIdx] = tbSpInfo[nSubSectionIdx] + nSpRate;
			end
		end

		self:NormalRandomAward(nFubenLevel, tbPersonalAward, tbTotalRate[nFubenLevel] or 0, fnMargeAward);
	end

	return tbResult;
end

function PersonalFuben:NormalRandomAward(nFubenLevel, tbAward, nTotalRate, fnMargeAward)
	local tbRandomCountInfo = self.tbLoseItemRandomCount[nFubenLevel];
	if not tbRandomCountInfo then
		return;
	end

	local nRandomCount = MathRandom(unpack(tbRandomCountInfo));

	-- 先掉固定奖励
	for _, tbInfo in pairs(tbAward) do
		if tbInfo.nFubenLevel == nFubenLevel and tbInfo.nRate == -1 then
			fnMargeAward(tbInfo);
		end
	end

	for i = 1, nRandomCount do
		local nRandom = MathRandom(0, nTotalRate);
		for _, tbInfo in pairs(tbAward) do
			if tbInfo.nRate > 0 and tbInfo.nFubenLevel == nFubenLevel and tbInfo.nSpecialRate <= 0 then
				if tbInfo.nRate >= nRandom then
					fnMargeAward(tbInfo);
					break;
				end

				nRandom = nRandom - tbInfo.nRate;
			end
		end
	end
end

-- 客户端数据合法性检查
function PersonalFuben:CheckDataRightful(tbServerData, tbClientData)
	return true;
end

function PersonalFuben:CheckCanFinishFuben(pPlayer, tbClientData)
	if not tbClientData or not tbClientData.bIsWin then
		return false, "您副本失敗了，沒有獎勵！";
	end

	local tbData = self:GetCurrentFubenData(pPlayer);
	local bRet, szMsg = self:CheckDataRightful(tbData, tbClientData);
	if not bRet then
		Lib:LogData(tbData, tbClientData);
		Log("[PersonalFuben] PersonalFuben:CheckCanFinishFuben ERR ?? nLastAvailable <= 0", pPlayer.szName, pPlayer.dwID);
		return false, szMsg or "非法遊戲數據！";
	end

	local nFubenIndex = tbData.nFubenIndex;
	local nFubenLevel = tbData.nFubenLevel;
	local tbFubenInfo = self:GetPersonalFubenInfo(nFubenIndex);
	if not tbFubenInfo then
		Lib:LogData(tbData, tbClientData);
		Log("[PersonalFuben] PersonalFuben:CheckCanFinishFuben ERR ?? tbFubenInfo is nil !!", pPlayer.szName, pPlayer.dwID);
		return false, "數據異常";
	end

	local nStarLevel = self:CalcFubenStarLevel(nFubenIndex, nFubenLevel, tbClientData);

	return true, "", nFubenIndex, nFubenLevel, tbData.tbAward or {}, nStarLevel, tbData.nStartTime;
end

function PersonalFuben:TryCreatePersonalFuben(pPlayer, nSectionIdx, nSubSectionIdx, nFubenLevel, tbHelperInfo)
	local bRet, szMsg, nMapTemplateIdOrErrCode, tbFubenSetting = self:CheckCanCreateFuben(pPlayer, nSectionIdx, nSubSectionIdx, nFubenLevel);
	if not bRet then
		local tbParam = {nSectionIdx = nSectionIdx, nSubSectionIdx = nSubSectionIdx, nFubenLevel = nFubenLevel};
		if not PersonalFuben:ProcessErr(pPlayer, nMapTemplateIdOrErrCode, tbParam) then
			pPlayer.CenterMsg(szMsg);
		end
		return;
	end

	local function fnQuitTeamAndCreateFuben(nPlayerId)
		local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
		if not pPlayer then
			return;
		end

		TeamMgr:QuiteTeam(pPlayer.dwTeamID, pPlayer.dwID);
		self:TryCreatePersonalFuben(pPlayer, nSectionIdx, nSubSectionIdx, nFubenLevel, tbHelperInfo);
	end

	if pPlayer.dwTeamID > 0 then
		pPlayer.MsgBox("組隊狀態無法進入關卡，是否退出目前隊伍？",
			{
				{"退出並進入", fnQuitTeamAndCreateFuben, pPlayer.dwID},
				{"取消"},
			})
		return;
	end

	local nFubenIndex = self:GetFubenIndex(nSectionIdx, nSubSectionIdx, nFubenLevel);
	local tbAward = self:GetRandomFubenAward(pPlayer, nSectionIdx, nSubSectionIdx, nFubenLevel);
	if not tbAward then
		Log("[PersonalFuben] PersonalFuben:TryCreatePersonalFuben ERR ?? tbAward is nil !!", pPlayer.szName, pPlayer.dwID, nSectionIdx, nSubSectionIdx);
	end

	local tbData = self:GetCurrentFubenData(pPlayer);
	tbData.nFubenIndex = nFubenIndex;
	tbData.nFubenLevel = nFubenLevel;
	tbData.nStartTime = GetTime();
	tbData.tbAward = tbAward;

	tbFubenSetting.tbBeginPoint = tbFubenSetting.tbBeginPoint or {};
	pPlayer.EnterClientMap(nMapTemplateIdOrErrCode, tbFubenSetting.tbBeginPoint[1] or 0, tbFubenSetting.tbBeginPoint[2] or 0);
	pPlayer.CallClientScript("Fuben:CreateFuben", nMapTemplateIdOrErrCode, nMapTemplateIdOrErrCode, nFubenLevel, tbAward, nFubenIndex, nFubenLevel, tbData.nStartTime, tbHelperInfo);
	LogD(Env.LOGD_ActivityPlay, pPlayer.szAccount, pPlayer.dwID, pPlayer.nLevel, string.format("%s_%s_%s", nSectionIdx, nSubSectionIdx, nFubenLevel), Env.LOGD_VAL_TAKE_TASK, Env.LOGD_MIS_PERSONAL_FUBEN, pPlayer.GetFightPower());
	Log("[PersonalFuben] CreateFuben", pPlayer.szAccount, pPlayer.dwID, pPlayer.szName, nSectionIdx, nSubSectionIdx, nFubenLevel, nMapTemplateIdOrErrCode);
end

function PersonalFuben:TryResetFubenTimes(pPlayer, nFubenIndex, nFubenLevel)
end

function PersonalFuben:OnSendResult(pPlayer, tbClientData)
	local bRet, szMsg, nFubenIndex, nFubenLevel, tbLocalAward, nStarLevel, nStartTime = self:CheckCanFinishFuben(pPlayer, tbClientData);
	if not bRet then
		pPlayer.Msg(szMsg);

		local tbData = self:GetCurrentFubenData(pPlayer);
		if tbClientData and not tbClientData.bIsWin and tbData and tbData.nFubenIndex and tbData.nFubenLevel then
			local nFailSectionIdx, nFailSubSectionIdx = self:GetSectionIdx(tbData.nFubenIndex, tbData.nFubenLevel);
			local szFailMissionId = string.format("%s_%s_%s", nFailSectionIdx, nFailSubSectionIdx, tbData.nFubenLevel);
		end
		return;
	end

	bRet, szMsg = self:TryCostFubenTimes(pPlayer, nFubenIndex, nFubenLevel);
	if not bRet then
		pPlayer.Msg(szMsg);
		return;
	end

	local tbFubenInfo = PersonalFuben:GetPersonalFubenInfo(nFubenIndex);
	if tbFubenInfo and tbFubenInfo.tbLeaveFubenPos and pPlayer.nMapTemplateId == tbFubenInfo.tbLeaveFubenPos[1] then
		pPlayer.SetPosition(unpack(tbFubenInfo.tbLeaveFubenPos, 2));
	end

	local nSectionIdx, nSubSectionIdx = self:GetSectionIdx(nFubenIndex, nFubenLevel);
	self:ClearCacheAward(pPlayer, nSectionIdx, nSubSectionIdx, nFubenLevel);
	self:ClearCurrentFubenData(pPlayer);

	pPlayer.CallClientScript("PersonalFuben:UpdatePersonalFubenInfo", nFubenLevel, nSectionIdx, nSubSectionIdx);

	local bFirstThreeStar = self:SetRecord(pPlayer, nSectionIdx, nSubSectionIdx, nFubenLevel, nStarLevel);

	if false then
		if tbClientData and tbClientData.nHelperId and nFubenLevel == self.PERSONAL_LEVEL_ELITE then
			Helper:OnUseHelper(pPlayer, tbClientData.nHelperId);
		end

		local tbAllAward = self:GetAwardInfo(tbLocalAward);
		self:MgrThreeStarAward(nFubenIndex, nFubenLevel, tbAllAward, bFirstThreeStar);
		local nTimes = 10 -- TODO: 之前是体力，改成策划需要的数值
		table.insert(tbAllAward, {"Exp", nTimes * pPlayer.GetBaseAwardExp()});

		local nMissionId = nSectionIdx * 10000 + nSubSectionIdx * 100 + nFubenLevel
		pPlayer.SendAward(tbAllAward, false, false, Env.LogWay_PersonalFuben, nMissionId);
		self:AddPartnerExp(pPlayer, nTimes);
	end

	pPlayer.OnEvent("OnFinishPersonalFuben", nFubenIndex, nFubenLevel, nStarLevel);
	pPlayer.CallClientScript("Fuben:OnFinishPersonalFuben", nSectionIdx, nSubSectionIdx, nFubenLevel);
	Log(string.format("PersonalFuben Win player[%s, %d] Fuben[%d, %d]", pPlayer.szName, pPlayer.dwID, nFubenIndex, nFubenLevel));
	pPlayer.TLogRoundFlow(Env.LogWay_PersonalFuben, nMissionId, 0, GetTime() - nStartTime, Env.LogRound_SUCCESS, 0, 0);
end

function PersonalFuben:MgrThreeStarAward(nFubenIndex, nFubenLevel, tbAward, bFirstThreeStar)
	if not bFirstThreeStar then
		return;
	end

	local tbSetting = self:GetPersonalFubenInfo(nFubenIndex);
	local tbExtAward = ((Fuben.tbFubenTemplate[tbSetting.nMapTemplateId] or {}).tbStarAward or {})[nFubenLevel];

	for _, tbInfo in pairs(tbExtAward or {}) do
		if tbInfo.nItemId > 0 and tbInfo.nCount > 0 then
			table.insert(tbAward, {"item", tbInfo.nItemId, tbInfo.nCount});
		elseif tbInfo.szType ~= "" then
			table.insert(tbAward, {tbInfo.szType, tbInfo.nCount});
		end
	end
end

function PersonalFuben:TryGetStarAward(pPlayer, nSectionIdx, nFubenLevel, nAwardIdx)
end

function PersonalFuben:TryMultiSweep(pPlayer, nSectionIdx, nSubSectionIdx, nFubenLevel)
	if true then
		return;
	end

	local bRet, szMsg, nAvailableTimes, bUseGold = PersonalFuben:CheckMultiSweep(me, nSectionIdx, nSubSectionIdx, nFubenLevel);
	if not bRet then
		me.CenterMsg(szMsg or "未知原因，無法掃蕩！");
		return;
	end
	local tbAllAward = {};
	for i = 1, nAvailableTimes do
		local tbResult = self:TrySweep(pPlayer, nSectionIdx, nSubSectionIdx, nFubenLevel, true);
		if tbResult then
			table.insert(tbAllAward, tbResult);
		end
	end

	return tbAllAward;
end

function PersonalFuben:TrySweep(pPlayer, nSectionIdx, nSubSectionIdx, nFubenLevel, bNotCheckBag)
	if true then
		return;
	end

	local bRet, szMsg, nFubenIndex, pItem, nNeedGold = self:CheckCanSweep(pPlayer, nSectionIdx, nSubSectionIdx, nFubenLevel, bNotCheckBag);
	if not bRet then
		pPlayer.CenterMsg(szMsg or "未知原因，無法掃蕩！");
		return;
	end

	local tbLocalAward = self:GetRandomFubenAward(pPlayer, nSectionIdx, nSubSectionIdx, nFubenLevel);
	if not tbLocalAward then
		pPlayer.CenterMsg("查找獎勵失敗！");
		Log("[PersonalFuben] PersonalFuben:TrySweep ERR ?? tbLocalAward is nil !!", pPlayer.szName, pPlayer.dwID, nSectionIdx, nSubSectionIdx, nFubenLevel);
		return;
	end

	bRet, szMsg = self:TryCostFubenTimes(pPlayer, nFubenIndex, nFubenLevel);
	if not bRet then
		pPlayer.Msg(szMsg);
		return;
	end

	if pItem then
		local nCount = pPlayer.ConsumeItem(pItem, 1, Env.LogWay_SweepFuben);
		if not nCount or nCount <= 0 then
			Log("[PersonalFuben] PersonalFuben:TrySweep ConsumeItem fail !!", pPlayer.szName, pPlayer.dwID, pItem.szName, nCount);
			return;
		end
	else
		if true then
			Log("[PersonalFuben] PersonalFuben:TrySweep Cost Gold Fail !!", pPlayer.szName, pPlayer.dwID, nNeedGold);
			return;
		end
	end

	self:ClearCacheAward(pPlayer, nSectionIdx, nSubSectionIdx, nFubenLevel);

	local tbAllAward = self:GetAwardInfo(tbLocalAward);
	local nTimes = 10
	table.insert(tbAllAward, {"Exp", nTimes * pPlayer.GetBaseAwardExp()});

	Helper:RandomUseFriendOrStranger(pPlayer);

	local nMissionId = nSectionIdx * 10000 + nSubSectionIdx * 100 + nFubenLevel
	pPlayer.SendAward(tbAllAward, false, false, Env.LogWay_PersonalFuben, nMissionId);
	self:AddPartnerExp(pPlayer, nTimes);
	pPlayer.OnEvent("OnFinishPersonalFuben", nFubenIndex, nFubenLevel, 3);
	Log(string.format("PersonalFuben Sweep player[%s, %d] Fuben[%d, %d]", pPlayer.szName, pPlayer.dwID, nFubenIndex, nFubenLevel));
	LogD(Env.LOGD_ActivityPlay, pPlayer.szAccount, pPlayer.dwID, pPlayer.nLevel, nMissionId, Env.LOGD_VAL_FINISH_TASK, Env.LOGD_MIS_PERSONAL_FUBEN, pPlayer.GetFightPower());
	return tbAllAward;
end

function PersonalFuben:AddPartnerExp(pPlayer, nGatherPoint)

end
