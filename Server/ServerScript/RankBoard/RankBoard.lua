-- tbRanktbInfo =
-- {
-- 	nPosition = 1,
-- 	dwUnitID =,
-- 	szValue = ,
-- 	nHighValue = ,
-- 	nLowValue = ,
-- }



local tbGetRankInfoView = {
	["Default"] = function (tbInfo)  --战力榜也是用这个
		local tbRole = KPlayer.GetRoleStayInfo(tbInfo.dwUnitID)
		if tbRole then
			tbInfo.szName = tbRole.szName;
			tbInfo.nFaction = tbRole.nFaction;
			tbInfo.dwKinId = tbRole.dwKinId;
			tbInfo.nHonorLevel = tbRole.nHonorLevel;
			tbInfo.nLevel = tbRole.nLevel;
			tbInfo.bGameCenter = Sdk:IsPlayerLaunchFromGameCenter(tbInfo.dwUnitID);
			if tbRole.dwKinId > 0 then
				local tbKin = Kin:GetKinById(tbRole.dwKinId)
   				if tbKin then
   					tbInfo.szKinName = tbKin.szName;
   				end
			end
		end
		return tbInfo
	end;

	["kin"] = function (tbInfo)
		local tbKin = Kin:GetKinById(tbInfo.dwUnitID)
		if tbKin then
			local nLeaderId = tbKin:GetLeaderId()
			local pRole = KPlayer.GetRoleStayInfo(nLeaderId)
			return
			{
				dwKinId   = tbInfo.dwUnitID,
				nPosition = tbInfo.nPosition,
				szKinName = tbKin.szName,
				nPrestige = tbKin.nPrestige,
				nLevel 	  = tbKin:GetLevel(),
				szLeaderName = pRole and pRole.szName or "",
				nLeaderHoner = pRole and pRole.nHonorLevel or 0;
			}
		else
			--TODO  如果家族删除了，则需要删除对应的
			Log("Error!! tbGetRankInfoView kin ", tbInfo.dwUnitID)
			return {nPosition = tbInfo.nPosition};
		end
	end;

	["LunJianRank"] = function (tbInfo)
	    local tbFightTeam = HuaShanLunJian:GetFightTeamByID(tbInfo.dwUnitID);
	    if not tbFightTeam then
	    	Log("Error!! tbGetRankInfoView LunJianRank ", tbInfo.dwUnitID)
	    	return {nPosition = tbInfo.nPosition};
	    end

	    local tbShowInfo = {};
	    tbShowInfo.szName = tbFightTeam:GetName();
	    local nValue = tonumber(tbInfo.szValue);
	    local nJiFen, nWinCount, nTime = tbFightTeam:AnalyzeRankValue(nValue);
	    tbShowInfo.nJiFen = nJiFen;
	    tbShowInfo.nWin = nWinCount;
	    tbShowInfo.nTime = nTime;
	    tbShowInfo.nPosition = tbInfo.nPosition;
	    tbShowInfo.dwUnitID = tbInfo.dwUnitID;

	    return tbShowInfo;	
	end,

	["House"] = function (tbInfo)
		local tbRole = KPlayer.GetRoleStayInfo(tbInfo.dwUnitID)
		if tbRole then
			tbInfo.szName = tbRole.szName;
			tbInfo.nFaction = tbRole.nFaction;
			tbInfo.nHonorLevel = tbRole.nHonorLevel;
			tbInfo.nHouseLevel = House:GetHouseLevel(tbInfo.dwUnitID);
			if tbRole.dwKinId > 0 then
				local tbKin = Kin:GetKinById(tbRole.dwKinId)
   				if tbKin then
   					tbInfo.szKinName = tbKin.szName;
   				end
			end
		end
		return tbInfo
	end,
}

local tbGetMyInfo = {
	["Default"] = function (pPlayer, pRank) ---GetRankInfoByID 在榜未刷新时 也会返回，nPos 就都是0(-1+1)
		local tbInfo = pRank.GetRankInfoByID(pPlayer.dwID)
		if not tbInfo then
			return
		end

		return  {nPosition = tbInfo.nPosition, szValue = tbInfo.szValue}
	end;

	["kin"] = function (pPlayer, pRank)
		local dwKinId = pPlayer.dwKinId
		if dwKinId == 0 then
			return
		end
		local tbKin = Kin:GetKinById(dwKinId)
		if not tbKin then
			return
		end

		local tbInfo = pRank.GetRankInfoByID(dwKinId)
		return {nPosition = (tbInfo and tbInfo.nPosition or nil) , nPrestige = tbKin.nPrestige }
	end;

	["qunyinghui"] = function (pPlayer, pRank)
		local tbInfo = pRank.GetRankInfoByID(pPlayer.dwID)
		if not tbInfo then
			return
		end

		local nValue = tonumber(tbInfo.szValue);
		local nJiFen = math.floor(nValue / 1000);

		return  {nPosition = tbInfo.nPosition, szValue = tostring(nJiFen)}

	end;

	["CardCollection_1"] = function (pPlayer, pRank)
		local tbInfo = pRank.GetRankInfoByID(pPlayer.dwID)
		if not tbInfo then
			return
		end

		return  {nPosition = tbInfo.nPosition, nHighValue = tbInfo.nHighValue, nLowValue = tbInfo.nLowValue}
	end;

	["LunJianRank"] = function (pPlayer, pRank)
		local nFightTeamID = HuaShanLunJian:GetPlayerFightTeam(pPlayer);
		if nFightTeamID <= 0 then
			return;
		end

		local tbInfo = pRank.GetRankInfoByID(nFightTeamID)
		if not tbInfo then
			return
		end

	    return tbGetRankInfoView["LunJianRank"](tbInfo);	
	end;

	["ZhongQiuJie"] = function (pPlayer, pRank)
		local tbInfo = pRank.GetRankInfoByID(pPlayer.dwID)
		if not tbInfo then
			return
		end

		return  {nPosition = tbInfo.nPosition, nHighValue = tbInfo.nHighValue, nLowValue = tbInfo.nLowValue}
	end;
}

local tbUpdateRankValFuc = {
	["Default"] = function (pRank, dwId, nVal)
		pRank.UpdateValueByID(dwId, nVal);
	end;

	["kin"] = function (pRank, tbKin, nLevel)
		if not nLevel then
			local tbBuildingData = tbKin:GetBuildingData(Kin.Def.Building_Main);
			nLevel = tbBuildingData.nLevel
		end
		if not Forbid:IsBanning(_,Forbid.BanType.KinRank,tbKin.nKinId) then
			pRank.UpdateValueByID(tbKin.nKinId, {tbKin.nPrestige, nLevel});
		end
	end;

	["FightPower"] = function (pRank, pPlayer, szType, nCurFightPower)
		
		if not Forbid:IsBanning(pPlayer,Forbid.BanType.FightPowerRank) then
			pRank.UpdateValueByID(pPlayer.dwID, pPlayer.GetFightPower());
		end
		local nFaction = pPlayer.nFaction
		local pRank = KRank.GetRankBoard("FightPower_" .. nFaction)
		if not pRank then
			Log(debug.traceback())
			return
		end
		if not Forbid:IsBanning(pPlayer,Forbid.BanType.FightPower_Faction) then
			pRank.UpdateValueByID(pPlayer.dwID, pPlayer.GetFightPower())
		end

		if szType and nCurFightPower then
			local szOtherRank = "FightPower_" .. szType
			local pRank = KRank.GetRankBoard(szOtherRank)
			if pRank then
				local nOtherBanType = Forbid.BanType[szOtherRank]
				if not nOtherBanType or not Forbid:IsBanning(pPlayer,nOtherBanType) then
					pRank.UpdateValueByID(pPlayer.dwID, nCurFightPower)
				end
			end
		end

	end;

	["Level"] = function (pRank, pPlayer)
		if not Forbid:IsBanning(pPlayer,Forbid.BanType.LevelRank) then
			pRank.UpdateValueByID(pPlayer.dwID, {pPlayer.nLevel, pPlayer.GetExp()}); --4294967295 是Max uint32_t
		end
	end;

	["CardCollection_1"] = function (pRank, dwID, nValue, nRare)
		local pPlayer = KPlayer.GetPlayerObjById(dwID)
		if pPlayer and not Forbid:IsBanning(pPlayer,Forbid.BanType.CardCollection_1) then
			pRank.UpdateValueByID(dwID, {nValue, nRare})
		end
	end;

	["ZhongQiuJie"] = function (pRank, dwID, nRight, nTime)
		pRank.UpdateValueByID(dwID, {nRight, nTime})
	end;

	["CardCollection_2"] = function (pRank, dwId, nVal)
		pRank.UpdateValueByID(dwId, nVal);
	end;

	["House"] = function (pRank, pPlayer, nVal)
		if not pPlayer or Forbid:IsBanning(pPlayer, Forbid.BanType.HouseRank) then
			return;
		end
		pRank.UpdateValueByID(pPlayer.dwID, nVal);
	end
}


local function GetRankViewInfo(tbInfo, szKey)
	local fnGet = tbGetRankInfoView[szKey] or tbGetRankInfoView["Default"]
	return fnGet(tbInfo)
end

local function GetMyRankViewInfo(pPlayer, pRank, szKey)
	local fnGet = tbGetMyInfo[szKey] or tbGetMyInfo["Default"]
	return fnGet(pPlayer, pRank)
end

function RankBoard:UpdateRankVal(szKey, ...)
	local pRank = KRank.GetRankBoard(szKey)
	if not pRank then
		return
	end
	tbUpdateRankValFuc[szKey](pRank, ...)
end


--手动更新排行榜
function RankBoard:Rank(szKey)
	local pRank = KRank.GetRankBoard(szKey)
	if not pRank then
		return
	end
	pRank.Rank();
end

function RankBoard:ClearRank(szKey)
    local pRank = KRank.GetRankBoard(szKey)
	if not pRank then
		return
	end

	pRank.Clear();
end

function RankBoard:GetRankBoardWithLength(szKey, nLength, nFrom)
	local pRank = KRank.GetRankBoard(szKey)
	if not pRank then
		return
	end

	local tbFront = {};
	nFrom = nFrom or 1
	for i = nFrom, nLength do
		local tbInfo = pRank.GetRankInfoByPos(i - 1);
		if not tbInfo then
			break;
		end

		table.insert(tbFront, GetRankViewInfo(tbInfo, szKey));
	end

    return tbFront;
end


function RankBoard:UpdateValueByID(szKey, nId, nVal)
	local pRank = KRank.GetRankBoard(szKey)
	if not pRank then
		return
	end
	pRank.UpdateValueByID(nId, nVal)
end

function RankBoard:OpenRankBoard(pPlayer, szKey, nPage, bNeedMy)
	if not self.tbSetting[szKey] then
		return
	end
	local nMaxNum = self.tbSetting[szKey].MaxNum
	local nLength = math.min(nPage * RankBoard.PAGE_NUM, nMaxNum) 
	local nFrom = nLength - RankBoard.PAGE_NUM + 1
	local tbFront = self:GetRankBoardWithLength(szKey, nLength, nFrom)
	if tbFront then
		local tbMyInfo;
		if bNeedMy then
			local pRank = KRank.GetRankBoard(szKey)
			tbMyInfo = GetMyRankViewInfo(pPlayer, pRank, szKey) or {}
			tbMyInfo.nLength = math.min(pRank.GetRankLength(), nMaxNum) 
		end

		pPlayer.CallClientScript("RankBoard:OnGetRanBoadData", tbFront, szKey, nPage, tbMyInfo)
	else
		pPlayer.CenterMsg("已沒有排行榜資料")
	end
end

function RankBoard:UpdateAllRank()
	for Key, tbInfo in pairs(self.tbSetting) do
		local pRank = KRank.GetRankBoard(Key)
		if pRank then
			pRank.Rank();
		end
	end
	Log("RankBoard UpdateAllRank")
end

if MODULE_ZONESERVER then
	function RankBoard:UpdateRankVal( ... )
	end
end