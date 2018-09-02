Require("ServerScript/Fuben/DungeonFuben/DungeonMgr.lua")
local tbFuben = Fuben:CreateFubenClass("DungeonFubenFloor2");
local FubenMgr = Fuben.DungeonFubenMgr;

function tbFuben:OnCreate(nKind, nFubenLevel, nPlayerNum, dwOwnerId)
	--直接根据boos 配置刷新出一只boss
	self.nKind = nKind
	self.nFubenLevel = nFubenLevel
	self.dwOwnerId = dwOwnerId
	local tbSet = FubenMgr.tbScendLevelSetting[nFubenLevel]

	if nKind == FubenMgr.Kind_Boss then
		self.tbKillNpcReg = {}
	else

		local nRandParam = MathRandom(unpack(FubenMgr.tbMineRandXY))
		local nMineNum = nRandParam * nPlayerNum

		local nNpcIndex = 0;
		if nKind == FubenMgr.Kind_Stone then
			nNpcIndex = 2;
		else
			nNpcIndex = 3;
		end
		self.nMaxPickNum = math.min(nRandParam + FubenMgr.nPickUpParam, nMineNum) 
		self.nItemIdStone = tbSet.nItemIdStone
		self.nItemIdCrystal = tbSet.nItemIdCrystal

		local nRegionNum = self.tbSetting.nNpcRegionPart
		local nEveryRegionNum = math.floor(nMineNum / nRegionNum) 
		for i = 1, nRegionNum do
			self:AddNpc(nNpcIndex, nEveryRegionNum, 0, "Mine" .. i, "Mine" .. i, nil, self.tbSetting.NPC_DIR[nNpcIndex]);	
		end
		if nMineNum - nEveryRegionNum * nRegionNum then
			self:AddNpc(nNpcIndex, nMineNum - nEveryRegionNum * nRegionNum , 0, "Mine1", "Mine1", nil, self.tbSetting.NPC_DIR[nNpcIndex]);
		end

		self.nCurnMineNum = nMineNum
		self.tbDigNum = {};
		Log("DungeonFubenFloor2 Mine ", nKind, self.nMapId, nMineNum, nRandParam, self.nMaxPickNum)
	end
	self.nEndTime = GetTime() + self.tbSetting.nDuraTime;
	self.tbJoinTime = {};
	self:Start();
end

function tbFuben:OnFirstJoin(pPlayer)
	if self.nKind == FubenMgr.Kind_Boss then
		self.tbKillNpcReg[pPlayer.dwID] = PlayerEvent:Register(pPlayer, "OnKillNpc", self.OnKillNpc, self);
	else
		--挖宝的话初始化其数量
		self.tbDigNum[pPlayer.dwID] = 0
	end
	self.tbJoinTime[pPlayer.dwID] = GetTime()
end

function tbFuben:OnOut(pPlayer)
	if self.tbKillNpcReg then
		if self.tbKillNpcReg[pPlayer.dwID] then
			PlayerEvent:UnRegister(pPlayer, "OnDeath", self.tbKillNpcReg[pPlayer.dwID]);
			self.tbKillNpcReg[pPlayer.dwID] = nil
		end
	end
	self:ClearDeathState(pPlayer);
	pPlayer.CallClientScript("Ui:CloseWindow", "HomeScreenFuben");
	pPlayer.TLogRoundFlow(Env.LogWay_DungeonFuben, self.tbSetting.nMapTemplateId, 0, GetTime() - self.tbJoinTime[pPlayer.dwID]
			, self.bLost and Env.LogRound_FAIL or Env.LogRound_SUCCESS, 0, 0); 

end

function tbFuben:OnKillNpc()
	if him.nId == self.nBossId then
		self:UnLock(3) --刷新篝火
		self.bBossKilled = true;
		-- 所有人显示离开
		local fnExcute = function (pPlayer)
			pPlayer.CallClientScript("Fuben:ShowLeave");
		end
		self:AllPlayerExcute(fnExcute);
	end
end

function tbFuben:OnDigStone(pPlayer, pNpc)
	self:DigMine(pPlayer, pNpc, self.nItemIdStone)
end

function tbFuben:OnDigCrystal(pPlayer, pNpc)
	self:DigMine(pPlayer, pNpc, self.nItemIdCrystal)
end

function tbFuben:DigMine(pPlayer, pNpc, nItemId)
	assert(self.tbDigNum[pPlayer.dwID])
	if self.tbDigNum[pPlayer.dwID] >= self.nMaxPickNum then
		pPlayer.CenterMsg("本次地底秘藏的採集次數已耗盡")
		return
	end
 	pNpc.Delete();
 	self.nCurnMineNum = self.nCurnMineNum - 1
 	local nRet, szMsg = Item:GetClass("RandomItemByLevel"):GetAwardByLevel(pPlayer, nItemId, "發現地宮獎勵")
	if szMsg then
		pPlayer.CenterMsg(szMsg)
	end
	
	self.tbDigNum[pPlayer.dwID] = self.tbDigNum[pPlayer.dwID] + 1

	self:ChekcAllHasLeftDigTimes()
	pPlayer.CallClientScript("Fuben:SetTargetInfo", string.format("剩餘採集次數：%d", (self.nMaxPickNum - self.tbDigNum[pPlayer.dwID])), self.nEndTime)
end

function tbFuben:ChekcAllHasLeftDigTimes()
	if self.bCreateGuohuoNpc  then
		return
	end

	if self.nCurnMineNum <= 0 then
		self.bCreateGuohuoNpc = true
	else
		for dwRoleId, nDigNum in pairs(self.tbDigNum) do
			if nDigNum < self.nMaxPickNum then
				return
			end
		end
		self.bCreateGuohuoNpc = true
	end

	if self.bCreateGuohuoNpc then
		KNpc.Add(self.tbSetting.nGuohuoNpcId, 1, 0, self.nMapId, unpack(self.tbSetting.tbGuohuoPoint))
		self:BlackMsg("篝火已點燃，可持續獲得經驗")
	end
end

function tbFuben:OnLogin()
	self:OnJoin(me)
end

function tbFuben:OnJoin(pPlayer)
	pPlayer.SetPkMode(0)
	local tbFubenInfo = {
		szName = self.tbSetting.szName,
		nEndTime = self.nEndTime,
	}
	if self.tbDigNum then
		tbFubenInfo.szName = string.format("剩餘採集次數：%d", self.nMaxPickNum - (self.tbDigNum[pPlayer.dwID] or 0) )
	end

	pPlayer.CallClientScript("Ui:OpenWindow", "HomeScreenFuben", "DungeonFuben", tbFubenInfo);
	if self.bBossKilled then
		pPlayer.CallClientScript("Fuben:ShowLeave");
	end
end

function tbFuben:OnPlayerDeath()
	me.Revive(0);
	me.AddSkillState(Fuben.RandomFuben.DEATH_SKILLID, 1, 0, 10000);
	me.nFightMode = 2;
	
	Timer:Register(FubenMgr.nReviveTime * Env.GAME_FPS, self.DoRevive, self, me.dwID);
	--客户端显示一个倒计时 todo
end

function tbFuben:ClearDeathState(pPlayer)
	pPlayer.RemoveSkillState(Fuben.RandomFuben.DEATH_SKILLID);
	pPlayer.nFightMode = 1;
end

function tbFuben:DoRevive(nPlayerId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return;
	end

	if pPlayer.nFightMode ~= 2 then
		return;
	end

	self:ClearDeathState(pPlayer);
end

function tbFuben:OnCreateBoss()
	local tbSet = FubenMgr.tbScendLevelSetting[self.nFubenLevel]
	local tbBossSet = tbSet.tbBossSetting
	local nTotalLevel = 0
	local nPlayerNum = 0
	local fnExcute = function (pPlayer)
		nPlayerNum = nPlayerNum + 1
		nTotalLevel = nTotalLevel + pPlayer.nLevel
	end
	self:AllPlayerExcute(fnExcute);
	local nBossLevel = math.ceil(nTotalLevel / nPlayerNum)

	local nBossId= unpack(tbBossSet[MathRandom(#tbBossSet)])
	local pNpc = KNpc.Add(nBossId, nBossLevel, 0, self.nMapId, unpack(self.tbSetting.tbBossPoint))
	if pNpc then
		self.nBossId = pNpc.nId
	end
end

function tbFuben:GameLost()
	self.bLost = true
	local fnExcute = function (pPlayer)
		pPlayer.SendBlackBoardMsg("神秘洞窟的存在時間已結束");
		FubenMgr:CheckReturnMapExplore(pPlayer, self.dwOwnerId)
	end
	self:AllPlayerExcute(fnExcute);
end