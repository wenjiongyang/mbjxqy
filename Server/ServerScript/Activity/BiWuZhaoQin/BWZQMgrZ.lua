BiWuZhaoQin.tbFightInfo = BiWuZhaoQin.tbFightInfo or {};

BiWuZhaoQin.tbServerPreMapInfo = BiWuZhaoQin.tbServerPreMapInfo or {};
BiWuZhaoQin.tbApplyPreMapID = BiWuZhaoQin.tbApplyPreMapID or {}

BiWuZhaoQin.tbAllPreMapLogic = BiWuZhaoQin.tbAllPreMapLogic or {};
BiWuZhaoQin.tbAllMapFight2Pre = BiWuZhaoQin.tbAllMapFight2Pre or {}

function BiWuZhaoQin:Start(nTargetId,nKinId,szTimeFrame, bNpcType)
    if not nTargetId or not nKinId then
        Log("BiWuZhaoQin Start Fail ",nTargetId,nKinId,szTimeFrame)
        return
    end

	local tbFightInfo = self:GetFightInfo(nTargetId)
	if tbFightInfo then
		Log("[BiWuZhaoQin] try start same fight during ZhaoQin",nTargetId,nKinId,szTimeFrame)
        Lib:LogTB(tbFightInfo)
	end

    local nType = nKinId == 0 and BiWuZhaoQin.TYPE_GLOBAL or BiWuZhaoQin.TYPE_KIN
    local nCurConnectIdx = Server.nCurConnectIdx
    tbFightInfo = self:Init(nType,nTargetId,nKinId,nCurConnectIdx,szTimeFrame, bNpcType)
	local nPreMapId = self:CreatePreMapZ(nTargetId)
    if not nPreMapId then
        self.tbFightInfo[nTargetId] = nil
        Log("[BiWuZhaoQin] create pre map fail ",nTargetId,nKinId,szTimeFrame)
        return
    end
	tbFightInfo.nPreMapId = nPreMapId
    Log("BiWuZhaoQin Start ",nTargetId,nKinId,szTimeFrame, bNpcType and "true" or "false");
end

function BiWuZhaoQin:Init(nType,nTargetId,nKinId,nCurConnectIdx,szTimeFrame, bNpcType)
	self.tbFightInfo[nTargetId] =
		{
			nType = nType,
			nTargetId = nTargetId,
			nRound = 1,
			tbPlayer = {},
			nProcess = BiWuZhaoQin.Process_Pre,
			nPreMapId = nil,
			nConnectIdx = nCurConnectIdx,
			tbFinalPlayer = {},
			nFinalRound = 0,
            nKinId = nKinId,
            tbFinalLostPlayer = {},                     -- 失去资格的8强玩家
            tbFailPlayer = {},                          -- 所有战败的玩家
            szTimeFrame = szTimeFrame,
            nJoin = 0,
            bNpcType = bNpcType,
		}

	self.tbFightInfo[nTargetId].tbPlayer[self.tbFightInfo[nTargetId].nRound] = {}

	return self.tbFightInfo[nTargetId]
end

function BiWuZhaoQin:GetFightInfo(nTargetId)
	return self.tbFightInfo[nTargetId]
end

function BiWuZhaoQin:ClearFightInfo(nTargetId)
    if self.tbFightInfo[nTargetId] then
        self.tbFightInfo[nTargetId] = nil
        Log("BiWuZhaoQin fnClearFightInfo ok",nTargetId)
    end
end

function BiWuZhaoQin:GetServerPreMapInfo(nTargetId)
    local tbInfo = self.tbServerPreMapInfo[nTargetId];
    if not tbInfo then
        tbInfo =
        {
            nMapId = nil;
            bApplyMap = false;
        };

        self.tbServerPreMapInfo[nTargetId] = tbInfo;
    end

    return tbInfo;
end

function BiWuZhaoQin:ClearServerPreMapInfo(nTargetId)
    self.tbServerPreMapInfo[nTargetId] = nil
end

function BiWuZhaoQin:CreatePreMapZ(nTargetId)
    local tbMapInfo = self:GetServerPreMapInfo(nTargetId);
    if tbMapInfo.bApplyMap then
        Log("BiWuZhaoQin fnCreatePreMapZ ApplyMap Error", nTargetId);
        return;
    end

    local nMapId = tbMapInfo.nMapId;
    if nMapId then
        BiWuZhaoQin:ClosePreMapLogic(nMapId);
    end

    tbMapInfo.nMapId = nil;
    tbMapInfo.bApplyMap = true;

    local nCreateMapId = CreateMap(BiWuZhaoQin.nPreMapTID);
    self.tbApplyPreMapID[nCreateMapId] = nTargetId;

    Log("BiWuZhaoQin fnCreatePreMapZ", nTargetId);
    return nCreateMapId
end

-- 没人参加结束
function BiWuZhaoQin:OnEndZhaoQin(tbPreMapLogic,tbFightInfo)
    if tbPreMapLogic.OnEnd then
        tbPreMapLogic:OnEnd()
    end
    Lib:CallBack({BiWuZhaoQin.EndTip,BiWuZhaoQin,tbPreMapLogic})
    CallZoneClientScript(tbFightInfo.nConnectIdx,"BiWuZhaoQin:OnEndZhaoQinS", tbPreMapLogic.nMapId, tbPreMapLogic.nTargetId, tbFightInfo.nType, tbFightInfo.tbPlayer, tbFightInfo.tbFinalLostPlayer)
    BiWuZhaoQin:ClearFightInfo(tbPreMapLogic.nTargetId)
    Log("BiWuZhaoQin fnOnEndZhaoQin", tbPreMapLogic:GetLog());
end

-- 决出优胜者
function BiWuZhaoQin:OnCompleteZhaoQin(tbFightInfo,tbPreMapLogic,nWinerId)
    if tbPreMapLogic.OnEnd then
        tbPreMapLogic:OnEnd()
    end
    Lib:CallBack({BiWuZhaoQin.CompleteTip,BiWuZhaoQin,tbPreMapLogic,nWinerId})
    CallZoneClientScript(tbFightInfo.nConnectIdx,"BiWuZhaoQin:OnCompleteZhaoQinS", nMapId, tbPreMapLogic.nTargetId, nWinerId, tbFightInfo.nType, tbFightInfo.tbPlayer, tbFightInfo.tbFinalLostPlayer)
    BiWuZhaoQin:ClearFightInfo(tbPreMapLogic.nTargetId)
    Log("BiWuZhaoQin fnOnCompleteZhaoQin ", nWinerId,tbPreMapLogic:GetLog());
end

function BiWuZhaoQin:EndTip(tbPreMapLogic)
    local fnMsg = function (self,pPlayer)
        local szMsg = "由於沒人參加比賽或參賽者失去資格,比賽結束！"
        pPlayer.Msg(szMsg)
        Dialog:SendBlackBoardMsg(pPlayer, szMsg)
    end
    tbPreMapLogic:ForeachMapPlayer(fnMsg)
end

function BiWuZhaoQin:CompleteTip(tbPreMapLogic,nWinerId)
    local szMsg = ""
    local pWiner = KPlayer.GetPlayerObjById(nWinerId)
    if pWiner then
        szMsg = "恭喜您獲得了比賽冠軍！"
        pWiner.Msg(szMsg)
        Dialog:SendBlackBoardMsg(pWiner, szMsg)
    end
    local tbPlayerInfo = tbPreMapLogic.tbJoinPlayerInfo[nWinerId] or {}
    local szName = tbPlayerInfo.szName or "未知"
    szMsg = string.format("恭喜俠士[FFFE0D]%s[-]獲得了本場比武招親比賽的冠軍！",szName)
    local fnMsg = function (self,pPlayer)
        pPlayer.Msg(szMsg)
        Dialog:SendBlackBoardMsg(pPlayer, szMsg)
    end
    tbPreMapLogic:ForeachMapPlayer(fnMsg)
end

function BiWuZhaoQin:OnStartZhaoQin(tbPreMapLogic)
    CallZoneClientScript(tbPreMapLogic.nConnectIdx, "BiWuZhaoQin:OnStartZhaoQinS", tbPreMapLogic.nMapId, tbPreMapLogic.nTargetId, tbPreMapLogic.nType, tbPreMapLogic.nKinId, tbPreMapLogic.bNpcType);

    Log("BiWuZhaoQin fnOnStartZhaoQin", tbPreMapLogic:GetLog());
end

function BiWuZhaoQin:GetPreMapLogic(nMapId)
    return self.tbAllPreMapLogic[nMapId];
end

function BiWuZhaoQin:Report(nPreMapId,nWinPlayerId,nLostPlayerId)
    local tbPreMapLogic = BiWuZhaoQin:GetPreMapLogic(nPreMapId)
    if not tbPreMapLogic then
        Log("BiWuZhaoQin Report no tbPreMapLogic", nPreMapId, nWinPlayerId or -1, nLostPlayerId or -1)
        return
    end
    local tbFightInfo = BiWuZhaoQin:GetFightInfo(tbPreMapLogic.nTargetId)
    if not tbFightInfo then
        Log("BiWuZhaoQin Report no tbFightInfo", nWinPlayerId or -1, nLostPlayerId or -1, tbPreMapLogic:GetLog());
        return
    end

    if not tbFightInfo.tbPlayer[tbFightInfo.nRound] then
        Log("BiWuZhaoQin Report no Round tbPlayer", nWinPlayerId or -1, nLostPlayerId or -1, tbPreMapLogic:GetLog());
        return
    end

    tbFightInfo.tbPlayer[tbFightInfo.nRound][nWinPlayerId] = GetTime()
    tbPreMapLogic.nFightCount = tbPreMapLogic.nFightCount - 1

    local nNowTime = GetTime()

    local pWinner = KPlayer.GetPlayerObjById(nWinPlayerId or 0)
    if pWinner then
        tbPreMapLogic:UpdatePlayerUi(pWinner,BiWuZhaoQin.tbFightState.Next)
    end

    local pLoster = KPlayer.GetPlayerObjById(nLostPlayerId or 0)
    if pLoster then
        tbFightInfo.tbFailPlayer[nLostPlayerId] = nNowTime
        tbPreMapLogic:UpdatePlayerUi(pLoster,BiWuZhaoQin.tbFightState.Out)
    end

    if tbPreMapLogic.nFightCount <= 0 then
        -- 关闭自动匹配定时器,手动匹配
        tbPreMapLogic:CloseAutoMatchTimer()
        tbPreMapLogic:CloseAutoMatchFinalTimer()
        self:OnNextMatch(nPreMapId)
    end
    Log("BiWuZhaoQin Report ", nWinPlayerId or -1, nLostPlayerId or -1, tbPreMapLogic:GetLog(), tbFightInfo.nRound)
end

-- 准备下次匹配
function BiWuZhaoQin:OnNextMatch(nPreMapId, bAuto)
    if bAuto then
        Log("BiWuZhaoQin fnOnNextMatch auto", nPreMapId)
    end
    local tbPreMapLogic = BiWuZhaoQin:GetPreMapLogic(nPreMapId)
    if not tbPreMapLogic then
        Log("BiWuZhaoQin fnOnNextMatch no tbPreMapLogic", nPreMapId)
        return
    end

    tbPreMapLogic.nAutoMatchTimer = nil
    tbPreMapLogic.nAutoMatchFinalTimer = nil

    local tbFightInfo = BiWuZhaoQin:GetFightInfo(tbPreMapLogic.nTargetId)
    if not tbFightInfo then
        Log("BiWuZhaoQin fnOnNextMatch no tbFightInfo", tbPreMapLogic.nTargetId);
        return
    end

    BiWuZhaoQin:CheckNextStep(tbPreMapLogic)

    Log("BiWuZhaoQin fnOnNextMatch", tbPreMapLogic.nTargetId, tbPreMapLogic.nType,nPreMapId, nCount)
end

function BiWuZhaoQin:CheckNextStep(tbPreMapLogic)
    -- 关闭自动匹配
    tbPreMapLogic:CloseAutoMatchTimer()
    tbPreMapLogic:CloseAutoMatchFinalTimer()
     -- 没限制返回玩家
    local tbAllPlayer = tbPreMapLogic:UpdatePlayer()
    local nCount = #tbAllPlayer

     if nCount <= BiWuZhaoQin.nFinalNum then
        -- 打过第一场以后进入8强赛
        tbPreMapLogic:OnFinalFight(tbAllPlayer)
    else
        tbPreMapLogic:CloseTaoTaiFightTimer()
        tbPreMapLogic.nTaoTaiFightTimer = Timer:Register(Env.GAME_FPS * BiWuZhaoQin.nMatchWaitTime, BiWuZhaoQin.Process, BiWuZhaoQin, tbPreMapLogic.nMapId)
        tbPreMapLogic:ForeachMapPlayer(tbPreMapLogic.UpdatePlayerUi)
    end
end

function BiWuZhaoQin:Process(nPreMapId, bFirst)
    local tbPreMapLogic = BiWuZhaoQin:GetPreMapLogic(nPreMapId)
    if not tbPreMapLogic then
        Log("BiWuZhaoQin fnProcess no tbPreMapLogic", nPreMapId)
        return
    end
    tbPreMapLogic.nTaoTaiFightTimer = nil
    local tbFightInfo = BiWuZhaoQin:GetFightInfo(tbPreMapLogic.nTargetId)
    if not tbFightInfo then
        Log("BiWuZhaoQin fnProcess no tbFightInfo", nPreMapId, tbPreMapLogic:GetLog());
        return
    end
    -- 更新符合条件的玩家，准备战斗
    local tbAllPlayer = tbPreMapLogic:UpdatePlayer(true)

    local nCount = #tbAllPlayer
    if nCount <= 0 then
        -- 没人参与
        BiWuZhaoQin:OnEndZhaoQin(tbPreMapLogic, tbFightInfo)
        return
    end

    if bFirst then
        CallZoneClientScript(tbFightInfo.nConnectIdx, "BiWuZhaoQin:OnFirstFightS", tbFightInfo)
    end

    -- 第一场进入8强
    if nCount <= BiWuZhaoQin.nFinalNum then
        tbPreMapLogic:OnFinalFight(tbAllPlayer)
        return
    end

    tbPreMapLogic:TryFight(tbFightInfo, tbAllPlayer)
    Log("BiWuZhaoQin fnProcess ", tbFightInfo.nRound, tbPreMapLogic:GetLog())
end

function BiWuZhaoQin:GetWatchTrapInfo(szTrapName)
    return szTrapName and ArenaBattle.TrapData[szTrapName]
end

function BiWuZhaoQin:OnFightClose(nPreMapId,nMapId)
	local tbPreMapLogic = BiWuZhaoQin:GetPreMapLogic(nPreMapId)
    if not tbPreMapLogic then
        Log("BiWuZhaoQin fnOnFightClose no tbPreMapLogic",nPreMapId)
        return
    end

    tbPreMapLogic:EndArenaWatch(nMapId)
end

function BiWuZhaoQin:OnTryEnterPreMap(dwID,nPreMapId,bNoJoin)
    local tbPreMapLogic = BiWuZhaoQin:GetPreMapLogic(nPreMapId)
    if not tbPreMapLogic then
        Log("BiWuZhaoQin fnOnTryEnterPreMap no tbPreMapLogic",nPreMapId)
        return
    end
    if bNoJoin then
        tbPreMapLogic:CachePlayerWilling(dwID,bNoJoin)
    end
end

function BiWuZhaoQin:UpdateNormalKinName(pPlayer)
    Timer:Register(2, self.OnUpdateNormalKinName, self, pPlayer.dwID);
end

function BiWuZhaoQin:OnUpdateNormalKinName(nPlayerID)
    local pPlayer = KPlayer.GetPlayerObjById(nPlayerID);
    if not pPlayer then
        return;
    end

    local KinMgr = GetKinMgr();
    local szTitle = KinMgr.GetTitle(pPlayer.dwID) or "";
    if pPlayer.dwKinId ~= 0 and not Lib:IsEmptyStr(szTitle) then
        local szKinName = string.match(szTitle, "^［.*服］(.+)$");
        if szKinName then
            szKinName = string.format("%s%s", "［幫派］", szKinName);
        else
            szKinName = szTitle;
        end

        Kin:SyncTitle(pPlayer.dwID, szKinName)
    end
end