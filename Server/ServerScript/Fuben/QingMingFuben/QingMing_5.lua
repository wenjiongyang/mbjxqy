Require("CommonScript/Activity/QingMingActC.lua");
local tbAct = Activity:GetClass("QingMingAct")
local tbFubenSetting = {};
local nMapTemplateId = 1606

Fuben:SetFubenSetting(nMapTemplateId, tbFubenSetting)   -- 绑定副本内容和地图

tbFubenSetting.szNpcPointFile           = "Setting/Fuben/QingMingFuben/NpcPos.tab"         -- NPC点
tbFubenSetting.szPathFile               = "Setting/Fuben/QingMingFuben/NpcPath.tab"        -- 寻路点

tbFubenSetting.szFubenClass   = tbAct.szFubenClass;                                  -- 副本类型
tbFubenSetting.szName         = "清明節"                                             -- 单纯的名字，后台输出或统计使用
tbFubenSetting.tbBeginPoint   = {4030, 3670}  
tbFubenSetting.tbTempRevivePoint = {4030, 3670}  

-- 开始祭拜是需要解锁的锁id，填nil则无需解锁,前提是该锁是开始状态并且还没解锁
tbFubenSetting.nStartWorshipUnlockId = 4
-- 完成祭拜是需要解锁的锁id
tbFubenSetting.nFinishWorshipUnlockId = nil
-- 开始祭拜时玩家的坐标和方向
tbFubenSetting.tbWorshipInfo = {
    {tbPos = {4320, 3700}, nDir = 29},              -- 使用道具者
    {tbPos = {4020, 3400}, nDir = 15},             -- 协助者
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
    [1] = {nTemplate = 2257, nLevel = -1, nSeries = 0},  --纪念石碑
    [2] = {nTemplate = 2244, nLevel = -1, nSeries = 0},  --杨熙烈
    [3] = {nTemplate = 2254, nLevel = -1, nSeries = 0},  --杨影枫
    [4] = {nTemplate = 2276, nLevel = -1, nSeries = 0},  --纪念石碑（展示）
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
            --纪念石碑 
            {"AddNpc", 1, 1, 1, "ShiBei", "QingMing_5_ShiBei", false, 57},

            --纳兰真 
            {"AddNpc", 3, 1, 1, "Npc1", "QingMing_5_Npc1", false, 23, 0, 0, 0},

            {"OpenWindow", "LingJueFengLayerPanel", "Info", 3, 9, "心魔幻境 淩絕峰"},
            {"SetKickoutPlayerDealyTime", 20},
        },
        --tbStartEvent 锁解开时的事件
        tbUnLockEvent = 
        {            
        },
    },
    [2] = {nTime = 3, nNum = 0,
        tbPrelock = {1},
        tbStartEvent = 
        {
            
        },
        tbUnLockEvent = 
        {
            {"BlackMsg", "不遠處有一塊碑石，這是……淩絕峰？我怎麼會到了這裡？"},
            {"PlayerBubbleTalk", "楊少俠，這是怎麼回事？你怎會在這裡？"}
        },
    },
    [3] = {nTime = 3, nNum = 0,
        tbPrelock = {2},
        tbStartEvent = 
        {
        },
        tbUnLockEvent = 
        {
            {"BlackMsg", "前方的石碑上似乎有些文字，不妨去看看上面寫了什麼"},   
            {"SetFubenProgress", -1, "查看石碑"}, 
        },
    },
    [4] = {nTime = 0, nNum = 1,
        tbPrelock = {3},
        tbStartEvent = 
        {

        },
        tbUnLockEvent = 
        {
            --祭拜开始时解锁，刷出Npc纳兰潜凛
            {"AddNpc", 2, 1, 1, "Npc2", "QingMing_5_Npc2", false, 0, 0, 0, 0},

            {"BlackMsg", "前方忽然出現了一個虛幻的人影"},
            {"SetFubenProgress", -1, "聆聽兩人對話"}, 

            --Npc移动
            {"ChangeNpcAi", "Npc2", "Move", "QingMing_Path5", 5, 0, 0, 0},

            --设置Npc朝向
            {"SetNpcDir", "Npc1", 23}
        },
    },
    [5] = {nTime = 0, nNum = 1,
        tbPrelock = {4},
        tbStartEvent = 
        {
        },
        tbUnLockEvent = 
        {
            {"NpcBubbleTalk", "Npc2", "嗯？此地……是淩絕峰？哼，上官小兒！你在哪，給老子滾出來再大戰三百回合！", 4, 1, 1},

            {"NpcBubbleTalk", "Npc1", "爹爹…多年不見…想不到你風采依舊…仍是……咳咳，這般的豪氣干雲！", 4, 6, 1},

            {"NpcBubbleTalk", "Npc2", "你、你叫我什麼？爹爹？小子，你是哪塊石頭裡蹦出來的，我可沒你這麼大的兒子！", 4, 11, 1},

            {"NpcBubbleTalk", "Npc1", "咳咳，爹爹，距你與上官叔叔比武已過了十數年，說出來你可能不信，但你看這一招，喝！", 4, 16, 1},    

            {"NpcBubbleTalk", "Npc2", "這…這是我家傳劍法中的烈火晴天！原來如此，原來當年我確實死了，上官小兒呢？他如今怎麼樣了？", 4, 21, 1},

            {"NpcBubbleTalk", "Npc1", "爹爹，當年您與上官叔叔比武，兩敗俱傷，上官叔叔也死于重傷，而且，上官叔叔的妻子也跳崖自盡了……", 4, 26, 1}, 

            {"NpcBubbleTalk", "Npc2", "什麼！這……我不過想要與他比試一番，這……料不到竟會導致他家破人亡！實在不該！那、那個小女孩呢？", 4, 31, 1},

            {"NpcBubbleTalk", "Npc1", "您說的那個小女孩名叫月眉兒，如今是孩兒的紅顏知己，孩兒自當好生照料。", 4, 36, 1},  

            {"NpcBubbleTalk", "Npc2", "好！這般便好！楓兒，既是我理虧，你定要好好待她，決不可負她。對了，你武功如何，可成為天下第一了？", 4, 41, 1},

            {"NpcBubbleTalk", "Npc1", "唉，爹爹，事到如今，你還如此執著於天下第一這個名頭嗎？", 4, 46, 1},   

            {"NpcBubbleTalk", "Npc2", "廢話！為父窮盡一生精力，便是要攀上劍道高峰，成為天下第一人，你、你莫非忘記老子的訓導了？", 4, 51, 1},

            {"NpcBubbleTalk", "Npc1", "爹爹不必擔心，如今我也算得上是天下第一人，您的心願，孩兒已經替你完成了", 4, 56, 1},  

            {"NpcBubbleTalk", "Npc2", "很好，哈哈哈，既奪得天下第一，又贏得美人芳心，有子如此，為父深感欣慰！哈哈哈！你去吧！老子可以安息了！", 4, 61, 1},
        },
    },       
    [6] = {nTime = 65, nNum = 0,
        tbPrelock = {5},
        tbStartEvent = 
        {

        },
        tbUnLockEvent = 
        {
            {"NpcBubbleTalk", "Npc1", "唉，爹。保重。", 4, 63, 1},
            {"SetFubenProgress", -1, "離開幻境"}, 
            {"BlackMsg", "現在可以離開了！"},
            {"GameWin"},
            --纪念石碑 
            {"AddSimpleNpc", 2276, 4580, 3150, 57}, 

            --纳兰真 
            {"AddSimpleNpc", 2254, 4300, 3400, 23}, 
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