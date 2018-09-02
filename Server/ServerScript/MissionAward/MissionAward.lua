
MissionAward.tbAllAwardSetting = MissionAward.tbAllAwardSetting or {};
function MissionAward:GetAwardSetting(szAwardPath)
	if self.tbAllAwardSetting[szAwardPath] then
		return self.tbAllAwardSetting[szAwardPath];
	end

	local szType = "sddddd";
	local tbItemInfo = {"Type", "Item", "Count", "Addition", "Other", "SendWorld"};
	for _, szInfo in pairs(self.tbGradeInfo) do
		szType = szType .. "d";
		table.insert(tbItemInfo, szInfo);
	end

	local tbFile = LoadTabFile(szAwardPath, szType, nil, tbItemInfo);
	assert(tbFile, "[MissionAward] can not open award setting  " .. szAwardPath);

	self.tbAllAwardSetting[szAwardPath] = {};
	local tbAwardSetting = self.tbAllAwardSetting[szAwardPath];

	local function fnLoadItem(tbSetting, tbRow, nRate)
		if nRate <= 0 then
			return;
		end

		tbSetting.nTotalRate = (tbSetting.nTotalRate or 0) + nRate;
		table.insert(tbSetting, {szType = tbRow.Type, nItemId = tbRow.Item, nCount = tbRow.Count, nRate = tbSetting.nTotalRate, bSendWorld = (tbRow.SendWorld == 1)});
	end

	for _, tbRow in pairs(tbFile) do
		tbAwardSetting.tbAddition = tbAwardSetting.tbAddition or {};
		fnLoadItem(tbAwardSetting.tbAddition, tbRow, tbRow.Addition);

		tbAwardSetting.tbOther = tbAwardSetting.tbOther or {};
		fnLoadItem(tbAwardSetting.tbOther, tbRow, tbRow.Other);

		for i = 1, #self.tbGradeInfo do
			tbAwardSetting.tbGrade = tbAwardSetting.tbGrade or {};
			tbAwardSetting.tbGrade[i] = tbAwardSetting.tbGrade[i] or {};
			fnLoadItem(tbAwardSetting.tbGrade[i], tbRow, tbRow[self.tbGradeInfo[i]]);
		end
	end

	return self.tbAllAwardSetting[szAwardPath];
end

function MissionAward:RandomItem(varAwardType, szAwardPath, nItemCount, nRandomCount)
	nRandomCount = math.max(nRandomCount or 1, 1);
	local tbAwardSetting = self:GetAwardSetting(szAwardPath);
	if not tbAwardSetting then
		Log("[MissionAward] MissionAward:RandomItem ERR tbAwardSetting is nil !!");
		return;
	end

	local tbSetting = nil;
	if type(varAwardType) == "string" then
		tbSetting = tbAwardSetting["tb" .. varAwardType];
	elseif type(varAwardType) == "number" then
		tbSetting = tbAwardSetting.tbGrade[varAwardType];
	end

	if not tbSetting then
		Log("[MissionAward] MissionAward:RandomItem ERR tbSetting is nil !!");
		return;
	end


	local function fnGetValue(tbInfo)
		local nValue = 0;
		local tbA = {"item", tbInfo.nItemId, 1};
		if tbInfo.szType and tbInfo.szType ~= "" then
			tbA = {tbInfo.szType, tbInfo.nCount};
		end

		return Player:GetAwardValue(tbA);
	end

	local function fnRandom()
		local tbRA = {};
		local nValue = 0;
		for i = 1, nItemCount do
			local nRate = MathRandom(tbSetting.nTotalRate);
			for _, tbInfo in ipairs(tbSetting) do
				if nRate < tbInfo.nRate then
					nValue = nValue + fnGetValue(tbInfo);
					table.insert(tbRA, tbInfo);
					break;
				end
			end
		end

		return tbRA, nValue;
	end

	local tbResult = nil;
	local nCurValue = 0;
	for i = 1, nRandomCount or 1 do
		local tbRA, nTotalValue = fnRandom();
		if nTotalValue >= nCurValue then
			tbResult = tbRA;
			nCurValue = nTotalValue;
		end
	end

	return tbResult;
end

function MissionAward:RandomAward(nGrade, nType, szAwardPath)
	local tbGradeItem = self:RandomItem(nGrade, szAwardPath, 1);
	local tbAddition = self:RandomItem("Addition", szAwardPath, self.MAX_REAL_ITEM_COUNT - 1);
	local tbOther = self:RandomItem("Other", szAwardPath, self.MAX_ITEM_COUNT - self.MAX_REAL_ITEM_COUNT, self:GetOtherRandomCount(nType, nGrade));

	local tbAllAward = {};
	local tbAwardPos = {};
	local fnSelect = Lib:GetRandomSelect(self.MAX_ITEM_COUNT);
	for i = 1, self.MAX_ITEM_COUNT do
		local nPos = fnSelect();
		if i <= self.MAX_REAL_ITEM_COUNT then
			tbAwardPos[i] = nPos;
			tbAllAward[nPos] = (i == 1) and tbGradeItem[1] or tbAddition[i - 1];
		else
			tbAllAward[nPos] = tbOther[i - self.MAX_REAL_ITEM_COUNT];
		end
	end

	return tbAllAward, tbAwardPos;
end

function MissionAward:GetPlayerRecord(pPlayer, nType)
	local tbAllRecord = pPlayer.GetScriptTable("MissionAward");
	tbAllRecord.tbAwardRecord = tbAllRecord.tbAwardRecord or {};
	tbAllRecord.tbAwardRecord[nType] = tbAllRecord.tbAwardRecord[nType] or {};

	tbAllRecord.tbScoreInfo = tbAllRecord.tbScoreInfo or {};
	tbAllRecord.tbScoreInfo[nType] = tbAllRecord.tbScoreInfo[nType] or {};

	return tbAllRecord.tbAwardRecord[nType], tbAllRecord.tbScoreInfo[nType];
end

function MissionAward:GetPlayerAllAwardRecord(pPlayer)
	local tbAllRecord = pPlayer.GetScriptTable("MissionAward");
	tbAllRecord.tbAwardRecord = tbAllRecord.tbAwardRecord or {};
	return tbAllRecord.tbAwardRecord;
end

function MissionAward:GetAwardListList(pPlayer)
	local tbAllData = self:GetPlayerAllAwardRecord(pPlayer);
	local tbResult = {};
	for nType, tbData in pairs(tbAllData) do
		self:ClearTimeoutRecord(pPlayer, nType, tbData);
		for nId, tbRecord in ipairs(tbData) do
			local szName = tbRecord.szName or self.tbMissionName[nType] or "未領獎勵";
			local bHasFreeTimes = tbRecord.nCurIdx < tbRecord.nAwardIdx;
			table.insert(tbResult, {nType = nType, nRecordId = nId, szName = szName, bHasFreeTimes = bHasFreeTimes});
		end
	end

	pPlayer.CallClientScript("MissionAward:OnGetRecordList", tbResult);
end

function MissionAward:GetPlayerAllScoreInfo(pPlayer)
	local tbAllRecord = pPlayer.GetScriptTable("MissionAward");
	tbAllRecord.tbScoreInfo = tbAllRecord.tbScoreInfo or {};
	return tbAllRecord.tbScoreInfo;
end

function MissionAward:MakeRecord(pPlayer, nType, nGrade, szAwardPath, szName, ...)
	local tbAllAward, tbAwardPos = self:RandomAward(nGrade, nType, szAwardPath);

	local tbRecord = {
		szName = szName;
		nGrade = nGrade;
		tbAllAward = tbAllAward;
		tbAwardPos = tbAwardPos;
		nCurIdx = 0;
		nTime = GetTime();
		nAwardIdx = self.MAX_FREE_COUNT;
		tbParam = {...};
	};

	local nIdx = self:SaveRecord(pPlayer, nType, tbRecord);
	return nIdx;
end

function MissionAward:RefreshRecord(pPlayer, nType, tbData)
	local nMaxCount = MissionAward:GetMaxAwardTimes(pPlayer, nType);
	nMaxCount = math.min(nMaxCount, self.MAX_RECORD_COUNT);

	for i = #tbData, 1, -1 do
		if tbData[i].nCurIdx >= nMaxCount then
			table.remove(tbData, i);
		end
	end
end

function MissionAward:ShowMissionAward(pPlayer, szTitle, nType, nRecordId)
	local tbData = self:GetPlayerRecord(pPlayer, nType);
	local tbRecord = tbData[nRecordId];
	if not tbRecord then
		Log("[MissionAward] ShowMissionAward ERR ?? find tbRecord fail !! ", szTitle, nType, nRecordId);
		return;
	end

	local tbAwardPos = {};
	for i = 1, tbRecord.nCurIdx do
		table.insert(tbAwardPos, tbRecord.tbAwardPos[i]);
	end

	pPlayer.CallClientScript("Ui:OpenWindow", "MissionAward", szTitle or tbRecord.szName, nType, nRecordId, tbRecord.nGrade, tbAwardPos, tbRecord.tbAllAward);
end

function MissionAward:SaveRecord(pPlayer, nType, tbRecord)
	local tbData = self:GetPlayerRecord(pPlayer, nType);

	table.insert(tbData, tbRecord);
	self:ClearTimeoutRecord(pPlayer, nType, tbData);
	if #tbData > self.MAX_RECORD_COUNT + 1 then
		table.remove(tbData, 1);
	end

	return #tbData;
end

function MissionAward:ClearTimeoutRecord(pPlayer, nType, tbData)
	self:RefreshRecord(pPlayer, nType, tbData);

	local nLastId = -1;
	for i = #tbData, 1, -1 do
		if nLastId < 0 and tbData[i].nAwardIdx <= tbData[i].nCurIdx then
			nLastId = i;
		elseif tbData[i].nAwardIdx <= tbData[i].nCurIdx then
			table.remove(tbData, i);
		end
	end
end

function MissionAward:AddAwardIdx(pPlayer, nType, nRecordId)
	local tbData = self:GetPlayerRecord(pPlayer, nType);
	local tbRecord = tbData[nRecordId];
	if not tbRecord then
		Log("[MissionAward] AddAwardIdx ERR ?? tbRecord is nil !!", pPlayer.szName, pPlayer.dwID, nRecordId);
		return;
	end

	local nMaxCount = self:GetMaxAwardTimes(pPlayer, nType);
	nMaxCount = math.min(nMaxCount, #tbRecord.tbAwardPos);
	if tbRecord.nCurIdx > nMaxCount then
		pPlayer.CenterMsg("目前已達最大抽獎次數，不能獲取多餘的次數了！");
		return;
	end

	local nGold = MissionAward:GetConsumeInfo(nType, tbRecord.nCurIdx + 1);
	if not nGold then
		Log("[MissionAward] AddAwardIdx ERR ?? nGold is nil !!", nType, tbRecord.nCurIdx + 1);
		return;
	end

	local fnCostCallback = function (nPlayerId, bSuccess, szBillNo, nType, nRecordId, nAwardIdx)
		return self:CostGold_AddAwardIdx(nPlayerId, bSuccess, nType, nRecordId, nAwardIdx);
	end

	-- CostGold谨慎调用, 调用前请搜索 _LuaPlayer.CostGold 查看使用说明, 它处调用时请保留本注释
	local bRet = pPlayer.CostGold(nGold, Env.LogWay_MissionAwardAdd, tbRecord.nCurIdx, fnCostCallback, nType, nRecordId, tbRecord.nAwardIdx);
	if not bRet then
		pPlayer.CenterMsg("扣除金幣失敗!");
		return;
	end
end

function MissionAward:CostGold_AddAwardIdx(nPlayerId, bSuccess, nType, nRecordId, nAwardIdx)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return false, "購買次數中途, 您離線了";
	end

	if not bSuccess then
		return false, "支付失敗請稍後再試";
	end

	local tbData = self:GetPlayerRecord(pPlayer, nType);
	local tbRecord = tbData[nRecordId];
	if not tbRecord or tbRecord.nCurIdx ~= nAwardIdx then
		return false, "付款超時";
	end

	local nMaxCount = self:GetMaxAwardTimes(pPlayer, nType);
	nMaxCount = math.min(nMaxCount, #tbRecord.tbAwardPos);
	if tbRecord.nCurIdx > nMaxCount then
		return false, "已達最大抽獎次數";
	end

	tbRecord.nAwardIdx = tbRecord.nAwardIdx + 1;
	self:GetAwardInfo(pPlayer, nType, nRecordId);
	return true;
end

function MissionAward:GetAwardInfo(pPlayer, nType, nRecordId)
	local tbData = self:GetPlayerRecord(pPlayer, nType);
	local tbRecord = tbData[nRecordId];

	if not tbRecord then
		pPlayer.Msg("未發現相應獎勵！");
		Lib:LogTB(tbData);
		Log("[MissionAward] GetAwardInfo ERR ?? tbRecord is nil !!", pPlayer.szName, pPlayer.dwID, nRecordId);
		return;
	end

	local nMaxCount = self:GetMaxAwardTimes(pPlayer, nType);
	nMaxCount = math.min(nMaxCount, #tbRecord.tbAwardPos);
	if tbRecord.nCurIdx > nMaxCount then
		return;
	end

	local bHasResult = true;
	local nValue = tbRecord.tbAwardPos[tbRecord.nCurIdx + 1];
	if tbRecord.nAwardIdx <= tbRecord.nCurIdx then
		local nGold = MissionAward:GetConsumeInfo(nType, tbRecord.nCurIdx + 1);
		if not nGold then
			Log("[MissionAward] GetAwardInfo ERR ?? nGold is nil !!", nType, tbRecord.nCurIdx + 1);
			return;
		end

		nValue = nGold;
		bHasResult = false;
	end

	pPlayer.CallClientScript("MissionAward:OnGetResult", bHasResult, nValue);
end

function MissionAward:GetAward(pPlayer, nType, nRecordId)
	local tbData = self:GetPlayerRecord(pPlayer, nType);
	local tbRecord = tbData[nRecordId];
	if not tbRecord then
		pPlayer.Msg("查找獎勵失敗！");
		Lib:LogTB(tbData);
		Log("[MissionAward] ERR ?? tbRecord is nil !!", pPlayer.szName, pPlayer.dwID, nRecordId);
		return;
	end

	if tbRecord.nAwardIdx <= tbRecord.nCurIdx then
		Log("[MissionAward] GetAward ERR ?? tbRecord.nAwardIdx <= tbRecord.nCurIdx ?? ", pPlayer.szName, pPlayer.dwID, nRecordId, tbRecord.nAwardIdx, tbRecord.nCurIdx);
		return;
	end

	local nPos = tbRecord.tbAwardPos[tbRecord.nCurIdx + 1] or 9999;
	tbRecord.nCurIdx = tbRecord.nCurIdx + 1;
	self:RefreshRecord(pPlayer, nType, tbData);

	local tbAward = tbRecord.tbAllAward[nPos];
	local tbResult = {};
	local bItemAward = false;
	if not tbAward.szType or tbAward.szType == "" then
		table.insert(tbResult, {"item", tbAward.nItemId, 1});
		bItemAward = true;
	else
		table.insert(tbResult, {tbAward.szType, tbAward.nCount});
	end


	pPlayer.SendAward(tbResult, false, false, Env.LogWay_MissionAward, nType * 1000 + tbRecord.nCurIdx - 1);
	if tbAward.bSendWorld and bItemAward then
		local tbItemInfo = KItem.GetItemBaseProp(tbAward.nItemId) or {szName = "未知道具"};
		KPlayer.SendWorldNotify(0, 1000, string.format("%s 在副本抽獎中幸運的獲取 %s 一件", pPlayer.szName, tbItemInfo.szName), 1, 1);
	end

	local tbAwardPos = {};
	for i = 1, tbRecord.nCurIdx do
		table.insert(tbAwardPos, tbRecord.tbAwardPos[i]);
	end

	pPlayer.CallClientScript("MissionAward:OnMissionUpdate", nType, nRecordId, tbAwardPos);
end

-- bIsNormalLogic  通用逻辑是指 如果玩家发生掉线，当玩家再次上线（非重连）的时候会根据当前记录的分数自动生成奖励
function MissionAward:CreateScoreRecord(pPlayer, nType, szAwardFilePath, bNotNormalLogic, szName)
	self:GenerateAward(pPlayer, nType);
	local _, tbScoreInfo = self:GetPlayerRecord(pPlayer, nType);
	tbScoreInfo.nScore = tbScoreInfo.nScore or 0;
	tbScoreInfo.szAwardFilePath = szAwardFilePath;
	tbScoreInfo.bNotNormalLogic = bNotNormalLogic;
	tbScoreInfo.szName = szName;
end

function MissionAward:AddMissionScore(pPlayer, nType, nScore)
	local _, tbScoreInfo = self:GetPlayerRecord(pPlayer, nType);
	if not tbScoreInfo.nScore then
		Log("[MissionAward] AddMissionScore ERR ?? without use MissionAward:CreateScoreRecord ??");
		return;
	end

	tbScoreInfo.nScore = tbScoreInfo.nScore + nScore;
	return tbScoreInfo.nScore;
end

function MissionAward:GetScore(pPlayer, nType)
	local _, tbScoreInfo = self:GetPlayerRecord(pPlayer, nType);
	return tbScoreInfo.nScore or 0;
end

-- 根据玩家当前记录分数生成玩家事后奖励，如果不存在则不做任何操作
function MissionAward:GenerateAward(pPlayer, nType, szAwardPath, szName)
	local _, tbScoreInfo = self:GetPlayerRecord(pPlayer, nType);
	if not tbScoreInfo.nScore then
		return;
	end

	local nGrade = self:GetGrade(nType, tbScoreInfo.nScore);
	if not nGrade then
		return;
	end

	if not szAwardPath then
		szAwardPath = tbScoreInfo.szAwardFilePath or self:GetAwardFile(nType);
		if not szAwardPath then
			Log("[MissionAward] GenerateAward ERR ?? unknow AwardPath " .. szAwardPath);
			return;
		end
	end

	tbScoreInfo.nScore = nil;
	return MissionAward:MakeRecord(pPlayer, nType, nGrade, szAwardPath, szName);
end

function MissionAward:OnLogin(bIsReconnect)
	if bIsReconnect then
		return;
	end

	local tbAllScoreInfo = self:GetPlayerAllScoreInfo(me);
	for nType, tbInfo in pairs(tbAllScoreInfo) do
		if not tbInfo.bNotNormalLogic then
			self:GenerateAward(pPlayer, nType, tbInfo.szAwardFilePath, tbInfo.szName);
		end
	end
end
