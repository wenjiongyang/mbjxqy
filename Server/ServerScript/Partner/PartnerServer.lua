
Require("CommonScript/Partner/PartnerCommon.lua");

function Partner:SetPartnerPos(pPlayer, tbPosInfo)
	if not tbPosInfo then
		return;
	end

	for nIdx in pairs(tbPosInfo) do
		if self.tbPosNeedLevel[nIdx] > pPlayer.nLevel then
			tbPosInfo[nIdx] = 0;
		end
	end

	pPlayer.SetPartnerPos(tbPosInfo);

	local tbPos = pPlayer.GetPartnerPosInfo();
	local tbAllPartner = pPlayer.GetAllPartner();
	local bAllPartner = true;
	local bAllSPartner = true;
	local bUseParner = false;
	for _, nPartnerId in pairs(tbPos or {}) do
		local tbPartner = tbAllPartner[nPartnerId];
		if not tbPartner then
			bAllPartner = false;
			bAllSPartner = false;
			break;
		end

		bUseParner = true;

		if tbPartner.nQualityLevel > 3 then
			bAllSPartner = false;
		end
	end

	if bUseParner then
		Task:OnTaskExtInfo(pPlayer, Task.ExtInfo_ShangZhenTongBan);
	end

	if bAllPartner then
		Achievement:AddCount(me, "Partner_3", 1);
	end

	if bAllSPartner then
		Achievement:AddCount(me, "Partner_5", 1);
	end
	JingMai:UpdatePlayerAttrib(pPlayer);
	FightPower:ChangeFightPower("JingMai", pPlayer);
end

function Partner:BatchUseProtentialItem(pPlayer, nPartnerId, nProtentialType, nUseCount)
	if self:CheckNeedConfirmReinit(pPlayer, nPartnerId) then
		pPlayer.CenterMsg("請先選擇洗髓結果");
		return;
	end

	local szShowMsg;
	nUseCount = math.max(nUseCount or 1, 1);

	local nAllAddValue = 0;
	local nCurUseCount = 0;
	for i = 1, nUseCount do
		local bRet, szMsg = self:CheckCanUseProtentialItem(pPlayer, nPartnerId, nProtentialType);
		if i == 1 and not bRet then
			szShowMsg = szMsg;
		end

		if not bRet then
			break;
		end

		nAllAddValue = nAllAddValue + (self:UseProtentialItem(pPlayer, nPartnerId, nProtentialType) or 0);
		nCurUseCount = nCurUseCount + 1;
	end

	if not szShowMsg then
		szShowMsg = string.format("消耗了[FFFE0D]%s[-]個資質丹，[FFFE0D]%s[-]增加了[FFFE0D]%s[-]", nCurUseCount, self.tbProtentialName[nProtentialType], nAllAddValue);
	end

	pPlayer.CenterMsg(szShowMsg);
	Lib:CallBack({JingMai.OnUsePartnerProtentialItem, JingMai, pPlayer, nCurUseCount});
end

function Partner:UseProtentialItem(pPlayer, nPartnerId, nProtentialType)
	local bRet, szMsg, nType, nProtential, pItem, pPartner, nQualityLevel = self:CheckCanUseProtentialItem(pPlayer, nPartnerId, nProtentialType);
	if not bRet then
		pPlayer.CenterMsg(szMsg);
		return;
	end

	if self:CheckNeedConfirmReinit(pPlayer, nPartnerId) then
		pPlayer.CenterMsg("請先選擇洗髓結果");
		return;
	end

	local nCount = pPlayer.ConsumeItem(pItem, 1, Env.LogWay_PartnerUseProtentialItem);
	if nCount <= 0 then
		pPlayer.CenterMsg("消耗道具失敗！");
		return;
	end

	local nValue, nOrgValue = self:RandomProtentialItemValue();
	local nResultProtential = nValue + nProtential;
	pPartner.SetProtential(nProtentialType, nResultProtential);

	local nOldUseProValue = pPartner.GetUseProtentialItemValue();
	pPartner.SetUseProtentialItemValue(nOldUseProValue + nOrgValue);
	pPartner.TLog(self.TLOG_DEF_PARTNER_USE_PROTENTIAL_ITEM, Env.LogWay_PartnerUseProtentialItem);

	local nAddValue = math.floor(nResultProtential / self.tbProtentialToValue[nQualityLevel]) - math.floor(nProtential / self.tbProtentialToValue[nQualityLevel]);
	--pPlayer.CenterMsg(string.format("%s潜能增加了%s点", self.tbProtentialName[nProtentialType], nAddValue));
	Task:OnTaskExtInfo(pPlayer, Task.ExtInfo_TiShengZiZhi);
	Log("[Partner] UseProtentialItem ", pPlayer.dwID, pPlayer.szAccount, pPlayer.szName, pItem.dwTemplateId, pPartner.nTemplateId, pPartner.szName, nProtentialType, nValue, nProtential, nResultProtential);
	return nAddValue;
end

function Partner:CheckReinitResult(pPlayer, bNotShowData)
	local tbData = pPlayer.GetScriptTable("Partner");
	if tbData and tbData.tbData then
		local pPartner = pPlayer.GetPartnerObj(tbData.nPartnerId);
		if not pPartner then
			tbData.tbData = nil;
			tbData.tbAward = nil;
			tbData.nPartnerId = nil;
		end
	end

	if bNotShowData then
		pPlayer.CallClientScript("Partner:SyncHasReinitData", (tbData and tbData.tbData) and true or false);
		return;
	end

	if tbData and tbData.tbData then
		pPlayer.CallClientScript("Ui:OpenWindow", "PartnerReInitPanel", {nPartnerId = tbData.nPartnerId, tbData = tbData.tbData});
		return true;
	end

	pPlayer.CallClientScript("Partner:SyncHasReinitData", false);
	return;
end

function Partner:GradeLevelup(pPlayer, nPartnerId)
	local bRet, szMsg, pPartner, nDstLevel = self:CheckCanGradeLevelup(pPlayer, nPartnerId);
	if not bRet then
		pPlayer.CenterMsg(szMsg);
		pPlayer.SyncPartner(nPartnerId);
		return;
	end

	pPartner.SetGradeLevel(nDstLevel);
	pPlayer.CallClientScript("Partner:OnGradeLevelup", nPartnerId, nDstLevel);
end

function Partner:CheckNeedConfirmReinit(pPlayer, nPartnerId)
	local tbData = pPlayer.GetScriptTable("Partner");
	if tbData.nPartnerId and tbData.nPartnerId == nPartnerId then
		return true;
	end

	return false;
end

function Partner:ReInitPartner(pPlayer, nPartnerId)
	local bHasPartnerData = self:CheckReinitResult(pPlayer);
	if bHasPartnerData then
		return;
	end

	local bRet, szMsg, pPartner, nCost, tbAward, nQualityLevel, nUseItemProtentialValue = self:CheckReinitPartner(pPlayer, nPartnerId);
	if not bRet then
		pPlayer.CenterMsg(szMsg);
		return;
	end

	local nRet = pPlayer.ConsumeItemInAllPos(self.nSeveranceItemId, nCost, Env.LogWay_PartnerReInit);
	if nRet ~= nCost then
		pPlayer.CenterMsg("扣除道具失敗！");
		Log("[Partner] ReInitPartner ERR Cost Item Fail !! ", self.nSeveranceItemId, nCost, nRet);
		return;
	end

	local tbData = pPlayer.GetScriptTable("Partner");
	tbData.nPartnerId = nPartnerId;
	tbData.tbRandomCount = tbData.tbRandomCount or {};
	tbData.tbRandomCount[nQualityLevel] = tbData.tbRandomCount[nQualityLevel] or {1, 1}
	tbData.nUseItemProtentialValue = nUseItemProtentialValue;

	local nType = self.PARTNER_TYPE_NORMAL;
	if tbData.tbRandomCount[nQualityLevel][1] >= self.nMaxRandomBYCount then
		nType = self.PARTNER_TYPE_BY;
	elseif tbData.tbRandomCount[nQualityLevel][2] >= self.nMaxRandomGoodCount then
		nType = self.PARTNER_TYPE_GOOD;
	end

	local nNeed = Player:GetRewardValueDebt(pPlayer.dwID);
	if nNeed and nNeed > 0 then
		local nReInitCost = self:GetReInitCostToGold(pPartner.nTemplateId);
		if nReInitCost and nReInitCost > 0 then
			nType = Partner.PARTNER_TYPE_DEBT;
			Player:CostRewardValueDebt(pPlayer.dwID, nReInitCost, Env.LogWay_PartnerReInit);
		end
	end

	tbData.tbData, nType = self:RandomAll(pPartner.nTemplateId, nType);

	if nType ~= self.PARTNER_TYPE_DEBT then
		if nType == self.PARTNER_TYPE_BY then
			tbData.tbRandomCount[nQualityLevel][1] = 1;
		elseif nType == self.PARTNER_TYPE_GOOD then
			tbData.tbRandomCount[nQualityLevel][2] = 1;
			tbData.tbRandomCount[nQualityLevel][1] = tbData.tbRandomCount[nQualityLevel][1] + 1;
		else
			tbData.tbRandomCount[nQualityLevel][1] = tbData.tbRandomCount[nQualityLevel][1] + 1;
			tbData.tbRandomCount[nQualityLevel][2] = tbData.tbRandomCount[nQualityLevel][2] + 1;
		end
	end

	local nLevel, nExp = pPartner.GetLevelInfo();
	tbData.tbData.nLevel = nLevel;
	tbData.tbData.nExp = nExp;
	tbData.tbData.nGradeLevel = pPartner.GetGradeLevel();
	tbData.tbData.nWeaponState = pPartner.nWeaponState;
	tbData.tbData.nAwareness = Partner:GetPartnerAwareness(pPlayer, pPartner.nTemplateId);
	tbData.tbAward = tbAward;

	pPlayer.CenterMsg(string.format("洗髓成功，消耗了%s個洗髓丹", nCost));
	self:CheckReinitResult(pPlayer);

	-- S 级及以上同伴进行洗髓后立即存盘
	if nQualityLevel <= 3 then
		pPlayer.SavePlayer();
	end

	SummerGift:OnJoinAct(pPlayer, "PartnerRefinement")
	Log("[Partner] ReInitPartner ", pPlayer.dwID, pPlayer.szAccount, pPlayer.szName, pPartner.nTemplateId, pPartner.szName);
end

function Partner:ReInitPartnerConfirm(pPlayer, nPartnerId, bUseOrg)
	local tbPartnerData = pPlayer.GetScriptTable("Partner");
	local nOrgId = tbPartnerData.nPartnerId;
	local tbData = tbPartnerData.tbData;
	local tbAward = tbPartnerData.tbAward;

	tbPartnerData.tbData = nil;
	tbPartnerData.tbAward = nil;
	tbPartnerData.nPartnerId = nil;

	if bUseOrg then
		return;
	end

	if not nOrgId or not tbData or nOrgId ~= nPartnerId then
		pPlayer.CenterMsg("數據超時");
		return;
	end

	local pPartner = pPlayer.GetPartnerObj(nPartnerId);
	if not pPartner then
		pPlayer.CenterMsg("同伴不存在");
		return;
	end

	if tbAward then
		pPlayer.SendAward(tbAward, false, true, Env.LogWay_PartnerReInit);
	end

	tbData.nAwareness = Partner:GetPartnerAwareness(pPlayer, pPartner.nTemplateId);
	pPartner.SetSkillValue(self.INT_VALUE_USE_SKILL_BOOK, 0);
	pPartner.SetSkillValue(self.INT_VALUE_SKILL_ORG_VALUE, 0);
	pPartner.SetUseProtentialItemValue(0);
	self:SetPartnerData(pPartner, tbData);
	pPartner.Update();
	pPartner.TLog(self.TLOG_DEF_PARTNER_REINIT, Env.LogWay_PartnerReInit);

	pPlayer.SyncPartner(nPartnerId);
	pPlayer.CenterMsg("替換成功");
	Lib:CallBack({JingMai.OnGetProtentialItemByPartner, JingMai, pPlayer, tbPartnerData.nUseItemProtentialValue});
end

function Partner:DecomposePartner(pPlayer, tbPartnerList)
	local bRet, szMsg, tbAward, szLogInfo, nUseItemProtentialValue = self:CheckCanDecomposePartner(pPlayer, tbPartnerList);
	if not bRet then
		pPlayer.CenterMsg(szMsg);
		return;
	end

	for nPartnerId in pairs(tbPartnerList) do
		pPlayer.DeletePartner(nPartnerId, Env.LogWay_DecomposePartner);
	end

	pPlayer.SendAward(tbAward, false, true, Env.LogWay_DecomposePartner);
	Lib:CallBack({JingMai.OnGetProtentialItemByPartner, JingMai, pPlayer, nUseItemProtentialValue});
	Log("[Partner] DecomposePartner ", pPlayer.dwID, pPlayer.szAccount, pPlayer.szName, szLogInfo);
end

function Partner:UseSkillBook(pPlayer, nPartnerId, nItemId, nPos)
	local pPartner = pPlayer.GetPartnerObj(nPartnerId);
	local bRet, szMsg, tbParam, nMustPos, tbAllowInfo, nValue = self:CheckCanUseSkillBook(pPlayer, nPartnerId, nItemId);
	if not bRet then
		pPlayer.CenterMsg(szMsg);
		return;
	end

	if self:CheckNeedConfirmReinit(pPlayer, nPartnerId) then
		pPlayer.CenterMsg("請先選擇洗髓結果");
		return;
	end

	local szName = tbParam.szName;
	local nTemplateId = tbParam.nTemplateId;
	local pItem = tbParam.pItem;
	local nSkillId = tbParam.nSkillId;

	if nMustPos and nMustPos > 0 and nMustPos ~= nPos then
		return;
	end

	if nMustPos and nMustPos <= 0 and not tbAllowInfo[nPos] then
		return;
	end

	local nRet = pPlayer.ConsumeItem(pItem, 1, Env.LogWay_PartnerUseSkillBook);
	if nRet ~= 1 then
		Log("[Partner] UseSkillBook ConsumeItem Fail !!", pPlayer.dwID, pPlayer.szAccount, pPlayer.szName, pItem.dwTemplateId, nTemplateId, szName, nPos);
		return;
	end

	local nOldUseSBValue = pPartner.GetSkillValue(self.INT_VALUE_USE_SKILL_BOOK);
	if nOldUseSBValue <= 0 then
		local tbSkillInfo = {};
		for i = 1, 5 do
			local nSkillId, nSkillLevel = pPartner.GetSkillInfo(i);
			if nSkillId > 0 then
				tbSkillInfo[nSkillId] = math.max(nSkillLevel, 1);
			end
		end
		local nSkillValue = self:GetSkillValue(tbSkillInfo);
		pPartner.SetSkillValue(self.INT_VALUE_SKILL_ORG_VALUE, nSkillValue);
	end

	Task:OnTaskExtInfo(pPlayer, Task.ExtInfo_TongBanDaShu);
	bRet = pPlayer.SetPartnerSkill(nPartnerId, nPos, nSkillId);
	if not bRet then
		Log("[Partner] UseSkillBook SetPartnerSkill Fail !!", pPlayer.dwID, pPlayer.szAccount, pPlayer.szName, pItem.dwTemplateId, nTemplateId, szName, nPos);
		return;
	end

	pPartner.SetSkillValue(self.INT_VALUE_USE_SKILL_BOOK, nOldUseSBValue + nValue);
	pPartner.TLog(self.TLOG_DEF_PARTNER_USE_SKILL_BOOK, Env.LogWay_PartnerUseSkillBook);

	local _, szSkillName = FightSkill:GetSkillShowInfo(nSkillId);
	pPlayer.CenterMsg(string.format("「%s」學會了%s", pPartner.szName, szSkillName));
	Log("[Partner] UseSkillBook ", pPlayer.dwID, pPlayer.szAccount, pPlayer.szName, pItem.dwTemplateId, nTemplateId, szName, nPos);
end

function Partner:DoUseExpItem(pPlayer, nPartnerId, nItemTemplateId, nUseCount)
	nUseCount = nUseCount or 1;
	if nUseCount <= 0 then
		return;
	end

	if self:CheckNeedConfirmReinit(pPlayer, nPartnerId) then
		pPlayer.CenterMsg("請先選擇洗髓結果");
		return;
	end

	local pPartner = pPlayer.GetPartnerObj(nPartnerId);
	if not pPartner or pPartner.nLevel >= pPlayer.nLevel then
		pPlayer.CenterMsg("目前同伴等級已達上限，無法使用！");
		return;
	end

	if pPartner.nLevel >= self.MAX_LEVEL then
		pPlayer.CenterMsg("目前同伴已滿級");
		return;
	end

	local _, nQualityLevel = GetOnePartnerBaseInfo(pPartner.nTemplateId);
	local tbItemClass = Item:GetClass("PartnerExpItem");
	local nBaseExp = tbItemClass:GetExpInfo(0, nItemTemplateId, me);
	if not nBaseExp or nBaseExp <= 0 then
		pPlayer.CenterMsg("無效道具，無法使用！");
		return;
	end

	local nItemCount = pPlayer.GetItemCountInAllPos(nItemTemplateId);
	if nItemCount <= 0 then
		pPlayer.CenterMsg("道具使用完畢!");
		return;
	end

	nUseCount = math.min(nUseCount, nItemCount);

	for i = 1, nUseCount do
		local nCount = pPlayer.ConsumeItemInAllPos(nItemTemplateId, 1, Env.LogWay_PartnerUseExpItem);
		if not nCount or nCount < 1 then
			Log("[Partner] DoUseExpItem ", pPlayer.dwID, pPlayer.szAccount, pPlayer.szName, pPartner.szName, pPartner.nTemplateId, nItemTemplateId, i - 1);
			return;
		end

		local nExp = math.floor(nBaseExp * GetPartnerBaseExp(nQualityLevel, pPartner.nLevel));
		pPlayer.AddPartnerExp(nPartnerId, nExp, i == nUseCount);
		if pPartner.nLevel >= self.MAX_LEVEL then
			pPlayer.AddPartnerExp(nPartnerId, 1, true);
			nUseCount = i;
			break;
		end
	end

	Task:OnTaskExtInfo(pPlayer, Task.ExtInfo_TongBanJiaJingYan);
	Log("[Partner] DoUseExpItem ", pPlayer.dwID, pPlayer.szAccount, pPlayer.szName, pPartner.szName, pPartner.nTemplateId, nItemTemplateId, nUseCount, pPartner.nLevel);
end

function Partner:DoAwareness(pPlayer, nPartnerId, tbUsePartnerInfo)
	local pPartner = pPlayer.GetPartnerObj(nPartnerId);
	if pPartner then
		local tbNeedInfo = self.tbAwareness[pPartner.nTemplateId];
		if tbNeedInfo then
			local nCount = pPlayer.GetItemCountInBags(self.nPartnerAwarenessCostItem);
			if nCount < tbNeedInfo.nNeedSeveranceItem then
				MarketStall:TipBuyItemFromMarket(pPlayer, self.nPartnerAwarenessCostItem);
				return;
			end
		end
	end

	local bRet, szMsg, nPartnerTemplateId, tbNeedInfo, tbAward, tbConsumeItem = Partner:CheckCanAwareness(pPlayer, nPartnerId, tbUsePartnerInfo);
	if not bRet then
		pPlayer.CenterMsg(szMsg or "無法覺醒");
		return;
	end

	if self:CheckNeedConfirmReinit(pPlayer, nPartnerId) then
		pPlayer.CenterMsg("請先選擇洗髓結果");
		return;
	end

	local nCostCount = pPlayer.ConsumeItemInBag(self.nPartnerAwarenessCostItem, tbNeedInfo.nNeedSeveranceItem, Env.LogWay_PartnerAwareness);
	if nCostCount ~= tbNeedInfo.nNeedSeveranceItem then
		pPlayer.CenterMsg("消耗道具失敗！", true);
		Log("[Partner] DoAwareness cost item fail !!", pPlayer.dwID, pPlayer.szAccount, pPlayer.szName, tbNeedInfo.nNeedSeveranceItem, nCostCount);
		return;
	end

	for _, nWeaponItemId in pairs(tbConsumeItem or {}) do
		local nCCount = pPlayer.ConsumeItemInBag(nWeaponItemId, 1, Env.LogWay_PartnerAwareness);
		if nCCount ~= 1 then
			pPlayer.CenterMsg("消耗道具失敗！", true);
			Log("[Partner] DoAwareness cost item fail !!", pPlayer.dwID, pPlayer.szAccount, pPlayer.szName, tbNeedInfo.nNeedSeveranceItem, nCostCount);
		else
			Log("[Partner] DoAwareness Consume PartnerWeapon ", pPlayer.dwID, pPlayer.szAccount, pPlayer.szName, self.nPartnerAwarenessCostItem, tbNeedInfo.nNeedSeveranceItem, nWeaponItemId);
		end
	end

	for _, nPartnerId in pairs(tbUsePartnerInfo) do
		pPlayer.DeletePartner(nPartnerId, Env.LogWay_PartnerAwareness);
	end

	if tbAward then
		pPlayer.SendAward(tbAward, false, true, Env.LogWay_PartnerAwareness);
	end
	Partner:SetPartnerAwareness(pPlayer, nPartnerTemplateId);
	pPlayer.SendBlackBoardMsg("覺醒成功，潛能得到了全面提升！");
	pPlayer.CallClientScript("Partner:PGAwarenessFinish", nPartnerId);

	pPlayer.TLog("OptPartner", self.TLOG_DEF_PARTNER_AWARENESS, Env.LogWay_PartnerAwareness, 0, nPartnerTemplateId, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);

	local szName, nQualityLevel = GetOnePartnerBaseInfo(nPartnerTemplateId);

	if nQualityLevel <= 2 then
		KPlayer.SendWorldNotify(0, 1000, string.format("恭喜「%s」的%s級同伴%s覺醒成功，潛能得到了全面提升！", pPlayer.szName, Partner.tbQualityLevelDes[nQualityLevel], szName), 1, 1);
	end

	if nQualityLevel <= 3 then
		if pPlayer.dwKinId > 0 then
			ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.Kin, string.format("恭喜幫派成員「%s」的%s級同伴%s覺醒成功，潛能得到了全面提升！", pPlayer.szName, Partner.tbQualityLevelDes[nQualityLevel], szName), pPlayer.dwKinId);
		end
	end
	Log("[Partner] DoAwareness", pPlayer.dwID, pPlayer.szAccount, pPlayer.szName, nPartnerTemplateId);
end

local tbPartnerWeapon;
function Partner:UseWeapon(pPlayer, nPartnerId)
	local tbPartner = pPlayer.GetPartnerInfo(nPartnerId or 0);
	if not tbPartner then
		return;
	end

	if tbPartner.nWeaponState ~= 0 then
		pPlayer.CenterMsg(string.format("【%s】已經擁有此武器", tbPartner.szName));
		return;
	end

	if self:CheckNeedConfirmReinit(pPlayer, nPartnerId) then
		pPlayer.CenterMsg("請先選擇洗髓結果");
		return;
	end

	local nWeaponItemTemplateId = Partner.tbPartner2WeaponItem[tbPartner.nTemplateId];
	if not nWeaponItemTemplateId then
		pPlayer.CenterMsg("此同伴沒有本命武器！");
		return;
	end

	local nCount, tbItems = pPlayer.GetItemCountInBags(nWeaponItemTemplateId);
	if nCount <= 0 then
		MarketStall:TipBuyItemFromMarket(pPlayer, nWeaponItemTemplateId);
		return;
	end

	local pItem = tbItems[1];
	tbPartnerWeapon = tbPartnerWeapon or Item:GetClass("PartnerWeapon");
	local szItemName = string.gsub(pItem.szName, tbPartner.szName .. "·", "");
	pPlayer.MsgBox(string.format("確定裝備 [FFFE0D]%s[-] 本命武器 [FFFE0D]%s[-] ？\n[FFFE0D]（裝備後不可取下，遣散後將會返還）[-]", tbPartner.szName, szItemName),
		{
			{"確定", tbPartnerWeapon.UseWeapon, tbPartnerWeapon, pPlayer.dwID, nPartnerId, pItem.dwId},
			{"取消"}
		});
end

function Partner:OnAddPartner(nPartnerId, nQualityLevel, nLogReazon)
	Log("Partner:OnAddPartner", me.dwID, me.szAccount, me.szName, nPartnerId, nQualityLevel);

	if me.GetUserValue(self.PARTNER_HAS_GROUP, nPartnerId) == 0 then
		me.SetUserValue(self.PARTNER_HAS_GROUP, nPartnerId, 1);
	end

	if nQualityLevel <= 3 then
		local szPartnerName = GetOnePartnerBaseInfo(nPartnerId);
		if szPartnerName then
			local szWorldNotifyMsg = string.format("恭喜「%s」獲得%s級同伴%s", me.szName, Partner.tbQualityLevelDes[nQualityLevel], szPartnerName);
			if nLogReazon >= Env.LogWay_CoinPick and nLogReazon <= Env.LogWay_GoldFreePick then
				Timer:Register(Env.GAME_FPS * 10, function ()
					KPlayer.SendWorldNotify(0, 1000, szWorldNotifyMsg, 1, 1);
				end);
			else
				KPlayer.SendWorldNotify(0, 1000, szWorldNotifyMsg, 1, 1);
			end
		end
	end

	Achievement:AddCount(me, "Partner_1", 1);

	if nQualityLevel <= 4 then
		Achievement:AddCount(me, "Partner_2", 1);
	end

	if nQualityLevel <= 3 then
		Achievement:AddCount(me, "Partner_4", 1);
	end

	if nQualityLevel <= Partner.tbDes2QualityLevel.SS then
		local nSSCount = me.GetUserValue(Sdk.Def.SDK_INFO_SAVEGROUP, Sdk.Def.SDK_INFO_SS_PARTNER_COUNT);
		if nSSCount == 0 then
			Sdk:SendTXLuckyBagMail(me, "FirstSSPartner");
		end
		me.SetUserValue(Sdk.Def.SDK_INFO_SAVEGROUP, Sdk.Def.SDK_INFO_SS_PARTNER_COUNT, nSSCount + 1);
	end

	self:ReportPartner(nQualityLevel)
end

function Partner:OnDeletePartner(nPartnerId, nQualityLevel, nTemplateId)
	Log("[Partner] OnDeletePartner", me.dwID, me.szAccount, me.szName, nPartnerId, nQualityLevel, nTemplateId);
	self:ReportPartner(nQualityLevel)
end

function Partner:ReportPartner(nQualityLevel)

    local nHave = Partner:GetPartnerCountByQuality(me,nQualityLevel) or 0

    if nQualityLevel == Partner.tbDes2QualityLevel.SS then
        AssistClient:ReportQQScore(me, Env.QQReport_PartnenrSSCount, nHave, 0, 1)
    elseif nQualityLevel == Partner.tbDes2QualityLevel.S then
        AssistClient:ReportQQScore(me, Env.QQReport_PartnenrSCount, nHave, 0, 1)
    elseif nQualityLevel == Partner.tbDes2QualityLevel.A then
        AssistClient:ReportQQScore(me, Env.QQReport_PartnenrACount, nHave, 0, 1)
    elseif nQualityLevel == Partner.tbDes2QualityLevel.B then
        AssistClient:ReportQQScore(me, Env.QQReport_PartnenrBCount, nHave, 0, 1)
    elseif nQualityLevel == Partner.tbDes2QualityLevel.C then
        AssistClient:ReportQQScore(me, Env.QQReport_PartnenrCCount, nHave, 0, 1)
    end
end

function Partner:OnLogin(pPlayer)
	local tbAllPartner = pPlayer.GetAllPartner();

	for nPartnerId, tbPartnerInfo in pairs(tbAllPartner or {}) do
		if pPlayer.GetUserValue(self.PARTNER_HAS_GROUP, tbPartnerInfo.nTemplateId) == 0 then
			pPlayer.SetUserValue(self.PARTNER_HAS_GROUP, tbPartnerInfo.nTemplateId, 1);
		end

		local nAwareness = Partner:GetPartnerAwareness(pPlayer, tbPartnerInfo.nTemplateId);
		local pPartner = pPlayer.GetPartnerObj(nPartnerId);

		if pPartner.GetAwareness() ~= nAwareness then
			pPartner.SetAwareness(nAwareness)
			pPartner.Update();
		end
	end
end

function Partner:OnZoneLogin(pPlayer) --对应同伴数据未初始化，先只有武林大会用到设置其出战同步
	local pAsync = KPlayer.GetAsyncData(pPlayer.dwID)
	if not pAsync then
		return
	end
	local tbPartnerPosToId = pPlayer.GetPartnerPosInfo()
	if not tbPartnerPosToId then
		return
	end
	for i,nPartnerId in ipairs(tbPartnerPosToId) do
		if nPartnerId ~= 0 then
			pPlayer.SetFightPartnerID(nPartnerId)
			return
		end
	end
	pPlayer.SetFightPartnerID(0)
end

function Partner:CallPartner(pPlayer, nPartnerTemplateId)
	local szPartnerName, nQualityLevel = GetOnePartnerBaseInfo(nPartnerTemplateId);
	local nNeedCount = self.tbCallPartnerCost[nQualityLevel or 0];
	if not nNeedCount or nNeedCount <= 0 then
		return;
	end

	local nHasPartner = pPlayer.GetUserValue(self.PARTNER_HAS_GROUP, nPartnerTemplateId);
	if nHasPartner == 0 then
		pPlayer.CenterMsg("必須擁有過此同伴才可以招募");
		return;
	end


	local nItemCount = pPlayer.GetItemCountInAllPos(self.nSeveranceItemId);
	if nItemCount < nNeedCount then
		pPlayer.CenterMsg("招募同伴所需洗髓丹不足");
		return;
	end

	local nCost = pPlayer.ConsumeItemInAllPos(self.nSeveranceItemId, nNeedCount, Env.LogWay_PartnerCallPartner);
	if nCost ~= nNeedCount then
		pPlayer.CenterMsg("扣除道具失敗，請聯繫客服人員！");
		Log("[Partner] CallPartner ConsumeItemInAllPos Fail !!", pPlayer.dwID, pPlayer.szAccount, pPlayer.szName, nCost, nNeedCount);
		return;
	end

	pPlayer.SendAward({{"partner", nPartnerTemplateId, 1}}, true, false, Env.LogWay_PartnerCallPartner);
	Log("[Partner] CallPartner", pPlayer.dwID, pPlayer.szAccount, pPlayer.szName, nPartnerTemplateId, nQualityLevel, nCost);
end

function Partner:ChangePartnerFightID(pPlayer, nPartnerId)
	if type(nPartnerId) ~= "number" then
		return;
	end

    local tbPartner = pPlayer.GetPartnerInfo(nPartnerId);
    if not tbPartner then
    	return;
    end

    pPlayer.SetFightPartnerID(nPartnerId);
 	pPlayer.CallClientScript("Partner:ChangePartnerFightID", nPartnerId);
 	pPlayer.OnEvent("OnChangePartnerFightID", nPartnerId);
 	Log("Partner ChangePartnerFightID", pPlayer.dwID, nPartnerId);
end

function Partner:OnZCSetFightPartnerID(dwRoleId, nPartnerId)
	local pPlayer = KPlayer.GetPlayerObjById(dwRoleId)
	if not pPlayer then
		return
	end
	pPlayer.SetFightPartnerID(nPartnerId);
end

PlayerEvent:RegisterGlobal("OnAddPartner",				Partner.OnAddPartner, Partner);
PlayerEvent:RegisterGlobal("OnDeletePartner",			Partner.OnDeletePartner, Partner);

