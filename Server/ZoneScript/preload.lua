

local tbGlobalTable_Pre = 
{
	-- 如果要声明只有server独有的，直接在此处就可以声明
	Server       = {};
	GM           = {};
	c2s          = {};
	ScriptData   = {};
	ScheduleTask = {};
	PunishTask   = {};
	FightPower   = {};
	Transmit     = {};
	
	c2z          = {};
}

for k, v in pairs(tbGlobalTable_Pre) do
	_G[k] = v;
end

Require("ServerScript/preload.lua");
Require("ServerScript/Fuben/FubenMgrServer.lua")
Require("ServerScript/Map/default.lua")

