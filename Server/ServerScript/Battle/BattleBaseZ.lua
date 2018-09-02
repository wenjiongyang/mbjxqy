Require("ServerScript/Battle/BattleBase.lua")
if not MODULE_ZONESERVER then
	return
end

local tbBase = Battle:GetClass("BattleServerBase", "BattleComBase")

function tbBase:CloseBattle()
	local fnKick = function (pPlayer)
		pPlayer.ZoneLogout()
	end
	self:ForEachInMap(fnKick)

	if self.nActiveTimer then
		Timer:Close(self.nActiveTimer)
		self.nActiveTimer = nil
	end
end

function tbBase:OnLeaveZoneBattleMap(pPlayer)
	if self.nSchedulePos  >= 3 then
		return
	end
	local nLeftTime = math.floor(Timer:GetRestTime(self.nMainTimer) / Env.GAME_FPS)
	if self.nSchedulePos == 1 then
		nLeftTime = nLeftTime + self.STATE_TRANS[self.nSchedulePos + 1].nSeconds;
	end

	-- 这里已经掉线了，先掉线再离开地图的，所以没有获取 ZoneIndex
	Battle:OnLeaveZoneBattleMapEvent(pPlayer, nLeftTime)
end


