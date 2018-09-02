function GeneralProcess:GetPlayerProcessData(pPlayer)
  pPlayer.tbGeneralProcess = pPlayer.tbGeneralProcess or {}
  return pPlayer.tbGeneralProcess
end
function GeneralProcess:StartProcess(pPlayer, nInterval, szMsg, ...)
  pPlayer.BreakProgress()
  local tbProcessData = self:GetPlayerProcessData(pPlayer)
  tbProcessData.tbCallBack = {
    ...
  }
  tbProcessData.tbBreakCallBack = nil
  pPlayer.StartProgress(nInterval)
  pPlayer.CallClientScript("Ui:StartProcess", szMsg, nInterval)
end
function GeneralProcess:StartProcessExt(pPlayer, nInterval, bBeAttechBreak, nProgressNpcId, nProgressDis, szMsg, tbFinish, tbBreak)
  pPlayer.BreakProgress()
  local tbProcessData = self:GetPlayerProcessData(pPlayer)
  tbProcessData.tbCallBack = tbFinish
  tbProcessData.tbBreakCallBack = tbBreak
  pPlayer.StartProgress(nInterval, bBeAttechBreak and 0 or 1, nProgressNpcId, nProgressDis)
  pPlayer.CallClientScript("Ui:StartProcess", szMsg, nInterval)
end
function GeneralProcess:OnFinish()
  local tbCallBack = self:GetPlayerProcessData(me).tbCallBack
  if not tbCallBack or #tbCallBack == 0 then
    return
  end
  Lib:CallBack(tbCallBack)
end
function GeneralProcess:OnBreak()
  local tbProcessData = self:GetPlayerProcessData(me)
  local tbCallBack = tbProcessData.tbBreakCallBack
  if me then
    me.CallClientScript("Ui:CloseProcess")
  end
  if not tbCallBack or #tbCallBack == 0 then
    return
  end
  Lib:CallBack(tbCallBack)
end
