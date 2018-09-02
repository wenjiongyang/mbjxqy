
Require("CommonScript/HeroChallenge/HeroChallengeDef.lua");
local tbDef = HeroChallenge.tbDefInfo;


function HeroChallenge:LoadSetting()
    self.tbFloorSetting     = {};
    self.tbExtAllAwardSetting = {};
    self.nMaxRankFloor      = 0;

    local tbFileData = Lib:LoadTabFile("Setting/HeroChallenge/ChallengeFloor.tab", {Floor = 1, MinRank = 1, MaxRank = 1, IsNpc = 1});
    for _, tbInfo in pairs(tbFileData) do
        self.tbFloorSetting[tbInfo.Floor] = tbInfo;
        tbInfo.tbAllAward = Lib:GetAwardFromString(tbInfo.Awards);
        if tbInfo.Floor > self.nMaxRankFloor then
            self.nMaxRankFloor = tbInfo.Floor;
        end  
    end

    tbFileData = Lib:LoadTabFile("Setting/HeroChallenge/ExtRateAward.tab", {MinLevel = 1, MaxLevel = 1});
    for _, tbInfo in pairs(tbFileData) do
        tbInfo.tbAllExtAward = {}; 
        for nI = 1, 10 do
            if not Lib:IsEmptyStr(tbInfo["ExtAward"..nI]) and not Lib:IsEmptyStr(tbInfo["ExtAwardRate"..nI]) then
                local tbExtAward = {};
                tbExtAward.tbAward = Lib:GetAwardFromString(tbInfo["ExtAward"..nI]);
                tbExtAward.nRate = tonumber(tbInfo["ExtAwardRate"..nI]);
                tbExtAward.nIsOne = 0;
                if not Lib:IsEmptyStr(tbInfo["IsOneExtAward"..nI]) then
                    tbExtAward.nIsOne = tonumber(tbInfo["IsOneExtAward"..nI]);
                end

                table.insert(tbInfo.tbAllExtAward, tbExtAward);    
            end    
        end
        table.insert(self.tbExtAllAwardSetting, tbInfo);   
    end    
end

HeroChallenge:LoadSetting();


function HeroChallenge:GetFloorInfo(nFloor)
    return self.tbFloorSetting[nFloor];
end

function HeroChallenge:GetExtAwardRate(nLevel)
    for _, tbInfo in pairs(self.tbExtAllAwardSetting) do
        if tbInfo.MinLevel <= nLevel and nLevel <= tbInfo.MaxLevel then
            return tbInfo;
        end    
    end     
end

function HeroChallenge:GetRankFloor(nRank)
    for nFloor, tbFloorInfo in pairs(self.tbFloorSetting) do
        if tbFloorInfo.MinRank <= nRank and nRank <= tbFloorInfo.MaxRank then
            return nFloor;
        end    
    end

end

function HeroChallenge:CheckChallengeMaster(pPlayer, bNotCheckDoing)
    if tbDef.nMinPlayerLevel > pPlayer.nLevel then
        return false, string.format("參加等級不足%s級", tbDef.nMinPlayerLevel);
    end

    if GetTimeFrameState(tbDef.szOpenTimeFrame) ~= 1 then
        return false, "尚未開啟！";
    end

    local nCount = DegreeCtrl:GetDegree(pPlayer, tbDef.szHeroChallengeCount);
    if nCount <= 0 then
        return false, string.format("目前挑戰次數%s", nCount);
    end

    local nCurFloor = self:GetPlayerChallengeFloor(pPlayer);
    local nChallengeFloor = nCurFloor + 1;
    local tbChallenge = self:GetFloorInfo(nChallengeFloor);
    if not tbChallenge then
        return false, "不可以挑戰目前層數";
    end       

    local pPlayerNpc = pPlayer.GetNpc();
    if not bNotCheckDoing then
        local nResult = pPlayerNpc.CanChangeDoing(Npc.Doing.skill);
        if nResult == 0 then
            return false, "目前狀態不能參加";
        end
    end
        
    return true, "", tbChallenge, nChallengeID, nChallengeType;    
end

function HeroChallenge:CheckChallengeAward(pPlayer, nFloor)
    local nAwardFlag = self:GetPlayerAwardFlag(pPlayer);
    local nFloorFlag = KLib.BitOperate(1, "<<", nFloor);
    local nRet = KLib.BitOperate(nAwardFlag, "&", nFloorFlag);
    if nRet ~= 0 then
        return false, "已領取獎勵";
    end

    local nCurFloor = self:GetPlayerChallengeFloor(pPlayer);
    if nFloor > nCurFloor then
        return false, "不可以領取獎勵";
    end

    local tbChallenge = self:GetFloorInfo(nFloor);
    if not tbChallenge then
        return false, "沒有可以領取的獎勵";
    end

    if nFloor <= 0 then
        return false, "不可以領取獎勵!!";
    end    

    return true, "", tbChallenge;    
end