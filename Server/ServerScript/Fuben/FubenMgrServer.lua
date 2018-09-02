Require("CommonScript/Fuben/FubenMgrCommon.lua");
Fuben.CREATE_FUBEN_TIMEOUT = 10;	-- 创建副本地图 超时时间

function Fuben:ApplyFubenUseLevel(nPlayerId, nMapTemplateId, nFubenLevel, fnSuccessCallback, fnFailedCallback, ...)
	self.tbPlayerIdToMapId = self.tbPlayerIdToMapId or {};
	if nPlayerId > 0 and self.tbPlayerIdToMapId[nPlayerId] then
		return false, "正在創建中，請稍等。。";
	end

	local nMapId = CreateMap(nMapTemplateId);
	if not nMapId then
		Timer:Register(1, function() fnFailedCallback() end);		-- 保持统一，一定是异步回调的
		return;
	end

	local nTimeoutTimerId = Timer:Register(Env.GAME_FPS * self.CREATE_FUBEN_TIMEOUT, self.ApplyFubenFailed, self, nMapId);
	self.tbPlayerIdToMapId[nPlayerId] = nMapId;
	self.tbApply[nMapId] = {
		nPlayerId = nPlayerId;
		fnSuccessCallback = fnSuccessCallback;
		fnFailedCallback = fnFailedCallback;
		nTimeoutTimerId = nTimeoutTimerId;
		nFubenLevel = nFubenLevel;
		tbParam = {...};
	};
end	

function Fuben:ApplyFuben(nPlayerId, nMapTemplateId, fnSuccessCallback, fnFailedCallback, ...)
	return self:ApplyFubenUseLevel(nPlayerId, nMapTemplateId, 1, fnSuccessCallback, fnFailedCallback, ...)
end

function Fuben:ApplyFubenSucess(nMapId)
	if not self.tbApply[nMapId] then
		return;
	end

	if self.tbApply[nMapId].nTimeoutTimerId then
		Timer:Close(self.tbApply[nMapId].nTimeoutTimerId);
	end

	Lib:CallBack({self.tbApply[nMapId].fnSuccessCallback, nMapId});

	self.tbPlayerIdToMapId[self.tbApply[nMapId].nPlayerId] = nil;
	self.tbApply[nMapId] = nil;
end

function Fuben:ApplyFubenFailed(nMapId)
	if not self.tbApply[nMapId] then
		return;
	end

	self.tbApply[nMapId].fnFailedCallback();
	self.tbPlayerIdToMapId[self.tbApply[nMapId].nPlayerId] = nil;
	self.tbApply[nMapId] = nil;
end

function Fuben:OnCreateMap(nMapTemplateId, nMapId)
	local tbParam = {};
	local tbApplyInfo = self.tbApply[nMapId];
	local nFubenLevel = 1;
	if tbApplyInfo then
		tbParam     = tbApplyInfo.tbParam or {};
		nFubenLevel = tbApplyInfo.nFubenLevel or 1;
	end

	self:CreateFuben(nMapTemplateId, nMapId, nFubenLevel, unpack(tbParam));
	self:ApplyFubenSucess(nMapId);
end

