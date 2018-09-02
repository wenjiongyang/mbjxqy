Kin.MonsterNian = Kin.MonsterNian or {}
local KinMonsterNian = Kin.MonsterNian

function KinMonsterNian:OnActOpen()
	self.bEnabled = true
	self:ClearData()
end

function KinMonsterNian:OnActClose()
	Kin:TraverseKin(function(tbKinData)
		self:OnTimeOver(tbKinData)
	end)
	self:ClearData()
	self.bEnabled = false
end

function KinMonsterNian:IsEnabled()
	return self.bEnabled
end

function KinMonsterNian:IsActive(nKinId)
	return self.bEnabled and not self:IsOver(nKinId)
end

function KinMonsterNian:ClearData()
	self.tbFireworks = {}
	self.tbFireworkTimers = {}
	self.tbOverKins = {}
	self.tbMonsters = {}
	self.tbGatherBoxes = {}
end

function KinMonsterNian:OnLogin(pPlayer)
	if pPlayer.nMapTemplateId~=Kin.Def.nKinMapTemplateId then
		return
	end
	self:OnEnterKinMap(pPlayer)
end

function KinMonsterNian:OnEnterKinMap(pPlayer)
	if self.bEnabled then
		pPlayer.CallClientScript("Ui:OpenWindow", "UseItemPop", {
			nTempId = Kin.MonsterNianDef.nFireworkId,
			nCD = Kin.MonsterNianDef.nFireworkCD,
			szAtlas = Kin.MonsterNianDef.szFireworkUseAtlas,
			szSprite = Kin.MonsterNianDef.szFireworkUseSprite,
		})
	end
	pPlayer.CallClientScript("Kin:OnSynMiniMainMapInfo", self:IsActive(pPlayer.dwKinId))
end

function KinMonsterNian:OnLeaveKinMap(pPlayer)
	pPlayer.CallClientScript("Ui:CloseWindow", "UseItemPop")
end

function KinMonsterNian:SetOver(nKinId)
	self.tbOverKins[nKinId] = true
end

function KinMonsterNian:IsOver(nKinId)
	self.tbOverKins = self.tbOverKins or {}
	return self.tbOverKins[nKinId]
end

function KinMonsterNian:Open(nKinId)
	if not self.bEnabled then
		return false, "活動尚未開啟"
	end

	local tbKin = Kin:GetKinById(nKinId)
	if not tbKin then
		Log("[x] KinMonsterNian:Open, no kin", tostring(nKinId))
		return false, "沒有幫派"
	end

	local nMapId = tbKin:GetMapId()
	if not nMapId or nMapId<=0 then
		return false, "幫派領地尚未創建"
	end

	self:RefreshFireworks(tbKin)
	self:CreateMonster(tbKin)

	local tbPlayer = KPlayer.GetMapPlayer(nMapId)
	for _, pPlayer in ipairs(tbPlayer or {}) do
		self:OnEnterKinMap(pPlayer)
	end

	return true
end

function KinMonsterNian:CreateMonster(tbKin)
	local nKinId = tbKin.nKinId
	local nMapId = tbKin:GetMapId()
	if not nMapId or nMapId<=0 then
		Log("[x] KinMonsterNian:CreateMonster, map nil", nKinId)
		return
	end
	local nX, nY = unpack(Kin.MonsterNianDef.tbMonsterPos)
	local pMonster = KNpc.Add(Kin.MonsterNianDef.nMonsterId, 1, 0, nMapId, nX, nY)
	self.tbMonsters[nKinId] = pMonster.nId
	pMonster.nKinId = nKinId
	pMonster.nRegDeathNotifyId = Npc:RegNpcOnDeath(pMonster, self.OnMonsterDeath, self)
	pMonster.nRegHpNotifyId = Npc:RegisterNpcHpChange(pMonster, function(nOldHp, nNewHp, nMaxHp)
		self:OnNpcHpChange(nKinId, nOldHp, nNewHp, nMaxHp)
	end)

	local tbMapSetting = Map:GetMapSetting(Kin.Def.nKinMapTemplateId)
    local szMsg = string.format("年獸出現在<%s(%d,%d)>，請大家趕緊去保護年貨驅逐年獸！", tbMapSetting.MapName, math.floor(nX*Map.nShowPosScale), math.floor(nY*Map.nShowPosScale))
    local tbLinkData = {
        nLinkType = ChatMgr.LinkType.Position,
        nMapId = Kin.Def.nKinMapTemplateId,
        nX = nX,
        nY = nY,
        nMapTemplateId = Kin.Def.nKinMapTemplateId,
    }
    ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.Kin, szMsg, nKinId, tbLinkData)
end

function KinMonsterNian:OnNpcHpChange(nKinId, nOldHp, nNewHp, nMaxHp)
	local nOldPercent = (nOldHp/nMaxHp)*100
	local nNewPercent = (nNewHp/nMaxHp)*100
	local bSendReward = false
	local nRewardHpStage = 0
	for nStage, nPercent in ipairs(Kin.MonsterNianDef.tbMonsterHpPercentRewards) do
		if nOldPercent>nPercent and nNewPercent<=nPercent then
			bSendReward = true
			nRewardHpStage = nStage
			break
		end
	end
	if bSendReward then
		self:SendMonsterHpRewards(nKinId)
		Log("KinMonsterNian:OnNpcHpChange, send rewards", nKinId, nRewardHpStage)
	end
end

function KinMonsterNian:SendMonsterHpRewards(nKinId)
	local tbKin = Kin:GetKinById(nKinId)
	if not tbKin then
		Log("[x] KinMonsterNian:SendMonsterHpRewards, kin nil", nKinId)
		return
	end
	self:CreateGatherBoxes(tbKin)
end

function KinMonsterNian:OnMonsterDeath(pKiller)
	local nKinId = him.nKinId
	local tbKin = Kin:GetKinById(nKinId)
	if not tbKin then
		Log("[x] KinMonsterNian:OnMonsterDeath, no kin", tostring(nKinId))
		return
	end
	self:OnFinish(tbKin, true)
	local szMsg = "恭喜大家齊心合力趕跑了年獸，保護了幫派的年貨！"
	ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.Kin, szMsg, nKinId)
end

function KinMonsterNian:OnFinish(tbKin, bDeath)
	local nKinId = tbKin.nKinId
	self:ClearFireworks(nKinId)

	local pMonster = nil
	local nMonsterId = self.tbMonsters[nKinId]
	if nMonsterId and nMonsterId>0 then
		pMonster = KNpc.GetById(nMonsterId)
		if not pMonster then
			return
		end
	else
		return
	end
	if pMonster.nRegDeathNotifyId and pMonster.nRegDeathNotifyId>0 then
		Npc:UnRegNpcOnDeath(pMonster.nId, pMonster.nRegDeathNotifyId)
	end
	if pMonster.nRegHpNotifyId and pMonster.nRegHpNotifyId>0 then
		Npc:UnRegisterNpcHpEvent(pMonster.nId, pMonster.nRegHpNotifyId)
	end

	if not bDeath and (pMonster.nCurLife/pMonster.nMaxLife)*100>Kin.MonsterNianDef.tbMonsterHpPercentRewards[1] then
		self:SendMonsterHpRewards(nKinId)
	end

	self:GiveRewards(nKinId)

	pMonster.Delete()
	self:SetOver(nKinId)

	Timer:Register(Env.GAME_FPS*Kin.MonsterNianDef.nClearGatherBoxDelay, self.ClearGatherBoxes, self, Lib:CopyTB(self.tbGatherBoxes[nKinId]))
	Log("KinMonsterNian:OnFinish", nKinId, tostring(bDeath))
end

function KinMonsterNian:GiveRewards(nKinId)
	local tbKinData = Kin:GetKinById(nKinId)
	if not tbKinData then
		Log("[x] KinMonsterNian:GiveRewards, kin nil", tostring(nKinId))
		return
	end

	local nToday = Lib:GetLocalDay()
	local nJoinMembers = 0
	local tbMembers = {}
	tbKinData:TraverseMembers(function (memberData)
		local tbMemberCacheData = memberData:GetMemberCacheData()
		if nToday==tbMemberCacheData.nKinGatherRewardDay then
			local pStay = KPlayer.GetRoleStayInfo(memberData.nMemberId)
			if pStay and pStay.nLevel>=Kin.MonsterNianDef.nMinJoinLevel then
				nJoinMembers = nJoinMembers + 1
				tbMembers[memberData.nMemberId] = true
			else
				Log("KinMonsterNian:GiveRewards, ignore player", nKinId, memberData.nMemberId, pStay and pStay.nLevel or -1)
			end
		end
		return true
	end)

	local nTotalValue = nJoinMembers*Kin.MonsterNianDef.nValuePerMember
	local tbItems = {}
	for nItemId, tbSetting in pairs(Kin.MonsterNianDef.tbAuctionSettings) do
		local nPercent, nSingleValue = unpack(tbSetting)
		local nValue = math.floor(nPercent*nTotalValue)
		local nCount = math.floor(nValue/nSingleValue)
		local nMod = nValue%nSingleValue
		local bAdd = MathRandom(nSingleValue)<nMod
		if bAdd then
			nCount = nCount+1
		end
		if nCount>0 then
			table.insert(tbItems, {nItemId, nCount})
		end
	end
	if next(tbItems) then
		Kin:AddAuction(nKinId, "MonsterNianAuction", tbMembers, tbItems)
		Log("KinMonsterNian:GiveRewards", nKinId, nJoinMembers, nTotalValue, #tbItems)
	else
		local szMsg = "本次驅逐年獸活動由於參與人數過少，沒有幫派拍賣獎勵！"
   		ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.Kin, szMsg, nKinId)
		Log("KinMonsterNian:GiveRewards, no item", nKinId, nJoinMembers, nTotalValue)
	end
end

function KinMonsterNian:OnTimeOver(tbKin)
	local nKinId = tbKin.nKinId
	if self:IsOver(nKinId) then
		return
	end
	self:OnFinish(tbKin, false)
	local szMsg = "活動結束了，年獸已經離開！"
    ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.Kin, szMsg, nKinId)
	Log("KinMonsterNian:OnTimeOver", nKinId)
end

function KinMonsterNian:ClearFireworks(nKinId)
	local tbKinFireworks = self.tbFireworks[nKinId] or {}
	if not next(tbKinFireworks) then
        return
    end

    for _, nId in ipairs(tbKinFireworks) do
        local pNpc = KNpc.GetById(nId)
        if pNpc then
            pNpc.Delete()
        end
    end
    self.tbFireworks[nKinId] = nil
end

function KinMonsterNian:RefreshFireworks(tbKin)
    local nKinId = tbKin.nKinId
    if self.tbFireworkTimers[nKinId] then
        Timer:Close(self.tbFireworkTimers[nKinId])
    end
    self.tbFireworkTimers[nKinId] = Timer:Register(Env.GAME_FPS*5, self.CreateFireworks, self, tbKin)
end

function KinMonsterNian:CreateFireworks(tbKin)
	local nKinId = tbKin.nKinId
	local nMapId = tbKin:GetMapId()
	self:ClearFireworks(nKinId)
	if not self.bEnabled or self:IsOver(nKinId) or not nMapId then
		self.tbFireworkTimers[nKinId] = nil
		Log("KinMonsterNian:CreateFireworks return", nKinId, tostring(self.bEnabled), tostring(self:IsOver(nKinId)), tostring(nMapId))
		return
	end

    self.tbFireworks[nKinId] = self.tbFireworks[nKinId] or {}
    local _, nPlayerCount = KPlayer.GetMapPlayer(nMapId)
    local nCount = math.floor(nPlayerCount*Kin.MonsterNianDef.nFireworksCountMult)
    for i = 1, nCount do
    	local tbFireworksPos = Kin.MonsterNianDef.tbFireworksPos
        local tbPos = tbFireworksPos[MathRandom(#tbFireworksPos)]
        local nX, nY = unpack(tbPos)
        local pNpc = KNpc.Add(Kin.MonsterNianDef.nFireworkPickId, 1, 0, nMapId, nX, nY)
        table.insert(self.tbFireworks[nKinId], pNpc.nId)
    end

    self.tbFireworkTimers[nKinId] = Timer:Register(Env.GAME_FPS*Kin.MonsterNianDef.nFireworkRefreshInterval,
    	self.CreateFireworks, self, tbKin)

	local tbPlayers = KPlayer.GetMapPlayer(nMapId)
    for _, pPlayer in ipairs(tbPlayers or {}) do
	    pPlayer.SendBlackBoardMsg("煙花散落在了地上，撿起來攻擊年獸吧！")
	end
end

function KinMonsterNian:ClearGatherBoxes(tbGatherBoxes)
	if not next(tbGatherBoxes or {}) then
        return
    end

    for _, nId in ipairs(tbGatherBoxes) do
        local pNpc = KNpc.GetById(nId)
        if pNpc then
            pNpc.Delete()
        end
    end
end

function KinMonsterNian:CreateGatherBoxes(tbKin)
	local nKinId = tbKin.nKinId
	local nMapId = tbKin:GetMapId()
	if not self.bEnabled or self:IsOver(nKinId) or not nMapId then
		Log("KinMonsterNian:CreateGatherBoxes return", nKinId, tostring(self.bEnabled), tostring(self:IsOver(nKinId)), tostring(nMapId))
		return
	end

	self.tbGatherBoxes[nKinId] = self.tbGatherBoxes[nKinId] or {}
    local _, nPlayerCount = KPlayer.GetMapPlayer(nMapId)
    local nCount = math.floor(nPlayerCount*2.5)
    for i = 1, nCount do
    	local tbGatherBoxPos = Kin.MonsterNianDef.tbGatherBoxPos
        local tbPos = tbGatherBoxPos[MathRandom(#tbGatherBoxPos)]
        local nX, nY = unpack(tbPos)
        local pNpc = KNpc.Add(Kin.MonsterNianDef.nMonsterHpPercentRewardId, 1, 0, nMapId, nX, nY)
        table.insert(self.tbGatherBoxes[nKinId], pNpc.nId)
    end

	local szMsg = "年獸扔下了很多寶箱，大家快去打開看看吧！"
	ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.Kin, szMsg, nKinId)
	Log("KinMonsterNian:CreateGatherBoxes", nKinId, nPlayerCount, nCount)
end