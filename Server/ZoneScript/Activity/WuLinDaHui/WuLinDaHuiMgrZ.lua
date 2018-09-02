if not MODULE_ZONESERVER then
	return
end

--todo 新的地图id要在跨服上重新注册一遍，现在还是旧的
local tbDef = WuLinDaHui.tbDef

function WuLinDaHui:ClearMathInfo()
	self.nCurGameType = nil;
	self.bCurIsFinal = nil;
	self.nLastRequestTime = nil;
	self.bFinalsAward = nil;
	self.tbAllPlayerFightTeamID = {};
	self.tbFightTeamNotSave = {
	  tbAllFightTeamName = {};
	  tbAllFightTeamInst = {};
	  tbAllFightTeamIdToConnIdx ={};
	};
	self.tbZoneTeamData = {};
	self.tbZoneSaveData = {};
	self.tbFinalsFightTeam = {};
	self.tbCachePlayerViewItems = {};
	HuaShanLunJian:ClearPrepareGameNotSave();
end
--TODO 服务器上打完的时候也要调下  ClearMathInfo

--重载，每次重启开活动时里面值都会清掉
function WuLinDaHui:GetSaveData()
	return self.tbZoneSaveData;
end

function WuLinDaHui:OpenMatchZ(nGameType, bFinal)
	--因为同时会有多个服请求开启的，只处理第一个
	local nNow = GetTime()
	if self.nLastRequestTime and math.abs(self.nLastRequestTime - nNow) < 60*20 then --内跨服上应该不会又开一场
		Log("WuLinDaHui:OpenMatchZ SameRequest", self.nLastRequestTime, nNow)
		return
	end

	self:ClearMathInfo();
	
	self.nLastRequestTime = nNow
	self.nOpenMathTime = nNow;
	local tbSaveData = self:GetSaveData()
	tbSaveData.nStartBaoMingTime = nNow; -- 用于跨服上重新创建战队的版本号

	self.nCurGameType = nGameType
	self.bCurIsFinal = bFinal

	--跨服上就直接用华山论剑的数据的了

	if not bFinal then
		local tbNotPreData = HuaShanLunJian:GetPrepareGameNotSave();
	    tbNotPreData.bStart = true;
	    tbNotPreData.nPlayGameCount = WuLinDaHui.tbDef.tbPrepareGame.nPlayerGameCount;
	    tbNotPreData.tbPreGameFightTeam = {};
	    tbNotPreData.tbMatchMapTeam = {};	
	    HuaShanLunJian.tbPreGamePreMgr:StartPreGame()
	else
		local tbNotFinalsData = HuaShanLunJian:GetFinalsGameNotSave();
	    tbNotFinalsData.bStart = true;
	    tbNotFinalsData.tbFinalsAllMapID = {};
	    tbNotFinalsData.tbFinalsAllMapIndex = {};
	    
	end

end

function WuLinDaHui:RequestSynRoleInfo(tbRequestRoleIds)
	local nConnectIdx = Server.nCurConnectIdx;
	for i,v in ipairs(tbRequestRoleIds) do
		SendTempRoleStayInfoToZC(nConnectIdx, v)
	end
end

function WuLinDaHui:OnFinalTeamGetEnd()
	Log("WuLinDaHui:OnFinalTeamGetEnd=========")
	--数据同步完再做的 这时候跨服上应该只有进入决赛的战队信息
	local tbNotFinalsData = HuaShanLunJian:GetFinalsGameNotSave();
	local tbBaseLogic = HuaShanLunJian.tbBaseFinalsMapLogic;
    tbNotFinalsData.tbFinalsLogicMgr = Lib:NewClass(tbBaseLogic);
    tbNotFinalsData.tbFinalsLogicMgr:OnCreate();

    local tbGameFormat = self.tbGameFormat[self.nCurGameType];
    local nCreateCount = 1;
    if tbGameFormat.nFinalsMapCount then
        nCreateCount = tbGameFormat.nFinalsMapCount;
    end

    for i = 1, nCreateCount do
    	CreateMap(tbDef.tbFinalsGame.nFinalsMapTID);
    end
end

function WuLinDaHui:GetFinalsFightTeamByID(nFightTeamID)
    return self.tbFinalsFightTeam[nFightTeamID]
end

function WuLinDaHui:GetToydayGameFormat()
	return self.nCurGameType
end

function WuLinDaHui:CachePlayerViewItemInfo( dwRoleId, tbItems )
	self.tbCachePlayerViewItems[dwRoleId] = tbItems
end

function WuLinDaHui:ChangeFightTeamPlayerNum(pPlayer, tbPlayerNum, nGameType)
	local bRet, szMsg, tbFightTeam = self:CheckChangeFightTeamPlayerNum(pPlayer, tbPlayerNum, nGameType);
    if not bRet then
        pPlayer.CenterMsg(szMsg, true);
        return;
    end
	local tbCurPlayerNum = {};
    for nPlayerID, nNum in pairs(tbPlayerNum) do
        local bRet1 = tbFightTeam:HavePlayerID(nPlayerID);
        if bRet1 then
            tbFightTeam:ChangePlayerNum(nPlayerID, nNum);
            tbCurPlayerNum[nNum] = nPlayerID;
            Log("WuLinDaHui ChangeFightTeamPlayerNum", tbFightTeam:GetID(), nPlayerID, nNum);
        end    
    end
    CallZoneClientScript(pPlayer.nZoneIndex,  "WuLinDaHui:OnZCChangeFightTeamPlayerNum", pPlayer.dwID, tbPlayerNum, nGameType)
end


WuLinDaHui.tbC2ZRequest = {
	["RequestTopPreFightTeamList"] = function (pPlayer, nGameType, nClientSynTime)
		CallZoneClientScript(pPlayer.nZoneIndex,  "WuLinDaHui:OnZCRequestTopPreFightTeamList", pPlayer.dwID, nGameType, nClientSynTime)
	end;

	["RequestFightTeamShow"] = function (pPlayer, nFightTeamID)
        CallZoneClientScript(pPlayer.nZoneIndex,  "WuLinDaHui:OnZCRequestFightTeamShowInfo", pPlayer.dwID, nFightTeamID)
    end;

    ["RequestFightTeam"] = function (pPlayer, nGameType)
    	CallZoneClientScript(pPlayer.nZoneIndex,  "WuLinDaHui:OnZCRequestFightTeam", pPlayer.dwID, nGameType)
    end;

    ["ChangeTeamNum"] = function (pPlayer, tbPlayerNum, nGameType)
        WuLinDaHui:ChangeFightTeamPlayerNum(pPlayer, tbPlayerNum, nGameType)
    end;

    ["SyncFinalsWatchData"] = function (pPlayer)
        HuaShanLunJian:SyncFinalsWatchData(pPlayer); --和华山论剑一样的
    end;
    ["SyncWatchTeamPlayerData"] = function (pPlayer, nFightTeamID)
        if type(nFightTeamID) ~= "number" then
            return;
        end
        
        HuaShanLunJian:SyncWatchTeamPlayerData(pPlayer, nFightTeamID)
   end;
	["PlayerWatchTeamPlayer"] = function (pPlayer, nPlayerID, bAutoFinsh)
        if type(nPlayerID) ~= "number" then
            return;
        end
        HuaShanLunJian:PlayerWatchTeamPlayer(pPlayer, nPlayerID, bAutoFinsh)
   end;
};