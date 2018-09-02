function KPlayer.BoardcastScript(nMinLevel, szFunction, ...)
	local nFuncId = s2c.func2id[szFunction]
	if nFuncId then
		KPlayer.BoardcastScriptByFuncId(nMinLevel, nFuncId, ...);
	else
		KPlayer.BoardcastScriptByFuncName(nMinLevel, szFunction, ...);
	end
end

function KPlayer.MapBoardcastScript(nMapId, szFunction, ...)
	local nFuncId = s2c.func2id[szFunction]
	if nFuncId then
		KPlayer.MapBoardcastScriptByFuncId(nMapId, nFuncId, ...);
	else
		KPlayer.MapBoardcastScriptByFuncName(nMapId, szFunction, ...);
	end
end
