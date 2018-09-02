Require("CommonScript/Item/Define.lua")

Item.GoldEquip 			= Item.GoldEquip or {};
local GoldEquip 		= Item.GoldEquip;
GoldEquip.COLOR_ACTVIED 	= "ActiveGreen"; --激活的熟悉颜色
GoldEquip.COLOR_UN_ACTVIED 	= "ASctiveGrey"; --未激活的属性颜色
GoldEquip.GOLD_QUALITY_COLOR = 7;

GoldEquip.MAX_ATTRI_NUM = 3
GoldEquip.MAX_TRAIN_ATTRI_LEVEL = 15 ;--养成属性的最大属性等级为15级
function GoldEquip:Init()
	self.tbEvolutionSetting = LoadTabFile(
	"Setting/Item/GoldEquip/Evolution.tab",
	"dddddds", "SrcItem",
	{"SrcItem", "TarItem", "CosumeItem1", "ConsumeCount1", "CosumeItem2", "ConsumeCount2", "TimeFrame"});

	self.tbEvolutionUpgradeSetting = LoadTabFile(
	"Setting/Item/GoldEquip/EvolutionUpgrade.tab",
	"dddddd", "SrcItem",
	{"SrcItem", "TarItem", "CosumeItem1","ConsumeCount1", "CosumeItem2", "ConsumeCount2"});


	self.tbSuitIndex = LoadTabFile(
		"Setting/Item/GoldEquip/SuitEquip.tab",
		"dd", "ItemId",{"SuitIndex","ItemId" });


	local tbCols = {"SuitIndex", "AttribGroup"}
	local szCols = "dd"
	for i=1, self.MAX_ATTRI_NUM do
		table.insert(tbCols, "ActiveNum" .. i)
		szCols = szCols .. "d";
	end
	self.tbSuitAttribSetting = LoadTabFile(
		"Setting/Item/GoldEquip/SuitAttrib.tab",
		szCols, "SuitIndex", tbCols);


	local tbCols = {"Item",	"AttribGroup", "CostItemId"};
	local szCols = "ddd";
	for i=1,self.MAX_TRAIN_ATTRI_LEVEL do
		table.insert(tbCols, "CostItemCount" .. i)
		table.insert(tbCols, "CostCoin" .. i)
		szCols = szCols .. "d";
	end
	self.tbTrainAttriSetting = LoadTabFile(
		"Setting/Item/GoldEquip/TrainAtriEquip.tab",
		szCols, "Item",
		 tbCols);

end



GoldEquip:Init()


function GoldEquip:GetCosumeItemAutoSelectEquipId(pPlayer, CosumeItemId)
	local tbSrcItems = {};
	for SrcItem, v in pairs(self.tbEvolutionSetting) do
		if v.CosumeItem1 == CosumeItemId or v.CosumeItem2 == CosumeItemId then
			tbSrcItems[SrcItem] = 1;
		end
	end
	local nEquipId;
	local tbEquips = pPlayer.GetEquips()
	for i = Item.EQUIPPOS_HEAD, Item.EQUIPPOS_PENDANT do
		local pEquip = pPlayer.GetEquipByPos(i)
		if pEquip and tbSrcItems[pEquip.dwTemplateId] then
			nEquipId = pEquip.dwId;
			break;
		end
	end
	return nEquipId
end


function GoldEquip:Evolution(pPlayer, nItemId)
	local pItemSrc, nEqiipPos = pPlayer.GetItemInBag(nItemId)
	if not pItemSrc then
		return false
	end

	if pItemSrc.IsEquip() ~= 1 then
		return
	end

	-- if not Item:IsMainEquipPos(pItemSrc.nEquipPos) then
	-- 	return;
	-- end

	local bEquiped = false;
	local pNowEquip = pPlayer.GetEquipByPos(pItemSrc.nEquipPos)
	if pNowEquip and pNowEquip.dwId == pItemSrc.dwId then
		bEquiped = true
	end

	local nTemplateIdSrc = pItemSrc.dwTemplateId
	local tbSetting = self.tbEvolutionSetting[nTemplateIdSrc]
	if not tbSetting then
		return
	end

	if not Lib:IsEmptyStr(tbSetting.TimeFrame)  and GetTimeFrameState(tbSetting.TimeFrame) ~= 1 then
		return false, "當前未開放"
	end

	if tbSetting.CosumeItem1 ~= 0 and tbSetting.ConsumeCount1 ~= 0 then
		if pPlayer.ConsumeItemInAllPos(tbSetting.CosumeItem1, tbSetting.ConsumeCount1, Env.LogWay_GoldEquipEvo)	~= tbSetting.ConsumeCount1 then
			Log(pPlayer.dwID, debug.traceback())
			return
		end
	end

	if tbSetting.CosumeItem2 ~= 0 and tbSetting.ConsumeCount2 ~= 0 then
		if pPlayer.ConsumeItemInAllPos(tbSetting.CosumeItem2, tbSetting.ConsumeCount2, Env.LogWay_GoldEquipEvo)	~= tbSetting.ConsumeCount2 then
			Log(pPlayer.dwID, debug.traceback())
			return
		end
	end


	local tbItemInVals = {}
	for i=1,6 do
		table.insert(tbItemInVals, pItemSrc.GetIntValue(i))
	end

	if  pPlayer.ConsumeItem(pItemSrc, 1, Env.LogWay_GoldEquipEvo) ~= 1 then
		Log(debug.traceback(), pPlayer.dwID)
		return
	end

	local pItemTar = pPlayer.AddItem(tbSetting.TarItem, 1, nil, Env.LogWay_GoldEquipEvo);
	if not pItemTar then
		Log(debug.traceback(), pPlayer.dwID)
		return
	end

	for i,v in ipairs(tbItemInVals) do
		pItemTar.SetIntValue(i, v);
	end

	local tbTrainSetting = self.tbTrainAttriSetting[tbSetting.TarItem]
	if tbTrainSetting then
		pItemTar.SetBaseIntValue(Item.EQUIP_VALUE_TRAIN_ATTRI_LEVEL, 1)
	end

	pItemTar.ReInit();

	pPlayer.TLog("EquipFlow", pItemTar.nItemType, pItemTar.dwTemplateId, pItemTar.dwId, 1, Env.LogWay_GoldEquipEvo, 0, 2, pItemTar.GetIntValue(1),pItemTar.GetIntValue(2), pItemTar.GetIntValue(3), pItemTar.GetIntValue(4), pItemTar.GetIntValue(5),pItemTar.GetIntValue(6), 0 );

	if bEquiped then
		Item:UseEquip(pItemTar.dwId, false, pItemTar.nEquipPos)
	end

	pPlayer.CallClientScript("Item.GoldEquip:OnEvolutionSuccess")
end

function GoldEquip:CanEvolutionTarItem(dwTemplateId)
	local tbSetting = self.tbEvolutionSetting[dwTemplateId]
	if tbSetting then
		if not Lib:IsEmptyStr(tbSetting.TimeFrame) and GetTimeFrameState(tbSetting.TimeFrame) ~= 1 then
			return
		end
		return tbSetting.TarItem
	end
end

function GoldEquip:CanEvolution(pPlayer, dwTemplateId)
	local tbSetting = self.tbEvolutionSetting[dwTemplateId]
	if not tbSetting then
		return false, "無進化配置"
	end
	if not Lib:IsEmptyStr(tbSetting.TimeFrame) and GetTimeFrameState(tbSetting.TimeFrame) ~= 1 then
		return false, "當前未開放"
	end

	if tbSetting.CosumeItem1 ~= 0 and tbSetting.ConsumeCount1 ~= 0 then
		local nHasCount = pPlayer.GetItemCountInAllPos(tbSetting.CosumeItem1)
		if nHasCount < tbSetting.ConsumeCount1 then
			return false, "所需材料不足"
		end
	end
	if tbSetting.CosumeItem2 ~= 0 and tbSetting.ConsumeCount2 ~= 0 then
		local nHasCount = pPlayer.GetItemCountInAllPos(tbSetting.CosumeItem2)
		if nHasCount < tbSetting.ConsumeCount2 then
			return false, "所需材料不足"
		end
	end

	return true;
end

function GoldEquip:GetSuitSetting(nItemId)
	local tb = self.tbSuitIndex[nItemId]
	if not tb then
		return
	end
	return self.tbSuitAttribSetting[tb.SuitIndex]
end

function GoldEquip:GetSuitAttrib(dwTemplateId, pPlayer)
	local tbSetting = self:GetSuitSetting(dwTemplateId)
	if not tbSetting then
		return
	end

	local tbActiedSuitIndex = pPlayer and pPlayer.tbActiedSuitIndex or {};
	--todo 目前是每激活一档只是一个属性,不然现有结构无法用
	local tbAttris = {}
	local tbSuitInfo = {0,0}
	for i= self.MAX_ATTRI_NUM, 1, -1 do
		local nMaxNeedNum = tbSetting["ActiveNum" .. i]
		if nMaxNeedNum ~= 0 then
			tbSuitInfo[1] = nMaxNeedNum
			local nExtAttribGroupID = tbSetting.AttribGroup
			local tbExtAttrib = KItem.GetExternAttrib(nExtAttribGroupID, i);
			if not tbExtAttrib then
				Log(debug.traceback(), nExtAttribGroupID, i)
				break;
			end

			local nNowActived = tbActiedSuitIndex[tbSetting.SuitIndex] or 0
			tbSuitInfo[2] = nNowActived
			for nIndex, v in ipairs(tbExtAttrib) do
				local szDesc  = FightSkill:GetMagicDesc(v.szAttribName, v.tbValue) or "";
				local nActiveNeedNum = tbSetting["ActiveNum" .. nIndex]
				local  nColor = nActiveNeedNum <= nNowActived and self.COLOR_ACTVIED or self.COLOR_UN_ACTVIED;
				table.insert(tbAttris, {string.format("%s  %s", string.format("(%d件)", nActiveNeedNum), szDesc) , nColor})
			end
			break;
		end
	end

	return tbAttris, tbSuitInfo
end

function GoldEquip:GetTrainAttrib(dwTemplateId, nLevel)
	local tbSetting = self.tbTrainAttriSetting[dwTemplateId]
	if not tbSetting then
		return
	end
	if not nLevel or  nLevel == 0  then
		nLevel = 1
	end
	if nLevel > self.MAX_TRAIN_ATTRI_LEVEL then
		return
	end
	local tbExtAttrib = KItem.GetExternAttrib(tbSetting.AttribGroup, nLevel);
	if not tbExtAttrib then
		return
	end

	local tbAttris = {}
	for nIndex, v in ipairs(tbExtAttrib) do
		local szDesc  = FightSkill:GetMagicDesc(v.szAttribName, v.tbValue) or "";
		table.insert(tbAttris, {szDesc , GoldEquip.GOLD_QUALITY_COLOR})
	end
	return tbAttris
end

-- 登陆 脱穿装备时 更新
function GoldEquip:UpdateSuitAttri(pPlayer)
	if pPlayer.tbActiedSuitIndex then --玩家 身上已经激活的套装属性
		for SuitIndex, nActiveNum in pairs(pPlayer.tbActiedSuitIndex) do
			local tbSetting = self.tbSuitAttribSetting[SuitIndex]
			if tbSetting then
				pPlayer.RemoveExternAttrib(tbSetting.AttribGroup)
			end
		end
	end

	local tbSuitIndexs = {}
	local tbEquips = pPlayer.GetEquips()
	for i, nItemId in pairs(tbEquips) do
		local pEquip = pPlayer.GetItemInBag(nItemId)
		if pEquip then
			local tbSetting = self:GetSuitSetting(pEquip.dwTemplateId)
	        if tbSetting then
	            tbSuitIndexs[tbSetting.SuitIndex] = (tbSuitIndexs[tbSetting.SuitIndex] or 0) + 1;
	        end

		end
	end
	local tbSaveAsyncVals = {}
    for SuitIndex, nActiveNum in pairs(tbSuitIndexs) do
        local tbSetting = self.tbSuitAttribSetting[SuitIndex]
        if tbSetting then
            for i = self.MAX_ATTRI_NUM, 1, -1 do
                local nActiveNeedNum = tbSetting["ActiveNum" .. i]
                if nActiveNeedNum <= nActiveNum then
                    pPlayer.ApplyExternAttrib(tbSetting.AttribGroup, i)
                    table.insert(tbSaveAsyncVals, tbSetting.AttribGroup * 100 + i)
                    break;
                end
            end
        end
    end

	pPlayer.tbActiedSuitIndex = tbSuitIndexs

	if MODULE_GAMESERVER then
		local pAsyncData = KPlayer.GetAsyncData(pPlayer.dwID)
		if pAsyncData then
			for i = 1,10 do
				local nVal = tbSaveAsyncVals[i] or 0
				pAsyncData.SetSuit(i, nVal)
				if nVal == 0 then
					break;
				end
			end
		end
	end
end

--异步数据加载时用到
function GoldEquip:UpdateTrainAttriToNpc(pNpc, tbEquipTemplates, tbEquipTranLevels)
	for nPos, nAttriLevel in pairs(tbEquipTranLevels) do
		local dwTemplateId = tbEquipTemplates[nPos]
		local tbSetting = self.tbTrainAttriSetting[dwTemplateId]
		if tbSetting then
			pNpc.ApplyExternAttrib(tbSetting.AttribGroup, nAttriLevel)
		end
	end
end

--这个 登陆，脱穿时 最好是跟着C里脱穿装备走
function GoldEquip:UpdateTrainAttri(pPlayer, nEquipPos)
	local tbApplyedTrainAttri = pPlayer.tbApplyedTrainAttri or {};

	local nActiveGroup = tbApplyedTrainAttri[nEquipPos]
	if nActiveGroup then
		pPlayer.RemoveExternAttrib(nActiveGroup)
		tbApplyedTrainAttri[nEquipPos] = nil;
	end

	local pEquip = pPlayer.GetEquipByPos(nEquipPos)
	if pEquip then
		local tbSetting = self.tbTrainAttriSetting[pEquip.dwTemplateId]
		if tbSetting then
			local nLevel = pEquip.GetBaseIntValue(Item.EQUIP_VALUE_TRAIN_ATTRI_LEVEL)
			if nLevel > 0 then
				pPlayer.ApplyExternAttrib(tbSetting.AttribGroup, nLevel)
				tbApplyedTrainAttri[nEquipPos] = tbSetting.AttribGroup
			end
		end
	end

	pPlayer.tbApplyedTrainAttri = tbApplyedTrainAttri;
end

function GoldEquip:OnLogin(pPlayer)
	self:UpdateSuitAttri(pPlayer)
	for nEquipPos = Item.EQUIPPOS_HEAD, Item.EQUIPPOS_PENDANT do
		self:UpdateTrainAttri(pPlayer, nEquipPos)
	end
end

function GoldEquip:UpgradeEquipTrainLevel(pPlayer, nItemId)
	local pEquip = pPlayer.GetItemInBag(nItemId)
	if not pEquip then
		return
	end
	local nNowLevel = pEquip.GetBaseIntValue(Item.EQUIP_VALUE_TRAIN_ATTRI_LEVEL)
	if nNowLevel == 0 then
		return
	end
	local tbSetting = self.tbTrainAttriSetting[pEquip.dwTemplateId]
	if not tbSetting then
		return
	end

	local nNextLevel = nNowLevel + 1
	if nNextLevel > self.MAX_TRAIN_ATTRI_LEVEL then
		return
	end

	local nCousumeCount, nConsumeCoin = tbSetting["CostItemCount" .. nNextLevel], tbSetting["CostCoin" .. nNextLevel]
	if not  nCousumeCount or not nConsumeCoin then
		Log(debug.traceback(), pEquip.dwTemplateId, nNextLevel)
		return
	end

	if not pPlayer.CostMoney("Coin", nConsumeCoin, Env.LogWay_TrainEquipAttri) then
		return
	end

	if pPlayer.ConsumeItemInAllPos(tbSetting.CostItemId, nCousumeCount, Env.LogWay_TrainEquipAttri) ~= nCousumeCount then
		Log(debug.traceback(), pEquip.dwTemplateId, nNextLevel)
		return
	end

	pEquip.SetBaseIntValue(Item.EQUIP_VALUE_TRAIN_ATTRI_LEVEL, nNextLevel)
	Log("GoldEquip:UpgradeEquipTrainLevel", pPlayer.dwID, pEquip.dwTemplateId, nNextLevel, nItemId)
	self:UpdateTrainAttri(pPlayer, pEquip.nEquipPos)

	pPlayer.CallClientScript("Item.GoldEquip:OnUpgradeEquipTrainLevelSuc", pEquip.nEquipPos)
end

function GoldEquip:CanEquipTrainAttris(pPlayer, nItemId)
	local pEquip = pPlayer.GetItemInBag(nItemId)
	if not pEquip then
		return
	end
	local nNowLevel = pEquip.GetBaseIntValue(Item.EQUIP_VALUE_TRAIN_ATTRI_LEVEL)
	if nNowLevel == 0 then
		return false, "未進化過"
	end
	local tbSetting = self.tbTrainAttriSetting[pEquip.dwTemplateId]
	if not tbSetting then
		return
	end

	local nNextLevel = nNowLevel + 1
	local tbExtAttrib = KItem.GetExternAttrib(tbSetting.AttribGroup, nNextLevel);
	if not tbExtAttrib then
		return
	end
	if pPlayer.GetItemCountInAllPos(tbSetting.CostItemId) <  tbSetting["CostItemCount" .. nNextLevel] then
		return false, "所需材料不足"
	end
	if pPlayer.GetMoney("Coin") < tbSetting["CostCoin" .. nNextLevel] then
		return false, "所需銀兩不足"
	end

	return true;
end

--C
function GoldEquip:OnEvolutionSuccess()
	UiNotify.OnNotify(UiNotify.emNOTIFY_EQUIP_EVOLUTION, true)
end

--C
function GoldEquip:OnUpgradeEquipTrainLevelSuc(nEquipPos)
	self:UpdateTrainAttri(me, nEquipPos)
	me.CenterMsg("精煉成功！")
	UiNotify.OnNotify(UiNotify.emNOTIFY_EQUIP_TRAIN_ATTRIB, true)
end

function GoldEquip:GetEvolutionSetting(dwTemplateId)
	return self.tbEvolutionSetting[dwTemplateId]
end

function GoldEquip:GetTrainAttriSetting( dwTemplateId )
	return self.tbTrainAttriSetting[dwTemplateId]
end


--进阶
function GoldEquip:CanUpgradeTarItem(dwTemplateId)
	local tbSetting = self.tbEvolutionUpgradeSetting[dwTemplateId]
	if tbSetting then
		return tbSetting.TarItem
	end
end

function GoldEquip:GetUpgradeSetting(dwTemplateId)
	return self.tbEvolutionUpgradeSetting[dwTemplateId]
end

function GoldEquip:CanUpgrade(pPlayer, dwTemplateId)
	local tbSetting = self.tbEvolutionUpgradeSetting[dwTemplateId]
	if not tbSetting then
		return false, "無升階配置"
	end

	if tbSetting.CosumeItem1 ~= 0 and tbSetting.ConsumeCount1 ~= 0 then
		local nHasCount = pPlayer.GetItemCountInAllPos(tbSetting.CosumeItem1)
		if nHasCount < tbSetting.ConsumeCount1 then
			return false, "所需材料不足"
		end
	end
	if tbSetting.CosumeItem2 ~= 0 and tbSetting.ConsumeCount2 ~= 0 then
		local nHasCount = pPlayer.GetItemCountInAllPos(tbSetting.CosumeItem2)
		if nHasCount < tbSetting.ConsumeCount2 then
			return false, "所需材料不足"
		end
	end

	return true;
end

--客户端
function GoldEquip:DoClietnUpgrade( pCostItem ) --消耗掉的 T6黄金
	local tbSetting = self.tbEvolutionUpgradeSetting[pCostItem.dwTemplateId]
	local TarItem = tbSetting.TarItem
	local tbSrcItems = me.FindItemInPlayer(tbSetting.CosumeItem1) --消耗掉的T7 稀有
	local pOriSrcItem = tbSrcItems[1]
	assert(pOriSrcItem)

	local pSrcEquip = Item:AddFakeItem(tbSetting.CosumeItem1)
	local pTarEquip = Item:AddFakeItem(TarItem)

	for i=1,6 do
		pSrcEquip:SetIntValue(i,  pOriSrcItem.GetIntValue(i))
		pTarEquip:SetIntValue(i,  pCostItem.GetIntValue(i)) --目标的T7黄金，属性是和一开始的T6黄金是一样的
	end

	pSrcEquip.nRealLevel = pOriSrcItem.nRealLevel
	pTarEquip.nRealLevel = pSrcEquip.nRealLevel + 1 -- TODO ，目标的real Level现在没法获取，下次版本加上吧

	local tbRefinemRecord = {
		SrcItemId = pOriSrcItem.dwId,
		CostItemId = pCostItem.dwId,
		nCoin = 0,
		tbRefineIndex = {},
		nFakeSrcId = pSrcEquip.dwId,
		nFakeTarId = pTarEquip.dwId,
	}
	Ui:OpenWindow("RefinementPanel", pSrcEquip.dwId, pTarEquip.dwId, tbRefinemRecord)
end

function GoldEquip:CheckDoUpgradeParam(pPlayer, tbRefinemRecord)
	local pSrcItem = pPlayer.GetItemInBag(tbRefinemRecord.SrcItemId) --消耗T7稀有
	if not pSrcItem then
		return false, "1"
	end
	local pCostItem = pPlayer.GetItemInBag(tbRefinemRecord.CostItemId)--消耗掉的T6黄金
	if not pCostItem then
		return false, "2"
	end

	local tbSetting = self.tbEvolutionUpgradeSetting[pCostItem.dwTemplateId]
	if not tbSetting then
		return false, "3"
	end

	if tbSetting.CosumeItem1 ~= pSrcItem.dwTemplateId then
		return false, "4"
	end

	local tbRefineIndex = tbRefinemRecord.tbRefineIndex
	if tbRefinemRecord.nCoin == 0  then
		if next(tbRefineIndex) then
			return false, "5"
		end
	else

		if not next(tbRefineIndex) then
			return false, "6"
		end
		local nCostTotal = 0
		local tbOldAllVals = {}
		for i=1,6 do
			table.insert(tbOldAllVals, pSrcItem.GetIntValue(i))
		end
		--检查是否所有的 nSrcVal 都在pSrcItem 里出现
		for nTarPos, nSrcVal in pairs(tbRefineIndex) do
			local bFound = false
			for k,v in pairs(tbOldAllVals) do
				if nSrcVal == v then
					bFound = true
					tbOldAllVals[k] = nil;
					break;
				end
			end
			if not bFound then
				return false, "6" .. nTarPos
			end
		end

		for nTarPos, nSrcVal in pairs(tbRefineIndex) do
			if nTarPos < 1 or nTarPos > 6 then
				return false, "7"
			end
			if nSrcVal == 0 then
				return false, "9"
			end
			local nCurCost = Item.tbRefinement:GetRefineCost(nSrcVal, pSrcItem.nItemType)
			if nCurCost == 0 then
				return false, "10"
			end
			nCostTotal = nCostTotal + nCurCost

		end

		if nCostTotal ~= tbRefinemRecord.nCoin then
			return false, "11"
		end


		if pPlayer.GetMoney("Coin") < nCostTotal then
			return false, "銀兩不足"
		end
	end
	return true
end

function GoldEquip:ClientPorcessUpgrade(tbRefinemRecord)
	local nFakeSrcId = tbRefinemRecord.nFakeSrcId
	local nFakeTarId = tbRefinemRecord.nFakeTarId
	tbRefinemRecord.nFakeSrcId = nil;
	tbRefinemRecord.nFakeTarId = nil;

	local bRet, szMsg = self:CheckDoUpgradeParam(me, tbRefinemRecord)
	if bRet then
		RemoteServer.RequestEquipUpgrade(tbRefinemRecord)
	else
		me.CenterMsg( szMsg or "裝備進階參數錯誤", true)
	end

	Item:RemoveFakeItem(nFakeSrcId)
	Item:RemoveFakeItem(nFakeTarId)
end


function GoldEquip:ServerDoEquipUpgrade(pPlayer, tbRefinemRecord)
	local bRet, szMsg = self:CheckDoUpgradeParam(pPlayer, tbRefinemRecord)
	if not bRet then
		return
	end
	local pSrcItem = pPlayer.GetItemInBag(tbRefinemRecord.SrcItemId) --消耗T7稀有
	if not pSrcItem then
		return
	end
	local pCostItem = pPlayer.GetItemInBag(tbRefinemRecord.CostItemId)--消耗掉的T6黄金
	if not pCostItem then
		return
	end

	local tbSetting = self.tbEvolutionUpgradeSetting[pCostItem.dwTemplateId]
	if not tbSetting then
		return
	end

	local tbItemInVals = {}
	for i=1,6 do
		table.insert(tbItemInVals, pCostItem.GetIntValue(i))
	end

	for k,v in pairs(tbRefinemRecord.tbRefineIndex) do --这里的 tbRefineIndex 已经全部验证过是属于消耗掉的t7稀有上面的
		tbItemInVals[k] = v;
	end

	if tbRefinemRecord.nCoin ~= 0  then
		if not pPlayer.CostMoney("Coin", tbRefinemRecord.nCoin, Env.LogWay_GoldEquipUpgrade) then
			Log(pPlayer.dwID, debug.traceback())
			return
		end
	end

	if tbSetting.CosumeItem2 ~= 0 and tbSetting.ConsumeCount2 ~= 0 then
		if pPlayer.ConsumeItemInAllPos(tbSetting.CosumeItem2, tbSetting.ConsumeCount2, Env.LogWay_GoldEquipUpgrade)	~= tbSetting.ConsumeCount2 then
			Log(pPlayer.dwID, debug.traceback())
			return
		end
	end

	if not pSrcItem.Delete(Env.LogWay_GoldEquipUpgrade) then
		Log(pPlayer.dwID, debug.traceback())
		return
	end

	if not pCostItem.Delete(Env.LogWay_GoldEquipUpgrade) then
		Log(pPlayer.dwID, debug.traceback())
		return
	end

	local pItemTar = pPlayer.AddItem(tbSetting.TarItem, 1, nil, Env.LogWay_GoldEquipUpgrade)
	if not pItemTar then
		Log(pPlayer.dwID, debug.traceback())
		return
	end

	for i,v in pairs(tbItemInVals) do
		pItemTar.SetIntValue(i, v);
	end

	pItemTar.ReInit();

	pPlayer.TLog("EquipFlow", pItemTar.nItemType, pItemTar.dwTemplateId, pItemTar.dwId, 1, Env.LogWay_GoldEquipUpgrade, 0, 2, pItemTar.GetIntValue(1),pItemTar.GetIntValue(2), pItemTar.GetIntValue(3), pItemTar.GetIntValue(4), pItemTar.GetIntValue(5),pItemTar.GetIntValue(6),0 );

	local pNowEquip = pPlayer.GetEquipByPos(pItemTar.nEquipPos)
	if not pNowEquip then
		Item:UseEquip(pItemTar.dwId, false, pItemTar.nEquipPos)
	end

	pPlayer.CallClientScript("Item.GoldEquip:OnEvolutionSuccess")
end

function GoldEquip:IsShowHorseUpgradeRed(pPlayer)
	for nEquipPos,v in pairs(Item.tbHorseItemPos) do
		local pEquip2 = pPlayer.GetEquipByPos(nEquipPos);
		if pEquip2 and Item.GoldEquip:CanEvolution(pPlayer, pEquip2.dwTemplateId) then
			return true
		end
	end
	return false
end

function GoldEquip:IsHaveHorseUpgradeItem(pPlayer)
	for nEquipPos,v in pairs(Item.tbHorseItemPos) do
		local pEquip2 = pPlayer.GetEquipByPos(nEquipPos);
		if pEquip2 and self:CanEvolutionTarItem(pEquip2.dwTemplateId) then
			return true
		end
	end
	return false
end