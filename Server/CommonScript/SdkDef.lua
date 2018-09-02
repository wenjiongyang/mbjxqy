Sdk.szQQAppId = "1105054046";
Sdk.szWxAppId = "wxacbfe7e1bb3e800f";
Sdk.szQQAppKey = "M8n98P39CQCUWJFX";
Sdk.szWXAppKey = "b53b55619b2a92414ad42aef480974fd";

Sdk.szDaojuiOSOfferId = "1450006821";
Sdk.sziOSOfferId = "1450006278";
Sdk.szAndroidOfferId = "1450005929";
Sdk.szMsdkAid = "aid=mvip.yx.inside.jxqy_1105054046";

Sdk.tbPCVersionChannels = {
	["10026640"] = true;
	["10028405"] = true;
};

Sdk.tbPCVersionChannelNums = {};
for k,v in pairs(Sdk.tbPCVersionChannels) do
	Sdk.tbPCVersionChannelNums[tonumber(k)] = v;
end

Sdk.szWXInvitationUrl = "http://dwz.cn/5O6n7O";
Sdk.szQQInvitationUrl = "http://youxi.vip.qq.com/m/act/891cb717ef_jxqy_186532.html?_wv=1";
Sdk.szIOSBuluoUrl = "http://xiaoqu.qq.com/cgi-bin/bar/qqgame/handle_ticket?redirect_url=http%3A%2F%2Fxiaoqu.qq.com%2Fmobile%2Fbarindex.html%3F%26_bid%3D%26_wv%3D1027%26from%3Dgameblog_jxqy%23bid%3D304889&sourcetype=1";
Sdk.szAndroidBuluoUrl = "http://xiaoqu.qq.com/cgi-bin/bar/qqgame/handle_ticket?redirect_url=http%3A%2F%2Fxiaoqu.qq.com%2Fmobile%2Fbarindex.html%3F%26_bid%3D%26_wv%3D1027%26from%3Dgameblog_jxqy%23bid%3D304889&sourcetype=1";
Sdk.szXinyueUrl = "http://apps.game.qq.com/php/tgclub/v2/mobile_open/redirect";
Sdk.szXinyueGameId = "63";

-- 平台枚举
Sdk.ePlatform_None    = 0;
Sdk.ePlatform_Weixin  = 1;
Sdk.ePlatform_QQ      = 2;
Sdk.ePlatform_WTLogin = 3;
Sdk.ePlatform_QQHall  = 4;
Sdk.ePlatform_Guest   = 5;

-- os type
Sdk.eOSType_Windows = 0;
Sdk.eOSType_iOS     = 1;
Sdk.eOSType_Android = 2;

-- 定义的详细注释到WGPublicDefine.cs当中查找
Sdk.eFlag_Succ                       = 0;
Sdk.eFlag_QQ_NoAcessToken            = 1000;
Sdk.eFlag_QQ_UserCancel              = 1001;
Sdk.eFlag_QQ_LoginFail               = 1002;
Sdk.eFlag_QQ_NetworkErr              = 1003;
Sdk.eFlag_QQ_NotInstall              = 1004;
Sdk.eFlag_QQ_NotSupportApi           = 1005;
Sdk.eFlag_QQ_AccessTokenExpired      = 1006;
Sdk.eFlag_QQ_PayTokenExpired         = 1007;
Sdk.eFlag_WX_NotInstall              = 2000;
Sdk.eFlag_WX_NotSupportApi           = 2001;
Sdk.eFlag_WX_UserCancel              = 2002;
Sdk.eFlag_WX_UserDeny                = 2003;
Sdk.eFlag_WX_LoginFail               = 2004;
Sdk.eFlag_WX_RefreshTokenSucc        = 2005;
Sdk.eFlag_WX_RefreshTokenFail        = 2006;
Sdk.eFlag_WX_AccessTokenExpired      = 2007;
Sdk.eFlag_WX_RefreshTokenExpired     = 2008;
Sdk.eFlag_Error                      = -1;
Sdk.eFlag_Local_Invalid              = -2;
Sdk.eFlag_NotInWhiteList             = -3;
Sdk.eFlag_LbsNeedOpenLocationService = -4;
Sdk.eFlag_LbsLocateFail              = -5;
Sdk.eFlag_NeedLogin                  = 3001;
Sdk.eFlag_UrlLogin                   = 3002;
Sdk.eFlag_NeedSelectAccount          = 3003;
Sdk.eFlag_AccountRefresh             = 3004;
Sdk.eFlag_Checking_Token             = 5001;
Sdk.eFlag_InvalidOnGuest             = -7;
Sdk.eFlag_Guest_AccessTokenInvalid   = 4001;
Sdk.eFlag_Guest_LoginFailed          = 4002;
Sdk.eFlag_Guest_RegisterFailed       = 4003;

Sdk.eMidas_PAYRESULT_ERROR      = -1;
Sdk.eMidas_PAYRESULT_SUCC       = 0;
Sdk.eMidas_PAYRESULT_CANCEL     = 2;
Sdk.eMidas_PAYRESULT_PARAMERROR = 3;
Sdk.eMidas_PAYSTATE_PAYSUCC     = 0;

Sdk.eMidasServerRet_Sussess              = 0;
Sdk.eMidasServerRet_ParamError           = 1001;
Sdk.eMidasServerRet_SystemBusy           = 1002; -- 系统繁忙
Sdk.eMidasServerRet_LoginError           = 1018; -- 登入校验失败
Sdk.eMidasServerRet_LackMoney            = 1004; -- 余额不足
Sdk.eMidasServerRet_RepeatBillNo         = 1002215; -- 订单号重复
Sdk.eMidasServerRet_BillDealing          = 3000111; -- 订单正在处理中..
Sdk.eMidasServerRet_PayRiskPunish        = 1145; -- 风控, 扣砖惩罚
Sdk.eMidasServerRet_PayRiskSeal          = 1146; -- 风控, 封号
Sdk.eMidasServerRet_PayRiskIntercept     = 1147; -- 风控, 拦截
Sdk.eMidasServerRet_PresentRiskIntercept = 1148; -- 风控, 拦截
Sdk.eMidasServerRet_PresentRiskSeal      = 1149; -- 风控, 封号

Sdk.eWXGroupRet_Suss          = 0;
Sdk.eQQGroupRet_Suss          = 0;
Sdk.eQQGroupRet_NotBind       = 2002; -- 没有绑定记录，
Sdk.eQQGroupRet_NotJoined     = 2003; --  查询失败，当前用户尚未加入QQ群，请先加入QQ群。
Sdk.eQQGroupRet_NotFoundGroup = 2007; -- 查询失败，当前公会绑定的QQ群已经解散或者不存在。
Sdk.eWXGroupRet_Suss          = 0;
Sdk.eWXGroupRet_NotPermit     = {[-10001] = true, [2009] = true}; -- 游戏没有建群权限
Sdk.eWXGroupRet_ParamErr      = {[-10002] = true, [2010] = true}; -- 参数错误
Sdk.eWXGroupRet_IDExist       = {[-10005] = true, [2011] = true}; -- 群ID已存在
Sdk.eWXGroupRet_OverCreateNum = {[-10006] = true, [2012] = true}; -- 建群数量超过上限
Sdk.eWXGroupRet_IDNotExist    = {[-10007] = true, [2013] = true}; -- 群ID不存在

Sdk.Def = {};
Sdk.Def.tbLaunchPrivilegeAward = {"Contrib", 50}; -- 登入特权每日签到额外
Sdk.Def.tbQQVipEveryDayAward   = {"item", 2393, 1}; -- QQ会员每日奖励
Sdk.Def.tbQQSVipEveryDayAward  = {"item", 2394, 1}; -- QQ超级会员每日奖励
Sdk.Def.tbQQVipGreenAward      = {"item", 2391, 1}; -- QQ会员新手礼包
Sdk.Def.tbQQSvipGreenAward     = {"item", 2392, 1}; -- QQ超级会员新手礼包
Sdk.Def.tbQQVipOpenAward       = {"item", 2389, 1}; -- QQ会员开通礼包
Sdk.Def.tbQQSvipOpenAward      = {"item", 2390, 1}; -- QQ超级会员开通礼包
Sdk.Def.tbWeixinTitleAward     = {"AddTimeTitle", 2005, -1}; -- 微信游戏中心首次
Sdk.Def.nWeixinTitleId = 2005;
Sdk.Def.nQQVipTitleId  = 2006;

Sdk.Def.TX_VIP_SAVEGROUP             = 86;
Sdk.Def.TX_VIP_DAY_REWARD            = 7;
Sdk.Def.TX_VIP_OPEN_REWARD           = 8;
Sdk.Def.TX_VIP_GREEN_REWARD          = 9;
Sdk.Def.TX_VIP_OPEN_MONTH            = 10;
Sdk.Def.TX_VIP_LATEST_OPEN_VIP       = 15;
Sdk.Def.TX_XINYUE_CHECK_DAY          = 13;
Sdk.Def.TX_XINYUE_LEVEL              = 14;
Sdk.Def.XG_EFUN_FACEBOOK_GROUP       = 108;
Sdk.Def.XG_EFUN_FACEBOOK_KEY         = 1;

Sdk.Def.SDK_INFO_SAVEGROUP              = 86;
Sdk.Def.SDK_INFO_BINDED_PHONE           = 16;
Sdk.Def.SDK_INFO_FB_INVITE_DAY          = 17;
Sdk.Def.SDK_INFO_FB_INVITE_COUNT        = 18;
Sdk.Def.SDK_INFO_FB_INVITE_PRICE_DAY    = 19;
Sdk.Def.SDK_INFO_XM_FB_CLICK_ED         = 20;
Sdk.Def.SDK_INFO_XM_EVALUEATE_ED        = 21;
Sdk.Def.SDK_INFO_QQ_INVITE_DISABLE      = 22;
Sdk.Def.SDK_INFO_SS_PARTNER_COUNT       = 23;
Sdk.Def.SDK_INFO_PC_VERSION_LOGIN_COUNT = 24;

Sdk.Def.nAddQQFriendImityLine     = 5; -- 添加QQ好友所需的亲密度等级
Sdk.Def.bIsEfunTWHKWeekendActOpen = false;

-- Efun平台绑定手机奖励邮件
Sdk.Def.tbBindPhoneMail = {
	Title = "綁定手機獎勵";
	Text = "綁定手機獎勵";
	From = "系統";
	tbAttach = {{"Gold", 200}, {"item", 212, 10}, {"item", 785, 5}};
	nLogReazon = Env.LogWay_BindPhoneReward;
};

Sdk.Def.tbPCVersionNoticeMail = {
	Title = "電腦版使用說明";
	Text = [[      親愛的少俠，歡迎使用《劍俠情緣手遊》電腦版。在電腦版中可以使用鍵盤進行基本操作。您可以通過 [FFFE0D]角色資訊介面--操作--PC操作設置[-] 介面進行快速鍵設置。
      電腦版目前暫不支持儲值，您仍需[FFFE0D]回到手機端來完成儲值支付[-]。對此帶來的不便，敬請見諒。]];
	From = "系統";
}

Sdk.Def.tbFBInviteFriendsAward = {"item", 222, 5}; -- facebook邀请好友奖励,5个绿水晶
Sdk.Def.nFBInviteFriendsPriceCount = 40; -- facebook邀请好友人数(以上则有奖励)

-- 新马点击facebook奖励
Sdk.Def.tbXMFacebookClickAwardMail = {
	Title = "Facebook關注獎勵";
	Text = "Facebook粉絲頁關注獎勵";
	From = "系統";
	tbAttach = {{"Gold", 10}};
};

-- 新马评论任务奖励
Sdk.Def.tbXMEvaluateAwardMail = {
	Title = "商店評論任務獎勵";
	Text = "商店評論任務獎勵";
	From = "系統";
	tbAttach = {{"item", 785, 1}};
};

Sdk.Def.tbPlatformIcon = {
	[Sdk.ePlatform_Weixin]  = "WeiXinMark";
	[Sdk.ePlatform_QQ]      = "QQMark";
	[Sdk.ePlatform_Guest]   = "TouristMark";
};

Sdk.Def.tbPlatformName = {
	[Sdk.ePlatform_Weixin]  = "微信";
	[Sdk.ePlatform_QQ]      = "手Q";
	[Sdk.ePlatform_QQHall]  = "手Q";
	[Sdk.ePlatform_Guest]   = "遊客";
}

Sdk.Def.tbWeixinLuckBagSetting = {
	["VIP6"] = -- 
		{"hongbaocard_4109_3222164606", "恭喜您達到[FFFE0D]劍俠尊享6[-]！"};
	["VIP9"] = -- 
		{"hongbaocard_4110_3222164606", "恭喜您達到[FFFE0D]劍俠尊享9[-]！"};
	["VIP12"] = -- 
		{"hongbaocard_4111_3222164606", "恭喜您達到[FFFE0D]劍俠尊享12[-]！"};
	["VIP15"] = -- 
		{"hongbaocard_4112_3222164606", "恭喜您達到[FFFE0D]劍俠尊享15[-]！"};
	["FactionNew"] = -- 门派新人王
		{"hongbaocard_4109_3222164606", "恭喜您獲得[FFFE0D]門派新人王[-]！"};
	["FactionMonkey"] = -- 门派大师兄
		{"hongbaocard_4111_3222164606", "恭喜您當選[FFFE0D]門派大師兄[-]！"};
	["Honor6"] = -- 潜龙头衔
		{"hongbaocard_4109_3222164606", "恭喜您達到[FFFE0D]潛龍[-]頭銜！"}; 
	["Honor7"] = -- 傲世头衔
		{"hongbaocard_4109_3222164606", "恭喜您達到[FFFE0D]傲世[-]頭銜！。"};
	["Honor8"] = -- 倚天头衔
		{"hongbaocard_4110_3222164606", "恭喜您達到[FFFE0D]倚天[-]頭銜！"};
	["Honor9"] = -- 至尊头衔
		{"hongbaocard_4110_3222164606", "恭喜您達到[FFFE0D]至尊[-]頭銜！"};
	["Honor10"] = -- 武圣头衔
		{"hongbaocard_4111_3222164606", "恭喜您達到[FFFE0D]武聖[-]頭銜！"};
	["Honor11"] = -- 无双头衔
		{"hongbaocard_4111_3222164606", "恭喜您達到[FFFE0D]無雙[-]頭銜！"};
	["Honor12"] = -- 传说头衔
		{"hongbaocard_4112_3222164606", "恭喜您達到[FFFE0D]傳說[-]頭銜！"};
	["Honor13"] = -- 神话头衔
		{"hongbaocard_4112_3222164606", "恭喜您達到[FFFE0D]神話[-]頭銜！"};

-------------------新增------------------------------
	["WeekActive700"] =
		{"hongbaocard_4109_3222164606", "恭喜您[FFFE0D]連續一周[-]活躍度100！"};
	["KillEmperor"] =
		{"hongbaocard_4110_3222164606", "恭喜您[FFFE0D]擊殺[-]了秦始皇！"};
	["KillFemaleEmperor"] =
		{"hongbaocard_4110_3222164606", "恭喜您[FFFE0D]擊殺[-]了武則天！"};
	["InDifferBattleWin"] = 
		{"hongbaocard_4110_3222164606", "恭喜您在心魔幻境獲得[FFFE0D]優勝[-]！"};
	["FirstSSPartner"] = 
		{"hongbaocard_4110_3222164606", "恭喜您獲得首個[FFFE0D]地級同伴[-]！"};
	["Power100w"] = 
		{"hongbaocard_4111_3222164606", "恭喜您首次戰力達到[FFFE0D]100萬[-]！"};
	["Power200w"] = 
		{"hongbaocard_4112_3222164606", "恭喜您首次戰力達到[FFFE0D]200萬[-]！"};
	["1Friend20L"] = 
		{"hongbaocard_4109_3222164606", "恭喜您首次與[FFFE0D]1名好友親密度達20級[-]！"};
	["3Friend20L"] = 
		{"hongbaocard_4110_3222164606", "恭喜您首次與[FFFE0D]3名好友親密度達20級[-]！"};
	["FirstStudentEliteOut"] = 
		{"hongbaocard_4109_3222164606", "恭喜您首個[FFFE0D]傑出徒弟[-]出師！"};
};


Sdk.Def.tbQQLuckyBagSetting = {
	["VIP6"] = -- 
		{126, 100, 5,
		 "恭喜您達到[FFFE0D]劍俠尊享6[-]！"};
	["VIP9"] = -- 
		{127, 300, 10,
		 "恭喜您達到[FFFE0D]劍俠尊享9[-]！"};
	["VIP12"] = -- 
		{128, 600, 10,
		 "恭喜您達到[FFFE0D]劍俠尊享12[-]！"};
	["VIP15"] = -- 
		{129, 1500, 15,
		 "恭喜您達到[FFFE0D]劍俠尊享15[-]！"};
	["FactionNew"] = -- 门派新人王
		{126, 100, 5,
		 "恭喜您獲得[FFFE0D]門派新人王[-]！"};
	["FactionMonkey"] = -- 门派大师兄
		{128, 600, 10,
		 "恭喜您當選[FFFE0D]門派大師兄[-]！"};
	["Honor6"] = -- 潜龙头衔
		{126, 100, 5,
		 "恭喜您達到[FFFE0D]潛龍[-]頭銜！"}; 
	["Honor7"] = -- 傲世头衔
		{126, 100, 5,
		 "恭喜您達到[FFFE0D]傲世[-]頭銜！。"};
	["Honor8"] = -- 倚天头衔
		{127, 300, 10,
		 "恭喜您達到[FFFE0D]倚天[-]頭銜！"};
	["Honor9"] = -- 至尊头衔
		{127, 300, 10,
		 "恭喜您達到[FFFE0D]至尊[-]頭銜！"};
	["Honor10"] = -- 武圣头衔
		{128, 600, 10,
		 "恭喜您達到[FFFE0D]武聖[-]頭銜！"};
	["Honor11"] = -- 无双头衔
		{128, 600, 10,
		 "恭喜您達到[FFFE0D]無雙[-]頭銜！"};
	["Honor12"] = -- 传说头衔
		{129, 1500, 15,
		 "恭喜您達到[FFFE0D]傳說[-]頭銜！"};
	["Honor13"] = -- 神话头衔
		{129, 1500, 15,
		 "恭喜您達到[FFFE0D]神話[-]頭銜！"};

-------------------新增------------------------------
	["WeekActive700"] =
		{126, 100, 5,
		 "恭喜您[FFFE0D]連續一周[-]活躍度100！"};
	["KillEmperor"] =
		{127, 300, 10,
		 "恭喜您[FFFE0D]擊殺[-]了秦始皇！"};
	["KillFemaleEmperor"] =
		{127, 300, 10,
		 "恭喜您[FFFE0D]擊殺[-]了武則天！"};	 
	["InDifferBattleWin"] = 
		{127, 300, 10,
		 "恭喜您在心魔幻境獲得[FFFE0D]優勝[-]！"};
	["FirstSSPartner"] = 
		{127, 300, 10,
		 "恭喜您獲得首個[FFFE0D]地級同伴[-]！"};
	["Power100w"] = 
		{128, 600, 10,
		 "恭喜您首次戰力達到[FFFE0D]100萬[-]！"};
	["Power200w"] = 
		{129, 1500, 15,
		 "恭喜您首次戰力達到[FFFE0D]200萬[-]！"};
	["1Friend20L"] = 
		{126, 100, 5,
		 "恭喜您首次與[FFFE0D]1名好友親密度達20級[-]！"};
	["3Friend20L"] = 
		{127, 300, 10,
		 "恭喜您首次與[FFFE0D]3名好友親密度達20級[-]！"};
	["FirstStudentEliteOut"] = 
		{126, 100, 5,
		 "恭喜您首個[FFFE0D]傑出徒弟[-]出師！"};
};

function Sdk:GetQQVipRewardState(pPlayer)
	local nLastDayRewardDay = pPlayer.GetUserValue(Sdk.Def.TX_VIP_SAVEGROUP, Sdk.Def.TX_VIP_DAY_REWARD);
	local nLastOpenRewardMonth = pPlayer.GetUserValue(Sdk.Def.TX_VIP_SAVEGROUP, Sdk.Def.TX_VIP_OPEN_REWARD);
	local nLastOpenMonth = pPlayer.GetUserValue(Sdk.Def.TX_VIP_SAVEGROUP, Sdk.Def.TX_VIP_OPEN_MONTH);
	local nLatestOpenVip = pPlayer.GetUserValue(Sdk.Def.TX_VIP_SAVEGROUP, Sdk.Def.TX_VIP_LATEST_OPEN_VIP);
	local nToday = Lib:GetLocalDay();
	local nThisMonth = Lib:GetLocalMonth();
	return nLastDayRewardDay < nToday, nLastOpenRewardMonth < nThisMonth and nLastOpenRewardMonth < nLastOpenMonth, nLatestOpenVip;
end

function Sdk:IsPhoneBinded(pPlayer)
	return pPlayer.GetUserValue(Sdk.Def.SDK_INFO_SAVEGROUP, Sdk.Def.SDK_INFO_BINDED_PHONE) ~= 0;
end

function Sdk:GetFBInviteCount()
	local nToday = Lib:GetLocalDay();
	local nInviteDay = me.GetUserValue(Sdk.Def.SDK_INFO_SAVEGROUP, Sdk.Def.SDK_INFO_FB_INVITE_DAY);
	if nToday ~= nInviteDay then
		return 0;
	end

	local nCurCount = me.GetUserValue(Sdk.Def.SDK_INFO_SAVEGROUP, Sdk.Def.SDK_INFO_FB_INVITE_COUNT);
	return nCurCount;
end

function Sdk:SetQQVipRewardTime(pPlayer, bDayReward, bOpenReward)
	if bDayReward then
		local nToday = Lib:GetLocalDay();
		pPlayer.SetUserValue(Sdk.Def.TX_VIP_SAVEGROUP, Sdk.Def.TX_VIP_DAY_REWARD, nToday);
	end

	if bOpenReward then
		local nThisMonth = Lib:GetLocalMonth();
		pPlayer.SetUserValue(Sdk.Def.TX_VIP_SAVEGROUP, Sdk.Def.TX_VIP_OPEN_REWARD, nThisMonth);
		pPlayer.SetUserValue(Sdk.Def.TX_VIP_SAVEGROUP, Sdk.Def.TX_VIP_OPEN_MONTH, 0);
	end
end

function Sdk:XMIsFacebookClickAwardSend(pPlayer)
	local nFBClicked = pPlayer.GetUserValue(Sdk.Def.SDK_INFO_SAVEGROUP, Sdk.Def.SDK_INFO_XM_FB_CLICK_ED);
	return nFBClicked > 0;
end

function Sdk:XMISEvaluateAwardSend(pPlayer)
	local nEvaluated = pPlayer.GetUserValue(Sdk.Def.SDK_INFO_SAVEGROUP, Sdk.Def.SDK_INFO_XM_EVALUEATE_ED);
	return nEvaluated > 0;
end

function Sdk:IsQQAddFriendAvailable(pPlayer)
	return pPlayer.GetUserValue(Sdk.Def.SDK_INFO_SAVEGROUP, Sdk.Def.SDK_INFO_QQ_INVITE_DISABLE) == 0;
end

function Sdk:IsXinyuePlayer(pPlayer)
	local nXinyueLevel = pPlayer.GetUserValue(Sdk.Def.TX_VIP_SAVEGROUP, Sdk.Def.TX_XINYUE_LEVEL);
	return nXinyueLevel > 0;
end

function Sdk:GetServerId(nServerId)
	if MODULE_GAMESERVER then
		nServerId = GetServerIdentity();
	else
		nServerId = Player.nServerIdentity or SERVER_ID;
	end

	if Sdk:IsTest() and Sdk:IsMsdk() then
		return nServerId + 50000;
	else
		return nServerId;
	end
end

function Sdk:GetPayUid(pPlayer)
	local nServerId = pPlayer.nOrgServerId;
	if nServerId > 0 and Sdk:IsTest() and Sdk:IsMsdk() then
		nServerId = nServerId + 50000;
	end

	if nServerId <= 0 then
		me.CenterMsg("獲取交易資訊異常，請稍後再試");
		Log("Sdk:GetPayUid Error", pPlayer.dwID, pPlayer.szName, nServerId, pPlayer.szAccount);
		assert(false);
		return;
	end
	return string.format("%d_%d", nServerId, pPlayer.dwID);
end

function Sdk:IsTest()
	return SDK_TEST;
end

function Sdk:IsXgSdk()
	return IS_XG_SDK;
end

function Sdk:IsMsdk()
	return not IS_XG_SDK;
end

function Sdk:IsEfunHKTW()
	return version_hk or version_tw;
end

function Sdk:HasEfunRank()
	return version_tw or version_hk or version_xm;
end

local tbMsdkTypeInfo = {
	nOsType       = "number",
	nPlatform     = "number",
	szOpenId      = "string",
	szOpenKey     = "string",
	szPayOpenKey  = "string",
	szPayToken    = "string",
	szSessionId   = "string",
	szSessionType = "string",
	szPf          = "string",
	szPfKey       = "string",
}

function Sdk:CheckMsdkTypeInfo(tbMsdkInfo)
	if type(tbMsdkInfo) ~= "table" then
		return false;
	end

	for szKey, szType in pairs(tbMsdkTypeInfo) do
		if type(tbMsdkInfo[szKey]) ~= szType then
			Log("[Error]Sdk:CheckMsdkTypeInfo", szKey, szType, type(tbMsdkInfo[szKey]));
			return false;
		end
	end
	return true;
end

local tbMainId2ZoneName = {
	[10000] = "安卓微信";
	[20000] = "安卓手Q";
	[30000] = "iOS微信";
	[40000] = "iOS手Q";
	[50000] = "iOS遊客";
}

function Sdk:GetServerDesc(nServerId)
	local nSubServerId = nServerId % 10000;
	local nMainId = nServerId - nSubServerId;
	if not version_tx then
		return string.format("%d服", nSubServerId);
	end

	return string.format("%s%d服", tbMainId2ZoneName[nMainId] or "null", nSubServerId), tbMainId2ZoneName[nMainId];
end

function Sdk:GetAreaIdByPlatform(nPlatform)
	if nPlatform == Sdk.ePlatform_Weixin then
		return 1;
	elseif nPlatform == Sdk.ePlatform_QQ then
		return 2;
	elseif nPlatform == Sdk.ePlatform_Guest then
		return 3;
	end
	return 0;
end