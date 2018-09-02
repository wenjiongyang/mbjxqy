if not MODULE_GAMESERVER then
    Activity.QingMingAct = Activity.QingMingAct or {}
end
local tbAct = MODULE_GAMESERVER and Activity:GetClass("QingMingAct") or Activity.QingMingAct

tbAct.szFubenClass = "QingMingFubenBase"
tbAct.nSitSkill  = 1083 					-- 打坐动作
tbAct.nEffectId = 1086 						-- 修炼身上的特效

tbAct.nWorshipTimes = 10 					-- 祭拜一共加5次经验
tbAct.nWorshipDelayTime = 6 				-- 6秒加一次经验
tbAct.nWorshipAddExpRate = 3			-- 经验倍率

-- 领活跃奖励
tbAct.tbActiveAward = {[1] = {{"item", 4426, 1}}, [2] = {{"item", 4426, 1}}, [3] = {{"item", 4426, 1}}, [4] = {{"item", 4426, 1}}, [5] = {{"item", 4426, 1}}};
-- 合成地图需要几个线索
tbAct.nClueCompose = 5
-- 线索道具模板ID
tbAct.nClueItemTID = 4426
-- 地图道具模板ID
tbAct.nMapItemTID = 4425
-- 活动中所有用到的地图信息
tbAct.tbMapInfo = {
	{nMapTID = 1602, szName = "心魔幻境·忘憂島",   --[[szTip = "",]] szIntrol = "無憂教當代教主，納蘭真及月眉兒的父親，是個徹頭徹尾的野心家，為了自己的目的而不擇手段，罔顧親情愛情，弑師害兄，最終獨霸無憂教，其境界高深武功更是出神入化，一直覬覦《武道德經》。後與楊影楓決鬥，落敗身隕。\n"},
	{nMapTID = 1603, szName = "心魔幻境·鳳凰山",   --[[szTip = "",]] szIntrol = "獨孤劍的戀人，“飛劍客”張風之女，張如夢之妹。她從來未曾想到一見鍾情的少年，竟與自己有血海深仇，徒自黯然神傷。當誤會被解開後，就一心跟著獨孤劍，以稚嫩的肩膀與他一起擔負拯救家國、為父報仇的使命。\n"},
	{nMapTID = 1604, szName = "心魔幻境·淩絕峰",   --[[szTip = "",]] szIntrol = "月眉兒之父，飛龍堡前堡主，江湖人稱「北上官，南熙烈」的武林兩大使劍高手之一，為人成熟穩重，不喜爭鬥，劍法也是走的沉穩一路，招式環環相扣，使敵人不知不覺陷入絕地。在淩絕峰被迫接受楊熙烈的挑戰，兩人全力相鬥，雙雙殞命。\n"},
	{nMapTID = 1605, szName = "心魔幻境·劍氣峰",   --[[szTip = "",]] szIntrol = "藏劍山莊莊主，武林中新一輩青年俊傑，英俊瀟灑，文武雙全，江湖上人人敬仰。實則城府極深，為得到《武道德經》，不惜派遣侍妾紫軒勾引楊影楓，陰謀敗露後更是將楊影楓打下劍氣峰。但他沒想到楊影楓墜落劍氣峰不但未死還武功大進，最終在與楊比武時含恨殞命。\n"},
	{nMapTID = 1606, szName = "心魔幻境·淩絕峰",   --[[szTip = "",]] szIntrol = "楊影楓之父，江湖人稱「北上官，南熙烈」的武林兩大使劍高手之一，為人豪爽，重情義，但有時興之所至，不顧他人感受，性格如同其劍招，咄咄逼人，不留餘地。後在淩絕峰與上官飛龍比武，勝負難分，力竭殞命。\n"},
	{nMapTID = 1607, szName = "心魔幻境·落葉穀",   --[[szTip = "",]] szIntrol = "落葉谷主，也是武林中眾人推舉的盟主，薔薇之父。武功極高，江湖上已少有人能與之比劍，為人沉穩，相信只要心懷大志，遲早能夠名動天下。後納蘭潛凜血洗武林，孟知秋寡不敵眾，英年早逝。\n"},
	{nMapTID = 1608, szName = "心魔幻境·臨安郊外", --[[szTip = "",]] szIntrol = "江湖四大劍客「天心飛仙」之「飛劍客」，張如夢和張琳心之父，南宋臨安都指揮使。與「仙劍客」獨孤雲一起前往金國意圖救出徽欽二帝，後敗露，為保護「山河社稷圖」假裝被「天劍客」南宮滅收買，親手殺死受盡折磨、生不如死的至交好友「仙劍客」獨孤雲。忍辱偷生多年，後命喪南宮滅之手。\n"},
	{nMapTID = 1609, szName = "心魔幻境·武當山",   --[[szTip = "",]] szIntrol = "武當前代掌門人，與武林盟主孟知秋是至交。武林名宿，得道高人，傳言其武功得玄天道人指點，深不可測，在江湖上聲望極高，曾受邀見證楊影楓戳穿卓非凡陰謀的生死決鬥。後來，楊影楓成功摧毀納蘭潛凜的驚天奇謀，也得到了他的極大幫助。\n"},
	{nMapTID = 1610, szName = "心魔幻境·風波亭",   --[[szTip = "",]] szIntrol = "南宋中興四將之一，抗金名將，著名軍事家、戰略家、民族英雄，南宋最傑出的統帥，締造“連結河朔”，主張民間抗金義軍和宋軍互相配合夾擊金軍以收復失地。嶽飛治軍賞罰分明，紀律嚴整，又能體恤部屬，以身作則，其「岳家軍」號稱「凍死不拆屋，餓死不打擄」，金人流傳「撼山易，撼岳家軍難」\n"},
}
-- 玩家自己可能使用地图道具的次数，会根据这个次数提前随好所有地图ID
tbAct.nMaxUseMap = 6
-- 使用地图道具需达到的亲密度
tbAct.nUseMapImityLevel = 5
-- 双方距离
tbAct.MIN_DISTANCE = 1000
-- 协助次数刷新时间点
tbAct.nAssistRefreshTime = 4 * 60 * 60
-- 每天最多可协助次数
tbAct.nMaxAssistCount = 1
-- 参与等级
tbAct.nJoinLevel = 20
-- 协助奖励
tbAct.tbAssistAward = {{"Contrib", 200}}
-- 每天捐献可获得的线索奖励,刷新时间点为协助次数刷新时间点
tbAct.nMaxClueDonatePerDay = 5
-- 每五次捐献的奖励
tbAct.tbDonateAward = {{"item", 4426, 1}}
-- 缅怀奖励
tbAct.tbWorshipAward = {{"item", 4428, 1}}
-- 每天可领取的最大缅怀奖励
tbAct.nMaxWorshipPerDay = 6

assert(#tbAct.tbMapInfo > 0 and tbAct.nMaxUseMap > 0, "[QingMingAct] assert setting fail " ..tbAct.nMaxUseMap .. #tbAct.tbMapInfo)

local nMaxBubbleCount = 10

function tbAct:InitSetting()
	self.tbMapSetting  = {}
	for _, tbInfo in ipairs(self.tbMapInfo) do
		self.tbMapSetting[tbInfo.nMapTID] = tbInfo
	end
end

tbAct:InitSetting()

function tbAct:GetMapSetting(nMapTID)
	return self.tbMapSetting[nMapTID]
end

function tbAct:CheckLevel(pPlayer)
	return pPlayer.nLevel >= self.nJoinLevel
end

function tbAct:OnLeaveWorshipMap()
	Ui:CloseWindow("HomeScreenFuben")
	Ui:CloseWindow("ChuangGongPanel")
end