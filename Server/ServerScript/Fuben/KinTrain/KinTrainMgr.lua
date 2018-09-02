--家族试炼
Fuben.KinTrainMgr = Fuben.KinTrainMgr or {}
local KinTrainMgr = Fuben.KinTrainMgr
KinTrainMgr.OPEN_MEMBER_NUM = 5--最小开启人数
KinTrainMgr.PREPARE_TIME    = 60*5--准备时间
KinTrainMgr.MAPTEMPLATEID   = 1048--地图ID
KinTrainMgr.ENTRY_POS       = {4338, 3691}
KinTrainMgr.TOTAL_TIME      = 40*60 --总时间（包括准备时间）
KinTrainMgr.AUCTION_LEVEL   = 30
KinTrainMgr.ACTIVITY_NAME   = "幫派試煉"
KinTrainMgr.ONE_PLAYER_VALUE= 100000
KinTrainMgr.tbItemAuctionValue = {
    [2164] = 450000,
    [2165] = 1350000,
    [4312] = 100000,
    [4313] = 200000,
    [4314] = 400000,
    [4315] = 800000,
    [3593] = 1000000,
}
KinTrainMgr.tbAuctionItem = {
--    [39]  = {[2164] = 1},
--    [49]  = {[2164] = 1},
--    [59]  = {[2164] = 1},
--    [69]  = {[4312] = 0.525, [2164] = 0.275, [2165] = 0.1},
--    [79]  = {[4312] = 0.175, [4313] = 0.35,  [2164] = 0.275, [2165] = 0.1,  [3593] = 0.1},
--    [89]  = {[4312] = 0.175, [4313] = 0.35,  [2164] = 0.225, [2165] = 0.15, [3593] = 0.1},
--    [99]  = {[4313] = 0.175, [4314] = 0.35,  [2164] = 0.175, [2165] = 0.2,  [3593] = 0.1},
--    [109] = {[4313] = 0.175, [4314] = 0.35,  [2164] = 0.125, [2165] = 0.25, [3593] = 0.1},
--    [119] = {[4314] = 0.175, [4315] = 0.35,  [2164] = 0.075, [2165] = 0.3,  [3593] = 0.1},
	{"OpenLevel39", {[2164] = 1}},
	{"OpenLevel69", {[4312] = 0.525, [2164] = 0.275, [2165] = 0.1}},
	{"OpenLevel79", {[4312] = 0.525, [2164] = 0.275, [2165] = 0.1,  [3593] = 0.1}},
	{"OpenDay99", 	{[4312] = 0.175, [4313] = 0.35,  [2164] = 0.275, [2165] = 0.1,  [3593] = 0.1}},
	
	{"OpenLevel89", {[4312] = 0.175, [4313] = 0.35,  [2164] = 0.225, [2165] = 0.15, [3593] = 0.1}},
	{"OpenLevel99", {[4312] = 0.15,  [4313] = 0.375,  [2164] = 0.175, [2165] = 0.2,  [3593] = 0.1}},
	{"OpenDay224", 	{[4313] = 0.175, [4314] = 0.35,  [2164] = 0.175, [2165] = 0.2,  [3593] = 0.1}},
	
	{"OpenLevel109", {[4313] = 0.175, [4314] = 0.35,  [2164] = 0.125, [2165] = 0.25, [3593] = 0.1}},
	{"OpenLevel119", {[4313] = 0.15,  [4314] = 0.375,  [2164] = 0.075, [2165] = 0.3,  [3593] = 0.1}},
	{"OpenDay399", 	 {[4314] = 0.175, [4315] = 0.35,  [2164] = 0.075, [2165] = 0.3,  [3593] = 0.1}},

}
function KinTrainMgr:Start()
    self.tbKinMap     = {}
    self.tbWaitPlayer = {}
    self.bInProcess   = true
    self.nStartTime   = GetTime()

    self:PushNotify()
    Timer:Register(Env.GAME_FPS * self.PREPARE_TIME, self.BeginTrain, self) --这里不能让副本来控制，因为副本的创建时间是不一定的
    SupplementAward:OnActivityOpen("KinTrain")
    Calendar:OnActivityBegin("KinFuben")
    Log("KinTrainMgr Start", GetTime())
end

function KinTrainMgr:PushNotify()
    local szMsg = "幫派試煉已經開啟，各幫派成員可通過活動日曆前往試煉地圖"
    KPlayer.SendWorldNotify(1, 1000, szMsg, ChatMgr.ChannelType.Public, 1)
end

function KinTrainMgr:Stop()
    if not self.bInProcess then
        Log("KinTrainMgr Try Stop Nonexistent Train")
        return
    end

    self.bInProcess = false
    for _, nMapId in pairs(self.tbKinMap or {}) do
        local tbFubenInst = Fuben.tbFubenInstance[nMapId]
        if tbFubenInst then
            tbFubenInst:OnTimeOut()
        end
    end
    Calendar:OnActivityEnd("KinFuben")
    Log("KinTrainMgr Stop", GetTime())
end

function KinTrainMgr:BeginTrain()
    for _, nMapId in pairs(self.tbKinMap) do
        local tbFubenInst = Fuben.tbFubenInstance[nMapId]
        if tbFubenInst then
            tbFubenInst:BeginTrain()
        end
    end
    Log("KinTrainMgr BeginTrain", GetTime())
end

function KinTrainMgr:OnFubenCreateSuccess(dwKinId, nMapId)
    if not self.bInProcess then
        Log("[KinTrainMgr OnFubenCreateSuccess]")
        self.tbWaitPlayer[dwKinId] = nil
        return
    end

    self.tbKinMap[dwKinId] = nMapId
    for dwID, _ in pairs(self.tbWaitPlayer[dwKinId] or {}) do
        local pPlayer = KPlayer.GetPlayerObjById(dwID)
        if pPlayer then
            self:TryEnterMap(pPlayer)
        end
    end
    self.tbWaitPlayer[dwKinId] = nil

    --开启家族实时语音
    if not ChatMgr:IsKinHaveChatRoom(dwKinId) then
        ChatMgr:CreateKinChatRoom(dwKinId)
    end
end

function KinTrainMgr:TryEnterMap(pPlayer)
    local bRet, szMsg = self:CheckEntry(pPlayer)
    if not bRet then
        pPlayer.CenterMsg(szMsg)
        return
    end

    local dwKinId = pPlayer.dwKinId
    local nMapId = self.tbKinMap[dwKinId]
    if not nMapId then
        if self.tbWaitPlayer[dwKinId] then
            self.tbWaitPlayer[dwKinId][pPlayer.dwID] = 1
            return
        end

        if GetTime() > (self.nStartTime + self.PREPARE_TIME) then
            pPlayer.CenterMsg("幫派試煉已結束")
            return
        end

        self.tbWaitPlayer[dwKinId] = {[pPlayer.dwID] = 1}
        Fuben:ApplyFuben(pPlayer.dwID, self.MAPTEMPLATEID, 
            function (nMapId)
                self:OnFubenCreateSuccess(dwKinId, nMapId)
            end,
            function ()
                Log("[KinTrainMgr] FubenCreateFail", dwKinId)
            end, dwKinId)
        Log("KinTrainMgr Try CreateMap", dwKinId)
        return
    end

    local tbInst = Fuben.tbFubenInstance[nMapId]
    if not tbInst or tbInst.bClose == 1 then
        pPlayer.CenterMsg("幫派試煉已結束")
        return
    end

    pPlayer.SetEntryPoint()
    pPlayer.SwitchMap(nMapId, unpack(self.ENTRY_POS))
    SupplementAward:OnJoinActivity(pPlayer, "KinTrain")
end

function KinTrainMgr:CheckEntry(pPlayer)
    if not self.bInProcess then
        return false, "活動未開啟"
    end

    if pPlayer.dwKinId == 0 then
        return false, "沒有幫派，無法參加活動"
    end

    if not Env:CheckSystemSwitch(pPlayer, Env.SW_SwitchMap) then
        return false, "目前狀態不允許切換地圖"
    end

    if not Fuben.tbSafeMap[pPlayer.nMapTemplateId] and Map:GetClassDesc(pPlayer.nMapTemplateId) ~= "fight" then
        return false, "所在地圖不允許進入副本！";
    end

    if Map:GetClassDesc(pPlayer.nMapTemplateId) == "fight" and pPlayer.nFightMode ~= 0 then
        return false, "非安全區不允許進入副本！";
    end

    return true
end

function KinTrainMgr:GetEndTime()
    if not self.bInProcess then
        return
    end

    if GetTime() < (self.nStartTime + self.PREPARE_TIME) then
        return self.nStartTime + self.PREPARE_TIME
    else
        return self.nStartTime + self.TOTAL_TIME
    end
end

function KinTrainMgr:OnCreateChatRoom(dwKinId, uRoomHighId, uRoomLowId)
    if not self.bInProcess then
        return false
    end

    local nMapId = self.tbKinMap[dwKinId]
    if not nMapId then
        return true
    end

    local tbFubenInst = Fuben.tbFubenInstance[nMapId]
    if tbFubenInst then
        tbFubenInst:MemberJoinKinChatRoom()
    end

    return true;
end

function KinTrainMgr:GetAwardList()
	local tbItemList;
	for _, tbInfo in ipairs(self.tbAuctionItem) do
		local szTimeFrime, tbList = unpack(tbInfo)
		if GetTimeFrameState(szTimeFrime) == 1 then
			tbItemList = tbList;
		else
			break;
		end
	end
	return tbItemList;
end

function KinTrainMgr:GetAward(nJoinNum)
    local tbItem = self:GetAwardList()
    if not tbItem then
        Log("[KinTrainMgr GetAward Err No AuctionAward In Cur Timeframe]", nJoinNum)
        return
    end

    local tbAward = {}
    local nAllValue = nJoinNum * self.ONE_PLAYER_VALUE
    for nItemTID, nProp in pairs(tbItem) do
        local nItemValue = nAllValue * nProp
        local nDropNum = nItemValue/self.tbItemAuctionValue[nItemTID]
        local nDec = 1000000*(nDropNum - math.floor(nDropNum))
        nDropNum = math.floor(nDropNum)
        if nDec >= MathRandom(1000000) then
            nDropNum = nDropNum + 1
        end
        if nDropNum > 0 then
            table.insert(tbAward, {nItemTID, nDropNum})
        end
    end
    local tbRealAward = self:GetRealAward(tbAward)
    return tbRealAward
end

function KinTrainMgr:GetRealAward(tbAward)
    local tbResult = {}
    for _, tbInfo in ipairs(tbAward) do
        local tbItemInfo = KItem.GetItemBaseProp(tbInfo[1])
        if not tbItemInfo or not tbItemInfo.szClass or
            (tbItemInfo.szClass ~= "RandomItem" and
            tbItemInfo.szClass ~= "RandomItemByLevel" and
            tbItemInfo.szClass ~= "RandomItemByMaxLevel" and
            tbItemInfo.szClass ~= "RandomItemByTimeFrame") then
            table.insert(tbResult, tbInfo)
        else
            local nParamId = KItem.GetItemExtParam(tbInfo[1], 1)
            if tbItemInfo.szClass == "RandomItemByLevel" or tbItemInfo.szClass == "RandomItemByMaxLevel" then
                nParamId = Item:GetClass("RandomItemByLevel"):GetRandomKindId(GetMaxLevel(), nParamId)
            elseif tbItemInfo.szClass == "RandomItemByTimeFrame" then
                nParamId = Item:GetClass("RandomItemByTimeFrame"):GetRandomKindId(nParamId)
            end

            for i = 1, tbInfo[2] do
                local bRet, szMsg, tbAllAward = Item:GetClass("RandomItem"):RandomItemAward(nil, nParamId, self.ACTIVITY_NAME)
                if not bRet or bRet ~= 1 then
                    Log("[KinTrainMgr GetRealAward] ERR ?? get random item award fail !", unpack(tbInfo))
                else
                    for _, tbAward in ipairs(tbAllAward) do
                        table.insert(tbResult, {tbAward[2], tbAward[3]})
                    end
                end

            end
        end
    end
    return tbResult
end