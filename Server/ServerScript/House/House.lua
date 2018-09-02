House.tbCache = House.tbCache or {};
House.tbDirty = House.tbDirty or {};

House.tbTryEnterList = House.tbTryEnterList or {};
House.tbHouseMapInfo = House.tbHouseMapInfo or {};
House.tbLoadHouseDataCallbacks = House.tbLoadHouseDataCallbacks or {};
House.tbInviteList = House.tbInviteList or {};

-- -- 数据结构
-- tbData =
-- {
-- 	tbHouseSet =
-- 	{
-- 		{
-- 			nLevel = number,
-- 			nComfortValue = number, -- 舒适度
-- 			tbFurnitureSet =
-- 			{
-- 				{
-- 					nTemplateId = number,
-- 					nX = number,
-- 					nY = number,
-- 					nYaw = number,
-- 				},
-- 			},
-- 			tbAccess =
-- 			{
-- 				[nType] = bool,
-- 			},
-- 			tbRoomer =
-- 			{
-- 				dwPlayerId,
-- 			},

-- 			-- 苗圃
-- 			tbLandSet =
-- 			{
-- 				{
-- 					nState = number,
-- 					nRipenTime = number,
-- 					nSickTime = number,
-- 					tbRecord =
-- 					{
-- 						{
-- 							dwPlayerId = number,
-- 							bCost = bool,
--							nCureTime = number,
--							nState = number,
-- 						},
-- 					},
-- 				}
-- 			},
-- 		},
-- 	},
-- }

House.MAIL_CHECK_IN_ROOMER = [[    你已正式入住「%s」的家園，享有「%s」家園的房客特權。[FFFE0D][url=openwnd:瞭解房客規則, GeneralHelpPanel, "RoomeHelp"][-]\n\n[FFFE0D]    快“點擊右上角小地圖”進入家園看看吧！[-] ]];

House.MAIL_CHECK_IN_OWNER = [[    「%s」同意了你的入住邀請，現在已經是你的房客啦！]];

House.MAIL_CHECK_OUT_LEAVE = [[    「%s」已經搬離你的家園。]];

House.MAIL_CHECK_OUT_KICK = [[    你已被請離「%s」的家園。]];

House.MAIL_LEVELUP_PACKUP = [[    大俠！由於家園擴建後室內格局發生了變化。[FFFE0D]部分的掛飾類傢俱，本姑娘已經幫你收回到傢俱倉庫了哦[-]。[-] ]];

House.MAIL_SET_DECORATIONACCESS = [[    大俠！房主[FFFE0D]「%s」[-]已經授予你對其家園的裝修許可權啦，快回寄居家園協助房主美化一下傢俱佈局吧！]];

function House:TryGetRoomer(tbHouse, dwPlayerId)
	local nMatchIndex = -1;
	for nIndex, dwRoomerId in ipairs(tbHouse.tbRoomer) do
		if dwRoomerId == dwPlayerId then
			nMatchIndex = nIndex;
			break;
		end
	end
	return nMatchIndex ~= -1, nMatchIndex;
end

function House:GetHouse(dwOwnerId)
	local tbData = self.tbCache[dwOwnerId];
	if not tbData then
		return;
	end

	local tbHouse = assert(tbData.tbHouseSet[1], string.format("failed to get house:", dwOwnerId));
	return tbHouse;
end

function House:OnLoadData(dwPlayerId, tbData)
	local bIsFirstLoaded = not self.tbCache[dwPlayerId];
	self.tbCache[dwPlayerId] = tbData;

	if not bIsFirstLoaded then
		Log("[WARNING][house] repeated load player hosue ?!!!  ", dwOwnerId);
		return;
	end

	HousePlant:InitData(dwPlayerId);

	local tbCallBacks = self.tbLoadHouseDataCallbacks[dwPlayerId];
	if tbCallBacks then
		for _, tbCallBack in pairs(tbCallBacks) do
			Lib:CallBack(tbCallBack);
		end
		self.tbLoadHouseDataCallbacks[dwPlayerId] = nil;
	end
end

function House:MarkDirty(dwPlayerId)
	self.tbDirty[dwPlayerId] = true;
end

function House:Save(dwPlayerId)
	local tbData = assert(self.tbCache[dwPlayerId], string.format("[error] house data not exist, player: %d", dwPlayerId));
	if not SaveHouseData(dwPlayerId, tbData) then
		Log("[error][house] failed to save data:", dwPlayerId);
		Lib:LogTB(tbData);
		Log(debug.traceback());
	end

	self.tbDirty[dwPlayerId] = nil;
	return true;
end

function House:CheckDirty()
	for dwPlayerId, _ in pairs(self.tbDirty) do
		self:Save(dwPlayerId);
	end
end

function House:SaveAll()
	for dwPlayerId, _ in pairs(self.tbCache) do
		self:Save(dwPlayerId);
	end
end

function House:OnFinishTask(nTaskId)
	if nTaskId ~= House.nFinishHouseTaskId then
		return;
	end

	if not House:Create(me, 1) then
		Log("[House] OnFinishTask Create House ERR !!", me.dwID, me.szAccount, me.szName, nTaskId);
	end
end

function House:GoMyHome(pPlayer)
	if pPlayer.nHouseState ~= 1 then
		pPlayer.CenterMsg("大俠現在還沒有家園呀！");
		return;
	end

	House:EnterHouse(pPlayer, pPlayer.dwID);
end

function House:CheckEnterAccess(pPlayer, dwOwnerId)
	if pPlayer.dwID == dwOwnerId then
		return true;
	end

	local nLandlordId = pPlayer.GetUserValue(House.USERGROUP_LANDLORD, House.USERKEY_LANDLORD);
	if nLandlordId ~= 0 and nLandlordId == dwOwnerId then
		return true;
	end

	if Wedding:IsLover(pPlayer.dwID, dwOwnerId) then
		return true;
	end

	local tbHouse = self:GetHouse(dwOwnerId);
	if not tbHouse then
		return false;
	end

	if tbHouse.tbAccess[House.nAccessType_Stranger] then
		return true;
	end

	if tbHouse.tbAccess[House.nAccessType_Friend] then
		if FriendShip:IsFriend(pPlayer.dwID, dwOwnerId) then
			return true;
		end
	end

	if tbHouse.tbAccess[House.nAccessType_Kin] then
		if Kin:PlayerAtSameKin(pPlayer.dwID, dwOwnerId) then
			return true;
		end
	end

	return false;
end

function House:CheckCanEnterHouse(pPlayer, dwOwnerId, bForce)
	if self:IsIdleOwner(dwOwnerId) then
		return false, "對方房門佈滿了灰塵，看似出了遠門許久未歸";
	end

	local tbHouse = self:GetHouse(dwOwnerId);
	if not tbHouse then
		return false, "對方還沒有家園";
	end

	local tbSetting = self.tbHouseSetting[tbHouse.nLevel];
	if not tbSetting then
		return false, "";
	end

	local bRet, szMsg = self:CheckCanEnterMap(pPlayer);
	if not bRet then
		return false, szMsg;
	end

	if not bForce then
		if pPlayer.dwID == dwOwnerId and tbHouse.bIsUpgraded then
			pPlayer.CallClientScript("House:TipsLevelup");
			return false, "";
		end
	end

	return true;
end

function House:EnterHouse(pPlayer, dwOwnerId, tbPos, fnGotoHouse, bForce)
	if not Env:CheckSystemSwitch(pPlayer, Env.SW_House) then
		pPlayer.CenterMsg("當前不可進入家園，請稍候再試");
		return;
	end

	local bCan, szErr = self:CheckCanEnterHouse(pPlayer, dwOwnerId, bForce);
	if not bCan then
		if szErr and szErr~="" then
			pPlayer.CenterMsg(szErr);
		end
		return;
	end

	local tbHouse = self:GetHouse(dwOwnerId);
	local tbSetting = self.tbHouseSetting[tbHouse.nLevel];
	if self.tbHouseMapInfo[dwOwnerId] and self.tbHouseMapInfo[dwOwnerId].bLoadFinish then
		self:GotoHouse(pPlayer.dwID, dwOwnerId, nil, tbPos, fnGotoHouse);
	else
		local tbMapInfo = self.tbHouseMapInfo[dwOwnerId];
		if not tbMapInfo then
			local nMapId = CreateMap(tbSetting.nMapTemplateId);

			tbMapInfo = {};
			tbMapInfo.nMapId = nMapId;
			tbMapInfo.nLevel = tbHouse.nLevel;
			tbMapInfo.nMapTemplateId = tbSetting.nMapTemplateId;
			self.tbHouseMapInfo[dwOwnerId] = tbMapInfo;
		end

		self.tbTryEnterList[tbMapInfo.nMapId] = self.tbTryEnterList[tbMapInfo.nMapId] or {};
		self.tbTryEnterList[tbMapInfo.nMapId][pPlayer.dwID] = { tbPos = tbPos, fnGotoHouse = fnGotoHouse };
	end
end

function House:GotoHouse(nPlayerId, dwOwnerId, bHasWaite, tbPos, fnGotoHouse)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return;
	end

	if not bHasWaite and not fnGotoHouse and Map:IsFieldFightMap(pPlayer.nMapTemplateId) and pPlayer.nFightMode == 1 then	-- 野外传送读条
		GeneralProcess:StartProcess(pPlayer, 5 * Env.GAME_FPS, "傳送中...", function ()
			self:GotoHouse(nPlayerId, dwOwnerId, true, tbPos);
		end);
		return;
	end

	if not self.tbHouseMapInfo[dwOwnerId] or not self.tbHouseMapInfo[dwOwnerId].bLoadFinish then
		return;
	end

	pPlayer.SetEntryPoint();

	local nX, nY = 0, 0
	if tbPos then
		nX, nY = unpack(tbPos)
	end

	local nMapId = self.tbHouseMapInfo[dwOwnerId].nMapId;
	if fnGotoHouse then
		fnGotoHouse(pPlayer, nMapId, nX, nY);
	else
		pPlayer.SwitchMap(nMapId, nX, nY);
	end
end

function House:StartLevelUp(pPlayer, bForce)
	local tbHouse = self:GetHouse(pPlayer.dwID);
	if not tbHouse then
		return;
	end

	if tbHouse.nStartLeveupTime then
		pPlayer.CenterMsg("正在升級中哦，稍安勿躁");
		return;
	end

	local nMaxLevel = self:GetMaxOpenHouseLevel();
	if tbHouse.nLevel >= nMaxLevel then
		pPlayer.CenterMsg("已達最高等級！");
		return;
	end

	local tbHouseSetting = self.tbHouseSetting[tbHouse.nLevel];
	if not tbHouseSetting then
		pPlayer.CenterMsg("未知錯誤，請聯繫客服");
		return;
	end

	local fnLevelUp = function (dwPlayerId, bSuccess)
			if not bSuccess then
				return false, "儲值失敗";
			end

			local pPlayer = KPlayer.GetPlayerObjById(dwPlayerId);
			if not pPlayer then
				Log("[ERROR][house] failed to level up, player is offline: ", dwPlayerId);
				return false, "離線了";
			end

			local tbHouse = House:GetHouse(dwPlayerId);
			if not tbHouse then
				Log("[ERROR][house] failed to level up, the house not exist !!", dwPlayerId, pPlayer.szAccount, pPlayer.szName);
				return false, "未知錯誤！";
			end

			if tbHouse.nStartLeveupTime then
				Log("[ERROR][house] failed to level up, the house is busy !!", dwPlayerId, pPlayer.szAccount, pPlayer.szName, tbHouse.nLevel, tbHouse.nStartLeveupTime);
				return false;
			end

			tbHouse.nStartLeveupTime = GetTime();
			tbHouse.bIsUpgraded = nil;
			House:Save(dwPlayerId);

			House:CheckUpgrade(dwPlayerId);

			pPlayer.CallClientScript("House:OnStartLevelUp", tbHouse.nStartLeveupTime);

			Log("[house] start level up ok !!", pPlayer.dwID, pPlayer.szAccount, pPlayer.szName, tbHouse.nLevel);

			return true;
	end

	if bForce then
		fnLevelUp(pPlayer.dwID, true);
		return;
	end

	if pPlayer.GetMoney("Gold") < tbHouseSetting.nLevelupCost then
		pPlayer.CenterMsg("元寶不足以升級家園");
		return;
	end

	-- CostGold谨慎调用, 调用前请搜索 _LuaPlayer.CostGold 查看使用说明, 它处调用时请保留本注释
	local bRet = pPlayer.CostGold(tbHouseSetting.nLevelupCost, Env.LogWay_HouseLevelUp, nil, fnLevelUp);
	if not bRet then
		pPlayer.CenterMsg("支付失敗請稍後再試");
		return;
	end
end

function House:DoLevelUp(pPlayer, bForce)
	if not Env:CheckSystemSwitch(pPlayer, Env.SW_House) then
		pPlayer.CenterMsg("當前不可升級家園，請稍候再試");
		return;
	end

	local dwPlayerId = pPlayer.dwID;
	local tbHouse = self:GetHouse(dwPlayerId);
	if not tbHouse then
		pPlayer.CenterMsg("你還沒有家園哦！");
		return;
	end

	if not bForce then
		if not tbHouse.nStartLeveupTime then
			pPlayer.CenterMsg("此家園還沒開始升級呢！");
			return;
		end

		if not tbHouse.bIsUpgraded then
			pPlayer.CenterMsg("此家園升級還未完成呢！");
			return;
		end
	end

	local nMaxLevel = self:GetMaxOpenHouseLevel();
	if tbHouse.nLevel >= nMaxLevel then
		pPlayer.CenterMsg("已達最高等級！");
		return;
	end

	for pMapPlayer in House:ForeachMapRoomers(dwPlayerId) do
		local pNpc = pMapPlayer.GetNpc();
		if not pNpc or pNpc.GetSkillState(House.MUSE_EFFECT) then
			pPlayer.CenterMsg("房客正在家園冥想中，請稍候再來完成升級！");
			return;
		end
	end

	House:DeleteMap(dwPlayerId, "此家園擴建升級中，先離開一下吧！");

	local tbPackupRange = House.tbPackupRange[tbHouse.nLevel];
	local bPackup = self:BatchPackup(pPlayer, function (tbInfo)
		for _, tbRange in pairs(tbPackupRange) do
			if House:CheckInRange({tbInfo.nX, tbInfo.nY}, tbRange) then
				return true;
			end
		end
	end);

	tbHouse.nStartLeveupTime = nil;
	tbHouse.bIsUpgraded = nil;
	tbHouse.nLevel = tbHouse.nLevel + 1;

	self:UpdateComfortValue(pPlayer);
	self:Save(dwPlayerId);

	Log("[House] DoLevelUp", dwPlayerId, pPlayer.szAccount, pPlayer.szName, tbHouse.nLevel);

	pPlayer.SendBlackBoardMsg(string.format("家園成功升級至%d級，快回去看看吧！", tbHouse.nLevel), 1);

	if bPackup then
		local tbMail =
		{
			To = dwPlayerId,
			Title = "傢俱收起通知",
			From = "「家園管理員」真兒",
			Text = House.MAIL_LEVELUP_PACKUP,
		};
		Mail:SendSystemMail(tbMail);
	end

	if tbHouse.nLevel >= House.NOTIFY_LEVEL and pPlayer.dwKinId ~= 0 then
		local szMsg = string.format("「%s」的家園經過一番改造擴建，成功升級至[FFFE0D]%d級[-]，大家快去圍觀啊！", pPlayer.szName, tbHouse.nLevel);
		ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.Kin, szMsg, pPlayer.dwKinId);
	end
end

-- 批量收起家具
function House:BatchPackup(pPlayer, fnCheck)
	local tbHouse = self:GetHouse(pPlayer.dwID);
	if not tbHouse then
		return false;
	end

	local tbRemoveTemplateId = {};
	local tbToRemove = {};
	for _, tbInfo in pairs(tbHouse.tbFurnitureSet) do
		if fnCheck(tbInfo) then
			tbRemoveTemplateId[tbInfo.nTemplateId] = true;
			table.insert(tbToRemove, {tbInfo.nTemplateId, tbInfo.nX, tbInfo.nY});
		end
	end

	local bPackup = false;
	for _, tbInfo in pairs(tbToRemove) do
		local bRet = self:TryRemoveFurniture(pPlayer.dwID, unpack(tbInfo));
		if bRet then
			Log("[House] Packup Furniture", pPlayer.dwID, pPlayer.szAccount, pPlayer.szName, unpack(tbInfo))
			Furniture:Add(pPlayer, tbInfo[1]);

			bPackup = true;
		else
			Log("[ERROR][House] Packup furniture failed: ", pPlayer.dwID, pPlayer.szAccount, pPlayer.szName, unpack(tbInfo));
		end
	end

	local tbMapInfo = House.tbHouseMapInfo[pPlayer.dwID];
	if not tbMapInfo then
		return bPackup;
	end

	local tbMapFurniture = House.tbMapFurnitureInfo[tbMapInfo.nMapId];
	if not tbMapFurniture then
		return bPackup;
	end

	local tbToRemoveDecoration = {};
	for nId, tbInfo in pairs(tbMapFurniture) do
		if tbRemoveTemplateId[tbInfo.nTemplateId] then
			tbToRemoveDecoration[nId] = true;
		end
	end

	for nId in pairs(tbToRemoveDecoration) do
		Decoration:DeleteDecoration(nId);
		tbMapFurniture[nId] = nil;
	end

	return bPackup;
end

function House:Create(pPlayer, nLevel)
	nLevel = nLevel or 1;
	assert(type(nLevel) == "number");

	local dwPlayerId = pPlayer.dwID;
	if pPlayer.nHouseState == 1 or self.tbCache[dwPlayerId] then
		return false;
	end

	local tbData =
	{
		tbHouseSet = {},
	};
	self.tbCache[dwPlayerId] = tbData;

	table.insert(tbData.tbHouseSet,
	{
		nLevel = nLevel,
		nComfortValue = 0,
		tbFurnitureSet = {},
		tbAccess =
		{
			[House.nAccessType_Friend] = true,
			[House.nAccessType_Kin] = true,
		},
		tbRoomer = {},
		tbLandSet = {},
	});

	self:UpdateComfortValue(pPlayer);
	self:Save(dwPlayerId);

	pPlayer.nHouseState = 1;

	self:OnCreateHouse(pPlayer);

	Log("[House] Create House ", pPlayer.dwID, pPlayer.szAccount, pPlayer.szName, nLevel);

	return true;
end

function House:OnCreateHouse(pPlayer)
	Furniture:Add(pPlayer, HousePlant.LAND_ID);

	pPlayer.CallClientScript("Guide.tbNotifyGuide:StartNotifyGuide", "House");
	pPlayer.CallClientScript("House:OnSyncHasHouse", true);

	local dwLoverId = Wedding:GetLover(pPlayer.dwID);
	if dwLoverId then
		local pLover = KPlayer.GetPlayerObjById(dwLoverId);
		if pLover then
			self:SyncLoverHouse(pLover);
		end
	end
end

function House:SetAccess(pPlayer, nType, bAccess)
	local tbHouse = self:GetHouse(pPlayer.dwID);
	if not tbHouse then
		return;
	end

	if nType ~= House.nAccessType_Friend and
		nType ~= House.nAccessType_Kin and
		nType ~= House.nAccessType_Stranger then
		return;
	end

	tbHouse.tbAccess = tbHouse.tbAccess or {};
	tbHouse.tbAccess[nType] = bAccess;
	self:MarkDirty(pPlayer.dwID);
	pPlayer.CallClientScript("House:OnSetAccess", nType, bAccess);
end

function House:SetDecorationAccess(nOwnerId, nRoomerId, bAccess)
	local tbHouse = self:GetHouse(nOwnerId);
	if not tbHouse then
		return;
	end

	tbHouse.tbAccess = tbHouse.tbAccess or {};
	tbHouse.tbAccess[House.nAccessType_Decoration] = tbHouse.tbAccess[House.nAccessType_Decoration] or {};

	self:MarkDirty(nOwnerId);

	local tbDecorationAccess = tbHouse.tbAccess[House.nAccessType_Decoration];
	local tbAllRoomer = {};
	for _, nRId in pairs(tbHouse.tbRoomer or {}) do
		tbAllRoomer[nRId] = true;
	end

	local tbToRemove = {};
	for nRId in pairs(tbDecorationAccess) do
		if not tbAllRoomer[nRId] then
			tbToRemove[nRId] = true;
		end
	end

	for nRId in pairs(tbToRemove) do
		tbDecorationAccess[nRId] = nil;
	end

	if not tbAllRoomer[nRoomerId] then
		return;
	end

	local nToday = Lib:GetLocalDay();
	local pOwner = KPlayer.GetPlayerObjById(nOwnerId);
	self.tbSendDSMailInfo = self.tbSendDSMailInfo or {};
	self.tbSendDSMailInfo[nRoomerId] = self.tbSendDSMailInfo[nRoomerId] or 0;
	if pOwner and not tbDecorationAccess[nRoomerId] and bAccess and self.tbSendDSMailInfo[nRoomerId] < nToday then
		local tbMail =
		{
			To = nRoomerId,
			Title = "家園管理通知",
			From = "「家園管理員」真兒",
			Text = string.format(House.MAIL_SET_DECORATIONACCESS, pOwner.szName),
		};
		Mail:SendSystemMail(tbMail);
		self.tbSendDSMailInfo[nRoomerId] = nToday;
	end

	tbDecorationAccess[nRoomerId] = bAccess and true or nil;

	local pRoomer = KPlayer.GetPlayerObjById(nRoomerId);
	if pRoomer then
		House:SyncHouseInfo(pRoomer);
	end

	if pOwner then
		House:SyncHouseInfo(pOwner);
	end
end

-- 内部接口，谨慎调用，一般情况下不会被外部直接调用，推荐使用 House:TryAddFurniture
function House:AddFurniture(pPlayer, nTemplateId, nX, nY, nYaw, nSX, nSY)
	local dwPlayerId = pPlayer.dwID;
	local tbHouse = self:GetHouse(dwPlayerId);
	if not tbHouse then
		return false, "沒有家園";
	end

	local _, nFurnitureTemplateId = House:GetFurnitureInfo(nTemplateId);
	nSX, nSY = House:FormatScale(nFurnitureTemplateId, nSX, nSY);

	local tbFurniture =
	{
		nTemplateId = nTemplateId,
		nX = nX,
		nY = nY,
		nYaw = nYaw,
		nSX = nSX,
		nSY = nSY,
	};

	table.insert(tbHouse.tbFurnitureSet, tbFurniture);

	self:UpdateComfortValue(pPlayer);
	self:Save(dwPlayerId);

	Log("[House] add furniture: ", dwPlayerId, nTemplateId, nX, nY, nSX or 1, nSY or 1);

	return true;
end

function House:ChangeFurnitureScale(dwOwnerId, nTemplateId, nX, nY, nSX, nSY)
	local tbHouse = self:GetHouse(dwOwnerId);
	if not tbHouse then
		return false;
	end

	if not House:CheckFurnitureScale(nTemplateId, nSX, nSY) then
		return false;
	end

	local bFinish = false;
	for _, tbInfo in pairs(tbHouse.tbFurnitureSet) do
		if tbInfo.nTemplateId == nTemplateId and
			tbInfo.nX == nX and
			tbInfo.nY == nY then

			tbInfo.nSX = nSX or 1;
			tbInfo.nSY = nSY or 1;

			self:MarkDirty(dwOwnerId);
			bFinish = true;
		end
	end

	local nHouseMapId = (self.tbHouseMapInfo[dwOwnerId] or {}).nMapId;
	if nHouseMapId and self.tbMapFurnitureInfo[nHouseMapId] then
		for nDecorationId, tbInfo in pairs(self.tbMapFurnitureInfo[nHouseMapId]) do
			if tbInfo.nTemplateId == nTemplateId and tbInfo.nX == nX and tbInfo.nY == nY then
				tbInfo.nSX = nSX;
				tbInfo.nSY = nSY;
				Decoration:ChangeScale(nDecorationId, nSX, nSY);
				break;
			end
		end
	end

	return bFinish;
end

function House:TryAddFurniture(pPlayer, nTemplateId, nX, nY, nYaw, nSX, nSY)
	local dwPlayerId = pPlayer.dwID;
	local tbFurniture = House:GetFurnitureInfo(nTemplateId);
	if not tbFurniture then
		return false, "無效傢俱！";
	end

	if tbFurniture.nType == Furniture.TYPE_LAND then
		if not Env:CheckSystemSwitch(pPlayer, Env.SW_HousePlant) then
			return false, "家園種植暫時關閉";
		end

		local bRet, szMsg = HousePlant:CreateLand(dwPlayerId);
		if not bRet then
			return false, szMsg;
		end
	end

	return House:AddFurniture(pPlayer, nTemplateId, nX, nY, nYaw, nSX, nSY);
end

function House:GetComfortValue(pPlayer)
	local tbHouse = self:GetHouse(pPlayer.dwID);
	return tbHouse and tbHouse.nComfortValue or 0;
end

function House:ChangeFurniturePos(dwOwnerId, tbOrgInfo, tbDstInfo)
	local tbHouse = self:GetHouse(dwOwnerId);
	if not tbHouse then
		return false;
	end

	for _, tbInfo in pairs(tbHouse.tbFurnitureSet) do
		if tbInfo.nTemplateId == tbOrgInfo.nTemplateId and
			tbInfo.nX == tbOrgInfo.nX and
			tbInfo.nY == tbOrgInfo.nY and
			tbInfo.nYaw == tbOrgInfo.nRotation then

			tbInfo.nX = tbDstInfo.nX or tbInfo.nX;
			tbInfo.nY = tbDstInfo.nY or tbInfo.nY;
			tbInfo.nYaw = tbDstInfo.nRotation or tbInfo.nYaw;
			tbInfo.nSX = tbDstInfo.nSX or tbInfo.nSX;
			tbInfo.nSY = tbDstInfo.nSY or tbInfo.nSY;
			self:MarkDirty(dwOwnerId);
			return true;
		end
	end

	return false;
end

function House:TryRemoveFurniture(dwPlayerId, nTemplateId, nX, nY)
	local tbHouse = self:GetHouse(dwPlayerId);
	if not tbHouse then
		return false, "不存在的家園！";
	end

	local nMatchIndex = nil;
	for nIndex, tbFurniture in pairs(tbHouse.tbFurnitureSet) do
		if tbFurniture.nTemplateId == nTemplateId and tbFurniture.nX == nX and tbFurniture.nY == nY then
			nMatchIndex = nIndex;
			break;
		end
	end

	if not nMatchIndex then
		Log("[error][house] remove inexistent furniture, player:", dwPlayerId, nTemplateId, nX, nY);	
		return false, "不存在的傢俱！";
	end

	local bRet, szMsg = self:DoRemoveFurniture(dwPlayerId, tbHouse.tbFurnitureSet, nMatchIndex);
	if not bRet then
		return false, szMsg;
	end

	return true;
end

function House:DoRemoveFurniture(dwPlayerId, tbFurnitureSet, nIndex)
	local tbFurniture = tbFurnitureSet[nIndex];
	if not tbFurniture then
		return false, "未知錯誤";
	end

	local tbFurnitureInfo = House:GetFurnitureInfo(tbFurniture.nTemplateId);
	if tbFurnitureInfo and tbFurnitureInfo.nType == Furniture.TYPE_LAND then
		local bRet, szMsg = HousePlant:DestroyLand(dwPlayerId);
		if not bRet then
			return false, szMsg;
		end
	end

	table.remove(tbFurnitureSet, nIndex);

	self:Save(dwPlayerId);

	local pPlayer = KPlayer.GetPlayerObjById(dwPlayerId);
	if pPlayer then
		self:UpdateComfortValue(pPlayer);
	end

	Log("[House] remove furniture: ", dwPlayerId, tbFurniture.nTemplateId, tbFurniture.nX, tbFurniture.nY);

	return true;
end

function House:RemoveFurnitureTemplate(dwPlayerId, nTemplateId, nCount)
	local tbHouse = self:GetHouse(dwPlayerId);
	if not tbHouse then
		return 0;
	end

	local tbRemove = {};
	for nIndex = #tbHouse.tbFurnitureSet, 1, -1 do
		local tbFurniture = tbHouse.tbFurnitureSet[nIndex];
		if tbFurniture.nTemplateId == nTemplateId then
			table.insert(tbRemove, nIndex);	

			nCount = nCount - 1;
			if nCount <= 0 then
				break;
			end
		end
	end

	local nRemoveCount = 0;
	for _, nIndex in ipairs(tbRemove) do
		local bRet = self:DoRemoveFurniture(dwPlayerId, tbHouse.tbFurnitureSet, nIndex);
		if bRet then
			nRemoveCount = nRemoveCount + 1;
		end
	end

	return nRemoveCount;
end

-- 是否闲置家主（拥有家园但因长期未登录，因此数据未加载）
function House:IsIdleOwner(dwPlayerId)
	if self.tbCache[dwPlayerId] then
		return false;
	end

	-- 判断玩家是否拥有家园标识
	local tbRole = KPlayer.GetRoleStayInfo(dwPlayerId);
	if not tbRole or tbRole.nHouseState ~= 1 then
		return false;
	end

	return true;
end

function House:OnLogin()
	local pPlayer = me;
	if House:CheckOpen(pPlayer)
		and not Task:GetPlayerTaskInfo(pPlayer, House.nFirstHouseTaskId)
		and Task:GetTaskFlag(pPlayer, House.nFirstHouseTaskId) ~= 1 then

		Task:TryAcceptTask(pPlayer, House.nFirstHouseTaskId, pPlayer.GetNpc().nId);
	end

	self:SyncMyHouseData(pPlayer);

	local dwPlayerId = pPlayer.dwID;
	if self:IsIdleOwner(dwPlayerId) then
		self:RequestLoadHouse(dwPlayerId, dwPlayerId, function ()
			local pPlayer = KPlayer.GetPlayerObjById(dwPlayerId);
			if pPlayer then
				self:OnOwnerLogin(pPlayer);
			end
		end);
	else
		self:OnOwnerLogin(pPlayer);
	end
	
	local nLandlordId = pPlayer.GetUserValue(self.USERGROUP_LANDLORD, self.USERKEY_LANDLORD);
	if nLandlordId ~= 0 then
		if self:IsIdleOwner(nLandlordId) then
			self:RequestLoadHouse(nLandlordId, dwPlayerId, function ()
		  		local pPlayer = KPlayer.GetPlayerObjById(dwPlayerId);
		  		if pPlayer then
		  			self:OnRoomerLogin(pPlayer, nLandlordId);
		  		end
		  	end)
		else
			self:OnRoomerLogin(pPlayer, nLandlordId);
		end
	end

	local dwLoverId = Wedding:GetLover(dwPlayerId);
	if dwLoverId and dwLoverId ~= nLandlordId and self:IsIdleOwner(dwLoverId) then
		self:RequestLoadHouse(dwLoverId);
	end
end

function House:RequestLoadHouse(dwOwnerId, dwKey, fnCallBack)
	if dwKey and fnCallBack then
		self.tbLoadHouseDataCallbacks[dwOwnerId] = self.tbLoadHouseDataCallbacks[dwOwnerId] or {};
		self.tbLoadHouseDataCallbacks[dwOwnerId][dwKey] = { fnCallBack };	-- 以登录玩家id为key，可覆盖
	end
	RequestLoadHouseData(dwOwnerId);
end

function House:OnOwnerLogin(pPlayer)
	self:SyncHouseInfo(pPlayer);
	self:SyncExtComfortLevel(pPlayer);
	self:UpdateComfortValue(pPlayer);
end

function House:OnRoomerLogin(pRoomer, nLandlordId)
	local dwRoomerId = pRoomer.dwID;
	local tbHouse = House:GetHouse(nLandlordId);
	if not tbHouse then
		return;
	end

	local bRet = House:TryGetRoomer(tbHouse, dwRoomerId);
	if bRet then
		return;
	end

	pRoomer.SetUserValue(House.USERGROUP_LANDLORD, House.USERKEY_LANDLORD, 0);

	Log(string.format("[house] login check out: owner(%d), roomer(%d)", nLandlordId, dwRoomerId));
end

function House:OnReConnect(pPlayer)
	self:SyncMyHouseData(pPlayer);
	self:SyncHouseInfo(pPlayer);
end

function House:SyncMyHouseData(pPlayer)
	pPlayer.CallClientScript("House:OnSyncHasHouse", pPlayer.nHouseState == 1);
	self:SyncLoverHouse(pPlayer);
end

function House:OnLevelUp()
	if House:CheckOpen(me)
		and not Task:GetPlayerTaskInfo(me, House.nFirstHouseTaskId)
		and Task:GetTaskFlag(me, House.nFirstHouseTaskId) ~= 1 then

		Task:TryAcceptTask(me, House.nFirstHouseTaskId, me.GetNpc().nId);
	end
end

function House:UpdateComfortValue(pPlayer)
	local tbHouse = self:GetHouse(pPlayer.dwID);
	if not tbHouse then
		return;
	end

	local nOldComfortValue = tbHouse.nComfortValue;
	local nNewComfortValue = self:CalcuComfortValue(tbHouse.nLevel, tbHouse.tbFurnitureSet);
	if nNewComfortValue ~= nOldComfortValue then
		tbHouse.nComfortValue = nNewComfortValue;
		RankBoard:UpdateRankVal("House", pPlayer, tbHouse.nComfortValue);

		local nOldLevel = self:CalcuComfortLevel(nOldComfortValue);
		local nNewLevel = self:CalcuComfortLevel(nNewComfortValue);
		if nNewLevel > nOldLevel then
			pPlayer.SendBlackBoardMsg(string.format("家園舒適等級提升至%d級", nNewLevel), true);
		end

		FightPower:ChangeFightPower("House", pPlayer);
	end
end

function House:OnStartDecorationState(pPlayer)
	local nHouseMapId = nil;

	local bIsInLiving, nOwnerId = House:IsInLivingRoom(pPlayer);
	if not bIsInLiving then
		nOwnerId = pPlayer.dwID;
	end

	if self.tbHouseMapInfo[nOwnerId] and self.tbHouseMapInfo[nOwnerId].nMapId then
		nHouseMapId = self.tbHouseMapInfo[nOwnerId].nMapId;
	end

	if not nHouseMapId or nHouseMapId ~= pPlayer.nMapId then
		return;
	end

	Decoration:ClearAllPlayerActState(pPlayer.nMapId);
end

function House:CanCheckIn(pPlayer, dwOwnerId, bForce)
	if pPlayer.nLevel < House.nMinOpenLevel then
		return false, "等級不足";
	end

	local nLandlordId = pPlayer.GetUserValue(self.USERGROUP_LANDLORD, self.USERKEY_LANDLORD);
	if nLandlordId ~= 0 then
		return false, "無法邀請，對方已經入住了的其他家園";
	end

	local dwPlayerId = pPlayer.dwID;
	if dwOwnerId == dwPlayerId then
		return false, "房主無需申請入住";
	end

	if Wedding:IsLover(dwPlayerId, dwOwnerId) then
		return false, "你們已是伴侶，無須申請入住！";
	end

	local tbHouse = self:GetHouse(dwOwnerId);
	if not tbHouse then
		return false, "家園不存在";
	end

	local tbSetting = self.tbHouseSetting[tbHouse.nLevel];
	if not tbSetting then
		return false, "無效家園";
	end

	if not bForce then
		local nTotalCount = #tbHouse.tbRoomer;
		if nTotalCount >= tbSetting.nRoomerCount then
			return false, "客房已滿！";
		end

		local nIntimacyLevel = FriendShip:GetFriendImityLevel(dwOwnerId, dwPlayerId) or 0;
		if nIntimacyLevel < self.nCheckInIntimacyLevel then
			return false, "親密度不足";
		end
	end

	return true;
end

function House:InviteCheckIn(pOwner, dwPlayerId)
	local pPlayer = KPlayer.GetPlayerObjById(dwPlayerId);
	if not pPlayer then
		pOwner.CenterMsg("對方不線上哦！");
		return;
	end

	local dwOwnerId = pOwner.dwID;
	local bRet, szMsg = self:CanCheckIn(pPlayer, dwOwnerId);
	if not bRet then
		pOwner.CenterMsg(szMsg);
		return;
	end

	pPlayer.CallClientScript("Ui:SynNotifyMsg", { szType = "HouseInvite", nTimeOut = GetTime() + 3600, dwOwnerId = dwOwnerId });
	pOwner.CenterMsg("已發送邀請");

	House.tbInviteList[dwOwnerId] = House.tbInviteList[dwOwnerId] or {};
	House.tbInviteList[dwOwnerId][dwPlayerId] = true;
end

function House:CheckIn(pPlayer, dwOwnerId, bForce)
	local bRet, szMsg = self:CanCheckIn(pPlayer, dwOwnerId, bForce);
	if not bRet then
		pPlayer.CenterMsg(szMsg);
		return false;
	end

	local dwPlayerId = pPlayer.dwID;
	if not bForce then
		if not House.tbInviteList[dwOwnerId] or not House.tbInviteList[dwOwnerId][dwPlayerId] then
			pPlayer.CenterMsg("對方還沒有邀請你入住哦");
			return false;
		end
	end

	local tbHouse = self:GetHouse(dwOwnerId);
	local bRet = self:TryGetRoomer(tbHouse, dwPlayerId);
	assert(not bRet, string.format("[ERROR][house] repeated roomer: %d, in house(%d)", dwPlayerId, dwOwnerId));

	table.insert(tbHouse.tbRoomer, dwPlayerId);
	pPlayer.SetUserValue(self.USERGROUP_LANDLORD, self.USERKEY_LANDLORD, dwOwnerId);
	pPlayer.SetUserValue(self.USERGROUP_LANDLORD, self.USERKEY_TIME_CHECKIN, GetTime());

	self:Save(dwOwnerId);

	pPlayer.CallClientScript("House:OnCheckIn", dwOwnerId);
	pPlayer.CenterMsg("成功入住家園！");

	Log(string.format("[house] roomer check in: owner(%d), roomer(%d)", dwOwnerId, dwPlayerId));

	self:SyncRoomer(dwOwnerId);

	self:SetDecorationAccess(dwOwnerId, dwPlayerId, false);

	local tbMail =
	{
		To = dwOwnerId,
		Title = "家園入住通知",
		From = "「家園管理員」真兒",
		Text = string.format(House.MAIL_CHECK_IN_OWNER, pPlayer.szName),
	};
	Mail:SendSystemMail(tbMail);

	local tbRole = KPlayer.GetRoleStayInfo(dwOwnerId);
	local tbMail =
	{
		To = dwPlayerId,
		Title = "家園入住通知",
		From = "「家園管理員」真兒",
		Text = string.format(House.MAIL_CHECK_IN_ROOMER, tbRole.szName, tbRole.szName),
	};
	Mail:SendSystemMail(tbMail);

	House.tbInviteList[dwOwnerId] = House.tbInviteList[dwOwnerId] or {};
	House.tbInviteList[dwOwnerId][dwPlayerId] = nil;
	if not next(House.tbInviteList[dwOwnerId]) then
		House.tbInviteList[dwOwnerId] = nil;
	end

	return true;
end

-- 支持离线退房
function House:CheckOut(dwRoomerId, dwOwnerId)
	local tbHouse = self:GetHouse(dwOwnerId);
	if not tbHouse then
		return false, "這是個假房東";
	end

	local bRet, nIndex = self:TryGetRoomer(tbHouse, dwRoomerId);
	if not bRet then
		return false, "查無此人";
	end

	table.remove(tbHouse.tbRoomer, nIndex);

	local pRoomer = KPlayer.GetPlayerObjById(dwRoomerId);
	if pRoomer then
		pRoomer.SetUserValue(self.USERGROUP_LANDLORD, self.USERKEY_LANDLORD, 0);
		pRoomer.CallClientScript("House:OnCheckOut", dwOwnerId);
	end

	self:Save(dwOwnerId);

	Log(string.format("[house] roomer check out: owner(%d), roomer(%d)", dwOwnerId, dwRoomerId));

	self:SyncRoomer(dwOwnerId);
	self:SetDecorationAccess(dwOwnerId, dwRoomerId, false);

	if pRoomer then
		pRoomer.CallClientScript("House:ExitDecorationMode");
		Decoration:DoSyncMapDecoration(pRoomer);
	end
	return true;
end

function House:RoomerCheckOut(pRoomer)
	local nLandlordId = pRoomer.GetUserValue(self.USERGROUP_LANDLORD, self.USERKEY_LANDLORD);
	if nLandlordId == 0 then
		return;
	end

	local bRet, szMsg = self:CheckOut(pRoomer.dwID, nLandlordId);
	if not bRet then
		pRoomer.CenterMsg(szMsg);
		return;
	end

	pRoomer.CenterMsg("已搬離家園！");

	local tbMail =
	{
		To = nLandlordId,
		Title = "房客搬離通知",
		From = "「家園管理員」真兒",
		Text = string.format(House.MAIL_CHECK_OUT_LEAVE, pRoomer.szName),
	};
	Mail:SendSystemMail(tbMail);
end

function House:MakeCheckOut(pOwner, dwRoomerId)
	local dwOwnerId = pOwner.dwID;
	local bRet, szMsg = self:CheckOut(dwRoomerId, dwOwnerId);
	if not bRet then
		pOwner.CenterMsg(szMsg);
		return;
	end

	pOwner.CenterMsg("已成功請離家園！");

	local tbMail =
	{
		To = dwRoomerId,
		Title = "家園搬離通知",
		From = "「家園管理員」真兒",
		Text = string.format(House.MAIL_CHECK_OUT_KICK, pOwner.szName),
	};
	Mail:SendSystemMail(tbMail);
end

function House:GetHouseComfortLevel(dwOwnerId)
	local tbHouse = self:GetHouse(dwOwnerId);
	if not tbHouse then
		return;
	end
	return self:CalcuComfortLevel(tbHouse.nComfortValue);
end

function House:GetHouseComfortSetting(dwOwnerId)
	local nLevel = self:GetHouseComfortLevel(dwOwnerId);
	if not nLevel then
		return;
	end
	return self:GetComfortSetting(nLevel);
end

-- 使用前请确保 dwOwnerId, dwRoomerId 均非闲置家主(House:IsIdleOwner)
function House:GetRoomerComfortLevel(dwOwnerId, dwRoomerId)
	local nOwnerComfortLevel = self:GetHouseComfortLevel(dwOwnerId);
	if not nOwnerComfortLevel then
		return;
	end

	local nRoomerComfortLevel = self:GetHouseComfortLevel(dwRoomerId) or 0;
	local nComfortLevel = self:CalcRoomerComfortLevel(nOwnerComfortLevel, nRoomerComfortLevel);
	return nComfortLevel, nRoomerComfortLevel;
end

function House:GetRoomerComfortSetting(dwOwnerId, dwRoomerId)
	if self:IsIdleOwner(dwOwnerId) or self:IsIdleOwner(dwRoomerId) then
		return;
	end

	local nLevel = self:GetRoomerComfortLevel(dwOwnerId, dwRoomerId);
	if not nLevel then
		return;
	end

	return self:GetComfortSetting(nLevel);
end

function House:CanMuse(pPlayer)
	if pPlayer.Temp_bIsOnMusing then
		return false, "當前正在冥想中";
	end

	if not Env:CheckSystemSwitch(pPlayer, Env.SW_Muse) then
		return false, "當前狀態不允許冥想";
	end

	if DegreeCtrl:GetDegree(pPlayer, "Muse") <= 0 then
		return false, "次數不足";
	end

	return true;
end

function House:TryMuse(pPlayer)
	local bRet, result = self:CanMuse(pPlayer);
	if not bRet then
		pPlayer.CenterMsg(result);
		return;
	end

	local dwOwnerId, tbComfort = self:GetMuseHouse(pPlayer);
	local bIsInLivingRoom, nLandlordId = self:IsInLivingRoom(pPlayer);
	local bIsInOwnHouse = self:IsInOwnHouse(pPlayer);
	if not bIsInLivingRoom and not bIsInOwnHouse then
		if not dwOwnerId then
			pPlayer.CenterMsg("你還沒有任何家園哦");
			return;
		end
		self:GotoMuse(pPlayer, dwOwnerId);
		return;
	end
	
	if not dwOwnerId then
		pPlayer.MsgBox("[FF6464FF]房客特權淩晨4:00以後生效。[-]還是先回自己的家園冥想吧，確定後即刻返回家園。", {{"確定", function ()
			me.MsgBox("你還沒有家園，傳聞[FFFE0D]真兒[-]處可打探到相關資訊。",
			{
				{"現在就去", function () me.CallClientScript("Ui.HyperTextHandle:Handle", "[url=npc:testtt,2279,10]", 0, 0); end},
				{"等會兒吧"}
			});
			end}, {"取消"}});
		return;
	end

	local dwPlayerId = pPlayer.dwID;
	local dwCurHouseOwneId = bIsInOwnHouse and dwPlayerId or nLandlordId;
	if not House:IsIndoor(pPlayer) then
		self:GotoMuse(pPlayer, dwCurHouseOwneId);
		return;
	end

	local _, tbMuseComfort = self:GetBetterHouse(pPlayer);
	House:DoMuse(pPlayer, tbMuseComfort.nEnergy);
end

function House:DoMuse(pPlayer, nBaseEnergy)
	pPlayer.Temp_bIsOnMusing = true;

	Env:SetSystemSwitchOff(pPlayer, Env.SW_All);
	ActionMode:DoForceNoneActMode(pPlayer);

	local pNpc = pPlayer.GetNpc();
	if pNpc then
		pNpc.CastSkill(self.MUSE_SKILL, 1, 0, 0);
		pNpc.SetDir(40);
	end

	local nMuseTime = Env.GAME_FPS * self.MUSE_TIME;
	pPlayer.AddSkillState(self.MUSE_EFFECT, 1, 0, nMuseTime);

	pPlayer.CallClientScript("House:OnMuseStart");

	local dwPlayerId = pPlayer.dwID;
	Timer:Register(Env.GAME_FPS * House.MUSE_TIME, function ()
		House:OnMuseEnd(dwPlayerId, nBaseEnergy);
	end);
end

function House:OnMuseEnd(dwPlayerId, nBaseEnergy)
	local pPlayer = KPlayer.GetPlayerObjById(dwPlayerId);
	if not pPlayer then
		Log("[ERROR][house]failed to muse, player is offline: ", dwPlayerId, nBaseEnergy)
		return;
	end

	Env:SetSystemSwitchOn(pPlayer, Env.SW_All);
	pPlayer.Temp_bIsOnMusing = nil;

	pPlayer.RemoveSkillState(self.MUSE_EFFECT);
	local pNpc = pPlayer.GetNpc();
	if pNpc then
		pNpc.RestoreAction();
	end

	local bRet = DegreeCtrl:ReduceDegree(pPlayer, "Muse", 1);
	if not bRet then
		pPlayer.CallClientScript("House:OnMuseEnd");
		pPlayer.CenterMsg("扣除次數失敗，請稍候再試");
		return;
	end

	local tbResult, nLevel = self:CalcuMuseResult();
	local nAwardRatio = tbResult.fAwardRatio + self:GetMuseExtAwardRatio(pPlayer.nMapId);
	local nEnergy = math.max(0, math.floor(nBaseEnergy * nAwardRatio));
	pPlayer.AddMoney("Energy", nEnergy, Env.LogWay_Muse);
	pPlayer.Msg(string.format(tbResult.szResult, nEnergy));

	if tbResult.szKinNotify ~= "" and pPlayer.dwKinId ~= 0 then
		local szMsg = string.format(tbResult.szKinNotify, pPlayer.szName, nEnergy);
		ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.Kin, szMsg, pPlayer.dwKinId);
	end

	if tbResult.szWorldNotify ~= "" then
		local szMsg = string.format(tbResult.szWorldNotify, pPlayer.szName, nEnergy);
		KPlayer.SendWorldNotify(0, 999, szMsg, 1, 1);
	end

	pPlayer.CallClientScript("House:OnMuseEnd", nLevel);
	
	EverydayTarget:AddCount(pPlayer, "Muse");
	
	Log("[House][Muse] Add Energy: ", dwPlayerId, nEnergy, nBaseEnergy, nAwardRatio);
end

function House:AddLand(dwOwnerId, tbLand)
	local tbHouse = self:GetHouse(dwOwnerId);
	if not tbHouse then
		return false;
	end

	assert(not tbHouse.tbLandSet[1], string.format("[ERROR][House] failed to add land to house, repeated! %d", dwOwnerId));

	table.insert(tbHouse.tbLandSet, tbLand);
	self:Save(dwOwnerId);

	Log("[House] add land to house successfully:", dwOwnerId);

	return true;
end

function House:RemoveLand(dwOwnerId)
	local tbHouse = self:GetHouse(dwOwnerId);
	if not tbHouse then
		return false;
	end

	tbHouse.tbLandSet[1] = nil;
	self:Save(dwOwnerId);

	Log("[House] remove land from house:", dwOwnerId);

	return true;
end

function House:GetLand(dwOwnerId)
	local tbHouse = self:GetHouse(dwOwnerId);
	if not tbHouse then
		return;
	end
	return tbHouse.tbLandSet[1];
end

function House:SyncHouseInfo(pPlayer)
	local nMapId = pPlayer.nMapId;
	local dwOwnerId = self:GetHouseInfoByMapId(nMapId);
	if not dwOwnerId then
		return;
	end

	local tbHouse = self:GetHouse(dwOwnerId);
	if not tbHouse then
		return;
	end

	local dwPlayerId = pPlayer.dwID;
	local bIsOwner = dwPlayerId == dwOwnerId;
	local tbRole = KPlayer.GetRoleStayInfo(dwOwnerId);
	assert(tbRole);

	local tbHouseInfo =
	{
		dwOwnerId = dwOwnerId,
		szName = tbRole.szName,
		nLevel = tbHouse.nLevel,
		nMapId = nMapId,
	};

	
	local dwLoverInfo = nil;
	if bIsOwner or self:IsRoomer(pPlayer, dwOwnerId) then
		tbHouseInfo.tbRoomer = self:GetRoomerInfo(tbHouse.tbRoomer);
		tbHouseInfo.tbAccess = tbHouse.tbAccess;
		
		dwLoverInfo = self:GetLoverInfo(dwOwnerId);

		if bIsOwner then
			tbHouseInfo.nStartLeveupTime = tbHouse.nStartLeveupTime;
		end
	end

	pPlayer.CallClientScript("House:OnSyncHouseInfo", tbHouseInfo, dwLoverInfo);
end

function House:GetRoomerInfo(tbRoomer)
	local tbResult = {};
	for _, dwPlayerId in ipairs(tbRoomer) do
		local tbRole = KPlayer.GetRoleStayInfo(dwPlayerId);
		table.insert(tbResult, { dwPlayerId = dwPlayerId, szName = tbRole.szName, nPortrait = tbRole.nPortrait });
	end
	return tbResult;
end

function House:SyncRoomer(dwOwnerId)
	local tbHouse = self:GetHouse(dwOwnerId);
	if not tbHouse then
		return;
	end

	local tbResult = self:GetRoomerInfo(tbHouse.tbRoomer);
	for pRoomer in House:ForeachMapRoomers(dwOwnerId) do
		pRoomer.CallClientScript("House:OnSyncRoomers", tbResult, self:GetLoverInfo(dwOwnerId));
	end
end

function House:GotoLand(pPlayer, dwOwnerId)
	local tbFurniture = self:GetLandFurniture(dwOwnerId);
	if not tbFurniture then
		pPlayer.CenterMsg("苗圃不存在");
		return;
	end

	House:EnterHouse(pPlayer, dwOwnerId, { tbFurniture.nX, tbFurniture.nY }, function (pPlayer, nMapId, nX, nY)
		pPlayer.CallClientScript("HousePlant:AutoPlantCure", nMapId, nX, nY);
	end);
end

function House:GetLandFurniture(dwOwnerId)
	local tbHouse = self:GetHouse(dwOwnerId);
	if not tbHouse then
		return;
	end

	for _, tbFurniture in ipairs(tbHouse.tbFurnitureSet) do
		local tbFurnitureInfo = House:GetFurnitureInfo(tbFurniture.nTemplateId);
		if tbFurnitureInfo.nType == Furniture.TYPE_LAND then
			return tbFurniture;
		end
	end
end

function House:CheckUpgrade(dwOwnerId)
	local tbHouse = self:GetHouse(dwOwnerId);
	if (not tbHouse) or (not tbHouse.nStartLeveupTime) or tbHouse.bIsUpgraded then
		return;
	end

	local fnOnUpgraded = function ()
		local tbHouse = self:GetHouse(dwOwnerId);
		if (not tbHouse) or (not tbHouse.nStartLeveupTime) or tbHouse.bIsUpgraded then
			return;
		end

		tbHouse.bIsUpgraded = true;
		self:MarkDirty(dwOwnerId);

		local tbMail = {
			To = dwOwnerId,
			Title = "家園升級通知",
			From = "「家園管理員」真兒",
			Text = "真兒的飛鴿傳書：\n    大俠，您的家園升級擴建目前已經完成。請[c8ff00][url=npc:前來, 2279, 10][-]確認，完成家園升級！",
		};
		Mail:SendSystemMail(tbMail);
	end

	local tbSetting = self.tbHouseSetting[tbHouse.nLevel];
	local nTime = tbHouse.nStartLeveupTime + tbSetting.nLevelupTime - GetTime();
	if nTime <= 0 then
		fnOnUpgraded();
		return;
	end

	Timer:Register(Env.GAME_FPS * nTime, fnOnUpgraded);
end

function House:OnStartUp()
	for dwOwnerId, _ in pairs(self.tbCache) do
		self:CheckUpgrade(dwOwnerId);
	end
end

function House:TryGetHouseFriendList(pPlayer)
	local dwPlayerId = pPlayer.dwID;
	local tbHouse = self:GetHouse(dwPlayerId);
	if not tbHouse then
		return;
	end

	local tbResult = {};
	local tbFriendSet = KFriendShip.GetFriendList(dwPlayerId);
	for dwFriendId, nImity in pairs(tbFriendSet) do
		local nLevel = FriendShip:GetImityLevel(nImity);
		if nLevel >= House.nCheckInIntimacyLevel then
			local pFriend = KPlayer.GetPlayerObjById(dwFriendId);
			if pFriend and pFriend.nLevel >= House.nMinOpenLevel then
				local nLandlordId = pFriend.GetUserValue(House.USERGROUP_LANDLORD, House.USERKEY_LANDLORD);
				if nLandlordId ~= dwPlayerId and not Wedding:IsLover(dwFriendId, dwPlayerId) then
					table.insert(tbResult, { dwPlayerId = dwFriendId, bCanInvite = nLandlordId == 0 });
				end
			end
		end
	end

	pPlayer.CallClientScript("House:OnSyncHouesFriendList", tbResult);
end

function House:GetBetterHouse(pPlayer)
	local dwBetterId = nil;
	local dwPlayerId = pPlayer.dwID;
	local tbComfort = self:GetHouseComfortSetting(dwPlayerId);
	if tbComfort then
		dwBetterId = dwPlayerId;
	end

	local nLandlordId, tbLivingComfort = self:GetBetterLandlord(pPlayer);
	if tbLivingComfort and (not tbComfort or tbComfort.nLevel < tbLivingComfort.nLevel) then
		tbComfort = tbLivingComfort;
		dwBetterId = nLandlordId;
	end

	return dwBetterId, tbComfort;
end

function House:GetMuseHouse(pPlayer)
	local dwBetterId = nil;
	local tbComfort = nil;
	local fnCheck = function (dwOwnerId)
		if not dwOwnerId then
			return;
		end

		local tbLandloadComfort = self:GetHouseComfortSetting(dwOwnerId);
		if tbLandloadComfort and (not tbComfort or tbLandloadComfort.nLevel > tbComfort.nLevel) then
			dwBetterId = dwOwnerId;
			tbComfort = tbLandloadComfort;
		end
	end

	local dwPlayerId = pPlayer.dwID;
	fnCheck(dwPlayerId);
	fnCheck(House:GetValidLandlord(pPlayer));
	fnCheck(Wedding:GetLover(dwPlayerId));

	return dwBetterId, tbComfort;
end

function House:GetHouseLevel(dwOwnerId)
	local tbHouse = self:GetHouse(dwOwnerId);
	if not tbHouse then
		return;
	end
	return tbHouse.nLevel;
end

function House:GotoMuse(pPlayer, dwOwnerId)
	local fnMuse = function (pPlayer, nMapId, nX, nY)
		pPlayer.CallClientScript("House:AutoMuse", nMapId, nX, nY);
	end

	local nMapId = House:GetHouseMap(dwOwnerId);
	if nMapId and nMapId == pPlayer.nMapId then
		fnMuse(pPlayer, nMapId, unpack(House.MUSE_POS));
		return;
	end

	self:EnterHouse(pPlayer, dwOwnerId, House.MUSE_POS, fnMuse);
end

function House:SaveMapFurniture(nMapId)
	local nMapTemplateId = GetMapInfoById(nMapId);
	if not nMapTemplateId then
		Log("[ERROR][samplehouse] unknown map: ", nMapId)
		return;
	end

	local szData = "";
	for _, tbFurniture in pairs(House.tbMapFurnitureInfo[nMapId] or {}) do
		szData = szData .. string.format("\n%d\t%d\t%d\t%d", tbFurniture.nTemplateId, tbFurniture.nX, tbFurniture.nY, tbFurniture.nRotation);
	end

	if szData == "" then
		return;
	end

	szData = "nTemplateId\tnX\tnY\tnYaw" .. szData;

	local szFileName = string.format("ServerSetting/SampleHouse/Furniture_%d.tab", nMapTemplateId);
	local file, err = io.open(szFileName, "w");
	if not file then
		Log("[ERROR][SampleHouse] failed to write map furniture: ", szFileName, err);
		return;
	end
	file:write(szData);
	file:close();

	Log("[House] save house map furniture: ", nMapTemplateId, szFileName);
end

function House:GenerateMapFurniture(pPlayer)
	local nMapTemplateId = pPlayer.nMapTemplateId;
	local szFileName =  string.format("ServerSetting/SampleHouse/Furniture_%d.tab", nMapTemplateId);
	local tbSetting = LoadTabFile(szFileName, "dddd", nil, {"nTemplateId", "nX", "nY", "nYaw"});
	if not tbSetting then
		Log("[ERROR][House] failed to generate furniture, map furniture setting not exist:", nMapTemplateId);
		return;
	end

	for _, tbInfo in pairs(tbSetting) do
		local bRet, szMsg = Furniture:CheckCanPutFurniture(pPlayer, tbInfo.nX, tbInfo.nY, tbInfo.nYaw, tbInfo.nTemplateId);
		if not bRet then
			pPlayer.CenterMsg(szMsg);
		else
			local bRet = Furniture:AddMapFurniture(pPlayer, tbInfo.nTemplateId, tbInfo.nX, tbInfo.nY, tbInfo.nYaw);
			assert(bRet, string.format("failed to add map furniture: %d, %d, %d, %d", tbInfo.nTemplateId, tbInfo.nX, tbInfo.nY, tbInfo.nYaw));
		end
	end

	Log("[House] generate map furniture successfully!");
end

function House:GetExtComfortLevel(pPlayer)
	local nLandlordId = self:GetBetterLandlord(pPlayer);
	if not nLandlordId then
		return 0;
	end

	local dwPlayerId = pPlayer.dwID;
	if self:IsIdleOwner(dwPlayerId) or self:IsIdleOwner(nLandlordId) then
		return 0;
	end
	
	local nLevel, nRoomerComfortLevel = House:GetRoomerComfortLevel(nLandlordId, dwPlayerId);
	return nLevel - nRoomerComfortLevel, nLandlordId;
end

function House:SyncExtComfortLevel(pPlayer)
	local nExtComfortLevel, nLandlordId = House:GetExtComfortLevel(pPlayer);
	pPlayer.CallClientScript("House:OnSyncExtComfortLevel", nExtComfortLevel, nLandlordId);
end

function House:GetMuseExtAwardRatio(nMapId)
	local dwOwnerId = House:GetHouseInfoByMapId(nMapId);
	if not dwOwnerId then
		return 0;
	end

	local fAwardRatio = 0;
	local tbNpc = KNpc.GetMapNpc(nMapId);
	for _, pNpc in pairs(tbNpc) do
		local fRatio = House.tbMuseExtAwardNpc[pNpc.nTemplateId];
		if fRatio then
			fAwardRatio = fAwardRatio + fRatio;
		end
	end

	return fAwardRatio;
end

function House:GetLoverInfo(dwOwnerId)
	local nLoverId = Wedding:GetLover(dwOwnerId);
	if not nLoverId then
		return;
	end

	local tbLoverInfo = self:GetRoomerInfo({nLoverId});
	return tbLoverInfo[1];
end

function House:OnMarry(pPlayer, pLover)
	local dwPlayerId = pPlayer.dwID;
	local dwLoverId = pLover.dwID;
	self:CheckOut(dwPlayerId, dwLoverId);
	self:CheckOut(dwLoverId, dwPlayerId);

	self:SyncRoomer(dwPlayerId);
	self:SyncRoomer(dwLoverId);

	self:SyncLoverHouse(pPlayer);
	self:SyncLoverHouse(pLover);
end

function House:OnDivorce(dwPlayerId, dwLoverId)
	local pPlayer = KPlayer.GetPlayerObjById(dwPlayerId);
	local pLover = KPlayer.GetPlayerObjById(dwLoverId);
	local fnRemoveFurniture = function (dwOwnerId)
		for nTemplateId, nCount in pairs(Wedding.tbWeddingFurniture) do
			Furniture:RemoveMapFurnitureTemplate(dwOwnerId, nTemplateId, nCount);
		end
	end

	if self:IsIdleOwner(dwPlayerId) then
		self:RequestLoadHouse(dwPlayerId, -dwLoverId, function ()
			fnRemoveFurniture(dwPlayerId);
		end);
	else
		fnRemoveFurniture(dwPlayerId);
	end

	if self:IsIdleOwner(dwLoverId) then
		self:RequestLoadHouse(dwLoverId, -dwPlayerId, function ()
			fnRemoveFurniture(dwLoverId);
		end);
	else
		fnRemoveFurniture(dwLoverId);
	end

	self:SyncRoomer(dwPlayerId);
	self:SyncRoomer(dwLoverId);

	if pPlayer then
		self:SyncLoverHouse(pPlayer);
		pPlayer.CallClientScript("House:OnCheckOut", dwLoverId);
		pPlayer.CallClientScript("House:ExitDecorationMode");
		Decoration:DoSyncMapDecoration(pPlayer);
	end

	if pLover then
		self:SyncLoverHouse(pLover);
		pLover.CallClientScript("House:OnCheckOut", dwPlayerId);
		pLover.CallClientScript("House:ExitDecorationMode");
		Decoration:DoSyncMapDecoration(pLover);
	end
end

function House:GetBetterLandlord(pPlayer)
	local dwBetterId = nil;
	local tbComfort = nil;
	local dwPlayerId = pPlayer.dwID;
	local nLandlordId = House:GetValidLandlord(pPlayer);
	if nLandlordId then
		dwBetterId = nLandlordId;
		tbComfort = self:GetRoomerComfortSetting(nLandlordId, dwPlayerId);
	end

	local dwLoverId = Wedding:GetLover(dwPlayerId);
	if dwLoverId then
		local tbLoverComfort = self:GetRoomerComfortSetting(dwLoverId, dwPlayerId);
		if tbLoverComfort and (not tbComfort or tbComfort.nLevel < tbLoverComfort.nLevel) then
			dwBetterId = dwLoverId;
			tbComfort = tbLoverComfort;
		end
	end

	return dwBetterId, tbComfort;
end

function House:SyncLoverHouse(pPlayer)
	local bHasHouse = false;
	local dwPlayerId = pPlayer.dwID;
	local dwLoverId = Wedding:GetLover(dwPlayerId);
	if dwLoverId then
		local tbRole = KPlayer.GetRoleStayInfo(dwLoverId);
		bHasHouse = tbRole and tbRole.nHouseState == 1 or false;
	end
	pPlayer.CallClientScript("House:OnSyncLoverHouse", bHasHouse);
end

function House:OnLoadFriendDataFinish(pPlayer)
	self:SyncLoverHouse(pPlayer);
end
