local tbItem = Item:GetClass("ChuangGongAdd");
tbItem.ADD_ACCEPT_TIMES = 1					-- 增加的被传次数
tbItem.ADD_SEND_TIMES = 1					-- 增加的传功次数

function tbItem:OnUse(it)
	if not it.dwTemplateId then
		return 
	end
	if DegreeCtrl:GetDegree(me, "ChuangGongAdd") < 1 then
		me.CenterMsg("當天的使用次數達到上限！")
		return
	end
	if not DegreeCtrl:ReduceDegree(me, "ChuangGongAdd", 1) then
		me.CenterMsg("扣除次數失敗！")
		return
	end

	DegreeCtrl:AddDegree(me, "ChuangGong", self.ADD_ACCEPT_TIMES);
	DegreeCtrl:AddDegree(me, "ChuangGongSend", self.ADD_SEND_TIMES);

	me.CenterMsg(string.format("您的傳功次數增加%d次，被傳功次數增加%d次",self.ADD_SEND_TIMES,self.ADD_ACCEPT_TIMES));
	
	return 1
end