
HousePlant.LAND_ID = 4427;
HousePlant.PLANT_COST = 200;				-- 种植消耗元宝数	
HousePlant.RIPEN_TIME = 3600 * 24 * 7;			-- 成熟时间

-- 植物状态
HousePlant.STATE_NULL = -1;				-- 空田
HousePlant.STATE_NORMAL = 0;			-- 正常
HousePlant.STATE_RIPEN = 100;			-- 成熟

-- 异常状态（注：按从小到大的顺序）
HousePlant.STATE_WATER = 1;				-- 待浇水
HousePlant.STATE_FERTILIZE = 2;			-- 待施肥
HousePlant.STATE_DISINFESTATION = 3;	-- 待除虫
HousePlant.tbSickStateSetting =
{
	{ szDesc = "缺水",	szCureTool = "水壺",	szCureNotify = "本次澆水，樹叢的成熟時間加快[FFFE0D]%s[-]",	szFailedMsg = "泥土看起來非常濕潤，無需澆水",  },
	{ szDesc = "缺肥",	szCureTool = "肥料", 	szCureNotify = "本次施肥，樹叢的成熟時間加快[FFFE0D]%s[-]",	szFailedMsg = "泥土看起來十分肥沃，無需施肥",  },
	{ szDesc = "生蟲",	szCureTool = "除蟲劑",	szCureNotify = "本次除蟲，樹叢的成熟時間加快[FFFE0D]%s[-]",	szFailedMsg = "植物看起來很健康，無需除蟲", },
}

-- 植物养护
HousePlant.CURE_COST = 50;				-- 养护消耗元宝数
HousePlant.CURE_TIME_NORMAL = 3600;		-- 普通养护减少成熟时间
HousePlant.CURE_TIME_COST = 3600 * 2;	-- 元宝养护减少成熟时间
HousePlant.CURE_COST_AWARD = 500;		-- 消耗元宝养护获得贡献值
HousePlant.CURE_INTIMACY = 50;			-- 养护亲密度
HousePlant.CURE_INTIMACY_COST = 100;		-- 消耗元宝养护亲密度

-- 植物养护次数刷新时间，每天4点
HousePlant.CURE_TIMES_REFRESH_TIME = 4 * 3600;

-- 植物异常
HousePlant.tbSickGapSetting =
{
	{ nHour = 2, nSickGap = 2 * 3600 },
	{ nHour = 10, nSickGap = 4 * 3600 },
	{ nHour = 24, nSickGap = 2 * 3600 },
};

if MODULE_GAMESERVER then
	function HousePlant:LoadLevelRatioSetting(szFile, nMaxIndex, szKey)
		local tbSetting = {};
		local szType = "s";
		local tbCol = { "szTimeFrame" };
		for i = 1, nMaxIndex do
			szType = szType .. "dd";
			table.insert(tbCol, "nRatio" .. i);
			table.insert(tbCol, szKey .. i);
		end
		local tbFile = LoadTabFile(szFile, szType, nil, tbCol);
		for _, tbRow in pairs(tbFile) do
			local tbLevelSetting = {};
			tbLevelSetting.szTimeFrame = tbRow.szTimeFrame;
			assert(tbLevelSetting.szTimeFrame ~= "");

			local tbRand = {};
			local nTotalRatio = 0;
			for i = 1, nMaxIndex do
				local nRatio = tbRow["nRatio" .. i];
				assert(nRatio >= 0, szFile);				
				table.insert(tbRand, { nResult = tbRow[szKey .. i], nRatio = nRatio });
				nTotalRatio = nTotalRatio + nRatio;
			end
			assert(nTotalRatio == 1000, szFile);
			tbLevelSetting.tbRand = tbRand;

			table.insert(tbSetting, tbLevelSetting);
		end
		return tbSetting;
	end

	HousePlant.tbCropCountSetting = HousePlant:LoadLevelRatioSetting("Setting/HousePlant/CropCount.tab", 4, "nCount");
	HousePlant.tbCropItemSetting = HousePlant:LoadLevelRatioSetting("Setting/HousePlant/CropItem.tab", 5, "nItem");

	function HousePlant:RandResult(tbRand)
		local nRand = MathRandom(1, 1000);
		local nCurValue = 0;
		for _, tbInfo in ipairs(tbRand) do
			nCurValue = nCurValue + tbInfo.nRatio;
			if nRand <= nCurValue then
				return tbInfo.nResult;
			end
		end
		assert(false, "failed to rand: " .. nRand);
		return -1;
	end

	function HousePlant:GetCropSetting(tbSetting)
		local tbResult = nil;
		for _, tbInfo in ipairs(tbSetting) do
			if GetTimeFrameState(tbInfo.szTimeFrame) ~= 1 then
				break;
			end
			tbResult = tbInfo;
		end
		return tbResult;
	end

	function HousePlant:RandCropCount()
		local tbSetting = self:GetCropSetting(self.tbCropCountSetting);
		return self:RandResult(tbSetting.tbRand);
	end

	function HousePlant:GetCropAward()
		local nCount = self:RandCropCount();
		if nCount <= 0 then
			return;
		end

		local tbAward = {};
		local tbSetting = self:GetCropSetting(self.tbCropItemSetting);
		for i = 1, nCount do
			local nItemId = self:RandResult(tbSetting.tbRand);
			table.insert(tbAward, {"item", nItemId,	1});
		end
		return tbAward;
	end

	function HousePlant:CalcuSickTime()
		local nCurTime = GetTime();
		local nDayHour = Lib:GetLocalDayHour(nCurTime);
		for _, tbSetting in ipairs(self.tbSickGapSetting) do
			if nDayHour <= tbSetting.nHour then
				return nCurTime + tbSetting.nSickGap;
			end
		end
	end
end

function HousePlant:IsSickState(nState)
	return HousePlant.tbSickStateSetting[nState] and true or false;
end
