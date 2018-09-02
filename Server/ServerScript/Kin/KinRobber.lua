Require("ServerScript/Kin/KinData.lua");

local _KinData   = Kin._MetaKinData;
local _KinMember = Kin._MetaKinMember;

Kin.KinRobber = Kin.KinRobber or {};
local KinRobber = Kin.KinRobber;

function Kin:OpenKinRobber(nRound)
	Kin:TraverseKinInDiffTime(5, function (kinData)
		kinData:StartKinRobber(nRound);
	end);
end

-- tbRobber = { -- 家族盗贼数据 
-- 	tbNpcInfo = {
-- 		[id] = {
-- 			nTeamId = ...
-- 		}
-- 	nLastRound = 1; --上一次生效的轮数
-- }

function _KinData:GetRobberData()
	local kinCache = self:GetCacheData();
	if not kinCache.tbRobber then
		kinCache.tbRobber = {
			tbNpcInfo = {};
		};
	end

	return kinCache.tbRobber;
end


function _KinData:StartKinRobber(nRobRound)
	--[[
	local tbRobberData = self:GetRobberData();
	if tbRobberData.nKinNestActivateDay == Lib:GetLocalDay() then
        return;
    end
    ]]

	self:CallWithMap(self.OpenKinRobber, self, nRobRound);
end

function _KinData:OpenKinRobber(nRobRound)
	local nMapId = self:GetMapId()
	SetMapSurvivalTime(nMapId, GetTime()+Kin.RobDef.ActivityTime)

	local tbRobberData = self:GetRobberData();
	self:ClearKinRobber();

	tbRobberData.nLastRound = nRobRound;
	local tbNpcData = self:GetRobberNpcs();
	for _, tbInfo in pairs(tbNpcData) do
		local pNpc = KNpc.Add(unpack(tbInfo.tbDialogNpc));
		if pNpc then
			tbRobberData.tbNpcInfo[pNpc.nId] = {
				tbFightNpc = tbInfo.tbFightNpc;
			}
			pNpc.nRobberKinId = self.nKinId;
		end
	end

	ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.Kin, "佳節將至，幫派內卻忽現賊匪，諸位弟兄，收拾他們！（需組成2人以上隊伍）", self.nKinId);

	local nCount = 0;
	local nMaxCount = Kin.RobDef.ActivityTime / 60 / 10; -- 每10分钟提醒一次
	Timer:Register(Env.GAME_FPS * 10 * 60, function ()
		nCount = nCount + 1;
		if nCount < nMaxCount then
			local nLeftCount = Lib:CountTB(tbRobberData.tbNpcInfo);
			if nLeftCount > 0 then
				local szInfo = string.format("幫派中還有%d個盜賊在搗亂，諸位弟兄，剿滅他們！（需組成2人以上隊伍）", nLeftCount)
				ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.Kin, szInfo, self.nKinId);
			end
			return nLeftCount > 0;
		elseif nCount >= nMaxCount and tbRobberData.nLastRound == nRobRound then
			self:ClearKinRobber();
		end
	end)

	local tbMsgData = {
		szType = "KinRobber";
		nTimeOut = GetTime() + Kin.RobDef.ActivityTime;
	};

	self:TraverseMembers(function (memberData)
		local player = KPlayer.GetPlayerObjById(memberData.nMemberId);
		if player then
			player.CallClientScript("Ui:SynNotifyMsg", tbMsgData);
		end
		return true;
	end);

	self:NotifyRobberPos();
	Log("OpenKinRobber", self.nKinId, self.szName, Lib:CountTB(tbNpcData or {}));
end

function _KinData:NotifyRobberPos(nMemberId)
	local tbRobberData = self:GetRobberData();
	local tbPos = {};
	for nNpcId, _ in pairs(tbRobberData.tbNpcInfo) do
		local pNpc = KNpc.GetById(nNpcId);
		if pNpc then
			local _, nX, nY = pNpc.GetWorldPos();
			table.insert(tbPos, {nX, nY});
		end
	end

	local fnNotify = function (memberData)
		local player = KPlayer.GetPlayerObjById(memberData.nMemberId);
		if player then
			player.CallClientScript("Map:OnSyncNpcsPos", "Robber", tbPos);
		end
		return true;
	end

	if nMemberId then
		local memberData = Kin:GetMemberData(nMemberId);
		if memberData then
			fnNotify(memberData);
		end
	else
		self:TraverseMembers(fnNotify);
	end
end

function _KinData:ClearKinRobber()
	local tbRobberData = self:GetRobberData();
	local nRobberLeft = 0;
	for nNpcId, _ in pairs(tbRobberData.tbNpcInfo) do
		local pNpc = KNpc.GetById(nNpcId);
		tbRobberData.tbNpcInfo[nNpcId] = nil;
		if pNpc then
			pNpc.Delete();
			nRobberLeft = nRobberLeft + 1;
		end
	end

--[[
	if nRobberLeft > 0 then
		local nLostFound = 0;
		for i = 1, nRobberLeft do
			nLostFound = nLostFound + MathRandom(Kin.RobDef.FailLostFound[1], Kin.RobDef.FailLostFound[2]);
		end

		self:CostFound(nLostFound);
		local szMsg = string.format("家族被入侵的盗贼掠夺了%d建设资金。", nLostFound)
		ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.Kin, szMsg, self.nKinId);
	end
	]]
	self:NotifyRobberPos();
	Log("ClearKinRobber", self.nKinId, self.szName);
end

function _KinData:OnKinRobberActivate(pNpc, nTeamId, player)
	local tbRobberData = self:GetRobberData();
	for _, tbNpcInfo in pairs(tbRobberData.tbNpcInfo or {}) do
		if tbNpcInfo.nTeamId == nTeamId then
			if player then
				player.CenterMsg("一次只能打一個幫派盜賊");
			end
			return;
		end
	end

	local tbDialogNpcInfo = tbRobberData.tbNpcInfo[pNpc.nId];
	if not tbDialogNpcInfo or not tbDialogNpcInfo.tbFightNpc then
		player.CenterMsg("幫派盜賊已被他人點開");
		return;
	end
	
	tbRobberData.tbNpcInfo[pNpc.nId] = nil;
	pNpc.Delete();

	local pFightNpc = KNpc.Add(unpack(tbDialogNpcInfo.tbFightNpc));
	if pFightNpc then
		tbRobberData.tbNpcInfo[pFightNpc.nId] = {
			nTeamId = nTeamId;
		}
		pFightNpc.nRobberKinId = self.nKinId;
	end

	LogD(Env.LOGD_ActivityPlay, player.szAccount, player.dwID, player.nLevel, 0, Env.LOGD_VAL_TAKE_TASK, Env.LOGD_MIS_KIN_ROBBER, player.GetFightPower());
end

function _KinData:OnRobberDeath(pNpc, nKillerPlayerId)
	local tbRobberData = self:GetRobberData();
	local tbFightNpcInfo = tbRobberData.tbNpcInfo[pNpc.nId];

	if not tbFightNpcInfo then
		return;
	end
	tbRobberData.tbNpcInfo[pNpc.nId] = nil;

	local team = tbFightNpcInfo.nTeamId and TeamMgr:GetTeamById(tbFightNpcInfo.nTeamId);
	if team then
		local tbTeamMembers = team:GetMembers();
		for _, nMemberId in pairs(tbTeamMembers) do
			local kinMember = Kin:GetMemberData(nMemberId);
			if kinMember then
				kinMember:SendKillRobberReward();
			end
		end
	end

	if Lib:CountTB(tbRobberData.tbNpcInfo) == 0 then
		local nToday = Lib:GetLocalDay();
		if self.nLastRobberRewardDay ~= nToday then
			self.nLastRobberRewardDay = nToday;
			self.nKillAllRobberRound = 0;
		end

		self.nKillAllRobberRound = self.nKillAllRobberRound + 1;
		--[[
		local nRobPrestige = Kin.RobDef.KillAllRobberPrestige[self.nKillAllRobberRound];
		assert(nRobPrestige, "没配置对应轮数威望奖励" .. self.nKillAllRobberRound);
		self:AddPrestige(nRobPrestige, Env.LogWay_KinRobber);
		]]

		ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.Kin, "成功清掃所有的賊匪，區區小賊，竟敢來幫派中搗亂，勞煩諸位弟兄辛苦了！", self.nKinId);
		self:TraverseMembers(function (memberData)
			local member = KPlayer.GetPlayerObjById(memberData.nMemberId);
			if member and member.nMapTemplateId == Kin.Def.nKinMapTemplateId then
				member.SendBlackBoardMsg("成功將所有入侵的盜賊擊退！");
			end
			return true;
		end);

		local TotalCount = self.nNpcCount * (Kin.RobDef.MaxRewardPerDay - tbRobberData.nLastRound);
		local bOpen = Kin.KinNest:RandomActivity(self.nKinId, tbRobberData.nLastRound, TotalCount, self.nNpcLevel);
		if bOpen == true then
			 tbRobberData.nKinNestActivateDay = Lib:GetLocalDay();
		end
	end

	-- 击杀盗贼者与所在队伍好友,亲密度加50
	local killer = KPlayer.GetPlayerObjById(nKillerPlayerId) or {};
	Achievement:AddCount(killer, "FamilyRobber_1");
	
	local tbTeamMembers = TeamMgr:GetMembers(killer.dwTeamID or 0);
	for _, nPlayerID in pairs(tbTeamMembers) do
		if nPlayerID ~= nKillerPlayerId then
			FriendShip:AddImitityByKind(nPlayerID, nKillerPlayerId, Env.LogWay_KinRobber);
		end
	end
	
	self:NotifyRobberPos();

	LogD(Env.LOGD_ActivityPlay, killer.szAccount, killer.dwID, killer.nLevel, 0, Env.LOGD_VAL_FINISH_TASK, Env.LOGD_MIS_KIN_ROBBER, killer.GetFightPower());
end

KinRobber.tbNpcSetting = KinRobber.tbNpcSetting 
	or LoadTabFile("Setting/Kin/RobberNpc.tab", "ddddd", nil, {"DialogNpc", "FightNpc", "PosX", "PosY", "Series"});

local tbNpcSetting = KinRobber.tbNpcSetting;

function _KinData:GetRobberNpcs()
	local tbMemberList = self:GetMemberInfoList();
	local nTotalLevel = 0;
	for _, tbMemberInfo in pairs(tbMemberList) do
		nTotalLevel = nTotalLevel + tbMemberInfo.nLevel;
	end

	local nNpcLevel = math.floor(nTotalLevel/#tbMemberList);
	local nNpcCount = math.max(math.floor(#tbMemberList / 3), 9);

	if nNpcCount > #tbNpcSetting then
		nNpcCount = #tbNpcSetting;
	end

	self.nNpcCount = nNpcCount;
	self.nNpcLevel = nNpcLevel;

	local tbResult = {};
	local fnSelect = Lib:GetRandomSelect(#tbNpcSetting);
	for i = 1, nNpcCount do
		local tbNpcInfo = tbNpcSetting[fnSelect()];
		table.insert(tbResult, {
			tbDialogNpc = {
				tbNpcInfo.DialogNpc,
				nNpcLevel,
				tbNpcInfo.Series,
				self:GetMapId(),
				tbNpcInfo.PosX,
				tbNpcInfo.PosY,
			};

			tbFightNpc = {
				tbNpcInfo.FightNpc,
				nNpcLevel,
				tbNpcInfo.Series,
				self:GetMapId(),
				tbNpcInfo.PosX,
				tbNpcInfo.PosY,
			};
		});
	end

	return tbResult;
end

function _KinMember:SendKillRobberReward()
	local member = KPlayer.GetPlayerObjById(self.nMemberId);
	if not member then
		return;
	end

	local szMoneyName = Shop:GetMoneyName("Contrib");
	if DegreeCtrl:GetDegree(member, "KinRobReward") == DegreeCtrl:GetMaxDegree("KinRobReward", member) then
		--member.AddMoney("Contrib", Kin.RobDef.FirstKillContrib, Env.LogWay_KinRobberFirstKill);
		--member.CenterMsg(string.format("恭喜你获得%d%s", Kin.RobDef.FirstKillContrib, szMoneyName));
	end
	--member.AddMoney("Contrib", Kin.RobDef.KillRobberContribution, Env.LogWay_KinRobber);
	--member.CenterMsg(string.format("恭喜你获得%d%s", Kin.RobDef.KillRobberContribution, szMoneyName));

	if not DegreeCtrl:ReduceDegree(member, "KinRobReward", 1) then
		return;
	end

	member.SendAward({{"Item", Kin.RobDef.RewardItemId, 1}}, true, false, Env.LogWay_KinRobber );

	self.bNeedSave = true;
end

