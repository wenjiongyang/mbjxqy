Require("CommonScript/Activity/QingMingActC.lua");
local tbAct = Activity:GetClass("QingMingAct")
local tbFubenSetting = {};
local nMapTemplateId = 1609

Fuben:SetFubenSetting(nMapTemplateId, tbFubenSetting)   -- 绑定副本内容和地图

tbFubenSetting.szNpcPointFile           = "Setting/Fuben/QingMingFuben/NpcPos.tab"         -- NPC点
tbFubenSetting.szPathFile               = "Setting/Fuben/QingMingFuben/NpcPath.tab"        -- 寻路点

tbFubenSetting.szFubenClass   = tbAct.szFubenClass;                                  -- 副本类型
tbFubenSetting.szName         = "清明節"                                             -- 单纯的名字，后台输出或统计使用
tbFubenSetting.tbBeginPoint   = {4400, 5400}  
tbFubenSetting.tbTempRevivePoint = {4400, 5400}  

-- 开始祭拜是需要解锁的锁id，填nil则无需解锁,前提是该锁是开始状态并且还没解锁
tbFubenSetting.nStartWorshipUnlockId = 4
-- 完成祭拜是需要解锁的锁id
tbFubenSetting.nFinishWorshipUnlockId = nil
-- 开始祭拜时玩家的坐标和方向
tbFubenSetting.tbWorshipInfo = {
    {tbPos = {5100, 6080}, nDir = 42},              -- 使用道具者
    {tbPos = {4800, 5720}, nDir = 57},             -- 协助者
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
    [2] = {nTemplate = 2247, nLevel = -1, nSeries = 0},  --天星道长
    [3] = {nTemplate = 2277, nLevel = -1, nSeries = 0},  --挺哥
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
            {"AddNpc", 1, 1, 1, "ShiBei", "QingMing_8_ShiBei", false, 32},

            --纳兰真 
            {"AddNpc", 3, 1, 1, "Npc1", "QingMing_8_Npc1", false, 0, 0, 0, 0},


            {"OpenWindow", "LingJueFengLayerPanel", "Info", 3, 9, "心魔幻境 武當山"},
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
            {"BlackMsg", "不遠處有一塊碑石，這是……武當山？我怎麼會到了這裡？"},
            {"PlayerBubbleTalk", "挺哥，這是怎麼回事？你怎會在這裡？"}
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
            {"AddNpc", 2, 1, 1, "Npc2", "QingMing_8_Npc2", false, 0, 0, 0, 0},

            {"BlackMsg", "前方忽然出現了一個虛幻的人影"},
            {"SetFubenProgress", -1, "聆聽兩人對話"}, 

            --Npc移动
            {"ChangeNpcAi", "Npc2", "Move", "QingMing_Path8", 5, 0, 0, 0},

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
            {"NpcBubbleTalk", "Npc2", "可恨！想不到無憂教的勢力竟發展至此！我還一直懵然不知！真是老糊塗！", 4, 1, 1},

            {"NpcBubbleTalk", "Npc1", "師祖…竟真的能夠見到師祖…弟子拜見師祖！", 4, 6, 1},

            {"NpcBubbleTalk", "Npc2", "嗯？你是誰？看你裝束，確實是我武當弟子，只不過為何我從未見過你？", 4, 11, 1},

            {"NpcBubbleTalk", "Npc1", "師祖，容我詳細說來，此處乃心魔幻境，能夠短暫實現人心深處的夢想。所以師祖您其實早已…", 4, 16, 1},    

            {"NpcBubbleTalk", "Npc2", "嗯，我雖然老糊塗了，可是仍清楚記得敗在了納蘭潛凜的手上，唉，武當遭無憂教血洗。", 4, 21, 1},

            {"NpcBubbleTalk", "Npc1", "師祖不必過於傷感，後來武當臥薪嚐膽，如今已重新成為武林中的中流砥柱。", 4, 26, 1}, 

            {"NpcBubbleTalk", "Npc2", "好！聲名倒是其次，但我武當派匡扶武林正道的行為舉止，決不能變！", 4, 31, 1},

            {"NpcBubbleTalk", "Npc1", "師祖說得對，如今掌教道一師父雲遊遠去，下一任掌門，想必是天目師兄，天目師兄為人正氣，定不負師祖所望。", 4, 36, 1},  

            {"NpcBubbleTalk", "Npc2", "那便好，那便好啊！呵呵，想到武林正道仍存，武當再度崛起，老道就深感欣慰啊！無憂教如何了？", 4, 41, 1},

            {"NpcBubbleTalk", "Npc1", "師祖，無憂邪教十年前便已被毀，剿滅無憂教的乃是一位名叫楊影楓的俠少。", 4, 46, 1},   

            {"NpcBubbleTalk", "Npc2", "不錯不錯，楊少俠能夠平息心魔。走入正道，實乃武林之福，武林之福啊！呵呵呵呵！", 4, 51, 1},

            {"NpcBubbleTalk", "Npc1", "師祖，今日乃清明佳節，弟子特帶了些美酒菜肴前來，您……師祖您的身體？", 4, 56, 1},  

            {"NpcBubbleTalk", "Npc2", "呵呵，終究是過眼雲煙，無妨，正道得以伸張，老道心願已了，也無甚牽掛，你天資卓絕，將來也必成一方名俠。去吧。", 4, 61, 1},
        },
    },       
    [6] = {nTime = 65, nNum = 0,
        tbPrelock = {5},
        tbStartEvent = 
        {

        },
        tbUnLockEvent = 
        {
            {"NpcBubbleTalk", "Npc1", "師祖告辭！保重。", 4, 63, 1},
            {"SetFubenProgress", -1, "離開幻境"}, 
            {"BlackMsg", "現在可以離開了！"},
            {"GameWin"},
            --纪念石碑 
            {"AddSimpleNpc", 2276, 4340, 6260, 32}, 

            --纳兰真 
            {"AddSimpleNpc", 2277, 4400, 5830, 0}, 
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