function KPlayer.CallClientScript(...)
  me.CallClientScript(...)
end
function KPlayer.GetMapPlayer(nMapId)
  if me.nMapId == nMapId then
    return {me}, 1
  end
end
function KPlayer.GetPlayerObjById(nId)
  if nId == me.dwID then
    return me
  end
end
