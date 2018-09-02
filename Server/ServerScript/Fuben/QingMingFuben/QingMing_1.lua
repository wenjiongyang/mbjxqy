Require("CommonScript/Activity/QingMingActC.lua");
local tbAct = Activity:GetClass("QingMingAct")
local tbFubenSetting = {};
local nMapTemplateId = 1602

Fuben:SetFubenSetting(nMapTemplateId, tbFubenSetting)   -- 绑定副本内容和地图

tbFubenSetting.szNpcPointFile           = "Setting/Fuben/QingMingFuben/NpcPos.tab"         -- NPC点
tbFubenSetting.szPathFile               = "Setting/Fuben/QingMingFuben/NpcPath.tab"        -- 寻路点

tbFubenSetting.szFubenClass   = tbAct.szFubenClass;                                  -- 副本类型
tbFubenSetting.szName         = "清明節"                                             -- 单纯的名字，后台输出或统计使用
tbFubenSetting.tbBeginPoint   = {5000, 8100}  
tbFubenSetting.tbTempRevivePoint = {5000, 8100}  

-- 开始祭拜是需要解锁的锁id，填nil则无需解锁,前提是该锁是开始状态并且还没解锁
tbFubenSetting.nStartWorshipUnlockId = 4
-- 完成祭拜是需要解锁的锁id
tbFubenSetting.nFinishWorshipUnlockId = nil
-- 开始祭拜时玩家的坐标和方向
tbFubenSetting.tbWorshipInfo = {
    {tbPos = {4820, 8150}, nDir = 5},              -- 使用道具者
    {tbPos = {5000, 8200}, nDir = 0},             -- 协助者
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
    [2] = {nTemplate = 2241, nLevel = -1, nSeries = 0},  --纳兰潜凛
    [3] = {nTemplate = 2250, nLevel = -1, nSeries = 0},  --纳兰真
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
            {"AddNpc", 1, 1, 1, "ShiBei", "QingMing_1_ShiBei", false, 0, 0, 0, 0},

            --纳兰真 
            {"AddNpc", 3, 1, 1, "Npc1", "QingMing_1_Npc1", false, 0, 0, 0, 0},

            {"OpenWindow", "RockerGuideNpcPanel", "心魔幻境 忘憂島"},
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
            {"BlackMsg", "不遠處有一塊碑石，這是……忘憂島？我怎麼會到了這裡？"},
            {"PlayerBubbleTalk", "納蘭姑娘，這是怎麼回事？你怎會在這裡？"}
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
            {"AddNpc", 2, 1, 1, "Npc2", "QingMing_1_Npc2", false, 0, 0, 0, 0},

            {"BlackMsg", "前方忽然出現了一個虛幻的人影"},
            {"SetFubenProgress", -1, "聆聽兩人對話"}, 

            --Npc移动
            {"ChangeNpcAi", "Npc2", "Move", "QingMing_Path1", 5, 0, 0, 0},

            --设置Npc朝向
            {"SetNpcDir", "Npc1", 0}
        },
    },
    [5] = {nTime = 0, nNum = 1,
        tbPrelock = {4},
        tbStartEvent = 
        {
        },
        tbUnLockEvent = 
        {
            {"NpcBubbleTalk", "Npc2", "真兒，許久不見，想不到竟能再次見到你……", 4, 1, 1},

            {"NpcBubbleTalk", "Npc1", "想不到這心魔幻境竟真能見到爹爹！這幾日乃清明佳節，我來看看你", 4, 6, 1},

            {"NpcBubbleTalk", "Npc2", "哼，那楊影楓對你可好？若他敢負你，我便化作惡鬼，也不放過他！", 4, 11, 1},

            {"NpcBubbleTalk", "Npc1", "爹爹…你放心…他對我很好，只是我十分想念你", 4, 16, 1},    

            {"NpcBubbleTalk", "Npc2", "如此便好，武林霸業竟已成黃粱一夢，你能幸福快樂，爹爹便心滿意足了。", 4, 21, 1},

            {"NpcBubbleTalk", "Npc1", "爹爹… 哎，早知如此，又何必當初？", 4, 26, 1}, 

            {"NpcBubbleTalk", "Npc2", "笑話！成王敗寇，本應如此！哼，你這小姑娘，又懂得些什麼！", 4, 31, 1},

            {"NpcBubbleTalk", "Npc1", "唉，爹爹，為了這念頭，你害得母親離去，如今又搭上了自己的性命，值得麼？", 4, 36, 1},  

            {"NpcBubbleTalk", "Npc2", "真兒，這世上何等遼闊，你父親我若是胸無大志，又豈能成為一代宗師？", 4, 41, 1},

            {"NpcBubbleTalk", "Npc1", "唉，也罷，也許你我所求不同，只願你在九泉之下，能活的快樂。是女兒不孝。", 4, 46, 1},   

            {"NpcBubbleTalk", "Npc2", "為父亦然，見你活的開心，一切安好，為父便放心了，是時候該離去了。", 4, 51, 1},

            {"NpcBubbleTalk", "Npc1", "爹爹…你…", 4, 56, 1},  

            {"NpcBubbleTalk", "Npc2", "好了，為父走了，你也早些回吧。", 4, 61, 1},
        },
    },       
    [6] = {nTime = 65, nNum = 0,
        tbPrelock = {5},
        tbStartEvent = 
        {

        },
        tbUnLockEvent = 
        {
            {"NpcBubbleTalk", "Npc1", "爹爹…保重…", 4, 63, 1},
            {"SetFubenProgress", -1, "離開幻境"}, 
            {"BlackMsg", "現在可以離開了！"},
            {"GameWin"},
            --纪念石碑 
            {"AddSimpleNpc", 2276, 4900, 8700, 0}, 

            --纳兰真 
            {"AddSimpleNpc", 2250, 4880, 8330, 0}, 
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