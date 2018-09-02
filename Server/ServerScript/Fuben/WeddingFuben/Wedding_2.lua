local tbFubenSetting = {};
local nMapTemplateId = 5001

Fuben:SetFubenSetting(nMapTemplateId, tbFubenSetting)   -- 绑定副本内容和地图

tbFubenSetting.szNpcPointFile           = "Setting/Fuben/WeddingFuben_2/NpcPos.tab"         -- NPC点
tbFubenSetting.szPathFile               = "Setting/Fuben/WeddingFuben_2/NpcPath.tab"        -- 寻路点

tbFubenSetting.szFubenClass   = Wedding.szFubenBase;                                  -- 副本类型
tbFubenSetting.szName         = "海島·紅鸞攬月"                                             -- 单纯的名字，后台输出或统计使用
tbFubenSetting.tbBeginPoint   = {2998, 6013}  --出生点
tbFubenSetting.tbTempRevivePoint = {2998, 6013}  --复活点

-- ID可以随便 普通副本NPC数量 ；精英模式NPC数量
tbFubenSetting.NUM = 
{
    
}

tbFubenSetting.ANIMATION = 
{
    [1] = "Scenes/camera/jiehun/jiehun_zhongji_cam.controller",   --拜堂镜头
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
    [4] = {nTemplate = 2542, nLevel = -1, nSeries = 0},
    --第2道菜
    [5] = {nTemplate = 2543, nLevel = -1, nSeries = 0},
    --第3道菜
    [6] = {nTemplate = 2544, nLevel = -1, nSeries = 0},
    --第4道菜
    [7] = {nTemplate = 2545, nLevel = -1, nSeries = 0},
    --第5道菜
    [8] = {nTemplate = 2546, nLevel = -1, nSeries = 0},
    --篝火
    [9] = {nTemplate = 2629, nLevel = -1, nSeries = 0},
    --空的桌子
    [10] = {nTemplate = 2557, nLevel = -1, nSeries = 0},
    --吹唢呐
    [11] = {nTemplate = 2375, nLevel = -1, nSeries = 0},
    --花圈
    [12] = {nTemplate = 2654, nLevel = -1, nSeries = 0},
}

-- 婚礼现场的家具
tbFubenSetting.FurnitureItem = 
{
    --宴席凳子-左
    [10] = {nTemplate = 10024, nPosX = 3721, nPosY = 6703, nRotation = 180, bNotSync = nil};
    [11] = {nTemplate = 10024, nPosX = 4470, nPosY = 6653, nRotation = 180, bNotSync = nil};
    [12] = {nTemplate = 10024, nPosX = 3139, nPosY = 5332, nRotation = 180, bNotSync = nil};
    [13] = {nTemplate = 10024, nPosX = 3837, nPosY = 5390, nRotation = 180, bNotSync = nil};
    [14] = {nTemplate = 10024, nPosX = 3111, nPosY = 6649, nRotation = 180, bNotSync = nil};
    [15] = {nTemplate = 10024, nPosX = 4462, nPosY = 5393, nRotation = 180, bNotSync = nil};

    --宴席凳子-右
    [20] = {nTemplate = 10024, nPosX = 3431, nPosY = 6644, nRotation = 0, bNotSync = nil};
    [21] = {nTemplate = 10024, nPosX = 4051, nPosY = 6707, nRotation = 0, bNotSync = nil};
    [22] = {nTemplate = 10024, nPosX = 4807, nPosY = 6651, nRotation = 0, bNotSync = nil};
    [23] = {nTemplate = 10024, nPosX = 3459, nPosY = 5334, nRotation = 0, bNotSync = nil};
    [24] = {nTemplate = 10024, nPosX = 4171, nPosY = 5388, nRotation = 0, bNotSync = nil};
    [25] = {nTemplate = 10024, nPosX = 4803, nPosY = 5386, nRotation = 0, bNotSync = nil};

    --宴席凳子-上
    [30] = {nTemplate = 10024, nPosX = 3275, nPosY = 6829, nRotation = 270, bNotSync = nil};
    [31] = {nTemplate = 10024, nPosX = 3884, nPosY = 6856, nRotation = 270, bNotSync = nil};
    [32] = {nTemplate = 10024, nPosX = 4639, nPosY = 6815, nRotation = 270, bNotSync = nil};
    [33] = {nTemplate = 10024, nPosX = 3291, nPosY = 5501, nRotation = 270, bNotSync = nil};
    [34] = {nTemplate = 10024, nPosX = 4004, nPosY = 5561, nRotation = 270, bNotSync = nil};
    [35] = {nTemplate = 10024, nPosX = 4619, nPosY = 5551, nRotation = 270, bNotSync = nil};

    --宴席凳子-下
    [40] = {nTemplate = 10024, nPosX = 3279, nPosY = 6492, nRotation = 90, bNotSync = nil};
    [41] = {nTemplate = 10024, nPosX = 3891, nPosY = 6524, nRotation = 90, bNotSync = nil};
    [42] = {nTemplate = 10024, nPosX = 4643, nPosY = 6488, nRotation = 90, bNotSync = nil};
    [43] = {nTemplate = 10024, nPosX = 3303, nPosY = 5167, nRotation = 90, bNotSync = nil};
    [44] = {nTemplate = 10024, nPosX = 4004, nPosY = 5229, nRotation = 90, bNotSync = nil};
    [45] = {nTemplate = 10024, nPosX = 4619, nPosY = 5222, nRotation = 90, bNotSync = nil};

    --观众席椅子
    [50] = {nTemplate = 1518, nPosX = 5783, nPosY = 6595, nRotation = 0, bNotSync = nil};
    [51] = {nTemplate = 1518, nPosX = 5782, nPosY = 6790, nRotation = 0, bNotSync = nil};
    [52] = {nTemplate = 1518, nPosX = 5784, nPosY = 6986, nRotation = 0, bNotSync = nil};
    [53] = {nTemplate = 1518, nPosX = 6091, nPosY = 6595, nRotation = 0, bNotSync = nil};
    [54] = {nTemplate = 1518, nPosX = 6090, nPosY = 6791, nRotation = 0, bNotSync = nil};
    [55] = {nTemplate = 1518, nPosX = 6092, nPosY = 6986, nRotation = 0, bNotSync = nil};
    [56] = {nTemplate = 1518, nPosX = 5864, nPosY = 5557, nRotation = 0, bNotSync = nil};
    [57] = {nTemplate = 1518, nPosX = 6203, nPosY = 5557, nRotation = 0, bNotSync = nil};
    [58] = {nTemplate = 1518, nPosX = 5865, nPosY = 5359, nRotation = 0, bNotSync = nil};
    [59] = {nTemplate = 1518, nPosX = 5863, nPosY = 5164, nRotation = 0, bNotSync = nil};
    [60] = {nTemplate = 1518, nPosX = 6203, nPosY = 5361, nRotation = 0, bNotSync = nil};
    [61] = {nTemplate = 1518, nPosX = 6202, nPosY = 5166, nRotation = 0, bNotSync = nil};
    --证婚席
    [80] = {nTemplate = 10027, nPosX = 6566, nPosY = 6398, nRotation = 270, bNotSync = nil};
    [81] = {nTemplate = 10027, nPosX = 6818, nPosY = 6398, nRotation = 270, bNotSync = nil};
    [82] = {nTemplate = 10027, nPosX = 6818, nPosY = 5670, nRotation = 90, bNotSync = nil};
    [83] = {nTemplate = 10027, nPosX = 6594, nPosY = 5670, nRotation = 90, bNotSync = nil};
}

tbFubenSetting.FurnitureItemGroup = 
{
    --宴席凳子-左
    ["dengzi_l"] = {10,11,12,13,14,15};
    --宴席凳子-右
    ["dengzi_r"] = {20,21,22,23,24,25};
    --宴席凳子-上
    ["dengzi_t"] = {30,31,32,33,34,35};
    --宴席凳子-下
    ["dengzi_b"] = {40,41,42,43,44,45};
    --观众席椅子
    ["yizi"] = {50,51,52,53,54,55,56,57,58,59,60,61};
    --证婚席
    ["zh_yizi_1"] = {80,81,82,83};
}

tbFubenSetting.tbEndMarryCeremonyPos = {{6763,6116}, {6761,5920}}             -- 结束拜堂之后主角传送的位置
tbFubenSetting.tbStartMarryCeremonyPos = {{5074,6029}}                         -- 开始拜堂之后主角传送的位置（用于宾客同步）
tbFubenSetting.tbStartMarryCeremonyPlayerPos =                                  -- 开始拜堂宾客的聚集地
{
    {5102,5447};
    {5248,5452};
    {4978,6553};
    {5065,6600};
    {5218,6601};
    {4964,6409};
    {5387,6477};
    {5392,6548};
    {5326,6600};
    {5117,6373};
    {5196,6457};
    {5276,6377};
    {5387,6368};
    {5289,6486};
    {5148,6526};
    {5069,6453};
    {5169,5662};
    {5305,5672};
    {5241,5590};
    {5084,5587};
    {5161,5530};
    {5326,5542};
    {5395,5651};
    {5417,5558};
    {5404,5456};
    {4961,5587};
    {5016,5668};
    {4997,5474};
}

-- 喜糖位置
tbFubenSetting.tbCandyPos = {
    {5925,6018},
    {4786,6254},
    {4544,6052},
    {6662,6413},
    {5464,6259},
    {5445,6023},
    {5395,5793},
    {5649,6042},
    {5158,5830},
    {4563,5880},
    {6363,6232},
    {6904,5650},
    {6690,5639},
    {5148,6482},
    {5050,6655},
    {5224,6803},
    {5433,6559},
    {5074,5430},
    {5205,5221},
    {5378,5533},
    {5486,5351},
    {6898,6377},
    {4843,5844},
    {4900,6035},
    {5163,6174},
    {6304,5918},
    {6479,6262},
}
-- 跳过迎宾之后需要解锁的锁id
tbFubenSetting.nCancelWelcomeUnlockId = 502
-- 开始婚礼之后需要解锁的锁id
tbFubenSetting.nStartWeddingUnlockId = 503
-- 宣誓结束之后需要解锁的锁id
tbFubenSetting.nEndPromiseUnlockId = 506
-- 同心果结束之后需要解锁的锁id
tbFubenSetting.nEndConcentricFruitUnlockId = 802
-- 证婚人相关
tbFubenSetting.tbWitnessInfo = 
{
    tbPos = {{6550,6327},{6803,6338},{6579,5730},{6804,5727}};
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
            {"AddNpc", 10, 1, nil, "Marry1_Table", "Marry1_Table5", true, 0, nil, nil, nil},
            {"AddNpc", 10, 1, nil, "Marry1_Table", "Marry1_Table6", true, 0, nil, nil, nil},

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
            {"AddNpc", 12, 1, nil, "huaquan", "Marry1_huaquan1", true, 0, nil, nil, nil},
            {"AddNpc", 12, 1, nil, "huaquan", "Marry1_huaquan2", true, 0, nil, nil, nil},
            {"AddNpc", 12, 1, nil, "huaquan", "Marry1_huaquan3", true, 0, nil, nil, nil},
            {"AddNpc", 12, 1, nil, "huaquan", "Marry1_huaquan4", true, 0, nil, nil, nil},
            {"AddNpc", 12, 1, nil, "huaquan", "Marry1_huaquan5", true, 0, nil, nil, nil},
            {"AddNpc", 12, 1, nil, "huaquan", "Marry1_huaquan6", true, 0, nil, nil, nil},
            {"AddNpc", 12, 1, nil, "huaquan", "Marry1_huaquan7", true, 0, nil, nil, nil},
            {"AddNpc", 12, 1, nil, "huaquan", "Marry1_huaquan8", true, 0, nil, nil, nil},
            {"AddNpc", 12, 1, nil, "huaquan", "Marry1_huaquan9", true, 0, nil, nil, nil},
            {"AddNpc", 12, 1, nil, "huaquan", "Marry1_huaquan10", true, 0, nil, nil, nil},
            {"AddNpc", 12, 1, nil, "huaquan", "Marry1_huaquan11", true, 0, nil, nil, nil},
            {"AddNpc", 12, 1, nil, "huaquan", "Marry1_huaquan12", true, 0, nil, nil, nil},
            {"AddNpc", 12, 1, nil, "huaquan", "Marry1_huaquan13", true, 0, nil, nil, nil},
            {"AddNpc", 12, 1, nil, "huaquan", "Marry1_huaquan14", true, 0, nil, nil, nil},
            {"AddNpc", 12, 1, nil, "huaquan", "Marry1_huaquan15", true, 0, nil, nil, nil},
            {"AddNpc", 12, 1, nil, "huaquan", "Marry1_huaquan16", true, 0, nil, nil, nil},
            --添加花童左
            {"AddNpc", 1, 1, nil, "huatong_L", "Wedding_1_L_huatong1", true, 30, nil, nil, nil},
            {"AddNpc", 1, 1, nil, "huatong_L", "Wedding_1_L_huatong2", true, 30, nil, nil, nil},
            {"AddNpc", 1, 1, nil, "huatong_L", "Wedding_1_L_huatong3", true, 30, nil, nil, nil},
            {"AddNpc", 1, 1, nil, "huatong_L", "Wedding_1_L_huatong4", true, 30, nil, nil, nil},
            {"AddNpc", 1, 1, nil, "huatong_L", "Wedding_1_L_huatong5", true, 30, nil, nil, nil},
            {"AddNpc", 1, 1, nil, "huatong_L", "Wedding_1_L_huatong6", true, 30, nil, nil, nil},
            --添加花童右
            {"AddNpc", 1, 1, nil, "huatong_R", "Wedding_1_R_huatong1", true, 0, nil, nil, nil},
            {"AddNpc", 1, 1, nil, "huatong_R", "Wedding_1_R_huatong2", true, 0, nil, nil, nil},
            {"AddNpc", 1, 1, nil, "huatong_R", "Wedding_1_R_huatong3", true, 0, nil, nil, nil},
            {"AddNpc", 1, 1, nil, "huatong_R", "Wedding_1_R_huatong4", true, 0, nil, nil, nil},
            {"AddNpc", 1, 1, nil, "huatong_R", "Wedding_1_R_huatong5", true, 0, nil, nil, nil},
            {"AddNpc", 1, 1, nil, "huatong_R", "Wedding_1_R_huatong6", true, 0, nil, nil, nil},
            --添加主台花童
            {"AddNpc", 1, 1, nil, "huatong_z", "Wedding_1_Z_huatong1", true, 47, nil, nil, nil},
            {"AddNpc", 1, 1, nil, "huatong_z", "Wedding_1_Z_huatong2", true, 47, nil, nil, nil},
            --添加月老
            {"AddNpc", 2, 1, nil, "yuelao", "Wedding_yuelao", true, 47, nil, nil, nil},
            --添加婚礼商人
            {"AddNpc", 3, 1, nil, "huatong_Shop", "Wedding_Shop", true, 14, nil, nil, nil},
            --添加篝火
            {"AddNpc", 9, 1, nil, "Marry_gouhuo", "Marry_gouhuo", true, 0, nil, nil, nil},
            --添加吹唢呐左
            {"AddNpc", 11, 1, nil, "chuisuona_L", "Wedding_1_L_chuisuona1", true, 30, nil, nil, nil},
            {"AddNpc", 11, 1, nil, "chuisuona_L", "Wedding_1_L_chuisuona2", true, 30, nil, nil, nil},
            --添加吹唢呐右
            {"AddNpc", 11, 1, nil, "chuisuona_R", "Wedding_1_R_chuisuona1", true, 0, nil, nil, nil},
            {"AddNpc", 11, 1, nil, "chuisuona_R", "Wedding_1_R_chuisuona2", true, 0, nil, nil, nil},

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
            {"RaiseEvent", "SendKinNotice", "[FFFE0D]「%s」[-]和[FFFE0D]「%s」[-]舉行的[FFFE0D]海島·紅鸞攬月[-]婚禮即將開始，各位俠士可前往[FFFE0D]襄陽城月老[-]處申請進入"},
            {"RaiseEvent", "SendWorldNotice", "[FFFE0D]「%s」[-]和[FFFE0D]「%s」[-]舉行的[FFFE0D]海島·紅鸞攬月[-]婚禮即將開始，各位俠士可前往[FFFE0D]襄陽城月老[-]處申請進入"},
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
            {"RaiseEvent", "PlayWeddingFirework", 10},
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
            {"RaiseEvent", "PlayWeddingFirework", 10},
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
            {"RaiseEvent", "PlayWeddingFirework", 11},
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
            {"DelNpc", "chuisuona_L"},
            {"DelNpc", "chuisuona_R"},
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
            {"AddNpc", 10, 1, nil, "Marry1_Table", "Marry1_Table5", true, 0, nil, nil, nil},
            {"AddNpc", 10, 1, nil, "Marry1_Table", "Marry1_Table6", true, 0, nil, nil, nil},

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
            {"AddNpc", 1, 1, nil, "huatong_L", "Wedding_1_L_huatong5", true, 30, nil, nil, nil},
            {"AddNpc", 1, 1, nil, "huatong_L", "Wedding_1_L_huatong6", true, 30, nil, nil, nil},
            --添加花童右
            {"AddNpc", 1, 1, nil, "huatong_R", "Wedding_1_R_huatong1", true, 0, nil, nil, nil},
            {"AddNpc", 1, 1, nil, "huatong_R", "Wedding_1_R_huatong2", true, 0, nil, nil, nil},
            {"AddNpc", 1, 1, nil, "huatong_R", "Wedding_1_R_huatong3", true, 0, nil, nil, nil},
            {"AddNpc", 1, 1, nil, "huatong_R", "Wedding_1_R_huatong4", true, 0, nil, nil, nil},
            {"AddNpc", 1, 1, nil, "huatong_R", "Wedding_1_R_huatong5", true, 0, nil, nil, nil},
            {"AddNpc", 1, 1, nil, "huatong_R", "Wedding_1_R_huatong6", true, 0, nil, nil, nil},
            --添加主台花童
            {"AddNpc", 1, 1, nil, "huatong_z", "Wedding_1_Z_huatong1", true, 47, nil, nil, nil},
            {"AddNpc", 1, 1, nil, "huatong_z", "Wedding_1_Z_huatong2", true, 47, nil, nil, nil},
            --添加月老
            {"AddNpc", 2, 1, nil, "yuelao", "Wedding_yuelao", true, 47, nil, nil, nil},
            --添加婚礼商人
            {"AddNpc", 3, 1, nil, "huatong_Shop", "Wedding_Shop", true, 14, nil, nil, nil},
            --添加吹唢呐左
            {"AddNpc", 11, 1, nil, "chuisuona_L", "Wedding_1_L_chuisuona1", true, 30, nil, nil, nil},
            {"AddNpc", 11, 1, nil, "chuisuona_L", "Wedding_1_L_chuisuona2", true, 30, nil, nil, nil},
            --添加吹唢呐右
            {"AddNpc", 11, 1, nil, "chuisuona_R", "Wedding_1_R_chuisuona1", true, 0, nil, nil, nil},
            {"AddNpc", 11, 1, nil, "chuisuona_R", "Wedding_1_R_chuisuona2", true, 0, nil, nil, nil},
        },
    },

    [103] = {nTime = 2, nNum = 0,
        tbPrelock = {102},
        tbStartEvent = 
        {
            --五彩烟花
            {"RaiseEvent", "PlayWeddingFirework", 10},
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
            {"RaiseEvent", "PlayWeddingFirework", 10},
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
            {"RaiseEvent", "PlayWeddingFirework", 11},
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
            {"RaiseEvent", "PlayWeddingFirework", 10},

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
            {"RaiseEvent", "AddFirecracker", 6715,6022},
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
            {"RaiseEvent", "PlayWeddingFirework", 10},
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
            {"RaiseEvent", "PlayWeddingFirework", 10},
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
            {"RaiseEvent", "PlayWeddingFirework", 11},
        },
        tbUnLockEvent = 
        {
            {"SetShowTime", 800, nil, "同心果準備中："},
            {"SetTargetInfo", "夫妻同心，同食同心果"},
        },
    },

    --同心果准备：10秒
    [800] = {nTime = 10, nNum = 0,
        tbPrelock = {703},
        tbStartEvent = 
        {
        },
        tbUnLockEvent = 
        {
            {"SetShowTime", 801, nil, "同食同心果："},
            {"SetTargetInfo", "夫妻1秒內同食同心果"},
        },
    },

    --同心果：2分钟
    [801] = {nTime = 2*60, nNum = 0,
        tbPrelock = {800},
        tbStartEvent = 
        {
            {"RaiseEvent", "AddConcentricFruit", 6715,6022} 
        },
        tbUnLockEvent = 
        {
            {"RaiseEvent", "EndConcentricFruit"}
        },
    },

    --前缀锁，不做任何事情，用来玩家提前完成同心果后跳过阶段
    [802] = {nTime = 0, nNum = 1,
        tbPrelock = {1},
        tbStartEvent = 
        {

        },
        tbUnLockEvent = 
        {

        },
    },

    [803] = {nTime = 3, nNum = 0,
        tbPrelock = {802},
        tbStartEvent = 
        {
            --心心相印烟花
            {"RaiseEvent", "PlayWeddingFirework", 12},
        },
        tbUnLockEvent = 
        {
        },
    },

    [804] = {nTime = 3, nNum = 0,
        tbPrelock = {803},
        tbStartEvent = 
        {
            --心心相印烟花
            {"RaiseEvent", "PlayWeddingFirework", 12},
        },
        tbUnLockEvent = 
        {
        },
    },

    [805] = {nTime = 2, nNum = 0,
        tbPrelock = {804},
        tbStartEvent = 
        {
            --五彩烟花
            {"RaiseEvent", "PlayWeddingFirework", 10},
        },
        tbUnLockEvent = 
        {
            {"SetShowTime", 704, nil, "宴席準備："},
            {"SetTargetInfo", "佳餚美食，等待開席"},
        },
    },

    --宴席准备：10秒
    [704] = {nTime = 10, nNum = 0,
        tbPrelock = {805},
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
            {"AddNpc", 4, 1, nil, "Marry1_TableFood_1", "Marry1_TableFood_5", true, 0, nil, nil, nil},
            {"AddNpc", 4, 1, nil, "Marry1_TableFood_1", "Marry1_TableFood_6", true, 0, nil, nil, nil},
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
            {"AddNpc", 5, 1, nil, "Marry1_TableFood_2", "Marry1_TableFood_5", true, 0, nil, nil, nil},
            {"AddNpc", 5, 1, nil, "Marry1_TableFood_2", "Marry1_TableFood_6", true, 0, nil, nil, nil},
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
            {"AddNpc", 6, 1, nil, "Marry1_TableFood_3", "Marry1_TableFood_5", true, 0, nil, nil, nil},
            {"AddNpc", 6, 1, nil, "Marry1_TableFood_3", "Marry1_TableFood_6", true, 0, nil, nil, nil},
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
            {"AddNpc", 7, 1, nil, "Marry1_TableFood_4", "Marry1_TableFood_5", true, 0, nil, nil, nil},
            {"AddNpc", 7, 1, nil, "Marry1_TableFood_4", "Marry1_TableFood_6", true, 0, nil, nil, nil},
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
            {"AddNpc", 8, 1, nil, "Marry1_TableFood_5", "Marry1_TableFood_5", true, 0, nil, nil, nil},
            {"AddNpc", 8, 1, nil, "Marry1_TableFood_5", "Marry1_TableFood_6", true, 0, nil, nil, nil},
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
            {"AddNpc", 10, 1, nil, "Marry1_Table", "Marry1_Table5", true, 0, nil, nil, nil},
            {"AddNpc", 10, 1, nil, "Marry1_Table", "Marry1_Table6", true, 0, nil, nil, nil},

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
            {"RaiseEvent", "PlayWeddingFirework", 10},
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
            {"RaiseEvent", "PlayWeddingFirework", 10},
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
            {"RaiseEvent", "PlayWeddingFirework", 10},
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