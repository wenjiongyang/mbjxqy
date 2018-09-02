
local tbFuben = Fuben:CreateFubenClass("HouseDefendFuben");
tbFuben.SURVIVAL_TIME = 3720;

function tbFuben:OnPreCreate(dwOwnerId)
	self.dwOwnerId = dwOwnerId;
	self.bIsFinished = false;
	SampleHouse:GenerateFurniture(self.nMapId, SampleHouse.tbMapFurniture[4006], false);
	SetMapSurvivalTime(self.nMapId, GetTime() + self.SURVIVAL_TIME);
end

function tbFuben:OnFinishFuben()
	local nMapId = self.nMapId;
	local fnAward = function (pPlayer)
		Activity:OnPlayerEvent(pPlayer, "Act_HouseDefend_FubenFinished", nMapId);
	end
	self:AllPlayerInMapExcute(fnAward);
	Activity:OnGlobalEvent("Act_HouseDefend_FubenClose", self.nMapId, self.dwOwnerId);
	self.bIsFinished = true;
end

function tbFuben:OnClose()
	SetMapSurvivalTime(self.nMapId, 0);
	if not self.bIsFinished then
		Activity:OnGlobalEvent("Act_HouseDefend_FubenClose", self.nMapId, self.dwOwnerId);
	end
end

function tbFuben:OnJoin(pPlayer)
	pPlayer.CallClientScript("Ui:OpenWindow", "HomeScreenFuben", "TeamFuben");

	if self.nShowEndTime and self.nShowEndTime > 0 then
		pPlayer.CallClientScript("Fuben:SetEndTime", self.bClose == 1 and 0 or self.nShowEndTime);
	end
end

function tbFuben:OnOut(pPlayer)
	pPlayer.CallClientScript("Fuben:ShowLeave");
end

function tbFuben:OnLeaveMap(pPlayer)
	pPlayer.CallClientScript("Ui:CloseWindow", "HomeScreenFuben")
end

