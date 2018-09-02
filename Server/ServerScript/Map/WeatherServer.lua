WeatherMgr.tbMapInfo = WeatherMgr.tbMapInfo or {};
WeatherMgr.tbAllWeatherInfo = WeatherMgr.tbAllWeatherInfo or {};
WeatherMgr.tbAllNightInfo = {};

function WeatherMgr:OnMapCreate(nMapId, nMapTemplateId)
	if not self.tbAllWeatherSetting[nMapTemplateId] then
		return;
	end
	self.tbMapInfo[nMapId] = nMapTemplateId;
end

function WeatherMgr:OnMapDestroy(nMapId, nMapTemplateId)
	if not self.tbAllWeatherSetting[nMapTemplateId] then
		return;
	end
	self.tbMapInfo[nMapId] = nil;
end

function WeatherMgr:OnMapEnter()
	if not self.tbMapInfo[me.nMapId] then
		return;
	end

	local nTimeNow = GetTime();
	local tbWeatherInfo = self.tbAllWeatherInfo[me.nMapTemplateId];
	if tbWeatherInfo and tbWeatherInfo.nWeatherEndTime and tbWeatherInfo.nWeatherEndTime > nTimeNow then
		me.CallClientScript("WeatherMgr:OnSyncWeatherInfo", me.nMapId, tbWeatherInfo.szWeatherType, tbWeatherInfo.nWeatherEndTime);
	end
end

function WeatherMgr:ActivatePerMinute(nTimeNow)
	local nMin = math.floor(nTimeNow / 60);
	for nMapTemplateId, tbInfo in pairs(self.tbAllWeatherSetting) do
		if tbInfo.nWeatherCheckTime > 0 and #tbInfo.tbWeather > 0 then
			self.tbAllWeatherInfo[nMapTemplateId] = self.tbAllWeatherInfo[nMapTemplateId] or {nNextWeatherCheckTime = 0};
			if nTimeNow >= self.tbAllWeatherInfo[nMapTemplateId].nNextWeatherCheckTime then
				self:CheckWeatherSwitch(nMapTemplateId);
			end
		end
		self:UpdateMapNightByMapTemplateId(nMapTemplateId);
	end
end

function WeatherMgr:UpdateMapNightByMapTemplateId(nMapTemplateId)
	local bIsNight = WeatherMgr:CheckIsNight(nMapTemplateId);
	WeatherMgr.tbAllNightInfo[nMapTemplateId] = WeatherMgr.tbAllNightInfo[nMapTemplateId] or {bIsNight = not bIsNight};
	if WeatherMgr.tbAllNightInfo[nMapTemplateId].bIsNight == bIsNight then
		return;
	end

	WeatherMgr.tbAllNightInfo[nMapTemplateId].bIsNight = bIsNight;

	for _, tbInfo in pairs(House.tbHouseMapInfo or {}) do
		if tbInfo.nMapTemplateId == nMapTemplateId then
			self:UpdateMapNightByMapId(tbInfo.nMapId);
		end
	end
end

function WeatherMgr:UpdateMapNightByMapId(nMapId)
	local nMapTemplateId = GetMapInfoById(nMapId);
	if not nMapTemplateId then
		return;
	end

	local tbAllFurniture = House.tbMapFurnitureInfo[nMapId];
	if not tbAllFurniture then
		return;
	end

	local bIsNight = WeatherMgr:CheckIsNight(nMapTemplateId);
	for nId, tbInfo in pairs(tbAllFurniture) do
		local tbFurniture = House:GetFurnitureInfo(tbInfo.nTemplateId);
		local szSubType = Decoration:GetSubTypeByDecorationId(tbFurniture.nDecorationId);
		if szSubType and szSubType == "Deng" then
			Decoration:OnClientCmd(nil, nId, "ServerDoCmd", bIsNight and 0 or -1);
		end
	end
end

function WeatherMgr:CheckWeatherSwitch(nMapTemplateId)
	local tbWeatherSetting = self.tbAllWeatherSetting[nMapTemplateId];
	if not tbWeatherSetting or tbWeatherSetting.nWeatherCheckTime <= 0 or #tbWeatherSetting.tbWeather <= 0 then
		return;
	end

	self.tbAllWeatherInfo[nMapTemplateId] = self.tbAllWeatherInfo[nMapTemplateId] or {nNextWeatherCheckTime = 0};
	local tbWeatherInfo = self.tbAllWeatherInfo[nMapTemplateId];

	local nTimeNow = GetTime();
	tbWeatherInfo.nNextWeatherCheckTime = nTimeNow + tbWeatherSetting.nWeatherCheckTime * 60;
	tbWeatherInfo.szWeatherType = nil;
	tbWeatherInfo.nWeatherEndTime = nil;

	local nRate = MathRandom(100);
	for _, tbInfo in ipairs(tbWeatherSetting.tbWeather) do
		if nRate > tbInfo[2] then
			nRate = nRate - tbInfo[2];
		else
			local nTime = MathRandom(tbInfo[3], tbInfo[4]);
			tbWeatherInfo.nWeatherEndTime = nTimeNow + nTime * 60 - 1;
			tbWeatherInfo.szWeatherType = tbInfo[1];
			break;
		end
	end

	if tbWeatherInfo.nWeatherEndTime then
		tbWeatherInfo.nNextWeatherCheckTime = tbWeatherInfo.nWeatherEndTime + tbWeatherSetting.nWeatherCheckTime * 60;
	end

	if not tbWeatherInfo.szWeatherType then
		return;
	end

	for nMapId, nMTId in pairs(self.tbMapInfo) do
		if nMTId == nMapTemplateId then
			KPlayer.MapBoardcastScriptByFuncName(nMapId, "WeatherMgr:OnSyncWeatherInfo", nMapId, tbWeatherInfo.szWeatherType, tbWeatherInfo.nWeatherEndTime);
		end
	end
end