local self
local function _GEN_INTVALUE_FUN(szDesc, nValueId, bSync)
  local function funGet()
    return self.GetIntValue(nValueId)
  end
  local function funSet(nValue)
    return self.SetIntValue(nValueId, nValue, bSync and 1 or 0)
  end
  rawset(_LuaPartner, "Get" .. szDesc, funGet)
  rawset(_LuaPartner, "Set" .. szDesc, funSet)
end
local function _GEN_INTVALUE_RANGE_FUN(szDesc, nBeginValueId, nEndValueId)
  local function funGet(nIndex)
    assert(self)
    if nIndex <= 0 or nBeginValueId + nIndex - 1 > nEndValueId then
      return
    end
    return self.GetIntValue(nBeginValueId + nIndex - 1)
  end
  local function funSet(nIndex, nValue)
    assert(self)
    if nIndex <= 0 or nBeginValueId + nIndex - 1 > nEndValueId then
      return
    end
    return self.SetIntValue(nBeginValueId + nIndex - 1, nValue)
  end
  rawset(_LuaPartner, "Get" .. szDesc, funGet)
  rawset(_LuaPartner, "Set" .. szDesc, funSet)
end
_GEN_INTVALUE_RANGE_FUN("SkillValue", 1, 2)
_GEN_INTVALUE_FUN("UseProtentialItemValue", 3)
_GEN_INTVALUE_FUN("Awareness", 4, true)
