
KinBattle.STATE_NONE = 0;
KinBattle.STATE_PRE = 1;
KinBattle.STATE_FIGHT = 2;

KinBattle.PRE_MAP_ID = 1021;
KinBattle.tbPreMapBeginPos = {5609, 8595};

KinBattle.MAX_PLAYER_COUNT = 20;

KinBattle.FIGHT_MAP_ID = 1023;
KinBattle.tbFightMapBeginPoint = {
	{4150,  6788};
	{14244, 6788};
};

KinBattle.nPreTime = 5 * 60;

KinBattle.nNpcRefreshTime = 60;

KinBattle.fileCommNpc = "Setting/Battle/KinBattle/CommNpcSetting.tab";
-- KinBattle.fileDotaNpc = "Setting/Battle/KinBattle/DotaNpcSetting.tab";
KinBattle.fileWildNpc = "Setting/Battle/KinBattle/WildNpcSetting.tab";
KinBattle.fileMovePath= "Setting/Battle/KinBattle/MovePath.tab";

KinBattle.tbKinRankSetting = {6, 11, 21, 31};

KinBattle.nKinBattleTypeCount = 2;

KinBattle.tbStateTrans = KinBattle.STATE_TRANS;

KinBattle.tbResultKinMsg =
{
	[-1] = "本幫派在本輪幫派中與對手戰成平局";			--平局
	[0] = "很遺憾，本幫派在本輪幫派戰中戰敗了";				--失败
	[1] = "恭喜本幫派在本輪幫派中戰勝對手！";			--胜利
}
KinBattle.tbFightByeMsg = "本輪輪空，沒有匹配到對手，直接獲勝！";  --轮空

KinBattle.szStartWorldMsg = "幫派戰開啟新一輪報名，從活動日曆選擇參加幫派戰";

KinBattle.szWinText = "恭喜你幫派在幫派戰的一輪比賽中取得了勝利，每位幫派成員可以獲得1200點貢獻的獎勵";
KinBattle.nWinPrestige = 400;
KinBattle.tbWinAward = {
	{"Contrib", 1200};
};

KinBattle.szFailText = "很遺憾，你幫派在幫派戰的一輪比賽中戰敗了，每位幫派成員可以獲得600點貢獻的獎勵";
KinBattle.nFailPrestige = 200;
KinBattle.tbFailAward = {
	{"Contrib", 600};
};

KinBattle.szDrawText = "你幫派在幫派戰的一輪比賽中與對手戰成平局，每位幫派成員可以獲得900點貢獻的獎勵";
KinBattle.nDrawPrestige = 300;
KinBattle.tbDrawAward = {
	{"Contrib", 900};
};



KinBattle.tbTimeTips = {
[[報名   20:50
開戰   21:00]],
[[報名   21:15
開戰   21:20]]
};
KinBattle.szTips = [[·幫派戰共分兩輪，每輪隨機另一幫派作為對手。
·每輪比賽同時開啟1號和2號場。每一場中，每個幫派最多只能進入20人。
·1號和2號場同時開戰，若幫派在1號、2號場均取得勝利，則判定幫派本輪勝利；若幫派在1號、2號場中，只取得1場勝利，則判定幫派本輪戰平。

·每場有人數上限，堂主可手動設置幫派成員參與的等級要求，讓符合等級要求的幫派成員來參加比賽。

]]

