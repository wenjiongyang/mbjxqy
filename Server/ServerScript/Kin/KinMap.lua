local tbMapClass = Map:GetClass(Kin.Def.nKinMapTemplateId);

function tbMapClass:OnCreate(nMapId)
	Kin:OnCreateKinMap(nMapId)
    Activity:OnGlobalEvent("Act_OnKinMapCreate", nMapId)
end

function tbMapClass:OnDestroy(nMapId)
    Kin:OnDestroyKinMap(nMapId);
    Activity:OnGlobalEvent("Act_OnKinMapDestroy", nMapId)
    Kin.tbKinMapId2KinId[nMapId] = nil
end

function  tbMapClass:OnEnter()
    local tbGather = Kin.Gather
    tbGather:OnPlayerEnterKin(me.dwKinId)
    DomainBattle:OnEnterKinMap(me)
    Kin.MonsterNian:OnEnterKinMap(me)
end

function tbMapClass:OnLeave()
    local tbGather = Kin.Gather
    tbGather:OnPlayerLeaveKin(me.dwKinId)
    Kin.MonsterNian:OnLeaveKinMap(me)
end

function tbMapClass:OnPlayerTrap(nMapID, szTrapName)
	if szTrapName == "TrapPeace" then
		me.nFightMode = 0;
	elseif szTrapName == "TrapFight" then
		me.nFightMode = 1;
	end
end
