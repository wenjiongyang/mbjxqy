Require("CommonScript/QunYingHui/QunYingHuiDef.lua");
Require("ServerScript/QunYingHui/QunYingHuiMgr.lua");

local tbDef = QunYingHui.tbDefInfo;
local tbPrepareMap = Map:GetClass(tbDef.nPrepareTempMapID)

function tbPrepareMap:OnCreate(nMapId)
    QunYingHui.nEnterMapID = nMapId;
    QunYingHui.bStartCreateEnterMap = false;
    self.nMapId = nMapId;
    self.nPlayerCount = 0;
    self.nLastPlayerCount = 0;
    self.nSendInfoTimer = Timer:Register(3 * Env.GAME_FPS, self.OnSendQYHUpdateInfo, self);
    Log("QunYingHui EnterMap OnCreate", nMapId, tbDef.nPrepareTempMapID);
end

function tbPrepareMap:OnSendQYHUpdateInfo()
    if self.nLastPlayerCount ~= self.nPlayerCount and QunYingHui.nTotalMatchCount > 0 then
        self:ForEachInMap(self.UpdateQYHInfo);
    end

    self.nLastPlayerCount = self.nPlayerCount;
    return true;
end

function tbPrepareMap:UpdateQYHInfo(pPlayer)
    if not pPlayer.bQYHLeftInfo then
        return;
    end

    pPlayer.CallClientScript("Ui:DoLeftInfoUpdate", {self.nPlayerCount});
end

function tbPrepareMap:OnDestroy(nMapId)
    QunYingHui.nEnterMapID = nil;
    QunYingHui.bStartCreateEnterMap = false;

    if self.nSendInfoTimer then
        Timer:Close(self.nSendInfoTimer);
        self.nSendInfoTimer = nil;
    end

    Log("QunYingHui EnterMap OnDestroy", nMapId, tbDef.nPrepareTempMapID);
end

function tbPrepareMap:OnEnter(nMapId)
    self.nPlayerCount = self.nPlayerCount + 1;
    local bRet, szMsg = QunYingHui:CheckPlayeGame(me);
    if not bRet then
        me.Msg(szMsg);
        me.GotoEntryPoint();
        return;
    end

    self:UpdateUIInfo(me);
    Log("QunYingHui EnterMap OnEnter", nMapId, me.dwID, me.szName);
end


function tbPrepareMap:UpdateUIInfo(pPlayer)
    if QunYingHui.nTotalMatchCount > 0 then
        pPlayer.CallClientScript("Ui:OpenWindow", "QYHLeftInfo", "QunYingHui", {self.nPlayerCount});
    end

    QunYingHui:UpdatePlayerUiShow(pPlayer);
    pPlayer.bQYHLeftInfo = true;
    pPlayer.CallClientScript("Ui:ChangeUiState", Ui.STATE_GAME_FIGHT, false); 
end

function tbPrepareMap:OnLogin()
    self:UpdateUIInfo(me);
end

function tbPrepareMap:OnLeave(nMapId)
    self.nPlayerCount = self.nPlayerCount - 1;
    me.CallClientScript("Ui:CloseWindow", "QYHLeftInfo");
    me.CallClientScript("Ui:ChangeUiState");
    me.bQYHLeftInfo = nil;
    Log("QunYingHui EnterMap OnLeave", nMapId, me.dwID, me.szName);
end

function tbPrepareMap:ForEachInMap(fnFunction, ...)
    local tbPlayer = KPlayer.GetMapPlayer(self.nMapId);
    for _, pPlayer in ipairs(tbPlayer) do
        fnFunction(self, pPlayer, ...);
    end
end


local tbGameMap = Map:GetClass(tbDef.nGameTempMapID);

function tbGameMap:OnCreate(nMapId)
    local tbInst = Lib:NewClass(QunYingHui.tbGameBase);
    QunYingHui.tbMapGameInstance[nMapId] = tbInst;

    local tbPlayerInfo = QunYingHui:GetMatchInfo(nMapId);
    tbInst:OnCreate(nMapId, tbPlayerInfo.tbPlayer);
    QunYingHui.tbMapMatchPlayer[nMapId] = nil;
end

function tbGameMap:OnDestroy(nMapId)
    local tbInst = QunYingHui.tbMapGameInstance[nMapId];
    if not tbInst then
        return;
    end

    tbInst:OnDestroy(nMapId);
    QunYingHui.tbMapGameInstance[nMapId] = nil;
end

function tbGameMap:OnEnter(nMapId)
    local tbInst = QunYingHui.tbMapGameInstance[nMapId];
    if not tbInst then
        return;
    end

    QunYingHui.nEnterPKPlayerCount = QunYingHui.nEnterPKPlayerCount + 1;
    tbInst:OnEnter(nMapId);
end

function tbGameMap:OnLeave(nMapId)
    local tbInst = QunYingHui.tbMapGameInstance[nMapId];
    if not tbInst then
        return;
    end

    QunYingHui.nEnterPKPlayerCount = QunYingHui.nEnterPKPlayerCount - 1;
    QunYingHui:OnLeavePKLogic();
    tbInst:OnLeave(nMapId);
end

function tbGameMap:OnLogin(nMapId)
    local tbInst = QunYingHui.tbMapGameInstance[nMapId];
    if not tbInst then
        return;
    end

    tbInst:OnLogicLogin();
end    