Require("CommonScript/ArenaBattle/ArenaBattleC.lua");
--[[
	*tbIsApply中的nTeamId总是对应玩家最新的nTeamId
	*tbApply中一个玩家可能对应多条申请信息（即nApplyId一样，但nTeamId不同，玩家组队申请之后重新组队申请）

   ArenaBattle.tbArenaInfo = 
   {
		[nArenaId] = 
		{
			tbArenaMan = {
				nArenaManId = dwPlayerId or nCaptainID,
				tbApply = {{nApplyId = dwPlayerId or nCaptainID,nTeamId = -1 or nTeamId}},  // -1 单人  
				tbSingleApply = {[dwPlayerId] = true or false}  
				tbTeamApply = {[nTeamId] = nArenaId}  
				},
			tbCurChallenger = {nChallengerId = dwPlayerId or nCaptainID},
			
		}
   }
	
	self.tbGame[nArenaId] = 擂台活动数据对象
]]

--[[
以下情况会删除申请
1.上擂台，全体成员的申请数据会失效并删除
2.单人变组队，单人申请数据会失效并删除
3.组队变单人或队伍解散，组队申请数据会失效，不删除
]]

function ArenaBattle:Init()
	self.tbArenaInfo = {}
	self.tbGame = {}

	for nArenaId = 1,ArenaBattle.nArenaNum do
		self.tbArenaInfo[nArenaId] = {}
		self.tbGame[nArenaId] = Lib:NewClass(self.ArenaBattleFight);	-- 创建活动数据对象
		self.tbGame[nArenaId].nArenaId = nArenaId
		self.tbGame[nArenaId].tbAllPos = ArenaBattle.tbPos[nArenaId] or {}
		self.tbGame[nArenaId].tbWatchList = {} 							-- 当前擂台进入观战范围的玩家（用于比赛结束停止观战）
		self.tbGame[nArenaId].tbCampInfo = {} 							-- 阵营玩家信息
		Log("[ArenaBattle] Init ArenaFight ok ",nArenaId)
	end
end

function ArenaBattle:CheckMemberValidMap(nTeamId)
	local tbMember = TeamMgr:GetMembers(nTeamId);
	for _,dwID in pairs(tbMember) do
		local pMember = KPlayer.GetPlayerObjById(dwID)
		if pMember then
			if not self:CheckValidMap(pMember) then
				return false,pMember.szName
			end
		end
	end
	return true
end

function ArenaBattle:SendTeamTip(nTeamId,szTip)
	local tbMember = TeamMgr:GetMembers(nTeamId);
	for _,dwID in pairs(tbMember) do
		local pMember = KPlayer.GetPlayerObjById(dwID)
		if pMember then
			pMember.CenterMsg(szTip)
		end
	end
end

function ArenaBattle:ApplyChallenge(pPlayer,nArenaId)
	if not self:CheckValidMap(pPlayer) then
		return 
	end

	local tbArenaInfo = self:GetArenaInfo(nArenaId)
	if not tbArenaInfo then
		pPlayer.CenterMsg("找不到擂臺數據")
		Log("[ArenaBattle] ApplyChallenge can not find arena !",nArenaId,pPlayer.dwID,pPlayer.szName,pPlayer.nMapTemplateId)
		return
	end

	if self:CheckIsArenaTeamMan(pPlayer.dwID) then
		pPlayer.CenterMsg("你已經是擂主了，不能對其他人發起挑戰")
		return
	end

	if self:CheckIsChallenger(pPlayer.dwID) then
		pPlayer.CenterMsg("你正在對戰中，不能對其他人發起挑戰")
		return
	end
	local bRet,szMsg,szTip

	local pTeamData = TeamMgr:GetTeamById(pPlayer.dwTeamID)

	tbArenaInfo.tbArenaMan = tbArenaInfo.tbArenaMan or {}
	local tbArenaMan = tbArenaInfo.tbArenaMan

	if not tbArenaMan.nArenaManId then
		if pTeamData then 
			if pPlayer.dwID ~= pTeamData.nCaptainID then
				pPlayer.CenterMsg("隊長才可以申請上擂臺")
				return
			end

			bRet,szMsg = self:CheckMemberValidMap(pPlayer.dwTeamID)
			if not bRet then
				szTip = string.format("「%s」不在比武場，無法上擂臺",szMsg or "")
				self:SendTeamTip(pPlayer.dwTeamID,szTip)
				ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.Team, szTip, pPlayer.dwTeamID)
				return
			end
		end

		self:OnArenaManChange(nArenaId,pPlayer.dwID,true)
		self:SynArenaManData(pPlayer)
		self:SendBeArenaManTip(pPlayer)
		return
	end

	local pMan = KPlayer.GetPlayerObjById(tbArenaMan.nArenaManId)
	if not pMan or not self:CheckValidMap(pMan) then
		self:ResetArenaInfo(nArenaId)
		self:SynArenaManData(pPlayer)
		Log("[ArenaBattle] ApplyChallenge can not find pMan !",nArenaId,tbArenaMan.nArenaManId,pPlayer.dwID,pPlayer.szName,pPlayer.nMapTemplateId)
		return 
	end

	local manTeamData = TeamMgr:GetTeamById(pMan.dwTeamID)

	if manTeamData and not pTeamData then
		pPlayer.CenterMsg("請以組隊的形式發起挑戰")
		return 
	end
	
	if not manTeamData and pTeamData then
		pPlayer.CenterMsg("請以單人的形式發起挑戰")
		return
	end

	local nApplyId = pPlayer.dwID
	local nTeamId = -1

	if manTeamData then
		if nApplyId ~= pTeamData.nCaptainID then
			pPlayer.CenterMsg("隊長才可申請挑戰")
			return
		end
		nApplyId = pTeamData.nCaptainID
		nTeamId = pPlayer.dwTeamID
		if tbArenaMan.tbTeamApply and tbArenaMan.tbTeamApply[nTeamId] then
			pPlayer.CenterMsg("您的隊伍已經申請過該擂臺")
			return 
		end
		bRet,szMsg = self:CheckMemberValidMap(pPlayer.dwTeamID)
		if not bRet then
			szTip = string.format("「%s」不在比武場，無法上擂臺",szMsg or "")
			self:SendTeamTip(pPlayer.dwTeamID,szTip)
			ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.Team, szTip, pPlayer.dwTeamID)
			return
		end
	else
		if tbArenaMan.tbSingleApply and tbArenaMan.tbSingleApply[nApplyId] then
			pPlayer.CenterMsg("您已經申請過該擂臺")
			return 
		end
	end

	tbArenaMan.tbApply = tbArenaMan.tbApply or {}

	table.insert(tbArenaMan.tbApply,{nApplyId = nApplyId , nTeamId = nTeamId})

	if manTeamData then
		tbArenaMan.tbTeamApply = tbArenaMan.tbTeamApply or {}
		tbArenaMan.tbTeamApply[nTeamId] = nArenaId
	else
		tbArenaMan.tbSingleApply = tbArenaMan.tbSingleApply or {}
		tbArenaMan.tbSingleApply[nApplyId] = nArenaId
	end
	
	self:SynArenaManData(pPlayer)
	self:SynPlayerApplyData(pPlayer)
	pPlayer.CenterMsg("已發起挑戰，請等候擂主回應")
end

function ArenaBattle:PickChallenger(pPlayer,tbApplyData,bAuto)
	if not self:CheckValidMap(pPlayer) then
		return 
	end

	local nIdx = tbApplyData and tbApplyData.nIdx
	local nChallengerId = tbApplyData and tbApplyData.nChallengerId
	local nArenaId = tbApplyData and tbApplyData.nArenaId
	if not nIdx or not nChallengerId or not nArenaId then
		return 
	end

	local tbArenaInfo = self:GetArenaInfo(nArenaId)
	if not tbArenaInfo then
		pPlayer.CenterMsg("找不到擂臺數據")
		Log("[ArenaBattle] PickChallenger can not find arena !",nArenaId,pPlayer.dwID,pPlayer.szName,pPlayer.nMapTemplateId,nIdx,nChallengerId)
		return
	end

	local tbArenaMan = tbArenaInfo.tbArenaMan
	if not tbArenaMan or not tbArenaMan.nArenaManId then
		pPlayer.CenterMsg("找不到擂主信息")
		Log("[ArenaBattle] PickChallenger can not find arena man !",nArenaId,pPlayer.dwID,pPlayer.szName,pPlayer.nMapTemplateId,nIdx,nChallengerId)
		return 
	end

	local nArenaManId = tbArenaMan.nArenaManId
	local pMan = KPlayer.GetPlayerObjById(nArenaManId)
	if not pMan then
		Log("[ArenaBattle] PickChallenger can not find pMan !",nArenaId,tbArenaMan.nArenaManId,pPlayer.dwID,pPlayer.szName,pPlayer.nMapTemplateId,nIdx,nChallengerId)
		return 
	end

	local manTeamData = TeamMgr:GetTeamById(pMan.dwTeamID)
	if pPlayer.dwID ~= nArenaManId then
		if manTeamData then
			pPlayer.CenterMsg("擂主隊伍隊長才可挑選挑戰者")
		else
			pPlayer.CenterMsg("擂主才可挑選挑戰者")
			Log("[ArenaBattle] PickChallenger single fight picker not match arenaman!",nArenaId,tbArenaMan.nArenaManId,pPlayer.dwID,pPlayer.szName,pPlayer.nMapTemplateId,nIdx,nChallengerId)
		end
		return
	end

	local tbApply = tbArenaMan.tbApply
	local tbApplyInfo = tbApply and tbApply[nIdx] 
	if not tbApplyInfo or not tbApplyInfo.nApplyId or not tbApplyInfo.nTeamId then
		self:SynChallengerData(pPlayer,nArenaId)
		pPlayer.CenterMsg("申請者資料發生變動,請重新選擇")
		return
	end

	local nApplyId = tbApplyInfo.nApplyId
	local nChallengerTeamId = tbApplyInfo.nTeamId
	local challengerTeamData = TeamMgr:GetTeamById(nChallengerTeamId)
	if challengerTeamData then
		nApplyId = challengerTeamData.nCaptainID
	end

	if nApplyId ~= nChallengerId then
		-- 一般是申请人移交队长了
		-- 同步申请者数据到客户端
		self:SynChallengerData(pPlayer,nArenaId)
		pPlayer.CenterMsg("申請者資料變動,請重新選擇")
		return
	end
	
	if manTeamData then 												-- 组队战
		if not challengerTeamData then
			self:RemoveApply(nArenaId,nIdx)
			self:SynChallengerData(pPlayer,nArenaId)
			pPlayer.CenterMsg("挑戰者隊伍已解散")
			return
		end
		nChallengerId = challengerTeamData.nCaptainID 					-- 找到当前队伍的队长（有可能移交队长）
	else 																-- 单人战
		if challengerTeamData then 										-- 单人战申请列表有组队战申请？？
			self:RemoveApply(nArenaId,nIdx)
			self:SynChallengerData(pPlayer,nArenaId)
			pPlayer.CenterMsg("異常數據")
			Log("[ArenaBattle] PickChallenger single arena with team challenger!",nArenaId,tbArenaMan.nArenaManId,pPlayer.dwID,pPlayer.szName,pPlayer.nMapTemplateId,nIdx,nChallengerId)
			return
		end
	end

	local pChallenger = KPlayer.GetPlayerObjById(nChallengerId)
	if not pChallenger then
		self:RemoveApply(nArenaId,nIdx)
		self:SynChallengerData(pPlayer,nArenaId)
		pPlayer.CenterMsg("挑戰者不線上")
		return 
	end

	local bRet,szMsg = self:CheckChallengerCommond(pChallenger,manTeamData)
	if not bRet then
		self:RemoveApply(nArenaId,nIdx)
		self:SynChallengerData(pPlayer,nArenaId)
		pPlayer.CenterMsg(szMsg)
		return
	end

	local tbArenaFight,szLog = self:ApplyArenaFight(nArenaId)
	local szFunc = bAuto and "AutoPickChallenger" or "PickChallenger"
	if not tbArenaFight then
		pPlayer.CenterMsg(szLog)
		Log("[ArenaBattle] PickChallenger ApplyArenaFight fail",nArenaId,tbArenaMan.nArenaManId,pPlayer.dwID,pPlayer.szName,pPlayer.nMapTemplateId,nIdx,nChallengerId,szFunc,szLog)
		return
	end
	self:RemoveApply(nArenaId,nIdx)
	self:SynChallengerData(pPlayer,nArenaId)
	self:SynPlayerApplyData(pChallenger)
	tbArenaFight:TryStart(nChallengerId)
	return true
end

function ArenaBattle:AutoPickChallenger(nArenaId)
	local bRet,pMan = self:CheckArenaManCanAutoPick(nArenaId)
	if not bRet then
		self:ResetArenaManInfo(nArenaId)
		return
	end

	local tbApplyData = self:GetApplyData(nArenaId,1)[1]
	local nApplyId = tbApplyData and tbApplyData.nPlayerID or 0
	local pApply = KPlayer.GetPlayerObjById(nApplyId or 0)
	if not tbApplyData or not pApply then
		-- 进入阶段一，等待申请
		pMan.CenterMsg("找不到合適的挑戰者")
		return
	end

	local nIdx = tbApplyData.nIdx

	local tbApplyData = {
		nIdx = nIdx,
		nChallengerId = nApplyId,
		nArenaId = nArenaId,
	}

	local bRet = ArenaBattle:PickChallenger(pMan,tbApplyData,true)
	if not bRet then
		-- 进入阶段一，等待申请
		pMan.CenterMsg("選取挑戰者失敗")
		return 	
	end

	return true
end

-- 申请擂台
function ArenaBattle:ApplyArenaFight(nArenaId)
	local tbArenaFight = self:GetArenaFight(nArenaId)
	if not tbArenaFight then
		return false,"找不到擂臺??"
	end

	if tbArenaFight.bStart then
		return false,"該擂臺有人使用中"
	end

	return tbArenaFight
end


function ArenaBattle:CheckChallengerCommond(pPlayer,bIsTeam)
	if not self:CheckValidMap(pPlayer) then
		return false,"該挑戰者不在當前地圖"
	end 

	if self:CheckIsChallenger(pPlayer.dwID) then
		return false,"該挑戰者正在其它擂臺戰鬥中"
	end

	--不能挑战擂主成员
	if self:CheckIsArenaTeamMan(pPlayer.dwID) then
		return false,"該挑戰者正在其它擂臺戰鬥中"
	end

	--挑战者已加入其它队伍
	if not bIsTeam and pPlayer.dwTeamID > 0 then
		return false,"該挑戰者當前無法上擂臺"
	end

	--挑战者队伍已解散
	if bIsTeam and pPlayer.dwTeamID <= 0 then
		return false,"該挑戰者當前無法上擂臺"
	end

	return true
end

function ArenaBattle:SendBeArenaManTip(pPlayer)
	if pPlayer.dwTeamID > 0 then
		local tbMember = TeamMgr:GetMembers(pPlayer.dwTeamID);
		for _,dwID in pairs(tbMember) do
			local pMember = KPlayer.GetPlayerObjById(dwID)
			if pMember then
				Dialog:SendBlackBoardMsg(pMember, "恭喜成為擂主");
			end
		end
	else
		Dialog:SendBlackBoardMsg(pPlayer, "恭喜成為擂主");
	end
end

function ArenaBattle:RemoveAllSingleApply(pPlayer)
	if pPlayer.dwTeamID > 0 then
		local tbMember = TeamMgr:GetMembers(pPlayer.dwTeamID);
		for _,dwID in pairs(tbMember) do
			local pMember = KPlayer.GetPlayerObjById(dwID)
			if pMember then
				if self:RemoveSingleApply(pMember) then
					self:SynMyApplyData(pMember)
				end
			end
		end
	end
end

function ArenaBattle:RemoveSingleApply(pPlayer)
	local bIsRemove
	for nArenaId = 1,ArenaBattle.nArenaNum do
		local tbArenaInfo = self:GetArenaInfo(nArenaId)
		if tbArenaInfo and tbArenaInfo.tbArenaMan and tbArenaInfo.tbArenaMan.tbApply then
			if tbArenaInfo.tbArenaMan.tbSingleApply and tbArenaInfo.tbArenaMan.tbSingleApply[pPlayer.dwID] then
				local tbApply = tbArenaInfo.tbArenaMan.tbApply

				for nIdx = #tbApply,1,-1 do
					local tbInfo = tbApply[nIdx]
					local nApplyId = tbInfo and tbInfo.nApplyId
					local nTeamId = tbInfo and tbInfo.nTeamId
					if nApplyId and nTeamId and nApplyId == pPlayer.dwID and nTeamId == -1 then
						table.remove(tbApply,nIdx)
					end
				end
				tbArenaInfo.tbArenaMan.tbSingleApply[pPlayer.dwID] = nil
				bIsRemove = true
			end	
		end
	end
	return bIsRemove
end

-- 只有传队长才会删除组队申请
function ArenaBattle:RemoveAllApply(pPlayer)
	for nArenaId = 1,ArenaBattle.nArenaNum do
		local tbArenaInfo = self:GetArenaInfo(nArenaId)
		if tbArenaInfo and tbArenaInfo.tbArenaMan and tbArenaInfo.tbArenaMan.tbApply then
			local tbApply = tbArenaInfo.tbArenaMan.tbApply
			for nIdx = #tbApply,1,-1 do
				local tbInfo = tbApply[nIdx]
				local nApplyId = tbInfo and tbInfo.nApplyId
				local nTeamId = tbInfo and tbInfo.nTeamId
				if nTeamId and nApplyId then
					if nTeamId == -1 then 														-- 单人直接比对删除单人申请
						if nApplyId == pPlayer.dwID then
							table.remove(tbApply,nIdx)
						end
					else
						local tbTeamData = TeamMgr:GetTeamById(nTeamId)

						if tbTeamData and tbTeamData.nCaptainID == pPlayer.dwID then 			-- 组队，找当前队伍队长比对并删除（有可能之前申请的队长离队了）
							table.remove(tbApply,nIdx)
						end
					end
				end
			end
			if pPlayer.dwTeamID > 0 then
				if tbArenaInfo.tbArenaMan.tbTeamApply then
					tbArenaInfo.tbArenaMan.tbTeamApply[pPlayer.dwTeamID] = nil
				end
			end
			if tbArenaInfo.tbArenaMan.tbSingleApply then
				tbArenaInfo.tbArenaMan.tbSingleApply[pPlayer.dwID] = nil
			end	
			self:SynMyApplyData(pPlayer)
		end
	end
end

function ArenaBattle:RemoveApply(nArenaId,nIdx)
	local tbArenaInfo = self:GetArenaInfo(nArenaId)
	if tbArenaInfo and tbArenaInfo.tbArenaMan and tbArenaInfo.tbArenaMan.tbApply and tbArenaInfo.tbArenaMan.tbApply[nIdx] then
		local nApplyId = tbArenaInfo.tbArenaMan.tbApply[nIdx].nApplyId
		local nApplyTeamId = tbArenaInfo.tbArenaMan.tbApply[nIdx].nTeamId
		if nApplyId and nApplyTeamId then
			if nApplyTeamId > 0 then
				if tbArenaInfo.tbArenaMan.tbTeamApply then
					tbArenaInfo.tbArenaMan.tbTeamApply[nApplyTeamId] = nil
				end
			else
				if tbArenaInfo.tbArenaMan.tbSingleApply then
					tbArenaInfo.tbArenaMan.tbSingleApply[nApplyId] = nil
				end
			end
		end
		table.remove(tbArenaInfo.tbArenaMan.tbApply,nIdx)
	end
end

function ArenaBattle:GetApply(pPlayer)
	local tbApply 
	for nArenaId = 1,ArenaBattle.nArenaNum do
		local tbArenaInfo = self:GetArenaInfo(nArenaId)
		if tbArenaInfo.tbArenaMan then
			local tbArenaMan = tbArenaInfo.tbArenaMan
			if (tbArenaMan.tbTeamApply and tbArenaMan.tbTeamApply[pPlayer.dwTeamID]) or (tbArenaMan.tbSingleApply and tbArenaMan.tbSingleApply[pPlayer.dwID]) then
				local nArenaManId = tbArenaMan.nArenaManId or 0
				local pMan = KPlayer.GetPlayerObjById(nArenaManId)
				if pMan then
					local bIsTeam = TeamMgr:GetTeamById(pMan.dwTeamID)
					if self:CheckChallengerCommond(pPlayer,bIsTeam) then
						tbApply = tbApply or {}
						table.insert(tbApply,nArenaId)
					end
				end
			end
		end
	end
	return tbApply
end

-- 同步擂台状态
function ArenaBattle:RefreshArenaState(pPlayer)
	local tbFightingArena = {}
	for nArenaId = 1,ArenaBattle.nArenaNum do
		local tbArenaFight = self:GetArenaFight(nArenaId)
		if tbArenaFight then
			if tbArenaFight.bStart then
				table.insert(tbFightingArena,nArenaId)
			end
		end
	end
	pPlayer.CallClientScript("ArenaBattle:OnRefreshArenaState",tbFightingArena)
end

-- 同步擂台数据
function ArenaBattle:SynArenaManData(pPlayer)
	local tbArenaData = {}
	local tbApply = self:GetApply(pPlayer)

	for nArenaId,tbArenaInfo in ipairs(ArenaBattle.tbArenaInfo) do
		if tbArenaInfo.tbArenaMan and tbArenaInfo.tbArenaMan.nArenaManId then
			local nArenaManId = tbArenaInfo.tbArenaMan.nArenaManId
			local pMan = KPlayer.GetPlayerObjById(nArenaManId)
			if pMan then
				local nTeammate = -1 					-- 单人
				if pMan.dwTeamID > 0 then
					local tbTeamData = TeamMgr:GetTeamById(pMan.dwTeamID)
					if tbTeamData then
						nTeammate = tbTeamData:GetMemberCount()
					end
				end
				tbArenaData[nArenaId] = {
					nPlayerID = nArenaManId,
					szName = pMan.szName or XT("無"),
					nLevel = pMan.nLevel,
					nHonorLevel = pMan.nHonorLevel or 0,
					nPortrait = pMan.nPortrait or 0,
					nFaction = pMan.nFaction,
					nTeammate = nTeammate,
					tbApply = tbApply,
				}
			end
		end
	end
	pPlayer.CallClientScript("ArenaBattle:OnSynArenaData",tbArenaData)
end

function ArenaBattle:SynPlayerApplyData(pPlayer)
	local tbApply = self:GetApply(pPlayer) or {}
	if pPlayer.dwTeamID > 0 then
		local tbMember = TeamMgr:GetMembers(pPlayer.dwTeamID);
		for _,dwID in pairs(tbMember) do
			local pMember = KPlayer.GetPlayerObjById(dwID)
			if pMember then
				pMember.CallClientScript("ArenaBattle:OnSynApplyData",tbApply)
			end
		end
	else
		pPlayer.CallClientScript("ArenaBattle:OnSynApplyData",tbApply)
	end
end

function ArenaBattle:SynMyApplyData(pPlayer)
	local tbApply = self:GetApply(pPlayer) or {}
	pPlayer.CallClientScript("ArenaBattle:OnSynApplyData",tbApply)
end

-- 整理同步申请信息(同步当前有效申请信息（必须是擂主或擂主队友的人才会同步）)
function ArenaBattle:SynChallengerData(pPlayer)
	local nArenaId = self:CheckIsArenaTeamMan(pPlayer.dwID)
	if not nArenaId then
		return
	end
	
	local tbApplyData = self:GetApplyData(nArenaId,ArenaBattle.nMaxSynData)
	pPlayer.CallClientScript("ArenaBattle:OnSynChallengerData",tbApplyData);
end

-- 拿申请数据(在线&队伍有效)
function ArenaBattle:GetApplyData(nArenaId,nCount)
	local tbApplyData = {}

	local tbArenaInfo = nArenaId and self:GetArenaInfo(nArenaId)
	if not tbArenaInfo or not nCount then
		return tbApplyData
	end

	if not tbArenaInfo.tbArenaMan or not tbArenaInfo.tbArenaMan.tbApply or not tbArenaInfo.tbArenaMan.nArenaManId then
		return tbApplyData
	end

	local nArenaManId = tbArenaInfo.tbArenaMan.nArenaManId
	local pMan = KPlayer.GetPlayerObjById(nArenaManId)
	if not pMan then
		return tbApplyData
	end

	local bIsTeam = TeamMgr:GetTeamById(pMan.dwTeamID)
	local nIdx = 1
	while true do
		local tbApply = tbArenaInfo.tbArenaMan.tbApply[nIdx]
		if not tbApply or #tbApplyData >= nCount then
			break
		end
		local nApplyId
		local nTeammate
		local nTeamId = tbApply.nTeamId
		if nTeamId then
			if nTeamId > 0 then
				local tbTeamData = TeamMgr:GetTeamById(nTeamId)
				if tbTeamData then 									-- 组队
					nApplyId = tbTeamData.nCaptainID
					nTeammate = tbTeamData:GetMemberCount()
				end
			else
				nApplyId = tbApply.nApplyId
				nTeammate = -1 										-- 单人
			end
			local pApply = KPlayer.GetPlayerObjById(nApplyId or 0)
			if pApply and self:CheckChallengerCommond(pApply,bIsTeam) then
				local tbPlayerData = {
					nPlayerID = nApplyId,
					nIdx = nIdx,
					szName = pApply.szName or XT("無"),
					nHonorLevel = pApply.nHonorLevel or 0,
					nPortrait = pApply.nPortrait or 0,
					nTeammate = nTeammate,
					nTeamId = nTeamId,
					nFaction = pApply.nFaction,
					nLevel = pApply.nLevel,
					nArenaId = nArenaId
				}
				table.insert(tbApplyData,tbPlayerData)
			end
		end
		nIdx = nIdx + 1
	end

	return tbApplyData
end

function ArenaBattle:ResetArenaInfo(nArenaId)
	ArenaBattle.tbArenaInfo[nArenaId] = {}
end

function ArenaBattle:ResetArenaManInfo(nArenaId)
	local tbArenaInfo = self:GetArenaInfo(nArenaId)
	if tbArenaInfo then
		tbArenaInfo.tbArenaMan = nil
		tbArenaInfo.tbCurChallenger = nil
	end
end

function ArenaBattle:ClearChallenger(nArenaId)
	local tbArenaInfo = ArenaBattle:GetArenaInfo(nArenaId)
	if tbArenaInfo then
		tbArenaInfo.tbCurChallenger = nil
	end
end

function ArenaBattle:GetArenaFight(nArenaId)
	return self.tbGame[nArenaId]
end

function ArenaBattle:CheckValidMap(pPlayer)
	return pPlayer.nMapTemplateId == ArenaBattle.nArenaMapId
end

-- 检查是否是擂主（组队的擂主是队长）
function ArenaBattle:CheckIsArenaMan(nPlayerID,nArenaId)
	for nId,tbArenaInfo in pairs(ArenaBattle.tbArenaInfo) do
		if nArenaId then
			if nArenaId == nId then
				if tbArenaInfo.tbArenaMan and tbArenaInfo.tbArenaMan.nArenaManId and tbArenaInfo.tbArenaMan.nArenaManId == nPlayerID then
					return nId
				end
			end
		else
			if tbArenaInfo.tbArenaMan and tbArenaInfo.tbArenaMan.nArenaManId and tbArenaInfo.tbArenaMan.nArenaManId == nPlayerID then
				return nId
			end
		end
	end
end

-- 检查是不是挑战者或挑战者队伍的队长
function ArenaBattle:CheckIsChallengeMan(nPlayerID,nArenaId)
	for nId,tbArenaInfo in pairs(ArenaBattle.tbArenaInfo) do
		if nArenaId then
			if nArenaId == nId then
				if tbArenaInfo.tbCurChallenger and tbArenaInfo.tbCurChallenger.nChallengerId and tbArenaInfo.tbCurChallenger.nChallengerId == nPlayerID then
					return nId
				end
			end
		else
			if tbArenaInfo.tbCurChallenger and tbArenaInfo.tbCurChallenger.nChallengerId and tbArenaInfo.tbCurChallenger.nChallengerId == nPlayerID then
				return nId
			end
		end
	end
end

-- 检查是不是擂主或擂主队伍中的一员,nArenaId不传则遍历所有擂台
function ArenaBattle:CheckIsArenaTeamMan(nPlayerID,nArenaId)
	for nId,tbArenaInfo in pairs(ArenaBattle.tbArenaInfo) do
		if nArenaId then
			if nArenaId == nId and tbArenaInfo.tbArenaMan and tbArenaInfo.tbArenaMan.nArenaManId then
				local nArenaManId = tbArenaInfo.tbArenaMan.nArenaManId
				local pMan = KPlayer.GetPlayerObjById(nArenaManId)
				if pMan then
					if nArenaManId == nPlayerID or self:CheckIsTeammate(nArenaManId,nPlayerID) then
						return nId
					end
				end
			end
		else
			if tbArenaInfo.tbArenaMan and tbArenaInfo.tbArenaMan.nArenaManId then
				local nArenaManId = tbArenaInfo.tbArenaMan.nArenaManId
				local pMan = KPlayer.GetPlayerObjById(nArenaManId) 					-- 一般不存在不在线的擂主
				if pMan then
					if nArenaManId == nPlayerID or self:CheckIsTeammate(nArenaManId,nPlayerID) then
						return nId
					end
				end
			end
		end
	end
end

function ArenaBattle:CheckIsTeammate(nArenaManId,nPlayerID)
	local pMan = KPlayer.GetPlayerObjById(nArenaManId)
	if pMan then
		if pMan.dwTeamID > 0 then 						-- 组队战
			local tbMember = TeamMgr:GetMembers(pMan.dwTeamID);
			for _,dwID in pairs(tbMember) do
				if dwID == nPlayerID then
					return true
				end
			end
		end
	end
end

-- 检查是不是挑战者
function ArenaBattle:CheckIsChallenger(nPlayerID)
	for nArenaId,tbArenaInfo in pairs(ArenaBattle.tbArenaInfo) do
		if tbArenaInfo.tbCurChallenger and tbArenaInfo.tbCurChallenger.nChallengerId then
			local nChallengerId = tbArenaInfo.tbCurChallenger.nChallengerId
			local pChallenger = KPlayer.GetPlayerObjById(nChallengerId)
			if pChallenger then
				if pChallenger.dwTeamID > 0 then 						-- 组队战
					local tbMember = TeamMgr:GetMembers(pChallenger.dwTeamID);
					for _,dwID in pairs(tbMember) do
						if dwID == nPlayerID then
							return nArenaId
						end
					end
				else
					if nPlayerID == nChallengerId then 					-- 单人战
						return nArenaId
					end
				end
			end
		end
	end
end

function ArenaBattle:CheckIsFighting(pPlayer)
	return self:CheckIsArenaTeamMan(pPlayer.dwID) or self:CheckIsChallenger(pPlayer.dwID)
end

function ArenaBattle:CheckArenaManCanAutoPick(nArenaId)
	local tbArenaInfo = self:GetArenaInfo(nArenaId)
	if not tbArenaInfo then
		return 
	end

	local tbArenaMan = tbArenaInfo.tbArenaMan
	if not tbArenaMan or not tbArenaMan.nArenaManId then
		return
	end

	local nArenaManId = tbArenaMan.nArenaManId
	local pMan = KPlayer.GetPlayerObjById(nArenaManId)
	if not pMan then
		return
	end

	if not self:CheckValidMap(pMan) then
		return
	end

	return true,pMan

end

function ArenaBattle:GetArenaInfo(nArenaId)
	return ArenaBattle.tbArenaInfo[nArenaId]
end

function ArenaBattle:ClearApply(nArenaId)
	local tbArenaInfo = nArenaId and self:GetArenaInfo(nArenaId)
	if tbArenaInfo and tbArenaInfo.tbArenaMan then
		tbArenaInfo.tbArenaMan.tbApply = {}
		tbArenaInfo.tbArenaMan.tbSingleApply = {}  
		tbArenaInfo.tbArenaMan.tbTeamApply = {}  
	end
end

-- 擂主即将变动，前擂主申请者的提示并同步数据
function ArenaBattle:ArenaManChangeNotice(nArenaId)
	local tbApply = self:GetApplyData(nArenaId,ArenaBattle.nMaxSynData)    			-- 先拿出来
	self:ClearApply(nArenaId) 														-- 再清空

	for _,tbData in ipairs(tbApply) do
		local nApplyId = tbData.nPlayerID or 0
		local pApply = KPlayer.GetPlayerObjById(nApplyId)
		if pApply then
			-- 同步已申请的擂台数据
			self:SynPlayerApplyData(pApply)
			
			if pApply.dwTeamID > 0 then
				local tbMember = TeamMgr:GetMembers(pApply.dwTeamID);
				for _,dwID in pairs(tbMember) do
					local pMember = KPlayer.GetPlayerObjById(dwID)
					if pMember then
						pMember.CenterMsg(string.format("%s號擂主變動，請重新報名挑戰",nArenaId),true)
					end
				end
			else
				pApply.CenterMsg(string.format("%s號擂主變動，請重新報名挑戰",nArenaId),true)
			end
		end
	end
end

function ArenaBattle:OnArenaManChange(nArenaId,nPlayerID,bUnderArena)
	Lib:CallBack({ArenaBattle.ArenaManChangeNotice,ArenaBattle,nArenaId});
	local bRet = self:TurnArenaMan(nArenaId,nPlayerID)
	local tbArenaFight,szLog = self:ApplyArenaFight(nArenaId)
	if not tbArenaFight or not bRet then 
		Log("[ArenaBattle] OnArenaManChange apply arena fail",nArenaId,nPlayerID,szLog,bUnderArena and 1 or 0,bRet and 1 or 0,tbArenaFight and 1 or 0)
		return 
	end
	if  tbArenaFight.OnArenaManChange then
		tbArenaFight:OnArenaManChange(nPlayerID,bUnderArena)
	end
end

function ArenaBattle:TurnArenaMan(nArenaId,nArenaManId)
	local tbArenaInfo = self:GetArenaInfo(nArenaId)
	if not tbArenaInfo then
		return false
	end

	tbArenaInfo.tbArenaMan = {
		nArenaManId = nArenaManId,
		tbApply = {},
		tbSingleApply = {},
		tbTeamApply = {},
	}
	tbArenaInfo.tbCurChallenger= {}
	return true
end

function ArenaBattle:Leave(pPlayer,bSure)
	local nArenaId = self:CheckIsFighting(pPlayer)
	if nArenaId then
		local tbArenaFight = self:GetArenaFight(nArenaId)
		if not tbArenaFight then
			pPlayer.CenterMsg("找不到擂臺出口")
			Log("[ArenaBattle] Leave fail",pPlayer.dwID,pPlayer.dwTeamID,pPlayer.szName,pPlayer.nMapTemplateId)
			return
		end

		if tbArenaFight.bStart then
			pPlayer.CenterMsg("正在比武中，無法離開擂臺")
			return			
		end

		local function fnLeave(nPlayerID)
			local pMan = KPlayer.GetPlayerObjById(nPlayerID)
			if not pMan then
				return
			end
			ArenaBattle:Leave(pMan,true)
		end

		if pPlayer.dwTeamID > 0 then
			
			local pTeamData = TeamMgr:GetTeamById(pPlayer.dwTeamID)
			local bIsCaptain
			if pTeamData and pPlayer.dwID == pTeamData.nCaptainID then
				bIsCaptain = true
			end
			local szMsgTip = bIsCaptain and "離開將全隊下擂臺" or "離開將下擂臺並退出當前隊伍"
			if not bSure then
				pPlayer.MsgBox(szMsgTip,
				{
					{"確認離開", fnLeave, pPlayer.dwID},
					{"取消"},
				})
			else
				if bIsCaptain then
					local tbMember = TeamMgr:GetMembers(pPlayer.dwTeamID);
					for _,dwID in pairs(tbMember) do
						local pMember = KPlayer.GetPlayerObjById(dwID)
						if pMember then
							tbArenaFight:OnLeave(pMember)
						end
					end
				else
					tbArenaFight:OnLeave(pPlayer)
					TeamMgr:QuiteTeam(pPlayer.dwTeamID, pPlayer.dwID)
				end
			end
			
		else
			if not bSure then
				pPlayer.MsgBox("確定要離開擂臺嗎?",
				{
					{"確認離開", fnLeave, pPlayer.dwID},
					{"取消"},
				})
			else
				tbArenaFight:OnLeave(pPlayer)
			end
		end
	else
		pPlayer.CenterMsg("你已經在擂臺下了")
	end
end

-- 队伍ID发生改变
function ArenaBattle:OnTeamChanged(pPlayer)
	if not ArenaBattle:CheckValidMap(pPlayer) then
		return
	end
	if pPlayer.dwTeamID > 0 then
		ArenaBattle:RemoveSingleApply(pPlayer)
	end
	self:SynMyApplyData(pPlayer)
end

-------------------------------------------观战-----------------------

function ArenaBattle:OnPlayerTrap(szClassName)
	local tbTrapInfo = szClassName and self:GetWatchTrapInfo(szClassName)
	if not tbTrapInfo then
		Log("[ArenaBattle] can no find trap info",szClassName,me.szName,me.dwID,me.nMapTemplateId,me.dwTeamID)
		return
	end
	
	local nArenaId = tbTrapInfo.nArenaId
	local nTrapType = tbTrapInfo.nType

	local tbArenaFight = self:GetArenaFight(nArenaId)
	if not tbArenaFight then
		return
	end
	if nTrapType == ArenaBattle.TrapType.In and tbArenaFight.OnTryIn then
		tbArenaFight:OnTryIn(me)
	elseif nTrapType == ArenaBattle.TrapType.Out and tbArenaFight.OnTrapOut then
		tbArenaFight:OnTrapOut(me)
	end

end

function ArenaBattle:GetWatchTrapInfo(szTrapName)
	return szTrapName and ArenaBattle.TrapData[szTrapName]
end

function ArenaBattle:GetWatchData(pTargePlayer,pPlayer)
	local tbCamp = {}
	if pTargePlayer.dwTeamID > 0 then
		local tbMember = TeamMgr:GetMembers(pTargePlayer.dwTeamID);
		for _,dwID in pairs(tbMember) do
			local pMember = KPlayer.GetPlayerObjById(dwID)
			if pMember then
				local pNpc = pMember.GetNpc();
				if pNpc and not pNpc.GetSkillState(TeamBattle.nDeathSkillState) then
					pNpc.AddToForceSyncSet(pPlayer.dwID); 			-- 将目标玩家强制加到观战玩家同步范围
					pPlayer.SyncNpc(pNpc.nId)
					table.insert(tbCamp,{pMember.szName,pNpc.nId})
				end
			end
		end
	else
		local pNpc = pTargePlayer.GetNpc();
		if pNpc and not pNpc.GetSkillState(TeamBattle.nDeathSkillState) then
			pNpc.AddToForceSyncSet(pPlayer.dwID);
			pPlayer.SyncNpc(pNpc.nId)
			table.insert(tbCamp,{pTargePlayer.szName,pNpc.nId})
		end
	end
	return tbCamp
end

function ArenaBattle:SyncWatchInfo(pPlayer,nArenaId)
	local tbArenaInfo = nArenaId and self:GetArenaInfo(nArenaId)
	if not tbArenaInfo then
		return
	end
	
	local tbWatchData = {}
	tbWatchData[nArenaId] = tbWatchData[nArenaId] or {}

	if tbArenaInfo.tbArenaMan and tbArenaInfo.tbArenaMan.nArenaManId then
		local pMan = KPlayer.GetPlayerObjById(tbArenaInfo.tbArenaMan.nArenaManId)
		if pMan then
			tbWatchData[nArenaId][ArenaBattle.tbForeachType.ARENA_MAN] = self:GetWatchData(pMan,pPlayer)
		end
	end

	if tbArenaInfo.tbCurChallenger and tbArenaInfo.tbCurChallenger.nChallengerId then
		local pChallenger = KPlayer.GetPlayerObjById(tbArenaInfo.tbCurChallenger.nChallengerId)
		if pChallenger then
			tbWatchData[nArenaId][ArenaBattle.tbForeachType.CHALLENGER] = self:GetWatchData(pChallenger,pPlayer)
		end
	end

	pPlayer.CallClientScript("ArenaBattle:SyncWatchInfo",tbWatchData,nArenaId)
end

-- 清理等待观战列表
function ArenaBattle:ClearOtherWaitWatch(nArenaId,nPlayerID)
	if not nArenaId or not nPlayerID then
		return
	end
	for nId = 1,ArenaBattle.nArenaNum do
		if nId ~= nArenaId then
			local tbArenaFight = self:GetArenaFight(nId)
			if tbArenaFight and tbArenaFight.tbWatchList and tbArenaFight.tbWatchList[nPlayerID] then
				tbArenaFight.tbWatchList[nPlayerID] = nil
			end
		end
	end
end

--------------------------------- Map -------------------------------------
local tbMap = Map:GetClass(ArenaBattle.nArenaMapId);

function tbMap:OnEnter(nMapId)
	ArenaBattle:SynMyApplyData(me)
	me.nInBattleState = 1
	local nArenaId = ArenaBattle:CheckIsFighting(me)
	if not nArenaId then
		local posX,posY = Map:GetDefaultPos(ArenaBattle.nArenaMapId)
		if posX and posY then
			me.SetPosition(posX,posY)
			me.CallClientScript("ArenaBattle:OnNoFightingEnterMap")
		end
	end
end

function tbMap:OnLeave(nMapId)
	me.bForbidTeamOp = nil
	me.nInBattleState = 0
	Env:SetSystemSwitchOn(me, Env.SW_All);
	ArenaBattle:ClearOtherWaitWatch(0,me.dwID)

	if me.dwTeamID > 0 then
		local tbTeamData = TeamMgr:GetTeamById(me.dwTeamID)
		if tbTeamData and ArenaBattle:GetApply(me) then
			local pCaptain = KPlayer.GetPlayerObjById(tbTeamData.nCaptainID)
			if pCaptain then
				ArenaBattle:RemoveAllApply(pCaptain)
				ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.Team, XT(string.format("由於「%s」離開了比武場，請重新對擂臺發起挑戰",me.szName)), me.dwTeamID);
				local tbMember = TeamMgr:GetMembers(me.dwTeamID);
				for _,dwID in pairs(tbMember) do
					local pMember = KPlayer.GetPlayerObjById(dwID)
					if pMember then
						pMember.CenterMsg(XT(string.format("由於「%s」離開了比武場，請重新對擂臺發起挑戰",me.szName)))
						ArenaBattle:SynMyApplyData(pMember)
					end
				end
			end
		end
	else
		ArenaBattle:RemoveSingleApply(me)
	end

	-- 一般不会出现切地图的时候还在台上
	local nArenaId = ArenaBattle:CheckIsFighting(me)
	if nArenaId then
		local tbArenaFight = ArenaBattle:GetArenaFight(nArenaId)
		if not tbArenaFight then
			return
		end
		if me.dwTeamID > 0 then
			if TeamMgr:GetTeamById(me.dwTeamID) then
				TeamMgr:QuiteTeam(me.dwTeamID, me.dwID)
			end
		end
		tbArenaFight:OnLeave(me)
		Log("[ArenaBattle] OnLeave map Fighting ",me.szName,me.dwID,me.nMapTemplateId,me.dwTeamID,nArenaId)
	end
end

function tbMap:OnPlayerTrap(nMapId, szClassName)
	ArenaBattle:OnPlayerTrap(szClassName)
end

