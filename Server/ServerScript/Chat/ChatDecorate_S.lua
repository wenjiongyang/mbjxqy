local ChatDecorate = ChatMgr.ChatDecorate
--[[
	tbData = 
	{
		[nPartsType] = nPartsID,
	}
]]

function ChatDecorate:ApplyDecorate(pPlayer,tbData)
	if not tbData then
		Log("[ChatDecorate] no data",pPlayer.dwID,pPlayer.szName)
		return
	end

	for _,nPartsType in pairs(ChatDecorate.PartsType) do
		if not tbData[nPartsType] then
			Log("[ChatDecorate] no PartsType",pPlayer.dwID,pPlayer.szName,nPartsType)
			return
		end
	end

	for nType,nPartsID in pairs(tbData) do
		local bRet,szMsg = self:CanApply(pPlayer,nPartsID)

		if not bRet then
			if szMsg then
				pPlayer.CenterMsg(szMsg,true)
			end
			Log("[ChatDecorate] ApplyDecorate CanApply fail",pPlayer.dwID,pPlayer.szName,nPartsID,szMsg,nType)
			return
		end

		if not self:CheckMatch(nType,nPartsID) then
			Log("[ChatDecorate] ApplyDecorate CheckMatch fail",pPlayer.dwID,pPlayer.szName,nPartsID,nType)
			return 
		end
	end

	self:TryCheckValid(pPlayer)

	local bIsApply
	local szLog = ""

	for nType,nPartsID in pairs(tbData) do
		local tbSetting = self.tbChatDecorateSetting[nType]
		if not tbSetting then
			Log("[ChatDecorate] ApplyDecorate no tbSetting",pPlayer.dwID,pPlayer.szName,nPartsID,nType)
			return
		end

		local szFnCur = tbSetting.szFnCur
		if not ChatDecorate[szFnCur] then
			Log("[ChatDecorate] ApplyDecorate find no szFnCur",pPlayer.dwID,pPlayer.szName,nType,nPartsID,szFnCur or "nil")
			return
		end

		local nCurPartsID = ChatDecorate[szFnCur](self,pPlayer)
		if nCurPartsID ~= nPartsID then
			local nSaveValue = ChatDecorate:CheckDefault(nPartsID) and 0 or nPartsID
			pPlayer.SetUserValue(ChatMgr.CHAT_BACKGROUND_USERVAULE_GROUP, tbSetting.nSaveKey,nSaveValue)
			bIsApply = true
		end
		szLog = szLog ..string.format(" type_%s_ChangePartsID_%s_CurPartsID_%s |",nType,nPartsID,nCurPartsID)
	end

	if bIsApply then
		Log("[ChatDecorate] ApplyDecorate ok",pPlayer.dwID,pPlayer.szName,szLog)
	else
		Log("[ChatDecorate] ApplyDecorate no change",pPlayer.dwID,pPlayer.szName,szLog)	
	end
end

function ChatDecorate:OnLogin(pPlayer)
	self:TryCheckValid(pPlayer)
end

function ChatDecorate:TryCheckValid(pPlayer)
	-- 检查重置当前使用
	self:TryCheckValidTime(pPlayer)
	-- 检查特权条件是有还有效
	self:CheckConditionOverdure(pPlayer)
	-- 检查并清除过期主题
	self:TryCheckTimeOverdue(pPlayer)
end

function ChatDecorate:TryCheckValidTime(pPlayer)
	local tbReset = self:CheckValidTime(pPlayer)
	if tbReset then
		for nType,_ in pairs(tbReset) do
			local tbSetting = self.tbChatDecorateSetting[nType]

			local nCurPartsID = ChatDecorate[tbSetting.szFnCur](self,pPlayer)
			local tbPartsInfo = ChatDecorate:GetPartsInfo(nCurPartsID)
			local nThemeID = tbPartsInfo.nThemeID

			pPlayer.SetUserValue(ChatMgr.CHAT_BACKGROUND_USERVAULE_GROUP, tbSetting.nSaveKey,0)
			Log("[ChatDecorate] TryCheckValidTime reset default",pPlayer.dwID,pPlayer.szName,nType,nCurPartsID,nThemeID,tbSetting.nSaveKey)
		end
		pPlayer.CallClientScript("ChatMgr.ChatDecorate.OnPartsReset")
	end
end

function ChatDecorate:TryCheckTimeOverdue(pPlayer)
	local tbOverdue = self:CheckTimeOverdue(pPlayer)
	if tbOverdue then
		for nThemeID,_ in pairs(tbOverdue) do
			ValueItem.ValueDecorate:SetValue(pPlayer,nThemeID,0)
			local tbTheme = self:GetThemeInfo(nThemeID)
			pPlayer.CenterMsg(string.format("您的「%s」頭像框已經過期",self:GetTitleByThemeId(nThemeID,pPlayer.nFaction) or ""),true)
		end
	end
end