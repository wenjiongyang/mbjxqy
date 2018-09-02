local tbItem = Item:GetClass("NewYearJiangQuan");
tbItem.szNewYearOverdue = "2017-2-4-22-00-00"               -- 新年奖券过期时间
tbItem.nNewYearJianQuanItemId = 3689
tbItem.nUseLevel = 1
function tbItem:OnUse(it)
	if not ChouJiang.bOpen then
		me.CenterMsg("暫不開放抽獎", true)
		return
	end
	if not it.dwTemplateId then
		return 
	end
	
	if self:CheckOverdue() then
		me.CenterMsg("道具已經過期", true)
		return 1
	end

	if me.nLevel < self.nUseLevel then
		me.CenterMsg(string.format("%d級才可使用", self.nUseLevel), true)
		return
	end	

	local bInProcess = Activity:__IsActInProcessByType("ChouJiang")
	if not bInProcess then
		me.CenterMsg("活動已經結束", true)
		return
	end

	Activity:OnPlayerEvent(me, "Act_OnUseNewYearJiangQuan")
end

function tbItem:GetOverdueTime()
	local tbTime = Lib:SplitStr(self.szNewYearOverdue, "-")
	local year, month, day, hour, minute, second = unpack(tbTime)
	return os.time({year = tonumber(year), month = tonumber(month), day = tonumber(day), hour = tonumber(hour), min = tonumber(minute), sec = tonumber(second)})
end

function tbItem:CheckOverdue()
	local nNowTime = GetTime()
	local nOverdueTime = self:GetOverdueTime()
	return nNowTime >= nOverdueTime
end

function tbItem:GetTip()
	local szTips = ""
	local tbTime = Lib:SplitStr(self.szNewYearOverdue, "-")
	local year, month, day, hour = unpack(tbTime)
	local szOverdue = self:CheckOverdue() and "(已過期)" or ""
	local nLastExeDay = ChouJiang:GetLastExeDay(ChouJiang.tbActInfo.nStartTime)
	local tbTime = Lib:SplitStr(ChouJiang.szDayTime, ":")
	local szExeDate = ChouJiang.tbDayLotteryDate[nLastExeDay] and string.format("抽獎時間:%s%s時", ChouJiang.tbDayLotteryDate[nLastExeDay], tbTime[1] or "-") or ""
	szTips = szTips ..string.format("過期時間:%s月%s日%s時%s\n%s", month, day, hour, szOverdue, szExeDate)
	return szTips
end

function tbItem:GetIntrol()
	local nLastExeDay = ChouJiang:GetLastExeDay(ChouJiang.tbActInfo.nStartTime)
	local szExeDate = ChouJiang.tbDayLotteryDate[nLastExeDay] and string.format("%s",ChouJiang.tbDayLotteryDate[nLastExeDay]) or ""
	return string.format("使用後參與[FFFE0D]%s[-]抽獎，同時還將獲得[FFFE0D]2月11日元宵抽大獎[-]的機會，點擊[FFFE0D]預覽[-]可以前去查看獎勵內容。", szExeDate)
end

function tbItem:GetUseSetting(nTemplateId, nItemId)
	local fnPreview = function ()
		Ui:OpenWindow("NewInformationPanel", ChouJiang.szOpenNewInfomationKey)
		Ui:CloseWindow("ItemTips")
    end
	return {szFirstName = "預覽", fnFirst = fnPreview, szSecondName = "使用", fnSecond = "UseItem"};
end