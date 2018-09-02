PlayerTitle.tbAllRoleTitle = PlayerTitle.tbAllRoleTitle or {} --[dwRoleId] = {TitleId , TitleIdStr}, 用于查看他人

function PlayerTitle:OnLogin(pPlayer)
    local pNpc = pPlayer.GetNpc();
    if not pNpc then
        Log("Error PlayerTitle OnLogin Not Npc Obj", pPlayer.dwID, pPlayer.szName);    
        return;
    end

    local tbData = self:GetPlayerTitleData(pPlayer);
    pPlayer.CallClientScript("PlayerTitle:OnSyncAllData", tbData);

    if tbData.nActivateTitle > 0 then
        pPlayer.ActiveTitle(tbData.nActivateTitle, false);
    end

    self:CheckTitleTimeout(pPlayer);

    local tbTempData = self:GetPlayerTempData(pPlayer);
    local tbShowTitle = tbTempData.tbShowTitle;
    if tbTempData.tbShowTitle then
        PlayerTitle:SetShowTitle(pPlayer, tbShowTitle.nTitleID, tbShowTitle.szText);
    end     
end

function PlayerTitle:OnLogout(pPlayer)
    self:ClosePlayerTimer(pPlayer);
end

function PlayerTitle:ClosePlayerTimer(pPlayer)
    local tbTempData = self:GetPlayerTempData(pPlayer);
    if tbTempData.nEndTimer then
        Timer:Close(tbTempData.nEndTimer);
        tbTempData.nEndTimer   = nil;
    end   
end


function PlayerTitle:CheckAddTile(pPlayer, nTitleID)
    local tbTitleTemp = self:GetTitleTemplate(nTitleID);
    if not tbTitleTemp then
        return false;
    end

    local tbData = self:GetPlayerTitleData(pPlayer);

    for _, tbTitleData in pairs(tbData.tbAllTitle) do
        local tbCurTitleTemp = self:GetTitleTemplate(tbTitleData.nTitleID);
        if tbCurTitleTemp.Rank > 0 and tbTitleTemp.Type == tbCurTitleTemp.Type then
            if tbTitleTemp.Rank >= tbCurTitleTemp.Rank then
                return true, tbTitleData.nTitleID;
            else
                return false, -1;
            end    
        end    
    end

    return true, 0;    
end

function PlayerTitle:GetPlayerTitleData(pPlayer)
    local tbData = pPlayer.GetScriptTable("PlayerTitleData");
    tbData.nActivateTitle = tbData.nActivateTitle or 0;
    tbData.tbAllTitle =  tbData.tbAllTitle or {};
    return tbData;
end

function PlayerTitle:GetCustomText(pPlayer, nTitleID)
    local tbData = self:GetPlayerTitleData(pPlayer)
    local tbTitleData = tbData.tbAllTitle[nTitleID]
    if not tbTitleData then
        return
    end
    return tbTitleData.szText
end

function PlayerTitle:AddTitle(pPlayer, nTitleID, nTimeout, szText, bNoTip)
    local bRet, nReplaceTitleID = self:CheckAddTile(pPlayer, nTitleID);
    if not bRet then
        return false;
    end    

    local tbData = self:GetPlayerTitleData(pPlayer);
    local nCurActID = tbData.nActivateTitle;
    if nReplaceTitleID > 0 then
        self:DeleteTitle(pPlayer, nReplaceTitleID, true);
    end

    local tbTitleTemp = self:GetTitleTemplate(nTitleID);
    local nEndTime   = -1;
    if nTimeout then
        if nTimeout > 0 then
            nEndTime = nTimeout + GetTime();
        end

    elseif tbTitleTemp.Timeout > 0 then
        nEndTime = tbTitleTemp.Timeout + GetTime();
        
    end

    local tbTitleData = {};
    tbTitleData.nTitleID = nTitleID;
    tbTitleData.nEndTime = nEndTime;   
    if not Lib:IsEmptyStr(szText) then
        tbTitleData.szText = szText;
    end     

    tbData.tbAllTitle[nTitleID] = tbTitleData;

    if nCurActID > 0 and nCurActID == nReplaceTitleID then
        self:ActiveTitle(pPlayer, nTitleID);
    end    

    self:CheckTitleTimeout(pPlayer);

    pPlayer.CallClientScript("PlayerTitle:AddTitle", nTitleID, nEndTime, szText);
    if not bNoTip then
        pPlayer.CenterMsg(string.format("您獲得了「%s」稱號", tbTitleTemp.Name));
    end
    
    if tbTitleTemp.tbAchievement then
        for _, szAchievement in pairs(tbTitleTemp.tbAchievement) do
            if not Lib:IsEmptyStr(szAchievement) then
                Achievement:AddCount(pPlayer, szAchievement, 1);
            end    
        end    
    end

    Kin:RedBagOnAddTitle(pPlayer, nTitleID)

    if not Lib:IsEmptyStr(tbTitleTemp.WorldNotify) then
        local szSendMsg = string.gsub(tbTitleTemp.WorldNotify, "$M", pPlayer.szName);
        if not szSendMsg then
            szSendMsg = tbTitleTemp.WorldNotify
        end
        
        KPlayer.SendWorldNotify(1, 999, szSendMsg, 1, 1);
    end   

    Log("Player AddTitle", pPlayer.dwID, pPlayer.szName, nTitleID, nEndTime, nReplaceTitleID, szText or "-");
    return true;    
end

function PlayerTitle:ActiveTitle(pPlayer, nTitleID, bShowInfo)
    local tbData = self:GetPlayerTitleData(pPlayer);
    if nTitleID ~= 0 and not tbData.tbAllTitle[nTitleID] then
        return;
    end    

    tbData.nActivateTitle = nTitleID;
    local pNpc = pPlayer.GetNpc();
    local szText = "";
    if tbData.nActivateTitle > 0 then
        local tbTitleData = pPlayer.GetTitleByID(tbData.nActivateTitle);
        if tbTitleData and not Lib:IsEmptyStr(tbTitleData.szText) then
            szText = tbTitleData.szText;
        end
    end

    pNpc.SetTitleID(tbData.nActivateTitle);  
    if not Lib:IsEmptyStr(szText) then 
        pNpc.SetTitle(szText, 1, 0);
    else
        pNpc.SetTitle("", 1, 0);  
    end    

    if nTitleID == 0 then
        self.tbAllRoleTitle[pPlayer.dwID] = nil;
    else
        self.tbAllRoleTitle[pPlayer.dwID] = {tbData.nActivateTitle, szText};
    end

        
    pPlayer.CallClientScript("PlayerTitle:ActiveTitle", nTitleID);

    if bShowInfo then
        if nTitleID > 0 then
            local tbTitleTemp = self:GetTitleTemplate(nTitleID);
            pPlayer.CenterMsg("更換稱號成功");
        else
            pPlayer.CenterMsg("隱藏稱號成功");    
        end
    end        

    Log("Player ActiveTitle", pPlayer.dwID, pPlayer.szName, nTitleID, szText or "-");    
end

function PlayerTitle:SetShowTitle(pPlayer, nTitleID, szText)
    local tbData = self:GetPlayerTitleData(pPlayer);
    local tbTempData = self:GetPlayerTempData(pPlayer);
    if not tbTempData.nLastActivateTitle then
        tbTempData.nLastActivateTitle = tbData.nActivateTitle
    end    

    tbTempData.tbShowTitle = {};
    tbTempData.tbShowTitle.nTitleID = nTitleID;
    tbTempData.tbShowTitle.szText = szText;

    pPlayer.ActiveTitle(0, false);
    local pNpc = pPlayer.GetNpc();
    pNpc.SetTitleID(nTitleID);  
    if not Lib:IsEmptyStr(szText) then 
        pNpc.SetTitle(szText, 1, 0);
    else
        pNpc.SetTitle("", 1, 0);  
    end

    pPlayer.CallClientScript("PlayerTitle:SetShowTitle", nTitleID, szText);
end

function PlayerTitle:ClearShowTitle(pPlayer)
    local tbTempData = self:GetPlayerTempData(pPlayer);
    local tbShowTitle = tbTempData.tbShowTitle;
    if not tbShowTitle then
        return;
    end

    local nActivateTitle = tbTempData.nLastActivateTitle;
    if not nActivateTitle then
        nActivateTitle = 0;
    end

    pPlayer.ActiveTitle(nActivateTitle, false);
    tbTempData.tbShowTitle = nil;
    tbTempData.nLastActivateTitle = nil;
end

function PlayerTitle:GetPlayerTempData(pPlayer)
    if not pPlayer.tbPlayerTitleTempData then
        pPlayer.tbPlayerTitleTempData = {};
    end
    
    return pPlayer.tbPlayerTitleTempData;    
end

function PlayerTitle:CheckTitleTimeout(pPlayer)
    local tbTempData = self:GetPlayerTempData(pPlayer);
    self:ClosePlayerTimer(pPlayer);

    local tbData = self:GetPlayerTitleData(pPlayer);
    local nMinEndTime    = 0;
    local nMinEndTitleId = 0;
    for _, tbTitleData in pairs(tbData.tbAllTitle) do
        if tbTitleData.nEndTime > 0 then
            if nMinEndTime == 0 or nMinEndTime > tbTitleData.nEndTime then
                nMinEndTime = tbTitleData.nEndTime;
                nMinEndTitleId = tbTitleData.nTitleID;
            end    
        end    
    end

    if nMinEndTime > 0 and nMinEndTitleId > 0 then
        local nReTime = nMinEndTime - GetTime();
        if nReTime <= 0 then
            nReTime = 1;
        end

        if nReTime >= 60 * 24 * 60 * 60 then
            return;
        end

        local nTimerFrame = nReTime * Env.GAME_FPS;
        tbTempData.nEndTimer = Timer:Register(nTimerFrame, self.OnTimerDeleteTitle, self, pPlayer.dwID, nMinEndTitleId);
    end    
end

function PlayerTitle:OnTimerDeleteTitle(nPlayerID, nTitleID)
    local pPlayer = KPlayer.GetPlayerObjById(nPlayerID);
    if not pPlayer then
        return;
    end

    local tbData      = self:GetPlayerTitleData(pPlayer);
    local nCurTime    = GetTime();
    local tbTitleData = tbData.tbAllTitle[nTitleID];
    if tbTitleData and tbTitleData.nEndTime > 0 and nCurTime >= (tbTitleData.nEndTime - 1) then
        self:DeleteTitle(pPlayer, nTitleID);   
    end    

    self:CheckTitleTimeout(pPlayer);
end

function PlayerTitle:GetPlayerTitleByID(pPlayer, nTitleID)
    local tbData = self:GetPlayerTitleData(pPlayer);
    return tbData.tbAllTitle[nTitleID];
end


function PlayerTitle:DeleteTitle(pPlayer, nTitleID, bReplace)
    local tbData = self:GetPlayerTitleData(pPlayer);
    tbData.tbAllTitle[nTitleID] = nil;

    if tbData.nActivateTitle == nTitleID then
        self:ActiveTitle(pPlayer, 0);
    end

    self:CheckTitleTimeout(pPlayer);  
    pPlayer.CallClientScript("PlayerTitle:DeleteTitle", nTitleID);

    local tbTitleTemp = PlayerTitle:GetTitleTemplate(nTitleID);

    if not bReplace then
        pPlayer.CenterMsg(string.format("您的稱號「%s」已過期", tbTitleTemp.Name), true);
    end       

    Log("Player DeleteTitle", pPlayer.dwID, pPlayer.szName, nTitleID);

    return true;   
end
 
 function PlayerTitle:GetTitleInfoByRoleId(dwRoleId)
     return self.tbAllRoleTitle[dwRoleId]
 end