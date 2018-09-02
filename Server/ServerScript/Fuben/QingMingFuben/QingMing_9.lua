Require("CommonScript/Activity/QingMingActC.lua");
local tbAct = Activity:GetClass("QingMingAct")
local tbFubenSetting = {};
local nMapTemplateId = 1610

Fuben:SetFubenSetting(nMapTemplateId, tbFubenSetting)   -- 绑定副本内容和地图

tbFubenSetting.szNpcPointFile           = "Setting/Fuben/QingMingFuben/NpcPos.tab"         -- NPC点
tbFubenSetting.szPathFile               = "Setting/Fuben/QingMingFuben/NpcPath.tab"        -- 寻路点

tbFubenSetting.szFubenClass   = tbAct.szFubenClass;                                  -- 副本类型
tbFubenSetting.szName         = "清明節"                                             -- 单纯的名字，后台输出或统计使用
tbFubenSetting.tbBeginPoint   = {2750, 5330}  
tbFubenSetting.tbTempRevivePoint = {2750, 5330}  

-- 开始祭拜是需要解锁的锁id，填nil则无需解锁,前提是该锁是开始状态并且还没解锁
tbFubenSetting.nStartWorshipUnlockId = 4
-- 完成祭拜是需要解锁的锁id
tbFubenSetting.nFinishWorshipUnlockId = nil
-- 开始祭拜时玩家的坐标和方向
tbFubenSetting.tbWorshipInfo = {
    {tbPos = {2980, 5550}, nDir = 47},              -- 使用道具者
    {tbPos = {2330, 6020}, nDir = 30},             -- 协助者
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
    [2] = {nTemplate = 2249, nLevel = -1, nSeries = 0},  --岳飞
    [3] = {nTemplate = 2278, nLevel = -1, nSeries = 0},  --公孙惜花
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
            {"AddNpc", 1, 1, 1, "ShiBei", "QingMing_9_ShiBei", false, 32},

            --纳兰真 
            {"AddNpc", 3, 1, 1, "Npc1", "QingMing_9_Npc1", false, 60, 0, 0, 0},

            {"OpenWindow", "LingJueFengLayerPanel", "Info", 3, 9, "心魔幻境 風波亭"},
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
            {"BlackMsg", "不遠處有一塊碑石，這是……風波亭？我怎麼會到了這裡？"},
            {"PlayerBubbleTalk", "公孫老闆娘，這是怎麼回事？你怎會在這裡？"}
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
            {"AddNpc", 2, 1, 1, "Npc2", "QingMing_9_Npc2", false, 0, 0, 0, 0},

            {"BlackMsg", "前方忽然出現了一個虛幻的人影"},
            {"SetFubenProgress", -1, "聆聽兩人對話"}, 

            --Npc移动
            {"ChangeNpcAi", "Npc2", "Move", "QingMing_Path9", 5, 0, 0, 0},

            --设置Npc朝向
            {"SetNpcDir", "Npc1", 60}
        },
    },
    [5] = {nTime = 0, nNum = 1,
        tbPrelock = {4},
        tbStartEvent = 
        {
        },
        tbUnLockEvent = 
        {
            {"NpcBubbleTalk", "Npc2", "這裡…是哪裡？是了！是風波亭！秦檜！惡賊！奸黨！我要殺了你！", 4, 1, 1},

            {"NpcBubbleTalk", "Npc1", "好了好了，多少歲的人了，還這般動肝火，省省心吧，你還嫌殺的人不夠麼？", 4, 6, 1},

            {"NpcBubbleTalk", "Npc2", "哼！若是殺敵寇，便是再來萬千個，也殺不夠！若是我宋朝子民，我一個也不殺！", 4, 11, 1},

            {"NpcBubbleTalk", "Npc1", "喲，大英雄，你倒是說得輕巧，莫要忘了，你方才口口聲聲要殺之人，可也是我大宋子民。", 4, 16, 1},    

            {"NpcBubbleTalk", "Npc2", "他……他這樣的人，留著徒增禍害！置家國於不顧，又豈能稱之為我朝子民？", 4, 21, 1},

            {"NpcBubbleTalk", "Npc1", "唉，岳大將軍，你一生戎馬，馳騁沙場，也是時候該歇歇了。", 4, 26, 1}, 

            {"NpcBubbleTalk", "Npc2", "嗯？對了，我還沒問，你這小姑娘伶牙俐齒的，究竟是誰？我現在又身在何處？", 4, 31, 1},

            {"NpcBubbleTalk", "Npc1", "你和我均處於心魔幻境之中，傳聞此陣能夠讓一些人的幻想短暫化為現實，想不到真有奇效", 4, 36, 1},  

            {"NpcBubbleTalk", "Npc2", "原來如此，我還以為是你救了我，現在看來，終究是無法救萬民於水火之中了。如今宋、金情勢如何？", 4, 41, 1},

            {"NpcBubbleTalk", "Npc1", "我可沒那本事救你。至於情勢，沒有了你，情勢如何還需要我說嗎？我來便是像向你請教山河社稷圖之事", 4, 46, 1},   

            {"NpcBubbleTalk", "Npc2", "唉，區區一份圖譜，又豈能改變天下？還是留著，興許後世能夠有人借此重整旗鼓。", 4, 51, 1},

            {"NpcBubbleTalk", "Npc1", "岳大將軍，我已知道想要的答案，你的身體也越發虛幻，就在此好好休息吧，你的事業，總會有後來者替你完成的", 4, 56, 1},  

            {"NpcBubbleTalk", "Npc2", "姑娘留步，敢問姑娘的名字？", 4, 61, 1},
        },
    },       
    [6] = {nTime = 65, nNum = 0,
        tbPrelock = {5},
        tbStartEvent = 
        {

        },
        tbUnLockEvent = 
        {
            {"NpcBubbleTalk", "Npc1", "樹欲靜而風不止，子欲養而親不待，我欲要說，你卻又不在了。記住，我叫公孫惜花。保重。", 4, 63, 1},
            {"SetFubenProgress", -1, "離開幻境"}, 
            {"BlackMsg", "現在可以離開副本了！"},
            {"GameWin"},
            --纪念石碑 
            {"AddSimpleNpc", 2276, 2620, 6240, 32}, 

            --纳兰真 
            {"AddSimpleNpc", 2278, 2480, 5670, 60}, 
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