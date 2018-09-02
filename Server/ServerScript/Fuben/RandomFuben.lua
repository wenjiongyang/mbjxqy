Fuben.RandomFuben = Fuben.RandomFuben or {};
local RandomFuben = Fuben.RandomFuben;

function RandomFuben:LoadSetting()
	local tbFile = LoadTabFile("Setting/Fuben/RandomFuben/RoomSetting.tab", "sddd", nil, {"Room", "RoomLevel", "Rate", "MapId"});
	assert(tbFile, "[RandomFuben] LoadSetting LoadTabFile Setting/Fuben/RandomFuben/RoomSetting.tab fail !!!");

	self.tbRandomFubenSetting = {};
	self.tbRateInfo = {};
	for _, tbRow in pairs(tbFile) do
		self.tbRateInfo[tbRow.MapId] = tbRow.Rate;
		self.tbRandomFubenSetting[tbRow.RoomLevel] = self.tbRandomFubenSetting[tbRow.RoomLevel] or {nTotalRate = 0, tbRoom = {}};

		local tbSetting = self.tbRandomFubenSetting[tbRow.RoomLevel];
		tbSetting.nTotalRate = tbSetting.nTotalRate + tbRow.Rate;
		table.insert(tbSetting.tbRoom, {nRate = tbRow.Rate, nMapId = tbRow.MapId});

		local tbFubenSetting = self.tbRoomSetting[tbRow.Room];
		if tbFubenSetting and tbRow.MapId > 0 then
			Fuben:SetFubenSetting(tbRow.MapId, tbFubenSetting);

			local tbTemplate = Fuben:RegisterFuben(tbRow.MapId, "RandomFubenBase", tbFubenSetting.szPathFile, tbFubenSetting.szNpcPointFile);
			tbTemplate.szRoom = tbRow.Room;
			tbTemplate.nRoomLevel = tbRow.RoomLevel;
			tbTemplate.nMapTemplateId = tbRow.MapId;
			tbTemplate.tbTimeScore = tbFubenSetting.tbTimeScore;
		else
			Log(string.format("[RandomFuben] LoadSetting ERR ?? room is unexist !! Room = %s, nMapId = %s", tbRow.Room, tbRow.MapId));
		end
	end


	for nFubenLevel, tbInfo in ipairs(self.tbSetting) do
		TeamMgr:RegisterActivity("RandomFuben", "RandomFuben_" .. nFubenLevel, tbInfo.szName,
			{"Fuben.RandomFuben:QTCanShow", nFubenLevel},
			{"Fuben.RandomFuben:QTCanJoin", nFubenLevel},
			{"Fuben.RandomFuben:QTCheckEnter", nFubenLevel},
			{"Fuben.RandomFuben:QTEnterFuben", nFubenLevel},
			RandomFuben.MIN_PLAYER_COUNT);
	end
end

function RandomFuben:GetRandomFubenSetting(szRoom)
	self.tbRoomSetting = self.tbRoomSetting or {};
	self.tbRoomSetting[szRoom] = self.tbRoomSetting[szRoom] or {};

	local tbSetting = self.tbRoomSetting[szRoom];
	tbSetting.szNpcPointFile = string.format("Setting/Fuben/RandomFuben/%s/NpcPos.tab", szRoom);
	tbSetting.szPathFile = string.format("Setting/Fuben/RandomFuben/%s/NpcPath.tab", szRoom);
	return tbSetting;
end

function RandomFuben:GetRoom(nRoomLevel, nCurMapId)
	local tbLevelSetting = self.tbRandomFubenSetting[nRoomLevel];

	if not tbLevelSetting then
		tbLevelSetting = self.tbRandomFubenSetting[#self.tbRandomFubenSetting];
		Log("[RandomFuben] GetRoom ERR ?? unexist random fuben level ", nRoomLevel);
	end

	nCurMapId = nCurMapId or -1;
	local nNewTotalRate = tbLevelSetting.nTotalRate - (self.tbRateInfo[nCurMapId] or 0);

	local nRate = MathRandom(nNewTotalRate);
	for _, tbInfo in pairs(tbLevelSetting.tbRoom) do
		if tbInfo.nMapId ~= nCurMapId then
			if nRate > tbInfo.nRate then
				nRate = nRate - tbInfo.nRate;
			else
				return tbInfo.nMapId;
			end
		end
	end
end

local function fnAllMember(tbMember, fnSc, ...)
	for _, nPlayerId in pairs(tbMember or {}) do
		local pMember = KPlayer.GetPlayerObjById(nPlayerId);
		if pMember then
			fnSc(pMember, ...);
		end
	end
end

local function fnMsg(pPlayer, szMsg)
	pPlayer.CenterMsg(szMsg);
end

function RandomFuben:CreateFuben(nPlayerId, nFubenLevel)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return;
	end

	local bRet, szMsg, tbMember, nFubenMapTemplateId = self:CheckCanCreateFuben(pPlayer, nFubenLevel);
	if not bRet then
		fnAllMember(tbMember, fnMsg, szMsg);
		return;
	end

	local function fnSuccessCallback(nMapId)
		local function fnSucess(pPlayer, nMapId)
			pPlayer.SetEntryPoint();
			pPlayer.SwitchMap(nMapId, 0, 0);
			pPlayer.CallClientScript("Fuben.RandomFuben:SaveLevel", nFubenLevel);
			LogD(Env.LOGD_ActivityPlay, pPlayer.szAccount, pPlayer.dwID, pPlayer.nLevel, "RandomFuben", Env.LOGD_VAL_TAKE_TASK, Env.LOGD_MIS_RANDOM_FUBEN, pPlayer.GetFightPower());
		end
		fnAllMember(tbMember, fnSucess, nMapId);
		Activity:OnGlobalEvent("Act_OnJoinTeamActivity", tbMember, Env.LogWay_RandomFuben)
	end

	local function fnFailedCallback()
		fnAllMember(tbMember, fnMsg, "創建副本失敗，請稍後嘗試！");
	end

	local nFubenMapTemplateId = self:GetRoom(self.tbSetting[nFubenLevel].nMinRoomLevel);
	Fuben:ApplyFubenUseLevel(pPlayer.dwID, nFubenMapTemplateId, nFubenLevel, fnSuccessCallback, fnFailedCallback, 1, {}, {}, 0, 0, nFubenLevel);
	return true;
end

function RandomFuben:QTCanShow(nFubenLevel)
	return self:CanEnterFubenCommon(me, nFubenLevel);
end

function RandomFuben:QTCanJoin(nFubenLevel)
	return self:CheckPlayerCanEnterFuben(me, nFubenLevel);
end

function RandomFuben:QTCheckEnter(nFubenLevel)
	return self:CheckCanCreateFuben(me, nFubenLevel);
end

function RandomFuben:QTEnterFuben(nFubenLevel)
	return self:CreateFuben(me.dwID, nFubenLevel);
end
