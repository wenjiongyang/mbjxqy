local FactionMonkey = FactionBattle.FactionMonkey
--[[

	宕机应急方案：

		活动开启时宕机（没有start），就不会end
		累积到下次评选开始时结算
		（可手动强制开启）

		活动结算时宕机
		* （没有end，可手动强制结算，就算不强制结算，也要把FactionBattle.tbBattleData.tbMonkeyData.nStartTime 设为 0 下次评选才能开启）
		不强制结算并将FactionBattle.tbBattleData.tbMonkeyData.nStartTime设为 0则将全部累积到下一次重新评选

		【*】没有start可自动累积评选，没有end必须热更新将nStartTime重置为0，下一次才可评选

	数据存储结构：

	-- 所有候选人信息
	FactionBattle.tbBattleData.tbMonkeyData.tbMonkeyInfo =
	{
		[nFaction] =
		{
			[1] = {
				nScore = 0,
				nScoreTime = 123456789,
				nSession = 0,
				nPlayerId = 123456789,
			},
		}
	}

	-- 评选开始时间（初始化为 0，评选结束重置 0）
	FactionBattle.tbBattleData.tbMonkeyData.nStartTime = 123456789

	-- 已经参选过的门派竞技届数（初始化为 0，如果该值为3，表示1,2,3届的门派竞技新人王已参选过）
	-- 在start的时候更新这个值而不在end的时候更新是为了防止投票期间又开了门派竞技，
	-- 那更新时候的值和评选时候的值就会不一样，导致这期间的新人王就评选不了
	FactionBattle.tbBattleData.tbMonkeyData.nChosedSession

	-- 是为了备份上一次的门派竞技届数（一般正常情况下不需要回滚）
	-- 有一种情况，如果有start，没有end（宕机），这时候想累积到下一次一起评选，这时只需要将
	-- nStartTime重置为 0，则在下一次评选自动回滚到 nBackUpSession的版本
	FactionBattle.tbBattleData.tbMonkeyData.nBackUpSession

	-- 目前举行过几次大师兄
	FactionBattle.tbBattleData.tbMonkeyData.nMonkeySession

]]

-- 如果宕机了需要强制开启传bForce，
-- 没有执行end强制开启会回滚（若不想回滚可将FactionBattle.tbBattleData.tbMonkeyData.nBackUpSession设为-1）！
function FactionMonkey:StartFactionMonkey(bForce)

	Log("FactionMonkey StartFactionMonkey nStartTime ======== ",FactionBattle.tbBattleData.tbMonkeyData.nStartTime)
	Log("FactionMonkey StartFactionMonkey nChosedSession ======== ",FactionBattle.tbBattleData.tbMonkeyData.nChosedSession)
	Log("FactionMonkey StartFactionMonkey nMonkeySession ======== ",FactionBattle.tbBattleData.tbMonkeyData.nMonkeySession)
	Log("FactionMonkey StartFactionMonkey nBackUpSession ======== ",FactionBattle.tbBattleData.tbMonkeyData.nBackUpSession)
	Log("FactionMonkey StartFactionMonkey is can start ======== ",self:SessionCount(),os.date("*t",GetTime()).day,bForce)

	if not bForce and not self:IsCanStartMonkey() then
		return
	end

	local tbMonkeyData = FactionBattle.tbBattleData.tbMonkeyData

	local nCurSession = self:SessionCount() 								-- 不直接用FactionBattle.tbBattleData.nCurSession原因是：该值是在门派竞技开始的时候就更新的，
																			-- 而FactionBattle.tbWinnerInfo是在结束的时候更新的
																			-- 如果在门派竞技期间开启了就悲剧了,该值更新了但FactionBattle.tbWinnerInfo中没有数据

	local tbCandidate = self:GenCandidates(FactionBattle.tbBattleData);

	if FactionBattle.tbBattleData.tbOldBattleData then
		--存在合服数据
		for _,tbBattleData in pairs(FactionBattle.tbBattleData.tbOldBattleData) do
			local tbOldCandidate = self:GenCandidates(tbBattleData);
			self:MergeCandidates(tbCandidate, tbOldCandidate)
		end

		FactionBattle.tbBattleData.tbOldBattleData = nil
	end

	if not next(tbCandidate) then
		Log(string.format([[
			FactionMonkey_StartFactionMonkey how dare tbMonkeyInfo is a { } , no monkeys ! nStartTime is %d ,nChosedSession is %d, session count is %d
			]],tbMonkeyData.nStartTime,tbMonkeyData.nChosedSession,nCurSession))
		return
	end

	tbMonkeyData.tbMonkeyInfo = self:Distinct(tbCandidate)   				-- 存库的是没有排序的数据

	-- 先备份评选时的版本
	tbMonkeyData.nBackUpSession = tbMonkeyData.nChosedSession

	tbMonkeyData.nStartTime = GetTime() 									-- 更新开始评选时间

	tbMonkeyData.nChosedSession = nCurSession

	self:SynSwitch()

	Log("FactionMonkey_StartFactionMonkey Begin Vote Monkey !",os.date("%c",tbMonkeyData.nStartTime),tbMonkeyData.nBackUpSession,tbMonkeyData.nChosedSession)
	Log("FactionMonkey_StartFactionMonkey log begin ------ ")
	self:LogMonkey(tbMonkeyData.tbMonkeyInfo)
	Log("FactionMonkey_StartFactionMonkey log end ------ ")
end

function FactionMonkey:EndFactionMonkey(bForce)

	Log("FactionMonkey EndFactionMonkey nStartTime ======== ",FactionBattle.tbBattleData.tbMonkeyData.nStartTime)
	Log("FactionMonkey EndFactionMonkey nChosedSession ======== ",FactionBattle.tbBattleData.tbMonkeyData.nChosedSession)
	Log("FactionMonkey EndFactionMonkey nMonkeySession ======== ",FactionBattle.tbBattleData.tbMonkeyData.nMonkeySession)
	Log("FactionMonkey EndFactionMonkey nBackUpSession ======== ",FactionBattle.tbBattleData.tbMonkeyData.nBackUpSession)
	Log("FactionMonkey EndFactionMonkey is can start ======== ",self:SessionCount(),os.date("*t",GetTime()).day,bForce)

	if not bForce and not self:IsCanEndMonkey() then
		return
	end

	local tbMonkeyData = FactionBattle.tbBattleData.tbMonkeyData

	if not next(tbMonkeyData.tbMonkeyInfo) then
		Log(string.format([[
			FactionMonkey_EndFactionMonkey not monkey info,  nStartTime is %d ,nChosedSession is %d
			]],tbMonkeyData.nStartTime,tbMonkeyData.nChosedSession))
		return 
	end

	tbMonkeyData.nStartTime = 0  				-- 活动结束

	tbMonkeyData.nBackUpSession = -1 			-- 删除回滚备份

	FactionBattle.tbBattleData.tbMonkeyData.nMonkeySession = FactionBattle.tbBattleData.tbMonkeyData.nMonkeySession + 1

	local tbResultMonkey = self:SortMonkey()

	self:MonkeyReward(tbResultMonkey)

	self:SynSwitch()

	-- 最新消息
	local tbInfo = {}
	local tbMonkey = self:ArrangeResult(tbResultMonkey)
	tbInfo.nMonkeySession = FactionBattle.tbBattleData.tbMonkeyData.nMonkeySession
	tbInfo.tbMonkey = tbMonkey

	NewInformation:AddInfomation("FactionMonkey",GetTime() + FactionBattle.nNewInfomationValidTime,tbInfo)

	for nFaction, tbPlayers in pairs(tbResultMonkey) do
		if FactionBattle.MONKEY_TITLE_ID[nFaction] then
			local pPlayer = KPlayer.GetPlayerObjById((tbPlayers[1] or {}).nPlayerId or 0);
			if pPlayer then
				pPlayer.CallClientScript("GameSetting.Comment:OnEvent", GameSetting.Comment.Type_FactionBattle_BigBrother);
			end
		end
	end
	Log("FactionMonkey_EndFactionMonkey End Vote Monkey !",os.date("%c",GetTime()),tbMonkeyData.nBackUpSession,tbMonkeyData.nChosedSession,tbMonkeyData.nStartTime)
	Log("FactionMonkey_EndFactionMonkey log begin ------ ")
	self:LogMonkey(tbResultMonkey)
	Log("FactionMonkey_EndFactionMonkey log end ------ ")
end

-- 整理(把各门派的大师兄整理出来)
function FactionMonkey:ArrangeResult(tbMonkey)
	local tbResult = {}
	for nFaction,tbPlayers in pairs(tbMonkey) do
		if tbPlayers[1] and next(tbPlayers[1]) then
			local tbPlayerInfo = {}
			local nPlayerId = tbPlayers[1].nPlayerId or 0
			local pPlayerStay = KPlayer.GetRoleStayInfo(nPlayerId) or {};
			local pKinData = Kin:GetKinById(pPlayerStay.dwKinId or 0) or {};

			tbPlayerInfo.nPlayerId = nPlayerId
			tbPlayerInfo.szName = pPlayerStay.szName or XT("無")
			tbPlayerInfo.nLevel = pPlayerStay.nLevel or 0
			tbPlayerInfo.nFightPower = FightPower:GetFightPower(nPlayerId)
			tbPlayerInfo.nFaction = nFaction
			tbPlayerInfo.nHonorLevel = pPlayerStay.nHonorLevel or 0
			tbPlayerInfo.nPortrait = pPlayerStay.nPortrait or 0
			tbPlayerInfo.szKinName = pKinData.szName or ""

			tbResult[nFaction] = tbPlayerInfo
		end
	end
	return tbResult
end

-- 发奖
function FactionMonkey:MonkeyReward(tbResultMonkey)
	local nNowTime = GetTime()
	local nValidTime = nNowTime + FactionBattle.MONKEY_TITLE_TIMEOUT
	for nFaction,tbPlayers in pairs(tbResultMonkey) do
		if next(tbPlayers) then
			local nTitleId = FactionBattle.MONKEY_TITLE_ID[nFaction]
			if nTitleId then
				local nMonkeyId = tbPlayers[1] and tbPlayers[1].nPlayerId or 0
				local pPlayer = KPlayer.GetPlayerObjById(nMonkeyId)
				local pStayInfo = pPlayer or KPlayer.GetRoleStayInfo(nMonkeyId)
				if pStayInfo then
					local tbMonkeyReward = {{"AddTimeTitle", nTitleId, nValidTime}}
					if FactionBattle.tbFactionMonkeyReward and next(FactionBattle.tbFactionMonkeyReward) then
						local tbReward = Lib:CopyTB(FactionBattle.tbFactionMonkeyReward)
						tbMonkeyReward = Lib:MergeTable(tbMonkeyReward, tbReward)
					end
					local szTitle = FactionBattle.tbMailSetting[nFaction].szTitle or "門派競選"
					local szText = FactionBattle.tbMailSetting[nFaction].szText or "門派競選稱號獎勵"
					local tbMail = {
						To = nMonkeyId;
						Title = szTitle;
						From = "系統";
						Text = szText;
						tbAttach = tbMonkeyReward;
						nLogReazon = Env.LogWay_FactionMonkey;
					};
					Mail:SendSystemMail(tbMail);

					Achievement:AddCount(nMonkeyId, "FactionBattleBrother_1", 1)

					if pPlayer then
						ChatMgr:SetNamePrefixByName(pPlayer, "FactionMonkey", nValidTime)
					else
						KPlayer.AddDelayCmd(nMonkeyId,
							string.format("ChatMgr:SetNamePrefixByName(me, 'FactionMonkey', %d)", nValidTime),
							string.format("%s|%d|%d", 'FactionMonkey', nValidTime, nFaction))
					end
					Log("FactionMonkey:MonkeyReward reward data " , nMonkeyId, nFaction, nTitleId, nValidTime)
				else
					Log("FactionMonkey:MonkeyReward no pStayInfo" , nMonkeyId, nFaction)
				end
			else
				Log("FactionMonkey:MonkeyReward can not find title id " , nMonkeyId, nFaction)
			end
		else
			Log("FactionMonkey:MonkeyReward no tbPlayers" , nFaction)
		end
	end
end

-- 排序
function FactionMonkey:SortMonkey()

	local tbMonkeyData = FactionBattle.tbBattleData.tbMonkeyData
	local tbMonkeyInfo = tbMonkeyData.tbMonkeyInfo

	local tbSortResult = {}
	 local function fnSort(a, b)
	 	if a.nScore == b.nScore then
	 		return a.nScoreTime < b.nScoreTime
	 	end
        return a.nScore > b.nScore;
    end

	for nFaction,tbPlayers in pairs(tbMonkeyInfo) do
		table.sort(tbPlayers,fnSort)
		tbSortResult[nFaction] = tbPlayers
	end

	return tbSortResult
end

function FactionMonkey:GenCandidates(tbBattleData)
	local tbMonkeyData = tbBattleData.tbMonkeyData

	--正常结束nBackUpSession都为 -1 ，如果宕机导致没有结束，下次评选会回滚到之前的版本
	if tbMonkeyData.nBackUpSession ~= -1 then
		tbMonkeyData.nChosedSession = tbMonkeyData.nBackUpSession
	end

	local nCurSession = self:SessionCount(tbBattleData) 					-- 不直接用FactionBattle.tbBattleData.nCurSession原因是：该值是在门派竞技开始的时候就更新的，
																			-- 而FactionBattle.tbWinnerInfo是在结束的时候更新的
																			-- 如果在门派竞技期间开启了就悲剧了,该值更新了但FactionBattle.tbWinnerInfo中没有数据

	return self:Candidates(tbMonkeyData.nChosedSession + 1,nCurSession, tbBattleData);
end

function FactionMonkey:MergeCandidates(tbA, tbB)
	for nFaction,tbList in pairs(tbB) do
		tbA[nFaction] = tbA[nFaction] or {}
		Lib:MergeTable(tbA[nFaction], tbList);
	end
	return tbA
end

-- 候选人
function FactionMonkey:Candidates(nStartSession, nEndSession, tbBattleData)
	local tbCandidate = {}

	if not nStartSession or not nEndSession or nStartSession > nEndSession then
		return tbCandidate
	end

	local tbFresher = tbBattleData.tbWinnerInfo

	for nSession = nStartSession,nEndSession do
		if tbFresher[nSession] then
			for nFaction,tbPlayerInfo in pairs(tbFresher[nSession]) do
				local nPlayerId = tbPlayerInfo.nPlayerId or 0
				local pStayInfo = KPlayer.GetPlayerObjById(nPlayerId) or KPlayer.GetRoleStayInfo(nPlayerId)
				if pStayInfo and pStayInfo.nFaction == nFaction then 				-- 转门派之后，之前的新人王不能进入候选人
					tbCandidate[nFaction] = tbCandidate[nFaction] or {}
					local tbInfo = {}
					tbInfo.nScore = 0
					tbInfo.nScoreTime = 0
					tbInfo.nSession = nSession
					tbInfo.nPlayerId = nPlayerId
					table.insert(tbCandidate[nFaction],tbInfo)
				end
			end
		else
			Log(string.format("FactionMonkey_Candidates can not find FactionBattle session data . session %d ",nSession))
		end
	end

	return tbCandidate
end

--去除重复
function FactionMonkey:Distinct(tbCandidate)

	local tbTemp = {}
	local tbDistinctCandidate = {}

	for nFaction,tbPlayers in pairs(tbCandidate) do

		tbTemp[nFaction] = tbTemp[nFaction] or {}
		tbDistinctCandidate[nFaction] = tbDistinctCandidate[nFaction] or {}

		for _,tbPlayerInfo in ipairs(tbPlayers) do
			if not tbTemp[nFaction][tbPlayerInfo.nPlayerId] then
				tbTemp[nFaction][tbPlayerInfo.nPlayerId] = true
				table.insert(tbDistinctCandidate[nFaction],tbPlayerInfo)
			end
		end
	end

	return tbDistinctCandidate
end

function FactionMonkey:OnSynData(pPlayer)

	local tbData = {}
	local tbMonkeyData = FactionBattle.tbBattleData.tbMonkeyData
	tbData.nStartTime = tbMonkeyData.nStartTime
	tbData.nChosedSession = tbMonkeyData.nChosedSession
	tbData.nMonkeySession = tbMonkeyData.nMonkeySession
	tbData.tbMonkey = tbMonkeyData.tbMonkeyInfo[pPlayer.nFaction] or {}

	for index,tbPlayerInfo in pairs(tbData.tbMonkey) do
		local pPlayerStay = KPlayer.GetRoleStayInfo(tbPlayerInfo.nPlayerId) or {};
		tbData.tbMonkey[index].szName = pPlayerStay.szName or XT("無")
		tbData.tbMonkey[index].nPortrait = pPlayerStay.nPortrait or 0
	end

	pPlayer.CallClientScript("FactionBattle.FactionMonkey:OnSynData", tbData)
end

-- 同步活动开关
function FactionMonkey:SynSwitch()
    local tbPlayer = KPlayer.GetAllPlayer()
    for _, pPlayer in pairs(tbPlayer) do
        pPlayer.CallClientScript("FactionBattle.FactionMonkey:SynSwitch", FactionBattle.tbBattleData.tbMonkeyData.nStartTime)
    end
end

function FactionMonkey:OnLogin(pPlayer)
	pPlayer.CallClientScript("FactionBattle.FactionMonkey:SynSwitch", FactionBattle.tbBattleData.tbMonkeyData.nStartTime)
end
--------------------------------投票相关-----------------------------

-- 投票
function FactionMonkey:VoteMonkey(pPlayer,dwMonkeyID)

	local tbMonkeyData = FactionBattle.tbBattleData.tbMonkeyData

	if not self:IsMonkeyStarting() or GetTime() > (tbMonkeyData.nStartTime + FactionBattle.MONKEY_VOTE_TIME * 60 * 60) then
		pPlayer.CenterMsg("投票時間已過，請下次再參與！")
		Log("[VoteMonkey] over time ",tbMonkeyData.nStartTime,self:IsMonkeyStarting())
		return
	end

	local tbMonkey = tbMonkeyData.tbMonkeyInfo[pPlayer.nFaction]
	if not tbMonkey then
		pPlayer.CenterMsg("找不到評選人")
		Log("[VoteMonkey] can find tbMonkey ",dwMonkeyID,pPlayer.nFaction,pPlayer.dwID,pPlayer.szName)
		return
	end

	local nIndex = self:MonkeyIndex(pPlayer,dwMonkeyID)
	if not nIndex then
		pPlayer.CenterMsg("找不到評選人")
		Log("[VoteMonkey] can find nIndex ",dwMonkeyID,pPlayer.nFaction,pPlayer.dwID,pPlayer.szName)
		return
	end

	self:CheckResetVote(pPlayer)

	local bRet,szMsg = FactionBattle:CheckCommondVote(pPlayer)
	if not bRet then
		pPlayer.CenterMsg(szMsg)
		return
	end
	local nRemainTime = FactionBattle:RemainVote(pPlayer) - 1

	pPlayer.SetUserValue(FactionBattle.SAVE_GROUP_MONKEY, FactionBattle.KEY_VOTE, nRemainTime);

	local nScore = FactionBattle.tbHonorVoteScore[pPlayer.nHonorLevel] or 0

	tbMonkey[nIndex].nScore = tbMonkey[nIndex].nScore + nScore
	tbMonkey[nIndex].nScoreTime = GetTime()

	self:OnSynData(pPlayer);

	pPlayer.CenterMsg("投票成功");

	Log("[VoteMonkey] vote ",dwMonkeyID,nIndex,pPlayer.dwID,pPlayer.szName,pPlayer.nHonorLevel,nScore,tbMonkey[nIndex].nScore,nRemainTime,pPlayer.nFaction)
end

-- 索引
function FactionMonkey:MonkeyIndex(pPlayer,dwMonkeyID)
	local nIndex

	local tbMonkeyData = FactionBattle.tbBattleData.tbMonkeyData
	local tbMonkey = tbMonkeyData.tbMonkeyInfo[pPlayer.nFaction] or {}
	for index,tbPlayerInfo in pairs(tbMonkey) do
		if tbPlayerInfo.nPlayerId == dwMonkeyID then
			nIndex = index
			break
		end
	end

	return nIndex
end

-- 打开界面的时候和投票的时候检查
-- 重置玩家投票次数
function FactionMonkey:CheckResetVote(pPlayer)
	local nVoteTime = pPlayer.GetUserValue(FactionBattle.SAVE_GROUP_MONKEY, FactionBattle.KEY_STARTTIME);
	local nStartTime = FactionBattle.tbBattleData.tbMonkeyData.nStartTime

	if nStartTime == 0 then
		return
	end

	if nVoteTime ~= nStartTime then
		pPlayer.SetUserValue(FactionBattle.SAVE_GROUP_MONKEY, FactionBattle.KEY_VOTE,FactionBattle.MAX_VOTE);
		pPlayer.SetUserValue(FactionBattle.SAVE_GROUP_MONKEY, FactionBattle.KEY_STARTTIME,nStartTime);
	end
end

----------------------------------------------- 接口 ------------------------------------------------

function FactionMonkey:LogMonkey(tbMonkey)
	for nFaction,v in pairs(tbMonkey or {}) do
		Log("monkey faction ",nFaction)
		for index,tbPlayerInfo in ipairs(v) do
			Log("monkey data ",index,tbPlayerInfo.nScore or -1,tbPlayerInfo.nScoreTime or -1,tbPlayerInfo.nSession or -1,tbPlayerInfo.nPlayerId or -1)
		end
	end
end

function FactionMonkey:IsMonkeyStarting(tbBattleData)
	local tbBattleData = tbBattleData or FactionBattle.tbBattleData
	local nStartTime = tbBattleData.tbMonkeyData.nStartTime
	return nStartTime ~= 0 and GetTime() > nStartTime
end

-- 在门派竞技start的时候就会self.tbWinnerInfo[self.tbBattleData.nCurSession] = {}初始化标，所以评判标准是self.tbWinnerInfo[self.tbBattleData.nCurSession] = {}里有数据
-- 但这种情况下一般是最新一届为{}，所以只限定最新一届，若是往届确实没有人打导致数据为{}，这一届还是要算上的
function FactionMonkey:SessionCount(tbBattleData)
	local tbBattleData = tbBattleData or FactionBattle.tbBattleData or {}
	local tbWinnerInfo = tbBattleData.tbWinnerInfo or {}

	local nSessionCount = tbBattleData.nCurSession or -1
	if nSessionCount < 0 then
		Log("[FactionMonkey] SessionCount nil")
		Lib:LogTB(tbBattleData)
		return 0
	end
	if nSessionCount ~= 0 and (not tbWinnerInfo[nSessionCount] or not next(tbWinnerInfo[nSessionCount])) then
		nSessionCount = nSessionCount - 1
		Log("[FactionMonkey] SessionCount Minus ",nSessionCount,tbWinnerInfo[nSessionCount] and 1 or 0)
		Lib:LogTB(tbWinnerInfo)
	end

	return nSessionCount
end

function FactionMonkey:IsCanStartMonkey()
	return self:SessionCount() >= FactionBattle.MONKEY_SESSION_LIMIT_COUNT and os.date("*t",GetTime()).day == FactionBattle.MONKEY_START_DAY and not self:IsMonkeyStarting()
end

function FactionMonkey:IsCanEndMonkey()
	return self:SessionCount() >= FactionBattle.MONKEY_SESSION_LIMIT_COUNT and os.date("*t",GetTime()).day == FactionBattle.MONKEY_END_DAY and self:IsMonkeyStarting()
end

function FactionMonkey:DelCandidate(nFaction,nPlayerId)
	if not nFaction or not nPlayerId then
		return
	end
	local bIsSuccess = false
	local tbMonkeyData = FactionBattle.tbBattleData.tbMonkeyData
	if tbMonkeyData and tbMonkeyData.tbMonkeyInfo and tbMonkeyData.tbMonkeyInfo[nFaction] then
		local tbCandidate = tbMonkeyData.tbMonkeyInfo[nFaction]
		local nLen = #tbCandidate
		for nIndex=nLen,1,-1 do
			local tbData = tbCandidate[nIndex]
			if tbData and tbData.nPlayerId and tbData.nPlayerId == nPlayerId then
				table.remove(tbCandidate,nIndex)
				bIsSuccess = true
				break
			end
		end
	end

	if bIsSuccess then
		Log("[FactionMonkey] DelCandidate ",nPlayerId,nFaction)
	else
		Log("[FactionMonkey] DelCandidate fail",nPlayerId,nFaction)
	end
end