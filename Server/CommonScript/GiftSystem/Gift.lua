Gift.tbGirls = {
	[2] = "峨嵋",
	[3] = "桃花",
	[6] = "天忍",
	[8] = "翠煙",
	[10]= "昆侖",
	[12]= "五毒",
	[14]= "長歌",
}

Gift.tbBoys = {
	[1] = "天王",
	[4] = "逍遙",
	[5] = "武當",
	[7] = "少林",
	[9] = "唐門",
	[11] = "丐幫",
	[13] = "藏劍",
}

Gift.Sex = {
	Boy  = 1,
	Girl = 2,
}

Gift.GiftType = 										-- 赠送类型
{
	RoseAndGrass = 1,
	FlowerBox    = 2,
	MailGift 	 = 3,
	Lover    = 4,
}

Gift.AllGift =
{
	[Gift.GiftType.RoseAndGrass] = true,
	[Gift.GiftType.FlowerBox] 	 = true,
	[Gift.GiftType.MailGift] 	 = true,
	[Gift.GiftType.Lover] 	 = true,
}

Gift.AllGiftNeedOnline = {
	[Gift.GiftType.RoseAndGrass] = true,
	[Gift.GiftType.FlowerBox] 	 = true,
	[Gift.GiftType.MailGift] 	 = false,
	[Gift.GiftType.Lover] 	 = true,	
}

Gift.MailType = 
{
	Times2Player = 1, 									-- 次数针对玩家
	Times2Item  = 2, 									-- 次数针对道具
	NoLimit = 3,										-- 没有次数限制
}

Gift.MailTimesType = 
{
	[Gift.MailType.Times2Player] = true,
	[Gift.MailType.Times2Item] = true,
	[Gift.MailType.NoLimit] = true,
}

Gift.MailTimesTypeNeedOnline = {
	[Gift.MailType.Times2Player] = true,
	[Gift.MailType.Times2Item] = true,
	[Gift.MailType.NoLimit] = false,
}

Gift.Times =
{
	Forever = -1 ,										-- 性别礼物类型不计赠送次数
}

Gift.nRoseId 		= 1234								-- 玫瑰花道具ID
Gift.nGrassId		= 1235								-- 幸运草道具ID

Gift.nRoseBoxId 	= 2180								-- 99朵玫瑰
Gift.nGrassBoxId	= 2181								-- 99棵幸运草

Gift.nQiaoKeLiId 	= 3789								-- 巧克力
Gift.nFlowerId		= 3788								-- 花束

-- 特殊处理的礼物类型
Gift.SpecialGift =
{
	[Gift.GiftType.MailGift] = true, 					-- 邮件发送道具类型（具体在Setting/Gift/MailGift.tab中配，可多个道具共用次数）
}

-- 性别礼物类型配置
Gift.IsReset = 											-- 性别礼物类型是否每天重置
{
	[Gift.GiftType.RoseAndGrass] = true,
	[Gift.GiftType.FlowerBox] 	 = true,
	[Gift.GiftType.Lover] 	 = true,
}

Gift.SendTimes = 										-- 性别礼物类型赠送次数
{
	[Gift.GiftType.RoseAndGrass] = 5,
	[Gift.GiftType.FlowerBox] 	 = 5,
	[Gift.GiftType.Lover] 	 = 1,
}

Gift.Rate = 											-- 性别礼物类型亲密度配置,不配不加
{
	[Gift.GiftType.RoseAndGrass] 	= 50,				-- 玫瑰花&幸运草 ~ 亲密度转换率
	[Gift.GiftType.FlowerBox] 		= 999,				-- 玫瑰花篮&幸运草篮 ~ 亲密度转换率
	[Gift.GiftType.Lover] 	 = 200,
}

Gift.AllItem = 											-- 性别礼物类型礼物类型对应性别的item
{
	[Gift.GiftType.RoseAndGrass] = {
		[Gift.Sex.Boy] = {Gift.nGrassId, "棵幸運草"},
		[Gift.Sex.Girl] = {Gift.nRoseId, "朵玫瑰花"},
	},
	[Gift.GiftType.FlowerBox] = {
		[Gift.Sex.Boy] = {Gift.nGrassBoxId, "99棵幸運草"},
		[Gift.Sex.Girl] = {Gift.nRoseBoxId, "99朵玫瑰花"},
	},
	[Gift.GiftType.Lover] = {
		[Gift.Sex.Boy] = {Gift.nQiaoKeLiId, "個春蠶懸絲"},
		[Gift.Sex.Girl] = {Gift.nFlowerId, "朵藍色妖姬"},
	},
}

-- 第一个%s是赠送方的名字，第二个%s是接受方的名字，第三个%s是道具的名字
Gift.tbBoxNotice = 
{
	-- 赠送放是男的 
	[Gift.Sex.Boy] = 
	{
		[Gift.Sex.Boy] = "「%s」從火熱的胸膛處掏出【%s】送給「%s」，說道：兄弟！天涯何處無芳草，送你一把幸運草……咱倆大塊肉，大杯酒，豈不快活！",
		[Gift.Sex.Girl] = "「%s」拿出藏在背後已久的【%s】送給「%s」，說道：此花只應天上有，不及佳人一回眸。最珍貴的花亦遠不如你，故此花非你莫屬。",
	},
	-- 赠送放是女的
	[Gift.Sex.Girl] = 
	{
		[Gift.Sex.Boy] = "「%s」紅著臉頰從香囊取出【%s】送給「%s」，說道：花開草葉側，只緣君護花。謝謝你一路以來的相伴，希望它能為你帶來幸運。",
		[Gift.Sex.Girl] = "「%s」從貼身的錦囊中取出【%s】送給「%s」，說道：唯有閨中蜜，方知兩人心，我最最親愛的姐妹，願你一世貌美如花，不可方物。",
	},
}

-- 邮件发送道具类型配置
Gift.tbMailGift = {}
Gift.tbAllMailItem = {}
Gift.tbAllMailGirlItem = {}

function Gift:LoadSetting()
	local szTabPath = "Setting/Gift/MailGift.tab";
	local szParamType = "sssdddddddsdddd";
	local szKey = "szKey";
	local tbParams = {"szKey","szId","szGirlId","nTimesType","nReset","nTimes","nItemSend","nItemAccept","nSure","nImityLevel","szSureTip","nVip","nAddImitity","nNotSendMail","nNotConsume"};
	local tbFile = LoadTabFile(szTabPath, szParamType, szKey, tbParams);

	for szKey,tbInfo in pairs(tbFile) do
		self.tbMailGift[szKey] = self.tbMailGift[szKey] or {}
		assert(tbInfo.szId ~= "",  "[Gift] LoadSetting no szId")
		local tbId = Lib:SplitStr(tbInfo.szId, ";")
		assert(next(tbId), "[Gift] LoadSetting fail ! tbItemId is {}")
		local tbGirlId = {}
		if tbInfo.szGirlId ~= "" then
			tbGirlId = Lib:SplitStr(tbInfo.szGirlId, ";")
			-- 男女道具个数要相等
			assert(#tbId == #tbGirlId, "[Gift] LoadSetting mail item count not equal " ..#tbId .."====" ..#tbGirlId)
		end

		local tbItemId = {}
		for i,v in pairs(tbId) do
			local nV = tonumber(v)
			if not nV then
				Log("[Gift] not invail id")
				return
			end
			tbItemId[i] = nV
		end

		local tbGirlItemId = {}
		if next(tbGirlId) then
			for k,v in pairs(tbItemId) do
				local nV = tonumber(tbGirlId[k])
				if not nV then
					Log("[Gift] tbGirlItemId not invail id")
					return
				end
				-- 男女对应道具id不能相同
				assert(nV ~= v, "[Gift] tbGirlItemId same id " ..nV .."====" ..v)
				tbGirlItemId[k] = nV
			end
		end

		self.tbMailGift[szKey].tbItemId = tbItemId
		self.tbMailGift[szKey].tbGirlItemId = tbGirlItemId

		if tbInfo.nReset and tbInfo.nReset == 1 then
			self.tbMailGift[szKey].bReset = true
		end

		if tbInfo.nSure and tbInfo.nSure == 1 then
			self.tbMailGift[szKey].bSure = true
		end

		assert(Gift.MailTimesType[tbInfo.nTimesType],"error times type")

		self.tbMailGift[szKey].nTimesType = tbInfo.nTimesType
		self.tbMailGift[szKey].nTimes = tbInfo.nTimes or 0 					-- 针对玩家可赠送的次数
		self.tbMailGift[szKey].nItemSend = tbInfo.nItemSend 				-- 针对道具可赠送的次数
		self.tbMailGift[szKey].nItemAccept = tbInfo.nItemAccept 			-- 针对道具可接受的次数
		self.tbMailGift[szKey].nImityLevel = tbInfo.nImityLevel
		self.tbMailGift[szKey].nVip = tbInfo.nVip
		if tbInfo.nAddImitity > 0 then
			self.tbMailGift[szKey].nAddImitity = tbInfo.nAddImitity
		end
		if tbInfo.nNotSendMail > 0 then
			self.tbMailGift[szKey].bNotSendMail = true
		end
		if tbInfo.nNotConsume > 0 then
			self.tbMailGift[szKey].bNotConsume = true
		end
		if tbInfo.szSureTip ~= "" then
			self.tbMailGift[szKey].szSureTip = tbInfo.szSureTip
		end

		for nIdx,nItemId in pairs(tbItemId) do
			assert(not Gift.tbAllMailItem[nItemId],"gift same item id")
			Gift.tbAllMailItem[nItemId] = {}
			Gift.tbAllMailItem[nItemId].tbData = self.tbMailGift[szKey]
			Gift.tbAllMailItem[nItemId].szKey = szKey
			Gift.tbAllMailItem[nItemId].nIdx = nIdx
		end

		for nIdx,nItemId in pairs(tbGirlItemId) do
			assert(not Gift.tbAllMailGirlItem[nItemId],"gift tbAllMailGirlItem same item id")
			Gift.tbAllMailGirlItem[nItemId] = {}
			Gift.tbAllMailGirlItem[nItemId].tbData = self.tbMailGift[szKey]
			Gift.tbAllMailGirlItem[nItemId].szKey = szKey
			Gift.tbAllMailGirlItem[nItemId].nIdx = nIdx
		end
	end
end

Gift:LoadSetting()

function Gift:CheckMailItemSex(nItemId)
	local nSex 
	if Gift.tbAllMailItem[nItemId] then
		nSex = Gift.Sex.Boy
	elseif Gift.tbAllMailGirlItem[nItemId] then
		nSex = Gift.Sex.Girl
	end
	return nSex
end

function Gift:CheckMailSexLimit(szKey)
	local bSexLimit
	local tbInfo = Gift:GetMailGiftInfo(szKey)
	if tbInfo and tbInfo.tbGirlItemId and next(tbInfo.tbGirlItemId) then
		bSexLimit = true
	end
	return bSexLimit
end

function Gift:GetMailGiftItemInfo(nItemId)
	return Gift.tbAllMailItem[nItemId] or Gift.tbAllMailGirlItem[nItemId]
end

function Gift:GetMailGiftInfo(szKey)
	return Gift.tbMailGift[szKey]
end

function Gift:GetSpecialTimes(nGiftType,nItemId)
	local nTimes,tbInfo
	if nGiftType == Gift.GiftType.MailGift then
		tbInfo = self:GetMailGiftItemInfo(nItemId)
		nTimes = tbInfo and tbInfo.tbData.nTimes
	end
	return nTimes
end

function Gift:GetMailAddImitity(nGiftType,nItemId)
	local nAddImitity,tbInfo
	if nGiftType == Gift.GiftType.MailGift then
		tbInfo = self:GetMailGiftItemInfo(nItemId)
		nAddImitity = tbInfo and tbInfo.tbData.nAddImitity
	end
	return nAddImitity
end

function Gift:GetMailTimesType(nGiftType,nItemId)
	local nType,tbInfo
	if nGiftType == Gift.GiftType.MailGift then
		tbInfo = self:GetMailGiftItemInfo(nItemId)
		nType = tbInfo and tbInfo.tbData.nTimesType
	end
	return nType
end

function Gift:GetItemAcceptTimes(nGiftType,nItemId)
	local nTimes,tbInfo
	if nGiftType == Gift.GiftType.MailGift then
		tbInfo = self:GetMailGiftItemInfo(nItemId)
		nTimes = tbInfo and tbInfo.tbData.nItemAccept
	end
	return nTimes
end

function Gift:GetItemSendTimes(nGiftType,nItemId)
	local nTimes,tbInfo
	if nGiftType == Gift.GiftType.MailGift then
		tbInfo = self:GetMailGiftItemInfo(nItemId)
		nTimes = tbInfo and tbInfo.tbData.nItemSend
	end
	return nTimes
end

function Gift:GetIsReset(nGiftType,nItemId)
	if nGiftType == Gift.GiftType.MailGift then
		local tbInfo = self:GetMailGiftItemInfo(nItemId)
		return tbInfo and tbInfo.tbData.bReset
	else
		return Gift.IsReset[nGiftType]
	end
end

function Gift:CheckNeedSure(nGiftType,nItemId)
	if nGiftType == Gift.GiftType.MailGift then
		local tbInfo = self:GetMailGiftItemInfo(nItemId)
		return tbInfo and tbInfo.tbData.bSure
	end
end

function Gift:CheckSex(nFaction)
	if Gift.tbGirls[nFaction] then
		return Gift.Sex.Girl;
	elseif Gift.tbBoys[nFaction] then
		return Gift.Sex.Boy;
	end
end

function Gift:CheckCommond(pPlayer,nAcceptId,nCount,nGiftType)
	if not nCount or nCount < 1 then
		return false,"請選擇要贈送的物品";
	end
	local pAcceptPlayer = KPlayer.GetPlayerObjById(nAcceptId);
	if not pAcceptPlayer then
		return false,"對方未在線";
	end

	local nSex = self:CheckSex(pAcceptPlayer.nFaction);
	if not nSex then
		return false,"對方是男?是女?";
	end

	local bIsFriend = FriendShip:IsFriend(pPlayer.dwID, nAcceptId);
	if not bIsFriend then
		return false,"對方不是你的好友";
	end

	local nItemId = Gift:GetItemId(nGiftType,nSex)

	if not nItemId then
		return false,"找不到要贈送的物品";
	end

	local nOrgCount = pPlayer.GetItemCountInAllPos(nItemId);
	local szItemName = KItem.GetItemShowInfo(nItemId, pPlayer.nFaction)
	if nOrgCount < nCount then
		return false,string.format("您的%s不夠",szItemName);
	end

	return true,"",pAcceptPlayer,nSex,nItemId,szItemName;
end

function Gift:BoxNotice(nSendSex, nAcceptSex)
	local szNotice = "「%s」對「%s」贈送了%s"
	if Gift.tbBoxNotice[nSendSex] and Gift.tbBoxNotice[nSendSex][nAcceptSex] then
		szNotice = Gift.tbBoxNotice[nSendSex][nAcceptSex]
	end
	return szNotice
end

function Gift:GetItemDesc(nGiftType,nSex)
	return Gift.AllItem[nGiftType] and Gift.AllItem[nGiftType][nSex] and Gift.AllItem[nGiftType][nSex][2]
end

-- 获取性别礼物类型ItemId
function Gift:GetItemId(nGiftType,nSex)
	return Gift.AllItem[nGiftType] and Gift.AllItem[nGiftType][nSex] and Gift.AllItem[nGiftType][nSex][1]
end