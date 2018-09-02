SendBless.nMinLevel = 20; --最小参与等级
SendBless.nStackMax  = 5; -- 每次的叠加上限为5
SendBless.nTimeStep = 1200 -- 20分钟恢复一次次数
SendBless.nMAX_SEND_TIMES = 20; --每天最多送20次
SendBless.TOP_NUM = 10 ;--取前10 玩家
SendBless.COST_GOLD = 88; --元宝祝福
SendBless.nItemDelayDelteTime = 0;--道具是在每轮活动结束后44小时再消失

SendBless.szDefaultWord = "新年快樂"
SendBless.szWordMaxLen = 30;-- 字符限制

SendBless.tbActSetting = {
    [1] = { --普天同庆祝福函
        szActName = "SendBlessAct"; --活动名
        szNotifyUi= "Lantern";
        szOpenUi = "BlessPanel";
        szNormalSprite = false;
        szGoldSprite = false;
        bRank = true;
        bGoldSkipTimes = false;
        nCardItemId = 3066;
        tbGetBlessAward = false;
        nMaxGetBlessAwardTimes = false;
        szItemUseName = "雙十祝福";
        szMailTitle = "普天同慶"; 
        szMailText = "少俠，江湖路遠，您也結交了很多武林同道吧？值此雙十佳節，或許應該給他們送去誠摯的祝福，邀請他們一起歡度這個節日吧。這張“[FFFE0D]普天同慶祝福函[-]”可以幫你收集和送出祝福，請查收。詳細內容請查閱[url=openwnd:最新消息, NewInformationPanel, 'SendBlessAct']相關頁面。";
        szGetBlessMsgNormal = "恭喜您獲得了來自好友「%s」的雙十祝福！";
        szGetBlessMsgGold = "大驚喜！獲得來自好友「%s」的特別雙十祝福";
        szSendBlessMsg = "您向好友「%s」送出了雙十的祝福！";
        szColorSendMsg = false;
        szNewsTitle = "雙十·普天同慶";
        szNewsText = [[
        [FFFE0D]新一輪國慶“普天同慶”祝福活動開始了！[-]

            通過祝福道具給好友送出祝福，根據總祝福值領取檔次獎勵，並參與排行獲得永久稱號。活動共開啟[FFFE0D]3輪[-]，分別在10月[FFFE0D]1、4、7[-]日0點開始，[FFFE0D]下一天4點[-]結束。
        [FFFE0D]本輪活動時間：[-]%s
        [FFFE0D]參與等級：[-]20級

        [FFFE0D]1、祝福函[-]
            活動開啟後，滿足條件的玩家能收到一封系統郵件，查收附件可得到[11adf6][url=openwnd:普天同慶祝福函, ItemTips, "Item", nil, 3066][-]。
            在祝福介面可對好友送出祝福，對方能獲得[FFFE0D]祝福值[-]。根據條件不同（如祝福方頭銜、雙方親密等級、幫派及師徒關係等）能獲得[FFFE0D]額外祝福值[-]，進行[FFFE0D]元寶祝福[-]也能額外獲得祝福值。
            祝福函中從好友處獲得的祝福值前[FFFE0D]10[-]名相加，為大俠自己獲得的[FFFE0D]總祝福值[-]。
            每輪活動開始時，會清空祝福值並重置祝福狀態。
        [FFFE0D]2、祝福次數[-]
            向好友送祝福需要消耗祝福次數，每[FFFE0D]20[-]分鐘可以獲得[FFFE0D]1[-]祝福次數，累計上限為[FFFE0D]5[-]。
            [FFFE0D]每輪[-]活動，每位俠客最多向[FFFE0D]20[-]名好友送出祝福，對同一好友最多祝福1次。
        [FFFE0D]3、活動獎勵[-]
            隨著祝福函中的總祝福值越來越大，可以領取[FFFE0D]檔次獎勵[-]，如下：
            ·達到5：  可領取2個[11adf6][url=openwnd:黃金寶箱, ItemTips, "Item", nil, 786][-]
            ·達到10： 可領取1000貢獻
            ·達到20： 可領取2個[11adf6][url=openwnd:藍水晶, ItemTips, "Item", nil, 223][-]
            ·達到30： 可領取200元寶
            ·達到40： 可領取3000貢獻
            ·達到50： 可領取[11adf6][url=openwnd:3級魂石箱, ItemTips, "Item", nil, 2164][-]
            ·達到60： 可領取[11adf6][url=openwnd:高級藏寶圖, ItemTips, "Item", nil, 788][-]
            ·達到70： 可領取[11adf6][url=openwnd:紫水晶, ItemTips, "Item", nil, 224][-]
            ·達到80： 可領取500元寶
            ·達到90： 可領取5000貢獻
            ·達到100：可領取[11adf6][url=openwnd:4級魂石箱, ItemTips, "Item", nil, 2165][-]

        [FFFE0D]每輪[-]活動會在“排行榜”中對玩家的總祝福值進行排名，結束時按照排名獲得[FFFE0D]永久稱號[-]：
            ·第1名：    橙色稱號“摯友如雲”
            ·第2~10名： 粉色稱號“高朋滿座”
            ·第11~30名：紫色稱號“門庭若市”
        ]];
    }; 
    [2] = { ----新年送祝福函
        szActName = "SendBlessActWord"; --活动名
        szNotifyUi= "NewYear";
        szNormalSprite = "NewYear01";
        szGoldSprite = "NewYear02";
        szOpenUi = "BlessPanelWord";
        bRank = false;
        bGoldSkipTimes = true; --消耗元宝不扣次数
        nCardItemId = 3687; --活动道具
        tbGetBlessAward = {{"item", 3712, 1}};--收到祝福方获得的奖励箱子
        nMaxGetBlessAwardTimes = 10;--每轮最多收到的祝福箱子数目
        szItemUseName = "新年祝福";
        szMailTitle = "新年祝福";
        szMailText = "少俠，江湖路遠，您也結交了很多武林同道吧？值此新年佳節，或許應該給他們送去誠摯的祝福，邀請他們一起歡度這個節日吧。這張“[FFFE0D]新年祝福函[-]”可以幫你收集和送出祝福，請查收。詳細內容請查閱[url=openwnd:最新消息, NewInformationPanel, 'SendBlessActWord']相關頁面。";
        szGetBlessMsgNormal = "恭喜您獲得了來自好友「%s」的新年祝福！";
        szGetBlessMsgGold = "大驚喜！獲得來自好友「%s」的特別新年祝福";
        szSendBlessMsg = "您向好友「%s」送出了新年的祝福！";
        szColorSendMsg = "俠士「%s」向其好友「%s」發送了新年祝福：%s";
        szNewsTitle = "新年祝福";
        szNewsText = [[
        [FFFE0D]新一輪新年祝福活動開始了！[-]

        通過祝福道具給好友送出祝福並獲得獎勵。活動共開啟[FFFE0D]3輪[-]，分別在[FFFE0D]1月28日、2月1日、2月5日[-]0點開始，[FFFE0D]下一天4點[-]結束。
        [FFFE0D]本輪活動時間：[-]%s
        [FFFE0D]參與等級：[-]20級

            活動開啟後，滿足條件的玩家能收到一封系統郵件，查收附件可得到[11adf6][url=openwnd:新年祝福函, ItemTips, "Item", nil, 3687][-]。
            使用祝福函後，在祝福介面可對好友送出祝福，同時對方能獲得[FFFE0D]祝福寶箱[-]。每輪活動，每個玩家最多獲得[FFFE0D]10個[-]祝福寶箱。
            每輪活動，每位俠客最多向[FFFE0D]20名[-]好友送出祝福，對同一好友最多祝福1次。消耗元寶祝福不會消耗祝福次數。
            可能獲得獎勵：[11adf6][url=openwnd:修煉丹, ItemTips, "Item", nil, 2301][-]，[11adf6][url=openwnd:傳功丹, ItemTips, "Item", nil, 2759][-]，[11adf6][url=openwnd:外裝染色劑, ItemTips, "Item", nil, 2569][-]，[11adf6][url=openwnd:紫水晶, ItemTips, "Item", nil, 224][-]。
        ]];
    };
}

SendBless.tbHonorScore = {  --头衔对应的加分
    [6]     = 1;
    [7]     = 2;
    [8]     = 3;
    [9]     = 4;
    [10]    = 5;
}; 

SendBless.tbImityScore = { --亲密度等级 对应分
    {5,  1 },
    {10, 2 },
    {15, 3 },
    {20, 4 },
    {30, 5 },
}

SendBless.tbRankAward = {  --排行奖励
    {nRankEnd = 1,  tbAward = {"AddTimeTitle" , 408, -1} },
    {nRankEnd = 10, tbAward = {"AddTimeTitle" , 407, -1} },
    {nRankEnd = 30, tbAward = {"AddTimeTitle" , 406, -1} },
}

SendBless.tbTakeAwardSet = {  --手动领取奖励
    {nScore = 5,  tbAward = {"item", 786, 2 } },
    {nScore = 10, tbAward = {"Contrib", 1000} },
    {nScore = 20, tbAward = {"item", 223, 2} },
    {nScore = 30, tbAward = {"Gold", 200 } },
    {nScore = 40, tbAward = {"Contrib", 3000 } },
    {nScore = 50, tbAward = {"item", 2164, 1 } },
    {nScore = 60, tbAward = {"item", 788, 1 } },
    {nScore = 70, tbAward = {"item", 224, 1 } },
    {nScore = 80, tbAward = {"Gold", 500 } },
    {nScore = 90, tbAward = {"Contrib", 5000 } },
    {nScore = 100, tbAward = {"item", 2165, 1 } },
};


SendBless.SAVE_GROUP    = 116
SendBless.KEY_RESET_DAY = 1
SendBless.KEY_SEND_TIME = 2
SendBless.KEY_CUR_SEND_TIMES = 3
SendBless.KEY_TakeAwardLevel = 4; --现在领取的奖励档次


--如果服务端判断剩余未6次，则重置对应的时间， 每次重置后使用次数置0，
function SendBless:GetNowMaxSendTimes(pPlayer)
    local nLastSendTime = pPlayer.GetUserValue(self.SAVE_GROUP, self.KEY_SEND_TIME) --参加重置为6次的时间
    if nLastSendTime == 0 then
        return self.nStackMax
    end

    local nTimeDiff = GetTime() - nLastSendTime
    local nNowSaveCur = pPlayer.GetUserValue(self.SAVE_GROUP, self.KEY_CUR_SEND_TIMES)
    return math.min(nNowSaveCur + math.floor(nTimeDiff / self.nTimeStep), self.nStackMax), nTimeDiff
end

function SendBless:GetScoreInfo(tbData)
    if not tbData then
        return 0;
    end
    local tbSort = {}
    for dwRoleId, nVal in pairs(tbData) do
        table.insert(tbSort, nVal)
    end
    table.sort( tbSort, function (a, b)
        return a > b;
    end )
    local nTotalVal = 0
    for i=1, self.TOP_NUM  do
        if tbSort[i] then
            nTotalVal = nTotalVal + tbSort[i]
        else
            break;
        end
    end
    return nTotalVal
end

function SendBless:GetSendTimes(tbSendData, bGoldSkipTimes)
    local nCount = 0
    for k,v in pairs(tbSendData) do
        if not (bGoldSkipTimes and v == 2) then
            nCount = nCount + 1
        end
    end
    return nCount
end

function SendBless:CheckSendCondition(pPlayer, dwRoleId2, tbData, bUseGold)
    if pPlayer.nLevel < self.nMinLevel then
        pPlayer.CenterMsg("等級不足")
        return
    end

    if tbData[dwRoleId2] then
        pPlayer.CenterMsg("已經贈送過了")
        return
    end
    
    local tbActSetting = self:GetActSetting()
    if not tbActSetting.bGoldSkipTimes or not bUseGold then
        if not pPlayer.nSendBlessTimes then
            pPlayer.nSendBlessTimes = self:GetSendTimes(tbData, tbActSetting.bGoldSkipTimes)
        end
        if pPlayer.nSendBlessTimes >= self.nMAX_SEND_TIMES then
            pPlayer.CenterMsg(string.format("每天最多贈送%d次", self.nMAX_SEND_TIMES))
            return
        end
    end
    
    if tbActSetting.bRank then
        local nCurHasCount = SendBless:GetNowMaxSendTimes(pPlayer)
        if nCurHasCount <= 0 then
            pPlayer.CenterMsg("您當前可用祝福次數不足")
            return
        end
    end

    local bInProcess = Activity:__IsActInProcessByType(tbActSetting.szActName)
    if not bInProcess then
        pPlayer.CenterMsg("本輪活動已經結束")
        return
    end

    return true, nCurHasCount
end


-- dwRoleId1 送给 dwRoleId2 的
function SendBless:GetSendBlessVal(dwRoleId1, dwRoleId2, pRole1, pRole2)
    local nScore = 1;
    local tbActSetting = self:GetActSetting()
    if not tbActSetting.bRank then
        return nScore
    end
    local nFriendLevel = FriendShip:GetFriendImityLevel(dwRoleId1, dwRoleId2)
    local nAddScore = 0
    for i,v in ipairs(self.tbImityScore) do
        if nFriendLevel >= v[1] then
            nAddScore = v[2]
        else
            break;
        end
    end
    nScore = nScore + nAddScore;

    local nSenderHonorLevel = pRole1.nHonorLevel
    nScore = nScore + (self.tbHonorScore[nSenderHonorLevel] or 0)
    if pRole1.dwKinId ~= 0 and pRole1.dwKinId == pRole2.dwKinId then
        nScore = nScore + 1
    end
    if TeacherStudent:_IsConnected(pRole1, pRole2) then
       nScore = nScore + 1 
    end

    return nScore;
end


function SendBless:GetCurAwardLevel(pPlayer, tbGet)
    local nHasTakedLevel = pPlayer.GetUserValue(self.SAVE_GROUP, self.KEY_TakeAwardLevel)
    local nNewLevel = nHasTakedLevel + 1;
    local tbAwardInfo = self.tbTakeAwardSet[nNewLevel]
    if not tbAwardInfo then
        return
    end
    local nTotalVal = SendBless:GetScoreInfo(tbGet)
    if nTotalVal < tbAwardInfo.nScore then
        return
    end

    return nNewLevel, tbAwardInfo.tbAward
end

function SendBless:GetActSetting()
    if self.TryGetCurType then
        self:TryGetCurType();
    end
        
    return SendBless.tbActSetting[self.nType]
end

