

function Player:LoadAvatarSetting()
	self.tbAvatarEquip = {}
	self.tbAvatarInset = {}
	self.tbAvatarSkill = {};
	
	local tbEquipSetting = LoadTabFile("Setting/Avatar/Equip.tab", "sd", nil, {"Key", "EquipId"});
	local tbInsetSetting = LoadTabFile("Setting/Avatar/Inset.tab", "sdddddd", nil, {"Key", "EquipPos", "StoneId1", "StoneId2", "StoneId3", "StoneId4", "StoneId5"});
	
	for _, tbInfo in pairs(tbEquipSetting) do
		self.tbAvatarEquip[tbInfo.Key] = self.tbAvatarEquip[tbInfo.Key] or {};
		table.insert(self.tbAvatarEquip[tbInfo.Key], tbInfo.EquipId)
	end
	
	for _,v in pairs(tbInsetSetting) do
		self.tbAvatarInset[v.Key] = self.tbAvatarInset[v.Key] or {};
		self.tbAvatarInset[v.Key][v.EquipPos] = {v.StoneId1, v.StoneId2, v.StoneId3, v.StoneId4, v.StoneId5};
	end
end

Player:LoadAvatarSetting()

function Player:ChangePlayer2Avatar(pPlayer, nFaction, nLevel, szEquipKey, szInsetKey, nEnhLevel)
	if pPlayer.Change2Avatar(nFaction, nLevel) then
		GameSetting:SetGlobalObj(pPlayer);
		local tbFightPowerData = pPlayer.GetScriptTable("FightPower");
		for szKey, _ in pairs(tbFightPowerData) do
			tbFightPowerData[szKey] = nil
		end
		-- 装备
		if szEquipKey and self.tbAvatarEquip[szEquipKey] then
			local tbSetting = self.tbAvatarEquip[szEquipKey];
			for _, nEquipTemplateId in ipairs(tbSetting) do
				local pEquip = pPlayer.AddItem(nEquipTemplateId, 1);
				Item:UseEquip(pEquip.dwId);
			end
		end
				
		local tbAllEquips = pPlayer.GetEquips();
		-- 镶嵌
		if szInsetKey and self.tbAvatarInset[szInsetKey] then
			for nEquipPos, nEquipId in pairs(tbAllEquips) do
		    	local tbInsetSetting = self.tbAvatarInset[szInsetKey][nEquipPos];
		    	local nInsetPos = 0
		    	for _, nStoneTemplateId in pairs(tbInsetSetting) do
		    		if nStoneTemplateId ~= 0 then
		    			nInsetPos = nInsetPos + 1;
		    			pPlayer.SetInsetInfo(nEquipPos, nInsetPos, nStoneTemplateId)
		    			local nInsetKey = StoneMgr:GetInsetValueKey(nEquipPos, nInsetPos)
						pPlayer.SetUserValue(StoneMgr.USER_VALUE_GROUP,  nInsetKey, nStoneTemplateId)
			    		--StoneMgr:DoInset(pPlayer, nEquipPos, nEquipId, nStoneTemplateId, nil, nInsetPos);
		    		end
		    	end
	    	end
	    end
	    StoneMgr:UpdateInsetAttrib(pPlayer)
	    
	    -- 强化
	    if nEnhLevel and nEnhLevel > 0 then
			for nEquipPos, nEquipId in pairs(tbAllEquips) do
				pPlayer.SetStrengthen(nEquipPos, nEnhLevel)
				pPlayer.SetUserValue(Strengthen.USER_VALUE_GROUP, nEquipPos + 1, nEnhLevel)
	
				--突破次数
				local nBreakCount 	= Strengthen:GetPlayerBreakCount(pPlayer, nEquipPos);
				local nNeed 		= Strengthen:GetNeedBreakCount(nEnhLevel);
				Strengthen:SetPlayerBreakCount(pPlayer, nEquipPos, nNeed)
			end
		end
		Strengthen:UpdateEnhAtrrib(pPlayer)
		--FightPower:ChangeFightPower("Strengthen", pPlayer, true);
		
		local szSkillKey = nFaction.."_"..nLevel
		if not self.tbAvatarSkill[szSkillKey] then
			self.tbAvatarSkill[szSkillKey] = {}
			local tbFactionSkill = FightSkill:GetFactionSkill(me.nFaction);
			for _,v in pairs(tbFactionSkill) do
				local nSkillId = v.SkillId;
				local tbLevelUp = FightSkill.tbSkillLevelUp[nSkillId];
				if tbLevelUp then
					local nSkillMaxLevel = FightSkill:GetSkillMaxLevel(nSkillId);
					local nToLevel = nSkillMaxLevel;
		
					for i = 1, nSkillMaxLevel do
						local tbNeed = tbLevelUp[i];
						local nReqLevel = tbNeed[1];
						if nLevel < nReqLevel then
							nToLevel = i - 1;
							break;
						end
					end
					table.insert(self.tbAvatarSkill[szSkillKey], {nSkillId, nToLevel})
				end
			end
		end
		for _, tbSkillInfo in pairs(self.tbAvatarSkill[szSkillKey]) do
			local nSkillId, nToLevel = unpack(tbSkillInfo)
			local _, nBaseLevel = pPlayer.GetSkillLevel(nSkillId);
			if nToLevel > 1 and nToLevel > nBaseLevel then
				pPlayer.LevelUpFightSkill(nSkillId, nToLevel - nBaseLevel)
			end
		end
		pPlayer.SetUserValue(FightSkill.nSaveSkillPointGroup, FightSkill.nSaveCostSkillPoint, nLevel + 19);	

		pPlayer.ClearPartnerInfo();
		--FightPower:ChangeFightPower("Skill", pPlayer);
		FightPower:OnLogin(pPlayer);

		local pNpc = pPlayer.GetNpc()
		pNpc.SetCurLife(pNpc.nMaxLife)
		
		GameSetting:RestoreGlobalObj()
		pPlayer.CallClientScript("PlayerEvent:OnReConnectZoneClient")
		return true;
	end
	return false;
end

function Player:AvatarRelogin(pPlayer)
	FightPower:OnLogin(pPlayer);
	pPlayer.CallClientScript("PlayerEvent:OnReConnectZoneClient")
end
