local tbAct = Activity:GetClass("CardPickReplaceSSAct");

tbAct.tbTimerTrigger = { }
tbAct.tbTrigger = { Init = { }, Start = { }, End = { }, }
tbAct.szCurRunningKeyName = nil;

function tbAct:OnTrigger(szTrigger)
	local szOpenFrame = self.tbParam[1];
	if GetTimeFrameState(szOpenFrame) ~= 1 then
		Log("CardPickReplaceSSAct Time Frame not reach!", szOpenFrame);
		return;
	end

	if szTrigger == "Start" then
		self:OnStart();
	elseif szTrigger == "End" then
		self:OnEnd();
	end
end

function tbAct:OnStart()
	local nItemId = tonumber(self.tbParam[2]);
	local tbReplaceCard = {
		szItemType = "Partner",
		nItemId = nItemId,
		nCount = 1,
	};

	CardPicker:SetSpecialReplaceCard(tbReplaceCard);
	tbAct.szCurRunningKeyName = self.szKeyName;
	Log("CardPickReplaceSSAct Start", self.szKeyName, unpack(self.tbParam));
	self:SendNews();
end

function tbAct:OnEnd()
	if tbAct.szCurRunningKeyName and tbAct.szCurRunningKeyName ~= self.szKeyName then
		Log("CardPickReplaceSSAct Not End", self.szKeyName, tbAct.szCurRunningKeyName);
		return;
	end

	tbAct.szCurRunningKeyName = nil;
	CardPicker:SetSpecialReplaceCard(nil);
	Log("CardPickReplaceSSAct End", self.szKeyName, unpack(self.tbParam));
end

function tbAct:SendNews()
	local szNewInfoMsg = [[
    近日，襄陽城酒樓內聚集了大量江湖中有名的俠客。凡在 [FFFE0D]%s ~ %s[-] 進行[FFFE0D]元寶招募[-]，將有概率尋訪到 [FFFE0D]SS級俠客：[-][00FF00][url=openwnd:%s, PartnerDetail, nil, nil, nil, %d][-] 作為同伴！
    ]]
	if version_tx then
		szNewInfoMsg = [[
    近日，襄陽城酒樓內聚集了大量江湖中有名的俠客。凡在 [FFFE0D]%s ~ %s[-] 進行[FFFE0D]元寶招募[-]，將有機率尋訪到 [FFFE0D]地級俠客：[-][00FF00][url=openwnd:%s, PartnerDetail, nil, nil, nil, %d][-] 作為同伴！
    ]]
	end


	local nBeginTime = Activity:GetActBeginTime(self.szKeyName);
	local nEndTime = Activity:GetActEndTime(self.szKeyName);
	local szBeginTime = Lib:TimeDesc9(nBeginTime);
	local szEndTime = Lib:TimeDesc9(nEndTime);
	local nItemId = tonumber(self.tbParam[2]);
	local szName = GetOnePartnerBaseInfo(nItemId);
	szNewInfoMsg = string.format(szNewInfoMsg, szBeginTime, szEndTime, szName, nItemId);
	NewInformation:AddInfomation("CardPickReplaceSSAct", nEndTime, {szNewInfoMsg}, { szTitle = "同伴招募活動"});
end