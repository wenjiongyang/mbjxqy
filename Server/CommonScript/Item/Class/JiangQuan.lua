local tbItem = Item:GetClass("JiangQuan");

tbItem.SAVE_GROUP = 115
tbItem.KEY_GET_TIME = 1
tbItem.KEY_USE_TIME = 2
tbItem.KEY_NEW_YEAR_USE_DAY = 3
tbItem.KEY_NEW_YEAR_START_TIME = 4

--下面策划配
tbItem.nTemplateId = 3010 					-- 奖券ID
tbItem.nRefreshTime = 4 * 60 * 60 			-- 每天领取奖券的刷新时间
tbItem.nOverdueTime = 22 * 60 * 60 			-- 每天领取奖券的过期时间
tbItem.nLimitLevel = 20 					-- 领取所需等级
tbItem.nHuoYue = 60 						-- 活跃度

tbItem.tbAward = {{"Item", 786, 2}} 			-- 使用奖券奖励

function tbItem:OnUse(it)

	local bRet,szMsg = self:CheckCanUse(me)
	if not bRet then
		me.CenterMsg(szMsg)
		return
	end

	me.SendAward(self.tbAward, nil, nil, Env.LogWay_JiangQuan);
	Activity:OnPlayerEvent(me, "Act_UpdateChouJiangData", 1)

	me.SetUserValue(self.SAVE_GROUP, self.KEY_USE_TIME,GetTime())

	me.CenterMsg("成功使用了“迎國慶幸運獎券”，恭喜你獲得參與今日抽獎的機會。")
	Log("[JiangQuan] OnUse ",me.szName,me.dwID)
	return 1
end

function tbItem:CheckCanGet(pPlayer)
	local bInProcess = Activity:__IsActInProcessByType("ChouJiang")
	if not bInProcess then
		return false, "不在活動時間內"
	end

    local tbDate = os.date("*t", GetTime()) 
	local nNowTime = tbDate.hour * 60 * 60 + tbDate.min * 60 + tbDate.sec
	if self.nRefreshTime > self.nOverdueTime then
		if nNowTime > self.nOverdueTime and nNowTime < self.nRefreshTime then
			return false,"今日抽獎活動已結束，請於每日的4點以後再來領取獎券！"
		end
	else
		if nNowTime > self.nOverdueTime or nNowTime < self.nRefreshTime then
			return false,"今日抽獎活動已結束，請於每日的4點以後再來領取獎券！"
		end
	end

	local nGetTime = pPlayer.GetUserValue(self.SAVE_GROUP, self.KEY_GET_TIME);
	if not Lib:IsDiffDay(self.nRefreshTime, nGetTime) then
		return false,"閣下今日已經領過獎券了。"
	end

	if pPlayer.nLevel < self.nLimitLevel then
		return false,string.format("需要達到%s級才能領取獎券。",self.nLimitLevel)
	end

	if EverydayTarget:GetTotalActiveValue(pPlayer) < self.nHuoYue then
		return false,string.format("需要活躍度達到%s才可領取獎券。",self.nHuoYue)
	end

	return true
end

function tbItem:CheckCanUse(pPlayer)
	local bInProcess = Activity:__IsActInProcessByType("ChouJiang")
	if not bInProcess then
        return false, "不在活動時間內。"
    end

	local nUseTime = pPlayer.GetUserValue(self.SAVE_GROUP, self.KEY_USE_TIME);

	if not Lib:IsDiffDay(self.nRefreshTime, nUseTime) then
		return false,"您今天已經使用過獎券。"
	end

	if pPlayer.nLevel < self.nLimitLevel then
		return false,string.format("需要達到%s級才能使用。",self.nLimitLevel)
	end
   
	return true
end