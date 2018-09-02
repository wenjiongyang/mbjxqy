local tbRequestGet = tbRequestGet or {} ; --接受请求者 [dwGetId][dwSendId] = nTimeOut
local tbRequestSend = tbRequestSend or {};--发起请求者 [dwSendId][dwGetId] = nTimeOut
local tbMapRegister = tbMapRegister or {}; --注册玩家的传入家族事件

ChuangGong.nEffectId = 1062 				-- 人身上的特效
ChuangGong.nMidEffectId = 1063              -- 中间的特效

ChuangGong.nHandSkill = 1061 				-- 伸手动作
ChuangGong.nSitSkill  = 1083 				-- 打坐动作

ChuangGong.nSelfEffectId = 1086 			-- 修炼身上的特效
ChuangGong.nSelfChuanGongDir = 56

local tbGeterEffect = {ChuangGong.nEffectId}
local tbSenderEffect = {ChuangGong.nEffectId, ChuangGong.nMidEffectId}

--直接对一个刚好给你发的发回去和从消息中心接受是调用同接口
function ChuangGong:RequestGetChuangGong(pPlayer, dwSendId)

	local dwGetId = pPlayer.dwID
	local nTimeNow = GetTime();
	local bCanDirProceed = false
	if tbRequestSend[dwSendId] and tbRequestSend[dwSendId][dwGetId]  then
		if tbRequestSend[dwSendId][dwGetId] > nTimeNow then
			bCanDirProceed = true
		end
		tbRequestSend[dwSendId][dwGetId] = nil;		
	end

	local pPlayer2 = KPlayer.GetPlayerObjById(dwSendId)
	if not pPlayer2 then
		pPlayer.CenterMsg("對方未在線")
		return
	end

	local nPlayerCount = ChuangGong:GetDegree(pPlayer, "ChuangGong")
	if nPlayerCount < 1 then
		pPlayer.CenterMsg("接受傳功次數不足")
		return
	end

	local nPlayer2Count = ChuangGong:GetDegree(pPlayer2, "ChuangGongSend")
	if nPlayer2Count < 1 then
		pPlayer.CenterMsg("對方已經沒有傳功次數了")
		return
	end

	local bRet, szMsg = self:CheckLevelLimi(pPlayer2.nLevel,pPlayer.nLevel,pPlayer2.GetVipLevel(),pPlayer.GetVipLevel())
	if not bRet then
		pPlayer.CenterMsg(szMsg)
		return
	end

	local nLastSendTime = pPlayer2.GetUserValue(self.SAVE_GROUP, self.KEY_SEND_TIME)
	local nCDTime = nLastSendTime + self.SEND_CD - nTimeNow
	if not ChuangGong.tbWithoutCDVip[pPlayer2.GetVipLevel()] and nCDTime > 0 then
		pPlayer.CenterMsg(string.format("對方還需要再等%d分鐘才能再次傳功", math.ceil(nCDTime / 60)))
		return
	end  

	if bCanDirProceed then
		self:PrcoceedChuangGong(pPlayer, pPlayer2)
		return
	end
	
	tbRequestGet[dwGetId] = tbRequestGet[dwGetId] or {}
	tbRequestGet[dwGetId][dwSendId] = nTimeNow + self.TIME_DELAY

	local tbData = {
		szType = "ChuangGongGet",
		nTimeOut = tbRequestGet[dwGetId][dwSendId], 
		szGetName = pPlayer.szName,
		dwGetId = dwGetId,
		dwKinId = pPlayer.dwKinId,
	};

	pPlayer2.CallClientScript("Ui:SynNotifyMsg", tbData)
	pPlayer.CenterMsg(string.format("你向「%s」發起了傳功請求，等待對方確認", pPlayer2.szName))
end


function ChuangGong:RequestSendChuangGong(pPlayer, dwGetId, bConFirm)

	local dwSendId = pPlayer.dwID
	local nTimeNow = GetTime();
	local bCanDirProceed = false
	if tbRequestGet[dwGetId] and tbRequestGet[dwGetId][dwSendId]  then
		if tbRequestGet[dwGetId][dwSendId]  > nTimeNow then
			bCanDirProceed = true
		end
		tbRequestGet[dwGetId][dwSendId] = nil;		
	end

	local nLastSendTime = pPlayer.GetUserValue(self.SAVE_GROUP, self.KEY_SEND_TIME)
	local nCDTime = nLastSendTime + self.SEND_CD - nTimeNow
	if not ChuangGong.tbWithoutCDVip[pPlayer.GetVipLevel()] and nCDTime > 0 then
		pPlayer.CenterMsg(string.format("您還需要再等%d分鐘才能再次傳功", math.ceil(nCDTime / 60)))
		return
	end  

	local pGeter = KPlayer.GetPlayerObjById(dwGetId)
	if not pGeter then
		pPlayer.CenterMsg("對方未在線")
		return
	end

	local nPlayerCount = ChuangGong:GetDegree(pPlayer, "ChuangGongSend")
	if nPlayerCount < 1 then
		pPlayer.CenterMsg("您的傳功次數不足")
		return
	end

	local nGeterCount = ChuangGong:GetDegree(pGeter, "ChuangGong")
	if nGeterCount == 0 and DegreeCtrl:GetDegree(pGeter, "ChuangGongBuy") == 0 then --todo BUY 最好就别判断了
		pPlayer.CenterMsg("對方的接受傳功次數不足，無法進行傳功")
		return
	end

	local bRet, szMsg = self:CheckLevelLimi(pPlayer.nLevel,pGeter.nLevel,pPlayer.GetVipLevel(),pGeter.GetVipLevel())
	if not bRet then
		pPlayer.CenterMsg(szMsg)
		return
	end

	if bCanDirProceed then
		self:PrcoceedChuangGong(pGeter, pPlayer)
		return
	end

	tbRequestSend[dwSendId] = tbRequestSend[dwSendId] or {}
	tbRequestSend[dwSendId][dwGetId]= nTimeNow + self.TIME_DELAY

	local tbData = {
		szType = "ChuangGongSend",
		nTimeOut = tbRequestSend[dwSendId][dwGetId],
		szSendName = pPlayer.szName,
		dwSendId = dwSendId,
		dwKinId = pPlayer.dwKinId,
	};

	pGeter.CallClientScript("Ui:SynNotifyMsg", tbData)
	pPlayer.CenterMsg(string.format("你向「%s」發起了傳功，等待對方確認", pGeter.szName))
end

-- 谁违法区域谁就是主动申请者，则特殊提示
function ChuangGong:IsAreaValid(pGeter, pSender)
	if not ChuangGong:IsWhiteMap(pGeter.nMapTemplateId) and (Map:GetClassDesc(pGeter.nMapTemplateId) ~= "fight" or pGeter.nFightMode ~= 0) then
		return false, string.format("「%s」接受了你的傳功請求，但你所在區域不可傳功", pSender.szName), string.format("「%s」所在區域不可傳功，傳功取消", pGeter.szName)
	elseif not ChuangGong:IsWhiteMap(pSender.nMapTemplateId) and (Map:GetClassDesc(pSender.nMapTemplateId) ~= "fight" or pSender.nFightMode ~= 0) then
		return false, string.format("「%s」所在區域不可傳功，傳功取消", pSender.szName), string.format("「%s」接受了你的傳功請求，但你所在區域不可傳功", pGeter.szName)
	elseif pGeter.nState and pGeter.nState == Player.emPLAYER_STATE_ALONE then
		return false, string.format("「%s」接受了你的傳功請求，但你所在區域不可傳功", pSender.szName), string.format("「%s」所在區域不可傳功，傳功取消", pGeter.szName)
	elseif pSender.nState and pSender.nState == Player.emPLAYER_STATE_ALONE then
		return false, string.format("「%s」所在區域不可傳功，傳功取消", pSender.szName), string.format("「%s」接受了你的傳功請求，但你所在區域不可傳功", pGeter.szName)
	end
	return true
end

function ChuangGong:IsCDValid(pGeter, pSender, bDisableCD)
	if bDisableCD then
		return true
	end

	local nLastSendTime = pSender.GetUserValue(self.SAVE_GROUP, self.KEY_SEND_TIME)
	local nCDTime = nLastSendTime + self.SEND_CD - GetTime()
	if not ChuangGong.tbWithoutCDVip[pSender.GetVipLevel()] and nCDTime > 0 then
		return false, string.format("「%s」還需要再等%d分鐘才能再次傳功", pSender.szName, math.ceil(nCDTime / 60))
	end
	return true
end

function ChuangGong:IsStateValid(pGeter, pSender)
	if pGeter.nMapTemplateId == Kin.Def.nKinMapTemplateId and pGeter.nFightMode ~= 0 then
		return false, string.format("「%s」接受了你的傳功請求，但你處於戰鬥狀態", pSender.szName), string.format("「%s」處於戰鬥狀態不可傳功，傳功取消", pGeter.szName)
	elseif pSender.nMapTemplateId == Kin.Def.nKinMapTemplateId and pSender.nFightMode ~= 0 then
		return false, string.format("「%s」處於戰鬥狀態不可傳功，傳功取消", pSender.szName), string.format("「%s」接受了你的傳功請求，但你處於戰鬥狀態不可傳功", pGeter.szName)
	elseif not Env:CheckSystemSwitch(pGeter, Env.SW_ChuangGong)	then
		return false, string.format("「%s」接受了你的傳功請求，但你當前狀態不允許傳功", pSender.szName), string.format("「%s」目前狀態不允許傳功，傳功取消", pGeter.szName)
	elseif not Env:CheckSystemSwitch(pSender, Env.SW_ChuangGong) then
		return false, string.format("「%s」目前狀態不允許傳功，傳功取消", pSender.szName), string.format("「%s」接受了你的傳功請求，但你當前狀態不允許傳功", pGeter.szName)
	end
	return true
end

function ChuangGong:GetSwitchMapInfo(pGeter, pSender, bOnlyKinMap)
	local fnSwithMap, nChuanGongMap, tbPos, tbNeedTrans;
	if pSender.dwKinId ~= 0 and pSender.dwKinId == pGeter.dwKinId then
		local nHitPosIndex = MathRandom(#self.tbKinMapPos)
		nChuanGongMap = Kin.Def.nKinMapTemplateId
		tbPos = self.tbKinMapPos[nHitPosIndex]

		local kinData = Kin:GetKinById(pGeter.dwKinId)
		fnSwithMap = function (pPlayer, i)
			kinData:GoMap(pPlayer.dwID, unpack(tbPos[i]))
		end
	elseif not bOnlyKinMap then
		local function GetComfortValue(pPlayer)
			local tbHouse = House:GetHouse(pPlayer.dwID);
			return tbHouse and tbHouse.nComfortValue or -1;
		end
		local nGeterComfort = GetComfortValue(pGeter)
		local nSenderComfort = GetComfortValue(pSender)
		local nHouseOwnerId = nGeterComfort>nSenderComfort and pGeter.dwID or pSender.dwID
		local bCanEnterHouse1 = House:CheckCanEnterHouse(pGeter, nHouseOwnerId, true)
		local bCanEnterHouse2 = House:CheckCanEnterHouse(pSender, nHouseOwnerId, true)
		if bCanEnterHouse1 and bCanEnterHouse2 then
			local nHitPosIndex = MathRandom(#self.tbHouseMapPos)
			tbPos = self.tbHouseMapPos[nHitPosIndex]
			local tbHouse = House:GetHouse(nHouseOwnerId)
			local tbSetting = House.tbHouseSetting[tbHouse.nLevel]
			nChuanGongMap = tbSetting.nMapTemplateId
			
			local nHouseMapId = House:GetHouseMap(nHouseOwnerId)
			tbNeedTrans = {
				pGeter.nMapId~=nHouseMapId,
				pSender.nMapId~=nHouseMapId,
			}

			fnSwithMap = function(pPlayer, i)
				House:EnterHouse(pPlayer, nHouseOwnerId, tbPos[i], nil, true);
			end
		else
			local nHitPosIndex = MathRandom(#self.tbXinShowMapPos)
			nChuanGongMap = self.tbXinShowMapPos[nHitPosIndex][1]
			tbPos = self.tbXinShowMapPos[nHitPosIndex][2]

			fnSwithMap = function (pPlayer, i)
			 	pPlayer.SwitchMap(nChuanGongMap, unpack(tbPos[i]))
			end;
		end
	end
	return fnSwithMap, nChuanGongMap, tbPos, tbNeedTrans
end

function ChuangGong:SwitchMap(pGeter, pSender, fnSwithMap, nChuanGongMap, tbPos, szType, tbNeedTrans)
	pSender.nChuanGongMap = nChuanGongMap
	pGeter.nChuanGongMap = nChuanGongMap

	local bWait = false;
	local dwSendId = pSender.dwID
	local dwGetId = pGeter.dwID
	local fnEncterMapCallBack = function (nMapTemplateId)
		self:OnEnterChuanGongMap(nMapTemplateId, dwGetId, dwSendId, szType, tbPos)
	end

	local tbPlayers = {pGeter, pSender}
	for i, pPlayer in ipairs(tbPlayers) do
		if pPlayer.nMapTemplateId ~= nChuanGongMap or (tbNeedTrans and tbNeedTrans[i]) then
			if tbMapRegister[pPlayer.dwID] then
				PlayerEvent:UnRegister(pPlayer, "OnEnterMap", tbMapRegister[pPlayer.dwID]);
			end
			tbMapRegister[pPlayer.dwID] = PlayerEvent:Register(pPlayer, "OnEnterMap", fnEncterMapCallBack);-- , 这里是注册，不用传参数dwGetId, dwSendId
			fnSwithMap(pPlayer, i)
			bWait = true
		end		
	end

	return bWait
end

function ChuangGong:GetSetting(szType)
	local tbSettings = {
		Default = {
			bDisableCD = false,
			bOnlyKinMap = true,
			bCheckDegree = true,
			bImitity = true,
			bAffectPersonal = true,
			bAffectKin = true,
			bLog = true,
			szThanks = "呼~多謝大俠！",
			nSendExp = self.nSendExp,
		},
		TeacherStudent = {
			bDisableCD = true,
			bOnlyKinMap = false,
			bCheckDegree = false,
			bImitity = true,
			bAffectPersonal = false,
			bAffectKin = false,
			bLog = false,
			szThanks = "呼~多謝師父！",
			nSendExp = TeacherStudent.Def.nChuanGongTeacherExpBase,
		},
	}
	return tbSettings[szType] or tbSettings.Default
end

function ChuangGong:PrcoceedChuangGong(pGeter, pSender, szType)
	local tbSetting = self:GetSetting(szType)

	--这里不用检查等级 次数了，前面检查过了才发过来
	local bOk, szErr, szSenderMsg = self:IsAreaValid(pGeter, pSender)
	if bOk then
		bOk, szErr = self:IsCDValid(pGeter, pSender, tbSetting.bDisableCD)
		if bOk then
			bOk, szErr, szSenderMsg = self:IsStateValid(pGeter, pSender)
		end
	end
	if not bOk then
		pGeter.CenterMsg(szErr, true)
		pSender.CenterMsg(szSenderMsg or szErr, true)
		return
	end

	local fnSwithMap, nChuanGongMap, tbPos, tbNeedTrans = self:GetSwitchMapInfo(pGeter, pSender, tbSetting.bOnlyKinMap)
	if not nChuanGongMap then
		return
	end

	if self:SwitchMap(pGeter, pSender, fnSwithMap, nChuanGongMap, tbPos, szType, tbNeedTrans) then
		return
	end

	--两人都在家族地图非战斗区域，开始传功
	self:BeginChuangGong(szType, pGeter, pSender, nChuanGongMap, tbPos)
end

function ChuangGong:GeterLevelExp(pPlayer)
	local nExp = 0
	for _,tbInfo in ipairs(self.tbGetLevelExp) do
		if pPlayer.nLevel < tbInfo[1] then
			nExp = tbInfo[2]
			break;
		else
			nExp = tbInfo[2]
		end
	end
	return nExp;
end

function ChuangGong:ReduceDegree(pPlayer, szType)
	local nCount, nDefault, nDan, nSaveIndex = ChuangGong:GetDegree(pPlayer, szType)
	if nCount <= 0 then
		return
	end
	if nDefault > 0 then
		if not DegreeCtrl:ReduceDegree(pPlayer, szType, 1) then
			return
		else
			return 1
		end
	elseif nDan > 0 then
		if nSaveIndex then
			pPlayer.SetUserValue(self.SAVE_GROUP, nSaveIndex, nDan - 1)
			return 2
		end
	end
end

function ChuangGong:CheckBeforeBegin(pGeter, pSender, bCheckDegree)
	if pGeter.nMapTemplateId ~= pSender.nMapTemplateId or pGeter.nMapId ~= pSender.nMapId then
		return false, "雙方地圖不匹配"
	end
	if not bCheckDegree then
		return true
	end
	local nPlayerCount = ChuangGong:GetDegree(pGeter, "ChuangGong")
	if nPlayerCount < 1 then
		return false, string.format("%s接受傳功次數不足", pGeter.szName)
	end

	local nPlayer2Count = ChuangGong:GetDegree(pSender, "ChuangGongSend")
	if nPlayer2Count < 1 then
		return false, string.format("%s傳功次數不足", pSender.szName)
	end
	return true
end

function ChuangGong:GetExtAwardRatio(pGeter, pSender)
	local fExtRatio = 0;

	local _, tbComfortSetting = House:GetBetterHouse(pGeter);
	local _, tbSenderComfort = House:GetBetterHouse(pSender);
	if tbSenderComfort and (not tbComfortSetting or tbSenderComfort.nLevel > tbComfortSetting.nLevel) then
		tbComfortSetting = tbSenderComfort;
	end

	if tbComfortSetting then
		fExtRatio = fExtRatio + tbComfortSetting.fChuangGongRatio;
	end

	return fExtRatio;
end

function ChuangGong:TryDoChuangGong(pGeter, pSender, nChuanGongMap, szType)
	Env:SetSystemSwitchOff(pGeter, Env.SW_All)
	Env:SetSystemSwitchOff(pSender, Env.SW_All)
	local tbSetting = self:GetSetting(szType)

	local nGetLevelExp = self:GeterLevelExp(pGeter)
	local nGetAdd = pGeter.GetBaseAwardExp() * nGetLevelExp;
	local nSendExp = tbSetting.nSendExp
	local nSendAdd = pGeter.GetBaseAwardExp() * nSendExp
	if pSender.nLevel - pGeter.nLevel >= self.nDoubleExpLevel then
		nGetAdd = nGetAdd * 2
	end

	local fExtRatio = self:GetExtAwardRatio(pGeter, pSender);
	if fExtRatio ~= 0 then
		nGetAdd = math.max(0, nGetAdd + math.floor(fExtRatio * nGetAdd));
		nSendAdd = math.max(0, nSendAdd + math.floor(fExtRatio * nSendAdd));
	end

	local nTimes = self.TIMES; --获得十次加经验
	pSender.nSendChuanggongTimes = nTimes
	local nGetAdd = math.floor(nGetAdd / nTimes)
	local nSendAdd = math.floor(nSendAdd / nTimes)

	local pGeterNpc = pGeter.GetNpc()
	local pSenderNpc = pSender.GetNpc()
	local nSendSkill,nGeterSkill = self:GetSkillId(szType)

	if pGeterNpc and pSenderNpc then 
		local _, nSenderX, nSenderY = pSenderNpc.GetWorldPos();
		local _, nGeterX, nGeterY = pGeterNpc.GetWorldPos();
		if szType == "TeacherStudent" then
			local nFaceX,nFaceY = self:GetFacePoint(nGeterX,nGeterY,nSenderX,nSenderY)       
			nGeterX = nFaceX
			nGeterY = nFaceY
			nSenderX = nFaceX
			nSenderY = nFaceY
		end
		
		pGeterNpc.CastSkill(nGeterSkill, 1, nSenderX, nSenderY);
		pSenderNpc.CastSkill(nSendSkill, 1, nGeterX, nGeterY);
	end
	
	ActionMode:DoForceNoneActMode(pGeter)
	ActionMode:DoForceNoneActMode(pSender)

	pGeter.AddSkillState(self.nEffectId, 1, 0, Env.GAME_FPS * self.TIME_DELTA * self.TIMES);
	pSender.AddSkillState(self.nEffectId, 1, 0,Env.GAME_FPS * self.TIME_DELTA * self.TIMES);
	pSender.AddSkillState(self.nMidEffectId, 1, 0,Env.GAME_FPS * self.TIME_DELTA * self.TIMES);

	pGeter.CallClientScript("ChuangGong:BeginChuangGong", nil, pSender.dwID, nGetAdd, nSendAdd, nChuanGongMap,pSender.szName, szType)
	pSender.CallClientScript("ChuangGong:BeginChuangGong", pGeter.dwID, nil, nGetAdd, nSendAdd, nChuanGongMap,pSender.szName, szType)

	Timer:Register(Env.GAME_FPS * self.TIME_DELTA, self.AddPlayerExp, self, pGeter.dwID, pSender.dwID, nGetAdd, nSendAdd, szType);
end

function ChuangGong:GetFacePoint(nGeterX, nGeterY, nSenderX, nSenderY)
	local dx, dy = nGeterX - nSenderX, nGeterY - nSenderY
	return nGeterX + dx, nGeterY + dy
end

function ChuangGong:GetSkillId(szType)
	szType = szType or ""
	if szType == "TeacherStudent" then
		return self.nHandSkill,self.nSitSkill
	end

	return self.nHandSkill,self.nHandSkill
end

function ChuangGong:SetPersonalValues(pGeter, pSender, bAffectPersonal)
	if not bAffectPersonal then
		return
	end
	pSender.SetUserValue(self.SAVE_GROUP, self.KEY_SEND_TIME, GetTime())
	EverydayTarget:AddCount(pSender, "ChuanGong");
	EverydayTarget:AddCount(pGeter, "ChuanGong");
	Achievement:AddCount(pGeter, "GetMeFight_1", 1)
	Achievement:AddCount(pSender, "GetMeFight_1", 1)
end

function ChuangGong:SetKinValues(pGeter, pSender, bAffectKin)
	if not bAffectKin then
		return
	end

	pSender.AddMoney("Contrib", self.nSendAddContrib, Env.LogWay_ChuangGongSend)

	local pSenderKinData = Kin:GetKinByMemberId(pSender.dwID);
	local pGeterKinData = Kin:GetKinByMemberId(pGeter.dwID);
	if pSenderKinData then
		pSenderKinData:SetCacheFlag("UpdateMemberInfoList", true);
	end
	if pGeterKinData then
		pGeterKinData:SetCacheFlag("UpdateMemberInfoList", true);
	end
end

function ChuangGong:RecordLog(pGeter, pSender, bLog)
	if not bLog then
		return
	end
	pSender.TLogRoundFlow(Env.LogWay_ChuangGong, Env.LogWay_ChuangGongSend, 0, 0, Env.LogRound_SUCCESS, 0, 0);
	pGeter.TLogRoundFlow(Env.LogWay_ChuangGong, Env.LogWay_ChuangGongGet, 0, 0, Env.LogRound_SUCCESS, 0, 0);

	AssistClient:ReportQQScore(pSender, Env.QQReport_IsJoinChuangGong, 1, 0, 1)
	AssistClient:ReportQQScore(pGeter, Env.QQReport_IsJoinChuangGong, 1, 0, 1)
end

--前面都检查完了，真正开始传功
function ChuangGong:BeginChuangGong(szType, pGeter, pSender, nChuanGongMap, tbPos)
	local tbSetting = self:GetSetting(szType)
	local bRet, szMsg = self:CheckBeforeBegin(pGeter, pSender, tbSetting.bCheckDegree)
	if not bRet then
		pGeter.CenterMsg(szMsg, true)
		pSender.CenterMsg(szMsg, true)
		return
	end
	local tbPlayers = {pGeter, pSender}
	for i, pPlayer in ipairs(tbPlayers) do
		pPlayer.SetPosition(unpack(tbPos[i]))
	end
	self:TryDoChuangGong(pGeter, pSender, nChuanGongMap, szType)
	Log("[ChuangGong] BeginChuangGong >>", szType or "Default", pGeter.szName, pGeter.dwID, pGeter.GetVipLevel(), pGeter.nLevel, pSender.szName, pSender.dwID, pSender.GetVipLevel(), pSender.nLevel)
end

function ChuangGong:DoBeginChuangGong(pGeter, pSender, szType)
	local tbSetting = self:GetSetting(szType)
	if tbSetting.bImitity then
		FriendShip:AddImitityByKind(pGeter.dwID, pSender.dwID, Env.LogWay_ChuangGong)
	end
	self:SetPersonalValues(pGeter, pSender, tbSetting.bAffectPersonal)
	self:SetKinValues(pGeter, pSender, tbSetting.bAffectKin)
	self:DoSpecialTask(szType, pGeter, pSender)
	self:RecordLog(pGeter, pSender, tbSetting.bLog)
end

function ChuangGong:DoSpecialTask(szType, pGeter, pSender)
	if szType=="TeacherStudent" then
		TeacherStudent:ChuanGongBegan(pSender, pGeter)
	end
end

function ChuangGong:AddPlayerExp(dwGetId, dwSendId, nGetAdd, nSendAdd, szType)
	local tbSetting = self:GetSetting(szType)

	local pGeter =  KPlayer.GetPlayerObjById(dwGetId)
	local pSender =  KPlayer.GetPlayerObjById(dwSendId)
	local pGeterNpc = pGeter and pGeter.GetNpc();
	local pSenderNpc = pSender and pSender.GetNpc();
	if not pGeter then
		if pSender then
			self:RemoveState(pSender, tbSenderEffect, "對方已下線,傳功結束")
		end
		return false
	end
	if not pSender then
		self:RemoveState(pGeter, tbGeterEffect, "對方已下線,傳功結束")
		return false
	end
	if not pGeter or not pSender then
		return false
	end
	local nTimes = pSender.nSendChuanggongTimes
	if not nTimes then
		self:RemoveState(pGeter, tbGeterEffect, "數據錯亂，傳功結束")
		self:RemoveState(pSender, tbSenderEffect, "數據錯亂，傳功結束")
		return false
	end
	if not pGeterNpc or not pSenderNpc then
		self:RemoveState(pGeter, tbGeterEffect, "找不到人了")
		self:RemoveState(pSender, tbSenderEffect, "找不到人了")
		return false
	end
	if pGeter.nMapTemplateId ~= pSender.nMapTemplateId or pGeter.nMapId ~= pSender.nMapId then
		self:RemoveState(pSender, tbSenderEffect, "對方切換了地圖，傳功結束")
		self:RemoveState(pGeter, tbGeterEffect, "對方切換了地圖，傳功結束")
		Log("ChuangGong diff map " , dwGetId, dwSendId, pGeter.nMapTemplateId, pSender.nMapTemplateId, pGeter.nMapId, pSender.nMapId)
		return false
	end
	local _, nSenderX, nSenderY = pSenderNpc.GetWorldPos();
	local _, nGeterX, nGeterY = pGeterNpc.GetWorldPos();
	local nDis = math.floor(math.sqrt(math.pow((nSenderX - nGeterX), 2) + math.pow((nSenderY - nGeterY), 2)));
	if nDis > self.MaxDistance then
		self:RemoveState(pSender, tbSenderEffect, "距離太遠傳功結束")
		self:RemoveState(pGeter, tbGeterEffect, "距離太遠傳功結束")
		Log("ChuangGong far dis " , dwGetId, dwSendId, nGeterX,nGeterY,nSenderX,nSenderY,nDis)
		return false
	end
	nTimes = nTimes - 1
	pSender.nSendChuanggongTimes = nTimes
	if nTimes <= 0 then
		pGeter.AddExperience(nGetAdd, Env.LogWay_ChuangGongGet)
		pSender.AddExperience(nSendAdd, Env.LogWay_ChuangGongSend)
		pSender.nSendChuanggongTimes = nil;
		self:RemoveState(pSender, tbSenderEffect)
		self:RemoveState(pGeter, tbGeterEffect)	
		ChatMgr:SendPlayerMsg(ChatMgr.ChannelType.Nearby, dwGetId, pGeter.szName, pGeter.nFaction, pGeter.nPortrait, pGeter.nLevel, tbSetting.szThanks)
		pGeter.CallClientScript("ChuangGong:SendOne", nTimes)
		pSender.CallClientScript("ChuangGong:SendOne", nTimes)
		return false
	else
		if nTimes == self.TIMES - 1 then
			local bRet, szMsg = self:DoReduceDegree(pGeter, pSender, tbSetting)
			if not bRet then
				self:RemoveState(pSender, tbSenderEffect, szMsg)
				self:RemoveState(pGeter, tbGeterEffect, szMsg)
				return false
			end
			self:DoBeginChuangGong(pGeter, pSender, szType)
			Log("ChuangGong StartChuangGong ", pGeter.dwID, pGeter.szName, pSender.dwID, pSender.szName)
		end
		pGeter.AddExperience(nGetAdd, Env.LogWay_ChuangGongGet)
		pSender.AddExperience(nSendAdd, Env.LogWay_ChuangGongSend)
		pGeter.CallClientScript("ChuangGong:SendOne", nTimes)
		pSender.CallClientScript("ChuangGong:SendOne", nTimes)
		return true
	end
end

function ChuangGong:DoReduceDegree(pGeter, pSender, tbSetting)
	if not tbSetting.bCheckDegree then
		return true
	end
	local nGeterRet = ChuangGong:ReduceDegree(pGeter, "ChuangGong")
	if not nGeterRet then
		return false, string.format("%s接受傳功次數扣除失敗", pGeter.szName)
	end

	local nSenderRet = ChuangGong:ReduceDegree(pSender, "ChuangGongSend")
	if not nSenderRet then
		return false, string.format("%s傳功次數扣除失敗", pSender.szName)
	end
	return true
end

function ChuangGong:RemoveState(pPlayer, tbEffect, szMsg)
	Env:SetSystemSwitchOn(pPlayer, Env.SW_All);
	local pNpc = pPlayer.GetNpc();
	if pNpc then
		pNpc.RestoreAction();
	end

	for _, nEffectId in pairs(tbEffect or {}) do
		pPlayer.RemoveSkillState(nEffectId);
	end

	pPlayer.CallClientScript("Ui:CloseWindow", "ChuangGongPanel")
	if szMsg then
		pPlayer.CenterMsg(szMsg)
	end
end

--自己就是参数是nil那一边 ,这个只是等待传功时触发一次。
function ChuangGong:OnEnterChuanGongMap(nMapTemplateId, dwGetId, dwSendId, szType, tbPos)
	if tbMapRegister[me.dwID] then
		PlayerEvent:UnRegister(me, "OnEnterMap", tbMapRegister[me.dwID]);
		tbMapRegister[me.dwID] = nil;
	end
	if me.nChuanGongMap ~= nMapTemplateId then
		return
	end
	local pGeter, pSender;
	if me.dwID == dwGetId then
		pGeter = me;
		pSender = KPlayer.GetPlayerObjById(dwSendId)
		if not pSender then
			me.CenterMsg("對方下線了")
			return
		end

		if pSender.nMapTemplateId ~= nMapTemplateId then
			return
		end
	else
		pSender = me;
		pGeter = KPlayer.GetPlayerObjById(dwGetId)
		if not pGeter then
			me.CenterMsg("對方下線了")
			return
		end

		if pGeter.nMapTemplateId ~= nMapTemplateId then
			return
		end
	end
	me.nChuanGongMap = nil;
	self:BeginChuangGong(szType, pGeter, pSender, nMapTemplateId, tbPos)
end

---------------------------------------------------------------------------
-- 打坐修炼
function ChuangGong:SelfChuanGong(nPlayerID)
    local pPlayer = KPlayer.GetPlayerObjById(nPlayerID)
    if not pPlayer then
    	return
    end

    local bRet,szMsg = self:CheckSelfChuanGong(pPlayer)
    if not bRet then
    	pPlayer.CenterMsg(szMsg)
    	return
    end

    if pPlayer.nMapTemplateId ~= Kin.Def.nKinMapTemplateId then
    	pPlayer.CenterMsg("請回到幫派再進行修煉",true)
		return
    end

    local nPlayerCount = ChuangGong:GetDegree(pPlayer, "ChuangGong")
	if nPlayerCount < 1 then
		pPlayer.CenterMsg("少俠被傳功次數不足，無法進行修煉",true)
		return
	end

	local nRet = ChuangGong:ReduceDegree(pPlayer, "ChuangGong")
	if not nRet then
		pPlayer.CenterMsg("被傳功次數扣除失敗", true)
		return false
	end

	self:BeginSelfChuanGong(pPlayer, nRet)
end

function ChuangGong:BeginSelfChuanGong(pPlayer, nRet)
	local nHit = MathRandom(#self.tbSelfKinMapPos)
	local tbPos = ChuangGong.tbSelfKinMapPos[nHit]
	if not tbPos then
		Log("[ChuangGong] BeginSelfChuanGong no pos", pPlayer.dwID, pPlayer.szName, nHit, nRet)
		return
	end

	local nPosX, nPosY = unpack(tbPos)
	pPlayer.SetPosition(nPosX, nPosY)

	Env:SetSystemSwitchOff(pPlayer, Env.SW_All)
	local nBaseExp = pPlayer.GetBaseAwardExp()
	local nAddExp = nBaseExp * self:SelfGetLevelExp(pPlayer)
	local nTimes = self.nSelfTimes; 
	pPlayer.nSelfChuangongTimes =  nTimes
	nAddExp = math.floor(nAddExp / nTimes)
	local pNpc = pPlayer.GetNpc()
	if pNpc then
		pNpc.CastSkill(self.nSitSkill, 1, nPosX, nPosY);
		pNpc.SetDir(self.nSelfChuanGongDir)
	else
		Log("[ChuangGong] BeginSelfChuanGong no Npc",pPlayer.dwID,pPlayer.szName,pPlayer.nLevel,nAddExp,nBaseExp)
	end
	ActionMode:DoForceNoneActMode(pPlayer)
	pPlayer.AddSkillState(self.nSelfEffectId, 1, 0, Env.GAME_FPS * self.nSelfDelayTime * self.nSelfTimes);

	Timer:Register(Env.GAME_FPS * self.nSelfDelayTime, self.AddSelfPlayerExp, self, pPlayer.dwID,nAddExp);

	pPlayer.CallClientScript("ChuangGong:BeginChuangGong", pPlayer.dwID, nil, nil, nil, Kin.Def.nKinMapTemplateId,nil, "SelfChuangGong")
	Log("[ChuangGong] BeginSelfChuanGong", pPlayer.dwID, pPlayer.szName, pPlayer.nLevel, nAddExp, nBaseExp, nRet or -1)
end

function ChuangGong:AddSelfPlayerExp(nPlayerID, nAddExp)

	local pPlayer =  KPlayer.GetPlayerObjById(nPlayerID)
	if not pPlayer then
		return false
	end
	local pNpc = pPlayer.GetNpc();

	if not pNpc or not pPlayer.nSelfChuangongTimes then
		pPlayer.RemoveSkillState(self.nSelfEffectId);
		Env:SetSystemSwitchOn(pPlayer, Env.SW_All);
		return false
	end

	if pPlayer.nMapTemplateId ~= Kin.Def.nKinMapTemplateId then
		pNpc.RestoreAction();
		pPlayer.RemoveSkillState(self.nSelfEffectId);
		Env:SetSystemSwitchOn(pPlayer, Env.SW_All);
		pPlayer.CenterMsg("傳功結束");
		pPlayer.CallClientScript("Ui:CloseWindow", "ChuangGongPanel")
		Log("[ChuangGong] AddSelfPlayerExp switch map ",pPlayer.dwID,pPlayer.szName,pPlayer.nLevel,pPlayer.nMapTemplateId)
		return false
	end
	
	pPlayer.AddExperience(nAddExp, Env.LogWay_ChuangGongGet)
	pPlayer.nSelfChuangongTimes = pPlayer.nSelfChuangongTimes - 1

	if pPlayer.nSelfChuangongTimes <= 0 then
		pPlayer.nSelfChuangongTimes = nil;
		pNpc.RestoreAction();
		pPlayer.RemoveSkillState(self.nSelfEffectId);
		Env:SetSystemSwitchOn(pPlayer, Env.SW_All);
		pPlayer.CallClientScript("ChuangGong:SendOne",pPlayer.nSelfChuangongTimes)
		Log("[ChuangGong] AddSelfPlayerExp ok",pPlayer.dwID,pPlayer.szName,pPlayer.nLevel,pPlayer.nSelfChuangongTimes or 0,nAddExp)
		return false
	else
		pPlayer.CallClientScript("ChuangGong:SendOne",pPlayer.nSelfChuangongTimes)
		Log("[ChuangGong] AddSelfPlayerExp ok",pPlayer.dwID,pPlayer.szName,pPlayer.nLevel,pPlayer.nSelfChuangongTimes or 0,nAddExp)
		return true
	end
end

function ChuangGong:SelfGetLevelExp(pPlayer)
	local nExp = 0
	for _,tbInfo in ipairs(self.tbSelfGetLevelExp) do
		if pPlayer.nLevel < tbInfo[1] then
			nExp = tbInfo[2]
			break;
		else
			nExp = tbInfo[2]
		end
	end
	return nExp;
end