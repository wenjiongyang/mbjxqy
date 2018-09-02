local tbNpc   = Npc:GetClass("ArenaNpc")

local nLimitLevel = 10
function tbNpc:OnDialog(szParam)
    if me.nLevel < nLimitLevel then
         Dialog:Show(
        {
            Text = string.format("少俠閱歷尚淺，%d級以後才能進入比武場！",nLimitLevel),
            OptList = {
                { Text = "知道了"}
            },
        }, me, him)
        return
    end
    if him.szScriptParam == "ArenaEnterNpc" then
        -- 擂场入口Npc
         Dialog:Show(
        {
            Text = "阿彌陀佛，施主步履輕快，想必身手不凡……",
            OptList = {
                { Text = "進入比武場", Callback = self.EnterArena, Param = {self, me.dwID} }
            },
        }, me, him)
    elseif him.szScriptParam == "ArenaManagerNpc" then
        -- 擂台报名Npc
        Dialog:Show(
        {
            Text = "阿彌陀佛，施主步履輕快，想必身手不凡，何不上擂臺一展雄姿？",
            OptList = {
                { Text = "我要上擂臺", Callback = self.SignInArena, Param = {self, me.dwID} }
            },
        }, me, him)
    else
        Log("[ArenaBattle] can not find npc",him.szScriptParam)
    end
end

function tbNpc:EnterArena(dwID)
    local pPlayer = KPlayer.GetPlayerObjById(dwID)
    if not pPlayer then
        return
    end
    pPlayer.SetEntryPoint()
    pPlayer.SwitchMap(ArenaBattle.nArenaMapId,unpack(ArenaBattle.defaultEnterMapPos))
end

function tbNpc:SignInArena(dwID)
    local pPlayer = KPlayer.GetPlayerObjById(dwID)
    if not pPlayer then
        return
    end
    pPlayer.CallClientScript("Ui:OpenWindow","ArenaPanel")
end

