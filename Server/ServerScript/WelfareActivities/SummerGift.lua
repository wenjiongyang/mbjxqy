function SummerGift:OnLogin(pPlayer)
    self:CheckPlayerData(pPlayer)
end

function SummerGift:OnPerDayUpdate()
    local tbAllPlayer = KPlayer.GetAllPlayer()
    for _, pPlayer in pairs(tbAllPlayer) do
        if pPlayer then
            self:CheckPlayerData(pPlayer)
            pPlayer.CallClientScript("SummerGift:CheckRedPoint")
        end
    end
end

function SummerGift:OnJoinAct(pPlayer, szAct)
    local nCurDay = self:GetCurDayIndex()
    if nCurDay <= 0 or nCurDay > self.nActAltDay then
        return
    end

    local nActPos, nJoinTimes, tbTodayAct = self:GetActPos(szAct)
    if not nActPos then
        return
    end

    self:CheckPlayerData(pPlayer)
    local nSavePos = self.BEGIN_FLAG + nActPos - 1
    local nCurTimes = pPlayer.GetUserValue(self.GROUP, nSavePos)
    if nCurTimes >= nJoinTimes then
        return
    end

    nCurTimes = nCurTimes + 1
    pPlayer.SetUserValue(self.GROUP, nSavePos, nCurTimes)
    pPlayer.CallClientScript("SummerGift:OnJoinAct")
    if nCurTimes == nJoinTimes then
        for i, tbInfo in ipairs(tbTodayAct) do
            local nNeed = tbInfo[2]
            local nTimes = pPlayer.GetUserValue(self.GROUP, self.BEGIN_FLAG + i - 1)
            if nTimes < nNeed then
                return
            end
        end
        local nCompleteFlag = pPlayer.GetUserValue(self.GROUP, self.COMPLETE_FLAG)
        nCompleteFlag = KLib.SetBit(nCompleteFlag, nCurDay, 1)
        pPlayer.SetUserValue(self.GROUP, self.COMPLETE_FLAG, nCompleteFlag)
        if self.tbDayAward[nCurDay] then
            local tbAward = {}
            table.insert(tbAward, self.tbDayAward[nCurDay])
            Mail:SendSystemMail({
                To = pPlayer.dwID,
                Title = "盛夏之周每日獎勵",
                Text = "    恭喜俠士達到盛夏之周的每日活動要求，應允之物我已託付郵差捎去，可千萬莫要忘記領走。還望俠士繼續保持，不僅獎勵豐厚，累積天數達到要求，更有一份額外的好處。",
                From = "",
                tbAttach = tbAward,
            })
        end
        Log("SummerGift Complete", pPlayer.dwID, szAct, nJoinTimes, type(self.tbDayAward[nCurDay]))
        for i = 1, 3 do
            self:TryGainGift(pPlayer, i)
        end
    end
end

function SummerGift:CheckPlayerData(pPlayer)
    local nDataDay   = pPlayer.GetUserValue(self.GROUP, self.DATA_DAY)
    local nBeginTime = Lib:ParseDateTime(self.szBeginDay)
    local nBeginDay  = Lib:GetLocalDay(nBeginTime)
    local nToday     = Lib:GetLocalDay(GetTime() - 4*60*60)
    if nDataDay < nToday then
        pPlayer.SetUserValue(self.GROUP, self.DATA_DAY, nToday)
        for i = self.BEGIN_FLAG, self.END_FLAG do
            pPlayer.SetUserValue(self.GROUP, i, 0)
        end
        if nDataDay < nBeginDay then
            pPlayer.SetUserValue(self.GROUP, self.COMPLETE_FLAG, 0)
            pPlayer.SetUserValue(self.GROUP, self.AWARD_FLAG, 0)
        end
    end
end

function SummerGift:TryGainGift(pPlayer, nIdx)
    self:CheckPlayerData(pPlayer)

    local bRet, szMsg = self:CheckCanGainGift(pPlayer, nIdx)
    if not bRet then
        return
    end

    local nGainFlag = pPlayer.GetUserValue(self.GROUP, self.AWARD_FLAG)
    nGainFlag = KLib.SetBit(nGainFlag, nIdx, 1)
    pPlayer.SetUserValue(self.GROUP, self.AWARD_FLAG, nGainFlag)

    local tbInfo = self.tbAward[nIdx]
    Mail:SendSystemMail({
                To = pPlayer.dwID,
                Title = "盛夏之周累積獎勵",
                Text = "    恭喜俠士達到盛夏之周的累積活動要求，應允之物我已託付郵差捎去，可千萬莫要忘記領走。還望俠士繼續保持，報酬自然是會越來越豐厚。武林之未來，還得指望諸位俠士同心協力。",
                From = "",
                tbAttach = tbInfo[2],
            })
    Log("SummerGift GainGift", pPlayer.dwID, nGainFlag, nIdx)
end