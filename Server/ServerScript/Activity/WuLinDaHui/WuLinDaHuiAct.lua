local tbAct = Activity:GetClass(WuLinDaHui.szActNameMain);
local tbDef = WuLinDaHui.tbDef;

tbAct.tbTimerTrigger =
{
	{ szType = "Day", Time = tbDef.szFinalStartMatchTime; Trigger = "CheckOpenMatchFinal" } ;
	{ szType = "Day", Time = tbDef.szFinalEndMatchTime;   Trigger = "CheckCloseMatchFinal" } ;
}

for i,v in ipairs(tbDef.tbNotifyMatchTime) do
	table.insert(tbAct.tbTimerTrigger, { szType = "Day", Time = v; Trigger = "CheckNotifyGameStart" }  )
end

for i,v in ipairs(tbDef.tbStartMatchTime) do
	table.insert(tbAct.tbTimerTrigger, { szType = "Day", Time = v; Trigger = "CheckOpenMatch" }  )
end

for i,v in ipairs(tbDef.tbEndMatchTime) do
	table.insert(tbAct.tbTimerTrigger, { szType = "Day", Time = v; Trigger = "CheckCloseMatch" }  )
end
	
tbAct.tbTrigger =
{
	Init = {},
	Start 	= {}, 
	End = {},
	CheckOpenMatch = {},
	CheckCloseMatch = {},
	CheckNotifyGameStart = {},
	CheckOpenMatchFinal = {},
	CheckCloseMatchFinal = {},
};

for i,v in ipairs(tbAct.tbTimerTrigger) do
	table.insert(tbAct.tbTrigger.Start, {"StartTimerTrigger", i } )
end

function tbAct:OnTrigger(szTrigger)
	if szTrigger == "Init" then	

	elseif szTrigger == "Start" then	
		local _,nEndTime = self:GetOpenTimeInfo()
		NewInformation:AddInfomation(tbDef.szNewsKeyNotify, nEndTime, {tbDef.szNewsContent}, {szTitle = "武林大會開啟", nReqLevel = 1} )    
		--因为这里活动还没同步到客户端呢
		Timer:Register(1, function ()
			KPlayer.BoardcastScript(1, "Player:ServerSyncData", "UpdateTopButton"); 
		end)
		
	elseif szTrigger == "End" then	
		Timer:Register(1, function ()
			KPlayer.BoardcastScript(1, "Player:ServerSyncData", "UpdateTopButton"); 
		end)

		WuLinDaHui:EndAct()
	elseif szTrigger == "CheckOpenMatch" then
		WuLinDaHui:CheckOpenMatch()
	elseif szTrigger == "CheckCloseMatch" then
		WuLinDaHui:CheckCloseMatch()
	elseif szTrigger == "CheckNotifyGameStart" then
		WuLinDaHui:CheckNotifyGameStart()
	elseif szTrigger == "CheckOpenMatchFinal" then
		WuLinDaHui:CheckOpenMatchFinal()
	elseif szTrigger == "CheckCloseMatchFinal" then
		WuLinDaHui:CheckCloseMatchFinal()
	end
end


