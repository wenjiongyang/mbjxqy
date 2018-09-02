local tbCountAddProp = Item:GetClass("CountAddProp");

function tbCountAddProp:LoadSetting()
	local tbTitle = {
	"TemplateId",
	"AddDegree",
	"AddCount",
	"CostDegree"
	};
	
	self.tbAllPropInfo = LoadTabFile("Setting/Item/Other/CountAddProp.tab", "dsds", "TemplateId", tbTitle);
	assert(self.tbAllPropInfo)
end

tbCountAddProp:LoadSetting();

function tbCountAddProp:OnUse(it)
	local tbKey = self.tbAllPropInfo[it.dwTemplateId];
	if not tbKey then
		Log("[CountAddProp] OnUse ERR ?? tbKey is nil !!", me.szName, me.dwID, it.szName, it.dwTemplateId);
		me.CenterMsg("很遺憾,系統檢測到該道具異常,暫時無法使用!");
		return 0;
	end

	if tbKey.CostDegree ~= "" then
		if not DegreeCtrl:ReduceDegree(me, tbKey.CostDegree, 1) then
			me.CenterMsg(string.format("%s每天限用道具增加%d次", DegreeCtrl:GetDegreeDesc(tbKey.AddDegree), DegreeCtrl:GetMaxDegree(tbKey.CostDegree, me)) )
			return 0;
		end
	end

	local szDesc = DegreeCtrl:GetDegreeDesc(tbKey.AddDegree)
	DegreeCtrl:AddDegree(me, tbKey.AddDegree, tbKey.AddCount);		

	me.CallClientScript("me.BuyTimesSuccess", string.format("成功增加%s %d次，快去參加活動吧！", szDesc, tbKey.AddCount));
	return 1;
end

function tbCountAddProp:GetAddDegreeItemId(szDegree)
	for k,v in pairs(self.tbAllPropInfo) do
		if v.AddDegree == szDegree then
			return k;
		end
	end
end

function tbCountAddProp:OnClientUse(it)
	local tbKey = self.tbAllPropInfo[it.dwTemplateId];
	if not tbKey then
		Log(debug.traceback(), it.dwTemplateId)
		return 1
	end
	if tbKey.AddDegree == InDifferBattle.tbDefine.szCalenddayKey or tbKey.AddDegree == "Battle" then 
		--只有活动当天才能用
		local nId = Calendar:GetActivityId(tbKey.AddDegree)
		local tbTime = Calendar:GetTodayOpenTime(nId)
		if not next(tbTime) then
			if tbKey.AddDegree == "Battle" then
				local nId = Calendar:GetActivityId("BattleMoba")
				tbTime = Calendar:GetTodayOpenTime(nId)
			end
		end
		if not next(tbTime) then
			me.CenterMsg(string.format("今天沒有%s活動，暫時不可使用",Calendar:GetActivityName(nId) ) )  
			return 1;
		end
	end
end

function tbCountAddProp:GetUseSetting(nItemTemplateId, nItemId)
	if nItemId and nItemId > 0 then
		return {szFirstName = "使用", fnFirst = "UseItem"};
	end

	local nPrice = MarketStall:GetPriceInfo("item", nItemTemplateId);
	if not nPrice then
		return {};
	end

	return {
				bForceShow = true,
				szFirstName = "前往擺攤購買",
				fnFirst = function ()
					Ui:OpenWindow("MarketStallPanel", 1, nil, "item", nItemTemplateId);
					Ui:CloseWindow("ItemTips");
				end
			};
end
