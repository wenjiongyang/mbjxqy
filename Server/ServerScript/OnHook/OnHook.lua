-- 结算离线时间的类型
OnHook.tbCalcLogType =
{
	LogType_OpenAct = 1, 				-- 上线时刚好活动开启
	LogType_Normal_Login = 2, 			-- 正常离线的登陆计算
	LogType_Online_Login = 3, 			-- 在线托管登陆计算（在线托管开启后宕机或者野外下线进入托管状态，又重新上线的情况）
	LogType_Online_Hand = 4, 			-- 在线托管手动结束计算
	LogType_Online_Force = 5, 		    -- 在线托管强制结算（参与活动或玩法，目前在切换地图做处理）
	LogType_Online_Offline = 6,			-- 在线托管下线的时候结算
}

function OnHook:OnLogin(pPlayer)
	-- 在快速切换到登陆界面的时候不会logout，进入游戏会Login，这回导致重新去计算一遍离线时间，会被刷
	-- 所以控制login只会计算一次，完成一次logout的话才会计算
	if not pPlayer.bIsCalclate then
		-- 检查上次登陆时间和最近存库时间（离线时间）是否跨天，跨天重置可挂机时间（预防跨天下线时宕机导致没重置挂机时间的情况）
		self:UpdateOnHookTime(pPlayer,self:LastSaveTime(pPlayer));
		pPlayer.SetUserValue(self.SAVE_ONHOOK_LOGIN_GROUP, self.Login_Time, GetTime());
		if self:IsOpen(pPlayer) then
			-- 理论上玩家上线的时候不会走到这一步（在线托管的时间没清掉的状态）
			-- 目前知道的只有开启在线托管之后。服务器宕机或者野外下线进入托管状态，又重新上线的情况
			if OnHook:IsOnLineOnHook(pPlayer) then
				self:EndOnLineOnHook(pPlayer,OnHook.tbCalcLogType.LogType_Online_Login)
			else
				self:UpdateExpAndOnHookTime(pPlayer);
			end

			pPlayer.bIsCalclate = true;

			self:TryStartOnLineOnHookForce(pPlayer)
		end
	end
	Log("[OnHook] now OnHookTime ",pPlayer.dwID,pPlayer.szName,self:OnHookTime(pPlayer))
end

function OnHook:OnLogout(pPlayer)
	if self:IsOpen(pPlayer) then
		self:UpdateOnHookTime(pPlayer);
		pPlayer.SetUserValue(self.SAVE_ONHOOK_GROUP, self.OffLine_Time, GetTime());						-- 存储下线时间
		if OnHook:IsOnLineOnHookForce(pPlayer) then
			self:EndOnLineOnHook(pPlayer,OnHook.tbCalcLogType.LogType_Online_Force); 					-- 结算在线托管
		elseif OnHook:IsOnLineOnHook(pPlayer) then
			self:EndOnLineOnHook(pPlayer,OnHook.tbCalcLogType.LogType_Online_Offline) 					-- 结算在线托管
		end
		pPlayer.bIsCalclate = nil;
		Log("[OnHook] start ========= ",os.date("%c",self:LastSaveTime(pPlayer)),pPlayer.dwID,pPlayer.szName,self:OnHookTime(pPlayer),OnHook:OnLineOnHookTime(pPlayer));
	end
end

-- 初始化变量
function OnHook:OnFirstLogin(pPlayer)
	pPlayer.SetUserValue(self.SAVE_ONHOOK_GROUP, self.OnHook_Time, self.OnHookTimePerDay);				-- 设置离线挂机时间
end

--默认是当前时间和上次登陆时间或在线托管时间作判断
--潜规则：在线状态下不能重置可挂机时间
function OnHook:UpdateOnHookTime(pPlayer,nTime)
	local nLastTime = nTime or GetTime()
	local nLoginTime = self:LoginTime(pPlayer)
	if nLoginTime then
		-- 开启了在线托管一律不用重置
		-- 1.是在开启在线托管的时候会先判断重置之后再开启
		-- 2.开启在线托管可相当于正常下线，走正常流程重置，跨天的情况会在计算中重置玩家的可挂机时间
		-- 3.一般玩家下线的时候会自动关掉在线托管，如果特殊情况导致没关掉也不需要重置，上线的时候会拿在线托管时间来计算离线时间，玩家也不会亏
		if nLoginTime ~= 0 and self:IsCrossDay(pPlayer,nLastTime,nLoginTime) and not OnHook:IsOnLineOnHook(pPlayer) then						-- 下线的时间点是否跨了上线时间点的天
			pPlayer.SetUserValue(self.SAVE_ONHOOK_GROUP, self.OnHook_Time, self.OnHookTimePerDay);		-- 重置可挂机时间
			Log("[OnHook] UpdateOnHookTime cross day reset onhook time ",pPlayer.dwID,pPlayer.szName,nLoginTime,nTime,OnHook:OnLineOnHookTime(pPlayer))
			return true
		end
	else
		Log("[OnHook] UpdateOnHookTime player last login time is nil !!!  ",pPlayer.dwID,pPlayer.szName);
	end
end

function OnHook:UpdateExpAndOnHookTime(pPlayer,nLogType)															-- 更新离线经验和可挂机时间

	local nOnHookLogType = OnHook.tbCalcLogType.LogType_Normal_Login

	local nLoginTime = self:LoginTime(pPlayer);
	if not nLoginTime or nLoginTime == 0 then
		Log("[OnHook] UpdateExpAndOnHookTime player last login time is nil or 0 !!!  ",pPlayer.dwID,pPlayer.szName,nLoginTime,nLogType);
		return
	end
	local nOfflineTime = self:LastOfflineTime(pPlayer);

	-- 只有开放挂机之后玩家下线才会更新nOfflineTime值，(nOfflineTime == 0 and not self:IsOpen(pPlayer)) 要注意的是开放以后玩家第一次上线也要计算，所以用and
	if not nOfflineTime or (nOfflineTime == 0 and not self:IsOpen(pPlayer)) then
		return
	end

	local nLastSaveTime = self:LastSaveTime(pPlayer)										-- 最近一次玩家数据存盘时间
	local nOpenActTime = self:OfflineTime2OpenServerTime(pPlayer) 							-- 活动开启时间

	--[[
		 如果玩家登陆之后，玩到挂机开启一直没下线，这时候服务器宕机，玩家重新上线的话，
		 会算从挂机开启到登陆时间这段时间的离线经验 所以加了nOpenActTime >= nLastSaveTime,
	 	 nLastSaveTime < nOpenActTime限定了玩家达到等级下线，活动开启后上线的情况
	]]

 	if nOfflineTime == 0 and nLastSaveTime <= nOpenActTime then 																	-- 挂机开启之后的第一次登陆
 		nOfflineTime = nOpenActTime															-- 设置离线时间为活动开启的时间
		pPlayer.SetUserValue(self.SAVE_ONHOOK_GROUP, self.OffLine_Time, -1); 				-- 马上标记已经计算过了
		nOnHookLogType = OnHook.tbCalcLogType.LogType_OpenAct
		Log("start first onhook time calc  ",nOnHookLogType,pPlayer.dwID,pPlayer.szName,nOpenActTime,nOfflineTime,nLastSaveTime,nLoginTime)
	else
		if OnHook:IsOnLineOnHook(pPlayer) then  												-- 如果手动开启了在线托管模式，优先用在线托管的开始时间
			nOfflineTime = OnHook:OnLineOnHookTime(pPlayer)
			-- 拿当前时间和在线托管的开始时间计算离线时间
			-- 目前三种情况会触发在线托管计算
			-- 1.手动结束在线托管
			-- 2.玩家开启在线托管后直接下线，重新上线的时候
			-- 3. 玩家参与活动或玩法时，强制结算
			nLoginTime = GetTime()
			nOnHookLogType = nLogType and nLogType or OnHook.tbCalcLogType.LogType_Online_Login
			if nOfflineTime > nLoginTime then
				Log("[OnHook] UpdateExpAndOnHookTime illegal nOnlineOnhookTime.",nOnHookLogType,nOfflineTime,nLoginTime)
				return
			end
		else
			nOfflineTime = nLastSaveTime								 						-- 玩家正常下线的时候该值为下线时间，玩家在线的时候为最后一次存库时间）
		end
	end

	-- 宕机时候玩家在线也不会损失太多离线时间给玩家，最多损失最后一次存库到宕机的时间
	if nOfflineTime == 0 then
	 	Log("[OnHook] UpdateExpAndOnHookTime player nOfflineTime is 0 !!!  ",nOnHookLogType,pPlayer.dwID,pPlayer.szName);
	 	return
	end

	local nExpTime = self:ExpTime(pPlayer);

	local nPassExpTime,nRemainOnHookTime = self:CalcPassExpAndOnHookTime(pPlayer,nLoginTime,nOfflineTime);

	nExpTime = nExpTime + nPassExpTime;
	nExpTime = nExpTime > self.MaxExpTime and self.MaxExpTime or nExpTime
	nRemainOnHookTime = nRemainOnHookTime > self.OnHookTimePerDay and self.OnHookTimePerDay or nRemainOnHookTime;

	pPlayer.SetUserValue(self.SAVE_ONHOOK_GROUP, self.Exp_Time, nExpTime);
	pPlayer.SetUserValue(self.SAVE_ONHOOK_GROUP, self.OnHook_Time, nRemainOnHookTime);
	pPlayer.SetUserValue(self.SAVE_ONLINE_ONHOOK_GROUP, self.OnLine_OnHook_Time, 0);			-- 每一次计算完在线托管离线时间将在线托管模式关掉
	pPlayer.SetUserValue(self.SAVE_ONHOOK_LOGIN_GROUP, self.Login_Time, GetTime());  			-- 每一次结束后更新登陆时间为当前时间，目的是在线托管跨天手动结束再下线的话就会再重置一遍

	pPlayer.CallClientScript("OnHook:OnCalcOnHookFinish")

	Log("[OnHook] UpdateExpAndOnHookTime calc success ",nOnHookLogType,pPlayer.dwID,pPlayer.szName,nExpTime,nPassExpTime,nRemainOnHookTime,nOfflineTime,OnHook:OnLineOnHookTime(pPlayer),pPlayer.nMapTemplateId,self:LoginTime(pPlayer))
end

function OnHook:OfflineTime2OpenServerTime(pPlayer) 		-- 模拟离线时间为挂机活动开启时间
	local dwServerCreateTime = ScriptData:GetValue("dwServerCreateTime");
	local nServerCreateZeroTime = Lib:GetTodayZeroHour(dwServerCreateTime);
	local nHour = self.nOpenTime / 100;
	local nMin = self.nOpenTime % 100;
	local nOfflineTime = nServerCreateZeroTime + (self.nOpenDay - 1) * 24 * 60 * 60 + nHour * 60 * 60 + nMin * 60;
	return nOfflineTime
end

function OnHook:GetOnHookExp(pPlayer,nGetType)															-- 领取离线经验
	local bRet,szMsg = self:CheckCommond(pPlayer);
	if not bRet then
		pPlayer.CenterMsg(szMsg);
		return
	end
	if nGetType == self.OnHookType.Free then
		self:DealFree(pPlayer);
	elseif nGetType == self.OnHookType.Pay then
		self:DealPay(pPlayer,nGetType);
	elseif nGetType == self.OnHookType.SpecialPay then
		if not self:CheckSpecialBaiJuWanIsOpen(pPlayer) then
			return ;
		end
		if OnHook:CheckSpecialPayType(pPlayer) then
			self:DealSpecialPay(pPlayer);
		else
			self:DealPay(pPlayer,nGetType);
		end
	end
	Log("OnHook GetOnHookExp Request",pPlayer.dwID,pPlayer.szName,pPlayer.nLevel,nGetType)
end

-- 目前提示获得经验在特定的情况下有问题
-- 1.真正获得的经验和显示的经验有点偏差，是因为现在加经验时可能会有加成
-- 2.满级获得经验达到满经验的情况下会把客户端显示的经验减半
function OnHook:AddExp(pPlayer, nType, nExpTime, nLogWay)
	local nAddExp = 0
	if OnHook:CheckIsMaxOpenLevel(pPlayer) then													-- 如果满级满经验
		local nRate = pPlayer.GetBaseAwardExp()														-- 目前等级的经验基准
		local nVipAddition = OnHook:GetVipAddition(pPlayer) 										-- vip加成
		local nExp = self:ExpTime2Exp(nExpTime, nType, nRate, nVipAddition);
		nAddExp = nAddExp + nExp;
		pPlayer.AddExperience(nExp, nLogWay);													-- 直接把经验给他
		nExpTime = 0;
		Log("OnHook AddExp: get onhook exp max ", pPlayer.dwID, pPlayer.szName, pPlayer.nLevel, nExp, nAddExp, nType, nRate)
		return nAddExp, nExpTime
	end

	local i = 1;																					-- 防止出现死循环的情况
	while (nExpTime > 0 and i < 100) do
		i = i + 1;
		local nHaveExp = pPlayer.GetExp();															-- 目前拥有的经验
		local nNowLevel = pPlayer.nLevel;
		local tbNowLevel = self.tbOnHook[nNowLevel];
		if not tbNowLevel then
			break
		end
		local nRate = pPlayer.GetBaseAwardExp()														-- 目前等级的经验基准
		local nVipAddition = OnHook:GetVipAddition(pPlayer) 										-- vip加成
		local nNextExp = tbNowLevel.nExpUpGrade;													-- 升下一等级总经验
		if nNowLevel >= self:MaxOpenLevel() and nNextExp <= nHaveExp then							-- 如果升满
			break
		end
		local nNeedExp = nNextExp - nHaveExp;														-- 升到下一等级需要的经验

		if nNeedExp <= 0 then																		-- 满等级满经验，开放等级之后领经验，需要的经验为0
			nNeedExp = 1																			-- 直接给一点经验升级
		end
		local nNeedTime = self:Exp2ExpTime(nNeedExp, nType, nRate, nVipAddition);						-- 目前加的经验需要扣除的离线时间
		if nExpTime < nNeedTime then																-- 如果升不满一级
			local nExp = self:ExpTime2Exp(nExpTime, nType, nRate, nVipAddition);
			nAddExp = nAddExp + nExp;
			pPlayer.AddExperience(nExp, nLogWay);													-- 直接把经验给他
			Log("OnHook AddExp: get onhook exp ", pPlayer.dwID, pPlayer.szName, pPlayer.nLevel, nExp, nType)
			nExpTime = 0
			break
		else
			local nExp = self:ExpTime2Exp(nNeedTime, nType, nRate, nVipAddition);						-- 如果升完当前等级还有剩离线时间
			nAddExp = nAddExp + nExp;
			pPlayer.AddExperience(nExp, nLogWay);													-- 直接升级
			Log("OnHook AddExp: get onhook exp level up", pPlayer.dwID, pPlayer.szName, pPlayer.nLevel, nExp, nType)
			nExpTime = nExpTime - nNeedTime;														-- 扣除升级所需要的离线时间
		end
	end

	return nAddExp, nExpTime
end

function OnHook:DealFree(pPlayer)
	local nExpTime = self:ExpTime(pPlayer);
	local bRet,nAddExp,nRemainExpTime = Lib:CallBack({OnHook.AddExp,OnHook,pPlayer,OnHook.OnHookType.Free,nExpTime,Env.LogWay_OnHookFree});

	if bRet then
		pPlayer.SetUserValue(self.SAVE_ONHOOK_GROUP, self.Exp_Time,nRemainExpTime);
		Log("OnHook DealFree ：player get onhook exp free success",pPlayer.nLevel,pPlayer.dwID,pPlayer.szName,nAddExp,OnHook.OnHookType.Free,nRemainExpTime,nExpTime);
	else
		pPlayer.SetUserValue(self.SAVE_ONHOOK_GROUP, self.Exp_Time,0);
		Log("OnHook DealFree ：player get onhook exp free error",pPlayer.nLevel,pPlayer.dwID,pPlayer.szName,self.OnHookType.Free,pPlayer.nLevel,nExpTime,nAddExp);
		local nVipAddition = OnHook:GetVipAddition(pPlayer)
		nAddExp = self:ExpTime2Exp(nExpTime,OnHook.OnHookType.Free,pPlayer.GetBaseAwardExp(),nVipAddition);
	end

	pPlayer.CallClientScript("OnHook:OnGetExpFinish", nAddExp, nRemainExpTime, self.OnHookType.Free);
	pPlayer.TLog("OnHookFlow", OnHook.OnHookType.Free, Env.LogWay_OnHookFree, nAddExp, nRemainExpTime, pPlayer.nLevel, nExpTime - nRemainExpTime, 0)
end

function OnHook:DealPay(pPlayer,nPayType)

	local nExpTime = self:ExpTime(pPlayer);														-- 可领的离线经验时间
	local nBaiJuWanTime = self:GetBaiJuWanTime(pPlayer,nPayType);								-- 目前拥有的白驹丸时间
	local nSaveBaiJuWanKey = self:GetBaiJuWanSaveKey(nPayType);

	if nExpTime <= nBaiJuWanTime then														-- 白驹丸够用

		local bRet,nAddExp,nRemainExpTime = Lib:CallBack({OnHook.AddExp,OnHook,pPlayer,nPayType,nExpTime,Env.LogWay_OnHookPay});
		if bRet then
			nBaiJuWanTime = nBaiJuWanTime - (nExpTime - nRemainExpTime)
			pPlayer.SetUserValue(self.SAVE_ONHOOK_GROUP, self.Exp_Time, nRemainExpTime);
			pPlayer.SetUserValue(self.SAVE_ONHOOK_GROUP, nSaveBaiJuWanKey, nBaiJuWanTime);
			Log("OnHook DealPay：player get onhook exp pay success",pPlayer.nLevel,pPlayer.dwID,pPlayer.szName,nAddExp,nPayType,nRemainExpTime,nExpTime,nBaiJuWanTime);
		else
			nBaiJuWanTime = nBaiJuWanTime - nExpTime
			pPlayer.SetUserValue(self.SAVE_ONHOOK_GROUP, self.Exp_Time, 0);
			pPlayer.SetUserValue(self.SAVE_ONHOOK_GROUP, nSaveBaiJuWanKey, nBaiJuWanTime);

			Log("OnHook DealPay：player get onhook exp pay error",pPlayer.nLevel,pPlayer.dwID,pPlayer.szName,nPayType,nExpTime,nBaiJuWanTime);
			nAddExp = 0
		end
		pPlayer.CallClientScript("OnHook:OnGetExpFinish", math.floor(nAddExp), nRemainExpTime, nPayType)
		pPlayer.TLog("OnHookFlow", OnHook.OnHookType.Pay, Env.LogWay_OnHookPay, nAddExp, nRemainExpTime, pPlayer.nLevel, nExpTime - nRemainExpTime, 0)
	else 																						-- 拥有的白驹丸时间不够

		local nExtraExpTime = nExpTime - nBaiJuWanTime;											-- 缺少的白驹丸时间

		local nPerBaiJuWanTime,nPerBaiJuWanPrice,nItemId = self:GetPerBaiJuWanInfo(nPayType);	-- 白驹丸每个的时间,价格，Id

		local nHaveNum = pPlayer.GetItemCountInAllPos(nItemId);									-- 拥有的数量
		local nNeedNum = math.ceil(nExtraExpTime / nPerBaiJuWanTime);							-- 需要的数量
		local nUseNum = nHaveNum > nNeedNum and nNeedNum or nHaveNum;							-- 用掉的数量
		local nLackNum = nNeedNum - nHaveNum; 													-- 还缺少的数量

		if nLackNum > 0 then																	-- 需要用元宝的情况
			local nNeedPay = nLackNum * nPerBaiJuWanPrice;										-- 不够的用元宝还
			if pPlayer.GetMoney("Gold") < nNeedPay then
				pPlayer.CenterMsg("您的元寶不足");
				pPlayer.CallClientScript("Ui:OpenWindow","CommonShop","Recharge");
				return ;
			end
			pPlayer.CostGold(nNeedPay, Env.LogWay_OnHookPay, nItemId, function (nPlayerId, bSuccess) -- 先扣掉需要的钱
					if not bSuccess then
						return false;
					end

					local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
					if not pPlayer then
						return false;
					end

					if nUseNum > 0 then
						local nConsume = pPlayer.ConsumeItemInAllPos(nItemId,nUseNum, Env.LogWay_OnHookPay);		-- 再扣掉需要的白驹丸
						if nConsume ~= nUseNum then
							return false,"扣除道具失敗."
						end
					end

					local bCheck,szMsg = OnHook:CheckCommond(pPlayer)
					if not bCheck then
						Log("OnHook DealPay: cost repeat",pPlayer.nLevel,pPlayer.dwID,pPlayer.szName,nPayType,nBaiJuWanTime,nUseNum,nItemId,nNeedPay,nNeedNum)
						return false,szMsg
					end
					nExpTime = OnHook:ExpTime(pPlayer)
					nBaiJuWanTime = OnHook:GetBaiJuWanTime(pPlayer,nPayType);

					local bRet,nAddExp,nRemainExpTime = Lib:CallBack({OnHook.AddExp,OnHook,pPlayer,nPayType,nExpTime,Env.LogWay_OnHookPay});

					if bRet then
						nBaiJuWanTime = nBaiJuWanTime + nNeedNum * nPerBaiJuWanTime - (nExpTime - nRemainExpTime);
						pPlayer.SetUserValue(self.SAVE_ONHOOK_GROUP, self.Exp_Time, nRemainExpTime);
						pPlayer.SetUserValue(self.SAVE_ONHOOK_GROUP, nSaveBaiJuWanKey, nBaiJuWanTime);
						Log("OnHook DealPay：player get onhook cost gold way exp pay success",pPlayer.nLevel,pPlayer.dwID,pPlayer.szName,nAddExp,nPayType,nRemainExpTime,nExpTime,nBaiJuWanTime,nUseNum,nItemId,nNeedPay,nNeedNum);
					else
						pPlayer.SetUserValue(self.SAVE_ONHOOK_GROUP, self.Exp_Time, 0);
						pPlayer.SetUserValue(self.SAVE_ONHOOK_GROUP, nSaveBaiJuWanKey, 0);

						Log("OnHook DealPay：player get onhook cost gold way exp gold way pay error",pPlayer.nLevel,pPlayer.dwID,pPlayer.szName,nPayType,nExpTime,nBaiJuWanTime,nUseNum,nItemId,nNeedPay,nNeedNum);
						nAddExp = 0
						return false,"腳本報錯"
					end

					pPlayer.CallClientScript("OnHook:OnGetExpFinish", nAddExp, nRemainExpTime, nPayType)
					pPlayer.TLog("OnHookFlow", OnHook.OnHookType.Pay, Env.LogWay_OnHookPay, nAddExp, nRemainExpTime, pPlayer.nLevel, nExpTime - nRemainExpTime, 0)
					return true
				end);
		else 																					-- 不需要元宝，只需要白驹丸
			local nConsume = pPlayer.ConsumeItemInAllPos(nItemId,nUseNum, Env.LogWay_OnHookPay);
			if nConsume ~= nUseNum then
				pPlayer.CenterMsg("扣除道具失敗.");
				return ;
			end

			local bRet,nAddExp,nRemainExpTime = Lib:CallBack({OnHook.AddExp,OnHook,pPlayer,nPayType,nExpTime,Env.LogWay_OnHookPay});
			if bRet then
				nBaiJuWanTime = nBaiJuWanTime + nUseNum * nPerBaiJuWanTime - (nExpTime - nRemainExpTime);
				pPlayer.SetUserValue(self.SAVE_ONHOOK_GROUP, self.Exp_Time, nRemainExpTime);
				pPlayer.SetUserValue(self.SAVE_ONHOOK_GROUP, nSaveBaiJuWanKey, nBaiJuWanTime);
				Log("OnHook DealPay：player get onhook use baijuwan way exp success",pPlayer.nLevel,pPlayer.dwID,pPlayer.szName,nAddExp,nPayType,nRemainExpTime,nExpTime,nBaiJuWanTime,nUseNum,nItemId,nNeedPay,nNeedNum);
			else
				pPlayer.SetUserValue(self.SAVE_ONHOOK_GROUP, self.Exp_Time, 0);
				pPlayer.SetUserValue(self.SAVE_ONHOOK_GROUP, nSaveBaiJuWanKey, 0);

				Log("OnHook DealPay：player get onhook use baijuwan way exp gold way error",pPlayer.nLevel,pPlayer.dwID,pPlayer.szName,nPayType,nExpTime,nBaiJuWanTime,nUseNum,nItemId,nNeedPay,nNeedNum);
				nAddExp = 0
			end

			pPlayer.CallClientScript("OnHook:OnGetExpFinish", nAddExp, nRemainExpTime, nPayType)
			pPlayer.TLog("OnHookFlow", OnHook.OnHookType.Pay, Env.LogWay_OnHookPay, nAddExp, nRemainExpTime, pPlayer.nLevel, nExpTime - nRemainExpTime, 0)
		end
	end
end

function OnHook:DealSpecialPay(pPlayer)
	local nExpTime = self:ExpTime(pPlayer);														-- 可领的离线经验时间
	local nBaiJuWanTime = self:GetBaiJuWanTime(pPlayer,self.OnHookType.SpecialPay);								-- 目前拥有的白驹丸时间
	local nSaveBaiJuWanKey = self:GetBaiJuWanSaveKey(self.OnHookType.SpecialPay);

	local bRet,nAddExp,nRemainExpTime

	if nExpTime <= nBaiJuWanTime then
		bRet,nAddExp,nRemainExpTime = Lib:CallBack({OnHook.AddExp,OnHook,pPlayer,self.OnHookType.SpecialPay,nExpTime,Env.LogWay_OnHookSpecialPay});
		if bRet then
			nBaiJuWanTime = nBaiJuWanTime - (nExpTime - nRemainExpTime)
			pPlayer.SetUserValue(self.SAVE_ONHOOK_GROUP, self.Exp_Time, nRemainExpTime);
			pPlayer.SetUserValue(self.SAVE_ONHOOK_GROUP, nSaveBaiJuWanKey, nBaiJuWanTime);
			Log("OnHook DealSpecialPay：player get onhook exp pay success",pPlayer.nLevel,pPlayer.dwID,pPlayer.szName,nAddExp,nRemainExpTime,nExpTime,nBaiJuWanTime);
		else
			nBaiJuWanTime = nBaiJuWanTime - nExpTime
			pPlayer.SetUserValue(self.SAVE_ONHOOK_GROUP, self.Exp_Time, 0);
			pPlayer.SetUserValue(self.SAVE_ONHOOK_GROUP, nSaveBaiJuWanKey, nBaiJuWanTime);

			Log("OnHook DealSpecialPay：player get onhook exp pay error",pPlayer.nLevel,pPlayer.dwID,pPlayer.szName,nExpTime,nBaiJuWanTime);
			nAddExp = 0;
		end
	else
		local nTryAddTime = nBaiJuWanTime
		bRet,nAddExp,nRemainExpTime = Lib:CallBack({OnHook.AddExp,OnHook,pPlayer,self.OnHookType.SpecialPay,nTryAddTime,Env.LogWay_OnHookSpecialPay});
		if bRet then
			nBaiJuWanTime = nBaiJuWanTime - (nTryAddTime - nRemainExpTime)
			nExpTime = nExpTime - (nTryAddTime - nRemainExpTime)
			pPlayer.SetUserValue(self.SAVE_ONHOOK_GROUP, self.Exp_Time, nExpTime);
			pPlayer.SetUserValue(self.SAVE_ONHOOK_GROUP, nSaveBaiJuWanKey, nBaiJuWanTime);
			Log("OnHook DealSpecialPay：player get onhook exp pay success",pPlayer.nLevel,pPlayer.dwID,pPlayer.szName,nAddExp,nRemainExpTime,nExpTime,nBaiJuWanTime,nTryAddTime);
		else
			pPlayer.SetUserValue(self.SAVE_ONHOOK_GROUP, self.Exp_Time, 0);
			pPlayer.SetUserValue(self.SAVE_ONHOOK_GROUP, nSaveBaiJuWanKey, 0);

			Log("OnHook DealSpecialPay：player get onhook exp pay error",pPlayer.nLevel,pPlayer.dwID,pPlayer.szName,nExpTime,nBaiJuWanTime,nTryAddTime);
			nAddExp = 0;
		end
	end
	pPlayer.CallClientScript("OnHook:OnGetExpFinish", math.floor(nAddExp), nRemainExpTime, self.OnHookType.SpecialPay)
	pPlayer.TLog("OnHookFlow", OnHook.OnHookType.SpecialPay, Env.LogWay_OnHookSpecialPay, nAddExp or 0, nRemainExpTime or 0, pPlayer.nLevel, nExpTime - (nRemainExpTime or 0), 0)
end

-- =================== 白驹丸使用
function OnHook:OnUseBaiJuWan(pPlayer,nBJWTime,nType)

	if not nType or not nBJWTime or (nType ~= OnHook.OnHookType.Pay and nType ~= OnHook.OnHookType.SpecialPay) or nBJWTime < 0 then
		return
	end

	local nExpTime = self:ExpTime(pPlayer);
	local nAddBJWTime = math.floor(nBJWTime)
	local nAddExpTime = 0
	local nAddExp = 0
	local nRemainExpTime = 0

	local bRet
	local szLog = ""
	if nExpTime > 0 then
		nAddExpTime = nExpTime > nBJWTime and nBJWTime or nExpTime
		bRet,nAddExp,nRemainExpTime = Lib:CallBack({OnHook.AddExp,OnHook,pPlayer,nType,nAddExpTime,Env.LogWay_OnHookUseBaiJuWan});

		if bRet then
			nExpTime = nExpTime - nAddExpTime + nRemainExpTime
			nAddBJWTime = nAddBJWTime - nAddExpTime + nRemainExpTime
			szLog = "OnHook OnUseBaiJuWan  baijuwan get exp success  "
		else
			local nVipAddition = OnHook:GetVipAddition(pPlayer)
			nAddExp = self:ExpTime2Exp(nExpTime,nType,pPlayer.GetBaseAwardExp(),nVipAddition);
			nAddBJWTime = 0
			nExpTime = (nExpTime - nBJWTime) > 0 and (nExpTime - nBJWTime) or 0
			szLog = "OnHook OnUseBaiJuWan baijuwan get exp error  "
		end
	end

	if nType == OnHook.OnHookType.Pay then
		pPlayer.SetUserValue(self.SAVE_ONHOOK_GROUP, self.BaiJuWan_Time, self:BaiJuWanTime(pPlayer) + nAddBJWTime);
	elseif nType == OnHook.OnHookType.SpecialPay then
		pPlayer.SetUserValue(self.SAVE_ONHOOK_GROUP, self.SpecialBaiJuWan_Time, self:SpecialBaiJuWanTime(pPlayer) + nAddBJWTime);
	end

	pPlayer.SetUserValue(self.SAVE_ONHOOK_GROUP, self.Exp_Time, nExpTime);

	if nAddBJWTime > 0 then
		local nHour,nMinute,nSecond = Lib:TransferSecond2NormalTime(nAddBJWTime);
		local szTime = ""
		local szItem = ""
		if nHour > 0 then
			szTime = szTime ..nHour .. "小時"
		end
		if nMinute > 0 then
			szTime = szTime ..nMinute .. "分"
		end
		if nSecond > 0 then
			szTime = szTime ..nSecond .. "秒"
		end
		if szTime ~= "" then
			szItem = nType == OnHook.OnHookType.Pay and "白駒丸" or "特效白駒丸"
			pPlayer.CenterMsg(szItem .."時間增加" ..szTime);
		end
	end

	pPlayer.CallClientScript("OnHook:OnGetExpFinish", nAddExp, nRemainExpTime, nType)

	Log(szLog,pPlayer.nLevel,pPlayer.dwID,nType,nAddExp,nAddBJWTime,nExpTime,nRemainExpTime);
	pPlayer.TLog("OnHookFlow", nType, Env.LogWay_OnHookUseBaiJuWan, nAddExp, nRemainExpTime, pPlayer.nLevel, nExpTime - nRemainExpTime, nAddBJWTime)
	return true
end


-- ============ 在线托管
--[[
	在玩家下线的时候会回调OnLeaveMap结算在线托管时间
]]

-- 开启在线托管
function OnHook:StartOnLineOnHook(pPlayer)

	local bRet,szMsg = OnHook:CheckRequestOnlineOH(pPlayer)

	if bRet then
		bRet,szMsg = OnHook:CheckStartOnlineHook(pPlayer)
	end

	if not bRet then
		pPlayer.CenterMsg(szMsg)
		return
	end

	ActionMode:DoForceNoneActMode(pPlayer)

	-- 跨天托管重置挂机时间与并修改上次登录时间为在线托管时间
	self:UpdateOnHookTime(pPlayer);

	pPlayer.SetUserValue(self.SAVE_ONHOOK_LOGIN_GROUP, self.Login_Time, GetTime());

	pPlayer.SetUserValue(self.SAVE_ONLINE_ONHOOK_GROUP, self.OnLine_OnHook_Time, GetTime());

	pPlayer.AddSkillState(self.nNoMoveBuffId, 1, 0, -1, 1, 1);

	pPlayer.nRequestStartOnlineOHTime = GetTime() + OnHook.nRequestOnlineOHInterval

	pPlayer.CallClientScript("OnHook:StartOnlineOnHookState")

	pPlayer.CenterMsg(string.format("託管開始，目前剩餘可託管時間：%s鐘", Lib:TimeDesc5(OnHook:GetOnHookTime(pPlayer))), true)

	Log("[OnHook] StartOnLineOnHook ",pPlayer.dwID,pPlayer.szName,OnHook:OnHookTime(pPlayer),OnHook:OnLineOnHookTime(pPlayer),pPlayer.nMapTemplateId)
end

-- 结算在线托管
function OnHook:EndOnLineOnHook(pPlayer, nLogType)

	local nOnlineOnhookTime = OnHook:OnLineOnHookTime(pPlayer) > 0 and  OnHook:OnLineOnHookTime(pPlayer) or 0

	if nOnlineOnhookTime == 0 then
		pPlayer.SetUserValue(self.SAVE_ONLINE_ONHOOK_GROUP, self.OnLine_OnHook_Time, 0);
		-- 手动结算时nOnlineOnhookTime不可能为0,活动或玩法有可能为0，因为有可能玩家有可能并没有开启在线托管就进行活动，这是正常的
		if nLogType and nLogType == OnHook.tbCalcLogType.LogType_Online_Hand then
			Log("[OnHook] EndOnLineOnHook End By Hand Error .",pPlayer.dwID,pPlayer.szName,OnHook:OnHookTime(pPlayer),nOnlineOnhookTime,pPlayer.nMapTemplateId)
		end

		return
	end
	-- 不能手动结束强制在线托管状态
	if nLogType and nLogType == OnHook.tbCalcLogType.LogType_Online_Hand and OnHook:IsOnLineOnHookForce(pPlayer) then
		pPlayer.CenterMsg("不能手動結束當前託管狀態")
		return
	end

	local bRet,szMsg = OnHook:CheckEndOnlineHook(pPlayer)

	if not bRet then
		pPlayer.CenterMsg(szMsg)
		return
	end

	-- 强制结束不检查区域
	if not nLogType or nLogType ~= OnHook.tbCalcLogType.LogType_Online_Force then
		if not self.tbOnlineOnhookMap[pPlayer.nMapTemplateId] then
			pPlayer.SetUserValue(self.SAVE_ONLINE_ONHOOK_GROUP, self.OnLine_OnHook_Time, 0);
			Log("[OnHook] EndOnLineOnHook invalid map",pPlayer.dwID,pPlayer.szName,pPlayer.nMapTemplateId,nLogType)
			return
		end

		if not Map:IsCityMap(pPlayer.nMapTemplateId) then
			pPlayer.CenterMsg("只能在城市開啟線上託管")
			return
		end
	end

	local nExpTimeBefore = self:ExpTime(pPlayer)

	self:UpdateExpAndOnHookTime(pPlayer,nLogType);

	local nExpTimeAfter = self:ExpTime(pPlayer)

	pPlayer.RemoveSkillState(self.nNoMoveBuffId)

	pPlayer.CallClientScript("OnHook:EndOnlineOnHookState")

	local szTime = Lib:TimeDesc5(nExpTimeAfter - nExpTimeBefore) or ""

	pPlayer.CenterMsg(string.format("託管結束，已託管%s鐘", szTime), true)

	Log("[OnHook] EndOnLineOnHook ",pPlayer.dwID,pPlayer.szName,OnHook:OnHookTime(pPlayer),nOnlineOnhookTime,pPlayer.nMapTemplateId,szTime)
end

-- 强制开启在线托管(没有限制行动)
function OnHook:StartOnLineOnHookForce(pPlayer)
	local nNowTime = GetTime()

	if not self:IsOpen(pPlayer) then
		return
	end

	if self:OnHookTime(pPlayer) < 60 and not self:IsCrossDay(pPlayer, nNowTime, self:LoginTime(pPlayer)) then
		pPlayer.CenterMsg("今日託管時間已用完", true)
		return
	end

	if self:OnLineOnHookTime(pPlayer) > 0 then
		pPlayer.CenterMsg("目前已經開啟線上掛機", true)
		return
	end

	-- 跨天托管重置挂机时间与并修改上次登录时间为在线托管时间
	self:UpdateOnHookTime(pPlayer);

	pPlayer.SetUserValue(self.SAVE_ONHOOK_LOGIN_GROUP, self.Login_Time, nNowTime);

	pPlayer.SetUserValue(self.SAVE_ONLINE_ONHOOK_GROUP, self.OnLine_OnHook_Time, nNowTime);

	pPlayer.CenterMsg(string.format("託管開始，目前剩餘可託管時間：%s鐘", Lib:TimeDesc5(OnHook:GetOnHookTime(pPlayer))), true)

	pPlayer.CallClientScript("OnHook:StartOnlineOnHookForceState")

	Log("[OnHook] fnStartOnLineOnHookForce ", pPlayer.dwID, pPlayer.szName, OnHook:OnHookTime(pPlayer), OnHook:OnLineOnHookTime(pPlayer), pPlayer.nMapTemplateId)
end

-- 玩家下线的时候也会回调该方法
function OnHook:OnLeaveMap(nMapTemplateId, nMapId)
	OnHook:EndOnLineOnHook(me, OnHook.tbCalcLogType.LogType_Online_Force)
end

-- 客户端地图进入（目前武林盟主有可能切换到客户端计算）
function OnHook:EnterClientMap(nMapTemplateId)
	OnHook:EndOnLineOnHook(me, OnHook.tbCalcLogType.LogType_Online_Force)
end

function OnHook:OnEnterMap(nMapTemplateId, nMapId)
	self:TryStartOnLineOnHookForce(me)
end

function OnHook:TryStartOnLineOnHookForce(pPlayer)
	-- 进入家园强制开启在线托管
	if House:IsInNormalHouse(pPlayer) and ( House:IsInOwnHouse(pPlayer) or House:IsInLivingRoom(pPlayer) )then
		OnHook:StartOnLineOnHookForce(pPlayer)
	end
end

PlayerEvent:RegisterGlobal("OnLeaveMap",                    OnHook.OnLeaveMap, OnHook);
PlayerEvent:RegisterGlobal("EnterClientMap",                OnHook.EnterClientMap, OnHook);