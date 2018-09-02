
local ACT_CLASS = "HouseDefend";
local tbActivity = Activity:GetClass(ACT_CLASS);

tbActivity.tbTimerTrigger = 
{
}

tbActivity.tbTrigger = 
{
	Init = 
	{
	},
    Start = 
    {
    },
    End = 
    {
    },
}

tbActivity.tbDailyAward =
{
    [1] = {{"Item", 5420, 1}},
    [2] = {{"Item", 5420, 1}},
    [3] = {{"Item", 5420, 1}},
    [4] = {{"Item", 5420, 1}},
    [5] = {{"Item", 5421, 1}},
};
tbActivity.tbJoinAward = 
{   
    {"Item", 4818, 1},
};
tbActivity.tbFubenAward =
{
    {"Item", 5430, 1},
};

tbActivity.MIN_LEVEL = 60;
tbActivity.TIME_CLEAR = 4 * 3600;
tbActivity.USERGROUP = 137;
tbActivity.USERKEY_FUBENTIME = 1; 
tbActivity.USERKEY_ACT_TIME = 2;
tbActivity.USERKEY_AWARD_COUNT = 3;
tbActivity.nFubenMapTemplateId = 4007;
tbActivity.MAX_AWARD_COUNT = 10;

tbActivity.tbHouseFuben = tbActivity.tbHouseFuben or {};

function tbActivity:OnTrigger(szTrigger)
    if szTrigger == "Start" then
        Activity:RegisterPlayerEvent(self, "Act_EverydayTarget_Award", "OnGainEverydayAward");
        Activity:RegisterPlayerEvent(self, "Act_HouseDefend_OpenFuben", "OpenFuben");
        Activity:RegisterPlayerEvent(self, "Act_HouseDefend_EnterFuben", "EnterFuben");
        Activity:RegisterPlayerEvent(self, "Act_HouseDefend_FubenFinished", "OnFubenFinished");

        Activity:RegisterGlobalEvent(self, "Act_HouseDefend_FubenClose", "OnFubenClose");

        self:SendNews();
    end
end

function tbActivity:SendNews()
    local _, nEndTime = self:GetOpenTimeInfo();
    NewInformation:AddInfomation("ActHouseDefend", nEndTime, 
        {
        [[活動時間：[FFFE0D]2017年7月13日04：00-2017年7月24日3：59[-]\n\n[FFFE0D]新穎小築，真情常駐[-]\n    諸位俠士，近日據聞楊大俠少俠與真兒女俠又再攜手共闖江湖，只是兩人嫉惡如仇，行俠仗義之際未免得罪不少武林惡徒，這些惡黨若是光明正大前來挑戰，兩位俠侶自是不懼，但偏生這些卑鄙之人，恐怕會使用一些下三濫的伎倆。故武林盟特邀請諸位俠士，助楊大俠與趙女俠一臂之力。參與方式如下：\n\n    活動期間，完成[FFFE0D]每日目標[-]即可獲得合成材料，每天完成[FFFE0D]20、40、60、80[-]時，均將獲得 [aa62fc][url=openwnd:灰暗的兔子燈罩, ItemTips, "Item", nil, 5420][-]，完成[FFFE0D]100點[-]時將獲得 [aa62fc][url=openwnd:搖曳的兔子燈芯, ItemTips, "Item", nil, 5421][-]，集齊後有機會獲得[ff8f06][url=openwnd:邀請函·楊大俠, ItemTips, "Item", nil, 5423][-] [ff8f06][url=openwnd:邀請函·真兒, ItemTips, "Item", nil, 5424][-]或是一份[FFFE0D]隨機獎勵[-]。\n\n    若俠士幸運得到邀請函，又擁有家園，可邀楊大俠少俠/真兒女俠來自己的家園做客，已加入幫派的俠士，還可與他們對話開啟新穎小築奪回戰，與[FFFE0D]幫派成員[-]一同説明他們奪回家園，規則如下：\n\n1、新穎小築奪回戰開啟後，[FFFE0D]開啟者[-]將獲得一份獎勵，所在幫派的成員均可進入挑戰，擊敗最終頭目後[FFFE0D]所有地圖內的俠士均將獲得一份獎勵[-]，活動期間，每個俠士最多只能獲得[FFFE0D]10次獎勵[-]，但仍可前往幫助其他俠士奪回新穎小築\n2、開啟新穎小築奪回戰後將發送幫派公告，[FFFE0D]入口持續1小時後關閉[-]，一定要確定有足夠的幫派成員與你一同挑戰再開啟！\n3、邀請函有效期至次日[FFFE0D]淩晨4點[-]，可千萬不要忘記使用喔\n4、楊大俠少俠/真兒女俠也將在次日淩晨4日離開，別忘記及時開啟奪回戰\n5、俠士開啟爭奪戰後，若更換幫派，新幫派的成員無法協助你進行活動]]
        }, 
        {
            szTitle = "新穎小築情長駐", 
            nReqLevel = 60
        });
end

function tbActivity:OnGainEverydayAward(pPlayer, nAwardIdx)
    if pPlayer.nLevel < tbActivity.MIN_LEVEL then
        return;
    end

    local tbAward = tbActivity.tbDailyAward[nAwardIdx];
    if not tbAward then
        return;
    end

    local nEndTime = Activity:GetActEndTime(self.szKeyName);
    for _, tbInfo in ipairs(tbAward) do
        if tbInfo[1] == "Item" then
            tbInfo[4] = nEndTime;
        end
    end

    pPlayer.SendAward(tbAward, true, true, Env.LogWay_HouseDefend);

    Log("[HouseDefend] player gain daily award:", pPlayer.dwID, pPlayer.szName, nAwardIdx);
end

function tbActivity:CanOpenFuben(pPlayer)
    if not Env:CheckSystemSwitch(pPlayer, Env.SW_HouseDefend) then
        return false, "活動暫時關閉，請稍候再試";
    end

    if not House:IsInOwnHouse(pPlayer) then
        return false, "只能在自己家園開啟副本哦";
    end

    if pPlayer.nLevel < tbActivity.MIN_LEVEL then
        return false, string.format("等級不足%d級", tbActivity.MIN_LEVEL);
    end

    local nOpenFubenTime = pPlayer.GetUserValue(tbActivity.USERGROUP, tbActivity.USERKEY_FUBENTIME);
    if nOpenFubenTime ~= 0 then
        local nCurDay = Lib:GetLocalDay(GetTime() - tbActivity.TIME_CLEAR);
        local nLastDay = Lib:GetLocalDay(nOpenFubenTime - tbActivity.TIME_CLEAR);
        if nCurDay == nLastDay then
            return false, "你已經開啟過副本";
        end
    end

    if pPlayer.dwKinId == 0 then
        return false, "你還沒有幫派！先去加入一個幫派吧";
    end

    local dwPlayerId = pPlayer.dwID;
    if tbActivity.tbHouseFuben[dwPlayerId] then
        return false, "你還有副本沒完成！";
    end

    return true;
end

function tbActivity:OpenFuben(pPlayer, bConfirm)
    local bRet, szMsg = self:CanOpenFuben(pPlayer);
    if not bRet then
        pPlayer.CenterMsg(szMsg);
        return;
    end

    if not bConfirm then
        pPlayer.MsgBox("新穎小築奪回戰開啟後[FFFE0D]持續1小時[-]，其中賊匪眾多，請確保有足夠的幫派成員與你一同參與，是否確定開啟？", {{"確定", function ()
            self:OpenFuben(me, true);
            end}, {"取消"}});
        return;
    end

    pPlayer.SetUserValue(tbActivity.USERGROUP, tbActivity.USERKEY_FUBENTIME, GetTime());
    pPlayer.SendAward(tbActivity.tbJoinAward, true, false, Env.LogWay_HouseDefend);

    local dwPlayerId = pPlayer.dwID;
    local dwKinId = pPlayer.dwKinId;
    local fnSuccessCallback = function (nMapId)
        assert(not tbActivity.tbHouseFuben[dwPlayerId], "repeated fuben:" .. dwPlayerId);
        tbActivity.tbHouseFuben[dwPlayerId] = { nMapId = nMapId, dwKinId = dwKinId };

        local pPlayer = KPlayer.GetPlayerObjById(dwPlayerId);
        if pPlayer then
            pPlayer.CenterMsg("開啟新穎小築奪回戰成功！", 1);
        end

        local szMsg = string.format("「%s」開啟新穎小築奪回戰啦，奪回後人人有獎，諸位幫派兄弟，快去助他一臂之力！", pPlayer.szName);
        ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.Kin, szMsg, dwKinId);
    end

    local fnFailedCallback = function ()
        Log("[ERROR][HouseDefend] failed to create fuben: ", dwPlayerId);
    end

    Fuben:ApplyFuben(dwPlayerId, tbActivity.nFubenMapTemplateId, fnSuccessCallback, fnFailedCallback, dwPlayerId);

    Log("[HouseDefend] fuben open: player", dwPlayerId, "kin", dwKinId, "map", nMapId);
end

function tbActivity:OnFubenClose(nMapId, dwOwnerId)
    local tbFuben = tbActivity.tbHouseFuben[dwOwnerId];
    if not tbFuben then
        return;
    end
    
    if tbFuben.nMapId ~= nMapId then
        Log("[ERROR][HouseDefend] unknown fuben: ", nMapId, dwOwnerId);
        return;
    end

    tbActivity.tbHouseFuben[dwOwnerId] = nil;

    Log("[HouseDefend] fuben close: ", nMapId, dwOwnerId);
end

function tbActivity:CanEnterFuben(pPlayer, dwOwnerId)
    if not Env:CheckSystemSwitch(pPlayer, Env.SW_HouseDefend) then
        return false, "活動暫時關閉，請稍候再試";
    end

    local tbFuben = tbActivity.tbHouseFuben[dwOwnerId];
    if not tbFuben then
        return false, "還沒有開啟副本";
    end

    if pPlayer.dwID ~= dwOwnerId and pPlayer.dwKinId ~= tbFuben.dwKinId then
        return false, "你不符合條件進入";
    end

    return true, tbFuben.nMapId;
end

function tbActivity:EnterFuben(pPlayer, dwOwnerId)
    local bRet, result = self:CanEnterFuben(pPlayer, dwOwnerId);
    if not bRet then
        pPlayer.CenterMsg(result);
        return;
    end
    pPlayer.SetEntryPoint();
    pPlayer.SwitchMap(result, 0, 0);
end

function tbActivity:GetAwardCount(pPlayer)
    local nLastActTime = pPlayer.GetUserValue(tbActivity.USERGROUP, tbActivity.USERKEY_ACT_TIME);
    local nCurActTime = Activity:GetActBeginTime(self.szKeyName);
    if nLastActTime < nCurActTime then
        pPlayer.SetUserValue(tbActivity.USERGROUP, tbActivity.USERKEY_ACT_TIME, nCurActTime);
        pPlayer.SetUserValue(tbActivity.USERGROUP, tbActivity.USERKEY_AWARD_COUNT, 0);
    end
    return pPlayer.GetUserValue(tbActivity.USERGROUP, tbActivity.USERKEY_AWARD_COUNT);
end

function tbActivity:OnFubenFinished(pPlayer, nMapId)
    local nCurAwardCount = self:GetAwardCount(pPlayer);
    if nCurAwardCount >= tbActivity.MAX_AWARD_COUNT then
        Npc:SetPlayerNoDropMap(pPlayer, nMapId);
        return;
    end

    pPlayer.SetUserValue(tbActivity.USERGROUP, tbActivity.USERKEY_AWARD_COUNT, nCurAwardCount + 1);
    pPlayer.SendAward(tbActivity.tbFubenAward, true, true, Env.LogWay_HouseDefend);
    
    Log("[HouseDefend] player gain fuben award: ", pPlayer.dwID, pPlayer.szName);
end