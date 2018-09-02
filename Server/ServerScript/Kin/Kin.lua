
local KinMgr = GetKinMgr();

function Kin:GetKinById(nKinId)
	return nKinId and Kin.KinData[nKinId];
end

function Kin:GetKinByMemberId(nMemberId)
	local tbMemberData = self:GetMemberData(nMemberId) or {}
	return Kin:GetKinById(tbMemberData.nKinId)
end

function Kin:GetKinIdByMemberId(nMemberId)
	local tbMember = Kin:GetMemberData(nMemberId)
	return tbMember and tbMember.nKinId or 0
end

function Kin:GetKinMembers(nKinId, bNotCopy)
	local kinData = assert(Kin:GetKinById(nKinId));
	if bNotCopy then
		return kinData.tbMembers;
	else
		return Lib:CopyTB1(kinData.tbMembers);
	end
end

function Kin:GetTopMemberLevel(nKinId,nRank)
	local tbKinData = Kin:GetKinById(nKinId);
	if not tbKinData then
		return 
	end

	local tbTopLevel = tbKinData:GetCacheTopLevel()

	if not next(tbTopLevel) or tbKinData:GetCacheFlag("UpdateTopLevel") then
		local tbMember = self:GetKinMembers(nKinId)
		local tbMemberLevel = {}
		local tbLevelFlag = {}
		for nPlayerID,_ in pairs(tbMember) do
			local pPlayer = KPlayer.GetPlayerObjById(nPlayerID) or KPlayer.GetRoleStayInfo(nPlayerID)
			if pPlayer and not tbLevelFlag[pPlayer.nLevel] then
				table.insert(tbMemberLevel,{nLevel = pPlayer.nLevel})
				tbLevelFlag[pPlayer.nLevel] = true
			end
		end

		table.sort(tbMemberLevel, function (a, b)
		    return a.nLevel > b.nLevel
		end)

		for i=1,nRank do
			tbTopLevel[i] = tbMemberLevel[i] or {nLevel = 0} 			-- 家族人数不够的情况
		end

		tbKinData:SetCacheFlag("UpdateTopLevel",nil)
		Log("[Kin] GetTopMemberLevel ",nKinId)
		Lib:LogTB(tbTopLevel)
	end

	return tbTopLevel
end

function Kin:GetMemberData(nPlayerId)
	if not nPlayerId then
		return
	end

	local tbMember = Kin.MemberData[nPlayerId]
	if not tbMember then
		return
	end

	local nKinId = tbMember.nKinId
	if not nKinId or nKinId<=0 then
		return
	end

	local tbKinData = Kin:GetKinById(nKinId)
	if not tbKinData then
		Log("[x] Kin:GetMemberData kin not exists", nPlayerId, nKinId)
		return
	end

	return tbMember
end

function Kin:GetPlayerCareer(nPlayerId)
	local tbMemberData = Kin:GetMemberData(nPlayerId) or {};
	return tbMemberData.nCareer or 0;
end

function Kin:PlayerAtSameKin(nPlayerId1, nPlayerId2)
	local member1 = Kin:GetMemberData(nPlayerId1);
	local member2 = Kin:GetMemberData(nPlayerId2);

	return member1 and member2
		and member1.nKinId == member2.nKinId
		and member1.nKinId ~= 0
end

function Kin:UpdateKinMemberInfo(nKinId)
	local kinData = Kin:GetKinById(nKinId);
	if kinData then
		kinData:SetCacheFlag("UpdateMemberInfoList", true);
		kinData:SetCacheFlag("UpdateTopLevel", true);
	end
end

function Kin:CreateMemberData(nKinId, nPlayerId)
	local tbMemberData = Kin.MemberData[nPlayerId]
	if not tbMemberData or tbMemberData.nKinId==0 then
		Kin:LoadMemberData(nPlayerId, {
			nKinId = nKinId,
			nMemberId = nPlayerId,
			nWeekActive = 0,
		});
	end

	tbMemberData = Kin:GetMemberData(nPlayerId);
	if tbMemberData then
		tbMemberData:ResetWeekActive()
	end
	return tbMemberData
end

function Kin:OnLogin()
	local kinMemberData = Kin:GetMemberData(me.dwID) or {};
	if not kinMemberData.nKinId or kinMemberData.nKinId == 0 then
		me.dwKinId = 0;
		return;
	end

	local szTitle = kinMemberData:GetFullTitle();
	Kin:SyncTitle(me.dwID, szTitle);
	me.dwKinId = kinMemberData.nKinId;

	Kin.KinNest:OnLogin(me);
	Kin.Gather:OnLogin(me)

	local kinData = Kin:GetKinById(kinMemberData.nKinId);
	if kinData.nMasterId == me.dwID then
		kinData:OnMasterLogin();
	elseif kinData.nLeaderId==me.dwID then
		kinData:OnLeaderLogin()
	end

	Achievement:AddCount(me, "Family_1");
	TeacherStudent:TargetAddCount(me, "JoinKin", 1)

	self:RedBagOnLogin(me)
end

function Kin:OnLogout(pPlayer)
	local memberData = Kin:GetMemberData(pPlayer.dwID);
	if memberData then
		memberData:Save();
	end
end

function Kin:Create(szKinName, szAddDeclare, nCamp)
	if me.dwKinId ~= 0 then
		return false, "已有幫派";
	end

	if me.nLevel < Kin.Def.nLevelLimite then
		return false, "未達到創建幫派等級";
	end

	if me.GetMoney("Gold") < Kin.Def.nCreationCost then
		return false, "金錢不足";
	end

	local nTotalKin = Lib:CountTB(Kin.KinData)
	if nTotalKin >= Kin.Def.nMaxCountPerSrv then
		return false, string.format("目前伺服器幫派數已達上限（%d個）", Kin.Def.nMaxCountPerSrv)
	end

	local bValid, szErr = self:IsNameValid(szKinName)
	if not bValid then
		return false, szErr
	end

	if Kin.tbAllKinNames[szKinName] then
		return false, "名字已被註冊";
	end

	local bRet = Kin:CheckKinCamp(nCamp);
	if not bRet then
		return false, "請選擇陣營！";
	end

	if Kin.Def.bForbidCamp then
		nCamp = Npc.CampTypeDef.camp_type_player;
	end

	-- CostGold谨慎调用, 调用前请搜索 _LuaPlayer.CostGold 查看使用说明, 它处调用时请保留本注释
	me.CostGold(Kin.Def.nCreationCost, Env.LogWay_CreateKin, nil, function (nPlayerId, bSuccess)
		if not bSuccess then
			return false;
		end

		local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
		if not pPlayer then
			return false, "創建幫派中途, 您離線了.";
		end

		if Kin.tbAllKinNames[szKinName] then
			return false, "名字已被註冊";
		end

		Kin:DoCreateKin(pPlayer, szKinName, szAddDeclare, nCamp);
		pPlayer.CenterMsg(string.format("你已成功創建幫派【%s】", szKinName));
		return true;
	end);

	return true;
end

function Kin:ChangeName(szKinName)
	local nKinId = me.dwKinId
	local tbKinData = Kin:GetKinById(nKinId)
	if not tbKinData then
		return false, "沒有幫派"
	end

	if me.dwID~=tbKinData:GetMasterId() then
		return false, "你不是堂主"
	end

	local nCost, bHasItem = Kin:GetChangeNamePrice(me)
	if me.GetMoney("Gold")<nCost then
		return false, "金錢不足"
	end

	local bValid, szErr = self:IsNameValid(szKinName)
	if not bValid then
		return false, szErr
	end

	if Kin.tbAllKinNames[szKinName] then
		return false, "名字已被註冊"
	end

	if nCost>0 then
		-- CostGold谨慎调用, 调用前请搜索 _LuaPlayer.CostGold 查看使用说明, 它处调用时请保留本注释
		me.CostGold(nCost, Env.LogWay_ChangeKinName, nil, function(nPlayerId, bSuccess)
			if not bSuccess then
				return false
			end

			local pPlayer = KPlayer.GetPlayerObjById(nPlayerId)
			if not pPlayer then
				return false, "修改幫派名中途, 您掉線了"
			end

			return self:ChangeNameAfterPay(pPlayer, nKinId, szKinName)
		end)
	elseif bHasItem then
		if me.ConsumeItemInAllPos(Kin.Def.nChangeNameItem, 1, Env.LogWay_ChangeKinName)>0 then
			return self:ChangeNameAfterPay(me, nKinId, szKinName)
		else
			Log("[x] Kin:ChangeName failed, item not exists")
			return false, "改名道具不存在"
		end
	else
		Log("[x] Kin:ChangeName failed, cost 0 and no item")
		return false, "未知錯誤"
	end

	return true
end

function Kin:ChangeNameAfterPay(pPlayer, nKinId, szKinName)
	if Kin.tbAllKinNames[szKinName] then
		return false, "名字已被註冊"
	end

	local bSuccess, szErr = self:DoChangeName(nKinId, szKinName)
	if not bSuccess then
		return false, szErr
	end
	pPlayer.CenterMsg(string.format("你已成功修改幫派名為【%s】", szKinName))
	Kin:SyncKinBaseInfo(0, pPlayer)

	return true
end

function Kin:DoChangeName(nKinId, szKinName)
	local tbKinData = Kin:GetKinById(nKinId)
	if not tbKinData then
		return false, "幫派不存在"
	end

	local bSuccess, szErr = tbKinData:ChangeName(szKinName)
	if not bSuccess then
		return false, szErr
	end

	return true
end

function Kin:DoCreateKin(pPlayer, szKinName, szAddDeclare, nKinCmp)
	local tbKinData = {};
	local nKinId = Kin:GetNextKinId(true);

	tbKinData.nKinId                        = nKinId;
	tbKinData.nCreateTime                   = GetTime();
	tbKinData.szName                        = szKinName;
	tbKinData.nLevel                        = 1;
	tbKinData.nFound                        = 0; -- 家族建设资金
	tbKinData.nMasterId                     = pPlayer.dwID;
	tbKinData.tbMembers                     = {}; -- 正式成员
	tbKinData.tbKinTitle                    = {};
	tbKinData.nToBreakTime                  = nil;
	tbKinData.tbContribution                = {}; -- 成员家族贡献存放处
	tbKinData.nPrestige                     = 0; -- 家族威望
	tbKinData.tbRecruitSetting              = {}; -- 招人条件设置
	tbKinData.tbRecruitSetting.szAddDeclare = szAddDeclare;
	tbKinData.tbRecruitSetting.nVersion     = 1;
	tbKinData.tbRecruitSetting.bAutoRecruitNewer = true;
	tbKinData.tbDonationRecord              = {};
	tbKinData.nDonationDataVersion          = 1;
	tbKinData.nKinCamp                      = nKinCmp; --家族阵营
	tbKinData.nKinCampCount   				= 0;
	tbKinData.nKinCampDay     				= 0;
	tbKinData.nChangeLeaderTime				= 0;
	tbKinData.nCandidateLeaderId			= 0;
	tbKinData.nAppointLeaderTime			= 0;
	tbKinData.nWeekActive					= 0;
	tbKinData.nSnowflake 					= 0;
	tbKinData.tbMakingPlayer 				= {};

	Kin:LoadKinData(nKinId, tbKinData);
	tbKinData:SetLeaderId(pPlayer.dwID, false)
	KinMgr.CreateKin(nKinId, szKinName);
	tbKinData:InitBuilding();
	tbKinData:CheckOrgServer();

	local tbMemberData = Kin:CreateMemberData(nKinId, pPlayer.dwID);
	tbMemberData:JoinKin(tbKinData);
	tbMemberData:SetCareer(Kin.Def.Career_Master);
	pPlayer.dwKinId = nKinId;

	pPlayer.AddMoney("Contrib", Kin.Def.nCreationContribution, Env.LogWay_CreateKin);

	local tbMail = {
		To = pPlayer.dwID;
		Title = "幫派信件";
		From = "幫派總管";
		Text = string.format("    恭喜你成功創建幫派：[FFFE0D]%s[-]\n    你成為了幫派第一任總堂主和第一任堂主。\n    [FFFE0D]總堂主[-]是幫派擁有者，有幫派最高許可權，可以任免堂主，並作為幫派代表獲得各種榮譽。\n    [aa62fc]堂主[-]主要職責為幫派日常管理，擁有幫派所有管理許可權。\n    每週一淩晨4點活躍評價達標的幫派，將由武林盟主獨孤劍給管理層[FFFE0D]（堂主、副堂主、會長、吉祥物）[-]發放工資[FFFE0D]（詳細查看幫派界面説明按鈕）[-]\n    合理安排管理層有利於幫派的發展，幫派總管會每天以郵件形式彙報本周幫派活躍情況，活躍持續不達標的幫派會被武林盟主強制解散。幫派的昌盛需要依靠每一位元成員的努力，快去招攬更多的成員壯大幫派吧！", szKinName);
	};

	Mail:SendSystemMail(tbMail);
	AssistClient:ReportQQScore(pPlayer, Env.QQReport_KinCreateTime, tbKinData.nCreateTime, 0, 1, true);
	AssistClient:ReportQQScore(pPlayer, Env.QQReport_KinName, szKinName, 0, 1, true);
	TLog("KinFlow", Env.LogWay_CreateKin, nKinId, szKinName, pPlayer.dwID, nKinCmp, 0);
end

function Kin:Apply(nKinId, bSilenceApply)
	if me.dwKinId ~= 0 then
		return false, "已有幫派";
	end

	if me.nLevel < Kin.Def.nLevelLimite then
		return false, "等級要求15級";
	end

	local kinData = Kin:GetKinById(nKinId);
	if not kinData then
		return false, "幫派不存在";
	end

	local nJoinCD = self:GetJoinCD(me)
	if nJoinCD>0 then
		return false, string.format("%s後才可以加入幫派", Lib:TimeDesc2(nJoinCD))
	end

	local isProbation = Kin:CheckIsProbation(me.nLevel);
	local bAailable, ret = kinData:Available2Join(isProbation);
	if not bAailable then
		return false, ret;
	end
	isProbation = ret

	if kinData:CheckApplyAutoPass(me, isProbation) then
		local meMemberData = Kin:CreateMemberData(nKinId, me.dwID);
		if meMemberData:JoinKin(kinData) then
			me.CenterMsg(string.format("成功加入【%s】幫派", kinData.szName));
			return true;
		end
	end

	kinData:Add2ApplyerList(me);

	if not bSilenceApply then
		me.CenterMsg(string.format("已向【%s】幫派發送了申請", kinData.szName));
	end

	return true;
end

function Kin:ApplyPlayer(nPlayerId)
	local tbRoleStayInfo = KPlayer.GetRoleStayInfo(nPlayerId);
	if tbRoleStayInfo.dwKinId == 0 then
		return false, "對方沒有幫派";
	end

	return Kin:Apply(tbRoleStayInfo.dwKinId);
end

function Kin:AgreeApply(nApplyerId)
	local meMemberData = Kin:GetMemberData(me.dwID);
	if not meMemberData or not meMemberData:CheckAuthority(Kin.Def.Authority_Recruit) then
		return false, "沒有許可權進行操作";
	end

	local nKinId = meMemberData.nKinId
	local kinData = Kin:GetKinById(nKinId);
	local isProbation = Kin:CheckIsProbation(me.nLevel);
	if not kinData or not kinData:Available2Join(isProbation) then
		return false, "幫派不可加入";
	end

	local applyerMemberData = Kin:GetMemberData(nApplyerId);
	if applyerMemberData and applyerMemberData.nKinId and applyerMemberData.nKinId ~= 0 then
		Kin:DeleteApplyerFromAllList(nApplyerId);
		return false, "申請者已有幫派";
	end

	local applyerInfo = kinData:GetApplyerInfo(nApplyerId);
	if not applyerInfo then
		return false, "不在申請列表中或超時";
	end

	applyerMemberData = Kin:CreateMemberData(nKinId, nApplyerId);
	local bSuccess = applyerMemberData:JoinKin(kinData);
	if not bSuccess then
		return false, "加入幫派失敗";
	end

	return true;
end

function Kin:DisagreeApply(nApplyerId)
	local meMemberData = Kin:GetMemberData(me.dwID);
	if not meMemberData or not meMemberData:CheckAuthority(Kin.Def.Authority_Recruit) then
		return false, "沒有許可權進行操作";
	end

	local kinData = Kin:GetKinById(meMemberData.nKinId);
	kinData:DeleteApplyerFromList(nApplyerId);

	return true;
end

function Kin:CleanApplyerList()
	local meMemberData = Kin:GetMemberData(me.dwID);
	if not meMemberData or not meMemberData:CheckAuthority(Kin.Def.Authority_Recruit) then
		return false, "沒有許可權進行操作";
	end

	local kinData = Kin:GetKinById(me.dwKinId);
	return kinData:ClearApplyerList();
end

function Kin:Invite(nTargetPlayerId)
	if me.dwKinId == 0 then
		return false, "你沒有幫派";
	end

	local meMemberData = Kin:GetMemberData(me.dwID);
	if not meMemberData or not meMemberData.nKinId then
		return false, "你也沒幫派囉";
	end

	local targetMemberData = Kin:GetMemberData(nTargetPlayerId) or {};
	if targetMemberData.nKinId and targetMemberData.nKinId ~= 0 then
		return false, "對方已經有幫派了";
	end

	local targetPlayer = KPlayer.GetPlayerObjById(nTargetPlayerId);
	if not targetPlayer then
		return false, "對方未在線";
	end

	if targetPlayer.nLevel < Kin.Def.nLevelLimite then
		return false, string.format("對方等級不足, 未到達%d級", Kin.Def.nLevelLimite);
	end

	local nJoinCD = self:GetJoinCD(targetPlayer)
	if nJoinCD>0 then
		return false, string.format("對方%s後才可以加入幫派", Lib:TimeDesc2(nJoinCD))
	end

	if targetPlayer.nInBattleState ~= 0 then
		return false, "對方正處於戰鬥中, 不可發送邀請";
	end

	local kinData = Kin:GetKinById(me.dwKinId);
	targetPlayer.CallClientScript("Kin:OnInvited", me.szName, kinData.szName, me.dwKinId);

	local powerfulInvite = meMemberData:CheckAuthority(Kin.Def.Authority_Recruit);
	local kinData = Kin:GetKinById(meMemberData.nKinId);
	kinData:Add2InviterList(nTargetPlayerId, powerfulInvite);
	me.CenterMsg(string.format("已向「%s」發起了幫派邀請", targetPlayer.szName));
	return true;
end

function Kin:AgreeInvite(nKinId)
	if me.dwKinId ~= 0 then
		return false, "已有幫派";
	end

	local nJoinCD = self:GetJoinCD(me)
	if nJoinCD>0 then
		return false, string.format("%s後才可以加入幫派", Lib:TimeDesc2(nJoinCD))
	end

	local kinData = Kin:GetKinById(nKinId);
	local tbInviterInfo = kinData:CheckInviter(me.dwID);

	if not tbInviterInfo or not tbInviterInfo.bPowerfulInvite then
		return Kin:Apply(nKinId);
	end

	local isProbation = Kin:CheckIsProbation(me.nLevel);
	if not kinData:Available2Join(isProbation) then
		return false, "目標幫派已經滿了";
	end

	local meMemberData = Kin:CreateMemberData(nKinId, me.dwID);
	local bSuccess = meMemberData:JoinKin(kinData);
	if not bSuccess then
		return false, "加入幫派失敗";
	end

	return true;
end

function Kin:KickOutMember(nTargetId)
	if me.dwKinId == 0 then
		return false, "沒有幫派";
	end

	if me.dwID == nTargetId then
		return false, "不能踢自己";
	end

	local meMemberData = Kin:GetMemberData(me.dwID);
	if not meMemberData then
		return false, "不在此幫派中"
	end
	if not meMemberData:CheckAuthority(Kin.Def.Authority_KickOut) then
		return false, "沒有許可權進行操作";
	end

	local targetMemberData = Kin:GetMemberData(nTargetId);
	if not targetMemberData or me.dwKinId ~= targetMemberData.nKinId then
		return false, "不在同一個幫派中哦";
	end

	if meMemberData.nCareer >= targetMemberData.nCareer then
		return false, "沒有許可權進行操作, 等級不比他高哦";
	end

	local kinData = Kin:GetKinById(me.dwKinId);
	if nTargetId==kinData.nCandidateLeaderId then
		return false, "候選總堂主不允許被踢出幫派"
	end
	if nTargetId==kinData.nLeaderId then
		return false, "總堂主不允許被踢出幫派"
	end

	kinData:DeleteMember(nTargetId);
	me.CenterMsg(string.format("成功將「%s」踢出幫派", targetMemberData:GetName()));

	local tbMail = {
		To = nTargetId;
		Title = "幫派信件";
		From = "幫派";
		Text = string.format("你被「%s」請出幫派", me.szName);
	};

	Mail:SendSystemMail(tbMail);
	Kin:SyncKinMemberInfo();
	Kin:UpdateJoinCD(nTargetId, true)
	return true;
end

-- 实习生转正
function Kin:PromoteMember(nTargetId)
	if me.dwKinId == 0 then
		return false, "沒有幫派";
	end

	local meMemberData = Kin:GetMemberData(me.dwID);
	if not meMemberData then
		return false, "不在此幫派中"
	end
	if not meMemberData:CheckAuthority(Kin.Def.Authority_Promotion) then
		return false, "沒有許可權進行操作";
	end

	local targetMemberData = Kin:GetMemberData(nTargetId);
	if not targetMemberData then
		return false, "不在此幫派中"
	end
	if targetMemberData.nKinId ~= me.dwKinId then
		return false, "不在同一個幫派中哦";
	end

	if targetMemberData.nCareer ~= Kin.Def.Career_New then
		return false, "他不是小弟";
	end

	local kinData = Kin:GetKinById(me.dwKinId);
	if kinData:GetMemberCount() >= kinData:GetMaxMemberCount() then
		return false, "無法轉正，正式成員已滿";
	end

	targetMemberData:SetCareer(Kin.Def.Career_Normal);
	me.CenterMsg("成功轉為正式成員")
	kinData:UpdateMemberInfoList()
	Kin:SyncKinMemberInfo()

	return true;
end

function Kin:Quite()
	if me.dwKinId == 0 then
		return false, "沒有幫派";
	end

	local kinData = Kin:GetKinById(me.dwKinId);
	if kinData.nMasterId == me.dwID then
		return false, "你可是堂主啊! 不能走~";
	end

	local memberData = Kin:GetMemberData(me.dwID);
	if not memberData then
		return false, "你沒有幫派";
	end

	if Kin.Def.tbManagerCareers[memberData.nCareer] then
		local tbMail = {
			To = kinData.nMasterId;
			Title = "幫派信件";
			From = "幫派";
			Text = string.format("%s「%s」離開了幫派。", Kin.Def.Career_Name[memberData.nCareer], me.szName);
		};

		Mail:SendSystemMail(tbMail);
	end

	kinData:DeleteMember(me.dwID);
	return true;
end

-- 检查见习成员条件
function Kin:CheckIsProbation(nPlayerLevel)
	local nInLevel = Kin:GetCareerNewLevels()
	return nPlayerLevel <= nInLevel
end

function Kin:SyncKins2Join(nPage)
	local tbKinsData = Kin:GetJoinKinsInfo();
	if not tbKinsData then
		return true;
	end

	nPage = nPage or 1;
	local nKinsPerPage = 7;
	local nMaxPage = math.ceil(#tbKinsData / nKinsPerPage);

	local tbSyncData = {};
	for i = (nPage - 1) * nKinsPerPage + 1, nPage * nKinsPerPage do
		if tbKinsData[i] then
			table.insert(tbSyncData, tbKinsData[i]);
		end
	end

	me.CallClientScript("Kin:OnSyncJoinInfo", tbSyncData, nPage, nMaxPage);
	return true;
end

function Kin:SyncKinBaseInfo(nBaseVersion, pPlayer)
	pPlayer = pPlayer or me;
	if pPlayer.dwKinId == 0 then
		return false, "沒有幫派";
	end

	local tbKinData = Kin:GetKinById(pPlayer.dwKinId);
	local tbBaseInfo, nBaseVersion = tbKinData:GetBaseInfo(nBaseVersion);
	if tbBaseInfo then
		pPlayer.CallClientScript("Kin:OnSyncBaseInfo", tbBaseInfo, nBaseVersion);
	end
	return true;
end

function Kin:SyncBuildingData(nVersion)
	if me.dwKinId == 0 then
		return false, "沒有幫派";
	end

	local tbKinData = Kin:GetKinById(me.dwKinId);
	local tbBuildingData, nBuildingVersion = tbKinData:GetAllBuildingData(nVersion);
	if tbBuildingData then
		me.CallClientScript("Kin:OnSyncBuildingData", tbBuildingData, nBuildingVersion);
	end

	return true;
end

function Kin:SyncKinMemberInfoForPlayer(pPlayer, nMemberListVersion)
	if pPlayer.dwKinId == 0 then
		return false, "沒有幫派";
	end

	KinMgr.SyncMemberState(pPlayer.dwID);

	local tbKinData = Kin:GetKinById(pPlayer.dwKinId);
	local tbMemberList, nMemberListVersion = tbKinData:GetMemberInfoList(nMemberListVersion);
	if tbMemberList then
		self:_TrySendMemberList(pPlayer, tbMemberList, nMemberListVersion)
	end

	return true;
end

function Kin:_TrySendMemberList(pPlayer, tbMemberList, nMemberListVersion)
	local nCount = #tbMemberList

	local nCountPerSlice = 50
	local tbList = {
		nExpectCount = nCount,
	}
	local nSliceCount = 0
	for nIdx, tbMember in ipairs(tbMemberList) do
		tbList[nIdx] = tbMember
		nSliceCount = nSliceCount+1
		if nSliceCount>=nCountPerSlice or nIdx>=nCount then
			local bSuccess = pPlayer.CallClientScript("Kin:OnSyncMemberListSlice", tbList, nMemberListVersion)
			if not bSuccess then
				local nSize, nCompressed = GetTableSize(tbList)
				Log(string.format("Kin:_TrySendMemberList slice failed: %s %s %s", #tbList, nSize, nCompressed))
				break
			end

			nSliceCount = 0
			tbList = {
				nExpectCount = nCount,
			}
		end
	end
end

function Kin:SyncKinMemberInfo(nMemberListVersion)
	return self:SyncKinMemberInfoForPlayer(me, nMemberListVersion)
end

function Kin:SyncApplyerList(nVersion, bManual)
	if me.dwKinId == 0 then
		return false, "沒有幫派";
	end

	local tbKinData = Kin:GetKinById(me.dwKinId);
	local tbApplyerList, nVersion = tbKinData:GetApplyerList(nVersion);
	if tbApplyerList then
		me.CallClientScript("Kin:OnSyncApplyerList", tbApplyerList, nVersion);
	end

	if bManual then
		me.CenterMsg("申請列表已刷新");
	end
	return true;
end

function Kin:SyncRecruiSetting(nVersion)
	if me.dwKinId == 0 then
		return false, "沒有幫派";
	end

	local tbKinData = Kin:GetKinById(me.dwKinId);
	local tbRecruitSetting, nVersion = tbKinData:GetRecruitSetting(nVersion);
	if tbRecruitSetting then
		me.CallClientScript("Kin:OnSyncRecruit",  tbRecruitSetting, nVersion);
	end
	return true;
end

function Kin:SetRecruitSetting(bAutoRecruitNewer, bConditionRecruit, nLimitLevel, tbFaction)
	if me.dwKinId == 0 then
		return false, "沒有幫派";
	end

	local meMemberData = Kin:GetMemberData(me.dwID);
	if not meMemberData then
		return false, "不在此幫派中"
	end
	if not meMemberData:CheckAuthority(Kin.Def.Authority_EditRecuitInfo) then
		return false, "沒有許可權進行招人設置";
	end

	local tbKinData = Kin:GetKinById(me.dwKinId);
	tbKinData:SetRecruitSetting(bAutoRecruitNewer, bConditionRecruit, nLimitLevel, tbFaction);
	Kin:SyncRecruiSetting();
	me.CenterMsg("修改招人設置成功");
	return true;
end

function Kin:_IsTitleLenValid(szTitle)
	local nLen = Lib:Utf8Len(szTitle)
	return nLen<=self.Def.nMaxKinTitleLen
end

function Kin:CheckTitleLen(tbSpecialTitle, tbCommonTitle, szLeaderTitle)
	local tbAllTitles = {}
	for _, szTitle in pairs(tbSpecialTitle) do
		table.insert(tbAllTitles, szTitle)
	end
	for _, szTitle in pairs(tbCommonTitle) do
		table.insert(tbAllTitles, szTitle)
	end
	table.insert(tbAllTitles, szLeaderTitle or "")

	for _, szTitle in ipairs(tbAllTitles) do
		if not self:_IsTitleLenValid(szTitle) then
			return false
		end
	end
	return true
end

function Kin:SetKinTitle(tbSpecialTitle, tbCommonTitle, szLeaderTitle)
	if me.dwKinId == 0 then
		return false, "沒有幫派";
	end

	local meMemberData = Kin:GetMemberData(me.dwID);
	if not meMemberData then
		return false, "不在此幫派中"
	end
	if not meMemberData:CheckAuthority(Kin.Def.Authority_EditKinTitle) then
		return false, "沒有許可權改頭銜";
	end

	if not self:CheckTitleLen(tbSpecialTitle, tbCommonTitle, szLeaderTitle) then
		return false, "自訂稱謂長度不合法"
	end

	for nMemberId, szTitle in pairs(tbSpecialTitle) do
		local memberData = Kin:GetMemberData(nMemberId);
		if memberData then
			memberData:SetKinTitle(szTitle);
		end
	end

	local kinData = Kin:GetKinById(me.dwKinId);
	kinData:SetKinTitle(tbCommonTitle[Kin.Def.Career_Elite], tbCommonTitle[Kin.Def.Career_Normal],
						 tbCommonTitle[Kin.Def.Career_New], tbCommonTitle[Kin.Def.Career_Retire], szLeaderTitle);

	Kin:SyncKinBaseInfo();
	Kin:SyncKinMemberInfo();

	me.CenterMsg("編輯稱謂完成");
	return true;
end

function Kin:_ChangeCareerCommonCheck(nTargetId, nCareer, nReplaceId)
	local nKinId = me.dwKinId
	if nKinId == 0 then
		return false, "沒有幫派"
	end

	local tbTarget = Kin:GetMemberData(nTargetId)
	if not tbTarget then
		return false, "找不到, 他真的存在嗎"
	end
	if tbTarget.nCareer==nCareer then
		return false, "職位與先前相同"
	end
	if tbTarget.nKinId~=nKinId then
		return false, "對方不在此幫派"
	end

	if nReplaceId and nReplaceId>0 then
		local tbReplace = Kin:GetMemberData(nReplaceId)
		if not tbReplace then
			return false, "被替換的人不存在"
		end
		if tbReplace.nCareer~=nCareer then
			return false, "被替換的人職位發生變化"
		end
		if tbReplace.nKinId~=nKinId then
			return false, "被替換的人不在此幫派"
		end
	end

	local tbKinData = Kin:GetKinById(me.dwKinId)
	local nCareerCountLimite = tbKinData:GetCareerMaxCount(nCareer);
	if not nReplaceId and nCareerCountLimite then
		if tbKinData:GetCareerMemberCount(nCareer) >= nCareerCountLimite then
			return false, "目標職位的人數已滿"
		end
	end
	return true
end

function Kin:_ChangeMasterCheck(nTargetId, nReplaceId)
	local tbKinData = Kin:GetKinById(me.dwKinId)
	if tbKinData.nLeaderId~=me.dwID and me.dwID==nTargetId then
		return false, "不可任命自己"
	end

	if nReplaceId and nReplaceId~=tbKinData:GetMasterId() then
		return false, "被替換的人不是堂主"
	end

	local tbMyData = Kin:GetMemberData(me.dwID)
	if not tbMyData then
		return false, "不在此幫派中"
	end
	if tbKinData.nLeaderId~=me.dwID and tbMyData.nCareer~=Kin.Def.Career_Master then
		return false, "你沒有許可權"
	end

	return true
end

function Kin:_ChangeOtherCheck(nTargetId, nCareer, nReplaceId)
	if me.dwID==nTargetId then
		return false, "不可任命自己"
	end

	local tbMyData = Kin:GetMemberData(me.dwID)
	local tbTarget = Kin:GetMemberData(nTargetId)
	if not tbMyData or not tbTarget then
		return false, "不在此幫派中"
	end
	local authority1 = Kin.Def.Career2Authority[nCareer];
	local authority2 = Kin.Def.Career2Authority[tbTarget.nCareer]
	if (not authority1 or not tbMyData:CheckAuthority(authority1)) or
		(not authority2 or not tbMyData:CheckAuthority(authority2)) then
		return false, tbTarget.nCareer==Kin.Def.Career_New and "小弟不能任職" or "沒有許可權進行操作"
	end

	if nReplaceId then
		local tbReplaceData = Kin:GetMemberData(nReplaceId);
		if not tbReplaceData then
			return false, "不在此幫派中"
		end
		local authority = Kin.Def.Career2Authority[tbReplaceData.nCareer];
		if not authority or not tbMyData:CheckAuthority(authority) then
			return false, "沒有許可權改變目標職位";
		end
	end

	return true
end

function Kin:ChangeCareer(nTargetId, nCareer, nReplaceId, bSilence)
	if nCareer==Kin.Def.Career_Mascot and Kin.Def.bMascotClosed then
		return false, "吉祥物暫未開放"
	end

	local bOk, szErr = self:_ChangeCareerCommonCheck(nTargetId, nCareer, nReplaceId)
	if not bOk then
		return false, szErr
	end

	if nCareer==Kin.Def.Career_Master then
		if not nReplaceId then
			local tbKinData = Kin:GetKinById(me.dwKinId)
			nReplaceId = tbKinData:GetMasterId()
		end
		bOk, szErr = self:_ChangeMasterCheck(nTargetId, nReplaceId)
		if not bOk then
			return false, szErr
		end
	else
		bOk, szErr = self:_ChangeOtherCheck(nTargetId, nCareer, nReplaceId)
		if not bOk then
			return false, szErr
		end
	end

	local tbTarget = Kin:GetMemberData(nTargetId)
	if not tbTarget then
		return false, "不在此幫派中"
	end
	if nReplaceId then
		local tbReplaceData = Kin:GetMemberData(nReplaceId)
		if tbReplaceData then
			tbTarget.tbAuthority = tbReplaceData.tbAuthority;
			tbReplaceData:SetCareer(Kin.Def.Career_Normal);
			tbReplaceData.tbAuthority = {};
		end
	end

	local nOldCareer = tbTarget.nCareer;
	tbTarget:SetCareer(nCareer);

	--默认允许副族长有踢人、升级建筑权限
	if nCareer==Kin.Def.Career_ViceMaster then
		tbTarget:SetAuthority({
			[Kin.Def.Authority_KickOut] = true,
			[Kin.Def.Authority_Building] = true,
		})
		local tbKinData = Kin:GetKinById(me.dwKinId)
		tbKinData:UpdateMemberInfoList()
	elseif nCareer==Kin.Def.Career_Elder or nCareer==Kin.Def.Career_Mascot then
		tbTarget:SetAuthority({})
	end

	if not bSilence then
		me.CenterMsg("職位任命成功");
		Kin:SyncKinMemberInfo();
	end

	if nCareer == Kin.Def.Career_Master then
		Kin:SyncKinBaseInfo();
	end

	if Kin.Def.tbManagerCareers[nCareer] and (nCareer<nOldCareer or nCareer==Kin.Def.Career_Mascot) then
		tbTarget:SendSetCareerMail(nCareer);

		local szInfo = string.format("「%s」被任命為%s", tbTarget:GetName(), Kin.Def.Career_Name[nCareer]);
		ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.Kin, szInfo, me.dwKinId);
	end

	--若对方在线，强制更新
	local pTarget = KPlayer.GetPlayerObjById(nTargetId)
	if pTarget then
		Kin:SyncKinMemberInfoForPlayer(pTarget)
	end
	if nReplaceId and nReplaceId~=me.dwID then
		local pReplaced = KPlayer.GetPlayerObjById(nReplaceId)
		if pReplaced then
			Kin:SyncKinMemberInfoForPlayer(pReplaced)
		end
	end

	local pTargetPlayer = KPlayer.GetPlayerObjById(nTargetId or 0)
	if pTargetPlayer then
		pTargetPlayer.CallClientScript("Kin:ChanePosition",nCareer,nOldCareer)
	end

	return true;
end

function Kin:CancelAppointLeader()
	local tbKin = self:GetKinById(me.dwKinId)
	if not tbKin then return end

	if me.dwID~=tbKin.nLeaderId then
		me.CenterMsg("只有總堂主才能取消任命")
		return
	end
	tbKin:CancelChangeLeader()
	Kin:SyncKinBaseInfo()
	me.CenterMsg("取消成功")
	me.CallClientScript("Kin:LeaderInfoChange")
end

function Kin:AppointLeader(nCandidateId)
	if nCandidateId==me.dwID then
		me.CenterMsg("不能任命自己")
		return
	end

	local tbKin = self:GetKinById(me.dwKinId)
	if not tbKin then return end

	local bOk, szErr = tbKin:AppointLeader(nCandidateId)
	if not bOk and szErr then
		me.CenterMsg(szErr)
		return
	end
	Kin:SyncKinBaseInfo()
	me.CenterMsg("任命成功")
	me.CallClientScript("Kin:LeaderInfoChange")
end

function Kin:ChangeCareers(nCareer, tbCancelMember, tbAppointMember)
	for _, nMemberId in pairs(tbCancelMember) do
		local bRet, szMsg = Kin:ChangeCareer(nMemberId, Kin.Def.Career_Normal, nil, true)
		if not bRet then
			return false, szMsg;
		end
	end

	for _, nMemberId in pairs(tbAppointMember) do
		local bRet, szMsg = Kin:ChangeCareer(nMemberId, nCareer, nil, true);
		if not bRet then
			return false, szMsg;
		end
	end

	me.CenterMsg("職位任命成功");
	Kin:SyncKinMemberInfo();
	return true;
end

function Kin:ChangeRetire(nTargetId, nCareer)
	if me.dwKinId == 0 then
		return false, "沒有幫派";
	end

	local meMemberData = Kin:GetMemberData(me.dwID);
	if not meMemberData then
		return false, "不在此幫派中"
	end
	if not meMemberData:CheckAuthority(Kin.Def.Authority_Retire) then
		return false, "可是, 你沒有許可權";
	end

	local targetMemberData = Kin:GetMemberData(nTargetId);
	if not targetMemberData then
		return false, "不在此幫派中"
	end
	if targetMemberData.nCareer == nCareer then
		return true;
	end

	local kinData = Kin:GetKinById(me.dwKinId);
	if nCareer == Kin.Def.Career_Normal then
		if kinData:GetMemberCount() >= kinData:GetMaxMemberCount() then
			return false, "正式成員滿了";
		end
		targetMemberData:SetCareer(nCareer);
	elseif nCareer == Kin.Def.Career_Retire then
		if kinData:GetRetireCount() >= kinData:GetMaxRetireCount() then
			return false, "退隱成員滿了";
		end
		targetMemberData:SetCareer(nCareer);
	else
		return false, "職位有問題! 此條不可能出現";
	end

	return true;
end

function Kin:ChangePublicDeclare(szPublicDeclare)
	if me.dwKinId == 0 then
		return false, "沒有幫派"
	end

	local meMemberData = Kin:GetMemberData(me.dwID);
	if not meMemberData then
		return false, "不在此幫派中"
	end
	if not meMemberData:CheckAuthority(Kin.Def.Authority_EditPubilcDeclare) then
		return false, "沒有許可權進行修改公告";
	end

	-- todo:检查公告长度什么的...

	local kinData = Kin:GetKinById(me.dwKinId);
	kinData:ChangePublicDeclare(szPublicDeclare);
	return true;
end

function Kin:CheckChangeKinCamp(pPlayer, nCamp)
	if Kin.Def.bForbidCamp then
		return false, "禁止操作";
	end

    if pPlayer.dwKinId <= 0 then
		return false, "沒有幫派";
	end

	local tbKinData = Kin:GetKinById(pPlayer.dwKinId);
	if not tbKinData then
		return false, "沒有幫派!";
	end

    local nKinCampCount = tbKinData:GetChangeCampCount();
    nKinCampCount = nKinCampCount + 1;
    local nNeedFound = Kin.Def.ChangeCampFound[nKinCampCount];
    if not nNeedFound then
    	return false, "改變陣營的次數不足";
    end

	if nNeedFound > tbKinData:GetFound() then
		return false, string.format("幫派資金不足%s", nNeedFound);
	end

	local bRet = Kin:CheckKinCamp(nCamp);
	if not bRet then
		return false, "請選擇陣營！"
	end

	if tbKinData:GetCamp() == nCamp then
		return false, "請選擇不同的陣營";
	end

	local tbMemberData = Kin:GetMemberData(pPlayer.dwID);
	if not tbMemberData then
		return false, "不在此幫派中"
	end
	if not tbMemberData:CheckAuthority(Kin.Def.Authority_ChangeCamp) then
		return false, "沒有許可權進行幫派陣營";
	end

	return true, "", nNeedFound;
end

function Kin:ChangeKinCamp(nCamp)
	if Kin.Def.bForbidCamp then
		nCamp = Npc.CampTypeDef.camp_type_player;
	end

    local bRet, szMsg, nNeedFound = Kin:CheckChangeKinCamp(me, nCamp);
    if not bRet then
    	return false, szMsg;
    end

    local tbKinData = Kin:GetKinById(me.dwKinId);
    local nKinCampCount = tbKinData:GetChangeCampCount();
	tbKinData.nKinCampCount = nKinCampCount + 1;
    tbKinData:CostFound(nNeedFound);
    tbKinData:ChangeCamp(nCamp);
    me.CenterMsg("修改幫派陣營成功！");
    Kin:SyncKinBaseInfo();
    me.CallClientScript("Ui:CloseWindow","FamilyCampPanel");
    return true;
end

function Kin:ChangeAddDeclare(szAddDeclare)
	if me.dwKinId == 0 then
		return false, "沒有幫派"
	end

	local meMemberData = Kin:GetMemberData(me.dwID);
	if not meMemberData then
		return false, "不在此幫派中"
	end
	if not meMemberData:CheckAuthority(Kin.Def.Authority_EditRecuitInfo) then
		return false, "沒有許可權進行修改幫派宣言";
	end

	local kinData = Kin:GetKinById(me.dwKinId);
	kinData:ChangeAddDeclare(szAddDeclare);
	me.CenterMsg("您修改了幫派宣言");
	return true;
end

function Kin:SyncKinCareer(nVersion)
	if me.dwKinId == 0 then
		return false, "沒有幫派"
	end

	local kinData = Kin:GetKinById(me.dwKinId);
	local tbMemberCareer, nVersion = kinData:GetMemberCareer(nVersion);
	if tbMemberCareer then
		me.CallClientScript("Kin:SetMemberCareer", tbMemberCareer, nVersion);
	end

	return true;
end

function Kin:ChatForbid(nTargetId, bIsCancel)
	if me.dwKinId == 0 then
		return false, "沒有幫派";
	end

	local tbMe = Kin:GetMemberData(me.dwID);
	if not tbMe then
		return false, "不在此幫派中"
	end
	if not tbMe:CheckAuthority(Kin.Def.Authority_ChatForbid) then
		return false, "沒有許可權進行禁言";
	end

	local tbTarget = Kin:GetMemberData(nTargetId);
	if not tbTarget then
		return false, "不在此幫派中"
	end

	local tbKin = self:GetKinById(me.dwKinId)
	local nTargetCareer = tbKin:GetLeaderId()==nTargetId and self.Def.Career_Leader or tbTarget.nCareer
	if self:CareerCmp(tbMe.nCareer, nTargetCareer)<=0 then
		return false, "你職位沒有比他高哦";
	end

	tbTarget:ChatForbid(bIsCancel);

	local szMsg = ""
	local szMsgOperator = ""
	if bIsCancel then
		szMsg = string.format("「%s」被解除了禁言", tbTarget:GetName());
		szMsgOperator = string.format("成功解除「%s」的禁言", tbTarget:GetName());
	else
		szMsg = string.format("「%s」被禁言2小時", tbTarget:GetName());
		szMsgOperator = string.format("成功對「%s」禁言2小時", tbTarget:GetName());
	end
	me.CenterMsg(szMsgOperator)
	ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.Kin, szMsg, me.dwKinId);
	Kin:SyncKinMemberInfo();
	return true;
end

function Kin:StartCombine(nDesKinId)
	if me.dwKinId == 0 then
		return false, "沒有幫派";
	end

	local meMemberData = Kin:GetMemberData(me.dwID);
	if not meMemberData then
		return false, "不在此幫派中"
	end
	if not meMemberData:CheckAuthority(Kin.Def.Authority_Combine) then
		return false, "沒有許可權進行操作";
	end

	local kinData = Kin:GetKinById(me.dwKinId);
	kinData:SetTargetCombineKin(nDesKinId);

	return true;
end

function Kin:AgreeCombine(nSrcKinId)
	if me.dwKinId == 0 then
		return false, "沒有幫派";
	end

	local meMemberData = Kin:GetMemberData(me.dwID);
	if not meMemberData then
		return false, "不在此幫派中"
	end
	if not meMemberData:CheckAuthority(Kin.Def.Authority_Combine) then
		return false, "沒有許可權進行操作";
	end

	local dstKinData = Kin:GetKinById(me.dwKinId);
	local srcKinData = Kin:GetKinById(nSrcKinId);

	if not dstKinData or not srcKinData then
		return false, "kin do not exist";
	end

	if not srcKinData:CheckCombineFlag(dstKinData.nKinId) then
		return false, "target do not agree";
	end

	if srcKinData:GetMemberCount() + dstKinData:GetMemberCount() > dstKinData:GetMaxMemberCount() then
		return false, "too many member to Combine";
	end

	if srcKinData:GetRetireCount() + dstKinData:GetRetireCount() > dstKinData:GetMaxRetireCount() then
		return false, "too many retire to Combine";
	end

	if srcKinData:GetNewerCount() + dstKinData:GetNewerCount() > dstKinData:GetMaxNewerCount() then
		return false, "too many newer to Combine";
	end

	dstKinData:Combine(srcKinData);

	-- todo: 合并后的通知或者什么??
	return true;
end

function Kin:SetAuthority(tbAuthorityData)
	if me.dwKinId == 0 then
		return false, "no kin";
	end

	local kinData = Kin:GetKinById(me.dwKinId);
	if kinData.nMasterId ~= me.dwID then
		return false, "沒有許可權進行操作";
	end

	for nMemberId, tbAuthority in pairs(tbAuthorityData) do
		local memberData = Kin:GetMemberData(nMemberId);
		if memberData then
			if memberData.nCareer ~= Kin.Def.Career_ViceMaster then
				return false, "only vice Master can be authored";
			end
			memberData:SetAuthority(tbAuthority);
		end
	end

	if next(tbAuthorityData) then
		kinData:UpdateMemberInfoList();
	end

	--若对方在线，强制更新
	for nMemberId in pairs(tbAuthorityData) do
		local pPlayer = KPlayer.GetPlayerObjById(nMemberId)
		if pPlayer then
			Kin:SyncKinMemberInfoForPlayer(pPlayer)
		end
	end

	me.CenterMsg("修改許可權成功");
	return true;
end

function Kin:BuildingUpgrade(nBuildingId)
	if me.dwKinId == 0 then
		return false, "no kin";
	end

	local memberData = Kin:GetMemberData(me.dwID);
	if not memberData then
		return false, "不在此幫派中"
	end
	if not memberData:CheckAuthority(Kin.Def.Authority_Building) then
		return false, "沒有許可權升級幫派建築";
	end

	local kinData = Kin:GetKinById(me.dwKinId);
	local tbBuildingData = kinData:GetBuildingData(nBuildingId);
	local nNextLevel = tbBuildingData.nLevel + 1;
	local nMaxLevel = kinData:GetBuildingOpenLevel(nBuildingId);
	if nNextLevel > nMaxLevel then
		return false, "幫派建築等級達到上限, 不可升級";
	end

	local nUpgradeCost = Kin:GetBuildingUpgradeCost(nBuildingId, nNextLevel);
	if not kinData:CostFound(nUpgradeCost) then
		return false, "金錢不足";
	end

	local nLevelLimit = Kin:GetBuildingLimitLevel(nBuildingId);
	if nLevelLimit > kinData:GetLevel() then
		return false, "幫派等級限制上限";
	end

	local bRet, szReason = kinData:BuildingLevelUp(nBuildingId);
	if not bRet then
		return false, szReason;
	end

	Kin:SyncKinBaseInfo();
	Kin:SyncBuildingData();

	local szInfo = string.format("在幫派成員的共同努力下，[FFFE0D]%s[-] 等級提升至 [FFFE0D]%s級[-]。各位成員要繼續努力，壯大幫派！", Kin.Def.BuildingName[nBuildingId], nNextLevel);
	ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.Kin, szInfo, me.dwKinId);

	return true;
end

function Kin:Donate(nCurDegree, nCount)
	if nCount<=0 then
		return false, "請選擇捐獻次數"
	end

	if nCurDegree ~= DegreeCtrl:GetDegree(me, "DonationCount") then
		DegreeCtrl:AddDegree(me, "DonationCount", 0) -- add 0 to force sync
		return false
	end

	if me.dwKinId == 0 then
		return false, "no kin";
	end

	local nCurGold = me.GetMoney("Gold");
	local nCurDegree = DegreeCtrl:GetDegree(me, "DonationCount");
	if not nCurDegree or nCurDegree < nCount then
		return false, "捐獻次數用完";
	end

	local nCostedCount = DegreeCtrl:GetMaxDegree("DonationCount", me) - nCurDegree;
	local nDonateCost = Kin:GetDonationsCost(nCostedCount + 1, nCostedCount + nCount);
	if nCurGold < nDonateCost then
		return false, "金錢不足";
	end

	local kinData = Kin:GetKinById(me.dwKinId);
	local nFound2Add = Kin:GetDonationsFound(nCostedCount + 1, nCostedCount + nCount)
	local nMaxFound = kinData:GetMaxFound();
	if (nFound2Add + kinData:GetFound()) > nMaxFound then
		return false, "幫派建設資金達到上限, 不可捐獻";
	end

	-- CostGold谨慎调用, 调用前请搜索 _LuaPlayer.CostGold 查看使用说明, 它处调用时请保留本注释
	me.CostGold(nDonateCost, Env.LogWay_KinDonate, nil, function (nPlayerId, bSuccess)
		if not bSuccess then
			return false;
		end

		local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
		if not pPlayer then
			return false, "捐獻過程中您下線了";
		end

		if not DegreeCtrl:ReduceDegree(pPlayer, "DonationCount", nCount) then
			return false, "捐獻次數用完";
		end

		local kinData = Kin:GetKinById(pPlayer.dwKinId);
		if kinData then
			nFound2Add = kinData:AddFound(nPlayerId, nFound2Add);
			kinData:SaveDonationRecord(pPlayer.szName, nFound2Add, nCount);
		end

		local nContribut = nCount * Kin.Def.nDonate2ContribPerTime;
		local fVipInc = Kin:GetVipDonateContributeInc(pPlayer.GetVipLevel())
		nContribut = math.ceil(nContribut*(1+fVipInc))
		pPlayer.AddMoney("Contrib", nContribut, Env.LogWay_KinDonate);

		local memberData = Kin:GetMemberData(pPlayer.dwID);
		if memberData then
			memberData:RecordKinFound(nFound2Add);
		end

		EverydayTarget:AddCount(pPlayer, "KinDonate", nCount);

		GameSetting:SetGlobalObj(pPlayer);
		Kin:SyncKinBaseInfo();
		Kin:SyncDonationRecord();
		GameSetting:RestoreGlobalObj();
		Activity:OnPlayerEvent(pPlayer, "Act_KinDonate", DegreeCtrl:GetMaxDegree("DonationCount", pPlayer), DegreeCtrl:GetDegree(pPlayer, "DonationCount"), nCount)
		pPlayer.CenterMsg(string.format("成功捐獻%d次", nCount));

		self:CheckDonateNotice(pPlayer)

		Achievement:AddCount(pPlayer, "FamilyContribute_1", nCount);
		TeacherStudent:TargetAddCount(pPlayer, "KinDonate", nCount)
		pPlayer.TLog("KinMemberFlow", pPlayer.dwKinId, Env.LogWay_KinDonate, nCount, nContribut);
		return true;
	end);

	return true;
end

function Kin:CheckDonateNotice(pPlayer)
	self.tbDonateNoticed = self.tbDonateNoticed or {}
	local nPlayerId = pPlayer.dwID
	local tbData = self.tbDonateNoticed[nPlayerId] or {
		nTime = 0,
		nMultiply = 0,
	}
	local nNow = GetTime()
	if Lib:IsDiffDay(4*3600, tbData.nTime, nNow) then
		tbData.nMultiply = 0
	end

	local nMax = DegreeCtrl:GetMaxDegree("DonationCount", pPlayer)
	local nLeft = DegreeCtrl:GetDegree(pPlayer, "DonationCount")
	local nMultiply = math.floor((nMax-nLeft)/self.Def.nDonateNoticeMin)
	if nMultiply>tbData.nMultiply then
		tbData.nTime = nNow
		tbData.nMultiply = nMultiply
		self.tbDonateNoticed[nPlayerId] = tbData
		local szName = pPlayer.szName
		local szMsg = string.format("玩家「%s」今日為幫派金庫捐獻達到%d次，為幫派的發展做出了卓越的貢獻。", szName, self.Def.nDonateNoticeMin*nMultiply)
		ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.Kin, szMsg, pPlayer.dwKinId)
	end
end

function Kin:GoKinMap(pPlayer)
	if not pPlayer then
		pPlayer = me;
	end

	if pPlayer.dwKinId == 0 then
		return false, "你沒有幫派";
	end

	if not Env:CheckSystemSwitch(pPlayer, Env.SW_SwitchMap) then
        return false, "目前狀態不允許切換地圖"
    end

	local kinData = Kin:GetKinById(pPlayer.dwKinId);
	return kinData:GoMap(pPlayer.dwID);
end

function Kin:BuyGiftBox()
	if me.dwKinId == 0 then
		return false, "no kin";
	end

	local memberData = Kin:GetMemberData(me.dwID);
	if not memberData then
		return false, "不在此幫派中"
	end

	local nContribut = me.GetMoney("Contrib");
	if nContribut < Kin.Def.nGiftBoxCost then
		return false, "領取失敗，貢獻不足";
	end

	if not memberData:CostMemberGiftBoxTime(me) then
		return false, "購買次數不足或冷卻時間未到";
	end

	local bRet = me.CostMoney("Contrib", Kin.Def.nGiftBoxCost, Env.LogWay_KinBuyGiftBox);
	if not bRet then
		return false, "扣錢失敗, 未知錯誤";
	end

	local kinData = Kin:GetKinById(me.dwKinId);
	local nTreaserBuildingLevel = kinData:GetBuildingLevel(Kin.Def.Building_Treasure);
	local nPriceItemId = assert(Kin.Def.GiftBoxItemIdByLevel[nTreaserBuildingLevel]);

	me.SendAward({{"item", nPriceItemId, 1}}, false, false, Env.LogWay_KinBuyGiftBox);
	me.CenterMsg("成功兌換一個幫派禮盒。");
	Achievement:AddCount(me, "Family_3");
	EverydayTarget:AddCount(me, "KinGiftBox", 1);
	TeacherStudent:TargetAddCount(me, "BuyKinGift", 1)

	me.CallClientScript("Kin:OnUpdateGiftBoxData");
	me.TLog("KinMemberFlow", me.dwKinId, Env.LogWay_KinBuyGiftBox, nTreaserBuildingLevel, nPriceItemId)
	return true;
end

--直接购买家族礼盒
function Kin:BuyGiftBoxImmediate(pPlayer, nLogWay)
	if pPlayer.dwKinId == 0 then
		return false, "沒有幫派"
	end

	local nContribut = pPlayer.GetMoney("Contrib")
	if nContribut < Kin.Def.nGiftBoxCost then
		return false, "購買失敗，貢獻不足"
	end

	local bRet = pPlayer.CostMoney("Contrib", Kin.Def.nGiftBoxCost, nLogWay)
	if not bRet then
		return false, "扣錢失敗, 未知錯誤"
	end

		local kinData = Kin:GetKinById(pPlayer.dwKinId)
	local nTreaserBuildingLevel = kinData:GetBuildingLevel(Kin.Def.Building_Treasure)
	local nPriceItemId = assert(Kin.Def.GiftBoxItemIdByLevel[nTreaserBuildingLevel])

	pPlayer.SendAward({{"item", nPriceItemId, 1}}, false, false, nLogWay)
	pPlayer.CenterMsg("成功購買一個幫派禮盒。")
	return true
end

function Kin:SyncMailCount(nCount)
	if me.dwKinId == 0 then
		return false, "沒有幫派";
	end

	local kinData = Kin:GetKinById(me.dwKinId);
	local nLeftMailCount = kinData:GetLeftMailCount();
	if nCount ~= nLeftMailCount then
		me.CallClientScript("Kin:OnSyncMailCount", nLeftMailCount);
	end
	return true;
end

function Kin:SendKinMail(szMail, bSendPhoneNotify)
	if me.dwKinId == 0 then
		return false, "沒有幫派";
	end

	local memberData = Kin:GetMemberData(me.dwID);
	if not memberData then
		return false, "不在此幫派中"
	end
	if not memberData:CheckAuthority(Kin.Def.Authority_Mail) then
		return false, "沒有許可權發送信件";
	end

	local kinData = Kin:GetKinById(me.dwKinId);
	local nLeftMailCount = kinData:GetLeftMailCount();
	if nLeftMailCount <= 0 then
		return false, "今日發送信件次數已用盡";
	end

	local nSendMailFee = kinData:GetTotalMemberCount() * Kin.Def.nSendMailFeeRate;
	if not kinData:CostFound(nSendMailFee) then
		return false, "幫派建設資金不足以發送信件";
	end

	kinData:ReduceLeftMailCount();

	local tbMail = {
		KinId = me.dwKinId;
		Text = szMail;
		From = me.szName;
	};

	Mail:SendKinMail(tbMail);
	local _,_,_, nAreaId = GetWorldConfifParam()
	szMail = string.gsub(szMail, "[,||]", "");
	me.TLog("SecTalkFlow", nAreaId, me.nFaction, me.szName, me.nLevel, me.GetFightPower(), me.szIP, 0,0,0,0,0,0,0,ChatMgr.nChannelMail, 0, szMail, 0);

	if bSendPhoneNotify then
		Sdk:SendXinGeNotifycation(me, szMail)
	end

	return true;
end

function Kin:AskAllMemberFriend()
	if me.dwKinId == 0 then
		return false, "沒有幫派";
	end

	local kinData = Kin:GetKinById(me.dwKinId);
	if not kinData then
		return false, "無法找到幫派";
	end

	kinData:TraverseMembers(function (memberData)
		if memberData.nMemberId ~= me.dwID then
			FriendShip:RequestAddFriend(me.dwID, memberData.nMemberId);
		end
		return true;
	end);

	me.CenterMsg("向所有成員發送好友邀請成功");
	return true;
end

function Kin:SyncDonationRecord(nVersion)
	if me.dwKinId == 0 then
		return false, "沒有幫派";
	end

	local kinData = Kin:GetKinById(me.dwKinId);
	if not kinData then
		return false, "無法找到幫派";
	end

	local tbRecord, nVersion = kinData:GetDonationRecord(nVersion);
	if tbRecord then
		me.CallClientScript("Kin:OnSyncDonationRecord", tbRecord, nVersion);
	end
	return true;
end

function Kin:CheckRobberCanOpen()
	local tbData = Kin.KinNest:GetKinNestData(me.dwKinId);
	if tbData then
		if tbData.nActivateData == Lib:GetLocalDay() then
			me.CallClientScript("Kin:AcceptCheckRobberCanOpen", false);
		else
			me.CallClientScript("Kin:AcceptCheckRobberCanOpen", true);
		end
	end

	return true;
end

function Kin:UpdateGroupInfo()
	if me.dwKinId == 0 then
		return false, "沒有幫派";
	end

	local kinData = Kin:GetKinById(me.dwKinId);
	if not kinData then
		return false, "無法找到幫派";
	end

	local nNow = GetTime();
	if me.nUpdateQQGroupTime == nNow then
		return false, "請求群資訊過於頻繁";
	end
	me.nUpdateQQGroupTime = nNow;

	AssistClient:UpdateGroupInfo(me, me.dwKinId, kinData:GetOrgServerId());
	return true;
end

function Kin:Ask4JoinQQGroup(bDirectJoin)
	if me.dwKinId == 0 then
		return false, "沒有幫派";
	end

	local kinData = Kin:GetKinById(me.dwKinId);
	if not kinData then
		return false, "您沒有幫派";
	end

	local szGroupOpenId = kinData:GetGroupOpenId();
	if not szGroupOpenId then
		return false, "您的幫派沒有綁定群";
	end

	if bDirectJoin then
		return AssistClient:JoinQQGroup(me, kinData);
	end

	return AssistClient:AskGroupJoinKey(me, szGroupOpenId);
end

function Kin:UnbindQQGroup()
	if me.dwKinId == 0 then
		return false, "沒有幫派";
	end

	local kinData = Kin:GetKinById(me.dwKinId);
	if not kinData then
		return false, "您沒有幫派";
	end

	local szGroupOpenId = kinData:GetGroupOpenId();
	if not szGroupOpenId then
		return false, "您的幫派沒有綁定群";
	end

	return AssistClient:UnbindQQGroup(me, szGroupOpenId, me.dwKinId);
end

function Kin:SendQQGroupInvitation()
	local kinData = Kin:GetKinById(me.dwKinId);
	if not kinData then
		return false, "您沒有幫派";
	end

	local memberData = Kin:GetMemberData(me.dwID);
	if not memberData or not memberData:CheckAuthority(Kin.Def.Authority_Recruit) then
		return false, "沒有許可權進行操作";
	end

	local szGroupOpenId = kinData:GetGroupOpenId();
	if not szGroupOpenId then
		return false, "您的幫派沒有綁定群";
	end

	return AssistClient:SendQQGroupInvitation(me, szGroupOpenId);
end

local KinInterface = {
	Create              = true;
	SyncKins2Join       = true;
	SyncKinBaseInfo     = true;
	SyncApplyerList     = true;
	SyncKinMemberInfo   = true;
	SyncDonationData    = true;
	SyncMailCount       = true;
	Apply               = true;
	ApplyPlayer         = true;
	AgreeApply          = true;
	DisagreeApply       = true;
	KickOutMember       = true;
	Quite               = true;
	PromoteMember       = true;
	SyncRecruiSetting   = true;
	SetRecruitSetting   = true;
	SetKinTitle         = true;
	ChangeCareer        = true;
	ChangeCareers       = true;
	AppointLeader		= true;
	CancelAppointLeader = true;
	CleanApplyerList    = true;
	ChangePublicDeclare = true;
	ChangeAddDeclare    = true;
	SyncKinCareer       = true;
	ChatForbid          = true;
	SetAuthority        = true;
	Invite              = true;
	SyncBuildingData    = true;
	BuildingUpgrade     = true;
	Donate              = true;
	AgreeInvite         = true;
	BuyGiftBox          = true;
	SendKinMail         = true;
	AskAllMemberFriend  = true;
	SyncDonationRecord  = true;
	CheckRobberCanOpen  = true;
	ChangeKinCamp       = true;
	UpdateGroupInfo		= true;
	Ask4JoinQQGroup		= true;
	UnbindQQGroup		= true;
	EscortFinishInfoReq	= true;
	OpenSrvMyKinRankReq = true;
	ChangeName			= true;
	SyncMascotOpenStatus = true;
	SendQQGroupInvitation = true;
}

function Kin:ClientRequest(szRequestType, ... )
	if KinInterface[szRequestType] then
		local bSuccess, szInfo = Kin[szRequestType](Kin, ...);
		if not bSuccess and szInfo then
			me.CenterMsg(szInfo);
		end
	else
		Log("WRONG Kin Request:", szRequestType, ...);
	end
end

function Kin:CheckLeaderOn()
	for _,tbKinData in pairs(Kin.KinData) do
		tbKinData:CheckLeaderOn()
	end
end

function Kin:CheckLeaderOff()
	for _,tbKinData in pairs(Kin.KinData) do
		tbKinData:CheckLeaderOff()
	end
end

function Kin:OnCreateChatRoom(dwKinId, uRoomHighId, uRoomLowId)
	local bNeedClose = true;

	-- 如果回调中有一个地方在用实时语音那就不用关闭
	if Kin.Gather:OnCreateChatRoom(dwKinId, uRoomHighId, uRoomLowId) and bNeedClose then
		bNeedClose = false;
	end

	if Fuben.KinTrainMgr:OnCreateChatRoom(dwKinId, uRoomHighId, uRoomLowId) and bNeedClose then
		bNeedClose = false;
	end

	if KinBattle:OnCreateChatRoom(dwKinId, uRoomHighId, uRoomLowId) and bNeedClose then
		bNeedClose = false;
	end

	if DomainBattle:OnCreateChatRoom(dwKinId, uRoomHighId, uRoomLowId) and bNeedClose then
		bNeedClose = false;
	end

	if bNeedClose then
		ChatMgr:CloseChatRoom(uRoomHighId, uRoomLowId);
	end
end

function Kin:JoinChatRoom(pPlayer)
	if not ChatMgr:IsKinHaveChatRoom(pPlayer.dwKinId) then
		return
	end

	local nPrivilege = ChatMgr.RoomPrivilege.emAudience;

	local memberData = Kin:GetMemberData(pPlayer.dwID);
	if memberData and (memberData.nCareer == Kin.Def.Career_Master or memberData.nCareer == Kin.Def.Career_ViceMaster) then
		nPrivilege = ChatMgr.RoomPrivilege.emSpeaker;
	end

	ChatMgr:JoinChatRoom(pPlayer, nPrivilege)
end

function Kin:EscortFinishInfoReq()
	local nKinId = me.dwKinId
	local tbKinData = self:GetKinById(nKinId)
	if not tbKinData then return end

	local tbEscortData = KinEscort:GetKinEscortData(nKinId)
	local nLastEscortDate = tbKinData:GetLastKinEscortDate()
	local bFinished = nLastEscortDate==Lib:GetLocalDay() and tbEscortData.nState==KinEscort.States.beforeAfter
	me.CallClientScript("Kin:EscortFinishInfoRsp", nLastEscortDate, bFinished)
end

function Kin:_ActivityDailyUpdate()
	Kin:TraverseKin(function(kinData)
		kinData:CorrectWeekActive()
	end)
end

function Kin:_GetActivitySetting(nActiveAvg)
	for nIdx,tb in ipairs(self.tbActivitySettings) do
		if nActiveAvg<=tb.nWeekAvg then
			return Lib:CopyTB(tb), nIdx
		end
	end
end

function Kin:_GetSalary(nCareer, nKinActive, nMyActiveAvg)
	nMyActiveAvg = math.max(0, math.min(100, nMyActiveAvg))
	local nBase = nKinActive/100*Kin.tbActivityCareerSalary[nCareer]
	return math.floor(nBase*nMyActiveAvg/100)
end

function Kin:_GetProfit(nCareer, nKinTotalCharge, nMyActiveAvg)
	if not nKinTotalCharge or nKinTotalCharge<=0 then
		return 0
	end

	local nCareerRate = Kin.Def.tbCareerProfitRate[nCareer]
	if not nCareerRate then
		return 0
	end

	local tbRateLevels = {}
	local nTotalCharge = nKinTotalCharge
	for nLevel, tbRateInfo in ipairs(Kin.Def.tbProfitRate) do
		local nMin = tbRateInfo[1]
		if nTotalCharge>=nMin then
			tbRateLevels[nLevel] = nTotalCharge-nMin
			nTotalCharge = nMin
		end
	end

	local nGold = 0
	for nLevel, nLevelGold in pairs(tbRateLevels) do
		local nRate = Kin.Def.tbProfitRate[nLevel][2]
		nGold = nGold+nRate*nLevelGold
	end

	return math.floor(nGold*nCareerRate*nMyActiveAvg/100)
end

function Kin:_Dismiss(nKinId)
	local tbData = Kin:GetKinById(nKinId)
	Mail:SendKinMail({
		KinId = nKinId,
		Text = string.format("    諸位俠士，吾乃武林盟主獨孤劍，由於爾等的幫派活躍連續兩周被評價為【%s】，已由吾親手自武林中除名。吾心甚痛，江湖險惡，孤身行走定當寸步難行，良禽擇木而棲，還望諸位弟兄早日加入新幫派，一展胸中抱負！",
			tbData.szLastJudge or ""),
		From = "獨孤劍",
	})

	tbData:DisbandImmediately()
end

function Kin:_SendBeginDismiss(nKinId)
	local tbData = Kin:GetKinById(nKinId)
	local nKinActive = tbData:GetWeekActive()
	local nActiveAvg = tbData:GetActivityAvg()
	local tbSetting = self:_GetActivitySetting(nActiveAvg)
	local szText = string.format("    諸位俠士，吾乃武林盟主獨孤劍，由於爾等的幫派上周活躍評價為【%s】，現進入為期一周的考核期，若本周幫派活躍評價仍然為【%s】，下週一4點，吾將親手將爾等幫派解散，諸位俠士若是心有不甘，則需努力達成活躍。",
					tbSetting.szJudgement, tbSetting.szJudgement)

	Mail:SendKinMail({
		KinId = nKinId,
		Text = szText,
		From = "獨孤劍",
	})
end

function Kin:_SendEndDismissMail(nKinId)
	Mail:SendKinMail({
		KinId = nKinId,
		Text = "    恭喜諸位俠士！吾乃武林盟主獨孤劍，在諸位的努力之下，爾等幫派上周活躍評價已達標，成功通過考核，還望諸位莫要鬆懈。",
		From = "獨孤劍",
	})
end

function Kin:_ShouldKeepSalary(nKinId)
	local tbKin = Kin:GetKinById(nKinId)
	if not tbKin then
		return false
	end

	local nCreateTime = tbKin.nCreateTime
	return (GetTime()-nCreateTime) < Kin.Def.nSalaryCreateMinHours*3600
end

function Kin:_KeepSalary(tbKinData)
	for nCareer in pairs(Kin.tbActivityCareerSalary) do
		local tbIds = tbKinData:GetCareerMemberIds(nCareer)
		for _,nId in ipairs(tbIds) do
			Mail:SendSystemMail({
		        To = nId,
		        Title = "幫派薪水",
		        Text = "    由於幫派創建時間未滿24小時，上周薪水將累積至下週一4:00結算時發放。",
		        From = "幫派總管",
		        tbAttach = {},
		    })
		end
	end
end

function Kin:_SalarySendRedBag(nKinId, nPlayerId, nCareer, nTotalGold)
	local tbCfg = Kin.Def.tbSalaryRedBagCfgs[nCareer]
	if not tbCfg then
		return
	end

	local nEventId = 0
	for _, tb in ipairs(tbCfg) do
		local nMin = tb[1]
		if nTotalGold>=nMin then
			nEventId = tb[2]
			break
		end
	end
	if nEventId<=0 then
		return
	end

	Kin:RedBagGainBySalaryWithoutCheck(nKinId, nPlayerId, nEventId)
	Log("_SalarySendRedBag", nKinId, nPlayerId, nCareer, nTotalGold)
end

function Kin:_SendSalary(tbKinData)
	local nKinActive = tbKinData:GetWeekActive()
	local nActiveAvg = tbKinData:GetActivityAvg()
	local tbSetting = self:_GetActivitySetting(nActiveAvg)

	local nDisplayKinActive = nKinActive
	local nDisplayActiveAvg = nActiveAvg
	if tbSetting.nDismiss>0 then
		local nChargeActive, nChargeActiveAvg = tbKinData:GetChargeActiveInfo()
		nDisplayKinActive = nDisplayKinActive+nChargeActive
		nDisplayActiveAvg = nDisplayActiveAvg+nChargeActiveAvg

		local tbSettingCharge = self:_GetActivitySetting(nDisplayActiveAvg)
		tbSetting.szJudgement = tbSettingCharge.szJudgement

		Log("Kin:_SendSalary charge", tbKinData.nKinId, tbSetting.szJudgement, nChargeActive, nChargeActiveAvg, nKinActive, nActiveAvg, tbKinData.nTotalCharge or 0)
	end

	local nNow = GetTime()
	for nCareer in pairs(Kin.tbActivityCareerSalary) do
		local tbIds = tbKinData:GetCareerMemberIds(nCareer)
		for _,nId in ipairs(tbIds) do
			local tbMember = self:GetMemberData(nId)
			if tbMember then
				local nMyActiveAvg = tbMember:GetActivityAvg()
				local nSalary = tbSetting.nHasSalary>0 and self:_GetSalary(nCareer, nKinActive, nMyActiveAvg) or 0
				local nProfit = Kin:_GetProfit(nCareer, tbKinData.nTotalCharge, nMyActiveAvg)
				local nTotalGold = nSalary+nProfit
				local szAdditional = ""
				if (nNow-tbMember.nCareerTime) < Kin.Def.nSalaryCareerMinHours*3600 then
					nTotalGold = 0
					szAdditional = "[FFFE0D]（任職未滿24小時無薪水）[-]"
				end
			
				-- 越南倒元宝惩罚机制
				if version_vn and nTotalGold>0 and Player:GetRewardValueDebt(nId)>0 then
					local nReduce = math.ceil(nTotalGold*0.3)
					if nReduce>0 then
						nTotalGold = nTotalGold-nReduce
						Player:CostRewardValueDebt(nId, nReduce, Env.LogWay_KinSalaryProfit)
						Log("Kin:_SendSalary vn_debt", tbKinData.nKinId, nTotalGold+nReduce, nReduce, Player:GetRewardValueDebt(nId))
					end
				end

				local szMailContent = string.format([[幫派上周活躍：%d\n上周日均活躍：%d\n我的日均活躍：%d\n幫派上周評價：%s\n我的上周工資：%d#999%s

【活躍規則說明】
活躍：[FFFE0D]日均活躍≥3000[-]較多工資
不夠活躍：[FFFE0D]3000>日均活躍≥1000[-]較少或無工資
非常不活躍：[FFFE0D]日均活躍<1000[-]持續兩周幫派將會被解散，新建幫派第一周爲保護期
[FFFE0D]注：個人日均活躍、幫派職位影響最終獲得的工資[-]\n]],
					nDisplayKinActive, nDisplayActiveAvg, nMyActiveAvg, tbSetting.szJudgement, nTotalGold , szAdditional)

				local tbSalary = nTotalGold>0 and {"Gold", nTotalGold} or nil
				Mail:SendSystemMail({
			        To = nId,
			        Title = "幫派薪水",
			        Text = szMailContent,
			        From = "幫派總管",
			        tbAttach = {
			        	tbSalary,
			        },
			        nLogReazon = Env.LogWay_KinSalaryProfit,
			    })

				self:_SalarySendRedBag(tbKinData.nKinId, nId, nCareer, nTotalGold)
			    Log("Kin:_SendSalary", tbKinData.nKinId, nKinActive, nId, nCareer, nMyActiveAvg, nTotalGold, nSalary, nProfit)
			end
		end
	end
end

function Kin:_Judge(tbKinData)
	if not tbKinData:CanJudgeWeeklyActivity() then
		return
	end

	local nKinActive = tbKinData:GetWeekActive()
	local nActiveAvg = tbKinData:GetActivityAvg()
	local tbSetting = self:_GetActivitySetting(nActiveAvg)

	if tbSetting.nDismiss>0 then
		local nChargeActive, nChargeActiveAvg = tbKinData:GetChargeActiveInfo()
		nKinActive = nKinActive+nChargeActive
		nActiveAvg = nActiveAvg+nChargeActiveAvg
		tbSetting = self:_GetActivitySetting(nActiveAvg)
		if tbSetting.nDismiss<=0 then
			Log("Kin:_Judge stop dismiss", tbKinData.nKinId, nChargeActive, nChargeActiveAvg, nKinActive, nActiveAvg, tbKinData.nTotalCharge or 0)
		end
	end

	local bDismissing = tbKinData.szLastJudge and tbKinData.szLastJudge~=""
	if bDismissing then
		if tbSetting.nDismiss<=0 then
			self:_SendEndDismissMail(tbKinData.nKinId)
			tbKinData.szLastJudge = nil
		end
	else
		if tbSetting.nDismiss>0 then
			self:_SendBeginDismiss(tbKinData.nKinId)
			tbKinData.szLastJudge = tbSetting.szJudgement
		end
	end
	if bDismissing and tbSetting.nDismiss>0 then
		Kin:_Dismiss(tbKinData.nKinId)
		Log("Kin:_Judge _Dismiss", tbKinData.nKinId, tbKinData.szLastJudge, tbSetting.szJudgement, nKinActive, nActiveAvg, tbKinData.nTotalCharge or 0)
	end
end

function Kin:_ActivityWeeklyJudge()
	Kin:TraverseKin(function(tbKinData)
		local bKeepSalary = self:_ShouldKeepSalary(tbKinData.nKinId)
		if bKeepSalary then
			self:_KeepSalary(tbKinData)
			return
		end

		self:_SendSalary(tbKinData)
		self:_Judge(tbKinData)
	end)
end

function Kin:_ActivityWeeklyReset()
	Kin:TraverseKin(function(tbKinData)
		tbKinData:ResetWeekActive()
		tbKinData:ResetWeekChargeProfit()
	end)
end

function Kin:_ActivityDailyReset()
	Kin:TraverseKin(function(tbKinData)
		tbKinData:ResetMemberDailyActive()
	end)
end

function Kin:_ActivityDailyReport()
	Kin:TraverseKin(function(tbKinData)
		local nKinActive = tbKinData:GetWeekActive()
		local nActiveAvg = tbKinData:GetActivityAvg()
		local tbSetting = self:_GetActivitySetting(nActiveAvg)

		local nDisplayKinActive = nKinActive
		local nDisplayActiveAvg = nActiveAvg
		if tbSetting.nDismiss>0 then
			local nChargeActive, nChargeActiveAvg = tbKinData:GetChargeActiveInfo()
			nDisplayKinActive = nDisplayKinActive+nChargeActive
			nDisplayActiveAvg = nDisplayActiveAvg+nChargeActiveAvg

			local tbSettingCharge = self:_GetActivitySetting(nDisplayActiveAvg)
			tbSetting.szJudgement = tbSettingCharge.szJudgement

			Log("Kin:_ActivityDailyReport charge", tbKinData.nKinId, tbSetting.szJudgement, nChargeActive, nChargeActiveAvg, nKinActive, nActiveAvg, tbKinData.nTotalCharge or 0)
		end

		for nCareer in pairs(Kin.tbActivityCareerSalary) do
			local tbIds = tbKinData:GetCareerMemberIds(nCareer)
			for _,nId in ipairs(tbIds) do
				local tbMember = self:GetMemberData(nId)
				if tbMember then
					local nMyActiveAvg = tbMember:GetActivityAvg()
					local nSalary = tbSetting.nHasSalary>0 and self:_GetSalary(nCareer, nKinActive, nMyActiveAvg) or 0
					local nProfit = self:_GetProfit(nCareer, tbKinData.nTotalCharge, nMyActiveAvg)
					local nTotalGold = nSalary+nProfit

					-- 越南倒元宝惩罚机制
					if version_vn and nTotalGold>0 and Player:GetRewardValueDebt(nId)>0 then
						local nReduce = math.ceil(nTotalGold*0.3)
						if nReduce>0 then
							nTotalGold = nTotalGold-nReduce
							Log("Kin:_ActivityDailyReport vn_debt", tbKinData.nKinId, nTotalGold+nReduce, nReduce, Player:GetRewardValueDebt(nId))
						end
					end

					local szMailContent = string.format([[幫派本周活躍：%d\n幫派日均活躍：%d\n我的日均活躍：%d\n幫派當前評價：%s\n預計本周工資：%d#999[FFFE0D](週一4:00發放工資)[-]

【活躍規則說明】
活躍：[FFFE0D]日均活躍≥3000[-]較多工資
不夠活躍：[FFFE0D]3000>日均活躍≥1000[-]較少或無工資
非常不活躍：[FFFE0D]日均活躍<1000[-]持續兩周幫派將會被解散，新建幫派第一周爲保護期
[FFFE0D]注：個人日均活躍、幫派職位影響最終獲得的工資[-]\n]],
						nDisplayKinActive, nDisplayActiveAvg, nMyActiveAvg, tbSetting.szJudgement, nTotalGold)

					Mail:SendSystemMail({
				        To = nId,
				        Title = "幫派活躍報告",
				        Text = szMailContent,
				        From = "幫派總管",
				        tbAttach = {},
				    })
				end
			end
		end
	end)
end

function Kin:DoActivityDaily()
	self:_ActivityDailyUpdate()

	local nWeekDay = Lib:GetLocalWeekDay(GetTime())
	if nWeekDay==1 then
		self:_ActivityWeeklyJudge()
		self:_ActivityWeeklyReset()
	else
		self:_ActivityDailyReport()
	end
	self:_ActivityDailyReset()

	ScriptData:SaveAtOnce("KinLastActivityDaily", GetTime())
end

-- 转正见习成员
function Kin:TransferCareerNew()
	Kin:TraverseKin(function(tbKinData)
		tbKinData:TransferCareerNew()
	end)
end

function Kin:GetReducedValue(nPlayerId, nValue)
	local tbMemberData = Kin:GetMemberData(nPlayerId)
	if tbMemberData and tbMemberData:GetCareer()==Kin.Def.Career_New then
		return math.floor(nValue/4)
	end
	return nValue
end

function Kin:OnMemberCharge(pPlayer, nCharge)
	self:ProcessMemberCharge(pPlayer.dwID, pPlayer.dwKinId, nCharge)
end

function Kin:ProcessMemberCharge(nPlayerId, nKinId, nCharge)
	local tbKinData = Kin:GetKinById(nKinId)
	if not tbKinData then
		Log(string.format("Kin:ProcessMemberCharge GetKinById nil: %s %s %s", nPlayerId, nKinId, nCharge))
		return
	end

	tbKinData:OnMemberCharge(nPlayerId, nCharge)
end

local function isTimeBefore(nTime, nBefore)
	local tbTime = os.date("*t", nTime)
	local n = tbTime.hour*100+tbTime.min
	return n<nBefore
end

function Kin:GetActivityWeekDay(nInTime)
	local nNow = GetTime()
	local nWeekDay = Lib:GetLocalWeekDay(nNow)
	nWeekDay = (nWeekDay-1)==0 and 7 or (nWeekDay-1)

	local nDiffDay = 0
	if (nNow-nInTime)>=7*24*3600 then
		nDiffDay = 7
	else
		local nTime1 = Lib:GetTimeNum(nInTime)
		local nTime2 = Lib:GetTimeNum(nNow)
		if isTimeBefore(nInTime, 400) then
			nTime1 = nTime1-1
		end
		if isTimeBefore(nNow, 400) then
			nTime2 = nTime2-1
		end
		nDiffDay = nTime2-nTime1+1
	end

	return math.max(1, math.min(nWeekDay, nDiffDay))
end

-- for gm use only
function Kin:OpenMascot(bOpen)
	if bOpen==nil then
		bOpen = true
	end

	Kin.Def.bMascotClosed = not bOpen
	if bOpen then
		Kin:TraverseKin(function(tbKinData)
			local nMasterId = tbKinData:GetMasterId()
			Mail:SendSystemMail({
				To = nMasterId,
				Title = "吉祥物職位",
				Text = "    吉祥物職位已在本服開放體驗測試。\n    3級以上幫派即開放吉祥物職位，由堂主將幫派成員任命為吉祥物，吉祥物不擁有幫派的管理許可權但享有每週的幫派工資，建議任命幫派中較為活躍的女性玩家。（詳細規則請查看幫派介面説明按鈕）",
				From = "幫派總管",
			})
		end)
	else
		Kin:TraverseKin(function(tbKinData)
			for nPlayerId, nCareer in pairs(tbKinData.tbMembers) do
				if nCareer==Kin.Def.Career_Mascot then
					self:ChangeCareer(nPlayerId, Kin.Def.Career_Normal, nil, true)
				end
			end
		end)
	end
end

function Kin:SyncMascotOpenStatus()
	me.CallClientScript("Kin:OnSyncMascotOpenStatus", Kin.Def.bMascotClosed)
end

function Kin:CheckCorrectWeekActive()
	local nNow = GetTime()
	local nLast = ScriptData:GetValue("KinLastActivityDaily")
	if type(nLast)~="number" then
		Log("Kin:CheckCorrectWeekActive skip")
		return
	end
	-- 3:55汇总周活跃
	if Lib:IsDiffDay((3*60+55)*60, nLast, nNow)	then
		self:_ActivityDailyUpdate()
		Log("Kin:CheckCorrectWeekActive", nLast, nNow)
	end
end

function Kin:UpdateJoinCD(nPlayerId, bKickedOut, nNow)
	local nCD = Kin.Def.tbJoinCD.nDefault
	if bKickedOut then
		nCD = Kin.Def.tbJoinCD.nKickedOut
	end
	local nRealNow = GetTime()
	nNow = nNow or nRealNow
	local nDeadline = nNow+nCD
	if nDeadline<nRealNow then
		return
	end

	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId)
	if pPlayer then
		if bKickedOut then
			local nLastCD = self:GetJoinCD(pPlayer)
			if nLastCD<=nCD then
				return
			end
		end
		pPlayer.SetUserValue(self.Def.tbJoinCDSaveSettings.nGrp, self.Def.tbJoinCDSaveSettings.nKey, nDeadline)
	else
		local szCmd = string.format("Kin:UpdateJoinCD(%d, %s, %d)", nPlayerId, tostring(bKickedOut), nNow)
		KPlayer.AddDelayCmd(nPlayerId, szCmd, "UpdateJoinCD")
	end
end

function Kin:OnVipChanged(pPlayer, nNew, nOld)
	local nPlayerId = pPlayer.dwID

	--家族礼盒
	local tbMember = self:GetMemberData(nPlayerId)
	if not tbMember then
		return
	end
	local nOldInc = self:GetGiftInc(nOld)
	local nNewInc = self:GetGiftInc(nNew)
	local nDiff = nNewInc-nOldInc
	if nDiff<=0 then
		return
	end
	local tbData = tbMember:GetMemberGiftBoxData(pPlayer)
	tbData.nLeftCount = math.min(tbData.nLeftCount+nDiff, self:GetGiftMaxCount(nNew))
	tbMember:SaveMemberGiftBoxData(pPlayer, tbData)
	Log("Kin:OnVipChanged gift inc", nPlayerId, tbData.nLeftCount, nDiff, nNewInc, nOldInc, nNew, nOld)
end
