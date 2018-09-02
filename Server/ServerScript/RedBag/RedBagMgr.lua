--[[
{	--家族红包
	nVersion = 1,
	{
		szId = "sdfjjagkj233",
		nVersion = 1,
		nEventId = 1,
		tbOwner = {
			nId = 111,
		},
		nBornTime = 123456,
		nSendTime = 123456,	--未发送为0
		nGold = 300,
		nMaxReceiver = 10,
		tbReceivers = {
			{
				123456, --nId 
				100,	--nGold 
			},
		},
	},
}
]]
RedBagMgr._EmptyCache = RedBagMgr._EmptyCache or {}	--不存盘的红包数据，只保存已领完的

RedBagMgr.nMaxGlobalEmptyCacheCount = 20
RedBagMgr._GlobalEmptyCache = RedBagMgr._GlobalEmptyCache or {}	--不存盘的全服红包数据，只保存已领完的，最多保存nMaxGlobalEmptyCacheCount份

function RedBagMgr:_GetKey(nKinId)
	return string.format("kinrb%d", nKinId)
end

function RedBagMgr:GetByKinId(nKinId)
	local szKey = self:_GetKey(nKinId)
	ScriptData:AddDef(szKey)
	local tbRedBags = ScriptData:GetValue(szKey)
	if not next(tbRedBags) then
		tbRedBags.nVersion = 1
	end
	return tbRedBags
end

function RedBagMgr:SaveByKinId(nKinId, tbValue)
	local szKey = self:_GetKey(nKinId)
	ScriptData:AddDef(szKey)
	ScriptData:SaveValue(szKey, tbValue)
	ScriptData:AddModifyFlag(szKey)
end

function RedBagMgr:ClearByKinId(nKinId)
	self:SaveByKinId(nKinId, {})

	RedBagMgr._EmptyCache[nKinId] = nil
end

function RedBagMgr:GetAll(nKinId)
	local tbRedBags = self:GetByKinId(nKinId)
	local tbRet = Lib:CopyTB(tbRedBags)

	local tbSlots = ScriptData:GrpGetAllSlots("GlobalRB")
	for _, tbSlot in ipairs(tbSlots) do
		for _, tbRedBag in pairs(tbSlot) do
			table.insert(tbRet, tbRedBag)
		end
	end

	local tbCached = self._EmptyCache[nKinId] or {}
	for _, tb in pairs(tbCached) do
		table.insert(tbRet, tb)
	end

	for _, tb in ipairs(self._GlobalEmptyCache) do
		table.insert(tbRet, tb)
	end

	local nNow = GetTime()
	for i=#tbRet,1,-1 do
		local tbRedBag = tbRet[i]
		local nSendTime = tbRedBag.nSendTime
		if nSendTime>0 and nNow-nSendTime>=Kin.Def.nRedbagExpireTime then
			table.remove(tbRet, i)
		end
	end

	return tbRet
end

function RedBagMgr:_GetGlobalById(szId)
	local tbRet = Kin:_RedBagGlobalGetById(szId)
	if not tbRet then
		for _, tbRedBag in ipairs(self._GlobalEmptyCache) do
			if szId==tbRedBag.szId then
				tbRet = tbRedBag
				break
			end
		end
	end
	return tbRet
end

function RedBagMgr:_GetById(nKinId, szId)
	local tbRet = nil
	local tbRedBags = self:GetByKinId(nKinId)
	for _,tbRedBag in ipairs(tbRedBags) do
		if szId==tbRedBag.szId then
			tbRet = tbRedBag
			break
		end
	end
	if not tbRet then
		if self._EmptyCache[nKinId] then
			tbRet = self._EmptyCache[nKinId][szId]
		end
	end
	return tbRet
end

function RedBagMgr:GetById(nKinId, szId)
	local tbRet = nil
	local bGlobal = Kin:RedBagIsIdGlobal(szId)
	if bGlobal then
		tbRet = self:_GetGlobalById(szId)
	else
		if nKinId and nKinId>0 then
			tbRet = self:_GetById(nKinId, szId)
		end
	end
	return tbRet
end

function RedBagMgr:Add(nKinId, tbRedBag)
	local tbRedBags = self:GetByKinId(nKinId)
	table.insert(tbRedBags, tbRedBag)

	local nCount = #tbRedBags
	if nCount>Kin.Def.nRedBagMaxCount then
		self:_AutoRemove(nKinId, nCount-Kin.Def.nRedBagMaxCount)
	end
	self:IncVersion(nKinId)
end

function RedBagMgr:GlobalAdd(tbRedBag)
	local szMainKey = "GlobalRB"
	local tbSlot, nSlot = ScriptData:GrpGetFreeSlot(szMainKey)
	tbSlot[tbRedBag.szId] = tbRedBag
	ScriptData:GrpSaveSlot(szMainKey, nSlot)
	self:GlobalIncVersion()
end

function RedBagMgr:Remove(nKinId, nIdx)
	local tbRedBags = self:GetByKinId(nKinId)
	local tbRedBag = tbRedBags[nIdx]
	self:_GiveBack(tbRedBag)
	table.remove(tbRedBags, nIdx)
	self:IncVersion(nKinId)
end

function RedBagMgr:GlobalMoveToCache(szId)
	local _, nSlot, tbSlot = Kin:_RedBagGlobalGetById(szId)
	if not tbSlot then
		return
	end

	table.insert(self._GlobalEmptyCache, 1, tbSlot[szId])
	while #self._GlobalEmptyCache>self.nMaxGlobalEmptyCacheCount do
		table.remove(self._GlobalEmptyCache)
	end
	tbSlot[szId] = nil
	Kin:_RedBagGlobalSave(nSlot)
	self:GlobalIncVersion()
end

function RedBagMgr:MoveToCache(nKinId, szId)
	local tbRedBags = self:GetByKinId(nKinId)
	for nIdx, tbRedBag in ipairs(tbRedBags) do
		if tbRedBag.szId==szId then
			self._EmptyCache[nKinId] = self._EmptyCache[nKinId] or {}
			self._EmptyCache[nKinId][szId] = tbRedBag
			table.remove(tbRedBags, nIdx)

			self:IncVersion(nKinId)	
			break
		end
	end
end

function RedBagMgr:GlobalIncVersion()
	self.nGlobalVersion = (self.nGlobalVersion or 0)+1
end

function RedBagMgr:IncVersion(nKinId)
	local tbRedBags = self:GetByKinId(nKinId)
	tbRedBags.nVersion = (tbRedBags.nVersion or 0)+1

	self:SaveByKinId(nKinId, tbRedBags)
end

-- 红包达到上限，自动删除
-- 优先删除已领完的，其次删除获得时间最早的
function RedBagMgr:_AutoRemove(nKinId, nCount)
	local tbRedBags = self:GetByKinId(nKinId)
	local tbSortedIdx = {}
	for nIdx in ipairs(tbRedBags) do
		table.insert(tbSortedIdx, nIdx)
	end

	table.sort(tbSortedIdx, function(nIdxA, nIdxB)
		local tbRedBagA = tbRedBags[nIdxA]
		local tbRedBagB = tbRedBags[nIdxB]

		local bEmptyA = #tbRedBagA.tbReceivers>=tbRedBagA.nMaxReceiver
		local bEmptyB = #tbRedBagB.tbReceivers>=tbRedBagB.nMaxReceiver

		if bEmptyA==bEmptyB then
			return tbRedBagA.nBornTime<tbRedBagB.nBornTime or (tbRedBagA.nBornTime==tbRedBagB.nBornTime and nIdxA<nIdxB)
		else
			return bEmptyA
		end
	end)

	local tbIdxToRemove = {}
	for i=1,nCount do
		local nIdx = tbSortedIdx[i]
		if not nIdx then break end
		table.insert(tbIdxToRemove, nIdx)
	end
	table.sort(tbIdxToRemove, function(nIdxA, nIdxB)
		return nIdxA>nIdxB
	end)

	for _,nIdx in ipairs(tbIdxToRemove) do
		self:Remove(nKinId, nIdx)
	end
end

function RedBagMgr:_GiveBack(tbRedBag)
	local nEventId = tbRedBag.nEventId
	if not nEventId or nEventId<=0 then
		return
	end

	local tbSetting = Kin.tbRedBagSettings[nEventId]
	local nTotalGold = tbRedBag.nGold
	local nAddGold = nTotalGold-tbSetting.nBaseGold
	if nAddGold<=0 then
		return
	end

	local nClaimed = 0
	for _,tb in ipairs(tbRedBag.tbReceivers) do
		local tbPack = self:PackReceiver(tb)
		nClaimed = nClaimed+tbPack.nGold
	end
	local nLeftGold = nTotalGold-nClaimed
	if nLeftGold<=0 then
		return
	end
	local nGiveBackGold = math.min(nLeftGold, nAddGold)
	Mail:SendSystemMail({
		To = tbRedBag.tbOwner.nId,
		Title = "幫派紅包",
		Text = string.format("您發放的紅包超過24小時未被領完，自動退回%d元寶", nGiveBackGold),
		From = "系統",
		tbAttach = {
			{"Gold", nGiveBackGold},
		},
	})
end

function RedBagMgr:PackReceiver(tb)
	return {
		nId = tb[1],
		nGold = tb[2],
	}
end

function RedBagMgr:UnpackReceiver(tb)
	return {
		tb.nId,
		tb.nGold,
	}
end