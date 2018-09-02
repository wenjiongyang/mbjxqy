local tbFubenSetting = {};
local nMapTemplateId = 5003

Fuben:SetFubenSetting(nMapTemplateId, tbFubenSetting)   -- 绑定副本内容和地图

tbFubenSetting.szNpcPointFile           = "Setting/Fuben/WeddingFuben_1/NpcPos.tab"         -- NPC点
tbFubenSetting.szPathFile               = "Setting/Fuben/WeddingFuben_1/NpcPath.tab"        -- 寻路点

tbFubenSetting.szFubenClass   = Wedding.szReplayFubenBase;                                  -- 副本类型
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

tbFubenSetting.NPC = 
{
    --花圈
    [11] = {nTemplate = 2654, nLevel = -1, nSeries = 0},
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
        },
        --tbStartEvent 锁解开时的事件
        tbUnLockEvent = 
        {            
        },
    },
    [2] = {nTime = 0, nNum = 0,
        tbPrelock = {1},
        tbStartEvent = 
        {
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
        },
        tbUnLockEvent = 
        {
            --片头字幕
            {"RaiseEvent", "OpenWeddingInterludePanel", "良時已到，婚禮開始"},
        },
    },
    [3] = {nTime = 8, nNum = 0,
        tbPrelock = {2},
        tbStartEvent = 
        {
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
            {"GameWin"},
        },
    },

    [716] = {nTime = 60, nNum = 0,
        tbPrelock = {1},
        tbStartEvent = 
        {   
        },
        tbUnLockEvent = 
        {
            {"GameWin"},
        },
    },
}