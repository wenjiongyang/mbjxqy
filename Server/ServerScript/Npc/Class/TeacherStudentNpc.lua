local tbNpc   = Npc:GetClass("TeacherStudentNpc")

function tbNpc:OnDialog(szParam)
    local szOpenTimeFrame = TeacherStudent.tbTimeFrameSettings[1].szTimeFrame
    local nOpenTime = CalcTimeFrameOpenTime(szOpenTimeFrame)
    local nDaysToOpen = Lib:GetLocalDay(nOpenTime) - Lib:GetLocalDay()
    if nDaysToOpen>0 then
        Dialog:Show({
            Text = string.format("三人行必有我師焉……\n師徒系統將在[FFFE0D]%d天[-]後開放！", nDaysToOpen),
            OptList = {
                { Text = "知道了" },
            },
        }, me, him)
    else
        Dialog:Show({
            Text = "三人行必有我師焉……\n想要處理師徒關係都可以前來找我！",
            OptList = {
                { Text = "處理師徒關係", Callback = self.DealConnectionDlg, Param = {self} },
                { Text = "進行出師儀式", Callback = self.GraduateDlg, Param = {self} },
            },
        }, me, him)
    end
end

function tbNpc:DealConnectionDlg()
    Dialog:Show({
        Text = "你想如何處理師徒關係？",
        OptList = {
            { Text = "解除師徒關係", Callback = self.DismissDlg, Param = {self} },
            { Text = "取消解除師徒關係的申請", Callback = self.CancelDismissDlg, Param = {self} },
        },
    }, me, him)
end

function tbNpc:DismissDlg()
    local tbMe = TeacherStudent:GetPlayerScriptTable(me)
    local tbCanDismiss = {}

    for nTeacherId, tbTeacher in pairs(tbMe.tbTeachers or {}) do
        local pStay = KPlayer.GetRoleStayInfo(nTeacherId)
        if pStay then
            tbCanDismiss[nTeacherId] = {
                nId = nTeacherId,
                szName = pStay.szName,
                bTeacher = true,
                nLastAccept = tbMe.nAcceptCount>=TeacherStudent.Def.nAddStudentNoCdCount and tbMe.nLastAccept or 0,
                bGraduate = tbTeacher.bGraduate,
            }
        end
    end
    for nStudentId, tbStudent in pairs(tbMe.tbStudents or {}) do
        local pStay = KPlayer.GetRoleStayInfo(nStudentId)
        if pStay then
            tbCanDismiss[nStudentId] = {
                nId = nStudentId,
                szName = pStay.szName,
                bTeacher = false,
                nLastAccept = tbMe.nAcceptCount>=TeacherStudent.Def.nAddStudentNoCdCount and tbMe.nLastAccept or 0,
                bGraduate = tbStudent.bGraduate,
            }
        end
    end

    if not next(tbCanDismiss) then
        self:NoCanDismissDlg()
        return
    end

    self:DismissSelectDlg(tbCanDismiss)
end

function tbNpc:DismissSelectDlg(tbCanDismiss)
    local tbOpt = {}
    for nPlayerId, tbInfo in pairs(tbCanDismiss) do
        table.insert(tbOpt, {
            Text = string.format("與%s「%s」解除師徒關係", tbInfo.bTeacher and "師父" or "徒弟", tbInfo.szName),
            Callback = self.DismissSelectedDlg,
            Param = {self, tbInfo},
        })
    end

    Dialog:Show({
        Text = "你要和誰解除師徒關係？",
        OptList = tbOpt,
    }, me, him)
end

function tbNpc:DismissSelectedDlg(tbInfo)
    local bGraduate = tbInfo.bGraduate
    local nNow = GetTime()
    local nDismissDeadline = TeacherStudent:_ComputeDismissDeadline(bGraduate)
    local szTips = ""
    if bGraduate then
        szTips = string.format("[FFFE0D]%s[-]是已出師%s，該申請需花費[FFFE0D]%d元寶[-]，將在[FFFE0D]%s[-]後生效，期間可以找我取消申請。",
            tbInfo.szName, tbInfo.bTeacher and "師父" or "徒弟", TeacherStudent.Def.nGraduateDismissCost,
            Lib:TimeDesc2(nDismissDeadline-nNow))
    else
        local nCd = tbInfo.nLastAccept+TeacherStudent.Def.nAddStudentInterval-nNow
        local bInCd = nCd>(TeacherStudent.Def.nDismissPunishTime+nDismissDeadline-nNow)
        if bInCd then
            szTips = string.format("該申請將在[FFFE0D]%s[-]後生效，期間隨時可以找我取消申請，你處於收徒間隔期[FFFE0D]%s[-]內不能再%s。",
                Lib:TimeDesc8(nDismissDeadline-nNow), Lib:TimeDesc2(nCd), tbInfo.bTeacher and "拜師" or "收徒")
        else
            local _, nOfflineSeconds = Player:GetOfflineDays(tbInfo.nId)
            local bNoPunish = nOfflineSeconds>=TeacherStudent.Def.nForceDissmissTime
            if bNoPunish then
                szTips = string.format("該申請將在[FFFE0D]%s[-]後生效，期間隨時可以找我取消申請。",
                    Lib:TimeDesc8(nDismissDeadline-nNow))
            else
                szTips = string.format("該申請將在[FFFE0D]%s[-]後生效，期間隨時可以找我取消申請，正式解除師徒關係後[FFFE0D]%s[-]內不能再%s。",
                    Lib:TimeDesc8(nDismissDeadline-nNow), string.format("%d小時", math.ceil(TeacherStudent.Def.nDismissPunishTime/3600)),
                    tbInfo.bTeacher and "拜師" or "收徒")
            end
        end
    end

    Dialog:Show({
        Text = szTips,
        OptList = {
            { Text = "確定解除師徒關係", Callback = self.DismissConfirm, Param = {self, tbInfo.nId} },
        },
    }, me, him)
end

function tbNpc:DismissConfirm(nId)
    TeacherStudent:OnRequest("ReqDismiss", nId)
end

function tbNpc:NoCanDismissDlg()
    Dialog:Show({
        Text = "你當前沒有可解除的師徒關係！",
        OptList = {
            { Text = "知道了" }
        },
    }, me, him)
end

function tbNpc:CancelDismissDlg()
    local tbDismissing = ScriptData:GetValue("TSDismissing")
    local tbMyReq = tbDismissing[me.dwID] or {}
    if not next(tbMyReq) then
        self:NoDismissReqDlg()
        return
    end

    self:CancelDismissSelectDlg(tbMyReq)
end

function tbNpc:NoDismissReqDlg()
    Dialog:Show({
        Text = "你當前沒有正在解除師徒關係的申請。",
        OptList = {
            { Text = "知道了" }
        },
    }, me, him)
end

function tbNpc:CancelDismissSelectDlg(tbMyReq)
    local tbDismissing = {}
    for nOtherId in pairs(tbMyReq) do
        local pStay = KPlayer.GetRoleStayInfo(nOtherId)
        if pStay then
            table.insert(tbDismissing, {
                nId = nOtherId,
                szName = pStay.szName,
                bTeacher = TeacherStudent:IsMyTeacher(me, nOtherId),
            })
        end
    end

    local tbOpt = {}
    for nPlayerId, tbInfo in pairs(tbDismissing) do
        table.insert(tbOpt, {
            Text = string.format("取消與%s「%s」解除師徒關係", tbInfo.bTeacher and "師父" or "徒弟", tbInfo.szName),
            Callback = self.CancelDismiss,
            Param = {self, tbInfo.nId},
        })
    end

    Dialog:Show({
        Text = "你要取消與誰解除師徒關係的申請？",
        OptList = tbOpt,
    }, me, him)
end

function tbNpc:CancelDismiss(nOtherId)
    TeacherStudent:OnRequest("CancelDismiss", nOtherId)
end

function tbNpc:GraduateDlg()
    Dialog:Show({
        Text = "請選擇出師儀式。",
        OptList = {
            { Text = "帶徒弟出師", Callback = self.GraduateWithStudentDlg, Param = {self} },
            { Text = "我要強制出師", Callback = self.ForceGraduateDlg, Param = {self} },
        },
    }, me, him)
end

function tbNpc:GraduateWithStudentDlg()
    local nTeamId = me.dwTeamID
    local tbTeamMembers = TeamMgr:GetMembers(nTeamId)
    if #tbTeamMembers~=2 then
        Dialog:Show({
            Text = "請先和徒弟組隊後再來找我出師吧。",
            OptList = {
                { Text = "知道了" }
            },
        }, me, him)
        return
    end

    local nStudentId = 0
    for _, nId in ipairs(tbTeamMembers) do
        if nId~=me.dwID then
            nStudentId = nId
            break
        end
    end

    local bIsMyStudent = TeacherStudent:IsMyStudent(me, nStudentId)
    if not bIsMyStudent then
        Dialog:Show({
            Text = "隊友不是你的徒弟。",
            OptList = {
                { Text = "知道了" }
            },
        }, me, him)
        return
    end

    local pStudent = nil
    local tbPlayer = KNpc.GetAroundPlayerList(him.nId, TeacherStudent.Def.nGraduateDistance) or {}
    for _,pPlayer in pairs(tbPlayer) do
        if pPlayer.dwID==nStudentId then
            pStudent = pPlayer
            break
        end
    end
    if not pStudent then
        Dialog:Show({
            Text = "還是等徒弟到了後再來找我出師吧。",
            OptList = {
                { Text = "知道了" }
            },
        }, me, him)
        return
    end

    local bOk, szErr = TeacherStudent:_CheckBeforeGraduate(me, pStudent)
    if not bOk then
        Dialog:Show({
            Text = string.format("你們還未達成出師條件（%s）", szErr),
            OptList = {
                { Text = "知道了" }
            },
        }, me, him)
        return
    end

    local nFinishedCount = TeacherStudent:_GetTargetFinishedCount(pStudent, me.dwID)
    local tbTeacherReward = nil
    for i=#TeacherStudent.Def.tbGraduateTeacherRewards,1,-1 do
        local tbInfo = TeacherStudent.Def.tbGraduateTeacherRewards[i]
        if nFinishedCount>=tbInfo.nMin then
            tbTeacherReward = tbInfo
            break
        end
    end
    Dialog:Show({
        Text = string.format("徒弟「%s」達成了[FFFE0D]%d條[-]師徒目標，評價：[FFFE0D]%s[-]，師徒獲得[FFFE0D]%s[-]出師獎勵，確定要現在出師嗎？", pStudent.szName, nFinishedCount, tbTeacherReward.szJudgement, tbTeacherReward.szJudgement2),
        OptList = {
            { Text = "確定出師", Callback = self.ReqGraduate, Param = {self, nStudentId} },
            { Text = "暫不出師" },
        },
    }, me, him)
end

function tbNpc:ReqGraduate(nOtherId)
    TeacherStudent:OnRequest("ReqGraduate", me.dwID, nOtherId)
end

function tbNpc:ForceGraduateDlg()
    local tbMe = TeacherStudent:GetPlayerScriptTable(me)
    local tbUndergraduates = {}
    for nTeacherId, tbTeacher in pairs(tbMe.tbTeachers) do
        if not tbTeacher.bGraduate then
            tbUndergraduates[nTeacherId] = {
                bTeacher = true,
            }
        end
    end
    for nStudentId, tbStudent in pairs(tbMe.tbStudents) do
        if not tbStudent.bGraduate then
            tbUndergraduates[nStudentId] = {
                bTeacher = false,
            }
        end
    end
    
    local tbOpt = {}
    for nPlayerId, tbInfo in pairs(tbUndergraduates) do
        local pStay = KPlayer.GetRoleStayInfo(nPlayerId)
        if pStay then
            table.insert(tbOpt, {
                Text = string.format("與%s「%s」強制出師", tbInfo.bTeacher and "師父" or "徒弟", pStay.szName),
                Callback = self.ForceGraduateSelectDlg,
                Param = {self, nPlayerId, tbInfo.bTeacher},
            })
        end
    end

    Dialog:Show({
        Text = string.format("師父或徒弟[FFFE0D]離線%d天[-]且[FFFE0D]符合出師條件[-]，即可申請強制出師。強制出師不影響出師獎勵，你要和誰強制出師？", math.floor(TeacherStudent.Def.nForceGraduateTime/(24*3600))),
        OptList = tbOpt,
    }, me, him)
end

function tbNpc:ForceGraduateSelectDlg(nOtherId, bAmIStudent)
    local nNow = GetTime()
    local bOfflineValid = false
    if not KPlayer.GetPlayerObjById(nOtherId) then
        local _, nOffSeconds = Player:GetOfflineDays(nOtherId)
        if nOffSeconds>=TeacherStudent.Def.nForceGraduateTime then
            bOfflineValid = true
        end
    end

    if not bOfflineValid then
        Dialog:Show({
            Text = string.format("你的%s離線未超過[FFFE0D]%d天[-]，不能申請強制出師。", bAmIStudent and "師父" or "徒弟", 
                math.floor(TeacherStudent.Def.nForceGraduateTime/(24*3600))),
            OptList = {
                { Text = "知道了" }
            },
        }, me, him)
        return
    end

    local bOk, szErr = TeacherStudent:CheckBeforeForceGraduate(me, nOtherId)
    if not bOk then
         Dialog:Show({
            Text = string.format("你們還未達成出師條件（%s）", szErr),
            OptList = {
                { Text = "知道了" }
            },
        }, me, him)
        return
    end

    local nTargetsCount = TeacherStudent:_GetTargetFinishedCount(me, nOtherId)
    local tbTeacherReward = nil
    for i=#TeacherStudent.Def.tbGraduateTeacherRewards,1,-1 do
        local tbInfo = TeacherStudent.Def.tbGraduateTeacherRewards[i]
        if nTargetsCount>=tbInfo.nMin then
            tbTeacherReward = tbInfo
            break
        end
    end
    
    local pStay = KPlayer.GetRoleStayInfo(nOtherId)
    local szStudentName = bAmIStudent and me.szName or pStay.szName
    Dialog:Show({
        Text = string.format("徒弟「%s」達成了[FFFE0D]%d條[-]師徒目標，評價：[FFFE0D]%s[-]，師徒獲得[FFFE0D]%s[-]出師獎勵，確定現在出師嗎？", szStudentName, nTargetsCount, tbTeacherReward.szJudgement, tbTeacherReward.szJudgement2),
        OptList = {
            { Text = "確定出師", Callback = self.ForceGraduate, Param = {self, nOtherId} },
            { Text = "暫不出師" },
        },
    }, me, him)
end

function tbNpc:ForceGraduate(nOtherId)
    TeacherStudent:OnRequest("ReqForceGraduate", nOtherId)
end