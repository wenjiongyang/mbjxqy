-- 用于接收upvalue
local self;

function _LuaPlayer.CenterMsg(szMsg, bSysMsg, nSysMsgType)
	self.CallClientScript("Ui:AddCenterMsg", szMsg, bSysMsg, nSysMsgType);
end

function _LuaPlayer.SendBlackBoardMsg(szMsg, bSysMsg)
	self.CallClientScript("Ui:ShowBlackMsg", szMsg, bSysMsg);
end

function _LuaPlayer.MsgBox(szMsg, tbCallback, szNotTipsType, nTime, fnTimeOut)
	GameSetting:SetGlobalObj(self, him, it);
	Dialog:MsgBox(szMsg, tbCallback, szNotTipsType, nTime, fnTimeOut);
	GameSetting:RestoreGlobalObj()
end

-- 设置临时复活点
function _LuaPlayer.SetTempRevivePos(nMapId, nX, nY, nFightMode)
	self._TempRevivePos = {nMapId, nX, nY};
	self._TempReviveFightMode = nFightMode;
end

function _LuaPlayer.ClearTempRevivePos()
	self._TempRevivePos = nil;
	self._TempReviveFightMode = nil;
end

function _LuaPlayer.GetTempRevivePos()
	if not self._TempRevivePos or #self._TempRevivePos ~= 3 then
		return nil;
	end

	local nMapId, nX, nY = unpack(self._TempRevivePos);

	return nMapId, nX, nY, self._TempReviveFightMode;
end

function _LuaPlayer.SetDefaultDeathDisable(bDisable)
	self._bDefaultDeathDisable = bDisable;
end

function _LuaPlayer.OnEvent(szEventType, ...)
	self = self;

	GameSetting:SetGlobalObj(self, him, it);
	PlayerEvent:OnEvent(szEventType, ...);
	GameSetting:RestoreGlobalObj()
end

function _LuaPlayer.CheckNeedArrangeBag()
	local nCurCount = self.GetBagUsedCount();
	return nCurCount >= (GameSetting.MAX_COUNT_IN_BAG + Item:GetExtBagCount(self));
end

function _LuaPlayer.GetFreeBagCount()
	return GameSetting.MAX_COUNT_IN_BAG - self.GetBagUsedCount() + Item:GetExtBagCount(self);
end

function _LuaPlayer.GetItemCountInAllPos(nItemTemplateId, tbHideID)
	local tbItem = self.FindItemInPlayer(nItemTemplateId);
	if not tbItem then
		return 0, {};
	end

	local tbGetItem = {};
	local nCount = 0;
	for _, pItem in pairs(tbItem) do
		if not tbHideID or not tbHideID[pItem.dwId] then
			nCount = nCount + pItem.nCount;
			table.insert(tbGetItem, pItem);
		end
	end

	return nCount, tbGetItem;
end

function _LuaPlayer.GetItemCountInBags(nItemTemplateId, tbHideID)
	local tbItem = self.FindItemInBag(nItemTemplateId);
	if not tbItem then
		return 0, {};
	end

	local tbGetItem = {};
	local nCount = 0;
	for _, pItem in pairs(tbItem) do
		if pItem.nPos == Item.emITEMPOS_BAG then
			if not tbHideID or not tbHideID[pItem.dwId] then
				nCount = nCount + pItem.nCount;
				table.insert(tbGetItem, pItem);
			end
		end
	end

	return nCount, tbGetItem;
end

function _LuaPlayer.CallClientScriptWhithPlayer(...)
	self.CallClientScript("Client:CallClientScriptWhithPlayer", ...);
end

function _LuaPlayer.GetMoney(szType)
	if not Shop.tbMoney[szType] then
		return;
	end
	local nKey = Shop.tbMoney[szType]["SaveKey"];
	local nMoney = self.GetUserValue(2, nKey);

	return nMoney;
end

function _LuaPlayer.GetMoneyDebt(szType)
	if not Shop.tbMoney[szType] then
		return 0;
	end
	local nKey = Shop.tbMoney[szType]["DebtSaveKey"];
	local nMoney = self.GetUserValue(Shop.MONEY_DEBT_GROUP, nKey);

	return nMoney;
end

function _LuaPlayer.GetShouldHaveMoney(szType)
	local nCur = self.GetMoney(szType)
	local nDebt = self.GetMoneyDebt(szType)
	return nCur - nDebt
end

function _LuaPlayer.GetPartnerFamiliar(nId)
	return ValueItem:GetValue(self, "PartnerFamiliar", nId);
end

function _LuaPlayer.GetAllPartnerFamiliar()
	return ValueItem:GetAllValue(self, "PartnerFamiliar");
end


function _LuaPlayer.CanTeamOpt()
	if self.bForbidTeamOp then 					-- 目前只有上擂台才会赋值
		return
	end
	local tbMapSetting = Map:GetMapSetting(self.nMapTemplateId)
	return (tbMapSetting.TeamForbidden ~= TeamMgr.forbidden_make_and_operation_team and tbMapSetting.TeamForbidden ~= TeamMgr.forbidden_operation_team_in_client);
end

function _LuaPlayer.CanTranOpt()
	local tbMapSetting = Map:GetMapSetting(self.nMapTemplateId)
	return tbMapSetting.TransForbidden ~= 1
end

function _LuaPlayer.GetVipLevel(bNew) --目前只有充值改变时才传bNew
	if bNew then
		self.nVipLevel = nil;
	end
	if not self.nVipLevel then
		self.nVipLevel = 0;
		local nTotalCharge = Recharge:GetTotoalRecharge(self)
		for i, v in ipairs(Recharge.tbVipSetting) do
			local szTimeFrameNeed = Recharge.tbVipTimeFrameSetting[i]
			if szTimeFrameNeed and  GetTimeFrameState(szTimeFrameNeed) ~= 1 then
				break;
			end

			if nTotalCharge >= v then
				self.nVipLevel = i;
			else
				break;
			end
		end
	end
	return self.nVipLevel
end

function _LuaPlayer.IsInGuaJiMap()
	local nMapTemplateId = self.nMapTemplateId

	local szMapClass = Map:GetClassDesc(nMapTemplateId)

	return szMapClass=="fight" or ImperialTomb:IsTombMap(nMapTemplateId)
end

function _LuaPlayer.GetQQVipInfo()
	local nNow = GetTime();
	if nNow <= self.GetUserValue(Player.QQ_VIPINFO_SAVEGROUP, Player.QQ_VIPINFO_SVIP_END) then
		return Player.QQVIP_SVIP, Player.QQVIP_SVIP_AWARD_RATE;
	end

	if nNow <= self.GetUserValue(Player.QQ_VIPINFO_SAVEGROUP, Player.QQ_VIPINFO_VIP_END) then
		return Player.QQVIP_VIP, Player.QQVIP_VIP_AWARD_RATE;
	end

	return Player.QQVIP_NONE, 0;
end

function _LuaPlayer.GetLaunchedPlatform()
	local nLaunchPlatform = self.GetUserValue(Player.TX_LAUNCH_SAVE_GROUP, Player.TX_LAUNCH_PRIVILEGE_TYPE);
	if nLaunchPlatform == Sdk.ePlatform_None then
		return nLaunchPlatform;
	end

	local nToday = Lib:GetLocalDay();
	local nLaunchDay = self.GetUserValue(Player.TX_LAUNCH_SAVE_GROUP, Player.TX_LAUNCH_PRIVILEGE_DAY);
	if nToday ~= nLaunchDay then
		return Sdk.ePlatform_None;
	end
	return nLaunchPlatform;
end

function _LuaPlayer.GetFightPartnerID()
    local bFindPartnerID = true;
    local nFightPartnerID = self.GetUserValue(Partner.nSavePKFightGroup, Partner.nSavePKFightID);
    if nFightPartnerID > 0 then
    	local tbPartner = self.GetPartnerInfo(nFightPartnerID);
    	if tbPartner then
    		bFindPartnerID = false;
    	end
    end

    if bFindPartnerID then
    	local tbPos = self.GetPartnerPosInfo();
    	for _, nPartnerID in ipairs(tbPos) do
    		if nPartnerID > 0 then
    			nFightPartnerID = nPartnerID;
    			break;
    		end
    	end
    end

    return nFightPartnerID or 0;
end


function _LuaPlayer.GetLastLoginTime()
	return self.GetUserValue(Player.SAVE_GROUP_LOGIN, Player.SAVE_KEY_LoginTime)
end