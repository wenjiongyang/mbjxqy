--[[
Kin.KinData = {
	[kinId] = {
		nKinId             = nKinId;
		nCreateTime        = GetTime();
		szName             = szKinName;
		nFound             = 0; -- 家族建设资金
		nMasterId          = me.dwID;
		szDeclaration      = szKinDeclaration;
		tbMembers          = {}; --
		tbMembers[me.dwID] = Kin.Def.Career_Master;
		nToBreakTime       = nil;
		nLastRobberRewardDay   = -- 家庭盗贼上次全部击杀日
		nKillAllRobberRound =  当日盗贼全部击杀轮数
		nLeftMailCount = 3;
		nRefreshMailDay = GetLocalDay();
		tbDonationRecord = {}
		nDonationRecordVertion = 1
		nKinCamp           = nCamp --家族阵营
		nKinCampCount      = 0;
		nKinCampDay        = GetLocalDay();
		nBanTime 		   = GetTime()  禁止参加家族排行榜的结束时间
		szBanTips		   = "" 		禁止参加家族排行榜的原因
		nSnowflake         = 0 			雪花数量,可用来计算雪人等级
		tbMakingPlayer     = {} 		贡献雪人等级提升的玩家

		nKinBattleMinLevel = 20;	-- 家族战最低等级限制，族长可设置
		tbBuilding = {
			[nBuildingId] = {
				nLevel =
			}
		};

		tbKinTask = {
			nDate = GetLocalDay();
			nCount = 100;			-- 完成家族任务数量
		};

		nKinEscortLastDate  = -1;      -- 上次家族运镖的时间（UTC天数）
		nLastRank = 1;	--上周排行
		nLeaderId = 123;	-- 领袖id
		szLeaderTitle = "";	--自定义领袖的称谓
		nChangeLeaderTime = 123;	--准备更换领袖的开始时间，0表示未开始
		nCandidateLeaderId = 123;	--候选领袖id，0表示无
		nAppointLeaderTime = 123;	--主动任命领袖时间
		nWeekActive = 0;	--累计周活跃,不包含今天
		szLastJudge = "";	-- 上周评价，仅考核期有记录

		nMasterProfit = 0;	--族长累计未领取分红(已废弃)
		nTotalCharge = 0;	--总充值元宝数
		tbTop3Charges = {	--（已废弃）
			[nId1] = nCharge1,
			[nId2] = nCharge2,
			[nId3] = nCharge3,
		},
		tbBattleSupply =  --战争防里购买的道具
		{
			[nItemId] = num;
		},
		tbAwardGuarantee = --家族活动奖励保底价值量累计
		{
			["Imperial_Emperor_2796"] = 30000, --保存了当前这项奖励累积的价值(可能为负值)
		},
		nClue = 0;	--家族盗贼累计线索
		nLastClueTime = 0;	--上次获得线索的时间
		nLastPushMail = 0;	--上次系统推送邮件的时间
	},
}

Kin._CacheKinData = {
	[kinId] = {
		tbApplyerList = {};
		tbInviteList  = {};
		nVersion      = 1;
		nMapId        = 4;-- 家族地图id

		....
	}
}

Kin.MemberData = {
	[memberId] = {
		nMemberId   = player.nID;
		nKinId      = nKinId;
		nJoinTime   = GetTime();
		nCareer      = career;
		nCareerTime = GetTime();	--成为此职业的时间
		nWeekActive = 0;	--周累计活跃值,不包含今天
		nTodayActive = 0;	--今日当前活跃值
		tbAuthority = {};
		tbFoundRecord = {};
		nWeekCharge = 0;	--本周累计充值(已废弃)
		nLastnBattleVersion = 0; --上次参加的攻城战届数
	}
}

-- 玩家 家族 临时数据
Kin._CacheKinMemberData = {
	[memberId] = {

	}
}

]]


local KinMgr     = GetKinMgr();
Kin.KinData       = Kin.KinData or {};
Kin.MemberData    = Kin.MemberData or {};
Kin.tbAllKinNames = Kin.tbAllKinNames or {};
Kin._MetaKinData = Kin._MetaKinData or {};
Kin._MetaKinMember = Kin._MetaKinMember or {};

local _KinData   = Kin._MetaKinData;
local _KinMember = Kin._MetaKinMember;

Kin._CacheKinData = Kin._CacheKinData or {}; -- 不存盘的家族缓存信息,放申请列表等
Kin._CacheKinMemberData = Kin._CacheKinMemberData or {}; -- 不存盘的家庭成员缓存信息, 如申请邀请列表等
Kin._nJoinKinsInfoVersion = Kin._nJoinKinsInfoVersion or 1;
Kin.tbKinDataSaveMap = Kin.tbKinDataSaveMap or {};
Kin.tbMemberDataSaveMap = Kin.tbMemberDataSaveMap or {};
Kin._CacheLastKinInfo = Kin._CacheLastKinInfo or {}	--不存盘的上次所在家族的信息

function Kin:LoadKinData(nKinId, tbData, szKinName)
	assert(not Kin.KinData[nKinId]);
	setmetatable(tbData, {__index = _KinData});
	Kin.KinData[nKinId] = tbData;

	tbData.szName = szKinName or tbData.szName;
	Kin.tbAllKinNames[tbData.szName] = true;
end

function Kin:DeleteKin(nKinId, nLogReason)
	local tbData = Kin.KinData[nKinId]
	if not tbData then
		return
	end

	TLog("KinFlow", Env.LogWay_DeleteKin, tbData.nKinId, tbData.szName, 0, nLogReason, 0);
	local pRank = KRank.GetRankBoard("kin")
	if pRank then
		pRank.RemoveByID(nKinId)
		pRank.Rank()
	end
	Kin.KinData[nKinId] = nil;
	KinMgr.DeletKin(nKinId);
	Kin._nJoinKinsInfoVersion = Kin._nJoinKinsInfoVersion + 1;

	RedBagMgr:ClearByKinId(nKinId)
end

function Kin:LoadMemberData(nPlayerId, tbData)
	setmetatable(tbData, {__index = _KinMember});
	Kin.MemberData[nPlayerId] = tbData;
end

-- 以member data的数据为准， 重建kin data的玩家索引
function Kin:RebuildCoreData()
	Kin:TraverseKin(function (kinData)
		kinData.tbMembers = {};
	end);

	for nPlayerId, tbMemberData in pairs(Kin.MemberData) do
		local nKinId = tbMemberData.nKinId;
		if nKinId ~= 0 then
			local kinData = Kin:GetKinById(nKinId);
			if kinData then
				kinData.tbMembers[nPlayerId] = tbMemberData.nCareer;
			else
				tbMemberData.nKinId = 0;
				tbMemberData:Save();
				Log("Kin:RebuildCoreData ERROR, kin not found", nKinId);
			end
		else
			Log("Kin:RebuildCoreData ERROR, KinId zero", nPlayerId);
		end
	end

	Kin:TraverseKin(function(tbKinData)
		local nMasterId = tbKinData.nMasterId
		local tbMember = self:GetMemberData(nMasterId)
		if not tbMember or tbMember.nCareer~=Kin.Def.Career_Master then
			local nChooseMasterId = tbKinData:_GetAutoChooseMasterId()
			local tbChooseMember = self:GetMemberData(nChooseMasterId)
			if tbChooseMember then
				tbChooseMember:SetCareer(Kin.Def.Career_Master)
				Log("Kin:RebuildCoreData auto choose master success", tbKinData.nKinId, nMasterId, nChooseMasterId)
			else
				Log("Kin:RebuildCoreData auto choose master failed", tbKinData.nKinId, nMasterId, nChooseMasterId)
			end
		end

		tbKinData:CheckResetTitle()
		tbKinData:CheckOrgServer();
	end)

	self:InitLastKinInfo()
end

function Kin:GetNextKinId(bIncrease)
	local _, _, nSubServerId = GetServerIdentity();
	local nNextKinId = ScriptData:GetValue("nNextKinId");
	if type(nNextKinId) ~= "number" then
		nNextKinId = 1;
	end

	if bIncrease then
		ScriptData:SaveAtOnce("nNextKinId", nNextKinId + 1);
	end

	return nSubServerId*2^20 + nNextKinId;
end

local nNextActiveTime = 0;

-- 每秒调用一次
function Kin:Save(bImmediately)
	local now = GetTime();
	if not bImmediately and now < nNextActiveTime then
		return;
	end

	-- 5秒存盘一次? 多长的时间间隔比较合适?
	nNextActiveTime = now + 5;

	for nKinId, _ in pairs(Kin.tbKinDataSaveMap) do
		local tbKinData = Kin:GetKinById(nKinId);
		if tbKinData then
			if not KinMgr.SaveKin(nKinId, tbKinData.szName, tbKinData) then
				Log("Kin:Save ERROR", nKinId, GetTableSize(tbKinData))
			end
		end
	end
	Kin.tbKinDataSaveMap = {};

	for nMemberId, _ in pairs(Kin.tbMemberDataSaveMap) do
		local tbMemberData = Kin:GetMemberData(nMemberId)
		local nKinId = 0
		local tbSavedData = {}
		if not tbMemberData then
			Kin.MemberData[nMemberId] = nil;
			Log("Kin:Save player leave kin", nMemberId)
		else
			nKinId = tbMemberData.nKinId
			tbSavedData = tbMemberData
		end
		KinMgr.SaveKinMember(nMemberId, nKinId, tbSavedData)
	end
	Kin.tbMemberDataSaveMap = {};
end

function Kin:RunPerDay()
	Kin:TraverseKin(function (kinData)
		kinData:DailyActive();
	end);

	Kin:DailyActive();
end

function Kin:DailyActive()
	Kin:UpdateJoinKinsInfo();
end

function Kin:GetJoinKinsInfo(nVersion)
	if not nVersion or nVersion ~= Kin._nJoinKinsInfoVersion then
		Kin:UpdateJoinKinsInfo();
		return Kin._tbJoinKinsInfo, Kin._nJoinKinsInfoVersion;
	end
end

local function GetJoinKinData(tbKinData)
	-- 考核期的家族不显示在申请列表中
	if tbKinData.szLastJudge and tbKinData.szLastJudge~="" then
		return
	end

	local master = KPlayer.GetRoleStayInfo(tbKinData.nMasterId);
	if not master then
		return;
	end

	local data = {
		nKinId = tbKinData.nKinId;
		szName = tbKinData.szName;
		szMasterName = master.szName;
		nHonorLevel = master.nHonorLevel;
		nMemberCount = tbKinData:GetMemberCount();
		nNewerCount = tbKinData:GetNewerCount();
		nMaxMemberCount = tbKinData:GetMaxMemberCount();
		nMaxNewerCount = tbKinData:GetMaxNewerCount();
		szDeclaration = tbKinData.tbRecruitSetting.szAddDeclare;
		nLevel = tbKinData:GetLevel();
		nVipLevel = master.nVipLevel;
		nWeekActive = tbKinData.nWeekActive;
	}

	return data;
end

function Kin:UpdateJoinKinsInfo(nKinId)
	if not nKinId then
		Kin._tbJoinKinsInfo = {};
		Kin._nJoinKinsInfoVersion = GetTime();
		for _, tbKinData in pairs(Kin.KinData) do
			local data = GetJoinKinData(tbKinData);
			if data then
				table.insert(Kin._tbJoinKinsInfo, data);
			end
		end

		table.sort(Kin._tbJoinKinsInfo, function(tbA, tbB)
			local bFullA = tbA.nMemberCount>=tbA.nMaxMemberCount
			local bFullB = tbB.nMemberCount>=tbB.nMaxMemberCount
			if bFullA==bFullB then
				return tbA.nWeekActive>tbB.nWeekActive or (tbA.nWeekActive==tbB.nWeekActive and tbA.nKinId<tbB.nKinId)
			else
				return not bFullA
			end
		end)

		return;
	end

	Kin._tbJoinKinsInfo = Kin._tbJoinKinsInfo or {};
	Kin._nJoinKinsInfoVersion = Kin._nJoinKinsInfoVersion + 1;

	local tbKinData = Kin:GetKinById(nKinId);
	local tbNewKinJoinData = GetJoinKinData(tbKinData);

	for nIdx, tbData in pairs(Kin._tbJoinKinsInfo) do
		if tbData.nKinId == nKinId then
			Kin._tbJoinKinsInfo[nIdx] = tbNewKinJoinData;
			return;
		end
	end

	table.insert(Kin._tbJoinKinsInfo, tbNewKinJoinData);
end

function Kin:SyncTitle(nMemberId, szKinTitle )
	KinMgr.SetTitle(nMemberId, szKinTitle);
end

function Kin:TraverseKin(fnOperate, ...)
	if type(fnOperate) == "function" then
		for nKinId, kinData in pairs(Kin.KinData) do
			fnOperate(kinData, ...);
		end
	end
end

function Kin:TraverseKinInDiffTime(nKinsPerFrame, fnOperate, ...)
	local function fnFrameCall(nKinId, ...)
		local kinData = Kin:GetKinById(nKinId);
		if kinData then
			fnOperate(kinData, ...);
		end
	end

	local nCurCount = 0;
	for nKinId, kinData in pairs(Kin.KinData) do
		nCurCount = nCurCount + 1;
		Timer:Register(math.ceil(nCurCount / nKinsPerFrame), fnFrameCall, nKinId, ...);
	end
end

Kin.tbKinMapCallbacks = Kin.tbKinMapCallbacks or {};
Kin.tbKinMapIds = Kin.tbKinMapIds or {};
Kin.tbKinMapId2KinId = Kin.tbKinMapId2KinId or {}
function Kin:CallAfterMapLoaded(nKinId, nMapId, tbCallback)
	self.tbKinMapCallbacks[nMapId] = self.tbKinMapCallbacks[nMapId] or {};
	table.insert(self.tbKinMapCallbacks[nMapId], tbCallback);
end

function Kin:OnCreateKinMap(nMapId)
	if self.tbKinMapCallbacks[nMapId] then
		for _, tbCallback in ipairs(self.tbKinMapCallbacks[nMapId]) do
			Lib:CallBack(tbCallback);
		end
		self.tbKinMapCallbacks[nMapId] = nil;
	end
	self.tbKinMapIds[nMapId] = true;
end

function Kin:OnDestroyKinMap(nMapId)
	self.tbKinMapIds[nMapId] = nil;
end

function Kin:IsLoadedKinMap(nMapId)
	return self.tbKinMapIds[nMapId] or false;
end

function Kin:GetKinIdByMapId(nMapId)
	return Kin.tbKinMapId2KinId[nMapId]
end

function Kin:InitLastKinInfo()
	self._CacheLastKinInfo = {}

	self:TraverseKin(function(tbKinData)
		local nKinId = tbKinData.nKinId
		for nMemberId in pairs(tbKinData.tbContribution) do
			while true do
				local tbContribInfo = tbKinData:GetContributionInfo(nMemberId)
				if not tbContribInfo then
					Log("[x] Kin:InitLastKinInfo member contribution nil", nKinId, nMemberId)
					break
				end

				local tbLastKinInfo = self._CacheLastKinInfo[nMemberId]
				if tbLastKinInfo and (tbLastKinInfo.nDeleteTime or math.huge) > (tbContribInfo.nDeleteTime or math.huge) then
					break
				end

				self._CacheLastKinInfo[nMemberId] = {
					nKinId = nKinId,
					nDeleteTime = tbContribInfo.nDeleteTime,
				}

				break
			end
		end
	end)

	for _, tbInfo in pairs(self._CacheLastKinInfo) do
		tbInfo.nDeleteTime = nil
	end
end

function Kin:GetPlayerLastKinId(nPlayerId)
	local tbLastKinInfo = self._CacheLastKinInfo[nPlayerId]
	return tbLastKinInfo and tbLastKinInfo.nKinId or 0
end

function Kin:SetPlayerLastKinId(nPlayerId, nKinId)
	self._CacheLastKinInfo[nPlayerId] = {
		nKinId = nKinId,
	}
end

-------------------------_KinData--------------------------------------

function _KinData:_GetAutoChooseMasterId()
	local nLeaderId = self:GetLeaderId()
	if nLeaderId and nLeaderId>0 then
		return nLeaderId
	end

	local nKinId = self.nKinId
	local tbKinData = Kin:GetKinById(nKinId)
	if not tbKinData then
		return 0
	end

	for nPlayerId, nCareer in pairs(tbKinData.tbMembers) do
		if nCareer==Kin.Def.Career_Master then
			return nPlayerId
		end
	end
	return 0
end

function _KinData:DailyActive()
	Log("KinRunPerDay", self.nKinId, self.szName);

	local tbMemberInfoList = self:GetMemberInfoList();
	table.sort( tbMemberInfoList, function (a, b)
		return a.nContribution > b.nContribution;
	end );

	local nTime = GetTime();

	-- 选取精英
	local nEliteCount = 0;
	for _, tbMemberInfo in ipairs(tbMemberInfoList) do
		if tbMemberInfo.nCareer == Kin.Def.Career_Normal
			or tbMemberInfo.nCareer == Kin.Def.Career_Elite
			then
			local memberData = Kin:GetMemberData(tbMemberInfo.nMemberId);
			if memberData then
				if tbMemberInfo.nContribution >= Kin.Def.nEliteContributionLine
					and nEliteCount <= self:GetCareerMaxCount(Kin.Def.Career_Elite)
					then
					memberData:SetCareer(Kin.Def.Career_Elite);
					nEliteCount = nEliteCount + 1;
				else
					memberData:SetCareer(Kin.Def.Career_Normal);
				end
			end
		end
	end

	if Lib:GetLocalWeekDay() == 1 then
		-- 每周一，威望率减
		local nModiyfPrestige = - math.floor(self.nPrestige * Kin.Def.nPrestigeFalloffRate)
		self:AddPrestige(nModiyfPrestige, Env.LogWay_KinPrestigeAutoReduce)

		self:TryPushMail()
	end

	Lib:CallBack({self.CheckRankForbid,self});

	self:SetCacheFlag("UpdateMemberInfoList", true);
	self:SetCacheFlag("UpdateBaseInfo", true);
	self:Save();
end

function _KinData:TryPushMail()
	if not version_tx then
		return
	end
	local nNow = GetTime()
	local nLastPush = self:GetLastPushMailTime()
	if (nNow-nLastPush) < Kin.Def.nPushMailCD then
		Log("_KinData:TryPushMail skip", self.nKinId, nNow, nLastPush)
		return
	end
	self:UpdateLastPushMailTime()

	local _, nPlatId = GetWorldConfifParam()
	local szUrl = nPlatId==1 and "http://jxqy.qq.com/webplat/info/news_version3/22500/23887/23888/23889/23891/m15035/201702/553075.shtml" or "http://jxqy.qq.com/webplat/info/news_version3/22500/23887/23888/23889/23891/m15035/201702/553086.shtml"
	local tbValidCareers = {Kin.Def.Career_Master, Kin.Def.Career_ViceMaster, Kin.Def.Career_Elder}

	local tbValidIds = {}
	local nLeaderId = self:GetLeaderId()
	tbValidIds[nLeaderId] = true
	for _, nCareer in ipairs(tbValidCareers) do
		local tbIds = self:GetCareerMemberIds(nCareer)
		for _, nId in ipairs(tbIds) do
			tbValidIds[nId] = true
		end
	end
	
	for nId in pairs(tbValidIds) do
		if nId>0 then
			Mail:SendSystemMail({
				To = nId,
				Title = "幫派全員一呼百應",
				From = "幫派總管",
				Text = string.format("    為方便幫派管理對幫派大小事宜的統一指揮行動，現特對幫派郵件增加手機系統提醒功能，幫派郵件不僅在遊戲內發送給每個幫派成員，同時也將通過手機系統提示直接發送到已開通“劍俠情緣”手遊系統提示許可權的幫派成員手機，幫派大事分秒即達，點擊[FFFE0D][url=openinnerurl:<查看教程>,%s][-]，可查看手機系統提示開啟方法。", szUrl),
			})
			Log("_KinData:TryPushMail", self.nKinId, nId)
		end
	end
end

function _KinData:GetCacheData()
	if not Kin._CacheKinData[self.nKinId] then
		Kin._CacheKinData[self.nKinId] = {
			nBaseInfoVersion = 1;
			tbApplyerList = {};
			nApplyerListVersion = 1;
			tbInviteList = {};
			nInviteListVersion = 1;
			nMemberInfoListVersion = 1;
			tbChatData = {};
			nBuildingVersion = 1;
			tbFlag = {};
			tbTopLevel = {}
		};
	end

	return Kin._CacheKinData[self.nKinId];
end

function _KinData:GetCacheTopLevel()
	local tbKinCache = self:GetCacheData();
	return tbKinCache.tbTopLevel;
end


function _KinData:SetCacheFlag(flag, value)
	local tbKinCache = self:GetCacheData();
	tbKinCache.tbFlag[flag] = value;
end

function _KinData:GetCacheFlag(flag)
	local tbKinCache = self:GetCacheData();
	return tbKinCache.tbFlag[flag];
end

function _KinData:CacheChatMsg(nChannelId, nSenderId, szSenderName, nFaction, nPortrait, nLevel, nHeadBg, nChatBg, szMsg, tbLinkInfo)
	local kinCache = self:GetCacheData();
	local data = {
				nChannelType = nChannelId,
				nSenderId = nSenderId,
				szSenderName = szSenderName,
				szMsg = szMsg,
				nFaction = nFaction,
				nPortrait = nPortrait,
				nLevel = nLevel,
				nTime = GetTime(),
				tbLinkInfo = tbLinkInfo,
				nHeadBg = nHeadBg,
				nChatBg = nChatBg,
			};

	table.insert(kinCache.tbChatData, data);
	if #kinCache.tbChatData > ChatMgr.nCacheChatMaxCount then
		table.remove(kinCache.tbChatData, 1);
	end
end

function _KinData:ClearCacheChatMsg(nSenderId)
	local kinCache = self:GetCacheData();
	local nLength = #kinCache.tbChatData
	for nIdx = nLength,1,-1 do
		local tbData = kinCache.tbChatData[nIdx]
		if tbData and tbData.nSenderId == nSenderId then
			table.remove(kinCache.tbChatData,nIdx)
		end
	end
end

function _KinData:GetChatCache()
	local kinCache = self:GetCacheData();
	return kinCache.tbChatData;
end

function _KinData:GetMaxMemberCount()
	local nLevel = self:GetLevel();
	local szKey = "MaxMemberAbroad"
	if version_tx or version_hk or version_vn or version_xm then
		szKey = "MaxMember"
	end
	return Kin:GetMaxMember(nLevel, szKey);
end

function _KinData:GetMaxNewerCount()
	local nLevel = self:GetLevel();
	return Kin:GetMaxMember(nLevel, Kin.Def.Career_New);
end

function _KinData:GetMaxRetireCount()
	local nLevel = self:GetLevel();
	return Kin:GetMaxMember(nLevel, Kin.Def.Career_Retire);
end

function _KinData:GetMemberCount()
	if not self.nMemberCount or self:GetCacheFlag("UpdateCount") then
		self:UpdateCount();
	end
	return self.nMemberCount;
end

function _KinData:GetNewerCount()
	if self:GetCacheFlag("UpdateCount") then
		self:UpdateCount();
	end
	return self.nNewerCount;
end

function _KinData:GetRetireCount()
	if self:GetCacheFlag("UpdateCount") then
		self:UpdateCount();
	end
	return self.nRetireCount;
end

function _KinData:GetTotalMemberCount()
	return self:GetRetireCount() + self:GetNewerCount() + self:GetMemberCount();
end

function _KinData:UpdateCount()
	local nNormalCount = 0;
	local nNewerCount = 0;
	local nRetireCount = 0;
	for _, nCareer in pairs(self.tbMembers) do
		if nCareer == Kin.Def.Career_New then
			nNewerCount = nNewerCount + 1;
		elseif nCareer == Kin.Def.Career_Retire then
			nRetireCount = nRetireCount + 1;
		else
			nNormalCount = nNormalCount + 1;
		end
	end

	self.nMemberCount = nNormalCount;
	self.nNewerCount = nNewerCount;
	self.nRetireCount = nRetireCount;

	self:SetCacheFlag("UpdateCount", nil);
	self:Save();
end

function _KinData:GetBaseInfo(nVersion)
	local kinCache = self:GetCacheData();
	if not kinCache.tbBaseInfo or self:GetCacheFlag("UpdateBaseInfo") then
		self:UpdateBaseInfo();
	end

	if nVersion ~= kinCache.nBaseInfoVersion then
		return kinCache.tbBaseInfo, kinCache.nBaseInfoVersion;
	end
end

function _KinData:UpdateBaseInfo()
	local kinCache = self:GetCacheData();
	local master = Kin:GetMemberData(self.nMasterId);

	kinCache.tbBaseInfo = {
		nMasterId        = self.nMasterId;
		szGroupOpenId    = self:GetGroupOpenId();
		szGroupName      = self:GetGroupName();
		szName           = self.szName;
		szMasterName     = master and master:GetName() or "";
		szPublicDeclare  = self.szPublicDeclare;
		nLevel           = self:GetLevel();
		nFound           = self.nFound;
		nKinCamp         = self.nKinCamp;
		nKinCampCount    = self:GetChangeCampCount();
		nKinCampDay      = self.nKinCampDay;
		nMemberCount     = self:GetMemberCount();
		nNewerCount      = self:GetNewerCount();
		nRetireCount     = self:GetRetireCount();
		nMaxMemberCount  = self:GetMaxMemberCount();
		nMaxRetireCount  = self:GetMaxRetireCount();
		nMaxNewerCount   = self:GetMaxNewerCount();
		tbKinTitle       = self.tbKinTitle;
		nPrestige        = self.nPrestige;
		nLastRank        = self:GetLastRank();
		nLeaderId        = self:GetLeaderId();
		szLeaderTitle	 = self.szLeaderTitle;
		nCandidateLeaderId = self:GetCandidateLeaderId();
		nChangeLeaderTime = self:GetChangeLeaderTime();
		nOrgServerId     = self:GetOrgServerId();
	};

	kinCache.nBaseInfoVersion = kinCache.nBaseInfoVersion + 1;
	self:SetCacheFlag("UpdateBaseInfo", nil);
end

function _KinData:GetMemberInfoList(nVersion)
	local kinCache = self:GetCacheData();
	if not kinCache.tbMemberInfoList or self:GetCacheFlag("UpdateMemberInfoList") then
		self:UpdateMemberInfoList();
	end

	if nVersion ~= kinCache.nMemberInfoListVersion then
		return kinCache.tbMemberInfoList, kinCache.nMemberInfoListVersion;
	end
end

function _KinData:UpdateMemberInfoList()
	local kinCache = self:GetCacheData();
	local tbMemberInfoList = {};
	local nNow = GetTime();
	for nMemberId, nCareer in pairs(self.tbMembers) do
		local memberData = Kin:GetMemberData(nMemberId);
		local pAsync = KPlayer.GetAsyncData(nMemberId)
		if memberData and memberData.nKinId == self.nKinId then
			local pPlayer = KPlayer.GetPlayerObjById(nMemberId)
			local tbRoleStayInfo = pPlayer or KPlayer.GetRoleStayInfo(nMemberId);
			local nAccept = pPlayer and ChuangGong:GetDegree(pPlayer, "ChuangGong") or 0
			local nSend = pPlayer and ChuangGong:GetDegree(pPlayer, "ChuangGongSend") or 0
			local tbData = {
					nMemberId     = memberData.nMemberId;
					szName        = tbRoleStayInfo.szName;
					nLevel        = tbRoleStayInfo.nLevel;
					nFaction      = tbRoleStayInfo.nFaction;
					nHonorLevel   = tbRoleStayInfo.nHonorLevel;
					nCareer       = memberData.nCareer;
					nPortrait	  = tbRoleStayInfo.nPortrait;
					nContribution = memberData:GetContribution();
					szKinTitle    = memberData.szKinTitle;
					tbAuthority   = memberData.tbAuthority;
					nForbidTime   = memberData.nForbidTime;
					nLastOnlineTime = tbRoleStayInfo.nLastOnlineTime or nNow;
					tbCommerceHelp = CommerceTask:GetFamilyCommerceHelpData(memberData.nMemberId);
					nVipLevel = pAsync and pAsync.GetVipLevel() or 0;
					nActivity = (memberData.nTodayActive or 0)+(memberData.nWeekActive or 0);
					nChuangGongTimes = nAccept;
					nChuangGongSendTimes = nSend;
					nLastChuangGongSendTime = pPlayer and pPlayer.GetUserValue(ChuangGong.SAVE_GROUP, ChuangGong.KEY_SEND_TIME) or 0;
				};

			table.insert(tbMemberInfoList, tbData);
			if nCareer ~= memberData.nCareer then
				self.tbMembers[nMemberId] = memberData.nCareer;
				Log("ERROR:KIN:UpdateMemberInfoList, career diff", nCareer, memberData.nCareer, nMemberId, self.nKinId);
			end
		else
			-- 清除错误的数据, 理论上不存在, 除非有bug
			self.tbMembers[nMemberId] = nil;
			self:SetCacheFlag("UpdateCount", true);
			self:SetCacheFlag("UpdateBaseInfo", true);
			Log("ERROR:KIN:UpdateMemberInfoList, kin member not found", nMemberId, self.nKinId);
		end
	end

	kinCache.tbMemberInfoList = tbMemberInfoList;
	kinCache.nMemberInfoListVersion = kinCache.nMemberInfoListVersion + 1;
	self:SetCacheFlag("UpdateMemberInfoList", nil);
end

function _KinData:Available2Join(bIsNewer)
	if bIsNewer then
		if self:GetNewerCount() < self:GetMaxNewerCount() then
			return true, true
		end
	end
	if self:GetMemberCount() < self:GetMaxMemberCount() then
		return true, false
	end
	return false, "幫派成員已滿"
end

function _KinData:Add2ApplyerList(player)
	local kinCache = self:GetCacheData();
	for _, tbData in pairs(kinCache.tbApplyerList) do
		if tbData.nPlayerId == player.dwID then
			return;
		end
	end

	table.insert(kinCache.tbApplyerList, {
		nPlayerId = player.dwID,
		nPlayerLevel = player.nLevel,
		szName = player.szName,
		nFaction = player.nFaction,
		nHonorLevel = player.nHonorLevel,
		nVipLevel = player.GetVipLevel(),
		nTime = GetTime()});

	while #kinCache.tbApplyerList>=Kin.Def.nMaxApplyList do
		table.remove(kinCache.tbApplyerList, 1)
	end

	kinCache.nApplyerListVersion = kinCache.nApplyerListVersion + 1;
end

function _KinData:ClearApplyerList()
	local kinCache = self:GetCacheData();
	if not kinCache.tbApplyerList or not next(kinCache.tbApplyerList) then
		return false, "暫無申請";
	end

	kinCache.tbApplyerList = {};
	kinCache.nApplyerListVersion = kinCache.nApplyerListVersion + 1;
	return true;
end

function Kin:DeleteApplyerFromAllList(nPlayerId)
	Kin:TraverseKin(function(tbKinData)
		tbKinData:DeleteApplyerFromList(nPlayerId)
	end)
end

function _KinData:DeleteApplyerFromList(nPlayerId)
	local kinCache = self:GetCacheData();
	local nIdx = nil;
	for _, tbData in pairs(kinCache.tbApplyerList) do
		if tbData.nPlayerId == nPlayerId then
			nIdx = _;
			break;
		end
	end

	if nIdx then
		table.remove(kinCache.tbApplyerList, nIdx);
		kinCache.nApplyerListVersion = kinCache.nApplyerListVersion + 1;
	end
end

function _KinData:GetApplyerList(nVersion)
	local kinCache = self:GetCacheData();

	if nVersion ~= kinCache.nApplyerListVersion then
		return kinCache.tbApplyerList, kinCache.nApplyerListVersion;
	end
end

function _KinData:Add2InviterList(nPlayerId, bPowerfulInvite)
	local kinCache = self:GetCacheData();
	for _, tbData in pairs(kinCache.tbInviteList) do
		if tbData.nPlayerId == nPlayerId then
			return;
		end
	end

	table.insert(kinCache.tbInviteList, {
		nPlayerId = nPlayerId,
		bPowerfulInvite = bPowerfulInvite,
		nTime = GetTime()});

	kinCache.nInviteListVersion = kinCache.nInviteListVersion + 1;
end

function _KinData:_TryGetOnlineMember()
	for nMemberId in pairs(self.tbMembers) do
		local pPlayer = KPlayer.GetPlayerObjById(nMemberId)
		if pPlayer then
			return pPlayer
		end
	end
	return nil
end

function _KinData:_ReportQQScore(nReportType, szReportData)
	local pPlayer = self:_TryGetOnlineMember()
	if not pPlayer then
		print("[x] _KinData:_ReportQQScore failed, no member online", nReportType, szReportData)
		return
	end
	AssistClient:ReportQQScore(pPlayer, nReportType, szReportData, 0, 1, true)
end

function _KinData:AddMember(nMemberId)
	local bResult = KinMgr.MemberJoin(nMemberId, self.nKinId);
	if not bResult then
		return false;
	end

	self.tbMembers[nMemberId] = Kin.Def.Career_Normal; -- 默认职位

	self:SetCacheFlag("UpdateMemberInfoList", true);
	self:SetCacheFlag("UpdateCount", true);
	self:SetCacheFlag("UpdateBaseInfo", true);
	self:SetCacheFlag("UpdateTopLevel", true);
	Kin:UpdateJoinKinsInfo(self.nKinId);
	self:Save();
	self:_ReportQQScore(Env.QQReport_KinMemberChange, 1)
	return true;
end

function _KinData:DeleteMember(nMemberId)
	if nMemberId==self.nLeaderId then
		self:BeginChangeLeader()
		Mail:SendKinMail({
			KinId = self.nKinId,
			Text = "    由於現任總堂主離開了幫派，新一任【總堂主】將于3天後評選，累積貢獻最高的成員將成為新的幫派總堂主。",
			From = "幫派總管",
		})
		self:SetLeaderId(0, false)
	elseif nMemberId==self.nCandidateLeaderId then
		self:CancelChangeLeader()
	end

	local targetMemberData = Kin:GetMemberData(nMemberId);
	if targetMemberData then
		targetMemberData:Quite();
	end

	self.tbMembers[nMemberId] = nil;
	self:SetCacheFlag("UpdateMemberInfoList", true);
	self:SetCacheFlag("UpdateCount", true);
	self:SetCacheFlag("UpdateBaseInfo", true);
	self:SetCacheFlag("UpdateTopLevel", true);

	Kin:RedBagMakeUnsendExpire(self.nKinId, nMemberId)
	KinMgr.MemberLeave(nMemberId, self.nKinId);
	Kin:UpdateJoinKinsInfo(self.nKinId);
	self:Save();

	self:_ReportQQScore(Env.QQReport_KinMemberChange, 2)
	TLog("KinFlow", Env.LogWay_LeaveKin, self.nKinId, self.szName, nMemberId, 0, 0);
end

function _KinData:ChangeCareer(nMemberId, career)
	if not self.tbMembers[nMemberId] then
		return false;
	end

	if career == Kin.Def.Career_Master then
		self.nMasterId = nMemberId;
	end

	local tbReportValue = {
		[Kin.Def.Career_Master] = 1, -- 族长
		[Kin.Def.Career_ViceMaster] = 2, -- 副族长
		[Kin.Def.Career_Normal] = 3, -- 正式成员
	}
	local nReportValue = tbReportValue[career]
	if nReportValue then
		self:_ReportQQScore(Env.QQReport_KinMemberTitleChange, nReportValue)
	end

	self.tbMembers[nMemberId] = career;

	self:SetCacheFlag("UpdateMemberInfoList", true);
	self:SetCacheFlag("UpdateCount", true);
	self:SetCacheFlag("UpdateBaseInfo", true);

	self:Save();
	return true;
end

function _KinData:GetDefaultCareer(nPlayerLevel)
	local nInLevel = Kin:GetCareerNewLevels()
	if nPlayerLevel<=nInLevel then
		if self:GetNewerCount()<self:GetMaxNewerCount() then
			return Kin.Def.Career_New
		end
	end
	return Kin.Def.Career_Normal
end


function _KinData:GetApplyerInfo(nApplyerId)
	local kinCache = self:GetCacheData();
	for _, applyerInfo in pairs(kinCache.tbApplyerList) do
		if applyerInfo.nPlayerId == nApplyerId then
			return applyerInfo;
		end
	end
end

function _KinData:CheckInviter(nInviterId)
	local kinCache = self:GetCacheData();
	for _, inviterInfo in pairs(kinCache.tbInviteList) do
		if inviterInfo.nPlayerId == nInviterId then
			return inviterInfo;
		end
	end
end

function _KinData:GetRecruitSetting(nVersion)
	if nVersion and nVersion == self.tbRecruitSetting.nVersion then
		return;
	end

	return self.tbRecruitSetting, self.tbRecruitSetting.nVersion;
end

function _KinData:SetRecruitSetting(bAutoRecruitNewer, bConditionRecruit, nLimitLevel, tbFaction)
	self.tbRecruitSetting.nLimitLevel       = nLimitLevel;
	self.tbRecruitSetting.bAutoRecruitNewer = bAutoRecruitNewer;
	self.tbRecruitSetting.bConditionRecruit = bConditionRecruit;
	self.tbRecruitSetting.tbFaction         = tbFaction;
	self.tbRecruitSetting.nVersion          = self.tbRecruitSetting.nVersion+1
	self:Save();
end

function _KinData:ChangeAddDeclare(szAddDeclare)
	self.tbRecruitSetting.szAddDeclare = szAddDeclare;
	self.tbRecruitSetting.nVersion     = self.tbRecruitSetting.nVersion+1

	Kin:UpdateJoinKinsInfo(self.nKinId);
	self:Save();
end

function _KinData:ChangePublicDeclare(szPublicDeclare)
	ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.Kin, me.szName .. "更新了幫派公告！", self.nKinId);

	self.szPublicDeclare = szPublicDeclare;
	self:SetCacheFlag("UpdateBaseInfo", true);
	self:Save();
end

function _KinData:CheckApplyAutoPass(player, bIsNewer)
	local setting = self.tbRecruitSetting;

	if setting.bAutoRecruitNewer and bIsNewer then
		return true;
	end

	if setting.bConditionRecruit then
		if player.nLevel < setting.nLimitLevel then
			return false;
		end

		if not setting.tbFaction[player.nFaction] then
			return false;
		end

		return true;
	end

	return false;
end

function _KinData:SetKinTitle(szEliteTitle, szNormalTitle, szNewerTitle, szRetireTitle, szLeaderTitle)
	self.tbKinTitle[Kin.Def.Career_Elite] = szEliteTitle or self.tbKinTitle[Kin.Def.Career_Elite];
	self.tbKinTitle[Kin.Def.Career_Normal] = szNormalTitle or self.tbKinTitle[Kin.Def.Career_Normal];
	self.tbKinTitle[Kin.Def.Career_New] = szNewerTitle or self.tbKinTitle[Kin.Def.Career_New];
	self.tbKinTitle[Kin.Def.Career_Retire] = szRetireTitle or self.tbKinTitle[Kin.Def.Career_Retire];
	self.szLeaderTitle = szLeaderTitle

	for nMemberId, nCareer in pairs(self.tbMembers) do
		if (nCareer == Kin.Def.Career_Normal and szNormalTitle) or
			(nCareer == Kin.Def.Career_Elite and szEliteTitle) or
			(nCareer == Kin.Def.Career_New and szNewerTitle) or
			(nCareer == Kin.Def.Career_Retire and szRetireTitle)
			then
			local memberData = Kin:GetMemberData(nMemberId);
			if memberData then
				local szKinTitle = memberData:GetFullTitle();
				Kin:SyncTitle(nMemberId, szKinTitle);
			end
		end
	end

	--领袖
	local nLeaderId = self.nLeaderId
	if nLeaderId and nLeaderId>0 then
		local tbLeader = Kin:GetMemberData(nLeaderId)
		if tbLeader then
			local szKinTitle = tbLeader:GetFullTitle()
			Kin:SyncTitle(nLeaderId, szKinTitle)
		end
	end

	self:SetCacheFlag("UpdateBaseInfo", true);
end

function _KinData:GetCareerMemberCount(nCareer)
	local nCount = 0;
	for _, career in pairs(self.tbMembers) do
		if career == nCareer then
			nCount = nCount + 1;
		end
	end

	return nCount;
end

local CareerSettingNameMap = {
	[Kin.Def.Career_Master]     = "MaxMaster",
	[Kin.Def.Career_ViceMaster] = "MaxViceMaster",
	[Kin.Def.Career_Elder]      = "MaxElder",
	[Kin.Def.Career_Elite]      = "MaxElite",
	[Kin.Def.Career_Mascot]     = "MaxMascot",
}

function _KinData:GetCareerMaxCount(nCareer)
	if not CareerSettingNameMap[nCareer] then
		return 999;
	end

	local nLevel = self:GetLevel();
	return Kin:GetMaxMember(nLevel, nCareer);
end

function _KinData:GetMemberCareer(nVersion)
	local kinCache = self:GetCacheData();
	if nVersion and nVersion == kinCache.nMemberCareerVersion then
		return;
	end

	if not kinCache.tbMemberCareer or kinCache.nMemberCareerVersion ~= kinCache.nMemberInfoListVersion then
		kinCache.tbMemberCareer = Lib:CopyTB1(self.tbMembers)
	end

	return kinCache.tbMemberCareer, kinCache.nMemberCareerVersion;
end

function _KinData:OnMasterLogin()
	if not self.nToBreakTime then
		return;
	end

	self.nToBreakTime = nil;

	-- todo? 通知取消待解散状态//

	self:Save();
end

function _KinData:DisbandImmediately()
	for nMemberId, nCareer in pairs(self.tbMembers) do
		local memberData = Kin:GetMemberData(nMemberId);
		if memberData then
			memberData:Quite();
		end
	end

	Kin:DeleteKin(self.nKinId, Env.LogWay_DeleteKinImmediately);
end

function _KinData:SetTargetCombineKin(nDstKinId)
	self.nCombineTargetId = nDstKinId;
	self:Save();
end

function _KinData:CheckCombineFlag(nSrcKinId)
	return self.nCombineTargetId == nSrcKinId;
end

function _KinData:GetClue()
	return self.nClue or 0
end

function _KinData:AddClue(nAdd)
	local nNow = GetTime()
	if not Lib:IsDiffDay(0, nNow, self.nLastClueTime or 0) then
		return false
	end
	self.nLastClueTime = nNow
	
	nAdd = nAdd or 1
	self.nClue = (self.nClue or 0)+nAdd
	self:Save()
	Log("_KinData:AddClue", self.nKinId, nAdd, self.nClue)
	return true
end

function _KinData:ResetClue()
	Log("_KinData:ResetClue", self.nKinId, self.nClue)
	self.nClue = 0
	self:Save()
end

function _KinData:Combine(srcKinData)
	for nMemberId, nCareer in pairs(srcKinData.tbMembers) do
		local memberData = Kin:GetMemberData(nMemberId);
		if memberData then
			if memberData:JoinKin(self) then
				if nCareer == Kin.Def.Career_New or nCareer == Kin.Def.Career_Retire then
					memberData:SetCareer(nCareer);
				else
					memberData:SetCareer(Kin.Def.Career_Normal);
				end
			end
		end
	end

	Kin:DeleteKin(srcKinData.nKinId, Env.LogWay_DeleteKinCombine);
	self:SetCacheFlag("UpdateMemberInfoList", true);
	self:SetCacheFlag("UpdateCount", true);
	self:SetCacheFlag("UpdateBaseInfo", true);
	Kin:UpdateJoinKinsInfo();
	self:Save();
end

---------------家族建设相关-----------------------
function _KinData:AddFound(nPlayerId, nValue)
	assert(nValue and nValue >= 0)
	nValue = Kin:GetReducedValue(nPlayerId, nValue)

	self.nFound = self.nFound + nValue;
	self:Save();
	self:SetCacheFlag("UpdateBaseInfo", true);
	TLog("KinFlow", Env.LogWay_KinAddFound, self.nKinId, self.szName, 0, nValue, self.nFound);
	return nValue
end

function _KinData:CostFound(nValue)
	assert(nValue and nValue >= 0)
	if self.nFound < nValue then
		return false;
	end

	self.nFound = self.nFound - nValue;
	self:Save();
	self:SetCacheFlag("UpdateBaseInfo", true);
	TLog("KinFlow", Env.LogWay_KinCostFound, self.nKinId, self.szName, 0, nValue, self.nFound);
	return true;
end

function _KinData:GetFound()
	return self.nFound;
end

function _KinData:GetMaxFound()
	return Kin:GetMaxFound(self:GetBuildingLevel(Kin.Def.Building_Treasure));
end

function _KinData:GetChangeCampCount()
	local nDay = Lib:GetLocalDay();
    if self.nKinCampDay ~= nDay then
    	self.nKinCampDay = nDay;
    	self.nKinCampCount = 0;
    end

    return self.nKinCampCount;
end

function _KinData:ChangeCamp(nCamp)
	local bRet = Kin:CheckKinCamp(nCamp);
	if not bRet then
		return false;
	end

    self.nKinCamp = nCamp;
    self:Save();
    self:SetCacheFlag("UpdateBaseInfo", true);
    self:UpdateMemberCamp();
	return true;
end

function _KinData:UpdateMemberCamp()
    for nMemberId, _ in pairs(self.tbMembers) do
    	local pPlayer = KPlayer.GetPlayerObjById(nMemberId);
    	if pPlayer then
    		pPlayer.SetOrgCamp(self.nKinCamp);
    	end
    end
end

function _KinData:GetCamp()
    return self.nKinCamp;
end

function _KinData:InitBuilding()
	self.tbBuilding = {
		[Kin.Def.Building_Main]         = {nLevel = 1},
		[Kin.Def.Building_Totem]        = {nLevel = 0},
		[Kin.Def.Building_War]          = {nLevel = 0},
		[Kin.Def.Building_DrugStore]    = {nLevel = 0},
		[Kin.Def.Building_WeaponStore]  = {nLevel = 0},
		[Kin.Def.Building_FangJuHouse]	= {nLevel = 0},
		[Kin.Def.Building_ShouShiHouse]	= {nLevel = 0},
		[Kin.Def.Building_Treasure]      = {nLevel = 1},
	}

	self:Save();
end

function _KinData:GetLevel()
	return self.tbBuilding[Kin.Def.Building_Main].nLevel;
end

function _KinData:GetMasterId()
	return self.nMasterId;
end

function _KinData:GetCareerMemberIds(nCareer)
	local tbMemberIds = {};
	self:TraverseMembers(function (memberData)
		if nCareer == memberData.nCareer then
			table.insert(tbMemberIds, memberData.nMemberId);
		end
		return true;
	end);
	return tbMemberIds;
end

function _KinData:GetBuildingOpenLevel(nBuildingId)
	if nBuildingId == Kin.Def.Building_Main then
		return Kin:GetMainBuildingOpenLevel();
	else
		local nCurLevel = self:GetBuildingLevel(nBuildingId);
		local nNextLevel = nCurLevel + 1;
		local nMaxBuildingLevel = Kin:GetBuildingMaxLevel(nBuildingId);
		if nNextLevel > nMaxBuildingLevel then
			return nMaxBuildingLevel;
		end

		local bCanLevelUp = Kin:CanLevelUp(nBuildingId, nNextLevel, self:GetLevel());
		return bCanLevelUp and nNextLevel or nCurLevel;
	end
end

function _KinData:GetAllBuildingData(nVersion)
	local tbKinCache = self:GetCacheData();
	if nVersion == tbKinCache.nBuildingVersion then
		return;
	end

	return self.tbBuilding, tbKinCache.nBuildingVersion;
end

function _KinData:GetBuildingLevel(nBuildingId)
	return self:GetBuildingData(nBuildingId).nLevel;
end

function _KinData:GetBuildingData(nBuildingId)
	return assert(self.tbBuilding[nBuildingId]);
end

function _KinData:BuildingLevelUp(nBuildingId)
	local tbBuildingData = self:GetBuildingData(nBuildingId);
	tbBuildingData.nLevel = tbBuildingData.nLevel + 1;
	self:Save();

	if nBuildingId == Kin.Def.Building_Main then
		self:SetCacheFlag("UpdateBaseInfo", true);
		RankBoard:UpdateRankVal("kin", self, tbBuildingData.nLevel)
		self:_ReportQQScore(Env.QQReport_KinLevel, tbBuildingData.nLevel)
	end

	local tbKinCache = self:GetCacheData();
	tbKinCache.nBuildingVersion = tbKinCache.nBuildingVersion + 1;

	TLog("KinFlow", Env.LogWay_KinBuildingLevelUp, self.nKinId, self.szName, 0, nBuildingId, tbBuildingData.nLevel);
	Log("KinBuildingLevelUp", self.szName, self.nKinId, Kin.Def.BuildingName[nBuildingId], tbBuildingData.nLevel);
	return true;
end

function _KinData:GetAuctionData()
	if not self.tbAuctionData then
		self.tbAuctionData = {};
	end

	return self.tbAuctionData;
end

function _KinData:SaveAuctionData()
	self:Save();
end

function _KinData:GoMap(nMemberId,nX,nY)
	self:CallWithMap(
		function (nMemberId)
			local member = KPlayer.GetPlayerObjById(nMemberId)
			if not member or member.nMapId == self:GetMapId() then
				return;
			end

			member.SetEntryPoint();

			local nPosX, nPosY = Map:GetDefaultPos(Kin.Def.nKinMapTemplateId);
			if nX and nY then
				nPosX, nPosY = nX,nY
			end
			member.SwitchMap(self:GetMapId(), nPosX, nPosY);

			Achievement:AddCount(member, "Family_2");
		end, nMemberId);
	return true;
end

function _KinData:CallWithMap(fnCallback, ...)
	if self:IsMapOpen() then
		fnCallback(...);
	else
		local nMapId = self:GetMapId();
		if not nMapId then
			nMapId = CreateMap(Kin.Def.nKinMapTemplateId);
			self:SetMapId(nMapId);
		end
		Kin:CallAfterMapLoaded(self.nKinId, nMapId, {fnCallback, ...});
		Kin.tbKinMapId2KinId[nMapId] = self.nKinId
	end
end

function _KinData:IsMapOpen()
	local nMapId = self:GetMapId();
	return Kin:IsLoadedKinMap(nMapId or 0);
end

function _KinData:SetMapId(nMapId)
	local tbKinCache = self:GetCacheData();
	tbKinCache.nMapId = nMapId;
end

function _KinData:GetMapId()
	local tbKinCache = self:GetCacheData();
	local nMapId = tbKinCache.nMapId;
	if not nMapId then
		return;
	end

	local nMapTemplateId = GetMapInfoById(nMapId);
	if not nMapTemplateId then
		tbKinCache.nMapId = nil;
		return;
	end

	return nMapId;
end

function _KinData:GetContributionInfo(nMemberId)
	return self.tbContribution[nMemberId];
end

function _KinData:RemoveContributionInfo(nMemberId)
	self.tbContribution[nMemberId] = nil
	self:Save()
end

function _KinData:SetContributionInfo(nMemberId, tbInfo, bClear)
	assert(self.tbMembers[nMemberId]);
	self.tbContribution[nMemberId] = tbInfo;

	if bClear then
		local nNow = GetTime();
		for nPlayerId, tbInfo in pairs(self.tbContribution) do
			if tbInfo.nDeleteTime
				and nNow > tbInfo.nDeleteTime
				and not self.tbMembers[nPlayerId]
				then
				self.tbContribution[nPlayerId] = nil;
			end
		end
	end

	self:Save();
end

-- 家族威望
function _KinData:AddPrestige(nValue, nLogReason)
	self.nPrestige = math.floor(self.nPrestige + nValue + 0.5);
	self:Save();
	self:SetCacheFlag("UpdateBaseInfo", true);
	RankBoard:UpdateRankVal("kin", self)
	TLog("KinFlow", Env.LogWay_KinAddPrestige, self.nKinId, self.szName, self.nPrestige, nValue, nLogReason);
	if nValue > 0 then
		ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.Kin, string.format("幫派於江湖中的威望值提升了%d", nValue), self.nKinId);
	end
end

function _KinData:GetPrestige()
	return self.nPrestige;
end

-- 家族运镖
function _KinData:CheckKinEscortLastDate()
	if not self.nKinEscortLastDate then
		self.nKinEscortLastDate = Lib:GetLocalDay()-1;
	end
end

function _KinData:UpdateLastKinEscortDate()
	self.nKinEscortLastDate = Lib:GetLocalDay()
	self:Save()
end

function _KinData:GetLastKinEscortDate()
	self:CheckKinEscortLastDate();
	return self.nKinEscortLastDate;
end

function _KinData:TraverseMembers(fnOperate, ...)
	for nMemberId, nCareer in pairs(self.tbMembers) do
		local memberData = Kin:GetMemberData(nMemberId);
		local bContinue = fnOperate(memberData, ...);
		if not bContinue then
			break;
		end
	end
end

function _KinData:GetGatherData()
	local tbKinCache = self:GetCacheData();
	if not tbKinCache.tbGatherData then
		tbKinCache.tbGatherData = {};
	end

	return tbKinCache.tbGatherData;
end

function _KinData:ResetGatherData()
	local tbKinCache = self:GetCacheData();
	tbKinCache.tbGatherData = {};
end

function _KinData:GetSnowmanData()
	local tbKinCache = self:GetCacheData();
	if not tbKinCache.tbSnowmanData then
		tbKinCache.tbSnowmanData = {};
	end

	return tbKinCache.tbSnowmanData;
end

function _KinData:ResetSnowmanData()
	local tbKinCache = self:GetCacheData();
	tbKinCache.tbSnowmanData = {};
end

function _KinData:GetGatherWinNames()
	local tbKinCache = self:GetCacheData();
	return tbKinCache.tbGatherWinNames or {};
end

function _KinData:SetGatherWinNames(tbGatherWinNames)
	local tbKinCache = self:GetCacheData();
	tbKinCache.tbGatherWinNames = tbGatherWinNames;
end

function _KinData:GetBattleKingNames()
	local tbKinCache = self:GetCacheData();
	local nCurDay = Lib:GetLocalDay();
	if tbKinCache.nInsertBattleKingDay ~= nCurDay
		or not tbKinCache.tbBattleKingNames then
		tbKinCache.tbBattleKingNames = {};
		tbKinCache.nInsertBattleKingDay = nCurDay;
	end
	return tbKinCache.tbBattleKingNames or {};
end

function _KinData:InsertBattleKingName(szName)
	local tbBattleKingNames = self:GetBattleKingNames();
	table.insert(tbBattleKingNames, szName);
end

function _KinData:GetHeroChallengeWin10Names()
	local tbKinCache = self:GetCacheData();
	local nCurDay = Lib:GetLocalDay();
	if tbKinCache.nHeroChallengeWin10Day ~= nCurDay
		or not tbKinCache.tbHeroChallengeWin10Names then
		tbKinCache.tbHeroChallengeWin10Names = {};
		tbKinCache.nHeroChallengeWin10Day = nCurDay;
	end
	return tbKinCache.tbHeroChallengeWin10Names;
end

function _KinData:InsertHeroChallengeWin10Name(szName)
	local tbHeroChallengeWin10Names = self:GetHeroChallengeWin10Names();
	table.insert(tbHeroChallengeWin10Names, szName);
end

function _KinData:CacheKinEscortColor(szColor)
	local tbEscortData = {
		nDay = Lib:GetLocalDay();
		szColor = szColor;
	}
	self:SetCacheFlag("KinEscortColor", tbEscortData);
end

function _KinData:GetYesterdayKinEscortColor()
	local tbEscortData = self:GetCacheFlag("KinEscortColor") or {};
	local nYesterDay = Lib:GetLocalDay() - 1;
	if tbEscortData.nDay == nYesterDay then
		return tbEscortData.szColor;
	end
end

function _KinData:CacheLatestTower7Player(szPlayerName)
	self:SetCacheFlag("LatestTower7", szPlayerName);
end

function _KinData:GetLatestTower7PlayerName()
	return self:GetCacheFlag("LatestTower7");
end

function _KinData:GetLeftMailCount()
	local nToday = Lib:GetLocalDay(GetTime() - Kin.Def.nGiftBagRefreshTime);
	if nToday ~= self.nRefreshMailDay or not self.nLeftMailCount then
		self.nRefreshMailDay = nToday;
		self.nLeftMailCount = Kin.Def.nMaxMailCount;
	end

	return self.nLeftMailCount;
end

function _KinData:ReduceLeftMailCount()
	local nLeftMailCount = self:GetLeftMailCount();
	self.nLeftMailCount = nLeftMailCount - 1;
	self:Save();
end

function _KinData:GetDonationRecord(nVersion)
	if nVersion == self.nDonationDataVersion then
		return;
	end

	return self.tbDonationRecord, self.nDonationDataVersion;
end

function _KinData:SaveDonationRecord(szDonator, nFoundAdd, nCount)
	table.insert(self.tbDonationRecord, {szDonator, nFoundAdd, nCount});
	self.nDonationDataVersion = self.nDonationDataVersion + 1;

	while #self.tbDonationRecord > Kin.Def.nDonationMaxRecordCount do
		table.remove(self.tbDonationRecord, 1);
	end
	self:Save();
end

 -- 自定义存盘数据
function _KinData:GetCustomData(szType)
	if not self.tbCustomData then
		self.tbCustomData = {};
	end

	if not self.tbCustomData[szType] then
		self.tbCustomData[szType] = {};
	end

	return self.tbCustomData[szType];
end

function _KinData:Save()
	Kin.tbKinDataSaveMap[self.nKinId] = true;
end


function _KinData:OnFinishKinTask()
	self.tbKinTask = self.tbKinTask or {};
	local nToday = Lib:GetLocalDay(GetTime() - (4 * 3600));
	if not self.tbKinTask.nDate or self.tbKinTask.nDate < nToday then
		self.tbKinTask.nDate = nToday;
		self.tbKinTask.nCount = 0;
	end

	self.tbKinTask.nCount = self.tbKinTask.nCount + 1;
	local nPrestige = Kin.Task2Prestige[self.tbKinTask.nCount];
	if nPrestige and nPrestige > 0 then
		self:AddPrestige(nPrestige, Env.LogWay_KinTaskOnFinish);
	end
	self:Save();
end

function _KinData:GetLastRank()
	return self.nLastRank or -1
end

function _KinData:SetLastRank(nRank)
	self.nLastRank = nRank
	self:SetCacheFlag("UpdateBaseInfo", true);
end

function _KinData:GetLeaderId()
	return self.nLeaderId or 0
end

function _KinData:SetCandidateLeaderId(nId)
	self.nCandidateLeaderId = nId
	self:SetCacheFlag("UpdateBaseInfo", true)
end

function _KinData:SetChangeLeaderTime(nTime)
	self.nChangeLeaderTime = nTime or GetTime()
	self:SetCacheFlag("UpdateBaseInfo", true)
end

function _KinData:GetCandidateLeaderId()
	return self.nCandidateLeaderId or 0
end

function _KinData:GetChangeLeaderTime()
	return self.nChangeLeaderTime or 0
end

function _KinData:SetLeaderId(nLeaderId, bSendMail)
	local nOldLeaderId = self:GetLeaderId()
	if bSendMail and nOldLeaderId~=nLeaderId then
		local tbMember = Kin:GetMemberData(nLeaderId)
		if tbMember then
			local szName = tbMember:GetName()
			local nContribution = tbMember:GetContribution()
			Mail:SendKinMail({
				KinId = self.nKinId,
				Text = string.format("    幫派的諸位弟兄！大俠「%s」在幫派中的累計貢獻已達%d，遠超他人，成為新一任幫派【總堂主】乃實至名歸，族中皆兄弟，還望各位弟兄日後能夠鼎力相助，我等一同奮戰，齊心協力，書寫幫派輝煌！", szName, nContribution),
				From = "幫派總管",
			})
		end
	end
	self.nLeaderId = nLeaderId
	if bSendMail then
		Mail:SendSystemMail({
	        To = nLeaderId,
	        Title = "幫派職位任命",
	        Text = "恭喜您被任命為【總堂主】\n擁有許可權：任免堂主、招收成員",
	        From = "幫派總管",
	        tbAttach = {},
	    })
	end
    self:SetCandidateLeaderId(0)

	local tbOldLeader = Kin:GetMemberData(nOldLeaderId)
	if tbOldLeader then
		local szOldTitle = tbOldLeader:GetFullTitle()
		Kin:SyncTitle(nOldLeaderId, szOldTitle)
	end

	local tbNewLeader = Kin:GetMemberData(nLeaderId)
	if tbNewLeader then
		local szNewTitle = tbNewLeader:GetFullTitle()
		Kin:SyncTitle(nLeaderId, szNewTitle)
	end

	self:Save()
end

function _KinData:GetGroupOpenId()
	return self.szQQGroupOpenId;
end

function _KinData:GetGroupName()
	return self.szQQGroupName;
end

function _KinData:SetQQGroupOpenData(szQQGroupOpenId, szQQGroupName)
	if self.szQQGroupOpenId == szQQGroupOpenId and self.szQQGroupName == szQQGroupName then
		return false;
	end

	self.szQQGroupName = szQQGroupName;
	self.szQQGroupOpenId = szQQGroupOpenId;
	self:SetCacheFlag("UpdateBaseInfo", true);
	self:Save();

	if szQQGroupName then
		self:_ReportQQScore(Env.QQReport_QQGrpBind, szQQGroupName)
		self:_ReportQQScore(Env.QQReport_QQGrpBindTime, GetTime())
	end

	return true;
end

function _KinData:GetQQGroupNum()
	return self.szQQGroupNum;
end

function _KinData:SetQQGroupNum(szQQGroupNum)
	self.szQQGroupNum = szQQGroupNum;
	self:Save();
end

function _KinData:AppointLeader(nCandidateLeaderId)
	local nNow = GetTime()
	if nNow-self.nAppointLeaderTime<=24*3600 then
		local nHours = 24 - (GetTime()-self.nAppointLeaderTime)/3600
		return false, string.format("需%d小時後才可再進行總堂主任命操作", nHours)
	end
	self.nAppointLeaderTime = nNow

	self:BeginChangeLeader(nCandidateLeaderId)

	local pLeader = KPlayer.GetRoleStayInfo(self.nLeaderId)
	local pCandidate = KPlayer.GetRoleStayInfo(nCandidateLeaderId)
	if pLeader and pCandidate then
		local szMsg = string.format("「%s」將「%s」任命為【候選總堂主】，將在72小時後正式成為【總堂主】", pLeader.szName, pCandidate.szName)
		ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.Kin, szMsg, self.nKinId)
	end
	return true
end

function _KinData:OnLeaderLogin()
	if self.nCandidateLeaderId>0 then
		-- 领袖主动任命
		local tbCandidate = Kin:GetMemberData(self.nCandidateLeaderId)

		--候选人不在家族
		if tbCandidate and tbCandidate.nKinId~=self.nKinId then
			self:CancelChangeLeader()
			return
		end

		local nDeadline = Kin:ComputeChangeLeaderDeadline(self.nChangeLeaderTime)
		local nSeconds = math.max(0, nDeadline-GetTime())
		local szTimeStr = Lib:TimeDesc5(nSeconds)
		Mail:SendSystemMail({
	 		To = self.nLeaderId,
	        Title = "總堂主任命",
	        Text = string.format("    「%s」被你任命為【候選總堂主】，將在%s後正式成為【總堂主】，期間可以通過職位管理介面取消任命。", tbCandidate:GetName(), szTimeStr),
	        From = "系統",
	        tbAttach = {},
		})
	elseif self.nChangeLeaderTime>0 then
		--7天未登陆，自动更换

		self:CancelChangeLeader()
		Mail:SendKinMail({
			KinId = self.nKinId,
			Text = "    由於現任總堂主重出江湖，自動取消正在進行的總堂主評選。（評選期間現任總堂主上線，自動取消總堂主評選）",
			From = "幫派總管",
		})
	end
end

function _KinData:CheckLeaderOn()
	if self.nChangeLeaderTime>0 then
		if GetTime()-self.nChangeLeaderTime >= Kin.Def.nChangeLeaderTime then
			self:_ChangeLeader()
		end
	end
end

function _KinData:CheckLeaderOff()
	if self.nChangeLeaderTime>0 then return end
	local _,nLeaderOffSeconds = Player:GetOfflineDays(self.nLeaderId)
	if nLeaderOffSeconds and nLeaderOffSeconds>=7*24*3600 then
		self:BeginChangeLeader()
		Mail:SendKinMail({
			KinId = self.nKinId,
			Text = "    由於現任總堂主隱退江湖（離線超7天），新一任【總堂主】將于3天后評選，累積貢獻最高的成員將成為新的幫派總堂主。",
			From = "幫派總管",
		})
	end
end

function _KinData:_ChangeLeader()
	self.nChangeLeaderTime = 0

	local nLeaderId = self.nCandidateLeaderId
	if self.nCandidateLeaderId<=0 then
		local tbMembers = self:GetMemberInfoList()
		local tbMaxInfo = nil
		for _,tbInfo in ipairs(tbMembers) do
			if not tbMaxInfo or tbMaxInfo.nContribution<tbInfo.nContribution then
				local nOffDays = Player:GetOfflineDays(tbInfo.nMemberId)
				if nOffDays and nOffDays<7 then
					tbMaxInfo = tbInfo
				end
			end
		end

		nLeaderId = tbMaxInfo and tbMaxInfo.nMemberId or self.nMasterId
	else
		local tbMember = Kin:GetMemberData(nLeaderId)
		if tbMember and tbMember.nKinId~=self.nKinId then
			nLeaderId = self.nLeaderId>0 and self.nLeaderId or self.nMasterId
		end
	end

	local bSendMail = true
	if self.nCandidateLeaderId==nLeaderId then
		local pLeader = KPlayer.GetRoleStayInfo(self.nLeaderId)
		local pCandidate = KPlayer.GetRoleStayInfo(nLeaderId)
		if pLeader and pCandidate then
			Mail:SendKinMail({
				KinId = self.nKinId,
				Text = string.format("    「%s」將「%s」任命為新一任【總堂主】", pLeader.szName, pCandidate.szName),
				From = "幫派總管",
			})
			bSendMail = false
		end
	end

	self:SetLeaderId(nLeaderId, bSendMail)
end

function _KinData:BeginChangeLeader(nCandidateLeaderId)
	self:SetChangeLeaderTime()
	self:SetCandidateLeaderId(nCandidateLeaderId or 0)
end

function _KinData:CancelChangeLeader()
	self:SetChangeLeaderTime(0)
	self:SetCandidateLeaderId(0)
end

function _KinData:SetSnowflake(nCount)
	self.nSnowflake = nCount
	self:SetCacheFlag("UpdateBaseInfo", true);
	self:Save();
end

function _KinData:SetMakingPlayer(nLevel,dwID)
	self.tbMakingPlayer = self.tbMakingPlayer or {}
	self.tbMakingPlayer[nLevel] = self.tbMakingPlayer[nLevel] or {}
	self.tbMakingPlayer[nLevel][dwID] = true
	self:SetCacheFlag("UpdateBaseInfo", true);
	self:Save();
end

function _KinData:ResetMakingPlayer()
	self.tbMakingPlayer = {}
	self:SetCacheFlag("UpdateBaseInfo", true);
	self:Save();
end

--------------------------IDIP相关-------------------------------------
function _KinData:SetBanRankTime(nEndTime,szReason)
	self.nBanTime = nEndTime
	self.szBanTips = szReason
	self:SetCacheFlag("UpdateBaseInfo", true);
	self:Save();
end

function _KinData:GetBanRankTime()
	return self.nBanTime and self.nBanTime or 0
end

function _KinData:GetBanRankTips()
	return self.szBanTips and self.szBanTips or ""
end

function _KinData:CheckRankForbid()
	if self.nBanTime and self.nBanTime ~= 0 and not Forbid:IsBanning(_,Forbid.BanType.KinRank,self.nKinId) then
		self.nBanTime = 0
		self.szBanTips = ""
		RankBoard:UpdateRankVal("kin", self)
	end
end

---------活跃相关
function _KinData:GetWeekActive()
	return self.nWeekActive or 0
end

function _KinData:AddWeekActive(nAdd)
	self.nWeekActive = self:GetWeekActive()+nAdd
end

function _KinData:ResetWeekActive()
	self.nWeekActive = 0
	for nMid in pairs(self.tbMembers) do
		local tbMember = Kin:GetMemberData(nMid)
		if tbMember then
			tbMember:ResetWeekActive()
		end
	end
	self:Save()
end

function _KinData:ResetWeekChargeProfit()
	local bKeep = Kin:_ShouldKeepSalary(self.nKinId)
	Log("_KinData:ResetWeekChargeProfit", self.nKinId, tostring(self.nTotalCharge), bKeep)
	if bKeep then return end

	self.nTotalCharge = 0
	self:Save()
end

function _KinData:CorrectWeekActive()
	local nTotal = 0
	for nMemberId in pairs(self.tbMembers) do
		local tbMemberData = Kin:GetMemberData(nMemberId)
		if tbMemberData then
			tbMemberData:DailyUpdateActive()
			nTotal = nTotal+tbMemberData:GetWeekActive()
		end
	end
	self.nWeekActive = nTotal
	self:Save()

	self:TLogDailyKinData()
end

function _KinData:TLogDailyKinData()
	local pRank = KRank.GetRankBoard("kin")
	if not pRank then
		return
	end
	local szGameAppid, nPlat, nServerIdentity, nAreaId = GetWorldConfifParam()
	local pInfo = pRank.GetRankInfoByID(self.nKinId)
	local nPosition = pInfo and pInfo.nPosition or 0;
	local tbMembers = Kin:GetKinMembers(self.nKinId, true)
	local nLevel = self:GetBuildingData(Kin.Def.Building_Main).nLevel
	local szKinName = self.szName
	local nCreateTime = self.nCreateTime
	local nFound = self:GetFound()
	local nLeaderId = self:GetLeaderId();
	for memberId, nCareer in pairs(tbMembers) do
		local tbMember = Kin:GetMemberData(memberId)
		if tbMember then
			local szAccount = KPlayer.GetPlayerAccount(memberId) or ""
			TLog("KinDaliyFlow", szGameAppid, nPlat, nServerIdentity, self.nKinId, self.nPrestige, nPosition, szAccount, memberId, nCareer, szKinName,
				 nLevel, nCreateTime, nFound, tbMember:GetContribution(), tbMember:GetWeekActive(), self:GetWeekActive(),nLeaderId == memberId and 1 or 0)
		end
	end
end

function _KinData:ResetMemberDailyActive()
	for nMemberId in pairs(self.tbMembers) do
		local tbMemberData = Kin:GetMemberData(nMemberId)
		if tbMemberData then
			tbMemberData:SetTodayActive(0)
		end
	end
	self:Save()
end

function _KinData:CanJudgeWeeklyActivity()
	return (GetTime()-self.nCreateTime) >= 7*24*3600
end

function _KinData:TransferCareerNew()
	local nMaxNormal = self:GetMaxMemberCount()
	local nCurNormal = self:GetMemberCount()
	local nHoles = nMaxNormal-nCurNormal
	if nHoles<=0 then
		return
	end

	local bChanged = false
	local _, nTransferLevel = Kin:GetCareerNewLevels()
	for nId, nCareer in pairs(self.tbMembers) do
		if nHoles<=0 then
			break
		end

		if nCareer==Kin.Def.Career_New then
			local pStay = KPlayer.GetRoleStayInfo(nId)
			if pStay.nLevel>=nTransferLevel then
				local tbMem = Kin:GetMemberData(nId)
				if tbMem then
					tbMem:SetCareer(Kin.Def.Career_Normal)
					nHoles = nHoles-1
					bChanged = true
				end
			end
		end
	end

	if bChanged then
		self:SetCacheFlag("UpdateCount", true)
		self:Save()
	end
end

function _KinData:GetChargeActiveInfo()
	local nGolds = math.min((self.nTotalCharge or 0), Kin.Def.nMaxChargeActiveGolds)
	local nKinWeekDay = Kin:GetActivityWeekDay(self.nCreateTime)
	local nActive = math.floor(nGolds*Kin.Def.nCharge2Activity/7*nKinWeekDay)
	return nActive, math.floor(nActive/nKinWeekDay)
end

function _KinData:GetActivityAvg()
	local nWeekActive = self:GetWeekActive()
	local nKinWeekDay = Kin:GetActivityWeekDay(self.nCreateTime)
	return math.floor(nWeekActive/nKinWeekDay)
end

function _KinData:_SalaryGetInfo(nMemberId)
	local nOldCareer = self.tbMembers[nMemberId]
	if not Kin.tbActivityCareerSalary[nOldCareer] then
		return false
	end

	local tbMemberData = Kin:GetMemberData(nMemberId)
	if not tbMemberData then
		return false
	end

	local bMaster = nOldCareer==Kin.Def.Career_Master
	local nCareerWeek = Lib:GetLocalWeek(tbMemberData.nCareerTime)
	local nThisWeek = Lib:GetLocalWeek(GetTime())
	if nCareerWeek==nThisWeek and not bMaster then
		return false
	end

	local nKinActive = self:GetWeekActive()
	local nActiveAvg = self:GetActivityAvg()
	local tbSetting = Kin:_GetActivitySetting(nActiveAvg)
	local nMyActiveAvg = tbMemberData:GetActivityAvg()
	local nSalary = tbSetting.nHasSalary>0 and Kin:_GetSalary(nOldCareer, nKinActive, nMyActiveAvg) or 0
	nSalary = nCareerWeek==nThisWeek and 0 or math.floor(nSalary/2)
	return true, bMaster, nSalary
end

function _KinData:OnMemberCharge(nPlayerId, nCharge)
	Log("_KinData:OnMemberCharge", self.nKinId, nPlayerId, nCharge)
	self.nTotalCharge = (self.nTotalCharge or 0) + nCharge
	self:Save()
end

function _KinData:CheckAddBattleApplysLimit(nItemId, nNum)
	local nToday = Lib:GetLocalDay()
	if self.nAddBattleSupplyDay ~= nToday then
		self.nAddBattleSupplyDay = nToday
		self.tbAddBattleSupplyLimit = {}
	end
	local nLimitNum = DomainBattle.define.tbBattleApplyLimit[nItemId]
	if not nLimitNum then
		return
	end
	if (self.tbAddBattleSupplyLimit[nItemId] or 0) + nNum > nLimitNum then
		local tbItembase = KItem.GetItemBaseProp(nItemId)
		return false, string.format("每天最多買%d個%s", nLimitNum, tbItembase.szName)
	end
	return true
end
--todo 战争坊增加物资
function _KinData:AddBattleApplys(nItemId, nNum)
	self.tbAddBattleSupplyLimit[nItemId] = (self.tbAddBattleSupplyLimit[nItemId] or 0 ) + nNum

	self.tbBattleSupply = self.tbBattleSupply or {}
	DomainBattle:SetData(self.nKinId, self.tbBattleSupply, nItemId, ((self.tbBattleSupply[nItemId] or 0) + nNum)) --暂时先都用领土战的版本号变化
	self:Save();
end

function _KinData:GetBattleApplys()
	return self.tbBattleSupply and Lib:CopyTB(self.tbBattleSupply) or {};
end

function _KinData:UseBattleApplys(nItemId)
	if not self.tbBattleSupply then
		return
	end
	local nNum = self.tbBattleSupply[nItemId]
	if not nNum or nNum <= 0 then
		return false, Lib:CopyTB(self.tbBattleSupply)
	end
	self.tbBattleSupply[nItemId] = nNum - 1
	DomainBattle:SetData(self.nKinId, self.tbBattleSupply, nItemId, nNum - 1)
	self:Save();
	return true, Lib:CopyTB(self.tbBattleSupply)
end

function _KinData:ChangeName(szKinName, bNotNotify)
	local szOldName = self.szName
	self.szName = szKinName
	self:SetCacheFlag("UpdateBaseInfo", true)
	self:Save()
	KinMgr.ChangeKinName(self.nKinId, szKinName)

	Kin.tbAllKinNames[szOldName] = nil
	Kin.tbAllKinNames[szKinName] = true

	if not bNotNotify then
		Mail:SendKinMail({
			KinId = self.nKinId,
			Title = "幫派改名",
			Text = string.format("幫派正式更名為【%s】", szKinName),
			From = "幫派總管",
		})

		local szWorldNotifyMsg = string.format("諸位江湖俠士，經幫中弟兄商議，幫派【%s】現正式更名為【%s】，在此告知武林同道。", szOldName, szKinName)
		KPlayer.SendWorldNotify(0, 1000, szWorldNotifyMsg, 1, 1)

		self:TraverseMembers(function(tbMember)
			local nMemberId = tbMember.nMemberId
			local pMember = KPlayer.GetPlayerObjById(nMemberId)
			if pMember then
				local szKinTitle = tbMember:GetFullTitle()
				Kin:SyncTitle(nMemberId, szKinTitle)
			end
			return true
		end)
	end


	return true
end

function _KinData:CheckResetTitle()
	local tbCurTitles = {
		[Kin.Def.Career_Leader] = self.szLeaderTitle,
	}
	for nCareer, szTitle in pairs(self.tbKinTitle) do
		tbCurTitles[nCareer] = szTitle
	end

	local bChanged = false
	for nCareer, szTitle in pairs(tbCurTitles) do
		if Kin:IsCareerTitleForbidden(nCareer, szTitle) then
			if nCareer==Kin.Def.Career_Leader then
				self.szLeaderTitle = nil
			else
				self.tbKinTitle[nCareer] = nil
			end
			bChanged = true
		end
	end

	self:TraverseMembers(function(tbMemberData)
		if tbMemberData:CheckResetTitle() then
			bChanged = true
		end
		return true
	end)

	if bChanged then
		self:Save()
		self:SetCacheFlag("UpdateMemberInfoList", true)
	end
end

function _KinData:CheckOrgServer()
	if not self.nOrgServerId then
		self.nOrgServerId = Sdk:GetServerId();
		self:Save();
	end
end

function _KinData:GetOrgServerId()
	return self.nOrgServerId;
end

function _KinData:SetOrgServerId(nServerId)
	self.nOrgServerId = nServerId;
	self:Save();
	self:SetCacheFlag("UpdateBaseInfo", true);
end

function _KinData:GetAwardGuarantee(szAwardKey)
	self.tbAwardGuarantee = self.tbAwardGuarantee or {}
	return self.tbAwardGuarantee[szAwardKey] or 0
end

function _KinData:SetAwardGuarantee(szAwardKey, nValue)
	self.tbAwardGuarantee = self.tbAwardGuarantee or {};
	self.tbAwardGuarantee[szAwardKey] = nValue;
	self:Save();
	Log("[Info]", "SetAwardGuarantee", self.nKinId, self.szName, szAwardKey, nValue)
end

function _KinData:GetLastPushMailTime()
	return self.nLastPushMail or 0
end

function _KinData:UpdateLastPushMailTime()
	self.nLastPushMail = GetTime()
	self:Save()
end

-------------------------_KinMember--------------------------------------

function _KinMember:GetMemberCacheData()
	if not Kin._CacheKinMemberData[self.nMemberId] then
		Kin._CacheKinMemberData[self.nMemberId] = {};
	end

	return Kin._CacheKinMemberData[self.nMemberId];
end

function _KinMember:CheckAuthority(authority)
	local careerAuthority = Kin.Def.Career_Authority[self.nCareer] or {};
	if careerAuthority[authority] then
		return true;
	end

	if self:IsLeader() and Kin.Def.Career_Authority[Kin.Def.Career_Leader][authority] then
		return true;
	end

	-- 只有副族长可被授予权限..
	if self.nCareer ~= Kin.Def.Career_ViceMaster then
		return false;
	end

	if authority == Kin.Def.Authority_GrantMaster then
		return self.nCareer == Kin.Def.Career_Master;
	end

	return self.tbAuthority[authority] and true or false;
end

function _KinMember:IsLeader()
	local kinData = Kin:GetKinById(self.nKinId);
	return kinData:GetLeaderId() == self.nMemberId;
end

function _KinMember:SetAuthority(tbAuthority)
	self.tbAuthority = tbAuthority;
	self:Save();
end

function _KinMember:JoinKin(kinData)
	if not kinData:AddMember(self.nMemberId) then
		return false;
	end

	self.nKinId = kinData.nKinId;
	self.nJoinTime = GetTime();
	self.tbAuthority = {};

	local tbRoleStayInfo = KPlayer.GetRoleStayInfo(self.nMemberId);
	local nCareer = kinData:GetDefaultCareer(tbRoleStayInfo.nLevel);
	self:SetCareer(nCareer);
	self:ResetContribution();

	local member = KPlayer.GetPlayerObjById(self.nMemberId);
	if member then
		local szFullTitle = self:GetFullTitle();
		member.dwKinId = kinData.nKinId;
		member.OnEvent("OnJoinKin", kinData.nKinId);
		member.CallClientScript("Kin:OnKinJoined", kinData.nKinId, szFullTitle);
		Kin:SyncTitle(self.nMemberId, szFullTitle);
		Achievement:AddCount(member, "Family_1");

		local nKinCamp = kinData:GetCamp();
		member.SetOrgCamp(nKinCamp);

		TeacherStudent:TargetAddCount(member, "JoinKin", 1)
	end

	local nMasterId = kinData.nMasterId
	if nMasterId ~= self.nMemberId then
		local szInfo = string.format("歡迎「%s」成為本幫派的一員！#49", tbRoleStayInfo.szName);
		ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.Kin, szInfo, self.nKinId);
	end

	Kin:DeleteApplyerFromAllList(self.nMemberId)
	self:Save();

	if nCareer==Kin.Def.Career_New and nMasterId~=self.nMemberId then
		Mail:SendSystemMail({
			To = self.nMemberId,
			Title = "幫派信件",
			From = "幫派總管",
			Text = "    歡迎俠士加入本幫派！由於俠士等級較低，將暫時作為幫派中的小弟！小弟在幫派中享有特權，可被幫派其他成員[FFFE0D]【額外傳功兩次】[-]，幫助你早日提升自身實力，早日成為族中棟樑！",
		})
	end

	Kin:UpdateJoinCD(self.nMemberId, false)

	if member then
		Kin:RedBagSendNoKinDelay(member)
	end

	TLog("KinFlow", Env.LogWay_JoinKin, self.nKinId, kinData.szName, self.nMemberId, tbRoleStayInfo.nLevel, nCareer);
	return true;
end

function _KinMember:GetJoinTime()
	return self.nJoinTime;
end

function _KinMember:AddContribution(nValue, nLogReason)
	if nLogReason and Kin.Def.tbExcludeAddContribLogReasons[nLogReason] then
		return
	end

	local kinData = Kin:GetKinById(self.nKinId);
	local tbInfo = kinData:GetContributionInfo(self.nMemberId);
	if not tbInfo then
		tbInfo = {nValue = 0};
		Log("ERROR:Kin:AddContribution Fail", self.nKinId, self.nMemberId);
	end
	tbInfo.nValue = tbInfo.nValue + nValue;
	kinData:SetContributionInfo(self.nMemberId, tbInfo);
	kinData:SetCacheFlag("UpdateMemberInfoList", true);

	TLog("KinFlow", Env.LogWay_KinAddContribution, self.nKinId, self:GetName(), self.nMemberId, nValue, nLogReason);
	Log("AddContrib", self:GetName(), self.nMemberId, self.nKinId, kinData.szName, tbInfo.nValue, nValue, nLogReason);
end

-- 只有在有成员加入时才会调用
function _KinMember:ResetContribution()
	local nMemberId = self.nMemberId
	local nLastKinId = Kin:GetPlayerLastKinId(nMemberId)
	local nCurKinId = self.nKinId

	local kinData = Kin:GetKinById(nCurKinId);
	local tbInfo = kinData:GetContributionInfo(nMemberId) or {nValue = 0};
	if tbInfo.nDeleteTime and GetTime() > tbInfo.nDeleteTime then
		tbInfo.nValue = 0;
	end
	tbInfo.nDeleteTime = nil;

	if nCurKinId~=nLastKinId then
		local tbLastKinData = Kin:GetKinById(nLastKinId)
		if tbLastKinData then
			tbLastKinData:RemoveContributionInfo(nMemberId)
		end
		tbInfo.nValue = 0
		Kin:SetPlayerLastKinId(nMemberId, nCurKinId)
	end

	kinData:SetContributionInfo(nMemberId, tbInfo, true);
end

function _KinMember:GetContribution()
	local kinData = Kin:GetKinById(self.nKinId);
	local tbInfo = kinData:GetContributionInfo(self.nMemberId) or {};
	if not tbInfo.nValue then
		Log("ERROR:Kin:GetContribution ", self.nKinId, self.nMemberId);
	end
	return tbInfo.nValue or 0;
end

function _KinMember:GetCareer()
	return self.nCareer;
end

function _KinMember:SetCareer(career)
	if career == self.nCareer then
		return;
	end

	local kinData = Kin:GetKinById(self.nKinId);
	kinData:ChangeCareer(self.nMemberId, career);

	self.nCareer = career;
	self.nCareerTime = GetTime()

	local szKinTitle = self:GetFullTitle();
	Kin:SyncTitle(self.nMemberId, szKinTitle);

	self:Save();
end

function _KinMember:SetDomainBattleVersion()
	self.nLastnBattleVersion = DomainBattle:GetBattleVersion()
	self:Save()
end

function _KinMember:GetDomainBattleVersion()
	return self.nLastnBattleVersion;
end

function _KinMember:SendSetCareerMail(nCareer)
	-- 每天限3次
	local tbMemberCache = self:GetMemberCacheData();
	local nToday = Lib:GetLocalDay();
	if tbMemberCache.nSendMailDay ~= nToday then
		tbMemberCache.nCurDaySendMailCount = 0;
		tbMemberCache.nSendMailDay = nToday;
	end

	if tbMemberCache.nCurDaySendMailCount >= Kin.Def.nMaxCareerMailPerDay then
		return;
	end
	tbMemberCache.nCurDaySendMailCount = tbMemberCache.nCurDaySendMailCount + 1;

	local szMailContent = string.format("恭喜您被任命為【%s】\n", Kin.Def.Career_Name[nCareer]);
	local tbAuthority = Kin.Def.Career_Authority[nCareer];
	if nCareer==Kin.Def.Career_ViceMaster then
		tbAuthority = Lib:CopyTB(tbAuthority)
		tbAuthority[Kin.Def.Authority_KickOut] = true
		tbAuthority[Kin.Def.Authority_Building] = true
	end
	if tbAuthority and next(tbAuthority) then
		szMailContent = szMailContent .. "擁有許可權：";
		local szDot = "";
		for nAuthority, _ in pairs(tbAuthority) do
			if Kin.Def.CareerAuthorityName[nAuthority] then
				szMailContent = string.format("%s%s%s", szMailContent, szDot, Kin.Def.CareerAuthorityName[nAuthority] or "");
				szDot = "，"
			end
		end
	end

	if nCareer==Kin.Def.Career_Mascot then
		szMailContent = string.format("%s擁有特權：可在幫派頻道發送30秒語音資訊，幫派吉祥物專屬頭像框", szMailContent)
	end

	local tbMail = {
		To = self.nMemberId;
		Title = "幫派職位任命";
		From = "幫派總管";
		Text = szMailContent;
	};

	Mail:SendSystemMail(tbMail);
end

function _KinMember:SetKinTitle(szKinTitle)
	if self.szKinTitle == szKinTitle then
		return;
	end

	self.szKinTitle = szKinTitle;
	self:Save();

	local szKinTitle = self:GetFullTitle();
	Kin:SyncTitle(self.nMemberId, szKinTitle);
	local kinData = Kin:GetKinById(self.nKinId);
	kinData:SetCacheFlag("UpdateMemberInfoList", true);
end

function _KinMember:CheckResetTitle()
	local tbKinData = Kin:GetKinById(self.nKinId)
	if not tbKinData then
		return false
	end

	local nCareer = self.nCareer
	if Kin:IsCareerTitleForbidden(nCareer, self.szKinTitle or "") then
		self.szKinTitle = Kin.Def.Career_Name[nCareer]
		self:Save()
	end
	return true
end

function _KinMember:GetFullTitle()
	local kinData = Kin:GetKinById(self.nKinId);

	local szKinTitle = "";
	if self.nMemberId==kinData.nLeaderId then
		szKinTitle = kinData.szLeaderTitle or Kin.Def.Career_Name[Kin.Def.Career_Leader]
	elseif self.nCareer >= Kin.Def.Career_Elite then
		szKinTitle = kinData.tbKinTitle[self.nCareer] or Kin.Def.Career_Name[self.nCareer];
	else
		szKinTitle = self.szKinTitle or Kin.Def.Career_Name[self.nCareer];
	end

	return string.format(Kin.Def.szFullTitleFormat, kinData.szName, szKinTitle);
end

function _KinMember:ChatForbid(bIsCancel)
	local nTime = GetTime();
	if bIsCancel then
		nTime = nil;
	else
		nTime = nTime + Kin.Def.nChatForbidTime;
	end

	self.nForbidTime = nTime;
	local kinData = Kin:GetKinById(self.nKinId);
	kinData:SetCacheFlag("UpdateMemberInfoList", true);
	self:Save();
end

function _KinMember:Quite()
	local player = KPlayer.GetPlayerObjById(self.nMemberId);
	if player then
		player.dwKinId = 0;
		player.CallClientScript("Kin:OnQuite");
		Kin:SyncTitle(self.nMemberId, "");

		if Kin:IsLoadedKinMap(player.nMapId) then
			player.GotoEntryPoint();
		end

		player.SetOrgCamp(Npc.CampTypeDef.camp_type_player);
	end

	local kinData = Kin:GetKinById(self.nKinId);

	local tbContribInfo = kinData:GetContributionInfo(self.nMemberId);
	if tbContribInfo then
		tbContribInfo.nDeleteTime = GetTime() + Kin.Def.nContribDelayDeleteTime;
		kinData:SetContributionInfo(self.nMemberId, tbContribInfo);
	end

	-- 玩家退出家族后，扣除当天通过该玩家使家族获得的建设资金
	local nCurDayFound = self:GetCurDayFound();
	kinData:CostFound(math.min(kinData:GetFound(), nCurDayFound));

	local nWeekActive = self:GetWeekActive()
	if nWeekActive>0 then
		kinData:AddWeekActive(-nWeekActive)
		self:ResetWeekActive()
	end

	self.nKinId = 0;
	self:Save();
	if player then
		player.OnEvent("OnLeaveKin")
	end
end

function _KinMember:IsRetire()
	return self.nCareer == Kin.Def.Career_Retire;
end

function _KinMember:GetMemberGiftBoxData(player)
	if not player then
		return;
	end

	local nNow = GetTime();
	local nToday = Lib:GetLocalDay(nNow - Kin.Def.nGiftBagRefreshTime);

	local tbGiftBagData = {
		nCurDay      = player.GetUserValue(Kin.Def.MEMBER_GIFT_KEY_GROUP, Kin.Def.MEMBER_GIFT_KEY_CUR_DAY);
		nNextBuyTime = player.GetUserValue(Kin.Def.MEMBER_GIFT_KEY_GROUP, Kin.Def.MEMBER_GIFT_KEY_NEXT_BUY_TIME);
		nLeftCount   = player.GetUserValue(Kin.Def.MEMBER_GIFT_KEY_GROUP, Kin.Def.MEMBER_GIFT_KEY_LEFT_COUNT);
	};

	if tbGiftBagData.nCurDay ~= nToday then
		tbGiftBagData.nCurDay      = nToday;
		tbGiftBagData.nNextBuyTime = nNow;
		tbGiftBagData.nLeftCount   = Kin:GetGiftMaxCount(player.GetVipLevel());
		self:SaveMemberGiftBoxData(player, tbGiftBagData);
	end
	return tbGiftBagData;
end

function _KinMember:SaveMemberGiftBoxData(player, tbGiftBagData)
	player.SetUserValue(Kin.Def.MEMBER_GIFT_KEY_GROUP, Kin.Def.MEMBER_GIFT_KEY_CUR_DAY, tbGiftBagData.nCurDay);
	player.SetUserValue(Kin.Def.MEMBER_GIFT_KEY_GROUP, Kin.Def.MEMBER_GIFT_KEY_NEXT_BUY_TIME, tbGiftBagData.nNextBuyTime);
	player.SetUserValue(Kin.Def.MEMBER_GIFT_KEY_GROUP, Kin.Def.MEMBER_GIFT_KEY_LEFT_COUNT, tbGiftBagData.nLeftCount);
end

function _KinMember:CostMemberGiftBoxTime(player)
	if not player then
		return;
	end

	local nNow = GetTime();
	local tbData = self:GetMemberGiftBoxData(player);
	if nNow < tbData.nNextBuyTime or tbData.nLeftCount <= 0 then
		return false;
	end

	tbData.nLeftCount = tbData.nLeftCount - 1;
	if tbData.nLeftCount > 0 then
		tbData.nNextBuyTime = nNow + Kin.Def.nGiftBoxCdTime;
	else
		tbData.nNextBuyTime = 0;
	end

	self:SaveMemberGiftBoxData(player, tbData);
	return true;
end

function _KinMember:GetQuizData()
	local tbMemberCache = self:GetMemberCacheData();
	local nToday = Lib:GetLocalDay();
	if not tbMemberCache.tbQuiz or tbMemberCache.tbQuiz.nCurDay ~= nToday then
		tbMemberCache.tbQuiz = {
			nCurDay = nToday;
			tbAnswered = {};
			nRightCount = 0;
		};
	end

	return tbMemberCache.tbQuiz;
end

-- 记录当日家族资金贡献值
function _KinMember:RecordKinFound(nFound)
	local nToday = Lib:GetLocalDay();
	if not self.tbFoundRecord then
		self.tbFoundRecord = {
			nCurDay = nToday;
			nFound = 0;
		};
	end

	if nToday ~= self.tbFoundRecord.nCurDay then
		self.tbFoundRecord.nCurDay = nToday;
		self.tbFoundRecord.nFound = nFound;
	else
		self.tbFoundRecord.nFound = self.tbFoundRecord.nFound + nFound;
	end

	self:Save();
end

function _KinMember:GetCurDayFound()
	local nToday = Lib:GetLocalDay();
	if not self.tbFoundRecord or self.tbFoundRecord.nCurDay ~= nToday then
		return 0;
	else
		return self.tbFoundRecord.nFound;
	end
end

function _KinMember:Save()
	Kin.tbMemberDataSaveMap[self.nMemberId] = true;
end

function _KinMember:GetName()
	local tbRoleStayInfo = KPlayer.GetRoleStayInfo(self.nMemberId);
	return tbRoleStayInfo.szName;
end

function _KinMember:GetRewardAdditionRate()
	return Kin.Def.CareerRewardAdditionRate[self.nCareer] or 0;
end

function _KinMember:ResetWeekActive()
	-- 腾讯版本特别奖励，周活跃满时发福袋
	if version_tx and self.nWeekActive == 700 then
		Sdk:SendTXLuckyBagMailByPlayerId(self.nMemberId, "WeekActive700");
	end

	self.nWeekActive = 0
	self:SetTodayActive(0)
	self:Save()
end

function _KinMember:GetActivityAvg()
	local nWeekActive = self:GetWeekActive()
	local nJoinDays = Kin:GetActivityWeekDay(self.nJoinTime)
	return math.floor(nWeekActive/nJoinDays)
end

function _KinMember:GetWeekActive()
	return self.nWeekActive or 0
end

function _KinMember:SetTodayActive(nActive)
	self.nTodayActive = math.max(math.min(nActive, 100), 0)
	Kin:UpdateKinMemberInfo(self.nKinId)
	self:Save()
end

function _KinMember:DailyUpdateActive()
	self.nWeekActive = self:GetWeekActive()+(self.nTodayActive or 0)
	self:SetTodayActive(0)
	self:Save()
end
