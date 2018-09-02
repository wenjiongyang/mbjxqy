NewInformation.tbActivity = {
    FactionBattle = {
        szTitle    = "門派競技",
        -- szUiName   = "Normal", -- 指定的UI组件，默认用Key作为组件名字
    },
    OpenSrvActivity = {
        szTitle    = "百大幫派",
        nReqLevel = 11,
    },
    FactionMonkey = {
        szTitle    = "門派競選",
    },

    DomainBattle = {
        szTitle    = "攻城戰結果",
        szUiName   = "TerritoryInfo",
    },

    LevelRankActivity = {
        szTitle    = "等級排名",
        szUiName   = "LevelRankActivity",
        nReqLevel = 10,
    },

     PowerRankActivity = {
        szTitle    = "戰力排名",
        szUiName   = "PowerRankActivity",
        nReqLevel = 10,
    },

	NormalActiveUi = {
		szTitle = "活動",
		szUiName = "DragonBoatFestival",
		nReqLevel = 10,
	},

    HSLJEightRank = {
        szTitle = "華山論劍八強",
        szUiName = "HSLJEightRank",
        nReqLevel = 10,
    },

    HSLJChampionship = {
        szTitle = "華山論劍冠軍",
        szUiName = "HSLJChampionship",
        nReqLevel = 10,
    },

    RandomFubenCollection = {
        szTitle    = "凌絕峰收集榜",
        szUiName   = "CardCollectionInfo",
    },

    DomainBattleAct =
    {
        szTitle    = "攻城戰狂歡活動",
        szUiName   = "Normal",
    };

    DomainBattleAct2 =
    {
        szTitle    = "攻城戰狂歡活動二",
        szUiName   = "Normal",
    };

    JXSH_Collection = {
        szTitle    = "錦繡山河收集榜",
        szUiName   = "JXSH_RankInfo",
    },
    NYLottery = 
    {
        szTitle    = "新年金雞抽獎",
    },
    NYLotteryResult = 
    {
        szTitle    = "抽獎活動幸運名單",
    },
    AnniversaryBag = 
    {
        szTitle    = "周年慶超值禮包",
    },
    WLDHChampionship = 
    {
      szTitle    = "武林大會冠軍",  
    },
    HonorMonthRank = {
        szTitle = "武林榮譽白金名俠",
        szUiName = "HonorMonthRank",
    },

    LotteryResult =
    {
        szTitle = "盟主的贈禮",
        szUiName = "LotteryResult",
    },
}
---------------在此的配置适用于数据较大的功能，会单独存储ScriptData，数据小的情况下不需配置---------------

function NewInformation:RegisterButtonCallBack(szType, tbCallBack)
    self.tbButtonCallBack = self.tbButtonCallBack or {};
    self.tbButtonCallBack[szType] = tbCallBack;
end

function NewInformation:UnRegisterButtonCallBack(szType)
    self.tbButtonCallBack = self.tbButtonCallBack or {};
    self.tbButtonCallBack[szType] = nil;
end

function NewInformation:OnButtonEvent(szType)
    local tbCallBack = self.tbButtonCallBack[szType];
    if not tbCallBack or not tbCallBack[1] then
        return;
    end

    Lib:CallBack(tbCallBack);
end