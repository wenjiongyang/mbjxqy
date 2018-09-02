
local tbFubenSetting = {};
local nMapTemplateId = 4007

Fuben:SetFubenSetting(nMapTemplateId, tbFubenSetting)   -- 绑定副本内容和地图

tbFubenSetting.szFubenClass 			= "HouseDefendFuben";
tbFubenSetting.szName 					= "家園守衛"											-- 单纯的名字，后台输出或统计使用
tbFubenSetting.szNpcPointFile 			= "Setting/Fuben/SpokespersonFuben/NpcPos.tab"			-- NPC点
tbFubenSetting.szPathFile 				= "Setting/Fuben/SpokespersonFuben/NpcPath.tab"			-- 寻路点

tbFubenSetting.tbBeginPoint   			= {2300, 18000}
tbFubenSetting.tbTempRevivePoint		= {2300, 18000}											--复活点  

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
    [1] = {nTemplate = 2403, nLevel = -1, nSeries = 0},  --小怪
    [2] = {nTemplate = 2404, nLevel = -1, nSeries = 0},  --小怪
    [3] = {nTemplate = 2405, nLevel = -1, nSeries = 0},  --精英
    [4] = {nTemplate = 2406, nLevel = -1, nSeries = 0},  --精英
    [5] = {nTemplate = 2402, nLevel = -1, nSeries = 0},  --篝火
    [6] = {nTemplate = 2328, nLevel = -1, nSeries = 0},  --林更新
    [7] = {nTemplate = 2329, nLevel = -1, nSeries = 0},  --赵丽颖
    [8] = {nTemplate = 74, nLevel = -1, nSeries = 0},  --气流
	[9] = {nTemplate = 2407, nLevel = -1, nSeries = 0},  --Boss
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
            {"SetKickOutToKinMapDelayTime", 10},

			{"SetPlayerDeathDoRevive", 0}
        },
        --tbStartEvent 锁解开时的事件
        tbUnLockEvent = 
        { 

        },
    },
    [2] = {nTime = 0, nNum = 1,
        tbPrelock = {1},
        tbStartEvent = 
        {
			{"TrapUnlock", "AddEnemy1", 2},

            {"OpenWindow", "LingJueFengLayerPanel", "Info", 3, 9, "新穎小築"},

            --说话
            {"PlayerBubbleTalk", "奇怪，怎麼這麼安靜？他們人呢？"},  

            {"SetFubenProgress", -1, "進入前庭看看"}, 
        },
            tbUnLockEvent = 
        { 

        },
    },     
    [3] = {nTime = 0, nNum = 8,
        tbPrelock = {2},
        tbStartEvent = 
        {
            --刷新小怪 
            {"AddNpc", 1, 8, 3, "Enemy1", "Home_Enemy_Pos_1", false, 39, 0, 0, 0},

            {"OpenWindow", "LingJueFengLayerPanel", "Info", 3, 9, "新穎小築"},

            --说话
            {"NpcBubbleTalk", "Enemy1", "嗯？這些人是他們請來的幫手？收拾他們！", 4, 1, 3},

            {"BlackMsg", "看來對方人手不少，先解決這些小嘍嘍！"},     

            {"SetFubenProgress", -1, "擊敗前庭的盜賊"}, 
        },
        tbUnLockEvent = 
        {
            {"BlackMsg", "左側庭院有一絲雜吵聲，去看看怎麼回事"},    

            {"SetFubenProgress", -1, "擊敗左側庭院的嘍囉"}, 
        },
    },
    [4] = {nTime = 0, nNum = 8,
        tbPrelock = {3},
        tbStartEvent = 
        {
            --第2波怪
            {"AddNpc", 2, 8, 4, "Enemy2", "Home_Enemy_Pos_2", false, 39, 0, 0, 0},

        },
        tbUnLockEvent = 
        {
            {"BlackMsg", "右側庭院有一絲雜吵聲，去看看怎麼回事"},    
            --刷新小怪 
            {"SetFubenProgress", -1, "擊敗右側庭院的賊匪"}, 
        },
    },
    [5] = {nTime = 0, nNum = 8,
        tbPrelock = {4},
        tbStartEvent = 
        {
            --第3波怪
            {"AddNpc", 3, 8, 5, "Enemy3", "Home_Enemy_Pos_3", false, 39, 0, 0, 0},
        },
        tbUnLockEvent = 
        {
            {"BlackMsg", "回前庭看看怎麼回事"},    
            --刷新小怪 
            {"SetFubenProgress", -1, "擊敗中庭的賊匪"}, 
        },
    },
    [6] = {nTime = 0, nNum = 8,
        tbPrelock = {5},
        tbStartEvent = 
        {
            --第4波怪
            {"AddNpc", 4, 8, 6, "Enemy4", "Home_Enemy_Pos_4", false, 39, 0, 0, 0},
        },
        tbUnLockEvent = 
        {
            {"AddNpc", 8, 1, 0, "Trap1", "Trap_Pos_1", false, 0, 0, 0, 0},
            {"AddNpc", 8, 1, 0, "Trap2", "Trap_Pos_2", false, 0, 0, 0, 0},

            {"ChangeTrap", "Out_sn", {1500, 6500}, nil, 1, 0, nil, nil},
            {"ChangeTrap", "Out_ty", {6000, 18000}, nil, 1, 0, nil, nil},

            {"SetFubenProgress", -1, "去屋內看看情況"}, 

            --设置新的复活点
            {"SetDynamicRevivePoint", 1800, 6500},
        },
    },       
    [7] = {nTime = 0, nNum = 8,
        tbPrelock = {6},
        tbStartEvent = 
        {
            --第5波怪
            {"AddNpc", 4, 8, 7, "Enemy5", "Home_Enemy_Pos_5", false, 39, 0, 0, 0},
        },
        tbUnLockEvent = 
        {

            {"SetFubenProgress", -1, "擊敗大堂中的頭目"}, 
        },
    },   
    [8] = {nTime = 0, nNum = 1,
        tbPrelock = {7},
        tbStartEvent = 
        {
            --第5波怪
            {"AddNpc", 9, 1, 8, "Boss1", "Home_Boss_Pos_1", false, 39, 0, 0, 0},
        },
        tbUnLockEvent = 
        {

            {"SetFubenProgress", -1, "享受溫暖的小屋爐火"}, 
        },
    },    
    [9] = {nTime =  70, nNum = 1,
        tbPrelock = {8},
        tbStartEvent = 
        {
            --刷新林更新，赵丽颖
            {"AddNpc", 6, 1, 0, "Daiyanren1", "Daiyanren1", false, 39, 0, 0, 0}, 
            {"AddNpc", 7, 1, 0, "Daiyanren1", "Daiyanren2", false, 39, 0, 0, 0}, 

            {"NpcBubbleTalk", "Daiyanren1", "多謝諸位俠士鼎力相助！特備小小爐火，還望諸位稍事休息！", 4, 1, 1},
            --刷新篝火
            {"SetShowTime", 9},
            {"RaiseEvent", "FinishFuben"},
            {"AddNpc", 5, 1, 0, "Gouhuo", "Gouhuo"}, 
        },
        tbUnLockEvent = 
        {
            {"SetFubenProgress", -1, "離開此處"}, 
            {"BlackMsg", "事情已經告一段落，可以離開了！"},
            {"GameWin"},
        },
    },
    [100] = {nTime = 3600, nNum = 0,
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