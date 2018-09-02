
Require("CommonScript/ChangeFaction/ChangeFactionDef.lua");

ChangeFaction.tbAllApplyPlayer = ChangeFaction.tbAllApplyPlayer or {};
ChangeFaction.tbAllPlayerInfo = ChangeFaction.tbAllPlayerInfo or {};

local tbDef = ChangeFaction.tbDef;
local tbMap = Map:GetClass(tbDef.nMapTID);

function tbMap:OnCreate(nMapId)
    ChangeFaction:OnCreate(nMapId);
end

function tbMap:OnDestroy(nMapId)
    ChangeFaction:OnDestroy(nMapId);
end

function tbMap:OnEnter(nMapId)
    ChangeFaction:OnEnter(nMapId);
end

function tbMap:OnLeave(nMapId)
    ChangeFaction:OnLeave(nMapId);
end


function ChangeFaction:CheckApplyEnterMap(pPlayer)
    local nLing = pPlayer.GetItemCountInAllPos(tbDef.nChangeFactionLing);
    if nLing <= 0 then
        local szName = KItem.GetItemShowInfo(tbDef.nChangeFactionLing);
        return false, string.format("身上不足%s", szName);
    end

    local bRet = Map:CheckEnterOtherMap(pPlayer);
    if not bRet then
        return false, "不在安全區，不能進入";
    end

    if pPlayer.nMapTemplateId == tbDef.nMapTID then
        return false, "已經在地圖！";
    end

    if tbDef.nMinChangeLevel > pPlayer.nLevel then
        return false, string.format("等級不足%s級", tbDef.nMinChangeLevel);
    end

    local nLastTime = pPlayer.GetUserValue(tbDef.nSaveGroup, tbDef.nSaveUseCD);
    local nRetTime = nLastTime - GetTime();
    if nRetTime > 0 then
        return false, string.format("%s後才可以使用", Lib:TimeDesc2(nRetTime));
    end

    return true, "";
end

function ChangeFaction:ApplyEnterMap(pPlayer)
    local bRet, szMsg = self:CheckApplyEnterMap(pPlayer);
    if not bRet then
        pPlayer.CenterMsg(szMsg, true);
        return;
    end

    local nTime = GetTime() + ChangeFaction:GetUseFactionCD();
    pPlayer.SetUserValue(tbDef.nSaveGroup, tbDef.nSaveUseCD, nTime);
    local nConsumeCount = pPlayer.ConsumeItemInAllPos(tbDef.nChangeFactionLing, 1, Env.LogWay_ChangeFaction);
    if nConsumeCount <= 0 then
        Log("Error ChangeFaction OnEnter", pPlayer.dwID, nConsumeCount);
        return;
    end

    pPlayer.SetEntryPoint();
    pPlayer.SwitchMap(tbDef.nMapTID, tbDef.tbEnterPos[1], tbDef.tbEnterPos[2]);
    pPlayer.SetUserValue(tbDef.nSaveGroup, tbDef.nSaveEnterFaction, pPlayer.nFaction);
    pPlayer.CallClientScript("Ui:CloseWindow", "ItemBox");
    Log("ChangeFaction ApplyEnterMap", pPlayer.dwID);
end

function ChangeFaction:CheckPlayerChangeFaction(pPlayer, nChangeFaction)
    if not Faction.tbFactionInfo[nChangeFaction] then
        return false, "沒有開放當前的門派";
    end

    if pPlayer.nFaction == nChangeFaction then
        return false, "請選擇不同的門派";
    end

    if pPlayer.nMapTemplateId ~= tbDef.nMapTID then
        return false, "當前地圖不能轉門派";
    end

    return true, "";
end

function ChangeFaction:PlayerChangeFaction(pPlayer, nChangeFaction)
    local bRet, szMsg = self:CheckPlayerChangeFaction(pPlayer, nChangeFaction);
    if not bRet then
        pPlayer.CenterMsg(szMsg, true);
        return;
    end

    local nOrgFaction = pPlayer.nFaction;
    local nRet = pPlayer.ChangeFaction(nChangeFaction);
    if nRet ~= 1 then
        Log("Error PlayerChangeFaction", pPlayer.dwID, nChangeFaction, pPlayer.nFaction);
        return;
    end

    pPlayer.SetUserValue(FightSkill.nSaveSkillPointGroup, FightSkill.nSaveCostSkillPoint, 0);
    pPlayer.SetPortrait(pPlayer.nFaction);

    local szKey = string.format("FightPower_%s", nOrgFaction);
    local pRank = KRank.GetRankBoard(szKey)
    if pRank then
        local tbRankInfo = pRank.GetRankInfoByID(pPlayer.dwID);
        if tbRankInfo then
            pRank.RemoveByID(pPlayer.dwID);
        end
    end

    FightPower:ChangeFightPower("Skill", pPlayer);
    local tbBook = Item:GetClass("SkillBook");
    --tbBook:UnuseAllSkillBook(pPlayer);
    tbBook:ChangeFactionBook(pPlayer, nOrgFaction, nChangeFaction);

    local nLightID = pPlayer.GetUserValue(OpenLight.nSaveGroupID, OpenLight.nSaveLightID);
    if nLightID > 0 then
        OpenLight:ServerUpdateOpenLight(pPlayer);
    end
    
    self:ClearFactionChannel(pPlayer, nOrgFaction);
    pPlayer.TLog("ChangeFactionFlow", pPlayer.nLevel, nOrgFaction, pPlayer.nFaction);
    Log("ChangeFaction PlayerChangeFaction", pPlayer.dwID, nOrgFaction, pPlayer.nFaction, nChangeFaction);
end

function ChangeFaction:OnCreate(nMapId)
    Log("ChangeFaction OnCreate", nMapId);
end

function ChangeFaction:OnDestroy(nMapId)
    Log("ChangeFaction OnDestroy", nMapId);
end

function ChangeFaction:OnEnter(nMapId)
    local tbPlayerInfo = self:GetPlayerInfo(me.dwID);
    tbPlayerInfo = tbPlayerInfo or {};
    tbPlayerInfo.nEnterTime = GetTime();
    tbPlayerInfo.nOrgFaction = me.nFaction;

    if tbPlayerInfo.nOnDeathRegID then
        PlayerEvent:UnRegister(me, "OnDeath", tbPlayerInfo.nOnDeathRegID);
        tbPlayerInfo.nOnDeathRegID = nil;
    end

    tbPlayerInfo.nOnDeathRegID = PlayerEvent:Register(me, "OnDeath", self.OnPlayerDeath, self);

    self.tbAllPlayerInfo[me.dwID] = tbPlayerInfo;

    local nCurMapId, nPosX, nPosY = me.GetWorldPos();
    me.SetTempRevivePos(nCurMapId, nPosX, nPosY);  --设置临时复活点
    me.bForbidChangePk = 1;
    me.nInBattleState = 1; --战场模式
    me.SetPkMode(Player.MODE_PEACE);
    me.CallClientScript("AutoFight:ChangeHand");
    Log("ChangeFaction OnEnter", nMapId, me.dwID, me.nFaction);
end

function ChangeFaction:OnPlayerDeath()
    me.Revive(1);
end

function ChangeFaction:GetPlayerInfo(nPlayerID)
    return self.tbAllPlayerInfo[nPlayerID];
end

function ChangeFaction:OnLeave(nMapId)
    local tbPlayerInfo = self:GetPlayerInfo(me.dwID);
    if not tbPlayerInfo then
        Log("Error ChangeFaction OnLeave", nMapId, me.dwID);
        return;
    end


    self:ClearFactionData(me, tbPlayerInfo.nOrgFaction);

    if tbPlayerInfo.nOnDeathRegID then
        PlayerEvent:UnRegister(me, "OnDeath", tbPlayerInfo.nOnDeathRegID);
        tbPlayerInfo.nOnDeathRegID = nil;
    end

    me.ClearTempRevivePos();
    local tbLogData =
    {
        Result = Env.LogRound_SUCCESS;
        nMatchTime = GetTime() - tbPlayerInfo.nEnterTime;
    };
    me.ActionLog(Env.LogType_Activity, Env.LogWay_ChangeFaction, tbLogData);
    self.tbAllPlayerInfo[me.dwID] = nil;

    me.bForbidChangePk = 0;
    me.nInBattleState = 0; --战场模式
    Log("ChangeFaction OnLeave", nMapId, me.dwID, me.nFaction);
end

function ChangeFaction:ClearFactionChannel(pPlayer, nOrgFaction)
    local tbOrgChat = Faction.tbChatChannel[nOrgFaction];
    if tbOrgChat then
        KChat.DelPlayerFromDynamicChannel(tbOrgChat, pPlayer.dwID);
    end

    local tbCurChat = Faction.tbChatChannel[pPlayer.nFaction];
    if pPlayer.nLevel >= 20 and tbCurChat then
        KChat.AddPlayerToDynamicChannel(tbCurChat, pPlayer.dwID);
    end
end

function ChangeFaction:ClearFactionData(pPlayer, nOrgFaction)
    if pPlayer.nFaction == nOrgFaction then
        return;
    end

    local nTitleID = FactionBattle.CHAMPION_TITLE[nOrgFaction];
    if nTitleID then
        local tbTitle = PlayerTitle:GetPlayerTitleByID(pPlayer, nTitleID);
        if tbTitle then
            pPlayer.DeleteTitle(nTitleID, true);

            local tbTitleTemp = PlayerTitle:GetTitleTemplate(nTitleID);
            if tbTitleTemp then
                pPlayer.Msg(string.format("由於轉為新門派，原稱號「%s」無法使用，稱號消失", tbTitleTemp.Name));
            end    
        end
    end

    nTitleID = FactionBattle.MONKEY_TITLE_ID[nOrgFaction];
    if nTitleID then
        local tbTitle = PlayerTitle:GetPlayerTitleByID(pPlayer, nTitleID);
        if tbTitle then
            pPlayer.DeleteTitle(nTitleID, true);

            local tbTitleTemp = PlayerTitle:GetTitleTemplate(nTitleID);
            if tbTitleTemp then
                pPlayer.Msg(string.format("由於轉為新門派，原稱號「%s」無法使用，稱號消失", tbTitleTemp.Name));
            end    
        end
    end

    if FactionBattle.FactionMonkey then
        Lib:CallBack({FactionBattle.FactionMonkey.DelCandidate, FactionBattle.FactionMonkey, nOrgFaction, pPlayer.dwID});
        Log("ChangeFaction ClearFactionData FactionMonkey", pPlayer.dwID, nOrgFaction);
    end

    
    
    Log("ChangeFaction ClearFactionData", pPlayer.dwID, nOrgFaction);
end
