Require("ServerScript/Battle/BattleBase.lua")

local tbLogic = Battle:CreateClass("BattleDota", "BattleServerBase")
local tbBaseClass = Battle:GetClass("BattleServerBase");
local tbDotaCom = Battle.tbDotaCom


function tbLogic:Init(nMapId, tbBattleSetting, tbPlayerInfos, tbTeamA, tbTeamB)
	local tbTimeFrame = tbBattleSetting.tbNpcTimeFrame
	local nLevel = 40
	for i,v in ipairs(tbTimeFrame) do
		if GetTimeFrameState(v[1]) == 1 then
			nLevel = v[2]
		end
	end
	local tbNpcScoreSetting = self.tbNpcScoreSetting
	for k, v in pairs(self.tbWildNpcSetting) do
		tbNpcScoreSetting[v.nNpcId][nLevel] = tbNpcScoreSetting[v.nNpcId][v.nLevel]
		v.nLevel = nLevel
	end

	tbBaseClass.Init(self, nMapId, tbBattleSetting, tbPlayerInfos, tbTeamA, tbTeamB)
	tbDotaCom.Init(self)
end

function tbLogic:StartFight()
	tbBaseClass.StartFight(self)
	tbDotaCom.StartFight(self)
end

--刷兵
function tbLogic:Active()
	local nTimeNow = GetTime();
	self:CheckStayInCamp(nTimeNow)
	self:SyncAllInfo(nTimeNow)

	tbDotaCom.Active(self, nTimeNow)
end


function tbLogic:OnNpcDeath(him, pKiller)
	local pPlayer = pKiller and pKiller.GetPlayer()
	if pPlayer then
		tbDotaCom.OnKillNpc(self, pPlayer)
	end
	tbDotaCom.OnNpcDeath(self, him, pKiller)	
end

--玩家杀死非玩家npc时
-- function tbLogic:OnKillNpc()
-- 	-- 
-- end




