
local function GetBuildingSetting()
	local tbResult = {};
	local tbMaxLevel = {};
	local szBuildingPath = "Setting/Kin/KinBuilding.tab";
	local tbSetting = LoadTabFile(szBuildingPath, "dddds", nil,
		{"BuildingId", "Level", "MainBuildingLimit", "LevelUpCost", "Desc"});

	for _, tbLineData in ipairs(tbSetting) do
		local nBuildingId = tbLineData.BuildingId;
		local nBuildingLevel = tbLineData.Level;
		tbResult[nBuildingId] = tbResult[nBuildingId] or {};
		tbResult[nBuildingId][nBuildingLevel] = {
			nMainBuildingRequire = tbLineData.MainBuildingLimit,
			nLevelUpCost = tbLineData.LevelUpCost,
			szDesc = tbLineData.Desc,
		};

		tbMaxLevel[nBuildingId] = tbMaxLevel[nBuildingId] or 1;
		if tbLineData.Level > tbMaxLevel[nBuildingId] then
			tbMaxLevel[nBuildingId] = tbLineData.Level;
		end
	end

	return tbResult, tbMaxLevel;
end

local tbBuildingSetting, tbBuildingMaxLevel = GetBuildingSetting();

function Kin:GetBuildingInfo(nBuildingId, nLevel)
	local tbBuildingData = assert(tbBuildingSetting[nBuildingId]);
	return tbBuildingData[nLevel];
end

function Kin:CanLevelUp(nBuildingId, nLevel, nMainBuildingLevel)
	if nBuildingId == Kin.Def.Building_Main then
		return Kin:GetMainBuildingOpenLevel() >= nLevel, 1;
	end

	local tbBuildingInfo = Kin:GetBuildingInfo(nBuildingId, nLevel);
	if not tbBuildingInfo then
		return false, 1
	end
	return nMainBuildingLevel >= tbBuildingInfo.nMainBuildingRequire, tbBuildingInfo.nMainBuildingRequire;
end

function Kin:GetBuildingLimitLevel(nBuildingId)
	return Kin.Def.BuildingOpenLimit[nBuildingId];
end

function Kin:CheckKinCamp(nCamp)
	if Kin.Def.bForbidCamp then
		return true;
	end

    if nCamp ~= Npc.CampTypeDef.camp_type_neutrality and
       nCamp ~= Npc.CampTypeDef.camp_type_song and
       nCamp ~= Npc.CampTypeDef.camp_type_jin then
       return false;
    end

    return true;
end

local tbBuildingLevel2Key = {
	[3] = "OpenLevel49",
	[4] = "OpenLevel59",
	[5] = "OpenLevel69",
	[6] = "OpenLevel79",
	[7] = "OpenLevel89",
	[8] = "OpenLevel99",
	[9] = "OpenLevel109",
	[10] = "OpenLevel119",
};

local function GetTimeFrameKeyByLevel(nLevel)
	return tbBuildingLevel2Key[nLevel];
end

local nCurDay = nil;
local nMaxMainBuildingLevel = 2;

function Kin:GetMainBuildingOpenLevel()
	local nToday = Lib:GetLocalDay(GetTime() - Kin.Def.nBuildingLevelUpdateTime);
	if nToday ~= nCurDay then
		nCurDay = nToday;
		for nLevel = 3, Kin.Def.nMaxBuildingLevel do
			if GetTimeFrameState(GetTimeFrameKeyByLevel(nLevel)) ~= 1 then
				break;
			end
			nMaxMainBuildingLevel = nLevel;
		end
	end

	local szNextLevelTimeFrame = GetTimeFrameKeyByLevel(nMaxMainBuildingLevel + 1);
	return nMaxMainBuildingLevel, szNextLevelTimeFrame;
end

function Kin:GetBuildingMaxLevel(nBuildingId)
	return tbBuildingMaxLevel[nBuildingId] or 1;
end

function Kin:GetBuildingUpgradeCost(nBuildingId, nNextLevel)
	if nNextLevel > Kin:GetBuildingMaxLevel(nBuildingId) then
		return 0, 0;
	end

	local tbBuildingInfo = Kin:GetBuildingInfo(nBuildingId, nNextLevel) or {};
	local nCost = tbBuildingInfo.nLevelUpCost;
	assert(nCost, string.format("KinBuilding.他b填表出錯%d, %d", nBuildingId, nNextLevel));

	local nMaxLevel = Kin:GetMainBuildingOpenLevel();
	local nLevel = nNextLevel-1
	local nDiscountRate = Kin.Def.BuildingDiscountRate[nMaxLevel - nLevel] or 1;
	nCost = math.floor(nCost * nDiscountRate);
	return nCost, nDiscountRate;
end

local szKinCountSettingPath = "Setting/Kin/LevelSetting.tab";
local tbLevelSetting = tbLevelSetting or
	LoadTabFile(szKinCountSettingPath, "ddddddddddd", "Level",
		{"Level", "MaxMember", "MaxMemberAbroad", "MaxNewer", "MaxRetire",
		"MaxMaster", "MaxViceMaster", "MaxElder",
		"MaxElite", "MaxMascot", "MaxFound"});

local CareerSettingNameMap = {
	[Kin.Def.Career_Master]     = "MaxMaster",
	[Kin.Def.Career_ViceMaster] = "MaxViceMaster",
	[Kin.Def.Career_Elder]      = "MaxElder",
	[Kin.Def.Career_Elite]      = "MaxElite",
	[Kin.Def.Career_Mascot]     = "MaxMascot",
	[Kin.Def.Career_New]        = "MaxNewer",
	[Kin.Def.Career_Retire]     = "MaxRetire",
	["MaxMember"]               = "MaxMember",
	["MaxMemberAbroad"]			= "MaxMemberAbroad",
}

function Kin:GetMaxMember(nLevel, itemKey)
	if itemKey==Kin.Def.Career_Leader then
		return 1
	end
	local szItemName = assert(CareerSettingNameMap[itemKey]);
	return tbLevelSetting[nLevel][szItemName];
end

function Kin:GetDonationsFound(nTimeBegin, nTimeEnd)
	if nTimeBegin>nTimeEnd then
		Log("[x] Kin:GetDonationsFound", tostring(nTimeBegin), tostring(nTimeEnd))
		return
	end

	local tbBegin = self:GetDonateSetting(nTimeBegin)
	local tbEnd = self:GetDonateSetting(nTimeEnd)
	return tbEnd.nTotalFound-tbBegin.nTotalFound+tbBegin.nFound
end

function Kin:GetDonationsCost(nTimeBegin, nTimeEnd)
	if nTimeBegin>nTimeEnd then
		Log("[x] Kin:GetDonationsCost", tostring(nTimeBegin), tostring(nTimeEnd))
		return
	end

	local tbBegin = self:GetDonateSetting(nTimeBegin)
	local tbEnd = self:GetDonateSetting(nTimeEnd)
	return tbEnd.nTotalPrice-tbBegin.nTotalPrice+tbBegin.nPrice
end

function Kin:GetMaxFound(nLevel)
	assert(tbLevelSetting[nLevel])
	return tbLevelSetting[nLevel].MaxFound;
end

function Kin:LoadRedBagSetting()
	self.tbRedBagTypes = LoadTabFile("Setting/Kin/KinRedBagType.tab", "dsssd", "nId",
		{"nId", "szRecordFormat", "szRelation", "szRepeat", "nGlobal"})

	local tbOrgSetting = LoadTabFile("Setting/Kin/KinRedBag.tab", "ddddsdd", "nEventId",
		{"nEventId", "nTypeId", "nTarget", "nBaseGold", "szAddGoldList", "nCount", "nAverageMin"})

	local tbSettings = {}
	for nEventId,tb in pairs(tbOrgSetting) do
		local tbList = Lib:SplitStr(tb.szAddGoldList, "_")
		local tbAddGoldList = {}
		for _,szGold in ipairs(tbList) do
			table.insert(tbAddGoldList, tonumber(szGold))
		end
		table.sort(tbAddGoldList, function(a, b) return a<b end)

		tbSettings[nEventId] = {
			nEventId = tb.nEventId,
			nTypeId = tb.nTypeId,
			nTarget = tb.nTarget,
			nBaseGold = tb.nBaseGold,
			nCount = tb.nCount,
			nAverageMin = tb.nAverageMin,
			tbAddGoldList = tbAddGoldList,
		}
	end
	self.tbRedBagSettings = tbSettings

	local tbRedBagIdGrps = {}
	for nEventId,tb in pairs(tbSettings) do
		tbRedBagIdGrps[tb.nTypeId] = tbRedBagIdGrps[tb.nTypeId] or {}
		tbRedBagIdGrps[tb.nTypeId][nEventId] = true
	end
	self.tbRedBagIdGrps = tbRedBagIdGrps
end
Kin:LoadRedBagSetting()

function Kin:GetRedBagSetting(nEventId)
	return self.tbRedBagSettings[nEventId]
end

function Kin:LoadActivitySetting()
	local tbSetting = LoadTabFile("Setting/Kin/KinActivity.tab", "sddd", nil,
		{"szJudgement", "nWeekAvg", "nHasSalary", "nDismiss"})
	table.sort(tbSetting, function(tbA, tbB)
		return tbA.nWeekAvg<tbB.nWeekAvg
	end)
	for nIdx,tb in ipairs(tbSetting) do
		if tb.nHasSalary>0 then
			tbSetting.nMinSalaryIdx = nIdx
			break
		end
	end
	self.tbActivitySettings = tbSetting
end
Kin:LoadActivitySetting()

function Kin:GenDonateSettingCache()
	local tbCache = {}
	local nLastMax = 1
	local nTotalPrice, nTotalFound = 0, 0
	for _, tb in ipairs(self.tbDonateSettings) do
		local nCurMax = tb.nMax
		for i=nLastMax, nCurMax do
			nTotalPrice = nTotalPrice+tb.nPrice
			nTotalFound = nTotalFound+tb.nFound
			local tbTmp = Lib:CopyTB(tb)
			tbTmp.nTotalPrice = nTotalPrice
			tbTmp.nTotalFound = nTotalFound
			tbCache[i] = tbTmp
		end
		nLastMax = nCurMax+1
	end
	self.tbDonationSettingCache = tbCache
end

function Kin:LoadDonateSetting()
	local tbSetting = LoadTabFile("Setting/Kin/KinDonate.tab", "ddd", nil,
		{"nMax", "nPrice", "nFound"})
	table.sort(tbSetting, function(tbA, tbB)
		return tbA.nMax<tbB.nMax
	end)

	self.tbDonateSettings = tbSetting
	self:GenDonateSettingCache()
end
Kin:LoadDonateSetting()

function Kin:GetDonateSetting(nCount)
	local tbSetting = self.tbDonationSettingCache[nCount]
	if not tbSetting then
		tbSetting = self.tbDonationSettingCache[#self.tbDonationSettingCache]
	end
	return tbSetting
end

function Kin:GetCareerNewLevels()
	local szTimeFrame = Lib:GetMaxTimeFrame(Kin.tbCareerNewTimeFrames)
	local tbSetting = Kin.tbCareerNewTimeFrames[szTimeFrame]
	if not tbSetting then
		return 0, 0
	end
	return unpack(tbSetting)
end

function Kin:RedBagIsModifyValid(nEventId, nAddGold, nCount, nVip)
	if not nEventId or nEventId<=0 then
		if nAddGold>0 then
			return false, "此紅包不可增加元寶"
		else
			return true
		end
	end

	local tbSetting = self.tbRedBagSettings[nEventId]

	if nCount<tbSetting.nCount then
		return false, "紅包個數不能再少了"
	end

	local bGlobal = self:RedBagIsEventGlobal(nEventId)
	if not bGlobal and nCount>100 then
		return false, "紅包個數不能再多了"
	end

	if nAddGold>0 then
		local bValidAddGold = false
		for _,nGold in ipairs(tbSetting.tbAddGoldList) do
			if nGold==nAddGold then
				bValidAddGold = true
				break
			end
		end
		if not bValidAddGold then
			return false, "不支持增加這麼多金額"
		end

		if not self:RedBagIsMultiValid(nVip, tbSetting.nBaseGold, nAddGold) then
			return false, "劍俠V等級不足"
		end
	end

	local nTotalGold = tbSetting.nBaseGold+nAddGold
	local fAverageGold = nTotalGold/nCount
	if fAverageGold<tbSetting.nAverageMin then
		return false, "紅包個數不能再多了"
	end

	return true
end

function Kin:RedBagOnAddTitle(pPlayer, nTitleID)
	local nRedBagEvent = Kin.Def.tbTitle2RedBagEvent[nTitleID]
	if not nRedBagEvent then
		return
	end

    Kin:RedBagOnEvent(pPlayer, nRedBagEvent)
end

function Kin:RedBagOnEvent(playerIdOrObj, nEventType, nCount)
	if MODULE_ZONESERVER then return end
	
	local pPlayer = playerIdOrObj
	if type(playerIdOrObj)=="number" then
		pPlayer = KPlayer.GetPlayerObjById(playerIdOrObj)
		if not pPlayer then
			local szCmd = string.format("Kin:RedBagOnEvent(%d, %d, %d)", playerIdOrObj, nEventType, nCount or 0)
			KPlayer.AddDelayCmd(playerIdOrObj, szCmd, "RedBagOnEvent")
			return
		end
	end
	if not pPlayer then
		Log("[x] Kin:RedBagOnEvent pPlayer nil", tostring(playerIdOrObj), tostring(nEventType), tostring(nCount))
		return
	end
	self:_RedBagOnEvent(pPlayer, nEventType, nCount)
end

function Kin:_RedBagOnEvent(pPlayer, nEventType, nCount)
	if not MODULE_GAMESERVER then
		return
	end

	if nEventType==Kin.tbRedBagEvents.first_master or
			nEventType==Kin.tbRedBagEvents.top10_master or
			nEventType==Kin.tbRedBagEvents.good_master then
		local nKinId = pPlayer.dwKinId
		local tbKin = Kin:GetKinById(nKinId)
		if not tbKin then
			return
		end
		local nLeaderId = tbKin:GetLeaderId()
		if nLeaderId>0 then
			return
		end
	end

	local tbTypeCfg = self.tbRedBagTypes[nEventType]
	local tbIdGrp = self.tbRedBagIdGrps[nEventType] or {}
	for nEventId in pairs(tbIdGrp) do
		while true do
			local szRepeat = tbTypeCfg.szRepeat
			if szRepeat=="" then
				if self:IsRedBagSent(pPlayer, nEventId) then
					break
				end
			elseif szRepeat=="weekly" then
				local nLastSend = self:_GetRedBagSendTime(pPlayer, nEventId)
				local nLastSendWeek = Lib:GetLocalWeek(nLastSend)
				local nCurWeek = Lib:GetLocalWeek(GetTime())
				if nLastSendWeek==nCurWeek then
					break
				end
			elseif szRepeat=="nolimit" then
				--no limit
			else
				Log("[x] Kin:RedBagOnEvent, unknown szRepeat", szRepeat, nEventType, nCount, nEventId)
				break
			end

			local tbSetting = self.tbRedBagSettings[nEventId]
			local nTarget = tbSetting.nTarget
			if tbTypeCfg.szRelation=="=" then
				if nCount~=nTarget then
					break
				end
			elseif tbTypeCfg.szRelation==">=" then
				if nCount<nTarget then
					break
				end
			elseif tbTypeCfg.szRelation=="<=" then
				if nCount>nTarget then
					break
				end
			end
			self:_RedBagGain(pPlayer.dwID, nEventId, nCount)

			break
		end
	end
end

function Kin:RedBagGetContent(tbRedBag)
	if tbRedBag.szContent then
		return tbRedBag.szContent
	end

	local szRet = ""
	local tbSetting = self.tbRedBagSettings[tbRedBag.nEventId]
	if not tbSetting then
		Log("[x] Kin:RedBagGetContent failed", tbRedBag.nEventId)
		return szRet
	end
	local nTypeId = tbSetting.nTypeId
	local tbTypeSetting = self.tbRedBagTypes[nTypeId]
	local szFormatStr = tbTypeSetting.szRecordFormat

	if nTypeId==Kin.tbRedBagEvents.newbie_king or nTypeId==Kin.tbRedBagEvents.big_brother then
		local nFaction = tbRedBag.tbOwner.nFaction
		if not nFaction and MODULE_GAMESERVER then
			local tbStayInfo = KPlayer.GetRoleStayInfo(tbRedBag.tbOwner.nId)
			nFaction = tbStayInfo.nFaction
		end
		local szFactionName = nFaction and Faction:GetName(nFaction) or ""
		szRet = string.format(szFormatStr, szFactionName)
	elseif nTypeId==Kin.tbRedBagEvents.vip_level or 
		nTypeId==Kin.tbRedBagEvents.all_strength or nTypeId==Kin.tbRedBagEvents.all_insert then
		szRet = string.format(szFormatStr, tbSetting.nTarget)
	elseif nTypeId==Kin.tbRedBagEvents.title then
		local szTitle = Player.tbHonorLevel:GetHonorName(tbSetting.nTarget)
		szRet = string.format(szFormatStr, szTitle)
	elseif nTypeId==Kin.tbRedBagEvents.wsd_rank then
		local szRank = string.format("前%d名", tbSetting.nTarget)
		if tbSetting.nTarget==1 then
			szRank = "第一名"
		end
		szRet = string.format(szFormatStr, szRank)
	elseif nTypeId==Kin.tbRedBagEvents.white_tiger_boss or nTypeId==Kin.tbRedBagEvents.tower_floor then
		szRet = string.format(szFormatStr, Lib:Transfer4LenDigit2CnNum(tbSetting.nTarget))
	else
		szRet = szFormatStr
	end
	return szRet
end


local tbMultiInfos = {
	[2] = {
		icon = "Multiple2",
		desc = "雙倍金額",
	},
	[3] = {
		icon = "Multiple3",
		desc = "三倍金額",
	},
	[6] = {
		icon = "Multiple6",
		desc = "六倍金額",
	},
}
function Kin:RedBagGetMultiInfo(nEventId, nGold)
	if not nEventId or nEventId<=0 then
		return nil
	end
	
	local tbSetting = self.tbRedBagSettings[nEventId]
	local nBase = tbSetting.nBaseGold
	for nMulti,tbInfo in pairs(tbMultiInfos) do
		if nMulti*nBase == nGold then
			return tbInfo.icon, tbInfo.desc, nMulti
		end
	end
	return nil
end

function Kin:RedBagGetBaseGold(nTypeId)
	if not nTypeId or nTypeId<=0 then
		return nil
	end
	local tbIdGrp = self.tbRedBagIdGrps[nTypeId] or {}
	local nEventId = next(tbIdGrp)
	if not nEventId then
		Log("[x] Kin:RedBagGetBaseGold invalid nEventId", tostring(nTypeId))
		return nil
	end
	local tbSetting = self.tbRedBagSettings[nEventId]
	return tbSetting.nBaseGold
end

function Kin:RedBagIsPlayerGrabEnough(pPlayer)
	if not pPlayer then
		return true
	end

	local nCurCount = pPlayer.GetUserValue(Kin.Def.nRedBagPlayerGrabGrp, Kin.Def.nRedBagPlayerGrabCount)
	local nLastTime = pPlayer.GetUserValue(Kin.Def.nRedBagPlayerGrabGrp, Kin.Def.nRedBagPlayerLastGrabTime)
	local nNow = GetTime()
	local nLastDay = Lib:GetLocalDay(nLastTime)
	local nToday = Lib:GetLocalDay(nNow)
	if nToday>nLastDay then
		return false
	end

	return nCurCount>=Kin.Def.nRedBagMaxGrabPerDay
end

function Kin:RedBagIsMultiValid(nVip, nBaseGold, nAddGold)
	local nMaxMulti = 1
	for i=#self.Def.tbVipRedBagMaxMulti, 1, -1 do
		local nMinVip, nMax = unpack(self.Def.tbVipRedBagMaxMulti[i])
		if nVip>=nMinVip then
			nMaxMulti = nMax
			break
		end
	end
	local nCurMulti = (nAddGold+nBaseGold)/nBaseGold
	return nCurMulti<=nMaxMulti
end

function Kin:IsCareerTitleForbidden(nCareer, szTitle)
	if Kin.Def.tbForbiddenTitleNames[szTitle] then
		return true
	end

	for nc, szName in pairs(Kin.Def.Career_Name) do
		if szTitle==szName and nCareer~=nc then
			return true
		end
	end
	return false
end

function Kin:IsGatherExtraReward()
	-- if Sdk:IsEfunHKTW() then
	-- 	return Sdk.Def.bIsEfunTWHKWeekendActOpen;
	-- end

	local nWeekDay = Lib:GetLocalWeekDay();
	return nWeekDay == 6 or nWeekDay == 7;
end

function Kin:GatherGetExtraRewardRate()
	local nExtraRate = 0;
	if Kin:IsGatherExtraReward() then
		return Kin.GatherDef.WeekendExtraAnswerRate, Kin.GatherDef.WeekendDicePriceExtraPercent;
	end
	return 0, 0;
end

function Kin:GetChangeNamePrice(pPlayer)
	local nChangeItem = pPlayer.GetItemCountInAllPos(Kin.Def.nChangeNameItem)
    if nChangeItem > 0 then
        return 0, true
    end
    return Kin.Def.nChangeNameCost, false
end

function Kin:GetVipDonateContributeInc(nVipLevel)
	local tbConfig = Recharge.tbVipExtSetting.KinDonateContributeInc
	local fRet = 0
	for _, tb in ipairs(tbConfig) do
		local nVip, fInc = unpack(tb)
		if nVipLevel>=nVip then
			fRet = fInc
		else
			break
		end
	end
	return fRet
end

function Kin:IsNameValid(szName)
	if not szName or szName=="" then
		return false, "請輸入名字"
	end

	--if Lib:HasNonChineseChars(szName) then
	--	return false, "家族名只能使用中文字符，请修改后重试"
	--end

	if string.find(szName, "%s") then
		return false, "幫派名當中不可含有空格"
	end

	local bInvalidWords = false
	if MODULE_GAMESERVER then
		bInvalidWords = not CheckNameAvailable(szName)
	else
		bInvalidWords = ReplaceLimitWords(szName)
	end
	if bInvalidWords then
		return false, "幫派名含有敏感字元，請修改後重試"
	end

	if version_tx or version_th then
		local nNameLen = Lib:Utf8Len(szName)
		if nNameLen > Kin.Def.nMaxKinNameLength or nNameLen < Kin.Def.nMinKinNameLength then
			return false, string.format("幫派名字需在%d~%d字之間", Kin.Def.nMinKinNameLength, Kin.Def.nMaxKinNameLength)
		end
	else
		local nNameLen = string.len(szName)
		if nNameLen > Kin.Def.nMaxKinNameLength then
			return false, "幫派名字過長，請重新輸入";
		elseif nNameLen < Kin.Def.nMinKinNameLength then
			return false, "幫派名字過短，請重新輸入";
		end
	end
	return true
end

function Kin:CareerCmp(nCareer1, nCareer2)
	local tbCareerOrder = {
		[self.Def.Career_Leader]	 = 1; -- 领袖
		[self.Def.Career_Master]     = 2; -- 族长
		[self.Def.Career_ViceMaster] = 3; -- 副族长
		[self.Def.Career_Elder]      = 4; -- 长老
		[self.Def.Career_Mascot]     = 4; -- 家族宝贝
		[self.Def.Career_Elite]      = 5; -- 精英
		[self.Def.Career_Normal]     = 6; -- 正式成员
		[self.Def.Career_New]        = 7; -- 见习成员
		[self.Def.Career_Retire]     = 8; -- 退隐成员
	}
	local nOrder1 = tbCareerOrder[nCareer1] or math.huge
	local nOrder2 = tbCareerOrder[nCareer2] or math.huge
	return nOrder2-nOrder1
end

function Kin:ComputeChangeLeaderDeadline(nChangeLeaderTime)
	local nDeadline = nChangeLeaderTime+Kin.Def.nChangeLeaderTime
	local tbDeadline = os.date("*t", nDeadline)
	tbDeadline.hour = 23
	tbDeadline.min = 59
	tbDeadline.sec = 59
	return os.time(tbDeadline)
end

Kin.Def.tbJoinCDSaveSettings = {
	nGrp = 32,
	nKey = 3,
}

function Kin:GetJoinCD(pPlayer)
	local nDeadline = pPlayer.GetUserValue(self.Def.tbJoinCDSaveSettings.nGrp, self.Def.tbJoinCDSaveSettings.nKey)
	return nDeadline-GetTime()
end

function Kin:RedBagIsEventGlobal(nEventId)
	local nEventType = self.tbRedBagSettings[nEventId].nTypeId
	return self.tbRedBagTypes[nEventType].nGlobal==1
end

function Kin:RedBagIsIdGlobal(szId)
	return string.find(szId, "g_")~=nil
end

function Kin:GetGiftInc(nVip)
	local tbSetting = Recharge.tbVipExtSetting.KinGiftBoxInc
	for i=#tbSetting, 1, -1 do
		local nMinVip, nInc = unpack(tbSetting[i])
		if nVip>=nMinVip then
			return nInc
		end
	end
	return 0
end

function Kin:GetGiftMaxCount(nVip)
	local nInc = self:GetGiftInc(nVip)
	return self.Def.nMaxGiftBoxPerDay+nInc
end