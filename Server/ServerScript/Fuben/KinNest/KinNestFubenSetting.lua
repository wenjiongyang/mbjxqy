
local tbFubenSetting = {};
Fuben:SetFubenSetting(Kin.Def.nKinNestMapTemplateId, tbFubenSetting)        -- 绑定副本内容和地图

tbFubenSetting.nDuraTime                =  3600; -- 副本时长
tbFubenSetting.szFubenClass             = "KinNestFuben";                                   -- 副本类型
tbFubenSetting.szName                   = "俠客島"                                            -- 单纯的名字，后台输出或统计使用
tbFubenSetting.szNpcPointFile           = "Setting/Fuben/KinNestFuben/NpcPos.tab"           -- NPC点
tbFubenSetting.tbBeginPoint             = {3000, 3300}                                          -- 副本出生点
tbFubenSetting.nStartDir                = 40
tbFubenSetting.tbTempRevivePoint        = {3100, 3300}                                          -- 临时复活点，副本内有效，出副本则移除

-- ID可以随便 普通副本NPC数量 ；精英模式NPC数量
tbFubenSetting.NUM = 
{
    NpcIndex1       = {1, 4, 7, 10, 13, 16, 19, 22},
    NpcIndex2       = {2, 5, 8, 11, 14, 17, 20, 23},
    NpcIndex3       = {3, 6, 9, 12, 15, 18, 21, 24},
}

tbFubenSetting.ANIMATION = 
{

}

--{"RaiseEvent", "OnAddKinRobberNpc", nIndex, nLock, szGroup, szPointName, bRevive, nDir, nDealyTime, nEffectId, nEffectTime}, --添加剩余盗贼
--NPC模版ID，NPC等级，NPC五行；

tbFubenSetting.NPC = 
{
    [1] = {nTemplate = 655, nLevel = 35, nSeries = 1},  --大当家
    [2] = {nTemplate = 656, nLevel = 35, nSeries = 1},  --二当家
    [3] = {nTemplate = 657, nLevel = 35, nSeries = 1},  --三当家
    [4] = {nTemplate = 655, nLevel = 45, nSeries = 1},
    [5] = {nTemplate = 656, nLevel = 45, nSeries = 1},
    [6] = {nTemplate = 657, nLevel = 45, nSeries = 1},
    [7] = {nTemplate = 655, nLevel = 55, nSeries = 1},
    [8] = {nTemplate = 656, nLevel = 55, nSeries = 1},
    [9] = {nTemplate = 657, nLevel = 55, nSeries = 1},
    [10] = {nTemplate = 655, nLevel = 65, nSeries = 1},
    [11] = {nTemplate = 656, nLevel = 65, nSeries = 1},
    [12] = {nTemplate = 657, nLevel = 65, nSeries = 1},
    [13] = {nTemplate = 655, nLevel = 75, nSeries = 1},
    [14] = {nTemplate = 656, nLevel = 75, nSeries = 1},
    [15] = {nTemplate = 657, nLevel = 75, nSeries = 1},
    [16] = {nTemplate = 655, nLevel = 85, nSeries = 1},
    [17] = {nTemplate = 656, nLevel = 85, nSeries = 1},
    [18] = {nTemplate = 657, nLevel = 85, nSeries = 1},
    [19] = {nTemplate = 655, nLevel = 95, nSeries = 1},
    [20] = {nTemplate = 656, nLevel = 95, nSeries = 1},
    [21] = {nTemplate = 657, nLevel = 95, nSeries = 1},
    [22] = {nTemplate = 655, nLevel = 100, nSeries = 1},
    [23] = {nTemplate = 656, nLevel = 100, nSeries = 1},
    [24] = {nTemplate = 657, nLevel = 100, nSeries = 1},
    [25] = {nTemplate = 654, nLevel = 1, nSeries = 1},  --篝火
}

tbFubenSetting.LOCK = 
{
    -- 1号锁不能不填，默认1号为起始锁，nTime是到时间自动解锁，nNum表示需要解锁的次数，如填3表示需要被解锁3次才算真正解锁，可以配置字符串
    [1] = {nTime = 1, nNum = 0,
        --tbPrelock 前置锁，激活锁的必要条件{1 , 2, {3, 4}}，代表1和2号必须解锁，3和4任意解锁一个即可
        tbPrelock = {},
        --tbStartEvent 锁激活时的事件
        tbStartEvent = 
        {

        },
        --tbStartEvent 锁解开时的事件
        tbUnLockEvent = 
        {   
            {"RaiseEvent", "OpenOwnerInvitePanel"},
            {"ShowTaskDialog", 10006, false},
            --{"RaiseEvent","AddKinRobberNpc", 2},  --刷盗贼       
            {"BlackMsg", "此處確非俠客島！所幸在盜賊身上奪得線索！看看到底怎麼回事！"},            
        },
    },
    [2] = {nTime = 0, nNum = 1,
        tbPrelock = {1},
        tbStartEvent = 
        { 
            {"TrapUnlock", "TrapLock1", 2},        
            {"RaiseEvent", "AddKinRobberBoss", "NpcIndex1", 1, 3, "boss", "RobberBoss_1", false, 0 , 0, 9005, 0.5},               
        },
        tbUnLockEvent = 
        {
            --{"RaiseEvent","AddKinRobberNpc", 3},  
            {"NpcBubbleTalk", "NpcIndex1", "哈哈哈，蠢貨，你們中計了！竟然真的敢來這裡！受死吧！", 10, 2, 1},
            {"BlackMsg", "真有人竟然埋伏於此！雙拳難敵四手！結果了他！"},
        },
    },
    [3] = {nTime = 0, nNum = 1,
        tbPrelock = {2},
        tbStartEvent = 
        {               

        },
        tbUnLockEvent = 
        {
            --{"RaiseEvent","AddKinRobberNpc", 3},  
            {"BlackMsg", "此人武功高強，此處危險重重，得小心為上，往前走看看！"},
        },
    },    
    [4] = {nTime = 0, nNum = 1,
        tbPrelock = {3},
        tbStartEvent = 
        { 
            {"TrapUnlock", "TrapLock2", 4},        
            {"RaiseEvent", "AddKinRobberBoss", "NpcIndex2", 1, 5, "boss", "RobberBoss_2", false, 0 , 0, 9005, 0.5},               
        },
        tbUnLockEvent = 
        {
            --{"RaiseEvent","AddKinRobberNpc", 3},  
            {"NpcBubbleTalk", "NpcIndex2", "哼，我等誘你們前來，又故意不設防，為的就是將你們一網打盡！", 10, 2, 1},
            {"BlackMsg", "大言不慚！我們幫派弟兄配合默契，豈會怕你？"},
        },
    },
    [5] = {nTime = 0, nNum = 1,
        tbPrelock = {4},
        tbStartEvent = 
        {          

        },
        tbUnLockEvent = 
        {
            --{"RaiseEvent","AddKinRobberNpc", 4},
            {"BlackMsg", "這果然是個陷阱！線索竟然也只是引誘我們前來的工具！"},
        },
    },
    [6] = {nTime = 0, nNum = 1,
        tbPrelock = {5},
        tbStartEvent = 
        { 
            {"TrapUnlock", "TrapLock3", 6},        
            {"RaiseEvent", "AddKinRobberBoss", "NpcIndex3", 1, 7, "boss", "RobberBoss_3", false, 0 , 0, 9005, 0.5},               
            {"BlackMsg", "來吧，本尊在此處等著你們"},
        },
        tbUnLockEvent = 
        {
            --{"RaiseEvent","AddKinRobberNpc", 3},  
            {"NpcBubbleTalk", "NpcIndex3", "想不到你們倒有些本事，竟要我親自動手……", 10, 2, 1},
            {"StartTimeCycle", "cycle_1", 5, 1, {"NpcBubbleTalk", "NpcIndex3", "線索上的寶藏倒是真的，否則如何讓你們羊入虎口？可惜你們無福享受，受死吧！", 10, 2, 1}},
            {"BlackMsg", "哼，幕後黑手已經出現，這是最後一戰了！"},
        },
    },
    [7] = {nTime = 0, nNum = 1,
        tbPrelock = {6},
        tbStartEvent = 
        {

        },
        tbUnLockEvent =
        {   
            {"RaiseEvent","UpateKinNestUiBoss"},
            {"BlackMsg", "幕後黑手竟打算誘騙各大幫派前來一併消滅，真是狂妄自大！"},   
        },
    },
    [8] = {nTime = 3, nNum = 1,
        tbPrelock = {7},
        tbStartEvent = 
        { 

        },
        tbUnLockEvent = 
        {
            {"BlackMsg", "成功剿滅假冒俠客島的所有賊匪，篝火已點燃！"},
            {"RaiseEvent", "UpateKinNestUiFire"},
            {"AddNpc", 25, 1, 0, "Gouhuo", "Gouhuo"}, 
        },
    },
    [9] = {nTime = 60, nNum = 1,
        tbPrelock = {8},
        tbStartEvent = 
        { 

        },
        tbUnLockEvent = 
        {
            {"BlackMsg", "篝火已熄滅，大家可以離開俠客島了"},             
            {"DelNpc", "Gouhuo"},
            {"RaiseEvent", "LastRewards"},            
            --{"RaiseEvent","EndKinNest", "BackTrap", 73, 2570, 6550},
        },
    },
    [10] = {nTime = 3600, nNum = 0,
        tbPrelock = {1},
        tbStartEvent = 
        { 
            {"SetShowTime", 10},
        },
        tbUnLockEvent = 
        {
            {"BlackMsg", "可惡…沒能阻止幕後黑手的陰謀…"},   
            {"GameLost"},
        },
    },
}
