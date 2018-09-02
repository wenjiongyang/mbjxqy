Require("ServerScript/Fuben/DungeonFuben/DungeonMgr.lua")
local tbFuben = Fuben:CreateFubenClass("DungeonFubenFloor1");
local FubenMgr = Fuben.DungeonFubenMgr;
local tbNpcKillAward = FubenMgr.tbNpcKillAward

function tbFuben:OnCreate(dwOwnerId)
	self.dwOwnerId = dwOwnerId
	self.nStartTime = GetTime();
	self.nReadyEndTime = self.nStartTime + self.tbSetting.nReadyTime

	self:Start();
	self.bCanInvite = true
	self.nPlayerCount = 0;
	self.tbJoinTime = {};
end

function tbFuben:OnFirstJoin(pPlayer)
	if pPlayer.dwID ~= self.dwOwnerId then --加入owner 的队伍
		local pOwner = KPlayer.GetPlayerObjById(self.dwOwnerId) 
		local szNotifyMsg = string.format("俠士[FFFE0D]%s[-]加入了神秘洞窟", pPlayer.szName)
		if pOwner then
			pOwner.CenterMsg(szNotifyMsg)
			ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.Team, szNotifyMsg, pOwner.dwTeamID);
		end
	else
		self.nPlayerCount = self.nPlayerCount + 1; --被邀请者的计数不加在这里是防止2个人同时点了接受邀请却在下一帧增加个数
	end

	self.tbJoinTime[pPlayer.dwID] = GetTime()
	if self.nPlayerCount >= FubenMgr.nMaxPlayerNum then
		local pOwner = KPlayer.GetPlayerObjById(self.dwOwnerId) 
		if pOwner then
			pOwner.CallClientScript("Fuben:HideInviteButton");
		end
	end
end

function tbFuben:OnLogin()
	self:OnJoin(me)
end

function tbFuben:OnJoin(pPlayer)
	pPlayer.SetPkMode(0)
	local tbFubenInfo = {
		szName = self.tbSetting.szName,
		nEndTime = self.nReadyEndTime,
		bOwner = (pPlayer.dwID == self.dwOwnerId),
	}
	pPlayer.CallClientScript("Ui:OpenWindow", "HomeScreenFuben", "DungeonFuben", tbFubenInfo);
end


function tbFuben:OnOwnerShowTaskDialog(nDialogId, bIsOnce)
	local pPlayer = KPlayer.GetPlayerObjById(self.dwOwnerId)
	if not pPlayer then
		return
	end
	pPlayer.CallClientScript("Ui:TryPlaySitutionalDialog", nDialogId, bIsOnce);
end

function tbFuben:OnOpenOwnerInvitePanel()
	local pPlayer = KPlayer.GetPlayerObjById(self.dwOwnerId)
	if  pPlayer then
		pPlayer.CallClientScript("Fuben:SetOpenUiAfterDialog", "DungeonInviteList")
	end
end


function tbFuben:OnOut(pPlayer)
	self:ClearDeathState(pPlayer);
	pPlayer.CallClientScript("Ui:CloseWindow", "HomeScreenFuben");
	--TODO 如果所有人都出去了也关闭
	if pPlayer.dwID == self.dwOwnerId then
		pPlayer.SendAward({{"item", FubenMgr.CREATE_FUBEN_AWARD, 1}}, true, false, Env.LogWay_FindDungeonAward)
		self.dwOwnerId = 0;
	end

	pPlayer.TLogRoundFlow(Env.LogWay_DungeonFuben, self.tbSetting.nMapTemplateId, 0, GetTime() - self.tbJoinTime[pPlayer.dwID]
 			, self.bLost and Env.LogRound_FAIL or Env.LogRound_SUCCESS, 0, 0); 

end

function tbFuben:OnPlayerDeath()
	me.Revive(1);
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

function tbFuben:OnCloseInvite()
	local pPlayer = KPlayer.GetPlayerObjById(self.dwOwnerId)
	if not pPlayer then
		return
	end
	pPlayer.CallClientScript("Fuben:HideInviteButton");
	self.bCanInvite = false
end

--地宫守护者被杀
function tbFuben:OnOpenGate()
	self.bGateOpened = true;
	local tbAward = FubenMgr.tbGateAward

	local fnExcute = function (pPlayer)
        pPlayer.SendAward(tbAward, true, false, Env.LogWay_DungeonFubenOpenGateAward)
    end
    self:AllPlayerExcute(fnExcute);

	local nRand = MathRandom()
	local szNotify = ""
	if nRand > FubenMgr.nRandFLooor2 then
		szNotify = "篝火已點燃，可持續獲得經驗"
		
		self:ChangeTrap("TrapRight", nil, nil, nil, nil, "LeaveFloor1")
		local nMapId = self.nMapId
		KNpc.Add(self.tbSetting.nLeavegGateNpcId, 1, 0, nMapId, unpack(self.tbSetting.tbLeavegGatePoint))
		KNpc.Add(self.tbSetting.nGuohuoNpcId, 1, 0, nMapId, unpack(self.tbSetting.tbGuohuoPoint))

		Timer:Register(Env.GAME_FPS * 60, function ()
			if Fuben.tbFubenInstance[nMapId] then
				Fuben.tbFubenInstance[nMapId]:BlackMsg("這個洞窟已經沒有什麼值得探索的了")
			end
		end)

	else
		szNotify = "邀請已關閉！左側出現一道入口！去看個究竟！"
		self:ChangeTrap("TrapLeft", nil, nil, nil, nil, "GotoNext")
		KNpc.Add(self.tbSetting.nNextGateNpcId, 1, 0, self.nMapId, unpack(self.tbSetting.tbNextGatePoint))

		--下一层的类型决定
		local nMaxLevel = 0
		local fnExcute = function (pPlayer)
			if pPlayer.nLevel > nMaxLevel then
				nMaxLevel = pPlayer.nLevel;
			end
			Achievement:AddCount(pPlayer, "Dungeon_4", 1)
		end
		self:AllPlayerExcute(fnExcute);
		--使用哪个事件等级的配置
		local nNextLevel = 0;
		local tbProb;
		for i,v in ipairs(FubenMgr.tbScendLevelSetting) do
			nNextLevel = i
			tbProb = v.tbProb
			if nMaxLevel <= v.nLevelEnd then
				break;
			end
		end

		self.nNextLevel = nNextLevel

		local nRand = MathRandom()
		for i, v in ipairs(tbProb) do
			if nRand <= v then
				self.nNextKind = i;
				break;
			end
		end
	end
	
	self:BlackMsg(szNotify)
	Log(string.format("DungeonFuben floor1 nMapId:%d, nRand:%d, nNextLevel:%d, nNextKind:%d", 
		self.nMapId, nRand, self.nNextLevel or 0, self.nNextKind or 0))
end

function tbFuben:GameLost()
	self.bLost = true;
	local fnExcute = function (pPlayer)
		pPlayer.SendBlackBoardMsg("神秘洞窟已經消失");
		FubenMgr:CheckReturnMapExplore(pPlayer, self.dwOwnerId)
	end
	self:AllPlayerExcute(fnExcute);
end

function tbFuben:OnLeaveFloor1()
	FubenMgr:CheckReturnMapExplore(me, self.dwOwnerId)
end

function tbFuben:OnGotoNext()
	if not self.nNextKind then
		Log("Error!!! tbFuben:GotoNext")
		return
	end
	if not self.bAppleyd then
		local dwRoleId = me.dwID
		local fnSucess = function (nMapId)
			self.nNextMapId = nMapId
			local pPlayer = KPlayer.GetPlayerObjById(dwRoleId)
			if pPlayer then
				pPlayer.SwitchMap(nMapId, 0, 0)
			end
		end
		local fnFailed = function ()
			self:Close();
		end

		local nMapTemplateId = 0;
		if self.nNextKind == FubenMgr.Kind_Boss then
			nMapTemplateId = FubenMgr.nMapTemplateIdBoss
		elseif self.nNextKind == FubenMgr.Kind_Stone then
			nMapTemplateId = FubenMgr.nMapTemplateIdMine	
		elseif self.nNextKind == FubenMgr.Kind_Silver then
			nMapTemplateId = FubenMgr.nMapTemplateIdSilver
		end

		local nPlayerNum = 0;
		for k,v in pairs(self.tbPlayer) do
			nPlayerNum = nPlayerNum + 1
		end

		Fuben:ApplyFuben(self.dwOwnerId, nMapTemplateId, fnSucess, fnFailed, self.nNextKind, self.nNextLevel, nPlayerNum, self.dwOwnerId);
		self.bAppleyd = true
	else 
		if not self.nNextMapId then
			return
		end
		me.SwitchMap(self.nNextMapId, 0, 0)
	end
end

function tbFuben:OnKillNpc(pNpc, pKiller)
	if self.bGateOpened then
		return
	end
	local nRandCoin = MathRandom(unpack(tbNpcKillAward))
	
	local szAwardDesc = string.format("恭喜您獲得了%d銀兩", nRandCoin)
	local fnExcute = function (pPlayer)
		pPlayer.CenterMsg(szAwardDesc, true)
		pPlayer.AddMoney("Coin", nRandCoin, Env.LogWay_DungeonMgrKill)
    end
    self:AllPlayerExcute(fnExcute);
end