Require("CommonScript/Npc/Npc.lua")
Npc.tbActDoCallScript = {
  [1] = function(pNpc, nParam1, nParam2, nParam3, nParam4)
    Log("Test", pNpc.szName, nParam1, nParam2, nParam3, nParam4)
  end
}
function Npc:ActDoCallScript(pNpc, nType, ...)
  local funCallBack = Npc.tbActDoCallScript[nType]
  if not funCallBack then
    return
  end
  funCallBack(pNpc, ...)
end
