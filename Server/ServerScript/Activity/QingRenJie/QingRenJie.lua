local tbAct = Activity:GetClass("QingRenJie")
tbAct.tbTrigger = { Init = { }, Start = { }, End = { }, }

tbAct.GROUP = 68
tbAct.VERSION = 11
tbAct.INVITE = 12
tbAct.BE_INVITE = 13
tbAct.TICKET_FLAG = 14
tbAct.TITLE_FLAG = 15
tbAct.SIT_FLAG = 16
tbAct.ACCEPT_DAY = 17
tbAct.ACCEPT_TIMES = 18
tbAct.tbMapInfo = {}

----------------------------以下为配置项----------------------------
tbAct.TICKET_TID = 3790      --船票ID
tbAct.GIFT_TID = 3787        --赠送礼物时赠送方得到的了礼物
tbAct.GIFT_TID_ACCEPT = 3791 --赠送礼物是对方得到的了礼物
tbAct.RANDOM_GIFT_TID = 3793 --从礼物开出的道具ID
tbAct.TICKET_RATE = 10000    --max is 1000000
tbAct.LEVEL = 40             --参与等级
tbAct.tbGift = {
    3788,
    3789,
}
tbAct.TITLE_ENDTIME = Lib:ParseDateTime("2017/3/14")
tbAct.BE_SEND_GIFT = 5      --每天接受礼物时只能有5有奖励
tbAct.HEAD_BG = 10          --头像框ID
tbAct.CHOOSE_TITLE_ID = 3792
tbAct.BASIC_EXP = 120
tbAct.IMITITY = 999
tbAct.tbPos = {
    {1450, 1700},
    {350,1700},
}
tbAct.TICKET_PRICE = 999
tbAct.NEED_IMITITY_LV = 1
----------------------------以上为配置项----------------------------

function tbAct:OnTrigger(szTrigger)
    if szTrigger == "Init" then
        self:SendMail("    有朋自遠方來，不亦樂乎？有舟自遠方來，不遊樂乎？今江湖有異國之邦到訪，隨之而來的還有妖豔花朵及精緻船坊，俠士只需完成[FFFE0D]每日目標活躍度[-]即可獲得禮物，有緣人更可獲得稀有[FFFE0D]雙人船票[-]，與心儀之人一睹小樓聽雨舫的風采！若與船票失之交臂，只需前往[FFFE0D]襄陽城[-]尋找[c8ff00][url=npc:小紫煙, 95, 10][-]即可直接購買船票！船隊將於數日後離開，不要錯過哦！")
    elseif szTrigger == "Start" then 
        Activity:RegisterPlayerEvent(self, "Act_EverydayTarget_Award", "OnGainEverydayAward")
        Activity:RegisterPlayerEvent(self, "Act_QingRenJie_AgreeInvite", "AgreeInvite")
        Activity:RegisterPlayerEvent(self, "Act_QingRenJie_TryDazuo", "TryDazuo")
        Activity:RegisterPlayerEvent(self, "Act_QingRenJie_AgreeInviteDazuo", "AgreeInviteDazuo")
        Activity:RegisterPlayerEvent(self, "Act_QingRenJie_ChooseTitle", "TryChooseTitle")
        Activity:RegisterPlayerEvent(self, "Act_TryUseQingRenJieGift", "OnUseGift")
        Activity:RegisterPlayerEvent(self, "Act_SendGift", "OnSendGift")
        Activity:RegisterPlayerEvent(self, "Act_OnLeaveMap", "OnLeaveMap")
        Activity:RegisterPlayerEvent(self, "Act_OnPlayerLogout", "OnLogout")
        Activity:RegisterNpcDialog(self, 95, {Text = "前去購買門票", Callback = self.BuyTicket, Param = {self}})
        Activity:RegisterNpcDialog(self, 95, {Text = "前往溫馨小屋", Callback = self.TryInteract, Param = {self}})
        Activity:RegisterNpcDialog(self, 95, {Text = "前去被邀請船舫", Callback = self.TryEnterAlong, Param = {self}})
        self.tbMapInfo = {}
        local tbItem = Item:GetClass("QingRenJieTitleItem")
        self.tbTitle = tbItem.tbTitle
    elseif szTrigger == "End" then
        self:SendMail("    諸位俠士，中原武林果然有趣，各位情深意重，也令我大開眼界，如今船隊已然離去，還望諸位保重！來年再會！")
    end
end

function tbAct:SendMail(szContent)
    Mail:SendGlobalSystemMail({
        Title = "竹林小屋情人結",
        Text = szContent,
        From = "小紫煙",
        LevelLimit = self.LEVEL
        })
end

function tbAct:OnGainEverydayAward(pPlayer)
    if pPlayer.nLevel < self.LEVEL then
        return
    end

    local nSex = Gift:CheckSex(pPlayer.nFaction)
    local _, nEndTime = self:GetOpenTimeInfo()
    pPlayer.SendAward({{"Item", self.tbGift[nSex], 1, nEndTime}}, true, false, Env.LogWay_QingRenJie)
    Log("QingRenJie OnGainEverydayAward", pPlayer.dwID)
end

function tbAct:CheckGainTicket(pPlayer)
    self:CheckPlayerData(pPlayer)
    return pPlayer.GetUserValue(self.GROUP, self.TICKET_FLAG) <= 0, "活動期間每名俠士只能獲得一張門票"
end

function tbAct:BuyTicket(bConfirm)
    local pPlayer = me
    local bRet, szMsg = self:CheckGainTicket(pPlayer)
    if not bRet then
        pPlayer.CenterMsg(szMsg)
        return
    end

    if not bConfirm then
        me.MsgBox("每位俠士只能獲得一張門票，是否確認花費[FFFE0D]999元寶[-]進行購買？", {{"確認", self.BuyTicket, self, true}, {"取消"}})
        return
    end

    if pPlayer.GetMoney("Gold") < self.TICKET_PRICE then
        pPlayer.CenterMsg("元寶不足！請先儲值")
        pPlayer.CallClientScript("Ui:OpenWindow", "CommonShop", "Recharge", "Recharge")
        return
    end
    pPlayer.CostGold(self.TICKET_PRICE, Env.LogWay_QingRenJie, nil, function (nPlayerId, bSuccess)
            local pPlayer = KPlayer.GetPlayerObjById(nPlayerId)
            if not pPlayer then
                return false, "離線了"
            end

            if not bSuccess then
                return false, "儲值失敗"
            end

            local bRet, szMsg = self:CheckGainTicket(pPlayer)
            if not bRet then
                return false, szMsg
            end

            local _, nEndTime = self:GetOpenTimeInfo()
            pPlayer.SetUserValue(self.GROUP, self.TICKET_FLAG, 1)
            pPlayer.SendAward({{"Item", self.TICKET_TID, 1, nEndTime}}, true, nil, Env.LogWay_QingRenJie)
            Log("QingRenJie BuyTicket Success", pPlayer.dwID)
            return true
    end)
end

function tbAct:OnUseGift(pPlayer, pItem)
    if Item:Consume(pItem, 1) < 1 then
        return
    end

    local _, nEndTime = self:GetOpenTimeInfo()
    local bRet = self:CheckGainTicket(pPlayer)
    if bRet and MathRandom(1000000) <= self.TICKET_RATE then
        pPlayer.SetUserValue(self.GROUP, self.TICKET_FLAG, 1)
        pPlayer.SendAward({{"Item", self.TICKET_TID, 1, nEndTime}}, true, false, Env.LogWay_QingRenJie)
        local szMsg = string.format("俠士「%s」開啟回禮禮盒後發現其中的雙人船票·泛舟江湖，不日即可攜心儀之人同行，同舟共渡，實在令人心生羡慕！", pPlayer.szName)
        KPlayer.SendWorldNotify(1, 1000, szMsg, ChatMgr.ChannelType.Public, 1)
        Log("QingRenJie OnUseGift GetTicket", pPlayer.dwID)
    end
    pPlayer.SendAward({{"Item", self.RANDOM_GIFT_TID, 1, nEndTime}}, true, false, Env.LogWay_QingRenJie)
    Log("QingRenJie UseGift", pPlayer.dwID)
end

function tbAct:OnSendGift(pPlayer, pAcceptPlayer, nGiftType)
    if nGiftType ~= Gift.GiftType.Lover then
        return
    end

    local _, nEndTime = self:GetOpenTimeInfo()
    local tbAward = {{"Item", self.GIFT_TID, 1, nEndTime}}
    pPlayer.SendAward(tbAward, true, false, Env.LogWay_QingRenJie)
    if pAcceptPlayer.GetUserValue(self.GROUP, self.ACCEPT_DAY) ~= Lib:GetLocalDay() then
        pAcceptPlayer.SetUserValue(self.GROUP, self.ACCEPT_DAY, Lib:GetLocalDay())
        pAcceptPlayer.SetUserValue(self.GROUP, self.ACCEPT_TIMES, 0)
    end
    local nHadAcc = pAcceptPlayer.GetUserValue(self.GROUP, self.ACCEPT_TIMES)
    if nHadAcc < self.BE_SEND_GIFT then
        pAcceptPlayer.SetUserValue(self.GROUP, self.ACCEPT_TIMES, nHadAcc + 1)
        local tbAward = {{"Item", self.GIFT_TID_ACCEPT, 1, nEndTime}}
        pAcceptPlayer.SendAward(tbAward, true, false, Env.LogWay_QingRenJie)

        local nGiftTID = Gift:GetItemId(nGiftType, Gift:CheckSex(pAcceptPlayer.nFaction))
        local szItemName = KItem.GetItemShowInfo(nGiftTID)
        local szMsg = string.format("    佳節將至，情緣未遠。值此佳節，[FFFE0D]「%s」[-]將準備已久的[FFFE0D]「%s」[-]小心交到你的手中，你接過一看，下面竟然還藏有一個小小的禮盒，快打開看看裡面裝著什麼吧！", pPlayer.szName, szItemName)
        local tbMail = {Title = "竹林小屋情人結", Text = szMsg, nLogReazon = Env.LogWay_QingRenJie, To = pAcceptPlayer.dwID}
        Mail:SendSystemMail(tbMail)
        Log("QingRenJie OnBeSendGift", pAcceptPlayer.dwID, nHadAcc)
    end
    Log("QingRenJie OnSendGift", pPlayer.dwID, pAcceptPlayer.dwID)
end

function tbAct:CheckPlayerData(pPlayer)
    local nStartTime = self:GetOpenTimeInfo()
    local nVersion = pPlayer.GetUserValue(self.GROUP, self.VERSION)
    if nVersion ~= nStartTime then
        pPlayer.SetUserValue(self.GROUP, self.VERSION, nStartTime)
        for i = self.VERSION + 1, self.SIT_FLAG do
            pPlayer.SetUserValue(self.GROUP, i, 0)
        end
    end
end

function tbAct:CheckEnterSelfMap(pPlayer)
    self:CheckPlayerData(pPlayer)
    if not Env:CheckSystemSwitch(me, Env.SW_SwitchMap) then
        pPlayer.CenterMsg("目前狀態不允許切換地圖")
        return
    end
    return pPlayer.GetUserValue(self.GROUP, self.INVITE) > 0
end

function tbAct:CheckInvite(pPlayer, pLover)
    if pPlayer.nLevel < self.LEVEL then
        return false, "等級須大於等於40級方可參與"
    end

    if pPlayer.GetUserValue(self.GROUP, self.INVITE) > 0 then
        return false, "每個俠士只能邀請一次"
    end

    if not pPlayer.dwTeamID or pPlayer.dwTeamID == 0 then
        return false, "你還沒有隊伍"
    end

    local tbMember = TeamMgr:GetMembers(pPlayer.dwTeamID)
    if #tbMember ~= 2 then
        return false, "必須組成兩人隊伍"
    end

    if pPlayer.GetItemCountInAllPos(self.TICKET_TID) <= 0 then
        return false, "沒有船票泛舟江湖，請先獲取船票"
    end

    local dwLover = tbMember[1] == pPlayer.dwID and tbMember[2] or tbMember[1]
    if pLover then
        if pLover.dwID ~= dwLover then
            return false
        end
    else
        pLover = KPlayer.GetPlayerObjById(dwLover)
    end
    if not pLover then
        return false, "沒找到隊友"
    end

    if Gift:CheckSex(pPlayer.nFaction) == Gift:CheckSex(pLover.nFaction) or not FriendShip:IsFriend(pPlayer.dwID, dwLover) then
        return false, "你與對方並非異性的好友，請確認後在進行嘗試哦"
    end

    if pLover.nLevel < self.LEVEL then
        return false, "被邀請的俠士等級不足"
    end

    self:CheckPlayerData(pLover)
    if pLover.GetUserValue(self.GROUP, self.BE_INVITE) > 0 then
        local szMsg = "每名俠士只能接受一次邀請"
        pLover.CenterMsg(szMsg)
        return false, szMsg, pLover
    end

    local nMapId1 = pPlayer.GetWorldPos()
    local nMapId2 = pLover.GetWorldPos()
    if nMapId1 ~= nMapId2 or pPlayer.GetNpc().GetDistance(pLover.GetNpc().nId) > Npc.DIALOG_DISTANCE * 3 then
        return false, "距離小紫煙太遠了，請先到小紫煙身邊哦", pLover
    end

    if FriendShip:GetFriendImityLevel(pPlayer.dwID, pLover.dwID) < self.NEED_IMITITY_LV then
        return false, string.format("雙方親密度等級需達到%d級", self.NEED_IMITITY_LV), pLover
    end

    for _, pNeedCheck in ipairs({pPlayer, pLover}) do
        if not Fuben.tbSafeMap[pNeedCheck.nMapTemplateId] and Map:GetClassDesc(pNeedCheck.nMapTemplateId) ~= "fight" and
            pNeedCheck.nMapTemplateId ~= self.PREPARE_MAPID and pNeedCheck.nMapTemplateId ~= self.OUTSIDE_MAPID then
            return false, string.format("「%s」所在地圖不允許進入副本！", pNeedCheck.szName), pLover
        end

        if Map:GetClassDesc(pNeedCheck.nMapTemplateId) == "fight" and pNeedCheck.nFightMode ~= 0 then
            return false, string.format("「%s」非安全區不允許進入副本！", pNeedCheck.szName), pLover
        end
    end

    return true, nil, pLover
end

function tbAct:TryInteract()
    local pPlayer = me
    if self:CheckEnterSelfMap(pPlayer) then
        local nMapId = self.tbMapInfo[pPlayer.dwID]
        self:EnterMap(pPlayer.dwID, nMapId)
        return
    end

    local bRet, szMsg, pLover = self:CheckInvite(pPlayer)
    if not bRet then
        if szMsg then
            pPlayer.CenterMsg(szMsg)
            if pLover then
                pLover.CenterMsg(szMsg)
            end
        end
        return
    end

    pLover.CallClientScript("Activity.QingRenJie:OnGetInvite", pPlayer.dwID, pPlayer.szName)
end

function tbAct:AgreeInvite(pBeInvitePlayer, nInvitePlayer, bAgree)
    if not nInvitePlayer then
        return
    end

    local pPlayer = KPlayer.GetPlayerObjById(nInvitePlayer)
    if not pPlayer then
        pBeInvitePlayer.CenterMsg("對方未在線")
        return
    end

    if not bAgree then
        pPlayer.CenterMsg("對方拒絕了你的邀請")
        return
    end

    local bRet, szMsg = self:CheckInvite(pPlayer)
    if not bRet then
        if szMsg then
            pPlayer.CenterMsg(szMsg)
            pBeInvitePlayer.CenterMsg(szMsg)
        end
        return
    end

    local nPlayer1 = pPlayer.dwID
    local nPlayer2 = pBeInvitePlayer.dwID
    local fnSuccessCallback = function (nMapId)
        local pPlayer = KPlayer.GetPlayerObjById(nPlayer1)
        local pLover = KPlayer.GetPlayerObjById(nPlayer2)
        if not pPlayer or not pLover then
            return
        end

        pPlayer.ConsumeItemInAllPos(self.TICKET_TID, 1, Env.LogWay_QingRenJie)
        pPlayer.SetUserValue(self.GROUP, self.INVITE, pLover.dwID)
        pLover.SetUserValue(self.GROUP, self.BE_INVITE, pPlayer.dwID)
        self:SwitchMap(pPlayer, nMapId, 0, 0, pPlayer.dwID)
        self:SwitchMap(pLover, nMapId, 0, 0, pPlayer.dwID)
        self.tbMapInfo[pPlayer.dwID] = nMapId
        local szMsg = string.format("%s和%s攜手一同登上了小樓聽雨舫，泛舟湖上，共賞江湖美景！實在是羨煞旁人！", pPlayer.szName, pLover.szName)
        KPlayer.SendWorldNotify(1, 1000, szMsg, ChatMgr.ChannelType.Public, 1)
        Log("QingRenJie Invite Success", pPlayer.dwID, pLover.dwID)
    end

    local fnFailedCallback = function ()
        local pPlayer = KPlayer.GetPlayerObjById(nPlayer1)
        local pLover = KPlayer.GetPlayerObjById(nPlayer2)
        if not pPlayer or not pLover then
            return
        end
        pPlayer.CenterMsg("進入失敗，請重試")
        pLover.CenterMsg("進入失敗，請重試")
        Log("QingRenJie Invite CreateMap Fail", pPlayer.dwID, pLover.dwID)
    end

    Fuben:ApplyFuben(pPlayer.dwID, self.MAP_TID, fnSuccessCallback, fnFailedCallback)
end

function tbAct:TryEnterAlong()
    local pPlayer = me
    self:CheckPlayerData(pPlayer)
    local nInvitePlayer = pPlayer.GetUserValue(self.GROUP, self.BE_INVITE)
    if nInvitePlayer <= 0 then
        pPlayer.CenterMsg("未被邀請")
        return
    end

    local nMapId = self.tbMapInfo[nInvitePlayer]
    self:EnterMap(pPlayer.dwID, nMapId, nInvitePlayer)
end

function tbAct:EnterMap(dwID, nMapId, nInvitePlayer)
    if not nMapId or not GetMapInfoById(nMapId) then
        local fnSuccessCallback = function (nMapId)
            local nPlayerID = nInvitePlayer or dwID
            self.tbMapInfo[nPlayerID] = nMapId
            local pPlayer = KPlayer.GetPlayerObjById(dwID)
            if not pPlayer then
                return
            end
            self:SwitchMap(pPlayer, nMapId, 0, 0, nInvitePlayer or dwID)
        end
    
        local fnFailedCallback = function ()
            local pPlayer = KPlayer.GetPlayerObjById(nPlayer1)
            if not pPlayer then
                return
            end
            pPlayer.CenterMsg("進入失敗，請重試")
        end
        Fuben:ApplyFuben(dwID, self.MAP_TID, fnSuccessCallback, fnFailedCallback)
    else
        local pPlayer = KPlayer.GetPlayerObjById(dwID)
        self:SwitchMap(pPlayer, nMapId, 0, 0, nInvitePlayer or dwID)
    end
end

function tbAct:SwitchMap(pPlayer, nMapId, nX, nY, nApplyID)
    if pPlayer.GetActionMode() ~= Npc.NpcActionModeType.act_mode_none then
        ActionMode:DoChangeActionMode(pPlayer, Npc.NpcActionModeType.act_mode_none)
    end
    pPlayer.SetEntryPoint()
    pPlayer.SwitchMap(nMapId, nX or 0, nY or 0)
    pPlayer.CallClientScript("Activity.QingRenJie:OnSetApplyPlayer", nApplyID)
end

function tbAct:CheckCanDazuo(pPlayer)
    if pPlayer.GetUserValue(self.GROUP, self.SIT_FLAG) > 0 then
        return false, "只能進行一次互動"
    end

    if pPlayer.nMapTemplateId ~= self.MAP_TID then
        return false, "隊伍中有成員不在溫馨小屋地圖內"
    end

    if pPlayer.nQingRenDazuo then
        return false, "正在進行互動"
    end

    if not pPlayer.dwTeamID or pPlayer.dwTeamID == 0 then
        return false, "你還沒有隊伍"
    end

    local tbMember = TeamMgr:GetMembers(pPlayer.dwTeamID)
    if #tbMember ~= 2 then
        return false, "必須與隊伍中另一名異性好友處於本地圖內"
    end

    local dwLover = tbMember[1] == pPlayer.dwID and tbMember[2] or tbMember[1]
    local pLover = KPlayer.GetPlayerObjById(dwLover)
    if pLover.nMapTemplateId ~= self.MAP_TID then
        return false, "隊伍中有成員不在溫馨小屋地圖內"
    end
    
    if pLover.nMapId ~= pPlayer.nMapId then
        return false, "對方不在溫馨小屋地圖內"
    end

    if pLover.nQingRenDazuo then
        return false, "正在觀賞美景"
    end
    return true, nil, pLover
end

function tbAct:TryDazuo(pPlayer)
    local bRet, szMsg, pLover = self:CheckCanDazuo(pPlayer)
    if not bRet then
        if szMsg then
            pPlayer.CenterMsg(szMsg)
        end
        return
    end

    pLover.CallClientScript("Activity.QingRenJie:OnGetDazuoInvite", pPlayer.dwID, pPlayer.szName)
end

function tbAct:AgreeInviteDazuo(pBeInvitePlayer, nInvitePlayer, bAgree)
    if not nInvitePlayer then
        return
    end

    local pPlayer = KPlayer.GetPlayerObjById(nInvitePlayer)
    if not pPlayer then
        pBeInvitePlayer.CenterMsg("對方未在線")
        return
    end

    if not bAgree then
        pPlayer.CenterMsg("對方拒絕了你的邀請")
        return
    end

    local bRet, szMsg = self:CheckCanDazuo(pPlayer)
    if not bRet then
        if szMsg then
            pPlayer.CenterMsg(szMsg)
            pBeInvitePlayer.CenterMsg("邀請已過期")
        end
        return
    end

    Env:SetSystemSwitchOff(pPlayer, Env.SW_All)
    Env:SetSystemSwitchOff(pBeInvitePlayer, Env.SW_All)

    if pPlayer.GetActionMode() ~= Npc.NpcActionModeType.act_mode_none then
        ActionMode:DoChangeActionMode(pPlayer, Npc.NpcActionModeType.act_mode_none)
    end
    if pBeInvitePlayer.GetActionMode() ~= Npc.NpcActionModeType.act_mode_none then
        ActionMode:DoChangeActionMode(pBeInvitePlayer, Npc.NpcActionModeType.act_mode_none)
    end

    pPlayer.SetPosition(830,1135)
    pBeInvitePlayer.SetPosition(790,1110)
    pPlayer.GetNpc().CastSkill(1083, 1, self.tbPos[1][1], self.tbPos[1][2])
    pBeInvitePlayer.GetNpc().CastSkill(1083, 1, self.tbPos[2][1], self.tbPos[2][2])

    pPlayer.SetUserValue(self.GROUP, self.SIT_FLAG, 1)

    pPlayer.nQingRenDazuo = self.DAZUO_SEC
    pPlayer.CallClientScript("Activity.QingRenJie:OnBeginDazuo")
    ValueItem.ValueDecorate:SetValue(pPlayer, self.HEAD_BG, ChatMgr.ChatDecorate.Valid_Type.FOREVER)
    pPlayer.CenterMsg("恭喜俠士使用船票登上小樓聽雨舫，解鎖「泛舟江湖情人結」頭像框！")
    pBeInvitePlayer.nQingRenDazuo = self.DAZUO_SEC
    pBeInvitePlayer.CallClientScript("Activity.QingRenJie:OnBeginDazuo")
    Timer:Register(Env.GAME_FPS, function ()
        return self:ContinueDazuo(pPlayer.dwID, pBeInvitePlayer.dwID)
    end)
end

function tbAct:ContinueDazuo(nPlayer, nLover)
    for _, nPlayerID in ipairs({nPlayer, nLover}) do
        local pPlayer = KPlayer.GetPlayerObjById(nPlayerID)
        if pPlayer and pPlayer.nQingRenDazuo and pPlayer.nQingRenDazuo >= 1 then
            pPlayer.nQingRenDazuo = pPlayer.nQingRenDazuo - 1
            local bAddExp = pPlayer.nQingRenDazuo%(self.DAZUO_SEC/self.EXP_TIMES) == 0
            if bAddExp or pPlayer.nQingRenDazuo%12 == 0 then
                if bAddExp then
                    pPlayer.SendAward({{"BasicExp", self.BASIC_EXP/self.EXP_TIMES}}, false, false, Env.LogWay_QingRenJie)
                end
                pPlayer.CallClientScript("Activity.QingRenJie:ContinueDazuo", pPlayer.nQingRenDazuo)
            end
        else
            self:RestoreState(nPlayer, nLover)
            return
        end
    end
    return true
end

function tbAct:RestoreState(nPlayer, nLover)
    for _, nPlayerID in ipairs({nPlayer, nLover}) do
        local pPlayer = KPlayer.GetPlayerObjById(nPlayerID)
        if pPlayer then
            Env:SetSystemSwitchOn(pPlayer, Env.SW_All)
            pPlayer.GetNpc().RestoreAction()
            pPlayer.nQingRenDazuo = nil
            pPlayer.CallClientScript("Activity.QingRenJie:OnDazuoEnd", nPlayer == nPlayerID)
        end
    end
    FriendShip:AddImitity(nPlayer, nLover, self.IMITITY, Env.LogWay_SendGift) --使用花草的亲密度
end

function tbAct:TryChooseTitle(pPlayer, nTitleId, nItemID)
    if nItemID then
        self:ChooseTitleByItem(pPlayer, nTitleId, nItemID)
        return
    end

    if pPlayer.GetUserValue(self.GROUP, self.SIT_FLAG) <= 0 then
        pPlayer.CenterMsg("尚未觀賞美景，無法進行稱號選擇")
        return
    end

    if pPlayer.GetUserValue(self.GROUP, self.TITLE_FLAG) > 0 then
        pPlayer.CenterMsg("已選稱號")
        return
    end

    local nInvite = pPlayer.GetUserValue(self.GROUP, self.INVITE)
    if nInvite <= 0 then
        pPlayer.CenterMsg("未進入船塢")
        return
    end

    if not self.tbTitle[nTitleId] then
        pPlayer.CenterMsg("不能選擇該稱號")
        return
    end

    pPlayer.SetUserValue(self.GROUP, self.TITLE_FLAG, 1)
    self:SendTitleMail(pPlayer.dwID, nInvite, {{"AddTimeTitle", nTitleId, self.TITLE_ENDTIME}})
    pPlayer.CenterMsg("恭喜俠士獲得竹林小屋情人結限時稱號")
    local pLover = KPlayer.GetPlayerObjById(nInvite)
    if pLover then
        pLover.CenterMsg("恭喜俠士獲得竹林小屋情人結限時稱號")
    end
    Log("QingRenJie TryChooseTitle", pPlayer.dwID, nInvite)
end

function tbAct:ChooseTitleByItem(pPlayer, nTitleId, nItemID)
    if not self.tbTitle[nTitleId] then
        return
    end

    local pItem = KItem.GetItemObj(nItemID)
    if not pItem then
        return
    end

    if Item:Consume(pItem, 1) < 1 then
        pPlayer.CenterMsg("道具消耗失敗，請重試")
        return
    end

    local tbAward = {{"AddTimeTitle", nTitleId, self.TITLE_ENDTIME}}
    pPlayer.SendAward(tbAward, true, true, Env.LogWay_QingRenJie)
end

function tbAct:OnLeaveMap(pPlayer, nMapTID)
    self:SendTitleItem(pPlayer, nMapTID)
end

function tbAct:OnLogout(pPlayer)
    self:SendTitleItem(pPlayer, pPlayer.nMapTemplateId)
end

function tbAct:SendTitleItem(pPlayer, nMapTID)
    if nMapTID ~= self.MAP_TID then
        return
    end

    pPlayer.CallClientScript("Ui:CloseWindow", "QingRenJieInvitePanel")
    if pPlayer.GetUserValue(self.GROUP, self.SIT_FLAG) <= 0 then
        return
    end
    if pPlayer.GetUserValue(self.GROUP, self.TITLE_FLAG) > 0 then
        return
    end

    pPlayer.SetUserValue(self.GROUP, self.TITLE_FLAG, 1)
    local nLover = pPlayer.GetUserValue(self.GROUP, self.INVITE)
    local tbAward = {{"Item", self.CHOOSE_TITLE_ID, 1, self.TITLE_ENDTIME}}
    self:SendTitleMail(pPlayer.dwID, nLover, tbAward)
    Log("QingRenJie SendTitleItem", pPlayer.dwID, nLover)
end

function tbAct:SendTitleMail(dwID1, dwID2, tbAward)
    local tbMail = {Title = "竹林小屋情人結", From = "小紫煙", nLogReazon = Env.LogWay_QingRenJie}
    tbMail.tbAttach = tbAward
    tbMail.Text = "    恭喜俠士使用船票登上小樓聽雨舫，獲得「泛舟江湖情人結」限時稱號！祝二位情意長存！"
    for _, nPlayerID in ipairs({dwID1, dwID2}) do
        tbMail.To = nPlayerID
        Mail:SendSystemMail(tbMail)
    end
end