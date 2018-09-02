local tbNpc1 = Npc:GetClass("SwornFriendsNpc1")

function tbNpc1:OnDialog(szParam)
    Dialog:Show({
        Text = "想要處理結拜關係都可以前來找我！",
        OptList = {
            { Text = "我們要結拜", Callback = self.Connect, Param = {self} },
            { Text = "割袍斷義", Callback = self.Disconnect, Param = {self} },
            { Text = "更改個人稱號", Callback = self.ChangeTitle, Param = {self} },
        },
    }, me, him)
end

function tbNpc1:Connect()
    local bValid, szErr = SwornFriends:CheckBeforeConnect(me)
    if not bValid then
        me.CenterMsg(szErr)
        return
    end

    local tbPlayer = KNpc.GetAroundPlayerList(him.nId, SwornFriends.Def.nConnectDistance) or {}
    local tbAroundPids = {}
    for _,pPlayer in pairs(tbPlayer) do
        tbAroundPids[pPlayer.dwID] = true
    end

    local tbMembers = TeamMgr:GetMembers(me.dwTeamID)
    for _, nId in ipairs(tbMembers) do
        if not tbAroundPids[nId] then
            Dialog:Show({
                Text = "還是等隊友都到了後再來找我結拜吧。",
                OptList = {
                    { Text = "知道了" }
                },
            }, me, him)
            return
        end
    end

    me.CallClientScript("Ui:OpenWindow", "SwornFriendsTitlePanel")
end

function tbNpc1:Disconnect()
    local bOk, szErr = SwornFriends:CheckBeforeDisconnect(me)
    if not bOk then
        me.CenterMsg(szErr)
        return
    end

    me.CallClientScript("SwornFriends:DisconnectDlg")
end

function tbNpc1:ChangeTitle()
    local bOk, szErr = SwornFriends:CheckBeforeChangePersonalTitle(me)
    if not bOk then
        me.CenterMsg(szErr)
        return
    end

    me.CallClientScript("Ui:OpenWindow", "SwornFriendsPersonalTitlePanel")
end


--------------------------------------------------------------------------
local tbNpc2 = Npc:GetClass("SwornFriendsNpc2")

function tbNpc2:OnDialog(szParam)
    Dialog:Show({
        Text = "想要處理結拜關係都可以前來找我！",
        OptList = {
            { Text = "離開", Callback = self.Quit, Param = {self} },
        },
    }, me, him)
end

function tbNpc2:Quit()
    me.GotoEntryPoint()
end
