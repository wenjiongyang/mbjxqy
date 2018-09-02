
ChangeName.tbInDBProcess = {};
ChangeName.tbLastRoleName = {}; --[dwRoleId] = szName
ChangeName.tbLastRoleNameToId = {}; -- [szName] = dwRoleId
function ChangeName:RequestChangeName(pPlayer, szNewName)
    if self.tbInDBProcess[pPlayer.dwID] then
        pPlayer.CenterMsg("請稍後再嘗試")
        return
    end
    local dwOcupyNameRoleId = self.tbLastRoleNameToId[szNewName]
    if dwOcupyNameRoleId and dwOcupyNameRoleId ~= pPlayer.dwID then
        pPlayer.CenterMsg("已經有大俠叫這個名字了！請重新輸入！")
        return
    end

    local nLevel = pPlayer.nLevel
    local bFree = false
    local nCost, bHasItem = self:GetChangePrice(pPlayer);
    if nCost > 0 then
        pPlayer.CostGold(nCost, Env.LogWay_ChangeName, nil, self.ChangeNameCallBack, szNewName, nCost, false);
    else
        if bHasItem then
            if pPlayer.ConsumeItemInAllPos(self.ITEM_ChangeName, 1, Env.LogWay_ChangeName) > 0 then
                self.ChangeNameCallBack(pPlayer.dwID, true, nil, szNewName, nCost, bHasItem)
            end
        else
            self.ChangeNameCallBack(pPlayer.dwID, true, nil, szNewName, nCost, bHasItem)
        end
    end
end

function ChangeName:ChangeNameById(nPlayerId, szNewName, bForce)
    local nRet =  KPlayer.ChangeRoleNameById(nPlayerId, szNewName, bForce)
    Log("ChangeName:ChangeNameById", nPlayerId, szNewName, bForce, nRet)
    if nRet ~= 0 then
        return
    end
    local tbRoleStay = KPlayer.GetRoleStayInfo(nPlayerId)
    ChangeName.tbInDBProcess[nPlayerId] = {0, false, tbRoleStay.szName};
end

function ChangeName.ChangeNameCallBack(nPlayerId, bSucceed, szBillNo, szNewName, nCost, bHasItem)
    if not bSucceed then
        return false
    end
    local pPlayer = KPlayer.GetPlayerObjById(nPlayerId)
    if not pPlayer then
        return false
    end

    local szOLdName = pPlayer.szName
    local nRet = pPlayer.ChangeName(szNewName)
    if nRet == 0 then
        ChangeName.tbInDBProcess[nPlayerId] = {nCost, bHasItem, szOLdName};
        if not bHasItem then
            if nCost > 0 then
                local nChangedTimes = pPlayer.GetUserValue(ChangeName.SAVE_GROUP, ChangeName.KEY_TIMES)
                pPlayer.SetUserValue(ChangeName.SAVE_GROUP, ChangeName.KEY_TIMES, nChangedTimes + 1)
            else
                pPlayer.SetUserValue(ChangeName.SAVE_GROUP, ChangeName.KEY_FREE, 1)
            end
        end

        return true
    else
        if bHasItem then
            pPlayer.AddItem(ChangeName.ITEM_ChangeName, 1, nil, Env.LogWay_ChangeName)
        end
        pPlayer.CallClientScript("ChangeName:OnChangeName", nRet)
        return false, "改名失敗"
    end
end

function ChangeName:OnDBResponse( dwRoleId, nCode )
    local tbInfo = self.tbInDBProcess[dwRoleId]
    if not tbInfo then
        return;
    end

    self.tbInDBProcess[dwRoleId] = nil
    local pPlayer = KPlayer.GetPlayerObjById(dwRoleId)
    local nCost, bHasItem, szOLdName = unpack(tbInfo)
    if nCode ~= 0  then
        local tbAttach = {}
        if nCost and nCost > 0 then
            table.insert(tbAttach, {"Gold", nCost})
        else
           table.insert(tbAttach, {"item", ChangeName.ITEM_ChangeName, 1})
        end

        Mail:SendSystemMail({
            To = dwRoleId,
            Text = "少俠，您的改名失敗了,請查收您的改名補償",
            tbAttach = tbAttach,
            nLogReazon = Env.LogWay_ChangeName,
        })
        if pPlayer then
            pPlayer.CallClientScript("ChangeName:OnChangeName", nCode)
        end
        Log("ChangeName DB Fail", nCode, dwRoleId, nCost, tostring(bHasItem))
    else
        --改名成功
        local szLastlastName = self.tbLastRoleName[dwRoleId]
        if szLastlastName then
            self.tbLastRoleNameToId[szLastlastName] = nil;
        end
        self.tbLastRoleName[dwRoleId] = szOLdName
        self.tbLastRoleNameToId[szOLdName] = dwRoleId;

        if pPlayer then
            local szNewName = pPlayer.szName
            local szMsg = string.format("少俠「%s」將名字更改為[f9ffa3]「%s」[-]", szOLdName, szNewName)
            local dwKinId = pPlayer.dwKinId
            if dwKinId ~= 0 then
                local tbKin = Kin:GetKinById(dwKinId)
                if tbKin then
                    ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.Kin, szMsg, dwKinId);
                    Kin:UpdateKinMemberInfo(dwKinId);
                end
            end

            KFriendShip.SynInfoToAllFriend(dwRoleId);

            local tbMail = {
                Title = "好友改名",
                Text  = szMsg,
            }

            local tbAllFriend = KFriendShip.GetFriendList(dwRoleId)
            for dwRoleId, _ in pairs(tbAllFriend) do
                tbMail.To = dwRoleId
                Mail:SendSystemMail(tbMail)
            end

            tbMail.Title = "仇人改名";

            local tbAllEnemy = KFriendShip.GetEnemyList(dwRoleId)
            for dwRoleId,v in pairs(tbAllEnemy) do
                tbMail.To = dwRoleId
                Mail:SendSystemMail(tbMail)
            end

            TeacherStudent:OnChangeName(pPlayer)
            Wedding:OnChangeName(pPlayer, szOLdName)
        end

        local pRole = KPlayer.GetRoleStayInfo(dwRoleId)
        local szGameAppid, nPlat, nServerIdentity, nAreaId = GetWorldConfifParam()
        local szAcc = KPlayer.GetPlayerAccount(dwRoleId) or ""
        TLog("ChangNameFlow", szGameAppid, nPlat, nServerIdentity, szAcc, dwRoleId, szOLdName, pRole.szName, nCost, (bHasItem and ChangeName.ITEM_ChangeName or 0))
        if pPlayer then
            AssistClient:ReportQQScore(pPlayer, Env.QQReport_ChangeRoleName, pPlayer.szName, 0, 2);
        end
        Log("ChangeName Success", dwRoleId, szOLdName, pRole.szName, nCost, tostring(bHasItem))
    end
end
