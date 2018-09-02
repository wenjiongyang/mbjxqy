RankActivity.MAX_RANK_LEVEL_COUNT = 100 									-- 前N个玩家达到等级有奖励
RankActivity.LEVEL_RANK_REWARD_LEVEL    = 49 							-- 需达到的等级
RankActivity.tbRankLevelReward = { 										-- 等级排名奖励
	[1] = {1, {{"Item", 1378, 1}, {"AddTimeTitle", 5060, 30*24*60*60}}}, 		-- N名以下（包括N名）的奖励
	[2] = {10,  {{"Gold", 1000}, {"AddTimeTitle", 5061, 30*24*60*60}}},
	[3] = {100, {{"Gold", 300},  {"AddTimeTitle", 5062, 30*24*60*60}}},
} 					

RankActivity.RANK_LEVEL_INVALID_TIME = 2*24*60*60 						-- 等级排名最新消息过期时间
RankActivity.OPEN_SERVER_RANK_LEVEL_INVALID_TIME = 30*24*60*60 			-- 开服推送等级排名最新消息过期时间

RankActivity.MAX_NEW_INFO_COUNT = 10 									-- 需要在界面中展示的名次


RankActivity.tbRankPowerCommonReward = {{"Item", 1126, 1}} 				-- 战力排名各门派通用奖励

RankActivity.tbRankPowerReward =  										-- 战力排名各门派奖励
{
	[1] = {
		{1,{{"AddTimeTitle", 5006, 30*24*60*60}}},	 		-- 排名N以下（包括N）的奖励,奖励配到N名则前N名发奖励			
	},																	--1 = 天王
	[2] = {
		{1,{{"AddTimeTitle", 5007, 30*24*60*60}}},	
	},																	--2 = 峨嵋
	[3] = {
		{1,{{"AddTimeTitle", 5008, 30*24*60*60}}},	
	},																	--3 = 桃花
	[4] = {
		{1,{{"AddTimeTitle", 5009, 30*24*60*60}}},	
	},																	--4 = 逍遥
	[5] = {
		{1,{{"AddTimeTitle", 5010, 30*24*60*60}}},		
	},																	--5 = 武当
	[6] = {
		{1,{{"AddTimeTitle", 5011, 30*24*60*60}}},	
	},																	--6 = 天忍
	[7] = {
		{1,{{"AddTimeTitle", 5012, 30*24*60*60}}},	
	},																	--7 = 少林
	[8] = {
		{1,{{"AddTimeTitle", 5013, 30*24*60*60}}},	
	},																	--8 = 翠烟
	[9] = {
		{1,{{"AddTimeTitle", 5014, 30*24*60*60}}},	
	},																	--9 = 唐门
	[10] = {
		{1,{{"AddTimeTitle", 5015, 30*24*60*60}}},	
	},																	--10 = 昆仑		
	[11] = {
		{1,{{"AddTimeTitle", 5016, 30*24*60*60}}},	
	},																	--11 = 丐帮	
	[12] = {
		{1,{{"AddTimeTitle", 5017, 30*24*60*60}}},	
	},																	--12 = 五毒	
	[13] = {
		{1,{{"AddTimeTitle", 5018, 30*24*60*60}}},	
	},																	--13 = 藏剑		
	[14] = {
		{1,{{"AddTimeTitle", 5019, 30*24*60*60}}},	
	},																	--14 = 长歌			
}

RankActivity.RANK_POWER_INVALID_TIME = 2*24*60*60 						-- 战力排名最新消息过期时间
RankActivity.OPEN_SERVER_RANK_POWER_INVALID_TIME = 15*24*60*60 			-- 开服推送战力排名最新消息过期时间

----------------show reward------------------
RankActivity.tbLevelRankShowReward = 									-- 等级排名界面显示奖励
{
	[1] = {
			{{"AddTimeTitle", 5060, 1}, {"Item", 1378, 1}}, 					-- 上面奖励
			{{"AddTimeTitle", 5061, 1}, {"Gold", 1000}}, 						-- 下面奖励（后面增加奖励以此类推）
			{{"AddTimeTitle", 5062, 1}, {"Gold", 300}},
		  },
	[2] = {
			{{"AddTimeTitle", 5060, 1}, {"Item", 1378, 1}}, 					-- 上面奖励
			{{"AddTimeTitle", 5061, 1}, {"Gold", 1000}}, 						-- 下面奖励（后面增加奖励以此类推）
			{{"AddTimeTitle", 5062, 1}, {"Gold", 300}},
		  },
	[3] = {
			{{"AddTimeTitle", 5060, 1}, {"Item", 1378, 1}}, 					-- 上面奖励
			{{"AddTimeTitle", 5061, 1}, {"Gold", 1000}}, 						-- 下面奖励（后面增加奖励以此类推）
			{{"AddTimeTitle", 5062, 1}, {"Gold", 300}},
		  },
	[4] = {
			{{"AddTimeTitle", 5060, 1}, {"Item", 1378, 1}}, 					-- 上面奖励
			{{"AddTimeTitle", 5061, 1}, {"Gold", 1000}}, 						-- 下面奖励（后面增加奖励以此类推）
			{{"AddTimeTitle", 5062, 1}, {"Gold", 300}},
		  },
	[5] = {
			{{"AddTimeTitle", 5060, 1}, {"Item", 1378, 1}}, 					-- 上面奖励
			{{"AddTimeTitle", 5061, 1}, {"Gold", 1000}}, 						-- 下面奖励（后面增加奖励以此类推）
			{{"AddTimeTitle", 5062, 1}, {"Gold", 300}},
		  },
	[6] = {
			{{"AddTimeTitle", 5060, 1}, {"Item", 1378, 1}}, 					-- 上面奖励
			{{"AddTimeTitle", 5061, 1}, {"Gold", 1000}}, 						-- 下面奖励（后面增加奖励以此类推）
			{{"AddTimeTitle", 5062, 1}, {"Gold", 300}},
		  },
	[7] = {
			{{"AddTimeTitle", 5060, 1}, {"Item", 1378, 1}}, 					-- 上面奖励
			{{"AddTimeTitle", 5061, 1}, {"Gold", 1000}}, 						-- 下面奖励（后面增加奖励以此类推）
			{{"AddTimeTitle", 5062, 1}, {"Gold", 300}},
		  },
	[8] = {
			{{"AddTimeTitle", 5060, 1}, {"Item", 1378, 1}}, 					-- 上面奖励
			{{"AddTimeTitle", 5061, 1}, {"Gold", 1000}}, 						-- 下面奖励（后面增加奖励以此类推）
			{{"AddTimeTitle", 5062, 1}, {"Gold", 300}},	
		  },
	[9] = {
			{{"AddTimeTitle", 5060, 1}, {"Item", 1378, 1}}, 					-- 上面奖励
			{{"AddTimeTitle", 5061, 1}, {"Gold", 1000}}, 						-- 下面奖励（后面增加奖励以此类推）
			{{"AddTimeTitle", 5062, 1}, {"Gold", 300}},
		  },
	[10] = {
			{{"AddTimeTitle", 5060, 1}, {"Item", 1378, 1}}, 					-- 上面奖励
			{{"AddTimeTitle", 5061, 1}, {"Gold", 1000}}, 						-- 下面奖励（后面增加奖励以此类推）
			{{"AddTimeTitle", 5062, 1}, {"Gold", 300}},	
		  },	  	  
	[11] = {
			{{"AddTimeTitle", 5060, 1}, {"Item", 1378, 1}}, 					-- 上面奖励
			{{"AddTimeTitle", 5061, 1}, {"Gold", 1000}}, 						-- 下面奖励（后面增加奖励以此类推）
			{{"AddTimeTitle", 5062, 1}, {"Gold", 300}},	
		  },
	[12] = {
			{{"AddTimeTitle", 5060, 1}, {"Item", 1378, 1}}, 					-- 上面奖励
			{{"AddTimeTitle", 5061, 1}, {"Gold", 1000}}, 						-- 下面奖励（后面增加奖励以此类推）
			{{"AddTimeTitle", 5062, 1}, {"Gold", 300}},	
		  },	
	[13] = {
			{{"AddTimeTitle", 5060, 1}, {"Item", 1378, 1}}, 					-- 上面奖励
			{{"AddTimeTitle", 5061, 1}, {"Gold", 1000}}, 						-- 下面奖励（后面增加奖励以此类推）
			{{"AddTimeTitle", 5062, 1}, {"Gold", 300}},	
		  },
	[14] = {
			{{"AddTimeTitle", 5060, 1}, {"Item", 1378, 1}}, 					-- 上面奖励
			{{"AddTimeTitle", 5061, 1}, {"Gold", 1000}}, 						-- 下面奖励（后面增加奖励以此类推）
			{{"AddTimeTitle", 5062, 1}, {"Gold", 300}},	
		  },
}

RankActivity.tbPowerRankShowReward = 						 			-- 战力排名界面显示奖励
{
	[1] = {
			{{"Item", 2557, 1}, {"Item", 1126, 1}},
		  },															--天王
	[2] = {
			{{"Item", 2558, 1}, {"Item", 1126, 1}},
		  },															--峨嵋
	[3] = {
			{{"Item", 2559, 1}, {"Item", 1126, 1}},
		  },															--桃花
	[4] = {
			{{"Item", 2560, 1}, {"Item", 1126, 1}},
		  },															--逍遥
	[5] = {
			{{"Item", 2561, 1}, {"Item", 1126, 1}},
		  },															--武当
	[6] = {
			{{"Item", 2562, 1}, {"Item", 1126, 1}},
		  },															--天忍
	[7] = {
			{{"Item", 2563, 1}, {"Item", 1126, 1}},
		  },															--少林
	[8] = {
			{{"Item", 2564, 1}, {"Item", 1126, 1}},
		  },															--翠烟	  
	[9] = {
			{{"Item", 2565, 1}, {"Item", 1126, 1}},
		  },															--唐门
	[10] = {
			{{"Item", 2566, 1}, {"Item", 1126, 1}},
		  },															--昆仑	  
	[11] = {
			{{"Item", 2567, 1}, {"Item", 1126, 1}},
		  },															--丐帮
	[12] = {
			{{"Item", 2568, 1}, {"Item", 1126, 1}},
		  },															--五毒
	[13] = {
			{{"Item", 5309, 1}, {"Item", 1126, 1}},
		  },															--藏剑
	[14] = {
			{{"Item", 5310, 1}, {"Item", 1126, 1}},
		  },															--长歌	  	
}

RankActivity.nPowerRankOpenDay = 15
RankActivity.nPowerRankTime = 0

function RankActivity:PowerRank(nFaction)
	local nRank = 0

	local tbFactionReward = RankActivity.tbRankPowerReward[nFaction]
	if not tbFactionReward then
		return nRank
	end

	for _,tbInfo in ipairs(tbFactionReward) do
		if tbInfo[1] > nRank then
			nRank = tbInfo[1]
		end
	end

	return nRank
end


function RankActivity:LevelRankReward(nRank)
	local tbAllReward = {}

	for _,tbInfo in ipairs(RankActivity.tbRankLevelReward) do
		if nRank <= tbInfo[1] and tbInfo[2] then
			tbAllReward = Lib:CopyTB(tbInfo[2])
			break
		end
	end

	return self:FormatReward(tbAllReward)
end

function RankActivity:GetPowerRankReward(nFaction,nRank)
	local tbAllReward = {}

	local tbFactionReward = RankActivity.tbRankPowerReward[nFaction]

	if not tbFactionReward then
		return tbAllReward
	end

	for _,tbInfo in ipairs(tbFactionReward) do
		if nRank <= tbInfo[1] and tbInfo[2] then
			tbAllReward = Lib:CopyTB(tbInfo[2])
			break
		end
	end

	return tbAllReward

end

function RankActivity:PowerRankReward(nFaction,nRank)
	local tbAllReward = {}

	local tbFactionReward = self:GetPowerRankReward(nFaction,nRank)
	if not tbFactionReward or not next(tbFactionReward) then
		return tbAllReward
	end

	for _,tbReward in pairs(RankActivity.tbRankPowerCommonReward) do
		table.insert(tbAllReward,tbReward)
	end

	local tbFormatFactionReward = Lib:CopyTB(tbFactionReward)
	tbFormatFactionReward = self:FormatReward(tbFormatFactionReward)
	for _,tbReward in pairs(tbFormatFactionReward) do
		table.insert(tbAllReward,tbReward)
	end

	return tbAllReward
end

function RankActivity:FormatReward(tbAllReward)
	tbAllReward = tbAllReward or {}

	local tbFormatReward = {}
	for _,tbReward in ipairs(tbAllReward) do
		if tbReward[1] == "AddTimeTitle" then
			tbReward[3] = tbReward[3] + GetTime()
		end
		table.insert(tbFormatReward,tbReward)
	end

	return tbFormatReward
end