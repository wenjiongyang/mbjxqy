--[[
playerData = {
		szWuxing = "1112",--五行结果
	};
]]

function Pray:CanPray(pPlayer)
	if DegreeCtrl:GetDegree(pPlayer, "Pray") < 1 then
		return false, "剩餘次數不足";
	end

	if self:IsEndWuxing(pPlayer) then
		return false, "先領取獎勵才能繼續祈福";
	end

	if not self:IsLevelEnough(pPlayer) then
		return false, string.format("您需要%d級才能參與祈福", self.PRAY_OPEN_LEVEL);
	end
	
	return true;
end

function Pray:DoPray(pPlayer)
	local bAvailable, szInfo = self:CanPray(pPlayer);
	if not bAvailable then
		pPlayer.CenterMsg(szInfo);
		return;
	end

	local nWuXing = MathRandom(1, 5);
	self:AddPrayElements(pPlayer, nWuXing);

	if self:IsEndWuxing(pPlayer) then
		DegreeCtrl:ReduceDegree(pPlayer, "Pray", 1);
	end

	self:Sync(pPlayer);
	pPlayer.CallClientScript("Pray:PrayAnimationControl", 2);
end

function Pray:GainReward(pPlayer)
	local tbRewards = self:GetItemRewards(pPlayer);
	local tbAward = {};
	for _,v in pairs(tbRewards) do
		if v.nTemplateId ~= 0 then
			table.insert(tbAward, {v.szType, v.nTemplateId, v.nCount});
		else
			table.insert(tbAward, {v.szType, v.nCount});
		end
	end
	pPlayer.SendAward(tbAward, false, false, Env.LogWay_PrayGainReward);

	local nSkiillId, nSkillLevel, nSkillTime = self:GetBuffRewards(pPlayer);
	if nSkiillId then
		pPlayer.AddSkillState(nSkiillId, nSkillLevel, 2, GetTime() + nSkillTime, 1, 0);
	end

	self:AddAchievement(pPlayer);
	self:ClearPrayElements(pPlayer);
	pPlayer.CenterMsg("領獎成功");
	self:Sync(pPlayer);
end

local Interface = {
	DoPray 	= true,
	GainReward 	= true,
}

function Pray:ClientRequest(pPlayer, szRequestType, ... )
	if true then --关闭祈福功能
		return
	end
	if Interface[szRequestType] then
		Pray[szRequestType](Pray, pPlayer, ...);
	else
		Log("WRONG Pray Request:", szRequestType, ...);
	end
end

function Pray:Sync(pPlayer)
	local szWuxing = self:GetPrayElements(pPlayer);
	pPlayer.CallClientScript("Pray:OnSyncResponse", szWuxing);
end


function Pray:AddPrayElements(pPlayer, nWuXing)
	local tbPrayData = pPlayer.GetScriptTable("Pray");
	local szAfter = string.format("%s%d", tbPrayData.szWuxing or "", nWuXing);
	tbPrayData.szWuxing = szAfter;
end

function Pray:ClearPrayElements(pPlayer, nWuXing)
	local tbPrayData = pPlayer.GetScriptTable("Pray");
	tbPrayData.szWuxing = "";
end

function Pray:OnLogin(pPlayer)
	self:Sync(pPlayer);
end

function Pray:AddAchievement(pPlayer)
	local szWx = Pray:GetPrayElements(pPlayer);
	local nWx = string.len(szWx);
 	Achievement:AddCount(pPlayer, "Pray_" .. nWx, 1)
end