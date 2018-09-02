
-- 服务器启动回调
function Server:OnStartup()
	local nGMTSec = Lib:GetGMTSec();
	SetLogicGMTSec(nGMTSec);
	SetMaxLevel(150);
	Fuben:Load();
	ValueItem:Init();
	Transmit:OnServerStart();
	Lib:CallBack({ChatMgr.Init, ChatMgr})
	self:LoadFileServerCfg();
end

local nScriptDataNextSaveTime = 0;

--服务器每秒调用一次
function Server:Activate(nTimeNow)
end

function Server:Quite()
end

function Server:OnWSConnected(nConnectIdx, nServerIdx)
	if not self.tbC2WRegister then
		self.tbC2WRegister = {}
		for szFunction, _ in pairs(c2z) do
			self.tbC2WRegister[szFunction] = 1;
		end
	end
	CallZoneClientScript(nConnectIdx, "Server:OnC2WRegister", self.tbC2WRegister);

	self.tbServerIdxToConnectIdx = self.tbServerIdxToConnectIdx or {};
	self.tbServerIdxToConnectIdx[nServerIdx] = nConnectIdx;
end

function Server:OnShutdownConnection(nConnectIdx, nServerIdx)
	self.tbServerIdxToConnectIdx = self.tbServerIdxToConnectIdx or {};
	self.tbServerIdxToConnectIdx[nServerIdx] = nil;
end

function Server:GetConnectIdx(nServerIdx)
	if not self.tbServerIdxToConnectIdx then
		return;
	end

	local _, nMainIdx = GetServerIdentity();
	nServerIdx = nServerIdx < nMainIdx and nServerIdx + nMainIdx or nServerIdx;

	return self.tbServerIdxToConnectIdx[nServerIdx];
end

function Server.OnZoneServerScript(nConnectIdx, szFunc, ...)
	local bRet = false
	if string.find(szFunc, ":") then
		local szTable, szFunc = string.match(szFunc, "^(.*):(.*)$");
		local tb = loadstring("return " .. szTable)();
		Server.nCurConnectIdx = nConnectIdx
		if tb and tb[szFunc] then
			Server.nCurConnectIdx = nConnectIdx;
			bRet = Lib:CallBack({tb[szFunc], tb, ...});
		end
	else
		local func = loadstring("return " .. szFunc)();
		Server.nCurConnectIdx = nConnectIdx;
		bRet = Lib:CallBack({func, ...});
	end
	Server.nCurConnectIdx = nil;
	if not bRet then
		Log("Server:OnZoneServerScript Error", nConnectIdx, szFunc, ...)
	end
end

function Server:OnTransferLogin(pPlayer, nServerIdx)
	local KinMgr = GetKinMgr()
	pPlayer.nServerIdx = nServerIdx or 0;
	local szTitle = KinMgr.GetTitle(pPlayer.dwID) or ""
	local szReplace = string.format("［%d服］", nServerIdx or 0)
	if pPlayer.dwKinId ~= 0 and not Lib:IsEmptyStr(szTitle) then
	    local szNew = string.gsub(szTitle, "［家族］", szReplace)
	    Kin:SyncTitle(pPlayer.dwID, szNew)
	else
		--pPlayer.GetNpc().SetTitle(szReplace, 1, 0)
	end

	self:SyncZoneFileServer(pPlayer)

	Log("Server OnPlayerLogin:", pPlayer.dwID, nServerIdx)
end

function Server:LoadFileServerCfg()
	local tbCfg = Lib:LoadIniFile("world_server.ini", 0, 1);
	if tbCfg.FileServer then
		self.szFileServerIp = tbCfg.FileServer.IP
		self.nFileServerPort = tonumber(tbCfg.FileServer.Port)
	end
end

function Server:SyncZoneFileServer(pPlayer)
	pPlayer.CallClientScript("FileServer:SyncZoneFileServer", self.szFileServerIp, self.nFileServerPort)
end
