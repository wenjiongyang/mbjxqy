
CombineServer.tbScriptData = CombineServer.tbScriptData or {};

-- 角色更名令
CombineServer.nChangePlayerNameItemId = 2593;

-- 家族更名令
CombineServer.nChangeKinNameItemId = 2640;

-- 武神令牌
CombineServer.nRankBattleItemId = 1258;

function CombineServer:LoadScriptData(key, value)
	self.tbScriptData[key] = value;
end

function CombineServer:GetOldScriptData(key)
	return self.tbScriptData[key] or {};
end

function CombineServer:CheckNeedChangeKinName(dwKinId, szKinName, tbKinData, dwOtherKinId, nSubIdentify)
	local tbOtherKin = Kin:GetKinById(dwOtherKinId);
	local bChangeSlaveKinName = true;
	if not tbOtherKin or tbKinData.nPrestige > tbOtherKin.nPrestige then
		bChangeSlaveKinName = false;
	end

	if tbOtherKin and not bChangeSlaveKinName then
		tbOtherKin:ChangeName(tbOtherKin.szName .. "@" .. nSubIdentify, true);
	end

	self:SendChangeKinNameAward(bChangeSlaveKinName and tbKinData or tbOtherKin);
	return bChangeSlaveKinName;
end

function CombineServer:SaveKinData(dwKinId, szKinName)
	local tbKinData = Kin:GetKinById(dwKinId);
	tbKinData:Save();

	Log("[CombineServer] CombineServer SaveKinData", dwKinId);
end

function CombineServer:SaveKinMember(dwRoleId)
	local tbMember = Kin:GetMemberData(dwRoleId);
	tbMember:Save();
end

function CombineServer:SendChangeKinNameAward(tbKinData)
	if not tbKinData or not tbKinData.nMasterId or tbKinData.nMasterId <= 0 then
		Log("[CombineServer] SendChangeKinNameAward Fial !!", (tbKinData or {}).nMasterId or 0, (tbKinData or {}).nKinId or 0, (tbKinData or {}).szName or "--");
		return;
	end

	local tbMail = {
		To = tbKinData.nMasterId;
		Title = "合服幫派重名補償";
		Text = "      尊敬的俠士，由於您的幫派名已重複，現贈送一枚幫派更名令作為補償，還請俠士費些心思，重新設計一個幫派名，日後此名定將響徹武林！";
		From = "幫派管理員";
		tbAttach = {{"item", self.nChangeKinNameItemId, 1}};
		nLogReazon = 0;
	};
	Mail:SendSystemMail(tbMail);
end

function CombineServer:SendChangeNameAward(tbPlayerInfo)
	local tbMail = {
		To = 0;
		Title = "合服角色重名補償";
		Text = "      尊敬的俠士，由於您的姓名已重複，現贈送一枚更名令作為補償，還請俠士另取一名，日後閣下此名定將響徹武林！";
		From = "劉雲";
		tbAttach = {{"item", self.nChangePlayerNameItemId, 1}};
		nLogReazon = 0;
	};

	for dwRoleId in pairs(tbPlayerInfo) do
		tbMail.To = dwRoleId;
		Mail:SendSystemMail(tbMail);
		Log("[CombineServer] SendChangeNameAward", dwRoleId);
	end
end

function CombineServer:SendRankBattleAward(nPlayerId)
	local tbMail = {
		To = nPlayerId;
		Title = "合服武神戰牌補償";
		Text = "      尊敬的俠士，由於武林動盪，如今武神殿已進行重新排名，閣下所在的名次或許受了影響，故于此補償武神戰牌一枚，還望閣下憑此戰牌，早日重登高位，海涵。";
		From = "楊鐵心";
		tbAttach = {{"item", self.nRankBattleItemId, 1}};
		nLogReazon = 0;
	};
	Mail:SendSystemMail(tbMail);
	Log("[CombineServer] SendRankBattleAward", nPlayerId);
end

function CombineServer:OnCombineServer(nMainIndentity, nSubIndentity, nSlaveIndentity)
	self.bInCombineServer = true;
	local tbInfo = ScriptData:GetValue("CombineServer");
	tbInfo.bCombineServer = true;
	ScriptData:AddModifyFlag("CombineServer");
	ScriptData:CheckAndSave()

	self:CombineAuction();
	self:CombineDomainBattle();
	self:CombineFactionBattle();
	self:DeleteNewInformationData();
	self:CombineRedBag();
	self:CombineHuaShanLunJian();
	self:CombineTeacherStudent();
	self:CombineChouJiang();
	self:CombineRandomFubenCollection(nMainIndentity, nSlaveIndentity)
	self:CombineSwornFriends();
	self:CombineBiWuZhaoQin();
	self:CombineWishActData();
	self:CombineBossLeader();
	self:CombineLottery();
	self:CombineWedding();
end

-- 合服后首次启动
function CombineServer:OnStartup()
	local tbInfo = ScriptData:GetValue("CombineServer");
	if not tbInfo.bCombineServer or self.bInCombineServer then
		return;
	end

	tbInfo.bCombineServer = false;
	ScriptData:AddModifyFlag("CombineServer");
	ScriptData:CheckAndSave();

	NewInformation:AddInfomation("CombineServer", GetTime() + (24 * 3600), {[[
    尊敬的俠士，如今天下大亂，而百家爭鳴，合縱連橫，在所難免，現今兩地俠客共處一城，還望諸位日後多加切磋，相互印鑒，此後的武林，想必更加精彩！
]]}, {szTitle = "武林公告"} )
	Log("[CombineServer] OnFirstStartup !!");
end

--结婚
function CombineServer:CombineWedding()
	--离婚
	local szKey = "WeddingDismissing"
	local tbOldDismissing = self:GetOldScriptData(szKey) or {}
	local tbLocalDismissing = ScriptData:GetValue(szKey)
	for nPlayerId, tbData in pairs(tbOldDismissing) do
		tbLocalDismissing[nPlayerId] = tbData
	end
	ScriptData:AddModifyFlag(szKey)

	self:CombineWeddingSchedule()
end

--师徒
function CombineServer:CombineTeacherStudent()
	--等待解除中
	local tbOldDismissing = self:GetOldScriptData("TSDismissing") or {}
	local tbLocalDismissing = ScriptData:GetValue("TSDismissing")
	for nPlayerId, tbData in pairs(tbOldDismissing) do
		tbLocalDismissing[nPlayerId] = Lib:CopyTB(tbData)
	end
	ScriptData:AddModifyFlag("TSDismissing")

	--玩家上线解除, 强制出师, 玩家上线更改称号名
	local tbOldMaxSlots = self:GetOldScriptData("MaxSlots")
	local tbMainKeys = {"TSDelayDismiss", "TSForceGraduate", "TSDelayChangeTitle"}
	for _, szMainKey in ipairs(tbMainKeys) do
		local tbKeys = {szMainKey}
		local nOldMax = tbOldMaxSlots[szMainKey] or 0
		for nSlot=1, nOldMax do
			table.insert(tbKeys, ScriptData:_GrpGetSlotKey(szMainKey, nSlot))
		end
		for _, szKey in ipairs(tbKeys) do
			local tbOldData = self:GetOldScriptData(szKey) or {}
			if next(tbOldData) then
				local _, nSlot = ScriptData:_GrpAddSlot(szMainKey)
				local szSlotKey = ScriptData:_GrpGetSlotKey(szMainKey, nSlot)
				ScriptData:SaveValue(szSlotKey, tbOldData)
				ScriptData:GrpSaveSlot(szMainKey, nSlot)
			end
		end
	end
	ScriptData:CheckAndSave()
end

-- 结拜
function CombineServer:CombineSwornFriends()
	local nOldMaxSlot = self:GetOldScriptData("SwornFriendsMaxSlot")
	Log("CombineServer:CombineSwornFriends, total slots", tostring(nOldMaxSlot))
	for nSlot=1, math.huge do
		local szKey = SwornFriends:_ScriptDataGetKey(nSlot)
		local tbSlot = self:GetOldScriptData(szKey)
		if not tbSlot or #tbSlot == 0 then
			Log("CombineServer:CombineSwornFriends, end at", szKey)
			break
		end

		for _, tbData in ipairs(tbSlot) do
			while true do
				if tbData.bClear then
					break
				end

				local szTitle = tbData[1]
				if SwornFriends:_IsMainTitleUsed(szTitle) then
					Log("CombineServer:CombineSwornFriends, main title used", szTitle)

					local tbMembers = tbData[2]
					for nPid in pairs(tbMembers) do
						local tbMail = {
							To = nPid,
							Title = "合服結拜重名補償",
							Text = "      尊敬的俠士，由於您的結拜稱號已重複，現贈送一本金蘭譜作為補償，還請俠士費些心思，重新設計一個稱號，日後此名定將響徹武林！";
							From = "系統",
							tbAttach = {{"item", SwornFriends.Def.nConnectItemId, 1}},
							nLogReazon = 0,
						}
						Mail:SendSystemMail(tbMail)

						local szCmd = "SwornFriends:_DeletePlayerTitle(me)"
						local szLog = string.format("%s|%d", "CombineServer:CombineSwornFriends", nPid)
						KPlayer.AddDelayCmd(nPid, szCmd, szLog)
					end
					break
				end

				SwornFriends:_ScriptDataAdd(tbData)

				break
			end
		end
	end
end

-- 红包
function CombineServer:CombineRedBag()
	Kin:TraverseKin(function(tbKinData)
		local nKinId = tbKinData.nKinId
		local szKey = RedBagMgr:_GetKey(nKinId)
		local tbRedBag = ScriptData.tbData[szKey] or self:GetOldScriptData(szKey)
		if not tbRedBag then
			Log("[x] CombineServer:CombineRedBag, both nil", nKinId)
			return
		end
		RedBagMgr:SaveByKinId(nKinId, tbRedBag)
	end)

	-- 全服红包
	local szMainKey = "GlobalRB"
	local tbOldMaxSlots = self:GetOldScriptData("MaxSlots")
	local nOldMax = tbOldMaxSlots[szMainKey] or 0
	local tbKeys = {}
	for nSlot=1, nOldMax do
		table.insert(tbKeys, ScriptData:_GrpGetSlotKey(szMainKey, nSlot))
	end
	for _, szKey in ipairs(tbKeys) do
		local tbOldData = self:GetOldScriptData(szKey) or {}
		if next(tbOldData) then
			local _, nSlot = ScriptData:_GrpAddSlot(szMainKey)
			local szSlotKey = ScriptData:_GrpGetSlotKey(szMainKey, nSlot)
			ScriptData:SaveValue(szSlotKey, tbOldData)
			ScriptData:GrpSaveSlot(szMainKey, nSlot)
		end
	end

	-- no kin delay
	local szNoKinDelayKey = "RedBagNoKinDelay"
	local tbOldData = self:GetOldScriptData(szNoKinDelayKey)
	local tbData = ScriptData:GetValue(szNoKinDelayKey)
	for nPlayerId, tb in pairs(tbOldData) do
		tbData[nPlayerId] = tb
	end
	ScriptData:AddModifyFlag(szNoKinDelayKey)

	ScriptData:CheckAndSave()
end

-- 拍卖（个人拍卖，世界拍卖）合服相关
function CombineServer:CombineAuction()
	local Auction = Kin.Auction;

	-- 合并全服拍卖
	local tbAuctionData = Auction:GetGlobalAuctionData();
	local tbOtherAuction = CombineServer:GetOldScriptData("GlobalAuction");
	local tbOtherAuctionData = tbOtherAuction and tbOtherAuction.tbAuctionData or {};

	for nId, tbItem in pairs(tbOtherAuctionData.tbItems or {}) do
		local nNewId = Auction:GetNextGlobalAuctionItemId();
		tbItem.nId = nNewId;
		tbAuctionData.tbItems[nNewId] = tbItem;
	end
	Auction:SaveGlobalAuctionData();

	local tbGlobalAuctionData = ScriptData:GetValue("GlobalAuction");
	local _, nRawTableSize = GetTableSize(tbGlobalAuctionData);
	-- 如果合并后数据大于可存盘数据，则直接发送, 目前是256k
	if nRawTableSize > 256 * 1024 then
		for nId, tbItem in pairs(tbAuctionData.tbItems or {}) do
			tbItem.nTimeOut = 0;
		end
		Kin:AuctionActive(true);
	end

	-- 合并个人拍卖
	local tbPersonAuctionData = ScriptData:GetValue("PersonAuctionPool");
	local tbOtherPersonData = CombineServer:GetOldScriptData("PersonAuctionPool");
	for nPlayerId, tbWaitAuctionData in pairs(tbOtherPersonData or {}) do
		tbPersonAuctionData[nPlayerId] = tbWaitAuctionData;
	end
	Auction:SavePersonAuctionData();
end

-- 领土战合服相关
function CombineServer:CombineDomainBattle()
	--对已经占领的进行补偿 ，家族拍卖和个人都有
	--其他的全清，届数保留最大的
	 --行商奖励还是有的，下次攻城战前清掉，
	local tbKinMaps = {};
	local nVersion1 = 0;
	local nVersion2 = 0;

	local nOpenWarDay1,nOpenWarDay2 = 0,0
	local tbData1 = ScriptData:GetValue("DomainBattle")
	local tbMapOwner = tbData1.tbMapOwner
	if tbMapOwner then
		for nMapId, dwKinId in pairs(tbMapOwner) do
			tbKinMaps[dwKinId] = nMapId;
		end
		nVersion1 = tbData1.nBattleVersion
		nOpenWarDay1 = tbData1.nOpenWarDay
	end


	local tbData2 = CombineServer:GetOldScriptData("DomainBattle");
	if tbData2 then
		local tbMapOwner = tbData2.tbMapOwner
		if tbMapOwner then
			for nMapId, dwKinId in pairs(tbMapOwner) do
				tbKinMaps[dwKinId] = nMapId;
			end
			nVersion2 = tbData2.nBattleVersion
			nOpenWarDay2 = tbData2.nOpenWarDay
		end
	end

	Log("CombineServer:CombineDomainBattle", nVersion1, nVersion2)
	Lib:LogTB(tbKinMaps)

	tbData1.tbMapOwner = {};
	tbData1.nOpenWarDay = nVersion1 > nVersion2 and nOpenWarDay1 or nOpenWarDay2
	tbData1.tbKinWarDeclare = {};
	tbData1.nBattleVersion = math.max(nVersion1, nVersion2)
	if nOpenWarDay1 > 0 then --当前已经开启新的宣战了
		nVersion1 = nVersion1 - 1
	end
	if nOpenWarDay2 > 0 then --当前已经开启新的宣战了
		nVersion2 = nVersion2 - 1
	end

	tbData1.tbMakeUpInfo = {
		nMakeUpTimes = 0;
		tbMakeUpKins = tbKinMaps;
		nVersion1 = nVersion1; --只用于补偿时判断是否参与上一届用
		nVersion2 = nVersion2;
	}

	DomainBattle:OnServerStart()

	--活动持续到最近的一次周二或周六的8点前
	local nWeek = Lib:GetLocalWeek()
	local nTime2 = Lib:GetTimeByWeek(nWeek, 2, 20, 0, 0)
	local nTime6 = Lib:GetTimeByWeek(nWeek, 6, 20, 0, 0)
	local nTime22 = Lib:GetTimeByWeek(nWeek + 1, 2, 20, 0, 0)
	local nNow = GetTime()
	local nEndTime;
	if nNow < nTime2 then
		nEndTime = nTime2
	elseif nNow < nTime6 then
		nEndTime = nTime6
	else
		nEndTime = nTime22
	end

	Activity:InitAndStartActivity("DomainBattleCombineAct", "DomainBattleCombineAct", nEndTime, {});

end

-- 门派竞技合服相关
function CombineServer:CombineFactionBattle()
	local tbOldBattleData = CombineServer:GetOldScriptData("FactionBattle");
	tbOldBattleData.nCurSession = tbOldBattleData.nCurSession or 0;
	tbOldBattleData.tbWinnerInfo = tbOldBattleData.tbWinnerInfo or {}
	tbOldBattleData.tbMonkeyData = tbOldBattleData.tbMonkeyData or {}
	tbOldBattleData.tbMonkeyData.nStartTime = tbOldBattleData.tbMonkeyData.nStartTime or 0
	tbOldBattleData.tbMonkeyData.tbMonkeyInfo = tbOldBattleData.tbMonkeyData.tbMonkeyInfo or {}
	tbOldBattleData.tbMonkeyData.nChosedSession = tbOldBattleData.tbMonkeyData.nChosedSession or 0
	tbOldBattleData.tbMonkeyData.nBackUpSession = tbOldBattleData.tbMonkeyData.nBackUpSession or -1
	tbOldBattleData.tbMonkeyData.nMonkeySession = tbOldBattleData.tbMonkeyData.nMonkeySession or 0

	if Lib:CountTB(tbOldBattleData.tbWinnerInfo) >= FactionBattle.MAX_SAVE_DATA_COUNT then
		for i=tbOldBattleData.nCurSession-FactionBattle.MAX_SAVE_DATA_COUNT, 1, -1 do
			tbOldBattleData.tbWinnerInfo[i] = nil
		end
	end
	
	if Lib:CountTB(FactionBattle.tbBattleData.tbWinnerInfo) >= FactionBattle.MAX_SAVE_DATA_COUNT then
		for i=FactionBattle.tbBattleData.nCurSession-FactionBattle.MAX_SAVE_DATA_COUNT, 1, -1 do
			FactionBattle.tbBattleData.tbWinnerInfo[i] = nil
		end
	end
	
	FactionBattle.tbBattleData.tbOldBattleData = FactionBattle.tbBattleData.tbOldBattleData or {}

	-- 合服时大师兄已经评选（而且还没结束）
	if FactionBattle.FactionMonkey:IsMonkeyStarting() and FactionBattle.FactionMonkey:IsMonkeyStarting(tbOldBattleData) then
		FactionBattle.FactionMonkey:MergeCandidates(FactionBattle.tbBattleData.tbMonkeyData.tbMonkeyInfo, tbOldBattleData.tbMonkeyData.tbMonkeyInfo)
		Log("[CombineServer] CombineFactionBattle FactionMonkey Is Starting")
	else
		table.insert(FactionBattle.tbBattleData.tbOldBattleData, tbOldBattleData);
	end

	Log("[CombineServer] CombineFactionBattle");
	Lib:LogTB(FactionBattle.tbBattleData.tbOldBattleData);
end

--删除最新消息数据
function CombineServer:DeleteNewInformationData()
	for szKey, _ in pairs(NewInformation.tbActivity) do
		local szScriptKey = "NewInfo_" .. szKey
		local tbInfoData = ScriptData:GetValue(szScriptKey)
		if tbInfoData.tbData or tbInfoData.nValidTime then
			tbInfoData.tbData = nil
			tbInfoData.nValidTime = 0
			ScriptData:AddModifyFlag(szScriptKey)
		end
	end
end

function CombineServer:CombineHuaShanLunJian()
	HuaShanLunJian:CombineHuaShanLunJian();
end

function CombineServer:CombineBossLeader()
    BossLeader:CombineBossLeaderKinJiFen();
end

function CombineServer:CombineChouJiang()
	local tbOldBaseData = CombineServer:GetOldScriptData("ChouJiangBase")
	if not tbOldBaseData then
		Log("[CombineServer] CombineChouJiang tbOldBaseData nil")
		return
	end
	local tbOldHitPlayer = tbOldBaseData.tbHitPlayer or {}

	local tbBaseData = ScriptData:GetValue("ChouJiangBase")
	tbBaseData.tbHitPlayer = tbBaseData.tbHitPlayer or {}

	for dwID,tbData in pairs(tbOldHitPlayer) do
		if tbBaseData.tbHitPlayer[dwID] then
			Log("[CombineServer] Old And New Server Same dwID",dwID)
		else
			tbBaseData.tbHitPlayer[dwID] = tbData
		end
	end

	ScriptData:AddModifyFlag("ChouJiangBase")

	local tbNewInfoData = ScriptData:GetValue(NewInformation.DEFAULT_SCRIPT)
	for szKey,_ in pairs(tbNewInfoData) do
		local szDelPrefix = string.sub(szKey,1,2)
		if szDelPrefix and szDelPrefix == "CJ" then
			local bRet = NewInformation:RemoveInfomation(szKey)
			if not bRet then
				Log("[CombineServer] CombineChouJiang Del NewInfomation Fail",szKey,szDelPrefix)
			else
				Log("[CombineServer] CombineChouJiang Del NewInfomation ok",szKey,szDelPrefix)
			end
		end
	end

	ScriptData:AddModifyFlag(NewInformation.DEFAULT_SCRIPT)

	Log("[CombineServer] CombineChouJiang Finish")
end

function CombineServer:CombineRandomFubenCollection(nMainIndentity, nSlaveIndentity)
	local tbOldData = CombineServer:GetOldScriptData("CollectionSystem")
	local nCollectionId = CollectionSystem.RANDOMFUBEN_ID
	if not tbOldData or not tbOldData[nCollectionId] then
		return
	end

	local tbNewData = ScriptData:GetValue("CollectionSystem")
	if not tbNewData[nCollectionId] then
		return
	end

	if tbOldData[nCollectionId].nSession == tbNewData[nCollectionId].nSession then
		return
	end

	tbNewData[nCollectionId].tbCombineInfo = tbNewData[nCollectionId].tbCombineInfo or {}
	tbNewData[nCollectionId].tbCombineInfo[nMainIndentity + nSlaveIndentity] = tbOldData[nCollectionId].nSession
	ScriptData:AddModifyFlag("CollectionSystem")
	Log("CombineServer CombineRandomFubenCollection", nMainIndentity, nSlaveIndentity, tbNewData[nCollectionId].nSession, tbOldData[nCollectionId].nSession)
	Lib:LogTB(tbNewData[nCollectionId].tbCombineInfo)
end

function CombineServer:CombineBiWuZhaoQin()
	local tbData = CombineServer:GetOldScriptData("BiWuZhaoQin") or {};
	tbData.tbAllLoverInfo = tbData.tbAllLoverInfo or {};

	local tbCurrentInfo = BiWuZhaoQin:GetAllLoverInfo();
	for k, v in pairs(tbData.tbAllLoverInfo) do
		tbCurrentInfo[k] = v;
	end
	ScriptData:AddModifyFlag("BiWuZhaoQin");
end

function CombineServer:CombineWishActData()
    local tbMainData = ScriptData:GetValue("WishActMain")
    tbMainData.tbKinDataSaveKey = tbMainData.tbKinDataSaveKey or {}
    tbMainData.tbDynamicKey = tbMainData.tbDynamicKey or {}
    --把主服数据填满，有新许愿数据直接跳到下一个存储单元
    local nMainSeverKeyLen = #tbMainData.tbDynamicKey
    if nMainSeverKeyLen > 0 then
    	tbMainData.tbDynamicKey[nMainSeverKeyLen][2] = 3
    end

    local tbOldData = CombineServer:GetOldScriptData("WishActMain") or {}
	tbOldData.tbKinDataSaveKey = tbOldData.tbKinDataSaveKey or {}
    tbOldData.tbDynamicKey = tbOldData.tbDynamicKey or {}

    for nSubKinId, szSaveKey in pairs(tbOldData.tbKinDataSaveKey) do
    	local nOldIdx = tonumber(string.sub(szSaveKey, 12))
    	tbMainData.tbKinDataSaveKey[nSubKinId] = "WishActSub_" .. (nOldIdx + nMainSeverKeyLen)
    end

    if #tbOldData.tbDynamicKey > 0 then
    	for i, tbInfo in ipairs(tbOldData.tbDynamicKey) do
    		local nNewIdx = i + nMainSeverKeyLen
	    	local szDataKey = "WishActSub_" .. nNewIdx
    		table.insert(tbMainData.tbDynamicKey, {szDataKey, tbInfo[2]})
    		local tbOldSubData = CombineServer:GetOldScriptData(tbInfo[1]) or {}
			ScriptData:AddDef(szDataKey)
			ScriptData:SaveValue(szDataKey, tbOldSubData)
			ScriptData:AddModifyFlag(szDataKey)
    	end
    end
    ScriptData:AddModifyFlag("WishActMain")
end

function CombineServer:CombineLottery()
	local KEY_DATA = "Lottery";
	local KEY_RECORD = "LotteryRecord";
	local tbSlaveRecord = self:GetOldScriptData(KEY_RECORD);
	if not tbSlaveRecord or not tbSlaveRecord.nDrawWeek then
		return;
	end

	local tbMainRecord = Lottery:GetRecordData();
	if tbMainRecord.nDrawWeek ~= tbSlaveRecord.nDrawWeek then
		Log("[ERROR][CombineServer] failed to combine lottery!!! draw week not match!", tbMainRecord.nDrawWeek, tbSlaveRecord.nDrawWeek);
		return;
	end

	for dwPlayerId in pairs(tbSlaveRecord.tbInvalidTicket or {}) do
		Lottery:AddInvalidTicket(dwPlayerId);
		Log("[CombineServer][Lottery] combine invalid ticket:", dwPlayerId);
	end

	for dwPlayerId, nRank in pairs(tbSlaveRecord.tbLucky or {}) do
		tbMainRecord.tbLucky[dwPlayerId] = nRank;
		Log("[CombineServer][Lottery] combine lucky record:", dwPlayerId, nRank);
	end
	
	ScriptData:SaveAtOnce(KEY_RECORD, tbMainRecord);

	local nIndex = 1;
	while (true) do
		local szKey = KEY_DATA .. nIndex;
		local tbSlaveData = self:GetOldScriptData(szKey);
		if not tbSlaveData then
			break;
		end

		local nPlayerCount = 0;
		local tbTicketData = tbSlaveData.tbTicket or {};
		for dwPlayerId, tbPlayerData in pairs(tbTicketData) do
			Lottery:AddTicket(dwPlayerId, tbPlayerData.tbExcept, tbPlayerData.nCount);

			nPlayerCount = nPlayerCount + 1;
		end
		
		if nPlayerCount == 0 then
			break;
		end

		nIndex = nIndex + 1;

		Log("[CombineServer][Lottery] combine ticket data: ", nIndex, nPlayerCount);
	end

	for nIndex in ipairs(Lottery.tbCache.tbTableSize) do
		local szKey = KEY_DATA .. nIndex;
		ScriptData:AddDef(szKey);

		local tbData = ScriptData:GetValue(szKey);
		ScriptData:SaveAtOnce(szKey, tbData);
	end

	Log("[CombineServer] combine lottery finished!");
end

-- 注意处理已完成和过期的情况
function CombineServer:CombineWeddingSchedule()
	local tbSchedule = ScriptData:GetValue("WWeddingSchedule");
	local tbBook = tbSchedule.tbBook or {}
	local tbOldSchedule = CombineServer:GetOldScriptData("WWeddingSchedule") or {};
	local tbOldBook = tbOldSchedule.tbBook or {}
	local bAlter 
	for nBookLevel, tbBookInfo in pairs(tbOldBook) do
		for nOpen, tbDetail in pairs(tbBookInfo) do
			for _, tbPlayerBookInfo in ipairs(tbDetail) do
				-- 还没举办的
				if not tbPlayerBookInfo.nOpenTime then
					local tbMapSetting = Wedding.tbWeddingLevelMapSetting[nBookLevel]
					if tbMapSetting and tbMapSetting.bBook then
						local szLog = Wedding:GetOverdueLog(tbPlayerBookInfo)
						local bOverdue = tbMapSetting.fnCheckBookOverdue(nOpen)
						-- 合并已过期
						if bOverdue then
							tbBook[nBookLevel] = tbBook[nBookLevel] or {}
							tbBook[nBookLevel][nOpen] = tbBook[nBookLevel][nOpen] or {}
							table.insert(tbBook[nBookLevel][nOpen], tbPlayerBookInfo)
							bAlter = true
							Log("CombineServer fnCombineWedding Overdue ", nBookLevel, nOpen, szLog)
						else
						-- 退款
							local tbCost = tbPlayerBookInfo.tbCost or {}
							for dwID, szCost in pairs(tbCost) do
								local tbAward
								if tonumber(szCost) then
									tbAward = {{"Gold", nCost}}
								else
									tbAward = Wedding:GetCostItemInfo(szCost, true)
								end
								local tbMail = {
									To = dwID;
									Title = "合服婚禮預定退款";
									From = "月老";
									Text = string.format("      尊敬的俠士，由於伺服器資料進行了互通。您預定的[FFFE0D]「%s」[-]婚禮，費用已全部退還，還請俠士另擇吉日重新預定婚禮！", tbMapSetting.szWeddingName);
									tbAttach = tbAward;
								};
								Mail:SendSystemMail(tbMail);
								Log("CombineServer fnCombineWedding refund ", dwID, nCost, nBookLevel, nOpen, szLog)
							end
						end
					end
				end
			end
		end
	end
	if bAlter then
		ScriptData:AddModifyFlag("WWeddingSchedule")
	end
end