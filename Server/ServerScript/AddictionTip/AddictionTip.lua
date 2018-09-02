AddictionTip.save_info_once = 1;
AddictionTip.save_info_day = 2;

AddictionTip.nTipsTimeOnce = 3 * 3600;		-- 单次时长提示

AddictionTip.nCheckTimeSpace = 300;			-- 每次检查时间间隔

AddictionTip.szUrl = "https://maasapi2.game.qq.com/aas.fcg";

AddictionTip.nRetryTimes = 1;
AddictionTip.nMaxBatchCount = 128;

AddictionTip.szTipsOnce = "您本次線上時間已達三小時，請注意休息！";
AddictionTip.szTipsDay = "您今日線上已達八小時，請注意休息！";

AddictionTip.MSG_TYPE_GET_CONF = 1;						--//拉取游戏配置信息
AddictionTip.MSG_TYPE_GET_USERINFO_SINGLE = 2;			--//查询用户防沉迷信息
AddictionTip.MSG_TYPE_UPDATE_USERINFO_SINGLE = 3;		--//更新用户防沉迷时长信息
AddictionTip.MSG_TYPE_GET_USERINFO_BATCH = 4;			--//查询用户防沉迷信息--批量接口
AddictionTip.MSG_TYPE_UPDATE_USERINFO_BATCH = 5;		--//更新用户防沉迷时长信息--批量接口
AddictionTip.MSG_TYPE_PUSH_EDNGAME = 6;					--//上报用户退出游戏信息
AddictionTip.MSG_TYPE_PUSH_ENDGAME_BATCH = 7;			--//上报用户退出游戏信息--批量接口
AddictionTip.MSG_TYPE_REPORT_REMINDED_BATCH = 8;		--//上报用户弹窗提醒信息--批量接口

-- 允许提示地图白名单
AddictionTip.tbAllowMapId = {999, 10};

AddictionTip.tbAllowMapInfo = {};
AddictionTip.bOpen = version_tx and true or false;

for _, nMapId in pairs(AddictionTip.tbAllowMapId) do
	AddictionTip.tbAllowMapInfo[nMapId] = true;
end

function AddictionTip:Setup()
	if not self.bOpen then
		return;
	end

	if not Sdk:IsTest() then
		self.szUrl = "http://jxqy.maasapi.idip.tencent-cloud.net:12280/aas.fcg";
	end

	if not self.nLoginRegisterId then
		self.nLoginRegisterId = PlayerEvent:RegisterGlobal("OnLogin", AddictionTip.OnLogin, AddictionTip);
	end

	if not self.nLogoutRegisterId then
		self.nLogoutRegisterId = PlayerEvent:RegisterGlobal("OnLogout", AddictionTip.OnLogout, AddictionTip);
	end

	local nTimeNow = GetTime();
	local szAppId, nPlatId, nServerId = GetWorldConfifParam();
	self.szReq = [[{"common_msg":{"seq_id":%%s,"msg_type":%%s,"version":"1.0","appid":"%s","plat_id":%s,"area":%s},"body_info":%%s}]];
	self.szReq = string.format(self.szReq, szAppId, nPlatId == 0 and 1 or 2, nServerId);
	Log("[AddictionTip] ReqHead:", self.szReq);

	self:DoHttpReq({dwID = 0}, nTimeNow, self.MSG_TYPE_GET_CONF, {});
end

function AddictionTip:Activate(nTimeNow)
	if not self.bOpen then
		return;
	end
	local nStartTime = GetRDTSC();
	self.nNextCheckTime = self.nNextCheckTime or 0;
	if nTimeNow < self.nNextCheckTime then
		return;
	end

	self.nNextCheckTime = nTimeNow + self.nCheckTimeSpace;

	local nCheckTime = math.floor(nTimeNow / AddictionTip.nCheckTimeSpace) * AddictionTip.nCheckTimeSpace;

	local tbTipsOK = {};
	local tbAllPlayer = KPlayer.GetAllPlayer();
	for _, pPlayer in pairs(tbAllPlayer) do
		local nLoginTime = nTimeNow - (pPlayer.nAddictionTipLoginTime or nTimeNow);
		if self.tbAllowMapInfo[pPlayer.nMapTemplateId] and nLoginTime >= self.nTipsTimeOnce and not self:CheckHasTips(pPlayer) then
			table.insert(tbTipsOK, pPlayer);
		end
	end

	local tbUpdateUserInfo = {user_info = {}};
	for i = 1, #tbAllPlayer do
		local pPlayer = tbAllPlayer[i];
		if #tbUpdateUserInfo.user_info >= self.nMaxBatchCount then
			self:DoHttpReq({dwID = 0}, nTimeNow, self.MSG_TYPE_UPDATE_USERINFO_BATCH, tbUpdateUserInfo)
			tbUpdateUserInfo.user_info = {};
		end
		local this_period_time = math.min(math.max(nTimeNow - (pPlayer.nAddictionTipLastReportTime or nTimeNow), 1), self.nCheckTimeSpace);
		table.insert(tbUpdateUserInfo.user_info, {account_id = pPlayer.szAccount, character_id = tostring(pPlayer.dwID), this_period_time = this_period_time});
		pPlayer.nAddictionTipLastReportTime = nTimeNow;
	end

	if #tbUpdateUserInfo.user_info > 0 then
		self:DoHttpReq({dwID = 0}, nTimeNow, self.MSG_TYPE_UPDATE_USERINFO_BATCH, tbUpdateUserInfo);
	end

	self:DoTipsBatch(tbTipsOK, nTimeNow, self.save_info_once);

	if GetRDTSC() - nStartTime >= (1.5 * 1024 * 1024) then
		Log("[AddictionTip] Activate Cost Time ", GetRDTSC() - nStartTime)
	end
end

function AddictionTip:DoTipsBatch(tbPlayer, nTimeNow, nType)
	local nToday = Lib:GetLocalDay();
	if nType == self.save_info_day then
		local tbToRemove = {};
		self.tbNextTipsInfo = self.tbNextTipsInfo or {};
		for dwPlayerID, nTipsDay in pairs(self.tbNextTipsInfo) do
			if nTipsDay ~= nToday then
				tbToRemove[dwPlayerID] = true;
			else
				local pPlayer = KPlayer.GetPlayerObjById(dwPlayerID);
				if pPlayer then
					table.insert(tbPlayer, pPlayer);
					tbToRemove[dwPlayerID] = true;
				end
			end
		end

		for dwPlayerID in pairs(tbToRemove) do
			self.tbNextTipsInfo[dwPlayerID] = nil;
		end
	end

	local tbTipsOK = {};
	for _, pPlayer in pairs(tbPlayer) do
		if self.tbAllowMapInfo[pPlayer.nMapTemplateId] then
			pPlayer.MsgBox(nType == self.save_info_once and self.szTipsOnce or self.szTipsDay, {{"知道了"}, });
			if nType == self.save_info_once then
				self:SetHasTips(pPlayer);
			end
			table.insert(tbTipsOK, pPlayer);
		else
			if nType == self.save_info_day then
				self.tbNextTipsInfo[pPlayer.dwID] = nToday;
			end
		end
	end

	-- 上报
	local tbReportInfo = {remind_info = {}};
	for i = 1, #tbTipsOK do
		local pPlayer = tbTipsOK[i];
		if #tbReportInfo.remind_info >= self.nMaxBatchCount then
			self:DoHttpReq({dwID = 0}, nTimeNow, self.MSG_TYPE_REPORT_REMINDED_BATCH, tbReportInfo);
			tbReportInfo.remind_info = {};
		end

		table.insert(tbReportInfo.remind_info, {account_id = pPlayer.szAccount, character_id = tostring(pPlayer.dwID), report_type = nType, report_time = nTimeNow});
	end

	if #tbReportInfo.remind_info > 0 then
		self:DoHttpReq({dwID = 0}, nTimeNow, self.MSG_TYPE_REPORT_REMINDED_BATCH, tbReportInfo);
	end
end

function AddictionTip:OnLogin()
	if not self.bOpen then
		return;
	end

	local nTimeNow = GetTime();
	me.nAddictionTipLoginTime = nTimeNow;
	me.nAddictionTipLastReportTime = nTimeNow;
	self:DoHttpReq(me, nTimeNow, self.MSG_TYPE_GET_USERINFO_SINGLE, {account_id = me.szAccount, character_id = tostring(me.dwID)});
end

function AddictionTip:OnLogout()
	if not self.bOpen then
		return;
	end

	local nTimeNow = GetTime();
	local this_period_time = math.min(math.max(nTimeNow - (me.nAddictionTipLastReportTime or nTimeNow), 1), self.nCheckTimeSpace);
	self:DoHttpReq(me, nTimeNow, self.MSG_TYPE_PUSH_EDNGAME, {account_id = me.szAccount, character_id = tostring(me.dwID), this_period_time = this_period_time});
	me.nAddictionTipLastReportTime = nil;
end

function AddictionTip:CheckHasTips(pPlayer)
	return pPlayer.bAddctionHasTips and true or false;
end

function AddictionTip:SetHasTips(pPlayer)
	pPlayer.bAddctionHasTips = true;
end

function AddictionTip:DoHttpReq(pPlayer, nTime, nType, tbData)
	if not self.bOpen then
		return;
	end

	local _, szMsg = Lib:CallBack({Lib.EncodeJson, Lib, tbData});
	local szBody = szMsg or "";
	local szReq = string.format(self.szReq, nTime, nType, szBody);
	--Log("[AddictionTip] DoHttpReq", szReq);
	AssistLib.DoHttpCommonRequest(pPlayer.dwID, self.szUrl, szReq, "AddictionTip", szReq .. "|" .. tostring(nType) .. "|0", "");
end

function AddictionTip:OnHttpCommonRsp(nPlayerId, szRetData, szExtra)
	if not self.bOpen then
		return;
	end

	local szReq, nType, nRetryTimes = string.match(szExtra, "^(.*)|(%d+)|(%d+)$");
	if not szReq then
		Log("[AddictionTip] OnHttpCommonRsp Err szExtra !!", nPlayerId, szRetData, szExtra);
		return;
	end

	nType = tonumber(nType);
	nRetryTimes = tonumber(nRetryTimes);

	local bOK, tbRet = Lib:CallBack({Lib.DecodeJson, Lib, szRetData});
	if not bOK or tbRet.comm_rsp.ret ~= 0 then
		if nRetryTimes < self.nRetryTimes then
			AssistLib.DoHttpCommonRequest(nPlayerId, self.szUrl, szReq, "AddictionTip", szReq .. "|" .. tostring(nType) .. "|" .. (nRetryTimes + 1), "");
		else
			Log("[AddictionTip] OnHttpCommonRsp return fail !!", nPlayerId, szRetData, szExtra);
		end
		return;
	end

	local nTimeNow = GetTime();
	if nType == self.MSG_TYPE_GET_CONF then
		self.nTipsTimeOnce = tbRet.game_conf_info.one_game_standard;
		Log("[AddictionTip] Set TipsTimeOnce", self.nTipsTimeOnce);
	elseif nType == self.MSG_TYPE_UPDATE_USERINFO_BATCH then
		local tbTipsPlayer = {};
		for _, tbInfo in pairs(tbRet.user_info or {}) do
			if tbInfo.is_need_reminded == 1 then
				local nPlayerId = tonumber(tbInfo.character_id) or 0;
				local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
				if pPlayer then
					table.insert(tbTipsPlayer, pPlayer);
				end
			end
		end

		self:DoTipsBatch(tbTipsPlayer, nTimeNow, self.save_info_day);
	end
end