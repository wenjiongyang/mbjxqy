
Server.bCheckHotfixCmdMd5 = false;

if version_vn then
	Server.bCheckHotfixCmdMd5 = true;
end

local nScriptDataNextSaveTime = 0;

-- 服务器启动回调
function Server:OnStartup()
	local nGMTSec = Lib:GetGMTSec();
	SetLogicGMTSec(nGMTSec);

	nScriptDataNextSaveTime = math.ceil(GetTime() / 60) * 60;

	ScheduleTask.CheckMaxLevel();
	Fuben:Load();
	ValueItem:Init();
	TeamFuben:Init();
	CardPicker:Init();
	Kin:RebuildCoreData();
	Kin:OnAuctionStart();
	PunishTask:StartCreateMapNpc();
	Transmit:OnServerStart();
	Item.tbRefinement:OnStartDataCheck();
	HeroChallenge:OnStartup();
	Task:Setup();
	local tbAllAsync = KPlayer.GetAllAsyncPlayer()
	-- Debris:OnStartup(tbAllAsync);
	MapExplore:InitPlayers(tbAllAsync);
	FactionBattle:OnServerStart();
	KinEscort:Init();
	Kin:OpenSrvInit()
	DomainBattle:OnServerStart()
	Recharge:OnStartup();
	Lib:CallBack({MarketStall.Setup, MarketStall});
	Lib:CallBack({Faction.OnServerStart, Faction});
	Lib:CallBack({NewInformation.OnStartUp, NewInformation})
	Lib:CallBack({RankActivity.OnServerStart, RankActivity})
	Lib:CallBack({ChatMgr.Init, ChatMgr})
	Lib:CallBack({Activity.OnServerStart, Activity});
	Lib:CallBack({Shop.Init, Shop})

	Lib:CallBack({Npc.UpdateLevelAddExpP, Npc})

	Lib:CallBack({ArenaBattle.Init, ArenaBattle})
	Lib:CallBack({ImperialTomb.Init, ImperialTomb})
	Lib:CallBack({RandomAward.Init, RandomAward})
	Lib:CallBack({HuaShanLunJian.OnServerStartup, HuaShanLunJian});
	Lib:CallBack({CombineServer.OnStartup, CombineServer});

	local tbRandomItemByTimeFrame = Item:GetClass("RandomItemByTimeFrame");
	Lib:CallBack({tbRandomItemByTimeFrame.LoadSetting, tbRandomItemByTimeFrame});

	local tbJuanZhouItem = Item:GetClass("JuanZhou");
	Lib:CallBack({tbJuanZhouItem.LoadSetting, tbJuanZhouItem});

	ChangeZoneConnect(1);	-- 先统一连到1号跨区服
	self:LoadZoneGroup();

	self:LoadIOSEntry();
	Lib:CallBack({Kin.CheckCorrectWeekActive, Kin})
	Lib:CallBack({SwornFriends.OnStartup, SwornFriends})
	Lib:CallBack({TeacherStudent.OnStartup, TeacherStudent})
	Lib:CallBack({AddictionTip.Setup, AddictionTip});

	Lib:CallBack({FriendRecall.OnServerStart, FriendRecall});
	Lib:CallBack({RegressionPrivilege.OnStartUp, RegressionPrivilege})
	Item.tbZhenYuan:InitEquipMakerXYItemValues()
	Lib:CallBack({House.OnStartUp, House});
	Lib:CallBack({Sdk.OnStartUp, Sdk});
	Lib:CallBack({Calendar.OnStartUp, Calendar});

	local tbAct = Activity:GetClass("BeautyPageant")
	Lib:CallBack({tbAct.OnServerStart, tbAct});
	WuLinDaHui:OnServerStartup()

	Lib:CallBack({Lottery.Load, Lottery});
	Lib:CallBack({JingMai.OnServerStart, JingMai});
	Lib:CallBack({Map.InitSetting, Map});
end


--服务器每秒调用一次
function Server:Activate(nTimeNow)
	if nTimeNow > nScriptDataNextSaveTime then
		nScriptDataNextSaveTime = nTimeNow + 60;
		Server:ActivatePerMinute(nTimeNow);
	end

	Lib:CallBack({Kin.Save, Kin});
	Lib:CallBack({ScriptData.CheckAndSave, ScriptData});
	Lib:CallBack({Kin.AuctionActive, Kin});
	Lib:CallBack({MarketStall.Activate, MarketStall, nTimeNow});
	Lib:CallBack({AssistClient.Active, AssistClient, nTimeNow});
	Lib:CallBack({Kin.OpenSrvActive, Kin});
	Lib:CallBack({NpcBubbleTalk.Active, NpcBubbleTalk});
	Lib:CallBack({House.CheckDirty, House});
end

function Server:ActivatePerMinute(nTimeNow)
	ScriptData:Save();
	FriendShip:Active(nTimeNow)
	Recharge:Activate(nTimeNow);
	Lib:CallBack({AddictionTip.Activate, AddictionTip, nTimeNow});
	Lib:CallBack({WeatherMgr.ActivatePerMinute, WeatherMgr, nTimeNow});
	Lib:CallBack({TimeFrame.UpdateMainTimeFrame, TimeFrame});
end

function Server:Quit()
	if not self.bQuit then
		self.bQuit = true;
		Kin:Save(true);
		ScriptData:Save();
		House:SaveAll();
		Lib:CallBack({MarketStall.OnQuit, MarketStall});
	end

	return AssistClient:CanQuit();
end

function Server:OnConnectedGateway()
	Lib:CallBack({Server.SyncPcuInfo, Server, true})
end

function Server:ExecuteFixCmd(szFileName, szTimeout, szCmdMd5)
	local nFileChangeTime = GetFileChangeTime("HotFix/" .. szFileName);
	if self.tbFixCmdInfo[szFileName] and self.tbFixCmdInfo[szFileName] == nFileChangeTime then
		Log(string.format("[HotFix] CheckFixCmd  [%s]  [%s] has executed FileChangeTime [%s]", szFileName, szTimeout, os.date("%Y-%m-%d %H:%M:%S", self.tbFixCmdInfo[szFileName])));
		return;
	end

	local file = io.open("HotFix/" .. szFileName, "rb");
	if not file then
		Log(string.format("[HotFix] ExecuteFixCmd ERR ?? open file fail !!"), szFileName);
		return;
	end

	local szCmd = file:read("*all");
	file:close();

	-- 去掉 UTF8 BOM文件头
	if string.len(szCmd) > 3 and
		string.byte(szCmd, 1) == 0xef and
		string.byte(szCmd, 2) == 0xbb and
		string.byte(szCmd, 3) == 0xbf then

		szCmd = string.sub(szCmd, 4, -1);
	end

	if self.bCheckHotfixCmdMd5 then
		local szMd5 = KLib.GetStringMd5(KLib.GetStringMd5(szCmd .. "jxqy_cmd_info_hhhhh") .. "jxqy_hotfix_md5_iiiiii");
		if not szCmdMd5 or string.lower(szCmdMd5) ~= string.lower(szMd5) then
			Log("[HotFix] ExecuteFixCmd ERR ?? Hotfix Check Fail !! ", szFileName);
			return;
		end
	end

	Log(string.format("[HotFix] ExecuteFixCmd  [%s]  [%s]", szFileName, szTimeout));

	Log("[HotFix] Execute Cmd " .. szFileName .. ":\n" .. szCmd);

	local fnOp, szRet = loadstring(szCmd);
	if not fnOp then
		Log("[HotFix] ExecuteFixCmd ERR ?? loadstring fail !!", szRet);
		return;
	end

	local bOpSucces = Lib:CallBack({fnOp});
	if not bOpSucces then
		Log("[HotFix] ExecuteFixCmd ERR ?? execute cmd fail !!");
		return;
	end

	self.tbFixCmdInfo[szFileName] = nFileChangeTime;
end

function Server:CheckFixCmd()
	Log("[HotFix] Start CheckFixCmd ==============================");
	local file = io.open("HotFix/HotFix.ini", "r");
	if not file then
		return;
	end
	file:close();

	self.tbFixCmdInfo = self.tbFixCmdInfo or {};
	local tbFile = KLib.LoadIniFile("HotFix/HotFix.ini", 0, 1) or {};
	local nTimeNow = GetTime();
	for szFileName, szTimeout in pairs(tbFile["CmdList"] or {}) do
		local year, month, day, hour, min, sec = string.match(szTimeout, "^(%d+)-(%d+)-(%d+) (%d+):(%d+):(%d+)");
		if year then
			local nTime = os.time({day=day,month=month,year=year,hour=hour,min=min,sec=sec});
			if nTime > nTimeNow then
				Lib:CallBack({self.ExecuteFixCmd, self, szFileName, szTimeout, (tbFile["CmdMd5"] or {})[szFileName]});
			else
				Log(string.format("[HotFix] CheckFixCmd  [%s]  [%s] timeout !!", szFileName, szTimeout));
			end
		else
			Log(string.format("[HotFix] CheckFixCmd  [%s]  [%s] ERROR !!", szFileName, szTimeout));
		end
	end
	Log("[HotFix] End CheckFixCmd ==============================");
end

function Server:IsCloseIOSEntry()
	return self.bCloseIOSEntry
end

function Server:CloseIOSEntry(bClose)
	self.bCloseIOSEntry = bClose

	if PlayerEvent.nCloseIOSEntry then
		PlayerEvent:UnRegisterGlobal("OnLogin", PlayerEvent.nCloseIOSEntry)
		PlayerEvent.nCloseIOSEntry = nil
	end

	local szCmd = string.format("Client:SetFlag('CloseIOSEntry', %s)", tostring(bClose))
	PlayerEvent.nCloseIOSEntry =  PlayerEvent:RegisterGlobal("OnLogin",  function ()
		me.CallClientScript("Client:DoCommand", szCmd)
	end);

	KPlayer.BoardcastScript(1, "Client:DoCommand", szCmd);
end

function Server.OnZoneCallScript( szFunc, ... )
	if string.find(szFunc, ":") then
		local szTable, szFunc = string.match(szFunc, "^(.*):(.*)$");
		local tb = loadstring("return " .. szTable)();
		tb[szFunc](tb, ...);
	else
		local func = loadstring("return " .. szFunc)();
		func(...);
	end
end

function Server:OnC2WRegister(tbC2WRegister)
	for szFunction, _ in pairs(tbC2WRegister) do
		RegisterZoneC2S(szFunction, 2);		-- 注册转发给zoneserver 的协议
	end
	WuLinDaHui:OnConnectZoneServer()
end

function Server:UpdatePCU7(nCurPcu)
	local tbPcu = ScriptData:GetValue("ServerPcuInfo");
	local nToday = Lib:GetLocalDay();
	if not tbPcu.nRecordDay or tbPcu.nRecordDay < nToday then
		tbPcu.tbPcuList = tbPcu.tbPcuList or {};
		table.insert(tbPcu.tbPcuList, nCurPcu)
		tbPcu.nRecordDay = nToday;
		if #tbPcu.tbPcuList > 8 then
			table.remove(tbPcu.tbPcuList, 1)
		end
		Server:SyncPcuInfo()
		Log("UpdatePCU7", unpack(tbPcu.tbPcuList));
	elseif tbPcu.nRecordDay == nToday and tbPcu.tbPcuList[#tbPcu.tbPcuList] < nCurPcu then
		tbPcu.tbPcuList[#tbPcu.tbPcuList] = nCurPcu;
		Server:SyncPcuInfo()
	end
end

function Server:SyncPcuInfo(bRequestAll)
	local tbPcu = ScriptData:GetValue("ServerPcuInfo");
	tbPcu.tbPcuList = tbPcu.tbPcuList or {};
	local nTotalPcu = 0
	local nPcuInfo = 0
	local nPcuCount = #tbPcu.tbPcuList;
	if nPcuCount > 1 then
		for i = 1, nPcuCount - 1 do
			nTotalPcu = nTotalPcu + tbPcu.tbPcuList[i];
		end
		nPcuInfo = nTotalPcu / (nPcuCount - 1);
	else
		nPcuInfo = (tbPcu.tbPcuList[1] or 0);
	end
	SyncPcu7Day(nPcuInfo, bRequestAll and 1 or 0);
	Log("SyncPcu7Day", nPcuInfo, bRequestAll)
end

function Server:OnSyncPcuInfo(nServerId, nCreateTime, nPcuInfo)
	self.tbAllPcuInfo = self.tbAllPcuInfo or {}
	self.tbAllPcuInfo[nServerId] =
	{
		nServerId = nServerId,
		nCreateTime = nCreateTime,
		nPcuInfo = nPcuInfo
	};
end

function Server:GetAutoZoneGroup(nServerId, nParam, szTimeFrame)
	local fnSort = function (tbA, tbB)
		local nLocalDayA = Lib:GetLocalDay(tbA.nCreateTime);
		local nLocalDayB = Lib:GetLocalDay(tbB.nCreateTime);
		if (nLocalDayA == nLocalDayB) then
			return tbA.nServerId < tbB.nServerId;
		end
        return tbA.nCreateTime < tbB.nCreateTime;		-- 开服时间升序排序
    end
    local tbSort = {}
    local nTotalPcu = 0;
    local nTotalServer = 0;
    local nGroup = 0;
    local nSplitCount = 2500;	-- 默认切分点在2500
    local nMaxZoneGroup = GetZoneListCount() - 1;
    local nCurTime = GetTime();
    if nMaxZoneGroup <= 0 then
    	return 1;
    end
    for _, tbInfo in pairs(self.tbAllPcuInfo) do
    	if tbInfo.nCreateTime > 0 and
    	(tbInfo.TimeFrame == "" or CalcTimeFrameOpenTime(szTimeFrame, tbInfo.nCreateTime) < nCurTime) then
    		table.insert(tbSort, tbInfo);
    		nTotalPcu = nTotalPcu + tbInfo.nPcuInfo;
    		nTotalServer = nTotalServer + 1;
    	end
    end
    if nTotalPcu * nParam > nSplitCount * nMaxZoneGroup then		-- 超负载，只能尽量平衡负载
    	nSplitCount = math.ceil(nTotalPcu * nParam / nMaxZoneGroup)
    end
    table.sort(tbSort, fnSort);

    -- 开始分配
    local nCurZoneGroup = 0;
    local nCurTotal = 0
    Log("AutoZoneGroupInfo", nSplitCount, nMaxZoneGroup, nTotalPcu, nTotalServer)
    for _, tbInfo in ipairs(tbSort) do
    	if (nCurTotal + tbInfo.nPcuInfo) * nParam > nCurZoneGroup * nSplitCount then
    		nCurZoneGroup = nCurZoneGroup + 1;
    		Log("Split Zone Group", tbInfo.nServerId, nCurZoneGroup + 1);
    	end
    	nCurTotal = nCurTotal + tbInfo.nPcuInfo;
    	if tbInfo.nServerId == nServerId then
    		nGroup = nCurZoneGroup;
    	end
    end

    return nGroup + 1;
end

function Server:LoadZoneGroup()
	self.tbZoneGroup = LoadTabFile("Setting/ZoneGroup.tab", "dddddddddd", "ServerId", {"ServerId", "Normal", "Battle", "Baihu", "TeamBattle", "Indiffer", "DaXueZhang","BiWuZhaoQin", "WLDH", "BLBoss"});
	self.tbAutoZoneGroup = LoadTabFile("Setting/AutoZoneGroup.tab", "sss", "Type", {"Type", "Param", "TimeFrame"})
	for _, tbInfo in pairs(self.tbAutoZoneGroup) do
		tbInfo.Param = tonumber(tbInfo.Param)
	end
end

function Server:ChangeZoneGroup(szType, szActName, szCloseActName)
	if not Lib:IsEmptyStr(szActName) then
		if not Activity:__IsActInProcessByType(szActName) then
			Log("Server:ChangeZoneGroup Not OpenActType", szType, szActName)
			return
		end
	end

	if not Lib:IsEmptyStr(szCloseActName) then
		if  Activity:__IsActInProcessByType(szCloseActName) then
			Log("Server:ChangeZoneGroup On CloseAct", szType, szCloseActName)
			return
		end
	end
	 
	local nServerId = GetServerIdentity()
	if not self.AutoZoneGroup then		-- 暂时保留原本配置的方式，用开关来区分
		if self.tbZoneGroup and self.tbZoneGroup[nServerId] then
			ChangeZoneConnect(self.tbZoneGroup[nServerId][szType] or 1);
		else
			ChangeZoneConnect(1);
			Log("ChangeZoneGroup Error!! ZoneGroup is not Exist", szType, nServerId, tostring(self.tbZoneGroup));
		end
		if self.tbAutoZoneGroup[szType] then
			local nZoneGroup = self:GetAutoZoneGroup(nServerId, self.tbAutoZoneGroup[szType].Param, self.tbAutoZoneGroup[szType].TimeFrame)
			Log("AutoZoneResult", nServerId, szType, nZoneGroup);
		end
	else
		if self.tbAutoZoneGroup[szType] then
			local nZoneGroup = self:GetAutoZoneGroup(nServerId, self.tbAutoZoneGroup[szType].Param, self.tbAutoZoneGroup[szType].TimeFrame)
			Log("AutoZoneResult", nServerId, szType, nZoneGroup);
			ChangeZoneConnect(nZoneGroup);
		else
			ChangeZoneConnect(1);
			Log("ChangeZoneGroup Error!! ZoneGroup is not Exist", szType, nServerId, tostring(self.tbZoneGroup));
		end
	end
end

function Server:OnDisconnectZoneServer()
	Battle:OnZoneStopBattleSignUp();
end

function Server:LoadIOSEntry()
	local tbCfg = Lib:LoadIniFile("world_server.ini", 0, 1);
	if tbCfg.Player and tbCfg.Player.CloseIOSEntry then
		self:CloseIOSEntry(tbCfg.Player.CloseIOSEntry == "1");
	end
end
