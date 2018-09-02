local SAVE_GROUP = 89

function Kin:_GetRedBagSendTime(pPlayer, nEventId)
	return pPlayer.GetUserValue(SAVE_GROUP, nEventId)
end

function Kin:IsRedBagSent(pPlayer, nEventId)
	return Kin:_GetRedBagSendTime(pPlayer, nEventId)>0
end

function Kin:_SetRedBagSendTime(pPlayer, nEventId)
	pPlayer.SetUserValue(SAVE_GROUP, nEventId, GetTime())
end

function Kin:RedBagGainBySalaryWithoutCheck(nKinId, nPlayerId, nEventId)
	Log("RedBagGainBySalaryWithoutCheck", nKinId, nPlayerId, nEventId)
	self:_RedBagAdd(nKinId, nPlayerId, nEventId)
end

function Kin:RedBagGainByItemWithoutCheck(nKinId, pPlayer, nEventId)
	local nPlayerId = pPlayer.dwID
	Log("RedBagGainByItemWithoutCheck", nKinId, nPlayerId, nEventId)
	local szId = self:_RedBagAdd(nKinId, nPlayerId, nEventId)
	if not szId then
		return false
	end
	pPlayer.CallClientScript("Ui:OpenWindow", "RedBagDetailPanel", "send", szId)
	return true
end

function Kin:_RedBagGenId(nPlayerId, nEventId, nNow, bGlobal)
	self.nIdx = (self.nIdx or 0)%1000+1
	if bGlobal then
		return string.format("g_%d_%d_%d_%d", nPlayerId, nEventId, nNow, self.nIdx)
	else
		return string.format("%d_%d_%d_%d", nPlayerId, nEventId, nNow, self.nIdx)
	end
end

function Kin:_RedBagAdd(nKinId, nPlayerId, nEventId)
	local tbSetting = self.tbRedBagSettings[nEventId]
	if not tbSetting then
		Log("[x] Kin:_RedBagAdd", nKinId, nPlayerId, tostring(nEventId))
		return
	end
	local nGold = tbSetting.nBaseGold
	local nMaxReceiver = tbSetting.nCount

	local bGlobal = self:RedBagIsEventGlobal(nEventId)

	local nNow = GetTime()
	local szRedBagId = self:_RedBagGenId(nPlayerId, nEventId, nNow, bGlobal)
	Log("Kin:_RedBagAdd", nKinId, nPlayerId, nEventId, nGold, tostring(bGlobal), szRedBagId)

	local tbRedBag = {
		szId = szRedBagId,
		nEventId = nEventId,
		tbOwner = {
			nId = nPlayerId,
		},
		nBornTime = nNow,
		nSendTime = 0,	--未发送为0
		nGold = nGold,
		nMaxReceiver = nMaxReceiver,
		tbReceivers = {},
	}

	if bGlobal then
		tbRedBag.bGlobal = true
		RedBagMgr:GlobalAdd(tbRedBag)
	else
		RedBagMgr:Add(nKinId, tbRedBag)
	end

	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId)
	if pPlayer then
		pPlayer.TLog("RedBagFlow", 1, nKinId, nEventId, szRedBagId, nGold)
		pPlayer.CallClientScript("Kin:RedBagOnGain")
	end

	return szRedBagId
end

Kin.tbRedBagNoKinDelayEvents = {
	[Kin.tbRedBagEvents.beauty_hx_1] = true,
	[Kin.tbRedBagEvents.beauty_hx_10] = true,
	[Kin.tbRedBagEvents.beauty_hx_vote] = true,
	[Kin.tbRedBagEvents.beauty_final_1] = true,
	[Kin.tbRedBagEvents.beauty_final_10] = true,
	[Kin.tbRedBagEvents.beauty_final_vote] = true,
	[Kin.tbRedBagEvents.wldh_top1] = true,
	[Kin.tbRedBagEvents.wldh_top4] = true,
	[Kin.tbRedBagEvents.wldh_top16] = true,
	[Kin.tbRedBagEvents.wldh_elite] = true,
	[Kin.tbRedBagEvents.summer_gift_1] = true,
	[Kin.tbRedBagEvents.summer_gift_2] = true,
	[Kin.tbRedBagEvents.summer_gift_3] = true,
	[Kin.tbRedBagEvents.summer_gift_4] = true,
	[Kin.tbRedBagEvents.wedding_1] = true,
	[Kin.tbRedBagEvents.wedding_2] = true,
	[Kin.tbRedBagEvents.wedding_3] = true,
}
function Kin:_RedBagAddNoKinDelay(nPlayerId, nEventId, nCount)
	local tbSetting = self.tbRedBagSettings[nEventId]
	if not tbSetting then
		Log("[x] Kin:_RedBagAddNoKinDelay setting nil", nPlayerId, nEventId)
		return
	end

	local nEventType = tbSetting.nTypeId
	if not self.tbRedBagNoKinDelayEvents[nEventType] then
		return
	end

	local szKey = "RedBagNoKinDelay"
	local tbData = ScriptData:GetValue(szKey)
	tbData[nPlayerId] = tbData[nPlayerId] or {}
	tbData[nPlayerId][nEventType] = tbData[nPlayerId][nEventType] or {}
	--兼容老数据
	if type(tbData[nPlayerId][nEventType])~="table" then
		tbData[nPlayerId][nEventType] = {
			tonumber(tbData[nPlayerId][nEventType])
		}
	end
	table.insert(tbData[nPlayerId][nEventType], nCount or 0)
	ScriptData:AddModifyFlag(szKey)
	Log("Kin:_RedBagAddNoKinDelay", nPlayerId, nEventType, nEventId, tostring(nCount))
end

function Kin:_RedBagGain(nPlayerId, nEventId, nCount)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId)
	if not pPlayer then return end

	local bGlobal = self:RedBagIsEventGlobal(nEventId)
	local nKinId = pPlayer.dwKinId
	if not bGlobal and (not nKinId or nKinId<=0) then
		self:_RedBagAddNoKinDelay(nPlayerId, nEventId, nCount)
		return
	end

	self:_SetRedBagSendTime(pPlayer, nEventId)
	self:_RedBagAdd(nKinId, nPlayerId, nEventId)
end

function Kin:_RedBagCanSend(tbRedBag, nOwnerId)
	if tbRedBag.tbOwner.nId~=nOwnerId then
		return false, "紅包不是你的"
	end

	if tbRedBag.nSendTime>0 then
		return false, "紅包已被打開"
	end
	return true
end

function Kin:_RedBagCheckBeforeSend(pPlayer, tbRedBag, nAddGold, nCount)
	local bValid, szErr = self:_RedBagCanSend(tbRedBag, pPlayer.dwID)
	if not bValid then
		return false, szErr
	end

	bValid, szErr = self:RedBagIsModifyValid(tbRedBag.nEventId, nAddGold, nCount, pPlayer.GetVipLevel())
	if not bValid then
		return false, szErr
	end
	return true
end

function Kin:_RedBagGlobalGetById(szId)
	local tbSlot, nSlot = ScriptData:GrpFindSlot("GlobalRB", szId)
	if not tbSlot then
		return
	end
	return tbSlot[szId], nSlot, tbSlot
end

function Kin:_RedBagGlobalSave(nSlot)
	ScriptData:GrpSaveSlot("GlobalRB", nSlot)
end

function Kin:_RedBagSendByPlayer(pPlayer, szId, nAddGold, nCount)
	if not pPlayer then
		return false, "玩家離線"
	end

	local tbRedBag, nSlot = nil, nil
	local nKinId = pPlayer.dwKinId
	local tbKinData = Kin:GetKinById(nKinId)
	if not tbKinData then
		return false, "你沒有加入幫派"
	end

	local bGlobal = self:RedBagIsIdGlobal(szId)
	if bGlobal then
		tbRedBag, nSlot = self:_RedBagGlobalGetById(szId)
	else
		tbRedBag = RedBagMgr:GetById(nKinId, szId)
	end
	if not tbRedBag then
		return false, "紅包不存在"
	end

	local bValid, szErr = self:_RedBagCheckBeforeSend(pPlayer, tbRedBag, nAddGold, nCount)
	if not bValid then
		return false, szErr
	end

	tbRedBag.nGold = tbRedBag.nGold+nAddGold
	tbRedBag.nMaxReceiver = nCount
	if bGlobal then
		self:_RedBagGlobalDoSend(tbRedBag, nKinId, true)
		RedBagMgr:GlobalIncVersion()
		self:_RedBagGlobalSave(nSlot)
	else
		self:_RedBagDoSend(tbRedBag, tbKinData, true)
		RedBagMgr:IncVersion(nKinId)
	end
	self:RedBagUpdateReq(pPlayer, "")
	
	Achievement:AddCount(pPlayer, "RedBag_1", 1)
	return true
end

function Kin:_RedBagSend(szId, nAddGold, nCount)
	local bGlobal = self:RedBagIsIdGlobal(szId)

	local tbRedBag = nil
	if bGlobal then
		tbRedBag = self:_RedBagGlobalGetById(szId)
	else
		local nKinId = me.dwKinId
		tbRedBag = RedBagMgr:GetById(nKinId, szId)
	end
	if not tbRedBag then
		me.CenterMsg("紅包不存在")
		return
	end

	local bValid, szErr = self:_RedBagCheckBeforeSend(me, tbRedBag, nAddGold, nCount)
	if not bValid then
		me.CenterMsg(szErr)
		return
	end

	if nAddGold>0 then
		if me.GetMoney("Gold")<nAddGold then
			me.CenterMsg("元寶不足，發送紅包失敗")
			return
		end
		
		me.CostGold(nAddGold, Env.LogWay_KinRedBag, nil, function(nPlayerId, bSuccess)
			if not bSuccess then
				return false, "元寶不足，發送紅包失敗"
			end

			local pPlayer = KPlayer.GetPlayerObjById(nPlayerId)
			if not pPlayer then
				return false, "發紅包過程中，你離線了"
			end

			return self:_RedBagSendByPlayer(pPlayer, szId, nAddGold, nCount)
		end)
	else
		self:_RedBagSendByPlayer(me, szId, nAddGold, nCount)
	end
end

function Kin:_RedBagDoSendNotifyClient(tbRedBag, nMulti, tbPlayers, bOnline)
	for _, pPlayer in ipairs(tbPlayers) do
		if not self:RedBagIsPlayerGrabEnough(pPlayer) then
			if bOnline and pPlayer.dwID==tbRedBag.tbOwner.nId then	
				pPlayer.CallClientScript("Ui:OpenWindow", "RedBagDetailPanel", "viewgrab", tbRedBag.szId)
			else
				pPlayer.CallClientScript("Kin:RedBagOnNew", tbRedBag.szId, nMulti)
			end
		end
	end
end

function Kin:_RedBagDoSendChatLinks(tbRedBag, nKinId, bOnline, bGlobal)
	local tbOwner = tbRedBag.tbOwner
	local pOwner = KPlayer.GetRoleStayInfo(tbOwner.nId)
	if not pOwner then
		return
	end

	local _,szMulti = Kin:RedBagGetMultiInfo(tbRedBag.nEventId, tbRedBag.nGold)
	if bOnline then
		if not szMulti then szMulti="" end
		local szContent = self:RedBagGetContent(tbRedBag)
		szContent = Lib:StrTrimColorMark(szContent)
		local szMsg = string.format("#971%s，分享一個%s紅包<查看紅包>", szContent, szMulti)
		if bGlobal then
			szMsg = string.format("#940%s，分享一個%s世界紅包<查看紅包>", szContent, szMulti)
		end
		ChatMgr:SendPlayerMsg(bGlobal and ChatMgr.ChannelType.Public or ChatMgr.ChannelType.Kin,
			tbOwner.nId, pOwner.szName, pOwner.nFaction, pOwner.nPortrait, pOwner.nLevel, szMsg, {
			nLinkType = ChatMgr.LinkType.KinRedBag,
			szId = tbRedBag.szId,
		})
	else
		local szSysMsg = string.format("幫派總管：#971「%s」的紅包逾期由老夫代為發放 <查看紅包>", pOwner.szName)
		if bGlobal then
			szSysMsg = string.format("#940「%s」的世界紅包逾期由系統自動發放 <查看紅包>", pOwner.szName)
		end
		ChatMgr:SendSystemMsg(bGlobal and ChatMgr.SystemMsgType.System or ChatMgr.ChannelType.Kin, szSysMsg,
			nKinId, {
			nLinkType = ChatMgr.LinkType.KinRedBag,
			szId = tbRedBag.szId,
		})
	end
end

function Kin:_RedBagDoSendTLogs(nOwnerId, nKinId, tbRedBag)
	local pOwnerObj = KPlayer.GetPlayerObjById(nOwnerId)
	if pOwnerObj then
		pOwnerObj.TLog("RedBagFlow", 2, nKinId, tbRedBag.nEventId, tbRedBag.szId, tbRedBag.nGold)
	else
		local szAccount = KPlayer.GetPlayerAccount(nOwnerId)
		local szGameAppid, nPlat, nServerIdentity = GetWorldConfifParam()
		TLog("RedBagFlow", szGameAppid, nPlat, nServerIdentity, szAccount, nOwnerId, 2, nKinId, tbRedBag.nEventId, tbRedBag.szId, tbRedBag.nGold)
	end
end

function Kin:_RedBagGlobalDoSend(tbRedBag, nKinId, bOnline)
	tbRedBag.nSendTime = GetTime()

	self:_RedBagDoSendChatLinks(tbRedBag, nil, bOnline, true)

	local tbAllPlayer = KPlayer.GetAllPlayer()
	self:_RedBagDoSendNotifyClient(tbRedBag, nMulti, tbAllPlayer, bOnline)

    local nOwnerId = tbRedBag.tbOwner.nId
    self:_RedBagDoSendTLogs(nOwnerId, nKinId, tbRedBag)

    Log("Kin:_RedBagGlobalDoSend", nKinId, nOwnerId, tostring(bOnline), tbRedBag.nEventId, tbRedBag.nGold)
end

function Kin:_RedBagDoSend(tbRedBag, tbKinData, bOnline)
	tbRedBag.nSendTime = GetTime()
	RedBagMgr:IncVersion(tbKinData.nKinId)

	self:_RedBagDoSendChatLinks(tbRedBag, tbKinData.nKinId, bOnline, false)
	
	local tbPlayers = {}
	for nId in pairs(tbKinData.tbMembers) do
		local pPlayer = KPlayer.GetPlayerObjById(nId)
		if pPlayer then
			table.insert(tbPlayers, pPlayer)
		end
	end
	self:_RedBagDoSendNotifyClient(tbRedBag, nMulti, tbPlayers, bOnline)

	local nOwnerId = tbRedBag.tbOwner.nId
    self:_RedBagDoSendTLogs(nOwnerId, nKinId, tbRedBag)

	Log("Kin:_RedBagDoSend", tbKinData.nKinId, nOwnerId, tbRedBag.nEventId, tbRedBag.nGold)
end

function Kin:_IncPlayerGrabCount(pPlayer)
	local nLastTime = pPlayer.GetUserValue(Kin.Def.nRedBagPlayerGrabGrp, Kin.Def.nRedBagPlayerLastGrabTime)
	local nNow = GetTime()
	if Lib:IsDiffDay(0, nLastTime, nNow) then
		pPlayer.SetUserValue(Kin.Def.nRedBagPlayerGrabGrp, Kin.Def.nRedBagPlayerGrabCount, 1)
		pPlayer.SetUserValue(Kin.Def.nRedBagPlayerGrabGrp, Kin.Def.nRedBagPlayerLastGrabTime, nNow)
		return
	end

	local nCurCount = pPlayer.GetUserValue(Kin.Def.nRedBagPlayerGrabGrp, Kin.Def.nRedBagPlayerGrabCount)
	pPlayer.SetUserValue(Kin.Def.nRedBagPlayerGrabGrp, Kin.Def.nRedBagPlayerGrabCount, nCurCount+1)
end

function Kin:_RedBagCanGrab(tbRedBag, nPlayerId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId)
	if self:RedBagIsPlayerGrabEnough(pPlayer) then
		return false, "少俠今日領取的紅包個數已達上限"
	end

	local nSendTime = tbRedBag.nSendTime
	if nSendTime<=0 then
		return false, "紅包還未發出"
	end

	if GetTime()-nSendTime>Kin.Def.nRedbagExpireTime then
		return false, "紅包已過期"
	end

	if #tbRedBag.tbReceivers>=tbRedBag.nMaxReceiver then
		return false, "紅包已被搶光"
	end

	for _,tbReceiver in ipairs(tbRedBag.tbReceivers) do
		local tbPack = RedBagMgr:PackReceiver(tbReceiver)
		if tbPack.nId==nPlayerId then
			return false, "你已領過此紅包"
		end
	end

	return true
end

function Kin:_RedBagGetRandomGold(tbRedBag)
	local nLeftCount = tbRedBag.nMaxReceiver-#tbRedBag.tbReceivers
	local nReceiveGold = 0
	for _,tbReceiver in ipairs(tbRedBag.tbReceivers) do
		local tbPack = RedBagMgr:PackReceiver(tbReceiver)
		nReceiveGold = nReceiveGold+tbPack.nGold
	end

	local nLeftGold = tbRedBag.nGold-nReceiveGold
	if nLeftCount<=1 then return nLeftGold end

	local nFreeGold = nLeftGold-nLeftCount
	if nFreeGold<=0 then return 1 end

	local nRandom = MathRandom(0, math.ceil(nFreeGold/nLeftCount*2))
	return nRandom+1
end

function Kin:_RedBagCheckDead(tbRedBag, nKinId, bGlobal)
	if tbRedBag.nMaxReceiver<=#tbRedBag.tbReceivers then
		local nLuckyId = 0
		local nMax = 0
		for _,tbReceiver in ipairs(tbRedBag.tbReceivers) do
			local tbPack = RedBagMgr:PackReceiver(tbReceiver)
			if nMax<tbPack.nGold then
				nMax = tbPack.nGold
				nLuckyId = tbPack.nId
			end
		end
		local pLuckyMan = KPlayer.GetRoleStayInfo(nLuckyId)
		local pOwner = KPlayer.GetRoleStayInfo(tbRedBag.tbOwner.nId)
		if pLuckyMan and pOwner then
			local szMsg = string.format("「%s」的%d個紅包共%d#999%s被搶完。「%s」手氣最佳，搶到了%d#999",
				pOwner.szName, tbRedBag.nMaxReceiver, tbRedBag.nGold, Lib:TimeDesc(GetTime()-tbRedBag.nSendTime), pLuckyMan.szName, nMax)
			ChatMgr:SendSystemMsg(bGlobal and ChatMgr.SystemMsgType.System or ChatMgr.SystemMsgType.Kin, szMsg, bGlobal and 0 or nKinId)
		end

		if bGlobal then
			RedBagMgr:GlobalMoveToCache(tbRedBag.szId)
		else
			RedBagMgr:MoveToCache(nKinId, tbRedBag.szId)
		end
	end
end

function Kin:_RedBagGrab(szId)
	local bGlobal = self:RedBagIsIdGlobal(szId)
	local nKinId = me.dwKinId

	local tbRedBag, nSlot = nil, nil
	if bGlobal then
		tbRedBag, nSlot = self:_RedBagGlobalGetById(szId)
	end
	if not tbRedBag then --世界红包会尝试获取已抢光的
		tbRedBag = RedBagMgr:GetById(nKinId, szId)
	end
	if not tbRedBag then
		me.CenterMsg("紅包不存在")
		return
	end

	local nMyId = me.dwID
	local bCan, szErr = self:_RedBagCanGrab(tbRedBag, nMyId)
	if not bCan then
		me.CenterMsg(szErr)
		self:RedBagUpdateReq(me, szId)
		return
	end

	self:_IncPlayerGrabCount(me)

	local nGold = self:_RedBagGetRandomGold(tbRedBag)
	me.AddMoney("Gold", nGold, Env.LogWay_KinRedBag)
	local tbUnpack = RedBagMgr:UnpackReceiver({
		nId = nMyId,
		nGold = nGold,
	})
	table.insert(tbRedBag.tbReceivers, tbUnpack)
	tbRedBag.nVersion = (tbRedBag.nVersion or 0)+1
	if bGlobal then
		self:_RedBagGlobalSave(nSlot)
	else
		RedBagMgr:IncVersion(nKinId)
	end

	self:_RedBagCheckDead(tbRedBag, nKinId, bGlobal)
	self:RedBagUpdateReq(me, szId)

	Log("Kin:_RedBagGrab", nKinId, nMyId, szId, nGold)
	me.TLog("RedBagFlow", 3, nKinId, tbRedBag.nEventId, szId, nGold)
end

function Kin:RedBagAutoSendPrepare()
	local tbKins = {}
	for nKinId in pairs(Kin.KinData) do
		tbKins[nKinId] = true
	end
	self.tbRedBagAutoSendKins = tbKins
end

function Kin:RedBagAutoSend()
	local nNow = GetTime()
	local bSent = false

	for nKinId in pairs(self.tbRedBagAutoSendKins) do
		local bEmpty = true
		local tbRedBags = RedBagMgr:GetByKinId(nKinId)
		local tbKinData = self:GetKinById(nKinId)
		for _,tbRedBag in ipairs(tbRedBags) do
			if tbRedBag.nSendTime<=0 and (nNow-tbRedBag.nBornTime>=Kin.Def.nRedbagExpireTime) then
				self:_RedBagDoSend(tbRedBag, tbKinData)
				bSent = true
				bEmpty = false
				break
			end
		end
		if bEmpty then
			self.tbRedBagAutoSendKins[nKinId] = nil
		end
	end

	-- global redbags
	if not bSent then
		local szMainKey = "GlobalRB"
		local tbSlots = ScriptData:GrpGetAllSlots(szMainKey)
		for nSlot, tbSlot in ipairs(tbSlots) do
			for _, tbRedBag in pairs(tbSlot) do
				if tbRedBag.nSendTime<=0 and (nNow-tbRedBag.nBornTime>=Kin.Def.nRedbagExpireTime) then
					self:_RedBagGlobalDoSend(tbRedBag, 0, false)
					self:_RedBagGlobalSave(nSlot)
					bSent = true
					break
				end
			end
			if bSent then break end
		end
	end

	return bSent
end

------------
function Kin:_GetRedBagBriefList(nPlayerId, nKinId)
	self:RedBagRemoveExpire(nKinId)

	local tbRedBags = RedBagMgr:GetAll(nKinId)

	-- 全服 > 自己 > 他人 > 已领完
	table.sort(tbRedBags, function(tbA, tbB)
		local bEmptyA = #tbA.tbReceivers>=tbA.nMaxReceiver
		local bEmptyB = #tbB.tbReceivers>=tbB.nMaxReceiver
		if bEmptyA~=bEmptyB then
			return not bEmptyA
		end

		local bGlobalA = not not tbA.bGlobal
		local bGlobalB = not not tbB.bGlobal
		if bGlobalA~=bGlobalB then
			return bGlobalA
		end

		local bOwnerA = tbA.nOwnerId==nPlayerId
		local bOwnerB = tbB.nOwnerId==nPlayerId
		if bOwnerA~=bOwnerB then
			return bOwnerA
		end

		return tbA.nBornTime>tbB.nBornTime
	end)

	local tbBriefList = {
		nVersion = tbRedBags.nVersion,
	}

	local nCount = 0
	for _,tbRedBag in ipairs(tbRedBags) do
		local nOwnerId = tbRedBag.tbOwner.nId
		local pOwner = KPlayer.GetRoleStayInfo(nOwnerId)
		if pOwner then
			table.insert(tbBriefList, {
				szId = tbRedBag.szId,
				nEventId = tbRedBag.nEventId,
				szContent = tbRedBag.szContent,
				nSendTime = tbRedBag.nSendTime,
				nGold = tbRedBag.nGold,
				tbOwner = {
					nId = nOwnerId,
					szName = pOwner.szName,
					nFaction = pOwner.nFaction,
				},
				bEmpty = #tbRedBag.tbReceivers>=tbRedBag.nMaxReceiver,
				bCanGrab = self:_RedBagCanGrab(tbRedBag, nPlayerId),
			})
			nCount = nCount+1

			if nCount>=Kin.Def.nRedBagListMaxCount then
				break
			end
		end
	end
	return tbBriefList
end

function Kin:_GetReceiverDetail(nPlayerId, nGold)
	local tbReceiver = {}
	tbReceiver.nId = nPlayerId
	tbReceiver.nGold = nGold

	local pReceiver = KPlayer.GetRoleStayInfo(nPlayerId)
	tbReceiver.szName = pReceiver.szName
	tbReceiver.nLevel = pReceiver.nLevel
	tbReceiver.nFaction = pReceiver.nFaction
	tbReceiver.nPortrait = pReceiver.nPortrait

	return tbReceiver
end

function Kin:_GetRedBagDetail(pPlayer, tbRedBag)
	local tbDetail = Lib:CopyTB(tbRedBag)
	local pOwner = KPlayer.GetRoleStayInfo(tbDetail.tbOwner.nId)
	tbDetail.tbOwner.szName = pOwner.szName
	tbDetail.tbOwner.nLevel = pOwner.nLevel
	tbDetail.tbOwner.nFaction = pOwner.nFaction
	tbDetail.tbOwner.nPortrait = pOwner.nPortrait

	local tbRecvData = {}
	local nRecvCount = #tbDetail.tbReceivers
	tbRecvData.nCount = nRecvCount
	tbRecvData.tbTop = {}

	local nLuckyId, nMax = 0, 0
	local nMyGrabGold = 0
	if tbRecvData.nCount>=tbRedBag.nMaxReceiver then
		for _,tbReceiver in ipairs(tbRedBag.tbReceivers) do
			local tbPack = RedBagMgr:PackReceiver(tbReceiver)
			if nMax<tbPack.nGold then
				nMax = tbPack.nGold
				nLuckyId = tbPack.nId
			end
			if nMyGrabGold<=0 and tbPack.nId==pPlayer.dwID then
				nMyGrabGold = tbPack.nGold
			end
		end
	else
		for _,tbReceiver in ipairs(tbRedBag.tbReceivers) do
			local tbPack = RedBagMgr:PackReceiver(tbReceiver)
			if nMyGrabGold<=0 and tbPack.nId==pPlayer.dwID then
				nMyGrabGold = tbPack.nGold
				break
			end
		end
	end
	if nLuckyId>0 then
		table.insert(tbRecvData.tbTop, self:_GetReceiverDetail(nLuckyId, nMax))
	end
	tbRecvData.nMyGrabGold = nMyGrabGold

	local nReceivedGold = 0
	for _,v in ipairs(tbRedBag.tbReceivers) do
		local tbPack = RedBagMgr:PackReceiver(v)
		nReceivedGold = nReceivedGold+tbPack.nGold
	end
	tbRecvData.nReceivedGold = nReceivedGold

	for i=1, self.Def.nRedBagReceiverShowCount do
		local tbReceiver = tbDetail.tbReceivers[nRecvCount-i+1]
		if not tbReceiver then
			break
		end

		local tbPack = RedBagMgr:PackReceiver(tbReceiver)
		if tbPack.nId~=nLuckyId then
			table.insert(tbRecvData.tbTop, self:_GetReceiverDetail(tbPack.nId, tbPack.nGold))
		end
	end

	tbDetail.tbReceivers = nil
	tbDetail.tbRecvData = tbRecvData

	return tbDetail
end

function Kin:RedBagOnLogin(pPlayer)
	local bGetFirstRecharge = pPlayer.GetUserValue(Recharge.SAVE_GROUP, Recharge.KEY_GET_FIRST_RECHARGE)==1
	if bGetFirstRecharge then
		self:RedBagOnEvent(pPlayer, self.tbRedBagEvents.charge_count, 1)	
	end

	local nVipLevel = pPlayer.GetVipLevel(true)
	if nVipLevel>0 then
		self:RedBagOnEvent(pPlayer, self.tbRedBagEvents.vip_level, nVipLevel)
	end

	self:RedBagSendNoKinDelay(pPlayer)
end

function Kin:RedBagSendNoKinDelay(pPlayer)
	if not pPlayer.dwKinId or pPlayer.dwKinId<=0 then
		return
	end

	local nPlayerId = pPlayer.dwID
	local szKey = "RedBagNoKinDelay"
	local tbNoKinDelay = ScriptData:GetValue(szKey)
	local tbData = tbNoKinDelay[nPlayerId]
	if not tbData then
		return
	end

	for nEventType, tbCount in pairs(tbData) do
		if type(tbCount)=="number" then
			tbCount = {tbCount}
		end
		for _, nCount in ipairs(tbCount) do
			self:RedBagOnEvent(pPlayer, nEventType, nCount)
			Log("Kin:RedBagSendNoKinDelay", nPlayerId, nEventType, nCount)
		end
	end
	tbNoKinDelay[nPlayerId] = nil
	ScriptData:AddModifyFlag(szKey)
end

function Kin:RedBagMakeUnsendExpire(nKinId, nMemberId)
	local bChange = false
	local nExpireTime = GetTime()-Kin.Def.nRedbagExpireTime
	local tbRedBags = RedBagMgr:GetByKinId(nKinId)
	for _,tbRedBag in ipairs(tbRedBags) do
		if tbRedBag.tbOwner.nId==nMemberId and tbRedBag.nSendTime<=0 then
			tbRedBag.nBornTime = nExpireTime
			bChange = true
		end
	end
	if bChange then
		RedBagMgr:IncVersion(nKinId)
	end
end

function Kin:RedBagGlobalRemoveExpire()
	local nNow = GetTime()

	-- nonempty
	local tbSlots = ScriptData:GrpGetAllSlots("GlobalRB")
	local tbModifiedSlots = {}
	for nSlot, tbSlot in ipairs(tbSlots) do
		for szId, tbRedBag in pairs(tbSlot) do
			if tbRedBag.nSendTime>0 and (nNow-tbRedBag.nSendTime>=Kin.Def.nRedbagExpireTime) then
				RedBagMgr:_GiveBack(tbRedBag)
				tbSlot[szId] = nil
				tbModifiedSlots[nSlot] = true
			end
		end
	end
	for nSlot in pairs(tbModifiedSlots) do
		self:_RedBagGlobalSave(nSlot)
	end

	-- empty
	local tbCached = RedBagMgr._GlobalEmptyCache or {}
	for i=#tbCached, 1, -1 do
		local tbRedBag = tbCached[i]
		if nNow-tbRedBag.nSendTime>=Kin.Def.nRedbagExpireTime then
			table.remove(tbCached, i)
		end
	end
end

function Kin:RedBagRemoveExpire(nKinId)
	local nNow = GetTime()
	local nNextCheckTime = Kin.Def.tbRedBagNextCheckTimes[nKinId] or 0
	if nNow < nNextCheckTime then
		return
	end
	Kin.Def.tbRedBagNextCheckTimes[nKinId] = nNow+Kin.Def.nRedBagActiveDelta

	-- nonempty redbags
	local tbRedBags = RedBagMgr:GetByKinId(nKinId)
	for i=#tbRedBags,1,-1 do
		local tbRedBag = tbRedBags[i]
		if tbRedBag.nSendTime>0 and (nNow-tbRedBag.nSendTime>=Kin.Def.nRedbagExpireTime) then
			RedBagMgr:Remove(nKinId, i)
		end
	end

	-- empty cached ones
	local tbCached = RedBagMgr._EmptyCache[nKinId] or {}
	for szId,tbRedBag in pairs(tbCached) do
		if nNow-tbRedBag.nSendTime>=Kin.Def.nRedbagExpireTime then
			tbCached[szId] = nil
		end
	end
end

-- if szId is empty string, then update all
-- if szId is not empty string, then update szId
function Kin:RedBagUpdateReq(pPlayer, szId, nVersion, nGlobalVersion)
	local nKinId = pPlayer.dwKinId

	if szId=="" then
		if not nKinId or nKinId<=0 then
			return
		end
		local tbBriefList = self:_GetRedBagBriefList(pPlayer.dwID, nKinId)
		if tbBriefList and (nVersion~=tbBriefList.nVersion or nGlobalVersion~=RedBagMgr.nGlobalVersion) then
			pPlayer.CallClientScript("Kin:OnRedBagUpdateAll", tbBriefList, RedBagMgr.nGlobalVersion or 0)
		end
	else
		local tbRedBag = RedBagMgr:GetById(nKinId, szId)
		if not tbRedBag then
			pPlayer.CenterMsg("紅包不存在")
			return
		end
		if nVersion==tbRedBag.nVersion then
			return
		end
		local tbDetail = self:_GetRedBagDetail(pPlayer, tbRedBag)
		pPlayer.CallClientScript("Kin:OnRedBagUpdate", tbDetail)
	end
end

function Kin:RedBagSendReq(pPlayer, szId, nAddGold, nCount)
	GameSetting:SetGlobalObj(pPlayer)
	self:_RedBagSend(szId, nAddGold, nCount)
	GameSetting:RestoreGlobalObj()
end

function Kin:RedBagGrabReq(pPlayer, szId)
	GameSetting:SetGlobalObj(pPlayer)
	self:_RedBagGrab(szId)
	GameSetting:RestoreGlobalObj()
end

function Kin:RedBagIdipInnerId(szId, bGlobal)
	return bGlobal and "g_"..szId or "__"..szId
end

-- nKinId: global if nKinId<=0
function Kin:RedBagIdipAdd(szId, nOwnerId, nGold, nMaxReceiver, szContent, nKinId)
	self.tbRedBagIdipAddIds = self.tbRedBagIdipAddIds or {}
	if self.tbRedBagIdipAddIds[szId] then
		Log("[x] Kin:RedBagIdipAdd: exists", szId, nOwnerId, nGold, nMaxReceiver, szContent, nKinId, tostring(self.tbRedBagIdipAddIds[szId]))
		return false, "紅包id已存在"
	end

	local bGlobal = nKinId<=0
	local szInnerId = self:RedBagIdipInnerId(szId, bGlobal)

	local nNow = GetTime()
	local tbRedBag = {
		szId = szInnerId,
		nEventId = 0,
		tbOwner = {
			nId = nOwnerId,
		},
		nBornTime = nNow,
		nSendTime = 0,	--未发送为0
		nGold = nGold,
		nMaxReceiver = nMaxReceiver,
		tbReceivers = {},
		szContent = szContent,
	}

	if bGlobal then
		tbRedBag.bGlobal = true
		RedBagMgr:GlobalAdd(tbRedBag)
	else
		RedBagMgr:Add(nKinId, tbRedBag)
	end

	self.tbRedBagIdipAddIds[szId] = nKinId

	Log("Kin:RedBagIdipAdd", szId, nOwnerId, nGold, nMaxReceiver, szContent, nKinId)
	return true
end

function Kin:RedBagIdipRemove(szId)
	self.tbRedBagIdipAddIds = self.tbRedBagIdipAddIds or {}
	local nKinId = self.tbRedBagIdipAddIds[szId]
	if not nKinId then
		Log("[x] Kin:RedBagIdipRemove: not exists", szId)
		return false, "紅包id不存在"
	end

	local bGlobal = nKinId<=0
	local szInnerId = self:RedBagIdipInnerId(szId, bGlobal)
	if bGlobal then
		local _, nSlot, tbSlot = Kin:_RedBagGlobalGetById(szInnerId)
		if tbSlot then
			tbSlot[szInnerId] = nil
			self:_RedBagGlobalSave(nSlot)
		else
			for i, tbRedBag in ipairs(RedBagMgr._GlobalEmptyCache) do
				if szInnerId==tbRedBag.szId then
					table.remove(RedBagMgr._GlobalEmptyCache, i)
					break
				end
			end
		end
	else
		local bFound = false
		local tbRedBags = RedBagMgr:GetByKinId(nKinId)
		for i, tbRedBag in ipairs(tbRedBags) do
			if szInnerId==tbRedBag.szId then
				bFound = true
				table.remove(tbRedBags, i)
				RedBagMgr:IncVersion(nKinId)
				break
			end
		end
		if not bFound and RedBagMgr._EmptyCache[nKinId] then
			RedBagMgr._EmptyCache[nKinId][szInnerId] = nil
		end
	end

	self.tbRedBagIdipAddIds[szId] = nil
	Log("Kin:RedBagIdipRemove", szId, tostring(bGlobal))
	return true
end