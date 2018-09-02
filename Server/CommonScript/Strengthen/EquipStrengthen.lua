Require("CommonScript/Item/Define.lua")

Strengthen.USER_VALUE_GROUP  = 6
Strengthen.OPEN_LEVEL = 10 -- 10级别开放
Strengthen.FAIL_ADD_PROB = 100;--每次失败增加的概率（总值1000）
Strengthen.USE_PROB2_ENHANCE_LEVEL = 100;--当前强化大于等于这个等级时失败用下面的增加概率
Strengthen.FAIL_ADD_PROB2 = 200;--每次失败增加的概率（总值1000）
Strengthen.ENHANCE_ATTRIB_GROUP = 1;
Strengthen.SAVE_KEY_LAST_ENHANCE_DAY = 41;
Strengthen.SAVE_KEY_ENHANCE_COUNT_FROM = 31;
Strengthen.DAY_MAX_ENHANCE_COUNT = 999; --每件装备每天只能强化20次

Strengthen.tbAchievementLevel = { 5,20,40,60,80,100 };

Strengthen.tbPosPrefixName =
{
	[Item.EQUIPPOS_HEAD]			= "Armor";
	[Item.EQUIPPOS_BODY]			= "Cloth";
	[Item.EQUIPPOS_BELT]			= "Armor";
	[Item.EQUIPPOS_WEAPON]			= "Weapon";
	[Item.EQUIPPOS_FOOT]			= "Armor";
	[Item.EQUIPPOS_CUFF]			= "Armor";
	[Item.EQUIPPOS_AMULET]			= "Jewelry";
	[Item.EQUIPPOS_RING]			= "Jewelry";
	[Item.EQUIPPOS_NECKLACE]		= "Jewelry";
	[Item.EQUIPPOS_PENDANT]			= "Jewelry";
}


function Strengthen:LoadTabFile()
	self.tbAttribValue = {};

	local tbAttribSetting = LoadTabFile(
		"Setting/Item/Strengthen/StrengthenAttrib.tab",
		"sdddd", nil,
		{"AttribType", "Level", "Value1", "Value2", "Value3"});

	for _,v in pairs(tbAttribSetting) do
		self.tbAttribValue[v.AttribType] = self.tbAttribValue[v.AttribType] or {};
		self.tbAttribValue[v.AttribType][v.Level] = {v.Value1, v.Value2, v.Value3};
	end

	local tbStrengthenSetting = LoadTabFile(
	    "Setting/Item/Strengthen/Strengthen.tab",
	    "ddddddddddsdddddsdddd", "Level",
	    {
	    	"Level",
	        "LevelMin",

	        "FightPowerWeapon",
	        "FightPowerCloth",
	        "FightPowerJewelry",
	        "FightPowerArmor",
	        "ValueWeapon",
	        "ValueCloth",
	        "ValueJewelry",
	        "ValueArmor",

	        "ConsumeItem",
	        "ConsumeCountWeapon",
	        "ConsumeCountCloth",
	        "ConsumeCountJewelry",
	        "ConsumeCountArmor",

	        "Probility",
	        "BreakItem",
	        "BreakCountWeapon",
	        "BreakCountCloth",
	        "BreakCountJewelry",
	        "BreakCountArmor",
	    });

	self.tbStrengthenLevel = tbStrengthenSetting;

	--突破{强化等级 = 需求突破次数}
	self.tbBreakLevel = {};
	local nMaxLevel = Lib:CountTB(self.tbStrengthenLevel) - 1;
	local nBreakCount = 0;
	for i = 0, nMaxLevel do
		local tbSetting = self.tbStrengthenLevel[i];
		if tbSetting.BreakItem and tbSetting.BreakItem ~= "" then
			nBreakCount = nBreakCount + 1;
		end
		self.tbBreakLevel[i] = nBreakCount;
	end

	self.STREN_LEVEL_MAX = nMaxLevel; --强化最大等级

	self.tbEnhanceExtern = LoadTabFile(
		"Setting/Item/EnhanceExtern.tab",
		"ddds", nil,
		{"EnhLevel", "NeedNum", "AttribLevel", "Img"});

	for nIdx, tbInfo in ipairs(self.tbEnhanceExtern) do
		tbInfo.nIdx = nIdx;
	end
end

Strengthen:LoadTabFile();

function Strengthen:GetNeedBreakCount(nStrenLevel)
	return self.tbBreakLevel[nStrenLevel];
end

function Strengthen:GetAttribValues(szAttribType, nLevel)
	if not self.tbAttribValue[szAttribType] then
		Log(string.format("can find %s in strengthenAttrib.tab", szAttribType));
		return {0, 0, 0};
	end
	if nLevel == 0 then
		return {0, 0, 0};
	else
		return self.tbAttribValue[szAttribType][nLevel];
	end
end

function Strengthen:GetStrenSetting(nStrenLevel)
	return self.tbStrengthenLevel[nStrenLevel]
end

function Strengthen:GetStrengthenLevel(pPlayer, nEquipPos)
	local tbStrengthen = pPlayer.GetStrengthen();
	local nStrenLevel = tbStrengthen[nEquipPos + 1];
	return nStrenLevel;
end

function Strengthen:CanStrengthen(pPlayer, nEquipPos, nEquipLevel)
	if me.nLevel < self.OPEN_LEVEL then
		return false, self.OPEN_LEVEL .. "級才開放強化"
	end
	if nEquipPos < 0 or nEquipPos >= Item.EQUIPPOS_MAIN_NUM then
		return false, "該裝備不能強化";
	end
	local tbStrengthen 	= pPlayer.GetStrengthen();
	local nStrenLevel 	= tbStrengthen[nEquipPos + 1]; --equipPos从0开始， lua数组从1开始
	local tbSetting 	= self.tbStrengthenLevel[nStrenLevel];

	local nConsumeId, nConsumeCount, nCoin;
	local szPrefix = self.tbPosPrefixName[nEquipPos]
	if self:IsNeedBreakThrough(pPlayer, nEquipPos) then
		nConsumeId 		= KItem.GetTemplateByKind(tbSetting.BreakItem);
		nConsumeCount 	= tbSetting["BreakCount" .. szPrefix];
		nCoin 			= 0;
	else
		nConsumeId 		= KItem.GetTemplateByKind(tbSetting.ConsumeItem);
		nConsumeCount 	= tbSetting["ConsumeCount" .. szPrefix] ;
		nCoin 			= self:GetStrengthenCost(nStrenLevel, nEquipPos);
		local nTodayCount = self:GetStrengthenTodayCount(pPlayer, nEquipPos)
		if nTodayCount >= self.DAY_MAX_ENHANCE_COUNT then
			return false, string.format("每件裝備每天只能強化%d次，請大俠明天再繼續強化該裝備", self.DAY_MAX_ENHANCE_COUNT)
		end
	end

	if nStrenLevel == self.STREN_LEVEL_MAX then
		return false, "已達最大等級";
	end

	if pPlayer.GetMoney("Coin") < nCoin then
		return false, "銀兩不足";
	end

	local tbTotalStone, nCombineCost
	local nHasCount = pPlayer.GetItemCountInAllPos(nConsumeId)
	if nHasCount < nConsumeCount then
		local szTimeFrame = StoneMgr.tbCrystalTimeFrame[nConsumeId]
		if 	szTimeFrame and GetTimeFrameState(szTimeFrame) ~= 1 then
			return false, "合成時間軸還未開放"
		end
		local bNotHasItem = false
		local bNotEoughCoin = false
		local nPreStoneId = StoneMgr:GetPreStoneId(nConsumeId)
		if nPreStoneId then
			tbTotalStone, nCombineCost = StoneMgr:GetCombineStoneNeed(nPreStoneId, (nConsumeCount - nHasCount) * StoneMgr.COMBINE_CRYSTAL_COUNT, pPlayer)
			if tbTotalStone then
				if pPlayer.GetMoney("Coin") >= nCoin + nCombineCost then
					bNotHasItem = true
				else
					bNotEoughCoin =  true
				end
			end
		end
		if not bNotHasItem then
			if bNotEoughCoin then
				return false, "水晶自動合成所需銀兩不足", nil, nCombineCost;
			else
				local tbBaseInfo = KItem.GetItemBaseProp(nConsumeId);
				return false, string.format("%s不足", tbBaseInfo.szName), nil, nCombineCost;
			end
		end
	end

	if nEquipLevel < tbSetting.LevelMin then
		return false, "裝備等級過低", nil, nCombineCost;
	end


	return true, nil, tbTotalStone, nCombineCost;
end


function Strengthen:IsNeedBreakThrough(pPlayer, nEquipPos)
	local nStrenLevel 	= self:GetStrengthenLevel(pPlayer, nEquipPos);
	local nBreakCount 	= self:GetPlayerBreakCount(pPlayer, nEquipPos);
	local nNeed 		= self:GetNeedBreakCount(nStrenLevel);
	return nBreakCount < nNeed;
end

function Strengthen:GetPlayerBreakCount(pPlayer, nEquipPos)
	return pPlayer.GetUserValue(self.USER_VALUE_GROUP, 11 + nEquipPos)
end

function Strengthen:SetPlayerBreakCount(pPlayer, nEquipPos, nCount)
	pPlayer.SetUserValue(self.USER_VALUE_GROUP, 11 + nEquipPos, nCount)
end

function Strengthen:GetStrenFightPower(pPlayer, nEquipPos, nStrenLevel)
	if not nStrenLevel then
		nStrenLevel = self:GetStrengthenLevel(pPlayer, nEquipPos);
	end
	if self.tbStrengthenLevel[nStrenLevel] then
		return self.tbStrengthenLevel[nStrenLevel]["FightPower" .. self.tbPosPrefixName[nEquipPos] ];
	end
	return 0;
end

--强化价值量
function Strengthen:GetStrengthenValue(pPlayer, nEquipPos)
	local nStrenLevel = self:GetStrengthenLevel(pPlayer, nEquipPos);
	local tbSetting = self.tbStrengthenLevel[nStrenLevel];
	return tbSetting["Value" .. self.tbPosPrefixName[nEquipPos]] ;
end

function Strengthen:GetStrengthenCost(nStrenLevel, nEquipPos)
	local tbSetting = self.tbStrengthenLevel[nStrenLevel];
	local nConsumeId 	= KItem.GetTemplateByKind(tbSetting.ConsumeItem);
	local tbBaseInfo 	= KItem.GetItemBaseProp(nConsumeId)
	local ConsumeCount = tbSetting["ConsumeCount" .. self.tbPosPrefixName[nEquipPos]]
	return math.floor(tbBaseInfo.nValue * ConsumeCount * 0.1 / 10 )
end

function Strengthen:OnLogin(pPlayer, bReInit)
	for nEquipPos = Item.EQUIPPOS_HEAD, Item.EQUIPPOS_PENDANT do
		local nStrenLevel = pPlayer.GetUserValue(self.USER_VALUE_GROUP, nEquipPos + 1)
		if nStrenLevel > 0 then
			pPlayer.SetStrengthen(nEquipPos, nStrenLevel)
		end

		-- 镶嵌
		StoneMgr:UpdateInsetInfo(pPlayer, nEquipPos, bReInit)
	end

	self:UpdateEnhAtrrib(pPlayer)
	StoneMgr:UpdateInsetAttrib(pPlayer)
end

function Strengthen:GetMinEnhLevel(pPlayer)
	local nMinEnhLevel = 100
	for nEquipPos = Item.EQUIPPOS_HEAD, Item.EQUIPPOS_PENDANT do
		local nStrenLevel = pPlayer.GetUserValue(self.USER_VALUE_GROUP, nEquipPos + 1)
		nMinEnhLevel = nMinEnhLevel > nStrenLevel and nStrenLevel or nMinEnhLevel
	end
	return nMinEnhLevel
end

function Strengthen:UpdateEnhAtrrib(pPlayer)
	local tbEnhanceLv = {}
	local nMinEnhLevel = 100;
	local nAttribLv = 0;
	pPlayer.nEnhExIdx = nil
	local nMaxEnhanceLevel = 0
	for nEquipPos = Item.EQUIPPOS_HEAD, Item.EQUIPPOS_PENDANT do
		local nStrenLevel = pPlayer.GetUserValue(self.USER_VALUE_GROUP, nEquipPos + 1)
		nMinEnhLevel = nMinEnhLevel > nStrenLevel and nStrenLevel or nMinEnhLevel;
		if nStrenLevel > 0 then
			tbEnhanceLv[nStrenLevel] = (tbEnhanceLv[nStrenLevel] or 0) + 1
			nMaxEnhanceLevel = nMaxEnhanceLevel > nStrenLevel and nMaxEnhanceLevel or nStrenLevel
			pPlayer.SetStrengthen(nEquipPos, nStrenLevel)
		end
	end

	for i = nMaxEnhanceLevel - 1, nMinEnhLevel, -1 do
		tbEnhanceLv[i] = (tbEnhanceLv[i] or 0) + (tbEnhanceLv[i + 1] or 0)
	end
	self.tbEnhanceLv = tbEnhanceLv

	for nIdx = #self.tbEnhanceExtern, 1, -1 do
		local tbInfo = self.tbEnhanceExtern[nIdx]
		if  (tbInfo.EnhLevel < nMinEnhLevel and  tbEnhanceLv[nMinEnhLevel] >= tbInfo.NeedNum) or (tbEnhanceLv[tbInfo.EnhLevel] and tbEnhanceLv[tbInfo.EnhLevel] >= tbInfo.NeedNum) then
			nAttribLv = tbInfo.AttribLevel;
			pPlayer.nEnhExIdx = nIdx
			break;
		end
	end
	if nAttribLv > 0 then
		pPlayer.ApplyEnhExAttrib(nAttribLv);
	else
		pPlayer.RemoveExternAttrib(self.ENHANCE_ATTRIB_GROUP)
	end

	Kin:RedBagOnEvent(pPlayer, Kin.tbRedBagEvents.all_strength, nMinEnhLevel)
	TeacherStudent:OnEquipAllStrength(pPlayer, nMinEnhLevel)
end

function Strengthen:GetEnhExAttrib(nIndex)
	local tbSetting = self.tbEnhanceExtern[nIndex];
	if not tbSetting then
		return;
	end

	if not tbSetting.tbAttrib then
		tbSetting.tbAttrib = KItem.GetEnhExAttrib(tbSetting.AttribLevel)
	end

	return tbSetting;
end

function Strengthen:GetStrengthenFailTimes(pPlayer, nEquipPos)
	return pPlayer.GetUserValue(self.USER_VALUE_GROUP, 21 + nEquipPos)
end

function Strengthen:SetStrengthenFailTimes(pPlayer, nEquipPos, nValue)
	pPlayer.SetUserValue(self.USER_VALUE_GROUP, 21 + nEquipPos, nValue)
end

function Strengthen:GetStrengthenProb(nDefaultProb, nFailTime, nNowEnhanceLevel)
	local nFaildAdd = nNowEnhanceLevel >= self.USE_PROB2_ENHANCE_LEVEL and self.FAIL_ADD_PROB2 or self.FAIL_ADD_PROB
	return math.min(1000, nDefaultProb + nFaildAdd * nFailTime)
end

function Strengthen:GetStrengthenTodayCount(pPlayer, nEquipPos)
	if Lib:GetLocalDay() ~= pPlayer.GetUserValue(self.USER_VALUE_GROUP, self.SAVE_KEY_LAST_ENHANCE_DAY) then
		return 0;
	end
	return pPlayer.GetUserValue(self.USER_VALUE_GROUP, self.SAVE_KEY_ENHANCE_COUNT_FROM + nEquipPos)
end