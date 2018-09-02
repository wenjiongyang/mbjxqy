

-- 目前声明的是客户和服务端都有的

local emFriendData_Type = FriendShip.tbDataType.emFriendData_Type
local emFriendData_Imity = FriendShip.tbDataType.emFriendData_Imity
local emFriendData_Enemy_Left = FriendShip.tbDataType.emFriendData_Enemy_Left
local emFriendData_Enemy_Right = FriendShip.tbDataType.emFriendData_Enemy_Right
local emFriendData_BlackOrRequest = FriendShip.tbDataType.emFriendData_BlackOrRequest
local emFriendData_Temp_Refuse = FriendShip.tbDataType.emFriendData_Temp_Refuse
local emFriendData_WeddingState = FriendShip.tbDataType.emFriendData_WeddingState
local emFriendData_WeddingTime = FriendShip.tbDataType.emFriendData_WeddingTime


local emFriend_Type_Invalid = FriendShip.tbDataVal.emFriend_Type_Invalid
local emFriend_Type_Friend = FriendShip.tbDataVal.emFriend_Type_Friend
local emFriend_Type_Request_Left = FriendShip.tbDataVal.emFriend_Type_Request_Left
local emFriend_Type_Request_Right = FriendShip.tbDataVal.emFriend_Type_Request_Right

local IMITY_DAY_LIMIT = 1000 --任何两个好友之间的亲密度每天添加上限

-- 	nLastUpdateDay = 231,

-- 	tbAllWayLimit = 
-- 	{
-- 		[dwRoleId] = 
-- 		{
-- 			[szWay] = nLimit
-- 		}
-- 	}	

-- tbAllDayImityLimit = 
-- {
-- 	[dwRoleId1][dwRoleId2] = nTodayVal --dwRoleId1 < dwRoleId2
-- }

-- tbAllSingleLimit = 
-- {
-- 	[szWay][dwRoleId1][dwRoleId2] = nTodayVal --dwRoleId1 < dwRoleId2
-- };


--各种途径的增加亲密度设置 --不仅这里还有不固定数值的
local tbAddFriendImitySet = {
	[Env.LogWay_Wanted] 		= 30;
	[Env.LogWay_ChuangGong] 	= 100;
	[Env.LogWay_DungeonFuben] 	= 30;
	[Env.LogWay_PunishTask] 	= 20,  --惩恶任务
	[Env.LogWay_KinRobber] 		= 50,
	[Env.LogWay_UseHelper] 		=  10;
	[Env.LogWay_AdventureFuben] =   50;  --山贼密窟
	[Env.LogWay_KillFieldMapNpc]=   5;  --野外击杀精英怪
	[Env.LogWay_WhiteTigerFuben_FF] = 20; --白虎堂进入首层
	[Env.LogWay_WhiteTigerFuben_OF] =   10; --白虎堂进入其他层
	[Env.LogWay_WhiteTigerFuben_BOSS] =   10; --白虎堂击杀boss
	[Env.LogWay_ImperialTomb_Leader] = 10;  --秦始皇陵挂机精英
}


--每天通过各种渠道增加的亲密度上限设置, 同时在每日上限限制里
local tbWayLimit = {
	[Env.LogWay_Wanted] = 300, 
	[Env.LogWay_PunishTask] = 300, 
}


--每天通过各种渠道增加的亲密度上限设置, 不受每日上限的限制
FriendShip.tbSingleWayLimit = {
	[Env.LogWay_SendGift] = 600 + 11988,  --送花送草（玫瑰花/幸运草 + 99朵玫瑰花/幸运草）
	[Env.LogWay_WomensDay] = 20000,  --妇女节
	[Env.LogWay_BeautyPageant_Vote] = 5000,  --武林第一美女投票
	[Env.LogWay_Wedding] = 12000,  -- 结婚亲密度
}



function FriendShip:InitS()
	self:Init();

	self.nImityUpdateDay = 0;
	self:ResetDayLimit()
end

function FriendShip:ResetDayLimit()
	self.tbAllWayLimit = {};
	self.tbAllDayImityLimit = {}
	self.tbAllSingleLimit = {};
	for nLogWay,v in pairs(FriendShip.tbSingleWayLimit) do
		self.tbAllSingleLimit[nLogWay] = {};
	end
end

FriendShip:InitS();


function FriendShip:GetCanAddImity(dwRoleId, nLogWay, nImitity)
	local nDayMax = tbWayLimit[nLogWay]
	if not nDayMax then
		return nImitity
	end
		
	local tbRoleLimit =  self.tbAllWayLimit[dwRoleId]
	if not tbRoleLimit then
		return math.min(nDayMax, nImitity)
	end

	return math.min(nDayMax - (tbRoleLimit[nLogWay] or 0), nImitity) 
end

function FriendShip:AddImitityLimit(dwRoleId, nLogWay, nImitity)
	if not tbWayLimit[nLogWay] then
		return
	end
	local tbAllWayLimit = self.tbAllWayLimit
	tbAllWayLimit[dwRoleId] = tbAllWayLimit[dwRoleId] or {};
	tbAllWayLimit[dwRoleId][nLogWay] = tbAllWayLimit[dwRoleId][nLogWay] or 0
	tbAllWayLimit[dwRoleId][nLogWay] = tbAllWayLimit[dwRoleId][nLogWay] + nImitity
end

function FriendShip:GetDayImityAdded(nSmall, nBig, nImitity, nLogWay)
	local tbDayLimit, nDayMax;
	if  self.tbSingleWayLimit[nLogWay] then
		nDayMax = self.tbSingleWayLimit[nLogWay]
		tbDayLimit = self.tbAllSingleLimit[nLogWay]
	else
		nDayMax = IMITY_DAY_LIMIT
		tbDayLimit = self.tbAllDayImityLimit
	end

	if tbDayLimit[nSmall] then
		local nTodayAdded = tbDayLimit[nSmall][nBig]
		if nTodayAdded then
			return math.min(nImitity, nDayMax - nTodayAdded)
		end
	end
	return math.min(nImitity, nDayMax)
end

function FriendShip:AddDayLimit(nSmall, nBig, nImitity, nLogWay)
	local tbImityLimit;
	if self.tbAllSingleLimit[nLogWay] then
		tbImityLimit = self.tbAllSingleLimit[nLogWay]
	else
		tbImityLimit = self.tbAllDayImityLimit
	end
	tbImityLimit[nSmall] 		   = tbImityLimit[nSmall] or {}
	tbImityLimit[nSmall][nBig] = tbImityLimit[nSmall][nBig] or 0
	tbImityLimit[nSmall][nBig] = tbImityLimit[nSmall][nBig] + nImitity
end

--申请添加好友
function FriendShip:RequestAddFriend(dwRoleId1, dwRoleId2)
	if	dwRoleId1 == dwRoleId2 then
		return false, "不能添加自己為好友"
	end
	local tbRoleStayInfo = KPlayer.GetRoleStayInfo(dwRoleId2)
	if not tbRoleStayInfo then
		return false, "此玩家不存在"
	end

	local pAsync1 = KPlayer.GetAsyncData(dwRoleId1)
	if not pAsync1 then
		return false, "玩家資料錯誤"
	end

	if  pAsync1.GetFriendNum() >=  self:GetMaxFriendNum(pAsync1.GetLevel(), pAsync1.GetVipLevel()) then
		return false, "你的好友數已經達到上限"
	end

	local nDataVal = dwRoleId1 < dwRoleId2 and emFriend_Type_Request_Left or emFriend_Type_Request_Right

	local tbFriendData = KFriendShip.GetFriendShipValSet(dwRoleId1, dwRoleId2);
	if not tbFriendData then --两者间暂无关系 ，，那么就直接是发送好友申请了
		return KFriendShip.SetFriendShipVal(dwRoleId1, dwRoleId2, 
						emFriendData_BlackOrRequest, 
						nDataVal
						);

	else --两者是有关系数值的，先检查下关系是不是满足条件
		if tbFriendData[emFriendData_Type] == emFriend_Type_Friend then
			return false, "您已經和該玩家是好友關係了"
		end

		--因为确定操作已经在客户端做了 这里就直接算他决定了 ，所以先做这些操作
		--解除屏蔽需要在 被他屏蔽前
		-- 注意这里操作DelBlack， DelEnemy都会做同步操作

		if FriendShip:IsHeIsMyEnemy(dwRoleId1, dwRoleId2, tbFriendData) then
			FriendShip:DelEnemy(dwRoleId1, dwRoleId2, tbFriendData);
		end


		--玩家点击一键清空其实相当于拒绝操作， XX分钟内不会再收到被拒绝玩家的好友申请
		if FriendShip:IsInHisTempRefuse(dwRoleId1, dwRoleId2, tbFriendData) then
			return false, "很抱歉你需要過陣子才能繼續申請"
		end 

		--已经发送好友请求的
		if FriendShip:IsRequestedAdd(dwRoleId1, dwRoleId2, tbFriendData) then
			return false, "您已經向該玩家發送好友請求了，請等待對方添加"
		end

		if FriendShip:IsMeRequested(dwRoleId1, dwRoleId2, tbFriendData) then
			return FriendShip:AcceptFriend(dwRoleId1, dwRoleId2, tbFriendData)
		else
			return KFriendShip.SetFriendShipVal(dwRoleId1, dwRoleId2, 
						emFriendData_BlackOrRequest, 
						nDataVal
						);

		end
	end
end


--接受目标的好友请求
function FriendShip:AcceptFriend(dwRoleId1, dwRoleId2, tbFriendData) --tbFriendData 可以不传
	Log("FriendShip:AcceptFriend", dwRoleId1, dwRoleId2)
	if	dwRoleId1 == dwRoleId2 then
		return false, "不能添加自己為好友"
	end

	local pAsync1 = KPlayer.GetAsyncData(dwRoleId1)
	if not pAsync1 then
		return false, "玩家資料錯誤"
	end

	local pAsync2 = KPlayer.GetAsyncData(dwRoleId2)
	if not pAsync2 then
		return false, "此玩家不存在"
	end

	local pRole1 = KPlayer.GetRoleStayInfo(dwRoleId1)
	if not pRole1 then
		return false, "玩家資料錯誤1"
	end

	local pRole2 = KPlayer.GetRoleStayInfo(dwRoleId2)
	if not pRole2 then
		return false, "玩家資料錯誤2"
	end

	if not tbFriendData then
		tbFriendData = KFriendShip.GetFriendShipValSet(dwRoleId1, dwRoleId2);
	end

	if not tbFriendData then
		return false, "無效的操作"
	end

	if not	self:IsMeRequested(dwRoleId1, dwRoleId2, tbFriendData) then
		return
	end

	if tbFriendData[emFriendData_Type] == emFriend_Type_Friend then
		return false, "你們已經是好友了"
	end

	if  pAsync1.GetFriendNum() >= self:GetMaxFriendNum(pAsync1.GetLevel(), pAsync1.GetVipLevel()) then
		return false, "您的好友數已達上限"
	end

	if pAsync2.GetFriendNum() >= self:GetMaxFriendNum(pAsync2.GetLevel(), pAsync2.GetVipLevel()) then
		return false, "對方的好友數已達上限"
	end
	
	--好友数量的更新在setValue里有设置
	local bRet = KFriendShip.SetFriendShipGroup(dwRoleId1, dwRoleId2, {
		emFriendData_Type, emFriend_Type_Friend, 
		emFriendData_Imity, 1,
		emFriendData_Enemy_Left, 0,
		emFriendData_Enemy_Right, 0,
		emFriendData_BlackOrRequest, 0,
		emFriendData_Temp_Refuse, 0
	}) 

	if bRet then
		local szGameAppid, nPlat, nServerIdentity, nAreaId = GetWorldConfifParam()
		local szAcc1 = KPlayer.GetPlayerAccount(dwRoleId1) or ""
		local szAcc2 = KPlayer.GetPlayerAccount(dwRoleId2) or ""
		TLog("FriendIntimacy", szGameAppid, nPlat, nServerIdentity, dwRoleId1, dwRoleId2, 0, 1, Env.LogWay_AddFriend, szAcc1, szAcc2, pRole1.szName, pRole2.szName)
	end

	return   bRet
end

--清除我对目标玩家的仇恨值
function FriendShip:DelEnemy(dwRoleId1, dwRoleId2, tbFriendData)
	assert(dwRoleId1 ~= dwRoleId2)
	if dwRoleId1 < dwRoleId2 then
		return KFriendShip.SetFriendShipVal(dwRoleId1, dwRoleId2, emFriendData_Enemy_Left, 0)	
	else
		return KFriendShip.SetFriendShipVal(dwRoleId1, dwRoleId2, emFriendData_Enemy_Right, 0)	
	end
end


--删除好友
function FriendShip:DelFriend(dwRoleId1, dwRoleId2)
	assert(dwRoleId1 ~= dwRoleId2)	
	local tbFriendData = KFriendShip.GetFriendShipValSet(dwRoleId1, dwRoleId2);
	if not tbFriendData then --两者间暂无关系 ，，那么就直接是发送好友申请了
		return false, "您的數據已過期" 
	end
	if tbFriendData[emFriendData_Type] ~= emFriend_Type_Friend then
		return false, "您的資料有問題"
	end

	local pRole1 = KPlayer.GetRoleStayInfo(dwRoleId1)
	if not pRole1 then
		return false, "玩家資料錯誤1"
	end

	local pRole2 = KPlayer.GetRoleStayInfo(dwRoleId2)
	if not pRole2 then
		return false, "玩家資料錯誤2"
	end

	if not TeacherStudent:CanDelFriend(dwRoleId1, dwRoleId2) then
		return false, "師徒無法刪除好友"
	end

	if not SwornFriends:CanDelFriend(dwRoleId1, dwRoleId2) then
		return false, "結拜關係無法刪除好友"
	end

	local bResult, szMsg = Wedding:CheckDelFriend(dwRoleId1, dwRoleId2)
	if not bResult then
		return false, szMsg
	end

	local bRet = KFriendShip.SetFriendShipGroup(dwRoleId1, dwRoleId2, {
		emFriendData_Type, 0,
		emFriendData_Imity, 0,
	})
	if bRet then
		local szGameAppid, nPlat, nServerIdentity, nAreaId = GetWorldConfifParam()
		local szAcc1 = KPlayer.GetPlayerAccount(dwRoleId1) or ""
		local szAcc2 = KPlayer.GetPlayerAccount(dwRoleId2) or ""
		TLog("FriendIntimacy", szGameAppid, nPlat, nServerIdentity, dwRoleId1, dwRoleId2, 0, 0, Env.LogWay_DelFriend, szAcc1, szAcc2, pRole1.szName, pRole2.szName)
	end
	return bRet
end

--直接拉黑 拉黑是取消掉好友的
function FriendShip:BlackHim(dwRoleId1, dwRoleId2)
	assert(dwRoleId1 ~= dwRoleId2)	
	local pRole1 = KPlayer.GetRoleStayInfo(dwRoleId1)
	if not pRole1 then
		return false, "玩家資料錯誤1"
	end

	local pRole2 = KPlayer.GetRoleStayInfo(dwRoleId2)
	if not pRole2 then
		return false, "玩家資料錯誤2"
	end

	if Wedding:IsEngaged(dwRoleId1, dwRoleId2) then
		return false, "訂婚關係無法拉黑好友"
	end
	if Wedding:IsLover(dwRoleId1, dwRoleId2) then
		return false, "結婚關係無法拉黑好友"
	end

	if not TeacherStudent:CanDelFriend(dwRoleId1, dwRoleId2) then
		return false, "師徒無法拉黑好友"
	end

	if not SwornFriends:CanDelFriend(dwRoleId1, dwRoleId2) then
		return false, "結拜關係無法拉黑好友"
	end

	local bFriend = self:IsFriend(dwRoleId1, dwRoleId2)
	local bRet, szMsg = KFriendShip.SetFriendShipGroup(dwRoleId1, dwRoleId2, {
		emFriendData_Type, 0,
		emFriendData_Imity, 0,
		emFriendData_BlackOrRequest, 0,
	});

	if bRet then
		if bFriend then
			local szGameAppid, nPlat, nServerIdentity, nAreaId = GetWorldConfifParam()
			local szAcc1 = KPlayer.GetPlayerAccount(dwRoleId1) or ""
			local szAcc2 = KPlayer.GetPlayerAccount(dwRoleId2) or ""
			TLog("FriendIntimacy", szGameAppid, nPlat, nServerIdentity, dwRoleId1, dwRoleId2, 0, 0, Env.LogWay_DelFriend, szAcc1, szAcc2, pRole1.szName, pRole2.szName)
		end

		local pRoleStayInfo = KPlayer.GetRoleStayInfo(dwRoleId2);
		if pRoleStayInfo then
			me.CallClientScript("FriendShip:AddBlack", dwRoleId2, {
					dwID = pRoleStayInfo.dwID;
					szName = pRoleStayInfo.szName;
					nLevel = pRoleStayInfo.nLevel;
					nHonorLevel = pRoleStayInfo.nHonorLevel;
					nFaction = pRoleStayInfo.nFaction;
					nPortrait = pRoleStayInfo.nPortrait;
				});
		end
	end
	return bRet, szMsg;
end

function FriendShip:AddImitityByKind(dwRoleId1, dwRoleId2, nLogReason)
	local nImitity = tbAddFriendImitySet[nLogReason] 
	if nImitity then
		self:AddImitity(dwRoleId1, dwRoleId2, nImitity, nLogReason)
	end
end

--减少亲密度
function FriendShip:ReduceImitity(dwRoleId1, dwRoleId2, nImitity, nLogReason)
	if dwRoleId1 > dwRoleId2 then
		dwRoleId1, dwRoleId2 = dwRoleId2, dwRoleId1
	end

	local tbFriendData = KFriendShip.GetFriendShipValSet(dwRoleId1, dwRoleId2);
	if not tbFriendData then
		return false, "兩者間暫無關係"
	end

	if tbFriendData[emFriendData_Type] ~= emFriend_Type_Friend then
		return false, "你們還不是好友關係"
	end

	local pRoleStay1 = KPlayer.GetRoleStayInfo(dwRoleId1) or {}
	if not pRoleStay1 then
		return false, "玩家資料錯誤1"
	end

	local pRoleStay2 = KPlayer.GetRoleStayInfo(dwRoleId2) or {}
	if not pRoleStay2 then
		return false, "玩家資料錯誤2"
	end

	local nOldImity = tbFriendData[emFriendData_Imity]
	local nNewImity = nOldImity - nImitity < 1 and 1 or nOldImity - nImitity
	local bRet = KFriendShip.SetFriendShipVal(dwRoleId1, dwRoleId2, emFriendData_Imity, nNewImity)
	if bRet then
		local szWayDesc = Env.tbLogWayDesc[nLogReason] or "";
		if not Lib:IsEmptyStr(szWayDesc) then
			szWayDesc = string.format("（%s）", szWayDesc)
		end
		local pPlayer1 = KPlayer.GetPlayerObjById(dwRoleId1)
		local pPlayer2 = KPlayer.GetPlayerObjById(dwRoleId2)
		if pPlayer1 then
			local szRoleName = pPlayer2 and pPlayer2.szName or pRoleStay2.szName
			pPlayer1.CenterMsg(string.format("與「%s」親密度減少了%d點%s", szRoleName or "-", nImitity, szWayDesc), true)
		end
		if pPlayer2 then
			local szRoleName = pPlayer1 and pPlayer1.szName or pRoleStay1.szName
			pPlayer2.CenterMsg(string.format("與「%s」親密度減少了%d點%s", szRoleName or "-", nImitity, szWayDesc), true)
		end
		local szGameAppid, nPlat, nServerIdentity, nAreaId = GetWorldConfifParam()
		local szAcc1 = KPlayer.GetPlayerAccount(dwRoleId1) or ""
		local szAcc2 = KPlayer.GetPlayerAccount(dwRoleId2) or ""
		TLog("FriendIntimacy", szGameAppid, nPlat, nServerIdentity, dwRoleId1, dwRoleId2, nImitity, nNewImity, nLogReason, szAcc1, szAcc2, pRoleStay1.szName, pRoleStay2.szName)
		return true, "減少親密度成功"
	else
		Log("Warn failed FriendShip:AddImitity", dwRoleId1, dwRoleId2, nImitity, nLogReason)
		return false, "減少親密度失敗"
	end
end

--增加亲密度
function FriendShip:AddImitity(dwRoleId1, dwRoleId2, nImitity, nLogReason)
	if dwRoleId1 > dwRoleId2 then
		dwRoleId1, dwRoleId2 = dwRoleId2, dwRoleId1
	end
	local tbFriendData = KFriendShip.GetFriendShipValSet(dwRoleId1, dwRoleId2);
	if not tbFriendData then
		return false, "兩者間暫無關係"
	end
	if tbFriendData[emFriendData_Type] ~= emFriend_Type_Friend then
		return false, "你們還不是好友關係"
	end

	local nOldImity = tbFriendData[emFriendData_Imity]
	if nOldImity >= FriendShip.nMaxImitiy then
		return false, "親密度已達上限"
	end

	local nToday = Lib:GetLocalDay()
	if nToday ~= self.nImityUpdateDay then
		self:ResetDayLimit()
		self.nImityUpdateDay = nToday
	end 
	local pRole1 = KPlayer.GetRoleStayInfo(dwRoleId1)
	if not pRole1 then
		return false, "玩家資料錯誤1"
	end

	local pRole2 = KPlayer.GetRoleStayInfo(dwRoleId2)
	if not pRole2 then
		return false, "玩家資料錯誤2"
	end

	--玩家召回加成
	
	if FriendRecall:IsInAwardList(dwRoleId1, dwRoleId2) or 
		FriendRecall:IsInAwardList(dwRoleId2, dwRoleId1) then

		nImitity = math.floor( nImitity * FriendRecall.Def.IMITY_BONUS)
	end

	local pAsync1 = KPlayer.GetAsyncData(dwRoleId1)
	local pAsync2 = KPlayer.GetAsyncData(dwRoleId2)
	local nVipLevel1 = pAsync1 and  pAsync1.GetVipLevel()
	local nVipLevel2 = pAsync2 and  pAsync2.GetVipLevel()
	local nNeedVip, nVipAdd = unpack(Recharge.tbVipExtSetting.AddImity)
	if nVipLevel1 >= nNeedVip or nVipLevel2 >= nNeedVip then
		nImitity = math.floor( nImitity * nVipAdd)
	end

	nImitity = FriendShip:GetDayImityAdded(dwRoleId1, dwRoleId2, nImitity, nLogReason)
	if nImitity <= 0 then
		return false, "今天已經不能通過此途徑增加親密度"
	end

	local bWayLimit = tbWayLimit[nLogReason]
	if bWayLimit then
		nImitity = math.min(self:GetCanAddImity(dwRoleId1, nLogReason, nImitity), 
							self:GetCanAddImity(dwRoleId2, nLogReason, nImitity) );
		if nImitity <= 0 then
			return false, "今天已經不能通過此途徑增加親密度"
		end
	end

	Activity:OnGlobalEvent("Act_OnAddImitity", pRole1, pRole2, nImitity, nLogReason)

	local nNewImity = nOldImity + nImitity
	if nNewImity >= FriendShip.nMaxImitiy then
		nNewImity = FriendShip.nMaxImitiy
	end

	local bRet = KFriendShip.SetFriendShipVal(dwRoleId1, dwRoleId2, emFriendData_Imity, nNewImity)
	if bRet then
		if bWayLimit then
			self:AddImitityLimit(dwRoleId1, nLogReason, nImitity)
			self:AddImitityLimit(dwRoleId2, nLogReason, nImitity)
		end

		self:AddDayLimit(dwRoleId1, dwRoleId2, nImitity, nLogReason)
		
		local pPlayer1 = KPlayer.GetPlayerObjById(dwRoleId1)
		local pPlayer2 = KPlayer.GetPlayerObjById(dwRoleId2)
		local nRealAddImity = nNewImity - nOldImity
		local szWayDesc = Env.tbLogWayDesc[nLogReason] or "";
		if not Lib:IsEmptyStr(szWayDesc) then
			szWayDesc = string.format("（%s）", szWayDesc)
		end

		if pPlayer1 then
			local szRoleName = pPlayer2 and pPlayer2.szName or KPlayer.GetRoleStayInfo(dwRoleId2).szName
			pPlayer1.CenterMsg(string.format("與「%s」親密度提升了%d點%s", szRoleName, nRealAddImity, szWayDesc), true)
		end
		if pPlayer2 then
			local szRoleName = pPlayer1 and pPlayer1.szName or KPlayer.GetRoleStayInfo(dwRoleId1).szName
			pPlayer2.CenterMsg(string.format("與「%s」親密度提升了%d點%s", szRoleName, nRealAddImity, szWayDesc), true)
		end
		local szGameAppid, nPlat, nServerIdentity, nAreaId = GetWorldConfifParam()
		local szAcc1 = KPlayer.GetPlayerAccount(dwRoleId1) or ""
		local szAcc2 = KPlayer.GetPlayerAccount(dwRoleId2) or ""
		TLog("FriendIntimacy", szGameAppid, nPlat, nServerIdentity, dwRoleId1, dwRoleId2, nRealAddImity, nNewImity, nLogReason, szAcc1, szAcc2, pRole1.szName, pRole2.szName)
		return true, "增加親密度成功"
	else
		Log("Warn failed FriendShip:AddImitity",dwRoleId1, dwRoleId2, nImitity)
		return false, "增加親密度失敗"
	end
end

function FriendShip:TryCheckImityAchievement(pPlayer, nImityCheckAcheLevel, tbCheckRoleIDs)
 	if not tbCheckRoleIDs or not next(tbCheckRoleIDs) then
 		return
 	end
 	
 	local nCheckLevel =  self.tbImityAchivementLevel[nImityCheckAcheLevel]
 	if not nCheckLevel then
 		return
 	end

 	local nValidNum = 0;
 	local dwRoleId1 = pPlayer.dwID
 	for i, v in ipairs(tbCheckRoleIDs) do
 		local nImitity = self:GetImity(dwRoleId1, v)
 		if nImitity and self:GetImityLevel(nImitity) >= nCheckLevel then
 			nValidNum =  nValidNum + 1;
 		end
 	end
 	local nOldCount1 = Achievement:GetSubKindCount(pPlayer, "FriendFamiliar_" .. nImityCheckAcheLevel)
 	local nOldCount2 = Achievement:GetSubKindCount(pPlayer, "Friend_" .. nImityCheckAcheLevel)
 	Achievement:SetCount(pPlayer, "FriendFamiliar_" .. nImityCheckAcheLevel, nValidNum)
 	Achievement:AddCount(pPlayer, "Friend_" .. nImityCheckAcheLevel, nValidNum)
 	if nImityCheckAcheLevel == 3 and nValidNum >= 3 and nOldCount1 < 3 then
 		Sdk:SendTXLuckyBagMail(pPlayer, "3Friend20L");
 	end

 	if nImityCheckAcheLevel == 3 and nValidNum > 0 and nOldCount2 == 0 then
		Sdk:SendTXLuckyBagMail(pPlayer, "1Friend20L");
 	end
 end 

--一键清空
function FriendShip:RefuseAllRequet(dwRoleId1)
	Log("FriendShip:RefuseAllRequet", dwRoleId1)
	return KFriendShip.RefuseAllRequet(dwRoleId1, self.nTempRefuseTime)
end

--dwRoleId1 拒绝玩家2
function FriendShip:RefuseAddFriend(dwRoleId1, dwRoleId2)
	KFriendShip.SetFriendShipVal(dwRoleId1, dwRoleId2, emFriendData_BlackOrRequest, 0)
end


------------仇人相关
-- 加role1 对 role2 的 仇恨  role2是role1 的仇人 pRole可以是player或RoleStay
function FriendShip:AddHate(pRole1, pRole2, nVal, bExcludeSworn)
	if nVal == 0 then
		return false;
	end
	if nVal > 0 and pRole1.nLevel - pRole2.nLevel > self.nEnemyLevelLimit then
		return
	end
	local dwRoleId1 = pRole1.dwID;
	local dwRoleId2 = pRole2.dwID;
	local tbFriendData = KFriendShip.GetFriendShipValSet(dwRoleId1, dwRoleId2)
	if tbFriendData and FriendShip:IsFriend(dwRoleId1, dwRoleId2, tbFriendData) then
		return false, "好友之間不能加仇恨"
	end

	if pRole1.dwKinId ~= 0 and pRole1.dwKinId == pRole2.dwKinId then
		return false, "同幫派不能增加仇恨"
	end

	if not bExcludeSworn and nVal>0 then
		SwornFriends:OnAddHate(pRole1.dwID, pRole2, nVal)
	end
	return KFriendShip.SetFriendShipVal(dwRoleId1, dwRoleId2, dwRoleId1 < dwRoleId2 and emFriendData_Enemy_Left or emFriendData_Enemy_Right, nVal)
end

function FriendShip:DoRevenge(pPlayer1, dwRoleId2)
	local dwRoleId1 = pPlayer1.dwID;
	if not AsyncBattle:CanStartAsyncBattle(pPlayer1) then
		return false, "請在安全區域下參與"
	end

	if not Env:CheckSystemSwitch(pPlayer1, Env.SW_SwitchMap) then
        return false, "目前狀態不允許切換地圖"
    end

 	local tbFriendData = KFriendShip.GetFriendShipValSet(dwRoleId1, dwRoleId2)
 	if not tbFriendData then
	 	return false, "非仇人關係"
	end

	if FriendShip:IsFriend(dwRoleId1, dwRoleId2, tbFriendData) then
		return false, "好友之間不能復仇"
	end

	local tbRoleInfo2 = KPlayer.GetRoleStayInfo(dwRoleId2)
	if not tbRoleInfo2 then
		return false, "角色2不存在"
	end

	if pPlayer1.dwKinId ~= 0 and pPlayer1.dwKinId == tbRoleInfo2.dwKinId then
		return false, "同幫派不能復仇"
	end

	local bEnemy, nHisHate = FriendShip:IsHeIsMyEnemy(dwRoleId1, dwRoleId2, tbFriendData) 
	if not bEnemy then
		return false, "他不是你的仇人"
	end

	local nNow = GetTime()
	local nCdTime = FriendShip:GetRevengeCDTiem(nNow)
	if nCdTime > 60 * 60 then
		return false, "復仇冷卻時間超過一小時不能復仇"
	end

	local pAnsyPlayer2 = KPlayer.GetAsyncData(dwRoleId2);
	if not pAnsyPlayer2 then
		return false, "對方已經好久沒上線啦"
	end

	local pPlayerNpc = pPlayer1.GetNpc();
	local nResult = pPlayerNpc.CanChangeDoing(Npc.Doing.skill);
	if nResult == 0 then
		return false, "目前狀態不能參加";
	end


	if DegreeCtrl:GetDegree(pPlayer1, "Revenge") < 1 then
		return false, "今天復仇次數已經用完"
	end

	local nBattleKey = GetTime()
	
	if not AsyncBattle:CreateAsyncBattle(pPlayer1, self.FIGHT_MAP, self.ENTER_POINT, "EnemyRevenge", dwRoleId2, nBattleKey, {dwRoleId2, nBattleKey}) then
		Log("Error!! Enter AsyncRevenge Map Failed!")
		return false, "非同步戰鬥進入失敗";
	end

	--增加CD时间
	self:SetNextRevengeTime(nil, pPlayer1);

	if not DegreeCtrl:ReduceDegree(pPlayer1, "Revenge", 1) then
		Log(debug.traceback(), pPlayer1.dwID)
	end

	pPlayer1.CallClientScript("Ui:CloseWindow", "SocialPanel");

	return true
 end 

--pPlayer2, pAnsyPlayer2可以都传空
function FriendShip:RobCoinAddHate(pPlayer1, nAddHate, dwRoleId2, pPlayer2, pAnsyPlayer2)
	if not pPlayer2 then
		pPlayer2 = KPlayer.GetPlayerObjById(dwRoleId2)
	end
	local dwRoleId1 = pPlayer1.dwID
	if not pAnsyPlayer2 then
		pAnsyPlayer2 = KPlayer.GetAsyncData(dwRoleId2)
		if not pAnsyPlayer2 then
			Log("FriendShip:RobCoinAddHate no targert", dwRoleId1, dwRoleId2)
			return
		end
	end

	local pRole2 = KPlayer.GetRoleStayInfo(dwRoleId2)
	if not pRole2 then
		return
	end

	local bEnemy, nHisHate = FriendShip:IsHeIsMyEnemy(dwRoleId1, dwRoleId2) 
	if not bEnemy then
		Log("FriendShip:RobCoinAddHate NO Enemy now", dwRoleId1, dwRoleId2)
		nHisHate = 0;
	end

	local nMinusHate = self:GetMinusHate(nAddHate, nHisHate);
	local nHisCoin = Player:GetPlayerCoin(pPlayer2, pAnsyPlayer2);
	local nHisJuBaoPenVal = JuBaoPen:GetJuBaoPengVal(dwRoleId2)
	local nRobCoin = self:GetRevengetRobCoin(nHisCoin + nHisJuBaoPenVal);			
 
	--优先抢 背包里的，再是抢聚宝盆里的
	local nRobBagCoin, nRobJuBaoPen = 0,0;
	local nHisCoin = pPlayer2 and  pPlayer2.GetMoney("Coin") or pAnsyPlayer2.GetCoin()
	if nHisCoin > nRobCoin then
		nRobBagCoin = nRobCoin;
	else
		nRobBagCoin = nHisCoin
		nRobJuBaoPen = nRobCoin - nHisCoin
	end
	
	if nAddHate > 0 then
		nAddHate = nAddHate + 10 * nRobCoin
	end
	
	if nRobBagCoin > 0 then
		if pPlayer2 then
			if not pPlayer2.CostMoney("Coin", nRobBagCoin, Env.LogWay_RobCoinAddHate) then
				Log(debug.traceback())
			end
			Log(string.format("FriendShip:RobCoinAddHate me:%d, he %d online rob coin %d", dwRoleId1, dwRoleId2, nRobBagCoin))
		else
			pAnsyPlayer2.SetCoinAdd(pAnsyPlayer2.GetCoinAdd() - nRobBagCoin)
			Log(string.format("FriendShip:RobCoinAddHate me:%d, he %d Ansy rob coin %d", dwRoleId1, dwRoleId2, nRobBagCoin))
		end
	end
	
	if nRobJuBaoPen > 0 then
		local nHisJuBaoPenVal = JuBaoPen:GetJuBaoPengVal(dwRoleId2)
		pAnsyPlayer2.SetJuBaoPenVal(nHisJuBaoPenVal - nRobJuBaoPen)
		Log(string.format("FriendShip:RobCoinAddHate RobJuBaoPen  me:%d, he %d Ansy rob coin %d  hisOrgJuBaoPen %d", dwRoleId1, dwRoleId2, nRobJuBaoPen, nHisJuBaoPenVal))
	end

	if nRobCoin > 0 then
		pPlayer1.AddMoney("Coin", nRobCoin, Env.LogWay_RobCoinAddHate)	
	end

	self:AddHate(pPlayer1, pRole2, -nMinusHate)
	if self:AddHate(pRole2, pPlayer1, nAddHate) then
		return true, nRobJuBaoPen, nRobCoin, nMinusHate
	end
	return false, nRobJuBaoPen, nRobCoin, nMinusHate
end

 --复仇一次增加30分钟CD, 如果上次可复仇时间还没到，就在上次基础上加，到了就从现在开始算
function FriendShip:SetNextRevengeTime(nTime, pPlayer)
	if nTime == 0 then
		pPlayer.SetUserValue(5, 3, 0)
		return
	end
	local nNow =  GetTime()
	local nNextTime = pPlayer.GetUserValue(5, 3)
	if nNextTime > nNow then
		pPlayer.SetUserValue(5, 3, nNextTime + 60 * 30)
	else
		pPlayer.SetUserValue(5, 3, nNow + 60 * 30)
	end
	
end

function FriendShip:Active(nTimeNow)
	for k1, v1 in pairs(FriendShip.tbWantedData) do
		if not next(v1) then
			FriendShip.tbWantedData[k1] = nil;
		else
			for k2, v2 in pairs(v1) do
				if not v2.nLock and v2.nEndTime <= nTimeNow then
					v1[k2] = nil;
				end
			end	
		end
		
	end
end

-- 直接按照头衔计算PK胜率  pRoleStay 也可以是pPlayer 
function FriendShip:FightWithHonor(pPlayer, pRoleStay)
	local nHonorMinus = pRoleStay.nHonorLevel - pPlayer.nHonorLevel
	local nProb = Lib.Calc:Link(nHonorMinus, FriendShip.tbHonorProb, true);
	return MathRandom() >= (1 - nProb)
end

function FriendShip:OnRevengeResult(pPlayer, nResult, tbBattleObj, dwRoleId2, nStartTime)
	local nTimeNow = GetTime()
	local pRole2 = KPlayer.GetRoleStayInfo(dwRoleId2)
	local bAddHate, nRobJuBaoPen, nRobCoin, nMinusHate;
	
 	if nResult == 1 then --成功
 		bAddHate, nRobJuBaoPen, nRobCoin, nMinusHate = self:RobCoinAddHate(pPlayer, self.nRevengeAddHate, dwRoleId2)
 		if bAddHate then
 			Player:SendNotifyMsg(dwRoleId2, {
				szType = "Revenge", 
				nTimeOut = nTimeNow + 86400 * 15, 
				dwID = pPlayer.dwID,
				nRobCoin = nRobCoin,
				nRobJuBaoPen = nRobJuBaoPen,
				}) 			
 		end
 		Achievement:AddCount(pPlayer, "Foe_1", 1)
 	end

 	pPlayer.CallClientScript("FriendShip:OnClientRevengeResult", nResult, pRole2, nMinusHate, nRobCoin)

 	pPlayer.TLogRoundFlow(Env.LogWay_Revenge, dwRoleId2, 0, nTimeNow - nStartTime,  nResult == 1 and Env.LogRound_SUCCESS or Env.LogRound_FAIL, 0, nRobCoin)
end

function FriendShip:ForceAddFriend(pPlayer1, pPlayer2)
	local dwRoleId1 = pPlayer1.dwID
	local dwRoleId2 = pPlayer2.dwID
	if FriendShip:IsFriend(dwRoleId1, dwRoleId2) then
		return
	end

	local bRet = KFriendShip.SetFriendShipGroup(dwRoleId1, dwRoleId2, {
		emFriendData_Type, emFriend_Type_Friend, 
		emFriendData_Imity, 1,
		emFriendData_Enemy_Left, 0,
		emFriendData_Enemy_Right, 0,
		emFriendData_BlackOrRequest, 0,
		emFriendData_Temp_Refuse, 0
	}) 

	if bRet then
		local szGameAppid, nPlat, nServerIdentity, nAreaId = GetWorldConfifParam()
		local szAcc1 = KPlayer.GetPlayerAccount(dwRoleId1) or ""
		local szAcc2 = KPlayer.GetPlayerAccount(dwRoleId2) or ""
		TLog("FriendIntimacy", szGameAppid, nPlat, nServerIdentity, dwRoleId1, dwRoleId2, 0, 1, Env.LogWay_AddFriend, szAcc1, szAcc2, pPlayer1.szName, pPlayer2.szName)
	end

	pPlayer1.CenterMsg(string.format("你成功將「%s」添加為好友！", pPlayer2.szName))
	pPlayer2.CenterMsg(string.format("你成功將「%s」添加為好友！", pPlayer1.szName))
	return true
end

function FriendShip:RequestSynAllFriendData(pPlayer, nClientFriendNum)
	local nNow = GetTime()
	if not pPlayer.nLastClientRequestSynTime or nNow - pPlayer.nLastClientRequestSynTime > 60 then
		pPlayer.nLastClientRequestSynTime = nNow
		local pASync = KPlayer.GetAsyncData(pPlayer.dwID) 
		if pASync then
			local nServerFriendNum = pASync.GetFriendNum()
			if nServerFriendNum ~= nClientFriendNum then
				KFriendShip.ReSynAllFriendInfo(pPlayer.dwID)	
			end
		end
	end
end

FriendShip.tbLastRecordLogoutTime = {}
function FriendShip:OnLogout(pPlayer)
	local nNow = GetTime()
	if self.tbLastRecordLogoutTime[pPlayer.dwID] and nNow - self.tbLastRecordLogoutTime[pPlayer.dwID]  < 7200 then
		return
	end
	self.tbLastRecordLogoutTime[pPlayer.dwID] = nNow

	local tbAllPlayers, nTotalCount = KFriendShip.GetFriendList(pPlayer.dwID);
	if not next(tbAllPlayers) then
		return
	end
	local tbNew = {}
	for k,v in pairs(tbAllPlayers) do
		table.insert(tbNew, {k,v} ) 
	end
	table.sort( tbNew, function (a, b)
		return a[2] > b[2]
	end )

	local szReportData = ""
	for i=1,3 do
		local v = tbNew[i]
		if not v then
			break;
		end
		local pRole = KPlayer.GetRoleStayInfo(v[1])
		if pRole then
			szReportData = szReportData .. 	pRole.szName .. "," .. v[2] .. ","
		end
	end

	AssistClient:ReportQQScore(pPlayer, Env.QQReport_FriendShopTop3, szReportData, 0, 1)	
end

function FriendShip:OnLoadFriendData(pPlayer)
	FriendRecall:OnLoadFriendData(pPlayer);
	Wedding:OnLoadFriendDataFinish(pPlayer);
	House:OnLoadFriendDataFinish(pPlayer)
end

AsyncBattle:ResgiterBattleType("EnemyRevenge", FriendShip, FriendShip.OnRevengeResult, nil, FriendShip.FIGHT_MAP)
