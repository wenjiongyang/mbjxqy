Require("CommonScript/Activity/QingMingActC.lua");
local tbAct = Activity:GetClass("QingMingAct")
local tbFubenSetting = {};
local nMapTemplateId = 1607

Fuben:SetFubenSetting(nMapTemplateId, tbFubenSetting)   -- 绑定副本内容和地图

tbFubenSetting.szNpcPointFile           = "Setting/Fuben/QingMingFuben/NpcPos.tab"         -- NPC点
tbFubenSetting.szPathFile               = "Setting/Fuben/QingMingFuben/NpcPath.tab"        -- 寻路点

tbFubenSetting.szFubenClass   = tbAct.szFubenClass;                                  -- 副本类型
tbFubenSetting.szName         = "清明節"                                             -- 单纯的名字，后台输出或统计使用
tbFubenSetting.tbBeginPoint   = {3300, 5000}  
tbFubenSetting.tbTempRevivePoint = {3300, 5000}  

-- 开始祭拜是需要解锁的锁id，填nil则无需解锁,前提是该锁是开始状态并且还没解锁
tbFubenSetting.nStartWorshipUnlockId = 4
-- 完成祭拜是需要解锁的锁id
tbFubenSetting.nFinishWorshipUnlockId = nil
-- 开始祭拜时玩家的坐标和方向
tbFubenSetting.tbWorshipInfo = {
    {tbPos = {3610, 5330}, nDir = 17},              -- 使用道具者
    {tbPos = {3790, 5500}, nDir = 26},             -- 协助者
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
    [2] = {nTemplate = 2245, nLevel = -1, nSeries = 0},  --孟知秋
    [3] = {nTemplate = 2255, nLevel = -1, nSeries = 0},  --蔷薇
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
            {"AddNpc", 1, 1, 1, "ShiBei", "QingMing_6_ShiBei", false, 32},

            --纳兰真 
            {"AddNpc", 3, 1, 1, "Npc1", "QingMing_6_Npc1", false, 16, 0, 0, 0},

            {"OpenWindow", "LingJueFengLayerPanel", "Info", 3, 9, "心魔幻境 落葉穀"},
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
            {"BlackMsg", "不遠處有一塊碑石，這是……落葉穀？我怎麼會到了這裡？"},
            {"PlayerBubbleTalk", "薔薇姑娘，這是怎麼回事？你怎會在這裡？"}
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
            {"AddNpc", 2, 1, 1, "Npc2", "QingMing_6_Npc2", false, 0, 0, 0, 0},

            {"BlackMsg", "前方忽然出現了一個虛幻的人影"},
            {"SetFubenProgress", -1, "聆聽兩人對話"}, 

            --Npc移动
            {"ChangeNpcAi", "Npc2", "Move", "QingMing_Path6", 5, 0, 0, 0},

            --设置Npc朝向
            {"SetNpcDir", "Npc1", 16}
        },
    },
    [5] = {nTime = 0, nNum = 1,
        tbPrelock = {4},
        tbStartEvent = 
        {
        },
        tbUnLockEvent = 
        {
            {"NpcBubbleTalk", "Npc2", "此處是落葉穀？納蘭潛凜呢！不好！我得趕緊去通知天星道長！還有薇兒……薇兒，你怎會在此？", 4, 1, 1},

            {"NpcBubbleTalk", "Npc1", "爹爹……此處乃心魔幻境，並非真正的落葉谷，乃人心深處夢想所化，你、你已被納蘭潛凜……被……", 4, 6, 1},

            {"NpcBubbleTalk", "Npc2", "是嗎？原來如此，唉，想我一世英雄，最終卻敗于納蘭潛凜之手！所幸蒼天有眼，你逃過了一劫", 4, 11, 1},

            {"NpcBubbleTalk", "Npc1", "爹爹…你放心…我活得很好，是影楓哥哥他打敗了納蘭潛凜，救了我，我和他，我們、我、我……", 4, 16, 1},    

            {"NpcBubbleTalk", "Npc2", "呵呵，你這小丫頭，對我還有什麼事是不能說的嗎？影楓這孩子很好，只是沒有遇到合適的名師。", 4, 21, 1},

            {"NpcBubbleTalk", "Npc1", "對呀，爹爹，他不但武學天賦極高，而且人也很善良，若是爹爹你還在世就好了，你們共研武學……", 4, 26, 1}, 

            {"NpcBubbleTalk", "Npc2", "呵呵，傻丫頭，能夠得知你如今生活安康，無憂無慮，爹的生死，又有何妨？", 4, 31, 1},

            {"NpcBubbleTalk", "Npc1", "爹爹！我不許你這麼說！你若再這般說話！我可要生氣了！再也不會來找你了！", 4, 36, 1},  

            {"NpcBubbleTalk", "Npc2", "好好好，我的寶貝女兒，你可千萬莫要生氣，不過影楓這孩子固執得很，還需要你多加開導。", 4, 41, 1},

            {"NpcBubbleTalk", "Npc1", "若爹爹說的是他對天下第一的追求，不必擔心，他已經放棄了這個念頭。", 4, 46, 1},   

            {"NpcBubbleTalk", "Npc2", "那樣便好，那樣便好。丫頭，以後爹爹不能在你身邊，你要好好保護自己，知道了嗎？", 4, 51, 1},

            {"NpcBubbleTalk", "Npc1", "爹爹，如今影楓哥哥是天下第一人，他自然會保護我的，爹爹，你、你的身體……", 4, 56, 1},  

            {"NpcBubbleTalk", "Npc2", "嗯？呵呵，虛幻之物終究是有限，罷了，為父這就要離開了，薇兒，多多愛護自己。", 4, 61, 1},
        },
    },       
    [6] = {nTime = 65, nNum = 0,
        tbPrelock = {5},
        tbStartEvent = 
        {

        },
        tbUnLockEvent = 
        {
            {"NpcBubbleTalk", "Npc1", "爹爹……", 4, 63, 1},
            {"SetFubenProgress", -1, "離開幻境"}, 
            {"BlackMsg", "現在可以離開了！"},
            {"GameWin"},
            --纪念石碑 
            {"AddSimpleNpc", 2276, 4010, 5440, 32}, 

            --纳兰真 
            {"AddSimpleNpc", 2255, 3860, 5280, 16}, 
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