
function TeamFuben:Init()
	for nSectionIdx, tbInfo in pairs(self.tbAllFuben or {}) do
		for nSubSectionIdx, tbSection in pairs(tbInfo) do
			local szSubType = string.format("%s_%s", nSectionIdx, nSubSectionIdx);
			TeamMgr:RegisterActivity("TeamFuben", szSubType, tbSection.szName,
				{"TeamFuben:QTCanShow", nSectionIdx, nSubSectionIdx},
				{"TeamFuben:QTCanJoin", nSectionIdx, nSubSectionIdx},
				{"TeamFuben:QTCheckEnter", nSectionIdx, nSubSectionIdx},
				{"TeamFuben:QTEnterFuben", nSectionIdx, nSubSectionIdx},
				TeamFuben.MIN_PLAYER_COUNT,
				{"TeamFuben:QTCheckHelpJoin", nSectionIdx, nSubSectionIdx}
				);
		end
	end
end

local function fnAllMember(tbMember, fnSc, ...)
	for _, nPlayerId in pairs(tbMember or {}) do
		local pMember = KPlayer.GetPlayerObjById(nPlayerId);
		if pMember then
			fnSc(pMember, ...);
		end
	end
end

local function fnMsg(pPlayer, szMsg)
	pPlayer.CenterMsg(szMsg);
end

function TeamFuben:CreateFuben(nPlayerId, nSectionIdx, nSubSectionIdx, bConfirm)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return;
	end

	local bRet, szMsg, tbMember, nFubenMapTemplateId = self:CheckCanCreateFuben(pPlayer, nSectionIdx, nSubSectionIdx);
	if not bRet then
		fnAllMember(tbMember, fnMsg, szMsg);
		return;
	end

	if #tbMember < TeamFuben.MAX_PLAYER_COUNT and not bConfirm then
		Dialog:Show(
		{
			Text = "目前人數並未滿員，是否直接開啟？",
			OptList = {
				{Text = "直接開啟", Callback = self.CreateFuben, Param = {self, nPlayerId, nSectionIdx, nSubSectionIdx, 1}},
				{Text = "等下再開"},
			},
		}, pPlayer);
		return;
	end

	local bAllHelp = true;
	local tbHelpState = {};
	local function fnSaveHelpState(pPlayer)
		tbHelpState[pPlayer.dwID] = TeamMgr:CanQuickTeamHelp(pPlayer);
		if not tbHelpState[pPlayer.dwID] then
			bAllHelp = false;
		end
	end
	fnAllMember(tbMember, fnSaveHelpState);
	if bAllHelp then
		fnAllMember(tbMember, fnMsg, "不允許所有人都是協助！");
		return;
	end

	local function fnSuccessCallback(nMapId)
		local function fnSucess(pPlayer, nMapId)
			pPlayer.SetEntryPoint();
			pPlayer.SwitchMap(nMapId, 0, 0);
		end
		fnAllMember(tbMember, fnSucess, nMapId);
		Activity:OnGlobalEvent("Act_OnJoinTeamActivity", tbMember, Env.LogWay_TeamFuben)
	end

	local function fnFailedCallback()
		fnAllMember(tbMember, fnMsg, "創建副本失敗，請稍後嘗試！");
	end

	Fuben:ApplyFuben(pPlayer.dwID, nFubenMapTemplateId, fnSuccessCallback, fnFailedCallback, nSectionIdx, nSubSectionIdx, tbHelpState);
	return true;
end

function TeamFuben:QTCanShow(nSectionIdx, nSubSectionIdx)
	return self:CanEnterFubenCommon(me, nSectionIdx, nSubSectionIdx);
end

function TeamFuben:QTCanJoin(nSectionIdx, nSubSectionIdx)
	return self:CheckPlayerCanEnterFuben(me, nSectionIdx, nSubSectionIdx);
end

function TeamFuben:QTCheckEnter(nSectionIdx, nSubSectionIdx)
	return self:CheckCanCreateFuben(me, nSectionIdx, nSubSectionIdx);
end

function TeamFuben:QTEnterFuben(nSectionIdx, nSubSectionIdx)
	return self:CreateFuben(me.dwID, nSectionIdx, nSubSectionIdx, true);
end

function TeamFuben:QTCheckHelpJoin(nSectionIdx, nSubSectionIdx)
	return self:CheckPlayerCanEnterFuben(me, nSectionIdx, nSubSectionIdx, true);
end