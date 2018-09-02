AssistClient.bFakeMidasServer = false;

AssistClient.tbFakeMidasServer = AssistClient.tbFakeMidasServer or {};
local FakeMidasServer = AssistClient.tbFakeMidasServer;
FakeMidasServer.nDelayTime = 15; -- 单位, 帧
FakeMidasServer.nDefaultGold = 0; -- 默认货币数量
FakeMidasServer.tbAllPlayersGold = FakeMidasServer.tbAllPlayersGold or {};

function FakeMidasServer:GetMyGold(nPlayerId)
	if not self.tbAllPlayersGold[nPlayerId] then
		self.tbAllPlayersGold[nPlayerId] = self.nDefaultGold;
	end
	return self.tbAllPlayersGold[nPlayerId];
end

function FakeMidasServer:CostMyGold(nPlayerId, nCost)
	local nMyGold = self:GetMyGold(nPlayerId);
	if nMyGold >= nCost then
		self.tbAllPlayersGold[nPlayerId] = nMyGold - nCost;
		return true;
	end
	return false;
end

function FakeMidasServer:AddMyGold(nPlayerId, nGold)
	local nMyGold = self:GetMyGold(nPlayerId);
	self.tbAllPlayersGold[nPlayerId] = nMyGold + nGold;
	return true;
end

function FakeMidasServer:GetBalanceStr(nPlayerId)
	local tbRet = {
		ret = 0;
		billno = "";
		balance = self:GetMyGold(nPlayerId);
		save_amt = self.nDefaultGold;
	}

	return Lib:EncodeJson(tbRet);
end

function FakeMidasServer:UpdateBalanceInfo(nPlayerId)
	Timer:Register(FakeMidasServer.nDelayTime, function ()
		local szBalanceInfo = self:GetBalanceStr(nPlayerId);
		AssistClient:OnQueryBalanceRsp(nPlayerId, szBalanceInfo);
	end);
end

function FakeMidasServer:GetPayRspStr(nPlayerId, nPay)
	local tbRet = {
		ret = self:CostMyGold(nPlayerId, nPay) and Sdk.eMidasServerRet_Sussess or Sdk.eMidasServerRet_LackMoney;
		balance = self:GetMyGold(nPlayerId);
	};
	return Lib:EncodeJson(tbRet);
end

function FakeMidasServer:MidasPay(nPlayerId, nPay, nWaitingId)
	Timer:Register(FakeMidasServer.nDelayTime, function ()
		local szPayRspStr = self:GetPayRspStr(nPlayerId, nPay);
		AssistClient:OnWaitingRsp(nWaitingId, "OnPayRsp", szPayRspStr);
	end);
end

function FakeMidasServer:GetAddGoldInfo(nPlayerId, nPay)
	local tbRet = {
		ret = self:AddMyGold(nPlayerId, nPay) and Sdk.eMidasServerRet_Sussess or Sdk.eMidasServerRet_LoginError;
		balance = self:GetMyGold(nPlayerId);
	}
	return Lib:EncodeJson(tbRet);
end

function FakeMidasServer:CancelPay(nPlayerId, nPay, nWaitingId)
	Timer:Register(FakeMidasServer.nDelayTime, function ()
		local szCancelRspStr = self:GetAddGoldInfo(nPlayerId, nPay);
		AssistClient:OnWaitingRsp(nWaitingId, "OnCancelPayRsp", szCancelRspStr);
	end);
end

function FakeMidasServer:Present(nPlayerId, nGold, nWaitingId)
	Timer:Register(FakeMidasServer.nDelayTime, function ()
		local szPresentRspStr = self:GetAddGoldInfo(nPlayerId, nGold);
		AssistClient:OnWaitingRsp(nWaitingId, "OnPresentRsp", szPresentRspStr);
	end);
end

-------------------------------------------------------------------------------
Require("ServerScript/Common/Env.lua");
AssistClient.tbWatingRespond = AssistClient.tbWatingRespond or {};

AssistClient.nMsdkParamErrorRetryCount = 3; -- 当参数错误时的请求重登重试次数
AssistClient.nNextPayWaitingTime = 20; -- 一笔交易的超时时间
AssistClient.nWaitingTimeOut = 5; -- 5秒没回包则进行重发处理
AssistClient.nMaxResendCount = 3; -- 没有回应 或  或未知错误 时最大重发次数

local tbTLogPayTypeMap = {
	OnPayRsp       = 1;
	OnPresentRsp   = 2;
	OnCancelPayRsp = 3;
	Pay            = 4;
	Present        = 5;
	CancelPay      = 6;
}

function AssistClient:Active(nTimeNow)
	if nTimeNow % 2 == 0 then
		return;
	end

	if not Sdk:IsMsdk() then
		return;
	end

	local tbToDelete = {};
	for nWaitingId, tbInfo in pairs(self.tbWatingRespond) do
		if tbInfo.nResendTime <= nTimeNow then
			if not self:Resend(nWaitingId, tbInfo) then
				table.insert(tbToDelete, nWaitingId);

				Log("AssistClient Resend Fail..", tbInfo.szType, tbInfo.nPlayerId, tbInfo.szBillNo, tbInfo.nGold);
				local szGameAppid, nPlat, nServerIdentity = GetWorldConfifParam();
				TLog("GoldErrFlow",
					szGameAppid,
					nPlat,
					nServerIdentity,
					tbInfo.nPlayerId or 0,
					tbTLogPayTypeMap[tbInfo.szType] or 0,
					tbInfo.nGold or 0,
					tbInfo.szBillNo or "");

				local _, szMsg = tbInfo.fnCallback(tbInfo.nPlayerId, false, tbInfo.szBillno, unpack(tbInfo.tbParams));
				if tbInfo.szType == "Pay" then
					local pPlayer = KPlayer.GetPlayerObjById(tbInfo.nPlayerId);
					if pPlayer then
						pPlayer.CenterMsg(string.format("消費元寶失敗, 原因為:%s", szMsg or "未知支付系統錯誤"));
					end
				end
			end
		end
	end

	for _, nWaitingId in ipairs(tbToDelete) do
		self.tbWatingRespond[nWaitingId] = nil;
	end
end

function AssistClient:Resend(nWaitingId, tbWaitingInfo)
	Log("AssistClient:Resend", tbWaitingInfo.nPlayerId, tbWaitingInfo.szType, tbWaitingInfo.szBillNo);
	if tbWaitingInfo.nResendCount >= AssistClient.nMaxResendCount then
		return false;
	end

	if not AssistLib.AssitServerConnected() then
		Log("Resend AssitServer not Connected");
		return false;
	end

	local pPlayer = KPlayer.GetPlayerObjById(tbWaitingInfo.nPlayerId);
	if not pPlayer then
		return false;
	end

	local tbMsdkInfo = pPlayer.GetMsdkInfo();
	if not next(tbMsdkInfo) then
		return false;
	end

	tbWaitingInfo.nResendCount = tbWaitingInfo.nResendCount + 1;
	tbWaitingInfo.nResendTime = GetTime() + AssistClient.nWaitingTimeOut;

	if tbWaitingInfo.szType == "Pay" then
		AssistLib.MidasPay(
			nWaitingId,
			tbMsdkInfo.szOpenId,
			tbMsdkInfo.szOpenKey,
			tbMsdkInfo.szPayToken,
			tbMsdkInfo.szPf,
			tbMsdkInfo.szPfKey,
			Sdk:GetPayUid(pPlayer),
			tbMsdkInfo.szSessionId,
			tbMsdkInfo.szSessionType,
			tbWaitingInfo.szBillNo,
			tostring(tbWaitingInfo.nGold),
			string.format("%s_%s", tostring(tbWaitingInfo.nLogReason1), tostring(tbWaitingInfo.nLogReason2)),
			tbMsdkInfo.nOsType,
			tbWaitingInfo.szSaleOrderId);
		return true;
	end

	if tbWaitingInfo.szType == "Present" then
		AssistLib.MidasPresent(
			nWaitingId,
			tbMsdkInfo.szOpenId,
			tbMsdkInfo.szOpenKey,
			tbMsdkInfo.szPayToken,
			tbMsdkInfo.szPf,
			tbMsdkInfo.szPfKey,
			Sdk:GetPayUid(pPlayer),
			tbMsdkInfo.szSessionId,
			tbMsdkInfo.szSessionType,
			tbWaitingInfo.szBillNo,
			tostring(tbWaitingInfo.nGold),
			tbMsdkInfo.nOsType,
			tbWaitingInfo.szSaleOrderId,
			tbWaitingInfo.szExtendParameter);
		return true;
	end

	if tbWaitingInfo.szType == "CancelPay" then
		AssistLib.MidasCancelPay(
			nWaitingId,
			tbMsdkInfo.szOpenId,
			tbMsdkInfo.szOpenKey,
			tbMsdkInfo.szPayToken,
			tbMsdkInfo.szPf,
			tbMsdkInfo.szPfKey,
			Sdk:GetPayUid(pPlayer),
			tbMsdkInfo.szSessionId,
			tbMsdkInfo.szSessionType,
			tbWaitingInfo.szBillNo,
			tostring(tbWaitingInfo.nGold),
			tbMsdkInfo.nOsType,
			tbWaitingInfo.szSaleOrderId);
		return true;
	end

	return false;
end

function AssistClient:CanQuit()
	local bCanQuit = not next(AssistClient.tbWatingRespond);
	if not bCanQuit then
		Log("Quiting AssistClient...");
	end
	return bCanQuit;
end

function AssistClient:OnLogin(pPlayer)
	-- AssistClient:ReportQQScore(pPlayer, Env.QQReport_Name, pPlayer.szName, 0, 1)
	-- AssistClient:ReportQQScore(pPlayer, Env.QQReport_KinId, pPlayer.dwKinId, 0, 1);
	-- AssistClient:ReportQQScore(pPlayer, Env.QQReport_Faction, pPlayer.nFaction, 0, 1);
	-- AssistClient:UpdateQQVipInfo(pPlayer);
end

function AssistClient:UpdateMsdkInfo(pPlayer, tbMsdkInfo, bLogin)
	if not Sdk:IsMsdk() then
		return;
	end

	if tbMsdkInfo.szOpenId ~= pPlayer.szAccount then
		local fnReturn2Login = function (nPlayerId)
			local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
			if pPlayer then
				pPlayer.CallClientScript("Ui:ReturnToLogin");
			end
		end

		pPlayer.MsgBox("登入異常, 請返回重新登入", {{"確認", fnReturn2Login, pPlayer.dwID}});
		return;
	end

	pPlayer.SetMsdkInfo(tbMsdkInfo);
	if bLogin then
		AssistClient:UpdateBalanceInfo(pPlayer);
		AssistClient:ReportQQScore(pPlayer, Env.QQReport_Name, pPlayer.szName, 0, 1)
		AssistClient:ReportQQScore(pPlayer, Env.QQReport_KinId, pPlayer.dwKinId, 0, 1);
		AssistClient:ReportQQScore(pPlayer, Env.QQReport_Faction, pPlayer.nFaction, 0, 1);
		AssistClient:UpdateQQVipInfo(pPlayer);
		Sdk:UpdateXinyueLevel(pPlayer);
	end

	if tbMsdkInfo.bPCVersion and tbMsdkInfo.nOsType == Sdk.eOSType_iOS then
		AssistClient:UpdatePfInfo(pPlayer, tbMsdkInfo);
	end
end

	-- 只有PC版本iOS服使用
function AssistClient:UpdatePfInfo(pPlayer, tbMsdkInfo)
	local tbPostInfo = {
		openid         = tbMsdkInfo.szOpenId,
		regChannel     = tbMsdkInfo.szRegisterChannel,
		os             = "iap",
		installchannel = tbMsdkInfo.szLoginChannel,
		offerid        = Sdk.sziOSOfferId,
	};

	if tbMsdkInfo.nPlatform == Sdk.ePlatform_QQ then
		tbPostInfo.appid = Sdk.szQQAppId;
		tbPostInfo.accessToken = tbMsdkInfo.szPayToken;
		tbPostInfo.platform = "desktop_m_qq";
	elseif tbMsdkInfo.nPlatform == Sdk.ePlatform_Weixin then
		tbPostInfo.appid = Sdk.szWxAppId;
		tbPostInfo.accessToken = tbMsdkInfo.szOpenKey;
		tbPostInfo.platform = "desktop_m_wx";
	else
		return;
	end

	local szPostData = Lib:EncodeJson(tbPostInfo);
	AssistLib.MsdkCommonRequest(
		pPlayer.dwID,
		tbMsdkInfo.szOpenId,
		tbMsdkInfo.nPlatform,
		"/auth/get_pfval",
		szPostData,
		"OnUpdatePfInfoRsp");
end

function AssistClient:OnUpdatePfInfoRsp(nPlayerId, szRetData)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return;
	end

	local tbPfInfo = Lib:DecodeJson(szRetData) or {};
	if tbPfInfo.ret ~= 0 then
		Log("OnUpdatePfInfoRsp Error", nPlayerId, szRetData);
		pPlayer.CenterMsg(tbPfInfo.msg);
		return;
	end

	local tbMsdkInfo = pPlayer.GetMsdkInfo();
	if tbMsdkInfo.szPfKey ~= tbPfInfo.pfKey or tbMsdkInfo.szPf ~= tbPfInfo.pf then
		Log("AssistClient:OnUpdatePfInfoRsp Error", szRetData, tbMsdkInfo.szPf, tbMsdkInfo.szPfKey);
		Log(debug.traceback());
	end

	tbMsdkInfo.szPf = tbPfInfo.pf;
	tbMsdkInfo.szPfKey = tbPfInfo.pfKey;
	pPlayer.SetMsdkInfo(tbMsdkInfo);
end

function AssistClient:AskPlayerUpdateMsdkInfo(pPlayer)
	pPlayer.CallClientScript("Sdk:LoginWithLocalInfo");
end

function AssistClient:UpdateBalanceInfo(pPlayer)
	local tbMsdkInfo = pPlayer.GetMsdkInfo();
	if not next(tbMsdkInfo) then
		return;
	end

	if AssistClient.bFakeMidasServer then
		FakeMidasServer:UpdateBalanceInfo(pPlayer.dwID);
	else
		AssistLib.UpdateBalanceInfo(pPlayer.dwID,
			tbMsdkInfo.szOpenId,
			tbMsdkInfo.szOpenKey,
			tbMsdkInfo.szPayToken,
			tbMsdkInfo.szPf,
			tbMsdkInfo.szPfKey,
			Sdk:GetPayUid(pPlayer),
			tbMsdkInfo.szSessionId,
			tbMsdkInfo.szSessionType,
			tbMsdkInfo.nOsType);
	end
end

function AssistClient:OnQueryBalanceRsp(nPlayerId, szBalanceInfo)
	assert(Sdk:IsMsdk());
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		Log("AssistClient:OnQueryBalanceRsp:Player Offline", nPlayerId, szBalanceInfo);
		return;
	end

	local tbBalanceInfo = Lib:DecodeJson(szBalanceInfo) or {};
	if tbBalanceInfo.ret == Sdk.eMidasServerRet_Sussess then
		pPlayer.SetGold(tbBalanceInfo.balance, Env.LogWay_SyncOuterGold);

		if math.ceil(Recharge.RATE * Recharge:GetTotoalRechargeGold(pPlayer) ) ~= tbBalanceInfo.save_amt then
			Recharge:OnTotalRechargeChange(pPlayer, math.ceil(tbBalanceInfo.save_amt / Recharge.RATE))
		end

		local tbSettingGroup = Recharge.tbSettingGroup
		for _, tbSubscribe in pairs(tbBalanceInfo.tss_list or {}) do
			local inner_productid = tbSubscribe.inner_productid
			-- "begintime" : "2016-03-10 19:17:22","endtime" : "2016-03-17 19:17:22"
			-- tbSubscribe.begintime, tbSubscribe.endtime
			if inner_productid == tbSettingGroup.DaysCard[1].szServiceCode then
				Recharge:OnBuyDaysCardCallBack(pPlayer, Lib:ParseDateTime(tbSubscribe.endtime), 1)
			elseif inner_productid == tbSettingGroup.DaysCard[2].szServiceCode then
				Recharge:OnBuyDaysCardCallBack(pPlayer, Lib:ParseDateTime(tbSubscribe.endtime), 2)
			elseif inner_productid == tbSettingGroup.GrowInvest[1].szServiceCode then
				Recharge:OnBuyInvestCallBack(pPlayer, 1)
			elseif inner_productid == tbSettingGroup.GrowInvest[2].szServiceCode then
				Recharge:OnBuyInvestCallBack(pPlayer, 2)
			elseif inner_productid == tbSettingGroup.GrowInvest[3].szServiceCode then
				Recharge:OnBuyInvestCallBack(pPlayer, 3)
			elseif inner_productid == tbSettingGroup.GrowInvest[4].szServiceCode then
				Recharge:OnBuyInvestCallBack(pPlayer, 4)
			elseif inner_productid == tbSettingGroup.GrowInvest[5].szServiceCode then
				Recharge:OnBuyInvestCallBack(pPlayer, 5)
			elseif inner_productid == tbSettingGroup.GrowInvest[6].szServiceCode then
				Recharge:OnBuyInvestCallBack(pPlayer, 6)
			elseif inner_productid == tbSettingGroup.GrowInvest[7].szServiceCode then
				Recharge:OnBuyInvestCallBack(pPlayer, 7)

			elseif inner_productid == tbSettingGroup.YearGift[1].szServiceCode then
				Recharge:OnBuyYearCardCallBack(pPlayer, Lib:ParseDateTime(tbSubscribe.endtime), 1)
			elseif tbSettingGroup.YearGift[2] and inner_productid == tbSettingGroup.YearGift[2].szServiceCode then
				Recharge:OnBuyYearCardCallBack(pPlayer, Lib:ParseDateTime(tbSubscribe.endtime), 2)
			elseif tbSettingGroup.YearGift[3] and inner_productid == tbSettingGroup.YearGift[3].szServiceCode then
				Recharge:OnBuyYearCardCallBack(pPlayer, Lib:ParseDateTime(tbSubscribe.endtime), 3)
			elseif tbSettingGroup.YearGift[4] and inner_productid == tbSettingGroup.YearGift[4].szServiceCode then
				Recharge:OnBuyYearCardCallBack(pPlayer, Lib:ParseDateTime(tbSubscribe.endtime), 4)


			elseif inner_productid == tbSettingGroup.DayGift[1].szServiceCode then
				Recharge:OnBuyOneDayCardCallBack(pPlayer, Lib:ParseDateTime(tbSubscribe.endtime), 1)
			elseif inner_productid == tbSettingGroup.DayGift[2].szServiceCode then
				Recharge:OnBuyOneDayCardCallBack(pPlayer, Lib:ParseDateTime(tbSubscribe.endtime), 2)
			elseif inner_productid == tbSettingGroup.DayGift[3].szServiceCode then
				Recharge:OnBuyOneDayCardCallBack(pPlayer, Lib:ParseDateTime(tbSubscribe.endtime), 3)

			elseif tbSettingGroup.DayGiftSet and inner_productid == tbSettingGroup.DayGiftSet[1].szServiceCode then
				Recharge:OnBuyOneDayCardSetCallBack(pPlayer, Lib:ParseDateTime(tbSubscribe.endtime), 1)
			elseif tbSettingGroup.DayGiftPlus and inner_productid == tbSettingGroup.DayGiftPlus[1].szServiceCode then
				Recharge:OnBuyOneDayCardPlusCallBack(pPlayer, Lib:ParseDateTime(tbSubscribe.endtime), 1)

			elseif inner_productid == tbSettingGroup.DirectEnhance[1].szServiceCode then
				Recharge:OnBuyDirectEnhanceCallBack(pPlayer, Lib:ParseDateTime(tbSubscribe.endtime), 1)
			elseif inner_productid == tbSettingGroup.DirectEnhance[2].szServiceCode then
				Recharge:OnBuyDirectEnhanceCallBack(pPlayer, Lib:ParseDateTime(tbSubscribe.endtime), 2)
			elseif inner_productid == tbSettingGroup.DirectEnhance[3].szServiceCode then
				Recharge:OnBuyDirectEnhanceCallBack(pPlayer, Lib:ParseDateTime(tbSubscribe.endtime), 3)

			elseif inner_productid == tbSettingGroup.BackGift[1].szServiceCode then
				Recharge:OnBuyBackGiftCallBack(pPlayer, Lib:ParseDateTime(tbSubscribe.endtime), 1)
			elseif inner_productid == tbSettingGroup.BackGift[2].szServiceCode then
				Recharge:OnBuyBackGiftCallBack(pPlayer, Lib:ParseDateTime(tbSubscribe.endtime), 2)
			elseif inner_productid == tbSettingGroup.BackGift[3].szServiceCode then
				Recharge:OnBuyBackGiftCallBack(pPlayer, Lib:ParseDateTime(tbSubscribe.endtime), 3)
			elseif inner_productid == tbSettingGroup.BackGift[4].szServiceCode then
				Recharge:OnBuyBackGiftCallBack(pPlayer, Lib:ParseDateTime(tbSubscribe.endtime), 4)
			elseif inner_productid == tbSettingGroup.BackGift[5].szServiceCode then
				Recharge:OnBuyBackGiftCallBack(pPlayer, Lib:ParseDateTime(tbSubscribe.endtime), 5)
			end
		end
		pPlayer.nMsdkParamErrorCount = 0;
	elseif tbBalanceInfo.ret == Sdk.eMidasServerRet_LoginError then
		AssistClient:AskPlayerUpdateMsdkInfo(pPlayer);
		Log("AssistClient:OnQueryBalanceRsp", nPlayerId, tbBalanceInfo.ret, szBalanceInfo);
	elseif tbBalanceInfo.ret == Sdk.eMidasServerRet_ParamError then
		pPlayer.nMsdkParamErrorCount = pPlayer.nMsdkParamErrorCount or 0;
		pPlayer.nMsdkParamErrorCount = pPlayer.nMsdkParamErrorCount + 1;
		if pPlayer.nMsdkParamErrorCount < AssistClient.nMsdkParamErrorRetryCount then
			AssistClient:AskPlayerUpdateMsdkInfo(pPlayer);
		end
		Log("AssistClient:ParamError:", pPlayer.dwID, pPlayer.nMsdkParamErrorCount, szBalanceInfo);
	else
		Log("AssistClient:OnQueryBalanceRsp:ERROR", nPlayerId, szBalanceInfo);
	end
end

AssistClient.nNextWatingId = AssistClient.nNextWatingId or 1;
function AssistClient:GetWaitingId()
	local nId = AssistClient.nNextWatingId;
	AssistClient.nNextWatingId = nId + 1;
	if AssistClient.nNextWatingId > Env.INT_MAX then
		AssistClient.nNextWatingId = 1;
	end
	return nId;
end

AssistClient.tbNextPlayersPayTime = AssistClient.tbNextPlayersPayTime or {};

function AssistClient:DoPay(pPlayer, nPay, nLogReason1, nLogReason2, fnAfterPay, ...)
	local nNow = GetTime();
	if self.tbNextPlayersPayTime[pPlayer.dwID] and nNow < self.tbNextPlayersPayTime[pPlayer.dwID] then
		fnAfterPay(pPlayer.dwID, false, "");
		pPlayer.CenterMsg("您有一筆交易正在進行中, 請稍後");
		return false;
	end

	self.tbNextPlayersPayTime[pPlayer.dwID] = nNow + AssistClient.nNextPayWaitingTime;

	local nWaitingId, szBillNo, tbWaitingInfo = AssistClient:Push2WaitingList("Pay", pPlayer, nPay, nLogReason1, nLogReason2, fnAfterPay, ...);
	if not nWaitingId or not szBillNo then
		fnAfterPay(pPlayer.dwID, false, "");
		pPlayer.CenterMsg("無法連結支付伺服器");
		return false;
	end

	if AssistClient.bFakeMidasServer then
		FakeMidasServer:MidasPay(pPlayer.dwID, nPay, nWaitingId);
	else
		local tbMsdkInfo = pPlayer.GetMsdkInfo();
		if not next(tbMsdkInfo) then
			return true;
		end
		AssistLib.MidasPay(
			nWaitingId,
			tbMsdkInfo.szOpenId,
			tbMsdkInfo.szOpenKey,
			tbMsdkInfo.szPayToken,
			tbMsdkInfo.szPf,
			tbMsdkInfo.szPfKey,
			Sdk:GetPayUid(pPlayer),
			tbMsdkInfo.szSessionId,
			tbMsdkInfo.szSessionType,
			szBillNo,
			tostring(nPay),
			string.format("%s_%s", tostring(nLogReason1), tostring(nLogReason2)),
			tbMsdkInfo.nOsType,
			tbWaitingInfo.szSaleOrderId);
	end
	return true;
end

function AssistClient:DoCancelPay(pPlayer, nGold, szBillno, nLogReason1, nLogReason2, fnAfterCancelPay, ...)
	local nWaitingId, _, tbWaitingInfo = AssistClient:Push2WaitingList("CancelPay", pPlayer, nGold, nLogReason1, nLogReason2, fnAfterCancelPay, ...);
	if not nWaitingId then
		fnAfterCancelPay(pPlayer.dwID, false, "");
		return false;
	end

	tbWaitingInfo.szBillNo = szBillno;

	if AssistClient.bFakeMidasServer then
		FakeMidasServer:CancelPay(pPlayer.dwID, nGold, nWaitingId);
	else
		local tbMsdkInfo = pPlayer.GetMsdkInfo();
		if not next(tbMsdkInfo) then
			return true;
		end
		AssistLib.MidasCancelPay(
			nWaitingId,
			tbMsdkInfo.szOpenId,
			tbMsdkInfo.szOpenKey,
			tbMsdkInfo.szPayToken,
			tbMsdkInfo.szPf,
			tbMsdkInfo.szPfKey,
			Sdk:GetPayUid(pPlayer),
			tbMsdkInfo.szSessionId,
			tbMsdkInfo.szSessionType,
			szBillno,
			tostring(nGold),
			tbMsdkInfo.nOsType,
			tbWaitingInfo.szSaleOrderId);
	end
	return true;
end

function AssistClient:DoPresent(pPlayer, nGold, nLogReason1, nLogReason2, fnAfterPresent, ...)
	local nWaitingId, szBillno, tbWaitingInfo = AssistClient:Push2WaitingList("Present", pPlayer, nGold, nLogReason1, nLogReason2, fnAfterPresent, ...);
	if not nWaitingId then
		fnAfterPresent(pPlayer.dwID, false, "", "無法連結支付伺服器");
		return false;
	end

	if AssistClient.bFakeMidasServer then
		FakeMidasServer:Present(pPlayer.dwID, nGold, nWaitingId);
	else
		local tbMsdkInfo = pPlayer.GetMsdkInfo();
		if not next(tbMsdkInfo) then
			return true;
		end
		AssistLib.MidasPresent(
			nWaitingId,
			tbMsdkInfo.szOpenId,
			tbMsdkInfo.szOpenKey,
			tbMsdkInfo.szPayToken,
			tbMsdkInfo.szPf,
			tbMsdkInfo.szPfKey,
			Sdk:GetPayUid(pPlayer),
			tbMsdkInfo.szSessionId,
			tbMsdkInfo.szSessionType,
			szBillno or "",
			tostring(nGold),
			tbMsdkInfo.nOsType,
			tbWaitingInfo.szSaleOrderId or "",
			tbWaitingInfo.szExtendParameter or "");
	end
	return true;
end

local tbHasSaleOrderId = {
	[Env.LogWay_AuctionGold] = true;
	[Env.LogWay_BidFail] = true;
	[Env.LogWay_AuctionBid] = true;
	[Env.LogWay_AuctionBidOver] = true;
	[Env.LogWay_MarketStallGetMoney] = true;
	[Env.LogWay_MarketStallCostMoneyBuy] = true;
};

local SERVER_ID = Sdk:GetServerId();

function AssistClient:Push2WaitingList(szType, pPlayer, nGold, nLogReason1, nLogReason2, fnCallback, ...)
	assert(Sdk:IsMsdk(), "Only for tencent msdk midas...");

	local szSaleOrderId = "";
	if tbHasSaleOrderId[nLogReason1] and nLogReason2 then
		szSaleOrderId = tostring(nLogReason2);
	end

	local szExtendParameter = "";
	if nLogReason1 == Env.LogWay_IdipDoSendAttachMailReq then
		szExtendParameter = tostring(nLogReason2);
	end

	local nNow       = GetTime();
	local nWaitingId = AssistClient:GetWaitingId();
	local szBillNo   = string.format("%d_%d_%d_%d", SERVER_ID, pPlayer.dwID, nNow, nWaitingId);

	AssistClient.tbWatingRespond[nWaitingId] = {
		szType            = szType;
		nGold             = nGold;
		nLogReason1       = nLogReason1;
		nLogReason2       = nLogReason2;
		nResendTime       = nNow + AssistClient.nWaitingTimeOut;
		nResendCount      = 0;
		szBillNo          = szBillNo;
		szSaleOrderId     = szSaleOrderId;
		szExtendParameter = szExtendParameter;
		nPlayerId         = pPlayer.dwID;
		fnCallback        = fnCallback;
		tbParams          = {...};
	};

	return nWaitingId, szBillNo, AssistClient.tbWatingRespond[nWaitingId];
end

local tbHandleRetFlag = {
	[Sdk.eMidasServerRet_Sussess]              = true;
	[Sdk.eMidasServerRet_LackMoney]            = true;
	[Sdk.eMidasServerRet_RepeatBillNo]         = true;
	[Sdk.eMidasServerRet_LoginError]           = true;
	[Sdk.eMidasServerRet_ParamError]           = true;
	[Sdk.eMidasServerRet_PayRiskPunish]        = true;
	[Sdk.eMidasServerRet_PayRiskSeal]          = true;
	[Sdk.eMidasServerRet_PayRiskIntercept]     = true;
	[Sdk.eMidasServerRet_PresentRiskIntercept] = true;
	[Sdk.eMidasServerRet_PresentRiskSeal]      = true;
}

function AssistClient:OnWaitingRsp(nWaitingId, szRetType, szRetInfo)
	local tbRetInfo = Lib:DecodeJson(szRetInfo) or {};
	if not tbHandleRetFlag[tbRetInfo.ret] then
		Log("AssistClient:OnWaitingRsp:Fail:", tbRetInfo.msg, tbRetInfo.billno, szRetInfo);
		return;
	end

	local tbWaitingInfo = self.tbWatingRespond[nWaitingId];
	if not tbWaitingInfo then
		Log("AssistClient:OnWaitingRsp:nWaitingId not exist.", nWaitingId, szRetType, szRetInfo);
		if tbRetInfo.ret == Sdk.eMidasServerRet_Sussess then
			local szGameAppid, nPlat, nServerIdentity = GetWorldConfifParam();
			local szPlayerId = string.match(tbRetInfo.billno or "", "^%d+_(%d+)");

			TLog("GoldErrFlow",
				szGameAppid,
				nPlat,
				nServerIdentity,
				tonumber(szPlayerId) or 0,
				tbTLogPayTypeMap[szRetType] or 0,
				tbRetInfo.used_gen_amt or 0,
				tbRetInfo.billno or "");
		end
		return;
	end

	if tbRetInfo.ret ~= Sdk.eMidasServerRet_Sussess then
		Log("AssistClient:OnWaitingRsp", szRetType, nWaitingId, tbWaitingInfo.nPlayerId, tbWaitingInfo.nGold, tbWaitingInfo.nLogReason1, tbWaitingInfo.nLogReason2, szRetInfo);
	end

	local bStopWaiting = true;
	local fnDeal = self[szRetType];
	if fnDeal then
		bStopWaiting = fnDeal(self, tbWaitingInfo.nPlayerId, tbWaitingInfo, tbRetInfo);
	else
		assert(false, szRetType);
	end

	if bStopWaiting then
		self.tbWatingRespond[nWaitingId] = nil;
	end
end

function AssistClient:OnPayRsp(nPlayerId, tbWaitingInfo, tbPayRet)
	self.tbNextPlayersPayTime[nPlayerId] = nil;

	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	local szFailReason = "您在購買過程中下線了";
	if pPlayer then
		if tbPayRet.ret == Sdk.eMidasServerRet_Sussess then
			pPlayer.SetGold(tbPayRet.balance, tbWaitingInfo.nLogReason1, tbWaitingInfo.nLogReason2);
		elseif tbPayRet.ret == Sdk.eMidasServerRet_RepeatBillNo then
			pPlayer.SetGold(pPlayer.GetMoney("Gold") - tbWaitingInfo.nGold, tbWaitingInfo.nLogReason1, tbWaitingInfo.nLogReason2);
			AssistClient:UpdateBalanceInfo(pPlayer);
		elseif tbPayRet.ret == Sdk.eMidasServerRet_LackMoney then
			szFailReason = "你的餘額不足";
		elseif tbPayRet.ret == Sdk.eMidasServerRet_LoginError
			or tbPayRet.ret == Sdk.eMidasServerRet_ParamError
			then
			AssistClient:AskPlayerUpdateMsdkInfo(pPlayer);
			return false;
		end
	end

	if tbPayRet.ret == Sdk.eMidasServerRet_PayRiskPunish
		or tbPayRet.ret == Sdk.eMidasServerRet_PayRiskSeal
		or tbPayRet.ret == Sdk.eMidasServerRet_PayRiskIntercept
		then
		Log("OnPayRsp:Hit Risk", nPlayerId, tbPayRet.ret);
		return true;
	end

	local bSucceed = false;
	if tbPayRet.ret == Sdk.eMidasServerRet_Sussess
		or tbPayRet.ret == Sdk.eMidasServerRet_RepeatBillNo
		then
		bSucceed = true;
	end

	local bRet, bResult, szRetInfo = Lib:CallBack({tbWaitingInfo.fnCallback, nPlayerId, bSucceed, tbWaitingInfo.szBillNo, unpack(tbWaitingInfo.tbParams)});
	if bResult == nil or not bRet then
		Log("AssistClient:OnPayRsp Fail:", bRet, bResult, nPlayerId, bSucceed, tbWaitingInfo.szBillno, tbWaitingInfo.nGold, tbWaitingInfo.nLogReason1, tbWaitingInfo.nLogReason2);
	end

	if bResult == false and bSucceed then
		local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
		if pPlayer then
			AssistClient:DoCancelPay(pPlayer, tbWaitingInfo.nGold, tbPayRet.billno, Env.LogWay_ReturnGold2Player, szRetInfo or szFailReason, function (nPlayerId, bSucc)
				if not bSucc then
					local tbMail = {
						To = nPlayerId;
						Title = "元寶返還";
						From = "消費系統";
						Text = string.format("消費元寶失敗, 由此返還, 原因為:%s", szRetInfo or szFailReason);
						tbAttach = {{"Gold", tbWaitingInfo.nGold}};
						nLogReazon = tbWaitingInfo.nLogReason1;
						tbParams = {LogReason2 = tbWaitingInfo.nLogReason2};
					};

					Mail:SendSystemMail(tbMail);
				end
			end);
		else
			local tbMail = {
				To = nPlayerId;
				Title = "元寶返還";
				From = "消費系統";
				Text = string.format("消費元寶失敗, 由此返還, 原因為:%s", szRetInfo or szFailReason);
				tbAttach = {{"Gold", tbWaitingInfo.nGold}};
				nLogReazon = tbWaitingInfo.nLogReason1;
				tbParams = {LogReason2 = tbWaitingInfo.nLogReason2};
			};

			Mail:SendSystemMail(tbMail);
		end
	end

	-- 回调后如果金额大于一定值, 里面会立即处理存盘
	if pPlayer and bSucceed then
		Activity:OnPlayerEvent(pPlayer, "OnConsumeGold", tbWaitingInfo.nGold)
		if tbWaitingInfo.nGold >= Player.IMMEDIATE_SAVE_GOLD_LINE then
			pPlayer.SavePlayer();
		end
	end
	return true;
end

function AssistClient:OnPresentRsp(nPlayerId, tbWaitingInfo, tbRetInfo)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if tbRetInfo.ret == Sdk.eMidasServerRet_Sussess then
		if pPlayer then
			pPlayer.SetGold(tbRetInfo.balance, tbWaitingInfo.nLogReason1, tbWaitingInfo.nLogReason2);
		end
	elseif tbRetInfo.ret == Sdk.eMidasServerRet_RepeatBillNo then
		if pPlayer then
			AssistClient:UpdateBalanceInfo(pPlayer);
		end
	elseif tbRetInfo.ret == Sdk.eMidasServerRet_LoginError
			or tbRetInfo.ret == Sdk.eMidasServerRet_ParamError then
		if pPlayer then
			AssistClient:AskPlayerUpdateMsdkInfo(pPlayer);
			return false;
		else
			Lib:CallBack({tbWaitingInfo.fnCallback, nPlayerId, false, tbWaitingInfo.szBillno, "贈送元寶過程過離線", unpack(tbWaitingInfo.tbParams)});
		end
	elseif tbRetInfo.ret == Sdk.eMidasServerRet_PresentRiskIntercept -- 中了风控策略, 则不再进行赠送..
		or tbRetInfo.ret == Sdk.eMidasServerRet_PresentRiskSeal then
		Log("OnPresentRsp:Hit Risk", nPlayerId, tbRetInfo.ret);
		return true;
	else
		return false;
	end

	return true;
end

function AssistClient:OnCancelPayRsp(nPlayerId, tbWaitingInfo, tbRetInfo)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if tbRetInfo.ret == Sdk.eMidasServerRet_Sussess then
		if pPlayer then
			pPlayer.SetGold(tbRetInfo.balance, tbWaitingInfo.nLogReason1, tbWaitingInfo.nLogReason2);
		end
	elseif tbRetInfo.ret == Sdk.eMidasServerRet_RepeatBillNo then
		if pPlayer then
			AssistClient:UpdateBalanceInfo(pPlayer);
		end
	elseif tbRetInfo.ret == Sdk.eMidasServerRet_LoginError
			or tbRetInfo.ret == Sdk.eMidasServerRet_ParamError then
		if pPlayer then
			AssistClient:AskPlayerUpdateMsdkInfo(pPlayer);
			return false;
		else
			Lib:CallBack({tbWaitingInfo.fnCallback, nPlayerId, false, unpack(tbWaitingInfo.tbParams)});
		end
	else
		return false;
	end

	return true;
end

AssistClient.tbCachePayCmd = AssistClient.tbCachePayCmd or {};
function AssistClient:DoLocalPay(pPlayer, nCostGold, nLogReason1, nLogReason2, fnAfterPay, ...)
	table.insert(AssistClient.tbCachePayCmd, {
		nPlayerId = pPlayer.dwID;
		nCostGold = nCostGold;
		nLogReason1 = nLogReason1;
		nLogReason2 = nLogReason2;
		fnAfterPay = fnAfterPay;
		tbParams = {...};
	});
	AssistLib.SetNextRunPayFlag();
end

function AssistClient:RunCachePayCmd()
	for _, tbPayInfo in pairs(self.tbCachePayCmd) do
		AssistClient:DelayLocalPay(tbPayInfo);
	end
	AssistClient.tbCachePayCmd = {};
end

function AssistClient:DelayLocalPay(tbPayInfo)
	local pPlayer = KPlayer.GetPlayerObjById(tbPayInfo.nPlayerId);
	if not pPlayer then
		Lib:CallBack({tbPayInfo.fnAfterPay, tbPayInfo.nPlayerId, false, "", unpack(tbPayInfo.tbParams)});
		return;
	end

	local bSucceed = false;
	if pPlayer.CostMoney("Gold", tbPayInfo.nCostGold, tbPayInfo.nLogReason1, tbPayInfo.nLogReason2) then
		bSucceed = true;
	end

	local bRet, bResult, szRetInfo = Lib:CallBack({tbPayInfo.fnAfterPay, tbPayInfo.nPlayerId, bSucceed, "", unpack(tbPayInfo.tbParams)});
	if not bRet or bResult == nil then
		Log("AssistClient:DelayLocalPay", pPlayer.szName, tbPayInfo.nPlayerId, tbPayInfo.nCostGold, tbPayInfo.nLogReason1, tbPayInfo.nLogReason2);
	end

	if bResult == false and bSucceed then
		pPlayer.AddMoney("Gold", tbPayInfo.nCostGold, tbPayInfo.nLogReason1, tbPayInfo.nLogReason2);
	end

	if bSucceed then
		Activity:OnPlayerEvent(pPlayer, "OnConsumeGold", tbPayInfo.nCostGold)
		if tbPayInfo.nCostGold >= Player.IMMEDIATE_SAVE_GOLD_LINE then
			pPlayer.SavePlayer();
		end
	end
end

function AssistClient:ReportQQScore(pPlayer, nReportType, szReportData, nExpires, nCover, bKin)
	local tbMsdkInfo = pPlayer.GetMsdkInfo();
	if tbMsdkInfo.nPlatform ~= Sdk.ePlatform_QQ then
		return;
	end

	AssistLib.ReportQQScore(
		pPlayer.dwID,
		tbMsdkInfo.szOpenId,
		tbMsdkInfo.szOpenKey,
		nReportType,
		tostring(szReportData),
		tostring(nExpires),
		nCover,
		bKin and pPlayer.dwKinId or 0,
		(tbMsdkInfo.nOsType == Sdk.eOSType_iOS) and 2 or 1);
end

function AssistClient:UpdateGroupInfo(pPlayer, nKinId, nKinServerId)
	local tbMsdkInfo = pPlayer.GetMsdkInfo();
	if tbMsdkInfo.nPlatform ~= Sdk.ePlatform_QQ then
		return;
	end

	AssistLib.GetGroupDetail(
		pPlayer.dwID,
		tbMsdkInfo.szOpenId,
		tbMsdkInfo.szOpenKey,
		tostring(nKinId),
		tostring(nKinServerId));
end

function AssistClient:OnGroupInfoRsp(nPlayerId, szGroupInfo)
	local tbGroupInfo = Lib:DecodeJson(szGroupInfo) or {};
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if tbGroupInfo.ret == 0 then
		local nKinId = tonumber(tbGroupInfo.unionid);
		local kinData = Kin:GetKinById(nKinId);
		if kinData then
			kinData:SetQQGroupOpenData(tbGroupInfo.groupOpenid, tbGroupInfo.groupName);
		end
	elseif pPlayer then
		local kinData = Kin:GetKinById(pPlayer.dwKinId);
		local nPlatCode = tonumber(tbGroupInfo.platCode);
		if kinData and nPlatCode == Sdk.eQQGroupRet_NotBind then
			kinData:SetQQGroupOpenData(nil, nil);
			kinData:SetQQGroupNum(nil);
		end
		pPlayer.CallClientScript("Kin:GroupNotify", nPlatCode);
	end

	if pPlayer then
		Kin:SyncKinBaseInfo(nil, pPlayer);
	end
end

function AssistClient:AskQQGroupNum(pPlayer, kinData)
	local tbMsdkInfo = pPlayer.GetMsdkInfo();
	local tbPostInfo = {
		appid = Sdk.szQQAppId,
		openid = tbMsdkInfo.szOpenId,
		accessToken = tbMsdkInfo.szOpenKey,
		guild_id = tostring(pPlayer.dwKinId),
		zone_id = tostring(kinData:GetOrgServerId()),
	};

	local szPostData = Lib:EncodeJson(tbPostInfo);

	AssistLib.MsdkCommonRequest(
		pPlayer.dwID,
		tbMsdkInfo.szOpenId,
		Sdk.ePlatform_QQ,
		"/relation/get_groupcode",
		szPostData,
		"OnQQGroupNumRsp:" .. tbPostInfo.guild_id);
end

function AssistClient:OnQQGroupNumRsp(dwPlayerId, szRetData, szKinId)
	--Log("OnQQGroupNumRsp", dwPlayerId, szRetData, szKinId);
	local pPlayer = KPlayer.GetPlayerObjById(dwPlayerId);
	if not pPlayer then
		return;
	end
	
	local kinData = Kin:GetKinById(tonumber(szKinId));
	local tbRetInfo = Lib:DecodeJson(szRetData) or {};
	if not tbRetInfo or tbRetInfo.ret ~= Sdk.eQQGroupRet_Suss or not tbRetInfo.data or not tbRetInfo.data.gc then
		pPlayer.CenterMsg("獲取Q群消息失敗：" .. tbRetInfo.ret);
		return;
	end

	kinData:SetQQGroupNum(tbRetInfo.data.gc);
	AssistClient:JoinQQGroup(pPlayer, kinData);
end

function AssistClient:JoinQQGroup(pPlayer, kinData)
	local tbMsdkInfo = pPlayer.GetMsdkInfo();
	if tbMsdkInfo.nPlatform ~= Sdk.ePlatform_QQ then
		return false, "請使用手Q登入遊戲";
	end

	local szQQGroupNum = kinData:GetQQGroupNum();
	if not szQQGroupNum then
		AssistClient:AskQQGroupNum(pPlayer, kinData);
		return;
	end

	local tbPostInfo = {
		appid = Sdk.szQQAppId,
		openid = tbMsdkInfo.szOpenId,
		accessToken = tbMsdkInfo.szOpenKey,
		guild_id = tostring(pPlayer.dwKinId),
		zone_id = tostring(kinData:GetOrgServerId()),
		gc = szQQGroupNum,
		partition = tostring(Sdk:GetServerId()),
		roleid = tostring(pPlayer.dwID),
		platid = (tbMsdkInfo.nOsType == Sdk.eOSType_iOS and "2" or "1"),
	};

	local szPostData = Lib:EncodeJson(tbPostInfo);
	AssistLib.MsdkCommonRequest(
		pPlayer.dwID,
		tbMsdkInfo.szOpenId,
		Sdk.ePlatform_QQ,
		"/relation/join_groupv2",
		szPostData,
		"OnJoinQQGroupRsp");
end

function AssistClient:OnJoinQQGroupRsp(dwPlayerId, szRetData)
	-- Log("OnJoinQQGroupRsp", dwPlayerId, szRetData);
	local pPlayer = KPlayer.GetPlayerObjById(dwPlayerId);
	if not pPlayer then
		return;
	end

	local tbRetInfo = Lib:DecodeJson(szRetData) or {};
	local szTips = "您已成功加入Q群";
	if tbRetInfo.ret ~= Sdk.eQQGroupRet_Suss then
		szTips = "加入Q群失敗：" .. (tbRetInfo.message or "");
		Log("OnJoinQQGroupRsp Error", dwPlayerId, szRetData);
	end
	pPlayer.CenterMsg(szTips);
end

function AssistClient:AskGroupJoinKey(pPlayer, szGroupOpenId)
	local tbMsdkInfo = pPlayer.GetMsdkInfo();
	if not next(tbMsdkInfo) then
		return false;
	end

	if tbMsdkInfo.nOsType == Sdk.eOSType_iOS then
		return false, "iOS平台目前無法在遊戲內直接加入Q群, 請通過群號碼添加";
	end

	if tbMsdkInfo.nPlatform ~= Sdk.ePlatform_QQ then
		return false, "請使用手Q登入遊戲";
	end

	AssistLib.GetGroupJoinKey(
		pPlayer.dwID,
		tbMsdkInfo.szOpenId,
		tbMsdkInfo.szOpenKey,
		szGroupOpenId);
	return true;
end

function AssistClient:OnGroupJoinKeyRsp(nPlayerId, szGroupInfo)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return;
	end

	local tbGroupInfo = Lib:DecodeJson(szGroupInfo) or {};
	if tbGroupInfo.ret ~= Sdk.eQQGroupRet_Suss then
		return;
	end

	pPlayer.CallClientScript("Sdk:JoinQQGroup", tbGroupInfo.joinGroupKey);
end

function AssistClient:UnbindQQGroup(pPlayer, szGroupOpenId, nKinId)
	local tbMsdkInfo = pPlayer.GetMsdkInfo();
	if not next(tbMsdkInfo) then
		return false;
	end
	local tbPostInfo = {
		appid = Sdk.szQQAppId,
		openid = tbMsdkInfo.szOpenId,
		accessToken = tbMsdkInfo.szOpenKey,
		groupOpenid = szGroupOpenId,
		unionid = tostring(nKinId),
	};

	local szPostData = Lib:EncodeJson(tbPostInfo);
	AssistLib.MsdkCommonRequest(
		pPlayer.dwID,
		tbMsdkInfo.szOpenId,
		Sdk.ePlatform_QQ,
		"/relation/unbind_group",
		szPostData,
		"OnUnbindQQGroup");

	return true;
end

function AssistClient:OnUnbindQQGroup(dwPlayerId, szRetData)
	local pPlayer = KPlayer.GetPlayerObjById(dwPlayerId);
	if not pPlayer then
		return;
	end

	local tbGroupInfo = Lib:DecodeJson(szRetData) or {};
	if tbGroupInfo.ret ~= Sdk.eQQGroupRet_Suss then
		return;
	end

	local kinData = Kin:GetKinById(pPlayer.dwKinId);
	if kinData then
		kinData:SetQQGroupOpenData(nil, nil);
		Kin:SyncKinBaseInfo(nil, pPlayer);
		pPlayer.CenterMsg("您已成功解綁Q群");
	end
end

function AssistClient:SendQQGroupInvitation(pPlayer, szGroupOpenId, szTitle, szDesc, szRedirectUrl, szImgUrl, szParam)
	local tbMsdkInfo = pPlayer.GetMsdkInfo();
	if not next(tbMsdkInfo) then
		return false, "出現異常錯誤，暫時無法發送消息";
	end

	if tbMsdkInfo.nPlatform ~= Sdk.ePlatform_QQ then
		return false, "您需要通過手Q登入才可發送Q群消息";
	end

	local tbPostInfo = {
		appid = Sdk.szQQAppId,
		accessToken = tbMsdkInfo.szOpenKey,
		pf = "qqqun",
		group_openid = szGroupOpenId,
		title = szTitle or "戰鬥即將打響！",
		desc = szDesc or "兄弟姐妹們，趕快集合參加幫派活動啦！",
		redirect_url = szRedirectUrl or "http://gamecenter.qq.com/gcjump?appid=1105054046&pf=invite&from=iphoneqq&plat=qq&originuin=111&ADTAG=adtag.qun.kaizhan",
		image_url = szImgUrl or "http://download.wegame.qq.com/gc/formal/common/1105054046/thumImg.png",
		param = szParam or "",
	};

	local szPostData = Lib:EncodeJson(tbPostInfo);
	AssistLib.MsdkCommonRequest(
		pPlayer.dwID,
		tbMsdkInfo.szOpenId,
		Sdk.ePlatform_QQ,
		"/relation/send_groupmsg",
		szPostData,
		"OnSendQQGroupInvitation");
	return true;
end

function AssistClient:OnSendQQGroupInvitation(dwPlayerId, szRetData)
	Log("OnSendQQGroupInvitation", dwPlayerId, szRetData)
	local pPlayer = KPlayer.GetPlayerObjById(dwPlayerId);
	if not pPlayer then
		return;
	end

	local tbGroupInfo = Lib:DecodeJson(szRetData) or {};
	if tbGroupInfo.ret ~= Sdk.eQQGroupRet_Suss then
		local szMsg = string.format("發送Q群消息失敗. 錯誤碼：%s", tostring(tbGroupInfo.ret));
		pPlayer.CenterMsg(szMsg);
		return;
	end

	pPlayer.CenterMsg("您已成功發送Q群消息");
end

function AssistClient:SendQQLuckyBagMail(pPlayer, szBagType, nActId, nBagCount, nPeopleNum)
	local tbMsdkInfo = pPlayer.GetMsdkInfo();
	if not next(tbMsdkInfo) then
		return false;
	end

	local tbPostInfo = {
		appid = Sdk.szQQAppId,
		openid = tbMsdkInfo.szOpenId,
		accessToken = tbMsdkInfo.szOpenKey,
		pf = tbMsdkInfo.szPf,
		actid = nActId,
		num = nBagCount,
		peoplenum = nPeopleNum,
		type = 0,
	};

	local szPostData = Lib:EncodeJson(tbPostInfo);
	AssistLib.MsdkCommonRequest(
		pPlayer.dwID,
		tbMsdkInfo.szOpenId,
		Sdk.ePlatform_QQ,
		"/relation/qq_gain_chest",
		szPostData,
		"OnSendQQLuckyBagRsp:" .. szBagType);
	return true;
end

function AssistClient:OnSendQQLuckyBagRsp(nPlayerId, szRetData, szBagType)
	Sdk:OnQQLuckyBagRsp(nPlayerId, szRetData, szBagType)
end

--[[
tag name目前的值有：
MSG_INVITE //邀请
MSG_FRIEND_EXCEED //超越炫耀
MSG_HEART_SEND //送心
MSG_SHARE_FRIEND_PVP //PVP对战
]]
function AssistClient:ShareInfo(pPlayer, szTargeOpenId, szTitle, szContent, szTagName, szExtInfo)
	local tbMsdkInfo = pPlayer.GetMsdkInfo();
	if not next(tbMsdkInfo) then
		return false;
	end

	if tbMsdkInfo.nPlatform == Sdk.ePlatform_Weixin then
		local tbPostInfo = {
			openid         = tbMsdkInfo.szOpenId,
			access_token   = tbMsdkInfo.szOpenKey,
			fopenid        = szTargeOpenId,
			extinfo        = szExtInfo or "",
			title          = szTitle,
			description    = szContent,
			media_tag_name = szTagName or "MSG_SHARE_FRIEND_PVP",
			thumb_media_id = "",
		};

		local szPostData = Lib:EncodeJson(tbPostInfo);
		AssistLib.MsdkCommonRequest(
			pPlayer.dwID,
			tbMsdkInfo.szOpenId,
			Sdk.ePlatform_Weixin,
			"/share/wx",
			szPostData,
			"OnShareInfoRsp");
	end

	if tbMsdkInfo.nPlatform == Sdk.ePlatform_QQ then
		local tbPostInfo = {
			openid             = tbMsdkInfo.szOpenId,
			access_token       = tbMsdkInfo.szOpenKey,
			userip             = pPlayer.szIP,
			act                = 0,
			oauth_consumer_key = Sdk.szQQAppId,
			dst                = 1001,
			flag               = 1;
			image_url          = "http://download.wegame.qq.com/gc/formal/common/1105054046/thumImg.png",
			src                = 0,
			summary            = szContent,
			title              = szTitle,
			target_url         = "http://gamecenter.qq.com/gcjump?appid=1105054046&pf=invite&from=iphoneqq&plat=qq&originuin=111&ADTAG=gameobj.msg_heart",
			game_tag           = szTagName or "MSG_SHARE_FRIEND_PVP",
			fopenids           = {{["openid"] = szTargeOpenId, ["type"] = 0}};
		};

		local szPostData = Lib:EncodeJson(tbPostInfo);
		AssistLib.MsdkCommonRequest(
			pPlayer.dwID,
			tbMsdkInfo.szOpenId,
			Sdk.ePlatform_QQ,
			"/share/qq",
			szPostData,
			"OnShareInfoRsp");
	end
end

function AssistClient:OnShareInfoRsp(dwPlayerId, szRetData)
	Log("AssistClient:OnShareInfoRsp", dwPlayerId, szRetData)

	local pPlayer = KPlayer.GetPlayerObjById(dwPlayerId);
	if pPlayer then
		FriendRecall:OnShareInfoRsp(pPlayer, szRetData)
	end
end

function AssistClient:UpdateXinyueVip(pPlayer)
	local tbMsdkInfo = pPlayer.GetMsdkInfo();
	if not next(tbMsdkInfo) then
		return false;
	end

	local tbPostInfo = {
		openid = tbMsdkInfo.szOpenId,
		accessToken = tbMsdkInfo.szOpenKey,
		vip = 64, -- 64为心悦游戏玩家标识
	};

	local szCmd = nil;
	if tbMsdkInfo.nPlatform == Sdk.ePlatform_QQ then
		szCmd = "/profile/query_vip";
		tbPostInfo.appid = Sdk.szQQAppId;
	elseif tbMsdkInfo.nPlatform == Sdk.ePlatform_Weixin then
		szCmd = "/profile/load_vip";
		tbPostInfo.wxAppid = Sdk.szWxAppId;
		tbPostInfo.login = Sdk.ePlatform_Weixin;
	else
		return false;
	end

	local szPostData = Lib:EncodeJson(tbPostInfo);
	AssistLib.MsdkCommonRequest(
		pPlayer.dwID,
		tbMsdkInfo.szOpenId,
		tbMsdkInfo.nPlatform,
		szCmd,
		szPostData,
		"OnXinVipRsp");

	return true;
end

function AssistClient:OnXinVipRsp(dwPlayerId, szRetData)
	local pPlayer = KPlayer.GetPlayerObjById(dwPlayerId);
	if not pPlayer then
		return;
	end

	local tbVipInfo = Lib:DecodeJson(szRetData) or {};
	if tbVipInfo.ret ~= 0 then
		Log("AssistClient:OnXinVipRsp", pPlayer.dwID, pPlayer.szName, szRetData);
		return;
	end

	local nXinyueLevel = 0;
	for _, tbVipInfo in pairs(tbVipInfo.lists or {}) do
		if tbVipInfo.flag == 64 then -- 64为心悦游戏玩家标识
			if tbVipInfo.luxury == 1 or tbVipInfo.isvip ~= 0 then
				nXinyueLevel = tbVipInfo.luxury + tbVipInfo.level;
			end
		end
	end

	Sdk:SetXinyueLevel(pPlayer, nXinyueLevel);
end

function AssistClient:UpdateQQVipInfo(pPlayer)
	local tbMsdkInfo = pPlayer.GetMsdkInfo();
	if not next(tbMsdkInfo) then
		return false;
	end
	if tbMsdkInfo.nPlatform ~= Sdk.ePlatform_QQ then
		return false;
	end

	local tbPostInfo = {
		appid = Sdk.szQQAppId,
		openid = tbMsdkInfo.szOpenId,
		accessToken = tbMsdkInfo.szOpenKey
	};

	local szPostData = Lib:EncodeJson(tbPostInfo);
	AssistLib.MsdkCommonRequest(
		pPlayer.dwID,
		tbMsdkInfo.szOpenId,
		Sdk.ePlatform_QQ,
		"/relation/get_vip_rich_info",
		szPostData,
		"OnQQVipRsp");

	return true;
end

function AssistClient:OnQQVipRsp(dwPlayerId, szRetData)
	local pPlayer = KPlayer.GetPlayerObjById(dwPlayerId);
	if not pPlayer then
		return;
	end

	local tbVipInfo = Lib:DecodeJson(szRetData) or {};
	if tbVipInfo.ret ~= 0 then
		Log("AssistClient:OnQQVipRsp", pPlayer.dwID, pPlayer.szName, szRetData);
		return;
	end

	local nNow = GetTime();
	local nIsSVip    = tonumber(tbVipInfo.is_svip) or 0;
	local nIsVip     = tonumber(tbVipInfo.is_qq_vip) or 0;
	local nVipStart  = tonumber(tbVipInfo.qq_vip_start) or 0;
	local nVipEnd    = tonumber(tbVipInfo.qq_vip_end) or 0;
	local nSvipStart = tonumber(tbVipInfo.qq_svip_start) or 0;
	local nSvipEnd   = tonumber(tbVipInfo.qq_svip_end) or 0;

	if nIsVip == 1 and nVipEnd < nNow then
		nVipEnd = nNow + 48 * 3600;
	end

	if nIsSVip == 1 and nSvipEnd < nNow then
		nSvipEnd = nNow + 48 * 3600;
	end

	pPlayer.SetQQVipInfo(nVipStart, nVipEnd, nSvipStart, nSvipEnd);
	Sdk:CheckQQVipGreenReward(pPlayer);
	Sdk:CheckQQVipEverydayReward(pPlayer);
	return true;
end

function AssistClient:OnMsdkCommonRsp(szRspType, nPlayerId, szRetData)
	local szRspType, szExtra = string.match(szRspType, "([^:]*):?(.*)");
	if AssistClient[szRspType] then
		AssistClient[szRspType](self, nPlayerId, szRetData, szExtra);
	else
		Log("AssistClient:OnMsdkCommonRsp:ERROR unkown type:", szRspType);
		assert(false);
	end
end

function AssistClient:RankServerReport(pPlayer)
	local tbReportData = {
		Power = pPlayer.GetFightPower(),
		Level = pPlayer.nLevel,
		Name = pPlayer.szName,
		ServerId = GetServerIdentity(),
		PlayerId = pPlayer.dwID,
		VipType = pPlayer.GetQQVipInfo(),
		LaunchPlat = pPlayer.GetLaunchedPlatform(),
	};

	local szReportData = Lib:EncodeJson(tbReportData);
	AssistLib.RankServerCommonRequest(
		pPlayer.dwID,
		string.format("/report?openid=%s", pPlayer.szAccount),
		szReportData,"", "");
end

function AssistClient:RankServerQuery(pPlayer, szOpenIds)
	AssistLib.RankServerCommonRequest(pPlayer.dwID, "/query", szOpenIds, "OnRankInfoRsp", "")
end

function AssistClient:RankServerSendGift(pPlayer, szTargeOpenId, nServerId, nTargetPlayerId, szFriendName)
	AssistLib.RankServerCommonRequest(
		pPlayer.dwID,
		string.format("/gift?openid=%s&targetid=%s", pPlayer.szAccount, szTargeOpenId),
		tostring(nTargetPlayerId), "OnSendGiftRsp", string.format("%s,%d,%d,%s", szTargeOpenId, nServerId, nTargetPlayerId, szFriendName));
end

function AssistClient:UpdateGiftInfo(pPlayer)
	AssistLib.RankServerCommonRequest(
		pPlayer.dwID, string.format("/gift?openid=%s", pPlayer.szAccount),
		"", "OnGiftUpdate", "")
end

AssistClient.tbRankServerRspDealer = AssistClient.tbRankServerRspDealer or {};
local tbRankServerRspDealer = AssistClient.tbRankServerRspDealer;

function AssistClient:OnRankServerCommonRsp(szRspType, ...)
	if tbRankServerRspDealer[szRspType] then
		tbRankServerRspDealer[szRspType](tbRankServerRspDealer, ...);
	else
		Log("AssistClient:OnRankServerCommonRsp:ERROR unkown type:", szRspType);
		assert(false);
	end
end

function tbRankServerRspDealer:OnGiftUpdate(dwPlayerId, szRetInfo)
	local pPlayer = KPlayer.GetPlayerObjById(dwPlayerId);
	if not pPlayer then
		return;
	end

	Sdk:OnQueryRankInfoRsp(pPlayer, "gift", szRetInfo);
end

local tbRankSendGiftTips = {
	["not found"] = "對象不存在";
	["diff player"] = "贈送的玩家資訊與後臺不符, 請稍後再試";
	["max send"] = "今日的贈送次數達到上限";
	["has sent"] = "今日已對該好友進行了贈送";
}

function tbRankServerRspDealer:OnSendGiftRsp(dwPlayerId, szErrMsg, szExtra)
	Log("tbRankServerRspDealer:OnSendGiftRsp", dwPlayerId, szErrMsg, szExtra)
	local _, _, szTargeOpenId, nServerId, nTargetPlayerId, szFriendName = string.find(szExtra, "(.*),(%d+),(%d+),(.*)");
	nServerId = tonumber(nServerId);
	nTargetPlayerId = tonumber(nTargetPlayerId);

	local pPlayer = KPlayer.GetPlayerObjById(dwPlayerId);
	if szErrMsg ~= "succeed" then
		if pPlayer then
			pPlayer.CenterMsg(tbRankSendGiftTips[szErrMsg] or "贈送好友禮物時發生異常");
		end
		return false;
	end

	local tbNeighbourCmd = {};
	tbNeighbourCmd.szAction = "FriendGift";
	tbNeighbourCmd.szTargeOpenId = szTargeOpenId;
	tbNeighbourCmd.tbMail = {
		To = nTargetPlayerId,
		Title = "好友贈禮",
		Text = string.format("您的社交好友 %s 贈送了您一份禮物, 請在附件中查收.", szFriendName),
		From = "親朋榜",
		tbAttach = {{"Coin", 200}},
		nLogReason = Env.LogWay_FriendGift;
	};

	Transmit:DoNeighboureCmdRequest(dwPlayerId, nServerId, tbNeighbourCmd);
	if pPlayer then
		AssistClient:UpdateGiftInfo(pPlayer);
	end
end

function tbRankServerRspDealer:OnRankInfoRsp(dwPlayerId, szRankInfo)
	local pPlayer = KPlayer.GetPlayerObjById(dwPlayerId);
	if not pPlayer then
		return;
	end

	Sdk:OnQueryRankInfoRsp(pPlayer, "rank", szRankInfo);
end

function AssistClient:OnHttpCommonRsp(szRspType, nPlayerId, szRetData, szExtra)
	if szRspType == "WeixinLukybag" then
		Sdk:OnWeixinLuckyBagRsp(nPlayerId, szRetData, szExtra);
	elseif szRspType == "AddictionTip" then
		AddictionTip:OnHttpCommonRsp(nPlayerId, szRetData, szExtra);
	elseif szRspType == "DaojuBuyRsp" then
		Sdk:DaojuBuyRsp(nPlayerId, szRetData, szExtra);
	elseif szRspType == "XingGeNotify" then
		Log("AssistClient:OnHttpCommonRsp=========", szRspType, nPlayerId, szRetData, szExtra)
	else
		assert(false);
	end
end