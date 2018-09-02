local tbFuben = Fuben:CreateFubenClass(Wedding.szReplayFubenBase);
function tbFuben:OnCreate(nRoleId, nLevel)
	local nNowTime = GetTime() 
	self.nStartReplayTime = nNowTime	
	self.nWeddingLevel = nLevel
	self.nRoleId = nRoleId
	self:InitRoleData()
	self:Start();
end

function tbFuben:OnFirstJoin(pPlayer)
	if pPlayer.dwID == self.nRoleId then
		if self.tbSetting.nStartReplayUnlockId then
 			self:UnLock(self.tbSetting.nStartReplayUnlockId);
 			Log("WeddingReplayFuben Start ", pPlayer.dwID, pPlayer.szName)
   		end
	end
end

-- 》》开始拜堂仪式
function tbFuben:OnStartMarryCeremony()
    local fnRoleExcute = function (self, pPlayer)
    	self:StartMarryCeremonyState(pPlayer)
    	-- 隐藏主角
    	self:SetHide(pPlayer, 1)
    	pPlayer.CallClientScript("Wedding:OnRoleStartMarryCeremonyState")
    	self:PlayMarryCeremonySceneAnim(pPlayer)
    end
    self:ForeachRole(fnRoleExcute)
    -- 镜头动画
    self:PlayCameraAnimation(1)
    Log("WeddingReplayFuben fnOnStartMarryCeremony ok >>", self.nRoleId)
end

function tbFuben:StartMarryCeremonyState(pPlayer)
	pPlayer.CallClientScript("Wedding:OnStateMarryCeremonyState", true)
	pPlayer.AddSkillState(Wedding.nNoMoveBuffId, 1, 0, -1, 1, 1);
end

-- 拜堂结束
function tbFuben:OnEndMarryCeremony()
    local fnRoleExcute = function (self, pPlayer)
	    -- 强制显示
		self:SetHide(pPlayer, 0)
    	self:EndMarryCeremonyState(pPlayer)
   
    	pPlayer.CallClientScript("Wedding:OnRoleEndMarryCeremonyState")
    	self:StopMarryCeremonySceneAnim(pPlayer)
    	-- 重置镜头
    	pPlayer.CallClientScript("Ui.CameraMgr.LeaveCameraAnimationState");
		pPlayer.CallClientScript("Ui.CameraMgr.RestoreCameraRotation");
    end
    self:ForeachRole(fnRoleExcute)
   	-- 为了防止策划配错，强制恢复游戏速度为1
   	self:SetGameWorldScale(1)
   	Log("WeddingReplayFuben fnOnEndMarryCeremony ok >>", self.nRoleId)
end

function tbFuben:EndMarryCeremonyState(pPlayer)
	pPlayer.CallClientScript("Wedding:OnEndMarryCeremonyState")
	pPlayer.RemoveSkillState(Wedding.nNoMoveBuffId)
end

function tbFuben:StopMarryCeremonySceneAnim(pPlayer)
	pPlayer.CallClientScript("Wedding:OnStopMarryCeremonySceneAnim", self.nWeddingLevel)
end


function tbFuben:PlayMarryCeremonySceneAnim(pPlayer)
	pPlayer.CallClientScript("Wedding:OnPlayMarryCeremonySceneAnim", self.tbRoleData, self.nWeddingLevel)
end

function tbFuben:OnJoin(pPlayer)
	pPlayer.CallClientScript("Wedding:OnJoinWeddingReplay")
end

function tbFuben:OnLogin()
	self:SynState(me)
end

function tbFuben:SynState(pPlayer)
	pPlayer.nCanLeaveMapId = self.nMapId;
	self:StartMarryCeremonyState(pPlayer)
	pPlayer.CallClientScript("Wedding:OnRoleStartMarryCeremonyState")
end

-- 1 隐藏 0 显示
function tbFuben:SetHide(pPlayer, nHide)
	local pNpc = pPlayer.GetNpc()
	if pNpc then
		pNpc.SetHideNpc(nHide)
	end
end

function tbFuben:InitRoleData()
	local tbRoleData = {}
	local nLoverId = Wedding:GetLover(self.nRoleId)
	local pPlayer = KPlayer.GetPlayerObjById(self.nRoleId)
	local pRoleStay = pPlayer or KPlayer.GetRoleStayInfo(self.nRoleId)
	local nRoleSex = pPlayer and pPlayer.GetUserValue(Wedding.nSaveGrp, Wedding.nSaveKeyGender) or Gift.Sex.Boy
	local tbRole = {}
	if nRoleSex == Gift.Sex.Boy then
		tbRole = {self.nRoleId, nLoverId}
	else
		tbRole = {nLoverId, self.nRoleId}
	end
	for i, dwID in ipairs(tbRole) do
		tbRoleData[i] = {}
		local pStayInfo = KPlayer.GetPlayerObjById(dwID) or KPlayer.GetRoleStayInfo(dwID)
		local szName = pStayInfo and pStayInfo.szName or ""
		tbRoleData[i].szName = szName
	end
	self.szManName = tbRoleData[Gift.Sex.Boy] and tbRoleData[Gift.Sex.Boy].szName or ""
	self.szFemaleName = tbRoleData[Gift.Sex.Girl] and tbRoleData[Gift.Sex.Girl].szName or ""
	self.tbRoleData = tbRoleData
end

-- 遍历主角
function tbFuben:ForeachRole(fnFunc, ...)
	local pPlayer = KPlayer.GetPlayerObjById(self.nRoleId)
	if pPlayer and pPlayer.nMapId == self.nMapId then
		Lib:CallBack({fnFunc, self, pPlayer, ...});
	end
end

function tbFuben:OnMarryCeremonyPlayerFadeAnim(...)
	local fnFade = function (self, pPlayer, ...)
    	pPlayer.CallClientScript("Ui:OpenWindow", "StoryBlackBg", ...)
   	end
   	self:ForeachRole(fnFade, ...)
end

function tbFuben:OnOpenWeddingInterludePanel(szMsg, szContent)
	local szBoyName = self.szManName
	local szGirlName =self.szFemaleName
	if szMsg then
		szMsg = string.format(szMsg, szBoyName, szGirlName)
	end
	local tbInfo
	if szContent then
		tbInfo = {}
		tbInfo.szManName = szBoyName
		tbInfo.szFemanName = szGirlName
		tbInfo.szContent = szContent
	end
	local fnExcute = function (pPlayer)
		pPlayer.CallClientScript("Ui:OpenWindow", "WeddingInterludePanel", szMsg, tbInfo)
    end
    self:AllPlayerExcute(fnExcute)
end

function tbFuben:OnMarryCeremonyPlayerBlackMsg(szMsg)
	local fnMsg = function (self, pPlayer)
		pPlayer.CallClientScript("Ui:OpenWindow", "WeddingTxtPanel", szMsg)
   	end
   	self:ForeachRole(fnMsg)
end

function tbFuben:OnDestroyUi(szUiName)
	local fnExcute = function (pPlayer)
		pPlayer.CallClientScript("Wedding:TryDestroyUi", szUiName)
    end
    self:AllPlayerExcute(fnExcute)
end
