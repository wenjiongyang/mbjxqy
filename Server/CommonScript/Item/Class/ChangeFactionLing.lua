
Require("CommonScript/ChangeFaction/ChangeFactionDef.lua");
local tbDef = ChangeFaction.tbDef;
local tbItem = Item:GetClass("ChangeFactionLing");

function tbItem:OnUse(it)
    local nLastTime = me.GetUserValue(tbDef.nSaveGroup, tbDef.nSaveUseCD);
    local nRetTime = nLastTime - GetTime();
    if nRetTime > 0 then
        me.CenterMsg(string.format("%s後才可以使用", Lib:TimeDesc2(nRetTime)), true);
        return;
    end    

    me.MsgBox("你要前往洗髓島進行轉門派嗎？\n進入洗髓島後，無論[FF0000]是否轉職[-]，均會[FF0000]消耗1個天劍令[-]", {{"前往", self.Affirm, self, me.dwID}, {"取消"}})
end

function tbItem:Affirm(nPlayerID)
    local pPlayer = KPlayer.GetPlayerObjById(nPlayerID);
    if not pPlayer then
        Log("ERROR ChangeFactionLing Not Player");
        return;
    end

    ChangeFaction:ApplyEnterMap(pPlayer);
end

