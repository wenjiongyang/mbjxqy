
local tbFuben = Fuben:CreateFubenClass("SampleHouseFuben");

function tbFuben:OnPreCreate()
	self.tbMultiSetting = {};
	self.tbMultiMoveNpc = {};
	self.tbMultiMoveTimer = {};
end

function tbFuben:OnPlayerTrap(szTrap)
    Fuben.tbBase.OnPlayerTrap(self, szTrap);
    House:DoPlayerTrap(szTrap);
end

function tbFuben:OnArrive(...)
	Fuben.tbBase.OnArrive(self, ...);

	local nNpcId = him.nId;
	local nCurIndex = self.tbMultiMoveNpc[nNpcId];
	if not nCurIndex then
		return;
	end

	local tbSetting = assert(self.tbMultiSetting[him.szFubenNpcGroup], "setting not exit:" .. him.szFubenNpcGroup);
	local nMaxIndex = #(tbSetting.tbPath);
	local bIsAllPathCompleted = nCurIndex >= nMaxIndex;
	if bIsAllPathCompleted and not tbSetting.bCycle then
		return;
	end

	local nWaitTime = tbSetting.tbPath[nCurIndex][2];

	nCurIndex = bIsAllPathCompleted and 1 or (nCurIndex + 1);
	self.tbMultiMoveNpc[nNpcId] = nCurIndex;
	
	local szPath = tbSetting.tbPath[nCurIndex][1];
	if not nWaitTime or nWaitTime <= 0 then
		self:SetNpcMove(him, szPath);
		return;
	end

	self.tbMultiMoveTimer[nNpcId] = Timer:Register(Env.GAME_FPS * nWaitTime, function ()
		local pNpc = KNpc.GetById(nNpcId);
		if pNpc then
			self:SetNpcMove(pNpc, szPath);
		end
		self.tbMultiMoveTimer[nNpcId] = nil;
		return 0;
	end)
end

function tbFuben:OnStartMultiPathMove(szGroup, tbPath, bCycle)
	assert(tbPath and tbPath[1] and tbPath[1][1]);

	self.tbMultiSetting[szGroup] = { tbPath = tbPath, bCycle = bCycle };
	for _, nNpcId in pairs(self.tbNpcGroup[szGroup] or {}) do
		local pNpc = KNpc.GetById(nNpcId);
		if pNpc then
			local nStartIndex = 1;
			local szPath = assert(tbPath[nStartIndex][1]);
			self.tbMultiMoveNpc[nNpcId] = nStartIndex;
			self:SetNpcMove(pNpc, szPath);
		end
	end
end

function tbFuben:OnClose()
	for _, nTimerId in pairs(self.tbMultiMoveTimer) do
		Timer:Close(nTimerId);
	end

	self.tbMultiSetting = nil;
	self.tbMultiMoveNpc = nil;
	self.tbMultiMoveTimer = nil;
end
