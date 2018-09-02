NewInformation.DEFAULT_SCRIPT = "NewInformation"
NewInformation.tbAllActivity = NewInformation.tbAllActivity or {}
function NewInformation:GetValueKey(szKey)
    local tbInfo  = self.tbAllActivity[szKey]
    if not tbInfo then
        return
    end

    return self.tbActivity[szKey] and "NewInfo_" .. szKey or self.DEFAULT_SCRIPT
end

function NewInformation:OnStartUp()
    for szKey, tbInfo in pairs(self.tbActivity) do
        self.tbAllActivity[szKey] = tbInfo
        ScriptData:AddDef(self:GetValueKey(szKey))
    end

    local tbMsgInfoData = ScriptData:GetValue(self.DEFAULT_SCRIPT)
    for szKey, tbData in pairs(tbMsgInfoData) do
        self.tbAllActivity[szKey] = tbData.tbSetting
    end

    self:CheckActivityData()
    self.tbNewClientActSetting = {}--用指令修改的客户端活动配置
end

function NewInformation:GetValue(szKey)
    local szValueKey = self:GetValueKey(szKey)
    if not szValueKey then
        return
    end

    local tbData = ScriptData:GetValue(szValueKey)
    if not self.tbActivity[szKey] then
        tbData[szKey] = tbData[szKey] or {}
        return tbData[szKey], szValueKey
    end
    return tbData, szValueKey
end

-- 可用指令发送最新消息，例：
-- NewInformation:AddInfomation("Cmd_NewInfo", GetTime() + 24*60*60, {"消息内容"}, {szTitle = "消息标题", nReqLevel = 10, szBtnName = "哈哈", szBtnTrap = "[url=openwnd:test, Partner]"})
--指令发送的文本类最新消息，Cmd_NewInfo不在配置表中，相同key会覆盖前面消息
function NewInformation:AddInfomation(szKey, nValidTime, tbActData, tbSetting) -- nValidTime: 有效时间(单位：秒)
    if not (szKey and nValidTime and tbActData and nValidTime > GetTime()) then
        Log("[NewInformation AddInfomation] Err", szKey, nValidTime)
        return
    end

    if not (self.tbActivity[szKey] or tbSetting) then
        Log("[NewInformation AddInfomation] No Setting", szKey, nValidTime)
        return
    end

    local bMsgType = not self.tbActivity[szKey]
    if bMsgType then
        self.tbAllActivity[szKey] = self.tbAllActivity[szKey] or {}
        self.tbAllActivity[szKey] = tbSetting
    end

    local tbInfoData, szSaveKey = self:GetValue(szKey)
    tbInfoData.nSession = tbInfoData.nSession or 0
    if not tbInfoData.nValidTime or tbInfoData.nValidTime ~= nValidTime then
        tbInfoData.nSession = tbInfoData.nSession + 1
    end
    tbInfoData.nValidTime = nValidTime
    tbInfoData.tbData     = tbActData
    tbInfoData.tbSetting  = tbSetting
    ScriptData:AddModifyFlag(szSaveKey)
    KPlayer.BoardcastScript(1, "NewInformation:OnAddInformation", szKey, tbInfoData.nSession, nValidTime, tbSetting)

    Log("NewInformation AddInfomation", szKey, nValidTime, tbInfoData.nSession, self.tbActivity[szKey] and "Normal" or "Message")
    return true
end

--删除最新消息，注意，只适用于服务端推送的最新消息
function NewInformation:RemoveInfomation(szKey)
    self:CheckActivityData()

    local tbInfoData, szSaveKey = self:GetValue(szKey)
    if not tbInfoData then
        Log("ERROR IN NewInformation DeleteInformation Not Found Key", szKey)
        return
    end

    if not tbInfoData.tbData or tbInfoData.nValidTime <= GetTime() then
        Log("Warning In NewInformation DeleteInformation", szKey, type(tbInfoData.tbData), tbInfoData.nValidTime or 0, GetTime())
        return
    end

    tbInfoData.nValidTime = 0
    tbInfoData.tbData = nil
    ScriptData:AddModifyFlag(szSaveKey)
    KPlayer.BoardcastScript(1, "NewInformation:OnRemoveInformation", szKey)
    Log("NewInformation RemoveInfomation", szKey)
    return true
end

--修改客户端配置，一般用于客户端配置错误
function NewInformation:ChangeClientSetting(szKey, tbSetting)
    self.tbNewClientActSetting[szKey] = tbSetting
    KPlayer.BoardcastScript(1, "NewInformation:OnSettingChange", {[szKey] = tbSetting})
end

function NewInformation:OnPlayerLogin(pPlayer)
    self:CheckActivityData()

    local tbSyncData = {}
    for szKey, _ in pairs(self.tbAllActivity) do
        local tbActData = self:GetValue(szKey)
        if tbActData and tbActData.tbData then
            tbSyncData[szKey] = { tbActData.nSession, tbActData.nValidTime, tbActData.tbSetting }
        end
    end
    pPlayer.CallClientScript("NewInformation:OnSyncInfoSession", tbSyncData, self.tbNewClientActSetting)
end

function NewInformation:CheckActivityData()
    for szKey, _ in pairs(self.tbAllActivity) do
        local tbActData, szSaveKey = self:GetValue(szKey)
        if tbActData.nValidTime and tbActData.nValidTime <= GetTime() then
            tbActData.tbData = nil
            ScriptData:AddModifyFlag(szSaveKey)
        end
    end
    ScriptData:AddModifyFlag(self.DEFAULT_SCRIPT)
end

function NewInformation:OnTryUpdateData(szKey, nSession)
    if not szKey or not nSession then
        return
    end

    local tbActData = self:GetValue(szKey)
    if not tbActData or tbActData.nSession ~= nSession then
        return
    end

    self:CheckActivityData()
    if not tbActData.tbData or  tbActData.nValidTime <= GetTime() then
        me.CenterMsg("消息已過期")
        return
    end

    me.CallClientScript("NewInformation:OnSyncActData", szKey, tbActData)
end

function NewInformation:GetInformation(szKey)
    if Lib:IsEmptyStr(szKey) then
        return
    end

    self:CheckActivityData()
    local tbActData = self:GetValue(szKey)
    if not tbActData or not tbActData.tbData or tbActData.nValidTime <= GetTime() then
        return
    end
    return {nValidTime = tbActData.nValidTime, tbData = tbActData.tbData, tbSetting = self.tbAllActivity[szKey]}
end