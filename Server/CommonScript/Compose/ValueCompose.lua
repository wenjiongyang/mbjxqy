Compose.ValueCompose = Compose.ValueCompose or {}
local ValueCompose = Compose.ValueCompose;
local nMaxParam = 9;
ValueCompose.tbAllInfo = {};

function ValueCompose:InitData()
	local szTabPath = "Setting/Item/ItemCompose/ValueCompose.tab";
	local szParamType = "ddsddss";
	local szKey = "SeqId";
	local tbParams = {"SeqId","TargetTemplateId","DirTitle","AllCount", "Icon", "Tips","BGMapPath"};

	for i=1,nMaxParam do
		local szItemDesKey = "ItemDes" ..i;
		szParamType = szParamType .."s";
		table.insert(tbParams,szItemDesKey);
	end

	local tbSettings = LoadTabFile(szTabPath, szParamType, szKey, tbParams);
	for nSeqId,v in ipairs(tbSettings) do
		local tbSeqInfo = {}
		tbSeqInfo.nSeqId = v.SeqId;
		tbSeqInfo.nTargetTemplateId = v.TargetTemplateId;
		tbSeqInfo.szDirTitle = v.DirTitle;
		tbSeqInfo.nAllCount = v.AllCount;
		tbSeqInfo.szBGMapPath = v.BGMapPath;
		tbSeqInfo.nIcon = v.Icon;
		tbSeqInfo.szTips = v.Tips;

		local nTempCount = 0;
		for i=1, nMaxParam do
			if v["ItemDes" ..i] and v["ItemDes" ..i] ~= "" then
				tbSeqInfo["szItemDes" ..i] = v["ItemDes" ..i];
				nTempCount = nTempCount + 1;
			end
		end
		assert(nTempCount == v.AllCount,string.format("ValueCompose tab load assert fail !! nAllCount(%d) ~= nTempCount(%d)",tbSeqInfo.nAllCount,nTempCount));
		self.tbAllInfo[nSeqId] = tbSeqInfo;
	end
end

ValueCompose:InitData();

--返回某个nSeqId的信息
function ValueCompose:GetSeqInfo(nSeqId)
	return self.tbAllInfo[nSeqId];
end

function ValueCompose:GetShowInfo(nSeqId)
	local tbSeqInfo = self:GetSeqInfo(nSeqId)
	if not tbSeqInfo then
		return;
	end

	return tbSeqInfo.nIcon, tbSeqInfo.szDirTitle, tbSeqInfo.szTips;
end

function ValueCompose:GetSeqAllCount(nSeqId)
	local tbSeqInfo = self:GetSeqInfo(nSeqId)
	if not tbSeqInfo then
		return;
	end
	return tbSeqInfo.nAllCount
end

function ValueCompose:GetSeqTempleteId(nSeqId)
	local tbSeqInfo = self:GetSeqInfo(nSeqId)
	if not tbSeqInfo then
		return;
	end
	return tbSeqInfo.nTargetTemplateId
end

--是否是有效范围内的Value
function ValueCompose:CheckIsValidValue(nSeq,nPos)
	
	if not nSeq or not nPos or nSeq <= 0 or nPos <= 0 then
		Log("ValueCompose:CheckIsValidValue is not a valid value ",nSeq,nPos)
		return ;
	end

	local tbSeqInfo = self:GetSeqInfo(nSeq);
	if not tbSeqInfo then
		return;
	end

	if nPos > tbSeqInfo.nAllCount then
		return;
	end

	return true;
end

function ValueCompose:GetHaveValueNum(pPlayer,nSeqId)
	local nCount = 0;
	local tbSeqInfo = self:GetNeedCollectValue(nSeqId);
	for _,tbTemp in ipairs(tbSeqInfo) do
		local nId = tbTemp.nSeqId;
		local nPos = tbTemp.nPos;
		if ValueItem.ValueCompose:GetValue(pPlayer,nId,nPos) > 0 then
			nCount = nCount + 1;
		end
	end
	return nCount
end

--是否拥有某个Value
function ValueCompose:CheckIsHaveValue(pPlayer,nSeqId,nPos)
	if not self:CheckIsValidValue(nSeqId,nPos) then
		return ;
	end
	return ValueItem.ValueCompose:GetValue(pPlayer,nSeqId,nPos) > 0;
end

--是否搜集完了Value
function ValueCompose:CheckIsFinish(pPlayer,nSeqId,bJustResult)

	local tbSeqInfo = self:GetNeedCollectValue(nSeqId);
	if not tbSeqInfo then
		Log("ValueCompose:CheckIsFinish ?? can not find tbSeqInfo",pPlayer.szName,nSeqId)
		return
	end
	local tbUnfinishPos = {};
	local tbFinishPos = {};
	local bIsFinish = true;
	for _,tbTemp in ipairs(tbSeqInfo) do
		local nId = tbTemp.nSeqId;
		local nPos = tbTemp.nPos;
		if not self:CheckIsValidValue(nId,nPos) then
			Log("ValueCompose:CheckIsValidValue ?? is a invalid value",nId,nPos);
			return 
		end
		if ValueItem.ValueCompose:GetValue(pPlayer,nId,nPos) < 1 then
			bIsFinish = false;
			if bJustResult then
				return bIsFinish;
			end
			table.insert(tbUnfinishPos,nPos);
		else
			table.insert(tbFinishPos,nPos);
		end
	end

	return bIsFinish,tbUnfinishPos,tbFinishPos;
end

--返回需要搜集的Value
function ValueCompose:GetNeedCollectValue(nSeqId)
	local tbSeqInfo = {}
	
	local nAllCount = self:GetSeqAllCount(nSeqId);
	if nAllCount then
		for nPos=1,nAllCount do
			local tbTemp = {};
			tbTemp.nSeqId = nSeqId;
			tbTemp.nPos = nPos;
			table.insert(tbSeqInfo,tbTemp);
		end
		return tbSeqInfo;
	end
end

function ValueCompose:CheckValueCompose(pPlayer,nSeqId)
	
	if not nSeqId or not tonumber(nSeqId) then
		return false,"違法合成操作！";
	end

	nSeqId = tonumber(nSeqId)
	if nSeqId < 1 then
		return false,"你要合成什麼？";
	end

	local tbSeqInfo  = self:GetSeqInfo(nSeqId);
	if not tbSeqInfo then
		return false,"找不到合成資訊！";
	end

	local nTargetTemplateId = tbSeqInfo.nTargetTemplateId
	if not nTargetTemplateId then
		return false,"找不到合成目標！"; 
	end

	local bIsFinish, _, tbFinishPos = self:CheckIsFinish(pPlayer, nSeqId)
	if not bIsFinish then
		return false,"還沒有完成拼圖！";
	end

	if pPlayer.CheckNeedArrangeBag() then
		return false,"請先整理一下背包物品！";
	end

	return true, "", nTargetTemplateId, tbFinishPos;
end

