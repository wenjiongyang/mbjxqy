local tbNpc = Npc:GetClass("KinTrainCar")

function tbNpc:OnDialog()
    local tbFubenInst = Fuben:GetFubenInstance(me)
    if tbFubenInst and tbFubenInst.ShowMeterialInfo then
        tbFubenInst:ShowMeterialInfo(me)
    end
end