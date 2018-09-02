
function StoneMgr:OnCombine(pPlayer, nTemplateId, nCreateCount)
	nCreateCount = nCreateCount or 1
	local bRet, szInfo = self:CanCombine(pPlayer, nTemplateId, nCreateCount);
	if not bRet then
		pPlayer.CenterMsg(szInfo);
		return;
	end
	local nDefaultCombineCount = StoneMgr:GetCombineDefaulCount(nTemplateId)
	local nCombineCount = nDefaultCombineCount * nCreateCount

	local nCost = self:GetCombineCost(nTemplateId, nCombineCount);
	if not pPlayer.CostMoney("Coin", nCost, Env.LogWay_StoneCombine) then
		return
	end

	if not pPlayer.ConsumeItemInAllPos(nTemplateId, nCombineCount, Env.LogWay_StoneCombine) then
		pPlayer.CenterMsg("扣除道具失敗");
		return;
	end

	local nNextTemplateId = self:GetNextLevelStone(nTemplateId);
	pPlayer.AddItem(nNextTemplateId, nCreateCount, nil, Env.LogWay_StoneCombine);

	pPlayer.CallClientScript("StoneMgr:OnResponseCombine");
	pPlayer.CenterMsg("合成成功");
	Log(string.format("StoneMgr:OnCombine pPlayer:%d, nTemplateId:%d, nCombineCount:%d, nNextTemplateId:%d, nCreateCount:%d", pPlayer.dwID, nTemplateId, nCombineCount, nNextTemplateId, nCreateCount))
end

function StoneMgr:DoQuickCombineStone(pPlayer, nStoneTemplateId)
	local nDefaultCombineCount = StoneMgr:GetCombineDefaulCount(nStoneTemplateId);
	local nPreStoneId = self.tbPreStoneIndex[nStoneTemplateId];
	if not nPreStoneId then
		return;
	end

	local tbTotalNeedStone, nTotalCost = StoneMgr:GetCombineStoneNeed(nPreStoneId, nDefaultCombineCount, pPlayer)
	if not tbTotalNeedStone then
		pPlayer.CenterMsg("不能合成！");
		return;
	end

	local tbBaseInfo = KItem.GetItemBaseProp(nStoneTemplateId)
	if tbBaseInfo.nRequireLevel > pPlayer.nLevel then
		pPlayer.CenterMsg("等級不足");
		return;
	end

	for i, v in ipairs(tbTotalNeedStone) do
		if pPlayer.GetItemCountInAllPos(v[1]) < v[2] then
			pPlayer.CenterMsg("缺少對應魂石");
			return;
		end
	end

	if not pPlayer.CostMoney("Coin", nTotalCost, Env.LogWay_StoneCombine) then
		pPlayer.CenterMsg("銀兩不足");
		return;
	end

	for i,v in ipairs(tbTotalNeedStone) do
		if not pPlayer.ConsumeItemInAllPos(v[1], v[2], Env.LogWay_QuickCombie) then
			pPlayer.CenterMsg("扣除道具異常", true);
			Log("StoneMgr:DoQuickCombineStone del Stone Miss ", v[1], v[2], pPlayer.dwID);
			return;
		end
	end

	pPlayer.AddItem(nStoneTemplateId, 1, nil, Env.LogWay_StoneCombine);
	pPlayer.CenterMsg("合成成功");
	Log(string.format("StoneMgr:DoQuickCombineStone pPlayer:%d, nTemplateId:%d, nCombineCount:%d, nCreateCount:%d", pPlayer.dwID, nStoneTemplateId, 1, 1))
end

function StoneMgr:OnQuicklyCombine(pPlayer, nEquipId, nInsetPos)
	local pEquip = pPlayer.GetItemInBag(nEquipId);
	if not pEquip then
		return;
	end

	local tbInset = me.GetInsetInfo(pEquip.nEquipPos);
	local nTemplateId = tbInset[nInsetPos];
	if nTemplateId == 0 then
		return nil, "不存在魂石" ;
	end

	local tbTotalNeedStone, nTotalCost = StoneMgr:GetCombineStoneNeed(nTemplateId, StoneMgr.COMBINE_COUNT, pPlayer, true, pEquip.nEquipPos)
	if not tbTotalNeedStone then
		return
	end

	local nNextTemplateId = self:GetNextLevelStone(nTemplateId);
	local tbData = self.tbStoneSetting[nNextTemplateId];
	if not tbData then
		return
	end
	local tbBaseInfo = KItem.GetItemBaseProp(nNextTemplateId)
	if tbBaseInfo.nRequireLevel > pPlayer.nLevel then
		return nil, "等級不足"
	end

	for i, v in ipairs(tbTotalNeedStone) do
		if not v[3] and pPlayer.GetItemCountInAllPos(v[1]) < v[2] then
			return nil, "缺少對應魂石"
		end
	end

	if not pPlayer.CostMoney("Coin", nTotalCost, Env.LogWay_StoneCombine) then
		return nil, "銀兩不足"
	end

	--如果
	local bReplaced = false;
	for i,v in ipairs(tbTotalNeedStone) do
		local nLastItemId, nLastItemNum, nOrgInsetPos = unpack(v);
		if nOrgInsetPos then
			if nOrgInsetPos == nInsetPos then
				bReplaced = true;
			end
			if not self:DoRemoveInset(pPlayer, pEquip.nEquipPos, nOrgInsetPos) then
				return false, "ERROR" .. nOrgInsetPos
			end
		else
			if not pPlayer.ConsumeItemInAllPos(nLastItemId, nLastItemNum, Env.LogWay_QuickCombie) then
				Log("StoneMgr:OnQuicklyCombine del Stone Miss ", nLastItemId, nLastItemNum, pPlayer.dwID)
				return
			end	
		end
	end
	if not bReplaced then
		pPlayer.AddItem(nTemplateId, 1, nil, Env.LogWay_InsetGetOrg);
	end

	self:DoInset(pPlayer, pEquip.nEquipPos, pEquip.dwId, nNextTemplateId, true, nInsetPos);

	--现在的快速合成会有很多空位了，所以还是检查去空的
	self:CheckUpdateStonePos(pPlayer, pEquip.nEquipPos)

	return true
end

function StoneMgr:CheckUpdateStonePos(pPlayer, nEquipPos)
	local tbInset = pPlayer.GetInsetInfo(nEquipPos);
	local nLastStonePos;
	local tbSortInset = {}
	for i=1,StoneMgr.INSET_COUNT_MAX do
		if tbInset[i] and tbInset[i] ~= 0 then
			nLastStonePos = i;
			table.insert(tbSortInset, tbInset[i])
		end
	end
	if #tbSortInset ~= nLastStonePos then
		for k, v in pairs(tbInset) do
			if v ~= 0 then
				self:DoRemoveInset(pPlayer, nEquipPos, k)
			end
		end
		for i,v in ipairs(tbSortInset) do
			self:DoRealInset(pPlayer, nEquipPos, i, v)		
		end
		pPlayer.CallClientScript("StoneMgr:OnResponseInset", true, nEquipPos)
	end
end

function StoneMgr:OnInset(pPlayer, nEquipId, nStoneTemplateId, nInsetPos)
	local bRet, szInfo, tbTotalNeedStone, nCombineCost, nNextTemplateId = self:CanInset(nEquipId, nStoneTemplateId, pPlayer, nInsetPos);
	if not bRet then
		pPlayer.CenterMsg(szInfo);
		return;
	end

	local pEquip = pPlayer.GetItemInBag(nEquipId);
	if not pEquip then
		return
	end
	local nEquipPos = pEquip.nEquipPos
	local tbInset = pPlayer.GetInsetInfo(nEquipPos);


	--调整为按顺序镶嵌
	if tbInset[nInsetPos] == 0 then
		for i = 1, nInsetPos  - 1 do
			if tbInset[i] == 0 then
				nInsetPos = i;
			end
		end
	end

	local nOrgInsetId = tbInset[nInsetPos];
	if nOrgInsetId and  nOrgInsetId ~= 0 then
		local nCost = self:GetRemoveInsetCost(nOrgInsetId)
		if not pPlayer.CostMoney("Coin", nCost, Env.LogWay_RemoveInset, nOrgInsetId) then
			pPlayer.CenterMsg("剝離銀兩不足")
			return
		end
	end

	local nInsetStoneId = nStoneTemplateId
	if tbTotalNeedStone and nCombineCost and nNextTemplateId then
		for i, v in ipairs(tbTotalNeedStone) do
			if pPlayer.GetItemCountInAllPos(v[1]) < v[2] then
				pPlayer.CenterMsg("缺少對應魂石")
				return
			end
		end
		if not pPlayer.CostMoney("Coin", nCombineCost, Env.LogWay_StoneCombine) then
			return;
		end
		for i,v in ipairs(tbTotalNeedStone) do
		if not pPlayer.ConsumeItemInAllPos(v[1], v[2], Env.LogWay_OnInset) then
				Log("StoneMgr:OnInsetQuicklyCombine del Stone Miss ", v[1], v[2], pPlayer.dwID)
				return
			end
		end
		nInsetStoneId = nNextTemplateId
	else
		if pPlayer.ConsumeItemInAllPos(nStoneTemplateId, 1, Env.LogWay_OnInset) == 0 then
			pPlayer.CenterMsg("魂石數量不足");
			return;
		end	
	end

	self:DoInset(pPlayer, nEquipPos, nEquipId, nInsetStoneId, true, nInsetPos);

	if nOrgInsetId and nOrgInsetId ~= 0 then
		pPlayer.AddItem(nOrgInsetId, 1, nil, Env.LogWay_InsetGetOrg);
	end
end

function StoneMgr:RemoveInset(pPlayer, nEquipId, nInsetPos)
	local pEquip = pPlayer.GetItemInBag(nEquipId);
	if not pEquip then
		return
	end

	local nEquipPos = pEquip.nEquipPos
	local tbInset = pPlayer.GetInsetInfo(nEquipPos);
	local nOrgInsetId = tbInset[nInsetPos]
	if not nOrgInsetId or nOrgInsetId == 0 then
		return false, "對應位置沒有魂石"
	end

	local nLastPosStone = nInsetPos;
	for i = nInsetPos + 1, self.INSET_COUNT_MAX do
		if tbInset[i] ~= 0 then
			nLastPosStone = i;
		end
	end

	local nOrgFightPower = FightPower:CalcStoneFightPower(pPlayer);

	local nCost = self:GetRemoveInsetCost(nOrgInsetId)
	if not pPlayer.CostMoney("Coin", nCost, Env.LogWay_RemoveInset, nOrgInsetId) then
		return false, "剝離銀兩不足"
	end

	if not self:DoRemoveInset(pPlayer, nEquipPos, nInsetPos) then
		return false, "ERROR1"
	end

	pPlayer.AddItem(nOrgInsetId, 1, nil, Env.LogWay_InsetGetOrg);

	if nLastPosStone > nInsetPos then --将最后位的移到空位这里
		if not self:DoRemoveInset(pPlayer, nEquipPos, nLastPosStone) then
			return false, "ERROR2"
		end

		if not self:DoRealInset(pPlayer, nEquipPos, nInsetPos, tbInset[nLastPosStone]) then
			return false, "ERROR3"
		end
	end

	FightPower:ChangeFightPower("Stone", pPlayer, true);
	pPlayer.CallClientScript("StoneMgr:OnResponseInset", false, nEquipPos)

	local nCurFightPower = FightPower:CalcStoneFightPower(pPlayer);
	FightPower:SendInfoByChange(pPlayer, nCurFightPower - nOrgFightPower);
	StoneMgr:UpdateInsetAttrib(pPlayer)
	return true, "剝離成功"
end

function StoneMgr:DoRemoveInset(pPlayer, nEquipPos, nInsetPos)
	if not pPlayer.RemoveInset(nEquipPos, nInsetPos) then
		Log(debug.traceback(), pPlayer.dwID, nEquipPos, nInsetPos)
		return
	end
	local nInsetKey = self:GetInsetValueKey(nEquipPos, nInsetPos)
	local nOldStoneTemplateId = pPlayer.GetUserValue(self.USER_VALUE_GROUP, nInsetKey)
	pPlayer.SetUserValue(self.USER_VALUE_GROUP, nInsetKey , 0)
	local pAsyncData = KPlayer.GetAsyncData(pPlayer.dwID)
    if pAsyncData then
    	pAsyncData.SetInset(StoneMgr:GetInsetAsyncKey(nEquipPos, nInsetPos), 0)
    end
    pPlayer.TLog("InsetFlow", nEquipPos, nInsetPos, nOldStoneTemplateId, 0)
    return true
end

function StoneMgr:DoRealInset(pPlayer, nEquipPos, nInsetPos, nStoneTemplateId)
	if not pPlayer.SetInsetInfo(nEquipPos, nInsetPos, nStoneTemplateId) then
		Log(debug.traceback(), pPlayer.dwID, nEquipPos, nInsetPos, nStoneTemplateId)
		return
	end

	local nInsetKey = self:GetInsetValueKey(nEquipPos, nInsetPos)
	local nOldStoneTemplateId = pPlayer.GetUserValue(self.USER_VALUE_GROUP, nInsetKey)
	pPlayer.SetUserValue(self.USER_VALUE_GROUP,  nInsetKey, nStoneTemplateId)
	local pAsyncData = KPlayer.GetAsyncData(pPlayer.dwID)
    if pAsyncData then
    	pAsyncData.SetInset(StoneMgr:GetInsetAsyncKey(nEquipPos, nInsetPos), nStoneTemplateId)
    end

    pPlayer.TLog("InsetFlow", nEquipPos, nInsetPos, nOldStoneTemplateId, nStoneTemplateId)
    return true
end

function StoneMgr:DoInset(pPlayer, nEquipPos, nEquipId, nStoneTemplateId, bFightPowerNotify, nInsetPos)
	if not self:DoRealInset(pPlayer, nEquipPos, nInsetPos, nStoneTemplateId) then
		return
	end

	local nAchiveveLevel, nRedbagInsertLevel = StoneMgr:UpdateInsetAttrib(pPlayer)

	FightPower:ChangeFightPower("Stone", pPlayer, not bFightPowerNotify);

	EverydayTarget:AddCount(pPlayer, "EquipStone")

	pPlayer.CallClientScript("StoneMgr:OnResponseInset", true, nEquipPos, nInsetPos)

	local tbInset = pPlayer.GetInsetInfo(nEquipPos);
	local nHasInset = 0
	for i,v in pairs(tbInset) do
		if v ~= 0 then
			nHasInset = nHasInset + 1;
		end
	end

	if nHasInset == 4 then
		Achievement:AddCount(pPlayer, "InsetFull_1");
	end
	Achievement:AddCount(pPlayer, "InsetOnce_1");

	local bFinishInsetMaster = Achievement:CheckCompleteLevel(pPlayer, "InsetMaster", 6);
	if not bFinishInsetMaster then
		if nAchiveveLevel and nAchiveveLevel ~= 0 then
			local tbAcheiSet = 
			{
				[1] = "InsetMaster_1",
				[2] = "InsetMaster_2",
				[3] = "InsetMaster_3",
				[4] = "InsetMaster_4",
				[5] = "InsetMaster_5",
				[6] = "InsetMaster_6",
			};

			for i = nAchiveveLevel, nAchiveveLevel - 3, -1 do
				if tbAcheiSet[i] then
					Achievement:AddCount(pPlayer, tbAcheiSet[i]);
					TeacherStudent:OnAllEquipInsert(pPlayer, i)
				end
			end
		end
	end

	if nRedbagInsertLevel and nRedbagInsertLevel>0 then
		for i=1,nRedbagInsertLevel do
			Kin:RedBagOnEvent(pPlayer, Kin.tbRedBagEvents.all_insert, i)
		end
	end

	Log(string.format("StoneMgr:DoInset pPlayer:%d, nEquipPos:%d, nEquipId:%d, nInsetPos:%d, nStoneTemplateId:%d", pPlayer.dwID, nEquipPos, nEquipId, nInsetPos, nStoneTemplateId))
end

function StoneMgr:OnQuicklyInset(pPlayer, nEquipId)
	if 1 then
		return
	end
	--todo 暂时不用的接口
	if pPlayer.nLastQuickInsetTime == GetTime() then
		return
	end
	pPlayer.nLastQuickInsetTime = GetTime()
	local pEquip = pPlayer.GetItemInBag(nEquipId);
	if not pEquip then
		pPlayer.CenterMsg("不存在裝備");
		return;
	end
	local nEquipPos = pEquip.nEquipPos

	local bInseted = false
	local tbStones = self:GetAllStoneInBag(pPlayer);
	local tbAvailabeStone = {};
	for nTemplateId, nCount in pairs(tbStones) do
		local bAvailable = self:CanInset(nEquipId, nTemplateId, pPlayer);
		if bAvailable then
			local tbBaseInfo = KItem.GetItemBaseProp(nTemplateId);
			tbAvailabeStone[nTemplateId] =
			{
				nTemplateId = nTemplateId,
				nLevel 		= tbBaseInfo.nLevel,
				nInsetPos 	= self:GetStoneInsetPos(nTemplateId, nEquipPos),
			};
		end
	end

	local tbInset = pPlayer.GetInsetInfo(nEquipPos);
	local nOrgFightPower = FightPower:CalcStoneFightPower(pPlayer);
	for i, nId in pairs(tbInset) do
		if nId ~= 0 then -- 找到相同类型且更高级的来替换
			local tbBaseInfo = KItem.GetItemBaseProp(nId);
			for k, v in pairs(tbAvailabeStone) do
				if v.nInsetPos == i and v.nLevel > tbBaseInfo.nLevel then
					if pPlayer.ConsumeItemInAllPos(k, 1, Env.LogWay_QuickInset) ~= 0 then
						self:DoInset(pPlayer, nEquipPos, pEquip.dwId, k);
						pPlayer.AddItem(nId, 1, nil, Env.LogWay_InsetGetOrg);
						tbAvailabeStone[k] = nil;
						bInseted = true
					end
				end
			end
		else --空位置就找到最高等级的魂石来镶嵌
			local nLevel, nHighestTemplateId;
			for k,v in pairs(tbAvailabeStone) do
				if v.nInsetPos == i and (not nLevel or v.nLevel > nLevel)  then
					nLevel 				= v.nLevel;
					nHighestTemplateId 	= v.nTemplateId;
				end
			end
			if nHighestTemplateId then
				if pPlayer.ConsumeItemInAllPos(nHighestTemplateId, 1, Env.LogWay_QuickInset) ~= 0 then
					self:DoInset(pPlayer, pEquip.nEquipPos, pEquip.dwId, nHighestTemplateId);
					tbAvailabeStone[nHighestTemplateId] = nil;
					bInseted = true
				end
			end
		end
	end

	--	同位置的检查有没有能快速合成的
	local szShowMsg;
	for i, nId in pairs(tbInset) do
		local bRet, szMsg, bNotify = self:OnQuicklyCombine(pPlayer, nEquipId, i)
		if bRet then
			bInseted = bRet
			bRet, szMsg, bNotify = self:OnQuicklyCombine(pPlayer, nEquipId, i)
			if bRet then
				bRet, szMsg, bNotify = self:OnQuicklyCombine(pPlayer, nEquipId, i)
			end
		end
		if bNotify and szMsg then
			szShowMsg = szMsg
		end
	end

	if szShowMsg then
		pPlayer.CenterMsg(szShowMsg)
	end

	local nCurFightPower = FightPower:CalcStoneFightPower(pPlayer);
	if nCurFightPower > nOrgFightPower  then
		FightPower:SendInfoByChange(pPlayer, nCurFightPower - nOrgFightPower);
	end
end