
Require("CommonScript/Player/PlayerAttribute.lua");
local tbDef = PlayerAttribute.tbDef;

function PlayerAttribute:AddStrength(pPlayer, nAdd)
    self:AddAttribValue(pPlayer, tbDef.nStrengthType, nAdd);
end

function PlayerAttribute:AddDexterity(pPlayer, nAdd)
    self:AddAttribValue(pPlayer, tbDef.nDexterityType, nAdd);
end

function PlayerAttribute:AddVitality(pPlayer, nAdd)
    self:AddAttribValue(pPlayer, tbDef.nVitalityType, nAdd);
end

function PlayerAttribute:AddEnergy(pPlayer, nAdd)
    self:AddAttribValue(pPlayer, tbDef.nEnergyType, nAdd);
end

function PlayerAttribute:AddAttribValue(pPlayer, nType, nAdd)
    if nAdd == 0 then
        Log("Error PlayerAttribute AddAttribValue", pPlayer.dwID, nType, nAdd);
        return;
    end

    local tbInfo = self:GetAttributInfo(nType);
    if not tbInfo then
        Log("Error PlayerAttribute AddAttribValue tbInfo", pPlayer.dwID, nType, nAdd);
        return;
    end   

    local nValue = pPlayer.GetUserValue(tbDef.nSaveGroupID, tbInfo.nSaveID);
    local nCurValue = nValue + nAdd;
    pPlayer.SetUserValue(tbDef.nSaveGroupID, tbInfo.nSaveID, nCurValue);
    self:UpdatePlayerAttrib(pPlayer, nType);
    pPlayer.CallClientScript("PlayerAttribute:UpdateSelfAttrib", nType, nAdd);
    pPlayer.CenterMsg(string.format("您獲得%s點%s", nAdd, tbInfo.szName or "-"), true);    
    Log("PlayerAttribute AddAttribValue", pPlayer.dwID, nType, nAdd, nCurValue, nValue);
end

function PlayerAttribute:UpdatePlayerAttrib(pPlayer, nType)
    local tbInfo = self:GetAttributInfo(nType);
    if not tbInfo then
        Log("Error PlayerAttribute UpdatePlayerAttrib tbInfo", pPlayer.dwID, nType);
        return;
    end

    local nValue = pPlayer.GetUserValue(tbDef.nSaveGroupID, tbInfo.nSaveID);
    local pAsyncData = KPlayer.GetAsyncData(pPlayer.dwID)
    if pAsyncData then
        pAsyncData.SetPlayerAttribute(tbInfo.nSaveID, nValue);
    end

    local pNpc = pPlayer.GetNpc();
    if not pNpc then
        return;
    end
        
    if nValue > 0 then
        self:SetAutoAttributeValue(pNpc, nType, nValue);
        --pPlayer.ApplyExternAttrib(tbInfo.nAttributeID, nValue);
    else
        self:SetAutoAttributeValue(pNpc, nType, 0);
        --pPlayer.RemoveExternAttrib(tbInfo.nAttributeID);
    end    
end

function PlayerAttribute:UpdatePlayerAllAttrib(pPlayer)
    for nType, tbInfo in pairs(tbDef.tbAttributeGroup) do
        local bRet = self:CheckSaveID(tbInfo.nSaveID);
        if bRet then
            local nValue = pPlayer.GetUserValue(tbDef.nSaveGroupID, tbInfo.nSaveID);
            if nValue > 0 then
                self:UpdatePlayerAttrib(pPlayer, nType);
            end
        end        
    end

    pPlayer.CallClientScript("PlayerAttribute:UpdateSelfAllAttrib");    
end

function PlayerAttribute:OnLogin()
    self:UpdatePlayerAllAttrib(me);
end

function PlayerAttribute:OnReConnect()
    me.CallClientScript("PlayerAttribute:UpdateSelfAllAttrib");
end

function PlayerAttribute:OnZoneLogin(nReconnected)
    if nReconnected == 1 then
        self:OnReConnect();
    else
        self:OnLogin();   
    end
end

function PlayerAttribute:OnReConnectZoneClient()
    self:OnReConnect();
end

PlayerEvent:RegisterGlobal("OnLogin",       PlayerAttribute.OnLogin, PlayerAttribute);
PlayerEvent:RegisterGlobal("OnReConnect",   PlayerAttribute.OnReConnect, PlayerAttribute);
PlayerEvent:RegisterGlobal("OnZoneLogin",   PlayerAttribute.OnZoneLogin, PlayerAttribute);
PlayerEvent:RegisterGlobal("OnReConnectZoneClient",  PlayerAttribute.OnReConnectZoneClient, PlayerAttribute);