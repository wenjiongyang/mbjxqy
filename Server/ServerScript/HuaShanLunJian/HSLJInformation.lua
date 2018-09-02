
Require("CommonScript/HuaShanLunJian/LunJianDef.lua");
local tbDef             = HuaShanLunJian.tbDef;
local tbFinalsDef       = tbDef.tbFinalsGame;
local tbGuessingDef     = tbDef.tbChampionGuessing;

function HuaShanLunJian:CheckOpenHSLJMail()
    local bRet = self:CheckUpdateGameFormat();
    if not bRet then
        return false;
    end

    bRet = self:CheckCanOpenHSLJ();
    if not bRet then
        return false;
    end    

    local tbSaveData = self:GetLunJianSaveData();
    if tbSaveData.nPlayState ~= tbDef.nPlayStateNone then
        return false;
    end

    return true;
end

function HuaShanLunJian:OpenHSLJMail()
    self:UpdateGameFormat();
    local bRet = self:CheckOpenHSLJMail();
    if not bRet then
        return;
    end    

    local tbSaveData = self:GetLunJianSaveData();
    tbSaveData.nPlayState = tbDef.nPlayStateMail;
    local tbFormat = self:GetGameFormat();
    local szContent = tbFormat.szOpenHSLJMail;
    local tbMail = 
    {
        Title = "華山論劍",
        Text = szContent or "",
        LevelLimit = tbDef.nMinPlayerLevel,
    };

    Mail:SendGlobalSystemMail(tbMail)
    --NewInformation:RemoveInfomation("HSLJChampionship");
    Log("HuaShanLunJian OpenHSLJMail");
end


function HuaShanLunJian:SendChampNewInformation(nFightTeamID)
    local tbNewInformation = {};
    
    if nFightTeamID > 0 then
        local tbFightTeam = self:GetFightTeamByID(nFightTeamID);
        if tbFightTeam then
            tbNewInformation = self:GetFightTeamShowInfo(nFightTeamID);
        end   
    end
        
    NewInformation:AddInfomation("HSLJChampionship", GetTime() + tbDef.nChampionshipNewTime, tbNewInformation);
    NewInformation:RemoveInfomation("HSLJEightRank");
    Log("HuaShanLunJian SendChampNewInformation", nFightTeamID);
end