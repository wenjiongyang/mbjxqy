local tbDef = WuLinDaHui.tbDef
WuLinDaHui.tbAllPlayerGuessingVerID = WuLinDaHui.tbAllPlayerGuessingVerID or {};

function WuLinDaHui:GetGuessingSavaDataKey(nVersion)
    local szKey = string.format("WLDHGuessing:%s", nVersion);
    return szKey;
end

function WuLinDaHui:HaveGuessingSavaData(nVersion)
    local szKey = self:GetGuessingSavaDataKey(nVersion);
    ScriptData:AddDef(szKey);
    local tbData = ScriptData:GetValue(szKey);
    if not tbData or not tbData.nStartBaoMingTime then
        return false;
    end

    return true;    
end

function WuLinDaHui:UpdateAllPlayerGuessingVersion()
    self.tbAllPlayerGuessingVerID = {};

    for nV = 1, tbDef.nMaxGuessingVer - 1 do
        local bRet = self:HaveGuessingSavaData(nV);
        if not bRet then
            return;
        end

        local tbGuessing = self:GetGuessingSavaData(nV);
        if tbGuessing then 
            for nPlayerID, tbSaveInfo in pairs(tbGuessing.tbAllPlayer) do 
                self.tbAllPlayerGuessingVerID[nPlayerID] = nV;
            end 
        end 
    end
end

function WuLinDaHui:GetGuessingSavaData(nVersion)
    if nVersion <= 0 or nVersion >= tbDef.nMaxGuessingVer then
        Log("Error WuLinDaHui GetGuessingSavaData", nVersion);
        return;
    end

    local tbSaveData = self:GetSaveData()
    local szKey = self:GetGuessingSavaDataKey(nVersion);
    ScriptData:AddDef(szKey);
    local tbGuessing = ScriptData:GetValue(szKey);
    if tbGuessing.nStartBaoMingTime and tbGuessing.nStartBaoMingTime == tbSaveData.nStartBaoMingTime then
        return tbGuessing;
    end

    tbGuessing.nStartBaoMingTime = tbSaveData.nStartBaoMingTime;
    tbGuessing.nCount     = 0;
    tbGuessing.nVer       = nVersion;
    tbGuessing.tbAllPlayer = {};
    return tbGuessing;
end

function WuLinDaHui:GetCanGuessingSavaData()
    local tbSaveData = self:GetSaveData()
    for nV = tbSaveData.nGuessingVer, tbDef.nMaxGuessingVer - 1 do
        local tbGuessing = self:GetGuessingSavaData(nV);
        if not tbGuessing then
            return;
        end

        if tbGuessing.nCount < tbDef.nSaveGuessingCount then
            tbSaveData.nGuessingVer = nV;
            return tbGuessing;
        end    
    end
end

function WuLinDaHui:GetPlayerGuessingVer(pPlayer)
    local nVersion = self.tbAllPlayerGuessingVerID[pPlayer.dwID] or 0;
    return nVersion;
end

function WuLinDaHui:GetPlayerGuesingSavaData(pPlayer)
   local nVersion = self:GetPlayerGuessingVer(pPlayer);
   if nVersion <= 0 then
        return;
   end

   local tbSaveGuessing = self:GetGuessingSavaData(nVersion);
   if not tbSaveGuessing then
        return;
   end

   local tbSaveInfo = tbSaveGuessing.tbAllPlayer[pPlayer.dwID];
   return tbSaveInfo;
end


function WuLinDaHui:CheckPlayerChampionGuessing(pPlayer, nFightTeamID, nGameType)
    --产生16强，且没产生冠军前应该都可以
    local tbSaveData = self:GetSaveData()
    if tbSaveData["WinnerTeamId" .. nGameType] then
         return false, "冠軍已經產生了";
    end

    if self.tbNotSaveData.nCurGameType == nGameType and self.tbNotSaveData.bCurIsFinal then
        return false, "該賽制競猜已經結束了"
    end

    local tbFinalsFightTeam = tbSaveData["tbFinalsFightTeam" .. nGameType];
    if not tbFinalsFightTeam or not next(tbFinalsFightTeam) then
        return false, "當前沒有可以競猜的隊伍"
    end

    local tbFinalsInfo = tbFinalsFightTeam[nFightTeamID]
    if not tbFinalsInfo then
        return false, "請選擇可以競猜的戰隊"
    end

    if pPlayer.nLevel < tbDef.tbChampionGuessing.nMinLevel then
        return false, string.format("等級不足%s", tbDef.tbChampionGuessing.nMinLevel);
    end  

    local tbSaveInfo = self:GetPlayerGuesingSavaData(pPlayer);
    if tbSaveInfo then
        local nSaveTeam = tbSaveInfo[nGameType];
        if nSaveTeam == nFightTeamID then
            return false, "已經競猜當前的戰隊";
        end
    else
        local tbCanSaveGuessing = self:GetCanGuessingSavaData();
        if not tbCanSaveGuessing then
            return false, "投注的名額已滿";
        end   
    end  

    return true, "";
end

--玩家冠军竞猜
function WuLinDaHui:PlayerChampionGuessing(pPlayer, nFightTeamID, nGameType)
    local bRet, szMsg = self:CheckPlayerChampionGuessing(pPlayer, nFightTeamID, nGameType);
    if not bRet then
        pPlayer.CenterMsg(szMsg, true);
        return;
    end
    local tbSaveInfo = self:GetPlayerGuesingSavaData(pPlayer);
    if not tbSaveInfo then
        tbSaveInfo = {};
        local tbSaveGuessing = self:GetCanGuessingSavaData();
        tbSaveGuessing.nCount     = tbSaveGuessing.nCount  + 1;
        tbSaveGuessing.tbAllPlayer[pPlayer.dwID] = tbSaveInfo;

        self.tbAllPlayerGuessingVerID[pPlayer.dwID] = tbSaveGuessing.nVer;
    end
    tbSaveInfo[nGameType] = nFightTeamID;

    self:SyncGuessingData(pPlayer);
    pPlayer.CallClientScript("Player:ServerSyncData", "WLDHGuessing");
    pPlayer.CenterMsg("競猜成功！", true);
    Log("WuLinDaHui PlayerChampionGuessing", pPlayer.dwID, nFightTeamID, nGameType);
end

function WuLinDaHui:SyncGuessingData(pPlayer)
    local tbSyncData = self:GetPlayerGuesingSavaData(pPlayer) or {};
    pPlayer.CallClientScript("Player:ServerSyncData", "WLDHGuessingData", tbSyncData);    
end