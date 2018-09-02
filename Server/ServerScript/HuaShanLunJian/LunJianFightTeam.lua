
Require("ServerScript/HuaShanLunJian/HuaShanLunJian.lua");
local tbDef = HuaShanLunJian.tbDef;
HuaShanLunJian.__tbBaseFightTeam = HuaShanLunJian.__tbBaseFightTeam  or {};
local tbBaseFightTeam = HuaShanLunJian.__tbBaseFightTeam;
HuaShanLunJian.tbAllPlayerFightTeamID = HuaShanLunJian.tbAllPlayerFightTeamID or {};

function tbBaseFightTeam:SetSaveData(tbSaveData, nID)
    self.tbSaveData = tbSaveData;
    self.nID = nID;
end

function tbBaseFightTeam:GetID()
    return self.nID;
end

function tbBaseFightTeam:GetName()
    return self.tbSaveData[tbDef.nTeamTypeName];
end

function tbBaseFightTeam:GetAllPlayerID()
    local tbAllPlayer = self.tbSaveData[tbDef.nTeamTypePlayer] or {};
    return tbAllPlayer;
end

function tbBaseFightTeam:GetPlayerNum(nPlayerID)
    local tbAllPlayer = self:GetAllPlayerID();
    local nNum = tbAllPlayer[nPlayerID] or 0;
    return nNum;
end

function tbBaseFightTeam:FindPlayerIDByNum(nFindNum)
    local tbAllPlayer = self:GetAllPlayerID();
    for nPlayerID, nNum in pairs(tbAllPlayer) do
        if nNum == nFindNum then
            return nPlayerID;
        end    
    end    
end 

function tbBaseFightTeam:AddPlayerID(nPlayerID)
    self.tbSaveData[tbDef.nTeamTypePlayer] = self.tbSaveData[tbDef.nTeamTypePlayer] or {};
    self.tbSaveData[tbDef.nTeamTypePlayer][nPlayerID] = 0;

    local nFightTeamID = self:GetID();
    HuaShanLunJian.tbAllPlayerFightTeamID[nPlayerID] = nFightTeamID;

    self:ResetPlayerNum();
end

function tbBaseFightTeam:ResetPlayerNum()
    local nCount = self:GetPlayerCount();
    if nCount <= 0 then
        return;
    end

    local tbAllPlayer = self:GetAllPlayerID();
    local tbSortID = {};
    for nPlayerID, _ in pairs(tbAllPlayer) do
        table.insert(tbSortID, nPlayerID);
    end

    table.sort(tbSortID, function (a, b)
        return a < b;
    end); 

    for nNum, nPlayerID in pairs(tbSortID) do
        local bRet = self:HavePlayerID(nPlayerID);
        if bRet then
            self:ChangePlayerNum(nPlayerID, nNum);
        end      
    end   
end

function tbBaseFightTeam:ChangePlayerNum(nPlayerID, nNum)
    local bRet = self:HavePlayerID(nPlayerID);
    if not bRet then
        return;
    end

    self.tbSaveData[tbDef.nTeamTypePlayer][nPlayerID] = nNum;    
end

function tbBaseFightTeam:GetPlayerCount()
    local tbAllPlayerID = self:GetAllPlayerID();
    local nCount = Lib:CountTB(tbAllPlayerID);
    return nCount;
end

function tbBaseFightTeam:HavePlayerID(nPlayerID)
    local tbAllPlayer = self:GetAllPlayerID();
    if not tbAllPlayer[nPlayerID] then
        return false;
    end

    return true;
end

function tbBaseFightTeam:RemovePlayer(nPlayerID)
    local bRet = self:HavePlayerID(nPlayerID);
    if not bRet then
        return;
    end

    self.tbSaveData[tbDef.nTeamTypePlayer][nPlayerID] = nil;

    local nFightTeamID = self:GetID();
    local nPlayerTeamID = HuaShanLunJian.tbAllPlayerFightTeamID[nPlayerID];
    if nPlayerTeamID and nPlayerTeamID == nFightTeamID then
        HuaShanLunJian.tbAllPlayerFightTeamID[nPlayerID] = nil;
    end

    self:ResetPlayerNum();      
end

--积分 * 100 * 100 + 胜利场数 * 100 + 总共场数
function tbBaseFightTeam:GetValue()
    local nValue = self.tbSaveData[tbDef.nTeamTypeValue] or 0;
    return nValue;
end

function tbBaseFightTeam:UpdateValue(nJiFen, nWinCount, nJoinCount)
    local nValue = nJiFen * 100 * 100 + nWinCount * 100 + nJoinCount;
    self.tbSaveData[tbDef.nTeamTypeValue] = nValue;
end

function tbBaseFightTeam:GetJoinCount()
    local nValue = self:GetValue();
    local nJoinCount = nValue % 100;
    return nJoinCount;
end

function tbBaseFightTeam:GetWinCount()
    local nValue = self:GetValue();
    local nWinCount = math.floor(nValue / 100) % 100;
    return nWinCount;
end

function tbBaseFightTeam:GetJiFen()
    local nValue = self:GetValue();
    local nJiFen = math.floor(nValue / 100 / 100);
    return nJiFen;
end

function tbBaseFightTeam:GetPlayTime()
    local nTime = self.tbSaveData[tbDef.nTeamTypeTime] or 0;
    return nTime;
end

function tbBaseFightTeam:AddPlayTime(nTime)
    local nTotatTime = self:GetPlayTime();
    self.tbSaveData[tbDef.nTeamTypeTime] = nTotatTime + nTime;
end

function tbBaseFightTeam:AddWinCount()
    local nJiFen     = self:GetJiFen();
    local nJoinCount = self:GetJoinCount();
    local nWinCount  = self:GetWinCount();
    nWinCount = nWinCount + 1;
    self:UpdateValue(nJiFen, nWinCount, nJoinCount);
end

function tbBaseFightTeam:AddJoinCount()
    local nJiFen     = self:GetJiFen();
    local nJoinCount = self:GetJoinCount();
    local nWinCount  = self:GetWinCount();
    nJoinCount = nJoinCount + 1;
    self:UpdateValue(nJiFen, nWinCount, nJoinCount);
    self:AddPerDayCount();

    self:AddCalendarCompleteAct(0);
end

function tbBaseFightTeam:AddCalendarCompleteAct(nRankPos)
    if not nRankPos or nRankPos < 0 then
        return;
    end

    local tbAllPlayer = self:GetAllPlayerID();
    for nPlayerID, _ in pairs(tbAllPlayer) do
        Lib:CallBack({Calendar.OnCompleteAct, Calendar, nPlayerID, "HuaShanLunJian", nRankPos});
    end  
end

function tbBaseFightTeam:GetPerDayCount()
    local nPlayTime = self.tbSaveData[tbDef.nTeamTypePlayDay] or 0;
    local nCurDay = Lib:GetLocalDay();
    local nPlayCount = self.tbSaveData[tbDef.nTeamTypePerCount] or 0;
    if nPlayTime == nCurDay then
        return nPlayCount;
    end

    self.tbSaveData[tbDef.nTeamTypePerCount] = 0;
    self.tbSaveData[tbDef.nTeamTypePlayDay] = nCurDay;
    return 0;    
end

function tbBaseFightTeam:AddPerDayCount()
    local nPerCount = self:GetPerDayCount();
    self.tbSaveData[tbDef.nTeamTypePerCount] = nPerCount + 1;
end

function tbBaseFightTeam:AddJiFen(nAdd)
    if nAdd <= 0 then
        return;
    end    

    local nJiFen     = self:GetJiFen();
    local nJoinCount = self:GetJoinCount();
    local nWinCount  = self:GetWinCount();
    nJiFen = nJiFen + nAdd;
    self:UpdateValue(nJiFen, nWinCount, nJoinCount);
end

--Rank Value = (nJiFen * 100 + nWinCount) * tbDef.nPrePlayTotalTime + nRankTime;
function tbBaseFightTeam:GetRankValue()
    local nJiFen = self:GetJiFen();
    local nWinCount = self:GetWinCount();
    local nTime = self:GetPlayTime();
    local nValue = nJiFen * 100 + nWinCount;
    local nRankTime = tbDef.nPrePlayTotalTime - nTime;
    if nRankTime <= 0 then
        nRankTime = 0;
    end
    return nValue * tbDef.nPrePlayTotalTime + nRankTime;
end

function tbBaseFightTeam:UpdateHSLJRankBoard()
    local nRankValue = self:GetRankValue()
    RankBoard:UpdateValueByID(tbDef.szRankBoard, self.nID, nRankValue);
    Log("UpdateHSLJRankBoard", self.nID, nRankValue);
    return nRankValue;
end

function tbBaseFightTeam:AnalyzeRankValue(nValue)
    local nRankTime = nValue % tbDef.nPrePlayTotalTime;
    local nTime = tbDef.nPrePlayTotalTime - nRankTime;
    local nJiFen = math.floor(nValue / tbDef.nPrePlayTotalTime / 100);
    local nWinCount = math.floor(nValue / tbDef.nPrePlayTotalTime) % 100;
    return nJiFen, nWinCount, nTime;
end

function HuaShanLunJian:GetFightTeamNotSaveData()
    self.tbFightTeamNotSave.tbAllFightTeamName = self.tbFightTeamNotSave.tbAllFightTeamName or {};
    self.tbFightTeamNotSave.tbAllFightTeamInst = self.tbFightTeamNotSave.tbAllFightTeamInst or {};

    self:UpdateFightTeamNameNotSaveData();
    return self.tbFightTeamNotSave;
end

function HuaShanLunJian:UpdateFightTeamNameNotSaveData()
    if self.tbFightTeamNotSave.bLoadData then
        return;
    end

    self.tbFightTeamNotSave.tbAllFightTeamName = {};
    self.tbFightTeamNotSave.bLoadData = true;

    for nVer = 1, tbDef.nMaxFightTeamVer - 1 do
        local bRet = self:HaveFightTeamSavaData(nVer);
        if not bRet then
            return;
        end    

        local tbSaveData = self:GetFightTeamSavaData(nVer);
        for nFightTeamID, _ in pairs(tbSaveData.tbAllTeam) do
            local tbFightTeam = self:GetFightTeamByID(nFightTeamID);
            local szName = tbFightTeam:GetName();
            self.tbFightTeamNotSave.tbAllFightTeamName[szName] = nFightTeamID;
        end    
    end  
end

function HuaShanLunJian:UpdateAllPlayerFightTeamID()
    Log("HSLJ UpdateAllPlayerFightTeamID"); 
    self.tbAllPlayerFightTeamID = {};
    for nVer = 1, tbDef.nMaxFightTeamVer - 1 do
        local bRet = self:HaveFightTeamSavaData(nVer);
        if not bRet then
            return;
        end    

        local tbSaveData = self:GetFightTeamSavaData(nVer);
        for nFightTeamID, _ in pairs(tbSaveData.tbAllTeam) do
            local tbFightTeam = self:GetFightTeamByID(nFightTeamID);
            if tbFightTeam then
                local tbAllPlayerID = tbFightTeam:GetAllPlayerID();
                local tbRemoveID = {};
                for nPlayerID, _ in pairs(tbAllPlayerID) do

                    if not self.tbAllPlayerFightTeamID[nPlayerID] then
                        self.tbAllPlayerFightTeamID[nPlayerID] = nFightTeamID;
                    else
                        tbRemoveID[nPlayerID] = 1;
                    end    
                end

                for nRemoveID, _ in pairs(tbRemoveID) do
                    tbFightTeam:RemovePlayer(nRemoveID);
                    Log("Error HSLJ UpdateAllPlayerFightTeamID", nRemoveID, nFightTeamID);
                end    
            end    
        end    
    end 
end

function HuaShanLunJian:GetFightTeamIDByName(szTeamName)
    local tbNotSave = self:GetFightTeamNotSaveData();
    local tbAllFightTeamName = tbNotSave.tbAllFightTeamName;
    if not tbAllFightTeamName then
        return;
    end

    return tbAllFightTeamName[szTeamName];
end


function HuaShanLunJian:HaveFightTeamSavaData(nVersion)
    local szKey = self:GetFightTeamSavaDataKey(nVersion);
    ScriptData:AddDef(szKey);
    local tbTeam = ScriptData:GetValue(szKey);
    if not tbTeam or not tbTeam.nGameMonth then
        return false;
    end

    return true;    
end

function HuaShanLunJian:GetFightTeamSavaDataKey(nVersion)
    local szKey = string.format("LunJianFightTeam:%s", nVersion);
    return szKey;
end

function HuaShanLunJian:GetFightTeamSavaData(nVersion)
    if nVersion <= 0 or nVersion >= tbDef.nMaxFightTeamVer then
        Log("Error HuaShanLunJian GetFightTeamSavaData", nVersion);
        return;
    end

    local tbSaveData = self:GetLunJianSaveData();
    local szKey = self:GetFightTeamSavaDataKey(nVersion);
    ScriptData:AddDef(szKey);
    local tbTeam = ScriptData:GetValue(szKey);
    if tbTeam.nGameMonth and tbTeam.nGameMonth == tbSaveData.nGameMonth then
        return tbTeam;
    end

    tbTeam.nGameMonth = tbSaveData.nGameMonth;
    tbTeam.nCount     = 0;
    tbTeam.nVer       = nVersion;
    tbTeam.tbAllTeam  = {};
    return tbTeam;
end

function HuaShanLunJian:GetCanFightTeamSava()
    local tbSaveData = self:GetLunJianSaveData();
    for nV = tbSaveData.nFightTeamVer, tbDef.nMaxFightTeamVer - 1 do
        local tbTeam = self:GetFightTeamSavaData(nV);
        if not tbTeam then
            return;
        end

        if tbTeam.nCount < tbDef.nMaxFightTeamCount then
            tbSaveData.nFightTeamVer = nV;
            return tbTeam;
        end    
    end
end


function HuaShanLunJian:GetFightTeamVerData(nFightTeamID)
    local nVersion = nFightTeamID % tbDef.nMaxFightTeamVer;
    local tbSaveData = self:GetFightTeamSavaData(nVersion);
    return tbSaveData;
end

function HuaShanLunJian:GetFightTeamSavaByID(nFightTeamID)
    local tbSaveData = self:GetFightTeamVerData(nFightTeamID);
    if not tbSaveData then
        return;
    end    

    return tbSaveData.tbAllTeam[nFightTeamID];
end

function HuaShanLunJian:GetFightTeamByID(nFightTeamID)
    local tbSaveData = self:GetFightTeamSavaByID(nFightTeamID);
    if not tbSaveData then
        return;
    end

    local tbNotSave = self:GetFightTeamNotSaveData();
    local tbInst = tbNotSave.tbAllFightTeamInst[nFightTeamID];
    if not tbInst then
        tbInst = Lib:NewClass(tbBaseFightTeam);
        tbNotSave.tbAllFightTeamInst[nFightTeamID] = tbInst;
    end

    tbInst:SetSaveData(tbSaveData, nFightTeamID);

    return tbInst;
end

function HuaShanLunJian:RemoveFightTeam(nFightTeamID)
    local tbSaveData = self:GetFightTeamVerData(nFightTeamID);
    local tbAllFightTeam = tbSaveData.tbAllTeam;
    if not tbAllFightTeam then
        return;
    end    

    local tbFightTeamData = tbAllFightTeam[nFightTeamID];
    if not tbFightTeamData then
        return;
    end

    local tbNotSave = self:GetFightTeamNotSaveData();
    local tbInst = self:GetFightTeamByID(nFightTeamID);
    local szName = tbInst:GetName();

    tbNotSave.tbAllFightTeamName[szName] = nil;
    tbNotSave.tbAllFightTeamInst[nFightTeamID] = nil;
    tbAllFightTeam[nFightTeamID] = nil;

    Log("HSLJ RemoveFightTeam ", nFightTeamID);
    return;
end


function HuaShanLunJian:GetPlayerFightTeam(pPlayer)
    --self:UpdatePlayerSaveData(pPlayer);
    --local nFightTeamID = pPlayer.GetUserValue(tbDef.nSaveGroupID, tbDef.nSaveFightTeamID);
    local nFightTeamID = self.tbAllPlayerFightTeamID[pPlayer.dwID] or 0;
    return nFightTeamID;
end

function HuaShanLunJian:CheckFightTeamName(szTeamName)
    if not szTeamName or szTeamName == "" then
        return false, "請輸入名字";
    end

    if Lib:HasNonChineseChars(szTeamName) then
        return false, "戰隊名只能使用中文字元，請修改後重試";
    end

    if string.find(szTeamName, "%s") then
        return false, "戰隊名當中不可含有空格";
    end

    if not CheckNameAvailable(szTeamName) then
        return false, "戰隊名含有敏感字元，請修改後重試";
    end

    if tbDef.bStringLenName then
        local nVNLen = string.len(szTeamName);
        if nVNLen > tbDef.nFightTeamNameMax or nVNLen < tbDef.nFightTeamNameMin then
            return false, string.format("戰隊名字需在%d~%d字之間", tbDef.nFightTeamNameMin, tbDef.nFightTeamNameMax);
        end
    else    
        local nNameLen = Lib:Utf8Len(szTeamName);
        if nNameLen > tbDef.nFightTeamNameMax or nNameLen < tbDef.nFightTeamNameMin then
            return false, string.format("戰隊名字需在%d~%d字之間", tbDef.nFightTeamNameMin, tbDef.nFightTeamNameMax);
        end
    end
        
    return true, "";
end

function HuaShanLunJian:CheckJoinTeamMember(nPlayerID)
    local pMember = KPlayer.GetPlayerObjById(nPlayerID);
    if not pMember then
        local tbPlayerInfo = self:GetPlayerInfoByID(nPlayerID);
        return false, string.format("「%s」不線上", tbPlayerInfo.szName);
    end

    if tbDef.nMinPlayerLevel > pMember.nLevel then
        return false, string.format("「%s」的等級不足%d", pMember.szName, tbDef.nMinPlayerLevel);
    end

    local nMemberTeamID = self:GetPlayerFightTeam(pMember);
    if nMemberTeamID > 0 then
        return false, string.format("「%s」已經擁有戰隊", pMember.szName);
    end

    local bRet = Map:CheckEnterOtherMap(pMember);
    if not bRet then
        return false, string.format("「%s」處於非安全區無法進行戰隊相關操作", pMember.szName);
    end

    return true, "";
end

function HuaShanLunJian:CheckPlayerFightTeamPeriod(pPlayer)
    local bRet = self:IsPlayGamePeriod();
    if not bRet then
        return false, "尚未開啟!";
    end

    if GetTimeFrameState(tbDef.szOpenTimeFrame) ~= 1 then
        return false, "尚未開啟華山論劍！";
    end

    if tbDef.nMinPlayerLevel > pPlayer.nLevel then
        return false, string.format("等級不足%d級", tbDef.nMinPlayerLevel);
    end

    local tbGameFormat = self:GetGameFormat();
    if not tbGameFormat then
        return false, "華山論劍賽制尚未開啟!";
    end

    return true, "";
end

function HuaShanLunJian:CheckPlayerCreateFightTeam(pPlayer, szTeamName)
    local bRet, szMsg = self:CheckPlayerFightTeamPeriod(pPlayer);
    if not bRet then
        return false, szMsg;
    end    

    local nFightTeamID = self:GetPlayerFightTeam(pPlayer);
    if nFightTeamID > 0 then
        return false, "已經創建戰隊";
    end

    if Lib:IsEmptyStr(szTeamName) then
        return false, "請輸入名字";
    end    

    local nFindTeamID = self:GetFightTeamIDByName(szTeamName);
    if nFindTeamID then
        return false, "戰隊的名稱已經存在！";
    end

    local nCreateTime = pPlayer.GetUserValue(tbDef.nSaveGroupID, tbDef.nSaveFightTeamTime);
    local nPassTime = GetTime() - nCreateTime;
    if nPassTime < tbDef.nHSLJCrateLimitTime then
        return false, string.format("%s後才能創建", Lib:TimeDesc(tbDef.nHSLJCrateLimitTime - nPassTime)); 
    end    

    local bRet1, szMsg1 = self:CheckFightTeamName(szTeamName);
    if not bRet1 then
        return false, szMsg1;
    end

    bRet = Map:CheckEnterOtherMap(pPlayer);
    if not bRet then
        return false, "非安全區不能操作";
    end

    local tbGameFormat = self:GetGameFormat();
    local nTeamId = pPlayer.dwTeamID;
    if nTeamId > 0 then
        local tbTeam = TeamMgr:GetTeamById(nTeamId)
        local nCaptainId = tbTeam:GetCaptainId();
        if nCaptainId ~= pPlayer.dwID then
            return false, "您不是隊長";
        end

        local tbMember     = tbTeam:GetMembers();
        local nCountMember = Lib:CountTB(tbMember);
        if nCountMember > tbGameFormat.nFightTeamCount then
            return false, string.format("最多%s個人參加", tbGameFormat.nFightTeamCount);
        end

        for _, nPlayerID in pairs(tbMember) do
            local bRet2, szMsg2 = self:CheckJoinTeamMember(nPlayerID);
            if not bRet2 then
                return false, szMsg2;
            end    
        end        
    end

    local tbCanSava = self:GetCanFightTeamSava();
    if not tbCanSava then
        return false, "創建戰隊已滿！！";
    end   

    return true, "";
end

function HuaShanLunJian:PlayerCreateFightTeam(nRequestPlayerID, szTeamName, bForce)
    local pPlayer = KPlayer.GetPlayerObjById(nRequestPlayerID);
    if not pPlayer then
        Log("Error HuaShanLunJian PlayerCreateFightTeam Not Player", nRequestPlayerID, szTeamName);
        return;
    end

    local bRet, szMsg = self:CheckPlayerCreateFightTeam(pPlayer, szTeamName);
    if not bRet then
        pPlayer.CenterMsg(szMsg, true);
        return;
    end

    local tbGameFormat = self:GetGameFormat();
    local tbPlayers = {};
    local nTeamId = pPlayer.dwTeamID;
    if nTeamId > 0 then
        local tbTeam = TeamMgr:GetTeamById(nTeamId)
        local tbMember = tbTeam:GetMembers();
        for _, nPlayerID in pairs(tbMember) do
            tbPlayers[nPlayerID] = nPlayerID;
        end   
    else
        tbPlayers[pPlayer.dwID] = pPlayer.dwID;
    end

    if not bForce then
        local szMsg = string.format("你要創建戰隊：[FFFE0D]%s[-]嗎？", szTeamName);

        for _, nPlayerID in pairs(tbPlayers) do
            local pMember = KPlayer.GetPlayerObjById(nPlayerID);
            szMsg = szMsg .. string.format("\n%s %s級%s", pMember.szName, pMember.nLevel, Faction:GetName(pMember.nFaction));
        end

        pPlayer.MsgBox(szMsg, {{"確認", self.PlayerCreateFightTeam, self, pPlayer.dwID, szTeamName, true}, {"取消"}});
        return;
    end 

    local nFightTeamID = self:CreateFightTeam(szTeamName, tbPlayers);

    for _, nPlayerID in pairs(tbPlayers) do
        local pMember = KPlayer.GetPlayerObjById(nPlayerID);
        pMember.CenterMsg(string.format("創建%s戰隊成功！", szTeamName), true);
    end

    pPlayer.SetUserValue(tbDef.nSaveGroupID, tbDef.nSaveFightTeamTime, GetTime());
    pPlayer.CallClientScript("Player:ServerSyncData", "HSLJCreateFightTeam");
    self:RequestFightTeamInfo(pPlayer);
    Log("HuaShanLunJian PlayerCreateFightTeam", szTeamName, pPlayer.dwID, nFightTeamID);  
end

function HuaShanLunJian:CreateFightTeam(szTeamName, tbPlayers)
    local nHaveTeamID = self:GetFightTeamIDByName(szTeamName);
    if nHaveTeamID then
        Log("Error HuaShanLunJian CreateFightTeam", szTeamName);
        return 0;
    end

    local tbSave = self:GetCanFightTeamSava();
    tbSave.nCount = tbSave.nCount + 1;

    local nFightTeamID  = tbSave.nCount * tbDef.nMaxFightTeamVer + tbSave.nVer;
    local tbTeamSave = 
    {
        [tbDef.nTeamTypeName] = szTeamName;
        [tbDef.nTeamTypePlayer] = {};
        [tbDef.nTeamTypeValue] = 0;
        [tbDef.nTeamTypeTime] = 0;
    }; 

    tbSave.tbAllTeam[nFightTeamID] = tbTeamSave;

    local tbNotSave = self:GetFightTeamNotSaveData();
    tbNotSave.tbAllFightTeamName[szTeamName] = nFightTeamID;

    self:AddFightTeamMembers(nFightTeamID, tbPlayers);
    Log("HuaShanLunJian CreateFightTeam", szTeamName, nFightTeamID);
    return nFightTeamID;
end

function HuaShanLunJian:AddFightTeamMembers(nFightTeamID, tbPlayers)
    local tbFightTeam = self:GetFightTeamByID(nFightTeamID);
    if not tbFightTeam then
        Log("Error HuaShanLunJian AddFightTeamMembers", nFightTeamID);
        return;
    end    

    for _, nPlayerID in pairs(tbPlayers) do
        local pPlayer = KPlayer.GetPlayerObjById(nPlayerID);
        local nMemberTeamID = self:GetPlayerFightTeam(pPlayer);
        if nMemberTeamID > 0 then
            local tbMemberTeam = self:GetFightTeamByID(nMemberTeamID);
            if tbMemberTeam then
                tbMemberTeam:RemovePlayer(pPlayer.dwID);
            end 

            Log("Error HuaShanLunJian AddFightTeamMembers Have nFightTeamID", nFightTeamID, nMemberTeamID, nPlayerID);    
        end
        
        --pPlayer.SetUserValue(tbDef.nSaveGroupID, tbDef.nSaveFightTeamID, nFightTeamID);
        tbFightTeam:AddPlayerID(nPlayerID);
        Log("HuaShanLunJian AddFightTeamMembers", nFightTeamID, szTeamName, nPlayerID);
    end
end

function HuaShanLunJian:CheckJoinFightTeam(pPlayer)
    local bRet, szMsg = self:CheckPlayerFightTeamPeriod(pPlayer);
    if not bRet then
        return false, szMsg;
    end

    local nFightTeamID = self:GetPlayerFightTeam(pPlayer);
    if nFightTeamID <= 0 then
        return false, "未擁有戰隊";
    end

    local nTeamId = pPlayer.dwTeamID;
    if nTeamId <= 0 then 
        return false, "尚未組隊";
    end

    local tbTeam = TeamMgr:GetTeamById(nTeamId)
    local nCaptainId = tbTeam:GetCaptainId();
    if nCaptainId ~= pPlayer.dwID then
        return false, "您不是隊長";
    end

    local tbMember = tbTeam:GetMembers();
    local nCountMember = Lib:CountTB(tbMember);
    if nCountMember ~= tbDef.nFightTeamJoinMemebr then
        return false, "請兩人單獨組隊";
    end

    local tbFightTeam = self:GetFightTeamByID(nFightTeamID);
    local nCurTeamCount = tbFightTeam:GetPlayerCount();
    local nTotalCount = nCurTeamCount + nCountMember - 1;
    local tbGameFormat = self:GetGameFormat();
    if nTotalCount > tbGameFormat.nFightTeamCount then
        return false, string.format("本賽季的戰隊最多允許%s名隊員", tbGameFormat.nFightTeamCount);
    end

    bRet = Map:CheckEnterOtherMap(pPlayer);
    if not bRet then
        return false, "非安全區不能操作";
    end 

    local nJoinPlayerID = nil;
    for _, nPlayerID in pairs(tbMember) do
        if nPlayerID ~= pPlayer.dwID then
            local bRet1, szMsg1 = self:CheckJoinTeamMember(nPlayerID);
            if not bRet1 then
                return false, szMsg1;
            end

            nJoinPlayerID = nPlayerID;
        end     
    end

    if not nJoinPlayerID then
        return false, "沒有成員加入";
    end    

    return true, "", nJoinPlayerID;
end

function HuaShanLunJian:PlayerJoinFightTeam(nRequestPlayerID, bConfirm, bForce)
    local pPlayer = KPlayer.GetPlayerObjById(nRequestPlayerID);
    if not pPlayer then
        Log("Error HuaShanLunJian PlayerJoinFightTeam Not Player", nRequestPlayerID);
        return;
    end

    local bRet, szMsg, nJoinPlayerID = self:CheckJoinFightTeam(pPlayer);
    if not bRet then
        pPlayer.CenterMsg(szMsg, true);
        return;
    end

    local nFightTeamID = self:GetPlayerFightTeam(pPlayer);
    local tbFightTeam = self:GetFightTeamByID(nFightTeamID);
    local pJoinMember = KPlayer.GetPlayerObjById(nJoinPlayerID);
    if not bConfirm then
        local szMsg = string.format("你確定將「%s」組入的你的戰隊%s嗎？", pJoinMember.szName, tbFightTeam:GetName());
        pPlayer.MsgBox(szMsg, {{"確認", self.PlayerJoinFightTeam, self, nRequestPlayerID, true}, {"取消"}});
        return;
    end    

    if not bForce then
        local szMsg = string.format("%s邀請你加入「%s」戰隊\n成員：", pPlayer.szName, tbFightTeam:GetName());
        local szMsgMember = nil;
        local tbCurPlayers = tbFightTeam:GetAllPlayerID();
        for nPlayerID, _ in pairs(tbCurPlayers) do
            local tbPlayerInfo = self:GetPlayerInfoByID(nPlayerID);
            if not szMsgMember then
                szMsgMember = string.format("「%s」 %s級%s", tbPlayerInfo.szName, tbPlayerInfo.nLevel, Faction:GetName(tbPlayerInfo.nFaction));
            else
               szMsgMember = szMsgMember .. string.format(",「%s」 %s級%s", tbPlayerInfo.szName, tbPlayerInfo.nLevel, Faction:GetName(tbPlayerInfo.nFaction)); 
            end    
        end

        szMsg = szMsg .. szMsgMember;
        szMsg = szMsg .. "\n是否同意加入該戰隊！";
        pJoinMember.MsgBox(szMsg, {{"同意", self.PlayerJoinFightTeam, self, nRequestPlayerID, true, true}, {"婉拒"}});
        pPlayer.CenterMsg(string.format("正在邀請%s加入戰隊！", pJoinMember.szName), true);
        return;
    end

    local tbPlayers = {};
    tbPlayers[nJoinPlayerID] = nJoinPlayerID;
    self:AddFightTeamMembers(nFightTeamID, tbPlayers);
    pPlayer.CenterMsg(string.format("成功邀請「%s」加入戰隊！", pJoinMember.szName), true);
    pJoinMember.CenterMsg(string.format("您成功加入了%s戰隊！", tbFightTeam:GetName()), true);
    pPlayer.CallClientScript("Player:ServerSyncData", "HSLJJoinFightTeam");
    self:RequestFightTeamInfo(pPlayer);

    local tbOnLinePlayers = tbFightTeam:GetAllPlayerID();
    for nOnLinePlayerID, _ in pairs(tbOnLinePlayers) do
        if nOnLinePlayerID ~= pPlayer.dwID and nOnLinePlayerID ~= nJoinPlayerID then
            local pOnLinePlayer = KPlayer.GetPlayerObjById(nOnLinePlayerID);
            if pOnLinePlayer then
                pOnLinePlayer.Msg(string.format("「%s」加入了您的戰隊", pJoinMember.szName));
            end    
        end
    end

    Log("HuaShanLunJian PlayerJoinFightTeam", nRequestPlayerID, nFightTeamID);    
end

function HuaShanLunJian:CheckPlayerQuitFightTeam(pPlayer)
    local nFightTeamID = self:GetPlayerFightTeam(pPlayer);
    if nFightTeamID <= 0 then
        return false, "您沒有戰隊，何來退出？";
    end

    local tbFightTeam = self:GetFightTeamByID(nFightTeamID);
    if not tbFightTeam then
        return false, "系統出錯，戰隊不存在，請聯繫客服人員！";
    end    

    local bRet = Map:CheckEnterOtherMap(pPlayer);
    if not bRet then
        return false, "非安全區不能操作";
    end

    bRet = tbFightTeam:HavePlayerID(pPlayer.dwID);
    if not bRet then
        return false, "系統出錯，你不存在戰隊，請聯繫客服人員！";
    end

    local nJoinCount = tbFightTeam:GetJoinCount();
    if nJoinCount > 0 then
        return false, "您所在戰隊已有比賽成績，不能退出。"
    end    

    return true, "", nFightTeamID;
end

function HuaShanLunJian:PlayerQuitFightTeam(nRequestPlayerID, bConfirm)
    local pPlayer = KPlayer.GetPlayerObjById(nRequestPlayerID);
    if not pPlayer then
        Log("Error HuaShanLunJian PlayerQuitFightTeam", nRequestPlayerID);
        return;
    end

    local bRet, szMsg, nFightTeamID = self:CheckPlayerQuitFightTeam(pPlayer);
    if not bRet then
        pPlayer.CenterMsg(szMsg, true);
        return;
    end

    local tbFightTeam = self:GetFightTeamByID(nFightTeamID);
    if not bConfirm then
        local szMsg = string.format("您確定退出戰隊%s嗎？", tbFightTeam:GetName());
        pPlayer.MsgBox(szMsg, {{"確認", self.PlayerQuitFightTeam, self, nRequestPlayerID, true}, {"取消"}});
        return;
    end    

    --pPlayer.SetUserValue(tbDef.nSaveGroupID, tbDef.nSaveFightTeamID, 0);
    tbFightTeam:RemovePlayer(pPlayer.dwID);
    pPlayer.CenterMsg(string.format("您退出了%s戰隊！", tbFightTeam:GetName()), true);
    local nPlayerCount = tbFightTeam:GetPlayerCount();
    if nPlayerCount > 0 then
        local szContent = string.format("大俠，很遺憾的通知你，華山論劍戰隊成員%s離開了大家。請儘快找到新的俠士來一起戰鬥吧！", pPlayer.szName);
        local tbAllPlayer = tbFightTeam:GetAllPlayerID();
        for nPlayerID, _ in pairs(tbAllPlayer) do
            local tbMail = 
            {
                To = nPlayerID,
                Text = szContent;
            }
            Mail:SendSystemMail(tbMail);
        end    
    else
        self:RemoveFightTeam(nFightTeamID);
        pPlayer.CenterMsg("您所在的戰隊已經解散了！", true);
    end

    pPlayer.CallClientScript("Player:ServerSyncData", "HSLJQuitFightTeam");
    self:RequestFightTeamInfo(pPlayer);
    Log("HSLJ PlayerQuitFightTeam", pPlayer.dwID, nFightTeamID);
end

function HuaShanLunJian:CheckChangeFightTeamPlayerNum(pPlayer, tbPlayerNum)
    if type(tbPlayerNum) ~= "table" then
        return false, "操作的資料錯誤";
    end
        
    local nFightTeamID = self:GetPlayerFightTeam(pPlayer);
    if nFightTeamID <= 0 then
        return false, "您沒有戰隊不能操作";
    end

    local tbFightTeam = self:GetFightTeamByID(nFightTeamID);
    if not tbFightTeam then
        return false, "系統出錯，戰隊不存在，請聯繫客服人員！";
    end    

    -- local bRet = Map:CheckEnterOtherMap(pPlayer);
    -- if not bRet then
    --     return false, "非安全区不能操作";
    -- end

    local tbGameFormat = self:GetGameFormat();
    if tbGameFormat.szPKClass ~= "PlayDuel" then
        return false, "當前賽季不能操作";
    end 

    local nChangeCount = Lib:CountTB(tbPlayerNum);    
    local nTotalCount = tbFightTeam:GetPlayerCount();
    if nChangeCount ~= nTotalCount then
        return false, "請選擇更換的陣容";
    end

    local tbHaveNum = {};
    for nPlayerID, nNum in pairs(tbPlayerNum) do
        if not nPlayerID then
            return false, "操作的陣容資料錯誤!!";
        end    

        local bRet = tbFightTeam:HavePlayerID(nPlayerID);
        if not bRet then
            return false, "有玩家不在當前的戰隊";
        end

        if nNum <= 0 or nNum > nTotalCount then
            return false, "操作的陣容資料錯誤";
        end

        if tbHaveNum[nNum] then
            return false, "操作的陣容資料錯誤!";
        end    

        tbHaveNum[nNum] = 1;    
    end

    return true, "", tbFightTeam;    
end

function HuaShanLunJian:ChangeFightTeamPlayerNum(pPlayer, tbPlayerNum)
    local bRet, szMsg, tbFightTeam = self:CheckChangeFightTeamPlayerNum(pPlayer, tbPlayerNum);
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
            Log("HSLJ ChangeFightTeamPlayerNum", tbFightTeam:GetID(), nPlayerID, nNum);
        end    
    end

    local szChangeMsg = "";
    local nChangeCount = Lib:CountTB(tbCurPlayerNum);
    for nI = 1, nChangeCount do
        local nPlayerID = tbCurPlayerNum[nI];
        if nPlayerID then
            local tbPlayerInfo = self:GetPlayerInfoByID(nPlayerID);
            if tbPlayerInfo then
                if Lib:IsEmptyStr(szChangeMsg) then
                    szChangeMsg = string.format("%s號位為「%s」", nI, tbPlayerInfo.szName);
                else    
                    szChangeMsg = szChangeMsg..string.format("，%s號位為「%s」", nI, tbPlayerInfo.szName);
                end
            end    
        end    
    end    
    
    szChangeMsg = "華山論劍戰隊編號變更：" ..szChangeMsg;
    pPlayer.CenterMsg("改變陣容成功！", true);

    local tbAllPlayerID = tbFightTeam:GetAllPlayerID();
    for nPlayerID, _ in pairs(tbAllPlayerID) do
        local pPlayer = KPlayer.GetPlayerObjById(nPlayerID);
        if pPlayer then
            pPlayer.Msg(szChangeMsg);
        end    
    end

    HuaShanLunJian:RequestFightTeamInfo(pPlayer);
    Log("HSLJ ChangeFightTeamPlayerNum Player", pPlayer.dwID, tbFightTeam:GetID());
end  
