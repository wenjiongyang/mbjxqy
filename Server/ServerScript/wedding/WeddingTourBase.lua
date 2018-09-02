Wedding.WeddingTourBase = Wedding.WeddingTourBase or {}
local WeddingTourBase = Wedding.WeddingTourBase

WeddingTourBase.tbTriggerFunc = 
{
	["SendNotify"] = true;
	--["PlayEffect"] = true;
	["TourEnd"] = true;
	["AddTempNpc"] = true;
	["TempNpcGoAndTalk"] = true;
	["StartCandy"] = true;
	["EndCandy"] = true;
	["ClearTempNpc"] = true;
	["PlayFirework"] = true;
	["NpcBubbleTalk"] = true;
	["RetsetCandyTimes"] = true;
	["TempNpcBubbleTalk"] = true;

}

function WeddingTourBase:StartTour(pBoy, pGirl, nTourId, nBookLevel)
	self.nWeddingLevel = nBookLevel
	self.nMapTID = Wedding.nTourMapTemplateId
	self.nExeTriggerId = 0
	self.tbWaitTrigger = {}
	self.nBoyPlayerId = pBoy.dwID
	self.nGirlPlayerId = pGirl.dwID
	self.tbRole = {[pBoy.dwID] = pBoy.szName, [pGirl.dwID] = pGirl.szName}
	self.nBoyViewNpc = 0
	self.nGirlViewNpc = 0
	self.nTourId = nTourId
	self:CreateNpc()
	self:TryStartPath()
	self:ForeachPlayer(self.PlayerState)
	self:CloseCheckTimer()
	self:StartCheckTimer()
	self:SendMsg()
	self:StartSynMapNpcPosTimer()
	self:TLogFlow()
	Log("WeddingTourBase fnStartTour > ", self:GetLog())
end

function WeddingTourBase:StartSynMapNpcPosTimer()
	Timer:Register(Env.GAME_FPS, function()
		return self:SynMapNpcPos()
	end)
end

function WeddingTourBase:SynMapNpcPos()
	local pNpc = KNpc.GetById(self.nTourSynMapPosNpcId)
	local tbPosInfo
	if pNpc then
		local nMapId, nX, nY = pNpc.GetWorldPos()
		tbPosInfo = {nMapId, nX, nY}
		self.nNpcMapId = nMapId
	end
	KPlayer.MapBoardcastScript(self.nNpcMapId, "Wedding:OnSynMapNpcPos", tbPosInfo)
	return tbPosInfo
end

-- 放烟花
function WeddingTourBase:PlayFirework(tbParam)
	local nId = tbParam and tbParam.nId
	if Wedding.tbTourPlayFireworkSetting[nId] then
		local tbPlayer = KPlayer.GetMapPlayer(Wedding.nTourMapTemplateId);
		for _, pPlayer in ipairs(tbPlayer or {}) do
			pPlayer.CallClientScript("Wedding:PlayWeddingTourFirework", nId)
		end
	end
end

-- 增加临时演员
function WeddingTourBase:AddTempNpc(tbParam)
	self.tbTempNpc = self.tbTempNpc or {}
	local pNpc = KNpc.Add(tbParam.nNpcTID, 1, 0, self.nMapTID, tbParam.nX, tbParam.nY, 0, tbParam.nDir or 0);
	if pNpc then
		self.tbTempNpc[tbParam.szGroup] = self.tbTempNpc[tbParam.szGroup] or {}
		table.insert(self.tbTempNpc[tbParam.szGroup], pNpc.nId)
	end
end

function WeddingTourBase:TempNpcBubbleTalk(tbParam)
	if not tbParam then
		return
	end
	local tbTempNpcId = self.tbTempNpc[tbParam and tbParam.szGroup] or {}
	for _, nNpcId in ipairs(tbTempNpcId) do
		local pNpc = KNpc.GetById(nNpcId);
		if pNpc and tbParam.szBubble then
			local tbPlayer = KNpc.GetAroundPlayerList(nNpcId, Wedding.szTempNpcBubbleRange) or {}
			for _, pPlayer in pairs(tbPlayer or {}) do
				pPlayer.CallClientScript("Wedding:DoBubbleTalk", nNpcId, tbParam.szBubbleTime, tbParam.szBubble)
			end
		end
	end
end

function WeddingTourBase:TempNpcGoAndTalk(tbParam)
	self.tbTempNpc = self.tbTempNpc or {}
	local tbNpc = self.tbTempNpc[tbParam.szGroup] or {}
	for _, nNpcId in ipairs(tbNpc) do
		local pNpc = KNpc.GetById(nNpcId);
		if pNpc then
			pNpc.AI_ClearMovePathPoint();
		    pNpc.AI_AddMovePos(tbParam.nX, tbParam.nY);
		    pNpc.SetActiveForever(1)
		    pNpc.AI_StartPath();
		    pNpc.tbOnArrive = {self.OnTempNpcArrive, self, nNpcId, tbParam};
		end
	end
end

function WeddingTourBase:OnTempNpcArrive(nNpcId, tbParam)
	local pNpc = KNpc.GetById(nNpcId);
	if pNpc then
		if tbParam.szBubble then
			local tbPlayer = KNpc.GetAroundPlayerList(nNpcId, Wedding.szTempNpcBubbleRange) or {}
			for _, pPlayer in pairs(tbPlayer or {}) do
				pPlayer.CallClientScript("Wedding:DoBubbleTalk", nNpcId, Wedding.szTempNpcBubbleTime, tbParam.szBubble)
			end
		end
		if tbParam.nDir then
			pNpc.SetDir(tbParam.nDir)
		end
	end
end

function WeddingTourBase:StartCandy()
	self.bCandy = true
	self.nCandy = (self.nCandy or 0) + 1
	local fnShow = function (self, pPlayer)
		pPlayer.CallClientScript("Fuben:SetBtnCandy", true)
	end;
	self:ForeachPlayer(fnShow)
end

function WeddingTourBase:EndCandy()
	self.bCandy = nil
	local fnHide = function (self, pPlayer)
		pPlayer.CallClientScript("Fuben:SetBtnCandy", false)
	end;
	self:ForeachPlayer(fnHide)
end

function WeddingTourBase:RetsetCandyTimes()
	self.tbCandyTimes = {}
end

function WeddingTourBase:SendCandy(pPlayer)
	local bRet, szMsg, nSendType = self:CheckSendCandy(pPlayer)
	if not bRet then
		pPlayer.CenterMsg(szMsg, true)
		return 
	end
	if not nSendType or (nSendType ~= Wedding.Candy_Type_Free and nSendType ~= Wedding.Candy_Type_Pay) then
		return
	end
	local fnSend = function (dwID)
		local tbAllPos = Wedding.tbCandyTourPos[self.nCandy]
		if tbAllPos and next(tbAllPos) then
			local tbNpc = Wedding:AddCandy(Wedding.szTourCandy, Wedding.nCandyTourCount, tbAllPos, self.nMapTID, self.tbRole)
			self:OnAddCandyNpc(tbNpc)
			Log("WeddingTourBase fnSendCandy ok ", dwID, self.nCandy)
		else
			Log("WeddingTourBase fnSendCandy no pos ", dwID, self.nCandy)
		end
		local tbPlayer = KNpc.GetAroundPlayerList(self.nBubbleRangeNpc, Wedding.nBubblePlayerDistance) or {}
		for _, pPlayer in pairs(tbPlayer) do
			pPlayer.SendBlackBoardMsg(string.format(Wedding.szSendCandyTourMsg, self.tbRole[self.nBoyPlayerId], self.tbRole[self.nGirlPlayerId]))
		end
	end;
	self.tbCandyTimes = self.tbCandyTimes or {}
	self.tbCandyTimes[pPlayer.dwID] = self.tbCandyTimes[pPlayer.dwID] or {}
	if nSendType == Wedding.Candy_Type_Free then
		self.tbCandyTimes[pPlayer.dwID][Wedding.Candy_Type_Free] = (self.tbCandyTimes[pPlayer.dwID][Wedding.Candy_Type_Free] or 0) + 1
		fnSend(pPlayer.dwID)
		pPlayer.nSendWeddingCandyTime = GetTime()
		Log("WeddingTourBase fnSendCandy Free", pPlayer.dwID, pPlayer.szName, self.tbCandyTimes[pPlayer.dwID][Wedding.Candy_Type_Free])
		return
	end
	if pPlayer.GetMoney("Gold") < Wedding.nCandyTourCost then
		pPlayer.CallClientScript("Ui:OpenWindow", "CommonShop", "Recharge", "Recharge");
		pPlayer.CenterMsg("元寶不足", true)
		return
	end
	-- CostGold谨慎调用, 调用前请搜索 _LuaPlayer.CostGold 查看使用说明, 它处调用时请保留本注释
	pPlayer.CostGold(Wedding.nCandyTourCost, Env.LogWay_WeddingTour, string.format("%s,%s", self.nBoyPlayerId or "", self.nGirlPlayerId or ""),
			function (nPlayerId, bSuccess, szBilloNo)
				local szFailMsg = ""
				local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
				if not pPlayer then
					szFailMsg = "購買次數中途, 您離線了"
					return false, szFailMsg;
				end
				if not bSuccess then
					szFailMsg = "支付失敗請稍後再試"
					pPlayer.CenterMsg(szFailMsg, true)
					return false, szFailMsg;
				end
				local bRet, szMsg, nSendType = self:CheckSendCandy(pPlayer)
				if not bRet then
					szFailMsg = szMsg
					pPlayer.CenterMsg(szFailMsg, true)
					return false, szFailMsg;
				end
				if nSendType ~= Wedding.Candy_Type_Pay then
					szFailMsg = "數據變動？"
					pPlayer.CenterMsg(szFailMsg, true)
					return false, szFailMsg
				end;
				self.tbCandyTimes[pPlayer.dwID][Wedding.Candy_Type_Pay] = (self.tbCandyTimes[pPlayer.dwID][Wedding.Candy_Type_Pay] or 0) + 1
				fnSend(nPlayerId)
				pPlayer.nSendWeddingCandyTime = GetTime()
				return true;
			end);
end

function WeddingTourBase:OnAddCandyNpc(tbNpc)
	self.tbAllCandyNpc = self.tbAllCandyNpc or {}
	for _, nNpcId in ipairs(tbNpc) do
		table.insert(self.tbAllCandyNpc, nNpcId)
	end
end

function WeddingTourBase:ClearAllCandy()
	for _, nNpcId in ipairs(self.tbAllCandyNpc or {}) do
		local pNpc = KNpc.GetById(nNpcId);
		if pNpc then
			pNpc.Delete()
		end
	end
	self.tbAllCandyNpc = nil
end

function WeddingTourBase:CheckSendCandy(pPlayer)
	if not self.tbRole[pPlayer.dwID] then
		return false, "你無權操作"
	end
	if not self.bCandy then
		return false, "派喜糖時間已經過了"
	end
	self.tbCandyTimes = self.tbCandyTimes or {}
	self.tbCandyTimes[pPlayer.dwID] = self.tbCandyTimes[pPlayer.dwID] or {}
	local nCandyFreeTimes = self.tbCandyTimes[pPlayer.dwID][Wedding.Candy_Type_Free] or 0
	if nCandyFreeTimes < Wedding.nCandyTourMaxFreeSend then
		return true, nil, Wedding.Candy_Type_Free
	end
	local nCandyCostTimes = self.tbCandyTimes[pPlayer.dwID][Wedding.Candy_Type_Pay] or 0
	if nCandyCostTimes < Wedding.nCandyTourMaxPaySend then
		return true, nil, Wedding.Candy_Type_Pay
	end
	return false, "喜糖已經派完了"
end

function WeddingTourBase:ClearTempNpc()
	for _, tbNpc in pairs(self.tbTempNpc or {}) do
		for _, nNpcId in ipairs(tbNpc) do
			local pNpc = KNpc.GetById(nNpcId);
			if pNpc then
				pNpc.Delete()
			end
		end
	end
end

function WeddingTourBase:SendMsg()
	local tbMapSetting = Map:GetMapSetting(self.nMapTID);
	local szMapName = tbMapSetting and tbMapSetting.MapName or ""
	local tbPlayer = {[self.nBoyPlayerId] = true, [self.nGirlPlayerId] = true}
	local tbSendPalyer = {}
	local function fnMsg(self, pPlayer)
		 local tbNofityData = {
		        szType = "WeddingTourBaseInvite",
		        nTimeOut = GetTime() + Wedding.nTourMsgListTimeOut,
	   	 	}
   		-- 优先好友
   		local tbAllFriend = KFriendShip.GetFriendList(pPlayer.dwID) or {}
   		tbNofityData.szContent = string.format("你的好友「%s」正在%s舉行花轎遊城，是否前往觀禮？", pPlayer.szName, szMapName)
   		for nFriendId in pairs(tbAllFriend) do
	   		if not tbPlayer[nFriendId] and not tbSendPalyer[nFriendId] then
	   			local pFriend = KPlayer.GetPlayerObjById(nFriendId)
	   			if pFriend then
		            pFriend.CallClientScript("Ui:SynNotifyMsg", tbNofityData)
		            tbSendPalyer[nFriendId] = true
	   			end
	   		end
  	 	end
  	 	-- 家族
  	 	if pPlayer.dwKinId > 0 then
		    local tbMember = Kin:GetKinMembers(pPlayer.dwKinId or 0)
		    tbNofityData.szContent = string.format("幫派成員「%s」正在%s舉行花轎遊城，是否前往觀禮？", pPlayer.szName, szMapName)
		    for dwID in pairs(tbMember or {}) do
		    	if not tbPlayer[dwID] and not tbSendPalyer[dwID] then
		    		local pKinMember = KPlayer.GetPlayerObjById(dwID)
			        if pKinMember then
			            pKinMember.CallClientScript("Ui:SynNotifyMsg", tbNofityData)
			            tbSendPalyer[dwID] = true
			        end
		    	end
		    end
		end
	end
	self:ForeachPlayer(fnMsg)
end

function WeddingTourBase:TLogFlow()
	local function fnLog(self, pPlayer)
		pPlayer.TLogRoundFlow(Env.LogWay_WeddingTour, pPlayer.nMapTemplateId, 0, 0, Env.LogRound_SUCCESS, 0, 0);
	end
	self:ForeachPlayer(fnLog)
end


function WeddingTourBase:StartCheckTimer()
	 self.nCheckTimer = Timer:Register(Env.GAME_FPS, self.CheckRange, self)
end

function WeddingTourBase:CloseCheckTimer()
	if self.nCheckTimer then
        Timer:Close(self.nCheckTimer)
        self.nCheckTimer = nil
    end
end

function WeddingTourBase:CheckRange()
	local pBubbleRangeNpc = KNpc.GetById(self.nBubbleRangeNpc or 0)
	if not pBubbleRangeNpc then
		self.nCheckTimer = nil
		return false
	end

	Lib:CallBack({self.CheckBubble, self});
	return true
end

function WeddingTourBase:CheckBubble()
	local pBubbleRangeNpc = KNpc.GetById(self.nBubbleRangeNpc or 0)
	if not pBubbleRangeNpc then
		return
	end

	local tbTourNpc = self.tbAllNpcId or {}
	local tbNpcList = KNpc.GetAroundNpcList(pBubbleRangeNpc, Wedding.nBubbleDistance) or {}
	for _, pNpc in pairs(tbNpcList) do
		if tbTourNpc[pNpc.nId] ~= pNpc.nTemplateId and pNpc.nId ~= (self.nBubbleRangeNpc or 0) then
			local tbPlayer = KNpc.GetAroundPlayerList(self.nBubbleRangeNpc, Wedding.nBubblePlayerDistance) or {}
			for _, pPlayer in pairs(tbPlayer) do
				if Wedding.tbBubbleMsg[pNpc.nTemplateId] then
					pPlayer.CallClientScript("Wedding:TryBubbleTalk", pNpc.nId, pNpc.nTemplateId)
				end
			end
		end
	end
end

function WeddingTourBase:StartSeriesTrigger(tbTrigger)
	if not tbTrigger or not next(tbTrigger) then
		return
	end
 	self.nExeTriggerId = self.nExeTriggerId + 1
 	self.tbWaitTrigger[self.nExeTriggerId] = {tbTrigger = tbTrigger, nTrigger = 0}
	self:StartTrigger(self.nExeTriggerId)
end

function WeddingTourBase:StartTrigger(nExeTriggerId)
	local tbExeTrigger = self.tbWaitTrigger[nExeTriggerId]
	if not tbExeTrigger then
		return
	end
	tbExeTrigger.nTrigger = tbExeTrigger.nTrigger + 1
	local tbTrigger = Wedding.tbTrigger[tbExeTrigger.tbTrigger[tbExeTrigger.nTrigger]]
	if not tbTrigger then
		return
	end
	local nTime = tbTrigger.nTime
	local tbExe = tbTrigger.tbExe
	if not tbExe then
		return
	end
	if nTime then
		Timer:Register(Env.GAME_FPS * nTime, self.ExeTrigger, self, tbExe, nExeTriggerId);
	else
		self:ExeTrigger(tbExe, nExeTriggerId)
	end
end

function WeddingTourBase:ExeTrigger(tbExe, nExeTriggerId)
	for _, tbTriggerInfo in ipairs(tbExe) do
		local szFunc = tbTriggerInfo.szType
		if self.tbTriggerFunc[szFunc] and WeddingTourBase[szFunc] then
			WeddingTourBase[szFunc](self, tbTriggerInfo.tbParam)
		end
	end
	self:StartTrigger(nExeTriggerId)
end

function WeddingTourBase:ForeachPlayer(fnFunc, ...)
	for _, nPlayerId in ipairs({self.nBoyPlayerId, self.nGirlPlayerId}) do
		local pPlayer = KPlayer.GetPlayerObjById(nPlayerId)
		if pPlayer then
			Lib:CallBack({fnFunc, self, pPlayer, ...});
		end
	end
end

function WeddingTourBase:ForeachWeddingNpc(nNpcTID, fnFunc, ...)
	local tbNpc = self.tbAllNpc and self.tbAllNpc[nNpcTID]
	for _, nNpcID in ipairs(tbNpc or {}) do
		local pNpc = KNpc.GetById(nNpcID);
		if pNpc then
			Lib:CallBack({fnFunc, self, pNpc, ...});
		end
	end
end

function WeddingTourBase:SendNotify(tbParam)
	local szMsg = tbParam.szMsg
	if szMsg then
		KPlayer.SendWorldNotify(tbParam.nMinLevel or 1, tbParam.nMaxLevel or 999, string.format(szMsg, self.tbRole[self.nBoyPlayerId], self.tbRole[self.nGirlPlayerId]), 1, 1)
	end	
end

-- function WeddingTourBase:PlayEffect(tbParam)
-- 	local function fnPlayEffect(self, pNpc)
-- 		local _, nX, nY = pNpc.GetWorldPos();
-- 		pNpc.CastSkill(tbParam.nEffectId, 1, tbParam.nPosX or nX, tbParam.nPosY or nY);
-- 	end
-- 	for _, nNpcTID in ipairs(tbParam.tbNpcTID or {}) do
-- 		self:ForeachWeddingNpc(nNpcTID, fnPlayEffect)
-- 	end
-- end

function WeddingTourBase:TourEnd()
	self:CloseCheckTimer()
	-- 先结束观战再移除npc
	self:ForeachPlayer(self.RemovePlayerState)
	local function fnDelNpc(self, pNpc)
		pNpc.Delete()
	end
	for nNpcTID, _ in pairs(self.tbAllNpc or {}) do
		self:ForeachWeddingNpc(nNpcTID, fnDelNpc)
	end
	-- 清理临时演员
	self:ClearTempNpc()
	-- 清理喜糖
	self:ClearAllCandy()
	-- 清理游行缓存数据
	Wedding:ClearCacheData(self.nBoyPlayerId)
	Wedding:ClearCacheData(self.nGirlPlayerId)
	local function fnSynData(pPlayer)
       Wedding:SynWeddingData(pPlayer)
    end

	Wedding:ForeachMapPlayer(self.nMapTID, fnSynData)
	-- 游城期间需要强制设置玩家离线托管时间防止玩家掉线
	local pBoy = KPlayer.GetPlayerObjById(self.nBoyPlayerId)
	local pGirl = KPlayer.GetPlayerObjById(self.nGirlPlayerId)
	if pBoy and pGirl then
		local bRet, szMsg = Wedding:CreateWeddingFuben(pBoy, pGirl, self.nWeddingLevel)
		if not bRet then
			pBoy.CenterMsg(szMsg, true)
			pGirl.CenterMsg(szMsg, true)
			Log("WeddingTourBase fnCreateWeddingFuben fail !! >>", self:GetLog())
		end
	else
		Log("WeddingTourBase fnCreateWeddingFuben player offline!! >>", self:GetLog())
	end
	Log("WeddingTourBase fnTourEnd ok >>", self:GetLog())
end

function WeddingTourBase:NpcBubbleTalk(tbParam)
	if not tbParam then
		return 
	end
	local tbNpcId = self.tbAllNpc[tbParam.nNpcTId] or {}
	local szBubble = string.format(tbParam.szBubble, self.tbRole[self.nBoyPlayerId], self.tbRole[self.nGirlPlayerId])
	for _, nNpcId in ipairs(tbNpcId) do
		local tbPlayer = KNpc.GetAroundPlayerList(nNpcId, Wedding.szTempNpcBubbleRange) or {}
		for _, pPlayer in pairs(tbPlayer) do
			pPlayer.CallClientScript("Wedding:DoBubbleTalk", nNpcId, tbParam.szBubbleTime, szBubble)
		end
	end
end

function WeddingTourBase:CreateNpc()
	self.tbAllNpc = {}
	self.tbAllNpcId = {}
	for _, v in ipairs(Wedding.tbAllNpc or {}) do
		local nNpcTID = v[1]
		local nX, nY = unpack(v[2])
		local nDir = v[3] or 0
		local pNpc = KNpc.Add(nNpcTID, 1, 0, self.nMapTID, nX, nY, 0, nDir);
		if pNpc then
			self.tbAllNpc[nNpcTID] = self.tbAllNpc[nNpcTID] or {}
			table.insert(self.tbAllNpc[nNpcTID], pNpc.nId)

			self.tbAllNpcId[pNpc.nId] = nNpcTID
			pNpc.tbTmp = {}
			pNpc.tbTmp.nPath = 0
			pNpc.tbTmp.tbPath = Lib:CopyTB(Wedding.tbNpcPath[nNpcTID] or {})
			if nNpcTID == Wedding.nBoyNpcTID then
				self:SetNpcInfo(pNpc, self.nBoyPlayerId, "新郎")
			elseif nNpcTID == Wedding.nGirlNpcTID then
				self:SetNpcInfo(pNpc, self.nGirlPlayerId, "新娘")
			end

			if nNpcTID == Wedding.nBoyViewNpcTID then
				self.nBoyViewNpc = pNpc.nId
			end
			if nNpcTID == Wedding.nGirlViewNpcTID then
				self.nGirlViewNpc = pNpc.nId
			end

			if nNpcTID == Wedding.nBubbleRangeNpcTID then
				self.nBubbleRangeNpc = pNpc.nId
			end 
			if nNpcTID == Wedding.nTourSynMapPosNpcTId then
				self.nTourSynMapPosNpcId = pNpc.nId
			end

		else
			Log("WeddingTourBase fnCreateNpc Fail", nNpcTID, self:GetLog())
		end
	end
end

function WeddingTourBase:GetLog()
	return self.nBoyPlayerId, self.nGirlPlayerId, self.nTourId, self.nBoyViewNpc, self.nGirlViewNpc, self.nTrigger
end

function WeddingTourBase:SetNpcInfo(pNpc, nPlayerId, szDefaultName)
	local pStayInfo = KPlayer.GetPlayerObjById(nPlayerId) or KPlayer.GetRoleStayInfo(nPlayerId)
	local szName = pStayInfo and pStayInfo.szName or szDefaultName
	pNpc.SetName(string.format("%s",szName or ""));
	local pKinData = Kin:GetKinByMemberId(nPlayerId)
	local szKinName = pKinData and pKinData.szName
	if szKinName then
		szKinName = string.format("[FF69B4]［幫派］%s[-]", szKinName or "-")
		pNpc.SetTitle(szKinName)
	end
end

function WeddingTourBase:TryStartPath()
	for nNpcTID, tbNpcId in pairs(self.tbAllNpc or {}) do
		for _, nNpcID in ipairs(tbNpcId) do
			 self:StartFindPath(nNpcID)
		end
	end
end

function WeddingTourBase:StartFindPath(nNpcID)
    local pNpc = KNpc.GetById(nNpcID);
    if not pNpc or not pNpc.tbTmp then
        return;
    end
 	pNpc.tbTmp.nPath = pNpc.tbTmp.nPath + 1

 	local tbPathInfo = pNpc.tbTmp.tbPath[pNpc.tbTmp.nPath]
 	if not tbPathInfo then
 		return
 	end
	local nTime = tbPathInfo.nTime
	local tbPos = tbPathInfo.tbPos
	local nDir = tbPathInfo.nDir
	local tbTrigger = tbPathInfo.tbTrigger
	pNpc.SetAiActive(1);
	pNpc.AI_ClearMovePathPoint();
    pNpc.AI_AddMovePos(tbPos[1], tbPos[2]);
    pNpc.SetActiveForever(1)
    pNpc.AI_StartPath();
    local tbNextathInfo = pNpc.tbTmp.tbPath[pNpc.tbTmp.nPath + 1]
    if tbNextathInfo then
    	pNpc.tbOnArrive = {self.OnArrivePath, self, nNpcID, nTime, nDir, tbTrigger};
    else
    	pNpc.tbOnArrive = nil
    end
end

function WeddingTourBase:OnArrivePath(nNpcID, nTime, nDir, tbTrigger)
	local pNpc = KNpc.GetById(nNpcID);
	if pNpc then
		pNpc.SetAiActive(0);
	end
	if tbTrigger then
		self:StartSeriesTrigger(tbTrigger)
	end
	if nTime then
		 Timer:Register(Env.GAME_FPS * nTime, self.StartFindPath, self, nNpcID);
	else
		self:StartFindPath(nNpcID)
	end
end

function WeddingTourBase:PlayerState(pPlayer)
	pPlayer.CallClientScript("Ui:OpenWindow", "HomeScreenFuben", "WeddingTour");
	pPlayer.CallClientScript("Fuben:SetBtnCandy", self.bCandy)
	Env:SetSystemSwitchOff(pPlayer, Env.SW_All)
	self:StartWatch(pPlayer)
	self:SetHide(pPlayer, 1)
	pPlayer.CallClientScript("Wedding:OnPlayerState")
end

-- 1 隐藏 0 显示
function WeddingTourBase:SetHide(pPlayer, nHide)
	local pNpc = pPlayer.GetNpc()
	if pNpc then
		pNpc.SetHideNpc(nHide)
	end
end

function WeddingTourBase:GetWatchNpcId(pPlayer)
	local nWatchNpcId
	if pPlayer.dwID == self.nBoyPlayerId then
		nWatchNpcId = self.nBoyViewNpc
	elseif pPlayer.dwID == self.nGirlPlayerId then
		nWatchNpcId = self.nGirlViewNpc
	end
	return nWatchNpcId
end

function WeddingTourBase:StartWatch(pPlayer)
	local nWatchNpcId = self:GetWatchNpcId(pPlayer)
	local pNpc = KNpc.GetById(nWatchNpcId or 0)
	if not pNpc then
		Log("WeddingTourBase fnStartWatch Fail", pPlayer.dwID, pPlayer.szName, self:GetLog(), nWatchNpcId or 0)
		return
	end
	
	pNpc.AddToForceSyncSet(pPlayer.dwID);
	pPlayer.SyncNpc(pNpc.nId)
	pPlayer.CallClientScript("Wedding:StartWatchState", pNpc.nId)
	self:WeddingCheckNpc(pPlayer, nWatchNpcId)
end

function WeddingTourBase:EndWatch(pPlayer)
	local nWatchNpcId = self:GetWatchNpcId(pPlayer)
	local pNpc = KNpc.GetById(nWatchNpcId or 0)
	if not pNpc then
		Log("WeddingTourBase fnEndWatch Fail", pPlayer.dwID, pPlayer.szName, self:GetLog(), nWatchNpcId or 0)
		return 
	end
	pNpc.RemoveFromForceSyncSet(pPlayer.dwID);
	pPlayer.CallClientScript("Wedding:EndWatchState", pNpc.nId)
end

function WeddingTourBase:RemovePlayerState(pPlayer)
	Env:SetSystemSwitchOn(pPlayer, Env.SW_All)
	self:EndWatch(pPlayer)
	self:SetHide(pPlayer, 0)
	pPlayer.CallClientScript("Wedding:OnRemovePlayerState")
	pPlayer.CallClientScript("Ui:CloseWindow", "HomeScreenFuben")
end

function WeddingTourBase:OnLogin(pPlayer)
	self:PlayerState(pPlayer)
end

function WeddingTourBase:OnLogout(pPlayer)
	self:RemovePlayerState(pPlayer)
end

function WeddingTourBase:WeddingCheckNpc(pPlayer, nNpcId)
	local pNpc = KNpc.GetById(nNpcId)
	if not pNpc then
		return
	end
	local nMapId, nX, nY = pNpc.GetWorldPos();
	local nMyMapId = pPlayer.GetWorldPos();
	if nMapId ~= nMyMapId then
		return
	end
	pPlayer.SetPosition(nX, nY)
	pPlayer.CallClientScript("Wedding:StartFollow", nNpcId)
end