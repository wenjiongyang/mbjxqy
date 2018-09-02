KinEscort.szKinEscortOpenMessage 		= "幫派運鏢活動開啟，各幫派管理可前往夜郎廢墟的委託人處接取押鏢任務";    --家族运镖活动开启系统通告
KinEscort.szKinEscortCloseMessage 		= "幫派運鏢活動結束";    --家族运镖活动关闭系统通告

KinEscort.szNpcTips = "一大堆的貨物要運出去，真是件頭疼的事情啊……";               --劫镖NPC提示语
KinEscort.szTitle   = "%s 幫派護送";                                              --镖车称号

KinEscort.tbKinChannelMsg = {                                                     --家族频道公告
	["szStart"] = "幫派鏢車已經發動！本次鏢車為%s,幫派成員儘快前去護送%s",        --镖车启动时，%s:颜色，%s坐标链接
	["szComplete"] = "幫派運鏢任務完成！",                                        --镖车完成时
	["szUnderAttack"] = "幫派鏢車正遭受攻擊, 請火速前往救援！%s",                 --镖车收到攻击时，%s坐标链接
	["szCrossHPStage"] = "幫派鏢車血量低於%d%%，掉落鏢物！",                      --镖车打到百分比时，%d：血量百分比
	["szUpgrade"] = "%s 花費%d幫派建設資金對幫派鏢車進行升階！目前品質為%s",      --镖车升阶时，%s：玩家名字，%s：品质，即颜色
	["szDeath"] = "幫派鏢車被%s擊破，本次幫派運鏢失敗！",                         --%s:killer
}

-- 镖车相对于接镖npc的偏移坐标
KinEscort.tbCarOffset = {
	x = -300,
	y = -300,
}

KinEscort.nAcceptCostFound = 40000;                                                 --接镖时花费家族建设资金
KinEscort.nAcceptCostFound2 = 50000;	--秦陵开放后接镖花费
KinEscort.nNpcAutoStartTime = 3*60;                                             --镖车自动开始运镖时间
KinEscort.nNpcProtectedTime = 10;                                                  --开始运镖后镖车的保护时间
KinEscort.nDropRewardDis = 800;                                                  --掉落劫镖奖励范围
KinEscort.nAddExpMaxTimes = 60;                                                    --跳经验次数上限，以防镖车在路上卡住导致无限经验
KinEscort.nAddExpDis = 500;                                                      --跳经验范围
KinEscort.nAddExpPerSecond = 10;                                                   --跳经验间隔(秒)
KinEscort.tbAttackNoticeInterval = 3;                                             --镖车遭受攻击提醒间隔，秒

KinEscort.tbNpcTemplate = {947, 948, 949, 950, 951};                              --对应镖车品质1~5的NpcId
KinEscort.tbQualityPro = {200, 460, 240, 80, 20};                                    --对应初始接到镖车品质的概率
KinEscort.tbNpcUpgradeCost = {0, 160000, 600000, 800000, 2000000};                           --对应镖车升级到品质1~5的NpcId所需建设资金
KinEscort.tbNpcUpgradeCost2 = {0, 200000, 750000, 1000000, 2500000};	--秦陵开放后升级花费
KinEscort.tbNpcColor = {"白色", "綠色", "藍色", "紫色", "橙色"};            --对应镖车升级到品质1~5的NpcId所需建设资金
KinEscort.tbAddExpMultiple = {3.2,4,4.8,6,8};                                    --对应镖车品质的经验倍率
KinEscort.nRewardItemId = 1969	--资质丹
KinEscort.tbRewardItemRate = {30, 40, 60, 80, 100}	--奖励资质丹的概率，基数为100
KinEscort.tbAddKinPrestige = {60, 80, 100, 120, 160}	--对于增加家族威望点数
KinEscort.tbPrestigeRate = {1, 0.9, 0.9, 0.8, 0.8, 0.7, 0.6, 0.5}	--镖车血量状态对应的威望比例

KinEscort.szDropRewardWrodMsg = "鏢車被擊毀，掉落部分物品";                       --劫镖过程掉落物品世界通告
KinEscort.tbDropRewardCount = {5,3,2};                       					  --劫镖过程名次对应掉落奖励份数
KinEscort.nPerPlayerRewardMax = 2;                       					      --劫镖过程每人获得奖励最多份数
KinEscort.nPlayerRobMaxCount = 3;                       					      --玩家每天最大获得劫镖奖励次数

--以下由程序配置
KinEscort.States = {
	beforeAfter = 1,		--未接或者已完成
	prepare = 2,			--已接镖未开跑
	running = 3,
}

function KinEscort:IsOpen()
	return self.bOpen
end

function KinEscort:GetKinEscortData(dwKinId)
	if not self.tbKinEscortStatus[dwKinId] then
		self.tbKinEscortStatus[dwKinId] = {
			nKinID = 0,
			nCarriageNpcId = -1,
			nState = self.States.beforeAfter,
		}
	end
	return self.tbKinEscortStatus[dwKinId]
end

function KinEscort:LoadRewardTabFile()
	local tbRewardTabSource = LoadTabFile("Setting/Activity/EscortReward.tab", "ddsss", nil, {"nQuality", "nHpStage", "szDropConfig", "tbArrival", "tbArrival2"});
	local tbReward = {};

	for _,tb in pairs(tbRewardTabSource) do
		local quality = tb.nQuality
		tbReward[quality] = tbReward[quality] or {}
		tbReward[quality].tbStageReward = tbReward[quality].tbStageReward or {}
		table.insert(tbReward[quality].tbStageReward, {
			nQuality = quality,
			nHpStage = tb.nHpStage,
			szDropConfig = tb.szDropConfig,
			tbArrival = Lib:GetAwardFromString(tb.tbArrival),
			tbArrival2 = Lib:GetAwardFromString(tb.tbArrival2),
		})
	end

	local tbUpgradeCost = self:GetNpcUpgradeCost()
	for nQuality in pairs(tbReward) do
		tbReward[nQuality].nNpcTemplateId = self.tbNpcTemplate[nQuality];
		tbReward[nQuality].nNpcUpgradeCost = tbUpgradeCost[nQuality];
		table.sort(tbReward[nQuality].tbStageReward, function (a, b)
			return a.nHpStage > b.nHpStage;
		end);
	end
	self.tbReward = tbReward
end

function KinEscort:LoadAiPath()
	self.tbMapDestSetting = LoadTabFile("Setting/Activity/EscortAIPathPos.tab", "ddddds", nil, {"nMapId", "nIdx", "nX", "nY", "nProbability", "szRobNpcs"})
	self.tbDestinationSetting = self.tbDestinationSetting or {}
	for _,tbSetting in pairs(self.tbMapDestSetting) do
		local nMapId = tbSetting.nMapId
		local tb = self.tbDestinationSetting[nMapId] or {}
		table.insert(tb, tbSetting)
		self.tbDestinationSetting[nMapId] = tb
	end
	for k,v in pairs(self.tbDestinationSetting) do
		table.sort(self.tbDestinationSetting[k], function(a, b) return a.nIdx<b.nIdx end)
	end
end

function KinEscort:InitQuality()
	for nIndex,nProbability in ipairs(self.tbQualityPro) do
		if nIndex > 1 then
			self.tbQualityPro[nIndex] = self.tbQualityPro[nIndex - 1] + nProbability
		end
	end
end

function KinEscort:Init()
	self.bOpen = false
	self.tbKinEscortStatus = {}
	self:LoadAiPath()
	self:InitQuality()
	self:LoadRewardTabFile()
end

function KinEscort:IsImperialTombOpen()
	return GetTimeFrameState(ImperialTomb.OPEN_TIME_FRAME)==1
end

function KinEscort:GetAcceptCostFound()
	return self:IsImperialTombOpen() and self.nAcceptCostFound2 or self.nAcceptCostFound
end

function KinEscort:GetNpcUpgradeCost()
	return self:IsImperialTombOpen() and self.tbNpcUpgradeCost2 or self.tbNpcUpgradeCost
end

function KinEscort:CheckAccept(tbKin)
	if not self:IsLevelEnough(me) then
		return false, string.format("%d級以上才可以參加", self.nMinAttendLevel)
	end

	if not tbKin then
		return false, "你還沒有幫派哦";
	end

	if tbKin:GetLastKinEscortDate() == Lib:GetLocalDay() then
		return false, "接鏢失敗，你的幫派今天已經接過鏢了";
	end

	if self.tbKinEscortStatus[tbKin.nKinId].nCarriageNpcId ~= -1 then
		return false, "接鏢失敗，幫派鏢車已經存在";
	end

	if self:GetAcceptCostFound() > tbKin:GetFound() then
		return false, "幫派建設資金不足";
	end

	return true;
end

function KinEscort:SyncClient(nKinId)
	local status = self.tbKinEscortStatus[nKinId]
	local nCarriageNpcId = status.nCarriageNpcId
	local bShow = status.nState~=KinEscort.States.beforeAfter

	local nMapId, nX, nY
	if bShow then
		local pCarriageNpc = KNpc.GetById(nCarriageNpcId)
		if pCarriageNpc then
			nMapId, nX, nY = pCarriageNpc.GetWorldPos()
		end
	end

	local members = Kin:GetKinMembers(nKinId)
	for nMemberId in pairs(members) do
        local player = KPlayer.GetPlayerObjById(nMemberId)
        if player then
            player.CallClientScript("Kin:OnSyncEscortInfo", {
            	nMapId = nMapId,
            	nX = nX,
            	nY = nY,
            })
        end
    end

    return bShow
end

function KinEscort:OnAcceptEscortTask(nPlayerId, tbKin, pNpc)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId)
	local bRet, szMsg = self:CheckAccept(tbKin)
	if not bRet then
		pPlayer.CenterMsg(szMsg)
		return
	end

	tbKin:CostFound(self:GetAcceptCostFound())

	local nRanVal = MathRandom(1, self.tbQualityPro[#self.tbQualityPro])
	local nQuality = 1
	for i,rate in ipairs(self.tbQualityPro) do
		if nRanVal<=rate then
			nQuality = i
			break
		end
	end

	local npcMapId, npcPosX, npcPosY = pNpc.GetWorldPos()
	local pCarriageNpc = KNpc.Add(self.tbReward[nQuality].nNpcTemplateId, pPlayer.nLevel, 1,
								 npcMapId, npcPosX+self.tbCarOffset.x, npcPosY+self.tbCarOffset.y)
	local nKinId = tbKin.nKinId
	pCarriageNpc.dwKinId = nKinId
	pCarriageNpc.nQuality = nQuality
	pCarriageNpc.tbJoinPlayer = {}
	pCarriageNpc.SetActiveForever(1)
	pCarriageNpc.SetTitle(string.format(self.szTitle, tbKin.szName))
	pCarriageNpc.SetProtected(1)

	self.tbKinEscortStatus[nKinId].nCarriageNpcId = pCarriageNpc.nId
	self.tbKinEscortStatus[nKinId].nState = self.States.prepare
	tbKin:UpdateLastKinEscortDate()

	Timer:Register(self.nNpcAutoStartTime*Env.GAME_FPS, function()
		local tbKinState = self:GetKinEscortData(nKinId)
		if tbKinState.nState==self.States.prepare then
			self:StartEscortAndStartAddExp(nKinId)
		end
	end)

	Timer:Register(Env.GAME_FPS, function()
		return self:SyncClient(nKinId)
	end)
end

function KinEscort:StartEscortAndStartAddExp(nKinId)
	local tbEscortData = self:GetKinEscortData(nKinId)
	if not tbEscortData or tbEscortData.nState~=self.States.prepare then
		Log("KinEscort:StartEscortAndStartAddExp failed", nKinId, tbEscortData)
		if tbEscortData then
			Log("\t", tbEscortData.nState)
		end
		return
	end
	local nCarriageNpcId = tbEscortData.nCarriageNpcId
	local nCurrDestIndex = 1

	local pCarriageNpc = KNpc.GetById(nCarriageNpcId)
	Timer:Register(self.nNpcProtectedTime*Env.GAME_FPS, function()
		pCarriageNpc.SetProtected(0)
	end)

	self:OnAddExpToAroundPlayer(nCarriageNpcId)
	self.tbKinEscortStatus[nKinId].nState = self.States.running
	pCarriageNpc.tbRobIds = {}

	pCarriageNpc.nRegHpNotifyId = Npc:RegisterNpcHpChange(pCarriageNpc, function(nOldHp, nNewHp, nMaxHp)
		self:OnNpcHpChange(nOldHp, nNewHp, nMaxHp)
	end)
	pCarriageNpc.nRegDeathNotifyId = Npc:RegNpcOnDeath(pCarriageNpc, self.OnDeath, self)

	self:OnStartEscort(nCarriageNpcId, nCurrDestIndex)

	local nMapID, nX, nY = pCarriageNpc.GetWorldPos();
	local szMapName = Map:GetMapName(pCarriageNpc.nMapTemplateId);
	local szLocaltion = string.format("<%s(%d,%d)>", szMapName, math.floor(nX * Map.nShowPosScale), math.floor(nY * Map.nShowPosScale));
	ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.Kin, string.format(self.tbKinChannelMsg.szStart,self.tbNpcColor[pCarriageNpc.nQuality], szLocaltion),
		nKinId, {nLinkType = ChatMgr.LinkType.Position, linkParam = {nMapID, nX, nY, pCarriageNpc.nMapTemplateId}});


	local kinData = Kin:GetKinById(nKinId);
	if kinData then
		kinData:CacheKinEscortColor(KinEscort.tbNpcColor[pCarriageNpc.nQuality]);
	end
end

function KinEscort:CheckStartEscort(nCarriageNpcId, nCurrDestIndex)
	local pCarriageNpc = KNpc.GetById(nCarriageNpcId)
	if not pCarriageNpc then
		return false
	end

	local tbKinState = self:GetKinEscortData(pCarriageNpc.dwKinId)
	if tbKinState.nState~=self.States.running then
		return false, pCarriageNpc
	end

	local tbDesSetting = self.tbDestinationSetting[pCarriageNpc.nMapTemplateId];
	if not tbDesSetting then
		Log(string.format("ERROR:Have not config DestinationSetting of nMapTemplateId:%d", pCarriageNpc.nMapTemplateId))
		return false, pCarriageNpc
	end

	return true, pCarriageNpc, tbDesSetting
end

-- szRobNpcs: npcId1|count1;npcId2|count2;...;
function KinEscort:SpawnRobNpcs(pCarriageNpc, nCurrDestIndex, szRobNpcs)
	if not szRobNpcs or szRobNpcs=="" then return end
	local robs = {}
	local tbGrps = Lib:SplitStr(szRobNpcs, ";")
	if #tbGrps<=0 then return end
	for _,v in ipairs(tbGrps) do
		if string.len(v)>0 then
			local tb = Lib:SplitStr(v, "|")
			assert(#tb>=2, v)
			table.insert(robs, {
				id = tonumber(tb[1]),
				count = tonumber(tb[2]),
			})
		end
	end

	local nMapId,nX,nY = pCarriageNpc.GetWorldPos()
	for _,v in ipairs(robs) do
		for i=1,v.count do
			local offsetX = MathRandom(0,800)-400
			local offsetY = MathRandom(0,800)-400
			local pRobNpc = KNpc.Add(v.id, pCarriageNpc.nLevel, 1, nMapId, nX+offsetX, nY+offsetY)
			pRobNpc.dwKinId = 0
			pRobNpc.SetPkMode(Player.MODE_PK)
			pRobNpc.nRegDeathNotifyId = Npc:RegNpcOnDeath(pRobNpc, self.OnRobDeath, self, pCarriageNpc.nId, nCurrDestIndex);
			table.insert(pCarriageNpc.tbRobIds, pRobNpc.nId)
		end
	end
end

function KinEscort:OnStartEscort(nCarriageNpcId, nCurrDestIndex)
	local bRet, pCarriageNpc, tbDesSetting = self:CheckStartEscort(nCarriageNpcId, nCurrDestIndex);
	if  not bRet then
		if pCarriageNpc then
			pCarriageNpc.Delete();
		end
		return;
	end

	if nCurrDestIndex > #tbDesSetting then
		self:OnArrival(nCarriageNpcId);
		return;
	end

	local  nRandomVal = (MathRandom(1, 100))/100;
	if tbDesSetting[nCurrDestIndex-1] and nRandomVal < tbDesSetting[nCurrDestIndex-1].nProbability then
		self:SpawnRobNpcs(pCarriageNpc, nCurrDestIndex, tbDesSetting[nCurrDestIndex-1].szRobNpcs)
	else
		pCarriageNpc.AI_ClearMovePathPoint();
		pCarriageNpc.AI_AddMovePos(tbDesSetting[nCurrDestIndex].nX, tbDesSetting[nCurrDestIndex].nY);
		pCarriageNpc.tbOnArrive = {self.OnStartEscort, self, nCarriageNpcId, nCurrDestIndex + 1};
		pCarriageNpc.AI_StartPath(0);
	end
end

function KinEscort:OnRobDeath(nCarriageNpcId, nCurrDestIndex, pKiller)
	local pCarriageNpc = KNpc.GetById(nCarriageNpcId)
	if not pCarriageNpc then
		return
	end

	for i,id in ipairs(pCarriageNpc.tbRobIds) do
		if id==him.nId then
			table.remove(pCarriageNpc.tbRobIds, i)
			break
		end
	end

	if not next(pCarriageNpc.tbRobIds) then
		local tbDesSetting = self.tbDestinationSetting[pCarriageNpc.nMapTemplateId];
		pCarriageNpc.AI_ClearMovePathPoint();
		pCarriageNpc.AI_AddMovePos(tbDesSetting[nCurrDestIndex].nX, tbDesSetting[nCurrDestIndex].nY);
		pCarriageNpc.tbOnArrive = {self.OnStartEscort, self, nCarriageNpcId, nCurrDestIndex + 1 };
		pCarriageNpc.AI_StartPath(0);
	end
end

function KinEscort:OnFinish(nCarriageNpcId)
	local pCarriageNpc = KNpc.GetById(nCarriageNpcId);
	if not pCarriageNpc then
		return false
	end

	if pCarriageNpc.nRegHpNotifyId > 0 then
		Npc:UnRegisterNpcHpEvent(pCarriageNpc.nId, pCarriageNpc.nRegHpNotifyId);
	end

	if pCarriageNpc.nRegDeathNotifyId and pCarriageNpc.nRegDeathNotifyId>0 then
		Npc:UnRegNpcOnDeath(pCarriageNpc.nId, pCarriageNpc.nRegDeathNotifyId);
	end

	local tbKinState = self:GetKinEscortData(pCarriageNpc.dwKinId);
	if tbKinState.nState ~= self.States.running then
		return false
	end

	self.tbKinEscortStatus[pCarriageNpc.dwKinId].nCarriageNpcId = -1;
	self.tbKinEscortStatus[pCarriageNpc.dwKinId].nState = self.States.beforeAfter

	for _,id in ipairs(pCarriageNpc.tbRobIds) do
		local pRob = KNpc.GetById(id)
		if pRob then
			pRob.Delete()
		end
	end
	pCarriageNpc.tbRobIds = {}

	local tbArrivalReward = self.tbReward[pCarriageNpc.nQuality].tbStageReward;
	if tbArrivalReward == nil then
		Log(string.format("ERROR:in KinEscort:OnFinish tbArrivalReward == nil(pCarriageNpc.nQuality = %d)",pCarriageNpc.nQuality));
		return false;
	end

	return true, pCarriageNpc, tbArrivalReward;
end

function KinEscort:OnArrival(nCarriageNpcId)
	local  bRet, pCarriageNpc, tbArrivalReward = self:OnFinish(nCarriageNpcId);
	if not bRet then
		if pCarriageNpc then
			pCarriageNpc.Delete();
		end
		return ;
	end

	ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.Kin, string.format(self.tbKinChannelMsg.szComplete), pCarriageNpc.dwKinId);
	local  nCurLiftPercent = (pCarriageNpc.nCurLife / pCarriageNpc.nMaxLife) * 100;
	local  nReachHPStage = 0;
	local  nRechIndex = 0;
	for nIndex, tbThisHPStage in ipairs(tbArrivalReward) do
		if nCurLiftPercent >= tbThisHPStage.nHpStage then
			nReachHPStage = tbThisHPStage.nHpStage;
			nRechIndex = nIndex;
			break;
		end
	end

	if nRechIndex <= 0 or nReachHPStage <0 then
		Log(string.format("ERROR:in KinEscort:OnArrival  nRechIndex(%d) <= 0 or nReachHPStage(%d) <0",nRechIndex,nReachHPStage));
		pCarriageNpc.Delete();
		return ;
	end

	self:GiveReward(pCarriageNpc, nRechIndex, tbArrivalReward, true)

	pCarriageNpc.Delete();
end

function KinEscort:GiveReward(pCarriageNpc, nRechIndex, tbArrivalReward, bArrive)
	local kinMembers = Kin:GetKinMembers(pCarriageNpc.dwKinId)
	local bImperialTombOpen = self:IsImperialTombOpen()
	for nId in pairs(pCarriageNpc.tbJoinPlayer) do
		if kinMembers[nId] then
			local tbAttach = bImperialTombOpen and tbArrivalReward[nRechIndex].tbArrival2 or tbArrivalReward[nRechIndex].tbArrival
			if MathRandom(100)<=self.tbRewardItemRate[pCarriageNpc.nQuality] then
				tbAttach = Lib:CopyTB(tbAttach)
				table.insert(tbAttach, {"item", self.nRewardItemId, 1})
			end
			Mail:SendSystemMail({
				To       = nId,
				Title    = "幫派運鏢獎勵",
				Text     = bArrive and "本次幫派運鏢順利完成，特發獎勵以資鼓勵" or "本次幫派運鏢失敗，望不要氣餒，再接再厲",
				From     = "幫派總管",
				tbAttach = tbAttach,
				nLogReazon = Env.LogWay_KinEscort,
			})

			if bArrive then
				local pPlayer = KPlayer.GetPlayerObjById(nId)
				if pPlayer then
					if pCarriageNpc.nQuality>=4 then
						Achievement:AddCount(pPlayer, "KinEscort_3", 1)
					end
					Achievement:AddCount(pPlayer, "KinEscort_4", 1)
				end
			end
		end
	end

	self:AddKinPrestige(pCarriageNpc, nRechIndex)
end

function KinEscort:AddKinPrestige(pCarriageNpc, nHpStageIndex)
	local nKinId = pCarriageNpc.dwKinId
	local tbKinData = Kin:GetKinById(nKinId)
	if not tbKinData then
		return
	end
	local nBase = self.tbAddKinPrestige[pCarriageNpc.nQuality]
	local rate = self.tbPrestigeRate[nHpStageIndex]
	tbKinData:AddPrestige(math.ceil(nBase*rate), Env.LogWay_KinEscort)
end

function KinEscort:CheckNpcHpChange(pCarriageNpc, nOldHp, nNewHp, nMaxHp)
	if nNewHp == nMaxHp then
		return false;
	end

	local tbKinState = self:GetKinEscortData(pCarriageNpc.dwKinId);
	if tbKinState.nState~=self.States.running then
		pCarriageNpc.Delete();
		return false;
	end

	local tbDropReward = self.tbReward[pCarriageNpc.nQuality].tbStageReward;
	if tbDropReward == nil then
		Log(string.format("ERROR:in KinEscort:CheckNpcHpChange tbDropReward == nil(pCarriageNpc.nQuality = %d)",pCarriageNpc.nQuality));
		return false;
	end

	local tbKin = Kin:GetKinById(pCarriageNpc.dwKinId);
	return true, tbKin, tbDropReward;
end

function KinEscort:SendUnderAttackMsg(nKinId, pCar)
	if pCar.nLastNoticeTime and GetTime()-pCar.nLastNoticeTime<self.tbAttackNoticeInterval then
		return
	end

	pCar.nLastNoticeTime = GetTime()
	local nMapID, nX, nY = pCar.GetWorldPos()
	local szMapName = Map:GetMapName(pCar.nMapTemplateId)
	local szLocaltion = string.format("<%s(%d,%d)>", szMapName, math.floor(nX * Map.nShowPosScale), math.floor(nY * Map.nShowPosScale))
	ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.Kin,
		string.format(self.tbKinChannelMsg.szUnderAttack, szLocaltion), nKinId, {
			nLinkType = ChatMgr.LinkType.Position,
			linkParam = {nMapID, nX, nY, pCar.nMapTemplateId},
		}
	)
end

function KinEscort:SendHpDropReward(nKinId, tbDropReward, nOldHp, nNewHp, nMaxHp)
	local nOldHpPercent = (nOldHp/nMaxHp)*100
	local nNewHpPercent = (nNewHp/nMaxHp)*100
	for _,tbThisHPStage in pairs(tbDropReward) do
		if nOldHpPercent>tbThisHPStage.nHpStage and nNewHpPercent<=tbThisHPStage.nHpStage then
			ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.Kin, string.format(self.tbKinChannelMsg.szCrossHPStage,tbThisHPStage.nHpStage), nKinId);
			local tbSourceDamage = him.GetDamageInfo();
			local tbSortDamage = self:ComputeDamInfoOfHPStage(him.nId, tbSourceDamage);
		    if tbSortDamage and #tbSortDamage>0 then
			    table.sort(tbSortDamage, function(a,b) return a.nTotalDamage>b.nTotalDamage end)

			    if tbSortDamage[1].nTotalDamage > 0 then
			    	for i=1,#self.tbDropRewardCount do
			    		local tbDamage = tbSortDamage[i];
			    		if tbDamage then
			    			local nPlayerId = tbDamage.nAttackRoleId
							if tbDamage.nTeamId > 0 then
								local tbTeam = TeamMgr:GetTeamById(tbDamage.nTeamId);
								if tbTeam then
									nPlayerId = tbTeam:GetCaptainId();
								end
							end
			    			self:AddRewardToAroundPlayerBySameTeam(him.nId, nPlayerId, tbDamage.nTeamId, i, tbThisHPStage);
			    		end
			    	end
			    else
			    	local pNpc = him.GetLastDamageNpc();
			    	if pNpc and pNpc.nPlayerID > 0 then
			    		self:AddRewardToAroundPlayerBySameTeam(him.nId, pNpc.nPlayerID, 0, 1, tbThisHPStage);
			    	end
				end
		    end

		    break
		end
	end
end

function KinEscort:OnNpcHpChange(nOldHp, nNewHp, nMaxHp)
	local bRet, tbKin, tbDropReward = self:CheckNpcHpChange(him, nOldHp, nNewHp, nMaxHp);
	if not bRet then
		return
	end

	self:SendUnderAttackMsg(tbKin.nKinId, him)
	self:SendHpDropReward(tbKin.nKinId, tbDropReward, nOldHp, nNewHp, nMaxHp)
end

function KinEscort:CheckUpgrade(nPlayerId, nCarriageNpcId, nFoundCost)
	local pCarriageNpc = KNpc.GetById(nCarriageNpcId);
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	local tbKin = Kin:GetKinById(pCarriageNpc.dwKinId);
	if nFoundCost > tbKin:GetFound() then
		pPlayer.CenterMsg("幫派建設資金不足")
		return false
	end

	local tbKinState = self:GetKinEscortData(pCarriageNpc.dwKinId);
	if tbKinState.nState~=self.States.prepare then
		pPlayer.CenterMsg("鏢車不在待發狀態，升階失敗!")
		return false
	end

	return true, pCarriageNpc, pPlayer, tbKin
end

function KinEscort:OnUpgrade(nPlayerId, nKinId, bConfirm)
	local tbEscortData = self:GetKinEscortData(nKinId)
	if not tbEscortData then
		Log("KinEscort:OnUpgrade data nil", nPlayerId, nKinId, bConfirm)
		return
	end

	local nCarriageNpcId = tbEscortData.nCarriageNpcId
	local pCarriageNpc = KNpc.GetById(nCarriageNpcId)
	if not pCarriageNpc then
		Log("KinEscort:OnUpgrade pCarriageNpc nil", nCarriageNpcId)
		return
	end

	local tbUpgradeCost = self:GetNpcUpgradeCost()
	local nFoundCost = tbUpgradeCost[pCarriageNpc.nQuality + 1];
	if not nFoundCost then
		Log("KinEscort:OnUpgrade, already top quality", pCarriageNpc.nQuality)
		return
	end
	local bRet, pCarriageNpc, pPlayer, tbKin = self:CheckUpgrade(nPlayerId, nCarriageNpcId, nFoundCost);
	if not bRet then
		return;
	end

	if not bConfirm  then
		pPlayer.MsgBox(string.format("花費%d幫派資金對鏢車進行升階嗎？", nFoundCost),
					   {{"確認", self.OnUpgrade, self, nPlayerId, nKinId, true}, {"取消"}});
		return ;
	end

	if not tbKin:CostFound(nFoundCost) then
		pPlayer.CenterMsg("幫派建設資金不足");
		return;
	end

	local nMapID, nX, nY = pCarriageNpc.GetWorldPos();
	local nChangeToNpcId = self.tbNpcTemplate[pCarriageNpc.nQuality + 1];
	local pNewCarriageNpc = KNpc.Add(nChangeToNpcId, pPlayer.nLevel, 1, nMapID, nX, nY);
	if not pNewCarriageNpc then
		return
	end

	pNewCarriageNpc.dwKinId = pCarriageNpc.dwKinId;
	pNewCarriageNpc.nQuality = pCarriageNpc.nQuality + 1;
	pNewCarriageNpc.tbJoinPlayer = pCarriageNpc.tbJoinPlayer
	pNewCarriageNpc.SetActiveForever(1);
	pNewCarriageNpc.SetTitle(string.format(self.szTitle,tbKin.szName));
	pNewCarriageNpc.SetProtected(1);
	pCarriageNpc.Delete();
	self.tbKinEscortStatus[tbKin.nKinId].nCarriageNpcId = pNewCarriageNpc.nId;
	ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.Kin, string.format(self.tbKinChannelMsg.szUpgrade,
		pPlayer.szName, nFoundCost, self.tbNpcColor[pNewCarriageNpc.nQuality]), tbKin.nKinId);
end

function KinEscort:OnDeath(pKiller)
	local bRet, pCarriageNpc, tbArrivalReward = self:OnFinish(him.nId);
	if not bRet or not pKiller or not pCarriageNpc then
		return
	end
	ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.Kin, string.format(self.tbKinChannelMsg.szDeath,pKiller.szName), him.dwKinId);
	self:GiveReward(pCarriageNpc, #self.tbPrestigeRate, tbArrivalReward, false)
end

function KinEscort:AddRewardToAroundPlayerBySameTeam(nCarriageNpcId, nPlayerId, nTeamId, nRanking, tbThisHPStage)
	local tbMembersAround = {};
	local pCarriageNpc = KNpc.GetById(nCarriageNpcId);
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer and nTeamId<=0 then
		Log("KinEscort:AddRewardToAroundPlayerBySameTeam failed", nCarriageNpcId, nPlayerId, nTeamId, nRanking)
		return
	end
	if nTeamId > 0 then
 		tbMembersAround = self:GetAroundPlayerBySameTeam(nCarriageNpcId, nTeamId);
	elseif self:CheckPlayerCanReward(pPlayer) then
		table.insert(tbMembersAround,{pPlayer = pPlayer,tbAward = {}});
	end

	local nTreasure = self.tbDropRewardCount[nRanking];
	if #tbMembersAround < (self.tbDropRewardCount[nRanking]/self.nPerPlayerRewardMax) then
		nTreasure = #tbMembersAround * self.nPerPlayerRewardMax;
	end

	local tbRewardPlayerList = Npc:AssignNormal(him, tbMembersAround,
					 							nTreasure,
					 							tbThisHPStage.szDropConfig);

	for _,pPlayer in pairs(tbRewardPlayerList) do
		self:AddPlayerRobCount(pPlayer);

		Achievement:AddCount(pPlayer, "KinEscort_2", 1)
	end
end

function KinEscort:GetPlayerJoinAndRobState(pPlayer)
	if pPlayer.GetUserValue(self.nSaveKeyUserValueId, self.nRefDateKey) ~= Lib:GetLocalDay() then
		pPlayer.SetUserValue(self.nSaveKeyUserValueId, self.nRefDateKey, Lib:GetLocalDay());
		pPlayer.SetUserValue(self.nSaveKeyUserValueId, self.nKinIdKey, -1);
		pPlayer.SetUserValue(self.nSaveKeyUserValueId, self.nRobCountKey, 0);
	end
	local nKinId = pPlayer.GetUserValue(self.nSaveKeyUserValueId, self.nKinIdKey);
	local nRobCount = pPlayer.GetUserValue(self.nSaveKeyUserValueId, self.nRobCountKey);
	return nKinId, nRobCount;
end

function KinEscort:AddPlayerRobCount(pPlayer)
	local _,nRobCount = self:GetPlayerJoinAndRobState(pPlayer)
	pPlayer.SetUserValue(self.nSaveKeyUserValueId, self.nRobCountKey, nRobCount+1)
end

function KinEscort:CheckPlayerCanReward(pPlayer)
	local _,nRobCount = self:GetPlayerJoinAndRobState(pPlayer)
	return self:IsLevelEnough(pPlayer) and nRobCount<self.nPlayerRobMaxCount
end

function KinEscort:GetAroundPlayerBySameTeam(nCarriageNpcId,nTeamId)
	local pCarriageNpc = KNpc.GetById(nCarriageNpcId);
	local tbPlayerSameTeam = {};
	if pCarriageNpc then
		local tbPlayer = KNpc.GetAroundPlayerList(nCarriageNpcId, self.nDropRewardDis);
		for _,pPlayer in pairs(tbPlayer) do
			if pPlayer.dwTeamID == nTeamId and self:CheckPlayerCanReward(pPlayer) then
				table.insert(tbPlayerSameTeam,{pPlayer = pPlayer,tbAward = {}});
			end
		end
	end
	return tbPlayerSameTeam;
end

function KinEscort:CheckAddExpToAround( nCarriageNpcId )
	local pCarriageNpc = KNpc.GetById(nCarriageNpcId);
	if pCarriageNpc == nil then
		return false;
	end

	pCarriageNpc.nAddExpCounter = pCarriageNpc.nAddExpCounter or 0;
	if pCarriageNpc.nAddExpCounter > self.nAddExpMaxTimes  then
		return false;
	end

	return true, pCarriageNpc;
end

function KinEscort:CheckPlayerCanJoin(pPlayer,dwKinId)
	local  nLastKinId = self:GetPlayerJoinAndRobState(pPlayer)
	return self:IsLevelEnough(pPlayer) and pPlayer.dwKinId==dwKinId and (nLastKinId==dwKinId or nLastKinId==-1)
end

function KinEscort:OnAddExpToAroundPlayer(nCarriageNpcId)
	local bRet, pCarriageNpc = self:CheckAddExpToAround(nCarriageNpcId);
	if not bRet then
		return
	end

	pCarriageNpc.nAddExpCounter = pCarriageNpc.nAddExpCounter + 1;
	local tbPlayer = KNpc.GetAroundPlayerList(nCarriageNpcId, self.nAddExpDis);
	for _, pPlayer in pairs(tbPlayer) do
		if self:CheckPlayerCanJoin(pPlayer, pCarriageNpc.dwKinId ) then
			pPlayer.SetUserValue(self.nSaveKeyUserValueId, self.nRefDateKey, Lib:GetLocalDay());
		    pPlayer.SetUserValue(self.nSaveKeyUserValueId, self.nKinIdKey, pCarriageNpc.dwKinId);

		    local nAddExpCount = self.tbAddExpMultiple[pCarriageNpc.nQuality]*pPlayer.GetBaseAwardExp()
		    pPlayer.AddExperience(nAddExpCount, Env.LogWay_KinEscort);
		    pCarriageNpc.tbJoinPlayer[pPlayer.dwID] = true

		    Achievement:SetCount(pPlayer, "KinEscort_1", 1)
		    SummerGift:OnJoinAct(pPlayer, "KinEscort")
		    Log("KinEscort:OnAddExpToAroundPlayer", pPlayer.dwKinId, pPlayer.dwID, pPlayer.szName, pCarriageNpc.nAddExpCounter)
		    pPlayer.TLog("KinMemberFlow", pPlayer.dwKinId, Env.LogWay_KinEscort, pCarriageNpc.nAddExpCounter, 0)
		end
	end
	self.nTimeTimer = Timer:Register(self.nAddExpPerSecond * Env.GAME_FPS, self.OnAddExpToAroundPlayer, self,nCarriageNpcId);
end

function KinEscort:ComputeDamInfoOfHPStage(nCarriageNpcId, tbDamageInfo)
	local pCarriageNpc = KNpc.GetById(nCarriageNpcId);
	assert(pCarriageNpc);
	if not pCarriageNpc.tbDamageOfStage then
		pCarriageNpc.tbDamageOfStage = {};
		table.insert(pCarriageNpc.tbDamageOfStage, tbDamageInfo);
		return tbDamageInfo;
	end

	local nThisStageIndex = #pCarriageNpc.tbDamageOfStage + 1;
	local tbThisStageDamgeInfo = {};

	for _,tbDam in pairs(tbDamageInfo) do
		local nNowTotalDamage = tbDam.nTotalDamage;
		local nBeforeStageIndex = nThisStageIndex-1;

		while nBeforeStageIndex > 0 do
			local tbBeforeDamgeInfo  = pCarriageNpc.tbDamageOfStage[nBeforeStageIndex];
			local nBeforeTotalDamage = self:GetDamgeValue(tbBeforeDamgeInfo, tbDam.nTeamId, tbDam.nAttackRoleId);

			nNowTotalDamage = nNowTotalDamage - nBeforeTotalDamage;
			nBeforeStageIndex = nBeforeStageIndex-1;
		end
		table.insert(tbThisStageDamgeInfo, {
			nTeamId = tbDam.nTeamId,
			nAttackRoleId = tbDam.nAttackRoleId,
			nTotalDamage = nNowTotalDamage,
		})
	end

	table.insert(pCarriageNpc.tbDamageOfStage, tbThisStageDamgeInfo);

	return tbThisStageDamgeInfo;
end

function KinEscort:GetDamgeValue(tbDamageInfo, nTeamId, nAttackRoleId)
	for _, tbDam in pairs(tbDamageInfo) do
		if tbDam.nTeamId == nTeamId and  tbDam.nAttackRoleId == nAttackRoleId then
			return tbDam.nTotalDamage ;
		end
	end
	return 0;
end

function KinEscort:Open()
	self.bOpen = true
	ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.System, self.szKinEscortOpenMessage)
	Calendar:OnActivityBegin("KinEscort")
end

function KinEscort:Close()
	self.bOpen = false
	ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.System, self.szKinEscortCloseMessage)
	Calendar:OnActivityEnd("KinEscort")
end
