if MODULE_ZONESERVER then
	return
end

RankActivity.LevelRankActivity = RankActivity.LevelRankActivity or {}
local LevelRankActivity = RankActivity.LevelRankActivity

RankActivity.nBindingPhoneGuideLevel = 16

function RankActivity:OnServerStart()
	local tbData = LevelRankActivity:GetData()
	if not tbData.bIsSend then
		NewInformation:AddInfomation("LevelRankActivity",GetTime() + RankActivity.OPEN_SERVER_RANK_LEVEL_INVALID_TIME,{})
		NewInformation:AddInfomation("PowerRankActivity",GetTime() + RankActivity.OPEN_SERVER_RANK_POWER_INVALID_TIME,{})
		tbData.bIsSend = true
	end
end

function RankActivity:SendGuideMail(nNewLevel)
	if me.nLevel > self.nBindingPhoneGuideLevel then
		return 
	end

	local tbMsdkInfo = me.GetMsdkInfo();
	if tbMsdkInfo.nOsType == Sdk.eOSType_iOS and Server:IsCloseIOSEntry() then
		return 
	end

	if not Sdk:IsMsdk() or not Sdk:IsEfunHKTW() then
		return;
	end

	if me.nLevel == self.nBindingPhoneGuideLevel then
		local tbMail = {
			To = me.dwID;
			Title = "綁定手機提醒";
			From = "系統";
			Text = "    尊敬的俠士，現在綁定手機不但能夠讓帳號更安全，還將獲得元寶*200、黃金鑰匙*5、白水晶*10的獎勵哦！\n                                      [FFFF0E][url=openwnd:馬上去綁定手機, RoleInformationPanel,1][-]";
		};

		Mail:SendSystemMail(tbMail);
	end
end

------------------------等级排名------------------------
function LevelRankActivity:OnPlayerLevelup(nNewLevel)
	Lib:CallBack({RankActivity.SendGuideMail, RankActivity,nNewLevel});
	local tbData = self:GetData() 
	tbData.tbLevelRankPlayer = tbData.tbLevelRankPlayer or {}

	if me.nLevel < RankActivity.LEVEL_RANK_REWARD_LEVEL or Lib:CountTB(tbData.tbLevelRankPlayer) >= RankActivity.MAX_RANK_LEVEL_COUNT then
		return
	end

	if me.nLevel == RankActivity.LEVEL_RANK_REWARD_LEVEL then

		if self:CheckIsGet(me) then
			return
		end

		local nRank = Lib:CountTB(tbData.tbLevelRankPlayer) + 1
		local tbReward = RankActivity:LevelRankReward(nRank)
		if not tbReward or not next(tbReward) then
			Log("LevelRankActivity OnPlayerLevelup can not find Reward .",me.dwID,nRank)
			return
		end

		local szTitle = "等級排名獎勵"
		local szText  = string.format("恭喜俠士在衝級活動中一馬當先率先達到%d級！這是俠士參與本次活動的獎勵！",RankActivity.LEVEL_RANK_REWARD_LEVEL)

		local tbMail = {
			To = me.dwID;
			Title = szTitle;
			From = "系統";
			Text = szText;
			tbAttach = tbReward;
			nLogReazon = Env.LogWay_LevelRankActivity;
		};

		local tbPlayerInfo = 
		{
			nPlayerID = me.dwID or 0,
		}

		table.insert(tbData.tbLevelRankPlayer,tbPlayerInfo)

		Mail:SendSystemMail(tbMail);

		if Lib:CountTB(tbData.tbLevelRankPlayer) == RankActivity.MAX_RANK_LEVEL_COUNT then
			local tbNewInfoData = self:GetTopTen(tbData.tbLevelRankPlayer)
			NewInformation:AddInfomation("LevelRankActivity",GetTime() + RankActivity.RANK_LEVEL_INVALID_TIME,tbNewInfoData)
		end
		
		Log("LevelRankActivity OnPlayerLevelup Send Mail Reward .",me.dwID,Lib:CountTB(tbData.tbLevelRankPlayer))
	end
end

function LevelRankActivity:SynData(pPlayer)
	local tbData = self:GetData()
	tbData.tbLevelRankPlayer = tbData.tbLevelRankPlayer or {}
	pPlayer.CallClientScript("RankActivity:OnSynLevelRankData", Lib:CountTB(tbData.tbLevelRankPlayer))
end

function LevelRankActivity:GetTopTen(tbPlayer)
	local tbData = {}

	for nRank = 1,RankActivity.MAX_NEW_INFO_COUNT do
		if tbPlayer[nRank] then
			local tbPlayerInfo = {}
			local nPlayerID = tbPlayer[nRank].nPlayerID
			local pPlayerStay = KPlayer.GetRoleStayInfo(nPlayerID) or {};
			local pKinData = Kin:GetKinById(pPlayerStay.dwKinId or 0) or {};

			tbPlayerInfo.nPlayerID = nPlayerID
			tbPlayerInfo.szName = pPlayerStay.szName or XT("無")
			tbPlayerInfo.nFaction = pPlayerStay.nFaction
			tbPlayerInfo.szKinName = pKinData.szName or "-"

			tbData[nRank] = tbPlayerInfo
		end
	end

	return tbData
end

function LevelRankActivity:CheckIsGet(pPlayer)
	local tbData = self:GetData()
	tbData.tbLevelRankPlayer = tbData.tbLevelRankPlayer or {}
	for _,tbPlayerInfo in pairs(tbData.tbLevelRankPlayer) do
		if tbPlayerInfo.nPlayerID == pPlayer.dwID then
			return true
		end
	end
end

function LevelRankActivity:GetData()
    return ScriptData:GetValue("RankActivity")
end


PlayerEvent:RegisterGlobal("OnLevelUp", LevelRankActivity.OnPlayerLevelup,LevelRankActivity);

----------------------------战力排名----------------------------
RankActivity.PowerRankActivity = RankActivity.PowerRankActivity or {}
local PowerRankActivity = RankActivity.PowerRankActivity

function PowerRankActivity:StartPowerRank()

	Log("PowerRankActivity StartPowerRank ===================================== ")

	local tbData = {}

	for nFaction = 1,Faction.MAX_FACTION_COUNT do
		local szKey = "FightPower_" ..nFaction
		RankBoard:Rank(szKey)
		local nMaxRewardRank = RankActivity:PowerRank(nFaction)
		if nMaxRewardRank ~= 0 then
			local tbRankList = RankBoard:GetRankBoardWithLength(szKey, nMaxRewardRank,1)
			if tbRankList then
				for nRank,tbPlayerInfo in ipairs(tbRankList) do
					local tbReward = RankActivity:PowerRankReward(nFaction,nRank)
					if tbReward and next(tbReward) then
						local szTitle = "戰力排名獎勵"
						local szText  = "恭喜俠士在戰力排名活動中佔據本門派戰力第一的寶座！這是俠士參與本次活動的獎勵！"

						local nPlayerID = tbPlayerInfo.dwUnitID or 0
						local tbMail = {

							To = nPlayerID;
							Title = szTitle;
							From = "系統";
							Text = szText;
							tbAttach = tbReward;
							nLogReazon = Env.LogWay_PowerRankActivity;

						};

						local pPlayerStay = KPlayer.GetRoleStayInfo(nPlayerID)

						if pPlayerStay then
							local tbPlayerInfo = {}
							local pKinData = Kin:GetKinById(pPlayerStay.dwKinId or 0) or {};

							tbPlayerInfo.nPlayerID = nPlayerID
							tbPlayerInfo.szName = pPlayerStay.szName or XT("無")
							tbPlayerInfo.nFaction = pPlayerStay.nFaction
							tbPlayerInfo.szKinName = pKinData.szName or "-"

							tbData[nFaction] = tbData[nFaction] or {}
							tbData[nFaction][nRank] = tbPlayerInfo

							Mail:SendSystemMail(tbMail);

							Log("PowerRankActivity StartPowerRank Send Mail Reward .",nPlayerID,nFaction,szKey,nRank,nMaxRewardRank)
						else
							Log("PowerRankActivity StartPowerRank Send Mail Reward failed,can not find tbRole.",nPlayerID,nFaction,szKey,nRank,nMaxRewardRank)
						end
					else
						Log("PowerRankActivity StartPowerRank can not find reward.",nFaction,szKey,nRank,nMaxRewardRank)
					end
				end

			else
				Log("PowerRankActivity StartPowerRank can not find rank board .",szKey,nFaction,nMaxRewardRank)
			end
		else
			Log("PowerRankActivity StartPowerRank nMaxRewardRank is 0.",szKey,nFaction)
		end	
	end

	local tbNewInfoData = {}
	for nFaction,tbInfo in pairs(tbData) do
		tbNewInfoData[nFaction] = tbInfo[1]
	end
	NewInformation:AddInfomation("PowerRankActivity",GetTime() + RankActivity.RANK_POWER_INVALID_TIME,tbNewInfoData)

	Log("PowerRankActivity EndPowerRank ===================================== ")
end