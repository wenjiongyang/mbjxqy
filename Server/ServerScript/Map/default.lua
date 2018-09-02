-- Map默认模板（也是基础模板）--先留了需要的，其他需要的到时再加吧
Require("ServerScript/Map/Map.lua")

local tbMapBase	= Map.tbMapBase;

function tbMapBase:OnCreate(nMapID)
end

function tbMapBase:OnDestroy(nMapID)
end

-- 定义玩家进入事件Onlogin前调用
function tbMapBase:OnEnter()
end

-- 定义玩家离开事件
function tbMapBase:OnLeave()
end

-- 触发本地图任何Trap点
function tbMapBase:OnPlayerTrap(nMapId, szTrapName)
end

function tbMapBase:OnNpcTrap(nMapId, szTrapName)
end

function tbMapBase:OnLogin(nMapId)
end

