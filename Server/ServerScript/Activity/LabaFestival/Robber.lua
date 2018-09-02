local tbAct = Activity:GetClass("LabaRobber")
tbAct.tbTimerTrigger = {}
tbAct.tbTrigger = {
	Init={},
	Start={},
	End={},
}

function tbAct:OnTrigger(szTrigger)
	if szTrigger == "Start" then
		self:OnStart()
	elseif szTrigger == "End" then
		self:OnEnd()
	end
	Log("LabaRobber:OnTrigger", szTrigger)
end

function tbAct:OnStart()
	Kin.bRobberOpened = true
end

function tbAct:OnEnd()
	Kin.bRobberOpened = nil
end
