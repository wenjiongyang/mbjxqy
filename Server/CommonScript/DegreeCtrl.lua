Require("CommonScript/Recharge/Recharge.lua")

DegreeCtrl.tbSetting = {
	--					次数变量	时间变量	重置周期	时刻	 默认次数			描述
	--					(变量组, Id)			Day/Week/Month
	Revenge 			= { {5,  1}, {5,   2},	"Day", 		"4:00",		10,				"復仇"},
	Catch				= { {5,  6}, {5,   7},	"Day", 		"4:00",		5,				"免費抓捕次數"},
	CatchBuy			= { {5,  8}, {5,   9},	"Day", 		"4:00",		20,				"購買抓捕次數"},
	RankBattle			= { {7,  1}, {7,   2},  "", 		"",			10,				"武神殿挑戰次數"},
	RankBattleBuy		= { {7,  3}, {7,   4},  "Day", 		"4:00",		0,				"武神殿購買次數"},
	Debris				= { {10, 3}, {10,  4},  "Day", 		"10:00",	10,				"碎片搶奪次數"},
	DebrisBuy			= { {10, 5}, {10,  6},  "Day", 		"10:00",	0,				"碎片搶奪購買次數"},
	RandomFuben			= { {9,  1}, {9,   2},	"Day", 		"4:00",		2,				"隨機副本次數"},
	Battle				= { {11, 1}, {11,  2},	"Day", 		"4:00",		1,				"戰場次數"},
	BattleAdd			= { {11, 3}, {11,  4},	"Day", 		"4:00",		1,				"戰場增加次數"}, --使用道具增加，原来的购买已没
	DungeonFubenInvited = { {12, 1}, {12,  2},	"Day", 		"4:00",		2,				"地宮被邀請次數"},
	MapExplore		    = { {12, 3}, {12,  4},	"Day", 		"4:00",		10,				"地圖探索次數"},
	MapExploreBuy	    = { {12, 5}, {12,  6},	"Day", 		"4:00",		0,				"地圖探索次數購買"},
	PunishTask			= { {16, 1}, {16,  2},	"Day", 		"4:00",		5,				"懲惡的次數"},
	PunishTaskBuy		= { {17, 1}, {17,  2},	"Day", 		"4:00",		0,			    "購買懲惡次數"},
	HeroChallenge		= { {43, 6}, {43,  7},	"Day", 		"4:00",		2,			    "英雄會挑戰次數"},
	Pray 				= { {14,  7}, {14,  8},	"Day", 		"4:00",		1,				"祈福次數"},
	PrayBuy				= { {14,  9}, {14,  10},"Day", 		"4:00",		4,				"購買祈福次數"},
	ChuangGong			= { {23,  1}, {23,  2},	"Day", 		"4:00",		2,				"接受傳功次數"}, 						-- 获取玩家所有传功和被传次数看ChuangGong:GetDegree接口
	ChuangGongBuy		= { {23,  3}, {23,  4},	"Day", 		"4:00",		0,				"接受傳功次數"},
	ChuangGongSend		= { {23,  5}, {23,  6},	"Day", 		"4:00",		1,				"發起傳功次數"},
	QunYingHuiDay       = { {24,  1}, {24,  2},	"Day", 		"0:00",		6,				"群英會比賽日次數"},
	TeamFuben 			= { {13,  1}, {13,	2},	"Day", 		"4:00",		2,				"組隊副本次數"},
	AdventureFuben      = { {31,  1}, {31, 	2}, "Day", 		"4:00", 	2, 				"奇遇秘境次數"},
	DonationCount       = { {32,  1}, {32, 	2}, "Day", 		"4:00", 	0, 				"幫派捐獻次數"},
	KinNestDay      	= { {35,  1}, {35,  2},	"Day", 		"0:00",		4,				"幫派巢穴獎勵"},
	ActivityQuestion    = { {28,  15}, {28, 16},"Day", 		"4:00", 	1, 				"每日答題次數"},
	CommerceTask    	= { {33,  1}, {33, 2}, 	"Day", 		"4:00", 	1, 				"商會任務次數"},
	KinRobReward        = { {36,  1}, {36, 	2}, "Day", 		"00:00", 	4, 				"幫派盜賊獎勵"},
	KinTask     		= { {40,  1}, {40, 	2}, "Day", 		"4:00", 	10, 			"幫派任務"},
	--XiuLianDan     		= { {92,  1}, {92, 	2}, "Day", 		"4:00", 	1, 				"修炼丹的次数"},
	XinDeBook     		= { {114,  1}, {114, 2}, "Day", 	"00:00", 	10, 			"心得書的次數"},
	WhiteTigerFuben    	= { {46,  1}, {46, 	2}, "Day", 		"4:00", 	1, 				"白虎堂次數"},
	PublicChatCount    	= { {50,  1}, {50, 	2}, "Day", 		"4:00", 	0, 				"世界聊天次數"},
	CrossChatCount    	= { {50,  4}, {50, 	5}, "Day", 		"4:00", 	0, 			"主播聊天次數"},
	DuoBaoZeiCount    	= { {81,  1}, {81, 	2}, "Day", 		"4:00", 	50, 			"奪寶賊每天可擊殺有獎勵數量"},
	ChuangGongAdd    	= { {83,  1}, {83, 	2}, "Day", 		"4:00", 	1, 				"增加傳功次數道具的使用個數"},
	Idioms  	       	= { {119,  1}, {119,2}, "Day", 		"4:00", 	2, 				"成語接龍副本次數"},
	DefendFuben  	   	= { {120,  1}, {120,2}, "Day", 		"4:00", 	1, 				"守衛名俠副本次數"},
	DaXueZhangAdd     	= { {122,  3}, {122, 4}, "Day", 	"4:00", 	1, 				"打雪仗的增加次數"},
	InDifferBattle      = { {118, 1}, {118,  2},"Day", 		"4:00",		1,				"心魔幻境次數"}, 
	IndifferAdd         = { {118, 4}, {118,  5},"Day", 		"4:00",		1,				"心魔增加次數"}, --使用道具增加，原来的购买已没
	SnowmanActAward     = { {123, 1}, {123,  2},"Day", 		"4:00",		1,				"堆雪人活動領取禮盒次數"}, 
	Muse     			= { {131, 1}, {131,  2},"Day", 		"4:00",		1,				"冥想次數"}, 
	PlantCure     		= { {133, 1}, {133,  2},"Day", 		"4:00",		1,				"植物養護次數"}, 
	PlantHelpCure   	= { {133, 3}, {133,  4},"Day", 		"4:00",		10,				"協助養護次數"}, 
}
local tbSetting = DegreeCtrl.tbSetting;

DegreeCtrl.tbSetting = tbSetting;

--次数购买设置
DegreeCtrl.tbBuyCountSetting =
{	--					购买次数限制		花费钱类型		花钱钱数

	Catch  			= {"CatchBuy",			"Gold",			20 },
	Debris 	        = {"DebrisBuy",			"Gold",			{{5, 5}, {10, 10}, {15, 20}, {20, 30}, {25, 45}, {30, 60}, {35, 80}, {40, 100}}},  --已完成
	-- Battle 			= {"BattleBuy",			"Gold",			{{1, 80}}},
	MapExplore      = {"MapExploreBuy",		"Gold",			{{5, 4}, {10, 12}, {15, 24}, {20, 40}}}, --每次购买数量是固定的，0-5次购买单价4，6-10单价12，...
	PunishTask  	= {"PunishTaskBuy",		"Gold",			{{5, 3}, {10,  9}, {15, 18}, {20, 30}}},
	ChuangGong 		= {"ChuangGongBuy",		"Gold",			{{1, 80},{2, 120}, {3, 160},{4, 200}}},
	MoneyTreeFree  	= {"MoneyTreeExt",		"Gold",			{{10, 10}, {20, 15}, {200,  20}}},
	RankBattle  	= {"RankBattleBuy",		"Gold",			{{5, 5}, {10,  15}, {15, 30}, {20, 50}}},
}
local tbBuyCountSetting = DegreeCtrl.tbBuyCountSetting;

DegreeCtrl.tbAddSetting =
{
	--			每次增加的CD	不增加的时间段，第一个值必须小于第二个值
	RankBattle = {60 * 60 * 4, 		},--{0, 10 * 3600}},
}
local tbAddSetting = DegreeCtrl.tbAddSetting;

function DegreeCtrl:Init()
	local tbCols = {}
	local szColType = "s"
	for i = 0, Recharge.nMaxVip do
		table.insert(tbCols, tostring(i))
		szColType = szColType .. "d"
	end

	self.tbVipExSetting = LoadTabFile(
	    "Setting/DegreeCtrl/VipDegree.tab",  --VIP 额外次数
	    szColType, "Degree",
	    {"Degree", unpack(tbCols) });
end

DegreeCtrl:Init()


--先采用lua table配置方式，有必要再改到用tab文件配置。
--tbSetting = LoadTabFile("setting/degreectrl.csv", "Key", {"Key:s", "Schedule:s", "Degree:d", "MaxDegree:d", "Description:s"});

function DegreeCtrl:GetDegreeDesc(szName)
	if tbSetting[szName] then
		return tbSetting[szName][6];
	end
end

function DegreeCtrl:_GetAdditional(pPlayer, szName)
	if szName=="ChuangGong" then
		local tbMember = Kin:GetMemberData(pPlayer.dwID)
		if tbMember and tbMember.nCareer==Kin.Def.Career_New then
			return 2
		end
	end
	return 0
end

function DegreeCtrl:GetMaxDegree(szName, pPlayer)
	local nValue = 0
	if tbSetting[szName] then
		if not self.tbVipExSetting[szName] then
			nValue = tbSetting[szName][5];
		else
			if not pPlayer then
				Log(debug.traceback(), szName)
				return
			end
			local nVipLevel = pPlayer.GetVipLevel()
			nValue = tbSetting[szName][5] + self.tbVipExSetting[szName][tostring(nVipLevel)] ;
		end
	end

	nValue = nValue + self:_GetAdditional(pPlayer, szName)

	return nValue
end

--获取想要更多次数时应该达成的vip等级 ,目前只是购买次数用到
function DegreeCtrl:GetNextVipDegree(szName, pPlayer)
	local tbInfo = self.tbVipExSetting[szName]
	if not tbInfo then
		return
	end

	local nCurVipLevel = pPlayer.GetVipLevel()

	local nCurDegree = tbInfo[tostring(nCurVipLevel)];
	for i = nCurVipLevel + 1, Recharge.nMaxVip do
		local nDegree = tbInfo[tostring(i)];
		if nDegree > nCurDegree then
			return i;
		end
	end
end

function DegreeCtrl:GetDegreeSecond(nDataTime, tbUnCountTime)
	local nUnCountBegin, nUnCountEnd = 0, 0;

	if tbUnCountTime then
		nUnCountBegin, nUnCountEnd = unpack(tbUnCountTime);
	end

	local nSecondPerDay = 24 * 3600 - nUnCountEnd + nUnCountBegin;
	local nLocalDay = Lib:GetLocalDay(nDataTime);

	local nCurDaySecond = Lib:GetLocalDayTime(nDataTime) % (24 * 3600);
	if nCurDaySecond > nUnCountBegin and nCurDaySecond < nUnCountEnd then
		nCurDaySecond = nUnCountBegin;
	elseif nCurDaySecond > nUnCountBegin then
		nCurDaySecond = nCurDaySecond + nUnCountBegin - nUnCountEnd;
	end

	return nLocalDay * nSecondPerDay + nCurDaySecond;
end

function DegreeCtrl:GetTimeByDegreeSecond(nDegreeSecond, tbUnCountTime)
	local nUnCountBegin, nUnCountEnd = 0, 0;

	if tbUnCountTime then
		nUnCountBegin, nUnCountEnd = unpack(tbUnCountTime);
	end

	local nSecondPerDay = 24 * 3600 - nUnCountEnd + nUnCountBegin;
	local nCurDaySecond = nDegreeSecond % nSecondPerDay;

	if nCurDaySecond >= nUnCountBegin then
		nCurDaySecond = nCurDaySecond + nUnCountEnd - nUnCountBegin;
	end

	return math.floor(nDegreeSecond / nSecondPerDay) * 24 * 3600 + nCurDaySecond - Lib:GetGMTSec();
end

function DegreeCtrl:GetNextAddTime(pPlayer, szName)
	local nDegree, nLastAddTime = self:GetDegree(pPlayer, szName)
	if nLastAddTime and tbAddSetting[szName] then
		if nDegree < self:GetMaxDegree(szName, pPlayer) then
			local nAddCDTime, tbUnCountTime = unpack(tbAddSetting[szName]);
			local nDegreeSecond = self:GetDegreeSecond(nLastAddTime, tbUnCountTime);
			nDegreeSecond = nDegreeSecond + nAddCDTime;

			return self:GetTimeByDegreeSecond(nDegreeSecond, tbUnCountTime)
		end
	end
end

function DegreeCtrl:GetUpdateTime(pPlayer, szName)
	local tbInfo = tbSetting[szName]
	if tbInfo then
		local nTimeGroup, nTimeId = unpack(tbInfo[2]);
		return pPlayer.GetUserValue(nTimeGroup, nTimeId)
	end
end

-- 返回现在的次数，返回空表示没配置
function DegreeCtrl:GetDegree(pPlayer, szName)
	if tbAddSetting[szName] and tbSetting[szName] then
		-- 时间累加次数
		local tbInfo = tbSetting[szName];
		local nAddCDTime, tbUnCountTime = unpack(tbAddSetting[szName]);
		local nGroup, nId = unpack(tbInfo[1]);
		local nTimeGroup, nTimeId = unpack(tbInfo[2]);
		local nMaxDegree = self:GetMaxDegree(szName, pPlayer)

		local nLastTime = pPlayer.GetUserValue(nTimeGroup, nTimeId);
		local nCurDegree = nMaxDegree - pPlayer.GetUserValue(nGroup, nId) --已经使用的次数，每花一次＋1 ，加次数减 -1 ,超默认最大时会出现负

		if nCurDegree >= nMaxDegree then
			return nCurDegree;
		end

		local nCurTime = GetTime();
		local nLastSecond = self:GetDegreeSecond(nLastTime, tbUnCountTime);
		local nCurSecond = self:GetDegreeSecond(nCurTime, tbUnCountTime);
		local nAddCount = math.floor((nCurSecond - nLastSecond) / nAddCDTime);
		local nLastAddTime = self:GetTimeByDegreeSecond(nCurSecond - ((nCurSecond - nLastSecond) % nAddCDTime), tbUnCountTime)

		return math.min(nMaxDegree, nCurDegree + nAddCount), nLastAddTime;
	elseif tbSetting[szName] then
		local tbInfo = tbSetting[szName];

		local nGroup, nId = unpack(tbInfo[1]);
		local nTimeGroup, nTimeId = unpack(tbInfo[2]);

		local nMaxDegree = self:GetMaxDegree(szName, pPlayer)

		local nLastTime = pPlayer.GetUserValue(nTimeGroup, nTimeId);
		if not nLastTime or nLastTime == 0 then
			return nMaxDegree;
		end

		local szFunction = "GetLocal"..tbInfo[3];
		local nCurTime = GetTime();
		local nClock = tbInfo[4];
		if nClock then
			local nParseTodayTime = Lib:ParseTodayTime(nClock);
			nCurTime = nCurTime - nParseTodayTime;
			nLastTime = nLastTime - nParseTodayTime;
		end

		local nCurTimeBlock = Lib[szFunction](Lib, nCurTime);
		local nLastTimeBlock = Lib[szFunction](Lib, nLastTime);

		local nCostedDegree = pPlayer.GetUserValue(nGroup, nId) --已经使用的次数，每花一次＋1 ，加次数减 -1 ,超默认最大时会出现负
		if nCurTimeBlock == nLastTimeBlock then
			return math.max(nMaxDegree - nCostedDegree, 0); --目前见习成员最大传功次数变化可能会导致负
		else
			return math.max(nMaxDegree, nMaxDegree - nCostedDegree); --玩家昨天有买次数超过每天额定次数时
		end
	end
end

function DegreeCtrl:SetDegree(pPlayer, szName, nDegree, nTime)
	local tbInfo = tbSetting[szName];
	if not tbInfo then
		return false
	end

	local nGroup, nId = unpack(tbInfo[1]);
	local nTimeGroup, nTimeId = unpack(tbInfo[2]);

	pPlayer.SetUserValue(nGroup, nId, nDegree); --花掉的次数
	pPlayer.SetUserValue(nTimeGroup, nTimeId, nTime);
	Log(string.format("DegreeCtrl:SetDegree pPlayer:%d, szName:%s, nDegree:%d, nTime:%d", pPlayer.dwID, szName, nDegree, nTime))
	return true;
end

function DegreeCtrl:ReduceDegree(pPlayer, szName, nDegree)
	local nCurDegree, nLastAddTime =  self:GetDegree(pPlayer, szName)
	if not nCurDegree or nCurDegree < nDegree then
		return false;
	end
	local nCurTime = GetTime();
	if tbAddSetting[szName] then
		local nMaxDegree = self:GetMaxDegree(szName, pPlayer)
		if nCurDegree < nMaxDegree and nLastAddTime then
			nCurTime = nLastAddTime
		end
	end
	return self:SetDegree(pPlayer, szName, self:GetMaxDegree(szName, pPlayer) - nCurDegree + nDegree, nCurTime)
end

function DegreeCtrl:AddDegree(pPlayer, szName, nDegree)
	local nCurDegree, nLastAddTime =  self:GetDegree(pPlayer, szName)
	local nCurTime = GetTime();
	if tbAddSetting[szName] then
		local nMaxDegree = self:GetMaxDegree(szName, pPlayer)
		if nCurDegree < nMaxDegree and nLastAddTime then
			nCurTime = nLastAddTime
		end
	end
	return self:SetDegree(pPlayer, szName, self:GetMaxDegree(szName, pPlayer) - nCurDegree - nDegree, nCurTime)
end

function DegreeCtrl:GetBuyCountInfo(szName)
	return tbBuyCountSetting[szName]
end


function DegreeCtrl:BuyCountCostPrice(pPlayer, szName, nDegree)
	local tbInfo = tbBuyCountSetting[szName]
	local szBuyDegree, szMoneyType, nMoney = unpack(tbInfo)
	if type(nMoney) == "number" then
		return szBuyDegree, szMoneyType, nMoney * nDegree, nMoney
	end

	local nHasBuy = self:GetMaxDegree(szBuyDegree, pPlayer) - self:GetDegree(pPlayer, szBuyDegree) --单单是买次数的判断就好了，
	local nToDegree = nHasBuy + nDegree

	local nTotalPrice = 0
	for i,v in ipairs(nMoney) do
		local nMaxCount, nPrice = unpack(v)
		if nHasBuy <= nMaxCount then
			local nBuy = math.min(nMaxCount, nToDegree) - nHasBuy
			nTotalPrice = nTotalPrice + nPrice * nBuy
			nHasBuy = nHasBuy + nBuy
			if nHasBuy >= nToDegree then
				break;
			end
		end
	end
	return szBuyDegree, szMoneyType, nTotalPrice
end


---买对应的就可
function DegreeCtrl:BuyCount(pPlayer, szName, nDegree)
	if nDegree < 1 then
		return false;
	end

	local tbInfo = tbBuyCountSetting[szName]
	if not tbInfo then
		return false;
	end

	local szBuyDegree, szMoneyType, nCost = DegreeCtrl:BuyCountCostPrice(pPlayer, szName, nDegree)
	local nCurDegree =  self:GetDegree(pPlayer, szBuyDegree)
	if not nCurDegree or nCurDegree < nDegree then
		pPlayer.CenterMsg("您今天的購買次數已經用完了");
		return false;
	end

	local tbDegInfo = self.tbSetting[szName][1]
	local nLogReason2 = tbDegInfo[1] * 1000 + tbDegInfo[2];
	if szMoneyType ~= "Gold" then
		if not DegreeCtrl:ReduceDegree(pPlayer, szBuyDegree, nDegree) then
			pPlayer.CenterMsg("您今天的購買次數已經用完了");
			return false;
		end

		if not pPlayer.CostMoney(szMoneyType, nCost, Env.LogWay_DegreeCtrl, nLogReason2) then
			pPlayer.CenterMsg("您的錢不足了哦")
			return false;
		end

		DegreeCtrl:AddDegree(pPlayer, szName, nDegree);
		pPlayer.CallClientScript("me.BuyTimesSuccess");
		return true;
	end

		-- CostGold谨慎调用, 调用前请搜索 _LuaPlayer.CostGold 查看使用说明, 它处调用时请保留本注释
	local bRet = pPlayer.CostGold(nCost, Env.LogWay_DegreeCtrl, nLogReason2,
					function (nPlayerId, bSuccess, szBilloNo, szBuyDegree, nDegree, szName)
						local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
						if not pPlayer then
							return false, "購買次數中途, 您離線了";
						end

						if not bSuccess then
							return false, "支付失敗請稍後再試";
						end

						if not DegreeCtrl:ReduceDegree(pPlayer, szBuyDegree, nDegree) then
							return false, "您今天的購買次數已經用完了";
						end

						DegreeCtrl:AddDegree(pPlayer, szName, nDegree);
						pPlayer.CallClientScript("me.BuyTimesSuccess");
						return true;
					end, szBuyDegree, nDegree, szName);
	return bRet;
end

--获取对应活动参加的次数，不即时更新数据。目前仅供前日补领功能使用
function DegreeCtrl:GetJoinCount(pPlayer, szName)
	local tbInfo = tbSetting[szName]
	if not tbInfo then
		return 999
	end

	local nGroup, nId = unpack(tbInfo[1])
	local nCostedDegree = pPlayer.GetUserValue(nGroup, nId) --已经使用的次数，每花一次＋1 ，加次数减 -1 ,超默认最大时会出现负
	return math.max(nCostedDegree, 0)
end