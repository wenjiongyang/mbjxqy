--生成任务
function CommerceTask:RandomAllTask(tbLevelTask)
	local tbResult = {};
	local tbFull = {};
	for i = 1, 3 do
		local tbPool = tbLevelTask[i];
		if tbPool then
			local nCount = self["POOL_COUNT"..i];
			local tbPoolTask = self:RandomAPoolTask(tbPool, nCount, tbFull);
			Lib:MergeTable(tbResult, tbPoolTask);
		end
	end

	return tbResult;
end

--生成一个池的任务
function CommerceTask:RandomAPoolTask(tbPool, nCount, tbFull)
	local tbPoolTask = {};
	local nTotalProb = 0;

	local tbRandom = {};
	for i,v in ipairs(tbPool) do
		if not tbFull[v.nTemplateId] then
			table.insert(tbRandom, {nIndex = i, nTemplateId = v.nTemplateId, nProb = v.nProb, nCount = 0});
			nTotalProb = nTotalProb + v.nProb;
		end
	end

	for i = 1, nCount do
		local nIndex, nRemove = self:RandomATask(tbRandom, nTotalProb);
		if nRemove then
			tbFull[tbRandom[nRemove].nTemplateId] = true;
		end

		local tbATask = tbPool[nIndex];
		table.insert(tbPoolTask, {
				nTaskId = tbATask.nTaskId,
				bFinish = false,
				nGain = 0,
			});

		if nRemove then--delete and trim
			nTotalProb = nTotalProb - tbRandom[nRemove].nProb;
			tbRandom[nRemove] = nil;
			local tbTemp = {};
			for k,v in pairs(tbRandom) do
				table.insert(tbTemp, v);
			end
			tbRandom = tbTemp;
		end
	end

	return tbPoolTask;
end

--随机一个任务
function CommerceTask:RandomATask(tbRandom, nTotalProb)
	local nRan = MathRandom(0, nTotalProb);
	local nRemove;
	for i,v in ipairs(tbRandom) do
		nRan = nRan - v.nProb;
		if nRan <= 0 then
			v.nCount = v.nCount + 1;
			if v.nCount == self.MAX_REPEAT then
				nRemove = i;
			end

			return v.nIndex, nRemove;
		end
	end
end

function CommerceTask:GetTaskInfo(pPlayer)
	local tbCommerceData = pPlayer.GetScriptTable("CommerceTask");
	local tbHelp, nHelpCount = self:GetHelpAsynData(pPlayer.dwID);
	for i = 1, nHelpCount do
		local nTaskId = tbHelp[i];
		local nState = tbHelp[i + nHelpCount];
		if nTaskId ~= 0 and nState == 1 and tbCommerceData.tbTask then
			for i,v in ipairs(tbCommerceData.tbTask) do
				if v.nTaskId == nTaskId then
					v.bFinish = true;
					break;
				end
			end
		end
	end

	return tbCommerceData, tbHelp;
end

function CommerceTask:SyncCommerceData(pPlayer)
	local tbCommerceData, tbHelp = self:GetTaskInfo(pPlayer);
	pPlayer.CallClientScript("CommerceTask:OnRespondSync", tbCommerceData, tbHelp);
end


function CommerceTask:AcceptTask(pPlayer)
	if not self:CanAcceptTask(pPlayer) then
		return;
	end

	local nDegree = DegreeCtrl:GetDegree(pPlayer, "CommerceTask")
	if not nDegree or nDegree <= 0 then
		pPlayer.CenterMsg("今日已接過商會任務")
		return;
	end

	local tbLevelTask = self:GainLevelTask(pPlayer.nLevel);
	local tbGainTask = self:RandomAllTask(tbLevelTask);

	local tbCommerceData 		= self:GetTaskInfo(pPlayer);
	tbCommerceData.tbTask 		= tbGainTask;
	tbCommerceData.bFinish 		= false;
	tbCommerceData.bGiveUp 		= false;
	tbCommerceData.nLevel 		= pPlayer.nLevel;
	tbCommerceData.nTime 		= GetTime();
	self:ClearHelpData(pPlayer.dwID);

	self:SyncCommerceData(pPlayer);

	DegreeCtrl:ReduceDegree(pPlayer, "CommerceTask", 1)
	AssistClient:ReportQQScore(pPlayer, Env.QQReport_IsJoinCommerceTask, 1, 0, 1)
	-- LogD(Env.LOGD_ActivityPlay, pPlayer.szAccount, pPlayer.dwID, pPlayer.nLevel, nil, Env.LOGD_VAL_TAKE_TASK, Env.LOGD_MIS_COMMERCE, pPlayer.GetFightPower())
	Log("CommerceTask AcceptTask", pPlayer.dwID)
end

--采集到一个采集物
function CommerceTask:AddGatherTing(pPlayer, nTemplateId)
	local tbCommerceData = self:GetTaskInfo(pPlayer);
	if tbCommerceData.tbTask then
		for k,v in pairs(tbCommerceData.tbTask) do
			local nTaskId = v.nTaskId;
			local tbSetting = self:GetTaskSetting(nTaskId);

			if not v.bFinish and tbSetting.szType == "Gather" and
			 tbSetting.nTemplateId == nTemplateId and v.nGain < tbSetting.nCount then
				v.nGain = v.nGain + 1;
				if v.nGain == tbSetting.nCount then
					return true;
				end
				break;
			end
		end
	end
	Log("CommerceTask AddGatherTing", pPlayer.dwID, nTemplateId)
end

function CommerceTask:CommitGather(pPlayer, nIndex)
	if not self:IsDoingTask(pPlayer) then
		return;
	end
	local tbCommerceData = self:GetTaskInfo(pPlayer);
	local tbAllTask = tbCommerceData.tbTask;
	local tbTask = tbAllTask[nIndex];

	if not tbTask then
		return;
	end

	if tbTask.bFinish then
		return;
	end

	local tbSetting = self:GetTaskSetting(tbTask.nTaskId);
	if tbTask.nGain >= tbSetting.nCount then
		tbTask.bFinish = true;
	end

	self:SyncCommerceData(pPlayer);
	pPlayer.CenterMsg("裝箱成功");
	Achievement:AddCount(pPlayer, "CommerceTask_1", 1)
	pPlayer.TLogRoundFlow(Env.LogWay_CommerceTask, tbTask.nTaskId, 0, 0, Env.LogRound_SUCCESS, 0, 0);
	Log("CommerceTask CommitGather", pPlayer.dwID, nIndex)
end

function CommerceTask:CommitItem(pPlayer, nIndex)
	if not self:IsDoingTask(pPlayer) then
		return;
	end
	local tbCommerceData = self:GetTaskInfo(pPlayer);
	local tbAllTask = tbCommerceData.tbTask;
	local tbTask = tbAllTask[nIndex];

	if not tbTask then
		Log("[CommerceTask CommitItem] Error, Task Is Nil")
		return;
	end

	if not self:ConsumeBoxNeedItem(pPlayer, tbTask.nTaskId) then
		pPlayer.CenterMsg("提交失敗，道具不足");
		return;
	end

	tbCommerceData.tbTask[nIndex].bFinish = true;
	local tbGainReward, szInfo = self:GetBoxReward(tbTask.nTaskId);
	pPlayer.SendAward(tbGainReward, nil, nil, Env.LogWay_CommerceTaskCommitItem);

	self:SyncCommerceData(pPlayer);

	local tbHelp, nHelpCount = self:GetHelpAsynData(pPlayer.dwID)
	for i = 1, nHelpCount do
		if tbHelp[i] == tbTask.nTaskId then
			self:SetHelpAsynData(pPlayer.dwID, i, tbTask.nTaskId, 1)
			local kinData = Kin:GetKinById(pPlayer.dwKinId)
			if kinData then
				kinData:SetCacheFlag("UpdateMemberInfoList", true)
			end
		end
	end

	local szTip = szInfo ~= "" and string.format("裝箱成功，獲得獎勵 %s", szInfo) or string.format("裝箱成功")
	pPlayer.CenterMsg(szTip);

	Achievement:AddCount(pPlayer, "CommerceTask_1", 1)
	pPlayer.TLogRoundFlow( Env.LogWay_CommerceTask, tbTask.nTaskId, 0, 0, Env.LogRound_SUCCESS, 0, 0);
	Log("CommerceTask CommitItem", pPlayer.dwID, nIndex)
end

function CommerceTask:GetBoxReward(nTaskId)
	local tbTaskSetting = self:GetTaskSetting(nTaskId);
	local tbGainReward = {};
	local szInfo = "";
	for i = 1, 2 do
		local szType = tbTaskSetting["szRewardType"..i];
		local nTemplateId = tbTaskSetting["nRewardId"..i];
		local nCount = tbTaskSetting["nRewardCount"..i];
		if szType and szType ~= "" then
			local tbReward = self:FormatReward(szType, nTemplateId, nCount);
			szInfo = szInfo .. " " .. self:FormatItem(szType, nTemplateId, nCount);
			table.insert(tbGainReward, tbReward);
		end
	end
	return tbGainReward, szInfo;
end

function CommerceTask:ConsumeBoxNeedItem(pPlayer, nTaskId)
	local tbTaskSetting = self:GetTaskSetting(nTaskId);
	if tbTaskSetting.szType == "Item" then
		local nHas = pPlayer.GetItemCountInAllPos(tbTaskSetting.nTemplateId);
		if nHas >= tbTaskSetting.nCount then
			pPlayer.ConsumeItemInAllPos(tbTaskSetting.nTemplateId, tbTaskSetting.nCount, Env.LogWay_CommerceTask);
			return true;
		end
	end
	return false;
end

function CommerceTask:FinishTask(pPlayer, bConfirm)
	if type(pPlayer) == "number" then
		pPlayer = KPlayer.GetPlayerObjById(pPlayer)
	end

	if not pPlayer then
		return
	end

	if not self:IsDoingTask(pPlayer) then
		return;
	end

	--check box count
	local tbCommerceTask = self:GetTaskInfo(pPlayer);
	local nFinishCount = 0;
	for i = 1, 10 do
		local tbTask = tbCommerceTask.tbTask[i];
		if tbTask.bFinish then
			nFinishCount = nFinishCount + 1;
		end
	end

	if nFinishCount < self.COMPLETE_COUNT then
		pPlayer.CenterMsg(string.format("需收集%d個以上完成任務", self.COMPLETE_COUNT))
		return;
	end

	if not bConfirm and nFinishCount < self.ALL_COMPLETE_COUNT then
		pPlayer.MsgBox(CommerceTask.szNotAllCompleteMsg, {{"確認", CommerceTask.FinishTask, CommerceTask, pPlayer.dwID, true}, {"取消"}})
		return
	end
	-- LogD(Env.LOGD_ActivityPlay, pPlayer.szAccount, pPlayer.dwID, pPlayer.nLevel, nil, Env.LOGD_VAL_FINISH_TASK, Env.LOGD_MIS_COMMERCE, pPlayer.GetFightPower())

	-- QQ会员加成
	local _, nVipAddRate = pPlayer.GetQQVipInfo();

	local tbAllAward = {}
	local nFinalMoney = math.floor(nFinishCount * self.BASIC_MONEY_NUM * (1 + nVipAddRate) + 0.5);
	table.insert(tbAllAward, { self.BASIC_MONEY_TYPE, nFinalMoney})
	table.insert(tbAllAward, self.BASIC_AWARD)
	table.insert(tbAllAward, self.ADDITION_AWARD)
	if nFinishCount == 10 then --额外奖励
		local tbAllCompleteAward = CommerceTask:GetAllCompleteAward(pPlayer)
		table.insert(tbAllAward, tbAllCompleteAward)
	end

	tbCommerceTask.bFinish = true;
	self:SetHelpAsynDataComplete(pPlayer)
	self:SyncCommerceData(pPlayer);
	pPlayer.CenterMsg("恭喜您，完成了任務");

	local bDoubleAward, szMsg, tbFinalAward = RegressionPrivilege:GetDoubleAward(pPlayer, "CommerceTask", tbAllAward)
	table.insert(tbFinalAward, {"BasicExp", self.BASIC_EXP_AWARD*nFinishCount})
	pPlayer.SendAward(tbFinalAward, true, false, Env.LogWay_FinishCommerceTask)
	if szMsg then
		pPlayer.CenterMsg(szMsg, true)
	end
	EverydayTarget:AddCount(pPlayer, "CommerceTask")
	Achievement:AddCount(pPlayer, "CommerceTask_3", 1)
	TeacherStudent:TargetAddCount(pPlayer, "CommerceTask", 1)

	Log("CommerceTask FinishTask", pPlayer.dwID)
end

function CommerceTask:SetHelpAsynDataComplete(pPlayer)
	local pAsyncData = KPlayer.GetAsyncData(pPlayer.dwID)
	if not pAsyncData then
		return
	end

	local nHelpCount = self:GetAskHelpCount(pPlayer.GetVipLevel())
	for i = 1, nHelpCount do
		local _, nStateSaveKey = self:GetHelpAsynSaveInfo(i)
		pAsyncData.SetAsyncValue(nStateSaveKey, 1)
	end
end

function CommerceTask:GiveUpTask(pPlayer)
	if not self:IsDoingTask(pPlayer) then
		return;
	end

	local tbCommerceTask = self:GetTaskInfo(pPlayer);
	tbCommerceTask.bGiveUp = true;
	self:SyncCommerceData(pPlayer);

	Log("CommerceTask GiveUpTask", pPlayer.dwID)
end

function CommerceTask:AskHelp(pPlayer, nRequestTaskId)
	if pPlayer.dwKinId == 0 then
		pPlayer.CenterMsg("您沒有幫派，無法求助");
		return;
	end

	local tbHelp, nHelpCount = self:GetHelpAsynData(pPlayer.dwID);
	local tbCommerceData = self:GetTaskInfo(pPlayer);

	local bPass, szReason = self:CanAskHelp(tbHelp, tbCommerceData.tbTask, nRequestTaskId);
	if not bPass then
		return;
	end

	for i = 1, nHelpCount do
		local nTaskId = tbHelp[i];
		local nState = tbHelp[i + nHelpCount];
		if nTaskId == 0 then
			self:SetHelpAsynData(pPlayer.dwID, i, nRequestTaskId, 0);
			break;
		end
	end

	local kinData = Kin:GetKinById(pPlayer.dwKinId);
	kinData:SetCacheFlag("UpdateMemberInfoList", true);

	local tbTaskSetting = self:GetTaskSetting(nRequestTaskId);
	local tbBaseInfo = KItem.GetItemBaseProp(tbTaskSetting.nTemplateId);
	local szItemName = tbBaseInfo.szName;

	pPlayer.CenterMsg("成功發起幫派求助");
	self:SyncCommerceData(pPlayer);

	local szKinMsg = string.format("<協助完成>「%s」發佈了商會任務的求助，正在尋找【%s】×%d", pPlayer.szName, szItemName, tbTaskSetting.nCount);
	ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.Kin, szKinMsg, pPlayer.dwKinId, { nLinkType = ChatMgr.LinkType.Commerce, dwPlayerID = pPlayer.dwID });

	Log("CommerceTask AskHelp", pPlayer.dwID, nRequestTaskId)
end

function CommerceTask:DoHelp(pPlayer, nTarPlayerId, nTaskId, bCoin)
	local bRet, szMsg, nItemTemplateId, nCount, nDataPos = self:CheckHelpEnable(pPlayer, nTarPlayerId, nTaskId, bCoin)
	if not bRet then
		if szMsg then
			pPlayer.CenterMsg(szMsg)
		end
		return
	end

	if not bCoin then
		local nConsumeCount = pPlayer.ConsumeItemInAllPos(nItemTemplateId, nCount, Env.LogWay_CommerceTask)
		if nConsumeCount < nCount then
			pPlayer.CenterMsg("您沒有足夠的協助物品")
			Log("CommerceTask DoHelp Error", pPlayer.dwID, pPlayer.szName, nTaskId)
			return
		end

		self:OnHelpSuccess(pPlayer, nTarPlayerId, nDataPos, nTaskId)
	else
		local nConsume = self:GetHelpNeedCoin(nItemTemplateId)
		if not nConsume then
			pPlayer.CenterMsg("協助失敗，請重試")
			return
		end
		pPlayer.CostGold(nConsume, Env.LogWay_CommerceTaskHelp, nil,
			function (nPlayerId, bSuccess)
				local bRet, szMsg = self:OnCostGoldHelpCallback(nPlayerId, bSuccess, nTarPlayerId, nDataPos, nTaskId)
				return bRet, szMsg
			end)
	end

end

function CommerceTask:OnCostGoldHelpCallback(nPlayerId, bSuccess, nTarPlayerId, nDataPos, nTaskId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return false, "協助期間離線，請重試"
	end

	if not bSuccess then
		return false, "支付失敗"
	end

	local bRet, szMsg = self:CheckHelpEnable(pPlayer, nTarPlayerId, nTaskId, true)
	if not bRet then
		if szMsg then
			pPlayer.CenterMsg(szMsg)
		end
		return false, szMsg
	end

	self:OnHelpSuccess(pPlayer, nTarPlayerId, nDataPos, nTaskId)
	Log("CommerceTask OnCostGoldHelpCallback", nTarPlayerId, nTaskId, nDataPos)
	return true
end

function CommerceTask:CheckHelpEnable(pPlayer, nTarPlayerId, nTaskId, bCoin)
	if pPlayer.dwID == nTarPlayerId then
		return false, "無法幫助自己完成任務"
	end

	if not Kin:PlayerAtSameKin(pPlayer.dwID, nTarPlayerId) then
		return false, "不在同一個幫派，無法協助";
	end

	local tbHelp, nHelpCount = self:GetHelpAsynData(nTarPlayerId);
	local nDataPos;
	for i = 1, nHelpCount do
		local nSaveTaskId = tbHelp[i];
		local nState = tbHelp[i + nHelpCount];

		if nSaveTaskId == nTaskId and nState == 0 then
			nDataPos = i;
			break;
		end
	end

	if not nDataPos then
		return false, "已經有人幫他完成了";
	end

	local tbTaskSetting = self:GetTaskSetting(nTaskId);
	local tbBaseInfo    = KItem.GetItemBaseProp(tbTaskSetting.nTemplateId);

	if tbTaskSetting.szType == "Item" then
		if not bCoin then
			local nHas = pPlayer.GetItemCountInAllPos(tbTaskSetting.nTemplateId);
			if nHas < tbTaskSetting.nCount then
				return false, string.format("你沒有足夠的%s", tbBaseInfo.szName or "")
			end
		end
	else
		return false, "此任務無法協助完成"
	end

	local tbCommerceData = self:GetTaskInfo(pPlayer)
	tbCommerceData.tbHelpOtherData = tbCommerceData.tbHelpOtherData or {}
	local nLastHelpDay = tbCommerceData.tbHelpOtherData.nLastHelpDay or 0
	local nCurDay      = Lib:GetLocalDay()
	tbCommerceData.tbHelpOtherData.nHelpTimes = nLastHelpDay == nCurDay and tbCommerceData.tbHelpOtherData.nHelpTimes or 0
	local nHelpTimes, nNextVip = self:GetHelpTimes(pPlayer)
	if tbCommerceData.tbHelpOtherData.nHelpTimes >= nHelpTimes then
		pPlayer.CallClientScript("CommerceTask:OnNoHelpTimes", nNextVip)
		return
	end

	return true, nil, tbTaskSetting.nTemplateId, tbTaskSetting.nCount, nDataPos
end

function CommerceTask:OnHelpSuccess(pPlayer, nTarPlayerId, nDataPos, nTaskId)
	--记录协助玩家的今日协助次数
	local tbCommerceData = self:GetTaskInfo(pPlayer)
	tbCommerceData.tbHelpOtherData = tbCommerceData.tbHelpOtherData or {}
	tbCommerceData.tbHelpOtherData.nHelpTimes   = tbCommerceData.tbHelpOtherData.nHelpTimes and tbCommerceData.tbHelpOtherData.nHelpTimes + 1 or 1
	tbCommerceData.tbHelpOtherData.nLastHelpDay = Lib:GetLocalDay()

	--被协助玩家的异步数据
	self:SetHelpAsynData(nTarPlayerId, nDataPos, nTaskId, 1);

	local kinData = Kin:GetKinById(pPlayer.dwKinId);
	kinData:SetCacheFlag("UpdateMemberInfoList", true);

	local pRoleStayInfo = KPlayer.GetRoleStayInfo(nTarPlayerId);
	local tbTaskSetting = self:GetTaskSetting(nTaskId);
	local tbBaseInfo = KItem.GetItemBaseProp(tbTaskSetting.nTemplateId);
	local szItemName = tbBaseInfo.szName;
	local szKinMsg = string.format("「%s」協助「%s」完成了商會需求：【%s】", pPlayer.szName, pRoleStayInfo.szName, szItemName)
	self:NotifyTargetPlayer(nTarPlayerId);
	ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.Kin, szKinMsg, pPlayer.dwKinId);
	self:SendNotifyMail(szItemName, tbTaskSetting.nCount, pPlayer.szName, nTarPlayerId);

	if pPlayer.dwKinId ~= 0 then
		local nAddCount = self:GetAddContributionCount(tbTaskSetting.nTemplateId)
		pPlayer.AddMoney("Contrib", nAddCount, Env.LogWay_CommerceTaskDoHelp)
		pPlayer.CallClientScript("CommerceTask:OnRespondHelp", string.format("獲得%d貢獻", nAddCount))
	end

	self:SyncCommerceData(pPlayer)
	FriendShip:AddImitity(pPlayer.dwID, nTarPlayerId, self.HELP_IMITITY, Env.LogWay_CommerceTaskDoHelp);
	Achievement:AddCount(nTarPlayerId, "CommerceTask_2", 1)
	Log("CommerceTask OnHelpSuccess", pPlayer.dwID, nTarPlayerId, nDataPos, nTaskId)
end

function CommerceTask:SendNotifyMail(szItemName, nCount, szPlayerName, nTarPlayerId)
	local szMailContent = string.format("你發佈的商會求助【%s】×%d，已經被「%s」協助完成了。", szItemName, nCount, szPlayerName);
	local tbMail =
	{
		To = nTarPlayerId,
		Title = "商會協助",
		Text = szMailContent,
		From = "「商會老闆」萬金財",
	};
	Mail:SendSystemMail(tbMail);
end


function CommerceTask:GetHelpAsynData(dwID)
	local tbHelp = {};
	local pAsyncData = KPlayer.GetAsyncData(dwID);
	local nHelpCount = 0
	if pAsyncData then
		nHelpCount = self:GetAskHelpCount(pAsyncData.GetVipLevel())
		for i = 1, nHelpCount do
			local nIdSaveKey, nStateSaveKey = self:GetHelpAsynSaveInfo(i)
			tbHelp[i] = pAsyncData.GetAsyncValue(nIdSaveKey)
			tbHelp[i + nHelpCount] = pAsyncData.GetAsyncValue(nStateSaveKey)
		end
	end
	return tbHelp, nHelpCount;
end

function CommerceTask:ClearHelpData(dwID)
	local pAsyncData = KPlayer.GetAsyncData(dwID);
	if pAsyncData then
		for _, tbInfo in ipairs(self.tbHelpAsynDataKey) do
			local nIdSaveKey, nStateSaveKey = unpack(tbInfo)
			pAsyncData.SetAsyncValue(nIdSaveKey, 0);
			pAsyncData.SetAsyncValue(nStateSaveKey, 0);
		end
	end
end

function CommerceTask:SetHelpAsynData(dwID, nIndex, nTaskId, nState)
	local pAsyncData = KPlayer.GetAsyncData(dwID);
	if pAsyncData then
		local nTaskSaveKey, nStateSaveKey = self:GetHelpAsynSaveInfo(nIndex)
		pAsyncData.SetAsyncValue(nTaskSaveKey, nTaskId);
		pAsyncData.SetAsyncValue(nStateSaveKey, nState);
	else
		Log("[ERROR] in CommerceTask:SetHelpAsynData.Can't find AsyncData:", dwID);
	end
end

function CommerceTask:GetFamilyCommerceHelpData(dwID)
	local tbHelp, nHelpCount = self:GetHelpAsynData(dwID);
	local bHelp = false;

	for i = 1, nHelpCount do
		local nTaskId = tbHelp[i];
		local nState = tbHelp[i + nHelpCount];
		if nTaskId ~= 0 and nState == 0 then
			bHelp = true;
			break;
		end
	end

	if bHelp then
		return tbHelp;
	end
end

--客户端调用接口
local CommerceTaskInterface = {
	CommitItem 	= true,--装箱
	CommitGather= true,
	AskHelp 	= true,--请求协助
	DoHelp 		= true,--协助
	FinishTask 	= true,--完成任务
	GiveUpTask 	= true,--放弃任务
}

function CommerceTask:OnResquest(pPlayer, szRequestType, ... )
	if CommerceTaskInterface[szRequestType] then
		CommerceTask[szRequestType](CommerceTask, pPlayer, ...);
	else
		Log("WRONG CommerceTask Request:", szRequestType, ...);
	end
end

function CommerceTask:NotifyTargetPlayer(nTargetPlayerId)
	local pPlayer = KPlayer.GetPlayerObjById(nTargetPlayerId);
	if pPlayer then
		self:SyncCommerceData(pPlayer);
	end
end

function CommerceTask:OnVipChanged(nNewVipLevel, nOldVipLevel)
	if nNewVipLevel >= self.nHelpTimesVipLv and nOldVipLevel < self.nHelpTimesVipLv then
		self:SetHelpAsynData(me.dwID, 4, 0, 0)
		self:SyncCommerceData(me)
	end
end
PlayerEvent:RegisterGlobal("OnVipChanged", CommerceTask.OnVipChanged, CommerceTask)