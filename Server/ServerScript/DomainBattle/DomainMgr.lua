--[[
DomainBattle.tbKinBattleReport = {
	[dwKinId] = {
		[dwRoleId] = {nScore, nKillNum, szRoleName} ; --[4] = dwRoleId 
	};
}
DomainBattle.tbAllFifhtMapId = {
	[nMapTemplateId] = nMapId;
}
DomainBattle.tbMapInst = 
{
	[nMapId] = {
		tbFlagState = {
			{me.dwKinId, "szKinName" };  --[nFlagIndex] = {dwKinId, tbKin.szName};
			{-1,  		 "szKinName" };  
			{dwKinId3, "szKinName" }; 
		};
	};
}
]]

DomainBattle.tbMapInst = DomainBattle.tbMapInst or {} --放的是实际实例
local tbMapInst = DomainBattle.tbMapInst
local define = DomainBattle.define

DomainBattle.nDataVersion = 0 
DomainBattle.tbOwnerMap = DomainBattle.tbOwnerMap or {}

function DomainBattle:SetData(dwKinId, tbTar, Key, Val)
	tbTar[Key] = Val 
	self.nDataVersion = self.nDataVersion + 1 --全局的如领地归属变化用nDataVersion， 宣战的操作比较少就也用同个版本号了
end

--获取各个领地的家族占领情况
function DomainBattle:GetDomainMapOwner()
	return ScriptData:GetValue("DomainBattle").tbMapOwner
end

function DomainBattle:GetDomainOwnerMap()
	return self.tbOwnerMap
end

function DomainBattle:GetOpenDomainDay( )
	return ScriptData:GetValue("DomainBattle").nOpenWarDay
end

function DomainBattle:GetKinWarDeclare()
	return ScriptData:GetValue("DomainBattle").tbKinWarDeclare
end

function DomainBattle:SetOpenDomainDay(nDay)
	local tbData = ScriptData:GetValue("DomainBattle")
	local nOldnOpenWarDay = tbData.nOpenWarDay
	if nDay > 0 and nOldnOpenWarDay ~= nDay then --正的天数是开启
		tbData.nBattleVersion = (tbData.nBattleVersion or 0) + 1
	end
	tbData.nOpenWarDay = nDay
	self.nDataVersion = self.nDataVersion + 1
end

function DomainBattle:GetBattleVersion()
	return ScriptData:GetValue("DomainBattle").nBattleVersion or 0;
end

function DomainBattle:OnServerStart()
	if  GetTimeFrameState(define.szOpenTimeFrame) ~= 1 then
		return
	end
	local tbData = ScriptData:GetValue("DomainBattle")
	if not (tbData.tbMapOwner and tbData.nOpenWarDay and tbData.tbKinWarDeclare) then
		tbData.tbMapOwner = {}; -- [nMapId] = dwkinId
		tbData.nOpenWarDay = 0; --正的是开启，负的是今天打完了
		tbData.tbKinWarDeclare = {} ; --各个家族的宣战地图
		tbData.nBattleVersion = 0; --每一次开启宣战时宣战天数与上次不一样则 + 1; 这个
		-- tbData.tbMakeUpInfo = {  --对合服后的补偿数据，每次设
		-- 	nMakeUpTime = 0; --每补偿一次+ 1，第一次补偿时是有额外的占领拍卖的
		-- 	tbMakeUpKins = { [dwKinId] = nMapTemplateId }
			-- nVersion1 = nVersion1;
			-- nVersion2 = nVersion2;
		-- } 
		--
	end

	local tbData = self:GetDomainMapOwner();
	for nMapTemplateId, dwKinId in pairs(tbData) do
		assert(self.tbMapLevel[nMapTemplateId], nMapTemplateId)
		local tbKin = Kin:GetKinById(dwKinId)
		if not tbKin then
			tbData[nMapTemplateId] = nil;
		end
	end

	self:GenerateOwnerMap()

	--时间轴和开启时间到则直接宣战开启
	if self:GetOpenDomainDay() == Lib:GetLocalDay()  then
		self:StartDeclareWar();
	end

	--创建对应的城主npc
	self:SetMasterStatue()
end

function DomainBattle:SetMasterStatue()
	local nOldnStatueNpcId = self.nStatueNpcId
	if nOldnStatueNpcId then
		local pOldNpc = KNpc.GetById(nOldnStatueNpcId)
		if pOldNpc then
			pOldNpc.Delete();
		end
		self.nStatueNpcId = nil;
	end

	local nMasterId = self:GetMasterLeaderId()
	if nMasterId and nMasterId ~= 0 then
		local pRole = KPlayer.GetRoleStayInfo(nMasterId)
		if not pRole then
			Log(debug.traceback())
			return
		end
		local nStatusId = define.tbMasterStatueId[pRole.nFaction]
		if not nStatusId then
			Log(debug.traceback())
			return
		end
		local nMapId, nX, nY, nDir = unpack(define.tbMasterStatuePos)
		local pNpc = KNpc.Add(nStatusId, 1, 0, nMapId, nX, nY, 0, nDir)
		if not pNpc then
			Log(debug.traceback())
			return
		end
		pNpc.SetName(pRole.szName)
		self.nStatueNpcId = pNpc.nId
	end
end

--设置领地的归属家族 --这里是先设置  GetDomainMapOwner 的关闭，活动结束指令后会 根据该table反算
function DomainBattle:SetMapOwner(nMapTemplateId, dwKinId)
	local tbKin = Kin:GetKinById(dwKinId)
	if not tbKin then
		return
	end
	local tbMapOwner = self:GetDomainMapOwner()
	tbMapOwner[nMapTemplateId] = dwKinId
end

function DomainBattle:GenerateOwnerMap()
	local tbMapOwner = self:GetDomainMapOwner()
	local tbOwnerMap = {}
	for nMapTemplateId , dwKinId in pairs(tbMapOwner) do
		local bSkip = false
		local nHasOwnerMapId = tbOwnerMap[dwKinId] 
		if nHasOwnerMapId then
			local nHassMapLevel = self:GetMapLevel(nHasOwnerMapId)
			local nNewMapLevel = self:GetMapLevel(nMapTemplateId)
			if nNewMapLevel > nHassMapLevel then -- 等级值是越小越高级的。。。 如果同时占领低级地图
				bSkip = true;
				tbMapOwner[nMapTemplateId] = nil;
			else
				tbMapOwner[nHasOwnerMapId] = nil;
			end
		end

		if not bSkip then
			tbOwnerMap[dwKinId] = nMapTemplateId;
		end
	end
	self.tbOwnerMap = tbOwnerMap;
	local tbWarDeclare = self:GetKinWarDeclare()
	for dwKinId, nMapTemplateId in pairs(tbOwnerMap) do
		tbWarDeclare[dwKinId] = self:GetFatherLinkMap(nMapTemplateId)
	end

	local nCityMapId = self.tbMapSetting.nMapTemplateId
	for dwKinId, nMapTemplateId in pairs(tbWarDeclare) do
		if nMapTemplateId == nCityMapId then
			local nOwnerMapId = tbOwnerMap[dwKinId]
			if not nOwnerMapId or self:GetMapLevel(nOwnerMapId) ~= 2 then
				tbWarDeclare[dwKinId] = nil;
			end
		end 
	end

	self.nDataVersion = self.nDataVersion + 1;
end


--开启宣战
function DomainBattle:StartDeclareWar()
	local tbData = ScriptData:GetValue("DomainBattle") --第一次宣战时
	if not (tbData.tbMapOwner and tbData.nOpenWarDay and tbData.tbKinWarDeclare) then
		self:OnServerStart();
	end

	self:SetOpenDomainDay(Lib:GetLocalDay())
	self.bCanDeclarerWar = true

	local tbMapOwner = self:GetDomainMapOwner();
	for nMapTemplateId, dwKinId in pairs(tbMapOwner) do
		local tbKin = Kin:GetKinById(dwKinId)
		if not tbKin then
			tbMapOwner[nMapTemplateId] = nil;
		end
	end

	local tbWarDeclare = self:GetKinWarDeclare()
	for dwKinId, nMapId in pairs(tbWarDeclare) do
		local tbKin = Kin:GetKinById(dwKinId)
		if not tbKin then
			tbWarDeclare[dwKinId] = nil;
		end
	end

	KPlayer.SendWorldNotify(self.define.nMinLevel, 150, "今日攻城戰已開始接受宣戰！請謹慎宣戰，開戰後只能攻打宣戰目標。", 1, 1)
	Log("DomainBattle:StartDeclareWar", tbData.nBattleVersion, tbData.nOpenWarDay)
end

--宣战倒计时
function DomainBattle:NotifyKinDomainWar()
	if not self.bCanDeclarerWar then
		self:StartDeclareWar();
	end

	
	local fnNotifyKin = function (kinData, timeVal)
		local nKinId = kinData.nKinId
		if not self:GetKinWarDeclare()[nKinId] then
			ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.Kin, string.format("攻城戰將在%d分鐘後開始，本幫派尚未宣戰，請堂主或副堂主儘快去領地介面宣戰！", math.ceil(timeVal / 60) ), nKinId);
		end
	end

	local nLastTime;
	for i,time in ipairs(DomainBattle.define.tbNotifyBeginSet) do
		if not nLastTime then
			Kin:TraverseKin(fnNotifyKin, time)		
		else
			Timer:Register(Env.GAME_FPS * (nLastTime - time), function ()
				Kin:TraverseKin(fnNotifyKin, time)
			end)
		end
		nLastTime = time;
	end	
end

function DomainBattle:NotifyEndDomainWar()
	KPlayer.SendWorldNotify(self.define.nMinLevel, 150, "今日攻城戰將于10分鐘後開始，請未宣戰的幫派儘快宣戰，開戰後只能攻打宣戰目標。", 1, 1)
end

function DomainBattle:OnEnterKinMap(pPlayer)
	local dwKinId = pPlayer.dwKinId
	if self.tbKinFireTimers and  self.tbKinFireTimers[dwKinId] then
		pPlayer.CallClientScript("Ui:OpenWindow", "QYHLeftInfo", "DomainBattleFire", {nil, math.floor(Timer:GetRestTime(self.tbKinFireTimers[dwKinId]) / Env.GAME_FPS)})
	end
end

--开启活动
function DomainBattle:StartActivity()
	self.bCanDeclarerWar = nil;
	
	self.tbKinBattleReport = {} --各个家族的积分战报, --也可以看做所有参战的家族 --todo 找个合适的地方清楚下
	self.tbKinReportVersion = {};
	self.tbKinUseSpplyTimes = {}; --各个家族使用道具次数的统计
	self.tbPlayerSignTime = {}; --每个玩家的报名时间


	--根据当前的时间轴对应相应的强度等级
	self.nTimeFrameLevel = 1
	self.nTimeFrameNpcLevel = 1
	for i,v in ipairs(define.tbTimeFrameLevel) do
		local timeframe, npcLevel = unpack(v)
		if GetTimeFrameState(timeframe) ~= 1 then
			break;
		end
		self.nTimeFrameLevel = i
		self.nTimeFrameNpcLevel = npcLevel
	end

	self.nActivyStartTime = GetTime()
	

	--现在宣战的家族里 和 拥有领地的家族才能参战
	--决定每个家族的征战营地， 没有家族的
	local tbOwnerMap = self:GetDomainOwnerMap()
	local tbMapAttakKin = {};


	for dwKinId, nFightMap in pairs(self:GetKinWarDeclare()) do
		self.tbKinBattleReport[dwKinId] = {}
		tbMapAttakKin[nFightMap] = tbMapAttakKin[nFightMap] or {}
		table.insert(tbMapAttakKin[nFightMap], dwKinId)
	end
	self.tbMapAttakKin = tbMapAttakKin;

	for dwKinId, _ in pairs(tbOwnerMap) do
		self.tbKinBattleReport[dwKinId] = {  }
	end

	--开启实时语音
	for dwKinId, _ in pairs(self.tbKinBattleReport) do
		if not ChatMgr:IsKinHaveChatRoom(dwKinId) then
			ChatMgr:CreateKinChatRoom(dwKinId)
		end
	end

	self.tbFifhtMapId = {};
	self.nCreateMapNum = 0;
	for nMapTemplateId, v in pairs(self.tbMapLevel) do
		self.nCreateMapNum = self.nCreateMapNum + 1;
		CreateMap(nMapTemplateId);
	end
end

function DomainBattle:SendMemberAward()
	local nNow = GetTime()
	local tbOwnerMap = self:GetDomainOwnerMap();
	local tbMemberAwardSetting = Lib:CopyTB(self.define.tbMemberAwardSetting)
	if Activity:__IsActInProcessByType("DomainBattleAct") then
		for i, v in ipairs(tbMemberAwardSetting) do
			v.Award[1][2] = math.floor(1.5 * v.Award[1][2])
		end
	end
	local szGameAppid, nPlat, nServerIdentity, nAreaId = GetWorldConfifParam()

	for dwKinId, tbInfo in pairs(self.tbKinBattleReport) do
		local tbRanks = {}
		for dwRoleId, v2 in pairs(tbInfo) do
			v2[4] = dwRoleId
			table.insert(tbRanks, v2)
		end
		table.sort( tbRanks, function (a, b)
			if a[1] == b[1] then
				return a[2] > b[2] 
			end
			return a[1] > b[1] 
		end )

		local tbRankAward = {}
		local nAllPlayeNum = #tbRanks
		local nLastRankEnd = 0;
		for i, v in ipairs(tbMemberAwardSetting) do
			local nRankEnd = v.nPos
			if  v.fPos then
				nRankEnd = math.max(math.floor(nAllPlayeNum * v.fPos), nLastRankEnd + 1) 
			end
			table.insert(tbRankAward, {nRankEnd = nRankEnd, Award = v.Award})
			if nRankEnd >= nAllPlayeNum then
				break;
			end
			nLastRankEnd = nRankEnd
		end

		local nLastRankEnd = 0;
		local nHasMapId = tbOwnerMap[dwKinId]
		for i, v in ipairs(tbRankAward) do
			if nLastRankEnd > nAllPlayeNum then
				break;
			end
			for nRank = nLastRankEnd + 1, v.nRankEnd do
				local tbRoleInfo = tbRanks[nRank]
				if not tbRoleInfo then
					break;
				end
				local dwRoleId = tbRoleInfo[4]
				Mail:SendSystemMail(
				{
					To 	  		= dwRoleId,
					Title 		= "攻城戰獎勵",
					Text        = string.format("今日攻城戰結束了，你的征戰積分幫派排名第%d，獎勵請領取附件", nRank),
					tbAttach 	= v.Award,
					nLogReazon = Env.LogWay_DomainBattle,
				})
				local szAcc = KPlayer.GetPlayerAccount(dwRoleId) or ""
				local tbRoleStay = KPlayer.GetRoleStayInfo(dwRoleId) or {};
				local pPlayer = KPlayer.GetPlayerObjById(dwRoleId)
				local nIsPc = 0;
				if pPlayer and Sdk.tbPCVersionChannelNums[pPlayer.nChannelCode] then
					nIsPc = 1;
				end

				TLog("RoundFlow", szGameAppid, nPlat, nServerIdentity, szAcc, dwRoleId, Env.LogWay_DomainBattle, 0, tbInfo[dwRoleId][1], nNow - (self.tbPlayerSignTime[dwRoleId] or 0)
		 				, nHasMapId and Env.LogRound_SUCCESS or Env.LogRound_FAIL, nRank, 0,tbRoleStay.nLevel, nIsPc)
			end
			nLastRankEnd = v.nRankEnd
		end
	end
end

function DomainBattle:SendKinAward()
	--对每个地图进行循环，得出家族占领分 --TODO 这个需要对应的配置表检查
	local tbKinMapScore = {} -- [dwKinId] = { [nMap] = nScore }

	local tbCanGetAwardKins = {} -- [dwKinId] = nPlayedNum;
	for nMapTemplateId, nMapId in pairs(self.tbAllFifhtMapId) do --tbFifhtMapId 已经修改了
		local tbInst = self.tbMapInst[nMapId]
		for nFlagIndex, v in ipairs(tbInst.tbFlagState) do --[nFlagIndex] = {dwKinId, tbKin.szName};
			local dwKinId = v[1];
			if dwKinId ~= -1 and not tbCanGetAwardKins[dwKinId] then
				local nPlayedNum = 0
				local tbKinInfo = self.tbKinBattleReport[dwKinId]
				for dwRoleId, _ in pairs(tbKinInfo) do
					nPlayedNum = nPlayedNum + 1
				end	
				tbCanGetAwardKins[dwKinId] = nPlayedNum
				tbKinMapScore[dwKinId] = {}
			end
		end
	end




	for nMapTemplateId, nMapId in pairs(self.tbAllFifhtMapId) do --tbFifhtMapId 已经修改了
		local tbInst = self.tbMapInst[nMapId]
		for dwKinId, nPlayedNum in pairs(tbCanGetAwardKins) do
			local nScore = DomainBattle:GetMapFlagKinScore(nMapTemplateId, tbInst.tbFlagState, nPlayedNum, dwKinId);
			if nScore > 0 then
				tbKinMapScore[dwKinId][nMapTemplateId] = nScore	
			end
		end
	end

	local tbFlagAwardSetting;
	for i, v in ipairs(self.define.tbFlagAwardSetting) do
		if GetTimeFrameState(v[1]) ~= 1 then
			break;
		end
		tbFlagAwardSetting = v[2];
	end

	local tbOwnerMap = self:GetDomainOwnerMap()

	local tbKinPrestigeSetting = self.define.tbKinPrestigeSetting
	for dwKinId, v in pairs(tbKinMapScore) do
		local nMaxScore = 0;
		local nMaxScoreMapId = 0;
		for nMapTemplateId, nScore in pairs(v) do
			if nScore > nMaxScore then
				nMaxScore = nScore
				nMaxScoreMapId = nMapTemplateId
			end
		end
		Log("DomainBattle:SendKinAward", dwKinId, nMaxScore, nMaxScoreMapId)
		local nMapLevel;

		local tbKin = Kin:GetKinById(dwKinId)
		if tbKin then
			local nOwnerMapId = tbOwnerMap[dwKinId]
			if nOwnerMapId then
				nMapLevel = self:GetMapLevel(nOwnerMapId)
				tbKin:AddPrestige( tbKinPrestigeSetting[nMapLevel].nOwner, Env.LogWay_DomainBattle)
			elseif nMaxScoreMapId > 0 then
				nMapLevel = self:GetMapLevel(nMaxScoreMapId)
				tbKin:AddPrestige( tbKinPrestigeSetting[nMapLevel].nHasFlag, Env.LogWay_DomainBattle)
			end
		end

		if not nMapLevel then
			nMapLevel = 3
		end
		local szKey = "nMapLevel" .. nMapLevel
		local tbAwardSet = tbFlagAwardSetting
		if tbFlagAwardSetting[szKey] then
			tbAwardSet = tbFlagAwardSetting[szKey]
		end

		--针对max分进行奖励分配
		local tbItems = DomainBattle:GetActionAwardFromParam(tbAwardSet, nMaxScore)
		if next(tbItems) then
			local tbFighters = {}
			local tbKinInfo = self.tbKinBattleReport[dwKinId]
			for dwRoleId, _ in pairs(tbKinInfo) do
				tbFighters[dwRoleId] = true
			end			
			Kin:AddAuction(dwKinId, "DomainBattle", tbFighters, tbItems);	
		end
	end

	local nKinDecarlePrestige = self.define.nKinDecarlePrestige
	for dwKinId, tbInfo in pairs(self.tbKinBattleReport) do
		if not tbKinMapScore[dwKinId] then
			local tbKin = Kin:GetKinById(dwKinId)
			if tbKin then
				tbKin:AddPrestige(nKinDecarlePrestige, Env.LogWay_DomainBattle)
			end
		end
	end

end

function DomainBattle:SendCityMasterAward()
	local nLeaderId = self:GetMasterLeaderId()
	if nLeaderId and nLeaderId ~= 0 then
		local nEndTime = GetTime()
		local nWeekDay = Lib:GetLocalWeekDay()
		if nWeekDay == 2 then
			nEndTime = nEndTime + 3600 * 24 * 4
		elseif nWeekDay == 6 then
			nEndTime = nEndTime + 3600 * 24 * 3
		else
			Log("ERROR!!!!!  DomainBattle openActivy day is not WeekDay2 or WeekDay6", nWeekDay)
		end

		local tbAwardSetting;
		for i, v in ipairs(DomainBattle.define.tbCityMasterAward) do
			if GetTimeFrameState(v[1]) ~= 1 then
				break;
			end
			tbAwardSetting = v[2];
		end
		assert(tbAwardSetting)

		local tbMasterAward = Lib:CopyTB(tbAwardSetting)
		for i, v in ipairs(tbMasterAward) do
			if v[1] == "AddTimeTitle" then
				v[3] = 	nEndTime
			elseif v[1] == "item" then
				v[4] = 	nEndTime
			end
			
		end
		Mail:SendSystemMail(
		{
			To 	  		= nLeaderId,
			Title 		= "恭喜閣下成為襄陽城主",
			Text        = "在閣下英明神武的領導下，你的幫派同仇敵愾、浴血奮戰，終於奪下了襄陽城，獲得無上榮耀，你也成為了襄陽城新的主人，特贈與閣下賀禮，聊表心意。",
			tbAttach 	= tbMasterAward,
			From 		= "獨孤劍",
			nLogReazon = Env.LogWay_DomainBattleMaster,
		})

		Log("DomainBattle SendCityMasterAward", nLeaderId)
	end
	--城主雕像
	self:SetMasterStatue()
end

--结束活动 --每场结束都调，--最后一个调用才发消息通知
function DomainBattle:StopActivity(nMapTemplateId)
	if not self.tbFifhtMapId then
		return
	end
	self:SetOpenDomainDay( -Lib:GetLocalDay());
	self.tbFifhtMapId[nMapTemplateId] = nil;
	
	if next(self.tbFifhtMapId) then
		return 
	end

	self.tbKinFireTimers = {};

	--不能在公布结果前设置不然玩家看到的战报里宣战目标就可能不对了
	for dwKinId, tbInfo in pairs(self.tbKinBattleReport) do
		local tbAttakInfo, tbDefendInfo, nAttackMapId, nDefendMapId = self:GetKinFlagInfo(dwKinId)
		local tbData = {
			nAttackMapId = nAttackMapId;
			nDefendMapId = nDefendMapId;
			tbScore = tbInfo;   --[dwRoleId] = {nSore, nKillNum, szRoleName}
			tbAttakInfo = tbAttakInfo;  --[nIndex] = {  dwKinId, szName} --从小龙柱到大龙柱
			tbDefendInfo = tbDefendInfo; --[nIndex] = {  dwKinId, szName}
			nLeftTime =  0;
		}

		local kinData = Kin:GetKinById(dwKinId);
		if kinData then
			kinData:TraverseMembers(function (memberData)
				if  tbInfo[memberData.nMemberId] then
					local pMember = KPlayer.GetPlayerObjById(memberData.nMemberId) 
					if pMember then
						pMember.CallClientScript("DomainBattle:OnSynFightData", tbData, self.tbKinReportVersion[dwKinId])
					end
				end
				return true;
			end);

			--创建各自的家族篝火
			kinData:CallWithMap(function ()
				local nMapId = kinData:GetMapId();
				self.tbKinFireTimers[dwKinId] = Timer:Register(Env.GAME_FPS * self.define.nFireNpcTime, function ( ... )
					self.tbKinFireTimers[dwKinId]  = nil;
				end)

				SetMapSurvivalTime(nMapId, GetTime() + self.define.nFireNpcTime);
				local pFireNpc = KNpc.Add(self.define.FireNpcTemplateId, 1, 0, nMapId, Kin.GatherDef.FireNpcPosX, Kin.GatherDef.FireNpcPosY);
				if pFireNpc then
					pFireNpc.tbTmp.nKey = dwKinId;
				end
				
			end);

		end
	end

	local tbMsgData = {
		szType = "DomainBattleEndMsg";
		nTimeOut = GetTime() + 120;
	};
	
	for nMapTemplateId, nMapId in pairs(self.tbAllFifhtMapId) do
		KPlayer.MapBoardcastScript(nMapId, "Ui:SynNotifyMsg", tbMsgData); 	
	end
	
	self:GenerateOwnerMap()

	--对各个家族的进行排名和发奖
	local fnAward = function ()
		self:SendMemberAward()
		self:SendKinAward()
		self:SendCityMasterAward()	
	end

	Lib:CallBack({fnAward})

	self.tbFifhtMapId = nil;
	self.tbMapAttakKin = nil;
	self.tbAllFifhtMapId = nil;
	self.nActivyStartTime = nil;
	self.tbKinReportVersion = nil;
	self.tbKinUseSpplyTimes = nil;
	self.tbPlayerSignTime = nil;

	local szNews = "今日攻城戰已結束";
	local tbMapOwner = self:GetDomainMapOwner()
	local tbMapSetting = self.tbMapSetting
	local dwWinKinId = tbMapOwner[tbMapSetting.nMapTemplateId]
	local tbKinInfo = Kin:GetKinById(dwWinKinId)	
	if tbKinInfo then
		szNews = szNews .. string.format("， 恭喜「%s」幫派佔據了襄陽城！", tbKinInfo.szName) 
	end

	KPlayer.SendWorldNotify(1, 150, szNews, 1, 1)

	local tbNewsCityInfo = {}
	for nMapTemplateId, dwKinId in pairs(tbMapOwner) do
		local tbKinInfo = Kin:GetKinById(dwKinId)
		if tbKinInfo then
			tbNewsCityInfo[nMapTemplateId] = tbKinInfo.szName
			TLog("KinFlow", Env.LogWay_DomainBattle, dwKinId, tbKinInfo.szName, 0, nMapTemplateId, 0);
		end
	end
	
	Calendar:OnActivityEnd("DomainBattle") --END

	NewInformation:AddInfomation("DomainBattle", GetTime() + define.nNewsTimeLast, {szNews, tbNewsCityInfo} )
end

function DomainBattle:GetMasterLeaderId()
	local tbMapOwner = self:GetDomainMapOwner()
	if not tbMapOwner then
		return
	end
	local dwCityMasterKinId = tbMapOwner[self.tbMapSetting.nMapTemplateId]
	if dwCityMasterKinId then
		local tbKinInfo = Kin:GetKinById(dwCityMasterKinId)
		if tbKinInfo then
			return  tbKinInfo:GetLeaderId()
		end
	end
end

--宣战
function DomainBattle:KinSignUp(pPlayer, nMapTemplateId)
	if not self.bCanDeclarerWar then
		pPlayer.CenterMsg("目前不能宣戰")
		return 
	end
	local dwKinId = pPlayer.dwKinId
	if dwKinId == 0 then
		return
	end
	local tbKin = Kin:GetKinById(dwKinId)
	if not tbKin then
		return
	end

	local tbMember = Kin:GetMemberData(pPlayer.dwID)
	if not tbMember then
		return
	end
	
	local nCareer = tbMember:GetCareer()
	if not define.tbCanDeclareCareer[nCareer] then
		pPlayer.CenterMsg("您不是幫派堂主或副堂主，無法宣戰")
		return
	end

	local nHasOwnerMapId = self:GetDomainOwnerMap()[dwKinId]
	if nHasOwnerMapId then
		local nAutoFightMap = self:GetFatherLinkMap(nHasOwnerMapId)
		if nAutoFightMap then
			pPlayer.CenterMsg("本幫派已經自動宣戰" .. Map:GetMapName(nAutoFightMap))
			return
		else
			pPlayer.CenterMsg("本幫派現在只需防守")
			return
		end
	end

	local nBattleVersion = self:GetBattleVersion()
	if not (self:CanKinSignUpMap(nMapTemplateId, nBattleVersion) or self:GetDomainMapOwner()[nMapTemplateId])  then
		return
	end

	if self:GetKinWarDeclare()[dwKinId] == nMapTemplateId then
		pPlayer.CenterMsg("已對該地圖宣戰")
		return
	end

	if nMapTemplateId == self.tbMapSetting.nMapTemplateId then
		pPlayer.CenterMsg("只有佔據村鎮的幫派有資格攻打主城", true)
		return
	end
	
	self:SetData(dwKinId, self:GetKinWarDeclare(), dwKinId, nMapTemplateId)
	ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.Kin, string.format("本幫派當前宣戰目標變更為「%s」，開戰後只能攻打宣戰目標。",Map:GetMapName(nMapTemplateId)), dwKinId);
	pPlayer.CallClientScript("DomainBattle:OnDeclareWarscucces", nMapTemplateId)
	DomainBattle:RequestBaseInfo(pPlayer)
end

--玩家参与
function DomainBattle:PlayerSignUp(pPlayer)
	if not Env:CheckSystemSwitch(pPlayer, Env.SW_SwitchMap) then
		pPlayer.CenterMsg("目前狀態不允許切換地圖")
	    return
	end
	local dwKinId = pPlayer.dwKinId
	if dwKinId == 0 then
		return
	end
	local tbKin = Kin:GetKinById(dwKinId)
	if not tbKin then
		return
	end

	local tbFifhtMapId = self.tbFifhtMapId
	if not tbFifhtMapId or not self.nActivyStartTime then
		pPlayer.CenterMsg("目前還不可以參戰")
		return
	end

	if pPlayer.nLevel < self.define.nMinLevel then
		pPlayer.CenterMsg(string.format("%d級才可參加", self.define.nMinLevel))
		return
	end

	local tbMember = Kin:GetMemberData(pPlayer.dwID)
	if not tbMember then
		return
	end

	if  tbMember:GetJoinTime() > self.nActivyStartTime then
		pPlayer.CenterMsg("您剛加入幫派，請等下次的活動吧")
		return
	end

	local nGotoWarMapId = self:GetDomainOwnerMap()[dwKinId] or self:GetKinWarDeclare()[dwKinId]
	if not nGotoWarMapId then
		pPlayer.CenterMsg("幫派並沒有宣戰")
		return
	end
	local nMapId = tbFifhtMapId[nGotoWarMapId]
	if not nMapId then
		pPlayer.CenterMsg("請稍後嘗試")
		return
	end

	if not AsyncBattle:CanStartAsyncBattle(pPlayer)  then
		pPlayer.CenterMsg("請在安全區域下參與活動")
		return
	end

	tbMember:SetDomainBattleVersion()

	self.tbPlayerSignTime[pPlayer.dwID] = GetTime()
	pPlayer.SetEntryPoint()	
	pPlayer.SwitchMap(nMapId, 0,0);
	EverydayTarget:AddCount(pPlayer, "DomainBattle");
end

function DomainBattle:RequestLeave(pPlayer)
	local tbInst = self.tbMapInst[pPlayer.nMapId]
	if not tbInst then
		return
	end

	local nSchedulePos = tbInst.nSchedulePos
	if nSchedulePos ~= 3 then
		if pPlayer.nFightMode  == 1 then
			GeneralProcess:StartProcess(pPlayer, 5 * Env.GAME_FPS, "傳送中...", self.SwitchMapDirectly, self);
			return
		end
		pPlayer.GotoEntryPoint();
	else
		local kinData = Kin:GetKinById(pPlayer.dwKinId);
		if kinData then
			kinData:GoMap(pPlayer.dwID);
		end
	end
end

function DomainBattle:SwitchMapDirectly()
	me.GotoEntryPoint();
end

--传送领地相对的攻击营地
function DomainBattle:GotoAttackMap(pPlayer)
	local nMapTemplateId = pPlayer.nMapTemplateId
	local nFatherLinkMap = self:GetFatherLinkMap(nMapTemplateId)
	if not nFatherLinkMap then
		return
	end
	if self:GetDomainMapOwner()[nMapTemplateId] ~= pPlayer.dwKinId then
		pPlayer.CenterMsg( string.format("只有%s的佔領者才有傳送許可權", Map:GetMapName(nMapTemplateId)) )
		return
	end
	if not self.tbFifhtMapId then
		return
	end
	local nMapId = self.tbFifhtMapId[nFatherLinkMap]
	if not nMapId then
		return
	end
	pPlayer.SwitchMap(nMapId, 0, 0)
end

function DomainBattle:GotoDefendMap(pPlayer, nCampIndex)
	local nMapTemplateId = pPlayer.nMapTemplateId
	local tbChildMaps = self:GetChildLinkMap(nMapTemplateId)
	if not tbChildMaps then
		return
	end
	local nGotoMapTemplateId = tbChildMaps[nCampIndex]
	if not nGotoMapTemplateId then
		Log(nCampIndex, nMapTemplateId, debug.traceback())
		return
	end

	if self:GetDomainMapOwner()[nGotoMapTemplateId] ~= pPlayer.dwKinId then
		pPlayer.CenterMsg(string.format("只有%s的佔領者才有傳送許可權", Map:GetMapName(nGotoMapTemplateId)) )
		return
	end
	if not self.tbFifhtMapId then
		return
	end
	local nMapId = self.tbFifhtMapId[nGotoMapTemplateId]
	if not nMapId then
		return
	end
	pPlayer.SwitchMap(nMapId, 0, 0)	
end

function DomainBattle:AddBattleScore(pPlayer, nAddScore, nKillNum)
	local tbKinInfo = self.tbKinBattleReport[pPlayer.dwKinId] 
	if not tbKinInfo then
		return
	end
	nAddScore = nAddScore or 0;
	nKillNum = nKillNum or 0;

	local dwRoleId = pPlayer.dwID
	tbKinInfo[dwRoleId] = tbKinInfo[dwRoleId] or {0, 0, pPlayer.szName}
	tbKinInfo[dwRoleId][1] = tbKinInfo[dwRoleId][1] + nAddScore
	tbKinInfo[dwRoleId][2] = tbKinInfo[dwRoleId][2] + nKillNum
	self:SetKinBattleReporteVersion(pPlayer.dwKinId)
end

function DomainBattle:AddMapKinScore(nMapId, dwKinId, nAddScore, szMsg)
	local tbKinInfo = self.tbKinBattleReport[dwKinId] 
	if not tbKinInfo then
		return
	end
	local tbPlayer = KPlayer.GetMapPlayer(nMapId);
	for _, pPlayer in ipairs(tbPlayer) do
		if pPlayer.dwKinId == dwKinId then
			tbKinInfo[pPlayer.dwID] = tbKinInfo[pPlayer.dwID] or { 0,0, pPlayer.szName}
			tbKinInfo[pPlayer.dwID][1] = tbKinInfo[pPlayer.dwID][1] + nAddScore
			pPlayer.CenterMsg(szMsg)
		end
	end
	self:SetKinBattleReporteVersion(dwKinId)
end

--同步战报用 ，积分变化或龙柱变化时
function DomainBattle:SetKinBattleReporteVersion(dwKinId)
	if not self.tbKinReportVersion then
		return
	end
	self.tbKinReportVersion[dwKinId] = (self.tbKinReportVersion[dwKinId] or 0) + 1
end

function DomainBattle:GetKinFlagInfo(dwKinId)
	local tbAttakInfo, tbDefendInfo, nAttackCampIndex;
	local nAttackMapId = self:GetKinWarDeclare()[dwKinId] 
	if nAttackMapId then
		local nMapId = self.tbAllFifhtMapId[nAttackMapId]
		local tbInst = self.tbMapInst[nMapId]
		if tbInst then
			tbAttakInfo = tbInst.tbFlagState;
			nAttackCampIndex = tbInst.tbKinAttackCampIndex[dwKinId]
		end
	end
	local nDefendMapId = self:GetDomainOwnerMap()[dwKinId]
	if nDefendMapId then
		local nMapId = self.tbAllFifhtMapId[nDefendMapId]
		local tbInst = self.tbMapInst[nMapId]
		if tbInst then
			tbDefendInfo = tbInst.tbFlagState;
		end
	end		
	return tbAttakInfo, tbDefendInfo, nAttackMapId, nDefendMapId, nAttackCampIndex
end

--获取战报信息, 可单玩家也可全家族同步
function DomainBattle:GetBattleReportInfo(pPlayer, nBattleReportVersion)
	local tbCurInst = self.tbMapInst[pPlayer.nMapId]
	if not tbCurInst then
		return
	end	
	local dwKinId = pPlayer.dwKinId
	
	local tbKinInfo = self.tbKinBattleReport[dwKinId] 
	if not tbKinInfo then
		return
	end

	if not self.tbKinReportVersion then
		return
	end
	if self.tbKinReportVersion[dwKinId] == nBattleReportVersion then
		return
	end

	local tbAttakInfo, tbDefendInfo, nAttackMapId, nDefendMapId, nAttackCampIndex = self:GetKinFlagInfo(dwKinId)

	local tbData = {
		nAttackMapId = nAttackMapId;
		nDefendMapId = nDefendMapId;
		tbScore = tbKinInfo;   --[dwRoleId] = {nSore, nKillNum, szRoleName}
		tbAttakInfo = tbAttakInfo;  --[nIndex] = {  dwKinId, szName} --从小龙柱到大龙柱
		tbDefendInfo = tbDefendInfo; --[nIndex] = {  dwKinId, szName}
		nAttackCampIndex = nAttackCampIndex;

		nLeftTime =  math.floor(Timer:GetRestTime(tbCurInst.nMainTimer) / Env.GAME_FPS);
	}

	pPlayer.CallClientScript("DomainBattle:OnSynFightData", tbData, self.tbKinReportVersion[dwKinId])
	
end

--请求使用战场道具
function DomainBattle:UseSupplys(pPlayer, nItemId)
	local nMapId = pPlayer.nMapId
	local tbInst = self.tbMapInst[nMapId]
	if not tbInst then
		pPlayer.CenterMsg("請在攻城戰使用")
		return
	end

	if not nItemId then
		return
	end

	if not self.tbKinUseSpplyTimes then
		pPlayer.CenterMsg("當前不能使用攻城道具")
		return
	end

	--每场的使用次数限制
	local dwKinId = pPlayer.dwKinId
	self.tbKinUseSpplyTimes[dwKinId] = self.tbKinUseSpplyTimes[dwKinId] or {}
	local tbLimit = self.tbKinUseSpplyTimes[dwKinId]
	tbLimit[nItemId] = tbLimit[nItemId] or 0

	local nLimitNum = define.tbBattleApplyLimit[nItemId]
	if nLimitNum and tbLimit[nItemId] >= nLimitNum then
		pPlayer.CenterMsg(string.format("該道具使用次數已達本場上限%d次", nLimitNum), true)		
		return 
	end

    local tbBattleSupply = tbInst:UseSupplys(pPlayer, nItemId)
    if tbBattleSupply then
    	tbLimit[nItemId]  = tbLimit[nItemId] + 1
    	pPlayer.CallClientScript("DomainBattle:OnSynBattleSupply", tbBattleSupply, tbLimit)
    end
end

--请求家族界面的基本信息
function DomainBattle:RequestBaseInfo(pPlayer, nVersion)
	local dwMyKinId = pPlayer.dwKinId
	local nCurVersion = self.nDataVersion
	if nCurVersion == nVersion then
		return
	end
	local tbKin = Kin:GetKinById(dwMyKinId)
	if not tbKin then
		return
	end
	local tbBattleSupply = tbKin:GetBattleApplys();
	local tbData = nil;
	local tbMapOwner = self:GetDomainMapOwner()
	if  tbMapOwner then
		local tbSynMapOwnerInfo = {}
		for nMapTemplateId, dwKinId in pairs(tbMapOwner) do
			local tbKin = Kin:GetKinById(dwKinId)
			if tbKin then
				tbSynMapOwnerInfo[nMapTemplateId] = {dwKinId, tbKin.szName}
			end
		end	
		tbData = {
					tbMapOwner = tbSynMapOwnerInfo; -- [nMapID] = {dwKinId, tbKin.szName}
					tbMapDeclare = self:GetKinWarDeclare();
					nBattleVersion = self:GetBattleVersion() 
				};
	end
	pPlayer.CallClientScript("DomainBattle:OnSyncBaseInfo", tbData, tbBattleSupply, nCurVersion)
end

function DomainBattle:RequestMapInfo(pPlayer)
	local tbInst = self.tbMapInst[pPlayer.nMapId]
	if tbInst then
		tbInst:RequestMapInfo(pPlayer)
	end
end

function DomainBattle:RequestMainMapInfo(pPlayer)
	local nLeaderId = self:GetMasterLeaderId()
	pPlayer.CallClientScript("DomainBattle:OnSynMiniMainMapInfo", nLeaderId)
end

function DomainBattle:OnSelectNpcDialog(nNpcId, nChangeSkillId, szText, nDuraSeconds)
	local tbInst = self.tbMapInst[me.nMapId]
	if tbInst then
		tbInst:OnSelectNpcDialog(me, nNpcId, nChangeSkillId, szText, nDuraSeconds)
	end
end

function DomainBattle:SelectCamp(pPlayer, nIndex)
	local dwKinId = pPlayer.dwKinId
	if dwKinId == 0 then
		return
	end
	local tbKin = Kin:GetKinById(dwKinId)
	if not tbKin then
		return
	end

	local tbFifhtMapId = self.tbFifhtMapId
	if not tbFifhtMapId or not self.nActivyStartTime then
		return
	end

	local nDeclareMapId = self:GetKinWarDeclare()[dwKinId] 
	if not nDeclareMapId then
		pPlayer.CenterMsg("無可更改的征戰營地")
		return
	end

	local tbMember = Kin:GetMemberData(pPlayer.dwID)
	if not tbMember then
		return
	end
	
	local nCareer = tbMember:GetCareer()
	if not self.define.tbCanUseItemCareer[nCareer] then
		pPlayer.CenterMsg("您的許可權不足")
		return
	end

	local tbInfo = DomainBattle:GetMapSetting(nDeclareMapId)
	if not tbInfo.tbAtackPos[nIndex] then
		pPlayer.CenterMsg("無效的征戰營地")
		return
	end

	local nMapId = tbFifhtMapId[nDeclareMapId]
	if not nMapId then
		return
	end
	local tbInst = self.tbMapInst[nMapId]
	if not tbInst then
		return
	end

	if nIndex == tbInst.tbKinAttackCampIndex[dwKinId] then
		pPlayer.CenterMsg("相同的征戰營地！")
		return
	end

	DomainBattle:SetData(dwKinId, tbInst.tbKinAttackCampIndex, dwKinId, nIndex)

	self:GetBattleReportInfo(pPlayer)
	pPlayer.CenterMsg(string.format("幫派當前進攻的征戰營地已經更換為「%s」！", tbInfo.tbAtackPos[nIndex][4]), true)
end

function DomainBattle:AddOnwenrAcutionAward()
	local nVersion = DomainBattle:GetBattleVersion()
	if not nVersion or nVersion == 0 then
		return
	end
	local tbMapOwner = DomainBattle:GetDomainMapOwner()
	
	local nOpenWarDay =  DomainBattle:GetOpenDomainDay()
	if nOpenWarDay > 0 then --当前已经开启新的宣战了
		nVersion = nVersion - 1
	end

	local tbFlagAwardSetting;
	for i, v in ipairs(DomainBattle.define.tbActOwnerItemSetting) do
		if GetTimeFrameState(v[1]) ~= 1 then
			break;
		end
		tbFlagAwardSetting = v[2];
	end
	assert(tbFlagAwardSetting)

	for nMapTemplateId, dwKinId in pairs(tbMapOwner) do
		local tbFighters = {}
		local nPlayedNum = 0
		local kinData = Kin:GetKinById(dwKinId);
		if kinData then
			kinData:TraverseMembers(function (memberData)
				if memberData.nLastnBattleVersion == nVersion then
					tbFighters[memberData.nMemberId] =  true
					nPlayedNum = nPlayedNum + 1
				end
				return true;
			end);

			local nSocre = DomainBattle:GetOnwerMapKinScore(nMapTemplateId, nPlayedNum)
			local tbItems = DomainBattle:GetActionAwardFromParam(tbFlagAwardSetting, nSocre)
			if next(tbItems) then
				Kin:AddAuction(dwKinId, "DomainBattleAct", tbFighters, tbItems);		
			end	
		end
	end
end

function DomainBattle:GetActionAwardFromParam(tbFlagAwardSetting, nSocre)
	local tbItems = {}
	local fnGetRandomAward = function (nItemId, nCount, tbItems)
		for i=1,nCount do
			local tbBaseInfo = KItem.GetItemBaseProp(nItemId)
			local szClass = tbBaseInfo.szClass
			local nParamId = KItem.GetItemExtParam(nItemId, 1)
			local tbAllAward;
			if szClass == "RandomItemByTimeFrame" then
				local nRet, szMsg, tbTempAllAward = Item:GetClass(szClass):GetAwardListByTimeFrame(nParamId, "領地行商")
				tbAllAward = tbTempAllAward;
			elseif szClass == "RandomItemByLevel" then
				local nRet, szMsg, tbTempAllAward = Item:GetClass(szClass):GetAwardListByLevel(GetMaxLevel(), nParamId, "領地行商")
				tbAllAward = tbTempAllAward;
			else
				Log(debug.traceback(), szClass, nItemId)
			end

			if tbAllAward then
				for i,v in ipairs(tbAllAward) do
					local szType, nItemIdEX, nCountEX = unpack(v)
					if szType == "item" then
						table.insert(tbItems, {nItemIdEX, nCountEX})				
					end
				end
			end
		end	
	end
	for _, v2 in ipairs(tbFlagAwardSetting) do
		local nItemId, fFrag, nScorePrice, bRand = unpack(v2)
		local nCostSocre = nSocre * fFrag
		local nCount = math.floor(nCostSocre / nScorePrice);
		local nLeftScore = nCostSocre - nCount * nScorePrice
		if MathRandom(nScorePrice) < nLeftScore then
			nCount = nCount + 1;
		end
		if nCount > 0 then
			if bRand then
				fnGetRandomAward(nItemId, nCount, tbItems)
			else
				table.insert(tbItems, {nItemId, nCount})				
			end
		end
	end
	if not next(tbItems) then
		for _,v in ipairs(DomainBattle.define.tbBaseAcutionAward) do
			local nItemId, nCount, bRand = unpack(v)
			if bRand then
				fnGetRandomAward(nItemId, nCount, tbItems)
			else
				table.insert(tbItems, {nItemId, nCount})				
			end
		end
	end
	return tbItems
end

function DomainBattle:NotifyBattleOpen()
	KPlayer.SendWorldNotify(self.define.nMinLevel, 150, "今日攻城戰已經開始，請已宣戰幫派成員儘快進入戰場，為奪取幫派領地而戰！", 1, 1)
	Calendar:OnActivityBegin("DomainBattle") --TODO
	local tbMsgData = {
		szType = "StartDomainBattle";
		nTimeOut = GetTime() + DomainBattle.STATE_TRANS[2].nSeconds;
	};

	KPlayer.BoardcastScript(self.define.nMinLevel, "Ui:SynNotifyMsg", tbMsgData); 
end

function DomainBattle:OnBattleMapCreate(nMapTemplateId, nMapId)
	local tbInst = Lib:NewClass(self.tbBase)
	local nOwnerKin = self:GetDomainMapOwner()[nMapTemplateId]
	tbInst:Init(nMapTemplateId, nMapId, nOwnerKin, self.tbMapAttakKin[nMapTemplateId] or {})
	self.tbFifhtMapId[nMapTemplateId] = nMapId

	tbInst:Start();
	self.tbMapInst[nMapId] = tbInst

	self.nCreateMapNum = self.nCreateMapNum - 1;
	if self.nCreateMapNum <= 0 then
		self.tbAllFifhtMapId = Lib:CopyTB(self.tbFifhtMapId) --为了最终统计发家族奖励用的

		self:NotifyBattleOpen();
	end
end

function DomainBattle:OnBattleMapDestory(nMapId)
	if self.tbMapInst[nMapId] then
		self.tbMapInst[nMapId]:OnMapDestroy();
		self.tbMapInst[nMapId] = nil
	end
	if not next(self.tbMapInst)  then
		self.tbKinBattleReport = {};
	end
end

function DomainBattle:OnCreateChatRoom(dwKinId, uRoomHighId, uRoomLowId)
	if not self.tbKinBattleReport then
		return false
	end
	if not self.tbKinBattleReport[dwKinId] then
		return false
	end

	local fnAddKinPlayerChatRoom = function (nGotoWarMapId)
		if not nGotoWarMapId then
			return
		end
		local tbPlayers = KPlayer.GetMapPlayer(nGotoWarMapId)
		for i,v in ipairs(tbPlayers) do
			if v.dwKinId == dwKinId then
				Kin:JoinChatRoom(v);
			end
		end
	end
	fnAddKinPlayerChatRoom(self:GetDomainOwnerMap()[dwKinId])
	fnAddKinPlayerChatRoom(self:GetKinWarDeclare()[dwKinId])
	return true;
end

function DomainBattle:GetOnwerMapKinScore(nMapTemplateId, nPlayedNum)
	local nMapLevel = DomainBattle:GetMapLevel(nMapTemplateId)
	local nDefaultScore, nDefaultRoleNum = unpack(DomainBattle.define.tbActOwnerScoreSetting[nMapLevel])
	local nRetrun = math.ceil(nDefaultScore * math.min(nPlayedNum, nDefaultRoleNum) / nDefaultRoleNum) 
	Log("DomainBattle:GetOnwerMapKinScore", nMapTemplateId, nPlayedNum)
	return nRetrun
end

function DomainBattle:GetMapFlagKinScore(nMapTemplateId, tbFlagState, nPlayedNum, dwKinId)
	local tbFlagScore = self.define.tbFlagScore
	local nMapLevel = DomainBattle:GetMapLevel(nMapTemplateId)
	local tbFlogNpcPos = self.tbMapPosSetting[nMapTemplateId].tbFlogNpcPos
	local nNeedDefault = 0
	local nGetScore = 0
	for i,v in ipairs(tbFlagState) do
		if v[1] == dwKinId then
			local nFlogLevel = tbFlogNpcPos[i][2] 
			local nDefaultScore, nDefaultRoleNum = unpack(tbFlagScore[nMapLevel][nFlogLevel])
			nGetScore = nGetScore + nDefaultScore;
			nNeedDefault = nNeedDefault + nDefaultRoleNum
		end
	end
	if nGetScore > 0 and  nNeedDefault > 0 then
		local nRetrun = math.ceil(nGetScore * math.min(nPlayedNum, nNeedDefault) / nNeedDefault) 
		Log("DomainBattle:GetMapFlagKinScore", nMapTemplateId, nPlayedNum, dwKinId)
		return nRetrun
	end

	return 0;
end

function DomainBattle:Init()
	self:SetupMapCallback()
end

function DomainBattle:SetupMapCallback()
	local fnOnCreate = function (tbMap, nMapId)
		self:OnBattleMapCreate(tbMap.nMapTemplateId, nMapId)
	end

	local fnOnDestory = function (tbMap, nMapId)
		self:OnBattleMapDestory(nMapId)
	end

	local fnOnEnter = function (tbMap, nMapId)
		local tbInst = tbMapInst[nMapId]
		if tbInst then
			tbInst:OnEnter()
		end
	end

	local fnOnLeave = function (tbMap, nMapId)
		local tbInst = tbMapInst[nMapId]
		if tbInst then
			tbInst:OnLeave()
		end
	end

	local fnOnPlayerTrap = function (tbMap, nMapId, szTrapName)
		local tbInst = tbMapInst[nMapId]
		if tbInst then
			tbInst:OnPlayerTrap(szTrapName)
		end
	end

	local fnOnNpcTrap = function (tbMap, nMapId, szTrapName)
		local tbInst = tbMapInst[nMapId]
		if tbInst then
			tbInst:OnNpcTrap(szTrapName)
		end
	end

	local fnOnMapLogin = function (tbMap, nMapId)
		local tbInst = tbMapInst[nMapId]
		if tbInst then
			tbInst:OnLogin()
		end
	end

	for nMapTemplateId, _ in pairs(self.tbMapLevel) do
		local tbMapClass = Map:GetClass(nMapTemplateId)
		tbMapClass.OnCreate = fnOnCreate;
		tbMapClass.OnDestroy = fnOnDestory;
		tbMapClass.OnEnter = fnOnEnter;
		tbMapClass.OnLeave = fnOnLeave;
		tbMapClass.OnPlayerTrap = fnOnPlayerTrap;
		tbMapClass.OnLogin = fnOnMapLogin;
	end	
end


DomainBattle:Init();