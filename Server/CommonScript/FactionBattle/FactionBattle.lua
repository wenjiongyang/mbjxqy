FactionBattle.FactionMonkey = FactionBattle.FactionMonkey or {}

-- 大师兄相关

FactionBattle.MONKEY_VOTE_TIME = 24 		   			-- 活动开启后允许投票的小时
FactionBattle.MONKEY_SESSION_LIMIT_COUNT = 3 	   		-- 举行超过几届门派竞技开始
FactionBattle.MONKEY_START_DAY = 1 						-- 活动每月几号开启
FactionBattle.MONKEY_END_DAY = 2 						-- 活动每月几号结束

FactionBattle.tbHonorVoteScore = 						-- 每票 头衔得分
{
	[0] = 1,
	[1] = 1,
	[2] = 2,
	[3] = 4,
	[4] = 8,
	[5] = 16,
	[6] = 32,
	[7] = 64,
	[8] = 128,
	[9] = 256,
	[10] = 512,
	[11] = 1024,
	[12] = 2048,
	[13] = 4096,
}

FactionBattle.tbFactionMonkeyReward = {{"Item", 3358, 1}}

FactionBattle.MAX_VOTE 	 = 1 							-- 最大投票次数

FactionBattle.MONKEY_TITLE_ID = 						-- 称号ID
{
	[1] = 311,
	[2] = 314,
	[3] = 313,
	[4] = 312,
	[5] = 315,
	[6] = 316,
	[7] = 317,
	[8] = 318,
	[9] = 319,
	[10] = 320,
	[11] = 322,
	[12] = 324,
	[13] = 326,
	[14] = 328,
}

FactionBattle.MONKEY_TITLE_TIMEOUT = 30 * 24 * 60 * 60 	-- 称号过期时间

FactionBattle.nNewInfomationValidTime = 7 * 24 * 60 * 60 	-- 最新消息过期时间（距离推送时间）

FactionBattle.tbMailSetting =
{
	[1] = {szTitle = "掌門的賀信",szText = "    做得很好！你已經歷生死較量，又得軍心所向！此後你就是我天王的大師兄，勤加練習，將來必能成為名動一方的豪俠，只是切勿沾沾自喜，與同門相處也莫要盛氣凌人，將無兵卒，又有何用？謹記。"},
	[2] = {szTitle = "掌門的賀信",szText = "    峨嵋派一向以相互扶助，救死扶傷為己任，如今你成為了峨嵋大師姐，更是應當凡事心懷善念，一切以大局為重。同門之中，你武功最高，自然不免多擔待一些，要保護好同門。任重而道遠，不可懈怠。"},
	[3] = {szTitle = "掌門的賀信",szText = "    我桃花創立不過數十載，卻已有你這般優秀的人才，著實令人欣喜不已，今日你成為桃花的大師姐，武藝自然是冠絕同門，可要切記勿要藏私，多與同門姐妹交流，桃花盛放所依者，是諸位的一同努力。"},
	[4] = {szTitle = "掌門的賀信",szText = "    做得不錯，此番較技，稱得上是瀟灑自如，而與諸位同門之間的情誼，也助你成就今日之名。既身為大師兄，自然是樣樣都要強於同門，此事雖不易，然既入我門下，理應如此，否則如何能逍遙自在？"},
	[5] = {szTitle = "掌門的賀信",szText = "    如今戰火不斷，天下紛亂，值此多事之秋，我派能夠有你如此傑出的弟子，實在令老道欣慰，將來這掌門之位，不免從你們這些年輕弟子中選中，還望你除了修行武功，更需修心養性，切不可過於自負。"},
	[6] = {szTitle = "掌門的賀信",szText = "    哼，有點意思，能從同門中脫穎而出，說明你天賦卓絕，已掌握我天忍之精髓，所欠缺的，不過是時間，待得技藝日漸成熟，將來天下之中，已無你不可暗殺之人，終有一日，你會成為天忍最鋒銳的刃。"},
	[7] = {szTitle = "掌門的賀信",szText = "    阿彌陀佛，善哉善哉。如今你學藝有成，技冠同門，自是令人欣喜，然需謹防心魔，戒驕戒躁，不可放下佛法修行，不可心高氣傲，同門之間，多加指導，相互印證，佛武並修，未來自當如虎添翼。"},
	[8] = {szTitle = "掌門的賀信",szText = "    卿之技藝，已日漸成熟，同門翹楚甚多，卻獨你一人青出於藍而勝於藍，行走江湖，四處歷練之際，需多加小心，莫要輕易相信他人，男女皆然。還有，照顧好那只小傢伙，它才是你最忠誠的同伴。"},
	[9] = {szTitle = "掌門的賀信",szText = "    哼，你既身為唐門子弟，理應為唐家堡名揚武林盡一份力，總算是你天資頗佳，不負我等期望，去吧，要記住，韜光養晦如此之久，而你，要成為青年名俠中的翹楚，方乃我唐門踏出武林的第一步。"},
	[10] = {szTitle = "掌門的賀信",szText = "   不錯不錯，我崑崙韜光養晦如此之久，近些年來總算是出了這般優秀的子弟，你長年累月在這極寒之地修煉，著實不易，而今能在眾多同門中脫穎而出，絕非僥倖，還得多在江湖走動，日後必成大器。"},
	[11] = {szTitle = "掌門的賀信",szText = "   丐幫自創立以來，數百年來被稱為天下第一大幫，靠的並非冠絕武林的功夫，除了武林同道給面子，最重要的便是幫眾弟子相互扶持，你既是其中翹楚，更應謹守此道，戒驕戒躁，方能一方有難，八方支援。"},
	[12] = {szTitle = "掌門的賀信",szText = "   哼，我等偏居一隅，卻叫中原武林小瞧，道什麼五毒教，如此也好，如今你學藝有成，是教中年輕一輩掌控五聖蠱最嫺熟者，也是時候還以顏色，讓那些中原蠻子知道我教中五聖的厲害！去吧，記住，一切小心！"},
	[13] = {szTitle = "掌門的賀信",szText = "   我藏劍山莊始于唐而興于唐，如今經歷卓非凡之禍，武林對於藏劍頗有微辭，然此並非武學衰敗，亦非我藏劍無人，如今你身負重振藏劍之名的重任，還望你此後仗劍江湖，能夠處處留心，讓江湖眾人都知道，我藏劍山莊，劍心依舊。"},
	[14] = {szTitle = "掌門的賀信",szText = "   長歌始于唐，原本乃風雅之地，承蒙各路文人異客集思廣益，悟得獨到武學，以此創立長歌，如今你已是門中第一人，還望你莫忘初心，習武之餘，切不可放下一門技藝，此乃長歌區別於他派之根本。"},
}

FactionBattle.MonkeyNamePrefix =
{
	[1] = "#964",
	[2] = "#963",
	[3] = "#961",
	[4] = "#962",
	[5] = "#960",
	[6] = "#959",
	[7] = "#957",
	[8] = "#958",
	[9] = "#950",
	[10]= "#951",
	[11]= "#946", 
	[12]= "#947", 
	[13]= "#938", 
	[14]= "#939", 
}

FactionBattle.SAVE_GROUP_MONKEY  = 96
FactionBattle.KEY_VOTE			 = 1
FactionBattle.KEY_STARTTIME		 = 2

function FactionBattle:CheckCommondVote(pPlayer)
	-- 检查投票次数
	if self:RemainVote(pPlayer) <= 0 then
		return false,"您已經沒有投票次數"
	end

	return true
end

function FactionBattle:RemainVote(pPlayer)
	return pPlayer.GetUserValue(FactionBattle.SAVE_GROUP_MONKEY, FactionBattle.KEY_VOTE);
end

function FactionBattle:IsMonkey(pPlayer)
	pPlayer = pPlayer or me;
	local tbTitleData = PlayerTitle:GetPlayerTitleData(pPlayer);
	for _, tbTitle in pairs(tbTitleData.tbAllTitle) do
		if tbTitle.nTitleID == FactionBattle.MONKEY_TITLE_ID[pPlayer.nFaction] then
			return true
		end
	end
	return false
end

function FactionBattle:GetMonkeyNamePrefix(nFaction)
	return FactionBattle.MonkeyNamePrefix[nFaction] or ""
end
