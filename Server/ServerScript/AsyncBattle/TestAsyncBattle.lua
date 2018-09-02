

AsyncBattle.__TestDemo = {}
local TestDemo = AsyncBattle.__TestDemo

local FIGHT_MAP = 1015
local RANK_BATTLE_MAP = 1003

function TestDemo:CreatePlayerBattle(pPlayer, nEnemyId)
	Log("CreatePlayerBattle", pPlayer, nEnemyId)

	local nBattleKey = GetTime();
	
	-- 同步异步数据
	if not pPlayer.SyncOtherPlayerAsyncData(nEnemyId) then
		Log("Sync Rank Player AsyncData Failed!!!")
		return;
	end
	
	if not AsyncBattle:ResgiterBattle(pPlayer, "AloneAsyncBattle", nBattleKey, 0, nRankNo) then
		return;
	end
	
	pPlayer.CallClientScript("AsyncBattle:OnAsyncBattle", "AloneAsyncBattle", nEnemyId, FIGHT_MAP, nBattleKey);
	
	if pPlayer.EnterClientMap(FIGHT_MAP, unpack(RankBattle.ENTER_POINT)) ~= 1 then
		Log("Error!! Enter Client Map Failed!");
		return;
	end
	
	return true;
end

function TestDemo:CreatePlayerBattleWS(pPlayer, nEnemyId)
	Log("CreatePlayerBattle", pPlayer, nEnemyId)

	local nBattleKey = GetTime();
	
	if not AsyncBattle:CreateAsyncBattle(pPlayer, FIGHT_MAP, RankBattle.ENTER_POINT, "AloneAsyncBattle", nEnemyId, nBattleKey) then
		return;
	end
end

function TestDemo:CreateRankBattleWS(pPlayer, nEnemyId)
	Log("CreateRankBattle", pPlayer, nEnemyId)

	local nBattleKey = GetTime();
	
	if not AsyncBattle:CreateAsyncBattle(pPlayer, RANK_BATTLE_MAP, RankBattle.ENTER_POINT, "RankBattlePvp", nEnemyId, nBattleKey) then
		return;
	end
end

function TestDemo:CreateRankBattlePVE(pPlayer, nEnemyId)
	Log("CreateRankBattle", pPlayer, nEnemyId)

	local nBattleKey = GetTime();
	
	if not AsyncBattle:CreateAsyncBattle(pPlayer, RANK_BATTLE_MAP, RankBattle.ENTER_POINT, "RankBattlePve", nEnemyId, nBattleKey) then
		return;
	end
end

function TestDemo:ResultCallback(...)
	print("ResultCallback", ...)
end

function TestDemo:ResultTimeout(...)
	print("ResultTimeout", ...)
end

AsyncBattle:ResgiterBattleType("AloneAsyncBattle", TestDemo, TestDemo.ResultCallback, TestDemo.ResultTimeout, FIGHT_MAP)
--AsyncBattle:ResgiterBattleType("RankBattlePvp", TestDemo, TestDemo.ResultCallback, TestDemo.ResultTimeout, RANK_BATTLE_MAP)
--AsyncBattle:ResgiterBattleType("RankBattlePve", TestDemo, TestDemo.ResultCallback, TestDemo.ResultTimeout, RANK_BATTLE_MAP)
