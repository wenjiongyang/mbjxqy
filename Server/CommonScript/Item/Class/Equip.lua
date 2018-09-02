
local tbEquip = Item:GetClass("equip");

function tbEquip:OnCreate(pEquip)
	Item.tbRefinement:OnGenerate(pEquip);
end

function tbEquip:OnInit(pEquip)
	local nValue = pEquip.nOrgValue;
	local nFightPower = pEquip.nBaseFightPower;
	local nRefinePower, nRefineValue, nMaxQuality = Item.tbRefinement:InitEquip(pEquip);
	pEquip.nFightPower = nFightPower + nRefinePower;
	pEquip.SetSingleValue(nValue + nRefineValue)
	pEquip.nQuality = math.max(1, nMaxQuality);
	if Item.GoldEquip.tbTrainAttriSetting[pEquip.dwTemplateId] and pEquip.GetBaseIntValue(Item.EQUIP_VALUE_TRAIN_ATTRI_LEVEL) == 0 then
		pEquip.SetBaseIntValue(Item.EQUIP_VALUE_TRAIN_ATTRI_LEVEL, 1)
	end
end

function tbEquip:GetTip(pEquip, pPlayer, bIsCompare)			-- 获取普通道具Tip	
	-- 基础属性
	local tbBaseAttrib, nBaseQuality = self:GetBaseAttrib(pEquip.dwTemplateId, pEquip, pPlayer, bIsCompare)
	-- 随机属性
	local tbRandomAttrib, nMaxQuality = self:GetRandomAttrib(pEquip, pPlayer)
	-- 精炼属性
	local tbTrainAttrib = Item.GoldEquip:GetTrainAttrib(pEquip.dwTemplateId, pEquip.GetBaseIntValue(Item.EQUIP_VALUE_TRAIN_ATTRI_LEVEL))
	-- 套装属性
	local tbSuitAttrib, tbSuitInfo = Item.GoldEquip:GetSuitAttrib(pEquip.dwTemplateId, pPlayer)
	-- 镶嵌属性
	local tbInsetAttrib = self:GetInsetAttrib(pEquip, pPlayer)
	-- 发光属性
	local tbOpenLight = bIsCompare and {} or self:GetOpenLightAttrib(pEquip, pPlayer);
	--铭刻信息
	local tbRecordStoneInfo = RecordStone:GetRecordStoneShowInfo(pEquip)

	nMaxQuality = math.max(nMaxQuality, nBaseQuality)

	local tbReturn = self:FormatTips(pEquip.dwTemplateId, tbBaseAttrib, tbRandomAttrib, tbInsetAttrib, tbSuitAttrib, tbOpenLight, tbSuitInfo, tbTrainAttrib, tbRecordStoneInfo)

	return tbReturn, nMaxQuality;
end

function tbEquip:GetTipByTemplate(nTemplateId, tbSaveRandomAttrib)
	local tbBaseAttrib, nBaseQuality = self:GetBaseAttrib(nTemplateId);
	local tbRandomAttrib = {};
	local nMaxQuality = 0;
	local tbRecordStoneInfo;

	if tbSaveRandomAttrib then
		local tbBaseInfo = KItem.GetItemBaseProp(nTemplateId);
		tbRandomAttrib, nMaxQuality = self:GetRandomAttribByTable(tbSaveRandomAttrib, tbBaseInfo.nLevel, tbBaseInfo.nItemType);
		--铭刻信息
		tbRecordStoneInfo = RecordStone:_GetRecordStoneShowInfo(nTemplateId, tbSaveRandomAttrib)	
	end
	local tbTrainAttrib = Item.GoldEquip:GetTrainAttrib(nTemplateId)
	local tbSuitAttrib, tbSuitInfo = Item.GoldEquip:GetSuitAttrib(nTemplateId)

	nMaxQuality = math.max(nMaxQuality, nBaseQuality)

	local tbReturn = self:FormatTips(nTemplateId, tbBaseAttrib, tbRandomAttrib, {}, tbSuitAttrib, nil, tbSuitInfo, tbTrainAttrib, tbRecordStoneInfo)

	return tbReturn, nMaxQuality;
end

function tbEquip:GetMagicAttribDesc(szName, tbValue, nActiveReq)
	if szName == "" then
		return	"";
	end

	if not tbValue then
		return ""
	end
	local szAttribMsg = FightSkill:GetMagicDesc(szName, tbValue);
	local szReq = Item:GetActiveReqDesc(nActiveReq);
	if szReq then
		szAttribMsg = szAttribMsg..string.format(" (%s)", szReq);
	end

	return szAttribMsg;
end


function tbEquip:GetBaseAttrib(nTemplate, pEquip, pPlayer, bIsCompare)
	local tbTip = {};
	local tbAttrib = nil;
	if pEquip then
		tbAttrib = pEquip.GetBaseAttrib();
	else
		tbAttrib = KItem.GetEquipBaseProp(nTemplate).tbBaseAttrib;
	end

	if not tbAttrib then
		return;
	end

	local nColorQuality = 1
	local tbInfo = KItem.GetItemBaseProp(nTemplate)
	if tbInfo.nDetailType == Item.DetailType_Gold then
		nColorQuality = Item.GoldEquip.GOLD_QUALITY_COLOR
	end

	for i, tbMA in ipairs(tbAttrib) do
		local szExt;
		if pEquip and pPlayer and not bIsCompare then
			local tbEquips = pPlayer.GetEquips();
			if tbEquips[pEquip.nEquipPos] and tbEquips[pEquip.nEquipPos] == pEquip.dwId then
				local nStrenLevel 	= Strengthen:GetStrengthenLevel(pPlayer, pEquip.nEquipPos);
				local tbValue 		= Strengthen:GetAttribValues(tbMA.szName, nStrenLevel);
				if tbValue and tbValue[1] ~= 0 then
			        local szName, szValue = FightSkill:GetMagicDescSplit(tbMA.szName, tbValue);
			        szExt = szValue;
			    end
			end
		end

		local szDesc = self:GetMagicAttribDesc(tbMA.szName, tbMA.tbValue, tbMA.nActiveReq);
		if (szDesc and szDesc ~= "") then
			if szExt then
				table.insert(tbTip, {{szDesc, nColorQuality, szExt, 2}});	
			else
				table.insert(tbTip, {szDesc, nColorQuality});
			end
		end
	end
	if pEquip and pEquip.nEquipPos == Item.EQUIPPOS_RING and pEquip.GetStrValue(1) then
		local szEquipString = pEquip.GetStrValue(1)
		if szEquipString then
			table.insert(tbTip, {szEquipString, 5});
		end
	end
	return tbTip or {}, nColorQuality;
end

function tbEquip:GetRandomAttrib(pEquip, pPlayer)
	local tbAttribs = Item.tbRefinement:GetRandomAttrib(pEquip);
	local tbTip = {};
	local nMaxQulity = 0;
	local nEquipLevel = pEquip.nLevel
	-- if pPlayer and pPlayer.GetEquipByPos then -- 随机属性的颜色，取按当前身上穿的装备的等级走，查看别人装备不受影响
	-- 	local pEquipedItem = pPlayer.GetEquipByPos(pEquip.nEquipPos)
	-- 	if pEquipedItem then
	-- 		nEquipLevel = pEquipedItem.nLevel
	-- 	end
	-- end
	local nItemType = pEquip.nItemType
	for _, tbAttrib in ipairs(tbAttribs) do
		local nQuality = Item.tbRefinement:GetAttribColor(nEquipLevel, tbAttrib.nAttribLevel, nItemType);
		local tbMA, szDesc = Item.tbRefinement:GetAttribMA(tbAttrib, nItemType);
		if  Lib:IsEmptyStr(szDesc) then
			szDesc = self:GetMagicAttribDesc(tbAttrib.szAttrib, tbMA);
		end
		if not Lib:IsEmptyStr(szDesc) then
			table.insert(tbTip, {szDesc, nQuality});
		end
		if nQuality > nMaxQulity then
			nMaxQulity = nQuality;
		end
	end

	return (tbTip or {}), nMaxQulity;
end

function tbEquip:GetRandomAttribByTable(tbSaveAttrib, nEquipLevel, nItemType)
	local tbAttribs = Item.tbRefinement:GetRandomAttribByTable(tbSaveAttrib);
	local tbTip = {};
	local nMaxQulity = 0;
	for _, tbAttrib in ipairs(tbAttribs) do
		local nQuality = Item.tbRefinement:GetAttribColor(nEquipLevel, tbAttrib.nAttribLevel, nItemType);
		local tbMA = Item.tbRefinement:GetAttribMA(tbAttrib, nItemType);
		local szDesc = self:GetMagicAttribDesc(tbAttrib.szAttrib, tbMA);
		if szDesc and szDesc ~= "" then
			table.insert(tbTip, {szDesc, nQuality});
		end
		if nQuality > nMaxQulity then
			nMaxQulity = nQuality;
		end
	end

	return (tbTip or {}), nMaxQulity;
end

function tbEquip:GetInsetAttrib(pEquip, pPlayer)
	local tbEquips = pPlayer.GetEquips();
	if tbEquips[pEquip.nEquipPos] and tbEquips[pEquip.nEquipPos] == pEquip.dwId then
		return StoneMgr:GetEquipInsetAttrib(pPlayer, pEquip);
	else
		return {};
	end
end

function tbEquip:GetOpenLightAttrib(pEquip, pPlayer)
    local tbEquips = pPlayer.GetEquips();
	if tbEquips[pEquip.nEquipPos] and 
	   pEquip.nEquipPos == Item.EQUIPPOS_WEAPON and
	   tbEquips[pEquip.nEquipPos] == pEquip.dwId then	
    	local tbAttibMsg = self:GetLightAttribMsg(pPlayer);
		return tbAttibMsg;
	else
		return {};
	end
end

function tbEquip:GetLightAttribMsg(pPlayer)
    local nLightID  = 0;
    local nEndTime  = 0;
    if pPlayer.szName == me.szName then
        nLightID = me.GetUserValue(OpenLight.nSaveGroupID, OpenLight.nSaveLightID);
        nEndTime = me.GetUserValue(OpenLight.nSaveGroupID, OpenLight.nSaveLightTime);
    else
        nLightID = pPlayer.GetOpenLight();
        nEndTime = -1;   
    end    

    local tbLightInfo = OpenLight:GetLightSetting(nLightID);
    if not tbLightInfo then
        return {};
    end   

    local tbAttibMsg, nQuality = OpenLight:GetLightAttribMsg(nLightID);
    tbAttibMsg = tbAttibMsg or {};
    if Lib:CountTB(tbAttibMsg) > 0 and nEndTime > 0 then
    	local nRetTime = nEndTime - GetTime();
    	nRetTime = math.max(0, nRetTime);
    	local szTime = string.format("時效：%s", Lib:TimeDesc2(nRetTime));
    	table.insert(tbAttibMsg, {szTime, nQuality});
    end

    return tbAttibMsg;	
end

function tbEquip:FormatTips(nTemplateId, tbBaseAttrib, tbRandomAttrib, tbInsetAttrib, tbSuitAttrib, tbLightAttirb, tbSuitInfo, tbTrainAttrib, tbRecordStoneInfo)
	-- body
	local tbAttribs = {};
	table.insert(tbAttribs, {"", 1});

	for i, v in ipairs(tbBaseAttrib) do
		local szText, nColor = unpack(v)
		if type(szText) == "table" then
			local tbV = Lib:CopyTB(v);
			if tbV[1] and not Lib:IsEmptyStr(tbV[1][3]) then
				tbV[1][3] = string.format("(強化 %s)", szText[3])
			end

			table.insert(tbAttribs, tbV);
		else
			table.insert(tbAttribs, v);
		end
	end

	if next(tbRandomAttrib) then
		table.insert(tbAttribs, {"附加屬性"});
		for i, v in ipairs(tbRandomAttrib) do
			table.insert(tbAttribs, v);
		end
	end

	--铭刻石显示
	if tbRecordStoneInfo and next(tbRecordStoneInfo) then
		table.insert(tbAttribs, {"銘刻"});
		for i,v in ipairs(tbRecordStoneInfo) do
			table.insert(tbAttribs, v);
		end
	end

	if tbTrainAttrib and next(tbTrainAttrib) then
		table.insert(tbAttribs, {"精煉屬性"});
		for i,v in ipairs(tbTrainAttrib) do
			table.insert(tbAttribs, v);
		end
	end

	if tbSuitAttrib and next(tbSuitAttrib) and tbSuitInfo  then
		table.insert(tbAttribs, {string.format("套裝屬性 (%d/%d)", tbSuitInfo[2] ,tbSuitInfo[1])});
		local nActiveNum = 0
		for i,v in ipairs(tbSuitAttrib) do
			table.insert(tbAttribs, v);
			if v[2] == Item.GoldEquip.COLOR_ACTVIED then
				nActiveNum = nActiveNum + 1
			end
		end
	end

	local tbInfo = KItem.GetEquipBaseProp(nTemplateId)
	if next(tbInsetAttrib) or tbInfo.nHoleCount > 0 then
		table.insert(tbAttribs, {string.format("魂石鑲嵌 (%d/%d)", #tbInsetAttrib, tbInfo.nHoleCount)});
		for i,v in ipairs(tbInsetAttrib) do
			table.insert(tbAttribs, v);
		end

		local _, szFrameColor = Item:GetQualityColor(tbInfo.nInsetLevel); --宝石等级是直接对应quality的
		for i = #tbInsetAttrib + 1, tbInfo.nHoleCount do
			table.insert(tbAttribs, {"", 1, "none", nil, "", "[C8C8C8]（未鑲嵌）[-]", szFrameColor });
		end

	end

	if tbLightAttirb and next(tbLightAttirb) then
		table.insert(tbAttribs, {"附魔屬性"});
		for i,v in ipairs(tbLightAttirb or {}) do
			table.insert(tbAttribs, v);
		end
	end

	return tbAttribs;
end

