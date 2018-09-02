
--[[ tbPayInfo
{
    "type": "verify-order",
    "xgAppId": "91000622",
    "channelId": "vng",
    "uid": "vng__7703149588014790104",
    "zoneId": "1",
    "serverId": "20001",
    "roleId": "1048578",
    "roleName": "别静丹",
    "roleLevel": "39",
    "roleVipLevel": "0",
    "currencyName": "VND",
    "productId": "com.vng.jxm.item1",
    "productName": "fas",
    "productDesc": "fas",
    "productQuantity": "1",
    "productUnitPrice": "20000",
    "totalAmount": "20000",
    "paidAmount": "20000",
    "customInfo": "customInfo",
    "ts": "20160727152606",
    "gameTradeNo": "1469604346",
    "sign": "8bc94456968f02cf8f9cb4ab2bfc4b65e51b3638",
    "tradeNo": "716q211000342883",
    "paidTime": "20160727152606",
    "payType": null,
    "payStatus": "1"
}
]]

function Transmit:OnPayNotify(szNotifyJson, nCmdSequence)
	local tbPayInfo = Lib:DecodeJson(szNotifyJson);
	local tbResponse = {
		code = 0; -- 任何情况下只要通知到游戏，就返回成功，因为返回任意失败的话西瓜会重复通知
		msg = "fail";
		tradeNo = tbPayInfo.tradeNo;
	};

	local bOk, bResult, szErr = Lib:CallBack({Recharge.OnResponse, Recharge, tbPayInfo});

	if bOk and bResult then
		-- tbResponse.code = 0;
		tbResponse.msg = "success";
	else
		tbResponse.msg = szErr or bResult or "fail";
		Log("XGPayNotifyFail", tostring(bOk), tostring(bResult), tostring(szErr), tbPayInfo.uid or "", tbPayInfo.roleId, tbPayInfo.productId, tbPayInfo.paidAmount, tbPayInfo.payType);
	end

	Log("Pay", tbPayInfo.uid or "", tbPayInfo.roleId, tbPayInfo.gameTradeNo, tbPayInfo.tradeNo,
		 tbPayInfo.channelId or "", tbPayInfo.productId, tbPayInfo.paidAmount, tbPayInfo.payType, tostring(bResult), szErr);

	local szResponse = Lib:EncodeJson(tbResponse);
	PayOperateRespond(szResponse, nCmdSequence);
end

local eXGRetGift_Success       = 0; -- 	兑换成功
local eXGRetGift_CodeInvalid   = 1000; -- 	礼包码无效，没有相应活动
local eXGRetGift_RoleNotFound  = 1001; -- 	用户不存在
local eXGRetGift_NotThisServer = 1004; -- 	礼包码只能在指定区服使用
-- local eXGRetGift_ = 1005; -- 	用户不能重复领取礼包
-- local eXGRetGift_ = 1006; -- 	您领取次数已超过限制
-- local eXGRetGift_ = 1007; -- 	该批次礼包码兑换次数已经到达上限
-- local eXGRetGift_ = 1008; -- 	礼包码在同一互斥组
-- local eXGRetGift_ = 1009; -- 	没有通过礼包码要求的关卡
-- local eXGRetGift_ = 1010; -- 	等级低于领取礼包最小等级要求
-- local eXGRetGift_ = 1011; -- 	等级高于领取礼包最大等级要求
-- local eXGRetGift_ = 1012; -- 	礼包无法在该渠道使用
-- local eXGRetGift_ = 2000; -- 	游戏服务器异常
-- local eXGRetGift_ = 2001; -- 	游戏服务器返回发放失败
-- local eXGRetGift_ = 2002; -- 	获取用户信息失败
-- local eXGRetGift_ = 3000; -- 	兑换服务器异常
-- local eXGRetGift_ = 3001; -- 	系统错误
-- local eXGRetGift_ = 3002; -- 	发生未知网络错误

function Transmit:XGQueryRoleInfo(szRoleId, szServerId, szMissionId, nCmdSequence)
	local nPlayerId = tonumber(szRoleId) or 0;
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId) or KPlayer.GetRoleStayInfo(nPlayerId);
	local tbResult = {};
	if pPlayer then
		tbResult.code = eXGRetGift_Success;
		tbResult.msg = "success";
		tbResult.item = {
			roleId = szRoleId;
			roleName = pPlayer.szName;
			serverId = szServerId;
			serverName = szServerId;
			level = pPlayer.nLevel;
			missionId = szMissionId;
			isMissionPassed = true;
			uid = pPlayer.szAccount;
		};
	else
		tbResult.code = eXGRetGift_RoleNotFound;
		tbResult.msg = "role not found";
		tbResult.item = {};
	end

	local szResult = Lib:EncodeJson(tbResult);
	TransLib.DoXGQueryRoleRespond(nCmdSequence, szResult);
end


--[[
{
    "data": {
        "channelId": "jinshan",
        "items": [
            {
                "id": "JX1",
                "num": 1
            }
        ],
        "roleId": "1002",
        "serverId": "1",
        "zoneId": "1"
    },
    "sign": "cb11ceceef0c109dd87fca11f10fb6edb8690a75",
    "ts": "20160523140838",
    "type": "GIFT"
}
]]
function Transmit:XGSendGiftCode(szGiftCodeInfoJson, nCmdSequence)
	local tbGiftInfo = Lib:DecodeJson(szGiftCodeInfoJson);
	tbGiftInfo = tbGiftInfo.data or {};

	local tbResult = {};
	local nPlayerId = tonumber(tbGiftInfo.roleId) or 0;
	local szGiftType = tbGiftInfo.items and tbGiftInfo.items[1] and tbGiftInfo.items[1].id or nil;
	local tbRoleStayInfo = KPlayer.GetRoleStayInfo(nPlayerId);
	if tbRoleStayInfo then
		tbResult.code, tbResult.msg = CodeAward:SendXGCodeGift(nPlayerId, szGiftType);
	else
		tbResult.code = eXGRetGift_RoleNotFound;
		tbResult.msg = "role not found";
	end

	Log("Transmit:XGSendGiftCode", nPlayerId, szGiftType, tbResult.code, tbResult.msg);

	local szResult = Lib:EncodeJson(tbResult);
	TransLib.DoXGSendGiftCodeRespond(nCmdSequence, szResult);
end


