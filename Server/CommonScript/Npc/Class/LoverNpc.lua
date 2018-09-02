
local tbNpc = Npc:GetClass("LoverNpc");

function tbNpc:OnDialog()
	local szText = "問世間情為何物，直教人生死相許！";
	local tbOptList = {};

	if BiWuZhaoQin:GetLover(me.dwID) and not self.bBiWuZhaoQinOpen then
		table.insert(tbOptList, { Text = "解除情緣關係", Callback = function () self:RemoveLover(); end});
	end

	Dialog:Show(
	{
		Text	= szText,
		OptList = tbOptList,
	}, me, him);
end

function tbNpc:OnBiWuZhaoQinStateChange(bOpen)
	self.bBiWuZhaoQinOpen = bOpen;
end

function tbNpc:RemoveLover(bConfirm)
	if not bConfirm then
		local nLover = BiWuZhaoQin:GetLover(me.dwID);
		if not nLover then
			me.CenterMsg("您沒有情緣關係需要解除！");
			return;
		end

		local tbRoleInfo = KPlayer.GetRoleStayInfo(nLover or 0) or {szName = "無名"};
		me.MsgBox(string.format("您確定解除與俠士[FFFE0D]%s[-]的情緣關係嗎？操作會[FFFE0D]立即生效[-]！", tbRoleInfo.szName), {{"確定", function ()
			self:RemoveLover(true);
		end}, {"取消"}})

		return;
	end

	local nOtherId = BiWuZhaoQin:RemoveLover(me);
	if not nOtherId then
		me.CenterMsg("您沒有情緣關係需要解除！");
		return;
	end

	local tbRoleInfo = KPlayer.GetRoleStayInfo(nOtherId or 0) or {szName = "無名"};

	me.DeleteTitle(BiWuZhaoQin.nTitleId);
	Mail:SendSystemMail({
		To = nOtherId,
		Title = "情緣解除",
		Text = string.format("大俠，很遺憾的告訴您，俠士[FFFE0D]%s[-]於%s解除了與您的情緣關係！", me.szName, os.date("%Y年%m月%d日", GetTime())),
		From = "燕若雪",
	});

	local pOther = KPlayer.GetPlayerObjById(nOtherId);
	if pOther then
		BiWuZhaoQin:RemoveLover(pOther);
		pOther.DeleteTitle(BiWuZhaoQin.nTitleId);
	end
	me.CenterMsg(string.format("您解除了與俠士[FFFE0D]%s[-]的情緣關係！", tbRoleInfo.szName));
end