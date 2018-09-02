
HousePlant.tbLandSet = HousePlant.tbLandSet or {};
HousePlant.tbLandBase = HousePlant.tbLandBase or {};

local tbLandBase = HousePlant.tbLandBase;
function tbLandBase:Init(dwOwnerId, nState, tbRecord, nRipenTime, nSickTime)
	self.dwOwnerId = dwOwnerId;
	self.nState = nState;
	self.tbRecord = tbRecord;
	self.nRipenTime = nRipenTime;
	self.nSickTime = nSickTime;

	self.nRipenTimerId = nil;
	self.nSickTimerId = nil;
	self:CheckRipen();
	self:CheckSick();

	self:SyncClientData();
end

function tbLandBase:Uninit()
	self:CloseRipenTimer();
	self:CloseSickTimer();

	self:RemoveClientData();
end

function tbLandBase:CheckRipen()
	if self.nState == HousePlant.STATE_NULL or self.nState == HousePlant.STATE_RIPEN then
		return;
	end

	local nTime = self.nRipenTime - GetTime();
	if nTime <= 0 then
		self:OnRipen();
		return;
	end

	assert(not self.nRipenTimerId, string.format("[ERROR][HousePlant] repeated ripen timer of player: %d", self.dwOwnerId));
	self.nRipenTimerId = Timer:Register(Env.GAME_FPS * nTime, self.OnRipen, self);
end

function tbLandBase:CheckSick()
	if self.nState ~= HousePlant.STATE_NORMAL then
		return;
	end

	local nTime = self.nSickTime - GetTime();
	if nTime <= 0 then
		self:OnSick();
		return;
	end

	assert(not self.nSickTimerId, string.format("[ERROR][HousePlant] repeated sick timer of player: %d", self.dwOwnerId));
	self.nSickTimerId = Timer:Register(Env.GAME_FPS * nTime, self.OnSick, self);
end

function tbLandBase:CanPlant(pPlayer)
	if pPlayer.dwID ~= self.dwOwnerId then
		return false, "只有房主才能種植哦"
	end

	if not House:IsInOwnHouse(pPlayer) then
		return false, "只能在自己家園種植哦";
	end

	if self.nState ~= HousePlant.STATE_NULL then
		return false, "只能種在空地上哦~";
	end

	if pPlayer.GetMoney("Gold") < HousePlant.PLANT_COST then
		return false, "元寶不足";
	end

	return true;
end

function tbLandBase:Plant()
	if self.nState ~= HousePlant.STATE_NULL then
		Log("[ERROR][HousePlant] failed to plant, the plant is already exist: ", self.dwOwnerId);
		return false;
	end

	self.nState = HousePlant.STATE_NORMAL;
	Log("[HousePlant] land plant successfully: ", self.dwOwnerId);

	self:ResetRipenTime();
	self:ResetSickTime();
	self:Save(true);

	self:SyncClientData();

	return true;
end

function tbLandBase:CanCrop(pPlayer)
	if pPlayer.dwID ~= self.dwOwnerId then
		return false, "只有房主才能收成哦"
	end

	if not House:IsInOwnHouse(pPlayer) then
		return false, "只能在自己家園收成哦";
	end

	if self.nState ~= HousePlant.STATE_RIPEN then
		return false, "還沒成熟呢，稍安勿躁~";
	end

	return true;
end

function tbLandBase:Crop()
	if self.nState ~= HousePlant.STATE_RIPEN then
		return false;
	end

	self.nState = HousePlant.STATE_NULL;
	self.tbRecord = {};
	self:Save(true);

	self:SyncClientData();

	Log("[HousePlant] land crop successfully: ", self.dwOwnerId);

	return true;
end

function tbLandBase:GetTodayCureTimes(dwPlayerId)
	local nMatchTimes = 0;
	local nCurDay = Lib:GetLocalDay(GetTime() - HousePlant.CURE_TIMES_REFRESH_TIME);
	for i = #self.tbRecord, 1, -1 do
		local tbRecord = self.tbRecord[i];
		local nCureDay = Lib:GetLocalDay(tbRecord.nCureTime - HousePlant.CURE_TIMES_REFRESH_TIME);
		assert(nCurDay >= nCureDay, string.format("[ERROR][HousePlant] failed to get cure times: %d", dwPlayerId));

		if nCureDay ~= nCurDay then
			break;
		end

		if tbRecord.dwPlayerId == dwPlayerId then
			nMatchTimes = nMatchTimes + 1;
		end
	end
	return nMatchTimes;
end

function tbLandBase:CanCure(pPlayer, nState)
	if pPlayer.nLevel < House.nMinOpenLevel then
		return false, string.format("等級不足%d級，無法養護", House.nMinOpenLevel);
	end

	local nMapId = House:GetHouseMap(self.dwOwnerId);
	if not nMapId or nMapId ~= pPlayer.nMapId then
		return false, "你沒有在家園中哦";
	end

	if not HousePlant.tbSickStateSetting[self.nState] then
		return false, "該植物目前不需要養護哦";
	end

	if self.nState ~= nState then
		return false, HousePlant.tbSickStateSetting[nState] and HousePlant.tbSickStateSetting[nState].szFailedMsg or "未知狀態-.-";
	end

	local dwPlayerId = pPlayer.dwID;
	local bIsHelpCure = dwPlayerId ~= self.dwOwnerId;
	if bIsHelpCure and not FriendShip:IsFriend(dwPlayerId, self.dwOwnerId) then
		return false, "你們還不是好友關係";
	end
	
	local szKey = bIsHelpCure and "PlantHelpCure" or "PlantCure";
	local nDegree = DegreeCtrl:GetDegree(pPlayer, szKey);
	if nDegree <= 0 then
		return false, bIsHelpCure and "養護次數不足哦，明天再來吧" or "你今天已經養護過該植物了";
	end

	if bIsHelpCure then
		local nTimes = self:GetTodayCureTimes(dwPlayerId);
		if nTimes > 0 then
			return false, "你今天已經幫他養護過了哦";
		end
	end

	return true;
end

function tbLandBase:DoCure(pPlayer, bCost)
	local dwPlayerId = pPlayer.dwID;
	local szKey = dwPlayerId == self.dwOwnerId and "PlantCure" or "PlantHelpCure";
	local bRet = DegreeCtrl:ReduceDegree(pPlayer, szKey, 1);
	if not bRet then
		return false;
	end

	local nReduceTime = bCost and HousePlant.CURE_TIME_COST or HousePlant.CURE_TIME_NORMAL;
	local bRet = self:Cure(dwPlayerId, nReduceTime, bCost);
	if not bRet then
		pPlayer.CenterMsg("未知錯誤！請聯繫客服");
		return false;
	end

	if dwPlayerId ~= self.dwOwnerId then
		FriendShip:AddImitity(dwPlayerId, self.dwOwnerId, bCost and HousePlant.CURE_INTIMACY_COST or HousePlant.CURE_INTIMACY, Env.LogWay_PlantCure);
	end

	if bCost then
		pPlayer.SendAward({{ "Contrib", HousePlant.CURE_COST_AWARD }}, nil, nil, Env.LogWay_PlantCure);
	end

	pPlayer.CenterMsg("養護成功！");
	pPlayer.CallClientScript("HousePlant:OnCureFinished");

	return true;
end

function tbLandBase:Cure(dwPlayerId, nReduceTime, bCost)
	if not HousePlant.tbSickStateSetting[self.nState] then
		return false;
	end

	table.insert(self.tbRecord, { dwPlayerId = dwPlayerId, bCost = bCost, nCureTime = GetTime(), nState = self.nState });

	self.nState = HousePlant.STATE_NORMAL;
	self:ResetRipenTime(self.nRipenTime - nReduceTime);
	self:ResetSickTime();
	self:Save(true);

	Log("[HousePlant] land cure successfully: ", self.dwOwnerId, "by player:", dwPlayerId, bCost and "gold" or "normal");

	self:SyncClientData();

	return true;
end

function tbLandBase:OnRipen()
	assert(self.nState ~= HousePlant.STATE_NULL and self.nState ~= HousePlant.STATE_RIPEN, string.format("[ERROR][HousePlant] illegal state of land: ", self.dwOwnerId, self.nState));

	self:CloseRipenTimer();
	self:CloseSickTimer();

	self.nState = HousePlant.STATE_RIPEN;
	self.nRipenTime = nil;
	self.nSickTime = nil;
	self:Save(true);

	Log("[HousePlant] land ripen successfully: ", self.dwOwnerId);

	self:SyncClientData();

	HousePlant:NotifyState(self.dwOwnerId);
end

function tbLandBase:OnSick()
	assert(self.nState == HousePlant.STATE_NORMAL, string.format("[ERROR][HousePlant] illegal state of land: ", self.dwOwnerId, self.nState));

	self:CloseSickTimer();

	local nSickCount = #HousePlant.tbSickStateSetting;
	self.nState = MathRandom(nSickCount);
	self.nSickTime = nil;
	self:Save(true);

	Log("[HousePlant] land sick: ", self.dwOwnerId, self.nState);

	self:SyncClientData();

	HousePlant:NotifyState(self.dwOwnerId);	
end

function tbLandBase:ResetRipenTime(nRipenTime)
	if not nRipenTime then
		nRipenTime = GetTime() + HousePlant.RIPEN_TIME;	
	end
	self.nRipenTime = nRipenTime;
	self:CloseRipenTimer();
	self:CheckRipen();
end

function tbLandBase:ResetSickTime(nSickTime)
	if not nSickTime then
		nSickTime = HousePlant:CalcuSickTime();
	end
	self.nSickTime = nSickTime;
	self:CloseSickTimer();
	self:CheckSick();
end

function tbLandBase:CloseRipenTimer()
	if self.nRipenTimerId then
		Timer:Close(self.nRipenTimerId);
		self.nRipenTimerId = nil;
	end
end

function tbLandBase:CloseSickTimer()
	if self.nSickTimerId then
		Timer:Close(self.nSickTimerId);
		self.nSickTimerId = nil;
	end
end

function tbLandBase:Save(bForce)
	local tbLand = House:GetLand(self.dwOwnerId);
	if not tbLand then
		Log("[WARNING][HousePlant] failed to save land, it's not exist: ", self.dwOwnerId);
		return;
	end

	tbLand.nState = self.nState;
	tbLand.tbRecord = self.tbRecord;
	tbLand.nRipenTime = self.nRipenTime;
	tbLand.nSickTime = self.nSickTime;

	if bForce then
		House:Save(self.dwOwnerId);
	else
		House:MarkDirty(self.dwOwnerId);
	end
end

function tbLandBase:GetSyncData()
	local tbRecord = {};
	for _, tbInfo in ipairs(self.tbRecord) do
		local tbRole = KPlayer.GetRoleStayInfo(tbInfo.dwPlayerId);
		if tbRole then
			table.insert(tbRecord, { szName = tbRole.szName, nState = tbInfo.nState, bCost = tbInfo.bCost } );
		end
	end

	return 
	{
		dwOwnerId = self.dwOwnerId,
		nState = self.nState,
		tbRecord = tbRecord,
		nRipenTime = self.nRipenTime,
	};
end

function tbLandBase:SyncClientData()
	local tbData = self:GetSyncData();
	self:DoSyncCmd("HousePlant:OnSyncHousePlant", tbData);
end

function tbLandBase:RemoveClientData()
	self:DoSyncCmd("HousePlant:OnSyncHousePlant", nil);
end

function tbLandBase:DoSyncCmd(cmd, ...)
	for pPlayer in House:ForeachMapPlayers(self.dwOwnerId) do
		pPlayer.CallClientScript(cmd, ...);
	end
end

function HousePlant:InitData(dwPlayerId)
	local tbHouse = House:GetHouse(dwPlayerId);
	for _, tbLand in ipairs(tbHouse.tbLandSet or {}) do
		self:AddLand(dwPlayerId, tbLand);
	end
end

function HousePlant:AddLand(dwOwnerId, tbLandData)
	assert(not self.tbLandSet[dwOwnerId], string.format("[ERROR][HousePlant] repeated add land to player: %d", dwOwnerId));

	local tbLand = Lib:NewClass(self.tbLandBase);
	self.tbLandSet[dwOwnerId] = tbLand;

	tbLand:Init(dwOwnerId, tbLandData.nState, tbLandData.tbRecord, tbLandData.nRipenTime, tbLandData.nSickTime);

	return tbLand;
end

function HousePlant:RemoveLand(dwOwnerId)
	local tbLand = self:GetLand(dwOwnerId);
	assert(tbLand, string.format("[ERROR][HousePlant] failed to remove land, it's not exist: %d", dwOwnerId));

	tbLand:Uninit();
	self.tbLandSet[dwOwnerId] = nil;
end

function HousePlant:GetLand(dwOwnerId)
	return self.tbLandSet[dwOwnerId];
end

function HousePlant:CreateLand(dwPlayerId)
	if self:GetLand(dwPlayerId) then
		Log("[ERROR][HousePlant] repeated create land: ", dwPlayerId);
		return false, "未知錯誤！請聯繫客服";
	end

	local tbLand = 
	{
		nState = HousePlant.STATE_NULL,
		tbRecord = {},
	};

	if not House:AddLand(dwPlayerId, tbLand) then
		return false, "你還沒有家園呢！";
	end

	self:AddLand(dwPlayerId, tbLand);

	Log("[HousePlant] create land successfully: ", dwPlayerId);

	return true;
end

function HousePlant:DestroyLand(dwPlayerId)
	local tbLand = self:GetLand(dwPlayerId);
	if not tbLand then
		Log("[ERROR][HousePlant] failed to remove land, it's not exist:", dwPlayerId);
		return false, "苗圃不存在";
	end

	if tbLand.nState ~= HousePlant.STATE_NULL then
		return false, "苗圃上已經種有植物，暫不能收起";
	end

	self:RemoveLand(dwPlayerId);
	
	if not House:RemoveLand(dwPlayerId) then
		Log("[ERROR][HousePlant] failed to remove land from house: ", dwPlayerId);
		return false, "未知錯誤，請聯繫客服";
	end

	Log("[HousePlant] destroy land successfully: ", dwPlayerId);

	return true;
end

function HousePlant:Plant(pPlayer)
	if not Env:CheckSystemSwitch(pPlayer, Env.SW_HousePlant) then
		pPlayer.CenterMsg("家園種植暫時關閉");
		return;
	end

	local dwPlayerId = pPlayer.dwID;
	local tbLand = self:GetLand(dwPlayerId);
	if not tbLand then
		pPlayer.CenterMsg("此處一片荒蕪~");
		return;
	end

	local bRet, szMsg = tbLand:CanPlant(pPlayer);
	if not bRet then
		pPlayer.CenterMsg(szMsg);
		return;
	end

	local fnPlant = function (dwPlayerId, bSuccess)
		if not bSuccess then
			return false, "儲值失敗";
		end

		local tbLand = HousePlant:GetLand(dwPlayerId);
		if not tbLand then
			return false, "苗圃已被收起";
		end

		local bRet = tbLand:Plant();
		if not bRet then
			return false, "未知錯誤！"; 
		end

		local pPlayer = KPlayer.GetPlayerObjById(dwPlayerId);
		if pPlayer then
			pPlayer.CenterMsg("種植成功！");
		end

		return true;
	end

	-- CostGold谨慎调用, 调用前请搜索 _LuaPlayer.CostGold 查看使用说明, 它处调用时请保留本注释
	local bRet = pPlayer.CostGold(HousePlant.PLANT_COST, Env.LogWay_HousePlant, nil, fnPlant);
	if not bRet then
		pPlayer.CenterMsg("支付失敗請稍後再試");
		return;
	end
end

function HousePlant:Cure(pPlayer, dwOwnerId, nState, bCost)
	if not Env:CheckSystemSwitch(pPlayer, Env.SW_HousePlant) then
		pPlayer.CenterMsg("家園種植暫時關閉");
		return;
	end

	local tbLand = self:GetLand(dwOwnerId);
	if not tbLand then
		pPlayer.CenterMsg("此處一片荒蕪~");
		return;
	end

	local bRet, szMsg = tbLand:CanCure(pPlayer, nState);
	if not bRet then
		pPlayer.CenterMsg(szMsg);
		return;
	end

	if not bCost then
		tbLand:DoCure(pPlayer);
		return;
	end

	if pPlayer.GetMoney("Gold") < HousePlant.CURE_COST then
		pPlayer.CenterMsg("元寶不足");
		return;
	end

	local fnCure = function (dwPlayerId, bSuccess)
		if not bSuccess then
			return false, "儲值失敗";
		end

		local pPlayer = KPlayer.GetPlayerObjById(dwPlayerId);
		if not pPlayer then
			return false, "玩家離線";
		end

		local tbLand = HousePlant:GetLand(dwOwnerId);
		if not tbLand then
			return false, "苗圃已被收起";
		end

		local bRet, szMsg = tbLand:CanCure(pPlayer, nState);
		if not bRet then
			pPlayer.CenterMsg(szMsg);
			return false, szMsg;
		end

		local bRet = tbLand:DoCure(pPlayer, true);
		if not bRet then
			return false, "養護失敗！！";
		end

		return true;
	end

	-- CostGold谨慎调用, 调用前请搜索 _LuaPlayer.CostGold 查看使用说明, 它处调用时请保留本注释
	local bRet = pPlayer.CostGold(HousePlant.CURE_COST, Env.LogWay_PlantCure, nil, fnCure);
	if not bRet then
		pPlayer.CenterMsg("支付失敗請稍後再試");
		return;
	end
end

function HousePlant:Crop(pPlayer)
	if not Env:CheckSystemSwitch(pPlayer, Env.SW_HousePlant) then
		pPlayer.CenterMsg("家園種植暫時關閉");
		return;
	end

	local dwPlayerId = pPlayer.dwID;
	local tbLand = self:GetLand(dwPlayerId);
	if not tbLand then
		pPlayer.CenterMsg("此處一片荒蕪~");
		return;
	end

	local bRet, szMsg = tbLand:CanCrop(pPlayer);
	if not bRet then
		pPlayer.CenterMsg(szMsg);
		return;
	end

	assert(tbLand:Crop());

	local tbAward = HousePlant:GetCropAward();
	assert(tbAward, string.format("failed to get crop award not exist: %d", dwPlayerId));
	
	pPlayer.SendAward(tbAward, nil, nil, Env.LogWay_PlantCrop);
	pPlayer.CenterMsg("收成成功！");
end

function HousePlant:OnLogin()
	self:DoSyncHousePlant(me);
	self:NotifyState(me.dwID);
end

function HousePlant:NotifyState(dwOwnerId)
	local tbLand = self:GetLand(dwOwnerId);
	if not tbLand then
		return;
	end

	local pPlayer = KPlayer.GetPlayerObjById(dwOwnerId);
	if not pPlayer then
		return;
	end

	local szType = nil;
	if tbLand.nState == HousePlant.STATE_RIPEN then
		szType = "PlantRipen";
	elseif HousePlant:IsSickState(tbLand.nState) and DegreeCtrl:GetDegree(pPlayer, "PlantCure") > 0 then
		szType = "PlantSick";
	end

	if not szType then
		return;
	end

	pPlayer.CallClientScript("Ui:SynNotifyMsg", { szType = szType, nTimeOut = GetTime() + 3600 });
end

function HousePlant:OnEnterMap()
	self:DoSyncHousePlant(me);
end

function HousePlant:OnReConnect()
	self:DoSyncHousePlant(me);
end

function HousePlant:DoSyncHousePlant(pPlayer)
	if not House:IsInNormalHouse(pPlayer) then
		return;
	end

	local nMapId = pPlayer.nMapId;
	local dwOwnerId = House:GetHouseInfoByMapId(nMapId);
	if not dwOwnerId then
		return;
	end

	local tbLand = self:GetLand(dwOwnerId);
	pPlayer.CallClientScript("HousePlant:OnSyncHousePlant", tbLand and tbLand:GetSyncData());
end

function HousePlant:TraverseSickFriendLand(pPlayer, fn)
	local dwPlayerId = pPlayer.dwID;
	local tbFriends = KFriendShip.GetFriendList(dwPlayerId);
	for dwFriendId in pairs(tbFriends) do
		local tbLand = self:GetLand(dwFriendId);
		if tbLand and HousePlant:IsSickState(tbLand.nState) and tbLand:GetTodayCureTimes(dwPlayerId) <= 0 then
			local bStop = fn(tbLand);
			if bStop then
				break;
			end
		end
	end
end

function HousePlant:TryGetFriendCanCure(pPlayer)
	local tbSick = {};
	self:TraverseSickFriendLand(pPlayer, function (tbLand)
		table.insert(tbSick, { dwPlayerId = tbLand.dwOwnerId, nState = tbLand.nState });
	end)
	pPlayer.CallClientScript("HousePlant:OnSyncFriendPlant", tbSick);
end

function HousePlant:CheckPlayerCanCure(pPlayer)
	local tbSick = {};
	if DegreeCtrl:GetDegree(pPlayer, "PlantHelpCure") > 0 then
		self:TraverseSickFriendLand(pPlayer, function (tbLand)
			tbSick[tbLand.dwOwnerId] = true;
		end);
	end
	pPlayer.CallClientScript("HousePlant:OnCheckPlayerCanCure", tbSick);
end
