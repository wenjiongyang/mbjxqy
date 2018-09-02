function SendBless:ActInit(tbAct, bInit)
    local nStartTime, nEndTime = tbAct:GetOpenTimeInfo()
    self.nType = tbAct.nType
    local tbActSetting = SendBless.tbActSetting[self.nType]
    local nLastTime = nEndTime - GetTime()
    local nItemEndTime = nEndTime + self.nItemDelayDelteTime; --0点到第二天4点结束的，道具和最新消息延迟到第四天0点
    local tbMailInfo = {
            Title = tbActSetting.szMailTitle,
            Text = tbActSetting.szMailText,
            tbAttach = {{"item", tbActSetting.nCardItemId, 1,  nItemEndTime} },
            nRecyleTime =  nLastTime, --因为是全服邮件的，所以要指定回收时间
            LevelLimit = self.nMinLevel,
        }
    self.tbMailInfo = tbMailInfo;
    if bInit then
        if tbActSetting.bRank then
            RankBoard:ClearRank("SendBless")
        end
        Mail:SendGlobalSystemMail(tbMailInfo)
        self:ResetAllPlayers(tbAct);
    end

    local strTimeDura = Lib:TimeDesc10(nStartTime) .. "~" .. Lib:TimeDesc10(nEndTime) 
    --最新消息
    NewInformation:AddInfomation(tbActSetting.szActName, nItemEndTime, {string.format(tbActSetting.szNewsText , strTimeDura)
        }, {szTitle = tbActSetting.szNewsTitle, nReqLevel = 1} )

end

function SendBless:ActEnd()
    local tbActSetting = SendBless.tbActSetting[self.nType]
    if tbActSetting.bRank then
        local pRank = KRank.GetRankBoard("SendBless")
        assert(pRank)
        pRank.Rank()
        local nFrom = 1
        for i,v in ipairs(self.tbRankAward) do
            for nPos = nFrom, v.nRankEnd do
                local tbInfo = pRank.GetRankInfoByPos(nPos - 1);
                if tbInfo then
                    Mail:SendSystemMail({
                        To = tbInfo.dwUnitID,
                        Title = "普天同慶排名獎勵",
                        Text = string.format("大俠，本輪祝福活動你獲得了來自好友的%s祝福值，排行%d名，人氣真不錯啊！這是您的獎勵，請查收。", tbInfo.szValue, nPos),
                        tbAttach = { v.tbAward },
                    });
                    Log("SendBless:ActEnd", tbInfo.dwUnitID, nPos, tbInfo.szValue)
                end
            end
            nFrom = v.nRankEnd + 1
        end
    end
    self.nType = nil;
end

function SendBless:ResetPlayerDataAndAward(pPlayer, tbAct)
    local nStartTime = tbAct:GetOpenTimeInfo()
    if pPlayer.GetUserValue(self.SAVE_GROUP, self.KEY_RESET_DAY) == nStartTime then
        return
    end

    pPlayer.nSendBlessTimes = nil;
    pPlayer.SetUserValue(self.SAVE_GROUP, self.KEY_RESET_DAY, nStartTime)
    local tbData = pPlayer.GetScriptTable("SendBless")
    tbData.tbGet = tbData.tbGet or {} 
    tbData.tbSend = tbData.tbSend or {} 
    tbData.nCurGetBlessAwardTimes = nil;
    
    tbData.tbGet =  {} 
    tbData.tbSend = {} 
    
    pPlayer.SetUserValue(self.SAVE_GROUP, self.KEY_SEND_TIME, 0)
    pPlayer.SetUserValue(self.SAVE_GROUP, self.KEY_CUR_SEND_TIMES, self.nStackMax)
    pPlayer.SetUserValue(self.SAVE_GROUP, self.KEY_TakeAwardLevel, 0)



    pPlayer.CallClientScript("SendBless:OnSynSendData", {  })
    Log("SendBless ResetPlayerDataAndAward", pPlayer.dwID)
end

function SendBless:SendBless(pPlayer, dwRoleId2, bCostGold, szWord)
    if not self.nType then
        return
    end
    local dwRoleId1 = pPlayer.dwID
    if not FriendShip:IsFriend(dwRoleId1, dwRoleId2) then
        pPlayer.CenterMsg("非好友關係")
        return
    end

    if not bCostGold then
        self.SendBlessCallBack(dwRoleId1, true, nil, dwRoleId2, false, szWord)    
    else
        pPlayer.CostGold(SendBless.COST_GOLD, Env.LogWay_SendBless, nil, self.SendBlessCallBack, dwRoleId2, true, szWord);
    end
end

function SendBless.SendBlessCallBack(dwRoleId1, bSucceed, szBillNo, dwRoleId2, bUseGold, szWord)
    if not bSucceed then
        return false
    end
    local pPlayer = KPlayer.GetPlayerObjById(dwRoleId1)
    if not pPlayer then
        return false
    end

    local tbData = pPlayer.GetScriptTable("SendBless")
    tbData.tbSend = tbData.tbSend or {}
    local bRet, nCurHasCount = SendBless:CheckSendCondition(pPlayer, dwRoleId2, tbData.tbSend, bUseGold) 
    if not bRet then
        return false
    end

    local pPlayer2 = KPlayer.GetPlayerObjById(dwRoleId2)
    if not pPlayer2 then
        pPlayer.CenterMsg("對方不線上，不能送出祝福！")
        return false
    end

    if pPlayer2.nLevel < SendBless.nMinLevel then
        pPlayer.CenterMsg("對方等級不足" .. SendBless.nMinLevel)
        return false
    end

    local tbActSetting = SendBless:GetActSetting()

    local nVal = SendBless:GetSendBlessVal(pPlayer.dwID, dwRoleId2, pPlayer, pPlayer2) --1 送给2 的祝福值
    if bUseGold then
        nVal = nVal + 1;
        if tbActSetting.szColorSendMsg then
            szWord = szWord or SendBless.szDefaultWord;
            ChatMgr:SendPlayerMsg(ChatMgr.ChannelType.Color, dwRoleId1, pPlayer.szName, pPlayer.nFaction, pPlayer.nPortrait, pPlayer.nLevel, string.format(tbActSetting.szColorSendMsg, pPlayer.szName, pPlayer2.szName, szWord) )
        end
        
    end
    
    tbData.tbSend[dwRoleId2] = nVal

    local tbData2 = pPlayer2.GetScriptTable("SendBless")
    tbData2.tbGet = tbData2.tbGet or {};
    tbData2.tbGet[dwRoleId1] = nVal

    
    if tbActSetting.bRank then
        pPlayer.SetUserValue(SendBless.SAVE_GROUP, SendBless.KEY_CUR_SEND_TIMES, nCurHasCount - 1)
        pPlayer.SetUserValue(SendBless.SAVE_GROUP, SendBless.KEY_SEND_TIME, GetTime())
        local nTotalVal = SendBless:GetScoreInfo(tbData2.tbGet)
        RankBoard:UpdateValueByID("SendBless", dwRoleId2, nTotalVal)
    end

    if not tbActSetting.bGoldSkipTimes or not bUseGold then
        pPlayer.nSendBlessTimes = pPlayer.nSendBlessTimes + 1;    
    end

    local nCurGetBlessAwardTimes;
    if tbActSetting.nMaxGetBlessAwardTimes then
        nCurGetBlessAwardTimes = tbData2.nCurGetBlessAwardTimes or 0
        if nCurGetBlessAwardTimes < tbActSetting.nMaxGetBlessAwardTimes then
            nCurGetBlessAwardTimes = nCurGetBlessAwardTimes + 1;
            tbData2.nCurGetBlessAwardTimes = nCurGetBlessAwardTimes;
            pPlayer2.SendAward(tbActSetting.tbGetBlessAward, nil,nil,Env.LogWay_SendBless)
        end
    end
    
    pPlayer.CallClientScript("SendBless:OnSendScucss", dwRoleId2, nVal, szWord)
    pPlayer2.CallClientScript("SendBless:OnGetScucss", dwRoleId1, nVal, bUseGold, szWord, nCurGetBlessAwardTimes)
end


function SendBless:TakeAward(pPlayer)
    local tbActSetting = SendBless:GetActSetting()
    if not tbActSetting then
        return
    end
    if tbActSetting.nMaxGetBlessAwardTimes then
        return
    end

    --TODO 确定下奖励形式决定接口要不要
    local tbData = pPlayer.GetScriptTable("SendBless")
    local nAwardLevel, tbAward = self:GetCurAwardLevel(pPlayer, tbData.tbGet)
    if not tbAward or not nAwardLevel then
        return
    end
    
    pPlayer.SetUserValue(self.SAVE_GROUP, self.KEY_TakeAwardLevel, nAwardLevel)
    pPlayer.SendAward({tbAward}, nil, nil, Env.LogWay_SendBless)
    pPlayer.CallClientScript("SendBless:OnGetAwwrdSucess")
end

function SendBless:SynSendData(pPlayer) --应该是指需要同步一次的
    local tbData = pPlayer.GetScriptTable("SendBless")
    pPlayer.CallClientScript("SendBless:OnSynSendData", tbData)
end

function SendBless:OnPlayerLevelUp(pPlayer)
    if pPlayer.nLevel ~= self.nMinLevel then
        return
    end
    local tbMail = Lib:CopyTB(self.tbMailInfo)
    tbMail.To = pPlayer.dwID;
    tbMail.LevelLimit = nil;
    Mail:SendSystemMail(tbMail)
end

function SendBless:ResetAllPlayers(tbActInst)
    local tbPlayers = KPlayer.GetAllPlayer()
    for i,v in ipairs(tbPlayers) do
        self:ResetPlayerDataAndAward(v, tbActInst);
    end
end

function SendBless:DataCheck()
    --保证每个类型的道具id是不一样的 ，确定下是不是每个配置都有，不需要的用false
    local tbKeyCount = {}
    local tbHasUsedItem = {}
    for k,v in ipairs(self.tbActSetting) do
        assert(not tbHasUsedItem[v.nCardItemId], k )
        tbHasUsedItem[v.nCardItemId] = 1;
        for k2,v2 in pairs(v) do
            tbKeyCount[k2] = (tbKeyCount[k2] or 0) + 1
        end
    end

    for k2,v2 in pairs(tbKeyCount) do
        assert(v2 == 2, k2)
    end
end

SendBless:DataCheck()