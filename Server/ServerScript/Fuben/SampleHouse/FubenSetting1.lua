local tbFubenSetting = {};
Fuben:SetFubenSetting(4006, tbFubenSetting)      -- 绑定副本内容和地图

tbFubenSetting.szFubenClass     = "SampleHouseFuben";                                 -- 副本类型
tbFubenSetting.szName           = "樣板房"                                            -- 单纯的名字，后台输出或统计使用
tbFubenSetting.szNpcPointFile   = "Setting/Fuben/SampleHouse/NpcPos.tab"              -- NPC点
tbFubenSetting.szPathFile       = "Setting/Fuben/SampleHouse/NpcPath.tab"             -- 寻路点
tbFubenSetting.tbBeginPoint     = {2322, 18120}                                        -- 副本出生点

-- ID可以随便 普通副本NPC数量 ；精英模式NPC数量
tbFubenSetting.NUM = 
{
}

tbFubenSetting.NPC = 
{
    [1] = {nTemplate = 2330, nLevel = -1, nSeries = -1},  --林更新
    [2] = {nTemplate = 2331, nLevel = -1, nSeries = -1},  --赵丽颖
}

-- 文字内容集
tbFubenSetting.TEXT_CONTNET =
{
    LinGengXin_Talk = 
    {
        [1] = "我有酒，你有故事麼？",
        [2] = "常年在外，方知家的溫暖。",
        [3] = "如若可以，我想與她簡簡單單的過著平淡的生活。",
        [4] = "來，少俠與我暢飲一杯~",
        [5] = "夜月一簾幽夢，春風十裡柔情。",
        [6] = "歡迎到訪寒舍做客~",
    },

    ZhaoLiYing_Talk = 
    {
        [1] = "歡迎到訪寒舍做客~",
        [2] = "原本都是一粒沙，被人寵愛，所以才變得珍貴，歲月打磨，終成珍珠。",
        [3] = "只求與他相廝守……",
        [4] = "青山遮不住，大江東流去，識時務者方為俊傑。",
        [5] = "深深夜色柳月中，愛若輕歌吟朦朧。",
    },
}


tbFubenSetting.LOCK = 
{
    -- 1号锁不能不填，默认1号为起始锁，nTime是到时间自动解锁，nNum表示需要解锁的次数，如填3表示需要被解锁3次才算真正解锁，可以配置字符串
    [1] = {nTime = 1, nNum = 0,
        --tbPrelock 前置锁，激活锁的必要条件{1 , 2, {3, 4}}，代表1和2号必须解锁，3和4任意解锁一个即可
        tbPrelock = {},
        --tbStartEvent 锁激活时的事件
        tbStartEvent = 
        {
        },
        --tbStartEvent 锁解开时的事件
        tbUnLockEvent = 
        {
        },
    },
    [2] = {nTime = 0, nNum = 1,
        tbPrelock = {1},
        tbStartEvent = 
        {    
            --林更新
            { "AddNpc", 1, 1, nil, "LinGengXin", "LinGengXinBornPos" },
            {"RaiseEvent", "StartMultiPathMove", "LinGengXin", { {"LinGengXin_Path1", 10}, { "LinGengXin_Path2", 10 }, { "LinGengXin_Path3", 20 }, { "LinGengXin_Path4", 30 }, { "LinGengXin_Path5", 0 } }, true},
            { "StartTimeCycle", "LinGengXin_Talk", 15, nil, {"NpcRandomTalk", "LinGengXin", "LinGengXin_Talk", 6, 0}, },

            --赵丽颖
            { "AddNpc", 2, 1, nil, "ZhaoLiYing", "ZhaoLiYingBornPos", nil, 49 },
            { "StartTimeCycle", "ZhaoLiYing_Talk", 22, nil, {"NpcRandomTalk", "ZhaoLiYing", "ZhaoLiYing_Talk", 6, 0}, },
        },
        tbUnLockEvent = 
        {
        },
    },
}