

tbGlobalTable_Pre =
{
	-- 如果要声明只有server独有的，直接在此处就可以声明
	Server       = {};
	GM           = {};
	c2s          = {};
	ScriptData   = {};
	ScheduleTask = {};
	PunishTask   = {};
	TeamPKMgr  	 = {};
	FightPower   = {};
	Transmit     = {};
	AssistClient = {};
	RedBagMgr	 = {};
	CombineServer = {};
	RandomAward = {};
	AddictionTip = {};
	SampleHouse = {};
}

-- GlobalTable 这个文件声明了 server 和 client 都有的全局 table
DoScript("CommonScript/GlobalTable.lua");
for k, v in pairs(tbGlobalTable_Pre) do
	tbGlobalTable[k] = v;
end

for k, v in pairs(tbGlobalTable) do
	_G[k] = v;
end

-- 定义c2s接口
Require("ServerScript/Common/c2s.lua");

---------------------------- 玩家数据SaveTable声明
PlayerScriptTableSetting = {
	["EntryPoint"]		= 1,
	["Task"]			= 1,
	["PersonalFuben"]	= 1,
	["MissionAward"]	= 1,
	["AsyncBattle"]		= 1,
	["Kin"]			= 1,
	["FightPower"]		= 1,
	["PlayerTitleData"]	= 1,
	["StarAttrib"]		= 1,
	["FamilyShop"]		= 1,
	["CommerceTask"]	= 1,
	["Achievement"]	= 1,
	["Helper"]		= 1,
	["EverydayTarget"]	= 1,
	["Pray"]			= 1,
	["Portrait"]		= 1,
	["MapExplore"]		= 1,
	["ShopLimit"]		= 1,
	["Gift"]			= 1,
	["Forbid"]			= 1,
	["Partner"]			= 1,
	["TeacherStudent"] 	= 1,
	["MarketStall"] 	= 1,
	["SendBless"]  		= 1, --国庆送祝福活动
	["GiftItem"]        = 1,
	["FriendRecall"] 	= 1,			--老玩家召回福利列表
	["ActivityData"] 	= 1,
	["Furniture"]		= 1,		-- 家具相关
}

GetTimeFrameState_Old = GetTimeFrameState_Old or GetTimeFrameState;
function GetTimeFrameState( ... )
	return TimeFrame:GetTimeFrameState(...)
end

CalcTimeFrameOpenTime_Old = CalcTimeFrameOpenTime_Old or CalcTimeFrameOpenTime;
function CalcTimeFrameOpenTime( ... )
	return TimeFrame:CalcTimeFrameOpenTime(...)
end

---------------------------- 玩家数据SaveTable声明 end
function SetReadOnly(tb, szInfo)
	local tbMt = {};
	tbMt.__newindex = function ()
		assert(false, szInfo or "this table read only");
	end
	setmetatable(tb, tbMt);
end

--- 设置table为只读
SetReadOnly(PlayerScriptTableSetting, "PlayerScriptTableSetting is read only !!");
SetReadOnly(c2s, "c2s api only can defined in file ServerScript/Common/c2s.lua !!");
SetReadOnly(tbGlobalTable);


function XT(...)
	return ...;
end

----------------------------- 禁用创建全局对象
global_env = getfenv(0);
getfenv_old = getfenv_old or getfenv;
getfenv = function (value)
	if getfenv_old(value) == getfenv_old(0) then
		return nil;
	end
	return getfenv_old(value);
end
assert(global_env, 'can not get global env!');
newmt = {
	__newindex = function (table, key, value)
		if not key or not tbGlobalTable[key] then
			assert(false, 'can not new global key ' .. tostring(key));
		else
			rawset(table, key, value);
		end
	end
}
setmetatable(global_env, newmt);
global_env = nil;
newmt = nil;
---------------------------- 禁用全局对象 end
Require("CommonScript/EnvDef.lua");
Require("CommonScript/lib.lua");
Require("CommonScript/calc.lua");
Require("CommonScript/Skill/FightSkill.lua");
Require("CommonScript/Npc/Npc.lua");
Require("CommonScript/Fuben/FubenMgrCommon.lua");
Require("CommonScript/Item/Item.lua");
Require("CommonScript/Kin/KinDef.lua");
Require("ServerScript/AsyncBattle/AsyncBattle.lua")
Require("ServerScript/Fuben/RandomFuben.lua");
Require("ServerScript/Map/Map.lua");
Require("CommonScript/Player/Player.lua");
Require("CommonScript/Faction.lua");
Require("ServerScript/Activity/ActivityBase.lua");
Require("ServerScript/Activity/ActivityMgr.lua");
Require("CommonScript/Decoration/Decoration.lua");
Require("CommonScript/Decoration/DecorationClassMgr.lua");
