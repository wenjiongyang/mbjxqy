
function Guide:Init()
	
	self.tbGuideSetting = LoadTabFile("Setting/Guide/GuideSetting.tab", "ddd", "GuideId", {"GuideId", "SaveId", "FinishTask"});
	
	for _, tbInfo in pairs(self.tbGuideSetting) do
		tbInfo.nKeyId = math.ceil(tbInfo.SaveId / 31)
		tbInfo.nBitIdx = (tbInfo.SaveId - 1) % 31 + 1
	end
	
	self.tbNotifySetting = LoadTabFile("Setting/Guide/NotifyGuide.tab", "sdd", "GuideName", {"GuideName", "SaveId", "StartLevel"});
	for szGuide, tbInfo in pairs(self.tbNotifySetting) do
		tbInfo.nKeyId = math.ceil(tbInfo.SaveId / 31)
		tbInfo.nBitIdx = (tbInfo.SaveId - 1) % 31 + 1
	end
end

Guide:Init()

function Guide:OnFinishGuide(pPlayer, nGuideId)
	if self.tbGuideSetting[nGuideId] then
		local nValue = pPlayer.GetUserValue(Guide.SAVE_GROUP, self.tbGuideSetting[nGuideId].nKeyId)
		nValue = KLib.SetBit(nValue, self.tbGuideSetting[nGuideId].nBitIdx, 1)
		pPlayer.SetUserValue(Guide.SAVE_GROUP, self.tbGuideSetting[nGuideId].nKeyId, nValue);
		
		if self.tbGuideSetting[nGuideId].FinishTask and self.tbGuideSetting[nGuideId].FinishTask ~= 0 then
			Task:DoFinishTask(pPlayer, self.tbGuideSetting[nGuideId].FinishTask, me.GetNpc().nId);
		end
	end
end

function Guide:FinishAllGuide(pPlayer)
	for nGuideId, tbInfo in pairs(self.tbGuideSetting) do
		local nValue = pPlayer.GetUserValue(Guide.SAVE_GROUP, tbInfo.nKeyId)
		nValue = KLib.SetBit(nValue, tbInfo.nBitIdx, 1)
		pPlayer.SetUserValue(Guide.SAVE_GROUP, tbInfo.nKeyId, nValue);
	end
end

function Guide:FinishNotifyGuide(pPlayer, szGuide)
	if self.tbNotifySetting[szGuide] then
		local nValue = pPlayer.GetUserValue(Guide.NOTIFY_GUIDE_SAVE, self.tbNotifySetting[szGuide].nKeyId)
		nValue = KLib.SetBit(nValue, self.tbNotifySetting[szGuide].nBitIdx, 1)
		pPlayer.SetUserValue(Guide.NOTIFY_GUIDE_SAVE, self.tbNotifySetting[szGuide].nKeyId, nValue);
	end
end
