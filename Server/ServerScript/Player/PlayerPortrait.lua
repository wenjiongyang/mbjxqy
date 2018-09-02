function PlayerPortrait:AddPortrait(pPlayer, nPortraitID)
	local nSaveIdx = self:GetSaveIdx(nPortraitID)
	if not nSaveIdx then
		Log("[PlayerPortrait AddAPortrait] Fail, Not Found", nPortraitID)
		return
	end

	if nSaveIdx == 0 then-- Basic Portrait
		return
	end

	local nSaveKey, nBit = self:GetSaveInfo(nSaveIdx)
	local nFlag = pPlayer.GetUserValue(self.Def.SAVE_GROUP, nSaveKey)
	local nRet  = KLib.GetBit(nFlag, nBit)
	if nRet == 0 then
		nFlag = KLib.SetBit(nFlag, nBit, 1)
		pPlayer.SetUserValue(self.Def.SAVE_GROUP, nSaveKey, nFlag)
		pPlayer.CallClientScript("PlayerPortrait:OnAddPortrait")
		Log("[PlayerPortrait AddAPortrait] Success", pPlayer.dwID, pPlayer.szName, nPortraitID)
	end
end

function PlayerPortrait:ChangePortrait(pPlayer, nPortrait)
	if not self:IsAvaliablePortraits(nPortrait) then
		pPlayer.CenterMsg("不可更換頭像！");
		return;
	end

	pPlayer.SetPortrait(nPortrait);
end
