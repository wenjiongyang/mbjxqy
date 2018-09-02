local tbNpc = Npc:GetClass("FubenDialogEvent")

function tbNpc:OnDialog()
	local szScriptParam = string.gsub(him.szScriptParam, "\"", "")
	local tbRet = Lib:SplitStr(szScriptParam, ",");
	local nTime = tonumber(tbRet[1])
	if not tbRet[3] then
		Log(him.nTemplateId, debug.traceback())
	end
	if not nTime then
		self:EndProcess(me.dwID, him.nId);
	else
		local szMsg = tbRet[2] or "開啟中...";
		GeneralProcess:StartProcess(me, nTime * Env.GAME_FPS, szMsg, self.EndProcess, self, me.dwID, him.nId, tbRet[3], tbRet[4]);
	end
end

function tbNpc:EndProcess(nPlayerId, nNpcId, szEvent, szParam)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		Log("not player ??")
		return;
	end
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		Log("not npc ??")
		return;
 	end
	Fuben:NpcRaiseEvent(pNpc, szEvent, pPlayer, szParam) --在事件里删
end
