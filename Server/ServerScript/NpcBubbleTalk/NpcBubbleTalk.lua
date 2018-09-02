NpcBubbleTalk.Def = {
	nInterval = 15,
	nDuration = 5,
	nRange = 500,
}

NpcBubbleTalk.tbTasks = NpcBubbleTalk.tbTasks or {}

function NpcBubbleTalk:_GetIndex(nMapId, nNpcTemplateId, szContent, nBeginTime, nEndTime)
	for i, tbTask in ipairs(self.tbTasks) do
		if tbTask.nMapId==nMapId and tbTask.nNpcTemplateId==nNpcTemplateId and tbTask.szContent==szContent and
		 tbTask.nBeginTime == nBeginTime and tbTask.nEndTime == nEndTime then
			return i
		end
	end
end

function NpcBubbleTalk:_IsExist(nMapId, nNpcTemplateId, szContent, nBeginTime, nEndTime)
	return self:_GetIndex(nMapId, nNpcTemplateId, szContent, nBeginTime, nEndTime)~=nil
end

function NpcBubbleTalk:_GetState(nBeginTime, nEndTime, nBeginDayTime, nEndDayTime)
	local nNow = GetTime()
	if nNow>nEndTime then
		return "expired"
	end
	if nNow<nBeginTime then
		return "waiting"
	end

	local nNowDayTime = Lib:GetLocalDayTime(nNow)
	if nNowDayTime<=nEndDayTime and nNowDayTime>=nBeginDayTime then
		return "running"
	end
	return "waiting"
end

function NpcBubbleTalk:_GetNpcIds(nMapId, nNpcTemplateId)
	local tbAllNpcs = KNpc.GetMapNpc(nMapId)
	local tbNpcIds = {}
	for _, pNpc in ipairs(tbAllNpcs) do
		if pNpc.nTemplateId==nNpcTemplateId then
			table.insert(tbNpcIds, pNpc.nId)
		end
	end
	return tbNpcIds
end

function NpcBubbleTalk:AddByTimestamp(nMapId, nNpcTemplateId, szContent, nBeginTime, nEndTime, nBeginDayTime, nEndDayTime)
	if self:_IsExist(nMapId, nNpcTemplateId, szContent, nBeginTime, nEndTime) then
		Log("[x] NpcBubbleTalk:AddByTimestamp, already exist", nMapId, nNpcTemplateId, szContent)
		return false
	end
	
	if not nBeginTime or not nEndTime then
		Log("[x] NpcBubbleTalk:AddByTimestamp, time format error", tostring(nBeginTime), tostring(nEndTime))
		return false
	end

	if nBeginTime>=nEndTime then
		Log("[x] NpcBubbleTalk:AddByTimestamp, nBeginTime>=nEndTime", nBeginTime, nEndTime)
		return false
	end

	if nBeginDayTime>=nEndDayTime then
		Log("[x] NpcBubbleTalk:AddByTimestamp, nBeginDayTime>=nEndTime", nBeginDayTime, nEndDayTime)
		return false
	end

	if self:_GetState(nBeginTime, nEndTime, nBeginDayTime, nEndDayTime)=="expired" then
		Log("[x] NpcBubbleTalk:AddByTimestamp, already expired", nEndTime)
		return false
	end

	local tbNpcIds = self:_GetNpcIds(nMapId, nNpcTemplateId)
	if not next(tbNpcIds) then
		Log("[x] NpcBubbleTalk:AddByTimestamp, npc not found", nMapId, nNpcTemplateId)
		return false
	end

	table.insert(self.tbTasks, {
		nMapId = nMapId,
		nNpcTemplateId = nNpcTemplateId,
		szContent = szContent,
		nBeginTime = nBeginTime,
		nEndTime = nEndTime,
		nBeginDayTime = nBeginDayTime,
		nEndDayTime = nEndDayTime,
		tbNpcIds = tbNpcIds,
	})
	return true
end

-- szBeginTime: 开始日期
-- szEndTime: 结束日期
-- szBeginDayTime: 每天开始时间
-- szEndDayTime: 每天结束时间
function NpcBubbleTalk:Add(nMapId, nNpcTemplateId, szContent, szBeginTime, szEndTime, szBeginDayTime, szEndDayTime)
	local nBeginTime = Lib:ParseDateTime(szBeginTime or "")
	local nEndTime = Lib:ParseDateTime(szEndTime or "")
	local nBeginDayTime = szBeginDayTime and Lib:ParseTodayTime(szBeginDayTime) or 0
	local nEndDayTime = szEndDayTime and Lib:ParseTodayTime(szEndDayTime) or 3600*24
	local bOk = self:AddByTimestamp(nMapId, nNpcTemplateId, szContent, nBeginTime, nEndTime, nBeginDayTime, nEndDayTime)
	Log("NpcBubbleTalk:Add", nMapId, nNpcTemplateId, szContent, szBeginTime, szEndTime, nBeginDayTime, nEndDayTime, tostring(bOk))
end

function NpcBubbleTalk:Remove(nMapId, nNpcTemplateId, szContent, nBeginTime, nEndTime)
	local nIdx = self:_GetIndex(nMapId, nNpcTemplateId, szContent, nBeginTime, nEndTime)
	if not nIdx then
		return
	end
	table.remove(self.tbTasks, nIdx)
end

local nNextCheckTime = 0
function NpcBubbleTalk:Active()
	local nNow = GetTime()
	if nNow<nNextCheckTime then
		return
	end
	nNextCheckTime = nNow+self.Def.nInterval

	self:_DoTasks()
end

function NpcBubbleTalk:_DoTasks()
	for i=#self.tbTasks, 1, -1 do
		local tbTask = self.tbTasks[i]
		local szState = self:_GetState(tbTask.nBeginTime, tbTask.nEndTime, tbTask.nBeginDayTime, tbTask.nEndDayTime)
		if szState=="expired" then
			Log("NpcBubbleTalk:_DoTasks, expired", tbTask.nMapId, tbTask.nNpcTemplateId, tbTask.szContent)
			table.remove(self.tbTasks, i)
		elseif szState=="running" then
			self:_DoTask(tbTask)
		end
	end
end

function NpcBubbleTalk:_DoTask(tbTask)
	local tbNpcIds = tbTask.tbNpcIds
	for _, nNpcId in ipairs(tbNpcIds) do
		local tbPlayers = KNpc.GetAroundPlayerList(nNpcId, self.Def.nRange) or {}
		for _, pPlayer in pairs(tbPlayers) do
			pPlayer.CallClientScript("Ui:NpcBubbleTalk", {nNpcId}, tbTask.szContent, self.Def.nDuration)
		end
	end
end

function NpcBubbleTalk:ManualTalk(nNpcId, szContent)
	if not szContent or szContent=="" then
		return
	end

	local tbPlayers = KNpc.GetAroundPlayerList(nNpcId, self.Def.nRange) or {}
	for _, pPlayer in pairs(tbPlayers) do
		pPlayer.CallClientScript("Ui:NpcBubbleTalk", {nNpcId}, szContent, self.Def.nDuration)
	end
end