local tbAct = Activity:GetClass("WinterAct")
tbAct.tbTimerTrigger = 
{ 
   
}
tbAct.tbTrigger  = {Init = {}, Start = {}, End = {}}

tbAct.tbGatherAnswerAward = {}

local Winter = Activity.Winter

function tbAct:OnTrigger(szTrigger)
	if szTrigger == "Start" then
		Activity:RegisterPlayerEvent(self, "Act_GatherFirstJoin", "OnGatherFirstJoin")
		Activity:RegisterPlayerEvent(self, "Act_GatherAnswerWrong", "OnGatherAnswerWrong")
		Activity:RegisterPlayerEvent(self, "Act_GatherAnswerRight", "OnGatherAnswerRight")
	elseif szTrigger == "End" then
		self:OnWinterEnd()
	end
	Log("WinterAct OnTrigger:", szTrigger)
end

function tbAct:OnWinterEnd()
	local nTangYuanCount = SupplementAward:GetMaxSupplementCount()
	local nNowTime = GetTime()
	local tbMail =
		{
			Title = "真兒的冬至暖信",
			Text = "    哼哼，那個說要揚名武林的大俠，不知冬日過得可好？一別經年，你可變成大忙人啦，佳節也不曾回島探望，我卻總惦記你，委託急如風替我捎去自己做的一碗湯圓，一盤餃子，無論你昨夜食用了何等山珍海味，都要乖乖吃下去！否則我會生氣的！好啦，要記得趁熱，[FFFE0D]過得今日，便不可食用了[-]。\n    冬日佳節，惟願君健康安好，平安而至。",
			From = '納蘭真',
			LevelLimit = Winter.nLimitLevel,
			tbAttach = {
			{'item', Winter:GetTangYuanItemId(), nTangYuanCount,nNowTime + Winter.nTangYuanValidTime},
			{'item', Winter:GetJiaoZiItemId(), Winter.nSendJiaoZiCount,nNowTime + Winter.nJiaoZiValidTime},
			},
			nLogReazon = Env.LogWay_WinterAct,
		};

	Mail:SendGlobalSystemMail(tbMail);
	Log("[WinterAct] OnWinterEnd Mail ",nTangYuanCount)
end

function tbAct:OnGatherAnswerWrong(pPlayer)
	EverydayTarget:AddActExtActiveValue(pPlayer, Winter.nGatherAnswerWrongActive, "WinterActGatherAnswerWrong")
	Log("[WinterAct] OnGatherAnswerWrong ",pPlayer.dwID,pPlayer.szName,pPlayer.nLevel,pPlayer.dwKinId)
end

function tbAct:OnGatherAnswerRight(pPlayer)
	EverydayTarget:AddActExtActiveValue(pPlayer, Winter.nGatherAnswerRightActive, "WinterActGatherAnswerRight")
	Log("[WinterAct] OnGatherAnswerRight ",pPlayer.dwID,pPlayer.szName,pPlayer.nLevel,pPlayer.dwKinId)
end

function tbAct:OnGatherFirstJoin(pPlayer)
	EverydayTarget:AddActExtActiveValue(pPlayer, Winter.nGatherFirstJoinActive, "WinterActGatherFirstJoin")
	Log("[WinterAct] OnGatherFirstJoin ",pPlayer.dwID,pPlayer.szName,pPlayer.nLevel,pPlayer.dwKinId)
end