Require("CommonScript/Item/Define.lua")

Item.tbRefinement 	= Item.tbRefinement or {};
local tbRefinement 	= Item.tbRefinement;


local NORMAL_MAX_ATTRIB = 5;
local GOLD_MAX_ATTRIB = 6;

local tbNumSetting = LoadTabFile(
	"Setting/Item/RandomAttrib/AttribNum.tab", 
	"ddddddd", "RealLevel", 
	{"RealLevel", "Count1", "Count2", "Count3", "Count4", "Count5", "ExtAttribLevel"});

local tbTypeSetting = LoadTabFile(
	"Setting/Item/RandomAttrib/AttribType.tab", 
	"ssd", nil, 
	{"EquipType", "Attrib", "Probility"});

local tbLevelSetting = LoadTabFile(
	"Setting/Item/RandomAttrib/AttribLevel.tab", 
	"ddd", nil, 
	{"RealLevel", "AttribLevel", "Probility",});		-- XXX

local tbAttribQuality = LoadTabFile(
	"Setting/Item/RandomAttrib/AttribQuality.tab", 
	"ddd", nil, 
	{"EquipLevel", "AttribLevel", "Quality",});		-- XXX


local tbCustomEquipSetting = LoadTabFile(
	"Setting/Item/CustomEquip.tab", 
	"dsdsdsdsdsdsd", "TemplateId",
	{"TemplateId",
	"AttribType1","AttribLevel1",
	"AttribType2","AttribLevel2",
	"AttribType3","AttribLevel3",
	"AttribType4","AttribLevel4",
	"AttribType5","AttribLevel5",
	"AttribType6","AttribLevel6",});

local tbGoldEquipSetting = LoadTabFile(
	"Setting/Item/GoldEquip.tab", 
	"dd", "TemplateId",
	{"TemplateId","AttribLevel"});

function tbRefinement:TrimSetting()
	self.tbRandomNum = {}
	self.tbExtAttrib = {};
	for nRealLevel,v in pairs(tbNumSetting) do
		self.tbRandomNum[nRealLevel] = {v.Count1, v.Count2, v.Count3, v.Count4, v.Count5};
		self.tbExtAttrib[nRealLevel] = v.ExtAttribLevel;
	end

	self.tbType = {};
	for _, v in pairs(tbTypeSetting) do
		self.tbType[v.EquipType] = self.tbType[v.EquipType] or {};
		self.tbType[v.EquipType][v.Attrib] = v.Probility;
	end

	self.tbLevel = {};
	for _,v in pairs(tbLevelSetting) do
		self.tbLevel[v.RealLevel] = self.tbLevel[v.RealLevel] or {};
		self.tbLevel[v.RealLevel][v.AttribLevel] = v.Probility;
	end

	self.tbColor = {};
	for _, v in pairs(tbAttribQuality) do
		self.tbColor[v.EquipLevel*100 + v.AttribLevel] = v.Quality;
	end

	self.tbTypeAttribValue = {}; --不同道具类型对应不同的属性表
	--不同装备类型对应的属性文件
	local tbAttribSetFiles = {
		{"Setting/Item/RandomAttrib/AttribValWeapon.tab", Item.EQUIP_WEAPON},
		{"Setting/Item/RandomAttrib/AttribValCloth.tab",  Item.EQUIP_ARMOR},
		{"Setting/Item/RandomAttrib/AttribValJewelry.tab",Item.EQUIP_RING, Item.EQUIP_NECKLACE, Item.EQUIP_AMULET, Item.EQUIP_PENDANT },
		{"Setting/Item/RandomAttrib/AttribValArmor.tab",   Item.EQUIP_BOOTS, Item.EQUIP_BELT, Item.EQUIP_HELM, Item.EQUIP_CUFF },
		{"Setting/Item/RandomAttrib/AttribValZhenYuan.tab", Item.EQUIP_ZHEN_YUAN},
	}

	for nKind, tbCol in ipairs(tbAttribSetFiles) do
		local tbAttribSetting = LoadTabFile(
			tbCol[1], 
			"sdddddds", nil, 
			{"AttribType", "Level", "FightPower", "AttribValue", "Value1", "Value2", "Value3", "SpecialDesc"});
		local tbKindInfo = {}
		for _,v in pairs(tbAttribSetting) do
			tbKindInfo[v.AttribType] = tbKindInfo[v.AttribType] or {};
			tbKindInfo[v.AttribType][v.Level] = 
			{
				tbMA = {v.Value1, v.Value2, v.Value3},
				nAttribValue = v.AttribValue,
				nFightPower = v.FightPower,
				szSpecialDesc = v.SpecialDesc,
			}
		end

		for i = 2, #tbCol do
			self.tbTypeAttribValue[ tbCol[i] ] = tbKindInfo
		end
	end
		
	self.tbCustomEquip 	= tbCustomEquipSetting;


	--只是洗练的用，因为存盘时转成了ID，ID值一旦添加后不能更改的,可以与C里的枚举值不一样,为兼顾前面数据就前面的取的是C里枚举值
	local tbAttribCharToId = {};
	local tbAttribIdToChar = {};
	local tbFile = LoadTabFile(  
	"Setting/Item/RandomAttrib/AttribSaveId.tab", 
	"sd", nil, 
	{"Attrib", "Id"});
	for i,v in ipairs(tbFile) do
		tbAttribCharToId[v.Attrib] = v.Id
		assert(not tbAttribIdToChar[v.Id], v.Attrib)
		tbAttribIdToChar[v.Id] = v.Attrib
	end

	if MODULE_GAMESERVER then
		for EquipType,v in pairs(self.tbType) do
			for Attrib, _ in pairs(v) do
				assert(tbAttribCharToId[Attrib], EquipType .. ", " .. Attrib)
			end
		end
	end
	
	self.tbAttribCharToId = tbAttribCharToId;
	self.tbAttribIdToChar = tbAttribIdToChar;
end

tbRefinement:TrimSetting();

function tbRefinement:GetCustomAttri(dwTemplateId, tbForbid)
	local tbAttribs = self.tbCustomEquip[dwTemplateId]
	if not tbAttribs then
		return
	end
	local tbSaveAttribs = {}
	for i = Item.EQUIP_RANDOM_ATTRIB_VALUE_BEGIN, Item.EQUIP_RANDOM_ATTRIB_VALUE_END do
		local szAttrib = tbAttribs["AttribType"..i];
		local nLevel = tbAttribs["AttribLevel"..i];
		if szAttrib and nLevel and szAttrib ~= "" and nLevel ~= 0 then
			local nAttribId = self:AttribCharToId(szAttrib);
			local nSave = self:AttribToSaveData(nAttribId, nLevel);
			table.insert(tbSaveAttribs, nSave);
			if tbForbid then
				tbForbid[szAttrib] = true
			end
		end
	end
	return tbSaveAttribs
end

-- Server 属性生成
function tbRefinement:OnGenerate(pEquip)
	local tbSaveAttribs = {};
	local tbForbid = {};
	local nCustomCount = 0;

	local tbCustomAttri = self:GetCustomAttri(pEquip.dwTemplateId, tbForbid)
	if tbCustomAttri  then -- 定制装备
		for _,nSave in ipairs(tbCustomAttri) do
			table.insert(tbSaveAttribs, nSave);
		end
		nCustomCount = #tbCustomAttri
	end

	local nRealLevel, nEquipType = pEquip.nRealLevel, pEquip.nItemType;
	local szEquipType = Item.EQUIPTYPE_EN_NAME[nEquipType];

	if not tbCustomAttri then -- 定制装备没有随机属性
		if self.tbExtAttrib[nRealLevel] and self.tbExtAttrib[nRealLevel] > 0 then -- 稀有装备，额外多一条属性定制属性的等级。
			local nFixLevel = self.tbExtAttrib[nRealLevel]
			local szAttrib = self:RandomAttribType(szEquipType, tbForbid);
			local nAttribId = self:AttribCharToId(szAttrib);
			local nSave = self:AttribToSaveData(nAttribId, nFixLevel);
			if #tbSaveAttribs == 0 then -- 稀有属性为第一条属性
				table.insert(tbSaveAttribs, nSave);
			else
				local tbTemp = {};
				table.insert(tbTemp, nSave);
				for i,v in ipairs(tbSaveAttribs) do
					table.insert(tbTemp, v);
				end
				tbSaveAttribs = tbTemp;
			end
		end
		local nCreateCount = self:RandomCount(nRealLevel) - nCustomCount;
		for i = 1, nCreateCount do

			local szAttrib = self:RandomAttribType(szEquipType, tbForbid);
			local nLevel = self:RandomAttribLevel(nRealLevel);
			local nAttribId = self:AttribCharToId(szAttrib);	-- XXX
			local nSave = self:AttribToSaveData(nAttribId, nLevel);		-- 左移16位，ID为高16位，等级为低16位
			table.insert(tbSaveAttribs, nSave);
		end
	end

	for nPos, nSave in pairs(tbSaveAttribs) do
		self:ChangeRandomAttrib(pEquip, nPos, nSave);
	end
end

function tbRefinement:InitEquip(pEquip)
	local tbAttribs = self:GetRandomAttrib(pEquip);
	local nMaxQuality = 0;
	local nRefineValue = 0;
	local nRefinePower = 0;
	for nIdx, tbAttrib in ipairs(tbAttribs) do
		local nQuality = self:GetAttribColor(pEquip.nLevel, tbAttrib.nAttribLevel);
		local tbSetting = self:GetAttribSetting(tbAttrib.szAttrib, tbAttrib.nAttribLevel, pEquip.nItemType);
		if tbSetting then
			pEquip.SetRandAttrib(nIdx, tbAttrib.szAttrib, unpack(tbSetting.tbMA))
			nRefineValue = nRefineValue + tbSetting.nAttribValue
			nRefinePower = nRefinePower + tbSetting.nFightPower
		end
		
		if nMaxQuality < nQuality then
			nMaxQuality = nQuality;
		end
	end
	return nRefinePower, nRefineValue, nMaxQuality;
end

function tbRefinement:GetFightPowerFromSaveAttri(nLevel, tbSaveRandomAttrib, nItemType)
	local nRefinePower = 0
	local tbAttribs = self:GetRandomAttribByTable(tbSaveRandomAttrib)
	for nIdx, tbAttrib in ipairs(tbAttribs) do
		local tbSetting = self:GetAttribSetting(tbAttrib.szAttrib, tbAttrib.nAttribLevel, nItemType);
		if tbSetting then
			nRefinePower = nRefinePower + tbSetting.nFightPower
		end
	end
	return nRefinePower
end

-- Server 属性生成 * 随属性条数
function tbRefinement:RandomCount(nRealLevel)
	local tbNum = self.tbRandomNum[nRealLevel];
	if not tbNum then
		Log("[ERROR] RandomCount error in", nRealLevel);
		return 0;
	end
	local nAttribCount;

	local nRan = MathRandom(0, 1000);

	for nCount, nProb in pairs(tbNum) do
		nRan = nRan - nProb;
		if nRan <= 0 then
			nAttribCount = nCount;
			break;
		end
	end

	return nAttribCount;
end

-- Server 属性生成 * 随属性类别
function tbRefinement:RandomAttribType(szEquipType, tbForbid)
	local szAttrib;
	local nTotoalProb = 0;
	local tbTypeAndProb = self.tbType[szEquipType]

	local tbfilter = {};
	for szType, nProb in pairs(tbTypeAndProb) do
		if not tbForbid[szType] then
			table.insert(tbfilter, {szType, nProb});
			nTotoalProb = nTotoalProb + nProb;
		end
	end

	local nRan = MathRandom(0, nTotoalProb);
	for i, v in ipairs(tbfilter) do
		nRan = nRan - v[2];
		if nRan <= 0 then
			szAttrib = v[1];
			break;
		end
	end

	assert(szAttrib, "[ERROR] RandomAttribType NULL");
	tbForbid[szAttrib] = true;
	return szAttrib;
end

-- Server 属性生成 * 随属性等级
function tbRefinement:RandomAttribLevel(nRealLevel)
	local nAttribLevel;
	local nTotoalProb = 0;

	local tbLevelAndProb = self.tbLevel[nRealLevel];
	for _, nProb in pairs(tbLevelAndProb) do
		nTotoalProb = nTotoalProb + nProb;
	end

	local nRan = MathRandom(0, nTotoalProb);
	for nLevel, nProb in pairs(tbLevelAndProb) do
		nRan = nRan - nProb;
		if nRan <= 0 then
			nAttribLevel = nLevel;
			break;
		end
	end

	return nAttribLevel;
end

function tbRefinement:GetFullRefineCount(pPlayer)
	local tbEquips =  pPlayer.GetEquips();
	local nFull = 0
	for _, nEquipId in pairs(tbEquips) do
		local pEquip = pPlayer.GetItemInBag(nEquipId);
		if pEquip then
			local tbEquipAttribs = self:GetRandomAttrib(pEquip);
			if #tbEquipAttribs >= 6 then
				nFull = nFull + 1
			end
		end
	end
	return nFull
end

-- Server 洗练
function tbRefinement:Refinement(pPlayer, nTarId, nSrcId, nTarPos, nSrcPos)
	local pItemTar = pPlayer.GetItemInBag(nTarId);
	local pItemSrc = pPlayer.GetItemInBag(nSrcId);

	if not pItemTar or not pItemSrc then
		return false;
	end



	if not (pItemTar.IsEquip() == 1 and pItemTar.IsEquip() == 1) then
		return false;
	end
	
	local tbSrcAttribs 		= self:GetRandomAttrib(pItemSrc);
	local tbTarAttribs 		= self:GetRandomAttrib(pItemTar);
	local tbSrcAttrib 		= tbSrcAttribs[nSrcPos];
	if not tbSrcAttrib then
		return false
	end

	if not self:CanDoRefinement(pItemTar, pItemSrc, tbTarAttribs, tbSrcAttrib, nTarPos) then
		return false
	end

	nTarPos = nTarPos or #tbTarAttribs + 1;

	local nItemType = pItemTar.nItemType
	if not pPlayer.CostMoney("Coin", self:GetRefineCost(tbSrcAttrib.nSaveData, pItemTar.nItemType), Env.LogWay_Refinement) then
		return false
	end

	self:ReduceRandomAttrib(pItemSrc, tbSrcAttrib.szAttrib);
	self:ChangeRandomAttrib(pItemTar, nTarPos, tbSrcAttrib.nSaveData);
	pItemTar.ReInit();
	FightPower:ChangeFightPower(FightPower:GetFightPowerTypeByEquipPos(pItemTar.nEquipPos), pPlayer)
	
	EverydayTarget:AddCount(pPlayer, "EquipRefinement")

	pPlayer.TLog("EquipFlow", pItemTar.nItemType, pItemTar.dwTemplateId, pItemTar.dwId, 1, Env.LogWay_Refinement, 0, 2, pItemTar.GetIntValue(1),pItemTar.GetIntValue(2), pItemTar.GetIntValue(3), pItemTar.GetIntValue(4), pItemTar.GetIntValue(5),pItemTar.GetIntValue(6), pItemTar.GetIntValue(7) );
	pPlayer.TLog("EquipFlow", pItemSrc.nItemType, pItemSrc.dwTemplateId, pItemSrc.dwId, 1, Env.LogWay_Refinement, 0, 3, pItemSrc.GetIntValue(1),pItemSrc.GetIntValue(2), pItemSrc.GetIntValue(3), pItemSrc.GetIntValue(4), pItemSrc.GetIntValue(5),pItemSrc.GetIntValue(6), pItemTar.GetIntValue(7) );
	Log("Refinement", pPlayer.szAccount, pPlayer.dwID, pItemTar.dwTemplateId, pItemSrc.dwTemplateId, nTarPos, nSrcPos, nTarAttrLevel, tbSrcAttrib.nAttribLevel);
	
	--3.将一条粉色属性洗练到装备上
	local nItemTarLevel = pItemTar.nLevel
	local nColor =  self:GetAttribColor(nItemTarLevel, tbSrcAttrib.nAttribLevel, nItemType);
	if nColor == 6 then
		Achievement:AddCount(pPlayer, "EquipRefinement_3", 1);
	end

	--太多了... 这条不包括上面2种
	--之前有bug导致 公测玩家先完成了 身上所有装备洗满6条紫色以上属性 就一直没法完成4级的 将身上一件装备洗满6条紫色以上属性	
	--1.成功完成一次装备洗练
	Achievement:AddCount(pPlayer, "EquipRefinement_1", 1);
	
	--2.将身上一件装备洗满6条属性
	tbTarAttribs = self:GetRandomAttrib(pItemTar);
	if #tbTarAttribs == 6 then
		Achievement:AddCount(pPlayer, "EquipRefinement_2", 1);
		TeacherStudent:OnEquipWashed(pPlayer)
		--5. 身上所有装备洗满6条紫色以上属性
		local tbEquips =  pPlayer.GetEquips();
		local nFullPurple = 0

		for _, nEquipId in pairs(tbEquips) do
			local pEquip = pPlayer.GetItemInBag(nEquipId);
			if pEquip then
				local tbEquipAttribs = self:GetRandomAttrib(pEquip);
				if #tbEquipAttribs < 6 then
					break;
				end
				local bBreak = false;
				for i, v in ipairs(tbEquipAttribs) do
					if self:GetAttribColor(nItemTarLevel, v.nAttribLevel, nItemType) < 4 then
						bBreak = true;
						break;
					end
				end
				if bBreak then
					break;
				end
			else
				break;
			end
			nFullPurple = nFullPurple + 1
		end
		if nFullPurple == Item.EQUIPPOS_MAIN_NUM  then
			Achievement:AddCount(pPlayer, "EquipRefinement_5", 1);
		else
			local bFullPurple = true
			for i, v in ipairs(tbTarAttribs) do
				if self:GetAttribColor(nItemTarLevel, v.nAttribLevel, nItemType) < 4 then
					bFullPurple = false
					break;
				end
			end
			if bFullPurple then
				Achievement:AddCount(pPlayer, "EquipRefinement_4", 1);			
			end
		end
	end

	return true;
end

function tbRefinement:IsCanDoRefinementItemPos(nEquipPos)
	 if Item:IsMainEquipPos(nEquipPos) then
	 	return true
	 end
	 return nEquipPos == Item.EQUIPPOS_ZHEN_YUAN
end

function tbRefinement:CanDoRefinement(pItemTar, pItemSrc, tbTarAttribs, tbSrcAttrib, nTarPos)
	if pItemTar.nItemType ~= pItemSrc.nItemType then
		return false;
	end

	if not self:IsCanDoRefinementItemPos(pItemTar.nEquipPos) or not self:IsCanDoRefinementItemPos(pItemSrc.nEquipPos) then
		return false;
	end	

	if not self:CanAddAttrib(pItemTar, tbSrcAttrib.nAttribId, tbSrcAttrib.nAttribLevel) then
		return false;
	end

	local bReplace = nTarPos ~= nil; -- 替换 or 新增
	local nTarAttrLevel;
	if self:IsExistSameTypeAttrib(tbTarAttribs, tbSrcAttrib.szAttrib) then
		if bReplace then
			local tbTarAttrib = tbTarAttribs[nTarPos];
			if tbTarAttrib.szAttrib ~= tbSrcAttrib.szAttrib then
				return;
			end	
			nTarAttrLevel = tbTarAttrib.nAttribLevel;
			if nTarAttrLevel > tbSrcAttrib.nAttribLevel then
				return false, "不能將同類型屬性洗練成低等級的"
			end
		else
			return false;
		end
	end

	local nFullCount = self:GetAttribFullCount(pItemTar.dwTemplateId);
	nTarPos = nTarPos or #tbTarAttribs + 1;
	if nTarPos > nFullCount  then
		return false;
	end
	return true
end

-- 假道具的洗练 客户端模拟
function tbRefinement:FakeRefinement(pPlayer, pItemTar, pItemSrc, nTarPos, nSrcPos, tbRecord)
	if not pItemTar or not pItemSrc or not tbRecord then
		return false;
	end

	local tbSrcAttribs 		= self:GetRandomAttrib(pItemSrc);
	local tbTarAttribs 		= self:GetRandomAttrib(pItemTar);
	local tbSrcAttrib 		= tbSrcAttribs[nSrcPos];
	if not tbSrcAttrib then
		return false
	end

	if not self:CanDoRefinement(pItemTar, pItemSrc, tbTarAttribs, tbSrcAttrib, nTarPos) then
		return false
	end

	local nTotalCost = tbRecord.nCoin + self:GetRefineCost(tbSrcAttrib.nSaveData, pItemTar.nItemType)
	if pPlayer.GetMoney("Coin") < nTotalCost then
		return false, "銀兩不足"
	end
	tbRecord.nCoin = nTotalCost

	nTarPos = nTarPos or #tbTarAttribs + 1;

	tbRecord.tbRefineIndex[nTarPos] = tbSrcAttrib.nSaveData  --源道具的val值的位置会在洗练后变化的, 所以不记录操作顺序了

	self:ReduceRandomAttrib(pItemSrc, tbSrcAttrib.szAttrib);
	self:ChangeRandomAttrib(pItemTar, nTarPos, tbSrcAttrib.nSaveData);
	
	return true;
end

function tbRefinement:GetAttribFullCount(nEquipTemplateId)
	--local bGoldEquip = self:IsGoldEquip(nEquipTemplateId);
	-- if bGoldEquip then
	-- 	return GOLD_MAX_ATTRIB;
	-- else
	-- 	return NORMAL_MAX_ATTRIB;
	-- end

	--非黄金装备也有6个孔 修改于2015-8-8
	return GOLD_MAX_ATTRIB;
end


function tbRefinement:ReduceRandomAttrib(pEquip, szReduceAttrib)
	local tbAttribs = self:GetRandomAttrib(pEquip);
	local tbAfter = {};
	for i = Item.EQUIP_RANDOM_ATTRIB_VALUE_BEGIN, Item.EQUIP_RANDOM_ATTRIB_VALUE_END do
		local tbAttrib = tbAttribs[i];
		if tbAttrib then
			if tbAttrib.szAttrib ~= szReduceAttrib then
				table.insert(tbAfter, tbAttrib.nSaveData);
			end
		end
	end

	-- if #tbAfter == 0 then
	-- 	pEquip.Delete();
	-- else
	for i = Item.EQUIP_RANDOM_ATTRIB_VALUE_BEGIN, Item.EQUIP_RANDOM_ATTRIB_VALUE_END do
		local nSaveData = tbAfter[i];
		self:ChangeRandomAttrib(pEquip, i, nSaveData or 0);
	end
	pEquip.ReInit();
	-- end
end


-- Server 转移
function tbRefinement:RefinementAll(pPlayer, nTarId, nSrcId)
	local pItemTar = me.GetItemInBag(nTarId);
	local pItemSrc = me.GetItemInBag(nSrcId);

	if not pItemTar or not pItemSrc then
		return false;
	end
	if pItemTar.nItemType ~= pItemTar.nItemType then
		return false;
	end
	if pItemTar.nLevel >= pItemSrc.nLevel then
		return false;
	end

	local tbTarAttribs = self:GetRandomAttrib(pItemTar);
	local tbSrcAttribs = self:GetRandomAttrib(pItemSrc);

	local nOrgFightPower = FightPower:CalcEquipFightPower(pPlayer);
	
	for i = Item.EQUIP_RANDOM_ATTRIB_VALUE_BEGIN, Item.EQUIP_RANDOM_ATTRIB_VALUE_END do
		local tbSrcAttrib = tbSrcAttribs[i];
		if tbSrcAttrib then
			self:ChangeRandomAttrib(pItemTar, i, tbSrcAttrib.nSaveData);
		else
			self:ChangeRandomAttrib(pItemTar, i, 0);
		end
		local tbTarAttrib = tbTarAttribs[i];
		if tbTarAttrib then
			self:ChangeRandomAttrib(pItemSrc, i, tbTarAttrib.nSaveData);
		else
			self:ChangeRandomAttrib(pItemSrc, i, 0);
		end
	end
	pItemSrc.ReInit();
	pItemTar.ReInit();
	
	local nCurFightPower = FightPower:CalcEquipFightPower(pPlayer);
	FightPower:SendInfoByChange(pPlayer, nCurFightPower - nOrgFightPower);

	return true;
end

function tbRefinement:IsExistSameTypeAttrib(tbAttribs, szAttrib)
	for _, tbAttrib in pairs(tbAttribs) do
		if tbAttrib.szAttrib == szAttrib then
			return true;
		end
	end

	return false;
end

-- Server
function tbRefinement:ChangeRandomAttrib(pEquip, nPos, nSave)
	self:SetItemIntValue(pEquip, nPos, nSave)
end


function tbRefinement:SetItemIntValue(pEquip, index, val)
	if type(pEquip) == "table" then
		pEquip:SetIntValue(index, val)	
	else
		pEquip.SetIntValue(index, val)	
	end
end

function tbRefinement:GetItemIntValue(pEquip, index)
	if type(pEquip) == "table" then
		return pEquip:GetIntValue(index)
	else
		return pEquip.GetIntValue(index)
	end
end

-- C/S
function tbRefinement:GetRandomAttrib(pEquip)
	local tbAttribs = {};
	for i = Item.EQUIP_RANDOM_ATTRIB_VALUE_BEGIN, Item.EQUIP_RANDOM_ATTRIB_VALUE_END do
		local nSaveData =  self:GetItemIntValue(pEquip, i);
		if nSaveData ~= 0 then
			local nAttribId, nAttribLevel 	= self:SaveDataToAttrib(nSaveData);
			local szAttrib 					= self:AttribIdToChar(nAttribId);
			table.insert(tbAttribs, 
			{
				szAttrib 		= szAttrib,
				nAttribLevel 	= nAttribLevel;
				nAttribId 		= nAttribId,
				nSaveData 		= nSaveData,
			})
		end
	end
	return tbAttribs;
end

function tbRefinement:GetSaveRandomAttrib(pEquip)
	if not pEquip then
		return
	end
	local tbSaveRandomAttrib = {}
	for i = Item.EQUIP_RANDOM_ATTRIB_VALUE_BEGIN, Item.EQUIP_RANDOM_ATTRIB_VALUE_END do
		table.insert(tbSaveRandomAttrib, self:GetItemIntValue(pEquip, i))
	end
	return tbSaveRandomAttrib
end

function tbRefinement:GetRandomAttribByTable(tbSaveAttrib)
	local tbAttribs = {};
	for i = Item.EQUIP_RANDOM_ATTRIB_VALUE_BEGIN, Item.EQUIP_RANDOM_ATTRIB_VALUE_END do
		local nSaveData = tbSaveAttrib[i]
		if not nSaveData or nSaveData == 0 then
			break;
		else
			local nAttribId, nAttribLevel 	= self:SaveDataToAttrib(nSaveData);
			local szAttrib 					= self:AttribIdToChar(nAttribId);
			table.insert(tbAttribs, 
			{
				szAttrib 		= szAttrib,
				nAttribLevel 	= nAttribLevel;
				nAttribId 		= nAttribId,
				nSaveData 		= nSaveData,
			})
		end
	end
	return tbAttribs;
end

function tbRefinement:GetRandomAttribLevel(pEquip)
	local tbAttribs = {};
	local nAttribCount = 0;
	for i = Item.EQUIP_RANDOM_ATTRIB_VALUE_BEGIN, Item.EQUIP_RANDOM_ATTRIB_VALUE_END do
		local nSaveData = self:GetItemIntValue(pEquip, i)
		if nSaveData ~= 0 then
			local nAttribId, nAttribLevel 	= self:SaveDataToAttrib(nSaveData);
			local szAttrib 					= self:AttribIdToChar(nAttribId);
			tbAttribs[nAttribId] = nAttribLevel;
			nAttribCount = nAttribCount + 1;
		end
	end
	return tbAttribs, nAttribCount;
end

-- C/S
function tbRefinement:GetAttribColor(nEquipLevel, nAttribLevel, nItemType)
	if nItemType and nItemType == Item.EQUIP_ZHEN_YUAN then
		return Item.tbZhenYuan:GetAttribColor(nEquipLevel, nAttribLevel)
	end
	local nKey = nEquipLevel * 100 + nAttribLevel;
	local nAttribColor = self.tbColor[nKey]
	if not nAttribColor then
		Log("[ERROR] can find color in ".. nEquipLevel .." ".. nAttribLevel);
		return 1;
	else
		return nAttribColor;
	end
end

-- C/S
function tbRefinement:GetAttribValue(nSaveData, nItemType)
	if nSaveData == 0 then
		return 0;
	end

	local tbAttribValue = self.tbTypeAttribValue[nItemType]
	if not tbAttribValue then
		Log("[ERROR]Refinement:GetAttribValue nItemType not exist")
		return 0;
	end

	local nAttribId, nAttribLevel = self:SaveDataToAttrib(nSaveData);
	local szAttrib = self:AttribIdToChar(nAttribId);

	if not tbAttribValue[szAttrib] then
		Log("[ERROR]Refinement:GetAttribValue  Attrib not exist in Attrib.tab", szAttrib);
		return 0;
	end

	local tbData = tbAttribValue[szAttrib][nAttribLevel];
	return tbData.nAttribValue;
end

function tbRefinement:GetRefineCost(nSaveData, nItemType)
	local nAttribValue = self:GetAttribValue(nSaveData, nItemType)
	if not nAttribValue then
		return 0 
	end
	return math.floor(nAttribValue * 0.1 / 10)
end

-- C/S
function tbRefinement:GetAttribMA(tbAttrib, nItemType)
	local tbAttribValue = self.tbTypeAttribValue[nItemType]
	assert(tbAttribValue, nItemType)
	local szAttrib, nLevel = tbAttrib.szAttrib, tbAttrib.nAttribLevel;
	if not tbAttribValue[szAttrib] then
		Log("[ERROR]Refinement:GetAttribMA  Attrib not exist in Attrib.tab", szAttrib);
		return;
	end
	local tbData = tbAttribValue[szAttrib][nLevel];
	if tbData then
		return tbData.tbMA, tbData.szSpecialDesc;
	else
		Log(string.format("[ERROR]Refinement:GetAttribMA  Attrib:%s not exist level %d in Attrib.tab", szAttrib, nLevel));
	end
end

function tbRefinement:GetAttribSetting(szAttrib, nLevel, nItemType)
	local tbAttribValue = self.tbTypeAttribValue[nItemType]
	assert(tbAttribValue, nItemType)

	if not tbAttribValue[szAttrib] then
		Log("[ERROR]Refinement:GetAttribSetting  Attrib not exist in Attrib.tab", szAttrib);
		return;
	end
	local tbData = tbAttribValue[szAttrib][nLevel];
	if not tbData then
		Log(string.format("[ERROR]Refinement:GetAttribSetting  Attrib:%s not exist level %d in Attrib.tab", szAttrib, nLevel));
		return
	end
	return tbData;
end

-- C/S
function tbRefinement:CanAddAttrib(pEquip, nAttribId, nAttribLevel)
	local szAttrib = self:AttribIdToChar(nAttribId);
	local szEquipType = Item.EQUIPTYPE_EN_NAME[pEquip.nItemType];
	local nEquipLevel = pEquip.nLevel;

	if self.tbType[szEquipType][szAttrib] then -- and self:CanAddAttribLevel(nEquipLevel, nAttribLevel) then
		return true;
	else
		return false;
	end
end

-- 可洗练
function tbRefinement:CanRefinement(pEquipTar, pEquipSrc, bCheckChange)
	if pEquipSrc.nRealLevel > pEquipTar.nRealLevel then
		return false;
	end
	local tbAttribLevel, nAttribCount = self:GetRandomAttribLevel(pEquipTar);
	local tbSrcAttribs = self:GetRandomAttrib(pEquipSrc);

	local nEquipTarLevel = pEquipTar.nLevel;

	local _, nMinTarLevel = next(tbAttribLevel) ;
	for _, nLevel in pairs(tbAttribLevel) do
		if nLevel < nMinTarLevel then
			nMinTarLevel = nLevel
		end
	end
	nMinTarLevel = nMinTarLevel or 0;
	for _, tbSrcAttrib in ipairs(tbSrcAttribs) do
		if not tbAttribLevel[tbSrcAttrib.nAttribId] then --没有的属性，比身上高的，或者可添加的
			if tbSrcAttrib.nAttribLevel > nMinTarLevel then
				return true
			end
			if bCheckChange or nAttribCount < GOLD_MAX_ATTRIB then
				return true
			end
		else 	-- 有的属性 可提升属性等级
			if tbAttribLevel[tbSrcAttrib.nAttribId] < tbSrcAttrib.nAttribLevel then
				return true
			end
		end
	end
	return false
end


-- C/S
function tbRefinement:AttribCharToId(szName)
	local nId = self.tbAttribCharToId[szName]
	if not nId then
		Log("[ERROR] tbRefinement:AttribCharToId", szName);
		return
	end
	return nId
end

-- C/S
function tbRefinement:AttribIdToChar(nQueryId)
	local szName = self.tbAttribIdToChar[nQueryId]
	if not szName then
		Log("[ERROR] tbRefinement:AttribIdToChar", nQueryId);
		return ""
	end
	return szName
end

-- C/S
function tbRefinement:AttribToSaveData(nAttribId, nLevel)
	return nAttribId * 65536 + nLevel;
end

-- C/S
function tbRefinement:SaveDataToAttrib(nData)
	local nAttribId 	= math.floor(nData / 65536);
	local nLevel 		= math.floor(nData % 65536);

	return nAttribId, nLevel;
end

function tbRefinement:OnStartDataCheck()
	for nTemplateId, v in pairs(tbRefinement.tbCustomEquip) do
		local tbInfo = KItem.GetItemBaseProp(nTemplateId)
		assert(tbInfo, nTemplateId)
		local szTypeName = Item.EQUIPTYPE_EN_NAME[tbInfo.nItemType] 
		for i = 1, 6 do
			if v["AttribType" .. i] ~= "" then
				assert(tbRefinement.tbType[szTypeName][v["AttribType" .. i]] ,  nTemplateId .. "," .. i )			
			end
		end
	end
end

--C
function tbRefinement:OnRefinementResult(bRet, szMsg)
	if Ui:WindowVisible("RefinementPanel") == 1 then
		Ui("RefinementPanel"):OnRespond(bRet, szMsg);
	end
end