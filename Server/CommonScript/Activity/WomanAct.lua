if not MODULE_GAMESERVER then
    Activity.WomanAct = Activity.WomanAct or {}
    Activity.WomanAct.tbLabelInfo = Activity.WomanAct.tbLabelInfo or {}
    Activity.WomanAct.tbPlayerRequestCD = {}
end
local tbAct = MODULE_GAMESERVER and Activity:GetClass("WomanAct") or Activity.WomanAct

-- 赠送需达到的亲密度等级
tbAct.nImityLevel = 0
-- 付费标签价格
tbAct.nPayLabelCost = 199
-- 保存多少个付费的赠送来源
tbAct.nSavePayCount = 5
-- 参与等级
tbAct.nLevelLimit = 20

tbAct.FreeLabel = 1
tbAct.PayLabel = 2

-- 标签长度配置
tbAct.nLabelMin = 1;		-- 最小标签长度
tbAct.nLabelMax = 7;		-- 最大标签长度
tbAct.nVNLabelMin = 4;		-- 越南版最小标签长度
tbAct.nVNLabelMax = 14;		-- 越南版最大标签长度

tbAct.tbFree = 
{"名師風範", "美膩的師父", "嚴厲的師傅", "厲害的師父", "幽默的大大", "三人行必有我師", "一日為師終身父", "有師如此複何求", "師父今天去哪玩", "師父稀有武器呢"}

-- 赠送之后可获得的礼盒个数
tbAct.nBoxLimit = 5
-- 礼盒刷新点
tbAct.nBoxRefreshTime = 4 * 60 * 60
-- 可用标签位置
tbAct.nMaxLabel = 15
-- 增加亲密度
tbAct.nAddImitity = 100

-- 赠送祝福册邮件内容
tbAct.szMailTitle =  "留下你的祝福";
tbAct.szMailText =  "    佳節將至，俠士經歷了如此之久的江湖生活，想必已除了識不少摯友，也應當結識了一位好師父，或是為人師表，有道是一日為師終生為父，何不與師父組隊，就快打開祝福冊，為與你一同闖蕩江湖的師父寫上祝福吧！";
tbAct.szMailFrom =  "";

-- 赠送祝福标签之后发给对方的邮件内容%s （1：赠送方 2：标签）
tbAct.szAcceptMailTitle = "新的祝福";
tbAct.szAcceptMailFrom = "系統";
tbAct.szAcceptMailText = "    俠士[FFFE0D]%s[-]對你留下了新的祝福——[FFFE0D]%s[-]，趕快去[64db00] [url=openwnd:查看祝福, FriendImpressionPanel] [-]吧！"


-- 赠送之后自身获得的奖励
tbAct.tbSendAward = 
{
	[tbAct.FreeLabel] = {{"item", 4889, 1}};
	[tbAct.PayLabel] = {{"item", 4889, 1}};
}

-- 赠送之后对方获得的奖励
tbAct.tbAcceptAward = 
{
	[tbAct.FreeLabel] = {{"item", 4889, 1}};
	[tbAct.PayLabel] = {{"item", 4889, 1}};
}

-- 女生标签到达几个可以获得奖励
tbAct.nGirlAwardLabelCount = 15
tbAct.nGirlAward = {{"item", 4890, 1}}

-- 领取哪个活跃度可获得奖励
tbAct.tbActiveIndex = 
{
	[Gift.Sex.Boy] = {[1] = {{"item", 3910, 1}},[2] = {{"item", 3910, 1}},[3] = {{"item", 3910, 1}},[4] = {{"item", 3910, 1}},[5] = {{"item", 3910, 1}}};
	[Gift.Sex.Girl] = {[1] = {{"item", 3909, 1}},[2] = {{"item", 3909, 1}},[3] = {{"item", 3909, 1}},[4] = {{"item", 3909, 1}},[5] = {{"item", 3909, 1}}};
}

tbAct.tbFree2Label = tbAct.tbFree2Label or {}
if not next(tbAct.tbFree2Label) then
	for k,v in pairs(tbAct.tbFree) do
		tbAct.tbFree2Label[v] = k
	end
end

-- 祝福签
tbAct.nImpressionLabelItemID = 3910
-- 免费标签需要消耗的道具数量
tbAct.nNeedConsumeImpressionLabel = 1
-- 可赠送的截止时间
tbAct.szSendLabelEndTime = "2017-6-18-23-59-59"

function tbAct:InitData()
	local tbEndDateTime = Lib:SplitStr(self.szSendLabelEndTime, "-")
	local year, month, day, hour, minute, second = unpack(tbEndDateTime)
	local nEndTime = os.time({year = tonumber(year), month = tonumber(month), day = tonumber(day), hour = tonumber(hour), min = tonumber(minute), sec = tonumber(second)})
	self.nSendLabelEndTime = nEndTime
end

tbAct:InitData()

function tbAct:IsEndSendLabel()
	if GetTime() >= self.nSendLabelEndTime then
		return true, "活動已結束，無法添加祝福"
	end
	return false
end

-- bNotCheckGold 扣完元宝回调中不再检查元宝
function tbAct:CheckCommon(pPlayer, nAcceptId, nType, szLabel, bNotCheckGold)
	local bRet, szMsg = self:IsEndSendLabel()
	if bRet then
		return false, szMsg
	end

	if nType ~= self.FreeLabel and nType ~= self.PayLabel then
		return false, "未知類型"
	end

	if szLabel == "" then
		return false, "未知標籤"
	end

	if pPlayer.nLevel < self.nLevelLimit then
		return false, string.format("參與等級不足%s", self.nLevelLimit)
	end

	if MODULE_GAMESERVER then
		if not TeacherStudent:IsMyTeacher(pPlayer, nAcceptId) then
			return false, "只能為師父添加祝福"
		end
	end
	
	-- if not FriendShip:IsFriend(pPlayer.dwID, nAcceptId) then
	-- 	return false, "对方不是你的好友";
	-- end

	local nImityLevel = FriendShip:GetFriendImityLevel(pPlayer.dwID, nAcceptId) or 0
	if nImityLevel < self.nImityLevel then
		return false, string.format("雙方親密度不足%s級", self.nImityLevel)
	end

	if nType == self.FreeLabel then
		if pPlayer.GetItemCountInAllPos(self.nImpressionLabelItemID) < self.nNeedConsumeImpressionLabel then
			return false, string.format("您擁有的%s不足", KItem.GetItemShowInfo(self.nImpressionLabelItemID, pPlayer.nFaction) or "祝福簽")
		end
		if not self.tbFree2Label[szLabel] then
			return false, "未知的標籤描述"
		end
	elseif nType == self.PayLabel then
		if not bNotCheckGold and pPlayer.GetMoney("Gold") < self.nPayLabelCost then
			return false, "元寶不足"
		end
		if version_vn then
			local nVNLen = string.len(szLabel);
			if nVNLen > self.nVNLabelMax or nVNLen < self.nVNLabelMin then
				return false, string.format("自定義標籤需在%d~%d字之間", self.nVNLabelMin, self.nVNLabelMax);
			end
		else
			local nNameLen = Lib:Utf8Len(szLabel);
			if nNameLen > self.nLabelMax or nNameLen < self.nLabelMin then
				return false, string.format("自定義標籤需在%d~%d字之間", self.nLabelMin, self.nLabelMax);
			end
		end
		if not CheckNameAvailable(szLabel) then
			return false, "含有非法字元，請修改後重試"
		end
	end

	return true
end

--------------------------- Client ------------------------------

function tbAct:OnSendLabelSuccess()
	UiNotify.OnNotify(UiNotify.emNOTIFY_WOMAN_SYNDATA)
end

function tbAct:OnAcceptLabelSuccess()
end

function tbAct:OnSynData(tbData, nStartTime, nEndTime)
	self.nStartTime = nStartTime
	self.nEndTime = nEndTime
	self:FormatData(tbData)
	UiNotify.OnNotify(UiNotify.emNOTIFY_WOMAN_SYNDATA)
end

function tbAct:FormatData(tbData)
	for dwID, tbInfo in pairs(tbData or {}) do
		self.tbLabelInfo[dwID] = self.tbLabelInfo[dwID] or {}
		self.tbLabelInfo[dwID].nPlayerId = dwID
		self.tbLabelInfo[dwID].tbFreeLabel = tbInfo.tbFreeLabel or self.tbLabelInfo[dwID].tbFreeLabel or {}
		self.tbLabelInfo[dwID].tbPayLabel = tbInfo.tbPayLabel or self.tbLabelInfo[dwID].tbPayLabel or {}
		self.tbLabelInfo[dwID].tbLabelTime = tbInfo.tbLabelTime or self.tbLabelInfo[dwID].tbLabelTime or {}
		self.tbLabelInfo[dwID].tbPayLabelPlayer = tbInfo.tbPayLabelPlayer or self.tbLabelInfo[dwID].tbPayLabelPlayer or {}
		self.tbLabelInfo[dwID].nHadLabelCount = tbInfo.nHadLabelCount or self.tbLabelInfo[dwID].nHadLabelCount or 0
	end
end

function tbAct:OnSynLabelPlayer(tbData)
	self.tbPriorData = tbData
	Ui:OpenWindow("FriendImpressionPanel")
end

function tbAct:GetLabelInfo()
	return self.tbLabelInfo
end

function tbAct:GetPriorData()
	return self.tbPriorData
end

function tbAct:ClearPriorData()
	self.tbPriorData = nil
end

function tbAct:OpenLabelWindow(nTargetId)
	if FriendShip:IsFriend(me.dwID, nTargetId) then
		Ui:OpenWindow("FriendImpressionPanel", nTargetId)
	else
		RemoteServer.TrySynLabelPlayer(nTargetId)
	end
end

function tbAct:GetTimeInfo()
	return self.nStartTime, self.nEndTime
end
