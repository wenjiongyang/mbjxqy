local tbAct = Activity:GetClass("DuanWuJie")

tbAct.tbTimerTrigger = { }
tbAct.tbTrigger = { Init = { }, Start = { }, End = { }, }

tbAct.tbAward = {
	DuanWuJie = {
		[1] = {{"Item", 4742, 1}},
		[2] = {{"Item", 4742, 1}},
		[3] = {{"Item", 4742, 1}},
		[4] = {{"Item", 4742, 1}},
		[5] = {{"Item", 4742, 1}},
	},
	GanEnAct = {
		[1] = {{"Item", 4742, 1}},
		[2] = {{"Item", 4742, 1}},
		[3] = {{"Item", 4742, 1}},
		[4] = {{"Item", 4742, 1}},
		[5] = {{"Item", 4742, 1}},
	},
	YuanQi = {
		[4] = {{"Item", 3013, 1}, {"Item", 786, 2}},
	},
	EverydayTarget1 = {
		[5] = {{"Item", 3515, 1}},
	},
}

tbAct.tbLogway = {
	DuanWuJie = Env.LogWay_ActDuanWuJie,
	GanEnAct  = Env.LogWay_ActGanEnJie,
}

tbAct.tbSubLogway = {
	DuanWuJie       = 1,
	GanEnAct        = 2,
	YuanQi          = 3,
	EverydayTarget1 = 4,
}

function tbAct:OnTrigger(szTrigger)
	if szTrigger == "Start" then
		Activity:RegisterPlayerEvent(self, "Act_EverydayTarget_Award", "OnAddEverydayAward")
	end
end

function tbAct:OnAddEverydayAward(pPlayer, nAwardIdx)
	local tbAward = self.tbAward[self.szKeyName] or {}
	local tbIdxAward = tbAward[nAwardIdx]
	if not tbIdxAward then
		return
	end

	local nLogWay = self.tbLogway[self.szKeyName] or Env.LogWay_ActDuanWuJie
	local nSubLog = self.tbSubLogway[self.szKeyName] or 0
	pPlayer.SendAward(tbIdxAward, true, nil, nLogWay, nSubLog)
	Log("[DuanWuJie] SendAward", pPlayer.dwID, nAwardIdx, self.szKeyName)
end