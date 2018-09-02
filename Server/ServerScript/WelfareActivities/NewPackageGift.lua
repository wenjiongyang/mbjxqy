NewPackageGift.OPEN_LEVEL  = 20
NewPackageGift.CREATE_TIME = Lib:ParseDateTime("2016/8/19")
NewPackageGift.IOS_URL     = "itms-apps://itunes.apple.com/app/id1086842482"
NewPackageGift.AND_URL     = "http://dlied5.myapp.com/myapp/6337/jxqy/2017_com.tencent.tmgp.jxqy0819.apk"
NewPackageGift.tbAward     = {{"Gold", 300}, {"Item", 2707, 5}}
---------------------------------以上为开启活动应修改的参数-----------------------------------------------------------------------

NewPackageGift.MAX_COUNT       = 2000
NewPackageGift.GAINED_FLAG     = 30
NewPackageGift.tbScriptDataKey = {"NewPackageGift", "NewPackageGift_Sub"}
NewPackageGift.MAIN_KEY        = NewPackageGift.tbScriptDataKey[1]
NewPackageGift.MAIL_CONTENT    = "    %d年%d月%d號前創建且等級在%d級以上的角色，若前去[c8ff00] [url=openNewPackageUrl:下載最新版本, %s, %s][-]，就將獲得[FFFE0D]%s[-]的獎勵。天下武功，唯快不破。此刻不去下載，更待何時！"
NewPackageGift.LAST_TIME       = 7*24*60*60

function NewPackageGift:ClearLastVersionData()
    for i = 2, 999 do
        local szKey = self.tbScriptDataKey[i]
        if not szKey then
            szKey = "NewPackageGift_Sub" .. (i - 2)
            ScriptData:AddDef(szKey)
        end

        local tbData = ScriptData:GetValue(szKey)
        if not tbData.nCount then
            return
        end

        tbData.nCount = nil
        tbData.tbAccountInfo = nil
    end
end

function NewPackageGift:OpenActivity(nVersion)
    local tbData = ScriptData:GetValue(self.MAIN_KEY)
    if tbData.nVersion and tbData.nVersion >= nVersion then
        return
    end

    self:ClearLastVersionData()
    tbData.nVersion = nVersion
    tbData.nCount = 0
    tbData.nCloseTime = GetTime() + self.LAST_TIME
    tbData.tbAccountInfo = {}
    ScriptData:AddModifyFlag(self.MAIN_KEY)

    self.szMailContent = nil
    self:NotifyPlayer()
    Log("NewPackageGift OpenActivity", nVersion)
end

function NewPackageGift:NotifyPlayer()
    local tbData = ScriptData:GetValue(self.MAIN_KEY)
    local nVersion = tbData.nVersion
    local nCloseTime = tbData.nCloseTime
    local tbAllPlayer = KPlayer.GetAllPlayer()
    for _, pPlayer in ipairs(tbAllPlayer) do
        if pPlayer.dwCreateTime < self.CREATE_TIME and pPlayer.nLevel >= self.OPEN_LEVEL then
            pPlayer.CallClientScript("NewPackageGift:OnSyncState", self.tbAward, nVersion, nCloseTime, true)
            local nData, szDataKey = self:GetAccountData(pPlayer.szAccount)
            nData = KLib.SetBit(nData, pPlayer.nFaction, 1)
            self:SavePlayerData(pPlayer.szAccount, nData, szDataKey)
            self:SendEmail(pPlayer.dwID)
        end
    end
    ScriptData:AddModifyFlag(self.MAIN_KEY)
end

function NewPackageGift:FormatMailContent()
    local tbDate = os.date("*t", self.CREATE_TIME)
    local szAwadDesc = table.concat( Lib:GetAwardDesCount2(self.tbAward), "、")
    return string.format(self.MAIL_CONTENT, tbDate.year, tbDate.month, tbDate.day, self.OPEN_LEVEL, self.IOS_URL, self.AND_URL, szAwadDesc)
end

function NewPackageGift:SendEmail(dwID)
    self.szMailContent = self.szMailContent or self:FormatMailContent()

    Mail:SendSystemMail({
        To = dwID,
        Title = "新版本更換",
        Text = self.szMailContent,
        From = "",
    })
end

function NewPackageGift:CheckActivityState()
    local tbData = ScriptData:GetValue(self.MAIN_KEY)
    return tbData.nVersion and tbData.nCloseTime > GetTime()
end

function NewPackageGift:GetAccountData(szAccount)
    for i = 1, 999 do
        local szKey = self.tbScriptDataKey[i]
        if not szKey then
            szKey = "NewPackageGift_Sub" .. (i - 2)
            table.insert(self.tbScriptDataKey, szKey)
            ScriptData:AddDef(szKey)
        end

        local tbData = ScriptData:GetValue(szKey)
        tbData.nCount = tbData.nCount or 0
        tbData.tbAccountInfo = tbData.tbAccountInfo or {}
        if tbData.tbAccountInfo[szAccount] then
            return tbData.tbAccountInfo[szAccount], szKey
        end

        if tbData.nCount < self.MAX_COUNT then
            tbData.nCount = tbData.nCount + 1
            tbData.tbAccountInfo[szAccount] = 0
            ScriptData:AddModifyFlag(szKey)
            return tbData.tbAccountInfo[szAccount], szKey
        end
    end
end

function NewPackageGift:SavePlayerData(szAccount, nData, szSaveKey)
    local tbData = ScriptData:GetValue(szSaveKey)
    tbData.tbAccountInfo[szAccount] = nData
end

function NewPackageGift:CheckCanGain(pPlayer)
    if not self:CheckActivityState() then
        return
    end

    if pPlayer.dwCreateTime >= self.CREATE_TIME then
        return
    end

    if pPlayer.nLevel < self.OPEN_LEVEL then
        return
    end

    local nData = self:GetAccountData(pPlayer.szAccount)
    return KLib.GetBit(nData, self.GAINED_FLAG) == 0
end

function NewPackageGift:OnLevelUp(nNewLevel)
    if nNewLevel == self.OPEN_LEVEL and self:CheckCanGain(me) then
        self:SyncData(me)
    end
end

function NewPackageGift:OnLogin(pPlayer)
    if not self:CheckCanGain(pPlayer) then
        pPlayer.CallClientScript("NewPackageGift:OnSyncState")
        return
    end

    self:SyncData(pPlayer)
end

function NewPackageGift:SyncData(pPlayer)
    local tbData = ScriptData:GetValue(self.MAIN_KEY)
    pPlayer.CallClientScript("NewPackageGift:OnSyncState", self.tbAward, tbData.nVersion, tbData.nCloseTime, true)

    local nData, szDataKey = self:GetAccountData(pPlayer.szAccount)
    if KLib.GetBit(nData, pPlayer.nFaction) == 0 then
        nData = KLib.SetBit(nData, pPlayer.nFaction, 1)
        self:SavePlayerData(pPlayer.szAccount, nData, szDataKey)
        ScriptData:AddModifyFlag(szDataKey)
        self:SendEmail(pPlayer.dwID)
    end
end

function NewPackageGift:TryGainGift(nVersion)
    local bCanGain = self:CheckCanGain(me)
    if not bCanGain then
        me.CenterMsg("活動已過期或已領取")
        return
    end

    local tbData = ScriptData:GetValue(self.MAIN_KEY)
    if tbData.nVersion ~= nVersion then
        me.CenterMsg("該版本無法參加活動")
        return
    end

    local nData, szDataKey = self:GetAccountData(me.szAccount)
    nData = KLib.SetBit(nData, self.GAINED_FLAG, 1)
    self:SavePlayerData(me.szAccount, nData, szDataKey)
    ScriptData:AddModifyFlag(szDataKey)

    me.SendAward(self.tbAward, nil, 1, Env.LogWay_NewPackageGift)
    me.CallClientScript("NewPackageGift:OnSyncState")
    Log("NewPackageGift TryGainGift", me.dwID, nVersion)
end