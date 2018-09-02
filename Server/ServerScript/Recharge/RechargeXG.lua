Require("ServerScript/Recharge/Recharge.lua")

if not Sdk:IsXgSdk() then
	function Recharge:OnStartup() end;
	function Recharge:Activate(nTimeNow) end;
	return
end

function Recharge:OnStartup()
	--将之前的订单号生成时间推迟往后, 接受go的请求
	-- local tbTradeNo = ScriptData:GetValue("TradeNo")
	-- local nTimeNow = GetTime()
	-- for szTradeNo, v in pairs(tbTradeNo) do
	-- 	tbTradeNo[szTradeNo] = nTimeNow
	-- end
	-- ScriptData:AddModifyFlag("TradeNo")
end

--请求充值对应rmb
function Recharge:RequestRecharge(pPlayer, szProductId)
	if not self:CanBuyProduct(pPlayer, szProductId) then
		return
	end
	self:DoRequest(pPlayer, szProductId)
end

Recharge.nTradeNoIndex = 0
--发起充值客户端成功会申请检查锁定，如没发奖会锁定，只有充值发奖处理后，充值超时2个情况下解锁, 避免重复周卡月卡一本万利
Recharge.tbTradeLockRoles = {}
Recharge.tbTradeNoInfo = Recharge.tbTradeNoInfo or {};

Recharge.RequestCDTime = 10;
--目前每种类型，每个额度对应唯一的 szProductId
function Recharge:DoRequest(pPlayer, szProductId)
	local nLastRechargeRequestTime = pPlayer.nLastRechargeRequestTime or 0;
	local nNow = GetTime()
	if nLastRechargeRequestTime + self.RequestCDTime > nNow then
		pPlayer.CenterMsg(string.format("請等%s後再嘗試", Lib:TimeDesc(nLastRechargeRequestTime + self.RequestCDTime - nNow)))
		return
	end

	local dwRoleId = pPlayer.dwID
	local nTradeTimeOut = self.tbTradeLockRoles[dwRoleId]
	if nTradeTimeOut then
		pPlayer.CenterMsg("目前還處於儲值狀態中，請稍後")
		return
	end

	if not IsGoServerConnected() then
		pPlayer.CenterMsg("儲值系統異常，請與GM聯繫")
		return
	end

	local tbBuyInfo = self.tbProductionSettingAll[szProductId]
	if not tbBuyInfo then
		return
	end
	local nGetGold = self:CheckBuyGoldGetNum(szProductId)

	self.nTradeNoIndex = self.nTradeNoIndex + 1
	local szTradeNo = string.format("%d_%d_%d", dwRoleId, nNow, self.nTradeNoIndex)

	-- local tbTradeNo = ScriptData:GetValue("TradeNo")
	self.tbTradeNoInfo[szTradeNo] = {nNow, pPlayer.szAccount, pPlayer.szChannelCode, pPlayer.nPlatform, nGetGold, pPlayer.szIP, pPlayer.szEquipId}
	-- tbTradeNo[szTradeNo] = nNow

	-- ScriptData:AddModifyFlag("TradeNo")

	local nServerId = Sdk:GetServerId();
	local tbMoneyInfo = Recharge.tbMoneyName[tbBuyInfo.szMoneyType] --sdk 使用分为单位
	pPlayer.CallClientScript("Sdk:XGPay", nServerId, szProductId, tbBuyInfo.szDesc, tbBuyInfo.nMoney * tbMoneyInfo[4] * 100 , tbBuyInfo.szMoneyType, szTradeNo)
	pPlayer.nLastRechargeRequestTime = nNow
	Log("Recharge:DoRequest", dwRoleId, szProductId, tbBuyInfo.szDesc, tbBuyInfo.nMoney, tbBuyInfo.szMoneyType, szTradeNo)
end

function Recharge:IsPlatformPay(tbPayInfo)
	if version_xm or version_hk or version_tw then
		return tbPayInfo.payType == "PlatformPay";
	elseif version_vn then
		return tbPayInfo.payType == "PlatformPay" or tbPayInfo.payType == "wallet";
	elseif version_th then
		return type(tbPayInfo.payType) == "string" and string.match(tbPayInfo.payType, "PlatformPay.*");
	end

	return false;
end


function Recharge:OnResponse(tbPayInfo)
	if Recharge:IsPlatformPay(tbPayInfo) then
		return self:OnThirdResponse(tbPayInfo)
	else
		return self:OnBuyProductResponse(tbPayInfo)
	end
end

function Recharge:OnThirdResponse(tbPayInfo)
	local dwRoleId = tonumber(tbPayInfo.roleId) 
	local szProductId = tbPayInfo.productId
	local paidAmount = tonumber(tbPayInfo.paidAmount) 
	local currencyName = tbPayInfo.currencyName
	local paramGetGoldNum;
	if version_xm then --只有新马的第三方支付是取得直接对应元宝数，不过也是有额外赠送比率的
		paramGetGoldNum = tonumber(tbPayInfo.productQuantity); -- 新马的直接传获得对应元宝数
	end
	if Lib:IsEmptyStr(currencyName) or not paidAmount or not dwRoleId then
		Log("Error OnThirdResponse==", currencyName, paidAmount)
		return false, "Error ThirdRes Money Param"
	end

	local nRate = self.tbMoneyRMBRate[currencyName]
	if not nRate then
		return false, "Error has not currencyName " .. currencyName
	end

	if not self.tbMoneyThirdRate[currencyName] then
		return false, "Error has not ThirdRate currencyName " .. currencyName
	end

	local tbMoneyInfo = Recharge.tbMoneyName[currencyName] 
	if not tbMoneyInfo then
		return false, "Error has not currencyName3 " .. currencyName
	end

	local nMoney = paidAmount /100 / (tbMoneyInfo[4]) ; --传过来的都是以分为单位，但后面的都是以存盘值为单位

	if not Lib:IsEmptyStr(szProductId) then
		local tbBuyInfo = self.tbProductionSettingAll[szProductId]
		if not tbBuyInfo then
			Log(debug.traceback(), szProductId)
			return  false, "Error Third ProductId"
		end
	end

	local bOK, bRet, szMsg = Lib:CallBack({ self.PayCallBack, self, true, dwRoleId, szProductId or "", nMoney or 0, currencyName or "", paramGetGoldNum or 0, tbPayInfo.payType or ""} );
	Log("Recharge:OnResponse Call_result", tostring(bOK), tostring(bRet), dwRoleId, szProductId, "", tbPayInfo.payType)
	
	if bOK then
		return bRet, szMsg
	else
		return false, bRet
	end
end

function Recharge:OnBuyProductResponse(tbPayInfo)
	local szProductId = tbPayInfo.productId
	local szTradeNo = tbPayInfo.gameTradeNo
	if not szProductId or not szTradeNo then
		return false, "Error ProductId or TradeNo"
	end
	local _, _, dwRoleId, nRequestTime, nNoIndex = string.find(szTradeNo, "^(%d+)_(%d+)_(%d+)$")
	dwRoleId = tonumber(dwRoleId)
	if not dwRoleId or not nRequestTime or not nNoIndex then
		Log("Recharge:OnResponse ERROR_on_szTradeNo", szProductId, szTradeNo)
		return false, "Error TradeNo"
	end

	local tbProdInfo = self.tbProductionSettingAll[szProductId];
	if not tbProdInfo then
		Log("Recharge:OnResponse ERROR_on_szProductId", szProductId, szTradeNo)
		return false, "Error ProductId"
	end
	-- local tbTradeNo = ScriptData:GetValue("TradeNo")
	-- if not tbTradeNo[szTradeNo] then
	-- 	Log("Recharge:OnResponse InValid TradeNo or Processed", szProductId, szTradeNo)
	-- 	return false, "not exist TradeNo"
	-- end
	if not self.tbTradeNoInfo[szTradeNo] then
		Log("Recharge:OnResponse InValid TradeNo2 or Processed", szProductId, szTradeNo)
		-- return false, "not exist TradeNo2"
	end

	self:RechargeRequestUnlock(dwRoleId)
	-- local _, szAccount, szChannelCode, nPlatform, nGetGold, szIP, szEquipId = unpack(self.tbTradeNoInfo[szTradeNo]) --可能空
	-- tbTradeNo[szTradeNo] = nil; 	--因为付费那边有可能同个订单发多次回应,保证只处理一次
	self.tbTradeNoInfo[szTradeNo] = nil;
	-- ScriptData:AddModifyFlag("TradeNo")
	local bOK, bRet, szMsg = Lib:CallBack({ self.PayCallBack, self, true, dwRoleId, szProductId } );
	--TODO 如果不记录这些就去掉 tbTradeNoInfo 里别的信息
	-- LogD(Env.LOGD_RechargeGetGold, szAccount, dwRoleId, szChannelCode, nPlatform, (bRet and nGetGold or 0), szIP, tbProdInfo.nMoney, nil, szEquipId);

	if not bRet then
		Mail:SendSystemMail({
			To = dwRoleId,
			Text = "很抱歉，您的儲值資訊有誤導致獎勵發放失敗，請與GM客服聯繫",
			})
	end
	Log("Recharge:OnResponse Call_result", tostring(bOK), tostring(bRet), dwRoleId, szProductId, szTradeNo, tbPayInfo.payType)
	if bOK then
		return bRet, szMsg
	else
		return false, bRet
	end
end

function Recharge:RechargeRequestUnlock(dwID)
	self.tbTradeLockRoles[dwID] = nil;
end

--todo SDK调用了以后调用
function Recharge:RechargeRequestlock(dwRoleId, szTradeNo)
	if not self.tbTradeNoInfo[szTradeNo] then
		return
	end

	local _, _, dwRequestRoleId, nRequestTime, nNoIndex = string.find(szTradeNo, "^(%d+)_(%d+)_(%d+)$")
	if dwRequestRoleId ~= dwRoleId then
		Log("Recharge:RechargeRequestlock ERROR ROLE_ID", dwRoleId, dwRequestRoleId, szTradeNo )
		return
	end

	self.tbTradeLockRoles[dwRoleId] = GetTime()
end

function Recharge:Activate(nTimeNow)
	for dwRoleId, nLockTime in pairs(self.tbTradeLockRoles) do
		if nTimeNow - nLockTime > 1200 then
			Recharge:RechargeRequestUnlock(dwRoleId)
			Log("Recharge:Activate DelLockTimeOut", dwRoleId, nLockTime)
		end
	end

	-- local tbTradeNo = ScriptData:GetValue("TradeNo")
	for szTradeNo, v in pairs(self.tbTradeNoInfo) do
		if nTimeNow - v[1] > 7200 then --订单号超时时间2小时
			-- tbTradeNo[szTradeNo] = nil;
			self.tbTradeNoInfo[szTradeNo] = nil;
			Log("Recharge:Activate DelTimeOut",  szTradeNo)
		end
	end

	-- ScriptData:AddModifyFlag("TradeNo")
end

function Recharge:DirPayBack(dwRoleId, szProductId)
	local tbProdInfo = self.tbProductionSettingAll[szProductId];
	if not tbProdInfo then
		Log("Recharge:DirPayBack ERROR_on_szProductId", szProductId, dwRoleId)
		return false, "Error ProductId Dir"
	end
	local bOK, bRet, szMsg = Lib:CallBack({ self.PayCallBack, self, true, dwRoleId, szProductId } );
	Log("Recharge:DirPayBack Call_result", bOK, bRet, dwRoleId, szProductId)
	return bRet, szMsg
end

function Recharge:OnDelayCmd(szProductId, nMoney, szMoneyType, paramGetGoldNum, payType)
	local nMoney = tonumber(nMoney) or 0
	local paramGetGoldNum = tonumber(paramGetGoldNum) or 0
	local bOK, bRet = Lib:CallBack({ self.BuyScucessCallBack, self, me, szProductId, nMoney, szMoneyType, paramGetGoldNum, payType } );
	Log("Recharge:OnDelayCmd", bOK, bRet, me.dwID, szProductId, nMoney, szMoneyType)
end

--目前假定必定会回调回来，不然的话做个超时检查处理
function Recharge:PayCallBack(bResult, dwRoleId, szProductId, nMoney, szMoneyType, paramGetGoldNum, payType)
	szProductId = szProductId or "";
	nMoney = nMoney or 0
	szMoneyType = szMoneyType or ""
	paramGetGoldNum = paramGetGoldNum or 0
	payType = payType or "";
	local pPlayer = KPlayer.GetPlayerObjById(dwRoleId)
	if not bResult then
		if pPlayer then
			pPlayer.CenterMsg("抱歉儲值失敗了")
		end
		return false, "bResult FALSE"
	end

	if pPlayer then
		self:BuyScucessCallBack(pPlayer, szProductId, nMoney, szMoneyType, paramGetGoldNum, payType)
	else
		local szCmd = string.format("Recharge:OnDelayCmd('%s', '%s', '%s', '%s', '%s')", szProductId, nMoney, szMoneyType, paramGetGoldNum, payType) 
		KPlayer.AddDelayCmd(dwRoleId, szCmd, string.format("%s|%s|%s|%s|%s", "RechargeDelay", szProductId, nMoney, szMoneyType, paramGetGoldNum, payType));
		Log("Recharge:PayCallBack Player Offline add", dwRoleId, szProductId, nMoney, szMoneyType, paramGetGoldNum, payType)
	end
	return true
end

function Recharge:CallBack_BuyGold(pPlayer, tbInfo)
end

function Recharge:CallBack_ThirdBuyGold(pPlayer, tbInfo, nMoney, szMoneyType, paramGetGoldNum, payType)
	local nFlag = 1;
	if version_th and payType and self.tbMoneyThirdRatePlatform[payType] then
		nFlag = self.tbMoneyThirdRatePlatform[payType]
	end
	local nAddGold = nMoney * Recharge.tbMoneyThirdRate[szMoneyType]*nFlag
	if version_th then
		nAddGold = math.floor(nAddGold)
	else
		nAddGold = math.ceil(nAddGold) 
	end
	pPlayer.SendAward({{"Gold", nAddGold}}, true, nil, Env.LogWay_Recharge, nMoney)
	Log(string.format("Recharge:Sucess BuyGoldThird id:%d, nMoney:%d, nAddGold:%d, szMoneyType:%s", pPlayer.dwID, nMoney, nAddGold, szMoneyType), payType)
end

function Recharge:CallBack_ThirdBuyGoldXM(pPlayer, tbInfo, nMoney, szMoneyType, paramGetGoldNum)
	local nAddGold = math.floor(paramGetGoldNum * Recharge.THIRD_GET_GOLD_RATE) 
	pPlayer.SendAward({{"Gold", nAddGold}}, true, nil, Env.LogWay_Recharge, nMoney)
	Log(string.format("Recharge:Sucess CallBack_ThirdBuyGoldXM id:%d, nMoney:%d, nAddGold:%d, szMoneyType:%s, paramGetGoldNum:%d", pPlayer.dwID, nMoney, nAddGold, szMoneyType, paramGetGoldNum))
end

function Recharge:CallBack_BuyGoldServer(pPlayer, tbInfo)
	pPlayer.SendAward(tbInfo.tbAward, true, false, Env.LogWay_Recharge, tbInfo.nMoney)
	pPlayer.CallClientScript("Recharge:OnRechargeGoldScucess", tbInfo.nMoney, tbInfo.tbAward)
	self:AddTotalCardRecharge(pPlayer, tbInfo.nMoney)
	Log(string.format("Recharge:Sucess CallBack_BuyGoldServer id:%d, ProductId:%s", pPlayer.dwID, tbInfo.ProductId))
end

function Recharge:CallBack_DaysCard(pPlayer, tbInfo)
	local nLocalEndTime = pPlayer.GetUserValue(Recharge.SAVE_GROUP, tbInfo.nEndTimeKey)
	local nNow = GetTime()
	if nLocalEndTime < nNow then
		nLocalEndTime = nNow
	end
	local nNewEndTime = nLocalEndTime + 3600 * 24 * tbInfo.nLastingDay
	self:OnBuyDaysCardCallBack(pPlayer, nNewEndTime, tbInfo.nGroupIndex)
end

function Recharge:CallBack_GrowInvest(pPlayer, tbInfo)
	Recharge:OnBuyInvestCallBack(pPlayer, tbInfo.nGroupIndex)
end

function Recharge:CallBack_DayGift(pPlayer, tbInfo)
	local nLocalEndTime = pPlayer.GetUserValue(Recharge.SAVE_GROUP, tbInfo.nEndTimeKey)
	self:OnBuyOneDayCardCallBack(pPlayer, nLocalEndTime + 3600 * 24, tbInfo.nGroupIndex)
end

function Recharge:CallBack_YearGift(pPlayer, tbInfo)
	local nLocalEndTime = pPlayer.GetUserValue(Recharge.SAVE_GROUP, tbInfo.nEndTimeKey)
	local nNow = GetTime()
	if nLocalEndTime < nNow then
		nLocalEndTime = nNow
	end
	local nNewEndTime = nLocalEndTime + 3600 * 24 * tbInfo.nLastingDay
	self:OnBuyYearCardCallBack(pPlayer, nNewEndTime, tbInfo.nGroupIndex)
end

function Recharge:CallBack_DressMoney(pPlayer, tbInfo)
	self:AddTotalCardRecharge(pPlayer, tbInfo.nMoney)
	pPlayer.SendAward(tbInfo.tbAward , nil, nil, Env.LogWay_BuyDressMoney)
	Log("Recharge:Sucess CallBack_DressMoney ", pPlayer.dwID, tbInfo.ProductId)
end

function Recharge:CallBack_BackGift(pPlayer, tbInfo)
	local nLocalEndTime = pPlayer.GetUserValue(Recharge.SAVE_GROUP, tbInfo.nEndTimeKey)
	local nNow = GetTime()
	if nLocalEndTime < nNow then
		nLocalEndTime = nNow
	end
	local nNewEndTime = nLocalEndTime + 3600 * 24 * tbInfo.nLastingDay
	self:OnBuyBackGiftCallBack(pPlayer, nNewEndTime, tbInfo.nGroupIndex)
end

function Recharge:CheckChangeBuyGold(pPlayer, nMoney, szMoneyType)
	if not version_th then
		return
	end
	if szMoneyType ~= self.szDefMoneyType then
		return
	end
	if not self.tbBuyGoldMoneyKey then
		self.tbBuyGoldMoneyKey = {};
		for i,v in ipairs(Recharge.tbSettingGroup.BuyGold) do
			self.tbBuyGoldMoneyKey[v.nMoney] = i;
		end
	end
	local nIndex = self.tbBuyGoldMoneyKey[nMoney]
	if not nIndex then
		return
	end
	local nBuyedFlag = Recharge:GetBuyedFlag(pPlayer);
	local tbBit = KLib.GetBitTB(nBuyedFlag)
	if tbBit[nIndex] == 1 then
		return
	end
	return true;
end

function Recharge:ProcesseCallBack(pPlayer, tbBuyInfo, nMoney, szMoneyType, paramGetGoldNum, payType)
	local szFuncCallBack;
	local nGoldRMB, nCardRMB;
	if tbBuyInfo then
		local szGroup = tbBuyInfo.szGroup
		if szGroup == "BuyGold" then
			nGoldRMB = self:GetTotoalRechargeGold(pPlayer) + tbBuyInfo.nMoney
		end
		szFuncCallBack = "CallBack_" .. szGroup	
	elseif nMoney and szMoneyType then
		if self:CheckChangeBuyGold(pPlayer, nMoney, szMoneyType) then
			nGoldRMB = self:GetTotoalRechargeGold(pPlayer) + nMoney
			szFuncCallBack = "CallBack_BuyGold"
		else
			local szMoneyTypeDef = self.tbSettingGroup.BuyGold[1].szMoneyType
			local nNewCardRMB = 0;
			if szMoneyType == szMoneyTypeDef then
				nNewCardRMB = nMoney
			else
				nNewCardRMB = nMoney * self.tbMoneyRMBRate[szMoneyType] / self.tbMoneyRMBRate[szMoneyTypeDef]
			end

			if paramGetGoldNum  and  paramGetGoldNum > 0 then
				szFuncCallBack = "CallBack_ThirdBuyGoldXM"	
			else
				szFuncCallBack = "CallBack_ThirdBuyGold"	
			end
			nCardRMB = pPlayer.GetUserValue(self.SAVE_GROUP, self.KEY_TOTAL_CARD) + nNewCardRMB	
		end
	end

	local fnCallBack = self[szFuncCallBack];-- tbBuyCallBackSetting[szType]
	fnCallBack(self, pPlayer, tbBuyInfo, nMoney, szMoneyType, paramGetGoldNum, payType)
	if nGoldRMB or nCardRMB then --直接 tbBuyInfo 里的回调是有掉 OnTotalRechargeChange 的
		self:OnTotalRechargeChange(pPlayer, nGoldRMB, nCardRMB)		
	end
end

function Recharge:BuyScucessCallBack(pPlayer, szProductId, nMoney, szMoneyType, paramGetGoldNum, payType)
	-- 这里拆分处理 --只有第三方支付会传szMoneyType
	nMoney = nMoney or 0;
	if not Lib:IsEmptyStr(szProductId) then
		local tbBuyInfo = self.tbProductionSettingAll[szProductId]
		if  Recharge:CanBuyProduct(pPlayer, szProductId) then --能够买就买然后去掉折算的钱数
			self:ProcesseCallBack(pPlayer, tbBuyInfo)
			if not Lib:IsEmptyStr(szMoneyType)  then
				--港台 第三方购买周月卡和基金时是没有对超额部分做元宝兑换的
				if tbBuyInfo.szGroup == "DaysCard" or tbBuyInfo.szGroup == "GrowInvest" then 
					nMoney = 0;
				else
					if Sdk:IsEfunHKTW() then --只有港台超额处理
						local nRate = self.tbMoneyRMBRate[szMoneyType]
						nMoney = math.ceil((nMoney * nRate - tbBuyInfo.nMoney * self.tbMoneyRMBRate[tbBuyInfo.szMoneyType]) / nRate - 0.00001) --浮点运算再用math.ceil有可能会多1
					else
						nMoney = 0;
					end
				end
			end
		elseif Lib:IsEmptyStr(szMoneyType)  then --只传产品购买失败的情况
			nMoney = tbBuyInfo.nMoney
			szMoneyType = tbBuyInfo.szMoneyType
		end	
	end

	if nMoney > 0 and not Lib:IsEmptyStr(szMoneyType)  then
		self:ProcesseCallBack(pPlayer, nil, nMoney, szMoneyType, paramGetGoldNum, payType)
	elseif nMoney < 0 then
		Log("Recharge:BuyScucessCallBackErr0", pPlayer.dwID, szProductId, nMoney, szMoneyType, paramGetGoldNum)
	end
end
