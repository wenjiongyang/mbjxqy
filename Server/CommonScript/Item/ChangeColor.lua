
Require("CommonScript/Faction.lua")

Item.tbChangeColor 	= Item.tbChangeColor or {};
local tbChangeColor = Item.tbChangeColor;

tbChangeColor.MAX_COLOR = 8
tbChangeColor.CONSUME_ITEM = 2569;
tbChangeColor.MAX_FACTION = Faction.MAX_FACTION_COUNT

function tbChangeColor:Init()
	local szParam = "ddd"
	local tbConlumn = {"ChangeId", "ConsumeCount", "Part"}
	for i = 1, self.MAX_COLOR do
		szParam = szParam.."d";
		table.insert(tbConlumn, "ColorItem"..i);
	end
	for i = 1, self.MAX_FACTION do
		szParam = szParam.."s";
		table.insert(tbConlumn, "NameFacion"..i);
	end
 	local tbSetting = LoadTabFile("Setting/Item/WaiyiColor.tab", szParam, nil, tbConlumn);

	self.tbColorItem = {};
	self.tbSortGroup = {}

	for _, tbInfo in ipairs(tbSetting) do
		local tbGroup = {nId = tbInfo.ChangeId, nCost = tbInfo.ConsumeCount, nPart = tbInfo.Part, tbItemList = {}, tbNameList = {}, tbItemSort = {}};
		table.insert(self.tbSortGroup, tbGroup);
		for i = 1, self.MAX_COLOR do
			local nItemId = tbInfo["ColorItem"..i];
			--local szItemName = tbInfo["ColorName"..i];
			if nItemId and nItemId > 0 then
				if not self.tbColorItem[nItemId] then
					self.tbColorItem[nItemId] = tbGroup;
					tbGroup.tbItemList[nItemId] = true;
					table.insert(tbGroup.tbItemSort, nItemId);
				else
					Log("Equip Color is Already Exist!!!", nItemId);
				end
			end
		end
		for i = 1, self.MAX_FACTION do
			if tbInfo["NameFacion"..i] then
				tbGroup.tbNameList[i] = tbInfo["NameFacion"..i];
			end
		end
	end

	-- TODO: 资源配置没有导出，先临时脚本也先读取一份。
	self.tbWaiyiItem = LoadTabFile("Setting/Item/Equip/WaiYi.tab", "dd", "TemplateId", {"TemplateId", "ShowType"});
	local tbWeaponItem = LoadTabFile("Setting/Item/Equip/WeaponShow.tab", "dd", "TemplateId", {"TemplateId", "ShowType"})
	for nKey, tbInfo in pairs(tbWeaponItem) do
		self.tbWaiyiItem[nKey] = tbInfo
	end
	self.tbWaiyiRes = {}
	local tbRes = LoadTabFile("Setting/Item/EquipShow.tab", "ddd", nil, {"ShowType", "Faction", "ResId"});
	for _, tbInfo in ipairs(tbRes) do
		if tbInfo.ResId > 0 then
			self.tbWaiyiRes[tbInfo.ShowType] = self.tbWaiyiRes[tbInfo.ShowType] or {}
			self.tbWaiyiRes[tbInfo.ShowType][tbInfo.Faction] = tbInfo.ResId;
		end
	end
end

tbChangeColor:Init();

function tbChangeColor:CanChangeColor(dwTemplateId)
	if not self.tbColorItem[dwTemplateId] then
		return false;
	end
	return true;
end

function tbChangeColor:GetChangeId(dwTemplateId)
	if self.tbColorItem[dwTemplateId] then
		return self.tbColorItem[dwTemplateId].nId
	end
end

function tbChangeColor:GetChangePart(dwTemplateId)
	if self.tbColorItem[dwTemplateId] then
		return self.tbColorItem[dwTemplateId].nPart
	end
end

function tbChangeColor:GetWaiZhuanRes(dwTemplateId, nFaction)
	if not self.tbWaiyiItem[dwTemplateId] then
		return 0;
	end
	local nShowType = self.tbWaiyiItem[dwTemplateId].ShowType
	if not self.tbWaiyiRes[nShowType] or not self.tbWaiyiRes[nShowType][nFaction] then
		return 0
	end
	return self.tbWaiyiRes[nShowType][nFaction];
end

function tbChangeColor:DoChangeColorDialogCallback(nItemId, nTargetId, bConfirm)
	self:DoChangeColor(me, nItemId, nTargetId, bConfirm)
end

function tbChangeColor:DoChangeColor(pPlayer, nItemId, nTargetId, bConfirm)
	local pItem;
	local tbItemGroup = {}
	local tbInfo = self.tbColorItem[nTargetId]
	if not tbInfo then
		return;
	end

		local tbOptList = {}
		for nId, _ in pairs(tbInfo.tbItemList) do
			local tbItemList = pPlayer.FindItemInPlayer(nId)
			for _, pCurItem in pairs(tbItemList) do
				if pCurItem.dwTemplateId == nTargetId then
					pPlayer.CenterMsg("此外裝您已經擁有了這款顏色。");
					return;
				end
				local szName = KItem.GetItemShowInfo(nId, pPlayer.nFaction)
				table.insert(tbItemGroup, pCurItem)
				table.insert(tbOptList, {Text = szName, Callback = self.DoChangeColorDialogCallback, Param = {self, pCurItem.dwId, nTargetId, true}})
			end
		end
		pItem = pPlayer.GetItemInBag(nItemId);

	if not pItem then
		pPlayer.CenterMsg("外裝不存在！")
		return;
	end
	if not self:CanChangeColor(pItem.dwTemplateId) then
		pPlayer.CenterMsg("該裝備不可染色！")
		return
	end

	if not tbInfo.tbItemList[pItem.dwTemplateId] then
		pPlayer.CenterMsg("此外裝不能染為目標顏色");
		return;
	end

	if tbInfo.nCost > 0 and pPlayer.ConsumeItemInBag(self.CONSUME_ITEM, tbInfo.nCost, Env.LogWay_ChangeColor, nil, nTargetId) < tbInfo.nCost then
		local tbBaseProp = KItem.GetItemBaseProp(self.CONSUME_ITEM);
		pPlayer.CenterMsg(string.format("您身上的%s不足，不能進行染色", tbBaseProp.szName));
		return;
	end

	pPlayer.AddItem(nTargetId)

	pPlayer.CenterMsg("染色成功！");
end


