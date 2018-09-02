
local tbAct = Activity:GetClass(WuLinDaHui.szActNameYuGao);
local tbDef = WuLinDaHui.tbDef;

tbAct.tbTimerTrigger =
{
}

tbAct.tbTrigger =
{
	Init 	= { }, 
	Start 	= { }, 
	End 	= { }, 
};


function tbAct:OnTrigger(szTrigger)
	if szTrigger == "Init" then	

		Mail:SendGlobalSystemMail({
			Title = "武林大會";
			Text = WuLinDaHui.tbDef.szMailTextYuGao;
			});

	elseif szTrigger == "Start" then	
		local _,nEndTime = self:GetOpenTimeInfo()
		NewInformation:AddInfomation(tbDef.szNewsKeyNotify, nEndTime, {tbDef.szNewsContent}, {szTitle = "武林大會開啟", nReqLevel = 1} )    

		Timer:Register(1, function ()
			KPlayer.BoardcastScript(1, "Player:ServerSyncData", "UpdateTopButton"); 
		end)
	elseif szTrigger == "End" then

	end
end

