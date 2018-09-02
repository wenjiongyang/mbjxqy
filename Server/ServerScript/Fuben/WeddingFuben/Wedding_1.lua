local tbFubenSetting = {};
local nMapTemplateId = 5000

Fuben:SetFubenSetting(nMapTemplateId, tbFubenSetting)   -- 绑定副本内容和地图

tbFubenSetting.szNpcPointFile           = "Setting/Fuben/WeddingFuben_1/NpcPos.tab"         -- NPC点
tbFubenSetting.szPathFile               = "Setting/Fuben/WeddingFuben_1/NpcPath.tab"        -- 寻路点

tbFubenSetting.szFubenClass   = Wedding.szFubenBase;                                  -- 副本类型
tbFubenSetting.szName         = "莊園·晚櫻連理"                                             -- 单纯的名字，后台输出或统计使用
tbFubenSetting.tbBeginPoint   = {2574,4970}  --出生点
tbFubenSetting.tbTempRevivePoint = {2574,4970}  --复活点

-- ID可以随便 普通副本NPC数量 ；精英模式NPC数量
tbFubenSetting.NUM = 
{
    
}

tbFubenSetting.ANIMATION = 
{
    [1] = "Scenes/camera/jiehun/jiehun_diji_cam.controller",   --拜堂镜头
}

--NPC模版ID，NPC等级，NPC五行；
--[[

]]

tbFubenSetting.NPC = 
{
    --花童
    [1] = {nTemplate = 2374, nLevel = -1, nSeries = 0},
    --月老
    [2] = {nTemplate = 2535, nLevel = -1, nSeries = 0},
    --商人
    [3] = {nTemplate = 2373, nLevel = -1, nSeries = 0},
    --第1道菜
    [4] = {nTemplate = 2537, nLevel = -1, nSeries = 0},
    --第2道菜
    [5] = {nTemplate = 2538, nLevel = -1, nSeries = 0},
    --第3道菜
    [6] = {nTemplate = 2539, nLevel = -1, nSeries = 0},
    --第4道菜
    [7] = {nTemplate = 2540, nLevel = -1, nSeries = 0},
    --第5道菜
    [8] = {nTemplate = 2541, nLevel = -1, nSeries = 0},
    --篝火
    [9] = {nTemplate = 2552, nLevel = -1, nSeries = 0},
    --空的桌子
    [10] = {nTemplate = 2556, nLevel = -1, nSeries = 0},
    --花圈
    [11] = {nTemplate = 2654, nLevel = -1, nSeries = 0},
}

-- 婚礼现场的家具
tbFubenSetting.FurnitureItem = 
{
    --宴席凳子-左
    [10] = {nTemplate = 10021, nPosX = 3139, nPosY = 5687, nRotation = 180, bNotSync = nil};
    [11] = {nTemplate = 10021, nPosX = 3725, nPosY = 5674, nRotation = 180, bNotSync = nil};
    [12] = {nTemplate = 10021, nPosX = 3167, nPosY = 4235, nRotation = 180, bNotSync = nil};
    [13] = {nTemplate = 10021, nPosX = 3703, nPosY = 4202, nRotation = 180, bNotSync = nil};

    --宴席凳子-右
    [14] = {nTemplate = 10021, nPosX = 3492, nPosY = 5683, nRotation = 0, bNotSync = nil};
    [15] = {nTemplate = 10021, nPosX = 4075, nPosY = 5669, nRotation = 0, bNotSync = nil};
    [16] = {nTemplate = 10021, nPosX = 3497, nPosY = 4225, nRotation = 0, bNotSync = nil};
    [17] = {nTemplate = 10021, nPosX = 4072, nPosY = 4207, nRotation = 0, bNotSync = nil};

    --宴席凳子-上
    [20] = {nTemplate = 10021, nPosX = 3329, nPosY = 5842, nRotation = 270, bNotSync = nil};
    [21] = {nTemplate = 10021, nPosX = 3893, nPosY = 5854, nRotation = 270, bNotSync = nil};
    [22] = {nTemplate = 10021, nPosX = 3330, nPosY = 4402, nRotation = 270, bNotSync = nil};
    [23] = {nTemplate = 10021, nPosX = 3892, nPosY = 4358, nRotation = 270, bNotSync = nil};

    --宴席凳子-下
    [24] = {nTemplate = 10021, nPosX = 3331, nPosY = 5520, nRotation = 90, bNotSync = nil};
    [25] = {nTemplate = 10021, nPosX = 3881, nPosY = 5526, nRotation = 90, bNotSync = nil};
    [26] = {nTemplate = 10021, nPosX = 3330, nPosY = 4066, nRotation = 90, bNotSync = nil};
    [27] = {nTemplate = 10021, nPosX = 3876, nPosY = 4012, nRotation = 90, bNotSync = nil};

    --观众席椅子
    [50] = {nTemplate = 1518, nPosX = 4942, nPosY = 5838, nRotation = 0, bNotSync = nil};
    [51] = {nTemplate = 1518, nPosX = 5294, nPosY = 5837, nRotation = 0, bNotSync = nil};
    [52] = {nTemplate = 1518, nPosX = 4941, nPosY = 5654, nRotation = 0, bNotSync = nil};
    [53] = {nTemplate = 1518, nPosX = 5294, nPosY = 5655, nRotation = 0, bNotSync = nil};
    [54] = {nTemplate = 1518, nPosX = 4944, nPosY = 5479, nRotation = 0, bNotSync = nil};
    [55] = {nTemplate = 1518, nPosX = 5291, nPosY = 5480, nRotation = 0, bNotSync = nil};
    [56] = {nTemplate = 1518, nPosX = 4945, nPosY = 4452, nRotation = 0, bNotSync = nil};
    [57] = {nTemplate = 1518, nPosX = 5295, nPosY = 4451, nRotation = 0, bNotSync = nil};
    [58] = {nTemplate = 1518, nPosX = 4948, nPosY = 4269, nRotation = 0, bNotSync = nil};
    [59] = {nTemplate = 1518, nPosX = 5295, nPosY = 4269, nRotation = 0, bNotSync = nil};
    [60] = {nTemplate = 1518, nPosX = 4942, nPosY = 4084, nRotation = 0, bNotSync = nil};
    [61] = {nTemplate = 1518, nPosX = 5294, nPosY = 4087, nRotation = 0, bNotSync = nil};

    --证婚席
    [80] = {nTemplate = 10027, nPosX = 5754, nPosY = 5362, nRotation = 180, bNotSync = nil};
    [81] = {nTemplate = 10027, nPosX = 5754, nPosY = 5194, nRotation = 180, bNotSync = nil};
    [82] = {nTemplate = 10027, nPosX = 5754, nPosY = 4718, nRotation = 180, bNotSync = nil};
    [83] = {nTemplate = 10027, nPosX = 5754, nPosY = 4550, nRotation = 180, bNotSync = nil};
}

tbFubenSetting.FurnitureItemGroup = 
{
    --宴席凳子-左
    ["dengzi_l"] = {10,11,12,13};
    --宴席凳子-右
    ["dengzi_r"] = {14,15,16,17};
    --宴席凳子-上
    ["dengzi_t"] = {20,21,22,23};
    --宴席凳子-下
    ["dengzi_b"] = {24,25,26,27};
    --观众席椅子
    ["yizi"] = {50,51,52,53,54,55,56,57,58,59,60,61};
    --证婚席
    ["zh_yizi_1"] = {80,81,82,83};
}

tbFubenSetting.tbEndMarryCeremonyPos = {{6064,5056}, {6066,4849}}             -- 结束拜堂之后主角传送的位置
tbFubenSetting.tbStartMarryCeremonyPos = {{4613,4968}}                         -- 开始拜堂之后主角传送的位置（用于宾客同步）
tbFubenSetting.tbStartMarryCeremonyPlayerPos =                                  -- 开始拜堂宾客的聚集地
{
    {4410,5440};
    {4552,5443};
    {4687,5443};
    {4811,5441};
    {4465,5533};
    {4643,5531};
    {4764,5525};
    {4420,5611};
    {4541,5616};
    {4701,5617};
    {4814,5618};
    {4455,5696};
    {4608,5698};
    {4758,5688};
    {4449,4523};
    {4594,4519};
    {4714,4513};
    {4797,4521};
    {4495,4410};
    {4631,4417};
    {4763,4412};
    {4427,4347};
    {4570,4353};
    {4692,4344};
    {4797,4343};
    {4483,4274};
    {4627,4260};
    {4750,4274};
}

-- 喜糖位置
tbFubenSetting.tbCandyPos = {
    {6122,5382},
    {6144,4485},
    {5351,4932},
    {4213,5022},
    {3812,4845},
    {3531,5071},
    {3089,4870},
    {4133,4835},
    {3278,5099},
    {4322,5633},
    {4645,5855},
    {4648,5464},
    {4332,4363},
    {4834,4420},
    {4489,4039},
    {4630,4947},
    {4347,5882},
    {4613,4313},
    {3934,5069},
    {5574,4943},
    {5936,4400},
    {5904,4524},
    {5886,5460},
    {5965,5258},
    {6203,5251},
    {4458,4788},
}
-- 跳过迎宾之后需要解锁的锁id
tbFubenSetting.nCancelWelcomeUnlockId = 502
-- 开始婚礼之后需要解锁的锁id
tbFubenSetting.nStartWeddingUnlockId = 503
-- 宣誓结束之后需要解锁的锁id
tbFubenSetting.nEndPromiseUnlockId = 506
-- 同心果结束之后需要解锁的锁id
tbFubenSetting.nEndConcentricFruitUnlockId = nil
-- 证婚人相关
tbFubenSetting.tbWitnessInfo = 
{
    tbPos = {{5822,5173},{5819,4698},{5819,5345},{5824,4531}};
    szGroup = "zh_yizi_1";
}

-- ChangeRoomState              更改房间title
--                              参数：nFloor 层, nRoomIdx 房间序列, szTitile 标题, nX, nY自动寻路点坐标, bKillBoss 是否杀死了BOSS
--                              示例：{"AddNpc", "NpcIndex2", "NpcNum2", 3, "Test1", "NpcPos2", true, 30, 2, 206, 1},

tbFubenSetting.LOCK = 
{
    -- 1号锁不能不填，默认1号为起始锁，nTime是到时间自动解锁，nNum表示需要解锁的次数，如填3表示需要被解锁3次才算真正解锁，可以配置字符串
    [1] = {nTime = 1, nNum = 0,
        --tbPrelock 前置锁，激活锁的必要条件{1 , 2, {3, 4}}，代表1和2号必须解锁，3和4任意解锁一个即可
        tbPrelock = {},
        --tbStartEvent 锁激活时的事件
        tbStartEvent = 
        {
            {"SetKickoutPlayerDealyTime", 1},
            {"SetPlayerDeathDoRevive", 5, "您將在 %d 秒後復活", true},
            --{"AddFurniture", 1, "a"}
            --{"AddFurnitureGroup", "a"}
        },
        --tbStartEvent 锁解开时的事件
        tbUnLockEvent = 
        {            
        },
    },

    --副本开始
    [500] = {nTime = 1, nNum = 0,
        tbPrelock = {1},
        tbStartEvent = 
        {
            --添加宴席空桌
            --{"AddFurnitureGroup", "zhuozi"},  
            {"AddNpc", 10, 1, nil, "Marry1_Table", "Marry1_Table1", true, 0, nil, nil, nil},
            {"AddNpc", 10, 1, nil, "Marry1_Table", "Marry1_Table2", true, 0, nil, nil, nil},
            {"AddNpc", 10, 1, nil, "Marry1_Table", "Marry1_Table3", true, 0, nil, nil, nil},
            {"AddNpc", 10, 1, nil, "Marry1_Table", "Marry1_Table4", true, 0, nil, nil, nil},

            --添加宴席凳子
            {"AddFurnitureGroup", "dengzi_l"},  
            --添加宴席凳子
            {"AddFurnitureGroup", "dengzi_r"},  
            --添加宴席凳子
            {"AddFurnitureGroup", "dengzi_t"},  
            --添加宴席凳子
            {"AddFurnitureGroup", "dengzi_b"},  
            --添加观众席椅子
            {"AddFurnitureGroup", "yizi"},   
            --添加证婚席椅子
            {"AddFurnitureGroup", "zh_yizi_1"},    
            --添加花圈
            {"AddNpc", 11, 1, nil, "huaquan", "Marry1_huaquan1", true, 0, nil, nil, nil},
            {"AddNpc", 11, 1, nil, "huaquan", "Marry1_huaquan2", true, 0, nil, nil, nil},
            {"AddNpc", 11, 1, nil, "huaquan", "Marry1_huaquan3", true, 0, nil, nil, nil},
            {"AddNpc", 11, 1, nil, "huaquan", "Marry1_huaquan4", true, 0, nil, nil, nil},
            {"AddNpc", 11, 1, nil, "huaquan", "Marry1_huaquan5", true, 0, nil, nil, nil},
            {"AddNpc", 11, 1, nil, "huaquan", "Marry1_huaquan6", true, 0, nil, nil, nil},
            {"AddNpc", 11, 1, nil, "huaquan", "Marry1_huaquan7", true, 0, nil, nil, nil},
            {"AddNpc", 11, 1, nil, "huaquan", "Marry1_huaquan8", true, 0, nil, nil, nil},
            {"AddNpc", 11, 1, nil, "huaquan", "Marry1_huaquan9", true, 0, nil, nil, nil},
            {"AddNpc", 11, 1, nil, "huaquan", "Marry1_huaquan10", true, 0, nil, nil, nil},
            {"AddNpc", 11, 1, nil, "huaquan", "Marry1_huaquan11", true, 0, nil, nil, nil},
            {"AddNpc", 11, 1, nil, "huaquan", "Marry1_huaquan12", true, 0, nil, nil, nil},
            {"AddNpc", 11, 1, nil, "huaquan", "Marry1_huaquan13", true, 0, nil, nil, nil},
            {"AddNpc", 11, 1, nil, "huaquan", "Marry1_huaquan14", true, 0, nil, nil, nil},
            {"AddNpc", 11, 1, nil, "huaquan", "Marry1_huaquan15", true, 0, nil, nil, nil},
            --添加花童左
            {"AddNpc", 1, 1, nil, "huatong_L", "Wedding_1_L_huatong1", true, 30, nil, nil, nil},
            {"AddNpc", 1, 1, nil, "huatong_L", "Wedding_1_L_huatong2", true, 30, nil, nil, nil},
            {"AddNpc", 1, 1, nil, "huatong_L", "Wedding_1_L_huatong3", true, 30, nil, nil, nil},
            {"AddNpc", 1, 1, nil, "huatong_L", "Wedding_1_L_huatong4", true, 30, nil, nil, nil},
            --添加花童右
            {"AddNpc", 1, 1, nil, "huatong_R", "Wedding_1_R_huatong1", true, 0, nil, nil, nil},
            {"AddNpc", 1, 1, nil, "huatong_R", "Wedding_1_R_huatong2", true, 0, nil, nil, nil},
            {"AddNpc", 1, 1, nil, "huatong_R", "Wedding_1_R_huatong3", true, 0, nil, nil, nil},
            {"AddNpc", 1, 1, nil, "huatong_R", "Wedding_1_R_huatong4", true, 0, nil, nil, nil},
            --添加主台花童
            {"AddNpc", 1, 1, nil, "huatong_z", "Wedding_1_Z_huatong1", true, 47, nil, nil, nil},
            {"AddNpc", 1, 1, nil, "huatong_z", "Wedding_1_Z_huatong2", true, 47, nil, nil, nil},
            --添加月老
            {"AddNpc", 2, 1, nil, "yuelao", "Wedding_yuelao", true, 47, nil, nil, nil},
            --添加婚礼商人
            {"AddNpc", 3, 1, nil, "huatong_Shop", "Wedding_Shop", true, 0, nil, nil, nil},
            --添加篝火
            {"AddNpc", 9, 1, nil, "Marry_gouhuo", "Marry_gouhuo", true, 0, nil, nil, nil},

            {"SetShowTime", 501, nil, "迎賓："},
            {"SetTargetInfo", "新人點擊請柬，邀請親朋好友"},
        },
        tbUnLockEvent = 
        {
            
        },
    },

    --迎宾阶段：10分钟
    [501] = {nTime = 10*60, nNum = 0,
        tbPrelock = {1},
        tbStartEvent = 
        {
            {"RaiseEvent", "StartWelcome"},
            {"RaiseEvent", "SendKinNotice", "[FFFE0D]「%s」[-]和[FFFE0D]「%s」[-]舉行的[FFFE0D]莊園·晚櫻連理[-]婚禮即將開始，各位俠士可前往[FFFE0D]襄陽城月老[-]處申請進入"},
            {"RaiseEvent", "SendWorldNotice", "[FFFE0D]「%s」[-]和[FFFE0D]「%s」[-]舉行的[FFFE0D]莊園·晚櫻連理[-]婚禮即將開始，各位俠士可前往[FFFE0D]襄陽城月老[-]處申請進入"},
        },
        tbUnLockEvent = 
        {
            {"RaiseEvent", "EndWelcome"},
        },
    },

    --前缀锁，不做任何事情，用来玩家手动跳过迎宾阶段
    [502] = {nTime = 0, nNum = 1,
        tbPrelock = {1},
        tbStartEvent = 
        {

        },
        tbUnLockEvent = 
        {
            {"SetShowTime", 503, nil, "婚禮準備："},
            {"SetTargetInfo", "找月老對話開啟婚禮"},
        },
    },

    --开始婚礼：1分钟
    [503] = {nTime = 1*60, nNum = 0,
        tbPrelock = {502},
        tbStartEvent = 
        {
            {"RaiseEvent", "StartWedding"},
        },
        tbUnLockEvent = 
        {
            {"RaiseEvent", "EndWedding"},
            {"SetShowTime", 504, nil, "準備宣誓："},
            {"SetTargetInfo", "相互許下愛的誓言"},
        },
    },

    --宣誓的准备：10秒
    [504] = {nTime = 10, nNum = 0,
        tbPrelock = {503},
        tbStartEvent = 
        {

        },
        tbUnLockEvent = 
        {
            {"SetShowTime", 505, nil, "山盟海誓："},
            {"SetTargetInfo", "對伴侶說出愛的誓言"},
        },
    },

    --山盟海誓：2分钟
    [505] = {nTime = 2*60, nNum = 0,
        tbPrelock = {504},
        tbStartEvent = 
        {
            {"RaiseEvent", "StartPromise"} 
        },
        tbUnLockEvent = 
        {
            {"RaiseEvent", "EndPromise"},
        },
    },

    --前缀锁，不做任何事情，用来玩家提前完成誓言后跳过阶段
    [506] = {nTime = 0, nNum = 1,
        tbPrelock = {1},
        tbStartEvent = 
        {

        },
        tbUnLockEvent = 
        {

        },
    },

    [507] = {nTime = 2, nNum = 0,
        tbPrelock = {506},
        tbStartEvent = 
        {
            --五彩烟花
            {"RaiseEvent", "PlayWeddingFirework", 1},
        },
        tbUnLockEvent = 
        {
        },
    },

    [508] = {nTime = 2, nNum = 0,
        tbPrelock = {507},
        tbStartEvent = 
        {
            --五彩烟花
            {"RaiseEvent", "PlayWeddingFirework", 1},
        },
        tbUnLockEvent = 
        {
        },
    },

    [509] = {nTime = 2, nNum = 0,
        tbPrelock = {508},
        tbStartEvent = 
        {
            --囍烟花
            {"RaiseEvent", "PlayWeddingFirework", 2},
        },
        tbUnLockEvent = 
        {
            {"SetShowTime", 600, nil, "準備拜堂："},
            {"SetTargetInfo", "良時將近，準備拜堂"},
        },
    },

    --拜堂前奏准备：10秒
    [600] = {nTime = 10, nNum = 0,
        tbPrelock = {509},
        tbStartEvent = 
        {
            
        },
        tbUnLockEvent = 
        {
            {"SetShowTime", 601, nil, "拜堂："},
            {"SetTargetInfo", "良時已到，新人拜天地"},
        },
    },

    --拜堂：60秒
    [601] = {nTime = 65, nNum = 0,
        tbPrelock = {600},
        tbStartEvent = 
        {
            
        },
        tbUnLockEvent = 
        {

        },
    },

    [2] = {nTime = 1, nNum = 0,
        tbPrelock = {600},
        tbStartEvent = 
        {
            
        },
        tbUnLockEvent = 
        {
            --片头字幕
            {"RaiseEvent", "OpenWeddingInterludePanel", "良時已到，婚禮開始"},
        },
    },

    [900] = {nTime = 1, nNum = 0,
        tbPrelock = {2},
        tbStartEvent = 
        {
            
        },
        tbUnLockEvent = 
        {
            --将宾客、主角传送至观众席
            {"RaiseEvent", "SetMarryCeremonyPlayerPos"},
        },
    },

    [3] = {nTime = 8, nNum = 0,
        tbPrelock = {2},
        tbStartEvent = 
        {
            --动画开始前，暂时删除重叠的NPC、家具
            {"DelNpc", "huatong_L"},
            {"DelNpc", "huatong_R"},
            {"DelNpc", "huatong_z"},
            {"DelNpc", "yuelao"},
            {"DelNpc", "huatong_Shop"},
            --{"DeleteFurniture", "zhuozi"},
            {"DelNpc", "Marry1_Table"},
            {"DeleteFurniture", "dengzi_l"},
            {"DeleteFurniture", "dengzi_r"},
            {"DeleteFurniture", "dengzi_t"},
            {"DeleteFurniture", "dengzi_b"},
            {"DeleteFurniture", "yizi"},
        },
        tbUnLockEvent = 
        {
            {"RaiseEvent", "DestroyUi", "WeddingInterludePanel"},
            -- 开始拜堂
            {"RaiseEvent", "StartMarryCeremony"},
            {"SetGameWorldScale", 0.7},   --动画速度
        },
    },
    [4] = {nTime = 17, nNum = 0,
        tbPrelock = {3},
        tbStartEvent = 
        {
           
        },
        tbUnLockEvent = 
        {
           {"RaiseEvent", "MarryCeremonyPlayerBlackMsg", "一拜天地"},
            {"SetGameWorldScale", 0.8},   --动画速度
        },
    },
    [5] = {nTime = 24, nNum = 0,
        tbPrelock = {3},
        tbStartEvent = 
        {
           
        },
        tbUnLockEvent = 
        {
           {"RaiseEvent", "MarryCeremonyPlayerBlackMsg", "二拜高祖"},
        },
    },
    [6] = {nTime = 32, nNum = 0,
        tbPrelock = {3},
        tbStartEvent = 
        {
           
        },
        tbUnLockEvent = 
        {
           {"RaiseEvent", "MarryCeremonyPlayerBlackMsg", "夫妻對拜"},
        },
    },

    --第6秒降低动画速度
    [50] = {nTime = 6, nNum = 0,
        tbPrelock = {3},
        tbStartEvent = 
        {
           
        },
        tbUnLockEvent = 
        {
            {"SetGameWorldScale", 0.6},   
        },
    },

    ---------------------镜头切换------------------------
    [52] = {nTime = 7, nNum = 0,
        tbPrelock = {3},
        tbStartEvent = 
        {
           
        },
        tbUnLockEvent = 
        {
            {"RaiseEvent", "MarryCeremonyPlayerFadeAnim", "", "", 0.2, 0.2},
        },
    },
    [53] = {nTime = 13, nNum = 0,
        tbPrelock = {3},
        tbStartEvent = 
        {
           
        },
        tbUnLockEvent = 
        {
            {"RaiseEvent", "MarryCeremonyPlayerFadeAnim", "", "", 0.1, 0.1},
        },
    },

    [100] = {nTime = 40, nNum = 0,
        tbPrelock = {3},
        tbStartEvent = 
        {
           
        },
        tbUnLockEvent = 
        {
             -- 黑幕动画要在EndMarryCeremony抛出之前用
            {"RaiseEvent", "MarryCeremonyPlayerFadeAnim", "", "", 0.2, 0.5},
            -- 片尾字幕
            {"RaiseEvent", "OpenWeddingInterludePanel", nil, "天生才子佳人配，只羨鴛鴦不羨仙"},
        },
    },

    [101] = {nTime = 41, nNum = 0,
        tbPrelock = {3},
        tbStartEvent = 
        {
           
        },
        tbUnLockEvent = 
        {
             -- 结束拜堂
            {"RaiseEvent", "EndMarryCeremony"},
            --{"BlackMsg", "拜堂结束"},
            {"SetGameWorldScale", 1}, 
        },
    },

    [102] = {nTime = 48, nNum = 0,
        tbPrelock = {3},
        tbStartEvent = 
        {
        },
        tbUnLockEvent = 
        {
            {"RaiseEvent", "DestroyUi", "WeddingInterludePanel"},
            {"RaiseEvent", "SendWorldNotice", "執子之手，與子偕老！恭喜[FFFE0D]「%s」[-]與[FFFE0D]「%s」[-]喜結良緣，祝兩位新人永結同心，白頭偕老。"},
            ----------动画结束后把临时删除的NPC加回来
            --添加宴席空桌
            --{"AddFurnitureGroup", "zhuozi"},  
            {"AddNpc", 10, 1, nil, "Marry1_Table", "Marry1_Table1", true, 0, nil, nil, nil},
            {"AddNpc", 10, 1, nil, "Marry1_Table", "Marry1_Table2", true, 0, nil, nil, nil},
            {"AddNpc", 10, 1, nil, "Marry1_Table", "Marry1_Table3", true, 0, nil, nil, nil},
            {"AddNpc", 10, 1, nil, "Marry1_Table", "Marry1_Table4", true, 0, nil, nil, nil},
            --添加宴席凳子
            {"AddFurnitureGroup", "dengzi_l"},  
            --添加宴席凳子
            {"AddFurnitureGroup", "dengzi_r"},  
            --添加宴席凳子
            {"AddFurnitureGroup", "dengzi_t"},  
            --添加宴席凳子
            {"AddFurnitureGroup", "dengzi_b"}, 
            --添加观众席椅子
            {"AddFurnitureGroup", "yizi"},    
            --添加花童左
            {"AddNpc", 1, 1, nil, "huatong_L", "Wedding_1_L_huatong1", true, 30, nil, nil, nil},
            {"AddNpc", 1, 1, nil, "huatong_L", "Wedding_1_L_huatong2", true, 30, nil, nil, nil},
            {"AddNpc", 1, 1, nil, "huatong_L", "Wedding_1_L_huatong3", true, 30, nil, nil, nil},
            {"AddNpc", 1, 1, nil, "huatong_L", "Wedding_1_L_huatong4", true, 30, nil, nil, nil},
            --添加花童右
            {"AddNpc", 1, 1, nil, "huatong_R", "Wedding_1_R_huatong1", true, 0, nil, nil, nil},
            {"AddNpc", 1, 1, nil, "huatong_R", "Wedding_1_R_huatong2", true, 0, nil, nil, nil},
            {"AddNpc", 1, 1, nil, "huatong_R", "Wedding_1_R_huatong3", true, 0, nil, nil, nil},
            {"AddNpc", 1, 1, nil, "huatong_R", "Wedding_1_R_huatong4", true, 0, nil, nil, nil},
            --添加主台花童
            {"AddNpc", 1, 1, nil, "huatong_z", "Wedding_1_Z_huatong1", true, 47, nil, nil, nil},
            {"AddNpc", 1, 1, nil, "huatong_z", "Wedding_1_Z_huatong2", true, 47, nil, nil, nil},
            --添加月老
            {"AddNpc", 2, 1, nil, "yuelao", "Wedding_yuelao", true, 47, nil, nil, nil},
            --添加婚礼商人
            {"AddNpc", 3, 1, nil, "huatong_Shop", "Wedding_Shop", true, 14, nil, nil, nil},
        },
    },

    [103] = {nTime = 2, nNum = 0,
        tbPrelock = {102},
        tbStartEvent = 
        {
            --五彩烟花
            {"RaiseEvent", "PlayWeddingFirework", 1},
        },
        tbUnLockEvent = 
        {
        },
    },

    [104] = {nTime = 2, nNum = 0,
        tbPrelock = {103},
        tbStartEvent = 
        {
            --五彩烟花
            {"RaiseEvent", "PlayWeddingFirework", 1},
        },
        tbUnLockEvent = 
        {
        },
    },

    [105] = {nTime = 2, nNum = 0,
        tbPrelock = {104},
        tbStartEvent = 
        {
            --囍烟花
            {"RaiseEvent", "PlayWeddingFirework", 2},
        },
        tbUnLockEvent = 
        {
        },
    },

    [106] = {nTime = 2, nNum = 0,
        tbPrelock = {105},
        tbStartEvent = 
        {
            --五彩烟花
            {"RaiseEvent", "PlayWeddingFirework", 1},

            --百年好合烟花
            {"PlayEffect", 9179, 6206,4980, 0},
        },
        tbUnLockEvent = 
        {
            {"SetShowTime", 107, nil, "爆竹準備中："},
            {"SetTargetInfo", "歡聚一堂，準備點燃"},
        },
    },

    --开心爆竹准备：10秒
    [107] = {nTime = 10, nNum = 0,
        tbPrelock = {105},
        tbStartEvent = 
        {

        },
        tbUnLockEvent = 
        {
            {"SetShowTime", 700, nil, "開心爆竹："},
            {"SetTargetInfo", "祝福新人，百年好合"},
        },
    },

    --开心爆竹：1分钟
    [700] = {nTime = 60, nNum = 0,
        tbPrelock = {107},
        tbStartEvent = 
        {
            {"RaiseEvent", "AddFirecracker", 6041, 4956},
        },
        tbUnLockEvent = 
        {
            {"RaiseEvent", "EndFirecracker"},
        },
    },

    [701] = {nTime = 2, nNum = 0,
        tbPrelock = {700},
        tbStartEvent = 
        {
            --五彩烟花
            {"RaiseEvent", "PlayWeddingFirework", 1},
        },
        tbUnLockEvent = 
        {
        },
    },

    [702] = {nTime = 2, nNum = 0,
        tbPrelock = {701},
        tbStartEvent = 
        {
            --五彩烟花
            {"RaiseEvent", "PlayWeddingFirework", 1},
        },
        tbUnLockEvent = 
        {
        },
    },

    [703] = {nTime = 2, nNum = 0,
        tbPrelock = {702},
        tbStartEvent = 
        {
            --囍烟花
            {"RaiseEvent", "PlayWeddingFirework", 2},
        },
        tbUnLockEvent = 
        {
            {"SetShowTime", 704, nil, "宴席準備："},
            {"SetTargetInfo", "佳餚美食，等待開席"},
        },
    },

    --宴席准备：10秒
    [704] = {nTime = 10, nNum = 0,
        tbPrelock = {703},
        tbStartEvent = 
        {
        },
        tbUnLockEvent = 
        {
            {"SetShowTime", 705, nil, "宴席："},
            {"SetTargetInfo", "第1道佳餚：姻緣美滿"},
        },
    },

    --宴席：第1道菜
    [705] = {nTime = 40, nNum = 0,
        tbPrelock = {704},
        tbStartEvent = 
        {
            --删除宴席空桌
            --{"DeleteFurniture", "zhuozi"},
            {"DelNpc", "Marry1_Table"},
            --添加宴席满桌
            {"AddNpc", 4, 1, nil, "Marry1_TableFood_1", "Marry1_TableFood_1", true, 0, nil, nil, nil},
            {"AddNpc", 4, 1, nil, "Marry1_TableFood_1", "Marry1_TableFood_2", true, 0, nil, nil, nil},
            {"AddNpc", 4, 1, nil, "Marry1_TableFood_1", "Marry1_TableFood_3", true, 0, nil, nil, nil},
            {"AddNpc", 4, 1, nil, "Marry1_TableFood_1", "Marry1_TableFood_4", true, 0, nil, nil, nil},
            {"RaiseEvent", "BlackMsgWithRole", "第1道佳餚：姻緣美滿，祝[FFFE0D]「%s」[-]和[FFFE0D]「%s」[-]姻緣美滿"},
            {"RaiseEvent", "StartTableFood"}  
        },
        tbUnLockEvent = 
        {
            {"SetShowTime", 706, nil, "宴席："},
            {"SetTargetInfo", "第2道佳餚：喜慶滿堂"},
        },
    },

    --宴席：第2道菜
    [706] = {nTime = 40, nNum = 0,
        tbPrelock = {705},
        tbStartEvent = 
        {
            --删除上一道菜
            {"DelNpc", "Marry1_TableFood_1"},

            {"AddNpc", 5, 1, nil, "Marry1_TableFood_2", "Marry1_TableFood_1", true, 0, nil, nil, nil},
            {"AddNpc", 5, 1, nil, "Marry1_TableFood_2", "Marry1_TableFood_2", true, 0, nil, nil, nil},
            {"AddNpc", 5, 1, nil, "Marry1_TableFood_2", "Marry1_TableFood_3", true, 0, nil, nil, nil},
            {"AddNpc", 5, 1, nil, "Marry1_TableFood_2", "Marry1_TableFood_4", true, 0, nil, nil, nil},
            {"RaiseEvent", "BlackMsgWithRole", "第2道佳餚：喜慶滿堂，祝[FFFE0D]「%s」[-]和[FFFE0D]「%s」[-]喜慶滿堂"},
            {"RaiseEvent", "StartTableFood"}  
        },
        tbUnLockEvent = 
        {
            {"SetShowTime", 707, nil, "宴席："},
            {"SetTargetInfo", "第3道佳餚：花好月圓"}, 
        },
    },

    --宴席：第3道菜
    [707] = {nTime = 40, nNum = 0,
        tbPrelock = {706},
        tbStartEvent = 
        {
            --删除上一道菜
            {"DelNpc", "Marry1_TableFood_2"},

            {"AddNpc", 6, 1, nil, "Marry1_TableFood_3", "Marry1_TableFood_1", true, 0, nil, nil, nil},
            {"AddNpc", 6, 1, nil, "Marry1_TableFood_3", "Marry1_TableFood_2", true, 0, nil, nil, nil},
            {"AddNpc", 6, 1, nil, "Marry1_TableFood_3", "Marry1_TableFood_3", true, 0, nil, nil, nil},
            {"AddNpc", 6, 1, nil, "Marry1_TableFood_3", "Marry1_TableFood_4", true, 0, nil, nil, nil},
            {"RaiseEvent", "BlackMsgWithRole", "第3道佳餚：花好月圓，祝[FFFE0D]「%s」[-]和[FFFE0D]「%s」[-]花好月圓"},
            {"RaiseEvent", "StartTableFood"}  
        },
        tbUnLockEvent = 
        {
            {"SetShowTime", 708, nil, "宴席："},
            {"SetTargetInfo", "第4道佳餚：永結連理"}, 
        },
    },

    --宴席：第4道菜
    [708] = {nTime = 40, nNum = 0,
        tbPrelock = {707},
        tbStartEvent = 
        {
            --删除上一道菜
            {"DelNpc", "Marry1_TableFood_3"},

            {"AddNpc", 7, 1, nil, "Marry1_TableFood_4", "Marry1_TableFood_1", true, 0, nil, nil, nil},
            {"AddNpc", 7, 1, nil, "Marry1_TableFood_4", "Marry1_TableFood_2", true, 0, nil, nil, nil},
            {"AddNpc", 7, 1, nil, "Marry1_TableFood_4", "Marry1_TableFood_3", true, 0, nil, nil, nil},
            {"AddNpc", 7, 1, nil, "Marry1_TableFood_4", "Marry1_TableFood_4", true, 0, nil, nil, nil},
            {"RaiseEvent", "BlackMsgWithRole", "第4道佳餚：永結連理，祝[FFFE0D]「%s」[-]和[FFFE0D]「%s」[-]永結連理"},
            {"RaiseEvent", "StartTableFood"}  
        },
        tbUnLockEvent = 
        {
            {"SetShowTime", 709, nil, "宴席："},
            {"SetTargetInfo", "第5道佳餚：百年好合"}, 
        },
    },

    --宴席：第5道菜
    [709] = {nTime = 40, nNum = 0,
        tbPrelock = {708},
        tbStartEvent = 
        {
            --删除上一道菜
            {"DelNpc", "Marry1_TableFood_4"},

            {"AddNpc", 8, 1, nil, "Marry1_TableFood_5", "Marry1_TableFood_1", true, 0, nil, nil, nil},
            {"AddNpc", 8, 1, nil, "Marry1_TableFood_5", "Marry1_TableFood_2", true, 0, nil, nil, nil},
            {"AddNpc", 8, 1, nil, "Marry1_TableFood_5", "Marry1_TableFood_3", true, 0, nil, nil, nil},
            {"AddNpc", 8, 1, nil, "Marry1_TableFood_5", "Marry1_TableFood_4", true, 0, nil, nil, nil},
            {"RaiseEvent", "BlackMsgWithRole", "第5道佳餚：百年好合，祝[FFFE0D]「%s」[-]和[FFFE0D]「%s」[-]百年好合"},
            {"RaiseEvent", "StartTableFood"}  
        },
        tbUnLockEvent = 
        {
            {"RaiseEvent", "EndTableFood"},
            {"SetShowTime", 710, nil, "準備喜糖："},
            {"SetTargetInfo", "新人/月老準備派喜糖"}, 
        },
    },

    --派喜糖准备：10秒
    [710] = {nTime = 10, nNum = 0,
        tbPrelock = {709},
        tbStartEvent = 
        {   
            --删除最后一道菜
            {"DelNpc", "Marry1_TableFood_5"},
            --添加宴席空桌
            --{"AddFurnitureGroup", "zhuozi"},
            {"AddNpc", 10, 1, nil, "Marry1_Table", "Marry1_Table1", true, 0, nil, nil, nil},
            {"AddNpc", 10, 1, nil, "Marry1_Table", "Marry1_Table2", true, 0, nil, nil, nil},
            {"AddNpc", 10, 1, nil, "Marry1_Table", "Marry1_Table3", true, 0, nil, nil, nil},
            {"AddNpc", 10, 1, nil, "Marry1_Table", "Marry1_Table4", true, 0, nil, nil, nil},
        },
        tbUnLockEvent = 
        {
            {"SetShowTime", 711, nil, "派發喜糖："},
            {"SetTargetInfo", "甜甜蜜蜜，恩恩愛愛"}, 
        },
    },

    --派喜糖：5分钟
    [711] = {nTime = 5*60, nNum = 0,
        tbPrelock = {710},
        tbStartEvent = 
        {   
            --玩家付费派喜糖
            {"RaiseEvent", "StartCandy"},
            --月老派喜糖，阶段开始时派1次
            {"RaiseEvent", "ThrowCandy"},
        },
        tbUnLockEvent = 
        {
            {"RaiseEvent", "EndCandy"},
        },
    },

    --玩家自由活动时间
    [712] = {nTime = 1, nNum = 0,
        tbPrelock = {711},
        tbStartEvent = 
        {   
        },
        tbUnLockEvent = 
        {
            {"SetShowTime", 716, nil, "自由時間："},
            {"SetTargetInfo", "婚禮結束，拍照留念"}, 
        },
    },


    --放会儿烟花呗
    [713] = {nTime = 2, nNum = 0,
        tbPrelock = {712},
        tbStartEvent = 
        {   
            --五彩烟花
            {"RaiseEvent", "PlayWeddingFirework", 1},
        },
        tbUnLockEvent = 
        {
        },
    },

    --放会儿烟花呗
    [714] = {nTime = 2, nNum = 0,
        tbPrelock = {713},
        tbStartEvent = 
        {   
            --五彩烟花
            {"RaiseEvent", "PlayWeddingFirework", 1},
        },
        tbUnLockEvent = 
        {
        },
    },

    --放会儿烟花呗
    [715] = {nTime = 2, nNum = 0,
        tbPrelock = {714},
        tbStartEvent = 
        {   
            --五彩烟花
            {"RaiseEvent", "PlayWeddingFirework", 1},
        },
        tbUnLockEvent = 
        {
        },
    },


    --婚礼结束
    [716] = {nTime = 10*60, nNum = 0,
        tbPrelock = {712},
        tbStartEvent = 
        {   
            --婚礼结束，给新人发放礼金，这个时候新人可以手动离开副本
            {"RaiseEvent", "WeddingEnd"},
            --删除篝火
            {"DelNpc", "Marry_gouhuo"},
        },
        tbUnLockEvent = 
        {
            {"GameWin"},
        },
    },

    --最后一个阶段剩余2分钟的时候，同步一下副本时间
    [717] = {nTime = 8*60, nNum = 0,
        tbPrelock = {712},
        tbStartEvent = 
        {   
        },
        tbUnLockEvent = 
        {
            {"RaiseEvent", "SynEndTime"},
        },
    },

    --副本总时长：X分，强制结束副本
    --[150] = {nTime = 30*60, nNum = 0,
    --    tbPrelock = {1},
    --    tbStartEvent = 
    --    {
    --      
    --    },
    --    tbUnLockEvent = 
    --    {
    --        {"GameWin"},
    --    },
    --},
}