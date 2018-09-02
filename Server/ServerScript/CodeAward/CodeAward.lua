CodeAward.CODE_PREFIX_LEN = 3;
CodeAward.CODE_LEN = CodeAward.CODE_PREFIX_LEN + 5 + 6;
CodeAward.SAVE_GROUP = {34};

local function LoadCodeAwardSetting()
	local tbCodeAwardSetting = LoadTabFile("ServerSetting/CodeAward/CodeAward.tab",
		"sddddddsssssssssss", "Type", {"Type", "SaveId", "TakeLimit", "BeginDay",
		 "EndDay", "MinLevel", "MaxLevel", "MailTxt", "Award1", "Award2", "Award3",
		 "Award4", "Award5", "Award6", "Award7", "Award8", "Award9", "Award10"});

	for szType, tbLineData in pairs(tbCodeAwardSetting) do
		for i = 1, 10 do
			local tbAward = Lib:SplitStr(tbLineData["Award" .. i], "|");
			tbLineData["Award" .. i] = nil;

			tbLineData.tbAward = tbLineData.tbAward or {}
			if tbAward[1] and tbAward[1] ~= "" then
				table.insert(tbLineData.tbAward, {
					tbAward[1],
					tonumber(tbAward[2]) or -1,
					tbAward[3] and tonumber(tbAward[3]),
					tbAward[4] and tonumber(tbAward[4])});
			end
		end
	end

	return tbCodeAwardSetting;
end

function CodeAward:Init()
	self.tbSetting = LoadCodeAwardSetting();
end

CodeAward:Init();

function CodeAward:GetRewardSetting(szCodePrefix)
	return self.tbSetting[szCodePrefix];
end

function CodeAward:TakeCodeAward(pPlayer, szCode)
	-- 关闭礼包码的服务端入口
	-- local bRet, szReason = self:DoTakeAward(pPlayer, szCode);
	-- if not bRet then
	-- 	pPlayer.CenterMsg(szReason or "领取激活码出错啦");
	-- end
end

function CodeAward:DoTakeAward(pPlayer, szCode)
	return false, "功能關閉";
end

function CodeAward:GetRealSaveInfo(nSaveId)
	local nSaveGroup = CodeAward.SAVE_GROUP[math.ceil(nSaveId/255)];
	nSaveId = nSaveId % 255
	if nSaveId == 0 then
		nSaveId = 255;
	end
	return nSaveGroup, nSaveId;
end

-- 验证返回码, 与 HttpProxyProtocol.proto 当中的定于相关
local RSP_CODE_OK            = 0;
local RSP_CODE_USED          = 1;
local RSP_CODE_CHANNEL_WRONG = 2;
local RSP_CODE_SERVER_WRONG  = 3;
local RSP_CODE_NOT_EXIST     = 4;
local RSP_CODE_DB_WRONG      = 5;

local tbRespondTips = {
	[RSP_CODE_OK]            = "成功領取禮包碼, 請到信箱當中查看";
	[RSP_CODE_USED]          = "該禮包已被使用";
	[RSP_CODE_CHANNEL_WRONG] = "該禮包碼不可在本渠道使用";
	[RSP_CODE_SERVER_WRONG]  = "該禮包碼不可在本服使用";
	[RSP_CODE_NOT_EXIST]     = "該禮包碼不存在";
	[RSP_CODE_DB_WRONG]      = "驗證禮包碼的時候, 伺服器發生了一個錯誤";
}

function CodeAward:VerifyRespond(nRoleId, szGiftCode, nRespondCode)
	-- 关闭礼包码的服务端入口
	assert(false);

	print(nRoleId, szGiftCode, nRespondCode)
	local pPlayer = KPlayer.GetPlayerObjById(nRoleId);
	if pPlayer then
		pPlayer.CenterMsg(tbRespondTips[nRespondCode]);
	end

	local szPrefix = string.sub(szGiftCode, 1, CodeAward.CODE_PREFIX_LEN);
	local tbRewardSetting = self:GetRewardSetting(szPrefix);
	if not tbRewardSetting then
		return;
	end

	if nRespondCode ~= RSP_CODE_OK then
		return;
	end

	if not pPlayer then
		Log("SendGiftCodeFail", "", nRoleId, szGiftCode, nRespondCode);
		return;
	end

	local tbMail = {
		To = nRoleId;
		Title = "禮包碼獎勵";
		Text = tbRewardSetting.MailTxt;
		From = "禮包碼發放系統";
		tbAttach = tbRewardSetting.tbAward;
		nLogReazon = Env.LogWay_CodeAward;
	};

	Mail:SendSystemMail(tbMail);

	local nSaveGroup, nSaveId = self:GetRealSaveInfo(tbRewardSetting.SaveId);
	local nSaveValue = pPlayer.GetUserValue(nSaveGroup, nSaveId);
	pPlayer.SetUserValue(nSaveGroup, nSaveId, nSaveValue + 1);

	Transmit:ReportUseCodeAward(pPlayer.dwID, szGiftCode, szGiftCode, pPlayer.szChannelCode, pPlayer.szAccount, pPlayer.szEquipId);
end

--------------------------------------------------------------------------------

local eXGRetGift_Success       = 0; -- 	兑换成功
local eXGRetGift_CodeInvalid   = 1000; -- 	礼包码无效，没有相应活动
local eXGRetGift_RoleNotFound  = 1001; -- 	用户不存在
local eXGRetGift_NotThisServer = 1004; -- 	礼包码只能在指定区服使用
local eXGRetGift_RoleOffLine   = 2002; -- 	获取用户信息失败

function CodeAward:SendXGCodeGift(nPlayerId, szGiftType)
	local tbRewardSetting = self:GetRewardSetting(szGiftType);
	if not tbRewardSetting then
		return eXGRetGift_CodeInvalid, "gift type not found";
	end

	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if pPlayer then
		pPlayer.CenterMsg("成功領取禮包碼, 請到信箱當中查看");
	end

	local tbMail = {
		To = nPlayerId;
		Title = "禮包碼獎勵";
		Text = tbRewardSetting.MailTxt;
		From = "禮包碼發放系統";
		tbAttach = tbRewardSetting.tbAward;
		nLogReazon = Env.LogWay_CodeAward;
	};

	Mail:SendSystemMail(tbMail);
	return eXGRetGift_Success, "success";
end
