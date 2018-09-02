-- 仅用于需要分表的特殊情况，参见ScriptData.lua的注释


local function fnDefaultIsExist(tbSlot, xKey)
	return tbSlot[xKey]
end

local function fnDefaultGetCount(tbSlot)
	return Lib:CountTB(tbSlot)
end
	
--[[
szMainKey = {								--szMainKey是存放的主键，程序将自动在后面追加数字来创建分表
	nMaxCount = 123,						--单个表存的条数上限，请以极限情况测试，取一个保证存储成功的安全值
	IsExist = function(tbSlot, ...) end,	--判断表中是否存在指定的值
	GetCount = function(tbSlot) end,		--返回表中的条数
}
]]
ScriptData.tbGroupSettings = {
	TSDelayDismiss = {	--师徒，玩家上线解除
		nMaxCount = 800,	--测试数据：每个玩家解除5对关系，可保存990组
	},

	TSForceGraduate = {	--师徒，强制出师
		nMaxCount = 2000,	--测试数据：每个玩家强制出师5个，可保存2300组
	},

	TSDelayChangeTitle = {	--师徒，玩家上线更改称号名
		nMaxCount = 500,	--测试数据：每个玩家存储5位改名信息，可保存600组
	},

	GlobalRB = {	--全服红包
		nMaxCount = 3,	--测试数据：每个红包1000个接受人，可保存4组
	},
}

function ScriptData:_GrpGetMaxSlot(szMainKey)
	if not self.tbGroupSettings[szMainKey] then
		Log("[x] ScriptData:_GrpGetMaxSlot", tostring(szMainKey))
		return
	end
	local tbMaxSlots = ScriptData:GetValue("MaxSlots")
	return tbMaxSlots[szMainKey] or -1
end

function ScriptData:_GrpSetMaxSlot(szMainKey, nValue)
	if not self.tbGroupSettings[szMainKey] then
		Log("[x] ScriptData:_GrpSetMaxSlot", tostring(szMainKey), nValue)
		return
	end
	local tbMaxSlots = ScriptData:GetValue("MaxSlots")
	tbMaxSlots[szMainKey] = nValue
	ScriptData:AddModifyFlag("MaxSlots")
	Log("ScriptData:_GrpSetMaxSlot", szMainKey, nValue)
end

function ScriptData:_GrpGetSlotKey(szMainKey, nSlot)
	return string.format("%s%d", szMainKey, nSlot)
end

function ScriptData:_GrpGetSlotValue(szKey)
	ScriptData:AddDef(szKey)
	return ScriptData:GetValue(szKey)
end

-- 获取所有的slot
function ScriptData:GrpGetAllSlots(szMainKey)
	local tbSlots = {}
	local nMaxSlot = self:_GrpGetMaxSlot(szMainKey) or 0
	for nSlot=1, nMaxSlot do
		local szKey = self:_GrpGetSlotKey(szMainKey, nSlot)
		local tbSlot = self:_GrpGetSlotValue(szKey)
		table.insert(tbSlots, tbSlot)
	end
	return tbSlots
end

-- 给定条件，查找对应的slot
function ScriptData:GrpFindSlot(szMainKey, ...)
	local tbSettings = self.tbGroupSettings[szMainKey]
	if not tbSettings then
		Log("[x] ScriptData:GrpFindSlot", tostring(szMainKey))
		return
	end

	local nMaxSlot = self:_GrpGetMaxSlot(szMainKey)
	for nSlot=1, nMaxSlot do
		local szKey = self:_GrpGetSlotKey(szMainKey, nSlot)
		local tbSlot = self:_GrpGetSlotValue(szKey)
		local fnIsExist = tbSettings.IsExist or fnDefaultIsExist
		if fnIsExist(tbSlot, ...) then
			return tbSlot, nSlot
		end
	end
end

-- 获得/创建slot，以供添加新数据
function ScriptData:GrpGetFreeSlot(szMainKey, nMinFree)
	local tbSettings = self.tbGroupSettings[szMainKey]
	if not tbSettings then
		Log("[x] ScriptData:GrpGetFreeSlot", tostring(szMainKey), tostring(nMinFree))
		return
	end

	nMinFree = nMinFree or 1
	local nMaxSlot = self:_GrpGetMaxSlot(szMainKey)
	for nSlot=1, nMaxSlot do
		local szKey = self:_GrpGetSlotKey(szMainKey, nSlot)
		local tbSlot = self:_GrpGetSlotValue(szKey)
		local fnGetCount = tbSettings.GetCount or fnDefaultGetCount
		local nCurCount = fnGetCount(tbSlot)
		if tbSettings.nMaxCount-nCurCount>=nMinFree then
			return tbSlot, nSlot
		end
	end
	return self:_GrpAddSlot(szMainKey)
end

-- 先尝试查找匹配的slot，失败后再获取空余的slot
function ScriptData:GrpFindOrGetFreeSlot(szMainKey, nMinFree, ...)
	local tbSlot, nSlot = self:GrpFindSlot(szMainKey, ...)
	if not tbSlot then
		tbSlot, nSlot = self:GrpGetFreeSlot(szMainKey, nMinFree)
	end
	return tbSlot, nSlot
end

function ScriptData:_GrpAddSlot(szMainKey)
	if not self.tbGroupSettings[szMainKey] then
		Log("[x] ScriptData:_GrpAddSlot", tostring(szMainKey))
		return
	end
	local nMaxSlot = self:_GrpGetMaxSlot(szMainKey)
	local nNextSlot = nMaxSlot<=0 and 1 or (nMaxSlot+1)
	local szKey = self:_GrpGetSlotKey(szMainKey, nNextSlot)
	local tbSlot = self:_GrpGetSlotValue(szKey)
	self:_GrpSetMaxSlot(szMainKey, nNextSlot)
	Log("ScriptData:_GrpAddSlot", szMainKey, nNextSlot)
	return tbSlot, nNextSlot
end

function ScriptData:GrpSaveSlot(szMainKey, nSlot)
	local szKey = self:_GrpGetSlotKey(szMainKey, nSlot)
	ScriptData:AddModifyFlag(szKey)
end
