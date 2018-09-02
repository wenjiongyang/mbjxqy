


function CommonWatch:RemovePlayerWatch(pPlayer)
    local tbAllWatchNpcID = pPlayer.tbAllWatchNpcID;
    if not tbAllWatchNpcID then
        return false;
    end

    local tbAllWatchNpcID = pPlayer.tbAllWatchNpcID;
    pPlayer.tbAllWatchNpcID = nil;
    for nNpcID, _ in pairs(tbAllWatchNpcID) do
        local pNpc = KNpc.GetById(nNpcID);
        if pNpc then
            pNpc.RemoveFromForceSyncSet(pPlayer.dwID); 
        end
    end

    return true;
end

function CommonWatch:CheckWatchPlayer(pPlayer, nNpcID)
    local pNpc = KNpc.GetById(nNpcID);
    if not pNpc then
        return false;
    end

    if pNpc.nMapId ~= pPlayer.nMapId then
        return false;
    end

    return true, pNpc;
end

function CommonWatch:WatchNpc(pPlayer, tbTeamNpcID, bNotChangeUi)
    self:RemovePlayerWatch(pPlayer);
    
    pPlayer.tbAllWatchNpcID = pPlayer.tbAllWatchNpcID or {};
    local tbSyncData = {};
    for nTeam, tbAllNpcID in pairs(tbTeamNpcID) do
        for nNpcID, NpcInfo in pairs(tbAllNpcID) do
            local bRet, pNpc = self:CheckWatchPlayer(pPlayer, nNpcID)
            if bRet then
                tbSyncData[nTeam] = tbSyncData[nTeam] or {};
                tbSyncData[nTeam][nNpcID] = {szName = pNpc.szName};  

                pNpc.AddToForceSyncSet(pPlayer.dwID);
                pPlayer.SyncNpc(pNpc.nId)
                pPlayer.tbAllWatchNpcID[pNpc.nId] = 1;

                if type(NpcInfo) == "table" then
                    local tbSyncHide = NpcInfo.tbSyncHide or {};
                    for nHideId, _ in pairs(tbSyncHide) do
                        local bHideRet, pHideNpc = self:CheckWatchPlayer(pPlayer, nHideId)
                        if bHideRet then
                            pHideNpc.AddToForceSyncSet(pPlayer.dwID);
                            pPlayer.SyncNpc(pHideNpc.nId)
                            pPlayer.tbAllWatchNpcID[pHideNpc.nId] = 1;
                        end    
                    end   
                end        
            end
        end    
    end

    pPlayer.CallClientScript("CommonWatch:WatchNpc", tbSyncData, bNotChangeUi);
end

function CommonWatch:DoEndWatch(pPlayer, bNotState)
    local bRet = self:RemovePlayerWatch(pPlayer);
    if not bRet then
        return;
    end

    pPlayer.CallClientScript("CommonWatch:DoEndWatch", bNotState);
    Log("CommonWatch DoEndWatch", pPlayer.dwID);  
end

function CommonWatch:OnLeaveMap(nMapTemplateId, nMapId)
    CommonWatch:DoEndWatch(me, true);
end

PlayerEvent:RegisterGlobal("OnLeaveMap",    CommonWatch.OnLeaveMap, CommonWatch);

CommonWatch.tbC2SRequest =
{
    ["DoEndWatch"] = function (pPlayer)
        CommonWatch:DoEndWatch(pPlayer);
    end;
}