Gift.GiftManager = Gift.GiftManager or {}
local GiftManager = Gift.GiftManager

--[[
	local tbGift = pPlayer.GetScriptTable("Gift");
	tbGift.nUpdateDay = nDay 								-- 上一次重置的天数(遍历tbGift时要注意nUpdateDay的存在)
	tbGift[nAcceptId] = {}
	tbGift[nAcceptId][nGiftType] = nRemain					-- 赠送过礼物的玩家剩余次数
	-- 不限次数的礼物类型不会存盘&每次重置会把该礼物次数置nil,为了存储更小的数据
]]

-- 扣除赠送次数 (pPlayer赠送给nAcceptId玩家nCount次nGiftType类型的礼物)
function GiftManager:CheckGiftTimes(pPlayer,nAcceptId,nCount,nGiftType,nItemId)

	nAcceptId = tonumber(nAcceptId);
	if not nAcceptId then
		return false,"請選擇要贈送的好友";
	end

	if not nCount or nCount < 1 then
		return false,"請選擇要贈送的數量";
	end

	if not Gift.AllGift[nGiftType] then
		return false,"請選擇要贈送的物品"
	end

	local nTimes
	if Gift.SpecialGift[nGiftType] then
		nTimes = Gift:GetSpecialTimes(nGiftType,nItemId)
	else
		nTimes = Gift.SendTimes[nGiftType]
	end

	if not nTimes then
		Log("[GiftManager] not find times!",pPlayer.dwID,pPlayer.szName,nAcceptId,nCount,nGiftType,nItemId)
		return false,"資料異常,請聯繫客服"
	end

	if nTimes == Gift.Times.Forever then
		return true,nil,Gift.Times.Forever
	end

	local tbGift = pPlayer.GetScriptTable("Gift");
	local nToday = Lib:GetLocalDay();
	if not tbGift.nUpdateDay or nToday ~= tbGift.nUpdateDay then
		GiftManager:SynGiftData(pPlayer)
	end
	local nRemain,key
	tbGift[nAcceptId] = tbGift[nAcceptId] or {}; 
	if Gift.SpecialGift[nGiftType] then
		if nGiftType == Gift.GiftType.MailGift then
			local tbInfo = Gift:GetMailGiftItemInfo(nItemId)
			local szKey = tbInfo and tbInfo.szKey
			if not szKey then
				Log("[GiftManager] not find szKey!",pPlayer.dwID,pPlayer.szName,nAcceptId,nCount,nGiftType,nItemId)
				return false,"資料異常,請聯繫客服"
			end
			tbGift[nAcceptId][szKey] = tbGift[nAcceptId][szKey] or nTimes;
			nRemain = tbGift[nAcceptId][szKey]
			key = szKey
		end
	else
		tbGift[nAcceptId][nGiftType] = tbGift[nAcceptId][nGiftType] or nTimes;
		nRemain = tbGift[nAcceptId][nGiftType];
		key = nGiftType
	end
	

	if not nRemain or not key then
		Log("[GiftManager] not find nRemain!",pPlayer.dwID,pPlayer.szName,nAcceptId,nCount,nGiftType,nItemId)
		return false,"資料異常,請聯繫客服"
	end

	if nRemain < 1 or nCount > nRemain then
		return false,"剩餘贈送次數不足";
	end

	return true,key,nRemain;
end

function GiftManager:ReduceGiftTimes(pPlayer,nAcceptId,key,nRemain,nCount)
	local tbGift = pPlayer.GetScriptTable("Gift");
	tbGift[nAcceptId][key] = nRemain - nCount;
	Log("[GiftManager] ReduceGiftTimes ",pPlayer.dwID,pPlayer.szName,nAcceptId,key,nRemain,nCount)
end

function GiftManager:CheckItemSend(pPlayer,nCount,nGiftType,nItemId)
	if not nCount or nCount < 1 then
		return false,"請選擇要贈送的數量";
	end

	local nTimes = Gift:GetItemSendTimes(nGiftType,nItemId)
	if not nTimes then
		Log("[GiftManager] not find times!",pPlayer.dwID,pPlayer.szName,nCount,nGiftType,nItemId)
		return false,"資料異常,請聯繫客服"
	end

	if nTimes == Gift.Times.Forever then
		return true,nil,Gift.Times.Forever
	end

	local tbGiftItem = pPlayer.GetScriptTable("GiftItem");
	tbGiftItem.tbSendItem = tbGiftItem.tbSendItem or {}
	
	self:TryResetGiftItem(pPlayer)

	local tbInfo = Gift:GetMailGiftItemInfo(nItemId)
	local szKey = tbInfo and tbInfo.szKey
	if not szKey then
		Log("[GiftManager] not find szKey!",pPlayer.dwID,pPlayer.szName,nCount,nGiftType,nItemId)
		return false,"資料異常,請聯繫客服"
	end

	tbGiftItem.tbSendItem[szKey] = tbGiftItem.tbSendItem[szKey] or nTimes;
	local nRemain = tbGiftItem.tbSendItem[szKey]
	if nRemain < 1 or nCount > nRemain then
		return false,"剩餘贈送次數不足";
	end

	return true,szKey,nRemain;
end

function GiftManager:ReduceItemSend(pPlayer,szKey,nRemain,nCount)
	local tbGiftItem = pPlayer.GetScriptTable("GiftItem");
	tbGiftItem.tbSendItem[szKey] = nRemain - nCount
	Log("[GiftManager] ReduceItemSend ",pPlayer.dwID,pPlayer.szName,szKey,nRemain,nCount)
end

function GiftManager:TryResetGiftItem(pPlayer)
	local tbGiftItem = pPlayer.GetScriptTable("GiftItem");

	tbGiftItem.tbSendItem = tbGiftItem.tbSendItem or {}
	local nToday = Lib:GetLocalDay();
	if not tbGiftItem.nSendItemUpdateDay or nToday ~= tbGiftItem.nSendItemUpdateDay then
		for szKey,nRemain in pairs(tbGiftItem.tbSendItem) do
			local tbInfo = Gift:GetMailGiftInfo(szKey)
			if tbInfo and tbInfo.bReset and tbInfo.nTimesType == Gift.MailType.Times2Item then
				tbGiftItem.tbSendItem[szKey] = tbInfo.nItemSend
			end
		end
		tbGiftItem.nSendItemUpdateDay = nToday;
	end

	tbGiftItem.tbAcceptItem = tbGiftItem.tbAcceptItem or {}
	local nToday = Lib:GetLocalDay();
	if not tbGiftItem.nAcceptItemUpdateDay or nToday ~= tbGiftItem.nAcceptItemUpdateDay then
		for szKey,nRemain in pairs(tbGiftItem.tbAcceptItem) do
			local tbInfo = Gift:GetMailGiftInfo(szKey)
			if tbInfo and tbInfo.bReset and tbInfo.nTimesType == Gift.MailType.Times2Item then
				tbGiftItem.tbAcceptItem[szKey] = tbInfo.nItemAccept
			end
		end
		tbGiftItem.nAcceptItemUpdateDay = nToday;
	end
end

function GiftManager:CheckItemAccept(pPlayer,nCount,nGiftType,nItemId)
	if not nCount or nCount < 1 then
		return false,"請選擇要贈送的數量";
	end

	local nTimes = Gift:GetItemAcceptTimes(nGiftType,nItemId)
	if not nTimes then
		Log("[GiftManager] not find times!",pPlayer.dwID,pPlayer.szName,nCount,nGiftType,nItemId)
		return false,"資料異常,請聯繫客服"
	end

	if nTimes == Gift.Times.Forever then
		return true,nil,Gift.Times.Forever
	end

	local tbGiftItem = pPlayer.GetScriptTable("GiftItem");
	tbGiftItem.tbAcceptItem = tbGiftItem.tbAcceptItem or {}
	
	self:TryResetGiftItem(pPlayer)

	local tbInfo = Gift:GetMailGiftItemInfo(nItemId)
	local szKey = tbInfo and tbInfo.szKey
	if not szKey then
		Log("[GiftManager] not find szKey!",pPlayer.dwID,pPlayer.szName,nCount,nGiftType,nItemId)
		return false,"資料異常,請聯繫客服"
	end

	tbGiftItem.tbAcceptItem[szKey] = tbGiftItem.tbAcceptItem[szKey] or nTimes;
	local nRemain = tbGiftItem.tbAcceptItem[szKey]
	if nRemain < 1 or nCount > nRemain then
		return false,"對方接受贈送次數不足";
	end

	return true,szKey,nRemain;
end

function GiftManager:ReduceItemAccept(pPlayer,szKey,nRemain,nCount)
	local tbGiftItem = pPlayer.GetScriptTable("GiftItem");
	tbGiftItem.tbAcceptItem[szKey] = nRemain - nCount
	Log("[GiftManager] ReduceItemAccept ",pPlayer.dwID,pPlayer.szName,szKey,nRemain,nCount)
end

-- 重置(打开界面的时候和赠送的时候都应该检查)
function GiftManager:CheckReset(pPlayer,nGiftType)
	local tbGift = pPlayer.GetScriptTable("Gift");
	local nToday = Lib:GetLocalDay();
	if not tbGift.nUpdateDay or nToday ~= tbGift.nUpdateDay then
		if Gift.SpecialGift[nGiftType] then
			if nGiftType == Gift.GiftType.MailGift then
				for nAcceptId,tbInfo in pairs(tbGift) do
					if tonumber(nAcceptId) then
						for szKey,_ in pairs(tbInfo) do 					-- 防止遍历到送花送草类型
							if type(szKey) == "string" then
								local tbInfo = Gift:GetMailGiftInfo(szKey) 			
								if tbInfo and tbInfo.bReset and tbInfo.nTimesType == Gift.MailType.Times2Player then 			-- 控制只重置MailGift类型的次数
									tbGift[nAcceptId][szKey] = nil
								end
							end
						end
					end
				end
			end
		else
			if Gift.IsReset[nGiftType] then
				for nAcceptId,_ in pairs(tbGift) do
					-- 防止遍历到 nUpdateDay
					if tonumber(nAcceptId) and tbGift[nAcceptId][nGiftType] then
						tbGift[nAcceptId][nGiftType] = nil
					end
				end
			end
		end
	end
end

-- 同步数据至客户端
function GiftManager:SynGiftData(pPlayer)
	local tbSynData = {};
	
	local tbGift = pPlayer.GetScriptTable("Gift");
	local nToday = Lib:GetLocalDay();
	if not tbGift.nUpdateDay or nToday ~= tbGift.nUpdateDay then
		for nType,_ in pairs(Gift.AllGift) do
			self:CheckReset(pPlayer,nType);
		end
		tbGift.nUpdateDay = nToday;
	end
	tbSynData = tbGift
	GiftManager:TryResetGiftItem(pPlayer)
	GiftManager:SynGiftItemData(pPlayer)
	pPlayer.CallClientScript("Gift:OnSynGiftData",tbSynData);
end

function GiftManager:SynNoLimitData(pPlayer)
	-- no send/recv times limit
	pPlayer.CallClientScript("Gift:OnSynNoLimitData")
end

function GiftManager:SynGiftItemData(pPlayer)
	local tbSynData = pPlayer.GetScriptTable("GiftItem");
	pPlayer.CallClientScript("Gift:OnSynGiftItemData",tbSynData);
end

function GiftManager:ClearMailItemTimes(pPlayer,szKey)
	local tbGiftItem = pPlayer.GetScriptTable("GiftItem");
	local tbInfo = Gift:GetMailGiftInfo(szKey)
	if not tbInfo then
		return
	end
	if tbInfo.nTimesType ~= Gift.MailType.Times2Item then
		return
	end
	tbGiftItem.tbSendItem = tbGiftItem.tbSendItem or {}
	local nRemainSend = tbGiftItem.tbSendItem[szKey]
	tbGiftItem.tbSendItem[szKey] = nil
	
	tbGiftItem.tbAcceptItem = tbGiftItem.tbAcceptItem or {}
	local nRemainAccept = tbGiftItem.tbAcceptItem[szKey]
	tbGiftItem.tbAcceptItem[szKey] = nil
	Log("[GiftManager] ClearMailItemTimes ok ",pPlayer.dwID,pPlayer.szName,szKey,nRemainSend,nRemainAccept)
end

function GiftManager:OnLogin()
	self:SynGiftData(me)
end

