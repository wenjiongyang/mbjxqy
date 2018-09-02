
function ScheduleTask:SendTimeFrameMail(szTimeFrame, nLevel, szMail, szAttach, nDelayDay)
	local nOpenTime = CalcTimeFrameOpenTime(szTimeFrame);
	local szDate;
	if nDelayDay then
		szDate =  os.date(XT("%Y年%m月%d日"), GetTime() + nDelayDay * 24 * 3600)  ..  os.date(XT(" %H:%M"), nOpenTime);
	else
		szDate	= os.date(XT("%Y年%m月%d日 %H:%M"), nOpenTime);
	end

	szMail	= string.gsub(szMail, "%%date", szDate);
	local tbAttach = szAttach and Lib:GetAwardFromString(szAttach) or nil;

	local _, _, szTitle, szContent = string.find(szMail, "^(.-)\\n(.+)$");
	Mail:SendGlobalSystemMail({
		Title = szTitle or "系統信件",
		Text = szContent,
		LevelLimit = nLevel,
		tbAttach  = tbAttach,
		})
	Log("SendTimeFrameMail", szMail)
end

function ScheduleTask:SendAnnounce(szTimeFrame, nLevel, szMsg)
	local nOpenTime 	= CalcTimeFrameOpenTime(szTimeFrame);
	local szDate		= os.date(XT("%Y年%m月%d日 %H:%M"), nOpenTime);
	local szMsg	= string.gsub(szMsg, "%%date", szDate);
	KPlayer.SendWorldNotify(nLevel, 999, szMsg, 1, 1);
end

function ScheduleTask:StartPowerRank()
	RankActivity.PowerRankActivity:StartPowerRank()
end

function ScheduleTask:SendActNewInfomation(szTitle, szKey, szEndTimeFrame, nEndDay)
	nEndDay = tonumber(nEndDay) or 1;
	local _, nValidTime = TimeFrame:CalcRealOpenDay(szEndTimeFrame, nEndDay);
	szKey = "__SendActNewInfomation__" .. szKey;
	NewInformation:AddInfomation(szKey, nValidTime, {szKey}, {szTitle = szTitle, szUiName = "DragonBoatFestival"});
end


local MAX_PARAM_COUNT = 5;
local MAX_TIME_COUNT = 10;
function ScheduleTask:LoadOneTimeTaskData()
	local tbTitle = {"TimeFrame", "Day", "ScriptFunc", "WeekDay"};
	local szType = "sssd"
	for i = 1, MAX_PARAM_COUNT do
	szType = szType .. "s";
		table.insert(tbTitle, "Param" .. i);
	end

	for i = 1, MAX_TIME_COUNT do
		szType = szType .. "s";
		table.insert(tbTitle, "Time" .. i);
	end

	local nTodayDay = Lib:GetLocalDay();
	local tbFile = LoadTabFile("Setting/OneTimeTask.tab", szType, nil, tbTitle);
	for _, tbRow in ipairs(tbFile) do
		tbRow.Day = tonumber(tbRow.Day);
		assert(tbRow.Day);

		local tbTimeInfo = {};
		for i = 1, MAX_TIME_COUNT do
			local nHour, nMin = string.match(tbRow["Time" .. i], "(%d+):(%d+)");
			if not nHour then
				table.insert(tbTimeInfo, -1);
			else
				table.insert(tbTimeInfo, tonumber(nHour) * 100 + tonumber(nMin));
			end
		end

		local nDay, nOpenTime = TimeFrame:CalcRealOpenDay(tbRow.TimeFrame, tbRow.Day);
		nOpenTime = Lib:GetTodayZeroHour(nOpenTime);
		TimeFrame:DoCheckTimeFrame(tbRow.TimeFrame, nOpenTime, tbRow.TimeFrame .. "_" .. tbRow.Day);

		local nOpenDay = Lib:GetLocalDay(nOpenTime);
		local nOpenWeekDay = Lib:GetLocalWeekDay(nOpenTime);
		local nWeekInfo = tbRow.WeekDay;
		if nWeekInfo > 0 then
			local nUseDay = 999;
			local tbWeekDay = {};
			while nWeekInfo > 0 do
				local nWeekDay = nWeekInfo % 10;
				nWeekInfo = math.floor(nWeekInfo / 10);
				nUseDay = math.min(nUseDay, nWeekDay < nOpenWeekDay and nWeekDay + 7 or nWeekDay);
			end

			nDay = nDay + nUseDay - nOpenWeekDay;
			nOpenDay = nOpenDay + nUseDay - nOpenWeekDay;
		end

		if nOpenDay >= nTodayDay then
			AddOneTimeTask(nDay, tbRow.ScriptFunc, tbRow.Param1, tbRow.Param2, tbRow.Param3, tbRow.Param4, tbRow.Param5, tbTimeInfo);
		end
	end
end


