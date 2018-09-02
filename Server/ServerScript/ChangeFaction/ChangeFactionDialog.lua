
local tbNpc = Npc:GetClass("ChangeFactionDialog");
Require("CommonScript/ChangeFaction/ChangeFactionDef.lua");

local tbDef = ChangeFaction.tbDef;

function tbNpc:OnDialog()
    Dialog:Show(
    {
        Text    = "這裡是洗髓島，你可以在這裡任意切換各個門派，以及重置技能點",
        OptList = {
            { Text = "選擇要轉的門派", Callback = self.SelectAllFaction, Param = {self, him.nId} },
            { Text = "我選好了，要離開", Callback = self.LeaveMap, Param = {self, him.nId} },
        };
    }, me, him);
end

function tbNpc:LeaveMap(nNpcID)
    local pNpc = KNpc.GetById(nNpcID);
    if not pNpc then
        Log("ChangeFactionDialog SelectAllFaction Not Npc");
        return;
    end

    local tbPlayerInfo = ChangeFaction:GetPlayerInfo(me.dwID);
    local nOrgFaction = me.nFaction;
    local nSaveFaction = me.GetUserValue(tbDef.nSaveGroup, tbDef.nSaveEnterFaction);
    if nSaveFaction > 0 then
        nOrgFaction = nSaveFaction;
    elseif tbPlayerInfo then
        nOrgFaction = tbPlayerInfo.nOrgFaction;
    end

    local szMsg = "";
    if nOrgFaction == me.nFaction then
        szMsg = "你當前所選門派與原門派相同。你確定要[FF0000]消耗轉門派[-]的機會，但[FF0000]不轉門派[-]嗎？";
    else
        local szFaction = Faction:GetName(me.nFaction);
        szMsg = string.format("你選擇了[FFFE0D]%s[-]作為新的門派。你確定這樣的選擇？確認離開洗髓島後，將不可再改變", szFaction);
    end  

    me.MsgBox(szMsg, {{"確認", self.ConfirmLeaveMap, self, me.dwID}, {"取消"}});  
end

function tbNpc:ConfirmLeaveMap(nPlayerID)
    local pPlayer = KPlayer.GetPlayerObjById(nPlayerID);
    if not pPlayer then
        return;
    end

    pPlayer.GotoEntryPoint();
    Log("ChangeFaction ConfirmLeaveMap", nPlayerID);
end

function tbNpc:SelectAllFaction(nNpcID)
    local pNpc = KNpc.GetById(nNpcID);
    if not pNpc then
        Log("ChangeFactionDialog SelectAllFaction Not Npc");
        return;
    end

    local tbAllFaction = {};
    for nFaction, tbInfo in pairs(Faction.tbFactionInfo) do
        tbAllFaction[nFaction] = 1;
    end

    me.CallClientScript("Ui:OpenWindow", "ChangeFactionPanel", tbAllFaction)
end

function tbNpc:AcceptChangeFaction(nNpcID, nChangeFaction)
    local pNpc = KNpc.GetById(nNpcID);
    if not pNpc then
        Log("PunishTask Accept Not Npc");
        return;
    end

    ChangeFaction:PlayerChangeFaction(me, nChangeFaction);
end