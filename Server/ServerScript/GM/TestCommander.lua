local tbGMEquipSetting = LoadTabFile(
        "Setting/GM/GMEquip.tab",
        "ddd", nil,
        {"Level", "Layer", "EquipId"});

local tbGMInsetSetting = LoadTabFile(
        "Setting/GM/GMInset.tab",
        "dddddddddd", nil,
        {"Level", "Layer", "EquipPos", "StoneId1", "StoneId2", "StoneId3", "StoneId4", "StoneId5", "StoneId6", "StoneId7"});

local tbCodeGiftSetting = LoadTabFile(
        "ServerSetting/CodeAward/CodeAward.tab",
        "ss", nil,
        {"Name", "Type"});

local tbScriptItemSetting = LoadTabFile(
        "Setting/Item/Other/ScriptItem.tab",
        "ds", nil,
        {"TemplateId", "ClassName"});

GM.tbEquipSetting = {};
for _,v in pairs(tbGMEquipSetting) do
	GM.tbEquipSetting[v.Level] = GM.tbEquipSetting[v.Level] or {};
	GM.tbEquipSetting[v.Level][v.Layer] = GM.tbEquipSetting[v.Level][v.Layer] or {};

	table.insert(GM.tbEquipSetting[v.Level][v.Layer], v.EquipId);
end

GM.tbInsetSetting = {};
for _,v in pairs(tbGMInsetSetting) do
	GM.tbInsetSetting[v.Level] = GM.tbInsetSetting[v.Level] or {};
	GM.tbInsetSetting[v.Level][v.Layer] = GM.tbInsetSetting[v.Level][v.Layer] or {};
	GM.tbInsetSetting[v.Level][v.Layer][v.EquipPos] = GM.tbInsetSetting[v.Level][v.Layer][v.EquipPos] or {};

	GM.tbInsetSetting[v.Level][v.Layer][v.EquipPos] = {v.StoneId1, v.StoneId2, v.StoneId3, v.StoneId4, v.StoneId5, v.StoneId6, v.StoneId7};
end

function GM:TestCommander()
	me.CallClientScript("Ui:OpenWindow", "GMListPanel");
end

function GM:OpenBossActivity()
	Boss:StartBossFight();
	me.CallClientScript("Ui:OpenWindow", "BossPanel");
end

local tbGMPartnerInfo = {
--	玩家等级	同伴阶级	进化等级
	{20,			2,			1},
	{30,			4,			1},
	{40,			8,			2},
	{60,			15,			5},
}

function GM:AddQualityPartner(nQuality)
	if not nQuality then
		return
	end
	local tbAllPartner = Partner:GetAllPartnerBaseInfo();
	for nId,tbInfo in pairs(tbAllPartner) do
		if nQuality == tbInfo.nQualityLevel then
			me.AddPartner(nId);
		end
	end
end

function GM:AddAIPartner(tbPartner)
	for _, nPartnerId in ipairs(tbPartner) do
		me.AddPartner(nPartnerId);
	end
end

function GM:AddPartnerExp()
	local tbPos = me.GetPartnerPosInfo();
	for _, v in pairs(tbPos) do
		me.AddPartnerExp(v, 100000000);
	end
end


function GM:AddOnePartner(nPartnerId, bShowExt)
	local nGradeLevel = 0;
	local nGrowthLevel = 1;
	for _, tbInfo in pairs(tbGMPartnerInfo) do
		if tbInfo[1] >= me.nLevel then
			nGradeLevel = tbInfo[2];
			nGrowthLevel = tbInfo[3];
			break;
		end
	end
	me.AddPartner(nPartnerId);
end

function GM:AddCangbaotu()
	me.AddItem(787, 12);
end

function GM:AddSeniorCangbaotu()
	me.AddItem(788, 12);
end

function GM:CleanBag()
	local items = me.GetItemListInBag();
	for nIdx, pItem in ipairs(items) do
		pItem.Delete(1)
	end
end

function GM:OpenRankPanel()
	me.CallClientScript("Ui:OpenWindow", "RankPanel");
end

--临时  todo
function GM:OpenBattleSignUp()
	me.CallClientScript("Ui:OpenWindow", "BattleEntrance");
end

function GM:GMAddMoney(nCount)
	AssistClient.bFakeMidasServer = true;
	for szType in pairs(Shop.tbMoney) do
		me.AddMoney(szType, nCount,1);
	end
end

function GM:Revive()
	me.CallClientScript("Fuben:ReviveClientPlayer", true);
	me.Revive(0);
end

function GM:RefreshHp()
	local pNpc = me.GetNpc();
	if pNpc then
		pNpc.SetCurLife(pNpc.nMaxLife);
	end
end

function GM:AddPlayerLevel(nLevel)
	local nAddLevel = nLevel - me.nLevel;
	if nAddLevel then
		me.AddLevel(nAddLevel);
	end
end

function GM:SetHonorLevel(nLevel)
    me.SetHonorLevel(nLevel);
end

function GM:AddEquips(nLevel, nLayer)
	if self.tbEquipSetting[nLevel] and self.tbEquipSetting[nLevel][nLayer] then
		local tbSetting = self.tbEquipSetting[nLevel][nLayer];
		for _, nEquipTemplateId in ipairs(tbSetting) do
			Log(string.format("GM:AddEquips  nEquipTemplateId:%d ", nEquipTemplateId));
			local pEquip = me.AddItem(nEquipTemplateId, 1);
			Item:UseEquip(pEquip.dwId);
		end
	end
end

function GM:InsetEquip(nLevel, nLayer)
	if self.tbInsetSetting[nLevel] and self.tbInsetSetting[nLevel][nLayer] then
		local tbSetting = self.tbInsetSetting[nLevel][nLayer];
		local tbAllEquips = me.GetEquips();
	    for nEquipPos, nEquipId in pairs(tbAllEquips) do
	    	local tbInsetSetting = tbSetting[nEquipPos];
	    	local i = 0
	    	for _, nStoneTemplateId in pairs(tbInsetSetting) do
	    		if nStoneTemplateId ~= 0 then
	    			i = i + 1;
		    		Log(string.format("GM:InsetEquip  nEquipId:%d  nStoneTemplateId:%d", nEquipId, nStoneTemplateId));
		    		StoneMgr:DoInset(me, nEquipPos, nEquipId, nStoneTemplateId, nil, i);
	    		end
	    	end
	    end
	end
end

function GM:SkillUpFull()
	local nMyLevel = me.nLevel;
	local tbFactionSkill = FightSkill:GetFactionSkill(me.nFaction);
	for _,v in pairs(tbFactionSkill) do
		local nSkillId = v.SkillId;
		local tbLevelUp = FightSkill.tbSkillLevelUp[nSkillId];
		if tbLevelUp then
			local nOrgMaxLevel = FightSkill:GetSkillMaxLevel(nSkillId);
			local nSkillMaxLevel = nOrgMaxLevel + FightSkill:GetSkillLimitAddLevel(me, nSkillId);
			local nToLevel = nSkillMaxLevel;
			for i = 1, nSkillMaxLevel do
				local tbNeed = tbLevelUp[i] or tbLevelUp[nOrgMaxLevel];
				local nReqLevel = tbNeed[1];
				if nMyLevel < nReqLevel then
					nToLevel = i - 1;
					break;
				end
			end
			local _, nBaseLevel = me.GetSkillLevel(nSkillId);
			if nToLevel > 1 and nToLevel > nBaseLevel then
				Log(string.format("GM:SkillUpFull  SkillId:%d  Level:%d", nSkillId, nToLevel));
				FightSkill:DoSkillLevelUp(me, nSkillId, nToLevel - nBaseLevel);
			end
		end
	end
end

function GM:EnhanceEquip(nLevel)
	local tbAllEquips = me.GetEquips();
	for nEquipPos, nEquipId in pairs(tbAllEquips) do
		Log(string.format("GM:EnhanceEquip  EquipId:%d  Level:%d", nEquipId, nLevel));
		self:QuickEnhance(me, nEquipId, nEquipPos, nLevel);
	end
end

function GM:QuickEnhance(pPlayer, nEquipId, nEquipPos, nStrenLevel)
	Strengthen:DoStrengthen(pPlayer, nEquipId, nEquipPos, nStrenLevel);
	--突破次数
	local nBreakCount 	= Strengthen:GetPlayerBreakCount(pPlayer, nEquipPos);
	local nNeed 		= Strengthen:GetNeedBreakCount(nStrenLevel);
	Strengthen:SetPlayerBreakCount(pPlayer, nEquipPos, nNeed)
end

--自己配置要增加的物品
function GM:AddItemList()
	--连续ID
	for i = 555,560  do
		me.AddItem(i, 1);
	end

	for i = 364,369  do
		me.AddItem(i, 1);
	end

	for i = 435,440  do
		me.AddItem(i, 1);
	end

	for i = 459,464  do
		me.AddItem(i, 1);
	end

	for i = 388,393  do
		me.AddItem(i, 1);
	end

	for i = 411,416  do
		me.AddItem(i, 1);
	end

	--非连续ID
	local tbAdd =
	{
		218,
	}

	for i, nTemplateId in pairs(tbAdd) do
		me.AddItem(nTemplateId, 1);
	end
end

function GM:QuicklyEquipment()
	self:AddPlayerLevel(40);
	self:SkillUpFull();
	self:AddEquips(40, 1);
	self:EnhanceEquip(20);
	self:InsetEquip(40, 1);
	self:AddEquipUse(2399);
	self:AddSkillBook(0);
end

function GM:QuicklyEquipment2()
	self:AddPlayerLevel(80);
	self:SkillUpFull();
	self:AddEquips(80, 3);
	self:EnhanceEquip(70);
	self:InsetEquip(80, 3);
	self:AddEquipUse(2400);
	self:AddSkillBook(1);
end

function GM:QuicklyEquipment3()
	self:AddPlayerLevel(100);
	self:SkillUpFull();
	self:AddEquips(100, 3);
	self:EnhanceEquip(80);
	self:InsetEquip(100, 3);
	self:AddEquipUse(3598);
	self:AddSkillBook(2);
end

function GM:QuicklyEquipment4()
	self:AddPlayerLevel(110);
	self:SkillUpFull();
	self:AddEquips(110, 3);
	self:EnhanceEquip(90);
	self:InsetEquip(110, 3);
	self:AddEquipUse(3598);
	self:AddSkillBook(2);
end

function GM:QuicklyEquipment5()
	self:AddPlayerLevel(120);
	self:AddAllMaxSkillLevel();
	self:SkillUpFull();
	self:AddEquips(120, 3);
	self:EnhanceEquip(100);
	self:InsetEquip(120, 3);
	self:AddEquipUse(3598);
	self:AddSkillBook(2);
end

function GM:AddAllMaxSkillLevel()
   	local tbItem = Item:GetClass("SkillMaxLevel");
	for _, tbInfo in pairs(tbItem.tbItemLimitInfo) do
		me.SetUserValue(tbItem.nSaveLevelGroup, tbInfo.nSaveID, tbInfo.nMaxCount * tbInfo.nAdd);
	end
end

function GM:AddEquipUse(nItemID)
	local pItem = me.AddItem(nItemID, 1);
	Item:UseEquip(pItem.dwId, nil, -1);
end

function GM:AddSkillBook(nType)
    local tbSkillBook = Item:GetClass("SkillBook");
    local tbFactionBook = {};
    for nBookID, tbInfo in pairs(tbSkillBook.tbBookSetting) do
        if nBookID > 0 and tbInfo.LimitFaction == me.nFaction and tbInfo.Type == nType then
            tbFactionBook[nBookID] = 1;
        end
    end
    local nEndPos = Item.EQUIPPOS_SKILL_BOOK + #tbSkillBook.tbSkillBookHoleLevel - 1;
	for nEquipPos = Item.EQUIPPOS_SKILL_BOOK, nEndPos, 1 do
		Item:UnuseEquip(nEquipPos);
	end
    local nIndexPos = 0;
    for nBookID, _ in pairs(tbFactionBook) do
        local pItem = me.AddItem(nBookID, 1, nil, Env.LogWay_MiJi);
        if pItem then
            local tbBookInfo = tbSkillBook:GetBookInfo(nBookID);
            if tbBookInfo then
                pItem.SetIntValue(tbSkillBook.nSaveSkillLevel, tbBookInfo.MaxSkillLevel);
                pItem.SetIntValue(tbSkillBook.nSaveBookLevel, tbBookInfo.MaxBookLevel);
                pItem.ReInit();
            end
            Item:UseEquip(pItem.dwId, nil, Item.EQUIPPOS_SKILL_BOOK + nIndexPos);
            nIndexPos  = nIndexPos + 1;
        end
    end
end

function GM:TestClientPk()
	local fnCallback = function (nFaction, nAutoSkill)
		me.CallClientScript("AsyncBattle:OnAsyncBattle", "PvpAutoTest", nFaction, 1003, GetTime(), nAutoSkill);
		me.EnterClientMap(1003, 2054, 2084);
	end
	Dialog:Show(
	{
		Text = "來，燒手機取取暖！！！",
		OptList = 	{
			{ Text = "天王20vs20", 			Callback = fnCallback, Param = {1, 1} },
			{ Text = "天王20vs20(普攻)", 	Callback = fnCallback, Param = {1, 0} },
			{ Text = "峨嵋20vs20", 			Callback = fnCallback, Param = {2, 1} },
			{ Text = "峨嵋20vs20(普攻)", 	Callback = fnCallback, Param = {2, 0} },
			{ Text = "桃花20vs20", 			Callback = fnCallback, Param = {3, 1} },
			{ Text = "桃花20vs20(普攻)", 	Callback = fnCallback, Param = {3, 0} },
			{ Text = "逍遙20vs20", 			Callback = fnCallback, Param = {4, 1} },
			{ Text = "逍遙20vs20(普攻)", 	Callback = fnCallback, Param = {4, 0} },
			{ Text = "武當20vs20", 			Callback = fnCallback, Param = {5, 1} },
			{ Text = "武當20vs20(普攻)", 	Callback = fnCallback, Param = {5, 0} },
			{ Text = "天忍20vs20", 			Callback = fnCallback, Param = {6, 1} },
			{ Text = "天忍20vs20(普攻)", 	Callback = fnCallback, Param = {6, 0} },
			{ Text = "隨機20vs20", 			Callback = fnCallback, Param = {-1, 1} },
			{ Text = "隨機20vs20(普攻)",	Callback = fnCallback, Param = {-1, 0} },
		};
	}, me);
end

function GM:QunYingHuiOpen()
	QunYingHui:FirstStartGame();
	QunYingHui:StartGame();
end

function GM:QunYingHuiJoin()
	QunYingHui:PlayerSignUpGame(me);
end

function GM:MapTest()
	me.EnterClientMap(99999, 2054, 2084);
end

function GM:UnlockFuben()
	PersonalFuben:UnlockFuben();
end

function GM:DirectGotoDungeon()
	Fuben.DungeonFubenMgr:CreateFuben(me, false);
end

function GM:SwitchSkillState()
	local nBuffSkillId = 4;
	if me.GetNpc().GetSkillState(nBuffSkillId) then
		me.GetNpc().RemoveSkillState(nBuffSkillId);
	else
		me.GetNpc().AddSkillState(nBuffSkillId, 1, 1, 100000000, 1);
	end
end

function GM:SwitchSkillState1()
	local nBuffSkillId = 4;
	if me.GetNpc().GetSkillState(nBuffSkillId) then
		me.GetNpc().RemoveSkillState(nBuffSkillId);
	else
		me.GetNpc().AddSkillState(nBuffSkillId, 30, 1, 100000000, 1);
	end
end

function GM:SwitchSkillState2()
	local nBuffSkillId = 58;
	if me.GetNpc().GetSkillState(nBuffSkillId) then
		me.GetNpc().RemoveSkillState(nBuffSkillId);
	else
		me.GetNpc().AddSkillState(nBuffSkillId, 10, 1, 100000000, 1);
	end
end

function GM:SwitchSkillState3()
	local nBuffSkillId = 58;
	if me.GetNpc().GetSkillState(nBuffSkillId) then
		me.GetNpc().RemoveSkillState(nBuffSkillId);
	else
		me.GetNpc().AddSkillState(nBuffSkillId, 20, 1, 100000000, 1);
	end
end

function GM:SwitchSkillState4()
	local nBuffSkillId = 58;
	if me.GetNpc().GetSkillState(nBuffSkillId) then
		me.GetNpc().RemoveSkillState(nBuffSkillId);
	else
		me.GetNpc().AddSkillState(nBuffSkillId, 30, 1, 100000000, 1);
	end
end

function GM:OneKeyShow()
	GM:AddPlayerLevel(30);
	GM:SkillUpFull();
	GM:AddEquips(30, 1);
	GM:EnhanceEquip(10);
	PersonalFuben:UnlockFuben();
	GM:AddOnePartner(78);
	GM:AddOnePartner(49);
end

function GM:OpenBattle()
	Battle:OpenBattleSignUp(2);  --元帅战场
end

function GM:OpenBatte1()
	Battle:OpenBattleSignUp(1);  --杀戮战场
end

function GM:OpenBatte8()
	Battle:StopBattleSignUp();
	Battle:OpenBattleSignUp(8);  --宋金攻防战
end
function GM:OpenWhiteTigerFuben()
	Fuben.WhiteTigerFuben:Start();
end

function GM:CloseWhiteTigerFuben()
	Fuben.WhiteTigerFuben:CloseFuben();
end

function GM:EnterWhiteTigerFuben()
	Fuben.WhiteTigerFuben:TryEnterPrepareMap(me);
end

function GM:AddDegreeWhiteTigerFuben()
	DegreeCtrl:AddDegree(me, "WhiteTigerFuben", 1);
end

function GM:PreStartBossLeader()
	ScheduleTask:PreStartBoss();
end

function GM:StartBossLeader()
	ScheduleTask:StartBoss(nExtCount);
end

function GM:CloseBossLeader()
	BossLeader:CloseActivity("Boss", 0);
end

function GM:OpenFactionBattle()
	ScheduleTask:StartFactionBattle();
end

function GM:JoinFactionBattle()
	FactionBattle:TrapIn(me);
end

function GM:CloseFactionBattle()
	FactionBattle:Close();
end

function GM:OpenTeamBattle()
	TeamBattle:PreStartTeamBattle(60);
end

function GM:OpenTeamBattle_Cross()
	TeamBattle:PreStartTeamBattle(60, true);
end

function GM:EnterTeamBattle()
	TeamBattle:TryJoinPreMap(me, true);
end

function GM:OpenKinTrain()
	Fuben.KinTrainMgr:Start();
end

function GM:EnterKinTrain()
	Fuben.KinTrainMgr:TryEnterMap(me);
end

function GM:OpenBoss()
	BossLeader:StartActivity("Leader", 0);
end

function GM:CloseBoss()
	BossLeader:CloseActivity("Leader", 0);
end

function GM:StartDomainBattleDeclareWar()
	DomainBattle:StartDeclareWar();
end

function GM:StartDomainBattleActivity()
	DomainBattle:StartActivity();
end

function GM:StartKinGatherActivity()
	Kin:StartKinGatherActivity();
end

function GM:OpenMascot()
	Kin:OpenMascot(true);
end

function GM:CloseMascot()
	Kin:OpenMascot(false);
end

function GM:DismissMyKin()
	Kin:_Dismiss(me.dwKinId);
end

function GM:OpenAloneBattle()
	Battle:RequireAloneBattle(me);
end
function GM:StartKinEscort()
	ScheduleTask:StartKinEscort();
end

function GM:BuyMonCardCallBack()
	AssistClient.bFakeMidasServer = true;
	Recharge:OnBuyDaysCardCallBack(me, GetTime() + 3600 * 24 * 30, 2);
end

function GM:BuyWeekCardCallBack()
	AssistClient.bFakeMidasServer = true;
	Recharge:OnBuyDaysCardCallBack(me, GetTime()+ 3600 *24*7, 1);
end

function GM:OnBuyDayCardCallBack1()
	AssistClient.bFakeMidasServer = true;
	Recharge:OnBuyOneDayCardCallBack(me, GetTime() + 3600 * 24, 1);
end

function GM:OnBuyDayCardCallBack3()
	AssistClient.bFakeMidasServer = true;
	Recharge:OnBuyOneDayCardCallBack(me, GetTime() + 3600 * 24, 2);
end

function GM:OnBuyDayCardCallBack6()
	AssistClient.bFakeMidasServer = true;
	Recharge:OnBuyOneDayCardCallBack(me, GetTime() + 3600 * 24, 3);
end

function GM:GetItem()
	me.CallClientScript("Client:GetItem");
end

function GM:PreciseCastSwitch()
	me.CallClientScript("Operation:SetPreciseSkillOp");
end

function GM:EnterTombRequest()
	me.CallClientScript("ImperialTomb:EnterTombRequest");
end

function GM:EnterNormalFloor2()
	local ret, msg = ImperialTomb:CheckEnterTomb(me, ImperialTomb.bOpenEmperor);
	if not ret then
		me.CenterMsg(msg);
		return
	end
	ImperialTomb:EnterNormalFloor(2);
end

function GM:EnterNormalFloor3()
	local ret, msg = ImperialTomb:CheckEnterTomb(me, ImperialTomb.bOpenEmperor);
	if not ret then
		me.CenterMsg(msg);
		return
	end
	ImperialTomb:EnterNormalFloor(3);
end

function GM:ImperialTombSecretRoom()
	if not ImperialTomb:IsNormalMapByTemplate(me.nMapTemplateId) then
		return
	end

	local nMapType = ImperialTomb:GetMapType(me.nMapTemplateId);
	ImperialTomb:SendSecretInvite(nMapType, me, "");
end

function GM:ImperialTombSpawnSecret()
	ImperialTomb:OnSpawnSecret();
end

function GM:OpenEmperor()
	ImperialTomb:OpenEmperor();
end
function GM:OpenEmperor1()
	ImperialTomb:OpenEmperor(true);
end

function GM:EnterEmperorRoom()
	ImperialTomb:EnterEmperorRoom(1);
end

function GM:CallBoss()
	ImperialTomb:CallBoss();
end

function GM:CallEmperor()
	ImperialTomb:CallEmperor();
end

function GM:CloseEmperor()
	ImperialTomb:CloseEmperor();
end

function GM:ImperialTombCallLeader()
	local nMapId, nX, nY = me.GetWorldPos();
	KNpc.Add(1871, 60, 0, nMapId, nX, nY, 0);
end

function GM:ImperialTombAddTime()
	ImperialTomb:AddStayTime(me, 30*60);
end

function GM:ImperialTombClearTime()
	ImperialTomb:ReduceStayTime(me, 10000000);
end


function GM:StartEnterHuaShanLunJian()
	HuaShanLunJian.tbDef.tbPrepareGame.nStartMonthDay = 1;
	HuaShanLunJian.tbDef.tbPrepareGame.nEndMothDay = Lib:GetMonthDay() + 1;
	HuaShanLunJian:StartPrepareGame();
end

function GM:EnterHuaShanLunJian()
	HuaShanLunJian.tbDef.tbPrepareGame.nEndMothDay = Lib:GetMonthDay();
	HuaShanLunJian:EnterPrepareGame(me);
end

function GM:JoinFightTeamHuaShanLunJian()
	HuaShanLunJian.tbDef.tbPrepareGame.nEndMothDay = Lib:GetMonthDay();
	HuaShanLunJian:PlayerJoinFightTeam(me.dwID);
end

function GM:CloseEnterHuaShanLunJian()
	HuaShanLunJian.tbDef.tbPrepareGame.nEndMothDay = Lib:GetMonthDay();
	HuaShanLunJian:CloseEnterPreGame();
end

function GM:StartFinalsHuaShanLunJian()
	local tbDef = HuaShanLunJian.tbDef;
		tbDef.tbFinalsGame.nMonthDay = Lib:GetMonthDay();
	local tbSaveData = HuaShanLunJian:GetLunJianSaveData();
		tbSaveData.nPlayState = tbDef.nPlayStatePrepare;
		tbSaveData.bEndAward = false;
		tbSaveData.nChampionId = 0;
		tbSaveData.tbFinalsFightTeam = {};
	HuaShanLunJian:StartFinalsPlayGame();
end

function GM:PlayerEnterHuaShanLunJian()
	local tbDef = HuaShanLunJian.tbDef;
		tbDef.tbFinalsGame.nMonthDay = Lib:GetMonthDay();
	local tbSaveData = HuaShanLunJian:GetLunJianSaveData();
		tbSaveData.nPlayState = tbDef.nPlayStatePrepare;
	HuaShanLunJian:PlayerEnterFinalsMap(me);
end

function GM:InformFinalsFightTeamListHuaShanLunJian()
	local tbDef = HuaShanLunJian.tbDef;
		tbDef.tbFinalsGame.nMonthDay = Lib:GetMonthDay();
	local tbSaveData = HuaShanLunJian:GetLunJianSaveData();
		tbSaveData.nPlayState = tbDef.nPlayStatePrepare;
	HuaShanLunJian:InformFinalsFightTeamList();
end

function GM:OnBuyInvestCallBack1()
	AssistClient.bFakeMidasServer = true;
	Recharge:OnBuyInvestCallBack(me, 1);
end

function GM:OnBuyInvestCallBack2()
	AssistClient.bFakeMidasServer = true;
	Recharge:OnBuyInvestCallBack(me, 2);
end

function GM:OnTotalRechargeChange6RMB()
	AssistClient.bFakeMidasServer = true;
	local nOldGoldRMB = Recharge:GetTotoalRechargeGold(me);
	local nOldCardRMB = me.GetUserValue(Recharge.SAVE_GROUP, Recharge.KEY_TOTAL_CARD);
	Recharge:OnTotalRechargeChange(me, nOldGoldRMB + 600, nOldCardRMB + 0);
end

function GM:OnTotalRechargeChange30RMB()
	AssistClient.bFakeMidasServer = true;
	local nOldGoldRMB = Recharge:GetTotoalRechargeGold(me);
	local nOldCardRMB = me.GetUserValue(Recharge.SAVE_GROUP, Recharge.KEY_TOTAL_CARD);
	Recharge:OnTotalRechargeChange(me, nOldGoldRMB + 3000, nOldCardRMB + 0);
end

function GM:OnTotalRechargeChange98RMB()
	AssistClient.bFakeMidasServer = true;
	local nOldGoldRMB = Recharge:GetTotoalRechargeGold(me);
	local nOldCardRMB = me.GetUserValue(Recharge.SAVE_GROUP, Recharge.KEY_TOTAL_CARD);
	Recharge:OnTotalRechargeChange(me, nOldGoldRMB + 9800, nOldCardRMB + 0);
end

function GM:OnTotalRechargeChange198RMB()
	AssistClient.bFakeMidasServer = true;
	local nOldGoldRMB = Recharge:GetTotoalRechargeGold(me);
	local nOldCardRMB = me.GetUserValue(Recharge.SAVE_GROUP, Recharge.KEY_TOTAL_CARD);
	Recharge:OnTotalRechargeChange(me, nOldGoldRMB + 19800, nOldCardRMB + 0);
end

function GM:OnTotalRechargeChange328RMB()
	AssistClient.bFakeMidasServer = true;
	local nOldGoldRMB = Recharge:GetTotoalRechargeGold(me);
	local nOldCardRMB = me.GetUserValue(Recharge.SAVE_GROUP, Recharge.KEY_TOTAL_CARD);
	Recharge:OnTotalRechargeChange(me, nOldGoldRMB + 32800, nOldCardRMB + 0);
end

function GM:OnTotalRechargeChange648RMB()
	AssistClient.bFakeMidasServer = true;
	local nOldGoldRMB = Recharge:GetTotoalRechargeGold(me);
	local nOldCardRMB = me.GetUserValue(Recharge.SAVE_GROUP, Recharge.KEY_TOTAL_CARD);
	Recharge:OnTotalRechargeChange(me, nOldGoldRMB + 64800, nOldCardRMB + 0);
end

function GM:CheckFixCmd()
	Server:CheckFixCmd();
end

function GM:AddKinFound()
	local kinData = Kin:GetKinById(me.dwKinId);
	kinData:AddFound(me.dwID, 999999);
end

function GM:Go2TeamFuben(nSectionIdx,nSubSectionIdx)
	local pPlayer = KPlayer.GetPlayerObjById(me.dwID);
	if not pPlayer then
		return;
	end
	local tbMember = TeamMgr:GetMembers(pPlayer.dwTeamID);
	local function fnAllMember(tbMember, fnSc, ...)
		for _, nPlayerId in pairs(tbMember or {}) do
			local pMember = KPlayer.GetPlayerObjById(nPlayerId);
			if pMember then
				fnSc(pMember, ...);
			end
		end
	end
	local function fnMsg(pPlayer, szMsg)
		pPlayer.CenterMsg(szMsg);
	end
	local function fnSuccessCallback(nMapId)
		local function fnSucess(pPlayer, nMapId)
			pPlayer.SetEntryPoint();
			pPlayer.SwitchMap(nMapId, 0, 0);
		end
		if pPlayer.dwTeamID > 0 then
			fnAllMember(tbMember, fnSucess, nMapId);
		else
			fnSucess(pPlayer,nMapId);
		end
	end
	local function fnFailedCallback()
		if pPlayer.dwTeamID > 0 then
			fnAllMember(tbMember, fnMsg, "創建副本失敗，請稍後嘗試！");
		else
			pPlayer.CenterMsg("創建副本失敗，請稍後嘗試！");
		end
	end
	local tbSetting = TeamFuben:GetFubenSetting(nSectionIdx, nSubSectionIdx);
	Fuben:ApplyFuben(pPlayer.dwID, tbSetting.nMapTemplateId, fnSuccessCallback, fnFailedCallback, nSectionIdx, nSubSectionIdx, {});
end

function GM:Go2RandomFuben(nMapId)
	if nMapId then
		Fuben.RandomFuben.GetRoom = function ( ... )
		  return nMapId;
		end
		Fuben.RandomFuben.CheckCanCreateFuben = function (self, pPlayer)
			local tbMember = TeamMgr:GetMembers(pPlayer.dwTeamID);
			if not tbMember or #tbMember <= 0 then
			   tbMember = { pPlayer.dwID };
			end
			 return true, "", tbMember;
		end
	end
	Fuben.RandomFuben:CreateFuben(me.dwID, 1, true);
end

function GM:GetValueDomainBattle()
	local tbData = ScriptData:GetValue("DomainBattle");
	me.Msg("第"..tbData.nBattleVersion.." 屆攻城戰");
end

function GM:GetServerOpenDay()
	me.Msg("當前開服天數：第"..Lib:GetServerOpenDay().."天");
end

function GM:ServerCreateTime()
	local dwServerCreateTime = ScriptData:GetValue("dwServerCreateTime");
	me.Msg("伺服器開服時間： \n"..Lib:GetTimeStr4(dwServerCreateTime));
end

function GM:GetMapPlayerPower()
	local tbPlayer = KPlayer.GetMapPlayer(me.nMapId);
	for _, pPlayer in pairs(tbPlayer) do
		me.Msg("玩家："..pPlayer.szName .." 戰力：" .. pPlayer.GetFightPower());
	end
end

function GM:StopBattleSignUp()
	Battle:StopBattleSignUp();
end

function GM:AddDegreeBattle()
	DegreeCtrl:AddDegree(me, "Battle", 10);
end

function GM:ChatMgrSetFilterText()
	ChatMgr:SetFilterText({});
end

function GM:GameWinFubenInstance()
	local tbInst = Fuben.tbFubenInstance[me.nMapId];
	if not tbInst then
		me.CenterMsg("沒在副本中？？");
	end
	tbInst:GameWin();
end

function GM:DirectGotoDungeonCrystal()
	local FubenMgr = Fuben.DungeonFubenMgr;
	local tbInst = Fuben.tbFubenInstance[me.nMapId];
		tbInst.nNextKind = FubenMgr.Kind_Silver;
	local nMaxLevel = me.nLevel;
	local nNextLevel = 0;
	for i,v in ipairs(FubenMgr.tbScendLevelSetting) do
		nNextLevel = i;
		if nMaxLevel <= v.nLevelEnd then
			break;
		end
	end
	tbInst.nNextLevel = nNextLevel;
	tbInst:OnGotoNext();
end

function GM:DirectGotoDungeonBoss()
	local FubenMgr = Fuben.DungeonFubenMgr;
	local tbInst = Fuben.tbFubenInstance[me.nMapId];
		tbInst.nNextKind = FubenMgr.Kind_Boss;
	local nMaxLevel = me.nLevel;
	local nNextLevel = 0;
	for i,v in ipairs(FubenMgr.tbScendLevelSetting) do
		nNextLevel = i;
		if nMaxLevel <= v.nLevelEnd then
			break;
		end
	end
	tbInst.nNextLevel = nNextLevel;
	tbInst:OnGotoNext();
end

function GM:RemoveUesrValue()
	me.SetUserValue(104, 2, 1);
end

function GM:GotoEntryPoint()
	me.GotoEntryPoint();
end

function GM:Cometome()
	local tbPlayer = KPlayer.GetAllPlayer();
	local nMap, nX, nY = me.GetWorldPos();
	for _, pPlayer in pairs(tbPlayer) do
		if pPlayer.dwID ~= me.dwID then
			pPlayer.SwitchMap(nMap, nX, nY);
		end
	end
end

function GM:CometomeDomain()
	local tbPlayer = KPlayer.GetAllPlayer();
	local nMap, nX, nY = me.GetWorldPos();
	for _, pPlayer in pairs(tbPlayer) do
		if pPlayer.dwID ~= me.dwID then
			DomainBattle:PlayerSignUp(pPlayer)
		end
	end
end

function GM:RemoveUesrValueRandomFuben()
	me.SetUserValue(9, 1, 0);
end

function GM:OnlinePlayerCount()
	me.Msg("當前線上人數："..GetOnlinePlayerCount());
end

function GM:CreatePartnerByPos()
	me.CreatePartnerByPos(1);
end

function GM:ChuangGongUserValue()
	me.SetUserValue(ChuangGong.SAVE_GROUP, ChuangGong.KEY_SEND_TIME, 0);
end

function GM:AddDegreeChuangGong()
	DegreeCtrl:AddDegree(me, "ChuangGong", 10);
end

function GM:AddDegreeChuangGongSend()
	DegreeCtrl:AddDegree(me, "ChuangGongSend", 10);
end

function GM:KinGetAllPlayer()
	local tbPlayer = KPlayer.GetAllPlayer();
	local nKinId = me.dwKinId;
	for _, pPlayer in pairs(tbPlayer) do
		local oldMe = me;
			me = pPlayer;
			Kin:Apply(nKinId, true);
			me = oldMe;
	end
end

function GM:GetMapPlayer()
	local _,nCount = KPlayer.GetMapPlayer(me.nMapId);
	me.Msg("當前地圖人數："..nCount);
end

function GM:AddOnwenrDomainBattle()
	DomainBattle:AddOnwenrAcutionAward();
end

function GM:ShowCodeGift()
	local tbOptList =
	{
		[1] =
		{
			Text = "正序",
			Callback = GM.ShowCodeGiftDeatail,
		},
		[2] =
		{
			Text = "降冪",
			Callback = GM.ShowCodeGiftDeatail,
			Param = {GM,true},
		},
	}
	Dialog:Show(
	{Text = "選一種排序吧！！！",OptList = tbOptList}, me);

end

function GM:ShowCodeGiftDeatail(bDsc)

	local fnCallback = function (szType)
		CodeAward:SendXGCodeGift(me.dwID, szType);
	end
	local tbOptList = {}
	local nCount = #tbCodeGiftSetting
	for nIndex,tbInfo in ipairs(tbCodeGiftSetting) do
		local szName = tbInfo.Name;
		local szType = tbInfo.Type;
		local nIdx = bDsc and (nCount - nIndex + 1) or nIndex
		tbOptList[nIdx] = {};
		tbOptList[nIdx].Text = szType .. "(" .. szName ..")";
		tbOptList[nIdx].Callback = fnCallback;
		tbOptList[nIdx].Param = {szType};
	end
	Dialog:Show(
	{Text = "來，來一隻禮包馬！！！",OptList = tbOptList}, me);
end

function GM:KinId()
	me.Msg("本幫派的幫派ID是："..me.dwKinId);
end

function GM:BeginNewSession()
	CollectionSystem:BeginNewSession(1);
	CollectionSystem:SyncStateToAllPlayer();
end

-- 默认item类名配置
GM.tbItemClass = {
	["RandomFubenCard"] = 1,
}
-- 增加ScriptItem表中的某一类的item
function GM:AddItemByClass(szClass,nCount)
	for _,tbInfo in pairs(tbScriptItemSetting) do
		if tbInfo.ClassName == szClass then
			me.AddItem(tbInfo.TemplateId,nCount);
		end
	end
end

function GM:AddDefaultItem()
	for _,tbInfo in pairs(tbScriptItemSetting) do
		local nCount = self.tbItemClass[tbInfo.ClassName];
		if nCount then
			me.AddItem(tbInfo.TemplateId,nCount);
		end
	end
end

function GM:BeginNewSessionItem()
	GM:AddDefaultItem();
end

function GM:KinIsNameValid()
	AssistClient.bFakeMidasServer = true;
	local tbPlayer = KPlayer.GetAllPlayer();
	for _, pPlayer in pairs(tbPlayer) do
		pPlayer.AddMoney("Gold", 99999, Env.LogWay_ActivyRechargeCard);
	end
	Kin.Old_IsNameValid = Kin.Old_IsNameValid or Kin.IsNameValid;
	Kin.IsNameValid = function() return true end
	local tbPlayer = KPlayer.GetAllPlayer();
	local i = 0;
	for _, pPlayer in pairs(tbPlayer) do
		i = i+1;
		local oldMe = me;
		me = pPlayer;
		local bOk, szErr = Kin:Create("幫派"..i, "", Npc.CampTypeDef.camp_type_song);
		if not bOk then
			oldMe.Msg(string.format("%s(%d)創建幫派失敗：%s", pPlayer.szName, pPlayer.dwID, tostring(szErr)));
		end
		me = oldMe;
	end
	Kin.IsNameValid = Kin.Old_IsNameValid;
end

function GM:StartMonsterCount()
	local tbBaseNpc = Npc:GetClass("");
	tbBaseNpc.tbKillNpcData = tbBaseNpc.tbKillNpcData or {};
	function tbBaseNpc:RecordData(pNpc, tbDamageInfo, pKiller)
	      if not pKiller then
	        Log("npc kill by no one!!!")
	        return
	    end
	    local pFirstPlayer = nil;
	    if pKiller then
	        pFirstPlayer = pKiller.GetPlayer();
	    end

	    local nMainAttackID = nil;
	     if pFirstPlayer then
	        nMainAttackID = pFirstPlayer.dwID;
	    end

	    local tbDamage = tbDamageInfo[1];
	    if tbDamage and nMainAttackID then
	        local tbPlayer, pCaptain, nTotalLevel, bMainAttack = Npc:GetAssignPlayer(pNpc, tbDamage, Npc.nMaxAwardLen, nMainAttackID);
	        pFirstPlayer = pCaptain;
	    end

	    if pFirstPlayer then
	        tbBaseNpc.tbKillNpcData[pFirstPlayer.dwTeamID] = tbBaseNpc.tbKillNpcData[pFirstPlayer.dwTeamID] or {};
	        tbBaseNpc.tbKillNpcData[pFirstPlayer.dwTeamID][pNpc.nTemplateId] = tbBaseNpc.tbKillNpcData[pFirstPlayer.dwTeamID][pNpc.nTemplateId] or 0;
	        tbBaseNpc.tbKillNpcData[pFirstPlayer.dwTeamID][pNpc.nTemplateId] = tbBaseNpc.tbKillNpcData[pFirstPlayer.dwTeamID][pNpc.nTemplateId] + 1;
	    end
	end

	function Npc:CalcNpcDeath(pNpc, pKiller)
	    local tbDamageInfo = pNpc.GetDamageInfo();
	    if not tbDamageInfo or #tbDamageInfo <= 0 then
	        return;
	    end

	    local function fnDamageCmp(a, b)
	        return a.nTotalDamage > b.nTotalDamage;
	    end

	    table.sort(tbDamageInfo, fnDamageCmp);

	    local szClassName = pNpc.szClass;
	    local tbNpcTInfo = KNpc.GetNpcTemplateInfo(pNpc.nTemplateId);
	    if not Lib:IsEmptyStr(tbNpcTInfo.szDropFile) then
	        Npc:DropAward(pNpc, tbDamageInfo, tbNpcTInfo.nTreasure, tbNpcTInfo.szDropFile, tbNpcTInfo.nDropType);
	    end

	    local tbClassNpc = nil;
	    if not Lib:IsEmptyStr(szClassName) then
	        tbClassNpc = Npc:GetClass(szClassName);
	    end

	    if tbClassNpc and tbClassNpc.DeathCalcAward then
	        tbClassNpc:DeathCalcAward(pNpc, tbDamageInfo, pKiller);
	    end

	    if tbClassNpc and tbClassNpc.RecordData then
	        tbClassNpc:RecordData(pNpc, tbDamageInfo, pKiller);
	    end

	    local pMainNpc = nil;
	    local tbFirstDmg = tbDamageInfo[1];
	    if tbFirstDmg and tbFirstDmg.nLastDmgNpcID then
	        pMainNpc = KNpc.GetById(tbFirstDmg.nLastDmgNpcID);
	    end

	    return pMainNpc;
	end

	Npc.OnDeath_Old = Npc.OnDeath_Old or Npc.OnDeath;
	Npc.tbClcInfo = Npc.tbClcInfo or {};
	function Npc:OnDeath(szClassName, szParam, pKiller)
	    self:OnDeath_Old(szClassName, szParam, pKiller);
	    if not pKiller then
	    	return
	    end
	    local pPlayer = pKiller.GetPlayer();
	    if pPlayer then
	        Npc.tbClcInfo[pPlayer.dwTeamID] = Npc.tbClcInfo[pPlayer.dwTeamID] or {};
	        Npc.tbClcInfo[pPlayer.dwTeamID][pPlayer.dwID] = Npc.tbClcInfo[pPlayer.dwTeamID][pPlayer.dwID] or {};
	        Npc.tbClcInfo[pPlayer.dwTeamID][pPlayer.dwID][him.nTemplateId] = Npc.tbClcInfo[pPlayer.dwTeamID][pPlayer.dwID][him.nTemplateId] or 0;
	        Npc.tbClcInfo[pPlayer.dwTeamID][pPlayer.dwID][him.nTemplateId] = Npc.tbClcInfo[pPlayer.dwTeamID][pPlayer.dwID][him.nTemplateId] + 1;
	        Log("[OnNpcDeath]", pPlayer.dwTeamID, pPlayer.dwID, him.nTemplateId, Npc.tbClcInfo[pPlayer.dwTeamID][pPlayer.dwID][him.nTemplateId]);
	    end
	end
end

function GM:ShowMonsterCount()
	local tbBaseNpc = Npc:GetClass("");
	Lib:LogTB(tbBaseNpc.tbKillNpcData);
	Lib:LogTB(Npc.tbClcInfo);
end

function GM:ClearExp()
	me.ReduceExp(me.GetExp(),1);
end

function GM:TryAutoFight()
	local szCmd = [[
		local function fnAutoFight(szInput)
			local nStartTime = 10
			local nEndTime = tonumber(szInput)
			if not nEndTime then
				Log("Valid Param !!!")
				return
			end
			Timer:Register(Env.GAME_FPS* nStartTime, function ()
                Log("→→→Automatic start fighting←←←",os.date("%Y-%m-%d %H:%M:%S"));
			    AutoFight:ChangeState(AutoFight.OperationType.Auto);
			end)
			Timer:Register(Env.GAME_FPS* (nStartTime + nEndTime) , function ()
                Log("→→→Automatic stop fighting←←←",os.date("%Y-%m-%d %H:%M:%S"));
			    AutoFight:ChangeState(AutoFight.OperationType.Manual);
			end)
		end
        Ui:OpenWindow("InputBox", "輸入結束時間（秒數）", fnAutoFight)
	]]
	me.CallClientScript("Client:DoCommand", szCmd);
end

function GM:GetHouse()
	if not House:GetHouse(me.dwID) then
		House:Create(me, 1);
	end
	House:GoMyHome(me);
end

function GM:LevelupHouse()
	House:DoLevelUp(me, 1);
end

function GM:TargetAddCount()
	for i=1,100 do
		TeacherStudent:_TargetAddCount(me, i, 1000);
	end
end

function GM:GetAllHouseMaterial()
	for i = 4296, 4325 do
		me.AddItem(i, 100);
	end
end

function GM:GetAllHouseFurniture()
	for i = 4058, 4251 do
		local tbBaseInfo = KItem.GetItemBaseProp(i);
		if tbBaseInfo and tbBaseInfo.szClass == "FurnitureItem" then
			Furniture:Add(me, i);
		end
	end
end

function GM:TryJoinPreMapTeamBattle()
	local tbPlayer = KPlayer.GetAllPlayer();
	for _, pPlayer in pairs(tbPlayer) do
		TeamBattle:TryJoinPreMap(pPlayer, true);
	end
end

function GM:TeamBattleUserValue()
	me.SetUserValue(TeamBattle.SAVE_GROUP, TeamBattle.SAVE_DATE, 0);
end

function GM:TeamBattlePlayerUserValue()
	local tbAllPlayer = KPlayer.GetAllPlayer();
	for _, pPlayer in pairs(tbAllPlayer) do
		pPlayer.SetUserValue(45, 1, 0);
		pPlayer.SetUserValue(45, 2, 0);
		pPlayer.SetUserValue(45, 4, 0);
		pPlayer.SetUserValue(45, 5, 0);
	end
end

function GM:TeamBatlePlayerSetUserValue()
	local tbAllPlayer = KPlayer.GetAllPlayer();
	for _, pPlayer in pairs(tbAllPlayer) do
		for i = 6, 14 do
			pPlayer.SetUserValue(45, i, 0);
		end
	end
end

function GM:TeamBattleHONOR()
	me.Msg("通天塔剩餘榮譽：" .. me.GetUserValue(TeamBattle.SAVE_GROUP, TeamBattle.SAVE_HONOR));
end

function GM:InDifferBattleStart()
	CallZoneServerScript("InDifferBattle:OpenSignUp");
end

function GM:KinTrainMgrStart()
	local KinTrainMgr = Fuben.KinTrainMgr;
	KinTrainMgr.OPEN_MEMBER_NUM = 1;
	KinTrainMgr.PREPARE_TIME = 60*1;
	KinTrainMgr:Start();
end

function GM:EndFinishBoss()
	Boss:NotifyFinishBoss();
end

function GM:StartFactionMonkey()
	FactionBattle.FactionMonkey:StartFactionMonkey(true);
end

function GM:EndFactionMonkey()
	FactionBattle.FactionMonkey:EndFactionMonkey(true);
end

function GM:GoZoneserver()
	me.SwitchZoneMap(11, 11569, 8907);
end

function GM:Kinteam()
	local kinData = Kin:GetKinById(me.dwKinId);
	local nTargetPlayerID = me.dwID;
	kinData:TraverseMembers(function (memberData)
		local nMemberId = memberData.nMemberId;
		local pMember = KPlayer.GetPlayerObjById(nMemberId);
		if pMember then
			GameSetting:SetGlobalObj(pMember);
			TeamMgr:Apply(nTargetPlayerID);
			GameSetting:RestoreGlobalObj();
		end
			return true;
		end);
end

function GM:InDifferBattleDegree()
	DegreeCtrl:AddDegree(me, "InDifferBattle", 10);
end

function GM:AddInDifferBattleItem()
	me.AddItem(3494, 1);
end

function GM:BossFightCd()
	Boss.Def.nBossFightCd = 0;
	Boss.Def.nRobCd = 0;
end

function GM:ChatHostInfo()
	ChatMgr:ReloadChatHostInfo();
end

function GM:ChangeZoneConnect()
	ChangeZoneConnect(1);
end

function GM:GetHostAuth()
	ChatMgr:SetCrossHostAuth(me, 1);
end

function GM:CancelHostAuth()
	ChatMgr:SetCrossHostAuth(me, 0);
end

function GM:ReportQQData()
	me.CallClientScript("Client:ReportQQGM");
end

function GM:HonorLingYun()
	me.AddItem(1393, 2);
end

function GM:HonorYuKong()
	me.AddItem(1393, 4);
end

function GM:HonorQianLong()
	me.AddItem(1394, 4);
end

function GM:HonorAoShi()
	me.AddItem(1394, 8);
end

function GM:HonorYiTian()
	me.AddItem(1395, 8);
end

function GM:HonorZhiZun()
	me.AddItem(1395, 16);
end

function GM:HonorWuShen()
	me.AddItem(1396, 12);
end

function GM:HonorWuShuang()
	me.AddItem(1396, 24);
end

function GM:OutPutAllTimeFrameInfo()
	TimeFrame:OutputInfo();
end

function GM:QueryTimeFrameIsOpen()
	local fnCallback = function (szFrame)
		me.Msg(string.format("%s時間軸開啟狀態：\n", szFrame)..(TimeFrame:GetTimeFrameState(szFrame) == 1 and "true" or "false"));
	end
	local tbOptList = self:GetTimeFrameOptList(fnCallback);
	Dialog:Show(
	{Text = "老闆，本店技師任您挑選！",OptList = tbOptList}, me);
end

function GM:QueryTimeFrameOpenTime(fnCallback)
	local fnCallback = function (szFrame)
		me.Msg(string.format("查詢的時間軸%s開啟時間是：\n", szFrame)..  Lib:GetTimeStr4(TimeFrame:CalcTimeFrameOpenTime(szFrame)));
	end
	local tbOptList = self:GetTimeFrameOptList(fnCallback);
	Dialog:Show(
	{Text = "老闆，很高興77號技師為您服務！",OptList = tbOptList}, me);
end

function GM:GetTimeFrameOptList(fnCallback)
	local tbOptList = {}
	for szFrame in pairs(TimeFrame.tbAllTimeFrame) do
		table.insert(tbOptList, {
			Text = szFrame;
			Callback = fnCallback;
			Param = {szFrame};
			nTimeStame = TimeFrame:CalcTimeFrameOpenTime(szFrame);
			})
	end
	table.sort(tbOptList, function (a, b) return a.nTimeStame < b.nTimeStame end );
	return tbOptList
end

function GM:EverydayTarget()
	for szKey, _ in pairs(EverydayTarget.tbEverydaySetting) do
		EverydayTarget:AddCount(me, szKey, 1);
	end
end

function GM:KinLastJudge()
	local tbKinData = Kin:GetKinById(me.dwKinId);
	if tbKinData.szLastJudge == nil then
		me.Msg("幫派狀態：活躍");
	else
		me.Msg("幫派狀態："..tbKinData.szLastJudge);
	end
end

function GM:KinAuction()
	Kin:AddAuction(me.dwKinId, "Boss", {[me.dwID] = true}, {{2529,1},{2534,1},{4816,1},{4817,1},{2794,1},{2795,1},{2800,1},{2797,1},{3179,1},{4288,1},{1395,1},{3461,1},{2396,1},{2804,1}});
end

function GM:StartAuctionDealer()
	Kin.AuctionDef.nDealerAutionOpenCount = 100000;
	Kin:StartAuctionDealer();
end

function GM:StartZBoss()
	Timer:Register(Env.GAME_FPS*Boss.ZDef.nPreStartTime, function ()
			Boss:StartBossFight();
	end)

	CallZoneServerScript("Boss:ZSPreStart");
end

function GM:EndZBoss()
	Boss:NotifyFinishBoss();
	CallZoneServerScript("Boss:ZSPreFinish");
end

function GM:AddKinScoreToZBoss()
	if Boss:ZCIsCrossOpen() then
		me.CenterMsg("跨服盟主開啟中，無法修改");
		return;
	end

	if not Boss:ZCTimeFramOpen() then
		me.CenterMsg("跨服盟主時間軸未到")
		return;
	end

	Kin:TraverseKin(function (kinData)
		Boss:ZCRecordKinScore4ZFight(kinData.nKinId, MathRandom(1, 10))
	end)

	if me.dwKinId ~= 0 then
		local tbRankScore = Boss:ZCGetSaveData("RankScore4Cross");
		tbRankScore[me.dwKinId] = 99999;
	end
end

function GM:AddProposeItem()
	me.AddItem(6155, 1);
end

function GM:ForceTeamAddFriend()
	local tbMember = TeamMgr:GetMembers(me.dwTeamID)
	local nCount =  #tbMember
	if nCount < 2 then
		me.CenterMsg("沒有找到隊友", true)
		return
	end
	for i = 1, nCount - 1 do
		local nPlayerId1 = tbMember[i]
		local pPlayer1 = KPlayer.GetPlayerObjById(nPlayerId1)
		for j = i + 1, nCount  do
	 		local nPlayerId2 = tbMember[j]
	 		local pPlayer2 = KPlayer.GetPlayerObjById(nPlayerId2)
	 		if pPlayer1 and pPlayer2 then
	 			FriendShip:ForceAddFriend(pPlayer1, pPlayer2)
	 		end
	 	end
	end
end

function GM:ForceTeamSetImitity(nImitity)
	if not nImitity then
		me.CallClientScript("Client:GMGetImitity");
		return
	end
	local tbMember = TeamMgr:GetMembers(me.dwTeamID)
	local nCount =  #tbMember
	if nCount < 2 then
		me.CenterMsg("沒有找到隊友", true)
		return
	end
	for i = 1, nCount - 1 do
		local nPlayerId1 = tbMember[i]
		for j = i + 1, nCount  do
	 		local nPlayerId2 = tbMember[j]
	 		KFriendShip.SetFriendShipVal(nPlayerId1, nPlayerId2, FriendShip.tbDataType.emFriendData_Imity, nImitity)
	 	end
	end
	me.CenterMsg("上車成功", true)
end

function GM:LogScheduleData()
	Wedding:LogScheduleData();
end

function GM:TryStartBookWedding()
	Wedding:TryStartBookWedding(me);
end

function GM:MakeMarry(nPlayerId)
	if not nPlayerId then
		me.CallClientScript("Client:GMGetLoverId");
		return
	end
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId)
	if not pPlayer then
		me.CenterMsg("對方未在線", true)
		return 
	end
	me.SetUserValue(Wedding.nSaveGrp, Wedding.nSaveKeyGender, 1);
	pPlayer.SetUserValue(Wedding.nSaveGrp, Wedding.nSaveKeyGender, 2);
	KFriendShip.SetFriendShipVal(me.dwID, nPlayerId, FriendShip:WeddingStateType(), Wedding.State_Marry);
	KFriendShip.SetFriendShipVal(me.dwID, nPlayerId, FriendShip:WeddingTimeType(), GetTime());
	me.CenterMsg("上車成功", true)
end

function GM:Divorce()
	local function dismiss()
		local pPlayer = me;
		local nPlayerId = me.dwID;
		local nOtherId, nWeddingTime = Wedding:GetLover(nPlayerId);
		if not nOtherId then 		
			return false, "沒有結婚";
		end 	
		local pOther = KPlayer.GetPlayerObjById(nOtherId) ;
		if not pOther then 		
			return false, "對方未在線";
		end 	
		Wedding:_DoDismissCommon(nPlayerId, nOtherId);
		Wedding:_DoDismiss(pPlayer, nOtherId);
		Wedding:_DoDismiss(pOther, nPlayerId);
		return true;
	end 
	local bOk, szErr = dismiss();
	if not bOk then 
		me.CenterMsg(szErr, 1);
	end
end

function GM:ForceSaveData()
	ScriptData:Save();
end

function GM:StartCityTour(nPlayerId)
	if not nPlayerId then
		me.CallClientScript("Client:GMGetLoverId", "GM:StartCityTour(%d)");
		return
	end
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId)
	if not pPlayer then
		me.CenterMsg("對方未在線", true)
		return 
	end
	local tbSchedule = Wedding:GetSaveData("WWeddingSchedule")
	tbSchedule.nTourTime = GetTime()
	tbSchedule.tbTourPlayer = {me.dwID, nPlayerId}
	Wedding:StartWeddingTour(me, pPlayer, 3)
end

function GM:StartWeddingPlay(szKey)
	local szFunc = "On" .. szKey
	local tbInst = Fuben.tbFubenInstance[me.nMapId]
	if tbInst and tbInst[szFunc] then
		tbInst[szFunc](tbInst)
	else
		me.CenterMsg("請前往婚禮現場開啟")
	end
end

function GM:WeedingWelcomeCount()
	local tbInst = Fuben.tbFubenInstance[me.nMapId];
	if tbInst then 	
		tbInst.tbWelcomeCount = tbInst.tbWelcomeCount or {};
		tbInst.tbWelcomeCount[me.dwID] = 256;
	end 
end

function GM:WeddingItem1()
	me.AddItem(6231, 2);
	me.AddItem(2180, 1);
	me.AddItem(2181, 1);
end

function GM:WeddingItem2()
	me.AddItem(6231, 19);
	me.AddItem(2180, 9);
	me.AddItem(2181, 9);
end

function GM:WeddingItem3()
	me.AddItem(6231, 99);
	me.AddItem(2180, 19);
	me.AddItem(2181, 19);
end