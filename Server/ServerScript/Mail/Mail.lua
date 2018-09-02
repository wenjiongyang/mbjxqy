Require("ServerScript/Kin/Kin.lua")
local nRecyleTimeAttach   = 30 * 24 * 3600 --有附件的最大保留时间
local nRecyleTimeNoAttach = 1 * 24 * 3600 --没附件的最大保留时间
local nKinRecyleTime 	  = 3 * 24 * 3600 --家族邮件的保留时间
local nMaxTitleLen = 31; --标题和邮件的最大char长度

local Requests = Requests or {}; --等待获取邮箱的请求


local PostRequest = function (dwRoleId, fnCallback, ...)
	local mail_box = KMail.GetMailBox(dwRoleId);
	if mail_box then
		fnCallback(mail_box, ...);
		return;
	end

	local nID = KMail.GetRequestID(dwRoleId);
	local tbData = Lib:CopyTB({...}) --因为可能发邮件接口调用对 tbMail 又做了修改，导致之前的邮件内容被修改
	Requests[nID] = {dwRoleId, fnCallback, tbData};
end
Mail.PostRequest = PostRequest;

--找到邮箱后发送邮件的回调
local function OnSendSystemMail(mail_box, tbMail)
	local bHasAttach = false;
	local nRecyleTime = nRecyleTimeNoAttach
	if tbMail.tbAttach and next(tbMail.tbAttach) then
		bHasAttach = true;
		nRecyleTime = nRecyleTimeAttach;
	end
	if tbMail.nRecyleTime then
		nRecyleTime = tbMail.nRecyleTime;
	end

	local tbSaveData = {
		Text = tbMail.Text or "",
		bNotAutoDelete = true;
	}
	if tbMail.nLogReazon then
		tbSaveData.nLogReazon = tbMail.nLogReazon
	end
	if bHasAttach then
		tbSaveData.tbAttach = tbMail.tbAttach;
	end
	local logReason2 = 0;
	if tbMail.tbParams then
		tbSaveData.tbParams = tbMail.tbParams;
		logReason2 = tbSaveData.tbParams.LogReason2 or 0;
	end
	local Title = tbMail.Title or "系統信件";
	local nStrLen = string.len(Title); --邮件里最长是 32
	if nStrLen > nMaxTitleLen then
		Title = Lib:CutUtf8(Title, nil, nMaxTitleLen - 3) .. "...";
	end
	local From = tbMail.From or ""
	local nStrLen = string.len(From); --邮件里最长是 32
	if nStrLen > nMaxTitleLen then
		From = Lib:CutUtf8(From, nil, nMaxTitleLen - 3) .. "...";
	end

	local dwMailId = mail_box.Send(Title, From, bHasAttach, nRecyleTime, tbSaveData, tbMail.LevelLimit);
	if bHasAttach then
		local dwRoleId = mail_box.dwID
		local szGameAppid, nPlat, nServerIdentity, nAreaId = GetWorldConfifParam()
		local szAcc = "";
		if dwRoleId ~= 0 then
			szAcc = KPlayer.GetPlayerAccount(dwRoleId) or ""
		end
		for i,v in ipairs(tbSaveData.tbAttach) do
			local szAwardType,nParam1,nParam2,nParam3 = unpack(v);
			TLog("MailFlow", szGameAppid, nPlat, nServerIdentity, szAcc, dwRoleId, dwMailId, tbSaveData.nLogReazon or 0, logReason2, Player.AwardType[szAwardType], nParam1 or 0, nParam2 or 0, nParam3 or 0,0);
		end	
	end
end

local function OnSendKinMail(mail_box, tbMail)
	local tbSaveData = {
		Text = tbMail.Text or "",
		bNotAutoDelete = true,
	}
	mail_box.Send(tbMail.Title or "幫派信件", tbMail.From or "", false, nKinRecyleTime, tbSaveData);
end

local function SyncMailCount(mail_box)
	mail_box.SyncMailCount();
end

--请求邮箱数据
local function OnRequestMailData(mail_box, nSelfLoadIndex)
	local pPlayer = KPlayer.GetPlayerObjById(mail_box.dwID)
	if not pPlayer then
		return
	end
	mail_box.SyncMailCount();
	local tbMails = mail_box.GetMailList(nSelfLoadIndex) --直接一次同步完吧
	pPlayer.CallClientScript("Mail:OnSyncMailData", tbMails,  #tbMails > 0 and tbMails[#tbMails].ID or mail_box.dwLastMailID)
end

local function OnRecordReadMails(mail_box, dwMailId, bAutoDelete)
	mail_box.SetRead(dwMailId, bAutoDelete)

end

local function OnTakeMailAttach(mail_box, nMailId)
	mail_box.TakeAttach(nMailId)
end

local function OnGetPLayerMailListInfo(mail_box,callBackInfo)
	local nSelfLoadIndex = 0
	local tbAllMails = {}
	for i=1,10 do
		local tbMails = mail_box.GetMailList(nSelfLoadIndex)
		if not next(tbMails) then
			break;
		end
		nSelfLoadIndex = tbMails[#tbMails].ID
		for _,v in ipairs(tbMails) do
			table.insert(tbAllMails, v)
		end
	end

    if callBackInfo and callBackInfo.fnCallBack then
        local function fnExc()
            if callBackInfo.callObj then
                 callBackInfo.fnCallBack(callBackInfo.callObj, tbAllMails, unpack(callBackInfo.param))
            else
                 callBackInfo.fnCallBack(tbAllMails, unpack(callBackInfo.param))
            end
        end
        xpcall(fnExc, Lib.ShowStack);
    end

	return tbAllMails;
end

local function OnDeleteAllMail(mail_box)
	local dwRoleId = mail_box.dwID
	mail_box.DeleteAll();
	mail_box.SyncMailCount();

	local pPlayer = KPlayer.GetPlayerObjById(dwRoleId)
	if pPlayer then
		pPlayer.CallClientScript("Mail:OnDeleteAllMail", mail_box.dwLastMailID)	
	end
	Log("OnDeleteAllMail", dwRoleId)
end

local function OnDeleteOneMail(mail_box, nMailId)
	local dwRoleId = mail_box.dwID
	if not mail_box.DeleteOneMail(nMailId) then
		Log("OnDeleteOneMail Fail", dwRoleId, nMailId)	
		return
	end

	mail_box.SyncMailCount();

	local pPlayer = KPlayer.GetPlayerObjById(dwRoleId)
	if pPlayer then
		pPlayer.CallClientScript("Mail:RemoveOneMail", nMailId)	
	end
	Log("OnDeleteOneMail scucess", dwRoleId, nMailId)	
end


--[[
tbMail:
{
	To = "角色名" | RoleID,
	Title = "标题", 默认 "系统邮件"
	Text = "内容",  默认 ""
	From = "发件人",默认 ""
	tbAttach = {   --附件，不发传空， 写法和SendAward中一样
		{"item", 		110, 		1, 				GetTime() + 60},
		{"Coin",		100},
	},
	nLogReazon = Env.LOGD_MIS_QUESTION, --可选
	tbParams ... 可选字段 --都会存到 tbSaveData里了
	nRecyleTime = 3600 --如果指定了过期时间则用对应过期时间,否则用系统默认
}
--]]
function Mail:SendSystemMail(tbMail)
	local role = KPlayer.GetRoleStayInfo(tbMail.To)
	if not role then
		return
	end
	PostRequest(role.dwID, OnSendSystemMail, tbMail)
end

--[[
tbMail:
{
	Title = "标题", 默认 "系统邮件"
	Text = "内容",  默认 ""
	From = "发件人",默认 ""
	LevelLimit = 0, 默认 0  -- 等级限制（只有大于等于这个等级的玩家能收到这封邮件）
	tbAttach = {   --附件， 和SendAward中一样
		{"item", 		110, 		1, 				GetTime() + 60},
		{"Coin",		100},
	},
}
--]]
function Mail:SendGlobalSystemMail(tbMail)
	tbMail.LevelLimit = tbMail.LevelLimit or 0;
	PostRequest(0, OnSendSystemMail, tbMail);
	local LevelLimit = tbMail.LevelLimit
	local tbPlayer = KPlayer.GetAllPlayer();
	for i, player in ipairs(tbPlayer) do
		if player.nLevel >= LevelLimit then
			Mail:SyncMailCount(player)
		end
	end
end

--[[
tbMail:
{
	KinId = 0
	Text = "内容",  默认 ""
	From = "发件人" 默认 ""
}
--]]
function Mail:SendKinMail(tbMail)
	local KinId = tbMail.KinId
	if not KinId or KinId == 0 then
		return
	end
	local tbKin = Kin:GetKinById(KinId)
	if not tbKin then
		return
	end

	local tbAllMembers = Kin:GetKinMembers(KinId)
	for dwRoleId, v in pairs(tbAllMembers) do
		PostRequest(dwRoleId, OnSendKinMail, tbMail)
	end
end

function Mail:SyncMailCount(pPlayer)
 	PostRequest(pPlayer.dwID, SyncMailCount)
 end

function Mail:GetMailRespond(nID, mail_box)
	local tbRequestInfo = Requests[nID];
	if not tbRequestInfo then
		return;
	end
	local _, fnCallback, Params = unpack(tbRequestInfo);
	fnCallback(mail_box, unpack(Params));
	Requests[nID] = nil;
end

function Mail:RequestMailData(pPlayer, nSelfLoadIndex)
	PostRequest(pPlayer.dwID, OnRequestMailData, nSelfLoadIndex)
end

function Mail:RecordReadMails(pPlayer, dwMailId, bAutoDelete)
	PostRequest(pPlayer.dwID, OnRecordReadMails, dwMailId, bAutoDelete)
end

function Mail:TakeMailAttach(pPlayer, nMailId)
	PostRequest(pPlayer.dwID, OnTakeMailAttach, nMailId)
end

function Mail:GetPLayerMailListInfo(dwRoleId, fnCallBack, callObj, ...)
		local callBackInfo =
    {
        fnCallBack = fnCallBack,
        callObj = callObj,
        param = {...},
    }

	PostRequest(dwRoleId, OnGetPLayerMailListInfo,callBackInfo)
end

function Mail:PlayerTakeAttach(pPlayer, tbSaveData, nMailId)
	local logReason2 = nil;
	if tbSaveData.tbParams then
		logReason2 = tbSaveData.tbParams.LogReason2
	end
	pPlayer.SendAward(tbSaveData.tbAttach, nil, nil, tbSaveData.nLogReazon or Env.LogWay_TakeMailAttach, logReason2)
	pPlayer.CallClientScript("Mail:TakeAttach", nMailId)
	pPlayer.OnEvent("OnTakeMailAttach", tbSaveData.nLogReazon, logReason2, tbSaveData.tbParams);

	for i,v in ipairs(tbSaveData.tbAttach) do
		local szAwardType,nParam1,nParam2,nParam3 = unpack(v);
		pPlayer.TLog("MailFlow", nMailId, tbSaveData.nLogReazon or 0, logReason2 or 0, Player.AwardType[szAwardType], nParam1 or 0, nParam2 or 0,nParam3 or 0, 1)
	end

	Log("Mail PlayerTakeAttach scucess", pPlayer.dwID, tbSaveData.nLogReazon, nMailId, logReason2)
end

function Mail:DeleteAllMail(dwRoleId)
	local role = KPlayer.GetRoleStayInfo(dwRoleId)
	if not role then
		return
	end
	PostRequest(dwRoleId, OnDeleteAllMail)
end

--根据邮件id 删一封邮件, 只处理有附件的，已领取的忽略删除
function Mail:DeleteOneMail(dwRoleId, nMailId)
	local role = KPlayer.GetRoleStayInfo(dwRoleId)
	if not role then
		return
	end
	PostRequest(dwRoleId, OnDeleteOneMail, nMailId)
end