

function Sdk:AskBuluoUrl(nOsType)
	local szUrl = "";
	if nOsType == Sdk.eOSType_iOS then
		szUrl = Sdk.szIOSBuluoUrl;
	else
		szUrl = Sdk.szAndroidBuluoUrl;
	end
	me.CallClientScript("Sdk:OnSyncBuluoUrl", szUrl);
	return true;
end

Sdk.tbCachePlayerLaunchPlat = Sdk.tbCachePlayerLaunchPlat or {};
function Sdk:CachePlayerLaunchPlat(nPlayerId)
	Sdk.tbCachePlayerLaunchPlat[nPlayerId] = Lib:GetLocalDay();
end

function Sdk:IsPlayerLaunchFromGameCenter(nPlayerId)
	local nValidDay = Sdk.tbCachePlayerLaunchPlat[nPlayerId] or 0;
	return Lib:GetLocalDay() == nValidDay;
end

function Sdk:UpdateXinyueLevel(pPlayer)
	local nDay = Lib:GetLocalDay();
	local nXinyueCheckDay = pPlayer.GetUserValue(Sdk.Def.TX_VIP_SAVEGROUP, Sdk.Def.TX_XINYUE_CHECK_DAY);
	if nDay == nXinyueCheckDay then
		return;
	end

	AssistClient:UpdateXinyueVip(pPlayer);
end

function Sdk:SetXinyueLevel(pPlayer, nXinyueLevel)
	local nDay = Lib:GetLocalDay();
	pPlayer.SetUserValue(Sdk.Def.TX_VIP_SAVEGROUP, Sdk.Def.TX_XINYUE_CHECK_DAY, nDay);
	pPlayer.SetUserValue(Sdk.Def.TX_VIP_SAVEGROUP, Sdk.Def.TX_XINYUE_LEVEL, nXinyueLevel);
end

function Sdk:CheckWeixinTitleReward(pPlayer)
	local nWXLaunchReward = pPlayer.GetUserValue(Sdk.Def.TX_VIP_SAVEGROUP, Sdk.Def.TX_VIP_GREEN_REWARD);
	if nWXLaunchReward ~= 0 then
		return;
	end

	local tbMsdkInfo = pPlayer.GetMsdkInfo();
	if not next(tbMsdkInfo) then
		return;
	end

	if tbMsdkInfo.nPlatform ~= Sdk.ePlatform_Weixin then
		return;
	end

	me.SendAward({Sdk.Def.tbWeixinTitleAward}, nil, nil, Env.LogWay_QQVIPGreenReward);
	pPlayer.SetUserValue(Sdk.Def.TX_VIP_SAVEGROUP, Sdk.Def.TX_VIP_GREEN_REWARD, 1);
	return true;
end

function Sdk:CheckQQVipGreenReward(pPlayer)
	local nGreenReward = pPlayer.GetUserValue(Sdk.Def.TX_VIP_SAVEGROUP, Sdk.Def.TX_VIP_GREEN_REWARD);
	if nGreenReward ~= 0 then
		return;
	end

	local nQQVip = pPlayer.GetQQVipInfo();
	if nQQVip == Player.QQVIP_NONE then
		return;
	end

	local tbMail = nil;
	if nQQVip == Player.QQVIP_VIP then
		tbMail = {
			To = pPlayer.dwID;
			Title = "特權新手禮包";
			Text = "送您一份特別的新手禮物，請注意查收！";
			From = "系統";
			tbAttach = {Sdk.Def.tbQQVipGreenAward};
			nLogReazon = Env.LogWay_QQVIPGreenReward;
		};
	elseif nQQVip == Player.QQVIP_SVIP then
		tbMail = {
			To = pPlayer.dwID;
			Title = "特權新手禮包";
			Text = "送您一份特別的新手禮物，請注意查收！";
			From = "系統";
			tbAttach = {Sdk.Def.tbQQSvipGreenAward};
			nLogReazon = Env.LogWay_QQSVIPGreenReward;
		};
	end

	if tbMail then
		Mail:SendSystemMail(tbMail);
		pPlayer.SetUserValue(Sdk.Def.TX_VIP_SAVEGROUP, Sdk.Def.TX_VIP_GREEN_REWARD, 1);
	end
	return true;
end

function Sdk:CheckQQVipEverydayReward(pPlayer)
	local tbMsdkInfo = pPlayer.GetMsdkInfo();
	-- iOS下的QQ vip每日奖励通过邮件发送
	if tbMsdkInfo.nOsType ~= Sdk.eOSType_iOS then
		return false;
	end

	local nQQVip = pPlayer.GetQQVipInfo();
	if nQQVip == Player.QQVIP_NONE then
		return false;
	end

	local bAllowed = Sdk:GetQQVipRewardState(pPlayer);
	if not bAllowed then
		return false;
	end

	local tbMail = nil;
	if nQQVip == Player.QQVIP_VIP then
		tbMail = {
			To = pPlayer.dwID;
			Title = "特權每日禮包";
			Text = "送您一份今日登錄的禮物，請注意查收！";
			From = "系統";
			tbAttach = {Sdk.Def.tbQQVipEveryDayAward};
			nLogReazon = Env.LogWay_QQVIPEveryDayReward;
		};
	elseif nQQVip == Player.QQVIP_SVIP then
		tbMail = {
			To = pPlayer.dwID;
			Title = "特權每日禮包";
			Text = "送您一份今日登錄的禮物，請注意查收！";
			From = "系統";
			tbAttach = {Sdk.Def.tbQQSVipEveryDayAward};
			nLogReazon = Env.LogWay_QQSVIPEveryDayReward;
		};
	end

	if tbMail then
		Mail:SendSystemMail(tbMail);
		Sdk:SetQQVipRewardTime(pPlayer, true);
	end
end

function Sdk:Ask4QQVipAward(nVipType, szAwardType)
	if nVipType ~= Player.QQVIP_SVIP and nVipType ~= Player.QQVIP_VIP then
		return false, "未知的會員類型";
	end

	if szAwardType ~= "day" and szAwardType ~= "open" then
		return false, "未知的獎勵類型";
	end

	if szAwardType == "day" then
		local nQQVip = me.GetQQVipInfo();
		if nQQVip ~= nVipType then
			return false, "您沒有對應的QQ會員許可權";
		end

		local bAllowed = Sdk:GetQQVipRewardState(me);
		if not bAllowed then
			return false, "您已經領取過今日的禮包了";
		end

		if nQQVip == Player.QQVIP_VIP then
			me.SendAward({Sdk.Def.tbQQVipEveryDayAward}, nil, nil, Env.LogWay_QQVIPEveryDayReward);
		elseif nQQVip == Player.QQVIP_SVIP then
			me.SendAward({Sdk.Def.tbQQSVipEveryDayAward}, nil, nil, Env.LogWay_QQSVIPEveryDayReward);
		end
		Sdk:SetQQVipRewardTime(me, true);
		me.CallClientScript("Sdk:OnQQVipChanged");
		return true;
	end

	if szAwardType == "open" then
		local _, bAllowed, nOpenVip = Sdk:GetQQVipRewardState(me);
		if not bAllowed then
			return false, "未達到領取開通獎勵的條件";
		end

		if nVipType ~= nOpenVip then
			return false, "您沒有對應的QQ會員許可權";
		end

		if nOpenVip == Player.QQVIP_VIP then
			me.SendAward({Sdk.Def.tbQQVipOpenAward}, nil, nil, Env.LogWay_QQVIPOpenReward);
		elseif nOpenVip == Player.QQVIP_SVIP then
			me.SendAward({Sdk.Def.tbQQSvipOpenAward}, nil, nil, Env.LogWay_QQSVIPOpenReward);
		end
		Sdk:SetQQVipRewardTime(me, nil, true);
		me.CallClientScript("Sdk:OnQQVipChanged");
		return true;
	end

	return false, "未知錯誤";
end

function Sdk:MarkPayQQVip()
	local _, bAllowVipOpenReward = Sdk:GetQQVipRewardState(me);
	if bAllowVipOpenReward then
		return true;
	end

	local nThisMonth = Lib:GetLocalMonth();
	local nLastOpenMonth = me.GetUserValue(Sdk.Def.TX_VIP_SAVEGROUP, Sdk.Def.TX_VIP_OPEN_MONTH);
	if nLastOpenMonth == nThisMonth then
		return true;
	end

	me.SetUserValue(Sdk.Def.TX_VIP_SAVEGROUP, Sdk.Def.TX_VIP_OPEN_MONTH, -1);

	local nExpireTime = GetTime() + 2 * 60;
	local fnCheckVip = function (nPlayerId)
		local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
		if not pPlayer then
			return false;
		end

		if GetTime() >= nExpireTime then
			return false;
		end

		local nLastOpenMonth = pPlayer.GetUserValue(Sdk.Def.TX_VIP_SAVEGROUP, Sdk.Def.TX_VIP_OPEN_MONTH);
		if nLastOpenMonth ~= -1 then
			pPlayer.CallClientScript("Sdk:OnQQVipChanged");
			return false;
		end

		AssistClient:UpdateQQVipInfo(pPlayer);
		return true;
	end

	AssistClient:UpdateQQVipInfo(me);
	Timer:Register(Env.GAME_FPS * 15, fnCheckVip, me.dwID);
	return true;
end

function Sdk:OnLogout(pPlayer)
	if Sdk:IsMsdk() then
		AssistClient:RankServerReport(pPlayer);
	elseif Sdk:HasEfunRank() then
		Transmit:RankServerReport(pPlayer);
	end
	if version_xm then
		Transmit:XMRoleInfoReport(pPlayer);
	end
end

function Sdk:OnStartUp()
	Sdk:CheckCommunityRedPointValidation();
end

function Sdk:OnLogin(pPlayer)
	local tbRedPointData = ScriptData:GetValue("RedPointCommunity");
	pPlayer.CallClientScript("Sdk:OnSyncCommunityRedPointInfo", tbRedPointData);

	local tbMsdkInfo = pPlayer.GetMsdkInfo();
	if tbMsdkInfo.bPCVersion then
		self:OnPCVersionLogin(pPlayer);
	end
end

function Sdk:OnPCVersionLogin(pPlayer)
	local nPCLoginCount = pPlayer.GetUserValue(Sdk.Def.SDK_INFO_SAVEGROUP, Sdk.Def.SDK_INFO_PC_VERSION_LOGIN_COUNT);
	if nPCLoginCount == 0 then
		Sdk.Def.tbPCVersionNoticeMail.To = pPlayer.dwID;
		Mail:SendSystemMail(Sdk.Def.tbPCVersionNoticeMail);
	end

	pPlayer.SetUserValue(Sdk.Def.SDK_INFO_SAVEGROUP, Sdk.Def.SDK_INFO_PC_VERSION_LOGIN_COUNT, nPCLoginCount + 1);
end

-- "Restaurant"	-襄阳酒楼
-- "QQBuluo"	-手Q部落
-- "WxCircle"	-微信朋友圈
-- "XinyueVip"	-心悦会员
-- "MicroMainPage"	-微官网
-- szRedPoint 为上五种中的一个
-- nTimeOut 失效时间戳
function Sdk:SetCommunityRedPointInfo(szRedPoint, nTimeOut)
	local tbRedPointData = ScriptData:GetValue("RedPointCommunity");
	tbRedPointData[szRedPoint] = nTimeOut;
	self:CheckCommunityRedPointValidation();
end

function Sdk:CheckCommunityRedPointValidation()
	local tbRedPointData = ScriptData:GetValue("RedPointCommunity");
	local nNow = GetTime();
	for szKey, nTimeOut in pairs(tbRedPointData) do
		if nTimeOut < nNow then
			tbRedPointData[szKey] = nil;
		end
	end

	ScriptData:AddModifyFlag("RedPointCommunity");
end

function Sdk:QueryRankInfo(szOpenIds)
	if not szOpenIds then
		return false, "無效的請求";
	end

	if Sdk:IsMsdk() then
		AssistClient:RankServerQuery(me, szOpenIds);
	elseif Sdk:HasEfunRank() then
		Transmit:RankServerQuery(me, szOpenIds);
	end
	return true;
end

function Sdk:OnQueryRankInfoRsp(pPlayer, szType, szRankInfo)
	pPlayer.CallClientScript("Sdk:OnRankInfoRsp", szType, szRankInfo);
end

function Sdk:QueryRankSendInfo()
	if Sdk:IsMsdk() then
		AssistClient:UpdateGiftInfo(me);
	elseif Sdk:HasEfunRank() then
		Transmit:UpdateGiftInfo(me);
	end
	return true;
end

function Sdk:SendFriendRankGift(szOpenId, nServerId, nPlayerId, szFriendName)
	if szOpenId == me.szAccount or szOpenId == Sdk:GetEfunFacebookId(me) then
		return false, "無法對自己進行贈送"
	end
	if not nPlayerId or nPlayerId == 0 or not nServerId or nServerId == 0 then
		return false, "無法對其它大區進行贈送";
	end

	if Sdk:IsMsdk() then
		AssistClient:RankServerSendGift(me, szOpenId, nServerId, nPlayerId, szFriendName or me.szName);
	elseif Sdk:HasEfunRank() then
		Transmit:RankServerSendGift(me, szOpenId, nServerId, nPlayerId, szFriendName or me.szName);
	end
	return true;
end

function Sdk:ReportLaunchPlat(nLaunchPlat)
	if nLaunchPlat and nLaunchPlat ~= Sdk.ePlatform_None then
		me.SetLaunchPlatform(nLaunchPlat);
		Sdk:CachePlayerLaunchPlat(me.dwID);
	end
end

function Sdk:PayReq(szPayType, ...)
	local szAcc = me.szAccount;
	local szPayUid = Sdk:GetPayUid(me);
	me.CallClientScript(szPayType, szAcc, szPayUid, ...);
	return true;
end

function Sdk:GetEfunFacebookId(pPlayer)
	return pPlayer.GetStrValue(Sdk.Def.XG_EFUN_FACEBOOK_GROUP, Sdk.Def.XG_EFUN_FACEBOOK_KEY);
end

function Sdk:UpdateEfunFacebookId(szFacebookId)
	if szFacebookId ~= Sdk:GetEfunFacebookId(me) then
		me.SetStrValue(Sdk.Def.XG_EFUN_FACEBOOK_GROUP, Sdk.Def.XG_EFUN_FACEBOOK_KEY, szFacebookId);
	end
	return true;
end

function Sdk:SendTXLuckyBagMailByPlayerId(nPlayerId, szBagType)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if pPlayer and next(pPlayer.GetMsdkInfo()) then
		Sdk:SendTXLuckyBagMail(pPlayer, szBagType);
	else
		KPlayer.AddDelayCmd(nPlayerId, string.format("Sdk:SendTXLuckyBagMailByPlayerId(%d, \"%s\")", nPlayerId, szBagType), "SendTXLuckyBagMail");
	end
end

function Sdk:SendTXLuckyBagMail(pPlayer, szBagType)
	local tbMsdkInfo = pPlayer.GetMsdkInfo();
	if not next(tbMsdkInfo) then
		Log("Sdk:SendTXLuckyBagMail Fail", szBagType, pPlayer.dwID, tbMsdkInfo.nPlatform);
		return;
	end

	-- 如果是审核服，则不发红包
	if Server:IsCloseIOSEntry() then
		return;
	end

	Log("Sdk:SendTXLuckyBagMail", szBagType, pPlayer.dwID, tbMsdkInfo.nPlatform);
	if tbMsdkInfo.nPlatform == Sdk.ePlatform_Weixin then
		Sdk:SendWeixinLuckyBagMail(pPlayer, szBagType);
	elseif tbMsdkInfo.nPlatform == Sdk.ePlatform_QQ then
		Sdk:SendQQLuckyBagMail(pPlayer, szBagType);
	end
end

function Sdk:SendQQLuckyBagMail(pPlayer, szBagType)
	if not Sdk.Def.tbQQLuckyBagSetting[szBagType] then
		Log("Sdk:SendQQLuckyBagMail Ignore type", szBagType);
		return;
	end

	local tbBagInfo = Sdk.Def.tbQQLuckyBagSetting[szBagType];
	local nActId = tbBagInfo[1];
	local nBagCount = tbBagInfo[2];
	local nPeopleNum = tbBagInfo[3];
	AssistClient:SendQQLuckyBagMail(pPlayer, szBagType, nActId, nBagCount, nPeopleNum);
	pPlayer.TLog("LuckyBagFlow", szBagType, tostring(nActId));
end

function Sdk:OnQQLuckyBagRsp(nPlayerId, szRetData, szBagType)
	Log("Sdk:OnQQLuckyBagRsp", szBagType, nPlayerId);
	local tbBoxInfo = Lib:DecodeJson(szRetData);
	local szBoxId = tbBoxInfo and tbBoxInfo.boxid;
	if not szBoxId or szBoxId == "" then
		Log("Sdk:OnQQLuckyBagRsp ERROR", nPlayerId, szRetData, szBagType);
		return;
	end

	local tbBagInfo = Sdk.Def.tbQQLuckyBagSetting[szBagType];
	local nActId = tbBagInfo[1];
	local szUrl = string.format("http://imgcache.qq.com/club/gamecenter/WebApi/giftbox/release/index/grap.html?actid=%d&_wv=1031&boxid=%s&appid=%d", nActId, szBoxId, Sdk.szQQAppId);
	local szContent = string.format("給QQ好友分享寶箱，即可領取元寶。[url=openwnd:點擊分享寶箱,RedPaperSharePanel,\"%s\"]", szUrl);
	local tbMail = {
			To = nPlayerId;
			Title = "恭喜你獲得元寶寶箱";
			Text = (tbBagInfo[4] or "") .. szContent;
			From = "手Q寶箱";
		};

	Mail:SendSystemMail(tbMail);
end

function Sdk:SendWeixinLuckyBagMail(pPlayer, szBagType)
	if not Sdk.Def.tbWeixinLuckBagSetting[szBagType] then
		Log("Sdk:SendWeixinLuckyBagMail Ignore type:", szBagType);
		return;
	end

	local tbBagInfo = Sdk.Def.tbWeixinLuckBagSetting[szBagType];
	local szActId = tbBagInfo[1];
	local szUrl = "http://game.weixin.qq.com/cgi-bin/actnew/getacturl?";
	local szOpenId = pPlayer.szAccount;
	local szKey = "S9MJF154ZPVOYAU7HDR8CK230BXQLN6TWEIG";
	local nNow = GetTime();
	local szBussId = szBagType .. tostring(nNow);
	local szType = "3";
	local szSign = KLib.GetStringMd5(string.format("actid=%s&bussid=%s&openid=%s&stamp=%d&type=%s&key=%s", szActId, szBussId, szOpenId, nNow, szType, szKey));
	szUrl = string.format("%sactid=%s&bussid=%s&openid=%s&stamp=%d&type=%s&sign=%s", szUrl, szActId, szBussId, szOpenId, nNow, szType, szSign);
	AssistLib.DoHttpCommonRequest(pPlayer.dwID, szUrl, "", "WeixinLukybag", szBagType, "");
	pPlayer.TLog("LuckyBagFlow", szBagType, szActId);
end

Sdk.tbNotifyPlatAllSetting = {
	[0] = {  -- ios
		message = [[{"aps":{"alert":"%s","badge":1}}]];
		tbPrarams = {
			environment = 1; --1表示推送生产环境；2表示推送开发环境
			access_id = 2295754046;
			
		};
		secret_key = "M8n98P39CQCUWJFX";
	};
	[1] = { -- android
		message = [[{"content":"%s","title":"劍俠情緣", "vibrate":1}]];
		tbPrarams = {
			access_id = 2195754046;
		};
		secret_key = "M8n98P39CQCUWJFX";
	};
};
	

function Sdk:SendXinGeNotifycation(pPlayer,szWord)
	local szAppId, nPlatId, nServerId, nAreaId = GetWorldConfifParam();
	local tbPlatSetting = self.tbNotifyPlatAllSetting[nPlatId]

	local szSendWord = szWord;
	-- ios payload 就是message字段 不能超过256字节
	if Lib:Utf8Len(szWord) > 50 then
		szSendWord = Lib:CutUtf8(szWord, 50) .. "..."
	end

	local dwKinId = pPlayer.dwKinId
	local tbPlayerAccounts1 = {};
	local tbMembers = Kin:GetKinMembers(dwKinId, true)
	for nMemberId, nCareer in pairs(tbMembers) do
		local pPlayer = KPlayer.GetPlayerObjById(nMemberId)
		if not pPlayer or  pPlayer.nState ~= 2 then
			local szAccount = KPlayer.GetPlayerAccount(nMemberId) 	
			if szAccount  then
				local memberData = Kin:GetMemberData(nMemberId);
				table.insert(tbPlayerAccounts1, {szAccount, memberData:GetWeekActive()})
			end
		end
	end
	if #tbPlayerAccounts1 == 0 then
		Log("Sdk:SendXinGeNotifycation No tbPlayerAccounts", pPlayer.dwID, pPlayer.dwKinId)
		return
	end
	if #tbPlayerAccounts1 > 100 then
		table.sort( tbPlayerAccounts1, function (a, b)
			return a[2] > b[2]
		end )
		tbPlayerAccounts1 = { unpack(tbPlayerAccounts1, 1, 100) }
	end
	local tbPlayerAccounts = {};
	for i,v in ipairs(tbPlayerAccounts1) do
		table.insert(tbPlayerAccounts, v[1])
	end
	local szAccountList = Lib:EncodeJson(tbPlayerAccounts)
	local secret_key = tbPlatSetting.secret_key
	
	--通用参数
	local nNow = GetTime();
	local tbParams = {
		timestamp = nNow;
	};
	--平台差异参数
	if tbPlatSetting.tbPrarams then
		for k,v in pairs(tbPlatSetting.tbPrarams) do
			tbParams[k] = v
		end
	end
	-- 单个帐号的参数
	-- tbParams.account = szAccount;	
	-- 多个帐号的参数
	tbParams.account_list = szAccountList;
	tbParams.message_type = 1;
	tbParams.message = string.format(tbPlatSetting.message, szSendWord)

	local tbKeys = {};
	for k,v in pairs(tbParams) do
		table.insert(tbKeys, k)
	end
	Lib:SortStrByAlphabet(tbKeys)

	local szUrl = "openapi.xg.qq.com/v2/push/account_list"; --多个帐号
	local tbContact = {"GET" .. szUrl};
	for _,k in ipairs(tbKeys) do
		table.insert(tbContact, k .. "=" .. tbParams[k])
	end
	table.insert(tbContact, secret_key)
	local szSign = table.concat(tbContact, "");

	szSign = KLib.GetStringMd5(szSign)
	szSign =string.lower(szSign)

	tbParams["sign"] = szSign;

	local tbParamStrs = {};
	for k,v in pairs(tbParams) do
		table.insert(tbParamStrs, string.format("%s=%s", Lib:UrlEncode(k), Lib:UrlEncode(v)))
	end
	local szParamStrs = table.concat(tbParamStrs,"&")

	local szSendUrl = string.format("http://%s?%s", szUrl, szParamStrs);

	AssistLib.DoHttpCommonRequest(pPlayer.dwID, szSendUrl, "", "XingGeNotify", "", "");
end

function Sdk:OnWeixinLuckyBagRsp(nPlayerId, szRetData, szBagType)
	Log("Sdk:OnWeixinLuckyBagRsp", szBagType, nPlayerId);

	local tbUrlInfo = Lib:DecodeJson(szRetData);
	local szUrl = tbUrlInfo and (type(tbUrlInfo.data) == "table") and tbUrlInfo.data.url;
	if not szUrl then
		Log("Sdk:OnWeixinLuckyBagRsp ERROR", nPlayerId, szRetData, szBagType);
		return;
	end

	local tbBagInfo = Sdk.Def.tbWeixinLuckBagSetting[szBagType];
	local szContent = string.format("你現在可以給微信好友發送[FFFE0D]福袋[-]了。[url=openwnd:點擊發放福袋,RedPaperSharePanel,\"%s\"]", szUrl or "http://g.cn");
	local tbMail = {
			To = nPlayerId;
			Title = "微信福袋";
			Text = (tbBagInfo[2] or "") .. szContent;
			From = "微信福袋";
		};

	Mail:SendSystemMail(tbMail);
end

function Sdk:SendBindPhoneReward()
	if not Sdk:IsEfunHKTW() then
		return false, "本渠道沒有綁定手機獎勵";
	end

	if Sdk:IsPhoneBinded(me) then
		return false, "您已經領取過綁定手機獎勵了";
	end

	Sdk.Def.tbBindPhoneMail.To = me.dwID;
	Mail:SendSystemMail(Sdk.Def.tbBindPhoneMail);
	me.SetUserValue(Sdk.Def.SDK_INFO_SAVEGROUP, Sdk.Def.SDK_INFO_BINDED_PHONE, GetTime());
	return true;
end

function Sdk:AddInviteFriendsCount(nCount)
	if not Sdk:HasEfunRank() then
		return false, "本渠道不支援該功能";
	end

	local nCurDay = Lib:GetLocalDay();
	local nInviteDay = me.GetUserValue(Sdk.Def.SDK_INFO_SAVEGROUP, Sdk.Def.SDK_INFO_FB_INVITE_DAY);
	if nCurDay ~= nInviteDay then
		me.SetUserValue(Sdk.Def.SDK_INFO_SAVEGROUP, Sdk.Def.SDK_INFO_FB_INVITE_DAY, nCurDay);
		me.SetUserValue(Sdk.Def.SDK_INFO_SAVEGROUP, Sdk.Def.SDK_INFO_FB_INVITE_COUNT, 0);
	end

	local nCurCount = me.GetUserValue(Sdk.Def.SDK_INFO_SAVEGROUP, Sdk.Def.SDK_INFO_FB_INVITE_COUNT);
	me.SetUserValue(Sdk.Def.SDK_INFO_SAVEGROUP, Sdk.Def.SDK_INFO_FB_INVITE_COUNT, nCurCount + nCount);
	return true;
end

function Sdk:TakeInviteReward()
	if not Sdk:IsEfunHKTW() then
		return false, "本渠道不支援該功能";
	end

	local nInviteDay = me.GetUserValue(Sdk.Def.SDK_INFO_SAVEGROUP, Sdk.Def.SDK_INFO_FB_INVITE_DAY);
	local nTakeRewardDay = me.GetUserValue(Sdk.Def.SDK_INFO_SAVEGROUP, Sdk.Def.SDK_INFO_FB_INVITE_PRICE_DAY);
	if nInviteDay == nTakeRewardDay then
		return false, "您已經領取過今日的邀請獎勵了";
	end

	local nToday = Lib:GetLocalDay();
	local nCurCount = me.GetUserValue(Sdk.Def.SDK_INFO_SAVEGROUP, Sdk.Def.SDK_INFO_FB_INVITE_COUNT);
	if nCurCount < Sdk.Def.nFBInviteFriendsPriceCount or nToday ~= nInviteDay then
		return false, "邀請人數尚未達標，無法領取獎勵";
	end

	me.SetUserValue(Sdk.Def.SDK_INFO_SAVEGROUP, Sdk.Def.SDK_INFO_FB_INVITE_PRICE_DAY, nInviteDay);
	me.SendAward({Sdk.Def.tbFBInviteFriendsAward}, nil, nil, Env.LogWay_InviteFriendReward);
	return true;
end

function Sdk:TakeXMFacebookReward()
	if not version_xm then
		return false, "本渠道不支援該功能";
	end

	if Sdk:XMIsFacebookClickAwardSend(me) then
		return false, "已經領取過該獎勵";
	end

	Sdk.Def.tbXMFacebookClickAwardMail.To = me.dwID;
	Mail:SendSystemMail(Sdk.Def.tbXMFacebookClickAwardMail);
	me.SetUserValue(Sdk.Def.SDK_INFO_SAVEGROUP, Sdk.Def.SDK_INFO_XM_FB_CLICK_ED, GetTime());
	return true;
end

function Sdk:TakeXMEvaluateReward()
	if not version_xm then
		return false, "本渠道不支援該功能";
	end

	if Sdk:XMISEvaluateAwardSend(me) then
		return false, "已經領取過該獎勵";
	end
	
	Sdk.Def.tbXMEvaluateAwardMail.To = me.dwID;
	Mail:SendSystemMail(Sdk.Def.tbXMEvaluateAwardMail);
	me.SetUserValue(Sdk.Def.SDK_INFO_SAVEGROUP, Sdk.Def.SDK_INFO_XM_EVALUEATE_ED, GetTime());
	return true;
end

function Sdk:SetQQAddFriendAvailable(bAvailable)
	me.SetUserValue(Sdk.Def.SDK_INFO_SAVEGROUP, Sdk.Def.SDK_INFO_QQ_INVITE_DISABLE, bAvailable and 0 or 1);
	return true;
end

Sdk.tbCachePlayerAddQQMapList = Sdk.tbCachePlayerAddQQMapList or {};
function Sdk:RequestAddQQFriend(dwFriendId)
	local pFriend = KPlayer.GetPlayerObjById(dwFriendId);
	if not pFriend then
		return false, "好友不線上，不可發起請求";
	end

	if not Sdk:IsQQAddFriendAvailable(pFriend) then
		return false, "好友設置無法添加QQ好友";
	end

	local nToday = Lib:GetLocalDay();
	Sdk.tbCachePlayerAddQQMapList[me.dwID] = Sdk.tbCachePlayerAddQQMapList[me.dwID] or {};
	if Sdk.tbCachePlayerAddQQMapList[me.dwID][dwFriendId] == nToday then
		return false, "您今日已向該好友發送申請，請擇日再發";
	end
	Sdk.tbCachePlayerAddQQMapList[me.dwID][dwFriendId] = nToday;
	me.CallClientScript("Sdk:AddQQFriend", pFriend.szAccount, pFriend.szName);
	return true;
end

function Sdk:RequestOpenTXLiveUrl()
	local szUrl = "http://egame.qq.com/sdk/live?anchorid=243127390&egame_id=1105218881&_pggwv=528";
	me.CallClientScript("Sdk:OpenUrl", szUrl);
end

-- 同步定义在tlog_stand.xml中
local tbShareTLogType = {
	ShowOff   = 0, -- 个人详情炫耀
	Invite    = 1, -- 邀请
	Luckybag  = 8, -- 微信红包 或 手Q宝箱
	HSLJ      = 9, -- 华山论剑冠军
	MainCity  = 10, -- 襄阳城主
	Faction   = 11, -- 门派新人王
	Companion = 12, -- 获得同伴
	HonorUp   = 13, -- 升级头衔
}

function Sdk:TlogShare(szShareType, nParam)
	local szGameAppid, nPlat, nServerIdentity = GetWorldConfifParam();
	TLog("SnsFlow",
		szGameAppid,
		nPlat,
		nServerIdentity,
		me.szAccount,
		0, 1, tbShareTLogType[szShareType] or 0, nParam or 0);

	-- Log("SnsFlow",
	-- 	szGameAppid,
	-- 	nPlat,
	-- 	nServerIdentity,
	-- 	me.szAccount,
	-- 	0, 0, tbShareTLogType[szShareType] or 0, nParam or 0);
	return true;
end


function Sdk:DoDaojuShopBuyingRequest(szPropId, szActionId, szProductId, pPlayer)
	local pPlayer = pPlayer or me;
	local tbMsdkInfo = pPlayer.GetMsdkInfo();
	local _, _, nServerId = GetWorldConfifParam();
	local tbParams = {};

	table.insert(tbParams, string.format("_test=%s", Sdk:IsTest() and "1" or "0"));
	table.insert(tbParams, string.format("iActionId=%s", szActionId));
	table.insert(tbParams, string.format("propid=%s", szPropId));

	if tbMsdkInfo.nPlatform == Sdk.ePlatform_Weixin then
		table.insert(tbParams, "acctype=wx");
		table.insert(tbParams, string.format("appid=%s", Sdk.szWxAppId));
	elseif tbMsdkInfo.nPlatform == Sdk.ePlatform_QQ then
		table.insert(tbParams, "acctype=qq");
		table.insert(tbParams, string.format("appid=%s", Sdk.szQQAppId));
		table.insert(tbParams, string.format("pay_token=%s", tbMsdkInfo.szPayToken));
	else
		return false, "請使用手Q或微信進行登入";
	end

	table.insert(tbParams, string.format("openid=%s", tbMsdkInfo.szOpenId));
	table.insert(tbParams, string.format("access_token=%s", tbMsdkInfo.szOpenKey));
	table.insert(tbParams, string.format("plat=%d", (tbMsdkInfo.nOsType == Sdk.eOSType_iOS) and 0 or 1));
	table.insert(tbParams, string.format("areaid=%d", Sdk:GetAreaIdByPlatform(tbMsdkInfo.nPlatform)));
	table.insert(tbParams, string.format("partition=%d", nServerId));
	table.insert(tbParams, string.format("roleid=%d", pPlayer.dwID));
	table.insert(tbParams, string.format("rolename=%s", pPlayer.szName));

	table.insert(tbParams, "_app_id=2005");
	table.insert(tbParams, "_biz_code=jxqy");
	table.insert(tbParams, "_plug_id=7200");
	table.insert(tbParams, "_output_fmt=1");
	table.insert(tbParams, "buynum=1");
	table.insert(tbParams, "paytype=2");
	table.insert(tbParams, "pandora_info={}");
	table.insert(tbParams, "_ver=v2");

	local szDaojuShopApiUrl = "/cgi-bin/daoju/v3/hs/i_buy.cgi?";
	local szRequestUrl = szDaojuShopApiUrl .. table.concat(tbParams, "&");

	-- Log(szRequestUrl)
	AssistLib.DoHttpCommonRequest(pPlayer.dwID, szRequestUrl, "", "DaojuBuyRsp", szProductId or "", "DaojuShop");
	return true;
end

function Sdk:DaojuBuyRsp(nPlayerId, szRetData, szProductId)
	-- Log("Sdk:DaojuBuyRsp", nPlayerId, szRetData, szProductId);
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return;
	end

	local _, _, nServerId = GetWorldConfifParam();
	pPlayer.CallClientScript("Sdk:OnDaojuChargeRsp", szRetData, szProductId, nServerId);
end

function Sdk:AskOrgServerIdForInit()
	if me.nOrgServerId <= 0 then
		Log("AskOrgServerIdForInit Error", me.dwID, me.nOrgServerId)
		return;
	end

	me.CallClientScript("PlayerEvent:OnSyncOrgServerId", me.nOrgServerId);
	me.CallClientScript("Sdk:MidasInit");
	return true;
end

function Sdk:ReprotASMInfo(szASMInfo)
	Log("ReprotASMInfo", me.dwID, szASMInfo);
end

local tbInterface = {
	Ask4QQVipAward           = true;
	AskBuluoUrl              = true;
	MarkPayQQVip             = true;
	QueryRankInfo            = true;
	QueryRankSendInfo        = true;
	SendFriendRankGift       = true;
	ReportLaunchPlat         = true;
	PayReq                   = true;
	UpdateEfunFacebookId     = true;
	SendBindPhoneReward      = true;
	TakeInviteReward         = true;
	AddInviteFriendsCount    = true;
	TakeXMFacebookReward     = true;
	TakeXMEvaluateReward     = true;
	SetQQAddFriendAvailable  = true;
	RequestAddQQFriend       = true;
	RequestOpenTXLiveUrl     = true;
	TlogShare                = true;
	DoDaojuShopBuyingRequest = true;
	AskOrgServerIdForInit    = true;
	ReprotASMInfo            = true;
};

function Sdk:ClientRequest(szRequestType, ...)
	if tbInterface[szRequestType] then
		local bRet, szMsg = Sdk[szRequestType](Sdk, ...);
		if not bRet and szMsg then
			me.CenterMsg(szMsg);
		end
	else
		assert(false, "unkonw sdk client request type:" .. szRequestType);
	end
end
