Require("ServerScript/Battle/BattleBase.lua")

local tbLogic = Battle:CreateClass("BattleKill", "BattleServerBase")
local tbBaseClass = Battle:GetClass("BattleServerBase");
local tbDotaCom = Battle.tbDotaCom

function tbLogic:StartFight()
	tbBaseClass.StartFight(self)
	tbDotaCom.StartAddTrapBuff(self)
end

function tbLogic:OnPlayerTrap(szTrapName)
	tbBaseClass.OnPlayerTrap(self, szTrapName)
	tbDotaCom.OnPlayerTrap(self, szTrapName, me)
end