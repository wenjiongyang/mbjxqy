local ValueComposeServer = Compose.ValueCompose;

function ValueComposeServer:TryComposeValue(pPlayer,nSeqId)
	local bRet,szMsg,nTargetTemplateId,tbFinishPos = self:CheckValueCompose(pPlayer,nSeqId);
	if not bRet then
		pPlayer.CenterMsg(szMsg);
		return 
	end

	for _,nPos in ipairs(tbFinishPos) do
		ValueItem.ValueCompose:ChangeValue(pPlayer,nSeqId,nPos,-1);
	end

	pPlayer.AddItem(nTargetTemplateId, 1, nil, Env.LogWay_ValueComposeAdd);
	pPlayer.CallClientScript("Compose.ValueCompose:OnValueComposeFinish",nSeqId);
	Log("ValueComposeServer TryComposeValue compose success ",pPlayer.dwID,pPlayer.szName,nSeqId)
end