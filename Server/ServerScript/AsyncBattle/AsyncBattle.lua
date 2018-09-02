
function AsyncBattle:GetResgiterBattle(nPlayerId)
	self.tbPlayerAsyncBattle = self.tbPlayerAsyncBattle or {}
	self.tbPlayerAsyncBattle[nPlayerId] = self.tbPlayerAsyncBattle[nPlayerId] or {}
	return self.tbPlayerAsyncBattle[nPlayerId];
end

function AsyncBattle:ResgiterBattle(pPlayer, szType, nBattleKey, tbParam)
	-- TODO
	local nCurTime = GetTime()

	local tbBattle = AsyncBattle:GetResgiterBattle(pPlayer.dwID)
	if tbBattle.tbCurBattle and nCurTime - tbBattle.tbCurBattle.nStartTime < 10 then
		return false;
	end
	tbBattle.tbCurBattle =
	{
		szType = szType,
		nStartTime = nCurTime,
		nBattleKey = nBattleKey,
		Arg = tbParam,
	}

	return true;
end

function AsyncBattle:CreateClientAsyncBattle(pPlayer, nMapTemplateId, tbEnterPos, szType, nEnemy, nBattleKey, tbParam)
	if not AsyncBattle:ResgiterBattle(pPlayer, szType, nBattleKey, tbParam) then
		return false
	end
	AsyncBattle:ResgiterBattle(pPlayer, szType, nBattleKey, tbParam)

	pPlayer.SyncOtherPlayerAsyncData(pPlayer.dwID)
	pPlayer.CallClientScript("AsyncBattle:RegisterAsyncBattle", nMapTemplateId, 0, szType)
	pPlayer.CallClientScript("AsyncBattle:OnAsyncBattle", szType, nEnemy, nMapTemplateId, nBattleKey)
	pPlayer.EnterClientMap(nMapTemplateId, unpack(tbEnterPos))
end

function AsyncBattle:CreateAsyncBattle(pPlayer, nMapTemplateId, tbEnterPos, szType, nEnemy, nBattleKey, tbParam, bIgnoreAsyncCheck)
	local nRoleId = pPlayer.dwID;
	if not AsyncBattle:ResgiterBattle(pPlayer, szType, nBattleKey, tbParam) then
		return false
	end
	local tbBattle = Lib:NewClass(self.tbClass[szType]);
	tbBattle.nBattleKey = nBattleKey;
	tbBattle.szClassType = szType;
	self.tbApplyingMap[nRoleId] = tbBattle;

	Fuben:ApplyFuben(pPlayer.dwID, nMapTemplateId,
		function (nMapId)
			if not self.tbApplyingMap[nRoleId] then
				return;
			end
			local pPlayer = KPlayer.GetPlayerObjById(nRoleId)
			local bEnterSuccess = false;
			local tbBattle = self.tbApplyingMap[nRoleId]
			self.tbApplyingMap[nRoleId] = nil;
			tbBattle:Init(nRoleId, nEnemy, nMapId)
			self.tbBattleList[nMapId] = tbBattle;
            if pPlayer and (AsyncBattle:CanStartAsyncBattle(pPlayer) or bIgnoreAsyncCheck) then
            	pPlayer.CallClientScript("AsyncBattle:RegisterAsyncBattle", nMapTemplateId, nMapId, szType)
            	pPlayer.SetEntryPoint();
               	if pPlayer.SwitchMap(nMapId, unpack(tbEnterPos)) then
               		bEnterSuccess = true;
               	end
            end
            if not bEnterSuccess then
            	-- TODO: 回收地图
            end
		end,
		function ()
			Log("[KinTrainMgr] FubenCreateFail", nRoleId)
		end)

	return true;
end

function AsyncBattle:IsInAsyncBattle(pAsync)
	-- TODO
end

function AsyncBattle:OnAsyncResult(pPlayer, nResult, tbBattleObj)
	local tbBattle = AsyncBattle:GetResgiterBattle(pPlayer.dwID)
	local tbCurBattle = tbBattle.tbCurBattle;
	if tbCurBattle.nBattleKey ~= tbBattleObj.nBattleKey then
		pPlayer.CenterMsg("系統檢查到您的資料異常，本次戰鬥無效！");
		return;
	end

	if self.tbBattleType[tbCurBattle.szType] then
		local tbTable = self.tbBattleType[tbCurBattle.szType].tbTable;
		local fnCallback = self.tbBattleType[tbCurBattle.szType].fnResultCallback
		fnCallback(tbTable, pPlayer, nResult, tbBattleObj, unpack(tbCurBattle.Arg or {}))
	end

	tbBattle.tbCurBattle = nil; -- 清空战斗信息
end

function AsyncBattle:GetBattleArray(pAsync)
	if not pAsync then
		return tbBattleArray;
	end

	AsyncBattle:PrepareBattleArray(pAsync);

	local tbBattleArray = {};
	for i = 1, 5 do
		tbBattleArray[i] = pAsync.GetBattleArray(i)
	end

	return tbBattleArray;
end

-- 位置说明：
-- 前排 1	2	3
-- 后排 4	5	6
-- Index = 1 为玩家位置，2~5 分别为1~4号同伴的位置
function AsyncBattle:PrepareBattleArray(pAsync)
	if not pAsync then
		return;
	end

	local tbBattleArray = {5, 1, 3, 4, 6} -- 默认阵容 玩家在后排中间，前排1，3位置为1，2号同伴，后排4，6位置为3，4号同伴
	if pAsync.GetBattleArray(1) == 0 then -- 连玩家都没有位置，则从没有布阵信息，存入默认
		self:OnChangeBattleArray(pAsync, tbBattleArray)
	end
end

function AsyncBattle:OnChangeBattleArray(pAsync, tbBattleArray)
	local tbPos = {}
	-- 校验重复pos
	for nIdx, nPos in ipairs(tbBattleArray) do
		if tbPos[nPos] then
			return;
		end
		tbPos[nPos] = 1;
	end
	-- 存储
	for nIdx, nPos in ipairs(tbBattleArray) do
		pAsync.SetBattleArray(nIdx, nPos)
	end
end

function AsyncBattle:OnSyncBattleArray(pPlayer)
	local pAsync = KPlayer.GetAsyncData(pPlayer.dwID)

	local tbBattleArray = self:GetBattleArray(pAsync)

	pPlayer.CallClientScript("AsyncBattle:OnAsyncBattleArray", tbBattleArray)
end

function AsyncBattle:ResgiterBattleType(szType, tbTable, fnResultCallback, fnTimeOutCallback, nMapTemplateId)
	self.tbBattleType[szType] =
	{
		tbTable = tbTable,
		fnResultCallback = fnResultCallback,
		fnTimeOutCallback = fnTimeOutCallback,
	}
	if nMapTemplateId then
		local tbMap = Map:GetClass(nMapTemplateId);
		tbMap.OnEnter = function (self, nMapId)
			AsyncBattle:OnEnterMap(nMapId);
		end;
		tbMap.OnLeave = function (self, nMapId)
			AsyncBattle:OnLeaveMap(nMapId);
		end;
		tbMap.OnLogin = function (self, nMapId)
			AsyncBattle:OnLogin(nMapId);
		end
	end
end

function AsyncBattle:OnEndBattle(nMapId, nResult, tbBattleObj)
	local tbBattle = self.tbBattleList[nMapId]
	if not tbBattle then
		return;
	end
	local pPlayer = tbBattle:GetSelfPlayer()
	if not pPlayer then
		return;
	end
	self:OnAsyncResult(pPlayer, nResult, tbBattleObj)

	if tbBattle.ShowResultUi then
		tbBattle:ShowResultUi(nResult);
	end
end

function AsyncBattle:RequireEndBattle(pPlayer)
	local nMapId = pPlayer.nMapId
	if self.tbBattleList[nMapId] then
		if self.tbBattleList[nMapId].szClassType == "RankBattlePvp" then
			self.tbBattleList[nMapId]:End()
		end
	end
end

function AsyncBattle:RequireLeaveBattle(pPlayer)
	local nMapId = pPlayer.nMapId
	if self.tbBattleList[nMapId] then
		pPlayer.GotoEntryPoint()
	elseif pPlayer.nState == Player.emPLAYER_STATE_ALONE then
		me.LeaveClientMap();
		me.SyncAllSkillState(1);
	end
end

function AsyncBattle:AllBattleExecute(szClassType, szFunction)
	for _, tbBattleObj in pairs(self.tbBattleList) do
		if szClassType == tbBattleObj.szClassType then
			if tbBattleObj[szFunction] then
				tbBattleObj[szFunction](tbBattleObj);
			end
		end
	end
end
