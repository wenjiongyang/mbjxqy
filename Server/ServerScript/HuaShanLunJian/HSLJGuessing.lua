Require("CommonScript/HuaShanLunJian/LunJianDef.lua");
local tbDef             = HuaShanLunJian.tbDef;
local tbFinalsDef       = tbDef.tbFinalsGame;
local tbGuessingDef     = tbDef.tbChampionGuessing;

HuaShanLunJian.tbAllPlayerGuessingVerID = HuaShanLunJian.tbAllPlayerGuessingVerID or {};

function HuaShanLunJian:GetGuessingSavaDataKey(nVersion)
    local szKey = string.format("HSLJGuessing:%s", nVersion);
    return szKey;
end

function HuaShanLunJian:HaveGuessingSavaData(nVersion)
    local szKey = self:GetGuessingSavaDataKey(nVersion);
    ScriptData:AddDef(szKey);
    local tbTeam = ScriptData:GetValue(szKey);
    if not tbTeam or not tbTeam.nGameMonth then
        return false;
    end

    return true;    
end

function HuaShanLunJian:UpdateAllPlayerGuessingVersion()
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

function HuaShanLunJian:GetGuessingSavaData(nVersion)
    if nVersion <= 0 or nVersion >= tbDef.nMaxGuessingVer then
        Log("Error HuaShanLunJian GetGuessingSavaData", nVersion);
        return;
    end

    local tbSaveData = self:GetLunJianSaveData();
    local szKey = self:GetGuessingSavaDataKey(nVersion);
    ScriptData:AddDef(szKey);
    local tbGuessing = ScriptData:GetValue(szKey);
    if tbGuessing.nGameMonth and tbGuessing.nGameMonth == tbSaveData.nGameMonth then
        return tbGuessing;
    end

    tbGuessing.nGameMonth = tbSaveData.nGameMonth;
    tbGuessing.nCount     = 0;
    tbGuessing.nVer       = nVersion;
    tbGuessing.tbAllPlayer = {};
    return tbGuessing;
end

function HuaShanLunJian:GetCanGuessingSavaData()
    local tbSaveData = self:GetLunJianSaveData();
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

function HuaShanLunJian:GetPlayerGuessingVer(pPlayer)
    local nVersion = self.tbAllPlayerGuessingVerID[pPlayer.dwID] or 0;
    return nVersion;
end

function HuaShanLunJian:GetPlayerGuesingSavaData(pPlayer)
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


function HuaShanLunJian:CheckPlayerChampionGuessing(pPlayer, nFightTeamID, nOneNoteCount, bNotCheckGlod)
    local bRet = self:CheckCanOpenHSLJ();
    if not bRet then
        return false, "尚未開啟";
    end

    local tbSaveData = self:GetLunJianSaveData();
    local nMonthDay = Lib:GetMonthDay();
    if nMonthDay ~= tbFinalsDef.nMonthDay then
        return false, "尚未開啟！";
    end

    if tbSaveData.nPlayState ~= tbDef.nPlayStatePrepare then
        return false, "競猜已經結束了";
    end

    if tbSaveData.nChampionId ~= 0 then
        return false, "冠軍已經產生了";
    end    

    local tbNotFinalsData = self:GetFinalsGameNotSave();
    if tbNotFinalsData.bStart then
        return false, "競猜已經結束了！";
    end

    local tbFinalsInfo = self:GetFinalsFightTeamByID(nFightTeamID);
    if not tbFinalsInfo then
        return false, "請選擇可以競猜的戰隊"
    end

    if pPlayer.nLevel < tbGuessingDef.nMinLevel then
        return false, string.format("等級不足%s", tbGuessingDef.nMinLevel);
    end  

    local tbSaveInfo = self:GetPlayerGuesingSavaData(pPlayer);
    if tbSaveInfo then
        local nSaveTeam = tbSaveInfo[tbDef.nGuessTypeTeam];
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
function HuaShanLunJian:PlayerChampionGuessing(pPlayer, nFightTeamID)
    local bRet, szMsg = self:CheckPlayerChampionGuessing(pPlayer, nFightTeamID);
    if not bRet then
        pPlayer.CenterMsg(szMsg, true);
        return;
    end

    local tbSaveInfo = HuaShanLunJian:GetPlayerGuesingSavaData(pPlayer);
    if not tbSaveInfo then
        tbSaveInfo = {};
        tbSaveInfo[tbDef.nGuessTypeTeam] = nFightTeamID;
        tbSaveInfo[tbDef.nGuessTypeOneNote] = 0;

        local tbSaveGuessing = HuaShanLunJian:GetCanGuessingSavaData();
        tbSaveGuessing.nCount     = tbSaveGuessing.nCount  + 1;
        tbSaveGuessing.tbAllPlayer[pPlayer.dwID] = tbSaveInfo;

        self.tbAllPlayerGuessingVerID[pPlayer.dwID] = tbSaveGuessing.nVer;
    end

    tbSaveInfo[tbDef.nGuessTypeOneNote] = 1;
    tbSaveInfo[tbDef.nGuessTypeTeam] = nFightTeamID;

    self:SyncGuessingData(pPlayer);
    pPlayer.CallClientScript("Player:ServerSyncData", "HSLJGuessing");
    pPlayer.CenterMsg("競猜成功！", true);
    Log("HSLJ PlayerChampionGuessing", pPlayer.dwID, nFightTeamID);
end

function HuaShanLunJian:SyncGuessingData(pPlayer)
    local tbSyncData = {};
    local tbSaveInfo = self:GetPlayerGuesingSavaData(pPlayer);
    if tbSaveInfo then
        tbSyncData.nFightTeamID = tbSaveInfo[tbDef.nGuessTypeTeam];
    end

    pPlayer.CallClientScript("Player:ServerSyncData", "HSLJGuessingData", tbSyncData);    
end