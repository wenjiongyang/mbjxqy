local MAX_TOTAL_DROP_RATE = 1000000;

local MAX_USE_DROP_RATE = MAX_TOTAL_DROP_RATE * 1000;

-- 各种分配方式
Npc.LOST_TYPE_NORMAL = 0;			-- 普通掉落方式，整体掉落，然后均分
Npc.LOST_TYPE_EVERY_PLAYER = 1;		-- 单人掉落模式，针对每个人分别按照配置表掉落，然后全部归此人

function Npc:LoadDropAwardDebtSetting()
	self.tbNpcDropDebtSetting = {}

	local tbFile = LoadTabFile("Setting/Npc/DropFile/DropAwardDebtSetting.tab", "dd", nil, {"nOrgItemId", "nDstItemId"});
	for _, tbRow in pairs(tbFile) do
		local tbOrgItemInfo = KItem.GetItemBaseProp(tbRow.nOrgItemId);
		local tbDstItemInfo = KItem.GetItemBaseProp(tbRow.nDstItemId);
		if tbOrgItemInfo and tbDstItemInfo and tbOrgItemInfo.nValue > tbDstItemInfo.nValue then
			local nValue = tbOrgItemInfo.nValue - tbDstItemInfo.nValue;
			self.tbNpcDropDebtSetting[tbRow.nOrgItemId] = {tbRow.nDstItemId, nValue};
		else
			Log("[Npc] LoadDropAwardDebtSetting ERR !!!!", tbRow.nOrgItemId, tbRow.nDstItemId);
		end
	end
end

function Npc:LoadDropFile(szDropFile)
	local tbFile = LoadTabFile(szDropFile, "ssssssdddsd", nil, {"TimeFrame", "AwardType", "AwardValue1", "AwardValue2", "AwardValue3", "RandRate", "WorldNotify", "KinNotify", "TeamNotify", "XiuLianRate", "IntoAuction"});
	if not tbFile then
		Log("[Npc] LoadDropFile ERR ?? tbFile is nil !!!", szDropFile);
		return {};
	end

	local tbTimeFrameDrop = {};
	local nCurRate = 0;
	local nCurXiuLianRate = 0;
	for _, tbRow in pairs(tbFile) do
		local szTimeFrame = tbRow.TimeFrame;
		if Lib:IsEmptyStr(szTimeFrame) then
			szTimeFrame = "-1";
		end

		local tbResult = tbTimeFrameDrop[szTimeFrame];
		if not tbResult then
			tbResult = {};
			tbResult.tbMustDrop = {};
			tbResult.tbRandomDrop = {};
			tbResult.nTotalRate = 0;
			tbResult.nTotalRateXiuLian = 0;
			tbTimeFrameDrop[szTimeFrame] = tbResult;
		end

		local tbDrop = tbResult.tbRandomDrop;

		if tbRow.RandRate == "" then
			tbRow.RandRate = 0;
		end

		tbRow.RandRate = tonumber(tbRow.RandRate);
		if (type(tbRow.RandRate) ~= "number") then
			Log("DropRate Error!!!!!!", szDropFile);
			tbRow.RandRate = 0
		end

		if tbRow.RandRate == -1 then
			tbDrop = tbResult.tbMustDrop;
		else
			tbRow.RandRate = math.floor(tbRow.RandRate * 1000);
			tbResult.nTotalRate = tbResult.nTotalRate + tbRow.RandRate;
			if tbRow.XiuLianRate and tbRow.XiuLianRate ~= "" then

				tbRow.XiuLianRate = tonumber(tbRow.XiuLianRate);
				assert(type(tbRow.XiuLianRate) == "number" and tbRow.XiuLianRate > 0);

				tbRow.XiuLianRate = math.floor(tbRow.XiuLianRate * 1000);
				tbResult.nTotalRateXiuLian = tbResult.nTotalRateXiuLian + tbRow.XiuLianRate;
			end
		end

		local nValueCount = 1;
		for i = 1, 3 do
			local value = tbRow["AwardValue" .. i];
			if value and value ~= "" then
				nValueCount = i;
				value = tonumber(value);
				tbRow["AwardValue" .. i] = value and value or tbRow["AwardValue" .. i];
			end
		end

		local tbAward = {
							tbRow.AwardType,
							nWorldNotify = tbRow.WorldNotify,
							nKinNotify = tbRow.KinNotify,
							nTeamNotify = tbRow.TeamNotify,
						};
		for i = 1, nValueCount do
			table.insert(tbAward, tbRow["AwardValue" .. i]);
		end

		-- 进个人拍卖的只有item -- 删除个人拍卖入口。。。
		-- if Player.AwardType[tbRow.AwardType] == Player.award_type_item and tbRow.IntoAuction > 0 then
		-- 	tbAward.bIntoAuction = true;
		-- end

		table.insert(tbDrop, {tbAward = tbAward, nRate = tbResult.nTotalRate, nRateXiuLian = tbResult.nTotalRateXiuLian});
	end

	for _, tbResult in pairs(tbTimeFrameDrop) do
		if tbResult.nTotalRate > MAX_USE_DROP_RATE or tbResult.nTotalRateXiuLian > MAX_USE_DROP_RATE then
			Log("[Npc] LoadDropFile ERR ?? nCurRate >= MAX_USE_DROP_RATE !!", szDropFile);
			tbResult = {};
		end
	end

	return tbTimeFrameDrop;
end

function Npc:SetPlayerNoDropMap(pPlayer, nMapId)
	pPlayer.tbNoNpcDropMapInfo = pPlayer.tbNoNpcDropMapInfo or {};
	pPlayer.tbNoNpcDropMapInfo[nMapId] = true;
end

function Npc:GetDropAward(szDropFile)
	self.tbAllDropInfo = self.tbAllDropInfo or {};
	if not self.tbAllDropInfo[szDropFile] then
		self.tbAllDropInfo[szDropFile] = self:LoadDropFile(szDropFile);
	end
	local tbTimeFrameDrop = self.tbAllDropInfo[szDropFile];

	local szTimeFrame = Lib:GetMaxTimeFrame(tbTimeFrameDrop);
	if Lib:IsEmptyStr(szTimeFrame) then
		szTimeFrame = "-1";
	end

	return tbTimeFrameDrop[szTimeFrame] or {};
end

function Npc:RandomAward(nTreasure, szDropFile, bXiuLianRate, tbDropAward)
	if nTreasure <= 0 or not szDropFile then
		return;
	end

	if not tbDropAward then
		tbDropAward = self:GetDropAward(szDropFile);
		if not tbDropAward then
			return;
		end
	end

	local tbAward = {};
	for _, tbInfo in pairs(tbDropAward.tbMustDrop) do
		table.insert(tbAward, tbInfo.tbAward)
	end

	local nTotalRate = tbDropAward.nTotalRate;
	if bXiuLianRate then
		nTotalRate = tbDropAward.nTotalRateXiuLian;
	end

	for i = 1, nTreasure do
		local nRandom = MathRandom(MAX_USE_DROP_RATE);
		if nRandom <= nTotalRate then

			for _, tbInfo in ipairs(tbDropAward.tbRandomDrop) do
				local nCurDropRate = tbInfo.nRate;
				if bXiuLianRate then
					nCurDropRate = tbInfo.nRateXiuLian;
				end

				if nRandom < nCurDropRate then
					table.insert(tbAward, tbInfo.tbAward)
					break;
				end
			end

		end
	end

	return tbAward;
end

function Npc:GetDamageFirstTeam(pNpc, tbDamageInfo, nPosLen)
	for nRank, tbDamage in ipairs(tbDamageInfo) do
		local tbPlayer, pCaptain = self:GetAssignPlayer(pNpc, tbDamage, nPosLen);
		if tbPlayer and #tbPlayer > 0 then
			return tbPlayer, pCaptain;
		end
	end
end

function Npc:CalcNpcDeath(pNpc, pKiller)
	local tbDamageInfo = pNpc.GetDamageInfo();
	if not tbDamageInfo or #tbDamageInfo <= 0 then
		return;
	end

	local function fnDamageCmp(a, b)
		return a.nTotalDamage > b.nTotalDamage;
	end

	table.sort(tbDamageInfo, fnDamageCmp);

	local szClassName = pNpc.szClass;
	local tbNpcTInfo = KNpc.GetNpcTemplateInfo(pNpc.nTemplateId);
    if not Lib:IsEmptyStr(tbNpcTInfo.szDropFile) then
    	Npc:DropAward(pNpc, tbDamageInfo, tbNpcTInfo.nTreasure, tbNpcTInfo.szDropFile, tbNpcTInfo.nDropType);
    end

    local tbClassNpc = nil;
	if not Lib:IsEmptyStr(szClassName) then
		tbClassNpc = Npc:GetClass(szClassName);
	end

    if tbClassNpc and tbClassNpc.DeathCalcAward then
    	tbClassNpc:DeathCalcAward(pNpc, tbDamageInfo, pKiller);
    end

    local pMainNpc = nil;
    local tbFirstDmg = tbDamageInfo[1];
    if tbFirstDmg and tbFirstDmg.nLastDmgNpcID then
    	pMainNpc = KNpc.GetById(tbFirstDmg.nLastDmgNpcID);
    end

    return pMainNpc;
end

function Npc:DropAward(pNpc, tbDamageInfo, nTreasure, szDropFile, nDropType)
	local tbPlayer = nil;
	if Npc:IsFieldNpc(pNpc.szClass) or
		ImperialTomb:IsNormalMapByTemplate(pNpc.nMapTemplateId) then
		local tbDamage = tbDamageInfo[1];
		if tbDamage then
			tbPlayer = self:GetAssignPlayer(pNpc, tbDamage, Npc.nMaxAwardLen);
		end
	else
		tbPlayer = Npc:GetDamageFirstTeam(pNpc, tbDamageInfo);
	end

	if not tbPlayer or #tbPlayer <= 0 then
		return;
	end

	-- 这新加分配类型的时候，注意禁止掉落功能处理  pPlayer.tbNoNpcDropMapInfo
	if nDropType == Npc.LOST_TYPE_EVERY_PLAYER then
		self:AssignEveryPlayer(pNpc, tbPlayer, nTreasure, szDropFile);
	else
		self:AssignNormal(pNpc, tbPlayer, nTreasure, szDropFile);
	end
end

--tbPlayer[i] = {
--	{pPlayer = me, tbAward = {}},
--}
function Npc:AssignNormal(pNpc, tbPlayer, nTreasure, szDropFile)
	local tbAward = self:RandomAward(nTreasure, szDropFile);
	if not tbAward then
		return {};
	end

	local tbMsg = {szNpcName = pNpc.szName};
	local _, nPosX, nPosY = pNpc.GetWorldPos();
	if #tbPlayer == 1 then
		if not tbPlayer[1].pPlayer.tbNoNpcDropMapInfo or not tbPlayer[1].pPlayer.tbNoNpcDropMapInfo[tbPlayer[1].pPlayer.nMapId] then
			Npc:DropAwardToPlayer(tbPlayer[1].pPlayer, nPosX, nPosY, tbMsg, tbAward, Env.LogWay_NpcDropAward, pNpc.nTemplateId);
		end
		return {tbPlayer[1].pPlayer};
	end

	local tbTmp = {};
	local tbResult = {};
	local tbAvailable = {};
	local fnSelectPlayer = Lib:GetRandomSelect(#tbPlayer);
	for _, tbInfo in pairs(tbAward) do
		local tbPlayerInfo = tbPlayer[fnSelectPlayer()];
		if not tbTmp[tbPlayerInfo.pPlayer.dwID] then
			tbTmp[tbPlayerInfo.pPlayer.dwID] = true;
			table.insert(tbResult, tbPlayerInfo.pPlayer);
		end
		table.insert(tbPlayerInfo.tbAward, tbInfo);
	end

	for _, tbPlayerInfo in pairs(tbPlayer) do
		if not tbPlayerInfo.pPlayer.tbNoNpcDropMapInfo or not tbPlayerInfo.pPlayer.tbNoNpcDropMapInfo[tbPlayerInfo.pPlayer.nMapId] then
			Npc:DropAwardToPlayer(tbPlayerInfo.pPlayer, nPosX, nPosY, tbMsg, tbPlayerInfo.tbAward, Env.LogWay_NpcDropAward,  pNpc.nTemplateId);
		end
	end

	return tbResult;
end

function Npc:DropAwardToPlayer(pPlayer, nPosX, nPosY, tbMsg, tbAward, nLogReazon, nLogReazon2, bMsg, bShowUi)
	local nValue = Player:GetRewardValueDebt(pPlayer.dwID);
	if nValue <= 0 then
		pPlayer.DropAward(nPosX, nPosY, tbMsg, tbAward, nLogReazon, nLogReazon2, bMsg, bShowUi);
		return;
	end

	if not self.tbNpcDropDebtSetting then
		self:LoadDropAwardDebtSetting();
	end

	local nCostValue = 0;
	for i = 1, #tbAward do
		local tbInfo = tbAward[i];
		if nCostValue >= nValue then
			break;
		end

		if Player.AwardType[tbInfo[1]] == Player.award_type_item and self.tbNpcDropDebtSetting[tbInfo[2]] then
			-- 转换为元宝为单位
			nCostValue = nCostValue + (self.tbNpcDropDebtSetting[tbInfo[2]][2] * (tbInfo[3] or 1) / 1000);
			tbAward[i] = {"item", self.tbNpcDropDebtSetting[tbInfo[2]][1], (tbInfo[3] or 1)};
		end
	end

	nCostValue = math.floor(nCostValue);
	if nCostValue > 0 then
		nCostValue = math.min(nCostValue, nValue);
		Player:CostRewardValueDebt(pPlayer.dwID, nCostValue, nLogReazon, nLogReazon2);
	end

	pPlayer.DropAward(nPosX, nPosY, tbMsg, tbAward, nLogReazon, nLogReazon2, bMsg, bShowUi);
end

function Npc:IsFieldNpc(szNpcClass)
    if szNpcClass == "FieldMapNpc" then
    	return true;
	end

	return false;
end

function Npc:AssignEveryPlayer(pNpc, tbPlayer, nTreasure, szDropFile)
	local _, nPosX, nPosY = pNpc.GetWorldPos();
	local bCalcXiuLian 	  = false;
	local nIsTransBossNpc = pNpc.IsTransBossNpc();
	local LogWay = Env.LogWay_NpcDropAward;
	if Npc:IsFieldNpc(pNpc.szClass) then
		bCalcXiuLian = true;
		LogWay = Env.LogWay_XiuLian;
	end

	local tbDropAward = self:GetDropAward(szDropFile);
	local tbMsg = {szNpcName = pNpc.szName};
	for _, tbPlayerInfo in pairs(tbPlayer) do
		local pPlayer         = tbPlayerInfo.pPlayer;
		local nCurTreasure    = nTreasure;
		local bCurXiuLianRate = false;

		if bCalcXiuLian then
			local nXLTrCount, bXiuLianRate = XiuLian:CalcXiuLianDrop(pPlayer, nIsTransBossNpc);
			if nXLTrCount > 0 then
				nCurTreasure = nXLTrCount;
			end
			bCurXiuLianRate = bXiuLianRate;
		end

		local tbAward = self:RandomAward(nCurTreasure, szDropFile, bCurXiuLianRate, tbDropAward);
		if not tbAward or not Lib:HaveCountTB(tbAward) then
			return;
		end

		if not pPlayer.tbNoNpcDropMapInfo or not pPlayer.tbNoNpcDropMapInfo[pPlayer.nMapId] then
			Npc:DropAwardToPlayer(pPlayer, nPosX, nPosY, tbMsg, tbAward, LogWay, pNpc.nTemplateId);
		end
	end
end

function Npc:CheckPlayerMapAssign(pPlayer, nMapId, nPosX, nPosY, nPosLen)
	local nPlayerMapId, nPlayerPosX, nPlayerPosY = pPlayer.GetWorldPos();
	if nPlayerMapId ~= nMapId then
		return false;
	end

    if not nPosLen then
    	return true;
    end

    local nSquLen = Lib:GetDistsSquare(nPlayerPosX, nPlayerPosY, nPosX, nPosY);
    if nSquLen > nPosLen * nPosLen then
    	return false;
    end

    return true;
end

function Npc:GetAssignPlayer(pNpc, tbDamage, nPosLen, nMainAttackID)
	local tbPlayer = nil;
	local pFirstPlayer = nil;
	local bMainAttack = false;
	local nTotalLevel = 0;
	local nMapId, nPosX, nPosY = pNpc.GetWorldPos();
	if tbDamage.nTeamId > 0 then
		local tbTeam  = TeamMgr:GetTeamById(tbDamage.nTeamId);
		if not tbTeam then
			return tbPlayer, pFirstPlayer, nTotalLevel, bMainAttack;
		end

		local nCaptainId = tbTeam:GetCaptainId();
	    local tbMember   = tbTeam:GetMembers();
		for _, nPlayerId in pairs(tbMember) do
			local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
			if pPlayer and Npc:CheckPlayerMapAssign(pPlayer, nMapId, nPosX, nPosY, nPosLen) then

				tbPlayer = tbPlayer or {};
				table.insert(tbPlayer, {pPlayer = pPlayer, tbAward = {}});

				if not pFirstPlayer or nPlayerId == nCaptainId then
	                pFirstPlayer = pPlayer;
	            end

	            if nPlayerId == nMainAttackID then
	            	bMainAttack = true;
	            end

	            nTotalLevel = nTotalLevel + pPlayer.nLevel;
			end
		end
	else
		local pPlayer = KPlayer.GetPlayerObjById(tbDamage.nAttackRoleId);
		if pPlayer and Npc:CheckPlayerMapAssign(pPlayer, nMapId, nPosX, nPosY, nPosLen) then
			tbPlayer = {{pPlayer = pPlayer, tbAward = {}}};
			pFirstPlayer = pPlayer;

            if pPlayer.dwID == nMainAttackID then
            	bMainAttack = true;
            end

			nTotalLevel = nTotalLevel + pPlayer.nLevel;
		end
	end

	return tbPlayer, pFirstPlayer, nTotalLevel, bMainAttack;
end

--只有会被攻击的Npc有ByAttackCallScript标记的才会回调到这
function Npc:OnByAttack(szClassName)
    local tbClass = self.tbClass[szClassName];
	if tbClass and tbClass.OnByAttack then
		tbClass:OnByAttack();
	end
end

Npc.tbActDoCallScript =
{
	[1] = function (pNpc, nParam1, nParam2, nParam3, nParam4)
	    Log("Test", pNpc.szName, nParam1, nParam2, nParam3, nParam4);
	end;
}

function Npc:ActDoCallScript(pNpc, nType, ...)
	local funCallBack = Npc.tbActDoCallScript[nType];
	if not funCallBack then
		return;
	end

	funCallBack(pNpc, ...);	
end

function Npc:ShowErrDlg(me, him, szMsg)
    Dialog:Show({
        Text = szMsg,
        OptList = {
            { Text = "知道了" }
        },
    }, me, him)
end

function Npc:IsTeammateNearby(pPlayer, pNpc, bMustBeCaptain)
    local tbTeam = TeamMgr:GetTeamById(pPlayer.dwTeamID)
    if not tbTeam then
        return false, "沒有隊伍", "no_team"
    end

    if bMustBeCaptain and not tbTeam:IsCaptain(pPlayer.dwID) then
    	return false, "只有隊長才有許可權", "not_captain"
    end

    local tbMemberMap = {}
    local tbMembers = tbTeam:GetMembers()
    for _, nPlayerId in pairs(tbMembers) do
    	tbMemberMap[nPlayerId] = true
    end

    local tbPlayer = KNpc.GetAroundPlayerList(pNpc.nId, 700) or {}
    for _,pPlayer in pairs(tbPlayer) do
    	local nPlayerId = pPlayer.dwID
        if tbMemberMap[nPlayerId] then
        	tbMemberMap[nPlayerId] = nil
        	if not next(tbMemberMap) then
        		return true
        	end
        end
    end
    local nPlayerId = next(tbMemberMap)
    if not nPlayerId then
    	return true
    end
    local pStay = KPlayer.GetRoleStayInfo(nPlayerId) or {szName=""}
    return false, string.format("隊員「%s」不在附近", pStay.szName)
end
