
Require("CommonScript/Player/PlayerDef.lua");

FightPower.tbLevelFPSetting = LoadTabFile(
	"Setting/Player/PlayerLevel.tab",
	"dd", "Level",
	{"Level", "FightPower"});


FightPower.tbHonorFPSetting = Player.tbHonorLevelSetting;

function FightPower:Setup()
	local tbFightPowerTypeEquipPos = {};
	for nPos = 0, Item.EQUIPPOS_MAIN_NUM - 1 do
		tbFightPowerTypeEquipPos[nPos] = 1;
	end
	for nPos = Item.EQUIPPOS_SKILL_BOOK, Item.EQUIPPOS_SKILL_BOOK_End do
		tbFightPowerTypeEquipPos[nPos] = 1;
	end
	self.tbFightPowerTypeEquipPos = tbFightPowerTypeEquipPos

	self.tbFightPowerTypeHorsePos = {
		[Item.EQUIPPOS_HORSE] 		= 1;
		[Item.EQUIPPOS_REIN] 		= 1;
		[Item.EQUIPPOS_SADDLE] 		= 1;
		[Item.EQUIPPOS_PEDAL] 		= 1;
	}
end

FightPower:Setup()

function FightPower:GetFightPowerTypeByEquipPos(nEquipPos)
	if nEquipPos == Item.EQUIPPOS_ZHEN_YUAN then
		return "ZhenYuan"
	elseif self.tbFightPowerTypeHorsePos[nEquipPos] then
		return "Horse"
	else
		return "Equip"
	end
end


function FightPower:OnLogin(pPlayer)
	local tbFightPowerData = pPlayer.GetScriptTable("FightPower");
	if not tbFightPowerData.nStoneFightPower then
		tbFightPowerData.nStoneFightPower = self:CalcStoneFightPower(pPlayer);
		tbFightPowerData.nSkillFightPower = self:CalcSkillFightPower(pPlayer);
		tbFightPowerData.nEquipFightPower = self:CalcEquipFightPower(pPlayer);
		tbFightPowerData.nLevelFightPower = self:CalcLevelFightPower(pPlayer);
		tbFightPowerData.nStrengthenFightPower = self:CalcStrengthenFightPower(pPlayer);
		tbFightPowerData.nHonorFightPower 	  = self:CalcHonorFightPower(pPlayer);
		tbFightPowerData.nPartnerFightPower   = self:CalcPartnerFightPower(pPlayer);
	end

	if not tbFightPowerData.nHorseFightPower then
		tbFightPowerData.nHorseFightPower = 0;
		tbFightPowerData.nZhenYuanFightPower = 0;
		self:ChangeFightPower("Horse", pPlayer, true);
		self:ChangeFightPower("ZhenYuan", pPlayer, true);
		self:ChangeFightPower("Equip", pPlayer, true);
	end

	if not tbFightPowerData.nHouseFightPower then
		House:UpdateComfortValue(pPlayer);
		tbFightPowerData.nHouseFightPower = 0;
		self:ChangeFightPower("House", pPlayer, true);
	end

	if not tbFightPowerData.nJingMaiFightPower then
		tbFightPowerData.nJingMaiFightPower = self:CalcJingMaiFightPower(pPlayer);
	end

	self:ChangeFightPower("Honor", pPlayer, true);
	self:ResetFightPower(pPlayer);
end

function FightPower:ResetFightPower(pPlayer)
	local nTotalFightPower = self:GetTotalFightPower(pPlayer);
	local pNpc = pPlayer.GetNpc();
	pNpc.SetFightPower(nTotalFightPower);

	local tbFightPowerData = pPlayer.GetScriptTable("FightPower");
	pPlayer.CallClientScript("Ui.Stronger:SyncFightPower", pPlayer.GetFightPower(),
		{
			tbFightPowerData.nStoneFightPower,
			tbFightPowerData.nSkillFightPower,
			tbFightPowerData.nEquipFightPower,
			tbFightPowerData.nLevelFightPower,
			tbFightPowerData.nStrengthenFightPower,
			tbFightPowerData.nHonorFightPower,
			tbFightPowerData.nPartnerFightPower,
			tbFightPowerData.nHouseFightPower,
			tbFightPowerData.nZhenYuanFightPower,
			tbFightPowerData.nJingMaiFightPower,
		});

	return nTotalFightPower;
end

function FightPower:GetTotalFightPower(pPlayer)
	local tbFightPowerData = pPlayer.GetScriptTable("FightPower");

	local nTotal = 0;
	nTotal = nTotal + (tbFightPowerData.nStoneFightPower or 0);
	nTotal = nTotal + (tbFightPowerData.nSkillFightPower or 0);
	nTotal = nTotal + (tbFightPowerData.nEquipFightPower or 0);
	nTotal = nTotal + (tbFightPowerData.nLevelFightPower or 0);
	nTotal = nTotal + (tbFightPowerData.nStrengthenFightPower or 0);
	nTotal = nTotal + (tbFightPowerData.nHonorFightPower or 0);
	nTotal = nTotal + (tbFightPowerData.nPartnerFightPower or 0);
	nTotal = nTotal + (tbFightPowerData.nHouseFightPower or 0);
	nTotal = nTotal + (tbFightPowerData.nHorseFightPower or 0);
	nTotal = nTotal + (tbFightPowerData.nZhenYuanFightPower or 0);
	nTotal = nTotal + (tbFightPowerData.nJingMaiFightPower or 0);
	return nTotal;
end

function FightPower:ChangeFightPower(szType, pPlayer, bSlient)
	local fnCalc = self["Calc"..szType.."FightPower"];
	if not fnCalc then
		return;
	end

	pPlayer = pPlayer or me;

	local tbFightPowerData = pPlayer.GetScriptTable("FightPower");
	local nCurFightPower = fnCalc(self, pPlayer);
	local szSaveKey = "n" .. szType .. "FightPower";
	local nOrgFightPower = tbFightPowerData[szSaveKey];

	local nExtChange = 0;
	if szType == "Equip" then
		local nChange1 = self:ChangeFightPower("Strengthen", pPlayer, true);
		local nChange2 = self:ChangeFightPower("Stone", pPlayer, true);
		nExtChange = nExtChange + (nChange1 or 0);
		nExtChange = nExtChange + (nChange2 or 0);
	end

	if nOrgFightPower then
		local nChange = nCurFightPower - nOrgFightPower;
		if nChange ~= 0 then
			tbFightPowerData[szSaveKey] = nCurFightPower;
			self:ResetFightPower(pPlayer);
			local nTotalFightPower = pPlayer.GetFightPower(); --脚本里算的总战力ResetFightPower少了属性里加的战力

			if nChange > 0 then
				if not bSlient then
					self:SendInfo(pPlayer, nTotalFightPower, nTotalFightPower - nChange - nExtChange);
				end

				local nOldMaxPower = tbFightPowerData.nMaxFightPower or 0;
				if version_tx and nTotalFightPower > nOldMaxPower then
					tbFightPowerData.nMaxFightPower = nTotalFightPower;

					if nTotalFightPower >= 2000000 and nOldMaxPower < 2000000 then
						Sdk:SendTXLuckyBagMail(pPlayer, "Power200w");
					elseif nTotalFightPower >= 1000000 and nOldMaxPower < 1000000 then
						Sdk:SendTXLuckyBagMail(pPlayer, "Power100w");
					end
				end
			end
			RankBoard:UpdateRankVal("FightPower", pPlayer, szType, nCurFightPower);

			AssistClient:ReportQQScore(pPlayer, Env.QQReport_FightPower, nTotalFightPower, 0, 1)
		end
		return nChange;
	end
end

function FightPower:SendInfo(pPlayer, nCur, nOrg)
	if nCur >= 100 then
		pPlayer.CallClientScript("Ui:OpenWindow", "FightPowerTip", nCur, nOrg);
	end
end

function FightPower:SendInfoByChange(pPlayer, nChange)
	local nTotalFightPower = FightPower:GetTotalFightPower(pPlayer);
	self:SendInfo(pPlayer, nTotalFightPower, nTotalFightPower - nChange);
end

function FightPower:CalcLevelFightPower(pPlayer)
	local tbLevel = self.tbLevelFPSetting[pPlayer.nLevel];
	local nLevelFightPower = tbLevel.FightPower;
	return nLevelFightPower;
end

function FightPower:CalcHonorFightPower(pPlayer)
	local tbHonorLevel = Player.tbHonorLevel;
	local nHonorLevel  = pPlayer.GetUserValue(tbHonorLevel.nSaveGroupID, tbHonorLevel.nSaveFightPower);
	local nHonorFightPower = 0;
	if nHonorLevel > 0 then
		for nI = 1, nHonorLevel do
			local tbHonor = self.tbHonorFPSetting[nI];
			local nCurAddFight = tbHonor and tbHonor.PowerValue or 0;
			nHonorFightPower = nHonorFightPower + nCurAddFight;
		end
	end

	return nHonorFightPower;
end

function FightPower:CalcPartnerFightPower(pPlayer)
	local nPartnerFightPower = 0;
	local tbPartnerPos = pPlayer.GetPartnerPosInfo();

	for nIndex, nPartnerId in pairs(tbPartnerPos) do
		if nPartnerId and nPartnerId ~= 0 then
			local tbPartner = pPlayer.GetPartnerInfo(nPartnerId);
			nPartnerFightPower = nPartnerFightPower + tbPartner.nFightPower;
		end
	end

	return nPartnerFightPower;
end

function FightPower:CalcJingMaiFightPower(pPlayer)
	return JingMai:GetFightPower(pPlayer);
end

function FightPower:CalcSkillFightPower(pPlayer)
	local nSkillPoint = pPlayer.GetUserValue(FightSkill.nSaveSkillPointGroup, FightSkill.nSaveCostSkillPoint);
	local nFightPower = FightSkill:GetSkillPointFightPower(nSkillPoint)

    return nFightPower;
end

function FightPower:CalcEquipFightPower(pPlayer)
	local nEquipFightPower = 0;
	for nPos,_ in pairs(self.tbFightPowerTypeEquipPos) do
		local pEquip = pPlayer.GetEquipByPos(nPos);
		if pEquip then
			nEquipFightPower = nEquipFightPower + pEquip.nFightPower;
		end
	end
	return nEquipFightPower
end

function FightPower:CalcHorseFightPower(pPlayer)
	local nEquipFightPower = 0;
	for nPos,_ in pairs(self.tbFightPowerTypeHorsePos) do
		local pEquip = pPlayer.GetEquipByPos(nPos);
		if pEquip then
			nEquipFightPower = nEquipFightPower + pEquip.nFightPower;
		end
	end
	return nEquipFightPower
end

function FightPower:CalcZhenYuanFightPower(pPlayer)
	local nEquipFightPower = 0;
	local pEquip = pPlayer.GetEquipByPos(Item.EQUIPPOS_ZHEN_YUAN);
	if pEquip then
		nEquipFightPower = nEquipFightPower + pEquip.nFightPower;
	end
	return nEquipFightPower
end

function FightPower:CalcStrengthenFightPower(pPlayer)
	local nTotalStrengthenFightPower = 0;
	local tbEquips =  pPlayer.GetEquips();
	for nEquipPos = 0, Item.EQUIPPOS_MAIN_NUM  - 1 do
		if tbEquips[nEquipPos] then
			local nFightPower = Strengthen:GetStrenFightPower(pPlayer, nEquipPos);
			nTotalStrengthenFightPower = nTotalStrengthenFightPower + nFightPower;
		end
	end

	return nTotalStrengthenFightPower;
end

function FightPower:CalcStoneFightPower(pPlayer)
	local nStoneFightPower = 0;
	local tbEquips =  pPlayer.GetEquips();
	for nEquipPos = 0, Item.EQUIPPOS_MAIN_NUM - 1 do
		if tbEquips[nEquipPos] then
			local tbInset = pPlayer.GetInsetInfo(nEquipPos);
			for _, nStoneTemplateId in pairs(tbInset) do
				if nStoneTemplateId ~= 0 then
					local nFightPower = StoneMgr:GetStoneFightPower(nStoneTemplateId);
					nStoneFightPower = nStoneFightPower + nFightPower;
				end
			end
		end
	end

	return nStoneFightPower;
end

function FightPower:CalcHouseFightPower(pPlayer)
	local nComfort = House:GetComfortValue(pPlayer);
	return nComfort * 10;
end

function FightPower:GetFightPower(nPlayerId)
	local pAsyncData = KPlayer.GetAsyncData(nPlayerId)
    if not pAsyncData then
        return 0;
    end

	return pAsyncData.GetFightPower();
end
