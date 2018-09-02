Require("CommonScript/House/HouseCommon.lua");

SampleHouse.tbMapInfo = SampleHouse.tbMapInfo or {};
SampleHouse.tbTryEnterPlayer = SampleHouse.tbTryEnterPlayer or {};
SampleHouse.tbMapFurniture = SampleHouse.tbMapFurniture or {};

function SampleHouse:LoadMapFurniture(nMapTemplateId)
	local tbSetting = House:GetSampleHouseSetting(nMapTemplateId);
	assert(tbSetting, "unknown samplehouse: " .. nMapTemplateId);
	local szFileName =  string.format("ServerSetting/SampleHouse/Furniture_%d.tab", tbSetting.nTargetHouse);
	SampleHouse.tbMapFurniture[nMapTemplateId] = LoadTabFile(szFileName, "dddd", nil, {"nTemplateId", "nX", "nY", "nYaw"});
end

function SampleHouse:EnterSampleHouse(pPlayer, nMapTemplateId)
	if not Env:CheckSystemSwitch(pPlayer, Env.SW_SwitchMap) then
		pPlayer.CenterMsg("目前狀態不允許切換地圖")
		return;
	end

	local bRet, szMsg = self:CanEnterSampleHouse(pPlayer, nMapTemplateId);
	if not bRet then
		pPlayer.CenterMsg(szMsg);
		return
	end

	local dwPlayerId = pPlayer.dwID;
	local tbMapInfo = self:GetMapInfo(nMapTemplateId);
	local nMapId = tbMapInfo.nMapId;
	if tbMapInfo.tbEnterQueue then
		if self.tbTryEnterPlayer[dwPlayerId] == nMapId then
			pPlayer.CenterMsg("正在傳送中...");
			return;
		end
		table.insert(tbMapInfo.tbEnterQueue, dwPlayerId);
		self.tbTryEnterPlayer[dwPlayerId] = nMapId;
		return;
	end

	pPlayer.SetEntryPoint();
	pPlayer.SwitchMap(nMapId, 0, 0);

	return true;
end

function SampleHouse:CanEnterSampleHouse(pPlayer, nMapTemplateId)
	if not Env:CheckSystemSwitch(pPlayer, Env.SW_SampleHouse) then
		return false, "該功能暫時關閉，請稍候再試";
	end

	if pPlayer.nMapTemplateId == nMapTemplateId then
		return false, "你已經在家園內了哦";
	end

	if not House:IsSampleHouse(nMapTemplateId) then
		return false, "走錯家園啦！";
	end

	return House:CheckCanEnterMap(pPlayer);
end

function SampleHouse:GetMapInfo(nMapTemplateId)
	local tbMapInfo = SampleHouse.tbMapInfo[nMapTemplateId];
	if not tbMapInfo then
		tbMapInfo = {};
		tbMapInfo.nMapId = CreateMap(nMapTemplateId);
		tbMapInfo.tbEnterQueue = {};
		SampleHouse.tbMapInfo[nMapTemplateId] = tbMapInfo;
	end
	return tbMapInfo;
end

function SampleHouse:OnMapCreate(nMapId)
	local nMapTemplateId = GetMapInfoById(nMapId);
	local tbMapInfo = SampleHouse.tbMapInfo[nMapTemplateId];
	if not tbMapInfo or tbMapInfo.nMapId ~= nMapId then
		Log("[ERROR][SampleHouse] map create, illegal sample house: ", nMapId, tbMapInfo and tbMapInfo.nMapId or -1);
		return;
	end

	if self.tbMapFurniture[nMapTemplateId] then
		self:GenerateFurniture(nMapId, self.tbMapFurniture[nMapTemplateId]);
	end

	for _, dwPlayerId in ipairs(tbMapInfo.tbEnterQueue) do
		local nTargetMapId = SampleHouse.tbTryEnterPlayer[dwPlayerId];
		SampleHouse.tbTryEnterPlayer[dwPlayerId] = nil;

		if nTargetMapId and nTargetMapId == nMapId then
			local pPlayer = KPlayer.GetPlayerObjById(dwPlayerId);
			if pPlayer then
				pPlayer.SetEntryPoint();
				pPlayer.SwitchMap(nMapId, 0, 0);
			end
		end 
	end
	tbMapInfo.tbEnterQueue = nil;
end

function SampleHouse:GenerateFurniture(nMapId, tbFurnitureSet, bCanOperation)
	for _, tbInfo in pairs(tbFurnitureSet) do
		local tbFur = House:GetFurnitureInfo(tbInfo.nTemplateId);
		if tbFur then
			Decoration:NewDecoration(nMapId, tbInfo.nX, tbInfo.nY, tbInfo.nYaw, tbFur.nDecorationId, true, bCanOperation);
		else
			Log("[ERROR][SampleHouse] failed to generate furniture, template id not exist! ", nMapId, tbInfo.nTemplateId);
		end
	end
end

function SampleHouse:OnMapDestroy(nMapId)
	local nMapTemplateId = GetMapInfoById(nMapId);
	local tbMapInfo = SampleHouse.tbMapInfo[nMapTemplateId];
	if not tbMapInfo or tbMapInfo.nMapId ~= nMapId then
		Log("[ERROR][SampleHouse] map destroy, illegal sample house: ", nMapId, tbMapInfo and tbMapInfo.nMapId or -1);
		return;
	end
	SampleHouse.tbMapInfo[nMapTemplateId] = nil;
end

function SampleHouse:RegisterMap(nMapTemplateId)
	local tbMap = Map:GetClass(nMapTemplateId);
	function tbMap:OnCreate(...)
		SampleHouse:OnMapCreate(...);
	end

	function tbMap:OnDestroy(...)
		SampleHouse:OnMapDestroy(...);
	end
end

for nMapTemplateId in pairs(House.tbSampleHouseSetting) do
	SampleHouse:LoadMapFurniture(nMapTemplateId);
	SampleHouse:RegisterMap(nMapTemplateId);
end

