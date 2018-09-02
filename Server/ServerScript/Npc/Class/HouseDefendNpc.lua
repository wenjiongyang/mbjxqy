local tbNpc = Npc:GetClass("HouseDefendNpc");

function tbNpc:OnDialog()
    local szDialog = "唉，說來有些慚愧，我們遭人下毒，武功暫失，所住之地如今為人霸佔，還望俠士施以援手";
    local tbOpt = {};
    local dwOwnerId = House:GetHouseInfoByMapId(him.nMapId);
    if not dwOwnerId then
        Dialog:Show(
        {
            Text = szDialog,
            OptList = tbOpt,
        }, me, him)
        return;
    end

    if dwOwnerId == me.dwID then
        table.insert(tbOpt, { Text = "開啟新穎小築奪回戰", Callback = function ()
            Activity:OnPlayerEvent(me, "Act_HouseDefend_OpenFuben");
        end, Param = {} });
    end

    table.insert(tbOpt, { Text = "前往新穎小築奪回戰", Callback = function ()
        Activity:OnPlayerEvent(me, "Act_HouseDefend_EnterFuben", dwOwnerId);
    end, Param = {} });

    Dialog:Show(
    {
        Text = szDialog,
        OptList = tbOpt,
    }, me, him)
end