--圣诞礼物
local tbAct = Activity:GetClass("ChristmasGift")

tbAct.MAX_RATE = 1000000
tbAct.tbMapInfo = {
    --[10 地图模板id] = {nRate --产生概率, {nPosX --坐标X, nPosY --坐标Y}}
    [300] = {nRate = 500000, nPosX = 3680, nPosY = 6592}, --藏剑山庄
    [301] = {nRate = 500000, nPosX = 2000, nPosY = 8484}, --武夷禁地
    [302] = {nRate = 500000, nPosX = 4460, nPosY = 7092}, --熔火霹雳
    [303] = {nRate = 500000, nPosX = 2332, nPosY = 3453}, --翠竹幽谷
    [304] = {nRate = 500000, nPosX = 3659, nPosY = 2458}, --呼啸栈道

    [201] = {nRate = 1000000, nPosX = 3939, nPosY = 1639}, --a1
    [220] = {nRate = 1000000, nPosX = 4035, nPosY = 2690}, --b10
    [225] = {nRate = 1000000, nPosX = 1062, nPosY = 1375}, --c5
    [240] = {nRate = 1000000, nPosX = 4959, nPosY = 5237}, --d10
    [244] = {nRate = 1000000, nPosX = 3076, nPosY = 5722}, --e4
    [260] = {nRate = 1000000, nPosX = 4053, nPosY = 2001}, --f10
    [270] = {nRate = 1000000, nPosX = 1139, nPosY = 6564}, --g10

    [500] = {nRate = 500000, nPosX = 3276, nPosY = 3158}, --山贼秘窟

    [600] = {nRate = 500000, nPosX = 2059, nPosY = 4864}, --藏宝地宫
}
tbAct.nGiftNpcTID = 2123 -- 圣诞老人模板ID
tbAct.nGiftItemTID = 3527 -- 圣诞礼物道具模板ID
tbAct.nRequireLevel = 20

tbAct.tbTimerTrigger = 
{
    [1] = {szType = "Day", Time = "10:00" , Trigger = "SendWorldNotify" },
    [2] = {szType = "Day", Time = "13:00" , Trigger = "SendWorldNotify" },
    [3] = {szType = "Day", Time = "19:00" , Trigger = "SendWorldNotify" },
}
tbAct.tbTrigger = { Init = { }, 
                    Start = { {"StartTimerTrigger", 1}, {"StartTimerTrigger", 2}, {"StartTimerTrigger", 3}, },
                    SendWorldNotify = { {"WorldMsg", "各位俠士，[FFFE0D]元旦、聖誕[-]雙節同慶活動開始了，大家可通過查詢「[FFFE0D]最新消息[-]」了解活動內容！", 1} },
                    End = { }, }
function tbAct:OnTrigger(szTrigger)
    if szTrigger == "Init" then
        self:SendNews()
    elseif szTrigger == "Start" then
        Activity:RegisterGlobalEvent(self, "Act_OnMapCreate", "OnMapCreate")
        Activity:RegisterNpcDialog(self, self.nGiftNpcTID,  {Text = "領取聖誕禮物", Callback = self.OnNpcDialog, Param = {self}})
        Activity:RegisterNpcDialog(self, self.nGiftNpcTID,  {Text = "瞭解詳情", Callback = self.OpenClientUi, Param = {self}})
    end
end

function tbAct:OnNpcDialog()
    if me.nLevel < self.nRequireLevel then
        me.CenterMsg(string.format("請先將等級提升到%d級！", self.nRequireLevel))
        return
    end
    him.tbGetList = him.tbGetList or {}
    if him.tbGetList[me.dwID] then
        me.CenterMsg("你已經領取過我給的禮物，不要貪心!")
        return
    end

    him.tbGetList[me.dwID] = true
    me.SendAward({{"Item", self.nGiftItemTID, 1}}, true, false, Env.LogWay_ChristmasGift)
end

function tbAct:OpenClientUi()
    me.CallClientScript("Ui:OpenWindow", "NewInformationPanel", "ShuangJieTongQing")
end

function tbAct:OnMapCreate(nMapTID, nMapID)
    local tbInfo = self.tbMapInfo[nMapTID]
    if not tbInfo then
        return
    end

    local nRate = MathRandom(self.MAX_RATE)
    if nRate > tbInfo.nRate then
        return
    end

    local pNpc = KNpc.Add(self.nGiftNpcTID, 1, -1, nMapID, tbInfo.nPosX, tbInfo.nPosY)
    Log("ChristmasGift OnMapCreate And CreateNpc Success", nMapTID, nMapID, pNpc.nId)
end

function tbAct:SendNews()
    local szNewInfoMsg = [[
[FFFE0D]元旦、聖誕雙節同慶活動開始了！[-]
    [FFFE0D]活動時間[-]：2016年12月24日4點~~2017年1月3日24點
    [FFFE0D]參與等級[-]：20級
    
    [FFFE0D]1、打雪仗[-]
    活動期間每日[FFFE0D]13：30[-]、[FFFE0D]16：00[-]及[FFFE0D]20：00[-]會開啟[FFFE0D]3場[-]打雪仗活動，每場報名時間[FFFE0D]5分鐘[-]，請通過「[FFFE0D]活動[-]」日曆界面，[FFFE0D]單人或組隊[-]報名進入準備場等待比賽開啟。
    每人每天有[FFFE0D]1次[-]機會，可以累積到[FFFE0D]3次[-]，額外的參加次數可用道具[11adf6][url=openwnd:烈焰飛雪, ItemTips, "Item", nil, 3536][-]換取。
    進入比賽場會[FFFE0D]變身[-]為小孩，並獲得一個「[FFFE0D]扔雪球[-]」的技能，用其攻擊敵方隊伍可以獲得[FFFE0D]積分[-]，比賽結束時積分多的隊伍獲勝。雪地上會出現雪人、陷阱以及神符，採集可以獲得其他[FFFE0D]強力技能[-]。
    [FFFE0D]注意事項[-]：小心山頂棲息的年獸！

    [FFFE0D]2、元旦雪人[-]
    活動期間，[FFFE0D]幫派屬地[-]會出現一個[FFFE0D]雪人[-]，[FFFE0D]幫派烤火[-]開始時可找其領取一個[11adf6][url=openwnd:雪人禮盒, ItemTips, "Item", nil, 3533][-]。
    幫派烤火[FFFE0D]答題[-]時，能夠得到[11adf6][url=openwnd:雪花, ItemTips, "Item", nil, 3532][-]，可去找雪人進行「[FFFE0D]堆雪人[-]」的操作，能獲得[FFFE0D]經驗[-]獎勵。
    雪人堆積一定次數，可以[FFFE0D]升級變大[-]，同時，對[FFFE0D]上一等級[-]雪人進行過「[FFFE0D]堆雪人[-]」操作的幫派成員能獲得額外的「[FFFE0D]雪人禮盒[-]」。
    
    [FFFE0D]3、聖誕禮物[-]
    活動期間，在[FFFE0D]組隊秘境[-]、[FFFE0D]凌絕峰[-]、[FFFE0D]山賊秘窟[-]及[FFFE0D]挖寶[-]出現的地宮中，可能遇到[FFFE0D]聖誕老人[-]，與其對話可以獲得聖誕禮物[11adf6][url=openwnd:聖誕襪子, ItemTips, "Item", nil, 3527][-]，打開能獲得豐厚獎勵，或許有機會獲得[11adf6][url=openwnd:聖誕糖果, ItemTips, "Item", nil, 3535][-]。
    ]]

    local nEndTime = Activity:GetActEndTime(self.szKeyName)
    NewInformation:AddInfomation("ShuangJieTongQing", nEndTime, {szNewInfoMsg}, { szTitle = "雙節同慶"})
end

--礼盒传情
local tbLHAct = Activity:GetClass("LiHeChuanQing")
tbLHAct.tbJoinActInfo = {
    Rank = 10000,
}
tbLHAct.nBoxTID = 10
tbLHAct.MAX_RATE = 1000000

tbLHAct.tbTrigger = { Init = { }, Start = { }, End = { }, }
function tbLHAct:OnTrigger(szTrigger)
    if szTrigger == "Start" then
        Activity:RegisterPlayerEvent(self, "Act_OnJoinAct", "OnJoinAct")
    end
end

function tbLHAct:OnJoinAct(pPlayer, szAct)
    if not self.tbJoinActInfo[szAct] then
        return
    end

    local nRate = MathRandom(self.MAX_RATE)
    if nRate > self.tbJoinActInfo[szAct] then
        return
    end

    pPlayer.SendAward({{"Item", self.nBoxTID, 1}}, true, false, Env.LogWay_LiHeChuanQing)
    Log("ChristmasGift OnJoinAct And SendAward", pPlayer.dwID, szAct)
end