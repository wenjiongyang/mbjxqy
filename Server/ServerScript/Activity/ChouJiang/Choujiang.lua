local tbAct = Activity:GetClass("ChouJiang")
tbAct.szMainKey = "ChouJiang"

tbAct.tbTimerTrigger = 
{ 
    [1] = {szType = "Day", Time = ChouJiang.szDayTime , Trigger = "LotteryDay"},                -- 每日抽奖时间点
    [2] = {szType = "Day", Time = ChouJiang.szBigDayTime , Trigger = "LotteryBig"  },           -- 大奖时间点
    -- [3] = {szType = "Day", Time = "10:00" , Trigger = "SendWorldNotify"},           
    -- [4] = {szType = "Day", Time = "13:00" , Trigger = "SendWorldNotify"},          
    -- [5] = {szType = "Day", Time = "20:00" , Trigger = "SendWorldNotify"},           
}
-- , {"StartTimerTrigger", 3}, {"StartTimerTrigger", 4}, {"StartTimerTrigger", 5}
tbAct.tbTrigger = { 
					Init = {},
                    Start = {{"StartTimerTrigger", 1}, {"StartTimerTrigger", 2}},
                    LotteryDay = {},
                    LotteryBig = {},
                    End = {},
                    SendWorldNotify = { {"WorldMsg", "喜迎國慶日，幸運抽獎活動強力來襲，活躍度達[FFFE0D]60[-]以後去找[FFFE0D]襄陽納蘭真[-]領取獎券參加活動吧！", 1} },
                  }

tbAct.TYPE =
{
	BIG = 1, 							-- 大奖	
	DAY = 2, 							-- 每日抽奖
}

tbAct.nMaxVer = 10000 					-- 最大版本号

tbAct.tbTypeData = 
{
	[tbAct.TYPE.BIG] = {
		nMaxSaveCount = 3000; 			-- 每个table最多存的数据数量
		szBaseKey = "ChouJiangBig";		-- 存储Key
		nLimitCount = 1; 				-- 参加抽奖需要的次数,不配默认不限制
		tbAward = ChouJiang.tbBigAward;
		nNewInfomationValidTime = 24*60*60*3;                                                                     -- 最新消息过期时间
		szNewInfomationTitle = "元宵大抽獎結果";                                        -- 最新消息标题
        -- 大奖抽奖的天数(以活动开始时间做校准的天数，活动开始那一天算第一天)
        nLotteryDay = ChouJiang.nBigExecuteDay;                                                      
        -- szWorldNotifyHit = "“迎国庆幸运抽奖”大奖活动结果已产生，请前往“最新消息”相关页面查看中奖名单。";        -- 开奖世界消息
        nDefaultShowIdx = 3;                                                                                    -- 最新消息中默认显示的奖励索引
        szAvMailText = "恭喜你參加「元宵大抽獎」活動，獲得[FFFE0D]幸運獎[-]，請查收！";                   -- 纪念奖邮件内容
        szRankMailText = "恭喜你參加「元宵大抽獎」活動，獲得[FFFE0D]%s[-]，附件為獎勵，請查收！";       -- 排名奖励邮件内容,%s为奖励排名
        szMailTitle = "元宵大抽獎";                                                                                   -- 邮件标题
        bOpen = true;                                                                                           -- 是否开放(不开放的话数据也是不存的)
        tbAVAward = ChouJiang.tbBigAVAward;
        tbShowRank = {[1] = true,[2] = true,[3] = true,[4] = true};
	},
	[tbAct.TYPE.DAY] = {
		nMaxSaveCount = 3000; 		   
		szBaseKey = "ChouJiangDay";	
		tbAward = ChouJiang.tbDayAward;
		nNewInfomationValidTime = 24*60*60*3;
		szNewInfomationTitle = "新年抽獎結果";
        --szWorldNotifyHit = "今日“迎国庆幸运抽奖”活动结果已产生，请前往“最新消息”相关页面查看中奖名单。";              
        nDefaultShowIdx = 3;
        szAvMailText = "恭喜你參加「新年金雞抽獎」活動，獲得[FFFE0D]幸運獎[-]，請查收！不要忘記在[FFFE0D]2月11日元宵節[-]還有大獎等你，獎勵更豐厚，要記得來哦！";
        szRankMailText = "恭喜你參加「新年金雞抽獎」活動，獲得[FFFE0D]%s[-]，附件為獎勵，請查收！不要忘記在[FFFE0D]2月11日元宵節[-]還有大獎等你，獎勵更豐厚，要記得來哦！";
        szMailTitle = "新年金雞抽獎";
        tbExecuteDay = ChouJiang.tbExecuteDay;                                                                            -- 活动期间第几天抽奖
        bOpen = true;                                                                                          -- 是否开放
        tbAVAward = ChouJiang.tbDayAVAward;
        tbShowRank = {[1] = true,[2] = true,[3] = true};
	},
}

--[[
-- 基础信息存库
    local tbBaseData = {}
    tbBaseData.nActVer = nStartTime                         -- 活动版本号(活动表里配的开始时间,因此重开活动记得把之前活动的数据从Activity.tab中删掉)
    tbBaseData.nBigVer = 1                                  -- 大奖数据当前存储版本号
    tbBaseData.nDayVer = 1                                  -- 每日抽奖数据当前存储版本号

--存库（每日抽奖和大奖一样的数据结构）
    local tbData = {}
    tbData.tbPlayer[pPlayer.dwID] = 0                         -- 玩家对应的使用数量
    tbData.nCount = tbData.nCount + 1                         -- 当前版本已有的数据条数
    tbData.nVer = nVersion                                    -- 当前存库数据的版本号

-- 缓存
    tbAct._tbActData = 
{
    tbBigData = {
        tbPlayer[pPlayer.dwID] = {}
        tbPlayer[pPlayer.dwID].nVer = tbData.nVer                 -- 存库的版本
        tbPlayer[pPlayer.dwID].nCount = 0                         -- 使用数量    

    };
    tbDayData = {
        tbPlayer[pPlayer.dwID] = {}
        tbPlayer[pPlayer.dwID].nVer = tbData.nVer                 -- 存库的版本
        tbPlayer[pPlayer.dwID].nCount = 0                         -- 使用数量      
    };
}
----------
]]

function tbAct:GetCacheData(nType)
	if nType == tbAct.TYPE.BIG then
		return self._tbActData.tbBigData
	elseif nType == tbAct.TYPE.DAY then
		return self._tbActData.tbDayData
	end
end

function tbAct:OnTrigger(szTrigger)
    if szTrigger == "Init" then
        self:OnInit()
	elseif szTrigger == "Start" then
        self:InitCacheData()
		self:InitBaseData()
        --Activity:RegisterNpcDialog(self, 90, {Text = "领取迎国庆幸运奖券", Callback = self.GetChouJiang, Param = {self}})
        --Activity:RegisterPlayerEvent(self, "Act_UpdateChouJiangData", "UpdateChouJiangData")
        Activity:RegisterPlayerEvent(self, "Act_OnUseNewYearJiangQuan", "OnUseNewYearJiangQuan")
        Activity:RegisterPlayerEvent(self, "Act_OnPlayerLogin", "OnPlayerLogin")
        self:OnActStart()
        local nStartTime, nEndTime = self:GetOpenTimeInfo()
        Log("[ChouJiang] Start ================", os.date("%c",nStartTime), os.date("%c", nEndTime))
    elseif szTrigger == "End" then
    	 Log("[ChouJiang] End =================")
    elseif szTrigger == "LotteryDay" then
        self:LotteryDay()
    elseif szTrigger == "LotteryBig" then
        self:LotteryBig()
    end
    Log("[ChouJiang] OnTrigger:", szTrigger)
end

function tbAct:OnInit()
    local nStartTime = Activity:GetActBeginTime(self.szKeyName)
    local nEndTime = Activity:GetActEndTime(self.szKeyName)
    local tbChouJiangData = {nStartTime = nStartTime, nEndTime = nEndTime}
    NewInformation:AddInfomation(ChouJiang.szOpenNewInfomationKey,nEndTime, tbChouJiangData)
    Log("[ChouJiang] OnInit =================", os.date("%c",nStartTime), os.date("%c", nEndTime))
end

function tbAct:OnPlayerLogin()
    self:SynActData(me)
end

function tbAct:OnActStart()
    local tbPlayer = KPlayer.GetAllPlayer()
    for _, pPlayer in pairs(tbPlayer) do
        self:SynActData(pPlayer)
    end
end

function tbAct:SynActData(pPlayer)
    local nStartTime = Activity:GetActBeginTime(self.szKeyName)
    local nEndTime = Activity:GetActEndTime(self.szKeyName)
    pPlayer.CallClientScript("ChouJiang:OnSynActTime", nStartTime, nEndTime)
end

function tbAct:OnUseNewYearJiangQuan(pPlayer)
    local tbNewYearItem = Item:GetClass("NewYearJiangQuan")
    local nHave = pPlayer.GetItemCountInAllPos(tbNewYearItem.nNewYearJianQuanItemId); 
    if nHave < 1 then
        pPlayer.CenterMsg("沒有獎券",true)
        return
    end
    local nStartTime = Activity:GetActBeginTime(self.szKeyName)
    local nLastExeDay = ChouJiang:GetLastExeDay(nStartTime)
    local szLotteryDate = ChouJiang.tbDayLotteryDate[nLastExeDay]           -- nLastExeDay 有可能为0, 最后一个抽奖时间点过后的当天
    local nPassDay = ChouJiang:GetPassDay(nStartTime)
    -- 所有抽奖抽完
    if not szLotteryDate or nPassDay > nLastExeDay then
        pPlayer.CenterMsg("已經沒有抽獎活動",true)
        return
    end

    local tbItem = Item:GetClass("JiangQuan")
    local nNewYearStartTime = pPlayer.GetUserValue(tbItem.SAVE_GROUP, tbItem.KEY_NEW_YEAR_START_TIME);
    if nStartTime ~= nNewYearStartTime then
       pPlayer.SetUserValue(tbItem.SAVE_GROUP, tbItem.KEY_NEW_YEAR_USE_DAY, 0)
       pPlayer.SetUserValue(tbItem.SAVE_GROUP, tbItem.KEY_NEW_YEAR_START_TIME, nStartTime)
    end
    local nNewYearUseDay = pPlayer.GetUserValue(tbItem.SAVE_GROUP, tbItem.KEY_NEW_YEAR_USE_DAY);
    -- and nLastExeDay > nNewYearUseDay 每个阶段的抽奖只能使用一张奖券
    if nNewYearUseDay ~= nLastExeDay then
        local nConsume = pPlayer.ConsumeItemInAllPos(tbNewYearItem.nNewYearJianQuanItemId,1, Env.LogWay_ChouJiangDay);
        if nConsume < 1 then
           pPlayer.CenterMsg("扣除道具失敗", true)
           Log("[ChouJiang] OnUseNewYearJiangQuan fail ", pPlayer.szName,pPlayer.dwID, nNewYearUseDay, nLastExeDay, nPassDay, nStartTime)
           return
        end
        pPlayer.SetUserValue(tbItem.SAVE_GROUP, tbItem.KEY_NEW_YEAR_USE_DAY,nLastExeDay)
        self:UpdateChouJiangData(pPlayer)
        local szTip = "開獎時間" .. string.format("[FFFE0D]" ..szLotteryDate .."[-]") .."，別忘記[FFFE0D]2月11日元宵節[-]還有大獎等著你哦！"
        pPlayer.CenterMsg(szTip)
        pPlayer.Msg(szTip)
        pPlayer.CallClientScript("ChouJiang:OnUseNewYearJiangQuan")
        Log("[ChouJiang] OnUseNewYearJiangQuan ok ", pPlayer.szName, pPlayer.dwID, nNewYearUseDay, nLastExeDay, nPassDay, nStartTime)
    else
       pPlayer.CenterMsg("已經有抽獎資格", true)
    end
end

function tbAct:GetChouJiang()

	local bRet,szMsg = Item:GetClass("JiangQuan"):CheckCanGet(me)
	if not bRet then
		me.CenterMsg(szMsg)
		return
	end

	local szTimeOut = self:CalcValidDate()	
	local pItem = me.AddItem(Item:GetClass("JiangQuan").nTemplateId, 1, szTimeOut, Env.LogWay_JiangQuan)
    if not pItem then
        Log(debug.traceback())
        return
    end

    me.SetUserValue(Item:GetClass("JiangQuan").SAVE_GROUP, Item:GetClass("JiangQuan").KEY_GET_TIME,GetTime())
    me.CenterMsg(string.format("領取%s成功",pItem.szName))
    Log("[ChouJiang] GetChouJiang ",me.szName,me.dwID,szTimeOut)
end

function tbAct:CalcValidDate()

    local nNow = GetTime()
    local tbDate = os.date("*t", nNow)
    local nYear,nMonth,nDay,nHour,nMin,nSec
    nHour = tbDate.hour
    nMin = tbDate.min
    nSec = tbDate.sec

    local nOverdueTime = Item:GetClass("JiangQuan").nOverdueTime
    local nTimeOut = os.time{year=tbDate.year, month=tbDate.month, day=tbDate.day, hour=0, sec=0} + nOverdueTime
    
    if (nHour * 60 * 60 + nMin * 60 + nSec) > nOverdueTime then
        nTimeOut = nTimeOut + 24*60*60
    end


    local tbDate = os.date("*t", nTimeOut)
    nYear = tbDate.year
    nMonth = tbDate.month
    nDay = tbDate.day
    nHour = tbDate.hour
    nMin = tbDate.min
    nSec = tbDate.sec
    
    return string.format("%d-%02d-%02d-%02d-%02d-%02d", nYear, nMonth,nDay,nHour,nMin,nSec)
end

function tbAct:GetSavaData(nVersion,nType)
    if not nVersion or nVersion <= 0 or nVersion >= self.nMaxVer then
        Log("[ChouJiang] Error GetSavaData", nVersion);
        return;
    end
    local szKey = self.tbTypeData[nType].szBaseKey ..nVersion;
    ScriptData:AddDef(szKey);
    local tbData = ScriptData:GetValue(szKey);
    if tbData.nCount then
        return tbData;
    end
    tbData.nCount = 0;
    tbData.nVer   = nVersion;
    tbData.tbPlayer = {};
    Log("[ChouJiang] GetSavaData New",nVersion,nType)
    return tbData;
end

function tbAct:GetCanUseData(nType)
	if not nType or not self.tbTypeData[nType] then	
        Log("[ChouJiang] GetCanUseData no nType",nType)
		return
	end
	local nMaxSaveCount = self.tbTypeData[nType].nMaxSaveCount
    local tbBaseData = self:GetBaseData();
    local nCurVer,szVer = self:GetTypeVer(nType)
    if not nCurVer or not szVer then
        Log("[ChouJiang] GetCanUseData no ver",nType,nCurVer,szVer)
        return
    end
    for nV = nCurVer, self.nMaxVer - 1 do
        local tbChouJiangData = self:GetSavaData(nV,nType);
        if not tbChouJiangData then
            Log("[ChouJiang] GetCanUseData GetSavaData fail ",nType,nV)
            return;
        end

        if tbChouJiangData.nCount < nMaxSaveCount then
            tbBaseData[szVer] = nV;
            return tbChouJiangData;
        end    
    end
end

function tbAct:GetBaseData()
	return ScriptData:GetValue("ChouJiangBase")
end

function tbAct:InitCacheData()
    --缓存数据结构
    tbAct._tbActData = 
    {
        tbBigData = {};
        tbDayData = {};
    }
----
end

function tbAct:InitBaseData()
	local nStartTime = Activity:GetActBeginTime(self.szKeyName)
	if nStartTime == 0 then
		Log("[ChouJiang] InitBaseData fail")
		return
	end
	local tbBaseData = self:GetBaseData()
	if not tbBaseData.nActVer or tbBaseData.nActVer ~= nStartTime then
		tbBaseData.nActVer = nStartTime 						-- 活动版本号
		tbBaseData.nBigVer = 1 									-- 大奖数据存储版本号
		tbBaseData.nDayVer = 1 									-- 每日抽奖数据存储版本号
	    tbBaseData.tbHitPlayer = {}                             -- 中过每日奖的玩家
        tbBaseData.tbHitBigPlayer = {}                          -- 中过大奖的玩家
        tbBaseData.tbNoRankPlayer = {}                          -- 不能参加每日排名抽奖的玩家
        tbBaseData.tbNoBigRankPlayer = {}                       -- 不能参加大奖排名抽奖的玩家
        ScriptData:AddModifyFlag("ChouJiangBase")
    	self:ClearData() 										-- 清空数据(存库和缓存)
		Log("[ChouJiang] InitBaseData reset ok!" , nStartTime)
	end

    -- 将存库数据整理写进缓存
	for _,nType in pairs(tbAct.TYPE) do
        if not self:IsForbid(nType) then
        	local tbCacheData = self:GetCacheData(nType)
        	if tbCacheData then
        		for nV = 1, self.nMaxVer - 1 do
        	        local tbData = self:GetSavaData(nV,nType);
        	      	if not tbData or tbData.nCount == 0 then
        	            break;
        	        end
        	        if tbData.tbPlayer then
        	        	for dwID,nCount in pairs(tbData.tbPlayer) do
        	        		tbCacheData.tbPlayer = tbCacheData.tbPlayer or {}
                            -- 不同的切页不可能有同一玩家的数据
        	        		tbCacheData.tbPlayer[dwID] = {}
        	        		tbCacheData.tbPlayer[dwID].nVer = nV
        	        		tbCacheData.tbPlayer[dwID].nCount = nCount
        	        	end
        	        	Log("[ChouJiang] InitBaseData combine data",nType,nV)
        	        end
        	    end
    	    else
    	   	   Log("[ChouJiang] InitBaseData no tbCacheData",nType)
    	    end
        end
	end
end

function tbAct:IsForbid(nType)
    local bOpen = false
    local tbTypeData = self.tbTypeData[nType]
    if tbTypeData and tbTypeData.bOpen then
        bOpen = true
    end
    return not bOpen
end

function tbAct:UpdateChouJiangData(pPlayer,nCount)
	-- 多个数据表不可能有同一个玩家的数据
    -- 缓存中记录玩家存库版本就是为了防止这种冗余情况
	for _,nType in pairs(tbAct.TYPE) do
        if not self:IsForbid(nType) then            -- 大奖屏蔽
    		local tbCacheData = self:GetCacheData(nType)
    		tbCacheData.tbPlayer = tbCacheData.tbPlayer or {}
    		local tbData
            local bFirst
    		-- 新数据才申请ScritData
    		if not tbCacheData.tbPlayer[pPlayer.dwID] then
    			tbData = self:GetCanUseData(nType)
                if not tbData then
                    Log("[ChouJiang] UpdateChouJiangData GetCanUseData nil", pPlayer.dwID, pPlayer.szName, nCount or -1)
                    return
                end
    			tbCacheData.tbPlayer[pPlayer.dwID] = {}
        		tbCacheData.tbPlayer[pPlayer.dwID].nVer = tbData.nVer                 -- 存库的版本
        		tbCacheData.tbPlayer[pPlayer.dwID].nCount = 0             
                bFirst = true
    		end
    		-- 已存在的数据拿版本数据
    		tbData = self:GetSavaData(tbCacheData.tbPlayer[pPlayer.dwID].nVer,nType)
    		if not tbData then
    			Log("[ChouJiang] UpdateChouJiangData GetSavaData nil", pPlayer.dwID, pPlayer.szName, nCount or -1, tbCacheData.tbPlayer[pPlayer.dwID].nVer)
    			return
    		end
    		if not tbData.tbPlayer[pPlayer.dwID] then
    			tbData.tbPlayer[pPlayer.dwID] = 0                         -- 玩家存库使用数量
    			tbData.nCount = tbData.nCount + 1                         -- 当前版本已有的数据条数
    		end
            if nCount then
                tbData.tbPlayer[pPlayer.dwID] = tbData.tbPlayer[pPlayer.dwID] + nCount
                tbCacheData.tbPlayer[pPlayer.dwID].nCount = tbCacheData.tbPlayer[pPlayer.dwID].nCount + nCount    -- 玩家缓存使用数量
                tbCacheData.nCount = (tbCacheData.nCount or 0) + nCount                                           -- 所有玩家缓存使用数量 
            else
                -- 不传数量无论使用多少次强制数量为 1(大奖数据也强制为1？待确定)
                tbData.tbPlayer[pPlayer.dwID] = 1
                tbCacheData.tbPlayer[pPlayer.dwID].nCount = 1
                if bFirst then
                    tbCacheData.nCount = (tbCacheData.nCount or 0) + 1                                           -- 所有玩家缓存使用数量 
                end
            end

    		ScriptData:AddModifyFlag(self.tbTypeData[nType].szBaseKey ..tbData.nVer)

            local bRank
            if Forbid:IsForbidAward(pPlayer) or pPlayer.GetMoneyDebt("Gold") > 0 then
                bRank = true
            end

            self:UpdateNoRankPlayer(nType, pPlayer.dwID, bRank)
    		Log("[ChouJiang] UpdateChouJiangData ", nType, pPlayer.dwID, pPlayer.szName, nCount, tbCacheData.tbPlayer[pPlayer.dwID].nVer, bRank and 1 or 0)
        end
	end
end

function tbAct:UpdateNoRankPlayer(nType, dwID, bRank)
    local tbBaseData = self:GetBaseData()
    local tbNoRankPlayer = nType == self.TYPE.BIG and tbBaseData.tbNoBigRankPlayer or tbBaseData.tbNoRankPlayer
    tbNoRankPlayer[dwID] = bRank
    ScriptData:AddModifyFlag("ChouJiangBase")
end

function tbAct:IsNoRankPlayer(nType, dwID)
    local tbBaseData = self:GetBaseData()
    local tbNoRankPlayer = nType == self.TYPE.BIG and tbBaseData.tbNoBigRankPlayer or tbBaseData.tbNoRankPlayer
    return tbNoRankPlayer[dwID]
end

function tbAct:ClearData()
	self:ClearBigData()
	self:ClearDayData()
end

function tbAct:ClearBigData()
	for nV = 1, self.nMaxVer - 1 do
        local tbData = self:GetSavaData(nV,self.TYPE.BIG);
      	if not tbData or tbData.nCount == 0 then
            break;
        end
        tbData.nCount = 0
        tbData.tbPlayer = {}
        ScriptData:AddModifyFlag(self.tbTypeData[tbAct.TYPE.BIG].szBaseKey ..nV)
        Log("[ChouJiang] ClearBigData ok",nV)
     end

     local tbDayCacheData = self:GetCacheData(tbAct.TYPE.BIG)
     tbDayCacheData.nCount = 0
     tbDayCacheData.tbPlayer = {}

     local tbBaseData = self:GetBaseData()
     tbBaseData.nBigVer = 1                 -- 重置当前使用的存库版本
end

function tbAct:ClearDayData()
	for nV = 1, self.nMaxVer - 1 do
        local tbData = self:GetSavaData(nV,self.TYPE.DAY);
      	if not tbData or tbData.nCount == 0 then
            break;
        end
        tbData.nCount = 0
        tbData.tbPlayer = {}
        ScriptData:AddModifyFlag(self.tbTypeData[tbAct.TYPE.DAY].szBaseKey ..nV)
        Log("[ChouJiang] ClearDayData ok",nV)
     end

     local tbDayCacheData = self:GetCacheData(tbAct.TYPE.DAY)
     tbDayCacheData.nCount = 0
     tbDayCacheData.tbPlayer = {}

     local tbBaseData = self:GetBaseData()
     tbBaseData.nDayVer = 1             -- 重置当前使用的存库版本
end

-- 返回当前数据类型的版本号
function tbAct:GetTypeVer(nType)
	local tbBaseData = self:GetBaseData();
	if nType == tbAct.TYPE.BIG then
		return tbBaseData.nBigVer,"nBigVer"
	elseif nType == tbAct.TYPE.DAY then
		return tbBaseData.nDayVer,"nDayVer"
	end
end
--------------------------------------------------------------------
-- 下一个抽奖天数
function tbAct:GetLastExecuteDay(nType)
    local nLastExeDay = 0
    local tbTypeData = self.tbTypeData[nType]
    if not tbTypeData then
        Log("[ChouJiang] fnGetLastExecuteDay no tbTypeData ", nType or -1)
        return nLastExeDay
    end

    local tbExecuteDay = tbTypeData.tbExecuteDay
    if not tbExecuteDay then
        Log("[ChouJiang] fnGetLastExecuteDay no tbExecuteDay ", nType or -1)
        return nLastExeDay
    end
    -- 不能用实际的开启时间来算，要用表里配的开启时间来算
    local nStartTime = Activity:GetActBeginTime(self.szKeyName)
    local nPassDay = ChouJiang:GetPassDay(nStartTime)
    if nPassDay < 0 then
        return nLastExeDay
    end
    for _,nExecuteDay in ipairs(tbExecuteDay) do
        nLastExeDay = nExecuteDay
        if nPassDay <= nExecuteDay then
            break
        end
    end

    return nLastExeDay
end


function tbAct:GetPassDay()
    local nPassDay = -1
    local nStartTime = Activity:GetActBeginTime(self.szKeyName)
    if nStartTime == 0 then
        Log("[ChouJiang] LotteryBig nStartTime 0 !", nType)
        return nPassDay
    end
    local nNowDay = Lib:GetLocalDay()
    local nStartDay = Lib:GetLocalDay(nStartTime)
    local nPassDay = nNowDay - nStartDay + 1                        -- 活动第几天
    return nPassDay
end

-- 是否抽奖（不是大奖）
function tbAct:CheckLotteryDay()
    local nStartTime = Activity:GetActBeginTime(self.szKeyName)
    local nPassDay = ChouJiang:GetPassDay(nStartTime)
    local nLastExeDay = self:GetLastExecuteDay(tbAct.TYPE.DAY)
    Log(string.format("[ChouJiang] fnCheckLotteryDay ExeDay %s, PassDay %s ", nLastExeDay or "nil", nPassDay or "nil"))
    return nPassDay == nLastExeDay
end
--------------------------------------------------------------------

function tbAct:LotteryDay()
    Log("[ChouJiang] LotteryDay execute start!")
    if self:CheckLotteryDay() then
        self:Lottery(tbAct.TYPE.DAY)
    else
        Log("[ChouJiang] LotteryDay not exe day!")
    end
    
    Log("[ChouJiang] LotteryDay execute end!")
end

function tbAct:LotteryBig()
    Log("[ChouJiang] LotteryBig execute start!")
    local nStartTime = Activity:GetActBeginTime(self.szKeyName)
    if nStartTime == 0 then
        Log("[ChouJiang] LotteryBig nStartTime 0 !")
        return
    end
    local tbTypeData = self.tbTypeData[tbAct.TYPE.BIG]
    if not tbTypeData or not tbTypeData.nLotteryDay then
        Log("[ChouJiang] LotteryBig no tbTypeData or nLotteryDay",tbTypeData and tbTypeData.nLotteryDay or -1)
        return
    end
    local nPassDay = ChouJiang:GetPassDay(nStartTime)
    if nPassDay == tbTypeData.nLotteryDay then
       self:Lottery(tbAct.TYPE.BIG)
       Log("[ChouJiang] LotteryBig hit", nPassDay, nStartTime, tbTypeData.nLotteryDay)
    else
        Log("[ChouJiang] LotteryBig hit no", nPassDay, nStartTime, tbTypeData.nLotteryDay)
    end
   Log("[ChouJiang] LotteryBig execute end!", nPassDay, nStartTime, tbTypeData.nLotteryDay)
end

function tbAct:CheckIsGet(dwID, nRank, nType)
    local tbBaseData = self:GetBaseData();
    local tbPlayer = nType == tbAct.TYPE.BIG and tbBaseData.tbHitBigPlayer or tbBaseData.tbHitPlayer
    return tbPlayer[dwID] and tbPlayer[dwID][nRank]
end

-- 抽奖
function tbAct:Lottery(nType)
    if not ChouJiang.bOpen then
        return
    end
    if self:IsForbid(nType) then
        Log("[ChouJiang] try lottery forbid type ", nType)
        return
    end
    local tbTypeData = self.tbTypeData[nType]
    if not tbTypeData then
    	Log("[ChouJiang] Lottery no tbTypeData ",nType)
    	return
    end
     local tbAwardData = ChouJiang:GetAwardSetting(tbTypeData.tbAward)
     if not tbAwardData then
        Log("[ChouJiang] Lottery no tbAward",nType)
        return
    end

    local tbShowRank = tbTypeData.tbShowRank
    -- 所有玩家
    local tbHouXuan = {}
    tbHouXuan.tbPlayer = {}
    tbHouXuan.nAllCount = 0
    tbHouXuan.nCount = 0
    -- 所有中奖玩家
    local tbHit = {}

    -- 所有拥有排名资格的玩家
    local tbRankHouXuan = {}

    -- 所有大号的池子
    local tbBigHouXuan = {}
    tbBigHouXuan.nAllCount = 0
    tbBigHouXuan.nCount = 0
    tbBigHouXuan.tbPlayer = {}

    -- 整合所有切表的数据,以及将玩家分类管理
    for nV = 1, self.nMaxVer - 1 do
        local tbData = self:GetSavaData(nV,nType);
      	if not tbData or tbData.nCount == 0 then
      		Log("[ChouJiang] Lottery end version ",nV,nType)
            break;
        end
        if tbData.tbPlayer then
        	for dwID,nCount in pairs(tbData.tbPlayer) do
                local bLimitCount = false
                if tbTypeData.nLimitCount and nCount < tbTypeData.nLimitCount then
                    bLimitCount = true
                    Log("[ChouJiang] Lottery player no match ",dwID ,nCount, nType)
                end
        		local pPlayerInfo = KPlayer.GetPlayerObjById(dwID) or KPlayer.GetRoleStayInfo(dwID);
        		if pPlayerInfo and not bLimitCount then
                    local bSmall = MarketStall:CheckIsLimitPlayer({nLevel = pPlayerInfo.nLevel or 0,GetVipLevel = function() return pPlayerInfo.nVipLevel or 0 end})
                    -- 初始化所有排名玩家池子
                    for nRank,tbInfo in ipairs(tbAwardData) do
                         -- 没有领过排名奖励 & 不是小号
                        if not self:CheckIsGet(dwID,nRank,nType) and not bSmall and not self:IsNoRankPlayer(nType, dwID) then
                            -- 排名奖励候选人池子
                            tbRankHouXuan[nRank] = tbRankHouXuan[nRank] or {}
                            tbRankHouXuan[nRank].tbPlayer = tbRankHouXuan[nRank].tbPlayer or {}
                            tbRankHouXuan[nRank].tbPlayer[dwID] = tbRankHouXuan[nRank].tbPlayer[dwID] and (tbRankHouXuan[nRank].tbPlayer[dwID] + nCount) or nCount
                            tbRankHouXuan[nRank].nAllCount = tbRankHouXuan[nRank].nAllCount and (tbRankHouXuan[nRank].nAllCount + nCount) or nCount
                            tbRankHouXuan[nRank].nCount = tbRankHouXuan[nRank].nCount and (tbRankHouXuan[nRank].nCount + 1) or 1        -- 多少候选人
                        end
                    end
                    -- 所有大号的池子,发纪念奖的时候用到
                    if not bSmall then
                        tbBigHouXuan.tbPlayer = tbBigHouXuan.tbPlayer or {}
                        tbBigHouXuan.tbPlayer[dwID] = tbBigHouXuan.tbPlayer[dwID] and (tbBigHouXuan.tbPlayer[dwID] + nCount) or nCount
                        tbBigHouXuan.nAllCount = tbBigHouXuan.nAllCount and (tbBigHouXuan.nAllCount + nCount) or nCount
                        tbBigHouXuan.nCount = tbBigHouXuan.nCount and (tbBigHouXuan.nCount + 1) or 1
                    end
                    -- 初始化所有玩家池子
    				tbHouXuan.tbPlayer = tbHouXuan.tbPlayer or {}
    				tbHouXuan.tbPlayer[dwID] = tbHouXuan.tbPlayer[dwID] and (tbHouXuan.tbPlayer[dwID] + nCount) or nCount
    				tbHouXuan.nAllCount = tbHouXuan.nAllCount and (tbHouXuan.nAllCount + nCount) or nCount
                    tbHouXuan.nCount = tbHouXuan.nCount and (tbHouXuan.nCount + 1) or 1
        		else
        			Log("[ChouJiang] Lottery no pPlayerInfo", dwID, nCount)
        		end
        	end
        end
    end

    if not next(tbHouXuan.tbPlayer) then	
    	Log("[ChouJiang] Lottery no player",nType)
    end

    local szTitle = tbTypeData.szMailTitle or "抽獎"
    local nLogWay = nType == tbAct.TYPE.BIG and Env.LogWay_ChouJiangBig or Env.LogWay_ChouJiangDay
--    开始抽排名奖励
    for nRank,tbInfo in ipairs(tbAwardData) do
        local szRank = ChouJiang:GetRankDes(nRank)
        local szRankText = string.format(tbTypeData.szRankMailText or "恭喜你參加抽獎活動，獲得[FFFE0D]%s[-]，附件為獎勵請查收！",szRank)
        if tbShowRank[nRank] then
            tbHit[nRank] = tbHit[nRank] or {}
        end
        for _,tbAwardInfo in ipairs(tbInfo) do
            local bSmall = tbAwardInfo[3]
            local tbRankData = tbRankHouXuan[nRank]
            if tbRankData then
                local nNum = tbAwardInfo[1]
                local tbAward = tbAwardInfo[2]
                for i=1,nNum do
                    -- 没有候选人
                    if tbRankData.nCount <= 0 then
                        break
                    end
                    local nRandom = MathRandom(tbRankData.nAllCount);
                    Log("[ChouJiang] Lottery start ",nRandom,tbRankData.nAllCount,nNum)
                    local nHitID = nil;
                    local nHitCount = 0
                    for dwID, nCount in pairs(tbRankData.tbPlayer) do
                        nHitID = dwID
                        nHitCount = nCount
                        if nRandom <= 0 then
                            break;
                        end
                        nRandom = nRandom - nCount;
                    end
                    if nHitID then
                        local tbMail = {
                            To = nHitID;
                            Title = szTitle;
                            From = "系統";
                            Text = szRankText;
                            tbAttach = tbAward;
                            nLogReazon = nLogWay;
                        }; 
                        Mail:SendSystemMail(tbMail);

                        -- 记录玩家获奖信息
                        local tbBaseData = self:GetBaseData();

                        if nType == tbAct.TYPE.BIG then
                            tbBaseData.tbHitBigPlayer[nHitID] = tbBaseData.tbHitBigPlayer[nHitID] or {}
                            tbBaseData.tbHitBigPlayer[nHitID][nRank] = true
                        else
                            tbBaseData.tbHitPlayer[nHitID] = tbBaseData.tbHitPlayer[nHitID] or {}
                            tbBaseData.tbHitPlayer[nHitID][nRank] = true

                            -- 统计互斥排名奖励
                            if ChouJiang.tbDayRejectRank[nRank] then
                                for _,nRejectRank in ipairs(ChouJiang.tbDayRejectRank[nRank]) do
                                     tbBaseData.tbHitPlayer[nHitID][nRejectRank] = true
                                end
                            end
                        end
                        if tbHit[nRank] then
                           tbHit[nRank][nHitID] = tbAward
                        end
                       
                        if tbRankHouXuan[nRank] and tbRankHouXuan[nRank].tbPlayer then
                            if tbRankHouXuan[nRank].tbPlayer[nHitID] then
                                tbRankHouXuan[nRank].nCount = tbRankData.nCount - 1
                                tbRankHouXuan[nRank].nAllCount = tbRankData.nAllCount - nHitCount
                                tbRankHouXuan[nRank].tbPlayer[nHitID] = nil
                            end
                        end
                        
                        -- 删除当前排名玩家名额
                        -- tbRankData.nCount = tbRankData.nCount - 1
                        -- tbRankData.nAllCount = tbRankData.nAllCount - nHitCount
                        -- tbRankData.tbPlayer[nHitID] = nil

                        -- 删除所有玩家名额
                        if tbHouXuan.tbPlayer[nHitID] then
                            tbHouXuan.nCount = tbHouXuan.nCount - 1
                            tbHouXuan.nAllCount = tbHouXuan.nAllCount - nHitCount
                            tbHouXuan.tbPlayer[nHitID] = nil
                        else
                            Log("[ChouJiang] Lottery del tbHouXuan err", nRank, nType, nHitID, nHitCount, nType)
                        end

                        -- 删除大号玩家名额
                        if tbBigHouXuan.tbPlayer[nHitID] then
                            tbBigHouXuan.nCount = tbBigHouXuan.nCount - 1
                            tbBigHouXuan.nAllCount = tbBigHouXuan.nAllCount - nHitCount
                            tbBigHouXuan.tbPlayer[nHitID] = nil
                        end

                        -- 删除其他排名玩家名额
                        local tbIdx = tbAwardInfo[4]

                        if tbIdx then
                            for _,nR in ipairs(tbIdx) do
                                if tbRankHouXuan[nR] and tbRankHouXuan[nR].tbPlayer[nHitID] then
                                    tbRankHouXuan[nR].nCount = tbRankHouXuan[nR].nCount - 1
                                    tbRankHouXuan[nR].nAllCount = tbRankHouXuan[nR].nAllCount - tbRankHouXuan[nR].tbPlayer[nHitID]
                                    tbRankHouXuan[nR].tbPlayer[nHitID] = nil
                                end
                            end
                        else
                            Log("[ChouJiang] Lottery del other rank info err", nRank, nType, nHitID, nHitCount, nRandom, tbHouXuan.nAllCount, tbRankData.nAllCount)
                        end

                        local bWorldTip = tbAwardInfo[5]
                        local bKinTip = tbAwardInfo[6]
                        if bWorldTip then
                            Lib:CallBack({self.SendWorldTip, self, nHitID, nRank, nType});
                        end

                        if bKinTip then
                            Lib:CallBack({self.SendKinTip, self, nHitID, nRank, nType});
                        end
                        Log("[ChouJiang] Lottery hit ok", nRank, nType, nHitID, nHitCount, nRandom, tbHouXuan.nAllCount, tbRankData.nAllCount)
                    else
                        Log("[ChouJiang] Lottery hit fail", nRank, nType)
                    end
                end
            else
                Log("[ChouJiang] Lottery no rank tbPlayer", nRank, nType)
            end
        end
    end

    local tbAVAward = ChouJiang:GetAwardSetting(tbTypeData.tbAVAward)
    if tbAVAward and next(tbHouXuan.tbPlayer) and next(tbAVAward) then
        --开始发纪念奖
        local tbBigAward = {}
        local tbNormalAward = {}
        for i,tbInfo in ipairs(tbAVAward) do
           if tbInfo[3] then
                table.insert(tbBigAward,tbInfo)
            else
                table.insert(tbNormalAward,tbInfo)
            end
        end
    
        local tbBigPlayer = {}

        if tbBigHouXuan.tbPlayer then
            for dwID,nCount in pairs(tbBigHouXuan.tbPlayer) do
                table.insert(tbBigPlayer,dwID)
            end
            Lib:SmashTable(tbBigPlayer)
        end
        local szAVText = tbTypeData.szAvMailText or "抽獎活動幸運獎"
        -- 先随大号
        local nSendBig = 0              -- 实际发了几个大号

        if next(tbBigPlayer) then
            for _,tbInfo in ipairs(tbBigAward) do
                local nRate = tbInfo[1]
                local tbAward = tbInfo[2]
                local nSend = math.floor(tbHouXuan.nCount*nRate)        -- 想要发几个大号
                for i=#tbBigPlayer,1,-1 do
                    local dwID = tbBigPlayer[i]
                    if nSend > 0 then
                        local tbMail = {
                            To = dwID;
                            Title = szTitle;
                            From = "系統";
                            Text = szAVText;
                            tbAttach = tbAward;
                            nLogReazon = nLogWay;
                        }; 
                        Mail:SendSystemMail(tbMail);
                        nSend = nSend - 1
                        nSendBig = nSendBig + 1
                        tbHouXuan.tbPlayer[dwID] = nil
                        tbBigPlayer[i] = nil
                        Log("[ChouJiang] Lottery Send Big", dwID, nSend, nRate)
                    else
                        break;
                    end
                end
            end
        end
        local tbNormalPlayer = {}

        if tbHouXuan.tbPlayer then
            for dwID,nCount in pairs(tbHouXuan.tbPlayer) do
                table.insert(tbNormalPlayer,dwID)
            end
            Lib:SmashTable(tbNormalPlayer)
        end

        if next(tbNormalPlayer) then
            -- 再发剩下的奖励
            local nSendNormal = tbHouXuan.nCount - nSendBig > 0 and tbHouXuan.nCount - nSendBig or 0
            for _,tbInfo in ipairs(tbNormalAward) do
                local nRate = tbInfo[1]
                local tbAward = tbInfo[2]
                local nSend = math.floor(tbHouXuan.nCount*nRate)        -- 想要发几个
                for i=#tbNormalPlayer,1,-1 do
                    local dwID = tbNormalPlayer[i]
                    if nSend > 0 then
                        local tbMail = {
                            To = dwID;
                            Title = szTitle;
                            From = "系統";
                            Text = szAVText;
                            tbAttach = tbAward;
                            nLogReazon = nLogWay;
                        }; 
                        Mail:SendSystemMail(tbMail);
                        nSendNormal = nSendNormal - 1
                        tbHouXuan.tbPlayer[dwID] = nil
                        tbNormalPlayer[i] = nil
                        nSend = nSend - 1
                        Log("[ChouJiang] Lottery Send normal", dwID, nSend, nRate)
                    else
                        break
                    end
                end
            end
        end

        -- 把剩下的人发了
        local tbDefaultAward = tbNormalAward[1][2]
        if tbDefaultAward then
            for dwID,_ in pairs(tbHouXuan.tbPlayer) do
                local tbMail = {
                    To = dwID;
                    Title = szTitle;
                    From = "系統";
                    Text = szAVText;
                    tbAttach = tbDefaultAward;
                    nLogReazon = nLogWay;
                }; 
                Mail:SendSystemMail(tbMail);
                Log("[ChouJiang] Lottery Send default", dwID)
            end
        end
    end
    
    if nType == tbAct.TYPE.DAY then
    	self:ClearDayData()
    elseif nType == tbAct.TYPE.BIG then
        self:ClearBigData()
    end

    local tbNewInfoData = {}
    tbNewInfoData.nType = nType
    tbNewInfoData.tbRankData = {}
    for nRank,tbInfo in pairs(tbHit) do
        tbNewInfoData.tbRankData[nRank] = tbNewInfoData.tbRankData[nRank] or {}
        for dwID,tbAward in pairs(tbInfo) do
            local pPlayerInfo = KPlayer.GetPlayerObjById(dwID) or KPlayer.GetRoleStayInfo(dwID)
            if pPlayerInfo then
                local tbInfo = {}
                local tbPlayerInfo = {}
                local pKinData = Kin:GetKinById(pPlayerInfo.dwKinId or 0) or {};
                tbPlayerInfo.szKinName = pKinData.szName or ""
                tbPlayerInfo.szName = pPlayerInfo.szName or XT("無")
                tbInfo.tbPlayerInfo = tbPlayerInfo
                tbInfo.tbAward = tbAward
                table.insert(tbNewInfoData.tbRankData[nRank],tbInfo)
            end
        end
    end

    if tbTypeData.nNewInfomationValidTime then
       NewInformation:AddInfomation(ChouJiang.szHitNewInfomationKey,GetTime() + tbTypeData.nNewInfomationValidTime, tbNewInfoData)
    end

    local szContent = tbTypeData.szWorldNotifyHit
    if szContent then
       KPlayer.SendWorldNotify(1, 999, szContent, ChatMgr.ChannelType.Public, 1);
    end

    ScriptData:AddModifyFlag("ChouJiangBase")
end

function tbAct:SendWorldTip(dwID, nRank, nType)
    if not dwID or not nRank or not nType then
        return 
    end
    local pPlayerInfo = KPlayer.GetPlayerObjById(dwID) or KPlayer.GetRoleStayInfo(dwID)
    local szName = pPlayerInfo and pPlayerInfo.szName
    if szName then
        local szType = (nType and nType == tbAct.TYPE.DAY) and "新年金雞抽獎" or "元宵大抽獎"
        local szRank = ChouJiang:GetRankDes(nRank)
        local szMsg = string.format("恭喜玩家%s在%s活動中獲得了%s", szName, szType, szRank)
        KPlayer.SendWorldNotify(0, 999, szMsg, 1, 1);
    end
end

function tbAct:SendKinTip(dwID, nRank, nType)
    if not dwID or not nRank or not nType then
        return 
    end
    local pPlayerInfo = KPlayer.GetPlayerObjById(dwID) or KPlayer.GetRoleStayInfo(dwID)
    local szName = pPlayerInfo and pPlayerInfo.szName
    local nKinId = pPlayerInfo and pPlayerInfo.dwKinId
    if szName and nKinId and nKinId ~= 0 then
        local szType = (nType and nType == tbAct.TYPE.DAY) and "小獎" or "大獎"
        local szRank = ChouJiang:GetRankDes(nRank)
        local szMsg = string.format("恭喜幫派成員%s在%s活動中獲得了%s", szName, szType, szRank)
        ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.Kin, szMsg, nKinId);
    end
end
