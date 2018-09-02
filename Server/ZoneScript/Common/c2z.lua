c2z.OnMsgBoxSelect = c2s.OnMsgBoxSelect
c2z.OnSimpleTapNpc = c2s.OnSimpleTapNpc
c2z.OnDialogSelect = c2s.OnDialogSelect
c2z.ChangeActionMode = c2s.ChangeActionMode
c2z.CallPartnerFunc = c2s.CallPartnerFunc
c2z.FocusSelfAllPet = c2s.FocusSelfAllPet
c2z.RequestBossLeaderBossDmgRank = c2s.RequestBossLeaderBossDmgRank;
c2z.BossLeaderEnterFuben = c2s.BossLeaderEnterFuben;

function c2z:PlayerLeaveMap(szMsg)
	local nMapId = me.nMapId;
	local szMsg = szMsg or "确定要离开活动？"
	if me.szCanLeaveMapMsg then
		szMsg = me.szCanLeaveMapMsg;
	end

	me.MsgBox(szMsg, {{"确定", function (nMapId)
		if me.nMapId ~= nMapId then
			return;
		end

    	if (me.nCanLeaveMapId and me.nCanLeaveMapId == me.nMapId) or Map:CheckCanLeave(me.nMapTemplateId) then
    		me.ZoneLogout()
    	end
	end, nMapId}, {"取消"}})
end

function c2z:LeaveFuben(bIsPersonalFuben, bShowStronger, bIsWin)
    if bIsPersonalFuben then
        if me.nState ~= Player.emPLAYER_STATE_ALONE then
            return;
        end

        if not bIsWin then
            local nX, nY, nFightMode = Map:GetDefaultPos(me.nMapTemplateId);
            me.SetPosition(nX, nY);
            me.nFightMode = nFightMode;
        end

        me.LeaveClientMap();
        me.CallClientScript("PersonalFuben:OnLeaveSucess");
        PersonalFuben:ClearCurrentFubenData(me);
    else
        if me.nLastMapExploreMapId then --从探索进去的话要返回探索
            Fuben.DungeonFubenMgr:CheckReturnMapExplore(me)
        elseif me.nMapTemplateId == Fuben.WhiteTigerFuben.OUTSIDE_MAPID then --从白虎堂第一层出来要回到准备场
            Fuben.WhiteTigerFuben:TryBackToPrepareMap(me)
        else
            me.ZoneLogout()
        end
    end

    if bShowStronger then
        me.CallClientScript("Ui:OpenWindow", "StrongerPanel");
    end
end

function c2z:ApplyChangeMode(nMode)
    if nMode == Player.MODE_CAMP and Kin.Def.bForbidCamp then
        me.CenterMsg("禁止操作");
        return;
    end

    Player:ChangePKMode(me, nMode);
end

function c2z:InDifferBattleChooseFaction(nFaction)
    InDifferBattle:ChooseFaction(me, nFaction)
end

function c2z:InDifferBattleGiveMoneyTo(dwRoleId2, nMoney)
    InDifferBattle:GiveMoneyTo(me, dwRoleId2, nMoney) 
end

function c2z:InDifferBattleRequestInst(...)
    InDifferBattle:RequestInst(me, ...)
end

--目前跨服穿戴装备只是心魔幻境中
function c2z:UseEquip(nId, nEquipPos)
   InDifferBattle:RequestInst(me, "UseEquip", nId, nEquipPos)
end

function c2z:UnuseEquip(nPos)
   InDifferBattle:RequestInst(me, "UnuseEquip", nPos)
end

function c2z:OnTeamRequest(...)
    me.CenterMsg("当前地图无法进行此操作");
end

function c2z:OnTeamUpRequest(...)
    me.CenterMsg("当前地图无法进行此操作");
end

function c2z:DoRequesWLDH(szType, ... )
    local FunCall = WuLinDaHui.tbC2ZRequest[szType];
    if not FunCall then
        return;
    end

    FunCall(me, ...);
end


function c2z:OnMapRequest(...)
    Map:ClientRequestZ(...);
end