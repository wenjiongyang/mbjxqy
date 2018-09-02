Fuben.KinTrainMgr = Fuben.KinTrainMgr or {}
local KinTrainMgr = Fuben.KinTrainMgr
KinTrainMgr.MAPTEMPLATEID = 1048
function KinTrainMgr:OnFubenStartFail()
  me.CenterMsg("人数不足，家族试炼开启失败")
end
function KinTrainMgr:OnFubenOver(szMsg)
  me.CenterMsg(szMsg)
  Fuben:SetFubenProgress(-1, "家族试炼已结束")
  Fuben:ShowLeave()
end
function KinTrainMgr:ShowMeterialInfo(...)
  if Ui:WindowVisible("KinTrainMatPanel") then
    UiNotify.OnNotify(UiNotify.emNOTIFY_SYNC_KIN_TRAIN_MAT, {
      ...
    })
  else
    Ui:OpenWindow("KinTrainMatPanel", {
      ...
    })
  end
end
local fnOpenFubenUi = function(bShowLeave, nEndTime)
  Ui:OpenWindow("HomeScreenFuben", "KinTrain")
  if bShowLeave then
    Fuben:ShowLeave()
  end
  Fuben:SetEndTime(nEndTime)
end
function KinTrainMgr:OnEntryMap(bShowLeave, nEndTime)
  fnOpenFubenUi(bShowLeave, nEndTime)
end
function KinTrainMgr:OnTrainBegin(bShowLeave, nEndTime)
  fnOpenFubenUi(bShowLeave, nEndTime)
end
function KinTrainMgr:OnMapLoaded(nMapTemplateId)
  if nMapTemplateId ~= self.MAPTEMPLATEID then
    return
  end
  UiNotify.OnNotify(UiNotify.emNOTIFY_SHOWTEAM_NO_TASK)
end
