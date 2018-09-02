
-- 在异步数据中存储的位置，不能改
local XUEWEI_BEGINE_SAVE_ID = 154;

-- 当前最大支持穴位数量，如果要扩充需要考虑存储 SAVE_GROUP_LIST 和 SAVE_GROUP_FAIL_COUNT_LIST 都要扩充
local MAX_XUEWEI_ID = 500;

-- 最大穴位等级，没法扩充了
local MAX_XUEWEI_LEVEL = 127;

-- 穴位等级存储在 UserValue 的位置，顺序很重要不要动
local SAVE_GROUP_LIST = {140};

-- 每个穴位失败次数的数据，顺序也很重要，别动
local SAVE_GROUP_FAIL_COUNT_LIST = {141};

JingMai.SAVE_GROUP_ID = 142;
JingMai.SAVE_INDEX_ID = 1;
JingMai.SAVE_INDEX_OPEN_DATE = 2;
JingMai.SAVE_INDEX_DATE = 3;
JingMai.SAVE_XUEWEI_LEVELUP_COUNT = 4;
JingMai.SAVE_XUEWEI_EXT_COUNT = 5;

JingMai.MAX_RATE = 1000000;


----------------------------------------------------------  下面的策划配置
-- 经脉最低开启玩家等级
JingMai.nOpenLevel = 70;

-- 经脉最低开启时间轴
JingMai.szOpenTimeFrame = "OpenLevel79";

-- 使用一个资质丹给与真气数量
JingMai.nUseItemProtentialZhenQiValue = 125;

-- 开放经脉系统时，返还已经使用资质丹所得真气
-- 每使用一个资质丹给的数量
JingMai.nOpenJingMaiAwardRate = 100;

-- 重置穴位真气返还比率
JingMai.nResetZhenQiRate = 1;

-- 玩家开启经脉任务ID
JingMai.nOpenTaskId = 3206;

-- 每日穴位升级次数（成功才算次数）
JingMai.nMaxLevelupTimes = 999;

JingMai.tbUseProtntialItemRandom = {
	{200, 8},
	{400, 4},
	{1000, 1.6},
	{4600, 0.8},
	{3800, 0.4},
};


for i, tbInfo in ipairs(JingMai.tbUseProtntialItemRandom) do
	tbInfo[1] = tbInfo[1] + (JingMai.tbUseProtntialItemRandom[i - 1] or {0})[1];
end

function JingMai:LoadSetting()
	self.tbXueWeiLevelupInfo = {};
	local tbFile = LoadTabFile("Setting/JingMai/XueWeiLevelup.tab", "dddsss", nil, {"TypeId", "Level", "Rate", "Cost1", "Cost2", "Cost3"});
	for _, tbRow in pairs(tbFile) do
		self.tbXueWeiLevelupInfo = self.tbXueWeiLevelupInfo or {};
		self.tbXueWeiLevelupInfo[tbRow.TypeId] = self.tbXueWeiLevelupInfo[tbRow.TypeId] or {};
		self.tbXueWeiLevelupInfo[tbRow.TypeId].nMaxLevel = math.max(self.tbXueWeiLevelupInfo[tbRow.TypeId].nMaxLevel or 0, tbRow.Level);

		assert(not self.tbXueWeiLevelupInfo[tbRow.TypeId][tbRow.Level]);
		assert(self.tbXueWeiLevelupInfo[tbRow.TypeId].nMaxLevel < MAX_XUEWEI_LEVEL);

		self.tbXueWeiLevelupInfo[tbRow.TypeId][tbRow.Level] = {
			nRate = tbRow.Rate;
			tbCost = {};
		}

		for i = 1, 3 do
			local tbCost = Lib:SplitStr(tbRow["Cost" .. i], "|");
			if tbCost and #tbCost > 1 then
				local nCostType = Player.AwardType[tbCost[1]];
				assert(nCostType and (nCostType == Player.award_type_item or nCostType == Player.award_type_money));

				for j = 2, #tbCost do
					tbCost[j] = tonumber(tbCost[j]);
					assert(tbCost[j] and tbCost[j] > 0);
				end

				table.insert(self.tbXueWeiLevelupInfo[tbRow.TypeId][tbRow.Level].tbCost, tbCost);
			end
		end
	end

	self.tbJingMaiSetting = {};
	tbFile = LoadTabFile("Setting/JingMai/JingMaiSetting.tab", "dssd", nil, {"Id", "Name", "OpenTimeFrame", "MinOpenDay"});
	for _, tbRow in ipairs(tbFile) do
		assert(not self.tbJingMaiSetting[tbRow.Id]);

		self.tbJingMaiSetting[tbRow.Id] = {
			szName = tbRow.Name;
			szOpenTimeFrame = tbRow.OpenTimeFrame;
			nMinOpenDay = tbRow.MinOpenDay;
			tbXueWei = {};
		}
	end

	self.tbXueWeiBeenRequired = {};
	self.tbAllAttrib = {};
	self.tbAllPartnerAttrib = {};
	self.tbAllSkill = {};
	self.tbXueWeiSetting = {};
	local tbTitle = {"Id", "Name", "TypeId", "JingMaiId", "LevelupType", "ExtSkillId", "ExtPartnerSkillId", "ExtAttribId", "ExtAttribMaxLevel", "ExtPartnerAttribId",
					"ExtPartnerAttribMaxLevel", "Require_XueWei1", "Require_XueWei2", "Require_XueWei3", "Require_Level", "Cost1", "Cost2", "Cost3"};
	local szType = "dsdddddddddsssssss";
	tbFile = LoadTabFile("Setting/JingMai/XueWeiSetting.tab", szType, nil, tbTitle);
	for _, tbRow in ipairs(tbFile) do
		assert(self.tbXueWeiLevelupInfo[tbRow.LevelupType]);
		assert(not self.tbXueWeiSetting[tbRow.Id]);
		assert(self.tbJingMaiSetting[tbRow.JingMaiId]);
		assert(tbRow.Id <= MAX_XUEWEI_ID);

		table.insert(self.tbJingMaiSetting[tbRow.JingMaiId].tbXueWei, tbRow.Id);

		local tbXueWeiInfo = {
			nId = tbRow.Id;
			szName = tbRow.Name;
			nType = tbRow.TypeId;
			nJingMaiId = tbRow.JingMaiId;
			nLevelupType = tbRow.LevelupType;
			nMaxLevel = self.tbXueWeiLevelupInfo[tbRow.LevelupType].nMaxLevel + 1;
			nExtAttribId = tbRow.ExtAttribId;
			nExtSkillId = tbRow.ExtSkillId;
			nExtPartnerSkillId = tbRow.ExtPartnerSkillId;
			nExtAttribMaxLevel = tbRow.ExtAttribMaxLevel;
			nExtPartnerAttribId = tbRow.ExtPartnerAttribId;
			nExtPartnerAttribMaxLevel = tbRow.ExtPartnerAttribMaxLevel;
			tbRequireLevel = {};
			tbRequireXueWei = {};
			tbCost = {};
			tbCostZhenQi = {};
			tbFightPower = {};
		};

		if tbRow.ExtAttribId and tbRow.ExtAttribId > 0 then
			assert(not self.tbAllAttrib[tbRow.ExtAttribId], string.format("[JingMai] Attribute Id Repeat !! nXueWeiId = %s, ExtAttribId = %s", tbRow.Id, tbRow.ExtAttribId));
			self.tbAllAttrib[tbRow.ExtAttribId] = true;
		end

		if tbRow.ExtPartnerAttribId and tbRow.ExtPartnerAttribId > 0 then
			assert(not self.tbAllPartnerAttrib[tbRow.ExtPartnerAttribId], string.format("[JingMai] Attribute Id Repeat !! nXueWeiId = %s, ExtPartnerAttribId = %s", tbRow.Id, tbRow.ExtPartnerAttribId));
			self.tbAllPartnerAttrib[tbRow.ExtPartnerAttribId] = true;
		end

		if tbRow.ExtSkillId and tbRow.ExtSkillId > 0 then
			self.tbAllSkill[tbRow.ExtSkillId] = true;
		end

		for i = 1, 3 do
			local tbCost = Lib:SplitStr(tbRow["Cost" .. i], "|");
			if tbCost and #tbCost > 1 then
				local nCostType = Player.AwardType[tbCost[1]];
				assert(nCostType and (nCostType == Player.award_type_item or nCostType == Player.award_type_money));

				for j = 2, #tbCost do
					tbCost[j] = tonumber(tbCost[j]);
					assert(tbCost[j] and tbCost[j] > 0);
				end

				if tbCost[1] == "ZhenQi" then
					tbXueWeiInfo.tbCostZhenQi[1] = tbXueWeiInfo.tbCostZhenQi[1] or 0;
					tbXueWeiInfo.tbCostZhenQi[1] = tbXueWeiInfo.tbCostZhenQi[1] + tbCost[2];
				end

				table.insert(tbXueWeiInfo.tbCost, tbCost);
			end
		end

		tbXueWeiInfo.tbFightPower[1] = math.floor(0.5 * tbXueWeiInfo.tbCostZhenQi[1] / 10);

		for i = 1, self.tbXueWeiLevelupInfo[tbRow.LevelupType].nMaxLevel do
			local tbCost = self.tbXueWeiLevelupInfo[tbRow.LevelupType][i].tbCost;
			local nZhenQiCost = 0;
			for _, tbInfo in pairs(tbCost) do
				if tbInfo[1] == "ZhenQi" then
					nZhenQiCost = nZhenQiCost + tbInfo[2];
				end
			end

			tbXueWeiInfo.tbCostZhenQi[i + 1] = nZhenQiCost + tbXueWeiInfo.tbCostZhenQi[i];

			local nRate = self.tbXueWeiLevelupInfo[tbRow.LevelupType][i].nRate / self.MAX_RATE;
			local nFightPower = math.floor((0.5 * nZhenQiCost / 10) / nRate);

			tbXueWeiInfo.tbFightPower[i + 1] = nFightPower + tbXueWeiInfo.tbFightPower[i];
		end

		for i = 1, 3 do
			local nXueWeiId, nLevel = string.match(tbRow["Require_XueWei" .. i] or "", "^(%d+)|(%d+)$");
			if nXueWeiId then
				nXueWeiId = tonumber(nXueWeiId);
				nLevel = tonumber(nLevel);
				table.insert(tbXueWeiInfo.tbRequireXueWei, {nXueWeiId, nLevel});
				self.tbXueWeiBeenRequired[nXueWeiId] = self.tbXueWeiBeenRequired[nXueWeiId] or {};
				table.insert(self.tbXueWeiBeenRequired[nXueWeiId], tbRow.Id)
			end
		end

		local tbRL = Lib:SplitStr(tbRow.Require_Level, ";");
		local tbPoint = {};
		for _, szInfo in ipairs(tbRL) do
			local nX, nY = string.match(szInfo, "^(%d+)|(%d+)$");
			if nX then
				table.insert(tbPoint, {tonumber(nX), tonumber(nY)});
			end
		end

		if #tbPoint <= 0 then
			tbPoint = {{0, 0}, {10, 0}};
		end

		for i = 1, tbXueWeiInfo.nMaxLevel do
			tbXueWeiInfo.tbRequireLevel[i] = Lib.Calc:Link(i, tbPoint);
		end

		self.tbXueWeiSetting[tbRow.Id] = tbXueWeiInfo;
	end
end

JingMai:LoadSetting();

function JingMai:OnServerStart()
	local tbJingMaiScriptData = ScriptData:GetValue("JingMai");
	if not tbJingMaiScriptData.bInit then
		local nFirstJingMai = self:GetNextOpenJingMai();
		local nSecondJingMai = self:GetNextOpenJingMai(nFirstJingMai);
		if self:CheckJingMaiOpen(nFirstJingMai) and self:CheckJingMaiOpen(nSecondJingMai) then
			tbJingMaiScriptData.tbOpenInfo = {};
			tbJingMaiScriptData.tbOpenInfo.nNextOpenJingMaiId = nSecondJingMai;
			tbJingMaiScriptData.tbOpenInfo.nOpenTime = GetTime() + self.tbJingMaiSetting[nSecondJingMai].nMinOpenDay * 24 * 3600;
		end

		tbJingMaiScriptData.bInit = true;
		ScriptData:SaveAtOnce("JingMai", tbJingMaiScriptData);
	end
	self.tbOpenInfo = tbJingMaiScriptData.tbOpenInfo;
end

function JingMai:OnLogin(pPlayer)
	pPlayer.CallClientScript("JingMai:OnSyncOpenInfo", self.tbOpenInfo);
	self:UpdatePlayerAttrib(pPlayer);
end

function JingMai:UpdatePlayerAttrib(pPlayer)
	if MODULE_GAMECLIENT then
		pPlayer = me;
	end

	for nAttribGroup in pairs(self.tbAllAttrib) do
		pPlayer.RemoveExternAttrib(nAttribGroup);
	end

	if MODULE_GAMESERVER then
		for nSkillId in pairs(self.tbAllSkill) do
			pPlayer.RemoveSkillState(nSkillId);
		end
	end

	local tbXueWeiLearnedInfo = self:GetLearnedXueWeiInfo(pPlayer);
	for nXueWeiId, nLevel in pairs(tbXueWeiLearnedInfo or {}) do
		local tbXueWei = self.tbXueWeiSetting[nXueWeiId];
		if tbXueWei.nExtSkillId > 0 or tbXueWei.nExtAttribId > 0 then
			if tbXueWei.nExtSkillId > 0 and MODULE_GAMESERVER then
				pPlayer.AddSkillState(tbXueWei.nExtSkillId, nLevel, 3, 10000000, 1);
			end

			if tbXueWei.nExtAttribId > 0 then
				local nAttribLevel = math.max(math.floor(nLevel * tbXueWei.nExtAttribMaxLevel / tbXueWei.nMaxLevel), 1);
				pPlayer.ApplyExternAttrib(tbXueWei.nExtAttribId, nAttribLevel);
			end
		end
	end

	if MODULE_GAMESERVER then
		pPlayer.CallClientScript("JingMai:UpdatePlayerAttrib");
	end
end

function JingMai:GetFightPower(pPlayer)
	local bHasPartnerInPos = false;
	local tbPosInfo = pPlayer.GetPartnerPosInfo();
	for i = 1, Partner.MAX_PARTNER_POS_COUNT do
		if tbPosInfo[i] > 0 then
			bHasPartnerInPos = true;
			break;
		end
	end
	if not bHasPartnerInPos then
		return 0;
	end

	local tbLearnInfo = self:GetLearnedXueWeiInfo(pPlayer);
	local nFightPower = 0;
	for nXueWeiId, nLevel in pairs(tbLearnInfo) do
		nFightPower = nFightPower + self.tbXueWeiSetting[nXueWeiId].tbFightPower[nLevel];
	end

	return nFightPower;
end

function JingMai:GetLearnedXueWeiInfo(pPlayer, pPlayerAsync)
	local bHasPartnerInPos = false;
	if pPlayerAsync then
		for i = 1, Partner.MAX_PARTNER_POS_COUNT do
			local nPartnerTemplateId = pPlayerAsync.GetPartnerInfo(i);
			if nPartnerTemplateId then
				bHasPartnerInPos = true;
				break;
			end
		end
	end

	if pPlayer then
		local tbPosInfo = pPlayer.GetPartnerPosInfo();
		for i = 1, Partner.MAX_PARTNER_POS_COUNT do
			if tbPosInfo[i] > 0 then
				bHasPartnerInPos = true;
				break;
			end
		end
	end

	-- 跨服状态忽略同伴检查
	if MODULE_ZONESERVER then
		bHasPartnerInPos = true;
	end

	if not bHasPartnerInPos then
		return {}, true;
	end

	local tbXueWeiLearnedInfo = {};
	for _, tbJingMai in pairs(self.tbJingMaiSetting) do
		if MODULE_ZONESERVER or TimeFrame:GetTimeFrameState(tbJingMai.szOpenTimeFrame) == 1 then
			for _, nXueWeiId in pairs(tbJingMai.tbXueWei) do
				local nLevel = 0;
				if pPlayer then
					nLevel = self:GetXueWeiLevel(pPlayer, nXueWeiId)
				else
					nLevel = self:GetXueWeiLevelByAsyncData(pPlayerAsync, nXueWeiId);
				end

				if nLevel > 0 then
					tbXueWeiLearnedInfo[nXueWeiId] = nLevel;
				end
			end
		end
	end

	return tbXueWeiLearnedInfo;
end

function JingMai:GetNextOpenJingMai(nJingMaiId)
	nJingMaiId = nJingMaiId or 0;

	if self.tbNextOpenJingMaiInfo then
		return self.tbNextOpenJingMaiInfo[nJingMaiId];
	end

	self.tbNextOpenJingMaiInfo = {};

	local tbAllJingMaiOpenTime = {};
	for nJingMaiId, tbJingMai in pairs(self.tbJingMaiSetting) do
		table.insert(tbAllJingMaiOpenTime, {nJingMaiId, TimeFrame:CalcTimeFrameOpenTime(tbJingMai.szOpenTimeFrame)});
	end

	table.sort(tbAllJingMaiOpenTime, function (a, b) return a[2] < b[2]; end)

	self.tbNextOpenJingMaiInfo[0] = tbAllJingMaiOpenTime[1][1];
	for i, tbInfo in ipairs(tbAllJingMaiOpenTime) do
		self.tbNextOpenJingMaiInfo[tbInfo[1]] = (tbAllJingMaiOpenTime[i + 1] or {})[1];
	end

	return self.tbNextOpenJingMaiInfo[nJingMaiId];
end

function JingMai:GetXueWeiAddInfo(tbXueWeiLearnedInfo, nJingMaiId)
	local tbXueWeiInfo = {};
	for nXueWeiId, nLevel in pairs(tbXueWeiLearnedInfo or {}) do
		table.insert(tbXueWeiInfo, {nXueWeiId, nLevel});
	end

	table.sort(tbXueWeiInfo, function (a, b)
		return a[1] < b[1];
	end);

	local tbAddInfo = {tbSkill = {}; tbPartnerSkill = {}; tbExtAttrib = {}; tbExtPartnerAttrib = {};};
	for _, tbInfo in ipairs(tbXueWeiInfo) do
		local nXueWeiId, nLevel = unpack(tbInfo);
		local tbXueWei = self.tbXueWeiSetting[nXueWeiId];
		if not nJingMaiId or nJingMaiId == tbXueWei.nJingMaiId then
			if tbXueWei.nExtSkillId > 0 then
				table.insert(tbAddInfo.tbSkill, {tbXueWei.nExtSkillId, nLevel, tbXueWei.nMaxLevel});
			end

			if tbXueWei.nExtPartnerSkillId > 0 then
				table.insert(tbAddInfo.tbPartnerSkill, {tbXueWei.nExtPartnerSkillId, nLevel, tbXueWei.nMaxLevel});
			end

			if tbXueWei.nExtAttribId > 0 then
				local nAttribLevel = math.max(math.floor(nLevel * tbXueWei.nExtAttribMaxLevel / tbXueWei.nMaxLevel), 1);
				table.insert(tbAddInfo.tbExtAttrib, {tbXueWei.nExtAttribId, nAttribLevel});
			end

			if tbXueWei.nExtPartnerAttribId > 0 then
				local nAttribLevel = math.max(math.floor(nLevel * tbXueWei.nExtPartnerAttribMaxLevel / tbXueWei.nMaxLevel), 1);
				table.insert(tbAddInfo.tbExtPartnerAttrib, {tbXueWei.nExtPartnerAttribId, nAttribLevel});
			end
		end
	end

	return tbAddInfo;
end

function JingMai:GetAttribInfo(tbAttribInfo)
	local tbAllAttrib = {};
	for _, tbInfo in ipairs(tbAttribInfo) do
		local nAttributeID, nLevel = unpack(tbInfo);
		local tbAttrib = KItem.GetExternAttrib(nAttributeID, nLevel);
		for _, tbMagic in pairs(tbAttrib or {}) do
			tbAllAttrib[tbMagic.szAttribName] = tbAllAttrib[tbMagic.szAttribName] or {tbValue = {0, 0, 0}};

			local tbOldInfo = tbAllAttrib[tbMagic.szAttribName];
			for i = 1, 3 do
				tbOldInfo.tbValue[i] = tbOldInfo.tbValue[i] + tbMagic.tbValue[i];
			end
		end
	end
	return tbAllAttrib;
end

function JingMai:MgrPartnerAttrib(tbPartnerAttribInfo, tbAttrib)
	local tbResult = Lib:CopyTB(tbPartnerAttribInfo);
	for szType, tbInfo in pairs(tbAttrib) do
		tbResult.tbBaseAttrib[szType] = tbResult.tbBaseAttrib[szType] or {tbValue = {0, 0, 0}};
		for i = 1, 3 do
			tbResult.tbBaseAttrib[szType].tbValue[i] = tbResult.tbBaseAttrib[szType].tbValue[i] + tbInfo.tbValue[i];
		end
	end

	return tbResult;
end


function JingMai:GetAttribDesc(tbAttrib)
	tbAttrib = Lib:CopyTB(tbAttrib);
	tbAttrib = {tbBaseAttrib = tbAttrib};

	local szDesc = nil;
	local nCount = 0;

	local function fnGetDesc(tbDef)
		for nIdx, tbInfo in ipairs(tbDef) do
			local szType = tbInfo[1];
			local value = 0;
			local szShowValue = nil;

			if type(tbInfo[2]) == "string" then
				value = Partner:GetJingMaiValueBase(tbAttrib, unpack(tbInfo, 2)) or 0;
			elseif type(tbInfo[2]) == "function" then
				value, szShowValue = tbInfo[2](Partner, tbAttrib, unpack(tbInfo, 3));
				value = value or 0;
			end

			local nValue = tonumber(value);
			if nValue and math.abs(nValue) > 0.0001 then
				if not szDesc then
					szDesc = string.format("%s   +%s", szType, szShowValue or value);
				else
					szDesc = string.format("%s\n%s   +%s", szDesc, szType, szShowValue or value);
				end
				nCount = nCount + 1;
			end
		end
	end

	fnGetDesc(Partner.tbAllAttribDef);
	fnGetDesc(Partner.tbJingMaiExtAttribDef);

	return szDesc or "", nCount;
end

function JingMai:UpdateAsyncPlayerAttrib(pPlayerAsync, pNpc)
	local tbXueWeiLearnedInfo = self:GetLearnedXueWeiInfo(nil, pPlayerAsync);
	for nXueWeiId, nLevel in pairs(tbXueWeiLearnedInfo or {}) do
		local tbXueWei = self.tbXueWeiSetting[nXueWeiId];
		if tbXueWei.nExtSkillId > 0 or tbXueWei.nExtPartnerAttribId > 0 then
			if tbXueWei.nExtSkillId > 0 then
				pNpc.AddSkillState(tbXueWei.nExtSkillId, nLevel, 3, 10000000);
			end

			if tbXueWei.nExtAttribId > 0 then
				local nAttribLevel = math.max(math.floor(nLevel * tbXueWei.nExtAttribMaxLevel / tbXueWei.nMaxLevel), 1);
				pNpc.ApplyExternAttrib(tbXueWei.nExtAttribId, nAttribLevel);
			end
		end
	end

	pNpc.RestoreHP();
end

function JingMai:OnCreatePartnerNpc(nNpcId, bHasWaite)
	if not bHasWaite then
		-- 此时 MasterNpcId还没有设置，所以要延迟下才进行更新数据
		Timer:Register(2, function ()
			self:OnCreatePartnerNpc(nNpcId, true);
		end);
		return;
	end

	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc or pNpc.nMasterNpcId <= 0 then
		return;
	end

	local pMasterNpc = KNpc.GetById(pNpc.nMasterNpcId);
	if not pMasterNpc then
		return;
	end

	local nPlayerId = pMasterNpc.nPlayerID;
	if nPlayerId <= 0 and pMasterNpc.GetPlayerIdSaveInNpc then
		nPlayerId = pMasterNpc.GetPlayerIdSaveInNpc();
	end

	if not pMasterNpc or nPlayerId <= 0 then
		return;
	end

	local tbXueWeiLearnedInfo = {};
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not MODULE_ZONESERVER and pPlayer then
		tbXueWeiLearnedInfo = self:GetLearnedXueWeiInfo(pPlayer);
	else
		local pAsyncData = KPlayer.GetAsyncData(nPlayerId);
		if not pAsyncData then
			return;
		end

		tbXueWeiLearnedInfo = self:GetLearnedXueWeiInfo(nil, pAsyncData);
	end

	for nXueWeiId, nLevel in pairs(tbXueWeiLearnedInfo or {}) do
		local tbXueWei = self.tbXueWeiSetting[nXueWeiId];
		if tbXueWei.nExtPartnerSkillId > 0 or tbXueWei.nExtPartnerAttribId > 0 then
			if tbXueWei.nExtPartnerSkillId > 0 then
				pNpc.AddSkillState(tbXueWei.nExtPartnerSkillId, nLevel, 3, 10000000);
			end

			if tbXueWei.nExtPartnerAttribId > 0 then
				local nAttribLevel = math.max(math.floor(nLevel * tbXueWei.nExtPartnerAttribMaxLevel / tbXueWei.nMaxLevel), 1);
				pNpc.ApplyExternAttrib(tbXueWei.nExtPartnerAttribId, nAttribLevel);
			end
		end
	end

	pNpc.RestoreHP();
end

function JingMai:OnSyncOpenInfo(tbOpenInfo)
	self.tbOpenInfo = tbOpenInfo;
end

function JingMai:GetXueWeiUserValueSaveIdx(nXueWeiId, tbSaveGroup)
	if nXueWeiId <= 0 or nXueWeiId > MAX_XUEWEI_ID then
		return;
	end

	tbSaveGroup = tbSaveGroup or SAVE_GROUP_LIST;

	local nTotalIdx = math.ceil(nXueWeiId / 4);
	local nBitIdx = nXueWeiId % 4;
	nBitIdx = nBitIdx == 0 and 4 or nBitIdx;

	local nSaveGroup = math.ceil(nTotalIdx / 255);
	if nSaveGroup > #tbSaveGroup then
		return;
	end
	nSaveGroup = tbSaveGroup[nSaveGroup];

	local nSaveIdx = nTotalIdx % 255;
	nSaveIdx = nSaveIdx == 0 and 255 or nSaveIdx;

	return nSaveGroup, nSaveIdx, nBitIdx * 8 - 8, nBitIdx * 8 - 1;
end

function JingMai:GetXueWeiLevel(pPlayer, nXueWeiId)
	local nSaveGroup, nSaveIdx, nBitBegin, nBitEnd = self:GetXueWeiUserValueSaveIdx(nXueWeiId);
	if not nSaveGroup then
		Log("[JingMai] GetXueWeiLevel ERR ?? ", pPlayer.dwID, pPlayer.szAccount, pPlayer.szName, nXueWeiId, debug.traceback());
		return;
	end

	local nValue = pPlayer.GetUserValue(nSaveGroup, nSaveIdx);
	return Lib:LoadBits(nValue, nBitBegin, nBitEnd);
end

function JingMai:GetXueWeiFailTimes(pPlayer, nXueWeiId)
	local nSaveGroup, nSaveIdx, nBitBegin, nBitEnd = self:GetXueWeiUserValueSaveIdx(nXueWeiId, SAVE_GROUP_FAIL_COUNT_LIST);
	if not nSaveGroup then
		Log("[JingMai] GetXueWeiFailTimes ERR ?? ", pPlayer.dwID, pPlayer.szAccount, pPlayer.szName, nXueWeiId, debug.traceback());
		return 0;
	end

	local nValue = pPlayer.GetUserValue(nSaveGroup, nSaveIdx);
	return Lib:LoadBits(nValue, nBitBegin, nBitEnd);
end

function JingMai:AddXueWeiFailTimes(pPlayer, nXueWeiId)
	local nSaveGroup, nSaveIdx, nBitBegin, nBitEnd = self:GetXueWeiUserValueSaveIdx(nXueWeiId, SAVE_GROUP_FAIL_COUNT_LIST);
	if not nSaveGroup then
		Log("[JingMai] AddXueWeiFailTimes ERR ?? ", pPlayer.dwID, pPlayer.szAccount, pPlayer.szName, nXueWeiId, debug.traceback());
		return;
	end

	local nValue = pPlayer.GetUserValue(nSaveGroup, nSaveIdx);
	local nFailTimes = Lib:LoadBits(nValue, nBitBegin, nBitEnd);

	nValue = Lib:SetBits(nValue, nFailTimes + 1, nBitBegin, nBitEnd);
	pPlayer.SetUserValue(nSaveGroup, nSaveIdx, nValue);
end

function JingMai:ClearXueWeiFailTimes(pPlayer, nXueWeiId)
	local nSaveGroup, nSaveIdx, nBitBegin, nBitEnd = self:GetXueWeiUserValueSaveIdx(nXueWeiId, SAVE_GROUP_FAIL_COUNT_LIST);
	if not nSaveGroup then
		Log("[JingMai] AddXueWeiFailTimes ERR ?? ", pPlayer.dwID, pPlayer.szAccount, pPlayer.szName, nXueWeiId, debug.traceback());
		return;
	end

	local nValue = pPlayer.GetUserValue(nSaveGroup, nSaveIdx);
	nValue = Lib:SetBits(nValue, 0, nBitBegin, nBitEnd);
	pPlayer.SetUserValue(nSaveGroup, nSaveIdx, nValue);
end

function JingMai:GetRealRate(pPlayer, nXueWeiId, nRate)
	if nRate > 300000 then
		return nRate, false;
	end

	local nFailTimes = self:GetXueWeiFailTimes(pPlayer, nXueWeiId) + 1;
	local nBaseTimes = math.ceil(self.MAX_RATE / nRate);

	local nTimesRate = 1;
	if nFailTimes > nBaseTimes then
		nTimesRate = nFailTimes - nBaseTimes + 1;
	elseif nFailTimes < nBaseTimes then
		nTimesRate = (nBaseTimes - nFailTimes) * 0.5 + 0.5
	end

	local nRealRate = math.floor(nFailTimes > nBaseTimes and nRate * nTimesRate or nRate / nTimesRate);
	return math.min(math.max(nRealRate, 0), self.MAX_RATE);
end

function JingMai:SetXueWeiLevel(pPlayer, nXueWeiId, nLevel)
	local nSaveGroup, nSaveIdx, nBitBegin, nBitEnd = self:GetXueWeiUserValueSaveIdx(nXueWeiId);
	if not nSaveGroup or nLevel > MAX_XUEWEI_LEVEL or nLevel < 0 then
		Log("[JingMai] SetXueWeiLevel ERR ?? ", pPlayer.dwID, pPlayer.szAccount, pPlayer.szName, nXueWeiId, debug.traceback());
		return;
	end

	local nValue = pPlayer.GetUserValue(nSaveGroup, nSaveIdx);


	nValue = Lib:SetBits(nValue, nLevel, nBitBegin, nBitEnd);
	pPlayer.SetUserValue(nSaveGroup, nSaveIdx, nValue);

	local pAsyncData = KPlayer.GetAsyncData(pPlayer.dwID);
	if pAsyncData then
		self:__SetXueWeiLevelByAsyncData(pAsyncData, nXueWeiId, nLevel);
	end
end

function JingMai:GetXueWeiLevelByAsyncData(pAsyncData, nXueWeiId)
	return pAsyncData.GetAsyncBattleValue(nXueWeiId + XUEWEI_BEGINE_SAVE_ID);
end

function JingMai:__SetXueWeiLevelByAsyncData(pAsyncData, nXueWeiId, nLevel)
	if not nXueWeiId or not nLevel or nLevel < 0 then
		Log("[JingMai] SetXueWeiLevelByAsyncData ERR ?? ", nXueWeiId or "nil", nLevel or "nil", debug.traceback());
		return;
	end

	local tbXueWei = self.tbXueWeiSetting[nXueWeiId];
	if not tbXueWei or nLevel > tbXueWei.nMaxLevel then
		Log("[JingMai] SetXueWeiLevelByAsyncData ERR ?? ", nXueWeiId, nLevel, debug.traceback());
		return;
	end

	pAsyncData.SetAsyncBattleValue(nXueWeiId + XUEWEI_BEGINE_SAVE_ID, nLevel);
end

function JingMai:CostLevelupTimes(pPlayer)
	local nLocalDay = Lib:GetLocalDay(GetTime() - 4 * 3600);
	if pPlayer.GetUserValue(self.SAVE_GROUP_ID, self.SAVE_INDEX_DATE) ~= nLocalDay then
		pPlayer.SetUserValue(self.SAVE_GROUP_ID, self.SAVE_INDEX_DATE, nLocalDay);
		pPlayer.SetUserValue(self.SAVE_GROUP_ID, self.SAVE_XUEWEI_LEVELUP_COUNT, 0);
	end

	local nTimes = pPlayer.GetUserValue(self.SAVE_GROUP_ID, self.SAVE_XUEWEI_LEVELUP_COUNT);
	if nTimes < self.nMaxLevelupTimes then
		pPlayer.SetUserValue(self.SAVE_GROUP_ID, self.SAVE_XUEWEI_LEVELUP_COUNT, nTimes + 1);
		return true;
	end

	local nExtCount = pPlayer.GetUserValue(self.SAVE_GROUP_ID, self.SAVE_XUEWEI_EXT_COUNT);
	if nExtCount > 0 then
		pPlayer.SetUserValue(self.SAVE_GROUP_ID, self.SAVE_XUEWEI_EXT_COUNT, nExtCount - 1);
		return true;
	end

	return false;
end

function JingMai:AddLevelupExtTimes(pPlayer, nTimes)
	if nTimes <= 0 then
		Log("[JingMai] AddLevelupExtTimes ERR ?? nTimes <= 0", pPlayer.dwID, pPlayer.szAccount, pPlayer.szName, nTimes, debug.traceback())
		return;
	end

	local nExtCount = pPlayer.GetUserValue(self.SAVE_GROUP_ID, self.SAVE_XUEWEI_EXT_COUNT);
	pPlayer.SetUserValue(self.SAVE_GROUP_ID, self.SAVE_XUEWEI_EXT_COUNT, nExtCount + nTimes);
end

function JingMai:GetLevelupLastTimes(pPlayer)
	local nExtCount = pPlayer.GetUserValue(self.SAVE_GROUP_ID, self.SAVE_XUEWEI_EXT_COUNT);
	local nLocalDay = Lib:GetLocalDay(GetTime() - 4 * 3600);
	if pPlayer.GetUserValue(self.SAVE_GROUP_ID, self.SAVE_INDEX_DATE) ~= nLocalDay then
		return nExtCount + self.nMaxLevelupTimes;
	end

	return nExtCount + self.nMaxLevelupTimes - pPlayer.GetUserValue(self.SAVE_GROUP_ID, self.SAVE_XUEWEI_LEVELUP_COUNT);
end

function JingMai:CheckJingMaiOpen(nJingMaiId)
	local tbJingMai = self.tbJingMaiSetting[nJingMaiId];
	if not tbJingMai then
		return false, "不存在的經脈";
	end

	local nTimeNow = GetTime();
	if self.tbOpenInfo then
		if nJingMaiId >= self.tbOpenInfo.nNextOpenJingMaiId and nTimeNow < self.tbOpenInfo.nOpenTime then
			return false, string.format("將在%s後開放此經脈", Lib:TimeDesc2(self.tbOpenInfo.nOpenTime - nTimeNow));
		end
	end

	local nOpenTime = TimeFrame:CalcTimeFrameOpenTime(tbJingMai.szOpenTimeFrame);
	if nTimeNow < nOpenTime then
		return false, string.format("將於%s後開放此經脈", Lib:TimeDesc2(nOpenTime - nTimeNow));
	end

	return true, "", tbJingMai;
end

function JingMai:CheckOpen(pPlayer)
	if TimeFrame:GetTimeFrameState(self.szOpenTimeFrame) ~= 1 then
		return false, "功能未開放";
	end

	if pPlayer.nLevel < self.nOpenLevel then
		return false, string.format("需要等級到%s，才能進行此操作！", self.nOpenLevel);
	end

	if Task:GetTaskFlag(pPlayer, self.nOpenTaskId) ~= 1 then
		return false, "未完成前置任務";
	end

	return true;
end

function JingMai:CheckXueWeiLevelup(pPlayer, nXueWeiId)
	local bRet, szMsg = self:CheckOpen(pPlayer);
	if not bRet then
		return false, szMsg;
	end

	local tbXueWei = self.tbXueWeiSetting[nXueWeiId];
	if not tbXueWei then
		return false, "不存在的穴位";
	end

	local tbJingMai = nil;
	bRet, szMsg, tbJingMai = self:CheckJingMaiOpen(tbXueWei.nJingMaiId);
	if not bRet then
		return false, szMsg;
	end

	if self:GetLevelupLastTimes(pPlayer) <= 0 then
		return false, string.format("閣下今日已成功沖穴[FFFE0D]%s[-]次，氣海虛浮無法繼續！", self.nMaxLevelupTimes);
	end

	for _, tbInfo in pairs(tbXueWei.tbRequireXueWei) do
		local nRequire_XueWei, nRequire_Level = unpack(tbInfo);
		local nRLevel = self:GetXueWeiLevel(pPlayer, nRequire_XueWei);
		if nRLevel < nRequire_Level then
			return false, string.format("前置穴位重數不足 %s", nRequire_Level);
		end
	end


	local nLevel = self:GetXueWeiLevel(pPlayer, nXueWeiId);
	if not nLevel then
		return false, "數據異常";
	end

	if nLevel >= tbXueWei.nMaxLevel or not tbXueWei.tbRequireLevel[nLevel + 1] then
		return false, "已達等級上限";
	end

	if pPlayer.nLevel < tbXueWei.tbRequireLevel[nLevel + 1] then
		return false, string.format("需要等級達到%s級！", tbXueWei.tbRequireLevel[nLevel + 1]);
	end

	local nRate = self.MAX_RATE;
	local tbCost = tbXueWei.tbCost;
	if nLevel > 0 then
		tbCost = self.tbXueWeiLevelupInfo[tbXueWei.nLevelupType][nLevel].tbCost;
		nRate = self.tbXueWeiLevelupInfo[tbXueWei.nLevelupType][nLevel].nRate;
	end

	for _, tbInfo in pairs(tbCost) do
		local nType = Player.AwardType[tbInfo[1]];
		if not nType or (nType ~= Player.award_type_item and nType ~= Player.award_type_money) then
			return false, "異常配置";
		end

		if nType == Player.award_type_money then
			if pPlayer.GetMoney(tbInfo[1]) < tbInfo[2] then
				return false, string.format("%s不足%s", Shop:GetMoneyName(tbInfo[1]), tbInfo[2]);
			end
		end

		if nType == Player.award_type_item then
			local nCount = pPlayer.GetItemCountInBags(tbInfo[2]);
			if nCount < tbInfo[3] then
				local szItemName = KItem.GetItemShowInfo(tbInfo[2], pPlayer.nFaction)
				return false, string.format("%s不足%s", szItemName, tbInfo[3]);
			end
		end
	end

	return true, "", tbXueWei, nLevel, tbCost, nRate;
end

function JingMai:XueWeiLevelup(pPlayer, nXueWeiId, nXueWeiLevel)
	local bRet, szMsg, tbXueWei, nLevel, tbCost, nRate = self:CheckXueWeiLevelup(pPlayer, nXueWeiId);
	if not bRet then
		pPlayer.CenterMsg(szMsg);
		return;
	end

	if nLevel ~= nXueWeiLevel then
		return;
	end

	for _, tbInfo in ipairs(tbCost) do
		local nType = Player.AwardType[tbInfo[1]];
		if nType == Player.award_type_item then
			local nCount = pPlayer.ConsumeItemInBag(tbInfo[2], tbInfo[3], Env.LogWay_XueWeiLevelup);
			if nCount < tbInfo[3] then
				pPlayer.CenterMsg("扣除道具失敗！");
				Log("[JingMai] XueWeiLevelup ConsumeItemInBag Fail !!!", pPlayer.dwID, pPlayer.szAccount, pPlayer.szName, nXueWeiId, nLevel, tbInfo[2], tbInfo[3], nCount);
				return;
			end
		elseif nType == Player.award_type_money then
			local bResult = pPlayer.CostMoney(tbInfo[1], tbInfo[2], Env.LogWay_XueWeiLevelup);
			if not bResult then
				Log("[JingMai] XueWeiLevelup CostMoney Fail !!!", pPlayer.dwID, pPlayer.szAccount, pPlayer.szName, nXueWeiId, nLevel, tbInfo[1], tbInfo[2]);
				return;
			end
		end
	end

	nRate = JingMai:GetRealRate(pPlayer, nXueWeiId, nRate);
	local nRandom = MathRandom(self.MAX_RATE);
	if nRandom > nRate then
		pPlayer.CenterMsg(string.format("很遺憾，穴位 [FFFE0D]%s[-] 沖穴失敗了！", JingMai.tbXueWeiSetting[nXueWeiId].szName));
		pPlayer.CallClientScript("JingMai:OnSyncXueWeiLevelChange", nXueWeiId, false);
		Log("[JingMai] XueWeiLevelup Fail !", pPlayer.dwID, pPlayer.szAccount, pPlayer.szName, nXueWeiId, nLevel);
		self:AddXueWeiFailTimes(pPlayer, nXueWeiId);
		return;
	end

	bRet = self:CostLevelupTimes(pPlayer);
	if not bRet then
		pPlayer.CenterMsg("丹田氣息紊亂，無法沖穴！");
		Log("[JingMai] ERR ?? XueWeiLevelup CostLevelupTimes Fail !!", pPlayer.dwID, pPlayer.szAccount, pPlayer.szName, nXueWeiId, nLevel);
		return;
	end

	self:ClearXueWeiFailTimes(pPlayer, nXueWeiId);

	self:SetXueWeiLevel(pPlayer, nXueWeiId, nLevel + 1);
	self:UpdatePlayerAttrib(pPlayer);
	FightPower:ChangeFightPower("JingMai", pPlayer);

	if nLevel == 0 then
		pPlayer.CenterMsg(string.format("打通穴位 %s 成功！", JingMai.tbXueWeiSetting[nXueWeiId].szName));
	else
		pPlayer.SendBlackBoardMsg(string.format("穴位 [FFFE0D]%s[-] 沖穴成功，境界提升為 [FFFE0D]%s[-] 重！", JingMai.tbXueWeiSetting[nXueWeiId].szName, nLevel + 1));
	end
	pPlayer.CallClientScript("JingMai:OnSyncXueWeiLevelChange", nXueWeiId, true);
	Log("[JingMai] XueWeiLevelup Success !", pPlayer.dwID, pPlayer.szAccount, pPlayer.szName, nXueWeiId, nLevel + 1);
end

function JingMai:OnSyncXueWeiLevelChange(nXueWeiId, bOK)
	UiNotify.OnNotify(UiNotify.emNOTIFY_SYNC_XUEWEI_LEVELUP, nXueWeiId, bOK);
end

function JingMai:OnGetProtentialItemByPartner(pPlayer, nUseItemProtentialValue)
	if not self:CheckOpen(pPlayer) then
		return;
	end

	local nItemCount = math.ceil(nUseItemProtentialValue / Partner:GetItemValue(Partner.nPartnerProtentialItem));
	if nItemCount <= 0 then
		return;
	end

	local nSaveInfo = pPlayer.GetUserValue(self.SAVE_GROUP_ID, self.SAVE_INDEX_ID);
	if nSaveInfo == 0 then
		pPlayer.SendBlackBoardMsg("當前丹田狀態變為[FFFE0D]疲勞[-]狀態！", true);
	end
	pPlayer.SetUserValue(self.SAVE_GROUP_ID, self.SAVE_INDEX_ID, nSaveInfo + nItemCount);
end

function JingMai:OnUsePartnerProtentialItem(pPlayer, nCount)
	if not self:CheckOpen(pPlayer) then
		return;
	end

	local nSaveInfo = pPlayer.GetUserValue(self.SAVE_GROUP_ID, self.SAVE_INDEX_ID);
	local nLast = math.max(nSaveInfo - nCount, 0);

	if nSaveInfo > 0 then
		pPlayer.CenterMsg(string.format("同伴使用了[FFFE0D]%s[-]個資質丹，丹田疲勞度降低[FFFE0D]%s[-]！", nCount, nCount), true);
		pPlayer.SetUserValue(self.SAVE_GROUP_ID, self.SAVE_INDEX_ID, nLast);

		if nLast <= 0 then
			pPlayer.SendBlackBoardMsg("當前丹田狀態變為[FFFE0D]充盈[-]狀態！", true);
		end
	end

	nCount = nCount - nSaveInfo;
	if nLast > 0 or nCount <= 0 then
		return;
	end

	local nZhenQiCount = 0;
	for i = 1, nCount do
		local nRandom = MathRandom(self.tbUseProtntialItemRandom[#self.tbUseProtntialItemRandom][1]);
		local nRate = self.tbUseProtntialItemRandom[1][2];
		for _, tbInfo in ipairs(self.tbUseProtntialItemRandom) do
			if tbInfo[1] >= nRandom then
				nRate = tbInfo[2];
				break;
			end
		end

		nZhenQiCount = nZhenQiCount + nRate * self.nUseItemProtentialZhenQiValue;
	end

	nZhenQiCount = math.max(math.floor(nZhenQiCount), 0);
	if nZhenQiCount <= 0 then
		return;
	end

	pPlayer.SendAward({{"ZhenQi", nZhenQiCount}}, false, false, Env.LogWay_XueWeiUseProtentialItem);
	pPlayer.CenterMsg(string.format("本次對同伴使用了[FFFE0D]%s[-]個資質丹，獲得了[FFFE0D]%s[-]真氣！", nCount, nZhenQiCount), true);
	Log("[JingMai] OnUsePartnerProtentialItem", pPlayer.dwID, pPlayer.szAccount, pPlayer.szName, nCount);
end

function JingMai:CheckCanResetXueWei(pPlayer, nXueWeiId)
	local nLevel = self:GetXueWeiLevel(pPlayer, nXueWeiId);
	if not nLevel or nLevel <= 0 then
		return false, "無需重置";
	end

	local tbBeenRequired = self.tbXueWeiBeenRequired[nXueWeiId] or {};
	for _, nBRXueWeiId in pairs(tbBeenRequired) do
		local nBRLevel = self:GetXueWeiLevel(pPlayer, nBRXueWeiId);
		if nBRLevel and nBRLevel > 0 then
			return false, string.format("需要先重置穴位[FFFE0D]%s[-]", self.tbXueWeiSetting[nBRXueWeiId].szName);
		end
	end

	return true, "", nLevel;
end

function JingMai:GetResetXueWeiAward(tbXueWeiInfo)
	local nTotalZhenCount = 0;
	for _, tbInfo in pairs(tbXueWeiInfo) do
		local nXueWeiId, nLevel = unpack(tbInfo);
		nTotalZhenCount = nTotalZhenCount + self.tbXueWeiSetting[nXueWeiId].tbCostZhenQi[nLevel];
	end
	nTotalZhenCount = math.max(math.floor(nTotalZhenCount * self.nResetZhenQiRate), 1);
	return {{"ZhenQi", nTotalZhenCount}}, nTotalZhenCount;
end

function JingMai:ResetXueWei(pPlayer, nXueWeiId)
	local bRet, szMsg, nLevel = self:CheckCanResetXueWei(pPlayer, nXueWeiId);
	if not bRet then
		pPlayer.CenterMsg(szMsg);
		return;
	end

	self:AddLevelupExtTimes(pPlayer, nLevel);
	self:ClearXueWeiFailTimes(pPlayer, nXueWeiId);
	self:SetXueWeiLevel(pPlayer, nXueWeiId, 0);
	self:UpdatePlayerAttrib(pPlayer);
	FightPower:ChangeFightPower("JingMai", pPlayer);

	local tbAward, nZhenQiCount = self:GetResetXueWeiAward({{nXueWeiId, nLevel}});
	pPlayer.SendAward(tbAward, nil, true, Env.LogWay_XueWeiResetAward);
	pPlayer.CallClientScript("JingMai:OnSyncXueWeiLevelChange", nXueWeiId);
	pPlayer.SendBlackBoardMsg(string.format("重置穴位 [FFFE0D]%s[-] 成功，獲得 [FFFE0D]%s[-] 真氣和 [FFFE0D]%s[-] 沖穴次數返還！", self.tbXueWeiSetting[nXueWeiId].szName, nZhenQiCount, nLevel), true);
	Log("[JingMai] ResetXueWei", pPlayer.dwID, pPlayer.szAccount, pPlayer.szName, nXueWeiId, nLevel);
end

function JingMai:CheckCanResetJingMai(pPlayer, nJingMaiId)
	local tbJingMai = self.tbJingMaiSetting[nJingMaiId];
	if not tbJingMai then
		return false, "不存在的經脈";
	end

	local szLogInfo = "";
	local tbXueWeiLearnedInfo = {};
	for _, nXueWeiId in pairs(tbJingMai.tbXueWei) do
		local nLevel = self:GetXueWeiLevel(pPlayer, nXueWeiId);
		if nLevel and nLevel > 0 then
			table.insert(tbXueWeiLearnedInfo, {nXueWeiId, nLevel});
			szLogInfo = string.format("%s%s|%s;", szLogInfo, nXueWeiId, nLevel);
		end
	end

	if #tbXueWeiLearnedInfo <= 0 then
		return false, "無需重置";
	end

	return true, "", szLogInfo, tbXueWeiLearnedInfo;
end

function JingMai:ResetJingMai(pPlayer, nJingMaiId)
	local bRet, szMsg, szLogInfo, tbXueWeiLearnedInfo = self:CheckCanResetJingMai(pPlayer, nJingMaiId);
	if not bRet then
		pPlayer.CenterMsg(szMsg);
		return;
	end

	local nTotalLevel = 0;
	for _, tbInfo in pairs(tbXueWeiLearnedInfo) do
		nTotalLevel = nTotalLevel + tbInfo[2];
		self:AddLevelupExtTimes(pPlayer, tbInfo[2]);
		self:ClearXueWeiFailTimes(pPlayer, tbInfo[1]);
		self:SetXueWeiLevel(me, tbInfo[1], 0);
		pPlayer.CallClientScript("JingMai:OnSyncXueWeiLevelChange", tbInfo[1]);
	end
	self:UpdatePlayerAttrib(pPlayer);
	FightPower:ChangeFightPower("JingMai", pPlayer);

	local tbAward, nZhenQiCount = self:GetResetXueWeiAward(tbXueWeiLearnedInfo);
	pPlayer.SendAward(tbAward, nil, true, Env.LogWay_XueWeiResetAward);
	pPlayer.SendBlackBoardMsg(string.format("重置經脈 [FFFE0D]%s[-] 成功，獲得 [FFFE0D]%s[-] 真氣和 [FFFE0D]%s[-] 沖穴次數返還！", self.tbJingMaiSetting[nJingMaiId].szName, nZhenQiCount, nTotalLevel), true);
	Log("[JingMai] ResetJingMai", pPlayer.dwID, pPlayer.szAccount, pPlayer.szName, nJingMaiId, szLogInfo);
end

function JingMai:OnFinishTask(nTaskId)
	if nTaskId ~= self.nOpenTaskId then
		return;
	end

	me.SendBlackBoardMsg("閣下已領悟了打通經脈的法門，可通過“[FFFE0D]同伴——經脈[-]”介面查看！", true);

	local nUseItemProtentialValue = 0;
	local tbAllPartner = me.GetAllPartner();
	for _, tbPartner in pairs(tbAllPartner) do
		-- 10003 号IntValue 存储的是同伴使用资质丹数量，为了效率所以直接通过这种方式获取
		-- 具体定义位置 CommonScript/Partner/LuaPartner.lua:45
		nUseItemProtentialValue = nUseItemProtentialValue + (tbPartner.tbIntValue[10003] or 0);
	end

	me.SetUserValue(self.SAVE_GROUP_ID, self.SAVE_INDEX_OPEN_DATE, Lib:GetLocalDay());
	local nItemCount = math.max(math.floor(nUseItemProtentialValue / Partner:GetItemValue(Partner.nPartnerProtentialItem)), 0);
	local nZhenQi = math.floor(self.nOpenJingMaiAwardRate * nItemCount);
	if nZhenQi > 0 then
		local tbMail = {
			To = me.dwID;
			Title = "真氣運行";
			Text = "      小友天資不錯，這麼快就領悟了[FFFE0D]經脈[-]中真氣運行的法門，在此之前你的同伴使用資質丹已經在丹田中凝結了很多[FFFE0D]真氣[-]，老朽就幫助你獲得這些真氣以便隨意使用吧。";
			From = "玄天道人";
			tbAttach = {{"ZhenQi", nZhenQi}};
			nLogReazon = Env.LogWay_JingMaiOpenAward;
		};
		Mail:SendSystemMail(tbMail);
	end
	me.CallClientScript("JingMai:OnClientEnterMap");
	Log("[JingMai] OnFinishTask", me.dwID, me.szAccount, me.szName, nItemCount, nZhenQi);
end

function JingMai:CheckShowRedPoint()
	if not JingMai:CheckOpen(me) then
		return false;
	end

	for nJingMaiId in pairs(self.tbJingMaiSetting) do
		if self:CheckJingMaiOpen(nJingMaiId) and Client:GetFlag("JingMai_" .. nJingMaiId) ~= 1 then
			return true;
		end
	end

	local nOpenDay = me.GetUserValue(self.SAVE_GROUP_ID, self.SAVE_INDEX_OPEN_DATE);
	if nOpenDay <= 0 then
		return false;
	end

	local nLocalDay = Lib:GetLocalDay();
	if nLocalDay - nOpenDay > 14 then
		return false;
	end

	local nTipDate = Client:GetFlag("JingMai");
	if nTipDate == nLocalDay then
		return false;
	end

	local bNeedTip = false;
	for nXueWeiId in pairs(self.tbXueWeiSetting) do
		if self:CheckXueWeiLevelup(me, nXueWeiId) then
			bNeedTip = true;
			break;
		end
	end

	return bNeedTip;
end

function JingMai:OnClientEnterMap()
	if self:CheckShowRedPoint() then
		Ui:SetRedPointNotify("PartnerMainPanel");
	end
end