Gift.fnSend =
{
	[Gift.GiftType.RoseAndGrass] = function (pPlayer,nAcceptId,nCount)
		Gift:SendGift(pPlayer,nAcceptId,nCount,Gift.GiftType.RoseAndGrass)
	end;
	[Gift.GiftType.FlowerBox] = function (pPlayer,nAcceptId,nCount)
		Gift:SendGift(pPlayer,nAcceptId,nCount,Gift.GiftType.FlowerBox)
	end;
	[Gift.GiftType.MailGift] = function (pPlayer,nAcceptId,nCount,nItemId)
		local nGiftType = Gift.GiftType.MailGift
		local nTimesType = Gift:GetMailTimesType(nGiftType,nItemId)
		if not nTimesType or not Gift.MailTimesType[nTimesType] then
			Log("[Gift] Mail Time Type Error",pPlayer.dwID,pPlayer.szName,nAcceptId,nCount,nItemId,nTimesType or -1)
			return
		end
		Gift:SendMailGift(pPlayer,nAcceptId,nCount,nGiftType,nItemId,nTimesType)
	end;
	[Gift.GiftType.Lover] = function (pPlayer,nAcceptId,nCount)
		Gift:SendGift(pPlayer,nAcceptId,nCount,Gift.GiftType.Lover)
	end;
}


-- 因为想灵活返回itemId才特殊处理
Gift.tbMailAcceptItemId = 
{
	[3565] = function (pPlayer,pAcceptPlayer,szKey)
		return DirectLevelUp:GetCanBuyItem()
	end,
}

Gift.tbMailAcceptItemKey = 
{
	["XinDeBook"] = function (pPlayer, pAcceptPlayer, nAcceptItemId)
		local tbXinDe = Item:GetClass("XinDeBook");
		local tbGetAward = tbXinDe:GetItemInfoById(nAcceptItemId);
		if not tbGetAward then
			return nAcceptItemId;
		end
			
		if tbGetAward.GetItemID ~= nAcceptItemId or tbGetAward.SendItemID <= 0 then
			return nAcceptItemId;
		end

		return tbGetAward.SendItemID;
	end,
};

Gift.tbMailGiftCheck = 
{
	["LevelUpItem"] = function (pPlayer,pAcceptPlayer,nItemId)
		-- if nItemId == DirectLevelUp.n4SendItemTID then
		-- 	local nGetItemTID = DirectLevelUp:GetCanBuyItem()
		-- 	local bRet, szMsg = DirectLevelUp:IsPlayerCanUse(pAcceptPlayer, nGetItemTID)
		-- 	return bRet, szMsg
		-- end

		-- return true
	end,

	["XinDeBook"] = function (pPlayer,pAcceptPlayer,nItemId)
	    if pAcceptPlayer.nLevel > pPlayer.nLevel then
	    	return false, "不能夠贈送等級大於自己的玩家";
	    end	

	    return true;
	end,
}

Gift.tbFormatAward = 
{
	["LevelUpItem"] = function (tbAward,nAcceptItemId)
		-- local nEndTime = RegressionPrivilege:GetPrivilegeTime(pPlayer)
		-- if nEndTime <= GetTime() then
		-- 	return
		-- end

		-- if not tbAward[1] then
		-- 	return
		-- end

		-- table.insert(tbAward[1], nEndTime)
	end,
}

Gift.bIsOpenMailGift = true

function Gift:SendMailGift(pPlayer,nAcceptId,nCount,nGiftType,nItemId,nTimesType)
	if not Gift.bIsOpenMailGift then
		pPlayer.CenterMsg("郵件贈送禮物暫不開放",true)
		return
	end
	nAcceptId = tonumber(nAcceptId);

	if not pPlayer or not nAcceptId or not nCount or nCount < 1 or not nItemId then
		Log("[Gift] SendMailGift illegal data",pPlayer and pPlayer.dwID,nAcceptId,nCount,nGiftType,nItemId)
		return ;
	end

	local szItemName = KItem.GetItemShowInfo(nItemId, pPlayer.nFaction)

	local tbMailInfo = Gift:GetMailGiftItemInfo(nItemId)

	if not tbMailInfo or not szItemName then
		pPlayer.CenterMsg("該物品不支持贈送!");
		Log("[Gift] SendMailGift illegal opa",pPlayer.dwID,pPlayer.szName,nAcceptId,nCount,nGiftType,nItemId)
		return
	end

	local bAcceptOnline = true
	local pAcceptPlayer = KPlayer.GetPlayerObjById(nAcceptId);
	if not pAcceptPlayer then
		bAcceptOnline = false
		if Gift.MailTimesTypeNeedOnline[nTimesType] then
			pPlayer.CenterMsg("對方不線上!");
			return
		end
		pAcceptPlayer = KPlayer.GetRoleStayInfo(nAcceptId)
		if not pAcceptPlayer then
			pPlayer.CenterMsg("獲取資料失敗")
			Log("[Gift] SendMailGift GetRoleStayInfo fail", tostring(nAcceptId))
			return
		end
	end

	local bIsFriend = FriendShip:IsFriend(pPlayer.dwID, nAcceptId);
	if not bIsFriend then
		pPlayer.CenterMsg("對方不是你的好友!");
		return
	end

	if pPlayer.GetItemCountInAllPos(nItemId) < nCount then
		pPlayer.CenterMsg("您擁有的數量不足")
		Log("[Gift] SendMailGift not enough count",pPlayer.dwID,pPlayer.szName,nAcceptId,pAcceptPlayer.szName,nCount,nGiftType,nItemId)
		return
	end
	
	local bSexLimit = Gift:CheckMailSexLimit(tbMailInfo.szKey)
	local nItemSex = Gift:CheckMailItemSex(nItemId)
	if not nItemSex then
		pPlayer.CenterMsg("未知的贈送物品？")
		Log("[Gift] SendMailGift unknow item sex", pPlayer.dwID, pPlayer.szName, nAcceptId, pAcceptPlayer.szName, nCount, nGiftType, nItemId)
		return
	end
	local nAcceptSex = Gift:CheckSex(pAcceptPlayer.nFaction)
	if not nAcceptSex or (nItemSex == Gift.Sex.Girl and nAcceptSex ~= Gift.Sex.Girl) or (bSexLimit and nItemSex == Gift.Sex.Boy and nAcceptSex ~= Gift.Sex.Boy) then
		pPlayer.CenterMsg("接受者的性別不符？？")
		Log("[Gift] SendMailGift unknow item sex", pPlayer.dwID, pPlayer.szName, nAcceptId, pAcceptPlayer.szName, nCount, nGiftType, nItemId, nItemSex, nAcceptSex)
		return
	end

	if tbMailInfo.tbData.nVip > 0 then
		if pPlayer.GetVipLevel() < tbMailInfo.tbData.nVip then
			pPlayer.CenterMsg(string.format("VIP達到%d級才可贈送",tbMailInfo.tbData.nVip))
			return
		end
	end 

	if tbMailInfo.tbData.nImityLevel > 0 then
		local nImityLevel = FriendShip:GetFriendImityLevel(pPlayer.dwID, nAcceptId) or 0
		if nImityLevel < tbMailInfo.tbData.nImityLevel then
			pPlayer.CenterMsg(string.format("雙方親密度等級達到%d級才可贈送",tbMailInfo.tbData.nImityLevel))
			return
		end
	end

	local bRet,key,nRemain,szAcceptKey,szAcceptRemain
	if nTimesType == Gift.MailType.Times2Player then
		bRet,key,nRemain = Gift.GiftManager:CheckGiftTimes(pPlayer,nAcceptId,nCount,nGiftType,nItemId)
		if not bRet then
			pPlayer.CenterMsg(key);
			Log("[Gift] SendMailGift CheckGiftTimes fail",pPlayer.dwID,pPlayer.szName,nAcceptId,pAcceptPlayer.szName,nCount,nGiftType,nItemId)
			return ;
		end
	elseif nTimesType == Gift.MailType.Times2Item then
		bRet,key,nRemain = Gift.GiftManager:CheckItemSend(pPlayer,nCount,nGiftType,nItemId)
		if not bRet then
			pPlayer.CenterMsg(key);
			return
		end
		bRet,szAcceptKey,szAcceptRemain = Gift.GiftManager:CheckItemAccept(pAcceptPlayer,nCount,nGiftType,nItemId)
		if not bRet then
			pPlayer.CenterMsg(szAcceptKey);
			return
		end
	elseif nTimesType == Gift.MailType.NoLimit then
		-- no limit, do nothing
	else
		pPlayer.CenterMsg("未知類型")
		Log("[Gift] unknow type",pPlayer.dwID,pPlayer.szName,nAcceptId,pAcceptPlayer.szName,nCount,nGiftType,nItemId)
		return
	end

	local fnCheck = Gift.tbMailGiftCheck[tbMailInfo.szKey]
	if fnCheck then
		local bResult,szMsg =  fnCheck(pPlayer,pAcceptPlayer,nItemId)
		if not bResult then
			pPlayer.CenterMsg(szMsg or "不支持贈送")
			return 
		end
	end

	if not tbMailInfo.tbData.bNotConsume then
		if pPlayer.ConsumeItemInAllPos(nItemId, nCount, Env.LogWay_SendMailGift) < nCount then
			pPlayer.CenterMsg("扣除道具%s失敗！",szItemName);
			Log("[Gift] SendMailGift consume item fail", pPlayer.dwID,pPlayer.szName,nAcceptId,pAcceptPlayer.szName,nItemId,nCount,nGiftType,key,nRemain,szAcceptKey,szAcceptRemain);
			return
		end
	end

	if nTimesType == Gift.MailType.Times2Player then
		if nRemain ~= Gift.Times.Forever then
			Gift.GiftManager:ReduceGiftTimes(pPlayer,nAcceptId,key,nRemain,nCount)
		end
		Gift.GiftManager:SynGiftData(pPlayer)
	elseif nTimesType == Gift.MailType.Times2Item then
		if nRemain ~= Gift.Times.Forever then
			Gift.GiftManager:ReduceItemSend(pPlayer,key,nRemain,nCount)
		end
		if szAcceptRemain ~= Gift.Times.Forever then
			Gift.GiftManager:ReduceItemAccept(pAcceptPlayer,szAcceptKey,szAcceptRemain,nCount)
		end
		Gift.GiftManager:SynGiftItemData(pPlayer)
	elseif nTimesType == Gift.MailType.NoLimit then
		Gift.GiftManager:SynNoLimitData(pPlayer)
	end

	local nAcceptItemId = nItemId
	local fnChangeItemId = Gift.tbMailAcceptItemId[nItemId]
	if fnChangeItemId then
		nAcceptItemId = fnChangeItemId(pPlayer,pAcceptPlayer,tbMailInfo.szKey)
		szItemName = KItem.GetItemShowInfo(nAcceptItemId, pPlayer.nFaction)
	end

	local fnChangeItemKey = Gift.tbMailAcceptItemKey[tbMailInfo.szKey];
	if fnChangeItemKey then
		nAcceptItemId = fnChangeItemKey(pPlayer, pAcceptPlayer, nAcceptItemId)
		szItemName = KItem.GetItemShowInfo(nAcceptItemId, pPlayer.nFaction)
	end	
	
	local tbAward = {{"item",nAcceptItemId,nCount}}
	local fnFormatAward = Gift.tbFormatAward[tbMailInfo.szKey]
	if fnFormatAward then
		fnFormatAward(tbAward,nAcceptItemId)
	end

	local tbMail = {
				To = nAcceptId;
				Title = "物品贈送";
				From = "系統";
				Text = string.format("    你的好友[FFFE0D]%s[-]給你贈送了[FFFE0D]%s[-]，請查收附件。",pPlayer.szName,szItemName);
				tbAttach = tbAward;
				nLogReazon = Env.LogWay_SendMailGift;
			};
	if not tbMailInfo.tbData.bNotSendMail then
		Mail:SendSystemMail(tbMail);
	end
	if tbMailInfo.szKey=="WaiYiGift" then
		local pAccept = KPlayer.GetRoleStayInfo(nAcceptId)
		if pAccept then
			local szMsg = string.format("「%s」從錦盒中拿出【%s】送給「%s」，說道：豈曰無衣？與子同裳。不妨穿上試試，定是十分俊俏！", pPlayer.szName, szItemName, pAccept.szName)
			KPlayer.SendWorldNotify(1, 999, szMsg, 1, 1)
		end
	end

	if tbMailInfo.szKey=="WaiYiGiftBox" then
		local pAccept = KPlayer.GetRoleStayInfo(nAcceptId)
		if pAccept then
			local szMsg = string.format("「%s」拿出【%s】送給「%s」，並說道：江南無所有，聊贈一枝春！", pPlayer.szName, szItemName, pAccept.szName)
			KPlayer.SendWorldNotify(1, 999, szMsg, 1, 1)
		end
	end

	local nImitity = 0
	if tbMailInfo.tbData.nAddImitity then
		nImitity = tbMailInfo.tbData.nAddImitity * nCount;
		FriendShip:AddImitity(pPlayer.dwID, nAcceptId, nImitity, Env.LogWay_SendMailGift);
	end

	if bAcceptOnline then
		pAcceptPlayer.OnEvent("SendMailGiftSuccess", pAcceptPlayer, nAcceptItemId)
		Activity:OnPlayerEvent(pPlayer, "Act_SendMailGift", pAcceptPlayer, tbMailInfo.szKey);
	end
	pPlayer.CenterMsg("贈送成功")
	Log("[Gift] SendMailGift ok", pPlayer.dwID,pPlayer.szName,nAcceptId,pAcceptPlayer.szName,nItemId,nAcceptItemId,nCount,nGiftType,key,nRemain,szAcceptKey,szAcceptRemain,nImitity,tbMailInfo.tbData.bNotConsume and 1 or 0)
end

function Gift:SendGift(pPlayer,nAcceptId,nCount,nGiftType)

	nAcceptId = tonumber(nAcceptId);

	if not pPlayer or not nAcceptId or not nCount or nCount < 1 then
		return ;
	end

	local bRet,szMsg,pAcceptPlayer,nSex,nItemId,szItemName = self:CheckCommond(pPlayer,nAcceptId,nCount,nGiftType)

	if not bRet then
		pPlayer.CenterMsg(szMsg);
		return ;
	end
	local bRet,key,nRemain = Gift.GiftManager:CheckGiftTimes(pPlayer,nAcceptId,nCount,nGiftType)
	if not bRet then
		pPlayer.CenterMsg(key);
		return
	end

	local nSendId = pPlayer.dwID;

	if pPlayer.ConsumeItemInAllPos(nItemId, nCount, Env.LogWay_SendGift) < nCount then
		pPlayer.CenterMsg("扣除道具%s失敗！",szItemName);
		Log("[Gift] SendGift consume item fail",nSendId,nAcceptId,nItemId,nCount);
		return ;
	end
	if nRemain ~= Gift.Times.Forever then
		Gift.GiftManager:ReduceGiftTimes(pPlayer,nAcceptId,key,nRemain,nCount)
	end

	local nRate = Gift.Rate[nGiftType];
	if nRate then
		local nImitity = nRate * nCount;
		FriendShip:AddImitity(nSendId, nAcceptId, nImitity, Env.LogWay_SendGift);
	else
		Log("[Gift] SendGift no Imitity Rate",nSendId, nAcceptId,nGiftType,nCount,nSex,nItemId)
	end

	Gift.GiftManager:SynGiftData(pPlayer)

	self:EndDeal(pPlayer,pAcceptPlayer,nGiftType,nItemId,nSex,nCount)

	self:SendNotice(pPlayer,pAcceptPlayer,nGiftType,nSex,nImitity,nCount);

	Activity:OnPlayerEvent(pPlayer, "Act_SendGift", pAcceptPlayer, nGiftType, nItemId)
	Log("[Gift] Gift SendGift ",nAcceptId,nSendId,nCount,nGiftType,nImitity,nRate,nSex)
end

function Gift:SendNotice(pPlayer,pAcceptPlayer,nGiftType,nSex,nImitity,nCount)
	local szUnit = Gift:GetItemDesc(nGiftType,nSex) or "禮物"

	local szMeTips = ""
	local szHimTips = ""
	if nGiftType == Gift.GiftType.FlowerBox then
		szMeTips = string.format("你送給了「%s」",pAcceptPlayer.szName) ..szUnit
		szHimTips = string.format("你的好友「%s」送給你",pPlayer.szName) ..szUnit
		if nCount and nCount > 0 then
			for i=1,nCount do
				pPlayer.CenterMsg(szMeTips,true);
				pAcceptPlayer.CenterMsg(szHimTips,true);
			end
		end
	else
		szMeTips = string.format("你送給了「%s」%d",pAcceptPlayer.szName,nCount) ..szUnit
		szHimTips = string.format("你的好友「%s」送給你%d",pPlayer.szName,nCount) ..szUnit
		pPlayer.CenterMsg(szMeTips,true);
		pAcceptPlayer.CenterMsg(szHimTips,true);
	end
end

function Gift:EndDeal(pPlayer, pAcceptPlayer, nGiftType, nItemId, nSex, nCount)
	pPlayer.CallClientScript("Gift:SendGiftSuccess");
	if nGiftType == Gift.GiftType.FlowerBox then
		local szUnit = Gift:GetItemDesc(nGiftType,nSex) or "禮物"
		local nSendSex = Gift:CheckSex(pPlayer.nFaction)
		local nAcceptSex = Gift:CheckSex(pAcceptPlayer.nFaction)
		local szTips
		if self.tbWomensDayInst then
			szTips = self.tbWomensDayInst:OnSendGift(pPlayer, pAcceptPlayer, nGiftType, nItemId, nCount)
		end
		szTips = szTips or string.format(Gift:BoxNotice(nSendSex, nAcceptSex), pPlayer.szName, szUnit, pAcceptPlayer.szName)		-- 传回客户端计算滚动时间

		local tbPlayer = KPlayer.GetAllPlayer();
		local tbFriendPlayer = {
			[pPlayer.dwID] = true,
			[pAcceptPlayer.dwID] = true,
		}
		for _, pPlayer in pairs(tbPlayer) do
			local bShowEffect = tbFriendPlayer[pPlayer.dwID]
			pPlayer.CallClientScript("Gift:AcceptGiftSuccess", nGiftType, nItemId, szTips, nCount, bShowEffect);
		end
	else
		 pAcceptPlayer.CallClientScript("Gift:AcceptGiftSuccess",nGiftType,nItemId);
	end
end

function Gift:OnWomensDayOpen(tbInst)
	self.tbWomensDayInst = tbInst
end

function Gift:OnWomensDayClose()
	self.tbWomensDayInst = nil
end