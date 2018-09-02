
local tbAct = Activity:GetClass("DomainBattleCombineAct");

tbAct.tbTimerTrigger = 
{ 
	[1] = {szType = "Day", Time = "19:10" , Trigger = "AddAcution"},				
}
tbAct.tbTrigger = { 
	Init 	= { }, 
	Start 	= { {"StartTimerTrigger", 1},}, 
	End 	= { }, 
	AddAcution = {};
}


--拍卖商人奖励道具设置

function tbAct:OnTrigger(szTrigger)
	if szTrigger == "AddAcution" then

		self:AddAcution()
	end
end

function tbAct:AddAcution()
	local tbData = ScriptData:GetValue("DomainBattle")
	local tbMakeUpInfo = tbData.tbMakeUpInfo
	if not tbMakeUpInfo then
		return
	end
	tbMakeUpInfo.nMakeUpTimes  = tbMakeUpInfo.nMakeUpTimes + 1
	if tbMakeUpInfo.nMakeUpTimes == 1 then
		--第一次的会发额外的占领拍卖
		self:SendMakeUpdOwnerAward();
	end

	self:SendMakeUpdDayAward()
end

function tbAct:GetAccordMembers(tbMakeUpInfo, dwKinId)
	local nVersion1 = tbMakeUpInfo.nVersion1
	local nVersion2 = tbMakeUpInfo.nVersion2
 	local kinData = Kin:GetKinById(dwKinId);
 	local nNum = 0;
	if kinData then
		kinData:TraverseMembers(function (memberData)
			if memberData.nLastnBattleVersion == nVersion1 or memberData.nLastnBattleVersion == nVersion2 then
				nNum = nNum + 1;
			end
			return true;
		end);
	end
	return nNum;
end

function tbAct:SendMakeUpdDayAward()
	local tbMakeUpInfo = ScriptData:GetValue("DomainBattle").tbMakeUpInfo
	local tbMakeUpKins = tbMakeUpInfo.tbMakeUpKins

	local tbKinScore = {}
	for dwKinId, nMapTemplateId in pairs(tbMakeUpKins) do
		local nPlayedNum = self:GetAccordMembers(tbMakeUpInfo, dwKinId)
		if nPlayedNum > 0 then
			tbKinScore[dwKinId] = DomainBattle:GetOnwerMapKinScore(nMapTemplateId, nPlayedNum);	
		end
	end

	self:SendKinAward(DomainBattle.define.tbActOwnerItemSetting, "DomainBattleAct", tbKinScore)
end

function tbAct:SendMakeUpdOwnerAward()
	local tbMakeUpInfo = ScriptData:GetValue("DomainBattle").tbMakeUpInfo
	local tbMakeUpKins = tbMakeUpInfo.tbMakeUpKins
	local tbKinScore = {}
	for dwKinId, nMapTemplateId in pairs(tbMakeUpKins) do
		local nPlayedNum = self:GetAccordMembers(tbMakeUpInfo, dwKinId)
		if nPlayedNum > 0 then			
			local tbFlogNpcPos = DomainBattle.tbMapPosSetting[nMapTemplateId].tbFlogNpcPos
			local tbFlagState = {}
			for i,v in ipairs(tbFlogNpcPos) do
				table.insert(tbFlagState, {dwKinId, ""})
			end

			tbKinScore[dwKinId] = DomainBattle:GetMapFlagKinScore(nMapTemplateId, tbFlagState, nPlayedNum, dwKinId) 	
		end
	end

	self:SendKinAward(DomainBattle.define.tbFlagAwardSetting, "DomainBattle", tbKinScore)
end

function tbAct:SendKinAward( tbAwardSetting, szAction, tbKinScore)
	local tbMakeUpInfo = ScriptData:GetValue("DomainBattle").tbMakeUpInfo
	local tbFlagAwardSetting;
	for i, v in ipairs(tbAwardSetting) do
		if GetTimeFrameState(v[1]) ~= 1 then
			break;
		end
		tbFlagAwardSetting = v[2];
	end

	local nVersion1 = tbMakeUpInfo.nVersion1
	local nVersion2 = tbMakeUpInfo.nVersion2
	local tbMakeUpKins = tbMakeUpInfo.tbMakeUpKins
	for dwKinId, nSocre in pairs(tbKinScore) do
		local tbAwardSet = tbFlagAwardSetting
		if tbFlagAwardSetting.nMapLevel1 then
			local nMapTemplateId = tbMakeUpKins[dwKinId]
			if nMapTemplateId then
				local nMapLevel = DomainBattle:GetMapLevel(nMapTemplateId)	
				if  tbFlagAwardSetting["nMapLevel" .. nMapLevel] then
					tbAwardSet = tbFlagAwardSetting["nMapLevel" .. nMapLevel];
				end
			end
		end
		local tbItems = DomainBattle:GetActionAwardFromParam(tbAwardSet, nSocre)
		if next(tbItems) then
			local tbFighters = {}
			local kinData = Kin:GetKinById(dwKinId);
			if kinData then
				kinData:TraverseMembers(function (memberData)
					if memberData.nLastnBattleVersion == nVersion1 or memberData.nLastnBattleVersion == nVersion2 then
						tbFighters[memberData.nMemberId] =  true
					end
					return true;
				end);
				Kin:AddAuction(dwKinId, szAction, tbFighters, tbItems);	
			end
		end
	end
end