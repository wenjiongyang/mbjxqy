
Faction.tbChatChannel = Faction.tbChatChannel or {}

function Faction:OnServerStart()
	for nFaction=1,Faction.MAX_FACTION_COUNT do
		Faction.tbChatChannel[nFaction] = KChat.CreateDynamicChannel("門派","#108", "CheckFactionChannelMsg")
	end
end

function Faction:OnLogin(pPlayer)
	if pPlayer.nLevel >= 20 then
		KChat.AddPlayerToDynamicChannel(Faction.tbChatChannel[pPlayer.nFaction],pPlayer.dwID);
	end
end

function Faction:OnLogout(pPlayer)
	KChat.DelPlayerFromDynamicChannel(Faction.tbChatChannel[pPlayer.nFaction],pPlayer.dwID);
end

function Faction:OnLevelUp(pPlayer)
	if pPlayer.nLevel == 20 then
		KChat.AddPlayerToDynamicChannel(Faction.tbChatChannel[pPlayer.nFaction],pPlayer.dwID);
	end
end
