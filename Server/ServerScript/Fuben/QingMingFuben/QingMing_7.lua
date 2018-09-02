Require("CommonScript/Activity/QingMingActC.lua");
local tbAct = Activity:GetClass("QingMingAct")
local tbFubenSetting = {};
local nMapTemplateId = 1608

Fuben:SetFubenSetting(nMapTemplateId, tbFubenSetting)   -- 绑定副本内容和地图

tbFubenSetting.szNpcPointFile           = "Setting/Fuben/QingMingFuben/NpcPos.tab"         -- NPC点
tbFubenSetting.szPathFile               = "Setting/Fuben/QingMingFuben/NpcPath.tab"        -- 寻路点

tbFubenSetting.szFubenClass   = tbAct.szFubenClass;                                  -- 副本类型
tbFubenSetting.szName         = "清明節"                                             -- 单纯的名字，后台输出或统计使用
tbFubenSetting.tbBeginPoint   = {2400, 6300}  
tbFubenSetting.tbTempRevivePoint = {2400, 6300}  

-- 开始祭拜是需要解锁的锁id，填nil则无需解锁,前提是该锁是开始状态并且还没解锁
tbFubenSetting.nStartWorshipUnlockId = 4
-- 完成祭拜是需要解锁的锁id
tbFubenSetting.nFinishWorshipUnlockId = nil
-- 开始祭拜时玩家的坐标和方向
tbFubenSetting.tbWorshipInfo = {
    {tbPos = {2460, 74200}, nDir = 31},              -- 使用道具者
    {tbPos = {2290, 7060}, nDir = 13},             -- 协助者
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
    [2] = {nTemplate = 2246, nLevel = -1, nSeries = 0},  --张风
    [3] = {nTemplate = 2256, nLevel = -1, nSeries = 0},  --张如梦
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
            {"AddNpc", 1, 1, 1, "ShiBei", "QingMing_7_ShiBei", false, 38},

            --纳兰真 
            {"AddNpc", 3, 1, 1, "Npc1", "QingMing_7_Npc1", false, 7, 0, 0, 0},

            {"OpenWindow", "LingJueFengLayerPanel", "Info", 3, 9, "心魔幻境 臨安驛道"},
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
            {"BlackMsg", "不遠處有一塊碑石，這是……臨安驛道？我怎麼會到了這裡？"},
            {"PlayerBubbleTalk", "張少俠，這是怎麼回事？你怎會在這裡？"}
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
            {"AddNpc", 2, 1, 1, "Npc2", "QingMing_7_Npc2", false, 0, 0, 0, 0},

            {"BlackMsg", "前方忽然出現了一個虛幻的人影"},
            {"SetFubenProgress", -1, "聆聽兩人對話"}, 

            --Npc移动
            {"ChangeNpcAi", "Npc2", "Move", "QingMing_Path7", 5, 0, 0, 0},

            --设置Npc朝向
            {"SetNpcDir", "Npc1", 7}
        },
    },
    [5] = {nTime = 0, nNum = 1,
        tbPrelock = {4},
        tbStartEvent = 
        {
        },
        tbUnLockEvent = 
        {
            {"NpcBubbleTalk", "Npc2", "這裡是……我竟然還沒死？南宮滅，南宮滅呢！夢兒？你怎麼會在這裡？此處危險，快走！", 4, 1, 1},

            {"NpcBubbleTalk", "Npc1", "這傳說竟是真的……心魔幻境，竟然真的能讓人夢想成真！爹爹，孩兒不孝，請受孩兒一拜！", 4, 6, 1},

            {"NpcBubbleTalk", "Npc2", "哎呀！你這孩子，這是幹什麼？我說了，此處不宜久留，你還不速速離開！", 4, 11, 1},

            {"NpcBubbleTalk", "Npc1", "爹，不必擔心，南宮滅早已死去多時，就連您，也不過是虛假的幻像…是孩兒心中的一抹執念…", 4, 16, 1},    

            {"NpcBubbleTalk", "Npc2", "你說什麼？原來我並未記錯，我確是被南宮滅重傷，不久後便撒手人寰了？", 4, 21, 1},

            {"NpcBubbleTalk", "Npc1", "確實如此。此地名為心魔幻境，傳聞能夠將人內心深處的夢想化為現實，我也沒想到竟然是真的。", 4, 26, 1}, 

            {"NpcBubbleTalk", "Npc2", "如此也好，如此也好啊，我畢竟雙手沾滿了罪孽，能夠死得其所，已經很好了！對了！獨孤兄的遺孤如何？", 4, 31, 1},

            {"NpcBubbleTalk", "Npc1", "爹爹放心，獨孤兄好得很，他把一切真相都告訴我了，原來爹爹您當年是忍辱負重，都怪孩兒愚昧！一直錯怪爹了！", 4, 36, 1},  

            {"NpcBubbleTalk", "Npc2", "呵呵，不怪你，不怪你，這麼多年你也一直很痛苦，爹也知道，只是有些話，卻不能坦白告訴你。", 4, 41, 1},

            {"NpcBubbleTalk", "Npc1", "爹，我有一事，還需要您老人家原諒，希望你莫要生氣……", 4, 46, 1},   

            {"NpcBubbleTalk", "Npc2", "你這小子，終日沉溺于酒色之時，老子也沒少生你的氣，如今又做出什麼壞事來了？", 4, 51, 1},

            {"NpcBubbleTalk", "Npc1", "爹爹…我、我與金國女子南宮彩虹真心相愛，已結為夫婦，隱居大漠。再不理世事！還請爹…爹你的身體…", 4, 56, 1},  

            {"NpcBubbleTalk", "Npc2", "夢兒，你至情至性，為父一直清楚，此事並無過錯，只可惜我見不到我的兒媳婦了。呵呵，隱居也好，爹祝福你們！要保重！", 4, 61, 1},
        },
    },       
    [6] = {nTime = 65, nNum = 0,
        tbPrelock = {5},
        tbStartEvent = 
        {

        },
        tbUnLockEvent = 
        {
            {"NpcBubbleTalk", "Npc1", "多謝爹爹！", 4, 63, 1},
            {"SetFubenProgress", -1, "離開幻境"}, 
            {"BlackMsg", "現在可以離開了！"},
            {"GameWin"},
            --纪念石碑 
            {"AddSimpleNpc", 2276, 2680, 7180, 38}, 

            --纳兰真 
            {"AddSimpleNpc", 2256, 2440, 6810, 7}, 
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