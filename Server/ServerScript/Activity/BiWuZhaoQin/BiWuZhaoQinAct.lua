Require("CommonScript/Activity/BiWuZhaoQinDef.lua");

local tbAct = Activity:GetClass("BiWuZhaoQin");

tbAct.tbTimerTrigger =
{
	[1] = {szType = "Day", Time = BiWuZhaoQin.szOpenTime , Trigger = "CheckStartFight" },
}

tbAct.tbTrigger =
{
	Init = {},
	Start =
	{
		{"StartTimerTrigger", 1}
	},

	End = {},
	CheckStartFight = {},
};


function tbAct:OnTrigger(szTrigger)
	if szTrigger == "Init" then
		local tbData = ScriptData:GetValue("BiWuZhaoQin");
		if tbData.nStartTime then
			Lib:LogTB(tbData);
		end
		tbData.nStartTime = Lib:GetLocalDay();
		tbData.tbOpenDateInfo = {};

		local nStartTime, nEndTime = self:GetOpenTimeInfo();
		self:UpdateOpenDate(math.max(nStartTime, GetTime()), nEndTime, tbData.tbOpenDateInfo);
		ScriptData:AddModifyFlag("BiWuZhaoQin");

		Log("[BiWuZhaoQin] Init tbOpenDateInfo:");
		Lib:LogTB(tbData.tbOpenDateInfo);

		NewInformation:AddInfomation("BiWuZhaoQin", nEndTime, {BiWuZhaoQin.szNewInfomation}, { szTitle = BiWuZhaoQin.szNewInfomationTitle});
	elseif szTrigger == "Start" then
		Npc:GetClass("LoverNpc"):OnBiWuZhaoQinStateChange(true);
		Activity:RegisterPlayerEvent(self, "BiWuZhaoQin", "OnClientCall");

		Activity:RegisterNpcDialog(self, 631,  {Text = "我要招親", Callback = self.OnNpcDialog, Param = {self, true}});
		Activity:RegisterNpcDialog(self, 631,  {Text = "比武招親比賽", Callback = self.OnNpcDialog, Param = {self}});
		Activity:RegisterNpcDialog(self, 631,  {Text = "解除情緣關係", Callback = self.RemoveLover, Param = {self}});

		local nHour, nMin = string.match(BiWuZhaoQin.szOpenTime, "(%d+):(%d+)");
		nHour = tonumber(nHour);
		nMin = tonumber(nMin);
		self.nOpenTime = nHour * 3600 + nMin * 60;
	elseif szTrigger == "CheckStartFight" then
		self:CheckStartFight();
	elseif szTrigger == "End" then
		local tbData = ScriptData:GetValue("BiWuZhaoQin");
		tbData.tbOpenDateInfo = {};
		ScriptData:AddModifyFlag("BiWuZhaoQin");
		Npc:GetClass("LoverNpc"):OnBiWuZhaoQinStateChange(false);
	end
end

function tbAct:UpdateOpenDate(nStartTime, nEndTime, tbOpenDateInfo)
	local nStartDay = Lib:GetLocalDay(nStartTime);
	local nEndDay = Lib:GetLocalDay(nEndTime);

	local nHour, nMin = string.match(BiWuZhaoQin.szOpenTime, "(%d+):(%d+)");
	nHour = tonumber(nHour);
	nMin = tonumber(nMin);

	-- 当天比赛时间前20分钟开启活动，则认为当前也可以开启比赛，否则当前不开启比赛
	if nStartTime > Lib:GetTodayZeroHour(nStartTime) + nHour * 3600 + nMin * 60 - 1200 then
		nStartDay = nStartDay + 1;
	end

	--如果在在开启比赛后半小时才结束活动，当天才允许开启比赛
	if nEndTime <= Lib:GetTodayZeroHour(nEndTime) + nHour * 3600 + nMin * 60 + 1800 then
		nEndDay = nEndDay - 1;
	end

	for nLocalDay = nStartDay, nEndDay do
		local nWeekDay = (nLocalDay + 3) % 7 + 1;
		if BiWuZhaoQin.tbOpenWeekDay[nWeekDay] then
			table.insert(tbOpenDateInfo, {nOpenDay = nLocalDay, tbOpenPlayerInfo = {}});
		end
	end
end

function tbAct:GetOpenInfo(nOpenDay, nTypeId)
	local tbOpenDateInfo = self:GetOpenDateInfo();
	for _, tbOpenInfo in pairs(tbOpenDateInfo) do
		if tbOpenInfo.nOpenDay == nOpenDay then
			return tbOpenInfo.tbOpenPlayerInfo[nTypeId];
		end
	end
	return nil;
end

function tbAct:GetNextOpenDay()
	local nToday = Lib:GetLocalDay();
	local nNextOpenDay = nToday;
	local nTodayTime = Lib:GetTodaySec();
	if nTodayTime >= self.nOpenTime then
		nNextOpenDay = nToday + 1;
	end
	return nNextOpenDay;
end

function tbAct:GetOpenDateInfo()
	local tbData = ScriptData:GetValue("BiWuZhaoQin");
	tbData.tbOpenDateInfo = tbData.tbOpenDateInfo or {};
	return tbData.tbOpenDateInfo;
end

function tbAct:SaveOpenDateInfo(tbOpenDateInfo)
	local tbData = ScriptData:GetValue("BiWuZhaoQin");
	tbData.tbOpenDateInfo = tbOpenDateInfo;
	ScriptData:AddModifyFlag("BiWuZhaoQin");
end

function tbAct:RemoveLover()
	Npc:GetClass("LoverNpc"):RemoveLover();
end

function tbAct:OnNpcDialog(bZhaoQin)
	self:OnZhaoQinDialog(me, bZhaoQin);
end

function tbAct:OnZhaoQinDialog(pPlayer, bZhaoQin)
	if bZhaoQin then
		if pPlayer.nLevel < BiWuZhaoQin.nMinPlayerLevel then
			pPlayer.CenterMsg(string.format("需要等級達到%s級！", BiWuZhaoQin.nMinPlayerLevel));
			return;
		end

		local tbPlayerInfo;
		local nOpenDay;
		local nNextOpenDay = self:GetNextOpenDay();
		local tbOpenDateInfo = self:GetOpenDateInfo();
		for _, tbOpenInfo in pairs(tbOpenDateInfo) do
			if tbOpenInfo.nOpenDay >= nNextOpenDay then
				for _, tbInfo in pairs(tbOpenInfo.tbOpenPlayerInfo) do
					if tbInfo.nId == pPlayer.dwID then
						tbPlayerInfo = tbInfo;
						nOpenDay = tbOpenInfo.nOpenDay;
						break;
					end
				end
			end
			if tbPlayerInfo then
				break;
			end
		end
		local tbLimitInfo;
		if tbPlayerInfo then
			tbLimitInfo = {
				nTypeId = tbPlayerInfo.nTypeId,
				szKinName = tbPlayerInfo.szKinName,
				nLevel = tbPlayerInfo.nMinLevel,
				nMinHonor = tbPlayerInfo.nMinHonor,
				nOpenDay = nOpenDay,
			};
		end
		pPlayer.CallClientScript("Ui:OpenWindow", "BiWuZhaoQinPanel", tbLimitInfo);
	else
		local tbShowInfo = {};
		local nToday = Lib:GetLocalDay();
		local tbOpenDateInfo = self:GetOpenDateInfo();
		local bOpened = Lib:GetTodaySec() > self.nOpenTime + 10;

		for _, tbOpenInfo in ipairs(tbOpenDateInfo) do
			if tbOpenInfo.nOpenDay >= nToday then
				local tbInfo = Lib:CopyTB(tbOpenInfo);
				for _, tb in pairs(tbInfo.tbOpenPlayerInfo) do
					if BiWuZhaoQin:HadJoin(pPlayer.dwID, tb.nId) then
						tb.bHasJoin = true;
					end

					tb.bIsRuning = BiWuZhaoQin:GetActData(tb.nId) and true or false;
					if nToday == tbOpenInfo.nOpenDay and bOpened and not tb.bIsRuning then
						tb.bFinish = true;
					end
				end

				table.insert(tbShowInfo, tbInfo);
			end
		end

		pPlayer.CallClientScript("Ui:OpenWindow", "BiWuZhaoQinList", tbShowInfo);
	end
end

function tbAct:OnClientCall(pPlayer, szEvent, ...)
	if szEvent == "ZhaoQin" then
		self:TryZhaoQin(...);
	elseif szEvent == "CancelZhaoQin" then
		self:CancelZhaoQin();
	elseif szEvent == "JoinFight" then
		-- 报名参展
		local nOpenDay, nTypeId = unpack({...});
		local bCanJoin, szMsg, nTargetId = self:CheckCanGoToFight(pPlayer, nOpenDay, nTypeId);
		if not bCanJoin then
			pPlayer.CenterMsg(szMsg);
			return;
		end
		BiWuZhaoQin:Enter(pPlayer.dwID, nTargetId, false);
		pPlayer.CallClientScript("Ui:CloseWindow", "BiWuZhaoQinList");
	elseif szEvent == "GoToMatch" then
		-- 前去观战
		local nOpenDay, nTypeId = unpack({...});
		local bCanJoin, szMsg, nTargetId = self:CheckCanGoToMatch(pPlayer, nOpenDay, nTypeId);
		if not bCanJoin then
			pPlayer.CenterMsg(szMsg);
			return;
		end

		BiWuZhaoQin:Enter(pPlayer.dwID, nTargetId, true);
		pPlayer.CallClientScript("Ui:CloseWindow", "BiWuZhaoQinList");
	end
end

function tbAct:CheckCanGoToFight(pPlayer, nOpenDay, nTypeId)
	if type(nOpenDay) ~= "number" or type(nTypeId) ~= "number" then
		return false, "參數異常";
	end

	if BiWuZhaoQin:GetLover(pPlayer.dwID) then
		return false, "已有情緣關係，不能參與招親！";
	end

	local tbOpenInfo = self:GetOpenInfo(nOpenDay, nTypeId);
	if not tbOpenInfo then
		return false, "指定招親不存在";
	end

	local nToday = Lib:GetLocalDay();
	local tbOpenDateInfo = self:GetOpenDateInfo();
	for _, tbOpenInfo in pairs(tbOpenDateInfo) do
		if tbOpenInfo.nOpenDay >= nToday then
			for nId, tbInfo in pairs(tbOpenInfo.tbOpenPlayerInfo) do
				if tbInfo.nId and tbInfo.nId == pPlayer.dwID then
					return false, "您正在招親，不能參與比賽！";
				end
			end
		end
	end

	local tbActData = BiWuZhaoQin:GetActData(tbOpenInfo.nId);
	if not tbActData or not tbActData.nPreMapId then
		return false, "本場招親比賽還未開啟！";
	end

	if pPlayer.dwID == tbOpenInfo.nId then
		return false, "只能觀戰自己的招親比賽！";
	end

	if pPlayer.nLevel < tbOpenInfo.nMinLevel then
		return false, string.format("需要等級達到%s級！", tbOpenInfo.nMinLevel);
	end

	if pPlayer.nHonorLevel < tbOpenInfo.nMinHonor then
		return false, "頭銜不符合最低要求！";
	end

	if nTypeId > 0 and pPlayer.dwKinId ~= nTypeId then
		return false, "只有招親者同幫派成員才可以參與！";
	end

	if not Fuben.tbSafeMap[pPlayer.nMapTemplateId] then
		return false, "所在地圖不允許進入";
	end

	return true, "", tbOpenInfo.nId;
end

function tbAct:CheckCanGoToMatch(pPlayer, nOpenDay, nTypeId)
	if type(nOpenDay) ~= "number" or type(nTypeId) ~= "number" then
		return false, "參數異常";
	end

	local tbOpenInfo = self:GetOpenInfo(nOpenDay, nTypeId);
	if not tbOpenInfo then
		return false, "指定招親不存在";
	end

	local tbActData = BiWuZhaoQin:GetActData(tbOpenInfo.nId);
	if not tbActData or not tbActData.nPreMapId then
		return false, "本場招親比賽還未開啟！";
	end

	if not Fuben.tbSafeMap[pPlayer.nMapTemplateId] then
		return false, "所在地圖不允許進入";
	end

	return true, "", tbOpenInfo.nId;
end

function tbAct:CheckCanZhaoQin(pPlayer, nType, nMinLevel, nMinHonor, bNotCheckMoney)
	if BiWuZhaoQin:GetLover(pPlayer.dwID) then
		return false, "已有情緣關係，不能招親！";
	end

	if pPlayer.nLevel < BiWuZhaoQin.nMinPlayerLevel then
		return false, string.format("需要等級達到%s級！", BiWuZhaoQin.nMinPlayerLevel);
	end

	local tbLimitInfo;
	for _, tbInfo in ipairs(BiWuZhaoQin.tbLimitByTimeFrame) do
		if GetTimeFrameState(tbInfo[1]) == 1 then
			tbLimitInfo = tbInfo;
		else
			break;
		end
	end

	if not tbLimitInfo then
		return false, "活動配置異常";
	end

	if not nType or nType ~= BiWuZhaoQin.TYPE_GLOBAL and nType ~= BiWuZhaoQin.TYPE_KIN then
		return false, "招親範圍異常";
	end

	if nType == BiWuZhaoQin.TYPE_KIN and pPlayer.dwKinId <= 0 then
		return false, "沒有幫派，不能幫派內招親";
	end

	local kinData;
	if nType == BiWuZhaoQin.TYPE_KIN then
		kinData = Kin:GetKinById(pPlayer.dwKinId);
		if not kinData then
			return false, "沒有幫派，不能參與！";
		end
	end

	if not nMinLevel or nMinLevel > tbLimitInfo[3] then
		return false, "參與最低等級異常";
	end

	if not nMinHonor or nMinHonor < 1 or nMinHonor > tbLimitInfo[2] then
		return false, "參與最低頭銜異常";
	end

	if not bNotCheckMoney then
		local nNeedGold = nType == BiWuZhaoQin.TYPE_GLOBAL and BiWuZhaoQin.nCostGold_TypeGlobal or BiWuZhaoQin.nCostGold_TypeKin;
		if pPlayer.GetMoney("Gold") < nNeedGold then
			return false, string.format("元寶不足 %s, 無法開啟！", nNeedGold);
		end
	end

	local nToday = Lib:GetLocalDay();
	local nNextOpenDay = self:GetNextOpenDay();

	local tbOpenDateInfo = self:GetOpenDateInfo();
	for _, tbOpenInfo in pairs(tbOpenDateInfo) do
		if tbOpenInfo.nOpenDay >= nNextOpenDay then
			for nId, tbInfo in pairs(tbOpenInfo.tbOpenPlayerInfo) do
				if tbInfo.nId and tbInfo.nId == pPlayer.dwID then
					return false, "大俠已經開啟了一場招親了，不能再次開啟！";
				end
			end
		end
	end

	local nLastOpenDay = pPlayer.GetUserValue(BiWuZhaoQin.SAVE_GROUP, BiWuZhaoQin.INDEX_LAST_DATE);
	if nToday - nLastOpenDay < BiWuZhaoQin.nOpenZhaoQinCD then
		return false, "大俠招親太頻繁了，等段時間再來吧！";
	end

	local nOpenDay = 0;
	local nId = (nType == BiWuZhaoQin.TYPE_GLOBAL) and 0 or pPlayer.dwKinId;
	for _, tbInfo in pairs(tbOpenDateInfo) do
		if tbInfo.nOpenDay >= nNextOpenDay and not tbInfo.tbOpenPlayerInfo[nId] then
			nOpenDay = tbInfo.nOpenDay;
			break;
		end
	end

	if nOpenDay <= 0 then
		return false, "當前招親預定名額已滿！";
	end

	return true, "可以招親", nOpenDay, nId, kinData and kinData.szName;
end

function tbAct:TryZhaoQin(nType, nMinLevel, nMinHonor, nConfirmOpenDay)
	local bRet, szMsg, nOpenDay, nId, szKinName = self:CheckCanZhaoQin(me, nType, nMinLevel, nMinHonor);
	if not bRet then
		me.CenterMsg(szMsg);
		return;
	end

	if not nConfirmOpenDay then
		szMsg = string.format("你確定開啟一場比武招親嗎？\n比賽將在[ffcd00]%s[-]開始", os.date("%Y年%m月%d日", nOpenDay * 3600 * 24 + 1));
		me.MsgBox(szMsg, {{"確定", function (nType, nMinLevel, nMinHonor, nConfirmOpenDay)
			self:TryZhaoQin(nType, nMinLevel, nMinHonor, nConfirmOpenDay);
		end, nType, nMinLevel, nMinHonor, nOpenDay}, {"取消"}})
		return;
	end

	if nConfirmOpenDay ~= nOpenDay then
		me.CenterMsg("很遺憾，此場次已被搶佔，請重新申請！");
		return;
	end

	local function fnCostCallback(nPlayerId, bSuccess, szBillNo, nType, nMinLevel, nMinHonor, nConfirmOpenDay)
		return self:TryZhaoQin_CoseMoney(nPlayerId, bSuccess, szBillNo, nType, nMinLevel, nMinHonor, nConfirmOpenDay)
	end

	local nNeedGold = nType == BiWuZhaoQin.TYPE_GLOBAL and BiWuZhaoQin.nCostGold_TypeGlobal or BiWuZhaoQin.nCostGold_TypeKin;
	local bRet = me.CostGold(nNeedGold, Env.LogWay_BiWuZhaoQin, nil, fnCostCallback, nType, nMinLevel, nMinHonor, nOpenDay);
	if not bRet then
		me.CenterMsg("支付失敗請稍後再試！");
		return;
	end
end

function tbAct:TryZhaoQin_CoseMoney(nPlayerId, bSuccess, szBillNo, nType, nMinLevel, nMinHonor, nConfirmOpenDay)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return false, "扣除手續費中途, 您掉線了！";
	end

	if not bSuccess then
		return false, "支付失敗請稍後再試！";
	end

	local bRet, szMsg, nOpenDay, nId, szKinName = self:CheckCanZhaoQin(pPlayer, nType, nMinLevel, nMinHonor, true);
	if not bRet then
		return false, szMsg;
	end

	if nConfirmOpenDay ~= nOpenDay then
		return false, "指定場次已被搶佔，請重新申請！";
	end

	pPlayer.SetUserValue(BiWuZhaoQin.SAVE_GROUP, BiWuZhaoQin.INDEX_LAST_DATE, nOpenDay);
	pPlayer.SetUserValue(BiWuZhaoQin.SAVE_GROUP, BiWuZhaoQin.INDEX_ID, nId);

	local tbOpenDateInfo = self:GetOpenDateInfo();
	for _, tbInfo in pairs(tbOpenDateInfo) do
		if tbInfo.nOpenDay == nOpenDay then
			tbInfo.tbOpenPlayerInfo[nId] =
			{
				nId = pPlayer.dwID,
				szName = pPlayer.szName,
				nLevel = pPlayer.nLevel,
				nFaction = pPlayer.nFaction,
				nPortrait = pPlayer.nPortrait,
				nHonorLevel = pPlayer.nHonorLevel,
				nFightPower = pPlayer.GetFightPower(),
				nVipLevel = pPlayer.GetVipLevel(),

				nTypeId = nId,
				nMinLevel = nMinLevel,
				nMinHonor = nMinHonor,
				szKinName = szKinName,
			};
			break;
		end
	end

	self:SaveOpenDateInfo(tbOpenDateInfo);
	pPlayer.CenterMsg("開啟招親成功！");
	if nId <= 0 then
		KPlayer.SendWorldNotify(0, 999, string.format("俠士「%s」開啟了比武招親，將於[ffcd00]%s%s[-]開賽，請有意的大俠到時積極參與！", pPlayer.szName, os.date("%Y年%m月%d日", nOpenDay * 3600 * 24 + 1), BiWuZhaoQin.szOpenTime), 0, 1);
	else
		ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.Kin, string.format("幫派成員「%s」開啟了比武招親，將於[EA2C2C]%s%s[-]開賽，請有意的大俠到時積極參與！", pPlayer.szName, os.date("%Y年%m月%d日", nOpenDay * 3600 * 24 + 1), BiWuZhaoQin.szOpenTime), nId);
	end
	return true;
end

function tbAct:CancelZhaoQin(bConfirm)
	local nNextOpenDay = self:GetNextOpenDay();
	local nId = me.GetUserValue(BiWuZhaoQin.SAVE_GROUP, BiWuZhaoQin.INDEX_ID);
	local nOpenDay = me.GetUserValue(BiWuZhaoQin.SAVE_GROUP, BiWuZhaoQin.INDEX_LAST_DATE);

	if nNextOpenDay > nOpenDay then
		me.CenterMsg("當前沒有可以取消的招親活動！");
		return;
	end

	if not bConfirm then
		me.MsgBox("您確定取消發佈的招親比賽嗎？\n[ffcd00]消耗的元寶將不會返還[-]", {{"確定", function ()
			self:CancelZhaoQin(true);
		end}, {"取消"}})
		return;
	end

	local tbOpenDateInfo = self:GetOpenDateInfo();
	for _, tbOpenInfo in pairs(tbOpenDateInfo) do
		if tbOpenInfo.nOpenDay >= nNextOpenDay then
			for nId, tbInfo in pairs(tbOpenInfo.tbOpenPlayerInfo) do
				if tbInfo.nId and tbInfo.nId == me.dwID then
					tbOpenInfo.tbOpenPlayerInfo[nId] = nil;
					break;
				end
			end
		end
	end

	self:SaveOpenDateInfo(tbOpenDateInfo);
	me.SetUserValue(BiWuZhaoQin.SAVE_GROUP, BiWuZhaoQin.INDEX_LAST_DATE, 0);
	me.CenterMsg("取消成功！");
end

function tbAct:CheckStartFight()
	Log("[BiWuZhaoQin] CheckStartFight -------------------------------");
	local nToday = Lib:GetLocalDay();
	local tbOpenDateInfo = self:GetOpenDateInfo();
	local tbTodayOpenInfo;
	for _, tbInfo in pairs(tbOpenDateInfo) do
		if nToday == tbInfo.nOpenDay then
			tbTodayOpenInfo = tbInfo;
			break;
		end
	end

	if not tbTodayOpenInfo then
		return;
	end

	for dwKinId, tbInfo in pairs(tbTodayOpenInfo.tbOpenPlayerInfo) do
		BiWuZhaoQin:StartS(tbInfo.nId, dwKinId)
		Log("[BiWuZhaoQin] Start ", dwKinId);
	end
end

