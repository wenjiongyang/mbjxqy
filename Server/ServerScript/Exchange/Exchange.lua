
function Exchange:AskItem(pPlayer, szType, ...)
	local tbSetting = self.tbExchangeSetting[szType];
	if not tbSetting then
		return
	end

	pPlayer.tbExchangeCallBack	= {...};
	pPlayer.szExchangeType = szType

	if not Lib:IsEmptyStr(tbSetting.CheckFunSever) then
		local fnFunc = self[tbSetting.CheckFunSever]
		if not fnFunc(self, pPlayer) then
			return
		end
	end

	pPlayer.CallClientScript("Ui:OpenWindow", "ExchangePanel", szType)
end

function Exchange:ConfirmExchange(pPlayer, tbItems)
	local tbExchangeCallBack = pPlayer.tbExchangeCallBack
	local szExchangeType = pPlayer.szExchangeType

	if not tbExchangeCallBack or not szExchangeType  then
		Log(debug.traceback())
		return
	end

	local tbSetting = self.tbExchangeSetting[szExchangeType];

	if not Lib:IsEmptyStr(tbSetting.CheckFunSever) then
		local fnFunc = self[tbSetting.CheckFunSever]
		if not fnFunc(self, pPlayer) then
			return
		end
	end

	local oldme = me;
	me = pPlayer;
	table.insert(tbExchangeCallBack, tbItems);
	Lib:CallBack(tbExchangeCallBack);
	me = oldme;

	table.remove(tbExchangeCallBack, #tbExchangeCallBack);
end
