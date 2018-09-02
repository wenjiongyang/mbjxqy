 
Item.EQUIP_WEAPON			= 1;		-- 武器
Item.EQUIP_ARMOR			= 2;		-- 衣服
Item.EQUIP_RING				= 3;		-- 戒指
Item.EQUIP_NECKLACE			= 4;		-- 项链
Item.EQUIP_AMULET			= 5;		-- 护身符
Item.EQUIP_BOOTS			= 6;		-- 鞋子
Item.EQUIP_BELT				= 7;		-- 腰带
Item.EQUIP_HELM				= 8;		-- 头盔
Item.EQUIP_CUFF				= 9;		-- 护腕
Item.EQUIP_PENDANT			= 10;		-- 腰坠
Item.EQUIP_HORSE			= 11;		-- 坐骑
Item.EQUIP_SKILL_BOOK		= 12;		-- 秘籍
Item.EQUIP_WAIYI 			= 13;		-- 外衣
Item.EQUIP_WAI_WEAPON		= 14;		-- 外装武器
Item.EQUIP_REIN				= 15;		-- 缰绳
Item.EQUIP_SADDLE			= 16;		-- 马鞍
Item.EQUIP_PEDAL			= 17;		-- 脚蹬
Item.EQUIP_WAI_HORSE		= 18;		-- 外装坐骑
Item.EQUIP_ZHEN_YUAN		= 19;		-- 真元


Item.ITEM_SCRIPT			= 34;
Item.PARTNER 				= 35;  		-- 同伴类
Item.EQUIP_EX				= 36;		-- 未鉴定装备

-- 装备位置

Item.EQUIPPOS_HEAD			= 0;		-- 头
Item.EQUIPPOS_BODY			= 1;		-- 衣服
Item.EQUIPPOS_BELT			= 2;		-- 腰带
Item.EQUIPPOS_WEAPON		= 3;		-- 武器
Item.EQUIPPOS_FOOT			= 4;		-- 鞋子
Item.EQUIPPOS_CUFF			= 5;		-- 护腕
Item.EQUIPPOS_AMULET		= 6;		-- 护身符
Item.EQUIPPOS_RING			= 7;		-- 戒指
Item.EQUIPPOS_NECKLACE		= 8;		-- 项链
Item.EQUIPPOS_PENDANT		= 9;		-- 玉佩
Item.EQUIPPOS_HORSE			= 10;		-- 坐骑
Item.EQUIPPOS_SKILL_BOOK    = 11;		-- 秘籍
Item.EQUIPPOS_SKILL_BOOK_End = 20;		-- 秘籍结束
Item.EQUIPPOS_WAIYI			= 21;		-- 外装
Item.EQUIPPOS_WAI_WEAPON	= 22;		-- 外装武器
Item.EQUIPPOS_REIN			= 23;		-- 缰绳
Item.EQUIPPOS_SADDLE		= 24;		-- 马鞍
Item.EQUIPPOS_PEDAL			= 25;		-- 脚蹬
Item.EQUIPPOS_WAI_HORSE		= 26;		-- 外装坐骑
Item.EQUIPPOS_ZHEN_YUAN		= 27;		-- 真元
Item.EQUIPPOS_NUM			= 27; 		--总装备位置数

Item.EQUIPPOS_MAIN_NUM     = 10; --主身体装备数量

Item.EITEMPOS_BAG     = 200; --背包的位置


Item.tbHorseItemPos = { 
	[Item.EQUIPPOS_HORSE] 	= 1; 
	[Item.EQUIPPOS_REIN] 	= 1;
	[Item.EQUIPPOS_SADDLE] = 1;
	[Item.EQUIPPOS_PEDAL] 	= 1;
}


--装备类型对应位置
Item.EQUIPTYPE_POS =  
{
	[Item.EQUIP_WEAPON]		= Item.EQUIPPOS_WEAPON,
	[Item.EQUIP_ARMOR]		= Item.EQUIPPOS_BODY,
	[Item.EQUIP_RING]		= Item.EQUIPPOS_RING,
	[Item.EQUIP_NECKLACE]	= Item.EQUIPPOS_NECKLACE,
	[Item.EQUIP_AMULET]		= Item.EQUIPPOS_AMULET,
	[Item.EQUIP_BOOTS]		= Item.EQUIPPOS_FOOT,
	[Item.EQUIP_BELT]		= Item.EQUIPPOS_BELT,
	[Item.EQUIP_HELM]		= Item.EQUIPPOS_HEAD,
	[Item.EQUIP_CUFF]		= Item.EQUIPPOS_CUFF,
	[Item.EQUIP_PENDANT]	= Item.EQUIPPOS_PENDANT,
	[Item.EQUIP_HORSE]		= Item.EQUIPPOS_HORSE,
}

Item.LOGIC_MAX_COUNT		= 200

Item.EQUIP_RANDOM_ATTRIB_VALUE_BEGIN = 1
Item.EQUIP_RANDOM_ATTRIB_VALUE_END = 6
Item.EQUIP_VALUE_TRAIN_ATTRI_LEVEL = 8;--装备的成长属性等级, baseIntValue

--铭刻石，先预留10 个。现在按照最多3个
Item.EQUIP_RECORD_STONE_VALUE_BEGIN = 11;
Item.EQUIP_RECORD_STONE_VALUE_END 	= 20; --

Item.EQUIPTYPE_NAME =
{
	[Item.EQUIP_WEAPON	] = "武器",
	[Item.EQUIP_ARMOR	] = "衣服",
	[Item.EQUIP_RING	] = "戒指",
	[Item.EQUIP_NECKLACE] = "項鍊",
	[Item.EQUIP_AMULET	] = "護身符",
	[Item.EQUIP_BOOTS	] = "鞋子",
	[Item.EQUIP_BELT	] = "腰帶",
	[Item.EQUIP_HELM	] = "帽子",
	[Item.EQUIP_CUFF	] = "護腕",
	[Item.EQUIP_PENDANT	] = "玉佩",
	[Item.EQUIP_HORSE	] = "坐騎",
	[Item.EQUIP_WAIYI	] = "外裝",
	[Item.EQUIP_WAI_WEAPON] = "外裝武器",
	[Item.EQUIP_REIN	] = "韁繩",
	[Item.EQUIP_SADDLE	] = "馬鞍",
	[Item.EQUIP_PEDAL	] = "腳蹬",
	[Item.EQUIP_ZHEN_YUAN] = "真元",
}

-- 装备穿在身上的位置描述字符串
Item.EQUIPPOS_NAME =
{
	[Item.EQUIPPOS_HEAD]		= "帽子",
	[Item.EQUIPPOS_BODY]		= "衣服",
	[Item.EQUIPPOS_BELT]		= "腰帶",
	[Item.EQUIPPOS_WEAPON]		= "武器",
	[Item.EQUIPPOS_FOOT]		= "鞋子",
	[Item.EQUIPPOS_CUFF]		= "護腕",
	[Item.EQUIPPOS_AMULET]		= "護身符",
	[Item.EQUIPPOS_RING]		= "戒指",
	[Item.EQUIPPOS_NECKLACE]	= "項鍊",
	[Item.EQUIPPOS_PENDANT]		= "玉佩",
	[Item.EQUIPPOS_HORSE]		= "坐騎",
};

Item.EQUIPTYPE_EN_NAME = 
{
	[Item.EQUIP_WEAPON	] = "Weapon",
	[Item.EQUIP_ARMOR	] = "Armor",
	[Item.EQUIP_RING	] = "Ring",
	[Item.EQUIP_NECKLACE] = "Necklace",
	[Item.EQUIP_AMULET	] = "Amulet",
	[Item.EQUIP_BOOTS	] = "Boots",
	[Item.EQUIP_BELT	] = "Belt",
	[Item.EQUIP_HELM	] = "Helm",
	[Item.EQUIP_CUFF	] = "Cuff",
	[Item.EQUIP_PENDANT	] = "Pendant",
	[Item.EQUIP_HORSE	] = "Horse",
	[Item.EQUIP_ZHEN_YUAN] = "ZhenYuan",
}


Item.EQUIPPOS_EN_NAME = 
{
	[Item.EQUIPPOS_WEAPON 	] = "Weapon",
	[Item.EQUIPPOS_BODY		] = "Armor",
	[Item.EQUIPPOS_RING		] = "Ring",
	[Item.EQUIPPOS_NECKLACE	] = "Necklace",
	[Item.EQUIPPOS_AMULET	] = "Amulet",
	[Item.EQUIPPOS_FOOT		] = "Boots",
	[Item.EQUIPPOS_BELT		] = "Belt",
	[Item.EQUIPPOS_HEAD		] = "Helm",
	[Item.EQUIPPOS_CUFF		] = "Cuff",
	[Item.EQUIPPOS_PENDANT	] = "Pendant",
	[Item.EQUIPPOS_HORSE	] = "Horse",
}


Item.tbQualityColor = 
{
	"itemframe", 			-- 白
	"itemframeGreen",		-- 绿
	"itemframeBlue",		-- 蓝
	"itemframePurple",		-- 紫
	"itemframePink",		-- 粉
	"itemframeOrange",		-- 橙
	"itemframeGold",		-- 金
}
Item.DEFAULT_COLOR = "itemframe";	-- 默认白色

Item.DROP_OBJ_TYPE_SPE = 0; --掉落特殊的
Item.DROP_OBJ_TYPE_MONEY = 1; --掉落钱
Item.DROP_OBJ_TYPE_ITEM  = 2; --掉落道具

Item.emEquipActiveReq_None = 0;
Item.emEquipActiveReq_Ride = 1;--骑乘激活

Item.szGeneralEquipPosAtlas = "UI/Atlas/Item/Item/Item2.prefab"
Item.tbGeneralEquipPosIcons = {
	[Item.EQUIPPOS_HEAD]		= "Helm",
	[Item.EQUIPPOS_BODY]		= "Armor",
	[Item.EQUIPPOS_BELT]		= "Belt",
	[Item.EQUIPPOS_WEAPON]		= "Weapon",
	[Item.EQUIPPOS_FOOT]		= "Boots",
	[Item.EQUIPPOS_CUFF]		= "Cuff",	--护腕
	[Item.EQUIPPOS_AMULET]		= "Amulet",	--护身符
	[Item.EQUIPPOS_RING]		= "Ring",
	[Item.EQUIPPOS_NECKLACE]	= "Necklace",
	[Item.EQUIPPOS_PENDANT]		= "Pendant",	--玉佩
	[Item.EQUIPPOS_HORSE]		= "",
}


Item.DetailType_Normal 	= 1;
Item.DetailType_Rare 	= 2;
Item.DetailType_Inherit = 3;
Item.DetailType_Gold 	= 4;

Item.tbSellMoneyType = {
	[Item.DetailType_Normal]  = "Coin",
	[Item.DetailType_Rare] 	  = "Contrib",
	[Item.DetailType_Inherit] = "Contrib",
	-- [Item.DetailType_Gold] 	  = "Contrib", --黄金装备不能出售
}

Item.EXT_USER_VALUE_GROUP = 135

Item.tbExtBagSetting = 
{
	-- SaveId     BagCount
	{	1,			10},
	{	2,			10},
	{	3,			10},
	{	4,			10},
}
