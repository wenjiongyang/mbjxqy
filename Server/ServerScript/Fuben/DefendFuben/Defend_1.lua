Require("CommonScript/Fuben/DefendFubenCommon.lua");
local tbFubenSetting = {};
local nMapTemplateId = DefendFuben.nFubenMapTemplateId
Fuben:SetFubenSetting(nMapTemplateId, tbFubenSetting)   -- 绑定副本内容和地图

tbFubenSetting.szNpcPointFile           = "Setting/Fuben/DefendFuben/NpcPos.tab"         -- NPC点
tbFubenSetting.szPathFile               = "Setting/Fuben/DefendFuben/NpcPath.tab"        -- 寻路点

tbFubenSetting.szFubenClass   = DefendFuben.szFubenClass;                                  -- 副本类型
tbFubenSetting.szName         = "同守天涯路"                                               -- 单纯的名字，后台输出或统计使用
tbFubenSetting.tbBeginPoint   = {7200, 7000}  
tbFubenSetting.tbTempRevivePoint = {7200, 7000}  

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
    [1]  = {nTemplate = 2079,  nLevel = -1,  nSeries = 1},    --金怪
    [2]  = {nTemplate = 2080,  nLevel = -1,  nSeries = 2},    --木怪
    [3]  = {nTemplate = 2081,  nLevel = -1,  nSeries = 3},    --水怪
    [4]  = {nTemplate = 2082,  nLevel = -1,  nSeries = 4},    --火怪
    [5]  = {nTemplate = 2083,  nLevel = -1,  nSeries = 5},    --土怪
    [6]  = {nTemplate = 2084,  nLevel = -1,  nSeries = 1},    --援助金
    [7]  = {nTemplate = 2085,  nLevel = -1,  nSeries = 2},    --援助木
    [8]  = {nTemplate = 2086,  nLevel = -1,  nSeries = 3},    --援助水
    [9]  = {nTemplate = 2087,  nLevel = -1,  nSeries = 4},    --援助火
    [10] = {nTemplate = 2088,  nLevel = -1,  nSeries = 5},    --援助土
    [11] = {nTemplate = 2089,  nLevel = -1,  nSeries = -1},    --张如梦
    [12] = {nTemplate = 2090,  nLevel = -1,  nSeries = 1},    --战斗金
    [13] = {nTemplate = 2091,  nLevel = -1,  nSeries = 2},    --战斗木
    [14] = {nTemplate = 2092,  nLevel = -1,  nSeries = 3},    --战斗水
    [15] = {nTemplate = 2093,  nLevel = -1,  nSeries = 4},    --战斗火
    [17] = {nTemplate = 2094,  nLevel = -1,  nSeries = 5},    --战斗土
    [18] = {nTemplate = 2095,  nLevel = -1,  nSeries = -1},    --南宫彩虹    
}
-- ChangeRoomState              更改房间title
--                              参数：nFloor 层, nRoomIdx 房间序列, szTitile 标题, nX, nY自动寻路点坐标, bKillBoss 是否杀死了BOSS
--                              示例：{"AddNpc", "NpcIndex2", "NpcNum2", 3, "Test1", "NpcPos2", true, 30, 2, 206, 1},


tbFubenSetting.NpcSeries = {
    [1] = "[ffba00]金[-]",
    [2] = "[15e800]木[-]",
    [3] = "[00c0ff]水[-]",
    [4] = "[c92100]火[-]",
    [5] = "[876b3d]土[-]",
}

tbFubenSetting.nMaxRoad = 4                           -- 有几条路
tbFubenSetting.nMaxRound = 6                          -- 有几轮
tbFubenSetting.nOpenRoadNum = 3                       -- 每轮开放几条路

-- 1 怪物出生点 2 助战Npc出生点   
tbFubenSetting.tbRoadSetting = 
{
    [1] = {"GuaiWu1", "Npc1",},                    
    [2] = {"GuaiWu2", "Npc2",},              
    [3] = {"GuaiWu3", "Npc3",},              
    [4] = {"GuaiWu4", "Npc4",},              
}

tbFubenSetting.szMingXiaPos = "MingXia"
tbFubenSetting.szMingXiaPath = "MingXiaPath"

-- 刷新小怪五行对应的NPC index
tbFubenSetting.tbSeriesMonster = 
{
    [1] = 1,                        --金
    [2] = 2,                        --木
    [3] = 3,                        --水
    [4] = 4,                        --火
    [5] = 5,                        --土
}

 -- 对话Npc ID
tbFubenSetting.tbSeriesDialogNpc =                 
{
    [1] = 2084,
    [2] = 2085,
    [3] = 2086,
    [4] = 2087,
    [5] = 2088,
}

 -- 援助Npc ID
tbFubenSetting.tbSeriesActiveNpc =                
{
    [1] = 2090,
    [2] = 2091,
    [3] = 2092,
    [4] = 2093,
    [5] = 2094,
}

-- 每一轮开始之前抛{"RaiseEvent", "RoundStep"}这个事件,会处理随机怪物属性
-- {"StartTimeCycle", "cycle_1", 3, 2, {"RaiseEvent", "CreateMonster", 51}}开启定时器穿件怪物，参数传对应的解锁的锁ID，每一次创建tbFubenSetting.nOpenRoadNum个怪物
-- 解锁数量nNum应该对应tbFubenSetting.nOpenRoadNum * 循环次数
-- 每一轮结束时应抛{"RaiseEvent", "RoundStepOver"}这个事件，会将对话Npc重置
-- 

tbFubenSetting.LOCK = 
{
    -- 1号锁不能不填，默认1号为起始锁，nTime是到时间自动解锁，nNum表示需要解锁的次数，如填3表示需要被解锁3次才算真正解锁，可以配置字符串
    [1] = {nTime = 1, nNum = 0,
        --tbPrelock 前置锁，激活锁的必要条件{1 , 2, {3, 4}}，代表1和2号必须解锁，3和4任意解锁一个即可
        tbPrelock = {},
        --tbStartEvent 锁激活时的事件
        tbStartEvent = 
        {
            --设置同步范围
            {"SetNearbyRange", 3},

            --调整摄像机基础参数
            {"ChangeCameraSetting", 29, 35, 20},


            {"AddNpc", 11, 1, 102, "MingXiaNpc", "MingXia", false, 0, 0, 0, 0},
            {"AddNpc", 18, 1, 102, "MingXiaBanLv", "Targer2", false, 36, 0, 0, 0}, 
            {"NpcHpUnlock", "MingXiaNpc", 70, 80},
            {"NpcHpUnlock", "MingXiaNpc", 71, 50},
            {"NpcHpUnlock", "MingXiaNpc", 72, 30},
            {"NpcHpUnlock", "MingXiaNpc", 73, 10},
            {"ChangeNpcCamp", "MingXiaNpc", 0},
        },
        --tbStartEvent 锁解开时的事件
        tbUnLockEvent = 
        {
        },
    },
    [2] = {nTime = 15, nNum = 0,
        tbPrelock = {1},
        tbStartEvent = 
        {
            {"NpcBubbleTalk", "MingXiaNpc", "如夢力有不逮，還望諸位俠士能夠替我照看虹兒。", 10, 2, 1},
            {"NpcBubbleTalk", "MingXiaBanLv", "虎毒不食兒，不必管我。夢哥的安危，便有勞二位了。", 10, 2, 1},
            {"BlackMsg", "張大俠與南宮姑娘均身受重傷，先到周圍查探一番！"},
            {"SetShowTime", 2},
            {"ChangeFightState", 1},
			{"SetFubenProgress", -1, "查看周圍環境"},
        },
        tbUnLockEvent = 
        {
        },
    },
    [3] = {nTime = 0  , nNum = 0,
        tbPrelock = {2},
        tbStartEvent = 
        {
            {"RaiseEvent", "RoundStep"},           
        },
        tbUnLockEvent = 
        {

        },
    },
    [4] = {nTime = 20, nNum = 0,
        tbPrelock = {3},
        tbStartEvent = 
        {
            {"SetShowTime", 4},
            {"SetFubenProgress", -1, "等待下一波敵人到來"},
            {"BlackMsg", "殺手即將出現，快找克制他們的同門師兄師姐幫忙！"}, 
        },
        tbUnLockEvent = 
        {
            {"NpcBubbleTalk", "MingXiaBanLv", "他們來了，是爹爹手下的精銳，小心！", 8, 2, 1},
        },
    },
    [5] = {nTime = 0, nNum = 36,
        tbPrelock = {4},
        tbStartEvent = 
        {
            {"SetShowTime", 102},
            {"BlackMsg", "殺手出現在地圖的三個方向，保護張大俠！"},
            {"SetFubenProgress", -1, "保護張如夢（1/6）"},
            {"StartTimeCycle", "cycle_1", 5, 12, {"RaiseEvent", "CreateMonster", 5}},
        },
        tbUnLockEvent = 
        {
            {"RaiseEvent", "RoundStepOver"},
        },
    },
    [6] = {nTime = 0  , nNum = 0,
        tbPrelock = {5},
        tbStartEvent = 
        {
            {"RaiseEvent", "RoundStep"},
        },
        tbUnLockEvent = 
        {

        },
    },
    [7] = {nTime = 20  , nNum = 0,
        tbPrelock = {6},
        tbStartEvent = 
        {
            {"SetShowTime", 7},
            {"SetFubenProgress", -1, "等待下一波敵人到來"},
            {"BlackMsg", "殺手即將出現，快找克制他們的同門師兄師姐幫忙！"}, 
        },
        tbUnLockEvent = 
        {

        },
    },
    [8] = {nTime = 0, nNum = 36,
        tbPrelock = {7},
        tbStartEvent = 
        {
            {"SetShowTime", 102},
            {"BlackMsg", "殺手出現在地圖的三個方向，保護張大俠！"},
            {"SetFubenProgress", -1, "保護張如夢（2/6）"},
            {"StartTimeCycle", "cycle_1", 5, 12, {"RaiseEvent", "CreateMonster", 8}},
        },
        tbUnLockEvent = 
        {
            {"RaiseEvent", "RoundStepOver"},
        },
    },
    [9] = {nTime = 0  , nNum = 0,
        tbPrelock = {8},
        tbStartEvent = 
        {
            {"RaiseEvent", "RoundStep"},
        },
        tbUnLockEvent = 
        {

        },
    },
    [10] = {nTime = 20  , nNum = 0,
        tbPrelock = {9},
        tbStartEvent = 
        {
            {"SetShowTime", 10},        
            {"SetFubenProgress", -1, "等待下一波敵人到來"},
            {"BlackMsg", "殺手即將出現，快找克制他們的同門師兄師姐幫忙！"},            
        },
        tbUnLockEvent = 
        {

        },
    },    
    [11] = {nTime = 0, nNum = 36,
        tbPrelock = {10},
        tbStartEvent = 
        {
            {"SetShowTime", 102},
            {"BlackMsg", "殺手出現在地圖的三個方向，保護張大俠！"},
            {"SetFubenProgress", -1, "保護張如夢（3/6）"},
            {"StartTimeCycle", "cycle_1", 5, 12, {"RaiseEvent", "CreateMonster", 11}},
        },
        tbUnLockEvent = 
        {
            {"RaiseEvent", "RoundStepOver"},
        },
    },
    [12] = {nTime = 0  , nNum = 0,
        tbPrelock = {11},
        tbStartEvent = 
        {
            {"RaiseEvent", "RoundStep"},
        },
        tbUnLockEvent = 
        {

        },
    },
    [13] = {nTime = 20  , nNum = 0,
        tbPrelock = {12},
        tbStartEvent = 
        {
            {"SetShowTime", 13},
            {"SetFubenProgress", -1, "等待下一波敵人到來"},
            {"BlackMsg", "殺手即將出現，快找克制他們的同門師兄師姐幫忙！"}, 
        },
        tbUnLockEvent = 
        {

        },
    },    
    [14] = {nTime = 0, nNum = 36,
        tbPrelock = {13},
        tbStartEvent = 
        {
            {"SetShowTime", 102},
            {"BlackMsg", "殺手出現在地圖的三個方向，保護張大俠！"},
            {"SetFubenProgress", -1, "保護張如夢（4/6）"},
            {"StartTimeCycle", "cycle_1", 5, 12, {"RaiseEvent", "CreateMonster", 14}},
        },
        tbUnLockEvent = 
        {
            {"RaiseEvent", "RoundStepOver"},
        },
    },
    [15] = {nTime = 0  , nNum = 0,
        tbPrelock = {14},
        tbStartEvent = 
        {
            {"RaiseEvent", "RoundStep"},
        },
        tbUnLockEvent = 
        {

        },
    },
    [16] = {nTime = 20  , nNum = 0,
        tbPrelock = {15},
        tbStartEvent = 
        {
            {"SetShowTime", 16},
            {"SetFubenProgress", -1, "等待下一波敵人到來"},
            {"BlackMsg", "殺手即將出現，快找克制他們的同門師兄師姐幫忙！"},             
        },
        tbUnLockEvent = 
        {

        },
    },    
    [17] = {nTime = 0, nNum = 36,
        tbPrelock = {16},
        tbStartEvent = 
        {
            {"SetShowTime", 102},
            {"BlackMsg", "殺手出現在地圖的三個方向，保護張大俠！"},
            {"SetFubenProgress", -1, "保護張如夢（5/6）"},
            {"StartTimeCycle", "cycle_1", 5, 12, {"RaiseEvent", "CreateMonster", 17}},
        },
        tbUnLockEvent = 
        {
            {"RaiseEvent", "RoundStepOver"},
        },
    },
    [18] = {nTime = 0  , nNum = 0,
        tbPrelock = {17},
        tbStartEvent = 
        {
            {"RaiseEvent", "RoundStep"},
        },
        tbUnLockEvent = 
        {

        },
    },
    [19] = {nTime = 20  , nNum = 0,
        tbPrelock = {18},
        tbStartEvent = 
        {
            {"SetShowTime", 19},        
            {"SetFubenProgress", -1, "等待下一波敵人到來"},
            {"BlackMsg", "殺手即將出現，快找克制他們的同門師兄師姐幫忙！"}, 
        },
        tbUnLockEvent = 
        {

        },
    },    
    [20] = {nTime = 0, nNum = 36,
        tbPrelock = {19},
        tbStartEvent = 
        {
            {"SetShowTime", 102},
            {"BlackMsg", "殺手出現在地圖的三個方向，保護張大俠！"},
            {"SetFubenProgress", -1, "保護張如夢（6/6）"},
            {"StartTimeCycle", "cycle_1", 5, 12, {"RaiseEvent", "CreateMonster", 20}},
        },
        tbUnLockEvent = 
        {

        },
    },
    [21] = {nTime = 10  , nNum = 0,
        tbPrelock = {20},
        tbStartEvent = 
        {
            {"SetShowTime", 21},
            {"BlackMsg", "經過一番浴血奮戰，終於成功擊退來犯之敵！"},        
            {"NpcBubbleTalk", "MingXiaNpc", "多謝兩位相助！虹兒，你我此生相守，再不分離！", 8, 2, 1},
            {"NpcBubbleTalk", "MingXiaBanLv", "多謝兩位，我與夢哥此生定不忘記此恩！", 8, 2, 1},
            {"RaiseEvent", "RoundStepOver"},
        },
        tbUnLockEvent = 
        {

        },
    },
    [70] = {nTime = 0  , nNum = 1,
        tbPrelock = {1},
        tbStartEvent = 
        {      

        },
        tbUnLockEvent = 
        {
            {"NpcBubbleTalk", "MingXiaNpc", "這些死士果然有些本事……諸位小心，只怕會是一場苦戰！", 8, 2, 1},
            {"NpcBubbleTalk", "MingXiaBanLv", "爹爹為山河社稷圖竟將五行死士派來了……", 8, 2, 1},
        },
    },  
    [71] = {nTime = 0  , nNum = 1,
        tbPrelock = {1},
        tbStartEvent = 
        {      

        },
        tbUnLockEvent = 
        {
            {"NpcBubbleTalk", "MingXiaNpc", "可恨……若非我氣力不加，又豈會被區區死士迫到如此狼狽！", 8, 2, 1},
            {"NpcBubbleTalk", "MingXiaBanLv", "夢哥！當心！你我光是招架都已極為勉強，莫要逞強！", 8, 2, 1},
        },
    },  
    [72] = {nTime = 0  , nNum = 1,
        tbPrelock = {1},
        tbStartEvent = 
        {      

        },
        tbUnLockEvent = 
        {
            {"NpcBubbleTalk", "MingXiaNpc", "虹兒！看來我等難以抵擋了，你速速離去吧……要好好活下去……", 8, 2, 1},
            {"NpcBubbleTalk", "MingXiaBanLv", "不！我們已經歷如此之多的苦楚，未到最後，你我豈能放棄？", 8, 2, 1},
        },
    },  
    [73] = {nTime = 0  , nNum = 1,
        tbPrelock = {1},
        tbStartEvent = 
        {      

        },
        tbUnLockEvent = 
        {
            {"NpcBubbleTalk", "MingXiaNpc", "可惡！眼前已漸漸模糊，難道我就要死在此處了嗎……虹兒……", 8, 2, 1},
            {"NpcBubbleTalk", "MingXiaBanLv", "夢哥，你放心，就算今日無法倖免，我也不讓你孤身一人……", 8, 2, 1},
        },
    },                
    [101] = {nTime = 10  , nNum = 0,
        tbPrelock = {21},
        tbStartEvent = 
        {
            {"SetShowTime", 101},
            {"SetFubenProgress", -1, "即將離開"}, 
        },
        tbUnLockEvent = 
        {
            {"GameWin"},
        },
    },
    [102] =  {nTime = 850  , nNum = 1,
        tbPrelock = {1},
        tbStartEvent = 
        {
            {"SetFubenProgress", -1, "即將離開"},
        },
        tbUnLockEvent = 
        {
            {"RaiseEvent", "ClearAllMonster"},
            {"BlackMsg", "可惡！殺手太過厲害！沒能守護好張如夢大俠！"},
            {"NpcBubbleTalk", "MingXiaBanLv", "夢哥！不！我的夢哥……罷了，我也隨你而去，與你黃泉相守……", 8, 2, 1},
            {"StartTimeCycle", "cycle_1", 5, 1, {"CastSkill", "MingXiaBanLv", 3, 1, -1, -1}},
        },
    },
    [103] =  {nTime = 10  , nNum = 0,
        tbPrelock = {102},
        tbStartEvent = 
        {
            {"SetFubenProgress", -1, "即將離開"},            
        },
        tbUnLockEvent = 
        {
            {"GameLost"},
        },
    },
}