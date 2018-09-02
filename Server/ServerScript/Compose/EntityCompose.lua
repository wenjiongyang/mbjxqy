
local EntityCompose = Compose.EntityCompose;

function EntityCompose:ComposeEntityItem(pPlayer,nTemplateId)
	nTemplateId = tonumber(nTemplateId)
	if not nTemplateId then
		return
	end
	if pPlayer.CheckNeedArrangeBag() then
		pPlayer.CenterMsg("請先整理一下背包物品！");
		return
	end
	local bRet,szMsg = self:CheckIsComposeMaterial(nTemplateId);
	if not bRet then
		pPlayer.CenterMsg(szMsg);
		return
	end
	local bIsCan,szMsg,nTargetID = self:CheckIsCanCompose(pPlayer,nTemplateId);
	if not bIsCan then
		pPlayer.CenterMsg(szMsg);
		return
	end
	local tbTargeInfo = self.tbTargeInfo[nTargetID];
	local szConsumeType = tbTargeInfo.szConsumeType;
	if szConsumeType then
		if not pPlayer.CostMoney(szConsumeType,tbTargeInfo.nConsumeCount,Env.LogWay_EntityComposeAdd) then
			pPlayer.CenterMsg("費用不足！")
			return
		end
		Log("EntityCompose ComposeEntityItem szConsumeType and nConsumeCount ",szConsumeType,tbTargeInfo.nConsumeCount,pPlayer.dwID)
	end
	for nId,nNeed in pairs(tbTargeInfo) do
		if tonumber(nId) then
			local nConsume = pPlayer.ConsumeItemInAllPos(nId,nNeed, Env.LogWay_EntityComposeConsume);
			if nConsume < nNeed then
				pPlayer.CenterMsg(string.format("扣除道具%s失敗！",KItem.GetItemShowInfo(nId, pPlayer.nFaction)));
				Log("ComposeEntityItem ----- consume item fail",nId,nConsume,nNeed,pPlayer.dwID);
				return
			else
				Log("EntityCompose ComposeEntityItem success ",nId,nConsume,nNeed,pPlayer.dwID)
			end
		end
	end
	pPlayer.SendAward({{"item",nTargetID,1}}, nil, nil, Env.LogWay_EntityComposeAdd);
	if not tbTargeInfo.bIsHideTip then
		pPlayer.CenterMsg(string.format("恭喜！合成了【%s】",KItem.GetItemShowInfo(nTargetID, pPlayer.nFaction)));
	end

	Log("EntityCompose ComposeEntityItem nTargetID ",nTargetID,pPlayer.dwID)
end