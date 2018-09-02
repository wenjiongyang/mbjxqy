
local tbAct = Activity:GetClass("SendBlessAct");

tbAct.tbTimerTrigger = 
{ 
}
tbAct.tbTrigger = { 
	Init 	= {  }, 
	Start 	= {  },
	End 	= {  }, 
}

function tbAct:OnTrigger(szTrigger)
	self.nType = 1;
	if szTrigger == "Init" then
		SendBless:ActInit(self, true)

	elseif szTrigger == "Start" then
		Activity:RegisterPlayerEvent(self, "Act_OnPlayerLogin", "OnPlayerLogin");
		Activity:RegisterPlayerEvent(self, "Act_OnPlayerLevelUp", "OnPlayerLevelUp");
		SendBless:ActInit(self)

	elseif szTrigger == "End" then
		SendBless:ActEnd()
	end
end

function tbAct:OnPlayerLogin()
    SendBless:ResetPlayerDataAndAward(me, self)
end

function tbAct:OnPlayerLevelUp()
    SendBless:OnPlayerLevelUp(me)
end
