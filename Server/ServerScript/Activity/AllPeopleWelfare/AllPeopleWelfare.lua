
local tbAct = Activity:GetClass("AllPeopleWelfare");

tbAct.tbTimerTrigger = 
{
};

tbAct.tbTrigger = 
{
    Init = {},
    Start = {},
    End = {},
};

tbAct.tbNewInfo_Old = 
{
    szTitle = "迎戰新服全民福利";
    szContent =
[[
      武林盟主特令，俠士進駐4月12日0點至5月1日0點之間開放的伺服器，可獲得“閒庭雅居”資料片獨享增益福利。助力眾俠士早日獨步武林！（增益福利將持續到開啟59級等級上限）
      福利一：[ffcc00]共戰[-]。野外修煉打怪獲得的經驗增加10%。
      福利二：[ffcc00]財運[-]。通過搖錢樹、每日目標、隨機地宮、野外修煉、商會任務獲得的銀兩增加10%。
      福利三：[ffcc00]天工[-]。通過幫派捐獻、武神殿、懲惡任務、幫派烤火答題、武林盟主獲得的貢獻增加10%。
]]
}

tbAct.tbNewInfo = 
{
    szTitle = "迎戰新服全民福利";
    szContent =
[[
      武林盟主特令，俠士進駐5月1日4點至5月16日0點之間開放的伺服器，可獲得5月勞動節獨享增益福利。助力眾俠士早日獨步武林！（增益福利將持續到開啟59級等級上限）
      福利一：[ffcc00]稱號[-]。新進玩家可獲得新服專屬限定稱號。
      福利二：[ffcc00]共戰[-]。野外修煉打怪獲得的經驗增加10%。
      福利三：[ffcc00]財運[-]。通過搖錢樹、每日目標、隨機地宮、野外修煉、商會任務獲得的銀兩增加10%。
      福利四：[ffcc00]天工[-]。通過幫派捐獻、武神殿、懲惡任務、幫派烤火答題、武林盟主獲得的貢獻增加10%。
]]
}

tbAct.tbAddBuff = 
{
    {nBuffID = 2301, nLevel = 1 },
    {nBuffID = 2302, nLevel = 1 },
    {nBuffID = 2303, nLevel = 1 },
};

function tbAct:OnTrigger(szTrigger)
    if szTrigger == "Init" then
        self:SendNew();
    elseif szTrigger == "Start" then
        Activity:RegisterPlayerEvent(self, "Act_OnPlayerLogin", "OnPlayerLogin");
    end

    Log("AllPeopleWelfare OnTrigger:", szTrigger)
end

function tbAct:OnPlayerLogin()
    local pPlayerNpc = me.GetNpc();
    if not pPlayerNpc then
        return;
    end

    local _, nEndTime = self:GetOpenTimeInfo();
    local nCurTime = GetTime();
    if nCurTime >= (nEndTime - 10) then
        return;
    end

    for _, tbBuffInfo in pairs(self.tbAddBuff) do
        local tbState  = pPlayerNpc.GetSkillState(tbBuffInfo.nBuffID);
        if not tbState then
            pPlayerNpc.AddSkillState(tbBuffInfo.nBuffID, tbBuffInfo.nLevel, FightSkill.STATE_TIME_TYPE.state_time_truetime, nEndTime, 1, 1);
        end    
    end   
end

function tbAct:SendNew()
    local tbNewInfo = self.tbNewInfo;
    if not tbNewInfo then
        return;
    end
    
    if tonumber(os.date("%Y%m%d", GetTime())) < 20170501 then	-- 这个时间之前用老的最新消息
    	tbNewInfo = self.tbNewInfo_Old or tbNewInfo;
    end

    local _, nEndTime = self:GetOpenTimeInfo();
    NewInformation:AddInfomation("AllPeopleWelfare_NewInfo", nEndTime, {tbNewInfo.szContent}, {szTitle = tbNewInfo.szTitle, nReqLevel = 1})
end