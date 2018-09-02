local tbNpc   = Npc:GetClass("YueLaoNpc")
function tbNpc:OnDialog()
    local nOpenDay, nOpenTime = Wedding:CheckTimeFrame()
    if nOpenDay then
         Dialog:Show(
        {
            Text = string.format("千里姻緣一線牽，少俠可是來尋紅線的另一頭？\n[FFFE0D]結婚系統將在%d天后開放！[-]", nOpenDay),
            OptList = {},
        }, me, him)
        return 
    end
    -- 主城常驻NPC
    if him.szScriptParam == "CityNpc" then
        local tbOptList = {
            { Text = "預定婚禮", Callback = self.OrderWedding, Param = {self, me.dwID} };
            { Text = "參加婚宴", Callback = self.EnterWedding, Param = {self, me.dwID} };
        }
        local nLevel, tbPlayerBookInfo, nOpen = Wedding:CheckPlayerHadBook(me.dwID)
        if nLevel then
            local tbMapSetting = Wedding.tbWeddingLevelMapSetting[nLevel]
            if tbMapSetting and tbMapSetting.fnCheckBookIsOpen(nOpen) then
                table.insert(tbOptList, 1, { Text = "開始舉行婚禮", Callback = self.TryStartWedding, Param = {self, me.dwID} })
            end
        end
        local nLover = Wedding:GetLover(me.dwID)
        if nLover then
            table.insert(tbOptList, { Text = "更改夫妻稱號", Callback = self.ChangeTitle, Param = {self} })
        end
        Dialog:Show(
        {
            Text = "千里姻緣一線牽，少俠可是來尋紅線的另一頭？",
            OptList = tbOptList,
        }, me, him)
    -- 婚礼现场NPC
    elseif him.szScriptParam == "FubenNpc" then
        local tbInst = Fuben.tbFubenInstance[him.nMapId]
        if tbInst then
            tbInst:OnDialogYueLao(me, him)
        end
    end
	
end

function tbNpc:TryStartWedding(dwID)
    local pPlayer = KPlayer.GetPlayerObjById(dwID)
    if not pPlayer then
        return
    end
    local nLevel = Wedding:CheckPlayerHadBook(dwID)
    local tbMapSetting = Wedding.tbWeddingLevelMapSetting[nLevel]
    if not tbMapSetting then
        return
    end
    if tbMapSetting.szStartWeddingTip then
        pPlayer.MsgBox(tbMapSetting.szStartWeddingTip, {{"舉行婚禮", self.StartWedding, self, dwID}, {"取消"}})
    else
        self:StartWedding(dwID)
    end
end

function tbNpc:StartWedding(dwID)
    local pPlayer = KPlayer.GetPlayerObjById(dwID)
    if not pPlayer then
        return
    end
    Wedding:TryStartBookWedding(pPlayer)
end

function tbNpc:OrderWedding(dwID)
	local pPlayer = KPlayer.GetPlayerObjById(dwID)
	if not pPlayer then
    	return
	end
    if not Wedding:CheckOpen() then
        pPlayer.CenterMsg("婚禮預定將擇良日開放，敬請期待！")
        return
    end
	pPlayer.CallClientScript("Ui:OpenWindow", "WeddingBookPanel")
end

function tbNpc:EnterWedding(dwID)
    local pPlayer = KPlayer.GetPlayerObjById(dwID)
    if not pPlayer then
        return
    end
    if not Wedding.tbWeddingMap or not next(Wedding.tbWeddingMap) then
        pPlayer.CenterMsg("暫無正在舉行的婚禮", true)
        return
    end
    pPlayer.CallClientScript("Ui:OpenWindow", "WeddingEnterPanel")
end

--------

function tbNpc:ChangeTitle()
    local nOtherId = Wedding:GetLover(me.dwID)
    if not nOtherId then
        Npc:ShowErrDlg(me, him, "你尚未結婚")
        return
    end

    local bOk, szErr = Wedding:CheckLoveTeam(me, true)
    if not bOk then
        Npc:ShowErrDlg(me, him, szErr)
        return
    end

    bOk, szErr = Npc:IsTeammateNearby(me, him, true)
    if not bOk then
        Npc:ShowErrDlg(me, him, szErr)
        return
    end

    local pOther = KPlayer.GetRoleStayInfo(nOtherId)
    local szHusbandName, szWifeName = me.szName, pOther.szName
    if me.GetUserValue(Wedding.nSaveGrp, Wedding.nSaveKeyGender)~=Gift.Sex.Boy then
        szHusbandName, szWifeName = szWifeName, szHusbandName
    end
    me.CallClientScript("Ui:OpenWindow", "MarriageTitlePanel", szHusbandName, szWifeName)
end