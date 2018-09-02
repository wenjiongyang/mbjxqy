Require("CommonScript/Activity/QingMingActC.lua");
local tbAct = Activity:GetClass("QingMingAct")
local tbFubenSetting = {};
local nMapTemplateId = 1604

Fuben:SetFubenSetting(nMapTemplateId, tbFubenSetting)   -- 绑定副本内容和地图

tbFubenSetting.szNpcPointFile           = "Setting/Fuben/QingMingFuben/NpcPos.tab"         -- NPC点
tbFubenSetting.szPathFile               = "Setting/Fuben/QingMingFuben/NpcPath.tab"        -- 寻路点

tbFubenSetting.szFubenClass   = tbAct.szFubenClass;                                  -- 副本类型
tbFubenSetting.szName         = "清明節"                                             -- 单纯的名字，后台输出或统计使用
tbFubenSetting.tbBeginPoint   = {4000, 3700}  
tbFubenSetting.tbTempRevivePoint = {4000, 3700}  

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
    [2] = {nTemplate = 2248, nLevel = -1, nSeries = 0},  --上官飞龙
    [3] = {nTemplate = 2252, nLevel = -1, nSeries = 0},  --月眉儿
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
            {"AddNpc", 1, 1, 1, "ShiBei", "QingMing_3_ShiBei", false, 57},

            --纳兰真 
            {"AddNpc", 3, 1, 1, "Npc1", "QingMing_3_Npc1", false, 25, 0, 0, 0},

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
            {"PlayerBubbleTalk", "月姑娘，這是怎麼回事？你怎會在這裡？"}
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
            {"AddNpc", 2, 1, 1, "Npc2", "QingMing_3_Npc2", false, 0, 0, 0, 0},

            {"BlackMsg", "前方忽然出現了一個虛幻的人影"},
            {"SetFubenProgress", -1, "聆聽兩人對話"}, 

            --Npc移动
            {"ChangeNpcAi", "Npc2", "Move", "QingMing_Path3", 5, 0, 0, 0},

            --设置Npc朝向
            {"SetNpcDir", "Npc1", 25}
        },
    },
    [5] = {nTime = 0, nNum = 1,
        tbPrelock = {4},
        tbStartEvent = 
        {
        },
        tbUnLockEvent = 
        {
            {"NpcBubbleTalk", "Npc2", "嗯？此處是……淩絕峰？哼，該不會又讓我遇見楊熙烈那個混帳吧！你、你是誰？", 4, 1, 1},

            {"NpcBubbleTalk", "Npc1", "想不到這心魔幻境竟真能見到爹爹！是我，你忘記了嗎？我是你的女兒，月眉兒啊！", 4, 6, 1},

            {"NpcBubbleTalk", "Npc2", "你……你說你是眉兒？！不！不可能，眉兒不過幾歲，怎麼可能……", 4, 11, 1},

            {"NpcBubbleTalk", "Npc1", "爹爹…此處乃心魔幻境，乃一處可以實現人心中最深處夢想的地方，距你與楊叔叔決鬥，已有十數載了。", 4, 16, 1},    

            {"NpcBubbleTalk", "Npc2", "竟有如此神奇之地？等等，你怎地稱他為叔叔？哼，若非那混帳，我又豈會拋下你們母子二人？", 4, 21, 1},

            {"NpcBubbleTalk", "Npc1", "爹爹…此事確是楊叔叔不對，但他也已死去，更何況，我、我結識了他的兒子，楊影楓", 4, 26, 1}, 

            {"NpcBubbleTalk", "Npc2", "什麼？這個混帳，與我同歸於盡之後，他兒子又來奪走了我女兒的芳心？那個混帳小子呢？", 4, 31, 1},

            {"NpcBubbleTalk", "Npc1", "撲哧，爹爹，你口中的那個混帳小子，也去見他的爹爹了，他答應我，要好好責備楊叔叔的！", 4, 36, 1},  

            {"NpcBubbleTalk", "Npc2", "這還差不多，哼，總算這個臭小子對你還算上心，他個性如何？是否也一心想著天下第一？", 4, 41, 1},

            {"NpcBubbleTalk", "Npc1", "他與楊叔叔不同，對女兒很好，對了爹爹，如今飛龍堡在我的帶領下，江湖中尊稱禦下三盟。", 4, 46, 1},   

            {"NpcBubbleTalk", "Npc2", "不錯不錯，虎父無犬女，你有如此成就，為父甚是欣慰，只是也莫要太過操勞，畢竟你是女兒身。", 4, 51, 1},

            {"NpcBubbleTalk", "Npc1", "爹爹，無論武藝才學，我可不輸於男子！我告訴你哦，爹、爹爹……你，你的身體怎麼越來越虛幻了？", 4, 56, 1},  

            {"NpcBubbleTalk", "Npc2", "嗯？看來為父的大限已到，哈哈哈，不必如此，為父本就已不在，知你幸福，為父在九泉之下也就無憾了。保重，乖女兒！", 4, 61, 1},
        },
    },       
    [6] = {nTime = 65, nNum = 0,
        tbPrelock = {5},
        tbStartEvent = 
        {

        },
        tbUnLockEvent = 
        {
            {"NpcBubbleTalk", "Npc1", "爹爹保重。", 4, 63, 1},
            {"SetFubenProgress", -1, "離開幻境"}, 
            {"BlackMsg", "現在可以離開了！"},
            {"GameWin"},
            --纪念石碑 
            {"AddSimpleNpc", 2276, 4580, 3150, 57}, 

            --纳兰真 
            {"AddSimpleNpc", 2252, 4300, 3400, 25}, 
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