
local tbOrgQuizs = {
	[1]  = "以下誰是幫派的堂主？",
	[2]  = "以下誰是幫派的副堂主？",
	[3]  = "以下誰是幫派的會長？",
	[4]  = "以下誰的等級最高？",
	[5]  = "幫派裡誰的戰力最高？",
	[6]  = "幫派裡誰的累計貢獻最高？",
	[7]  = "以下成員誰的頭銜是：",
	[8]  = "幫派目前有多少正式成員？",
	[9]  = "幫派目前有多少小弟？",
	[10] = "幫派目前多少級？",
	[11] = "幫派目前什麼門派人最多？",

	[12] = "昨天幫派烤火活動誰中獎了？", -- 可能无效
	[13] = "昨天傍晚的武林盟主活動本幫派排名多少？", -- 可能无效
	[14] = "中午的武林盟主活動幫派排名多少？", -- 可能无效
	[15] = "幫派的%s現在多少級？",
	[16] = "最晚加入幫派的是誰？",

	[17] = "幫派裡誰的武神殿排名最高？", -- 未做
	[18] = "最近的一次門派競技幫派裡誰的排名最高?", -- 未做
	[19] = "幫派裡誰今天獲得了戰場第1名?", -- 可能无效
	[20] = "幫派裡誰今天在英雄挑戰第10輪獲勝?", -- 可能无效

	[21] = "昨天幫派運鏢的鏢車是什麼顏色?", -- 可能无效
	[22] = "幫派裡誰最近登上了通天塔7層?", -- 可能无效
};

local tbRandomName = {
	"余文博", "趙昊焱",
	"慕浩軒", "巫語堂",
	"元聰健", "鄧問旋",
	"孫白易", "蕭問筠",
	"喬聽白", "李半雪",
	"單山柳", "卜穀雪",
	"葉靖易", "姚代滔",
	"燕冷之", "尤盼秋",
	"周秋寒", "顧慕瑞",
	"左海亦", "杭初騰",
	"仲盼旋", "汪幼旋",
	"龐爾藍", "嚴沛山",
	"馮代遊", "秋覓松",
	"諸夜白", "宋冷安",
	"包靈竹", "王醉微",
	"曹幼南", "尹凡墨",

	"如若回到當初", "姬茹嫣",
	"上官櫻姬", "尚善若水",
	"踏盡紅塵", "聽風吻雨",
	"褻玉偷香", "往年風動",
	"名字長才霸氣", "果子醬",
	"果果", "龍嘯九天",
	"玉無言", "傑少",
	"敵敵威", "文聖先生",
	"西門大官", "西門大人",
	"陳家小太子", "陳家小公主",
	"陳家小公舉", "東方勝",
	"君臨天下", "附近的人",
	"龍嘯天", "龍傲天",
}

assert(#tbRandomName > 5);

tbRandomName = Lib:RandomArray(tbRandomName);

local function ValueInTable(value, tb)
	for _,v in pairs(tb) do
		if value == v then
			return true;
		end
	end
	return false;
end


local nNameIndex = 0;
local function GetRandomName(tbNames)
	local szName = "";
	repeat
		if nNameIndex >= #tbRandomName then
			nNameIndex = 0;
		end

		nNameIndex = nNameIndex + 1;
		szName = tbRandomName[nNameIndex];
	until not ValueInTable(szName, tbNames)

	return szName;
end

local function RandAnswer(tbOption, nAnswerIndex)
	assert(nAnswerIndex <= #tbOption);
	local answer = tbOption[nAnswerIndex];
	local nCount = #tbOption
	local temp = nil;
	for i = 1, nCount do
		local n = MathRandom(nCount);
		temp = tbOption[i];
		tbOption[i] = tbOption[n];
		tbOption[n] = temp;
	end

	for nIdx, option in ipairs(tbOption) do
		if option == answer then
			nAnswerIndex = nIdx;
			break;
		end
	end

	return tbOption, nAnswerIndex;
end

local function PackgeQuizData(szQuiz, tbOptions, nAnswerIndex)
	if not next(tbOptions) then
		return;
	end

	local tbQuiz = {};
	tbQuiz.szQuiz = szQuiz;
	tbQuiz.tbOption, tbQuiz.nAnswer = RandAnswer(tbOptions, nAnswerIndex);
	return tbQuiz;
end

local function FillUpKinRandomName(kinData, tbOptions, fnCheck)
	local tbMembers = {};
	kinData:TraverseMembers(function (memberData)
		table.insert(tbMembers, memberData);
		return true;
	end);

	tbMembers = Lib:RandomArray(tbMembers);
	for _, memberData in ipairs(tbMembers) do
		if #tbOptions >= 4 then
			break;
		end

		local szName = memberData:GetName();
		if not ValueInTable(szName, tbOptions) then
			if not fnCheck or fnCheck(memberData) then
				table.insert(tbOptions, szName);
			end
		end
	end

	return tbOptions;
end

--[[
tbQuiz = {
	szQuiz = "以下谁是家族的族长？";
	nAnswer = 1;
	tbOption = {
		[1] = "aaa";
		[2] = "bbb";
		[3] = "cc";
		[4] = "d";
	}
}

]]

local tbKinQuizCreator = {
	[1] = function (kinData) --以下谁是家族的族长？
		local nQuizIdx = 1;
		local nRightAnswer = 1;
		local master = KPlayer.GetRoleStayInfo(kinData.nMasterId);
		local tbNames = {master.szName};
		tbNames = FillUpKinRandomName(kinData, tbNames);

		while #tbNames < 4 do
			table.insert(tbNames, GetRandomName(tbNames));
		end

		return PackgeQuizData(tbOrgQuizs[nQuizIdx], tbNames, nRightAnswer);
	end;

	[2] = function (kinData)-- 以下谁是家族的副族长？
		local nQuizIdx = 2;
		local tbNames = {"無"};
		local nRightAnswer = 1;

		kinData:TraverseMembers(function (memberData)
			if memberData.nCareer == Kin.Def.Career_ViceMaster then
				table.insert(tbNames, memberData:GetName());
				nRightAnswer = 2;
				return false;
			end
			return true;
		end);

		tbNames = FillUpKinRandomName(kinData, tbNames, function (memberData)
			return memberData.nCareer ~= Kin.Def.Career_ViceMaster;
		end);

		while #tbNames < 4 do
			table.insert(tbNames, GetRandomName(tbNames));
		end

		return PackgeQuizData(tbOrgQuizs[nQuizIdx], tbNames, nRightAnswer);
	end;

	[3] = function (kinData)-- 以下谁是家族的长老？
		local nQuizIdx = 3;
		local tbNames = {"無"};
		local nRightAnswer = 1;

		kinData:TraverseMembers(function (memberData)
			if memberData.nCareer == Kin.Def.Career_Elder then
				table.insert(tbNames, memberData:GetName());
				nRightAnswer = 2;
				return false;
			end
			return true;
		end);

		tbNames = FillUpKinRandomName(kinData, tbNames, function (memberData)
			return memberData.nCareer ~= Kin.Def.Career_Elder;
		end);

		while #tbNames < 4 do
			table.insert(tbNames, GetRandomName(tbNames));
		end

		return PackgeQuizData(tbOrgQuizs[nQuizIdx], tbNames, nRightAnswer);
	end;

	[4] = function (kinData)-- 家族里谁的等级最高？
		local nQuizIdx = 4;
		local tbNames = {};
		local nRightAnswer = 1;

		local nMaxLevel = 0;
		local szMaxLevelName = "";
		kinData:TraverseMembers(function (memberData)
			local tbRoleStayInfo = KPlayer.GetRoleStayInfo(memberData.nMemberId);
			if tbRoleStayInfo.nLevel > nMaxLevel then
				szMaxLevelName = memberData:GetName();
				nMaxLevel = tbRoleStayInfo.nLevel;
			end
			return true;
		end);

		table.insert(tbNames, szMaxLevelName);

		tbNames = FillUpKinRandomName(kinData, tbNames, function (memberData)
			local tbRoleStayInfo = KPlayer.GetRoleStayInfo(memberData.nMemberId);
			return tbRoleStayInfo.nLevel < nMaxLevel;
		end);

		while #tbNames < 4 do
			table.insert(tbNames, GetRandomName(tbNames));
		end

		return PackgeQuizData(tbOrgQuizs[nQuizIdx], tbNames, nRightAnswer);
	end;

	[5] = function (kinData)-- 家族里谁的战力最高？
		local nQuizIdx = 5;
		local tbNames = {};
		local nRightAnswer = 1;

		local nMaxPower = -1;
		local szMaxPowerName = "";
		kinData:TraverseMembers(function (memberData)
			local nPower = FightPower:GetFightPower(memberData.nMemberId);
			if nPower > nMaxPower then
				nMaxPower = nPower;
				szMaxPowerName = memberData:GetName();
			end
			return true;
		end);

		table.insert(tbNames, szMaxPowerName);

		tbNames = FillUpKinRandomName(kinData, tbNames, function (memberData)
			local nPower = FightPower:GetFightPower(memberData.nMemberId);
			return nPower < nMaxPower;
		end);

		while #tbNames < 4 do
			table.insert(tbNames, GetRandomName(tbNames));
		end

		return PackgeQuizData(tbOrgQuizs[nQuizIdx], tbNames, nRightAnswer);
	end;

	[6] = function (kinData) -- 家族里谁的个人贡献最高？
		local nQuizIdx = 6;
		local tbNames = {};
		local nRightAnswer = 1;

		local nMaxContribution = -1;
		local szMaxConName = "";
		kinData:TraverseMembers(function (memberData)
			local nContrib = memberData:GetContribution();
			if nContrib > nMaxContribution then
				nMaxContribution = nContrib;
				szMaxConName = memberData:GetName();
			end
			return true;
		end);

		table.insert(tbNames, szMaxConName);

		tbNames = FillUpKinRandomName(kinData, tbNames, function (memberData)
			local nContrib = memberData:GetContribution();
			return nContrib < nMaxContribution;
		end);

		while #tbNames < 4 do
			table.insert(tbNames, GetRandomName(tbNames));
		end

		return PackgeQuizData(tbOrgQuizs[nQuizIdx], tbNames, nRightAnswer);
	end;

	[7] = function (kinData) -- "以下成员谁的头衔是:",
		local nQuizIdx = 7;
		local nRightAnswer = 1;
		local tbTitle = {};
		local tbMapFlag = {};
		kinData:TraverseMembers(function (memberData)
			local tbRoleStayInfo = KPlayer.GetRoleStayInfo(memberData.nMemberId);
			if not tbMapFlag[tbRoleStayInfo.nHonorLevel] then
				table.insert(tbTitle, tbRoleStayInfo.nHonorLevel);
				tbMapFlag[tbRoleStayInfo.nHonorLevel] = true;
			end
			return true;
		end);

		table.sort(tbTitle, function (a, b)
			return a > b;
		end);

		local nSelectHonor = tbTitle[1];
		if #tbTitle > 1 and MathRandom(2) == 2 then
			nSelectHonor = tbTitle[2];
		end

		local tbOptions = {};
		kinData:TraverseMembers(function (memberData)
			local tbRoleStayInfo = KPlayer.GetRoleStayInfo(memberData.nMemberId);
			if tbRoleStayInfo.nHonorLevel == nSelectHonor then
				table.insert(tbOptions, tbRoleStayInfo.szName);
				return false;
			end
			return true;
		end);

		tbOptions = FillUpKinRandomName(kinData, tbOptions, function (memberData)
			local tbRoleStayInfo = KPlayer.GetRoleStayInfo(memberData.nMemberId);
			return tbRoleStayInfo.nHonorLevel ~= nSelectHonor;
		end);

		while #tbOptions < 4 do
			table.insert(tbOptions, GetRandomName(tbOptions));
		end

		local tbHonorInfo = Player.tbHonorLevelSetting[nSelectHonor] or {Name = "無頭銜"};
		return PackgeQuizData(tbOrgQuizs[nQuizIdx] .. tbHonorInfo.Name, tbOptions, nRightAnswer);
	end;

	[8] = function (kinData) -- 家族目前有多少正式成员？
		local nQuizIdx = 8;
		local nRightAnswer = 1;
		local tbOptions = {};
		local nNormalMemberCount = kinData:GetMemberCount();
		table.insert(tbOptions, nNormalMemberCount);

		local tbArray = {}
		for i = nNormalMemberCount - 5, nNormalMemberCount + 5 do
			if i ~= nNormalMemberCount and i > 1 then
				table.insert(tbArray, i);
			end
		end

		assert(#tbArray >= 3, "規則有問題");
		local nOptionCount = 1;
		while nOptionCount < 4 do
			local nSelect = MathRandom(#tbArray);
			table.insert(tbOptions, tbArray[nSelect]);
			table.remove(tbArray, nSelect);
			nOptionCount = nOptionCount + 1;
		end

		return PackgeQuizData(tbOrgQuizs[nQuizIdx], tbOptions, nRightAnswer);
	end;

	[9] = function (kinData) -- 家族目前有多少见习成员？
		local nQuizIdx = 9;
		local nRightAnswer = 1;
		local tbOptions = {};
		local nNormalMemberCount = kinData:GetNewerCount();
		table.insert(tbOptions, nNormalMemberCount);

		local tbArray = {}
		for i = nNormalMemberCount - 3, nNormalMemberCount + 3 do
			if i ~= nNormalMemberCount and i <= 40 and i >= 0 then
				table.insert(tbArray, i);
			end
		end

		assert(#tbArray >= 3, "規則有問題");
		local nOptionCount = 1;
		while nOptionCount < 4 do
			local nSelect = MathRandom(#tbArray);
			table.insert(tbOptions, tbArray[nSelect]);
			table.remove(tbArray, nSelect);
			nOptionCount = nOptionCount + 1;
		end

		return PackgeQuizData(tbOrgQuizs[nQuizIdx], tbOptions, nRightAnswer);
	end;

	[10] = function (kinData) -- 家族目前多少级？
		local nQuizIdx = 10;
		local nRightAnswer = 1;
		local tbOptions = {};
		local nLevel = kinData:GetLevel();
		table.insert(tbOptions, nLevel);

		local tbArray = {}
		for i = nLevel - 10, nLevel + 10 do
			if i ~= nLevel and i > 0 then
				table.insert(tbArray, i);
			end
		end

		local nOptionCount = 1;
		while nOptionCount < 4 do
			local nSelect = MathRandom(#tbArray);
			table.insert(tbOptions, tbArray[nSelect]);
			table.remove(tbArray, nSelect);
			nOptionCount = nOptionCount + 1;
		end

		return PackgeQuizData(tbOrgQuizs[nQuizIdx], tbOptions, nRightAnswer);
	end;

	[11] = function (kinData) -- 家族目前什么门派人最多？
		local nQuizIdx = 11;
		local nRightAnswer = 1;
		local tbFactions = {};
		for i = 1, Faction.MAX_FACTION_COUNT do
			tbFactions[i] = 0;
		end

		kinData:TraverseMembers(function (memberData)
			local tbRoleStayInfo = KPlayer.GetRoleStayInfo(memberData.nMemberId);
			tbFactions[tbRoleStayInfo.nFaction] = tbFactions[tbRoleStayInfo.nFaction] + 1;
			return true;
		end);

		local nMaxFaction = 1;
		local nMaxCount = 0;
		for nFaction, nCount in pairs(tbFactions) do
			if nCount > nMaxCount then
				nMaxFaction = nFaction;
				nMaxCount = nCount;
			end
		end

		local tbOptions = {};
		table.insert(tbOptions, Faction:GetName(nMaxFaction));

		for nFaction = 1, Faction.MAX_FACTION_COUNT do
			if #tbOptions >= 4 then
				break;
			end

			if nFaction ~= nMaxFaction then
				table.insert(tbOptions, Faction:GetName(nFaction));
			end
		end

		return PackgeQuizData(tbOrgQuizs[nQuizIdx], tbOptions, nRightAnswer);
	end;

	[12] = function (kinData) -- "昨天家族烤火活动谁中奖了？",
		local gatherWinNames = kinData:GetGatherWinNames() or {};
		if not next(gatherWinNames) then
			return;
		end

		local nQuizIdx = 12;
		local nRightAnswer = 1;
		local tbOptions = {};

		table.insert(tbOptions, gatherWinNames[MathRandom(#gatherWinNames)]);

		tbOptions = FillUpKinRandomName(kinData, tbOptions, function (memberData)
			local szName = memberData:GetName();
			return not ValueInTable(szName, gatherWinNames);
		end);

		while #tbOptions < 4 do
			table.insert(tbOptions, GetRandomName(tbOptions));
		end

		return PackgeQuizData(tbOrgQuizs[nQuizIdx], tbOptions, nRightAnswer);
	end;

	[13] = function (kinData) -- "昨天傍晚的武林盟主活动本家族排名多少？",
		local nQuizIdx = 13;
		local nRightAnswer = 1;
		local tbOptions = {};

		local nRank = kinData:GetCacheFlag("BossRank2");
		if not nRank then
			return;
		end

		local fnSelect = Lib:GetRandomSelect(12);
		table.insert(tbOptions, nRank);

		while #tbOptions < 4 do
			local nRandRank = fnSelect() - 6 + nRank;
			if nRandRank ~= nRank and nRandRank > 0 then
				table.insert(tbOptions, nRandRank);
			end
		end

		return PackgeQuizData(tbOrgQuizs[nQuizIdx], tbOptions, nRightAnswer);
	end;

	[14] = function (kinData) -- "中午的武林盟主活动家族排名多少？",
		local nQuizIdx = 14;
		local nRightAnswer = 1;
		local tbOptions = {};

		local nRank = kinData:GetCacheFlag("BossRank1");
		if not nRank then
			return;
		end

		local fnSelect = Lib:GetRandomSelect(12);
		table.insert(tbOptions, nRank);

		while #tbOptions < 4 do
			local nRandRank = fnSelect() - 6 + nRank;
			if nRandRank ~= nRank and nRandRank > 0 then
				table.insert(tbOptions, nRandRank);
			end
		end

		return PackgeQuizData(tbOrgQuizs[nQuizIdx], tbOptions, nRightAnswer);
	end;

	[15] = function (kinData) -- "家族的%s现在多少级？",
		local nQuizIdx = 15;
		local nRightAnswer = 1;
		local tbOptions = {};

		local tbKinBuildings = {
			Kin.Def.Building_Main,
			Kin.Def.Building_War,
			Kin.Def.Building_DrugStore,
			Kin.Def.Building_WeaponStore,
			Kin.Def.Building_Treasure,
			Kin.Def.Building_FangJuHouse,
			Kin.Def.Building_ShouShiHouse,
		};

		local nBuildingId = tbKinBuildings[MathRandom(#tbKinBuildings)];
		local szQuiz = string.format(tbOrgQuizs[nQuizIdx], Kin.Def.BuildingName[nBuildingId]);
		local nBuildingLevel = kinData:GetBuildingLevel(nBuildingId);
		local fnSelect = Lib:GetRandomSelect(Kin.Def.nMaxBuildingLevel);

		table.insert(tbOptions, nBuildingLevel);
		while #tbOptions < 4 do
			local nLevel = fnSelect();
			if nLevel ~= nBuildingLevel then
				table.insert(tbOptions, nLevel);
			end
		end

		return PackgeQuizData(szQuiz, tbOptions, nRightAnswer);
	end;

	[16] = function (kinData) -- "最晚加入家族的是谁？",
		local nQuizIdx = 16;
		local nRightAnswer = 1;
		local tbOptions = {};

		local nMaxJoinTime = 0;
		local szLatestMemberName = "";
		kinData:TraverseMembers(function (memberData)
			local nJoinTime = memberData:GetJoinTime();
			if nJoinTime > nMaxJoinTime then
				nMaxJoinTime = nJoinTime;
				szLatestMemberName = memberData:GetName();
			end
			return true;
		end);

		table.insert(tbOptions, szLatestMemberName);
		tbOptions = FillUpKinRandomName(kinData, tbOptions);

		while #tbOptions < 4 do
			table.insert(tbOptions, GetRandomName(tbOptions));
		end

		return PackgeQuizData(tbOrgQuizs[nQuizIdx], tbOptions, nRightAnswer);
	end;

	[17] = function (kinData) -- "家族里谁的武神殿排名最高？",
		local nQuizIdx = 17;
		local nRightAnswer = 1;
		local tbOptions = {};

		-- todo

		return PackgeQuizData(tbOrgQuizs[nQuizIdx], tbOptions, nRightAnswer);
	end;

	[18] = function (kinData) -- "最近的一次门派竞技家族里谁的排名最高?",
		local nQuizIdx = 18;
		local nRightAnswer = 1;
		local tbOptions = {};
		-- todo
		return PackgeQuizData(tbOrgQuizs[nQuizIdx], tbOptions, nRightAnswer);
	end;

	[19] = function (kinData) -- "家族里谁今天获得了战场第1名?",
		local nQuizIdx = 19;
		local nRightAnswer = 1;
		local tbOptions = {};

		local tbWinBattleNames = kinData:GetBattleKingNames() or {};
		if not next(tbWinBattleNames) then
			return;
		end

		table.insert(tbOptions, tbWinBattleNames[MathRandom(#tbWinBattleNames)]);

		tbOptions = FillUpKinRandomName(kinData, tbOptions, function (memberData)
			local szName = memberData:GetName();
			return not ValueInTable(szName, tbWinBattleNames);
		end);

		while #tbOptions < 4 do
			table.insert(tbOptions, GetRandomName(tbOptions));
		end

		return PackgeQuizData(tbOrgQuizs[nQuizIdx], tbOptions, nRightAnswer);
	end;

	[20] = function (kinData) -- "家族里谁今天在英雄挑战第10轮获胜?",
		local nQuizIdx = 20;
		local nRightAnswer = 1;
		local tbOptions = {};

		local tbWin10Names = kinData:GetHeroChallengeWin10Names();
		if not next(tbWin10Names) then
			return;
		end

		table.insert(tbOptions, tbWin10Names[MathRandom(#tbWin10Names)]);

		tbOptions = FillUpKinRandomName(kinData, tbOptions, function (memberData)
			local szName = memberData:GetName();
			return not ValueInTable(szName, tbWin10Names);
		end);

		while #tbOptions < 4 do
			table.insert(tbOptions, GetRandomName(tbOptions));
		end
		return PackgeQuizData(tbOrgQuizs[nQuizIdx], tbOptions, nRightAnswer);
	end;


	[21] = function (kinData) --"昨天家族运镖的镖车是什么颜色?",
		local nQuizIdx = 21;
		local nRightAnswer = 1;
		local tbOptions = {};
		local szEscortColor = kinData:GetYesterdayKinEscortColor();
		if not szEscortColor then
			return;
		end
		table.insert(tbOptions, szEscortColor);
		for _, szColor in pairs(KinEscort.tbNpcColor) do
			if #tbOptions >= 4 then
				break;
			end

			if szColor ~= szEscortColor then
				table.insert(tbOptions, szColor);
			end
		end
		assert(#tbOptions == 4);
		return PackgeQuizData(tbOrgQuizs[nQuizIdx], tbOptions, nRightAnswer);
	end;

	[22] = function (kinData) --"家族里谁最近登上了通天塔7层?",
		local nQuizIdx = 22;
		local nRightAnswer = 1;
		local tbOptions = {};
		local szLatestName = kinData:GetLatestTower7PlayerName();
		if not szLatestName then
			return;
		end

		table.insert(tbOptions, szLatestName);
		tbOptions = FillUpKinRandomName(kinData, tbOptions);

		while #tbOptions < 4 do
			table.insert(tbOptions, GetRandomName(tbOptions));
		end
		return PackgeQuizData(tbOrgQuizs[nQuizIdx], tbOptions, nRightAnswer);
	end;
}

function Kin:GetGatherQuizByIndex(tbIndexes, nIndex, kinData)
	local tbQuiz = tbKinQuizCreator[tbIndexes[nIndex]](kinData);

	-- 若选取的题目不可用, 则从未选的题中再选题, 直到题目可用为止
	local fnSelect = not tbQuiz and Lib:GetRandomSelect(#tbKinQuizCreator);
	local nMaxTryTime = #tbKinQuizCreator;
	while not tbQuiz do
		local nQuizIdx = fnSelect();
		nMaxTryTime = nMaxTryTime - 1;
		if nMaxTryTime < 0 then
			Log(debug.traceback())
			return;
		end

		while ValueInTable(nQuizIdx, tbIndexes) do
			nQuizIdx = fnSelect();
			nMaxTryTime = nMaxTryTime - 1;
			if nMaxTryTime < 0 then
				Log(debug.traceback())
				return;
			end
		end
		tbIndexes[nIndex] = nQuizIdx;

		tbQuiz = tbKinQuizCreator[nQuizIdx](kinData);
	end
	return tbQuiz;
end

function Kin:GetGatherQuizIndex()
	local fnSelect = Lib:GetRandomSelect(#tbKinQuizCreator);
	local tbIndexes = {};
	for i = 1, Kin.GatherDef.QuizCount do
		table.insert(tbIndexes, fnSelect());
	end
	return tbIndexes;
end
