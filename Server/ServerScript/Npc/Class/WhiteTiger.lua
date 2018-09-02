local tbNpc   = Npc:GetClass("WhiteTiger")

local tbIndex = {"一", "二", "三", "四", "五", "六", "七", "八"}
function tbNpc:OnDialog()
    local nRoomId  = tonumber(him.szScriptParam)
    local szIdx    = tbIndex[nRoomId]
    local szDialog = "這裡是進入白虎堂一層的入口" .. szIdx .. "，你確定要進入嗎？"
    Dialog:Show(
    {
        Text = szDialog,
        OptList = {
            { Text = "進入·入口" .. szIdx, Callback = self.EnterFuben, Param = {self, me.dwID, nRoomId} }
        },
    }, me, him)
end

function tbNpc:EnterFuben(dwID, nRoomId)
    local pPlayer = KPlayer.GetPlayerObjById(dwID)
    if not pPlayer then
        return
    end

    Fuben.WhiteTigerFuben:TryEnterOutSideFuben(pPlayer, nRoomId)
end