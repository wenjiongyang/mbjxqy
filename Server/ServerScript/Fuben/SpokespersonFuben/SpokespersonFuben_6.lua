Require("ServerScript/Fuben/SpokespersonFuben/ActivityFubenBase.lua")
local tbFubenSetting = Fuben.ActivityFuben:GetFubenSetting("SpokespersonFuben_6")
local nMapTemplateId = 1623
Fuben:SetFubenSetting(nMapTemplateId, tbFubenSetting)   -- 绑定副本内容和地图

tbFubenSetting.szNpcPointFile           = "Setting/Fuben/SpokespersonFuben/NpcPos.tab"         -- NPC点
tbFubenSetting.szPathFile               = "Setting/Fuben/SpokespersonFuben/NpcPath.tab"        -- 寻路点

tbFubenSetting.szName         = "心魔幻境"                                             -- 单纯的名字，后台输出或统计使用
tbFubenSetting.tbBeginPoint   = {6616, 6666}  
tbFubenSetting.tbTempRevivePoint = {6616, 6666}  


-- 开始祭拜是需要解锁的锁id，填nil则无需解锁,前提是该锁是开始状态并且还没解锁
tbFubenSetting.nStartWorshipUnlockId = 5
-- 完成祭拜是需要解锁的锁id
tbFubenSetting.nFinishWorshipUnlockId = nil
-- 开始祭拜时玩家的坐标和方向
tbFubenSetting.tbWorshipInfo = {
    {tbPos = {4650, 5100}, nDir = 13},              -- 使用道具者
    {tbPos = {4735, 4950}, nDir = 7},             -- 协助者
}

-- ID可以随便 普通副本NPC数量 ；精英模式NPC数量
tbFubenSetting.NUM = 
{
    
}

tbFubenSetting.ANIMATION = 
{
   
}

--NPC模版ID，NPC等级，NPC五行；
--[[

]]

tbFubenSetting.NPC = 
{
    [1] = {nTemplate = 2323, nLevel = -1, nSeries = 0},  --树
    [2] = {nTemplate = 2307, nLevel = -1, nSeries = 0},  --赵丽颖
    [3] = {nTemplate = 2308, nLevel = -1, nSeries = 0},  --林更新
    [4] = {nTemplate = 2322, nLevel = -1, nSeries = 0},  --树（展示）
}

tbFubenSetting.LOCK = 
{
    -- 1号锁不能不填，默认1号为起始锁，nTime是到时间自动解锁，nNum表示需要解锁的次数，如填3表示需要被解锁3次才算真正解锁，可以配置字符串
    [1] = {nTime = 5, nNum = 0,
        --tbPrelock 前置锁，激活锁的必要条件{1 , 2, {3, 4}}，代表1和2号必须解锁，3和4任意解锁一个即可
        tbPrelock = {},
        --tbStartEvent 锁激活时的事件
        tbStartEvent = 
        {
            --树 
            {"AddNpc", 4, 1, 1, "Shu1", "Shu", false, 0, 0, 0, 0},

            --赵丽颖 
            {"AddNpc", 2, 1, 1, "Npc1", "Fuben_6_Npc1_1", false, 41, 0, 0, 0},

            --林更新 
            {"AddNpc", 3, 1, 1, "Npc2", "Fuben_6_Npc2_1", false, 39, 0, 0, 0},
            
            {"SetKickoutPlayerDealyTime", 20},
        },
        --tbStartEvent 锁解开时的事件
        tbUnLockEvent = 
        { 

        },
    },
    [2] = {nTime = 0, nNum = 2,
        tbPrelock = {1},
        tbStartEvent = 
        {
            {"OpenWindow", "LingJueFengLayerPanel", "Info", 3, 9, "新穎小院"},

            {"OpenWindowAutoClose", "QingRenJieDazuoPanel"},

            {"PlayerBubbleTalk", "我們真沒來錯地方，此處真是人間仙境"},

            --说话
            {"NpcBubbleTalk", "Npc1", "來吧，莫要在這兒站著了，跟我來", 4, 1, 1},
            {"NpcBubbleTalk", "Npc2", "前面有一處地方，保證你們更是喜歡", 4, 3, 1},

            --移动
            {"ChangeNpcAi", "Npc1", "Move", "Fuben_6_Npc1_Move_1", 2, 1, 1, 0, 0},
            {"ChangeNpcAi", "Npc2", "Move", "Fuben_6_Npc2_Move_1", 2, 1, 1, 0, 0},           
        },
        tbUnLockEvent = 
        {

        },
    },
    [3] = {nTime = 10, nNum = 0,
        tbPrelock = {2},
        tbStartEvent = 
        {

        },
        tbUnLockEvent = 
        {
            --说话
            {"NpcBubbleTalk", "Npc1", "此處風景優美，又有美酒相伴，何不小酌一番", 4, 1, 1},
            {"NpcBubbleTalk", "Npc2", "正是，我們不當電燈泡啦！你們經許多劫難，好好聚聚！", 4, 3, 1},

            --移动
            {"ChangeNpcAi", "Npc1", "Move", "Fuben_6_Npc1_Move_2", 3, 1, 1, 1, 0},
            {"ChangeNpcAi", "Npc2", "Move", "Fuben_6_Npc2_Move_2", 3, 1, 1, 1, 0},

            {"BlackMsg", "或許應當好好賞花飲酒，共用此刻"},   
            
            {"SetFubenProgress", -1, "查看花樹"}, 
        },
    },
    [4] = {nTime = 2, nNum = 0,
        tbPrelock = {3},
        tbStartEvent = 
        {


        },
        tbUnLockEvent = 
        {
            --树 
            {"AddNpc", 1, 1, 1, "Shu2", "Shu", false, 0, 0, 0, 0},
        },
    },
    [5] = {nTime = 0, nNum = 1,
        tbPrelock = {4},
        tbStartEvent = 
        {
            {"BlackMsg", "如此良辰美景，兩人獨處，何不暢談一番？"},  
        },
        tbUnLockEvent = 
        {

            {"SetFubenProgress", -1, "賞花談心"}, 
        },
    },       
    [6] = {nTime =  55, nNum = 0,
        tbPrelock = {5},
        tbStartEvent = 
        {

        },
        tbUnLockEvent = 
        {
            {"SetFubenProgress", -1, "離開此處"}, 
            {"BlackMsg", "現在可以離開了！"},
            {"GameWin"},

            --纳兰真 
            {"AddSimpleNpc", 2322, 5040, 5300, 0}, 
        },
    },
    [100] = {nTime = 600, nNum = 0,
        tbPrelock = {1},
        tbStartEvent = 
        {
            {"SetShowTime", 100},
            --{"SetFubenProgress", -1, "即将离开"}, 
        },
        tbUnLockEvent = 
        {
            {"GameLost"},
        },
    },
}