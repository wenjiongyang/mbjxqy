local tbDefine = InDifferBattle.tbDefine;

function InDifferBattle:OnServerStopSignUp()
	self.tbReadyMapList = nil;
	Calendar:OnActivityEnd(tbDefine.szCalenddayKey)
end

function InDifferBattle:OnServerOnReadyMapCreate(tbReadyMapTypes)
	if GetTimeFrameState(tbDefine.szOpenTimeFrame) ~= 1 then
		Log("InDifferBattle:OnServerOnReadyMapCreate TimeFrameState UnOpen")
		return
	end
	local tbReadyMapList = {}; -- 从级别高到低
	for k, szBattleType in pairs(tbReadyMapTypes) do
		local tbSetting = self.tbBattleTypeSetting[szBattleType]
		if tbSetting.szOpenTimeFrame and GetTimeFrameState(tbSetting.szOpenTimeFrame) ~= 1 then
			tbReadyMapTypes[k] = nil;
		else
			table.insert(tbReadyMapList, {k, szBattleType,tbSetting.nLevel })
		end
	end
	
	table.sort( tbReadyMapList, function (a, b)
		return  a[3] > b[3]
	end )
	

	self.tbReadyMapList = tbReadyMapList

	local szMsg = "心魔幻境已經開啟，眾俠士可通過「活動」報名參加！"
	KPlayer.SendWorldNotify(tbDefine.nMinLevel, 150, szMsg, 1, 1)

	local tbMsgData = {
		szType = "StartInDifferBattle";
		nTimeOut = GetTime() + tbDefine.MATCH_SIGNUP_TIME;
		tbReadyMapList = tbReadyMapList;
	};

	if #tbReadyMapList > 1 then
		self.tbSynQualifyZoneWinRoleIds = {}; --跨服上取得资格赛胜利的玩家id， 用于发最新消息
	end

	KPlayer.BoardcastScript(tbDefine.nMinLevel, "Ui:SynNotifyMsg", tbMsgData); 
	Calendar:OnActivityBegin(tbDefine.szCalenddayKey)
	SupplementAward:OnActivityOpen("InDifferBattle")
end

function InDifferBattle:SignUp(pPlayer)
	if not self.tbReadyMapList  then
		pPlayer.CenterMsg("心魔幻境活動尚未開始！")
		return
	end
	local tbPlayers = {};
	local dwTeamID = pPlayer.dwTeamID
	if dwTeamID ~= 0 then
		local tbMember = TeamMgr:GetMembers(dwTeamID);
		for _, nPlayerId in pairs(tbMember) do
			local pMember = KPlayer.GetPlayerObjById(nPlayerId)
			if pMember then
				table.insert(tbPlayers, pMember)
			end
		end
	else
		table.insert(tbPlayers, pPlayer)
	end
	local szTrySignUpBattleType, nReadyMapId, szTopTypePlayerName = self:GetTopCanSignBattleType(tbPlayers, self.tbReadyMapList)
	assert(szTrySignUpBattleType)
	
	if 	#tbPlayers == 1 then
		local bRet, szMsg = self:CanSignUp(pPlayer, szTrySignUpBattleType) 
		if not bRet then
			pPlayer.CenterMsg(szMsg)
			return
		end	
	else
		local bRet, szMsg,szQualifyName = self:CanSignUp(pPlayer, szTrySignUpBattleType) 
		if not bRet then
			if szTopTypePlayerName and szQualifyName then
				pPlayer.CenterMsg(string.format("隊員「%s」擁有%s資格，不允許參加常規賽", szTopTypePlayerName, szQualifyName ))
			else
				pPlayer.CenterMsg(szMsg)
			end
			return
		end

		local bRet, szMsg = self:CheckTeamSignUp(pPlayer, szTrySignUpBattleType)
		if not bRet then
			pPlayer.CenterMsg(szMsg)
			return
		end
		local tbMemberIds = {}
		for i,v in ipairs(tbPlayers) do
			table.insert(tbMemberIds, v.dwID)
		end
		CallZoneServerScript("InDifferBattle:OnSyncTeamInfo", pPlayer.dwID, tbMemberIds);
		--组队信息， 拆队
		for _, nPlayerId in pairs(tbMemberIds) do
			TeamMgr:QuiteTeam(dwTeamID, nPlayerId)
		end

	end
	for i,pPlayer in ipairs(tbPlayers) do
		if not pPlayer.SwitchZoneMap(nReadyMapId, unpack(tbDefine.READY_MAP_POS[MathRandom(#tbDefine.READY_MAP_POS)]) ) then
			pPlayer.CenterMsg("暫時無法進入準備場")
		end
	end	
end


function InDifferBattle:CheckTeamSignUp(pPlayer, szTrySignUpBattleType)
	local tbMember = TeamMgr:GetMembers(pPlayer.dwTeamID);
	if not tbMember then
		return false, "無效的隊伍"
	end 

	local teamData = TeamMgr:GetTeamById(pPlayer.dwTeamID);
	if not teamData or teamData.nCaptainID ~= pPlayer.dwID then
		return false, "只有隊長才可以進行報名"
	end

	if #tbMember > tbDefine.nMaxTeamRoleNum then
		return false, string.format("請以單人或隊伍人數不超過%d人前來報名", tbDefine.nMaxTeamRoleNum);        
	end

	for _, nPlayerId in pairs(tbMember) do
		if nPlayerId ~= pPlayer.dwID then
			local pPlayer2 = KPlayer.GetPlayerObjById(nPlayerId);
			if not pPlayer2 then
				return false, "未知隊伍成員，無法報名！";
			end	
			local bRet, szMsg = self:CanSignUp(pPlayer2, szTrySignUpBattleType)
			if not bRet then
				return false, "「" .. pPlayer2.szName .. "」" .. (szMsg or "")
			end
		end
	end
	return true;
end

function InDifferBattle:OnPlayedBattle(dwRoleId, szBattleType)
	local pPlayer = KPlayer.GetPlayerObjById(dwRoleId)
	if not pPlayer then
		Log(debug.traceback(), dwRoleId)
		return
	end
	if szBattleType == "Normal" then
		DegreeCtrl:ReduceDegree(pPlayer, "InDifferBattle", 1)
	end
	
	SupplementAward:OnJoinActivity(pPlayer, "InDifferBattle")
	EverydayTarget:AddCount(pPlayer, "InDifferBattle");
end



function InDifferBattle:DelayOnGetQualifyTime(nScore, nQualifyOpenTime, szBattleType)
	nScore = tonumber(nScore) or 0;
	nQualifyOpenTime = tonumber(nQualifyOpenTime) or 0;

	if nQualifyOpenTime < GetTime() then
		Log("InDifferBattle:DelayOnGetQualifyTime Small", me.dwID, nScore, nQualifyOpenTime, szBattleType)
		return
	end
	
	self:SetPlayerQualify(me, szBattleType, nScore)
	Log("InDifferBattle:DelayOnGetPlayerScore", me.dwID, szBattleType)
end

function InDifferBattle:OnGetPlayerScore(dwRoleId, nScore, szBattleType)
	szBattleType = szBattleType or "Normal"
	local nGrade, tbGradeSetting = self:GetEvaluationFromScore(nScore)
	local tbBattteSetting = InDifferBattle.tbBattleTypeSetting[szBattleType]
	if not tbBattteSetting.NextType then
		return
	end
	local tbNextBattteSetting = InDifferBattle.tbBattleTypeSetting[tbBattteSetting.NextType]	
	if not tbNextBattteSetting then
		return
	end

	if GetTimeFrameState(tbNextBattteSetting.szOpenTimeFrame) ~= 1 then
		return
	end

	if nGrade < tbNextBattteSetting.nNeedGrade then
		return
	end	
	local pPlayer = KPlayer.GetPlayerObjById(dwRoleId)
	if not pPlayer then
		local nQualifyOpenTime = InDifferBattle:GetNextOpenTime(tbBattteSetting.NextType)
		local szCmd = string.format("InDifferBattle:DelayOnGetQualifyTime('%d', '%s', '%s')", nScore, nQualifyOpenTime, szBattleType) 
		KPlayer.AddDelayCmd(dwRoleId, szCmd, string.format("%s|%s|%s|%s", "InDifferBattleDelayOnGetQualifyTime", nScore, nQualifyOpenTime, szBattleType));
		return
	end

	self:SetPlayerQualify(pPlayer, szBattleType, nScore)
end

function InDifferBattle:SetPlayerQualify(pPlayer, szBattleType, nScore)
	local tbBattteSetting = InDifferBattle.tbBattleTypeSetting[szBattleType]
	local tbNextBattteSetting = InDifferBattle.tbBattleTypeSetting[tbBattteSetting.NextType]	

	local bNowCanInNext = self:IsQualifyInBattleType(pPlayer, tbBattteSetting.NextType, true)
	local nGrade, tbGradeSetting = self:GetEvaluationFromScore(nScore)
	
	if not bNowCanInNext then
		local nQualifyOpenTime = self:GetNextOpenTime(tbBattteSetting.NextType)
		pPlayer.SetUserValue(self.tbDefine.SAVE_GROUP, tbNextBattteSetting.nKeyQualifyTime, nQualifyOpenTime)

		Mail:SendSystemMail({
			To = pPlayer.dwID,
			Title = string.format("%s心魔幻境資格通知", tbNextBattteSetting.szName),
			Text = string.format("    本次%s心魔幻境的個人積分為：[FFFE0D]%s[-][%s]（%s）[-]\n    恭喜你已獲得[FFFE0D]%s心魔幻境[-]的參賽資格，將於[FFFE0D]%s[-]開啟，屆時你將於同入圍%s賽的俠士共同角逐，期待你的參與！\n    [00FF00][url=openwnd:瞭解規則, GeneralHelpPanel, 'InDifferBattleContestHelp'][-]",
				   tbBattteSetting.szName, nScore, tbGradeSetting.szColor, tbGradeSetting.szName, tbNextBattteSetting.szName, Lib:GetTimeStr3(nQualifyOpenTime), tbNextBattteSetting.szName ),
			tbAttach 	= { {"AddTimeTitle", tbNextBattteSetting.nQualifyTitleId, nQualifyOpenTime} },
			nLogReazon = Env.LogWay_InDifferBattleUpgrade,
			tbParams 	= {LogReason2 = tbBattteSetting.NextType};
			})								

		if pPlayer.dwKinId ~= 0 then
			local szNotifyMsg = string.format("恭喜幫派成員「%s」獲得了[FFFE0D]%s心魔幻境[-]參賽資格！", pPlayer.szName, tbNextBattteSetting.szName)
			ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.Kin, szNotifyMsg, pPlayer.dwKinId)
		end
	end
end

function InDifferBattle:SendPlayerAwardS(dwRoleId, nResult, nMatchTime, nScore, nKillCount, szBattleType)
	--心魔的地图托管时间是等于比赛时长的, 进阶信息就直接记在玩家身上吧
	local nGrade, tbGradeSetting = self:GetEvaluationFromScore(nScore)
	local tbBattleSetting = InDifferBattle.tbBattleTypeSetting[szBattleType]
	local pPlayer = KPlayer.GetPlayerObjById(dwRoleId)
	if  pPlayer then
		if nResult == Env.LogRound_SUCCESS then
			local dwKinId = pPlayer.dwKinId
			local szNotifyMsg = string.format("恭喜「%s」在心魔幻境%s中憑藉強悍的生存技巧獲得了優勝！", pPlayer.szName, tbBattleSetting.nNeedGrade and tbBattleSetting.szName .. "賽" or "")
			if dwKinId ~= 0 then
				ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.Kin, szNotifyMsg, dwKinId);		
			end
			if tbBattleSetting.nNeedGrade then
				KPlayer.SendWorldNotify(0, 999, szNotifyMsg, 0, 1);
			end
			Sdk:SendTXLuckyBagMail(pPlayer, "InDifferBattleWin");
		end

		pPlayer.TLogRoundFlow(Env.LogWay_InDifferBattle, tbDefine.nFightMapTemplateId, nScore, nMatchTime, nResult, 0, 0);
		AssistClient:ReportQQScore(pPlayer, Env.QQReport_InDifferBattleScore, nScore, 0, 1)
		AssistClient:ReportQQScore(pPlayer, Env.QQReport_InDifferBattleKillCount, nKillCount, 0, 1)
	end
	
	local tbGetAward;
	for i, v in ipairs(self.tbDefine.tbGetHonorSetting) do
		if nScore >= v.nScoreMin then
			tbGetAward = v["tbAward"..szBattleType] 
		else
			break;
		end
	end

	Mail:SendSystemMail({
		To = dwRoleId,
		Title =  tbBattleSetting.szName ..  "心魔幻境獎勵",
		Text = string.format("尊敬的俠士：\n\n    %s本次心魔幻境的個人積分為：[FFFE0D]%d[-][%s]（%s）[-]，附件是您的心魔幻境獎勵，請查收！\n\n 小提示：個人積分越高獎勵越豐厚！[00FF00][url=openwnd:積分規則, AttributeDescription, '', false, '%s'][-]",  
				nResult == Env.LogRound_SUCCESS and "恭喜您獲得本次心魔幻境的優勝！" or "", nScore, tbGradeSetting.szColor, tbGradeSetting.szName, tbBattleSetting.szScroeDescHelpKey ),
		tbAttach = tbGetAward,
		nLogReazon = Env.LogWay_InDifferBattleAward,
		tbParams = {LogReason2 = nResult},
		})
	
	Calendar:OnCompleteAct(dwRoleId, "InDifferBattle", nGrade)
	self:OnGetPlayerScore(dwRoleId, nScore, szBattleType) 
end



function InDifferBattle:AddPlayerHonorBox(pPlayer, nHonor, nLogReazon, nLogReazon2)
	if nLogReazon2 == Env.LogRound_SUCCESS then --记录下获胜还有对应成就之类的
		pPlayer.SetUserValue( tbDefine.SAVE_GROUP, tbDefine.KEY_WIN_TIMES, pPlayer.GetUserValue(tbDefine.SAVE_GROUP, tbDefine.KEY_WIN_TIMES) + 1)
		Kin:RedBagOnEvent(pPlayer, Kin.tbRedBagEvents.in_differ_battle)
    end

	local nCurHonor = pPlayer.GetUserValue(tbDefine.SAVE_GROUP, tbDefine.KEY_CUR_HONOR);
    nCurHonor = nCurHonor + nHonor;

    local tbAwardList = {};
	for _, v in ipairs(tbDefine.tbExChangeBoxInfo) do
		local nGiveItemId, nCostHonorPer = unpack(v)
		local nCanChangeNum = math.floor(nCurHonor / nCostHonorPer)
		if nCanChangeNum > 0 then
			nCurHonor = nCurHonor - nCanChangeNum * nCostHonorPer
			table.insert(tbAwardList, {"item", nGiveItemId, nCanChangeNum })
		end
	end
    pPlayer.SetUserValue(tbDefine.SAVE_GROUP, tbDefine.KEY_CUR_HONOR, nCurHonor);

    if next(tbAwardList) then
    	pPlayer.SendAward(tbAwardList, nil, nil, nLogReazon, nLogReazon2)
    else
    	pPlayer.CenterMsg(string.format("您獲得%d點心魔幻境榮譽", nHonor), true)
    end
end

function InDifferBattle:AddTeamImity(tbRetData)
	for dwRoleId1, v in pairs(tbRetData) do
		for dwRoleId2, nImitity in pairs(v) do
			FriendShip:AddImitity(dwRoleId1, dwRoleId2, nImitity, Env.LogWay_InDifferBattleAward)
		end
	end

	FriendRecall:OnInDifferBattleTeamImity(tbRetData);
end

function InDifferBattle:CheckTips()
	local nTimeNow = GetTime();
	local nLocalDay = Lib:GetLocalDay();
	if not self.tbTipCheckInfo or self.tbTipCheckInfo.nCheckDay ~= nLocalDay then
		self.tbTipCheckInfo = {};
		self.tbTipCheckInfo.nCheckDay = nLocalDay;
		self.tbTipCheckInfo.tbTipInfo = {};
		self.tbTipCheckInfo.bNeedCheck = false;
		self.tbTipCheckInfo.nOpenDayZeroTime = nil;

		for szType, v in pairs(InDifferBattle.tbBattleTypeSetting) do
			if v.nNeedGrade then
				local nOpenTime = self:GetNextOpenTime(szType, nTimeNow);
				if nOpenTime and nOpenTime > nTimeNow and nOpenTime - nTimeNow < InDifferBattle.tbDefine.nPreTipTime + 86400 then
					self.tbTipCheckInfo.tbTipInfo[szType] = nOpenTime;
					self.tbTipCheckInfo.bNeedCheck = true;
					if Lib:GetLocalDay(nOpenTime) == nLocalDay then
						self.tbTipCheckInfo.nOpenDayZeroTime = 	Lib:GetTodayZeroHour()
					end
					
				end	
			end
		end
	end

	return self.tbTipCheckInfo.bNeedCheck, self.tbTipCheckInfo.tbTipInfo, nTimeNow, self.tbTipCheckInfo.nOpenDayZeroTime;
end


function InDifferBattle:OnPlayerLogin_League(pPlayer)
	--资格赛开启前两天有对应的邮件提示， 比赛当天登录也有对应邮件提示
	local bNeedCheck, tbTipInfo, nTimeNow, nOpenDayZeroTime = self:CheckTips();
	if not bNeedCheck then
		return;
	end
	for szType, nOpenTime in pairs(tbTipInfo) do
		local nLastTime = nOpenTime - nTimeNow;
		if nLastTime > 0 and nLastTime < InDifferBattle.tbDefine.nPreTipTime then
			--如果上次登录时间 已经也是小于这个时间间隔的话则不处理，说明已经发过了
			local nLastLoginTime = pPlayer.GetLastLoginTime();
			local nMyLastTime = nOpenTime - nLastLoginTime
			if nMyLastTime >= InDifferBattle.tbDefine.nPreTipTime or  (nOpenDayZeroTime and nLastLoginTime <= nOpenDayZeroTime)  then
				if InDifferBattle:IsQualifyInBattleType(pPlayer, szType) then
					local tbSetting = InDifferBattle.tbBattleTypeSetting[szType]
					local szTimeInfo = Lib:GetTimeStr4(nOpenTime);
					local tbTipMail = {
						To = pPlayer.dwID,
						Title = tbSetting.tbLeagueTipMailInfo[1],
						Text = string.format(tbSetting.tbLeagueTipMailInfo[2], szTimeInfo),
						From = "心魔幻境",
					};
					Mail:SendSystemMail(tbTipMail);
				end
			end
		end
	end
end

function InDifferBattle:CheckSendQualifyWinnerNews(szBattleType)
	if not self.tbSynQualifyZoneWinRoleIds or not next(self.tbSynQualifyZoneWinRoleIds) then
		return
	end

	local tbShowInfo = {};
	for i,v in ipairs(self.tbSynQualifyZoneWinRoleIds) do
		local pRole = KPlayer.GetRoleStayInfo(v)
		local dwKinId = pRole.dwKinId
		local szKinName = ""
		local nFightPower = 0;
		if dwKinId ~= 0 then
			local tbKin = Kin:GetKinById(dwKinId)
			if tbKin then
				szKinName = tbKin.szName
			end
		end
		local pAsync = KPlayer.GetAsyncData(v)
		if pAsync then
			nFightPower = pAsync.GetFightPower()
		end
		table.insert(tbShowInfo, {szName = pRole.szName,
                                    nLevel = pRole.nLevel,
                                    nFaction = pRole.nFaction,
                                    nHonorLevel = pRole.nHonorLevel,
                                    szKinName = szKinName,
                                    nFightPower = nFightPower});

	end
	NewInformation:AddInfomation("InDifferBattle" .. GetTime(), GetTime() + 7 * 3600 * 24, { Type1 = "InDifferBattle",Type2 = szBattleType, tbList = tbShowInfo }, {szTitle = "心魔幻境系列賽", nReqLevel = 10, szUiName = "StarTower"});

	self.tbSynQualifyZoneWinRoleIds = nil;
end

function InDifferBattle:OnSynQualifyBattleWinRoleIds(tbWinRoleList)
	if not self.tbSynQualifyZoneWinRoleIds then
		return
	end
	for i,v in ipairs(tbWinRoleList) do
		local pRole = KPlayer.GetRoleStayInfo(v)
		if  pRole then
			table.insert(self.tbSynQualifyZoneWinRoleIds, v)
		end
	end
end