local tbAct = Activity:GetClass("WeddingAct")
tbAct.tbTimerTrigger = 
{ 
   
}
tbAct.tbTrigger  = {Init = {}, Start = {}, End = {}}

function tbAct:OnTrigger(szTrigger)
    if szTrigger == "Start" then
    	local nStartTime, nEndTime = self:GetOpenTimeInfo()
    	Wedding.nOpenStartTime = nStartTime
    	Wedding.nOpenEndTime = nEndTime
    elseif szTrigger == "End" then
        Wedding.nOpenStartTime = nil
    	Wedding.nOpenEndTime = nil
    end
    Log("WeddingAct OnTrigger:", szTrigger)
end