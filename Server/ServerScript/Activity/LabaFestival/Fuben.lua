local tbAct = Activity:GetClass("LabaFuben")
tbAct.tbTimerTrigger = {}
tbAct.tbTrigger = {
	Init={},
	Start={},
	End={},
}

tbAct.tbSettings = {
	nNestNpcNum = 100,
	nNestNpcLevel = 50,
}

function tbAct:OnTrigger(szTrigger)
	if szTrigger == "Start" then
		self:OnStart()
	elseif szTrigger == "End" then
		self:OnEnd()
	end
	Log("LabaFuben:OnTrigger", szTrigger)
end

function tbAct:OnStart()
	Kin:TraverseKin(function(tbKinData)
		Kin.KinNest:ForceOpen(tbKinData.nKinId, self.tbSettings.nNestNpcNum, self.tbSettings.nNestNpcLevel)
    end)
end

function tbAct:OnEnd()
	Kin:TraverseKin(function(tbKinData)
		Kin.KinNest:EndKinNest(tbKinData.nKinId)
    end)
end
