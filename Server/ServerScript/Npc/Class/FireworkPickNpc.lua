local tbNpc = Npc:GetClass("FireworkPickNpc")

function tbNpc:OnDialog()
    GeneralProcess:StartProcess(me, Kin.MonsterNianDef.nFireworkPickTime*Env.GAME_FPS, "採集中", self.EndProcess, self, me.dwID, him.nId)
end

function tbNpc:EndProcess(dwID, nNpcId)
    local pPlayer = KPlayer.GetPlayerObjById(dwID)
    local pNpc    = KNpc.GetById(nNpcId)
    if not pPlayer then
        return
    end

    local nCount = pPlayer.GetItemCountInBags(Kin.MonsterNianDef.nFireworkId)
    if nCount>=Kin.MonsterNianDef.nFireworkMaxInBag then
        pPlayer.SendBlackBoardMsg(string.format("煙花很危險，最多同時攜帶%d個，請用完再來！", Kin.MonsterNianDef.nFireworkMaxInBag))
        return
    end

    if not pNpc or pNpc.IsDelayDelete() then
        pPlayer:CenterMsg("已被其他人搶先採集")
        return
    end
    
    pNpc.Delete()

    local nTimeout = self:GetItemTimeout()
    pPlayer.SendAward({{"Item", Kin.MonsterNianDef.nFireworkId, 1, nTimeout}}, false, true, Env.LogWay_GatherBox)
end

function tbNpc:GetItemTimeout()
	local tbDeadline = os.date("*t", GetTime())
	tbDeadline.hour = 23
	tbDeadline.min = 59
	tbDeadline.sec = 59
	return os.time(tbDeadline)
end
