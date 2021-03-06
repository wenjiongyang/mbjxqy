

OpenLight.nSaveGroupID = 47;
OpenLight.nSaveLightID = 1;
OpenLight.nSaveLightTime = 2;


OpenLight.nExtAttribGroupID = 4; --激活属性的GroupID

OpenLight.tbRealLevlMsg = 
{
    [7] = "40級稀有裝備";
}

function OpenLight:LoadSetting()
    self.tbLightSetting = {};
    self.tbFactionEffect = {};

    local tbFileData = Lib:LoadTabFile("Setting/Item/OpenLight/OpenLightStone.tab", {ExtAttribLevel = 1, WeaponRealLevel = 1, 
        EffectID = 1, TimeOut = 1, LightStoneID = 1, LightType = 1, LightLevel = 1});
    for nRow, tbInfo in pairs(tbFileData) do
        self.tbLightSetting[tbInfo.LightStoneID] = tbInfo;
    end

    tbFileData = Lib:LoadTabFile("Setting/Item/OpenLight/FactionEffect.tab", {EffectID = 1, FactionID = 1, LightResID = 1});
    for nRow, tbInfo in pairs(tbFileData) do
        self.tbFactionEffect[tbInfo.EffectID] = self.tbFactionEffect[tbInfo.EffectID] or {};
        self.tbFactionEffect[tbInfo.EffectID][tbInfo.FactionID] = tbInfo;
    end
        
end

OpenLight:LoadSetting();

function OpenLight:GetLightSetting(nLightID)
    if nLightID <= 0 then
        return;
    end

    return self.tbLightSetting[nLightID];
end

function OpenLight:CheckOpenLight(pPlayer, nItemID)
    local pItem = pPlayer.GetItemInBag(nItemID);
    if not pItem then
        return false, "道具不存在！";
    end    

    if pItem.szClass ~= "OpenLightStone" then
        return false, "請使用附魔石";
    end

    local tbLightInfo = self:GetLightSetting(pItem.dwTemplateId);
    if not tbLightInfo then
        return false, "尚未開啟";
    end

    local pEquip = pPlayer.GetEquipByPos(Item.EQUIPPOS_WEAPON);
    if not pEquip then
        return false, "請穿上武器再進行附魔"
    end    

    if tbLightInfo.WeaponRealLevel > pEquip.nRealLevel then
        return false, string.format("%s以上裝備，才進行附魔", self.tbRealLevlMsg[tbLightInfo.WeaponRealLevel] or "40級稀有裝備");
    end

    local nCurLightID = pPlayer.GetUserValue(self.nSaveGroupID, self.nSaveLightID); 
    local tbCurLight = self:GetLightSetting(nCurLightID);
    if tbCurLight and tbCurLight.LightType == tbLightInfo.LightType and 
       tbCurLight.LightLevel > tbLightInfo.LightLevel then
       return false, "不能替換高級屬性"
    end    

    return true, "", tbLightInfo, pItem;   
end

function OpenLight:CheckUseLightType(pPlayer, nItemID)
    local bRet, szMsg, tbLightInfo, pItem = self:CheckOpenLight(pPlayer, nItemID);
    if not bRet then
        return false, szMsg; 
    end    

    local tbRetInfo = self:GetResidueStoneTime(pPlayer, tbLightInfo);
    if not tbRetInfo then
        return true, "";
    end

    if tbRetInfo.nRetTime > 0 and tbRetInfo.nRetCount == 0 then
        return true, "";
    end

    local nCurLightID = pPlayer.GetUserValue(self.nSaveGroupID, self.nSaveLightID);
    local tbCurLight = self:GetLightSetting(nCurLightID);
    local tbCurItemInfo = KItem.GetItemBaseProp(tbCurLight.LightStoneID); 
    local szMsg = string.format("用[64db00]%s[-]替換掉現有的[64db00]%s[-]", pItem.szName, tbCurItemInfo.szName);
    if tbRetInfo.nRetCount > 0 then
        local szName = KItem.GetItemShowInfo(tbRetInfo.nStoneID);
        szMsg = szMsg..string.format(",並獲得[64db00]%s個%s[-]", tbRetInfo.nRetCount, szName);
    end

    return true, szMsg, true;    
end

function OpenLight:GetResidueStoneTime(pPlayer, tbLightInfo)
    local nCurLightID = pPlayer.GetUserValue(self.nSaveGroupID, self.nSaveLightID);
    local nEndTime    = pPlayer.GetUserValue(self.nSaveGroupID, self.nSaveLightTime);
    if nCurLightID == 0 then 
        return;
    end

    local nRetTime    = 0;
    local nRetCount   = 0;
    local nStoneID    = 0;
    local tbCurLight = self:GetLightSetting(nCurLightID);
    if tbCurLight.LightStoneID == tbLightInfo.LightStoneID then
        nRetTime = nEndTime - GetTime();
    else
        local nCurRetTime  = nEndTime - GetTime();
        local nTimeOut  = tbLightInfo.TimeOut;
        nRetCount = 1;
        nRetTime  = 0;
        nStoneID  = tbCurLight.LightStoneID;
        if nTimeOut > 0 then
            nRetCount = math.floor(nCurRetTime / nTimeOut);
        end    
    end

    nRetTime = math.max(0, nRetTime);
    nRetCount = math.max(0, nRetCount);
    return {nRetTime = nRetTime, nRetCount = nRetCount, nStoneID = nStoneID};
end

function OpenLight:OpenLightItem(pPlayer, nItemID)
    local bRet, szMsg, tbLightInfo, pItem = self:CheckOpenLight(pPlayer, nItemID);
    if not bRet then
        pPlayer.CenterMsg(szMsg);
        return;
    end

    pPlayer.ConsumeItem(pItem, 1, Env.LogWay_OpenLightStone);
    local tbRetInfo = self:GetResidueStoneTime(pPlayer, tbLightInfo);
    local nTimeOut = tbLightInfo.TimeOut;
    if tbRetInfo then
        nTimeOut = tbRetInfo.nRetTime + nTimeOut;  

        if tbRetInfo.nRetCount > 0 and tbRetInfo.nStoneID > 0 then
            local tbAward = {{"item", tbRetInfo.nStoneID, tbRetInfo.nRetCount}};
            pPlayer.SendAward(tbAward, true, nil, Env.LogWay_OpenLightStone);
        end    
    end

    local nEndTime = nTimeOut + GetTime();
    nEndTime = math.min(Env.INT_MAX, nEndTime);
    pPlayer.SetUserValue(self.nSaveGroupID, self.nSaveLightTime, nEndTime);
    pPlayer.SetUserValue(self.nSaveGroupID, self.nSaveLightID, tbLightInfo.LightStoneID);
    self:ServerUpdateOpenLight(pPlayer);
    pPlayer.CenterMsg("武器附魔成功！");
    Log("OpenLight OpenLightItem Result", pPlayer.dwID, nEndTime, tbLightInfo.LightStoneID);
end

function OpenLight:GetFactionEffect(nEffectID, nFactionID)
    local tbEffectInfo = self.tbFactionEffect[nEffectID];
    if not tbEffectInfo then
        return 0;
    end

    local tbInfo = tbEffectInfo[nFactionID];
    if not tbInfo then
        return 0;
    end    

    return tbInfo.LightResID;    
end

function OpenLight:GetFactionEffectByLight(nLightID, nFactionID)
    local tbLightInfo = self:GetLightSetting(nLightID);
    if not tbLightInfo then
        return 0;
    end

    local nResId = self:GetFactionEffect(tbLightInfo.EffectID, nFactionID);
    return nResId;
end

function OpenLight:OnClientUpdate()
    self:UpdateAttribOpenLight(me);
    Log("OpenLight OnClientUpdate");
end

function OpenLight:UpdateAttribOpenLight(pPlayer)
    local pNpc = pPlayer.GetNpc();
    local nLightID = pPlayer.GetUserValue(self.nSaveGroupID, self.nSaveLightID);
    local nEndTime = pPlayer.GetUserValue(self.nSaveGroupID, self.nSaveLightTime);
    pPlayer.RemoveExternAttrib(self.nExtAttribGroupID);
    pNpc.ModifyPartFeatureEquip(Npc.NpcResPartsDef.npc_part_weapon, 0, Npc.NpcPartLayerDef.npc_part_layer_effect);
    
    local nEffectResId = 0;
    local tbLightInfo = self:GetLightSetting(nLightID);
    if tbLightInfo then
        pPlayer.ApplyExternAttrib(self.nExtAttribGroupID, tbLightInfo.ExtAttribLevel);
        nEffectResId = self:GetFactionEffect(tbLightInfo.EffectID, pPlayer.nFaction);

        local pEquip = pPlayer.GetEquipByPos(Item.EQUIPPOS_WEAPON);
        if pEquip then
            pNpc.ModifyPartFeatureEquip(Npc.NpcResPartsDef.npc_part_weapon, nEffectResId, Npc.NpcPartLayerDef.npc_part_layer_effect);
        end    
    end

    return nLightID, nEndTime, nEffectResId;
end

function OpenLight:ServerUpdateOpenLight(pPlayer)
    local pNpc = pPlayer.GetNpc();
    if not pNpc then
        Log("Error OpenLight ServerUpdateOpenLight Not Npc", pPlayer.dwID);
        return;
    end    

    local nLightID, nEndTime, nEffectResId = self:UpdateAttribOpenLight(pPlayer);
    local pAsyncData = KPlayer.GetAsyncData(pPlayer.dwID)
    if pAsyncData then
        pAsyncData.SetOpenLight(nLightID);
    end
        
    pPlayer.SetOpenLight(nEffectResId, nEndTime);
    pPlayer.CallClientScript("OpenLight:OnClientUpdate");
    Log("OpenLight ServerUpdateOpenLight", pPlayer.dwID, nEndTime, nLightID, nEffectResId);
end

function OpenLight:OnEndTimeOut()
    local nLightID = me.GetUserValue(self.nSaveGroupID, self.nSaveLightID);
    me.SetUserValue(self.nSaveGroupID, self.nSaveLightTime, 0);
    me.SetUserValue(self.nSaveGroupID, self.nSaveLightID, 0);
    self:ServerUpdateOpenLight(me);
    
    local tbCurLightInfo = self:GetLightSetting(nLightID);
if MODULE_GAMESERVER and tbCurLightInfo then
    local szMailInfo = string.format("    您的【%s】已過期。", KItem.GetItemShowInfo(tbCurLightInfo.LightStoneID) or "-");
    local tbMail =
    {
        To = me.dwID,
        Text = szMailInfo;
    }
    Mail:SendSystemMail(tbMail);
end    
    Log("OpenLight OnEndTimeOut", me.dwID);
end

function OpenLight:OnLogin(pPlayer)
    local nLightID = pPlayer.GetUserValue(self.nSaveGroupID, self.nSaveLightID);
    if nLightID <= 0 then
        return;
    end    

    self:ServerUpdateOpenLight(pPlayer);
end

function OpenLight:GetLightAttribMsg(nLightID)
    local tbLightInfo = self:GetLightSetting(nLightID);
    if not tbLightInfo then
        return;
    end

    local tbItemInfo = KItem.GetItemBaseProp(tbLightInfo.LightStoneID);
    local tbExtAttrib = KItem.GetExternAttrib(OpenLight.nExtAttribGroupID, tbLightInfo.ExtAttribLevel);
    if not tbExtAttrib then
        return; 
    end
    
    local tbAttibMsg = {};
    local tbEquip = Item:GetClass("equip");    
    for _, tbAttrib in ipairs(tbExtAttrib) do
        local szDesc = tbEquip:GetMagicAttribDesc(tbAttrib.szAttribName, tbAttrib.tbValue);
        if not Lib:IsEmptyStr(szDesc) then
            table.insert(tbAttibMsg, {szDesc, tbItemInfo.nQuality});
        end 
    end

    return tbAttibMsg, tbItemInfo.nQuality;
end