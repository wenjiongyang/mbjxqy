Activity.tbScheduleCallBack = Activity.tbScheduleCallBack or {};
Activity.tbCachePlayerActivityData = Activity.tbCachePlayerActivityData or {};

function Activity:CheckVersion(tbInfo)
	if (tbInfo.version_tx == 1 and version_tx) or
		(tbInfo.version_vn == 1 and version_vn) or
		(tbInfo.version_hk == 1 and version_hk) or
		(tbInfo.version_xm == 1 and version_xm) or
		(tbInfo.version_en == 1 and version_en) or
		(tbInfo.version_kor == 1 and version_kor) or
		(tbInfo.version_th == 1 and version_th) then
		return true;
	end

	return false;
end

function Activity:LoadSetting()
	local szParam = "sssssssddddddd"
	local tbColume = {"OpenServerDay", "StartDateTime", "EndDateTime", "KeyName", "Type", "TimeFrameLimitGE", "TimeFrameLimitLE",
						"version_tx", "version_vn", "version_hk", "version_xm", "version_en", "version_kor", "version_th"};

	for i = 1, 10 do
		szParam = szParam .. "s"
		table.insert(tbColume, "Param"..i)
	end

	self.tbActivityPlan = LoadTabFile("ServerSetting/Activity/Activity.tab", szParam, nil, tbColume);

	local nOpenServerTime = TimeFrame:GetServerCreateTime();
	for i, tbInfo in ipairs(self.tbActivityPlan) do
		if self:CheckVersion(tbInfo) then
			local tbOpenServerDay = Lib:SplitStr(tbInfo.OpenServerDay, ";")
			local tbStartDateTime = Lib:SplitStr(tbInfo.StartDateTime, "-")
			local tbEndDateTime = Lib:SplitStr(tbInfo.EndDateTime, "-")
			local tbTimeFrameLimitGE = Lib:SplitStr(tbInfo.TimeFrameLimitGE, "|");
			local tbTimeFrameLimitLE = Lib:SplitStr(tbInfo.TimeFrameLimitLE, "|");
			local tbParam = {};

			for j = 1, 10 do
				if tbInfo["Param"..j] then
					table.insert(tbParam, tbInfo["Param"..j])
				end
			end

			if #tbOpenServerDay == 2 then	-- 开服时间优先
				local tbStartInfo = Lib:SplitStr(tbOpenServerDay[1], "|");
				local tbEndInfo = Lib:SplitStr(tbOpenServerDay[2], "|");
				tbStartInfo[2] = tonumber(tbStartInfo[2]);
				tbEndInfo[2] = tonumber(tbEndInfo[2]);

				local nStartOpenDay = TimeFrame:CalcRealOpenDay(unpack(tbStartInfo));
				local nEndOpenDay = TimeFrame:CalcRealOpenDay(unpack(tbEndInfo));
				assert(nStartOpenDay > 0 and nEndOpenDay > 0 and nEndOpenDay > nStartOpenDay);

				tbInfo.tbActivityDay = { nStartOpenDay, nEndOpenDay };
			elseif #tbStartDateTime >= 3 and #tbEndDateTime >= 3 then	-- 其次是日期时间
				local year, month, day, hour, minute, second = unpack(tbStartDateTime)
				local nStartTime = os.time({year = tonumber(year), month = tonumber(month), day = tonumber(day), hour = tonumber(hour), min = tonumber(minute), sec = tonumber(second)})
				local year, month, day, hour, minute, second = unpack(tbEndDateTime)
				local nEndTime = os.time({year = tonumber(year), month = tonumber(month), day = tonumber(day), hour = tonumber(hour), min = tonumber(minute), sec = tonumber(second)})

				tbInfo.tbActivityDate = {nStartTime, nEndTime};
			else
				assert(false, "Activity Setting Error!! No Start Time!!!!", tbInfo.KeyName, tbInfo.Type);
			end

			tbInfo.bTimeFrameCheckOK = true;
			if #tbTimeFrameLimitGE == 2 and #tbTimeFrameLimitLE == 2 then
				tbTimeFrameLimitGE[2] = tonumber(tbTimeFrameLimitGE[2]);
				tbTimeFrameLimitLE[2] = tonumber(tbTimeFrameLimitLE[2]);
				assert(tbTimeFrameLimitGE[2] and tbTimeFrameLimitLE[2]);

				local nOpenTimeFrameDayGE, nOpenTimeFrameTimeGE = TimeFrame:CalcRealOpenDay(unpack(tbTimeFrameLimitGE));
				local nOpenTimeFrameDayLE, nOpenTimeFrameTimeLE = TimeFrame:CalcRealOpenDay(unpack(tbTimeFrameLimitLE));

				nOpenTimeFrameTimeGE = math.max(nOpenTimeFrameTimeGE, nOpenServerTime);
				nOpenTimeFrameTimeLE = math.max(nOpenTimeFrameTimeLE, nOpenServerTime);
				tbInfo.bTimeFrameCheckOK = false;
				if tbInfo.tbActivityDay then
					if tbInfo.tbActivityDay[1] >= nOpenTimeFrameDayGE and tbInfo.tbActivityDay[1] <= nOpenTimeFrameDayLE then
						tbInfo.bTimeFrameCheckOK = true;
					end
				elseif tbInfo.tbActivityDate then
					local nStartTime = math.max(tbInfo.tbActivityDate[1], nOpenServerTime);
					if nStartTime >= nOpenTimeFrameTimeGE and nStartTime <= nOpenTimeFrameTimeLE then
						tbInfo.bTimeFrameCheckOK = true;
					end
				end
			end
			tbInfo.tbParam = tbParam;
		end
	end
end

Activity.tbClass = Activity.tbClass or {};
Activity.EVENT_PROC =
{
	StartTimerTrigger = true,
	WorldMsg          = true,
	ExcuteTriggle     = true,
}
Activity.tbPlayerActivityDataReg = Activity.tbPlayerActivityDataReg or {};

function Activity:CheckActivityStartToday()
	local nOpenServerTime = ScriptData:GetValue("dwServerCreateTime")
	local nServerDay = Lib:GetLocalDay(nOpenServerTime);
	local nToday = Lib:GetLocalDay(GetTime());

	for _, tbInfo in ipairs(self.tbActivityPlan) do
		if tbInfo.bTimeFrameCheckOK then
			if tbInfo.tbActivityDay then
				if tbInfo.tbActivityDay[1] <= nToday - nServerDay + 1 and
					(tbInfo.tbActivityDay[2] <= 0 or tbInfo.tbActivityDay[2] >= nToday - nServerDay + 1) then
					local nEndTime = -1;
					if tbInfo.tbActivityDay[2] > 0 then
						nEndTime = nOpenServerTime + tbInfo.tbActivityDay[2] * 24 * 3600;
						nEndTime = os.time({year = tonumber(os.date("%Y", nEndTime)), month = tonumber(os.date("%m", nEndTime)), day = tonumber(os.date("%d", nEndTime)),  hour = 0});
					end
					self:InitAndStartActivity(tbInfo.KeyName, tbInfo.Type, nEndTime, tbInfo.tbParam);
				end
			elseif tbInfo.tbActivityDate then
				local nCurTime = GetTime();
				if nCurTime >= tbInfo.tbActivityDate[1] and tbInfo.tbActivityDate[2] > nCurTime then	-- 已经过了开启时间但没到结束时间，开启
					self:InitAndStartActivity(tbInfo.KeyName, tbInfo.Type, tbInfo.tbActivityDate[2], tbInfo.tbParam);
				elseif nCurTime < tbInfo.tbActivityDate[1] and Lib:GetLocalDay(nCurTime) == Lib:GetLocalDay(tbInfo.tbActivityDate[1]) then -- 今天会开
					Timer:Register((tbInfo.tbActivityDate[1] - nCurTime) * Env.GAME_FPS, self.InitAndStartActivity, self, tbInfo.KeyName, tbInfo.Type, tbInfo.tbActivityDate[2], tbInfo.tbParam);
				end
			end
		end
	end
end

function Activity:OnServerStart()
	Activity:LoadSetting();
	local tbActivityData = self:GetActivityData();
	for szKeyName, tbCurActivity in pairs(tbActivityData) do
		self:StartActivity(tbCurActivity, szKeyName);
	end

	-- 看看有没有活动符合开启条件
	self:CheckActivityStartToday();
end

function Activity:GetClass(szClass, szBaseClass)
	if not self.tbClass[szClass] then
		local tbBase = self.tbClass[szBaseClass or "___nil___"] or self.tbBase;
		self.tbClass[szClass] = Lib:NewClass(tbBase);
	end
	return self.tbClass[szClass];
end

function Activity:GetActivityData()
	self.tbRuningActivity = self.tbRuningActivity or {};
	local tbActivityData = ScriptData:GetValue("ActivityData");
	return tbActivityData, self.tbRuningActivity;
end

function Activity:SaveActivityData()
	ScriptData:AddModifyFlag("ActivityData")
	ScriptData:CheckAndSave()
end

function Activity:InitAndStartActivity(szKeyName, szType, nEndTime, tbParam)
	local tbActivityData, tbRuningActivity = self:GetActivityData();
	local nTimeNow = GetTime();
	if nEndTime > 0 and nTimeNow >= nEndTime then
		return;
	end

	if tbActivityData[szKeyName] then
		return;
	end

	Log("Activity Init!!", szKeyName, szType);

	tbActivityData[szKeyName] =
	{
		szType = szType,
		nStartTime = nTimeNow,
		nEndTime = nEndTime,
		tbParam = tbParam,
	};

	self:StartActivity(tbActivityData[szKeyName], szKeyName, true);
	self:SaveActivityData()
end

function Activity:StartActivity(tbActData, szKeyName, bInit)
	local nCurTime = GetTime();
	local tbClass = self.tbClass[tbActData.szType];
	if not tbClass then
		Log("[Activity] StartActivity ERR ?? tbClass is nil !!", tbActData.szType, szKeyName, bInit and "true" or "false");
		return;
	end

	local tbActivity = Lib:NewClass(tbClass);
	self.tbRuningActivity = self.tbRuningActivity or {}
	self.tbRuningActivity[szKeyName] =
		{
			szType = tbActData.szType,
			nStartTime = tbActData.nStartTime,
			nEndTime = tbActData.nEndTime,
			tbParam = tbActData.tbParam,
			tbInst = tbActivity,
			szKeyName = szKeyName,
			tbEvent = {},

			-- tbNpcClassRegister = {}; -- NPC 注册空间 --需要的时候添加
			-- tbNpcTemplateIdRegiseter = {};

			bRunning = 1,
		}

	self.tbRuningActivity[szKeyName].tbInst:Init(tbActData.szType, szKeyName, unpack(tbActData.tbParam));
	if bInit then
		self:OnTrigger(self.tbRuningActivity[szKeyName], "Init");
	end

	Log("Start Activity", szKeyName, tbActData.szType,
		tbActData.nEndTime > 0 and os.date("EndTime:%Y-%m-%d %H:%M:%S", tbActData.nEndTime) or "No EndTime")

	self:OnTrigger(self.tbRuningActivity[szKeyName], "Start", unpack(tbActData.tbParam));
	if tbActData.nEndTime > 0 then
		if tbActData.nEndTime > nCurTime then
			Timer:Register((tbActData.nEndTime - nCurTime) * Env.GAME_FPS, self.EndActivity, self, szKeyName)
		else
			self:EndActivity(szKeyName);
		end
	end

	if self.tbRuningActivity[szKeyName] then
		self:CheckPassedTimerTrigger(self.tbRuningActivity[szKeyName])
	end

	local tbInfo = {szKeyName = szKeyName, szType = tbActData.szType, nEndTime = tbActData.nEndTime, nStartTime = tbActData.nStartTime };
	if tbActivity.GetUiData then
		tbInfo.tbUiData = tbActivity:GetUiData();
	end
	if tbActivity.GetCustomInfo then
		tbInfo.tbCustomInfo = tbActivity:GetCustomInfo()
	end

	KPlayer.BoardcastScript(1, "Activity:OnSyncActivityInfo", {tbInfo});
end

function Activity:CheckPassedTimerTrigger(tbActivity)
	local nCurTime = GetTime();
	local nPassedTime = nCurTime - tbActivity.nStartTime;
	local nCurDay = Lib:GetLocalDay(nCurTime);
	local nOpenDay = Lib:GetLocalDay(tbActivity.nStartTime);
	local nPassedDay = nCurDay - nOpenDay;

	local tbTrigger = tbActivity.tbInst.tbTimerTrigger;
	if not tbTrigger then
		return;
	end

	for i, tbInfo in ipairs(tbTrigger) do
		if tbInfo.szType == "PassedTime" then
			if (tbInfo.Time and tbInfo.Time <= nPassedTime) or
				(tbInfo.Day and tbInfo.Day <= nPassedDay) then	-- 已经过了开始的时间
				self:OnTrigger(tbActivity, tbInfo.Trigger);
			elseif tbInfo.Time then		-- 今天之内会开则开个Timer
				Timer:Register((tbInfo.Time - nPassedTime) * Env.GAME_FPS, self.OnTriggerTimer, self, tbActivity, i);
			elseif tbInfo.Day then
				local nTime = tbActivity.nStartTime + tbInfo.Day * 24 * 3600;
				nTime = os.time({year = tonumber(os.date("%Y", nTime)), month = tonumber(os.date("%m", nTime)), day = tonumber(os.date("%d", nTime)),  hour = 0});
				Timer:Register((nTime - nCurTime) * Env.GAME_FPS, self.OnTriggerTimer, self, tbActivity, i);
				Log(tbActivity.szKeyName, tbInfo.Trigger, os.date("PassedTimerTrigger Will Open At:%Y-%m-%d %H:%M:%S", nTime));
			end
		end
	end
end

function Activity:EndActivity(szKeyName)
	local tbActivityData, tbRuningActivity = self:GetActivityData();
	if not tbActivityData[szKeyName] then
		return;
	end

	Log("End Activity", szKeyName);

	self:OnTrigger(tbRuningActivity[szKeyName], "End");
	tbRuningActivity[szKeyName].bRunning = 0;
	tbRuningActivity[szKeyName] = nil;
	tbActivityData[szKeyName] = nil;
	self:SaveActivityData()

	--对于强行关闭的活动，需要手动关闭客户端显示
	KPlayer.BoardcastScript(1, "Activity:CloseNewInfomation", szKeyName)
end

function Activity:OnTrigger(tbActivity, szTrigger, ...)
	if not tbActivity.tbInst.tbTrigger or not tbActivity.tbInst.tbTrigger[szTrigger] then
		Log("Activity Trigger is unexsit!", tbActivity.szType, szTrigger);
		return;
	end

	for _, tbEvent in ipairs(tbActivity.tbInst.tbTrigger[szTrigger]) do
		self:OnEvent(tbActivity, unpack(tbEvent));
	end

	if tbActivity.tbInst.OnTrigger then
		Lib:CallBack({tbActivity.tbInst.OnTrigger, tbActivity.tbInst, szTrigger, ...});
		--tbActivity.tbInst:OnTrigger(szTrigger, ...);
	end
end

function Activity:OnTriggerTimer(tbActivity, nTriggerId)
	if tbActivity.bRunning ~= 1 or
		not tbActivity.tbInst.tbTimerTrigger or
		not tbActivity.tbInst.tbTimerTrigger[nTriggerId] then

		return;
	end

	self:OnTrigger(tbActivity, tbActivity.tbInst.tbTimerTrigger[nTriggerId].Trigger);
end

function Activity:StartTimerTrigger(tbActivity, nTriggerId)
	if not tbActivity or not tbActivity.tbInst or not tbActivity.tbInst.tbTimerTrigger or not tbActivity.tbInst.tbTimerTrigger[nTriggerId] then
		return;
	end

	local tbTimerTrigger = tbActivity.tbInst.tbTimerTrigger[nTriggerId];
	if tbTimerTrigger.szType == "Day" then
		if not self.tbScheduleCallBack[tbTimerTrigger.Time] then
			self.tbScheduleCallBack[tbTimerTrigger.Time] = {}
			AddScheduleTask(tbTimerTrigger.Time, "ActivityDynamicCallback", tbTimerTrigger.Time);
		end
		table.insert(self.tbScheduleCallBack[tbTimerTrigger.Time], {tbActivity.szKeyName, tbActivity.tbInst.tbTimerTrigger[nTriggerId]})
	elseif tbTimerTrigger.szType == "Timer" then
		Timer:Register(tbTimerTrigger.Time * Env.GAME_FPS, self.OnTriggerTimer, self, tbActivity, nTriggerId)
	end
end

function Activity:ScheduleCallBack(szParam)
	if not self.tbScheduleCallBack[szParam] then
		return
	end

	local tbActivityData, tbRuningActivity = self:GetActivityData();
	for i = #self.tbScheduleCallBack[szParam], 1, -1 do
		-- 倒序遍历，因为可能要删数据
		local szKeyName, tbTimerTrigger = unpack(self.tbScheduleCallBack[szParam][i])
		Log("[Activity]ScheduleCallBack "..szParam.." "..szKeyName)

		if tbRuningActivity[szKeyName] and tbRuningActivity[szKeyName].bRunning == 1 then
			self:OnTrigger(tbRuningActivity[szKeyName], tbTimerTrigger.Trigger)
		else
			table.remove(self.tbScheduleCallBack[szParam], i)
			Log("[Activity]ScheduleCallBack "..szParam.." Remove "..szKeyName)
		end
	end
end

function Activity:OnEvent(tbActivity, szEventType, ...)
	if not self.EVENT_PROC[szEventType] or not self[szEventType] then
		Log("[Activity] ERR ?? Undefind szEventType", szEventType, ...);
		return;
	end

	Lib:CallBack({self[szEventType], self, tbActivity, ...});
	--self[szEventType](self, tbActivity, ...);
end

function Activity:ExcuteTriggle(tbActivity, szTrigger, ...)
	if not tbActivity.tbInst or not tbActivity.tbInst.ExcuteTriggle then
		return;
	end

	Lib:CallBack({tbActivity.tbInst.ExcuteTriggle, tbActivity.tbInst, szTrigger, ...});
	--tbActivity.tbInst:ExcuteTriggle(szTrigger, ...);
end

function Activity:WorldMsg(tbActivity, szMsg, nMinLevel, nMaxLevel)
	KPlayer.SendWorldNotify(nMinLevel or 1, nMaxLevel or 1000, szMsg, ChatMgr.ChannelType.Public, 1);
end

function Activity:RegisterPlayerEvent(tbActivityInst, szEventType, szFunc)
	local szKeyName = tbActivityInst.szKeyName;
	local _, tbRuningActivity = self:GetActivityData();
	local tbActivity = tbRuningActivity[szKeyName];
	if not tbActivity then
		Log("[Activity] RegisterPlayerEvent ERR ?? tbActivity is nil !!", szKeyName, szEventType, szFunc);
		Log(debug.traceback());
		return;
	end
	tbActivity.tbEvent[szEventType] = szFunc;
end

function Activity:UnRegisterPlayerEvent(tbActivityInst, szEventType)
	local szKeyName = tbActivityInst.szKeyName;
	local _, tbRuningActivity = self:GetActivityData();
	local tbActivity = tbRuningActivity[szKeyName];
	if not tbActivity then
		return;
	end

	tbActivity.tbEvent[szEventType] = nil;
end

function Activity:OnPlayerEvent(pPlayer, szEventType, ...)
	local _, tbRuningActivity = self:GetActivityData();
	for szKeyName, tbActivity in pairs(tbRuningActivity) do
		local szFunc = tbActivity.tbEvent[szEventType];
		if szFunc then
			Lib:CallBack({tbActivity.tbInst.OnPlayerEvent, tbActivity.tbInst, pPlayer, szEventType, szFunc, ...});
			--tbActivity.tbInst:OnPlayerEvent(pPlayer, szEventType, szFunc, ...);
		end
	end
end

function Activity:RegisterNpcCallback(tbActivityInst, varNpc)
	local szKeyName = tbActivityInst.szKeyName;
	local _, tbRuningActivity = self:GetActivityData();
	local tbActivity = tbRuningActivity[szKeyName];
	if not tbActivity then
		Log(debug.traceback(), szKeyName, szFunc);
		return;
	end

	if type(varNpc) == "string" then
		tbActivity.tbNpcClassRegister = tbActivity.tbNpcClassRegister or {}
		tbActivity.tbNpcClassRegister[varNpc] = tbActivity.tbNpcClassRegister[varNpc] or { tbDialog = {} }
		return tbActivity.tbNpcClassRegister[varNpc]
	elseif type(varNpc) == "number" then
		tbActivity.tbNpcTemplateIdRegiseter = tbActivity.tbNpcTemplateIdRegiseter or {}
		tbActivity.tbNpcTemplateIdRegiseter[varNpc] = tbActivity.tbNpcTemplateIdRegiseter[varNpc] or { tbDialog = {} }
		return tbActivity.tbNpcTemplateIdRegiseter[varNpc]
	end
end

function Activity:RegisterNpcDialog(tbActivityInst, varNpc, tbOpt)
	local tbTable = self:RegisterNpcCallback(tbActivityInst, varNpc)
	table.insert(tbTable.tbDialog, tbOpt);
end

function Activity:OnNpcDialog(nTemplateId, szClassName, tbOptList)
	local _, tbRuningActivity = self:GetActivityData();
	for szKeyName, tbActivity in pairs(tbRuningActivity) do
		if szClassName and tbActivity.tbNpcClassRegister and tbActivity.tbNpcClassRegister[szClassName] then
			local tbDialog = tbActivity.tbNpcClassRegister[szClassName].tbDialog
			if tbDialog then
				Lib:MergeTable(tbOptList, tbDialog);
			end
		end

		if tbActivity.tbNpcTemplateIdRegiseter and tbActivity.tbNpcTemplateIdRegiseter[nTemplateId] then
			local tbDialog = tbActivity.tbNpcTemplateIdRegiseter[nTemplateId].tbDialog
			if tbDialog then
				Lib:MergeTable(tbOptList, tbDialog);
			end
		end
	end
end

function Activity:UnRegisterNpcDialog(tbActivityInst, varNpc)
	local _, tbRuningActivity = self:GetActivityData();
	local tbActivity = tbRuningActivity[tbActivityInst.szKeyName];
	if not tbActivity then
		Log(debug.traceback(), varNpc, tbActivityInst.szKeyName)
		return
	end
	if not varNpc then
		for szNapClass, tbInfo in pairs(tbActivity.tbNpcClassRegister) do
			tbInfo.tbDialog = {}
		end
		for nNpcTemplateId, tbInfo in pairs(tbActivity.tbNpcTemplateIdRegiseter) do
			tbInfo.tbDialog = {}
		end
	else
		local tbTable = self:RegisterNpcCallback(tbActivityInst, varNpc)
		tbTable.tbDialog = {};
	end
end

function Activity:__IsActInProcessByType(szType)
	if Lib:IsEmptyStr(szType) then
		return
	end

	local _, tbRuningActivity = self:GetActivityData()
	local nCount = 0
	for _, tbInfo in pairs(tbRuningActivity) do
		if tbInfo.szType == szType then
			nCount = nCount + 1
		end
	end
	return nCount > 0, nCount
end

function Activity:__GetActTimeInfo(szKeyName)
	local _, tbRuningActivity = self:GetActivityData();
	local tbAct = tbRuningActivity[szKeyName] or {nStartTime = 0, nEndTime = 0}
	return tbAct.nStartTime, tbAct.nEndTime
end

function Activity:OnLogin(pPlayer)
	self:CheckPlayerActivityDataTimeout(pPlayer, GetTime());
	local tbActData = pPlayer.GetScriptTable("ActivityData");
	for szKeyName, tbData in pairs(tbActData or {}) do
		self:SetCachePlayerActivityData(szKeyName, pPlayer.dwID, tbData);
	end

	local tbActData = {};
	local _, tbRuningActivity = self:GetActivityData();
	for szKeyName, tbActivity in pairs(tbRuningActivity or {}) do
		if tbActivity.bRunning and tbActivity.bRunning == 1 then
			local tbInfo = {szKeyName = szKeyName, szType = tbActivity.szType, nEndTime = tbActivity.nEndTime, nStartTime = tbActivity.nStartTime};
			if tbActivity.tbInst and tbActivity.tbInst.GetUiData then
				tbInfo.tbUiData = tbActivity.tbInst:GetUiData();
			end
			if tbActivity.tbInst and tbActivity.tbInst.GetCustomInfo then
				tbInfo.tbCustomInfo = tbActivity.tbInst:GetCustomInfo()
			end
			table.insert(tbActData, tbInfo);
		end
	end
	pPlayer.CallClientScript("Activity:OnSyncActivityInfo", tbActData);

	self:OnPlayerEvent(pPlayer, "Act_OnPlayerLogin")
end

function Activity:RegisterGlobalEvent(tbActivityInst, szEventType, szFunc)
	local szKeyName = tbActivityInst.szKeyName;
	local _, tbRuningActivity = self:GetActivityData();
	local tbActivity = tbRuningActivity[szKeyName];
	if not tbActivity then
		Log("[Activity] RegisterGlobalEvent ERR ?? tbActivity is nil !!", szKeyName, szEventType, szFunc);
		Log(debug.traceback());
		return;
	end
	if Lib:IsEmptyStr(szFunc) then
		Log("[Activity] RegisterGlobalEvent ERR ?? szFunc is not available !!", szKeyName, szEventType, szFunc);
		Log(debug.traceback());
		return
	end
	tbActivity.tbEvent[szEventType] = szFunc;
end

function Activity:UnRegisterGlobalEvent(tbActivityInst, szEventType)
	local szKeyName = tbActivityInst.szKeyName;
	local _, tbRuningActivity = self:GetActivityData();
	local tbActivity = tbRuningActivity[szKeyName];
	if not tbActivity then
		return;
	end

	tbActivity.tbEvent[szEventType] = nil;
end

function Activity:OnGlobalEvent(szEventType, ...)
	local _, tbRuningActivity = self:GetActivityData();
	for szKeyName, tbActivity in pairs(tbRuningActivity) do
		local szFunc = tbActivity.tbEvent[szEventType];
		if szFunc then
			Lib:CallBack({tbActivity.tbInst.OnGlobalEvent, tbActivity.tbInst, szEventType, szFunc, ...});
			--tbActivity.tbInst:OnGlobalEvent(szEventType, szFunc, ...);
		end
	end
end

--获取配置表中活动开启时间，并非实际开启时间
function Activity:GetActBeginTime(szKey)
	for _, tbInfo in ipairs(self.tbActivityPlan) do
		if tbInfo.KeyName == szKey then
			if tbInfo.tbActivityDay then
				local nDay = Lib:GetLocalDay(GetServerCreateTime())
				nDay = nDay + tbInfo.tbActivityDay[1] - 1
				return nDay*24*3600
			elseif tbInfo.tbActivityDate then
				return tbInfo.tbActivityDate[1]
			end
		end
	end

	Log("Activity GetActBeginTime Error", szKey)
	return 0
end

--获取配置表中活动结束时间，并非实际结束时间
function Activity:GetActEndTime(szKey)
	for _, tbInfo in ipairs(self.tbActivityPlan) do
		if tbInfo.KeyName == szKey then
			if tbInfo.tbActivityDay then
				local nDay = Lib:GetLocalDay(GetServerCreateTime())
				nDay = nDay + tbInfo.tbActivityDay[2]
				return nDay*24*3600
			elseif tbInfo.tbActivityDate then
				return tbInfo.tbActivityDate[2]
			end
		end
	end

	Log("Activity GetActEndTime unnormal", szKey)
	return 0
end

function Activity:SetCachePlayerActivityData(szKeyName, nPlayerId, tbValue)
	self.tbCachePlayerActivityData = self.tbCachePlayerActivityData or {};
	self.tbCachePlayerActivityData[nPlayerId] = self.tbCachePlayerActivityData[nPlayerId] or {};
	self.tbCachePlayerActivityData[nPlayerId][szKeyName] = type(tbValue) == "table" and Lib:CopyTB(tbValue) or tbValue;
end

function Activity:CheckPlayerActivityDataTimeout(pPlayer, nTimeNow)
	local tbActData = pPlayer.GetScriptTable("ActivityData");
	local tbTimeout = {};
	for szKeyName, tbData in pairs(tbActData) do
		local nCurTimeout = self.tbPlayerActivityDataReg[szKeyName];
		if not nCurTimeout or tbData.nTimeout ~= nCurTimeout or tbData.nTimeout < nTimeNow then
			tbTimeout[szKeyName] = true;
		end
	end

	for szKey in pairs(tbTimeout) do
		tbActData[szKey] = nil;
		self:SetCachePlayerActivityData(szKey, pPlayer.dwID, nil)
	end
end

function Activity:__GetPlayerActivityData(szKeyName, nPlayerId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	local tbActData = nil;
	if pPlayer then
		tbActData = pPlayer.GetScriptTable("ActivityData");
	else
		tbActData = self.tbCachePlayerActivityData[nPlayerId];
	end

	if not tbActData or not tbActData[szKeyName] then
		return;
	end

	local nCurTimeout = self.tbPlayerActivityDataReg[szKeyName];
	if not nCurTimeout or tbActData[szKeyName].nTimeout ~= nCurTimeout or nCurTimeout < GetTime() then
		return;
	end

	return tbActData[szKeyName].tbValue;
end

function Activity:__SetPlayerActivityData(szKeyName, pPlayer, tbValue)
	local tbActData = pPlayer.GetScriptTable("ActivityData");
	local nTimeNow = GetTime();
	if not self.tbPlayerActivityDataReg or not self.tbPlayerActivityDataReg[szKeyName] or self.tbPlayerActivityDataReg[szKeyName] < nTimeNow then
		return;
	end

	self:CheckPlayerActivityDataTimeout(pPlayer, GetTime());

	tbActData[szKeyName] = tbActData[szKeyName] or {};
	tbActData[szKeyName].nTimeout = self.tbPlayerActivityDataReg[szKeyName];
	tbActData[szKeyName].tbValue = type(tbValue) == "table" and Lib:CopyTB(tbValue) or tbValue;
	self:SetCachePlayerActivityData(szKeyName, pPlayer.dwID, tbActData[szKeyName]);
end

function Activity:__RegisterPlayerActivityData(szKeyName, nTimeout)
	self.tbPlayerActivityDataReg = self.tbPlayerActivityDataReg or {};
	self.tbPlayerActivityDataReg[szKeyName] = nTimeout;
end