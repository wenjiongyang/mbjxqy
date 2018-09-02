local self;

-- 发奖励接口，奖励表格式如下
--[[
tbAward = {
					道具ID		道具数量		超时时间
	{"item", 		110, 		1, 				GetTime() + 60},
	{"Coin",		100},
	{"Gold",		99},
	{"PartnerStone", 1,			10},
	{"Partner",		 1,			2},
	{"ComposeValue",nSeqId,nPos,nCount},	--nSeqId 决定是哪个道具的碎片 nPos 决定是碎片位置	nCount 为数量
	{"VipExp",		100},
};
]]

--bShowUi--默认显示,主动传false 才不显示
function _LuaPlayer.SendAward(tbAward, bMsg, bShowUi, nLogReazon, nLogReazon2)

	if not nLogReazon then
		Log(debug.traceback())
	end
	if bShowUi == nil then
		bShowUi = true;
	end

	if Forbid:IsForbidAward(self) then
		Forbid:SendForbidAwardNotice(self)
	else
		local tbAdd2AuctionIndex
		tbAward,tbAdd2AuctionIndex = KPlayer:FormatAward(self, tbAward, nil, nLogReazon, nLogReazon2);

		local tbAuctionAward = {}
		if tbAdd2AuctionIndex and next(tbAdd2AuctionIndex) then
			tbAward,tbAuctionAward = Kin:FormatAuctionItem(tbAward,tbAdd2AuctionIndex,tbAuctionAward)
			if tbAuctionAward and next(tbAuctionAward) then
				Kin:AddPersonAuction(self.dwID, tbAuctionAward)
			end
		end

		tbAward = KPlayer:MgrAward(self, tbAward);
		Lib:CallBack({KPlayer.SendAwardUnsafe, KPlayer, self.dwID, tbAward, bMsg or false, bShowUi, nLogReazon, nLogReazon2});
	end
end

function _LuaPlayer.ActionLog(szLogType, ActivityType, tbLog)
	Lib:CallBack({Player.ActionLog, Player, self, szLogType, ActivityType, tbLog});
end

function KPlayer:GetRealAward(pPlayer, tbInfo, szFromItemName, nLogReazon, nLogReazon2)
	local nAwardType = Player.AwardType[tbInfo[1]];
	if not nAwardType or nAwardType ~= Player.award_type_item then
		return;
	end

	local tbItemInfo = KItem.GetItemBaseProp(tbInfo[2]);
	if not tbItemInfo or not tbItemInfo.szClass or
		(tbItemInfo.szClass ~= "RandomItem" and
			tbItemInfo.szClass ~= "RandomItemByLevel" and
			tbItemInfo.szClass ~= "RandomItemByMaxLevel" and
			tbItemInfo.szClass ~= "RandomItemByTimeFrame") then

		return;
	end

	local nNeedAutoUse = KItem.GetItemExtParam(tbInfo[2], 2);
	if not nNeedAutoUse or nNeedAutoUse ~= 1 then
		return;
	end

	local nParamId = KItem.GetItemExtParam(tbInfo[2], 1);
	if tbItemInfo.szClass == "RandomItemByLevel" then
		nParamId = Item:GetClass("RandomItemByLevel"):GetRandomKindIdByPlayer(pPlayer, tbInfo[2]);
	elseif tbItemInfo.szClass == "RandomItemByMaxLevel" then
		nParamId = Item:GetClass("RandomItemByLevel"):GetRandomKindId(GetMaxLevel(), nParamId);
	elseif tbItemInfo.szClass == "RandomItemByTimeFrame" then
		nParamId = Item:GetClass("RandomItemByTimeFrame"):GetRandomKindIdByPlayer(pPlayer, tbInfo[2]);
	end

	local tbResult = {};
	local tbAdd2AuctionResult = {}

	szFromItemName = szFromItemName or tbItemInfo.szName
	for i = 1, tbInfo[3] do
		local bRet, szMsg, tbAllAward,tbAdd2AuctionIndex = Item:GetClass("RandomItem"):RandomItemAward(pPlayer, nParamId, szFromItemName, nLogReazon, nLogReazon2);
		if not bRet or bRet ~= 1 then
			Log("[GetRealAward] ERR ?? get random item award fail !", pPlayer.szAccount, pPlayer.dwID, pPlayer.szName, unpack(tbInfo));
			return;
		end

		for nIdx, tbAward in ipairs(tbAllAward) do
			table.insert(tbResult,tbAward)
			if tbAdd2AuctionIndex and tbAdd2AuctionIndex[1] and nIdx == tbAdd2AuctionIndex[1] then
				table.insert(tbAdd2AuctionResult, #tbResult);
				table.remove(tbAdd2AuctionIndex, 1);
			end
		end

	end

	Log("[GetRealAward] auto use item", pPlayer.szAccount, pPlayer.dwID, pPlayer.szName, unpack(tbInfo));
	return tbResult,tbAdd2AuctionResult;
end

function KPlayer:MgrAward(pPlayer, tbAward)
	local tbItemAward = {};
	local tbMoneyAward = {};
	local tbPartnerAward = {};
	local nExp = 0;
	local nBaseExp = 0;
	local nKinFound = 0;
	local nFactionHonor = 0;
	local nBattleHonor = 0;

	local tbResult = {};
	for _, tbInfo in pairs(tbAward) do
		local nAwardType = Player.AwardType[tbInfo[1]];
		local nParamCount = #tbInfo;
		if nAwardType == Player.award_type_item and nParamCount == 3 then
			tbItemAward[tbInfo[2]] = tbItemAward[tbInfo[2]] or 0;
			tbItemAward[tbInfo[2]] = tbItemAward[tbInfo[2]] + tbInfo[3];
		elseif nAwardType == Player.award_type_partner and nParamCount == 3 then
			tbPartnerAward[tbInfo[2]] = tbPartnerAward[tbInfo[2]] or 0;
			tbPartnerAward[tbInfo[2]] = tbPartnerAward[tbInfo[2]] + tbInfo[3];
		elseif nAwardType == Player.award_type_money and nParamCount == 2 then
			tbMoneyAward[tbInfo[1]] = tbMoneyAward[tbInfo[1]] or 0;
			tbMoneyAward[tbInfo[1]] = tbMoneyAward[tbInfo[1]] + tbInfo[2];
		elseif nAwardType == Player.award_type_exp and nParamCount == 2 then
			nExp = nExp + tbInfo[2];
		elseif nAwardType == Player.award_type_basic_exp and nParamCount == 2 then
			nBaseExp = nBaseExp + tbInfo[2];
		elseif nAwardType == Player.award_type_kin_found and nParamCount == 2 then
			nKinFound = nKinFound + tbInfo[2];
		elseif nAwardType == Player.award_type_faction_honor then
			nFactionHonor = nFactionHonor + tbInfo[2];
		elseif nAwardType == Player.award_type_battle_honor then
			nBattleHonor = nBattleHonor + tbInfo[2];
		elseif nAwardType ~= Player.award_type_empty then
			table.insert(tbResult, tbInfo);
		end
	end

	for nItemId, nCount in pairs(tbItemAward) do
		table.insert(tbResult, {"item", nItemId, nCount});
	end

	for szType, nCount in pairs(tbMoneyAward) do
		table.insert(tbResult, {szType, nCount});
	end

	for nPartnerId, nCount in pairs(tbPartnerAward) do
		table.insert(tbResult, {"Partner", nPartnerId, nCount});
	end

	if nExp > 0 then
		table.insert(tbResult, {"Exp", nExp});
	end

	if nBaseExp > 0 then
		table.insert(tbResult, {"BasicExp", nBaseExp});
	end

	if nKinFound > 0 then
		table.insert(tbResult, {"KinFound", nKinFound});
	end

	if nFactionHonor > 0 then
		table.insert(tbResult, {"FactionHonor", nFactionHonor});
	end

	if nBattleHonor > 0 then
		table.insert(tbResult, {"BattleHonor", nBattleHonor});
	end

	return tbResult;
end

function KPlayer:FormatAward(pPlayer, tbAward, szFromItemName, nLogReazon, nLogReazon2)
	local tbResult = {};
	local tbAdd2AuctionResult = {}

	for _, tbInfo in pairs(tbAward) do
		local tbRealInfo,tbAdd2AuctionIndex = self:GetRealAward(pPlayer, tbInfo, szFromItemName, nLogReazon, nLogReazon2);
		if tbRealInfo then
			for nIdx,tbInfo in ipairs(tbRealInfo) do
				table.insert(tbResult, tbInfo);
	            if tbAdd2AuctionIndex and tbAdd2AuctionIndex[1] and nIdx == tbAdd2AuctionIndex[1] then
	                table.insert(tbAdd2AuctionResult, #tbResult);
	                table.remove(tbAdd2AuctionIndex, 1);
	            end
			end
		else
			table.insert(tbResult, tbInfo);
		end
	end

	return tbResult,tbAdd2AuctionResult;
end

-- 最好不要直接调用接口，可能会由于一些意外导致这个函数有报错，
-- 但是如果调用此函数之后才进行设置领奖标志或者扣除道具之类的，就会导致给奖励但是不扣道具的情况的出现
function KPlayer:SendAwardUnsafe(nPlayerId, tbAward, bMsg, bShowUi, nLogReazon, nLogReazon2)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return;
	end

	if not tbAward then
		Log("Error SendAward Not Award", pPlayer.szName, pPlayer.dwID);
		return;
	end

	if bMsg or bShowUi then
		pPlayer.CallClientScript("Ui:NotfifyGetAward", tbAward, bMsg, bShowUi, nLogReazon)
	end
	for _, tbItemInfo in ipairs(tbAward) do
		local fnAddAwardFunc = Player:GetAwardFunc(tbItemInfo[1]);
		fnAddAwardFunc(pPlayer, nLogReazon, nLogReazon2, unpack(tbItemInfo))
	end
end

function _LuaPlayer.DropAward(nPosX, nPosY, tbMsg, tbAward, nLogReazon, nLogReazon2, bMsg, bShowUi)
	local tbDirectAward = {};
	local tbAuctionAward = {};
	local tbAllResult = {};
	for _, tbInfo in pairs(tbAward) do
		if tbInfo.bIntoAuction then
			table.insert(tbAuctionAward, {tbInfo[2], tbInfo[3] or 1});
			table.insert(tbAllResult, {tbInfo[1], tbInfo[2], tbInfo[3]});
		else
			table.insert(tbDirectAward, tbInfo);
		end
	end

	tbDirectAward = Lib:CopyTB(tbDirectAward);
	local tbAdd2AuctionIndex
	tbDirectAward,tbAdd2AuctionIndex = KPlayer:FormatAward(self, tbDirectAward, tbMsg and tbMsg.szNpcName or "", nLogReazon, nLogReazon2);

	if tbAdd2AuctionIndex and next(tbAdd2AuctionIndex) then
		tbDirectAward,tbAuctionAward = Kin:FormatAuctionItem(tbDirectAward,tbAdd2AuctionIndex,tbAuctionAward)
	end

	if tbAuctionAward and next(tbAuctionAward) then
		Kin:AddPersonAuction(self.dwID, tbAuctionAward);
	end
	tbAllResult = Lib:MergeTable(tbAllResult, tbDirectAward);
	self.SendAward(tbDirectAward, bMsg, bShowUi, nLogReazon, nLogReazon2);
	self.CallClientScript("Ui:DropAward", nPosX, nPosY, tbAllResult);

	if tbMsg then
		for _, tbInfo in pairs(tbAward) do
			if (tbInfo.nWorldNotify and tbInfo.nWorldNotify > 0) or (tbInfo.nKinNotify and tbInfo.nKinNotify > 0) or (tbInfo.nTeamNotify and tbInfo.nTeamNotify > 0) then
				local tbDsc = Lib:GetAwardDesCount({tbInfo}, self);
				local szDsc = tbDsc[1].szDesc;
				local nItemTemplateId;
				if Player.AwardType[tbInfo[1]] == Player.award_type_item then
					local szName = KItem.GetItemShowInfo(tbInfo[2], self.nFaction);
					szDsc = string.format("<%s>", szName);
					if tbInfo[3] > 1 then
						szDsc = szDsc .. " * " .. tbInfo[3];
					end
					nItemTemplateId = tbInfo[2];
				end

				if tbInfo.nWorldNotify and tbInfo.nWorldNotify > 0 then
					local szMsg = MsgInfoCtrl:GetMsg(tbInfo.nWorldNotify, self.szName, tbMsg.szNpcName, szDsc);
					if nItemTemplateId then
						KPlayer.SendWorldNotify(0, 999, szMsg, 0, 1);
						ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.System, szMsg, nil, {nLinkType = ChatMgr.LinkType.Item, nTemplateId = nItemTemplateId, nFaction = self.nFaction});
					else
						KPlayer.SendWorldNotify(0, 999, szMsg, 1, 1);
					end
				end

				if self.dwKinId > 0 and tbInfo.nKinNotify and tbInfo.nKinNotify > 0 then
					local szMsg = MsgInfoCtrl:GetMsg(tbInfo.nKinNotify, self.szName, tbMsg.szNpcName, szDsc);
					if nItemTemplateId then
						ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.Kin, szMsg, self.dwKinId, {nLinkType = ChatMgr.LinkType.Item, nTemplateId = nItemTemplateId, nFaction = self.nFaction});
					else
						ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.Kin, szMsg, self.dwKinId);
					end
				end

				if self.dwTeamID > 0 and tbInfo.nTeamNotify and tbInfo.nTeamNotify > 0 then
					local szMsg = MsgInfoCtrl:GetMsg(tbInfo.nTeamNotify, self.szName, tbMsg.szNpcName, szDsc);
					if nItemTemplateId then
						ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.Team, szMsg, self.dwTeamID, {nLinkType = ChatMgr.LinkType.Item, nTemplateId = nItemTemplateId, nFaction = self.nFaction})
					else
						ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.Team, szMsg, self.dwTeamID)
					end
				end
			end
		end
	end

	self.OnEvent("OnNpcDrop", tbAllResult);
end

function _LuaPlayer.SetEntryPoint()
	if self.nMapTemplateId <= 0 then
		Log("Error SetEntryPoint!!", self.nMapTemplateId, self.dwID, self.szName);
		return;
	end

	local nMapType = Map:GetMapType(self.nMapTemplateId);
	if nMapType ~= Map.emMap_Public and nMapType ~= Map.emMap_Public_Fuben then
		Log("Error SetEntryPoint", self.nMapTemplateId, self.dwID, self.szName);
		return;
	end

	local bRet = Map:IsForbidTransEnter(self.nMapTemplateId);
	if bRet then
		Log("Error SetEntryPoint IsForbidTransEnter", self.nMapTemplateId, self.dwID, self.szName);
		return;
	end

	local nMapId, nX, nY = self.GetWorldPos();
	local tbEntryPoint = self.GetScriptTable("EntryPoint");

	tbEntryPoint.nMapTemplateId = self.nMapTemplateId;
	tbEntryPoint.nMapId = nMapId;
	tbEntryPoint.nX = nX;
	tbEntryPoint.nY = nY;
end

function _LuaPlayer.GotoEntryPoint()
	local tbEntryPoint = self.GetScriptTable("EntryPoint");
	local nDesMapTemplateId = GetMapInfoById(tbEntryPoint.nMapId or -1);

	if not nDesMapTemplateId or not tbEntryPoint.nMapTemplateId or nDesMapTemplateId ~= tbEntryPoint.nMapTemplateId then
		self.OnEvent("OnGotoEntryPointFail");
		return;
	end

	if Map:IsFieldFightMap(nDesMapTemplateId) then
		tbEntryPoint.nX, tbEntryPoint.nY = Map:GetDefaultPos(nDesMapTemplateId);
	end

	local bRet = self.SwitchMap(tbEntryPoint.nMapId, tbEntryPoint.nX, tbEntryPoint.nY);
	if not bRet then
		self.OnEvent("OnGotoEntryPointFail");
		return;
	end
end

function _LuaPlayer.ConsumeItem(pItem, nCount, nLogReazon, nLogReazon2)
	self = self;
	if nCount <= 0 or pItem.nCount < nCount then
		return 0;
	end

	local nLogReazon = nLogReazon or 0;
	local nLogReazon2 = nLogReazon2 or 0;
	if  nLogReazon == 0 then
		Log(debug.traceback())
	end

	if pItem.nCount > nCount then
		if not pItem.SetCount(pItem.nCount - nCount, nLogReazon, nLogReazon2) then
			return 0;
		end
	else
		pItem.Delete(nLogReazon, nLogReazon2);
	end

	return nCount;
end

function _LuaPlayer.ConsumeItemInAllPos(nItemTemplateId, nNeedCount, nLogReazon, tbHideID)
	local nConsumeCount = 0;
	local nCountInBag, tbItem = self.GetItemCountInAllPos(nItemTemplateId, tbHideID);
	if nCountInBag < nNeedCount then
		return nConsumeCount;
	end

	for _, pItem in pairs(tbItem) do
		if not tbHideID or not tbHideID[pItem.dwId] then
			local nConsume = math.min(pItem.nCount, nNeedCount - nConsumeCount);
			nConsume = self.ConsumeItem(pItem, nConsume, nLogReazon);
			nConsumeCount = nConsumeCount + nConsume;
			if nConsumeCount >= nNeedCount then
				break;
			end
		end
	end

	if nConsumeCount < nNeedCount then
		Log("[player] ConsumeItemInAllPos ERR ?? nConsumeCount < nNeedCount", self.szName, self.dwID, nItemTemplateId, nNeedCount, nConsumeCount);
	end

	return nConsumeCount;
end

function _LuaPlayer.ConsumeItemInBag(nItemTemplateId, nNeedCount, nLogReazon, tbHideID, nLogReazon2)
	local nConsumeCount = 0;
	local nCountInBag, tbItem = self.GetItemCountInBags(nItemTemplateId, tbHideID);
	if nCountInBag < nNeedCount then
		return nConsumeCount;
	end

	for _, pItem in pairs(tbItem) do
		if not tbHideID or not tbHideID[pItem.dwId] then
			local nConsume = math.min(pItem.nCount, nNeedCount - nConsumeCount);
			nConsume = self.ConsumeItem(pItem, nConsume, nLogReazon, nLogReazon2);
			nConsumeCount = nConsumeCount + nConsume;
			if nConsumeCount >= nNeedCount then
				break;
			end
		end
	end

	if nConsumeCount < nNeedCount then
		Log("[player] ConsumeItemInBag ERR ?? nConsumeCount < nNeedCount", self.szName, self.dwID, nItemTemplateId, nNeedCount, nConsumeCount);
	end

	return nConsumeCount;
end

--nTimeout（秒） -1永久 nil是默认配置表的时间, bActive是否激活
function _LuaPlayer.AddTitle(nTitleID, nTimeout, bActive, bShowInfo, szText, bNoTip)
	local bRet = PlayerTitle:AddTitle(self, nTitleID, nTimeout, szText, bNoTip);

	if bRet and bActive then
		self.ActiveTitle(nTitleID, bShowInfo);
    end

    return bRet;
end

function _LuaPlayer.AddTimeTitle(nTitleID, nEndTime, bActive, bShowInfo)
    local nTimeout = nEndTime - GetTime();
    if nTimeout <= 0 and nEndTime ~= 0 then
    	local tbTitleTemp = PlayerTitle:GetTitleTemplate(nTitleID);
    	if tbTitleTemp then
    		self.CenterMsg(string.format("%s稱號已經過期了！", tbTitleTemp.Name));
    	end

    	Log("[Player] AddTimeTitle TimeOut End", self.dwID, nTitleID, nEndTime, nTimeout);
    	return;
    end

    if nTimeout > 0 then
	    self.AddTitle(nTitleID, nTimeout, bActive, bShowInfo);
    else
	    self.AddTitle(nTitleID, nil, bActive, bShowInfo);
    end
end

function _LuaPlayer.ActiveTitle(nTitleID, bShowInfo)
    PlayerTitle:ActiveTitle(self, nTitleID, bShowInfo);
end

--设置显示称号 不存档
function _LuaPlayer.SetShowTitle(nTitleID, szText)
    PlayerTitle:SetShowTitle(self, nTitleID, szText);
end

function _LuaPlayer.ClearShowTitle()
    PlayerTitle:ClearShowTitle(self);
end

function _LuaPlayer.DeleteTitle(nTitleID, bReplace)
    return PlayerTitle:DeleteTitle(self, nTitleID, bReplace);
end

function _LuaPlayer.GetTitleByID(nTitleID)
	local tbSaveData = PlayerTitle:GetPlayerTitleByID(self, nTitleID);
	return tbSaveData;
end

function _LuaPlayer.LockTitle(bLock)
	-- 现在锁定都是暂时的，就不存盘了
	self.bTitileLock = bLock;
	if bLock then
		local tbData = PlayerTitle:GetPlayerTitleData(self);
		return tbData.nActivateTitle
	end
end

function _LuaPlayer.SetOrgCamp(nCamp)
	self.nOrgCamp = nCamp;

	self.RestoreCamp();
end

function _LuaPlayer.RestoreCamp()
	if self.nInBattleState == 1 then
		return;
	end

	local pNpc = self.GetNpc();
	if not pNpc then
		return;
	end

	self.nOrgCamp = self.nOrgCamp or Npc.CampTypeDef.camp_type_player;
	pNpc.SetCamp(self.nOrgCamp);
end

function _LuaPlayer.DoChangeActionMode(nActMode)
	self.ChangeActionMode(nActMode);
    self.CallClientScript("ActionMode:ClientActionMode", nActMode);
    Log("ActionMode ChangeActionMode", self.dwID, nActMode);
end

function _LuaPlayer.AddOrgMoney(szType, nPoint, nLogReazon, nLogReazon2)
	if not Shop.tbMoney[szType] or nPoint <= 0 then
		Log(debug.traceback())
		return;
	end

	local tbMoneyP = Player.tbMoneyTypeAddP[szType];
	if tbMoneyP then
		local bOk, nAddMoneyP = Lib:CallBack({tbMoneyP.fnAddP, self, nPoint, nLogReazon});
		if bOk and nAddMoneyP then
			nPoint = math.floor(nPoint * (nAddMoneyP + 100) / 100);
		end
	end

	if szType == "Contrib" then --获得贡献货币时同时增加累积贡献，目前是绑定一起，不允许其他地方调AddContribution
		local kinMemberData = Kin:GetMemberData(self.dwID);
		if kinMemberData and kinMemberData.nKinId ~= 0 then
			kinMemberData:AddContribution(nPoint, nLogReazon);
		end
	end

	local nKey = Shop.tbMoney[szType]["SaveKey"];
	local nOrgPoint = self.GetUserValue(2, nKey);
	local nSetPoint = ((nOrgPoint + nPoint) < 0) and 0 or (nOrgPoint + nPoint);
	self.SetUserValue(2, nKey, nSetPoint);
	self.CallClientScript("Player:OnChangeMoney", szType, nPoint, nSetPoint);

	nLogReazon2 = nLogReazon2 or 0;
	if not nLogReazon or nLogReazon == 0 then
		Log(debug.traceback())
	end

	self.TLog("MoneyFlow", self.nLevel, 0, nSetPoint - self.GetMoneyDebt(szType), nPoint, nLogReazon, nLogReazon2, 0, nKey)

	self.CheckMoneyDebt(szType)

	if szType == "Gold" and nPoint >= Player.IMMEDIATE_SAVE_GOLD_LINE then
		self.SavePlayer();
	end

	Activity:OnPlayerEvent(self, "Act_OnAddOrgMoney", szType, nPoint, nLogReazon, nLogReazon2)

	return true;
end

function _LuaPlayer.AddMoney(szType, nPoint, nLogReazon, nLogReazon2)
	if Forbid:IsForbidAward(self) then
		Forbid:SendForbidAwardNotice(self)
		return
	end

	if szType == "Gold" and Sdk:IsMsdk() then
		if nPoint <= 0 then
			Log(debug.traceback())
			return false;
		end

		AssistClient:DoPresent(self, nPoint, nLogReazon, nLogReazon2, function (nPlayerId, bSucceed)
			if not bSucceed then
				local tbMail = {
					To = nPlayerId;
					Title = "元寶贈送";
					From = "支付系統";
					Text = "很抱歉，在獲取系統贈送的元寶時, 系統發生異常。 故將元寶以信件附件形式發送給您, 請手動領取。";
					tbAttach = {{"Gold", nPoint}};
					nLogReazon = nLogReazon;
					tbParams = {LogReason2 = nLogReazon2};
				};

				Mail:SendSystemMail(tbMail);
			end
			return true;
		end);
		return true;
	else
		return self.AddOrgMoney(szType, nPoint, nLogReazon, nLogReazon2);
	end
end

function _LuaPlayer.CostOrgMoney(szType, nPoint, nLogReazon, nLogReazon2) --nPrice, nItemCount
	if not Shop.tbMoney[szType] or nPoint <= 0 then
		return;
	end
	local nKey = Shop.tbMoney[szType]["SaveKey"];
	local nOrgPoint = self.GetUserValue(2, nKey);
	if nOrgPoint < nPoint then
		return false;
	end
	local nSetPoint = nOrgPoint - nPoint
	self.SetUserValue(2, nKey, nSetPoint);
	self.CallClientScript("Player:OnChangeMoney", szType);

	nLogReazon2 = nLogReazon2 or 0;

	if not nLogReazon or nLogReazon == 0 then
		Log(debug.traceback())
	end

	self.TLog("MoneyFlow", self.nLevel, 0, nSetPoint - self.GetMoneyDebt(szType), nPoint, nLogReazon, nLogReazon2, 1, nKey)
	return true;
end

--只用于普通货币的扣除, 元宝的消耗请调用CostGold
function _LuaPlayer.CostMoney(szType, nPoint, nLogReazon, nLogReazon2) --nPrice, nItemCount
	assert(not Sdk:IsMsdk() or szType ~= "Gold");
	return self.CostOrgMoney(szType, nPoint, nLogReazon, nLogReazon2);
end

--[[ 消耗元宝必传回调, 回调中注意的处理事项:
0. 在回调当中的C对象必须使用ID重新获取并判空,
1. 注意使用的各个对象是否还存在, 各个前提判断是否依然有效
2. 对于回调回来后玩家已经下线的处理
3. 对于回调回来后 后续 流程失败的处理
4. 异步执行, 注意执行顺序
fnAfterCost(nPlayerId, bCostSucceed, szBilloId, ...);
]]
function _LuaPlayer.CostGold(nPoint, nLogReazon, nLogReazon2, fnAfterCost, ...)
	assert(fnAfterCost, "fnAfterCost is necessary");

	if Sdk:IsMsdk() then
		AssistClient:DoPay(self, nPoint, nLogReazon, nLogReazon2 or 0, fnAfterCost, ...);
	else
		AssistClient:DoLocalPay(self, nPoint, nLogReazon, nLogReazon2 or 0, fnAfterCost, ...);
	end
	return true;
end

-- 设置当前托管元宝数, 由米大师托管的金币的本地副本
function _LuaPlayer.SetGold(nGold, nLogReazon, nLogReazon2)
	if not nGold or type(nGold) ~= "number" then
		Log("SetGold ERROR", nGold);
		Log(debug.traceback());
		return false;
	end

	local nKey = Shop.tbMoney["Gold"]["SaveKey"];
	local nOrgGold = self.GetUserValue(2, nKey);
	if nGold == nOrgGold then
		return false;
	end

	self.SetUserValue(2, nKey, nGold);
	self.CallClientScript("Player:OnChangeMoney", "Gold");
	local nChangeGold = nGold - nOrgGold;
	local AddOrReduce = 0;
	if nChangeGold < 0 then
		AddOrReduce = 1;
		nChangeGold = - nChangeGold
	end

	self.TLog("MoneyFlow", self.nLevel, 0, nGold - self.GetMoneyDebt("Gold"), nChangeGold , nLogReazon, nLogReazon2 or 0, AddOrReduce, nKey);
	AssistClient:ReportQQScore(self, Env.QQReport_Gold, nGold, 0, 1);

	self.CheckMoneyDebt("Gold")

	-- 消耗操作的立即存盘在外部处理了..
	if AddOrReduce == 0 and nChangeGold >= Player.IMMEDIATE_SAVE_GOLD_LINE then
		self.SavePlayer();
	end

	return true;
end

function _LuaPlayer.AddMoneyDebt(szType, nPoint, nLogReazon, nLogReazon2)
	if not Shop.tbMoney[szType] or nPoint <= 0 then
		Log(debug.traceback())
		return;
	end

	local nKey = Shop.tbMoney[szType]["DebtSaveKey"];
	local nOrgPoint = self.GetUserValue(Shop.MONEY_DEBT_GROUP, nKey);
	local nSetPoint = ((nOrgPoint + nPoint) < 0) and 0 or (nOrgPoint + nPoint);
	self.SetUserValue(Shop.MONEY_DEBT_GROUP, nKey, nSetPoint);

	nLogReazon2 = nLogReazon2 or 0;
	if not nLogReazon or nLogReazon == 0 then
		Log(debug.traceback())
	end

	self.TLog("MoneyDebtFlow", self.nLevel, 0, nSetPoint, nPoint, nLogReazon, nLogReazon2, 0, nKey)

	if szType == "Gold" and nPoint >= Player.IMMEDIATE_SAVE_GOLD_LINE then
		self.SavePlayer();
	end

	Player:CheckMoneyDebtBuff(self)
	Player:CheckMoneyDebtStartTime(self);

	self.CallClientScript("Player:OnMoneyDebtAdd", szType, nSetPoint)

	return true;
end

function _LuaPlayer.CostMoneyDebt(szType, nPoint, nLogReazon, nLogReazon2)
	if not Shop.tbMoney[szType] or nPoint <= 0 then
		Log(debug.traceback())
		return;
	end
	local nKey = Shop.tbMoney[szType]["SaveKey"];
	local nOrgPoint = self.GetUserValue(Shop.MONEY_DEBT_GROUP, nKey);
	if nOrgPoint < nPoint then
		Log(debug.traceback())
		return false;
	end
	local nSetPoint = nOrgPoint - nPoint
	self.SetUserValue(Shop.MONEY_DEBT_GROUP, nKey, nSetPoint);

	nLogReazon2 = nLogReazon2 or 0;

	if not nLogReazon or nLogReazon == 0 then
		Log(debug.traceback())
	end

	self.TLog("MoneyDebtFlow", self.nLevel, 0, nSetPoint, nPoint, nLogReazon, nLogReazon2, 1, nKey)

	Player:CheckMoneyDebtBuff(self)
	Player:CheckMoneyDebtStartTime(self);

	self.CallClientScript("Player:OnMoneyDebtCost", szType, nPoint)

	return true;
end

function _LuaPlayer.CheckMoneyDebt(szType)
	local nCurDebt = self.GetMoneyDebt(szType);
	if nCurDebt <= 0 then
		return
	end

	local nCur = self.GetMoney(szType);

	if not nCur or nCur <= 0 then
		return
	end

	local nNeedCost = math.min(nCurDebt, nCur);

	if not self.CostMoneyDebt(szType, nNeedCost, Env.LogWay_Money_Debt_Cost) then
		Log(debug.traceback())
	end

	local function fnAfterCost(nPlayerId, bSuccess, szBillNo, bNeedCheck)
		if not bSuccess then
			Player:AddMoneyDebt(nPlayerId, "Gold", nNeedCost, Env.LogWay_Money_Debt_Add, 0, bNeedCheck)
		end
	end

	if szType == "Gold" then
		self.CostGold(nNeedCost, Env.LogWay_Money_Debt_Cost, nil, function (nPlayerId, bSuccess, szBillNo, bNeedCheck)
			fnAfterCost(nPlayerId, bSuccess, szBillNo, bNeedCheck)
			return true;
		end, true);

	else
		local bRet = self.CostMoney(szType, nNeedCost, Env.LogWay_Money_Debt_Cost)
		fnAfterCost(self.dwID, bRet)
	end
end

function _LuaPlayer.SetQQVipInfo(nVipBegin, nVipEnd, nSVipBegin, nSVipEnd)
	local nOrgVipEndTime = self.GetUserValue(Player.QQ_VIPINFO_SAVEGROUP, Player.QQ_VIPINFO_VIP_END);
	local nOrgSVipEndTime = self.GetUserValue(Player.QQ_VIPINFO_SAVEGROUP, Player.QQ_VIPINFO_SVIP_END);
	if nVipEnd == nOrgVipEndTime and nSVipEnd == nOrgSVipEndTime then
		return false;
	end

	local nLastOpenMonth = self.GetUserValue(Sdk.Def.TX_VIP_SAVEGROUP, Sdk.Def.TX_VIP_OPEN_MONTH);
	if nLastOpenMonth == -1 then
		local nThisMonth = Lib:GetLocalMonth();
		self.SetUserValue(Sdk.Def.TX_VIP_SAVEGROUP, Sdk.Def.TX_VIP_OPEN_MONTH, nThisMonth);

		if nSVipEnd ~= nOrgSVipEndTime then
			self.SetUserValue(Sdk.Def.TX_VIP_SAVEGROUP, Sdk.Def.TX_VIP_LATEST_OPEN_VIP, Player.QQVIP_SVIP);
		elseif nVipEnd ~= nOrgVipEndTime then
			self.SetUserValue(Sdk.Def.TX_VIP_SAVEGROUP, Sdk.Def.TX_VIP_LATEST_OPEN_VIP, Player.QQVIP_VIP);
		end
	end

	self.SetUserValue(Player.QQ_VIPINFO_SAVEGROUP, Player.QQ_VIPINFO_VIP_BEGIN, nVipBegin);
	self.SetUserValue(Player.QQ_VIPINFO_SAVEGROUP, Player.QQ_VIPINFO_VIP_END, nVipEnd);
	self.SetUserValue(Player.QQ_VIPINFO_SAVEGROUP, Player.QQ_VIPINFO_SVIP_BEGIN, nSVipBegin);
	self.SetUserValue(Player.QQ_VIPINFO_SAVEGROUP, Player.QQ_VIPINFO_SVIP_END, nSVipEnd);

	self.CallClientScript("Sdk:OnQQVipChanged");
	return true;
end

function _LuaPlayer.CallClientScript(szFunction, ...)
	local nFuncId = s2c.func2id[szFunction]
	if nFuncId then
		return self.CallClientScriptByFuncId(nFuncId, ...);
	else
		return self.CallClientScriptByFuncName(szFunction, ...);
	end
end

function _LuaPlayer.GetMsdkInfo()
	if not Sdk:IsMsdk() then
		return {};
	end

	if not self.tbMsdkInfo then
		if Lib:IsEmptyStr(self.szMsdkJsonInfo) then
			return {};
		end

		local bOK, tbMsdkInfo = pcall(Lib.DecodeJson, Lib, self.szMsdkJsonInfo);
		if not bOK or not Sdk:CheckMsdkTypeInfo(tbMsdkInfo) then
			Log("GetMsdkInfo Error:", self.szMsdkJsonInfo);
			tbMsdkInfo = {};
		end
		self.tbMsdkInfo = tbMsdkInfo or {};
	end
	return self.tbMsdkInfo;
end

function _LuaPlayer.SetMsdkInfo(tbMsdkInfo)
	if not Sdk:CheckMsdkTypeInfo(tbMsdkInfo) then
		Log(debug.traceback());
		Lib:Tree(tbMsdkInfo or {});
		return;
	end

	self.tbMsdkInfo = tbMsdkInfo;
end

function _LuaPlayer.AddExperience(nExp, nLogReason)
	local pNpc = self.GetNpc();
	if pNpc then
		nExp = math.floor(nExp * (100 + pNpc.nAddAllExpP) / 100);
	end

	if Forbid:IsForbidAward(self) then
		Forbid:SendForbidAwardNotice(self)
	else
		local nTrueExp = self.AddExp(nExp, nLogReason)
		Lib:CallBack({Player.OnPlayerAddExp, Player, self, nExp, nTrueExp});
	end
end

function _LuaPlayer.SetLaunchPlatform(nLaunchPlatform)
	if not nLaunchPlatform then
		return false;
	end

	local nToday = Lib:GetLocalDay();
	self.SetUserValue(Player.TX_LAUNCH_SAVE_GROUP, Player.TX_LAUNCH_PRIVILEGE_TYPE, nLaunchPlatform);
	self.SetUserValue(Player.TX_LAUNCH_SAVE_GROUP, Player.TX_LAUNCH_PRIVILEGE_DAY, nToday);
	return true;
end

function _LuaPlayer.SetFightPartnerID(nPartnerId)
	if nPartnerId ~= 0 then
		local tbPartner = self.GetPartnerInfo(nPartnerId);
	    if not tbPartner then
	    	return;
	    end	
	end

    self.SetUserValue(Partner.nSavePKFightGroup, Partner.nSavePKFightID, nPartnerId);
end

function _LuaPlayer.TLogRoundFlow(nBattleType, nBattleID, nScore, nRoundTime, nResult, nRank, nGold)
	self.TLog("RoundFlow", nBattleType, nBattleID, nScore, nRoundTime,nResult, nRank, nGold, self.nLevel, Sdk.tbPCVersionChannelNums[self.nChannelCode] and 1 or 0);
end
