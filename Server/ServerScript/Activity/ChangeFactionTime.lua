
local tbAct = Activity:GetClass("ChangeFactionTime");
local tbDef = ChangeFaction.tbDef;

tbAct.tbTimerTrigger = 
{
};
tbAct.tbTrigger = 
{
    Init = {},
    Start = {},
    End = {},
};

function tbAct:OnTrigger(szTrigger)
    if szTrigger == "Start" then
        tbDef.nActUseFactionLingCD = 1 * 24 * 60 * 60; --使用门派令的时间

        local tbAllPlayer = KPlayer.GetAllPlayer();
        for _, pPlayer in pairs(tbAllPlayer) do
            self:PlayerChangeFactionTime(pPlayer)
        end

        Activity:RegisterPlayerEvent(self, "Act_OnPlayerLogin", "OnPlayerLogin");
    elseif szTrigger == "End" then
        tbDef.nActUseFactionLingCD = nil; --使用门派令的时间   
    end

    Log("ChangeFactionTime OnTrigger:", szTrigger)
end

function tbAct:OnPlayerLogin()
    self:PlayerChangeFactionTime(me);
end

function tbAct:PlayerChangeFactionTime(pPlayer)
    local nLastTime = pPlayer.GetUserValue(tbDef.nSaveGroup, tbDef.nSaveUseCD);
    local nRetTime = nLastTime - GetTime();
    local nCDTime = ChangeFaction:GetUseFactionCD();
    if nRetTime > nCDTime + 10 then
        pPlayer.SetUserValue(tbDef.nSaveGroup, tbDef.nSaveUseCD, 0);
        Log("ChangeFactionTime PlayerChangeFactionTime", pPlayer.dwID, nRetTime);
    end
end

