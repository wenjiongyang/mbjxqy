
ScriptData.tbData = ScriptData.tbData or {};
ScriptData.tbModifySave = ScriptData.tbModifySave or {}

-- 警告：ScriptData不是用来存储玩家相关数据的，
-- 所以不要出现以玩家ID为索引，等相似情况的出现
-- 如果无法确认是否可以使用，可以找华仔确认 ！！！
ScriptData.tbUseScriptDataDef =
{
	["dwServerCreateTime"]   = 1,
	["TimeFrame"]            = 1,
	["nNextKinId"]           = 1;
	["HonorLevelRank"]       = 1,
	["Boss"]                 = 1,
	["GlobalAuction"]        = 1,
	["PersonAuctionPool"]    = 1,
	["FactionBattle"]        = 1,
	["SupplementAward"]      = 1,
	["KinOpenSrvStatus"]     = 1,
	["DomainBattle"]         = 1,
	["RankActivity"]         = 1,
	["ActivityData"]         = 1,
	["WTF_KinPrestige"]      = 1,
	["CollectionSystem"]     = 1,
	["HuaShanLunJianData"]   = 1,
	["LunJianFightTeam"]     = 1,
	["HSLJGuessing"]         = 1,
	["HSLJPlayerStatue"]     = 1,
	["TradeNo"]              = 1,
	["NewPackageGift"]       = 1,
	["NewPackageGift_Sub"]   = 1,
	["TSDismissing"]         = 1,				-- 师徒，等待解除中
	["NewInformation"]       = 1,
	["ChatFilterText"]       = 1,				-- 聊天，动态过滤的敏感词
	["CombineServer"]        = 1,				-- 合服标志，用于判断是否为和服后首次启动
	["ChouJiangBase"]        = 1,				-- 抽奖控制
	["IDIPInterfaceAuction"] = 1,
	["KinLastActivityDaily"] = 1,
	["SwornFriendsMaxSlot"]  = 1,				-- 结拜使用的最大槽数
	["GatherBox"]            = 1,				-- 家族庆典相关活动数据
	["BiWuZhaoQin"]          = 1,				-- 比武招亲
	["WishActMain"]          = 1, 				-- 许愿活动数据
	["MaxSlots"]             = 1,				-- 存储分表数据当前的最大槽数, key = max slot
	["ServerPcuInfo"]        = 1,
	["ArborDayCureAct"]      = 1,
	["CardPickSchedule"]     = 1,				-- 十连抽排期表
	["RedPointCommunity"]    = 1, 				-- 平台红点设置
	["MSSoldPrice"]          = 1,
	["BeautyPageantAct"]     = 1,				-- 武林第一美女
	["NpcLoveToken"]         = 1,				-- 代言人比武招亲
	["FathersDay_Act"]       = 1,				-- 父亲节植树
	["RedBagNoKinDelay"]     = 1,				-- 红包，无家族延迟发放
	["WuLinDaHuiData"]       = 1,				-- 武林大会
	["HonorMonthRank"]       = 1,   			-- 武林荣誉月榜
	["ActHonorLevelRank"]    = 1,  				-- 冲头衔活动
	["CrossBossLeaderKin"]   = 1,  				-- 跨服名将的积分
	["LotteryRecord"]	     = 1,				-- 不参与抽奖的数据

	["WeddingDismissing"]	 = 1,				-- 结婚，等待离婚中
	["WWeddingSchedule"] 		 = 1,  				-- 结婚

	["JingMai"]				= 1,				-- 经脉
}

function ScriptData:AddDef(szKey)
	self.tbUseScriptDataDef[szKey] = 1;
end

function ScriptData:Load(szKey, value)
	self.tbData[szKey] = value;
end

function ScriptData:Save()
	for szKey, value in pairs(self.tbData) do
		if not SaveScriptData(szKey, value) then
			Log("ScriptData:Save ERROR:", szKey);
			Log(debug.traceback());
		end
	end
end

function ScriptData:GetValue(szKey)
	if not self.tbUseScriptDataDef[szKey] then
		assert(false, "use ScriptData need define in ServerScript/Common/ScriptData.lua  " .. szKey);
		return;
	end

	if not self.tbData[szKey] then
		self.tbData[szKey] = {};
	end

	return self.tbData[szKey];
end

function ScriptData:SaveValue(szKey, value)
	if not self.tbUseScriptDataDef[szKey] then
		assert(false, "use ScriptData need define in ServerScript/Common/ScriptData.lua  " .. szKey);
		return;
	end
	self.tbData[szKey] = value;
end

function ScriptData:SaveAtOnce(szKey, value)
	assert(value ~= nil);

	self:SaveValue(szKey, value);
	if not SaveScriptData(szKey, value) then
		Log("ScriptData:SaveAtOnce ERROR:", szKey);
		Log(debug.traceback());
	end
end

function ScriptData:AddModifyFlag(szKey)
	self.tbModifySave[szKey] = true
end

function ScriptData:CheckAndSave()
	for szKey, _ in pairs(self.tbModifySave) do
		if self.tbData[szKey] then
			self:SaveAtOnce(szKey, self.tbData[szKey])
		end
	end
	self.tbModifySave = {};
end

