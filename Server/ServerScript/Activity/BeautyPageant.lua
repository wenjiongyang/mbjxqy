Require("CommonScript/Activity/BeautyPageant.lua");

local tbAct = Activity:GetClass("BeautyPageant")

--本服冠军雕像有效期3个月
tbAct.nLocalStatueTimeOut = 3*30*24*60*60

tbAct.tbTimerTrigger = 
{
	--[1] = {szType = "Day", Time = "10:35" , Trigger = "OnWorldNotify" },  --因为发奖是在10点以后，取消该时间点的世界公告
	[1] = {szType = "Day", Time = "12:10" , Trigger = "OnWorldNotify" },
	[2] = {szType = "Day", Time = "16:10" , Trigger = "OnWorldNotify" },
	[3] = {szType = "Day", Time = "19:27" , Trigger = "OnWorldNotify" },
	[4] = {szType = "Day", Time = "22:42" , Trigger = "OnWorldNotify" },
	[5] = {szType = "Day", Time = "00:05", Trigger = "CheckLocalResultInfo"},-- 如果在间歇期中间时间还没公布结果的最新消息这里直接发
	[6] = {szType = "Day", Time = "00:05", Trigger = "CheckFinalResultInfo"},-- 如果在间歇期中间时间还没公布结果的最新消息这里直接发
}

tbAct.tbTrigger = { 
	Init = { }, 
	Start = { {"StartTimerTrigger", 1}, {"StartTimerTrigger", 2}, {"StartTimerTrigger", 3},
		 {"StartTimerTrigger", 4}, {"StartTimerTrigger", 5}, {"StartTimerTrigger", 6}, {"StartTimerTrigger", 7}},
	OnWorldNotify = {},
	End = { },
}

--每日礼包赠送投票道具数量
tbAct.DailyGiftVote = 
{
	[Recharge.DAILY_GIFT_TYPE.YUAN_1] = 1,
	[Recharge.DAILY_GIFT_TYPE.YUAN_3] = 2,
	[Recharge.DAILY_GIFT_TYPE.YUAN_6] = 3,
	[Recharge.DAILY_GIFT_TYPE.YUAN_10] = 6,
}

--周卡月卡赠送投票道具数量
tbAct.DaysCardVote = 
{
	[Recharge.DAYS_CARD_TYPE.DAYS_7] = 18,
	[Recharge.DAYS_CARD_TYPE.DAYS_30] = 30,
}

--充值元宝对应赠送投票道具比例
tbAct.nRechargeGoldVote = 300;

--充值获得黎饰对应赠送投票道具比例
--98元送1000黎饰
tbAct.nRechargeSilverBoardVote = 30;

--本服排行奖励
tbAct.tbLocalWinnerAward = 
{
	[1] =  --海选第一
	{
		{"AddTimeTitle", 7202, Lib:ParseDateTime("2018-06-23 12:00:00")},
		{"Item", 4835, 1},  --礼包
	},

	[2] =  --海选前十 
	{
		{"AddTimeTitle", 7203, Lib:ParseDateTime("2018-06-23 12:00:00")},
		{"Item", 4836, 1},  --礼包
	},
}

--全服排行奖励
tbAct.tbFinalWinnerAward = 
{
	[1] =  --决赛第一
	{
		{"AddTimeTitle", 7200, Lib:ParseDateTime("2018-07-03 00:00:00")},
		{"Item", 4833, 1},  --礼包
	},

	[2] =   --决赛前十
	{
		{"AddTimeTitle", 7201, Lib:ParseDateTime("2018-07-03 00:00:00")},
		{"Item", 4834, 1},  --礼包
	},
}

--海选赛投票参与奖励（199票）
tbAct.tbParticipateAward = 
{
	{"AddTimeTitle", 7204, Lib:ParseDateTime("2018-06-23 12:00:00")},
	{"Item", 4824, 1},  --头像
	{"Energy", 15000},
}

--决赛投票参与奖励（8000票）
tbAct.tbFinalParticipateAward = 
{
	{"AddTimeTitle", 7205, Lib:ParseDateTime("2018-07-03 00:00:00")},
	{"Item", 5252, 1},  --前缀
	{"Item", 4838, 1},  --地毯
	{"Item", 4820, 1},  --头像
	{"Energy", 30000},
}

tbAct.tbWorldNotify = 
{
	--报名阶段
	[tbAct.STATE_TYPE.SIGN_UP] = "「武林第一美女評選」正在火熱接受報名中，諸位女俠可前往襄陽城紫軒處報名",  
	--海选赛
	[tbAct.STATE_TYPE.LOCAL] = "「武林第一美女評選」海選賽（本服評選）正在進行中，快去給你們心目中的女神投上一票吧！未報名的女俠可前往襄陽城紫軒處報名。",  
	--海选赛展示
	[tbAct.STATE_TYPE.LOCAL_REST] = "「武林第一美女評選」海選賽（本服評選）前十已經產生，「本服第一美女」雕像已在紫軒處樹立，快去一睹芳容吧！",
	--决赛
	[tbAct.STATE_TYPE.FINAL] = "「武林第一美女評選」決賽（跨服評選）正在進行中，快去給你們心目中的女神投上一票吧！",
	--决赛展示
	[tbAct.STATE_TYPE.FINAL_REST] = "「武林第一美女評選」決賽（跨服評選）前十已經產生，「武林第一美女」雕像已在紫軒處樹立，快去一睹芳容吧！",
}

tbAct.tbNpcBubble = 
{
	[tbAct.STATE_TYPE.SIGN_UP] = --报名阶段
	{
		--紫轩
		--[[{nNpcTemplate=622, nMapId=10, szDateTime={"00:00:00", "23:59:59"}, szContent="「武林第一美女评选」火热接受报名中，报名阶段将于[FFFE0D]2017年6月21日[-]结束。"},

		--小紫烟
		{nNpcTemplate=95, nMapId=10, szDateTime={"00:00:00", "23:59:59"}, szContent="紫轩姐姐说小女孩不能参加「武林第一美女评选」，哼哼~"},
		--张琳心
		{nNpcTemplate=621, nMapId=10, szDateTime={"00:00:00", "23:59:59"}, szContent="听闻「武林第一美女评选」海选赛已经开始报名了，我也得启程前去参赛了。"},
		--唐影
		{nNpcTemplate=620, nMapId=10, szDateTime={"00:00:00", "23:59:59"}, szContent="「武林第一美女评选」的参赛选手里，那翠烟门门主倒是有几分姿色。"},
		--小殷方
		{nNpcTemplate=623, nMapId=10, szDateTime={"00:00:00", "23:59:59"}, szContent="哇！紫轩姐姐那里好热闹啊，都是漂亮的小姐姐，想必是为那「武林第一美女评选」而去的吧。"},
		--杨瑛
		{nNpcTemplate=633, nMapId=10, szDateTime={"00:00:00", "23:59:59"}, szContent="若有机会，我也想去见识一下襄阳城当下的盛事「武林第一美女评选」。"},
		--纳兰真
		{nNpcTemplate=90, nMapId=10, szDateTime={"00:00:00", "23:59:59"}, szContent="嘿~影枫哥哥，你会支持我的对吧？嘻嘻……"},
		--月眉儿
		{nNpcTemplate=97, nMapId=10, szDateTime={"00:00:00", "23:59:59"}, szContent="真儿妹妹，「武林第一美女评选」我可不会让着你。"},
		--杨影枫
		{nNpcTemplate=624, nMapId=10, szDateTime={"00:00:00", "23:59:59"}, szContent="真儿和眉儿都报名了「武林第一美女评选」，我该支持谁呢？真头疼……"},
		--万金财
		{nNpcTemplate=190, nMapId=10, szDateTime={"00:00:00", "23:59:59"}, szContent="嘿嘿~本届「武林第一美女评选」由我万某人的商会独家赞助，奖励丰厚，有意的女侠快快前去报名吧。"},
		--公孙惜花
		{nNpcTemplate=99, nMapId=10, szDateTime={"00:00:00", "23:59:59"}, szContent="近日襄阳城内正在举办「武林第一美女评选」，我这「隐香楼」可收集了不少赛事情报哟~"},
		--秋依水
		{nNpcTemplate=694, nMapId=10, szDateTime={"00:00:00", "23:59:59"}, szContent="以我翠烟门弟子的姿色，「武林第一美女」定是我门下的弟子。"},
		--武僧
		{nNpcTemplate=1829, nMapId=10, szDateTime={"00:00:00", "23:59:59"}, szContent="阿尼陀佛，这几日比武场内好是冷清，想必是因为那「武林第一美女评选」吧……"},
		--祝子虚
		{nNpcTemplate=1528, nMapId=10, szDateTime={"00:00:00", "23:59:59"}, szContent="剑侠多佳人，美者颜如玉。一笑倾人城，再笑倾人国。——[FFFE0D]「武林第一美女评选」[-]"},
		--黄暮云
		{nNpcTemplate=1530, nMapId=10, szDateTime={"00:00:00", "23:59:59"}, szContent="我岛内弟子天生萌萌哒，「武林第一美女」荣誉唾手可得！"},]]
	},
	[tbAct.STATE_TYPE.LOCAL] = --海选赛
	{
		--紫轩
		{nNpcTemplate=622, nMapId=10, szDateTime={"00:00:00", "23:59:59"}, szContent="「武林第一美女評選」海選賽正在進行中，將於[FFFE0D]2017年6月23日[-]評選出[FFFE0D]「本服第一美女」[-]，快去給你們心目中的女神投上一票吧！"},

		--小紫烟
		{nNpcTemplate=95, nMapId=10, szDateTime={"00:00:00", "23:59:59"}, szContent="紫軒姐姐說小女孩不能參加「武林第一美女評選」，哼哼~"},
		--张琳心
		{nNpcTemplate=621, nMapId=10, szDateTime={"00:00:00", "23:59:59"}, szContent="聽聞「武林第一美女評選」海選賽已經開始報名了，我也得啟程前去參賽了。"},
		--唐影
		{nNpcTemplate=620, nMapId=10, szDateTime={"00:00:00", "23:59:59"}, szContent="「武林第一美女評選」的參賽選手裡，那翠煙門門主倒是有幾分姿色。"},
		--小殷方
		{nNpcTemplate=623, nMapId=10, szDateTime={"00:00:00", "23:59:59"}, szContent="哇！紫軒姐姐那裡好熱鬧啊，都是漂亮的小姐姐，想必是為那「武林第一美女評選」而去的吧。"},
		--杨瑛
		{nNpcTemplate=633, nMapId=10, szDateTime={"00:00:00", "23:59:59"}, szContent="若有機會，我也想去見識一下襄陽城當下的盛事「武林第一美女評選」。"},
		--纳兰真
		{nNpcTemplate=90, nMapId=10, szDateTime={"00:00:00", "23:59:59"}, szContent="嘿~影楓哥哥，你會支持我的對吧？嘻嘻……"},
		--月眉儿
		{nNpcTemplate=97, nMapId=10, szDateTime={"00:00:00", "23:59:59"}, szContent="真兒妹妹，「武林第一美女評選」我可不會讓著你。"},
		--杨影枫
		{nNpcTemplate=624, nMapId=10, szDateTime={"00:00:00", "23:59:59"}, szContent="真兒和眉兒都報名了「武林第一美女評選」，我該支持誰呢？真頭疼……"},
		--万金财
		{nNpcTemplate=190, nMapId=10, szDateTime={"00:00:00", "23:59:59"}, szContent="嘿嘿~本屆「武林第一美女評選」由我萬某人的商會獨家贊助，獎勵豐厚，有意的女俠快快前去報名吧。"},
		--公孙惜花
		{nNpcTemplate=99, nMapId=10, szDateTime={"00:00:00", "23:59:59"}, szContent="近日襄陽城內正在舉辦「武林第一美女評選」，我這「隱香樓」可收集了不少賽事情報喲~"},
		--秋依水
		{nNpcTemplate=694, nMapId=10, szDateTime={"00:00:00", "23:59:59"}, szContent="以我翠煙門弟子的姿色，「武林第一美女」定是我門下的弟子。"},
		--武僧
		{nNpcTemplate=1829, nMapId=10, szDateTime={"00:00:00", "23:59:59"}, szContent="阿尼陀佛，這幾日比武場內好是冷清，想必是因為那「武林第一美女評選」吧……"},
		--祝子虚
		{nNpcTemplate=1528, nMapId=10, szDateTime={"00:00:00", "23:59:59"}, szContent="劍俠多佳人，美者顏如玉。一笑傾人城，再笑傾人國。——[FFFE0D]「武林第一美女評選」[-]"},
		--黄暮云
		{nNpcTemplate=1530, nMapId=10, szDateTime={"00:00:00", "23:59:59"}, szContent="我島內弟子天生萌萌噠，「武林第一美女」榮譽唾手可得！"},
	},

	[tbAct.STATE_TYPE.LOCAL_REST] =  --海选赛休整
	{
		--紫轩
		{nNpcTemplate=622, nMapId=10, szDateTime={"00:00:00", "23:59:59"}, szContent="「武林第一美女評選」海選賽（本服評選）前十已經產生，決賽（跨服評選）將在[FFFE0D]6月26日[-]開始。"},

		--小紫烟
		{nNpcTemplate=95, nMapId=10, szDateTime={"00:00:00", "23:59:59"}, szContent="紫軒姐姐說小女孩不能參加「武林第一美女評選」，哼哼~"},
		--张琳心
		{nNpcTemplate=621, nMapId=10, szDateTime={"00:00:00", "23:59:59"}, szContent="聽聞「本服第一美女」的雕像已經在紫軒姐姐那樹立……"},
		--唐影
		{nNpcTemplate=620, nMapId=10, szDateTime={"00:00:00", "23:59:59"}, szContent="「武林第一美女評選」的參賽選手裡，那翠煙門門主倒是有幾分姿色。"},
		--小殷方
		{nNpcTemplate=623, nMapId=10, szDateTime={"00:00:00", "23:59:59"}, szContent="哇！紫軒姐姐那裡好熱鬧啊，都是漂亮的小姐姐，想必是為那「武林第一美女評選」而去的吧。"},
		--杨瑛
		{nNpcTemplate=633, nMapId=10, szDateTime={"00:00:00", "23:59:59"}, szContent="若有機會，我也想去見識一下襄陽城當下的盛事「武林第一美女評選」。"},
		--纳兰真
		{nNpcTemplate=90, nMapId=10, szDateTime={"00:00:00", "23:59:59"}, szContent="嘿~影楓哥哥，你會支持我的對吧？嘻嘻……"},
		--月眉儿
		{nNpcTemplate=97, nMapId=10, szDateTime={"00:00:00", "23:59:59"}, szContent="真兒妹妹，「武林第一美女評選」我可不會讓著你。"},
		--杨影枫
		{nNpcTemplate=624, nMapId=10, szDateTime={"00:00:00", "23:59:59"}, szContent="真兒和眉兒都報名了「武林第一美女評選」，我該支持誰呢？真頭疼……"},
		--万金财
		{nNpcTemplate=190, nMapId=10, szDateTime={"00:00:00", "23:59:59"}, szContent="嘿嘿~本屆「武林第一美女評選」由我萬某人的商會獨家贊助，獎勵豐厚，有意的女俠快快前去報名吧。"},
		--公孙惜花
		{nNpcTemplate=99, nMapId=10, szDateTime={"00:00:00", "23:59:59"}, szContent="近日襄陽城內正在舉辦「武林第一美女評選」，我這「隱香樓」可收集了不少賽事情報喲~"},
		--秋依水
		{nNpcTemplate=694, nMapId=10, szDateTime={"00:00:00", "23:59:59"}, szContent="以我翠煙門弟子的姿色，「武林第一美女」定是我門下的弟子。"},
		--武僧
		{nNpcTemplate=1829, nMapId=10, szDateTime={"00:00:00", "23:59:59"}, szContent="阿尼陀佛，這幾日比武場內好是冷清，想必是因為那「武林第一美女評選」吧……"},
		--祝子虚
		{nNpcTemplate=1528, nMapId=10, szDateTime={"00:00:00", "23:59:59"}, szContent="劍俠多佳人，美者顏如玉。一笑傾人城，再笑傾人國。——[FFFE0D]「武林第一美女評選」[-]"},
		--黄暮云
		{nNpcTemplate=1530, nMapId=10, szDateTime={"00:00:00", "23:59:59"}, szContent="我島內弟子天生萌萌噠，「武林第一美女」榮譽唾手可得！"},
	},

	[tbAct.STATE_TYPE.FINAL] = --决赛
	{
		--紫轩
		{nNpcTemplate=622, nMapId=10, szDateTime={"00:00:00", "23:59:59"}, szContent="「武林第一美女評選」決賽正在進行中，將於[FFFE0D]2017年7月3日[-]評選出[FFFE0D]「武林第一美女」[-]，快去給你們心目中的女神投上一票吧！"},

		--小紫烟
		{nNpcTemplate=95, nMapId=10, szDateTime={"00:00:00", "23:59:59"}, szContent="紫軒姐姐說小女孩不能參加「武林第一美女評選」，哼哼~"},
		--张琳心
		{nNpcTemplate=621, nMapId=10, szDateTime={"00:00:00", "23:59:59"}, szContent="嘿嘿！各位大俠，快把你們手中的「紅粉佳人」獻給「武林第一美女評選」的參賽佳人吧。"},
		--唐影
		{nNpcTemplate=620, nMapId=10, szDateTime={"00:00:00", "23:59:59"}, szContent="「武林第一美女評選」的參賽選手裡，那翠煙門門主倒是有幾分姿色。"},
		--小殷方
		{nNpcTemplate=623, nMapId=10, szDateTime={"00:00:00", "23:59:59"}, szContent="哇！紫軒姐姐那裡好熱鬧啊，都是漂亮的小姐姐，想必是為那「武林第一美女評選」而去的吧。"},
		--杨瑛
		{nNpcTemplate=633, nMapId=10, szDateTime={"00:00:00", "23:59:59"}, szContent="若有機會，我也想去見識一下襄陽城當下的盛事「武林第一美女評選」。"},
		--纳兰真
		{nNpcTemplate=90, nMapId=10, szDateTime={"00:00:00", "23:59:59"}, szContent="嘿~影楓哥哥，你會支持我的對吧？嘻嘻……"},
		--月眉儿
		{nNpcTemplate=97, nMapId=10, szDateTime={"00:00:00", "23:59:59"}, szContent="真兒妹妹，「武林第一美女評選」我可不會讓著你。"},
		--杨影枫
		{nNpcTemplate=624, nMapId=10, szDateTime={"00:00:00", "23:59:59"}, szContent="真兒和眉兒都報名了「武林第一美女評選」，我該支持誰呢？真頭疼……"},
		--万金财
		{nNpcTemplate=190, nMapId=10, szDateTime={"00:00:00", "23:59:59"}, szContent="嘿嘿~本屆「武林第一美女評選」由我萬某人的商會獨家贊助，獎勵豐厚，有意的女俠快快前去報名吧。"},
		--公孙惜花
		{nNpcTemplate=99, nMapId=10, szDateTime={"00:00:00", "23:59:59"}, szContent="近日襄陽城內正在舉辦「武林第一美女評選」，我這「隱香樓」可收集了不少賽事情報喲~"},
		--秋依水
		{nNpcTemplate=694, nMapId=10, szDateTime={"00:00:00", "23:59:59"}, szContent="以我翠煙門弟子的姿色，「武林第一美女」定是我門下的弟子。"},
		--武僧
		{nNpcTemplate=1829, nMapId=10, szDateTime={"00:00:00", "23:59:59"}, szContent="阿尼陀佛，這幾日比武場內好是冷清，想必是因為那「武林第一美女評選」吧……"},
		--祝子虚
		{nNpcTemplate=1528, nMapId=10, szDateTime={"00:00:00", "23:59:59"}, szContent="劍俠多佳人，美者顏如玉。一笑傾人城，再笑傾人國。——[FFFE0D]「武林第一美女評選」[-]"},
		--黄暮云
		{nNpcTemplate=1530, nMapId=10, szDateTime={"00:00:00", "23:59:59"}, szContent="我島內弟子天生萌萌噠，「武林第一美女」榮譽唾手可得！"},
	},

	[tbAct.STATE_TYPE.FINAL_REST] =  --决赛休整
	{
		--紫轩
		{nNpcTemplate=622, nMapId=10, szDateTime={"00:00:00", "23:59:59"}, szContent="「武林第一美女評選」決賽（跨服評選）前十已經產生，「武林第一美女」雕像已經樹立，快去一睹芳容吧！"},
	},
}

tbAct.tbSignUpMail = 
{
	[tbAct.STATE_TYPE.LOCAL] = 
	{
		Title = "成功報名選美海選賽",
		Text = string.format("    恭喜佳人！你成功報名「武林第一美女評選」海選賽，附件為你的參賽宣傳單。[FFFE0D]可以通過它在任意聊天頻道宣傳個人的選美資訊，或打開自己的參賽頁面。[-]提示：[FF6464FF]已上傳的參賽資料不可更改，建議活動期間不要更改角色名字哦！[-]\n    [00FF00][url=openBeautyUrl:查看活動頁面, %s]\n    [url=openBeautyUrl:查看我的頁面, %s][-]", tbAct.szMainEntryUrl, tbAct.szPlayerUrl),
		From = "「選美大會司儀」紫軒",
		nLogReazon = Env.LogWay_BeautyPageant_SignUp,
		tbAttach = {{"item", tbAct.SIGNUP_ITEM, 1, tbAct.STATE_TIME[tbAct.STATE_TYPE.LOCAL][2]}},
	},
	[tbAct.STATE_TYPE.FINAL] = 
	{
		Title = "選美入圍決賽通知",
		Text = string.format("    恭喜佳人！你成功[FFFE0D]入圍選美決賽[-]階段。\n    決賽（跨服評選）將於[FFFE0D]6月24號[-]開始，屆時你將與來自其他伺服器海選賽前三名的玩家共同角逐[ff578c]「武林第一美女」[-]，附件為你的決賽宣傳單。\n    [00FF00][url=openBeautyUrl:查看評選結果, %s]\n    [url=openBeautyUrl:查看我的頁面, %s][-]", tbAct.szMainEntryUrl, tbAct.szPlayerUrl),
		From = "「選美大會司儀」紫軒",
		nLogReazon = Env.LogWay_BeautyPageant_SignUp,
		tbAttach = {{"item", tbAct.SIGNUP_ITEM_FINAL, 1, tbAct.STATE_TIME[tbAct.STATE_TYPE.FINAL][2]}},
	},
}

tbAct.tbWinnerMailInfo = 
{
	[1] = {szName="冠軍", szTitle="第一", szContent="    你在%s最終排名：[FFFE0D]第%d名[-]。\n    恭喜佳人！你被評選為[ff578c]「武林%s美女」[-]%s"},
	[2] = {szName="十強", szTitle="十大", szContent="    你在%s最終排名：[FFFE0D]第%d名[-]。\n    恭喜佳人！你被評選為[ff578c]「武林%s美女」[-]%s"},
}

tbAct.AVAILABLE_CHANNEL = 
{
	[ChatMgr.ChannelType.Public] = 1,
	[ChatMgr.ChannelType.Team] = 1,
	[ChatMgr.ChannelType.Kin] = 1,
	[ChatMgr.ChannelType.Nearby] = 1,
	[ChatMgr.ChannelType.Friend] = 1,
}

tbAct.WINNER_TYPE = 
{
	BEGINE = 0,

	FINAL_1 = 1,
	FINAL_2 = 2,
	FINAL_3 = 3,
	FINAL_4 = 4,
	FINAL_5 = 5,
	FINAL_6 = 6,
	FINAL_7 = 7,
	FINAL_8 = 8,
	FINAL_9 = 9,
	FINAL_10 = 10,

	LOCAL_1 = 11,
	LOCAL_2 = 12,
	LOCAL_3 = 13,
	LOCAL_4 = 14,
	LOCAL_5 = 15,
	LOCAL_6 = 16,
	LOCAL_7 = 17,
	LOCAL_8 = 18,
	LOCAL_9 = 19,
	LOCAL_10 = 20,

	PARTICIPATE = 21,
	FINAL_PARTICIPATE = 22,

	MAX = 23,
}

tbAct.tbStatueInfo = 
{
	[tbAct.WINNER_TYPE.FINAL_1] = 
	{
		nTemplateId = 2336,
		pos = {10, 13275,18637},
		nTitleId = 7200,
		nDir = 50,
	},

	[tbAct.WINNER_TYPE.LOCAL_1] = 
	{
		nTemplateId = 2306,
		pos = {10, 13284,18936},
		nTitleId = 7202,
		nDir = 50,
	},
}

function tbAct:OnTrigger(szTrigger)
	if szTrigger == "Init" then
		ScriptData:SaveValue(self.szScriptDataKey, {})
		local tbData = self:GetActivityData();
		tbData.szFurnitureAwardFrame = Lib:GetMaxTimeFrame(self.tbFurnitureSelectAward)
		Log("[Info]", "BeautyPageant", "Init Set FurnitureAwardFrame", tbData.szFurnitureAwardFrame)

		local nStartTime, nEndTime = self:GetOpenTimeInfo()
		NewInformation:AddInfomation("BeautyReward", nEndTime,
						 {nStartTime, nEndTime},
						 {szTitle="美女評選護花獎", nReqLevel = self.LEVEL_LIMIT,
						 nShowPriority = 1, szUiName = "BeautyReward", szCheckRpFunc="fnBeautyRewardCheckRp"})
	elseif szTrigger == "Start" then
		Timer:Register(Env.GAME_FPS, self.AddNpcBubbleTalk, self)
		Activity:RegisterPlayerEvent(self, "Act_OnPlayerLogin", "OnLogin")
		Activity:RegisterPlayerEvent(self, "Act_SendChannelMsg", "SendChannelMsg")
		Activity:RegisterPlayerEvent(self, "Act_RequestSignUpFriend", "OnRequestSignUpFriend")
		Activity:RegisterPlayerEvent(self, "Act_DailyGift", "OnBuyDailyGift")
		Activity:RegisterPlayerEvent(self, "Act_BuyDaysCard", "OnBuyDaysCard")
		Activity:RegisterPlayerEvent(self, "Act_OnRechargeGold", "OnRechargeGold")
		Activity:RegisterPlayerEvent(self, "Act_OnAddOrgMoney", "OnAddOrgMoney")
		Activity:RegisterPlayerEvent(self, "Act_VotedAwardReq", "OnVotedAwardReq")
		Activity:RegisterPlayerEvent(self, "Act_EverydayTarget_Award", "OnAddEverydayAward")

		local nState = self:GetCurState()
		if nState == self.STATE_TYPE.SIGN_UP or nState == self.STATE_TYPE.LOCAL then
			Activity:RegisterNpcDialog(self, 622, {Text = "我要報名", Callback = self.TrySignUp, Param = {self}})
		end

		if nState ~= self.STATE_TYPE.SIGN_UP then
			Activity:RegisterNpcDialog(self, 622, {Text = "我要投票", Callback = self.TryVote, Param = {self}})
		end

		local _, nEndTime = self:GetOpenTimeInfo()
		self:RegisterDataInPlayer(nEndTime)

		local tbPlayer = KPlayer.GetAllPlayer();
		for _, pPlayer in pairs(tbPlayer) do
			if pPlayer.nLevel >= self.LEVEL_LIMIT then
				self:OnLogin(pPlayer)
			end
		end
	elseif szTrigger == "OnWorldNotify" then
		self:OnWorldNotify()
	elseif szTrigger == "CheckLocalResultInfo" then
		local tbInfoData = NewInformation:GetInformation("BeautyPageantAct_LocalResult")
		if not tbInfoData and self:GetCurState() == self.STATE_TYPE.LOCAL_REST and self:GetStateLeftTime() <= 24*60*60 then
			-- 如果在间歇期中间时间还没公布结果的最新消息这里直接发
			self:AddLocalResultInfo();
		end
	elseif szTrigger == "CheckFinalResultInfo" then
		local tbInfoData = NewInformation:GetInformation("BeautyPageantAct_FinalResult")
		if not tbInfoData and self:GetCurState() == self.STATE_TYPE.FINAL_REST and self:GetStateLeftTime() <= 2*24*60*60 then
			-- 如果在间歇期中间时间还没公布结果的最新消息这里直接发
			self:AddFinalResultInfo();
		end
	elseif szTrigger  == "End" then
	end
end

function tbAct:GetActivityData()
	local tbData = ScriptData:GetValue(self.szScriptDataKey)
	tbData.tbSignList = tbData.tbSignList or {}
	tbData.tbFinalWinnerList = tbData.tbFinalWinnerList or {}
	tbData.tbLocalWinnerList = tbData.tbLocalWinnerList or {}
	tbData.tbParticipateWinnerList = tbData.tbParticipateWinnerList or {}
	tbData.tbFinalParticipateWinnerList = tbData.tbFinalParticipateWinnerList or {}
	return tbData
end

function tbAct:SaveActivityData()
	 ScriptData:AddModifyFlag(self.szScriptDataKey)
end

function tbAct:OnWorldNotify()
	local nState = self:GetCurState();
	local szNotify = self.tbWorldNotify[nState]
	if szNotify then
		KPlayer.SendWorldNotify(self.LEVEL_LIMIT, 1000,
					szNotify,
					ChatMgr.ChannelType.Public, 1);
	end
end

function tbAct:AddNpcBubbleTalk()
	for nState,tbNpcList in pairs(self.tbNpcBubble) do
		local tbTimeRange = tbAct.STATE_TIME[nState];
		for _,tbInfo in pairs(tbNpcList) do
			NpcBubbleTalk:Add(tbInfo.nMapId, tbInfo.nNpcTemplate,
						tbInfo.szContent,
						 Lib:GetTimeStr4(tbTimeRange[1]),
						 Lib:GetTimeStr4(tbTimeRange[2]),
						 tbInfo.szDateTime[1], tbInfo.szDateTime[2])
		end
	end
end

function tbAct:CheckPlayerData(pPlayer)
	local nStartTime, nEndTime = self:GetOpenTimeInfo()
	if pPlayer.GetUserValue(self.SAVE_GROUP, self.VERSION) == nStartTime then
		return
	end
	pPlayer.SetUserValue(self.SAVE_GROUP, self.VERSION, nStartTime)
	pPlayer.SetUserValue(self.SAVE_GROUP, self.VOTE_COUNT, 0)
	pPlayer.SetUserValue(self.SAVE_GROUP, self.VOTE_AWARD_1, 0)
	pPlayer.SetUserValue(self.SAVE_GROUP, self.VOTE_AWARD_2, 0)
	pPlayer.SetUserValue(self.SAVE_GROUP, self.VOTE_AWARD_3, 0)
	pPlayer.SetUserValue(self.SAVE_GROUP, self.VOTE_AWARD_4, 0)
	pPlayer.SetUserValue(self.SAVE_GROUP, self.VOTE_AWARD_5, 0)
	pPlayer.SetUserValue(self.SAVE_GROUP, self.VOTE_AWARD_6, 0)
	pPlayer.SetUserValue(self.SAVE_GROUP, self.VOTE_AWARD_7, 0)
	pPlayer.SetUserValue(self.SAVE_GROUP, self.VOTE_AWARD_8, 0)
	pPlayer.SetUserValue(self.SAVE_GROUP, self.VOTE_AWARD_9, 0)
	pPlayer.SetUserValue(self.SAVE_GROUP, self.VOTE_AWARD_10, 0)
end

function tbAct:OnLogin(pPlayer)
	self:CheckPlayerData(pPlayer);
	local bIsSignUp, nSignUpTimeOut = self:IsSignUp(pPlayer.dwID);
	if bIsSignUp then
		pPlayer.CallClientScript("Activity.BeautyPageant:SyncIsSignUp", nSignUpTimeOut);
	end
	pPlayer.CallClientScript("Activity.BeautyPageant:SyncFurnitureAwardFrame", self:GetFurnitureAwardFrame());
end

function tbAct:TrySignUp()
	if me.nLevel < self.LEVEL_LIMIT then
		me.CenterMsg(string.format("等級不足%d", self.LEVEL_LIMIT))
		return
	end

	me.CallClientScript("Activity.BeautyPageant:OpenSignUpPage");
end

function tbAct:TryVote()
	me.CallClientScript("Activity.BeautyPageant:OpenMainPage");
end

function tbAct:GetFurnitureAwardFrame()
	local tbData = self:GetActivityData();
	
	return tbData.szFurnitureAwardFrame or "-1"
end

function tbAct:OnSignUp(nPlayerId)
	local tbData = self:GetActivityData();
	--有效时间到本服比赛结束时间
	tbData.tbSignList[nPlayerId] = self.STATE_TIME[self.STATE_TYPE.LOCAL][2]
	self:SaveActivityData();
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if pPlayer then
		pPlayer.CallClientScript("Activity.BeautyPageant:SyncIsSignUp", tbData.tbSignList[nPlayerId]);
		local dwKinId = pPlayer.dwKinId
		if dwKinId > 0 then
			local szName = pPlayer.szName
			local tbLinkData = {nLinkType = ChatMgr.LinkType.HyperText, linkParam={szHyperText = string.format("[url=openBeautyUrl:PlayerPage, %s][-]", string.format(self.szPlayerUrl, pPlayer.dwID, Sdk:GetServerId()))}}
			local nNow = GetTime()
			local tbTime = os.date("*t", nNow)
			ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.Kin,
				string.format(XT("幫派成員「%s」已報名武林第一美女評選活動<佳人：%s>"),
					szName, szName),
					dwKinId, tbLinkData);
		end

	end

	self:SendSignUpItem(nPlayerId, self.STATE_TYPE.LOCAL)
end

function tbAct:IsSignUp(nPlayerId)
	local tbData = self:GetActivityData();
	local nSignUpTimeOut = tbData.tbSignList[nPlayerId];
	return nSignUpTimeOut ~= nil and GetTime() < nSignUpTimeOut, nSignUpTimeOut
end

function tbAct:SendChannelMsg(pPlayer, nType, nParam)
	if not self:IsSignUp(pPlayer.dwID) then
		return
	end

	if not nType then
		return
	end

	if nType ~= tbAct.MSG_CHANNEL_TYPE.NORMAL and 
		nType ~= tbAct.MSG_CHANNEL_TYPE.FACTION and
		nType ~= tbAct.MSG_CHANNEL_TYPE.PRIVATE then

		return
	end

	local szMsg, tbLinkData = self:GetSendMsg(pPlayer)

	if nType == tbAct.MSG_CHANNEL_TYPE.NORMAL then
		local nChannel = nParam or 0;
		if not tbAct.AVAILABLE_CHANNEL[nChannel] then
			return
		end

		if nChannel == ChatMgr.ChannelType.Public then
			if not ChatMgr:ReducePublicChatCount(pPlayer, 1) then
				return
			end
		end

		ChatMgr:SendPlayerMsg(nChannel, pPlayer.dwID, pPlayer.szName,
						 pPlayer.nFaction, pPlayer.nPortrait,
						 pPlayer.nLevel, szMsg, tbLinkData)

	elseif nType == tbAct.MSG_CHANNEL_TYPE.FACTION then
		local nChannel = Faction.tbChatChannel[pPlayer.nFaction]
		if not nChannel then
			return
		end

		ChatMgr:SendPlayerMsg(nChannel, pPlayer.dwID, pPlayer.szName,
						 pPlayer.nFaction, pPlayer.nPortrait,
						 pPlayer.nLevel, szMsg, tbLinkData)

	elseif nType == tbAct.MSG_CHANNEL_TYPE.PRIVATE then
		local nToRoleId = nParam or 0

		local pToStayInfo = KPlayer.GetRoleStayInfo(nToRoleId)
		if not pToStayInfo then
			return
		end

		SendPrivateMsg(pPlayer.dwID, nToRoleId, szMsg, tbLinkData)
	end
end

function tbAct:OnRequestSignUpFriend(pPlayer)
	local tbList = {}
	local tbAllFriends, _ = KFriendShip.GetFriendList(pPlayer.dwID);
	for nPlayerId, nImity in pairs(tbAllFriends) do
		if self:IsSignUp(nPlayerId) then
			table.insert(tbList, nPlayerId);
		end
	end
	if Lib:CountTB(tbList) > 0 then
		pPlayer.CallClientScript("Activity.BeautyPageant:SyncSignUpFriendList", tbList);
	end
end

function tbAct:OnVotedAwardReq(pPlayer, nIndex)
	local tbAward, nCanGet, nGotCount, bIsShow, tbAwardInfo = self:GetVotedAward(pPlayer, nIndex);
	if not tbAward or not nCanGet or nCanGet <= 0 or not bIsShow then
		return
	end
	
	pPlayer.SetUserValue(self.SAVE_GROUP, tbAwardInfo.nSaveKey, nGotCount + nCanGet);
	pPlayer.SendAward({tbAward}, true, true, Env.LogWay_BeautyPageant_Vote);

	pPlayer.CallClientScript("Activity.BeautyPageant:OnRefreshVotedAward");
end

function tbAct:OnAddEverydayAward(pPlayer, nAwardIdx)
	--活跃度100才给奖励
	if nAwardIdx ~= 5 then
		return
	end

	if pPlayer.nLevel < self.LEVEL_LIMIT then
		return
	end

	local nState = self:GetCurState()
	if nState < self.STATE_TYPE.SIGN_UP or nState > self.STATE_TYPE.FINAL then
		return
	end

	local tbFinalTime = self.STATE_TIME[self.STATE_TYPE.FINAL]

	pPlayer.SendAward({{"item", self.VOTE_ITEM, 1, tbFinalTime[2]}}, true, true, Env.LogWay_BeautyPageant_EverydayAward);
end

function tbAct:OnWinnerResult(nWinnerType, nServerId, szServerName, nPlayerId, szPlayerName, nFaction, nArmorResId, nWeaponResId)
	if self.WINNER_TYPE.FINAL_1 <= nWinnerType and nWinnerType <= self.WINNER_TYPE.FINAL_10 then

		self:_OnFinalWinnerResult(nWinnerType, nServerId,
				 szServerName, nPlayerId, szPlayerName, nFaction, nArmorResId, nWeaponResId)

	elseif self.WINNER_TYPE.LOCAL_1 <= nWinnerType and nWinnerType <= self.WINNER_TYPE.LOCAL_10 then

		self:_OnLocalWinnerResult(nWinnerType, nServerId,
				 szServerName, nPlayerId, szPlayerName, nFaction, nArmorResId, nWeaponResId)

	elseif nWinnerType == self.WINNER_TYPE.PARTICIPATE then

		self:_OnParticipateWinnerResult(nServerId, szServerName, nPlayerId, szPlayerName,
				 nFaction, nArmorResId, nWeaponResId)

	elseif nWinnerType == self.WINNER_TYPE.FINAL_PARTICIPATE then

		self:_OnFinalParticipateWinnerResult(nServerId, szServerName, nPlayerId, szPlayerName,
				 nFaction, nArmorResId, nWeaponResId)

	end
end

function tbAct:_OnFinalWinnerResult(nWinnerType, nServerId, szServerName, nPlayerId, szPlayerName, nFaction, nArmorResId, nWeaponResId)
	local nRank = nWinnerType - self.WINNER_TYPE.FINAL_1 + 1;
	local tbData = self:GetActivityData();
	local tbFinalWinnerList = tbData.tbFinalWinnerList
	local bAwarded = false;
	local tbOldWinnerInfo = tbFinalWinnerList[nRank]
	if tbOldWinnerInfo then
		bAwarded = tbOldWinnerInfo.bAwarded
		Lib:LogTB(tbOldWinnerInfo);
		Log("[Warning]", "BeautyPageant", "_OnFinalWinnerResult", "Over Write Cur Data", nRank, nServerId, szServerName, nPlayerId, szPlayerName, nFaction, nArmorResId, nWeaponResId, tostring(bAwarded))
	end

	tbFinalWinnerList[nRank] = 
	{
		nWinnerType = nWinnerType,
		nRank = nRank,
		nServerId = nServerId,
		szServerName = szServerName,
		nPlayerId = nPlayerId,
		szPlayerName = szPlayerName,
		nFaction =nFaction,
		nArmorResId = nArmorResId,
		nWeaponResId = nWeaponResId,
		bAwarded = bAwarded,
		nTime = GetTime(),
	}

	local nThisServerId = GetServerIdentity()

	local tbStatueInfo = self.tbStatueInfo[nWinnerType]
	if tbStatueInfo then
		if tbOldWinnerInfo then
			self:RemoveStatue(tbOldWinnerInfo, tbStatueInfo)
		end
		self:AddStatue(tbFinalWinnerList[nRank], tbStatueInfo)
	end

	if nThisServerId == nServerId and not bAwarded then
		if tbStatueInfo then
			Kin:RedBagOnEvent(nPlayerId, Kin.tbRedBagEvents.beauty_final_1)
			Kin:RedBagOnEvent(nPlayerId, Kin.tbRedBagEvents.beauty_g_final_1)
		else
			Kin:RedBagOnEvent(nPlayerId, Kin.tbRedBagEvents.beauty_g_final_10)
			Kin:RedBagOnEvent(nPlayerId, Kin.tbRedBagEvents.beauty_final_10)
		end
		local tbAward = self.tbFinalWinnerAward[nRank] or self.tbFinalWinnerAward[2]
		local tbMailInfo = self.tbWinnerMailInfo[nRank] or self.tbWinnerMailInfo[2]
		if tbAward then
			local tbMail = 
			{
				To = nPlayerId,
				Title = string.format("選美決賽%s", tbMailInfo.szName),
				Text = string.format("    你在%s最終排名：[FFFE0D]第%s名[-]\n    恭喜佳人！你傾國傾城般的容貌與魅力得到了武林的認可，被評選為[FF69B4]「武林%s美女」[-]%s\n    [FFFE0D]紅包獎勵已發放，請前往幫派紅包介面查看。[-]\n    [00FF00][url=openBeautyUrl:查看評選結果, %s]\n    [url=openBeautyUrl:查看我的頁面, %s][-]", "決賽（跨服評選）", 
							Lib:Transfer4LenDigit2CnNum(nRank), tbMailInfo.szTitle,
							tbStatueInfo and string.format("，你的雕像已在[00ff00][url=npc:襄陽城, %d, 10][-]樹立，以供他人一睹芳容。", tbStatueInfo.nTemplateId) or "。",
							self.szMainEntryUrl, string.format(self.szPlayerUrl, nPlayerId, nServerId)),
				From = "「選美大會司儀」紫軒",
				nLogReazon = Env.LogWay_BeautyPageant_Winner,
				tbAttach = tbAward,
			}

			Mail:SendSystemMail(tbMail);
			tbFinalWinnerList[nRank].bAwarded = true;
		else
			Log("[Error]", "BeautyPageant", "_OnFinalWinnerResult", "Not Award", nRank, nWinnerType, nServerId, szServerName, nPlayerId, szPlayerName, nFaction, nArmorResId, nWeaponResId)
		end
	end
	
	self:SaveActivityData();

	--如果名单齐了发最新消息
	if Lib:CountTB(tbFinalWinnerList) >= 10 then
		self:AddFinalResultInfo()
	end
end

function tbAct:_OnLocalWinnerResult(nWinnerType, nServerId, szServerName, nPlayerId, szPlayerName, nFaction, nArmorResId, nWeaponResId)
	local nThisServerId = GetServerIdentity()
	if nThisServerId ~= nServerId then
		Log("[Error]", "BeautyPageant", "_OnLocalWinnerResult", "Not This Server", nThisServerId, nWinnerType, nServerId, szServerName, nPlayerId, szPlayerName, nFaction, nArmorResId, nWeaponResId)
		return
	end

	local nRank = nWinnerType - self.WINNER_TYPE.LOCAL_1 + 1;
	local tbData = self:GetActivityData();
	local tbLocalWinnerList = tbData.tbLocalWinnerList
	local bAwarded = false;
	local tbOldWinnerInfo = tbLocalWinnerList[nRank]

	if tbOldWinnerInfo then
		bAwarded = tbOldWinnerInfo.bAwarded
		Lib:LogTB(tbOldWinnerInfo);
		Log("[Warning]", "BeautyPageant", "_OnLocalWinnerResult", "Over Write Cur Data", nRank, nServerId, szServerName, nPlayerId, szPlayerName, nFaction, nArmorResId, nWeaponResId, tostring(bAwarded))
	end

	tbLocalWinnerList[nRank] = 
	{
		nWinnerType = nWinnerType,
		nRank = nRank,
		nServerId = nServerId,
		szServerName = szServerName,
		nPlayerId = nPlayerId,
		szPlayerName = szPlayerName,
		nFaction =nFaction,
		nArmorResId = nArmorResId,
		nWeaponResId = nWeaponResId,
		bAwarded = bAwarded,
		nTime = GetTime(),
	}

	local tbStatueInfo = self.tbStatueInfo[nWinnerType]
	if tbStatueInfo then
		if tbOldWinnerInfo then
			self:RemoveStatue(tbOldWinnerInfo, tbStatueInfo)
		end
		self:AddStatue(tbLocalWinnerList[nRank], tbStatueInfo)
	end

	--前3名进入决赛
	if nRank <= 3 then
		local tbData = self:GetActivityData();
		--有效时间到决赛比赛结束时间
		tbData.tbSignList[nPlayerId] = self.STATE_TIME[self.STATE_TYPE.FINAL][2]
		self:SaveActivityData();
		local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
		if pPlayer then
			pPlayer.CallClientScript("Activity.BeautyPageant:SyncIsSignUp", tbData.tbSignList[nPlayerId]);
		end
		self:SendSignUpItem(nPlayerId, self.STATE_TYPE.FINAL)
	end
	
	if not bAwarded then
		if tbStatueInfo then
			Kin:RedBagOnEvent(nPlayerId, Kin.tbRedBagEvents.beauty_hx_1)
			Kin:RedBagOnEvent(nPlayerId, Kin.tbRedBagEvents.beauty_g_hx_1)
		else
			Kin:RedBagOnEvent(nPlayerId, Kin.tbRedBagEvents.beauty_hx_10)
		end

		local tbAward = self.tbLocalWinnerAward[nRank] or self.tbLocalWinnerAward[2]
		local tbMailInfo = self.tbWinnerMailInfo[nRank] or self.tbWinnerMailInfo[2]
		if tbAward then
			local tbMail = 
			{
				To = nPlayerId,
				Title = string.format("選美海選賽%s", tbMailInfo.szName),
				Text = string.format("    你在%s最終排名：[FFFE0D]第%s名[-]\n    恭喜佳人！你傾國傾城般的容貌與魅力得到了武林的認可，被評選為[FF69B4]「本服%s美女」[-]%s\n    [FFFE0D]紅包獎勵已發放，請前往幫派紅包介面查看。[-]\n    [00FF00][url=openBeautyUrl:查看評選結果, %s]\n    [url=openBeautyUrl:查看我的頁面, %s][-]", "海選賽（本服評選）", 
							Lib:Transfer4LenDigit2CnNum(nRank), tbMailInfo.szTitle,
							tbStatueInfo and string.format("，你的雕像已在[00ff00][url=npc:襄陽城, %d, 10][-]樹立，以供他人一睹芳容。", tbStatueInfo.nTemplateId) or "。",
							self.szMainEntryUrl, string.format(self.szPlayerUrl, nPlayerId, nServerId)),
				From = "「選美大會司儀」紫軒",
				nLogReazon = Env.LogWay_BeautyPageant_Winner,
				tbAttach = tbAward,
			}

			Mail:SendSystemMail(tbMail);

			tbLocalWinnerList[nRank].bAwarded = true;
		else
			Log("[Error]", "BeautyPageant", "_OnLocalWinnerResult", "Not Award", nRank, nWinnerType, nServerId, szServerName, nPlayerId, szPlayerName, nFaction, nArmorResId, nWeaponResId)
		end
	end

	self:SaveActivityData();

	--如果名单齐了发最新消息
	if Lib:CountTB(tbLocalWinnerList) >= 10 then
		self:AddLocalResultInfo()
	end
end

function tbAct:_OnParticipateWinnerResult(nServerId, szServerName, nPlayerId, szPlayerName, nFaction, nArmorResId, nWeaponResId)
	local nThisServerId = GetServerIdentity()
	if nThisServerId ~= nServerId then
		Log("[Error]", "BeautyPageant", "_OnParticipateWinnerResult", "Not This Server", nThisServerId, nRank, nServerId, szServerName, nPlayerId, szPlayerName, nFaction, nArmorResId, nWeaponResId)
		return
	end

	local tbData = self:GetActivityData();
	local tbParticipateWinnerList = tbData.tbParticipateWinnerList
	local bAwarded = false;

	if tbParticipateWinnerList[nPlayerId] then
		bAwarded = tbParticipateWinnerList[nPlayerId].bAwarded
		Lib:LogTB(tbParticipateWinnerList[nPlayerId]);
		Log("[Warning]", "BeautyPageant", "_OnParticipateWinnerResult", "Over Write Cur Data", nRank, nServerId, szServerName, nPlayerId, szPlayerName, nFaction, nArmorResId, nWeaponResId, tostring(bAwarded))
	end

	tbParticipateWinnerList[nPlayerId] = 
	{
		nServerId = nServerId,
		szServerName = szServerName,
		nPlayerId = nPlayerId,
		szPlayerName = szPlayerName,
		nFaction =nFaction,
		nArmorResId = nArmorResId,
		nWeaponResId = nWeaponResId,
		bAwarded = bAwarded,
	}

	if not bAwarded then
		local tbMail = 
		{
			To = nPlayerId,
			Title = "選美獲投199票獎勵",
			Text = string.format("    你在海選賽（本服評選）的得票數超過了[FFFE0D]199[-]\n    恭喜佳人！你在海選賽中受到了眾多俠士的傾慕，[FF69B4]「人見人愛，花見花開」[-]用於形容你也不為過，選美大會特為你準備了些許獎勵，請查收附件。\n    [FFFE0D]紅包獎勵已發放，請前往幫派紅包介面查看。[-]\n    [00FF00][url=openBeautyUrl:查看評選結果, %s]\n    [url=openBeautyUrl:查看我的頁面, %s][-]",
				self.szMainEntryUrl, string.format(self.szPlayerUrl, nPlayerId, nServerId)),
			From = "「選美大會司儀」紫軒",
			nLogReazon = Env.LogWay_BeautyPageant_Winner,
			tbAttach = self.tbParticipateAward,
		}

		Mail:SendSystemMail(tbMail);

		tbParticipateWinnerList[nPlayerId].bAwarded = true;

		Kin:RedBagOnEvent(nPlayerId, Kin.tbRedBagEvents.beauty_hx_vote, 199)
	end

	self:SaveActivityData();
end

function tbAct:_OnFinalParticipateWinnerResult(nServerId, szServerName, nPlayerId, szPlayerName, nFaction, nArmorResId, nWeaponResId)
	local nThisServerId = GetServerIdentity()
	if nThisServerId ~= nServerId then
		Log("[Error]", "BeautyPageant", "_OnFinalParticipateWinnerResult", "Not This Server", nThisServerId, nRank, nServerId, szServerName, nPlayerId, szPlayerName, nFaction, nArmorResId, nWeaponResId)
		return
	end

	local tbData = self:GetActivityData();
	local tbFinalParticipateWinnerList = tbData.tbFinalParticipateWinnerList
	local bAwarded = false;

	if tbFinalParticipateWinnerList[nPlayerId] then
		bAwarded = tbFinalParticipateWinnerList[nPlayerId].bAwarded
		Lib:LogTB(tbFinalParticipateWinnerList[nPlayerId]);
		Log("[Warning]", "BeautyPageant", "_OnFinalParticipateWinnerResult", "Over Write Cur Data", nRank, nServerId, szServerName, nPlayerId, szPlayerName, nFaction, nArmorResId, nWeaponResId, tostring(bAwarded))
	end

	tbFinalParticipateWinnerList[nPlayerId] = 
	{
		nServerId = nServerId,
		szServerName = szServerName,
		nPlayerId = nPlayerId,
		szPlayerName = szPlayerName,
		nFaction =nFaction,
		nArmorResId = nArmorResId,
		nWeaponResId = nWeaponResId,
		bAwarded = bAwarded,
	}

	if not bAwarded then
		local tbMail = 
		{
			To = nPlayerId,
			Title = "選美獲投8000票獎勵",
			Text = string.format("    你在決賽（跨服評選）的得票數超過了[FFFE0D]8000[-]\n    恭喜佳人！你在決賽中受到了眾多俠士的傾慕，[FF69B4]「人見人愛，花見花開」[-]用於形容你也不為過，選美大會特為你準備了些許獎勵，請查收附件。\n    [FFFE0D]紅包獎勵已發放，請前往幫派紅包介面查看。[-]\n    [00FF00][url=openBeautyUrl:查看評選結果, %s]\n    [url=openBeautyUrl:查看我的頁面, %s][-]",
				self.szMainEntryUrl, string.format(self.szPlayerUrl, nPlayerId, nServerId)),
			From = "「選美大會司儀」紫軒",
			nLogReazon = Env.LogWay_BeautyPageant_Winner,
			tbAttach = self.tbFinalParticipateAward,
		}

		Mail:SendSystemMail(tbMail);

		tbFinalParticipateWinnerList[nPlayerId].bAwarded = true;

		Kin:RedBagOnEvent(nPlayerId, Kin.tbRedBagEvents.beauty_final_vote, 8000)
		Kin:RedBagOnEvent(nPlayerId, Kin.tbRedBagEvents.beauty_g_final_vote, 8000)
	end

	self:SaveActivityData();
end

function tbAct:AddStatue(tbWinnerInfo, tbStatueInfo)
	local tbPos = tbStatueInfo.pos;

	local pNpc = KNpc.Add(tbStatueInfo.nTemplateId, 1, -1, tbPos[1], tbPos[2], tbPos[3], false, tbStatueInfo.nDir);
	if not pNpc then
		Lib:LogTB(tbWinnerInfo)
		Lib:LogTB(tbStatueInfo)
		Log("[Error]", "BeautyPageant", "AddStatue Failed");
		return
	end

	pNpc.tbWinnerInfo = tbWinnerInfo;
	pNpc.tbStatueInfo = tbStatueInfo;

	pNpc.SetName(tbWinnerInfo.szPlayerName);
	pNpc.SetTitleID(tbStatueInfo.nTitleId);

	local nResId , nBodyResId, nWeaponResId, _, _ = KPlayer.GetNpcResIdByFaction(tbWinnerInfo.nFaction);
	
	if tbWinnerInfo.nArmorResId and tbWinnerInfo.nArmorResId > 0 then
		nBodyResId = tbWinnerInfo.nArmorResId;
	end

	if tbWinnerInfo.nWeaponResId and tbWinnerInfo.nWeaponResId > 0 then
		nWeaponResId = tbWinnerInfo.nWeaponResId;
	end

	pNpc.ChangeFeature(nResId, nBodyResId, nWeaponResId);
	if tbStatueInfo.nDir then
		pNpc.SetDir(tbStatueInfo.nDir);
	end
end

function tbAct:RemoveStatue(tbWinnerInfo, tbStatueInfo)
	local tbPosInfo = tbStatueInfo.pos;

	local tbNpcList,_ = KNpc.GetMapNpc(tbPosInfo[1])

	for _, pNpc in pairs(tbNpcList) do
		if pNpc.nTemplateId == tbStatueInfo.nTemplateId and 
			pNpc.tbWinnerInfo and pNpc.tbWinnerInfo.nServerId == tbWinnerInfo.nServerId and
			pNpc.tbWinnerInfo.nPlayerId == tbWinnerInfo.nPlayerId then

			pNpc.Delete();
		end
	end
end

function tbAct:OnBuyDailyGift(pPlayer, nGroupIndex, nBuyCount)
	local nState = self:GetCurState()
	if nState < self.STATE_TYPE.SIGN_UP or nState > self.STATE_TYPE.FINAL then
		return
	end

	local nCount = self.DailyGiftVote[nGroupIndex];
	if not nCount or nCount <= 0 then
		Log("[Error]", "BeautyPageant", "Wrong Daily Gift Vote Count", pPlayer.dwID, pPlayer.szName, nGroupIndex, nBuyCount);
		return
	end

	local tbFinalTime = self.STATE_TIME[self.STATE_TYPE.FINAL]

	pPlayer.SendAward({{"item", self.VOTE_ITEM, nCount * nBuyCount, tbFinalTime[2]}}, true, true, Env.LogWay_BeautyPageant_Recharge);
end

function tbAct:OnBuyDaysCard(pPlayer, nGroupIndex)
	local nState = self:GetCurState()
	if nState < self.STATE_TYPE.SIGN_UP or nState > self.STATE_TYPE.FINAL then
		return
	end

	local nCount = self.DaysCardVote[nGroupIndex];
	if not nCount or nCount <= 0 then
		Log("[Error]", "BeautyPageant", "Wrong Days Card Vote Count", pPlayer.dwID, pPlayer.szName, nGroupIndex);
		return
	end

	local tbFinalTime = self.STATE_TIME[self.STATE_TYPE.FINAL]

	pPlayer.SendAward({{"item", self.VOTE_ITEM, nCount, tbFinalTime[2]}}, true, true, Env.LogWay_BeautyPageant_Recharge);

end

function tbAct:OnRechargeGold(pPlayer, nRMB)
	local nState = self:GetCurState()
	if nState < self.STATE_TYPE.SIGN_UP or nState > self.STATE_TYPE.FINAL then
		return
	end

	local nCount = math.ceil(nRMB / self.nRechargeGoldVote);
	if not nCount or nCount <= 0 then
		Log("[Error]", "BeautyPageant", "Wrong Recharge Gold Vote Count", pPlayer.dwID, pPlayer.szName, nRMB);
		return
	end

	local tbFinalTime = self.STATE_TIME[self.STATE_TYPE.FINAL]

	pPlayer.SendAward({{"item", self.VOTE_ITEM, nCount, tbFinalTime[2]}}, true, true, Env.LogWay_BeautyPageant_Recharge);
end

function tbAct:OnAddOrgMoney(pPlayer, szType, nPoint, nLogReazon, nLogReazon2)
	if szType ~= "SilverBoard" then
		return
	end

	local nState = self:GetCurState()
	if nState < self.STATE_TYPE.SIGN_UP or nState > self.STATE_TYPE.FINAL then
		return
	end

	local nCount = math.ceil(nPoint / self.nRechargeSilverBoardVote);

	if not nCount or nCount <= 0 then
		Log("[Error]", "BeautyPageant", "Wrong Recharge SilverBoard Vote Count", pPlayer.dwID, pPlayer.szName, nPoint);
		return
	end

	local tbFinalTime = self.STATE_TIME[self.STATE_TYPE.FINAL]

	pPlayer.SendAward({{"item", self.VOTE_ITEM, nCount, tbFinalTime[2]}}, true, true, Env.LogWay_BeautyPageant_Recharge);
end

function tbAct:OnEnterMap(pPlayer, nMapTemplateId, nMapId)
	if nMapTemplateId ~= 10 then
		return
	end

	local tbData = self:GetActivityData();
	local tbFinalWinnerList = tbData.tbFinalWinnerList
	local tbLocalWinnerList = tbData.tbLocalWinnerList
	local bStatue = false
	for nRank,tbWinnerInfo in pairs(tbFinalWinnerList) do
		local tbStatueInfo = self.tbStatueInfo[tbWinnerInfo.nWinnerType]
		if tbStatueInfo then
			bStatue = true
			break;
		end
	end

	if not bStatue then
		for nRank,tbWinnerInfo in pairs(tbLocalWinnerList) do
			local tbStatueInfo = self.tbStatueInfo[tbWinnerInfo.nWinnerType]
			if tbStatueInfo then
				bStatue = true
				break;
			end
		end
	end

	if bStatue then
		pPlayer.CallClientScript("Activity.BeautyPageant:OnSynMiniMainMapInfo")
	end
end


function tbAct:SendSignUpItem(nPlayerId, nType)
	local tbMail = Lib:CopyTB(tbAct.tbSignUpMail[nType])
	if not tbMail then
		Log("[Error]", "BeautyPageant", "SendSignUpItem No Mail Template", nPlayerId, nType);
		return
	end

	tbMail.To = nPlayerId;
	tbMail.Text = string.format(tbMail.Text, nPlayerId, Sdk:GetServerId())

	Mail:SendSystemMail(tbMail);
end

function tbAct:AddVoteCount(pPlayer, nCount)
	self:CheckPlayerData(pPlayer);
	local nCurCount = pPlayer.GetUserValue(self.SAVE_GROUP, self.VOTE_COUNT)
	pPlayer.SetUserValue(self.SAVE_GROUP, self.VOTE_COUNT, nCurCount + nCount)
	pPlayer.CallClientScript("Activity.BeautyPageant:OnRefreshVotedAward");
end

function tbAct:IsLocalWinner(nPlayerId)
	local tbData = self:GetActivityData();
	local tbLocalWinnerList = tbData.tbLocalWinnerList;
	if not tbLocalWinnerList then
		return
	end

	for nRank,tbWinnerInfo in pairs(tbLocalWinnerList) do
		if tbWinnerInfo.nPlayerId == nPlayerId then
			return nRank
		end
	end
end

function tbAct:IsFinalWinner(nPlayerId)
	local tbData = self:GetActivityData();
	local tbFinalWinnerList = tbData.tbFinalWinnerList;
	if not tbFinalWinnerList then
		return
	end

	local nThisServerId = GetServerIdentity()

	for nRank,tbWinnerInfo in pairs(tbFinalWinnerList) do
		if tbWinnerInfo.nServerId == nThisServerId and tbWinnerInfo.nPlayerId == nPlayerId then
			return nRank
		end
	end
end

function tbAct:IsParticipateWinner(nPlayerId)
	local tbData = self:GetActivityData();
	local tbParticipateWinnerList = tbData.tbParticipateWinnerList;
	if not tbParticipateWinnerList then
		return
	end

	return tbParticipateWinnerList[nPlayerId]
end

function tbAct:IsFinalParticipateWinner(nPlayerId)
	local tbData = self:GetActivityData();
	local tbFinalParticipateWinnerList = tbData.tbFinalParticipateWinnerList;
	if not tbFinalParticipateWinnerList then
		return
	end

	return tbFinalParticipateWinnerList[nPlayerId]
end

function tbAct:OnServerStart()
	local tbData = self:GetActivityData();
	local tbFinalWinnerList = tbData.tbFinalWinnerList
	local tbLocalWinnerList = tbData.tbLocalWinnerList
	local nNow = GetTime()
	--如果有冠军数据立雕像
	for nRank,tbWinnerInfo in pairs(tbFinalWinnerList) do
		local tbStatueInfo = self.tbStatueInfo[tbWinnerInfo.nWinnerType]
		if tbStatueInfo then
			self:AddStatue(tbWinnerInfo, tbStatueInfo)
		end
	end
	for nRank,tbWinnerInfo in pairs(tbLocalWinnerList) do
		local tbStatueInfo = self.tbStatueInfo[tbWinnerInfo.nWinnerType]
		if tbStatueInfo and tbWinnerInfo.nTime + self.nLocalStatueTimeOut > nNow then
			self:AddStatue(tbWinnerInfo, tbStatueInfo)
		end
	end
end

function tbAct:AddLocalResultInfo()
	local tbData = self:GetActivityData();
	local tbLocalWinnerList = tbData.tbLocalWinnerList
	local  szContent = [[
「武林第一美女評選」[FFFE0D]海選賽（本服評選）[-]已結束，恭喜以下十強佳人！
]]

	for nRank,tbWinnerInfo in ipairs(tbLocalWinnerList) do
		local tbMailInfo = self.tbWinnerMailInfo[nRank] or self.tbWinnerMailInfo[2]
		local pStayInfo = KPlayer.GetRoleStayInfo(tbWinnerInfo.nPlayerId)
		local pKinData = Kin:GetKinById((pStayInfo and pStayInfo.dwKinId) or 0);
		szContent = string.format("%s\n[FFFE0D]%s[-]佳人：[C8FF00]%s[-]幫派：[C8FF00]%s[-][00FF00][url=openBeautyUrl:查看資料, %s][-]", szContent, Lib:StrFillL(string.format("第%s名", Lib:TransferDigit2CnNum(nRank)), 18, " "), Lib:StrFillL(tbWinnerInfo.szPlayerName, 18, " "), Lib:StrFillL((pKinData and pKinData.szName) or "--", 18, " "), string.format(self.szPlayerUrl, tbWinnerInfo.nPlayerId, tbWinnerInfo.nServerId))
	end

	local tbStatueInfo = self.tbStatueInfo[self.WINNER_TYPE.LOCAL_1]
	szContent = string.format("%s\n\n[FFFE0D]「本服第一美女」[-]雕像已在[00ff00][url=npc:襄陽城, %d, 10][-]樹立，各位俠士快去一睹芳容吧！\n恭喜[FFFE0D]前3名[-]佳人入圍決賽，決賽將於 [FFFE0D]%s[-] 開始。", szContent, tbStatueInfo.nTemplateId, Lib:TimeDesc10(self.STATE_TIME[self.STATE_TYPE.FINAL][1]))

	local nStartTime, nEndTime = self:GetOpenTimeInfo()
	NewInformation:AddInfomation("BeautyPageantAct_LocalResult", nEndTime, {szContent},{szTitle="本服十大美女", nReqLevel = self.LEVEL_LIMIT,
						 nShowPriority = 3})	
end

function tbAct:AddFinalResultInfo()
	local tbData = self:GetActivityData();
	local tbFinalWinnerList = tbData.tbFinalWinnerList
	local  szContent = [[
「武林第一美女評選」[FFFE0D]決賽（跨服評選）已結束[-]，恭喜以下十強佳人！
]]

	for nRank,tbWinnerInfo in ipairs(tbFinalWinnerList) do
		local tbMailInfo = self.tbWinnerMailInfo[nRank] or self.tbWinnerMailInfo[2]
		szContent = string.format("%s\n[FFFE0D]%s[-]佳人：[C8FF00]%s[-]來自：[C8FF00]%s[-][00FF00][url=openBeautyUrl:查看資料, %s][-]", szContent, Lib:StrFillL(string.format("第%s名", Lib:TransferDigit2CnNum(nRank)), 18, " "), Lib:StrFillL(tbWinnerInfo.szPlayerName, 18, " "), Lib:StrFillL(tbWinnerInfo.szServerName, 24, " "), string.format(self.szPlayerUrl, tbWinnerInfo.nPlayerId, tbWinnerInfo.nServerId))
	end

	local tbStatueInfo = self.tbStatueInfo[self.WINNER_TYPE.FINAL_1]
	szContent = string.format("%s\n\n[FFFE0D]「武林第一美女」[-]雕像已在[00ff00][url=npc:襄陽城, %d, 10][-]樹立，各位俠士快去一睹芳容吧！", szContent, tbStatueInfo.nTemplateId)

	local nStartTime, nEndTime = self:GetOpenTimeInfo()
	NewInformation:AddInfomation("BeautyPageantAct_FinalResult", nEndTime, {szContent},{szTitle="武林十大美女", nReqLevel = self.LEVEL_LIMIT,
						 nShowPriority = 4})	
end

function tbAct:AwardFinalParticipateFromFile()

	Log("AwardFinalParticipateFromFile")

	local nThisServerId = GetServerIdentity()
	local tbList = LoadTabFile("FinalParticipate.tab", "dsnsddd", nil, {"ServerId", "ServerName", "PlayerId", "PlayerName", "Faction", "ArmorResId", "WeaponResId"}, 1, 1) or {};
	for _,tbInfo in pairs(tbList) do
		if nThisServerId == tbInfo.ServerId then

			self:_OnFinalParticipateWinnerResult(tbInfo.ServerId, tbInfo.ServerName, tbInfo.PlayerId, tbInfo.PlayerName,
					 tbInfo.Faction, tbInfo.ArmorResId, tbInfo.WeaponResId)

			Log("_OnFinalParticipateWinnerResult", tbInfo.ServerId, tbInfo.ServerName, tbInfo.PlayerId, tbInfo.PlayerName, tbInfo.Faction, tbInfo.ArmorResId, tbInfo.WeaponResId)
		end
	end
end

function tbAct:UpdateStatueInfo(pPlayer, nWinnerType)
	local tbStatueInfo = self.tbStatueInfo[nWinnerType]
	if not tbStatueInfo then
		return
	end
	local tbData = self:GetActivityData();
	local tbFinalWinnerList = tbData.tbFinalWinnerList
	local tbLocalWinnerList = tbData.tbLocalWinnerList

	local nRank = 1;
	local tbWinnerInfo = tbLocalWinnerList[nRank];
	if nWinnerType == self.WINNER_TYPE.FINAL_1 then
		tbWinnerInfo = tbFinalWinnerList[nRank];
	end

	if not tbWinnerInfo then
		return
	end

	tbWinnerInfo.szPlayerName = pPlayer.szName;
	tbWinnerInfo.nFaction = pPlayer.nFaction

	local tbEquipInfo = KPlayer.GetInfoFromAsyncData(pPlayer.dwID);
	
	if tbEquipInfo then
		local tbWeapon = tbEquipInfo[Item.EQUIPPOS_WEAPON]
		local tbArmor = tbEquipInfo[Item.EQUIPPOS_BODY]

		local tbWaiWeapon = tbEquipInfo[Item.EQUIPPOS_WAI_WEAPON]
		local tbWaiArmor = tbEquipInfo[Item.EQUIPPOS_WAIYI]

		if tbWeapon then
			tbWinnerInfo.nWeaponResId = tbWeapon.nShowResId
		end

		if tbArmor then
			tbWinnerInfo.nArmorResId = tbArmor.nShowResId
		end

		if tbWaiWeapon then
			tbWinnerInfo.nWeaponResId = tbWaiWeapon.nShowResId
		end
		
		if tbWaiArmor then
			tbWinnerInfo.nArmorResId = tbWaiArmor.nShowResId
		end
	end


	self:RemoveStatue(tbWinnerInfo, tbStatueInfo)
	
	self:AddStatue(tbWinnerInfo, tbStatueInfo)
	pPlayer.SendBlackBoardMsg("成功更新雕像的形象");
end
