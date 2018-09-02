
Transmit.tbEfunOperation = Transmit.tbEfunOperation or {};

Transmit.eEfunRetFlag_Sucee          = "1000"; -- 發送奖励成功
Transmit.eEfunRetFlag_Fail           = "1002"; -- 失败
Transmit.eEfunRetFlag_ParamEmpty     = "1003"; -- 傳入參數為空
Transmit.eEfunRetFlag_EncrypErr      = "1010"; -- 加密串不匹配
Transmit.eEfunRetFlag_NoReapted      = "1006"; --serialNo重複
Transmit.eEfunRetFlag_BagFull        = "1037"; --背包已满
Transmit.eEfunRetFlag_RoleNotFound   = "1038"; --该用户无此角色
Transmit.eEfunRetFlag_ServerNotFound = "1039"; --不存在的服务器id
Transmit.eEfunRetFlag_GiftNotFound   = "1034"; --不存在的礼包

function Transmit:OnEfunOperate(szOpType, szOpJson, nCmdSequence)
	if Transmit.tbEfunOperation[szOpType] then
		Transmit.tbEfunOperation[szOpType](Transmit, szOpJson, nCmdSequence);
	else
		Log("Unknow EfunOperate");
		Log(debug.traceback());

		local tbRet = {
			code = Transmit.eEfunRetFlag_Fail;
			message = "Unknow EfunOperate";
		};
		local szRetJson = Lib:EncodeJson(tbRet);
		TransLib.DoEfunOperateRespond(nCmdSequence, szRetJson);
	end
end

Transmit.tbEfunRewardSeriaNo = Transmit.tbEfunRewardSeriaNo or {};
-- 127.0.0.1:8088/efunsendreward?userId=1&roleId=1049708&serverCode=20001&serialNo=1&packageId=Gold,1000;item,1024,2&title=你好&content=啦啦啦
function Transmit.tbEfunOperation:SendRewardMail(szOpJson, nCmdSequence)
	local tbOp = Lib:DecodeJson(szOpJson);
	local nRoleId = tonumber(tbOp.roleId) or 0;
	local tbRoleStayInfo = KPlayer.GetRoleStayInfo(nRoleId);
	if not tbRoleStayInfo then
		TransLib.DoEfunOperateRespond(nCmdSequence, [[{"code":"1038","message":"role not found"}]]);
		return;
	end

	if self.tbEfunRewardSeriaNo[tbOp.serialNo] then
		TransLib.DoEfunOperateRespond(nCmdSequence, [[{"code":"1006","message":"serialNo Repeated!"}]]);
		return;
	end

	local tbAttach = {};
	local tbItems = Lib:SplitStr(tbOp.packageId, ";");
	for _, szItem in pairs(tbItems) do
		local szType, szParam1, szParam2 = string.match(szItem, "(%w+),(%d+),?(%d*)");
		local nP1, nP2 = tonumber(szParam1) or 0, tonumber(szParam2) or 0;
		if nP1 > 0 then
			if nP2 > 0 then
				table.insert(tbAttach, {szType, nP1, nP2});
			else
				table.insert(tbAttach, {szType, nP1});
			end
		end
	end

	local tbMail = {
		To = nRoleId;
		Title = tbOp.title;
		Text = tbOp.content;
		From = "運營平臺";
		tbAttach = tbAttach;
		nLogReazon = Env.LogWay_EfunAttachMail;
	};
	Mail:SendSystemMail(tbMail);
	self.tbEfunRewardSeriaNo[tbOp.serialNo] = true;
	TransLib.DoEfunOperateRespond(nCmdSequence, [[{"code":"1000","message":"send mail succeed"}]]);
	Log("EfunOperate SendSystemMail", tbOp.serialNo, tbOp.userId, tbOp.roleId, tbRoleStayInfo.szName, tbOp.packageId);
end

local SERVER_ID = Sdk:GetServerId();

function Transmit.tbEfunOperation:QueryRoleList(szAccount, nCmdSequence)
	if Sdk:IsEfunHKTW() then
		szAccount = "efun__" .. szAccount;
	elseif version_xm then
		szAccount = "efunae__" .. szAccount;
	end
	Player:DoAccountRoleListRequest(szAccount, Transmit.tbEfunOperation.OnQueryRoleList, Transmit.tbEfunOperation, nCmdSequence)
end

function Transmit.tbEfunOperation:OnQueryRoleList(szAccount, tbRoleList, nCmdSequence)
	local tbRet = {
		code = Transmit.eEfunRetFlag_Sucee;
		list = {};
	};

	for _, tbInfo in pairs(tbRoleList or {}) do
		table.insert(tbRet.list, {
			roleid = tbInfo.dwID;
			name = tbInfo.szName;
			level = tbInfo.nLevel;
			subgame = SERVER_ID;
		});
	end

	if not next(tbRoleList) then
		tbRet.code = Transmit.eEfunRetFlag_RoleNotFound;
	end

	local szRetJson = Lib:EncodeJson(tbRet);
	TransLib.DoEfunOperateRespond(nCmdSequence, szRetJson);
end

