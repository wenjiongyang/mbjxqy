Survey.SAVE_GROUP = 82

function Survey:LoadTabFileOutside(szFileName, tbNumColName)
	return Lib:LoadTabFile(szFileName, tbNumColName, 1) or Lib:LoadTabFile(szFileName, tbNumColName, 0)
end

local TYPES = {
	fixed = 0,		--固定节点
	whitelist = 1,	--白名单
	required = 2,	--必答
}

function Survey:LoadCfg()
	self.tbSortedGrpIds = {}
	self.tbCfgs = {}
	local tbMainCfg = self:LoadTabFileOutside("Setting/Survey/Survey.tab", {GroupID=1, Priority=1, Type=1, RewardGold=1, OpenTime=1, CloseTime=1, MinLevel=1, 
		MaxLevel=1, TaskFinish=1, FightPower=1, CurGold=1, TotalLoginDays=1, WhiteListID=1, TotalRechargeRmb=1})
	local tbQuestions = self:LoadTabFileOutside("Setting/Survey/SurveyQuestion.tab", {GroupID=1, Index=1, Type=1, MaxChoice=1, nOptional=1})
	for _,v in ipairs(tbMainCfg) do
		table.insert(self.tbSortedGrpIds, v.GroupID)
		self.tbCfgs[v.GroupID] = v
		local tb = {}
		for _,tbQues in ipairs(tbQuestions) do
			if v.GroupID==tbQues.GroupID then
				local tbChoices = {}
				for i=1,16 do
					local szA = tbQues[string.format("A%d", i)]
					if not szA or szA=="" then
						break
					end

					local tbChoice = {nIdx=i, szA=szA}
					local szFlow = tbQues[string.format("A%dFlow", i)]
					if szFlow and szFlow~="" then
						local tb = Lib:SplitStr(szFlow, "_")
						if tb[1]=="jump" then
							tbChoice.nFlowJump = tonumber(tb[2])
						elseif tb[1]=="add" then
							tbChoice.tbFlowAdd = {}
							for i=2,#tb do
								local nId = tonumber(tb[i])
								if nId and nId>0 then
									table.insert(tbChoice.tbFlowAdd, nId)
								end
							end
							table.sort(tbChoice.tbFlowAdd, function(nId1, nId2) return nId1>nId2 end)
						end
					end

					local nPos = tonumber(tbQues[string.format("A%dPos", i)])
					if nPos and nPos>0 then
						tbChoice.nPos = nPos
					end

					local nOther = tonumber(tbQues[string.format("A%dOther", i)])
					if nOther and nOther>=0 then
						tbChoice.nOther = nOther
					end

					tbChoices[i] = tbChoice
				end

				tb[tbQues.Index] = {
					GroupID = tbQues.GroupID,
					Index = tbQues.Index,
					Question = tbQues.Question,
					Type = tbQues.Type,
					nOptional = tbQues.nOptional,
					MaxChoice = tonumber(tbQues.MaxChoice),
					tbChoices = tbChoices,
				}

				if tbQues.Type==4 then
					local szHeader = tbQues.A1Flow
					tb[tbQues.Index].tbHeader = Lib:SplitStr(szHeader, "|")
				end
			end
		end
		self.tbCfgs[v.GroupID].tbQuestions = tb
	end

	table.sort(self.tbSortedGrpIds, function(nGrpId1, nGrpId2)
		local tbCfg1 = self.tbCfgs[nGrpId1]
		local tbCfg2 = self.tbCfgs[nGrpId2]
		if tbCfg1.Type==tbCfg2.Type then
			return tbCfg1.Priority>tbCfg2.Priority or (tbCfg1.Priority==tbCfg2.Priority and tbCfg1.GroupID>tbCfg2.GroupID)
		end
		return tbCfg1.Type>tbCfg2.Type
	end)
end

function Survey:LoadWhiteList()
	self.tbWhiteLists = {}
	local tbWhiteLists = self:LoadTabFileOutside("Setting/Survey/SurveyWhiteList.tab", {ID=1})
	for _,tb in ipairs(tbWhiteLists) do
		self.tbWhiteLists[tb.ID] = self.tbWhiteLists[tb.ID] or {}
		self.tbWhiteLists[tb.ID][tb.OpenID] = true
	end
end

function Survey:Init()
	self:LoadCfg()
	self:LoadWhiteList()
end
Survey:Init()

function Survey:GetLatest(pPlayer)
	local bFixedDone = false
	local bWhiteListDone = false
	for _, nGrpId in ipairs(self.tbSortedGrpIds) do
		local tbCfg = self.tbCfgs[nGrpId]
		while true do
			--[[
			if tbCfg.Url and tbCfg.Url~="" then
				if self:IsDone(pPlayer, nGrpId) then
					break
				end

				if self:IsConditionValid(pPlayer, nGrpId) then
					return tbCfg
				end
				break
			end
			]]

			local nType = tbCfg.Type
			if nType==TYPES.required then
				if not self:IsDone(pPlayer, nGrpId) and self:IsConditionValid(pPlayer, nGrpId) then
					return tbCfg
				end
			elseif nType==TYPES.whitelist then
				if bWhiteListDone then
					break
				end
				if self:IsDone(pPlayer, nGrpId) then
					bWhiteListDone = true
					break
				end
				if self:IsConditionValid(pPlayer, nGrpId) then
					return tbCfg
				end
			elseif nType==TYPES.fixed then
				if bFixedDone then
					break
				end
				if self:IsDone(pPlayer, nGrpId) then
					bFixedDone = true
					break
				end
				if self:IsConditionValid(pPlayer, nGrpId) then
					return tbCfg
				end
			end

			break
		end
	end
	return nil
end

function Survey:SendLatest(pPlayer)
	local tbLatest = self:GetLatest(pPlayer)
	if not tbLatest then return end

	pPlayer.CallClientScript("Survey:SetLatest", tbLatest)
end

function Survey:IsDone(pPlayer, nGroupId)
	local nState = pPlayer.GetUserValue(self.SAVE_GROUP, nGroupId)
	return nState>0
end

function Survey:IsConditionValid(pPlayer, nGroupId)
	local tbCfg = self.tbCfgs[nGroupId]
	if not tbCfg then
		return false
	end

	if tbCfg.WhiteListID and tbCfg.WhiteListID>0 then
		local tbWhiteList = self.tbWhiteLists[tbCfg.WhiteListID] or {}
		if not tbWhiteList[pPlayer.szAccount] then
			return false
		end
	end

	local nNow = Lib:GetTimeNum()
	if tbCfg.OpenTime and tbCfg.OpenTime>0 and nNow<tbCfg.OpenTime then
		return false
	end
	if tbCfg.CloseTime and tbCfg.CloseTime>0 and nNow>tbCfg.CloseTime then
		return false
	end

	local nLevel = pPlayer.nLevel
	if tbCfg.MinLevel and tbCfg.MinLevel>0 and nLevel<tbCfg.MinLevel then
		return false
	end
	if tbCfg.MaxLevel and tbCfg.MaxLevel>0 and nLevel>tbCfg.MaxLevel then
		return false
	end

	if tbCfg.TaskFinish and tbCfg.TaskFinish>0 and not Task:IsFinish(pPlayer, tbCfg.TaskFinish) then
		return false
	end

	if tbCfg.FightPower and tbCfg.FightPower>0 then
		local nFightPower = pPlayer.GetFightPower()
		if tbCfg.FightPower>nFightPower then
			return false
		end
	end

	if tbCfg.CurGold and tbCfg.CurGold>0 then
		local nGold = pPlayer.GetMoney("Gold")
		if tbCfg.CurGold>nGold then
			return false
		end
	end

	if tbCfg.TotalLoginDays and tbCfg.TotalLoginDays>0 then
		local nTotalLoginDays = LoginAwards:GetTotalLoginDays(pPlayer)
		if nTotalLoginDays<tbCfg.TotalLoginDays then
			return false
		end
	end

	if tbCfg.TotalRechargeRmb and tbCfg.TotalRechargeRmb>0 then
		local nTotal = Recharge:GetTotoalRecharge(pPlayer)
		if nTotal/100<tbCfg.TotalRechargeRmb then
			return false
		end
	end

	return true
end

function Survey:IsValid(pPlayer, nGroupId)
	if self:IsDone(pPlayer, nGroupId) then
		return false
	end
	return self:IsConditionValid(pPlayer, nGroupId)
end

function Survey:Finish(pPlayer, bUrl, nGroupId, tbAnswer)
	if not self:IsValid(pPlayer, nGroupId) then
		print("[x] Survey:Finish failed", nGroupId)
		return
	end
	pPlayer.SetUserValue(self.SAVE_GROUP, nGroupId, 1)

	if not bUrl then
		self:RecordAnswer(pPlayer, nGroupId, tbAnswer)
		self:SendReward(pPlayer, nGroupId)
	end
end

function Survey:SendReward(pPlayer, nGroupId)
	local tbCfg = self.tbCfgs[nGroupId]
	Mail:SendSystemMail({
        To = pPlayer.dwID,
        Title = "問卷調查獎勵",
        Text = "感謝你參與問卷調查，獎勵已發送，請查收。",
        From = "系統",
        tbAttach = {{"Gold", tbCfg.RewardGold}},
    })
end

function Survey:RecordAnswer(pPlayer, nGroupId, tbAnswer)
	local tbOrderedAnswers = {}
	for i=1,50 do
		local tb = tbAnswer[i] or {}
		table.insert(tbOrderedAnswers, tb.szChoices or "")
		table.insert(tbOrderedAnswers, tb.szInput or "")
	end

	local szLog = string.format("%s|%s", nGroupId, table.concat(tbOrderedAnswers, "|"))
	pPlayer.TLog("Survey", szLog)
end
