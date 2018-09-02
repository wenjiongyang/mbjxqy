Require("CommonScript/Activity/QingMingActC.lua");
local tbAct = Activity:GetClass("QingMingAct")
local tbFubenSetting = {};
local nMapTemplateId = 1603

Fuben:SetFubenSetting(nMapTemplateId, tbFubenSetting)   -- 绑定副本内容和地图

tbFubenSetting.szNpcPointFile           = "Setting/Fuben/QingMingFuben/NpcPos.tab"         -- NPC点
tbFubenSetting.szPathFile               = "Setting/Fuben/QingMingFuben/NpcPath.tab"        -- 寻路点

tbFubenSetting.szFubenClass   = tbAct.szFubenClass;                                  -- 副本类型
tbFubenSetting.szName         = "清明節"                                             -- 单纯的名字，后台输出或统计使用
tbFubenSetting.tbBeginPoint   = {5920, 1970}  
tbFubenSetting.tbTempRevivePoint = {5950, 1680}  

-- 开始祭拜是需要解锁的锁id，填nil则无需解锁,前提是该锁是开始状态并且还没解锁
tbFubenSetting.nStartWorshipUnlockId = 4
-- 完成祭拜是需要解锁的锁id
tbFubenSetting.nFinishWorshipUnlockId = nil
-- 开始祭拜时玩家的坐标和方向
tbFubenSetting.tbWorshipInfo = {
    {tbPos = {6070, 1940}, nDir = 48},              -- 使用道具者
    {tbPos = {5880, 1630}, nDir = 60},             -- 协助者
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
    [2] = {nTemplate = 2242, nLevel = -1, nSeries = 0},  --张琳心
    [3] = {nTemplate = 2251, nLevel = -1, nSeries = 0},  --独孤剑
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
            {"AddNpc", 1, 1, 1, "ShiBei", "QingMing_2_ShiBei", false, 18},

            --纳兰真 
            {"AddNpc", 3, 1, 1, "Npc1", "QingMing_2_Npc1", false, 49, 0, 0, 0},

            {"OpenWindow", "LingJueFengLayerPanel", "Info", 3, 9, "心魔幻境 鳳凰山"},
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
            {"BlackMsg", "不遠處有一塊碑石，這是……鳳凰山？我怎麼會到了這裡？"},
            {"PlayerBubbleTalk", "獨孤大俠，這是怎麼回事？你怎會在這裡？"}
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
            {"AddNpc", 2, 1, 1, "Npc2", "QingMing_2_Npc2", false, 0, 0, 0, 0},

            {"BlackMsg", "前方忽然出現了一個虛幻的人影"},
            {"SetFubenProgress", -1, "聆聽兩人對話"}, 

            --Npc移动
            {"ChangeNpcAi", "Npc2", "Move", "QingMing_Path2", 5, 0, 0, 0},

            --设置Npc朝向
            {"SetNpcDir", "Npc1", 49}
        },
    },
    [5] = {nTime = 0, nNum = 1,
        tbPrelock = {4},
        tbStartEvent = 
        {
        },
        tbUnLockEvent = 
        {
            {"NpcBubbleTalk", "Npc2", "夫君，這是真的麼？我竟能再見到你……", 4, 1, 1},

            {"NpcBubbleTalk", "Npc1", "縱使知曉這心魔幻境乃虛妄之地，但能再見到你，便是癡狂亦無妨！", 4, 6, 1},

            {"NpcBubbleTalk", "Npc2", "夫君，這麼多年不見，你蒼老了許多……", 4, 11, 1},

            {"NpcBubbleTalk", "Npc1", "失去你，此生本已了無生趣，只是抗金大業未成，我不忍拋下他們！", 4, 16, 1},    

            {"NpcBubbleTalk", "Npc2", "夫君，千萬不可，你曾答應我要好好地活下去，對了，楊姑娘呢？她……", 4, 21, 1},

            {"NpcBubbleTalk", "Npc1", "唉，琳兒，你應該清楚，除了你以外，我心中再容不下其他人，楊瑛是個好姑娘，但……", 4, 26, 1}, 

            {"NpcBubbleTalk", "Npc2", "楊姑娘如此忠烈，想必亦是終生未嫁，我已是久死之人，你們這又是何苦呢？", 4, 31, 1},

            {"NpcBubbleTalk", "Npc1", "琳兒，此事休要再提，若真有來生，我亦要繼續尋你覓你。", 4, 36, 1},  

            {"NpcBubbleTalk", "Npc2", "夫君…你對我情深至此…琳兒便不再多言，若有來生，我自會靜靜相待，非君不嫁。", 4, 41, 1},

            {"NpcBubbleTalk", "Npc1", "只願來生你我均生在一個普通的小家庭，莫要再被國仇家恨所糾纏。", 4, 46, 1},   

            {"NpcBubbleTalk", "Npc2", "夫君，身體要緊，此後你可不能再這般放縱自己了。", 4, 51, 1},

            {"NpcBubbleTalk", "Npc1", "好，琳兒，你放心，我這把老骨頭尚有用處，我定會……琳兒，你……", 4, 56, 1},  

            {"NpcBubbleTalk", "Npc2", "看來時候差不多了，琳兒與你就此別過了，夫君，珍重……", 4, 61, 1},
        },
    },       
    [6] = {nTime = 65, nNum = 0,
        tbPrelock = {5},
        tbStartEvent = 
        {

        },
        tbUnLockEvent = 
        {
            {"NpcBubbleTalk", "Npc1", "琳兒……", 4, 63, 1},
            {"SetFubenProgress", -1, "離開幻境"}, 
            {"BlackMsg", "現在可以離開了！"},
            {"GameWin"},
            --纪念石碑 
            {"AddSimpleNpc", 2276, 5400, 2000, 18}, 

            --纳兰真 
            {"AddSimpleNpc", 2251, 5780, 1980, 49}, 
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