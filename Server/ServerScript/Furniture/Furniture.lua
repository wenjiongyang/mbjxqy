
function Furniture:GetFurnitureData(pPlayer)
	local tbData = pPlayer.GetScriptTable("Furniture");
	local tbFurnitureData = tbData.tbFurnitureData;
	if not tbFurnitureData then
		tbFurnitureData =
		{
			tbFurnitures = {},
		};

		tbData.tbFurnitureData = tbFurnitureData;
	end
	return tbFurnitureData;
end

function Furniture:GetFurnitures(pPlayer)
	local tbData = self:GetFurnitureData(pPlayer);
	return tbData.tbFurnitures;
end

function Furniture:GetFurniture(pPlayer, nTemplateId)
	local tbFurnitures = self:GetFurnitures(pPlayer);
	return tbFurnitures[nTemplateId];
end

function Furniture:Add(pPlayer, nTemplateId)
	local tbFurnitures = self:GetFurnitures(pPlayer);
	local tbFurniture = tbFurnitures[nTemplateId];
	if not tbFurniture then
		tbFurniture = { nCount = 0 };
		tbFurnitures[nTemplateId] = tbFurniture;
	end

	tbFurniture.nCount = tbFurniture.nCount + 1;

	self:DoSyncCmd(pPlayer, "House:OnSyncSingleFurniture", nTemplateId, tbFurniture.nCount);
	Log("[Furniture] Add ", pPlayer.dwID, pPlayer.szAccount, pPlayer.szName, nTemplateId, tbFurniture.nCount);
end

function Furniture:Remove(pPlayer, nTemplateId, nCount)
	nCount = nCount or 1;
	nCount = math.floor(nCount);
	if nCount <= 0 then
		return false;
	end

	local tbFurnitures = self:GetFurnitures(pPlayer);
	local tbFurniture = tbFurnitures[nTemplateId];
	if not tbFurniture then
		return false;
	end

	if nCount > tbFurniture.nCount then
		return false;
	end

	tbFurniture.nCount = tbFurniture.nCount - nCount;
	if tbFurniture.nCount <= 0 then
		tbFurnitures[nTemplateId] = nil;
	end

	self:DoSyncCmd(pPlayer, "House:OnSyncSingleFurniture", nTemplateId, tbFurniture.nCount);

	Log("[Furniture] Remove ", pPlayer.dwID, pPlayer.szAccount, pPlayer.szName, nTemplateId, nCount, tbFurniture.nCount);
	
	return true;
end

function Furniture:DoSyncCmd(pPlayer, cmd, ...)
	if House:IsInOwnHouse(pPlayer) then
		pPlayer.CallClientScript(cmd, ...);
	end
end

-- 只需要家园地图内，和进家园地图的时候同步就好了，其它时候不需要同步数据
function Furniture:DoSyncFurniture(pPlayer)
	if House:IsInNormalHouse(pPlayer) then
		local tbMapFurniture = nil;
		if House.tbMapFurnitureInfo then
			tbMapFurniture = House.tbMapFurnitureInfo[pPlayer.nMapId];
		end
		pPlayer.CallClientScript("House:OnSyncMapFurniture", tbMapFurniture);
	end

	if House:IsInOwnHouse(pPlayer) then
		local tbFurnitures = self:GetFurnitures(pPlayer);
		local tbSyncInfo = {};
		for nTemplateId, tbInfo in pairs(tbFurnitures) do
			if tbInfo.nCount > 0 then
				tbSyncInfo[nTemplateId] = tbInfo.nCount;
			end
		end
		pPlayer.CallClientScript("House:OnSyncFurniture", tbSyncInfo);
	end
end

function Furniture:RestortFurniturePosOrPackup(pPlayer, nId, nX, nY, nRotation, nSX, nSY)
	local bRet = Decoration:ChangeDecorationPos(nId, nX, nY, nRotation, nSX, nSY);
	if not bRet then
		if House:IsInOwnHouse(pPlayer) then
			self:PackupFurniture(pPlayer, nId);
		else
			local nLandlordId = pPlayer.GetUserValue(House.USERGROUP_LANDLORD, House.USERKEY_LANDLORD);
			Log("[Furniture] RestortFurniturePosOrPackup Fail !!", pPlayer.dwID, pPlayer.szName, pPlayer.szAccount, nLandlordId, nId, nX, nY, nRotation, nSX, nSY);
		end
	end
end

function Furniture:ChangeFurniturePos(pPlayer, nId, nX, nY, nRotation, nSX, nSY)
	local bRet, szMsg, tbFurniture = self:CheckCanChangePos(pPlayer, nId, nX, nY, nRotation);
	if not bRet then
		if tbFurniture then
			Furniture:RestortFurniturePosOrPackup(pPlayer, nId, tbFurniture.nX, tbFurniture.nY, tbFurniture.nRotation, tbFurniture.nSX, tbFurniture.nSY);
		end
		pPlayer.CenterMsg(szMsg);
		return;
	end

	local _, nFurnitureTemplateId = House:GetFurnitureInfo(tbFurniture.nTemplateId);
	nSX, nSY = House:FormatScale(nFurnitureTemplateId, nSX, nSY);

	bRet = Decoration:ChangeDecorationPos(nId, nX, nY, nRotation, nSX, nSY);
	if not bRet then
		Furniture:RestortFurniturePosOrPackup(pPlayer, tbFurniture.nX, tbFurniture.nY, tbFurniture.nRotation, tbFurniture.nSX, tbFurniture.nSY);
		return;
	end

	local bIsInLivingRoom, nOwnerId = House:IsInLivingRoom(pPlayer);
	if not bIsInLivingRoom then
		nOwnerId = pPlayer.dwID;
	end
	local tbOrgInfo = {nTemplateId = tbFurniture.nTemplateId, nX = tbFurniture.nX, nY = tbFurniture.nY, nRotation = tbFurniture.nRotation, nSX = nSX, nSY = nSY};
	bRet = House:ChangeFurniturePos(nOwnerId, tbOrgInfo, {nX = nX, nY = nY, nRotation = nRotation, nSX = nSX, nSY = nSY});
	if not bRet then
		Furniture:RestortFurniturePosOrPackup(pPlayer, nId, tbFurniture.nX, tbFurniture.nY, tbFurniture.nRotation);
		Log("[Furniture] ChangeFurniturePos fail !!", pPlayer.dwID, pPlayer.szAccount, pPlayer.szName, pPlayer.nMapId, pPlayer.nMapTemplateId, tbFurniture.nTemplateId, nX, nY, nRotation);
		return;
	end

	tbFurniture.nX = nX;
	tbFurniture.nY = nY;
	tbFurniture.nSX = nSX;
	tbFurniture.nSY = nSY;
	tbFurniture.nRotation = nRotation;
end

function Furniture:PackupFurniture(pPlayer, nId)
	local dwPlayerId = pPlayer.dwID;
	local bRet, result = Furniture:RemoveMapFurniture(dwPlayerId, nId);
	if not bRet then
		if result then
			pPlayer.CenterMsg(result);
			return;
		end
	end

	local tbFurniture = result;
	self:Add(pPlayer, tbFurniture.nTemplateId);

	Log("[Furniture] packup furniture finished: ", dwPlayerId, tbFurniture.nTemplateId, tbFurniture.nX, tbFurniture.nY);

	return true;
end

function Furniture:RemoveMapFurniture(dwPlayerId, nId)
	local nMapId = House:GetHouseMap(dwPlayerId);
	if not nMapId then
		return false;
	end

	local tbFurniture = (House.tbMapFurnitureInfo[nMapId] or {})[nId];
	if not tbFurniture then
		return false;
	end

	local bRemove, szMsg = House:TryRemoveFurniture(dwPlayerId, tbFurniture.nTemplateId, tbFurniture.nX, tbFurniture.nY);
	if not bRemove then
		Decoration:SyncDecoration(nId);
		return false, szMsg;
	end

	House.tbMapFurnitureInfo[nMapId][nId] = nil;
	Decoration:DeleteDecoration(nId);

	KPlayer.MapBoardcastScriptByFuncName(nMapId, "House:OnRemoveMapFurniture", nId);

	Log("[Furniture] remove map furniture", dwPlayerId, tbFurniture.nTemplateId, tbFurniture.nX, tbFurniture.nY);

	return true, tbFurniture;
end

function Furniture:RemoveMapFurnitureTemplate(dwPlayerId, nTemplateId, nCount)
	local nRemoveCount = 0;
	local nHouseMapId = House:GetHouseMap(dwPlayerId);
	if nHouseMapId and House.tbMapFurnitureInfo[nHouseMapId] then
		for nId, tbFurniture in pairs(House.tbMapFurnitureInfo[nHouseMapId]) do
			if tbFurniture.nTemplateId == nTemplateId then
				if self:RemoveMapFurniture(dwPlayerId, nId) then
					nRemoveCount = nRemoveCount + 1;
					if nRemoveCount >= nCount then
						break;
					end
				end
			end
		end
	else
		nRemoveCount = House:RemoveFurnitureTemplate(dwPlayerId, nTemplateId, nCount);
	end

	return nRemoveCount;
end

function Furniture:CheckCanChangePos(pPlayer, nId, nX, nY, nRotation)
	local tbFurniture = (House.tbMapFurnitureInfo[pPlayer.nMapId] or {})[nId];
	if not tbFurniture then
		return false, "不存在的傢俱！";
	end

	if not House:HasDecorationAccess(pPlayer) then
		return false, "只能裝扮自己的家園！", tbFurniture;
	end

	local bRet, szMsg = House:CheckCanPutFurnitureCommon(pPlayer.nMapTemplateId, nX, nY, nRotation, tbFurniture.nTemplateId);
	if not bRet then
		return false, szMsg, tbFurniture;
	end

	local bRet, szMsg = Decoration:CheckCanChangePos(nId, nX, nY, nRotation);
	if not bRet then
		return false, szMsg, tbFurniture;
	end

	return true, "", tbFurniture;
end

function Furniture:CheckCanPutFurniture(pPlayer, nX, nY, nRotation, nTemplateId)
	local bRet, szMsg = House:CheckCanPutFurnitureCommon(pPlayer.nMapTemplateId, nX, nY, nRotation, nTemplateId);
	if not bRet then
		return bRet, szMsg;
	end

	if not House:IsInOwnHouse(pPlayer) then
		return false, "只能裝扮自己的家園！";
	end

	local tbFurniture = House:GetFurnitureInfo(nTemplateId);
	bRet, szMsg = Decoration:CheckCanUseDecoration(pPlayer.nMapId, nX, nY, nRotation, tbFurniture.nDecorationId);
	if not bRet then
		return bRet, szMsg;
	end

	if tbFurniture.nType == Furniture.TYPE_LAND then
		local tbLand = HousePlant:GetLand(pPlayer.dwID);
		if tbLand then
			return false, "你已經有苗圃了哦";
		end
	end

	return true;
end

function Furniture:PutFurniture(pPlayer, nX, nY, nRotation, nTemplateId)
	return self:PutFurnitureByTB(pPlayer, {nTemplateId = nTemplateId, nX = nX, nY = nY, nRotation = nRotation});
end

function Furniture:PutFurnitureByTB(pPlayer, tbSetting)
	local nTemplateId, nX, nY, nSX, nSY, nRotation = tbSetting.nTemplateId, tbSetting.nX, tbSetting.nY, tbSetting.nSX, tbSetting.nSY, tbSetting.nRotation;
	local bRet, szMsg = self:CheckCanPutFurniture(pPlayer, nX, nY, nRotation, nTemplateId);
	if not bRet then
		pPlayer.CenterMsg(szMsg);
		return;
	end

	local bRet = Furniture:Remove(pPlayer, nTemplateId);
	if not bRet then
		Log("[Furniture] PutFurniture fail !! Furniture:Remove return false !!", pPlayer.dwID, pPlayer.szAccount, pPlayer.szName, nX, nY, nRotation, nTemplateId)
		return;
	end

	local bRet, szMsg = Furniture:AddMapFurnitureByTB(pPlayer, tbSetting);
	if not bRet then
		pPlayer.CenterMsg(szMsg);
		return;
	end

	Task:OnTaskExtInfo(pPlayer, Task.ExtInfo_UseFurniture);

	Log("[Furniture] PutFurniture", pPlayer.dwID, pPlayer.szAccount, pPlayer.szName, nX, nY, nRotation, nTemplateId)
end

function Furniture:AddMapFurniture(pPlayer, nTemplateId, nX, nY, nRotation)
	return Furniture:AddMapFurnitureByTB(pPlayer, {nTemplateId = nTemplateId, nX = nX, nY = nY, nRotation = nRotation});
end

function Furniture:AddMapFurnitureByTB(pPlayer, tbSetting)
	local nTemplateId, nX, nY, nSX, nSY, nRotation = tbSetting.nTemplateId, tbSetting.nX, tbSetting.nY, tbSetting.nSX, tbSetting.nSY, tbSetting.nRotation;
	local bRet, szMsg = House:TryAddFurniture(pPlayer, nTemplateId, nX, nY, nRotation, nSX, nSY);
	if not bRet then
		Log("[ERROR][Furniture] AddMapFurnitureByTB failed !! add furniture error", pPlayer.dwID, pPlayer.szAccount, pPlayer.szName, nX, nY, nRotation, nTemplateId);
		return false, szMsg;
	end

	nSX, nSY = House:FormatScale(nTemplateId, nSX, nSY);


	local nMapId = pPlayer.nMapId;
	local tbFurniture = House:GetFurnitureInfo(nTemplateId);
	tbSetting.nTemplateId = tbFurniture.nDecorationId;

	local bRet, szMsg, nDId = Decoration:NewDecorationByTB(nMapId, tbSetting);
	if not bRet then
		Log("[ERROR][Furniture] AddMapFurnitureByTB failed !! create decoration error", pPlayer.dwID, pPlayer.szAccount, pPlayer.szName, nX, nY, nRotation, nTemplateId);
		return false, szMsg;
	end

	local tbMapFurniture = {nX = nX, nY = nY, nRotation = nRotation, nTemplateId = nTemplateId, nSX = nSX, nSY = nSY};
	House.tbMapFurnitureInfo[nMapId][nDId] = tbMapFurniture;

	if House:IsInNormalHouse(pPlayer) then
		KPlayer.MapBoardcastScriptByFuncName(nMapId, "House:OnAddMapFurniture", nDId, tbMapFurniture);
	end

	return true;
end

function Furniture:MakeFurniture(pPlayer, nFurnitureItemId)
	local bRet, szMsg, tbFurniture, tbCost, tbMakeInfo = House:CheckCanMakeFurniture(pPlayer, nFurnitureItemId);
	if not bRet then
		pPlayer.CenterMsg(szMsg);
		pPlayer.CallClientScript("House:OnSyncMakeFurniture", nFurnitureItemId, false);
		return;
	end

	local tbConsummeInfo = {};
	for _, tbInfo in pairs(tbCost) do
		local nAwardType = Player.AwardType[tbInfo[1]];
		if nAwardType == Player.award_type_item then
			local nCostCount = pPlayer.ConsumeItemInBag(tbInfo[2], tbInfo[3], Env.LogWay_FurnitureMake);
			table.insert(tbConsummeInfo, {tbInfo[1], tbInfo[2], nCostCount});

			if nCostCount ~= tbInfo[3] then
				Log("[Furniture] MakeFurniture ConsumeItemInBag Fail !!", pPlayer.dwID, pPlayer.szAccount, pPlayer.szName, nFurnitureItemId);
				Lib:LogTB(tbConsummeInfo);
				pPlayer.CenterMsg("扣除材料失敗！！", true);
				pPlayer.CallClientScript("House:OnSyncMakeFurniture", nFurnitureItemId, false);
				return;
			end
		end

		if nAwardType == Player.award_type_money then
			if tbInfo[1] == "Gold" then
				Log("[Furniture] MakeFurniture ConsumeItemInBag Fail !!", pPlayer.dwID, pPlayer.szAccount, pPlayer.szName, nFurnitureItemId);
				Lib:LogTB(tbConsummeInfo);
				pPlayer.CenterMsg("消耗材料失敗！！", true);
				pPlayer.CallClientScript("House:OnSyncMakeFurniture", nFurnitureItemId, false);
				return;
			end

			local bOK = pPlayer.CostMoney(tbInfo[1], tbInfo[2], Env.LogWay_FurnitureMake);
			if not bOK then
				Log("[Furniture] MakeFurniture ConsumeItemInBag Fail !!", pPlayer.dwID, pPlayer.szAccount, pPlayer.szName, nFurnitureItemId);
				Lib:LogTB(tbConsummeInfo);
				pPlayer.CenterMsg("消耗材料失敗！！", true);
				pPlayer.CallClientScript("House:OnSyncMakeFurniture", nFurnitureItemId, false);
				return;
			end

			table.insert(tbConsummeInfo, {tbInfo[1], tbInfo[2]});
		end
	end

	local szItemName = "";
	local tbBaseInfo = KItem.GetItemBaseProp(nFurnitureItemId);
	if tbBaseInfo then
		szItemName = string.format("<%s>", tbBaseInfo.szName);
	end

	if tbMakeInfo.nKinMsg > 0 and pPlayer.dwKinId > 0 then
		local szKinMsg = MsgInfoCtrl:GetMsg(tbMakeInfo.nKinMsg, pPlayer.szName, szItemName, tbFurniture.nLevel);
		ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.Kin, szKinMsg, pPlayer.dwKinId, {nLinkType = ChatMgr.LinkType.Item, nTemplateId = nFurnitureItemId, nFaction = pPlayer.nFaction});
	end

	if tbMakeInfo.nWorldMsg > 0 then
		local szWorldMsg = MsgInfoCtrl:GetMsg(tbMakeInfo.nWorldMsg, pPlayer.szName, szItemName, tbFurniture.nLevel);
		ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.System, szWorldMsg, nil, {nLinkType = ChatMgr.LinkType.Item, nTemplateId = nFurnitureItemId, nFaction = pPlayer.nFaction});
	end

	self:Add(pPlayer, nFurnitureItemId);
	pPlayer.TLog("FurnitureFlow", nFurnitureItemId, 1);
	pPlayer.CallClientScript("House:OnSyncMakeFurniture", nFurnitureItemId, true);
	Log("[Furniture] FurnitureMake Finish !", pPlayer.dwID, pPlayer.szAccount, pPlayer.szName, nFurnitureItemId);
end

function Furniture:OnLogin()
	self:DoSyncFurniture(me);
end

function Furniture:OnReConnect()
	self:DoSyncFurniture(me);
end

function Furniture:OnEnterMap(nMapId)
	self:DoSyncFurniture(me);
end

function Furniture:SellFurniture(pPlayer, nTemplateId, nCount)
	if not Env:CheckSystemSwitch(pPlayer, Env.SW_SellFurniture) then
		pPlayer.CenterMsg("傢俱出售暫時關閉");
		return;
	end

	local nCount = math.floor(nCount);
	if nCount <= 0 then
		pPlayer.CenterMsg("傢俱數量不正確！");
		return;
	end

	if Furniture:IsSpecialFurniture(nTemplateId) then
		pPlayer.CenterMsg("此傢俱不支持售賣");
		return;
	end

	local tbFurnitures = self:GetFurnitures(pPlayer);
	local tbFurniture = tbFurnitures[nTemplateId];
	if not tbFurniture then
		pPlayer.CenterMsg("你身上沒有此傢俱");
		return;
	end

	if tbFurniture.nCount < nCount then
		pPlayer.CenterMsg("傢俱數量不足");
		return;
	end

	if not Furniture:Remove(pPlayer, nTemplateId, nCount) then
		pPlayer.CenterMsg("傢俱出售失敗");
		return;
	end

	local nValue = math.floor(KItem.GetBaseValue(nTemplateId) / 100 * House.fFurnitureSellRatio);
	local tbAward = {{"Contrib", nValue * nCount }};
	pPlayer.SendAward(tbAward, nil, nil, Env.LogWay_SellFurniture);
	pPlayer.CenterMsg("出售成功");
end

-- 自动收起和删除
--[[
tbTemplate =
{
	[nTemplateId] = nCount,
}
]]
function Furniture:Delete(pPlayer, tbTemplate, nLogway)
	assert(nLogway, "[ERROR][furniture] log way not exist");

	local tbRemain = {};
	for nTemplateId, nCount in pairs(tbTemplate) do
		local nCountInBag = pPlayer.GetItemCountInBags(nTemplateId);
		local nConsumeCount = math.min(nCount, nCountInBag);
		if nConsumeCount > 0 then
			nCount = nCount - nConsumeCount;
			pPlayer.ConsumeItemInBag(nTemplateId, nConsumeCount, nLogway);

			Log("[Furniture] delete furniture in bag: ", nTemplateId, nConsumeCount);
		end

		if nCount > 0 then
			local tbFurniture = self:GetFurniture(pPlayer, nTemplateId);
			if tbFurniture then
				local nRemoveCount = math.min(tbFurniture.nCount, nCount);
				local bRet = self:Remove(pPlayer, nTemplateId, nRemoveCount);
				if bRet then
					nCount = nCount - nRemoveCount;
					Log("[Furniture] delete furniture in furniture bag: ", nTemplateId, nRemoveCount);
				end
			end
		end

		if nCount > 0 then
			tbRemain[nTemplateId] = nCount;
		end
	end

	for nTemplateId, nCount in pairs(tbRemain) do
		local nRemoveCount = self:RemoveMapFurnitureTemplate(pPlayer.dwID, nTemplateId, nCount);
		if nRemoveCount > 0 then
			Log("[Furniture] delete furniture in house: ", nTemplateId, nRemoveCount);
		end
	end

	Log("[Furniture] delete furniture finished, log way: ", nLogway);
end
