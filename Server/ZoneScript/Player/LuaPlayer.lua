local self;

--重载
function _LuaPlayer.GetPartnerPosInfo()
	if self.tbPartnerPosToId then
		return self.tbPartnerPosToId
	end
	local pAsync = KPlayer.GetAsyncData(self.dwID)
	if not pAsync then
		return
	end
	local tbPartnerPosToId = {}
	for i=1,Partner.MAX_PARTNER_POS_COUNT do
		local _, _,_, _, _,_, _, _, nPartnerId = pAsync.GetPartnerInfo(i);
		tbPartnerPosToId[i] = nPartnerId or 0
	end
	self.tbPartnerPosToId = tbPartnerPosToId
	return tbPartnerPosToId
end

--只是跨服用，现在只是心魔用到
function _LuaPlayer.ClearPartnerInfo()
	self.tbPartnerPosToId = {}
	for i=1,Partner.MAX_PARTNER_POS_COUNT do
		table.insert(self.tbPartnerPosToId, 0)
	end
end

function _LuaPlayer.GetPartnerPosById(nPartnerID)
	local tbPartnerPosToId = self.GetPartnerPosInfo()
	for nPos, nId in pairs(tbPartnerPosToId) do
		if nId == nPartnerID then
			return nPos
		end
	end
end

--重载
function _LuaPlayer.GetPartnerInfo(nPartnerID)
	local tbPartnerPosToId = self.GetPartnerPosInfo()
	local nPos;
	for i,v in ipairs(tbPartnerPosToId) do
		if v == nPartnerID then
			nPos = i;
			break;
		end
	end
	if not nPos then
		return
	end
	local pAsync = KPlayer.GetAsyncData(self.dwID)
	if not pAsync then
		return
	end

	local nPartnerTemplateId, nLevel,nFightPower, nWeaponState, nProtentialVitality,nProtentialDexterity, nProtentialStrength, nProtentialEnergy, nPartnerId = pAsync.GetPartnerInfo(nPos);
	if not nPartnerTemplateId then
		return
	end
	local _, _, nNpcTemplateId = GetOnePartnerBaseInfo(nPartnerTemplateId)

	return {
		nPartnerId = nPartnerId;
		nLevel = nLevel;
		nFightPower = nFightPower;
		nNpcTemplateId = nNpcTemplateId;
		nWeaponState = nWeaponState;
		nProtentialVitality = nProtentialVitality;
		nProtentialDexterity = nProtentialDexterity;
		nProtentialStrength = nProtentialStrength;
		nProtentialEnergy = nProtentialEnergy;
	}	
end

--重载
function _LuaPlayer.CreatePartnerByPos(nPos)
	local pAsync = KPlayer.GetAsyncData(self.dwID)
	if not pAsync then
		return
	end
	local nMapId,x, y = self.GetWorldPos()
	local pNpc = pAsync.AddPartnerNpc(nPos, nMapId,x, y)
	if pNpc then
		pNpc.SetMasterNpcId(self.GetNpc().nId);
		if not self.tbCurCreatePartnerNpc then
			self.tbCurCreatePartnerNpc = {}
		end
		self.tbCurCreatePartnerNpc[nPos] = pNpc.nId 
		return pNpc
	end
end

--重载
function _LuaPlayer.HaulBackPartnerPos()
	local tbCurCreatePartnerNpc = self.tbCurCreatePartnerNpc
	if not tbCurCreatePartnerNpc then
		return
	end
	local nMapId,x,y = self.GetWorldPos()
	for k,v in pairs(tbCurCreatePartnerNpc) do
		local pNpc = KNpc.GetById(v)
		if pNpc then
			if pNpc.nMapId == nMapId then
				pNpc.SetPosition(x, y)
			end
		else
			tbCurCreatePartnerNpc[k] = nil;
		end
	end
	return 1;
end

--重载
function _LuaPlayer.CreatePartnerByID(nPartnerID)
	local nPartnerPos = self.GetPartnerPosById(nPartnerID)
	if not nPartnerPos then
		return
	end
	return self.CreatePartnerByPos(nPartnerPos)
end

--重载
function _LuaPlayer.SetFightPartnerID(nPartnerId)
    self.SetUserValue(Partner.nSavePKFightGroup, Partner.nSavePKFightID, nPartnerId);
    CallZoneClientScript(self.nZoneIndex, "Partner:OnZCSetFightPartnerID", self.dwID, nPartnerId)
end