local self
local function _GEN_ASYNC_FUN(szDesc, nValueId)
  local function funGet()
    return self.GetAsyncValue(nValueId)
  end
  local function funSet(nValue)
    return self.SetAsyncValue(nValueId, nValue)
  end
  rawset(_LuaPlayerAsync, "Get" .. szDesc, funGet)
  rawset(_LuaPlayerAsync, "Set" .. szDesc, funSet)
end
local function _GEN_BATTLE_FUN(szDesc, nValueId)
  local function funGet()
    return self.GetAsyncBattleValue(nValueId)
  end
  local function funSet(nValue)
    return self.SetAsyncBattleValue(nValueId, nValue)
  end
  rawset(_LuaPlayerAsync, "Get" .. szDesc, funGet)
  rawset(_LuaPlayerAsync, "Set" .. szDesc, funSet)
end
local function _GEN_BATTLE_RANGE_FUN(szDesc, nBeginValueId, nEndValueId)
  local function funGet(nIndex)
    assert(self)
    if nIndex <= 0 or nBeginValueId + nIndex - 1 > nEndValueId then
      return
    end
    return self.GetAsyncBattleValue(nBeginValueId + nIndex - 1)
  end
  local function funSet(nIndex, nValue)
    assert(self)
    if nIndex <= 0 or nBeginValueId + nIndex - 1 > nEndValueId then
      return
    end
    return self.SetAsyncBattleValue(nBeginValueId + nIndex - 1, nValue)
  end
  rawset(_LuaPlayerAsync, "Get" .. szDesc, funGet)
  rawset(_LuaPlayerAsync, "Set" .. szDesc, funSet)
end
function _LuaPlayerAsync.GetInsetInfo(nPos)
  if nPos >= Item.EQUIPPOS_MAIN_NUM then
    return {}
  end
  local tbInfo = {}
  for i = 1, StoneMgr.INSET_COUNT_MAX do
    table.insert(tbInfo, self.GetInset(StoneMgr:GetInsetAsyncKey(nPos, i)))
  end
  return tbInfo
end
function _LuaPlayerAsync.GetStrengthen()
  local tbInfo = {}
  for i = 1, Item.EQUIPPOS_MAIN_NUM do
    table.insert(tbInfo, self.GetEnhance(i))
  end
  return tbInfo
end
_GEN_ASYNC_FUN("Coin", 1)
_GEN_ASYNC_FUN("CoinAdd", 2)
_GEN_ASYNC_FUN("VipLevel", 31)
_GEN_ASYNC_FUN("JuBaoPenVal", 32)
_GEN_ASYNC_FUN("JuBaoPenTime", 33)
_GEN_ASYNC_FUN("ChatForbidType", 34)
_GEN_ASYNC_FUN("ChatForbidEndTime", 35)
_GEN_ASYNC_FUN("ChatForbidSilence", 36)
_GEN_ASYNC_FUN("DebrisAvoidTime", 37)
_GEN_ASYNC_FUN("MapExploreEnyMap", 38)
_GEN_ASYNC_FUN("FriendNum", 39)
_GEN_ASYNC_FUN("FactionHonor", 41)
_GEN_ASYNC_FUN("BattleHonor", 42)
_GEN_ASYNC_FUN("RankHonor", 43)
_GEN_ASYNC_FUN("DomainHonor", 44)
_GEN_ASYNC_FUN("RewardValueDebt", 45)
_GEN_BATTLE_RANGE_FUN("BattleArray", 1, 10)
_GEN_BATTLE_FUN("Level", 11)
_GEN_BATTLE_FUN("HonorLevel", 12)
_GEN_BATTLE_FUN("Faction", 13)
_GEN_BATTLE_FUN("FightPower", 114)
_GEN_BATTLE_FUN("BaseDamage", 115)
_GEN_BATTLE_FUN("MaxHp", 116)
_GEN_BATTLE_FUN("Vitality", 151)
_GEN_BATTLE_FUN("Strength", 152)
_GEN_BATTLE_FUN("Energy", 153)
_GEN_BATTLE_FUN("Dexterity", 154)
_GEN_BATTLE_FUN("OpenLight", 129)
_GEN_BATTLE_RANGE_FUN("Enhance", 14, 33)
_GEN_BATTLE_RANGE_FUN("Inset", 34, 113)
_GEN_BATTLE_RANGE_FUN("Suit", 130, 139)
_GEN_BATTLE_RANGE_FUN("PlayerAttribute", 140, 150)
