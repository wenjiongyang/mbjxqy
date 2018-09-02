Transmit.tbIDIPInterface = Transmit.tbIDIPInterface or {};
local tbIDIPInterface = Transmit.tbIDIPInterface;

local IDIP_SUCCESS = 0
local IDIP_PLAYER_NOT_EXIST = 1
local IDIP_NET_ERROR = -1
local IDIP_TIME_OUT = -2
local IDIP_DB_ERROR = -3
local IDIP_API_ERROR = -4
local IDIP_SERVER_NO_RESPONSE = -5
local IDIP_OTHER_ERROR = -6
local IDIP_INVALID_PARAM = -100
local IDIP_SERVER_OFFLINE = -101
local IDIP_INTERNAL_ERR = -102
local IDIP_PLAYER_BAG_FULL = -103
local IDIP_INVALID_ITEM_ID = -104
local IDIP_INVALID_ITEM_TYPE = -105
local IDIP_INVALID_OPEN_ID = -106
local IDIP_INVALID_PARTNER_ID = -107
local IDIP_ACCOUNT_ROLEID_NOT_MATCH = -108
local IDIP_ROLEID_ROLENAME_NOT_MATCH = -109
local IDIP_KIN_NOT_FOUND = -110
local IDIP_NOT_Time = -111
local IDIP_KINID_ROLEID_NOT_MATCH = -112
local IDIP_VALID_BATCH_ID = -113
local IDIP_EXIST_AUCTION_ID = -114
local IDIP_NO_EXIST_AUCTION_ID = -115
local IDIP_NO_EXIST_MSG_ID = -116
local IDIP_FACTION_RANK_NOT_FIND = -117
local IDIP_INVALID_TYPE = -118
local IDIP_NEW_MSG_REMOVE_FAIL = -119
local IDIP_NEW_MSG_ADD_FAIL = -120
local IDIP_NEW_MSG_INFO_NO_FIND = -121
local IDIP_EXIST_NEW_MSG_ID = -122
local IDIP_NO_EXIST_AUCTION_INFO = -123
local IDIP_AUCTION_ADD_FAIL = -124
local IDIP_VALID_TITLE_TIME = -125
local IDIP_NO_TITLE_INFO = -126
local IDIP_PLAYER_OFFLINE = -127
local IDIP_OTHER_PLAYER_NO_EXIST = -128
local IDIP_RED_DACKET_PARAM_ERR = -129
local IDIP_NO_EXIST_ID = -130
local IDIP_INVALID_REASON2 = -131
local IDIP_EXIST_ID = -132
local IDIP_ACTIVITY_NOT_START = -133


local ErrPlayerNotExist = string.format("%d player not exist", IDIP_PLAYER_NOT_EXIST)
local ErrNetError = string.format("%d net error", IDIP_NET_ERROR)
local ErrTimeOut = string.format("%d time out", IDIP_TIME_OUT)
local ErrDBError = string.format("%d DB error", IDIP_DB_ERROR)
local ErrAPIError = string.format("%d API error", IDIP_API_ERROR)
local ErrServerNoResponse = string.format("%d server no response", IDIP_SERVER_NO_RESPONSE)
local ErrOtherError = string.format("%d other error", IDIP_OTHER_ERROR)
local ErrInvalidParam = string.format("%d invalid param", IDIP_INVALID_PARAM)
local ErrServerOffLine = string.format("%d server offline", IDIP_SERVER_OFFLINE)
local ErrInternalError = string.format("%d internal error", IDIP_INTERNAL_ERR)
local ErrPlayerBagFull = string.format("%d player bag full", IDIP_PLAYER_BAG_FULL)
local ErrInValidItemId = string.format("%d item have no exist", IDIP_INVALID_ITEM_ID)
local ErrInValidItemType = string.format("%d invalid item type", IDIP_INVALID_ITEM_TYPE)
local ErrInValidOpenId = string.format("%d account is no exist", IDIP_INVALID_OPEN_ID)
local ErrInValidPartnerId = string.format("%d partner is no exist", IDIP_INVALID_PARTNER_ID)
local ErrInValidAccountRoleIdNotMatch = string.format("%d account not match role id", IDIP_ACCOUNT_ROLEID_NOT_MATCH)
local ErrInValidRoleIdRoleNameNotMatch = string.format("%d role id not match role name", IDIP_ROLEID_ROLENAME_NOT_MATCH)
local ErrKinNotFound = string.format("%d can not found kin", IDIP_KIN_NOT_FOUND)
local ErrNoTime = string.format("%d no mask time", IDIP_NOT_Time)
local ErrRoleIdKinIdNotMatch = string.format("%d role id not match kin id", IDIP_KINID_ROLEID_NOT_MATCH)
local ErrValidBatchId = string.format("%d valid batch id", IDIP_VALID_BATCH_ID)
local ErrExistAuctionId = string.format("%d same auction id", IDIP_EXIST_AUCTION_ID)
local ErrNoExistAuctionId = string.format("%d no exist auction id", IDIP_NO_EXIST_AUCTION_ID)
local ErrNoExistMsgId = string.format("%d no exist msg id", IDIP_NO_EXIST_MSG_ID)
local ErrFactionRankNotFind = string.format("%d no find faction rank", IDIP_FACTION_RANK_NOT_FIND)
local ErrInValidType = string.format("%d valid type", IDIP_INVALID_TYPE)
local ErrNewMsgRemoveFail = string.format("%d new msg remove fail", IDIP_NEW_MSG_REMOVE_FAIL)
local ErrNewMsgAddFail = string.format("%d new msg add fail", IDIP_NEW_MSG_ADD_FAIL)
local ErrNewMsgInfoNoFind = string.format("%d new msg info no find", IDIP_NEW_MSG_INFO_NO_FIND)
local ErrExistNewMsgId = string.format("%d exist new msg id", IDIP_EXIST_NEW_MSG_ID)
local ErrNoExistAuctionInfo = string.format("%d no exist auction info", IDIP_NO_EXIST_AUCTION_INFO)
local ErrAuctionAddFail = string.format("%d auction add fail", IDIP_AUCTION_ADD_FAIL)
local ErrValidTitleTime = string.format("%d valid title time", IDIP_VALID_TITLE_TIME)
local ErrNoTitleInfo = string.format("%d no title info", IDIP_NO_TITLE_INFO)
local ErrPlayerOffline = string.format("%d player offline", IDIP_PLAYER_OFFLINE)
local ErrOtherPlayerNoExist = string.format("%d other player no exist", IDIP_OTHER_PLAYER_NO_EXIST)
local ErrRedDacketParam = string.format("%d szRedKey has exist or RedType not exist or RedId has exist", IDIP_RED_DACKET_PARAM_ERR)
local ErrNoExistId = string.format("%d not exist id", IDIP_NO_EXIST_ID)
local ErrInvalidReason2 = string.format("%d invalid reason2", IDIP_INVALID_REASON2)
local ErrExistId = string.format("%d exist id", IDIP_EXIST_ID)
local ErrActivityNotStart = string.format("%d Activity Not Start", IDIP_ACTIVITY_NOT_START)

local tbItemType =
{
	["Gold"]    = 1,
	["Coin"]    = 2,
	["item"] 	= 3,
	["Partner"] = 4,
	["Contrib"] = 5,
	["Honor"] 	= 6,
	["Exp"] 	= 7,
	["BaseExp"] = 8,
	["AddTimeTitle"] = 9,
	["Energy"] = 10,
	["SilverBoard"] = 11,
}

local KinNoticeType =
{
	Notice  = 1,
	Declare = 2,
	All     = 99,
}

local MsgType =
{
	System 		= 0,
	World = 1,
	ZouMaDeng = 2,
	All = 99,
}

local BossType =
{
	BossLeader = 1,							-- 历代名将
	FieldBoss  = 2,							-- 野外boss
	Boss 	   = 3,							-- 武林盟主
	WhiteTiger = 4,							-- 白虎堂
}

local BanOfflineRankType = 					-- 禁止参与排行榜（离线榜）(AQ)
{
	LevelRank 			= 1,						-- 等级排行榜
	FightPowerRank 		= 2,						-- 战力排行榜
	KinRank 			= 3,						-- 家族排行榜
	WuShenRank 			= 4,						-- 武神殿
	FactionRank 		= 5, 						-- 门派排行榜
	EquipRank 			= 6,						-- 洗练排行榜
	StrengthenRank 		= 7,						-- 强化排行榜
	StoneRank 			= 8,						-- 镶嵌排行榜
	PartnerRank 		= 9,						-- 同伴排行榜
	CardCollection_1Rank= 10,						-- 凌绝峰收集榜
	AllRank  			= 99,						-- 全选
}

-- 普遍处理
tbIDIPInterface.BanOfflineRankTypeCommon =
{
	[BanOfflineRankType.LevelRank] 				 = {nBanType = Forbid.BanType.LevelRank,szRankTitle = "等級排行榜"},
	[BanOfflineRankType.FightPowerRank] 		 = {nBanType = Forbid.BanType.FightPowerRank,szRankTitle = "戰力排行榜"},
	[BanOfflineRankType.WuShenRank]			 	 = {nBanType = Forbid.BanType.WuShenRank,szRankTitle = "武神殿排行榜"},
	[BanOfflineRankType.FactionRank]			 = {nBanType = Forbid.BanType.FightPower_Faction,szRankTitle = "門派排行榜"},
	[BanOfflineRankType.EquipRank] 				 = {nBanType = Forbid.BanType.FightPower_Equip,szRankTitle = "洗練排行榜"},
	[BanOfflineRankType.StrengthenRank] 	     = {nBanType = Forbid.BanType.FightPower_Strengthen,szRankTitle = "強化排行榜"},
	[BanOfflineRankType.StoneRank] 				 = {nBanType = Forbid.BanType.FightPower_Stone,szRankTitle = "鑲嵌排行榜"},
	[BanOfflineRankType.PartnerRank]			 = {nBanType = Forbid.BanType.FightPower_Partner,szRankTitle = "同伴排行榜"},
	[BanOfflineRankType.CardCollection_1Rank]	 = {nBanType = Forbid.BanType.CardCollection_1,szRankTitle = "凌絕峰收集榜"},

}


local BanCurrentRankType =					-- 实时榜
{
	WuLinMengZhu = 6,
	AllRank = 99
}

local BanGroupOfflineRankType =
{
	KinRank = 1,
	AllRank = 99
}
local tbMoneyType =
{
	[1] = "Honor",
	[2] = "Contrib",
}

local tbMailSendType =
{
	[1] = "Honor",
	[2] = "Contrib",
}

tbIDIPInterface.tbMsgTimer = tbIDIPInterface.tbMsgTimer or {nTimerCount = 0,tbAllTimer = {}}

--[[
	tbIDIPInterface.tbStallItem[nBatchId] = nStallId
]]

tbIDIPInterface.tbStallItem = tbIDIPInterface.tbStallItem or {} 								-- 指令摆摊上架的货物

tbIDIPInterface.AuctionType =
{
	[2] = "Boss",
	[3] = "BossLeader_Boss",
	[5] = "DomainBattle",
	[6] = "KinTrain",
	[7] = "DomainBattleAct",
}

local tbLoopMsgType =
{
	ZouMaDeng = 1,
}

tbIDIPInterface.tbClearRank =
{
	FightPower = "戰力排行榜",
	Level 	   = "等級排行榜",
	FightPower_Equip = "洗練",
	FightPower_Strengthen = "強化",
	FightPower_Stone = "鑲嵌",
	FightPower_Partner = "同伴",
	CardCollection_1 = "凌絕峰收集榜",
}

local Recharge_Type =
{
	LEVEL_6 		= 1,
	LEVEL_30 		= 2,
	LEVEL_98 		= 3,
	LEVEL_198 		= 4,
	LEVEL_328 		= 5,
	LEVEL_648 		= 6,
	YIBENWANLI_1 	= 7,
	YIBENWANLI_2 	= 8,
	FIRSTCHARGE		= 9,
	YIBENWANLI_3    = 10,
	YIBENWANLI_4    = 11,
	YIBENWANLI_5    = 12,
}

local tbRechargeData =
	{
		[Recharge_Type.LEVEL_6] =
		{
			tbParam = {1},
			szCall = "SetBuyGold",
		},
		[Recharge_Type.LEVEL_30] =
		{
			tbParam = {2},
			szCall = "SetBuyGold",
		},
		[Recharge_Type.LEVEL_98] =
		{
			tbParam = {3},
			szCall = "SetBuyGold",
		},
		[Recharge_Type.LEVEL_198] =
		{
			tbParam = {4},
			szCall = "SetBuyGold",
		},
		[Recharge_Type.LEVEL_328] =
		{
			tbParam = {5},
			szCall = "SetBuyGold",
		},
		[Recharge_Type.LEVEL_648] =
		{
			tbParam = {6},
			szCall = "SetBuyGold",
		},
		[Recharge_Type.YIBENWANLI_1] =
		{
			tbParam = {1, 59},
			szCall = "SetYiBenWanLi",
		},
		[Recharge_Type.YIBENWANLI_2] =
		{
			tbParam = {2, 60},
			szCall = "SetYiBenWanLi",
		},
		[Recharge_Type.FIRSTCHARGE] =
		{
			szCall = "SetFirstCharge",
		},
		[Recharge_Type.YIBENWANLI_3] =
		{
			szCall = "SetYiBenWanLi",
			tbParam = {3, 65},
		},
		[Recharge_Type.YIBENWANLI_4] =
		{
			szCall = "SetYiBenWanLi",
			tbParam = {5, 73},
		},
		[Recharge_Type.YIBENWANLI_5] =
		{
			szCall = "SetYiBenWanLi",
			tbParam = {6, 74},
		},
	}

local New_Year_Recharge_Type =
{
	YIBENWANLI_NewYear = 1,
	LEVEL_648 = 2,
	LEVEL_298 = 3,
	LEVEL_98 = 4,
	LEVEL_30 = 5,
}

local tbNewYearRechargeData =
{
	[New_Year_Recharge_Type.YIBENWANLI_NewYear] =
	{
		tbParam = {4},
		szCall = "SetYiBenWanLiNewYear",
	},
	[New_Year_Recharge_Type.LEVEL_648] =
	{
		tbParam = {4},
		szCall = "OnBuyYearGift",
	},
	[New_Year_Recharge_Type.LEVEL_298] =
	{
		tbParam = {3},
		szCall = "OnBuyYearGift",
	},
	[New_Year_Recharge_Type.LEVEL_98] =
	{
		tbParam = {2},
		szCall = "OnBuyYearGift",
	},
	[New_Year_Recharge_Type.LEVEL_30] =
	{
		tbParam = {1},
		szCall = "OnBuyYearGift",
	},
}

local ChannelType =
{

	Kin = 1,
	Friend = 2,
	Private = 3,
}

local NewMsgType = 
{
	Level_1 = 1,			-- 抢购
	Level_2 = 2,			-- 紧急
	Level_3 = 3,			-- 活动
	Level_4 = 4,			-- 公告
}

local tbAllNewMsgType = 
{
	[NewMsgType.Level_1] = "搶購",
	[NewMsgType.Level_2] = "緊急",
	[NewMsgType.Level_3] = "活動",
	[NewMsgType.Level_4] = "公告",
}

local NewMsgRPType = 
{
	ShowDaily 	= 1, 
	ShowOne     = 2,
	ShowOnLogin = 3,
}
-- 类型2：最新消息发布后只给一次红点 直接传nil
local tbNewMsgRPRefresh = 
{
	[NewMsgRPType.ShowDaily] = "fnShowDaily", 					-- 最新消息持续期间每天刷新一次
	[NewMsgRPType.ShowOnLogin] = "fnShowOnLogin", 					-- 最新消息持续期间每次上线都刷新一次
}


function Transmit:IDIPRequest(strCmdType, nCmdId, szJson, nCmdSequence)
	local tbReq = Lib:DecodeJson(szJson);

	--Log(strCmdType)
	--Lib:LogTB(tbReq);

	local szRspJson = ""
	local tbRspJson = nil
	local nResult = IDIP_INVALID_PARAM
	local szErrMsg = ErrInvalidParam

	if tbIDIPInterface[strCmdType] then
		nResult, tbRspJson, szErrMsg = tbIDIPInterface[strCmdType](tbIDIPInterface, nCmdId, tbReq,nCmdSequence);
	end
	if nResult then
		if tbRspJson  then
			szRspJson = Lib:EncodeJson(tbRspJson);
		end
		if nResult ~= IDIP_SUCCESS then
			Log(strCmdType)
			Lib:LogTB(tbReq);
			Log("Result:", nResult, szRspJson, szErrMsg);
		end
		IDIPRespond(strCmdType, nResult, szErrMsg, szRspJson, nCmdSequence);
	end
end

function Transmit:OnIDIPKickPlayerByAccount(pPlayer, szReason)
	if pPlayer and szReason ~= "" then
		pPlayer.CallClientScript("Ui:OnShowKickMsg", szReason);
	end
end

function tbIDIPInterface:IDIPDelayResponse(nResult,tbRspJson,szErrMsg,strCmdType,nCmdSequence)
	if nResult and tbIDIPInterface[strCmdType] then
		local szRspJson = ""
		if tbRspJson then
			szRspJson = Lib:EncodeJson(tbRspJson);
		end
		if nResult ~= IDIP_SUCCESS then
			Log(strCmdType)
			Log("Result:", nResult, szRspJson, szErrMsg);
		end
		IDIPRespond(strCmdType, nResult, szErrMsg, szRspJson, nCmdSequence);
	else
		IDIPRespond(strCmdType, IDIP_INVALID_PARAM, ErrInvalidParam, "", nCmdSequence);
	end
end

function tbIDIPInterface:GetReducePower(pPlayer,nPower)
	local nOrgPower = 0
	if math.abs(nPower) > nOrgPower then
		return nOrgPower;
	end
	return math.abs(nPower);
end

function tbIDIPInterface:IDIP_DO_DEL_PHYSICAL_REQ(nCmdId, tbReq, nCmdSequence)
	Player:DoAccountRoleMatchRequest(tbReq.OpenId,tbReq.RoleId,Transmit.tbIDIPInterface.OnDelPhysicalCheckFinish,Transmit.tbIDIPInterface,nCmdId,tbReq,nCmdSequence);
end

function tbIDIPInterface:OnDelPhysicalCheckFinish(szAccount, dwPlayerId, nIsMatch,nCmdId, tbReq, nCmdSequence)
	local tbRsp =
	{
		Result = IDIP_SUCCESS,
		RetMsg = "ok",
	}
	if nIsMatch == 0 then
		tbRsp.Result = IDIP_PLAYER_NOT_EXIST;
		tbRsp.RetMsg = ErrInValidAccountRoleIdNotMatch;
		self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_DO_DEL_PHYSICAL_REQ", nCmdSequence)
		return
	end

	local nPower = tonumber(tbReq.Value);
	if not nPower then
		tbRsp.Result = IDIP_INVALID_PARAM;
		tbRsp.RetMsg = ErrInvalidParam;
		self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_DO_DEL_PHYSICAL_REQ", nCmdSequence)
	end
	local pPlayer = KPlayer.GetPlayerObjById(tbReq.RoleId);
	if pPlayer then
		if nPower >= 0 then
			pPlayer.AddPhysicalPower(nPower, true, "IDIP_DO_DEL_PHYSICAL_REQ");
		elseif nPower < 0 then
			local nReduPower = self:GetReducePower(pPlayer,nPower);
			pPlayer.SubPhysicalPower(nReduPower, "IDIP_DO_DEL_PHYSICAL_REQ");
		end
	else
		local pPlayerInfo = KPlayer.GetRoleStayInfo(tbReq.RoleId);
		if pPlayerInfo then
			local szCmd = "";
			if nPower >= 0 then
				szCmd = string.format("me.AddPhysicalPower(%d, true, 'IDIP_DO_DEL_PHYSICAL_REQ')",nPower);
			elseif nPower < 0 then
				szCmd = string.format("local nReduPower = Transmit.tbIDIPInterface:GetReducePower(me,%d);me.SubPhysicalPower(nReduPower, 'IDIP_DO_DEL_PHYSICAL_REQ')",nPower);
			end
			KPlayer.AddDelayCmd(tbReq.RoleId,
				szCmd,
				string.format("%s|%d|%s|%s", 'IDIP_DO_DEL_PHYSICAL_REQ', nPower, tbReq.Source, tbReq.Serial))
		else
			tbRsp.Result = IDIP_PLAYER_NOT_EXIST
			tbRsp.RetMsg = ErrPlayerNotExist
		end
	end
	TLog("IDIPFLOW", tbReq.AreaId, tbReq.OpenId, 0, tbReq.Value, tbReq.Serial, tbReq.Source, nCmdId, tbReq.PlatId,
		tbReq.Partition, tbReq.RoleId, 0, "IDIP_DO_DEL_PHYSICAL_REQ", (pPlayer and "immediately") or "delay")

	self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_DO_DEL_PHYSICAL_REQ", nCmdSequence)
end

function tbIDIPInterface:GetCost(pPlayer, szType, nCost)
	local nOrg = pPlayer.GetMoney(szType)
	if nOrg >= 0 and nOrg < math.abs(nCost) then
		return nOrg;
	end
	return math.abs(nCost);
end

function tbIDIPInterface:IDIP_DO_DEL_MONEY_REQ(nCmdId, tbReq,nCmdSequence)
	Player:DoAccountRoleMatchRequest(tbReq.OpenId,tbReq.RoleId,Transmit.tbIDIPInterface.OnDelMoneyCheckFinish,Transmit.tbIDIPInterface,nCmdId,tbReq,nCmdSequence);
end

function tbIDIPInterface:OnDelMoneyCheckFinish(szAccount, dwPlayerId, nIsMatch,nCmdId, tbReq, nCmdSequence)
	local tbRsp =
	{
		Result = IDIP_SUCCESS,
		RetMsg = "ok",
	}
	if nIsMatch == 0 then
		tbRsp.Result = IDIP_PLAYER_NOT_EXIST;
		tbRsp.RetMsg = ErrInValidAccountRoleIdNotMatch;
		self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_DO_DEL_MONEY_REQ", nCmdSequence)
		return
	end
	local nCoin = tonumber(tbReq.Value);
	if not nCoin then
		tbRsp.Result = IDIP_INVALID_PARAM
		tbRsp.RetMsg = ErrInvalidParam
		self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_DO_DEL_MONEY_REQ", nCmdSequence)
		return
	end
	local pPlayer = KPlayer.GetPlayerObjById(tbReq.RoleId);
	if pPlayer then
		if nCoin >= 0 then
			pPlayer.AddMoney("Coin",nCoin,Env.LogWay_IdipDoDelMoneyReq);
		elseif nCoin < 0 then
			local nCost = self:GetCost(pPlayer,"Coin",nCoin);
			pPlayer.CostMoney("Coin",nCost,Env.LogWay_IdipDoDelMoneyReq);
		end
	else
		local pPlayerInfo = KPlayer.GetRoleStayInfo(tbReq.RoleId);
		if pPlayerInfo then
			local szCmd = "";
			local nCost = nCoin;
			if nCost >= 0 then
				szCmd = string.format("me.AddMoney('Coin', %d, %d)",nCost,Env.LogWay_IdipDoDelMoneyReq);
			elseif nCost < 0 then
				szCmd = string.format("local nCost = Transmit.tbIDIPInterface:GetCost(me,'Coin',%d);me.CostMoney('Coin', math.abs(nCost), %d)",nCost,Env.LogWay_IdipDoDelMoneyReq);
			end
			KPlayer.AddDelayCmd(tbReq.RoleId,
				szCmd,
				string.format("%s|%d|%s|%s", 'IDIP_DO_DEL_MONEY_REQ', nCost, tbReq.Source, tbReq.Serial))
		else
			tbRsp.Result = IDIP_PLAYER_NOT_EXIST
			tbRsp.RetMsg = ErrPlayerNotExist
		end
	end

	TLog("IDIPFLOW", tbReq.AreaId, tbReq.OpenId, 0, tbReq.Value, tbReq.Serial, tbReq.Source, nCmdId, tbReq.PlatId,
		tbReq.Partition, tbReq.RoleId, 0, "IDIP_DO_DEL_MONEY_REQ", (pPlayer and "immediately") or "delay")

	self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_DO_DEL_MONEY_REQ", nCmdSequence)
end

function tbIDIPInterface:IdipTryDelayCostGold(nPlayerId,nGold,nIsNegative,szSource,szSerial)
	local szCmd = "";
	local szLog = string.format("%s|%d|%s|%s", 'IDIP_DO_DEL_DIAMOND_REQ', nGold, szSource,szSerial)
	if nGold >= 0 then
		szCmd = string.format("me.AddMoney('Gold', %d, %d)",nGold,Env.LogWay_IdipDoDelDiamondReq);
	elseif nGold < 0 then
		szCmd = string.format("Transmit.tbIDIPInterface:IdipDelayCostGold(%u,%d,%d,'%s','%s')",nPlayerId,nGold,nIsNegative or 0,szSource,szSerial)
	end
	KPlayer.AddDelayCmd(nPlayerId,szCmd,szLog)
	Log("IDIP_DO_DEL_DIAMOND_REQ IdipTryDelayCostGold AddDelayCmd",nPlayerId,nGold, nIsNegative,szCmd)
end

function tbIDIPInterface:IdipDelayCostGold(nPlayerId,nGold, nIsNegative,szSource,szSerial)
	Log("IDIP_DO_DEL_DIAMOND_REQ IdipDelayCostGold execute",nPlayerId,nGold, nIsNegative)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		self:IdipTryDelayCostGold(nPlayerId,nGold,nIsNegative,szSource,szSerial);
		Log("IDIP_DO_DEL_DIAMOND_REQ IdipDelayCostGold not pPlayer add 2 delay cmd", nPlayerId,nGold,nIsNegative);
		return
	end

	local nCost = self:GetCost(pPlayer,"Gold",nGold);
	if nCost == 0 then
		if nIsNegative == 1 then
			Player:AddMoneyDebt(nPlayerId, "Gold", math.abs(nGold), Env.LogWay_Money_Debt_Add, 0, true)
			Log("IDIP_DO_DEL_DIAMOND_REQ IdipDelayCostGold AddMoneyDebt dir", nPlayerId,nGold,nCost,nIsNegative);
		end
		return
	end
	pPlayer.CostGold(nCost,Env.LogWay_IdipDoDelDiamondReq,nil,function (nPlayerId, bSuccess)
			if bSuccess then
				if nIsNegative == 1 and math.abs(nGold) > nCost then
					Player:AddMoneyDebt(nPlayerId, "Gold", math.abs(nGold) - nCost, Env.LogWay_Money_Debt_Add, 0, true)
					Log("IDIP_DO_DEL_DIAMOND_REQ IdipDelayCostGold CostGold AddMoneyDebt ", nPlayerId,nGold,nCost,nIsNegative);
				end
				Log("IDIP_DO_DEL_DIAMOND_REQ IdipDelayCostGold CostGold success ", nPlayerId,nGold,nCost,nIsNegative);
				return true
			end
			-- 扣除失败直接加延迟指令
			Transmit.tbIDIPInterface:IdipTryDelayCostGold(nPlayerId,nGold,nIsNegative,szSource,szSerial);
			Log("IDIP_DO_DEL_DIAMOND_REQ IdipDelayCostGold CostGold fail add 2 delay cmd", nPlayerId,nGold,nCost,nIsNegative);
			return true;
		end);
end

function tbIDIPInterface:IdipCostGold(nPlayerId,nGold,nIsNegative,szSource,szSerial)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		self:IdipTryDelayCostGold(nPlayerId,nGold,nIsNegative,szSource,szSerial)
		Log("IDIP_DO_DEL_DIAMOND_REQ IdipCostGold not pPlayer add 2 delay cmd", nPlayerId,nGold,nIsNegative);
		return
	end

	local nCost = self:GetCost(pPlayer,"Gold",nGold);
	if nCost == 0 then
		if nIsNegative == 1 then
			Player:AddMoneyDebt(nPlayerId, "Gold", math.abs(nGold), Env.LogWay_Money_Debt_Add, 0, true)
			Log("IDIP_DO_DEL_DIAMOND_REQ IdipCostGold AddMoneyDebt dir", nPlayerId,nGold,nCost,nIsNegative);
		end
		return
	end
	pPlayer.CostGold(nCost,Env.LogWay_IdipDoDelDiamondReq,nil,Transmit.tbIDIPInterface.OnCostGoldCallBack, szSource, szSerial,nGold,nCost,nIsNegative);
end

function tbIDIPInterface.OnCostGoldCallBack(nPlayerId, bSuccess,szBilloNo, szSource, szSerial,nGold,nCost,nIsNegative)
	if bSuccess then
		if nIsNegative == 1 and math.abs(nGold) > nCost then
			Player:AddMoneyDebt(nPlayerId, "Gold", math.abs(nGold) - nCost, Env.LogWay_Money_Debt_Add, 0, true)
			Log("IDIP_DO_DEL_DIAMOND_REQ OnCostGoldCallBack CostGold AddMoneyDebt ", nPlayerId,nGold,nCost,nIsNegative);
		end
		Log("IDIP_DO_DEL_DIAMOND_REQ OnCostGoldCallBack CostGold success ", nPlayerId,nGold,nCost,nIsNegative);
		return true
	end

	--不成功强制加延迟指令
	Transmit.tbIDIPInterface:IdipTryDelayCostGold(nPlayerId,nGold,nIsNegative,szSource,szSerial)
	Log("IDIP_DO_DEL_DIAMOND_REQ OnCostGoldCallBack CostGold fail add 2 delay cmd", nPlayerId,nGold,nCost,nIsNegative);
	return true
end

function tbIDIPInterface:IDIP_DO_DEL_DIAMOND_REQ(nCmdId, tbReq,nCmdSequence)
	Player:DoAccountRoleMatchRequest(tbReq.OpenId,tbReq.RoleId,Transmit.tbIDIPInterface.OnDelDiamondCheckFinish,Transmit.tbIDIPInterface,nCmdId,tbReq,nCmdSequence);
end

function tbIDIPInterface:OnDelDiamondCheckFinish(szAccount, dwPlayerId, nIsMatch,nCmdId, tbReq, nCmdSequence)
	local tbRsp =
	{
		Result = IDIP_SUCCESS,
		RetMsg = "ok",
	}
	if nIsMatch == 0 then
		tbRsp.Result = IDIP_PLAYER_NOT_EXIST;
		tbRsp.RetMsg = ErrInValidAccountRoleIdNotMatch;
		self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_DO_DEL_DIAMOND_REQ", nCmdSequence)
		return
	end

	local nGold = tonumber(tbReq.Value);
	local nIsNegative = tonumber(tbReq.IsNegative) or 0;

	if not nGold or not Shop.tbMoney["Gold"] then
		tbRsp.Result = IDIP_INVALID_PARAM
		tbRsp.RetMsg = ErrInvalidParam
		self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_DO_DEL_DIAMOND_REQ", nCmdSequence)
		return
	end

	local pPlayer = KPlayer.GetPlayerObjById(tbReq.RoleId);

	if pPlayer then
		if nGold >= 0 then
			pPlayer.AddMoney("Gold",nGold,Env.LogWay_IdipDoDelDiamondReq);
		elseif nGold < 0 then
			self:IdipCostGold(tbReq.RoleId, nGold, nIsNegative, tbReq.Source, tbReq.Serial);
		end
	else
		local pPlayerInfo = KPlayer.GetRoleStayInfo(tbReq.RoleId);
		if pPlayerInfo then
			self:IdipTryDelayCostGold(tbReq.RoleId,nGold, nIsNegative, tbReq.Source, tbReq.Serial)
		else
			tbRsp.Result = IDIP_PLAYER_NOT_EXIST
			tbRsp.RetMsg = ErrPlayerNotExist
		end
	end

	TLog("IDIPFLOW", tbReq.AreaId, tbReq.OpenId, 0, tbReq.Value, tbReq.Serial, tbReq.Source, nCmdId, tbReq.PlatId,
		tbReq.Partition, tbReq.RoleId, 0, "IDIP_DO_DEL_DIAMOND_REQ", (pPlayer and "immediately") or "delay")

	self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_DO_DEL_DIAMOND_REQ", nCmdSequence)
end

function tbIDIPInterface:IDIP_DO_DEL_EXP_REQ(nCmdId, tbReq, nCmdSequence)
	Player:DoAccountRoleMatchRequest(tbReq.OpenId,tbReq.RoleId,Transmit.tbIDIPInterface.OnDelExpCheckFinish,Transmit.tbIDIPInterface,nCmdId,tbReq,nCmdSequence);
end

function tbIDIPInterface:OnDelExpCheckFinish(szAccount, dwPlayerId, nIsMatch,nCmdId, tbReq, nCmdSequence)
	local tbRsp =
	{
		Result = IDIP_SUCCESS,
		RetMsg = "ok",
	};
	if nIsMatch == 0 then
		tbRsp.Result = IDIP_PLAYER_NOT_EXIST;
		tbRsp.RetMsg = ErrInValidAccountRoleIdNotMatch;
		self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_DO_DEL_EXP_REQ", nCmdSequence)
		return
	end
	local nExp = tonumber(tbReq.Value);
	if not nExp then
		tbRsp.Result = IDIP_INVALID_PARAM;
		tbRsp.RetMsg = ErrInvalidParam;
		self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_DO_DEL_EXP_REQ", nCmdSequence)
		return
	end
	local pPlayer = KPlayer.GetPlayerObjById(tbReq.RoleId);
	if pPlayer then
		if nExp >= 0 then
			pPlayer.AddExperience(nExp,Env.LogWay_IdipDoDelExpReq);
		elseif nExp < 0 then
			pPlayer.ReduceExp(math.abs(nExp),Env.LogWay_IdipDoDelExpReq);
		end
	else
		local pPlayerInfo = KPlayer.GetRoleStayInfo(tbReq.RoleId);
		if pPlayerInfo then
			local szCmd = "";
			if nExp >= 0 then
				szCmd = string.format("me.AddExperience(%d,Env.LogWay_IdipDoDelExpReq)",nExp);
			elseif nExp < 0 then
				szCmd = string.format("me.ReduceExp(math.abs(%d),Env.LogWay_IdipDoDelExpReq)",nExp);
			end
			KPlayer.AddDelayCmd(tbReq.RoleId,
				szCmd,
				string.format("%s|%d|%s|%s", 'IDIP_DO_DEL_EXP_REQ', nExp, tbReq.Source, tbReq.Serial))
		else
			tbRsp.Result = IDIP_PLAYER_NOT_EXIST
			tbRsp.RetMsg = ErrPlayerNotExist
		end
	end

	TLog("IDIPFLOW", tbReq.AreaId, tbReq.OpenId, 0, tbReq.Value, tbReq.Serial, tbReq.Source, nCmdId, tbReq.PlatId,
		tbReq.Partition, tbReq.RoleId, 0, "IDIP_DO_DEL_EXP_REQ", (pPlayer and "immediately") or "delay")

	self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_DO_DEL_EXP_REQ", nCmdSequence)
end

function tbIDIPInterface:GetConsumeNum(pPlayer,nItemId,nCount)
	if nCount < 0 then
		local nOrgCount = pPlayer.GetItemCountInAllPos(nItemId);
		if nOrgCount < math.abs(nCount) then
			return nOrgCount;
		end

	end
	return math.abs(nCount);
end

function tbIDIPInterface:IDIP_DO_DEL_ITEM_REQ(nCmdId, tbReq, nCmdSequence)
	Player:DoAccountRoleMatchRequest(tbReq.OpenId,tbReq.RoleId,Transmit.tbIDIPInterface.OnDelItemCheckFinish,Transmit.tbIDIPInterface,nCmdId,tbReq,nCmdSequence);
end

function tbIDIPInterface:OnDelItemCheckFinish(szAccount, dwPlayerId, nIsMatch,nCmdId, tbReq, nCmdSequence)
	local tbRsp =
	{
		Result = IDIP_SUCCESS,
		RetMsg = "ok",
	}
	if nIsMatch == 0 then
		tbRsp.Result = IDIP_PLAYER_NOT_EXIST;
		tbRsp.RetMsg = ErrInValidAccountRoleIdNotMatch;
		self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_DO_DEL_ITEM_REQ", nCmdSequence)
		return
	end
	local nItemId = tonumber(tbReq.ItemId);
	local nItemNum = tonumber(tbReq.ItemNum);
	if not nItemId or not nItemNum then
		tbRsp.Result = IDIP_INVALID_PARAM;
		tbRsp.RetMsg = ErrInvalidParam;
		self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_DO_DEL_ITEM_REQ", nCmdSequence)
		return
	end
	local bIsHaveItem = KItem.GetItemBaseProp(nItemId);
	if not bIsHaveItem then
		tbRsp.Result = IDIP_INVALID_ITEM_ID;
		tbRsp.RetMsg = ErrInValidItemId;
		self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_DO_DEL_ITEM_REQ", nCmdSequence)
		return
	end
 	local pPlayer = KPlayer.GetPlayerObjById(tbReq.RoleId);
	if pPlayer then
		local nCount = self:GetConsumeNum(pPlayer,nItemId,nItemNum);
		if nItemNum >= 0 then
			--pPlayer.AddItem(nItemId, nCount, nil, Env.LogWay_IdipDoDelItemReq);
			pPlayer.SendAward({{"item", nItemId, nCount}}, nil, true, Env.LogWay_IdipDoDelItemReq);
		elseif nItemNum < 0 then
			pPlayer.ConsumeItemInAllPos(nItemId,nCount, Env.LogWay_IdipDoDelItemReq);
		end
	else
		local pPlayerInfo = KPlayer.GetRoleStayInfo(tbReq.RoleId);
		if pPlayerInfo then
			local szCmd = string.format("local nCount = Transmit.tbIDIPInterface:GetConsumeNum(me,%d,%d);",nItemId,nItemNum);
			if nItemNum >= 0 then
				--szCmd = szCmd ..string.format("me.AddItem(%d, nCount, nil, Env.LogWay_IdipDoDelItemReq);",nItemId);
				szCmd = szCmd ..string.format("me.SendAward({{'item', %d, nCount}}, nil, true, Env.LogWay_IdipDoDelItemReq);", nItemId);
			elseif nItemNum < 0  then
				szCmd = szCmd ..string.format("me.ConsumeItemInAllPos(%d,nCount, Env.LogWay_IdipDoDelItemReq);",nItemId);
			end
			KPlayer.AddDelayCmd(tbReq.RoleId,
				szCmd,
				string.format("%s|%d|%d|%s|%s", 'IDIP_DO_DEL_ITEM_REQ', nItemId,nItemNum, tbReq.Source, tbReq.Serial))
		else
			tbRsp.Result = IDIP_PLAYER_NOT_EXIST
			tbRsp.RetMsg = ErrPlayerNotExist
		end
	end

	TLog("IDIPFLOW", tbReq.AreaId, tbReq.OpenId, tbReq.ItemId, tbReq.ItemNum, tbReq.Serial, tbReq.Source, nCmdId, tbReq.PlatId,
		tbReq.Partition, tbReq.RoleId, 0, "IDIP_DO_DEL_ITEM_REQ", (pPlayer and "immediately") or "delay")

	self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_DO_DEL_ITEM_REQ", nCmdSequence)
end

function tbIDIPInterface:IDIP_DO_DEL_FRIEND_REQ(nCmdId, tbReq, nCmdSequence)
	Player:DoAccountRoleMatchRequest(tbReq.OpenId,tbReq.RoleId,Transmit.tbIDIPInterface.OnDelFriendCheckFinish,Transmit.tbIDIPInterface,nCmdId,tbReq,nCmdSequence);
end

function tbIDIPInterface:OnDelFriendCheckFinish(szAccount, dwPlayerId, nIsMatch,nCmdId, tbReq, nCmdSequence)
	local tbRsp =
	{
		Result = IDIP_SUCCESS,
		RetMsg = "ok",
	}
	if nIsMatch == 0 then
		tbRsp.Result = IDIP_PLAYER_NOT_EXIST;
		tbRsp.RetMsg = ErrInValidAccountRoleIdNotMatch;
		self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_DO_DEL_FRIEND_REQ", nCmdSequence)
		return
	end
	local nPartnerId = tonumber(tbReq.FriendId);
	local nPartnerNum = tonumber(tbReq.FriendNum);
	if not nPartnerId or not nPartnerNum or nPartnerNum == 0 then
		tbRsp.Result = IDIP_INVALID_PARAM
		tbRsp.RetMsg = ErrInvalidParam
		self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_DO_DEL_FRIEND_REQ", nCmdSequence)
		return
	end


	local bIsExistPartner = Partner:CheckPartnerId(nPartnerId);
    if not bIsExistPartner then
        tbRsp.Result = IDIP_INVALID_PARTNER_ID;
        tbRsp.RetMsg = ErrInValidPartnerId;
        self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_DO_DEL_FRIEND_REQ", nCmdSequence)
        return
    end

	local pPlayer = KPlayer.GetPlayerObjById(tbReq.RoleId);
	if pPlayer then
		if nPartnerNum > 0 then
			pPlayer.AddPartner(nPartnerId,Env.LogWay_IdipDoDelFriendReq);
		elseif nPartnerNum < 0 then
			pPlayer.DeletePartner(nPartnerId);
		end
	else
		local pPlayerInfo = KPlayer.GetRoleStayInfo(tbReq.RoleId);
		if pPlayerInfo then
			local szCmd = "";
			if nPartnerNum > 0 then
				szCmd = string.format("me.AddPartner(%d,Env.LogWay_IdipDoDelFriendReq)",nPartnerId);
			elseif nPartnerNum < 0 then
				szCmd = string.format("me.DeletePartner(%d)",nPartnerId);
			end
			KPlayer.AddDelayCmd(tbReq.RoleId,
				szCmd,
				string.format("%s|%d|%d|%s|%s", 'IDIP_DO_DEL_FRIEND_REQ', nPartnerId,nPartnerNum, tbReq.Source, tbReq.Serial))
		else
			tbRsp.Result = IDIP_PLAYER_NOT_EXIST;
			tbRsp.RetMsg = ErrPlayerNotExist;
		end
	end

	TLog("IDIPFLOW", tbReq.AreaId, tbReq.OpenId, tbReq.FriendId, tbReq.FriendNum, tbReq.Serial, tbReq.Source, nCmdId, tbReq.PlatId,
		tbReq.Partition, tbReq.RoleId, 0, "IDIP_DO_DEL_FRIEND_REQ", (pPlayer and "immediately") or "delay")

	self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_DO_DEL_FRIEND_REQ", nCmdSequence)
end

function tbIDIPInterface:GetAwardList(nType, nItemId, nItemNum, nExpireTime)
	if nType then
		if nType == tbItemType.Gold then
			return {"Gold",nItemNum};
		elseif nType == tbItemType.Coin then
			return {"Coin",nItemNum};
		elseif nType == tbItemType.item then
			if nExpireTime then
				return {"item", nItemId, nItemNum, nExpireTime};
			end
			return {"item",nItemId,nItemNum};
		elseif nType == tbItemType.Partner then
			return {"Partner",nItemId,nItemNum};
		elseif nType == tbItemType.Contrib then
			return {"Contrib",nItemNum};
		elseif nType == tbItemType.Honor then
			return {"Honor",nItemNum};
		elseif nType == tbItemType.Exp then
			return {"Exp",nItemNum};
		elseif nType == tbItemType.BaseExp then
			return {"BasicExp",nItemNum};
		elseif nType == tbItemType.AddTimeTitle then
			local nTime = nItemNum == -1 and nItemNum or (GetTime() + nItemNum)
			return {"AddTimeTitle",nItemId,nTime};
		elseif nType == tbItemType.Energy then
			return {"Energy",nItemNum};
		elseif nType == tbItemType.SilverBoard then
			return {"SilverBoard",nItemNum};
		end
	end
end

function tbIDIPInterface:IDIP_DO_SEND_ATTACH_MAIL_REQ(nCmdId, tbReq, nCmdSequence)
	Player:DoAccountRoleMatchRequest(tbReq.OpenId,tbReq.RoleId,Transmit.tbIDIPInterface.OnSendAttachMailCheckFinish,Transmit.tbIDIPInterface,nCmdId,tbReq,nCmdSequence);
end

function tbIDIPInterface:OnSendAttachMailCheckFinish(szAccount, dwPlayerId, nIsMatch,nCmdId, tbReq, nCmdSequence)
	local tbRsp =
	{
		Result = IDIP_SUCCESS,
		RetMsg = "ok",
		ExtendParameter,
	}
	local szExtendParameter = tbReq.ExtendParameter or ""
	local nKinBonus = tonumber(tbReq.IsFamilyBonus) or 0
	local nGoldNum = 0

	tbRsp.ExtendParameter = szExtendParameter
	if nIsMatch == 0 then
		tbRsp.Result = IDIP_PLAYER_NOT_EXIST;
		tbRsp.RetMsg = ErrInValidAccountRoleIdNotMatch;
		self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_DO_SEND_ATTACH_MAIL_REQ", nCmdSequence)
		return
	end

	local pPlayerStay = KPlayer.GetRoleStayInfo(dwPlayerId);
	if not pPlayerStay then
	    tbRsp.Result = IDIP_PLAYER_NOT_EXIST;
	    tbRsp.RetMsg = ErrPlayerNotExist;
	    self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_DO_SEND_ATTACH_MAIL_REQ", nCmdSequence)
	    return
	end

	if not tonumber(tbReq.Type) or not tonumber(tbReq.ItemNum) then
		tbRsp.Result = IDIP_INVALID_PARAM
        tbRsp.RetMsg = ErrInvalidParam
        self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_DO_SEND_ATTACH_MAIL_REQ", nCmdSequence)
        return
	end
	local nReason = tonumber(tbReq.Reason)
	local nLogReazon = nReason and nReason or Env.LogWay_IdipDoSendAttachMailReq
	local szReason2 = tbReq.SubReason
	local szFrom = tbReq.Sender
	local tbMail = {};
	tbMail.To = tbReq.RoleId;
	tbMail.Title = tbReq.MailTitle;
	tbMail.Text = tbReq.MailContent;
	tbMail.From = (szFrom == "" and "系統" or szFrom) 
	tbMail.nLogReazon = nLogReazon;
	if szReason2 and szReason2 ~= "" then
		-- 目前道具的reason2只支持数值类型
		if tbReq.Type == tbItemType.item then
			local nReason2 = tonumber(szReason2)
			if not nReason2 then
				tbRsp.Result = IDIP_INVALID_REASON2
	            tbRsp.RetMsg = ErrInvalidReason2
	            self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_DO_SEND_ATTACH_MAIL_REQ", nCmdSequence)
				return
			end
			tbMail.tbParams = {}
			tbMail.tbParams.LogReason2 = nReason2
		else
			tbMail.tbParams = {}
			tbMail.tbParams.LogReason2 = szReason2
		end
	end

	local bIsHaveItem = nil
	if tbReq.Type == tbItemType.item then
		if not tonumber(tbReq.ItemId) then
			tbRsp.Result = IDIP_INVALID_ITEM_ID
            tbRsp.RetMsg = ErrInValidItemId
            self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_DO_SEND_ATTACH_MAIL_REQ", nCmdSequence)
            return
		end
		bIsHaveItem = KItem.GetItemBaseProp(tbReq.ItemId);
	    if not bIsHaveItem then
	        tbRsp.Result = IDIP_INVALID_ITEM_ID;
	        tbRsp.RetMsg = ErrInValidItemId;
	        self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_DO_SEND_ATTACH_MAIL_REQ", nCmdSequence)
	        return
	    end
	elseif tbReq.Type == tbItemType.Partner then
		bIsHaveItem = Partner:CheckPartnerId(tbReq.ItemId);
	    if not bIsHaveItem then
	        tbRsp.Result = IDIP_INVALID_PARTNER_ID;
	        tbRsp.RetMsg = ErrInValidPartnerId;
	        self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_DO_SEND_ATTACH_MAIL_REQ", nCmdSequence)
	        return
	    end
	elseif tbReq.Type == tbItemType.Gold then
		nGoldNum = tbReq.ItemNum
	elseif tbReq.Type == tbItemType.AddTimeTitle then
		-- 称号 item_id为title_id,item_num为有效期（秒）,数量写死1个
		local nTime = tonumber(tbReq.ItemNum)
		local nTitleID = tonumber(tbReq.ItemId)
		local nNowTime = GetTime()
		if nTime ~= -1 and nNowTime + nTime <= nNowTime then
			tbRsp.Result = IDIP_VALID_TITLE_TIME;
	        tbRsp.RetMsg = ErrValidTitleTime;
	        self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_DO_SEND_ATTACH_MAIL_REQ", nCmdSequence)
	        return
		end
		if not PlayerTitle:GetTitleTemplate(nTitleID) then
			tbRsp.Result = IDIP_NO_TITLE_INFO;
	        tbRsp.RetMsg = ErrNoTitleInfo;
	        self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_DO_SEND_ATTACH_MAIL_REQ", nCmdSequence)
	        return
		end
	end

	local tbAward = self:GetAwardList(tbReq.Type,tbReq.ItemId,tbReq.ItemNum);
	if not tbAward then
		tbRsp.Result = IDIP_INVALID_ITEM_TYPE
		tbRsp.RetMsg = ErrInValidItemType
		Log("IDIP_DO_SEND_ATTACH_MAIL_REQ ========= no match awardType" ,tbReq.Type,tbReq.ItemId,tbReq.ItemNum);
		self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_DO_SEND_ATTACH_MAIL_REQ", nCmdSequence)
		return
	end

	if szExtendParameter ~= "" and tbReq.Type == tbItemType.Gold then
		tbMail.tbParams = {LogReason2 = szExtendParameter};
	end

	tbMail.tbAttach = {tbAward};

	Mail:SendSystemMail(tbMail);

	local nKinId = pPlayerStay.dwKinId or 0

	if nKinBonus == 1 and tbReq.Type == tbItemType.Gold then
		local tbKinData = Kin:GetKinById(nKinId)
		if tbKinData then
			Kin:ProcessMemberCharge(dwPlayerId, nKinId, nGoldNum)
		else
			Log("IDIP_DO_SEND_ATTACH_MAIL_REQ have no kin 2 add kin bonus",dwPlayerId,nKinId,nGoldNum)
		end
	end

	local pPlayer = KPlayer.GetPlayerObjById(tbReq.RoleId);

	TLog("IDIPFLOW", tbReq.AreaId, tbReq.OpenId, tbReq.ItemId, tbReq.ItemNum, tbReq.Serial, tbReq.Source, nCmdId, tbReq.PlatId,
		tbReq.Partition, tbReq.RoleId,0, "IDIP_DO_SEND_ATTACH_MAIL_REQ", (pPlayer and "immediately") or "delay",tbReq.Type,nKinBonus,nKinId,nLogReazon,szReason2)

	self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_DO_SEND_ATTACH_MAIL_REQ", nCmdSequence)
end

function tbIDIPInterface:GetMuliAwardList(tbItem,nMaxCount)
	local tbAttach = {};
	for _,tbInfo in pairs(tbItem) do
		local tbAward = self:GetAwardList(tbInfo.Type,tbInfo.ItemId,tbInfo.ItemNum);
		table.insert(tbAttach,tbAward);
	end
	if Lib:CountTB(tbAttach) > nMaxCount then
		return nil
	end
	return tbAttach
end

function tbIDIPInterface:GetAwardListStr(tbAttach)
	local szAward = "";
	szAward = szAward .."{";
	for _,tbItem in ipairs(tbAttach) do
		szAward = szAward .."{'";
		for index,value in ipairs(tbItem) do
			szAward = szAward ..value;
			if index == 1 then
				szAward = szAward .."'";
			end
			szAward = szAward ..",";
		end
		szAward = szAward .."},";
	end
	szAward = szAward .."}";
	return szAward
end

function tbIDIPInterface:IDIP_DO_SEND_ITEM_REQ(nCmdId, tbReq, nCmdSequence)
	Player:DoAccountRoleMatchRequest(tbReq.OpenId,tbReq.RoleId,Transmit.tbIDIPInterface.OnSendItemCheckFinish,Transmit.tbIDIPInterface,nCmdId,tbReq,nCmdSequence);
end

function tbIDIPInterface:OnSendItemCheckFinish(szAccount, dwPlayerId, nIsMatch,nCmdId, tbReq, nCmdSequence)
	local tbRsp =
	{
		Result = IDIP_SUCCESS,
		RetMsg = "ok",
	}
	if nIsMatch == 0 then
		tbRsp.Result = IDIP_PLAYER_NOT_EXIST;
		tbRsp.RetMsg = ErrInValidAccountRoleIdNotMatch;
		self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_DO_SEND_ITEM_REQ", nCmdSequence)
		return
	end
	if not tbReq.ItemList or not next(tbReq.ItemList) then
		tbRsp.Result = IDIP_INVALID_PARAM
		tbRsp.RetMsg = ErrInvalidParam
		self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_DO_SEND_ITEM_REQ", nCmdSequence)
		return
	end
	local tbMail = {};
	tbMail.To = tbReq.RoleId;
	tbMail.Title = tbReq.MailTitle;
	tbMail.Text = tbReq.MailContent;
	tbMail.From = "系統";
	tbMail.nLogReazon = Env.LogWay_IdipDoSendItemReq;
	tbMail.tbAttach = {};

	for _,tbInfo in pairs(tbReq.ItemList) do
		local nTempType = tonumber(tbInfo.Type);
		local nItemId = tonumber(tbInfo.ItemId);
		local bIsHaveItem = nil
		local bIsInvalidType = true

		if not nTempType then
			tbRsp.Result = IDIP_INVALID_ITEM_TYPE
			tbRsp.RetMsg = ErrInValidItemType
			self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_DO_SEND_ITEM_REQ", nCmdSequence)
			return
		end
		if nTempType == tbItemType.Gold or nTempType == tbItemType.Coin or nTempType == tbItemType.item or nTempType == tbItemType.Partner then
			bIsInvalidType = false
		end
		if bIsInvalidType then
			tbRsp.Result = IDIP_INVALID_ITEM_TYPE
			tbRsp.RetMsg = ErrInValidItemType
			self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_DO_SEND_ITEM_REQ", nCmdSequence)
			return
		end
		if nTempType == tbItemType.item then		--item
			if not nItemId then
				tbRsp.Result = IDIP_INVALID_ITEM_ID
				tbRsp.RetMsg = ErrInValidItemId
				self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_DO_SEND_ITEM_REQ", nCmdSequence)
				return
			end
			bIsHaveItem = KItem.GetItemBaseProp(nItemId);
		    if not bIsHaveItem then
		        tbRsp.Result = IDIP_INVALID_ITEM_ID;
		        tbRsp.RetMsg = ErrInValidItemId;
		        self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_DO_SEND_ITEM_REQ", nCmdSequence)
		        return
		    end
		elseif nTempType == tbItemType.Partner then		--partner
			bIsHaveItem = Partner:CheckPartnerId(nItemId);
		    if not bIsHaveItem then
		        tbRsp.Result = IDIP_INVALID_PARTNER_ID;
		        tbRsp.RetMsg = ErrInValidPartnerId;
		        self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_DO_SEND_ITEM_REQ", nCmdSequence)
		        return
		    end
		end
	end

	tbMail.tbAttach = self:GetMuliAwardList(tbReq.ItemList,tbReq.ItemList_count);
	if not tbMail.tbAttach then
		tbRsp.Result = IDIP_INVALID_PARAM
		tbRsp.RetMsg = ErrInvalidParam
		self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_DO_SEND_ITEM_REQ", nCmdSequence)
		return
	end

	Mail:SendSystemMail(tbMail);

	local pPlayer = KPlayer.GetPlayerObjById(tbReq.RoleId);

	for _,tbInfo in pairs(tbReq.ItemList) do
		TLog("IDIPFLOW", tbReq.AreaId, tbReq.OpenId, tbInfo.ItemId, tbInfo.ItemNum, tbReq.Serial, tbReq.Source, nCmdId, tbReq.PlatId,
			tbReq.Partition, tbReq.RoleId,0, "IDIP_DO_SEND_ITEM_REQ", (pPlayer and "immediately") or "delay", tbInfo.Type)
	end

	self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_DO_SEND_ITEM_REQ", nCmdSequence)
end

function tbIDIPInterface:OnRmbChange(dwID,nRMB)
	local pPlayer = KPlayer.GetPlayerObjById(dwID);
	if not pPlayer then
		Log("[IDIP_DO_DEL_VIP_REQ] OnRmbChange can not find pPlayer",dwID,nRMB)
		return
	end

	pPlayer.SendAward({{"VipExp", nRMB} }, nil, nil, Env.LogWay_IdIpAddVipExp)

	Log("[IDIP_DO_DEL_VIP_REQ] OnRmbChange ",pPlayer.szName, dwID, nRMB)
end

function tbIDIPInterface:IDIP_DO_DEL_VIP_REQ(nCmdId, tbReq, nCmdSequence)
	Player:DoAccountRoleMatchRequest(tbReq.OpenId,tbReq.RoleId,Transmit.tbIDIPInterface.OnDelVipCheckFinish,Transmit.tbIDIPInterface,nCmdId,tbReq,nCmdSequence);
end

function tbIDIPInterface:OnDelVipCheckFinish(szAccount, dwPlayerId, nIsMatch,nCmdId, tbReq, nCmdSequence)
	local tbRsp =
	{
		Result = IDIP_SUCCESS,
		RetMsg = "ok",
	}
	if nIsMatch == 0 then
		tbRsp.Result = IDIP_PLAYER_NOT_EXIST;
		tbRsp.RetMsg = ErrInValidAccountRoleIdNotMatch;
		self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_DO_DEL_VIP_REQ", nCmdSequence)
		return
	end
	local nRMB = tonumber(tbReq.Value)
	if not nRMB then
		tbRsp.Result = IDIP_INVALID_PARAM;
		tbRsp.RetMsg = ErrInvalidParam;
		self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_DO_DEL_VIP_REQ", nCmdSequence)
		return
	end
	local pPlayer = KPlayer.GetPlayerObjById(tbReq.RoleId);
	if pPlayer then
		self:OnRmbChange(tbReq.RoleId,nRMB);
	else
		local pPlayerInfo = KPlayer.GetRoleStayInfo(tbReq.RoleId);
		if pPlayerInfo then
			KPlayer.AddDelayCmd(tbReq.RoleId,
				string.format("Transmit.tbIDIPInterface:OnRmbChange(%d, %d)",tbReq.RoleId,nRMB),
				string.format("%s|%d|%s|%s", 'IDIP_DO_DEL_VIP_REQ', nRMB,tbReq.Source, tbReq.Serial))
		else
			tbRsp.Result = IDIP_PLAYER_NOT_EXIST;
			tbRsp.RetMsg = ErrPlayerNotExist;
		end
	end

	TLog("IDIPFLOW", tbReq.AreaId, tbReq.OpenId, 0, tbReq.Value, tbReq.Serial, tbReq.Source, nCmdId, tbReq.PlatId,
		tbReq.Partition, tbReq.RoleId,  0, "IDIP_DO_DEL_VIP_REQ", (pPlayer and "immediately") or "delay")

	self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_DO_DEL_VIP_REQ", nCmdSequence)
end

function tbIDIPInterface:IDIP_QUERY_ROLELIST_REQ(nCmdId, tbReq,nCmdSequence)
	Player:DoAccountRoleListRequest(tbReq.OpenId, Transmit.tbIDIPInterface.OnAccountRoleListResult, Transmit.tbIDIPInterface, nCmdSequence,tbReq,nCmdId)
end

function tbIDIPInterface:OnAccountRoleListResult(szAccount,tbRoleList,nCmdSequence,tbReq,nCmdId)
	local tbRsp = {
	RoleList_count = 0,
	RoleList = {},
	};
	local tbPlayer = tbRoleList or {};
	if not next(tbPlayer) then
		self:IDIPDelayResponse(IDIP_PLAYER_NOT_EXIST,tbRsp,ErrInValidOpenId,"IDIP_QUERY_ROLELIST_REQ",nCmdSequence)
		return
	end
	for _,info in pairs(tbPlayer) do
		local tbInfo = {};
		tbInfo.RoleId = info.dwID;
		tbInfo.RoleName = info.szName;
		tbRsp.RoleList_count = tbRsp.RoleList_count + 1;
		table.insert(tbRsp.RoleList,tbInfo);
	end

	TLog("IDIPFLOW", tbReq.AreaId, tbReq.OpenId, 0,0,tbReq.Serial, tbReq.Source, nCmdId, tbReq.PlatId,
        tbReq.Partition,0,0, "IDIP_QUERY_ROLELIST_REQ")

	self:IDIPDelayResponse(IDIP_SUCCESS,tbRsp,"ok","IDIP_QUERY_ROLELIST_REQ",nCmdSequence)
end

function tbIDIPInterface:CheckRoleIsFit(nDwId,szRoleName)
	local pPlayer = KPlayer.GetPlayerObjById(nDwId);
	local szName = "";
	if pPlayer then
		szName = pPlayer.szName;
	else
		local pPlayerInfo = KPlayer.GetRoleStayInfo(nDwId);
		if pPlayerInfo then
			szName = pPlayerInfo.szName;
		end
	end
	return szRoleName == szName
end

function tbIDIPInterface:IDIP_QUERY_USR_INFO_REQ(nCmdId, tbReq,nCmdSequence)
	local tbRsp =
	{
		Result = IDIP_SUCCESS,
		RetMsg = "ok",
	}

	local nRoleId = type(tbReq.RoleId) == "number" and tbReq.RoleId or nil
	local szRoleName = tbReq.RoleName or ""
	if not nRoleId and szRoleName == "" then
		tbRsp.Result = IDIP_PLAYER_NOT_EXIST
		tbRsp.RetMsg = ErrInValidRoleIdRoleNameNotMatch
		Log("IDIP_QUERY_USR_INFO_REQ =======not RoleID and not RoleName")
		self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_QUERY_USR_INFO_REQ",nCmdSequence)
		return
	end

	if nRoleId and szRoleName ~= "" then
		if not self:CheckRoleIsFit(tbReq.RoleId,tbReq.RoleName) then
			tbRsp.Result = IDIP_PLAYER_NOT_EXIST
			tbRsp.RetMsg = ErrInValidRoleIdRoleNameNotMatch
			Log("IDIP_QUERY_USR_INFO_REQ ======= RoleID and RoleName not match",tbReq.RoleId,tbReq.RoleName)
			self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_QUERY_USR_INFO_REQ",nCmdSequence)
			return
		end
	end

	if not nRoleId then
		local tbStayInfo = KPlayer.GetRoleStayInfo(szRoleName);
		if not tbStayInfo then
			tbRsp.Result = IDIP_PLAYER_NOT_EXIST;
			tbRsp.RetMsg = ErrPlayerNotExist;
			self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_QUERY_USR_INFO_REQ",nCmdSequence)
			return
		end
		nRoleId = tbStayInfo.dwID;
	end

	Player:DoAccountRoleMatchRequest(tbReq.OpenId,nRoleId,Transmit.tbIDIPInterface.OnQueryUsrInfoCheckFinish,Transmit.tbIDIPInterface,nCmdId,tbReq,nCmdSequence);
end

function tbIDIPInterface:OnQueryUsrInfoCheckFinish(szAccount, dwPlayerId, nIsMatch,nCmdId, tbReq, nCmdSequence)

	local tbRsp =
	{
		Result = IDIP_SUCCESS,
		RetMsg = "ok",
		Diamond = 0,
		Money = 0,
		Vip = 0,
		VipExp = 0,
		Level = 0,
		FamilyId = 0,
		Ranking = -1,
		RegisterTime = 0,
		TotalLoginTime = 0,
		LastLogoutTime = 0,
		IsOnline = 0,
		Friend = 0,
		Contribute = 0,
		RoleCurTitle = "",		--称号
		RoleTitle = "",			--头衔

		School = 0,
		Fighting = 0,
		Honor = 0,
		TitleNum = 0,
		IsLogin = 0,

		CurIcoinId = 0,
		RoleName = "",

		Practice = 0, 			--洗练战力
		Strengthen = 0,         --强化战力
		Mosaic = 0,				--镶嵌战力

		Nimbus = 0,				-- 元气
		RechargeMoney = 0,		-- 黎饰
	}

	if nIsMatch == 0 then
        tbRsp.Result = IDIP_PLAYER_NOT_EXIST;
        tbRsp.RetMsg = ErrInValidAccountRoleIdNotMatch;
        self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_QUERY_USR_INFO_REQ", nCmdSequence)
        return
    end

    local pPlayer = KPlayer.GetPlayerObjById(dwPlayerId);
	if pPlayer then

		tbRsp.Diamond = pPlayer.GetMoney("Gold") - pPlayer.GetMoneyDebt("Gold");
		tbRsp.Money = pPlayer.GetMoney("Coin");
		tbRsp.Vip = pPlayer.GetVipLevel();
		tbRsp.VipExp = Recharge:GetTotoalRecharge(pPlayer);
		tbRsp.Level = pPlayer.nLevel;
		tbRsp.FamilyId = pPlayer.dwKinId;
		tbRsp.Ranking = -1;
		tbRsp.RegisterTime = pPlayer.dwCreateTime;
		tbRsp.TotalLoginTime = pPlayer.dwGameTime;
		tbRsp.LastLogoutTime = GetTime(); 					-- 玩家数据中暂时拿不到
		tbRsp.IsOnline = 1;
		tbRsp.Friend = pPlayer.GetMoney("Jade");
		tbRsp.Contribute = pPlayer.GetMoney("Contrib");
		tbRsp.RoleCurTitle = "";
		tbRsp.RoleTitle = "";

		tbRsp.School = pPlayer.nFaction
		tbRsp.Fighting = pPlayer.GetFightPower()
		tbRsp.Honor = pPlayer.GetMoney("Honor")

		local pRank = KRank.GetRankBoard("FightPower")
		if pRank then
		    local tbInfo = pRank.GetRankInfoByID(pPlayer.dwID)
		    if tbInfo then
		         tbRsp.Ranking = tbInfo.nPosition or -1
		    end
		end

		local tbHonorInfo = Player.tbHonorLevel:GetHonorLevelInfo(pPlayer.nHonorLevel)
		if not tbHonorInfo then
			tbRsp.RoleTitle = "";
		else
			tbRsp.RoleTitle = string.format("%d%s",pPlayer.nHonorLevel,tbHonorInfo.Name);
		end

		local tbTitleData = PlayerTitle:GetPlayerTitleData(pPlayer)
		local tbAllTitle = tbTitleData.tbAllTitle or {}
		local nActivateTitle = tbTitleData.nActivateTitle or 0;

		local tbTitleInfo = PlayerTitle:GetTitleTemplate(nActivateTitle);
		if not tbTitleInfo then
			tbRsp.RoleCurTitle = "";
		else
			tbRsp.RoleCurTitle = string.format("%d%s",nActivateTitle,tbTitleInfo.Name);
		end

		tbRsp.TitleNum = Lib:CountTB(tbAllTitle)

		tbRsp.IsLogin = 1

		tbRsp.CurIcoinId = pPlayer.nPortrait

		tbRsp.RoleName = pPlayer.szName

		local tbFightPowerData = pPlayer.GetScriptTable("FightPower");
		tbRsp.Practice = tbFightPowerData.nEquipFightPower or 0
		tbRsp.Strengthen = tbFightPowerData.nStrengthenFightPower or 0
		tbRsp.Mosaic = tbFightPowerData.nStoneFightPower or 0

		tbRsp.Nimbus = pPlayer.GetMoney("Energy");
		tbRsp.RechargeMoney = pPlayer.GetMoney("SilverBoard");

		TLog("IDIPFLOW", tbReq.AreaId, tbReq.OpenId, 0, 0, tbReq.Serial, tbReq.Source, nCmdId, tbReq.PlatId,
			tbReq.Partition, dwPlayerId,  0, "IDIP_QUERY_USR_INFO_REQ","immediately")

		self:IDIPDelayResponse(IDIP_SUCCESS,tbRsp,"ok","IDIP_QUERY_USR_INFO_REQ",nCmdSequence)
		return
	end

	Player:DoPlayerQueryInfoRequest(dwPlayerId, Transmit.tbIDIPInterface.OnQueryPlayerBaseInfo, Transmit.tbIDIPInterface,nCmdSequence,tbReq)
end

function tbIDIPInterface:OnQueryPlayerBaseInfo(tbQueryInfo,nCmdSequence,tbReq)

	local tbRsp = {
		Diamond = 0,
		Money = 0,
		Vip = 0,
		VipExp = 0,
		Level = 0,
		FamilyId = 0,
		Ranking = -1,
		RegisterTime = 0,
		TotalLoginTime = 0,
		LastLogoutTime = 0,
		IsOnline = 0,
		Friend = 0,
		Contribute = 0,
		RoleCurTitle = "",		--称号
		RoleTitle = "",			--头衔

		School = 0,
		Fighting = 0,
		Honor = 0,
		TitleNum = 0,
		IsLogin = 0,

		CurIcoinId = 0,
		RoleName = "",

		Practice = 0,
		Strengthen = 0,
		Mosaic = 0,

		Nimbus = 0,				-- 元气
		RechargeMoney = 0,		-- 黎饰
	};
	if not tbQueryInfo or not next(tbQueryInfo) then
        self:IDIPDelayResponse(IDIP_PLAYER_NOT_EXIST,tbRsp,ErrInValidOpenId,"IDIP_QUERY_USR_INFO_REQ",nCmdSequence)
        return
    end
	if tbQueryInfo and next(tbQueryInfo) then

		tbRsp.Diamond = tbQueryInfo.nGold;
		tbRsp.Money = tbQueryInfo.nCoin;
		tbRsp.Vip = tbQueryInfo.nVipLevel;
		tbRsp.VipExp = tbQueryInfo.nTotalCharge;
		tbRsp.Level = tbQueryInfo.nLevel;
		tbRsp.FamilyId = tbQueryInfo.dwKinId;
		tbRsp.Ranking = tbQueryInfo.nFightPowerRank;
		tbRsp.RegisterTime = tbQueryInfo.dwCreateTime;
		tbRsp.TotalLoginTime = tbQueryInfo.dwGameTime;
		tbRsp.LastLogoutTime = tbQueryInfo.dwLastLogoutTime;
		tbRsp.IsOnline = 0;
		tbRsp.Friend = tbQueryInfo.nJade;
		tbRsp.Contribute = tbQueryInfo.nContrib;
		tbRsp.RoleCurTitle = "";
		tbRsp.RoleTitle = "";

		local tbHonorInfo = Player.tbHonorLevel:GetHonorLevelInfo(tbQueryInfo.nHonorLevel)
		if not tbHonorInfo then
			tbRsp.RoleTitle = "";
		else
			tbRsp.RoleTitle = string.format("%d%s",tbQueryInfo.nHonorLevel,tbHonorInfo.Name);
		end

		local pPlayer = KPlayer.GetPlayerObjById(tbQueryInfo.dwID);
		if pPlayer then
			tbRsp.IsOnline = 1
		end

		local tbTitleInfo = PlayerTitle:GetTitleTemplate(tbQueryInfo.nActiveTitleId);
		if not tbTitleInfo then
			tbRsp.RoleCurTitle = "";
		else
			tbRsp.RoleCurTitle = string.format("%d%s",tbQueryInfo.nActiveTitleId,tbTitleInfo.Name);
		end

		local pPlayerInfo = KPlayer.GetRoleStayInfo(tbQueryInfo.dwID);

		tbRsp.School = pPlayerInfo.nFaction
		tbRsp.Fighting = tbQueryInfo.nFightPower
		tbRsp.Honor = tbQueryInfo.nHonor

		local tbAllTitle = tbQueryInfo.tbTitleList or {}
		tbRsp.TitleNum = Lib:CountTB(tbAllTitle)

		local nLastOnlineTime = pPlayerInfo.nLastOnlineTime or 0
		if Lib:GetLocalDay(nLastOnlineTime) == Lib:GetLocalDay() then
			tbRsp.IsLogin = 1
		end

		tbRsp.CurIcoinId = pPlayerInfo.nPortrait

		tbRsp.RoleName = pPlayerInfo.szName

		tbRsp.Practice = tbQueryInfo.nEquipFightPower or 0
		tbRsp.Strengthen = tbQueryInfo.nStrengthenFightPower or 0
		tbRsp.Mosaic = tbQueryInfo.nStoneFightPower or 0

		tbRsp.Nimbus = tbQueryInfo.nEnergy;
		tbRsp.RechargeMoney = tbQueryInfo.nSilverBoard;
	end

	TLog("IDIPFLOW", tbReq.AreaId, tbReq.OpenId, 0, 0, tbReq.Serial, tbReq.Source, nCmdId, tbReq.PlatId,
			tbReq.Partition, tbReq.RoleId,  0, "IDIP_QUERY_USR_INFO_REQ","delay")

	self:IDIPDelayResponse(IDIP_SUCCESS,tbRsp,"ok","IDIP_QUERY_USR_INFO_REQ",nCmdSequence)
end

function tbIDIPInterface:IDIP_QUERY_FRIEND_INFO_REQ(nCmdId, tbReq,nCmdSequence)
	Player:DoAccountRoleMatchRequest(tbReq.OpenId,tbReq.RoleId,Transmit.tbIDIPInterface.OnQueryFriendInfoCheckFinish,Transmit.tbIDIPInterface,nCmdId,tbReq,nCmdSequence);
end

function tbIDIPInterface:OnQueryFriendInfoCheckFinish(szAccount, dwPlayerId, nIsMatch,nCmdId, tbReq, nCmdSequence)
	local tbRsp = {
		FriendList_count = 0,
		FriendList = {},
		Totalpage = 0,
		Result = IDIP_SUCCESS,
		RetMsg = "ok",

	};
	if nIsMatch == 0 then
        tbRsp.Result = IDIP_PLAYER_NOT_EXIST;
        tbRsp.RetMsg = ErrInValidAccountRoleIdNotMatch;
        self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_QUERY_FRIEND_INFO_REQ", nCmdSequence)
        return
    end

    local nPage = tonumber(tbReq.Page) or 0

    local pPlayer = KPlayer.GetPlayerObjById(dwPlayerId)
    if pPlayer then
    	local tbAllPartner = pPlayer.GetAllPartner() or {}
    	local tbSortPartner = {}
    	for _,tbInfo in pairs(tbAllPartner) do
    		table.insert(tbSortPartner,tbInfo)
    	end
		if next(tbSortPartner) then
			local nNumPerPage = 50
			local nStartNum = nPage * nNumPerPage + 1
			local nEndNum = (nPage + 1) * nNumPerPage

			for nNum=nStartNum,nEndNum do
				if not tbSortPartner[nNum] then
					break;
				else
					local tbPartner = {}
					local tbInfo = tbSortPartner[nNum]

					local nQuality = tbInfo.nQualityLevel;

					tbPartner.FriendId = tbInfo.nTemplateId;
					tbPartner.FriendName = tbInfo.szName or "";
					tbPartner.Level = tbInfo.nLevel;
					if version_tx then
						tbPartner.Ratings = Partner.tbQualityLevelDes_Old[nQuality] or "";
					else
						tbPartner.Ratings = Partner.tbQualityLevelDes[nQuality] or "";
					end
					tbPartner.EvolutLevel = 0;
					tbPartner.Section = 0;

					table.insert(tbRsp.FriendList,tbPartner);
				end
			end

			tbRsp.FriendList_count = Lib:CountTB(tbRsp.FriendList);
			tbRsp.Totalpage = math.ceil(#tbSortPartner / nNumPerPage);
		end

		TLog("IDIPFLOW", tbReq.AreaId, tbReq.OpenId,0,0, tbReq.Serial, tbReq.Source,nCmdId, tbReq.PlatId,
        tbReq.Partition, tbReq.RoleId,0, "IDIP_QUERY_FRIEND_INFO_REQ", "immediately",tbReq.Page)

		self:IDIPDelayResponse(IDIP_SUCCESS,tbRsp,"ok","IDIP_QUERY_FRIEND_INFO_REQ",nCmdSequence)

    	return
    end

	Player:DoPlayerQueryInfoRequest(dwPlayerId, Transmit.tbIDIPInterface.OnQueryPlayerPartnerInfo, Transmit.tbIDIPInterface,nCmdSequence,nPage,tbReq,nCmdId)
end

function tbIDIPInterface:OnQueryPlayerPartnerInfo(tbQueryInfo,nCmdSequence,nPage,tbReq,nCmdId)
	local tbRsp = {
		FriendList_count = 0,
		FriendList = {},
		Totalpage = 0,
	};
	tbQueryInfo.tbPartnerList = tbQueryInfo.tbPartnerList or {}

	local nNumPerPage = 50
	local nStartNum = nPage * nNumPerPage + 1
	local nEndNum = (nPage + 1) * nNumPerPage

	if next(tbQueryInfo.tbPartnerList) then
		local tbAllPartnerInfo = Partner:GetAllPartnerBaseInfo();
		for nNum=nStartNum,nEndNum do
			if not tbQueryInfo.tbPartnerList[nNum] then
				break;
			else
				local tbPartner = {}
				local tbInfo = tbQueryInfo.tbPartnerList[nNum]
				local tbBaseInfo = tbAllPartnerInfo[tbInfo.nId] or {};
				local nQuality = tbBaseInfo.nQualityLevel;

				tbPartner.FriendId = tbInfo.nId;
				tbPartner.FriendName = tbBaseInfo.szName or "";
				tbPartner.Level = tbInfo.nLevel;
				if version_tx then
					tbPartner.Ratings = Partner.tbQualityLevelDes_Old[nQuality] or "";
				else
					tbPartner.Ratings = Partner.tbQualityLevelDes[nQuality] or "";
				end
				tbPartner.EvolutLevel = 0;
				tbPartner.Section = 0;

				table.insert(tbRsp.FriendList,tbPartner);
			end
		end

		tbRsp.FriendList_count = Lib:CountTB(tbRsp.FriendList);
		tbRsp.Totalpage = math.ceil(Lib:CountTB(tbQueryInfo.tbPartnerList) / nNumPerPage);
	end

	TLog("IDIPFLOW", tbReq.AreaId, tbReq.OpenId,0,0, tbReq.Serial, tbReq.Source,nCmdId, tbReq.PlatId,
        tbReq.Partition, tbReq.RoleId,0, "IDIP_QUERY_FRIEND_INFO_REQ", "delay",nPage)

	self:IDIPDelayResponse(IDIP_SUCCESS,tbRsp,"ok","IDIP_QUERY_FRIEND_INFO_REQ",nCmdSequence)
end

function tbIDIPInterface:IDIP_QUERY_FRIEND_INFO2_REQ(nCmdId, tbReq,nCmdSequence)
	local tbRsp = {
		Friend_count = 0,
		Friend = {},
		Totalpage = 0,
		Result = IDIP_SUCCESS,
		RetMsg = "ok",
	};
	local nRoleId = tonumber(tbReq.RoleId)
	if not nRoleId and tbReq.RoleName and tbReq.RoleName ~= "" then
		local tbStayInfo = KPlayer.GetRoleStayInfo(tbReq.RoleName);
		if not tbStayInfo then
			tbRsp.Result = IDIP_PLAYER_NOT_EXIST;
			tbRsp.RetMsg = ErrPlayerNotExist;
			self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_QUERY_FRIEND_INFO2_REQ",nCmdSequence)
			return
		end
		nRoleId = tbStayInfo and tbStayInfo.dwID
	end
	Player:DoAccountRoleMatchRequest(tbReq.OpenId,nRoleId,Transmit.tbIDIPInterface.OnQueryFriendInfo2CheckFinish,Transmit.tbIDIPInterface,nCmdId,tbReq,nCmdSequence);
end

function tbIDIPInterface:OnQueryFriendInfo2CheckFinish(szAccount, dwPlayerId, nIsMatch,nCmdId, tbReq, nCmdSequence)
	local tbRsp = {
		Friend_count = 0,
		Friend = {},
		Totalpage = 0,
		Result = IDIP_SUCCESS,
		RetMsg = "ok",
	};

	if nIsMatch == 0 then
        tbRsp.Result = IDIP_PLAYER_NOT_EXIST;
        tbRsp.RetMsg = ErrInValidAccountRoleIdNotMatch;
        self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_QUERY_FRIEND_INFO2_REQ", nCmdSequence)
        return
    end

    local nPage = tonumber(tbReq.Page) or 0

    local pPlayer = KPlayer.GetPlayerObjById(dwPlayerId)
    if pPlayer then
    	local tbAllPartner = pPlayer.GetAllPartner() or {}

    	local tbSortPartner = {}
    	for nPartnerId,tbInfo in pairs(tbAllPartner) do
    		tbInfo.nPartnerId = nPartnerId
    		table.insert(tbSortPartner,tbInfo)
    	end

    	local tbBattlePartnerTemp = pPlayer.GetPartnerPosInfo()
    	local tbBattlePartner = {}
    	for _,nPartnerId in pairs(tbBattlePartnerTemp) do
    		tbBattlePartner[nPartnerId] = true
    	end

		if next(tbSortPartner) then
			local nNumPerPage = 50
			local nStartNum = nPage * nNumPerPage + 1
			local nEndNum = (nPage + 1) * nNumPerPage

			for nNum=nStartNum,nEndNum do
				if not tbSortPartner[nNum] then
					break;
				else
					local tbPartner = {}
					local tbInfo = tbSortPartner[nNum]
					tbPartner.Template = tbInfo.nTemplateId;
					tbPartner.IsBattle = tbBattlePartner[tbInfo.nPartnerId] and 1 or 0; 			-- 是否上阵：（int，1为是，0为否）
					tbPartner.PhysicalFitness = tbInfo.nProtentialVitality or 0;					-- 体质资质
					tbPartner.AgileQualification = tbInfo.nProtentialDexterity or 0; 			-- 敏捷资质
					tbPartner.StrengthQualification = tbInfo.nProtentialStrength or 0; 			-- 力量资质
					tbPartner.SmartQualifications = tbInfo.nProtentialEnergy or 0;				-- 灵巧资质

					tbPartner.MaxPhysicalFitness = tbInfo.nLimitProtentialVitality or 0; 		-- 体质资质上限
					tbPartner.MaxAgileQualification = tbInfo.nLimitProtentialDexterity or 0; 	-- 敏捷资质上限
					tbPartner.MaxStrengthQualification = tbInfo.nLimitProtentialStrength or 0; 	-- 力量资质上限
					tbPartner.MaxSmartQualifications = tbInfo.nLimitProtentialEnergy or 0; 		-- 灵巧资质上限

					tbPartner.IsWizards = (tbInfo.nIsNormal and tbInfo.nIsNormal == 1) and 0 or 1; 						-- 是否奇才：（int，1为是，0为否）
					tbPartner.IsNatalweapons = tbInfo.nWeaponState or 0; 						-- 是否装备本命武器：（int，1为是，0为否）
					tbPartner.Level = tbInfo.nLevel  or 0;										-- 同伴等级
					tbPartner.Exp = tbInfo.nExp or 0;											-- 当前等级的经验

					local tbAllSkill = Partner:GetPartnerAllSkillInfo(pPlayer, tbInfo.nPartnerId)
					local tbNormalSkill = tbAllSkill and tbAllSkill.tbNormalSkill
					for i=1,5 do
						local nSkillId = 0
						local nSkillLevel = 0
						if tbNormalSkill and tbNormalSkill[i] and tbNormalSkill[i].nSkillId and tbNormalSkill[i].nSkillLevel and tbNormalSkill[i].nSkillId > 0 then
							nSkillId =  tbNormalSkill[i].nSkillId
							nSkillLevel = tbNormalSkill[i].nSkillLevel
						end
						tbPartner[string.format("Skill%dId",i)] = nSkillId
						tbPartner[string.format("Skill%dLevel",i)] = nSkillLevel
					end
					table.insert(tbRsp.Friend,tbPartner);
				end
			end

			tbRsp.Friend_count = Lib:CountTB(tbRsp.Friend);
			tbRsp.Totalpage = math.ceil(#tbSortPartner / nNumPerPage);
		end

		TLog("IDIPFLOW", tbReq.AreaId, tbReq.OpenId,0,0, tbReq.Serial, tbReq.Source,nCmdId, tbReq.PlatId,
        tbReq.Partition, tbReq.RoleId,0, "IDIP_QUERY_FRIEND_INFO2_REQ", "immediately",tbReq.Page)
		self:IDIPDelayResponse(IDIP_SUCCESS,tbRsp,"ok","IDIP_QUERY_FRIEND_INFO2_REQ",nCmdSequence)
    	return
    end
    Player:DoPlayerQueryInfoRequest(dwPlayerId, Transmit.tbIDIPInterface.OnQueryPlayerPartnerInfo2, Transmit.tbIDIPInterface,nCmdSequence,nPage,tbReq,nCmdId)
end

function tbIDIPInterface:OnQueryPlayerPartnerInfo2(tbQueryInfo,nCmdSequence,nPage,tbReq,nCmdId)
	local tbRsp = {
		Friend_count = 0,
		Friend = {},
		Totalpage = 0,
		Result = IDIP_SUCCESS,
		RetMsg = "ok",
	};
	tbQueryInfo.tbPartnerList = tbQueryInfo.tbPartnerList or {}

	local nNumPerPage = 50
	local nStartNum = nPage * nNumPerPage + 1
	local nEndNum = (nPage + 1) * nNumPerPage

	if next(tbQueryInfo.tbPartnerList) then
		local tbAllPartnerInfo = Partner:GetAllPartnerBaseInfo();
		for nNum=nStartNum,nEndNum do
			if not tbQueryInfo.tbPartnerList[nNum] then
				break;
			else
				local tbPartner = {}
				local tbInfo = tbQueryInfo.tbPartnerList[nNum]
				local tbBaseInfo = tbAllPartnerInfo[tbInfo.nId] or {};

				tbPartner.Template = tbInfo.nId;
				tbPartner.IsBattle = tbInfo.nEquiped or 0; 												-- 是否上阵：（int，1为是，0为否）

				tbPartner.PhysicalFitness = tbInfo.Vitality and tbInfo.Vitality[1] or 0;			-- 体质资质
				tbPartner.AgileQualification = tbInfo.Dexterity and tbInfo.Dexterity[1] or 0;	    -- 敏捷资质
				tbPartner.StrengthQualification = tbInfo.Strength and tbInfo.Strength[1] or 0; 		-- 力量资质
				tbPartner.SmartQualifications = tbInfo.Energy and tbInfo.Energy[1] or 0;			-- 灵巧资质

				tbPartner.MaxPhysicalFitness = tbInfo.Vitality and tbInfo.Vitality[2] or 0; 		-- 体质资质上限
				tbPartner.MaxAgileQualification = tbInfo.Dexterity and tbInfo.Dexterity[2] or 0; 	-- 敏捷资质上限
				tbPartner.MaxStrengthQualification = tbInfo.Strength and tbInfo.Strength[2] or 0; 	-- 力量资质上限
				tbPartner.MaxSmartQualifications = tbInfo.Energy and tbInfo.Energy[2] or 0;			-- 灵巧资质上限

				tbPartner.IsWizards = tbInfo.nBYState or 0; 												-- 是否奇才：（int，1为是，0为否）
				tbPartner.IsNatalweapons = tbInfo.nWeaponState or 0; 									-- 是否装备本命武器：（int，1为是，0为否）
				tbPartner.Level = tbInfo.nLevel or 0;													-- 同伴等级
				tbPartner.Exp = tbInfo.nExp or 0;														-- 当前等级的经验

				local tbNormalSkill = tbInfo.tbSkill
				for i=1,5 do
					local nSkillId = 0
					local nSkillLevel = 0
					if tbNormalSkill and tbNormalSkill[i] then
						nSkillId = tbNormalSkill[i].nId
						nSkillLevel = tbNormalSkill[i].nLevel
					end
					tbPartner[string.format("Skill%dId",i)] = nSkillId
					tbPartner[string.format("Skill%dLevel",i)] = nSkillLevel
				end

				table.insert(tbRsp.Friend,tbPartner);
			end
		end

		tbRsp.Friend_count = Lib:CountTB(tbRsp.Friend);
		tbRsp.Totalpage = math.ceil(Lib:CountTB(tbQueryInfo.tbPartnerList) / nNumPerPage);
	end

	TLog("IDIPFLOW", tbReq.AreaId, tbReq.OpenId,0,0, tbReq.Serial, tbReq.Source,nCmdId, tbReq.PlatId,
        tbReq.Partition, tbReq.RoleId,0, "IDIP_QUERY_FRIEND_INFO2_REQ", "delay",nPage)

	self:IDIPDelayResponse(IDIP_SUCCESS,tbRsp,"ok","IDIP_QUERY_FRIEND_INFO2_REQ",nCmdSequence)
end

function tbIDIPInterface:IDIP_QUERY_FAMILY_INFO_REQ(nCmdId, tbReq, nCmdSequence)
	Player:DoAccountRoleMatchRequest(tbReq.OpenId,tbReq.RoleId,Transmit.tbIDIPInterface.OnQueryFamilyInfoCheckFinish,Transmit.tbIDIPInterface,nCmdId,tbReq,nCmdSequence);
end

function tbIDIPInterface:OnQueryFamilyInfoCheckFinish(szAccount, dwPlayerId, nIsMatch,nCmdId, tbReq, nCmdSequence)

	local tbRsp =
	{
		FamilyId = 0,
		FamilyName = "",
		FamilyLevel = 0,
		LeaderId = 0,
		MasterId = 0,
		FamilyNotice = "",
		FamilyDeclare = "",
		CreateTime = "",
		Leader = "",
		Master = "",
		FamilyPrestige = "",
		Fund = "",
		MemberNum = "",
		PreMemberNum = "",

		FamilyRank = 0,

		Result = IDIP_SUCCESS,
		RetMsg = "ok",
	}

	if nIsMatch == 0 then
		tbRsp.Result = IDIP_PLAYER_NOT_EXIST;
		tbRsp.RetMsg = ErrInValidAccountRoleIdNotMatch;
		self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_QUERY_FAMILY_INFO_REQ", nCmdSequence)
		return
	end

	local nDwKinId = 0;
	dwPlayerId = tonumber(dwPlayerId);
	local pPlayer = KPlayer.GetPlayerObjById(dwPlayerId) or KPlayer.GetRoleStayInfo(dwPlayerId);
	if not pPlayer then
		tbRsp.Result = IDIP_PLAYER_NOT_EXIST;
		tbRsp.RetMsg = ErrPlayerNotExist;
		self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_QUERY_FAMILY_INFO_REQ",nCmdSequence)
		return;
	end

	local tbMemberData = Kin:GetMemberData(dwPlayerId)
	nDwKinId = tbMemberData and tbMemberData.nKinId or 0

	local tbKinData = Kin:GetKinById(nDwKinId)
	if tbKinData then
		tbRsp.FamilyId = tbKinData.nKinId;
		tbRsp.FamilyName = tbKinData.szName;
		tbRsp.FamilyLevel = tbKinData:GetLevel();
		tbRsp.LeaderId = tbKinData.nLeaderId;
		tbRsp.MasterId = tbKinData.nMasterId;
		tbRsp.FamilyNotice = tbKinData.szPublicDeclare or "";
		tbRsp.FamilyDeclare = tbKinData.tbRecruitSetting.szAddDeclare;
		tbRsp.CreateTime = tostring(tbKinData.nCreateTime);

		local pLeaderPlayer = KPlayer.GetPlayerObjById(tbKinData.nLeaderId) or KPlayer.GetRoleStayInfo(tbKinData.nLeaderId);
		tbRsp.Leader = pLeaderPlayer and pLeaderPlayer.szName or ""

		local pMasterPlayer = KPlayer.GetPlayerObjById(tbKinData.nMasterId) or KPlayer.GetRoleStayInfo(tbKinData.nMasterId);
		tbRsp.Master = pMasterPlayer and pMasterPlayer.szName or ""

		tbRsp.FamilyPrestige = tbKinData.nPrestige or 0
		tbRsp.Fund = tbKinData.nFound or 0

		tbRsp.MemberNum = tbKinData:GetMemberCount()
		tbRsp.PreMemberNum = tbKinData:GetCareerMemberCount(Kin.Def.Career_New)

		local pRank = KRank.GetRankBoard("kin")
		if pRank then
			 local tbInfo = pRank.GetRankInfoByID(nDwKinId)
			 tbRsp.FamilyRank = tbInfo and tbInfo.nPosition or 0
		end
	end

	TLog("IDIPFLOW", tbReq.AreaId, tbReq.OpenId,0,0, tbReq.Serial, tbReq.Source, nCmdId, tbReq.PlatId,
        tbReq.Partition, tbReq.RoleId,0, "IDIP_QUERY_FAMILY_INFO_REQ")

	self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_QUERY_FAMILY_INFO_REQ",nCmdSequence)
end

function tbIDIPInterface:IDIP_QUERY_FAMILY_MEMBER_INFO_REQ(nCmdId, tbReq, nCmdSequence)

	local tbRsp =
	{
		MemberList_count = 0,
		MemberList = {},
		Result = IDIP_SUCCESS,
		RetMsg = "ok",
	}

	local nDwKinId = tonumber(tbReq.FamilyId) or 0;
	local tbKinData = Kin:GetKinById(nDwKinId);
	if tbKinData then
		local tbMembers = tbKinData.tbMembers
		for nDwId,_ in pairs(tbMembers) do
			local tbTemp = {};
			tbTemp.RoleId = nDwId;
			local pPlayer = KPlayer.GetPlayerObjById(tbTemp.RoleId) or KPlayer.GetRoleStayInfo(tbTemp.RoleId);
			if pPlayer then
				tbTemp.RoleName = pPlayer.szName;
				table.insert(tbRsp.MemberList,tbTemp);
				tbRsp.MemberList_count = tbRsp.MemberList_count + 1;
			end
		end
	else
		tbRsp.Result = IDIP_KIN_NOT_FOUND;
		tbRsp.RetMsg = ErrKinNotFound;
	end

	TLog("IDIPFLOW", tbReq.AreaId, tbReq.OpenId,0,0, tbReq.Serial, tbReq.Source, nCmdId, tbReq.PlatId,
        tbReq.Partition,0,0, "IDIP_QUERY_FAMILY_MEMBER_INFO_REQ",tbReq.FamilyId)

	self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_QUERY_FAMILY_MEMBER_INFO_REQ", nCmdSequence)
end

function tbIDIPInterface:IDIP_DO_HOT_UPDATE_SERVER_REQ(nCmdId, tbReq, nCmdSequence)
	local tbRsp =
	{
		Result = 0,
		RetMsg = "ok",
	}

	Log("=====Excute GM Code=====")
	Lib:LogTB(tbReq);

	local fnOp, szRet, bOpSucces;
	fnOp, szRet = loadstring(tbReq.HotterScript or "");
	if fnOp then
		bOpSucces, szRet = Lib:CallBack({fnOp});
	end

	if not bOpSucces then
		tbRsp.Result = IDIP_INVALID_PARAM;
		tbRsp.RetMsg = ErrInvalidParam;
	end

	Log("Result:", tbRsp.RetMsg);

	TLog("IDIPFLOW", tbReq.AreaId, "", 0, 0, tbReq.Serial, tbReq.Source, nCmdId, tbReq.PlatId,
		tbReq.Partition, 0,  0, "IDIP_DO_HOT_UPDATE_SERVER_REQ", tbReq.c)

	return tbRsp.Result, tbRsp, tbRsp.RetMsg
end

function tbIDIPInterface:IDIP_DO_UPDAT_HONHR_CONTRIBUTE_REQ(nCmdId, tbReq, nCmdSequence)
	Player:DoAccountRoleMatchRequest(tbReq.OpenId,tbReq.RoleId,Transmit.tbIDIPInterface.OnUpdatHonhrContributeCheckFinish,Transmit.tbIDIPInterface,nCmdId,tbReq,nCmdSequence);
end

function tbIDIPInterface:OnUpdatHonhrContributeCheckFinish(szAccount, dwPlayerId, nIsMatch,nCmdId, tbReq, nCmdSequence)
	local tbRsp =
	{
		Result = IDIP_SUCCESS,
		RetMsg = "ok",
		BeginValue = 0,
		EndValue = 0,
	}

	if nIsMatch == 0 then
		tbRsp.Result = IDIP_PLAYER_NOT_EXIST;
		tbRsp.RetMsg = ErrInValidAccountRoleIdNotMatch;
		self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_DO_UPDAT_HONHR_CONTRIBUTE_REQ", nCmdSequence)
		return
	end

	local szType = tbMoneyType[tonumber(tbReq.Type)]
	if not szType then
		tbRsp.Result = IDIP_INVALID_PARAM;
		tbRsp.RetMsg = ErrInvalidParam;
		self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_DO_UPDAT_HONHR_CONTRIBUTE_REQ", nCmdSequence)
		return
	end

	local nValue = tonumber(tbReq.Value)
	if not nValue then
		tbRsp.Result = IDIP_INVALID_PARAM;
		tbRsp.RetMsg = ErrInvalidParam;
		self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_DO_UPDAT_HONHR_CONTRIBUTE_REQ", nCmdSequence)
		return
	end

	local pPlayer = KPlayer.GetPlayerObjById(dwPlayerId);
	if pPlayer then
		tbRsp.BeginValue = pPlayer.GetMoney(szType)
		if nValue >= 0 then
			pPlayer.AddMoney(szType,nValue,Env.LogWay_IdipDoUpdatHonhrContributeReq);
			tbRsp.EndValue = tbRsp.BeginValue + nValue
		elseif nValue < 0 then
			local nCost = self:GetCost(pPlayer,szType,nValue);
			pPlayer.CostMoney(szType,nCost,Env.LogWay_IdipDoUpdatHonhrContributeReq);
			tbRsp.EndValue = tbRsp.BeginValue - nCost
		end

	else
		local pPlayerInfo = KPlayer.GetRoleStayInfo(tbReq.RoleId);
		if pPlayerInfo then
			local szCmd = "";
			if nValue >= 0 then
				szCmd = string.format("me.AddMoney('%s', %d, %d)",szType,nValue,Env.LogWay_IdipDoUpdatHonhrContributeReq);
			elseif nValue < 0 then
				szCmd = string.format("local szType = '%s';local nCost = Transmit.tbIDIPInterface:GetCost(me,szType,%d);me.CostMoney(szType,nCost,%d)",szType,nValue,Env.LogWay_IdipDoUpdatHonhrContributeReq);
			end
			KPlayer.AddDelayCmd(tbReq.RoleId,
				szCmd,
				string.format("%s|%d|%d|%s|%s", 'IDIP_DO_UPDAT_HONHR_CONTRIBUTE_REQ' ,tbReq.Type, nValue, tbReq.Source, tbReq.Serial))
		else
			tbRsp.Result = IDIP_PLAYER_NOT_EXIST
			tbRsp.RetMsg = ErrPlayerNotExist
		end
	end

	TLog("IDIPFLOW", tbReq.AreaId, tbReq.OpenId, 0, tbReq.Value, tbReq.Serial, tbReq.Source, nCmdId, tbReq.PlatId,
		tbReq.Partition, tbReq.RoleId, 0, "IDIP_DO_UPDAT_HONHR_CONTRIBUTE_REQ", (pPlayer and "immediately") or "delay",tbReq.Type)

	self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_DO_UPDAT_HONHR_CONTRIBUTE_REQ", nCmdSequence)
end

function tbIDIPInterface:IDIP_DO_MAIL_SEND_HONHR_CONTRIBUTE_REQ(nCmdId, tbReq, nCmdSequence)
	Player:DoAccountRoleMatchRequest(tbReq.OpenId,tbReq.RoleId,Transmit.tbIDIPInterface.OnMailSendHonhrContributeCheckFinish,Transmit.tbIDIPInterface,nCmdId,tbReq,nCmdSequence);
end

function tbIDIPInterface:OnMailSendHonhrContributeCheckFinish(szAccount, dwPlayerId, nIsMatch,nCmdId, tbReq, nCmdSequence)
	local tbRsp =
	{
		Result = IDIP_SUCCESS,
		RetMsg = "ok",
	}

	if nIsMatch == 0 then
		tbRsp.Result = IDIP_PLAYER_NOT_EXIST;
		tbRsp.RetMsg = ErrInValidAccountRoleIdNotMatch;
		self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_DO_MAIL_SEND_HONHR_CONTRIBUTE_REQ", nCmdSequence)
		return
	end

	local nType = tonumber(tbReq.Type)
	local nNum = tonumber(tbReq.SendNum)
	local szType = tbMailSendType[nType]
	if not szType or not nNum then
		tbRsp.Result = IDIP_INVALID_PARAM;
		tbRsp.RetMsg = ErrInvalidParam;
		self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_DO_MAIL_SEND_HONHR_CONTRIBUTE_REQ", nCmdSequence)
		return
	end

	local tbMail = {};
	tbMail.To = dwPlayerId;
	tbMail.Title = tbReq.MailTitle or "";
	tbMail.Text = tbReq.MailContent or "";
	tbMail.From = "系統";
	tbMail.nLogReazon = Env.LogWay_IdipDoMailSendHonhrContributeReq;
	tbMail.tbAttach = {{szType,nNum}};

	Mail:SendSystemMail(tbMail);

	local pPlayer = KPlayer.GetPlayerObjById(tbReq.RoleId);

	TLog("IDIPFLOW", tbReq.AreaId, tbReq.OpenId, 0,tbReq.SendNum, tbReq.Serial, tbReq.Source, nCmdId, tbReq.PlatId,
		tbReq.Partition, tbReq.RoleId,0, "IDIP_DO_MAIL_SEND_HONHR_CONTRIBUTE_REQ", (pPlayer and "immediately") or "delay",tbReq.Type)

	self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_DO_MAIL_SEND_HONHR_CONTRIBUTE_REQ", nCmdSequence)
end

function tbIDIPInterface:IDIP_DO_GAME_SEND_SCROLL_NOTICE_REQ(nCmdId, tbReq, nCmdSequence)

	local tbRsp =
	{
		Result = IDIP_SUCCESS,
		RetMsg = "ok",
		NoticeId = 0,
	}

	local nNoticeType = tonumber(tbReq.NoticeType)
	local szNoticeContent = tbReq.NoticeContent or ""

	if not nNoticeType then
		tbRsp.Result = IDIP_INVALID_PARAM;
		tbRsp.RetMsg = ErrInvalidParam;
		self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_DO_GAME_SEND_SCROLL_NOTICE_REQ", nCmdSequence)
		return
	end

	if nNoticeType == tbLoopMsgType.ZouMaDeng then
		KPlayer.SendWorldNotify(1, 1000,szNoticeContent,1, 1);                    -- 走马灯&系统提示
	else
		tbRsp.Result = IDIP_INVALID_PARAM;
		tbRsp.RetMsg = ErrInvalidParam;
		self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_DO_GAME_SEND_SCROLL_NOTICE_REQ", nCmdSequence)
		return
	end

	TLog("IDIPFLOW", tbReq.AreaId, tbReq.OpenId,0,0, tbReq.Serial, tbReq.Source, nCmdId, tbReq.PlatId,
		tbReq.Partition,0,0, "IDIP_DO_GAME_SEND_SCROLL_NOTICE_REQ", nNoticeType,szNoticeContent)

	self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_DO_GAME_SEND_SCROLL_NOTICE_REQ", nCmdSequence)
end

-- 废弃
function tbIDIPInterface:IDIP_DO_ADVANCE_STOP_SCROLL_NOTICE_REQ(nCmdId, tbReq, nCmdSequence)

	local tbRsp =
	{
		Result = IDIP_SUCCESS,
		RetMsg = "ok",
	}

	local nTimerID = tonumber(tbReq.NoticeId)
	if not nTimerID then
		tbRsp.Result = IDIP_INVALID_PARAM;
		tbRsp.RetMsg = ErrInvalidParam;
		self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_DO_ADVANCE_STOP_SCROLL_NOTICE_REQ", nCmdSequence)
		return
	end

	local bRet = self:CloseMsgTimer(nTimerID)
	if not bRet then
		tbRsp.Result = IDIP_INVALID_PARAM;
		tbRsp.RetMsg = ErrInvalidParam;
		self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_DO_ADVANCE_STOP_SCROLL_NOTICE_REQ", nCmdSequence)
		return
	end

	self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_DO_ADVANCE_STOP_SCROLL_NOTICE_REQ", nCmdSequence)

	Log("IDIP_DO_ADVANCE_STOP_SCROLL_NOTICE_REQ ========== ",nTimerID,GetTime())
end

function tbIDIPInterface:CloseMsgTimer(nTimerID)
	local bRet
	if not nTimerID then
		return
	end
	for index,tbInfo in pairs(self.tbMsgTimer.tbAllTimer) do
		if tbInfo.NoticeId == nTimerID then
			Timer:Close(nTimerID);
			self.tbMsgTimer.nTimerCount = self.tbMsgTimer.nTimerCount - 1
			table.remove(self.tbMsgTimer.tbAllTimer,index)
			bRet = true
			break;
		end
	end

	return bRet
end

-- 废弃
function tbIDIPInterface:IDIP_QUERY_ONLINE_SCROLL_NOTICE_REQ(nCmdId, tbReq, nCmdSequence)

	local tbRsp =
	{
		Result = IDIP_SUCCESS,
		RetMsg = "ok",
		ScrollNoticeList_count = 0,
		ScrollNoticeList = {},
	}

	local nPage = tbReq.Page
	local nNumPerPage = 50
	local nStartNum = nPage * nNumPerPage + 1
	local nEndNum = (nPage + 1) * nNumPerPage
	if next(self.tbMsgTimer.tbAllTimer) then
		for nNum=nStartNum,nEndNum do
			if not self.tbMsgTimer.tbAllTimer[nNum] then
				break;
			else
				local tbTimer = {}
				local tbInfo = self.tbMsgTimer.tbAllTimer[nNum]

				tbTimer.NoticeId = tbInfo.NoticeId;
				tbTimer.NoticeContent = tbInfo.NoticeContent;
				tbTimer.NoticeType = tbInfo.NoticeType;
				tbTimer.StopPlayingTime = tbInfo.StopPlayingTime;

				table.insert(tbRsp.ScrollNoticeList,tbTimer);
			end
		end
		tbRsp.ScrollNoticeList_count = self.tbMsgTimer.nTimerCount;
		tbRsp.Totalpage = math.ceil(tbRsp.ScrollNoticeList_count / nNumPerPage);
	end

	self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_QUERY_ONLINE_SCROLL_NOTICE_REQ",nCmdSequence)
end

function tbIDIPInterface:IDIP_DO_SEND_GOLD_MAIL_ATTACH_VIP_EXP_REQ(nCmdId, tbReq, nCmdSequence)
	Player:DoAccountRoleMatchRequest(tbReq.OpenId,tbReq.RoleId,Transmit.tbIDIPInterface.OnSendGoldMailAttachVipExpCheckFinish,Transmit.tbIDIPInterface,nCmdId,tbReq,nCmdSequence);
end

function tbIDIPInterface:OnSendGoldMailAttachVipExpCheckFinish(szAccount, dwPlayerId, nIsMatch,nCmdId, tbReq, nCmdSequence)
	local tbRsp =
	{
		Result = IDIP_SUCCESS,
		RetMsg = "ok",
	}

	if nIsMatch == 0 then
        tbRsp.Result = IDIP_PLAYER_NOT_EXIST;
        tbRsp.RetMsg = ErrInValidAccountRoleIdNotMatch;
        self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_DO_SEND_GOLD_MAIL_ATTACH_VIP_EXP_REQ", nCmdSequence)
        return
    end

    local nKinBonus = tonumber(tbReq.IsFamilyBonus) or 0

    local nSendNum = tonumber(tbReq.SendNum)

    if not nSendNum then
		tbRsp.Result = IDIP_INVALID_PARAM;
		tbRsp.RetMsg = ErrInvalidParam;
		self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_DO_SEND_GOLD_MAIL_ATTACH_VIP_EXP_REQ", nCmdSequence)
		return
   	end

   	local pPlayerStay = KPlayer.GetRoleStayInfo(tbReq.RoleId);
	if not pPlayerStay then
		tbRsp.Result = IDIP_PLAYER_NOT_EXIST;
		tbRsp.RetMsg = ErrPlayerNotExist;
		self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_DO_SEND_GOLD_MAIL_ATTACH_VIP_EXP_REQ", nCmdSequence)
		return
	end

   	local tbMail = {};
	tbMail.To = dwPlayerId;
	tbMail.Title = "儲值失敗返還";
	tbMail.Text =  "";
	tbMail.From = "系統";
	tbMail.nLogReazon = Env.LogWay_DoSendGoldMailAttachVipExp;
	tbMail.tbAttach = {{"Gold",nSendNum},{"VipExp",nSendNum * 10}};

	Mail:SendSystemMail(tbMail);

	local nKinId = pPlayerStay.dwKinId or 0

	if nKinBonus == 1 then
		local tbKinData = Kin:GetKinById(nKinId)
		if tbKinData then
			Kin:ProcessMemberCharge(dwPlayerId, nKinId, nSendNum)
		else
			Log("IDIP_DO_SEND_GOLD_MAIL_ATTACH_VIP_EXP_REQ have no kin 2 add kin bonus",dwPlayerId,nKinId,nSendNum)
		end
	end

	local pPlayer = KPlayer.GetPlayerObjById(dwPlayerId);

	TLog("IDIPFLOW", tbReq.AreaId, tbReq.OpenId,0, tbReq.SendNum, tbReq.Serial, tbReq.Source, nCmdId, tbReq.PlatId,
		tbReq.Partition, tbReq.RoleId,0, "IDIP_DO_SEND_GOLD_MAIL_ATTACH_VIP_EXP_REQ",(pPlayer and "immediately") or "delay",nKinBonus,nKinId)

	self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_DO_SEND_GOLD_MAIL_ATTACH_VIP_EXP_REQ", nCmdSequence)
end

function tbIDIPInterface:CheckPartnerParamValid(tbReq)

    if not tonumber(tbReq.FriendLevel) or tbReq.FriendLevel > Partner.MAX_LEVEL then
    	return false
	end

	for i=1,5 do
		local nSkillId = tbReq[string.format("Skill%dId",i)]
		nSkillId = type(nSkillId) ~= "number" and 0 or nSkillId
		if not nSkillId or (nSkillId ~= 0 and not Partner:GetSkillInfoBySkillId(nSkillId)) then
			return false
		end
	end

	if type(tbReq.HealthCertificateUp) ~= "number" or tbReq.HealthCertificateUp < 1 or tbReq.HealthCertificateUp > Partner.MAX_PROTENTIAL_LIMITE_LEVEL then
		return false
	end

	if type(tbReq.AgileCertificateUp) ~= "number" or tbReq.AgileCertificateUp < 1 or tbReq.AgileCertificateUp > Partner.MAX_PROTENTIAL_LIMITE_LEVEL then
		return false
	end

	if type(tbReq.StrengthCertificateUp) ~= "number" or tbReq.StrengthCertificateUp < 1 or tbReq.StrengthCertificateUp > Partner.MAX_PROTENTIAL_LIMITE_LEVEL then
		return false
	end

	if type(tbReq.SmartCertificateUp) ~= "number" or tbReq.SmartCertificateUp < 1 or tbReq.SmartCertificateUp > Partner.MAX_PROTENTIAL_LIMITE_LEVEL then
		return false
	end

	return true
end

function tbIDIPInterface:IDIP_DO_SEND_ATTRIBUTE_FRIEND_REQ(nCmdId, tbReq, nCmdSequence)
	Player:DoAccountRoleMatchRequest(tbReq.OpenId,tbReq.RoleId,Transmit.tbIDIPInterface.OnSendAttributeFriendCheckFinish,Transmit.tbIDIPInterface,nCmdId,tbReq,nCmdSequence);
end

function tbIDIPInterface:OnSendAttributeFriendCheckFinish(szAccount, dwPlayerId, nIsMatch,nCmdId, tbReq, nCmdSequence)
	local tbRsp =
	{
		Result = IDIP_SUCCESS,
		RetMsg = "ok",
	}

	if nIsMatch == 0 then
        tbRsp.Result = IDIP_PLAYER_NOT_EXIST;
        tbRsp.RetMsg = ErrInValidAccountRoleIdNotMatch;
        self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_DO_SEND_ATTRIBUTE_FRIEND_REQ", nCmdSequence)
        return
    end

    local nFriendTemplate = tbReq.FriendTemplate
    local bIsExitPartner = Partner:CheckPartnerId(nFriendTemplate);
    if not bIsExitPartner then
        tbRsp.Result = IDIP_INVALID_PARTNER_ID;
        tbRsp.RetMsg = ErrInValidPartnerId;
        self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_DO_SEND_ATTRIBUTE_FRIEND_REQ", nCmdSequence)
        return
    end

     if not self:CheckPartnerParamValid(tbReq) then
    	tbRsp.Result = IDIP_INVALID_PARAM;
		tbRsp.RetMsg = ErrInvalidParam;
		self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_DO_SEND_ATTRIBUTE_FRIEND_REQ", nCmdSequence)
		return
    end

    local nHealthCertificate = tonumber(tbReq.HealthCertificate) 				-- 体质资质
    local nAgileCertificate = tonumber(tbReq.AgileCertificate) 					-- 敏捷资质
    local nStrengthCertificate = tonumber(tbReq.StrengthCertificate) 			-- 力量资质
    local nSmartCertificate = tonumber(tbReq.SmartCertificate) 					-- 灵巧资质

    local nHealthCertificateUp = tonumber(tbReq.HealthCertificateUp) 			-- 体质资质上限
    local nAgileCertificateUp = tonumber(tbReq.AgileCertificateUp) 				-- 敏捷资质上限
    local nStrengthCertificateUp = tonumber(tbReq.StrengthCertificateUp) 		-- 力量资质上限
    local nSmartCertificateUp = tonumber(tbReq.SmartCertificateUp) 				-- 灵巧资质上限

    local nSkillId1 = tonumber(tbReq.Skill1Id) 									-- 技能1id
    local nSkillLevel1 = tonumber(tbReq.Skill1Level) 							-- 技能1等级
    local nSkillId2 = tonumber(tbReq.Skill2Id) 									-- 技能2id
    local nSkillLevel2 = tonumber(tbReq.Skill2Level) 							-- 技能2等级
    local nSkillId3 = tonumber(tbReq.Skill3Id) 									-- 技能3id
    local nSkillLevel3 = tonumber(tbReq.Skill3Level) 							-- 技能3等级
    local nSkillId4 = tonumber(tbReq.Skill4Id) 									-- 技能4id
    local nSkillLevel4 = tonumber(tbReq.Skill4Level) 							-- 技能4等级
    local nSkillId5 = tonumber(tbReq.Skill5Id) 									-- 技能5id
    local nSkillLevel5 = tonumber(tbReq.Skill5Level) 							-- 技能5等级

    local nIsGenius = tonumber(tbReq.IsGenius) 									-- 是否奇才（int，1为是，0为否）
    local nisEquipWeapon = tonumber(tbReq.isEquipWeapon) 						-- 是否装备本命武器（int，1为是，0为否）
    local nFriendLevel = tonumber(tbReq.FriendLevel) 							-- 同伴等级
    local nFriendLevelExp = tonumber(tbReq.FriendLevelExp) 						-- 同伴当前等级的经验

    local tbMail = {};
	tbMail.To = dwPlayerId;
	tbMail.Title = "同伴返還";
	tbMail.Text =  "";
	tbMail.From = "系統";
	tbMail.nLogReazon = Env.LogWay_DoSendAttributeFriend;

	local tbData = {}
	tbData.nLevel = nFriendLevel
	tbData.nExp = nFriendLevelExp
	tbData.nGradeLevel = 0    				-- 进阶
	tbData.nWeaponState = nisEquipWeapon
	tbData.bIsBY = nIsGenius == 1 and true or false

	tbData.nVitality = nHealthCertificate
	tbData.nDexterity = nAgileCertificate
	tbData.nStrength = nStrengthCertificate
	tbData.nEnergy = nSmartCertificate

	tbData.nLimitVitality = nHealthCertificateUp
	tbData.nLimitDexterity = nAgileCertificateUp
	tbData.nLimitStrength = nStrengthCertificateUp
	tbData.nLimitEnergy = nSmartCertificateUp

	tbData.tbSkillInfo = {}
	tbData.tbSkillInfo[1] = nSkillId1
	tbData.tbSkillInfo[2] = nSkillId2
	tbData.tbSkillInfo[3] = nSkillId3
	tbData.tbSkillInfo[4] = nSkillId4
	tbData.tbSkillInfo[5] = nSkillId5

	local szParamPartner = Partner:GetSpecialPartnerValue(tbData)
	tbMail.tbAttach = {{"SpecialPartner",nFriendTemplate,szParamPartner}};

	Mail:SendSystemMail(tbMail);

	local pPlayer = KPlayer.GetPlayerObjById(dwPlayerId);

    TLog("IDIPFLOW", tbReq.AreaId, tbReq.OpenId, tbReq.FriendTemplate,1,tbReq.Serial, tbReq.Source, nCmdId, tbReq.PlatId,tbReq.Partition,
    	tbReq.RoleId, 0,"IDIP_DO_SEND_ATTRIBUTE_FRIEND_REQ",(pPlayer and "immediately") or "delay",tbReq.HealthCertificate, tbReq.AgileCertificate,
    	tbReq.StrengthCertificate,tbReq.SmartCertificate , tbReq.HealthCertificateUp,tbReq.AgileCertificateUp,
    	tbReq.StrengthCertificateUp,tbReq.StrengthCertificateUp,tbReq.SmartCertificateUp,tbReq.Skill1Id,tbReq.Skill2Id,
    	tbReq.Skill3Id,tbReq.Skill4Id,tbReq.Skill5Id,tbReq.IsGenius,tbReq.isEquipWeapon,tbReq.FriendLevel,tbReq.FriendLevelExp)

	self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_DO_SEND_ATTRIBUTE_FRIEND_REQ", nCmdSequence)

end

function tbIDIPInterface:IDIP_DO_SEND_NOATTACH_MAIL_TO_DESIGN_PLAYER_REQ(nCmdId, tbReq, nCmdSequence)
	local tbRsp =
	{
		Result = IDIP_SUCCESS,
		RetMsg = "ok",
	}

	local szTitle = tbReq.MailTitle or ""
	local szContent = tbReq.MailContent or ""



	local tbMail = {};

    tbMail.Title = szTitle;
    tbMail.Text = string.format(szContent);
    tbMail.From = "系統";

    Mail:SendGlobalSystemMail(tbMail);


	TLog("IDIPFLOW", tbReq.AreaId, tbReq.OpenId,0,0, tbReq.Serial, tbReq.Source, nCmdId, tbReq.PlatId,
	        tbReq.Partition, tbReq.RoleId,0, "IDIP_DO_SEND_NOATTACH_MAIL_TO_DESIGN_PLAYER_REQ", tbReq.MailTitle,tbReq.MailContent)

	self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_DO_SEND_NOATTACH_MAIL_TO_DESIGN_PLAYER_REQ", nCmdSequence)
end

function tbIDIPInterface:IDIP_QUERY_ROLE_MAIL_REQ(nCmdId, tbReq, nCmdSequence)

	local tbRsp =
	{
		Result = IDIP_SUCCESS,
		RetMsg = "ok",
	}

	local nRoleId = tonumber(tbReq.RoleId)
	local szRoleName = tbReq.RoleName or ""
	if not nRoleId and szRoleName == "" then
		tbRsp.Result = IDIP_PLAYER_NOT_EXIST
		tbRsp.RetMsg = ErrInValidRoleIdRoleNameNotMatch
		Log("IDIP_QUERY_ROLE_MAIL_REQ =======not RoleID and not RoleName")
		self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_QUERY_ROLE_MAIL_REQ",nCmdSequence)
		return
	end

	if nRoleId and szRoleName ~= "" then
		if not self:CheckRoleIsFit(nRoleId,tbReq.RoleName) then
			tbRsp.Result = IDIP_PLAYER_NOT_EXIST
			tbRsp.RetMsg = ErrInValidRoleIdRoleNameNotMatch
			Log("IDIP_QUERY_ROLE_MAIL_REQ ======= RoleID and RoleName not match",tbReq.RoleId,tbReq.RoleName)
			self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_QUERY_ROLE_MAIL_REQ",nCmdSequence)
			return
		end
	end

	if not nRoleId then
		local tbStayInfo = KPlayer.GetRoleStayInfo(szRoleName);
		if not tbStayInfo then
			tbRsp.Result = IDIP_PLAYER_NOT_EXIST;
			tbRsp.RetMsg = ErrPlayerNotExist;
			self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_QUERY_ROLE_MAIL_REQ",nCmdSequence)
			return
		end
		nRoleId = tbStayInfo.dwID;
	end

	Player:DoAccountRoleMatchRequest(tbReq.OpenId,nRoleId,Transmit.tbIDIPInterface.OnQueryRoleMailCheckFinish,Transmit.tbIDIPInterface,nCmdId,tbReq,nCmdSequence);
end

function tbIDIPInterface:OnQueryRoleMailCheckFinish(szAccount, dwPlayerId, nIsMatch,nCmdId, tbReq, nCmdSequence)
	local tbRsp =
	{
		Result = IDIP_SUCCESS,
		RetMsg = "ok",
	}

	if nIsMatch == 0 then
		tbRsp.Result = IDIP_PLAYER_NOT_EXIST;
		tbRsp.RetMsg = ErrInValidAccountRoleIdNotMatch;
		self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_QUERY_ROLE_MAIL_REQ", nCmdSequence)
		return
	end

	Mail:GetPLayerMailListInfo(dwPlayerId, Transmit.tbIDIPInterface.OnQueryRoleMailInfo,Transmit.tbIDIPInterface,nCmdId,tbReq,nCmdSequence)
end

function tbIDIPInterface:OnQueryRoleMailInfo(tbAllMails,nCmdId,tbReq,nCmdSequence)
	local tbRsp =
	{
		Result = IDIP_SUCCESS,
		RetMsg = "ok",

		MailList_count = 0,
		MailList = {},
		TotalPageNo = 0,
	}

	local nPage = tonumber(tbReq.PageNo) or 0

	local nNumPerPage = 5
	local nStartNum = nPage * nNumPerPage + 1
	local nEndNum = (nPage + 1) * nNumPerPage
	if tbAllMails and next(tbAllMails) then
		for nNum = nStartNum,nEndNum do
			if not tbAllMails[nNum] then
				break;
			else
				local tbMails = {}
				local tbInfo = tbAllMails[nNum]

				tbMails.MailTitle = tbInfo.Title;
				tbMails.MailContent = tbInfo.Text;
				tbMails.SendTime = tbInfo.SendTime;
				tbMails.IsRead = tbInfo.ReadFlag and 1 or 0;
				tbMails.IsAttach = (tbInfo.tbAttach and next(tbInfo.tbAttach)) and 1 or 0;
				tbMails.AttachItemStr = 0;
				if tbMails.IsAttach == 1 then
					tbMails.AttachItemStr = self:GetAttachStr(tbInfo.tbAttach)
				end

				table.insert(tbRsp.MailList,tbMails);
			end
		end
		tbRsp.MailList_count = Lib:CountTB(tbRsp.MailList);
		tbRsp.TotalPageNo = math.ceil(Lib:CountTB(tbAllMails) / nNumPerPage);
	end

	TLog("IDIPFLOW", tbReq.AreaId, tbReq.OpenId, 0,0, tbReq.Serial, tbReq.Source, nCmdId, tbReq.PlatId,
	        tbReq.Partition, tbReq.RoleId,0, "IDIP_QUERY_ROLE_MAIL_REQ",tbReq.PageNo,tbReq.RoleName)

	self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_QUERY_ROLE_MAIL_REQ",nCmdSequence)
end

function tbIDIPInterface:GetAttachStr(tbAward)
	local szAward = ""

	local szAward = "";
	for _,tbItem in ipairs(tbAward or {}) do
		local nCount = Lib:CountTB(tbItem)
		szAward = szAward .."'";
		for index,value in ipairs(tbItem) do

			local szDiv = ","

			if index == 1 then
				szDiv = "',";
			end

			szAward = szAward ..value;

			if index ~= nCount then
				szAward = szAward ..szDiv;
			end
		end
		szAward = szAward ..";";
	end

	return szAward
end

function tbIDIPInterface:IDIP_DO_SEND_ATTACH_MAIL_TO_DESIGN_PARTION_LEVEL_PLAYER_REQ(nCmdId, tbReq, nCmdSequence)

	local tbRsp =
	{
		Result = IDIP_SUCCESS,
		RetMsg = "ok",
	}

	if not tonumber(tbReq.Type) or not tonumber(tbReq.ItemNum) or not tonumber(tbReq.Level) then
		tbRsp.Result = IDIP_INVALID_PARAM
        tbRsp.RetMsg = ErrInvalidParam
        self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_DO_SEND_ATTACH_MAIL_TO_DESIGN_PARTION_LEVEL_PLAYER_REQ", nCmdSequence)
        return
	end

	local szTitle = tbReq.MailTitle or ""
	local szContent = tbReq.MailContent or ""

	local tbMail = {};
	tbMail.Title = szTitle;
	tbMail.Text = string.format(szContent);
	tbMail.From = "系統";
	tbMail.LevelLimit = tbReq.Level
	tbMail.nLogReazon = Env.LogWay_IdipDoSendAttachMailToDesignPartionLevelPlayerReq;

	local bIsHaveItem = nil
	if tbReq.Type == tbItemType.item then
		if not tonumber(tbReq.ItemId) then
			tbRsp.Result = IDIP_INVALID_ITEM_ID
            tbRsp.RetMsg = ErrInValidItemId
            self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_DO_SEND_ATTACH_MAIL_TO_DESIGN_PARTION_LEVEL_PLAYER_REQ", nCmdSequence)
            return
		end
		bIsHaveItem = KItem.GetItemBaseProp(tbReq.ItemId);
	    if not bIsHaveItem then
	        tbRsp.Result = IDIP_INVALID_ITEM_ID;
	        tbRsp.RetMsg = ErrInValidItemId;
	        self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_DO_SEND_ATTACH_MAIL_TO_DESIGN_PARTION_LEVEL_PLAYER_REQ", nCmdSequence)
	        return
	    end
	elseif tbReq.Type == tbItemType.Partner then
		bIsHaveItem = Partner:CheckPartnerId(tbReq.ItemId);
	    if not bIsHaveItem then
	        tbRsp.Result = IDIP_INVALID_PARTNER_ID;
	        tbRsp.RetMsg = ErrInValidPartnerId;
	        self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_DO_SEND_ATTACH_MAIL_TO_DESIGN_PARTION_LEVEL_PLAYER_REQ", nCmdSequence)
	        return
	    end
	end

	local tbAward = self:GetAwardList(tbReq.Type,tbReq.ItemId,tbReq.ItemNum);
	if not tbAward then
		tbRsp.Result = IDIP_INVALID_ITEM_TYPE
		tbRsp.RetMsg = ErrInValidItemType
		Log("IDIP_DO_SEND_ATTACH_MAIL_TO_DESIGN_PARTION_LEVEL_PLAYER_REQ ========= no match awardType" ,tbReq.Type,tbReq.ItemId,tbReq.ItemNum);
		self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_DO_SEND_ATTACH_MAIL_TO_DESIGN_PARTION_LEVEL_PLAYER_REQ", nCmdSequence)
		return
	end

	tbMail.tbAttach = {tbAward};

	Mail:SendGlobalSystemMail(tbMail);

	TLog("IDIPFLOW", tbReq.AreaId, tbReq.OpenId, tbReq.ItemId, tbReq.ItemNum, tbReq.Serial, tbReq.Source, nCmdId, tbReq.PlatId,
		tbReq.Partition, tbReq.RoleId,0, "IDIP_DO_SEND_ATTACH_MAIL_TO_DESIGN_PARTION_LEVEL_PLAYER_REQ",tbReq.Level,tbReq.MailTitle,tbReq.MailContent,tbReq.Type)

	self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_DO_SEND_ATTACH_MAIL_TO_DESIGN_PARTION_LEVEL_PLAYER_REQ", nCmdSequence)
end

function tbIDIPInterface:IDIP_QUERY_ROLEID_TO_OPENID_REQ(nCmdId, tbReq, nCmdSequence)
	local tbRsp =
	{
		Result = IDIP_SUCCESS,
		RetMsg = "ok",
		OpenId = "",
	}

	local nPlayerId = tonumber(tbReq.RoleId)

	if not nPlayerId then
		tbRsp.Result = IDIP_PLAYER_NOT_EXIST;
        tbRsp.RetMsg = ErrPlayerNotExist;
        self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_QUERY_ROLEID_TO_OPENID_REQ", nCmdSequence)
        return
	end

	local tbStayInfo = KPlayer.GetRoleStayInfo(nPlayerId);
	if not tbStayInfo then
		tbRsp.Result = IDIP_PLAYER_NOT_EXIST;
        tbRsp.RetMsg = ErrPlayerNotExist;
        self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_QUERY_ROLEID_TO_OPENID_REQ", nCmdSequence)
        return
	end

	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if pPlayer then
		tbRsp.OpenId = pPlayer.szAccount

		TLog("IDIPFLOW", tbReq.AreaId,tbRsp.OpenId,0,0,tbReq.Serial, tbReq.Source, nCmdId, tbReq.PlatId,
			tbReq.Partition, tbReq.RoleId,0,"IDIP_QUERY_ROLEID_TO_OPENID_REQ","immediately")

		self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_QUERY_ROLEID_TO_OPENID_REQ", nCmdSequence)
	else
		Player:DoPlayerQueryInfoRequest(nPlayerId, Transmit.tbIDIPInterface.OnQueryPlayerOpenIdInfo, Transmit.tbIDIPInterface,nCmdId, tbReq,nCmdSequence)
	end
end

function tbIDIPInterface:OnQueryPlayerOpenIdInfo(tbQueryInfo, nCmdId, tbReq, nCmdSequence)

	local tbRsp =
	{
		Result = IDIP_SUCCESS,
		RetMsg = "ok",
		OpenId = tbQueryInfo.szAccount or "",
	}

	TLog("IDIPFLOW", tbReq.AreaId, tbRsp.OpenId,0,0, tbReq.Serial, tbReq.Source, nCmdId, tbReq.PlatId,
			tbReq.Partition, tbReq.RoleId,0, "IDIP_QUERY_ROLEID_TO_OPENID_REQ","delay")

	self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_QUERY_ROLEID_TO_OPENID_REQ", nCmdSequence)
end

function tbIDIPInterface:IDIP_QUERY_ROLECURTITLE_REQ(nCmdId, tbReq, nCmdSequence)
	local tbRsp =
	{
		Result = IDIP_SUCCESS,
		RetMsg = "ok",
	}

	local nRoleId = tonumber(tbReq.RoleId)
	local szRoleName = tbReq.RoleName or ""
	if not nRoleId and szRoleName == "" then
		tbRsp.Result = IDIP_PLAYER_NOT_EXIST
		tbRsp.RetMsg = ErrPlayerNotExist
		Log("IDIP_QUERY_ROLECURTITLE_REQ =======not RoleID and not RoleName")
		self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_QUERY_ROLECURTITLE_REQ",nCmdSequence)
		return
	end

	if nRoleId and szRoleName ~= "" then
		if not self:CheckRoleIsFit(nRoleId,tbReq.RoleName) then
			tbRsp.Result = IDIP_PLAYER_NOT_EXIST
			tbRsp.RetMsg = ErrPlayerNotExist
			Log("IDIP_QUERY_ROLECURTITLE_REQ ======= RoleID and RoleName not match",tbReq.RoleId,tbReq.RoleName)
			self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_QUERY_ROLECURTITLE_REQ",nCmdSequence)
			return
		end
	end

	if not nRoleId then
		local tbStayInfo = KPlayer.GetRoleStayInfo(szRoleName);
		if not tbStayInfo then
			tbRsp.Result = IDIP_PLAYER_NOT_EXIST;
			tbRsp.RetMsg = ErrPlayerNotExist;
			self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_QUERY_ROLECURTITLE_REQ",nCmdSequence)
			return
		end
		nRoleId = tbStayInfo.dwID;
	end

	Player:DoAccountRoleMatchRequest(tbReq.OpenId,nRoleId,Transmit.tbIDIPInterface.OnQueryRoleCurTitleCheckFinish,Transmit.tbIDIPInterface,nCmdId,tbReq,nCmdSequence);
end

function tbIDIPInterface:OnQueryRoleCurTitleCheckFinish(szAccount, dwPlayerId, nIsMatch,nCmdId, tbReq, nCmdSequence)

	local tbRsp =
	{
		Result = IDIP_SUCCESS,
		RetMsg = "ok",

		TitleList_count = 0,
		TitleList = {},
		Totalpage = 0,
		Total = 0,
	}

	if nIsMatch == 0 then
		tbRsp.Result = IDIP_PLAYER_NOT_EXIST;
		tbRsp.RetMsg = ErrInValidAccountRoleIdNotMatch;
		self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_QUERY_ROLECURTITLE_REQ", nCmdSequence)
		return
	end

	local pPlayer = KPlayer.GetPlayerObjById(dwPlayerId);
	if pPlayer then

		local tbTitleData = PlayerTitle:GetPlayerTitleData(pPlayer)
    	local tbTempAllTitle = tbTitleData.tbAllTitle or {}

    	if next(tbTempAllTitle) then

    		local tbAllTitle = {}

			for _,tbTitle in pairs(tbTempAllTitle) do
				table.insert(tbAllTitle,tbTitle)
			end

    		tbAllTitle = self:SortTitle(tbAllTitle)

    		local nPage = tonumber(tbReq.Page) or 0

   			tbRsp.TitleList,tbRsp.Totalpage,tbRsp.Total = self:GetPageTitle(tbAllTitle,nPage)

   			tbRsp.TitleList_count = #tbRsp.TitleList
    	end

    	TLog("IDIPFLOW", tbReq.AreaId, tbReq.OpenId,0,0,tbReq.Serial, tbReq.Source, nCmdId, tbReq.PlatId,
			tbReq.Partition, tbReq.RoleId,0,"IDIP_QUERY_ROLECURTITLE_REQ","immediately", tbReq.RoleName, tbReq.Page)

		self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_QUERY_ROLECURTITLE_REQ", nCmdSequence)
	else
		Player:DoPlayerQueryInfoRequest(dwPlayerId, Transmit.tbIDIPInterface.OnQueryPlayerTitleInfo, Transmit.tbIDIPInterface,nCmdId,tbReq,nCmdSequence)
	end
end

function tbIDIPInterface:OnQueryPlayerTitleInfo(tbQueryInfo,nCmdId,tbReq,nCmdSequence)

	local tbRsp =
	{
		Result = IDIP_SUCCESS,
		RetMsg = "ok",

		TitleList_count = 0,
		TitleList = {},
		Totalpage = 0,
		Total = 0,
	}

	local tbTitleList = tbQueryInfo.tbTitleList or {}

	if next(tbTitleList) then

		local tbAllTitle = {}

		for _,nID in pairs(tbTitleList) do
			local tbTitle = {
				nTitleID = nID,
			}
			table.insert(tbAllTitle,tbTitle)
		end

		tbAllTitle = self:SortTitle(tbAllTitle)

		local nPage = tonumber(tbReq.Page) or 0

		tbRsp.TitleList,tbRsp.Totalpage,tbRsp.Total = self:GetPageTitle(tbAllTitle,nPage)

    	tbRsp.TitleList_count = #tbRsp.TitleList
    end

    TLog("IDIPFLOW", tbReq.AreaId, tbReq.OpenId,0,0,tbReq.Serial, tbReq.Source, nCmdId, tbReq.PlatId,
			tbReq.Partition, tbReq.RoleId,0,"IDIP_QUERY_ROLECURTITLE_REQ","delay", tbReq.RoleName, tbReq.Page)

	self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_QUERY_ROLECURTITLE_REQ", nCmdSequence)
end

function tbIDIPInterface:GetPageTitle(tbAllTitle,nPage)
	local tbPageTitle = {}
    local nNumPerPage = 50
    local nStartNum = nPage * nNumPerPage + 1
    local nEndNum = (nPage + 1) * nNumPerPage

	for nNum = nStartNum,nEndNum do
		local tbTitle = tbAllTitle[nNum]
        if not tbTitle then
            break;
        else
        	local nTitleID = tbTitle.nTitleID
			local tbTitleInfo = PlayerTitle:GetTitleTemplate(nTitleID) or {}
			local tbInfo = {
				TitleId = nTitleID,
				TitleName = tbTitleInfo.Name or "",
				TitleIntroduction = tbTitleInfo.Desc or "",
			}
			table.insert(tbPageTitle,tbInfo)
        end
    end

    local nTitleCount = Lib:CountTB(tbAllTitle)

    return tbPageTitle,math.ceil(nTitleCount / nNumPerPage),nTitleCount
end

function tbIDIPInterface:SortTitle(tbAllTitle)

	local function SortDes(a,b)
		return a.nTitleID < b.nTitleID
	end
	table.sort(tbAllTitle,SortDes)

	return tbAllTitle
end

------------------------------------------------------------ AQ 需求 --------------------------------------------------------------

-- 禁言(AQ)请求
function tbIDIPInterface:IDIP_AQ_DO_MASKCHAT_USR_REQ(nCmdId, tbReq, nCmdSequence)
	Player:DoAccountRoleMatchRequest(tbReq.OpenId,tbReq.RoleId,Transmit.tbIDIPInterface.OnMaskChatCheckFinish,Transmit.tbIDIPInterface,nCmdId,tbReq,nCmdSequence);
end

function tbIDIPInterface:OnMaskChatCheckFinish(szAccount, dwPlayerId, nIsMatch,nCmdId, tbReq, nCmdSequence)

	local tbRsp =
	{
		Result = IDIP_SUCCESS,
		RetMsg = "ok",
	}

	if nIsMatch == 0 then
		tbRsp.Result = IDIP_PLAYER_NOT_EXIST;
		tbRsp.RetMsg = ErrInValidAccountRoleIdNotMatch;
		self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_AQ_DO_MASKCHAT_USR_REQ", nCmdSequence)
		return
	end

	local nTime = tonumber(tbReq.Time);
	if not nTime or nTime < 1 then
		tbRsp.Result = IDIP_NOT_Time
    	tbRsp.RetMsg = ErrNoTime
    	self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_AQ_DO_MASKCHAT_USR_REQ", nCmdSequence)
		return
	end

	local pPlayerInfo = KPlayer.GetRoleStayInfo(dwPlayerId);
	local pAsyncData = KPlayer.GetAsyncData(dwPlayerId)
	if not pPlayerInfo or not pAsyncData then
		tbRsp.Result = IDIP_PLAYER_NOT_EXIST
    	tbRsp.RetMsg = ErrPlayerNotExist
    	self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_AQ_DO_MASKCHAT_USR_REQ", nCmdSequence)
		return
	end

	local nPunish = tonumber(tbReq.IsPunish) or -1
	local nForbidType = (nPunish and nPunish == 1) and ChatMgr.ForbidType.Public or ChatMgr.ForbidType.All
	pAsyncData.SetChatForbidType(nForbidType);
	pAsyncData.SetChatForbidEndTime(GetTime() + nTime);
	pAsyncData.SetChatForbidSilence(0);

	local pPlayer = KPlayer.GetPlayerObjById(dwPlayerId)
	local szReason = tbReq.Reason;
	if pPlayer and szReason and szReason ~= "" then
		pPlayer.MsgBox(szReason, {{"確定"}, {"取消"}})
	end

	TLog("IDIPFLOW", tbReq.AreaId, tbReq.OpenId,0,0, tbReq.Serial, tbReq.Source, nCmdId, tbReq.PlatId,
	        tbReq.Partition, tbReq.RoleId,0, "IDIP_AQ_DO_MASKCHAT_USR_REQ", (pPlayer and "immediately") or "delay", nTime, szReason, nPunish)

	self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_AQ_DO_MASKCHAT_USR_REQ", nCmdSequence)
end

function tbIDIPInterface:ClearAllRank(nPlayerId,nFaction)
	for szKey,_ in pairs(self.tbClearRank) do
		local pRank = KRank.GetRankBoard(szKey)
		if pRank then
			pRank.RemoveByID(nPlayerId)
		end
	end

	local szFactionRank = "FightPower_" ..nFaction
	local pFactionRank = KRank.GetRankBoard(szFactionRank)
	if pFactionRank then
		pFactionRank.RemoveByID(nPlayerId)
	end
end

function tbIDIPInterface:IDIP_AQ_DO_BAN_ROLE_REQ(nCmdId, tbReq, nCmdSequence)
	Player:DoAccountRoleMatchRequest(tbReq.OpenId,tbReq.RoleId,Transmit.tbIDIPInterface.OnBanRoleCheckFinish,Transmit.tbIDIPInterface,nCmdId,tbReq,nCmdSequence);
end

function tbIDIPInterface:OnBanRoleCheckFinish(szAccount, dwPlayerId, nIsMatch,nCmdId, tbReq, nCmdSequence)

	local tbRsp =
	{
		Result = IDIP_SUCCESS,
		RetMsg = "ok",
	}

	if nIsMatch == 0 then
		tbRsp.Result = IDIP_PLAYER_NOT_EXIST;
		tbRsp.RetMsg = ErrInValidAccountRoleIdNotMatch;
		self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_AQ_DO_BAN_ROLE_REQ", nCmdSequence)
		return
	end

	local nTime = tonumber(tbReq.Time);
	if not nTime or nTime < 0 then
		tbRsp.Result = IDIP_NOT_Time
    	tbRsp.RetMsg = ErrNoTime
    	self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_AQ_DO_BAN_ROLE_REQ", nCmdSequence)
		return
	end

	dwPlayerId = tonumber(dwPlayerId);
	local pPlayerInfo = KPlayer.GetRoleStayInfo(dwPlayerId);
	if not pPlayerInfo then
		tbRsp.Result = IDIP_PLAYER_NOT_EXIST
    	tbRsp.RetMsg = ErrPlayerNotExist
    	self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_AQ_DO_BAN_ROLE_REQ", nCmdSequence)
		return
	end
	local szReason = tbReq.Reason or "";

	local pPlayer = KPlayer.GetPlayerObjById(dwPlayerId)
	if pPlayer and szReason ~= "" then
		pPlayer.CallClientScript("Ui:OnShowKickMsg", string.format("此角色由於%s已被凍結", szReason));
	end

	local nFaction = pPlayer and pPlayer.nFaction or pPlayerInfo.nFaction

	if nTime ~= 0 then
		BanPlayer(dwPlayerId,GetTime() + nTime,szReason);
	end

	-- 禁角色的同时要求下榜
	Lib:CallBack({Transmit.tbIDIPInterface.ClearAllRank,Transmit.tbIDIPInterface,dwPlayerId,nFaction or 0});

	TLog("IDIPFLOW", tbReq.AreaId, tbReq.OpenId,0,0, tbReq.Serial, tbReq.Source, nCmdId, tbReq.PlatId,
	        tbReq.Partition, tbReq.RoleId,0, "IDIP_AQ_DO_BAN_ROLE_REQ", (pPlayer and "immediately") or "delay", nTime, szReason)

	self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_AQ_DO_BAN_ROLE_REQ", nCmdSequence)
end

function tbIDIPInterface:IDIP_AQ_QUERY_USERBASE_INFO_REQ(nCmdId, tbReq, nCmdSequence)
	Player:DoAccountRoleMatchRequest(tbReq.OpenId,tbReq.RoleId,Transmit.tbIDIPInterface.OnQueryUserBaseCheckFinish,Transmit.tbIDIPInterface,nCmdId,tbReq,nCmdSequence);
end

function tbIDIPInterface:OnQueryUserBaseCheckFinish(szAccount, dwPlayerId, nIsMatch,nCmdId, tbReq, nCmdSequence)

	local tbRsp =
	{
		Result = IDIP_SUCCESS,
		RetMsg = "ok",
		RoleName = "",
        Money = 0,
        Diamond = 0,
        Biography = 0,
        Honor = 0,
        Contribute = 0,
        SoulStone = 0,       					-- 目前游戏中没有魂石
        Friend = 0,
        Skill = 0,
        Fighting = 0,
        ShrineHighestRanking = 0,
	}

	if nIsMatch == 0 then
        tbRsp.Result = IDIP_PLAYER_NOT_EXIST;
        tbRsp.RetMsg = ErrInValidAccountRoleIdNotMatch;
        self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_AQ_QUERY_USERBASE_INFO_REQ", nCmdSequence)
        return
    end

    local pPlayer = KPlayer.GetPlayerObjById(dwPlayerId)
    if pPlayer then
    	tbRsp.RoleName = pPlayer.szName
		tbRsp.Money = pPlayer.GetMoney("Coin");
		tbRsp.Diamond = pPlayer.GetMoney("Gold") - pPlayer.GetMoneyDebt("Gold");
		tbRsp.Biography = pPlayer.GetMoney("Biography");
		tbRsp.Honor = pPlayer.GetMoney("Honor");
		tbRsp.Contribute = pPlayer.GetMoney("Contrib");
		tbRsp.Friend = pPlayer.GetMoney("Jade");
		tbRsp.Skill = pPlayer.GetMoney("SkillPoint");
		tbRsp.Fighting = pPlayer.GetFightPower();
		tbRsp.ShrineHighestRanking = RankBattle:GetBestRank(pPlayer);

		TLog("IDIPFLOW", tbReq.AreaId, tbReq.OpenId,0,0, tbReq.Serial, tbReq.Source, nCmdId, tbReq.PlatId,
      		  tbReq.Partition,dwPlayerId,0, "IDIP_AQ_QUERY_USERBASE_INFO_REQ")

		self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_AQ_QUERY_USERBASE_INFO_REQ",nCmdSequence)
		return
    end

    local pPlayerInfo = KPlayer.GetRoleStayInfo(dwPlayerId);
	if not pPlayerInfo then
		tbRsp.Result = IDIP_PLAYER_NOT_EXIST;
    	tbRsp.RetMsg = ErrPlayerNotExist;
    	self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_AQ_QUERY_USERBASE_INFO_REQ", nCmdSequence);
    	return
	end

	Player:DoPlayerQueryInfoRequest(dwPlayerId, Transmit.tbIDIPInterface.OnQueryUserBaseInfo, Transmit.tbIDIPInterface,nCmdSequence,tbReq,nCmdId);
end

function tbIDIPInterface:OnQueryUserBaseInfo(tbQueryInfo,nCmdSequence,tbReq,nCmdId)

	local tbRsp =
	{
		Result = IDIP_SUCCESS,
		RetMsg = "ok",
		RoleName = "",
        Money = 0,
        Diamond = 0,
        Biography = 0,
        Honor = 0,
        Contribute = 0,
        SoulStone = 0,             					-- 目前游戏中没有魂石
        Friend = 0,
        Skill = 0,
        Fighting = 0,
        ShrineHighestRanking = 0,
	}

	if not tbQueryInfo or not next(tbQueryInfo) then
        self:IDIPDelayResponse(IDIP_PLAYER_NOT_EXIST,tbRsp,ErrInValidOpenId,"IDIP_AQ_QUERY_USERBASE_INFO_REQ",nCmdSequence)
        return
    end

	if tbQueryInfo and next(tbQueryInfo) then
		local pPlayer = KPlayer.GetPlayerObjById(tbQueryInfo.dwID) or KPlayer.GetRoleStayInfo(tbQueryInfo.dwID);
		tbRsp.RoleName = pPlayer.szName
		tbRsp.Money = tbQueryInfo.nCoin;
		tbRsp.Diamond = tbQueryInfo.nGold;
		tbRsp.Biography = tbQueryInfo.nBiography;
		tbRsp.Honor = tbQueryInfo.nHonor;
		tbRsp.Contribute = tbQueryInfo.nContrib;
		tbRsp.Friend = tbQueryInfo.nJade;
		tbRsp.Skill = tbQueryInfo.nSkillPoint;
		tbRsp.Fighting = tbQueryInfo.nFightPower;
		tbRsp.ShrineHighestRanking = tbQueryInfo.nBestRankBattle;
	end

	TLog("IDIPFLOW", tbReq.AreaId, tbReq.OpenId,0,0, tbReq.Serial, tbReq.Source, nCmdId, tbReq.PlatId,
        tbReq.Partition,tbQueryInfo.dwID,0, "IDIP_AQ_QUERY_USERBASE_INFO_REQ")

	self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_AQ_QUERY_USERBASE_INFO_REQ",nCmdSequence)
end

function tbIDIPInterface:IDIP_AQ_DO_UPDATE_MONEY_REQ(nCmdId, tbReq, nCmdSequence)
	Player:DoAccountRoleMatchRequest(tbReq.OpenId,tbReq.RoleId,Transmit.tbIDIPInterface.OnUpdateMoneyCheckFinish,Transmit.tbIDIPInterface,nCmdId,tbReq,nCmdSequence);
end

function tbIDIPInterface:OnUpdateMoneyCheckFinish(szAccount, dwPlayerId, nIsMatch,nCmdId, tbReq, nCmdSequence)
	local tbRsp =
	{
		Result = IDIP_SUCCESS,
		RetMsg = "ok",
	}
	if nIsMatch == 0 then
		tbRsp.Result = IDIP_PLAYER_NOT_EXIST;
		tbRsp.RetMsg = ErrInValidAccountRoleIdNotMatch;
		self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_AQ_DO_UPDATE_MONEY_REQ", nCmdSequence)
		return
	end
	local nCoin = tonumber(tbReq.Value);
	if not nCoin then
		tbRsp.Result = IDIP_INVALID_PARAM
		tbRsp.RetMsg = ErrInvalidParam
		self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_AQ_DO_UPDATE_MONEY_REQ", nCmdSequence)
		return
	end
	local pPlayer = KPlayer.GetPlayerObjById(tbReq.RoleId);
	if pPlayer then
		if nCoin >= 0 then
			pPlayer.AddMoney("Coin",nCoin,Env.LogWay_IdipDoUpdateMoneyReq);
		elseif nCoin < 0 then
			local nCost = self:GetCost(pPlayer,"Coin",nCoin);
			pPlayer.CostMoney("Coin",nCost,Env.LogWay_IdipDoUpdateMoneyReq);
		end
	else
		local pPlayerInfo = KPlayer.GetRoleStayInfo(tbReq.RoleId);
		if pPlayerInfo then
			local szCmd = "";
			local nCost = nCoin;
			if nCost >= 0 then
				szCmd = string.format("me.AddMoney('Coin', %d, %d)",nCost,Env.LogWay_IdipDoUpdateMoneyReq);
			elseif nCost < 0 then
				szCmd = string.format("local nCost = Transmit.tbIDIPInterface:GetCost(me,'Coin',%d);me.CostMoney('Coin', math.abs(nCost), %d)",nCost,Env.LogWay_IdipDoDelMoneyReq);
			end
			KPlayer.AddDelayCmd(tbReq.RoleId,
				szCmd,
				string.format("%s|%d|%s|%s", 'IDIP_AQ_DO_UPDATE_MONEY_REQ', nCost, tbReq.Source, tbReq.Serial))
		else
			tbRsp.Result = IDIP_PLAYER_NOT_EXIST
			tbRsp.RetMsg = ErrPlayerNotExist
		end
	end

	TLog("IDIPFLOW", tbReq.AreaId, tbReq.OpenId, 0, tbReq.Value, tbReq.Serial, tbReq.Source, nCmdId, tbReq.PlatId,
		tbReq.Partition, tbReq.RoleId, 0, "IDIP_AQ_DO_UPDATE_MONEY_REQ", (pPlayer and "immediately") or "delay")

	self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_AQ_DO_UPDATE_MONEY_REQ", nCmdSequence)
end

function tbIDIPInterface:IdipAQTryDelayCostGold(nPlayerId,nGold,nIsNegative,szSource,szSerial)
	local szCmd = "";
	local szLog = string.format("%s|%d|%s|%s", 'IDIP_AQ_DO_UPDATE_DIAMOND_REQ', nGold, szSource,szSerial)
	if nGold >= 0 then
		szCmd = string.format("me.AddMoney('Gold', %d, %d)",nGold,Env.LogWay_IdipDoUpdateDiamondReq);
	elseif nGold < 0 then
		szCmd = string.format("Transmit.tbIDIPInterface:IdipAQDelayCostGold(%u,%d,%d,'%s','%s')",nPlayerId,nGold,nIsNegative,szSource,szSerial)
	end
	KPlayer.AddDelayCmd(nPlayerId,szCmd,szLog)
	Log("IDIP_AQ_DO_UPDATE_DIAMOND_REQ IdipAQTryDelayCostGold AddDelayCmd",nPlayerId,nGold, nIsNegative,szCmd)
end

function tbIDIPInterface:IdipAQDelayCostGold(nPlayerId,nGold,nIsNegative,szSource,szSerial)
	Log("IDIP_AQ_DO_UPDATE_DIAMOND_REQ IdipAQDelayCostGold execute",nPlayerId,nGold, nIsNegative)
	local szLog = string.format("%s|%d|%s|%s", 'IDIP_AQ_DO_UPDATE_DIAMOND_REQ', nGold, szSource,szSerial)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		self:IdipAQTryDelayCostGold(nPlayerId,nGold,nIsNegative,szSource,szSerial);
		Log("IDIP_AQ_DO_UPDATE_DIAMOND_REQ IdipAQTryDelayCostGold not pPlayer add 2 delay cmd", nPlayerId,nGold,nIsNegative);
		return
	end
	local nCost = self:GetCost(pPlayer,"Gold",nGold);
	if nCost == 0 then
		if nIsNegative == 1 then
			Player:AddMoneyDebt(nPlayerId, "Gold", math.abs(nGold), Env.LogWay_Money_Debt_Add, 0, true)
			Log("IDIP_AQ_DO_UPDATE_DIAMOND_REQ IdipAQDelayCostGold AddMoneyDebt dir", nPlayerId,nGold,nCost,nIsNegative);
		end
		return
	end
	pPlayer.CostGold(nCost,Env.LogWay_IdipDoUpdateDiamondReq,nil,function (nPlayerId, bSuccess)
			if bSuccess then
				if nIsNegative == 1 and math.abs(nGold) > nCost then
					Player:AddMoneyDebt(nPlayerId, "Gold", math.abs(nGold) - nCost, Env.LogWay_Money_Debt_Add, 0, true)
					Log("IDIP_AQ_DO_UPDATE_DIAMOND_REQ IdipAQDelayCostGold CostGold AddMoneyDebt ", nPlayerId,nGold,nCost,nIsNegative);
				end
				Log("IDIP_AQ_DO_UPDATE_DIAMOND_REQ IdipAQDelayCostGold CostGold success ", nPlayerId,nGold,nCost,nIsNegative);
				return true
			end
			--不成功强制加延迟指令
			Transmit.tbIDIPInterface:IdipAQTryDelayCostGold(nPlayerId,nGold,nIsNegative,szSource,szSerial);
			Log("IDIP_AQ_DO_UPDATE_DIAMOND_REQ IdipAQDelayCostGold CostGold fail add 2 delay cmd", nPlayerId,nGold,nCost,nIsNegative);
			return true;
		end);
end

function tbIDIPInterface:IdipAQCostGold(nPlayerId,nGold,nIsNegative,szSource,szSerial)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		self:IdipAQTryDelayCostGold(nPlayerId,nGold,nIsNegative,szSource,szSerial)
		Log("IDIP_AQ_DO_UPDATE_DIAMOND_REQ IdipAQCostGold not pPlayer add 2 delay cmd", nPlayerId,nGold,nIsNegative);
		return
	end

	local nCost = self:GetCost(pPlayer,"Gold",nGold);
	if nCost == 0 then
		if nIsNegative == 1 then
			Player:AddMoneyDebt(nPlayerId, "Gold", math.abs(nGold), Env.LogWay_Money_Debt_Add, 0, true)
			Log("IDIP_AQ_DO_UPDATE_DIAMOND_REQ IdipAQCostGold AddMoneyDebt dir", nPlayerId,nGold,nCost,nIsNegative);
		end
		return
	end
	pPlayer.CostGold(nCost,Env.LogWay_IdipDoUpdateDiamondReq,nil,Transmit.tbIDIPInterface.OnAQCostGoldCallBack, szSource, szSerial,nGold,nCost,nIsNegative);
end

function tbIDIPInterface.OnAQCostGoldCallBack(nPlayerId, bSuccess,szBilloNo, szSource, szSerial,nGold,nCost,nIsNegative)
	if bSuccess then
		if nIsNegative == 1 and math.abs(nGold) > nCost then
			Player:AddMoneyDebt(nPlayerId, "Gold", math.abs(nGold) - nCost, Env.LogWay_Money_Debt_Add, 0, true)
			Log("IDIP_AQ_DO_UPDATE_DIAMOND_REQ OnAQCostGoldCallBack CostGold AddMoneyDebt ", nPlayerId,nGold,nCost,nIsNegative);
		end
		Log("IDIP_AQ_DO_UPDATE_DIAMOND_REQ OnAQCostGoldCallBack CostGold success ", nPlayerId,nGold,nCost,nIsNegative);
		return true
	end

	Transmit.tbIDIPInterface:IdipAQTryDelayCostGold(nPlayerId,nGold,nIsNegative,szSource,szSerial)
	Log("IDIP_AQ_DO_UPDATE_DIAMOND_REQ OnAQCostGoldCallBack CostGold fail add 2 delay cmd", nPlayerId,nGold,nCost,nIsNegative);
	return true
end

function tbIDIPInterface:IDIP_AQ_DO_UPDATE_DIAMOND_REQ(nCmdId, tbReq,nCmdSequence)
	Player:DoAccountRoleMatchRequest(tbReq.OpenId,tbReq.RoleId,Transmit.tbIDIPInterface.OnUpdateDiamondCheckFinish,Transmit.tbIDIPInterface,nCmdId,tbReq,nCmdSequence);
end

function tbIDIPInterface:OnUpdateDiamondCheckFinish(szAccount, dwPlayerId, nIsMatch,nCmdId, tbReq, nCmdSequence)
	local tbRsp =
	{
		Result = IDIP_SUCCESS,
		RetMsg = "ok",
	}
	if nIsMatch == 0 then
		tbRsp.Result = IDIP_PLAYER_NOT_EXIST;
		tbRsp.RetMsg = ErrInValidAccountRoleIdNotMatch;
		self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_AQ_DO_UPDATE_DIAMOND_REQ", nCmdSequence)
		return
	end

	local nGold = tonumber(tbReq.Value);
	local nIsNegative = tonumber(tbReq.IsNegative) or 0

	if not nGold or not Shop.tbMoney["Gold"] then
		tbRsp.Result = IDIP_INVALID_PARAM
		tbRsp.RetMsg = ErrInvalidParam
		self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_AQ_DO_UPDATE_DIAMOND_REQ", nCmdSequence)
		return
	end

	local pPlayer = KPlayer.GetPlayerObjById(tbReq.RoleId);

	if pPlayer then
		if nGold >= 0 then
			pPlayer.AddMoney("Gold",nGold,Env.LogWay_IdipDoUpdateDiamondReq);
		elseif nGold < 0 then
			self:IdipAQCostGold(tbReq.RoleId,nGold,nIsNegative,tbReq.Source, tbReq.Serial);
		end
	else
		local pPlayerInfo = KPlayer.GetRoleStayInfo(tbReq.RoleId);
		if pPlayerInfo then
			self:IdipAQTryDelayCostGold(tbReq.RoleId,nGold,nIsNegative,tbReq.Source, tbReq.Serial)
		else
			tbRsp.Result = IDIP_PLAYER_NOT_EXIST
			tbRsp.RetMsg = ErrPlayerNotExist
		end
	end

	TLog("IDIPFLOW", tbReq.AreaId, tbReq.OpenId, 0, tbReq.Value, tbReq.Serial, tbReq.Source, nCmdId, tbReq.PlatId,
		tbReq.Partition, tbReq.RoleId, 0, "IDIP_AQ_DO_UPDATE_DIAMOND_REQ", (pPlayer and "immediately") or "delay")

	self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_AQ_DO_UPDATE_DIAMOND_REQ", nCmdSequence)
end

function tbIDIPInterface:IDIP_AQ_QUERY_GUILD_NOTICE_REQ(nCmdId, tbReq, nCmdSequence)
	 local tbRsp =
	{
		Result = IDIP_SUCCESS,
		RetMsg = "ok",
	}

	local nRoleId = tonumber(tbReq.RoleId)
	if not nRoleId then
		tbRsp.Result = IDIP_INVALID_PARAM
		tbRsp.RetMsg = ErrInvalidParam
		self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_AQ_QUERY_GUILD_NOTICE_REQ", nCmdSequence)
		return
	end
	Player:DoAccountRoleMatchRequest(tbReq.OpenId,nRoleId,Transmit.tbIDIPInterface.OnQueryGuildNoticeCheckFinish,Transmit.tbIDIPInterface,nCmdId,tbReq,nCmdSequence);
end

function tbIDIPInterface:OnQueryGuildNoticeCheckFinish(szAccount, dwPlayerId, nIsMatch,nCmdId, tbReq, nCmdSequence)

    local tbRsp =
	{
		Result = IDIP_SUCCESS,
		RetMsg = "ok",
		RoleName = "",
		Level = 0,
		GuildId = 0,
		GuildStatus = 0,
		GuildNotice = "",
		GuildDeclare = "",
	}

	if nIsMatch == 0 then
		tbRsp.Result = IDIP_PLAYER_NOT_EXIST;
		tbRsp.RetMsg = ErrInValidAccountRoleIdNotMatch;
		self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_AQ_QUERY_GUILD_NOTICE_REQ", nCmdSequence)
		return
	end

	local nDwKinId = 0;
	dwPlayerId = tonumber(dwPlayerId);
	local pPlayer = KPlayer.GetPlayerObjById(dwPlayerId) or KPlayer.GetRoleStayInfo(dwPlayerId);
	if not pPlayer then
		tbRsp.Result = IDIP_PLAYER_NOT_EXIST;
		tbRsp.RetMsg = ErrPlayerNotExist;
		self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_AQ_QUERY_GUILD_NOTICE_REQ",nCmdSequence)
		return;
	end

	nDwKinId = pPlayer.dwKinId;
	local tbKinData = Kin:GetKinById(nDwKinId)
	if tbKinData then
		local tbMemberData = Kin:GetMemberData(dwPlayerId)
		tbRsp.RoleName = pPlayer.szName;
		tbRsp.Level = pPlayer.nLevel;
		if tbMemberData then
			tbRsp.GuildStatus = tbMemberData.nCareer;
		end
		tbRsp.GuildId = tbKinData.nKinId;
		tbRsp.GuildNotice = tbKinData.szPublicDeclare or "";
		tbRsp.GuildDeclare = tbKinData.tbRecruitSetting.szAddDeclare;
	end

	TLog("IDIPFLOW", tbReq.AreaId, tbReq.OpenId,0,0, tbReq.Serial, tbReq.Source, nCmdId, tbReq.PlatId,
        tbReq.Partition, tbReq.RoleId,0, "IDIP_AQ_QUERY_GUILD_NOTICE_REQ")

	self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_AQ_QUERY_GUILD_NOTICE_REQ",nCmdSequence)
end

function tbIDIPInterface:IDIP_AQ_DO_SET_GUILD_NOTICE_REQ(nCmdId, tbReq, nCmdSequence)
	Player:DoAccountRoleMatchRequest(tbReq.OpenId,tbReq.RoleId,Transmit.tbIDIPInterface.OnSetGuildNoticeCheckFinish,Transmit.tbIDIPInterface,nCmdId,tbReq,nCmdSequence);
end

function tbIDIPInterface:OnSetGuildNoticeCheckFinish(szAccount, dwPlayerId, nIsMatch,nCmdId, tbReq, nCmdSequence)

    local tbRsp =
	{
		Result = IDIP_SUCCESS,
		RetMsg = "ok",
	}

	if nIsMatch == 0 then
		tbRsp.Result = IDIP_PLAYER_NOT_EXIST;
		tbRsp.RetMsg = ErrInValidAccountRoleIdNotMatch;
		self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_AQ_DO_SET_GUILD_NOTICE_REQ", nCmdSequence)
		return
	end

	local nDwKinId = tonumber(tbReq.GuildId) or 0;
	dwPlayerId = tonumber(dwPlayerId);

	local pPlayer = KPlayer.GetPlayerObjById(dwPlayerId) or KPlayer.GetRoleStayInfo(dwPlayerId);
	if not pPlayer then
		tbRsp.Result = IDIP_PLAYER_NOT_EXIST;
		tbRsp.RetMsg = ErrPlayerNotExist;
		self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_AQ_DO_SET_GUILD_NOTICE_REQ",nCmdSequence)
		return;
	end

	if nDwKinId ~= pPlayer.dwKinId then
		tbRsp.Result = IDIP_KINID_ROLEID_NOT_MATCH;
		tbRsp.RetMsg = ErrRoleIdKinIdNotMatch;
		self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_AQ_DO_SET_GUILD_NOTICE_REQ", nCmdSequence)
		return
	end
	local nType = tbReq.Type;
	local szContent = tbReq.Content or "";

	local tbKinData = Kin:GetKinById(nDwKinId)
	if not tbKinData then
		tbRsp.Result = IDIP_KIN_NOT_FOUND;
		tbRsp.RetMsg = ErrKinNotFound;
		self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_AQ_DO_SET_GUILD_NOTICE_REQ",nCmdSequence)
		return
	end
	if nType == KinNoticeType.Notice then				-- 公告
		tbKinData.szPublicDeclare = szContent;
		tbKinData:SetCacheFlag("UpdateBaseInfo", true);
		tbKinData:Save()
	elseif nType == KinNoticeType.Declare then			-- 宣言
		tbKinData:ChangeAddDeclare(szContent);
	elseif nType == KinNoticeType.All then
		tbKinData.szPublicDeclare = szContent;
		tbKinData:SetCacheFlag("UpdateBaseInfo", true);
		tbKinData:ChangeAddDeclare(szContent);
		tbKinData:Save()
	else
		tbRsp.Result = IDIP_INVALID_PARAM;
		tbRsp.RetMsg = ErrInvalidParam;
		self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_AQ_DO_SET_GUILD_NOTICE_REQ",nCmdSequence)
		return
	end

	local bIsOnline = KPlayer.GetPlayerObjById(dwPlayerId)

	TLog("IDIPFLOW", tbReq.AreaId, tbReq.OpenId,0,0, tbReq.Serial, tbReq.Source, nCmdId, tbReq.PlatId,
        tbReq.Partition, tbReq.RoleId,0, "IDIP_AQ_DO_SET_GUILD_NOTICE_REQ", (bIsOnline and "immediately") or "delay", nDwKinId, nType,szContent)

	self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_AQ_DO_SET_GUILD_NOTICE_REQ",nCmdSequence)
end

function tbIDIPInterface:IDIP_AQ_QUERY_ROLELIST_REQ(nCmdId, tbReq,nCmdSequence)
	Player:DoAccountRoleListRequest(tbReq.OpenId, Transmit.tbIDIPInterface.OnQueryRoleList, Transmit.tbIDIPInterface, nCmdSequence,tbReq,nCmdId)
end

function tbIDIPInterface:OnQueryRoleList(szAccount,tbRoleList,nCmdSequence,tbReq,nCmdId)
	local tbRsp = {
	RoleList_count = 0,
	RoleList = {},
	};
	local tbPlayer = tbRoleList or {};
	if not next(tbPlayer) then
		self:IDIPDelayResponse(IDIP_PLAYER_NOT_EXIST,tbRsp,ErrInValidOpenId,"IDIP_AQ_QUERY_ROLELIST_REQ",nCmdSequence)
		return
	end
	for _,info in pairs(tbPlayer) do
		local tbInfo = {};
		tbInfo.RoleId = info.dwID;
		tbInfo.RoleName = info.szName;
		tbInfo.Status = 1;
		local nBanTime = info.nBanEndTime
		if nBanTime == 0 or (nBanTime > 0 and nBanTime < GetTime()) then
			tbInfo.Status = 0
		end
		tbRsp.RoleList_count = tbRsp.RoleList_count + 1;
		table.insert(tbRsp.RoleList,tbInfo);
	end

	TLog("IDIPFLOW", tbReq.AreaId, tbReq.OpenId,0,0, tbReq.Serial, tbReq.Source, nCmdId, tbReq.PlatId,
        tbReq.Partition,0,0, "IDIP_AQ_QUERY_ROLELIST_REQ")

	self:IDIPDelayResponse(IDIP_SUCCESS,tbRsp,"ok","IDIP_AQ_QUERY_ROLELIST_REQ",nCmdSequence)
end

function tbIDIPInterface:IDIP_AQ_DO_SEND_NOTICE_REQ(nCmdId, tbReq,nCmdSequence)
	 local tbRsp =
	{
		Result = IDIP_SUCCESS,
		RetMsg = "ok",
	}
	local nType = tonumber(tbReq.Type) or 100;
	local szMsg = tbReq.MsgContent or "";

	if nType == MsgType.System then
		ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.System, szMsg);     -- 系统
	elseif nType == MsgType.World then
		ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.System, szMsg);     -- 世界暂时到系统频道
	elseif nType == MsgType.ZouMaDeng then
		KPlayer.SendWorldNotify(1, 1000,szMsg,0, 1); 					-- 走马灯
	elseif nType == MsgType.All then
		KPlayer.SendWorldNotify(1, 1000,szMsg,ChatMgr.ChannelType.Public, 1); -- 走马灯同时有系统消息
	else
		tbRsp.Result = IDIP_INVALID_PARAM;
		tbRsp.RetMsg = ErrInvalidParam;
		self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_AQ_DO_SEND_NOTICE_REQ",nCmdSequence)
		return
	end

	TLog("IDIPFLOW", tbReq.AreaId,"",0,0, tbReq.Serial, tbReq.Source, nCmdId, tbReq.PlatId,
        tbReq.Partition,0,0, "IDIP_AQ_DO_SEND_NOTICE_REQ",tbReq.Type,tbReq.MsgContent)

	self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_AQ_DO_SEND_NOTICE_REQ",nCmdSequence)
end

function tbIDIPInterface:IDIP_AQ_DO_SEND_MSG_REQ(nCmdId, tbReq, nCmdSequence)
	Player:DoAccountRoleMatchRequest(tbReq.OpenId,tbReq.RoleId,Transmit.tbIDIPInterface.OnSendMsgCheckFinish,Transmit.tbIDIPInterface,nCmdId,tbReq,nCmdSequence);
end

function tbIDIPInterface:OnSendMsgCheckFinish(szAccount, dwPlayerId, nIsMatch,nCmdId, tbReq, nCmdSequence)
	local tbRsp =
	{
		Result = IDIP_SUCCESS,
		RetMsg = "ok",
	}
	if nIsMatch == 0 then
		tbRsp.Result = IDIP_PLAYER_NOT_EXIST;
		tbRsp.RetMsg = ErrInValidAccountRoleIdNotMatch;
		self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_AQ_DO_SEND_MSG_REQ", nCmdSequence)
		return
	end
	local szMsg = tbReq.MsgContent or "";
	local tbMail = {};
	tbMail.To = tbReq.RoleId;
	tbMail.Title = "系統";
	tbMail.Text = szMsg;
	tbMail.From = "系統";
	tbMail.nLogReazon = Env.LogWay_IdipAqDoSendMsgReq;
	tbMail.tbAttach = {};

	Mail:SendSystemMail(tbMail);

	local pPlayer = KPlayer.GetPlayerObjById(tbReq.RoleId);

	TLog("IDIPFLOW", tbReq.AreaId, tbReq.OpenId,0,0,tbReq.Serial, tbReq.Source, nCmdId, tbReq.PlatId,
		tbReq.Partition,0,0, "IDIP_AQ_DO_SEND_MSG_REQ", (pPlayer and "immediately") or "delay", szMsg)

	self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_AQ_DO_SEND_MSG_REQ", nCmdSequence)
end

function tbIDIPInterface:IDIP_AQ_CLEAR_SAY_REQ(nCmdId, tbReq, nCmdSequence)
	Player:DoAccountRoleMatchRequest(tbReq.OpenId,tbReq.RoleId,Transmit.tbIDIPInterface.OnClearSayCheckFinish,Transmit.tbIDIPInterface,nCmdId,tbReq,nCmdSequence);
end

function tbIDIPInterface:OnClearSayCheckFinish(szAccount, dwPlayerId, nIsMatch,nCmdId, tbReq, nCmdSequence)
	local tbRsp =
	{
		Result = IDIP_SUCCESS,
		RetMsg = "ok",
	}

	if nIsMatch == 0 then
		tbRsp.Result = IDIP_PLAYER_NOT_EXIST;
		tbRsp.RetMsg = ErrInValidAccountRoleIdNotMatch;
		self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_AQ_CLEAR_SAY_REQ", nCmdSequence)
		return
	end

	local pPlayer = KPlayer.GetRoleStayInfo(dwPlayerId);
	if not pPlayer then
		tbRsp.Result = IDIP_PLAYER_NOT_EXIST;
		tbRsp.RetMsg = ErrPlayerNotExist;
		self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_AQ_CLEAR_SAY_REQ", nCmdSequence)
		return
	end

	ChatMgr:ClearRoleChatMsgOnClient(dwPlayerId)

	local tbMemberData = Kin:GetMemberData(dwPlayerId)
	local nKinId = tbMemberData and tbMemberData.nKinId or 0
	local tbKinData = Kin:GetKinById(nKinId)
	if tbKinData then
		tbKinData:ClearCacheChatMsg(dwPlayerId)
	end

	local bIsOnline = KPlayer.GetPlayerObjById(dwPlayerId)

	TLog("IDIPFLOW", tbReq.AreaId, tbReq.OpenId,0,0, tbReq.Serial, tbReq.Source, nCmdId, tbReq.PlatId,
        tbReq.Partition, tbReq.RoleId,0, "IDIP_AQ_CLEAR_SAY_REQ", (bIsOnline and "immediately") or "delay")

	self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_AQ_CLEAR_SAY_REQ", nCmdSequence)
end

function tbIDIPInterface:IDIP_AQ_DO_RELIEVE_PUNISH_REQ(nCmdId, tbReq, nCmdSequence)
	Player:DoAccountRoleMatchRequest(tbReq.OpenId,tbReq.RoleId,Transmit.tbIDIPInterface.OnRelievePunishCheckFinish,Transmit.tbIDIPInterface,nCmdId,tbReq,nCmdSequence);
end

function tbIDIPInterface:OnRelievePunishCheckFinish(szAccount, dwPlayerId, nIsMatch,nCmdId, tbReq, nCmdSequence)
	local tbRsp =
	{
		Result = IDIP_SUCCESS,
		RetMsg = "ok",
	}

	if nIsMatch == 0 then
		tbRsp.Result = IDIP_PLAYER_NOT_EXIST;
		tbRsp.RetMsg = ErrInValidAccountRoleIdNotMatch;
		self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_AQ_DO_RELIEVE_PUNISH_REQ", nCmdSequence)
		return
	end

	local nRelieveZeroProfit  = tonumber(tbReq.RelieveZeroProfit) or 0
	local nRelievePlayAll 	  = tonumber(tbReq.RelievePlayAll) or 0
	local nRelieveBanJoinRank = tonumber(tbReq.RelieveBanJoinRank) or 0
	local nRelieveMaskchat 	  = tonumber(tbReq.RelieveMaskchat) or 0
	local nRelieveBanRole 	  = tonumber(tbReq.RelieveBanRole) or 0

	local pPlayerInfo = KPlayer.GetRoleStayInfo(dwPlayerId);
	if not pPlayerInfo then
		tbRsp.Result = IDIP_PLAYER_NOT_EXIST;
		tbRsp.RetMsg = ErrPlayerNotExist;
		self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_AQ_DO_RELIEVE_PUNISH_REQ", nCmdSequence)
		return
	end

	local szRelieveType = ""

	if nRelieveBanRole == 1 then								-- 解除封角色（0否，1是）
		BanPlayer(dwPlayerId,0,"");
	end
	if nRelieveMaskchat == 1 then								-- 解除禁言（0 否，1 是）
		local pAsyncData = KPlayer.GetAsyncData(dwPlayerId)
		if pAsyncData then
			szRelieveType = szRelieveType ..",禁言"
			pAsyncData.SetChatForbidType(ChatMgr.ForbidType.All);
			pAsyncData.SetChatForbidEndTime(GetTime());
			pAsyncData.SetChatForbidSilence(0);
		end
	end
	local pPlayer = KPlayer.GetPlayerObjById(dwPlayerId)
	local szCmd = ""

	if nRelieveBanJoinRank == 1 then							-- 解除禁止参与排行榜限制（0 否，1 是）
		if Forbid:IsBanning(_,Forbid.BanType.KinRank,pPlayerInfo.dwKinId) then
			szRelieveType = szRelieveType ..",幫派排行榜"
		end
		-- 家族与玩家在线与否无关
		Forbid:RelieveBan(_,Forbid.BanType.KinRank,pPlayerInfo.dwKinId);

		if pPlayer then
			-- 在线排行榜
			if Forbid:IsBanning(pPlayer,Forbid.BanType.WuLinMengZhu) then
				szRelieveType = szRelieveType ..",武林盟主排行榜"
			end
			Forbid:RelieveBan(pPlayer,Forbid.BanType.WuLinMengZhu);
			-- 离线普遍处理排行榜
			for _,tbBanCommonData in pairs(self.BanOfflineRankTypeCommon) do
				local nBanType = tbBanCommonData.nBanType
				if Forbid:IsBanning(pPlayer, nBanType) then
					szRelieveType = szRelieveType  .."," ..(tbBanCommonData.szRankTitle or "")
				end
				Forbid:RelieveBan(pPlayer,nBanType);
			end
		else
			szCmd = szCmd ..string.format([[
				Forbid:RelieveBan(me,Forbid.BanType.WuLinMengZhu);

				for _,tbBanCommonData in pairs(Transmit.tbIDIPInterface.BanOfflineRankTypeCommon) do
					Forbid:RelieveBan(me,tbBanCommonData.nBanType);
				end
			]])
		end
	end
	if nRelieveZeroProfit == 1 then								-- 解除零收益状态（0 否，1 是）
		if pPlayer then
			if Forbid:IsForbidAward(pPlayer) then
				szRelieveType = szRelieveType ..",零收益狀態"
			end
			Forbid:SetForbidAward(pPlayer, 0, "",true)
		else
			szCmd = szCmd .."Forbid:SetForbidAward(me, 0, '');"
		end
	end

	if nRelievePlayAll == 1 then								-- 解除所有玩法限制（0 否，1 是）	
		-- 待后面接入
	end
	if szCmd ~= "" then
		KPlayer.AddDelayCmd(dwPlayerId,
                szCmd,
                string.format("%s|%d|%d|%d|%d|%d|%s|%s", 'IDIP_AQ_DO_RELIEVE_PUNISH_REQ', nRelieveZeroProfit,nRelievePlayAll, nRelieveBanJoinRank,nRelieveMaskchat,nRelieveBanRole,tbReq.Source, tbReq.Serial))
	end

	if pPlayer and szRelieveType and szRelieveType ~="" then
		pPlayer.MsgBox(string.format("解除禁止狀態%s",szRelieveType), {{"確定"}, {"取消"}})
	end

	TLog("IDIPFLOW", tbReq.AreaId, tbReq.OpenId,0,0, tbReq.Serial, tbReq.Source, nCmdId, tbReq.PlatId,
        tbReq.Partition, tbReq.RoleId,0, "IDIP_AQ_DO_RELIEVE_PUNISH_REQ", (pPlayer and "immediately") or "delay", nRelieveZeroProfit, nRelievePlayAll,nRelieveBanJoinRank,nRelieveMaskchat,nRelieveBanRole)

	self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_AQ_DO_RELIEVE_PUNISH_REQ", nCmdSequence)
end

function tbIDIPInterface:IDIP_AQ_QUERY_BOSS_INFO_REQ(nCmdId, tbReq, nCmdSequence)
	local nRoleId = tonumber(tbReq.RoleId) or 0
	Player:DoAccountRoleMatchRequest(tbReq.OpenId,nRoleId,Transmit.tbIDIPInterface.OnQueryBossInfoCheckFinish,Transmit.tbIDIPInterface,nCmdId,tbReq,nCmdSequence);
end

function tbIDIPInterface:OnQueryBossInfoCheckFinish(szAccount, dwPlayerId, nIsMatch,nCmdId, tbReq, nCmdSequence)
	--[[
		玩家不在线或者玩家所在Boss地图没有Boss了或者不在Boss地图
		返回的是玩家当前最高伤害的Boss数据（伤害最高是指家族伤害最高的那只Boss）

		玩家在Boos地图并且存在Boss
		返回的是离玩家最近的Boss数据
	]]
	local tbRsp =
	{
		Result 				= IDIP_SUCCESS,
		RetMsg 				= "ok",
		RoleName 			= "",           -- 角色名
        Level 				= 0,            -- 等级
        BossFight   		= 0,            -- 当前Boss战角色总伤害	(如果有队伍则返回最高的队伍排名伤害)
        BossRanking 		= 0,          	-- 当前Boss战角色排名 (如果有队伍则返回最高的队伍排名)
        FamilyBossFight		= 0 ,      		-- 当前BOSS战家族（队伍<最高>）总伤害
        FamilyBossRanking 	= 0,      		-- 当前boss战家族（队伍<最高>）排名
	}

	if nIsMatch == 0 then
		tbRsp.Result = IDIP_PLAYER_NOT_EXIST;
		tbRsp.RetMsg = ErrInValidAccountRoleIdNotMatch;
		self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_AQ_QUERY_BOSS_INFO_REQ", nCmdSequence)
		return
	end

	local pPlayer = KPlayer.GetPlayerObjById(dwPlayerId) or KPlayer.GetRoleStayInfo(dwPlayerId);
	if not pPlayer then
		tbRsp.Result = IDIP_PLAYER_NOT_EXIST;
		tbRsp.RetMsg = ErrPlayerNotExist;
		self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_AQ_QUERY_BOSS_INFO_REQ", nCmdSequence)
		return
	end

	tbRsp.RoleName = pPlayer.szName;
	tbRsp.Level    = pPlayer.nLevel;

	local nType = tbReq.Type;
	if nType == BossType.BossLeader then							-- 历代名将 野外boss(szType (Boss))
		tbRsp.BossFight,tbRsp.BossRanking,tbRsp.FamilyBossFight,tbRsp.FamilyBossRanking = BossLeader:PlayerDmgInfo(dwPlayerId,"Boss")
	elseif nType == BossType.FieldBoss then							-- 野外boss(szType (Leader))
		tbRsp.BossFight,tbRsp.BossRanking,tbRsp.FamilyBossFight,tbRsp.FamilyBossRanking = BossLeader:PlayerDmgInfo(dwPlayerId,"Leader")
	elseif nType == BossType.Boss then								-- 武林盟主
		tbRsp.BossFight,tbRsp.BossRanking,tbRsp.FamilyBossFight,tbRsp.FamilyBossRanking = Boss:PlayerDmgInfo(dwPlayerId)
	elseif nType == BossType.WhiteTiger then						-- 白虎堂(玩家不在线的时候,一律返回0，因为无法确定哪个Boss)
		tbRsp.BossFight,tbRsp.BossRanking,tbRsp.FamilyBossFight,tbRsp.FamilyBossRanking = Fuben.WhiteTigerFuben:PlayerDmgInfo(dwPlayerId)
	else
		tbRsp.Result = IDIP_INVALID_PARAM;
		tbRsp.RetMsg = ErrInvalidParam;
		self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_AQ_QUERY_BOSS_INFO_REQ", nCmdSequence)
		return
	end

	TLog("IDIPFLOW", tbReq.AreaId, tbReq.OpenId,0,0, tbReq.Serial, tbReq.Source,nCmdId , tbReq.PlatId,
        tbReq.Partition, tbReq.RoleId,0, "IDIP_AQ_QUERY_BOSS_INFO_REQ",tbReq.Type)

	self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_AQ_QUERY_BOSS_INFO_REQ", nCmdSequence)
end

function tbIDIPInterface:IDIP_AQ_DO_BAN_JOINRANK_OFFLINE_REQ(nCmdId, tbReq, nCmdSequence)
	local nRoleId = tonumber(tbReq.RoleId) or 0
	Player:DoAccountRoleMatchRequest(tbReq.OpenId,nRoleId,Transmit.tbIDIPInterface.OnBanJoinRankOfflineCheckFinish,Transmit.tbIDIPInterface,nCmdId,tbReq,nCmdSequence);
end

function tbIDIPInterface:OnBanJoinRankOfflineCheckFinish(szAccount, dwPlayerId, nIsMatch,nCmdId, tbReq, nCmdSequence)
		local tbRsp =
	{
		Result 				= IDIP_SUCCESS,
		RetMsg 				= "ok",
	}

	if nIsMatch == 0 then
		tbRsp.Result = IDIP_PLAYER_NOT_EXIST;
		tbRsp.RetMsg = ErrInValidAccountRoleIdNotMatch;
		self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_AQ_DO_BAN_JOINRANK_OFFLINE_REQ", nCmdSequence)
		return
	end
	local nType = tonumber(tbReq.Type) or 0
	local nTime = tonumber(tbReq.Time) or 0
	local szTips = tbReq.Tip or "凍結中"
	local nIsZeroRank = tonumber(tbReq.IsZeroRank) or 0
	local nEndTime = GetTime() + nTime

	if nType == 0 or nTime == 0 then
		tbRsp.Result = IDIP_INVALID_PARAM;
		tbRsp.RetMsg = ErrInvalidParam;
		self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_AQ_DO_BAN_JOINRANK_OFFLINE_REQ", nCmdSequence)
		return
	end

	local pPlayerInfo = KPlayer.GetRoleStayInfo(dwPlayerId);
	if not pPlayerInfo then
		tbRsp.Result = IDIP_PLAYER_NOT_EXIST;
		tbRsp.RetMsg = ErrPlayerNotExist;
		self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_AQ_DO_BAN_JOINRANK_OFFLINE_REQ", nCmdSequence)
		return
	end

	local pPlayer = KPlayer.GetPlayerObjById(dwPlayerId)
	local szCmd
	local tbBanCommonData = self.BanOfflineRankTypeCommon[nType]
	if tbBanCommonData then
		local nBanCommonType = tbBanCommonData.nBanType
		if nIsZeroRank == Forbid.IsClear.CLEAR then
 			Forbid:ClearRankData(dwPlayerId,nBanCommonType)
 		end
		if pPlayer then
			Forbid:Ban(pPlayer,nBanCommonType,nEndTime,szTips)
		else
			szCmd = string.format("Forbid:Ban(me,%d,%d,'%s')",nBanCommonType,nEndTime,szTips);
		end
	elseif nType == BanOfflineRankType.AllRank then
		if nIsZeroRank == Forbid.IsClear.CLEAR then
			for _,tbBanCommonData in pairs(self.BanOfflineRankTypeCommon) do
				Forbid:ClearRankData(dwPlayerId,tbBanCommonData.nBanType)
			end
 		end

		if pPlayer then
			for _,tbBanCommonData in pairs(self.BanOfflineRankTypeCommon) do
				Forbid:Ban(pPlayer,tbBanCommonData.nBanType,nEndTime,szTips)
			end
		else
			szCmd = string.format([[
				local nEndTime = %d;
				local szTips = '%s';
				for _,tbBanCommonData in pairs(Transmit.tbIDIPInterface.BanOfflineRankTypeCommon) do
					local nBanCommonType = tbBanCommonData.nBanType
					Forbid:Ban(me,nBanCommonType,nEndTime,szTips);
					Log('[tbIDIPInterface] IDIP_AQ_DO_BAN_JOINRANK_OFFLINE_REQ ban AllRank delay ',nBanCommonType,nEndTime,szTips);
				end
				]],nEndTime,szTips);
		end
	else
		tbRsp.Result = IDIP_INVALID_PARAM;
		tbRsp.RetMsg = ErrInvalidParam;
		self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_AQ_DO_BAN_JOINRANK_OFFLINE_REQ", nCmdSequence)
		return
	end
	if szCmd then
		KPlayer.AddDelayCmd(dwPlayerId,
                szCmd,
                string.format("%s|%d|%d|%s|%s", 'IDIP_AQ_DO_BAN_JOINRANK_OFFLINE_REQ', nType,nTime, tbReq.Source, tbReq.Serial))
	end

	if pPlayer then
		pPlayer.MsgBox(string.format("您由於%s被禁止上榜，禁止時間%s",szTips, Lib:TimeDesc2(nTime) or ""), {{"確定"}, {"取消"}})
	end

	TLog("IDIPFLOW", tbReq.AreaId, tbReq.OpenId,0,0, tbReq.Serial, tbReq.Source, nCmdId, tbReq.PlatId,
        tbReq.Partition, tbReq.RoleId,0, "IDIP_AQ_DO_BAN_JOINRANK_OFFLINE_REQ", (pPlayer and "immediately") or "delay", nType, nTime,szTips,nIsZeroRank,nEndTime)

	self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_AQ_DO_BAN_JOINRANK_OFFLINE_REQ", nCmdSequence)
end

function tbIDIPInterface:IDIP_AQ_DO_BAN_JOINRANK_CURRENT_REQ(nCmdId, tbReq, nCmdSequence)
	local nRoleId = tonumber(tbReq.RoleId) or 0
	Player:DoAccountRoleMatchRequest(tbReq.OpenId,nRoleId,Transmit.tbIDIPInterface.OnBanJoinRankCurrentCheckFinish,Transmit.tbIDIPInterface,nCmdId,tbReq,nCmdSequence);
end

function tbIDIPInterface:OnBanJoinRankCurrentCheckFinish(szAccount, dwPlayerId, nIsMatch,nCmdId, tbReq, nCmdSequence)
	local tbRsp =
		{
			Result 				= IDIP_SUCCESS,
			RetMsg 				= "ok",
		}

	if nIsMatch == 0 then
		tbRsp.Result = IDIP_PLAYER_NOT_EXIST;
		tbRsp.RetMsg = ErrInValidAccountRoleIdNotMatch;
		self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_AQ_DO_BAN_JOINRANK_CURRENT_REQ", nCmdSequence)
		return
	end
	local nType = tonumber(tbReq.Type) or 0

	if nType == 0 then
	    tbRsp.Result = IDIP_INVALID_PARAM;
	    tbRsp.RetMsg = ErrInvalidParam;
	    self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_AQ_DO_BAN_JOINRANK_CURRENT_REQ", nCmdSequence)
	    return
	end

	local nTime = tonumber(tbReq.Time) or 0
	local szTips = tbReq.Tip or "凍結中"

	local nIsZeroRank = tonumber(tbReq.IsZeroRank) or 0
	local nEndTime = GetTime() + nTime

	local pPlayerInfo = KPlayer.GetRoleStayInfo(dwPlayerId);
	if not pPlayerInfo then
		tbRsp.Result = IDIP_PLAYER_NOT_EXIST;
		tbRsp.RetMsg = ErrPlayerNotExist;
		self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_AQ_DO_BAN_JOINRANK_CURRENT_REQ", nCmdSequence)
		return
	end

	local pPlayer = KPlayer.GetPlayerObjById(dwPlayerId)

	local szCmd
	if nType == BanCurrentRankType.WuLinMengZhu then
		if nIsZeroRank == Forbid.IsClear.CLEAR then
 			Forbid:ClearRankData(dwPlayerId,Forbid.BanType.WuLinMengZhu)
 		end

		if pPlayer then
			Forbid:Ban(pPlayer,Forbid.BanType.WuLinMengZhu,nEndTime,szTips)
		else
			szCmd = string.format("Forbid:Ban(me,Forbid.BanType.WuLinMengZhu,%d,'%s')",nEndTime,szTips);
		end

	elseif nType == BanCurrentRankType.AllRank then
		if nIsZeroRank == Forbid.IsClear.CLEAR then
 			Forbid:ClearRankData(dwPlayerId,Forbid.BanType.WuLinMengZhu)
 			-- 待扩充
 		end
		if pPlayer then
			Forbid:Ban(pPlayer,Forbid.BanType.WuLinMengZhu,nEndTime,szTips)
			-- 待扩充
		else
			szCmd = string.format([[
				local nEndTime = %d;
				local szTips = '%s';
				Forbid:Ban(me,Forbid.BanType.WuLinMengZhu,nEndTime,szTips);
				]],nEndTime,szTips);
		end
	else
		tbRsp.Result = IDIP_INVALID_PARAM;
		tbRsp.RetMsg = ErrInvalidParam;
		self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_AQ_DO_BAN_JOINRANK_CURRENT_REQ", nCmdSequence)
		return
	end
	if szCmd then
		KPlayer.AddDelayCmd(dwPlayerId,
                szCmd,
                string.format("%s|%d|%d|%s|%s", 'IDIP_AQ_DO_BAN_JOINRANK_CURRENT_REQ', nType,nTime, tbReq.Source, tbReq.Serial))
	end

	if pPlayer then
        pPlayer.MsgBox(string.format("您由於%s被禁止上榜，禁止時間%s",szTips, Lib:TimeDesc2(nTime) or ""), {{"確定"}, {"取消"}})
    end

    TLog("IDIPFLOW", tbReq.AreaId, tbReq.OpenId,0,0, tbReq.Serial, tbReq.Source, nCmdId, tbReq.PlatId,
        tbReq.Partition, tbReq.RoleId,0, "IDIP_AQ_DO_BAN_JOINRANK_CURRENT_REQ", (pPlayer and "immediately") or "delay", nType, nTime,szTips,nIsZeroRank,nEndTime)

	self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_AQ_DO_BAN_JOINRANK_CURRENT_REQ", nCmdSequence)
end

function tbIDIPInterface:IDIP_AQ_DO_ZEROPROFIT_REQ(nCmdId, tbReq, nCmdSequence)
	Player:DoAccountRoleMatchRequest(tbReq.OpenId,tbReq.RoleId,Transmit.tbIDIPInterface.OnZeroProfitCheckFinish,Transmit.tbIDIPInterface,nCmdId,tbReq,nCmdSequence);
end

function tbIDIPInterface:OnZeroProfitCheckFinish(szAccount, dwPlayerId, nIsMatch,nCmdId, tbReq, nCmdSequence)
	local tbRsp =
		{
			Result 				= IDIP_SUCCESS,
			RetMsg 				= "ok",
		}

	if nIsMatch == 0 then
		tbRsp.Result = IDIP_PLAYER_NOT_EXIST;
		tbRsp.RetMsg = ErrInValidAccountRoleIdNotMatch;
		self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_AQ_DO_ZEROPROFIT_REQ", nCmdSequence)
		return
	end

	local pPlayerInfo = KPlayer.GetRoleStayInfo(dwPlayerId);
	if not pPlayerInfo then
		tbRsp.Result = IDIP_PLAYER_NOT_EXIST;
		tbRsp.RetMsg = ErrPlayerNotExist;
		self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_AQ_DO_ZEROPROFIT_REQ", nCmdSequence)
		return
	end

	local nTime = tonumber(tbReq.Time) or 0
	local szReason = tbReq.Reason or ""

	local nEndTime = GetTime() + nTime
	local pPlayer = KPlayer.GetPlayerObjById(dwPlayerId)
	local szCmd
	if pPlayer then
		Forbid:SetForbidAward(pPlayer, nEndTime, szReason)
	else
		szCmd = string.format("Forbid:SetForbidAward(me, %d,'%s');",nEndTime,szReason);
	end
	if szCmd then
		KPlayer.AddDelayCmd(dwPlayerId,
                szCmd,
                string.format("%s|%d|%s|%s", 'IDIP_AQ_DO_ZEROPROFIT_REQ' ,nTime, tbReq.Source, tbReq.Serial))
	end

	TLog("IDIPFLOW", tbReq.AreaId, tbReq.OpenId,0,0, tbReq.Serial, tbReq.Source, nCmdId, tbReq.PlatId,
        tbReq.Partition, tbReq.RoleId,0, "IDIP_AQ_DO_ZEROPROFIT_REQ", (pPlayer and "immediately") or "delay", nTime, szReason,nEndTime)

	self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_AQ_DO_ZEROPROFIT_REQ", nCmdSequence)
end


function tbIDIPInterface:IDIP_DO_UP_STALL_REQ(nCmdId, tbReq, nCmdSequence)
	local tbRsp =
		{
			Result 				= IDIP_SUCCESS,
			RetMsg 				= "ok",
		}

	local nItemId = tonumber(tbReq.ItemId)
	local nItemNum = tonumber(tbReq.ItemNum)
	local nPercentage = tonumber(tbReq.Percentage) or -1
	local nProbability = tonumber(tbReq.Probability)
	local nBatchId = tonumber(tbReq.BatchId)

	if not nItemId or not nItemNum or not nBatchId or not nProbability or nProbability < 0 or nProbability > MarketStall.MAX_RANDOM_RATE then
		tbRsp.Result = IDIP_INVALID_PARAM;
		tbRsp.RetMsg = ErrInvalidParam;
		self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_DO_UP_STALL_REQ", nCmdSequence)
		return
	end

	local nNorPrice, tbAllow = MarketStall:GetPriceInfo("item", nItemId);
	if not nNorPrice then
		tbRsp.Result = IDIP_INVALID_PARAM;
		tbRsp.RetMsg = ErrInvalidParam;
		self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_DO_UP_STALL_REQ", nCmdSequence)
		return
	end
	-- nPercentage 为-1代表以最大价上架 (nPercentage浮动最大200，最小50)
	local nPrice = nPercentage == -1 and -1 or (nNorPrice*(nPercentage / 100))

	local nStallId = MarketStall:AddExtStallInfo("item", nItemId, nItemNum, nPrice, nProbability)

	if not nStallId then
		tbRsp.Result = IDIP_INVALID_PARAM;
		tbRsp.RetMsg = ErrInvalidParam;
		self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_DO_UP_STALL_REQ", nCmdSequence)
		return
	end

	if self.tbStallItem[nBatchId] then
		local bRet = MarketStall:RemoveExtStallInfo(self.tbStallItem[nBatchId].nStallId)
		Log("[IDIP_DO_UP_STALL_REQ] remove exist stall item",self.tbStallItem[nBatchId].nStallId,self.tbStallItem[nBatchId].nItemId,nBatchId,bRet)
	end

	self.tbStallItem[nBatchId] = {["nStallId"] = nStallId,["nItemId"] = nItemId}

	TLog("IDIPFLOW", tbReq.AreaId, tbReq.OpenId,tbReq.ItemId,tbReq.ItemNum, tbReq.Serial, tbReq.Source, nCmdId, tbReq.PlatId,
    tbReq.Partition, 0,0, "IDIP_DO_UP_STALL_REQ", "immediately", nPercentage, nProbability,nBatchId,nStallId)

	self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_DO_UP_STALL_REQ", nCmdSequence)
end

function tbIDIPInterface:IDIP_QUERY_STALL_REQ(nCmdId, tbReq, nCmdSequence)
	local tbRsp =
		{
			Result 				= IDIP_SUCCESS,
			RetMsg 				= "ok",
			ItemId 				= 0,
			ItemNum             = 0,
		}

	local nBatchId = tonumber(tbReq.BatchId)
	if not nBatchId then
		tbRsp.Result = IDIP_INVALID_PARAM;
		tbRsp.RetMsg = ErrInvalidParam;
		self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_QUERY_STALL_REQ", nCmdSequence)
		return
	end

	local tbInfo = self.tbStallItem[nBatchId]
	if not tbInfo or not tbInfo.nStallId then
		tbRsp.Result = IDIP_VALID_BATCH_ID;
		tbRsp.RetMsg = ErrValidBatchId;
		self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_QUERY_STALL_REQ", nCmdSequence)
		return
	end

	tbRsp.ItemId = tbInfo.nItemId

	local tbStallInfo = MarketStall:GetStallInfoByStallId(tbInfo.nStallId) 		--
	if not tbStallInfo then
		tbRsp.ItemNum = 0
		self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_QUERY_STALL_REQ", nCmdSequence)
		return
	end
	tbRsp.ItemNum = tbStallInfo.nCount or 0

	TLog("IDIPFLOW", tbReq.AreaId, tbReq.OpenId,0,0, tbReq.Serial, tbReq.Source, nCmdId, tbReq.PlatId,
    tbReq.Partition, 0,0, "IDIP_QUERY_STALL_REQ", "immediately", tbReq.BatchId, tbRsp.ItemId,tbRsp.ItemNum)

	self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_QUERY_STALL_REQ", nCmdSequence)
end

function tbIDIPInterface:IDIP_DO_DEL_STALL_REQ(nCmdId, tbReq, nCmdSequence)
	local tbRsp =
		{
			Result 				= IDIP_SUCCESS,
			RetMsg 				= "ok",
		}

	local nItemId = tonumber(tbReq.ItemId)
	local nBatchId = tonumber(tbReq.BatchId)

	if not nItemId or not nBatchId then
		tbRsp.Result = IDIP_INVALID_PARAM;
		tbRsp.RetMsg = ErrInvalidParam;
		self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_DO_DEL_STALL_REQ", nCmdSequence)
		return
	end

	local tbInfo = self.tbStallItem[nBatchId]
	local nLogItemId = tbInfo and tbInfo.nItemId or 0
	local nLogStallId = tbInfo and tbInfo.nStallId or 0

	if not tbInfo or not tbInfo.nStallId or not tbInfo.nItemId or nItemId ~= tbInfo.nItemId then
		tbRsp.Result = IDIP_VALID_BATCH_ID;
		tbRsp.RetMsg = ErrValidBatchId;
		self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_DO_DEL_STALL_REQ", nCmdSequence)
		Log("[IDIP_DO_DEL_STALL_REQ] ",tbReq.ItemId,tbReq.BatchId,nLogItemId,nLogStallId)
		return
	end

	local nItemId = tbInfo.nItemId
	local nStallId = tbInfo.nStallId

	local bRet = MarketStall:RemoveExtStallInfo(nStallId)
	if not bRet then
		tbRsp.Result = IDIP_INVALID_PARAM;
		tbRsp.RetMsg = ErrInvalidParam;
		self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_DO_DEL_STALL_REQ", nCmdSequence)
		Log("IDIP_DO_DEL_STALL_REQ",tbReq.ItemId,tbReq.BatchId,nItemId,nStallId)
		return
	end

	self.tbStallItem[nBatchId] = nil

	TLog("IDIPFLOW", tbReq.AreaId, tbReq.OpenId,0,0, tbReq.Serial, tbReq.Source, nCmdId, tbReq.PlatId,
    tbReq.Partition, 0,0, "IDIP_DO_DEL_STALL_REQ", "immediately", tbReq.BatchId, tbReq.ItemId)

	self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_DO_DEL_STALL_REQ", nCmdSequence)
end

function tbIDIPInterface:GetNewMsgPrefix(nMsgId)
	return "IDIP_IF_" ..nMsgId
end

function tbIDIPInterface:IDIP_DO_SEND_MSG_REQ(nCmdId, tbReq, nCmdSequence)
	local tbRsp =
		{
			Result 	= IDIP_SUCCESS,
			RetMsg 	= "ok",
		}

	local nMsgId = tonumber(tbReq.MsgId)
	local szEndTime = tbReq.EndTime
	local szMsgContents = tbReq.MsgContents
	local szMsgTitle = tbReq.MsgTitle

	if not nMsgId or szEndTime == "" or szMsgContents == "" or szMsgTitle == "" then
		tbRsp.Result = IDIP_INVALID_PARAM;
		tbRsp.RetMsg = ErrInvalidParam;
		self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_DO_SEND_MSG_REQ", nCmdSequence)
		return
	end

	local nEndTime = tonumber(szEndTime)
	if not nEndTime then
		tbRsp.Result = IDIP_INVALID_PARAM;
		tbRsp.RetMsg = ErrInvalidParam;
		self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_DO_SEND_MSG_REQ", nCmdSequence)
		Log("[IDIP_DO_SEND_MSG_REQ] ParseDateTime fail ",tbReq.MsgId,tbReq.EndTime,tbReq.MsgContents,tbReq.MsgTitle,szEndTime)
		return
	end

	local szKey = self:GetNewMsgPrefix(nMsgId)
	local tbInfoData = NewInformation:GetInformation(szKey)
	if tbInfoData then
		tbRsp.Result = IDIP_EXIST_NEW_MSG_ID;
		tbRsp.RetMsg = ErrExistNewMsgId;
		self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_DO_SEND_MSG_REQ", nCmdSequence)
		return
	end
	local tbActData = {string.format(szMsgContents)}
	local bRet = NewInformation:AddInfomation(szKey, nEndTime, tbActData, {szTitle = szMsgTitle});

	if not bRet then
		tbRsp.Result = IDIP_NEW_MSG_ADD_FAIL;
		tbRsp.RetMsg = ErrNewMsgAddFail;
		self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_DO_SEND_MSG_REQ", nCmdSequence)
		Log("[IDIP_DO_SEND_MSG_REQ] AddInfomation fail ",tbReq.MsgId,tbReq.EndTime,tbReq.MsgContents,tbReq.MsgTitle,szEndTime,szKey)
		return
	end

	TLog("IDIPFLOW", tbReq.AreaId, tbReq.OpenId,0,0, tbReq.Serial, tbReq.Source, nCmdId, tbReq.PlatId,
    tbReq.Partition, 0,0, "IDIP_DO_SEND_MSG_REQ", "immediately",tbReq.MsgId,tbReq.EndTime,tbReq.MsgContents,tbReq.MsgTitle,nEndTime)

	self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_DO_SEND_MSG_REQ", nCmdSequence)
end

function tbIDIPInterface:IDIP_QUERY_MSG_REQ(nCmdId, tbReq, nCmdSequence)
	local tbRsp =
		{
			Result 	= IDIP_SUCCESS,
			RetMsg 	= "ok",
			MsgContents = "",
			MsgTitle = "",
		}

	local nMsgId = tonumber(tbReq.MsgId)
	if not nMsgId then
		tbRsp.Result = IDIP_INVALID_PARAM;
		tbRsp.RetMsg = ErrInvalidParam;
		self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_QUERY_MSG_REQ", nCmdSequence)
		return
	end

	local szKey = self:GetNewMsgPrefix(nMsgId)
	local tbInfoData = NewInformation:GetInformation(szKey)

	if not tbInfoData then
		tbRsp.Result = IDIP_NO_EXIST_MSG_ID;
		tbRsp.RetMsg = ErrNoExistMsgId;
		self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_QUERY_MSG_REQ", nCmdSequence)
		return
	end
	tbRsp.MsgContents = tbInfoData.tbData and tbInfoData.tbData[1] or ""
	tbRsp.MsgTitle = tbInfoData.tbSetting and tbInfoData.tbSetting.szTitle or ""

	if not tbRsp.MsgContents or not tbRsp.MsgTitle then
		tbRsp.Result = IDIP_NEW_MSG_INFO_NO_FIND;
		tbRsp.RetMsg = ErrNewMsgInfoNoFind;
		self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_QUERY_MSG_REQ", nCmdSequence)
		Log("[IDIP_QUERY_MSG_REQ] can no find msg",tbReq.MsgId,tbRsp.MsgContents,tbRsp.MsgTitle)
		return
	end

	TLog("IDIPFLOW", tbReq.AreaId, tbReq.OpenId,0,0, tbReq.Serial, tbReq.Source, nCmdId, tbReq.PlatId,
    tbReq.Partition, 0,0, "IDIP_QUERY_MSG_REQ", "immediately",tbReq.MsgId,tbRsp.MsgContents,tbRsp.MsgTitle)

	self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_QUERY_MSG_REQ", nCmdSequence)
end

function tbIDIPInterface:IDIP_DO_DEL_MSG_REQ(nCmdId, tbReq, nCmdSequence)
	local tbRsp =
		{
			Result 	= IDIP_SUCCESS,
			RetMsg 	= "ok",
		}

	local nMsgId = tonumber(tbReq.MsgId)
	if not nMsgId then
		tbRsp.Result = IDIP_INVALID_PARAM;
		tbRsp.RetMsg = ErrInvalidParam;
		self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_DO_DEL_MSG_REQ", nCmdSequence)
		return
	end

	local szKey = self:GetNewMsgPrefix(nMsgId)

	local tbInfoData = NewInformation:GetInformation(szKey)
	if not tbInfoData then
		tbRsp.Result = IDIP_NO_EXIST_MSG_ID;
		tbRsp.RetMsg = ErrNoExistMsgId;
		self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_DO_DEL_MSG_REQ", nCmdSequence)
		return
	end


	local szTitle = tbInfoData.tbSetting and tbInfoData.tbSetting.szTitle or ""
	local szContent = tbInfoData.tbData and tbInfoData.tbData[1] or ""
	local nEndTime = tbInfoData.nValidTime


	local bRet = NewInformation:RemoveInfomation(szKey)

	if not bRet then
		tbRsp.Result = IDIP_NEW_MSG_REMOVE_FAIL;
		tbRsp.RetMsg = ErrNewMsgRemoveFail;
		self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_DO_DEL_MSG_REQ", nCmdSequence)
		Log("[IDIP_DO_DEL_MSG_REQ] remove fail ",tbReq.MsgId,szTitle,szContent,nEndTime)
		return
	end

	TLog("IDIPFLOW", tbReq.AreaId, tbReq.OpenId,0,0, tbReq.Serial, tbReq.Source, nCmdId, tbReq.PlatId,
    tbReq.Partition, 0,0, "IDIP_DO_DEL_MSG_REQ", "immediately",tbReq.MsgId,szTitle,szContent,szEndTime)

	self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_DO_DEL_MSG_REQ", nCmdSequence)
end

function tbIDIPInterface:GetAuctionType(nType)
	if not nType then
		return
	end
	return self.AuctionType[nType]
end

function tbIDIPInterface:IDIP_DO_AUCTION_UP_ITEM_REQ(nCmdId, tbReq, nCmdSequence)
	local tbRsp =
		{
			Result 	= IDIP_SUCCESS,
			RetMsg 	= "ok",
		}

	local nItemId = tonumber(tbReq.ItemId)
	local nItemNum = tonumber(tbReq.ItemNum)
	local nType = tonumber(tbReq.Type)
	local nAuctionId = tonumber(tbReq.AuctionId)
	local szAuctionType = self:GetAuctionType(nType)

	if not nItemId or not nItemNum or not nType or not nAuctionId or not szAuctionType then
		tbRsp.Result = IDIP_INVALID_PARAM;
		tbRsp.RetMsg = ErrInvalidParam;
		self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_DO_AUCTION_UP_ITEM_REQ", nCmdSequence)
		return
	end

	if self.tbAuction.tbAuctionItem[nAuctionId] then
		tbRsp.Result = IDIP_EXIST_AUCTION_ID;
		tbRsp.RetMsg = ErrExistAuctionId;
		self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_DO_AUCTION_UP_ITEM_REQ", nCmdSequence)
		return
	end
	-- 有返回串不是列表形式，所有每次写死只上架一个，这是对好的
	local nId = Kin.Auction:Add2GlobalAuction(szAuctionType, nItemId, 1)
	if not nId then
		tbRsp.Result = IDIP_AUCTION_ADD_FAIL;
		tbRsp.RetMsg = ErrAuctionAddFail;
		self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_DO_AUCTION_UP_ITEM_REQ", nCmdSequence)
		Log("[IDIP_DO_AUCTION_UP_ITEM_REQ] Add2GlobalAuction fail",tbReq.Type,tbReq.AuctionId,tbReq.AuctionId)
		return
	end

	self.tbAuction.tbAuctionItem[nAuctionId] = {nUpId = nId,nItemId = nItemId}
	self.tbAuction.tbUpItem[nId] = {nAuctionId = nAuctionId}

	ScriptData:AddModifyFlag(Transmit.SaveName.IDIPInterfaceAuction)

	TLog("IDIPFLOW", tbReq.AreaId, tbReq.OpenId,tbReq.ItemId,tbReq.ItemNum, tbReq.Serial, tbReq.Source, nCmdId, tbReq.PlatId,
    tbReq.Partition, 0,0, "IDIP_DO_AUCTION_UP_ITEM_REQ", "immediately",tbReq.Type,tbReq.AuctionId,tbReq.AuctionId,nId)

	self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_DO_AUCTION_UP_ITEM_REQ", nCmdSequence)
end

function tbIDIPInterface:IDIP_QUERY_AUCTION_ITEM_REQ(nCmdId, tbReq, nCmdSequence)
	local tbRsp =
		{
			Result 	= IDIP_SUCCESS,
			RetMsg 	= "ok",
			ItemId = 0,
			ItemNum = 0,
			Status = 0, 		-- 0、流拍或被买走 1、正在等待上架；2、正在拍卖的道具
		}

	local nAuctionId = tonumber(tbReq.AuctionId)
	if not nAuctionId then
		tbRsp.Result = IDIP_INVALID_PARAM;
		tbRsp.RetMsg = ErrInvalidParam;
		self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_QUERY_AUCTION_ITEM_REQ", nCmdSequence)
		return
	end

	local tbAuctionInfo = self.tbAuction.tbAuctionItem[nAuctionId]
	if not tbAuctionInfo then
		tbRsp.Result = IDIP_NO_EXIST_AUCTION_ID;
		tbRsp.RetMsg = ErrNoExistAuctionId;
		self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_QUERY_AUCTION_ITEM_REQ", nCmdSequence)
		return
	end

	local nUpId = tbAuctionInfo.nUpId
	local nItemId = tbAuctionInfo.nItemId

	if not nUpId or not nItemId then
		tbRsp.Result = IDIP_NO_EXIST_AUCTION_INFO;
		tbRsp.RetMsg = ErrNoExistAuctionInfo;
		self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_QUERY_AUCTION_ITEM_REQ", nCmdSequence)
		Log("[IDIP_QUERY_AUCTION_ITEM_REQ] find auction info",tbReq.AuctionId,nUpId,nItemId)
		return
	end

	tbRsp.ItemId = nItemId

	local nState = Kin.Auction:QueryGlobalAuctionItemById(nUpId)
	if not nState then -- 流拍或被买走
		tbRsp.ItemNum = 0
		tbRsp.Status = 0
	else
		tbRsp.ItemNum = 1
		tbRsp.Status = nState
	end

	TLog("IDIPFLOW", tbReq.AreaId, tbReq.OpenId,0,0, tbReq.Serial, tbReq.Source, nCmdId, tbReq.PlatId,
    tbReq.Partition, 0,0, "IDIP_QUERY_AUCTION_ITEM_REQ", "immediately",tbReq.AuctionId,tbRsp.ItemId,tbRsp.ItemNum,tbRsp.Status)

	self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_QUERY_AUCTION_ITEM_REQ", nCmdSequence)
end

function tbIDIPInterface:OnGlobalAuctionRemove(nUpId)
	if self.tbAuction.tbAuctionItem and self.tbAuction.tbUpItem then
		if self.tbAuction.tbUpItem[nUpId] then
			local nAuctionId = self.tbAuction.tbUpItem[nUpId].nAuctionId
			if nAuctionId then
				if self.tbAuction.tbAuctionItem[nAuctionId] then
					Log("[tbIDIPInterface] OnGlobalAuctionRemove remove auction",nAuctionId,nUpId,self.tbAuction.tbAuctionItem[nAuctionId].nItemId)
					self.tbAuction.tbAuctionItem[nAuctionId] = nil
				else
					Log("[tbIDIPInterface] OnGlobalAuctionRemove no Auction info",nUpId,nAuctionId)
				end
			else
				Log("[tbIDIPInterface] OnGlobalAuctionRemove no nAuctionId",nUpId)
			end
			Log("[tbIDIPInterface] OnGlobalAuctionRemove remove UpId",nUpId)
			self.tbAuction.tbUpItem[nUpId] = nil
			ScriptData:AddModifyFlag(Transmit.SaveName.IDIPInterfaceAuction)
		end
	end
end

function tbIDIPInterface:IDIP_DO_ADD_SENSITIVE_WORD_REQ(nCmdId, tbReq, nCmdSequence)
	local tbRsp =
		{
			Result 	= IDIP_SUCCESS,
			RetMsg 	= "ok",
		}
	local tbForbidWord = {}
	local szForbidWord = tostring(tbReq.SensitiveWord)

	if szForbidWord and szForbidWord ~= "" then
		tbForbidWord = Lib:SplitStr(szForbidWord, "|")
	end

	ChatMgr:SetFilterText(tbForbidWord)

	TLog("IDIPFLOW", tbReq.AreaId, tbReq.OpenId,0,0, tbReq.Serial, tbReq.Source, nCmdId, tbReq.PlatId,
    tbReq.Partition, 0,0, "IDIP_DO_ADD_SENSITIVE_WORD_REQ","immediately",szForbidWord,szDivide,next(tbForbidWord) and 1 or 0)

	self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_DO_ADD_SENSITIVE_WORD_REQ", nCmdSequence)
end

function tbIDIPInterface:IDIP_DO_SET_BUY_STATUS_REQ(nCmdId, tbReq, nCmdSequence)
	Player:DoAccountRoleMatchRequest(tbReq.OpenId,tbReq.RoleId,Transmit.tbIDIPInterface.OnSetBuyStateCheckFinish,Transmit.tbIDIPInterface,nCmdId,tbReq,nCmdSequence);
end

function tbIDIPInterface:OnSetBuyStateCheckFinish(szAccount, dwPlayerId, nIsMatch,nCmdId, tbReq, nCmdSequence)
	local tbRsp =
		{
			Result 	= IDIP_SUCCESS,
			RetMsg 	= "ok",
		}

	if nIsMatch == 0 then
		tbRsp.Result = IDIP_PLAYER_NOT_EXIST;
		tbRsp.RetMsg = ErrInValidAccountRoleIdNotMatch;
		self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_DO_SET_BUY_STATUS_REQ", nCmdSequence)
		return
	end

	local nType = tonumber(tbReq.Value)
	if not nType then
		tbRsp.Result = IDIP_INVALID_PARAM;
		tbRsp.RetMsg = ErrInvalidParam;
		self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_DO_SET_BUY_STATUS_REQ", nCmdSequence)
		return
	end

	local pPlayer = KPlayer.GetRoleStayInfo(dwPlayerId);
	if not pPlayer then
		tbRsp.Result = IDIP_PLAYER_NOT_EXIST;
		tbRsp.RetMsg = ErrPlayerNotExist;
		self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_DO_SET_BUY_STATUS_REQ", nCmdSequence)
		return
	end

	local tbData = tbRechargeData[nType]
	if not tbData then
		tbRsp.Result = IDIP_INVALID_TYPE;
		tbRsp.RetMsg = ErrInValidType;
		self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_DO_SET_BUY_STATUS_REQ", nCmdSequence)
		return
	end

	local tbParam = tbData.tbParam or {-1}
	local szCall = tbData.szCall

	local szCmd
	pPlayer = KPlayer.GetPlayerObjById(dwPlayerId)

	if pPlayer then
		Transmit.tbIDIPInterface[szCall](self,dwPlayerId,unpack(tbParam))
	else
		szCmd = string.format("Transmit.tbIDIPInterface:%s(%d,%d)",szCall,dwPlayerId,unpack(tbParam))
	end

	if szCmd then
		KPlayer.AddDelayCmd(dwPlayerId,
                szCmd,
                string.format("%s|%d|%s|%s", 'IDIP_DO_SET_BUY_STATUS_REQ' ,nType, tbReq.Source, tbReq.Serial))
	end

	TLog("IDIPFLOW", tbReq.AreaId, tbReq.OpenId,0,0, tbReq.Serial, tbReq.Source, nCmdId, tbReq.PlatId,
    tbReq.Partition, dwPlayerId,0, "IDIP_DO_SET_BUY_STATUS_REQ",pPlayer and "immediately" or "delay",nType)

	self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_DO_SET_BUY_STATUS_REQ", nCmdSequence)
end

-- 一本万利(不触发红包)
function tbIDIPInterface:SetYiBenWanLi(dwID, nGroupIndex, nEventId)
	local pPlayer = KPlayer.GetPlayerObjById(dwID)
	if not pPlayer then
		Log("[tbIDIPInterface] SetYiBenWanLi not player", dwID, nGroupIndex)
		return
	end
	local bRet = Recharge:CanBuyGrowInvest(pPlayer, nGroupIndex)
	if not bRet then
		Log("[tbIDIPInterface] SetYiBenWanLi player can not buy", dwID, nGroupIndex, pPlayer.szName, pPlayer.nLevel)
		return
	end
	local nBuyedKey = Recharge.tbKeyGrowBuyed[nGroupIndex]
	if pPlayer.GetUserValue(Recharge.SAVE_GROUP, nBuyedKey) == 0 then
		pPlayer.SetUserValue(Recharge.SAVE_GROUP, nBuyedKey, 1);
		Recharge:TakeGrowInvestAward(pPlayer, 1, nGroupIndex)
		TeacherStudent:TargetAddCount(pPlayer, "BuyInvestGift", 1)
		-- 将对应的红包设置为已发送
		if nEventId then
			Kin:_SetRedBagSendTime(pPlayer, nEventId)
			Log("[tbIDIPInterface] SetYiBenWanLi _SetRedBagSendTime ok", dwID, pPlayer.szName, nGroupIndex, nEventId, pPlayer.nLevel)
		else
			Log("[tbIDIPInterface] SetYiBenWanLi _SetRedBagSendTime no nEventId", dwID, pPlayer.szName, nGroupIndex, pPlayer.nLevel)
		end
		Log("[tbIDIPInterface] SetYiBenWanLi ok",dwID,pPlayer.szName,nGroupIndex, pPlayer.nLevel)
	else
		Log("[tbIDIPInterface] SetYiBenWanLi repeat", dwID, pPlayer.szName, nGroupIndex, pPlayer.nLevel)
	end
end

-- 买金币
function tbIDIPInterface:SetBuyGold(dwID,nIndex)
	local pPlayer = KPlayer.GetPlayerObjById(dwID)
	if not pPlayer then
		Log("[tbIDIPInterface] SetBuyGold not player",dwID,nIndex)
		return
	end
	local nNow = GetTime()
	local nBuyedFlag = Recharge:GetBuyedFlag(pPlayer);
	local tbBit = KLib.GetBitTB(nBuyedFlag)
	local tbBuyGoldGroup = Recharge.tbSettingGroup.BuyGold
	local v = tbBuyGoldGroup[nIndex]
	if v then
		if tbBit[v.nGroupIndex] == 0 then
			nBuyedFlag = KLib.SetBit(nBuyedFlag, v.nGroupIndex, 1)
			tbBit[v.nGroupIndex] = 1;
			pPlayer.SetUserValue(Recharge.SAVE_GROUP, Recharge.KEY_BUYED_FLAG, nBuyedFlag)

			Log("[tbIDIPInterface] SetBuyGold ok",dwID,pPlayer.szName,nIndex,v.nGroupIndex)
		else
			Log("[tbIDIPInterface] SetBuyGold repeat",dwID,pPlayer.szName,nIndex,v.nGroupIndex)
		end
	else
		Log("[tbIDIPInterface] SetBuyGold no find info",dwID,pPlayer.szName,nIndex)
	end
end

-- 首冲
function tbIDIPInterface:SetFirstCharge(dwID)
	local pPlayer = KPlayer.GetPlayerObjById(dwID)
	if not pPlayer then
		Log("[tbIDIPInterface] SetFirstCharge not player",dwID)
		return
	end
	if pPlayer.GetUserValue(Recharge.SAVE_GROUP, Recharge.KEY_GET_FIRST_RECHARGE) ~= 1 then
		pPlayer.SetUserValue(Recharge.SAVE_GROUP, Recharge.KEY_GET_FIRST_RECHARGE, 1)
		Kin:_SetRedBagSendTime(pPlayer, 1)
		Log("[tbIDIPInterface] SetFirstCharge ok",dwID,pPlayer.szName)
	else
		Log("[tbIDIPInterface] SetFirstCharge repeat",dwID,pPlayer.szName)
	end
end

function tbIDIPInterface:IDIP_AQ_DO_BAN_JOINGROUPRANK_OFFLINE_REQ(nCmdId, tbReq, nCmdSequence)
	Player:DoAccountRoleMatchRequest(tbReq.OpenId,tbReq.RoleId,Transmit.tbIDIPInterface.OnBanJoinGroupRankOfflineCheckFinish,Transmit.tbIDIPInterface,nCmdId,tbReq,nCmdSequence);
end

function tbIDIPInterface:OnBanJoinGroupRankOfflineCheckFinish(szAccount, dwPlayerId, nIsMatch,nCmdId, tbReq, nCmdSequence)
		local tbRsp =
	{
		Result 				= IDIP_SUCCESS,
		RetMsg 				= "ok",
	}

	if nIsMatch == 0 then
		tbRsp.Result = IDIP_PLAYER_NOT_EXIST;
		tbRsp.RetMsg = ErrInValidAccountRoleIdNotMatch;
		self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_AQ_DO_BAN_JOINGROUPRANK_OFFLINE_REQ", nCmdSequence)
		return
	end

	local nType = tonumber(tbReq.Type) or 0
	local nTime = tonumber(tbReq.Time) or 0
	local szTips = "凍結中"
	if tbReq.Tip and tbReq.Tip ~= "" then
		szTips = tbReq.Tip
	end
	local nIsZeroRank = tonumber(tbReq.IsZeroRank) or 0
	local nEndTime = GetTime() + nTime

	if nType == 0 or nTime <= 0 then
		tbRsp.Result = IDIP_INVALID_PARAM;
		tbRsp.RetMsg = ErrInvalidParam;
		self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_AQ_DO_BAN_JOINGROUPRANK_OFFLINE_REQ", nCmdSequence)
		return
	end

	local pPlayerInfo = KPlayer.GetRoleStayInfo(dwPlayerId);
	if not pPlayerInfo then
		tbRsp.Result = IDIP_PLAYER_NOT_EXIST;
		tbRsp.RetMsg = ErrPlayerNotExist;
		self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_AQ_DO_BAN_JOINGROUPRANK_OFFLINE_REQ", nCmdSequence)
		return
	end

	local pPlayer = KPlayer.GetPlayerObjById(dwPlayerId)
	if nType == BanGroupOfflineRankType.KinRank then
		if nIsZeroRank == Forbid.IsClear.CLEAR then
 			Forbid:ClearRankData(_,Forbid.BanType.KinRank,pPlayerInfo.dwKinId)
 		end
		Forbid:Ban(_,Forbid.BanType.KinRank,nEndTime,szTips,pPlayerInfo.dwKinId)
	elseif nType == BanGroupOfflineRankType.AllRank then
		if nIsZeroRank == Forbid.IsClear.CLEAR then
			Forbid:ClearRankData(_,Forbid.BanType.KinRank,pPlayerInfo.dwKinId)
 		end
 		Forbid:Ban(_,Forbid.BanType.KinRank,nEndTime,szTips,pPlayerInfo.dwKinId)
	else
		tbRsp.Result = IDIP_INVALID_PARAM;
		tbRsp.RetMsg = ErrInvalidParam;
		self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_AQ_DO_BAN_JOINGROUPRANK_OFFLINE_REQ", nCmdSequence)
		return
	end

	if pPlayer then
		pPlayer.MsgBox(string.format("您由於%s被禁止上榜，禁止時間%s",szTips, Lib:TimeDesc2(nTime) or ""), {{"確定"}, {"取消"}})
	end

	TLog("IDIPFLOW", tbReq.AreaId, tbReq.OpenId,0,0, tbReq.Serial, tbReq.Source, nCmdId, tbReq.PlatId,
        tbReq.Partition, tbReq.RoleId,0, "IDIP_AQ_DO_BAN_JOINGROUPRANK_OFFLINE_REQ", (pPlayer and "immediately") or "delay", nType, nTime,szTips,nIsZeroRank,nEndTime)

	self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_AQ_DO_BAN_JOINGROUPRANK_OFFLINE_REQ", nCmdSequence)
end

function tbIDIPInterface:IDIP_DO_ADD_OR_DELE_POWER_REQ(nCmdId, tbReq, nCmdSequence)
	Player:DoAccountRoleMatchRequest(tbReq.OpenId,tbReq.RoleId,Transmit.tbIDIPInterface.OnAddOrDelePowerCheckFinish,Transmit.tbIDIPInterface,nCmdId,tbReq,nCmdSequence);
end

function tbIDIPInterface:OnAddOrDelePowerCheckFinish(szAccount, dwPlayerId, nIsMatch,nCmdId, tbReq, nCmdSequence)
	local tbRsp =
		{
			Result 				= IDIP_SUCCESS,
			RetMsg 				= "ok",
		}

	if nIsMatch == 0 then
		tbRsp.Result = IDIP_PLAYER_NOT_EXIST;
		tbRsp.RetMsg = ErrInValidAccountRoleIdNotMatch;
		self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_DO_ADD_OR_DELE_POWER_REQ", nCmdSequence)
		return
	end

	local nType = tonumber(tbReq.Type) 							-- 执行类型：授权（1）、取消（2）

	if not nType then
		tbRsp.Result = IDIP_INVALID_PARAM;
		tbRsp.RetMsg = ErrInvalidParam;
		self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_DO_ADD_OR_DELE_POWER_REQ", nCmdSequence)
		return
	end

	local Type_Ref =
	{
		[1] = ChatMgr.ChatCrossAuthType.emHost,
		[2] = ChatMgr.ChatCrossAuthType.emNone,
	}

	local nPowerType = Type_Ref[nType]
	if not nPowerType then
		tbRsp.Result = IDIP_INVALID_TYPE;
		tbRsp.RetMsg = ErrInValidType;
		self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_DO_ADD_OR_DELE_POWER_REQ", nCmdSequence)
		return
	end

	local pPlayerInfo = KPlayer.GetRoleStayInfo(dwPlayerId);
	if not pPlayerInfo then
		tbRsp.Result = IDIP_PLAYER_NOT_EXIST;
		tbRsp.RetMsg = ErrPlayerNotExist;
		self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_DO_ADD_OR_DELE_POWER_REQ", nCmdSequence)
		return
	end

	local pPlayer = KPlayer.GetPlayerObjById(dwPlayerId)

	if pPlayer then
		ChatMgr:SetCrossHostAuth(pPlayer,nPowerType)
	else
		KPlayer.AddDelayCmd(dwPlayerId,
				string.format("ChatMgr:SetCrossHostAuth(me,%d)",nPowerType),
				string.format("%s|%d|%s|%s", 'IDIP_DO_ADD_OR_DELE_POWER_REQ', nPowerType, tbReq.Source, tbReq.Serial))
	end

	TLog("IDIPFLOW", tbReq.AreaId, tbReq.OpenId,0,0, tbReq.Serial, tbReq.Source, nCmdId, tbReq.PlatId,
        tbReq.Partition, tbReq.RoleId,0, "IDIP_DO_ADD_OR_DELE_POWER_REQ", (pPlayer and "immediately") or "delay", nType, nPowerType)

	self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_DO_ADD_OR_DELE_POWER_REQ", nCmdSequence)
end

-- 口令红包
function tbIDIPInterface:IDIP_DO_ACTIVE_WORD_RED_DACKET_REQ(nCmdId, tbReq, nCmdSequence)
	local tbRsp =
		{
			Result 	= IDIP_SUCCESS,
			RetMsg 	= "ok",
		}

	local szRedKey = tbReq.RedPacket
	local nRedId = tonumber(tbReq.RedPacketId)
	local nRedType = tonumber(tbReq.RedPacketType)
	local nOverTime = tonumber(tbReq.RedPacketTime)

	if not nRedId or not nRedType or not nOverTime or nOverTime <= 0 or szRedKey == "" then
		tbRsp.Result = IDIP_INVALID_PARAM;
 		tbRsp.RetMsg = ErrInvalidParam;
		self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_DO_ACTIVE_WORD_RED_DACKET_REQ", nCmdSequence)
		return
	end

	local bRet,ErrMsg = ChatMgr.ChatAward:AddChatAward(szRedKey, nRedId, nRedType, nOverTime)
	if not bRet then
		tbRsp.Result = IDIP_RED_DACKET_PARAM_ERR;
 		tbRsp.RetMsg = ErrRedDacketParam;
		self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_DO_ACTIVE_WORD_RED_DACKET_REQ", nCmdSequence)
		return
	end

	TLog("IDIPFLOW", tbReq.AreaId, tbReq.OpenId,0,0, tbReq.Serial, tbReq.Source, nCmdId, tbReq.PlatId,
        tbReq.Partition, tbReq.RoleId,0, "IDIP_DO_ACTIVE_WORD_RED_DACKET_REQ","immediately",szRedKey,nRedId,nRedType,nOverTime)

 	self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_DO_ACTIVE_WORD_RED_DACKET_REQ", nCmdSequence)
end

function tbIDIPInterface:IDIP_DO_DELE_WORD_RED_DACKET_REQ(nCmdId, tbReq, nCmdSequence)
	local tbRsp =
		{
			Result 	= IDIP_SUCCESS,
			RetMsg 	= "ok",
		}

	local nRedId = tonumber(tbReq.RedPacketId)
	if not nRedId then
		tbRsp.Result = IDIP_INVALID_PARAM;
 		tbRsp.RetMsg = ErrInvalidParam;
		self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_DO_DELE_WORD_RED_DACKET_REQ", nCmdSequence)
		return
	end

	if not ChatMgr.ChatAward:CancelChatAward(nRedId) then
		tbRsp.Result = IDIP_NO_EXIST_ID;
 		tbRsp.RetMsg = ErrNoExistId;
		self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_DO_DELE_WORD_RED_DACKET_REQ", nCmdSequence)
		return
	end

	TLog("IDIPFLOW", tbReq.AreaId, tbReq.OpenId,0,0, tbReq.Serial, tbReq.Source, nCmdId, tbReq.PlatId,
        tbReq.Partition, tbReq.RoleId,0, "IDIP_DO_DELE_WORD_RED_DACKET_REQ","immediately",nRedId)

 	self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_DO_DELE_WORD_RED_DACKET_REQ", nCmdSequence)
end

function tbIDIPInterface:IDIP_DO_USR_SEND_WINE_HOUSE_MSG_REQ(nCmdId, tbReq, nCmdSequence)
    Player:DoAccountRoleMatchRequest(tbReq.OpenId,tbReq.RoleId,Transmit.tbIDIPInterface.OnDoUsrSendWineHouseMsgCheckFinish,Transmit.tbIDIPInterface,nCmdId,tbReq,nCmdSequence);
end

function tbIDIPInterface:OnDoUsrSendWineHouseMsgCheckFinish(szAccount, dwPlayerId, nIsMatch,nCmdId, tbReq, nCmdSequence)
    local tbRsp =
        {
            Result              = IDIP_SUCCESS,
            RetMsg              = "ok",
        }

    if nIsMatch == 0 then
        tbRsp.Result = IDIP_PLAYER_NOT_EXIST;
        tbRsp.RetMsg = ErrInValidAccountRoleIdNotMatch;
        self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_DO_USR_SEND_WINE_HOUSE_MSG_REQ", nCmdSequence)
        return
    end

    local nChannel = tonumber(tbReq.Channel)
    local szSend = tbReq.Send
    local szContentType = tbReq.ContentType
    local nToRoleId = tonumber(tbReq.ToRoleId)

    if not nChannel then
        tbRsp.Result = IDIP_INVALID_PARAM;
        tbRsp.RetMsg = ErrInvalidParam;
        self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_DO_USR_SEND_WINE_HOUSE_MSG_REQ", nCmdSequence)
        return
    end

    local pStayInfo = KPlayer.GetRoleStayInfo(dwPlayerId)

    if not pStayInfo then
        tbRsp.Result = IDIP_PLAYER_NOT_EXIST;
        tbRsp.RetMsg = ErrPlayerNotExist;
        self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_DO_USR_SEND_WINE_HOUSE_MSG_REQ", nCmdSequence)
        return
    end

    local pPlayer = KPlayer.GetPlayerObjById(dwPlayerId)
    local nKinId = pPlayer and pPlayer.dwKinId or pStayInfo.dwKinId

    local szName = pStayInfo.szName or "-"
    local szMsg = "<[" .. szName .."]" ..szContentType ..">"
    local tbLinkData = {nLinkType = ChatMgr.LinkType.OpenUrlLunTanJiuLou,szParam = szSend}
    if nChannel == ChannelType.Kin then
    	if not nKinId or nKinId == 0 then
    		tbRsp.Result = IDIP_KIN_NOT_FOUND;
            tbRsp.RetMsg = ErrKinNotFound;
            self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_DO_USR_SEND_WINE_HOUSE_MSG_REQ", nCmdSequence)
            return
    	end
        ChatMgr:SendPlayerMsg(ChatMgr.ChannelType.Kin, dwPlayerId, pStayInfo.szName, pStayInfo.nFaction, pStayInfo.nPortrait, pStayInfo.nLevel, szMsg,tbLinkData, nKinId)
    elseif nChannel == ChannelType.Friend then
        -- 好友频道需要好友在线才能拿到好友信息
        if not pPlayer then
            tbRsp.Result = IDIP_PLAYER_OFFLINE;
            tbRsp.RetMsg = ErrPlayerOffline;
            self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_DO_USR_SEND_WINE_HOUSE_MSG_REQ", nCmdSequence)
            return
        end
        ChatMgr:SendPlayerMsg(ChatMgr.ChannelType.Friend, dwPlayerId, pStayInfo.szName, pStayInfo.nFaction, pStayInfo.nPortrait, pStayInfo.nLevel, szMsg,tbLinkData)
    elseif nChannel == ChannelType.Private then
    	if not nToRoleId then
	        tbRsp.Result = IDIP_INVALID_PARAM;
	        tbRsp.RetMsg = ErrInvalidParam;
	        self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_DO_USR_SEND_WINE_HOUSE_MSG_REQ", nCmdSequence)
	        return
    	end
        if not pPlayer then
            tbRsp.Result = IDIP_PLAYER_OFFLINE;
            tbRsp.RetMsg = ErrPlayerOffline;
            self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_DO_USR_SEND_WINE_HOUSE_MSG_REQ", nCmdSequence)
            return
        end

        local pToStayInfo = KPlayer.GetRoleStayInfo(nToRoleId)
        if not pToStayInfo then
	        tbRsp.Result = IDIP_OTHER_PLAYER_NO_EXIST;
	        tbRsp.RetMsg = ErrOtherPlayerNoExist;
	        self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_DO_USR_SEND_WINE_HOUSE_MSG_REQ", nCmdSequence)
	        return
	    end
    	SendPrivateMsg(dwPlayerId, nToRoleId, szMsg, tbLinkData)
    else
        tbRsp.Result = IDIP_INVALID_PARAM;
        tbRsp.RetMsg = ErrInvalidParam;
        self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_DO_USR_SEND_WINE_HOUSE_MSG_REQ", nCmdSequence)
        return
    end

    TLog("IDIPFLOW", tbReq.AreaId, tbReq.OpenId,0,0, tbReq.Serial, tbReq.Source, nCmdId, tbReq.PlatId,
         tbReq.Partition, tbReq.RoleId,0, "IDIP_DO_USR_SEND_WINE_HOUSE_MSG_REQ", (pPlayer and "immediately") or "delay",nChannel,szSend,szContentType,nToRoleId)

    self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_DO_USR_SEND_WINE_HOUSE_MSG_REQ", nCmdSequence)
 end


 function tbIDIPInterface:IDIP_DO_SET_BUY_STATUS_NEW_REQ(nCmdId, tbReq, nCmdSequence)
	Player:DoAccountRoleMatchRequest(tbReq.OpenId,tbReq.RoleId,Transmit.tbIDIPInterface.OnSetBuyStateNewCheckFinish,Transmit.tbIDIPInterface,nCmdId,tbReq,nCmdSequence);
end

function tbIDIPInterface:OnSetBuyStateNewCheckFinish(szAccount, dwPlayerId, nIsMatch,nCmdId, tbReq, nCmdSequence)
	local tbRsp =
		{
			Result 	= IDIP_SUCCESS,
			RetMsg 	= "ok",
		}

	if nIsMatch == 0 then
		tbRsp.Result = IDIP_PLAYER_NOT_EXIST;
		tbRsp.RetMsg = ErrInValidAccountRoleIdNotMatch;
		self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_DO_SET_BUY_STATUS_NEW_REQ", nCmdSequence)
		return
	end

	local nType = tonumber(tbReq.Value)
	if not nType then
		tbRsp.Result = IDIP_INVALID_PARAM;
		tbRsp.RetMsg = ErrInvalidParam;
		self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_DO_SET_BUY_STATUS_NEW_REQ", nCmdSequence)
		return
	end

	local pPlayer = KPlayer.GetRoleStayInfo(dwPlayerId);
	if not pPlayer then
		tbRsp.Result = IDIP_PLAYER_NOT_EXIST;
		tbRsp.RetMsg = ErrPlayerNotExist;
		self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_DO_SET_BUY_STATUS_NEW_REQ", nCmdSequence)
		return
	end

	local tbData = tbNewYearRechargeData[nType]
	if not tbData then
		tbRsp.Result = IDIP_INVALID_TYPE;
		tbRsp.RetMsg = ErrInValidType;
		self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_DO_SET_BUY_STATUS_NEW_REQ", nCmdSequence)
		return
	end

	local tbParam = tbData.tbParam or {-1}
	local szCall = tbData.szCall

	local szCmd
	pPlayer = KPlayer.GetPlayerObjById(dwPlayerId)

	if pPlayer then
		Transmit.tbIDIPInterface[szCall](self,dwPlayerId,unpack(tbParam))
	else
		szCmd = string.format("Transmit.tbIDIPInterface:%s(%d,%d)",szCall,dwPlayerId,unpack(tbParam))
	end

	if szCmd then
		KPlayer.AddDelayCmd(dwPlayerId,
                szCmd,
                string.format("%s|%d|%s|%s", 'IDIP_DO_SET_BUY_STATUS_NEW_REQ' ,nType, tbReq.Source, tbReq.Serial))
	end

	TLog("IDIPFLOW", tbReq.AreaId, tbReq.OpenId,0,0, tbReq.Serial, tbReq.Source, nCmdId, tbReq.PlatId,
    tbReq.Partition, dwPlayerId,0, "IDIP_DO_SET_BUY_STATUS_NEW_REQ",pPlayer and "immediately" or "delay",nType)

	self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_DO_SET_BUY_STATUS_NEW_REQ", nCmdSequence)
end

function tbIDIPInterface:OnBuyYearGift(dwPlayerId, nIndex)
	local pPlayer = KPlayer.GetPlayerObjById(dwPlayerId)
	if not pPlayer then
		Log("[tbIDIPInterface] SetYiBenWanLi not player", dwPlayerId, nIndex)
		return
	end
	if not Recharge.tbSettingGroup or not Recharge.tbSettingGroup.YearGift then
		Log("IDIP_DO_SET_BUY_STATUS_NEW_REQ OnBuyYearGift no data ", dwPlayerId, nIndex)
		return
	end
	local tbInfo = Recharge.tbSettingGroup.YearGift[nIndex]
	if not tbInfo then
		Log("IDIP_DO_SET_BUY_STATUS_NEW_REQ OnBuyYearGift no info ", dwPlayerId, nIndex)
		return
	end

	local bCan =  Recharge:CanBuyProduct(pPlayer, tbInfo.ProductId)
	if not bCan then
		Log("IDIP_DO_SET_BUY_STATUS_NEW_REQ OnBuyYearGift no can ", dwPlayerId, nIndex)
		return
	end

	local nLocalEndTime = pPlayer.GetUserValue(Recharge.SAVE_GROUP, tbInfo.nEndTimeKey)
    local nNow = GetTime()
    if nLocalEndTime < nNow then
        nLocalEndTime = nNow
    end
    local nNewEndTime = nLocalEndTime + 3600 * 24 * tbInfo.nLastingDay
    Recharge:OnBuyYearCardCallBack(pPlayer, nNewEndTime, tbInfo.nGroupIndex)
    Log("IDIP_DO_SET_BUY_STATUS_NEW_REQ OnBuyYearGift ok ", nIndex, tbInfo.ProductId, tbInfo.nEndTimeKey, tbInfo.nLastingDay)
end

function tbIDIPInterface:SetYiBenWanLiNewYear(dwPlayerId, nGroupIndex)
	local pPlayer = KPlayer.GetPlayerObjById(dwPlayerId)
	if not pPlayer then
		Log("[tbIDIPInterface] SetYiBenWanLiNewYear not player", dwPlayerId, nGroupIndex)
		return
	end
	if not Recharge.tbSettingGroup or not Recharge.tbSettingGroup.GrowInvest then
		Log("IDIP_DO_SET_BUY_STATUS_NEW_REQ SetYiBenWanLiNewYear no data ", dwPlayerId, nGroupIndex)
		return
	end
	local tbInfo = Recharge.tbSettingGroup.GrowInvest[nGroupIndex]
	if not tbInfo then
		Log("IDIP_DO_SET_BUY_STATUS_NEW_REQ SetYiBenWanLiNewYear no info ", dwPlayerId, nGroupIndex)
		return
	end

	local bCan =  Recharge:CanBuyProduct(pPlayer, tbInfo.ProductId)
	if not bCan then
		Log("IDIP_DO_SET_BUY_STATUS_NEW_REQ SetYiBenWanLiNewYear no can ", dwPlayerId, nGroupIndex)
		return
	end

	Recharge:OnBuyInvestCallBack(pPlayer, nGroupIndex)
	Log("[tbIDIPInterface] SetYiBenWanLiNewYear try ", dwPlayerId, pPlayer.szName, nGroupIndex)
end

function tbIDIPInterface:IDIP_DO_SEND_ATTACH_MAIL_EXPIRE_REQ(nCmdId, tbReq, nCmdSequence)
	Player:DoAccountRoleMatchRequest(tbReq.OpenId, tbReq.RoleId, Transmit.tbIDIPInterface.OnSendAttachMailExpireCheckFinish, Transmit.tbIDIPInterface, nCmdId, tbReq, nCmdSequence);
end

function tbIDIPInterface:OnSendAttachMailExpireCheckFinish(szAccount, dwPlayerId, nIsMatch, nCmdId, tbReq, nCmdSequence)
	local tbRsp =
	{
		Result = IDIP_SUCCESS,
		RetMsg = "ok",
		ExtendParameter,
	}

	local szExtendParameter = tbReq.ExtendParameter or ""
	local nKinBonus = tonumber(tbReq.IsFamilyBonus) or 0
	local nGoldNum = 0

	tbRsp.ExtendParameter = szExtendParameter
	if nIsMatch == 0 then
		tbRsp.Result = IDIP_PLAYER_NOT_EXIST;
		tbRsp.RetMsg = ErrInValidAccountRoleIdNotMatch;
		self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_DO_SEND_ATTACH_MAIL_EXPIRE_REQ", nCmdSequence)
		return
	end

	local pPlayerStay = KPlayer.GetRoleStayInfo(dwPlayerId);
	if not pPlayerStay then
	    tbRsp.Result = IDIP_PLAYER_NOT_EXIST;
	    tbRsp.RetMsg = ErrPlayerNotExist;
	    self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_DO_SEND_ATTACH_MAIL_EXPIRE_REQ", nCmdSequence)
	    return
	end

	if not tonumber(tbReq.Type) or not tonumber(tbReq.ItemNum) or not tonumber(tbReq.ExpireTime) or tbReq.ExpireTime <= 0 then
		tbRsp.Result = IDIP_INVALID_PARAM
        tbRsp.RetMsg = ErrInvalidParam
        self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_DO_SEND_ATTACH_MAIL_EXPIRE_REQ", nCmdSequence)
        return
	end

	local nReason = tonumber(tbReq.Reason)
	local nLogReazon = nReason and nReason or Env.LogWay_IdipDoSendAttachMailExpireReq
	local szReason2 = tbReq.SubReason
	local tbMail = {};
	tbMail.To = tbReq.RoleId;
	tbMail.Title = tbReq.MailTitle;
	tbMail.Text = tbReq.MailContent;
	tbMail.From = "系統";
	tbMail.nLogReazon = nLogReazon;
	if szReason2 and szReason2 ~= "" then
		-- 目前道具的reason2只支持数值类型
		local nReason2 = tonumber(szReason2)
		if not nReason2 then
			tbRsp.Result = IDIP_INVALID_REASON2
            tbRsp.RetMsg = ErrInvalidReason2
            self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_DO_SEND_ATTACH_MAIL_EXPIRE_REQ", nCmdSequence)
			return
		end
		tbMail.tbParams = {}
		tbMail.tbParams.LogReason2 = nReason2
	end

	if tbReq.Type == tbItemType.item then
		if not tonumber(tbReq.ItemId) or not KItem.GetItemBaseProp(tbReq.ItemId) then
			tbRsp.Result = IDIP_INVALID_ITEM_ID
            tbRsp.RetMsg = ErrInValidItemId
            self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_DO_SEND_ATTACH_MAIL_EXPIRE_REQ", nCmdSequence)
            return
		end
	else
		tbRsp.Result = IDIP_INVALID_PARAM
        tbRsp.RetMsg = ErrInvalidParam
        self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_DO_SEND_ATTACH_MAIL_EXPIRE_REQ", nCmdSequence)
        return
	end
	local nEndTime = GetTime() + tbReq.ExpireTime
	local tbAward = self:GetAwardList(tbReq.Type, tbReq.ItemId, tbReq.ItemNum, nEndTime);
	if not tbAward then
		tbRsp.Result = IDIP_INVALID_ITEM_TYPE
		tbRsp.RetMsg = ErrInValidItemType
		Log("IDIP_DO_SEND_ATTACH_MAIL_EXPIRE_REQ ========= no match awardType" , tbReq.Type, tbReq.ItemId, tbReq.ItemNum, tbReq.ExpireTime);
		self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_DO_SEND_ATTACH_MAIL_EXPIRE_REQ", nCmdSequence)
		return
	end
	tbMail.tbAttach = {tbAward};
	local szTime = "\n(道具過期時間:" .. Lib:TimeDesc9(nEndTime) .. ")"
	tbMail.Text = tbMail.Text .. szTime

	Mail:SendSystemMail(tbMail);
	TLog("IDIPFLOW", tbReq.AreaId, tbReq.OpenId, tbReq.ItemId, tbReq.ItemNum, tbReq.Serial, tbReq.Source, nCmdId, tbReq.PlatId,
		tbReq.Partition, tbReq.RoleId,0, "IDIP_DO_SEND_ATTACH_MAIL_EXPIRE_REQ", "immediately", tbReq.Type, nKinBonus, nKinId, nLogReazon, szReason2, tbReq.ExpireTime)

	self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_DO_SEND_ATTACH_MAIL_EXPIRE_REQ", nCmdSequence)
end

function tbIDIPInterface:IDIP_DO_FRESHEN_SERVER_INFO_REQ(nCmdId, tbReq, nCmdSequence)
	local tbRsp =
	{
		Result = IDIP_SUCCESS,
		RetMsg = "ok",
	}

	local nSwitch = tonumber(tbReq.Switch)
	if not nSwitch or nSwitch ~= 1 then
		tbRsp.Result = IDIP_INVALID_PARAM
        tbRsp.RetMsg = ErrInvalidParam
        self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_DO_FRESHEN_SERVER_INFO_REQ", nCmdSequence)
        return
	end

	ChatMgr:ReloadChatHostInfo()

	TLog("IDIPFLOW", tbReq.AreaId, tbReq.OpenId, 0, 0, tbReq.Serial, tbReq.Source, nCmdId, tbReq.PlatId,
		tbReq.Partition, 0, 0, "IDIP_DO_FRESHEN_SERVER_INFO_REQ")

	self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_DO_FRESHEN_SERVER_INFO_REQ", nCmdSequence)
end

function tbIDIPInterface:IDIP_DO_BAN_ROLE_REQ(nCmdId, tbReq, nCmdSequence)
	Player:DoAccountRoleMatchRequest(tbReq.OpenId, tbReq.RoleId, Transmit.tbIDIPInterface.OnDoBanRoleCheckFinish, Transmit.tbIDIPInterface, nCmdId, tbReq, nCmdSequence);
end

function tbIDIPInterface:OnDoBanRoleCheckFinish(szAccount, dwPlayerId, nIsMatch, nCmdId, tbReq, nCmdSequence)
	local tbRsp =
	{
		Result = IDIP_SUCCESS,
		RetMsg = "ok",
	}

	if nIsMatch == 0 then
		tbRsp.Result = IDIP_PLAYER_NOT_EXIST;
		tbRsp.RetMsg = ErrInValidAccountRoleIdNotMatch;
		self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_DO_BAN_ROLE_REQ", nCmdSequence)
		return
	end

	local nBanTime = tonumber(tbReq.Time) or 0
	local szReason = tbReq.Reason
	if nBanTime == 0 or (nBanTime < 0 and (nBanTime ~= -1 and nBanTime ~= -2)) then
		tbRsp.Result = IDIP_INVALID_PARAM
        tbRsp.RetMsg = ErrInvalidParam
        self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_DO_BAN_ROLE_REQ", nCmdSequence)
		return
	end

	local pPlayerStay = KPlayer.GetRoleStayInfo(dwPlayerId);
	if not pPlayerStay then
	    tbRsp.Result = IDIP_PLAYER_NOT_EXIST;
	    tbRsp.RetMsg = ErrPlayerNotExist;
	    self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_DO_BAN_ROLE_REQ", nCmdSequence)
	    return
	end

	local pPlayer = KPlayer.GetPlayerObjById(dwPlayerId)
	if pPlayer and szReason ~= "" then
		pPlayer.CallClientScript("Ui:OnShowKickMsg", string.format("此角色由於%s已被凍結", szReason));
	end

	if nBanTime == -2 then
		szReason = szReason .."[no_time_notice]"
	end

	local nBanEndTime = nBanTime > 0 and GetTime() + nBanTime or -1

	BanPlayer(dwPlayerId, nBanEndTime, szReason);

	TLog("IDIPFLOW", tbReq.AreaId, tbReq.OpenId, 0, 0, tbReq.Serial, tbReq.Source, nCmdId, tbReq.PlatId,
	        tbReq.Partition, tbReq.RoleId, 0, "IDIP_DO_BAN_ROLE_REQ", "immediately", nBanTime, nBanEndTime, szReason)

	self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_DO_BAN_ROLE_REQ", nCmdSequence)
end

function tbIDIPInterface:IDIP_DO_UNBAN_ROLE_REQ(nCmdId, tbReq, nCmdSequence)
	Player:DoAccountRoleMatchRequest(tbReq.OpenId, tbReq.RoleId, Transmit.tbIDIPInterface.OnDoUnbanRoleCheckFinish, Transmit.tbIDIPInterface, nCmdId, tbReq, nCmdSequence);
end

function tbIDIPInterface:OnDoUnbanRoleCheckFinish(szAccount, dwPlayerId, nIsMatch, nCmdId, tbReq, nCmdSequence)
	local tbRsp =
	{
		Result = IDIP_SUCCESS,
		RetMsg = "ok",
	}

	if nIsMatch == 0 then
		tbRsp.Result = IDIP_PLAYER_NOT_EXIST;
		tbRsp.RetMsg = ErrInValidAccountRoleIdNotMatch;
		self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_DO_UNBAN_ROLE_REQ", nCmdSequence)
		return
	end

	local pPlayerStay = KPlayer.GetRoleStayInfo(dwPlayerId);
	if not pPlayerStay then
	    tbRsp.Result = IDIP_PLAYER_NOT_EXIST;
	    tbRsp.RetMsg = ErrPlayerNotExist;
	    self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_DO_UNBAN_ROLE_REQ", nCmdSequence)
	    return
	end

	BanPlayer(dwPlayerId,0,"");

	TLog("IDIPFLOW", tbReq.AreaId, tbReq.OpenId, 0, 0, tbReq.Serial, tbReq.Source, nCmdId, tbReq.PlatId,
	        tbReq.Partition, tbReq.RoleId, 0, "IDIP_DO_UNBAN_ROLE_REQ", "immediately")

	self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_DO_UNBAN_ROLE_REQ", nCmdSequence)
end

function tbIDIPInterface:IDIP_QUERY_BAN_ROLE_STATE_REQ(nCmdId, tbReq, nCmdSequence)
	Player:DoAccountRoleMatchRequest(tbReq.OpenId, tbReq.RoleId, Transmit.tbIDIPInterface.OnDoQueryBanRoleStateCheckFinish, Transmit.tbIDIPInterface, nCmdId, tbReq, nCmdSequence);
end

function tbIDIPInterface:OnDoQueryBanRoleStateCheckFinish(szAccount, dwPlayerId, nIsMatch, nCmdId, tbReq, nCmdSequence)
	local tbRsp =
	{
		Result = IDIP_SUCCESS,
		RetMsg = "ok",
		Time = 0
	}

	if nIsMatch == 0 then
		tbRsp.Result = IDIP_PLAYER_NOT_EXIST;
		tbRsp.RetMsg = ErrInValidAccountRoleIdNotMatch;
		self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_QUERY_BAN_ROLE_STATE_REQ", nCmdSequence)
		return
	end

	local pPlayerStay = KPlayer.GetRoleStayInfo(dwPlayerId);
	if not pPlayerStay then
	    tbRsp.Result = IDIP_PLAYER_NOT_EXIST;
	    tbRsp.RetMsg = ErrPlayerNotExist;
	    self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_QUERY_BAN_ROLE_STATE_REQ", nCmdSequence)
	    return
	end

	local nBanEndTime = pPlayerStay.nBanEndTime or 0
	if nBanEndTime < 0 then
		nBanEndTime = -1
	elseif nBanEndTime <= GetTime() then
		nBanEndTime = 0
	end

	tbRsp.Time = nBanEndTime

	TLog("IDIPFLOW", tbReq.AreaId, tbReq.OpenId, 0, 0, tbReq.Serial, tbReq.Source, nCmdId, tbReq.PlatId,
	        tbReq.Partition, tbReq.RoleId, 0, "IDIP_QUERY_BAN_ROLE_STATE_REQ", "immediately")

	self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_QUERY_BAN_ROLE_STATE_REQ", nCmdSequence)
end

-- 删除角色邮件接口
function tbIDIPInterface:IDIP_DO_DELETE_ROLE_EMAIL_REQ(nCmdId, tbReq, nCmdSequence)
	Player:DoAccountRoleMatchRequest(tbReq.OpenId, tbReq.RoleId, Transmit.tbIDIPInterface.OnDoDeleteRoleEmailCheckFinish, Transmit.tbIDIPInterface, nCmdId, tbReq, nCmdSequence);
end

function tbIDIPInterface:OnDoDeleteRoleEmailCheckFinish(szAccount, dwPlayerId, nIsMatch, nCmdId, tbReq, nCmdSequence)
	local tbRsp =
	{
		Result = IDIP_SUCCESS,
		RetMsg = "ok",
	}

	if nIsMatch == 0 then
		tbRsp.Result = IDIP_PLAYER_NOT_EXIST;
		tbRsp.RetMsg = ErrInValidAccountRoleIdNotMatch;
		self:IDIPDelayResponse(tbRsp.Result, tbRsp, tbRsp.RetMsg, "IDIP_DO_DELETE_ROLE_EMAIL_REQ", nCmdSequence)
		return
	end

	local pPlayerStay = KPlayer.GetRoleStayInfo(dwPlayerId);
	if not pPlayerStay then
	    tbRsp.Result = IDIP_PLAYER_NOT_EXIST;
	    tbRsp.RetMsg = ErrPlayerNotExist;
	    self:IDIPDelayResponse(tbRsp.Result, tbRsp, tbRsp.RetMsg, "IDIP_DO_DELETE_ROLE_EMAIL_REQ", nCmdSequence)
	    return
	end

	local nSwitch = tonumber(tbReq.Switch)
	if not nSwitch or nSwitch ~= 1 then
		tbRsp.Result = IDIP_INVALID_PARAM
        tbRsp.RetMsg = ErrInvalidParam
        self:IDIPDelayResponse(tbRsp.Result, tbRsp, tbRsp.RetMsg, "IDIP_DO_DELETE_ROLE_EMAIL_REQ", nCmdSequence)
        return
	end

	-- 删除玩家所有邮件
	Mail:DeleteAllMail(dwPlayerId)

	TLog("IDIPFLOW", tbReq.AreaId, tbReq.OpenId, 0, 0, tbReq.Serial, tbReq.Source, nCmdId, tbReq.PlatId,
	        tbReq.Partition, tbReq.RoleId, 0, "IDIP_DO_DELETE_ROLE_EMAIL_REQ", "immediately")

	self:IDIPDelayResponse(tbRsp.Result, tbRsp, tbRsp.RetMsg, "IDIP_DO_DELETE_ROLE_EMAIL_REQ", nCmdSequence)
end

-- 发送带附件系统邮件(过期时间戳)
function tbIDIPInterface:IDIP_DO_SEND_ITEM_WHITE_TIME_REQ(nCmdId, tbReq, nCmdSequence)
	Player:DoAccountRoleMatchRequest(tbReq.OpenId, tbReq.RoleId, Transmit.tbIDIPInterface.OnSendItemWhiteTimeCheckFinish, Transmit.tbIDIPInterface, nCmdId, tbReq, nCmdSequence);
end

function tbIDIPInterface:OnSendItemWhiteTimeCheckFinish(szAccount, dwPlayerId, nIsMatch, nCmdId, tbReq, nCmdSequence)
	local tbRsp =
	{
		Result = IDIP_SUCCESS,
		RetMsg = "ok",
	}

	if nIsMatch == 0 then
		tbRsp.Result = IDIP_PLAYER_NOT_EXIST;
		tbRsp.RetMsg = ErrInValidAccountRoleIdNotMatch;
		self:IDIPDelayResponse(tbRsp.Result, tbRsp, tbRsp.RetMsg, "IDIP_DO_SEND_ITEM_WHITE_TIME_REQ", nCmdSequence)
		return
	end

	local pPlayerStay = KPlayer.GetRoleStayInfo(dwPlayerId);
	if not pPlayerStay then
	    tbRsp.Result = IDIP_PLAYER_NOT_EXIST;
	    tbRsp.RetMsg = ErrPlayerNotExist;
	    self:IDIPDelayResponse(tbRsp.Result, tbRsp, tbRsp.RetMsg, "IDIP_DO_SEND_ITEM_WHITE_TIME_REQ", nCmdSequence)
	    return
	end

	local nEndTime = tonumber(tbReq.UneffectTime)

	if not tonumber(tbReq.Type) or not tonumber(tbReq.ItemNum) or not nEndTime or nEndTime <= GetTime() then
		tbRsp.Result = IDIP_INVALID_PARAM
        tbRsp.RetMsg = ErrInvalidParam
        self:IDIPDelayResponse(tbRsp.Result, tbRsp, tbRsp.RetMsg, "IDIP_DO_SEND_ITEM_WHITE_TIME_REQ", nCmdSequence)
        return
	end

	local tbMail = {};
	tbMail.To = tbReq.RoleId;
	tbMail.Title = tbReq.EmailTitle;
	tbMail.Text = tbReq.EmailContent;
	tbMail.From = "系統";
	tbMail.nLogReazon = Env.LogWay_IdipDoSendItemWhiteTimeReq;

	if tbReq.Type == tbItemType.item then
		if not tonumber(tbReq.ItemId) or not KItem.GetItemBaseProp(tbReq.ItemId) then
			tbRsp.Result = IDIP_INVALID_ITEM_ID
            tbRsp.RetMsg = ErrInValidItemId
            self:IDIPDelayResponse(tbRsp.Result, tbRsp, tbRsp.RetMsg, "IDIP_DO_SEND_ITEM_WHITE_TIME_REQ", nCmdSequence)
            return
		end
	else
		tbRsp.Result = IDIP_INVALID_PARAM
        tbRsp.RetMsg = ErrInvalidParam
        self:IDIPDelayResponse(tbRsp.Result, tbRsp, tbRsp.RetMsg, "IDIP_DO_SEND_ITEM_WHITE_TIME_REQ", nCmdSequence)
        return
	end

	local tbAward = self:GetAwardList(tbReq.Type, tbReq.ItemId, tbReq.ItemNum, nEndTime);
	if not tbAward then
		tbRsp.Result = IDIP_INVALID_ITEM_TYPE
		tbRsp.RetMsg = ErrInValidItemType
		Log("IDIP_DO_SEND_ITEM_WHITE_TIME_REQ ========= no match awardType" , tbReq.Type, tbReq.ItemId, tbReq.ItemNum, nEndTime);
		self:IDIPDelayResponse(tbRsp.Result, tbRsp, tbRsp.RetMsg, "IDIP_DO_SEND_ITEM_WHITE_TIME_REQ", nCmdSequence)
		return
	end
	tbMail.tbAttach = {tbAward};

	local szTime = "\n(道具過期時間:" .. Lib:TimeDesc9(nEndTime) .. ")"
	tbMail.Text = tbMail.Text .. szTime

	Mail:SendSystemMail(tbMail);

	TLog("IDIPFLOW", tbReq.AreaId, tbReq.OpenId, tbReq.ItemId, tbReq.ItemNum, tbReq.Serial, tbReq.Source, nCmdId, tbReq.PlatId,
		tbReq.Partition, tbReq.RoleId, 0, "IDIP_DO_SEND_ITEM_WHITE_TIME_REQ", "immediately", tbReq.UneffectTime)

	self:IDIPDelayResponse(tbRsp.Result, tbRsp, tbRsp.RetMsg, "IDIP_DO_SEND_ITEM_WHITE_TIME_REQ", nCmdSequence)
end

function tbIDIPInterface:IDIP_DO_DEFINE_BUTTON_CONTENT_REQ(nCmdId, tbReq, nCmdSequence)
	local tbRsp =
		{
			Result 	= IDIP_SUCCESS,
			RetMsg 	= "ok",
		}

	local nMsgId = tonumber(tbReq.MsgId)
	local szEndTime = tbReq.EndTime
	local szMsgContents = tbReq.MsgContents
	local szMsgTitle = tbReq.MsgTitle
	local szBtnName = tbReq.ButtonMsg
	local szBtnTrap = tbReq.ButtonUrl
	local nType = tonumber(tbReq.Type)
	local nOrder = tonumber(tbReq.Order)
	local nRefresh = tonumber(tbReq.Refresh) or 1
	local szCheckRpFunc = tbNewMsgRPRefresh[nRefresh]

	if not nMsgId or szEndTime == "" or szMsgContents == "" or szMsgTitle == "" or (nType and not tbAllNewMsgType[nType]) 
		or (nRefresh ~= NewMsgRPType.ShowOne and not szCheckRpFunc) then
		tbRsp.Result = IDIP_INVALID_PARAM;
		tbRsp.RetMsg = ErrInvalidParam;
		self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_DO_DEFINE_BUTTON_CONTENT_REQ", nCmdSequence)
		return
	end

	local nEndTime = tonumber(szEndTime)
	if not nEndTime then
		tbRsp.Result = IDIP_INVALID_PARAM;
		tbRsp.RetMsg = ErrInvalidParam;
		self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_DO_DEFINE_BUTTON_CONTENT_REQ", nCmdSequence)
		return
	end

	local szKey = self:GetNewMsgPrefix(nMsgId)
	local tbInfoData = NewInformation:GetInformation(szKey)
	if tbInfoData then
		tbRsp.Result = IDIP_EXIST_NEW_MSG_ID;
		tbRsp.RetMsg = ErrExistNewMsgId;
		self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_DO_DEFINE_BUTTON_CONTENT_REQ", nCmdSequence)
		return
	end
	local tbActData = {string.format(szMsgContents)}
	local bRet = NewInformation:AddInfomation(szKey, nEndTime, tbActData, {szTitle = szMsgTitle, szBtnName = szBtnName, szBtnTrap = szBtnTrap, nOperationType = nType, nShowPriority = nOrder, szCheckRpFunc = szCheckRpFunc});

	if not bRet then
		tbRsp.Result = IDIP_NEW_MSG_ADD_FAIL;
		tbRsp.RetMsg = ErrNewMsgAddFail;
		self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_DO_DEFINE_BUTTON_CONTENT_REQ", nCmdSequence)
		Log("[IDIP_DO_DEFINE_BUTTON_CONTENT_REQ] AddInfomation fail ", tbReq.MsgId, tbReq.EndTime, tbReq.MsgContents, tbReq.MsgTitle, szEndTime, szKey)
		return
	end

	TLog("IDIPFLOW", tbReq.AreaId, tbReq.OpenId, 0, 0, tbReq.Serial, tbReq.Source, nCmdId, tbReq.PlatId,
    tbReq.Partition, 0, 0, "IDIP_DO_DEFINE_BUTTON_CONTENT_REQ", "immediately", nMsgId, nEndTime, szMsgContents, szMsgTitle, nEndTime, szBtnName, szBtnTrap, nType or -1, nOrder or -1, nRefresh or -1)

	self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg, "IDIP_DO_DEFINE_BUTTON_CONTENT_REQ", nCmdSequence)
end

function tbIDIPInterface:IDIP_DO_VALUE_NIMBUS_REQ(nCmdId, tbReq,nCmdSequence)
	Player:DoAccountRoleMatchRequest(tbReq.OpenId, tbReq.RoleId, Transmit.tbIDIPInterface.OnDoValueNimbusCheckFinish, Transmit.tbIDIPInterface, nCmdId, tbReq, nCmdSequence);
end

function tbIDIPInterface:OnDoValueNimbusCheckFinish(szAccount, dwPlayerId, nIsMatch,nCmdId, tbReq, nCmdSequence)
	local tbRsp =
	{
		Result = IDIP_SUCCESS,
		RetMsg = "ok",
	}
	if nIsMatch == 0 then
		tbRsp.Result = IDIP_PLAYER_NOT_EXIST;
		tbRsp.RetMsg = ErrInValidAccountRoleIdNotMatch;
		self:IDIPDelayResponse(tbRsp.Result, tbRsp, tbRsp.RetMsg, "IDIP_DO_VALUE_NIMBUS_REQ", nCmdSequence)
		return
	end
	local nValue = tonumber(tbReq.Value);
	if not nValue or nValue == 0 then
		tbRsp.Result = IDIP_INVALID_PARAM
		tbRsp.RetMsg = ErrInvalidParam
		self:IDIPDelayResponse(tbRsp.Result, tbRsp, tbRsp.RetMsg, "IDIP_DO_VALUE_NIMBUS_REQ", nCmdSequence)
		return
	end
	local pPlayer = KPlayer.GetPlayerObjById(dwPlayerId);
	if pPlayer then
		if nValue > 0 then
			pPlayer.AddMoney("Energy", nValue, Env.LogWay_IdipDoValueNimbusReq);
		elseif nValue < 0 then
			local nCost = self:GetCost(pPlayer,"Energy", nValue);
			pPlayer.CostMoney("Energy", nCost, Env.LogWay_IdipDoValueNimbusReq);
		end
	else
		local pPlayerInfo = KPlayer.GetRoleStayInfo(dwPlayerId);
		if pPlayerInfo then
			local szCmd = "";
			local nCost = nValue;
			if nCost > 0 then
				szCmd = string.format("me.AddMoney('Energy', %d, %d)", nCost, Env.LogWay_IdipDoValueNimbusReq);
			elseif nCost < 0 then
				szCmd = string.format("local nCost = Transmit.tbIDIPInterface:GetCost(me,'Energy',%d);me.CostMoney('Energy', math.abs(nCost), %d)", nCost, Env.LogWay_IdipDoValueNimbusReq);
			end
			KPlayer.AddDelayCmd(dwPlayerId,
				szCmd,
				string.format("%s|%d|%s|%s", 'IDIP_DO_VALUE_NIMBUS_REQ', nCost, tbReq.Source, tbReq.Serial))
		else
			tbRsp.Result = IDIP_PLAYER_NOT_EXIST
			tbRsp.RetMsg = ErrPlayerNotExist
		end
	end

	TLog("IDIPFLOW", tbReq.AreaId, tbReq.OpenId, 0, tbReq.Value, tbReq.Serial, tbReq.Source, nCmdId, tbReq.PlatId,
		tbReq.Partition, tbReq.RoleId, 0, "IDIP_DO_VALUE_NIMBUS_REQ", (pPlayer and "immediately") or "delay")

	self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_DO_VALUE_NIMBUS_REQ", nCmdSequence)
end

function tbIDIPInterface:IDIP_DO_VALUE_RECHARGE_REQ(nCmdId, tbReq,nCmdSequence)
	Player:DoAccountRoleMatchRequest(tbReq.OpenId, tbReq.RoleId, Transmit.tbIDIPInterface.OnDoValueRechargeCheckFinish, Transmit.tbIDIPInterface, nCmdId, tbReq,nCmdSequence);
end

function tbIDIPInterface:OnDoValueRechargeCheckFinish(szAccount, dwPlayerId, nIsMatch,nCmdId, tbReq, nCmdSequence)
	local tbRsp =
	{
		Result = IDIP_SUCCESS,
		RetMsg = "ok",
	}
	if nIsMatch == 0 then
		tbRsp.Result = IDIP_PLAYER_NOT_EXIST;
		tbRsp.RetMsg = ErrInValidAccountRoleIdNotMatch;
		self:IDIPDelayResponse(tbRsp.Result, tbRsp, tbRsp.RetMsg, "IDIP_DO_VALUE_RECHARGE_REQ", nCmdSequence)
		return
	end
	local nValue = tonumber(tbReq.Value);
	if not nValue or nValue == 0 then
		tbRsp.Result = IDIP_INVALID_PARAM
		tbRsp.RetMsg = ErrInvalidParam
		self:IDIPDelayResponse(tbRsp.Result, tbRsp, tbRsp.RetMsg, "IDIP_DO_VALUE_RECHARGE_REQ", nCmdSequence)
		return
	end
	local pPlayer = KPlayer.GetPlayerObjById(dwPlayerId);
	if pPlayer then
		if nValue > 0 then
			pPlayer.AddMoney("SilverBoard", nValue, Env.LogWay_IdipDoValueRechargeReq);
		elseif nValue < 0 then
			local nCost = self:GetCost(pPlayer,"SilverBoard", nValue);
			pPlayer.CostMoney("SilverBoard", nCost, Env.LogWay_IdipDoValueRechargeReq);
		end
	else
		local pPlayerInfo = KPlayer.GetRoleStayInfo(dwPlayerId);
		if pPlayerInfo then
			local szCmd = "";
			local nCost = nValue;
			if nCost > 0 then
				szCmd = string.format("me.AddMoney('SilverBoard', %d, %d)", nCost, Env.LogWay_IdipDoValueRechargeReq);
			elseif nCost < 0 then
				szCmd = string.format("local nCost = Transmit.tbIDIPInterface:GetCost(me,'SilverBoard',%d);me.CostMoney('SilverBoard', math.abs(nCost), %d)", nCost, Env.LogWay_IdipDoValueRechargeReq);
			end
			KPlayer.AddDelayCmd(dwPlayerId,
				szCmd,
				string.format("%s|%d|%s|%s", 'IDIP_DO_VALUE_RECHARGE_REQ', nCost, tbReq.Source, tbReq.Serial))
		else
			tbRsp.Result = IDIP_PLAYER_NOT_EXIST
			tbRsp.RetMsg = ErrPlayerNotExist
		end
	end

	TLog("IDIPFLOW", tbReq.AreaId, tbReq.OpenId, 0, tbReq.Value, tbReq.Serial, tbReq.Source, nCmdId, tbReq.PlatId,
		tbReq.Partition, tbReq.RoleId, 0, "IDIP_DO_VALUE_RECHARGE_REQ", (pPlayer and "immediately") or "delay")

	self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_DO_VALUE_RECHARGE_REQ", nCmdSequence)
end

function tbIDIPInterface:IDIP_DO_VALUE_PRETTY_PINK_REQ(nCmdId, tbReq,nCmdSequence)
	Player:DoAccountRoleMatchRequest(tbReq.OpenId, tbReq.RoleId, Transmit.tbIDIPInterface.OnDoValuePrettyPinkCheckFinish, Transmit.tbIDIPInterface, nCmdId, tbReq,nCmdSequence);
end

function tbIDIPInterface:OnDoValuePrettyPinkCheckFinish(szAccount, dwPlayerId, nIsMatch,nCmdId, tbReq, nCmdSequence)
	local tbRsp =
	{
		Result = IDIP_SUCCESS,
		RetMsg = "ok",
		Reduce = 0,
		NowNum = 0,
	}
	if nIsMatch == 0 then
		tbRsp.Result = IDIP_PLAYER_NOT_EXIST;
		tbRsp.RetMsg = ErrInValidAccountRoleIdNotMatch;
		self:IDIPDelayResponse(tbRsp.Result, tbRsp, tbRsp.RetMsg, "IDIP_DO_VALUE_PRETTY_PINK_REQ", nCmdSequence)
		return
	end
	local nValue = tonumber(tbReq.Value);
	if not nValue or nValue <= 0 then
		tbRsp.Result = IDIP_INVALID_PARAM
		tbRsp.RetMsg = ErrInvalidParam
		self:IDIPDelayResponse(tbRsp.Result, tbRsp, tbRsp.RetMsg, "IDIP_DO_VALUE_PRETTY_PINK_REQ", nCmdSequence)
		return
	end

	local pPlayerInfo = KPlayer.GetRoleStayInfo(dwPlayerId);
	if not pPlayerInfo then
		tbRsp.Result = IDIP_PLAYER_NOT_EXIST
		tbRsp.RetMsg = ErrPlayerNotExist
		self:IDIPDelayResponse(tbRsp.Result, tbRsp, tbRsp.RetMsg, "IDIP_DO_VALUE_PRETTY_PINK_REQ", nCmdSequence)
		return
	end

	local pPlayer = KPlayer.GetPlayerObjById(dwPlayerId);
	if not pPlayer then
		tbRsp.Result = IDIP_PLAYER_OFFLINE
		tbRsp.RetMsg = ErrPlayerOffline
		self:IDIPDelayResponse(tbRsp.Result, tbRsp, tbRsp.RetMsg, "IDIP_DO_VALUE_PRETTY_PINK_REQ", nCmdSequence)
		return
	end

	local _, tbRunning = Activity:GetActivityData()
	local tbAct = tbRunning["BeautyPageant"] and tbRunning["BeautyPageant"].tbInst
	if not tbAct then
		tbRsp.Result = IDIP_ACTIVITY_NOT_START
		tbRsp.RetMsg = ErrActivityNotStart
		self:IDIPDelayResponse(tbRsp.Result, tbRsp, tbRsp.RetMsg, "IDIP_DO_VALUE_PRETTY_PINK_REQ", nCmdSequence)
		return
	end

	local nVotedRoleId = tonumber(tbReq.BeRoleId);
	local nVotedRoleServerId = tonumber(tbReq.BePartition);

	local nCurCount = pPlayer.GetItemCountInAllPos(tbAct.VOTE_ITEM)
	local nNeedCount = math.min(nCurCount, nValue)

	local nDelCount = pPlayer.ConsumeItemInAllPos(tbAct.VOTE_ITEM, nNeedCount, Env.LogWay_BeautyPageant_Vote);

	tbRsp.Reduce = nDelCount
	tbRsp.NowNum = nCurCount - nDelCount

	tbAct:AddVoteCount(pPlayer, nDelCount)
	
	pPlayer.Msg(string.format("消耗了%d個紅粉佳人進行投票！", nDelCount))

	local nServerId = GetServerIdentity()

	if nDelCount > 0 and nVotedRoleServerId and math.floor(nVotedRoleServerId/10000) == math.floor(nServerId/10000) then
		--如果投票人和被投票人是同一个大区的
		local pVotedPlayerInfo = KPlayer.GetRoleStayInfo(nVotedRoleId);
		if pVotedPlayerInfo then
			FriendShip:AddImitity(dwPlayerId, nVotedRoleId, nDelCount * tbAct.IMITITY_PER_VOTE, Env.LogWay_BeautyPageant_Vote)
		end
	end

	TLog("IDIPFLOW", tbReq.AreaId, tbReq.OpenId, 0, tbReq.Value, tbReq.Serial, tbReq.Source, nCmdId, tbReq.PlatId,
		tbReq.Partition, tbReq.RoleId, tbReq.VotedRoleId, tbReq.VotedRoleServerId, nCurCount, nDelCount, "IDIP_DO_VALUE_PRETTY_PINK_REQ", (pPlayer and "immediately") or "delay")

	self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_DO_VALUE_PRETTY_PINK_REQ", nCmdSequence)
end

function tbIDIPInterface:IDIP_DO_NOTICE_BELL_SUCCESS_REQ(nCmdId, tbReq,nCmdSequence)
	Player:DoAccountRoleMatchRequest(tbReq.OpenId, tbReq.RoleId, Transmit.tbIDIPInterface.OnDoNoticeBellCheckFinish, Transmit.tbIDIPInterface, nCmdId, tbReq,nCmdSequence);
end

function tbIDIPInterface:OnDoNoticeBellCheckFinish(szAccount, dwPlayerId, nIsMatch,nCmdId, tbReq, nCmdSequence)
	local tbRsp =
	{
		Result = IDIP_SUCCESS,
		RetMsg = "ok",
	}
	if nIsMatch == 0 then
		tbRsp.Result = IDIP_PLAYER_NOT_EXIST;
		tbRsp.RetMsg = ErrInValidAccountRoleIdNotMatch;
		self:IDIPDelayResponse(tbRsp.Result, tbRsp, tbRsp.RetMsg, "IDIP_DO_NOTICE_BELL_SUCCESS_REQ", nCmdSequence)
		return
	end

	local pPlayerInfo = KPlayer.GetRoleStayInfo(dwPlayerId);
	if not pPlayerInfo then
		tbRsp.Result = IDIP_PLAYER_NOT_EXIST
		tbRsp.RetMsg = ErrPlayerNotExist
		self:IDIPDelayResponse(tbRsp.Result, tbRsp, tbRsp.RetMsg, "IDIP_DO_NOTICE_BELL_SUCCESS_REQ", nCmdSequence)
		return
	end

	local _, tbRunning = Activity:GetActivityData()
	local tbAct = tbRunning["BeautyPageant"] and tbRunning["BeautyPageant"].tbInst
	if not tbAct then
		tbRsp.Result = IDIP_ACTIVITY_NOT_START
		tbRsp.RetMsg = ErrActivityNotStart
		self:IDIPDelayResponse(tbRsp.Result, tbRsp, tbRsp.RetMsg, "IDIP_DO_VALUE_PRETTY_PINK_REQ", nCmdSequence)
		return
	end

	tbAct:OnSignUp(dwPlayerId);

	TLog("IDIPFLOW", tbReq.AreaId, tbReq.OpenId, 0, 0, tbReq.Serial, tbReq.Source, nCmdId, tbReq.PlatId,
		tbReq.Partition, tbReq.RoleId, 0, "IDIP_DO_NOTICE_BELL_SUCCESS_REQ", (pPlayer and "immediately") or "delay")

	self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_DO_NOTICE_BELL_SUCCESS_REQ", nCmdSequence)
end

function tbIDIPInterface:IDIP_QUERY_CLOTHES_INFO_REQ(nCmdId, tbReq,nCmdSequence)
	Player:DoAccountRoleMatchRequest(tbReq.OpenId, tbReq.RoleId, Transmit.tbIDIPInterface.OnQueryClothesInfoCheckFinish, Transmit.tbIDIPInterface, nCmdId, tbReq,nCmdSequence);
end

function tbIDIPInterface:OnQueryClothesInfoCheckFinish(szAccount, dwPlayerId, nIsMatch,nCmdId, tbReq, nCmdSequence)
	local tbRsp =
	{
		Result = IDIP_SUCCESS,
		RetMsg = "ok",
		ClothesId = 0,
		ItemId = 0,
	}
	if nIsMatch == 0 then
		tbRsp.Result = IDIP_PLAYER_NOT_EXIST;
		tbRsp.RetMsg = ErrInValidAccountRoleIdNotMatch;
		self:IDIPDelayResponse(tbRsp.Result, tbRsp, tbRsp.RetMsg, "IDIP_QUERY_CLOTHES_INFO_REQ", nCmdSequence)
		return
	end

	local pPlayerInfo = KPlayer.GetRoleStayInfo(dwPlayerId);
	if not pPlayerInfo then
		tbRsp.Result = IDIP_PLAYER_NOT_EXIST
		tbRsp.RetMsg = ErrPlayerNotExist
		self:IDIPDelayResponse(tbRsp.Result, tbRsp, tbRsp.RetMsg, "IDIP_QUERY_CLOTHES_INFO_REQ", nCmdSequence)
		return
	end

	local tbEquipInfo = KPlayer.GetInfoFromAsyncData(dwPlayerId);
	
	if tbEquipInfo then
		local tbWeapon = tbEquipInfo[Item.EQUIPPOS_WEAPON]
		local tbArmor = tbEquipInfo[Item.EQUIPPOS_BODY]

		local tbWaiWeapon = tbEquipInfo[Item.EQUIPPOS_WAI_WEAPON]
		local tbWaiArmor = tbEquipInfo[Item.EQUIPPOS_WAIYI]

		if tbWeapon then
			tbRsp.ItemId = tbWeapon.nShowResId
		end

		if tbArmor then
			tbRsp.ClothesId = tbArmor.nShowResId
		end

		if tbWaiWeapon then
			tbRsp.ItemId = tbWaiWeapon.nShowResId
		end
		
		if tbWaiArmor then
			tbRsp.ClothesId = tbWaiArmor.nShowResId
		end
	end

	TLog("IDIPFLOW", tbReq.AreaId, tbReq.OpenId, 0, 0, tbReq.Serial, tbReq.Source, nCmdId, tbReq.PlatId,
		tbReq.Partition, tbReq.RoleId, tbRsp.ClothesId, tbRsp.ItemId, "IDIP_QUERY_CLOTHES_INFO_REQ", (pPlayer and "immediately") or "delay")

	self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_QUERY_CLOTHES_INFO_REQ", nCmdSequence)
end

function tbIDIPInterface:IDIP_DO_SEND_BELL_WIN_REQ(nCmdId, tbReq,nCmdSequence)
	local tbRsp =
	{
		Result 	= IDIP_SUCCESS,
		RetMsg 	= "ok",
	}

	local _, tbRunning = Activity:GetActivityData()
	local tbAct = tbRunning["BeautyPageant"] and tbRunning["BeautyPageant"].tbInst
	if not tbAct then
		tbRsp.Result = IDIP_ACTIVITY_NOT_START
		tbRsp.RetMsg = ErrActivityNotStart
		self:IDIPDelayResponse(tbRsp.Result, tbRsp, tbRsp.RetMsg, "IDIP_DO_VALUE_PRETTY_PINK_REQ", nCmdSequence)
		return
	end

	local nWinnerType = tonumber(tbReq.Type);
	local nFaction = tonumber(tbReq.Job);

	if nFaction <= 0 or nFaction > Faction.MAX_FACTION_COUNT or
	 nWinnerType <= tbAct.WINNER_TYPE.BEGINE or nWinnerType >= tbAct.WINNER_TYPE.MAX then

		tbRsp.Result = IDIP_INVALID_PARAM
		tbRsp.RetMsg = ErrInvalidParam
		self:IDIPDelayResponse(tbRsp.Result, tbRsp, tbRsp.RetMsg, "IDIP_DO_SEND_BELL_WIN_REQ", nCmdSequence)
		return
	end

	tbAct:OnWinnerResult(nWinnerType, tonumber(tbReq.BePartition), tbReq.Name,
				 tonumber(tbReq.RoleId), tbReq.RoleName, nFaction,
				 tonumber(tbReq.ClothesId),  tonumber(tbReq.ItemId));

	TLog("IDIPFLOW", tbReq.AreaId, tbReq.OpenId, nWinnerType, nFaction, tbReq.Serial, tbReq.Source, nCmdId, tbReq.PlatId,
		tbReq.Partition, tbReq.RoleId, tbReq.BePartition, tbReq.RoleName, tbReq.ClothesId, tbReq.ItemId, tbReq.Name, 
		"IDIP_DO_SEND_BELL_WIN_REQ", (pPlayer and "immediately") or "delay")

	self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg, "IDIP_DO_SEND_BELL_WIN_REQ", nCmdSequence)

end

-- 发放自定义家族红包
function tbIDIPInterface:IDIP_DO_FAMILY_RED_PACKET_REQ(nCmdId, tbReq, nCmdSequence)
	Player:DoAccountRoleMatchRequest(tbReq.OpenId, tbReq.RoleId, Transmit.tbIDIPInterface.OnFamilyRedPacketCheckFinish, Transmit.tbIDIPInterface, nCmdId, tbReq, nCmdSequence);
end

function tbIDIPInterface:OnFamilyRedPacketCheckFinish(szAccount, dwPlayerId, nIsMatch, nCmdId, tbReq, nCmdSequence)
	local tbRsp =
		{
			Result 	= IDIP_SUCCESS,
			RetMsg 	= "ok",
		}

	if nIsMatch == 0 then
		tbRsp.Result = IDIP_PLAYER_NOT_EXIST;
		tbRsp.RetMsg = ErrInValidAccountRoleIdNotMatch;
		self:IDIPDelayResponse(tbRsp.Result, tbRsp, tbRsp.RetMsg, "IDIP_DO_FAMILY_RED_PACKET_REQ", nCmdSequence)
		return
	end

	local szRedPacketName = tbReq.RedPacketName
	local nRedPacketId = tonumber(tbReq.RedPacketId)
	local szRedPacketId = tostring(nRedPacketId)
	local nBaseAmount = tonumber(tbReq.BaseAmount)
	local nNum = tonumber(tbReq.Num)

	if not nRedPacketId or nRedPacketId < 0 or szRedPacketId == "" or not nBaseAmount or nBaseAmount <= 0 or not nNum or nNum <= 0 or szRedPacketName == "" then
		tbRsp.Result = IDIP_INVALID_PARAM;
 		tbRsp.RetMsg = ErrInvalidParam;
		self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_DO_FAMILY_RED_PACKET_REQ", nCmdSequence)
		return
	end

	local kinData = Kin:GetKinByMemberId(dwPlayerId)
	if not kinData then
		tbRsp.Result = IDIP_KIN_NOT_FOUND;
		tbRsp.RetMsg = ErrKinNotFound;
		self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_DO_FAMILY_RED_PACKET_REQ", nCmdSequence)
		return
	end

	if not Kin:RedBagIdipAdd(szRedPacketId, dwPlayerId, nBaseAmount, nNum, szRedPacketName, kinData.nKinId) then
		tbRsp.Result = IDIP_EXIST_ID;
 		tbRsp.RetMsg = ErrExistId;
		self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_DO_FAMILY_RED_PACKET_REQ", nCmdSequence)
		return
	end

	TLog("IDIPFLOW", tbReq.AreaId, tbReq.OpenId, 0, 0, tbReq.Serial, tbReq.Source, nCmdId, tbReq.PlatId,
        tbReq.Partition, tbReq.RoleId, 0, "IDIP_DO_FAMILY_RED_PACKET_REQ", "immediately", szRedPacketName, szRedPacketId, nBaseAmount, nNum)

 	self:IDIPDelayResponse(tbRsp.Result, tbRsp, tbRsp.RetMsg, "IDIP_DO_FAMILY_RED_PACKET_REQ", nCmdSequence)
end

-- 删除自定义家族红包 
function tbIDIPInterface:IDIP_DO_DELETE_FAMILY_RED_PACKET_REQ(nCmdId, tbReq, nCmdSequence)
	local tbRsp =
		{
			Result 	= IDIP_SUCCESS,
			RetMsg 	= "ok",
		}

	local szRedPacketId = tostring(tbReq.RedPacketId)
	if szRedPacketId == "" then
		tbRsp.Result = IDIP_INVALID_PARAM;
 		tbRsp.RetMsg = ErrInvalidParam;
		self:IDIPDelayResponse(tbRsp.Result, tbRsp, tbRsp.RetMsg, "IDIP_DO_DELETE_FAMILY_RED_PACKET_REQ", nCmdSequence)
		return
	end

	if not Kin:RedBagIdipRemove(szRedPacketId) then
		tbRsp.Result = IDIP_NO_EXIST_ID;
 		tbRsp.RetMsg = ErrNoExistId;
		self:IDIPDelayResponse(tbRsp.Result, tbRsp, tbRsp.RetMsg, "IDIP_DO_DELETE_FAMILY_RED_PACKET_REQ", nCmdSequence)
		return
	end

	TLog("IDIPFLOW", tbReq.AreaId, tbReq.OpenId, 0, 0, tbReq.Serial, tbReq.Source, nCmdId, tbReq.PlatId,
        tbReq.Partition, 0, 0, "IDIP_DO_DELETE_FAMILY_RED_PACKET_REQ", "immediately", szRedPacketId)

 	self:IDIPDelayResponse(tbRsp.Result, tbRsp, tbRsp.RetMsg,"IDIP_DO_DELETE_FAMILY_RED_PACKET_REQ", nCmdSequence)
end

-- 发送无附件系统个人邮件
function tbIDIPInterface:IDIP_DO_SEND_UNATTACH_MAIL_REQ(nCmdId, tbReq, nCmdSequence)
	Player:DoAccountRoleMatchRequest(tbReq.OpenId, tbReq.RoleId, Transmit.tbIDIPInterface.OnSendUnattchMailCheckFinish, Transmit.tbIDIPInterface, nCmdId, tbReq, nCmdSequence);
end

function tbIDIPInterface:OnSendUnattchMailCheckFinish(szAccount, dwPlayerId, nIsMatch, nCmdId, tbReq, nCmdSequence)
	local tbRsp =
		{
			Result 	= IDIP_SUCCESS,
			RetMsg 	= "ok",
		}

	if nIsMatch == 0 then
		tbRsp.Result = IDIP_PLAYER_NOT_EXIST;
		tbRsp.RetMsg = ErrInValidAccountRoleIdNotMatch;
		self:IDIPDelayResponse(tbRsp.Result, tbRsp, tbRsp.RetMsg, "IDIP_DO_SEND_UNATTACH_MAIL_REQ", nCmdSequence)
		return
	end

	if not KPlayer.GetRoleStayInfo(dwPlayerId) then
		tbRsp.Result = IDIP_PLAYER_NOT_EXIST;
		tbRsp.RetMsg = ErrPlayerNotExist;
		self:IDIPDelayResponse(tbRsp.Result, tbRsp, tbRsp.RetMsg, "IDIP_DO_SEND_UNATTACH_MAIL_REQ", nCmdSequence)
		return
	end

	local szTitle = tbReq.MailTitle
	local szContent = tbReq.MailContent
	local szFrom = tbReq.Sender

	local tbMail = {};
	tbMail.To = dwPlayerId;
	tbMail.Title = szTitle;
	tbMail.Text = szContent;
	tbMail.From = (szFrom == "" and "系統" or szFrom) 
	tbMail.nLogReazon = Env.LogWay_IdipSendUnattchMail;
	Mail:SendSystemMail(tbMail)

	TLog("IDIPFLOW", tbReq.AreaId, tbReq.OpenId, 0, 0, tbReq.Serial, tbReq.Source, nCmdId, tbReq.PlatId,
        tbReq.Partition, tbReq.RoleId, 0, "IDIP_DO_SEND_UNATTACH_MAIL_REQ", "immediately", szTitle, szContent, szFrom)

 	self:IDIPDelayResponse(tbRsp.Result, tbRsp, tbRsp.RetMsg, "IDIP_DO_SEND_UNATTACH_MAIL_REQ", nCmdSequence)
end

function tbIDIPInterface:IDIP_DO_EXTERNAL_FRIEND_REQUEST_REQ(nCmdId, tbReq, nCmdSequence)
	Player:DoAccountRoleMatchRequest(tbReq.OpenId, tbReq.RoleId, Transmit.tbIDIPInterface.ExternalFriendReqCheckFinish, Transmit.tbIDIPInterface, nCmdId, tbReq, nCmdSequence);
end

function tbIDIPInterface:ExternalFriendReqCheckFinish(szAccount, dwPlayerId, nIsMatch, nCmdId, tbReq, nCmdSequence)
	local tbRsp =
		{
			Result 	= IDIP_SUCCESS,
			RetMsg = "ok",
		}

	if nIsMatch == 0 then
		tbRsp.Result = IDIP_PLAYER_NOT_EXIST;
		tbRsp.RetMsg = ErrInValidAccountRoleIdNotMatch;
		self:IDIPDelayResponse(tbRsp.Result, tbRsp, tbRsp.RetMsg, "IDIP_DO_EXTERNAL_FRIEND_REQUEST_REQ", nCmdSequence)
		return
	end

	if not KPlayer.GetRoleStayInfo(tbReq.AskedRoleId) then
		tbRsp.Result = IDIP_OTHER_PLAYER_NO_EXIST;
		tbRsp.RetMsg = ErrOtherPlayerNoExist;
		self:IDIPDelayResponse(tbRsp.Result, tbRsp, tbRsp.RetMsg, "IDIP_DO_EXTERNAL_FRIEND_REQUEST_REQ", nCmdSequence)
		return
	end

	local bRet, szMsg = FriendShip:RequestAddFriend(dwPlayerId, tbReq.AskedRoleId)
	if not bRet then
		tbRsp.Result = IDIP_INTERNAL_ERR;
		tbRsp.RetMsg = szMsg;
		self:IDIPDelayResponse(tbRsp.Result, tbRsp, tbRsp.RetMsg, "IDIP_DO_EXTERNAL_FRIEND_REQUEST_REQ", nCmdSequence)
		return
	end

	TLog("IDIPFLOW", tbReq.AreaId, tbReq.OpenId, 0, 0, tbReq.Serial, tbReq.Source, nCmdId, tbReq.PlatId,
		tbReq.Partition, tbReq.RoleId, 0, "IDIP_DO_EXTERNAL_FRIEND_REQUEST_REQ", "immediately", tostring(tbReq.AskedRoleId))

	self:IDIPDelayResponse(tbRsp.Result, tbRsp, tbRsp.RetMsg, "IDIP_DO_EXTERNAL_FRIEND_REQUEST_REQ", nCmdSequence)
end

function tbIDIPInterface:IDIP_DO_EXTERNAL_FAMILY_REQUEST_REQ(nCmdId, tbReq, nCmdSequence)
	Player:DoAccountRoleMatchRequest(tbReq.OpenId, tbReq.RoleId, Transmit.tbIDIPInterface.ExternalFamilyReqCheckFinish, Transmit.tbIDIPInterface, nCmdId, tbReq, nCmdSequence);
end

function tbIDIPInterface:ExternalFamilyReqCheckFinish(szAccount, dwPlayerId, nIsMatch, nCmdId, tbReq, nCmdSequence)
	local tbRsp =
		{
			Result 	= IDIP_SUCCESS,
			RetMsg = "ok",
		}

	local pStayInfo = KPlayer.GetRoleStayInfo(dwPlayerId)
	if nIsMatch == 0 or not pStayInfo then
		tbRsp.Result = IDIP_PLAYER_NOT_EXIST;
		tbRsp.RetMsg = ErrInValidAccountRoleIdNotMatch;
		self:IDIPDelayResponse(tbRsp.Result, tbRsp, tbRsp.RetMsg, "IDIP_DO_EXTERNAL_FAMILY_REQUEST_REQ", nCmdSequence)
		return
	end

	local kinData = Kin:GetKinById(tonumber(tbReq.FamilyId));
	if not kinData then
		tbRsp.Result = IDIP_INVALID_PARAM;
		tbRsp.RetMsg = ErrInvalidParam;
		self:IDIPDelayResponse(tbRsp.Result, tbRsp, tbRsp.RetMsg, "IDIP_DO_EXTERNAL_FAMILY_REQUEST_REQ", nCmdSequence)
		return
	end

	if pStayInfo.dwKinId ~= 0 then
		tbRsp.Result = IDIP_INTERNAL_ERR;
		tbRsp.RetMsg = "已有幫派";
		self:IDIPDelayResponse(tbRsp.Result, tbRsp, tbRsp.RetMsg, "IDIP_DO_EXTERNAL_FAMILY_REQUEST_REQ", nCmdSequence)
		return
	end

	if pStayInfo.nLevel < Kin.Def.nLevelLimite then
		tbRsp.Result = IDIP_INTERNAL_ERR;
		tbRsp.RetMsg = "等級不足";
		self:IDIPDelayResponse(tbRsp.Result, tbRsp, tbRsp.RetMsg, "IDIP_DO_EXTERNAL_FAMILY_REQUEST_REQ", nCmdSequence)
		return
	end

	local isProbation = Kin:CheckIsProbation(pStayInfo.nLevel);
	local bRet, szMsg = kinData:Available2Join(isProbation);
	if not bRet then
		tbRsp.Result = IDIP_INTERNAL_ERR;
		tbRsp.RetMsg = szMsg;
		self:IDIPDelayResponse(tbRsp.Result, tbRsp, tbRsp.RetMsg, "IDIP_DO_EXTERNAL_FAMILY_REQUEST_REQ", nCmdSequence)
		return
	end

	pStayInfo.GetVipLevel = function ()
		return pStayInfo.nVipLevel
	end

	kinData:Add2ApplyerList(pStayInfo);

	TLog("IDIPFLOW", tbReq.AreaId, tbReq.OpenId, 0, 0, tbReq.Serial, tbReq.Source, nCmdId, tbReq.PlatId,
		tbReq.Partition, tbReq.RoleId, 0, "IDIP_DO_EXTERNAL_FAMILY_REQUEST_REQ", "immediately", tostring(tbReq.FamilyId))

 	self:IDIPDelayResponse(tbRsp.Result, tbRsp, tbRsp.RetMsg, "IDIP_DO_EXTERNAL_FAMILY_REQUEST_REQ", nCmdSequence)
end

function tbIDIPInterface:IDIP_QUERY_FAMILY_LIST_REQ(nCmdId, tbReq, nCmdSequence)
	local tbRsp =
	{
		Result = IDIP_SUCCESS,
		RetMsg = "ok",

		FamilyList_count = 0,
		FamilyList = {},
		TotalPageNo = 0,
	}

	local nPage = tonumber(tbReq.PageNo) or 0

	local nNumPerPage = 50
	local nStartNum = nPage * nNumPerPage + 1
	local nEndNum = (nPage + 1) * nNumPerPage
	if Kin.KinData and next(Kin.KinData) then
		local nCount = 1;
		for nKinId,tbKinData in pairs(Kin.KinData) do
			if nCount >= nStartNum and nCount <= nEndNum then
				table.insert(tbRsp.FamilyList, {FamilyId=nKinId, FamilyName=tbKinData.szName});
			end
			nCount = nCount + 1;
		end
		tbRsp.FamilyList_count = Lib:CountTB(tbRsp.FamilyList);
		tbRsp.TotalPageNo = math.ceil(Lib:CountTB(Kin.KinData) / nNumPerPage);
	end

	TLog("IDIPFLOW", tbReq.AreaId, tbReq.OpenId, 0,0, tbReq.Serial, tbReq.Source, nCmdId, tbReq.PlatId,
	        tbReq.Partition, tbReq.RoleId,0, "IDIP_QUERY_FAMILY_LIST_REQ",tbReq.PageNo)

	self:IDIPDelayResponse(tbRsp.Result,tbRsp,tbRsp.RetMsg,"IDIP_QUERY_FAMILY_LIST_REQ",nCmdSequence)
end

