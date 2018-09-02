function RandomAward:Init()
	self.tbGroupList = {}
	self.tbRankAwardList = {}

	local tbAwardIdData = LoadTabFile("ServerSetting/RandomAward/RandomAward.tab", "dds", nil, {"AwardID", "GroupID", "TimeFrame"})

	if not tbAwardIdData then
		Log("[Error]", "RandomAward", "Load RandomAward Config Failed");
		return false
	end

	for _, tbInfo in pairs(tbAwardIdData) do
		self.tbGroupList[tbInfo.GroupID] = self.tbGroupList[tbInfo.GroupID] or {}
		local tbGroup = self.tbGroupList[tbInfo.GroupID]
		table.insert(tbGroup, tbInfo)
	end

	local tbRankAwardData = LoadTabFile("ServerSetting/RandomAward/RankAward.tab", "ddssd", nil, {"AwardID", "Rank", "Award", "AwardRate", "Rate"})

	if not tbRankAwardData then
		Log("[Error]", "RandomAward", "Load RankAward Config Failed");
		return false
	end

	for _, tbInfo in pairs(tbRankAwardData) do
		self.tbRankAwardList[tbInfo.AwardID] = self.tbRankAwardList[tbInfo.AwardID] or {};
		local tbAward = self.tbRankAwardList[tbInfo.AwardID]

		local tbAllAward = {};
		tbAllAward.tbAward = Lib:GetAwardFromString(tbInfo.Award);
		tbAllAward.nRateAward = tbInfo.Rate;
		tbAllAward.tbRateAward = Lib:GetAwardFromString(tbInfo.AwardRate);
		tbAward[tbInfo.Rank] = tbAllAward;
	end

	self:LoadKinAward()
	
	return true
end

function RandomAward:GetAwardIdByGroup(nGroupId)
	local tbGroup = self.tbGroupList[nGroupId]
	if not tbGroup then
		return
	end

	local tbAwardInfo = nil
	local nCurTimeFrameTime = -1;

	for _,tbInfo in ipairs(tbGroup) do
		if tbAwardInfo == nil and (tbInfo.TimeFrame == nil or tbInfo.TimeFrame == "") then
			tbAwardInfo = tbInfo
		elseif tbInfo.TimeFrame ~= nil and tbInfo.TimeFrame ~= "" and GetTimeFrameState(tbInfo.TimeFrame) == 1 then
			local nOpenTime = CalcTimeFrameOpenTime(tbInfo.TimeFrame)
			if nOpenTime > nCurTimeFrameTime then
				nCurTimeFrameTime = nOpenTime
				tbAwardInfo = tbInfo
			end
		end
	end

	return tbAwardInfo and tbAwardInfo.AwardID
end

function RandomAward:GetRankAwardInfo(nAwardId, nRank)
	local tbAward = self.tbRankAwardList[nAwardId]
	return tbAward and tbAward[nRank]
end

function RandomAward:SendRankAwardByNpc(nGroupId, pNpc, nLogWay)
	if not nGroupId or not pNpc then
		Log("[Error]", "RandomAward", "SendRankAwardByNpc Failed Wrong Param");
		return
	end

	local nAwardId = self:GetAwardIdByGroup(nGroupId)
	if not nAwardId then
		Log("[Error]", "RandomAward", "SendRankAwardByNpc Failed Wrong Award Group", nGroupId, pNpc.nId, pNpc.szName);
		return
	end

	local tbDmgInfo = pNpc.GetDamageInfo()

	if not tbDmgInfo or #tbDmgInfo <= 0 then
		Log("[Error]", "RandomAward", "SendRankAwardByNpc Failed Empty Dmg Info", nGroupId, pNpc.nId, pNpc.szName);
		return
	end

	local function fnDamageCmp(a, b)
		return a.nTotalDamage > b.nTotalDamage;
	end

	table.sort(tbDmgInfo, fnDamageCmp);

	Log("[Info]", "RandomAward", "------SendRankAwardByNpc Dmg Info------", nGroupId, pNpc.nId, pNpc.szName);
	Lib:LogTB(tbDmgInfo);

	local tbAllDmgPlayer = {};
	local tbDmgPlayerList = pNpc.GetDamagePlayerList();
	for _, tbInfo in pairs(tbDmgPlayerList) do
		tbAllDmgPlayer[tbInfo.nPlayerId] = true
	end

	local szAwardTitle = pNpc.szName;
	local nNpcMapId = pNpc.nMapId
	for nRank, tbDmg in ipairs(tbDmgInfo) do

		local tbTeam = nil;
		if tbDmg.nTeamId > 0 then
			tbTeam = TeamMgr:GetTeamById(tbDmg.nTeamId);
		end

		if tbTeam then
			local tbMember = TeamMgr:GetMembers(tbDmg.nTeamId);
			for _, nPlayerID in pairs(tbMember) do
				if tbAllDmgPlayer[nPlayerID] then
					self:SendPlayerRankAward(nPlayerID, nAwardId, nRank, nLogWay, szAwardTitle);
				end
			end
		elseif tbDmg.nAttackRoleId > 0 then
			self:SendPlayerRankAward(tbDmg.nAttackRoleId, nAwardId, nRank, nLogWay, szAwardTitle)
		end
	end
end

function RandomAward:SendPlayerRankAward(nPlayerId, nAwardId, nRank, nLogWay, szAwardTitle)
	local tbAllAward = self:GetRankAwardInfo(nAwardId, nRank)
	if not tbAllAward then
		Log("[Error]", "RandomAward", "SendPlayerRankAward Failed Empty tbAward", nPlayerId, nAwardId, nRank);
		return
	end

	if tbAllAward.tbAward and #tbAllAward.tbAward > 0  then
		self:SendPlayerAward(nPlayerId, tbAllAward.tbAward, nLogWay, szAwardTitle);
	end

	if tbAllAward.nRateAward and tbAllAward.nRateAward > 0 and
		tbAllAward.tbRateAward and #tbAllAward.tbRateAward > 0 then

		local nRate = MathRandom(100);
		if tbAllAward.nRateAward >= nRate then
			self:SendPlayerAward(nPlayerId, tbAllAward.tbRateAward, nLogWay, szAwardTitle);
		end
	end
end

function RandomAward:SendPlayerAward(nPlayerId, tbAward, nLogWay, szAwardTitle)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);

	if pPlayer and szAwardTitle then
		local _,nPosX, nPosY = pPlayer.GetWorldPos();
		pPlayer.DropAward(nPosX, nPosY, {szNpcName = szAwardTitle}, tbAward, nLogWay, nil, false, true);
	elseif pPlayer then
		pPlayer.SendAward(tbAward, false, true, nLogWay);
	else
		local tbMail =
		{
			To = nPlayerId,
			tbAttach = tbAward,
			nLogReazon = nLogWay,
		};

		if szAwardTitle then
			tbMail.Text = string.format(XT("從%s獲得的獎勵"), szAwardTitle)
		else
			tbMail.Text = XT("一份遺失的獎勵")
		end

		Mail:SendSystemMail(tbMail);
	end
end
