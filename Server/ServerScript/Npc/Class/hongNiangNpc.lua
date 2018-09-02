local tbNpc   = Npc:GetClass("hongNiangNpc")
function tbNpc:OnDialog(szParam)
	local nOpenDay, nOpenTime = Wedding:CheckTimeFrame()
    if nOpenDay then
         Dialog:Show(
        {
            Text = string.format("願無歲月可回頭，且以深情共白首。\n[FFFE0D]結婚系統將在%d天后開放！[-]", nOpenDay),
            OptList = {},
        }, me, him)
        return 
    end
    local tbOptList = {}
    local nLover = Wedding:GetLover(me.dwID)
    if nLover then
        tbOptList = {
            { Text = "離婚處理", Callback = self.DismissMenuDlg, Param = {self} },
            { Text = "領取結婚紀念日獎勵", Callback = self.ClaimMemorialDayRewards, Param = {self} },
        }
    else
        tbOptList = {
           { Text = "解除訂婚關係", Callback = self.MakeSureDelEngaged, Param = {self, me.dwID}},
        }
    end
	Dialog:Show(
    {
        Text = "願無歲月可回頭，且以深情共白首。",
        OptList = tbOptList,
    }, me, him)
end

function tbNpc:MakeSureDelEngaged(dwID)
	local pPlayer = KPlayer.GetPlayerObjById(dwID)
	if not pPlayer then
		return
	end
	if Wedding:IsSingle(pPlayer) then
		pPlayer.CenterMsg("你當前沒有訂婚關係")
		return
	end
	local nEngaged = Wedding:GetEngaged(pPlayer.dwID)
	if nEngaged then
		local pStayInfo = KPlayer.GetPlayerObjById(nEngaged) or KPlayer.GetRoleStayInfo(nEngaged)
		local szName = pStayInfo and pStayInfo.szName or ""
		local bHadBook = Wedding:CheckPlayerHadBook(dwID)
        -- 自动换行将颜色代码隔断会导致变色失败
		local szTip = string.format("確認跟 [FFFE0D]%s[-] 解除訂婚關係嗎？解除關係後[FF6464FF]「緣定今生」道具不退還[-]", szName)
        local szTipNone = string.format("確認跟 [FFFE0D]%s[-] 解除訂婚關係嗎？", szName) 
        if bHadBook then
            szTip = string.format("你已經預定了婚禮，%s 解除關係後[FF6464FF]預定的婚禮將被取消，所花費的金額不退還。[-]", szTipNone)
        end
		pPlayer.MsgBox(szTip,
			{
				{"確認解除", function () self:ComfirmDelEngaged(dwID) end},
				{"冷靜一下"},
			});
	else
		pPlayer.CenterMsg("你們已經完婚，若愛走到了盡頭，可以找我申請離婚")
	end
end

function tbNpc:ComfirmDelEngaged(dwID)
	local pPlayer = KPlayer.GetPlayerObjById(dwID)
	if not pPlayer then
		return
	end
	Wedding:TryDelEngaged(pPlayer)
end

---------
function tbNpc:DismissMenuDlg()
    Dialog:Show({
        Text = "如果愛走到了盡頭，分開未必不是好的開始。",
        OptList = {
            { Text = "協議離婚", Callback = self.Dismiss, Param = {self} },
            { Text = "強制離婚", Callback = self.ForceDismiss, Param = {self} },
            { Text = "取消離婚申請", Callback = self.CancelDismiss, Param = {self} },
        },
    }, me, him)
end

function tbNpc:Dismiss()
    local nOtherId = Wedding:GetLover(me.dwID)
    if not nOtherId then
        Npc:ShowErrDlg(me, him, "你尚未結婚")
        return
    end

    local bOk, szErr, szErrType = Npc:IsTeammateNearby(me, him, true)
    if not bOk then
        if szErrType then
            local tbErrs = {
                no_team = "請先和你的伴侶組隊，再前來協議離婚",
                not_captain = "請由隊長來申請協議離婚",
            }
            szErr = tbErrs[szErrType] or szErr
        end
        Npc:ShowErrDlg(me, him, szErr)
        return
    end

    local function fnConfirm()
        local bOk, szErr = Wedding:DismissReq(me)
        if not bOk and szErr then
            Npc:ShowErrDlg(me, him, szErr)
        end
    end

    Dialog:Show({
        Text = "百年修得同船渡，千年修得共枕眠。緣分難得，[FF6464FF]俠士想清楚要和對方解除婚姻關係嗎？[-]",
        OptList = {
            { Text = "確定解除婚姻關係", Callback = fnConfirm, Param = {} },
        },
    }, me, him)
end

function tbNpc:ForceDismiss()
    local function fnConfirm()
        local bOk, szErr = Wedding:ForceDismissReq(me)
        if not bOk and szErr then
            Npc:ShowErrDlg(me, him, szErr)
        end
    end

    local nLover = Wedding:GetLover(me.dwID)
    if not nLover then
        Npc:ShowErrDlg(me, him, "你沒有結婚")
        return
    end

    local szTxt = ""
    local _, nOfflineSec = Player:GetOfflineDays(nLover)
    if nOfflineSec>=Wedding.nForceDivorcePlayerOffline then
        szTxt = "俠士確定要解除婚姻關係嗎？對方已離線超過[FFFE0D]14天[-]，申請後立即生效。"
    else
        local nNow = GetTime()
        local tbNow = os.date("*t", nNow)
        tbNow.day = tbNow.day+1
        tbNow.hour = 0
        tbNow.min = 0
        tbNow.sec = 1
        local nDeadline = os.time(tbNow)+Wedding.nForceDivorceDelayTime
        szTxt = string.format("俠士確定要解除婚姻關係嗎？[-]該申請需花費[FFFE0D]%d元寶[-]，將在[FFFE0D]%s[-]後生效，期間可以找我取消申請。", Wedding.nForceDivorceCost, Lib:TimeDesc2(nDeadline-nNow))
    end
    Dialog:Show({
        Text = szTxt,
        OptList = {
            { Text = "確定解除婚姻關係", Callback = fnConfirm, Param = {} },
        },
    }, me, him)
end

function tbNpc:CancelDismiss()
    local tbRecord = Wedding:_IsDismissing(me.dwID)
    if not tbRecord then
        Npc:ShowErrDlg(me, him, "你沒有申請離婚")
        return
    end

    local function fnConfirm()
        local bOk, szErr = Wedding:CancelDismissReq(me)
        if not bOk and szErr then
            Npc:ShowErrDlg(me, him, szErr)
        end
    end

    local _, nOtherId = unpack(tbRecord)
    local pOther = KPlayer.GetRoleStayInfo(nOtherId) or {szName=""}
    local szTxt = string.format("你正在申請與 [fffe0d]%s[-] 解除婚姻關係，你確定要取消該離婚申請嗎？", pOther.szName)
    Dialog:Show({
        Text = szTxt,
        OptList = {
            { Text = "確認取消離婚申請", Callback = fnConfirm, Param = {} },
        },
    }, me, him) 
end

function tbNpc:ClaimMemorialDayRewards()
    local nOtherId = Wedding:GetLover(me.dwID)
    if not nOtherId then
        Npc:ShowErrDlg(me, him, "你尚未結婚")
        return
    end

    local bOk, szErr, szErrType = Npc:IsTeammateNearby(me, him, true)
    if not bOk then
        if szErrType then
            local tbErrs = {
                no_team = "請先和你的伴侶組隊，再前來領取紀念日獎勵",
                not_captain = "請由隊長來領取紀念日獎勵",
            }
            szErr = tbErrs[szErrType] or szErr
        end
        Npc:ShowErrDlg(me, him, szErr)
        return
    end

    local bOk, szErr = Wedding:ClaimMemorialDayRewardsReq(me)
    if not bOk and szErr then
        Npc:ShowErrDlg(me, him, szErr)
    end
end
