if not MODULE_GAMESERVER then
    Activity.Qixi = {}
end
local tbAct = MODULE_GAMESERVER and Activity:GetClass("Qixi") or Activity.Qixi

tbAct.Def = {
    BAIXING_AWARDS_ID = 2701, --拜星奖励
    BAIXING_EXT_AWARDS = {{"BasicExp", 2}}, --每次拜星读条奖励
    BAIXING_HELP_AWARDS = {{"Contrib", 200}},
    BAIXING_EXT_TIMES = 15, --总共读条次数
    BAIXING_EXT_INTERVAL = 6, --每次读条时间

    IMITITY_BAIXING = 500,
    IMITITY_SENDGIFT = 200,

    --SEND_GIFT_AWARD = {{"Coin", 100}}, --赠送奖励
    --GAIN_GIFT_AWARD = {{"Coin", 100}}, --被赠奖励

    EVERY_AWARD = { {"Item", 2684, 1}, {"Item", 2685, 1}, {"Item", 2686, 1}, {"Item", 2687, 1} }, --每日目标奖励
    SEND_ITEM = { {[2688] = 2689}, {[2690] = 2691} }, --道具赠送对应关系

    IMITYLEVEL = 2,  --亲密度
    OPEN_LEVEL = 20, --开启等级

    CHANGE_ITEM_TIMES    = 1, --每天交换七色玄香次数
    HELP_AWARD_TIMES     = 2, --协助烧香有奖励次数

    ACTIVITY_TIME_BEGIN = Lib:ParseDateTime("2016/8/9"), --开始时间
    ACTIVITY_TIME_END   = Lib:ParseDateTime("2016/8/15 23:59:59"), --结束时间

    CHAT_GIFT = {
        [2688] = "送你美麗的花朵，我們把酒共賞！",
        [2689] = "謝謝[%s]送的禮物，我很喜歡！",
        [2690] = "小詩一首，名劍一把，伴君走天涯！",
        [2691] = "謝謝[%s]送的禮物，我很喜歡！",
    },

    ITEM_TIP = {
        [2689] = "[FFFE0D][%s][-]送給我的禮物，花有附言：[FFFE0D]贈卿一花，把酒共賞[-]",
        [2691] = "[FFFE0D][%s][-]送給我的禮物，詩箋有雲：[FFFE0D]贈君名劍，伴君天涯[-]",
    },

    WORLD_NOTIFY = "各位俠士，浪漫情人節活動開始了，大家可通過[FFFE0D]完成每日目標[-]及進行[FFFE0D]幫派貢獻[-]獲得相應道具參加活動。詳情請查詢最新消息相關介紹內容！",

-----------------------------------以上为策划配置项-----------------------------------

    SAVE_GROUP            = 59,
    DATA_LOCALDAY_KEY     = 1,
    CHANGE_ITEM_TIMES_KEY = 2,
    HELP_AWARD_TIMES_KEY  = 3,
}

function tbAct:IsInActivityTime()
    return GetTime() >= self.Def.ACTIVITY_TIME_BEGIN and GetTime() < self.Def.ACTIVITY_TIME_END
end

function tbAct:CommonCheck(tbMyInfo, tbHelperInfo)
   if Gift:CheckSex(tbMyInfo[1]) == Gift:CheckSex(tbHelperInfo[1]) or not FriendShip:IsFriend(tbMyInfo[2], tbHelperInfo[2]) then
        return nil, "非異性好友"
    end

    local nImityLevel = FriendShip:GetFriendImityLevel(tbMyInfo[2], tbHelperInfo[2]) or 0
    if nImityLevel < self.Def.IMITYLEVEL then
        return nil, string.format("親密度需要%d級", self.Def.IMITYLEVEL)
    end

    local nLevel = self.Def.OPEN_LEVEL
    if tbMyInfo[3] < nLevel or tbHelperInfo[3] < nLevel then
        return nil, "等級不足"
    end

    return true
end