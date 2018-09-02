Fuben.DungeonFubenMgr = Fuben.DungeonFubenMgr or {};
local DungeonFubenMgr = Fuben.DungeonFubenMgr;

DungeonFubenMgr.nMapTemplateIdFrist = 600 --地宫第一层 地图id
DungeonFubenMgr.nMapTemplateIdBoss = 601; -- 地宫二层 boss
DungeonFubenMgr.nMapTemplateIdMine = 602; -- 地宫二层 魂石
DungeonFubenMgr.nMapTemplateIdSilver = 603 -- 地宫二层 水晶

DungeonFubenMgr.nRandFLooor2 = 0.2875; --TODO  打开第二层的概率

DungeonFubenMgr.nMaxPlayerNum = 4; --最大四人队

DungeonFubenMgr.Kind_Boss = 1
DungeonFubenMgr.Kind_Stone = 2
DungeonFubenMgr.Kind_Silver = 3

DungeonFubenMgr.nReviveTime = 10 ; --10s倒计时复活

DungeonFubenMgr.tbBossAwardSetting = { -- Boss Npc Id 对应的奖励id，奖励id对应 Setting/BossLeader/PlayerDmgRankAward.tab
	[193] = 1;	--鹿王
	[194] = 2;	--狼王
	[195] = 3;	--猴王
	[197] = 9;	--豹王
	[198] = 7;	--狐王
	[199] = 8;	--双首异兽
	[1768] = 16;	--金刚
	[1769] = 17;	--鹏皇
	[1770] = 18;	--犀皇
	[2186] = 25;	--赤睛虎皇
	[2187] = 26;	--撼天熊皇
	[2188] = 27;	--紫背鳄皇	
	[2445] = 34;	--冰鳞蜥皇
	[2446] = 35;	--银钩蝎皇
	[2447] = 36;	--狂鬃獒皇	
}
DungeonFubenMgr.nBossAwardNum = 4; --上面随出的奖励随四份
DungeonFubenMgr.tbGateAward = {{"item", 968, 1}}; --开门奖励
DungeonFubenMgr.CREATE_FUBEN_AWARD = 792 --创建地宫者的奖励，随机道具id

DungeonFubenMgr.tbScendLevelSetting =  --第二层的设置  从小到大 --todo
{ 
	{ 
		nLevelEnd = 39,  --1到59级
		tbBossSetting = { {193}, {194}, {195} },--id, 等级，从里面随机
		nItemIdStone = 13, --RandomItemByLevel 的扩展参数一
		nItemIdCrystal = 28,
		tbProb = {0.35, 0, 0.65}, --分别对应 Boss Stone Crytal 的概率
	},  
	{ 
		nLevelEnd = 49,  --1到59级
		tbBossSetting = { {197}, {198}, {199} },--id, 等级，从里面随机
		nItemIdStone = 13, --RandomItemByLevel 的扩展参数一
		nItemIdCrystal = 28,
		tbProb = {0.35, 0, 0.65}, --分别对应 Boss Stone Crytal 的概率
	},  	
	{ 
		nLevelEnd = 59,  --1到59级
		tbBossSetting = { {197}, {198}, {199} },--id, 等级，从里面随机
		nItemIdStone = 13, --RandomItemByLevel 的扩展参数一
		nItemIdCrystal = 28,
		tbProb = {0.35, 0, 0.65}, --分别对应 Boss Stone Crytal 的概率
	},  
	{ 
		nLevelEnd = 69 , --60到69级
		tbBossSetting = { {1768}, {1769}, {1770} },--id, 等级，从里面随机
		nItemIdStone = 13,
		nItemIdCrystal = 28,
		tbProb = {0.35, 0, 0.65}, --分别对应 Boss Stone Crytal 的概率
	},  
	{ 
		nLevelEnd = 79 , --70 到79级
		tbBossSetting = { {1768}, {1769}, {1770} },--id, 等级，从里面随机
		nItemIdStone = 13,
		nItemIdCrystal = 28,
		tbProb = {0.35, 0, 0.65}, --分别对应 Boss Stone Crytal 的概率	
	},  
	{ 
		nLevelEnd = 89 , --80 到89级
		tbBossSetting = { {2186}, {2187}, {2188} },--id, 等级，从里面随机
		nItemIdStone = 13,
		nItemIdCrystal = 28,
		tbProb = {0.35, 0, 0.65}, --分别对应 Boss Stone Crytal 的概率的概率		
	},  
	{ 
		nLevelEnd = 99 , --90 到99级
		tbBossSetting = { {2186}, {2187}, {2188} },--id, 等级，从里面随机
		nItemIdStone = 13,
		nItemIdCrystal = 28,
		tbProb = {0.35, 0, 0.65}, --分别对应 Boss Stone Crytal 的概率	
	},
	{ 
		nLevelEnd = 129 , --100 到129级
		tbBossSetting = { {2445}, {2446}, {2447} },--id, 等级，从里面随机
		nItemIdStone = 13,
		nItemIdCrystal = 28,
		tbProb = {0.35, 0, 0.65}, --分别对应 Boss Stone Crytal 的概率	
	},  	  
}

--击杀一层小怪获得的奖励银两范围
DungeonFubenMgr.tbNpcKillAward = {
	50, 100
}

DungeonFubenMgr.tbMineRandXY 			= {7, 9}; --魂石 水晶数量的随机数
DungeonFubenMgr.nPickUpParam			= 2;	--最大

-----------------------
local function fnCheck()
	for i,v in ipairs(DungeonFubenMgr.tbScendLevelSetting) do
		local nLastProb = 0
		for i2,v2 in ipairs(v.tbProb) do
			v.tbProb[i2] = nLastProb + v2
			nLastProb = v.tbProb[i2]
		end
		assert(math.abs( nLastProb - 1) <= 0.001, i.." but " ..nLastProb)
	end
end

fnCheck()


--直接创建并传送该玩家 ,传送时有队伍拆队
function DungeonFubenMgr:CreateFuben(pPlayer, bFromExplore)
	local dwRoleId = pPlayer.dwID
	local function fnSucess(nMapId)
		local pPlayer = KPlayer.GetPlayerObjById(dwRoleId)
		if not pPlayer then
			return
		end
		if bFromExplore then
			MapExplore:Leave(pPlayer)
		end

		TeamMgr:RemoveFromQuickTeamWaitingList(pPlayer)

		if pPlayer.dwTeamID ~= 0 then
			TeamMgr:QuiteTeam(pPlayer.dwTeamID, pPlayer.dwID);
		end

		pPlayer.SetEntryPoint();	


		pPlayer.SwitchMap(nMapId, 0, 0);   
	end

	local function fnFailedCallback()
		pPlayer.CenterMsg("創建副本失敗，請稍後嘗試！")
	end

	Achievement:AddCount(pPlayer, "Dungeon_1", 1)

	Fuben:ApplyFuben(pPlayer.dwID, DungeonFubenMgr.nMapTemplateIdFrist, fnSucess, fnFailedCallback, pPlayer.dwID);
end

function DungeonFubenMgr:InvitePlayer(pPlayer, dwRoleId)
	local pPlayer2 = KPlayer.GetPlayerObjById(dwRoleId)
	if not pPlayer2 then
		return false, "對方未在線"
	end

	--邀请者需要在副本的准备阶段
	local tbInst = Fuben.tbFubenInstance[pPlayer.nMapId]
	if not tbInst or not tbInst.bCanInvite then
		return false, "只有在洞窟準備階段才能邀請"
	end

	if tbInst.dwOwnerId ~= pPlayer.dwID then
		return false, "只有洞窟的創建者才能邀請"
	end

	local nCount = DegreeCtrl:GetDegree(pPlayer2, "DungeonFubenInvited")
	if nCount <= 0 then
		return false, "對方的次數已用盡"
	end

	if pPlayer2.nLevel < MapExplore.MIN_LEVEL then
		return false, string.format("需要[FFFE0D]%d[-]級才能進入神秘洞窟", MapExplore.MIN_LEVEL)
	end

	if tbInst.nPlayerCount >= self.nMaxPlayerNum then
		pPlayer.CallClientScript("Ui:CloseWindow", "DungeonInviteList")
		return false, "目前神秘洞窟人數已滿"
	end

	local tbData = {
		szType = "InviteDungeon",
		nTimeOut = tbInst.nReadyEndTime, --消息超时时间
		szInviteName = pPlayer.szName,
		dwInviteRoleId = pPlayer.dwID,
	}

	pPlayer2.CallClientScript("Ui:SynNotifyMsg", tbData)
	return true, "成功發送邀請"
end

function DungeonFubenMgr:RandomInvite(pPlayer)
	--邀请者需要在副本的准备阶段
	local tbInst = Fuben.tbFubenInstance[pPlayer.nMapId]
	if not tbInst or not tbInst.bCanInvite then
		pPlayer.CenterMsg("只有在洞窟準備階段才能邀請")
		return 
	end

	if tbInst.dwOwnerId ~= pPlayer.dwID then
		pPlayer.CenterMsg("只有洞窟的創建者才能邀請")
		return 
	end

	if tbInst.nPlayerCount >= self.nMaxPlayerNum then
		pPlayer.CallClientScript("Ui:CloseWindow", "DungeonInviteList")
		pPlayer.CenterMsg("目前神秘洞窟人數已滿")
		return
	end

	local tbData = {
		szType = "InviteDungeon",
		nTimeOut = tbInst.nReadyEndTime, --消息超时时间
		szInviteName = pPlayer.szName,
		dwInviteRoleId = pPlayer.dwID,
	}

	local tbStranger = KPlayer.GetStranger(pPlayer.dwID, 20, 1);
	for i, v in ipairs(tbStranger) do
		local pTar = v.pPlayer
		if pTar and v.nLevel >= MapExplore.MIN_LEVEL then
			if DegreeCtrl:GetDegree(pTar, "DungeonFubenInvited") > 0 then
				pTar.CallClientScript("Ui:SynNotifyMsg", tbData)
			end
		end
	end

	pPlayer.CenterMsg("已向武林中的俠士發佈招募函，請靜待回音")
end

function DungeonFubenMgr:InviteApply(pPlayer, dwOwnerId)
	local pOwner = KPlayer.GetPlayerObjById(dwOwnerId)
	if not pOwner then
		pPlayer.CenterMsg("邀請者目前不線上")
		return
	end

	local tbInst = Fuben.tbFubenInstance[pOwner.nMapId]
	if not tbInst or not tbInst.bCanInvite then
		pPlayer.CenterMsg("該邀請已過期，神秘洞窟已經結束")
		return
	end

	if tbInst.dwOwnerId ~= dwOwnerId then
		pPlayer.CenterMsg("無效的邀請")
	end

	if tbInst.nPlayerCount >= self.nMaxPlayerNum then
		pPlayer.CenterMsg("神秘洞窟人數已滿")
		return
	end

	if not DegreeCtrl:ReduceDegree(pPlayer, "DungeonFubenInvited", 1) then
		pPlayer.CenterMsg("該俠士本日神秘洞窟被邀請次數已用盡")
		return
	end

	local bRet, szMsg = TeamMgr:DirectAddMember(dwOwnerId, pPlayer)
	if not bRet then
		pPlayer.CenterMsg(szMsg)
		return
	end

	tbInst.nPlayerCount = tbInst.nPlayerCount + 1; --如放在进入副本的话会延迟一帧

	FriendShip:AddImitityByKind(dwOwnerId, pPlayer.dwID, Env.LogWay_DungeonFuben)	

	pPlayer.SetEntryPoint();
	pPlayer.SwitchMap(pOwner.nMapId, 0, 0);
	Achievement:AddCount(pOwner, "Dungeon_2", 1)
	Achievement:AddCount(pPlayer, "Dungeon_3", 1)
end

function DungeonFubenMgr:CheckReturnMapExplore(pPlayer, dwOwnerId)
	--TODO 现在直接返回探索会有问题
	-- if pPlayer.nLastMapExploreMapId then
	-- 	local tbInst = Fuben.tbFubenInstance[pPlayer.nMapId];
	-- 	if tbInst then
	-- 		if not dwOwnerId then
	-- 			dwOwnerId = tbInst.dwOwnerId
	-- 		end
	-- 		if pPlayer.dwID == dwOwnerId then
	-- 			tbInst:OnOut(pPlayer)
		
	-- 			local bRet, szMsg = MapExplore:RequestExplore(pPlayer, pPlayer.nLastMapExploreMapId, true)
	-- 			pPlayer.nLastMapExploreMapId = nil;
	-- 			if bRet then
	-- 				pPlayer.bFromDungeonToExplore = true
	-- 				return
	-- 			end
	-- 		end	
	-- 	end
	-- 	pPlayer.nLastMapExploreMapId = nil;
	-- end
	pPlayer.GotoEntryPoint()
end