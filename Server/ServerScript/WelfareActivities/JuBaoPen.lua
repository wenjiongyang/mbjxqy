local fnInit = function ()
	local nLastProb = 0
	for i2, v2 in ipairs(JuBaoPen.tbEventProp) do
		v2.nProb = nLastProb + v2.nProb
		nLastProb = v2.nProb
	end
	assert(math.abs( nLastProb - 1) <= 0.001)
end

fnInit()

--如果传了Player 就是要更新 数据查看到客户端了
function JuBaoPen:GetJuBaoPengVal(dwRoleId)
	if true then
		return 0;
	end
	local pAsnc = KPlayer.GetAsyncData(dwRoleId)
	if not pAsnc then
		return 0;
	end
	if pAsnc.GetLevel() < self.OPEN_LEVEL then
		return 0;
	end

	local nOrgVal = pAsnc.GetJuBaoPenVal()
	local nRecodeTime = pAsnc.GetJuBaoPenTime()
	assert(nRecodeTime > 0, dwRoleId)

	local nCurTime = GetTime();
	local nChangeCount = math.floor((nCurTime - nRecodeTime) / self.TIME_INTERVAL)
	if nChangeCount == 0 then
		return nOrgVal
	end

	local nCanAddMaxMoney = self.MAX_MONEY - nOrgVal
	local nAddMoney = 0;
	for nCount = 1, nChangeCount do
		local nRand = MathRandom()
		for i, v in ipairs(self.tbEventProp) do
			if nRand <= v.nProb then
				nAddMoney = nAddMoney + v.Money
				break
			end
		end
		if nAddMoney > nCanAddMaxMoney then
			break;
		end
	end
	nAddMoney = math.min(nAddMoney, nCanAddMaxMoney)
	Log("JuBaoPenFinalAddMoney", dwRoleId, nAddMoney, nChangeCount, nRecodeTime)

	local nNewRecordTime = nRecodeTime + self.TIME_INTERVAL * nChangeCount
	pAsnc.SetJuBaoPenVal(nOrgVal + nAddMoney)
	pAsnc.SetJuBaoPenTime(nNewRecordTime)
	return nOrgVal + nAddMoney
end

function JuBaoPen:CheckOpenJuBaoPen(pPlayer, nNewLevel)
	if true then
		return
	end
	if nNewLevel ~= self.OPEN_LEVEL then
		return
	end
	local pAsnc = KPlayer.GetAsyncData(pPlayer.dwID)
	if pAsnc then
		pAsnc.SetJuBaoPenTime(GetTime())
	end
end

function JuBaoPen:TakeMoney(pPlayer)
	if true then
		return
	end
	local nCDTime = self:GetTakeMoneyCDTime(pPlayer)
	if nCDTime > 0 then
		pPlayer.CenterMsg(string.format("需要等待%s後才能領取", Lib:TimeDesc(nCDTime)))
		return
	end
	local nVal = self:GetJuBaoPengVal(pPlayer.dwID)
	if nVal <= 0 then
		pPlayer.CenterMsg("沒有銀兩可以領取")
		return
	end
	local pAsnc = KPlayer.GetAsyncData(pPlayer.dwID)
	pAsnc.SetJuBaoPenVal(0)
	pPlayer.SetUserValue(self.SAVE_GROUP, self.SAVE_KEY_TAKE, GetTime())
	pPlayer.AddMoney("Coin", nVal, Env.LogWay_JuBaoPenTakeMoney)
	pPlayer.CallClientScript("JuBaoPen:TakeMoneyScucess", nVal)
end
