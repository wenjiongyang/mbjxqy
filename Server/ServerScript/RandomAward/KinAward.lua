function RandomAward:LoadKinAward()
	self.tbKinAwardList = {}

	local tbGroupData = LoadTabFile("ServerSetting/RandomAward/KinAwardGroup.tab", "dd", nil, {"GroupID", "BaseValue"})

	if not tbGroupData then
		Log("[Error]", "RandomAward", "Load KinAwardGroup Config Failed");
		return false
	end

	for _, tbInfo in pairs(tbGroupData) do
		self.tbKinAwardList[tbInfo.GroupID] = 
		{
			nGroupID = tbInfo.GroupID,
			nBaseValue = tbInfo.BaseValue,
			tbAwardList = {},
		}
	end

	local tbAwardData = LoadTabFile("ServerSetting/RandomAward/KinAward.tab", "ddsds", nil, {"GroupID", "ItemTemplate", "TimeFrame", "Factor", "GuaranteeKey"})

	if not tbAwardData then
		Log("[Error]", "RandomAward", "Load KinAward Config Failed");
		return false
	end

	for _, tbInfo in pairs(tbAwardData) do
		local tbGroup = self.tbKinAwardList[tbInfo.GroupID]
		if tbGroup then
			tbGroup.tbAwardList[tbInfo.TimeFrame] = tbGroup.tbAwardList[tbInfo.TimeFrame] or {}

			table.insert(tbGroup.tbAwardList[tbInfo.TimeFrame], 
			{
				nTemplateId = tbInfo.ItemTemplate,
				nFactor = tbInfo.Factor,
				nValue = KItem.GetBaseValue(tbInfo.ItemTemplate),
				szGuaranteeKey = tbInfo.GuaranteeKey,
			})
		else
			Log("[Error]", "RandomAward", "Load KinAward Info Not Found Group", tbInfo.GroupID);
		end
	end

	return true
end

function RandomAward:GetKinAwardByGroup(nGroupId)
	local tbGroup = self.tbKinAwardList[nGroupId]
	if not tbGroup then
		return
	end

	local szTimeFrame = Lib:GetMaxTimeFrame(tbGroup.tbAwardList)

	return tbGroup.tbAwardList[szTimeFrame], tbGroup
end

function RandomAward:GetKinAwardCount(nId, nTotalValue, nItemValue, szGuaranteeKey)
	if nItemValue <= 0 or nTotalValue <= 0 then
		return 0
	end

	local nCount = math.floor(nTotalValue/nItemValue)

	--超出的部分随机
	local nExtraRate = math.floor(100000 * math.mod(nTotalValue, nItemValue) / nItemValue)
	local nRand = MathRandom(100000)

	if nRand <= nExtraRate then
		nCount = nCount + 1
	end

	Log("[Info]", "GetKinAwardCount", nId,  nTotalValue, nItemValue, nRand, nExtraRate, tostring(szGuaranteeKey))
	return nCount
end

--已经用szGuaranteeKey = BossLeader_Boss_ ,
function RandomAward:GetKinGuaranteeAwardCount(nId, nTotalValue, nItemValue, szGuaranteeKey)
	if nItemValue <= 0 or nTotalValue <= 0 then
		return 0
	end

	local nCount = math.floor(nTotalValue/nItemValue)
	local nCurGuaranteeValue = 0;
	local nOldGuaranteeValue = 0;
	local tbKinData = Kin:GetKinById(nId) 

	if tbKinData then
		nCurGuaranteeValue = tbKinData:GetAwardGuarantee(szGuaranteeKey)
		nOldGuaranteeValue = nCurGuaranteeValue
	end

	local nExtraValue = math.mod(nTotalValue, nItemValue)
	local nRealExtraValue = nCurGuaranteeValue + nExtraValue;
	local nExtraCount = 0;

	if nCount <= 0 then
		--原始部分不足一个
		if nRealExtraValue > 0 then
			nExtraCount = math.floor(nRealExtraValue/nItemValue);
			nCount = nCount + nExtraCount
			if nCount <= 0 then
				local nExtraRate = math.floor(100000 * nRealExtraValue / nItemValue)
				local nRand = MathRandom(100000)
				--如果累计概率大于5%才参与随机否则继续累价值量
				if nExtraRate >= 5000 and nRand <= nExtraRate then
					nCount = nCount + 1
					nRealExtraValue = nRealExtraValue - nItemValue
				end
				Log("[Info]", "GetKinGuaranteeAwardCount", "Random", nRand, nExtraRate)
			else
				nRealExtraValue = nRealExtraValue - (nExtraCount * nItemValue)
			end
		end
	end

	if tbKinData then
		tbKinData:SetAwardGuarantee(szGuaranteeKey, nRealExtraValue)
	end

	Log("[Info]", "GetKinGuaranteeAwardCount", nId,  nTotalValue, nItemValue, math.floor(nTotalValue/nItemValue), nExtraCount, nCount, nOldGuaranteeValue, tostring(szGuaranteeKey), nRealExtraValue)
	return nCount
end

--[[
伤害排行数据如下格式
	{
		[1] = {
			nId = nKinId,
			szName = szKinName,
			nDmg = 0,
			nPercent = 0,
		},
	}

如果传入fnCalAwardValue 则调用该函数计算排名价值量(fnCalAwardValue(名次, 伤害百分比, 总价值, 奖励价值, 奖励价值系数) )
如果不传默认按照伤害百分比作为计算系数
]]
function RandomAward:GetKinAuctionAwardByRank(nGroupId, tbDmgRank, nMaxRank, fnCalAwardValue)
	local tbAwardList, tbGroup = self:GetKinAwardByGroup(nGroupId)
	if not tbAwardList then
		Log("[Error]", "RandomAward", "SendKinAwardByRank Not Found Award Group", nGroupId);
		Lib:LogTB(tbDmgRank)
		return {}
	end

	fnCalAwardValue = fnCalAwardValue or self.CalAwardValue
	local tbKinAwardList = {}
	for nRank, tbRankInfo in ipairs(tbDmgRank) do
		if nMaxRank and nRank > nMaxRank then
			break;
		end

		tbKinAwardList[tbRankInfo.nId] = tbKinAwardList[tbRankInfo.nId] or {}
		local tbKinAward = tbKinAwardList[tbRankInfo.nId]
		for _, tbAwardInfo in pairs(tbAwardList) do
			local nAwardValue = fnCalAwardValue(tbRankInfo.nId, nRank, tbRankInfo.nPercent,
					 tbGroup.nBaseValue, tbAwardInfo.nValue, tbAwardInfo.nFactor)

			local nCount = 0;

			if tbAwardInfo.szGuaranteeKey and tbAwardInfo.szGuaranteeKey ~= "" then
				nCount = self:GetKinGuaranteeAwardCount(tbRankInfo.nId, nAwardValue, tbAwardInfo.nValue, tbAwardInfo.szGuaranteeKey)
			else
				nCount = self:GetKinAwardCount(tbRankInfo.nId, nAwardValue, tbAwardInfo.nValue, tbAwardInfo.szGuaranteeKey)
			end

			if nCount > 0 then
				table.insert(tbKinAward, {tbAwardInfo.nTemplateId, nCount})
			end
		end
	end

	return tbKinAwardList
end

function RandomAward.CalAwardValue(nId, nRank, nPercent, nBaseValue, nValue, nFactor)
	return nBaseValue * (nPercent/100) * (nFactor/100000)
end