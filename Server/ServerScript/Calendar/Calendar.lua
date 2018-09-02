Calendar.tbState = Calendar.tbState or {}
function Calendar:OnActivityBegin(szKey)
	self:OnActivityStateChange(szKey, 1)
end

function Calendar:OnActivityEnd(szKey)
	self:OnActivityStateChange(szKey, 0)
end

function Calendar:OnActivityStateChange(szKey, nState)
	if Lib:IsEmptyStr(szKey) then
		return
	end

	if self.tbState[szKey] == nState then
		return
	end
	self.tbState[szKey] = nState

	KPlayer.BoardcastScript(1, "Calendar:OnActivityStateChange", szKey, nState);
end

function Calendar:OnPlayerLogin(pPlayer)
	self:CheckRankboard(pPlayer)
	pPlayer.CallClientScript("Calendar:OnSyncActivityState", self.tbState)
end

function Calendar:IsActivityInOpenState(szKey)
	return self.tbState[szKey] == 1
end

----------------------------荣誉成就----------------------------
Calendar.tbPlayerLastDiv = {}
function Calendar:OnStartUp()
	self.nLocalMonth = Lib:GetLocalMonth()
    self:CheckMonthRank()
end

function Calendar:CheckMonth()
	if self.nLocalMonth == Lib:GetLocalMonth() then
		return
	end

	self.nLocalMonth = Lib:GetLocalMonth()
	local tbPlayer = KPlayer.GetAllPlayer()
	for _, pPlayer in ipairs(tbPlayer) do
		self:CheckData(pPlayer)
	end
    self:CheckMonthRank()
end

--因为排行榜上线时间比段位功能晚，所以这里要检查一下
function Calendar:CheckRankboard(pPlayer)
    local pRank = KRank.GetRankBoard("WulinHonor")
    if not pRank then
        return
    end

    local tbInfo = pRank.GetRankInfoByID(pPlayer.dwID)
    if tbInfo then
        return
    end

    local nHonor = 0
    for szKey, tbInfo in pairs(self.tbHonorInfo) do
        local nDivision = self:GetDivision(pPlayer, szKey)
        nHonor = nHonor + (self.DIVISION_HOUR[nDivision] or 0)
    end
    if nHonor == 0 then
        return
    end
    self:UpdateRankboard(pPlayer.dwID, nHonor)
    Log("Calendar CheckRankboard", pPlayer.dwID, nHonor)
end

function Calendar:OnDelayCmdEnd()
    self:CheckData(me)
end

function Calendar:CheckData(pPlayer)
	local nDataMonth = pPlayer.GetUserValue(self.GROUP, self.DATA_MONTH)
	local nCurMonth  = Lib:GetLocalMonth()
	if nDataMonth == 0 or nDataMonth == nCurMonth then
		pPlayer.SetUserValue(self.GROUP, self.DATA_MONTH, nCurMonth)
		return
	end
	local nHonor = 0
	local szLog = ""
	local tbAllAward = {}
	for szKey, tbInfo in pairs(self.tbHonorInfo) do
		local nDivision = self:GetDivision(pPlayer, szKey)
		for i = tbInfo.nJoinTimesKey, tbInfo.nJoinTimesKey + #(tbInfo.Operation) - 1 do
			pPlayer.SetUserValue(self.GROUP, i, 0)
		end
		local tbAward = self.tbDivisionAward[nDivision] or {}
		Lib:MergeTable(tbAllAward, tbAward)
		szLog = string.format("%s|%s:%d", szLog, szKey, nDivision)
	end
	self.tbPlayerLastDiv[pPlayer.dwID] = {}
	pPlayer.SetUserValue(self.GROUP, self.DATA_MONTH, nCurMonth)
	if #tbAllAward > 0 then
		local tbMail = {
            To = pPlayer.dwID,
            Title = "武林榮譽",
            From = "獨孤劍",
            Text = "      尊敬的俠士，恭喜你在本月出類拔萃，成為武林榮譽榜上有名的人物。特備薄禮聊表敬意，還請俠士此後多加努力，更上一層樓！",
            tbAttach = tbAllAward,
            nLogReazon = Env.LogWay_WulinHonor,
        };
        Mail:SendSystemMail(tbMail)
	end
	Log("Calendar SendMonthAwrd:", pPlayer.dwID, nDataMonth, nHonor, szLog)
	return true
end

function Calendar:OnCompleteAct_Delay(nTime, dwID, szAct, ...)
    local pPlayer = KPlayer.GetPlayerObjById(dwID)
    if not pPlayer then
        return
    end
    local nDataMonth = pPlayer.GetUserValue(self.GROUP, self.DATA_MONTH)
    local nCmdMonth  = Lib:GetLocalMonth(nTime)
    if nDataMonth ~= 0 and nDataMonth ~= nCmdMonth then
        Log("Calendar OnCompleteAct_Delay Month Err:", nCmdMonth, nDataMonth, dwID, szAct, ...)
        return
    end

    local _, nNewDiv = self:OnCompleteActDirect(dwID, szAct, ...)
    if not nNewDiv or nNewDiv < #self.tbDivisionKey then
        return
    end
    if nCmdMonth ~= Lib:GetLocalMonth() then
        Log("Calendar OnCompleteAct_Delay MonthRank Err:" , nCmdMonth, dwID, szAct, ...)
        return
    end

    self:UpdateMonthRank(pPlayer.dwID, szAct)
end

function Calendar:OnCompleteAct(dwID, szAct, ...)
    local pPlayer = KPlayer.GetPlayerObjById(dwID)
    if pPlayer then
        local nDataMonth = pPlayer.GetUserValue(self.GROUP, self.DATA_MONTH)
        local nCurMonth  = Lib:GetLocalMonth()
        if nDataMonth ~= 0 and nDataMonth ~= nCurMonth then
            Log("Calendar OnCompleteAct Month Err:", dwID, szAct, ...)
            return
        end
    end
    local _, nNewDiv = self:OnCompleteActDirect(dwID, szAct, ...)
    if not nNewDiv or nNewDiv < #self.tbDivisionKey then
        return
    end
    self:UpdateMonthRank(dwID, szAct)
end

function Calendar:OnCompleteActDirect(dwID, szAct, ...)
	if not self.tbHonorInfo[szAct] then
		Log(debug.traceback(), dwID, szAct)
		return
	end

	if self.tbUnopenHonor[szAct] then
		Log("Calendar OnCompleteAct UnopenAct", dwID, szAct, ...)
		return
	end

	local pPlayer = KPlayer.GetPlayerObjById(dwID)
	if not pPlayer then
		local tbParam = {...}
		local szCmd = string.format("Calendar:OnCompleteAct_Delay(%d, me.dwID, '%s'", GetTime(), szAct)
		local szLog = string.format("Calendar OnCompleteAct By DelayCmd: %s, %d", szAct, dwID)
		for _, param in ipairs(tbParam) do
			local szType = type(param) == "number" and "%d" or "'%s'"
			szCmd = string.format("%s, " .. szType, szCmd, param)
			szLog = string.format("%s, " .. szType, szLog, param)
		end
		szCmd = szCmd .. ")"
		KPlayer.AddDelayCmd(dwID, szCmd, szLog)
		return
	end

	if pPlayer.nLevel < self.JOIN_LV then
		return
	end

	self.tbPlayerLastDiv[dwID] = self.tbPlayerLastDiv[dwID] or {}
	self.tbPlayerLastDiv[dwID][szAct] = self.tbPlayerLastDiv[dwID][szAct] or self:GetDivision(pPlayer, szAct)
	local nLastDiv = self.tbPlayerLastDiv[dwID][szAct]
	self:ChangeHonorData(pPlayer, szAct, ...)
	local nNewDiv = (nLastDiv >= #self.tbDivisionKey) and nLastDiv or self:GetDivision(pPlayer, szAct, nLastDiv)
	if nNewDiv > nLastDiv then
		self.tbPlayerLastDiv[dwID][szAct] = nNewDiv
		local nAddHonor = (nLastDiv > 0) and self.DIVISION_HOUR[nLastDiv] or 0
		nAddHonor = self.DIVISION_HOUR[nNewDiv] - nAddHonor
		self:UpdateRankboard(pPlayer.dwID, nAddHonor)
		self:SendNotifyMsg(pPlayer, szAct, nNewDiv, ...)
		pPlayer.CallClientScript("Calendar:OnDivisionChange", szAct, nNewDiv)
	end
	Log("Calendar ChangeHonorData", pPlayer.dwID, szAct, nLastDiv, nNewDiv, ...)
    return true, nNewDiv > nLastDiv and nNewDiv
end

function Calendar:UpdateRankboard(nPlayerId, nValue)
	local pRank = KRank.GetRankBoard("WulinHonor")
    if not pRank then
    	return
    end

    local tbInfo = pRank.GetRankInfoByID(nPlayerId)
    if tbInfo then
    	nValue = tbInfo.nLowValue + nValue
    end

	pRank.UpdateValueByID(nPlayerId, nValue)
	Log("Calendar UpdateRankboard", nPlayerId, nValue)
end

function Calendar:ChangeHonorData(pPlayer, szAct, ...)
	local tbHonorInfo = self.tbHonorInfo[szAct]
	local nJoinKey    = tbHonorInfo.nJoinTimesKey
	local nJoinTimes  = pPlayer.GetUserValue(self.GROUP, nJoinKey) + 1
	pPlayer.SetUserValue(self.GROUP, nJoinKey, nJoinTimes)

	if self["ChangeHonorData_" .. szAct] then
		self["ChangeHonorData_" .. szAct](self, pPlayer, szAct, ...)
		return
	end

	local tbParam  = {...}
	local nParam   = tonumber(tbParam[1])
	if nParam <= 0 then
		return
	end
	local nSaveKey = nJoinKey + 1
	local nCurPam  = pPlayer.GetUserValue(self.GROUP, nSaveKey)
	if szAct == "HuaShanLunJian" then
		nParam = nCurPam == 0 and nParam or math.min(nCurPam, nParam)
	else
		nParam = math.max(nCurPam, nParam)
	end
	if nCurPam == 0 or nCurPam ~= nParam then
		pPlayer.SetUserValue(self.GROUP, nSaveKey, nParam)
	end
end

function Calendar:ChangeHonorData_Battle(pPlayer, szAct, nRank, nSubType)
	local tbHonorInfo = self.tbHonorInfo[szAct]
	local nSaveKey    = tbHonorInfo.nJoinTimesKey
	if nSubType ~= 1 and nSubType ~= 2 and nSubType ~= 3 then
		Log(debug.traceback(), nSubType)
		return
	end
	nSaveKey = nSaveKey + nSubType
	local nCurRank = pPlayer.GetUserValue(self.GROUP, nSaveKey)
	if nCurRank == 0 or nCurRank > nRank then
		pPlayer.SetUserValue(self.GROUP, nSaveKey, nRank)
	end
end

function Calendar:ChangeHonorData_FactionBattle(pPlayer, szAct, nRank, nJoinPlayerCount)
	local nSaveKey   = self.tbHonorInfo[szAct].nJoinTimesKey
	local nJoinTimes = pPlayer.GetUserValue(self.GROUP, nSaveKey)
	local nOffset    = 0
	if nRank <= 16 then
		nOffset  = 1
		nSaveKey = nSaveKey + nOffset
		local nCurRank = pPlayer.GetUserValue(self.GROUP, nSaveKey)
		if nCurRank == 0 or nCurRank > nRank then
			pPlayer.SetUserValue(self.GROUP, nSaveKey, nRank)
		end
	elseif nRank <= math.floor(nJoinPlayerCount*0.6) then
		nOffset  = 2
		nSaveKey = nSaveKey + nOffset
		local nB60Times = pPlayer.GetUserValue(self.GROUP, nSaveKey) + 1
		pPlayer.SetUserValue(self.GROUP, nSaveKey, nB60Times)
	end
end

function Calendar:SendNotifyMsg(pPlayer, szKey, nDivision, _, nParam2)
    nParam2 = szKey == "Battle" and nParam2 or 1
    local tbHonorInfo = self.tbHonorInfo[szKey]
    if not tbHonorInfo then
        return
    end

    local szDivisionKey = self.tbDivisionKey[nDivision]
    if not szDivisionKey then
        return
    end

    local tbActMsg     = self.tbActMsgInfo[szKey]
    local nRankMsgType = (tbActMsg[szDivisionKey] or {})[nParam2]
    if not nRankMsgType then
        return
    end

    local tbDivisionInfo = tbHonorInfo[szDivisionKey]
    local szRank         = string.format(self.tbMsgFormatInfo[nRankMsgType], tbDivisionInfo[nParam2 + 1])
    local szActName      = tbActMsg.tbName[nParam2]
    local szNotifyMsg    = string.format("恭喜俠士「%s」參加%s%s，成功晉級該活動本月%s段武林榮譽。", pPlayer.szName, szActName, szRank, self.tbDivisionName[nDivision])
    if pPlayer.dwKinId > 0 then
        ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.Kin, szNotifyMsg, pPlayer.dwKinId)
    end
    ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.Friend, szNotifyMsg, pPlayer.dwID)
end

function Calendar:UpdateMonthRank(nPlayerId, szAct)
    local tbData = ScriptData:GetValue("HonorMonthRank")
    tbData.tbRankInfo[nPlayerId] = tbData.tbRankInfo[nPlayerId] or {nChangeTime = GetTime(), tbPlatnumAct = {}}
    tbData.tbRankInfo[nPlayerId].tbPlatnumAct[szAct] = true
    ScriptData:AddModifyFlag("HonorMonthRank")
    Log("Calendar UpdateMonthRank", nPlayerId, szAct)
end

--[[
HonorMonthRank:
nMonth,
tbRankInfo = {
    [nPlayerId] = {nChangeTime, (nKinId, szKinName, szName, nHonorLevel,) tbPlatnumAct = {Battle = true, TeamBattle = true}}
}
]]--
function Calendar:CheckMonthRank()
    local tbData      = ScriptData:GetValue("HonorMonthRank")
    local nDataMonth  = tbData.nMonth
    local nLocalMonth = Lib:GetLocalMonth()
    if not nDataMonth then
        tbData.nMonth = nLocalMonth
        tbData.tbRankInfo = {}
        ScriptData:AddModifyFlag("HonorMonthRank")
        return
    end
    if nDataMonth == nLocalMonth then
        return
    end

    local tbList = {}
    for nPlayerId, tbInfo in pairs(tbData.tbRankInfo) do
        local pPlayer = KPlayer.GetRoleStayInfo(nPlayerId)
        if pPlayer then
            local tbCompleteInfo = {nPlayerId = nPlayerId, nChangeTime = tbInfo.nChangeTime, nKinId = pPlayer.dwKinId, szName = pPlayer.szName, nHonorLevel = pPlayer.nHonorLevel, tbPlatnumAct = tbInfo.tbPlatnumAct}
            local pKinData = Kin:GetKinById(pPlayer.dwKinId or 0) or {}
            tbCompleteInfo.szKinName = pKinData.szName or ""
            table.insert(tbList, tbCompleteInfo)
        end
    end
    if #tbList > 0 then
        table.sort(tbList, function (a, b)
            local nPlatnumA = Lib:CountTB(a.tbPlatnumAct)
            local nPlatnumB = Lib:CountTB(b.tbPlatnumAct)
            if (nPlatnumA > nPlatnumB) or (nPlatnumA == nPlatnumB and a.nChangeTime < b.nChangeTime) then
                return true
            end
        end)
        NewInformation:AddInfomation("HonorMonthRank", GetTime() + 5*24*3600, tbList)
    end
    tbData.nMonth = nLocalMonth
    tbData.tbRankInfo = {}
    ScriptData:AddModifyFlag("HonorMonthRank")
    Log("Calendar SendMonthRank NewInformation", nDataMonth, #tbList)
end

PlayerEvent:RegisterGlobal("OnDelayCmdEnd", Calendar.OnDelayCmdEnd, Calendar)