

local tbRealtimeReportType = {
	OnLine = 1;
	Login = 2;
	Custom = 3;
	Pay = 4;
}

Transmit.tbReportOnline = {
	gamename = "jxft";
	os = "other";
	dbname = tostring(GetServerIdentity()) ;
	online_num = 0;
	online_time = "2015-03-09 15:00:00";
}

Transmit.tbBroadCastList = Transmit.tbBroadCastList or {}
Transmit.nMaxBroadCastId = Transmit.nMaxBroadCastId or 0

Transmit.SaveName =
{
	IDIPInterfaceAuction = "IDIPInterfaceAuction",
}

Transmit.szNewMsgPrefix = "GM_IF_"
Transmit.nNewMsgPrefix  = 6

function Transmit:ReportOnlinePlayers()
	local nOnlineCount = GetOnlinePlayerCount();
	self.tbReportOnline.online_num = nOnlineCount;
	self.tbReportOnline.online_time = os.date("%Y-%m-%d %H:%M:%S");

	Log("Online Player Count:", nOnlineCount, "ServerId:", tostring(GetServerIdentity()));
	Server:UpdatePCU7(nOnlineCount);
	-- local szReport = Lib:EncodeJson(self.tbReportOnline);
	-- DoRealTimeReportReq(tbRealtimeReportType.OnLine, szReport);
	return true;
end

function Transmit:OnServerStart()
	-- 每5分钟向数据中心上报一次在线人数
	Timer:Register(Env.GAME_FPS * 5 * 60, self.ReportOnlinePlayers, self);
	Transmit.tbIDIPInterface.tbAuction = ScriptData:GetValue(Transmit.SaveName.IDIPInterfaceAuction)							-- 指令拍卖物品
	Transmit.tbIDIPInterface.tbAuction.tbAuctionItem = Transmit.tbIDIPInterface.tbAuction.tbAuctionItem or {}
	Transmit.tbIDIPInterface.tbAuction.tbUpItem = Transmit.tbIDIPInterface.tbAuction.tbUpItem or {}
end


Transmit.tbReportLogin = {
	gamename = "jxft";
	os = "other";
	dbname = tostring(GetServerIdentity()) ;
	channelcode = "pc";
	accountid = "accountid";
	equdid = "ime...";
	stat_time = "2015-03-09 15:00:00";
	roleid = "111";
	rolename = "啦啦";
	mobilemodel = "null";
};

function Transmit:ReportLogin(player)
	-- if player.szChannelCode == "" then
	-- 	return;
	-- end

	-- self.tbReportLogin.accountid   = player.szAccount;
	-- self.tbReportLogin.equdid      = player.szEquipId;
	-- self.tbReportLogin.stat_time   = os.date("%Y-%m-%d %H:%M:%S");
	-- self.tbReportLogin.roleid      = tostring(player.dwID);
	-- self.tbReportLogin.rolename    = player.szName;
	-- self.tbReportLogin.channelcode = player.szChannelCode;

	-- local szReport = Lib:EncodeJson(self.tbReportLogin);
	-- DoRealTimeReportReq(tbRealtimeReportType.Login, szReport);
end


Transmit.tbReportUseCodeAward = {
	gamename = "jxft";
	os = "other";
	channelcode = "pc";
	accountid = "";
	equdid = "";
	dbname = tostring(GetServerIdentity()) ;
	stat_time = "2015-03-09 15:00:00";
	roleid = "111";
	msg = "code; type";
	eventid = 10001; -- 激活码自定义事件id
};

function Transmit:ReportUseCodeAward(dwRoleId, szCode, szType, szChannelCode, szAccount, szEquipId)
	-- self.tbReportUseCodeAward.msg = string.format("%s; %s", szCode, szType)
	-- self.tbReportUseCodeAward.roleid = tostring(dwRoleId)
	-- self.tbReportUseCodeAward.stat_time = os.date("%Y-%m-%d %H:%M:%S");
	-- self.tbReportUseCodeAward.channelcode = szChannelCode;
	-- self.tbReportUseCodeAward.accountid = szAccount
	-- self.tbReportUseCodeAward.equdid = szEquipId

	-- local szReport = Lib:EncodeJson(self.tbReportUseCodeAward);
	-- DoRealTimeReportReq(tbRealtimeReportType.Custom, szReport);
end

Transmit.tbGMInterface = Transmit.tbGMInterface or {};
local tbGMInterface = Transmit.tbGMInterface;

tbGMInterface.tbMsgTimer = tbGMInterface.tbMsgTimer or {nTimerCount = 0,tbAllTimer = {}} 				-- 公告

function Transmit:GMOpRequest(szJson, nCmdSequence)
	local tbOperations = Lib:DecodeJson(szJson);

	Log("=====GMOpRequest=====")
	Lib:LogTB(tbOperations);

	local tbResult = nil

	if tbGMInterface[tbOperations.action] then
		tbResult = tbGMInterface[tbOperations.action](tbGMInterface, tbOperations, nCmdSequence);
	else
		Log("ERROR:Unkown GM cmd", tbOperations.action);
	end

	if tbResult then
		local szRet = Lib:EncodeJson(tbResult);
		Log("Result:", szRet);
		GmOperateRespond(szRet, nCmdSequence);
	end
end

function Transmit:GenBroadCastId()
	self.nMaxBroadCastId = self.nMaxBroadCastId + 1
	return self.nMaxBroadCastId;
end

function Transmit:GetCost(pPlayer,szType,nCost)
	local nOrg = pPlayer.GetMoney(szType)
	if nOrg >= 0 and nOrg < math.abs(nCost) then
		return nOrg;
	end
	return math.abs(nCost);
end

function tbGMInterface:GMCode(tbOperations)
	local tbResult = {
		code = 1;
		msg = "Operation Failed";
	}

	Log("Run GM Code:", tbOperations.content or "");
	local fnOp, szRet, bOpSucces;
	fnOp, szRet = loadstring(tbOperations.content or "");
	if fnOp then
		bOpSucces, szRet = Lib:CallBack({fnOp});
		if bOpSucces then
			tbResult.code = 0
			tbResult.msg = szRet or "Operation succesed";
		elseif szRet then
			tbResult.msg = szRet;
		end
	else
		Log("Unkown GMCode:", szRet);
	end

	return tbResult;
end

function tbGMInterface:SendWorldNotify(tbOperations)
	local tbResult = {
		code = 1;
		msg = "Operation Failed";
	}

	if not tbOperations.content or tbOperations.content == "" then
		tbResult.msg = "fail: no notify"
		return tbResult;
	end

	local nNow = GetTime();
	local nBeginTime = Lib:ParseDateTime(tbOperations.beginTime or "") or nNow;
	local nEndTime = Lib:ParseDateTime(tbOperations.expireTime or "");
	local nLoopTime = tonumber(tbOperations.loopTime);
	local nMsgId = tonumber(tbOperations.msgId);

	if not nMsgId then
		tbResult.msg = "fail: illegal msg id"
		return tbResult;
	end

	if self.tbMsgTimer.tbAllTimer[nMsgId] then
		tbResult.msg = "fail: exist msg id"
		return tbResult;
	end

	if not nLoopTime or not nEndTime then
		tbResult.msg = "fail: not nLoopTime or nEndTime"
		return tbResult;
	end

	if nNow > nEndTime then
		tbResult.msg = "fail: out of time";
		return tbResult;
	end

	local nTimerId

	local fnSendNotify = function ()
		local nCurTime = GetTime();
		if nCurTime > nEndTime then
			if not self:CloseMsgTimer(nMsgId) then
				Log("[tbIDIPInterface] CloseMsgTimer fail",nTimerId,nMsgId,nBeginTime,nEndTime,nLoopTime,nNow)
			else
				Log("[tbIDIPInterface] CloseMsgTimer overdue",nTimerId,nMsgId,nBeginTime,nEndTime,nLoopTime,nNow)
			end
			return false;
		end

		KPlayer.SendWorldNotify(1, 999, tbOperations.content, 1, 1);
		return true;
	end

	self.tbMsgTimer.tbAllTimer[nMsgId] = {}
	self.tbMsgTimer.tbAllTimer[nMsgId].nBeginTime = nBeginTime
	self.tbMsgTimer.tbAllTimer[nMsgId].nEndTime = nEndTime
	self.tbMsgTimer.tbAllTimer[nMsgId].nLoopTime = nLoopTime
	self.tbMsgTimer.tbAllTimer[nMsgId].szMsgContent = tbOperations.content
	self.tbMsgTimer.nTimerCount = self.tbMsgTimer.nTimerCount + 1

	local fnBeginSendNotify = function ()
		if fnSendNotify() then
			-- 循环触发的Timer ID（如果触发之前把第一次出发的Timer停止了，就不会进来这里，所以self.tbMsgTimer.tbAllTimer[nMsgId]不会为空）
			nTimerId = Timer:Register(Env.GAME_FPS * nLoopTime, fnSendNotify);
			self.tbMsgTimer.tbAllTimer[nMsgId].nTimerId = nTimerId
		end
		return false;
	end

	if nNow >= nBeginTime then
		fnBeginSendNotify();
	else
		nTimerId = Timer:Register(Env.GAME_FPS * (nBeginTime - nNow), fnBeginSendNotify);
		self.tbMsgTimer.tbAllTimer[nMsgId].nTimerId = nTimerId  				-- 第一次触发的Timer ID
	end

	tbResult.code = 0
	tbResult.msg = "SendWorldNotify succesed,"
	Log("[tbGMInterface] SendWorldNotify succesed",nTimerId or "wait",nMsgId,nBeginTime,nEndTime,nLoopTime,nNow)
	return tbResult
end

function tbGMInterface:StopWorldNotice(tbOperations)
	local tbResult = {
		code = 1;
		msg = "Operation Failed";
	}

	local nMsgId = tonumber(tbOperations.msgId);

	if not nMsgId then
		tbResult.msg = "fail: illegal msg id"
		return tbResult;
	end

	if not self.tbMsgTimer.tbAllTimer[nMsgId] then
		tbResult.msg = "fail: no exist msg id"
		return tbResult;
	end

	if not self:CloseMsgTimer(nMsgId) then
		tbResult.msg = "fail: CloseMsgTimer fail"
		return tbResult;
	end

	tbResult.code = 0
	tbResult.msg = "StopWorldNotice succesed,"

	Log("[tbGMInterface] StopWorldNotice succesed",nMsgId)

	return tbResult
end

function tbGMInterface:CloseMsgTimer(nMsgId)
	if not nMsgId then
		Log("[tbIDIPInterface] CloseMsgTimer no msg id")
		return
	end
	if self.tbMsgTimer.tbAllTimer[nMsgId] then
		local nTimerId = self.tbMsgTimer.tbAllTimer[nMsgId].nTimerId
		if not nTimerId then
			Log("[tbIDIPInterface] CloseMsgTimer no timer id")
			return
		end
		Timer:Close(nTimerId);
		self.tbMsgTimer.nTimerCount = self.tbMsgTimer.nTimerCount - 1
		self.tbMsgTimer.tbAllTimer[nMsgId] = nil
	else
		Log("[tbIDIPInterface] CloseMsgTimer no timer msg")
		return false
	end

	return true
end

function tbGMInterface:SendGlobalMail(tbOperations)
	local tbResult = {
		code = 1;
		msg = "Operation Failed";
	}

	if Lib:IsEmptyStr(tbOperations.zoneId)
		or Lib:IsEmptyStr(tbOperations.title)
		or Lib:IsEmptyStr(tbOperations.content)
		or Lib:IsEmptyStr(tbOperations.sender)
		then
		tbResult.msg = "fail: lack of param";
		return tbResult;
	end

	local tbAttach = {};
	for szItemInfo in string.gmatch(tbOperations.attach, "%w+,%d+") do
		local szItem, nCount = string.match(szItemInfo, "(%w+),(%d+)");
		nCount = tonumber(nCount) or 0;

		if Player.AwardType[szItem] and nCount > 0 then
			table.insert(tbAttach, {szItem, nCount});
		end
	end

	for szItemInfo in string.gmatch(tbOperations.attach_item, "%w+,%d+") do
		local szItem, nCount = string.match(szItemInfo, "(%w+),(%d+)");
		nCount = tonumber(nCount) or 0;
		local nItemId = tonumber(szItem);
		if nItemId then
			table.insert(tbAttach, {"item", nItemId, nCount});
		end
	end

	local tbMail = {
		Title = tbOperations.title;
		Text = tbOperations.content;
		From = tbOperations.sender;
		tbAttach = tbAttach;
		LevelLimit = tonumber(tbOperations.level) or 0;
		nLogReazon = Env.LogWay_GMGlobalMail;
	};

	Mail:SendGlobalSystemMail(tbMail);

	tbResult.code = 0
	tbResult.msg = "SendMail succesed";

	TLog("GM_WEB", 0, "", 0, 0, "", "", 0, 0,
		0, 0, 0, "GLOBAL_MAIL", tbOperations.attach, tbOperations.attach_item)

	return tbResult
end

function tbGMInterface:SendPlayerMail(tbOperations)

	local tbResult = {
		code = 1;
		msg = "Operation Failed";
	}

	if Lib:IsEmptyStr(tbOperations.roleId)
		or Lib:IsEmptyStr(tbOperations.zoneId)
		or Lib:IsEmptyStr(tbOperations.title)
		or Lib:IsEmptyStr(tbOperations.content)
		--or Lib:IsEmptyStr(tbOperations.sender)
		then
		tbResult.msg = "fail: lack of param";
		return tbResult;
	end

	local tbAttach = {};
	for szItemInfo in string.gmatch(tbOperations.attach, "%w+,%d+") do
		local szItem, nCount = string.match(szItemInfo, "(%w+),(%d+)");
		nCount = tonumber(nCount) or 0;

		if Player.AwardType[szItem] and nCount > 0 then
			table.insert(tbAttach, {szItem, nCount});
		end
	end

	for szItemInfo in string.gmatch(tbOperations.attach_item, "%w+,%d+") do
		local szItem, nCount = string.match(szItemInfo, "(%w+),(%d+)");
		nCount = tonumber(nCount) or 0;
		local nItemId = tonumber(szItem);
		if nItemId then
			table.insert(tbAttach, {"item", nItemId, nCount});
		end
	end

	local tbMail = {
		To = nil;
		Title = tbOperations.title;
		Text = tbOperations.content;
		From = XT("系統");
		tbAttach = tbAttach;
		nLogReazon = Env.LogWay_GMPersonMail;
	};

	local tbPlayers = Lib:SplitStr(tbOperations.roleId, ",");
	for _, szPlayerId in pairs(tbPlayers) do
		local nPlayerId = tonumber(szPlayerId);
		if nPlayerId then
			tbMail.To = nPlayerId;
			Mail:SendSystemMail(tbMail);
		end
	end

	tbResult.code = 0
	tbResult.msg = "SendMail succesed";

	TLog("GM_WEB", 0, "", 0, 0, "", "", 0, 0,
		0, 0, 0, "PLAYER_MAIL", tbOperations.roleId, tbOperations.attach, tbOperations.attach_item)

	return tbResult
end

function tbGMInterface:PayToPlayer(tbOperations)
	local nPlayerId = tonumber(tbOperations.roleId) or 0;
	local bRet, szErr = Recharge:DirPayBack(nPlayerId, tbOperations.productId);

	Log("GMPay", "", tbOperations.roleid, tbOperations.productId, bRet, szErr);

	return bRet and "Charge succesed" or szErr;
end

function tbGMInterface:QueryRoleInfo(tbOperations, nCmdSequence)
	local tbResult = {
		code = 1;
		msg =
		{
			meta =
			{
				RoleName = "角色名";
				Diamond = "元寶";
				Money = "銀兩";
				Vip = "Vip";
				VipExp = "VipExp";
				Level = "等級";
				KinId = "幫派ID";
				Ranking = "戰力排名";
				RegisterTime = "創建時間";
				TotalLoginTime = "遊戲時間";
				LastLogoutTime = "最後登出時間";
				IsLogin = "是否線上";
				Contribute = "貢獻";
				CurTitle = "當前稱號";
				HonorTitle = "頭銜";
				Faction = "門派";
				FightPower = "戰力";
				TitleNum = "稱號數量";
				PortraitIcoinId = "頭像";
				Account = "賬號";
				RoleId  = "角色ID";
			};

			totalPage = 1;
		};
	};

	local nRoleId = tonumber(tbOperations.where.RoleId)

	if (not nRoleId or nRoleId == 0) and tbOperations.where.RoleName then
		local tbStayInfo = KPlayer.GetRoleStayInfo(tbOperations.where.RoleName);
		nRoleId = tbStayInfo and tbStayInfo.dwID
	end

	if nRoleId then
		local pPlayer = KPlayer.GetPlayerObjById(nRoleId);
		if pPlayer then
			tbResult.code = 0;
			tbResult.msg.data = {
				{
					Diamond = pPlayer.GetMoney("Gold") - pPlayer.GetMoneyDebt("Gold");
					Money = pPlayer.GetMoney("Coin");
					Vip = pPlayer.GetVipLevel();
					VipExp = Recharge:GetTotoalRecharge(pPlayer);
					Level = pPlayer.nLevel;
					KinId = pPlayer.dwKinId;
					Ranking = -1;
					RegisterTime = Lib:TimeDesc9(pPlayer.dwCreateTime);
					TotalLoginTime = Lib:TimeDesc8(pPlayer.dwGameTime);
					LastLogoutTime = Lib:TimeDesc9(GetTime());
					IsLogin = 1;
					Contribute = pPlayer.GetMoney("Contrib");
					CurTitle = "";
					HonorTitle = "";
					Faction = pPlayer.nFaction;
					FightPower = pPlayer.GetFightPower();
					TitleNum = 0;
					PortraitIcoinId = pPlayer.nPortrait;
					RoleName = pPlayer.szName;
					Account = pPlayer.szAccount;
					RoleId = nRoleId;
				};
			}

			local tbData = tbResult.msg.data[1];

			local pRank = KRank.GetRankBoard("FightPower")
			if pRank then
				local tbInfo = pRank.GetRankInfoByID(pPlayer.dwID)
				if tbInfo then
					tbData.Ranking = tbInfo.nPosition or -1
				end
			end

			local tbHonorInfo = Player.tbHonorLevel:GetHonorLevelInfo(pPlayer.nHonorLevel)
			if not tbHonorInfo then
				tbData.HonorTitle = "";
			else
				tbData.HonorTitle = string.format("%d%s",pPlayer.nHonorLevel,tbHonorInfo.Name);
			end

			local tbTitleData = PlayerTitle:GetPlayerTitleData(pPlayer)
			local tbAllTitle = tbTitleData.tbAllTitle or {}
			local nActivateTitle = tbTitleData.nActivateTitle or 0;

			local tbTitleInfo = PlayerTitle:GetTitleTemplate(nActivateTitle);
			if not tbTitleInfo then
				tbData.CurTitle = "";
			else
				tbData.CurTitle = string.format("%d%s",nActivateTitle,tbTitleInfo.Name);
			end

			tbData.TitleNum = Lib:CountTB(tbAllTitle)

			return tbResult
		else
			--不在线

			Player:DoPlayerQueryInfoRequest(nRoleId, Transmit.tbGMInterface.OnDelayQueryRoleInfo, Transmit.tbGMInterface,nCmdSequence)

			return nil
		end
	end

	return tbResult;
end

function tbGMInterface:OnDelayQueryRoleInfo(tbQueryInfo, nCmdSequence)
	local tbResult = {
		code = 1;
		msg =
		{
			meta =
			{
				RoleName = "角色名";
				Diamond = "元寶";
				Money = "銀兩";
				Vip = "Vip";
				VipExp = "VipExp";
				Level = "等級";
				KinId = "幫派ID";
				Ranking = "戰力排名";
				RegisterTime = "創建時間";
				TotalLoginTime = "遊戲時間";
				LastLogoutTime = "最後登出時間";
				IsOnline = "是否線上";
				IsLogin = "今日是否登錄";
				Contribute = "貢獻";
				CurTitle = "當前稱號";
				HonorTitle = "頭銜";
				Faction = "門派";
				FightPower = "戰力";
				TitleNum = "稱號數量";
				PortraitIcoinId = "頭像";
				Account = "賬號";
				RoleId  = "角色ID";
			};

			totalPage = 1;
		};
	};

	if tbQueryInfo and next(tbQueryInfo) then

		local pPlayerInfo = KPlayer.GetRoleStayInfo(tbQueryInfo.dwID);
		tbResult.code = 0;
		tbResult.msg.data = {
			{
				Diamond = tbQueryInfo.nGold;
				Money = tbQueryInfo.nCoin;
				Vip = tbQueryInfo.nVipLevel;
				VipExp = tbQueryInfo.nTotalCharge;
				Level = tbQueryInfo.nLevel;
				KinId = tbQueryInfo.dwKinId;
				Ranking = tbQueryInfo.nFightPowerRank;
				RegisterTime = Lib:TimeDesc9(tbQueryInfo.dwCreateTime);
				TotalLoginTime = Lib:TimeDesc8(tbQueryInfo.dwGameTime);
				LastLogoutTime = Lib:TimeDesc9(tbQueryInfo.dwLastLogoutTime);
				IsOnline = 0;
				IsLogin = 0;
				Contribute = tbQueryInfo.nContrib;
				CurTitle = "";
				HonorTitle = "";
				Faction = pPlayerInfo.nFaction;
				FightPower = tbQueryInfo.nFightPower;
				TitleNum = 0;
				PortraitIcoinId = pPlayerInfo.nPortrait;
				RoleName = pPlayerInfo.szName;
				Account = tbQueryInfo.szAccount;
				RoleId = tbQueryInfo.dwID;
			};
		}

		local tbData = tbResult.msg.data[1];

		local tbHonorInfo = Player.tbHonorLevel:GetHonorLevelInfo(tbQueryInfo.nHonorLevel)
		if not tbHonorInfo then
			tbData.HonorTitle = "";
		else
			tbData.HonorTitle = string.format("%d%s",tbQueryInfo.nHonorLevel,tbHonorInfo.Name);
		end

		local pPlayer = KPlayer.GetPlayerObjById(tbQueryInfo.dwID);
		if pPlayer then
			tbData.IsOnline = 1
		end

		local tbTitleInfo = PlayerTitle:GetTitleTemplate(tbQueryInfo.nActiveTitleId);
		if not tbTitleInfo then
			tbData.CurTitle = "";
		else
			tbData.CurTitle = string.format("%d%s",tbQueryInfo.nActiveTitleId,tbTitleInfo.Name);
		end

		local tbAllTitle = tbQueryInfo.tbTitleList or {}
		tbData.TitleNum = Lib:CountTB(tbAllTitle)

		local nLastOnlineTime = pPlayerInfo.nLastOnlineTime or 0
		if Lib:GetLocalDay(nLastOnlineTime) == Lib:GetLocalDay() then
			tbData.IsLogin = 1
		end
	end

	local szRet = Lib:EncodeJson(tbResult);
	Log("OnDelayQueryRoleInfo:", szRet);
	GmOperateRespond(szRet, nCmdSequence);
end

function tbGMInterface:QueryRoleList(tbOperations, nCmdSequence)
	Player:DoAccountRoleListRequest(tbOperations.where.Account, Transmit.tbGMInterface.OnDelayQueryRoleList, Transmit.tbGMInterface, nCmdSequence)
end

function tbGMInterface:OnDelayQueryRoleList(szAccount,tbRoleList,nCmdSequence)
	local tbResult = {
		code = 1;
		msg =
		{
			meta =
			{
				RoleId = "角色ID";
				RoleName = "角色名";
				BanStatus = "封停狀態";
			};

			data = {};

			totalPage = 1;
		};
	};

	local tbDataList = tbResult.msg.data;

	for _,info in pairs(tbRoleList) do
		local tbInfo =
		{
			RoleId = info.dwID;
			RoleName = info.szName;
			BanStatus = 1;
		}
		local nBanTime = info.nBanEndTime
		if nBanTime == 0 or (nBanTime > 0 and nBanTime < GetTime()) then
			tbInfo.BanStatus = 0
		end

		table.insert(tbDataList, tbInfo);
	end
	tbResult.code = 0

	local szRet = Lib:EncodeJson(tbResult);
	Log("OnDelayQueryRoleList:", szRet);
	GmOperateRespond(szRet, nCmdSequence);
end

function tbGMInterface:QueryPartnerInfo(tbOperations, nCmdSequence)
	local tbResult = {
		code = 1;
		msg =
		{
			meta =
			{
				PartnerName = "同伴名";
				PartnerId = "同伴ID";
				Level = "等級";
				Quality = "品質";
			};

			data = {};

			totalPage = 1;
		};
	};

	local tbDataList = tbResult.msg.data;

	local nPage = tonumber(tbOperations.page) or 1
	local nNumPerPage = tonumber(tbOperations.perpage) or 20

	local nRoleId = tonumber(tbOperations.where.RoleId)

	if (not nRoleId or nRoleId == 0) and tbOperations.where.RoleName then
		local tbStayInfo = KPlayer.GetRoleStayInfo(tbOperations.where.RoleName);
		nRoleId = tbStayInfo and tbStayInfo.dwID
	end

	if nRoleId then
		local pPlayer = KPlayer.GetPlayerObjById(nRoleId);
		if pPlayer then
			tbResult.code = 0;

			local tbAllPartner = pPlayer.GetAllPartner() or {}
			local tbSortPartner = {}
			for _,tbInfo in pairs(tbAllPartner) do
				table.insert(tbSortPartner,tbInfo)
			end

			if next(tbSortPartner) then

				tbResult.msg.totalPage = math.ceil(#tbSortPartner/nNumPerPage)
				local nStartNum = (nPage - 1) * nNumPerPage + 1
				local nEndNum = nPage * nNumPerPage

				for nNum=nStartNum,nEndNum do
					if not tbSortPartner[nNum] then
						break;
					else
						local tbPartner = {}
						local tbInfo = tbSortPartner[nNum]

						local nQuality = tbInfo.nQualityLevel;

						tbPartner.PartnerId = tbInfo.nTemplateId;
						tbPartner.PartnerName = tbInfo.szName or "";
						tbPartner.Level = tbInfo.nLevel;
						if version_tx then
							tbPartner.Quality = Partner.tbQualityLevelDes_Old[nQuality] or "";
						else
							tbPartner.Quality = Partner.tbQualityLevelDes[nQuality] or "";
						end

						table.insert(tbDataList, tbPartner);
					end
				end
			end

			return tbResult
		else
			--不在线

			Player:DoPlayerQueryInfoRequest(nRoleId, Transmit.tbGMInterface.OnDelayQueryPartnerInfo, Transmit.tbGMInterface, nPage, nNumPerPage, nCmdSequence)

			return nil
		end
	end

	return tbResult;
end

function tbGMInterface:OnDelayQueryPartnerInfo(tbQueryInfo, nPage, nNumPerPage, nCmdSequence)
	local tbResult = {
		code = 1;
		msg =
		{
			meta =
			{
				PartnerName = "同伴名";
				PartnerId = "同伴ID";
				Level = "等級";
				Quality = "品質";
			};

			data = {};

			totalPage = 1;
		};
	};

	local tbDataList = tbResult.msg.data;

	if tbQueryInfo and next(tbQueryInfo.tbPartnerList) then

		local tbAllPartnerInfo = Partner:GetAllPartnerBaseInfo();

		tbResult.msg.totalPage = math.ceil(#(tbQueryInfo.tbPartnerList)/nNumPerPage)
		local nStartNum = (nPage - 1) * nNumPerPage + 1
		local nEndNum = nPage * nNumPerPage

		for nNum=nStartNum,nEndNum do
			if not tbQueryInfo.tbPartnerList[nNum] then
				break;
			else
				local tbPartner = {}
				local tbInfo = tbQueryInfo.tbPartnerList[nNum]
				local tbBaseInfo = tbAllPartnerInfo[tbInfo.nId] or {};
				local nQuality = tbBaseInfo.nQualityLevel;

				tbPartner.PartnerId = tbInfo.nId;
				tbPartner.PartnerName = tbBaseInfo.szName or "";
				tbPartner.Level = tbInfo.nLevel;
				if version_tx then
					tbPartner.Quality = Partner.tbQualityLevelDes_Old[nQuality] or "";
				else
					tbPartner.Quality = Partner.tbQualityLevelDes[nQuality] or "";
				end

				table.insert(tbDataList, tbPartner);
			end
		end
	end

	local szRet = Lib:EncodeJson(tbResult);
	Log("OnDelayQueryPartnerInfo:", szRet);
	GmOperateRespond(szRet, nCmdSequence);
end

function tbGMInterface:QueryRoleKinInfo(tbOperations, nCmdSequence)
	local tbResult = {
		code = 1;
		msg =
		{
			meta =
			{
				KinId = "幫派ID",
				KinName = "幫派名",
				KinLevel = "等級",
				Leader = "總堂主",
				LeaderId = "領袖ID",
				Master = "堂主",
				MasterId = "族長ID",
				Notice = "幫派公告",
				Declare = "幫派宣言",
				CreateTime = "創建時間",
				Prestige = "威望",
				Fund = "建設資金",
				MemberNum = "成員數量",
				PreMemberNum = "小弟數量",
				Rank = "幫派排名",
				KinFightPower = "幫派總戰力",
			};

			totalPage = 1;
		};
	};

	local nRoleId = tonumber(tbOperations.where.RoleId)

	if (not nRoleId or nRoleId == 0) and tbOperations.where.RoleName then
		local tbStayInfo = KPlayer.GetRoleStayInfo(tbOperations.where.RoleName);
		nRoleId = tbStayInfo and tbStayInfo.dwID
	end

	local tbMemberData = Kin:GetMemberData(nRoleId)
	local nKinId = tbMemberData and tbMemberData.nKinId or 0
	local tbKinData = Kin:GetKinById(nKinId)

	if tbKinData then
		tbResult.code = 0;
		tbResult.msg.data = {
			{

				KinId = tbKinData.nKinId,
				KinName = tbKinData.szName,
				KinLevel = tbKinData:GetLevel(),
				Leader = "",
				LeaderId = tbKinData.nLeaderId,
				Master = "",
				MasterId = tbKinData.nMasterId,
				Notice = tbKinData.szPublicDeclare,
				Declare = tbKinData.tbRecruitSetting.szAddDeclare,
				CreateTime = tostring(tbKinData.nCreateTime),
				Prestige = tbKinData.nPrestige,
				Fund = tbKinData.nFound,
				MemberNum = tbKinData:GetMemberCount(),
				PreMemberNum = tbKinData:GetCareerMemberCount(Kin.Def.Career_New),
				Rank = 0,
				KinFightPower = 0,
			};
		}

		local tbData = tbResult.msg.data[1];

		local pLeaderPlayer = KPlayer.GetPlayerObjById(tbKinData.nLeaderId) or KPlayer.GetRoleStayInfo(tbKinData.nLeaderId);
		tbData.Leader = pLeaderPlayer and pLeaderPlayer.szName or ""

		local pMasterPlayer = KPlayer.GetPlayerObjById(tbKinData.nMasterId) or KPlayer.GetRoleStayInfo(tbKinData.nMasterId);
		tbData.Master = pMasterPlayer and pMasterPlayer.szName or ""

		local pRank = KRank.GetRankBoard("kin")
		if pRank then
			 local tbInfo = pRank.GetRankInfoByID(nKinId)
			 tbData.FamilyRank = tbInfo and tbInfo.nPosition or 0
		end
		local tbMembers = tbKinData.tbMembers or {}
		for dwID,_ in pairs(tbMembers) do
			local pAsyncData = KPlayer.GetAsyncData(dwID)
			if pAsyncData then
				tbData.KinFightPower = tbData.KinFightPower + pAsyncData.GetFightPower()
			else
				Log("[tbGMInterface] QueryRoleKinInfo no pAsyncData",dwID)
			end
		end

		return tbResult
	end

	return tbResult;
end

function tbGMInterface:QueryTitleInfo(tbOperations, nCmdSequence)
	local tbResult = {
		code = 1;
		msg =
		{
			meta =
			{
				Id = "稱號ID";
				Name = "稱號名";
			};

			data = {};

			totalPage = 1;
		};
	};

	local tbDataList = tbResult.msg.data;

	local nPage = tonumber(tbOperations.page) or 1
	local nNumPerPage = tonumber(tbOperations.perpage) or 20

	local nRoleId = tonumber(tbOperations.where.RoleId)

	if (not nRoleId or nRoleId == 0) and tbOperations.where.RoleName then
		local tbStayInfo = KPlayer.GetRoleStayInfo(tbOperations.where.RoleName);
		nRoleId = tbStayInfo and tbStayInfo.dwID
	end

	if nRoleId then
		local pPlayer = KPlayer.GetPlayerObjById(nRoleId);
		if pPlayer then
			tbResult.code = 0;

			local tbTitleData = PlayerTitle:GetPlayerTitleData(pPlayer)
			local tbTempAllTitle = tbTitleData.tbAllTitle or {}

			if next(tbTempAllTitle) then

				local tbAllTitle = {}

				for _,tbTitle in pairs(tbTempAllTitle) do
					table.insert(tbAllTitle, tbTitle)
				end

				tbResult.msg.totalPage = math.ceil(#tbAllTitle/nNumPerPage)
				local nStartNum = (nPage - 1) * nNumPerPage + 1
				local nEndNum = nPage * nNumPerPage
				for nNum=nStartNum,nEndNum do
					if not tbAllTitle[nNum] then
						break;
					end

					local nId = tbAllTitle[nNum].nTitleID
					local tbTitleTemp = PlayerTitle:GetTitleTemplate(nId);
					local tbTitleData =
					{
						Id = nId,
						Name = tbTitleTemp and tbTitleTemp.Name or "",
					}

					table.insert(tbDataList, tbTitleData);
				end
			end

			return tbResult
		else
			--不在线

			Player:DoPlayerQueryInfoRequest(nRoleId, Transmit.tbGMInterface.OnDelayQueryTitleInfo, Transmit.tbGMInterface, nPage, nNumPerPage, nCmdSequence)

			return nil
		end
	end

	return tbResult;
end

function tbGMInterface:OnDelayQueryTitleInfo(tbQueryInfo, nPage, nNumPerPage, nCmdSequence)
	local tbResult = {
		code = 1;
		msg =
		{
			meta =
			{
				Id = "稱號ID";
				Name = "稱號名";
			};

			data = {};

			totalPage = 1;
		};
	};

	local tbDataList = tbResult.msg.data;

	if tbQueryInfo and next(tbQueryInfo.tbTitleList) then

		tbResult.msg.totalPage = math.ceil(#(tbQueryInfo.tbTitleList)/nNumPerPage)
		local nStartNum = (nPage - 1) * nNumPerPage + 1
		local nEndNum = nPage * nNumPerPage

		for nNum=nStartNum,nEndNum do
			if not tbQueryInfo.tbTitleList[nNum] then
				break;
			else
				local nId = tbQueryInfo.tbTitleList[nNum]
				local tbTitleTemp = PlayerTitle:GetTitleTemplate(nId);

				local tbTitleData =
				{
					Id = nId,
					Name = tbTitleTemp and tbTitleTemp.Name or "",
				}

				table.insert(tbDataList, tbTitleData);
			end
		end
	end

	local szRet = Lib:EncodeJson(tbResult);
	Log("OnDelayQueryTitleInfo:", szRet);
	GmOperateRespond(szRet, nCmdSequence);
end

function tbGMInterface:QueryRoleAccount(tbOperations, nCmdSequence)
	local tbResult = {
		code = 1;
		msg =
		{
			meta =
			{
				Account = "帳號名";
			};

			totalPage = 1;
		};
	};

	local nRoleId = tonumber(tbOperations.where.RoleId)

	if (not nRoleId or nRoleId == 0) and tbOperations.where.RoleName then
		local tbStayInfo = KPlayer.GetRoleStayInfo(tbOperations.where.RoleName);
		nRoleId = tbStayInfo and tbStayInfo.dwID
	end

	if nRoleId then
		local pPlayer = KPlayer.GetPlayerObjById(nRoleId);
		if pPlayer then
			tbResult.code = 0;
			tbResult.msg.data = {
				{
					Account = pPlayer.szAccount
				};
			}

			return tbResult
		else
			--不在线

			Player:DoPlayerQueryInfoRequest(nRoleId, Transmit.tbGMInterface.OnDelayQueryRoleAccount, Transmit.tbGMInterface,nCmdSequence)

			return nil
		end
	end

	return tbResult;
end

function tbGMInterface:OnDelayQueryRoleAccount(tbQueryInfo, nCmdSequence)
	local tbResult = {
		code = 1;
		msg =
		{
			meta =
			{
				Account = "帳號名";
			};

			totalPage = 1;
		};
	};

	if tbQueryInfo and next(tbQueryInfo) then
		tbResult.code = 0;
		tbResult.msg.data = {
			{
				Account = tbQueryInfo.szAccount;
			};
		}
	end

	local szRet = Lib:EncodeJson(tbResult);
	Log("OnDelayQueryRoleAccount:", szRet);
	GmOperateRespond(szRet, nCmdSequence);
end

function tbGMInterface:BanRole(tbOperations, nCmdSequence)
	local tbResult = {
		code = 1;
		msg = "Failed Found Role"
	};

	local szReason = tbOperations.Reason or "";
	local nTime = tonumber(tbOperations.Time) or -1;
	local nRoleId = tonumber(tbOperations.RoleId)
	local bBanRank = tbOperations.BanRank
	local tbStayInfo = KPlayer.GetRoleStayInfo(nRoleId or tbOperations.RoleName);

	if tbStayInfo then
		tbResult.code = 0;
		tbResult.msg = "Success"

		self:_BanRole(tbStayInfo.dwID, nTime, bBanRank, szReason)
	end

	return tbResult;
end

function tbGMInterface:BanRoleList(tbOperations, nCmdSequence)
	local tbResult = {
		code = 1;
		msg = "Ban Count: 0"
	};

	local szReason = tbOperations.Reason or "";
	local nTime = tonumber(tbOperations.Time) or -1;
	local bBanRank = tbOperations.BanRank
	local tbRoleList = Lib:SplitStr(tbOperations.RoleList or "")
	local nCount = 0;
	for _,szId in pairs(tbRoleList) do
		local nRoleId = tonumber(szId)
		if nRoleId and nRoleId > 0 then
			local tbStayInfo = KPlayer.GetRoleStayInfo(nRoleId);
			if tbStayInfo then
				tbResult.code = 1;
				nCount = nCount + 1
				self:_BanRole(tbStayInfo.dwID, nTime, bBanRank,  szReason)
			end
		end
	end

	tbResult.msg = string.format("Ban Count: %d", nCount)

	return tbResult;
end

function tbGMInterface:_BanRole(nPlayerId, nTime, bBanRank, szReason)
	Log("GM InterFace Ban Role", tostring(nPlayerId), tostring(nTime), tostring(bBanRank), tostring(szReason))
	szReason = szReason or ""
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId)
	if pPlayer and szReason ~= "" then
		pPlayer.CallClientScript("Ui:OnShowKickMsg", string.format(XT("此角色由於%s已被凍結"), szReason));
	end

	local bBaned = false

	if nTime > 0 then
		BanPlayer(nPlayerId,GetTime() + nTime, szReason);
		bBaned = true
	elseif nTime < 0 then
		BanPlayer(nPlayerId, nTime, szReason);
		bBaned = true
	else
		BanPlayer(nPlayerId, 0, szReason);
	end

	if bBaned and bBanRank then
		local tbStayInfo = KPlayer.GetRoleStayInfo(nPlayerId);
		-- 禁角色的同时要求下榜
		Lib:CallBack({Transmit.tbIDIPInterface.ClearAllRank,Transmit.tbIDIPInterface,nPlayerId,(tbStayInfo and tbStayInfo.nFaction) or 0});
	end
end

function tbGMInterface:ForbidChat(tbOperations, nCmdSequence)
	local tbResult = {
		code = 1;
		msg = "Failed Found Role"
	};

	local szReason = tbOperations.Reason or "";
	local nTime = tonumber(tbOperations.Time) or -1;
	local nRoleId = tonumber(tbOperations.RoleId)

	if (not nRoleId or nRoleId == 0) and tbOperations.RoleName then
		local tbStayInfo = KPlayer.GetRoleStayInfo(tbOperations.RoleName);
		nRoleId = tbStayInfo and tbStayInfo.dwID
	end

	local pAsyncData = KPlayer.GetAsyncData(nRoleId or 0)

	if pAsyncData then
		tbResult.code = 0;
		tbResult.msg = "Success"

		pAsyncData.SetChatForbidType(ChatMgr.ForbidType.All);
		pAsyncData.SetChatForbidEndTime(GetTime() + nTime);
		pAsyncData.SetChatForbidSilence(0);

		local pPlayer = KPlayer.GetPlayerObjById(nRoleId)
		if pPlayer and szReason ~= "" then
			pPlayer.MsgBox(szReason, {{"確定"}, {"取消"}})
		end
	end

	return tbResult;
end

function tbGMInterface:CostMoney(tbOperations, nCmdSequence)
	local tbResult = {
		code = 1;
		msg = "Operation Failed";
	}

	local nPlayerId = tonumber(tbOperations.RoleId)
	local nCount = tonumber(tbOperations.count)
	local nIsNegative = 0;
	if tbOperations.isNegative then
		nIsNegative = 1;
	end

	if not nPlayerId or not nCount then
		tbResult.msg = "fail: lack of param";
		return tbResult;
	end

	if nCount <= 0 then
		tbResult.msg = "fail: invalid count";
		return tbResult;
	end

	local pStayInfo = KPlayer.GetRoleStayInfo(nPlayerId);
	if not pStayInfo then
		tbResult.msg = "fail: not found role";
		return tbResult;
	end

	self:_CostMoney(nPlayerId, nCount, nIsNegative, nCmdSequence)

	tbResult.code = 0
	tbResult.msg = "Operation succesed";

	return tbResult
end

function tbGMInterface:_CostMoney(nPlayerId, nCount, nIsNegative, nCmdSequence)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		self:_DelayCostMoney(nPlayerId, nCount, nIsNegative, nCmdSequence)
		return
	end

	local nCost = Transmit:GetCost(pPlayer,"Coin",nCount);
	if nCost > 0 then
		pPlayer.CostMoney("Coin", nCost, Env.LogWay_IdipDoDelMoneyReq);
	end

	if nIsNegative == 1 and  nCount > nCost then
		Player:AddMoneyDebt(nPlayerId, "Coin", nCount - nCost, Env.LogWay_Money_Debt_Add, 0, true)
	end
end

function tbGMInterface:_DelayCostMoney(nPlayerId, nCount, nIsNegative, nCmdSequence)
	local szCmd = string.format("Transmit.tbGMInterface:_CostMoney(%u,%d,%d,%d)",nPlayerId,nCount,nIsNegative or 0,nCmdSequence)
	local szLog = string.format("%s|%d|%d|%d", 'tbGMInterface:_DelayCostMoney', nCount,nIsNegative,nCmdSequence)
	KPlayer.AddDelayCmd(nPlayerId,szCmd,szLog)
	Log("tbGMInterface:_DelayCostMoney AddDelayCmd",nPlayerId,nCount,nIsNegative,nCmdSequence,szCmd)
end

function tbGMInterface:CostGold(tbOperations, nCmdSequence)
	local tbResult = {
		code = 1;
		msg = "Operation Failed";
	}

	local nPlayerId = tonumber(tbOperations.RoleId)
	local nCount = tonumber(tbOperations.count)
	local nIsNegative = 0;
	if tbOperations.isNegative then
		nIsNegative = 1;
	end

	if not nPlayerId or not nCount then
		tbResult.msg = "fail: lack of param";
		return tbResult;
	end

	if nCount <= 0 then
		tbResult.msg = "fail: invalid count";
		return tbResult;
	end

	local pStayInfo = KPlayer.GetRoleStayInfo(nPlayerId);
	if not pStayInfo then
		tbResult.msg = "fail: not found role";
		return tbResult;
	end

	self:_CostGold(nPlayerId, nCount, nIsNegative, nCmdSequence)

	tbResult.code = 0
	tbResult.msg = "Operation succesed";

	return tbResult
end

function tbGMInterface:_CostGold(nPlayerId, nCount, nIsNegative, nCmdSequence)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		self:_DelayCostGold(nPlayerId, nCount, nIsNegative, nCmdSequence)
		return
	end

	local nCost = Transmit:GetCost(pPlayer,"Gold",nCount);
	if nCost == 0 then
		if nIsNegative == 1 then
			Player:AddMoneyDebt(nPlayerId, "Gold", math.abs(nCount), Env.LogWay_Money_Debt_Add, 0, true)
		end
		return
	end

	pPlayer.CostGold(nCost,Env.LogWay_IdipDoDelDiamondReq,nil,function (nPlayerId, bSuccess)
			if bSuccess then
				if nIsNegative == 1 and math.abs(nCount) > nCost then
					Player:AddMoneyDebt(nPlayerId, "Gold", math.abs(nCount) - nCost, Env.LogWay_Money_Debt_Add, 0, true)
				end
				Log("tbGMInterface:_CostGold success ", nPlayerId,nCount,nCost,nIsNegative);
				return true
			end
			-- 扣除失败直接加延迟指令
			self:_DelayCostMoney(nPlayerId, nCount, nIsNegative, nCmdSequence);
			Log("tbGMInterface:_CostGold fail add delay cmd", nPlayerId, nCount, nIsNegative, nCmdSequence);
			return true;
		end);
end

function tbGMInterface:_DelayCostGold(nPlayerId, nCount, nIsNegative, nCmdSequence)
	local szCmd = string.format("Transmit.tbGMInterface:_CostGold(%u,%d,%d,%d)",nPlayerId,nCount,nIsNegative or 0,nCmdSequence)
	local szLog = string.format("%s|%d|%d|%d", 'tbGMInterface:_DelayCostGold', nCount,nIsNegative,nCmdSequence)
	KPlayer.AddDelayCmd(nPlayerId,szCmd,szLog)
	Log("tbGMInterface:_DelayCostGold AddDelayCmd",nPlayerId,nCount,nIsNegative,nCmdSequence,szCmd)
end

function tbGMInterface:ReduceVip(tbOperations, nCmdSequence)
	local tbResult = {
		code = 1;
		msg = "Operation Failed";
	}

	local nPlayerId = tonumber(tbOperations.RoleId)
	local nCount = tonumber(tbOperations.count)

	if not nPlayerId or not nCount then
		tbResult.msg = "fail: lack of param";
		return tbResult;
	end

	if nCount <= 0 then
		tbResult.msg = "fail: invalid count";
		return tbResult;
	end

	local pStayInfo = KPlayer.GetRoleStayInfo(nPlayerId);
	if not pStayInfo then
		tbResult.msg = "fail: not found role";
		return tbResult;
	end

	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if pPlayer then
		self:_ReduceVip(nPlayerId, nCount, nCmdSequence)
	else
		KPlayer.AddDelayCmd(nPlayerId,
			string.format("Transmit.tbGMInterface:_ReduceVip(%d, %d, %d)",nPlayerId, nCount, nCmdSequence),
			string.format("%s|%d|%d|%d", 'tbGMInterface:ReduceVip', nPlayerId, nCount, nCmdSequence))
	end

	tbResult.code = 0
	tbResult.msg = "Operation succesed";

	return tbResult
end

function tbGMInterface:_ReduceVip(nPlayerId, nCount, nCmdSequence)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		Log("tbGMInterface:_ReduceVip can not find pPlayer",nPlayerId, nCount, nCmdSequence)
		return
	end

	pPlayer.SendAward({{"VipExp", -nCount} }, nil, nil, Env.LogWay_IdIpAddVipExp)

	Log("tbGMInterface:_ReduceVip",pPlayer.szName, nPlayerId, nCount, nCmdSequence)
end

function tbGMInterface:DelItem(tbOperations, nCmdSequence)
	local tbResult = {
		code = 1;
		msg = "Operation Failed";
	}

	local nPlayerId = tonumber(tbOperations.RoleId)
	local nItemId = tonumber(tbOperations.itemId)
	local nCount = tonumber(tbOperations.count)

	if not nPlayerId or not nCount or not nItemId then
		tbResult.msg = "fail: lack of param";
		return tbResult;
	end

	if nCount <= 0 then
		tbResult.msg = "fail: invalid count";
		return tbResult;
	end

	local bIsHaveItem = KItem.GetItemBaseProp(nItemId);
	if not bIsHaveItem then
		tbResult.msg = "fail: invalid item id";
		return tbResult;
	end

	local pStayInfo = KPlayer.GetRoleStayInfo(nPlayerId);
	if not pStayInfo then
		tbResult.msg = "fail: not found role";
		return tbResult;
	end

	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if pPlayer then
		self:_DelItem(nPlayerId, nItemId, nCount, nCmdSequence)
	else
		KPlayer.AddDelayCmd(nPlayerId,
			string.format("Transmit.tbGMInterface:_DelItem(%d, %d, %d, %d)",nPlayerId, nItemId, nCount, nCmdSequence),
			string.format("%s|%d|%d|%d|%d", 'tbGMInterface:DelItem', nPlayerId, nItemId, nCount, nCmdSequence))
	end

	tbResult.code = 0
	tbResult.msg = "Operation succesed";

	return tbResult
end

function tbGMInterface:_DelItem(nPlayerId, nItemId, nCount, nCmdSequence)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		Log("tbGMInterface:_DelItem can not find pPlayer",nPlayerId, nItemId, nCount, nCmdSequence)
		return
	end

	local nOrgCount = pPlayer.GetItemCountInAllPos(nItemId);
	local nDelCount = math.min(nOrgCount, nCount)

	pPlayer.ConsumeItemInAllPos(nItemId, nDelCount, Env.LogWay_IdipDoDelItemReq);

	Log("tbGMInterface:_DelItem", pPlayer.szName, nPlayerId, nItemId, nCount, nCmdSequence)
end

function tbGMInterface:QueryFamilyMemberInfo(tbOperations, nCmdSequence)
	local tbResult = {
		code = 1;
		msg =
		{
			meta =
			{
				RoleId = "角色ID";
				RoleName = "角色名";
				Career = "職位";
				FightPower = "戰力";
			};

			data = {};

			totalPage = 1;
		};
	};
	local tbDataList = tbResult.msg.data;

	local dwKinId =tonumber(tbOperations.where.KinId)
	if not dwKinId then
		Log("[tbGMInterface] QueryFamilyMemberInfo no KinId")
		return tbResult
	end

	local tbKinData = Kin:GetKinById(dwKinId);
	if tbKinData then
		local nLeaderId = tbKinData:GetLeaderId();
		local tbMembers = tbKinData.tbMembers
		for dwID,nCareer in pairs(tbMembers) do
			local tbTemp = {
				RoleId = dwID,
				RoleName = "-",
				Career = Kin.Def.Career_Name[nCareer] or "",
				FightPower = 0,
			};

			if nLeaderId == dwID then
				tbTemp.Career = string.format("%s-%s", tbTemp.Career, Kin.Def.Career_Name[Kin.Def.Career_Leader])
			end

			local pPlayer = KPlayer.GetPlayerObjById(dwID) or KPlayer.GetRoleStayInfo(dwID);
			if pPlayer then
				tbTemp.RoleName = pPlayer.szName;
				local pAsyncData = KPlayer.GetAsyncData(dwID)
				tbTemp.FightPower = pAsyncData and pAsyncData.GetFightPower() or 0
				table.insert(tbDataList,tbTemp);
			end
		end
	end
	tbResult.code = 0
	Log("[tbGMInterface] QueryFamilyMemberInfo ok ",dwKinId)
	return tbResult
end

function tbGMInterface:GetNewMsgPrefix(nMsgId)
	return Transmit.szNewMsgPrefix ..nMsgId
end

function tbGMInterface:SendNewMsg(tbOperations)
	local tbResult = {
		code = 1;
		msg = "Operation Failed";
	}
	local nMsgId = tonumber(tbOperations.MsgId)
	local szEndTime = tbOperations.EndTime
	local szMsgContents = tbOperations.MsgContents
	local szMsgTitle = tbOperations.MsgTitle

	if not nMsgId or szEndTime == "" or szMsgContents == "" or szMsgTitle == "" then
		tbResult.msg = "error param"
		Log("[tbGMInterface] SendNewMsg error param ",nMsgId,szEndTime,szMsgContents,szMsgTitle)
		return tbResult
	end

	local nEndTime = Lib:ParseDateTime(szEndTime)
	if not nEndTime then
		tbResult.msg = "ParseDateTime failed"
		Log("[tbGMInterface] SendNewMsg ParseDateTime fail ",nMsgId,szEndTime,szMsgContents,szMsgTitle)
		return tbResult
	end

	local szKey = self:GetNewMsgPrefix(nMsgId)
	local tbInfoData = NewInformation:GetInformation(szKey)
	if tbInfoData then
		tbResult.msg = "exist new msg id"
		Log("[tbGMInterface] SendNewMsg exist new msg id",nMsgId,szEndTime,szMsgContents,szMsgTitle)
		return tbResult
	end
	local tbActData = {string.format(szMsgContents)}
	local bRet = NewInformation:AddInfomation(szKey, nEndTime, tbActData, {szTitle = szMsgTitle})
	if not bRet then
		tbResult.msg = "execute fail"
		Log("[tbGMInterface] SendNewMsg execute fail ",nMsgId,nEndTime,szMsgContents,szMsgTitle)
		return tbResult
	end

	tbResult.code = 0
	tbResult.msg = "Operation succesed";
	Log("[tbGMInterface] SendNewMsg execute ok ",nMsgId,nEndTime,szMsgContents,szMsgTitle)
	return tbResult
end

function tbGMInterface:QueryNewMsg(tbOperations, nCmdSequence)
	local tbResult = {
		code = 1;
		msg =
		{
			meta =
			{
				Id = "Id";
				MsgTitle = "消息標題";
				MsgContents = "消息內容";
				EndTime = "過期時間";
			};

			data = {};

			totalPage = 1;
		};
	};

	local tbDataList = tbResult.msg.data;
	local tbMsgInfoData = ScriptData:GetValue(NewInformation.DEFAULT_SCRIPT) or {}
	for szKey,_ in pairs(tbMsgInfoData) do
		local szPrefix = string.sub(szKey,1,Transmit.nNewMsgPrefix)
		if szPrefix and szPrefix == Transmit.szNewMsgPrefix then
			local tbInfoData = NewInformation:GetInformation(szKey)
			if tbInfoData then
				local tbInfo =
				{
					Id = string.sub(szKey,Transmit.nNewMsgPrefix + 1),
					MsgContents = tbInfoData.tbData and tbInfoData.tbData[1] or "",
			 		MsgTitle = tbInfoData.tbSetting and tbInfoData.tbSetting.szTitle or "",
			 		EndTime = tbInfoData.nValidTime and tbInfoData.nValidTime or 0,
				}
				table.insert(tbDataList, tbInfo);
			end
		end
	end
	tbResult.code = 0
	Log("[tbGMInterface] QueryMsgTimer ok")

	return tbResult
end

function tbGMInterface:DelNewMsg(tbOperations)
	local tbResult = {
		code = 1;
		msg = "Operation Failed";
	}

	local nMsgId = tonumber(tbOperations.MsgId)
	if not nMsgId then
		tbResult.msg = "error param"
		Log("[tbGMInterface] DelNewMsg error param ",nMsgId)
		return tbResult
	end
	local szKey = self:GetNewMsgPrefix(nMsgId)

	local tbInfoData = NewInformation:GetInformation(szKey)
	if not tbInfoData then
		Log("[tbGMInterface] DelNewMsg error or no exist new msg ",nMsgId)
		return tbResult
	end

	local szTitle = tbInfoData.tbSetting and tbInfoData.tbSetting.szTitle or ""
	local szContent = tbInfoData.tbData and tbInfoData.tbData[1] or ""
	local nEndTime = tbInfoData.nValidTime

	local bRet = NewInformation:RemoveInfomation(szKey)

	if not bRet then
		tbResult.msg = "execute fail"
		Log("[tbGMInterface] DelNewMsg remove fail ",nMsgId,szTitle,szContent,nEndTime)
		return tbResult
	end

	tbResult.code = 0
	tbResult.msg = "Operation succesed";
	Log("[tbGMInterface] DelNewMsg ok ",nMsgId,szTitle,szContent,nEndTime)
	return tbResult
end

function tbGMInterface:QueryMsgTimer(tbOperations, nCmdSequence)
	local tbResult = {
		code = 1;
		msg =
		{
			meta =
			{
				MsgId 		= "公告ID";
				TimerId 	= "定時器ID";
				BeginTime 	= "開始時間";
				EndTime 	= "結束時間";
				LoopTime 	= "間隔時間";
				MsgContent  = "公告內容";
			};

			data = {};

			totalPage = 1;
		};
	};

	local tbDataList = tbResult.msg.data;

	for id,info in pairs(self.tbMsgTimer.tbAllTimer) do
		local tbInfo =
		{
			MsgId 		= id;
			TimerId 	= info.nTimerId;
			BeginTime 	= os.date("%c",info.nBeginTime);
			EndTime 	= os.date("%c",info.nEndTime);
			LoopTime 	= info.nLoopTime;
			MsgContent  = info.szMsgContent;
		}
		table.insert(tbDataList, tbInfo);
	end
	tbResult.code = 0
	Log("[tbGMInterface] QueryMsgTimer ok")

	return tbResult
end

function tbGMInterface:AddPlayerGoldDebtFromList(tbOperations, nCmdSequence)
	local tbResult = {
		code = 0;
		msg = "Operation succesed";
		count = "0";
	};

	tbResult.count = tostring(Player:AddGoldDebtFromList());

	Log("[tbGMInterface] AddPlayerGoldDebtFromList")

	return tbResult
end


function tbGMInterface:MarketStallLimitFromList(tbOperations, nCmdSequence)
	local tbResult = {
		code = 0;
		msg = "Operation succesed";
		count = "0";
	};

	tbResult.count = tostring(Player:MarketStallLimitFromList());

	Log("[tbGMInterface] MarketStallLimitFromList")

	return tbResult
end

function tbGMInterface:MarketStallLimit(tbOperations, nCmdSequence)
	local tbResult = {
		code = 1;
		msg = "Operation Failed";
	}

	local nPlayerId = tonumber(tbOperations.RoleId)
	local nType = tonumber(tbOperations.nType)
	local fValue = tonumber(tbOperations.fValue)
	local nEndTime = Lib:ParseDateTime(tbOperations.szEndTime)

	if not nPlayerId or not nType or not fValue or not nEndTime then
		tbResult.msg = "fail: lack of param";
		return tbResult;
	end

	local pStayInfo = KPlayer.GetRoleStayInfo(nPlayerId);
	if not pStayInfo then
		tbResult.msg = "fail: not found role";
		return tbResult;
	end

	MarketStall:SetPlayerLimit(nPlayerId, nType, fValue, nEndTime)

	tbResult.code = 0
	tbResult.msg = "Operation succesed";

	return tbResult
end

function tbGMInterface:AddRewardValueDebt(tbOperations, nCmdSequence)
	local tbResult = {
		code = 1;
		msg = "Operation Failed";
	}

	local nPlayerId = tonumber(tbOperations.RoleId)
	local nCount = tonumber(tbOperations.count)

	if not nPlayerId or not nCount then
		tbResult.msg = "fail: lack of param";
		return tbResult;
	end

	if nCount <= 0 then
		tbResult.msg = "fail: invalid count";
		return tbResult;
	end

	local pStayInfo = KPlayer.GetRoleStayInfo(nPlayerId);
	if not pStayInfo then
		tbResult.msg = "fail: not found role";
		return tbResult;
	end

	local pAsyncData = KPlayer.GetAsyncData(nPlayerId);

	if not pAsyncData then
		tbResult.msg = "fail: not async data";
		return tbResult;
	end

	Player:AddRewardValueDebt(nPlayerId, nCount, Env.LogWay_GM)

	tbResult.code = 0
	tbResult.msg = "Operation succesed";

	return tbResult
end

function tbGMInterface:AddRewardValueDebtFromList(tbOperations, nCmdSequence)
	local tbResult = {
		code = 0;
		msg = "Operation succesed";
		count = "0";
	};

	tbResult.count = tostring(Player:AddRewardValueDebtFromList());

	Log("[tbGMInterface] AddRewardValueDebtFromList")

	return tbResult
end

Transmit.tbCustomInterface = Transmit.tbCustomInterface or {};
local tbCustomInterface = Transmit.tbCustomInterface;

function Transmit:CustomServiceRequest(szJson, nCmdSequence)
	local tbOperations = Lib:DecodeJson(szJson);

	Log("=====GM:CustomServiceRequest=====")
	Lib:LogTB(tbOperations);

	local tbResult = {
			code = -1;
			msg = "未知客服平台指令";
			data = {};
		};

	if tbCustomInterface[tbOperations.action] then
		tbResult = tbCustomInterface[tbOperations.action](tbCustomInterface, tbOperations);
	else
		Log("ERROR:Unkown action", tbOperations.action);
	end

	local szRet = Lib:EncodeJson(tbResult);
	Log("Result:", szRet);
	GmOperateRespond(szRet, nCmdSequence);
end

function tbCustomInterface:searchPlayer(tbOperations)
	local tbResult = {
		code = -1;
		msg = "player not found";
	};

	local pPlayerInfo = KPlayer.GetRoleStayInfo(tbOperations.player_name or "");
	if pPlayerInfo then
		pPlayerInfo = KPlayer.GetPlayerObjById(pPlayerInfo.dwID) or pPlayerInfo;
	end

	if pPlayerInfo then
		tbResult.code = 0;
		tbResult.msg = "searchPlayer succesed";
		tbResult.data = {
			{
				user_id = pPlayerInfo.szAccount or "";
				user_name = "";
				player_id = pPlayerInfo.dwID;
				player_name = pPlayerInfo.szName;
			};
		}
	end

	return tbResult;
end

function tbCustomInterface:playerInfo(tbOperations)
	local tbResult = {
		code = -1;
		msg = "player not found";
	};

	local nPlayerId   = tonumber(tbOperations.player_id) or 0;
	local pPlayerInfo = KPlayer.GetRoleStayInfo(nPlayerId);
	local pPlayer     = KPlayer.GetPlayerObjById(nPlayerId);

	if pPlayerInfo then
		local kinData = Kin:GetKinByMemberId(nPlayerId);
		local kinMemberData = Kin:GetMemberData(nPlayerId);
		tbResult.code = 0;
		tbResult.msg = "searchPlayer succesed";
		tbResult.data = {
			user_id = pPlayer and pPlayer.szAccount or "";
			user_name = "";
			player_id = pPlayerInfo.dwID;
			player_name = pPlayerInfo.szName;
			lv = pPlayerInfo.nLevel;
			vip = pPlayer and pPlayer.GetVipLevel() or -1;
			battle_score = FightPower:GetFightPower(nPlayerId);
			gold = pPlayer and pPlayer.GetMoney("Gold") or -1;
			stamina = pPlayer and 0 or -1;
			silver = pPlayer and pPlayer.GetMoney("Coin") or -1;
			create_date = pPlayer and os.date("%Y-%m-%d %H:%M:%S", pPlayer.dwCreateTime) or "-1";
			online_date = os.date("%Y-%m-%d %H:%M:%S", pPlayerInfo.nLastOnlineTime);
			honor_level = pPlayerInfo.nHonorLevel;
			faction = pPlayerInfo.nFaction;
			contrib = kinMemberData and kinMemberData:GetContribution() or -1;
			kin_name = kinData and kinData.szName or "";
		};
	end
	return tbResult;
end

function tbCustomInterface:charge(tbOperations)
	local tbResult =
	{
		code = 0;
		msg = "success";
	};

	local nPlayerId   = tonumber(tbOperations.player_id) or 0;

	local bRet, szErr = Recharge:DirPayBack(nPlayerId, tbOperations.product_id);

	Log("CustomCharge", "", tbOperations.player_id, tbOperations.product_id, bRet, szErr);

	if not bRet then
		tbResult.code = 1
		tbResult.msg = szErr
	end

	return tbResult;
end

function tbCustomInterface:searchVIP(tbOperations)
	local tbResult = {};

	local nVipLevel   = tonumber(tbOperations.vip) or 0;


	local tbPlayer = KPlayer.GetAllPlayer();
	for _, pPlayer in pairs(tbPlayer) do
		if pPlayer.GetVipLevel() >= nVipLevel then
			local pPlayerInfo = KPlayer.GetRoleStayInfo(pPlayer.dwID);
			local playerInfo =
			{
				user_id = pPlayer.szAccount,
				user_name = "",
				player_id = pPlayer.dwID,
				player_name = pPlayer.szName,
				lv = pPlayer.nLevel,
				vip = pPlayer.GetVipLevel(),
				battle_score = FightPower:GetFightPower(pPlayer.dwID),
				gold = pPlayer.GetMoney("Gold"),
				silver = pPlayer.GetMoney("Coin"),
				create_date = os.date("%Y-%m-%d %H:%M:%S", pPlayer.dwCreateTime),
				online_date = os.date("%Y-%m-%d %H:%M:%S", pPlayerInfo.nLastOnlineTime),
				channel_id = pPlayer.szAccount,
				server_id = tostring(GetServerIdentity()) ,
			}
			table.insert(tbResult, playerInfo)
		end
	end

	return tbResult;
end

function tbCustomInterface:sendMail(tbOperations)
	local tbResult =
	{
		code = 0;
		msg = "success";
	};

	if Lib:IsEmptyStr(tbOperations.player_id)
		or Lib:IsEmptyStr(tbOperations.title)
		or Lib:IsEmptyStr(tbOperations.content)
		or Lib:IsEmptyStr(tbOperations.sender)
		then
		tbResult.code = 1
		tbResult.msg = "fail: lack of param"
		return tbResult;
	end

	local tbAttach = {};
	for szItemInfo in string.gmatch(tbOperations.attach, "%w+,%d+") do
		local szItem, nCount = string.match(szItemInfo, "(%w+),(%d+)");
		nCount = tonumber(nCount) or 0;

		if Player.AwardType[szItem] == Player.award_type_money and nCount > 0 then
			table.insert(tbAttach, {szItem, nCount});
		elseif nCount > 0 then
			local nItemId = tonumber(szItem);
			if nItemId then
				table.insert(tbAttach, {"item", nItemId, nCount});
			end
		end
	end

	local tbMail = {
		To = nil;
		Title = tbOperations.title;
		Text = tbOperations.content;
		From = tbOperations.sender;
		tbAttach = tbAttach;
		nLogReazon = Env.LogWay_GMCompenMail;
	};

	local tbPlayers = Lib:SplitStr(tbOperations.player_id, ",");
	for _, szPlayerId in pairs(tbPlayers) do
		local nPlayerId = tonumber(szPlayerId);
		if nPlayerId then
			tbMail.To = nPlayerId;
			Mail:SendSystemMail(tbMail);
		end
	end

	return tbResult;
end

function tbCustomInterface:sendGlobalMail(tbOperations)
	local tbResult =
	{
		code = 0;
		msg = "success";
	};

	if Lib:IsEmptyStr(tbOperations.title)
		or Lib:IsEmptyStr(tbOperations.content)
		or Lib:IsEmptyStr(tbOperations.sender)
		then
		tbResult.code = 1
		tbResult.msg = "fail: lack of param"
		return tbResult;
	end

	local tbAttach = {};
	for szItemInfo in string.gmatch(tbOperations.attach, "%w+,%d+") do
		local szItem, nCount = string.match(szItemInfo, "(%w+),(%d+)");
		nCount = tonumber(nCount) or 0;

		if Player.AwardType[szItem] == Player.award_type_money and nCount > 0 then
			table.insert(tbAttach, {szItem, nCount});
		elseif nCount > 0 then
			local nItemId = tonumber(szItem);
			if nItemId then
				table.insert(tbAttach, {"item", nItemId, nCount});
			end
		end
	end

	local tbMail = {
		To = nil;
		Title = tbOperations.title;
		Text = tbOperations.content;
		From = tbOperations.sender;
		tbAttach = tbAttach;
		nLogReazon = Env.LogWay_GMGlobalCompenMail;
	};

	Mail:SendGlobalSystemMail(tbMail);

	return tbResult;
end

function tbCustomInterface:broadcast(tbOperations)
	local tbResult =
	{
		code = 0;
		msg = "success";
		id = 0,
	};

	if not tbOperations.content or tbOperations.content == "" then
		tbResult.code = 1
		tbResult.msg = "fail: no content"
		return tbResult;
	end

	local nNow = GetTime();
	local nBeginTime = Lib:ParseDateTime(tbOperations.start_date or "") or nNow;
	local nEndTime = Lib:ParseDateTime(tbOperations.end_date or "");
	local nLoopTime = tonumber(tbOperations.interval_time);
	if not nLoopTime or not nEndTime then
		tbResult.code = 1
		tbResult.msg = "fail: not interval_time or end_date"
		return tbResult;
	end

	if nNow > nEndTime then
		tbResult.code = 1
		tbResult.msg = "fail: out of time"
		return tbResult;
	end

	local id = Transmit:GenBroadCastId()

	tbResult.id = id

	Transmit.tbBroadCastList[id] =
	{
		broadcast_id = id,
		start_date = tbOperations.start_date,
		end_date = tbOperations.end_date,
		interval_time = tbOperations.interval_time,
		content = tbOperations.content,
	}

	local fnSendNotify = function ()
		local nCurTime = GetTime();
		if nCurTime > nEndTime or not Transmit.tbBroadCastList[id] then
			return false;
		end

		KPlayer.SendWorldNotify(1, 999, tbOperations.content, 1, 1);
		return true;
	end

	local fnBeginSendNotify = function ()
		if fnSendNotify() then
			Timer:Register(Env.GAME_FPS * nLoopTime * 60, fnSendNotify);
		end
		return false;
	end

	if nNow >= nBeginTime then
		fnBeginSendNotify();
	else
		Timer:Register(Env.GAME_FPS * (nBeginTime - nNow), fnBeginSendNotify);
	end

	return tbResult
end

function tbCustomInterface:searchBroadcast(tbOperations)
	local tbResult ={};

	for _,broadCastInfo in pairs(Transmit.tbBroadCastList) do
		table.insert(tbResult, broadCastInfo)
	end

	return tbResult
end

function tbCustomInterface:removeBroadcast(tbOperations)
	local tbResult =
	{
		code = 1,
		msg = "success",
	};

	local broadcast_id = tonumber(tbOperations.broadcast_id) or 0

	if not Transmit.tbBroadCastList[broadcast_id] then
		tbResult.code = 0
		tbResult.msg = "not found broadcast"
		return tbResult
	end

	Transmit.tbBroadCastList[broadcast_id] = nil

	return tbResult
end

function tbCustomInterface:forbidChat(tbOperations)
	local tbResult =
	{
		code = 1,
		msg = "success",
	};

	local nPlayerId   = tonumber(tbOperations.player_id);
	local nEndTime = Lib:ParseDateTime(tbOperations.end_date or "");
	local nForbidType = ChatMgr.ForbidType.Public
	local nSilence = tonumber(tbOperations.is_silence) or 0
	local reason = tbOperations.reason or ""

	if not nPlayerId or not nEndTime then
		tbResult.code = 0
		tbResult.msg = "fail: lack param"
		return tbResult
	end

	if tbOperations.forbid_type == "All" then
		nForbidType = ChatMgr.ForbidType.All
	elseif tbOperations.forbid_type == "None" then
		nForbidType = ChatMgr.ForbidType.None
	end

	local pAsyncData = KPlayer.GetAsyncData(nPlayerId)

	if not pAsyncData then
		tbResult.code = 0
		tbResult.msg = "fail: not found player"
		return tbResult
	end

	pAsyncData.SetChatForbidType(nForbidType);
	pAsyncData.SetChatForbidEndTime(nEndTime);
	pAsyncData.SetChatForbidSilence(nSilence);

	return tbResult
end

function tbCustomInterface:frozen(tbOperations)
	local tbResult =
	{
		code = 1,
		msg = "success",
	};

	local nPlayerId   = tonumber(tbOperations.player_id);
	local reason = tbOperations.reason or ""

	if not nPlayerId then
		tbResult.code = 0
		tbResult.msg = "fail: lack param"
		return tbResult
	end

	BanPlayer(nPlayerId, -1)

	return tbResult
end

function tbCustomInterface:unfrozen(tbOperations)
	local tbResult =
	{
		code = 1,
		msg = "success",
	};

	local nPlayerId   = tonumber(tbOperations.player_id);

	if not nPlayerId then
		tbResult.code = 0
		tbResult.msg = "fail: lack param"
		return tbResult
	end

	BanPlayer(nPlayerId, 0)

	return tbResult
end


function Transmit:OnNeighbourCmd(szJsonCmd, nCmdSeq)
	local tbCmdContent = Lib:DecodeJson(szJsonCmd);
	local tbResult = {};
	tbResult.action = tbCmdContent.szAction;
	if tbCmdContent.szAction == "FriendGift" then
		Mail:SendSystemMail(tbCmdContent.tbMail);
		tbResult.result = true;
		tbResult.targetOpenId = tbCmdContent.szTargeOpenId;
	end

	local szResult = Lib:EncodeJson(tbResult);
	DoNeighbourObeyCmdRespond(szResult, nCmdSeq);
end

function Transmit:DoNeighboureCmdRequest(nPlayerId, nServerId, tbCmd)
	local szCmd = Lib:EncodeJson(tbCmd);
	DoNeighbourMasterCmdRequest(nPlayerId, nServerId, szCmd);
end

function Transmit:OnNeighbourCmdRespond(nPlayerId, szJsonResult)
	Log("Transmit:OnNeighbourCmdRespond:", nPlayerId, szJsonResult);
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return;
	end

	local tbResult = Lib:DecodeJson(szJsonResult);
	if tbResult.action == "FriendGift" and Sdk:IsMsdk() then
		if not tbResult.result then
			pPlayer.CenterMsg("禮物無法送達, 贈送失敗");
			return;
		end
		local fnTellHim = function (szTargeOpenId)
			AssistClient:ShareInfo(me, szTargeOpenId,
				"劍俠情緣好友贈禮",
				"我贈送了你禮物喔, 記得查收喔!",
				"MSG_HEART_SEND");
		end

		local fnConfirm = function (szTargeOpenId)
			local tbMsdkInfo = me.GetMsdkInfo();
			if not next(tbMsdkInfo) then
				return false;
			end

			if tbMsdkInfo.nPlatform == Sdk.ePlatform_Weixin then
				me.MsgBox("確定要給好友發送微信消息嗎?", {{"確定", fnTellHim, szTargeOpenId}, {"取消"}});
			else
				fnTellHim(szTargeOpenId);
			end
		end

		pPlayer.MsgBox("贈禮已送達好友信箱! 發消息告訴他", {{"告訴他", fnConfirm, tbResult.targetOpenId}, {"下次吧"}});
	end
end

local SERVER_ID = GetServerIdentity();
function Transmit:RankServerReport(pPlayer)
	local szFacebookId = Sdk:GetEfunFacebookId(pPlayer);
	if not szFacebookId or szFacebookId == "" then
		return;
	end

	local tbReportData = {
		Power = pPlayer.GetFightPower(),
		Level = pPlayer.nLevel,
		Name = pPlayer.szName,
		ServerId = SERVER_ID,
		PlayerId = pPlayer.dwID,
		VipType = 0,
		LaunchPlat = 0,
	};

	local szReportData = Lib:EncodeJson(tbReportData);
	TransLib.DoHttpCommonRequest(
		pPlayer.dwID,
		string.format("/report?openid=%s", szFacebookId),
		szReportData, "", "", "RankServer");
end

function Transmit:RankServerQuery(pPlayer, szOpenIds)
	TransLib.DoHttpCommonRequest(pPlayer.dwID, "/query", szOpenIds, "OnRankInfoRsp", "", "RankServer")
end

function Transmit:RankServerSendGift(pPlayer, szTargeFacebookId, nServerId, nTargetPlayerId, szFriendName)
	local szFacebookId = Sdk:GetEfunFacebookId(pPlayer);
	if not szFacebookId or szFacebookId == "" then
		return;
	end

	TransLib.DoHttpCommonRequest(
		pPlayer.dwID,
		string.format("/gift?openid=%s&targetid=%s", szFacebookId, szTargeFacebookId),
		tostring(nTargetPlayerId), "OnSendGiftRsp", string.format("%s,%d,%d,%s", szTargeFacebookId, nServerId, nTargetPlayerId, szFriendName), "RankServer");
end

function Transmit:UpdateGiftInfo(pPlayer)
	local szFacebookId = Sdk:GetEfunFacebookId(pPlayer);
	if not szFacebookId or szFacebookId == "" then
		return;
	end

	TransLib.DoHttpCommonRequest(
		pPlayer.dwID, string.format("/gift?openid=%s", szFacebookId),
		"", "OnGiftUpdate", "", "RankServer");
end

function Transmit:XMRoleInfoReport(pPlayer)
	local szUid = string.match(pPlayer.szAccount, "__(.*)") or pPlayer.szAccount;
	local tbReportData = {
		gameCode = "smjq",
		roleName = pPlayer.szName,
		roleid = pPlayer.dwID,
		score = pPlayer.GetFightPower(),
		scoreType = "2",
		serverCode = SERVER_ID,
		serverName = SERVER_ID,
		userid = szUid,
	};

	local szReportData = Lib:EncodeJson(tbReportData);
	szReportData = Lib:UrlEncode(string.format("[%s]", szReportData));
	TransLib.DoHttpCommonRequest(
		pPlayer.dwID,
		string.format("http://fb.efun.com/rank_updateFraction.shtml?data=%s", szReportData),
		"", "", "", "");
end

Transmit.tbHttpCommonRspOp = Transmit.tbHttpCommonRspOp or {};
local tbHttpCommonRspDealer = Transmit.tbHttpCommonRspOp;

function Transmit:OnHttpCommonRsp(szType, nPlayerId, szHttpRsp, szExtra)
	if tbHttpCommonRspDealer[szType] then
		tbHttpCommonRspDealer[szType](self, nPlayerId, szHttpRsp, szExtra);
	else
		Log("Transmit:OnHttpCommonRsp ERROR", szType, nPlayerId, szHttpRsp, szExtra)
		Log(debug.traceback())
	end
end

function tbHttpCommonRspDealer:OnGiftUpdate(dwPlayerId, szRetInfo)
	local pPlayer = KPlayer.GetPlayerObjById(dwPlayerId);
	if not pPlayer then
		return;
	end

	Sdk:OnQueryRankInfoRsp(pPlayer, "gift", szRetInfo);
end

local tbRankSendGiftTips = {
	["not found"] = "對象不存在";
	["diff player"] = "贈送的玩家資訊與後臺不符, 請稍後再試";
	["max send"] = "今日的贈送次數達到上限";
	["has sent"] = "今日已對該好友進行了贈送";
}

function tbHttpCommonRspDealer:OnSendGiftRsp(dwPlayerId, szErrMsg, szExtra)
	Log("tbHttpCommonRspDealer:OnSendGiftRsp", dwPlayerId, szErrMsg, szExtra)
	local _, _, szTargeOpenId, nServerId, nTargetPlayerId, szFriendName = string.find(szExtra, "(.*),(%d+),(%d+),(.*)");
	nServerId = tonumber(nServerId);
	nTargetPlayerId = tonumber(nTargetPlayerId);

	local pPlayer = KPlayer.GetPlayerObjById(dwPlayerId);
	if szErrMsg ~= "succeed" then
		if pPlayer then
			pPlayer.CenterMsg(tbRankSendGiftTips[szErrMsg] or "贈送好友禮物時發生異常");
		end
		return false;
	end

	local tbNeighbourCmd = {};
	tbNeighbourCmd.szAction = "FriendGift";
	tbNeighbourCmd.szTargeOpenId = szTargeOpenId;
	tbNeighbourCmd.tbMail = {
		To = nTargetPlayerId,
		Title = "好友贈禮",
		Text = string.format("您的社交好友 %s 贈送了您一份禮物, 請在附件中查收.", szFriendName),
		From = "FB好友",
		tbAttach = {{"Coin", 200}},
		nLogReason = Env.LogWay_FriendGift;
	};

	Transmit:DoNeighboureCmdRequest(dwPlayerId, nServerId, tbNeighbourCmd);
	if pPlayer then
		Transmit:UpdateGiftInfo(pPlayer);
	end
end

function tbHttpCommonRspDealer:OnRankInfoRsp(dwPlayerId, szRankInfo)
	local pPlayer = KPlayer.GetPlayerObjById(dwPlayerId);
	if not pPlayer then
		return;
	end

	Sdk:OnQueryRankInfoRsp(pPlayer, "rank", szRankInfo);
end