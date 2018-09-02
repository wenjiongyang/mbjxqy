Fuben.ActivityFuben = Fuben.ActivityFuben or {}
local ActivityFuben = Fuben.ActivityFuben
ActivityFuben.nSitSkill     = 1083  -- 打坐动作
ActivityFuben.nEffectId     = 1086  -- 修炼身上的特效
ActivityFuben.nExpDelayTime = 5     --每次经验间隔时间
ActivityFuben.nExpAddTimes  = 10    --加多少次经验
ActivityFuben.nBasicexp     = 10     --每次加的经验

function ActivityFuben:GetFubenSetting(szRoom)
    self.tbRoomSetting = self.tbRoomSetting or {}
    self.tbRoomSetting[szRoom] = self.tbRoomSetting[szRoom] or {szFubenClass = "ActivityFubenBase"}
    return self.tbRoomSetting[szRoom]
end




local tbFuben = Fuben:CreateFubenClass("ActivityFubenBase")
function tbFuben:OnPreCreate(nP1ID, nP2ID, nMapTID)
    self.tbActPlayer = {nP1ID, nP2ID}
    self.nMapTID     = nMapTID
    self.nStartTime  = GetTime()
end

function tbFuben:OnJoin(pPlayer)
    pPlayer.CallClientScript("Ui:OpenWindow", "HomeScreenFuben", "TeamFuben")
end

function tbFuben:OnFirstJoin(pPlayer)
    if not self.tbSetting.tbNeedSpecialPointFaction or not self.tbSetting.tbNeedSpecialPointFaction[pPlayer.nFaction] then
        return
    end

    local nX, nY, nDir = unpack(self.tbSetting.tbSpecialPoint)
    pPlayer.SetPosition(nX, nY)
    if self.tbSetting.tbSkillState then
        local nSkill, nTime = unpack(self.tbSetting.tbSkillState)
        pPlayer.AddSkillState(nSkill, 1, 0, Env.GAME_FPS * nTime)
    end
    pPlayer.GetNpc().SetDir(nDir)
end

function tbFuben:fnAllPlayer(fnSc, ...)
    for _, nPlayerId in pairs(self.tbActPlayer or {}) do
        local pPlayer = KPlayer.GetPlayerObjById(nPlayerId)
        if pPlayer and pPlayer.nMapTemplateId == self.nMapTID then
            fnSc(pPlayer, ...)
        end
    end
end

function tbFuben:TryBeginDazuo(dwID)
    if self.nDazuoPlayer then
        return
    end
    self.nDazuoPlayer = dwID
    self.nExpAddTimes = ActivityFuben.nExpAddTimes
    if self.tbSetting.nStartWorshipUnlockId then
        self:UnLock(self.tbSetting.nStartWorshipUnlockId)
    end
    local nIndex = 0
    local function fnSit(pPlayer)
        ActionMode:DoForceNoneActMode(pPlayer)
        nIndex = nIndex + 1
        local tbWorshipInfo = self.tbSetting.tbWorshipInfo
        if tbWorshipInfo then
            local tbPlayerWorshipInfo = tbWorshipInfo[nIndex]
            if tbPlayerWorshipInfo then
                local tbPos = tbPlayerWorshipInfo.tbPos
                if tbPos then
                    pPlayer.SetPosition(unpack(tbPos))
                end
                local nDir = tbPlayerWorshipInfo.nDir
                if nDir then
                    local pNpc = pPlayer.GetNpc()
                    if pNpc then
                        local _, nX, nY = pPlayer.GetWorldPos()
                        pNpc.CastSkill(ActivityFuben.nSitSkill, 1, nX, nY)
                        pNpc.SetDir(nDir)
                    end
                end
            end
        end
        pPlayer.AddSkillState(ActivityFuben.nEffectId, 1, 0, Env.GAME_FPS * ActivityFuben.nExpDelayTime * self.nExpAddTimes)
        pPlayer.CallClientScript("ChuangGong:BeginChuangGong", pPlayer.dwID, nil, nil, nil, self.nMapTID, nil, "ActivityFuben")
    end
    self:fnAllPlayer(fnSit)
    Timer:Register(Env.GAME_FPS * ActivityFuben.nExpDelayTime, self.AddPlayerExp, self)
end

function tbFuben:AddPlayerExp()
    self.nExpAddTimes = self.nExpAddTimes - 1
    local fnAddExp = function (pPlayer)
        pPlayer.SendAward({{"BasicExp", ActivityFuben.nBasicexp}}, false, false, Env.LogWay_ActivityFuben)
        pPlayer.CallClientScript("ChuangGong:SendOne", self.nExpAddTimes)
    end
    self:fnAllPlayer(fnAddExp)

    if self.nExpAddTimes <= 0 then
        local fnDone = function (pPlayer)
            pPlayer.CallClientScript("Ui:CloseWindow", "ChuangGongPanel")
            local pNpc = pPlayer.GetNpc()
            if pNpc then
                pNpc.RestoreAction()
            end
            pPlayer.RemoveSkillState(ActivityFuben.nEffectId)
        end
        self:fnAllPlayer(fnDone)
        return false
    end

    return true
end

function tbFuben:OnPlayerDeath()
    me.Revive(0)
end

function tbFuben:GameWin()
    Activity:OnGlobalEvent("DYRAct_TryCompleteFuben", self.tbActPlayer, self.nMapTID)
    self:Close()
    self.bWin = true
end

function tbFuben:OnClose()
    local fnExcute = function (pPlayer)
        pPlayer.CallClientScript("Fuben:ShowLeave")
    end
    self:AllPlayerInMapExcute(fnExcute)
end

function tbFuben:OnLeaveMap(pPlayer)
    local nTime = GetTime() - self.nStartTime
    pPlayer.TLogRoundFlow(Env.LogWay_ActivityFuben, pPlayer.nMapTemplateId, 0, nTime, self.bWin and Env.LogRound_SUCCESS or Env.LogRound_FAIL, 0, 0)
    pPlayer.CallClientScript("Ui:CloseWindow", "HomeScreenFuben")
end